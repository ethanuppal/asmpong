; Copyright (C) 2023 Ethan Uppal. All rights reserved.
;
; tui.nasm:
; - tui_begin
; - tui_end
; - tui_keys
; - tui_draw

; I realized that I probably don't need to be pushing r12-15 etc and using them,
; but it is what it is.

bits 64

%include "config.nasm"
%include "struct_tui.nasm"

section .text

extern _malloc
extern _free
extern _fcntl
extern _tcgetattr
extern _tcsetattr
extern _memset
extern _poll
extern _read
extern _putchar
extern _tcflush

%macro $tui_loop_r13_r14_start 1
    xor r13d, r13d
%1.v_loop:
    cmp r13, [r12 + OFF_tui_height]
    je %1.v_loop_exit
    xor r14d, r14d
%1.h_loop:
    cmp r14, [r12 + OFF_tui_width]
    je %1.h_loop_exit
%endmacro

%macro $tui_loop_r13_r14_between 1
    inc r14
    jmp %1.h_loop
%1.h_loop_exit:
    inc r13
%endmacro

%macro $tui_loop_r13_r14_end 1
    jmp %1.v_loop
%1.v_loop_exit: 
%endmacro

; void tui_begin(struct tui* t, int width, int height)
;   rdi = struct tui* t;
;   esi = int width;
;   edx = int height;
global _tui_begin
_tui_begin:
    push rbp
    mov rbp, rsp
    sub rsp, 8      ; stack alignment (see next instruction)
    push r12        ; callee must save
    mov r12, rdi

    mov [r12 + OFF_tui_width], rsi      ; t->width = width;
    mov [r12 + OFF_tui_height], rdx     ; t->height = height;

    ; t->fcntl = fcntl(STDIN_FILENO, F_GETFL);
    mov edi, M_STDIN_FILENO
    mov esi, M_F_GETFL
    call _fcntl
    mov [r12 + OFF_tui_fcntl], eax

    ; tcgetattr(STDOUT_FILENO, &t->old);
    mov edi, M_STDOUT_FILENO
    lea rsi, [r12 + OFF_tui_old]
    call _tcgetattr

    ; fcntl(STDIN_FILENO, F_SETFL, t->fcntl | O_NONBLOCK);
    mov edi, M_STDIN_FILENO
    mov esi, M_F_SETFL
    mov edx, [r12 + OFF_tui_fcntl]
    or edx, M_O_NONBLOCK
    call _fcntl

    ; t->new = t->old; // inefficiently though...
    mov edi, M_STDOUT_FILENO
    lea rsi, [r12 + OFF_tui_new]
    call _tcgetattr

    ; t->new.c_lflag &= ~(ECHO | ICANON);
    lea rdi, [r12 + OFF_tui_new + OFF_termios_cflag]
    mov esi, [rdi]
    and esi, ~(M_ECHO | M_ICANON)
    mov [rdi], esi

    ; tcsetattr(STDOUT_FILENO, TCSAFLUSH, &t->new)
    mov edi, M_STDOUT_FILENO
    mov esi, M_TCSAFLUSH
    lea rdx, [r12 + OFF_tui_new]
    call _tcsetattr

    ; t->polldf.fd = STDIN_FILENO;
    mov dword [r12 + OFF_tui_pollfd + OFF_pollfd_fd], M_STDIN_FILENO

    ; t->polldf.events = POLLIN;
    mov dword [r12 + OFF_tui_pollfd + OFF_pollfd_events], M_POLLIN

    ; t->polldf.revents = 0;
    mov dword [r12 + OFF_tui_pollfd + OFF_pollfd_revents], 0

    ; t->buf = malloc(W * H);
    mov rdi, W * H
    call _malloc
    mov [r12 + OFF_tui_buf], rax

    ; memset(t->buf, ' ', W * H);
    mov rdi, rax
    mov esi, ' '
    mov rdx, W * H
    call _memset

    ; printf("%s", HIDE_CURSOR);
    $print HIDE_CURSOR, HIDE_CURSOR_LEN

    mov rsp, rbp
    pop rbp
    ret


; void tui_end(struct tui* t)
;   rdi = struct tui* t;
global _tui_end
_tui_end:
    push rbp
    mov rbp, rsp
    sub rsp, 8      ; stack alignment (see next instruction)
    push r12        ; callee must save
    mov r12, rdi

    ; fcntl(STDIN_FILENO, F_SETFL, t->fcntl);
    mov edi, M_STDIN_FILENO
    mov esi, M_F_SETFL
    mov edx, [r12+OFF_tui_fcntl]
    call _fcntl

    ; tcsetattr(STDOUT_FILENO, TCSAFLUSH, &t->old);
    mov edi, M_STDOUT_FILENO
    mov esi, M_TCSAFLUSH
    lea rdx, [r12+OFF_tui_old]
    call _tcsetattr

    ; free(t->buf);
    mov rdi, [r12+OFF_tui_buf]
    call _free

    ; printf(SHOW_CURSOR);
    $print SHOW_CURSOR, SHOW_CURSOR_LEN

    mov rsp, rbp
    pop rbp
    ret

; void tui_keys(struct tui* t)
;   rdi = struct tui* t;
global _tui_keys
_tui_keys:
    push rbp
    mov rbp, rsp
    push r12        ; callee must save
    push r13        ; callee must save
    mov r12, rdi

    ; t.c = 0
    mov qword [r12 + OFF_tui_c], 0

    ; if (poll(&t.pollfd, 1, 5 /* ms */) > 0)
    ;     if (read(STDIN_FILENO, &t.c, 1 /* bytes */) == 1)
    ;         // got input
    lea rdi, [r12 + OFF_tui_pollfd]
    mov esi, 1
    mov edx, 5
    call _poll
    cmp rax, 1
    jne .no_input
    mov edi, M_STDIN_FILENO
    lea rsi, [r12 + OFF_tui_c]
    mov edx, 1
    call _read
    cmp rax, 1
    jne .no_input
.no_input:

    mov rsp, rbp
    pop rbp
    ret

; void tui_draw(struct tui* t)
;   rdi = struct tui* t;
global _tui_draw
_tui_draw:
    push rbp
    mov rbp, rsp
    push r12        ; callee must save
    push r13
    push r14
    push r15
    mov r12, rdi

    ; printf("\e[H");
    $print GO_HOME, GO_HOME_LEN

    ; for (int i = 0; i < t->h; i++) {
    ;     for (int j = 0; j < t->w; j++) 
    ;         putchar(t->b[i * t->w + j]);
    ;     putchar('\n');
    ; }
    $tui_loop_r13_r14_start _tui_draw
    mov r15, [r12 + OFF_tui_buf]        ; r15 = t->b
    mov rdi, r13                        ; rdi = i
    mov rsi, [r12 + OFF_tui_width]      ; rsi = t->w
    imul rdi, rsi                       ; rdi = i * t->w
    add rdi, r14                        ; rdi = i * t->w + j
    mov rsi, rdi
    xor edi, edi
    mov dil, [r15 + rsi]                ; rdi = t->b[rdi]
    call _putchar
    $tui_loop_r13_r14_between _tui_draw
    mov edi, '\n'
    call _putchar
    $tui_loop_r13_r14_end _tui_draw

    ; tcflush(STDOUT_FILENO, TCIOFLUSH)
    mov edi, M_STDIN_FILENO
    mov esi, M_TCIOFLUSH
    call _tcflush

    mov rsp, rbp
    pop rbp
    ret

; void tui_fill(struct tui* t, char fill)
;   rdi = struct tui* t;
;   sil = char fill;
global _tui_fill
_tui_fill:
    push rbp
    mov rbp, rsp
    push r12        ; callee must save
    push r13
    push r14
    push r15
    mov r12, rdi
    mov r15, [r12 + OFF_tui_buf]        ; r15 = t->b

    $tui_loop_r13_r14_start _tui_fill
    mov rdi, r13                        ; rdi = i
    mov rdx, [r12 + OFF_tui_width]      ; rdx = t->w
    imul rdi, rdx                       ; rdi = i * t->w
    add rdi, r14                        ; rdi = i * t->w + j
    mov [r15 + rdi], sil                ; t->b[rdi] = (char)rsi
    $tui_loop_r13_r14_between _tui_fill
    $tui_loop_r13_r14_end _tui_fill

    mov rsp, rbp
    pop rbp
    ret

section .rodata
    HIDE_CURSOR: db 27, "[?25l"
    HIDE_CURSOR_LEN: equ $ - HIDE_CURSOR

    SHOW_CURSOR: db 27, "[?25h"
    SHOW_CURSOR_LEN: equ $ - SHOW_CURSOR

    GO_HOME: db 27, "[H"
    GO_HOME_LEN: equ $ - GO_HOME

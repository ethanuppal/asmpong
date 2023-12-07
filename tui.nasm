; Copyright (C) 2023 Ethan Uppal. All rights reserved.
;
; tui.nasm:
; - tui_begin
; - tui_end
; - tui_keys
; - tui_draw

%include "config.nasm"
%include "struct_tui.nasm"

section .text

extern _malloc
extern _free
extern _fcntl
extern _tcgetattr
extern _tcsetattr
extern _memset

; struct tui* tui_begin()
;   rdi = struct tui* t;
;   esi = int width;
;   edx = int height;
global _tui_begin
_tui_begin:
    mov r8, rdi

    mov [r8+OFF_tui_width], esi     ; t->width = width;
    mov [r8+OFF_tui_height], edx    ; t->height = height;

    ; t->fcntl = fcntl(STDIN_FILENO, F_GETFL);
    mov edi, M_STDIN_FILENO
    mov esi, M_F_GETFL
    call _fcntl
    mov [r8+OFF_tui_fcntl], eax

    ; tcgetattr(STDOUT_FILENO, &t->old);
    mov edi, M_STDOUT_FILENO
    lea rsi, [r8+OFF_tui_old]
    call _tcgetattr

    ; fcntl(STDIN_FILENO, F_SETFL, t->fcntl | O_NONBLOCK);
    mov edi, M_STDIN_FILENO
    mov esi, M_F_SETFL
    mov edx, [r8+OFF_tui_fcntl]
    or edx, M_O_NONBLOCK
    call _fcntl

    ; t->new = t->old; // inefficiently though...
    mov edi, M_STDOUT_FILENO
    lea rsi, [r8+OFF_tui_new]
    call _tcgetattr

    ; t->new.c_lflag &= ~(ECHO | ICANON);
    lea rdi, [r8+OFF_tui_new+OFF_termios_cflag]
    mov esi, [rdi]
    and esi, ~(M_ECHO | M_ICANON)
    mov [rdi], esi

    ; tcsetattr(STDOUT_FILENO, TCSAFLUSH, &t->new)
    mov edi, M_STDOUT_FILENO
    mov esi, M_TCSAFLUSH
    lea rdx, [r8+OFF_tui_old]
    call _tcsetattr

    ; t->polldf.fd = STDIN_FILENO;
    mov dword [r8+OFF_tui_pollfd+OFF_pollfd_fd], M_STDIN_FILENO

    ; t->polldf.events = POLLIN;
    mov dword [r8+OFF_tui_pollfd+OFF_pollfd_events], M_POLLIN

    ; t->polldf.revents = 0;
    mov dword [r8+OFF_tui_pollfd+OFF_pollfd_revents], 0

    ; t->buf = malloc(W * H);
    mov rdi, W * H
    call _malloc
    mov [r8+OFF_tui_buf], rax

    ; memset(t->buf, ' ', W * H);
    mov rdi, rax
    mov esi, ' '
    mov rdx, W * H
    call _memset

    ; printf(HIDE_CURSOR);
    $print HIDE_CURSOR, HIDE_CURSOR_LEN

    mov rax, r8
    ret


; struct tui* tui_end()
;   rdi = struct tui* t;
global _tui_end
_tui_end:
    mov r8, rdi

    ; fcntl(STDIN_FILENO, F_SETFL, t->fcntl);
    mov edi, M_STDIN_FILENO
    mov esi, M_F_SETFL
    mov edx, [r8+OFF_tui_fcntl]
    call _fcntl

    ; tcsetattr(STDOUT_FILENO, TCSAFLUSH, &t->old);
    mov edi, M_STDOUT_FILENO
    mov esi, M_TCSAFLUSH
    lea rdx, [r8+OFF_tui_old]
    call _tcsetattr

    ; free(t->buf);
    mov rdi, [r8+OFF_tui_buf]
    call _free

    ; printf(SHOW_CURSOR);
    $print SHOW_CURSOR, SHOW_CURSOR_LEN

    mov rax, r8
    ret

section .rodata
    HIDE_CURSOR: db 27, '[?25l'
    HIDE_CURSOR_LEN: equ $ - HIDE_CURSOR

    SHOW_CURSOR: db 27, '[?25h'
    SHOW_CURSOR_LEN: equ $ - SHOW_CURSOR

    GO_HOME: db 27, '[H'
    GO_HOME_LEN: equ $ - GO_HOME

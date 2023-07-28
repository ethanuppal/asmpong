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

;T.f=fcntl(I,F_GETFL);tcgetattr(O,&T.t);fcntl(I,F_SETFL,T.f|O_NONBLOCK);T.u=T.t;T.u.c_lflag&=~(ECHO|ICANON);tcsetattr(O,Y(SA),&T.u);T.p.fd=I;T.p.events=POLLIN;T.p.revents=0;T.b=malloc(W*H);memset(T.b,' ',W*H);

; void tui_begin()
;   rdi = struct tui* t;
;   esi = int width;
;   edx = int height;
global _tui_begin
_tui_begin:
    mov [rdi], esi      ; t->width = width;
    mov [rdi+4], edx    ; t->height = height;
    ; mov [rdi+12]
    $print HIDE_CURSOR, HIDE_CURSOR_LEN

section .rodata
    HIDE_CURSOR: db 'lol\n'
    HIDE_CURSOR_LEN: equ $ - HIDE_CURSOR

    SHOW_CURSOR: db '\e[?25h'
    SHOW_CURSOR_LEN: equ $ - SHOW_CURSOR

    GO_HOME: db '\e[H'
    GO_HOME_LEN: equ $ - GO_HOME

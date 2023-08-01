; Copyright (C) 2023 Ethan Uppal. All rights reserved.
;
; game.nasm:
; - _game

%include "config.nasm"
%include "struct_tui.nasm"

section .text

extern _malloc
extern _free
extern _tui_begin
extern _tui_end
extern _tui_keys
extern _tui_draw

; int game(void);
;   keep r12 = struct tui* tui;
global _game
_game:
    mov rdi, SZ_STRUCT_TUI
    call _malloc
    cmp rax, 0
    jz _game.error
    mov r12, rax
    ; BEGIN GAME LOGIC (tui in r12)
    call _tui_begin
    ; END GAME LOGIC
    mov rdi, r12
    call _free
    xor eax, eax
    ret
_game.error:
    $print error_msg, error_msg_len
    mov eax, 1
    ret

section .rodata
    error_msg: db 'A problem occured while running the game.', 10
    error_msg_len: equ $ - error_msg

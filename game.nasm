; Copyright (C) 2023 Ethan Uppal. All rights reserved.
;
; game.nasm:
; - _game

bits 64

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
    push rbp
    mov rbp, rsp
    mov rdi, SZ_STRUCT_TUI
    call _malloc        ; struct tui* rax = malloc(sizeof(struct tui));
    cmp rax, 0          ; if (!tui)
    jz _game.error      ;     game_error();
    mov r12, rax        ; // <- r12 forever :sunglasses:
    mov rdi, r12        
    mov esi, W          
    mov edx, H
    ; BEGIN GAME LOGIC (tui in r12)
    call _tui_begin     ; tui_begin(tui /* mov rdi, r12 */, W, H);
    mov rdi, r12
    call _tui_end       ; tui_end(tui /* mov rdi, r12 */);
    ; END GAME LOGIC
    mov rdi, rax
    call _free
    xor eax, eax
    mov rsp, rbp
    pop rbp
    ret
.error:
    $print error_msg, error_msg_len
    mov eax, 1
    mov rsp, rbp
    pop rbp
    ret

section .rodata
    error_msg: db 'A problem occured while running the game.', 10
    error_msg_len: equ $ - error_msg

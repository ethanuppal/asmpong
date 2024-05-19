; Copyright (C) 2023 Ethan Uppal. All rights reserved.
;
; main.nasm:
; - _main

bits 64

%include "config.nasm"

section .text
    align 16

; int game(void);
extern _game

; int main(int argc, char** argv);
global _main
_main:
    call _handle_args
.resume:
    call _game
    mov rdi, rax
.exit:
    mov eax, M_SYS_EXIT
    syscall

; _handle_args(edi = argc, rsi = argv):
; (this "function" does not follow any calling convention)
_handle_args:
    cmp edi, 2
    je _handle_args.args_passed     ; if argc == 2      // one arg
    cmp edi, 1
    je _main.resume                 ; if argc == 1      // no args
    jmp .error_exit                 ; goto error_exit   // not valid
.args_passed:
    mov rdx, [rsi + 8]              ; char* arg = argv[1];
    lea r9, [rel help_flag]         ; char* match = "-h";
    xor eax, eax                    ; int i = 0;
.loop:
    inc rax                         ; i++;
    mov r8b, [rdx + rax]            ; char cur = arg[i];
    mov r10b, [r9 + rax]            ; char exp = match[i];
    cmp r8b, r10b                   ; if (cur != exp)
    jne .error_exit                 ;   goto error_exit
    cmp r10b, 0                     ; if (cur == 0)
    jz .done_compare                ;   goto done_compare;
    jmp _handle_args.loop
.done_compare:
    cmp rax, help_flag_len
    jz _handle_args.print_help
.error_exit:
    $print argument_error, argument_error_len
    mov edi, 1
.finish_args:
    jmp _main.exit
.print_help:
    $print help_msg, help_msg_len
    xor edi, edi
    jmp _handle_args.finish_args

section .rodata
    align 16

    help_flag: db '-h', 0
    help_flag_len: equ $ - help_flag - 1
    help_msg: db "usage: pong [-h]", 10, 10, "Press 'q' to exit.", 10
    help_msg_len: equ $ - help_msg
    argument_error: db "error: Pass either no arguments or '-h' for help.", 10
    argument_error_len: equ $ - argument_error

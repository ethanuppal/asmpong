; Copyright (C) 2023 Ethan Uppal. All rights reserved.
;
; main.nasm:
; - _main

%include "config.nasm"

section .text

; int game(void);
extern _game

; int main(void);
global _main
_main:
    call _handle_args
_main.resume:
    call _game
    mov rdi, rax
_main.exit:
    mov eax, M_SYS_EXIT
    syscall

_handle_args:
    cmp edi, 1
    jnz _handle_args.args_passed    ; argc == 1, i.e., no args
    jmp _main.resume
_handle_args.args_passed:
    mov rdx, [rsi+8]                ; char* arg = argv[1];
    lea r9, [rel help_flag]         ; char* match = "-h";
    xor eax, eax                    ; int i = 0;
_handle_args.loop:
    inc rax                         ; i++;
    mov r8b, [rdx+rax]              ; char cur = arg[i];
    cmp r8b, 0                      ; if (cur == 0)
    jz _handle_args.done_compare    ;   goto done_compare;
_handle_args.check_compare:
    cmp r8b, [r9+rax]               ; if (cur != match[i])
    jnz _handle_args.compare_error  ;   goto compare_error;
    jmp _handle_args.loop
_handle_args.done_compare:
    cmp rax, help_flag_len
    jz _handle_args.print_help
_handle_args.compare_error:
    $print argument_error, argument_error_len
    mov edi, 1
_handle_args.finish_args:
    jmp _main.exit
_handle_args.print_help:
    $print help_msg, help_msg_len
    xor edi, edi
    jmp _handle_args.finish_args

section .rodata
    help_flag: db '-h', 0
    help_flag_len: equ $ - help_flag - 1
    help_msg: db 'usage: pong [-h]', 10
    help_msg_len: equ $ - help_msg
    argument_error: db 'error: Pass either no arguments or -h.', 10
    argument_error_len: equ $ - argument_error

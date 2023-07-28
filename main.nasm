; Copyright (C) 2023 Ethan Uppal. All rights reserved.
;
; main.nasm:
; - _main

%include "config.nasm"

section .text

; int main(void);
global _main
_main:
    $print msg, 3
    xor edi, edi
    mov eax, M_SYS_EXIT
    syscall

section .rodata
    msg: db 'hi', 10

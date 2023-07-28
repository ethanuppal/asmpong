; Copyright (C) 2023 Ethan Uppal. All rights reserved.
;
; tui.nasm:
; - tui_begin
; - tui_end
; - tui_keys
; - tui_draw

%include "config.nasm"

; struct tui =
; [0-4] int width
; [5-8] int height
; [9-12] char c
; [13-16] int fcntl

section .text

; void tui_begin()
;   rdi = struct tui*
;   esi = int width
;   edx = int height
global _tui_begin
_tui_begin:
    mov [rdi], esi
    mov [rdi+4], edx

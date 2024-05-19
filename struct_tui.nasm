; Copyright (C) 2023 Ethan Uppal. All rights reserved.

; struct tui {
;   int64_t width;
;   int64_t height;
;   char c;
;   int32_t fcntl;
;   char* buf;
;   struct pollfd pollfd;
;   struct termios old;
;   struct termios new;
; };

bits 64

%define OFF_tui_width 0
%define OFF_tui_height 8
%define OFF_tui_c 16
%define OFF_tui_fcntl 20
%define OFF_tui_buf 24
%define OFF_tui_pollfd 32
%define OFF_tui_old OFF_tui_pollfd + SZ_STRUCT_POLLFD
%define OFF_tui_new OFF_tui_old + SZ_STRUCT_TERMIOS
%define SZ_STRUCT_TUI OFF_tui_new + SZ_STRUCT_TERMIOS

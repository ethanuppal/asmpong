; Copyright (C) 2023 Ethan Uppal. All rights reserved.

section .rodata
    global HIDE_CURSOR
    HIDE_CURSOR: db 'lol\n'
    global HIDE_CURSOR_LEN
    HIDE_CURSOR_LEN: equ $ - HIDE_CURSOR

    global SHOW_CURSOR
    SHOW_CURSOR: db '\e[?25h'
    global SHOW_CURSOR_LEN
    SHOW_CURSOR_LEN: equ $ - SHOW_CURSOR

    global GO_HOME
    GO_HOME: db '\e[H'
    global GO_HOME_LEN
    GO_HOME_LEN: equ $ - GO_HOME

// Copyright (C) 2023 Ethan Uppal. All rights reserved.

#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <unistd.h>
#include <termios.h>
#include <fcntl.h>
#include <poll.h>

int main(void) {
    const struct termios t;
    const uintptr_t c_lflag_offset = (uintptr_t)&t.c_lflag - (uintptr_t)&t;

    const struct pollfd p;
    const uintptr_t fd_offset = (uintptr_t)&p.fd - (uintptr_t)&p;
    const uintptr_t events_offset = (uintptr_t)&p.events - (uintptr_t)&p;
    const uintptr_t revents_offset = (uintptr_t)&p.revents - (uintptr_t)&p;

    printf("; Copyright (C) 2023 Ethan Uppal. All rights reserved.\n");
    printf("; This file was automatically generated by the config.c script.\n");
    printf("; It adapts to varying implementations of the POSIX library.\n");
    printf("\n");
    printf("%%define W 50\n");
    printf("%%define H 50\n");
    printf("\n");
    printf("%%define SZ_STRUCT_TERMIOS %zu\n", sizeof(struct termios));
    printf("%%define SZ_STRUCT_POLLFD %zu\n", sizeof(struct pollfd));
    printf("%%define OFF_termios_cflag %zu\n", (size_t)c_lflag_offset);
    printf("%%define OFF_pollfd_fd %zu\n", (size_t)fd_offset);
    printf("%%define OFF_pollfd_events %zu\n", (size_t)events_offset);
    printf("%%define OFF_pollfd_revents %zu\n", (size_t)revents_offset);
    printf("\n");
    printf("%%define M_SYS_EXIT 0x2000001\n");
    printf("%%define M_SYS_WRITE 0x2000004\n");
    printf("\n");
    printf("%%define M_STDIN_FILENO %d\n", STDIN_FILENO);
    printf("%%define M_STDOUT_FILENO %d\n", STDOUT_FILENO);
    printf("%%define M_F_GETFL %d\n", F_GETFL);
    printf("%%define M_F_SETFL %d\n", F_SETFL);
    printf("%%define M_O_NONBLOCK %d\n", O_NONBLOCK);
    printf("%%define M_ECHO %d\n", ECHO);
    printf("%%define M_ICANON %d\n", ICANON);
    printf("%%define M_TCSAFLUSH %d\n", TCSAFLUSH);
    printf("%%define M_TCIOFLUSH %d\n", TCIOFLUSH);
    printf("%%define M_POLLIN %d\n", POLLIN);
    printf("\n");
    printf("%%macro $print 2\n");
    printf("    mov edi, M_STDOUT_FILENO\n");
    printf("    lea rsi, [rel %%1]\n");
    printf("    mov rdx, %%2\n");
    printf("    mov eax, M_SYS_WRITE\n");
    printf("    syscall\n");
    printf("%%endmacro\n");
    printf("\n");

    return 0;
}

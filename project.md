# Project Structure

## `Makefile`

The build system for this project is contained in a `Makefile`.
It has been tested to be functional on Intel and Silicon macs.

## `config.c`

The implementation of the C standard library and POSIX differs between computers.
However, this flexibility cannot be easily coded using assembly.
Therefore, this script generates a `config.nasm` configuration file that supplies macros for the implementation-defined constants needed.

## `config.nasm`

See the description for `config.c`.

## `game.nasm`

The implementation of the game.
Handles game logic and calls the routines defined in `tui.nasm`.

## `main.nasm`

The driver program for the project.
Parses arguments and starts the game.

## `struct_tui.nasm`

Defines the TUI structure via member offsets.

## `tui.nasm`

Defines the routines for drawing in the terminal window.

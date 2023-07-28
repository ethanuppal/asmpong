# Copyright (C) 2023 Ethan Uppal. All rights reserved.

NASM	:= nasm
CC		:= $(shell which gcc || which clang)
LD		:= ld
NASMFL	:= -f macho64

SRC		:= $(shell find . -type f -name "*.nasm")
OBJ		:= $(SRC:.nasm=.o)
TARGET	:= pong
CONFIG	:= config

$(TARGET): $(OBJ)
	$(LD) -r $^ -o $@.o
	$(CC) $@.o -o $@

$(CONFIG).nasm: $(CONFIG)
	./$(CONFIG) > $(CONFIG).nasm

$(CONFIG): $(CONFIG).c
	$(CC) $< -O3 -o $@

%.o: %.nasm $(CONFIG).nasm
	$(NASM) $(NASMFL) $<

clean:
	rm -rf $(OBJ) $(TARGET) $(CONFIG) $(CONFIG).nasm

# Copyright (C) 2023 Ethan Uppal. All rights reserved.

NASM	:= nasm
CC		:= $(shell which gcc || which clang)
LD		:= ld
NASMFL	:= -f macho64

SRC		:= $(shell find . -type f -name "*.nasm")
OBJ		:= $(SRC:.nasm=.o)
TARGET	:= pong
CONFIG	:= config

.PHONY: run
run:
	make clean
	make $(TARGET)
	./$(TARGET)

.PHONY: d
d:
	make clean
	make $(TARGET)
	lldb ./$(TARGET)

$(TARGET): $(OBJ)
	$(CC) $^ -o $@

$(CONFIG).nasm: $(CONFIG)
	./$(CONFIG) > $(CONFIG).nasm

$(CONFIG): $(CONFIG).c
	$(CC) $< -O3 -o $@

%.o: %.nasm $(CONFIG).nasm
	$(NASM) $(NASMFL) $<

.PHONY: clean
clean:
	rm -rf $(OBJ) $(TARGET) $(CONFIG) $(CONFIG).nasm

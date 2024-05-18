# Copyright (C) 2023-4 Ethan Uppal. All rights reserved.

NASM	:= $(shell which nasm)
CC		:= $(shell which gcc || which clang)
CCX86	:= $(shell which clang)

LD		:= ld
NASMFL	:= -f macho64

SRC		:= $(shell find . -type f -name "*.nasm")
OBJ		:= $(SRC:.nasm=.o)
TARGET	:= pong
CONFIG	:= config

PY		:= $(shell which python3 || which python || which pypy3 || which pypy)

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
	$(CCX86) $^ -o $@

$(CONFIG).nasm: $(CONFIG)
	./$(CONFIG) > $(CONFIG).nasm

$(CONFIG): $(CONFIG).c
	$(CC) $< -O3 -o $@

%.o: %.nasm $(CONFIG).nasm
	$(NASM) $(NASMFL) $<

.PHONY: clean
clean:
	rm -rf $(OBJ) $(TARGET) $(CONFIG) $(CONFIG).nasm

.PHONY: test
test:
	@echo '==> checking python dependencies'
	@cd test; $(PY) check_deps.py 2>&1 >/dev/null \
		|| (echo -e '\x1b[31m[!] dependencies not installed\x1b[m' && exit 1) \
		&& (printf '\x1b[32m==> dependencies installed\x1b[m\n')
	@echo '==> testing CLI'
	@cd test; $(PY) main.py
	@echo -e '\x1b[32m==> all tests passed!\x1b[m'

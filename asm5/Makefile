# Путь к ассемблеру NASM
AS      := ~/nasm-2.16.01/nasm
ASFLAGS := -f elf64 -g

CC       := gcc
CFLAGS   := -std=c99 -Wall -Wextra

.PHONY: all clean

all: gray

main.o: main.c
	$(CC) $(CFLAGS) -c main.c -o main.o

process.o: process.s
	$(AS) $(ASFLAGS) process.s -o process.o

gray: main.o process.o
	$(CC) main.o process.o -o gray -lm

clean:
	rm -f main.o process.o gray gray_O0 gray_O1 gray_O2 gray_O3 gray_Ofast

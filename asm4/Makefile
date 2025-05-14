# Путь к ассемблеру NASM
AS      = ~/nasm-2.16.01/nasm
ASFLAGS = -g -f elf64

# Используем gcc для линковки (он подтянет crt*.o и libc)
CC      = gcc
LDFLAGS = -lm

SRCS    = lab.s
OBJS    = $(SRCS:.s=.o)
EXE     = lab

.PHONY: all clean

all: $(EXE)

# Линкуем через gcc с опцией -no-pie, чтобы не собирать PIE
$(EXE): $(OBJS)
	$(CC) -no-pie $(OBJS) $(LDFLAGS) -o $(EXE)

# Ассемблирование lab.s -> lab.o
%.o: %.s
	$(AS) $(ASFLAGS) -o $@ $<

clean:
	rm -f $(EXE) $(OBJS)

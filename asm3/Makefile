AS = ~/nasm-2.16.01/nasm
LD = /usr/bin/ld

ASFLAGS = -g -f elf64
LDFLAGS = -static

SRCS = lab.s
OBJS = $(SRCS:.s=.o)

EXE = lab

FILEFLAGS = $(FILEOUTPUTFLAG) $(FILEINPUTFLAG)

all: $(EXE)

clean:
	rm -rf $(EXE) $(OBJS)

%.o: %.s
	$(AS) $(ASFLAGS) $(FILEFLAGS) -o $@ $<

$(EXE): $(OBJS)
	$(LD) $(LDFLAGS) $(OBJS) -o $@

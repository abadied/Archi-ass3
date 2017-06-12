CC = gcc
NASM = nasm
LD = ld

CFLAGS = -g -m32 -Wall -ansi -c
NASMFLAGS = -g -f elf
LDFLAGS = -g -m elf_i386

all : run

run : ass3.o cell.o coroutines.o printer.o scheduler.o
	$(LD) $(LDFLAGS) $? -o $@

ass3.o : ass3.s
	$(NASM) $(NASMFLAGS) $? -o $@

cell.o : cell.c
	$(CC) $(CFLAGS) $? -o $@
	
coroutines.o : coroutines.s
	$(NASM) $(NASMFLAGS) $? -o $@

printer.o : printer.s
	$(NASM) $(NASMFLAGS) $? -o $@
	
scheduler.o : scheduler.s
	$(NASM) $(NASMFLAGS) $? -o $@

.PHONY : clean

clean :
	rm -f *.o run

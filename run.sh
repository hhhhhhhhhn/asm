nasm -g -f elf64 main.asm -o main.o \
	&& ld main.o -o main \
	&& ./main

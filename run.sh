#!/bin/sh

set -xe

nasm -g -f elf64 lib.asm -o lib.o
nasm -g -f elf64 main.asm -o main.o

ld lib.o main.o -o main
./main

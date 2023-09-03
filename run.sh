#!/bin/sh

set -xe

nasm -g -f elf64 lib.asm -o lib.o
nasm -g -f elf64 north.asm -o north.o

ld lib.o north.o -o north
./north <main.north >compiled/out.s

nasm -g -f elf64 northlib.asm -o northlib.o
nasm -g -f elf64 compiled/out.s -o compiled/out.o
ld compiled/out.o northlib.o -o compiled/out
./compiled/out

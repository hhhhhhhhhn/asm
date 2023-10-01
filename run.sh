#!/bin/sh

set -xe

mkdir compiled 2>/dev/null || true

nasm -g -f elf64 lib.asm -o compiled/lib.o
nasm -g -f elf64 north.asm -o compiled/north.o

ld compiled/lib.o compiled/north.o -o compiled/north
./compiled/north lib <northlib2.north > compiled/northlib2.s

nasm -g -f elf64 compiled/northlib2.s -o compiled/northlib2.o

./compiled/north <main.north >compiled/out.s

nasm -g -f elf64 northlib.asm -o compiled/northlib.o
nasm -g -f elf64 compiled/out.s -o compiled/out.o
ld compiled/out.o compiled/northlib.o compiled/northlib2.o -o compiled/out
./compiled/out

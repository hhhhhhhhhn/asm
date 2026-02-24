#!/bin/sh

set -xe

mkdir compiled 2>/dev/null || true

nasm -g -f elf64 lib.asm -o compiled/lib.o
nasm -g -f elf64 north.asm -o compiled/north.o

ld compiled/lib.o compiled/north.o -o compiled/north
./compiled/north lib <northlib2.north > compiled/northlib2.s

nasm -g -f elf64 compiled/northlib2.s -o compiled/northlib2.o

./compiled/north <hlang.north >compiled/hc.s

nasm -g -f elf64 northlib.asm -o compiled/northlib.o
nasm -g -f elf64 compiled/hc.s -o compiled/hc.o
ld compiled/hc.o compiled/northlib.o compiled/northlib2.o -o compiled/hc

./compiled/hc <main.hlang >compiled/hmain.s

nasm -g -f elf64 hlib.asm -o compiled/hlib.o
nasm -g -f elf64 compiled/hmain.s -o compiled/hmain.o
ld compiled/hlib.o compiled/hmain.o -o compiled/hmain

./compiled/hmain

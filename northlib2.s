section .text

extern dup
extern rot
extern unrot
extern over
extern pop
extern swap
extern prints
extern printu
extern printi
extern newline
extern add
extern sub
extern mul
extern lt
extern le
extern gt
extern ge
extern eq
extern ne
extern dump
extern dumplen
extern syscall
extern syscall7
extern strlen
global write
write:
sub rcx, 8
mov qword[rcx], 1
call unrot
call swap
call dup
call strlen
call syscall
ret
global open_file_writing
open_file_writing:
sub rcx, 8
mov qword[rcx], 2
call swap
sub rcx, 8
mov qword[rcx], 577
sub rcx, 8
mov qword[rcx], 0770
call syscall
ret
global close_file
close_file:
sub rcx, 8
mov qword[rcx], 3
call swap
sub rcx, 8
mov qword[rcx], 0
sub rcx, 8
mov qword[rcx], 0
call syscall
ret
global mmap
mmap:
sub rcx, 8
mov qword[rcx], 9
call swap
sub rcx, 8
mov qword[rcx], 0
call swap
sub rcx, 8
mov qword[rcx], 4096
call mul
sub rcx, 8
mov qword[rcx], 3
sub rcx, 8
mov qword[rcx], 34
sub rcx, 8
mov qword[rcx], -1
sub rcx, 8
mov qword[rcx], 0
call syscall7
ret
global munmap
munmap:
sub rcx, 8
mov qword[rcx], 11
call unrot
sub rcx, 8
mov qword[rcx], 0
call syscall
call pop
ret
section .data
section .bss
STACK resq 1024

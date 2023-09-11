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
extern set
extern get
extern add
extern sub
extern mul
extern lt
extern le
extern gt
extern ge
extern eq
extern ne
extern band
extern bor
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
round_up_to_page:
call dup
sub rcx, 8
mov qword[rcx], 0b111111111111
call band
sub rcx, 8
mov qword[rcx], 0
call ne
sub rcx, 8
mov qword[rcx], 4096
call mul
call swap
sub rcx, 8
mov qword[rcx], 0xfffffffffffff000
call band
call add
ret
global mmap
mmap:
call round_up_to_page
sub rcx, 8
mov qword[rcx], 9
call swap
sub rcx, 8
mov qword[rcx], 0
call swap
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
call round_up_to_page
sub rcx, 8
mov qword[rcx], 0
call syscall
ret
section .data
section .bss
STACK resq 1024

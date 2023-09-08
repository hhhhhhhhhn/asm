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
global mul
mul:
sub rcx, 8
mov qword[rcx], 0
.loop1:
call swap
call dup
sub rcx, 8
mov qword[rcx], 0
call le
mov rax, qword[rcx]
add rcx, 8
cmp rax, 0
je .ifelse2
jmp .break1
jmp .ifend2
.ifelse2:
.ifend2:
call swap
call rot
call swap
call over
call add
call swap
call unrot
call swap
sub rcx, 8
mov qword[rcx], 1
call sub
call swap
jmp .loop1
.break1:
call rot
call pop
call pop
ret
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
global open_file
open_file:
sub rcx, 8
mov qword[rcx], 2
call swap
sub rcx, 8
mov qword[rcx], 65
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
section .data
section .bss
STACK resq 1024

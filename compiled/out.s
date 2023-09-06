global _start
global main
global STACK
section .text
_start:
lea rcx, [STACK+1024*8]
call main
mov rax, 60
mov rdi, 0
syscall

extern dup
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
extern dump
extern dumplen
fib:
call dup
sub rcx, 8
mov qword[rcx], 1
call le
mov rax, qword[rcx]
add rcx, 8
cmp rax, 0
je .ifelse1
call pop
sub rcx, 8
mov qword[rcx], 1
jmp .ifend1
.ifelse1:
call dup
sub rcx, 8
mov qword[rcx], 1
call sub
call fib
call swap
sub rcx, 8
mov qword[rcx], 2
call sub
call fib
call add
.ifend1:
ret
main:
sub rcx, 8
mov qword[rcx], 30
call fib
call printu
call newline
ret
section .data
section .bss
STACK resq 1024

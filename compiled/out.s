section .text
global _start
global STACK
_start:
lea rcx, [STACK+1024*8]
call main
mov rax, 60
mov rdi, 0
syscall

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
ret
jmp .ifend1
.ifelse1:
.ifend1:
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
ret
sum:
sub rcx, 8
mov qword[rcx], 0
.loop2:
.loop3:
jmp .break3
jmp .loop3
.break3:
call over
call add
call swap
sub rcx, 8
mov qword[rcx], 1
call sub
call dup
sub rcx, 8
mov qword[rcx], 0
call lt
mov rax, qword[rcx]
add rcx, 8
cmp rax, 0
je .ifelse4
jmp .break2
jmp .ifend4
.ifelse4:
call swap
.ifend4:
jmp .loop2
.break2:
call pop
ret
extern mmap
extern munmap
main:
sub rcx, 8
mov qword[rcx], 1024
call mmap
call dup
sub rcx, 8
mov qword[rcx], 10
sub rcx, 8
mov qword[rcx], 1024
call set
call dup
sub rcx, 8
mov qword[rcx], 10
call get
call printu
call newline
sub rcx, 8
mov qword[rcx], 1024
call munmap
ret
section .data
section .bss
STACK resq 1024

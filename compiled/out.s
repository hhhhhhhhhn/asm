global _start
section .text
_start:
lea rcx, [STACK+1024]
call main
mov rax, 60
mov rdi, 0
syscall
extern print
name:
lea rax, STR0
sub rcx, 8
mov qword[rcx], rax
ret
extern main
main:
call name
call print
ret
section .data
STR0 db `"\`John\`"\n`, 0
section .bss
STACK resq 1024

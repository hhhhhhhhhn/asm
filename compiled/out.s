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
extern call
fib:
push rbp
mov rbp, rsp
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
mov rsp, rbp
pop rbp
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
mov rsp, rbp
pop rbp
ret
sum:
push rbp
mov rbp, rsp
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
mov rsp, rbp
pop rbp
ret
add_test:
push rbp
mov rbp, rsp
sub rsp, 8
sub rsp, 8
mov rax, qword[rcx]
mov qword[rsp + 8*0], rax
add rcx, 8
mov rax, qword[rcx]
mov qword[rsp + 8*1], rax
add rcx, 8
sub rcx, 8
mov rax, qword[rsp + 8*1]
mov qword[rcx], rax
sub rcx, 8
mov rax, qword[rsp + 8*0]
mov qword[rcx], rax
call add
mov rsp, rbp
pop rbp
ret
test_get_a:
mov rax, qword[rcx]
mov rbx, qword[rax + 8*0]
mov qword[rcx], rbx
ret
test_set_a:
mov rax, qword[rcx + 8]
mov rbx, qword[rcx]
mov qword[rax + 8*0], rbx
add rcx, 16
ret
test_get_b:
mov rax, qword[rcx]
mov rbx, qword[rax + 8*1]
mov qword[rcx], rbx
ret
test_set_b:
mov rax, qword[rcx + 8]
mov rbx, qword[rcx]
mov qword[rax + 8*1], rbx
add rcx, 16
ret
test_get_c:
mov rax, qword[rcx]
mov rbx, qword[rax + 8*2]
mov qword[rcx], rbx
ret
test_set_c:
mov rax, qword[rcx + 8]
mov rbx, qword[rcx]
mov qword[rax + 8*2], rbx
add rcx, 16
ret
test_size:
sub rcx, 8
mov qword[rcx], 24
ret
test_get:
mov rbx, qword[rcx + 8]
mov rax, qword[rcx]
mov rdx, 24
mul rdx
add rbx, rax
add rcx, 8
mov qword[rcx], rbx
ret
print_stuff:
push rbp
mov rbp, rsp
call dup
call printu
call dup
call printu
call printu
mov rsp, rbp
pop rbp
ret
extern arena_new
extern arena_destroy
extern arena_alloc
main:
push rbp
mov rbp, rsp
sub rsp, 8
sub rcx, 8
mov qword[rcx], 1024
call arena_new
mov rax, qword[rcx]
mov qword[rsp + 8*0], rax
add rcx, 8
sub rsp, 8
sub rsp, 8
sub rcx, 8
mov rax, qword[rsp + 8*2]
mov qword[rcx], rax
sub rcx, 8
mov qword[rcx], 100
call arena_alloc
mov rax, qword[rcx]
mov qword[rsp + 8*1], rax
add rcx, 8
sub rcx, 8
mov rax, qword[rsp + 8*2]
mov qword[rcx], rax
sub rcx, 8
mov qword[rcx], 200
call arena_alloc
mov rax, qword[rcx]
mov qword[rsp + 8*0], rax
add rcx, 8
sub rcx, 8
mov rax, qword[rsp + 8*2]
mov qword[rcx], rax
sub rcx, 8
mov qword[rcx], 200
call arena_alloc
call pop
sub rcx, 8
mov rax, qword[rsp + 8*2]
mov qword[rcx], rax
sub rcx, 8
mov qword[rcx], 200
call arena_alloc
call pop
sub rcx, 8
mov rax, qword[rsp + 8*2]
mov qword[rcx], rax
sub rcx, 8
mov qword[rcx], 200
call arena_alloc
call pop
sub rcx, 8
mov rax, qword[rsp + 8*2]
mov qword[rcx], rax
sub rcx, 8
mov qword[rcx], 200
call arena_alloc
call pop
sub rcx, 8
mov rax, qword[rsp + 8*2]
mov qword[rcx], rax
sub rcx, 8
mov qword[rcx], 200
call arena_alloc
call pop
sub rcx, 8
mov rax, qword[rsp + 8*1]
mov qword[rcx], rax
sub rcx, 8
mov qword[rcx], 10
sub rcx, 8
mov qword[rcx], 1111
call set
sub rcx, 8
mov rax, qword[rsp + 8*0]
mov qword[rcx], rax
sub rcx, 8
mov qword[rcx], 10
sub rcx, 8
mov qword[rcx], 2222
call set
sub rcx, 8
mov rax, qword[rsp + 8*1]
mov qword[rcx], rax
sub rcx, 8
mov qword[rcx], 10
call get
call printu
call newline
sub rcx, 8
mov rax, qword[rsp + 8*0]
mov qword[rcx], rax
sub rcx, 8
mov qword[rcx], 10
call get
call printu
call newline
sub rcx, 8
mov rax, qword[rsp + 8*2]
mov qword[rcx], rax
call arena_destroy
mov rsp, rbp
pop rbp
ret
section .data
section .bss
STACK resq 1024

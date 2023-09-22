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
extern array_get
extern array_set
extern get_byte
extern set_byte
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
extern global_arena_allocator_start
extern global_arena_allocator_end
extern malloc
extern list_new
extern list_push_new
extern list_get
extern list_destroy
extern list_grow
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
test_at:
mov rbx, qword[rcx + 8]
mov rax, qword[rcx]
mov rdx, 24
mul rdx
add rbx, rax
add rcx, 8
mov qword[rcx], rbx
ret
main:
push rbp
mov rbp, rsp
sub rcx, 8
mov qword[rcx], 1024
sub rcx, 8
mov qword[rcx], 1024
call mul
call global_arena_allocator_start
sub rsp, 8
call test_size
call list_new
mov rax, qword[rcx]
mov qword[rsp + 8*0], rax
add rcx, 8
sub rcx, 8
mov rax, qword[rsp + 8*0]
mov qword[rcx], rax
call list_push_new
call dup
sub rcx, 8
mov qword[rcx], 13
call test_set_a
call dup
sub rcx, 8
mov qword[rcx], 12
call test_set_b
sub rcx, 8
mov qword[rcx], 11
call test_set_c
sub rcx, 8
mov rax, qword[rsp + 8*0]
mov qword[rcx], rax
call list_push_new
call dup
sub rcx, 8
mov qword[rcx], 23
call test_set_a
call dup
sub rcx, 8
mov qword[rcx], 22
call test_set_b
sub rcx, 8
mov qword[rcx], 21
call test_set_c
sub rcx, 8
mov rax, qword[rsp + 8*0]
mov qword[rcx], rax
sub rcx, 8
mov qword[rcx], 0
call list_get
call dup
call test_get_a
call printu
call newline
call dup
call test_get_b
call printu
call newline
call test_get_c
call printu
call newline
call newline
sub rsp, 8
sub rcx, 8
mov qword[rcx], 0
mov rax, qword[rcx]
mov qword[rsp + 8*0], rax
add rcx, 8
.loop1:
sub rcx, 8
mov rax, qword[rsp + 8*0]
mov qword[rcx], rax
sub rcx, 8
mov qword[rcx], 2000
call ge
mov rax, qword[rcx]
add rcx, 8
cmp rax, 0
je .ifelse2
jmp .break1
jmp .ifend2
.ifelse2:
.ifend2:
sub rcx, 8
mov rax, qword[rsp + 8*1]
mov qword[rcx], rax
call list_push_new
call pop
sub rcx, 8
mov rax, qword[rsp + 8*0]
mov qword[rcx], rax
sub rcx, 8
mov qword[rcx], 1
call add
mov rax, qword[rcx]
mov qword[rsp + 8*0], rax
add rcx, 8
jmp .loop1
.break1:
sub rcx, 8
mov rax, qword[rsp + 8*1]
mov qword[rcx], rax
sub rcx, 8
mov qword[rcx], 1
call list_get
call dup
call test_get_a
call printu
call newline
call dup
call test_get_b
call printu
call newline
call test_get_c
call printu
call newline
sub rcx, 8
mov rax, qword[rsp + 8*1]
mov qword[rcx], rax
call list_destroy
call global_arena_allocator_end
mov rsp, rbp
pop rbp
ret
section .data
section .bss
STACK resq 1024

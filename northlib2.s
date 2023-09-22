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
global write
write:
push rbp
mov rbp, rsp
sub rcx, 8
mov qword[rcx], 1
call unrot
call swap
call dup
call strlen
call syscall
mov rsp, rbp
pop rbp
ret
global open_file_writing
open_file_writing:
push rbp
mov rbp, rsp
sub rcx, 8
mov qword[rcx], 2
call swap
sub rcx, 8
mov qword[rcx], 577
sub rcx, 8
mov qword[rcx], 0770
call syscall
mov rsp, rbp
pop rbp
ret
global close_file
close_file:
push rbp
mov rbp, rsp
sub rcx, 8
mov qword[rcx], 3
call swap
sub rcx, 8
mov qword[rcx], 0
sub rcx, 8
mov qword[rcx], 0
call syscall
mov rsp, rbp
pop rbp
ret
round_up_to_page:
push rbp
mov rbp, rsp
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
mov rsp, rbp
pop rbp
ret
global mmap
mmap:
push rbp
mov rbp, rsp
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
mov rsp, rbp
pop rbp
ret
global munmap
munmap:
push rbp
mov rbp, rsp
sub rcx, 8
mov qword[rcx], 11
call unrot
call round_up_to_page
sub rcx, 8
mov qword[rcx], 0
call syscall
mov rsp, rbp
pop rbp
ret
section .bss
malloc_internal resb 8
section .text
section .bss
free_internal resb 8
section .text
global malloc
malloc:
push rbp
mov rbp, rsp
sub rcx, 8
lea rax, malloc_internal
mov qword[rcx], rax
call get
call call
mov rsp, rbp
pop rbp
ret
global free
free:
push rbp
mov rbp, rsp
sub rcx, 8
lea rax, free_internal
mov qword[rcx], rax
call get
call call
mov rsp, rbp
pop rbp
ret
arena_get_pointer:
mov rax, qword[rcx]
mov rbx, qword[rax + 8*0]
mov qword[rcx], rbx
ret
arena_set_pointer:
mov rax, qword[rcx + 8]
mov rbx, qword[rcx]
mov qword[rax + 8*0], rbx
add rcx, 16
ret
arena_get_used:
mov rax, qword[rcx]
mov rbx, qword[rax + 8*1]
mov qword[rcx], rbx
ret
arena_set_used:
mov rax, qword[rcx + 8]
mov rbx, qword[rcx]
mov qword[rax + 8*1], rbx
add rcx, 16
ret
arena_get_cap:
mov rax, qword[rcx]
mov rbx, qword[rax + 8*2]
mov qword[rcx], rbx
ret
arena_set_cap:
mov rax, qword[rcx + 8]
mov rbx, qword[rcx]
mov qword[rax + 8*2], rbx
add rcx, 16
ret
arena_size:
sub rcx, 8
mov qword[rcx], 24
ret
arena_at:
mov rbx, qword[rcx + 8]
mov rax, qword[rcx]
mov rdx, 24
mul rdx
add rbx, rax
add rcx, 8
mov qword[rcx], rbx
ret
global arena_new
arena_new:
push rbp
mov rbp, rsp
sub rsp, 8
sub rsp, 8
sub rsp, 8
mov rax, qword[rcx]
mov qword[rsp + 8*2], rax
add rcx, 8
call arena_size
sub rcx, 8
mov rax, qword[rsp + 8*2]
mov qword[rcx], rax
call add
call mmap
mov rax, qword[rcx]
mov qword[rsp + 8*0], rax
add rcx, 8
sub rcx, 8
mov rax, qword[rsp + 8*0]
mov qword[rcx], rax
call arena_size
call add
mov rax, qword[rcx]
mov qword[rsp + 8*1], rax
add rcx, 8
sub rcx, 8
mov rax, qword[rsp + 8*0]
mov qword[rcx], rax
sub rcx, 8
mov qword[rcx], 0
call arena_set_used
sub rcx, 8
mov rax, qword[rsp + 8*0]
mov qword[rcx], rax
sub rcx, 8
mov rax, qword[rsp + 8*2]
mov qword[rcx], rax
call arena_set_cap
sub rcx, 8
mov rax, qword[rsp + 8*0]
mov qword[rcx], rax
sub rcx, 8
mov rax, qword[rsp + 8*1]
mov qword[rcx], rax
call arena_set_pointer
sub rcx, 8
mov rax, qword[rsp + 8*0]
mov qword[rcx], rax
mov rsp, rbp
pop rbp
ret
global arena_destroy
arena_destroy:
push rbp
mov rbp, rsp
sub rsp, 8
sub rsp, 8
mov rax, qword[rcx]
mov qword[rsp + 8*0], rax
add rcx, 8
call arena_size
sub rcx, 8
mov rax, qword[rsp + 8*0]
mov qword[rcx], rax
call arena_get_cap
call add
mov rax, qword[rcx]
mov qword[rsp + 8*1], rax
add rcx, 8
sub rcx, 8
mov rax, qword[rsp + 8*0]
mov qword[rcx], rax
sub rcx, 8
mov rax, qword[rsp + 8*1]
mov qword[rcx], rax
call munmap
mov rsp, rbp
pop rbp
ret
global arena_alloc
arena_alloc:
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
sub rsp, 8
sub rcx, 8
mov rax, qword[rsp + 8*2]
mov qword[rcx], rax
call arena_get_cap
sub rcx, 8
mov rax, qword[rsp + 8*2]
mov qword[rcx], rax
call arena_get_used
call sub
mov rax, qword[rcx]
mov qword[rsp + 8*0], rax
add rcx, 8
sub rcx, 8
mov rax, qword[rsp + 8*1]
mov qword[rcx], rax
sub rcx, 8
mov rax, qword[rsp + 8*0]
mov qword[rcx], rax
call gt
mov rax, qword[rcx]
add rcx, 8
cmp rax, 0
je .ifelse1
lea rax, STR0
sub rcx, 8
mov qword[rcx], rax
call panic
jmp .ifend1
.ifelse1:
.ifend1:
sub rsp, 8
sub rcx, 8
mov rax, qword[rsp + 8*3]
mov qword[rcx], rax
call arena_get_pointer
sub rcx, 8
mov rax, qword[rsp + 8*3]
mov qword[rcx], rax
call arena_get_used
call add
mov rax, qword[rcx]
mov qword[rsp + 8*0], rax
add rcx, 8
sub rcx, 8
mov rax, qword[rsp + 8*3]
mov qword[rcx], rax
sub rcx, 8
mov rax, qword[rsp + 8*3]
mov qword[rcx], rax
call arena_get_used
sub rcx, 8
mov rax, qword[rsp + 8*2]
mov qword[rcx], rax
call add
call arena_set_used
sub rcx, 8
mov rax, qword[rsp + 8*0]
mov qword[rcx], rax
mov rsp, rbp
pop rbp
ret
section .bss
global_arena resb 8
section .text
global global_arena_allocator_start
global_arena_allocator_start:
push rbp
mov rbp, rsp
sub rsp, 8
mov rax, qword[rcx]
mov qword[rsp + 8*0], rax
add rcx, 8
sub rcx, 8
lea rax, global_arena
mov qword[rcx], rax
sub rcx, 8
mov rax, qword[rsp + 8*0]
mov qword[rcx], rax
call arena_new
call set
sub rcx, 8
lea rax, malloc_internal
mov qword[rcx], rax
sub rcx, 8
lea rax, global_arena_malloc
mov qword[rcx], rax
call set
sub rcx, 8
lea rax, free_internal
mov qword[rcx], rax
sub rcx, 8
lea rax, global_arena_free
mov qword[rcx], rax
call set
mov rsp, rbp
pop rbp
ret
global_arena_malloc:
push rbp
mov rbp, rsp
sub rcx, 8
lea rax, global_arena
mov qword[rcx], rax
call get
call swap
call arena_alloc
mov rsp, rbp
pop rbp
ret
global_arena_free:
push rbp
mov rbp, rsp
call pop
mov rsp, rbp
pop rbp
ret
global global_arena_allocator_end
global_arena_allocator_end:
push rbp
mov rbp, rsp
sub rcx, 8
lea rax, global_arena
mov qword[rcx], rax
call get
call arena_destroy
mov rsp, rbp
pop rbp
ret
global panic
panic:
push rbp
mov rbp, rsp
lea rax, STR1
sub rcx, 8
mov qword[rcx], rax
sub rcx, 8
mov qword[rcx], 2
call write
call pop
sub rcx, 8
mov qword[rcx], 2
call write
call pop
lea rax, STR2
sub rcx, 8
mov qword[rcx], rax
sub rcx, 8
mov qword[rcx], 2
call write
call pop
sub rcx, 8
mov qword[rcx], 60
sub rcx, 8
mov qword[rcx], 1
sub rcx, 8
mov qword[rcx], 0
sub rcx, 8
mov qword[rcx], 0
call syscall
mov rsp, rbp
pop rbp
ret
global error
error:
push rbp
mov rbp, rsp
lea rax, STR3
sub rcx, 8
mov qword[rcx], rax
sub rcx, 8
mov qword[rcx], 2
call write
call pop
sub rcx, 8
mov qword[rcx], 2
call write
call pop
lea rax, STR4
sub rcx, 8
mov qword[rcx], rax
sub rcx, 8
mov qword[rcx], 2
call write
call pop
mov rsp, rbp
pop rbp
ret
global todo
todo:
push rbp
mov rbp, rsp
lea rax, STR5
sub rcx, 8
mov qword[rcx], rax
sub rcx, 8
mov qword[rcx], 2
call write
call pop
sub rcx, 8
mov qword[rcx], 2
call write
call pop
lea rax, STR6
sub rcx, 8
mov qword[rcx], rax
sub rcx, 8
mov qword[rcx], 2
call write
call pop
sub rcx, 8
mov qword[rcx], 60
sub rcx, 8
mov qword[rcx], 2
sub rcx, 8
mov qword[rcx], 0
sub rcx, 8
mov qword[rcx], 0
call syscall
mov rsp, rbp
pop rbp
ret
list_get_buffer:
mov rax, qword[rcx]
mov rbx, qword[rax + 8*0]
mov qword[rcx], rbx
ret
list_set_buffer:
mov rax, qword[rcx + 8]
mov rbx, qword[rcx]
mov qword[rax + 8*0], rbx
add rcx, 16
ret
list_get_used:
mov rax, qword[rcx]
mov rbx, qword[rax + 8*1]
mov qword[rcx], rbx
ret
list_set_used:
mov rax, qword[rcx + 8]
mov rbx, qword[rcx]
mov qword[rax + 8*1], rbx
add rcx, 16
ret
list_get_cap:
mov rax, qword[rcx]
mov rbx, qword[rax + 8*2]
mov qword[rcx], rbx
ret
list_set_cap:
mov rax, qword[rcx + 8]
mov rbx, qword[rcx]
mov qword[rax + 8*2], rbx
add rcx, 16
ret
list_get_element_size:
mov rax, qword[rcx]
mov rbx, qword[rax + 8*3]
mov qword[rcx], rbx
ret
list_set_element_size:
mov rax, qword[rcx + 8]
mov rbx, qword[rcx]
mov qword[rax + 8*3], rbx
add rcx, 16
ret
list_size:
sub rcx, 8
mov qword[rcx], 32
ret
list_at:
mov rbx, qword[rcx + 8]
mov rax, qword[rcx]
mov rdx, 32
mul rdx
add rbx, rax
add rcx, 8
mov qword[rcx], rbx
ret
global list_new
list_new:
push rbp
mov rbp, rsp
sub rsp, 8
mov rax, qword[rcx]
mov qword[rsp + 8*0], rax
add rcx, 8
sub rsp, 8
call list_size
call malloc
mov rax, qword[rcx]
mov qword[rsp + 8*0], rax
add rcx, 8
sub rsp, 8
sub rcx, 8
mov qword[rcx], 64
sub rcx, 8
mov rax, qword[rsp + 8*2]
mov qword[rcx], rax
call mul
call malloc
mov rax, qword[rcx]
mov qword[rsp + 8*0], rax
add rcx, 8
sub rcx, 8
mov rax, qword[rsp + 8*1]
mov qword[rcx], rax
sub rcx, 8
mov qword[rcx], 64
call list_set_cap
sub rcx, 8
mov rax, qword[rsp + 8*1]
mov qword[rcx], rax
sub rcx, 8
mov qword[rcx], 0
call list_set_used
sub rcx, 8
mov rax, qword[rsp + 8*1]
mov qword[rcx], rax
sub rcx, 8
mov rax, qword[rsp + 8*2]
mov qword[rcx], rax
call list_set_element_size
sub rcx, 8
mov rax, qword[rsp + 8*1]
mov qword[rcx], rax
sub rcx, 8
mov rax, qword[rsp + 8*0]
mov qword[rcx], rax
call list_set_buffer
sub rcx, 8
mov rax, qword[rsp + 8*1]
mov qword[rcx], rax
mov rsp, rbp
pop rbp
ret
global list_destroy
list_destroy:
push rbp
mov rbp, rsp
sub rsp, 8
mov rax, qword[rcx]
mov qword[rsp + 8*0], rax
add rcx, 8
sub rcx, 8
mov rax, qword[rsp + 8*0]
mov qword[rcx], rax
call list_get_buffer
call free
sub rcx, 8
mov rax, qword[rsp + 8*0]
mov qword[rcx], rax
call free
mov rsp, rbp
pop rbp
ret
global list_push_new
list_push_new:
push rbp
mov rbp, rsp
sub rsp, 8
mov rax, qword[rcx]
mov qword[rsp + 8*0], rax
add rcx, 8
sub rcx, 8
mov rax, qword[rsp + 8*0]
mov qword[rcx], rax
call list_get_used
sub rcx, 8
mov rax, qword[rsp + 8*0]
mov qword[rcx], rax
call list_get_cap
call eq
mov rax, qword[rcx]
add rcx, 8
cmp rax, 0
je .ifelse2
sub rcx, 8
mov rax, qword[rsp + 8*0]
mov qword[rcx], rax
call list_grow
jmp .ifend2
.ifelse2:
.ifend2:
sub rsp, 8
sub rcx, 8
mov rax, qword[rsp + 8*1]
mov qword[rcx], rax
call list_get_used
sub rcx, 8
mov rax, qword[rsp + 8*1]
mov qword[rcx], rax
call list_get_element_size
call mul
sub rcx, 8
mov rax, qword[rsp + 8*1]
mov qword[rcx], rax
call list_get_buffer
call add
mov rax, qword[rcx]
mov qword[rsp + 8*0], rax
add rcx, 8
sub rcx, 8
mov rax, qword[rsp + 8*1]
mov qword[rcx], rax
sub rcx, 8
mov rax, qword[rsp + 8*1]
mov qword[rcx], rax
call list_get_used
sub rcx, 8
mov qword[rcx], 1
call add
call list_set_used
sub rcx, 8
mov rax, qword[rsp + 8*0]
mov qword[rcx], rax
mov rsp, rbp
pop rbp
ret
global list_grow
list_grow:
push rbp
mov rbp, rsp
sub rsp, 8
mov rax, qword[rcx]
mov qword[rsp + 8*0], rax
add rcx, 8
sub rsp, 8
sub rcx, 8
mov rax, qword[rsp + 8*1]
mov qword[rcx], rax
call list_get_element_size
sub rcx, 8
mov rax, qword[rsp + 8*1]
mov qword[rcx], rax
call list_get_used
call mul
mov rax, qword[rcx]
mov qword[rsp + 8*0], rax
add rcx, 8
sub rcx, 8
mov rax, qword[rsp + 8*1]
mov qword[rcx], rax
sub rcx, 8
mov rax, qword[rsp + 8*1]
mov qword[rcx], rax
call list_get_cap
sub rcx, 8
mov qword[rcx], 2
call mul
call list_set_cap
sub rsp, 8
sub rcx, 8
mov rax, qword[rsp + 8*1]
mov qword[rcx], rax
sub rcx, 8
mov qword[rcx], 2
call mul
call malloc
mov rax, qword[rcx]
mov qword[rsp + 8*0], rax
add rcx, 8
sub rcx, 8
mov rax, qword[rsp + 8*0]
mov qword[rcx], rax
sub rcx, 8
mov rax, qword[rsp + 8*2]
mov qword[rcx], rax
call list_get_buffer
sub rcx, 8
mov rax, qword[rsp + 8*1]
mov qword[rcx], rax
call memcpy
sub rcx, 8
mov rax, qword[rsp + 8*2]
mov qword[rcx], rax
call list_get_buffer
call free
sub rcx, 8
mov rax, qword[rsp + 8*2]
mov qword[rcx], rax
sub rcx, 8
mov rax, qword[rsp + 8*0]
mov qword[rcx], rax
call list_set_buffer
mov rsp, rbp
pop rbp
ret
global memcpy
memcpy:
push rbp
mov rbp, rsp
sub rsp, 8
sub rsp, 8
sub rsp, 8
mov rax, qword[rcx]
mov qword[rsp + 8*0], rax
add rcx, 8
mov rax, qword[rcx]
mov qword[rsp + 8*1], rax
add rcx, 8
mov rax, qword[rcx]
mov qword[rsp + 8*2], rax
add rcx, 8
sub rsp, 8
sub rcx, 8
mov qword[rcx], 0
mov rax, qword[rcx]
mov qword[rsp + 8*0], rax
add rcx, 8
sub rsp, 8
.loop3:
sub rcx, 8
mov rax, qword[rsp + 8*1]
mov qword[rcx], rax
sub rcx, 8
mov rax, qword[rsp + 8*2]
mov qword[rcx], rax
call ge
mov rax, qword[rcx]
add rcx, 8
cmp rax, 0
je .ifelse4
jmp .break3
jmp .ifend4
.ifelse4:
.ifend4:
sub rcx, 8
mov rax, qword[rsp + 8*3]
mov qword[rcx], rax
sub rcx, 8
mov rax, qword[rsp + 8*1]
mov qword[rcx], rax
call add
call get_byte
mov rax, qword[rcx]
mov qword[rsp + 8*0], rax
add rcx, 8
sub rcx, 8
mov rax, qword[rsp + 8*4]
mov qword[rcx], rax
sub rcx, 8
mov rax, qword[rsp + 8*1]
mov qword[rcx], rax
call add
sub rcx, 8
mov rax, qword[rsp + 8*0]
mov qword[rcx], rax
call set_byte
sub rcx, 8
mov rax, qword[rsp + 8*1]
mov qword[rcx], rax
sub rcx, 8
mov qword[rcx], 1
call add
mov rax, qword[rcx]
mov qword[rsp + 8*1], rax
add rcx, 8
jmp .loop3
.break3:
mov rsp, rbp
pop rbp
ret
global list_get
list_get:
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
mov rax, qword[rsp + 8*0]
mov qword[rcx], rax
sub rcx, 8
mov rax, qword[rsp + 8*1]
mov qword[rcx], rax
call list_get_element_size
call mul
sub rcx, 8
mov rax, qword[rsp + 8*1]
mov qword[rcx], rax
call list_get_buffer
call add
mov rsp, rbp
pop rbp
ret
section .data
STR0 db `Not enough memory for arena allocation`, 0
STR1 db `\033[1;31mPANIC: `, 0
STR2 db `\033[0m\n`, 0
STR3 db `\033[1;31mERROR: `, 0
STR4 db `\033[0m\n`, 0
STR5 db `\033[1;35m`, 0
STR6 db `\033[0m\n`, 0
section .bss
STACK resq 1024

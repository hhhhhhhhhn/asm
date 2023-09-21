section .text

global add
add:
	mov rax, qword[rcx]
	add rax, qword[rcx+8]
	add rcx, 8
	mov qword[rcx], rax
	ret

global sub
sub:
	mov rax, qword[rcx+8]
	sub rax, qword[rcx]
	add rcx, 8
	mov qword[rcx], rax
	ret

global mul
mul:
	mov rax, qword[rcx]
	mov rbx, qword[rcx+8]
	mul rbx
	add rcx, 8
	mov qword[rcx], rax
	ret

global band
band:
	mov rax, qword[rcx+8]
	and rax, qword[rcx]
	add rcx, 8
	mov qword[rcx], rax
	ret

global bor
bor:
	mov rax, qword[rcx+8]
	or rax, qword[rcx]
	add rcx, 8
	mov qword[rcx], rax
	ret

global array_get
array_get:
	mov rax, qword[rcx + 8]
	mov rbx, qword[rcx]
	shl rbx, 3
	add rax, rbx
	mov rax, qword[rax]
	add rcx, 8
	mov qword[rcx], rax
	ret

global array_set
array_set:
	mov rax, qword[rcx + 16]
	mov rbx, qword[rcx + 8]
	mov rdx, qword[rcx]
	shl rbx, 3
	add rax, rbx
	mov qword[rax], rdx
	add rcx, 24
	ret

global get
get:
	mov rax, qword[rcx]
	mov rax, qword[rax]
	mov qword[rcx], rax
	ret

global set
set:
	mov rax, qword[rcx+8]
	mov rbx, qword[rcx]
	mov qword[rax], rbx
	add rcx, 16
	ret

global prints
prints:
	push rcx
	mov rax, qword[rcx]
	mov rsi, rax
	call string_len
	mov rdx, rax
	mov rax, 1 ; syscall write
	mov rdi, 1 ; stdout
	syscall

	pop rcx
	add rcx, 8
	ret

global dup
dup:
	mov rax, qword[rcx]
	sub rcx, 8
	mov qword[rcx], rax
	ret

global pop
pop:
	add rcx, 8
	ret

global swap
swap:
	mov rax, qword[rcx]
	mov rbx, qword[rcx+8]
	mov qword[rcx], rbx
	mov qword[rcx+8], rax
	ret

global rot
rot:
	mov rax, qword[rcx]
	mov rbx, qword[rcx+8]
	mov rdx, qword[rcx+16]
	mov qword[rcx], rdx
	mov qword[rcx+8], rax
	mov qword[rcx+16], rbx
	ret

global unrot
unrot:
	call rot
	call rot
	ret

global over
over:
	mov rax, qword[rcx+8]
	sub rcx, 8
	mov qword[rcx], rax
	ret

global printu
printu:
	sub rsp, 32

	mov rax, qword[rcx]
	lea rbx, [rsp]
	call write_unsigned
	mov rbx, rsp
	add rbx, rax
	mov byte[rbx], 0
	lea rax, [rsp]
	sub rcx, 8
	mov qword[rcx], rax
	call prints

	add rsp, 32
	add rcx, 8
	ret

global printi
printi:
	mov rax, qword[rcx]
	cmp rax, 0
	jge .print
	.switchsign:
		push rax
		sub rsp, 2
		mov byte[rsp], '-'
		mov byte[rsp+1], 0
		sub rcx, 8
		mov qword[rcx], rsp
		call prints
		add rcx, 8
		add rsp, 2
		pop rax
		neg rax
	.print:
	mov qword[rcx], rax
	call printu
	ret

global newline
newline:
	sub rcx, 8
	lea rax, NEWLINE
	mov qword[rcx], rax
	call prints
	ret

global eq
eq:
	mov rax, qword[rcx + 8]
	mov rbx, qword[rcx]
	add rcx, 8
	cmp rax, rbx
	je .true
	mov qword[rcx], 0
	ret
	.true:
	mov qword[rcx], 1
	ret

global ne
ne:
	mov rax, qword[rcx + 8]
	mov rbx, qword[rcx]
	add rcx, 8
	cmp rax, rbx
	jne .true
	mov qword[rcx], 0
	ret
	.true:
	mov qword[rcx], 1
	ret

global lt
lt:
	mov rax, qword[rcx + 8]
	mov rbx, qword[rcx]
	add rcx, 8
	cmp rax, rbx
	jl .true
	mov qword[rcx], 0
	ret
	.true:
	mov qword[rcx], 1
	ret

global le
le:
	mov rax, qword[rcx + 8]
	mov rbx, qword[rcx]
	add rcx, 8
	cmp rax, rbx
	jle .true
	mov qword[rcx], 0
	ret
	.true:
	mov qword[rcx], 1
	ret

global gt
gt:
	mov rax, qword[rcx + 8]
	mov rbx, qword[rcx]
	add rcx, 8
	cmp rax, rbx
	jg .true
	mov qword[rcx], 0
	ret
	.true:
	mov qword[rcx], 1
	ret

global ge
ge:
	mov rax, qword[rcx + 8]
	mov rbx, qword[rcx]
	add rcx, 8
	cmp rax, rbx
	jge .true
	mov qword[rcx], 0
	ret
	.true:
	mov qword[rcx], 1
	ret

extern STACK
global dump
dump:
	mov rbx, rcx
	.loop:
		cmp rbx, STACK + 1024*8
		jge .break
		mov rax, qword[rbx]
		call dump_rax
		add rbx, 8
		jmp .loop
	.break:
	ret

global dumplen
dumplen:
	mov rbx, rcx
	sub rbx, STACK + 1024*8
	neg rbx
	shr rbx, 3

	sub rcx, 8
	mov qword[rcx], rbx
	call printu
	call newline
	ret

global syscall
syscall:
	push rcx
	mov rax, qword[rcx + 24]
	mov rdi, qword[rcx + 16]
	mov rsi, qword[rcx + 8]
	mov rdx, qword[rcx]
	syscall
	pop rcx
	add rcx, 3*8
	mov qword[rcx], rax
	ret

global syscall7
syscall7:
	push rcx
	mov rax, qword[rcx + 48]
	mov rdi, qword[rcx + 40]
	mov rsi, qword[rcx + 32]
	mov rdx, qword[rcx + 24]
	mov r10, qword[rcx + 16]
	mov r8,  qword[rcx + 8]
	mov r9,  qword[rcx]
	syscall
	pop rcx
	add rcx, 6*8
	mov qword[rcx], rax
	ret

global call
call:
	mov rax, qword[rcx]
	add rcx, 8
	call rax
	ret

dump_rax:
	push rcx

	push rax
	call .hex_char
	call putc
	pop rax

	mov rcx, 1
	.loop:
		shl rax, 4
		push rax
		call .hex_char
		call putc
		pop rax
		inc rcx
		cmp rcx, 16
		jl .loop
	.return:
		mov al, 10
		call putc
		mov rax, 17
		pop rcx
		ret

	.hex_char:
		shr rax, 60
		cmp al, 9
		jle .number
		jmp .alpha
		.number:
			add al, '0'
			ret
		.alpha:
			sub al, 10
			add al, 'a'
			ret

write_unsigned:
	push rdx
	push rdi
	push rsi ; buffer

	mov rsi, rbx
	mov rbx, 0
	.loop:
		mov rdi, 10 ; for division
		mov rdx, 0 ; for division
		div rdi
		add rdx, '0'

		mov rdi, rsp
		sub rdi, rbx
		mov byte[rdi], dl

		inc rbx
		cmp rax, 0
		jne .loop
	.copy_buffer:
		mov rax, rbx
		dec rbx
		.buffer_loop:
			cmp rbx, 0
			jl .return

			mov rdi, rsp
			sub rdi, rbx
			mov dl, byte[rdi]
			mov byte[rsi], dl

			inc rsi
			dec rbx
			jmp .buffer_loop
	.return:
		pop rsi
		pop rdi
		pop rdx
		ret

global strlen
strlen:
	mov rax, qword[rcx]
	call string_len
	mov qword[rcx], rax
	ret

; *u8 -> u64
string_len:
	push rbx
	mov rbx, 0
	.loop:
		cmp byte[rax], 0
		je .return
		inc rbx
		inc rax
		jmp .loop
	.return:
		mov rax, rbx
		pop rbx
		ret

putc:
	push rcx
	push rdi
	push rsi
	push rdx

	mov byte[rsp-1], al
	mov rax, 1
	mov rdi, 1
	lea rsi, [rsp-1]
	mov rdx, 1
	syscall

	pop rdx
	pop rsi
	pop rdi
	pop rcx
	ret

section .data
NEWLINE db 10, 0

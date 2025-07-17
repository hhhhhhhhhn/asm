section .text

global not
not:
	mov rax, qword[rcx]
	mov rdx, 0
	cmp rax, 0
	sete dl
	mov qword[rcx], rdx
	ret

global set
set:
	mov rax, qword[rcx+8]
	mov rbx, qword[rcx]
	mov qword[rax], rbx
	add rcx, 8              ; Returns the pointer
	ret

global set_byte
set_byte:
	mov rax, qword[rcx+8]
	mov rbx, qword[rcx]
	mov byte[rax], bl
	add rcx, 8              ; Returns the pointer
	ret

global get
get:
	mov rax, qword[rcx]
	mov rax, qword[rax]
	mov qword[rcx], rax
	ret

global get_byte
get_byte:
	mov rbx, qword[rcx]
	mov rax, 0
	mov al, byte[rbx]
	mov qword[rcx], rax
	ret

global lshift
lshift:
	push rcx
	mov rax, qword[rcx+8]
	mov rcx, qword[rcx]
	shl rax, cl
	pop rcx
	add rcx, 8
	mov qword[rcx], rax
	ret

global rshift
rshift:
	push rcx
	mov rax, qword[rcx+8]
	mov rcx, qword[rcx]
	shr rax, cl
	pop rcx
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

global bxor
bxor:
	mov rax, qword[rcx+8]
	xor rax, qword[rcx]
	add rcx, 8
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
	add rcx, 8

	add rsp, 32
	;add rcx, 8 ; Return the same value
	ret

global syscall4
syscall4:
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
	; add rcx, 8 ; Return the same value
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


; DEBUG SYMBOLS
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

global newline
newline:
	sub rcx, 8
	lea rax, NEWLINE
	mov qword[rcx], rax
	call prints
	add rcx, 8
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
global true
true dq 1
global false
false dq 0

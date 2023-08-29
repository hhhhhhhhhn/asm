global _start
section .text
_start:
	lea rax, msg
	call print

	mov rax, -132
	sub rsp, 32
	lea rbx, [rsp]
	call write_signed
	mov byte[rsp + rax], 0
	lea rax, [rsp]
	call print

	mov rax, 10
	call putc

	lea rax, [rsp]
	call parse_int
	lea rbx, [rsp]
	call write_signed
	mov byte[rsp + rax], 0
	lea rax, [rsp]
	call print

	mov rax, 10
	call putc
	
	mov rdi, rax
	mov rax, 60
	syscall

; *u8 -> syscall_write_err
print:
	push rcx
	push rdi
	push rsi
	push rdx

	mov rsi, rax
	call strlen
	mov rdx, rax
	mov rax, 1 ; syscall write
	mov rdi, 1 ; stdout
	syscall

	pop rdx
	pop rsi
	pop rdi
	pop rcx
	ret

; u8 -> syscall_write_err
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

; u64 (number), *u8 (buffer) -> u64 (written)
write_hex:
	push rcx

	push rax
	call .hex_char
	mov byte[rbx], al
	pop rax

	mov rcx, 1
	.loop:
		shl rax, 4
		push rax
		call .hex_char
		mov byte[rbx + rcx], al
		pop rax
		inc rcx
		cmp rcx, 16
		jl .loop
	.return:
		mov rax, 16
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
	
; u64, *u8 -> u64
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

; i64, *u8 -> u64 (written)
write_signed:
	cmp rax, 0
	jl .invert
	jmp .write
	.invert:
		mov byte[rbx], '-'
		inc rbx
		neg rax
		call write_unsigned
		inc rax ; for the "-"
		ret
	.write:
		call write_unsigned
		ret

; *u8 -> u64/i64
parse_int:
	push rbx ; digit
	push rcx ; buffer
	push rdx ; for division
	push rdi ; for division
	push rsi ; isSigned?

	mov rsi, 0
	cmp byte[rax], '-'
	jne .nosign
	.signed:
		mov rsi, 1
		inc rax
	.nosign:

	mov rdi, 10
	mov rcx, rax
	mov rax, 0
	mov rbx, 0
	.loop:
		cmp byte[rcx], 0
		je .return

		mov bl, byte[rcx]
		sub bl, '0'

		mul rdi
		add rax, rbx
		inc rcx

		jmp .loop
	.return:
		cmp rsi, 1
		jne .noinvert
		.invert:
			neg rax
		.noinvert:
		pop rsi
		pop rdi
		pop rdx
		pop rcx
		pop rbx
		ret

; *u8 -> u64
strlen:
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

; *u8, *u8 -> bool
strcmp:
	push rcx
	.loop:
		cmp byte[rax], 0
		jne .compare
		cmp byte[rbx], 0
		jne .compare
		jmp .match
		.compare:
			mov cl, byte[rbx]
			cmp byte[rax], cl
			jne .nomatch
	.match:
		mov rax, 1
		pop rcx
		ret
	.nomatch:
		mov rax, 0
		pop rcx
		ret

; u64 -> u64
fib:
	push rbx
	push rcx

	cmp rax, 1
	jle .base
	jmp .recurse
	.recurse:
		mov rcx, rax
		sub rax, 1
		call fib
		mov rbx, rax
		mov rax, rcx
		sub rax, 2
		call fib
		add rax, rbx
		jmp .return
	.base:
		mov rax, 1
		jmp .return
	.return:
		pop rcx
		pop rbx
		ret

section .data
msg	db "Hello there", 10, 0
othermsg	db "1", 0

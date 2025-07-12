section .text

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
	;add rcx, 8 ; Return the same value
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

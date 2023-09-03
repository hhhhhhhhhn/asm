section .text

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

global print
print:
	push rcx
	mov rax, qword[rcx]
	mov rsi, rax
	call strlen
	mov rdx, rax
	mov rax, 1 ; syscall write
	mov rdi, 1 ; stdout
	syscall

	pop rcx
	add rcx, 8
	ret

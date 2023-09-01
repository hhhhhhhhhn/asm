global _start
extern print
extern read_stdin_to_buf
extern putc
extern print_rax
extern print_newline

section .text
_start:
	lea rax, BUF
	mov rbx, BUF_LEN
	call read_stdin_to_buf
	cmp rax, -1
	je panic

	lea rax, BUF
	call print

	lea rax, SEPARATOR
	call print

	call consume_num
	lea rax, LAST_TOKEN
	call print
	call print_newline

	call consume_space
	call consume_name
	lea rax, LAST_TOKEN
	call print
	call print_newline

	mov rax, 60
	mov rdi, 0
	syscall

; void -> void
; Modifies CURSOR, and sets LAST_TOKEN
consume_num:
	push rax
	push rbx

	lea rbx, LAST_TOKEN
	.loop:
		call next_char
		push rax
		call is_num_char
		cmp rax, 1
		pop rax
		jne .done

		mov byte[rbx], al
		inc rbx
		call consume_char
		jmp .loop
	.done:
	mov byte[rbx], 0
	pop rbx
	pop rax
	ret

; u8 -> 1|0 (u64)
is_num_char:
	cmp al, '0'
	jl .not_num
	cmp al, '9'
	jg .not_num
	jmp .yes_num

	.not_num:
		mov rax, 0
		ret
	.yes_num:
		mov rax, 1
		ret

; void -> void
; Modifies CURSOR, and sets LAST_TOKEN
consume_name:
	push rax
	push rbx

	lea rbx, LAST_TOKEN
	.loop:
		call next_char
		push rax
		call is_alphanum_char
		cmp rax, 1
		pop rax
		jne .done

		mov byte[rbx], al
		inc rbx
		call consume_char
		jmp .loop
	.done:
	mov byte[rbx], 0
	pop rbx
	pop rax
	ret

; void -> void
; Modifies CURSOR
consume_space:
	push rax

	.loop:
		call next_char
		push rax
		call is_space_char
		cmp rax, 1
		pop rax
		jne .done
		call consume_char
		jmp .loop
	.done:
	pop rax
	ret

consume_string_literal:
	; TODO: Implement
	ret

; u8 -> 1|0 (u64)
is_alpha_char:
	cmp al, 'a'
	jl .not_lowercase
	cmp al, 'z'
	jg .not_lowercase
	jmp .is_alpha

	.not_lowercase:
		cmp al, 'A'
		jl .not_alpha
		cmp al, 'Z'
		jg .not_alpha
		jmp .is_alpha

	.not_alpha:
		mov rax, 0
		ret
	.is_alpha:
		mov rax, 1
		ret

; u8 -> 1|0 (u64)
is_alphanum_char:
	push rax
	call is_alpha_char
	cmp rax, 1
	pop rax
	je .is
	call is_num_char
	cmp rax, 1
	je .is
	jmp .isnot

	.is:
		mov rax, 1
		ret
	.isnot:
		mov rax, 0
		ret

; u8 -> 1|0 (u64)
is_space_char:
	cmp al, ' '
	je .is
	cmp al, '\t'
	je .is
	cmp al, '\n'
	je .is
	jmp .is_not
	.is:
		mov rax, 1
		ret
	.is_not:
		mov rax, 0
		ret

; void -> u8
next_char:
	mov rax, qword[CURSOR]
	mov al, byte[rax]
	ret

; void -> void
consume_char:
	push rax
	mov rax, qword[CURSOR]
	inc rax
	mov qword[CURSOR], rax
	pop rax
	ret

panic:
	lea rax, PANICMSG
	call print
	mov rax, 60
	mov rdi, 1
	syscall

section .bss
LAST_TOKEN_LEN equ 512
LAST_TOKEN resb LAST_TOKEN_LEN
BUF_LEN equ 1024*1024
BUF resb BUF_LEN


section .data
MSG db "Hello there", 10, 0
PANICMSG db "PANIC", 10, 0
SEPARATOR db "==========================================================", 10, 0
KEYWORD_IF db "if", 0
KEYWORD_FN db "fn", 0
KEYWORD_WHILE db "while", 0
KEYWORD_END db "end", 0
CURSOR dq BUF

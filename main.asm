global _start
extern print
extern read_stdin_to_buf
extern putc
extern print_rax
extern print_newline
extern parse_int
extern strcmp
extern strcpy
extern print_unsigned

section .text
_start:
	call read_buf

	lea rax, HEADER
	call print

	call generate_until_end

	lea rax, DATA_SECTION
	call print
	call generate_strings

	; call generate_strings

	mov rax, 60
	mov rdi, 0
	syscall

; Generates until nearest "end" keyword, or EOF
; void -> void
generate_until_end:
	push rax
	.loop:
		call generate
		cmp rax, 1
		je .loop
	pop rax
	ret

; void -> 0|1 (u64, 1 for success, 0 for eof or end) (writes to stdout)
generate:
	push rax
	push rbx

	call consume_space

	call next_two_chars

	push rax
	call is_num_char
	cmp rax, 1
	pop rax
	je .num_literal

	cmp al, '-'
	jne .notminus
		push rax
		mov al, ah
		call is_num_char
		cmp rax, 1
		pop rax
		je .num_literal

	.notminus:
	push rax
	call is_alpha_char
	cmp rax, 1
	pop rax
	je .name

	cmp al, 0
	je .return_end

	cmp al, '"'
	je .string

	call panic

	.num_literal:
		call consume_num
		lea rax, PUSH_INT_START
		call print
		lea rax, LAST_TOKEN
		call print
		lea rax, PUSH_INT_END
		call print
		jmp .return_ok
	.name:
		call consume_name

		push rax
		lea rax, LAST_TOKEN
		lea rbx, KEYWORD_END
		call strcmp
		cmp rax, 1
		pop rax
		je .return_end

		lea rax, CALL_FUNCTION_START
		call print
		lea rax, LAST_TOKEN
		call print
		lea rax, CALL_FUNCTION_END
		call print
		jmp .return_ok
	.string:
		call consume_string_literal
		lea rax, LAST_TOKEN
		call push_string
		mov rbx, rax

		lea rax, PUSH_STR_START
		call print
		mov rax, rbx
		call print_unsigned

		lea rax, PUSH_STR_END
		call print

		jmp .return_ok

	.return_ok:
		pop rbx
		pop rax
		mov rax, 1
		ret
	.return_end:
		pop rbx
		pop rax
		mov rax, 0
		ret

; void -> void (prints)
generate_strings:
	push rax
	push rbx
	push rcx
	push rdx

	lea rdx, STRINGS ; pointer
	mov rbx, qword[STRINGS_USED] ; left
	mov rcx, 0 ; index

	.loop:
		cmp rbx, 0
		je .return

		lea rax, DATA_STR_START
		call print

		mov rax, rcx
		call print_unsigned

		mov rax, DATA_STR_MIDDLE
		call print

		mov rax, rcx
		call get_string
		call print

		mov rax, DATA_STR_END
		call print

		dec rbx
		inc rcx
		add rdx, 1<<STRING_LENGTH
		jmp .loop

	.return:
	pop rdx
	pop rcx
	pop rbx
	pop rax
	ret

; void -> void (can panic)
read_buf:
	push rax
	push rbx

	lea rax, BUF
	mov rbx, BUF_LEN
	call read_stdin_to_buf
	cmp rax, -1
	je panic

	pop rbx
	pop rax
	ret

; *u8 -> u64 (string index)
push_string:
	push rbx
	push rcx

	lea rbx, STRINGS
	mov rcx, qword[STRINGS_USED]
	shl	rcx, STRING_LENGTH
	add rbx, rcx

	mov rcx, rax
	mov rax, rbx
	mov rbx, rcx
	call strcpy

	mov rax, qword[STRINGS_USED]
	mov rbx, rax
	inc rbx
	mov qword[STRINGS_USED], rbx

	pop rcx
	pop rbx
	ret

; u64 (string index) -> *u8
get_string:
	push rbx

	lea rbx, STRINGS
	shl	rax, STRING_LENGTH
	add rbx, rax
	mov rax, rbx

	pop rbx
	ret

; void -> void
; Modifies CURSOR, and sets LAST_TOKEN
consume_num:
	push rax
	push rbx

	lea rbx, LAST_TOKEN

	call next_char
	cmp al, '-'
	jne .loop
	mov byte[rbx], '-'
	inc rbx
	call consume_char

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

; void -> void (modifies CURSOS, sets LAST_TOKEN)
consume_string_literal:
	push rax
	push rbx

	lea rbx, LAST_TOKEN

	call consume_char ; the '"'
	mov byte[rbx], '"'
	inc rbx

	.loop:
		call next_char
		cmp al, '"'
		je .done

		call consume_char
		mov byte[rbx], al
		inc rbx

		jmp .loop
	.done:
	call consume_char
	mov byte[rbx], '"'
	inc rbx
	mov byte[rbx], 0
	pop rbx
	pop rax
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
	cmp al, 9 ; tab
	je .is
	cmp al, 10 ; newline
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

; void -> u8 (al), u8 (ah)
next_two_chars:
	push rbx

	mov rbx, qword [CURSOR]
	mov al, byte[rbx]
	mov ah, byte[rbx+1]

	pop rbx
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

STRINGS_AMOUNT equ 1024
STRING_LENGTH equ 10
STRINGS resb (1 << STRING_LENGTH)*STRINGS_AMOUNT

section .data
MSG db "Hello there", 10, 0
PANICMSG db "PANIC", 10, 0
SEPARATOR db "==========================================================", 10, 0
KEYWORD_IF db "if", 0
KEYWORD_FN db "fn", 0
KEYWORD_WHILE db "while", 0
KEYWORD_END db "end", 0
CURSOR dq BUF
STRINGS_USED dq 0

; Code generation
PUSH_INT_START db "sub rcx, 8", 10, "mov qword[rcx], ", 0
PUSH_INT_END db 10, 0

CALL_FUNCTION_START db "call ", 0
CALL_FUNCTION_END db 10, 0

PUSH_STR_START db "lea rax, STR", 0
PUSH_STR_END db 10, "sub rcx, 8", 10, "mov qword[rcx], rax", 10, 0

DATA_SECTION db "section .data", 10, 0

HEADER db "global _start", 10, "section .text", 10, "_start:", 10, "call main", 10, "mov rax, 60", 10, "mov rdi, 0", 10, "syscall", 10, 0

DATA_STR_START db "STR", 0
DATA_STR_MIDDLE db " db ", 0
DATA_STR_END db ", 0", 10, 0

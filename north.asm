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

; If a second argument is provided, the program is built like a library
section .text
_start:
	call read_buf

	lea rax, HEADER
	call print

	cmp qword[rsp], 2
	je .islib
	lea rax, START_LABEL
	call print
	.islib:

	call generate_builtins

	call generate_until_end

	lea rax, DATA_SECTION
	call print

	call generate_strings

	lea rax, STACK
	call print

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

; void -> 0|1 (u64, 1 for success, 0 for eof, end, or else) (writes to stdout)
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

	cmp al, "'"
	je .char_literal

	cmp al, '?'
	je .var_read

	cmp al, '!'
	je .var_write

	cmp al, '&'
	je .pointer

	cmp al, '#'
	je .comment

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
	.char_literal:
		call consume_char_literal
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

		push rax
		lea rax, LAST_TOKEN
		lea rbx, KEYWORD_ELSE
		call strcmp
		cmp rax, 1
		pop rax
		je .return_end

		push rax
		lea rax, LAST_TOKEN
		lea rbx, KEYWORD_FN
		call strcmp
		cmp rax, 1
		pop rax
		je .function

		push rax
		lea rax, LAST_TOKEN
		lea rbx, KEYWORD_RETURN
		call strcmp
		cmp rax, 1
		pop rax
		je .return_keyword

		push rax
		lea rax, LAST_TOKEN
		lea rbx, KEYWORD_EXTERN
		call strcmp
		cmp rax, 1
		pop rax
		je .extern

		push rax
		lea rax, LAST_TOKEN
		lea rbx, KEYWORD_SPACE
		call strcmp
		cmp rax, 1
		pop rax
		je .space

		push rax
		lea rax, LAST_TOKEN
		lea rbx, KEYWORD_GLOBAL
		call strcmp
		cmp rax, 1
		pop rax
		je .global

		push rax
		lea rax, LAST_TOKEN
		lea rbx, KEYWORD_LOCAL
		call strcmp
		cmp rax, 1
		pop rax
		je .local

		push rax
		lea rax, LAST_TOKEN
		lea rbx, KEYWORD_IF
		call strcmp
		cmp rax, 1
		pop rax
		je .if

		push rax
		lea rax, LAST_TOKEN
		lea rbx, KEYWORD_LOOP
		call strcmp
		cmp rax, 1
		pop rax
		je .loop

		push rax
		lea rax, LAST_TOKEN
		lea rbx, KEYWORD_BREAK
		call strcmp
		cmp rax, 1
		pop rax
		je .break

		push rax
		lea rax, LAST_TOKEN
		lea rbx, KEYWORD_CONTINUE
		call strcmp
		cmp rax, 1
		pop rax
		je .continue

		push rax
		lea rax, LAST_TOKEN
		lea rbx, KEYWORD_STRUCT
		call strcmp
		cmp rax, 1
		pop rax
		je .struct

		; Just a simple call
		lea rax, CALL_FUNCTION_START
		call print
		lea rax, LAST_TOKEN
		call print
		lea rax, CALL_FUNCTION_END
		call print
		jmp .return_ok
	.function:
		call reset_locals
		call consume_space
		call consume_name
		lea rax, LAST_TOKEN
		call print
		lea rax, FUNCTION_START
		call print
		call generate_until_end
		lea rax, FUNCTION_RETURN
		call print

		jmp .return_ok
	.loop:
		mov rbx, qword[CURRENT_LOOP]
		push rbx
		call new_id
		mov qword[CURRENT_LOOP], rax
		mov rax, LOOP_HEADER_START
		call print
		mov rax, qword[CURRENT_LOOP]
		call print_unsigned
		mov rax, LOOP_HEADER_END
		call print
		mov rbx, qword[CURRENT_LOOP]

		call generate_until_end

		mov qword[CURRENT_LOOP], rbx

		lea rax, JUMP_TO_LOOP_START
		call print
		mov rax, rbx
		call print_unsigned
		lea rax, JUMP_TO_LOOP_END
		call print

		lea rax, BREAK_LABEL_START
		call print
		mov rax, rbx
		call print_unsigned
		lea rax, BREAK_LABEL_END
		call print

		pop rbx
		mov qword[CURRENT_LOOP], rbx

		jmp .return_ok
	.break:
		lea rax, BREAK_START
		call print
		mov rax, qword[CURRENT_LOOP]
		call print_unsigned
		lea rax, BREAK_END
		call print
		jmp .return_ok
	.continue:
		lea rax, JUMP_TO_LOOP_START
		call print
		mov rax, qword[CURRENT_LOOP]
		call print_unsigned
		lea rax, JUMP_TO_LOOP_END
		call print
		jmp .return_ok
	.return_keyword:
		lea rax, FUNCTION_RETURN
		call print
		jmp .return_ok
	.if:
		call new_id
		mov rbx, rax
		lea rax, CONDITIONAL_JUMP_START
		call print
		mov rax, rbx
		call print_unsigned
		lea rax, CONDITIONAL_JUMP_END
		call print

		call generate_until_end

		lea rax, JUMP_TO_IFEND_LABEL_START
		call print
		mov rax, rbx
		call print_unsigned
		lea rax, JUMP_TO_IFEND_LABEL_END
		call print

		lea rax, IFELSE_LABEL_START
		call print
		mov rax, rbx
		call print_unsigned
		lea rax, IFELSE_LABEL_END
		call print

		push rbx
		lea rax, LAST_TOKEN
		lea rbx, KEYWORD_ELSE
		call strcmp
		cmp rax, 1
		pop rbx
		jne .noelse
		.else:
			call generate_until_end
		.noelse:
		lea rax, IFEND_LABEL_START
		call print
		mov rax, rbx
		call print_unsigned
		lea rax, IFEND_LABEL_END
		call print
		jmp .return_ok
	.extern:
		lea rax, EXTERN_INSTRUCTION
		call print
		call consume_space
		call consume_name
		lea rax, LAST_TOKEN
		call print
		call print_newline
		jmp .return_ok
	.global:
		lea rax, GLOBAL_INSTRUCTION
		call print
		call consume_space
		call consume_name
		lea rax, LAST_TOKEN
		call print
		call print_newline
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
	.local:
		call consume_space
		call consume_name
		call push_local_from_last_token
		lea rax, NEW_LOCAL
		call print
		jmp .return_ok
	.var_read:
		call consume_char
		call consume_name
		lea rax, LAST_TOKEN
		call get_local_index_from_top
		cmp rax, -1
		je panic

		mov rbx, rax

		lea rax, PUSH_LOCAL_START
		call print
		mov rax, rbx
		call print_unsigned
		lea rax, PUSH_LOCAL_END
		call print

		jmp .return_ok
	.var_write:
		call consume_char
		call consume_name
		lea rax, LAST_TOKEN
		call get_local_index_from_top
		cmp rax, -1
		je panic

		mov rbx, rax

		lea rax, WRITE_LOCAL_START
		call print
		mov rax, rbx
		call print_unsigned
		lea rax, WRITE_LOCAL_END
		call print

		jmp .return_ok
	.pointer:
		call consume_char
		call consume_name ; TODO: Add support for pointer to local variable
		lea rax, GET_POINTER_START
		call print
		lea rax, LAST_TOKEN
		call print
		lea rax, GET_POINTER_END
		call print

		jmp .return_ok
	.struct:
		call consume_space
		call consume_name

		push rcx
		push rdx
		sub rsp, 128
		lea rcx, [rsp] ; struct name

		mov rax, rcx
		lea rbx, LAST_TOKEN
		call strcpy

		mov rbx, 0 ; index
		.structloop:
			call consume_space
			call consume_name
			lea rdx, LAST_TOKEN

			push rbx
			mov rax, rdx
			lea rbx, KEYWORD_END
			call strcmp
			cmp rax, 1
			pop rbx
			je .structloopend

			mov rax, rcx
			call print
			mov rax, STRUCT_READ_START
			call print
			mov rax, rdx
			call print
			mov rax, STRUCT_READ_MIDDLE
			call print
			mov rax, rbx
			call print_unsigned
			mov rax, STRUCT_READ_END
			call print

			mov rax, rcx
			call print
			mov rax, STRUCT_WRITE_START
			call print
			mov rax, rdx
			call print
			mov rax, STRUCT_WRITE_MIDDLE
			call print
			mov rax, rbx
			call print_unsigned
			mov rax, STRUCT_WRITE_END
			call print

			inc rbx
			jmp .structloop
		.structloopend:
		mov rax, rcx
		call print
		mov rax, STRUCT_SIZEOF_START
		call print
		mov rax, rbx
		shl rax, 3 ; times 8
		call print_unsigned
		lea rax, STRUCT_SIZEOF_END
		call print

		mov rax, rcx
		call print
		mov rax, STRUCT_ARRAY_GET_START
		call print
		mov rax, rbx
		shl rax, 3 ; times 8
		call print_unsigned
		lea rax, STRUCT_ARRAY_GET_END
		call print

		add rsp, 128
		pop rdx
		pop rcx
		jmp .return_ok
	.comment:
		call consume_comment
		jmp .return_ok
	.space:
		lea rax, SPACE_START
		call print

		call consume_space
		call consume_name
		lea rax, LAST_TOKEN
		call print

		lea rax, SPACE_MIDDLE
		call print

		call consume_space
		call consume_num
		lea rax, LAST_TOKEN
		call print

		lea rax, SPACE_END
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

generate_builtins:
	push rax
	push rbx
	lea rbx, BUILTINS
	.loop:
		mov al, byte[rbx]
		cmp al, 0
		je .return
		cmp al, ' '
		je .space
		jmp .normal
		.space:
			call print_newline
			lea rax, EXTERN_INSTRUCTION
			call print
			inc rbx
			jmp .loop
		.normal:
			call putc
			inc rbx
			jmp .loop
	.return:
	call print_newline
	pop rbx
	pop rax
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
consume_char_literal:
	push rax

	call next_char
	mov byte[LAST_TOKEN], al
	call consume_char

	call next_char
	mov byte[LAST_TOKEN+1], al
	call consume_char

	call next_char
	mov byte[LAST_TOKEN+2], al
	call consume_char

	mov byte[LAST_TOKEN+3], 0

	pop rax
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
		je .is_valid_char
		; TODO: Make only second char
		cmp al, '_'
		je .continue
		cmp al, 'a'
		je .is_valid_char
		cmp al, 'b'
		je .is_valid_char
		cmp al, 'c'
		je .is_valid_char
		cmp al, 'd'
		je .is_valid_char
		cmp al, 'e'
		je .is_valid_char
		cmp al, 'f'
		je .is_valid_char
		cmp al, 'x'
		je .is_valid_char
		jmp .done
		.is_valid_char:

		mov byte[rbx], al
		inc rbx
		.continue:
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

consume_comment:
	push rax
	.loop:
		call next_char
		cmp al, 10
		je .done
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
	mov byte[rbx], '`'
	inc rbx

	.loop:
		call next_two_chars
		cmp al, '"'
		je .done

		cmp al, '`'
		jne .no_backtick
		mov byte[rbx], '\'
		inc rbx

		.no_backtick:
		cmp al, '\'
		jne .no_escape
		cmp ah, '"'
		jne .no_escape
		call consume_char
		call next_char
		.no_escape:
		call consume_char
		mov byte[rbx], al
		inc rbx

		jmp .loop
	.done:
	call consume_char
	mov byte[rbx], '`'
	inc rbx
	mov byte[rbx], 0
	pop rbx
	pop rax
	ret

; NOTE: includes newline
; u8 -> 1|0 (u64)
is_alpha_char:
	cmp al, '_'
	je .is_alpha
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

; void -> void (changes LOCALS_LEN)
reset_locals:
	mov qword[LOCALS_LEN], 0
	ret

; void (reads LAST_TOKEN) -> void (changes LOCALS and LOCALS_LEN)
push_local_from_last_token:
	push rbx
	push rax

	lea rax, LOCALS
	mov rbx, qword[LOCALS_LEN]
	shl rbx, LOCAL_LENGTH
	add rax, rbx

	lea rbx, LAST_TOKEN

	call strcpy

	mov rbx, qword[LOCALS_LEN]
	inc rbx
	mov qword[LOCALS_LEN], rbx

	pop rax
	pop rbx
	ret

; *u8 (name) -> i64 (index in LOCALS or -1 if not found)
get_local_index_from_top:
	push rbx
	push rcx
	push rdx

	mov rdx, 0 ; index
	.loop:
		cmp rdx, qword[LOCALS_LEN]
		jge .return_false

		mov rcx, rdx
		shl rcx, LOCAL_LENGTH
		mov rbx, LOCALS
		add rbx, rcx

		push rax
		call strcmp
		cmp rax, 1
		pop rax
		je .return_true

		inc rdx
		jmp .loop
	.return_false:
		mov rax, -1

		pop rdx
		pop rcx
		pop rbx
		ret
	.return_true:
		mov rax, qword[LOCALS_LEN]
		sub rax, rdx
		dec rax

		pop rdx
		pop rcx
		pop rbx
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

; void -> u64
new_id:
	mov rax, qword[LAST_ID]
	inc rax
	mov qword[LAST_ID], rax
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

unimplemented:
	lea rax, UNIMPLEMENTED
	call print
	mov rax, 60
	mov rdi, 2
	syscall

section .bss
LAST_TOKEN_LEN equ 512
LAST_TOKEN resb LAST_TOKEN_LEN
BUF_LEN equ 1024*1024
BUF resb BUF_LEN

; NOTE: STRING_LENGTH and LOCAL_LENGTH indicate how big a *single* string is
; in powers of 2
STRINGS_AMOUNT equ 1024
STRING_LENGTH equ 10
STRINGS resb (1 << STRING_LENGTH)*STRINGS_AMOUNT

LOCALS_AMOUNT equ 1024
LOCAL_LENGTH equ 6
LOCALS resb (1 << STRING_LENGTH)*STRINGS_AMOUNT
LOCALS_LEN resq 1

section .data
MSG db "Hello there", 10, 0
PANICMSG db "PANIC", 10, 0
UNIMPLEMENTED db "UNIMPLEMENTED", 10, 0
SEPARATOR db "==========================================================", 10, 0
KEYWORD_IF db "if", 0
KEYWORD_FN db "fn", 0
KEYWORD_LOOP db "loop", 0
KEYWORD_END db "end", 0
KEYWORD_ELSE db "else", 0
KEYWORD_EXTERN db "extern", 0
KEYWORD_GLOBAL db "global", 0
KEYWORD_RETURN db "return", 0
KEYWORD_STRUCT db "struct", 0
KEYWORD_LOCAL db "local", 0
KEYWORD_SPACE db "space", 0
KEYWORD_BREAK db "break", 0
KEYWORD_CONTINUE db "continue", 0
CURSOR dq BUF
STRINGS_USED dq 0
LAST_ID dq 0
CURRENT_LOOP dq 0

; Code generation

; the space at the beggining is needed
BUILTINS db " dup rot unrot over pop swap prints printu printi printc newline set get array_get array_set get_byte set_byte add sub mul lt le gt ge eq ne band bor bnot not dump dumplen syscall syscall7 strlen streq call", 0

EXTERN_INSTRUCTION db "extern ", 0
GLOBAL_INSTRUCTION db "global ", 0

PUSH_INT_START db "sub rcx, 8", 10, "mov qword[rcx], ", 0
PUSH_INT_END db 10, 0

CALL_FUNCTION_START db "call ", 0
CALL_FUNCTION_END db 10, 0

PUSH_STR_START db "lea rax, STR", 0
PUSH_STR_END db 10, "sub rcx, 8", 10, "mov qword[rcx], rax", 10, 0

PUSH_LOCAL_START db "sub rcx, 8", 10, "mov rax, qword[rsp + 8*", 0
PUSH_LOCAL_END db "]", 10, "mov qword[rcx], rax", 10, 0

WRITE_LOCAL_START db "mov rax, qword[rcx]", 10, "mov qword[rsp + 8*", 0
WRITE_LOCAL_END db "], rax", 10, "add rcx, 8", 10, 0

CONDITIONAL_JUMP_START db "mov rax, qword[rcx]", 10, "add rcx, 8", 10, "cmp rax, 0", 10, "je .ifelse", 0
CONDITIONAL_JUMP_END db 10, 0

LOOP_HEADER_START db ".loop", 0
LOOP_HEADER_END db ":", 10, 0

JUMP_TO_LOOP_START db "jmp .loop", 0
JUMP_TO_LOOP_END db 10, 0

BREAK_LABEL_START db ".break", 0
BREAK_LABEL_END db ":", 10, 0

FUNCTION_START db ":", 10, "push rbp", 10, "mov rbp, rsp", 10, 0
FUNCTION_RETURN db "mov rsp, rbp", 10, "pop rbp", 10, "ret", 10, 0

BREAK_START db "jmp .break", 0
BREAK_END db 10, 0

NEW_LOCAL db "sub rsp, 8", 10, 0

STRUCT_READ_START db "_get_", 0
STRUCT_READ_MIDDLE db ":", 10, "mov rax, qword[rcx]", 10, "mov rbx, qword[rax + 8*", 0
STRUCT_READ_END db "]", 10, "mov qword[rcx], rbx", 10, "ret", 10, 0

STRUCT_WRITE_START db "_set_", 0
STRUCT_WRITE_MIDDLE db ":", 10, "mov rax, qword[rcx + 8]", 10, "mov rbx, qword[rcx]", 10, "mov qword[rax + 8*", 0
STRUCT_WRITE_END db "], rbx", 10, "add rcx, 16", 10, "ret", 10, 0

STRUCT_SIZEOF_START db "_size:", 10, "sub rcx, 8", 10, "mov qword[rcx], ", 0
STRUCT_SIZEOF_END db 10, "ret", 10, 0

STRUCT_ARRAY_GET_START db "_at:", 10, "mov rbx, qword[rcx + 8]", 10, "mov rax, qword[rcx]", 10, "mov rdx, ", 0
STRUCT_ARRAY_GET_END db 10, "mul rdx", 10, "add rbx, rax", 10, "add rcx, 8", 10, "mov qword[rcx], rbx", 10, "ret", 10, 0

JUMP_TO_IFEND_LABEL_START db "jmp .ifend", 0
JUMP_TO_IFEND_LABEL_END db 10, 0

GET_POINTER_START db "sub rcx, 8", 10, "lea rax, ", 0
GET_POINTER_END db 10, "mov qword[rcx], rax", 10, 0

IFEND_LABEL_START db ".ifend", 0
IFEND_LABEL_END db ":", 10, 0

IFELSE_LABEL_START db ".ifelse", 0
IFELSE_LABEL_END db ":", 10, 0

SPACE_START db "section .bss", 10, 0
SPACE_MIDDLE db " resb ", 0
SPACE_END db 10, "section .text", 10, 0

DATA_SECTION db "section .data", 10, 0
STACK db "section .bss", 10, "STACK resq 1024", 10, 0

HEADER db "section .text", 10, 0
START_LABEL db "global _start", 10, "global STACK", 10, "_start:", 10, "lea rcx, [STACK+1024*8]", 10, "call main", 10, "mov rax, 60", 10, "mov rdi, 0", 10, "syscall", 10, 0

DATA_STR_START db "STR", 0
DATA_STR_MIDDLE db " db ", 0
DATA_STR_END db ", 0", 10, 0

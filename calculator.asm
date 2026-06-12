; ============================================
;  Simple Calculator — x86-64 NASM (Linux)
;  Operations: Add, Subtract, Multiply, Divide
;  Compile : nasm -f elf64 calculator.asm -o calculator.o
;  Link    : ld calculator.o -o calculator
;  Run     : ./calculator
; ============================================

section .data
    prompt_num1   db  "Enter first number : ", 0
    prompt_num1_l equ $ - prompt_num1

    prompt_op     db  "Enter operator (+,-,*,/) : ", 0
    prompt_op_l   equ $ - prompt_op

    prompt_num2   db  "Enter second number: ", 0
    prompt_num2_l equ $ - prompt_num2

    msg_result    db  "Result = ", 0
    msg_result_l  equ $ - msg_result

    msg_error     db  "Error: Division by zero!", 10, 0
    msg_error_l   equ $ - msg_error

    msg_invalid   db  "Error: Invalid operator!", 10, 0
    msg_invalid_l equ $ - msg_invalid

    newline       db  10

section .bss
    buf1    resb 20     ; buffer for first number input
    buf2    resb 20     ; buffer for second number input
    op_buf  resb 4      ; buffer for operator input
    res_buf resb 25     ; buffer for result output

section .text
    global _start

; ─────────────────────────────────────────────
_start:
    ; ── Prompt for first number ──
    mov  rax, 1
    mov  rdi, 1
    mov  rsi, prompt_num1
    mov  rdx, prompt_num1_l
    syscall

    ; ── Read first number ──
    mov  rax, 0
    mov  rdi, 0
    mov  rsi, buf1
    mov  rdx, 20
    syscall

    ; ── Prompt for operator ──
    mov  rax, 1
    mov  rdi, 1
    mov  rsi, prompt_op
    mov  rdx, prompt_op_l
    syscall

    ; ── Read operator ──
    mov  rax, 0
    mov  rdi, 0
    mov  rsi, op_buf
    mov  rdx, 4
    syscall

    ; ── Prompt for second number ──
    mov  rax, 1
    mov  rdi, 1
    mov  rsi, prompt_num2
    mov  rdx, prompt_num2_l
    syscall

    ; ── Read second number ──
    mov  rax, 0
    mov  rdi, 0
    mov  rsi, buf2
    mov  rdx, 20
    syscall

    ; ── Convert buf1 string → integer → r12 ──
    mov  rsi, buf1
    call str_to_int
    mov  r12, rax       ; r12 = first number

    ; ── Convert buf2 string → integer → r13 ──
    mov  rsi, buf2
    call str_to_int
    mov  r13, rax       ; r13 = second number

    ; ── Check operator ──
    movzx rax, byte [op_buf]

    cmp  al, '+'
    je   do_add
    cmp  al, '-'
    je   do_sub
    cmp  al, '*'
    je   do_mul
    cmp  al, '/'
    je   do_div

    ; ── Invalid operator ──
    mov  rax, 1
    mov  rdi, 1
    mov  rsi, msg_invalid
    mov  rdx, msg_invalid_l
    syscall
    jmp  exit_prog

; ─────────────────────────────────────────────
do_add:
    mov  rax, r12
    add  rax, r13
    jmp  print_result

do_sub:
    mov  rax, r12
    sub  rax, r13
    jmp  print_result

do_mul:
    mov  rax, r12
    imul rax, r13
    jmp  print_result

do_div:
    ; Check for divide by zero
    cmp  r13, 0
    je   div_error

    mov  rax, r12
    cqo                 ; sign-extend rax into rdx:rax
    idiv r13            ; rax = quotient
    jmp  print_result

div_error:
    mov  rax, 1
    mov  rdi, 1
    mov  rsi, msg_error
    mov  rdx, msg_error_l
    syscall
    jmp  exit_prog

; ─────────────────────────────────────────────
print_result:
    ; rax holds the result
    ; Print "Result = "
    push rax
    mov  rax, 1
    mov  rdi, 1
    mov  rsi, msg_result
    mov  rdx, msg_result_l
    syscall
    pop  rax

    ; Convert integer in rax → string in res_buf
    mov  rdi, res_buf
    call int_to_str     ; returns length in rcx

    ; Print result string
    mov  rax, 1
    mov  rdi, 1
    mov  rsi, res_buf
    mov  rdx, rcx
    syscall

    ; Print newline
    mov  rax, 1
    mov  rdi, 1
    mov  rsi, newline
    mov  rdx, 1
    syscall

exit_prog:
    mov  rax, 60
    xor  rdi, rdi
    syscall

; ─────────────────────────────────────────────
; str_to_int: converts ASCII string at [rsi] to integer
;   Input : rsi = pointer to string
;   Output: rax = integer value
; ─────────────────────────────────────────────
str_to_int:
    xor  rax, rax       ; result = 0
    xor  rcx, rcx       ; sign flag

    ; Check for negative sign
    movzx rdx, byte [rsi]
    cmp  dl, '-'
    jne  .loop
    inc  rsi
    mov  rcx, 1         ; mark negative

.loop:
    movzx rdx, byte [rsi]
    cmp  dl, '0'
    jl   .done
    cmp  dl, '9'
    jg   .done

    sub  dl, '0'
    imul rax, rax, 10
    add  rax, rdx
    inc  rsi
    jmp  .loop

.done:
    cmp  rcx, 1
    jne  .positive
    neg  rax

.positive:
    ret

; ─────────────────────────────────────────────
; int_to_str: converts integer in rax to string
;   Input : rax = integer, rdi = output buffer
;   Output: rcx = length of string written
; ─────────────────────────────────────────────
int_to_str:
    push rbx
    push r8
    push r9

    mov  r8, rdi        ; save buffer start
    xor  rcx, rcx       ; length counter
    xor  r9, r9         ; negative flag

    ; Handle negative numbers
    cmp  rax, 0
    jge  .positive_n
    neg  rax
    mov  r9, 1
    mov  byte [rdi], '-'
    inc  rdi
    inc  rcx

.positive_n:
    ; Handle zero
    cmp  rax, 0
    jne  .convert
    mov  byte [rdi], '0'
    inc  rcx
    pop  r9
    pop  r8
    pop  rbx
    ret

.convert:
    ; Push digits onto stack (reverse order)
    xor  rbx, rbx       ; digit count

.push_loop:
    cmp  rax, 0
    je   .pop_loop
    xor  rdx, rdx
    mov  r10, 10
    div  r10            ; rax = quotient, rdx = remainder
    add  dl, '0'
    push rdx
    inc  rbx
    jmp  .push_loop

.pop_loop:
    cmp  rbx, 0
    je   .done_convert
    pop  rdx
    mov  byte [rdi], dl
    inc  rdi
    inc  rcx
    dec  rbx
    jmp  .pop_loop

.done_convert:
    pop  r9
    pop  r8
    pop  rbx
    ret

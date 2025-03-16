section .bss
    global digit_count, lower_count, upper_count, other_count
    digit_count   resq 1
    lower_count   resq 1
    upper_count   resq 1
    other_count   resq 1

section .text
global analyze_line
extern print_message, buffer

analyze_line:
    push rbp
    mov rbp, rsp

    ; Обнуляем счётчики перед каждой строкой
    mov qword [digit_count], 0
    mov qword [lower_count], 0
    mov qword [upper_count], 0
    mov qword [other_count], 0

    mov rsi, buffer  ; Указатель на начало строки

.loop:
    mov al, [rsi]
    test al, al
    jz .done         ; Конец строки -> выходим

    cmp al, '0'
    jl .check_lower
    cmp al, '9'
    jg .check_lower
    inc qword [digit_count]
    jmp .next

.check_lower:
    cmp al, 'a'
    jl .check_upper
    cmp al, 'z'
    jg .check_upper
    inc qword [lower_count]
    jmp .next

.check_upper:
    cmp al, 'A'
    jl .check_other
    cmp al, 'Z'
    jg .check_other
    inc qword [upper_count]
    jmp .next

.check_other:
    inc qword [other_count]

.next:
    inc rsi
    mov rdi, rsi
    call print_message   ; <-- Выводим каждый символ
    jmp .loop

.done:
    pop rbp
    ret

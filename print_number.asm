section .bss
    num_buffer resb 20

section .text
global print_number
extern print_message

print_number:
    push rbp
    mov rbp, rsp
    sub rsp, 32

    mov rsi, num_buffer + 19
    mov byte [rsi], 0
    dec rsi

    mov rax, rdi
    test rax, rax
    jns .convert_loop

    neg rax
    mov byte [num_buffer], '-'
    inc rsi

.convert_loop:
    mov rdx, 0
    mov rcx, 10
    div rcx
    add dl, '0'
    mov [rsi], dl
    dec rsi
    test rax, rax
    jnz .convert_loop

    inc rsi
    mov rdi, rsi
    call print_message

    add rsp, 32
    pop rbp
    ret

global msg_file_error

section .data
msg_file_error db "Ошибка: файл не найден", 0x0A, 0

section .text
global print_message
extern strlen
print_message:
    push    rbp
    mov     rbp, rsp
    push    rsi
    mov     rdi, rsi
    call    strlen
    mov     rdx, rax
    pop     rsi
    mov     rax, 1
    mov     rdi, 1
    syscall
    pop     rbp
    ret

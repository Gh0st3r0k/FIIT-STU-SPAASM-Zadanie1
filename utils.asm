global msg_file_error, msg_file_found

section .data
msg_file_error db "Ошибка: файл не найден", 0x0A, 0
msg_file_found db "Файл найден", 0x0A, 0
msg_newline db 0x0A, 0  ; Символ новой строки

section .text
global print_message, print_new_line
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


print_new_line:
    push rbp
    mov rbp, rsp
    push rsi           ; Сохраняем rsi, чтобы потом восстановить

    mov rsi, msg_newline  ; Передаём строку напрямую в rdi
    call print_message    ; Вызываем print_message для вывода "\n"

    pop rsi            ; Восстанавливаем rsi
    pop rbp
    ret

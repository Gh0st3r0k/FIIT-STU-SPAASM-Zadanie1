section .text
global _start
extern print_args, process_file, print_results
extern print_message

_start:
    pop rdi          ; argc
    mov rsi, rsp     ; argv
    call print_args  ; Разбираем аргументы

    mov rsi, msg_exit
    call print_message

    ; call process_file  ; Обрабатываем файл

    ; call print_flags  Выводим состояние флагов
    ; call print_results ; Выводим статистику строк

    mov rax, 60      ; sys_exit
    xor rdi, rdi
    syscall


section .data
    msg_exit db "Выход из main", 0x0A, 0

section .text
global _start
extern print_args, process_file, print_results

_start:
    pop rdi          ; argc
    mov rsi, rsp     ; argv
    call print_args  ; Разбираем аргументы

    call process_file  ; Обрабатываем файл

    ; call print_flags  Выводим состояние флагов
    call print_results ; Выводим статистику строк

    mov rax, 60      ; sys_exit
    xor rdi, rdi
    syscall

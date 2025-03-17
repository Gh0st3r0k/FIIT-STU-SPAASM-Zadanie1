section .text
global _start
extern print_args, print_results

_start:
    pop rdi            ; argc
    mov rsi, rsp       ; argv
    call print_args    ; Разбираем аргументы

    call print_results ; Выводим статистику строк

    mov rax, 60        ; sys_exit
    xor rdi, rdi
    syscall

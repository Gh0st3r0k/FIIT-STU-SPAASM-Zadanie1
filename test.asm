section .data
    hello db "Hello", 0x0A
    hello_len equ $ - hello

section .text
    global _start

_start:
    mov    rax, 1      ; syscall: sys_write
    mov    rdi, 1      ; stdout
    mov    rsi, hello  ; Адрес строки
    mov    rdx, hello_len  ; Длина строки
    syscall            ; Вызов sys_write

    mov    rax, 60     ; syscall: sys_exit
    xor    rdi, rdi    ; Код выхода 0
    syscall            ; Вызов sys_exit

section .data
    linebreak db 0x0A

section .text
global print_args
extern strlen

; Печатает ВСЕ «пользовательские» аргументы, кроме argv[0] (имени программы),
; и останавливается (не печатает переменные среды).
;   rdi = argc
;   rsi = argv

print_args:
    push   rbp
    mov    rbp, rsp

    mov    rcx, rdi        ; rcx := argc
    dec    rcx             ; отбрасываем argv[0] (имя программы)
    jz     .no_args        ; если после вычитания стало 0, значит аргументов нет

    mov    rbx, rsi        ; rbx указывает на argv[0]

.next_arg:
    ; Двигаемся к следующему аргументу: первый раз это argv[1]
    add    rbx, 8          ; size(pointer)=8
    mov    rax, [rbx]      ; rax := argv[i], указатель на C-строку
    cmp    rax, 0
    je     .done           ; если вдруг там 0, выходим (не лезем в envp)

    ; strlen( rdi=rax ) => длина в RAX
    mov    rdi, rax
    call   strlen
    mov    rdx, rax        ; длина строки

    ; write(1, argv[i], length)
    mov    rax, 1          ; sys_write
    mov    rdi, 1          ; stdout
    mov    rsi, [rbx]      ; строка
    syscall

    ; Печатаем перевод строки
    mov    rax, 1
    mov    rdi, 1
    mov    rsi, linebreak
    mov    rdx, 1
    syscall

    dec    rcx
    jnz    .next_arg       ; пока не вычерпали все (argc-1) аргументы

.done:
.no_args:
    mov    rsp, rbp
    pop    rbp
    ret

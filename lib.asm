section .data
    linebreak       db 0x0A            ; символ перевода строки

    msg_r_set       db "Флаг -r установлен",0x0A,0
    msg_r_not_set   db "Флаг -r не установлен",0x0A,0
    msg_h_set       db "Флаг -h установлен",0x0A,0
    msg_h_not_set   db "Флаг -h не установлен",0x0A,0
    msg_no_args     db "Аргументов нет",0x0A,0  ; Сообщение об отсутствии аргументов

    flag_r  db 0
    flag_h  db 0

section .text
global print_args
extern strlen

print_args:
    push    rbp
    mov     rbp, rsp

    mov     byte [flag_r], 0
    mov     byte [flag_h], 0

    mov     rcx, rdi         ; rcx := argc
    dec     rcx              ; отбросим argv[0] (имя программы)
    jz      .no_args         ; если 0, значит нет пользовательских аргументов

    mov     rbx, rsi         ; rbx указывает на argv[0]

.next_arg:
    add     rbx, 8           
    mov     rax, [rbx]       
    cmp     rax, 0
    je      .done            

    mov     rdi, rax         
    mov     dl, [rdi]        
    cmp     dl, '-'          
    jne     .print_filename  

    add     rdi, 1           
    mov     dl, [rdi]
    cmp     dl, 'r'
    je      .set_r_flag
    cmp     dl, 'h'
    je      .set_h_flag

    jmp     .skip_print

.set_r_flag:
    mov     byte [flag_r], 1
    jmp     .skip_print

.set_h_flag:
    mov     byte [flag_h], 1
    jmp     .skip_print

.print_filename:
    mov     rdi, rax         
    call    strlen
    mov     rdx, rax         

    mov     rax, 1           
    mov     rdi, 1           
    mov     rsi, [rbx]       
    syscall

    mov     rax, 1
    mov     rdi, 1
    mov     rsi, linebreak
    mov     rdx, 1
    syscall

.skip_print:
    dec     rcx
    jnz     .next_arg

.done:
    jmp     .print_flags

.no_args:
    mov     rsi, msg_no_args
    call    print_message
    jmp     .print_flags

.print_flags:
    mov     al, [flag_r]
    cmp     al, 0
    jne     .flag_r_is_set

    mov     rsi, msg_r_not_set
    jmp     .print_flag_res

.flag_r_is_set:
    mov     rsi, msg_r_set

.print_flag_res:
    call    print_message

    mov     al, [flag_h]
    cmp     al, 0
    jne     .flag_h_is_set

    mov     rsi, msg_h_not_set
    jmp     .print_flag_res2

.flag_h_is_set:
    mov     rsi, msg_h_set

.print_flag_res2:
    call    print_message

    mov     rsp, rbp
    pop     rbp
    ret

print_message:
    push    rsi
    mov     rdi, rsi
    call    strlen
    mov     rdx, rax
    pop     rsi
    mov     rax, 1
    mov     rdi, 1
    syscall
    ret

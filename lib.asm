section .bss
    global fd, num_line
    global digit_counts, lower_counts, upper_counts, other_counts
    global flag_r, flag_h  ; Добавляем флаги -r и -h

    fd          resq 1
    num_line    resq 1

    digit_counts resq 100
    lower_counts resq 100
    upper_counts resq 100
    other_counts resq 100

    flag_r  resb 1  ; Флаг -r
    flag_h  resb 1  ; Флаг -h

    global buffer
    buffer resb 396

section .text
global print_args, process_file, print_flags, print_results
extern print_message, print_number, analyze_line, msg_file_error
extern digit_count, lower_count, upper_count, other_count
extern strlen

print_args:
    push rbp
    mov rbp, rsp

    mov byte [flag_r], 0
    mov byte [flag_h], 0

    mov rcx, rdi   ; Количество аргументов (argc)
    dec rcx        ; Убираем имя программы
    jz .no_args    ; Если нет аргументов — вывести сообщение

    mov rbx, rsi   ; Указатель на список аргументов

.next_arg:
    add rbx, 8     ; Переходим к следующему аргументу
    mov rax, [rbx] ; Загружаем аргумент
    cmp rax, 0
    je .done       ; Если аргументов больше нет — завершаем

    mov rdi, rax
    mov dl, [rdi]
    cmp dl, '-'    ; Проверяем, является ли аргумент флагом
    jne .print_filename  ; Если нет, значит, это имя файла

    add rdi, 1
    mov dl, [rdi]
    cmp dl, 'r'
    je .set_r_flag
    cmp dl, 'h'
    je .set_h_flag
    jmp .skip_print

.set_r_flag:
    mov byte [flag_r], 1
    jmp .skip_print

.set_h_flag:
    mov byte [flag_h], 1
    jmp .skip_print

.print_filename:
    mov rdi, rax
    call strlen
    mov rdx, rax

    mov rax, 1
    mov rdi, 1
    mov rsi, [rbx]
    syscall

    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

.skip_print:
    dec rcx
    jnz .next_arg

.done:
    jmp .print_flags

.no_args:
    mov rsi, msg_no_args
    call print_message
    jmp .print_flags

.print_flags:
    mov al, [flag_r]
    cmp al, 0
    jne .flag_r_is_set

    mov rsi, msg_r_not_set
    jmp .print_flag_res

.flag_r_is_set:
    mov rsi, msg_r_set

.print_flag_res:
    call print_message

    mov al, [flag_h]
    cmp al, 0
    jne .flag_h_is_set

    mov rsi, msg_h_not_set
    jmp .print_flag_res2

.flag_h_is_set:
    mov rsi, msg_h_set

.print_flag_res2:
    call print_message

    mov rsp, rbp
    pop rbp
    ret

process_file:
    push rbp
    mov rbp, rsp
    sub rsp, 32

    mov rdi, rsi
    mov rax, 2
    mov rsi, 0
    syscall
    cmp rax, 0
    jl .file_error

    mov [fd], rax
    mov qword [num_line], 0

.read_loop:
    mov rdi, [fd]
    mov rsi, buffer
    mov rdx, 396
    mov rax, 0
    syscall
    cmp rax, 0
    jle .close_file

    mov rsi, buffer
    call analyze_line

    mov rdi, [num_line]
    mov rdx, qword [digit_count]
    mov rcx, qword [lower_count]
    mov r8,  qword [upper_count]
    mov r9,  qword [other_count]

    mov [digit_counts + rdi*8], rdx
    mov [lower_counts + rdi*8], rcx
    mov [upper_counts + rdi*8], r8
    mov [other_counts + rdi*8], r9

    inc qword [num_line]
    jmp .read_loop

.file_error:
    mov rsi, msg_file_error
    call print_message
    jmp .exit

.close_file:
    mov rdi, [fd]
    mov rax, 3
    syscall

.exit:
    add rsp, 32
    pop rbp
    ret

print_results:
    push rbp
    mov rbp, rsp
    sub rsp, 16

    mov rcx, 0

.loop:
    cmp rcx, [num_line]
    jge .done

    mov rdi, rcx
    inc rdi
    call print_number

    mov rsi, msg_digits
    call print_message
    mov rdi, [digit_counts + rcx * 8]
    call print_number

    mov rsi, msg_lower
    call print_message
    mov rdi, [lower_counts + rcx * 8]
    call print_number

    mov rsi, msg_upper
    call print_message
    mov rdi, [upper_counts + rcx * 8]
    call print_number

    mov rsi, msg_other
    call print_message
    mov rdi, [other_counts + rcx * 8]
    call print_number

    inc rcx
    jmp .loop

.done:
    add rsp, 16
    pop rbp
    ret

section .data
    newline db 0x0A
    msg_digits db " Цифры=", 0
    msg_lower  db " строчные=", 0
    msg_upper  db " заглавные=", 0
    msg_other  db " другие=", 0
    msg_r_set db "Флаг -r установлен", 0x0A, 0
    msg_r_not_set db "Флаг -r не установлен", 0x0A, 0
    msg_h_set db "Флаг -h установлен", 0x0A, 0
    msg_h_not_set db "Флаг -h не установлен", 0x0A, 0
    msg_no_args db "Аргументов нет", 0x0A, 0 

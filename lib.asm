section .bss
    global fd, num_line
    global digit_counts, lower_counts, upper_counts, other_counts
    global flag_r, flag_h  ; Флаги -r и -h

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
extern print_new_line, print_message, print_number, analyze_line, msg_file_error, msg_file_found
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
    jne .process_file  ; Если нет, значит, это имя файла

    ;mov rsi, msg_user
    ;call print_message

    add rdi, 1
    cmp byte [rdi], 'r'
    je .set_r_flag
    cmp byte [rdi], 'h'
    je .set_h_flag
    jmp .skip_print

.set_r_flag:
    mov byte [flag_r], 1
    jmp .skip_print

.set_h_flag:
    mov byte [flag_h], 1
    jmp .skip_print

.process_file:
    mov rsi, rax  ; Передаём имя файла в rsi
    call process_file  ; Обрабатываем файл
    jmp .skip_print

.done:
    jmp .print_flags

.no_args:
    mov rsi, msg_no_args
    jmp .done_flags

.skip_print:
    dec rcx
    jmp .next_arg


.print_flags:
    mov rbp, rsp   ; <-- Убираем `push rbp`, так как он уже был в `print_args`

    ; Проверяем флаг -r
    mov al, [flag_r]
    cmp al, 0
    jne .flag_r_is_set
    mov rsi, msg_r_not_set
    jmp .print_flag_res

.flag_r_is_set:
    mov rsi, msg_r_set

.print_flag_res:
    call print_message

    ; Проверяем флаг -h (только один раз!)
    mov al, [flag_h]
    cmp al, 0
    jne .flag_h_is_set
    mov rsi, msg_h_not_set
    jmp .done_flags

.flag_h_is_set:
    mov rsi, msg_h_set

.done_flags:
    call print_message

    mov rsi, msg_end
    call print_message

    pop rbp   ; <-- ЧЁТКО ВОССТАНАВЛИВАЕМ СТЕК
    ret       ; <-- ТЕПЕРЬ НЕ УПАДЁТ


process_file:
    push rbp
    mov rbp, rsp
    sub rsp, 32

    ; Выводим имя файла перед открытием (ОТЛАДКА)
    mov rdi, rsi
    call print_message
    call print_new_line
    ;mov rsi, msg_newline
    ;call print_message
    ;mov rsi, rdi

    ; Открываем файл на чтение
    mov rdi, rsi  ; Имя файла уже в rsi
    mov rax, 2    ; sys_open
    mov rsi, 0    ; Только для чтения
    syscall

    ; Проверяем, открылся ли файл
    cmp rax, 0
    jl .file_error  ; Если ошибка, вывести сообщение

    mov [fd], rax
    jmp .success

.file_error:
    mov rsi, msg_error_code
    call print_message
    mov rdi, rax  ; Код ошибки
    call print_number  ; Выведем его
    mov rsi, msg_file_error
    call print_message
    jmp .exit

.success:
    mov rsi, msg_file_found
    call print_message  ; Выводим "Файл найден"

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
    msg_error_code db "Код ошибки: ", 0
    msg_end db "Завершение print_flags", 0x0A, 0
    msg_newline db 0x0A, 0
    msg_user db "Золотая чаша, золотааааааяяяяя", 0x0A, 0
    msg_line_num db "Номер строки: ", 0
    msg_colon db ": ", 0

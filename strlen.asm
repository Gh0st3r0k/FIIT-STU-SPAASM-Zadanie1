section .text
    global strlen

strlen:
    xor   rax, rax  ; Обнуляем rax
    test  rdi, rdi  ; Проверяем, не 0 ли rdi
    jz    .done     ; Если 0 — сразу выходим
.loop:
    cmp   byte [rdi], 0  ; Конец строки?
    je    .done
    inc   rdi       ; Двигаем указатель вперёд
    inc   rax       ; Увеличиваем счётчик
    jmp   .loop
.done:
    ret

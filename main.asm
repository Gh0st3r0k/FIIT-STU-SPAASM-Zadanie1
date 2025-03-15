section .text
global _start
extern print_args   ; print_args будет определена в другом файле (lib.asm)

; Входная точка (т.к. мы линкуем без стандартных библиотек):
; По соглашению Linux при запуске процесса в стеке лежат:
;   [ argc | argv[0] | argv[1] | ... | argv[argc-1] | 0 | envp[0] ... ]
; Первая pop снимает argc, в rsi кладём указатель на argv[0].
; Затем вызываем print_args(rdi=argc, rsi=argv).

_start:
    ; Забираем argc
    pop rdi
    ; Указатель на argv
    mov rsi, rsp

    call print_args

    ; Выходим через sys_exit(0)
    mov rax, 60       ; номер системного вызова exit
    xor rdi, rdi      ; код возврата = 0
    syscall

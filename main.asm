; Program entry point: parse arguments, print statistics, and exit.
; Author: Kostiantyn Zaitsev (AIS 123101) | FIIT STU, SPAASM, 2024/2025.
; Build instructions and usage examples are in README.md.

section .text
global _start       ; Entry point of the program
extern parse_args, print_results  ; External procedures (lib.asm)

_start:
    pop rdi     ; Get argc (argument count)
    mov rsi, rsp    ; Get argv (pointer to arguments array)
    call parse_args ; Parse arguments, open and process file

    call print_results  ; display per-line and total
; character stats

; Exit the program using sys_exit
    mov rax, 60     ; System call number for sys_exit
    xor rdi, rdi    ; Exit code = 0
    syscall

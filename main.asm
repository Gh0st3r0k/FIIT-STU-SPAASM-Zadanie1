;<=============================================================>;
; Assignment #1							;
; Author: Kostiantyn Zaitsev, AIS ID: 123101			;
; 								;
; Task: Display the counts of digits, lowercase letters, 	;
;	uppercase letters, and other characters for each line 	;
;	and for the entire input.				;
; Submission deadline: 21.03.2025				;
; Academic year: 2024/2025, Summer semester			;
;---------------------------------------------------------------;
;								;
; Environment:							;
;   - Developed and tested on Linux x86_64, NASM assembler	;
;   - Terminal-based input/output				;
;								;
; Assumptions & Limitations:					;
;   - Lines are separated by LF ('\n')				;
;   - No Unicode support (ASCII only)				;
;   - Invalid file encoding may cause incorrect results		;
;								;
; Implemented Flags:						;
;   -h : display help						;
;   -r : reverse line order					;
;   -p : paginated output (10 lines per page)			;
;								;
; Compilation:							;
;   nasm -f elf64 main.asm -o main.o				;
;   nasm -f elf64 lib.asm -o lib.o				;
;   nasm -f elf64 data.asm -o data.o				;
;   nasm -f elf64 utils.asm -o utils.o				;
;   nasm -f elf64 strlen.asm -o strlen.o			;
;   nasm -f elf64 analyze_line.asm -o analyze_line.o		;
;   nasm -f elf64 print_number.asm -o print_number.o 		;
;   ld main.o lib.o data.o analyze_line.o utils.o strlen.o 	;
;	print_number.o -o program				;
;								;
; Running (Example):						;
; ./program -h							;
; ./program testFile.txt -r -p					;
; ./program -p testFile1.txt -r testFile2.txt			;
;								;
;								;
; Project Files:                                                ;
; - main.asm           : Entry point, calls argument parser     ;
; - lib.asm            : Core logic: parse_args, process_file   ;
; - data.asm           : All strings and global constants       ;
; - utils.asm          : Utility functions for output           ;
; - strlen.asm         : Calculates length of a string          ;
; - analyze_line.asm   : Analyzes one line of text              ;
; - print_number.asm   : Converts and prints integer as string  ;
; - macros.inc         : Macros for formatted output		;
;								;
;								;
; Technical Limitations:					;
; - Maximum number of lines in all files: 4096			;
; - Maximum length of a single line: 4095 (+ 1 -> '\n')		;
;<=============================================================>;



section .text
global _start		; Entry point of the program
extern parse_args, print_results  ; External procedures (lib.asm)

_start:
    pop rdi		; Get argc (argument count)
    mov rsi, rsp	; Get argv (pointer to arguments array)
    call parse_args	; Parse arguments, open and process file

    call print_results	; display per-line and total
    			;			character stats

    ; Exit the program using sys_exit
    mov rax, 60		; System call number for sys_exit
    xor rdi, rdi	; Exit code = 0
    syscall

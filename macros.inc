; Formatting macros used by the statistics output routines.

%macro PRINT_MSG 1
    push rcx        ; Save rcx (will be changed
; in print_message)
    mov rsi, %1     ; Pointer to a string in rsi
    call print_message  ; Printing a line
    pop rcx     ; Restoring the rcx
%endmacro

; Macro: PRINT_NUM
; Description:
; Prints a number using the print_number function
; Automatically saves and restores rcx
; Parameters:
; %1 - value (can be in memory or a register)

%macro PRINT_NUM 1
    push rcx        ; Save rcx (will be changed
; in print_number)
    mov rdi, %1     ; The number is put in rdi
    call print_number   ; Print a number
    pop rcx     ; Restoring the rcx
%endmacro


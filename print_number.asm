;<=============================================================>;
;								;
;		      Function: print_number			;
;								;
;								;
; Description: Converts a number (from rdi) to string and	;
;						     prints it.	;
;								;
;   Supports negative numbers.					;
;   Uses num_buffer to build the string, then prints it.	;
;								;
;<=============================================================>;

section .bss
    num_buffer resb 20		; Buffer to store number as 
    				; string(up to 19 digits + null)

section .text
global print_number		; Export symbol for linking 
					;    with other modules
extern print_message		; Import from utils.asm

print_number:
    push rbp			; Save previous base pointer
    mov rbp, rsp		; Set up current base pointer
    sub rsp, 32			; Allocate some space on
    					;	     the stack

    ; Set the pointer to the end of the buffer
    mov rsi, num_buffer + 19
    mov byte [rsi], 0		; Null-terminator
    dec rsi			; Moving on to the position
    					;     for the last digit

    mov rax, rdi		; Copy number into rax
    test rax, rax		; rax == 0?
    jns .convert_loop		; Yes? -> to conversion

    ; If the number is negative:
    neg rax			; Make it positive
    mov byte [num_buffer], '-'	; Set '-' at start of buffer
    inc rsi			; Avoid overwriting '-'

.convert_loop:
    mov rdx, 0			; Clear RDX because DIV uses
    					; 128-bit RDX:RAX / RCX
                		  ; Uninitialized RDX would cause
				      ; incorrect result or crash

    mov rcx, 10			; Divide by 10
    div rcx			; rax / 10 → rax = quotient,
    					;	rdx = remainder
    add dl, '0'			; Convert digit to ASCII
    mov [rsi], dl		; Writing to the buffer
    dec rsi			; Move back in buffer
    test rax, rax		; rax == 0?
    jnz .convert_loop		; No? -> repeat

    inc rsi			; rsi points to start of string
    mov rdi, rsi		; Set argument for print_message
    call print_message		; Print the string

    add rsp, 32			; Free 32 bytes of stack 
    					;space reserved earlier
    pop rbp			; Restore base pointer
    ret				; Return to caller

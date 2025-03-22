;<=============================================================>;
;								;
;			File: utils.asm				;
;								;
;								;
; Description:							;
;   Utility functions for output:				;
;   - print_message: print null-terminated string		;
;   - print_new_line: print newline character			;
;								;
;<=============================================================>;


section .data
    msg_newline db 0x0A, 0	; New line character (LF)

section .text
global print_message, print_new_line	; Exporting functions
extern strlen			; Use the external function 
					; strlen (strlen.asm)


;<=============================================================>;
;								;
;		      Function: print_message			;
;								;
;								;
; Description:							;
;   Prints null-terminated string from RSI using write syscall.	;
;   Input: RSI = pointer to string				;
;								;
;<=============================================================>;

print_message:
    push    rbp			; Save previous base pointer
    mov     rbp, rsp		; Set up current base pointer

    push    rsi			; Save RSI, because we will 
    					;	   call strlen
    mov     rdi, rsi		; Copy pointer to RDI for strlen
    call    strlen		; Get string length -> RAX

    mov     rdx, rax		; Number of bytes to output
    pop     rsi			; Restore RSI (string pointer)

    mov     rax, 1		; sys_write - system call
    					;	for writing
    mov     rdi, 1		; descriptor 1 = standard
    					;	output (stdout)
    syscall			; execute system call: 
    					; write(stdout, rsi, rdx)

    pop     rbp			; Restore base pointer
    ret				; Return to caller









;<=============================================================>;
;								;
;		     Function: print_new_line			;
;								;
;								;
; Description:							;
;   Outputs a newline character ("\n")				;
;   Uses print_message to output the msg_newline		;
;								;
;<=============================================================>;


print_new_line:
    push rbp			; Save previous base pointer
    mov rbp, rsp		; Set up current base pointer
    push rsi			; Save rsi

    mov rsi, msg_newline  	; Pass the string directly
    						;	to rdi
    call print_message    	; Call print_message to
    						;  output "\n"

    pop rsi			; Restore rsi
    pop rbp			; Restore base pointer
    ret				; Return to caller

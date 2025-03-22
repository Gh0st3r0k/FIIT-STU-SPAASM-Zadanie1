;<=============================================================>;
;								;
;			Function: strlen			;
;								;
;								;
; Description:							;
;   Calculates length of a null-terminated string.		;
;								;
;   Input: RDI = pointer to string				;
;   Output: RAX = string length					;
;								;
;<=============================================================>;


section .text
    global strlen		; Exporting the strlen function
    					;	for other files

strlen:
    xor   rax, rax  		; Clear length counter
    test  rdi, rdi  		; rdi == 0?
    jz    .done     		; Yes? -> return 0

.loop:
    cmp   byte [rdi], 0		; End of string?
    je    .done			; Yes? -> exit
    inc   rdi			; Move to next char
    inc   rax			; Increment counter
    jmp   .loop			; Repeat

.done:
    ret				; Return length in RAX

;<=============================================================>;
;								;
;		   Function: analyze_line			;
;								;
;								;
; Description: Analyze 1 line and determine the number of 	;
;	digits, lowercase, capital letters, and other 		;
;						characters.	;
;								;
; The results are saved to global variables:			;
;	digit_count, lower_count, upper_count, other_count	;
;								;
;<=============================================================>;


section .bss

    ; Create global variables
    global digit_count, lower_count, upper_count, other_count
    
    digit_count   resq 1	; Digit counter
    lower_count   resq 1	; Lowercase counter
    upper_count   resq 1	; Uppercase counter
    other_count   resq 1	; Other chars counter

section .text
global analyze_line		; Export function for 
					;	external modules

analyze_line:
    push rbp			; Save previous base pointer
    mov rbp, rsp		; Set up current base pointer

    ; Reset all counters to 0 before processing the line
    mov qword [digit_count], 0
    mov qword [lower_count], 0
    mov qword [upper_count], 0
    mov qword [other_count], 0

.loop:
    mov al, [rsi]		; Load current char
    test al, al			; al is 0 (end of line)?
    jz .done         		; Yes? -> exit


    ; Check if digit
    cmp al, '0'			; '0' <= al?
    jl .check_lower		; No? -> check if it's a 
    					;	small letter
    cmp al, '9'			; Yes? -> al <= '9'?
    jg .check_lower		; No? -> check if it's a 
    					;	small letter
    inc qword [digit_count]	; Yes? -> +1 in digit_count
    jmp .next			; Go to the next character on
    					;	the current line


.check_lower:			; Check if lowercase
    cmp al, 'a'			; 'a' <= al?
    jl .check_upper		; No? -> check if it's a 
    					;	capital letter
    cmp al, 'z'			; al <= 'z'?
    jg .check_upper		; No? -> check if it's a
                                        ;       capital letter
    inc qword [lower_count]	; Yes? -> +1 in lower_count
    jmp .next			; Go to the next character on
                                        ;       the current line


.check_upper:			; Check if uppercase
    cmp al, 'A'			; 'A' <= al
    jl .check_other		; No? -> it`s other character
    cmp al, 'Z'			; al <= 'Z'
    jg .check_other		; No? -> it`s other character
    inc qword [upper_count]	; Yes? -> +1 in upper_count
    jmp .next			; Go to the next character on
                                        ;       the current line


.check_other:
    inc qword [other_count]	; Everything else is other
    					;	      characters


.next:
    inc rsi			; Move to next char
    jmp .loop			; Loop back to analyze

.done:
    pop rbp			; Restore base pointer
    ret				; Return to caller

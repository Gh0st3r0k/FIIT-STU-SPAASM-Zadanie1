;<=============================================================>;
;								;
;			File: lib.asm				;
;								;
;								;
; Description:							;
;   Core logic of the program:					;
;   - Argument parsing (parse_args)				;
;   - File processing (process_file)				;
;   - Results printing (print_results, show_total)		;
;								;
;<=============================================================>;



;----------------- SECTION: Uninitialized Data -----------------;

section .bss

    fd          resq 1		; File descriptor

    ; Total counters across all lines
    total_digits resq 1
    total_lower  resq 1
    total_upper  resq 1
    total_other  resq 1

    ; Per-line counts (arrays)
    digit_counts resq 4096
    lower_counts resq 4096
    upper_counts resq 4096
    other_counts resq 4096

    ; Flags from command line
    flag_h  resb 1              ; -h : help
    flag_r  resb 1		; -r : reverse order
    flag_p  resb 1		; -p : pagination

    buffer resb 4096		; Buffer for reading file




;----------------------- SECTION: Code -------------------------;

section .text
%include "macros.inc"


;---------- Externals: Data ----------;

extern msg_help, msg_no_args		; from data.asm
extern msg_error_code, msg_file_error	; from data.asm
extern msg_line_num, msg_digits		; from data.asm
extern msg_lower, msg_upper, msg_other	; from data.asm
extern msg_total, msg_press_enter	; from data.asm
extern num_line				; from data.asm

extern digit_count, lower_count		; from analyze_line.asm
extern upper_count, other_count		; from analyze_line.asm

;---------- Externaks: Function ----------;

extern print_message, print_new_line	; from utils.asm
extern print_number			; from print_number
extern analyze_line			; from analyze_line.asm


;---------- Global ----------;

global parse_args, print_results	; Exporting functions








;<=============================================================>;
;								;
;			Function: parse_args			;
;								;
;								;
; Description:							;
;   Parses command-line arguments and sets global flags.	;
;   Calls `process_file` if a filename is found.		;
;   Shows help and exits if '-h' is specified.			;
;								;
; Input:							;
;   rdi = argc							;
;   rsi = argv							;
;								;
;<=============================================================>;

parse_args:

    push rbp			; Save previous base pointer
    mov rbp, rsp		; Set up current base pointer

    ; Initialising flags to 0
    mov byte [flag_r], 0
    mov byte [flag_p], 0

    mov rcx, rdi		; Copy argument count (argc)
    						;	to RCX
    dec rcx        		; Skip program name
    jz .no_args			; If no arguments - print
    					;     a warning message

    mov rbx, rsi		; Copy pointer to argv
    						; array into RBX


.next_arg:

    add rbx, 8			; Move on to the next argument
    mov rax, [rbx]		; Load the argument
    cmp rax, 0			; rax == NULL (end of args)?
    je .done_flags       	; Yes? -> exit

    mov rdi, rax		; Copy pointer to string into RDI
    mov dl, [rdi]		; Load first character
    						; of the argument
    cmp dl, '-'			; Check if the argument is a flag
    jne .process_file		; No? -> this is filename


    ; Checking which flag it is
    add rdi, 1			; Move to second character
    					;     (actual flag char)
    cmp byte [rdi], 'r'		; Is it '-r'?
    je .set_r_flag		; Yes? -> set global r flag
    cmp byte [rdi], 'h'		; Is it '-h'?
    je .h_flag			; Yes? -> help message
    cmp byte [rdi], 'p'		; Is it '-p'?
    je .set_p_flag		; Yes? -> set global p flag
    jmp .skip_flag		; No? -> skip it

.set_r_flag:
    mov byte [flag_r], 1	; Enable reverse output
    jmp .skip_flag		; Move to next argument

.h_flag:
    mov byte [flag_h], 1	; Enable help output
    jmp .help_message		; Move to help message

.set_p_flag:
    mov byte [flag_p], 1	; Enable pagination
    jmp .skip_flag		; Move to next argument

.process_file:
    mov rsi, rax		; Pass filename to rsi
    call process_file		; Processing the file
    jmp .skip_flag		; Move to next argument

.help_message:
    PRINT_MSG msg_help		; Display help message
    mov rax, 60			; sys_exit
    xor rdi, rdi		; exit code = 0
    syscall			; Terminate program

.no_args:
    PRINT_MSG msg_no_args	; Print "No arguments"
    jmp .done_flags		; exit

.skip_flag:
    dec rcx			; Decrement remaining arguments
    jmp .next_arg		; Move to next argument


.done_flags:
    
    pop rbp			; Restore base pointer
    ret				; Return to caller











;<=============================================================>;
;								;
;			Function: process_file			;
;								;
;								;
; Description:							;
;   Opens and reads the file, analyzes each line,		;
;   and stores per-line and total statistics.			;
;   Calls `analyze_line` on each line.				;
;								;
; Input:							;
;   rsi = pointer to filename					;
;								;
;<=============================================================>;

process_file:

    push rbp			; Save previous base pointer
    mov rbp, rsp		; Set up current base pointer
    sub rsp, 16			; Allocate 16 bytes of the stack

    ; Open the file for reading
    mov rdi, rsi		; Copy the file name to rdi
    mov rax, 2			; syscall: sys_open
    mov rsi, 0			; Opening mode: read-only
    						;    (O_RDONLY)
    syscall			; call
    				;   sys_open(filename, O_RDONLY)


    ; Check if the file is open
    cmp rax, 0			; rax < 0?
    jl .file_error		; Yes? -> error

    mov [fd], rax		; Save the file descriptor
    					;  in a global variable
    jmp .success		; Move to a reading cycle



.file_error:
    
    PRINT_MSG msg_error_code	; Print "Error: "
    PRINT_NUM rax		; Print error code (from rax)
    
    call print_new_line		; New line
    
    PRINT_MSG msg_file_error	; Print "file not found"

    add rsp, 16			; Releasing the stack
    pop rbp			; Restore base pointer
    jmp .exit			; Exit


.success:
    push rbx			; Save the rbx register (we will
    				; use it as a pointer to the
				; beginning of the string)
    

.read_loop:

    ; Read from file to buffer
    mov rdi, [fd]		; First argument: file descriptor
    mov rsi, buffer		; Second argument: read buffer
    mov rdx, 4096		; Third argument: how many bytes
    							; to read
    mov rax, 0			; sys_read
    syscall			; read: read(fd, buffer, 4096)
    cmp rax, 0			; rax > 0?
    jle .close_file		; No? -> exit

    mov rsi, buffer		; rsi - current char (pointer)
    mov rbx, rsi		; rbx = start of line


.next_char:

    mov al, [rsi]		; Load the current char
    cmp al, 0			; al == 0?
    je .done_processing		; Yes? -> buffer end, exit

    cmp al, 10			; al == 10 ('\n')?
    je .process_line		; Yes? -> process a string

    inc rsi			; No? -> forward on the buffer
    jmp .next_char		; Repeat


.process_line:

    push rsi			; Save the current pointer
    mov byte [rsi], 0		; Replace '\n' by 0 (end of line)

    mov rsi, rbx		; rbx - pointer to start of line
    call analyze_line		; Call analysis of the 
    						; current string

    mov rdi, [num_line]		  ; Get the current line number
    mov rdx, qword [digit_count]  ; Number of digits per line
    mov rcx, qword [lower_count]  ; Number of lowercase letters
    mov r8,  qword [upper_count]  ; Number of capital letters
    mov r9,  qword [other_count]  ; Number of other chars

    ; Save by index for the string
    mov [digit_counts + rdi*8], rdx
    mov [lower_counts + rdi*8], rcx
    mov [upper_counts + rdi*8], r8
    mov [other_counts + rdi*8], r9

    ; Updating the summary statistics
    add [total_digits], rdx
    add [total_lower], rcx
    add [total_upper], r8
    add [total_other], r9

    inc qword [num_line]	; Increase the line number
    pop rsi			; Restore the pointer


.next_line:
    
    inc rsi			; Moving forward
    cmp byte [rsi], 0		; 'rsi' == '\0'?
    je .next_line		; Yes? -> repeat

    test rsi, rsi		; rsi == 0?
    jz .done_processing		; Yes? -> file end

    mov rbx, rsi		; Updating the beginning of 
    						; a new line
    jmp .next_char		; Go to the next line


.done_processing:
    jmp .read_loop		; Read the following
    						; piece of data


.close_file:
    mov rdi, [fd]		; File descriptor
    mov rax, 3			; sys_close
    syscall			; Close the file

.exit:
    pop rbx			; Restore the saved register
    leave			; Simplified equivalent:
    						; mov rsp,
						; rbp → pop rbp
    ret				; Return to caller














;<=============================================================>;
;								;
;			Function: print_results			;
;								;
;								;
; Description:							;
;   Displays per-line statistics for all lines,			;
;   in normal or reverse order depending on flag_r.		;
;   If flag_p is set, paginates output (10 lines per screen).	;
;   Then calls show_total.					;
;								;
;<=============================================================>;

print_results:

    push rbp			; Save previous base pointer
    mov rbp, rsp		; Set up current base pointer
    sub rsp, 16			; Allocate 16 bytes of the stack

    mov r8, 0			; r8 will be used as a line
    				; count on the current page 
						;     (for -p)


    cmp byte [flag_h], 1	; 'flag_h' == 1?
    je .done			; Yes? -> skip prints

    cmp byte [flag_r], 1	; 'flag_r' == 1?
    je .reverse_order		; Yes? -> revers print

.forward_order:			; No? -> forward print
    mov rcx, 0			; rcx will be the current
    				  ; line number (index in
				  ; statistics arrays)


.forward_loop:

    ; Check if the number of rows is not exceeded
    cmp rcx, [num_line]		; rcx >= num_line?
    jge .forward_done		; Yes? -> finished output

    PRINT_MSG msg_line_num	; Print "Line number #"
    mov rdi, rcx
    inc rdi			; Increase by 1 (so that row #1,
    							; not #0)
    PRINT_NUM rdi		; Print line number


    ; Print the number of digits
    PRINT_MSG msg_digits
    PRINT_NUM [digit_counts + rcx * 8]


    ; Printing of lowercase letters
    PRINT_MSG msg_lower
    PRINT_NUM [lower_counts + rcx * 8]


    ; Printing of capital letters
    PRINT_MSG msg_upper
    PRINT_NUM [upper_counts + rcx * 8]


    ; Print the remaining characters
    PRINT_MSG msg_other
    PRINT_NUM [other_counts + rcx * 8]

    
    push rcx			; Save to avoid losing
    						; the rcx data
    call print_new_line		; Move to a new line
    pop rcx			; Return rcx value

    inc rcx			; Move to the next line
    inc r8			; Increase the line count
    					;    per page (for -p)


    cmp byte [flag_p], 1	; 'flag_p' == 1?
    jne .forward_loop		; No? -> skip checking

    
    ; Check if the number of lines in one page is not exceeded

    cmp rcx, [num_line]		; rcx >= num_line?
    jge .forward_done           ; Yes? -> finished output

    ; Are there 10 lines printed?
    cmp r8, 10			; r8 == 10?
    jne .forward_loop		; No? -> continue to output
    						;    the lines

    PRINT_MSG msg_press_enter	; Message to user: press Enter

    push rcx			; Save loop index (rcx)
    						; before syscall
    mov rax, 0			; syscall: sys_read
    mov rdi, 0			; file descriptor: stdin
    mov rsi, buffer		; buffer to store 1 char
    mov rdx, 1			; read 1 byte
    syscall			; wait for user input
    pop rcx			; Restore loop index
    						; after syscall

    mov r8, 0			; Reset the line count
    						; on a new page

    jmp .forward_loop		; Move to continue output


.forward_done:

    call show_total		; Output total statistics 
    						; for all rows
    jmp .done			; Exit

.reverse_order:

    call show_total		; First, we also display the
    			    		  ;    summary statistics
    call print_new_line		; Print new line
    mov rcx, [num_line]		; Set the index to the last line
    dec rcx			; Since the lines are counted
    				  ; from 0 → 
				  ; last line = num_line - 1

.reverse_loop:

    ; If we've reached the beginning, we're done
    cmp rcx, -1			; rcx <= -1?
    jle .done			; Yes? -> finished output


    PRINT_MSG msg_line_num      ; Print "Line number #"
    mov rdi, rcx
    inc rdi                     ; Increase by 1 (so that row #1,
                                                        ; not #0)
    PRINT_NUM rdi               ; Print line number


    ; Print the number of digits
    PRINT_MSG msg_digits
    PRINT_NUM [digit_counts + rcx * 8]


    ; Printing of lowercase letters
    PRINT_MSG msg_lower
    PRINT_NUM [lower_counts + rcx * 8]


    ; Printing of capital letters
    PRINT_MSG msg_upper
    PRINT_NUM [upper_counts + rcx * 8]


    ; Print the remaining characters
    PRINT_MSG msg_other
    PRINT_NUM [other_counts + rcx * 8]


    push rcx                    ; Save to avoid losing
                                                ; the rcx data
    call print_new_line         ; Move to a new line
    pop rcx                     ; Return rcx value

    dec rcx                     ; Move to the next line
    inc r8                      ; Increase the line count
                                        ;    per page (for -p)


    cmp byte [flag_p], 1        ; 'flag_p' == 1?
    jne .reverse_loop           ; No? -> skip checking

     ; Check if the number of lines in one page is not exceeded

    cmp rcx, -1         	; rcx <= -1?
    jle .done			; Yes? -> finished output

    ; Are there 10 lines printed?
    cmp r8, 10                  ; r8 == 10?
    jne .reverse_loop           ; No? -> continue to output
                                                ;    the lines

    PRINT_MSG msg_press_enter   ; Message to user: press Enter

    push rcx                    ; Save loop index (rcx)
                                                ; before syscall
    mov rax, 0                  ; syscall: sys_read
    mov rdi, 0                  ; file descriptor: stdin
    mov rsi, buffer             ; buffer to store 1 char
    mov rdx, 1                  ; read 1 byte
    syscall                     ; wait for user input
    pop rcx                     ; Restore loop index
                                                ; after syscall

    mov r8, 0                   ; Reset the line count
                                                ; on a new page

    jmp .reverse_loop           ; Move to continue output


.done:
    add rsp, 16			; Clear the stack
    pop rbp			; Restore base pointer
    ret				; Return to caller










;<=============================================================>;
;								;
;			Function: show_total			;
;								;
;								;
; Description:							;
;   Displays the total number of digits, lowercase,		;
;   uppercase, and other characters across all lines.		;
;								;
;<=============================================================>;

show_total:

    call print_new_line		; Output an empty line before
    					; the summary statistics
    
    PRINT_MSG msg_total		; Print:
    				    ; 'Total across all lines'
    
    ; Print the total number of digits in all lines
    PRINT_MSG msg_digits
    PRINT_NUM [total_digits]

    ; Total number of lowercase letters
    PRINT_MSG msg_lower
    PRINT_NUM [total_lower]

    ; Total number of capital letters
    PRINT_MSG msg_upper
    PRINT_NUM [total_upper]

    ; Total number of other characters
    PRINT_MSG msg_other
    PRINT_NUM [total_other]

    call print_new_line		; New line after the final block

    ret				; Return to caller

;<=============================================================>;
;								;
;			  File data.asm				;
;								;
;								;
; Description:							;
;   Allocated initialised memory from code logic		;
;								;
;<=============================================================>;


section .data

;<--------------------------------------------------------------;
;			  Error messages			;
;---------------------------------------------------------------;

    global msg_no_args, msg_error_code, msg_file_error

    msg_no_args db "No arguments", 0x0A, 0
    msg_error_code db "Error: ", 0
    msg_file_error db "Error: file not found", 0x0A, 0



;---------------------------------------------------------------;
;		Statistics on rows and total output		;
;---------------------------------------------------------------;

    global msg_total, msg_line_num
    global msg_digits, msg_lower
    global msg_upper, msg_other
    
    msg_total db "Total across all lines", 0
    msg_line_num db "Line number #", 0

    msg_digits db ": Digits = ", 0
    msg_lower  db ", small letters = ", 0
    msg_upper  db ", capital letters = ", 0
    msg_other  db ", other = ", 0



;---------------------------------------------------------------;
;			Page output - pause			;
;---------------------------------------------------------------;

    global msg_press_enter
    
    msg_press_enter db "Press Enter to continue...", 0x0A, 0



;---------------------------------------------------------------;
;		     Help (output with -h flag)			;
;---------------------------------------------------------------;

    global msg_help

    msg_help db "Run: program [flags] file.txt [flags]", 0x0A
         db "-r  : Output in reverse order", 0x0A
         db "-p  : Page output (10 lines each)", 0x0A
         db "-h  : Help", 0x0A, 0



;---------------------------------------------------------------;
;		       Line counter (global)			;
;---------------------------------------------------------------;

    global num_line

    num_line dq 0

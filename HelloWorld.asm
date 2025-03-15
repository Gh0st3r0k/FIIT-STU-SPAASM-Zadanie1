section .data
    msg db "Hello, world!", 0
    caption db "Message", 0

section .text
    global main
    extern MessageBoxA
    extern ExitProcess

main:
    sub rsp, 40            ; Windows ABI: выделить место для вызова
    mov rcx, 0             ; hWnd = NULL
    mov rdx, msg           ; LPCTSTR lpText
    mov r8, caption        ; LPCTSTR lpCaption
    mov r9, 0              ; uType = MB_OK
    call MessageBoxA

    mov ecx, 0             ; Exit code 0
    call ExitProcess

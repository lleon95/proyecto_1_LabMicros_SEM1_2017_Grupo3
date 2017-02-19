%include "io64.inc"

section .data
    regist TIMES 32 dd 0

section .text
    global CMAIN
    
CMAIN:
    mov rbp, rsp; for correct debugging
    ;write your code here
    mov rax, 0x15
    mov [regist], rax
    mov rdx, regist
    add rdx, 124
    mov eax, 0x30
    mov [rdx], eax
    mov r8, [regist]
    add rdx, 4
    ; Prueba de suma signada
    mov eax, 20
    mov ebx, -10
    add eax, ebx
    ret
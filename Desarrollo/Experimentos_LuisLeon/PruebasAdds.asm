%include "io64.inc"

section .data
    registers TIMES 32 dd 0
    temp dq 0
section .text
global CMAIN
CMAIN:
    mov rbp, rsp; for correct debugging
    ;write your code here
    mov r10, -1
    mov r11, 128
    mov r8, registers
ins_Add:
	;call llamadas_aritmeticas_log
        mov eax, r10d
        add eax, r11d
        ; Ambos positivos
        cmp r10d, 0
        jge ins_Add_r11positivo
        ; Ambos negativos
        jl ins_Add_r11negativo
        ins_Add_r11positivo:
            cmp r11d, 0
            jge ins_Add_respositivo
            jmp ins_Add_ret
        ins_Add_r11negativo:
            cmp r11d, 0
            jl ins_Add_resnegativo
            jmp ins_Add_ret
        ins_Add_respositivo:
            cmp eax, 0
            jle overflow
            jmp ins_Add_ret
        ins_Add_resnegativo:
            cmp eax, 0
            jge overflow
  
        ins_Add_ret: 
            mov [r8], eax; write back
            

ins_Addu: ;Hay que corregir
	;call llamadas_aritmeticas_log
        add r10d, r11d
	mov [r8], r10d; write back
	ret 

overflow:
        mov r8, -1
        ret
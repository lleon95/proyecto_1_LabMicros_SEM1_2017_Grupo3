%include "io64.inc"

%macro impr_texto 2 	;recibe 2 parametros
	mov rax,1	;sys_write
	mov rdi,1	;std_out
	mov rsi,%1	;primer parametro: Texto
	mov rdx,%2	;segundo parametro: Tamano texto
	syscall
	
	;mov rax,1	;sys_write
;	mov rdi,[result_fd]	;std_out
;	mov rsi,%1	;primer parametro: Texto
;	mov rdx,%2	;segundo parametro: Tamano texto
;	syscall

%endmacro

%macro impr_decimal 1
	mov r8,%1
	mov r9,0
;impr_texto text_Sv0,len_Sv0
%%_resta:
	cmp r8,10
	jge %%dism10
cmp r9,0
jne %%impr_r9

%%impr_r8:
	add r8,48
        mov [modelo],r8
	impr_texto modelo,1
        jmp %%fin


%%impr_r9:
	add r9,48
        mov [modelo],r9
	impr_texto modelo,1
	jmp %%impr_r8

%%dism10:
	sub r8,10
	add r9,1
	jmp %%_resta
%%fin:	
%endmacro

%macro impr_registro 1
        mov r14,%1
	mov r8,r14
	shr r8,24
	impr_inmediato r8
	mov r8,r14
	shr r8,16
	and r8,0xff
	impr_inmediato r8
	mov r8,r14
	shr r8,8
	and r8,0xff
	impr_inmediato r8
	mov r8,%1	
	and r8,0xff
	impr_inmediato r8
%endmacro

%macro impr_inmediato 1
	impr_numero %1
	mov [modelo],r9
	mov [modelo+1],r8
	impr_texto modelo,2
%endmacro

%macro impr_numero 1
    mov r8, %1
    mov r9,r8
    and r8,0xf
    shr r9,4
    cmp r8,10
    jge %%sumar8
 %%ret1:
    cmp r9,10
    jge %%sumar9
 %%ret2:
    add r8,48
    add r9,48
    jmp %%end
    
  %%sumar8:
    add r8,7
    jmp %%ret1
  %%sumar9:
    add r9,7
    jmp %%ret2  
   
  %%end:
%endmacro

inmediato:
        mov r12,12
	mov r8,r12
	mov r14,r12
	shr r8,8
	impr_inmediato r8 ;macro de inmediato
	and r14,0xff
	impr_inmediato r14	
	ret

imprimir_Imm:
    
    call inmediato
	jmp termina

section .text
global CMAIN
CMAIN:
    mov rbp, rsp; for correct debugging
    mov r10,4
    ;mov [modelo],r10
   ;impr_texto modelo,1;
  impr_decimal r10;
;   impr_texto r8,1
;   impr_texto r9,1
;   mov [modelo],r9
;    mov [modelo+1],r8
;    impr_texto modelo,2
termina:
        mov rax,60						; Salir del sistema sys_exit
	mov rdi,0
	syscall

section .bss
  modelo resd  8
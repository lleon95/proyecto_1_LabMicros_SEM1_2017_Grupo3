;%include "io64.inc"
;MAXARGS     equ     5 ; 1 = program path 2 = 1st arg  3 = 2nd arg etc... 
;sys_exit    equ     1
sys_read    equ     0
sys_write   equ     1
stdin       equ     0
stdout      equ     1
;stderr      equ     3

%macro htb 1
    mov r9,28
    mov r10,0
    mov r11,0

 %%extraer:
    mov rcx,r11
    mov r8, %1
    shr r8,cl
    shr r8,cl
    and r8,0xff

    cmp r8,47
    jle %%argerror
    cmp r8,71
    jge %%argerror
    cmp r8,58
    jge %%letras

 %%retletras:
    sub r8, 48
    mov rcx,r9
    sub rcx,r11
    shl r8,cl
    or  r10,r8


    cmp r11, 28
    je %%endhtb
    add r11,4
    jmp %%extraer 

 %%letras:
    cmp r8, 64
    jle %%argerror
    sub r8, 7
    jmp %%retletras


 %%argerror:
    impr_texto const_argerror_txt,const_argerror_size
    impr_texto newline, 1
    jmp %%endhtb

  %%endhtb:
%endmacro



%macro bth 1
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
    jmp %%endbth
    
  %%sumar8:
    add r8,7
    jmp %%ret1
  %%sumar9:
    add r9,7
    jmp %%ret2  
   
  %%endbth:
%endmacro

%macro impr_texto 2
    mov rax,1
    mov rdi,1
    mov rsi,%1 ;texto
    mov rdx,%2 ;len
    syscall
%endmacro


%macro impr_registro 1
        mov r12,%1
    mov r8,r12
    shr r8,24
    impr_inmediato r8
    mov r8,r12
    shr r8,16
    and r8,0xff
    impr_inmediato r8
    mov r8,r12
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

section .data
	const_argerror_txt: db 'Error de argumento. ', 0xa
	const_argerror_size: equ $-const_argerror_txt

section .bss 
   modelo           resd  8  ; reservar 8 bytes


section .text

global      _start
newline db 0x0a

_start:
   

    push    rbp
    mov     rbp, rsp
    
    cmp     dword[rbp + 8], 1
    je      NoArgs                           ; no args entered
     
    
    mov     rbx, [rbp + 24]
    mov     rbx, [rbx]
    ;mov     r12, [rbp + 32]
    ;mov     r13, [rbp + 40]
    ;mov     r14, [rbp + 48]
    
    htb rbx
    mov rbx,r10

    ;htb r12
    ;mov r12,r10

    ;htb r13
    ;mov r13,r10

    ;htb r14
    ;mov r14,r10

    impr_registro rbx
    





    impr_texto newline, 1
    jmp Exit

    
NoArgs:
   mov rbx, 0
   mov r12, 0
   mov r13, 0
   mov r14, 0
   jmp     Exit

;DisplayNorm:
    ;push    rbx
;    mov     rax, sys_write
;    mov     rdi, stdout
;    syscall  
    ;pop     rbx
;    ret
    


Exit:
    mov     rsp, rbp
    pop     rbp
    
	mov rax,60	;system call number (sys_exit)
	mov rdi,0	;exit status 0 (if not used is 1 as set before) "echo $?" to check
	syscall	    ;system exit

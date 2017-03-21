;%include "io64.inc"

sys_read    equ     0   ;Codigo de lladas al sistema
sys_write   equ     1
stdin       equ     0
stdout      equ     1


%macro htb 1    ;Macro para pasar hexadecimal en ascii a hexadecimal en binario
    mov r9,28   ;Definir constante 28 en registro auxiliar para los shift
    mov r10,0   ;Inicializar registro de resultado final
    mov r11,0   ;Inicializar registro auxiliar de contador

 %%extraer:         ;Proceso de extraccion de 8 bits (ascii)
    mov rcx,r11     ;Copiar valor de registro auxiliar 
    mov r8, %1      ;Copiar registro de entrada 
    shr r8,cl       ;Correr a la derecha 2 veces el valor del contador para tener 8 bits de LSBs
    shr r8,cl     
    and r8,0xff     ;Mascara para asegurar solo 8 bits

    cmp r8,47       ;Si el codigo ascii es menor a 47 reportar error
    jle %%argerror  
    cmp r8,71       ;Si el codigo ascii es mayor a 71 reportar error
    jge %%argerror
    cmp r8,58       ;Si el codigo ascii es mayor a 58 probablente sea una letra o sea un error
    jge %%letras

 %%retletras:
    sub r8, 48      ;Se resta 48 al codigo ascii para pasarlo a binario
    mov rcx,r9      ;El contador se pone en 28
    sub rcx,r11     ;Se le resta el registro auxiliar al contador para hacer el corrimiento correcto
    shl r8,cl       ;Se realiza el corrimiento respectivo para agregar 4 bits en la posicion correcta
    or  r10,r8      ;Se agregan 4 bits al resultado final


    cmp r11, 28     ;Se compara el registro auxiliar del contador para ver si ya termino la extraccion
    je %%endhtb     ;Termina el loop
    add r11,4       ;Se suman 4 al registro auxiliar del contador
    jmp %%extraer   ;Inicia otro ciclo

 %%letras:          
    cmp r8, 64      ;Si el codigo ascii es menor a 64 reportar error
    jle %%argerror
    sub r8, 7       ;Si no, es una letra y necesita un corrimiento de 7
    jmp %%retletras


 %%argerror:        ;Impresion de Error
    impr_texto const_argerror_txt,const_argerror_size   
    impr_texto newline, 1
    jmp %%endhtb

  %%endhtb:
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
	const_argerror_txt: db 'Error de argumento. ', 0xa ;String de Error
	const_argerror_size: equ $-const_argerror_txt      ;Tamano del string

section .bss 
   modelo           resd  8  ; reservar 8 bytes

section .text

global      _start
newline db 0x0a

_start:
   

    push    rbp         ;Empujar rbp al stack
    mov     rbp, rsp    ;Asignar la direccion de rsp al rbp
    
    cmp     dword[rbp + 8], 1   ;Revisar si hay argumentos
    je      NoArgs              
     
    
    mov     rbx, [rbp + 24]     ;Mover la direccion de los argumentos a los registros de resultados
    mov     rbx, [rbx]          ;Mover el contenido de los argumentos a los resgistros de resultados
    mov     r12, [rbp + 32]
    mov     r12, [r12]
    mov     r13, [rbp + 40]
    mov     r13, [r13]
    mov     r14, [rbp + 48]
    mov     r14, [r14]
    
    htb rbx             ;Llamar a la funcion htb para obtener hexadecimal en binario de cada uno de los argumentos
    mov rbx,r10

    htb r12
    mov r12,r10

    htb r13
    mov r13,r10

    htb r14
    mov r14,r10

    impr_registro rbx   ;Imprimir los resultados para comprobar
    impr_texto newline, 1

    impr_registro r12
    impr_texto newline, 1

    impr_registro r13
    impr_texto newline, 1

    impr_registro r14
    impr_texto newline, 1
    jmp Exit

NoArgs:                     ;Si no hay argumentos, poner registros en 0
   mov rbx, 0
   mov r12, 0
   mov r13, 0
   mov r14, 0
   jmp     Exit


Exit:
    mov     rsp, rbp        ;Sacar rbp del stack
    pop     rbp
    
	mov rax,60	;system call number (sys_exit)
	mov rdi,0	;exit status 0 (if not used is 1 as set before) "echo $?" to check
	syscall	    ;system exit

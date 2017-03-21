;%include "io64.inc"
%define SYS_READ 0
%define SYS_OPEN 2
%define SYS_WRITE 1
%define SYS_CLOSE 3
%define STDOUT 1
%define BUFFER_SIZE 1

;################################################-----MACROS-----############################################################
%macro limpiar_pantalla 2 	;recibe 2 parametros
	mov rax,1	;sys_write
	mov rdi,1	;std_out
	mov rsi,%1	;primer parametro: caracteres especiales para limpiar la pantalla
	mov rdx,%2	;segundo parametro: Tamano 
	syscall
%endmacro

%macro impr_shell 2	;Recibe 2 parametros
	mov rax,1	;sys_write
	mov rdi,1	;std_out
	mov rsi,%1	;Texto
	mov rdx,%2	;Longitud de texto
	syscall
%endmacro

%macro impr_texto 2 	;recibe 2 parametros
	mov rax,1	;sys_write
	mov rdi,1	;std_out
	mov rsi,%1	;primer parametro: Texto
	mov rdx,%2	;segundo parametro: Tamano texto
	syscall

	mov rax,1	;sys_write
	mov rdi,[result_fd]	;std_out
	mov rsi,%1	;primer parametro: Texto
	mov rdx,%2	;segundo parametro: Tamano texto
	syscall

%endmacro

%macro tecla_get 1 
	mov rax,0	;sys_read
	mov rdi,0	; 
	mov rsi,%1	;primer parámetro: Texto(enter)
	mov rdx,1	;segundo parámetro: Tamano texto
	syscall
%endmacro

%macro impr_numero 1  ;prepara un numero de 2 bytes en hexadecimal para ser impresos en ascii
    mov r8, %1     ;carga el dato de entrada en un registro
    mov r9,r8	;copia el dato entrante en otro registro
    and r8,0xf	;toma los bits mas bajos de dato entrante
    shr r9,4	;toma los bits mas altos del dato que entro
    cmp r8,10	;compara si el dato es mayor a 10
    jge %%sumar8 ;si el dato es mayor a 10 hay que sumarle 7 para poder imprimir letras
 %%ret1:
    cmp r9,10	;compara si la parte alta del dato es mayor a 10
    jge %%sumar9 ;si la parte alta del dato es mayor a 10 hay que sumarle 7 para poder imprimir letras
 %%ret2:
    add r8,48 ;convierte la parte baja del dato de entrada en ascii
    add r9,48 ;convierte la parte alta del dato de entrada en ascii
    jmp %%end ;termina el macro
    
  %%sumar8:
    add r8,7  ;suma 7 para poder imprimir una letra
    jmp %%ret1
  %%sumar9:
    add r9,7  ;suma 7 para poder imprimir una letra
    jmp %%ret2  
   
  %%end:
%endmacro

%macro impr_inmediato 1 ;imprime el dato que entra en ascii, imprime solo datos de 8 bits
	impr_numero %1 ;prepara el dato y lo separa en su parte alta y baja transformada en ascii
	mov [modelo],r9 ;copia la parte alta en un arreglo
	mov [modelo+1],r8 ;copia la parte baja en un arreglo 
	impr_texto modelo,2 ;imprime el arreglo
%endmacro

%macro impr_registro 1 ;este macro puede imprimir datos de 32 bits
        mov r12,%1  ;carga el dato de entrada en un registro
	mov r8,r12  ;copia el dato de entrada en un registro
	shr r8,24   ;toma la parte alta del registro de 32 bits
	impr_inmediato r8 ;imprime los 8 bits mas  altos del dato que ingresa
	mov r8,r12  ;copia el dato de entrada en un registro
	shr r8,16   ;toma la segunda mitad del dato de entrada
	and r8,0xff ;toma 8 bits del dato de entrada, de 16 al 23
	impr_inmediato r8 ;imprime los 8 bits del dato de entada, del 16 al 23 
	mov r8,r12  ;copia el dato de entrada en un registro
	shr r8,8    ;toma los bits del 8 al 31 del dato de entrada
	and r8,0xff ;deja solo los bits de 8 al 15 del dato de entrada
	impr_inmediato r8 ;imprime los 8 bits del dato de entada, del 8 al 15
	mov r8,%1  ;copia el dato de entrada en un registro
	and r8,0xff ;toma los 8 bits mas bajos del dato de entrada
	impr_inmediato r8 ;imprime los 8 bits mas bajos del dato de entrada

%endmacro


%macro impr_decimal 1 ;imprime el dato de entrada en decimal, solo puede imprimir del 0 al 99
	mov r8,%1  ;copia el dato de entrada en un registro
	mov r9,0   ;inicializa en cero un registro
%%_resta:
	cmp r8,10  ;comprueba si el dato es menor que 10
	jge %%dism10 ;si el dato es mayor que 10 se le resta una decena
cmp r9,0  ;comprueba si hay que imprimir la decena
jne %%impr_r9  ;imprime la decena

%%impr_r8:
	add r8,48 ;convierte el dato en ascii
        mov [modelo],r8 ;carga el dato convertido en ascii en un arreglo
	impr_texto modelo,1  ;imprime la unidad del dato de entrada
        jmp %%fin ;termina el macro


%%impr_r9:
	add r9,48 ;convierte el dato en ascii
        mov [modelo],r9 ;carga el dato convertido en ascii en un arreglo
	impr_texto modelo,1  ;imprime la decena del dato de entrada
	jmp %%impr_r8 ;despues de imprimir la decena procede a imprimir la unidad

%%dism10:
	sub r8,10  ;resta una decena al dato que entra
	add r9,1   ;aumenta en una unidad el dato contador de decena
	jmp %%_resta ;vuelve al ciclo para comprobar si el dato el mayor que 10
%%fin:	
%endmacro

%macro carga 1
	mov r14,registers
	mov r13,%1
	mov r10,r13
	shl r10,3
	add r14,r10
%endmacro

;#################--------Seccion de comparacion de Rd-------------------#########################
imprimir_Rd: ;Identificacion de registro destino, para impresion
	cmp r12,2
	je Rd_v0
	cmp r12,3
	je Rd_v1
	cmp r12,4
	je Rd_a0
	cmp r12,5
	je Rd_a1
	cmp r12,6
	je Rd_a2
	cmp r12,7
	je Rd_a3
	cmp r12,16
	je Rd_s0
	cmp r12,17
	je Rd_s1
	cmp r12,18
	je Rd_s2
	cmp r12,19
	je Rd_s3
	cmp r12,20
	je Rd_s4
	cmp r12,0x25
	je Rd_s5
	cmp r12,22
	je Rd_s6
	cmp r12,23
	je Rd_s7
	cmp r12,29
	je Rd_sp   
    impr_texto text_error_Rd, len_error_Rd ;Si el registro en la instruccion no existe en el emulador, error
	jmp Pantalla_salida_error

Rd_v0:
	impr_texto text_Sv0,len_Sv0
	jmp siguiente_Rd
Rd_v1:
	impr_texto text_Sv1,len_Sv1
	jmp siguiente_Rd
Rd_a0:
	impr_texto text_Sa0,len_Sa0
	jmp siguiente_Rd
Rd_a1:
	impr_texto text_Sa1,len_Sa1
	jmp siguiente_Rd
Rd_a2:
	impr_texto text_Sa2,len_Sa2
	jmp siguiente_Rd
Rd_a3:
	impr_texto text_Sa3,len_Sa3
	jmp siguiente_Rd
Rd_s0:
	impr_texto text_Ss0,len_Ss0
	jmp siguiente_Rd
Rd_s1:
	impr_texto text_Ss1,len_Ss1
	jmp siguiente_Rd
Rd_s2:
	impr_texto text_Ss2,len_Ss2
	jmp siguiente_Rd
Rd_s3:
	impr_texto text_Ss3,len_Ss3
	jmp siguiente_Rd
Rd_s4:
	impr_texto text_Ss4,len_Ss4
	jmp siguiente_Rd
Rd_s5:
	impr_texto text_Ss5,len_Ss5
	jmp siguiente_Rd
Rd_s6:
	impr_texto text_Ss6,len_Ss6
	jmp siguiente_Rd
Rd_s7:
	impr_texto text_Ss7,len_Ss7
	jmp siguiente_Rd
Rd_sp:
	impr_texto text_Ssp,len_Ssp
	jmp siguiente_Rd	

siguiente_Rd:
        cmp r9,0
        je imprimir_Rt
        cmp r9,2
        je imprimir_Rt
        jmp imprimir_Rs

;#################seccion de compracion de Rs
imprimir_Rs:
    mov r11,rbx    
    cmp r11,0
    je Rs_zero
	cmp r11,2
	je Rs_v0
	cmp r11,3d
	je Rs_v1
	cmp r11,4
	je Rs_a0
	cmp r11,5
	je Rs_a1
        cmp r11,6
	je Rs_a2
	cmp r11,7
	je Rs_a3
	cmp r11,16
	je Rs_s0
	cmp r11,17
	je Rs_s1
	cmp r11,18
	je Rs_s2
	cmp r11,19
	je Rs_s3
	cmp r11,20
	je Rs_s4
	cmp r11,21
	je Rs_s5
	cmp r11,22
	je Rs_s6
	cmp r11,23
	je Rs_s7
	cmp r11,29
	je Rs_sp
    impr_texto text_error_Rs, len_error_Rs
	jmp Pantalla_salida_error

siguiente_Rs:
	cmp r8,0
	je imprimir_Rt
	cmp r8,4
	je imprimir_Rt
	cmp r8,5
	je imprimir_Rt
	jmp imprimir_Imm
	
Rs_zero:
	impr_texto text_Szero,len_Szero
	jmp siguiente_Rs
Rs_v0:
	impr_texto text_Sv0,len_Sv0
	jmp siguiente_Rs
Rs_v1:
	impr_texto text_Sv1,len_Sv1
	jmp siguiente_Rs
Rs_a0:
	impr_texto text_Sa0,len_Sa0
	jmp siguiente_Rs
Rs_a1:
	impr_texto text_Sa1,len_Sa1
	jmp siguiente_Rs
Rs_a2:
	impr_texto text_Sa2,len_Sa2
	jmp siguiente_Rs
Rs_a3:
	impr_texto text_Sa3,len_Sa3
	jmp siguiente_Rs
Rs_s0:
	impr_texto text_Ss0,len_Ss0
	jmp siguiente_Rs
Rs_s1:
	impr_texto text_Ss1,len_Ss1
	jmp siguiente_Rs
Rs_s2:
	impr_texto text_Ss2,len_Ss2
	jmp siguiente_Rs
Rs_s3:
	impr_texto text_Ss3,len_Ss3
	jmp siguiente_Rs
Rs_s4:
	impr_texto text_Ss4,len_Ss4
	jmp siguiente_Rs
Rs_s5:
	impr_texto text_Ss5,len_Ss5
	jmp siguiente_Rs
Rs_s6:
	impr_texto text_Ss6,len_Ss6
	jmp siguiente_Rs
Rs_s7:
	impr_texto text_Ss7,len_Ss7
	jmp siguiente_Rs
Rs_sp:
	impr_texto text_Ssp,len_Ssp
	jmp siguiente_Rs

	;#################seccion de compracion de Rt
imprimir_Rt:
	cmp r10,0
	je Rt_zero
	cmp r10,2
	je Rt_v0
	cmp r10,3
	je Rt_v1
	cmp r10,4
	je Rt_a0
	cmp r10,5
	je Rt_a1
	cmp r10,6
	je Rt_a2
	cmp r10,7
	je Rt_a3
	cmp r10,16
	je Rt_s0
	cmp r10,17
	je Rt_s1
	cmp r10,18
	je Rt_s2
	cmp r10,19
	je Rt_s3
	cmp r10,20
	je Rt_s4
	cmp r10,21
	je Rt_s5
	cmp r10,22
	je Rt_s6
	cmp r10,23
	je Rt_s7
	cmp r10,29
	je Rt_sp
    impr_texto text_error_Rt, len_error_Rt
	jmp Pantalla_salida_error

siguiente_Rt:
        cmp r8,0
	je Verif_R
        	cmp r8,4
	je imprimir_Imm
	cmp r8,5
	je imprimir_Imm
	jmp imprimir_Rs

Verif_R:
        cmp r9,0
	je imprimir_Imm
	cmp r9,2
	je imprimir_Imm
        jmp termina

Rt_zero:
	impr_texto text_Szero, len_Szero
	jmp siguiente_Rt
Rt_v0:
	impr_texto text_Sv0,len_Sv0
	jmp siguiente_Rt
Rt_v1:
	impr_texto text_Sv1,len_Sv1
	jmp siguiente_Rt
Rt_a0:
	impr_texto text_Sa0,len_Sa0
	jmp siguiente_Rt
Rt_a1:
	impr_texto text_Sa1,len_Sa1
	jmp siguiente_Rt
Rt_a2:
	impr_texto text_Sa2,len_Sa2
	jmp siguiente_Rt
Rt_a3:
	impr_texto text_Sa3,len_Sa3
	jmp siguiente_Rt
Rt_s0:
	impr_texto text_Ss0,len_Ss0
	jmp siguiente_Rt
Rt_s1:
	impr_texto text_Ss1,len_Ss1
	jmp siguiente_Rt
Rt_s2:
	impr_texto text_Ss2,len_Ss2
	jmp siguiente_Rt
Rt_s3:
	impr_texto text_Ss3,len_Ss3
	jmp siguiente_Rt
Rt_s4:
	impr_texto text_Ss4,len_Ss4
	jmp siguiente_Rt
Rt_s5:
	impr_texto text_Ss5,len_Ss5
	jmp siguiente_Rt
Rt_s6:
	impr_texto text_Ss6,len_Ss6
	jmp siguiente_Rt
Rt_s7:
	impr_texto text_Ss7,len_Ss7
	jmp siguiente_Rt
Rt_sp:
	impr_texto text_Ssp,len_Ssp
	jmp siguiente_Rt
	
;################## Seccion de imprimir Immediato
;inmediato:
imprimir_Imm:
	mov r8,r14
	mov r13,r14
	shr r8,8
	impr_inmediato r8 ;macro de inmediato
	and r13,0xff
	impr_inmediato r13	
;	ret
        jmp termina

;imprimir_Imm:
;    call inmediato
;	jmp termina

;################## Seccion de llamadas a variables
siguiente_variable:
	cmp r8,0
	je imprimir_Rd
	cmp r8,4
	je imprimir_Rs
	cmp r8,5
	je imprimir_Rs
	jmp imprimir_Rt

termina:
	impr_texto text_salto,len_salto
	ret

impr_add:
	impr_texto text_Snumero,len_Snumero
	impr_decimal r13
        impr_texto text_espacio,len_espacio
	impr_registro [r14]
        impr_texto text_salto,len_salto
	add r14,8
	add r13,1
	ret
;#################################################################################################################################

; Buffer Size en 4 porque son 4x8: 32 bits

section	.data
  ; ### Parte 0 - Mensaje de Bienvenida al Emulador y presentacion del proyecto
  const_saludo_txt: db 'Bienvenido al Emulador MIPS',0xa
  const_saludo_size: equ $-const_saludo_txt
  const_curso_txt: db 'EL-4313-Lab. Estructura de Microprocesadores',0xa
  const_curso_size: equ $-const_curso_txt
  const_semestre_txt: db '1S-2017',0xa
  const_semestre_size: equ $-const_semestre_txt
  ;  ### Parte 1 - Mensaje de buscando archivo ###
  const_buscandoROM_txt: db 'Buscando archivo ROM.txt', 0xa
  const_buscandoROM_size: equ $-const_buscandoROM_txt
  ; ### Parte 2 - Apertura del archivo ###
  file_name db '/home/tec/Desktop/Github/proyecto_1_LabMicros_SEM1_2017_Grupo3/ROM_Test.txt'
  ; ### Parte 3 - Comprobación de correcto ###
  fd dw 0

  ; ### Parte B - Mensaje de error FILENOTFOUND ###
  const_filenotfound_txt: db 'Archivo ROM.txt no encontrado', 0xa
  const_filenotfound_size: equ $-const_filenotfound_txt
  ; ### Parte A - Mensaje de info FileFound ###
  const_filefound_txt: db 'Archivo ROM.txt encontrado', 0xa
  const_filefound_size: equ $-const_filefound_txt
  ; ### Parte C - Mensaje de error - Overflow de instrucciones ###
  const_instoverflow_txt: db 'Error: Existen más instrucciones de las permitidas (150) o hay una instrucción no válida', 0xa
  const_instoverflow_size: equ $-const_instoverflow_txt
  ; ### Parte D - Mensaje para continuar con la ejecuciones
  const_continuar_txt: db 'Presione la tecla enter para continuar con la ejecucion del archivo ROM.txt',0xa
  const_continuar_size: equ $-const_continuar_txt
  const_salir_txt: db 'Verifique la ruta del archivo ROM.txt',0xa
  const_salir_size: equ $-const_salir_txt

  ; ### Parte Fetch ###
  instructions TIMES 150 dd 0   ; Cargar el arreglo de instrucciones 150 inst
  data TIMES 512 db -1           ; Cargar el arreglo de memoria en 512 (0x190) words
  ;stack TIMES 100 dd -1          ; Cargar el arreglo de stack de 100 palabras --- DUDA!!!!
  registers TIMES 64 dd 0        ; Cargar los registros del microprocesador
  ;temp dq 0
  
  
;###############################################################################################################################################reciente
fmt:    db "%ld "	; The printf format

;
resulttxt: db 'result.txt',0

;################# seccion de variables a imprimir texto
ejecutando: db 'Ejecutando la instruccion: '
ejecutando_len: equ $-ejecutando

text_Add: db 'Add '
len_Add: equ $-text_Add

text_Addi: db 'Addi '
len_Addi: equ $-text_Addi

text_Addu: db 'Addu '
len_Addu: equ $-text_Addu

text_And: db 'And '
len_And: equ $-text_And

text_Andi: db 'Andi '
len_Andi: equ $-text_Andi

text_Beq: db 'Beq '
len_Beq: equ $-text_Beq

text_Bne: db 'Bne '
len_Bne: equ $-text_Bne

text_J: db 'J '
len_J: equ $-text_J

text_Jal: db 'Jal '
len_Jal: equ $-text_Jal

text_Jr: db 'Jr '
len_Jr: equ $-text_Jr

text_Lui: db 'Lui '
len_Lui: equ $-text_Lui

text_Lw: db 'Lw '
len_Lw: equ $-text_Lw

text_Nor: db 'Nor '
len_Nor: equ $-text_Nor

text_Or: db 'Or '
len_Or: equ $-text_Or

text_Ori: db 'Ori '
len_Ori: equ $-text_Ori

text_Slt: db 'Slt '
len_Slt: equ $-text_Slt

text_Slti: db 'Slti '
len_Slti: equ $-text_Slti

text_Sltiu: db 'Sltiu '
len_Sltiu: equ $-text_Sltiu

text_Sltu: db 'Sltu '
len_Sltu: equ $-text_Sltu

text_Sll: db 'Sll '
len_Sll: equ $-text_Sll

text_Srl: db 'Srl '
len_Srl: equ $-text_Srl

text_Sub: db 'Sub '
len_Sub: equ $-text_Sub

text_Subu: db 'Subu '
len_Subu: equ $-text_Subu

text_Mult: db 'Mult '
len_Mult: equ $-text_Mult


;###############################-----------------Textos para imprimir registros MIPS------------------################################


text_Ss0: db '$s0 '
len_Ss0: equ $-text_Ss0

text_Szero: db '$zero '
len_Szero: equ $-text_Szero

text_Ss1: db '$s1 '
len_Ss1: equ $-text_Ss1

text_Ss2: db '$s2 '
len_Ss2: equ $-text_Ss2

text_Ss3: db '$s3 '
len_Ss3: equ $-text_Ss3

text_Ss4: db '$s4 '
len_Ss4: equ $-text_Ss4

text_Ss5: db '$s5 '
len_Ss5: equ $-text_Ss5

text_Ss6: db '$s6 '
len_Ss6: equ $-text_Ss6

text_Ss7: db '$s7 '
len_Ss7: equ $-text_Ss7

text_Ssp: db '$sp '
len_Ssp: equ $-text_Ssp

text_Sa0: db '$a0 '
len_Sa0: equ $-text_Sa0

text_Sa1: db '$a1 '
len_Sa1: equ $-text_Sa1

text_Sa2: db '$a2 '
len_Sa2: equ $-text_Sa2

text_Sa3: db '$a3 '
len_Sa3: equ $-text_Sa3

text_Sv0: db '$v0 '
len_Sv0: equ $-text_Sv0

text_Sv1: db '$v1 '
len_Sv1: equ $-text_Sv1

text_Snumero: db '$'
len_Snumero: equ $-text_Snumero

text_salto: db '.',0xa
len_salto: equ $-text_salto


;#################################----------Textos para identificacion de errores-----------########################################
text_error_Rs: db 'ERROR! Registro Rs invalido.',0xa
len_error_Rs: equ $-text_error_Rs

text_error_Rt: db 'ERROR! Registro Rt invalido.',0xa
len_error_Rt: equ $-text_error_Rt

text_error_Rd: db 'ERROR! Registro Rd invalido.',0xa
len_error_Rd: equ $-text_error_Rd

text_error_overflow: db 'ERROR! Overflow detectado en la instruccion ',0xa
len_error_overflow: equ $-text_error_overflow

text_error_OPCode: db 'ERROR! Codigo de operacion invalido en la intruccion correpondiente a la direccion: ',0xa
len_error_OPCode: equ $-text_error_OPCode

text_error_Function: db 'ERROR! Funcion invalida en la intruccion correpondiente a la direccion: ',0xa
len_error_Function: equ $-text_error_Function

;#################################################################################################################################

text_espacio: db ' - '
len_espacio: equ $-text_espacio

limpiar    db 0x1b, "[2J", 0x1b, "[H"
limpiar_tam equ $ - limpiar

;###########################################################################################################################################

text_final: db 'GG EZ',0xa
len_final: equ $-text_final

text_ejecucion_exitosa: db 'Ejecucion Exitosa',0xa
len_ejecucion_exitosa: equ $-text_ejecucion_exitosa

text_ejecucion_fallida: db 'Ejecucion Fallida',0xa
len_ejecucion_fallida: equ $-text_ejecucion_fallida

text_enter_salida: db 'Presione Enter para terminar',0xa
len_enter_salida: equ $-text_enter_salida

text_Desarrolladores: db 'Desarrolladores:',0xa
len_Desarrolladores: equ $-text_Desarrolladores

text_Leon: db 'Luis Gerardo Leon Vega     Carne: 2014069639',0xa
len_Leon: equ $-text_Leon

text_Keylor: db 'Keylor Andres Mena Venegas     Carne: 20140108164',0xa
len_Keylor: equ $-text_Keylor

text_Danny: db 'Danny Gabriel Mejias Anchia     Carne: 2014159999',0xa
len_Danny: equ $-text_Danny

text_Javi: db 'Javier Cordero Quiros     Carne: 2014115782',0xa
len_Javi: equ $-text_Javi

text_Merayo: db 'Luis Orlando Merayo Gatica     Carne: 2014049811',0xa
len_Merayo: equ $-text_Merayo

;###############################################################################################################################################
text_enter: db ''
;###############################################################################################################################################

section	.text
   global _start         ;must be declared for using gcc

_start:
    mov rbp, rsp; for correct debugging

  ;  ### Mensaje de Entrada al emulador
  impr_shell const_saludo_txt, const_saludo_size
  impr_shell const_curso_txt, const_curso_size
  impr_shell const_semestre_txt, const_semestre_size
  ; ### Parte 1 - Mensaje de buscando archivo ###
  impr_shell const_buscandoROM_txt, const_buscandoROM_size
  ; ### Parte 2 - Apertura del archivo ###
  mov rax, SYS_OPEN
  mov rdi, file_name
  mov rsi, 0
  mov rdx, 0777                    ; Para acceso total
  syscall

  ; ### Parte 3 - Comprobación de correcto ###
  mov [fd], rax                      ; Apertura del puntero 
  mov	rdx,0
  cmp	rdx,rax                      ; Condicion si hay bytes
  jg	_filenotfound                ; Si hay una incongruencia
  jmp _filefound                     ; Mensaje de encontrado
  
_fileread:
  ; ### Parte 4 - Leer ###
  mov rax, SYS_READ
  mov rdi, [fd]
  mov rsi, file_buffer
  mov rdx, BUFFER_SIZE
  syscall

  ; Ver si se terminó de leer
  cmp rax, 0
  je _startPC	; Comenzar el procesador

  ; Mostrar contenido en consola
  mov r8, 0

  mov r8, [file_buffer]
  mov rdx, rax
  mov rax, SYS_WRITE
  mov rdi, STDOUT
  mov rsi, file_buffer
  syscall
  
  ; Nuevo código DEBUG
  
  ; ## Filtrado de datos
  cmp r8, 32    ; Ver si es espacio
  je _fileread
  cmp r8, 59    ; Ver si es ;
  je _activarComentario
  cmp r8, 10; Ver si es fin de línea
  je _writeMem
  cmp r9, 2 ; Ver si está el modo de comentario
  je _fileread
  cmp r8, 0x5b ; Ver si inicia la direccion
  je _startAddress
  cmp r8, 0x5d ; Ver si finaliza la direccion
  je _endAddress
  cmp r8, 57 ; Ver si el dato es numérico
  jle _numerico
  cmp r8, 70 ; Ver si es hexa mayuscula
  jle _hexmay
  cmp r8, 102 ; Ver si es hexa minúscula
  jle _hexmin
  
  
  ; ## Caracteres numéricos
  _numerico:
    sub r8, 48
    jmp _append
  ; ## Caracteres Hexa Mayúsculas
  _hexmay:
    sub r8, 55 ; 65 start + 10
    jmp _append
  _hexmin:
    sub r8, 87 ; 97 start + 10
    jmp _append
  
  ; ## Operaciones especiales
  _startAddress:
    mov r9, 1   ; Encender centinela
    jmp _fileread
  _endAddress:
    mov r9, 0
    jmp _fileread
  _append:
    cmp r9, 1
    je _appendAddress
    jmp _appendData
  _appendAddress:
    shl r14, 4  ; Correr direccion para adjuntar byte
    or r14, r8  ; Hacer append
    jmp _fileread
  _appendData:
    shl r15, 4  ; Correr data para adjuntar byte
    or r15, r8  ; Hacer append
    jmp _fileread
  _activarComentario:
    mov r9, 2   ; Activar comentario
    jmp _fileread
  
  ; Escritura en el STACK
  ; 0H - 0040 0000H (Reserved)
  ; 0040 0000H - 1000 0000 (Program)
  ; 1000 0000 - 1000 8000 (Constantes)
  ; 1000 8000 - 3FFF FFFC (Stack)
  ; Instrucciones 150
  ; Memoria de Datos 100
  ; Stack 100
  
  _writeMem:
    ; Tipo instruccion
    mov r8d, r14d   ; Crear un contenido de direccion auxiliar
    shr r8d, 16     ; Ver la parte superior de los 32 bits
    cmp r8d, 0x0040 ; Ver si es instrucción
    je _writeInstruction
    cmp r8d, 0x1000 ; Ver si son datos
    je _writeDynamic
    jmp _instoverflow       ; DEBUG
    
  _writeInstruction:
    mov r8, 0
    mov r8w, r14w   ; Copiar los primeros 16 bits  - Recordar eliminar la parte alta de la palabra
    add r8, instructions
    mov [r8], r15  ; Almacenar como instruccion
    mov r14, 0
    mov r15, 0
    mov r9, 0       ; Restore modo captura
    jmp _fileread
  
  _writeDynamic:
    mov r8, 0
    mov r8w, r14w   ; Copiar los primeros 16 bits de direccion - Recordar eliminar la parte alta de la palabra
    and r8w, 0x7FFF ; Eliminar el 8000 y poner 0000
    add r8, data
    mov [r8], r15   ; Almacenar como dato dinámico
    mov r14, 0
    mov r15, 0
    jmp _fileread
  
  
  jmp _fileread


_startPC:
	;## abrir el archivo de resultados
    mov rax,2
    mov rdi,resulttxt
    mov rsi,(2000o+1000o+100o+2o)
    mov rdx,(700o+40o+4o)
    syscall	
    mov [result_fd],rax

  ; ### Parte 9- Preparar el PC y apuntarlo en la posicion inicial ###
  mov r14, r15                ; Repaldar las instrucciones totales que existen (para evitar desbordamientos)
  mov r15, 0x400000           ; Colocar el PC Counter en su posicion inicial

	impr_shell const_continuar_txt, const_continuar_size
  	tecla_get text_enter
	limpiar_pantalla limpiar,limpiar_tam

_fetch:
  ; ### Parte 10 - Decodificar el PC en memoria de instrucciones: Pasar de 400004 a 1 ###
  mov r14, r15                ; Hacer copia del PC
  ;shr r14, 2                  ; Dividir por 4
  and r14, 0xFFF              ; Obtener los últimos dígitos
  ; Verificar que el contador sea válido
  cmp r14, 150                ; Ver si no hay overflow
  jge _instoverflow           ; Si es 150 o más, hay overflow
  ; Hasta este punto, ya tengo el valor del puntero del arreglo a incrementar

  ; ### Parte 11 - Buscar la instrucción (Fetching) ###
  add r14, instructions       ; Sumar elemento al arreglo respectivo
  mov edx, [r14]              ; Cargar la instruccion en rdx
  ; Hasta este punto, tengo la próxima instrucción. Hay que ver si es válida

  ; ### Parte 12 - Salida de programa por falta de instrucciones ###
  cmp edx, 0                 ; Si la instrucción está cargada de F's, no es válida, entonces salir
  je Pantalla_salida_exitosa
  ; Hasta este punto, tengo todo filtrado de que sea correcto

  ; ### Parte 13 - PC + 4 ###
  add r15, 4                  ; PC + 4
  jmp _predecode

_predecode:
  ; ### Parte 14 - Obtener las componentes de la instrucción (opcode, function, ...) ###
  ; Sacar el Opcode
  mov r8, rdx             ;Hacemos copia de la instruccion
  cmp rdx, 0
  je _nop
  shr r8, 26
  and r8, 0x3F
  
  ; Verificar si es R
  cmp r8, 0
  je _FormatoR
  ; Verificar si es J (3=>)
  cmp r8, 3
  jle _FormatoJ
  ; Verificar si es I - Default
  jmp _FormatoI

_FormatoR:
  ; Hallar rs (21-25)
  mov r11, 0x1F 			; Mascara de 5 Bits
  shl r11, 21				; Correr al LSB
  and r11, rdx				; Adquirir la direccion de rs
  shr r11, 21
  mov rbx,r11                             ; Devolverse
  ; Hallar rt (16-20)	
  mov r10, 0x1F				; Mascara de 5 Bits
  shl r10, 16				; Correr al LSB
  and r10, rdx				; Adquirir la direccion de rt
  shr r10, 16                             ; Devolverse
  ; Hallar el rd (11-15)	
  mov r12, 0x1F				; Mascara de 5 bits
  shl r12, 11				; Correr el LSB
  and r12, rdx				; Adquirir la direccion de rd
  shr r12, 11                             ; Devolverse
  ; Hallar el shamt (6-10)
  mov r14, 0x1F				; Mascara de 5 bits
  shl r14, 6				; Correr hasta el MSB
  and r14, rdx				; Adquirir el shampt
  shr r14, 6                            ; Devolverse
  ;mov r13,r14                              ;shamt
  ; Hallar el function (0-5)
  mov r9, 0x3F				; Mascara de 6 bits
  and r9, rdx				; Adquirir el function code
  
  jmp _decode ; DEBUG!!
_FormatoI:
  ; Hallar rs (21-25)
  mov r11, 0x1F 			; Mascara de 5 Bits
  shl r11, 21				; Correr al LSB
  and r11, rdx				; Adquirir la direccion de rs
  shr r11, 21
  mov rbx,r11                             ; Devolverse
  ; Hallar rt (16-20)	
  mov r10, 0x1F				; Mascara de 5 Bits
  shl r10, 16				; Correr al LSB
  and r10, rdx				; Adquirir la direccion de rt
  shr r10, 16                             ; Devolverse
  ; Hallar el inmediate (0-15)
  mov r12, 0
  mov r12w, -1				; Hacer máscara de 16 bits
  and r12, rdx				; Adquirir el inmediato
  mov r14, r12
  jmp _decode ; DEBUG!!
_FormatoJ:
  mov r13, 0x3F				; Mascara de 6 bits para filtrar opcode
  shl r13, 26				; Correr hasta el LSB del opcode
  not r13					; Invertir para adquirir el jaddress
  and r13, rdx
  jmp _decode ; DEBUG!!

_filefound:
  ; ### Parte A - Mensaje de info - FileFound ###
  impr_shell const_filefound_txt, const_filefound_size
  mov r9,0
  jmp _fileread

_filenotfound:
  ; ### Parte B - Mensaje de error FILENOTFOUND ###
  impr_shell const_filenotfound_txt, const_filenotfound_size
  impr_shell const_salir_txt, const_salir_size
  jmp Pantalla_salida_error

_instoverflow:
  ; ### Parte C - Mensaje de instrucciones overflow ###
  mov rax,1						             ;Colocar en modo sys_write
  mov rdi,1					               ;Colocar en consola
  mov rsi,const_instoverflow_txt		 ;Cargar el mensaje
  mov rdx,const_instoverflow_size	 ;Tamaño del mensaje
  syscall
  jmp Pantalla_salida_error

_exit:
  ; ### Cierra el archivo ###
	;##Cierra el archivo
	mov rax,3
	mov rdi,[result_fd]
	syscall
  
	mov rax, SYS_CLOSE
	mov rdi, fd
  	syscall
  ; ### Exit ###
	mov rax,60						; Salir del sistema sys_exit
	mov rdi,0
	syscall


;################# seccion carga de datos
;################# seccion carga de datos
deco_RS:
        
	mov r8,registers ;asigna puntero de arreglo de registros
    ;impr_texto text_Sv0,len_Sv0
	;shl r11,3 ;alinear direccion
 	shl rbx,3  
	;add r8,r11 ;mueve direccion de puntero
 	;mov r11,[r8] ;cargo los datos de la direccion de memoria
	add r8,rbx ;mueve direccion de puntero
	mov rbx,[r8] 
	ret

deco_RT:
	mov r8,registers ;asigna puntero de arreglo de registros
	shl r10,3 ;alinear direccion
	add r8,r10 ;mueve direccion de puntero
	mov r10,[r8] ;cargo los datos de la direccion de memoria
	ret

deco_RD:
	mov r8,registers ;asigna puntero de arreglo de registros
	shl r12,3 ;alinear direccion
	add r8,r12 ;mueve direccion de puntero
	ret

deco_RT_I:
	mov r8,registers ;asigna puntero de arreglo de registros
	shl r10,3 ;alinear direccion
	add r8,r10 ;mueve direccion de puntero
	ret

llamadas_aritmeticas_log: ; llamadas para carga de registros cuando Rd es destino
	call deco_RS
	call deco_RT
	call deco_RD
	ret

llamadas_tipo_I: ;llamada para carga de registros cuando Rt es destino
	call deco_RS
	call deco_RT_I
	ret

; ###################### OPcode
_decode:
        
        ;mov r14,r11
               
;instrucciones R
	cmp r8,0 ;identifica instrucciones tipo R
	je function_R
	cmp r8,0x8 ;identifica Addi
	je ins_Addi
	cmp r8,0xc ;identifica Andi
	je ins_Andi
	cmp r8,0x4 ;identifica Beq
	je ins_Beq
	cmp r8,0x5 ;identifica Bne
	je ins_Bne
	cmp r8,0x2 ;identifica J
	je ins_J
	cmp r8,0x3 ;identifica Jal
	je ins_Jal
	cmp r8,0x23 ;identifica Lw
	je ins_Lw
	cmp r8,0xd ;identifica Ori
	je ins_Ori
	cmp r8,0xa ;identifica Slti
	je ins_Slti
	cmp r8,0xb ;identifica Sltiu
	je ins_Sltiu
	cmp r8,0xf
	je ins_Lui ;identifica Lui
        impr_texto text_error_OPCode, len_error_OPCode
        impr_registro r15
        jmp Pantalla_salida_error
	
;############################
function_R:
	cmp r9,0x20 ;identifica Add
	je ins_Add
	cmp r9,0x21 ;identifica Addu
	je ins_Addu
	cmp r9,0x24 ;identifica And
	je ins_And
	cmp r9,0x08 ;identifica Jr
	je ins_Jr
	cmp r9,0x27 ;identifica Nor
	je ins_Nor
	cmp r9,0x25 ;identifica Or
	je ins_Or
	cmp r9,0x2a ;identifica Slt
	je ins_Slt
	cmp r9,0x2b ;identifica Sltu
	je ins_Sltu
	cmp r9,0x00 ;identifica Sll
	je ins_Sll
	cmp r9,0x02 ;identifica Srl
	je ins_Srl
	cmp r9,0x22 ;identifica Sub
	je ins_Sub
	cmp r9,0x23 ;identifica Subu
	je ins_Subu
	cmp r9,0x18 ;identifica Mult
	je ins_Mult
        impr_texto text_error_Function, len_error_Function
        impr_registro r15
        jmp Pantalla_salida_error

;###### Funcionamiento de instrucciones tipo R

ins_Add:
	impr_texto text_Add,len_Add
	call siguiente_variable
	call llamadas_aritmeticas_log
	mov eax, r10d
    add eax, ebx
    ; Ambos positivos
    cmp r10d, 0
    jge ins_Add_r11positivo
    ; Ambos negativos
    jl ins_Add_r11negativo
    	ins_Add_r11positivo:
            cmp ebx, 0
            jge ins_Add_respositivo
            jmp ins_Add_ret
        ins_Add_r11negativo:
            cmp ebx, 0
            jl ins_Add_resnegativo
            jmp ins_Add_ret
        ins_Add_respositivo:
            cmp eax, 0
            jl overflow
            jmp ins_Add_ret
        ins_Add_resnegativo:
            cmp eax, 0
            jge overflow               ; Agregar
  
        ins_Add_ret: 
            mov [r8], eax; write back
	
	jmp imprimir_all

ins_Addu: 
	impr_texto text_Addu,len_Addu
	call siguiente_variable
	call llamadas_aritmeticas_log
	add r10d, ebx; Opera solo 32 bits de r10 y r11
	mov [r8], r10d; write back
	jmp imprimir_all

ins_And:
	impr_texto text_And,len_And
	call siguiente_variable
	call llamadas_aritmeticas_log
	and rbx,r10 ; operacion de and
	mov [r8],ebx ; write back
	jmp imprimir_all

ins_Jr:
	impr_texto text_Jr,len_Jr
	call siguiente_variable
	call deco_RS
	mov r15, rbx ;asigna nueva direccion al Program Counter
	jmp imprimir_all

ins_Nor:
	impr_texto text_Nor,len_Nor
	call siguiente_variable
	call llamadas_aritmeticas_log
	or rbx,r10 ; operacion de or
	not rbx ; operacion de negacion
	mov [r8],ebx ; write back
	jmp imprimir_all

ins_Or:
	impr_texto text_Or,len_Or
	call siguiente_variable
	call llamadas_aritmeticas_log
	or rbx,r10 ; operacion de or
	mov [r8],ebx ; write back
	jmp imprimir_all


;#################################
ins_Slt: 
	impr_texto text_Slt,len_Slt
	call siguiente_variable
	call llamadas_aritmeticas_log
	cmp ebx,r10d
	jge esmayor_sltu ; verificacion de mayor o menor
	mov r10,1
	mov [r8],r10d
	jmp imprimir_all

ins_Sltu:
	impr_texto text_Sltu,len_Sltu
	call siguiente_variable
	call llamadas_aritmeticas_log
	cmp rbx,r10
	jge esmayor_sltu ; verificacion de mayor o menor
	mov r10,1
	mov [r8],r10d
	jmp imprimir_all

esmayor_sltu: ;si la comparacion da mayor
	mov r10,0
	mov [r8],r10d
	jmp imprimir_all
;################################

ins_Sll:
	impr_texto text_Sll,len_Sll
	call siguiente_variable
	call deco_RT
	call deco_RD
	mov rcx,r14
	shl r10, cl ;corrimiento a la izquierda
	mov [r8],r10d ;write back
	jmp imprimir_all
        ;jmp _fetch

ins_Srl:
	impr_texto text_Srl,len_Srl
	call siguiente_variable
	call deco_RT
	call deco_RD
	mov rcx,r13
	shr r10,cl ;corrimiento a la derecha
	mov [r8],r10d ;write back
	jmp imprimir_all

ins_Sub:
	impr_texto text_Sub,len_Sub
	call siguiente_variable
	call llamadas_aritmeticas_log
	mov eax, r10d
        mov r14,rbx
    sub ebx, eax
    cmp eax, 0
	jge ins_Sub_r11negativo
	jl ins_Sub_r11positivo
	
	ins_Sub_r11negativo:
		cmp r14d, 0
		jle ins_Sub_respositivo
		jmp ins_Sub_ret
	ins_Sub_r11positivo:
		cmp r14d, 0
		jge ins_Sub_resnegativo
		jmp ins_Sub_ret
	ins_Sub_respositivo:
		cmp ebx, 0
		jg overflow
		jmp ins_Sub_ret
	ins_Sub_resnegativo:
		cmp ebx, 0
		jl overflow
	ins_Sub_ret:
		mov [r8], ebx; write back
	jmp imprimir_all

ins_Subu:
	impr_texto text_Subu,len_Subu
	call siguiente_variable
	call llamadas_aritmeticas_log
        mov rax, r10
	sub rbx,rax ;operacion de resta
	mov [r8],ebx ;write back
	jmp imprimir_all

ins_Mult: 
	impr_texto text_Mult,len_Mult
	call siguiente_variable
	call llamadas_aritmeticas_log
         mov r11,0
        mov r12,0
        cmp r10,0
        jg multiplicacion

finmult:
        carga 8
        mov [r14],r12
        shr r12,32
        carga 9
        mov [r14],r12
        jmp imprimir_all
    

multiplicacion:
      ADD r12,RBX
      add r11,1  
      cmp r11,r10
      jl multiplicacion
       jmp finmult
;####################################Funcionamiento de instrucciones tipo I

ins_Addi:
	impr_texto text_Addi,len_Addi
	call siguiente_variable
	call llamadas_tipo_I   
	movsx r12d,r12w
	mov eax, ebx
    add eax, r12d
    ; Ambos positivos
    cmp ebx, 0
    jge ins_Addi_immpositivo
    ; Ambos negativos
    jl ins_Addi_immnegativo
    	ins_Addi_immpositivo:
            cmp r12d, 0
            jge ins_Addi_respositivo
            jmp ins_Addi_ret
        ins_Addi_immnegativo:
            cmp r12d, 0
            jl ins_Addi_resnegativo
            jmp ins_Addi_ret
        ins_Addi_respositivo:
            cmp eax, 0
            jl overflow
            jmp ins_Addi_ret
        ins_Addi_resnegativo:
            cmp eax, 0
            jge overflow               ; Agregar
  
        ins_Addi_ret: 
            mov [r8], eax; write back
            ;jmp _fetch
	jmp imprimir_all


ins_Andi:
	impr_texto text_Andi,len_Andi
	call siguiente_variable
	call llamadas_tipo_I
	and rbx,r12 ;operacion de and
	mov [r8],ebx ;write back
	jmp imprimir_all

ins_Beq:
	impr_texto text_Beq,len_Beq
	call siguiente_variable
	call deco_RS
	call deco_RT
	cmp r10,rbx ; comparacione de registros rs y rt
	je branch_address ;salto si es valido
	jmp imprimir_all

ins_Bne:
	impr_texto text_Bne,len_Bne
	call siguiente_variable
	call deco_RS
	call deco_RT
	cmp r10,rbx ; comparaciones de registros rs y rt
	jne branch_address ;salto si es valido
	jmp imprimir_all

branch_address:
	mov r10,r12 ;copiar el dato para hacer la máscara
	shr r10,15 ;corrimiento para hacer la máscara
	and r10,1 ;captura el bit de signo
	cmp r10,1 ;si el número es negativo
	je Crear_Ext 

Branch:
	shl r12, 2
	add r15, r12 ;termina el calculo de nueva direccion
	jmp imprimir_all

Crear_Ext:
	mov r10, 16383 ;14 veces el primer bit del inmediato
	shl r10,16
	or r10,r12 ;Calculo de Branch Address
	jmp Branch

ins_J:
	impr_texto text_J,len_J
	impr_registro r13
	impr_texto text_salto,len_salto
	jmp JumpAddress

ins_Jal:
	impr_texto text_Jal,len_Jal
	impr_registro r13
	impr_texto text_salto,len_salto
	mov r8,registers ;asigna puntero de arreglo de registros
	mov r10,0xf8
	add r8,r10 ;mueve direccion de puntero
	add r15,4
	mov [r8],r15d ; R[31] = PC + 8
	sub r15,4
	jmp JumpAddress

JumpAddress:
         mov r14,r15
	shr r14, 28
	shl r14, 26 ;toma de los primeros cuatros bits del PC
	or r14, r13 
	shl r14,2 ; calculo de JumpAddress
	mov r15,r14
	jmp imprimir_all


ins_Lui:
	impr_texto text_Lui,len_Lui
	impr_numero r12
	impr_texto text_salto,len_salto
	call deco_RT_I
	shl r12,16
	mov [r8],r12d
	jmp imprimir_all
	
ins_Lw:
	impr_texto text_Lw,len_Lw
	call siguiente_variable
	call llamadas_tipo_I
	movsx r12d,r12w
	add rbx,r12
	mov r9,data ;asigna puntero de arreglo de registros
        and rbx, 0x1ff
        shl rbx,1
	add r9,rbx ;mueve direccion de puntero
	mov r10d,[r9]
 	mov [r8],r10d ;cargo los datos de la direccion de memoria
	jmp imprimir_all
	

ins_Ori:
	impr_texto text_Ori,len_Ori
	call siguiente_variable
	call llamadas_tipo_I
	or rbx,r12 ;operacion de or
	mov [r8],ebx ;write back
	jmp imprimir_all

ins_Slti:
	impr_texto text_Slti,len_Slti
	call siguiente_variable
        call llamadas_tipo_I
        movsx r12d,r12w
	cmp ebx,r12d
	jge esmayor_sltiu ; verificacion de mayor o menor
	mov r10,1
	mov [r8],r10d
	jmp imprimir_all

ins_Sltiu:
	impr_texto text_Sltiu,len_Sltiu
	call siguiente_variable
	call llamadas_tipo_I
	mov r10,r12 ;copiar el dato para hacer la máscara
	shr r10,15 ;corrimiento para hacer la máscara
	and r10,1 ;captura el bit de signo
	cmp r10,1 ;si el número es negativo
	je SignExtsltiu
	jmp Sltiu

SignExtsltiu:
	or r12,-65536 ;Extiende el signo
	jmp Sltiu

Sltiu:
	;shl r12,32 ; Corrimientos 
	;shr r12,32 
	cmp ebx,r12d ;comparacion
	jge esmayor_sltiu ; verificacion de mayor o menor
	mov rbx,1
	mov [r8],ebx
	jmp imprimir_all

esmayor_sltiu: ;si si la comparacion da mayor
	mov rbx,0
	mov [r8],ebx ;escribe 0
	jmp imprimir_all
	
;##############################################seccion de impresion de variables


	
imprimir_all:
	carga 2
	
tag1:

	call impr_add
	cmp r13,10
	jl tag1
	carga 16
tag2:
           
	call impr_add
	cmp r13,24
	jl tag2
	carga 29
	call impr_add
	carga 31
	call impr_add
	tecla_get text_enter
	limpiar_pantalla limpiar,limpiar_tam
	jmp _fetch


overflow:
        impr_texto text_error_overflow, len_error_overflow
        carga 2
tag3:
	call impr_add
	cmp r13,8
	jl tag3
	carga 16
tag4:
	call impr_add
	cmp r13,24
	jl tag4
	carga 29
	call impr_add
	carga 31
	call impr_add
    jmp Pantalla_salida_error

_nop:
    jmp _fetch


Pantalla_salida_error:
        impr_texto text_ejecucion_fallida,len_ejecucion_fallida
        impr_texto text_Desarrolladores,len_Desarrolladores
        impr_texto text_Javi,len_Javi
        impr_texto text_Leon,len_Leon
        impr_texto text_Danny,len_Danny
        impr_texto text_Keylor,len_Keylor
        impr_texto text_Merayo,len_Merayo
        impr_texto text_enter_salida,len_enter_salida
        tecla_get text_enter
        jmp _exit
        
Pantalla_salida_exitosa:
        impr_texto text_ejecucion_exitosa,len_ejecucion_exitosa
        impr_texto text_Desarrolladores,len_Desarrolladores
        impr_texto text_Javi,len_Javi
        impr_texto text_Leon,len_Leon
        impr_texto text_Danny,len_Danny
        impr_texto text_Keylor,len_Keylor
        impr_texto text_Merayo,len_Merayo
        impr_texto text_enter_salida,len_enter_salida
        tecla_get text_enter
        jmp _exit
        

section .bss
  file_buffer resb BUFFER_SIZE
  result_fd resb 8
  modelo resd  8  ; reservar 8 bytes
  regs resd 8

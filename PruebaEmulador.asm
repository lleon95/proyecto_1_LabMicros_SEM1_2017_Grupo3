%include "io64.inc"
%define SYS_READ 0
%define SYS_OPEN 2
%define SYS_WRITE 1
%define SYS_CLOSE 3
%define STDOUT 1
%define BUFFER_SIZE 1
extern	printf		; the C function, to be called
;#################################################################################################################################
%macro limpiar_pantalla 2 	;recibe 2 parametros
	mov rax,1	;sys_write
	mov rdi,1	;std_out
	mov rsi,%1	;primer parametro: caracteres especiales para limpiar la pantalla
	mov rdx,%2	;segundo parametro: Tamano 
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

%macro impr_numero 1
	 push    rbp		; set up stack frame
	
	 mov	rax,%1		; put "a" from store into register
	 mov	rdi,fmt		; format for printf
	 mov	rsi,%1         ; first parameter for printf
	 mov	rax,0		; no xmm registers
         call    printf		; Call C function

	 pop	rbp		; restore stack

	 mov	rax,0		; normal, no error, return value
%endmacro

%macro carga 1
	mov r9,registers
	mov r8,%1
	mov r10,r8
	shl r10,3
	add r9,r10
%endmacro

;#################seccion de compracion de Rd
imprimir_Rd:
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
	cmp r12,21
	je Rd_s5
	cmp r12,22
	je Rd_s6
	cmp r12,23
	je Rd_s7
	cmp r12,29
	je Rd_sp
	jmp error_exit

Rd_v0:
	impr_texto text_$v0,len_$v0
	jmp imprimir_Rs
Rd_v1:
	impr_texto text_$v1,len_$v1
	jmp imprimir_Rs
Rd_a0:
	impr_texto text_$a0,len_$a0
	jmp imprimir_Rs
Rd_a1:
	impr_texto text_$a1,len_$a1
	jmp imprimir_Rs
Rd_a2:
	impr_texto text_$a2,len_$a2
	jmp imprimir_Rs
Rd_a3:
	impr_texto text_$a3,len_$a3
	jmp imprimir_Rs	
Rd_s0:
	impr_texto text_$s0,len_$s0
	jmp imprimir_Rs
Rd_s1:
	impr_texto text_$s1,len_$s1
	jmp imprimir_Rs
Rd_s2:
	impr_texto text_$s2,len_$s2
	jmp imprimir_Rs
Rd_s3:
	impr_texto text_$s3,len_$s3
	jmp imprimir_Rs
Rd_s4:
	impr_texto text_$s4,len_$s4
	jmp imprimir_Rs
Rd_s5:
	impr_texto text_$s5,len_$s5
	jmp imprimir_Rs
Rd_s6:
	impr_texto text_$s6,len_$s6
	jmp imprimir_Rs
Rd_s7:
	impr_texto text_$s7,len_$s7
	jmp imprimir_Rs
Rd_sp:
	impr_texto text_$sp,len_$sp
	jmp imprimir_Rs	

	;#################seccion de compracion de Rs
imprimir_Rs:
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
	jmp error_exit

siguiente_Rs:
	cmp r8,0
	je imprimir_Rt
	cmp r8,4
	je imprimir_Rt
	cmp r8,5
	je imprimir_Rt
	je imprimir_Imm
	
	
Rs_v0:
	impr_texto text_$v0,len_$v0
	jmp siguiente_Rs
Rs_v1:
	impr_texto text_$v1,len_$v1
	jmp siguiente_Rs
Rs_a0:
	impr_texto text_$a0,len_$a0
	jmp siguiente_Rs
Rs_a1:
	impr_texto text_$a1,len_$a1
	jmp siguiente_Rs
Rs_a2:
	impr_texto text_$a2,len_$a2
	jmp siguiente_Rs
Rs_a3:
	impr_texto text_$a3,len_$a3
	jmp siguiente_Rs
Rs_s0:
	impr_texto text_$s0,len_$s0
	jmp siguiente_Rs
Rs_s1:
	impr_texto text_$s1,len_$s1
	jmp siguiente_Rs
Rs_s2:
	impr_texto text_$s2,len_$s2
	jmp siguiente_Rs
Rs_s3:
	impr_texto text_$s3,len_$s3
	jmp siguiente_Rs
Rs_s4:
	impr_texto text_$s4,len_$s4
	jmp siguiente_Rs
Rs_s5:
	impr_texto text_$s5,len_$s5
	jmp siguiente_Rs
Rs_s6:
	impr_texto text_$s6,len_$s6
	jmp siguiente_Rs
Rs_s7:
	impr_texto text_$s7,len_$s7
	jmp siguiente_Rs
Rs_sp:
	impr_texto text_$sp,len_$sp
	jmp siguiente_Rs

	;#################seccion de compracion de Rt
imprimir_Rt:
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
	jmp error_exit

siguiente_Rt:
	cmp r8,0
	je termina
	cmp r8,4
	je imprimir_Imm
	cmp r8,5
	je imprimir_Imm
	je imprimir_Rs
	
	
Rt_v0:
	impr_texto text_$v0,len_$v0
	jmp siguiente_Rt
Rt_v1:
	impr_texto text_$v1,len_$v1
	jmp siguiente_Rt
Rt_a0:
	impr_texto text_$a0,len_$a0
	jmp siguiente_Rt
Rt_a1:
	impr_texto text_$a1,len_$a1
	jmp siguiente_Rt
Rt_a2:
	impr_texto text_$a2,len_$a2
	jmp siguiente_Rt
Rt_a3:
	impr_texto text_$a3,len_$a3
	jmp siguiente_Rt
Rt_s0:
	impr_texto text_$s0,len_$s0
	jmp siguiente_Rt
Rt_s1:
	impr_texto text_$s1,len_$s1
	jmp siguiente_Rt
Rt_s2:
	impr_texto text_$s2,len_$s2
	jmp siguiente_Rt
Rt_s3:
	impr_texto text_$s3,len_$s3
	jmp siguiente_Rt
Rt_s4:
	impr_texto text_$s4,len_$s4
	jmp siguiente_Rt
Rt_s5:
	impr_texto text_$s5,len_$s5
	jmp siguiente_Rt
Rt_s6:
	impr_texto text_$s6,len_$s6
	jmp siguiente_Rt
Rt_s7:
	impr_texto text_$s7,len_$s7
	jmp siguiente_Rt
Rt_sp:
	impr_texto text_$sp,len_$sp
	jmp siguiente_Rt
	
;################## Seccion de imprimir Immediato
imprimir_Imm:
	impr_numero r14
	jmp termina

;################## Seccion de llamadas a variables
siguiente_variable:
	cmp r8,0
	je imprimir_Rd
	cmp r8,4
	je imprimir_Rs
	cmp r8,5
	je imprimir_Rs
	je imprimir_Rt

termina:
	impr_texto text_salto,len_salto
	ret
	
impr_add:
	impr_texto text_$numero,len_$numero
	impr_numero r8
	impr_numero [r9]
	impr_texto text_salto,len_salto
	add r9,8
	add r8,1
	ret
;#################################################################################################################################

; Buffer Size en 4 porque son 4x8: 32 bits

section	.data
  ;  ### Parte 1 - Mensaje de buscando archivo ###
  const_buscandoROM_txt: db 'Buscando archivo ROM.txt', 0xa
  const_buscandoROM_size: equ $-const_buscandoROM_txt
  ; ### Parte 2 - Apertura del archivo ###
  file_name db '/home/lleon95/Documentos/proyecto_1_LabMicros_SEM1_2017_Grupo3/Experimentos_LuisLeon/ROM_Test.txt'
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

  ; ### Parte Fetch ###
  instructions TIMES 150 dd 0   ; Cargar el arreglo de instrucciones 150 inst
  data TIMES 401 db -1           ; Cargar el arreglo de memoria en 401 (0x190) words
  ;stack TIMES 100 dd -1          ; Cargar el arreglo de stack de 100 palabras --- DUDA!!!!
  registers TIMES 32 dd 0        ; Cargar los registros del microprocesador
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

text_enter: db ''

;################## seccion de imprimir registros MIPS
text_$s0: db '$s0 '
len_$s0: equ $-text_$s0

text_$s1: db '$s1 '
len_$s1: equ $-text_$s1

text_$s2: db '$s2 '
len_$s2: equ $-text_$s2

text_$s3: db '$s3 '
len_$s3: equ $-text_$s3

text_$s4: db '$s4 '
len_$s4: equ $-text_$s4

text_$s5: db '$s5 '
len_$s5: equ $-text_$s5

text_$s6: db '$s6 '
len_$s6: equ $-text_$s6

text_$s7: db '$s7 '
len_$s7: equ $-text_$s7

text_$sp: db '$sp '
len_$sp: equ $-text_$sp

text_$a0: db '$a0 '
len_$a0: equ $-text_$a0

text_$a1: db '$a1 '
len_$a1: equ $-text_$a1

text_$a2: db '$a2 '
len_$a2: equ $-text_$a2

text_$a3: db '$a3 '
len_$a3: equ $-text_$a3

text_$v0: db '$v0 '
len_$v0: equ $-text_$v0

text_$v1: db '$v1 '
len_$v1: equ $-text_$v1

text_$numero: db '$'
len_$numero: equ $-text_$numero

text_salto: db '.',0xa
len_salto: equ $-text_salto

limpiar    db 0x1b, "[2J", 0x1b, "[H"
limpiar_tam equ $ - limpiar
;###############################################################################################################################################

section	.text
   global CMAIN         ;must be declared for using gcc

CMAIN:
	;## abrir el archivo de resultados
	mov rax,2
	mov rdi,resulttxt
	mov rsi,(2000o+1000o+100o+2o)
	mov rdx,(700o+40o+4o)
	syscall	
	mov [result_fd],rax


    mov rbp, rsp; for correct debugging
  ; ### Parte 1 - Mensaje de buscando archivo ###
  mov rax,1						             ;Colocar en modo sys_write
  mov rdi,1					               ;Colocar en consola
  mov rsi,const_buscandoROM_txt		 ;Cargar el mensaje
  mov rdx,const_buscandoROM_size	 ;Tamaño del mensaje
  syscall
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
  ; ### Parte 9- Preparar el PC y apuntarlo en la posicion inicial ###
  mov r14, r15                ; Repaldar las instrucciones totales que existen (para evitar desbordamientos)
  mov r15, 0x400000           ; Colocar el PC Counter en su posicion inicial

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
  je _exit
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
  shr r11, 21                             ; Devolverse
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
  ; Hallar el shampt (6-10)
  mov r14, 0x1F				; Mascara de 5 bits
  shl r14, 6				; Correr hasta el MSB
  and r14, rdx				; Adquirir el shampt
  shr r14, 6                             ; Devolverse
  ; Hallar el function (0-5)
  mov r9, 0x3F				; Mascara de 6 bits
  and r9, rdx				; Adquirir el function code
  
  jmp _decode ; DEBUG!!
_FormatoI:
  ; Hallar rs (21-25)
  mov r11, 0x1F 			; Mascara de 5 Bits
  shl r11, 21				; Correr al LSB
  and r11, rdx				; Adquirir la direccion de rs
  shr r11, 21                             ; Devolverse
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
  mov rax,1						             ;Colocar en modo sys_write
  mov rdi,1					               ;Colocar en consola
  mov rsi,const_filefound_txt		 ;Cargar el mensaje
  mov rdx,const_filefound_size	 ;Tamaño del mensaje
  syscall
  jmp _fileread

_filenotfound:
  ; ### Parte B - Mensaje de error FILENOTFOUND ###
  mov rax,1						             ;Colocar en modo sys_write
  mov rdi,1					               ;Colocar en consola
  mov rsi,const_filenotfound_txt		 ;Cargar el mensaje
  mov rdx,const_filenotfound_size	 ;Tamaño del mensaje
  syscall
  jmp _exit

_instoverflow:
  ; ### Parte C - Mensaje de instrucciones overflow ###
  mov rax,1						             ;Colocar en modo sys_write
  mov rdi,1					               ;Colocar en consola
  mov rsi,const_instoverflow_txt		 ;Cargar el mensaje
  mov rdx,const_instoverflow_size	 ;Tamaño del mensaje
  syscall
  jmp _exit

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
	shl r11,3 ;alinear direccion
	add r8,r11 ;mueve direccion de puntero
 	mov r11,[r8] ;cargo los datos de la direccion de memoria
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

;###### Funcionamiento de instrucciones tipo R

ins_Add:
	impr_texto text_Add,len_Add
	call siguiente_variable
	call llamadas_aritmeticas_log
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
            jge overflow               ; Agregar
  
        ins_Add_ret: 
            mov [r8], eax; write back
	
	jmp imprimir_all

ins_Addu: 
	impr_texto text_Addu,len_Addu
	call siguiente_variable
	call llamadas_aritmeticas_log
	add r10d, r11d; Opera solo 32 bits de r10 y r11
	mov [r8], r10d; write back
	jmp imprimir_all

ins_And:
	impr_texto text_And,len_And
	call siguiente_variable
	call llamadas_aritmeticas_log
	and r11,r10 ; operacion de and
	mov [r8],r11d ; write back
	jmp imprimir_all

ins_Jr:
	impr_texto text_Jr,len_Jr
	call siguiente_variable
	deco_RS
	mov r15, r11 ;asigna nueva direccion al Program Counter
	jmp imprimir_all

ins_Nor:
	impr_texto text_Nor,len_Nor
	call siguiente_variable
	call llamadas_aritmeticas_log
	or r11,r10 ; operacion de or
	not r11 ; operacion de negacion
	mov [r8],r11d ; write back
	jmp imprimir_all

ins_Or:
	impr_texto text_Or,len_Or
	call siguiente_variable
	call llamadas_aritmeticas_log
	or r11,r10 ; operacion de or
	mov [r8],r11d ; write back
	jmp imprimir_all

;#################################
ins_Slt: ;NO SE  HA TOMANDO EN CUENTA EL SIGNO!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	impr_texto text_Slt,len_Slt
	call siguiente_variable
	call llamadas_aritmeticas_log
	cmp r10d,r11d
	jge esmayor_sltu ; verificacion de mayor o menor
	mov r10,1
	mov [r8],r10d
	jmp imprimir_all

ins_Sltu:
	impr_texto text_Sltu,len_Sltu
	call siguiente_variable
	call llamadas_aritmeticas_log
	cmp r10,r11
	jge esmayor_sltu ; verificacion de mayor o menor
	mov r10,1
	mov [r8],r10d
	jmp imprimir_all

esmayor_sltu: ;si si la comparacion da mayor
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

ins_Srl:
	impr_texto text_Srl,len_Srl
	call siguiente_variable
	call deco_RT
	call deco_RD
	mov rcx,r14
	shr r10,cl ;corrimiento a la derecha
	mov [r8],r10d ;write back
	jmp imprimir_all

ins_Sub:
	impr_texto text_Sub,len_Sub
	call siguiente_variable
	call llamadas_aritmeticas_log
	mov eax, r10d
    sub eax, r11d
    ; Ambos positivos
    cmp r10d, 0
	jge ins_Sub_r11negativo
	jl ins_Sub_r11positivo
	
	ins_Sub_r11negativo:
		comp r11d, 0
		jl ins_Sub_respositivo
		jmp ins_Sub_ret
	ins_Sub_r11positivo:
		comp r11d, 0
		jge ins_Sub_resnegativo
		jmp ins_Sub_ret
	ins_Sub_respositivo:
		cmp eax, 0
		jle overflow
		jmp ins_Sub_ret
	ins_Sub_resnegativo:
		cmp eax, 0
		jge overflow
	ins_Sub_ret:
		mov [r8], eax; write back
	jmp imprimir_all

ins_Subu:
	impr_texto text_Subu,len_Subu
	call siguiente_variable
	call llamadas_aritmeticas_log
	sub r11,r10 ;operacion de resta
	mov [r8],r11d ;write back
	jmp imprimir_all

ins_Mult: ;PREGUTARLE AL PROFE SOBRE ESTA INSTRUCCION
	impr_texto text_Mult,len_Mult
	call siguiente_variable
	call llamadas_aritmeticas_log
	jmp imprimir_all

;####################################Funcionamiento de instrucciones tipo I

ins_Addi:
	impr_texto text_Addi,len_Addi
	call siguiente_variable
	call llamadas_tipo_I
	movsx r12d,r12w
	mov eax, r10d
    add eax, r12d
    ; Ambos positivos
    cmp r10d, 0
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
            jmp ins_Add_ret
        ins_Addi_respositivo:
            cmp eax, 0
            jle overflow
            jmp ins_Addi_ret
        ins_Addi_resnegativo:
            cmp eax, 0
            jge overflow               ; Agregar
  
        ins_Addi_ret: 
            mov [r8], eax; write back
			jmp imprimir_all


ins_Andi:
	impr_texto text_Andi,len_Andi
	call siguiente_variable
	call llamadas_tipo_I
	and r11,r12 ;operacion de and
	mov [r8],r11d ;write back
	jmp imprimir_all

ins_Beq:
	impr_texto text_Beq,len_Beq
	call siguiente_variable
	call deco_RS
	call deco_RT
	cmp r10,r11 ; comparacione de registros rs y rt
	je branch_address ;salto si es valido
	jmp imprimir_all

ins_Bne:
	impr_texto text_Bne,len_Bne
	call siguiente_variable
	call deco_RS
	call deco_RT
	cmp r10,r11 ; comparaciones de registros rs y rt
	jne branch_address ;salto si es valido
	jmp imprimir_all

branch_address:
	;add r15,4
	mov r10,r12 ;copiar el dato para hacer la máscara
	shr r10,15 ;corrimiento para hacer la máscara
	and r10,1 ;captura el bit de signo
	cmp r10,1 ;si el número es negativo
	je Crear_Ext 
	jmp Branch

Crear_Ext:
	mov r10, 16383 ;14 veces el primer bit del inmediato
	shl r10,16
	or r10,r12 ;Calculo de Branch Address
	jmp Branch

Branch:
	shl r12, 2
	add r15, r12 ;termina el calculo de nueva direccion
	jmp imprimir_all

ins_J:
	impr_texto text_J,len_J
	impr_numero r13
	impr_texto text_salto,len_salto
	add r15, 4
	shr r15, 28
	shl r15, 26 ;toma de los primeros cuatros bits del PC
	or r15, r13 
	shl r15,2 ; calculo de JumpAddress
	jmp imprimir_all

ins_Jal:
	impr_texto text_Jal,len_Jal
	impr_numero r13
	impr_texto text_salto,len_salto
	mov r8,registers ;asigna puntero de arreglo de registros
	shl r10,3 ;alinear direccion
	add r8,31 ;mueve direccion de puntero
	add r15,4
	mov [r8],r15d ; R[31] = PC + 8
	sub r15,4
	jmp ins_J

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
	mov r10,r12 ;copiar el dato para hacer la máscara
	shr r10,15 ;corrimiento para hacer la máscara
	and r10,1 ;captura el bit de signo
	cmp r10,1 ;si el número es negativo
	je SignExtLw
	jmp Lw

SignExtLw:
	or r12,-65536 ;Extiende el signo
	jmp Sltiu

Lw:
	add r11,r12
	mov r9,data ;asigna puntero de arreglo de registros
	shl r11,3 ;alinear direccion
	add r9,r11 ;mueve direccion de puntero
	mov r9,[r9]
 	mov [r8],r9d ;cargo los datos de la direccion de memoria
	jmp imprimir_all
	

ins_Ori:
	impr_texto text_Ori,len_Ori
	call siguiente_variable
	call llamadas_tipo_I
	or r11,r12 ;operacion de or
	mov [r8],r11d ;write back
	jmp imprimir_all

ins_Slti:
	impr_texto text_Slti,len_Slti
	call siguiente_variable
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
	cmp r11d,r12d ;comparacion
	jge esmayor_sltiu ; verificacion de mayor o menor
	mov r11,1
	mov [r8],r11d
	jmp imprimir_all

esmayor_sltiu: ;si si la comparacion da mayor
	mov r11,0
	mov [r8],r11d ;escribe 0
	jmp imprimir_all
	
;##############################################seccion de impresion de variables
overflow:
		jmp _exit

	
imprimir_all:
	carga 2
	
tag1:
	call impr_add
	cmp r8,8
	jl tag1
	carga 16
tag2:
	call impr_add
	cmp r8,24
	jl tag2
	carga 29
	call impr_add
	impr_texto text_enter,1
	limpiar_pantalla limpiar,limpiar_tam
	jmp _fetch

overflow:
        jmp _exit; !!DEBUG
        
_nop:
    jmp _fetch


section .bss
  file_buffer resb BUFFER_SIZE
  result_fd resb 8

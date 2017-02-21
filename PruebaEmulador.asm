%include "io64.inc"
%define SYS_READ 0
%define SYS_OPEN 2
%define SYS_WRITE 1
%define SYS_CLOSE 3
%define STDOUT 1
%define BUFFER_SIZE 4


; Buffer Size en 4 porque son 4x8: 32 bits

section	.data
  ;  ### Parte 1 - Mensaje de buscando archivo ###
  const_buscandoROM_txt: db 'Buscando archivo ROM.txt', 0xa
  const_buscandoROM_size: equ $-const_buscandoROM_txt
  ; ### Parte 2 - Apertura del archivo ###
  file_name db '/home/lleon95/Documentos/proyecto_1_LabMicros_SEM1_2017_Grupo3/Experimentos_LuisLeon/testROM.bin'
  ; ### Parte 3 - Comprobación de correcto ###
  fd dw 0

  ; ### Parte B - Mensaje de error FILENOTFOUND ###
  const_filenotfound_txt: db 'Archivo ROM.txt no encontrado', 0xa
  const_filenotfound_size: equ $-const_filenotfound_txt
  ; ### Parte A - Mensaje de info FileFound ###
  const_filefound_txt: db 'Archivo ROM.txt encontrado', 0xa
  const_filefound_size: equ $-const_filefound_txt
  ; ### Parte C - Mensaje de error - Overflow de instrucciones ###
  const_instoverflow_txt: db 'Error: Existen más instrucciones de las permitidas (150)', 0xa
  const_instoverflow_size: equ $-const_instoverflow_txt

  ; ### Parte Fetch ###
  instructions TIMES 150 dw -1   ; Cargar el arreglo de instrucciones 150 inst
  data TIMES 401 db -1           ; Cargar el arreglo de memoria en 401 (0x190) words
  stack TIMES 100 dd -1          ; Cargar el arreglo de stack de 100 palabras --- DUDA!!!!
  registers TIMES 32 dd 0        ; Cargar los registros del microprocesador
  temp dq 0

section	.text
   global CMAIN         ;must be declared for using gcc

CMAIN:
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

  ; ### Parte 4 - Inicializar la carga de las instrucciones a memoria de instrucciones ###
_readinstructions:
  mov r15, 0                        ; Inicializar en el PC Counter
  mov r14, 150                       ; Total de instrucciones
  mov r12, instructions              ; Copiar el puntero de memoria a r12
  mov r10, 1                         ; Contador de bytes
  mov r8, 0

_fileread:
  ; ### Parte 5 - Leer una instruccion (32 bits) ###
  mov rax, SYS_READ
  mov rdi, [fd]
  mov rsi, file_buffer
  mov rdx, BUFFER_SIZE
  syscall
;  
;  mov rdx, [file_buffer]        ; Carga el byte en rdx
;  shl r8, 8                    ; Mueve el contenido de r13 a la izquierda
;  or r8, rdx                   ; Hace r13 = r13 or rdx
;  add r10, 1                    ; Siguiente byte (contador)
;  cmp r10, 5                    ; Ver si ya se leyeron todos
;  jne _fileread                 ; Si no se ha completado, leer proximo

_insertInst:
  ; ### Parte 6 - Verificar overflow de instrucciones (más de 150) ###
  mov r13, r14                  ; Hace copia de los registros totales
  sub r13, r15                  ; Resta de los registros totales con el PC Counter
  cmp r13, 0                    ; Si la resta es menor, hay overflow
  jl _instoverflow

  ; ### Parte 7 - Agregar instrucciones al arreglo de instrucciones ###
  mov r13, [file_buffer]        ; Copiar la instruccion en un registro temporal
  mov [r12], r13                ; Añadir la instrucción al arreglo
  add r15, 1                    ; Agregar 1 al PC
  add r12, 4                    ; Mover el puntero del arreglo al siguiente elemento

  ; ### Parte 7 - Validar fin de lectura ###
  cmp rax, 0
  je _startPC

  ; ### Parte 8- Retorno a continuar leyendo otra instruccion ###
  mov r10, 1                    ; Restaurar el contador de bytes
  mov r8, 0
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
  mov rdx, [r14]              ; Cargar la instruccion en rdx
  ; Hasta este punto, tengo la próxima instrucción. Hay que ver si es válida

  ; ### Parte 12 - Salida de programa por falta de instrucciones ###
  cmp rdx, -1                 ; Si la instrucción está cargada de F's, no es válida, entonces salir
  je _exit
  ; Hasta este punto, tengo todo filtrado de que sea correcto

  ; ### Parte 13 - PC + 4 ###
  add r15, 4                  ; PC + 4
  jmp _predecode

_predecode:
  ; ### Parte 14 - Obtener las componentes de la instrucción (opcode, function, ...) ###
  ; Sacar el Opcode
  mov r8, rdx             ;Hacemos copia de la instruccion
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
  mov r13, 0x1F				; Mascara de 5 bits
  shl r13, 6				; Correr hasta el MSB
  and r13, rdx				; Adquirir el shampt
  shr r13, 6                             ; Devolverse
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
  jmp _readinstructions

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
  mov rax, SYS_CLOSE
  mov rdi, fd
  syscall
  ; ### Exit ###
	mov rax,60						; Salir del sistema sys_exit
	mov rdi,0
	syscall


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
;instrucciones R
_decode:
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
	cmp r9,0x26 ;identifica Mult
	je ins_Mult

;###### Funcionamiento de instrucciones tipo R

ins_Add:
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
	jmp _fetch

ins_Addu: 
	call llamadas_aritmeticas_log
	add r10d, r11d; Opera solo 32 bits de r10 y r11
	mov [r8], r10d; write back
	jmp _fetch

ins_And:
	call llamadas_aritmeticas_log
	and r11,r10 ; operacion de and
	mov [r8],r11d ; write back
	jmp _fetch

ins_Jr:
	call deco_RS
	mov r15, r11 ;asigna nueva direccion al Program Counter
	jmp _fetch

ins_Nor:
	call llamadas_aritmeticas_log
	or r11,r10 ; operacion de or
	not r11 ; operacion de negacion
	mov [r8],r11d ; write back
	jmp _fetch

ins_Or:
	call llamadas_aritmeticas_log
	or r11,r10 ; operacion de or
	mov [r8],r11d ; write back
	jmp _fetch

;#################################
ins_Slt: ;NO SE  HA TOMANDO EN CUENTA EL SIGNO!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	call llamadas_aritmeticas_log
	shl r10,32 ;corrimiento para signo
	shl r11,32
	cmp r10,r11
	jge esmayor_sltu ; verificacion de mayor o menor
        mov r10, 1
	mov [r8],r10d
	jmp _fetch

esmayor_sltu: ;si si la comparacion da mayor
        mov r10, 0
	mov [r8],r10d
	jmp _fetch

;#################################
ins_Sltu:
	call llamadas_aritmeticas_log
	cmp r10,r11
	jge esmayor_sltu ; verificacion de mayor o menor
        mov r10, 1
	mov [r8],r10d
	jmp _fetch


;################################

ins_Sll:
	call deco_RT
	call deco_RD
         mov rcx, r13 
	shl r10, cl ;corrimiento a la izquierda
	mov [r8],r10d ;write back
	jmp _fetch

ins_Srl:
	call deco_RT
	call deco_RD
         mov rcx, r13
	shr r10,cl ;corrimiento a la derecha
	mov [r8],r10d ;write back
	jmp _fetch

ins_Sub:
	call llamadas_aritmeticas_log
	jmp _fetch

ins_Subu:
	call llamadas_aritmeticas_log
	sub r11,r10 ;operacion de resta
	mov [r8],r11d ;write back
	jmp _fetch

ins_Mult:
	call llamadas_aritmeticas_log
	jmp _fetch

;####################################Funcionamiento de instrucciones tipo I

ins_Addi:
	call llamadas_tipo_I
	mov r10,r12 ;copiar el dato para hacer la máscara
	shr r10,15 ;corrimiento para hacer la máscara
	and r10,1 ;captura el bit de signo
	cmp r10,1 ;si el número es negativo
	je SignExt
	jmp Addi

SignExt:
	or r12,-65536 ;Extiende el signo
	jmp Addi
Addi:
	add r11,r12 ;Operacion de suma
	shl r11,32 ; Corrimientos para eliminación de overflow
	shr r11,32 ;
	mov [r8],r11d ; write back
	jmp _fetch

ins_Andi:
	call llamadas_tipo_I
	and r11,r12 ;operacion de and
	mov [r8],r11d ;write back
	jmp _fetch

ins_Beq:
	call deco_RS
	call deco_RT
	cmp r10,r11 ; comparacione de registros rs y rt
	je branch_address ;salto si es valido
	jmp _fetch

ins_Bne:
	call deco_RS
	call deco_RT
	cmp r10,r11 ; comparaciones de registros rs y rt
	jne branch_address ;salto si es valido
	jmp _fetch

branch_address:
	
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
	jmp _fetch

ins_J:
	add r15, 4
	shr r15, 28
	shl r15, 26 ;toma de los primeros cuatros bits del PC
	or r15, r13 
	shl r15,2 ; calculo de JumpAddress
	jmp _fetch

ins_Jal:
	mov r8,registers ;asigna puntero de arreglo de registros
	shl r10,3 ;alinear direccion
	add r8,31 ;mueve direccion de puntero
	add r15,8
	mov [r8],r15d ; R[31] = PC + 8
	sub r15,8
	jmp ins_J	

ins_Lw:
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
         mov r9, [r9] 
 	mov [r8],r9d ;cargo los datos de la direccion de memoria
	jmp _fetch
	

ins_Ori:
	call llamadas_tipo_I
	or r11,r12 ;operacion de or
	mov [r8],r11d ;write back
	jmp _fetch

ins_Slti:

ins_Sltiu:
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
	shl r12,32 ; Corrimientos 
	shr r12,32 
	cmp r11,r12 ;comparacion
	jge esmayor_sltiu ; verificacion de mayor o menor
        mov r11, 1
	mov [r8],r11d
	jmp _fetch

esmayor_sltiu: ;si si la comparacion da mayor
        mov r11, 0
	mov [r8],r11d ;escribe 0
	jmp _fetch

overflow:
        jmp _exit; !!DEBUG


section .bss
  file_buffer resb BUFFER_SIZE

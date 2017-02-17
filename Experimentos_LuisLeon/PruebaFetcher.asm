%include "io64.inc"
%define SYS_READ 0
%define SYS_OPEN 2
%define SYS_WRITE 1
%define SYS_CLOSE 3
%define STDOUT 1
%define BUFFER_SIZE 1


; Buffer Size en 4 porque son 4x8: 32 bits

section	.data
  ;  ### Parte 1 - Mensaje de buscando archivo ###
  const_buscandoROM_txt: db 'Buscando archivo ROM.txt', 0xa
  const_buscandoROM_size: equ $-const_buscandoROM_txt
  ; ### Parte 2 - Apertura del archivo ###
  file_name db '/home/lleon95/Documentos/ASM/ROM.txt'
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
  
  mov rdx, [file_buffer]        ; Carga el byte en rdx
  shl r8, 8                    ; Mueve el contenido de r13 a la izquierda
  or r8, rdx                   ; Hace r13 = r13 or rdx
  add r10, 1                    ; Siguiente byte (contador)
  cmp r10, 5                    ; Ver si ya se leyeron todos
  jne _fileread                 ; Si no se ha completado, leer proximo

_insertInst:
  ; ### Parte 6 - Verificar overflow de instrucciones (más de 150) ###
  mov r13, r14                  ; Hace copia de los registros totales
  sub r13, r15                  ; Resta de los registros totales con el PC Counter
  cmp r13, 0                    ; Si la resta es menor, hay overflow
  jl _instoverflow

  ; ### Parte 7 - Agregar instrucciones al arreglo de instrucciones ###
  ;mov r13, [file_buffer]        ; Copiar la instruccion en un registro temporal
  mov [r12], r8                ; Añadir la instrucción al arreglo
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
  jmp _fetch ; DEBUG!!
_FormatoI:
  jmp _fetch ; DEBUG!!
_FormatoJ:
  jmp _fetch ; DEBUG!!

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

section .bss
  file_buffer resb BUFFER_SIZE

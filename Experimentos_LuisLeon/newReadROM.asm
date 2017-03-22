%include "io64.inc"
%define SYS_READ 0
%define SYS_OPEN 2
%define SYS_WRITE 1
%define SYS_CLOSE 3
%define STDOUT 1
%define BUFFER_SIZE 1

section	.data
  ;  ### Parte 1 - Mensaje de buscando archivo ###
  const_buscandoROM_txt: db 'Buscando archivo ROM.txt', 0xa
  const_buscandoROM_size: equ $-const_buscandoROM_txt
  ; ### Parte 2 - Apertura del archivo ###
  file_name db '/home/tec/Desktop/Github/proyecto_1_LabMicros_SEM1_2017_Grupo3/ROM_Test.txt'
  ; ### Parte 3 - Comprobación de correcto ###
  fd dw 0

  ; ### Parte X - Mensaje de error FILENOTFOUND ###
  const_filenotfound_txt: db 'Archivo ROM no encontrado', 0xa
  const_filenotfound_size: equ $-const_filenotfound_txt
  ; ### Parte X - Mensaje de info FileFound ###
  const_filefound_txt: db 'Archivo ROM.txt encontrado', 0xa
  const_filefound_size: equ $-const_filefound_txt
  
  INSTRUCTIONS TIMES 150 dd 0   ; Memoria de instrucciones
  DYNAMIC TIMES 200 dd 0        ; Memoria de datos dinámica (RAM)


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
  

  
  
_fileread:
  ; ### Parte 4 - Leer ###
  mov rax, SYS_READ
  mov rdi, [fd]
  mov rsi, file_buffer
  mov rdx, BUFFER_SIZE
  syscall

  ; Ver si se terminó de leer
  cmp rax, 0
  je _exit

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
  cmp r8, 13; Ver si es retorno de carro
  je _fileread
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
    jmp _exit       ; DEBUG
    
  _writeInstruction:
    mov r8, 0
    mov r8w, r14w   ; Copiar los primeros 16 bits  - Recordar eliminar la parte alta de la palabra
    add r8, INSTRUCTIONS
    mov [r8], r15  ; Almacenar como instruccion
    mov r14, 0
    mov r15, 0
    mov r9, 0       ; Restore modo captura
    jmp _fileread
  
  _writeDynamic:
    mov r8, 0
    mov r8w, r14w   ; Copiar los primeros 16 bits de direccion - Recordar eliminar la parte alta de la palabra
    and r8w, 0x7FFF ; Eliminar el 8000 y poner 0000
    add r8, DYNAMIC
    mov [r8], r15   ; Almacenar como dato dinámico
    mov r14, 0
    mov r15, 0
    jmp _fileread
  
  
  jmp _fileread
  jmp _exit

_filefound:
  ; ### Parte X - Mensaje de info - FileFound ###
  mov rax,1						             ;Colocar en modo sys_write
  mov rdi,1					               ;Colocar en consola
  mov rsi,const_filefound_txt		 ;Cargar el mensaje
  mov rdx,const_filefound_size	 ;Tamaño del mensaje
  syscall
  mov r14, 0
  mov r15, 0
  jmp _fileread

_filenotfound:
  ; ### Parte X - Mensaje de error FILENOTFOUND ###
  mov rax,1						             ;Colocar en modo sys_write
  mov rdi,1					               ;Colocar en consola
  mov rsi,const_filenotfound_txt		 ;Cargar el mensaje
  mov rdx,const_filenotfound_size	 ;Tamaño del mensaje
  syscall

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


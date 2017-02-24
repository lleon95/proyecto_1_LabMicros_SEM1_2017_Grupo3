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
  file_name db '/home/lleon95/Documentos/proyecto_1_LabMicros_SEM1_2017_Grupo3/Experimentos_LuisLeon/ROM_Test.txt'
  ; ### Parte 3 - Comprobación de correcto ###
  fd dw 0

  ; ### Parte X - Mensaje de error FILENOTFOUND ###
  const_filenotfound_txt: db 'Archivo ROM no encontrado', 0xa
  const_filenotfound_size: equ $-const_filenotfound_txt
  ; ### Parte X - Mensaje de info FileFound ###
  const_filefound_txt: db 'Archivo ROM.txt encontrado', 0xa
  const_filefound_size: equ $-const_filefound_txt
  STACK TIMES 100 dd 0


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
  cmp r8, 10; Ver si es fin de línea
  je _writeMem

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
    cmp r9, 0
    je _appendAddress
    jmp _appendData
  _appendAddress:
    shl r10, 8  ; Correr direccion para adjuntar byte
    or r10, r8  ; Hacer append
    jmp _fileread
  _appendData:
    shl r11, 8  ; Correr data para adjuntar byte
    or r11, r8  ; Hacer append
    jmp _fileread
  _writeMem:
    add r10, STACK
    mov [r10], r11  ; Almacenar en el Stack
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


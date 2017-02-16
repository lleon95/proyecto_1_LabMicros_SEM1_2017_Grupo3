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
  file_name db '/home/lleon95/Documentos/ASM/ROM.txt'
  ; ### Parte 3 - Comprobación de correcto ###
  fd dw 0

  ; ### Parte X - Mensaje de error FILENOTFOUND ###
  const_filenotfound_txt: db 'Archivo ROM.txt no encontrado', 0xa
  const_filenotfound_size: equ $-const_filenotfound_txt
  ; ### Parte X - Mensaje de info FileFound ###
  const_filefound_txt: db 'Archivo ROM.txt encontrado', 0xa
  const_filefound_size: equ $-const_filefound_txt
  
  ; ### Parte Fetch ###
  instructions TIMES 150 dw -1   ; Cargar de FF el arreglo de instrucciones


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

_startPCCounter:
  mov r15, 0                  ; Inicializar en el PC Counter
  mov r14, 150                       ; Total de instrucciones 

_fileread:
  ; ### Parte 4 - Leer ###
  mov rax, SYS_READ
  mov rdi, [fd]
  mov rsi, file_buffer
  mov rdx, BUFFER_SIZE
  syscall
  
  ; Insertar en el arreglo
  mov r13, r14                  ; Hace copia de los registros totales
  sub r13, r15           ; Resta de los registros totales con el PC Counter
  cmp r13, 0                    ; Si la resta es menor, hay overflow
  jl _exit
  
  ; Agregar instrucciones al arreglo
  mov r13, [file_buffer]
  mov [instructions], r13
  add r15, 1              
  
  ; Ver si se terminó de leer
  cmp rax, 0
  je _exit

  ; Mostrar contenido en consola
  ;mov rdx, rax
  ;mov rax, SYS_WRITE
  ;mov rdi, STDOUT
  ;mov rsi, file_buffer
  ;syscall

  jmp _fileread
  
_filefound:
  ; ### Parte X - Mensaje de info - FileFound ###
  mov rax,1						             ;Colocar en modo sys_write
  mov rdi,1					               ;Colocar en consola
  mov rsi,const_filefound_txt		 ;Cargar el mensaje
  mov rdx,const_filefound_size	 ;Tamaño del mensaje
  syscall
  jmp _startPCCounter

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
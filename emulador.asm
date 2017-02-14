;############################################################
; Para escribir lo requerido en la primera parte del programa
; Fecha: DOM 12/FEB/2017 - 17:30
;#############################################################

;-----Segmento de datos-----

section .data
	const_bienvenido_txt: db 'Bienvenido al Emulador MIPS', 0xa
	const_bienvenido_size: equ $-const_bienvenido_txt
	const_curso_txt: db 'EL-4313 - Lab. Estructura de Microprocesadores - 1S2017', 0xa
	const_curso_size: equ $-const_curso_txt
	const_headers_txt: db '##############################################################', 0xa
	const_headers_size: equ $-const_headers_txt

;-----Segmento de datos-----

section .text
	global _start ; Iniciará con _welcome

_start:
	; ### Parte 1 - Headers o Gatos ###
	mov rax,1						;Colocar en modo sys_write
	mov rdi,1						;Colocar en consola
	mov rsi,const_headers_txt				;Cargar los headers para imprimirlos
	mov rdx,const_headers_size				;Tamaño de los headers
	syscall							;Ejecutar
	; ### Parte 2 - Texto de Bienvenido ###
	mov rax,1 						; Colocar en modo sys_write
	mov rdi,1 						; Colocar en consola
	mov rsi,const_bienvenido_txt			 	; Colocar el texto a imprimir -  Bienvenido
	mov rdx,const_bienvenido_size				; Colocar el tamaño del texto - Bienvenido
	syscall
	; ### Parte 3 - Texto de Curso ###
	mov rax,1						; Colocar en modo sys_write
	mov rdi,1                                               ; Colocar en consola
        mov rsi,const_curso_txt         	                ; Colocar el texto a imprimir - Curso
        mov rdx,const_curso_size      	                        ; Colocar el tamaño del texto - Curso
	syscall
        ; ### Parte 4  - Headers o Gatos ###
        mov rax,1                                               ;Colocar en modo sys_write
        mov rdi,1                                               ;Colocar en consola
        mov rsi,const_headers_txt                               ;Cargar los headers para imprimirlos
        mov rdx,const_headers_size                              ;Tamaño de los headers
        syscall

	; ### Salida provisional ###
	; ### Exit ###
	mov rax,60						; Salir del sistema sys_exit
	mov rdi,0
	syscall

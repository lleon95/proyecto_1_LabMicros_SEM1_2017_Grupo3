;############################################################
; Para escribir lo requerido en la primera parte del programa
; Hecho por: LLEON
; Fecha: DOM 12/FEB/2017 - 17:30
;#############################################################

;-----Segmento de datos-----

section .data
	const_bienvenido_txt: db 'Bienvenido al Emulador MIPS', 0xa
	const_curso_txt: db 'EL-4313 - Lab. Estructura de Microprocesadores - 1S2017', 0xa
	const_bienvenido_size: equ $-const_bienvenido_txt
	const_curso_size: equ $-const_curso_txt

;-----Segmento de datos-----

section .text
	global _start ; Iniciará con _welcome

_start:
	; ### Parte 1 - Texto de Bienvenido ###
	mov rax,1 						; Colocar en modo sys_write
	mov rdi,1 						; Colocar en consola
	mov rsi,const_bienvenido_txt 	; Colocar el texto a imprimir -  Bienvenido
	mov rdx,const_bienvenido_size	; Colocar el tamaño del texto - Bienvenido
	syscall
	mov rax,60						; Salir del sistema sys_exit
	mov rdi,0
	syscall


;##############################################
;Ejemplo#2 - HolaMundo con etiquetas para usar GBD (debugger)
;EL4313 - Laboratorio de Estructura de Microprocesadores
;2S2016-LCRA
;##############################################
;Este programa muestra el uso de etiquetas que luego se pueden
;usar como referencias para depuracion (debug) del codigo
;usando GDB. 
;Refierase al documento guia para mas instrucciones
;##############################################

;--------------------Segmento de datos--------------------
;Se declaran 2 constantes de texto

section .data
	linea_uno: db 'Hola mundo! Primera linea',0xa	;Primera linea a imprimir	
	l1_tamano: equ $-linea_uno

	linea_dos: db 'Hola mundo! Segunda linea',0xa	;Segunda linea a imprimir	
	l2_tamano: equ $-linea_dos


;--------------------Segmento de codigo--------------------
;Contiene la secuencia de ejecucion del programa

section .text
	global _start				;Definicion de la etiqueta inicial
	global _segunda			;Definicion de la etiqueta #2
	global _tercera			;Definicion de la etiqueta #3

_start:
	;Primer paso: Imprimir la primera linea
	mov rax,1					;rax = sys_write (1) 
	mov rdi,1					;rdi = 1
	mov rsi,linea_uno		;rsi = linea_uno
	mov rdx,l1_tamano		;rdx = tamano de linea_uno
	syscall						;Llamar al sistema

	;Imprimir la segunda linea
	mov rax,1					;rax = sys_write (1) 
	mov rdi,1					;rdi = 1
	mov rsi,linea_dos			;rsi = linea_dos
	mov rdx,l2_tamano		;rdx = tamano de linea_uno
_segunda:						;detiene la ejecucion con GDB para visualizar los valores en los registros
	syscall						;Llamar al sistema

	;liberar los recursos
	mov rax,60			;rax=sys_exit (60)
	mov rdi,0				;rdi=0
_tercera:					;detiene la ejecucion con GDB para visualizar los valores en los registros
	syscall					;Llamar al sistema

;fin del programa
;##############################################
	

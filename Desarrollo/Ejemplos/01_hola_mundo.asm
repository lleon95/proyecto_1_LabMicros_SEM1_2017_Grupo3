;##############################################
;Ejemplo#1 - HolaMundo con Ensamblador de 64-bits (usando Linux)
;EL4313 - Laboratorio de Estructura de Microprocesadores
;2S2016-LCRA
;##############################################
;Este programa simplemente imprime un mensaje "hola mundo" a 
;la pantalla del sistema, usando la llamada sys_write al sistema
;##############################################

;--------------------Segmento de datos--------------------
;Aqui se declaran las constantes que se van a usar en el programa

section .data
	cons_hola: db 'Hola mundo!',0xa		; Texto que se desea imprimir
	cons_tamano: equ $-cons_hola			; Longitud del texto


;--------------------Segmento de codigo--------------------
;Contiene la secuencia de ejecucion del programa
;La ejecucion inicia en "_start", que es una etiqueta o referencia

section .text
	global _start		;Definicion de la etiqueta inicial

_start:
	mov rax,1					;rax debe contener la llamada de sistema que se va a usar. 
								;Se debe usar la llamada de sistema de 64 bits para Linux
								;En este caso, el 1(decimal) es la llamada "sys_write"

	mov rdi,1					;rdi contiene el primer argumento que se pasa a la llamada de sistema
								;en rax. Un 1 indica que se imprime en la consola default del sistema

	mov rsi,cons_hola		;rsi contiene el segundo argumento que se pasa a la llamada de sistema 
								;En este caso, el texto a imprimir

	mov rdx,cons_tamano	;rdx contiene el tercer argumento que se pasa a la llamada de sistema
								; en rax. En este caso, el tamano del texto

	syscall						;luego de cargar los argumentos, se llama al sistema 
								;para ejecutar la operacion que se configuro via registros


	;Luego de completar la primera operacion, se deben recargar registros con las condiciones para
	;la siguiente operacion, en este caso, la siguiente operacion consiste en liberar los recursos del 
	;sistema para terminar el programa sin que se de un error de segmentacion (segmentation fault)

	mov rax,60				;se carga la llamada 60d (sys_exit) en rax
	mov rdi,0					;en rdi se carga un 0
	syscall						;se llama al sistema.

;fin del programa
;##############################################	

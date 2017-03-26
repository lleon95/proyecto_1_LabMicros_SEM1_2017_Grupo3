;##############################################
;Ejemplo#3 - Captura desde teclado (y muestra en pantalla)
;EL4313 - Laboratorio de Estructura de Microprocesadores
;2S2016-LCRA
;##############################################
;Este programa muestra el uso de las llamadas a sistema sys_write
;y sys_read para capturar una tecla presionada por el usuario y luego
;imprimirla en la pantalla
;##############################################

;--------------------Segmento de datos--------------------
;Aqui se declaran las etiquetas de uso frecuente en el programa

section .data
	cons_banner: db 'Presione una tecla, y luego Enter:  '		; Banner para el usuario
	cons_tamano_banner: equ $-cons_banner					; Longitud del banner

	cons_salida: db 'Usted presiono la tecla:  '					; Banner para el usuario
	cons_tamano_salida: equ $-cons_salida					; Longitud del banner

	cons_final: db 0xa,'Fin del programa. ',0xa					; Banner para el usuario
	cons_tamano_final: equ $-cons_final						; Longitud del banner

	variable: db''													;Almacenamiento de la tecla capturada


;--------------------Segmento de codigo--------------------
;Secuencia de ejecucion del programa

section .text
	global _start		;Definicion del punto de partida

_start:
	;Primer paso: Imprimir el banner de bienvenida
	mov rax,1							;rax = "sys_write"
	mov rdi,1							;rdi = 1 (standard output = pantalla)
	mov rsi,cons_banner				;rsi = mensaje a imprimir
	mov rdx,cons_tamano_banner	;rdx=tamano del string
	syscall								;Llamar al sistema

	;Segundo paso: Capturar una tecla presionada en el teclado
	mov rax,0							;rax = "sys_read"
	mov rdi,0							;rdi = 0 (standard input = teclado)
	mov rsi,variable					;rsi = direccion de memoria donde se almacena la tecla capturada
	mov rdx,1							;rdx=1 (cuantos eventos o teclazos capturar)
	syscall								;Llamar al sistema

	;Tercer paso: Imprimir el banner de salida
	mov rax,1							;rax = "sys_write"
	mov rdi,1							;rdi = 1 (standard output = pantalla)
	mov rsi,cons_salida				;rsi = mensaje a imprimir
	mov rdx,cons_tamano_salida	;rdx=tamano del string
	syscall								;Llamar al sistema

	;Cuarto paso: Imprimir la tecla capturada
	mov rax,1							;rax = "sys_write"
	mov rdi,1							;rdi = 1 (standard output = pantalla)
	mov rsi,variable					;rsi = mensaje a imprimir
	mov rdx,1							;rdx=solo se imprime 1 byte
	syscall								;Llamar al sistema

	;Quinto paso: Imprimir final del programa
	mov rax,1							;rax = "sys_write"
	mov rdi,1							;rdi = 1 (standard output = pantalla)
	mov rsi,cons_final				;rsi = mensaje a imprimir
	mov rdx,cons_tamano_final		;rdx=solo se imprime 1 byte
	syscall								;Llamar al sistema

	;Sexto paso: Salida del programa
	mov rax,60						;se carga la llamada 60d (sys_exit) en rax
	mov rdi,0							;en rdi se carga un 0
	syscall								;se llama al sistema.

;fin del programa
;##############################################	

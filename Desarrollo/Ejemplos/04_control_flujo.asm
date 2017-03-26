;##############################################
;Ejemplo#4 - Control de flujo
;EL4313 - Laboratorio de Estructura de Microprocesadores
;2S2016-LCRA
;##############################################
;Este programa muestra el uso de condiciones y comparaciones
;entre registros para realizar la toma de deciciones o control del
;flujo de ejecucion del programa
;##############################################

;--------------------Segmento de datos--------------------
;Aqui se declaran las etiquetas de uso frecuente en el programa

section .data
	;Definicion de constantes
	;Las constantes no cambian durante el programa. Son valore estaticos
	;En este ejemplo, se definen 2 numeros como constantes, que se van a 
	;usar para realizar calculos aritmeticos simples

	num1: equ 100									;Primer numero: 100
	num2: equ 50										;Segundo numero: 50

	msj_1: db 'Este es el primer bloque de codigo. ',0xa		; Mensaje para el usuario
	tamano_msj_1: equ $-msj_1									; Longitud del mensaje

	msj_2: db 'Este es el segundo bloque de codigo. ',0xa		; Mensaje para el usuario
	tamano_msj_2: equ $-msj_2									; Longitud del mensaje

	msj_3: db 'Este es el tercer  bloque de codigo. ',0xa		; Mensaje para el usuario
	tamano_msj_3: equ $-msj_3									; Longitud del mensaje

;--------------------Segmento de codigo--------------------
;Secuencia de ejecucion del programa

section .text
	global _start		;Definicion del punto de partida

;---------------------------------------------------------------------------------------------------------------------
;En este programa, se va a ejecutar el codigo en segmentos separados
;a diferencia de los anteriores, se usan saltos para moverse en orden 
;diferente al orden secuencial.
;Para esto, se usan etiquetas que indican los fragmentos de codigo
;
;---------------------------------------------------------------------------------------------------------------------
_start:

	;Primer bloque de codigo
.primer_bloque:
	mov rax,1							;rax = "sys_write"
	mov rdi,1							;rdi = 1 (standard output = pantalla)
	mov rsi,msj_1						;rsi = mensaje a imprimir
	mov rdx,tamano_msj_1			;rdx=tamano del mensaje
	syscall								;Llamar al sistema

	;Se va a realizar una comparacion entre num1 y num2
	;si son iguales, pasa al bloque 2, si son diferentes al bloque 3
	mov rax,num1
	mov rbx,num2
	cmp rax,rbx
	je .segundo_bloque
	jne .tercer_bloque

.segundo_bloque	:
	mov rax,1							;rax = "sys_write"
	mov rdi,1							;rdi = 1 (standard output = pantalla)
	mov rsi,msj_2						;rsi = mensaje a imprimir
	mov rdx,tamano_msj_2			;rdx=tamano del mensaje
	syscall								;Llamar al sistema

	;Para forzar al programa a terminar luego de ejecutar el bloque 2 
	;se hace una comparacion entre num1 y num2
	mov rax,num1
	mov rbx,num2
	cmp rax,rbx
	jg .final

.tercer_bloque:
	mov rax,1							;rax = "sys_write"
	mov rdi,1							;rdi = 1 (standard output = pantalla)
	mov rsi,msj_3						;rsi = mensaje a imprimir
	mov rdx,tamano_msj_3			;rdx=tamano del mensaje
	syscall								;Llamar al sistema

	;Para forzar al programa a regresar al bloque 2, se hace una 
	;comparacion entre num1 y num1
	mov rax,num1
	mov rbx,num1
	cmp rax,rbx
	je .segundo_bloque
	jne .tercer_bloque

.final:

	;Salida del programa
	mov rax,60						;se carga la llamada 60d (sys_exit) en rax
	mov rdi,0							;en rdi se carga un 0
	syscall								;se llama al sistema.

;fin del programa
;##############################################	

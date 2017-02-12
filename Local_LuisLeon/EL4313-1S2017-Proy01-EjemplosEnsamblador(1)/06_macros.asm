;#######################################################################
;Ejemplo#6 - Uso de Macros para agrupar funcionalidades de uso frecuente
;EL4313 - Laboratorio de Estructura de Microprocesadores
;2S2016-LCRA
;#######################################################################
;Este programa contiene ejemplos de uso de macros para manejar 
;funcionalidades frecuentes como si fueran funciones con paso de 
;parametros
;Las macros de ejemplo se usan para imprimir una forma muy basica de la
;pantalla de juego Arkanoid
;#######################################################################


;######################## SEGMENTO DE MACROS ###########################
;Las macros, son funciones que reciben parametros de entrada y ejecutan
;acciones sobre esos parametros.
;Se debe indicar el numero de parametros de entrada y ejecutar las 
;operaciones en la macro. Luego, se puede llamar la macro desde el
;programa principal

;Ejemplos de Macros:

;-------------------------  MACRO #1  ----------------------------------
;Macro-1: impr_texto.
;	Imprime un mensaje que se pasa como parametro
;	Recibe 2 parametros de entrada:
;		%1 es la direccion del texto a imprimir
;		%2 es la cantidad de bytes a imprimir
;-----------------------------------------------------------------------
%macro impr_texto 2 	;recibe 2 parametros
	mov rax,1	;sys_write
	mov rdi,1	;std_out
	mov rsi,%1	;primer parametro: Texto
	mov rdx,%2	;segundo parametro: Tamano texto
	syscall
%endmacro
;------------------------- FIN DE MACRO --------------------------------


;-------------------------  MACRO #2  ----------------------------------
;Macro-2: leer_texto.
;	Lee un mensaje desde teclado y se almacena en la variable que se
;	pasa como parametro
;	Recibe 2 parametros de entrada:
;		%1 es la direccion de memoria donde se guarda el texto
;		%2 es la cantidad de bytes a guardar
;-----------------------------------------------------------------------
%macro leer_texto 2 	;recibe 2 parametros
	mov rax,0	;sys_read
	mov rdi,0	;std_input
	mov rsi,%1	;primer parametro: Variable
	mov rdx,%2	;segundo parametro: Tamano 
	syscall
%endmacro
;------------------------- FIN DE MACRO --------------------------------

;-------------------------  MACRO #3  ----------------------------------
;Macro-3: limpiar_pantalla.
;	Limpa la pantalla de texto
;	Recibe 2 parametros:
;		%1 es la direccion de memoria donde se guarda el texto
;		%2 es la cantidad de bytes a guardar
;-----------------------------------------------------------------------
%macro limpiar_pantalla 2 	;recibe 2 parametros
	mov rax,1	;sys_write
	mov rdi,1	;std_out
	mov rsi,%1	;primer parametro: caracteres especiales para limpiar la pantalla
	mov rdx,%2	;segundo parametro: Tamano 
	syscall
%endmacro
;------------------------- FIN DE MACRO --------------------------------

;-------------------------  MACRO #4  ----------------------------------
;Macro-4: leer stdin_termios.
;	Captura la configuracion del stdin
;	recibe 2 parametros:
;		%1 es el valor de stdin
;		%2 es el valor de termios
;-----------------------------------------------------------------------
%macro read_stdin_termios 2
        push rax
        push rbx
        push rcx
        push rdx

        mov eax, 36h
        mov ebx, %1
        mov ecx, 5401h
        mov edx, %2
        int 80h

        pop rdx
        pop rcx
        pop rbx
        pop rax
%endmacro
;------------------------- FIN DE MACRO --------------------------------


;-------------------------  MACRO #5  ----------------------------------
;Macro-5: escribir stdin_termios.
;	Captura la configuracion del stdin
;	recibe 2 parametros:
;		%1 es el valor de stdin
;		%2 es el valor de termios
;-----------------------------------------------------------------------
%macro write_stdin_termios 2
        push rax
        push rbx
        push rcx
        push rdx

        mov eax, 36h
        mov ebx, %1
        mov ecx, 5402h
        mov edx, %2
        int 80h

        pop rdx
        pop rcx
        pop rbx
        pop rax
%endmacro
;------------------------- FIN DE MACRO --------------------------------


;-------------------------  MACRO #6  ----------------------------------
;Macro-6: apagar el modo canonico.
;	Apaga el modo canonico del Kernel
;	recibe 2 parametros:
;		%1 es el valor de ICANON
;		%2 es el valor de termios
;-----------------------------------------------------------------------
%macro canonical_off 2
	;Se llama a la funcion que lee el estado actual del TERMIOS en STDIN
	;TERMIOS son los parametros de configuracion que usa Linux para STDIN
        read_stdin_termios stdin,termios

	;Se escribe el nuevo valor de ICANON en EAX, para apagar el modo canonico
        push rax
        mov eax, %1
        not eax
        and [%2 + 12], eax
        pop rax

	;Se escribe la nueva configuracion de TERMIOS
        write_stdin_termios stdin,termios
%endmacro
;------------------------- FIN DE MACRO --------------------------------
        
	
;-------------------------  MACRO #7  ----------------------------------
;Macro-6: encender el modo canonico.
;	Recupera el modo canonico del Kernel
;	recibe 2 parametros:
;		%1 es el valor de ICANON
;		%2 es el valor de termios
;-----------------------------------------------------------------------
%macro canonical_on 2

	;Se llama a la funcion que lee el estado actual del TERMIOS en STDIN
	;TERMIOS son los parametros de configuracion que usa Linux para STDIN
	read_stdin_termios stdin,termios

        ;Se escribe el nuevo valor de modo Canonico
        or dword [%2 + 12], %1

	;Se escribe la nueva configuracion de TERMIOS
        write_stdin_termios stdin,termios
%endmacro
;----------------------------------------------------

;#######################################################################


;######################## SEGMENTO DE DATOS ############################
;Se declaran algunos strings que constituyen los bloques de construccion
;de la pantalla de juego Arkanoid
section .data
	;Definicion de las lineas especiales de texto para diujar el area de juego
	linea_techo: 		db '===============================================================', 0xa
	linea_blanco: 		db '|                                                             |', 0xa
	linea_bloque: 		db '|  ########  ########  ########  ########  ########  ######## |', 0xa
	linea_cubo: 		db '|                             ###                             |', 0xa
	linea_plataforma:	db '|                          =========                          |', 0xa
	linea_piso:		db '|^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^|', 0xa
	
	;Definicion de los mensajes especiales en lineas de texto para mostrar en el area de juego
	linea_bienvenida:	db '|                    Presione X para iniciar                  |', 0xa
	linea_vida_menos:	db '|         Perdio una vida - Presione X para continuar         |', 0xa
	linea_game_over:	db '|         Fin del Juego   - Presione X para continuar         |', 0xa
	
	;Todas las lineas anteriores son del mismo tamano, por lo que se maneja como una constante
	tamano_linea: 		equ 64
		
	;Definicion de los caracteres especiales para limpiar la pantalla
	limpiar    db 0x1b, "[2J", 0x1b, "[H"
	limpiar_tam equ $ - limpiar
	
	;Definicion de constantes para manejar el modo canonico y el echo
	termios:	times 36 db 0	;Estructura de 36bytes que contiene el modo de operacion de la consola
	stdin:		equ 0		;Standard Input (se usa stdin en lugar de escribir manualmente los valores)
	ICANON:		equ 1<<1	;ICANON: Valor de control para encender/apagar el modo canonico
	ECHO:           equ 1<<3	;ECHO: Valor de control para encender/apagar el modo de eco


;segmento de datos no-inicializados, que se pueden usar para capturar variables 
;del usuario, por ejemplo: desde el teclado
section .bss
	tecla_capturada: resb 1
;#######################################################################


;######################## SEGMENTO DE CODIGO ###########################

;---------- Ejecucion del programa principal -----------------------
section .text
	global _start		;Definicion de la etiqueta inicial

_start:
	;Apagar el modo canonico
	canonical_off ICANON,termios
	
	;Limpiar la pantalla
	limpiar_pantalla limpiar,limpiar_tam
	
	
	;Imprimir la pantalla de bienvenida usando los textos previamente definidos
	_bienvenida:
		impr_texto linea_techo,tamano_linea
		impr_texto linea_blanco,tamano_linea
		;se hace un loop para imprimir 3 lineas de tipo "linea_bloque"
		mov r8,0
		loop_1:
			impr_texto linea_bloque,tamano_linea
			inc r8
			cmp r8,0x3
			jne loop_1
		;se hace un loop para imprimir 5 lineas de tipo "linea_blanco"
		mov r8,0
		loop_2:
			impr_texto linea_blanco,tamano_linea
			inc r8
			cmp r8,0x5
			jne loop_2
			
		;se imprime el mensaje de bienvenida
		impr_texto linea_bienvenida,tamano_linea
		;se hace un loop para imprimir 5 lineas de tipo "linea_blanco"
		mov r8,0
		loop_3:
			impr_texto linea_blanco,tamano_linea
			inc r8
			cmp r8,0x5
			jne loop_3
				
		;se imprimen 2 lineas de tipo linea_cubo
		impr_texto linea_cubo,tamano_linea
		impr_texto linea_cubo,tamano_linea
		;se imprime la linea de la plataforma
		impr_texto linea_plataforma,tamano_linea
		;se imprime la linea del piso
		impr_texto linea_blanco,tamano_linea
		impr_texto linea_piso,tamano_linea
	
	;Se captura una tecla cualquiera, para probar la Macro #2.
	;En realidad, se puede agregar soporte para hacer comparaciones
	;y detectar si la tecla presionada es la X.
	_leer_opcion:
		leer_texto tecla_capturada,1
	
	;Luego que el usuario presiona una tecla, se limpia nuevamente
	;la pantalla y se imprime la pantalla de juego.
	;En este caso, es solamente como medio de pruebas. Luego de 
	;imprimir la pantalla de juego, se termina el programa
	_pantalla_juego:
		limpiar_pantalla limpiar,limpiar_tam
		
		impr_texto linea_techo,tamano_linea
		impr_texto linea_blanco,tamano_linea
		;se hace un loop para imprimir 3 lineas de tipo "linea_bloque"
		mov r8,0
		loop_4:
			impr_texto linea_bloque,tamano_linea
			inc r8
			cmp r8,0x3
			jne loop_4
		;se hace un loop para imprimir 11 lineas de tipo "linea_blanco"
		mov r8,0
		loop_5:
			impr_texto linea_blanco,tamano_linea
			inc r8
			cmp r8,0x0B
			jne loop_5
			
		;se imprimen 2 lineas de tipo linea_cubo
		impr_texto linea_cubo,tamano_linea
		impr_texto linea_cubo,tamano_linea
		;se imprime la linea de la plataforma
		impr_texto linea_plataforma,tamano_linea
		;se imprime la linea del piso
		impr_texto linea_blanco,tamano_linea
		impr_texto linea_piso,tamano_linea
	
	;Recuperar el modo canonico
	canonical_on ICANON,termios

	;Finalmente, se devuelven los recursos del sistema
	;y se termina el programa
		mov rax,60	;se carga la llamada 60d (sys_exit) en rax
		mov rdi,0	;en rdi se carga un 0
		syscall	
	
;#######################################################################
;######################## FIN DEL PROGRAMA #############################
;#######################################################################
;imprimir y buscar la ROM

section .data
	const_buscandoROM_txt: db 'Buscando archivo ROM.txt', 0xa
	const_buscandoROM_size: equ $-const_buscandoROM_txt
	const_verif_txt: db 'gracias, hacker' ,0xa
	const_verif_size: equ $-const_verif_txt
	tecla: db ''
	termios:        times 36 db 0									;Estructura de 36bytes que contiene el modo de operacion de la consola
	stdin:          	  equ 0												;Standard Input (se usa stdin en lugar de escribir manualmente los valores)
	;ICANON:      equ 1<<1											;ICANON: Valor de control para encender/apagar el modo canonico
	ECHO:           equ 1<<3											;ECHO: Valor de control para encender/apagar el modo de eco
;echo_off
;Esta es una funcion que sirve para apagar el modo echo en Linux
;Cuando el modo echo se apaga, Linux NO muestra en la pantalla la tecla que
;se acaba de presionar.
;
;Para apagar el modo echo, simplemente use: call echo_off
;###################################################
echo_off:

	;Se llama a la funcion que lee el estado actual del TERMIOS en STDIN
	;TERMIOS son los parametros de configuracion que usa Linux para STDIN
        call read_stdin_termios

        ;Se escribe el nuevo valor de ECHO en EAX para apagar el echo
        push rax
        mov eax, ECHO
        not eax
        and [termios+12], eax
        pop rax

	;Se escribe la nueva configuracion de TERMIOS
        call write_stdin_termios
        ret
        ;Final de la funcion
;###################################################
;####################################################
;write_stdin_termios
;Esta es una funcion que sirve para escribir la configuracion actual del stdin o 
;teclado directamente de Linux
;Esta configuracion se conoce como TERMIOS (Terminal Input/Output Settings)
;Los valores del stdin se cargan con EAX=36h y llamada a la interrupcion 80h
;
;Para utilizarlo, simplemente se usa: call write_stdin_termios
;###################################################
write_stdin_termios:
        push rax
        push rbx
        push rcx
        push rdx

        mov eax, 36h
        mov ebx, stdin
        mov ecx, 5402h
        mov edx, termios
        int 80h

        pop rdx
        pop rcx
        pop rbx
        pop rax
        ret
        ;Final de la funcion
;###################################################
;####################################################
;read_stdin_termios
;Esta es una funcion que sirve para leer la configuracion actual del stdin o 
;teclado directamente de Linux
;Esta configuracion se conoce como TERMIOS (Terminal Input/Output Settings)
;Los valores del stdin se cargan con EAX=36h y llamada a la interrupcion 80h
;
;Para utilizarlo, simplemente se usa: call read_stdin_termios
;###################################################
read_stdin_termios:
        push rax
        push rbx
        push rcx
        push rdx

        mov eax, 36h
        mov ebx, stdin
        mov ecx, 5401h
        mov edx, termios
        int 80h

        pop rdx
        pop rcx
        pop rbx
        pop rax
        ret
        ;Final de la funcion
;###################################################

section .text

	global _start ; Iniciará con _welcome

_start:
	mov rax,1						;Colocar en modo sys_write
	mov rdi,1						;Colocar en consola
	mov rsi,const_buscandoROM_txt				;Cargar los headers para imprimirlos
	mov rdx,const_buscandoROM_size				;Tamaño de los headers
	syscall

;capturar tecla
	call echo_off
	mov rax,0
	mov rdi,0
	mov rsi,tecla
	mov rdx,1
	syscall

;#######Prueba#########
 mov rax,1						;Colocar en modo sys_write
	mov rdi,1						;Colocar en consola
	mov rsi,const_verif_txt				;Cargar los headers para imprimirlos
	mov rdx,const_verif_size				;Tamaño de los headers
	syscall

; ### Exit ###
	mov rax,60						; Salir del sistema sys_exit
	mov rdi,0
	syscall

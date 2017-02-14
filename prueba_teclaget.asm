;imprimir y buscar la ROM

section .data
	const_buscandoROM_txt: db 'Buscando archivo ROM.txt', 0xa
	const_buscandoROM_size: equ $-const_buscandoROM_txt
	const_verif_txt: db 'gracias, hacker' ,0xa
	const_verif_size: equ $-const_verif_txt
	tecla: db ''
section .text

	global _start ; Iniciará con _welcome

_start:
	mov rax,1						;Colocar en modo sys_write
	mov rdi,1						;Colocar en consola
	mov rsi,const_buscandoROM_txt				;Cargar los headers para imprimirlos
	mov rdx,const_buscandoROM_size				;Tamaño de los headers
	syscall

;capturar tecla
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

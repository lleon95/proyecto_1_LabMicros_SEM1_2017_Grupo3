;Imprimir Fabricante, Modelo, Familia, Tipo, y Porcentaje de utilización

 section .data

   const_fabricante_txt: db 'Fabricante: ', 0xa
   const_fabricante_size: equ $-const_fabricante_txt

   const_modelo_txt: db 'Modelo: ', 0xa
   const_modelo_size: equ $-const_modelo_txt

   const_familia_txt: db 'Familia: ', 0xa
   const_familia_size: equ $-const_familia_txt

   const_tipo_txt: db 'Tipo: ', 0xa
   const_tipo_size: equ $-const_tipo_txt

   const_pu_txt: db 'Porcentaje de Utilización: ', 0xa
   const_pu_size: equ $-const_pu_txt

 
 section .bss
   fabricante       resd  12 ; reservar 12 bytes   
   modelo           resd  8  ; reservar 8 bytes

 
 section .txt
   global _start
   newline db 0x0a

 _start:


;####################### FABRICANTE ########################

mov eax,0
cpuid  ; obtener id del fabricante


mov [fabricante],ebx        ; guardar resultado en ‘fabricante’
mov [fabricante+4],edx
mov [fabricante+8],ecx

       ; Imprimir el resultado

mov rax,1
mov rdi,1
mov rsi,const_fabricante_txt
mov rdx,const_fabricante_size
syscall


mov edx,12		  ;message length
mov ecx,fabricante	;message to write (msg is a pointer to the start of the string)
mov ebx,1	           ;file descriptor (stdout)
mov eax,4	           ;system call number (sys_write)
int 0x80	           ; system call

        ; Write out newline (\n)
mov edx, 1
mov ecx, newline
mov ebx,1
mov eax,4
int 0x80



;####################### MODELO ########################

mov eax,1
cpuid     ; get the model name

mov r8d, eax
shr r8, 4
and r8, 0xf
mov r9d, eax
shr r9, 12
and r9, 0xf0
or r8, r9
mov [modelo], r8

; Imprimir el resultado
mov rax,1
mov rdi,1
mov rsi,const_modelo_txt
mov rdx,const_modelo_size
syscall

mov edx,2		  ;message length
mov ecx,modelo	;message to write (msg is a pointer to the start of the string)
mov ebx,1	           ;file descriptor (stdout)
mov eax,4	           ;system call number (sys_write)
int 0x80	           ; system call 




mov eax,1	  ;system call number (sys_exit)
mov ebx,0	;exit status 0 (if not used is 1 as set before) "echo $?" to check
int 0x80	; system exit

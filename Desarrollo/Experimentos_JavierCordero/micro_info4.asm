;Imprimir Fabricante, Modelo, Familia, Tipo, y Porcentaje de utilización
%include "io64.inc"

%macro bth 1
    mov r8, %1
    mov r9,r8
    and r8,0xf
    shr r9,4
    cmp r8,10
    jge %%sumar8
 %%ret1:
    cmp r9,10
    jge %%sumar9
 %%ret2:
    add r8,48
    add r9,48
    jmp %%end
    
  %%sumar8:
    add r8,7
    jmp %%ret1
  %%sumar9:
    add r9,7
    jmp %%ret2  
   
  %%end:
%endmacro

%macro impr_texto 2
    mov rax,1
    mov rdi,1
    mov rsi,%1 ;texto
    mov rdx,%2 ;len
    syscall
%endmacro
    
    


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
   familia          resd  8  ; reservar 8 bytes
   tipo             resd  8  ; reservar 8 bytes
   pu               resd  8  ; reservar 8 bytes

 
 section .txt
   global CMAIN
   newline db 0x0a




 CMAIN:
    mov rbp, rsp; for correct debugging


;####################### FABRICANTE ########################

mov eax,0
cpuid  ; obtener id del fabricante

mov [fabricante],ebx        ; guardar resultado en ‘fabricante’
mov [fabricante+4],edx
mov [fabricante+8],ecx

; Imprimir el resultado
impr_texto const_fabricante_txt,const_fabricante_size
impr_texto fabricante,12
impr_texto newline,1



;####################### MODELO ############################

mov eax,1
cpuid     ; get the model name

mov r8d, eax
shr r8, 4
and r8, 0xf
mov r9d, eax
shr r9, 12
and r9, 0xf0
or r8, r9
bth r8
mov [modelo], r9
mov [modelo+1],r8

; Imprimir el resultado
impr_texto const_modelo_txt, const_modelo_size
impr_texto modelo,2
impr_texto newline,1



;####################### FAMILIA ############################

mov eax,1
cpuid     

mov r8d, eax
shr r8, 8
and r8, 0xf
mov r9d, eax
shr r9, 16
and r9, 0xf0
or r8, r9
bth r8
mov [familia], r9
mov [familia+1],r8

; Imprimir el resultado
impr_texto const_familia_txt, const_familia_size
impr_texto familia,2
impr_texto newline,1




;####################### TIPO ############################

mov eax,1
cpuid     

mov r8d, eax
shr r8, 12
and r8, 0x3

bth r8
mov [tipo], r9
mov [tipo+1],r8

; Imprimir el resultado
impr_texto const_tipo_txt, const_tipo_size
impr_texto tipo,2
impr_texto newline,1





mov rax,60	  ;system call number (sys_exit)
mov rdi,0	;exit status 0 (if not used is 1 as set before) "echo $?" to check
syscall	; system exit

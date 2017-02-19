;cases de intrucciones


section .data

;################# seccion carga de datos
deco_RS:
	mov r8,registers ;asigna puntero de arreglo de registros
	shl r11,3 ;alinear direccion
	add r8,r11 ;mueve direccion de puntero
 	mov r11,[r8] ;cargo los datos de la direccion de memoria
	ret

deco_RT:
	mov r8,registers ;asigna puntero de arreglo de registros
	shl r10,3 ;alinear direccion
	add r8,r10 ;mueve direccion de puntero
	mov r10,[r8] ;cargo los datos de la direccion de memoria
	ret

deco_RD:
	mov r8,registers ;asigna puntero de arreglo de registros
	shl r12,3 ;alinear direccion
	add r8,r12 ;mueve direccion de puntero
	ret

deco_RT_I:
	mov r8,registers ;asigna puntero de arreglo de registros
	shl r10,3 ;alinear direccion
	add r8,r10 ;mueve direccion de puntero
	ret

llamadas_aritmeticas_log: ; llamadas para carga de registros cuando Rd es destino
	call deco_RS
	call deco_RT
	call deco_RD
	ret

llamadas_tipo_I: ;llamada para carga de registros cuando Rt es destino
	call deco_RS
	call deco_RT_I
	ret

; ###################### OPcode
;instrucciones R
	cmp r8,0 ;identifica instrucciones tipo R
	je function_R
	cmp r8,0x8 ;identifica Addi
	je ins_Addi
	cmp r8,0xc ;identifica Andi
	je ins_Andi
	cmp r8,0x4 ;identifica Beq
	je ins_Beq
	cmp r8,0x5 ;identifica Bne
	je ins_Bne
	cmp r8,0x2 ;identifica J
	je ins_J
	cmp r8,0x3 ;identifica Jal
	je ins_Jal
	cmp r8,0x23 ;identifica Lw
	je ins_Lw
	cmp r8,0xd ;identifica Ori
	je ins_Ori
	cmp r8,0xa ;identifica Slti
	je ins_Slti
	cmp r8,0xb ;identifica Sltiu
	je ins_Sltiu
;############################
function_R:
	cmp r9,0x20 ;identifica Add
	je ins_Add
	cmp r9,0x21 ;identifica Addu
	je ins_Addu
	cmp r9,0x24 ;identifica And
	je ins_And
	cmp r9,0x08 ;identifica Jr
	je ins_Jr
	cmp r9,0x27 ;identifica Nor
	je ins_Nor
	cmp r9,0x25 ;identifica Or
	je ins_Or
	cmp r9,0x2a ;identifica Slt
	je ins_Slt
	cmp r9,0x2b ;identifica Sltu
	je ins_Sltu
	cmp r9,0x00 ;identifica Sll
	je ins_Sll
	cmp r9,0x02 ;identifica Srl
	je ins_Srl
	cmp r9,0x22 ;identifica Sub
	je ins_Sub
	cmp r9,0x23 ;identifica Subu
	je ins_Subu
	cmp r9,0x26 ;identifica Mult
	je ins_Mult

;###### Funcionamiento de instrucciones tipo R

ins_Add:
	


ins_Addu:
	call llamadas_aritmeticas_log
	add r11,r10 ; operacion de suma
	mov [r8],r11 ; write back
	jmp _fetch

ins_And:
	call llamadas_aritmeticas_log
	and r11,r10 ; operacion de and
	mov [r8],r11 ; write back
	jmp _fetch

ins_Jr:


ins_Nor:
	call llamadas_aritmeticas_log
	or r11,r10 ; operacion de or
	not r11 ; operacion de negacion
	mov [r8],r11 ; write back
	jmp _fetch

ins_Or:
	call llamadas_aritmeticas_log
	or r11,r10 ; operacion de or
	mov [r8],r11 ; write back
	jmp _fetch

;#################################
ins_Slt:
	call llamadas_aritmeticas_log
	shl r10,32 ;corrimiento para signo
	shl r11,32
	cmp r10,r11
	jge esmayor_sltu ; verificacion de mayor o menor
	mov [r8],1
	jmp _fetch

esmayor_sltu: ;si si la comparacion da mayor
	mov [r8],0
	jmp _fetch

;#################################
ins_Sltu:
	call llamadas_aritmeticas_log
	cmp r10,r11
	jge esmayor_sltu ; verificacion de mayor o menor
	mov [r8],1
	jmp _fetch

esmayor_sltu: ;si si la comparacion da mayor
	mov [r8],0 ;escribe 0
	jmp _fetch
;################################

ins_Sll:
	call deco_RT
	call deco_RD
	shl r10, r13 ;corrimiento a la izquierda
	mov [r8],r10 ;write back
	jmp _fetch

ins_Srl:
	call deco_RT
	call deco_RD
	shr r10,r13 ;corrimiento a la derecha
	mov [r8],r10 ;write back
	jmp _fetch

ins_Sub:
	call llamadas_aritmeticas_log
	jmp_fetch

ins_Subu:
	call llamadas_aritmeticas_log
	sub r11,r10 ;operacion de resta
	mov [r8],r11 ;write back
	jmp _fetch

ins_Mult:
	call llamadas_aritmeticas_log
	jmp _fetch

;####################################Funcionamiento de instrucciones tipo I

ins_Addi:
	call llamadas_tipo_I
	mov r10,r12 ;copiar el dato para hacer la máscara
	shr r10,15 ;corrimiento para hacer la máscara
	and r10,1 ;captura el bit de signo
	cmp r10,1 ;si el número es negativo
	je SignExt
	jmp Addi

SignExt:
	or r12,-65536 ;Extiende el signo
	jmp Addi
Addi:
	add r11,r12 ;Operacion de suma
	shl r11,32 ; Corrimientos para eliminación de overflow
	shr r11,32 ;
	mov [r8],r11 ; write back
	jmp _fetch

ins_Andi:
	call llamadas_tipo_I
	and r11,r12 ;operacion de and
	mov [r8],r11 ;write back
	jmp _fetch

ins_Beq:
	call deco_RS
	call deco_RT
	cmp r10,r11 ; comparacione de registros rs y rt
	je branch_address ;salto si es valido
	jmp _fetch

branch_address:
	add r15,4
	add r15,

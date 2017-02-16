;cases de intrucciones

;OPcode ###
;instrucciones R
cmp r8,0 ;identifica instruccines tipo R
je function_R
cmp r8,0x8 ;identifica Addi
je ins_Addi
cmp r8,0x9 ;identifica Addiu
je ins_Addiu
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
cmp r8,0x24 ;identifica Lbu
je ins_Lbu
cmp r8,0x25 ;identifica Lhu
je ins_Lhu
cmp r8,0x30 ;identifica Ll
je ins_Ll
cmp r8,0xf ;identifica Lui
je ins_Lui
cmp r8,0x23 ;identifica Lw
je ins_Lw
cmp r8,0xd ;identifica Ori 
je ins_Ori
cmp r8,0xa ;identifica Slti
je ins_Slti
cmp r8,0xb ;identifica Sltiu
je ins_Sltiu
cmp r8,0x28 ;identifica Sb
je ins_Sb
cmp r8,0x38 ;identifica Sc
je ins_Sc
cmp r8,0x29;identifica Sh
je ins_Sh
cmp r8,0x2b ;identifica Sw
je ins_Sw
function_R:

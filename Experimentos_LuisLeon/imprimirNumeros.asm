%include "io64.inc"
                extern	printf		; the C function, to be called

        SECTION .data		; Data section, initialized variables

	a:	dq	5	; long int a=5;
fmt:    db "a=%ld", 10, 0	; The printf format, "\n",'0'


        SECTION .text           ; Code section.

        global CMAIN		; the standard gcc entry point
CMAIN:				; the program label for the entry point
        push    rbp		; set up stack frame
	
	mov	rax,78		; put "a" from store into register
	mov	rdi,fmt		; format for printf
	mov	rsi,89         ; first parameter for printf
	;mov	rdx,rax         ; second parameter for printf
	mov	rax,0		; no xmm registers
        call    printf		; Call C function

	pop	rbp		; restore stack

	mov	rax,0		; normal, no error, return value
	ret			; return
	

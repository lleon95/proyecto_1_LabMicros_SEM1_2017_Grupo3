%include "io64.inc"
MAXARGS     equ     5 ; 1 = program path 2 = 1st arg  3 = 2nd arg etc... 
;sys_exit    equ     1
sys_read    equ     0
sys_write   equ     1
stdin       equ     0
stdout      equ     1
;stderr      equ     3

SECTION     .data
;szErrMsg    db      "Too many arguments.  The max number of args is 4", 10
;ERRLEN      equ     $-szErrMsg
szLineFeed  db      10


SECTION     .text
global      CMAIN
    
CMAIN:
    nop

    push    rbp
    mov     rbp, rsp
    
    cmp     dword[rbp + 8], 1
    je      NoArgs                           ; no args entered
    
    ; uncomment the following 2 lines to limit args entered
    ; and set MAXARGS to Total args wanted + 1
    ; cmp     dword [ebp + 4], MAXARGS        ; check total args entered
    ; ja      TooManyArgs                     ; if total is greater than MAXARGS, show error and quit

    mov     rbx, 3
    
DoNextArg:   
    mov     rdi, [rbp + 8 * rbx]
    test    rdi, rdi
    jz      Exit
    
    call    GetStrlen
    ;push    rdx                             ; save string length for reverse
    
    mov     rsi, [rbp + 8 * rbx]
    call    DisplayNorm                     ; display arg text normally
    
    ;pop     rdi                             ; move string length into edi
    ;mov     rsi, dword [ebp + 4 * ebx]
    ;call    ReverseIt                       ; now display in reverse
    inc     rbx                             ; step arg array index
    jmp     DoNextArg
    
;ReverseIt:
;    push    rbx
;
;    add     rsi, rdi
;Next:
;    mov     rax, sys_write
;    mov     rbx, stdout
;    mov     rcx, rsi
;    mov     rdx, 1
;    int     80H    
;    dec     rsi
;    dec     rdi 
;    jns     Next
;
;    mov     rcx, szLineFeed
;    mov     rdx, 1
;    mov     rax, sys_write
;    mov     rbx, stdout
;    int     80H
;    
;    pop     rbx
;    ret
    
NoArgs:
   ; No args entered,
   ; start program without args here
    jmp     Exit

DisplayNorm:
    ;push    rbx
    mov     rax, sys_write
    mov     rdi, stdout
    syscall  
    ;pop     rbx
    ret
    
GetStrlen:
    push    rbx
    xor     rcx, rcx
    not     rcx
    xor     rax, rax
    cld
    repne   scasb
    mov     byte [rdi - 1], 10
    not     rcx
    pop     rbx
    lea     rdx, [rcx - 1]
    ret
    
; TooManyArgs:
;     mov     rax, sys_write
;     mov     rbx, stdout
;     mov     rcx, szErrMsg
;     mov     rdx, ERRLEN
;     int     80H
    
Exit:
    mov     rsp, rbp
    pop     rbp
    

mov rax,60	  ;system call number (sys_exit)
mov rdi,0	;exit status 0 (if not used is 1 as set before) "echo $?" to check
syscall	; system exit

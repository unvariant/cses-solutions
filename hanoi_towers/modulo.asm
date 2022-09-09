%macro ascin 1
    db %1, 0x0A
%endmacro
 
%macro asciz 1
    db %1, 0x00
%endmacro
 
%macro ascii 1
    db %1
%endmacro


    global  _start
    section .text
 
 
_start:
    mov     rsi,     buffer
    mov     edx,     buffer_len
    syscall
 
    mov     ebx,     1
    lea     edx,     [rax - 1]
    xor     ecx,     ecx
    xor     eax,     eax
atoi:
    imul    ecx,     10
    lodsb
    lea     ecx,     [rax + rcx - 0x30]
    dec     edx
    jnz     atoi
 
    shl     ebx,     cl
    dec     ebx
 
    mov     esi,     0x0A
    mov     rbp,     0xCCCCCCCCCCCCCCCD
    mov     edx,     ebx
    mov     r9d,     1
itoa:
    shl     rsi,     8
    mov     eax,     edx
    lea     edi,     [rdx + 0x30]
    mul     rbp
    shr     edx,     3
    lea     r8d,     [rdx * 4 + rdx]
    shl     r8d,     1
    sub     edi,     r8d
    or      rsi,     rdi
    inc     r9
    test    edx,     edx
    jnz     itoa
 
    mov     r11,     even_swap
    mov     r12,     odd_swap
    test    rcx,     1
    cmovz   r12,     r11

    ;mov     qword [output], rsi

    lea     r9,      [output + r9]
    xor     rdi,     rdi
    mov     r13,     (4 << 8) | (0)

build:
    mov     eax,     dword [r12 + rdi * 8]
    mov     edx,     dword [r12 + rdi * 8 + 4]
 
    bextr   ecx,     dword [state + rax * 8], r13d
    bextr   esi,     dword [state + rdx * 8], r13d

    inc     rdi
 
    cmp     esi,     ecx
    jge     .next

    xchg    eax,     edx
    mov     ecx,     esi
 
 .next:
    shl     qword [state + rdx * 8], 4
    sar     qword [state + rax * 8], 4
    or      byte  [state + rdx * 8], cl

    cmp     rdi,     3
    cmovz   rdi,     qword [numeric_zero]
 
    shl     edx,     16
    lea     esi,     [eax + edx + 0x0A312031]
    mov     dword [r9], esi
    add     r9,      4
 
    dec     rbx
    jnz     build
 
solution:
    mov     rdx,     r9
    mov     eax,     1
    mov     edi,     1
    mov     rsi,     output
    sub     rdx,     output
    syscall
 
exit:
    mov     eax,     60
    xor     edi,     edi
    syscall
 
 
 
buffer_len  equ      32
 
    section .bss
buffer: resb 32
output: resb 1000000
 
 
    section .data
    align 16
state: dq (0)       | (1 << 4)  | (2 << 8)   | (3 << 12)  |(4 << 16)   | (5 << 20)  | (6 << 24)  | (7 << 28) |\
          (8 << 32) | (9 << 36) | (10 << 40) | (11 << 44) | (12 << 48) | (13 << 52) | (14 << 56) | (15 << 60) 
       dq -1, -1
 
    align 16
even_swap:
    dd 0, 1
    dd 0, 2
    dd 1, 2
 
    align 16
odd_swap:
    dd 0, 2
    dd 0, 1
    dd 1, 2

    align 16
numeric_zero: dq 0
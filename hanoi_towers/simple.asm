%macro ascin 1
    db %1, 0x0A
%endmacro
 
%macro asciz 1
    db %1, 0x00
%endmacro
 
%macro ascii 1
    db %1
%endmacro
 
 
;;; reg | usage                  | default
;;; --------------------------------------
;;; rax | src index              | none
;;; rbx | max loop iterations    | (1 << n) - 1
;;; rcx | scratch                | none
;;; rdx | dst index              | none
;;; rdi | iteration counter      | 0
;;; rsi | scratch                | none
;;; rbp | scratch                | none
;;; rsp | scratch                | none
;;; r8  | divide by 3 constant   | 0xaaaaaaaaaaaaaaab (shift 65)
;;; r9  | output buffer          | none
;;; r10 | scratch                | none
;;; r11 | scratch                | none
;;; r12 | scratch                | none
;;; r13 | scratch                | none
;;; r14 | scratch                | none
;;; r15 | scratch                | none
;;; --------------------------------------
 
 
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
 
    xor     esi,     esi
    mov     rbp,     0xCCCCCCCCCCCCCCCD
    mov     edx,     ebx
    xor     r9d,     r9d
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
 
    mov     qword [output], rsi
    mov     byte [output + r9], 0x0A
 
    mov     r8,      0xaaaaaaaaaaaaaaab
    lea     r9,      [output + r9 + 1]
    xor     rdi,     rdi
 
    mov     r11,     even_swap
    mov     r12,     odd_swap
    test    rcx,     1
    cmovz   r12,     r11
 
build: 
    mov     eax,     dword [r12 + rdi * 8]
    mov     edx,     dword [r12 + rdi * 8 + 4]
 
    mov     rcx,     qword [state + rax * 8]
    mov     rsi,     qword [state + rdx * 8]
    and     rcx,     0x0F
    and     rsi,     0x0F

    inc     rdi
 
    cmp     esi,     ecx
 
    cmovl   ecx,     esi
    cmovl   ebp,     eax
    cmovl   eax,     edx
    cmovl   edx,     ebp

    cmp     rdi,     3
    cmovz   rdi,     qword [numeric_zero]
 
    shl     qword [state + rdx * 8], 4
    or      qword [state + rdx * 8], rcx
    sar     qword [state + rax * 8], 4
 
    shl     edx,     16
    lea     ecx,     [eax + edx + 0x0A312031]
    mov     dword [r9], ecx
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
state: dq (0) | (1 << 4) | (2 << 8) | (3 << 12) | (4 << 16) | (5 << 20) | (6 << 24) | (7 << 28) | (8 << 32) | (9 << 36) | (10 << 40) | (11 << 44) | (12 << 48) | (13 << 52) | (14 << 56) | (15 << 60) 
       dq 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF
 
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
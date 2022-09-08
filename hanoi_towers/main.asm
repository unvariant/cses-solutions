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

    lea     rdx,     [rax - 1]
    xor     ecx,     ecx
    xor     eax,     eax
atoi:
    imul    rcx,     10
    lodsb
    lea     rcx,     [rax + rcx - 0x30]
    dec     rdx
    jnz     atoi

    mov     ebx,     1
    shl     rbx,     cl
    dec     rbx

    xor     esi,     esi
    mov     rbp,     0xCCCCCCCCCCCCCCCD
    mov     edx,     ebx
    xor     r9d,     r9d
itoa:
    shl     rsi,     8
    mov     eax,     edx
    lea     edi,     [edx + 0x30]
    mul     rbp
    shr     edx,     3
    lea     r8d,     [edx * 4 + edx]
    shl     r8d,     1
    sub     edi,     r8d
    or      rsi,     rdi
    inc     r9
    test    edx,     edx
    jnz     itoa

    mov     qword [output], rsi
    mov     byte [output + r9], 0x0A

    mov     ebp,     5
    test    cl,      1
    cmovnz  rbp,     rdx
    dec     rbp

    xor     r8d,     r8d
    xor     edi,     edi
    mov     esi,     1
    mov     rsp,     0xaaaaaaaaaaaaaaab
    lea     r9,      [output + r9 + 1]

    mov     qword [state], rbx

;;; reg | usage                  | default
;;; --------------------------------------
;;; rax | scratch                | none
;;; rbx | max loop iterations    | (1 << n) - 1
;;; rcx | shift                  | none
;;; rdx | mask                   | none
;;; rdi | previous gray code     | 0
;;; rsi | loop iteration + 1     | 1
;;; rbp | cycle increment amount | 4 or -1
;;; rsp | divide by 3 constant   | 0x2aaaaaaaaaaaaaaab
;;; r8  | last cycle index       | 0
;;; r9  | scratch                | none
;;; r10 | weight                 | none
;;; r11 | dst index              | none
;;; r12 | src index              | none
;;; r13 | scratch                | none
;;; r14 | scratch                | none
;;; r15 | scratch                | none
;;; --------------------------------------

build:
    mov     r10,     1
    mov     rax,     rsi
    shr     rax,     1
    xor     rax,     rsi
    mov     rdx,     rax
    xor     rax,     rdi
    tzcnt   rcx,     rax
    shl     r10,     cl
    mov     rdi,     rdx

    cmp     r10,     1
    jz      .smallest_weight

    mov     r13,     qword [state]
    mov     r14,     qword [state + 8]
    mov     r15,     qword [state + 16]
    lea     rdx,     [r10 * 2 - 1]

    test    r13,     r10
    cmovnz  r12,     qword [numeric_zero]
    test    r14,     r10
    cmovnz  r12,     qword [numeric_one]
    test    r15,     r10
    cmovnz  r12,     qword [numeric_two]

    test    r13,     rdx
    cmovz   r11,     qword [numeric_zero]
    test    r14,     rdx
    cmovz   r11,     qword [numeric_one]
    test    r15,     rdx
    cmovz   r11,     qword [numeric_two]

    jmp     .next

.smallest_weight:
    mov     r12,     r8
    add     r8,      rbp
    cmovs   r8,      qword [numeric_two]
    mov     rax,     r8
    mul     rsp
    shr     rdx,     1
    lea     rdx,     [rdx + rdx * 2]
    sub     r8,      rdx

    mov     r11,     r8

.next:
    xor     qword [state + r12 * 8], r10
    or      qword [state + r11 * 8], r10

    shl     r12,     2
    or      r11,     r12
    mov     eax,     dword [lookup + r11 * 4]
    mov     dword [r9], eax

    add     r9,      4
    inc     rsi
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
state: times 3 dq 0

    align 16
lookup:
    ascin "bad"
    ascin "1 2"
    ascin "1 3"
    ascin "bad"
    ascin "2 1"
    ascin "bad"
    ascin "2 3"
    ascin "bad"
    ascin "3 1"
    ascin "3 2"
    ascin "bad"
    ascin "bad"
    ascin "bad"
    ascin "bad"
    ascin "bad"
    ascin "bad"


    align 16
numeric_zero: dq 0
numeric_one: dq 1
numeric_two: dq 2

;;; 0_1 00_01 1
;;; 0_2 00_10 2
;;; 1_0 01_00 4
;;; 1_2 01_10 6
;;; 2_0 10_00 8
;;; 2_1 10_01 9
    global  _start
    section .text


_start:
    mov     rsi,     buffer
    mov     rdx,     buffer_len
    syscall

    dec     rax
    lea     rcx,     [rsi + rax]
    shr     rax,     1
    lea     rbx,     [output + rax]

    xor     rax,     rax

bucket_count:
    lodsb
    inc     qword [bucket_start + eax * 8]
    cmp     rsi,     rcx
    jnz     bucket_count

    mov     ecx,     0x5A
    mov     dl,      1
    xor     eax,     eax

check:
    mov     rsi,     qword [bucket_start + ecx * 8]
    shr     rsi,     1

    cmovc   eax,     ecx
    setc    bl

    mov     qword [bucket_start + ecx * 8], rsi
    sub     dl,      bl

    dec     ecx
    cmp     ecx,     0x40
    jnz     check

    ;;; perform the check outside the loop
    ;;; if dl is less than zero then not possible to build palindrome
    cmp     dl,      0
    jl      no_solution

    xor     edx,     edx
    test    al,      al
    setnz   edx
    mov     byte [rdi], al

    lea     rsi,     [rdi + rdx]
    sub     rdi,     32

    mov     ecx,     25
    vzeroupper
    vmovdqa ymm7,    yword [alpha_z]
    vmovdqa ymm1,    yword [numeric_one]

build:
    mov     rax,     qword [bucket + ecx * 8]
    add     rax,     31
    shr     rax,     5

    mov     rbx,     rdi
    mov     rdx,     rax

.left:
    vmovdqu yword [rbx], ymm7
    sub     rbx,     32
    dec     rax
    jnz     .left

    mov     rbx,     rsi
    sub     rdi,     rdx
    mov     rax,     rdx

.right:
    vmovdqu yword [rbx], ymm7
    add     rbx,     32
    dec     rax
    jnz     .right

    add     rsi,     rdx

    dec     ecx
    jnz     build

solution:
    mov     eax,     1
    mov     rdx,     rdi
    mov     rsi,     output
    sub     rdx,     output
    mov     edi,     1
    syscall

    mov     eax,     60
    xor     edi,     edi
    syscall

no_solution:
    mov     eax,     1
    mov     edi,     1
    mov     rsi,     _no_solution
    mov     edx,     _no_solution_len
    syscall

    mov     eax,     60
    xor     edi,     edi
    syscall


buffer_len  equ      (1000000 + 16) & (~15)

    align 16
    section .bss

buffer: resb buffer_len
output: resb buffer_len

bucket_start: resq 65
bucket: resq 26
        resq 37


    align 16
    section .data
alpha_z: times 32 db 0x5A
numeric_one: times 32 db 0x01

_no_solution: db "NO SOLUTION", 0Ah
_no_solution_len equ $-_no_solution
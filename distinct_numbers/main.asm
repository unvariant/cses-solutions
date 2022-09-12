KB equ 1024
MB equ 1024 * KB


    section .text
    global  _start


_start:
    mov     rsi,     buffer
    mov     rdx,     buffer_len
    syscall

    lea     rdi,     [rsi + rax - 1]

    vzeroupper
    movdqa    xmm7,  oword [pcmpestrm_data]
    movdqa    xmm6,  oword [shuffle_reverse]
    movdqa    xmm5,  oword [mul_byte]
    movdqa    xmm4,  oword [mul_word]
    movdqa    xmm3,  oword [mul_dword]
    movdqa    xmm2,  oword [ascii_adjust]

    call atoi
    call atoi

    mov rdi, rax
    mov rax, 60
    syscall


atoi:
    movdqu    xmm1,    oword [rdi - 16]
    pshufb    xmm1,    xmm6
    pcmpistrm xmm7,    xmm1,    pcmpestrm_control
    psubb     xmm1,    xmm2
    pand      xmm1,    xmm0
    pmaddubsw xmm1,    xmm5
    pmaddwd   xmm1,    xmm4
    pmuludq   xmm1,    xmm3
    pmovmskb  ecx,     xmm0
    pextrq    rdx,     xmm1,    1
    pextrq    rax,     xmm1,    0
    bsr       ecx,     ecx
    add       rax,     rdx
    sub       rdi,     rcx
    dec       rdi
    ret


pcmpestrm_control equ (0b1 << 6) | (0b00 << 4) | (0b00 << 2) | (0b0 << 1) | (0b0)

    section .data
    align 16
pcmpestrm_data: db '0123456789'
                db 0, 0, 0, 0, 0, 0
mul_byte:  db 1, 10, 1, 10, 1, 10, 1, 10, 1, 10, 1, 10, 1, 10, 1, 10
mul_word:  dw 1, 100, 1, 100, 1, 100, 1, 100
mul_dword: dd 1, 10000, 1, 10000
ascii_adjust: times 16 db 0x30
shuffle_reverse: db 0x0F, 0x0E, 0x0D, 0x0C, 0x0B, 0x0A, 0x09, 0x08
                 db 0x07, 0x06, 0x05, 0x04, 0x03, 0x02, 0x01, 0x00


buffer_len equ MB * 16
bitmap_len equ MB * 128

    section .bss
bitmap: resb bitmap_len
buffer: resb buffer_len
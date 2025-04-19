; Assemble with: nasm -f bin -o demo_fp.com demo_fp.asm -l demo_fp.lst

    ; 16-bit code
    BITS 16
     ; COM programs start at offset 100h
    ORG 100h


start:
    lea edi, [sine_table+1279*4]

init_loop:
    fild word   [time]
    fmul dword  [tau_1024]
    fsin
    fmul dword  [to16_16]
    fistp dword [edi]
    sub edi, 4
    dec word    [time]
    jnz init_loop

    ; Set video mode (320x200, 256 colors)
    mov ax, 0013h
    int 10h

    ; Initialize video memory segment
    mov ax, 0A000h
    mov es, ax

main_loop:
    inc word [time]

    mov word [screen], 0
    mov word [y], 200
y_loop:
    mov word [x], 320
x_loop:
    ; eax, edx compute
    ; ebx - X
    ; ecx - Y
    ; esi - Z
    ; edi - Scale

    mov   esi, [_0_01]

    mov   ax , [x]
    shl   eax, 16
    imul  esi
    shrd  eax, edx, 16
    sub   eax, [_1_6]
    mov   ebx, eax

    mov   ax , [y]
    shl   eax, 16
    imul  esi
    shrd  eax, edx, 16
    sub   eax, [_1]
    mov   ecx, eax

    mov   esi, [_0_5]

    mov   edi, [time]
    and   edi, 0x3FF
    lea   edi, [sine_table+edi*4]

    ; 'z = z*cos+y*sin
    ; 'y = y*cos-z*sin
    mov   eax, esi
    imul  dword [edi+1024]
    shrd  eax, edx, 16
    mov   ebp, eax

    mov   eax, ecx
    imul  dword [edi]
    shrd  eax, edx, 16
    add   ebp, eax

    mov   eax, ecx
    imul  dword [edi+1024]
    shrd  eax, edx, 16
    mov   ecx, eax

    mov   eax, esi
    imul  dword [edi]
    shrd  eax, edx, 16
    sub   ecx, eax

    mov   esi, ebp

    ; 'x = x*cos+z*sin
    ; 'z = z*cos-x*sin
    mov   eax, ebx
    imul  dword [edi+1024]
    shrd  eax, edx, 16
    mov   ebp, eax

    mov   eax, esi
    imul  dword [edi]
    shrd  eax, edx, 16
    add   ebp, eax

    mov   eax, esi
    imul  dword [edi+1024]
    shrd  eax, edx, 16
    mov   esi, eax

    mov   eax, ebx
    imul  dword [edi]
    shrd  eax, edx, 16
    sub   esi, eax

    mov   ebx, ebp

    mov   eax, ebx
    imul  dword [edi+1024]
    shrd  eax, edx, 16
    mov   ebp, eax

    mov   eax, ecx
    imul  dword [edi]
    shrd  eax, edx, 16
    add   ebp, eax

    mov   eax, ecx
    imul  dword [edi+1024]
    shrd  eax, edx, 16
    mov   ecx, eax

    mov   eax, ebx
    imul  dword [edi]
    shrd  eax, edx, 16
    sub   ecx, eax

    mov   ebx, ebp

    ; Scale
    mov   edi, [_1]

    mov   byte [a], 4
a_loop:
    ; p -= 2*round(0.5*p)
    mov   eax, ebx
    shr   eax, 1
    add   eax, [_0_5]
    and   eax, 0FFFF0000h
    add   eax, eax
    sub   ebx, eax

    mov   eax, ecx
    shr   eax, 1
    add   eax, [_0_5]
    and   eax, 0FFFF0000h
    add   eax, eax
    sub   ecx, eax

    mov   eax, esi
    shr   eax, 1
    add   eax, [_0_5]
    and   eax, 0FFFF0000h
    add   eax, eax
    sub   esi, eax

    ; r2 = dot(p,p)
    mov   eax, ebx
    imul  eax
    shrd  eax, edx, 16
    mov   ebp, eax

    mov   eax, ecx
    imul  eax
    shrd  eax, edx, 16
    add   ebp, eax

    mov   eax, esi
    imul  eax
    shrd  eax, edx, 16
    add   ebp, eax

    ; To avoid overflows
    add   ebp, 8

    ; k = 1/r2
    xor   eax, eax
    mov   edx, 2
    idiv  ebp
    mov   ebp, eax

    ; p *= k
    mov   eax, ebx
    imul  ebp
    shrd  eax, edx, 16
    mov   ebx, eax

    mov   eax, ecx
    imul  ebp
    shrd  eax, edx, 16
    mov   ecx, eax

    mov   eax, esi
    imul  ebp
    shrd  eax, edx, 16
    mov   esi, eax

    ; scale *= k
    mov   eax, edi
    imul  ebp
    shrd  eax, edx, 16
    mov   edi, eax
.skip:
    dec byte [a]
    jnz a_loop

    ; To avoid overflows
    add edi, 8

    xor   edx, edx
    mov   eax,ebx
    test  eax,eax
    jge   .abs
    neg   eax
.abs:
    shld  edx, eax, 16
    shl   eax, 16
    idiv  edi

    bsr   ebx, eax
    mov   cl , 31
    sub   cl , bl
    shl   eax, cl
    shr   eax, 15

    mov di, [screen]
    ; Write pixel
    stosb
    mov [screen],di

    dec word [x]
    jnz x_loop

    dec word [y]
    jnz y_loop

    ; Check for keypress to exit
    mov ah, 1
    int 16h
    jz main_loop

    ret

; Data section
section .data
_1          dd  0x00010000
_1_6        dd  0x00019999
_0_5        dd  0x00008000
_0_01       dd  0x0000028F
tau_1024    dd  0.00613592315154256491887235035797
to16_16     dd  65536.0

a           db  0
x           dw  0
y           dw  0
time        dw  1279
screen      dw  0

sine_table  dw  0
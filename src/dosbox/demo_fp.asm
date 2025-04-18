; Assemble with: nasm -f bin -o demo_fp.com demo_fp.asm -l demo_fp.lst

    ; 16-bit code
    BITS 16
     ; COM programs start at offset 100h
    ORG 100h


start:
    ; Set video mode (320x200, 256 colors)
    mov ax, 0013h
    int 10h

    ; Initialize video memory segment
    mov ax, 0A000h
    mov es, ax

main_loop:
    inc word [time]

    ; Reset position to start of video memory
    xor di, di

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
    mov   ebx, eax

    mov   ax , [y]
    shl   eax, 16
    imul  esi
    shrd  eax, edx, 16
    mov   ecx, eax

    ; edi - Scale
    mov   edi, [_1]

    mov   word [a], 4
a_loop:
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

    xor   eax, eax
    mov   edx, [_1]
    shld edx, eax, 16
    idiv  ebp
    mov   ebp, eax

    mov   eax, ebx
    imul  ebx
    shrd  eax, edx, 16
    mov   ebx, eax

    mov   eax, ecx
    imul  ebx
    shrd  eax, edx, 16
    mov   ecx, eax

    mov   eax, esi
    imul  ebx
    shrd  eax, edx, 16
    mov   esi, eax

    mov   eax, edi
    imul  ebx
    shrd  eax, edx, 16
    mov   edi, eax

    dec word [a]
    jnz a_loop

    xor   eax, eax
    mov   edx,ebx
    jge   .abs
    neg   edx
.abs:
    shld  edx, eax, 16
    idiv  edi

    ; Write pixel
    stosb

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
a           dw  0
x           dw  0
y           dw  0
time        dw  0

tmp         dd  0x00000000
_1          dd  0x00010000
_2          dd  0x00020000
_0_5        dd  0x00008000
_0_01       dd  0x0000028F

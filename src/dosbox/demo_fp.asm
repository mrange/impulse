; Assemble with: nasm -f bin -o demo_fp.com demo_fp.asm -l demo_fp.lst

    ; 16-bit code
    BITS 16
     ; COM programs start at offset 100h
    ORG 100h

start:
    lea edi, [sine_table+1279*4]
    fild dword  [_1]
init_loop:
    fild word   [time]
    fmul dword  [tau_1024]
    fsin
    fmul st1
    fistp dword [edi]
    sub edi, 4
    dec word    [time]
    jnz init_loop

    ; Set video mode (320x200, 256 colors)
    mov ax, 0013h
    int 10h

    ; Initialize video memory segment
    ;   Might be initialized to 0 to save
    mov ax, 0A000h
    mov es, ax

main_loop:
    inc word [time]

    mov word [screen], 0
    mov word [y], 200
y_loop:
    mov word [x], 320
x_loop:

    mov   esi, [_0_005]

    mov   ax , [x]
    shl   eax, 16
    imul  esi
    shrd  eax, edx, 16
    sub   eax, [_0_8]
    mov   ebx, eax

    mov   ax , [y]
    shl   eax, 16
    imul  esi
    shrd  eax, edx, 16
    mov   esi, [_0_5]
    sub   eax, esi
    mov   ecx, eax

    mov   edi, [time]
    and   edi, 0x3FF
    lea   edi, [sine_table+edi*4]

    ; eax - scratch
    ; edx - scratch
    ; ebx - X
    ; ecx - Y
    ; esi - Z
    ; edi - Scale
    ; ebp - scratch
    ; esp - Don't touch this

    mov word [a], 3
r_loop:
    mov   eax, ebx
    mov   ebx, ecx
    mov   ecx, esi
    mov   esi, eax

    ; 'x = x*cos+y*sin
    ; 'y = y*cos-x*sin
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

    dec word [a]
    jnz r_loop

    ; Scale
    mov   edi, [_1]

    mov   word [a], 4
a_loop:
    ; eax - scratch
    ; edx - scratch
    ; ebx - X
    ; ecx - Y
    ; esi - Z
    ; edi - Scale
    ; ebp - Dot
    ; esp - Don't touch this

    xor ebp, ebp
    mov word [b], 3
i_loop:
    mov   eax, ebx
    mov   ebx, ecx
    mov   ecx, esi
    mov   esi, eax

    ; p -= 2*floor(0.5*p+0.5)
    mov   eax, ebx
    shr   eax, 1
    add   eax, [_0_5]
    xor   ax, ax
    add   eax, eax
    sub   ebx, eax

    ; r2 = dot(p,p)
    mov   eax, ebx
    imul  eax
    shrd  eax, edx, 16
    add   ebp, eax

    dec word [b]
    jnz i_loop

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
    dec word [a]
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
    add   ebx, 0x20
    cmp   eax, [_0_005]
    jge   .outside
    xor   ebx, ebx
.outside:

    mov   eax, ebx

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

    int 0x20

; Data section
section .data
; Can be reused
tau_1024    dd  0.00613592315154256491887235035797


_1          dd  0x00010000
_0_8        dd  0x0000CCCC
_0_5        dd  0x00008000
_0_005      dd  0x00000147

time        dw  1279
a           dw  0
b           dw  0
x           dw  0
y           dw  0
screen      dw  0

sine_table  dw  0
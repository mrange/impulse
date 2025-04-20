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
    ;   Might be initialized to 0 to save
    mov ax, 0A000h
    mov es, ax

main_loop:
    fild dword  [_1]
    fild word   [time]
    fmul dword  [tau_1024]
    fsincos
    fmul st2
    fistp dword [cos]
    fmul st1
    fistp dword [sin]
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
    ; 0.8
    sub   eax, 0x0000CCCC
    mov   ebx, eax

    mov   ax , [y]
    shl   eax, 16
    imul  esi
    shrd  eax, edx, 16
    ; 0.5
    mov   esi, 0x00008000
    sub   eax, esi
    mov   ecx, eax

    ; eax - scratch
    ; edx - scratch
    ; ebx - X
    ; ecx - Y
    ; esi - Z
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
    imul  dword [cos]
    shrd  eax, edx, 16
    mov   ebp, eax

    mov   eax, ecx
    imul  dword [sin]
    shrd  eax, edx, 16
    add   ebp, eax

    mov   eax, ecx
    imul  dword [cos]
    shrd  eax, edx, 16
    mov   ecx, eax

    mov   eax, ebx
    imul  dword [sin]
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

    ; p -= 2*floor((p+1)/2)
    mov   eax, ebx
    add   eax, [_1]
    shr   eax, 1
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

    ; Restore text mode
    mov ax, 0x0003
    int 0x10

    ret

; Data section
;   Can be reused
tau_1024    dd  0.00613592315154256491887235035797
_1          dd  0x00010000
_0_005      dd  0x00000147

section .bss
a           resb 2
b           resb 2
x           resb 2
y           resb 2
time        resb 2
screen      resb 2
sin         resb 4
cos         resb 4


; DOS demo with FPU sine wave pattern
; Assemble with: nasm -f bin -o demo.com demo.asm

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

    ; PUSH 2
    fld1
    fld1
    fadd

main_loop:
    ; Reset position to start of video memory
    xor di, di

    mov word [y], 200
y_loop:
    mov word [x], 320
x_loop:
    ; expected stack
    ; ST(0) 2

    ; Scale
    fld1

    fild word [y]
    fild word [_100]
    fdiv
    fld1
    fsub

    fild word [x]
    fild word [_100]
    fdiv
    fld dword [_1_6]
    fsub

    ; expected stack
    ; ST(0) x
    ; ST(1) y
    ; ST(2) scale
    ; ST(3) 2

    ; Appollian loop
    mov al,5
a_loop:
    ; p -= 2.*round(0.5*p);

    mov cl,2
r_loop:
    ; Swap x and y
    fxch
    ; Dupe
    fld     st0
    ; Divide by 2
    fdiv    st4
    frndint
    ; Multiply by 2
    fmul    st4
    fsub
    dec cl
    jnz r_loop

    ; dot(p,p)
    ; Dupe x
    fld     st0
    fmul    st0

    ; Dupe y
    fld     st2
    fmul    st0

    fadd

    ; k = 1/dot(p,p)
    fld1
    fdivr

    ; p *= k
    fmul    st1,st0
    fmul    st2,st0
    ; scale *= k
    fmul    st3,st0

    ; Pop k
    fstp    st0

    dec al
    jnz a_loop

    ; Compute distance
    fabs
    fdiv    st2


    fld dword [threshold]

    fcomip
    jbe set_color
    mov al, 0x32
set_color:
    ; Write pixel and advance DI
    stosb

    ; Restore stack to expected state
    ; ST(0) 2
    fstp    st0
    fstp    st0
    fstp    st0

    dec word [x]
    jnz x_loop

    dec word [y]
    jnz y_loop

    ; Check for keypress to exit
    mov ah, 1
    int 16h
    jz main_loop

    ; Clear keyboard buffer
    mov ah, 0
    int 16h

    ; Clear keyboard buffer
    mov ax, 0003h
    int 10h
    ret

; Data section
threshold   dd  0.01
_1_6        dd  1.6

_100        dw  100
x           dw  0
y           dw  0

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

    ; PUSH 100
    fild word [_100]

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
    ; ST(1) 100

    ; Scale
    fld1

    ; Z
    fld1
    fdiv st3

    fild word [y]
    fdiv st4
    fld1
    fsub

    fild word [x]
    fdiv st5
    fld dword [_1_6]
    fsub

    ; expected stack
    ; ST(0) x
    ; ST(1) y
    ; ST(2) z
    ; ST(3) scale
    ; ST(4) 2
    ; ST(5) 100

    ; Appollian loop
    mov al,5
a_loop:
    ; p -= 2.*round(0.5*p);

    mov ah,3
r_loop:
    ; Rotate ST(0..2)
    fxch st2
    fxch st1
    ; Dupe
    fld     st0
    ; Divide by 2
    fdiv    st5
    frndint
    ; Multiply by 2
    fmul    st5
    fsub
    dec ah
    jnz r_loop

    ; dot(p,p)
    ; Dupe x
    fld     st0
    fmul    st0

    ; Dupe y
    fld     st2
    fmul    st0

    fadd

    ; Dupe z
    fld     st3
    fmul    st0

    fadd

    ; k = 1/dot(p,p)
    fld1
    fdivr

    ; p *= k
    fmul    st1,st0
    fmul    st2,st0
    fmul    st3,st0
    ; scale *= k
    fmul    st4,st0

    ; Pop k
    fstp    st0

    dec al
    jnz a_loop

    ; Compute distance
    fabs
    fdiv    st3


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
    fstp    st0

    dec word [x]
    jnz x_loop

    dec word [y]
    jnz y_loop

    inc word [time]

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
time        dw  0
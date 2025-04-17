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

main_loop:
    ; Reset position to start of video memory
    xor di, di

    mov word [y], 200
y_loop:
    mov word [x], 320
x_loop:
    ; PUSH 0.01
    fld dword [_0_01]

    ; Z
    fld  st0

    fild word [y]
    fmul st2
    fld1
    fsub

    fild word [x]
    fmul st3
    fsub dword [_1_6]

    ; Load sin cos
    fild word [time]
    fmul st4
    fsincos

    ; expected stack
    ; ST(0) cos
    ; ST(1) sin
    ; ST(2) x
    ; ST(3) y
    ; ST(4) z

    mov ax,1
t_loop:

    ; y' = y*cos - x*sin
    ; y +0
    fld     st3
    ; *cos +1
    fmul    st1
    ; x +1
    fld     st3
    ; *sin +2
    fmul    st3
    fsub                ; y' = y*cos - x*sin

    ; x' = x*cos + y*sin
    ; x +1
    fld     st3
    ; *cos +2
    fmul    st2
    ; y +2
    fld     st5
    ; *sin +3
    fmul    st4
    fadd

    ; expected stack
    ; ST(0) x'
    ; ST(1) y'
    ; ST(2) cos
    ; ST(3) sin
    ; ST(4) x
    ; ST(5) y
    ; ST(6) z

    fstp    st4
    fstp    st4
    dec     ax
    jnz     t_loop

    fstp    st0
    fstp    st0

    ; Scale
    fld1
    fstp st4

    ; expected stack
    ; ST(0) x
    ; ST(1) y
    ; ST(2) z
    ; ST(3) scale


    ; Appollian loop
    mov ax,5
a_loop:
    ; p -= 2.*round(0.5*p);

    mov bx,3
r_loop:
    ; Rotate ST(0..2)
    fxch st2
    fxch st1
    ; Dupe
    fld     st0
    ; Divide by 2
    fmul dword [_0_5]
    frndint
    ; Multiply by 2
    fadd    st0
    fsub
    dec bx
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

    dec ax
    jnz a_loop

    ; Compute distance
    fabs
    fdiv    st3

    fst dword [_bits]
    mov al, [_bits+3]
    sub al,16

    stosb

    ; Restore stack to expected state
    ;   Not needed as nothing is kept stack
    ; fstp    st0
    ; fstp    st0
    ; fstp    st0
    ; fstp    st0

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
_1_6        dd  1.6
_0_01       dd  0.01
_0_5        dd  0.5
_bits       dd  0.0

x           dw  0
y           dw  0
time        dw  0


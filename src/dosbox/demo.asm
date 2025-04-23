; Assemble with: nasm -f bin -o demo.com demo.asm -l demo.lst

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
    ; Load sin cos
    fild word  [time]
    fmul dword [_0_005]
    fsincos
    fstp dword [cos]
    fstp dword [sin]

    ; Reset position to start of video memory
    xor di, di

    mov word [y], 200
y_loop:
    mov word [x], 320
x_loop:
    ; Z (0.5)
    fld dword [_0_5]

    fild word [y]
    fmul dword [_0_005]
    fld st1
    fsub

    fild word [x]
    fmul dword [_0_005]
    fsub dword [_0_8]

    ; expected stack
    ; ST(0) x
    ; ST(1) y
    ; ST(2) z
    ; ST(3) 0.005

    mov ax, 3
t_loop:
    fxch st2
    fxch st1

    ; y' = y*cos - x*sin
    fld     st1
    fmul dword [cos]
    fld     st1
    fmul dword [sin]
    fsub

    ; x' = x*cos + y*sin
    fld     st1
    fmul dword [cos]
    fld     st3
    fmul dword [sin]
    fadd

    ; Overwrite x with x'
    fstp    st2
    ; Overwrite y with y'
    fstp    st2

    dec ax
    jnz t_loop

    ; Scale
    fld1
    fstp st4

    ; expected stack
    ; ST(0) x
    ; ST(1) y
    ; ST(2) z
    ; ST(3) scale

    ; Appollian loop
    mov ax,4
a_loop:
    ; p -= 2.*round(0.5*p);
    fldz
    fstp st5

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

    fld     st0
    fmul    st0
    faddp   st5, st0

    dec bx
    jnz r_loop

    ; k = 2/dot(p,p)
    fld1
    fadd    st0
    fdiv    st5

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

    ; Hacky colors
    fst dword [_bits]
    mov al, [_bits+3]
    sub al,16

    ; Write pixel
    stosb

    ; Clean up stack (if not the DosBox dynamic mode fails)
    fstp st0
    fstp st0
    fstp st0


    dec word [x]
    jnz x_loop

    dec word [y]
    jnz y_loop

    inc word [time]

    ; Check for keypress to exit
    mov ah, 1
    int 16h
    jz main_loop

    ; Restore text mode
    mov ax, 0x0003
    int 0x10

    ret

; Data section
_0_005      dd  0.005
_0_5        dd  0.5
_0_8        dd  0.8

time        dw  0

section .bss
x           resb 2
y           resb 2

_bits       resb 4
sin         resb 4
cos         resb 4


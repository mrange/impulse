; Assemble with: nasm -f bin -o ndemo.com ndemo.asm -l ndemo.lst

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
    fmul dword [_0_01]
    fsincos
    fstp dword [cos]
    fstp dword [sin]

    ; Reset position to start of video memory
    xor di, di

    mov word [y], 200
y_loop:
    mov word [x], 320
x_loop:
    fild word [y]
    fmul dword [_0_01]
    fld1
    fsub

    fild word [x]
    fmul dword [_0_01]
    fsub dword [_1_6]

    ; Stack
    ; ST(0) - x
    ; ST(1) - y

    fldz
    ; Dupe x/y
    fld  st2
    fld  st2

    mov cx, 2
a_loop:
    fxch st1
    fmul dword [_4]
    fld st0
    frndint
    fsubp st1, st0
    fmul dword [_0_25]
    fmul st0
    fadd st2, st0
    loop a_loop

    fstp st0
    fstp st0

    fstp st3

    mov cx, 2
b_loop:
    ; Stack
    ; ST(0) - x
    ; ST(1) - y
    ; ST(2) - d

    ; Add path
    fadd dword [cos]
    fxch
    fadd dword [sin]

    ; dot
    fld st0
    fmul st0
    fld st2
    fmul st0
    fadd

    ; ST(0) - td
    ; ST(1) - x
    ; ST(2) - y
    ; ST(3) - d

    ; k = 1/8
    ; float pmin(float a, float b, float k) {
    ;   float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
    ;   return mix( b, a, h ) - k*h*(1.0-h);
    ; }

    ; td-d
    fsub  st3
    fld   st0
    fadd  dword [_0_125]
    fmul  dword [_4]

    fld1
    fcomp
    fstsw ax
    sahf
    ja .min1
    fstp st0
    fld1
.min1:

    fld1
    fsub st0, st1

    ; Stack
    ; ST(0) - 1-h
    ; ST(1) - h
    ; ST(2) - td-d
    ; ST(3) - x
    ; ST(4) - y
    ; ST(5) - d

    ; Compute (1-h)*(td-d)
    fld   st0
    fmul  st3
    ; Add it to d (now ST(6)
    faddp st6, st0
    ; Compute (1-h)*h*0.125
    fmul  dword [_0_125]
    fmul
    ; Subtract from d
    fsubp st4

    ; Pop td-d
    fstp  st0

    loop b_loop

    fstp  st0
    fstp  st0

    fchs

    ; Hacky colors
    fstp dword [_bits]
    mov al, [_bits+3]
    sub al,16
    ; Write pixel
    stosb

    ; Clean up stack (if not the DosBox dynamic mode fails)

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
_0_01       dd  0.01
_1_6        dd  1.6
_4          dd  4.0
_0_25       dd  0.25
_0_125      dd  0.125

time        dw  0

section .bss
x           resb 2
y           resb 2

_bits       resb 4
sin         resb 4
cos         resb 4


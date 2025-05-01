; Assemble with: nasm -f bin -o ndemo.com ndemo.asm -l ndemo.lst

    ; 16-bit code
    BITS 16
     ; COM programs start at offset 100h
    ORG 0x100

X       equ 0
Y       equ 2
TIME    equ 4
_BITS   equ 6
SINS    equ 10

start:
    ; si seem initialized to 0x100. If we shift right it becomes 0x80
    ;   Where the command line should be
    shr si, 1
    ; Set video mode (320x200, 256 colors)
    mov al, 0x13
    int 10h

    ; Initialize video memory segment
    push 0xA000
    pop es

main_loop:
    lea bx, [si+SINS]
    ; Load DOS timer
    fild dword fs:[046Ch]
    ; Load sin cos
    fmul dword [_0_01]

    mov cx, 8
s_loop:
    fld1
    fadd
    fld     st0
    fsin
    fstp dword ds:[bx]
    add     bx, 4
    loop s_loop

    fstp    st0

m_loop:
    xor dx, dx
    mov ax, di
    mov cx, 320
    div cx
    mov [si+X], dx
    mov [si+Y], ax

    fild word [si+Y]
    fmul dword [_0_01]
    fld1
    fsub

    fild word [si+X]
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
    fimul word [_4]
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

    lea bx, [si+SINS]

    mov cx, 4
b_loop:
    ; Stack
    ; ST(0) - x
    ; ST(1) - y
    ; ST(2) - d

    ; Add path
    fadd dword [bx]
    add bx, 4
    fxch
    add bx, 4
    fadd dword [bx]

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
    fimul word  [_4]

    fld1
    fcomp
    fnstsw ax
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
    fstp dword [si+_BITS]
    mov al, [si+_BITS+3]
    sub al, 16
    ; Write pixel
    stosb

    ; Clean up stack (if not the DosBox dynamic mode fails)

    test di, di
    jnz m_loop

    ; Check for ESC to exit
    in  al, 0x60
    dec al
    jnz main_loop

    ret

; Data section
_0_01       dd  0.01
_1_6        dd  1.6
_0_25       dd  0.25
_0_125      dd  0.125

_4          dw  4


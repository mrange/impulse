; Assemble with: nasm -f bin -o demo_mini.com demo_mini.asm -l demo_mini.lst

    ; 16-bit code
    BITS 16
     ; COM programs start at offset 100h
    ORG 0x100

_BITS   equ 0
SIN     equ 4
COS     equ 8

start:
    shr si, 1

    ; Set video mode (320x200, 256 colors)
    mov ax, 0x13
    int 10h

    ; Initialize video memory segment
    push 0xA000
    pop es

main_loop:
    ; Load DOS timer
    fild dword fs:[046Ch]
    fmul dword [_0_005]
    ; Load sin cos
    fsincos
    fstp dword [si+COS]
    fstp dword [si+SIN]

m_loop:
    mov [si+_BITS], edi

    fild word [_320]
    fild dword [si+_BITS]
    fprem
    fild dword [si+_BITS]
    fsub st0, st1
    fdiv st2

    ; Z (0.5)
    fld dword [_0_5]
    fstp st3

    fmul dword [_0_005]
    fsub st2

    fxch
    fmul dword [_0_005]
    fsub dword [_0_8]

    ; expected stack
    ; ST(0) x
    ; ST(1) y
    ; ST(2) z

    mov cx, 3
t_loop:
    fxch st2
    fxch st1

    ; y' = y*cos - x*sin
    fld     st1
    fmul dword [si+COS]
    fld     st1
    fmul dword [si+SIN]
    fsub

    ; x' = x*cos + y*sin
    fld     st1
    fmul dword [si+COS]
    fld     st3
    fmul dword [si+SIN]
    fadd

    ; Overwrite x with x'
    fstp    st2
    ; Overwrite y with y'
    fstp    st2

    loop t_loop

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

    ; TODO: mov cl, 3 seems to work and saves 1 byte
    mov cx, 3
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

    loop r_loop

    ; k = 2/dot(p,p)
    fld1
    fadd    st0
    fdiv    st5

    ; p *= k
    fmul    st1,st0
    fmul    st2,st0
    fmul    st3,st0
    ; scale *= k
    fmulp   st4,st0

    dec ax
    jnz a_loop

    ; Compute distance
    fabs
    fdiv    st3

    ; Hacky colors
    fstp dword [si+_BITS]
    mov al, [si+_BITS+3]
    sub al,16

    ; Clean up stack (if not the DosBox dynamic mode fails)
    fstp st0
    fstp st0

    ; Write pixel
    stosb

    test di, di
    jnz m_loop

    ; Check for ESC to exit
    in  al, 0x60
    dec ax
    jnz main_loop

    mov ax, 0x0003
    int 0x10

    ret

; Data section
_0_005      dd  0.005
_0_5        dd  0.5
_0_8        dd  0.8
_320        dw  320

section .bss

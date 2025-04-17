; DOS demo with FPU sine wave pattern
; Assemble with: nasm -f bin -o fpudemo.com fpudemo.asm

    BITS 16          ; 16-bit code
    ORG 100h         ; COM programs start at offset 100h

start:
    mov dx, wait_for_any_key
    mov ah, 09h
    int 21h

    mov ah, 00h
    int 16h

    ; Set video mode (320x200, 256 colors)
    mov ax, 0013h
    int 10h

    ; Initialize video memory segment
    mov ax, 0A000h   ; Video memory segment
    mov es, ax       ; ES points to video memory

    ; Set up a counter for animation
    xor bp, bp

    ; PUSH 2
    fld1
    fld1
    fadd

main_loop:
    ; Clear screen
    xor di, di       ; Reset position to start of video memory

    ; PUSH 1 (start y)
    fld1

    ; Loop through Y coordinates (0-199)
    xor cx, cx       ; Y = 0
y_loop:
    ; Expected stack
    ; ST(1) - y
    ; ST(0) - 2

    fld     dword [start_x]

    ; Loop through X coordinates (0-319)
    xor dx, dx       ; X = 0
x_loop:
    ; Expected stack
    ; ST(0) - x
    ; ST(1) - y

    ; PUSH 1 (Scale)
    fld1

    ; Appollian loop
    xor ax,ax

a_loop:
    ; Expected stack
    ; ST(0) - scale
    ; ST(1) - x
    ; ST(2) - y
    ; ST(3) - 2

    ; ST(1) x -= 2*round(0.5*x)
    fxch    st1
    fdiv    st0, st3
    frndint
    fmul    st0, st3
    fxch    st1

    ; ST(2) y -= 2*round(0.5*y)
    fxch    st2
    fdiv    st0, st3
    frndint
    fmul    st0, st3
    fxch    st2

    ; dot product
    fld     st1
    fmul    st0, st0
    fld     st3
    fmul    st0, st0
    fadd

    ; ST(0) - dot
    ; ST(1) - scale
    ; ST(2) - x
    ; ST(3) - y
    ; ST(4) - 2

    fdiv    st1, st0
    fdiv    st2, st0
    fdiv    st3, st0

    ; POP dot
    fstp    st0

    inc ax
    cmp ax, 5
    jl a_loop

    ; ST(0) - scale
    ; ST(1) - x
    ; ST(2) - y
    ; ST(3) - 2

    fld     st1
    fabs
    fdivr   st0, st1

    fld     dword [threshold]

    fcomip  st0, st1
    setb    al
    dec     al

    stosb                  ; Write pixel and advance DI

    ; POP threshold
    fstp st0
    ; POP scale
    fstp st0

    ; Expected stack
    ; ST(0) - x
    ; ST(1) - y
    ; ST(2) - 2

    ; Increment x
    fld     dword [increment]
    fadd

    ; X loop control
    inc dx
    cmp dx, 320
    jl x_loop

    ; POP x
    fstp st0

    ; Expected stack
    ; ST(0) - y
    ; ST(1) - 2

    ; Increment y
    fld     dword [increment]
    fadd

    ; Y loop control
    inc cx
    cmp cx, 200
    jl y_loop

    ; POP y
    fstp st0

    ; Check for keypress to exit
    mov ah, 1
    int 16h
    jz main_loop

    ; POP 2
    fstp st0

    ; Exit: reset video mode
    mov ah, 0       ; Clear keyboard buffer
    int 16h
    mov ax, 0003h   ; Text mode
    int 10h
    ret

; Data section
threshold   dd 0.01
increment   dd -0.01
start_x     dd 1.6

wait_for_any_key db 'Wait for any key$', 0
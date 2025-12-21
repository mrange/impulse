; Assemble with: nasm -f bin -o mandel_brot.com mandel_brot.asm -l mandel_brot.lst

  BITS 16
  ORG 0x100

start:
  ; Switch to VGA video mode 13h (320x200 pixels, 256 colors)
  mov ax, 0013h
  int 10h

  ; Initialize the x87 floating-point unit
  finit

  ; Load the VGA video memory segment
  mov ax, 0A000h   ; Segment address of the VGA framebuffer
  mov es, ax       ; ES now points to video memory

  ; Clear the direction flag so string instructions increment addresses
  cld

  ; Clear DI so writing starts at the beginning of video memory
  xor di, di

  ; Outer loop: iterate over rows (Y direction)
  mov word [y],200
y_loop:
  ; Inner loop: iterate over columns (X direction)
  mov word [x],320
x_loop:

  ; The Mandelbrot set repeatedly applies the equation Z = Z*Z + C
  ; Z is a complex number, and C is the initial starting point

  ; Naturally, we use the FPU (Floating Point Unit) for these calculations.
  ; The CPU uses registers such as AX, BX, and CX to store values, but the FPU is
  ; stack-based, with 8 positions named ST(0), ST(1), and so on.
  ; Most FPU instructions operate on the top of the stack, ST(0).
  ; When a new value is pushed, all existing values move down one level, which
  ; can be difficult to track mentally.
  ; One way to simplify FPU code is to store intermediate results in memory,
  ; but that usually increases both code size and execution time.

  ; Compute the initial complex coordinate (C) from x and y

  ; Start with the Y coordinate
  fild word  [y]
  ; Center the Y coordinate around zero
  fsub dword [half_h]
  ; Apply zoom factor
  fmul dword [zoom]
  ; Offset to the chosen Mandelbrot center (Y)
  fadd dword [center_y]
  ; Store the result in c_y
  fst  dword [c_y]

  ; ST(0) now contains the initial Y value

  ; Now compute the X coordinate
  fild word  [x]
  ; Center the X coordinate around zero
  fsub dword [half_w]
  ; Apply zoom factor
  fmul dword [zoom]
  ; Offset to the chosen Mandelbrot center (X)
  fadd dword [center_x]
  ; Store the result in c_x
  fst  dword [c_x]

  ; ST(0) now contains the initial X value
  ; Since the FPU is stack-based, the Y value is now in ST(1)

  ; Current FPU stack layout:
  ; ST(0) = x
  ; ST(1) = y

  ; Number of iterations before giving up
  mov cx, 100
mandel_loop:
  ; Duplicate Y into ST(0), pushing existing values down
  fld st1
  ; Multiply with X to compute x*y
  ; Because of the duplicate, X is now in ST(1)
  fmul st1

  ; Duplicate Y again into ST(0)
  fld st2
  ; Multiply with Y to compute y*y
  fmul st3

  ; Load X into ST(0)
  fld st2
  ; Multiply with X to compute x*x
  fmul st3

  ; Stack now contains:
  ; ST(0) - x*x
  ; ST(1) - y*y
  ; ST(2) - x*y
  ; ST(3) - x
  ; ST(4) - y

  ; Check if the magnitude of Z is greater than 2 using Pythagoras
  ; sqrt(x*x + y*y) < 2 ?
  ; To avoid a square root, compare against 4 instead
  ; x*x + y*y < 4 (since 2*2 = 4)
  ; Duplicate x*x
  fld st0
  ; Add y*y
  fadd st2

  ; Have we escaped?
  fld dword [_4]
  fcompp
  fstsw ax
  sahf
  jb mandel_early_exit

  ; Not escaped, continue iterating
  ; Complex multiplication: Z*Z
  ; If Z = (x, y), then:
  ; Z*Z = (x*x - y*y, 2*x*y)
  ; Then add C

  ; Compute x*x - y*y
  ; Load x*x
  fld st0
  ; Subtract y*y
  fsub st2
  ; Add C.x
  fadd dword [c_x]
  ; Replace X on the stack with the new value
  fstp st4

  ; We no longer need x*x and y*y
  ; Pop x*x
  fstp st0
  ; Pop y*y
  fstp st0
  ; Compute 2*x*y by doubling x*y
  fadd st0
  ; Add C.y
  fadd dword [c_y]
  ; Replace Y on the stack with the new value
  fstp st2

  ; Decrement iteration counter
  dec cx
  jnz mandel_loop
mandel_exit:
  ; To avoid FPU stack overflow, remove X and Y
  ; This restores the stack to its original state
  ; Pop Y
  fstp st0
  ; Pop X
  fstp st0

  ; Use the remaining iteration count as a color value
  ; This produces a simple but visible Mandelbrot image
  mov ax,cx
  stosb

  ; Decrement X until the entire row is drawn
  dec word [x]
  ; Loop while X is not zero
  jnz x_loop

  ; Decrement Y until all rows are drawn
  dec word [y]
  ; Loop while Y is not zero
  jnz y_loop

  ; Wait for a key press (blocks until a key is pressed)
  mov ah, 00h
  int 16h

  ; Restore standard text mode (80x25)
  mov ax, 0003h
  int 10h

  ; Return control to DOS
  ret
mandel_early_exit:
  ; On early exit, clean up the FPU stack
  ; Remove x*x, y*y, and x*y
  ; Pop x*x
  fstp st0
  ; Pop y*y
  fstp st0
  ; Pop x*y
  fstp st0
  jmp mandel_exit

; DATA section

; Constant used for comparison with 4.0
_4        dd  4.0
; Mandelbrot center coordinates
center_x  dd  -0.5
center_y  dd  0.0
; Zoom factor
zoom      dd  0.01

; Half of the screen resolution
half_w    dd  160.0
half_h    dd  100.0

; BSS section - variables are uninitialized at program start
; and may contain arbitrary values
section .bss
x   resb 2
y   resb 2
c_x resb 4
c_y resb 4

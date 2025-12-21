; Assemble with: nasm -f bin -o mandel_brot.com mandel_brot.asm -l mandel_brot.lst

  BITS 16
  ORG 0x100

start:
  ; Switch to VGA video mode 13h (320x200 pixels, 256 colors)
  mov ax, 0013h
  int 10h

  ; Initialize the x87 floating-point unit
  finit

  ; Set up ES to point to VGA video memory
  mov ax, 0A000h   ; VGA framebuffer starts at segment 0xA000
  mov es, ax       ; ES now points to video memory

  ; Clear the direction flag so string instructions increment addresses
  cld

  ; Start writing at the beginning of video memory
  xor di, di

  ; Algorithm overview:
  ; for each pixel (x,y):
  ;   C = convert pixel to complex coordinate
  ;   Z = C
  ;   for iteration = 0 to MAX_ITERATIONS:
  ;     Z = Z*Z + C
  ;     if |Z| > 2: break
  ;   color = iteration count

  ; Outer loop: iterate over rows (Y direction)
  mov word [y],200
y_loop:
  ; Inner loop: iterate over columns (X direction)
  mov word [x],320
x_loop:

  ; The Mandelbrot set uses the iterative formula: Z = Z*Z + C
  ; where both Z and C are complex numbers, and C is the pixel coordinate

  ; We use the FPU (Floating Point Unit) for these calculations.
  ; Unlike CPU registers (AX, BX, CX), the FPU is stack-based with 8 slots
  ; named ST(0), ST(1), etc. Most FPU instructions operate on ST(0), the top
  ; of the stack. When you push a new value, everything shifts down one slot,
  ; which can be tricky to track.
  ; To simplify FPU code, you can store intermediate results in memory,
  ; but this increases both code size and execution time.

  ; Especially the floating point store operation have two modes.
  ; Popping mode (fstp) or non-popping mode (fst).
  ; fstp stores and then pop the value of the stack
  ; fst stores the value while leaving the value on the stack
  ; fstp st0 means popping the top element without storing it

  ; Convert pixel coordinates (x, y) to the complex number C

  ; Start with the Y coordinate
  fild word  [y]
  ; Center Y around zero (subtract half the screen height)
  fsub dword [half_h]
  ; Scale by zoom factor
  fmul dword [zoom]
  ; Offset to center the view on the desired region
  fadd dword [center_y]
  ; Store the imaginary component of C
  fst  dword [c_y]

  ; ST(0) now contains the imaginary part of C

  ; Now compute the X coordinate
  fild word  [x]
  ; Center X around zero (subtract half the screen width)
  fsub dword [half_w]
  ; Scale by zoom factor
  fmul dword [zoom]
  ; Offset to center the view on the desired region
  fadd dword [center_x]
  ; Store the real component of C
  fst  dword [c_x]

  ; ST(0) now contains the real part of C
  ; The imaginary part is now in ST(1) due to the stack structure

  ; Current FPU stack layout:
  ; ST(0) = x (real part)
  ; ST(1) = y (imaginary part)

  ; Maximum iterations before considering a point "in the set"
  mov cx, 100
mandel_loop:
  ; Duplicate y into ST(0), pushing existing values down the stack
  fld st1
  ; Multiply by x to compute x*y
  ; (x is now in ST(1) due to the duplicate)
  fmul st1

  ; Stack now contains:
  ; ST(0) = x*y
  ; ST(1) = x
  ; ST(2) = y

  ; Duplicate y again into ST(0)
  fld st2
  ; Square y to compute y*y
  fmul st3

  ; Stack now contains:
  ; ST(0) = y*y
  ; ST(1) = x*y
  ; ST(2) = x
  ; ST(3) = y

  ; Load x into ST(0)
  fld st2
  ; Square x to compute x*x
  fmul st3

  ; Stack now contains:
  ; ST(0) = x*x
  ; ST(1) = y*y
  ; ST(2) = x*y
  ; ST(3) = x
  ; ST(4) = y

  ; Check if Z has escaped (magnitude > 2)
  ; Normally: sqrt(x*x + y*y) < 2
  ; To avoid the square root, we compare x*x + y*y < 4 instead
  ; Duplicate x*x
  fld st0
  ; Add y*y to get the magnitude squared
  fadd st2

  ; Check if we've escaped (magnitude squared >= 4)
  ; Push 4.0 onto the FPU stack
  fld dword [_4]
  ; Compare ST(0) with ST(1), then pop both values
  ; This compares 4.0 with (x*x + y*y)
  fcompp
  ; Copy FPU status flags to AX register
  ; (The FPU has its own flags separate from the CPU flags)
  fstsw ax
  ; Copy AH into the CPU's flag register
  ; This makes the FPU comparison result available to CPU jump instructions
  sahf
  ; Jump if below: if (x*x + y*y) < 4.0, the point has escaped
  jb mandel_early_exit

  ; Point hasn't escaped yet, continue iterating
  ; Apply the Mandelbrot formula: Z = Z*Z + C
  ; For complex numbers, if Z = (x, y):
  ; Z*Z = (x*x - y*y, 2*x*y)
  ; Then we add C

  ; Compute the new real part: x*x - y*y + C.x
  ; Load x*x
  fld st0
  ; Subtract y*y
  fsub st2
  ; Add the real component of C
  fadd dword [c_x]
  ; Store as the new x value
  fstp st4

  ; Clean up values we no longer need
  ; Pop x*x
  fstp st0
  ; Pop y*y
  fstp st0

  ; Stack now contains:
  ; ST(0) = x*y
  ; ST(1) = x
  ; ST(2) = y

  ; Compute the new imaginary part: 2*x*y + C.y
  ; Double x*y
  fadd st0
  ; Add the imaginary component of C
  fadd dword [c_y]
  ; Store as the new y value
  fstp st2

  ; Stack now contains:
  ; ST(0) = x
  ; ST(1) = y

  ; Decrement iteration counter and continue if not done
  dec cx
  jnz mandel_loop
mandel_exit:
  ; Clean up the FPU stack to prevent overflow
  ; We need to restore the stack to its original state
  ; Pop y
  fstp st0
  ; Pop x
  fstp st0

  ; Use the iteration count as the color (higher count = darker)
  ; This creates the characteristic Mandelbrot coloring
  mov ax,cx
  stosb

  ; Move to the next pixel in the current row
  dec word [x]
  ; Continue until the entire row is complete
  jnz x_loop

  ; Move to the next row
  dec word [y]
  ; Continue until all rows are complete
  jnz y_loop

  ; Wait for a keypress before exiting
  mov ah, 00h
  int 16h

  ; Return to text mode (80x25 characters)
  mov ax, 0003h
  int 10h

  ; Exit program and return to DOS
  ret
mandel_early_exit:
  ; Point escaped early - clean up the FPU stack before continuing
  ; Remove intermediate values we calculated
  ; Pop x*x
  fstp st0
  ; Pop y*y
  fstp st0
  ; Pop x*y
  fstp st0
  jmp mandel_exit

; DATA section

; Constant value 4.0 for escape radius comparison
_4        dd  4.0
; Center point of the Mandelbrot view
center_x  dd  -0.5
center_y  dd  0.0
; Zoom level (smaller = more zoomed in)
zoom      dd  0.01

; Half of the screen dimensions (for centering calculations)
half_w    dd  160.0
half_h    dd  100.0

; BSS section - uninitialized variables
; These will contain arbitrary values at program start
section .bss
x   resb 2
y   resb 2
c_x resb 4
c_y resb 4
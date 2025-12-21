; Assemble with: nasm -f bin -o mandel_brot.com mandel_brot.asm -l mandel_brot.lst

  BITS 16
  ORG 0x100

start:
  ; Switch to VGA video mode 13h (320x200, 256 colors)
  mov ax, 0013h
  int 10h

  ; Load the VGA video memory segment
  mov ax, 0A000h   ; Segment address of the VGA framebuffer
  mov es, ax       ; ES now points to video memory

  ; Clear the direction flag so string instructions move forward
  cld

  ; Clear DI so writing starts at the beginning of video memory
  xor di, di

  ; Outer loop: iterate over rows (Y direction)
  mov word [y],200
y_loop:
  ; Inner loop: iterate over columns (X direction)
  mov word [x],320
x_loop:

  ; Compute the pixel color as x + y
  ; Since we count downwards, the top-left pixel starts at
  ; coordinates (320,200) and the bottom-right ends at (1,1)
  mov ax,[x]
  add ax,[y]

  ; STOSB is a string instruction with implicit operands:
  ; - Writes AL (the low byte of AX) to memory at ES:DI
  ; - Advances DI by one byte because DF is cleared
  stosb

  ; Decrement X until the entire row has been written
  dec word [x]
  ; Jump back if the result is not zero
  jnz x_loop

  ; Decrement Y until all rows have been written
  dec word [y]
  ; Jump back if the result is not zero
  jnz y_loop

  ; Wait for a key press (this call blocks until a key is available)
  mov ah, 00h
  ; Invoke the BIOS Keyboard Services to read a key
  int 16h

  ; Restore standard text mode (80x25)
  mov ax, 0003h
  ; Invoke the BIOS Video Services to switch back to text mode
  int 10h

  ; Return control to DOS
  ret

; DATA section

center_x  dd  1.5
center_y  dd  0.0
zoom      dd  0.1
; BSS section - variables are uninitialized at program start
; and may contain arbitrary values
section .bss
x resb 2
y resb 2

; Assemble with: nasm -f bin -o blog.com blog.asm -l blog.lst

  BITS 16
  ORG 0x100

start:
  ; Set video mode (320x200, 256 colors)
  mov ax, 0013h
  int 10h

  ; Setup for stosb (which will be used to write data to video memory)
  ; We need to setup es, di and df

  ; Initialize video memory segment
  mov ax, 0A000h   ; Video memory segment
  mov es, ax       ; ES points to video memory, this will be useful later

  ; Clears the df flag
  cld

  ; Clear di which will be used as a pointer into the video memory
  xor di, di

  ; Loop 200 times in y-direction
  mov word [y],200
y_loop:
  ; Loop 320 times in x-direction
  mov word [x],320
x_loop:

  ; Compute current pixel color by adding x and y
  ; Note: Since we counting towards top left pixel will have
  ; coordinate 320x200 and bottom right pixel have coordinate
  ; 1x1
  mov ax,[x]
  add ax,[y]

  ; stosb does alot of things in a single byte
  ; stosb writes the content in al (that is the lower byte of ax) to
  ; the address es+di, then stosb increments di (if df is 0, otherwise it decrements di)
  stosb

  ; Decrements x value until it's zero
  dec word [x]
  jnz x_loop

  ; Decrements y value until it's zero
  dec word [y]
  jnz y_loop

  ; Waits for a keypress
  mov ah, 00h
  int 16h

  ; Return to text mode
  mov ax, 0003h
  int 10h

  ; Return to DOS
  ret

; BSS section - This data is uninitalized when the program starts
;   and might contain garbage data
section .bss
x resb 2
y resb 2

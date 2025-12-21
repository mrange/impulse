; Assemble with: nasm -f bin -o sb.com sb.asm -l sb.lst

    BITS 16
    ORG 0x100

; Sound Blaster Port Definitions (Standard Base Address 220h)
DSP_RESET   equ 0x226   ; Write: 1 to reset, wait >3us, write 0
DSP_READ    equ 0x22A   ; Read: Data from DSP
DSP_WRITE   equ 0x22C   ; Write: Command or Data to DSP
DSP_STATUS  equ 0x22E   ; Read: Bit 7 = DSP busy (1=Busy/Buffer Full, 0=Ready for command/data)
DSP_READ_STATUS equ 0x22A ; Read: Bit 7 = Data available to read (1=Available, 0=Not Available) - Note: Same port as DSP_READ

start:
    ; --- Reset DSP ---
    mov dx, DSP_RESET
    mov al, 1
    out dx, al

    ; Short delay (~5 microseconds minimum, let's do more)
    ; Using loop is CPU speed dependent. Let's use a simple count.
    mov cx, 0xFFFF ; Increase delay significantly
.reset_delay_loop:
    loop .reset_delay_loop

    ; End reset pulse
    xor al, al
    out dx, al

    ; --- Wait for DSP Ready Confirmation (0xAA) ---
    ; Wait until data is available in the read buffer
.wait_dsp_read_ready_loop:
    mov dx, DSP_READ_STATUS
    in al, dx
    test al, 0x80   ; Check bit 7 (Data Available)
    jz .wait_dsp_read_ready_loop ; Loop if bit 7 is 0 (no data)

    ; Read the data byte from the DSP
    mov dx, DSP_READ
    in al, dx

    ; Check if it's the 0xAA confirmation byte
    cmp al, 0xAA
    jne reset_failed ; Or loop back to wait/retry, but failure is simpler for demo

    ; --- Send Direct DAC Command (0x10) ---
    call wait_dsp_write_ready ; Wait until DSP is ready to receive command
    mov dx, DSP_WRITE
    mov al, 0x10      ; Direct DAC output command
    out dx, al

    ; --- Sound Generation Loop ---
.sound_loop:
    ; Output Low Value (0x00)
    call wait_dsp_write_ready ; Wait until DSP is ready to receive data
    mov dx, DSP_WRITE
    mov al, 0x00
    out dx, al

    ; Delay for frequency control (adjust CX for pitch)
    mov cx, 500       ; Much longer delay! Lower value = higher pitch
.delay1:
    loop .delay1

    ; Output High Value (0xFF)
    call wait_dsp_write_ready ; Wait until DSP is ready to receive data
    mov dx, DSP_WRITE
    mov al, 0xFF
    out dx, al

    ; Delay for frequency control (should be same as above for 50% duty cycle)
    mov cx, 500       ; Much longer delay!
.delay2:
    loop .delay2

    ; Check for keypress to exit (non-destructive)
    mov ah, 0x01
    int 0x16          ; BIOS check keyboard buffer
    jz .sound_loop    ; If ZF=1 (Zero Flag set), no key waiting, loop back

    ; Key was pressed, consume it from buffer (optional but good practice)
    mov ah, 0x00
    int 0x16

    ; --- Exit Program ---
    ; Optional: Could send command 0xD3 (DSP Speaker Off) or reset again
reset_failed: ; Also jump here if reset fails
    ret               ; Return to DOS

; --- Subroutine: Wait for DSP Write Ready ---
; Waits until DSP is ready to accept a command or data byte.
; Destroys: AX, DX
wait_dsp_write_ready:
    mov dx, DSP_STATUS ; Port to check write readiness
.wait_loop:
    in al, dx        ; Read status byte
    test al, 0x80    ; Check bit 7 (Input Buffer Full / Busy flag)
    jnz .wait_loop   ; Loop if bit 7 is 1 (DSP is busy / buffer full)
    ret              ; Return if bit 7 is 0 (DSP is ready)
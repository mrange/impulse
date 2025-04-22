; Assemble with: nasm -f bin -o demo.com demo.asm -l demo.lst

    bits 16         ; 16-bit real mode
    org 100h        ; COM file format starts at 100h

section .text
start:
    ; Set up the timer (channel 2)
    mov al, 10110110b    ; Channel 2, mode 3 (square wave), binary
    out 43h, al

    ; Turn on the speaker by setting bits 0 and 1 of port 61h
    in al, 61h           ; Read current value
    or al, 3             ; Set bits 0 and 1
    out 61h, al          ; Write back to enable speaker

    ; Calculate frequency value (middle C = 262 Hz)
    ; PIT frequency is 1193180 Hz
    mov dx, 0            ; Clear DX for division
    mov eax, 1193180
    mov ecx, 440          ; Desired frequency
    div ecx               ; Result in AX = 1193180 / 262

    ; Send the frequency value to the timer
    out 42h, al          ; Send low byte
    mov al, ah
    out 42h, al          ; Send high byte

    ; Wait for a key press
    xor ax, ax           ; Clear AX (AH = 0: wait for keypress)
    int 16h              ; BIOS keyboard interrupt

    ; Calculate frequency value (middle C = 262 Hz)
    ; PIT frequency is 1193180 Hz
    mov dx, 0            ; Clear DX for division
    mov eax, 1193180
    mov ecx, 262          ; Desired frequency
    div ecx               ; Result in AX = 1193180 / 262

    ; Send the frequency value to the timer
    out 42h, al          ; Send low byte
    mov al, ah
    out 42h, al          ; Send high byte

    ; Wait for a key press
    xor ax, ax           ; Clear AX (AH = 0: wait for keypress)
    int 16h              ; BIOS keyboard interrupt

    ; Turn off the speaker
    in al, 61h           ; Read current value
    and al, 11111100b    ; Clear bits 0 and 1
    out 61h, al          ; Write back to disable speaker

    ; Exit program
    mov ax, 4C00h        ; DOS function: exit program
    int 21h              ; Call DOS
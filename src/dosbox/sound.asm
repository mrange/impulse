; Assemble with: nasm -f bin -o sound.com sound.asm -l sound.lst

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

    xor ebx, ebx

main_loop:
    mov eax, ebx
    shr eax, 12
    mov ecx, eax
    mov eax, ebx
    shr eax, 8
    or  ecx, eax
    and ecx, 42
    add ecx, 110

    ; Calculate frequency value (middle C = 262 Hz)
    ; PIT frequency is 1193180 Hz
    xor edx, edx
    mov eax, 1193180
    div ecx               ; Result in AX = 1193180 / 262

    ; Send the frequency value to the timer
    out 42h, al          ; Send low byte
    mov al, ah
    out 42h, al          ; Send high byte

    mov ecx, 18000
.wait:
    dec ecx
    jnz .wait

    add ebx, 400

    ; Check for keypress to exit
    mov ah, 1
    int 16h
    jz main_loop

    ; Turn off the speaker
    in al, 61h           ; Read current value
    and al, 11111100b    ; Clear bits 0 and 1
    out 61h, al          ; Write back to disable speaker

    ; Exit program
    mov ax, 4C00h        ; DOS function: exit program
    int 21h              ; Call DOS


a   dd  11
b   dd  17
c   dd  13
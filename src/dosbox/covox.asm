; Assemble with: nasm -f bin -o covox.com covox.asm -l covox.lst

           ;-----------------------------------
           ; MUZAK58 by wiRe/NpM
           ;-----------------------------------
            section .text
            org     100h

           ;--------------------------------- ;---------- ;muzak sequence table
  seqtbl:   dw      0x1413                    ;1314       ;  t * [3,1,4,1][3&t>>10]       ;! 1314       adc dx,[si]
            dw      0x6C66                    ;666C       ;    * [6,6,12,6][3&t>>11]      ;! 666C       o32 insb
            dw      0x2242                    ;4222       ;    * [2,4,2,2][3&t>>12]       ;! 42         inc dx
            dw      0x6495                    ;9564       ;    * [5,9,4,6][3&t>>13]       ;! 22956484   and dl,[di-0x7b9c]
            dw      0x4484                    ;8444       ;    * [4,8,4,4][3&t>>14] >> 8  ;! 44         inc sp

            mov     al, 0b00010000            ;B010       ;write 8253/8254 PIT command/mode register: resets PIT channel #0
            out     43h, al                   ;E643       ;  [7:6] channel #0, [5:4] LSB only, [3:1] mode0 (one-shot), [0] 16-bit binary

           ;--------------------------------- ;---------- ;present next audio sample (DX:BX = 32-bit sample counter)
  bbeat:    add     al, 149                   ;04xx       ;  calculate new timer period (AL = 42..148)
            out     40h, al                   ;E640       ;  rearm timer

            inc     bx                        ;43         ;  increment 16-bit timer counter

            pusha                             ;60         ;  store all registers
           ;mov     si, seqtbl                ;BExxxx     ;  load address of sequence table into SI (here SI already points to seqtbl by default)
            mov     dx, bx                    ;89DA       ;  load start value into DX
            mov     cl, 5                     ;B1xx       ;  init index counter inside CX (CH must be zero already!)
  bbeat_lp: push    cx                        ;51         ;  store CX counter
            mov     cl, 01100b                ;B1xx       ;  get bit sequence from time into CL
            and     cl, bh                    ;20F9       ;    CL := offset to 1 out of 4 entries
            lodsw                             ;AD         ;  load next sequence table entry (AX := DS:[SI]; SI := SI + 2)
            ror     ax, cl                    ;D3C8       ;  select sequence entry at bit-offset 0, 4, 8 or 12
            and     ax, 01111b                ;83E00F     ;  each sequence entry is 4 bits only (AX &= 15)
            mul     dx                        ;F7E2       ;  multiply (DX:AX := AX ∗ DX)
            xchg    ax, dx                    ;92         ;    DX := updated 16-bit sample
            pop     cx                        ;59         ;  restore CX counter
            shr     bx, 1                     ;D1ED       ;  get next bit sequence from time
            loop    bbeat_lp                  ;E2xx       ;  loop until all bits are out

            mov     al, dh                    ;88F0       ;  get sample data into AL
            mov     dx, 0378h                 ;BA7803     ;  load LPT1 port address into DX
            out     dx, al                    ;EE         ;  send 8-bit sample data to COVOX device
            popa                              ;61         ;  restore all registers (especially BX, CX, DX, SI)

  main_lp: ;--------------------------------- ;---------- ;read 8253/8254 PIT ch#0 counter value (ch#0 must be reconfigured to 0b00010000)
            in      al, 40h                   ;E440       ;  read low-byte
            cmp     al, 148                   ;3Cxx       ;  did timer counter overflowed to 149..0FFh?
            jo      short bbeat               ;71xx       ;    yes -> play

           ;... the place for your intro

            jmp     short main_lp             ;75xx       ;  loop forever

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

Start:   jmp       Instal                   ; instalace programu

Old10    dd        0                        ; pñvodn° adresa obsluhy INT 10h

; -----------------------------------------------------------------------------
;        Obsluha p©eru®en° INT 10h
; -----------------------------------------------------------------------------

Int10    PROC      FAR

         pushf
         cmp       ax,3
         je        Int103
         popf
         jmp       dword ptr cs:[Old10]     ; skok na pñvodn° obsluhu INT 10h

; ------ fonty se p©einstaluj°

Int103:  call      dword ptr cs:[Old10]     ; vol†n° pñvodn° funkce

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es

; ------ stanoven° adresy fontu podle poátu linek na znak

         xor       ax,ax
         mov       ds,ax
         cmp       byte ptr ds:[485h],16
         jne       Int109


         call      InitRegF                 ; inicializace registrñ pro fonty

         push      cs
         pop       ds
         mov       ax,0a000h
         mov       es,ax
         mov       dx,256
         mov       si,offset Font16
         xor       di,di
         cld
Int104:  mov       cx,16/2
         rep       movsw
         add       di,32-16
         dec       dx
         jnz       Int104

         call      InitRegT                 ; inicializace registrñ pro text

; ------ n†vrat registrñ

Int109:  pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         iret

Int10    ENDP

; -----------------------------------------------------------------------------
;     Inicializace registrñ videokarty na reëim definice fontñ
; -----------------------------------------------------------------------------

InitRegF PROC      NEAR

         mov       ah,2                     ; átec° rovina
         mov       cx,4                     ; nastaven° mapov†n° pro fonty
         mov       bx,407h                  ; BH=roviny, BL=prokl†d†n°
         jmp       short InitReg            ; inicializace registrñ

InitRegF ENDP

; -----------------------------------------------------------------------------
;        Inicializace registrñ videokarty na textovò videom¢d
; -----------------------------------------------------------------------------

InitRegT PROC      NEAR

         mov       ah,0                     ; átec° rovina
         mov       cl,0eh                   ; registr mapov†n° pro CGA
         mov       ch,10h                   ; registr m¢du - prokl†d†n°
         mov       bx,303h                  ; BH=roviny, BL=prokl†d†n°

InitRegT ENDP

; -----------------------------------------------------------------------------
;        Inicializace registrñ videokarty
; -----------------------------------------------------------------------------
; VSTUP: AH=átec° rovina (0=text, 1=atributy, 2=fonty)
;        BH=roviny k z†pisu (bit 0 = text, bit 1 = atributy, bit 2 = fonty)
;        BL=nastaven° prokl†d†n° (3=je prokl†d†n° rovin, 7=sekvenán° adresy)
;        CL=nastaven° mapov†n° (04h=A000h, 0Ah=B000h, 0Eh=B800h)
;        CH=registr m¢du (0=sekvenán° adresov†n°, 10h=prokl†danÇ adresov†n°)
; -----------------------------------------------------------------------------
; zniáenÇ registry: AX, DX
; -----------------------------------------------------------------------------

InitReg  PROC      NEAR

; ------ volba rovin pro z†pis (maska)

         mov       dx,3c4h                  ; b†zov† adresa 03c4h
         mov       al,2
         out       dx,al                    ; volba registru 2
         inc       dx
         mov       al,bh                    ; roviny k z†pisu
         out       dx,al                    ; nastaven° rovin pro z†pis

; ------ nastav. prokl†d†n° bajtñ sud†/lich†

         dec       dx
         mov       al,4
         out       dx,al                    ; volba registru 4
         inc       dx
         mov       al,bl                    ; prokl†d†n°
         out       dx,al                    ; nastaven° prokl†d†n° bajtñ

; ------ nastaven° mapov†n° videopamàti (adresa)

         mov       dl,0ceh                  ; port 03ceh/03cfh
         mov       al,6
         out       dx,al                    ; volba registru 6
         inc       dx
         mov       al,cl                    ; nastaven° mapov†n°
         out       dx,al                    ; nastaven° mapov†n° videopamàti

; ------ nastaven° registru m¢du (áten° i z†pis - MïD 0)

         dec       dx
         mov       al,5
         out       dx,al                    ; volba registru 5
         inc       dx
         mov       al,ch                    ; registr m¢du
         out       dx,al

; ------ volba roviny pro áten°

         dec       dx
         mov       al,4
         out       dx,al                    ; volba registru 4
         inc       dx
         mov       al,ah                    ; rovina ke áten°
         out       dx,al                    ; nastaven° roviny ke áten°
         ret

InitReg  ENDP

;˛
Font16   label     byte
         db        00000000b                ; 0
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 1
         db        00000000b
         db        01111110b
         db        10000001b
         db        10100101b
         db        10000001b
         db        10000001b
         db        10111101b
         db        10011001b
         db        10000001b
         db        10000001b
         db        01111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 2
         db        00000000b
         db        01111110b
         db        11111111b
         db        11011011b
         db        11111111b
         db        11111111b
         db        11000011b
         db        11100111b
         db        11111111b
         db        11111111b
         db        01111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 3
         db        00000000b
         db        00000000b
         db        00000000b
         db        01101100b
         db        11111110b
         db        11111110b
         db        11111110b
         db        11111110b
         db        01111100b
         db        00111000b
         db        00010000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 4
         db        00000000b
         db        00000000b
         db        00000000b
         db        00010000b
         db        00111000b
         db        01111100b
         db        11111110b
         db        01111100b
         db        00111000b
         db        00010000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 5
         db        00000000b
         db        00000000b
         db        00011000b
         db        00111100b
         db        00111100b
         db        11100111b
         db        11100111b
         db        11100111b
         db        10011001b
         db        00011000b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 6
         db        00000000b
         db        00000000b
         db        00011000b
         db        00111100b
         db        01111110b
         db        11111111b
         db        11111111b
         db        01111110b
         db        00011000b
         db        00011000b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 7
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00011000b
         db        00111100b
         db        00111100b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        11111111b                ; 8
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11100111b
         db        11000011b
         db        11000011b
         db        11100111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b

         db        00000000b                ; 9
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00111100b
         db        01100110b
         db        01000010b
         db        01000010b
         db        01100110b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        11111111b                ; 10
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11000011b
         db        10011001b
         db        10111101b
         db        10111101b
         db        10011001b
         db        11000011b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b

         db        00000000b                ; 11
         db        00000000b
         db        00011110b
         db        00001110b
         db        00011010b
         db        00110010b
         db        01111000b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        01111000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 12
         db        00000000b
         db        00111100b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        00111100b
         db        00011000b
         db        01111110b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 13
         db        00000000b
         db        00111111b
         db        00110011b
         db        00111111b
         db        00110000b
         db        00110000b
         db        00110000b
         db        00110000b
         db        01110000b
         db        11110000b
         db        11100000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 14
         db        00000000b
         db        01111111b
         db        01100011b
         db        01111111b
         db        01100011b
         db        01100011b
         db        01100011b
         db        01100011b
         db        01100111b
         db        11100111b
         db        11100110b
         db        11000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 15
         db        00000000b
         db        00000000b
         db        00011000b
         db        00011000b
         db        11011011b
         db        00111100b
         db        11100111b
         db        00111100b
         db        11011011b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 16
         db        10000000b
         db        11000000b
         db        11100000b
         db        11110000b
         db        11111000b
         db        11111110b
         db        11111000b
         db        11110000b
         db        11100000b
         db        11000000b
         db        10000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 17
         db        00000010b
         db        00000110b
         db        00001110b
         db        00011110b
         db        00111110b
         db        11111110b
         db        00111110b
         db        00011110b
         db        00001110b
         db        00000110b
         db        00000010b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 18
         db        00000000b
         db        00011000b
         db        00111100b
         db        01111110b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        01111110b
         db        00111100b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 19
         db        00000000b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        00000000b
         db        01100110b
         db        01100110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 20
         db        00000000b
         db        01111111b
         db        11011011b
         db        11011011b
         db        11011011b
         db        01111011b
         db        00011011b
         db        00011011b
         db        00011011b
         db        00011011b
         db        00011011b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 21
         db        01111100b
         db        11000110b
         db        01100000b
         db        00111000b
         db        01101100b
         db        11000110b
         db        11000110b
         db        01101100b
         db        00111000b
         db        00001100b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 22
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111110b
         db        11111110b
         db        11111110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 23
         db        00000000b
         db        00011000b
         db        00111100b
         db        01111110b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        01111110b
         db        00111100b
         db        00011000b
         db        01111110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 24
         db        00000000b
         db        00011000b
         db        00111100b
         db        01111110b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 25
         db        00000000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        01111110b
         db        00111100b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 26
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00011000b
         db        00001100b
         db        11111110b
         db        00001100b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 27
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00110000b
         db        01100000b
         db        11111110b
         db        01100000b
         db        00110000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 28
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11000000b
         db        11000000b
         db        11000000b
         db        11000000b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 29
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00100100b
         db        01100110b
         db        11111111b
         db        01100110b
         db        00100100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 30
         db        00000000b
         db        00000000b
         db        00000000b
         db        00010000b
         db        00111000b
         db        00111000b
         db        01111100b
         db        01111100b
         db        11111110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 31
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111110b
         db        11111110b
         db        01111100b
         db        01111100b
         db        00111000b
         db        00111000b
         db        00010000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 32 " "
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 33 "!"
         db        00000000b
         db        00011000b
         db        00111100b
         db        00111100b
         db        00111100b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 34 """
         db        01100011b
         db        01100011b
         db        01100011b
         db        00100010b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 35 "#"
         db        00000000b
         db        00000000b
         db        01101100b
         db        01101100b
         db        11111110b
         db        01101100b
         db        01101100b
         db        01101100b
         db        11111110b
         db        01101100b
         db        01101100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00011000b                ; 36 "$"
         db        00011000b
         db        01111100b
         db        11000110b
         db        11000010b
         db        11000000b
         db        01111100b
         db        00000110b
         db        10000110b
         db        11000110b
         db        01111100b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 37 "%"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11000010b
         db        11000110b
         db        00001100b
         db        00011000b
         db        00110000b
         db        01100000b
         db        11000110b
         db        10000110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 38 "&"
         db        00000000b
         db        00111000b
         db        01101100b
         db        01101100b
         db        00111000b
         db        01110110b
         db        11011100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        01110110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 39 "'"
         db        00110000b
         db        00110000b
         db        00110000b
         db        01100000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 40 "("
         db        00000000b
         db        00001100b
         db        00011000b
         db        00110000b
         db        00110000b
         db        00110000b
         db        00110000b
         db        00110000b
         db        00110000b
         db        00011000b
         db        00001100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 41 ")"
         db        00000000b
         db        00110000b
         db        00011000b
         db        00001100b
         db        00001100b
         db        00001100b
         db        00001100b
         db        00001100b
         db        00001100b
         db        00011000b
         db        00110000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 42 "*"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        01100110b
         db        00111100b
         db        11111111b
         db        00111100b
         db        01100110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 43 "+"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00011000b
         db        00011000b
         db        11111111b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 44 ","
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00110000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 45 "-"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 46 "."
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 47 "/"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000010b
         db        00000110b
         db        00001100b
         db        00011000b
         db        00110000b
         db        01100000b
         db        11000000b
         db        10000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
;˛
         db        00000000b                ; 48 "0"
         db        01111100b
         db        11111110b
         db        11101110b
         db        11101110b
         db        11101110b
         db        11101110b
         db        11101110b
         db        11101110b
         db        11101110b
         db        11101110b
         db        11111110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 49 "1"
         db        00011100b
         db        00111100b
         db        01111100b
         db        11111100b
         db        11111100b
         db        00011100b
         db        00011100b
         db        00011100b
         db        00011100b
         db        00011100b
         db        00011100b
         db        00011100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 50 "2"
         db        01111100b
         db        11111110b
         db        11101110b
         db        11101110b
         db        00001110b
         db        00001110b
         db        00011110b
         db        00111100b
         db        01111000b
         db        11110000b
         db        11111110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 51 "3"
         db        01111100b
         db        11111110b
         db        11101110b
         db        11101110b
         db        00001110b
         db        00111100b
         db        00111100b
         db        00001110b
         db        00001110b
         db        11101110b
         db        11111110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 52 "4"
         db        00001110b
         db        00011110b
         db        00111110b
         db        01111110b
         db        11111110b
         db        11101110b
         db        11001110b
         db        11111110b
         db        11111110b
         db        00001110b
         db        00001110b
         db        00001110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 53 "5"
         db        11111110b
         db        11111110b
         db        11100000b
         db        11100000b
         db        11111100b
         db        11111110b
         db        00011110b
         db        00001110b
         db        00001110b
         db        11101110b
         db        11111110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 54 "6"
         db        00111100b
         db        01111100b
         db        11110000b
         db        11100000b
         db        11100000b
         db        11111100b
         db        11111110b
         db        11101110b
         db        11101110b
         db        11101110b
         db        11111110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 55 "7"
         db        11111110b
         db        11111110b
         db        00001110b
         db        00001110b
         db        00001110b
         db        00011110b
         db        00111100b
         db        01111000b
         db        01110000b
         db        01110000b
         db        01110000b
         db        01110000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 56 "8"
         db        01111100b
         db        11111100b
         db        11101110b
         db        11101110b
         db        11101110b
         db        01111100b
         db        01111100b
         db        11101110b
         db        11101110b
         db        11101110b
         db        11111110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 57 "9"
         db        01111100b
         db        11111110b
         db        11101110b
         db        11101110b
         db        11101110b
         db        11111110b
         db        01111110b
         db        00001110b
         db        00001110b
         db        00011110b
         db        01111100b
         db        01111000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 58 ":"
         db        00000000b
         db        00000000b
         db        00111000b
         db        00111000b
         db        00111000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00111000b
         db        00111000b
         db        00111000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 59 ";"
         db        00000000b
         db        00000000b
         db        00111000b
         db        00111000b
         db        00111000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00111000b
         db        00111000b
         db        00111000b
         db        01110000b
         db        01100000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 60 "<"
         db        00000000b
         db        00001110b
         db        00011110b
         db        00111100b
         db        01111000b
         db        11110000b
         db        11100000b
         db        11110000b
         db        01111000b
         db        00111100b
         db        00011110b
         db        00001110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 61 "="
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        11111110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 62 ">"
         db        00000000b
         db        11100000b
         db        11110000b
         db        01111000b
         db        00111100b
         db        00011110b
         db        00001110b
         db        00011110b
         db        00111100b
         db        01111000b
         db        11110000b
         db        11100000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 63 "?"
         db        01111100b
         db        11111110b
         db        11111110b
         db        11101110b
         db        00011110b
         db        00111100b
         db        00111000b
         db        00111000b
         db        00000000b
         db        00111000b
         db        00111000b
         db        00111000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 64 "@"
         db        00000000b
         db        01111100b
         db        11111110b
         db        11101110b
         db        11101110b
         db        11111110b
         db        11111110b
         db        11111110b
         db        11101100b
         db        11100000b
         db        11111100b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 65 "A"
         db        00010000b
         db        00111000b
         db        01111100b
         db        11111110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11111110b
         db        11111110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 66 "B"
         db        11111100b
         db        11111110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11111100b
         db        11111100b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11111110b
         db        11111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 67 "C"
         db        01111100b
         db        11111110b
         db        11000110b
         db        11000110b
         db        11000000b
         db        11000000b
         db        11000000b
         db        11000000b
         db        11000110b
         db        11000110b
         db        11111110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 68 "D"
         db        11111000b
         db        11111100b
         db        11001110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11001110b
         db        11111100b
         db        11111000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 69 "E"
         db        11111110b
         db        11111110b
         db        11000110b
         db        11000000b
         db        11000000b
         db        11111000b
         db        11111000b
         db        11000000b
         db        11000000b
         db        11000110b
         db        11111110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 70 "F"
         db        11111110b
         db        11111110b
         db        11000110b
         db        11000000b
         db        11000000b
         db        11111000b
         db        11111000b
         db        11000000b
         db        11000000b
         db        11000000b
         db        11000000b
         db        11100000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 71 "G"
         db        01111100b
         db        11111110b
         db        11000110b
         db        11000110b
         db        11000000b
         db        11000000b
         db        11001110b
         db        11001110b
         db        11000110b
         db        11000110b
         db        11111110b
         db        01111110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 72 "H"
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11111110b
         db        11111110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 73 "I"
         db        00111100b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 74 "J"
         db        00001111b
         db        00000110b
         db        00000110b
         db        00000110b
         db        00000110b
         db        00000110b
         db        00000110b
         db        00000110b
         db        11000110b
         db        11000110b
         db        11111110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 75 "K"
         db        11000110b
         db        11000110b
         db        11001110b
         db        11011100b
         db        11111000b
         db        11110000b
         db        11110000b
         db        11111000b
         db        11011100b
         db        11001110b
         db        11000110b
         db        11000110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 76 "L"
         db        11100000b
         db        11000000b
         db        11000000b
         db        11000000b
         db        11000000b
         db        11000000b
         db        11000000b
         db        11000000b
         db        11000000b
         db        11000110b
         db        11111110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 77 "M"
         db        11000110b
         db        11101110b
         db        11111110b
         db        11111110b
         db        11111110b
         db        11010110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 78 "N"
         db        11000110b
         db        11100110b
         db        11100110b
         db        11110110b
         db        11110110b
         db        11111110b
         db        11011110b
         db        11001110b
         db        11001110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 79 "O"
         db        00111000b
         db        01111100b
         db        11101110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11101110b
         db        01111100b
         db        00111000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 80 "P"
         db        11111100b
         db        11111110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11111110b
         db        11111100b
         db        11000000b
         db        11000000b
         db        11000000b
         db        11000000b
         db        11000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 81 "Q"
         db        00111000b
         db        01111100b
         db        11101110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11111110b
         db        11111100b
         db        01111100b
         db        00011100b
         db        00001110b
         db        00000110b
         db        00000000b

         db        00000000b                ; 82 "R"
         db        11111100b
         db        11111110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11111110b
         db        11111100b
         db        11111000b
         db        11011100b
         db        11001110b
         db        11000110b
         db        11000110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 83 "S"
         db        01111100b
         db        11111110b
         db        11000110b
         db        11000110b
         db        11100000b
         db        01110000b
         db        00011100b
         db        00000110b
         db        11000110b
         db        11000110b
         db        11111110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 84 "T"
         db        11111111b
         db        11111111b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 85 "U"
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11111110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 86 "V"
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11101110b
         db        01111100b
         db        00111000b
         db        00010000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 87 "W"
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11010110b
         db        11111110b
         db        11111110b
         db        11111110b
         db        01101100b
         db        01101100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 88 "X"
         db        11000110b
         db        11000110b
         db        11101110b
         db        01111100b
         db        01111100b
         db        00111000b
         db        00111000b
         db        01111100b
         db        01111100b
         db        11101110b
         db        11000110b
         db        11000110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 89 "Y"
         db        11000011b
         db        11000011b
         db        11000011b
         db        11100111b
         db        01111110b
         db        00111100b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 90 "Z"
         db        11111110b
         db        11111110b
         db        11000110b
         db        00000110b
         db        00001110b
         db        00011100b
         db        00111000b
         db        01110000b
         db        11100000b
         db        11000110b
         db        11111110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 91 "["
         db        01111110b
         db        01111110b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01111110b
         db        01111110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 92 "\"
         db        00000000b
         db        10000000b
         db        11000000b
         db        11100000b
         db        11110000b
         db        01111000b
         db        00111100b
         db        00011110b
         db        00001111b
         db        00000111b
         db        00000011b
         db        00000001b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 93 "]"
         db        01111110b
         db        01111110b
         db        00000110b
         db        00000110b
         db        00000110b
         db        00000110b
         db        00000110b
         db        00000110b
         db        00000110b
         db        00000110b
         db        01111110b
         db        01111110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00011000b                ; 94 "^"
         db        00111100b
         db        01111110b
         db        11100111b
         db        11000011b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 95 "_"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111111b
         db        11111111b
         db        00000000b

         db        01110000b                ; 96 "`"
         db        00111000b
         db        00011100b
         db        00001110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 97 "a"
         db        00000000b
         db        00000000b
         db        00000000b
         db        01111100b
         db        01111110b
         db        00001110b
         db        01111110b
         db        11111110b
         db        11001110b
         db        11001110b
         db        11111110b
         db        01110110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 98 "b"
         db        11000000b
         db        11000000b
         db        11000000b
         db        11000000b
         db        11111000b
         db        11111100b
         db        11001110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11111110b
         db        11011100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 99 "c"
         db        00000000b
         db        00000000b
         db        00000000b
         db        01111100b
         db        11111110b
         db        11000110b
         db        11000000b
         db        11000000b
         db        11000000b
         db        11000110b
         db        11111110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 100 "d"
         db        00000110b
         db        00000110b
         db        00000110b
         db        00000110b
         db        00111110b
         db        01111110b
         db        11100110b
         db        11000110b
         db        11000110b
         db        11001110b
         db        11111110b
         db        01110110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 101 "e"
         db        00000000b
         db        00000000b
         db        00000000b
         db        01111100b
         db        11111110b
         db        11000110b
         db        11111110b
         db        11111110b
         db        11000000b
         db        11000000b
         db        11111110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 102 "f"
         db        00111000b
         db        01111100b
         db        01101100b
         db        01101100b
         db        01100000b
         db        11110000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        11110000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 103 "g"
         db        00000000b
         db        00000000b
         db        00000000b
         db        01111010b
         db        11111110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11111110b
         db        01111110b
         db        00000110b
         db        11111110b
         db        01111100b
         db        00000000b

         db        00000000b                ; 104 "h"
         db        11000000b
         db        11000000b
         db        11000000b
         db        11000000b
         db        11011000b
         db        11111100b
         db        11101110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 105 "i"
         db        00000000b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00111000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 106 "j"
         db        00000000b
         db        00000110b
         db        00000110b
         db        00000000b
         db        00001110b
         db        00000110b
         db        00000110b
         db        00000110b
         db        00000110b
         db        00000110b
         db        00000110b
         db        01100110b
         db        01111110b
         db        00111100b
         db        00000000b

         db        00000000b                ; 107 "k"
         db        11000000b
         db        11000000b
         db        11000000b
         db        11000110b
         db        11001110b
         db        11011100b
         db        11111000b
         db        11111000b
         db        11011100b
         db        11001110b
         db        11000110b
         db        11000110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 108 "l"
         db        00111000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 109 "m"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11100110b
         db        11111111b
         db        11011011b
         db        11011011b
         db        11011011b
         db        11011011b
         db        11011011b
         db        11011011b
         db        11011011b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 110 "n"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11011100b
         db        01111110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 111 "o"
         db        00000000b
         db        00000000b
         db        00000000b
         db        01111100b
         db        11111110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11111110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 112 "p"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11011100b
         db        11111110b
         db        11100110b
         db        11100110b
         db        11100110b
         db        11100110b
         db        11100110b
         db        11111110b
         db        11111100b
         db        11000000b
         db        11000000b
         db        11000000b

         db        00000000b                ; 113 "q"
         db        00000000b
         db        00000000b
         db        00000000b
         db        01110110b
         db        11111110b
         db        11001110b
         db        11001110b
         db        11001110b
         db        11001110b
         db        11001110b
         db        11111110b
         db        01111110b
         db        00001110b
         db        00001110b
         db        00001110b

         db        00000000b                ; 114 "r"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11011100b
         db        11111110b
         db        01110110b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        11110000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 115 "s"
         db        00000000b
         db        00000000b
         db        00000000b
         db        01111110b
         db        11111110b
         db        11000000b
         db        11110000b
         db        01111100b
         db        00011110b
         db        00000110b
         db        11111110b
         db        11111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 116 "t"
         db        00010000b
         db        00110000b
         db        00110000b
         db        11111100b
         db        11111100b
         db        00110000b
         db        00110000b
         db        00110000b
         db        00110000b
         db        00110110b
         db        00111110b
         db        00011100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 117 "u"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11111100b
         db        01110110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 118 "v"
         db        00000000b
         db        00000000b
         db        00000000b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01111110b
         db        00111100b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 119 "w"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11000011b
         db        11000011b
         db        11000011b
         db        11011011b
         db        11011011b
         db        11111111b
         db        01100110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 120 "x"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11000110b
         db        01101100b
         db        00111000b
         db        00111000b
         db        00111000b
         db        01101100b
         db        11000110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 121 "y"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01111110b
         db        00000110b
         db        00001100b
         db        11111000b
         db        00000000b

         db        00000000b                ; 122 "z"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111110b
         db        11001100b
         db        00011000b
         db        00110000b
         db        01100000b
         db        11000110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 123 "{"
         db        00000000b
         db        00001110b
         db        00011000b
         db        00011000b
         db        00011000b
         db        01110000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00001110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 124 "|"
         db        00000000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 125 "}"
         db        00000000b
         db        01110000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00001110b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        01110000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 126 "~"
         db        00000000b
         db        01110110b
         db        11011100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 127 ""
         db        00000000b
         db        00000000b
         db        00000000b
         db        00010000b
         db        00111000b
         db        01101100b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        01100110b                ; 128 "Ä"
         db        00111100b
         db        00111100b
         db        01100110b
         db        11000010b
         db        11000000b
         db        11000000b
         db        11000000b
         db        11000000b
         db        11000010b
         db        01100110b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 129 "Å"
         db        00000000b
         db        11001100b
         db        11001100b
         db        00000000b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        01110110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 130 "Ç"
         db        00001100b
         db        00011000b
         db        00110000b
         db        00000000b
         db        01111100b
         db        11000110b
         db        11111110b
         db        11000000b
         db        11000000b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000011b                ; 131 "É"
         db        00000011b
         db        00011101b
         db        00001110b
         db        00001100b
         db        00111100b
         db        01101100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        01110110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 132 "Ñ"
         db        00000000b
         db        11001100b
         db        11001100b
         db        00000000b
         db        01111000b
         db        00001100b
         db        01111100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        01110110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        01100110b                ; 133 "Ö"
         db        00111100b
         db        11111000b
         db        01101100b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01101100b
         db        11111000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        01100110b                ; 134 "Ü"
         db        00111100b
         db        11111111b
         db        11011011b
         db        10011001b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 135 "á"
         db        01100110b
         db        00111100b
         db        00011000b
         db        00000000b
         db        01111100b
         db        11000110b
         db        11000000b
         db        11000000b
         db        11000000b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 136 "à"
         db        01100110b
         db        00111100b
         db        00011000b
         db        00000000b
         db        01111100b
         db        11000110b
         db        11111110b
         db        11000000b
         db        11000000b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        01100110b                ; 137 "â"
         db        00111100b
         db        11111110b
         db        01100110b
         db        01100010b
         db        01101000b
         db        01111000b
         db        01101000b
         db        01100000b
         db        01100010b
         db        01100110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00001100b                ; 138 "ä"
         db        00011000b
         db        11110000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100010b
         db        01100110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00001100b                ; 139 "ã"
         db        00011000b
         db        00111100b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000011b                ; 140 "å"
         db        00000011b
         db        00111001b
         db        00011010b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00001100b                ; 141 "ç"
         db        00011000b
         db        00111000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 142 "é"
         db        11000110b
         db        11000110b
         db        00010000b
         db        00111000b
         db        01101100b
         db        11000110b
         db        11000110b
         db        11111110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00001100b                ; 143 "è"
         db        00011000b
         db        00010000b
         db        00111000b
         db        01101100b
         db        11000110b
         db        11000110b
         db        11111110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00001100b                ; 144 "ê"
         db        00011000b
         db        11111110b
         db        01100110b
         db        01100010b
         db        01101000b
         db        01111000b
         db        01101000b
         db        01100000b
         db        01100010b
         db        01100110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 145 "ë"
         db        01100110b
         db        00111100b
         db        00011000b
         db        00000000b
         db        11111110b
         db        11001100b
         db        00011000b
         db        00110000b
         db        01100000b
         db        11000110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        01100110b                ; 146 "í"
         db        00111100b
         db        11111111b
         db        11000011b
         db        10000011b
         db        00000110b
         db        00001100b
         db        00011000b
         db        00110000b
         db        01100001b
         db        11000011b
         db        11111111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 147 "ì"
         db        00010000b
         db        00111000b
         db        01101100b
         db        00000000b
         db        01111100b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 148 "î"
         db        00000000b
         db        11000110b
         db        11000110b
         db        00000000b
         db        01111100b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00001100b                ; 149 "ï"
         db        00011000b
         db        00111000b
         db        01101100b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01101100b
         db        00111000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 150 "ñ"
         db        00111000b
         db        01101100b
         db        00111000b
         db        00000000b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        01110110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00001100b                ; 151 "ó"
         db        00011000b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 152 "ò"
         db        00001100b
         db        00011000b
         db        00110000b
         db        00000000b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01111110b
         db        00000110b
         db        00001100b
         db        11111000b
         db        00000000b

         db        00000000b                ; 153 "ô"
         db        11000110b
         db        11000110b
         db        00000000b
         db        00111000b
         db        01101100b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01101100b
         db        00111000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 154 "ö"
         db        11000110b
         db        11000110b
         db        00000000b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        01100110b                ; 155 "õ"
         db        00111100b
         db        01111100b
         db        11000110b
         db        11000110b
         db        01100000b
         db        00111000b
         db        00001100b
         db        00000110b
         db        11000110b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000011b                ; 156 "ú"
         db        00000011b
         db        11110001b
         db        01100010b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100010b
         db        01100110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00001100b                ; 157 "ù"
         db        00011000b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        00111100b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        01100110b                ; 158 "û"
         db        00111100b
         db        11111100b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01111100b
         db        01101100b
         db        01100110b
         db        01100110b
         db        01100110b
         db        11100110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000011b                ; 159 "ü"
         db        00000011b
         db        00010001b
         db        00110010b
         db        00110000b
         db        11111100b
         db        00110000b
         db        00110000b
         db        00110000b
         db        00110000b
         db        00110110b
         db        00011100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 160 "†"
         db        00001100b
         db        00011000b
         db        00110000b
         db        00000000b
         db        01111000b
         db        00001100b
         db        01111100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        01110110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 161 "°"
         db        00001100b
         db        00011000b
         db        00110000b
         db        00000000b
         db        00111000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 162 "¢"
         db        00001100b
         db        00011000b
         db        00110000b
         db        00000000b
         db        01111100b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 163 "£"
         db        00001100b
         db        00011000b
         db        00110000b
         db        00000000b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        01110110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 164 "§"
         db        01100110b
         db        00111100b
         db        00011000b
         db        00000000b
         db        11011100b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        01100110b                ; 165 "•"
         db        00111100b
         db        11011110b
         db        11100110b
         db        11110110b
         db        11111110b
         db        11011110b
         db        11001110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00010000b                ; 166 "¶"
         db        00101000b
         db        11010110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        01111110b                ; 167 "ß"
         db        11000011b
         db        00111000b
         db        01101100b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01101100b
         db        00111000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 168 "®"
         db        01100110b
         db        00111100b
         db        00011000b
         db        00000000b
         db        01111100b
         db        11000110b
         db        01100000b
         db        00111000b
         db        00001100b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 169 "©"
         db        01100110b
         db        00111100b
         db        00011000b
         db        00000000b
         db        11011100b
         db        01110110b
         db        01100010b
         db        01100000b
         db        01100000b
         db        01100000b
         db        11110000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 170 "™"
         db        00001100b
         db        00011000b
         db        00110000b
         db        00000000b
         db        11011100b
         db        01110110b
         db        01100010b
         db        01100000b
         db        01100000b
         db        01100000b
         db        11110000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00001100b                ; 171 "´"
         db        00011000b
         db        11111100b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01111100b
         db        01101100b
         db        01100110b
         db        01100110b
         db        01100110b
         db        11100110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 172 "¨"
         db        11000000b
         db        11000000b
         db        11000010b
         db        11000110b
         db        11001100b
         db        00011000b
         db        00110000b
         db        01100110b
         db        11001110b
         db        10011010b
         db        00111111b
         db        00000110b
         db        00001111b
         db        00000000b
         db        00000000b

         db        00000000b                ; 173 "≠"
         db        01111100b
         db        11000110b
         db        01100000b
         db        00111000b
         db        01101100b
         db        11000110b
         db        11000110b
         db        01101100b
         db        00111000b
         db        00001100b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 174 "Æ"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00110011b
         db        01100110b
         db        11001100b
         db        01100110b
         db        00110011b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 175 "Ø"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11001100b
         db        01100110b
         db        00110011b
         db        01100110b
         db        11001100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00010001b                ; 176 "∞"
         db        01000100b
         db        00010001b
         db        01000100b
         db        00010001b
         db        01000100b
         db        00010001b
         db        01000100b
         db        00010001b
         db        01000100b
         db        00010001b
         db        01000100b
         db        00010001b
         db        01000100b
         db        00010001b
         db        01000100b

         db        01010101b                ; 177 "±"
         db        10101010b
         db        01010101b
         db        10101010b
         db        01010101b
         db        10101010b
         db        01010101b
         db        10101010b
         db        01010101b
         db        10101010b
         db        01010101b
         db        10101010b
         db        01010101b
         db        10101010b
         db        01010101b
         db        10101010b

         db        11011101b                ; 178 "≤"
         db        01110111b
         db        11011101b
         db        01110111b
         db        11011101b
         db        01110111b
         db        11011101b
         db        01110111b
         db        11011101b
         db        01110111b
         db        11011101b
         db        01110111b
         db        11011101b
         db        01110111b
         db        11011101b
         db        01110111b

         db        00011000b                ; 179 "≥"
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00011000b                ; 180 "¥"
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        11111000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00011000b                ; 181 "µ"
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        11111000b
         db        00011000b
         db        11111000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00110110b                ; 182 "∂"
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        11110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00000000b                ; 183 "∑"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00000000b                ; 184 "∏"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111000b
         db        00011000b
         db        11111000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00110110b                ; 185 "π"
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        11110110b
         db        00000110b
         db        11110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00110110b                ; 186 "∫"
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00000000b                ; 187 "ª"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111110b
         db        00000110b
         db        11110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00110110b                ; 188 "º"
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        11110110b
         db        00000110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00110110b                ; 189 "Ω"
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00011000b                ; 190 "æ"
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        11111000b
         db        00011000b
         db        11111000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 191 "ø"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00011000b                ; 192 "¿"
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00011000b                ; 193 "¡"
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        11111111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 194 "¬"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111111b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00011000b                ; 195 "√"
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011111b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00000000b                ; 196 "ƒ"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00011000b                ; 197 "≈"
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        11111111b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00011000b                ; 198 "∆"
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011111b
         db        00011000b
         db        00011111b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00110110b                ; 199 "«"
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110111b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00110110b                ; 200 "»"
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110111b
         db        00110000b
         db        00111111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 201 "…"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00111111b
         db        00110000b
         db        00110111b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00110110b                ; 202 " "
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        11110111b
         db        00000000b
         db        11111111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 203 "À"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111111b
         db        00000000b
         db        11110111b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00110110b                ; 204 "Ã"
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110111b
         db        00110000b
         db        00110111b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00000000b                ; 205 "Õ"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111111b
         db        00000000b
         db        11111111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00110110b                ; 206 "Œ"
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        11110111b
         db        00000000b
         db        11110111b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00011000b                ; 207 "œ"
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        11111111b
         db        00000000b
         db        11111111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00110110b                ; 208 "–"
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        11111111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 209 "—"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111111b
         db        00000000b
         db        11111111b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00000000b                ; 210 "“"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111111b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00110110b                ; 211 "”"
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00111111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00011000b                ; 212 "‘"
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011111b
         db        00011000b
         db        00011111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 213 "’"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00011111b
         db        00011000b
         db        00011111b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00000000b                ; 214 "÷"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00111111b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00110110b                ; 215 "◊"
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        11111111b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00011000b                ; 216 "ÿ"
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        11111111b
         db        00011000b
         db        11111111b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00011000b                ; 217 "Ÿ"
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        11111000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 218 "⁄"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00011111b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b

         db        11111111b                ; 219 "€"
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b

         db        00000000b                ; 220 "‹"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b

         db        11110000b                ; 221 "›"
         db        11110000b
         db        11110000b
         db        11110000b
         db        11110000b
         db        11110000b
         db        11110000b
         db        11110000b
         db        11110000b
         db        11110000b
         db        11110000b
         db        11110000b
         db        11110000b
         db        11110000b
         db        11110000b
         db        11110000b

         db        00001111b                ; 222 "ﬁ"
         db        00001111b
         db        00001111b
         db        00001111b
         db        00001111b
         db        00001111b
         db        00001111b
         db        00001111b
         db        00001111b
         db        00001111b
         db        00001111b
         db        00001111b
         db        00001111b
         db        00001111b
         db        00001111b
         db        00001111b

         db        11111111b                ; 223 "ﬂ"
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 224 "‡"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        01110110b
         db        11011100b
         db        11011000b
         db        11011000b
         db        11011000b
         db        11011100b
         db        01110110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 225 "·"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111100b
         db        11000110b
         db        11111100b
         db        11000110b
         db        11000110b
         db        11111100b
         db        11000000b
         db        11000000b
         db        11000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 226 "‚"
         db        00000000b
         db        11111110b
         db        11000110b
         db        11000110b
         db        11000000b
         db        11000000b
         db        11000000b
         db        11000000b
         db        11000000b
         db        11000000b
         db        11000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 227 "„"
         db        00000000b
         db        00000000b
         db        00000000b
         db        10000000b
         db        11111110b
         db        01101100b
         db        01101100b
         db        01101100b
         db        01101100b
         db        01101100b
         db        01101100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 228 "‰"
         db        00000000b
         db        00000000b
         db        11111110b
         db        11000110b
         db        01100000b
         db        00110000b
         db        00011000b
         db        00110000b
         db        01100000b
         db        11000110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 229 "Â"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        01111110b
         db        11011000b
         db        11011000b
         db        11011000b
         db        11011000b
         db        11011000b
         db        01110000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 230 "Ê"
         db        00000000b
         db        00000000b
         db        00000000b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01111100b
         db        01100000b
         db        01100000b
         db        11000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 231 "Á"
         db        00000000b
         db        00000000b
         db        00000000b
         db        01110110b
         db        11011100b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 232 "Ë"
         db        00000000b
         db        00000000b
         db        01111110b
         db        00011000b
         db        00111100b
         db        01100110b
         db        01100110b
         db        01100110b
         db        00111100b
         db        00011000b
         db        01111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 233 "È"
         db        00000000b
         db        00000000b
         db        00111000b
         db        01101100b
         db        11000110b
         db        11000110b
         db        11111110b
         db        11000110b
         db        11000110b
         db        01101100b
         db        00111000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 234 "Í"
         db        00000000b
         db        00111000b
         db        01101100b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01101100b
         db        01101100b
         db        01101100b
         db        01101100b
         db        11101110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 235 "Î"
         db        00000000b
         db        00011110b
         db        00110000b
         db        00011000b
         db        00001100b
         db        00111110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 236 "Ï"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        01111110b
         db        11011011b
         db        11011011b
         db        11011011b
         db        01111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 237 "Ì"
         db        00000000b
         db        00000000b
         db        00000011b
         db        00000110b
         db        01111110b
         db        11001111b
         db        11011011b
         db        11110011b
         db        01111110b
         db        01100000b
         db        11000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 238 "Ó"
         db        00000000b
         db        00011100b
         db        00110000b
         db        01100000b
         db        01100000b
         db        01111100b
         db        01100000b
         db        01100000b
         db        01100000b
         db        00110000b
         db        00011100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 239 "Ô"
         db        00000000b
         db        00000000b
         db        01111100b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 240 ""
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111110b
         db        00000000b
         db        00000000b
         db        11111110b
         db        00000000b
         db        00000000b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 241 "Ò"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00011000b
         db        00011000b
         db        11111111b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00000000b
         db        11111111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 242 "Ú"
         db        00000000b
         db        00000000b
         db        00110000b
         db        00011000b
         db        00001100b
         db        00000110b
         db        00001100b
         db        00011000b
         db        00110000b
         db        00000000b
         db        01111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 243 "Û"
         db        00000000b
         db        00000000b
         db        00001100b
         db        00011000b
         db        00110000b
         db        01100000b
         db        00110000b
         db        00011000b
         db        00001100b
         db        00000000b
         db        01111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 244 "Ù"
         db        00000000b
         db        00001110b
         db        00011011b
         db        00011011b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00011000b                ; 245 "ı"
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        11011000b
         db        11011000b
         db        11011000b
         db        01110000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 246 "ˆ"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00011000b
         db        00011000b
         db        00000000b
         db        11111111b
         db        00000000b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 247 "˜"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        01110110b
         db        11011100b
         db        00000000b
         db        01110110b
         db        11011100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 248 "¯"
         db        00111000b
         db        01101100b
         db        01101100b
         db        00111000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 249 "˘"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 250 "˙"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 251 "˚"
         db        00001111b
         db        00001100b
         db        00001100b
         db        00001100b
         db        00001100b
         db        00001100b
         db        11101100b
         db        01101100b
         db        01101100b
         db        00111100b
         db        00011100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 252 "¸"
         db        11011000b
         db        01101100b
         db        01101100b
         db        01101100b
         db        01101100b
         db        01101100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 253 "˝"
         db        01110000b
         db        10011000b
         db        00110000b
         db        01100000b
         db        11001000b
         db        11111000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 254 "˛"
         db        00000000b
         db        00000000b
         db        00000000b
         db        01111100b
         db        01111100b
         db        01111100b
         db        01111100b
         db        01111100b
         db        01111100b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 255 "ˇ"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

; *****************************************************************************
;                         Instalace programu
; *****************************************************************************
;˛
; ------ £schova pñvodn° adresy INT 10h

Instal:  mov       ax,3510h
         int       21h
         mov       word ptr ds:[Old10],bx ; £schova offsetu INT 10h
         mov       word ptr ds:[Old10+2],es ; £schova segmentu INT 10h

; ------ instalace novÇ obsluhy INT 10h

         mov       dx,offset Int10          ; vlastn° obsluha INT 10h
         mov       ax,2510h
         int       21h                      ; instalace vlastn° obsluhy INT 10h

; ------ inicializace videom¢du

         mov       ax,3
         int       10h

; ------ zobrazen° £vodn°ho textu

         mov       dx,offset UvTxt          ; £vodn° text
         mov       ah,9
         int       21h                      ; zobrazen° £vodn°ho textu

; ------ instalace programu

         mov       dx,offset Instal         ; konec rezidentn° á†sti
         int       27h                      ; instalace programu

UvTxt    db        'MAXIFONT V1.00 - Maximalni font 16 linek Kamenickych; (c) Miroslav Nemecek',13,10,'$'

Code     ENDS
         END       Start

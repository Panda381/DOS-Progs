
; *****************************************************************************
;
;                              EGAAZBUK
;              Instalace azbuky znak– na displej EGA/VGA
;
; *****************************************************************************

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

Start:   jmp       Instal                   ; instalace programu

                                            ; identifika‡n¡ text
Ident    db        'EGAAZBUK V1.00'
Ident0   label     byte

SegRez   dw        0                        ; segment rezidentn¡ ‡ sti
Old10    dd        0                        ; p–vodn¡ adresa obsluhy INT 10h

FontTab  db        1                        ; ‡¡slo tabulky font–
                                            ;   0=bez font–
                                            ;   1=Azbuka

RegMap   db        0                        ; nastaven¡ registru pro mapov n¡

; -----------------------------------------------------------------------------
;        vol n¡ p–vodn¡ obsluhy INT 10h
; -----------------------------------------------------------------------------

Int10I   PROC      NEAR

         pushf                              ; simulace isntrukce INT xx
         call      dword ptr cs:[Old10]     ; nastaven¡ nov‚ho videom¢du
         ret

Int10I   ENDP

; -----------------------------------------------------------------------------
;        Obsluha p©eru¨en¡ INT 10h
; -----------------------------------------------------------------------------

Int10    PROC      FAR

; ------ test, zda je dotaz na instalaci

         cmp       ah,12h                   ; funkce dotazu na instalaci ?
         jne       Int101                   ; nen¡ dotaz na instalaci
         cmp       bx,3e10h                 ; je dotaz na instalaci ?
         jne       Int102                   ; nen¡ identifikace dotazu

; ------ ovˆ©en¡, zda p©i¨el po‘adavek opravdu od EGACSmin

         push      si
         push      di
         push      cx
         push      ds
         cld
         push      cs
         pop       ds                       ; segment tohoto modulu
         mov       si,offset Ident          ; za‡ tek identifika‡n¡ho textu
         mov       di,si                    ; adresa identifika‡n¡ho textu
         mov       cx,offset(Ident0-Ident)  ; d‚lka identifika‡n¡ho textu
         repe      cmpsb                    ; je to tento program ?
         jne       Int100                   ; nen¡ to tento program
         mov       es:[SegRez],cs           ; segment rezidentn¡ho modulu
Int100:  pop       ds
         pop       cx
         pop       di
         pop       si

; ------ rozli¨en¡, zda se maj¡ p©einstalovat fonty

Int101:  or        ah,ah                    ; je nastaven¡ m¢du displeje ?
         jz        int103                   ; je nastaven¡ videom¢du
         cmp       ah,11h                   ; je slu‘ba obsluhy font– ?
         jne       int102                   ; nen¡ operace s fonty

; ------ kontrola, zda je nastaven¡ font– slu‘by 11h

         test      al,0fh                   ; jsou u‘iv. fonty nebo informace ?
         jz        Int102                   ; u‘ivatelsk‚ fonty nebo informace
         cmp       al,3                     ; je nastaven¡ bloku font– ?
         jne       Int103                   ; nen¡ nastaven¡ bloku
;         mov       bl,0
Int102:  jmp       dword ptr cs:[Old10]     ; skok na p–vodn¡ obsluhu INT 10h

; ------ fonty se p©einstaluj¡

Int103:  call      Int10I                   ; vol n¡ p–vodn¡ po‘adovan‚ funkce

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es

; ------ stanoven¡ adresy defini‡n¡ tabulky font–

         cmp       byte ptr cs:[FontTab],0  ; je nˆjak˜ font ?
         je        Int109                   ; funkce je vypnuta

; ------ kontrola, zda je textov˜ videom¢d

         xor       ax,ax                    ; AX <- 0
         mov       ds,ax                    ; DS <- 0 datov˜ segment BIOS
         mov       al,ds:[449h]             ; aktu ln¡ videom¢d
         and       al,7fh                   ; zru¨en¡ p©¡znaku nemaz n¡ displeje
         mov       ah,0eh                   ; registr mapov n¡ pro CGA
         cmp       al,3                     ; je textov˜ videom¢d CGA ?
         jbe       Int104                   ; je textov˜ m¢d CGA - OK
         cmp       al,85                    ; videom¢d "Paradise VGA" ?
         je        Int104                   ; textov˜ videom¢d OK
         cmp       al,7                     ; je videom¢d MDA ?
         jne       Int109                   ; nen¡ textov˜ videom¢d
         mov       ah,0ah                   ; registr mapov n¡ pro MDA
Int104:  mov       cs:[RegMap],ah           ; £schova registru pro mapov n¡

; ------ nastaven¡ video©adi‡e do re‘imu definice znak–

         call      InitRegF                 ; inicializace registr– pro fonty

; ------ stanoven¡ adresy fontu podle po‡tu linek na znak

         mov       ax,ds:[485h]             ; po‡et linek na znak
         mov       si,offset Font8          ; font 8x8
         mov       cx,8
         cmp       al,8                     ; je font 8x8 ?
         jbe       Int105                   ; je font 8x8
         mov       si,offset Font14         ; font 8x14
         mov       cl,14
         cmp       al,14
         jbe       Int105                   ; je font 8x14
         mov       cl,al
;         mov       si,offset Font16         ; jinak font 8x16

; ------ p©edefinov n¡ font–

Int105:  call      Defin                    ; definov n¡ n rodn¡ch font–

; ------ zpˆtn‚ nastaven¡ videom¢du

         call      InitRegT                 ; inicializace registr– pro text

; ------ n vrat registr–

Int109:  pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         iret

Int10    ENDP

; -----------------------------------------------------------------------------
;        p©edefinov n¡ n rodn¡ch font–
; -----------------------------------------------------------------------------
; VSTUP: CS:SI=vlastn¡ fonty
;        CX=po‡et linek na znak
; -----------------------------------------------------------------------------

Defin    PROC      NEAR

         push      ds

         push      cs
         pop       ds
         mov       ax,0a000h                ; segment videopamˆti
         mov       es,ax                    ; segment videopamˆti
         mov       di,80h*32                ; ukl dac¡ adresa
         cld
         cmp       cl,14
         ja        Defin4

; ------ p©enos font– 8 a 14 linek

Defin1:  push      di
         push      cx
         rep       movsb
         pop       cx
         pop       di

         add       di,32
         cmp       di,176*32
         jne       Defin2
         mov       di,224*32

Defin2:
         cmp       di,248*32
         jne       Defin3
         mov       di,252*32
Defin3:
         cmp       di,254*32
         jb        Defin1
         jmp       short Defin8

; ------ p©enos font– 16 linek

Defin4:  push      di
         stosb
         mov       cl,14
         rep       movsb
         stosb
         pop       di

         add       di,32

         cmp       di,176*32
         jne       Defin5
         mov       di,224*32
Defin5:
         cmp       di,248*32
         jne       Defin6
         mov       di,252*32
Defin6:
         cmp       di,254*32
         jb        Defin4

Defin8:  pop       ds
         ret

Defin    ENDP

; -----------------------------------------------------------------------------
;     Inicializace registr– videokarty na re‘im definice font–
; -----------------------------------------------------------------------------

InitRegF PROC      NEAR

         mov       cl,4                     ; nastaven¡ mapov n¡ pro fonty
         mov       bx,407h                  ; BH=roviny, BL=prokl d n¡
         jmp       short InitReg            ; inicializace registr–

InitRegF ENDP

; -----------------------------------------------------------------------------
;        Inicializace registr– videokarty na textov˜ videom¢d
; -----------------------------------------------------------------------------

InitRegT PROC      NEAR

         mov       cl,cs:[RegMap]           ; registr pro mapov n¡
         mov       bx,303h                  ; BH=roviny, BL=prokl d n¡

InitRegT ENDP

; -----------------------------------------------------------------------------
;        Inicializace registr– videokarty
; -----------------------------------------------------------------------------
; VSTUP: BH=nastaven¡ rovin
;        BL=nastaven¡ prokl d n¡
;        CL=nastaven¡ mapov n¡
; -----------------------------------------------------------------------------
; zni‡en‚ registry: AX, DX
; -----------------------------------------------------------------------------

InitReg  PROC      NEAR

; ------ volba rovin pro z pis (maska)

         mov       dx,3c4h                  ; b zov  adresa 03c4h
         mov       al,2
         out       dx,al
         inc       dx
         mov       al,bh                    ; roviny
         out       dx,al
         dec       dx                       ; nastaven¡ rovin pro z pis

; ------ nastav. prokl d n¡ bajt– sud /lich 

         mov       al,4
         out       dx,al
         inc       dx
         mov       al,bl                    ; prokl d n¡
         out       dx,al                    ; nastaven¡ prokl d n¡ bajt–

; ------ nastaven¡ mapov n¡ videopamˆti

         mov       dl,0ceh                  ; port 03ceh/03cfh
         mov       al,6
         out       dx,al
         inc       dx
         mov       al,cl                    ; nastaven¡ mapov n¡
         out       dx,al                    ; registr 6: mapov n¡ videopamˆti
         ret

InitReg  ENDP

; *****************************************************************************
;                              Tabulky font–
; *****************************************************************************

;þ
Font8    label     byte                     ; font 8 linek
         db        00010000b                ; 128 "€"
         db        00111000b
         db        01101100b
         db        11000110b
         db        11111110b
         db        11000110b
         db        11000110b
         db        00000000b

         db        11111110b                ; 129 ""
         db        01000010b
         db        01000000b
         db        01111100b
         db        01000110b
         db        01000110b
         db        11111100b
         db        00000000b

         db        11111100b                ; 130 "‚"
         db        01100110b
         db        01100110b
         db        01111100b
         db        01100110b
         db        01100110b
         db        11111100b
         db        00000000b

         db        11111110b                ; 131 "ƒ"
         db        01100010b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        11110000b
         db        00000000b

         db        00111100b                ; 132 "„"
         db        01101100b
         db        01101100b
         db        01101100b
         db        01101100b
         db        01101100b
         db        11111110b
         db        11000110b

         db        11111110b                ; 133 "…"
         db        01100010b
         db        01101000b
         db        01111000b
         db        01101000b
         db        01100010b
         db        11111110b
         db        00000000b

         db        11010110b                ; 134 "†"
         db        11010110b
         db        01111100b
         db        00111000b
         db        11111110b
         db        11010110b
         db        11010110b
         db        00000000b

         db        01111100b                ; 135 "‡"
         db        11000110b
         db        00000110b
         db        00011100b
         db        00000110b
         db        11000110b
         db        01111100b
         db        00000000b

         db        11000110b                ; 136 "ˆ"
         db        11000110b
         db        11001110b
         db        11011110b
         db        11110110b
         db        11100110b
         db        11000110b
         db        00000000b

         db        11010110b                ; 137 "‰"
         db        11000110b
         db        11001110b
         db        11011110b
         db        11110110b
         db        11100110b
         db        11000110b
         db        00000000b

         db        11100110b                ; 138 "Š"
         db        01100110b
         db        01101100b
         db        01111000b
         db        01101100b
         db        01100110b
         db        11100110b
         db        00000000b

         db        00011110b                ; 139 "‹"
         db        00110110b
         db        01100110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        00000000b

         db        11000110b                ; 140 "Œ"
         db        11101110b
         db        11111110b
         db        11111110b
         db        11010110b
         db        11000110b
         db        11000110b
         db        00000000b

         db        11000110b                ; 141 ""
         db        11000110b
         db        11000110b
         db        11111110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        00000000b

         db        01111100b                ; 142 "Ž"
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01111100b
         db        00000000b

         db        11111110b                ; 143 ""
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        00000000b

         db        11111100b                ; 144 ""
         db        01100110b
         db        01100110b
         db        01111100b
         db        01100000b
         db        01100000b
         db        11110000b
         db        00000000b

         db        01111100b                ; 145 "‘"
         db        11000110b
         db        11000000b
         db        11000000b
         db        11000110b
         db        11000110b
         db        01111100b
         db        00000000b

         db        01111110b                ; 146 "’"
         db        01011010b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00111100b
         db        00000000b

         db        11000110b                ; 147 "“"
         db        11000110b
         db        11000110b
         db        01111110b
         db        00000110b
         db        11000110b
         db        01111100b
         db        00000000b

         db        01111100b                ; 148 "”"
         db        11010110b
         db        11010110b
         db        11010110b
         db        01111100b
         db        00010000b
         db        00111000b
         db        00000000b

         db        11000110b                ; 149 "•"
         db        11000110b
         db        01101100b
         db        00111000b
         db        01101100b
         db        11000110b
         db        11000110b
         db        00000000b

         db        11001100b                ; 150 "–"
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11111100b
         db        00000110b

         db        11000110b                ; 151 "—"
         db        11000110b
         db        11000110b
         db        01111110b
         db        00000110b
         db        00000110b
         db        00000110b
         db        00000000b

         db        11010110b                ; 152 "˜"
         db        11010110b
         db        11010110b
         db        11010110b
         db        11010110b
         db        11010110b
         db        11111110b
         db        00000000b

         db        11010110b                ; 153 "™"
         db        11010110b
         db        11010110b
         db        11010110b
         db        11010110b
         db        11010110b
         db        11111110b
         db        00000011b

         db        11110000b                ; 154 "š"
         db        10110000b
         db        00111100b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00111100b
         db        00000000b

         db        11000011b                ; 155 "›"
         db        11000011b
         db        11111011b
         db        11001111b
         db        11001111b
         db        11001111b
         db        11111011b
         db        00000000b

         db        11110000b                ; 156 "œ"
         db        01100000b
         db        01100000b
         db        01111100b
         db        01100110b
         db        01100110b
         db        11111100b
         db        00000000b

         db        01111100b                ; 157 ""
         db        11000110b
         db        00010110b
         db        00011110b
         db        00010110b
         db        11000110b
         db        01111100b
         db        00000000b

         db        11001110b                ; 158 "ž"
         db        11011011b
         db        11011011b
         db        11111011b
         db        11011011b
         db        11011011b
         db        11001110b
         db        00000000b

         db        00111111b                ; 159 "Ÿ"
         db        01100110b
         db        01100110b
         db        00111110b
         db        01100110b
         db        01100110b
         db        11100111b
         db        00000000b

         db        00000000b                ; 160 " "
         db        00000000b
         db        01111000b
         db        00001100b
         db        01111100b
         db        11001100b
         db        01110110b
         db        00000000b

         db        00011100b                ; 161 "¡"
         db        00110000b
         db        01111100b
         db        01100110b
         db        01100110b
         db        01100110b
         db        00111100b
         db        00000000b

         db        00000000b                ; 162 "¢"
         db        00000000b
         db        11111100b
         db        01100110b
         db        01111100b
         db        01100110b
         db        11111100b
         db        00000000b

         db        00000000b                ; 163 "£"
         db        00000000b
         db        11111110b
         db        01100010b
         db        01100000b
         db        01100000b
         db        11110000b
         db        00000000b

         db        00000000b                ; 164 "¤"
         db        00000000b
         db        00111100b
         db        01101100b
         db        01101100b
         db        01101100b
         db        11111110b
         db        11000110b

         db        00000000b                ; 165 "¥"
         db        00000000b
         db        01111100b
         db        11000110b
         db        11111100b
         db        11000000b
         db        01111100b
         db        00000000b

         db        00000000b                ; 166 "¦"
         db        00000000b
         db        11010110b
         db        11010110b
         db        01111100b
         db        11010110b
         db        11010110b
         db        00000000b

         db        00000000b                ; 167 "§"
         db        00000000b
         db        01111100b
         db        11000110b
         db        00011100b
         db        11000110b
         db        01111100b
         db        00000000b

         db        00000000b                ; 168 "¨"
         db        00000000b
         db        11000110b
         db        11001110b
         db        11011110b
         db        11110110b
         db        11100110b
         db        00000000b

         db        00111000b                ; 169 "©"
         db        00010000b
         db        11000110b
         db        11001110b
         db        11011110b
         db        11110110b
         db        11100110b
         db        00000000b

         db        00000000b                ; 170 "ª"
         db        00000000b
         db        11100110b
         db        01101100b
         db        01111000b
         db        01101100b
         db        11100110b
         db        00000000b

         db        00000000b                ; 171 "«"
         db        00000000b
         db        00011110b
         db        00110110b
         db        01100110b
         db        11000110b
         db        11000110b
         db        00000000b

         db        00000000b                ; 172 "¬"
         db        00000000b
         db        11000110b
         db        11101110b
         db        11111110b
         db        11010110b
         db        11000110b
         db        00000000b

         db        00000000b                ; 173 "­"
         db        00000000b
         db        11000110b
         db        11000110b
         db        11111110b
         db        11000110b
         db        11000110b
         db        00000000b

         db        00000000b                ; 174 "®"
         db        00000000b
         db        01111100b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01111100b
         db        00000000b

         db        00000000b                ; 175 "¯"
         db        00000000b
         db        11111110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        00000000b

; ------

         db        00000000b                ; 224 "à"
         db        00000000b
         db        11111100b
         db        01100110b
         db        01100110b
         db        01111100b
         db        01100000b
         db        11110000b

         db        00000000b                ; 225 "á"
         db        00000000b
         db        01111100b
         db        11000110b
         db        11000000b
         db        11000110b
         db        01111100b
         db        00000000b

         db        00000000b                ; 226 "â"
         db        00000000b
         db        01111110b
         db        01011010b
         db        00011000b
         db        00011000b
         db        00111100b
         db        00000000b

         db        00000000b                ; 227 "ã"
         db        00000000b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01111110b
         db        00000110b
         db        01111100b

         db        00000000b                ; 228 "ä"
         db        00000000b
         db        01111100b
         db        11010110b
         db        11010110b
         db        01111100b
         db        00010000b
         db        00111000b

         db        00000000b                ; 229 "å"
         db        00000000b
         db        11000110b
         db        01101100b
         db        00111000b
         db        01101100b
         db        11000110b
         db        00000000b

         db        00000000b                ; 230 "æ"
         db        00000000b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11111110b
         db        00000011b

         db        00000000b                ; 231 "ç"
         db        00000000b
         db        11000110b
         db        11000110b
         db        01111110b
         db        00000110b
         db        00000110b
         db        00000000b

         db        00000000b                ; 232 "è"
         db        00000000b
         db        11010110b
         db        11010110b
         db        11010110b
         db        11010110b
         db        11111110b
         db        00000000b

         db        00000000b                ; 233 "é"
         db        00000000b
         db        11010110b
         db        11010110b
         db        11010110b
         db        11010110b
         db        11111110b
         db        00000011b

         db        00000000b                ; 234 "ê"
         db        00000000b
         db        11110000b
         db        10111100b
         db        00110110b
         db        00110110b
         db        01111100b
         db        00000000b

         db        00000000b                ; 235 "ë"
         db        00000000b
         db        11000011b
         db        11000011b
         db        11111011b
         db        11001111b
         db        11111011b
         db        00000000b

         db        00000000b                ; 236 "ì"
         db        00000000b
         db        11110000b
         db        01100000b
         db        01111100b
         db        01100110b
         db        11111100b
         db        00000000b

         db        00000000b                ; 237 "í"
         db        00000000b
         db        01111100b
         db        11000110b
         db        00011110b
         db        11000110b
         db        01111100b
         db        00000000b

         db        00000000b                ; 238 "î"
         db        00000000b
         db        11001110b
         db        11011011b
         db        11111011b
         db        11011011b
         db        11001110b
         db        00000000b

         db        00000000b                ; 239 "ï"
         db        00000000b
         db        00111111b
         db        01100110b
         db        00111110b
         db        01110110b
         db        11100111b
         db        00000000b

;         db        01010000b                ; 240 "ð"
;         db        11111100b
;         db        11000000b
;         db        11110000b
;         db        11000000b
;         db        11000000b
;         db        11111110b
;         db        00000000b

         db        00000000b                ; 240 "ð"
         db        11111110b
         db        00000000b
         db        11111110b
         db        00000000b
         db        11111110b
         db        00000000b
         db        00000000b

         db        00101000b                ; 241 "ñ"
         db        00000000b
         db        01111000b
         db        11001100b
         db        11111100b
         db        11000000b
         db        01111100b
         db        00000000b

         db        01111100b                ; 242 "ò"
         db        11000110b
         db        11010000b
         db        11110000b
         db        11010000b
         db        11000110b
         db        01111100b
         db        00000000b

         db        00000000b                ; 243 "ó"
         db        00000000b
         db        01111100b
         db        11000110b
         db        11110000b
         db        11000110b
         db        01111100b
         db        00000000b

         db        00111100b                ; 244 "ô"
         db        00000000b
         db        00111100b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00111100b
         db        00000000b

         db        00000000b                ; 245 "õ"
         db        00111100b
         db        00000000b
         db        00111100b
         db        00011000b
         db        00011000b
         db        00111100b
         db        00000000b

         db        00111000b                ; 246 "ö"
         db        10010010b
         db        11000110b
         db        11111110b
         db        00000110b
         db        11000110b
         db        01111100b
         db        00000000b

         db        00111000b                ; 247 "÷"
         db        00010000b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01111110b
         db        00000110b
         db        01111100b

; ------

;         db        00000000b                ; 252 "ü"
;         db        11001111b
;         db        11001100b
;         db        11101100b
;         db        11011100b
;         db        11001100b
;         db        11001100b
;         db        00000000b

         db        01010000b                ; 252 "ü"
         db        11111100b
         db        11000000b
         db        11110000b
         db        11000000b
         db        11000000b
         db        11111110b
         db        00000000b


         db        00000000b                ; 253 "ý"
         db        01100110b
         db        00111100b
         db        01100110b
         db        01100110b
         db        00111100b
         db        01100110b
         db        00000000b

;þ
Font14   label     byte                     ; font 14 linek
         db        00000000b                ; 128 "€"
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

         db        00000000b                ; 129 ""
         db        11111110b
         db        01100010b
         db        01100010b
         db        01100000b
         db        01111100b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        11111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 130 "‚"
         db        11111100b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01111100b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        11111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 131 "ƒ"
         db        11111110b
         db        01100010b
         db        01100010b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        11110000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 132 "„"
         db        00011110b
         db        00110110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        11111111b
         db        11000011b
         db        10000001b
         db        00000000b

         db        00000000b                ; 133 "…"
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

         db        00000000b                ; 134 "†"
         db        11010110b
         db        11010110b
         db        11010110b
         db        01111100b
         db        00111000b
         db        01111100b
         db        11010110b
         db        11010110b
         db        11010110b
         db        11010110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 135 "‡"
         db        01111100b
         db        11000110b
         db        00000110b
         db        00000110b
         db        00111100b
         db        00000110b
         db        00000110b
         db        00000110b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 136 "ˆ"
         db        11000110b
         db        11000110b
         db        11001110b
         db        11001110b
         db        11010110b
         db        11100110b
         db        11100110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00111000b                ; 137 "‰"
         db        11000110b
         db        11000110b
         db        11001110b
         db        11001110b
         db        11010110b
         db        11100110b
         db        11100110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 138 "Š"
         db        11100110b
         db        01100110b
         db        01100110b
         db        01101100b
         db        01111000b
         db        01111000b
         db        01101100b
         db        01100110b
         db        01100110b
         db        11100110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 139 "‹"
         db        00011110b
         db        00111110b
         db        01100110b
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

         db        00000000b                ; 140 "Œ"
         db        11000110b
         db        11101110b
         db        11111110b
         db        11111110b
         db        11010110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 141 ""
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11111110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 142 "Ž"
         db        01111100b
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

         db        00000000b                ; 143 ""
         db        11111110b
         db        11000110b
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

         db        00000000b                ; 144 ""
         db        11111100b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01111100b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        11110000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 145 "‘"
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

         db        00000000b                ; 146 "’"
         db        01111110b
         db        01111110b
         db        01011010b
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

         db        00000000b                ; 147 "“"
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01111110b
         db        00000110b
         db        00000110b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 148 "”"
         db        00111100b
         db        00011000b
         db        01111110b
         db        11011011b
         db        11011011b
         db        11011011b
         db        11011011b
         db        01111110b
         db        00011000b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 149 "•"
         db        11000110b
         db        11000110b
         db        01101100b
         db        01111100b
         db        00111000b
         db        00111000b
         db        01111100b
         db        01101100b
         db        11000110b
         db        11000110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 150 "–"
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11111110b
         db        00000110b
         db        00000110b
         db        00000000b

         db        00000000b                ; 151 "—"
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01111110b
         db        00000110b
         db        00000110b
         db        00000110b
         db        00000110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 152 "˜"
         db        11011011b
         db        11011011b
         db        11011011b
         db        11011011b
         db        11011011b
         db        11011011b
         db        11011011b
         db        11011011b
         db        11011011b
         db        11111111b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 153 "™"
         db        11011011b
         db        11011011b
         db        11011011b
         db        11011011b
         db        11011011b
         db        11011011b
         db        11011011b
         db        11011011b
         db        11011011b
         db        11111111b
         db        00000011b
         db        00000011b
         db        00000000b

         db        00000000b                ; 154 "š"
         db        11111000b
         db        10110000b
         db        10110000b
         db        00110000b
         db        00111110b
         db        00110011b
         db        00110011b
         db        00110011b
         db        00110011b
         db        01111110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 155 "›"
         db        11000011b
         db        11000011b
         db        11000011b
         db        11000011b
         db        11111011b
         db        11001111b
         db        11001111b
         db        11001111b
         db        11001111b
         db        11111011b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 156 "œ"
         db        11110000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01111100b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        11111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 157 ""
         db        01111100b
         db        11000110b
         db        00000110b
         db        00100110b
         db        00111110b
         db        00100110b
         db        00000110b
         db        00000110b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 158 "ž"
         db        11001110b
         db        11011011b
         db        11011011b
         db        11011011b
         db        11111011b
         db        11011011b
         db        11011011b
         db        11011011b
         db        11011011b
         db        11001110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 159 "Ÿ"
         db        00111111b
         db        01100110b
         db        01100110b
         db        01100110b
         db        00111110b
         db        00111110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        11100111b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 160 " "
         db        00000000b
         db        00000000b
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

         db        00000010b                ; 161 "¡"
         db        00000110b
         db        00111100b
         db        01100000b
         db        01100000b
         db        01111100b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 162 "¢"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111100b
         db        01100110b
         db        01100110b
         db        01111100b
         db        01100110b
         db        01100110b
         db        11111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 163 "£"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111110b
         db        01100010b
         db        01100010b
         db        01100000b
         db        01100000b
         db        01100000b
         db        11110000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 164 "¤"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00011110b
         db        00110110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        11111111b
         db        11000011b
         db        11000011b
         db        00000000b

         db        00000000b                ; 165 "¥"
         db        00000000b
         db        00000000b
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

         db        00000000b                ; 166 "¦"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11010110b
         db        11010110b
         db        01111110b
         db        01111100b
         db        01010100b
         db        11010110b
         db        11010110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 167 "§"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00111100b
         db        01100110b
         db        00000110b
         db        00001100b
         db        00000110b
         db        01100110b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 168 "¨"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11000110b
         db        11001110b
         db        11011110b
         db        11111110b
         db        11110110b
         db        11100110b
         db        11000110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 169 "©"
         db        00000000b
         db        00111000b
         db        00111000b
         db        11000110b
         db        11001110b
         db        11011110b
         db        11111110b
         db        11110110b
         db        11100110b
         db        11000110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 170 "ª"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11100110b
         db        01101100b
         db        01111000b
         db        01111000b
         db        01101100b
         db        01100110b
         db        11100110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 171 "«"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00001110b
         db        00011110b
         db        00110110b
         db        01100110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 172 "¬"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11000110b
         db        11101110b
         db        11111110b
         db        11111110b
         db        11010110b
         db        11000110b
         db        11000110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 173 "­"
         db        00000000b
         db        00000000b
         db        00000000b
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

         db        00000000b                ; 174 "®"
         db        00000000b
         db        00000000b
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

         db        00000000b                ; 175 "¯"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        00000000b
         db        00000000b
         db        00000000b

; ------

         db        00000000b                ; 224 "à"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11011100b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01111100b
         db        01100000b
         db        01100000b
         db        11110000b

         db        00000000b                ; 225 "á"
         db        00000000b
         db        00000000b
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

         db        00000000b                ; 226 "â"
         db        00000000b
         db        00000000b
         db        00000000b
         db        01111110b
         db        01011010b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 227 "ã"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01111110b
         db        00000110b
         db        00000110b
         db        11000110b
         db        01111100b

         db        00000000b                ; 228 "ä"
         db        00000000b
         db        00000000b
         db        00111100b
         db        00011000b
         db        01111110b
         db        11011011b
         db        11011011b
         db        11011011b
         db        11011011b
         db        01111110b
         db        00011000b
         db        00011000b
         db        00111100b

         db        00000000b                ; 229 "å"
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

         db        00000000b                ; 230 "æ"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11111110b
         db        00000110b
         db        00000110b
         db        00000000b

         db        00000000b                ; 231 "ç"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01111110b
         db        00000110b
         db        00000110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 232 "è"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11010110b
         db        11010110b
         db        11010110b
         db        11010110b
         db        11010110b
         db        11010110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 233 "é"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11010110b
         db        11010110b
         db        11010110b
         db        11010110b
         db        11010110b
         db        11010110b
         db        11111110b
         db        00000011b
         db        00000011b
         db        00000000b

         db        00000000b                ; 234 "ê"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111000b
         db        10110000b
         db        10110000b
         db        00111100b
         db        00110110b
         db        00110110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 235 "ë"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11110110b
         db        11011110b
         db        11011110b
         db        11110110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 236 "ì"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11110000b
         db        01100000b
         db        01100000b
         db        01111100b
         db        01100110b
         db        01100110b
         db        11111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 237 "í"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00111100b
         db        01100110b
         db        00000110b
         db        00011110b
         db        00000110b
         db        01100110b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 238 "î"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11001110b
         db        11011011b
         db        11011011b
         db        11111011b
         db        11011011b
         db        11011011b
         db        11001110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 239 "ï"
         db        00000000b
         db        00000000b
         db        00000000b
         db        01111110b
         db        11001100b
         db        11001100b
         db        11111100b
         db        01101100b
         db        11001100b
         db        11001110b
         db        00000000b
         db        00000000b
         db        00000000b

;         db        00100100b                ; 240 "ð"
;         db        00000000b
;         db        11111110b
;         db        01100110b
;         db        01100010b
;         db        01101000b
;         db        01111000b
;         db        01101000b
;         db        01100010b
;         db        01100110b
;         db        11111110b
;         db        00000000b
;         db        00000000b
;         db        00000000b

         db        00000000b                ; 240 "ð"
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

         db        00000000b                ; 241 "ñ"
         db        00000000b
         db        00101000b
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

         db        00000000b                ; 242 "ò"
         db        01111100b
         db        11000110b
         db        11000000b
         db        11001000b
         db        11111000b
         db        11001000b
         db        11000000b
         db        11000000b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 243 "ó"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00111100b
         db        01100110b
         db        01100000b
         db        01111000b
         db        01100000b
         db        01100110b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        01100110b                ; 244 "ô"
         db        00000000b
         db        00111100b
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

         db        00000000b                ; 245 "õ"
         db        00000000b
         db        01100110b
         db        00000000b
         db        00111100b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00111000b                ; 246 "ö"
         db        00010000b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01111110b
         db        00000110b
         db        00000110b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 247 "÷"
         db        00000000b
         db        00111000b
         db        00010000b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01111110b
         db        00000110b
         db        00000110b
         db        11000110b
         db        01111100b

; ------

;         db        00000000b                ; 252 "ü"
;         db        11001111b
;         db        11001100b
;         db        11001101b
;         db        11101101b
;         db        11101100b
;         db        11011100b
;         db        11011100b
;         db        11001100b
;         db        11001100b
;         db        11001100b
;         db        00000000b
;         db        00000000b
;         db        00000000b

         db        00100100b                ; 240 "ð"
         db        00000000b
         db        11111110b
         db        01100110b
         db        01100010b
         db        01101000b
         db        01111000b
         db        01101000b
         db        01100010b
         db        01100110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 253 "ý"
         db        00000000b
         db        00000000b
         db        01100110b
         db        00111100b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        00111100b
         db        01100110b
         db        00000000b
         db        00000000b

COMMENT  %
;þ
Font16   label     byte                     ; font 16 linek
         db        00000000b                ; 128 "€"
         db        00000000b
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

         db        00000000b                ; 129 ""
         db        00000000b
         db        11111110b
         db        01100010b
         db        01100010b
         db        01100000b
         db        01111100b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        11111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 130 "‚"
         db        00000000b
         db        11111100b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01111100b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        11111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 131 "ƒ"
         db        00000000b
         db        11111110b
         db        01100010b
         db        01100010b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        11110000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 132 "„"
         db        00000000b
         db        00011110b
         db        00110110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        11111111b
         db        11000011b
         db        10000001b
         db        00000000b
         db        00000000b

         db        00000000b                ; 133 "…"
         db        00000000b
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

         db        00000000b                ; 134 "†"
         db        00000000b
         db        11010110b
         db        11010110b
         db        11010110b
         db        01111100b
         db        00111000b
         db        01111100b
         db        11010110b
         db        11010110b
         db        11010110b
         db        11010110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 135 "‡"
         db        00000000b
         db        01111100b
         db        11000110b
         db        00000110b
         db        00000110b
         db        00111100b
         db        00000110b
         db        00000110b
         db        00000110b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 136 "ˆ"
         db        00000000b
         db        11000110b
         db        11000110b
         db        11001110b
         db        11001110b
         db        11010110b
         db        11100110b
         db        11100110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 137 "‰"
         db        00111000b
         db        11000110b
         db        11000110b
         db        11001110b
         db        11001110b
         db        11010110b
         db        11100110b
         db        11100110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 138 "Š"
         db        00000000b
         db        11100110b
         db        01100110b
         db        01100110b
         db        01101100b
         db        01111000b
         db        01111000b
         db        01101100b
         db        01100110b
         db        01100110b
         db        11100110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 139 "‹"
         db        00000000b
         db        00011110b
         db        00111110b
         db        01100110b
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

         db        00000000b                ; 140 "Œ"
         db        00000000b
         db        11000110b
         db        11101110b
         db        11111110b
         db        11111110b
         db        11010110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 141 ""
         db        00000000b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11111110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 142 "Ž"
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
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 143 ""
         db        00000000b
         db        11111110b
         db        11000110b
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

         db        00000000b                ; 144 ""
         db        00000000b
         db        11111100b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01111100b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        11110000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 145 "‘"
         db        00000000b
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

         db        00000000b                ; 146 "’"
         db        00000000b
         db        01111110b
         db        01111110b
         db        01011010b
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

         db        00000000b                ; 147 "“"
         db        00000000b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01111110b
         db        00000110b
         db        00000110b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 148 "”"
         db        00000000b
         db        00111100b
         db        00011000b
         db        01111110b
         db        11011011b
         db        11011011b
         db        11011011b
         db        11011011b
         db        01111110b
         db        00011000b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 149 "•"
         db        00000000b
         db        11000110b
         db        11000110b
         db        01101100b
         db        01111100b
         db        00111000b
         db        00111000b
         db        01111100b
         db        01101100b
         db        11000110b
         db        11000110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 150 "–"
         db        00000000b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11111110b
         db        00000110b
         db        00000110b
         db        00000000b
         db        00000000b

         db        00000000b                ; 151 "—"
         db        00000000b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01111110b
         db        00000110b
         db        00000110b
         db        00000110b
         db        00000110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 152 "˜"
         db        00000000b
         db        11011011b
         db        11011011b
         db        11011011b
         db        11011011b
         db        11011011b
         db        11011011b
         db        11011011b
         db        11011011b
         db        11011011b
         db        11111111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 153 "™"
         db        00000000b
         db        11011011b
         db        11011011b
         db        11011011b
         db        11011011b
         db        11011011b
         db        11011011b
         db        11011011b
         db        11011011b
         db        11011011b
         db        11111111b
         db        00000011b
         db        00000011b
         db        00000000b
         db        00000000b

         db        00000000b                ; 154 "š"
         db        00000000b
         db        11111000b
         db        10110000b
         db        10110000b
         db        00110000b
         db        00111110b
         db        00110011b
         db        00110011b
         db        00110011b
         db        00110011b
         db        01111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 155 "›"
         db        00000000b
         db        11000011b
         db        11000011b
         db        11000011b
         db        11000011b
         db        11111011b
         db        11001111b
         db        11001111b
         db        11001111b
         db        11001111b
         db        11111011b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 156 "œ"
         db        00000000b
         db        11110000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01111100b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        11111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 157 ""
         db        00000000b
         db        01111100b
         db        11000110b
         db        00000110b
         db        00100110b
         db        00111110b
         db        00100110b
         db        00000110b
         db        00000110b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 158 "ž"
         db        00000000b
         db        11001110b
         db        11011011b
         db        11011011b
         db        11011011b
         db        11111011b
         db        11011011b
         db        11011011b
         db        11011011b
         db        11011011b
         db        11001110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 159 "Ÿ"
         db        00000000b
         db        00111111b
         db        01100110b
         db        01100110b
         db        01100110b
         db        00111110b
         db        00111110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        11100111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 160 " "
         db        00000000b
         db        00000000b
         db        00000000b
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

         db        00000000b                ; 161 "¡"
         db        00000010b
         db        00000110b
         db        00111100b
         db        01100000b
         db        01100000b
         db        01111100b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 162 "¢"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111100b
         db        01100110b
         db        01100110b
         db        01111100b
         db        01100110b
         db        01100110b
         db        11111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 163 "£"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111110b
         db        01100010b
         db        01100010b
         db        01100000b
         db        01100000b
         db        01100000b
         db        11110000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 164 "¤"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00011110b
         db        00110110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        11111111b
         db        11000011b
         db        11000011b
         db        00000000b
         db        00000000b

         db        00000000b                ; 165 "¥"
         db        00000000b
         db        00000000b
         db        00000000b
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

         db        00000000b                ; 166 "¦"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11010110b
         db        11010110b
         db        01111110b
         db        01111100b
         db        01010100b
         db        11010110b
         db        11010110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 167 "§"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00111100b
         db        01100110b
         db        00000110b
         db        00001100b
         db        00000110b
         db        01100110b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 168 "¨"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11000110b
         db        11001110b
         db        11011110b
         db        11111110b
         db        11110110b
         db        11100110b
         db        11000110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 169 "©"
         db        00000000b
         db        00000000b
         db        00111000b
         db        00111000b
         db        11000110b
         db        11001110b
         db        11011110b
         db        11111110b
         db        11110110b
         db        11100110b
         db        11000110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 170 "ª"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11100110b
         db        01101100b
         db        01111000b
         db        01111000b
         db        01101100b
         db        01100110b
         db        11100110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 171 "«"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00001110b
         db        00011110b
         db        00110110b
         db        01100110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 172 "¬"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11000110b
         db        11101110b
         db        11111110b
         db        11111110b
         db        11010110b
         db        11000110b
         db        11000110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 173 "­"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
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

         db        00000000b                ; 174 "®"
         db        00000000b
         db        00000000b
         db        00000000b
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

         db        00000000b                ; 175 "¯"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111110b
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

; ------

         db        00000000b                ; 224 "à"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11011100b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01111100b
         db        01100000b
         db        01100000b
         db        11110000b
         db        00000000b

         db        00000000b                ; 225 "á"
         db        00000000b
         db        00000000b
         db        00000000b
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

         db        00000000b                ; 226 "â"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        01111110b
         db        01011010b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 227 "ã"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01111110b
         db        00000110b
         db        00000110b
         db        11000110b
         db        01111100b
         db        00000000b

         db        00000000b                ; 228 "ä"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00111100b
         db        00011000b
         db        01111110b
         db        11011011b
         db        11011011b
         db        11011011b
         db        11011011b
         db        01111110b
         db        00011000b
         db        00011000b
         db        00111100b
         db        00000000b

         db        00000000b                ; 229 "å"
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

         db        00000000b                ; 230 "æ"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11111110b
         db        00000110b
         db        00000110b
         db        00000000b
         db        00000000b

         db        00000000b                ; 231 "ç"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01111110b
         db        00000110b
         db        00000110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 232 "è"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11010110b
         db        11010110b
         db        11010110b
         db        11010110b
         db        11010110b
         db        11010110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 233 "é"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11010110b
         db        11010110b
         db        11010110b
         db        11010110b
         db        11010110b
         db        11010110b
         db        11111110b
         db        00000011b
         db        00000011b
         db        00000000b
         db        00000000b

         db        00000000b                ; 234 "ê"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111000b
         db        10110000b
         db        10110000b
         db        00111100b
         db        00110110b
         db        00110110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 235 "ë"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11110110b
         db        11011110b
         db        11011110b
         db        11110110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 236 "ì"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11110000b
         db        01100000b
         db        01100000b
         db        01111100b
         db        01100110b
         db        01100110b
         db        11111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 237 "í"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00111100b
         db        01100110b
         db        00000110b
         db        00011110b
         db        00000110b
         db        01100110b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 238 "î"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11001110b
         db        11011011b
         db        11011011b
         db        11111011b
         db        11011011b
         db        11011011b
         db        11001110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 239 "ï"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        01111110b
         db        11001100b
         db        11001100b
         db        11111100b
         db        01101100b
         db        11001100b
         db        11001110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

;         db        00000000b                ; 240 "ð"
;         db        00100100b
;         db        00000000b
;         db        11111110b
;         db        01100110b
;         db        01100010b
;         db        01101000b
;         db        01111000b
;         db        01101000b
;         db        01100010b
;         db        01100110b
;         db        11111110b
;         db        00000000b
;         db        00000000b
;         db        00000000b
;         db        00000000b

         db        00000000b                ; 240 "ð"
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

         db        00000000b                ; 241 "ñ"
         db        00000000b
         db        00000000b
         db        00101000b
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

         db        00000000b                ; 242 "ò"
         db        00000000b
         db        01111100b
         db        11000110b
         db        11000000b
         db        11001000b
         db        11111000b
         db        11001000b
         db        11000000b
         db        11000000b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 243 "ó"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00111100b
         db        01100110b
         db        01100000b
         db        01111000b
         db        01100000b
         db        01100110b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 244 "ô"
         db        01100110b
         db        00000000b
         db        00111100b
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

         db        00000000b                ; 245 "õ"
         db        00000000b
         db        00000000b
         db        01100110b
         db        00000000b
         db        00111100b
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

         db        00000000b                ; 246 "ö"
         db        00111000b
         db        00010000b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01111110b
         db        00000110b
         db        00000110b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 247 "÷"
         db        00000000b
         db        00000000b
         db        00111000b
         db        00010000b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01111110b
         db        00000110b
         db        00000110b
         db        11000110b
         db        01111100b
         db        00000000b

; ------

;         db        00000000b                ; 252 "ü"
;         db        00000000b
;         db        11001111b
;         db        11001100b
;         db        11001101b
;         db        11101101b
;         db        11101100b
;         db        11011100b
;         db        11011100b
;         db        11001100b
;         db        11001100b
;         db        11001100b
;         db        00000000b
;         db        00000000b
;         db        00000000b
;         db        00000000b

         db        00000000b                ; 240 "ð"
         db        00100100b
         db        00000000b
         db        11111110b
         db        01100110b
         db        01100010b
         db        01101000b
         db        01111000b
         db        01101000b
         db        01100010b
         db        01100110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 253 "ý"
         db        00000000b
         db        00000000b
         db        00000000b
         db        01100110b
         db        00111100b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        00111100b
         db        01100110b
         db        00000000b
         db        00000000b
         db        00000000b
%

; *****************************************************************************
;                         Instalace programu
; *****************************************************************************
;þ
Instal:  mov       ds:[SegRez],ds           ; segment tohoto programu

; ------ test, zda je program ji‘ nainstalov n, test karty EGA/VGA

         push      cs
         pop       es
         mov       ah,12h                   ; funkce informac¡ EGA
         mov       bx,3e10h                 ; podfunkce - test instalace
         int       10h                      ; informace o kartˆ EGA
         cmp       bl,6                     ; kontrola navr cen‚ho £daje
         jb        Instal1                  ; je displej EGA/VGA

; ------ chyba - nen¡ karta EGA/VGA

         mov       dx,offset ErrTxt         ; chyba - nen¡ karta EGA/VGA
Chyba:   mov       ah,9
         int       21h
         int       20h

; ------ p©¡prava k dek¢dov n¡ p©¡kazov‚ho © dku

Instal1: push      cs
         pop       ds                       ; DS <- CS
         mov       es,ds:[SegRez]           ; segment rezidentn¡ ‡ sti
         mov       dx,offset Help           ; n povˆda
         mov       si,81h                   ; za‡ tek textu
         xor       cx,cx
         mov       cl,ds:[si-1]             ; po‡et znak– zad n¡
         cld                                ; smˆr nahoru

; ------ vypu¨tˆn¡ oddˆlova‡– (mezer a tabel tor–)

Instal3: jcxz      Instal6                  ; nen¡ ji‘ dal¨¡ znak
         lodsb                              ; na‡ten¡ dal¨¡ho znaku
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e znak–
         cmp       al," "                   ; oddˆlovac¡ znak ?
         jbe       Instal3                  ; je oddˆlovac¡ znak - p©esko‡en¡
         cmp       al,"/"
         je        Instal3                  ; oddˆlova‡ parametr– - vypu¨tˆn¡
         or        al,20h                   ; p©evod na mal‚ p¡smeno

; ------ parametr /C - k¢d Azbuka

         cmp       al,"c"                   ; k¢d Kamenick˜ch ?
         jne       Instal4                  ; nen¡ k¢d Azbuka
         mov       byte ptr es:[FontTab],1  ; k¢d Azbuka
         jmp       short Instal3            ; dal¨¡ znak

; ------ parametr /0 - vypnut¡ font–

Instal4: cmp       al,"0"                   ; vypnut¡ obsluhy ?
         jne       Instal53
         mov       byte ptr es:[FontTab],0  ; standardn¡ k¢d IBM
         jmp       short Instal3            ; dal¨¡ znak

; ------ parametr /! - odinstalov n¡ z pamˆti

Instal53:cmp       al,"!"                   ; odinstalov n¡ ?
         jne       Chyba                    ; chyba zad n¡
         mov       word ptr ds:[OdIns],1    ; p©¡znak odinstalov n¡
         jmp       short Instal3

; ------ kontrola, zda je to prvn¡ instalace

Instal6: mov       ax,cs
         cmp       ax,ds:[SegRez]           ; je program nainstalovan˜ ?
         je        Instal7                  ; je to prvn¡ instalace

; ------ nem -li b˜t odinstalov n¡ pouze zobrazen¡ informa‡n¡ho textu

         cmp       byte ptr ds:[OdIns],0    ; m  b˜t odinstalov n¡ ?
         je        Inst67                   ; nem  b˜t odinstalov n¡ - konec

; ------ kontrola, zda lze odinstalovat

         mov       ax,3510h                 ; funkce poskytnut¡ INT 10h
         int       21h                      ; poskytnut¡ adresy INT 10h
         mov       dx,offset ErrDIns        ; text - nelze odinstalovat
         cmp       bx,offset Int10          ; je offset INT 10h ?
         jne       Inst66                   ; chyba - nelze odinstalovat
         mov       ax,es                    ; segment INT 10h
         cmp       ax,ds:[SegRez]           ; je segment OK ?
         jne       Inst66                   ; nelze odinstalovat

; ------ n vrat vektoru p©eru¨en¡ INT 10h

         mov       es,ds:[SegRez]           ; sezidentn¡ segment
         push      ds
         lds       dx,es:[Old10]            ; p–vodn¡ adresa INT 10h
         mov       ax,2510h                 ; funkce nastaven¡ vektoru p©eru¨en¡
         int       21h                      ; n vrat vektoru p©eru¨en¡ INT 10h
         pop       ds

; ------ uvolnˆn¡ segmentu pamˆti

         mov       ah,49h                   ; funkce uvolnˆn¡ pamˆti
         int       21h                      ; uvolnˆn¡ bloku pamˆti

; ------ hl ¨en¡ o odinstalov n¡ programu

         mov       dx,offset DInsTxt        ; text - byl odinstalov n
Inst66:  mov       ah,9
         int       21h                      ; zobrazen¡ textu
         int       20h                      ; konec programu

; ------ zobrazen¡ informa‡n¡ho textu, konec

Inst67:  call      Inform                   ; zobrazen¡ informa‡n¡ho textu
Inst68:  int       20h                      ; konec programu

; ------ prvn¡ instalace - nelze odinstalovat

Instal7: mov       dx,offset ErrDIn2        ; text - nebyl nainstalov n
         cmp       byte ptr ds:[OdIns],0    ; po‘adov no odinstalov n¡ ?
         jne       Inst66                   ; po‘adov no odinstalov n¡

; ------ £schova p–vodn¡ adresy INT 10h

         push      es
         mov       ax,3510h                 ; funkce poskytnut¡ adresy INT 10h
         int       21h
         mov       word ptr ds:[Old10],bx   ; £schova offsetu INT 10h
         mov       word ptr ds:[Old10+2],es ; £schova segmentu INT 10h

; ------ instalace nov‚ obsluhy INT 10h

         mov       dx,offset Int10          ; vlastn¡ obsluha INT 10h
         mov       ax,2510h
         int       21h                      ; instalace vlastn¡ obsluhy INT 10h

; ------ uvolnˆn¡ pamˆŸov‚ho bloku segmentu prost©ed¡

         mov       es,ds:[2ch]              ; segment prost©ed¡
         mov       ah,49h                   ; funkce uvolnˆn¡ pamˆti
         int       21h                      ; uvolnˆn¡ bloku pamˆti
         pop       es

; ------ zobrazen¡ informa‡n¡ho textu

         call      Inform                   ; zobrazen¡ informa‡n¡ho textu

; ------ instalace programu

         mov       dx,offset Instal         ; konec rezidentn¡ ‡ sti
         int       27h                      ; instalace programu

; -----------------------------------------------------------------------------
;        zobrazen¡ informa‡n¡ho textu (ES=segment EGAAZBUK)
; -----------------------------------------------------------------------------

Inform   PROC      NEAR

; ------ £schova videom¢du

         push      es                       ; segment aktivn¡ho EGACSmin
         mov       ah,0fh
         int       10h                      ; dotaz na sou‡asn˜ videom¢d
         mov       cs:[OldVMod],al
         push      ax                       ; £schova videom¢du

; ------ £schova pozice kurzoru

         mov       ah,3
         int       10h                      ; poskytnut¡ pozice kurzoru
         pop       ax                       ; n vrat aktivn¡ho videom¢du
         push      dx                       ; £schova pozice kurzoru

; ------ p©edefinov n¡ videom¢du

         or        al,80h                   ; displej se nema‘e
         xor       ah,ah
         int       10h                      ; nov‚ nastaven¡ videom¢du

; ------ zru¨en¡ p©¡znaku nemazat displej

         push      ds
         xor       ax,ax
         mov       ds,ax
         and       byte ptr ds:[449h],not 80h ; zru¨en¡ p©¡znaku nemazat displej
         and       byte ptr ds:[487h],not 80h ; zru¨en¡ p©¡znaku nemazat displej
         pop       ds

; ------ n vrat pozice kurzoru

         pop       dx                       ; n vrat pozice kurzoru
         mov       ah,2
         int       10h                      ; n vrat pozice kurzoru

; ------ pro LCD p©edefinov n¡

         mov       ax,1130h
         mov       bl,4
         int       10h
         cmp       cx,19
         jne       Infor23
         mov       al,cs:[OldVMod]
         xor       ah,ah
         int       10h

; ------ zobrazen¡ informa‡n¡ho textu

Infor23: pop       es
         mov       dx,offset UvTxt          ; prvn¡ ‡ st textu
         mov       ah,9
         int       21h                      ; zobrazen¡ prvn¡ ‡ sti textu
         ret

Inform   ENDP

; -----------------------------------------------------------------------------
;        data instala‡n¡ ‡ sti programu
; -----------------------------------------------------------------------------

OdIns    db        0                        ; 1=p©¡znak odinstalov n¡

OldVMod  db        0

ErrTxt   db        'Neni karta EGA/VGA !',13,10,'$'

Help     db        'Zadejte: /C=azbuka, /0=IBM, /!=odinstalovani',13,10
         db        '$'

UvTxt    db        'EGAAZBUK V1.0 - azbuka, (c) Miroslav Nemecek',13,10,'$'

DInsTxt  db        'EGAAZBUK byl odinstalovan.',13,10,'$'
ErrDIns  db        'EGAAZBUK nelze odinstalovat !',13,10,'$'
ErrDIn2  db        'EGAAZBUK nebyl dosud nainstalovan !',13,10,'$'

Code     ENDS
         END       Start

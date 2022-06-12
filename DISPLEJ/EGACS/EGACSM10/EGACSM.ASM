
b0       EQU       1
b1       EQU       2
b2       EQU       4
b3       EQU       8
b4       EQU       10h
b5       EQU       20h
b6       EQU       40h
b7       EQU       80h

KORIG    EQU       5ch-103h                 ; korekce adres

; *****************************************************************************
;
;               Ovlada‡ ‡esk‚ho displeje EGA/VGA - mikroverze
;
; *****************************************************************************

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

Start:   jmp       Init                     ; start programu

RezBeg   LABEL     NEAR                     ; za‡ tek rezidentn¡ ‡ sti programu

; -----------------------------------------------------------------------------
;               Obsluha p©eru¨en¡ INT 10h
; -----------------------------------------------------------------------------

Ident    label     byte                     ; za‡ tek k identifikaci

Int10    PROC      FAR

; ------ test, zda se p©einstalov vaj¡ fonty

         or        ah,ah
         jz        Int102
         cmp       ah,11h
         je        Int102

; ------ nen¡ inicializace font– - pokra‡ov n¡ p–vodn¡ obsluhou

         db        0eah                     ; instrukce JMP FAR
Ident0   label     byte                     ; konec identifikace
Old10    dd        0                        ; p–vodn¡ adresa INT 10h

; ------ vol n¡ p–vodn¡ obsluhy

Int102:  pushf
         db        9ah                      ; instrukce CALL FAR
Old101   dd        0                        ; p–vodn¡ adresa INT 10h

; ------ £schova registr–

Int102X: push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es

; ------ kontrola ‡¡sla videom¢du, p©¡prava registru mapov n¡

         cld

         xor       cx,cx
         mov       ds,cx                    ; ES <- 0
         mov       al,ds:[449h]             ; videom¢d
         and       al,7fh
         mov       ah,0eh                   ; mapov n¡ pro CGA
         cmp       al,3
         jbe       Int103                   ; je CGA m¢d
         cmp       al,7
         jne       Int109                   ; nepovolen˜ videom¢d
         mov       ah,0ah                   ; mapov n¡ pro MDA m¢d
Int103:  mov       si,offset InitTab0+KORIG
         mov       cs:[si+7],ah             ; registr mapov n¡

; ------ inicializace registr– pro definici font– (CH=0)

         call      InitReg                  ; inicializace registr–

; ------ p©¡prava k dek¢dov n¡ znak–

         mov       bx,offset TabDef+KORIG   ; defini‡n¡ tabulka
         mov       ax,0a000h
         mov       es,ax
         mov       ds,ax
         mov       di,128*32                ; ukl dac¡ adresa font–

; ------ dek¢dov n¡ znak–

Int104:  push      di
         mov       al,cs:[bx]
         mov       dl,al
         inc       bx

; ------ adresa vzoru znaku

         and       al,3fh
         jz        Int107
         or        al,40h
         mov       ah,32
         mul       ah
         xchg      ax,si
         mov       cl,16
         rep       movsw

; ------ doplnˆn¡ znam‚nka

         xchg      ax,dx
         test      al,b5
         jz        Int105
         inc       di                       ; korekce pro mal  p¡smenka
Int105:  mov       dx,0001100000001100b     ; ‡ rka
         test      al,b6+b7
         jz        Int106                   ; je ‡ rka
         mov       dx,0011100001101100b     ; st©¡¨ka
         test      al,b7
         jz        Int106                   ; je h ‡ek
         xchg      dh,dl                    ; st©¡¨ka
         test      al,b6
         jnz       Int106                   ; je st©¡¨ka
         or        ds:[di-32+2],dl          ; spodek krou‘ku
Int106:  or        word ptr ds:[di-32],dx   ; doplnˆn¡ znam‚nka

; ------ p©¡prava pro dal¨¡ znak

Int107:  pop       di
         add       di,32
         cmp       bl,((offset TabDef0-offset Start)+100h+KORIG) AND 0ffh
         jne       Int104

; ------ n vrat inicializace registr–

         mov       si,offset InitTab1+KORIG
         call      InitReg                  ; inicializace registr–

; ------ n vrat registr–

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

InitTab0 label     byte                     ; inicializace registr– - fonty
         db        4                        ; roviny k z pisu
         db        7                        ; prokl d n¡
         db        4                        ; mapov n¡ pamˆti
         db        0                        ; registr m¢du
         db        2                        ; ‡tec¡ rovina

InitTab1 label     byte                     ; inicializace registr– - text
         db        3                        ; roviny k z pisu
         db        3                        ; prokl d n¡
         db        0eh                      ; mapov n¡ pamˆti
         db        10h                      ; registr m¢du
         db        0                        ; ‡tec¡ rovina

; -----------------------------------------------------------------------------
;        Inicializace registr– videokarty
; -----------------------------------------------------------------------------
; VSTUP: 0: roviny k z pisu (bit 0 = text, bit 1 = atributy, bit 2 = fonty)
;        1: nastaven¡ prokl d n¡ (3=je prokl d n¡ rovin, 7=sekven‡n¡ adresy)
;        2: nastaven¡ mapov n¡ (04h=A000h, 0Ah=B000h, 0Eh=B800h)
;        3: registr m¢du (0=sekven‡n¡ adresov n¡, 10h=prokl dan‚ adresov n¡)
;        4: ‡tec¡ rovina (0=text, 1=atributy, 2=fonty)
; -----------------------------------------------------------------------------

InitReg  PROC      NEAR

         push      cs
         pop       ds

; ------ volba rovin pro z pis (maska)

         mov       dx,3c4h                  ; b zov  adresa 03c4h
         mov       al,2
         call      SetReg                   ; nastaven¡ rovin pro z pis

; ------ nastav. prokl d n¡ bajt– sud /lich 

         mov       al,4
         call      SetReg                   ; nastaven¡ prokl d n¡ bajt–

; ------ nastaven¡ mapov n¡ videopamˆti (adresa)

         mov       dl,0ceh                  ; port 03ceh/03cfh
         mov       al,6
         call      SetReg                   ; nastaven¡ mapov n¡ videopamˆti

; ------ nastaven¡ registru m¢du (‡ten¡ i z pis - M•D 0)

         mov       al,5
         call      SetReg

; ------ volba roviny pro ‡ten¡

         mov       al,4
         call      SetReg                   ; nastaven¡ roviny ke ‡ten¡
         ret

InitReg  ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ registru AH portu DX na AL
; -----------------------------------------------------------------------------

SetReg   PROC      NEAR

         out       dx,al                    ; volba registru
         inc       dx
         lodsb
         out       dx,al                    ; nastaven¡ registru
         dec       dx
         ret

SetReg   ENDP

; -----------------------------------------------------------------------------
;        tabulka pro definici znak–
; -----------------------------------------------------------------------------

TabDef   label     byte
         db        'C'-b6 + b6              ; 128 "€"
         db        0                        ; 129 ""
         db        0                        ; 130 "‚"
         db        'd'-b6 + b6              ; 131 "ƒ"
         db        0                        ; 132 "„"
         db        'D'-b6 + b6              ; 133 "…"
         db        'T'-b6 + b6              ; 134 "†"
         db        'c'-b6 + b6              ; 135 "‡"
         db        'e'-b6 + b6              ; 136 "ˆ"
         db        'E'-b6 + b6              ; 137 "‰"
         db        'L'-b6                   ; 138 "Š"
         db        'I'-b6                   ; 139 "‹"
         db        'l'-b6 + b6              ; 140 "Œ"
         db        'l'-b6                   ; 141 ""
         db        0                        ; 142 "Ž"
         db        'A'-b6                   ; 143 ""
         db        0                        ; 144 ""
         db        'z'-b6 + b6              ; 145 "‘"
         db        'Z'-b6 + b6              ; 146 "’"
         db        0                        ; 147 "“"
         db        0                        ; 148 "”"
         db        'O'-b6                   ; 149 "•"
         db        'u'-b6      + b7         ; 150 "–"
         db        'U'-b6                   ; 151 "—"
         db        'y'-b6                   ; 152 "˜"
         db        0                        ; 153 "™"
         db        0                        ; 154 "š"
         db        'S'-b6 + b6              ; 155 "›"
         db        'L'-b6 + b6              ; 156 "œ"
         db        'Y'-b6                   ; 157 ""
         db        'R'-b6 + b6              ; 158 "ž"
         db        't'-b6 + b6              ; 159 "Ÿ"
         db        0                        ; 160 " "
         db        0                        ; 161 "¡"
         db        0                        ; 162 "¢"
         db        0                        ; 163 "£"
         db        'n'-b6 + b6              ; 164 "¤"
         db        'N'-b6 + b6              ; 165 "¥"
         db        'U'-b6      + b7         ; 166 "¦"
         db        'O'-b6 + b6 + b7         ; 167 "§"
         db        's'-b6 + b6              ; 168 "¨"
         db        'r'-b6 + b6              ; 169 "©"
         db        'r'-b6                   ; 170 "ª"
         db        'R'-b6                   ; 171 "«"
TabDef0  label     byte

RezEnd   label     byte                     ; konec rezidentn¡ ‡ sti programu

; *****************************************************************************
;
;                           Instalace programu
;
; *****************************************************************************
;þ
; ------ p©esun programu dol–

Init:    mov       si,offset RezBeg
         mov       di,offset RezBeg+KORIG
         mov       cx,offset(RezEnd-RezBeg)
         cld
         rep       movsb                    ; p©esun programu dol–

; ------ adresa obsluhy INT 10h

         mov       ax,3510h
         int       21h                      ; poskytnut¡ adresy INT 10h

         mov       si,offset Ident+KORIG
         mov       word ptr ds:[si+Old10-Ident],bx ; offset INT 10h
         mov       word ptr ds:[si+Old10-Ident+2],es ; segment obsluhy
         mov       word ptr ds:[si+Old101-Ident],bx ; offset INT 10h
         mov       word ptr ds:[si+Old101-Ident+2],es ; segment obsluhy

; ------ test, zda je program nainstalov n

         mov       di,si
         mov       cl,offset(Ident0-Ident)
         cld
         repe      cmpsb                    ; porovn n¡ programu
         jne       Init5                    ; program nen¡ nainstalov n

; ------ hl ¨en¡ o odinstalov n¡

         mov       dx,offset DInstTxt       ; hl ¨en¡ o odinstalov n¡
         mov       ah,9
         int       21h                      ; zobrazen¡ hl ¨en¡

; ------ n vrat adresy INT 10h

         lds       dx,es:[Old10+KORIG]
         mov       ax,2510h
         int       21h                      ; n vrat obsluhy INT 10h

; ------ uvolnˆn¡ bloku programu

         mov       ah,49h
         int       21h                      ; uvolnˆn¡ bloku programu

; ------ konec programu (n vratov˜ k¢d 1)

         mov       ax,4c01h
         int       21h

; ------ zobrazen¡ hl ¨en¡ o instalaci

Init5:   mov       dx,offset UvTxt          ; hl ¨en¡ o instalaci
         mov       ah,9
         int       21h                      ; zobrazen¡ hl ¨en¡

; ------ instalace obsluhy INT 10h

         mov       dx,offset Int10+KORIG
         mov       ax,2510h
         int       21h                      ; instalace obsluhy INT 10h

; ------ p©einstalov n¡ videom¢du

         pushf
         push      cs
         call      Int102X+KORIG            ; inicializace videom¢du

; ------ uvolnˆn¡ bloku prost©ed¡

         mov       es,ds:[2ch]              ; segment prost©ed¡
         mov       ah,49h
         int       21h                      ; uvolnˆn¡ segmentu prost©ed¡

; ------ instalace programu do pamˆti

         mov       dx,offset RezEnd + KORIG
         int       27h

; -----------------------------------------------------------------------------
;                             data pro instalaci
; -----------------------------------------------------------------------------

UvTxt    db        'EGACSM V1.10 - FREEWARE; (c) Miroslav Nemecek',13,10,'$'
DInstTxt db        'EGACSM byl odinstalovan.',13,10,'$'

Code     ENDS

         END       Start


KORIG    EQU       5ch-103h                 ; korekce adres

; *****************************************************************************
;
;                 Ovlada‡ ‡esk‚ kl vesnice - minim ln¡ verze
;
; *****************************************************************************

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

Start:   jmp       Init                     ; start programu

RezBeg   LABEL     NEAR                     ; za‡ tek rezidentn¡ ‡ sti programu

; -----------------------------------------------------------------------------
;               Obsluha p©eru¨en¡ od kl vesnice INT 09H
; -----------------------------------------------------------------------------

Ident    label     byte                     ; za‡ tek k identifikaci

Int09    PROC      FAR

; ------ £schova registr–

         push      ax
         push      bx
         push      si
         push      ds

; ------ £schova ukl dac¡ adresy do bufferu kl vesnice

         mov       bx,40h                   ; segment dat BIOS
         mov       ds,bx                    ; DS <- segment dat BIOS 0040h
         mov       si,word ptr ds:[bx-40h+1ch] ; ukl dac¡ adresa do bufferu

; ------ vol n¡ p–vodn¡ obsluhy kl vesnice

         pushf                              ; simulace vol n¡ INT
         db        9ah                      ; instrukce CALL FAR

Ident0   label     byte                     ; konec k identifikaci

Old09    dd        0                        ; p–vodn¡ obsluha INT 09h

; ------ test, zda byl p©ijat znak

         cmp       si,word ptr ds:[bx-40h+1ch] ; byl p©ijat znak ?
         je        Int098                   ; nebyl p©ijat znak

; ------ rozli¨en¡, zda byl prefix

         mov       ah,0
         mov       al,ds:[si]               ; p©ijat  kl vesa
Int092:  jmp       short Int097             ; nebyl zad n prefix

Int093:  db        2eh,0c6h,47h,offset(Int092+KORIG+1-40h),offset(Int097-Int093)
;        mov       byte ptr cs:[bx-40h+Int092+KORIG+1],offset(Int097-Int093)

; ------ nalezen¡ kl vesy v bufferu

         mov       bl,offset TabKod+KORIG - 2 ; (BH=0)
Int094:  inc       bx
         inc       bx
         cmp       cs:[bx],ah               ; je konec tabulky ?
         je        Int098                   ; konec tabulky - kl vesa nenalezena
         cmp       al,cs:[bx]               ; je to p©ijat  kl vesa ?
         jne       Int094                   ; nen¡ je¨tˆ konec - dal¨¡

; ------ kl vesa nalezena - zmˆna k¢du kl vesy

         mov       al,cs:[bx+1]             ; n hradn¡ znak
         mov       ds:[si],ax               ; n hrada kl vesy

; ------ test, zda je prefixov  kl vesa

Int097:  cmp       al,"`"                   ; je prefixov  kl vesa ?
         jne       Int098                   ; nen¡ prefixov  kl vesa

         xor       bx,bx                    ; BX <- 0
         db        2eh,88h,5fh,offset(Int092+KORIG+1)
;        mov       byte ptr cs:[bx+Int092+KORIG+1],bl; p©¡znak prefixu
         mov       ds:[bx+1ch],si           ; zru¨en¡ kl vesy v bufferu

; ------ n vrat registr–

Int098:  pop       ds
         pop       si
         pop       bx
         pop       ax
         iret

Int09    ENDP

; -----------------------------------------------------------------------------
;        k¢dovac¡ tabulka znak–
; -----------------------------------------------------------------------------

TabKod   label     byte
         db        "q„"                     ; "„"
         db        "QŽ"                     ; "Ž"
         db        "wˆ"                     ; "ˆ"
         db        "W‰"                     ; "‰"
         db        "e‚"                     ; "‚"
         db        "E"                     ; ""
         db        "r©"                     ; "©"
         db        "Rž"                     ; "ž"
         db        "tŸ"                     ; "Ÿ"
         db        "T†"                     ; "†"
         db        "y˜"                     ; "˜"
         db        "Y"                     ; ""
         db        "u£"                     ; "£"
         db        "U—"                     ; "—"
         db        "i¡"                     ; "¡"
         db        "I‹"                     ; "‹"
         db        "o¢"                     ; "¢"
         db        "O•"                     ; "•"
         db        "p”"                     ; "”"
         db        "P™"                     ; "™"
         db        "a "                     ; " "
         db        "A"                     ; ""
         db        "s¨"                     ; "¨"
         db        "S›"                     ; "›"
         db        "dƒ"                     ; "ƒ"
         db        "D…"                     ; "…"
         db        "fª"                     ; "ª"
         db        "F«"                     ; "«"
         db        "h"                     ; ""
         db        "Hš"                     ; "š"
         db        "j–"                     ; "–"
         db        "J¦"                     ; "¦"
         db        "k“"                     ; "“"
         db        "K§"                     ; "§"
         db        "lŒ"                     ; "Œ"
         db        "Lœ"                     ; "œ"
         db        "z‘"                     ; "‘"
         db        "Z’"                     ; "’"
         db        "c‡"                     ; "‡"
         db        "C€"                     ; "€"
         db        "n¤"                     ; "¤"
         db        "N¥"                     ; "¥"
         db        "m"                     ; ""
         db        "MŠ"                     ; "Š"
         db        "\­"                     ; "­"
         db        0

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

; ------ adresa obsluhy INT 09h

         mov       ax,3509h
         int       21h                      ; poskytnut¡ adresy INT 09h
         mov       word ptr ds:[Old09+KORIG],bx ; offset INT 09h
         mov       word ptr ds:[Old09+KORIG+2],es ; segment obsluhy

; ------ test, zda je program nainstalov n

         mov       si,offset Ident+KORIG
         mov       di,si
         mov       cl,offset(Ident0-Ident)
         cld
         repe      cmpsb                    ; porovn n¡ programu
         jne       Init5                    ; program nen¡ nainstalov n

; ------ hl ¨en¡ o odinstalov n¡

         mov       dx,offset DInstTxt       ; hl ¨en¡ o odinstalov n¡
         mov       ah,9
         int       21h                      ; zobrazen¡ hl ¨en¡

; ------ n vrat adresy INT 09h

         lds       dx,es:[Old09+KORIG]
         mov       ax,2509h
         int       21h                      ; n vrat obsluhy INT 09h

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

; ------ instalace obsluhy INT 09h

         mov       dx,offset Int09+KORIG
         mov       ax,2509h
         int       21h                      ; instalace obsluhy INT 09h

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

UvTxt    db        'CSKEYMin V1.10 - FREEWARE; (c) Miroslav Nemecek (diakritika=<`>)',13,10,'$'

DInstTxt db        'CSKEYMin byl odinstalovan.',13,10,'$'

;UvTxt    db        'CSKEYMIN V 1.10 - ovladac CS klavesnice; (c) Miroslav Nemecek',13,10
;         db        'Program byl nainstalovan. Diakriticke znamenko = klavesa <`>.',13,10
;         db        '° Tento program je FREEWARE a je mozne ho neomezene sirit ! °',13,10
;         db        '$'
;
;DInstTxt db        'CSKEYMIN byl odinstalovan z pameti.',13,10,'$'

Code     ENDS

         END       Start

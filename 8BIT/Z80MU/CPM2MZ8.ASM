
Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; ------ £vodn¡ text

Start:   mov       dx,offset UvText
         mov       ah,9
         int       21h

; ------ p©¡prava jm‚na programu

         mov       di,offset Nazev
         mov       si,5dh                   ; jm‚no souboru
         mov       cx,8
         cld
Start1:  movsb
         cmp       byte ptr ds:[si]," "
         ja        Start1
         mov       byte ptr ds:[si],"."
         inc       si

; ------ otev©en¡ vstupn¡ho souboru

Start2:  mov       word ptr ds:[si],"PC"
         mov       word ptr ds:[si+2],"M"
         mov       dx,5dh
         mov       ax,3d00h
         int       21h                      ; otev©en¡ vstupn¡ho souboru
         jc        Chyba
         xchg      ax,bx

; ------ na‡ten¡ instrukce skoku

         mov       dx,offset StrtAdr-1
         mov       cx,3
         mov       ah,3fh
         int       21h                      ; na‡ten¡ instrukce skoku
         jc        Chyba

; ------ p©¡prava parametr– programu

         mov       dx,offset StrtTxt
         cmp       byte ptr ds:[StrtAdr-1],0c3h ; je JP start ?
         jne       Chyba2                   ; nen¡ startovac¡ adresa
         mov       ax,ds:[StrtAdr]          ; startovac¡ adresa
         mov       ds:[BegAdr],ax           ; po‡ te‡n¡ adresa

; ------ p©esko‡en¡ neplatn˜ch dat programu

         sub       ax,103h                  ; zbytek na neplatn  data
         jbe       Start3                   ; nejsou ‘ dn  neplatn  data
         xchg      ax,cx                    ; CX <- po‡et bajt– k p©esko‡en¡
         mov       dx,offset Buffer
         mov       ah,3fh
         int       21h                      ; p©esko‡en¡ neplatn˜ch dat

; ------ na‡ten¡ vstupn¡ho souboru

Start3:  mov       dx,offset Buffer
         mov       cx,0f000h
         mov       ah,3fh
         int       21h
         jc        Chyba
         mov       ds:[Delka],ax            ; d‚lka programu
         add       ax,offset(Zahlavi0-Zahlavi)

; ------ otev©en¡ v˜stupn¡ho souboru

         push      ax
         mov       word ptr ds:[si],"ZM"
         mov       word ptr ds:[si+2],"8"
         mov       ah,3ch
         xor       cx,cx
         mov       dx,5dh
         int       21h                      ; otev©en¡ vstupn¡ho souboru
         xchg      ax,bx
         pop       cx
         jc        Chyba

; ------ z pis v˜stupn¡ho souboru

         mov       dx,offset Zahlavi
         mov       ah,40h
         int       21h                      ; z pis
         int       20h

; ------ chyba

Chyba:   mov       dx,offset ZadTxt
Chyba2:  mov       ah,9
         int       21h
         int       20h

; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------

UvText   db        'CPM2MZ8 - konverze programu CPM (CP/M) na MZ8 (SHARP MZ800)',13,10,'$'
ZadTxt   db        'Zadejte jmeno programu bez pripony - cteni z CPM, zapis do MZ8',13,10,'$'
StrtTxt  db        'V programu CPM neudana startovaci adresa (END xxx) !',13,10,'$'

Zahlavi  label     byte                     ; z hlav¡ programu MZ8
         db        1                        ; syp souboru - program
Nazev    db        17 dup (13)              ; jm‚no programu
Delka    dw        0                        ; d‚lka programu
BegAdr   dw        0                        ; po‡ te‡n¡ adresa programu
StrtAdr  dw        0                        ; startovac¡ adresa programu
Koment   db        104 dup (13)             ; koment © k programu
Zahlavi0 label     byte

Buffer   label     byte

Code     ENDS
         END       Start

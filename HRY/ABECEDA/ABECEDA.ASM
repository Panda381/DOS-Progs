
Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; ------ test, je-li karta EGA nebo VGA

Start:   mov       ah,12h
         mov       bx,9a10h
         call      Int10
         cmp       bh,1
         ja        Start1
         cmp       bl,4
         jbe       Start2

; ------ chyba - nen¡ karta EGA/VGA

Start1:  mov       dx,offset CardTxt
         mov       ah,9
         int       21h
         int       20h

; ------ inicializace videom¢du

Start2:  mov       ax,10h
         call      Int10
         mov       ah,0fh
         call      Int10
         cmp       al,10h
         jne       Start1                   ; chyba - videom¢d nenastaven

; ------ p©¡prava k zobrazen¡ obr zku

         cld
         mov       si,offset Obrazek+16     ; za‡ tek dat k zobrazen¡
         mov       ax,0a000h
         mov       es,ax                    ; ES <- segment videopamˆti
         mov       bh,1                     ; z pisov  rovina

; ------ nastaven¡ barevn‚ roviny

Start3:  mov       dx,3c4h
         mov       al,2                     ; registr volby z pisov‚ roviny
         out       dx,al
         inc       dx
         mov       al,bh                    ; ‡¡slo z pisov‚ roviny
         out       dx,al                    ; volba z pisov‚ roviny

; ------ zobrazen¡ jedn‚ roviny

         mov       cx,80*350/2              ; po‡et slov k zobrazen¡
         xor       di,di
Start4:  call      ReadByte                 ; na‡ten¡ 1. bajtu
         mov       ah,al                    ; 1. bajt
         call      ReadByte                 ; na‡ten¡ 2. bajtu
         xchg      ah,al
         stosw                              ; ulo‘en¡ 2 bajt–
         loop      Start4                   ; dal¨¡ dvojice bajt–

; ------ p©¡prava pro dal¨¡ z pisovou rovinu

         shl       bh,1                     ; zv˜¨en¡ ukazatele rovin
         cmp       bh,10h
         jne       Start3                   ; z pis dal¨¡ roviny

; ------ zobrazen¡ znaku kurzoru

Start5:  mov       ax,0fh*256 + "_"
         call      DispChr

; ------ vstup znaku z kl vesnice

         mov       ah,0
         int       16h
         or        ax,ax
         jz        Start6
         cmp       al,27
         jne       Start7

; ------ konec programu ESC - n vrat videom¢du a konec programu

Start6:  mov       ax,3
         int       10h                      ; n vrat text. videom¢du
         int       20h

; ------ vypnut¡ kurzoru

Start7:  push      ax
         mov       ax,720h
         call      DispChr                  ; vymaz n¡ kurzoru
         pop       ax

; ------ n vrat o pozici zpˆt

Start71: cmp       ax,4b00h
         je        Start72                  ; ¨ipka vlevo
         cmp       al,8
         je        Start72                  ; BS
         cmp       ax,5300h
         jne       Start74                  ; nen¡ Delete
Start72: cmp       byte ptr ds:[Pozice],0   ; je ji‘ za‡ tek © dku ?
         je        Start5                   ; je ji‘ za‡ tek © dku
         dec       byte ptr ds:[Pozice]     ; sn¡‘en¡ pozice na © dku
Start55: jmp       short Start5             ; dal¨¡ znak

; ------ pozice vpravo

Start74: cmp       ax,4d00h
         jne       Start75
         mov       al," "

; ------ © dek nahoru

Start75: cmp       ax,4800h
         jne       Start8
         cmp       byte ptr ds:[Radek],19
         je        Start55
         dec       byte ptr ds:[Radek]
         jmp       short Start55

; ------ © dek dol–

Start8:  cmp       ax,5000h
         je        Start93

; ------ nov˜ © dek ENTER

         cmp       al,0dh
         je        Start92                  ; zv˜¨en¡ ‡¡sla © dku

; ------ zobrazen¡ platn‚ho znaku

         cmp       al,0
         je        Start55                  ; ©¡dic¡ kl vesa se ignoruje
         mov       ah,12                    ; barva znaku
         call      DispChr                  ; zobrazen¡ znaku AL

; ------ zv˜¨en¡ pozice na © dku

         inc       byte ptr ds:[Pozice]     ; zv˜¨en¡ pozice na © dku
         cmp       byte ptr ds:[Pozice],80  ; je ji‘ konec © dku ?
         jne       Start55                  ; nen¡ je¨tˆ konec © dku

; ------ zv˜¨en¡ ‡¡sla © dku

Start92: mov       byte ptr ds:[Pozice],0   ; vynulov n¡ pozice
Start93: inc       byte ptr ds:[Radek]      ; zv˜¨en¡ ‡¡sla © dku
         cmp       byte ptr ds:[Radek],25   ; je ji‘ posledn¡ © dek ?
         jne       Start55                  ; nen¡ je¨tˆ posledn¡ © dek

; ------ p©ete‡en¡ konec - rolov n¡ obrazovky

         mov       byte ptr ds:[Radek],24   ; omezen¡ ‡¡sla © dku
         mov       ax,601h                  ; po‡et © dk– = 1
         mov       bh,0                     ; atribut barvy
         mov       cx,19*256                ; lev˜ horn¡ roh
         mov       dx,24*256+79             ; prav˜ doln¡ roh
         call      Int10                    ; rolov n¡ obrazovky
         jmp       short Start55            ; nov  kl vesa

; -----------------------------------------------------------------------------
;        zobrazen¡ znaku AL, barva AH (bez ©¡zen¡)
; -----------------------------------------------------------------------------

DispChr  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx

; ------ nastaven¡ pozice kurzoru

         push      ax
         mov       dx,ds:[PozRad]           ; © dek a pozice
         mov       ah,2
         mov       bh,0                     ; ‡¡slo str nky
         call      Int10                    ; nastaven¡ pozice kurzoru
         pop       ax

; ------ zobrazen¡ znaku na pozici kurzoru

         mov       bl,ah                    ; barva znaku
         mov       bh,0                     ; str nka
         mov       ah,9
         mov       cx,1                     ; po‡et znak– k z pisu
         call      Int10                    ; zobrazen¡ znaku AL

; ------ n vrat registr–

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispChr  ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 10h s £schovou registr–
; -----------------------------------------------------------------------------

Int10    PROC      NEAR

         pushf
         push      si
         push      di
         push      bp
         push      es
         push      ds

         int       10h

         pop       ds
         pop       es
         pop       bp
         pop       di
         pop       si
         popf
         ret

Int10    ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ bajtu obr zku v kompresn¡m m¢du
; -----------------------------------------------------------------------------

ReadByte PROC      NEAR

; ------ na‡ten¡ bajtu po‡tu dat komprese

         cmp       byte ptr ds:[KompCit],0  ; je ‡¡ta‡ platn˜ ?
         jne       ReadByt4                 ; ‡¡ta‡ je dosud platn˜
ReadByt1:lodsb                              ; na‡ten¡ bajtu ‡¡ta‡e
         mov       byte ptr ds:[KompCit],al ; po‡et n sleduj¡c¡ch bajt–

; ------ p©ep¡na‡ m¢du komprese

         or        al,al                    ; je to jen p©ep¡na‡ ?
         jnz       ReadByt2                 ; nen¡ to p©ep¡na‡
         xor       byte ptr ds:[KompPar],1  ; zmˆna p©¡znaku komprese
         jmp       short ReadByt1           ; nov‚ ‡ten¡ bajtu

; ------ na‡ten¡ bajtu k opakov n¡

ReadByt2:and       byte ptr ds:[KompPar],not 2 ; zru¨en¡ p©¡znaku komprese
         test      byte ptr ds:[KompPar],1  ; je m¢d komprese ?
         jz        ReadByt3                 ; nen¡ m¢d komprese
         or        byte ptr ds:[KompPar],2  ; p©¡znak komprese
         lodsb                              ; na‡ten¡ bajtu k opakov n¡
         mov       ds:[KompChar],al         ; bajt k opakov n¡

; ------ zmˆna p©¡znaku m¢du komprese

ReadByt3:cmp       byte ptr ds:[KompCit],255 ; je zmˆna m¢du komprese ?
         je        ReadByt4                 ; nen¡ zmˆna m¢du komprese
         xor       byte ptr ds:[KompPar],1  ; zmˆna p©¡znaku komprese

; ------ na‡ten¡ dal¨¡ho bajtu

ReadByt4:mov       al,ds:[KompChar]         ; bajt p©i opakov n¡ dat
         test      byte ptr ds:[KompPar],2  ; je opakov n¡ dat ?
         jnz       ReadByt5                 ; je opakov n¡ dat
         lodsb                              ; na‡ten¡ bˆ‘n‚ho bajtu dat

; ------ sn¡‘en¡ ‡¡ta‡e bajt–

ReadByt5:dec       byte ptr ds:[KompCit]    ; sn¡‘en¡ ‡¡ta‡e komprese
         ret

ReadByte ENDP

; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------

PozRad   label     word                     ; © dek a pozice
Pozice   db        0                        ; aktu ln¡ pozice na © dku
Radek    db        19                       ; aktu ln¡ © dek k zobrazen¡ znaku

KompCit  db        0                        ; ‡¡ta‡ shodn‚ho bajtu [BP-2]
KompChar db        0                        ; znak k opakov n¡ [BP-3]
KompPar  db        1                        ; p©¡znak komprese [BP-4]

CardTxt  db        'Lituji, program vyzaduje grafickou kartu EGA nebo VGA !',13,10,'$'

Obrazek  label     byte                     ; zde se p©ipoj¡ obr zek

Code     ENDS
         END       Start

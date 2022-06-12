
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                         Vstup textu z obrazovky
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

KORIG    EQU       5ch-103h                 ; korekce adres (posun programu)

BuffMax  EQU       103h-5ch                 ; max. velikost bufferu

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

Start:   jmp       Init

Old16    dd        0                        ; p–vodn¡ adresa INT 16h

BuffAdr  dw        Buffer+KORIG             ; ukazatel ‡tec¡ adresy v bufferu
BuffEnd  dw        Buffer+KORIG             ; adresa konce dat v bufferu
BuffMax  dw        Buffer+80+KORIG          ; maxim ln¡ velikost bufferu

Povel    db        0                        ; povel INT 16h

KurzVRAM dw        0                        ; kurzor ve videopamˆti
AdrVRAM  dw        0                        ; adresa videostr nky
SegmVRAM dw        0b800h                   ; segment videopamˆti
Radek    dw        160                      ; d‚lka © dku (bajt–)
Radku    dw        25                       ; po‡et © dk– displeje

Param    db        0                        ; parametry
                                            ;   bit 0: 1=prob¡h  v˜stup bufferu
                                            ;   bit 1: 1=je karta EGA/VGA

; -----------------------------------------------------------------------------
;        obsluha INT 16h
; -----------------------------------------------------------------------------

INT16    PROC      FAR

; ------ test, zda je povolen  funkce

         test      ah,0eeh                  ; povolen‚ funkce 0, 1, 10h, 11h
         jz        INT161                   ; je povolen  funkce
INT160:  jmp       dword ptr cs:[Old16+KORIG] ; p–vodn¡ obsluha INT 16h

; ------ test, zda prob¡h  v˜stup textu z bufferu

INT161:  mov       cs:[Povel+KORIG],ah      ; £schova ‡¡sla povelu
         test      byte ptr cs:[Param+KORIG],1 ; prob¡h  v˜stup textu z bufferu ?
         jz        INT163                   ; neprob¡h  v˜stup textu z bufferu

; ------ v˜stup textu z bufferu

         push      bx
         mov       bx,cs:[BuffAdr+KORIG]    ; adresa v bufferu
         test      ah,1                     ; je vstup znaku ?
         mov       al,cs:[bx]               ; znak z bufferu
         jnz       INT162                   ; nen¡ vstup - je test
         inc       bx                       ; zv˜¨en¡ ukazatele v bufferu
         mov       cs:[BuffAdr+KORIG],bx    ; nov  adresa v bufferu
         cmp       bx,cs:[BuffEnd+KORIG]    ; je ji‘ konec bufferu ?
         jb        INT162                   ; nen¡ je¨tˆ konec bufferu
         and       byte ptr cs:[Param+KORIG],not 1 ; zru¨en¡ p©¡znaku v˜stupu textu
INT162:  mov       ah,0                     ; SCAN k¢d bˆ‘n‚ho znaku
         or        al,al                    ; je znak 0 ?
         jne       INT1621                  ; nen¡ znak 0
         mov       ah,3                     ; SCAN k¢d znaku 0
INT1621: or        bx,bx                    ; nastaven¡ p©¡znaku NZ
         pop       bx
INT1622: sti
         ret       2

; ------ rozli¨en¡, zda je vstup znaku nebo test znaku

INT163:  test      ah,1                     ; je vstup znaku ?
         jnz       INT165                   ; je test znaku

; ------ vstup znaku z kl vesnice

         call      Exec16                   ; vstup znaku z kl vesnice
         pushf
         call      TestHot                  ; test, zda je hork  kl vesa
         jnc       INT167                   ; je hork  kl vesa
INT164:  popf
         jmp       short INT1622

; ------ test stavu kl vesnice

INT165:  call      Exec16                   ; test stavu kl vesnice
         jz        INT1622                  ; nen¡ p©ipravena kl vesa
         pushf
         call      TestHot
         jc        INT164                   ; nen¡ hork  kl vesa

; ------ zru¨en¡ hork‚ kl vesy z bufferu

INT166:  mov       ah,cs:[Povel+KORIG]      ; p–vodn¡ povel INT 16h
         and       ah,not 1
         call      Exec16                   ; zru¨en¡ kl vesy z bufferu
INT167:  popf

; ------ funkce v˜stupu z bufferu

         cmp       ah,71h                   ; je funkce v˜stupu ?
         jne       INT168                   ; nen¡ funkce v˜stupu
         cmp       word ptr cs:[BuffEnd+KORIG],Buffer+KORIG ; je nˆco v bufferu ?
         je        INT169                   ; nen¡ nic v bufferu
         mov       word ptr cs:[BuffAdr+KORIG],Buffer+KORIG ; adresa textu v bufferu
         or        byte ptr cs:[Param+KORIG],1 ; p©¡znak v˜stupu textu
         jmp       short INT169

; ------ funkce vstupu do bufferu

INT168:  call      InpText                  ; vstup textu z obrazovky

; ------ opakov n¡ p–vodn¡ funkce

INT169:  mov       ah,cs:[Povel+KORIG]      ; p–vodn¡ povel
         jmp       INT161                   ; opakov n¡ funkce

INT16    ENDP

; -----------------------------------------------------------------------------
;        test, zda je hork  kl vesa
; -----------------------------------------------------------------------------

TestHot  PROC      NEAR

         push      ax
         and       ah,not 1
         cmp       ah,70h                   ; je Alt-F9 nebo Alt-F10 ?
         jne       TestHot2                 ; nen¡ hork  kl vesa

         push      ds
         xor       ax,ax
         mov       ds,ax
         test      byte ptr ds:[417h],4     ; je p©esmyka‡ Ctrl ?
         pop       ds
         jnz       TestHot3                 ; je p©esmyka‡ Ctrl OK

TestHot2:stc                                ; p©¡znak, ‘e nen¡ hork  kl vesa
TestHot3:pop       ax
         ret

TestHot  ENDP

; -----------------------------------------------------------------------------
;        vstup textu z obrazovky
; -----------------------------------------------------------------------------

InpText  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      si
         push      di
         push      ds
         push      es

; ------ p©¡prava registr–

         xor       ax,ax
         mov       ds,ax
         mov       al,ds:[449h]             ; aktu ln¡ videom¢d
         mov       cx,0b000h                ; segment videom¢du MDA
         cmp       al,7                     ; je videom¢d MDA ?
         je        InpTxt11
         mov       ch,0b8h                  ; segment videom¢du CGA
         cmp       al,3
         jbe       InpTxt11                 ; je videom¢d CGA
         jmp       InpText9                 ; nepovolen˜ videom¢d
InpTxt11:mov       di,ds:[44eh]             ; adresa videopamˆti
         mov       al,ds:[44ah]             ; po‡et pozic na © dek
         mov       ah,0
         shl       ax,1                     ; p©epo‡et na bajty
         push      cs
         pop       ds
         mov       ds:[Radek+KORIG],ax      ; d‚lka © dku
         mov       ds:[AdrVRAM+KORIG],di    ; adresa videopamˆti
         mov       ds:[SegmVRAM+KORIG],cx   ; segment videopamˆti
         add       di,ds:[KurzVRAM+KORIG]   ; kurzor ve videopamˆti
         mov       es,cx

; ------ ‡ek n¡ na nastaven¡ za‡ tku kurzoru

InpText2:call      Kurzor                   ; ‡ek n¡ na stisk

         cmp       ah,4dh                   ; kurzor vpravo
         jne       InpTxt21
         inc       di
         inc       di

InpTxt21:cmp       ah,4bh                   ; kurzor vlevo
         jne       InpTxt22
         or        di,di
         jz        InpTxt22
         dec       di
         dec       di

InpTxt22:cmp       ah,48h                   ; kurzor nahoru
         jne       InpTxt23
         sub       di,ds:[Radek]
         jc        InpTxt24

InpTxt23:cmp       ah,50h                   ; kurzor dol–
         jne       InpTxt25
InpTxt24:add       di,ds:[Radek+KORIG]
         jns       InpTxt25
         add       di,8000h

InpTxt25:cmp       al,27                    ; ESC p©eru¨en¡
         jne       InpTxt26
         jmp       InpText9                 ; p©eru¨en¡

InpTxt26:cmp       al,13                    ; ENTER
         jne       InpText2                 ; nen¡ ENTER - dal¨¡ znak

; ------ ‡ek n¡ na nastaven¡ konce kurzoru

         mov       cx,1                     ; ‡¡ta‡ znak–
InpText3:call      Kurzor                   ; blik n¡ kurzoru

         cmp       ah,4dh                   ; kurzor vpravo
         jne       InpTxt32
         cmp       cx,ds:[BuffMax+KORIG]    ; byl by buffer ji‘ pln˜ ?
         jae       InpText3                 ; byl by ji‘ pln˜
         inc       cx
         inc       di
         xor       byte ptr es:[di],77h
         inc       di

InpTxt32:cmp       ah,4bh                   ; kurzor vlevo
         jne       InpTxt33
         cmp       cx,1
         je        InpText3
         dec       cx
         dec       di
         xor       byte ptr es:[di],77h
         dec       di

InpTxt33:cmp       ah,47h                   ; Home
         jne       InpTxt35
InpTxt34:cmp       cx,1
         je        InpTxt35
         dec       di
         xor       byte ptr es:[di],77h
         dec       di
         loop      InpTxt34

InpTxt35:cmp       ah,4fh                   ; End
         jne       InpTxt37
InpTxt36:cmp       cx,ds:[BuffMax+KORIG]    ; je buffer ji‘ pln˜ ?
         je        InpTxt37
         inc       di
         xor       byte ptr es:[di],77h
         inc       di
         inc       cx
         jmp       short InpTxt36

InpTxt37:cmp       al,27                    ; ESC ?
         je        InpText4                 ; p©eru¨en¡ operace
         cmp       al,13
         jne       InpText3                 ; nen¡ ENTER

; ------ vymaz n¡ ozna‡en‚ho © dku

InpText4:push      cx
         dec       cx
         jz        InpTxt43
InpTxt42:dec       di
         xor       byte ptr es:[di],77h
         dec       di
         loop      InpTxt42
InpTxt43:pop       cx
         cmp       al,27
         je        InpText9                 ; p©eru¨en¡ operace

; ------ p©enesen¡ textu do bufferu

         mov       si,offset Buffer+KORIG
InpText5:mov       al,es:[di]
         mov       ds:[si],al
         inc       si
         inc       di
         inc       di
         loop      InpText5
         mov       ds:[BuffEnd+KORIG],si    ; konec dat v bufferu

; ------ n vrat registr–

InpText9:pop       es
         pop       ds
         pop       di
         pop       si
         pop       cx
         pop       ax
         ret

InpText  ENDP

; -----------------------------------------------------------------------------
;        ‡ek n¡ na stisk kl vesy (ES:DI=adresa ve videopamˆti)
; -----------------------------------------------------------------------------

Kurzor   PROC      NEAR

         push      bx
         push      cx
         push      ds

         xor       bx,bx
         mov       ds,bx

         mov       bh,es:[di+1]
         mov       ch,2
Kurzor1: xor       byte ptr es:[di+1],77h
         mov       cl,ch
Kurzor2: mov       bl,ds:[46ch]
Kurzor3: sti
         mov       ah,1
         call      Exec16
         jnz       Kurzor5                  ; je kl vesa
         cmp       bl,ds:[46ch]
         je        Kurzor3
         dec       cl
         jnz       Kurzor2
         xor       ch,2 XOR 1
         jmp       short Kurzor1

Kurzor5: mov       ah,0
         call      Exec16                   ; vstup znaku z kl vesnice

Kurzor6: mov       es:[di+1],bh             ; n vrat atributu barvy znaku

         mov       bx,di
         sub       bx,cs:[AdrVRAM+KORIG]
         mov       cs:[KurzVRAM+KORIG],bx   ; £schova kurzoru

         pop       ds
         pop       cx
         pop       bx
         ret

Kurzor   ENDP

Exec16   PROC      NEAR

         pushf
         call      dword ptr cs:[Old16+KORIG]
         ret

Exec16   ENDP

Buffer   label     byte                     ; buffer k uschov n¡ textu

; *****************************************************************************
;
;                            Instalace programu
;
; *****************************************************************************

; ------ zobrazen¡ £vodn¡ho textu

Init:    mov       ah,9
         mov       dx,offset UvTxt
         int       21h

; ------ instalace INT 16h

         mov       ax,3516h
         int       21h
         mov       word ptr ds:[Old16],bx
         mov       word ptr ds:[Old16+2],es

         mov       dx,offset INT16
         mov       ax,2516h
         int       21h

; ------ uvolnˆn¡ segmentu prost©ed¡

         mov       es,ds:[2ch]              ; segment prost©ed¡
         mov       ah,49h
         int       21h                      ; uvolnˆn¡ segmentu prost©ed¡

; ------ instalace programu

         mov       dx,offset Init
         int       27h

UvTxt    db        'INPSCR V 1.0 - vstup textu z obrazovky; (c) Miroslav Nemecek',13,10,'$'

InstTxt  db        '  Program byl nainstalovan do pameti. Stiskem  Ctrl-Alt-F9',13,10
         db        '  oznacite text na obrazovce k uschove do bufferu. Stiskem',13,10
         db        '  Ctrl-Alt-F10 navratite tento text z bufferu zpet.',13,10
         db        '$'

ZadTxt   db        'Zadejte: /! ....... odinstalovani programu z pameti.',13,10
         db        '         cislo .... velikost bufferu ve znacich (stand. 80)',13,10
         db        '$'

Code     ENDS
         END       Start

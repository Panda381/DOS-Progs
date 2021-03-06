
; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�
;
;                         Vstup textu z obrazovky
;
; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�

BuffTop  EQU       5ch                      ; po뇿te뇆� adresa bufferu
BuffMax  EQU       103h-5ch                 ; max. velikost bufferu

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

Start:   jmp       Init

Old16    dd        0                        ; p뻱odn� adresa INT 16h

BuffAdr  dw        BuffTop                  ; ukazatel 뇍ec� adresy v bufferu
BuffEnd  dw        BuffTop                  ; adresa konce dat v bufferu

Povel    db        0                        ; povel INT 16h

KurzVRAM dw        0                        ; kurzor ve videopam늯i
AdrVRAM  dw        0                        ; adresa videostr쟮ky
SegmVRAM dw        0b800h                   ; segment videopam늯i
Radek    dw        160                      ; d굃ka 찤dku (bajt�)

Param    db        0                        ; parametry
                                            ;   bit 0: 1=prob죋� v쁲tup bufferu

; -----------------------------------------------------------------------------
;        obsluha INT 16h
; -----------------------------------------------------------------------------

INT16    PROC      FAR

; ------ test, zda je povolen� funkce

         test      ah,0eeh                  ; povolen� funkce 0, 1, 10h, 11h
         jz        INT161                   ; je povolen� funkce
INT160:  jmp       dword ptr cs:[Old16]     ; p뻱odn� obsluha INT 16h

; ------ test, zda prob죋� v쁲tup textu z bufferu

INT161:  mov       cs:[Povel],ah            ; 즧chova 눀sla povelu
         test      byte ptr cs:[Param],1    ; prob죋� v쁲tup textu z bufferu ?
         jz        INT163                   ; neprob죋� v쁲tup textu z bufferu

; ------ v쁲tup textu z bufferu

         push      bx
         mov       bx,cs:[BuffAdr]          ; adresa v bufferu
         test      ah,1                     ; je vstup znaku ?
         mov       al,cs:[bx]               ; znak z bufferu
         jnz       INT162                   ; nen� vstup - je test
         inc       bx                       ; zv삩en� ukazatele v bufferu
         mov       cs:[BuffAdr],bx          ; nov� adresa v bufferu
         cmp       bx,cs:[BuffEnd]          ; je ji� konec bufferu ?
         jb        INT162                   ; nen� je쮝� konec bufferu
         and       byte ptr cs:[Param],not 1 ; zru쮍n� pæznaku v쁲tupu textu
INT162:  mov       ah,0                     ; SCAN k줰 b닊n괿o znaku
         or        al,al                    ; je znak 0 ?
         jne       INT1621                  ; nen� znak 0
         mov       ah,3                     ; SCAN k줰 znaku 0
INT1621: or        bx,bx                    ; nastaven� pæznaku NZ
         pop       bx
INT1622: sti
         ret       2

; ------ rozli쮍n�, zda je vstup znaku nebo test znaku

INT163:  test      ah,1                     ; je vstup znaku ?
         jnz       INT165                   ; je test znaku

; ------ vstup znaku z kl쟶esnice

         call      Exec16                   ; vstup znaku z kl쟶esnice
         pushf
         call      TestHot                  ; test, zda je hork� kl쟶esa
         jnc       INT167                   ; je hork� kl쟶esa
INT164:  popf
         jmp       short INT1622

; ------ test stavu kl쟶esnice

INT165:  call      Exec16                   ; test stavu kl쟶esnice
         jz        INT1622                  ; nen� p쯫pravena kl쟶esa
         pushf
         call      TestHot
         jc        INT164                   ; nen� hork� kl쟶esa

; ------ zru쮍n� hork� kl쟶esy z bufferu

INT166:  mov       ah,cs:[Povel]            ; p뻱odn� povel INT 16h
         and       ah,not 1
         call      Exec16                   ; zru쮍n� kl쟶esy z bufferu
INT167:  popf

; ------ funkce v쁲tupu z bufferu

         cmp       ah,71h                   ; je funkce v쁲tupu ?
         jne       INT168                   ; nen� funkce v쁲tupu
         cmp       word ptr cs:[BuffEnd],BuffTop ; je n늓o v bufferu ?
         je        INT169                   ; nen� nic v bufferu
         mov       word ptr cs:[BuffAdr],BuffTop ; adresa textu v bufferu
         or        byte ptr cs:[Param],1    ; pæznak v쁲tupu textu
         jmp       short INT169

; ------ funkce vstupu do bufferu

INT168:  call      InpText                  ; vstup textu z obrazovky

; ------ opakov쟮� p뻱odn� funkce

INT169:  mov       ah,cs:[Povel]            ; p뻱odn� povel
         jmp       INT161                   ; opakov쟮� funkce

INT16    ENDP

; -----------------------------------------------------------------------------
;        test, zda je hork� kl쟶esa
; -----------------------------------------------------------------------------

TestHot  PROC      NEAR

         push      ax
         and       ah,not 1
         cmp       ah,70h                   ; je Alt-F9 nebo Alt-F10 ?
         jne       TestHot2                 ; nen� hork� kl쟶esa

         push      ds
         xor       ax,ax
         mov       ds,ax
         test      byte ptr ds:[417h],4     ; je p쯥smyka� Ctrl ?
         pop       ds
         jnz       TestHot3                 ; je p쯥smyka� Ctrl OK

TestHot2:stc                                ; pæznak, 멷 nen� hork� kl쟶esa
TestHot3:pop       ax
         ret

TestHot  ENDP

; -----------------------------------------------------------------------------
;        vstup textu z obrazovky
; -----------------------------------------------------------------------------

InpText  PROC      NEAR

; ------ 즧chova registr�

         push      ax
         push      cx
         push      si
         push      di
         push      ds
         push      es

; ------ pæprava registr�

         xor       ax,ax
         mov       ds,ax
         mov       al,ds:[449h]             ; aktu쟫n� videom줰
         mov       cx,0b000h                ; segment videom줰u MDA
         cmp       al,7                     ; je videom줰 MDA ?
         je        InpTxt11
         mov       ch,0b8h                  ; segment videom줰u CGA
         cmp       al,3
         jbe       InpTxt11                 ; je videom줰 CGA
         jmp       InpText9                 ; nepovolen� videom줰
InpTxt11:mov       di,ds:[44eh]             ; adresa videopam늯i
         mov       al,ds:[44ah]             ; po놽t pozic na 찤dek
         mov       ah,0
         shl       ax,1                     ; p쯥po놽t na bajty
         push      cs
         pop       ds
         mov       ds:[Radek],ax            ; d굃ka 찤dku
         mov       ds:[AdrVRAM],di          ; adresa videopam늯i
         mov       ds:[SegmVRAM],cx         ; segment videopam늯i
         add       di,ds:[KurzVRAM]         ; kurzor ve videopam늯i
         mov       es,cx

; ------ 놽k쟮� na nastaven� za뇿tku kurzoru

InpText2:call      Kurzor                   ; 놽k쟮� na stisk

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

InpTxt23:cmp       ah,50h                   ; kurzor dol�
         jne       InpTxt25
InpTxt24:add       di,ds:[Radek]
         jns       InpTxt25
         add       di,8000h

InpTxt25:cmp       al,27                    ; ESC p쯥ru쮍n�
         jne       InpTxt26
         jmp       InpText9                 ; p쯥ru쮍n�

InpTxt26:cmp       al,13                    ; ENTER
         jne       InpText2                 ; nen� ENTER - dalÆ znak

; ------ 놽k쟮� na nastaven� konce kurzoru

         mov       cx,1                     ; 눀ta� znak�
InpText3:call      Kurzor                   ; blik쟮� kurzoru

         cmp       ah,4dh                   ; kurzor vpravo
         jne       InpTxt32
         cmp       cx,BuffMax               ; byl by buffer ji� pln� ?
         jae       InpText3                 ; byl by ji� pln�
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
InpTxt36:cmp       cx,BuffMax               ; je buffer ji� pln� ?
         je        InpTxt37
         inc       di
         xor       byte ptr es:[di],77h
         inc       di
         inc       cx
         jmp       short InpTxt36

InpTxt37:cmp       al,27                    ; ESC ?
         je        InpText4                 ; p쯥ru쮍n� operace
         cmp       al,13
         jne       InpText3                 ; nen� ENTER

; ------ vymaz쟮� ozna놽n괿o 찤dku

InpText4:push      cx
         dec       cx
         jz        InpTxt43
InpTxt42:dec       di
         xor       byte ptr es:[di],77h
         dec       di
         loop      InpTxt42
InpTxt43:pop       cx
         cmp       al,27
         je        InpText9                 ; p쯥ru쮍n� operace

; ------ p쯥nesen� textu do bufferu

         mov       si,BuffTop
InpText5:mov       al,es:[di]
         mov       ds:[si],al
         inc       si
         inc       di
         inc       di
         loop      InpText5
         mov       ds:[BuffEnd],si          ; konec dat v bufferu

; ------ n쟶rat registr�

InpText9:pop       es
         pop       ds
         pop       di
         pop       si
         pop       cx
         pop       ax
         ret

InpText  ENDP

; -----------------------------------------------------------------------------
;        놽k쟮� na stisk kl쟶esy (ES:DI=adresa ve videopam늯i)
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
         jnz       Kurzor5                  ; je kl쟶esa
         cmp       bl,ds:[46ch]
         je        Kurzor3
         dec       cl
         jnz       Kurzor2
         xor       ch,2 XOR 1
         jmp       short Kurzor1

Kurzor5: mov       ah,0
         call      Exec16                   ; vstup znaku z kl쟶esnice

Kurzor6: mov       es:[di+1],bh             ; n쟶rat atributu barvy znaku

         mov       bx,di
         sub       bx,cs:[AdrVRAM]
         mov       cs:[KurzVRAM],bx         ; 즧chova kurzoru

         pop       ds
         pop       cx
         pop       bx
         ret

Kurzor   ENDP

; -----------------------------------------------------------------------------
;        test znaku
; -----------------------------------------------------------------------------



; -----------------------------------------------------------------------------
;        funkce INT 16h
; -----------------------------------------------------------------------------

Exec16   PROC      NEAR

         pushf
         call      dword ptr cs:[Old16]
         ret

Exec16   ENDP

; *****************************************************************************
;
;                            Instalace programu
;
; *****************************************************************************

; ------ zobrazen� 즪odn죋o textu

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

; ------ uvoln늧� segmentu prost쯥d�

         mov       es,ds:[2ch]              ; segment prost쯥d�
         mov       ah,49h
         int       21h                      ; uvoln늧� segmentu prost쯥d�

; ------ instalace programu

         mov       dx,offset Init
         int       27h

UvTxt    db        'INPSCR V 1.0 - vstup textu z obrazovky; (c) Miroslav Nemecek',13,10
         db        '  Program byl nainstalovan do pameti. Stiskem  Ctrl-Alt-F9',13,10
         db        '  oznacite text na obrazovce k uschove do bufferu. Stiskem',13,10
         db        '  Ctrl-Alt-F10 navratite tento text z bufferu zpet.',13,10
         db        '$'

Code     ENDS
         END       Start

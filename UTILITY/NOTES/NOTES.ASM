
; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�
;
;                                 NOTES
;
;                        Rezidentn� pozn쟭kov� blok
;
; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�

KORIG    EQU       5ch - 103h               ; korekce pro posun programu
Heslo0   EQU       5a82h                    ; dotaz na instalaci - AX
Heslo1   EQU       9bc2h                    ; dotaz na instalaci - BX vstup
Heslo2   EQU       0c356h                   ; dotaz na instalaci - BX v쁲tup
Sirka    EQU       42                       ; Æ쯭a okna (pozic)
Vyska    EQU       7                        ; v삩ka okna (찤dk�)

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

Start:   jmp       Instal

Old16    dd        0                        ; p뻱odn� adresa INT 16h
StatDOS  dd        -1                       ; adresa statutu DOS (-1 = nen�)
Pozice   db        (80-Sirka)/2             ; po뇿te뇆� pozice okna
Radek    db        1                        ; po뇿te뇆� 찤dek okna

TopPoz   dw        0                        ; po뇿te뇆� pozice
TopRad   dw        0                        ; po뇿te뇆� 찤dek
OffsTop  dw        0                        ; offset po뇿te뇆죋o 찤dku
Poz      dw        0                        ; aktu쟫n� pozice kurzoru
Rad      dw        0                        ; aktu쟫n� 찤dek kurzoru
OffsAkt  dw        0                        ; offset aktivn죋o 찤dku

Povel    db        0                        ; povel pro INT 16h
BuffMax  dw        2000                     ; maxim쟫n� velikost bufferu
BuffNum  dw        0                        ; po놽t bajt� v bufferu
BuffTop  dw        0                        ; offset po뇿tku str쟮ky

AktPage  db        0                        ; aktivn� videostr쟮ka
OldKurz  dw        0                        ; uschovan� pozice kurzoru
OldLink  dw        0                        ; uschovan� vzhled kurzoru
AdrVRAM  dd        0                        ; po뇿te뇆� adresa videopam늯i
PocVRAM  dw        0                        ; po뇿te뇆� adresa ve VRAM

Param    db        0                        ; parametry
                                            ;   bit 0: 1=po멲davek odinstalov쟮�
                                            ;   bit 1: 1=zad쟮a velikost bufferu
                                            ;   bit 2: 1=prvn� instalace
                                            ;   bit 3: 1=prob죋� obsluha notesu
                                            ;   bit 4: 1=po멲dov쟮a obsluha
                                            ;   bit 5: 1=nen� INSERT (je p쯥pis)


Soubor   db        'NOTES.0',0
SoubNamN db        7                        ; d굃ka jm굈a souboru
SoubNam  db        'NOTES.0'

; -----------------------------------------------------------------------------
;        obsluha INT 16h
; -----------------------------------------------------------------------------

Int16    PROC      FAR

; ------ dotaz na instalaci programu

         cmp       ax,Heslo0                ; je dotaz na instalaci ?
         jne       Int161
         cmp       bx,Heslo1
         jne       Int161
         push      cs
         pop       es
         mov       bx,Heslo2
         sti
         ret       2

; ------ test, zda je povel pro test nebo vstup znaku

Int161:  test      ah,0eeh                  ; je povel vstupu nebo testu ?
         jz        Int163                   ; povel je OK
Int162:  jmp       dword ptr cs:[Old16+KORIG]

; ------ test, zda je ji� obsluha notesu

Int163:  test      byte ptr cs:[Param+KORIG],8 ; prob죋� obsluha notesu ?
         jnz       Int162                   ; prob죋� obsluha notesu
         mov       cs:[Povel+KORIG],ah      ; 즧chova 눀sla povelu

; ------ test, zda se po멲duje obsluha

         test      byte ptr cs:[Param+KORIG],10h ; po멲duje se obsluha ?
         jnz       Int1680                  ; obsluha notesu

; ------ test p쯫pravenosti znaku

Int164:  test      ah,1                     ; je test znaku ?
         jz        Int165                   ; nen� test znaku
         call      Exec16                   ; test znaku kl쟶esnice
         jz        Int167                   ; nen� p쯫praven znak z kl쟶esnice
         call      TestHot                  ; test hork� kl쟶esy
         jnz       Int167                   ; nen� hork� kl쟶esa
         mov       ah,cs:[Povel+KORIG]      ; povel
         and       ah,not 1                 ; povel pro vstup z kl쟶esnice
         call      Exec16                   ; zru쮍n� znaku z bufferu kl쟶esnice
         jmp       short Int168             ; obsluha pozn쟭kov괿o bloku

Int165:  call      Exec16                   ; vstup znaku z kl쟶esnice
Int166:  call      TestHot                  ; test hork� kl쟶esy
         jz        Int168                   ; je hork� kl쟶esa

Int167:  sti
         ret       2

; ------ test 눀sla videom줰u

Int168:  or        byte ptr cs:[Param+KORIG],10h ; pæznak po멲davku obsluhy

Int1680: push      bx
         push      ds
         xor       bx,bx
         mov       ds,bx
         mov       bl,ds:[449h]             ; aktivn� videom줰
         mov       byte ptr cs:[AdrVRAM+KORIG+3],0b0h ; segment videopam늯i MDA
         cmp       bl,7
         je        Int1681
         mov       byte ptr cs:[AdrVRAM+KORIG+3],0b8h ; segment videopam늯i CGA
         cmp       bl,2
         je        Int1681
         cmp       bl,3
Int1681: pop       ds
         pop       bx
         jne       Int169                   ; nen� povolen� videom줰

; ------ test pæznaku aktivity DOS

         push      bx
         push      ds
         lds       bx,cs:[StatDOS+KORIG]    ; adresa statutu DOS
         cmp       bx,-1                    ; je adresa platn� ?
         je        Int1682                  ; adresa nen� platn�
         cmp       byte ptr ds:[bx],0       ; je mo몁� obsluha DOS ?
Int1682: pop       ds
         pop       bx
         jne       Int169                   ; nen� mo몁� obsluha

; ------ obsluha pozn쟭kov괿o bloku

Int1690: and       byte ptr cs:[Param+KORIG],not 10h ; zru쮍n� po멲davku obsluhy
         or        byte ptr cs:[Param+KORIG],8 ; pæznak obsluhy notesu
         call      Notes                    ; obsluha pozn쟭kov괿o bloku
         and       byte ptr cs:[Param+KORIG],not 8 ; zru쮍n� pæznaku obsluhy
Int169:  mov       ah,cs:[Povel+KORIG]      ; p뻱odn� povel
         jmp       Int164                   ; opakov쟮� funkce

Int16    ENDP

; -----------------------------------------------------------------------------
;        test, zda je hork� kl쟶esa (NZ=nen�)
; -----------------------------------------------------------------------------

TestHot  PROC      NEAR

         cmp       ax,3100h
         jne       TestHot5                 ; nen� hork� kl쟶esa

         push      ds
         push      ax
         xor       ax,ax
         mov       ds,ax
         mov       al,ds:[417h]             ; p쯥smyka놽
         xor       al,4
         and       al,4                     ; je p쯥smyka� Ctrl- ?
         pop       ax
         pop       ds

TestHot5:clc
         ret

TestHot  ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 10h
; -----------------------------------------------------------------------------

Exec10   PROC      NEAR

         push      si
         push      di
         push      bp
         push      ds
         push      es

         int       10h

         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         ret

Exec10   ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 16h
; -----------------------------------------------------------------------------

Exec16   PROC      NEAR

         pushf
         call      dword ptr cs:[Old16+KORIG]
         ret

Exec16   ENDP

; -----------------------------------------------------------------------------
;        obsluha pozn쟭kov괿o bloku
; -----------------------------------------------------------------------------

Notes    PROC      NEAR

; ------ 즧chova registr�

         pushf
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es

; ------ stanoven� parametr� videom줰u

         xor       ax,ax
         mov       ds,ax
         mov       ax,ds:[44eh]             ; po뇿te뇆� adresa videopam늯i
         push      cs
         pop       ds
         mov       word ptr ds:[AdrVRAM+KORIG],ax ; adresa videopam늯i
         mov       es,word ptr ds:[AdrVRAM+2+KORIG]

; ------ 즧chova obsahu displeje

         call      PushScr                  ; 즧chova obsahu displeje


; ------ otev쯥n� a na뇍en� souboru

         call      ReadFile                 ; otev쯥n� a na뇍en� souboru

         call      DispRam                  ; zobrazen� r쟭u okna


Not23:   call      DispInf                  ;
         call      DispFile
         call      DispKurz

; ------ vstup znaku z kl쟶esnice

Not24:   mov       ah,ds:[Povel+KORIG]
         and       ah,not 1                 ; povel pro vstup znaku
         call      Exec16                   ; vstup znaku z kl쟶esnice
         or        ah,ah
         jz        Not232
         cmp       al,0e0h
         je        Not231
         cmp       al,0f0h
         jne       Not232
Not231:  mov       al,0

Not232:  mov       bx,ax                    ; kl쟶esa
         mov       cx,ds:[Poz+KORIG]        ; aktu쟫n� pozice kurzoru
         mov       dx,ds:[Rad+KORIG]        ; aktu쟫n� 찤dek kurzoru
         mov       si,ds:[OffsAkt+KORIG]    ; offset aktivn죋o 찤dku
         call      JumpBX                   ; skok na obsluhu

         dw        4d00h,NotRght+KORIG      ; vpravo
         dw        4b00h,NotLeft+KORIG      ; vlevo
;         dw        5000h,NotDwn+KORIG       ; dol�
;         dw        4800h,NotUp+KORIG        ; nahoru

         dw        5200h,NotIns+KORIG       ; INSERT
         dw        11bh,NotEsc+KORIG        ; ESC
         dw        0,Not24+KORIG
;�
; ------ INSERT - pæznak p쯥pisov쟮�

NotIns:  xor       byte ptr ds:[Param+KORIG],20h ; zm늧a INSERT
Not23x1: jmp       short Not23

; ------ posun kurzoru o pozici vpravo

NotRght: inc       cx                       ; zv삩en� pozice kurzoru
         jnz       NotRght2
Not24x1: jmp       short Not24
NotRght2:mov       ds:[Poz+KORIG],cx        ; nov� pozice kurzoru
         mov       ds:[Rad+KORIG],dx        ; nov� 찤dek kurzoru
         call      NormKurz                 ; normalizace kurzoru
         jmp       short Not23x1            ; nov� zobrazen�

; ------ posun kurzoru o pozici vlevo

NotLeft: jcxz      Not24x1                  ; je ji� po뇿tek 찤dku
         dec       cx                       ; sn죷en� pozice kurzoru
         jmp       short NotRght2

; ------ posun kurzoru o 찤dek dol�

;NotDwn:  inc       dx
;         call      NextRow                  ; dalÆ 찤dek
;         jc        Not24x1                  ; nen� dalÆ 찤dek
;         jmp       short NotRght2

; ------ posun kurzoru o 찤dek nahoru

;NotUp:   dec



; ------ n쟶rat obsahu displeje

NotEsc:  call      PopScr                   ; n쟶rat obsahu displeje

; ------ n쟶rat registr�

         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         popf
         ret

Notes    ENDP

; -----------------------------------------------------------------------------
;        normalizace kurzoru
; -----------------------------------------------------------------------------

NormKurz PROC      NEAR

; ------ 즧chova registr�

         push      ax
         push      cx
         push      dx
         push      si

; ------ normalizace pozice kurzoru

         mov       ax,ds:[Poz+KORIG]        ; pozice kurzoru
         mov       bx,ds:[TopPoz+KORIG]     ; po뇿te뇆� pozice okna
         cmp       ax,bx                    ; je p쯥d oknem ?
         ja        NormKur2                 ; nen� p쯥d oknem
         mov       bx,ax                    ; omezen� po뇿tku okna
NormKur2:sub       ax,Sirka-3               ; maxim쟫n� pozice okna
         jnc       NormKur3
         xor       ax,ax
NormKur3:cmp       ax,bx                    ; p쯥kro놽n max. po뇿tek ?
         jbe       NormKur4                 ; po뇿tek je OK
         mov       bx,ax                    ; omezen� po뇿tku
NormKur4:mov       ds:[TopPoz+KORIG],bx     ; nov� pozice po뇿tku okna



; ------ n쟶rat registr�

         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

NormKurz ENDP

; -----------------------------------------------------------------------------
;        즧chova obsahu obrazovky
; -----------------------------------------------------------------------------

PushScr  PROC      NEAR

; ------ 즧chova registr�

         push      ax
         push      cx
         push      si
         push      di
         push      ds
         push      es

; ------ 즧chova 눀sla aktivn� videostr쟮ky

         mov       ah,0fh
         call      Exec10                   ; poskytnut� aktivn� str쟮ky
         mov       cs:[AktPage+KORIG],bh    ; aktivn� videostr쟮ka

; ------ 즧chova pozice kurzoru

         mov       ah,3
         call      Exec10                   ; poskytnut� pozice kurzoru
         mov       cs:[OldKurz+KORIG],dx    ; 즧chova pozice kurzoru
         mov       cs:[OldLink+KORIG],cx    ; 즧chova linek kurzoru

; ------ v쁯o놽t po뇿te뇆� adresy v삪ezu

         lds       si,cs:[AdrVRAM+KORIG]    ; adresa videopam늯i
         mov       al,160                   ; po놽t bajt� na 찤dek
         mul       byte ptr cs:[Radek+KORIG] ; p쯥po놽t 눀sla 찤dku na offset
         mov       cl,cs:[Pozice+KORIG]     ; po뇿te뇆� pozice
         mov       ch,0
         shl       cx,1                     ; offset na 찤dku
         add       ax,cx                    ; offset ve videostr쟮ce
         add       si,ax                    ; po뇿te뇆� adresa v삪ezu
         mov       cs:[PocVRAM+KORIG],si    ; 즧chova adresy ve videopam늯i

; ------ 즧chova obsahu v삪ezu

         mov       di,offset BuffScr+KORIG  ; buffer obrazovky
         push      cs
         pop       es
         cld
         mov       ax,Vyska                 ; v삩ka v삪ezu (찤dk�)
PushScr1:mov       cx,Sirka                 ; Æ쯭a v삪ezu (pozic)
         rep       movsw                    ; 즧chova jednoho 찤dku
         add       si,160-2*Sirka           ; adresa dalÆho 찤dku
         dec       ax                       ; 눀ta� 찤dk�
         jnz       PushScr1                 ; 즧chova dalÆho 찤dku

; ------ n쟶rat registr�

         pop       es
         pop       ds
         pop       di
         pop       si
         pop       cx
         pop       ax
         ret

PushScr  ENDP

; -----------------------------------------------------------------------------
;        n쟶rat obsahu obrazovky
; -----------------------------------------------------------------------------

PopScr   PROC      NEAR

; ------ 즧chova registr�

         push      ax
         push      cx
         push      si
         push      di
         push      ds
         push      es

; ------ n쟶rat obsahu v삪ezu

         push      cs
         pop       ds
         mov       si,offset BuffScr+KORIG  ; buffer obrazovky
         mov       es,word ptr ds:[AdrVRAM+2+KORIG] ; segment videopam늯i
         mov       di,ds:[PocVRAM+KORIG]    ; po뇿te뇆� adresa ve videopam늯i
         cld
         mov       ax,Vyska                 ; v삩ka v삪ezu (찤dk�)
PopScr1: mov       cx,Sirka                 ; Æ쯭a v삪ezu (pozic)
         rep       movsw                    ; 즧chova jednoho 찤dku
         add       di,160-2*Sirka           ; adresa dalÆho 찤dku
         dec       ax                       ; 눀ta� 찤dk�
         jnz       PopScr1                  ; 즧chova dalÆho 찤dku

; ------ n쟶rat vzhledu a pozice kurzoru

         mov       ah,1
         mov       cx,ds:[OldLink+KORIG]    ; p뻱odn� vzhled kurzoru
         call      Exec10                   ; n쟶rat vzhledu kurzoru
         mov       bh,ds:[AktPage+KORIG]    ; aktivn� vodeostr쟮ka
         mov       ah,2
         mov       dx,ds:[OldKurz+KORIG]    ; p뻱odn� pozice kurzoru
         call      Exec10                   ; n쟶rat pozice kurzoru

; ------ n쟶rat registr�

         pop       es
         pop       ds
         pop       di
         pop       si
         pop       cx
         pop       ax
         ret

PopScr   ENDP

; -----------------------------------------------------------------------------
;        otev쯥n� a na뇍en� souboru do bufferu
; -----------------------------------------------------------------------------

ReadFile PROC      NEAR

; ------ 즧chova registr�

         push      ax
         push      bx
         push      cx
         push      dx

; ------ otev쯥n� souboru

         mov       word ptr ds:[BuffNum+KORIG],0 ; po놽t bajt� v bufferu
         mov       dx,offset Soubor+KORIG
         mov       ax,3d02h
         int       21h
         jc        ReadFil9                 ; soubor nelze otevæt
         mov       bx,ax

; ------ na뇍en� souboru

         mov       dx,offset Buffer+KORIG
         mov       ah,3fh
         mov       cx,ds:[BuffMax+KORIG]
         int       21h                      ; na뇍en� souboru
         jnc       ReadFil3
         xor       ax,ax
ReadFil3:cmp       ax,cx
         jbe       ReadFil4
         mov       ax,cx
ReadFil4:mov       ds:[BuffNum+KORIG],ax    ; po놽t na뇍en쁟h bajt�

; ------ uzav쯥n� souboru

         mov       ah,3eh
         int       21h

; ------ n쟶rat registr�

ReadFil9:pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

ReadFile ENDP

; -----------------------------------------------------------------------------
;        zobrazen� r쟭u okna
; -----------------------------------------------------------------------------

DispRam  PROC      NEAR

; ------ 즧chova registr�

         push      ax
         push      cx
         push      di
         push      es

; ------ pæprava registr�

         mov       es,word ptr ds:[AdrVRAM+2+KORIG]
         mov       di,ds:[PocVRAM+KORIG]
         add       di,160                   ; po뇿te뇆� adresa ve videopam늯i

; ------ zobrazen� lev괿o a prav괿o okraje

         mov       cx,Vyska-2               ; po놽t 찤dk� k zobrazen�
         mov       ax,0fh * 256 + 186
DispRam2:stosw
         mov       es:[di+Sirka*2-4],ax
         add       di,160-2
         loop      DispRam2

; ------ zobrazen� spodn죋o okraje

         mov       al,200
         stosw
         mov       al,205
         mov       cl,Sirka-2
         rep       stosw
         mov       al,188
         stosw

; ------ n쟶rat registr�

         pop       es
         pop       di
         pop       cx
         pop       ax
         ret

DispRam  ENDP

; -----------------------------------------------------------------------------
;        zobrazen� informa뇆죋o 찤dku
; -----------------------------------------------------------------------------

DispInf  PROC      NEAR

; ------ 즧chova registr�

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ pæprava registr�

         mov       es,word ptr ds:[AdrVRAM+2+KORIG]
         mov       di,ds:[PocVRAM+KORIG]
         cld

; ------ vymaz쟮� horn죋o 찤dku

         push      di
         mov       ax,0fh*256 + 201
         stosw
         mov       ax,7020h
         mov       cx,Sirka-2
         rep       stosw
         mov       ax,0fh*256 + 187
         stosw
         pop       di

; ------ zobrazen� pozice a 찤dku kurzoru

         push      di
         add       di,2*2                   ; pozice k zobrazen� 눀sla
         mov       ax,ds:[Poz+KORIG]        ; pozice kurzoru
         mov       bh,70h                   ; barva textu
         call      DispLNum                 ; zobrazen� 눀sla pozice kurzoru
         mov       ax,70h*256 + "/"
         stosw                              ; zobrazen� odd늢ova놽
         mov       ax,ds:[Rad+KORIG]        ; 찤dek kurzoru
         call      DispLNum                 ; zobrazen� 눀sla 찤dku kurzoru
         pop       di

; ------ zobrazen� jm굈a souboru

         push      di
         add       di,(Sirka/2)*2 - 2
         mov       cl,ds:[SoubNamN+KORIG]
         mov       ch,0
         mov       ax,cx
         and       al,0feh
         sub       di,ax
         mov       si,offset SoubNam + KORIG
         mov       ah,70h
         mov       al,ds:[Soubor+KORIG]
         stosw
         mov       al,":"
         stosw
DispInf2:lodsb
         stosw
         loop      DispInf2
         pop       di

; ------ zobrazen� voln� kapacity

         add       di,(Sirka-3)*2           ; adresa konce 찤dku
         mov       ax,ds:[BuffMax+KORIG]    ; velikost bufferu
         sub       ax,ds:[BuffNum+KORIG]    ; zbyl� kapacita bufferu
         call      DispRNum                 ; zobrazen� voln� kapacity

; ------ n쟶rat registr�

         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispInf  ENDP

; -----------------------------------------------------------------------------
;        zobrazen� kurzoru
; -----------------------------------------------------------------------------

DispKurz PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx

         mov       ah,2
         mov       dl,byte ptr ds:[Poz+KORIG]
         sub       dl,byte ptr ds:[TopPoz+KORIG]
         add       dl,byte ptr ds:[Pozice+KORIG]
         mov       dh,byte ptr ds:[Rad+KORIG]
         sub       dh,byte ptr ds:[TopRad+KORIG]
         add       dh,byte ptr ds:[Radek+KORIG]
         inc       dx
         inc       dh
         mov       bh,ds:[AktPage+KORIG]
         call      Exec10                   ; nastaven� aktu쟫n� pozice kurzoru

         mov       cx,607h
         cmp       byte ptr ds:[AdrVRAM+3+KORIG],0b8h
         je        DispKur3
         mov       cx,0b0ch
DispKur3:test      byte ptr ds:[Param+KORIG],20h ; je INSERT ?
         jz        DispKur4                 ; je INSERT
         mov       ch,0                     ; p쯥pis - velk� kurzor
DispKur4:mov       ah,1
         call      Exec10

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispKurz ENDP

; -----------------------------------------------------------------------------
;        zobrazen� souboru
; -----------------------------------------------------------------------------

DispFile PROC      NEAR

; ------ 즧chova registr�

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es

; ------ pæprava registr�

         mov       es,word ptr ds:[AdrVRAM+2+KORIG]
         mov       di,ds:[PocVRAM+KORIG]
         add       di,160+2                 ; adresa ve videopam늯i
         mov       si,ds:[OffsTop+KORIG]    ; offset po뇿tku str쟮ky
         add       si,offset Buffer+KORIG   ; adresa textu
         mov       bp,ds:[BuffNum+KORIG]
         add       bp,offset Buffer+KORIG   ; adresa konce textu
         mov       bh,Vyska-2               ; po놽t 찤dk� k zobrazen�
         cld

; ------ zobrazen� jednoho 찤dku

DispFil2:mov       cx,Sirka-2               ; Æ쯭a 찤dku (pozic)
         mov       dx,ds:[TopPoz+KORIG]     ; pozice po뇿tku 찤dku
         mov       ah,7
DispFil3:cmp       si,bp
         jae       DispFil7
         lodsb
         cmp       al,13
         je        DispFil3
         cmp       al,10
         je        DispFil7                 ; konec 찤dku
DispFil4:jcxz      DispFil3
         or        dx,dx
         jz        DispFil5
         dec       dx                       ; 눀ta� po뇿tku 찤dku
         jmp       short DispFil3
DispFil5:stosw
         dec       cx
         jmp       short DispFil3

; ------ vymaz쟮� zbytku 찤dku

DispFil7:mov       al,20h
         rep       stosw

; ------ pæprava pro dalÆ 찤dek

DispFil8:add       di,160-(Sirka-2)*2       ; adresa dalÆho 찤dku
         dec       bh                       ; 눀ta� 찤dk�
         jnz       DispFil2                 ; zobrazen� dalÆho 찤dku

; ------ n쟶rat registr�

         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispFile ENDP

; -----------------------------------------------------------------------------
;        zobrazen� 눀sla AX zarovnan괿o vlevo (po뇿tek adresy ES:DI, BH=barva)
; -----------------------------------------------------------------------------

DispLNum PROC      NEAR

; ------ 즧chova registr�

         push      ax
         push      cx
         push      dx
         push      si

; ------ dek줰ov쟮� 눀sla

         xor       cx,cx                    ; 눀ta� 눀slic
         mov       si,10                    ; d늢itel
DispLNm1:xor       dx,dx
         div       si                       ; 눀slo / 10
         add       dl,"0"                   ; korekce na 눀slici
         mov       dh,bh
         push      dx                       ; 즧chova 눀sla
         inc       cx                       ; zv삩en� 눀ta놽 눀slic
         or        ax,ax                    ; je ji� 눀slo 0 ?
         jnz       DispLNm1                 ; dek줰ov쟮� dalÆ 눀slice

; ------ ulo멷n� 눀sla

         cld
DispLNm2:pop       ax
         stosw
         loop      DispLNm2

; ------ n쟶rat registr�

         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

DispLNum ENDP

; -----------------------------------------------------------------------------
;        zobrazen� 눀sla AX zarovnan괿o vpravo (adresa konec ES:DI, BH=barva)
; -----------------------------------------------------------------------------

DispRNum PROC      NEAR

; ------ 즧chova registr�

         push      ax
         push      cx
         push      dx
         push      si

; ------ dek줰ov쟮� 눀sla

         mov       si,10                    ; d늢itel
DispRNm1:xor       dx,dx
         div       si                       ; 눀slo / 10
         add       dl,"0"                   ; korekce na 눀slici
         mov       dh,bh
         mov       es:[di],dx
         dec       di
         dec       di
         or        ax,ax                    ; je ji� 눀slo 0 ?
         jnz       DispRNm1                 ; dek줰ov쟮� dalÆ 눀slice

; ------ n쟶rat registr�

         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

DispRNum ENDP

; *****************************************************************************
;                    skok na obsluhu podle BX
; -----------------------------------------------------------------------------
; Procedura se vol� instrukc� CALL JumpBX, za kterou n쟳leduje tabulka
; skok�. Procedura zm늧� svou n쟶ratovou adresu na adresu podle nalezen�
; polo멾y v tabulce (nebo podle polo멾y pro nenalezenou hodnotu).
; -----------------------------------------------------------------------------
; VSTUP: v z쟳obn죏u slovo (n쟶ratov� adresa NEAR) = za뇿tek tabulky skok�
;             stuktura tabulky: 1 slovo testovan� hodnota BX
;                               1 slovo adresa NEAR obsluhy
;             konec tabulky: 1 slovo = 0 (pæznak konce tabulky)
;                            1 slovo adresa NEAR obsluhy p쯫 nenalezen� k줰u
; *****************************************************************************

JumpBX   PROC      NEAR

; ------ 즧chova registr�

                                            ; SS:[BP+6] = IP
         push      si                       ; SS:[BP+4] = SI
         push      bp                       ; SS:[BP+2] = BP
         push      ds                       ; SS:[BP+0] = DS
         mov       bp,sp

; ------ nalezen� hodnoty v tabulce

         push      cs
         pop       ds
         mov       si,ss:[bp+6]             ; offset adresy tabulky
JumpBX1: cmp       word ptr ds:[si],0       ; je konec tabulky ?
         je        JumpBX2                  ; konec tabulky - nenalezeno
         cmp       word ptr ds:[si],bx      ; je to hledan� hodnota ?
         je        JumpBX2                  ; hodnota nalezena
         add       si,4                     ; adresa dalÆ polo멾y
         jmp       short JumpBX1            ; test dalÆ polo멾y

; ------ nastaven� n쟶ratov� adresy podle tabulky

JumpBX2: mov       si,ds:[si+2]             ; adresa skoku
         mov       ss:[bp+6],si             ; nov� n쟶ratov� adresa

; ------ n쟶rat registr�

         pop       ds
         pop       bp
         pop       si
         ret

JumpBX   ENDP


BuffScr  db        Sirka*Vyska*2 dup(0)     ; buffer k 즧chov� obrazovky

Buffer   label     byte                     ; za뇿tek datov괿o bufferu

; *****************************************************************************
;
;                         Instalace programu
;
; *****************************************************************************

; ------ zobrazen� 즪odn죋o textu

Instal:  mov       dx,offset UvTxt
         call      DispTxt                  ; zobrazen� 즪odn죋o textu

; ------ test instalace programu

         mov       ax,Heslo0
         mov       bx,Heslo1
         int       16h                      ; test instalace programu
         cmp       bx,Heslo2
         je        Instal1
         push      cs
         pop       es
         or        byte ptr ds:[Param],4    ; pæznak prvn� instalace
Instal1: mov       ds:[RezSeg],es           ; segment rezidentn� instalace

; ------ dek줰ov쟮� pækazov괿o 찤dku

         mov       si,81h                   ; za뇿tek pækazov괿o 찤dku
         mov       bl,ds:[si-1]             ; d굃ka pækazov괿o 찤dku
         mov       bh,0
         mov       byte ptr ds:[si+bx],bh   ; ozna놽n� konce textu pækaz. 찤dku
         cld
Rozbor1: lodsb                              ; na뇍en� znaku
         cmp       al,9
         je        Rozbor1                  ; tabel쟴or se ignoruje
         cmp       al," "
         je        Rozbor1                  ; mezera se ignoruje
         jb        Instal3                  ; konec parametr�
         cmp       al,"/"
         je        Rozbor1                  ; odd늢ova� parametr� se ignoruje

; ------ po멲davek odinstalov쟮� programu

         cmp       al,"!"                   ; po멲davek odinstalov쟮� ?
         jne       Rozbor2
         or        byte ptr ds:[Param],1    ; pæznak po멲davku odinstalov쟮�
         jmp       short Rozbor1

; ------ zad쟮� velikosti bufferu

Rozbor2: call      RozbNm                   ; p쯥vod na 눀slici
         jc        RozbChyb                 ; nen� 눀slice
         or        byte ptr ds:[Param],2    ; pæznak zad쟮� velikosti bufferu
         mov       ah,0
         xchg      ax,bx                    ; BX <- st쯠da� 눀sla
Rozb23:  mov       al,ds:[si]               ; dalÆ 눀slo
         call      RozbNm                   ; test dalÆho znaku
         jc        Rozb26
         mov       ax,10
         mul       bx                       ; st쯠da� * 10
         xchg      ax,bx                    ; BX <- nov� st쯠da�
         lodsb                              ; znak 눀slice
         call      RozbNm
         mov       ah,0
         or        dx,dx                    ; p쯥te놽n� ?
         jnz       Rozb24                   ; p쯥te놽n�
         add       bx,ax                    ; p쯫뇍en� 눀sla ke st쯠da뇁
         jnc       Rozb25
Rozb24:  mov       bx,-1                    ; omezen� velikosti 눀sla
Rozb25:  jmp       short Rozb23             ; dalÆ 눀slice
Rozb26:  cmp       bx,20
         ja        Rozb27
         mov       bl,20
Rozb27:  cmp       bx,63000
         jb        Rozb28
         mov       bx,63000
Rozb28:  mov       ds:[BuffMax],bx          ; nov� velikost bufferu
         jmp       short Rozbor1

; ------ chyba zad쟮� parametr�

RozbChyb:mov       dx,offset HlpTxt         ; text n쟰ov늕y
Chyba:   call      DispTxt                  ; zobrazen� textu chyby
         mov       ax,4c01h
         int       21h

; ------ p쯥sun programu na ni뫅� 즦ove�

Instal3: mov       si,103h                  ; star� za뇿tek programu
         mov       di,5ch                   ; nov� za뇿tek programu
         push      cs
         pop       es
         mov       cx,offset(Buffer-Start)-3 ; d굃ka programu
         cld
         rep       movsb                    ; p쯥nos programu dol�

; ------ instalace programu - test, zda je ji� nainstalov쟮

Instal4: mov       al,ds:[Param+KORIG]      ; pæznaky
         test      al,1                     ; je odinstalov쟮� programu ?
         jnz       OdInst1                  ; po멲duje se odinstalov쟮�
         mov       dx,offset JeInsTxt       ; text - je ji� nainstalov쟮
         test      al,4                     ; je prvn� instalace ?
         jnz       Instal6                  ; je prvn� instalace OK
         test      al,2                     ; byla zad쟮a velikost bufferu ?
         jz        Instal5                  ; nebyla zad쟮a velikost bufferu
         call      DispTxt                  ; zobrazen� hl젴en�, 멷 ji� je inst.
         mov       dx,offset VelTxt         ; dopln늟 - nutno odinstalovat
Instal5: jmp       short Chyba              ; chybov� ukon놽n� programu

; ------ test, zda je dostatek pam늯i k instalaci programu

Instal6: mov       dx,offset MemTxt         ; text - nedostatek pam늯i
         mov       ax,ds:[BuffMax+KORIG]    ; velikost bufferu
         add       ax,offset Buffer + KORIG + 200h ; adresa konce bufferu
         cmp       ax,sp                    ; je dostatek pam늯i ?
         jae       Chyba                    ; chyba - nedostatek pam늯i

; ------ prvn� instalace programu

         mov       dx,offset InstTxt
         call      DispTxt                  ; text - byl nainstalov쟮
         mov       es,ds:[2ch]              ; segment prost쯥d�
         mov       ah,49h
         int       21h                      ; uvoln늧� segmentu prost쯥d�
         mov       ax,3516h
         int       21h                      ; poskytnut� adresy INT 16h
         mov       word ptr ds:[Old16+KORIG],bx ; offset INT 16h
         mov       word ptr ds:[Old16+KORIG+2],es ; segment INT 16h
         mov       dx,offset INT16 + KORIG  ; nov� obsluha INT 16h
         mov       ax,2516h
         int       21h                      ; instalace INT 16h
         mov       bx,-1
         mov       ah,34h
         int       21h                      ; poskytnut� pæznaku statutu DOS
         mov       word ptr ds:[StatDOS+KORIG],bx ; offset statutu DOS
         mov       word ptr ds:[StatDOS+KORIG+2],es ; segment statutu DOS
         mov       dx,ds:[BuffMax+KORIG]    ; velikost bufferu
         add       dx,offset Buffer + KORIG ; adresa konce bufferu
         int       27h                      ; instalace programu

; ------ odinstalov쟮� - test, zda je v pam늯i

OdInst1: mov       dx,offset NeInsTxt
         test      byte ptr ds:[Param+KORIG],4 ; je prvn� instalace ?
         jnz       Instal5                  ; chyba - nebyl dosud nainstalov쟮

; ------ test, zda lze odinstalovat

         mov       ax,3516h
         int       21h                      ; poskytnut� adresy INT 16h
         mov       dx,offset NelzeTxt       ; text - nelze odinstalovat
         mov       ax,es
         cmp       ax,ds:[RezSeg]           ; souhlas� adresa ?
         jne       Instal5                  ; chyba - nelze odinstalovat

; ------ odinstalov쟮� programu

         push      ds
         lds       dx,es:[Old16+KORIG]      ; p뻱odn� adresa INT 16h
         mov       ax,2516h
         int       21h                      ; n쟶rat p뻱odn� adresy INT 16h
         pop       ds
         mov       ah,49h
         int       21h                      ; uvoln늧� bloku programu
         mov       dx,offset OdInsTxt
         call      DispTxt                  ; hl젴en� - byl odinstalov쟮
         int       20h

; -----------------------------------------------------------------------------
;        p쯥vod 눀slice v AL na 눀slo (CY=nen� 눀slice)
; -----------------------------------------------------------------------------

RozbNm   PROC      NEAR

         cmp       al,"0"
         jb        RozbNm2
         cmp       al,"9"+1
         cmc
         jc        RozbNm2
         sub       al,"0"
RozbNm2: ret

RozbNm   ENDP

; -----------------------------------------------------------------------------
;        zobrazen� textu DX
; -----------------------------------------------------------------------------

DispTxt  PROC      NEAR

         push      ax
         mov       ah,9
         int       21h
         pop       ax
         ret

DispTxt  ENDP

; *****************************************************************************
;
;                                Data
;
; *****************************************************************************

RezSeg   dw        0                        ; rezidentn� segment

UvTxt    db        'NOTES V1.0 - poznamkovy blok; (c) Miroslav Nemecek',13,10,'$'
MemTxt   db        'Nedostatek pameti pro isntalaci programu !',13,10,'$'
InstTxt  db        'NOTES byl nainstalovan do pameti. Aktivace: Ctrl-Alt-N.',13,10,'$'

NeInsTxt db        'NOTES nebyl dosud nainstalovan do pameti !',13,10,'$'
NelzeTxt db        'NOTES nelze odinstalovat - je nutno odinstalovat nejdrive',13,10
         db        'rezidentni programy nainstalovane pozdeji !',13,10,'$'
JeInsTxt db        'NOTES je jiz nainstalovan v pameti !',13,10,'$'
VelTxt   db        'Chcete-li zmenit velikost bufferu, musite jej nejdrive odinstalovat !',13,10,'$'
OdInsTxt db        'NOTES byl odinstalovan z pameti.',13,10,'$'

HlpTxt   db        'Zadejte: ! ......... odinstalovani programu z pameti',13,10
         db        '         cislo ..... instalace se zadanou velikosti bufferu',13,10
         db        '                     (20 az 63000, implicitne 2000 bajtu)',13,10
         db        '$'


Code     ENDS
         END       Start

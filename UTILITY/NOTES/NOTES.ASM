
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                                 NOTES
;
;                        Rezidentn¡ pozn mkov˜ blok
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

KORIG    EQU       5ch - 103h               ; korekce pro posun programu
Heslo0   EQU       5a82h                    ; dotaz na instalaci - AX
Heslo1   EQU       9bc2h                    ; dotaz na instalaci - BX vstup
Heslo2   EQU       0c356h                   ; dotaz na instalaci - BX v˜stup
Sirka    EQU       42                       ; ¨¡©ka okna (pozic)
Vyska    EQU       7                        ; v˜¨ka okna (© dk–)

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

Start:   jmp       Instal

Old16    dd        0                        ; p–vodn¡ adresa INT 16h
StatDOS  dd        -1                       ; adresa statutu DOS (-1 = nen¡)
Pozice   db        (80-Sirka)/2             ; po‡ te‡n¡ pozice okna
Radek    db        1                        ; po‡ te‡n¡ © dek okna

TopPoz   dw        0                        ; po‡ te‡n¡ pozice
TopRad   dw        0                        ; po‡ te‡n¡ © dek
OffsTop  dw        0                        ; offset po‡ te‡n¡ho © dku
Poz      dw        0                        ; aktu ln¡ pozice kurzoru
Rad      dw        0                        ; aktu ln¡ © dek kurzoru
OffsAkt  dw        0                        ; offset aktivn¡ho © dku

Povel    db        0                        ; povel pro INT 16h
BuffMax  dw        2000                     ; maxim ln¡ velikost bufferu
BuffNum  dw        0                        ; po‡et bajt– v bufferu
BuffTop  dw        0                        ; offset po‡ tku str nky

AktPage  db        0                        ; aktivn¡ videostr nka
OldKurz  dw        0                        ; uschovan  pozice kurzoru
OldLink  dw        0                        ; uschovan˜ vzhled kurzoru
AdrVRAM  dd        0                        ; po‡ te‡n¡ adresa videopamˆti
PocVRAM  dw        0                        ; po‡ te‡n¡ adresa ve VRAM

Param    db        0                        ; parametry
                                            ;   bit 0: 1=po‘adavek odinstalov n¡
                                            ;   bit 1: 1=zad na velikost bufferu
                                            ;   bit 2: 1=prvn¡ instalace
                                            ;   bit 3: 1=prob¡h  obsluha notesu
                                            ;   bit 4: 1=po‘adov na obsluha
                                            ;   bit 5: 1=nen¡ INSERT (je p©epis)


Soubor   db        'NOTES.0',0
SoubNamN db        7                        ; d‚lka jm‚na souboru
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

; ------ test, zda je ji‘ obsluha notesu

Int163:  test      byte ptr cs:[Param+KORIG],8 ; prob¡h  obsluha notesu ?
         jnz       Int162                   ; prob¡h  obsluha notesu
         mov       cs:[Povel+KORIG],ah      ; £schova ‡¡sla povelu

; ------ test, zda se po‘aduje obsluha

         test      byte ptr cs:[Param+KORIG],10h ; po‘aduje se obsluha ?
         jnz       Int1680                  ; obsluha notesu

; ------ test p©ipravenosti znaku

Int164:  test      ah,1                     ; je test znaku ?
         jz        Int165                   ; nen¡ test znaku
         call      Exec16                   ; test znaku kl vesnice
         jz        Int167                   ; nen¡ p©ipraven znak z kl vesnice
         call      TestHot                  ; test hork‚ kl vesy
         jnz       Int167                   ; nen¡ hork  kl vesa
         mov       ah,cs:[Povel+KORIG]      ; povel
         and       ah,not 1                 ; povel pro vstup z kl vesnice
         call      Exec16                   ; zru¨en¡ znaku z bufferu kl vesnice
         jmp       short Int168             ; obsluha pozn mkov‚ho bloku

Int165:  call      Exec16                   ; vstup znaku z kl vesnice
Int166:  call      TestHot                  ; test hork‚ kl vesy
         jz        Int168                   ; je hork  kl vesa

Int167:  sti
         ret       2

; ------ test ‡¡sla videom¢du

Int168:  or        byte ptr cs:[Param+KORIG],10h ; p©¡znak po‘adavku obsluhy

Int1680: push      bx
         push      ds
         xor       bx,bx
         mov       ds,bx
         mov       bl,ds:[449h]             ; aktivn¡ videom¢d
         mov       byte ptr cs:[AdrVRAM+KORIG+3],0b0h ; segment videopamˆti MDA
         cmp       bl,7
         je        Int1681
         mov       byte ptr cs:[AdrVRAM+KORIG+3],0b8h ; segment videopamˆti CGA
         cmp       bl,2
         je        Int1681
         cmp       bl,3
Int1681: pop       ds
         pop       bx
         jne       Int169                   ; nen¡ povolen˜ videom¢d

; ------ test p©¡znaku aktivity DOS

         push      bx
         push      ds
         lds       bx,cs:[StatDOS+KORIG]    ; adresa statutu DOS
         cmp       bx,-1                    ; je adresa platn  ?
         je        Int1682                  ; adresa nen¡ platn 
         cmp       byte ptr ds:[bx],0       ; je mo‘n  obsluha DOS ?
Int1682: pop       ds
         pop       bx
         jne       Int169                   ; nen¡ mo‘n  obsluha

; ------ obsluha pozn mkov‚ho bloku

Int1690: and       byte ptr cs:[Param+KORIG],not 10h ; zru¨en¡ po‘adavku obsluhy
         or        byte ptr cs:[Param+KORIG],8 ; p©¡znak obsluhy notesu
         call      Notes                    ; obsluha pozn mkov‚ho bloku
         and       byte ptr cs:[Param+KORIG],not 8 ; zru¨en¡ p©¡znaku obsluhy
Int169:  mov       ah,cs:[Povel+KORIG]      ; p–vodn¡ povel
         jmp       Int164                   ; opakov n¡ funkce

Int16    ENDP

; -----------------------------------------------------------------------------
;        test, zda je hork  kl vesa (NZ=nen¡)
; -----------------------------------------------------------------------------

TestHot  PROC      NEAR

         cmp       ax,3100h
         jne       TestHot5                 ; nen¡ hork  kl vesa

         push      ds
         push      ax
         xor       ax,ax
         mov       ds,ax
         mov       al,ds:[417h]             ; p©esmyka‡e
         xor       al,4
         and       al,4                     ; je p©esmyka‡ Ctrl- ?
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
;        obsluha pozn mkov‚ho bloku
; -----------------------------------------------------------------------------

Notes    PROC      NEAR

; ------ £schova registr–

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

; ------ stanoven¡ parametr– videom¢du

         xor       ax,ax
         mov       ds,ax
         mov       ax,ds:[44eh]             ; po‡ te‡n¡ adresa videopamˆti
         push      cs
         pop       ds
         mov       word ptr ds:[AdrVRAM+KORIG],ax ; adresa videopamˆti
         mov       es,word ptr ds:[AdrVRAM+2+KORIG]

; ------ £schova obsahu displeje

         call      PushScr                  ; £schova obsahu displeje


; ------ otev©en¡ a na‡ten¡ souboru

         call      ReadFile                 ; otev©en¡ a na‡ten¡ souboru

         call      DispRam                  ; zobrazen¡ r mu okna


Not23:   call      DispInf                  ;
         call      DispFile
         call      DispKurz

; ------ vstup znaku z kl vesnice

Not24:   mov       ah,ds:[Povel+KORIG]
         and       ah,not 1                 ; povel pro vstup znaku
         call      Exec16                   ; vstup znaku z kl vesnice
         or        ah,ah
         jz        Not232
         cmp       al,0e0h
         je        Not231
         cmp       al,0f0h
         jne       Not232
Not231:  mov       al,0

Not232:  mov       bx,ax                    ; kl vesa
         mov       cx,ds:[Poz+KORIG]        ; aktu ln¡ pozice kurzoru
         mov       dx,ds:[Rad+KORIG]        ; aktu ln¡ © dek kurzoru
         mov       si,ds:[OffsAkt+KORIG]    ; offset aktivn¡ho © dku
         call      JumpBX                   ; skok na obsluhu

         dw        4d00h,NotRght+KORIG      ; vpravo
         dw        4b00h,NotLeft+KORIG      ; vlevo
;         dw        5000h,NotDwn+KORIG       ; dol–
;         dw        4800h,NotUp+KORIG        ; nahoru

         dw        5200h,NotIns+KORIG       ; INSERT
         dw        11bh,NotEsc+KORIG        ; ESC
         dw        0,Not24+KORIG
;þ
; ------ INSERT - p©¡znak p©episov n¡

NotIns:  xor       byte ptr ds:[Param+KORIG],20h ; zmˆna INSERT
Not23x1: jmp       short Not23

; ------ posun kurzoru o pozici vpravo

NotRght: inc       cx                       ; zv˜¨en¡ pozice kurzoru
         jnz       NotRght2
Not24x1: jmp       short Not24
NotRght2:mov       ds:[Poz+KORIG],cx        ; nov  pozice kurzoru
         mov       ds:[Rad+KORIG],dx        ; nov˜ © dek kurzoru
         call      NormKurz                 ; normalizace kurzoru
         jmp       short Not23x1            ; nov‚ zobrazen¡

; ------ posun kurzoru o pozici vlevo

NotLeft: jcxz      Not24x1                  ; je ji‘ po‡ tek © dku
         dec       cx                       ; sn¡‘en¡ pozice kurzoru
         jmp       short NotRght2

; ------ posun kurzoru o © dek dol–

;NotDwn:  inc       dx
;         call      NextRow                  ; dal¨¡ © dek
;         jc        Not24x1                  ; nen¡ dal¨¡ © dek
;         jmp       short NotRght2

; ------ posun kurzoru o © dek nahoru

;NotUp:   dec



; ------ n vrat obsahu displeje

NotEsc:  call      PopScr                   ; n vrat obsahu displeje

; ------ n vrat registr–

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

; ------ £schova registr–

         push      ax
         push      cx
         push      dx
         push      si

; ------ normalizace pozice kurzoru

         mov       ax,ds:[Poz+KORIG]        ; pozice kurzoru
         mov       bx,ds:[TopPoz+KORIG]     ; po‡ te‡n¡ pozice okna
         cmp       ax,bx                    ; je p©ed oknem ?
         ja        NormKur2                 ; nen¡ p©ed oknem
         mov       bx,ax                    ; omezen¡ po‡ tku okna
NormKur2:sub       ax,Sirka-3               ; maxim ln¡ pozice okna
         jnc       NormKur3
         xor       ax,ax
NormKur3:cmp       ax,bx                    ; p©ekro‡en max. po‡ tek ?
         jbe       NormKur4                 ; po‡ tek je OK
         mov       bx,ax                    ; omezen¡ po‡ tku
NormKur4:mov       ds:[TopPoz+KORIG],bx     ; nov  pozice po‡ tku okna



; ------ n vrat registr–

         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

NormKurz ENDP

; -----------------------------------------------------------------------------
;        £schova obsahu obrazovky
; -----------------------------------------------------------------------------

PushScr  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      si
         push      di
         push      ds
         push      es

; ------ £schova ‡¡sla aktivn¡ videostr nky

         mov       ah,0fh
         call      Exec10                   ; poskytnut¡ aktivn¡ str nky
         mov       cs:[AktPage+KORIG],bh    ; aktivn¡ videostr nka

; ------ £schova pozice kurzoru

         mov       ah,3
         call      Exec10                   ; poskytnut¡ pozice kurzoru
         mov       cs:[OldKurz+KORIG],dx    ; £schova pozice kurzoru
         mov       cs:[OldLink+KORIG],cx    ; £schova linek kurzoru

; ------ v˜po‡et po‡ te‡n¡ adresy v˜©ezu

         lds       si,cs:[AdrVRAM+KORIG]    ; adresa videopamˆti
         mov       al,160                   ; po‡et bajt– na © dek
         mul       byte ptr cs:[Radek+KORIG] ; p©epo‡et ‡¡sla © dku na offset
         mov       cl,cs:[Pozice+KORIG]     ; po‡ te‡n¡ pozice
         mov       ch,0
         shl       cx,1                     ; offset na © dku
         add       ax,cx                    ; offset ve videostr nce
         add       si,ax                    ; po‡ te‡n¡ adresa v˜©ezu
         mov       cs:[PocVRAM+KORIG],si    ; £schova adresy ve videopamˆti

; ------ £schova obsahu v˜©ezu

         mov       di,offset BuffScr+KORIG  ; buffer obrazovky
         push      cs
         pop       es
         cld
         mov       ax,Vyska                 ; v˜¨ka v˜©ezu (© dk–)
PushScr1:mov       cx,Sirka                 ; ¨¡©ka v˜©ezu (pozic)
         rep       movsw                    ; £schova jednoho © dku
         add       si,160-2*Sirka           ; adresa dal¨¡ho © dku
         dec       ax                       ; ‡¡ta‡ © dk–
         jnz       PushScr1                 ; £schova dal¨¡ho © dku

; ------ n vrat registr–

         pop       es
         pop       ds
         pop       di
         pop       si
         pop       cx
         pop       ax
         ret

PushScr  ENDP

; -----------------------------------------------------------------------------
;        n vrat obsahu obrazovky
; -----------------------------------------------------------------------------

PopScr   PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      si
         push      di
         push      ds
         push      es

; ------ n vrat obsahu v˜©ezu

         push      cs
         pop       ds
         mov       si,offset BuffScr+KORIG  ; buffer obrazovky
         mov       es,word ptr ds:[AdrVRAM+2+KORIG] ; segment videopamˆti
         mov       di,ds:[PocVRAM+KORIG]    ; po‡ te‡n¡ adresa ve videopamˆti
         cld
         mov       ax,Vyska                 ; v˜¨ka v˜©ezu (© dk–)
PopScr1: mov       cx,Sirka                 ; ¨¡©ka v˜©ezu (pozic)
         rep       movsw                    ; £schova jednoho © dku
         add       di,160-2*Sirka           ; adresa dal¨¡ho © dku
         dec       ax                       ; ‡¡ta‡ © dk–
         jnz       PopScr1                  ; £schova dal¨¡ho © dku

; ------ n vrat vzhledu a pozice kurzoru

         mov       ah,1
         mov       cx,ds:[OldLink+KORIG]    ; p–vodn¡ vzhled kurzoru
         call      Exec10                   ; n vrat vzhledu kurzoru
         mov       bh,ds:[AktPage+KORIG]    ; aktivn¡ vodeostr nka
         mov       ah,2
         mov       dx,ds:[OldKurz+KORIG]    ; p–vodn¡ pozice kurzoru
         call      Exec10                   ; n vrat pozice kurzoru

; ------ n vrat registr–

         pop       es
         pop       ds
         pop       di
         pop       si
         pop       cx
         pop       ax
         ret

PopScr   ENDP

; -----------------------------------------------------------------------------
;        otev©en¡ a na‡ten¡ souboru do bufferu
; -----------------------------------------------------------------------------

ReadFile PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx

; ------ otev©en¡ souboru

         mov       word ptr ds:[BuffNum+KORIG],0 ; po‡et bajt– v bufferu
         mov       dx,offset Soubor+KORIG
         mov       ax,3d02h
         int       21h
         jc        ReadFil9                 ; soubor nelze otev©¡t
         mov       bx,ax

; ------ na‡ten¡ souboru

         mov       dx,offset Buffer+KORIG
         mov       ah,3fh
         mov       cx,ds:[BuffMax+KORIG]
         int       21h                      ; na‡ten¡ souboru
         jnc       ReadFil3
         xor       ax,ax
ReadFil3:cmp       ax,cx
         jbe       ReadFil4
         mov       ax,cx
ReadFil4:mov       ds:[BuffNum+KORIG],ax    ; po‡et na‡ten˜ch bajt–

; ------ uzav©en¡ souboru

         mov       ah,3eh
         int       21h

; ------ n vrat registr–

ReadFil9:pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

ReadFile ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ r mu okna
; -----------------------------------------------------------------------------

DispRam  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      di
         push      es

; ------ p©¡prava registr–

         mov       es,word ptr ds:[AdrVRAM+2+KORIG]
         mov       di,ds:[PocVRAM+KORIG]
         add       di,160                   ; po‡ te‡n¡ adresa ve videopamˆti

; ------ zobrazen¡ lev‚ho a prav‚ho okraje

         mov       cx,Vyska-2               ; po‡et © dk– k zobrazen¡
         mov       ax,0fh * 256 + 186
DispRam2:stosw
         mov       es:[di+Sirka*2-4],ax
         add       di,160-2
         loop      DispRam2

; ------ zobrazen¡ spodn¡ho okraje

         mov       al,200
         stosw
         mov       al,205
         mov       cl,Sirka-2
         rep       stosw
         mov       al,188
         stosw

; ------ n vrat registr–

         pop       es
         pop       di
         pop       cx
         pop       ax
         ret

DispRam  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ informa‡n¡ho © dku
; -----------------------------------------------------------------------------

DispInf  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ p©¡prava registr–

         mov       es,word ptr ds:[AdrVRAM+2+KORIG]
         mov       di,ds:[PocVRAM+KORIG]
         cld

; ------ vymaz n¡ horn¡ho © dku

         push      di
         mov       ax,0fh*256 + 201
         stosw
         mov       ax,7020h
         mov       cx,Sirka-2
         rep       stosw
         mov       ax,0fh*256 + 187
         stosw
         pop       di

; ------ zobrazen¡ pozice a © dku kurzoru

         push      di
         add       di,2*2                   ; pozice k zobrazen¡ ‡¡sla
         mov       ax,ds:[Poz+KORIG]        ; pozice kurzoru
         mov       bh,70h                   ; barva textu
         call      DispLNum                 ; zobrazen¡ ‡¡sla pozice kurzoru
         mov       ax,70h*256 + "/"
         stosw                              ; zobrazen¡ oddˆlova‡e
         mov       ax,ds:[Rad+KORIG]        ; © dek kurzoru
         call      DispLNum                 ; zobrazen¡ ‡¡sla © dku kurzoru
         pop       di

; ------ zobrazen¡ jm‚na souboru

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

; ------ zobrazen¡ voln‚ kapacity

         add       di,(Sirka-3)*2           ; adresa konce © dku
         mov       ax,ds:[BuffMax+KORIG]    ; velikost bufferu
         sub       ax,ds:[BuffNum+KORIG]    ; zbyl  kapacita bufferu
         call      DispRNum                 ; zobrazen¡ voln‚ kapacity

; ------ n vrat registr–

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
;        zobrazen¡ kurzoru
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
         call      Exec10                   ; nastaven¡ aktu ln¡ pozice kurzoru

         mov       cx,607h
         cmp       byte ptr ds:[AdrVRAM+3+KORIG],0b8h
         je        DispKur3
         mov       cx,0b0ch
DispKur3:test      byte ptr ds:[Param+KORIG],20h ; je INSERT ?
         jz        DispKur4                 ; je INSERT
         mov       ch,0                     ; p©epis - velk˜ kurzor
DispKur4:mov       ah,1
         call      Exec10

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispKurz ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ souboru
; -----------------------------------------------------------------------------

DispFile PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es

; ------ p©¡prava registr–

         mov       es,word ptr ds:[AdrVRAM+2+KORIG]
         mov       di,ds:[PocVRAM+KORIG]
         add       di,160+2                 ; adresa ve videopamˆti
         mov       si,ds:[OffsTop+KORIG]    ; offset po‡ tku str nky
         add       si,offset Buffer+KORIG   ; adresa textu
         mov       bp,ds:[BuffNum+KORIG]
         add       bp,offset Buffer+KORIG   ; adresa konce textu
         mov       bh,Vyska-2               ; po‡et © dk– k zobrazen¡
         cld

; ------ zobrazen¡ jednoho © dku

DispFil2:mov       cx,Sirka-2               ; ¨¡©ka © dku (pozic)
         mov       dx,ds:[TopPoz+KORIG]     ; pozice po‡ tku © dku
         mov       ah,7
DispFil3:cmp       si,bp
         jae       DispFil7
         lodsb
         cmp       al,13
         je        DispFil3
         cmp       al,10
         je        DispFil7                 ; konec © dku
DispFil4:jcxz      DispFil3
         or        dx,dx
         jz        DispFil5
         dec       dx                       ; ‡¡ta‡ po‡ tku © dku
         jmp       short DispFil3
DispFil5:stosw
         dec       cx
         jmp       short DispFil3

; ------ vymaz n¡ zbytku © dku

DispFil7:mov       al,20h
         rep       stosw

; ------ p©¡prava pro dal¨¡ © dek

DispFil8:add       di,160-(Sirka-2)*2       ; adresa dal¨¡ho © dku
         dec       bh                       ; ‡¡ta‡ © dk–
         jnz       DispFil2                 ; zobrazen¡ dal¨¡ho © dku

; ------ n vrat registr–

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
;        zobrazen¡ ‡¡sla AX zarovnan‚ho vlevo (po‡ tek adresy ES:DI, BH=barva)
; -----------------------------------------------------------------------------

DispLNum PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      dx
         push      si

; ------ dek¢dov n¡ ‡¡sla

         xor       cx,cx                    ; ‡¡ta‡ ‡¡slic
         mov       si,10                    ; dˆlitel
DispLNm1:xor       dx,dx
         div       si                       ; ‡¡slo / 10
         add       dl,"0"                   ; korekce na ‡¡slici
         mov       dh,bh
         push      dx                       ; £schova ‡¡sla
         inc       cx                       ; zv˜¨en¡ ‡¡ta‡e ‡¡slic
         or        ax,ax                    ; je ji‘ ‡¡slo 0 ?
         jnz       DispLNm1                 ; dek¢dov n¡ dal¨¡ ‡¡slice

; ------ ulo‘en¡ ‡¡sla

         cld
DispLNm2:pop       ax
         stosw
         loop      DispLNm2

; ------ n vrat registr–

         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

DispLNum ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ ‡¡sla AX zarovnan‚ho vpravo (adresa konec ES:DI, BH=barva)
; -----------------------------------------------------------------------------

DispRNum PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      dx
         push      si

; ------ dek¢dov n¡ ‡¡sla

         mov       si,10                    ; dˆlitel
DispRNm1:xor       dx,dx
         div       si                       ; ‡¡slo / 10
         add       dl,"0"                   ; korekce na ‡¡slici
         mov       dh,bh
         mov       es:[di],dx
         dec       di
         dec       di
         or        ax,ax                    ; je ji‘ ‡¡slo 0 ?
         jnz       DispRNm1                 ; dek¢dov n¡ dal¨¡ ‡¡slice

; ------ n vrat registr–

         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

DispRNum ENDP

; *****************************************************************************
;                    skok na obsluhu podle BX
; -----------------------------------------------------------------------------
; Procedura se vol  instrukc¡ CALL JumpBX, za kterou n sleduje tabulka
; skok–. Procedura zmˆn¡ svou n vratovou adresu na adresu podle nalezen‚
; polo‘ky v tabulce (nebo podle polo‘ky pro nenalezenou hodnotu).
; -----------------------------------------------------------------------------
; VSTUP: v z sobn¡ku slovo (n vratov  adresa NEAR) = za‡ tek tabulky skok–
;             stuktura tabulky: 1 slovo testovan  hodnota BX
;                               1 slovo adresa NEAR obsluhy
;             konec tabulky: 1 slovo = 0 (p©¡znak konce tabulky)
;                            1 slovo adresa NEAR obsluhy p©i nenalezen¡ k¢du
; *****************************************************************************

JumpBX   PROC      NEAR

; ------ £schova registr–

                                            ; SS:[BP+6] = IP
         push      si                       ; SS:[BP+4] = SI
         push      bp                       ; SS:[BP+2] = BP
         push      ds                       ; SS:[BP+0] = DS
         mov       bp,sp

; ------ nalezen¡ hodnoty v tabulce

         push      cs
         pop       ds
         mov       si,ss:[bp+6]             ; offset adresy tabulky
JumpBX1: cmp       word ptr ds:[si],0       ; je konec tabulky ?
         je        JumpBX2                  ; konec tabulky - nenalezeno
         cmp       word ptr ds:[si],bx      ; je to hledan  hodnota ?
         je        JumpBX2                  ; hodnota nalezena
         add       si,4                     ; adresa dal¨¡ polo‘ky
         jmp       short JumpBX1            ; test dal¨¡ polo‘ky

; ------ nastaven¡ n vratov‚ adresy podle tabulky

JumpBX2: mov       si,ds:[si+2]             ; adresa skoku
         mov       ss:[bp+6],si             ; nov  n vratov  adresa

; ------ n vrat registr–

         pop       ds
         pop       bp
         pop       si
         ret

JumpBX   ENDP


BuffScr  db        Sirka*Vyska*2 dup(0)     ; buffer k £schovˆ obrazovky

Buffer   label     byte                     ; za‡ tek datov‚ho bufferu

; *****************************************************************************
;
;                         Instalace programu
;
; *****************************************************************************

; ------ zobrazen¡ £vodn¡ho textu

Instal:  mov       dx,offset UvTxt
         call      DispTxt                  ; zobrazen¡ £vodn¡ho textu

; ------ test instalace programu

         mov       ax,Heslo0
         mov       bx,Heslo1
         int       16h                      ; test instalace programu
         cmp       bx,Heslo2
         je        Instal1
         push      cs
         pop       es
         or        byte ptr ds:[Param],4    ; p©¡znak prvn¡ instalace
Instal1: mov       ds:[RezSeg],es           ; segment rezidentn¡ instalace

; ------ dek¢dov n¡ p©¡kazov‚ho © dku

         mov       si,81h                   ; za‡ tek p©¡kazov‚ho © dku
         mov       bl,ds:[si-1]             ; d‚lka p©¡kazov‚ho © dku
         mov       bh,0
         mov       byte ptr ds:[si+bx],bh   ; ozna‡en¡ konce textu p©¡kaz. © dku
         cld
Rozbor1: lodsb                              ; na‡ten¡ znaku
         cmp       al,9
         je        Rozbor1                  ; tabel tor se ignoruje
         cmp       al," "
         je        Rozbor1                  ; mezera se ignoruje
         jb        Instal3                  ; konec parametr–
         cmp       al,"/"
         je        Rozbor1                  ; oddˆlova‡ parametr– se ignoruje

; ------ po‘adavek odinstalov n¡ programu

         cmp       al,"!"                   ; po‘adavek odinstalov n¡ ?
         jne       Rozbor2
         or        byte ptr ds:[Param],1    ; p©¡znak po‘adavku odinstalov n¡
         jmp       short Rozbor1

; ------ zad n¡ velikosti bufferu

Rozbor2: call      RozbNm                   ; p©evod na ‡¡slici
         jc        RozbChyb                 ; nen¡ ‡¡slice
         or        byte ptr ds:[Param],2    ; p©¡znak zad n¡ velikosti bufferu
         mov       ah,0
         xchg      ax,bx                    ; BX <- st©ada‡ ‡¡sla
Rozb23:  mov       al,ds:[si]               ; dal¨¡ ‡¡slo
         call      RozbNm                   ; test dal¨¡ho znaku
         jc        Rozb26
         mov       ax,10
         mul       bx                       ; st©ada‡ * 10
         xchg      ax,bx                    ; BX <- nov˜ st©ada‡
         lodsb                              ; znak ‡¡slice
         call      RozbNm
         mov       ah,0
         or        dx,dx                    ; p©ete‡en¡ ?
         jnz       Rozb24                   ; p©ete‡en¡
         add       bx,ax                    ; p©i‡ten¡ ‡¡sla ke st©ada‡i
         jnc       Rozb25
Rozb24:  mov       bx,-1                    ; omezen¡ velikosti ‡¡sla
Rozb25:  jmp       short Rozb23             ; dal¨¡ ‡¡slice
Rozb26:  cmp       bx,20
         ja        Rozb27
         mov       bl,20
Rozb27:  cmp       bx,63000
         jb        Rozb28
         mov       bx,63000
Rozb28:  mov       ds:[BuffMax],bx          ; nov  velikost bufferu
         jmp       short Rozbor1

; ------ chyba zad n¡ parametr–

RozbChyb:mov       dx,offset HlpTxt         ; text n povˆdy
Chyba:   call      DispTxt                  ; zobrazen¡ textu chyby
         mov       ax,4c01h
         int       21h

; ------ p©esun programu na ni‘¨¡ £rove¤

Instal3: mov       si,103h                  ; star˜ za‡ tek programu
         mov       di,5ch                   ; nov˜ za‡ tek programu
         push      cs
         pop       es
         mov       cx,offset(Buffer-Start)-3 ; d‚lka programu
         cld
         rep       movsb                    ; p©enos programu dol–

; ------ instalace programu - test, zda je ji‘ nainstalov n

Instal4: mov       al,ds:[Param+KORIG]      ; p©¡znaky
         test      al,1                     ; je odinstalov n¡ programu ?
         jnz       OdInst1                  ; po‘aduje se odinstalov n¡
         mov       dx,offset JeInsTxt       ; text - je ji‘ nainstalov n
         test      al,4                     ; je prvn¡ instalace ?
         jnz       Instal6                  ; je prvn¡ instalace OK
         test      al,2                     ; byla zad na velikost bufferu ?
         jz        Instal5                  ; nebyla zad na velikost bufferu
         call      DispTxt                  ; zobrazen¡ hl ¨en¡, ‘e ji‘ je inst.
         mov       dx,offset VelTxt         ; doplnˆk - nutno odinstalovat
Instal5: jmp       short Chyba              ; chybov‚ ukon‡en¡ programu

; ------ test, zda je dostatek pamˆti k instalaci programu

Instal6: mov       dx,offset MemTxt         ; text - nedostatek pamˆti
         mov       ax,ds:[BuffMax+KORIG]    ; velikost bufferu
         add       ax,offset Buffer + KORIG + 200h ; adresa konce bufferu
         cmp       ax,sp                    ; je dostatek pamˆti ?
         jae       Chyba                    ; chyba - nedostatek pamˆti

; ------ prvn¡ instalace programu

         mov       dx,offset InstTxt
         call      DispTxt                  ; text - byl nainstalov n
         mov       es,ds:[2ch]              ; segment prost©ed¡
         mov       ah,49h
         int       21h                      ; uvolnˆn¡ segmentu prost©ed¡
         mov       ax,3516h
         int       21h                      ; poskytnut¡ adresy INT 16h
         mov       word ptr ds:[Old16+KORIG],bx ; offset INT 16h
         mov       word ptr ds:[Old16+KORIG+2],es ; segment INT 16h
         mov       dx,offset INT16 + KORIG  ; nov  obsluha INT 16h
         mov       ax,2516h
         int       21h                      ; instalace INT 16h
         mov       bx,-1
         mov       ah,34h
         int       21h                      ; poskytnut¡ p©¡znaku statutu DOS
         mov       word ptr ds:[StatDOS+KORIG],bx ; offset statutu DOS
         mov       word ptr ds:[StatDOS+KORIG+2],es ; segment statutu DOS
         mov       dx,ds:[BuffMax+KORIG]    ; velikost bufferu
         add       dx,offset Buffer + KORIG ; adresa konce bufferu
         int       27h                      ; instalace programu

; ------ odinstalov n¡ - test, zda je v pamˆti

OdInst1: mov       dx,offset NeInsTxt
         test      byte ptr ds:[Param+KORIG],4 ; je prvn¡ instalace ?
         jnz       Instal5                  ; chyba - nebyl dosud nainstalov n

; ------ test, zda lze odinstalovat

         mov       ax,3516h
         int       21h                      ; poskytnut¡ adresy INT 16h
         mov       dx,offset NelzeTxt       ; text - nelze odinstalovat
         mov       ax,es
         cmp       ax,ds:[RezSeg]           ; souhlas¡ adresa ?
         jne       Instal5                  ; chyba - nelze odinstalovat

; ------ odinstalov n¡ programu

         push      ds
         lds       dx,es:[Old16+KORIG]      ; p–vodn¡ adresa INT 16h
         mov       ax,2516h
         int       21h                      ; n vrat p–vodn¡ adresy INT 16h
         pop       ds
         mov       ah,49h
         int       21h                      ; uvolnˆn¡ bloku programu
         mov       dx,offset OdInsTxt
         call      DispTxt                  ; hl ¨en¡ - byl odinstalov n
         int       20h

; -----------------------------------------------------------------------------
;        p©evod ‡¡slice v AL na ‡¡slo (CY=nen¡ ‡¡slice)
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
;        zobrazen¡ textu DX
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

RezSeg   dw        0                        ; rezidentn¡ segment

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

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                                     ¨achy
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; ------ inicializace videom¢du

Start:   mov       ah,0fh
         call      Int10P                   ; poskytnut¡ videom¢du
         cmp       al,7
         je        Start1
         mov       byte ptr ds:[SegmVRAM+1],0b8h ; segment videopamˆti
         cmp       al,2
         je        Start1
         mov       al,3
Start1:  mov       ah,0
         call      Int10P                   ; inicializace videom¢du

; ------ kontrola grafick‚ karty VGA

         mov       ax,1a00h
         int       10h                      ; dotaz na po‡et linek na znak
         cmp       al,1ah                   ; je funkce obsluhovan  ?
         jne       Start103                 ; funkce nen¡ obsluhovan 
         cmp       bl,7                     ; je 7 linek na znak ?
         je        Start100                 ; je karta OK
         cmp       bl,8
         je        Start100                 ; je karta OK
         cmp       bl,11
         jb        Start103                 ; nen¡ karta
         cmp       bl,12
         ja        Start103                 ; nen¡ karta

; ====== oprava zobrazen¡ VGA na 8 bod– na linku

Start100:cli

; ------ p©¡prava registru hodin

         mov       dx,3cch
         in        al,dx
         xor       al,4
         test      al,8+4
         jnz       Start102
         mov       bl,al

; ------ p©¡prava registru po‡tu bod–

         mov       dl,0c4h
         mov       al,1
         out       dx,al
         jmp       short $+2
         inc       dx
         in        al,dx
         test      al,21h
         jnz       Start102
         xor       al,1
         mov       bh,al

; ------ kontrola registru posunu PANNING

         call      Pan
         out       dx,al
         jmp       short $+2
         inc       dx
         in        al,dx
         cmp       al,8
         jne       Start101

; ------ nastaven¡ registru posunu PANNING

         dec       dx
         mov       al,0
         out       dx,al

; ------ nastaven¡ registru po‡tu bod–

         mov       al,bh
         mov       dl,0c5h
         out       dx,al

; ------ nastaven¡ registru hodin

         mov       al,bl
         mov       dl,0c2h
         out       dx,al

; ------ zapnut¡ displeje

Start101:call      Pan
         mov       al,20h
         out       dx,al
Start102:sti

; ------ instalace obsluhy p©eru¨en¡

Start103:mov       ax,2523h
         mov       dx,offset INT23
         int       21h                      ; instalace INT 23h

; ------ zobrazen¡ £vodn¡ho textu

         mov       ds:[Zasobnik],sp         ; £schova ukazatele z sobn¡ku
Zadej:   mov       sp,ds:[Zasobnik]         ; n vrat ukazatele z sobn¡ku
         call      Clear                    ; vymaz n¡ displeje
         mov       si,offset Text1
         mov       dx,6*256 + 32
         call      DispB
         mov       dx,9*256 + 35
         call      DispB
         mov       dx,11*256 + 30
         call      DispB
         mov       dx,13*256 + 34
         call      DispB

; ------ p©¡prava barvy hr ‡e

Zadej1:  mov       sp,ds:[Zasobnik]         ; n vrat ukazatele z sobn¡ku
         mov       al,"A"                   ; automat
         cmp       byte ptr ds:[Automat],0  ; je automat ?
         jne       Zadej2                   ; je automat
         mov       al,"B"                   ; b¡l 
         cmp       byte ptr ds:[Hrac],0     ; m  hr ‡ b¡l‚ ?
         jne       Zadej2                   ; hr ‡ m  b¡le
         mov       al,"C"                   ; ‡ern 
Zadej2:  mov       ds:[ColTxt0],al          ; barva hr ‡e
         mov       ds:[ColTxt1],al          ; barva hr ‡e

; ------ v˜zva k zad n¡ barvy hr ‡e

         mov       si,offset ColTxt         ; text v˜zvy k zad n¡ barvy
         mov       dx,16*256 + 11
         call      DispB
         dec       dx

; ------ vstup znaku z kl vesnice

Zadej3:  call      SetKurz
         call      InpChr                   ; vstup znaku z kl vesnice

         call      JumpBX                   ; obsluha podle kl vesy

         dw        "B",ZadejB               ; b¡l 
         dw        "C",ZadejC               ; ‡ern 
         dw        "A",ZadejA               ; automat
         dw        13,ZadejM                ; ENTER
         dw        27,Konec                 ; ESC

         dw        0,Zadej3

; ------ konec programu ESC

Konec:   ;call      Clear                    ; vymaz n¡ displeje
         mov       ah,0fh
         int       10h
         mov       ah,0
         int       10h
         int       20h                      ; konec programu

; ------ volba automatu

ZadejA:  mov       byte ptr ds:[Automat],1  ; p©¡znak automatu
         mov       al,0                     ; hr ‡ m  ‡ern‚
         jmp       short ZadejC3

; ------ volba b¡l‚ barvy

ZadejB:  mov       al,80h                   ; barva hr ‡e b¡l 
         jmp       short ZadejC2

; ------ volba ‡ern‚ barvy

ZadejC:  mov       al,0                     ; barva hr ‡e ‡ern 
ZadejC2: mov       byte ptr ds:[Automat],0  ; zru¨en¡ p©¡znaku automatu
ZadejC3: mov       ds:[Hrac],al             ; barva hr ‡e

; ------ potvrzen¡ star‚ volby ENTER (DX=star  pozice kurzoru !!!)

ZadejM0: mov       ds:[ColTxt1],bl          ; zadan˜ znak
ZadejM:  mov       si,offset ColTxt1
         call      DispB                    ; zobrazen¡ text

; ------ p©¡prava k volbˆ obt¡‘nosti

         mov       al,ds:[Uroven]           ; £rove¤ obt¡‘nosti
         add       al,"0"
         mov       ds:[UrovTxt0],al

; ------ zobrazen¡ v˜zvy k zad n¡ £rovnˆ obt¡‘nosti

         mov       si,offset UrovTxt        ; text v˜zvy k zad n¡ £rovnˆ
         mov       dx,18*256+10
         call      DispB
         dec       dx

; ------ vstup znaku z kl vesnice

ZadejU1: call      SetKurz                  ; nastaven¡ pozice kurzoru
         call      InpChr                   ; vstup znaku z kl vesnice
         cmp       bl,13                    ; potvrzen¡ ENTER ?
         je        ZadejU5                  ; potvrzen¡ volby ENTER
         cmp       bl,27                    ; n vrat k p©ede¨l‚ volbˆ ?
         jne       ZadejU2                  ; nen¡ ESC n vrat
         jmp       Zadej                    ; n vrat k volbˆ barvy
ZadejU2: sub       bl,"0"
         jbe       ZadejU1                  ; neplatn˜ znak
         cmp       bl,6
         ja        ZadejU1                  ; neplatn˜ znak
         mov       ds:[Uroven],bl           ; zvolen  £rove¤

; ------ inicializace ¨achovnice

ZadejU5: call      Clear                    ; vymaz n¡ obrazovky
         call      InitPole                 ; inicializace ¨achovnice
         call      Disp                     ; zobrazen¡ ¨achovnice
         mov       word ptr ds:[CitTah],1   ; ‡¡ta‡ tah–
         mov       byte ptr ds:[Radek],1    ; aktivn¡ © dek v˜stupu na displej
         call      KurzOff                  ; vypnut¡ kurzoru

; ------ rozli¨en¡ typu hry

Hrej:    call      DispTah                  ; zobrazen¡ ‡¡sla tahu
         test      byte ptr ds:[Hrac],80h   ; m  hr ‡ b¡l‚ ?
         jnz       Hrej1                    ; hr ‡ m  b¡l‚  - za‡¡n 

                                          ;* po‡¡ta‡ m  b¡l‚ - za‡¡n 
         call      TahPoc                   ; tah po‡¡ta‡e
         call      TahHrac                  ; volba tahu hr ‡e
         jmp       short Hrej2
                                          ;* hr ‡ m  b¡l‚ - za‡¡n 
Hrej1:   call      TahHrac                  ; volba tahu hr ‡e
         call      TahPoc                   ; tah po‡¡ta‡e

                                          ;* zv˜¨en¡ ‡¡ta‡e tah–
Hrej2:   inc       word ptr ds:[CitTah]     ; zv˜¨en¡ ‡¡ta‡e tah–
         jmp       short Hrej               ; dal¨¡ tah

; -----------------------------------------------------------------------------
;        obsluha registru PANNING
; -----------------------------------------------------------------------------

Pan:     mov       dl,0dah
         in        al,dx
         mov       dl,0bah
         in        al,dx
         mov       dl,0c0h
         mov       al,13h
         ret

; -----------------------------------------------------------------------------
;        obsluha INT 23h
; -----------------------------------------------------------------------------

INT23:   iret

; -----------------------------------------------------------------------------
;        zobrazen¡ textu ASCIIZ - BIOS (DX=sou©adnice, DS:SI=text)
; -----------------------------------------------------------------------------

DispB    PROC      NEAR

; ------ na‡ten¡ znaku

         mov       ah,7                     ; barva textu
DispB2:  cld
         lodsb
         cmp       al,0                     ; konec ?
         je        DispB8                   ; konec textu

; ------ ©¡dic¡ znaky

         cmp       al,1
         jne       DispB3
         xor       ah,8
         jmp       short DispB2
DispB3:  cmp       al,2
         jne       DispB4
         xor       ah,77h
         jmp       short DispB2

; ------ zobrazen¡ znaku

DispB4:  call      DispCh                   ; zobrazen¡ znaku
         inc       dl                       ; zv˜¨en¡ pozice na displeji
         jmp       short DispB2             ; dal¨¡ znak

DispB8:  ret

DispB    ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ znaku AX (pozice DX)
; -----------------------------------------------------------------------------

DispCh   PROC      NEAR

; ------ £schova registr–

         push      ax
         push      di
         push      es

; ------ v˜po‡et adresy ve videopamˆti

         push      ax
         mov       al,160                   ; po‡et bajt– na © dek
         mul       dh                       ; p©epo‡et © dk– na bajty
         mov       di,ax                    ; adresa za‡ tku © dku
         mov       al,dl
         mov       ah,0
         add       di,ax
         add       di,ax                    ; p©i‡ten¡ pozice
         pop       ax

; ------ z pis znaku do videopamˆti

         mov       es,ds:[SegmVRAM]
         cld
         stosw                              ; ulo‘en¡ znaku

; ------ n vrat registr–

         pop       es
         pop       di
         pop       ax
         ret

DispCh   ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ proveden‚ho tahu
; -----------------------------------------------------------------------------

DispMov  PROC      NEAR

         mov       dh,ds:[Radek]            ; © dek

         mov       dl,5                     ; pozice
         mov       al,ds:[OldPoz]
         call      DispMv                   ; zobrazen¡ pol¡‡ka

         mov       dl,8                     ; pozice
         mov       al,"-"                   ; oddˆlova‡ tah–
         call      DispChar

         mov       al,ds:[NewPoz]
         mov       dl,10
         call      DispMv

         mov       dl,12
         mov       al," "
         call      DispChar

         mov       dl,13
         mov       al,"X"
         test      byte ptr ds:[OldFig],7fh
         jnz       DispMov3
         mov       al," "
DispMov3:call      DispChar

         mov       dl,15
         mov       al,ds:[Rosad]
         mov       si,offset MalRosTx
         cmp       al,1
         je        DispMov4
         mov       si,offset VelRosTx
         cmp       al,2
         je        DispMov4
         mov       si,offset PxPepTx
         cmp       al,3
         jne       DispMov6
DispMov4:cld
         lodsb
         cmp       al,0
         je        DispMov6
         call      DispChar
         inc       dx
         jmp       short DispMov4
DispMov6:
         ret

DispMov  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ pol¡‡ka AL
; -----------------------------------------------------------------------------

DispMv   PROC      NEAR

; ------ v˜po‡et © dku a pozice

         mov       cl,10
         mov       ah,0
         div       cl                       ; v˜po‡et © dku a pozice

; ------ zobrazen¡ pozice

         xchg      al,ah
         add       al,"a"-1
         call      DispChar

; ------ zobrazen¡ © dku

         inc       dx
         xchg      al,ah
         add       al,"1"-2
         call      DispChar
         ret

DispMv   ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ ‡¡sla tahu
; -----------------------------------------------------------------------------

DispTah  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      dx

; ------ vymaz n¡ © dku

         mov       dh,ds:[Radek]            ; aktivn¡ © dek
         call      DispClr                  ; vymaz n¡ © dku

; ------ zobrazen¡ oddˆlovac¡ dvojte‡ky

         mov       dl,3                     ; pozice k zobrazen¡ ‡¡sla tahu
         mov       al,":"
         call      DispChar
         dec       dx

; ------ dek¢dov n¡ ‡¡sla

         mov       cx,10
         mov       ax,ds:[CitTah]           ; ‡¡ta‡ tah–
DispTah1:push      dx
         xor       dx,dx
         div       cx                       ; v˜po‡et jedn‚ ‡¡slice
         xchg      bx,ax
         xchg      ax,dx
         pop       dx
         add       al,"0"                   ; korekce na ‡¡slici
         call      DispChar                 ; zobrazen¡ znaku
         xchg      ax,bx
         dec       dx                       ; sn¡‘en¡ pozice
         or        ax,ax                    ; je je¨tˆ ‡¡slo ?
         jnz       DispTah1                 ; dek¢dov n¡ dal¨¡ho ‡¡sla

; ------ n vrat registr–

         pop       dx
         pop       cx
         pop       ax
         ret

DispTah  ENDP

; -----------------------------------------------------------------------------
;        od© dkov n¡ v˜stupu na konzolu
; -----------------------------------------------------------------------------

DispCR   PROC      NEAR

; ------ £schova registr–

         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ zv˜¨en¡ ukazatele © dku

         inc       byte ptr ds:[Radek]      ; zv˜¨en¡ ukazatele © dku
         cmp       byte ptr ds:[Radek],25
         jb        DispCR9                  ; © dek je OK
         dec       byte ptr ds:[Radek]      ; n vrat ‡¡sla © dku

; ------ rolov n¡ obrazovky

         cld
         push      ds
         mov       es,ds:[SegmVRAM]
         push      es
         pop       ds
         mov       di,160-20*2 + 160
         mov       dx,23                    ; po‡et © dk–
DispCR2: mov       cx,20
         mov       si,di
         add       si,160
         rep       movsw
         add       di,160-20*2
         dec       dx
         jnz       DispCR2
         pop       ds

; ------ vymaz n¡ nov‚ho © dku

DispCR9: mov       dh,ds:[Radek]            ; aktu ln¡ © dek
         call      DispClr                  ; vymaz n¡ © dku

; ------ n vrat registr–

         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         ret

DispCR   ENDP

; -----------------------------------------------------------------------------
;        v˜stup znaku AL do v˜stupn¡ konzoly (sou©adnice DX)
; -----------------------------------------------------------------------------

DispChar PROC      NEAR

; ------ £schova registr–

         push      ax
         push      di
         push      es

; ------ ur‡en¡ adresy k ulo‘en¡ textu

         push      ax
         mov       al,160                   ; po‡et bajt– na © dek
         mul       dh                       ; p©epo‡et © dk– na pozice
         mov       di,ax                    ; adresa © dku
         mov       al,dl                    ; pozice
         add       al,80-20
         mov       ah,0
         add       di,ax
         add       di,ax                    ; adresa
         pop       ax

; ------ ulo‘en¡ znaku

         mov       es,ds:[SegmVRAM]
         cld
         mov       ah,7
         cmp       dl,4
         jb        DispChr2
         mov       ah,0fh
DispChr2:stosw                              ; ulo‘en¡ znaku

; ------ n vrat registr–

         pop       es
         pop       di
         pop       ax
         ret

DispChar ENDP

; -----------------------------------------------------------------------------
;        vymaz n¡ © dku DH konzoly
; -----------------------------------------------------------------------------

DispClr  PROC      NEAR

         push      ax
         push      dx
         mov       al,32                    ; znak mezery
         mov       dl,0
DispClr1:call      DispChar                 ; vymaz n¡ znaku
         inc       dx
         cmp       dl,20
         jb        DispClr1
         pop       dx
         pop       ax
         ret

DispClr  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ hl ¨en¡ DS:SI (prvn¡ bajt = d‚lka)
; -----------------------------------------------------------------------------

DispHlas PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      si
         push      di
         push      es

; ------ p©¡prava registr–

         cld
         mov       es,ds:[SegmVRAM]         ; segment videopamˆti
         lodsb                              ; d‚lka textu
         mov       bl,al                    ; d‚lka textu
         mov       cx,20                    ; ¨¡©ka © dku
         sub       cl,bl                    ; zbytek na okraje
         shr       cl,1                     ; okraje / 2
         mov       bh,cl                    ; prav˜ okraj
         adc       bh,0                     ; lich  mezera

; ------ zobrazen¡ lev‚ mezery

         mov       di,160-2*20              ; po‡ te‡n¡ adresa
         mov       ax,7020h                 ; znak mezery
         rep       stosw                    ; zobrazen¡ lev‚ mezery

; ------ zobrazen¡ textu

         mov       cl,bl                    ; d‚lka textu
DispHls1:lodsb
         stosw
         loop      DispHls1

; ------ zobrazen¡ prav‚ mezery

         mov       cl,bh                    ; prav  mezera
         mov       al," "                   ; znak mezery
         rep       stosw                    ; zobrazen¡ prav‚ mezery

; ------ n vrat registr–

         pop       es
         pop       di
         pop       si
         pop       cx
         pop       ax
         ret

DispHlas ENDP

;==========================================================================
;        ulo‘en¡ nov‚ definice do z sobn¡ku tah–
;==========================================================================
  
l_0000   PROC      NEAR

         mov       dx,ds:[d_09CC]           ; ukazatel v z sobn¡ku tah–
         mov       bx,offset d_09AA         ; konec z sobn¡ku tah–
         cmp       dx,bx                    ; je z sobn¡k ji‘ pln˜ ?
         jae       l_0046                   ; z sobn¡k je ji‘ pln˜

         mov       bx,ds:[d_09CA]
         mov       ds:[d_09CA],dx
         mov       ds:[bx],dx
         test      byte ptr ds:[FigTst1],8
         jnz       l_0022
         or        byte ptr ds:[CilFig1],10h

l_0022:  mov       bx,dx                    ; ukazatel v z sobn¡ku tah–
         mov       word ptr ds:[bx],0       ; bodov n¡ tahu
         mov       al,ds:[d_09B2]
         mov       ds:[bx+2],al
         mov       al,ds:[PozTah]           ; pozice p©i pokusu o tah
         mov       ds:[bx+3],al
         mov       al,ds:[CilFig1]           ; p–vodn¡ obsah nov‚ho pol¡‡ka
         mov       ds:[bx+4],al
         mov       byte ptr ds:[bx+5],0
         add       bx,6                     ; zv˜¨en¡ ukazatele v z sobn¡ku
         mov       ds:[d_09CC],bx           ; ukazatel v z sobn¡ku tah–
         ret

l_0046:  mov       word ptr ds:[bx],0       ; ohodnocen¡ - ‘ dn˜ bod
         ret

l_0000   ENDP
  
;==========================================================================
;        ulo‘en¡ definice tahu
;==========================================================================
  
l_004C   PROC      NEAR

         xor       byte ptr ds:[Protihr],80h
         jns       l_0057
         dec       word ptr ds:[CitTah]     ; ‡¡ta‡ tah–
l_0057:  dec       word ptr ds:[d_09C6]
         dec       byte ptr ds:[d_09D6]     ; ‡¡ta‡ hloubky (£rove¤ hry)
         mov       bx,ds:[d_09C2]
         sub       bx,4
         mov       ds:[d_09C2],bx
         mov       ax,ds:[bx+2]
         mov       ds:[d_09CC],ax           ; ukazatel v z sobn¡ku tah–
         mov       ax,ds:[bx]
         mov       ds:[d_09C4],ax           ; ukazatel v bufferu tah–
         call      l_0EC2                   ; n vrat tahu z bufferu tah–
         ret

l_004C   ENDP
  
;==========================================================================
;        jeden posun
; -----------------------------------------------------------------------------
; VSTUP: DH=p©¡znaky
;              bit 0 a‘ bit 3: po‡et krok–
;              bit 4:
;              bit 5: 1=nalezena soupe©ova figurka
;              bit 6: 1=nalezena vlastn¡ figurka
;              bit 7: 1=skok na d mu
;        CL=smˆr pohybu (p©¡rustek pozice od sou‡asn‚)
; -----------------------------------------------------------------------------

l_007A   PROC      NEAR

         push      cx
         push      dx
         push      di

         mov       al,byte ptr ds:[d_09C0]
         cmp       al,0
         je        l_00AE

         mov       bl,cl                    ; smˆr pohybu (p©¡rustek pozice)
         mov       dl,0
         mov       cl,al
         mov       ch,0
         mov       al,ds:[PozTah]           ; pozice p©i pokusu o tah
         mov       di,offset d_0165         ; tabulka pozic figurek

         cld
l_0094:  repne     scasb                    ; nalezen¡ pozice figurky
         jnz       l_00AE                   ; pozice nenalezena
         cmp       dl,0
         jne       l_00F3

         mov       dl,1
         mov       bh,ds:[di+9]             ; smˆr pohybu
         cmp       bh,bl                    ; je to stejn˜ smˆr ?
         je        l_0094                   ; je stejn˜ smˆr - dal¨¡
         neg       bh                       ; obr cen˜ smˆr
         cmp       bh,bl                    ; je obr cen˜ smˆr ?
         je        l_0094                   ; je obr cen˜ smˆr - dal¨¡
         jmp       short l_00F3             ; konec

; ------ adresa tabulky po‡t– figurek hr ‡e

l_00AE:  mov       di,word ptr ds:[CilFig2] ; c¡lov  figurka skoku (bez barvy)
         mov       bx,offset PocFigC        ; tabulka ‡ern‚ho hr ‡e
         mov       ah,0
         mov       al,ds:[CilFig1]          ; p–vodn¡ figurka na pol¡‡ku
         test      al,80h                   ; byla to b¡l  figurka ?
         jz        l_00C3                   ; byla to ‡ern  figurka
         mov       bx,offset PocFigB        ; tabulka b¡l‚ho hr ‡e

; ------ skok na d mu

l_00C3:  and       al,7                     ; figurka
         test      dh,80h                   ; skok na d mu ?
         jz        l_00CC                   ; nen¡ d ma
         mov       al,5                     ; bude d ma

; ------ zv˜¨en¡ celkov‚ho po‡tu figurek

l_00CC:  inc       byte ptr ds:[bx]         ; zv˜¨en¡ celkov‚ho po‡tu figurek

; ------ star‚ body figurky

         add       bx,ax
         add       bx,ax
         mov       ax,ds:[bx]               ; stav figurek

; ------ rozli¨en¡, zda bylo ji‘ nˆjak‚ bodov n¡

         cmp       al,0                     ; bylo ji‘ prvn¡ bodov n¡ ?
         je        l_00EB                   ; je to prvn¡ bodov n¡
         cmp       ah,0                     ; bylo druh‚ bodov n¡
         je        l_00E4                   ; je to druh‚ bodov n¡

; ------ t©et¡ bodov n¡ figurky

         inc       bx
         inc       bx
         mov       ax,ds:[bx]               ; bodov n¡ dal¨¡ho typu figurek
         jmp       short l_00EB

; ------ druh‚ bodov n¡ figurky

l_00E4:  mov       ah,ds:[di+TabBod]        ; bodov n¡
         jmp       short l_00F1

; ------ prvn¡ (a t©et¡) bodov n¡ figurky

l_00EB:  mov       ah,al                    ; nulov n¡ registru AH
         mov       al,ds:[di+TabBod]        ; bodov n¡
l_00F1:  mov       ds:[bx],ax               ; £schova bodov n¡

; ------ n vrat registr–

l_00F3:  pop       di
         pop       dx
         pop       cx
         ret       

l_007A   ENDP
  
; -----------------------------------------------------------------------------
;        test okol¡ figurky (bodov n¡ pozice figurky)
; -----------------------------------------------------------------------------
; Testuje se ve smˆrech ¨ikmo, kolmo a konˆm (kromˆ konˆ se krokuje do konce)
; -----------------------------------------------------------------------------
;þ
TestOkol PROC      NEAR

; ------ p©¡prava registr–

         push      cx
         mov       ch,16                    ; ‡¡ta‡ smˆr–
         xor       di,di                    ; ukazatel smˆr–

; ------ test jednoho smˆru

TestOk1: mov       cl,ds:[di+TabSmer]       ; smˆr pohybu figurky
         mov       dh,0                     ; ‡¡ta‡ krok– v jednom smˆru
         mov       al,ds:[PozTst]           ; testovan  pozice
         mov       ds:[PozTah],al           ; pozice p©i pokusu o tah

; ------ test v¨ech krok– v jednom smˆru (nalezen¡ nˆjak‚ prvn¡ figurky)

TestOk2: inc       dh                       ; ‡¡ta‡ krok– v dan‚m smˆru
         call      PokTah                   ; pokus o tah dan˜m smˆrem CL
         cmp       al,1                     ; je skok na soupe©e ?
         je        TestOk5                  ; je skok na soupe©e
         cmp       al,2                     ; je skok na vlastn¡ ?
         je        TestOk6                  ; je skok na vlastn¡
         cmp       al,0                     ; skok na pr zdn‚ pol¡‡ko ?
         jne       TestOk3                  ; je skok mimo ¨achovnici
         cmp       ch,9                     ; jsou tahy konˆm ?
         jae       TestOk2                  ; nen¡ k–¤ - dal¨¡ krok ve smˆru

; ------ konec jednoho smˆru - dal¨¡ smˆr

TestOk3: inc       di                       ; zv˜¨en¡ adresy v tabulce smˆr–
         dec       ch                       ; ‡¡ta‡ smˆr–
         jnz       TestOk1                  ; test dal¨¡ho smˆru
         mov       al,0                     ; p©¡znak
TestOk4: pop       cx
         ret       

; ------ nalezen soupe©

TestOk5: test      dh,40h                   ; byla ji‘ nalezena vlastn¡ ?
         jnz       TestOk3                  ; byla nalezena vlastn¡
         or        dh,20h                   ; p©¡znak nalezen¡ soupe©e
         jmp       short TestOk7            ; test povolen˜ch tah– na soupe©e

; ------ nalezen vlastn¡

TestOk6: test      dh,20h                   ; byl ji‘ nalezen soupe© ?
         jnz       TestOk3                  ; byl ji‘ nalezen soupe©
         or        dh,40h                   ; p©¡znak nalezen¡ vlastn¡ho

; ------ test, zda je skok na konˆ

TestOk7: mov       dl,ds:[CilFig2]          ; ru¨en  figurka
         cmp       ch,9                     ; jsou tahy konˆm ?
         jb        TestOkC                  ; je tah konˆm - test, zda je k–¤

; ------ kontrola skoku na d mu - libovoln˜ p©¡m˜ smˆr o libovoln˜ po‡et krok–

         cmp       dl,5                     ; je d ma ?
         jne       TestOk8                  ; nen¡ d ma
         or        dh,80h                   ; p©¡znak, ‘e je skok na d mu
         jmp       short TestOkD            ; smˆr je OK

; ------ kontrola tahu kr le - 1 krok libovoln˜m smˆrem

TestOk8: mov       al,dh                    ; ‡¡ta‡ krok–
         and       al,0Fh                   ; po‡et krok– v dan‚m smˆru
         cmp       al,1                     ; je 1 krok ?
         jne       TestOk9                  ; je v¡ce krok–
         cmp       dl,6                     ; je kr l ?
         je        TestOkD                  ; je kr l - OK

; ------ kontrola tahu st©elce - ¨ikm˜ smˆr

TestOk9: cmp       ch,0Dh                   ; jsou ¨ikm‚ smˆry ?
         jb        TestOkB                  ; jsou kolm‚ smˆry
         cmp       dl,3                     ; je st©elec ?
         je        TestOkD                  ; je st©elec - OK

; ------ jinak mus¡ b˜t pˆ¨ k

         mov       al,dh                    ; ‡¡ta‡ krok–
         and       al,0Fh                   ; po‡et krok–
         cmp       al,1                     ; je 1 krok ?
         jne       TestOk3                  ; nen¡ 1 krok
         cmp       dl,1                     ; je pˆ¨ k ?
         jne       TestOk3                  ; nen¡ pˆ¨ k

; ------ kontrola tahu pˆ¨ ka

         test      byte ptr ds:[CilFig1],80h ; je b¡l˜ pˆ¨ k ?
         jz        TestOkA                  ; je ‡ern˜ pˆ¨ k
         cmp       ch,0Fh                   ; t hne b¡l˜ pˆ¨ k nahoru ?
         jb        TestOk3                  ; b¡l˜ pˆ¨ k dol– - chyba
         jmp       short TestOkD            ; b¡l˜ pˆ¨ k nahoru - OK

TestOkA: cmp       ch,0Fh                   ; t hne ‡ern˜ pˆ¨ k dol– ?
         jae       TestOk3                  ; ‡ern˜ pˆ¨ k dol– - OK
         jmp       short TestOkD            ; ‡ern˜ pˆ¨ k nahoru - chyba

; ------ kontrola tahu vˆ‘¡

TestOkB: cmp       dl,4                     ; je vˆ‘ ?
         jne       TestOk3                  ; nen¡ vˆ‘
         jmp       short TestOkD            ; je vˆ‘ - OK

; ------ test, zda je skok na konˆ

TestOkC: cmp       dl,2                     ; je k–¤ ?
         jne       TestOk3                  ; nen¡ k–¤ - dal¨¡ smˆr

; ------ je tah povolen˜m smˆrem

TestOkD: cmp       byte ptr ds:[FigTst2],7
         je        TestOkE
         test      dh,20h                   ; je skok na soupe©e ?
         jz        TestOkF                  ; nen¡ skok na soupe©e
         mov       al,1                     ; p©¡znak, ‘e v cestˆ stoj¡ soupe©
         jmp       short TestOk4            ; konec

; ------ test, zda bude dal¨¡ tah

TestOkE: call      l_007A                   ; ulo‘en¡ bodov n¡ do tabulky figurek
TestOkF: mov       al,ds:[CilFig2]          ; p–vodn¡ figurka na pol¡‡ku
         cmp       al,6                     ; byl to kr l ?
         je        TestOkG                  ; byl to kr l - jen 1 krok
         cmp       al,2                     ; byl to k–¤ ?
         je        TestOkG                  ; byl to k–¤ - jen 1 krok
         jmp       TestOk2                  ; jinak test dal¨¡ho kroku

TestOkG: jmp       TestOk3                  ; konec

TestOkol ENDP
  
;==========================================================================
;        n hodn˜ v˜bˆr tabulky zah jen¡ hry
;==========================================================================
  
l_01C8   PROC      NEAR

         push      ds
         xor       ax,ax
         mov       ds,ax
         mov       al,ds:[46ch]
         pop       ds

         and       al,3                     ; ni‘¨¡ 2 bity setiny sekundy
         mov       dl,6                     
         mul       dl                       ; n hodn‚ ‡¡slo 0, 6, 12, 18
         mov       dx,offset d_000E
         add       ax,dx                    
         mov       ds:[d_09C8],ax           ; nalezen˜ tah po‡¡ta‡e
         ret

l_01C8   ENDP

;==========================================================================
;        test ro¨ dy
;==========================================================================
  
l_01DE   proc    near

         test      byte ptr ds:[FigTst1],8
         jz        l_01E6
         ret       

l_01E6:  cmp       byte ptr ds:[d_09D7],0
         je        l_01EE
         ret       

l_01EE:  mov       cx,0FF03h                ; posun kr le o 3 pole vpravo
l_01F1:  add       cl,ds:[d_09B2]           
         mov       bh,0                     
         mov       bl,cl                    ; testovan‚ pol¡‡ko
         mov       word ptr ds:[PozTst],bx
         mov       al,ds:[bx+Mapa]        ; obsah pol¡‡ka
         and       al,7Fh                   ; zru¨en¡ p©¡znaku barvy
         cmp       al,4                     ; je vˆ‘ ?
         jne       l_026E                   ; nen¡ vˆ‘
         jz        l_0229

l_0209:  mov       bx,word ptr ds:[PozTst]  ; pozice v ¨achovnici
         cmp       byte ptr ds:[bx+Mapa],0 ; je pr zdn‚ pole ?
         jne       l_026E                   ; nen¡ pr zdn‚ pole
         cmp       bl,5Ch                                ; '\'
         je        l_0229
         cmp       bl,16h
         je        l_0229
         call      TestOkol                   ; test okol¡ figurky
         cmp       al,0                     ; bylo pr zdn‚ pol¡‡ko ?
         jne       l_026E
         mov       bx,word ptr ds:[PozTst]
l_0229:  add       bl,ch
         mov       word ptr ds:[PozTst],bx
         cmp       bl,ds:[d_09B2]
         jne       l_0209
         sub       bl,ch
         sub       bl,ch
         mov       ds:[PozTah],bl           ; pozice p©i pokusu o tah
         mov       byte ptr ds:[CilFig1],40h
         call      l_0000                   ; ulo‘en¡ definice do z sobn¡ku tah–
         mov       al,ds:[d_09B2]
         sub       al,ch
         mov       ds:[PozTah],al           ; pozice p©i pokusu o tah
         mov       ds:[d_09B2],cl
         mov       byte ptr ds:[CilFig1],0
         call      l_0000                   ; ulo‘en¡ definice do z sobn¡ku tah–
         mov       bx,ds:[d_09CA]
         sub       bx,6
         mov       ds:[d_09CA],bx
         mov       word ptr ds:[bx],0
         mov       al,ds:[PozTst]
         mov       ds:[d_09B2],al

l_026E:  cmp       ch,1                     ; byl ji‘ druh˜ smˆr ?
         je        l_0279                   ; byl ji‘ druh˜ smˆr
         mov       cx,1FCh                  ; posun kr le o 4 pozice vlevo
         jmp       l_01F1                   ; nov˜ pokus

l_0279:  ret

l_01DE   ENDP

;==========================================================================
;        Tah po‡¡ta‡e
;==========================================================================
  
TahPoc   PROC      NEAR

; ------ hl ¨en¡, ‘e t hne po‡¡ta‡

         mov       byte ptr ds:[Hraje],1    ; p©¡znak, ‘e hraje po‡¡ta‡

         mov       si,offset CekTxt
         call      DispHlas

         mov       dh,ds:[Radek]            ; aktu ln¡ © dek
         mov       dl,4
         mov       al,16
         call      DispChar                 ; indik tor ‡ek n¡

l_02CA:  call      l_0606                   ; nalezen¡ tahu pro po‡¡ta‡
         mov       ax,ds:[d_09C8]           ; nalezen˜ tah po‡¡ta‡e
         mov       ds:[d_09C4],ax           ; ukazatel v bufferu tah–
         cmp       byte ptr ds:[d_017F],1
         jne       l_02EA                   
         mov       cl,1                     
         call      l_05B0                   ; hl ¨en¡ o matu

l_02EA:  call      l_09B4                   ; proveden¡ jednoho tahu
         mov       al,ds:[Hrac]           ; 80=hr ‡ m  b¡l‚, 00=‡ern‚
         mov       ds:[Protihr],al           ; 80=po‡¡ta‡ m  b¡l‚, 00=‡ern‚
         call      Rosada                   ; volba tahu pro ro¨ du

         mov       byte ptr ds:[Rosad],0    ; p©¡znak - nen¡ ro¨ da

         mov       ds:[NewPoz],dl           ; c¡lov  pozice
         mov       ds:[OldPoz],cl           ; v˜choz¡ pozice

                                           ;* norm ln¡ tah
         cmp       ch,0                     ; je norm ln¡ tah ?
         jne       l_0316                   ; nen¡ norm ln¡ tah

;         mov       ds:[NewPoz],dl           ; c¡lov  pozice
;         mov       ds:[OldPoz],cl           ; v˜choz¡ pozice
         jmp       short l_033E             ; pokra‡ov n¡
                                           ;* mal  ro¨ da "O-O"
l_0316:  test      ch,2                     ; je mal  ro¨ da ?
         jz        l_0326                   ; nen¡ mal  ro¨ da
         mov       byte ptr ds:[Rosad],1    ; p©¡znak - je mal  ro¨ da
         jmp       short l_033E             ; pokra‡ov n¡
                                           ;* velk  ro¨ da "O-O-O"
l_0326:  test      ch,4                     ; je velk  ro¨ da ?
         jz        l_0336                   ; nen¡ velk  ro¨ da
         mov       byte ptr ds:[Rosad],2    ; p©¡znak - je velk  ro¨ da
         jmp       short l_033E             ; pokra‡ov n¡
         nop                                

l_0336:  mov       byte ptr ds:[Rosad],3    ; p©¡znak "PxPep"

l_033E:  cmp       byte ptr ds:[d_017F],0FFh
         jne       l_034D
         mov       cl,0                     
         call      l_05B0                   ; hl ¨en¡ o matu
         jmp       short l_0368             ; konec, ‡ek  na znak
         nop
                                            
l_034D:  lea       bx,ds:[d_09E2]           ;
         mov       al,ds:[Hrac]           ; 80=hr ‡ m  b¡l‚, 00=‡ern‚
         xor       al,80h                   
         call      TestFig                   ; test okol¡ aktivn¡ figurky
         cmp       al,0                     
         je        l_0368                   
;         lea       dx,ds:[d_004E]
;         mov       ah,9
;         int       21h                      ; tisk textu "Check"
l_0368:

         mov       dh,ds:[Radek]            ; aktu ln¡ © dek
         mov       dl,4
         mov       al," "
         call      DispChar                 ; indik tor ‡ek n¡

         call      DispMov                  ; zobrazen¡ proveden‚ho tahu
         call      DispCR                   ; od© dkov n¡ textu
         ret

TahPoc   ENDP
  
;==========================================================================
;        Zobrazen¡ ¨achovnice
;==========================================================================
  
Disp     PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      di
         push      es

; ------ zobrazen¡ ¨achovnice

         xor       bx,bx                    ; ‡¡slo prvn¡ho pol¡‡ka
         mov       cx,offset(Mapa0-Mapa)
Disp2:   mov       dl,ds:[bx+Mapa]          ; mapa ¨achovnice
         cmp       dl,0FFh                  ; je zak zan‚ pol¡‡ko ?
         je        Disp3                    ; pol¡‡ko je zak zan‚
         mov       al,bl                    ; ‡¡slo pol¡‡ka
         call      DispPol                  ; zobrazen¡ pol¡‡ka
Disp3:   inc       bx                       ; zv˜¨en¡ ‡¡sla pol¡‡ka
         loop      Disp2

; ------ zobrazen¡ ‡¡slic vlevo

         mov       di,160                   ; adresa k ulo‘en¡
         mov       es,ds:[SegmVRAM]         ; segment videopamˆti
         mov       ax,0fh*256 + "8"
         mov       cl,8
         cld
Disp4:   stosw                              ; ulo‘en¡ ‡¡slice © dku
         add       di,3*160-2
         dec       ax
         loop      Disp4

; ------ zobrazen¡ © dku dole

         add       di,5*2-160
         mov       al,"a"
         mov       cl,8
Disp5:   stosw
         add       di,6*2
         inc       ax
         loop      Disp5

; ------ n vrat registr–

         pop       es
         pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Disp     ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ pol¡‡ka
; -----------------------------------------------------------------------------
;þ
                                                 ; VSTUP: AL=‡¡slo pol¡‡ka
                                                 ;        DL=obsah pol¡‡ka
DispPol  PROC      NEAR

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

         mov       es,ds:[SegmVRAM]         ; segment videopamˆti
         cld

; ------ v˜po‡et sou©adnic pol¡‡ka

         mov       ah,0                     ; AX=‡¡slo pol¡‡ka
         mov       cl,10                    ; po‡et pozic na © dek
         div       cl                       ; v˜po‡et © dku a pozice pol¡‡ka
         sub       al,2                     ; ode‡ten¡ okraje
         neg       al                       ; - ‡¡slo © dku
         add       al,7                     ; po‡ te‡n¡ offset ‡¡sla © dku
         dec       ah                       ; ‡¡slo pozice - 1
         mov       bl,ah                    ; £schova ‡¡sla pozice

; ------ ur‡en¡ barvy pol¡‡ka

         mov       bp,70h*256 + 178         ; b¡l  barva, pln‚ pol¡‡ko
         cmp       dl,80h                   ; je pr zdn‚ inverzn¡ pol¡‡ko ?
         jne       DispPol1
         xor       bp,77h*256               ; inverzn¡ pr zdn‚ pol¡‡ko
DispPol1:xor       ah,al                    ; test barvy pol¡‡ka
         test      ah,1                     ; je ‡ern‚ pol¡‡ko ?
         jz        DispPol2                 ; je ‡ern‚ pol¡‡ko
         xor       bp,77h*256               ; zmˆna barvy pol¡‡ka
         xor       dl,80h                   ; zmˆna barvy figurky
DispPol2:test      dl,80h
         jnz       DispPl22
         add       bp,176-178               ; n hrada ¨rafovan˜m pol¡‡kem

; ------ v˜po‡et adresy ve videopamˆti

DispPl22:mov       cl,80*3                  ; po‡et pozic na © dek
         mul       cl                       ; p©epo‡et © dku na znaky
         shl       ax,1                     ; po‡et bajt–
         add       ax,4
         mov       di,ax                    ; po‡ te‡n¡ adresa © dku
         mov       al,7*2                   ; po‡et bajt– na ¨¡©ku pol¡‡ka
         mul       bl                       ; v˜po‡et offsetu na © dku
         add       di,ax                    ; adresa ve videopamˆti

; ------ test, zda se zobraz¡ pr zdn‚ pol¡‡ko

         mov       al,dl                    ; ‡¡slo figurky
         and       al,7                     ; ‡¡slo figurky
         jnz       DispPol4                 ; je figurka

; ------ zobrazen¡ pr zdn‚ho pol¡‡ka

         mov       bh,3                     ; po‡et © dk– na pol¡‡ko
         mov       ax,bp                    ; barva pol¡‡ka
         mov       al," "                   ; znak mezery
DispPol3:mov       cx,7                     ; po‡et znak– na pol¡‡ko
         rep       stosw                    ; vymaz n¡ © dku pol¡‡ka
         add       di,160-7*2               ; adresa dal¨¡ho © dku
         dec       bh                       ; ‡¡ta‡ © dk– pol¡‡ka
         jnz       DispPol3                 ; dal¨¡ © dek
         jmp       short DispPol9

; ------ adresa vzorku figurky

DispPol4:mov       cl,3*7                   ; po‡et bajt– na obr zek
         mul       cl                       ; offset obr zky
         mov       si,offset Obrazky-3*7
         add       si,ax                    ; adresa obr zky

; ------ zobrazen¡ figurky

         mov       bh,3                     ; po‡et © dk– k zobrazen¡
         mov       ax,bp                    ; barva pol¡‡ka
DispPol5:mov       cx,7                     ; po‡et bajt– na © dek
DispPol6:lodsb                              ; bajt k zobrazen¡
         cmp       al,178                   ; pln‚ pol¡‡ko ?
         jne       DispPol7                 ; nen¡ pln‚ pol¡‡ko
         mov       ax,bp                    ; n hradn¡ znak
DispPol7:stosw
         loop      DispPol6                 ; dal¨¡ znak na © dku
         add       di,160-2*7               ; adresa dal¨¡ho © dku
         dec       bh                       ; ‡¡ta‡ © dk–
         jnz       DispPol5                 ; zobrazen¡ dal¨¡ho © dku

; ------ n vrat registr–

DispPol9:pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispPol  ENDP

;==========================================================================
;       vno©en¡ do tahu
;==========================================================================
  
l_0492   PROC      NEAR

         mov       al,ds:[d_09B2]
         test      byte ptr ds:[FigTst1],80h
         jz        l_049E
         add       al,0Ah
l_049E:  cmp       al,3Dh                                ; '='
         jb        l_0508
         cmp       al,44h                                ; 'D'
         ja        l_0508
         mov       bx,ds:[d_09C4]           ; ukazatel v bufferu tah–
         test      byte ptr ds:[bx+4],10h
         jz        l_0508
         mov       bl,ds:[bx+3]
         mov       ds:[d_09B8],bl
         mov       bh,0
         mov       al,ds:[bx+Mapa]        ; obsah pole
         mov       ds:[d_09D2],al           
         and       al,7                     
         cmp       al,1                     ; je pˆ¨ k ?
         jne       l_0508                   ; nen¡ pˆ¨ k

         sub       bl,ds:[PozTah]           ; pozice p©i pokusu o tah
         jns       l_04CE                   
         neg       bl                       ; absolutn¡ hodnota rozd¡lu
l_04CE:  cmp       bl,0Ah
         jne       l_0508
         or        byte ptr ds:[CilFig1],40h              ; '@'
         call      l_0000                   ; ulo‘en¡ definice do z sobn¡ku tah–
         mov       al,ds:[d_09B2]
         mov       ds:[PozTst],al
         mov       al,ds:[d_09B8]
         mov       ds:[d_09B2],al
         mov       ds:[PozTah],al           ; pozice p©i pokusu o tah
         mov       al,ds:[d_09D2]
         mov       ds:[CilFig1],al
         call      l_0000                   ; ulo‘en¡ definice do z sobn¡ku tah–
         mov       al,ds:[PozTst]
         mov       ds:[d_09B2],al
         mov       bx,ds:[d_09CA]
         sub       bx,6
         mov       ds:[d_09CA],bx
         mov       word ptr ds:[bx],0
l_0508:  ret

l_0492   ENDP
  
;==========================================================================
;       jeden tah s vyhodnocen¡m
;==========================================================================
  
l_050A   PROC      NEAR

         call      l_09B4                   ; proveden¡ jednoho tahu
         mov       al,ds:[Protihr]
         call      TestFig                   ; test okol¡ aktivn¡ figurky
         cmp       al,0
         je        l_051F
         mov       byte ptr ds:[d_09D9],0
         jmp       short l_0525
         nop
l_051F:  call      l_0B24                   ; hodnocen¡ jednoho stavu ¨achovnice
         call      l_0CA8                   
l_0525:  call      l_0EC2                   ; n vrat tahu z bufferu tah–
         ret

l_050A   ENDP
  
;==========================================================================
;        volba tahu pro ro¨ du
;==========================================================================
  
Rosada   PROC      NEAR

         mov       si,ds:[d_09C4]           ; ukazatel v bufferu tah–
         mov       al,ds:[Protihr]           ; 80=po‡¡ta‡ m  b¡l‚, 00=‡ern‚
         cmp       al,ds:[Hrac]           ; 80=hr ‡ m  b¡l‚, 00=‡ern‚
         jne       l_056C

l_0537:  mov       bh,0
         mov       bl,ds:[si+3]             ; c¡lov  pozice
         cmp       bl,ds:[si+2]             ; = v˜choz¡ pozice ?
         je        l_055B                   ; c¡lov  pozice = v˜choz¡ pozice

         mov       dh,ds:[bx+Mapa]        ; vektor ¨achovnice
         test      byte ptr ds:[si+4],20h                   ; ' '
         jz        l_0551
         and       dh,0F8h
         or        dh,1
l_0551:  mov       dl,0
         mov       bl,ds:[si+2]                ; ‡¡slo pol¡‡ka
         mov       ch,0Ah                      ; po‡et bliknut¡ kurzoru
         call      BlikKurz                      ; blik n¡ kurzoru

l_055B:  mov       bh,0
         mov       bl,ds:[si+3]             
         mov       dh,ds:[si+4]             
         mov       dl,ds:[bx+Mapa]        ; vektor ¨achovnice
         mov       ch,0Ah                   
         call      BlikKurz                      ; blik n¡ kurzoru

l_056C:  test      byte ptr ds:[si+4],40h                   ; '@'
         jz        l_0577
         add       si,6
         jmp       short l_0537

l_0577:  mov       bx,ds:[d_09C4]           ; ukazatel v bufferu tah–
         mov       cl,ds:[bx+2]
         mov       dl,ds:[bx+3]
         mov       ch,0
         test      byte ptr ds:[bx+4],40h                   ; '@'
         jz        l_05AF
         add       bx,6
         mov       cl,ds:[bx+2]
         mov       dl,ds:[bx+3]
         cmp       cl,dl
         jne       l_059C
         or        ch,1
         jmp       short l_05AF

l_059C:  cmp       dl,1Ah
         je        l_05AC
         cmp       dl,60h                                ; '`'
         je        l_05AC
         or        ch,4
         jmp       short l_05AF
l_05AC:  or        ch,2
l_05AF:  ret

Rosada   ENDP

;==========================================================================
;        hl ¨en¡ o matu (nebo bl¡‘¡c¡m se matu)
;==========================================================================
  
l_05B0   PROC      NEAR

         mov       al,ds:[d_09D3]           ; zbyl˜ po‡et tah– 1
         sub       al,byte ptr ds:[CitTah]  ; ‡¡ta‡ tah–
         jnz       l_05D4                   ; nen¡ v˜hra

         mov       al,ds:[Hrac]             ; barva hr ‡e
         cmp       cl,0                     ; je v¡tˆzem po‡¡ta‡ ?
         jne       l_05aaa                  ; ne - vyhr l hr ‡
         xor       al,80h                   ; zmˆna barvy - barva po‡¡ta‡e
l_05aaa: mov       si,offset d_0A5A         ; ‡ern˜ vyhr l
         cmp       al,0                     ; vyhr l ‡ern˜ ?
         je        l_05aab                  ; vyhr l ‡ern˜
         mov       si,offset d_0a3a         ; b¡l˜ vyhr l
l_05aab:
         call      DispHlas
         jmp       l_0894                   ; konec hry

                                          ;* mat se bl¡‘¡
l_05D4:  cmp       cl,0                     ; hraje po‡¡ta‡ ?
         jne       l_05E6                   ; nehraje po‡¡ta‡
         add       al,30h                   ; korekce na ‡¡slici
         mov       ds:[d_0A52],al         
         mov       si,offset d_0a4a
         call      DispHlas

l_05E6:  ret

l_05B0   ENDP
  
;==========================================================================
;        blik n¡ kurzoru
;==========================================================================
  
BlikKurz   PROC      NEAR
                                            ; VSTUP: CH=po‡et bliknut¡
                                            ;        BL=‡¡slo pol¡‡ka
                                            ;        DL=figurka
                                            ;        DH=figurka s kurzorem

         mov       al,dl
         xor       al,dh
         js        BlikKur1
         test      dl,7fh
         jz        BlikKur1
         test      dh,7fh
         jz        BlikKur1
         xor       dh,80h

; ------ obsluha kl vesnice

BlikKur1:mov       cl,0                     ; p©¡znak dvoj¡ho bliknut¡
BlikKur2:cmp       byte ptr ds:[Hraje],0
         jne       BlikKur3                 ; hraje po‡¡ta‡
         call      Obsluha                  ; proveden¡ obsluhy kl vesy

; ------ prodleva

BlikKur3:push      ax
         mov       ah,1
         int       16h                      ; test stavu kl vesnice
         pop       ax
         jnz       BlikKur4                 ; je kl vesa
         call      Cekej                    ; ‡ek n¡ po 1/18 sekundy

; ------ zobrazen¡ pol¡‡ka

BlikKur4:xchg      dl,dh                    ;
         mov       al,bl                    ; ‡¡slo pol¡‡ka
         call      DispPol                  ; zobrazen¡ pol¡‡ka AL
         xor       cl,1                     ; test p©¡znaku ukon‡en¡ tahu
         jnz       BlikKur2                 ; tah nebyl dokon‡en
         dec       ch                       ; ‡¡ta‡ po‡tu bliknut¡
         jnz       BlikKur2                 ; dal¨¡ cyklus bliknut¡
         ret

BlikKurz ENDP
  
;==========================================================================
;        nalezen¡ tahu pro po‡¡ta‡
;==========================================================================
  
l_0606   PROC      NEAR

; --- p©¡prava

         mov       al,ds:[Uroven]           ; £rove¤ hry 1-6
         mov       ds:[d_0A6C],al           ; £schova £rovnˆ hry p©i tahu

; ------ prvn¡ tah - n hodn‚ zah jen¡       

         cmp       word ptr ds:[CitTah],1   ; je to prvn¡ tah ?
         jne       l_062F                   ; nen¡ prvn¡ tah
         mov       byte ptr ds:[d_017F],0
         test      byte ptr ds:[Hrac],80h ; 80=hr ‡ m  b¡l‚, 00=‡ern‚
         jnz       l_062F                   ; hr ‡ m  b¡l‚
         call      l_01C8                   ; n hodn˜ v˜bˆr tabulky zah jen¡
         ret                                

; ----- pro m‚nˆ ne‘ 4. tah omezen¡ £rovnˆ hry na 1 (pro rozehr n¡)

l_062F: ; push      ds
        ; xor       ax,ax
        ; mov       ds,ax
        ; mov       al,ds:[46ch]
        ; pop       ds
        ; test      al,1ch                   ; nepozornost p©i 1/8
        ; jnz       l_062f2
        ;
        ; and       al,3
        ; sub       byte ptr ds:[Uroven],al
        ; jbe       l_062f3

l_062f2: mov       al,ds:[Uroven]
         mov       ah,0
         cmp       ax,word ptr ds:[CitTah]  ; ‡¡ta‡ tah–
         jb        l_063B
         mov       al,byte ptr ds:[CitTah]
         sub       al,1
         mov       ds:[Uroven],al           ; sn¡‘en¡ £rovnˆ
         ja        l_063b

l_062f3: mov       byte ptr ds:[Uroven],1   ; na za‡ tku £rove¤ hry = 1

l_063B:  xor       ax,ax
         mov       byte ptr ds:[d_09D6],al  ; ‡¡ta‡ hloubky (£rove¤ hry)
         mov       ds:[d_09C8],ax           ; nalezen˜ tah po‡¡ta‡e (nen¡ nic)
         lea       ax,ds:[d_01B2]           ; za‡ tek tabulky tah–
         mov       ds:[d_09CC],ax           ; ukazatel v z sobn¡ku tah–
         lea       ax,ds:[d_018A]           
         sub       ax,2                     
         mov       ds:[d_09C2],ax           
         mov       al,ds:[Hrac]           ; 80=hr ‡ m  b¡l‚, 00=‡ern‚
         mov       ds:[Protihr],al           ; 80=po‡¡ta‡ m  b¡l‚, 00=‡ern‚
         lea       di,ds:[d_017E]           
         mov       ds:[d_09C6],di           
         mov       ch,0                     
         mov       cl,ds:[Uroven]           ; £rove¤ hry
         add       cl,2                     
         mov       al,0                     
         cld                                
         rep       stosb                    
         mov       ds:[d_09DF],al           
         mov       ds:[d_09E0],al           
         call      l_0B24                   
         call      l_0CA8                   ; hodnocen¡ jednoho stavu ¨achovnice
         mov       al,ds:[d_09DA]           
         mov       ds:[d_09DF],al           
         mov       al,ds:[d_09DE]           
         mov       ds:[d_09E0],al           
         jmp       short l_069D             


l_068C:                                     ; (zde m  b˜t zobrazen¡ ‡asu)

         call      DispStav                 ; zobrazen¡ stavu

l_069D:  inc       byte ptr ds:[d_09D6]     ; ‡¡ta‡ hloubky (£rove¤ hry)

;         call      DispStav

         mov       byte ptr ds:[d_09D8],0
         call      l_08A2                   ; test, zda m  hr ‡ dal¨¡ tah
         mov       al,byte ptr ds:[d_09D6]  ; ‡¡ta‡ hloubky (£rove¤ hry)
         cmp       al,ds:[Uroven]           ; £rove¤ hry
         jae       l_06B5
         call      l_0E88

l_06B5:  mov       ax,ds:[d_09C2]
         mov       ds:[d_09C4],ax           ; ukazatel v bufferu tah–
l_06BB:  mov       bx,ds:[d_09C4]           ; ukazatel v bufferu tah–
         mov       ax,ds:[bx]
         cmp       ax,0
         je        l_072A
         mov       ds:[d_09C4],ax           ; ukazatel v bufferu tah–
         mov       bx,ds:[d_09C2]
         mov       ds:[bx],ax
         mov       al,byte ptr ds:[d_09D6]  ; ‡¡ta‡ hloubky (£rove¤ hry)
         cmp       al,ds:[Uroven]           ; £rove¤ hry
         jb        l_0701                   
         call      l_09B4                   ; proveden¡ jednoho tahu
         mov       al,ds:[Protihr]
         call      TestFig                   ; test okol¡ aktivn¡ figurky
         cmp       al,0                     
         je        l_06EA                   
         call      l_0EC2                   ; n vrat tahu z bufferu tah–
         jmp       short l_06BB

l_06EA:  mov       al,byte ptr ds:[d_09D6]  ; ‡¡ta‡ hloubky (£rove¤ hry)
         cmp       al,ds:[Uroven]           ; £rove¤ hry
         jne       l_0759                   
         mov       al,ds:[Protihr]
         xor       al,80h                   
         call      TestFig                   ; test okol¡ aktivn¡ figurky
         cmp       al,0
         je        l_0759
         jnz       l_070E
l_0701:  mov       bx,ds:[d_09C4]           ; ukazatel v bufferu tah–
         cmp       byte ptr ds:[bx+5],0
         je        l_06BB
         call      l_09B4                   ; proveden¡ jednoho tahu
l_070E:  xor       byte ptr ds:[Protihr],80h
         js        l_0719
         inc       word ptr ds:[CitTah]     ; ‡¡ta‡ tah–
l_0719:  mov       bx,ds:[d_09C6]
         mov       al,ds:[bx]
         mov       ds:[bx+2],al
         inc       bx
         mov       ds:[d_09C6],bx
         jmp       l_068C

l_072A:  cmp       byte ptr ds:[d_09D8],0
         jne       l_0745
         mov       al,80h
         cmp       byte ptr ds:[d_09D7],0
         je        l_0765
         mov       al,byte ptr ds:[CitTah]  ; ‡¡ta‡ tah–
         mov       ds:[d_09D3],al           ; zbyl˜ po‡et tah– 1
         mov       al,0FFh
         jmp       short l_0765

l_0745:  cmp       byte ptr ds:[d_09D6],1   ; ‡¡ta‡ hloubky (£rove¤ hry)
         je        l_07A6
         call      l_004C
         mov       bx,ds:[d_09C6]
         mov       al,ds:[bx+2]
         jmp       short l_076E

l_0759:  call      l_0B24                   ; hodnocen¡ jednoho stavu ¨achovnice
         call      l_0CA8                   
         call      l_0EC2                   ; n vrat tahu z bufferu tah–
         mov       al,ds:[d_09D9]
l_0765:  mov       byte ptr ds:[d_09D8],1
         mov       bx,ds:[d_09C6]
l_076E:  cmp       al,ds:[bx]
         ja        l_0778
         call      l_004C
l_0775:  jmp       l_06BB

l_0778:  neg       al
         inc       bx
         cmp       al,ds:[bx]
         jbe       l_0775
         mov       ds:[bx],al

;         call      DispStav

         cmp       byte ptr ds:[d_09D6],1   ; ‡¡ta‡ hloubky (£rove¤ hry)
         jne       l_0775

         mov       ax,ds:[d_09C4]           ; ukazatel v bufferu tah–
                                            ; - nalezen˜ nejlep¨¡ tah
         mov       ds:[d_09C8],ax           ; nalezen˜ tah po‡¡ta‡e

         call      DispStav                 ; zobrazen¡ stavu

         mov       ax,word ptr ds:[d_017E]
         cmp       ah,0FFh
         jne       l_0775
         sub       byte ptr ds:[Uroven],2   ; £rove¤ hry
         test      byte ptr ds:[Hrac],80h ; 80=hr ‡ m  b¡l‚, 00=‡ern‚
         jz        l_07A6                   
         dec       byte ptr ds:[d_09D3]     ; zbyl˜ po‡et tah– 1
l_07A6:  mov       al,ds:[d_0A6C]           ; £schova £rovnˆ hry p©i tahu
         mov       ds:[Uroven],al           ; £rove¤ hry
         ret

l_0606   ENDP


DispStav PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di

         mov       ah,1
         int       16h
         jz        l_068c5
         call      InpChr
         cmp       bl,27
         jne       l_068c5

         mov       si,offset PrerTxt        ; dotaz k p©eru¨en¡
         call      DispHlas                 ; zobrazen¡ hl ¨en¡
l_068c2: call      InpChr                   ; vstup znaku z kl vesnice
         cmp       bl,27
         je        l_068c2
         cmp       bl,"A"
         jne       l_068c4

         mov       al,ds:[d_0A6C]           ; £schova £rovnˆ hry p©i tahu
         mov       ds:[Uroven],al           ; £rove¤ hry
         jmp       Zadej

l_068c4: mov       si,offset CekTxt
         call      DispHlas

l_068c5: mov       bx,ds:[d_09c8]
         or        bx,bx
         jz        DispSt18

         mov       al,ds:[OldPoz]
         mov       ah,ds:[NewPoz]
         push      ax
         mov       al,ds:[OldFig]
         mov       ah,ds:[Rosad]
         push      ax

         mov       ax,ds:[bx+2]
         mov       ds:[OldPoz],al
         mov       ds:[NewPoz],ah
         mov       al,ds:[bx+4]
         and       al,7
         mov       ds:[OldFig],al
         mov       byte ptr ds:[Rosad],0
         call      DispMov

         pop       ax
         mov       ds:[Rosad],ah
         mov       ds:[OldFig],al
         pop       ax
         mov       ds:[NewPoz],ah
         mov       ds:[OldPoz],al

DispSt18:

l_068c7:
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispStav ENDP

;==========================================================================
;        Tah hr ‡e - pohyb figurkou
;==========================================================================
  
Obsluha  PROC      NEAR

; ------ test, zda je nˆjak  kl vesa

         mov       ah,1
         int       16h
         jz        Obsluha9                 ; nen¡ kl vesa

; ------ £schova registr–

         push      ax
         push      bx
         push      cx                       
         push      dx                       

; ------ v˜po‡et aktu ln¡ho © dku a pozice

         mov       ah,0
         mov       al,ds:[Kurzor]           ; pozice kurzoru
         mov       cl,10                    ; po‡et pozic na © dek
         div       cl                       ; v˜po‡et © dku a pozice
         xchg      ax,dx                    ; DH=pozice, DL=© dek

; ------ vstup znaku z kl vesnice

         call      InpChr
         call      Obsluha2                 ; obsluha kl vesy

; ------ n vrat registr–

         pop       dx
         pop       cx
         pop       bx
         pop       ax
Obsluha9:ret

Obsluha  ENDP

;þ
Obsluha2:call      JumpBX                   ; skok na obsluhu kl vesy

         dw        4800h,ObslUp             ; nahoru
         dw        4900h,ObslPgUp           ; £plnˆ nahoru
         dw        4b00h,ObslLeft           ; vlevo
         dw        4d00h,ObslRght           ; vpravo
         dw        5000h,ObslDwn            ; dol–
         dw        5100h,ObslPgDn           ; £plnˆ dol–
         dw        4f00h,ObslEnd            ; £plnˆ vpravo
         dw        4700h,ObslHome           ; £plnˆ vlevo

         dw        0dh,ObslEnt              ; ENTER
         dw        " ",ObslEnt              ; mezera
         dw        5200h,ObslEnt            ; INSERT
         dw        5300h,ObslEnt            ; DELETE
         dw        27,ObslEsc               ; ESC

         dw        0,Obsluha9

; -----------------------------------------------------------------------------
;        p©eru¨en¡ programu
; -----------------------------------------------------------------------------

ObslEsc  PROC      NEAR

         push      si
         mov       si,offset PrerTxt        ; dotaz k p©eru¨en¡
         call      DispHlas                 ; zobrazen¡ hl ¨en¡
         pop       si
         call      InpChr                   ; vstup znaku z kl vesnice
         cmp       bl,"A"
         jne       ObslEsc4
         jmp       short l_08942

                                          ;* konec hry - nˆkdo vyhr l
l_0894:  call      KurzOff
         call      InpChr
l_08942: call      Clear
         jmp       Zadej

ObslEsc4:mov       si,offset TahTxt
         call      DispHlas
         ret

ObslEsc  ENDP

; -----------------------------------------------------------------------------
;        kl vesa Home - £plnˆ vlevo
; -----------------------------------------------------------------------------

ObslHome PROC      NEAR

         cmp       dh,1                     ; je za‡ tek © dku ?
         je        ObslHom4                 ; je ji‘ za‡ tek © dku
         call      ObslLeft                 ; kurzor vlevo
         jmp       short ObslHome           ; dal¨¡ test
ObslHom4:ret

ObslHome ENDP

; -----------------------------------------------------------------------------
;        kl vesa Page Up - £plnˆ nahoru
; -----------------------------------------------------------------------------

ObslPgUp PROC      NEAR

         cmp       dl,9                     ; je horn¡ © dek ?
         je        ObslPgU4                 ; je horn¡ © dek
         call      ObslUp                   ; posun kurzoru nahoru
         jmp       short ObslPgUp
ObslPgU4:ret

ObslPgUp ENDP

; -----------------------------------------------------------------------------
;        kl vesa End - £plnˆ vpravo
; -----------------------------------------------------------------------------

ObslEnd  PROC      NEAR

         cmp       dh,8                     ; je konec © dku ?
         je        ObslEnd4                 ; je konec © dku
         call      ObslRght                 ; posun kurzoru vpravo
         jmp       short ObslEnd
ObslEnd4:ret

ObslEnd  ENDP

; -----------------------------------------------------------------------------
;        Page Down - £plnˆ dol–
; -----------------------------------------------------------------------------

ObslPgDn PROC      NEAR

         cmp       dl,2                     ; je spodn¡ © dek ?
         je        ObslPgD4                 ; je spodn¡ © dek
         call      ObslDwn                  ; posun kurzoru dol–
         jmp       short ObslPgDn           ; dal¨¡ posun
ObslPgD4:ret

ObslPgDn ENDP

; -----------------------------------------------------------------------------
;        kurzor nahoru
; -----------------------------------------------------------------------------

ObslUp   PROC      NEAR

         mov       al,ds:[Kurzor]           ; pozice kurzoru
         add       al,10                    ; zv˜¨en¡ © dku o 10 pozic
         add       dl,1                     ; posun ‡¡sla © dku
         cmp       al,100                   ; je p©ekro‡en okraj ?
         jb        ObslUp2                  ; okraj je¨tˆ nen¡ p©ekro‡en
         sub       al,80                    ; sn¡‘en¡ na spodn¡ okraj
         sub       dl,8
ObslUp2: mov       ds:[Kurzor],al           ; nov  pozice kurzoru
         ret

ObslUp   ENDP

; -----------------------------------------------------------------------------
;        kurzor vlevo
; -----------------------------------------------------------------------------

ObslLeft PROC      NEAR

         dec       byte ptr ds:[Kurzor]     ; sn¡‘en¡ pozice kurzoru
         dec       dh                       ; sn¡‘en¡ pozice
         jnz       ObslLft4                 ; nebyl p©echod p©es okraj
         add       byte ptr ds:[Kurzor],8   ; korekce na konec © dku
         add       dh,8
ObslLft4:ret

ObslLeft ENDP

; -----------------------------------------------------------------------------
;        kurzor vpravo
; -----------------------------------------------------------------------------

ObslRght PROC      NEAR

         inc       byte ptr ds:[Kurzor]     ; zv˜¨en¡ pozice kurzoru
         inc       dh                       ; zv˜¨en¡ pozice
         cmp       dh,9                     ; byl p©echod p©es okraj ?
         jne       ObslRgh4                 ; nebyl p©echod p©es okraj
         sub       byte ptr ds:[Kurzor],8   ; korekce na za‡ tek © dku
         sub       dh,8
ObslRgh4:ret

ObslRght ENDP

; -----------------------------------------------------------------------------
;        kurzor dol–
; -----------------------------------------------------------------------------

ObslDwn  PROC      NEAR

         mov       al,ds:[Kurzor]           ; pozice kurzoru
         sub       al,10                    ; sn¡‘en¡ ‡¡sla © dku
         sub       dl,1
         cmp       al,20                    ; je podte‡en¡ pod okraj ?
         ja        ObslDwn4                 ; nen¡ pod spodn¡m okrajem
         add       al,80                    ; korekce na horn¡ okraj
         add       dl,8
ObslDwn4:mov       ds:[Kurzor],al           ; nov  pozice kurzoru
         ret

ObslDwn  ENDP

; -----------------------------------------------------------------------------
;        Enter - polo‘en¡ figurky
; -----------------------------------------------------------------------------

ObslEnt  PROC      NEAR

; ------ polo‘en¡ figurky

         cmp       byte ptr ds:[VolTah],2   ; ‡ek  se na polo‘en¡ ?
         jne       ObslEnt2                 ; ne‡ek  se na polo‘en¡
         mov       bh,0
         mov       bl,ds:[Kurzor]           ; pozice kurzoru
         mov       al,ds:[bx+Mapa]          ; figurka na nov‚ pozici
         mov       ds:[OldFig],al           ; p–vodn¡ figurka
         test      al,7fh                   ; je nˆjak  figurka ?
         jz        ObslEnt0                 ; nen¡ figurka - OK
         xor       al,ds:[Figurka]          ; je to figurka spr vn‚ barvy ?
         jns       ObslEnt1                 ; je to ¨patn  figurka
ObslEnt0:mov       al,ds:[Kurzor]           ; pozice kurzoru
         mov       ds:[NewPoz],al           ; nov  pozice figurky
         mov       byte ptr ds:[VolTah],0   ; p©¡znak stavu klidu
ObslEnt1:ret

; ------ zvednut¡ figurky

ObslEnt2:mov       bh,0
         mov       bl,ds:[Kurzor]           ; pozice kurzoru
         mov       al,ds:[bx+Mapa]          ; p©en ¨en  figurka
         cmp       al,0                     ; je nˆjak  figurka ?
         je        ObslEnt5                 ; nen¡ figurka
         xor       al,ds:[Hrac]             ; je to figurka spr vn‚ barvy ?
         jns       ObslEnt5                 ; je to ¨patn  figurka
         mov       ds:[OldPoz],bl           ; v˜choz¡ pozice figurky
         mov       al,ds:[bx+Mapa]          ; p©en ¨en  figurka
         mov       ds:[Figurka],al          ; p©en ¨en  figurka
         mov       byte ptr ds:[bx+Mapa],0  ; zru¨en¡ figurky na ¨achovnici
         mov       byte ptr ds:[VolTah],2   ; p©¡znak ‡ek n¡ na polo‘en¡
ObslEnt5:ret

ObslEnt  ENDP


;==========================================================================
;        test, zda je nˆjak  figurka, s kterou lze t hnout
;==========================================================================
  
l_08A2   PROC      NEAR

         mov       al,ds:[Protihr]           ; barva protihr ‡e
         call      TestFig                   ; test okol¡ aktivn¡ figurky
         mov       ds:[d_09D7],al           
         mov       dx,ds:[d_09CC]           ; ukazatel v z sobn¡ku tah–
         mov       bx,ds:[d_09C2]           
         mov       ds:[bx+2],dx             
         add       bx,4                     
         mov       ds:[d_09C2],bx           
         mov       ds:[d_09CA],bx           
         mov       bx,15h                   ; prvn¡ pol¡‡ko ¨achovnice

l_08C4:  mov       word ptr ds:[d_09B2],bx  ; ukazatel v ¨achovnici
         mov       al,ds:[bx+Mapa]        ; k men na ¨achovnici
         cmp       al,0                     ; je pr zdn‚ pole ?
         je        l_08E0                   ; pr zdn‚ pole - dal¨¡
         cmp       al,0FFh                  ; mimo ¨achovnici ?
         je        l_08E0                   ; je mimo - konec
         mov       ds:[FigTst1],al           ; testovan  figurka
         xor       al,ds:[Protihr]           ; je to figurka hr ‡e ?
         js        l_08E0                   ; nen¡ - dal¨¡
         call      l_0A30                   ; test, zda lze s figurkou t hnout

l_08E0:  mov       bx,word ptr ds:[d_09B2]
         inc       bx
         cmp       bl,63h
         jb        l_08C4
         ret

l_08A2   ENDP
  
         db        0
  
; -----------------------------------------------------------------------------
;             test okol¡ figurky protihr ‡e (barva hr ‡e AL)
; -----------------------------------------------------------------------------
  
TestFig  PROC      NEAR

         rol       al,1                     ; barva -> bit 0
         and       ax,1                     ; barva figurky
         mov       bx,ax                    ; BX <- barva figurky (1=b¡l )
         mov       bl,ds:[bx+KurzB]         ; pozice kurzoru protihr ‡e
         mov       bh,0                     ; BH <- 0
         mov       word ptr ds:[PozTst],bx  ; pracovn¡ pozice hr ‡e
         mov       al,ds:[bx+Mapa]          ; figurka na pozici
         mov       ds:[FigTst1],al          ; figurka p©i testu
         and       al,7                     
         mov       ds:[FigTst2],al          ; figurka p©i testu
         call      TestOkol                 ; test okol¡ figurky
         ret

TestFig  ENDP
  
; -----------------------------------------------------------------------------
;                     Inicializace ¨achovnice
; -----------------------------------------------------------------------------

InitPole PROC      NEAR

; ------ vymaz n¡ ¨achovnice

         cld                                
         mov       di,offset Mapa           ; mapa ¨achovnice
         mov       si,offset MapaIni        ; inicializa‡n¡ rozm¡stˆn¡
         mov       cx,offset(Mapa0-Mapa)/2  ; d‚lka mapy ¨achovnice (slov)
         rep       movsw                    ; inicializace mapy ¨achovnice

; ------ inicializace ukazatel–

         mov       byte ptr ds:[KurzB],25   ; pozice kurzoru b¡l‚ho
         mov       byte ptr ds:[KurzC],95   ; pozice kurzoru ‡ern‚ho
         mov       byte ptr ds:[DamaB],24   ; b¡l  d ma
         mov       byte ptr ds:[DamaC],94   ; ‡ern  d ma

; ------ pozice kurzoru hr ‡e

         mov       al,25                    ; kurzor b¡l‚ho
         test      byte ptr ds:[Hrac],80h   ; je hr ‡ b¡l˜ ?
         jnz       InitPol2                 ; je b¡l˜
         mov       al,95                    ; pozice kurzoru ‡ern‚ho
InitPol2:mov       ds:[HracPoz],al          ; pozice kurzoru hr ‡e
         ret

InitPole ENDP

;==========================================================================
;        omezen¡ ‡¡sla AL na CH (absolutnˆ)
;==========================================================================
  
l_09A0   PROC      NEAR

                                          ;* kontrola p©ekro‡en¡ ‡¡sla AL
         and       al,al                    ; test AL
         lahf                               ; £schova registru p©¡znak–
         jns       l_09A7                   ; je kladn‚ ‡¡slo
         neg       al                       ; absolutn¡ hodnota ‡¡sla
l_09A7:  cmp       al,ch                    
         jb        l_09AD                   
         mov       al,ch                    
l_09AD:  sahf                               ; n vrat registru p©¡znak–
         jns       l_09B2                   ; bylo to kladn‚ ‡¡slo
         neg       al                       ; n vrat z porn‚ho ‡¡sla
l_09B2:  ret

l_09A0   ENDP
  
;==========================================================================
;        proveden¡ jednoho tahu
;==========================================================================
  
l_09B4   PROC      NEAR

         mov       si,ds:[d_09C4]           ; ukazatel v bufferu tah–
l_09B8:  mov       bh,0                     
         mov       dh,ds:[si+4]             ; c¡lov  figurka
         and       byte ptr ds:[OldFig],7
         mov       bl,ds:[si+2]             ; v˜choz¡ pozice
         mov       di,bx                    ; v˜choz¡ pozice
         mov       bl,ds:[si+3]             ; c¡lov  pozice
         mov       si,bx                    ; c¡lov  pozice

         push      ax
         mov       al,ds:[si+Mapa]
         mov       ds:[OldFig],al          ; p–vodn¡ figurka
         pop       ax

         mov       dl,ds:[di+Mapa]        ; figurka, kter  t hne
         mov       bl,dl                    ; £schova figurky k t hnut¡
         rol       bl,1                     
         and       bx,1                     ; barva figurky
         nop
         test      dh,20h                   ; n hrada pˆ¨ ka d mou ?
         jnz       l_0A07                   ; je n hrada pˆ¨ ka d mou
         mov       al,dl                    ; aktivn¡ figurka
         and       al,7                     ; zru¨en¡ barvy
         cmp       al,5                     ; je d ma ?
         je        l_0A0F                   ; je d ma
         cmp       al,6                     ; je kr l ?
         je        l_0A17                   ; je kr l

l_09E4:  or        dl,8
         mov       ds:[si+Mapa],dl        ; aktivn¡ figurka na nov‚ pozici
         mov       byte ptr ds:[di+Mapa],0; zru¨en¡ aktivn¡ figurky
         test      dh,40h                   ; bude dal¨¡ tah ?
         jnz       l_0A27                   ; bude dal¨¡ tah (ro¨ da)
         mov       al,dh                    ; ru¨en  figurka
         and       al,7                     ; zru¨en¡ barvy
         cmp       al,5                     ; byla to d ma ?
         jne       l_0A06                   ; nebyla to d ma
         xor       bx,1
         nop
         mov       byte ptr ds:[bx+DamaB],0; zru¨en¡ pozice d my
l_0A06:  ret

; ------ n hrada pˆ¨ ka d mou

l_0A07:  and       dl,0F8h                  ; zru¨en¡ figurky
         or        dl,5                     ; n hrada d mou
         jmp       short l_09E4

; ------ tah d mou - nov  pozice

l_0A0F:  mov     ax,si                      ; c¡lov  pozice figurky
         mov     ds:[bx+DamaB],al          ; nov  pozice d my
         jmp     short l_09E4

; ------- tah kr lem

l_0A17:  test    dh,40h                     ; byla to ro¨ da ?
         jz      l_0A1F                     ; nebyla ro¨ da
         or      dl,10h                     ; p©¡znak 2. tahu ro¨ dy

l_0A1F:  mov     ax,si                      
         mov     ds:[bx+KurzB],al          ; nov  pozice kurzoru
         jmp     short l_09E4

l_0A27:  mov     si,ds:[d_09C4]             ; ukazatel v bufferu tah–
         add     si,6
         jmp     l_09B8

l_09B4   ENDP

;==========================================================================
;        test, zda lze s figurkou t hnout
;==========================================================================
  
l_0A30   PROC      NEAR

; ------ p©¡prava po‡tu a adresy mo‘n˜ch tah– figurky

         mov       al,ds:[FigTst1]           ; testovan  figurka
         and       al,87h                   ; figurka s barvou
         cmp       al,81h                   ; je ‡ern˜ pˆ¨ k ?
         jne       l_0A3B                   ; nen¡ ‡ern˜ pˆ¨ k
         dec       al                       ; n hradn˜ ‡¡slo figurky 0
l_0A3B:  and       al,7                     ; zru¨en¡ barvy
         mov       ds:[FigTst2],al           ; figurka
         mov       bh,0                     
         mov       bl,al                    ; figurka
         mov       ch,ds:[bx+NumSmer]        ; po‡et mo‘n˜ch tah–
         mov       bl,ds:[bx+OfsSmer]        ; adresa mo‘n˜ch tah–
         mov       di,bx                    ; adresa mo‘n˜ch tah– figurky

; --------- test jednoho tahu figurky

l_0A4E:  mov       cl,ds:[di+TabSmer]        ; mo‘n˜ smˆr tahu figurky
         mov       al,ds:[d_09B2]           ; pozice figurky
         mov       ds:[PozTah],al           ; pozice p©i pokusu o tah

; ------- test jednoho kroku

l_0A58:  call      PokTah                   ; pokus o tah dan˜m smˆrem

         cmp       al,2                     ; je skok na vlastn¡ nebo ven ?
         jae       l_0A7A                   ; skok na vlastn¡ nebo ven - chyba

         cmp       al,0                     ; je pr zdn‚ ?
         lahf                               ; £schova p©¡znak–
         mov       al,ds:[FigTst2]           ; figurka
         cmp       al,1                     ; je pˆ¨ k ?
         jbe       l_0A8A                   ; pˆ¨ k nebo pr zdn‚ pol¡‡ko
         call      l_0000                   ; ulo‘en¡ definice do z sobn¡ku tah–
         sahf                               ; n vrat p©¡znak–
         jnz       l_0A7A                   ; nen¡ pr zdn‚ pol¡‡ko
         mov       al,ds:[FigTst2]           ; figurka
         cmp       al,6                     ; je kr l ?
         je        l_0A7A                   ; je kr l - nelze dal¨¡ krok
         cmp       al,3                     ; je st©elec, vˆ‘ nebo d ma ?
         jae       l_0A58                   ; st©elec, vˆ‘ nebo d ma-dal¨¡ krok

l_0A7A:  inc       di
         dec       ch
         jnz       l_0A4E
         mov       al,ds:[FigTst2]
         cmp       al,6
         jne       l_0A89
         call      l_01DE                   ; test ro¨ dy
l_0A89:  ret

l_0A8A:  cmp       ch,3
         jb        l_0ABB
         jz        l_0AB3
         sahf                               ; jinak je prvn¡ tah - p©¡mo
         jnz       l_0A7A                   ; nen¡ pr zdn‚ pole - chyba
         mov       al,ds:[PozTah]           ; pozice p©i pokusu o tah
         cmp       al,5Bh                                ; '['
         jae       l_0A9F
         cmp       al,1Dh
         jae       l_0AA4
l_0A9F:  or        byte ptr ds:[CilFig1],20h ; p©¡znak posl. ©ady pˆ¨ kem
l_0AA4:  call      l_0000                   ; ulo‘en¡ definice do z sobn¡ku tah–
         inc       di
         dec       ch
         test      byte ptr ds:[FigTst1],8
         jz        l_0A58                   ; dal¨¡ krok
         jnz       l_0A7A
l_0AB3:  sahf
         jnz       l_0A7A
l_0AB6:  call      l_0000                   ; ulo‘en¡ definice do z sobn¡ku tah–
         jmp       short l_0A7A

l_0ABB:  sahf
         jz        l_0AD0
         mov       al,ds:[PozTah]           ; pozice p©i pokusu o tah
         cmp       al,5Bh                                ; '['
         jae       l_0AC9
         cmp       al,1Dh
         jae       l_0AB6
l_0AC9:  or        byte ptr ds:[CilFig1],20h              ; ' '
         jmp       short l_0AB6

l_0AD0:  call      l_0492
         jmp       short l_0A7A

l_0A30   ENDP
  
  
l_0AD6   PROC      NEAR

         inc       bp
         xchg      ch,cl
         xchg      di,si
         mov       ax,0
         cmp       ch,0
         je        l_0AF5
         dec       ch
         cld       
l_0AE6:  scasw
         jz        l_0AE6
         dec       di
         dec       di
         mov       ax,ds:[di]
         mov       ds:[di],ah
         mov       byte ptr ds:[di+1],0
         add       al,al
l_0AF5:  ret

l_0AD6   ENDP

;==========================================================================
;                  Pokus o tah dan˜m smˆrem
;==========================================================================
  
PokTah   PROC      NEAR
                                               ;* pokus o tah dan˜m smˆrem
                                                 ; VSTUP: CL=p©¡rustek skoku
                                                 ; VSTUP: AL=0 - pr zdn‚ pole
                                                 ;         AL=1 - na soupe©e
                                                 ;         AL=2 - na vlastn¡
                                                 ;         AL=3 - tah ven

; ------ z¡sk n¡ obsahu c¡lov‚ho pol¡‡ka

         mov       bx,word ptr ds:[PozTah]  ; pozice p©i pokusu o tah
         add       bl,cl                    ; zv˜¨en¡ pozice o tah
         mov       word ptr ds:[PozTah],bx  ; nov  pozice p©i pokusu o tah
         mov       al,ds:[bx+Mapa]          ; obsah nov‚ pozice

; ------ test, zda je skok mimo ¨achovnici

         cmp       al,0FFh                  ; je zak zan  oblast ?
         je        PokTah2                  ; je tah ven z ¨achovnice

; ------ £schova obsahu c¡lov‚ho pol¡‡ka

         mov       ds:[CilFig1],al          ; p–vodn¡ obsah na pol¡‡ku
         and       al,7                     ; zru¨en¡ p©¡znaku barvy
         mov       ds:[CilFig2],al          ; ru¨en  figurka
         jz        PokTah3                  ; pr zdn‚ pol¡‡ko

; ------ test, zda je skok na vlastn¡ figurku

         mov       al,ds:[CilFig1]          ; p–vodn¡ obsah pol¡‡ka
         xor       al,ds:[FigTst1]          ; test barvy figurky
         jns       PokTah1                  ; stejn  barva - chyba
         mov       al,1                     ; skok na soupe©e - OK
         ret       

; ------ skok na vlastn¡

PokTah1: mov       al,2                     ; p©¡znak - skok na vlastn¡
         ret       

; ------ skok ven z ¨achovnice

PokTah2: mov       al,3                     ; p©¡znak - tah je ven
PokTah3: ret

PokTah   ENDP

;==========================================================================
;        hodnocen¡ jednoho stavu ¨achovnice
;==========================================================================
  
l_0B24   PROC      NEAR

         mov       word ptr ds:[d_09C0],0
         mov       si,0
l_0B2D:  mov       bl,ds:[si+KurzB]        ; pozice kurzoru b¡l‚ho
         cmp       bl,0
         jne       l_0B39
         jmp       l_0BEE

l_0B39:  cmp       bl,0FFh
         jne       l_0B3F
         ret       

l_0B3F:  mov       bh,0
         mov       word ptr ds:[PozTst],bx  ; testovan  pozice
         mov       al,ds:[bx+Mapa]        ; vektor ¨achovnice
         mov       ds:[FigTst1],al           ; testovan  figurka
         mov       ch,8                     ; po‡et pokus–
         mov       di,0                     
l_0B51:  mov       al,ds:[PozTst]           ; testovan  pozice
         mov       ds:[PozTah],al           ; pozice p©i pokusu o tah
         mov       byte ptr ds:[d_09B8],0
         mov       cl,ds:[di+TabSmer]

l_0B60:  call      PokTah                   ; pokus o tah dan˜m smˆrem
         cmp       al,0                     
         je        l_0B60                   ; je pr zdn‚ pole - dal¨¡
         cmp       al,3                     
         je        l_0BE6                   ; tah ven
         cmp       al,2                     ; skok na vlastn¡
         je        l_0B8E

         cmp       byte ptr ds:[d_09B8],0
         je        l_0BE6
         mov       al,ds:[CilFig2]           ; p–vodn¡ figurka
         cmp       al,5                     ; byla to d ma ?
         je        l_0B9D                   ; byla to d ma
         cmp       ch,5                     
         jb        l_0B88                   
         cmp       al,3                     ; byl to st©elece ?
         jne       l_0BE6                   ; nebyl to st©elec
         jz        l_0BD2                   ; byl to st©elec - OK

l_0B88:  cmp       al,4                     ; byla to vˆ‘ ?
         jne       l_0BE6                   ; nebyla to vˆ‘
         jz        l_0BD2                   ; byla to vˆ‘

l_0B8E:  cmp       byte ptr ds:[d_09B8],0
         jne       l_0BE6
         mov       al,ds:[PozTah]           ; pozice p©i pokusu o tah
         mov       ds:[d_09B8],al
         jmp       short l_0B60

l_0B9D:  mov       al,ds:[FigTst1]           ; testovan  figurka
         and       al,7                     ; zru¨en¡ barvy
         cmp       al,5                     ; byla to d ma ?
         jne       l_0BD2                   ; nebyla to d ma - dobr˜ tah
         push      cx
         push      di
         mov       al,0
         mov       cx,0Eh
         lea       di,ds:[PocFigC]
         cld       
         rep       stosw
         mov       byte ptr ds:[FigTst2],7
         call      TestOkol                   ; test okol¡ figurky
         pop       di
         pop       cx
         mov       al,ds:[PocFigC]
         sub       al,ds:[PocFigB]
         test      byte ptr ds:[FigTst1],80h
         jz        l_0BCE
         neg       al
l_0BCE:  dec       al
         jns       l_0BE6
l_0BD2:  mov       bx,ds:[d_09C0]
         inc       bx
         mov       ds:[d_09C0],bx
         mov       ds:[bx+d_016F],cl
         mov       al,ds:[d_09B8]
         mov       ds:[bx+d_0165],al
l_0BE6:  inc       di
         dec       ch
         jz        l_0BEE
         jmp       l_0B51
l_0BEE:  inc       si
         jmp       l_0B2D

l_0B24   ENDP

;==========================================================================
;                       Tah hr ‡e
;==========================================================================
;þ

TahHrac  PROC      NEAR

; ------ automatick  hra - n hrada po‡¡ta‡em

         cmp       byte ptr ds:[Automat],0  ; je automatick  hra ?
         je        TahHrac2                 ; nen¡ automatick  hra
         xor       byte ptr ds:[Hrac],80h   ; zmˆna barvy hr ‡e
;         xor       byte ptr ds:[Protihr],80h ; zmˆna barvy po‡¡ta‡e
         call      TahPoc                   ; tah po‡¡ta‡e
         xor       byte ptr ds:[Hrac],80h   ; n vrat barvy hr ‡e
;         xor       byte ptr ds:[Protihr],80h ; n vrat barvy po‡¡ta‡e
         ret

; ------ p©¡prava aktu ln¡ pozice kurzoru

TahHrac2:mov       byte ptr ds:[Hraje],0    ; p©¡znak, ‘e hraje hr ‡

         mov       al,ds:[HracPoz]          ; pozice hr ‡e
         mov       ds:[Kurzor],al           ; aktu ln¡ pozice kurzoru

; ------ v˜zva k proveden¡ tahu

         mov       si,offset TahTxt
         call      DispHlas                 ; zobrazen¡ hl ¨en¡

; ------ zvednut¡ figurky

TahHrac4:mov       byte ptr ds:[VolTah],1   ; p©¡znak ‡ek n¡ na DEL
         call      KurzOff                  ; vypnut¡ kurzoru

; ------ ‡ek n¡ na zvednut¡ figurky

TahHrac5:mov       bh,0                     ; BH <- 0
         mov       bl,ds:[Kurzor]           ; pozice kurzoru
         mov       dl,ds:[bx+Mapa]          ; figurka na pozici kurzoru
         mov       dh,dl                    ; £schova figurky
         xor       dh,80h                   ; inverzn¡ figurka
         mov       ch,1                     ; po‡et cykl– = 1
         call      BlikKurz                 ; obsluha kurzoru
         cmp       byte ptr ds:[VolTah],1   ; ‡ek  se na zvednut¡ ?
         je        TahHrac5                 ; ‡ek n¡ na zvednut¡ figurky

; ------ ‡ek n¡ na polo‘en¡ figurky

TahHrac6:mov       bh,0                     ; BH <- 0
         mov       bl,ds:[Kurzor]           ; pozice kurzoru
         mov       dl,ds:[bx+Mapa]          ; figurka na pozici kurzoru
         mov       dh,ds:[Figurka]          ; p©en ¨en  figurka
         mov       ch,1                     ; po‡et cykl– = 1
         call      BlikKurz                 ; obsluha kurzoru
         cmp       byte ptr ds:[VolTah],2   ; ‡ek  se na polo‘en¡ ?
         je        TahHrac6                 ; ‡ek n¡ na polo‘en¡ figurky

; ------ test navr cen¡ figurky

         mov       bh,0                     ; BH <- 0
         mov       bl,ds:[OldPoz]           ; v˜choz¡ pozice figurky
         mov       al,ds:[Figurka]          ; p©en ¨en  figurka
         mov       ds:[bx+Mapa],al          ; navr cen¡ figurky zpˆt
         mov       dl,bl                    ; v˜choz¡ pozice p©en ¨en¡
         mov       dh,ds:[NewPoz]           ; nov  pozice figurky
         cmp       dl,dh                    ; je stejn  pozice ?
         je        TahHrac4                 ; figurka navr cena - znovu

; ------ test spr vnosti tahu, n vrat tahu

         call      TestTah                  ; test spr vnosti tahu + proveden¡
         jnc       TahHrac7                 ; tah je OK - nov  pozice
         mov       al,ds:[OldPoz]           ; v˜choz¡ pozice figurky
         mov       ds:[Kurzor],al           ; pozice kurzoru
         mov       dl,ds:[Figurka]          ; p©en ¨en  figurka
         call      DispPol                  ; zobrazen¡ pol¡‡ka
         jmp       TahHrac4                 ; nov  volba tahu

; ------ zobrazen¡ nov‚ pozice figurky

TahHrac7:mov       al,ds:[NewPoz]           ; nov  pozice figurky
         mov       ds:[HracPoz],al          ; £schova nov‚ pozice kurzoru
         mov       bh,0                     ; BH <- 0
         mov       bl,al                    ; BX <- nov  pozice figurky
         mov       dl,ds:[bx+Mapa]          ; vektor ¨achovnice
         call      DispPol                  ; zobrazen¡ pol¡‡ka

         mov       byte ptr ds:[Rosad],0
         call      Rosada                   ; volba tahu pro ro¨ du

; ------ zobrazen¡ proveden‚ho tahu

         call      DispMov                  ; zobrazen¡ proveden‚ho tahu
         call      DispCR                   ; od© dkov n¡ textu
         ret

TahHrac   ENDP

;==========================================================================
;       nalezen¡ dal¨¡ho tahu
;==========================================================================
  
l_0CA8   PROC      NEAR

         mov       al,0
         mov       ds:[d_09DE],al
         mov       ds:[d_09DA],al
         mov       ds:[d_09DB],al
         mov       ds:[d_09DC],al
         mov       ds:[d_09DD],al
         mov       ds:[d_09E1],al
         mov       byte ptr ds:[FigTst2],7
         mov       bx,15h
l_0CC4:  mov       word ptr ds:[PozTst],bx
         mov       al,ds:[bx+Mapa]        ; vektor ¨achovnice
         cmp       al,0FFh
         jne       l_0CD3
         jmp       l_0D90
l_0CD3:  mov       cl,al
         mov       ds:[FigTst1],al
         and       al,7
         mov       ds:[d_09BE],al
         cmp       al,1
         jbe       l_0D1C
         cmp       al,4
         jb        l_0D0A
         cmp       al,6
         je        l_0CF2
         cmp       word ptr ds:[CitTah],7   ; ‡¡ta‡ tah–
         jb        l_0D03
         jnc       l_0D03
l_0CF2:  test      cl,10h
         jz        l_0D03
         mov       al,6
         test      cl,80h
         jz        l_0D18
         neg       al
         jmp       short l_0D18
         nop
l_0D03:  test      cl,8
         jz        l_0D1C
         jnz       l_0D0F
l_0D0A:  test      cl,8
         jnz       l_0D1C
l_0D0F:  mov       al,2
         test      cl,80h
         jnz       l_0D18
         neg       al
l_0D18:  add       ds:[d_09DA],al
l_0D1C:  mov       al,0
         mov       cx,0Eh
         lea       di,ds:[PocFigC]
         cld       
         rep       stosw
         call      TestOkol                   ; test okol¡ figurky
         mov       al,ds:[PocFigC]
         sub       al,ds:[PocFigB]
         add       ds:[d_09DA],al
         cmp       byte ptr ds:[FigTst1],0
         je        l_0D90
         call      l_0F9E
         cmp       dl,0
         je        l_0D81
         dec       dh
         mov       al,ds:[FigTst1]
         xor       al,ds:[Protihr]
         js        l_0D6C
         cmp       dl,ds:[d_09DB]
         jb        l_0D81
         mov       ds:[d_09DB],dl
         mov       bx,ds:[d_09C4]           ; ukazatel v bufferu tah–
         mov       al,ds:[PozTst]
         cmp       al,ds:[bx+3]
         jne       l_0D81
         mov       ds:[d_09E1],al
         jmp       short l_0D81

l_0D6C:  mov       al,dl
         cmp       al,ds:[d_09DC]
         jb        l_0D78
         xchg      al,ds:[d_09DC]
l_0D78:  cmp       al,ds:[d_09DD]
         jb        l_0D81
         mov       ds:[d_09DD],al
l_0D81:  mov       al,dh
         test      byte ptr ds:[FigTst1],80h
         jz        l_0D8C
         neg       al
l_0D8C:  add       ds:[d_09DE],al
l_0D90:  mov       bx,word ptr ds:[PozTst]
         inc       bx
         cmp       bx,63h
         jae       l_0D9D
         jmp       l_0CC4
l_0D9D:  cmp       byte ptr ds:[d_09E1],0
         je        l_0DAF
         mov       al,ds:[d_09DD]
         mov       ds:[d_09DC],al
         mov       byte ptr ds:[d_09DD],0
l_0DAF:  mov       al,ds:[d_09DB]
         cmp       al,0
         je        l_0DB8
         dec       al
l_0DB8:  mov       ch,al
         mov       al,ds:[d_09DC]
         cmp       al,0
         je        l_0DCC
         mov       al,ds:[d_09DD]
         cmp       al,0
         je        l_0DCC
         dec       al
         shr       al,1
l_0DCC:  sub       al,ch
         test      byte ptr ds:[Protihr],80h
         jz        l_0DD7
         neg       al
l_0DD7:  add       al,ds:[d_09DE]
         sub       al,ds:[d_09E0]
         mov       ch,1Eh                   ; max. hodnota = 30
         call      l_09A0                   ; omezen¡ ‡¡sla AL na CH
         mov       dl,al
         mov       al,ds:[d_09DA]
         sub       al,ds:[d_09DF]
         cmp       byte ptr ds:[d_09E1],0
         je        l_0DF6
         mov       al,0
l_0DF6:  mov       ch,6                     ; max. hodnota = 6
         call      l_09A0                   ; omezen¡ ‡¡sla AL na CH
         shl       dl,1
         shl       dl,1
         add       al,dl
         test      byte ptr ds:[Protihr],80h
         jnz       l_0E0A
         neg       al
l_0E0A:  add       al,80h
         mov       ds:[d_09D9],al
         mov       bx,ds:[d_09C4]           ; ukazatel v bufferu tah–
         mov       [bx+5],al
         ret

l_0CA8   ENDP

;==========================================================================
;       posun tahu
;==========================================================================
  
l_0E88   PROC      NEAR

         mov       cx,ds:[d_09C2]
         mov       di,0
l_0E8F:  mov       bx,cx
         mov       cx,[bx]
         mov       [bx],di
         cmp       cx,0
         jne       l_0E9B
         ret       

l_0E9B:  mov       ds:[d_09C4],cx           ; ukazatel v bufferu tah–
         call      l_050A
         mov       bx,ds:[d_09C2]
         mov       cx,ds:[d_09C4]           ; ukazatel v bufferu tah–
l_0EAA:  mov       di,ds:[bx]
         cmp       di,0
         je        l_0EB9
         mov       al,ds:[d_09D9]
         cmp       al,ds:[di+5]
         jae       l_0EBD
l_0EB9:  mov       ds:[bx],cx
         jmp       short l_0E8F
l_0EBD:  mov       bx,di
         jmp       short l_0EAA

l_0E88   ENDP
  
         db        0
  
;==========================================================================
;        n vrat tahu z bufferu tah–
;==========================================================================
  
l_0EC2   PROC      NEAR

         mov       si,ds:[d_09C4]           ; ukazatel v bufferu tah–

l_0EC6:  mov       bh,0                     
         mov       dh,ds:[si+4]             ; p–vodn¡ obsah nov‚ho pole
         mov       bl,ds:[si+2]             ; v˜choz¡ pozice tahu
         mov       di,bx                    ; v˜choz¡ pozice tahu
         mov       bl,ds:[si+3]             ; c¡lov  pozice tahu
         mov       si,bx                    ; c¡lov  pozice tahu
         mov       dl,ds:[si+Mapa]        ; figurka, s kterou se t hlo
         mov       bl,dl                    ; figurka k t hnut¡
         rol       bl,1                     ; figurka * 2
         and       bx,1                     ; barva figurky
         test      dh,20h                   ; byla n hrada pˆ¨ ka d mou ?
         jnz       l_0F1E                   ; byla n hrada pˆ¨ ka d mou
         mov       al,dl                    ; figurka, kter  t hla
         and       al,7                     ; zru¨en¡ barvy
         cmp       al,5                     ; byla to d ma ?
         je        l_0F26                   ; t hla d ma
         cmp       al,6                     ; t hl kr l ?
         je        l_0F2E                   ; t hl kr l
                                            
l_0EF2:  test      dh,10h
         jz        l_0EFA                   
         and       dl,0F7h                  
l_0EFA:  mov       ds:[di+Mapa],dl        ; ulo‘en¡ p–vodn¡ figurky
         mov       al,dh                    ; p–vodn¡ figurka
         and       al,8Fh                   ; zru¨en¡ p©¡znak–
         mov       ds:[si+Mapa],al        ; n vrat ru¨en‚ figurky
         test      dh,40h                   ; bude dal¨¡ tah ?
         jnz       l_0F3E                   ; n vrat dal¨¡ho tahu
         mov       al,dh                    ; ru¨en  figurka
         and       al,7                     ; zru¨en¡ barvy
         cmp       al,5                     ; je to d ma ?
         jne       l_0F1D                   ; nen¡ to d ma
         mov       ax,si                    ; pozice d my
         xor       bx,1                     
         mov       ds:[bx+DamaB],al        ; p–vodn¡ pozice d my
l_0F1D:  ret

; ------ byla n hrada pˆ¨ ka d mou - n vrat pˆ¨ ka

l_0F1E:  and       dl,0F8h                  ; zru¨en¡ figurky
         or        dl,1                     ; n hrada pˆ¨ kem
         jmp       short l_0EF2

; ----- t hla d ma

l_0F26:  mov       ax,di                    ; p–vodn¡ pozice d my
         mov       ds:[bx+DamaB],al        ; n vrat pozice d my
         jmp       short l_0EF2

; ----- t hne kr l

l_0F2E:  test      dh,40h
         jz        l_0F36
         and       dl,0EFh
l_0F36:  mov       ax,di
         mov       ds:[bx+KurzB],al        ; pozice kurzoru b¡l‚ho
         jmp       short l_0EF2

; ------ dal¨¡ tah

l_0F3E:  mov       si,ds:[d_09C4]           ; ukazatel v bufferu tah–
         add       si,6                     ; zv˜¨en¡ pozice v bufferu
         jmp       l_0EC6

l_0EC2   ENDP

;==========================================================================
;     Test spr vnosti tahu a proveden¡ tahu (DL=v˜choz¡/DH=c¡lov  pozice)
;==========================================================================
;þ
TestTah  PROC      NEAR

; ------ p©¡prava registr–

         push      word ptr ds:[d_09C4]     ; ukazatel v bufferu tah–
         mov       al,ds:[Hrac]             ; 80=hr ‡ m  b¡l‚, 00=‡ern‚
         xor       al,80h                   ; zmˆna p©¡znaku barvy
         mov       ds:[Protihr],al          ; po‘adovan  barva protihr ‡e
         mov       word ptr ds:[d_09C2],offset d_018A-2 ; ukazatel v bufferu
         mov       word ptr ds:[d_09CC],offset d_05b2 ; ukazatel v z sobn¡ku

; ------ test, zda m  hr ‡ dal¨¡ tah

         push      dx
         call      l_08A2                   ; test, zda m  hr ‡ dal¨¡ tah
         pop       dx                       


         lea       bx,ds:[d_05B2]
l_0F6E:  cmp       dl,ds:[bx+2]             
         jne       l_0F78                   
         cmp       dh,ds:[bx+3]             
         je        l_0F81                   
l_0F78:  mov       bx,ds:[bx]               
         cmp       bx,0                     
         jne       l_0F6E                   
         jz        l_0F98                   
l_0F81:  mov       ds:[d_09C4],bx           ; ukazatel v bufferu tah–
         call      l_09B4                   ; proveden¡ jednoho tahu

         mov       al,ds:[Protihr]           ; barva po‡¡ta‡e
         call      TestFig                   ; test okol¡ aktivn¡ figurky
         cmp       al,0                     
         jne       l_0F95                   

         pop       ax                       
         clc                                
         ret                                

l_0F95:  call      l_0EC2                   ; n vrat tahu z bufferu tah–
l_0F98:  pop       word ptr ds:[d_09C4]     ; ukazatel v bufferu tah–
         stc                                ; p©¡znak chyby - nepovolen˜ tah
         ret

TestTah   ENDP

;==========================================================================
;       obodov n¡ jednoho tahu
;==========================================================================
  
l_0F9E   PROC      NEAR

         lea       di,ds:[BodFigC]
         lea       si,ds:[BodFigB]
         mov       ch,ds:[PocFigC]
         mov       cl,ds:[PocFigB]
         test      byte ptr ds:[FigTst1],80h
         jz        l_0FB9
         xchg      di,si
         xchg      ch,cl
l_0FB9:  mov       bp,0
         mov       dl,0
         mov       bx,word ptr ds:[d_09BE]
         mov       dh,ds:[bx+TabBod]
         shl       dh,1
         mov       bh,dh
         call      l_0AD6
         jz        l_0FFC
l_0FCF:  mov       bl,al
         call      l_0AD6
         jz        l_0FEA
         cmp       bh,bl
         jae       l_0FEA
l_0FDA:  cmp       al,bl
         jb        l_0FFC                            ;*
         call      l_0AD6
         jz        l_0FFC                            ;*
         mov       bl,al
         call      l_0AD6
         jnz       l_0FDA
l_0FEA:  test      bp,1
         jz        l_0FF2                            ;*
         neg       bh
l_0FF2:  add       dl,bh
         cmp       al,0
         je        l_0FFC
         mov       bh,bl
         jmp       short l_0FCF
l_0FFC:  ret

l_0F9E   ENDP

; -----------------------------------------------------------------------------
;        vymaz n¡ obrazovky
; -----------------------------------------------------------------------------

Clear    PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      di
         push      es

; ------ vymaz n¡ obrazovky

         mov       cx,25*80                 ; po‡et znak– celkem
         mov       es,ds:[SegmVRAM]         ; segment videopamˆti
         xor       di,di
         cld
         mov       ax,720h                  ; znak mezery k vymaz n¡
         rep       stosw                    ; vymaz n¡ obrazovky

; ------ nastaven¡ kurzoru

         mov       bh,0
         mov       ah,2
         xor       dx,dx
         call      Int10P                   ; nastaven¡ pozice kurzoru

; ------ n vrat registr–

         pop       es
         pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Clear    ENDP

; -----------------------------------------------------------------------------
;        ‡ek n¡ na hodinov˜ impuls
; -----------------------------------------------------------------------------

Cekej    PROC      NEAR

         push      ax
         push      ds

         xor       ax,ax
         mov       ds,ax
         mov       ax,ds:[46ch]             ; ‡asova‡
Cekej2:  sti
         cmp       ax,ds:[46ch]
         je        Cekej2                   ; ‡ek n¡ na zmˆnu hodin

         pop       ds
         pop       ax
         ret

Cekej    ENDP

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

; -----------------------------------------------------------------------------
;        vstup znaku z kl vesnice
; -----------------------------------------------------------------------------

InpChr   PROC      NEAR

; ------ vstup znaku z kl vesnice

         sti
         push      ax
         mov       ah,0
         int       16h                      ; vstup znaku z kl vesnice
         mov       bx,ax                    ; znak z kl vesnice
         pop       ax

; ------ n hrada Ctrl-Break kl vesou ESC

         or        bx,bx                    ; je Ctrl-Break ?
         jnz       InpChr2                  ; nen¡ Ctrl-Break
         mov       bx,11bh                  ; n hrada kl vesou Esc

; ------ konverze na velk‚ p¡smeno

InpChr2: cmp       bl,"a"
         jb        InpChr3
         cmp       bl,"z"
         ja        InpChr3
         sub       bl,32                    ; konverze na velk‚ p¡smeno

; ------ £prava ASCII znak–

InpChr3: cmp       bl,0
         je        InpChr4                  ; nen¡ ASCII znak
         mov       bh,0

InpChr4: ret

InpChr   ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ kurzoru
; -----------------------------------------------------------------------------

SetKurz  PROC      NEAR

         push      ax
         push      bx
         push      dx

         mov       bh,0
         mov       ah,2
         call      Int10P

         pop       dx
         pop       bx
         pop       ax
         ret

SetKurz  ENDP

; -----------------------------------------------------------------------------
;        vypnut¡ kurzoru
; -----------------------------------------------------------------------------

KurzOff  PROC      NEAR

         push      ax
         push      bx
         push      dx

         mov       bh,0
         mov       ah,2
         mov       dx,25*256
         call      Int10P

         pop       dx
         pop       bx
         pop       ax
         ret

KurzOff  ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 10h
; -----------------------------------------------------------------------------

Int10P   PROC      NEAR

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

Int10P   ENDP

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                              Data
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

;þ

SegmVRAM dw        0b000h                   ; segment videopamˆti
Zasobnik dw        0                        ; uschovan˜ z sobn¡k

Automat  db        0                        ; p©¡znak automatu: 0=nen¡, 1=je

Hraje    db        0                        ; hraje: 0=hr ‡, 1=po‡¡ta‡

Hrac     db        80h                      ; barva hr ‡e: 80h=b¡l‚, 0=‡ern‚
Protihr  db        0                        ; barva protihr ‡e: 80h=b¡l‚,0=‡ern‚

Uroven   db        1                        ; £rove¤ hry

CitTah   dw        1                        ; ‡¡ta‡ tah–

Radek    db        1                        ; aktivn¡ © dek pro tisk textu

Kurzor   db        0                        ; aktivn¡ pozice kurzoru

Rosad    db        0                        ; p©¡znak ro¨ dy
                                            ;   0=norm ln¡ tah
                                            ;   1=mal  ro¨ da
                                            ;   2=velk  ro¨ da
                                            ;   3=PxPep

VolTah   db        0                        ; p©¡znak volby figurky
                                            ;   0=figurka byla polo‘ena
                                            ;   1=‡ek  se na uchopen¡
                                            ;   2=figurka je uchopena
Figurka  db        0                        ; p©en ¨en  aktivn¡ figurka
OldPoz   db        0                        ; v˜choz¡ pozice figurky
NewPoz   db        0,0                      ; nov  pozice figurky
OldFig   db        0                        ; star  figurka
HracPoz  db        0                        ; pozice kurzoru hr ‡e

d_000E   label     byte                     ; tabulka zah jen¡ tah– b¡l‚ho
         db        0,0,35,55,10h,0          ; lev˜ pˆ¨ k uprost©ed o 2 pole
         db        0,0,34,54,10h,0          ; prav˜ pˆ¨ k uprost©ed o 2 pole
         db        0,0,22,43,10h,0          ; prav˜ jezdec
         db        0,0,27,46,10h,0          ; lev˜ jezdec

d_0026   db        39 dup (20h),'$'         ; text pro vymaz n¡

MalRosTx db        'O-O',0
VelRosTx db        'O-O-O',0
PxPepTx  db        'PxP',0  ;'PxPep',0

                                          ;* mo‘n‚ smˆry figurek
TabSmer  db        9,11,-11,-9              ; 0: smˆry ¨ikmo
         db        10,-10,1,-1              ; 4: smˆry kolmo
         db        -21,-12,8,19             ; 8: konˆm vlevo
         db        21,12,-8,-19             ; 12: konˆm vpravo
         db        10,10,11,9               ; 16: tahy b¡l‚ho pˆ¨ ka
         db        -10,-10,-11,-9           ; 20: tahy ‡ern‚ho pˆ¨ ka

OfsSmer  label     byte                   ;* offset mo‘n˜ch smˆr– figurek
         db        20                       ; 0: b¡l˜ pˆ¨ k
         db        16                       ; 1: ‡ern˜ pˆ¨ k
         db        8                        ; 2: jezdec
         db        0                        ; 3: st©elec
         db        4                        ; 4: vˆ‘
         db        0                        ; 5: d ma
         db        0                        ; 6: kr l

NumSmer  label     byte                   ;* po‡et mo‘n˜ch smˆr– figurek
         db        4                        ; 0: b¡l˜ pˆ¨ k
         db        4                        ; 1: ‡ern˜ pˆ¨ k
         db        8                        ; 2: jezdec
         db        4                        ; 3: st©elec
         db        4                        ; 4: vˆ‘
         db        8                        ; 5: d ma
         db        8                        ; 6: kr l

TabBod   db        0,1,3,3,5,9,10           ; bodov n¡ figurek

                                          ;* mapa ¨achovnice
Mapa     db        21 dup (0)               ; spodn¡ okraj ¨achovnice
d_00E6   db        10 dup (0)               ; © dek 1
d_00F0   db        10 dup (0)               ; © dek 2
d_00FA   db        10 dup (0)               ; © dek 3
d_0104   db        10 dup (0)               ; © dek 4
d_010E   db        10 dup (0)               ; © dek 5
d_0118   db        10 dup (0)               ; © dek 6
d_0122   db        10 dup (0)               ; © dek 7
d_012C   db        10 dup (0)               ; © dek 8
d_0136   db        19 dup (0)               ; horn¡ okraj ¨achovnice
Mapa0    label     byte

                                          ;* inicializa‡n¡ mapa ¨achovnice
MapaIni  db        20 dup(-1)               ; spodn¡ okraj ¨achovnice
         db        -1,4,2,3,5,6,3,2,4,-1    ; © dek 1 (b¡l‚)
         db        -1,1,1,1,1,1,1,1,1,-1    ; © dek 2
         db        -1,0,0,0,0,0,0,0,0,-1    ; © dek 3
         db        -1,0,0,0,0,0,0,0,0,-1    ; © dek 4
         db        -1,0,0,0,0,0,0,0,0,-1    ; © dek 5
         db        -1,0,0,0,0,0,0,0,0,-1    ; © dek 6
         db        -1,81h,81h,81h,81h,81h,81h,81h,81h,-1 ; © dek 7
         db        -1,84h,82h,83h,85h,86h,83h,82h,84h,-1 ; © dek 8 (‡ern‚)
         db        20 dup(-1)               ; horn¡ okraj ¨achovnice

                                                 ;    0=pr zdn‚ pol¡‡ko
                                                 ;    1=pˆ¨ec
                                                 ;    2=jezdec
                                                 ;    3=st©elec
                                                 ;    4=vˆ‘
                                                 ;    5=d ma
                                                 ;    6=kr l
                                                 ;    0ffh=zak zan‚ pol¡‡ko
                                                 ; bit 7: 1=b¡l  barva,0=‡ern 

                                          ;* tabulka po‡tu ‡ern˜ch figurek
PocFigC  db        0,0                      ; celkov˜ po‡et figurek
BodFigC  dw        6 dup (0)                ; bodov n¡ figurek

                                          ;* tabulka po‡tu b¡l˜ch figurek
PocFigB  db        0,0                      ; celkov˜ po‡et figurek
BodFigB  dw        6 dup (0)                ; bodov n¡ figurek

d_0165   db        10 dup (0)               ; tabulka pozic figurek
d_016F   db        10 dup (0)

                                          ;* po©ad¡ zachovat !
KurzB    db        19h                      ; pozice kurzoru b¡l‚ho
KurzC    db        5Fh                      ; pozice kurzoru ‡ern‚ho

DamaB    db        18h                      ; pozice b¡l‚ d my
DamaC    db        5Eh                      ; pozice ‡ern‚ d my

         db        0FFh
d_017E   db        0
d_017F   db        0
         db        10 dup(0)


                                                 ; 0: (2) bodov n¡ tahu
                                                 ; 2: (1) v˜choz¡ pozice tahu
                                                 ; 3: (1) c¡lov  pozice tahu
                                                 ; 4: (1) p–vodn¡ obsah nov‚ho pole
                                                 ; 5: (1)

d_018A   db        40 dup(0)                ; tabulka tah–

d_01B2   db        1024 dup(0)

d_05B2   db        1016 dup (0)             ; tabulka tah–

d_09AA   db        8 dup(0)

d_09B2   db        0,0
PozTah   db        0,0                      ; pozice p©i pokusu o tah
PozTst   db        0,0                      ; testovan  pozice hr ‡e
d_09B8   db        0,0
FigTst2  db        0,0                      ; pracovn¡ figurka (bez barvy)

CilFig2  db        0,0                      ; ru¨en  c¡lov  figurka p©i skoku
                                            ;   (bez barvy)

d_09BE   db        0,0
d_09C0   dw        0
d_09C2   dw        18Ah                     ; ukazatel v z sobn¡ku tah–
                                            ;  <- 188h
d_09C4   dw        0                        ; ukazatel v bufferu tah–
d_09C6   dw        0
d_09C8   dw        0                        ; nalezen˜ tah po‡¡ta‡e (v tab.tah–)
d_09CA   dw        0
d_09CC   dw        1B2h                     ; ukazatel v z sobn¡ku tah–
                                            ;  <- 5b2h

FigTst1  db        0                        ; figurka p©i pracovn¡m testu
CilFig1  db        0                        ; p–vod.obsah na nov‚m pol¡‡ku
                                                 ;  0 a‘ 6 - figurka
                                                 ;  10h - je to 2. tah ro¨ dy
                                                 ;  20h - n hrada pˆ¨ ka d mou
                                                 ;  40h - je to 1. tah ro¨ dy
                                                 ;  80h - barva figurky

d_09D2   db        0
d_09D3   db        0                        ; zbyl˜ po‡et tah–
d_09D6   db        0
d_09D7   db        0
d_09D8   db        0
d_09D9   db        0
d_09DA   db        0
d_09DB   db        0
d_09DC   db        0
d_09DD   db        0
d_09DE   db        0
d_09DF   db        0
d_09E0   db        0
d_09E1   db        0
d_09E2   dw        0
d_09E4   dw        0

d_09EC   dw        0
;d_09EE   dw        0                        ; segment PSP


d_0A3A   db        19,'MAT - BILY VYHRAL !' ; b¡l˜ vyhr l

d_0A4A   db        14,'MAT v '
d_0A52   db        'X tazich'               ; mat v X taz¡ch

d_0A5A   db        20,'MAT - CERNY VYHRAL !'  ; ‡ern˜ vyhr l
         db        0

d_0A6C   db        0,0                      ; £schova £rovnˆ hry p©i tahu

Obrazky  label     byte                     ; obr zky figurek

                                            ; 1: pˆ¨ k
         db        '   o   '
         db        '   ²   '
         db        ' ²²²²² '
                                            ; 2: jezdec
         db        ' /^²   '
         db        ' ÄÄ²²  '
         db        ' ²²²²² '
                                            ; 3: st©elec
         db        '  Ü²Ü  '
         db        '   ²   '
         db        ' ²²²²² '
                                            ; 4: vˆ‘
         db        ' ² ² ² '
         db        '  ²²²  '
         db        ' ²²²²² '
                                            ; 5: d ma
         db        ' . . . '
         db        ' ² ² ² '
         db        '  ²²²  '
                                            ; 6: kr l
         db        '  _+_  '
         db        ' ² ² ² '
         db        ' ²²²²² '


Text1    db        2,' S  A  C  H  Y ',0
Text2    db        'verze ',1,'1.1',0
Text3    db        '(c) Miroslav Nemecek',0
Text4    db        '- FREEWARE -',0

ColTxt   db        'Zvolte barvu (',1,'B',1,'ila/',1,'C',1,'erna/'
         db        1,'A',1,'utomat/',1,'ENTER',1,', ',1,'ESC',1,'=konec): ',1
ColTxt0  db        'B',0
ColTxt1  db        'B',0
CRTxt    db        13,10,0

UrovTxt  db        'Zvolte uroven obtiznosti (',1,'1',1,' az ',1,'6',1
         db        ', ',1,'ENTER',1,', ',1,'ESC',1,'=navrat): ',1
UrovTxt0 db        '1',0

TahTxt   db        13,'Jste na tahu:'
CekTxt   db        16,'CEKEJTE - tahnu.'

PrerTxt  db        18,'Prerusit (A=ANO) ?'

         db        13 dup (0)

Code     ENDS

         END       Start

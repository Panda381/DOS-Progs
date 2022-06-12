
code     segment
         assume    cs:code,ds:code
         org       100h

MAPASIZE EQU       1000

; ------ inicializace videom¢du

start:   mov       ah,0fh
         int       10h                      ; poskytnut° videom¢du
         cmp       al,7
         je        Start1                   ; videom¢d MDA = OK
         mov       al,3                     ; jinak videom¢d CGA
         mov       byte ptr ds:[SegmVRAM+1],0b8h ; adresa videopamàti CGA
         mov       word ptr ds:[Barva1],1f30h ; oprava barev pro barevnò displej
Start1:  mov       byte ptr ds:[VMod],al    ; £schova videom¢du
         mov       ah,0
         int       10h                      ; inicializace videom¢du

; ------ spoáten° poátu ©†dkñ

         mov       si,offset Text           ; text
         cld
         xor       cx,cx                    ; á°taá ©†dkñ
Start2:  lodsb                              ; naáten° znaku z textu
         cmp       al,10                    ; je konec ©†dku ?
         jne       Start3                   ; nen° konec ©†dku
         inc       cx                       ; zvò®en° á°taáe ©†dkñ
Start3:  cmp       al,26                    ; je konec textu ?
         jne       Start2                   ; dal®° test
         mov       ds:[Radku],cx            ; celkovò poáet ©†dkñ

; ------ zobrazen° nadpisu

Start35: mov       es,ds:[SegmVRAM]         ; adresa videopamàti
         mov       ah,ds:[Barva1]           ; barva nadpisu
         mov       si,offset Nadpis         ; text nadpisu
         xor       di,di                    ; adresa ve videopamàti
         mov       cx,80                    ; dÇlka ©†dku (znakñ)
         cld
Start4:  lodsb                              ; naáten° znaku k zobrazen°
         stosw                              ; uloëen° znaku
         loop      Start4                   ; dek¢dov†n° dal®°ho znaku

; ------ vypnut° kurzoru

Start5:  mov       dx,25*256
         mov       ah,2
         int       10h                      ; nastaven° kurzoru mimo displej

; ------ zobrazen° jednÇ str†nky textu

         mov       es,ds:[SegmVRAM]         ; segment videopamàti
         mov       ah,ds:[Barva2]           ; barva textu
         mov       si,ds:[AdrRad]           ; adresa prvn°ho ©†dku obrazovky
         mov       di,160                   ; adresa druhÇho ©†dku
         xor       bx,bx
         cld
Start6:  mov       cx,80                    ; dÇlka ©†dku (pozic)
Start7:  lodsb
         cmp       al,13
         je        Start7                   ; CR se ignoruje
         cmp       al,10
         je        Start76                  ; LF = konec ©†dku
         cmp       al,26
         je        Start74                  ; EOF = konec textu

         test      byte ptr ds:[Param],1    ; je zapnut filtr ?
         jz        Start71                  ; nen° zapnut filtr
         cmp       al,128                   ; poá†teán° znak ke konverzi
         jb        Start71                  ; nen° konverze
         cmp       al,128 + offset(Filtr0-Filtr)
         jae       Start71                  ; nen° konverze
         mov       bl,al                    ; znak ke konverzi
         mov       al,ds:[bx+Filtr-128]     ; konverze znaku
Start71: stosw                              ; uloëen° znaku
         loop      Start7                   ; dal®° znak
Start72: lodsb
         cmp       al,13
         je        Start72
         cmp       al,10
         je        Start76
Start74: dec       si                       ; n†vrat znaku
Start76: mov       al," "
         rep       stosw                    ; vymaz†n° zbytku ©†dku
         cmp       di,25*160                ; jsou jië v®echny ©†dky ?
         jb        Start6                   ; dek¢dov†n° dal®°ho ©†dku

; ------ áek†n° na stisk kl†vesy

Start77: mov       ah,1
         int       16h
         jz        Start78
         mov       ah,0
         int       16h
         jmp       short Start77

Start78: mov       ah,0
         int       16h

; ------ filtr znakñ ENTER

         cmp       al,13
         jne       Start81                  ; nen° filtr ENTER
         xor       byte ptr ds:[Param],1    ; zmàna p©°znaku filtru
Start8:  jmp       Start5                   ; novÇ zobrazen° str†nky

; ------ posun textu

Start81: mov       cx,1                     ; posun o 1 ©†dek
         cmp       ah,50h
         je        Start82                  ; posun o 1 ©†dek dolñ
         cmp       ah,48h
         je        Start83                  ; posun o 1 ©†dek nahoru
         mov       cl,23                    ; posun o str†nku
         cmp       ah,51h
         je        Start82                  ; posun o str†nku dolñ
         cmp       ah,49h
         je        Start83                  ; posun o str†nku nahoru
         mov       cx,-1
         cmp       ah,47h
         je        Start83                  ; posun na zaá†tek
         cmp       ah,4fh                   ; posun na konec
         jne       Start84

; ------ posun dolñ

Start82: call      Down                     ; posun o ©†dek dolñ
         jc        Start8
         loop      Start82                  ; posun o dal®° ©†dek
         jmp       short Start8

; ------ posun nahoru

Start83: call      Up
         jc        Start8
         loop      Start83
         jmp       short Start8

; ------ odstartov†n° testu

Start84: cmp       al," "
         jne       Start85
         call      Tst
         jmp       Start35

; ------ konec programu ESC

Start85: or        ax,ax
         jz        Start9                   ; Ctrl-Break = konec
         cmp       al,27
         jne       Start8                   ; nen° ESC

; ------ n†vrat z programu

Start9:  mov       ax,ds:[VMod]             ; videom¢d
         int       10h                      ; vymaz†n° obrazovky
         int       20h

; -----------------------------------------------------------------------------
;        test
; -----------------------------------------------------------------------------
;˛
Tst      PROC      NEAR

         mov       word ptr ds:[RandomR],0a534h
         mov       word ptr ds:[RandomR+2],2151h
         mov       byte ptr ds:[Col],9
         mov       byte ptr ds:[CitCol],10
         mov       word ptr ds:[MapaUk],0

         push      ds
         pop       es
         mov       di,offset Mapa
         mov       cx,MAPASIZE
         xor       ax,ax
         cld
         rep       stosw

         call      CekInit                  ; inicializace hodin

; ------ vymaz†n° obrazovky

         mov       es,ds:[SegmVRAM]
         mov       ax,720h
         mov       cx,25*80
         xor       di,di
         cld
         rep       stosw

; ------ uráen° adresy k uloëen° znaku

         mov       di,12*160+80
         mov       bp,80                    ; ukazatel pozice na ©†dku * 2
Tst1:    mov       es,ds:[SegmVRAM]
         mov       ax,5                     ; rozsah (poáet pozic)
         call      Random                   ; generov†n° n†hodnÇho á°sla
         shl       ax,1
         sub       ax,2*2
         add       di,ax
         add       bp,ax
         js        Tst11
         cmp       bp,160
         jb        Tst12

Tst11:   neg       ax
         add       bp,ax
         add       bp,ax
         add       di,ax
         add       di,ax
Tst12:

Tst2:    mov       ax,3
         call      Random
         mov       bx,160
         mul       bx
         sub       ax,160
         add       di,ax
         jns       Tst3
         add       di,160
Tst3:    cmp       di,25*160
         jb        Tst4
         sub       di,160

; ------ vygenerov†n° znaku k uloëen°

Tst4:
         mov       ax,4
         call      Random
         mov       bx,ax
         mov       bl,ds:[bx+TabCh]

Tst5:    mov       bh,ds:[Col]
         dec       byte ptr ds:[CitCol]
         jnz       Tst62
         mov       ax,3
         call      Random                   ; vygenerov†n° barvy
         mov       si,ax
         mov       bh,ds:[si+TabCol]
         mov       ax,120
         call      Random
         add       al,60
         mov       byte ptr ds:[CitCol],al
Tst62:   mov       ds:[Col],bh

         mov       si,ds:[MapaUk]
         mov       si,ds:[Mapa+si]
         mov       word ptr es:[si],720h
         mov       si,ds:[MapaUk]
         mov       ds:[Mapa+si],di
         inc       si
         inc       si
         cmp       si,MAPASIZE*2
         jb        Tst63
         xor       si,si
Tst63:   mov       ds:[MapaUk],si

         mov       es:[di],bx               ; uloëen° znaku

; ------ áek†n° - prodleva

         mov       cx,1
         call      Cekej                    ; prodleva

; ------ test p©eru®en° programu

         mov       ah,1
         int       16h
         jnz       Tst7
         jmp       Tst1

Tst7:

         mov       ah,0
         int       16h

; ------ vymaz†n° obrazovky

         mov       es,ds:[SegmVRAM]
         mov       ax,720h
         mov       cx,25*80
         xor       di,di
         cld
         rep       stosw

; ------ ozn†men° o áek†n°

         mov       si,offset CekTxt
         mov       cx,offset(CekTxt0-CekTxt)
         xor       di,di
         mov       ah,07h
Tst72:   lodsb
         stosw
         loop      Tst72

; ------ n†hodn† prodleva

         mov       cx,word ptr ds:[RandomR] ; vòsledek testu
         shr       cx,1
         shr       cx,1
         shr       cx,1
         shr       cx,1
         shr       cx,1
         shr       cx,1
         call      Cekej

; ------ vypr†zdnàn° bufferu kl†vesnice

Tst74:   mov       ah,1
         int       16h
         jz        Tst75
         mov       ah,0
         int       16h
         jmp       short Tst74

; ------ zobrazen° informace o vòsledku testu

Tst75:   mov       al,byte ptr ds:[RandomR+1] ; vòsledek testu
         shr       al,1
         mov       di,offset TstTxt0+2
         mov       cl,10

         mov       word ptr ds:[di-2],"  "

Tst76:   mov       ah,0
         div       cl
         add       ah,"0"
         mov       ds:[di],ah
         dec       di
         cmp       al,0
         jne       Tst76

         mov       si,offset TstTxt
         mov       cx,offset(TstTxt1-TstTxt)
         xor       di,di
         mov       ah,0fh
         cld
Tst77:   lodsb
         stosw
         loop      Tst77

; ------ áek†n° na stisk kl†vesy

         mov       ah,0
         int       16h
         ret

Tst      ENDP

; -----------------------------------------------------------------------------
;        posun o ©†dek dolñ (CY=nen° dal®° ©†dek)
; -----------------------------------------------------------------------------

Down     PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      si

; ------ zvò®en° á°sla ©†dku

         mov       ax,ds:[Radku]            ; celkovò poáet ©†dkñ
         sub       ax,24                    ; á°slo max. prvn°ho ©†dku
         cmp       ds:[Radek],ax            ; je jië posledn° ©†dek ?
         cmc
         jbe       Down4                    ; je jië posledn° ©†dek
         inc       word ptr ds:[Radek]      ; zvò®en° á°sla ©†dku

; ------ nalezen° adresy dal®°ho ©†dku

         mov       si,ds:[AdrRad]           ; adresa ©†dku
         cld
Down1:   lodsb
         cmp       al,10
         jne       Down1                    ; nalezen° adresy dal®°ho ©†dku
         mov       ds:[AdrRad],si           ; adresa dal®°ho ©†dku

; ------ n†vrat registrñ

Down4:   pop       si
         pop       ax
         ret

Down     ENDP

; -----------------------------------------------------------------------------
;        posun o ©†dek nahoru (CY=nen° dal®° ©†dek)
; -----------------------------------------------------------------------------

Up       PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      si

; ------ sn°ëen° á°sla ©†dku

         cmp       word ptr ds:[Radek],0    ; je jië prvn° ©†dek ?
         stc
         je        Up9                      ; je jië prvn° ©†dek
         dec       word ptr ds:[Radek]      ; sn°ëen° á°sla ©†dku

; ------ adresa p©ede®lÇho ©†dku

         mov       si,ds:[AdrRad]           ; adresa ©†dku
Up1:     dec       si
         cmp       si,offset Text           ; je jië zaá†tek textu ?
         jbe       Up8                      ; je jië zaá†tek textu
         cmp       byte ptr ds:[si-1],10    ; je zaá†tek novÇho ©†dku ?
         jne       Up1                      ; nalezen° zaá†tku ©†dku
Up8:     mov       ds:[AdrRad],si           ; nov† adresa
         clc

; ------ n†vrat registrñ

Up9:     pop       si
         pop       ax
         ret

Up       ENDP

; -----------------------------------------------------------------------------
;                           Random
;                   gener†tor n†hodnÇho á°sla
; -----------------------------------------------------------------------------
; VSTUP: AX=max. hodnota
;        DS=datovò segment
; VùSTUP: AX=á°slo 0 aë (max. hodnota - 1)
; -----------------------------------------------------------------------------

Random   PROC      NEAR

         push      bx
         push      dx
         or        ax,ax
         jz        Random1
         mov       bx,ax                    ; poëadovanò rozsah
         call      Random0                  ; generov†n° n†hodnÇho á°sla DX:AX
         xchg      ax,dx                    ; AX <- n†hodnÇ á°slo
         xor       dx,dx
         div       bx
         xchg      ax,dx
Random1: pop       dx
         pop       bx
         ret

Random   ENDP

; -----------------------------------------------------------------------------

Random0  PROC      NEAR

         push      bx
         push      cx
         mov       ax,word ptr ds:[RandomR]
         mov       bx,word ptr ds:[RandomR+2]
         mov       cx,ax
         mul       word ptr ds:[RandomD]
         shl       cx,1
         shl       cx,1
         shl       cx,1
         add       ch,cl
         add       dx,cx
         add       dx,bx
         shl       bx,1
         shl       bx,1
         add       dx,bx
         add       dh,bl
         mov       cl,5
         shl       bx,cl
         add       dh,bl
         add       ax,1
         adc       dx,0
         mov       word ptr ds:[RandomR],ax
         mov       word ptr ds:[RandomR+2],dx
         pop       cx
         pop       bx
         ret

Random0  ENDP

; -----------------------------------------------------------------------------
;        cejchov†n° hodin
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; -----------------------------------------------------------------------------

CekInit  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      dx
         push      di

         push      ds

; ------ p©°prava registrñ

         sti
         xor       ax,ax                    ; AX <- 0
         mov       ds,ax
         xor       dx,dx                    ; DX <- 0
         mov       di,46ch

; ------ áek†n° na zaá†tek impulsu hodin

         mov       bx,ds:[di]
CekInit1:cmp       bx,ds:[di]
         je        CekInit1                 ; áek†n° na zaá†tek hodin

; ------ mà©en° áasu

         mov       bx,ds:[di]
         EVEN                               ; zarovn†n° na sudou adresu
CekInit2:add       ax,1                     ; á°taá nië®°ho slova áasu
         adc       dx,0                     ; p©enos do vy®®°ho slova
         cmp       bx,ds:[di]               ; byla zmàna ?
         je        CekInit2                 ; áek†n° na zmànu hodin

; ------ vòpoáet konstanty

         mov       bx,55                    ; dàlitel
         cmp       dx,bx                    ; p©eteáen° á°sla ?
         jb        CekInit3                 ; nen° p©eteáen° á°sla
         mov       dx,54                    ; omezen° á°sla
CekInit3:div       bx                       ; vòpoáet konstanty
         or        ax,ax                    ; je = 0 ?
         jnz       CekInit4                 ; nen° = 0
         inc       ax                       ; korekce na 1
CekInit4:
         pop       ds
         mov       ds:[Cit1ms],ax           ; konstanta hodin

; ------ n†vrat registrñ

         pop       di
         pop       dx
         pop       bx
         pop       ax
         ret

CekInit  ENDP

; -----------------------------------------------------------------------------
;        áek†n° na uplynut° zadanÇho áasu
; -----------------------------------------------------------------------------
; VSTUP: CX=poëadovan† doba v milisekund†ch
;        DS=datovò segment
; -----------------------------------------------------------------------------

Cekej    PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      di

; ------ áek†n° po zadanou dobu

         sti
         jcxz      Cekej9                   ; nen° ë†dnÇ áek†n°
         mov       di,offset Cit1ms         ; konstanta hodin
Cekej1:  xor       ax,ax                    ; nië®° slovo á°taáe hodin
         xor       dx,dx                    ; vy®®° slovo á°taáe hodin

; ------ á°t†n° doby 1 ms

         EVEN                               ; zarovn†n° na sudou adresu
Cekej2:  add       ax,1                     ; á°taá nië®°ho slova áasu
         adc       dx,0                     ; p©enos do vy®®°ho slova
         cmp       ax,ds:[di]               ; dosaëeno doby 1 ms ?
         jb        Cekej2                   ; á°t†n° doby 1 ms

         loop      Cekej1                   ; áek†n° na dal®° 1 ms

; ------ n†vrat registrñ

Cekej9:  pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Cekej    ENDP


; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------

VMod     dw        3                        ; £schova videom¢du
SegmVRAM dw        0b000h                   ; segment videopamàti

RandomR  dd        21510d31h                ; promànn† pro gener†tor n†hody
RandomD  dw        8405h                    ; pomocn† konstanta

         EVEN                               ; zaá°n† na sudÇ adrese jako 0:46ch
Cit1ms   dw        ?                        ; konstanta pro dobu 1 ms

Param    db        0                        ; parametry
                                            ;  bit 0: 1=zapnut filtr

Col      db        9
CitCol   db        10

TabCh    db        32,219,220,223
TabCol   db        9,10,12

CekTxt   db        'Cekejte, vyhodnocuji vysledek testu ...'
CekTxt0  label     byte

TstTxt   db        'Vas inteligencni koeficient zjisteny testem je '
TstTxt0  db        '  0.'
TstTxt1  label     byte

; ------ konverzn° tabulka filtru
Filtr    db        'CuedaDTceELIllAAEzZooOuUyOUSLYRtaiounNUOsrrR'
Filtr0   label     byte

Nadpis   db        ' ESC=opusteni programu, navrat do systemu ',179,' ENTER=odstraneni diakritiky z textu '

Barva1   db        70h                      ; barva nadpisu
Barva2   db        0fh                      ; barva textu
Radku    dw        0                        ; celkovò poáet ©†dkñ textu
Radek    dw        0                        ; prvn° zobrazenò ©†dek
AdrRad   dw        offset Text              ; adresa prvn°ho ©†dku obrazovky

MapaUk   dw        0                        ; ukazatel v mapà adres
Mapa     dw        MAPASIZE dup(0)          ; mapa adres

Text     label     byte                     ; text n†povàdy

code     ends
         end       start

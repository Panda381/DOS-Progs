
code     segment
         assume    cs:code,ds:code
         org       100h

MAPASIZE EQU       1000

; ------ inicializace videom¢du

start:   mov       ah,0fh
         int       10h                      ; poskytnut¡ videom¢du
         cmp       al,7
         je        Start1                   ; videom¢d MDA = OK
         mov       al,3                     ; jinak videom¢d CGA
         mov       byte ptr ds:[SegmVRAM+1],0b8h ; adresa videopamØti CGA
         mov       word ptr ds:[Barva1],1f30h ; oprava barev pro barevnì displej
Start1:  mov       byte ptr ds:[VMod],al    ; £schova videom¢du
         mov       ah,0
         int       10h                      ; inicializace videom¢du

; ------ spoŸten¡ poŸtu ý dk…

         mov       si,offset Text           ; text
         cld
         xor       cx,cx                    ; Ÿ¡taŸ ý dk…
Start2:  lodsb                              ; naŸten¡ znaku z textu
         cmp       al,10                    ; je konec ý dku ?
         jne       Start3                   ; nen¡ konec ý dku
         inc       cx                       ; zvìçen¡ Ÿ¡taŸe ý dk…
Start3:  cmp       al,26                    ; je konec textu ?
         jne       Start2                   ; dalç¡ test
         mov       ds:[Radku],cx            ; celkovì poŸet ý dk…

; ------ zobrazen¡ nadpisu

Start35: mov       es,ds:[SegmVRAM]         ; adresa videopamØti
         mov       ah,ds:[Barva1]           ; barva nadpisu
         mov       si,offset Nadpis         ; text nadpisu
         xor       di,di                    ; adresa ve videopamØti
         mov       cx,80                    ; d‚lka ý dku (znak…)
         cld
Start4:  lodsb                              ; naŸten¡ znaku k zobrazen¡
         stosw                              ; ulo§en¡ znaku
         loop      Start4                   ; dek¢dov n¡ dalç¡ho znaku

; ------ vypnut¡ kurzoru

Start5:  mov       dx,25*256
         mov       ah,2
         int       10h                      ; nastaven¡ kurzoru mimo displej

; ------ zobrazen¡ jedn‚ str nky textu

         mov       es,ds:[SegmVRAM]         ; segment videopamØti
         mov       ah,ds:[Barva2]           ; barva textu
         mov       si,ds:[AdrRad]           ; adresa prvn¡ho ý dku obrazovky
         mov       di,160                   ; adresa druh‚ho ý dku
         xor       bx,bx
         cld
Start6:  mov       cx,80                    ; d‚lka ý dku (pozic)
Start7:  lodsb
         cmp       al,13
         je        Start7                   ; CR se ignoruje
         cmp       al,10
         je        Start76                  ; LF = konec ý dku
         cmp       al,26
         je        Start74                  ; EOF = konec textu

;         test      byte ptr ds:[Param],1    ; je zapnut filtr ?
;         jz        Start71                  ; nen¡ zapnut filtr
;         cmp       al,128                   ; poŸ teŸn¡ znak ke konverzi
;         jb        Start71                  ; nen¡ konverze
;         cmp       al,128 + offset(Filtr0-Filtr)
;         jae       Start71                  ; nen¡ konverze
;         mov       bl,al                    ; znak ke konverzi
;         mov       al,ds:[bx+Filtr-128]     ; konverze znaku
Start71: stosw                              ; ulo§en¡ znaku
         loop      Start7                   ; dalç¡ znak
Start72: lodsb
         cmp       al,13
         je        Start72
         cmp       al,10
         je        Start76
Start74: dec       si                       ; n vrat znaku
Start76: mov       al," "
         rep       stosw                    ; vymaz n¡ zbytku ý dku
         cmp       di,25*160                ; jsou ji§ vçechny ý dky ?
         jb        Start6                   ; dek¢dov n¡ dalç¡ho ý dku

; ------ Ÿek n¡ na stisk kl vesy

Start77: mov       ah,1
         int       16h
         jz        Start78
         mov       ah,0
         int       16h
         jmp       short Start77

Start78: mov       ah,0
         int       16h

; ------ filtr znak… ENTER

         cmp       al,13
         jne       Start81                  ; nen¡ filtr ENTER
         xor       byte ptr ds:[Param],1    ; zmØna pý¡znaku filtru
Start8:  jmp       Start5                   ; nov‚ zobrazen¡ str nky

; ------ posun textu

Start81: mov       cx,1                     ; posun o 1 ý dek
         cmp       ah,50h
         je        Start82                  ; posun o 1 ý dek dol…
         cmp       ah,48h
         je        Start83                  ; posun o 1 ý dek nahoru
         mov       cl,23                    ; posun o str nku
         cmp       ah,51h
         je        Start82                  ; posun o str nku dol…
         cmp       ah,49h
         je        Start83                  ; posun o str nku nahoru
         mov       cx,-1
         cmp       ah,47h
         je        Start83                  ; posun na zaŸ tek
         cmp       ah,4fh                   ; posun na konec
         jne       Start84

; ------ posun dol…

Start82: call      Down                     ; posun o ý dek dol…
         jc        Start8
         loop      Start82                  ; posun o dalç¡ ý dek
         jmp       short Start8

; ------ posun nahoru

Start83: call      Up
         jc        Start8
         loop      Start83
         jmp       short Start8

; ------ odstartov n¡ testu

Start84: cmp       al," "
         jne       Start85
         call      Tst
         jmp       Start35

; ------ konec programu ESC

Start85: or        ax,ax
         jz        Start9                   ; Ctrl-Break = konec
         cmp       al,27
         jne       Start8                   ; nen¡ ESC

; ------ n vrat z programu

Start9:  mov       ax,ds:[VMod]             ; videom¢d
         int       10h                      ; vymaz n¡ obrazovky
         int       20h

; -----------------------------------------------------------------------------
;        test
; -----------------------------------------------------------------------------
;þ
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

; ------ vymaz n¡ obrazovky

         mov       es,ds:[SegmVRAM]
         mov       ax,720h
         mov       cx,25*80
         xor       di,di
         cld
         rep       stosw

; ------ urŸen¡ adresy k ulo§en¡ znaku

         mov       di,12*160+80
         mov       bp,80                    ; ukazatel pozice na ý dku * 2
Tst1:    mov       es,ds:[SegmVRAM]
         mov       ax,5                     ; rozsah (poŸet pozic)
         call      Random                   ; generov n¡ n hodn‚ho Ÿ¡sla
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

; ------ vygenerov n¡ znaku k ulo§en¡

Tst4:
         mov       ax,4
         call      Random
         mov       bx,ax
         mov       bl,ds:[bx+TabCh]

Tst5:    mov       bh,ds:[Col]
         dec       byte ptr ds:[CitCol]
         jnz       Tst62
         mov       ax,3
         call      Random                   ; vygenerov n¡ barvy
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

         mov       es:[di],bx               ; ulo§en¡ znaku

; ------ Ÿek n¡ - prodleva

         mov       cx,1
         call      Cekej                    ; prodleva

; ------ test pýeruçen¡ programu

         mov       ah,1
         int       16h
         jnz       Tst7
         jmp       Tst1

Tst7:

         mov       ah,0
         int       16h

; ------ vymaz n¡ obrazovky

         mov       es,ds:[SegmVRAM]
         mov       ax,720h
         mov       cx,25*80
         xor       di,di
         cld
         rep       stosw

; ------ ozn men¡ o Ÿek n¡

         mov       si,offset CekTxt
         mov       cx,offset(CekTxt0-CekTxt)
         xor       di,di
         mov       ah,07h
Tst72:   lodsb
         stosw
         loop      Tst72

; ------ n hodn  prodleva

         mov       cx,word ptr ds:[RandomR] ; vìsledek testu
         shr       cx,1
         shr       cx,1
         shr       cx,1
         shr       cx,1
         shr       cx,1
         shr       cx,1
         call      Cekej

; ------ vypr zdnØn¡ bufferu kl vesnice

Tst74:   mov       ah,1
         int       16h
         jz        Tst75
         mov       ah,0
         int       16h
         jmp       short Tst74

; ------ zobrazen¡ informace o vìsledku testu

Tst75:   mov       al,byte ptr ds:[RandomR+1] ; vìsledek testu
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

; ------ Ÿek n¡ na stisk kl vesy

         mov       ah,0
         int       16h
         ret

Tst      ENDP

; -----------------------------------------------------------------------------
;        posun o ý dek dol… (CY=nen¡ dalç¡ ý dek)
; -----------------------------------------------------------------------------

Down     PROC      NEAR

; ------ £schova registr…

         push      ax
         push      si

; ------ zvìçen¡ Ÿ¡sla ý dku

         mov       ax,ds:[Radku]            ; celkovì poŸet ý dk…
         sub       ax,24                    ; Ÿ¡slo max. prvn¡ho ý dku
         cmp       ds:[Radek],ax            ; je ji§ posledn¡ ý dek ?
         cmc
         jbe       Down4                    ; je ji§ posledn¡ ý dek
         inc       word ptr ds:[Radek]      ; zvìçen¡ Ÿ¡sla ý dku

; ------ nalezen¡ adresy dalç¡ho ý dku

         mov       si,ds:[AdrRad]           ; adresa ý dku
         cld
Down1:   lodsb
         cmp       al,10
         jne       Down1                    ; nalezen¡ adresy dalç¡ho ý dku
         mov       ds:[AdrRad],si           ; adresa dalç¡ho ý dku

; ------ n vrat registr…

Down4:   pop       si
         pop       ax
         ret

Down     ENDP

; -----------------------------------------------------------------------------
;        posun o ý dek nahoru (CY=nen¡ dalç¡ ý dek)
; -----------------------------------------------------------------------------

Up       PROC      NEAR

; ------ £schova registr…

         push      ax
         push      si

; ------ sn¡§en¡ Ÿ¡sla ý dku

         cmp       word ptr ds:[Radek],0    ; je ji§ prvn¡ ý dek ?
         stc
         je        Up9                      ; je ji§ prvn¡ ý dek
         dec       word ptr ds:[Radek]      ; sn¡§en¡ Ÿ¡sla ý dku

; ------ adresa pýedeçl‚ho ý dku

         mov       si,ds:[AdrRad]           ; adresa ý dku
Up1:     dec       si
         cmp       si,offset Text           ; je ji§ zaŸ tek textu ?
         jbe       Up8                      ; je ji§ zaŸ tek textu
         cmp       byte ptr ds:[si-1],10    ; je zaŸ tek nov‚ho ý dku ?
         jne       Up1                      ; nalezen¡ zaŸ tku ý dku
Up8:     mov       ds:[AdrRad],si           ; nov  adresa
         clc

; ------ n vrat registr…

Up9:     pop       si
         pop       ax
         ret

Up       ENDP

; -----------------------------------------------------------------------------
;                           Random
;                   gener tor n hodn‚ho Ÿ¡sla
; -----------------------------------------------------------------------------
; VSTUP: AX=max. hodnota
;        DS=datovì segment
; VíSTUP: AX=Ÿ¡slo 0 a§ (max. hodnota - 1)
; -----------------------------------------------------------------------------

Random   PROC      NEAR

         push      bx
         push      dx
         or        ax,ax
         jz        Random1
         mov       bx,ax                    ; po§adovanì rozsah
         call      Random0                  ; generov n¡ n hodn‚ho Ÿ¡sla DX:AX
         xchg      ax,dx                    ; AX <- n hodn‚ Ÿ¡slo
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
;        cejchov n¡ hodin
; -----------------------------------------------------------------------------
; VSTUP: DS=datovì segment
; -----------------------------------------------------------------------------

CekInit  PROC      NEAR

; ------ £schova registr…

         push      ax
         push      bx
         push      dx
         push      di

         push      ds

; ------ pý¡prava registr…

         sti
         xor       ax,ax                    ; AX <- 0
         mov       ds,ax
         xor       dx,dx                    ; DX <- 0
         mov       di,46ch

; ------ Ÿek n¡ na zaŸ tek impulsu hodin

         mov       bx,ds:[di]
CekInit1:cmp       bx,ds:[di]
         je        CekInit1                 ; Ÿek n¡ na zaŸ tek hodin

; ------ mØýen¡ Ÿasu

         mov       bx,ds:[di]
         EVEN                               ; zarovn n¡ na sudou adresu
CekInit2:add       ax,1                     ; Ÿ¡taŸ ni§ç¡ho slova Ÿasu
         adc       dx,0                     ; pýenos do vyçç¡ho slova
         cmp       bx,ds:[di]               ; byla zmØna ?
         je        CekInit2                 ; Ÿek n¡ na zmØnu hodin

; ------ vìpoŸet konstanty

         mov       bx,55                    ; dØlitel
         cmp       dx,bx                    ; pýeteŸen¡ Ÿ¡sla ?
         jb        CekInit3                 ; nen¡ pýeteŸen¡ Ÿ¡sla
         mov       dx,54                    ; omezen¡ Ÿ¡sla
CekInit3:div       bx                       ; vìpoŸet konstanty
         or        ax,ax                    ; je = 0 ?
         jnz       CekInit4                 ; nen¡ = 0
         inc       ax                       ; korekce na 1
CekInit4:
         pop       ds
         mov       ds:[Cit1ms],ax           ; konstanta hodin

; ------ n vrat registr…

         pop       di
         pop       dx
         pop       bx
         pop       ax
         ret

CekInit  ENDP

; -----------------------------------------------------------------------------
;        Ÿek n¡ na uplynut¡ zadan‚ho Ÿasu
; -----------------------------------------------------------------------------
; VSTUP: CX=po§adovan  doba v milisekund ch
;        DS=datovì segment
; -----------------------------------------------------------------------------

Cekej    PROC      NEAR

; ------ £schova registr…

         push      ax
         push      bx
         push      cx
         push      dx
         push      di

; ------ Ÿek n¡ po zadanou dobu

         sti
         jcxz      Cekej9                   ; nen¡ § dn‚ Ÿek n¡
         mov       di,offset Cit1ms         ; konstanta hodin
Cekej1:  xor       ax,ax                    ; ni§ç¡ slovo Ÿ¡taŸe hodin
         xor       dx,dx                    ; vyçç¡ slovo Ÿ¡taŸe hodin

; ------ Ÿ¡t n¡ doby 1 ms

         EVEN                               ; zarovn n¡ na sudou adresu
Cekej2:  add       ax,1                     ; Ÿ¡taŸ ni§ç¡ho slova Ÿasu
         adc       dx,0                     ; pýenos do vyçç¡ho slova
         cmp       ax,ds:[di]               ; dosa§eno doby 1 ms ?
         jb        Cekej2                   ; Ÿ¡t n¡ doby 1 ms

         loop      Cekej1                   ; Ÿek n¡ na dalç¡ 1 ms

; ------ n vrat registr…

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
SegmVRAM dw        0b000h                   ; segment videopamØti

RandomR  dd        21510d31h                ; promØnn  pro gener tor n hody
RandomD  dw        8405h                    ; pomocn  konstanta

         EVEN                               ; zaŸ¡n  na sud‚ adrese jako 0:46ch
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

; ------ konverzn¡ tabulka filtru
;Filtr    db        'CuedaDTceELIllAAEzZooOuUyOUSLYRtaiounNUOsrrR'
;Filtr0   label     byte

Nadpis   db        ' ESC=opusteni programu, navrat do systemu                                       '

Barva1   db        70h                      ; barva nadpisu
Barva2   db        0fh                      ; barva textu
Radku    dw        0                        ; celkovì poŸet ý dk… textu
Radek    dw        0                        ; prvn¡ zobrazenì ý dek
AdrRad   dw        offset Text              ; adresa prvn¡ho ý dku obrazovky

MapaUk   dw        0                        ; ukazatel v mapØ adres
Mapa     dw        MAPASIZE dup(0)          ; mapa adres

Text     label     byte                     ; text n povØdy

code     ends
         end       start

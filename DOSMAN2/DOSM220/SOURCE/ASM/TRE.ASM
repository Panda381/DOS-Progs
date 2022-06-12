
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                                     T R E E
;
;                                 Obsluha stromu
;
; =============================================================================
;
;
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

INCLUDE  ASM\DEF.ASM

CodeTre  SEGMENT   BYTE PUBLIC
         ASSUME    cs:CodeTre,ds:Data

; -----------------------------------------------------------------------------
;        strom Alt-F10
; -----------------------------------------------------------------------------

Strom    LABEL     FAR

; ------ uzav©en° oken menu

         call      far ptr ClosMnuA         ; uzav©en° oken menu

; ------ test, zda je strom jië aktivn°

         mov       si,offset ParamL         ; parametry levÇho okna
         test      byte ptr ds:[WindPar],bit0 ; je aktivn° levÇ okno ?
         jnz       Strom01                  ; je aktivn° levÇ okno
         mov       si,offset ParamR         ; parametry pravÇho okna
Strom01: test      byte ptr ds:[si],bit2    ; je aktivn° strom ?
         jz        Strom04                  ; strom nen° aktivn°

; ------ uzav©en° okna stromu

         push      cs
         call      near ptr TreeClos        ; uzav©en° okna stromu
         call      far ptr MainRead         ; naáten° oken
         jmp       short Strom07

; ------ vytvo©en° okna stromu

Strom04: call      TreeOpen                 ; otev©en° okna stromu
         jc        Strom07                  ; chyba
         mov       ax,ds:[SegmAkt]
         push      cs
         call      near ptr InitTWn         ; inicializace okna

; ------ aktualizace oken

Strom07: call      far ptr DispAll
StromX0: jmp       far ptr Main0

; -----------------------------------------------------------------------------
;        z†màna adres†©ovòch oken p©i zapnut°/vypnut° stromu (niá° AX)
; -----------------------------------------------------------------------------

StromWA  PROC      NEAR

         mov       ax,ds:[SegmLAdr]         ; levò adres†©
         test      byte ptr ds:[ParamR],bit1 ; je v pravÇm oknà adres†© ?
         jz        StromWA1                 ; nen° adres†©
         mov       ds:[SegmR],ax            ; v pravÇm oknà adres†©
StromWA1:xchg      ax,ds:[SegmRAdr]         ; z†màna s pravòm adres†©em
         mov       ds:[SegmLAdr],ax         ; levò adres†©
         test      byte ptr ds:[ParamL],bit1 ; je v levÇm oknà adres†© ?
         jz        StromWA2                 ; nen° adres†©
         mov       ds:[SegmL],ax            ; v levÇm oknà adres†©
StromWA2:ret

StromWA  ENDP

; -----------------------------------------------------------------------------
;        zru®en° okna stromu v aktivn°m oknà (niá° registry AX, SI, DI !)
; -----------------------------------------------------------------------------

TreeClos PROC      FAR

; ------ ukazatele aktivn°ho okna

         mov       si,offset ParamL         ; parametry levÇho okna
         mov       di,offset SegmL          ; segment levÇho okna
         test      byte ptr ds:[WindPar],bit0 ; je aktivn° levÇ okno ?
         jnz       TreeCls1                 ; je aktivn° levÇ okno
         mov       si,offset ParamR         ; parametry pravÇho okna
         mov       di,offset SegmR          ; segment pravÇho okna

; ------ test, zda je aktivn° strom

TreeCls1:test      byte ptr ds:[si],bit2    ; zobrazen strom ?
         jz        TreeCls4                 ; strom nen° zobrazen

; ------ z†pis stromu na disk

         mov       ax,ds:[di]               ; segment okna
         call      WritTree                 ; uloëen° stromu na disk

; ------ p©epnut° p©°znakñ na adres†©

         xor       byte ptr ds:[si],bit2+bit1 ; p©epnut° na adres†©

; ------ zru®en° segmentu stromu

         call      far ptr DeletAWn         ; zru®en° okna

; ------ navr†cen° segmentu adres†©e

         mov       ax,ds:[di+2]             ; segment adres†©ovÇho okna
         mov       ds:[di],ax               ; segment pravÇho okna

; ------ aktualizace aktivn°ho adres†©e

         call      StromWA                  ; z†màna adres†©ovòch oken
         call      far ptr AktIWin          ; aktualizace oken
         call      far ptr AktADir          ; aktualizace aktivn°ho adres†©e
TreeCls4:ret

TreeClos ENDP

; -----------------------------------------------------------------------------
;        otev©en° okna stromu (neuchov†v† registry AX, SI, DI a ES) CY=chyba
; -----------------------------------------------------------------------------

TreeOpen PROC      NEAR

; ------ uzav©en° p©°padnÇho okna seznamu

         call      far ptr HledClos         ; uzav©en° okna seznamu

; ------ ukazatele aktivn°ho okna

         mov       si,offset ParamL         ; parametry levÇho okna
         mov       di,offset SegmL          ; segment levÇho okna
         test      byte ptr ds:[WindPar],bit0 ; je aktivn° levÇ okno ?
         jnz       TreeOpn1                 ; je aktivn° levÇ okno
         mov       si,offset ParamR         ; parametry pravÇho okna
         mov       di,offset SegmR          ; segment pravÇho okna

; ------ test, zda je okno stromu jië aktivn°

TreeOpn1:or        byte ptr ds:[si],bit0    ; zapnut° okna
         or        byte ptr ds:[WindPar],bit1 ; okna jsou zapnuta
         test      byte ptr ds:[si],bit2    ; je jië strom ?
         jnz       TreeOpn8                 ; je jië strom

; ------ vytvo©en° segmentu okna

         mov       ax,ds:[SegmAkt]          ; segment vzoru (adres†©)
         call      far ptr CreatTWn         ; vytvo©en° segmentu stromu
         jc        TreeOpn8

; ------ nastaven° p©°znakñ stromu

         and       byte ptr ds:[si],not bit1 + bit3 ; nen° seznam ani adres†©
         or        byte ptr ds:[si],bit2    ; p©°znak zobrazen° stromu

; ------ nastaven° segmentñ

         mov       ds:[di],ax               ; segment okna
         call      StromWA                  ; z†màna adres†©ovòch oken
         clc                                ; p©°znak operace OK
TreeOpn8:call      far ptr AktIWin          ; aktualizace oken
TreeOpn9:ret

TreeOpen ENDP

; *****************************************************************************
;                              CreatTWn
;                        vytvo©en° okna stromu
; -----------------------------------------------------------------------------
; VSTUP: AX=á°slo segmentu vzoru okna
;        DS=datovò segment
; VùSTUP: AX=á°slo novÇho okna (p©i chybà AX=0)
;         CY=okno nelze vytvo©it nebo jin† chyba (hl†s° chybu pamàti)
; *****************************************************************************
;˛
CreatTWn PROC      FAR

; ------ £schova registrñ

         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ vytvo©en° novÇho okna

         call      far ptr DuplAWin         ; vytvo©en° novÇho okna
         xchg      ax,bx                    ; AX <- á°slo novÇho okna
         jnc       CreatTW2

; ------ zru®en° okna p©i chybà (AX=0 okno nebylo vytvo©eno)

CreatTW1:call      far ptr DeletAWn         ; zru®en° okna p©i chybà

; ------ chybovÇ hl†®en° - nedostatek pamàti

         mov       si,offset ChbTrMem
         call      far ptr Lin0MenF
         stc                                ; p©°znak chyby operace
         jmp       CreatTW9

; ------ inicializace p©°znakñ

CreatTW2:and       byte ptr es:[AWinPrm1],not bit1+bit2+bit3+bit5+bit7
         or        byte ptr es:[AWinPrm1],bit4   ; p©°znak okna stromu

; ------ vytvo©en° m°sta pro prvn° poloëku (ROOT)

         mov       di,AWinSoub              ; zaá†tek souborñ
         mov       cx,FileTSum              ; velikost poloëky stromu
         call      far ptr InsDat           ; vytvo©en° m°sta
         jc        CreatTW1                 ; chyba pamàti
         add       word ptr es:[AWinSouI],cx         ; posun tabulky indexñ
         add       word ptr es:[AWinKomI],cx         ; posun tabulky koment†©ñ
         inc       word ptr es:[AWinSouR]   ; á°taá naátenòch poloëek

; ------ uloëen° poloëky ROOT

         cld
         push      ax
         mov       al,ATRT + DIR            ; atributy poloëky
         stosb                              ; atributy
         mov       ax,word ptr es:[AWinDir]          ; aktivn° disk a ":"
         stosw
         mov       al,"\"
         stosb                              ; oddàlovaá cesty
         mov       al," "
         mov       cl,11-3                  ; zbytek jmÇna (CH=0)
         rep       stosb                    ; vymaz†n° zbytku jmÇna poloëky

         xor       ax,ax                    ; AX <- 0
         stosw
         stosw                              ; velikost

         mov       al,1*bit0 + 1*bit5
         stosb                              ; datum LOW (1.1.1980)

         mov       al,0
         mov       cl,FileTSum-(FileDate+1) ; zbytek poloëek
         rep       stosb                    ; vymaz†n° zbytku poloëky

         mov       byte ptr es:[di-FileTSum+FileTPar],bit2+bit4+bit7 ; parametry

         pop       ax

; ------ vytvo©en° m°sta pro index poloëky ROOT (za jmÇnem poloëky ROOT)

         mov       cl,3                     ; poáet bajtñ na index
         call      far ptr InsDat           ; vytvo©en° m°sta pro index
         jc        CreatTW1                 ; chyba pamàti
         add       word ptr es:[AWinKomI],cx         ; posun tabulky koment†©ñ
         inc       word ptr es:[AWinSouN]   ; á°taá zobrazenòch poloëek

         call      far ptr NormIAWn         ; normalizace adres tabulek

; ------ uloëen° indexu prvn° poloëky

         mov       byte ptr es:[di],AWinSoub AND 0fh ; adresa poloëky
         mov       word ptr es:[di+1],AWinSoub/16

; ------ naáten° uschovanÇho stromu z disku

         call      ReadTree                 ; naáten° stromu z disku

; ------ naáten° n†và®t° disku

         push      ax
         call      far ptr TestBreak
         jc        CreatTW6
         call      far ptr GetDat           ; adresa okna
         call      far ptr InitDInf         ; inicializace diskovòch informac°
         mov       al,es:[AWinDisk]         ; disk okna
         mov       di,AWinLab               ; n†và®t° disku
         call      far ptr GetVol           ; poskytnut° n†và®t° disku
         mov       es:[AWinLabN],cl         ; dÇlka n†và®t°
         jcxz      CreatTW6
         cmp       word ptr es:[AWinSouR],0 ; je nàjak† poloëka ?
         je        CreatTW6                 ; nen° ë†dn† poloëka ?
         mov       ax,ds:[VolDate]          ; datum n†và®t°
         mov       es:[AWinSoub+FileDate],ax ; datum ROOT
         mov       ax,ds:[VolTime]          ; áas n†và®t°
         mov       es:[AWinSoub+FileTime],ax ; áas ROOT
CreatTW6:pop       ax

         clc

; ------ n†vrat registrñ

CreatTW9:pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         ret

CreatTWn ENDP

; *****************************************************************************
;                                   InitTWn
;             inicializace kurzoru okna stromu pro aktivn° adres†©
; -----------------------------------------------------------------------------
; VSTUP: AX=á°slo segmentu okna
;        DS=datovò segment
; *****************************************************************************

InitTWn  PROC      FAR

; ------ £schova registrñ

         push      bx
         push      cx
         push      si
         push      es

; ------ vynulov†n° starÇho oznaáen° adres†©e

         call      far ptr GetDat           ; adresa okna
         mov       si,AWinSoub              ; zaá†tek poloëek
         mov       cx,es:[AWinSouR]         ; poáet naátenòch poloëek
         jcxz      InitTWn4                 ; ë†dn† poloëka ? (nenastane)
InitTWn2:and       byte ptr es:[si+FileTPar],not bit6 ; nen° to aktivn° adres†©
         add       si,FileTSum              ; adresa dal®° poloëky
         jns       InitTWn3
         sub       si,8000h                 ; normalizace offsetu
         mov       bx,es
         add       bx,8000h/16              ; normalizace segmentu
         mov       es,bx
InitTWn3:loop      InitTWn2                 ; dal®° poloëka

; ------ rozvinut° vàtve aktivn°ho adres†©e

InitTWn4:;call      far ptr GetDat           ; adresa okna
         ;mov       si,offset AWinDir        ; aktivn° adres†©
         push      ds
         pop       es                       ; datovò segment
         mov       si,offset AktPath        ; aktivn° adres†©
         push      cs
         call      near ptr SrcPathT        ; nalezen° cesty
         call      far ptr GetDat           ; nov† adresa okna
         mov       es:[AWinKurz],bx         ; nastaven° kurzoru

; ------ á°slo prvn° poloëky okna

         push      bx
         mov       ch,0                     ; CH <- 0
         mov       cl,ds:[NumRows]          ; vò®ka oken
         sub       cl,8                     ; bez okrajñ
         jnc       InitTWn6
         mov       cl,0                     ; omezen°
InitTWn6:shr       cx,1                     ; polovina okna
         sub       bx,cx                    ; poá†tek okna
         jnc       InitTWn7
         xor       bx,bx                    ; omezen° p©i podteáen°
InitTWn7:mov       es:[AWinFrst],bx         ; poá†teán° poloëka okna
         pop       bx

; ------ oznaáen° koncovÇ poloëky adres†©e jako aktivn° adres†©

         call      far ptr GetESPol         ; adresa aktivn° poloëky
         jc        InitTWn9
         or        byte ptr es:[si+FileTPar],bit6 ; je to aktivn° adres†©

; ------ n†vrat registrñ

InitTWn9:pop       es
         pop       si
         pop       cx
         pop       bx
         call      far ptr AktPathT         ; aktualizace stromu v oknà
         call      AktTSiz                  ; aktualizace velikost° adres†©ñ
         ret

InitTWn  ENDP

; *****************************************************************************
;                                   SrcPathT
;        nalezen° poloëky v oknà stromu podle cesty (mus° souhlasit disk)
;             pokud je p©°stupov† cesta uzav©ena, rozvine se
; -----------------------------------------------------------------------------
; VSTUP: AX=á°slo segmentu okna
;        ES:SI=poëadovan† cesta ASCIIZ
;        DS=datovò segment
; VùSTUP: BX=á°slo nalezenÇ koncovÇ poloëky adres†©e (nebo max.nalezenÇ poloëky)
;         CY=poloëka nenalezena (cesta nen° cel†)
; *****************************************************************************

SrcPathT PROC      FAR

; ------ £schova registrñ

         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es

; ------ p©°prava registrñ

         mov       bp,es                    ; BP <- segment adresy cesty
         mov       di,si                    ; DI <- offset adresy cesty
         xor       bx,bx                    ; BX <- 0 ukazatel á°sla poloëky
         mov       dl,0                     ; DL <- 0 hledan† hladina
         cmp       word ptr es:[di+1],"\:"  ; je ROOT ?
         jne       SrcPthT1                 ; nen° ROOT
         add       di,3                     ; p©eskoáen° oznaáen° ROOT

; ------ test, zda je jië konec cesty

SrcPthT1:inc       dx                       ; zvò®en° ukazatele hladiny
         mov       cx,bx                    ; CX <- nejvy®®° nalezen† poloëka
         mov       es,bp                    ; ES <- segment adresy cesty
         cmp       byte ptr es:[di],0       ; je dal®° podadres†© ?
         je        SrcPthT9                 ; nen° dal®° podadres†©

; ------ naáten° podadres†©e ES:SI (nen°-li je®tà naáten)

         call      far ptr GetPol           ; adresa poloëky -> ES:SI
         jc        SrcPthT9                 ; neplatn† poloëka
         test      byte ptr es:[si+FileTPar],bit0 ; je adres†© naáten ?
         jnz       SrcPthT2                 ; adres†© je jië naáten
         push      cs
         call      near ptr ReadTWn         ; naáten° adres†©e

; ------ rozvinut° tÇto vàtve o jednu hladinu

SrcPthT2:call      far ptr GetPol           ; znovu adresa poloëky
         push      bx
         mov       bl,0                     ; pouze jednu hladinu
         call      OpenDTWn                 ; rozvinut° adres†©e
         pop       bx

; ------ nalezen° zaá†tku dal®°ho podadres†©e

         mov       es,bp                    ; ES <- segment adresy cesty
         mov       si,di                    ; SI <- zaá†tek podadres†©e
SrcPthT3:inc       di
         mov       dh,es:[di-1]
         cmp       dh,"\"
         je        SrcPthT4
         or        dh,dh
         jnz       SrcPthT3
         dec       di                       ; n†vrat na konec cesty

; ------ dek¢dov†n° dal®°ho podadres†©e na tvar FCB

SrcPthT4:sub       si,DTAName               ; fiktivn° poloëka DTA
         call      far ptr GetBFCB          ; dek¢dov†n° na jmÇno FCB

; ------ adresa dal®° poloëky

SrcPthT5:inc       bx                       ; zvò®en° ukazatele poloëek
         call      far ptr GetPol           ; adresa dal®° poloëky
         jc        SrcPthT9                 ; nen° dal®° poloëka

; ------ test, zda je to poëadovan† hladina poloëky

         cmp       dl,es:[si+FileTLev]      ; je to hledan† hladina ?
         jb        SrcPthT5                 ; je to podadres†© - dal®°
         ja        SrcPthT8                 ; konec vàtve

; ------ porovn†n° jmÇna poloëky

         push      di
         push      cx
         inc       si                       ; zaá†tek jmÇna poloëky
         mov       di,si
         mov       si,offset FileFCB        ; jmÇno podcesty
         mov       cx,11                    ; dÇlka textu
         cld
         repe      cmpsb                    ; porovn†n° jmÇna
         pop       cx
         pop       di
         je        SrcPthT1                 ; nalezena shodn† poloëka
         ja        SrcPthT5                 ; dal®° poloëka

; ------ n†vrat registrñ

SrcPthT8:stc                                ; p©°znak chyby
SrcPthT9:mov       bx,cx                    ; BX <- nalezen† poloëka
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         ret

SrcPathT ENDP

; *****************************************************************************
;                                 EditDTWn
;                          ovl†d†n° okna stromu
; -----------------------------------------------------------------------------
; VSTUP: AX=á°slo segmentu okna
;        BX=kl†vesa
;        DS=datovò segment
; VùSTUP: CY=nebyla obsluha kl†vesy (BX nezmànàno)
;         NC=byla obsluha kl†vesy (BX=0)
; *****************************************************************************
;˛
EditDTWn PROC      FAR

; ------ £schova registrñ

         push      si
         push      es

; ------ test, zda je okno zapnuto

         call      far ptr TestAWin         ; je okno zapnuto ?
         jc        EditDTW9                 ; okno nen° zapnuto

; ------ adresa okna

         call      far ptr GetDat           ; adresa okna
         jc        EditDTW9                 ; neplatnÇ okno

; ------ test, zda je okno stromu

         test      byte ptr es:[AWinPrm1],bit4 ; je to strom ?
         jz        EditDTW7                 ; nen° to strom

; ------ adresa kurzoru

         push      bx
         mov       bx,es:[AWinKurz]         ; kurzor
         call      far ptr GetESPol         ; adresa poloëky
         pop       bx
         jc        EditDTW9                 ; chyba - neplatn† poloëka

; ------ uzav©en° vàtve

         cmp       bl,"-"
         jne       EditDTW1
         call      ClosDTWn                 ; uzav©en° vàtve stromu
         jmp       short EditDTW4

; ------ rozvinut° vàtve

EditDTW1:cmp       bl,"+"
         jne       EditDTW2
         mov       bl,bit1                  ; podadres†©e se nerozv°j°
         jmp       short EditDTW3

; ------ rozvinut° vàtve do maxim†ln° hloubky

EditDTW2:cmp       bl,"*"
         jne       EditDTW5
         mov       bl,bit1+bit2             ; podadres†©e se rozv°j°
EditDTW3:call      OpenDTWn                 ; otev©en° celÇ vàtve stromu
EditDTW4:jmp       short EditDTW8

; ------ posun kurzoru vlevo (k nië®° hladinà)

EditDTW5:cmp       bx,4b00h
         jne       EditDTW6
         call      LeftDTWn                 ; posun kurzoru vlevo
         jmp       short EdiDTW82

; ------ neplatn† kl†vesa

EditDTW7:stc
         jmp       short EditDTW9

; ------ posun kurzoru vpravo (k vy®®° hladinà)

EditDTW6:cmp       bx,4d00h
         jne       EditDTW7
         call      RghtDTWn                 ; posun kurzoru vpravo

; ------ n†vrat registrñ

EdiDTW82:call      far ptr InitQVw          ; inicializace rychlovyhled†v†n°
EditDTW8:call      far ptr QSrcEnd          ; ukonáen° rychlovyhled†v†n°
         call      far ptr AktPathT         ; aktualizace stromu v oknà
         call      AktTSiz                  ; aktualizace velikost° adres†©ñ
         xor       bx,bx                    ; p©°znak obsluhy funkce
EditDTW9:pop       es
         pop       si
         ret

EditDTWn ENDP

; -----------------------------------------------------------------------------
;                               LeftDTWn
;                   posun kurzoru v oknà stromu vlevo
; -----------------------------------------------------------------------------
; VSTUP: AX=á°slo segmentu
;        DS=datovò segment
; VùSTUP: CY=je jië z†kladn° hladina
; -----------------------------------------------------------------------------

LeftDTWn PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      si
         push      bp
         push      es

; ------ adresa okna

         call      far ptr GetDat           ; adresa okna
         jc        LeftDTW9                 ; neplatnÇ okno
         mov       bp,es                    ; £schova adresy okna

; ------ adresa kurzoru

         mov       bx,es:[AWinKurz]         ; á°slo kurzoru
         call      far ptr GetESPol         ; adresa kurzoru ES:SI
         jc        LeftDTW9                 ; nen° kurzor
         mov       al,es:[si+FileTLev]      ; hladina poloëky
         cmp       al,1                     ; je to poloëka ROOT ?
         jb        LeftDTW9                 ; je to jië ROOT

; ------ sn°ëen° ukazatele kurzoru

LeftDTW3:or        bx,bx
         jz        LeftDTW9                 ; je jië ROOT
         dec       bx
         mov       es,bp
         mov       es:[AWinKurz],bx         ; novò kurzor

; ------ test, zda to je jië nië®° poloëka

         call      far ptr GetESPol
         jc        LeftDTW9
         cmp       al,es:[si+FileTLev]      ; nalezena nië®° hladina ?
         jbe       LeftDTW3                 ; nalezen° nië®° hladiny

; ------ n†vrat registrñ

LeftDTW9:pop       es
         pop       bp
         pop       si
         pop       bx
         pop       ax
         ret

LeftDTWn ENDP

; -----------------------------------------------------------------------------
;                               RghtDTWn
;                   posun kurzoru v oknà stromu vpravo
; -----------------------------------------------------------------------------
; VSTUP: AX=á°slo segmentu
;        DS=datovò segment
; VùSTUP: CY=nenalezena dal®° hladina
; -----------------------------------------------------------------------------

RghtDTWn PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      si
         push      bp
         push      es

; ------ adresa okna

         call      far ptr GetDat           ; adresa okna
         jc        RghtDTW9                 ; neplatnÇ okno
         mov       bp,es                    ; £schova adresy okna

; ------ adresa kurzoru

         mov       bx,es:[AWinKurz]         ; á°slo kurzoru
         call      far ptr GetESPol         ; adresa kurzoru ES:SI
         jc        RghtDTW9                 ; nen° kurzor
         mov       al,es:[si+FileTLev]      ; hladina poloëky
         inc       ax                       ; hledan† hladina poloëky
         mov       cx,1                     ; kladnò p©°rustek

; ------ zvò®en° ukazatele kurzoru

RghtDTW3:add       bx,cx                    ; zvò®en° ukazatele kurzoru
         mov       es,bp                    ; adresa okna
         call      far ptr GetESPol         ; adresa poloëky BX
         jnc       RghtDTW4                 ; je dal®° poloëka OK

; ------ zmàna smàru hled†n°

         dec       cx                       ; zmàna smàru
         jnz       RghtDTW9                 ; byl jië z†pornò smàr - nenalezeno
         dec       cx                       ; hled†n° zpàt
         jmp       short RghtDTW3           ; hled†n° zpàt

; ------ test, zda je to hledan† poloëka

RghtDTW4:cmp       al,es:[si+FileTLev]      ; nalezena vy®®° hladina ?
         jne       RghtDTW3                 ; nalezen° vy®®° hladiny

; ------ uloëen° á°sla nalezenÇ poloëky

         mov       es,bp                    ; adresa okna
         mov       es:[AWinKurz],bx         ; novò kurzor

; ------ n†vrat registrñ

RghtDTW9:pop       es
         pop       bp
         pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

RghtDTWn ENDP

; -----------------------------------------------------------------------------
;                                    ClosDTWn
;                         uzav©en° vàtve v oknà stromu
; -----------------------------------------------------------------------------
; VSTUP: AX=á°slo segmentu
;        ES:SI=adresa adres†©e, kterò se m† uzav©°t (normalizov†no)
;        DS=datovò segment
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) á°slo okna
;                   SS:[BP-4] (2) adresa okna
;                   SS:[BP-6] (2) segment adresy vòchoz° poloëky
;                   SS:[BP-8] (2) offset adresy vòchoz° poloëky
;                   SS:[BP-10] (2) segment adresy za posledn° poloëkou
;                   SS:[BP-12] (2) offset adresy za posledn° poloëkou
;                   SS:[BP-14] (2) segment adresy tabulky indexñ
;                   SS:[BP-16] (2) offset adresy tabulky indexñ
;                   SS:[BP-18] (2) poáet poloëek v tabulce indexñ
; -----------------------------------------------------------------------------

ClosDTWn PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,sp
         sub       sp,18

; ------ inicializace lok†ln°ch promànnòch

         mov       ss:[bp-2],ax             ; á°slo okna
         mov       ss:[bp-6],es             ; segment adresy vòchoz° poloëky
         mov       ss:[bp-8],si             ; offset adresy vòchoz° poloëky
         push      es                       ; segment adresy poloëky
         call      far ptr GetDat           ; adresa okna
         mov       ss:[bp-4],es             ; adresa okna
         mov       ax,word ptr es:[AWinSouI]         ; offset tabulky indexñ
         mov       ss:[bp-16],ax            ; offset tabulky indexñ
         mov       ax,word ptr es:[AWinSouI+2]       ; adresa indexovÇ tabulky - segment
         add       ax,ss:[bp-4]             ; + adresa okna
         mov       ss:[bp-14],ax            ; segment tabulky indexñ
         mov       ax,es:[AWinSouN]         ; poáet zobrazenòch poloëek
         mov       ss:[bp-18],ax            ; poáet poloëek v tabulce indexñ
         pop       es                       ; segment adresy poloëky

; ------ p©°prava k vyhled†n° konce vàtve

         mov       bl,es:[si+FileTLev]      ; hladina vòchoz°ho adres†©e
         mov       dx,es                    ; DX <- segment poloëky
         and       byte ptr es:[si+FileTPar],not bit2 ; nejsou rozvinuty podadres†©e
;         mov       ax,es:[si+FileTSiz]      ; souáet velikost° poloëek
;         mov       es:[si+FileSize],ax      ; vòchoz° velikost adres†©e
;         mov       ax,es:[si+FileTSiz+2]
;         mov       es:[si+FileSize+2],ax
         jmp       short ClsDTW22

; ------ oznaáen°, ëe poloëka nen° rozvinuta

ClosDTW2:and       byte ptr es:[si+FileTPar],not bit2+bit7 ; podadr. nerozvinuty

;; ------ velikost poloëky se p©iáte k velikosti vòchoz°ho adres†©e
;
;         push      si
;         mov       ax,es:[si+FileTSiz]      ; souáet velikost° poloëek
;         mov       cx,es:[si+FileTSiz+2]
;         les       si,ss:[bp-8]             ; adresa vòchoz° poloëky
;         add       es:[si+FileSize],ax      ; p©iáten° k velikosti adres†©e
;         adc       es:[si+FileSize+2],cx
;         pop       si

; ------ adresa dal®° poloëky

ClsDTW22:add       si,FileTSum              ; offset dal®° poloëky
         mov       ax,si                    ; offset dal®° poloëky
         and       si,0fh                   ; normalizace offsetu poloëky
         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; p©evod offsetu na segment
         add       dx,ax                    ; normalizace segmentu poloëky
         mov       es,dx                    ; novò segment adresy

; ------ test, zda je to platn† poloëka

         cmp       dx,ss:[bp-14]            ; je to platn† poloëka ?
         jae       ClosDTW3                 ; je konec poloëek

; ------ test, zda je konec vàtve

         cmp       bl,es:[si+FileTLev]      ; je to konec vàtve ?
         jb        ClosDTW2                 ; nen° je®tà konec vàtve

; ------ £schova adresy konce vàtve

ClosDTW3:mov       ss:[bp-10],es            ; adresa za posledn° poloëkou vàtve
         mov       ss:[bp-12],si

; ------ p©°prava k prohled†n° tabulky indexñ

         les       di,ss:[bp-16]            ; adresa tabulky indexñ
         mov       cx,ss:[bp-18]            ; poáet poloëek v tabulce indexñ
         xor       bx,bx                    ; ukazatel á°sla poá†teán° poloëky
         mov       ax,ss:[bp-6]             ; segment adresy vòchoz° poloëky
         sub       ax,ss:[bp-4]             ; segment adresy relativnà
         jcxz      ClosDTW9                 ; nen° ë†dn† poloëka (?)
         cld

; ------ vyhled†n° zaá†tku vàtve v tabulce indexñ

ClosDTW4:inc       bx                       ; zvò®en° ukazatele á°sla poloëky
         inc       di                       ; offset se ignoruje
         scasw                              ; je to hledan† poloëka ?
         jbe       ClosDTW5                 ; nalezena hledan† poloëka
         loop      ClosDTW4                 ; test dal®° poloëky

; ------ vyhled†n° konce vàtve v tabulce indexñ

         inc       cx
ClosDTW5:dec       cx                       ; bez tÇto poloëky
         xor       dx,dx                    ; á°taá poloëek ke zru®en°
         mov       ax,ss:[bp-10]            ; segment adresy za posledn° poloëkou
         sub       ax,ss:[bp-4]             ; segment adresy relativnà
         jcxz      ClosDTW9                 ; je konec seznamu - nen° co ru®it
ClosDTW6:cmp       ax,es:[di+1]
         jbe       ClosDTW7                 ; nalezena hledan† poloëka
         inc       dx                       ; zvò®en° á°taáe poloëek
         inc       di                       ; offset se ignoruje
         inc       di
         inc       di
         loop      ClosDTW6

; ------ zru®en° á†sti indexovÇ tabulky

ClosDTW7:mov       cx,dx                    ; CX <- poáet poloëek k ru®en°

         push      cx

         shl       cx,1
         add       cx,dx                    ; poáet bajtñ ke zru®en°
         jz        ClosDTW8                 ; nen° co ru®it
         mov       di,bx                    ; DI <- á°slo poá†teán° poloëky
         shl       di,1
         add       di,bx                    ; offset indexu
         add       di,ss:[bp-16]            ; adresa indexu
         mov       dx,es                    ; segment tabulky indexñ
         sub       dx,ss:[bp-4]             ; offset segmentu tabulky indexñ
         xor       bx,bx                    ; poáet ru®enòch bajtñ HIGH
         mov       ax,ss:[bp-2]             ; segment okna
         call      far ptr DelSDat          ; zru®en° á†sti tabulky indexñ

ClosDTW8:pop       cx                       ; poáet ru®enòch poloëek

         mov       es,ss:[bp-4]             ; segment okna
         sub       es:[AWinSouN],cx         ; sn°ëen° poátu zobrazenòch poloëek

; ------ n†vrat registrñ

ClosDTW9:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

ClosDTWn ENDP

; -----------------------------------------------------------------------------
;                                 OpenDTWn
;                      otev©en° vàtve v oknà stromu
; -----------------------------------------------------------------------------
; VSTUP: AX=á°slo segmentu
;        BL=p©°znaky  bit1: 1=p©en†®° se oznaáen° adres†©e
;                     bit2: 1=rozv°j° se v®echny podadres†©e (ostatn° bity = 0)
;        ES:SI=adresa adres†©e, kterò se m† otev©°t
;        DS=datovò segment
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) á°slo okna
;                   SS:[BP-4] (2) adresa okna
;                   SS:[BP-6] (2) segment adresy aktu†ln° poloëky
;                   SS:[BP-8] (2) offset adresy aktu†ln° poloëky
;                   SS:[BP-10] (2) segment adresy tabulky indexñ
;                   SS:[BP-12] (2) offset adresy v tabulce indexñ
;                   SS:[BP-14] (2) poáet zbylòch poloëek v tabulce indexñ
;                   SS:[BP-15] (1) parametry podadres†©ñ:
;                                       bit 1: 1=p©en†®° se oznaáen° adres†©e
;                                       bit 2: 1=rozv°j° se v®echny podadres†©e
;                   SS:[BP-16] (1) parametr podadres†©ñ:
;                                       bit 6: p©°znak oznaáen° poloëky
; -----------------------------------------------------------------------------

OpenDTWn PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,sp
         sub       sp,16

; ------ £schova ukazatelñ

         mov       ss:[bp-2],ax             ; á°slo okna
         mov       ss:[bp-6],es             ; segment adresy vòchoz° poloëky
         mov       ss:[bp-8],si             ; offset adresy vòchoz° poloëky

; ------ nejsou-li podadres†©e, nemñëe bòt rozvinuto

         test      byte ptr es:[si+FileTPar],bit1 ; jsou podadres†©e ?
         jnz       OpenDTW0                 ; jsou podadres†©e OK
         and       byte ptr es:[si+FileTPar],not bit2 ; nen° rozvinuto
         jmp       OpenDTW9

; ------ inicializace lok†ln°ch promànnòch

OpenDTW0:or        byte ptr es:[si+FileTPar],bit2 ; podadres†©e rozvinuty
         mov       ss:[bp-15],bl            ; parametry podadres†©ñ
         mov       bl,es:[si+FileAtr]       ; atributy poloëky
         and       bl,ATRO                  ; p©°znak oznaáen° poloëek
         mov       ss:[bp-16],bl            ; p©°znak oznaáen° poloëek
         mov       bl,es:[si+FileTLev]      ; hladina vòchoz° poloëky
         inc       bx                       ; hladina podadres†©ñ
         call      far ptr GetDat           ; adresa okna
         mov       ss:[bp-4],es             ; adresa okna
         mov       ax,word ptr es:[AWinSouI]         ; offset tabulky indexñ
         mov       ss:[bp-12],ax            ; offset tabulky indexñ
         mov       ax,word ptr es:[AWinSouI+2]       ; adresa indexovÇ tabulky - segment
         add       ax,ss:[bp-4]             ; + adresa okna
         mov       ss:[bp-10],ax            ; segment tabulky indexñ
         mov       ax,es:[AWinSouN]         ; poáet zobrazenòch poloëek
         mov       ss:[bp-14],ax            ; poáet zbylòch poloëek indexñ

; ------ je pouze velikost adres†©e

OpenDTW1:
;         les       si,ss:[bp-8]             ; adresa poloëky
;         mov       ax,es:[si+FileTSiz]      ; souáet velikost° poloëek
;         mov       es:[si+FileSize],ax      ; to je velikost poloëek adres†©e
;         mov       ax,es:[si+FileTSiz+2]
;         mov       es:[si+FileSize+2],ax

; ------ adresa dal®° poloëky podadres†©e

OpenDTW2:add       word ptr ss:[bp-8],FileTSum ; zvò®en° ukazatele adresy poloëky
         mov       ax,ss:[bp-8]             ; offset adresy poloëky
         and       word ptr ss:[bp-8],0fh   ; normalizace offsetu
         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; p©evod offsetu na segment
         add       ss:[bp-6],ax             ; posun segmentu adresy

; ------ test, zda to je platn† poloëka (staá° porovnat segment, jsou 2 odstavce/poloëku)

         les       si,ss:[bp-8]             ; adresa dal®° poloëky
         mov       ax,es                    ; segment adresy
         cmp       ax,ss:[bp-10]            ; je to je®tà platn† poloëka ?
         jb        OpnDTW22                 ; je to je®tà platn† poloëka
OpnDTW21:jmp       OpenDTW9                 ; nen° dal®° poloëka

; ------ test, zda je to hledan† poloëka podadres†©e

OpnDTW22:mov       bh,ss:[bp-15]            ; parametr rozvinut° podadres†©ñ
         and       bh,bit2                  ; p©°znak rozvinut° adres†©ñ
         cmp       bl,es:[si+FileTLev]      ; je to hledanò podadres†© ?
         ja        OpnDTW21                 ; konec vàtve adres†©ñ
         je        OpenDTW3                 ; je to hledanò podadres†©
         or        bh,bh                    ; rozv°j° se podadres†©e ?
         jz        OpenDTW2                 ; podadres†©e se nerozv°j°

; ------ p©°prava k vyhled†n° indexu poloëky

OpenDTW3:or        es:[si+FileTPar],bh      ; p©°znak rozvinut° poloëky

         sub       ax,ss:[bp-4]             ; offset segmentu poloëky
         mov       bh,ss:[bp-8]             ; offset adresy poloëky
         les       di,ss:[bp-12]            ; adresa v tabulce indexñ
         cmp       word ptr ss:[bp-14],0    ; je dal®° poloëka indexu ?
         je        OpenDTW5                 ; nen° dal®° poloëka indexu

; ------ zvò®en° ukazatele v tabulce indexñ

OpenDTW4:add       di,3                     ; adresa dal®°ho indexu
         mov       ss:[bp-12],di            ; £schova adresy indexu
         dec       word ptr ss:[bp-14]      ; sn°ëen° á°taáe zbylòch poloëek
         jz        OpenDTW5                 ; nen° dal®° poloëka

; ------ test, zda je to hledan† poloëka

         cmp       ax,es:[di+1]             ; porovn†n° segmentu poloëky
         ja        OpenDTW4                 ; nen° je®tà dosaëeno poloëky
         jb        OpenDTW5                 ; je jië nalezena dal®° poloëka

; ------ poloëka je nalezena

         test      byte ptr ss:[bp-15],bit2 ; rozv°j° se podadres†©e ?
         jz        OpenDTW2                 ; podadres†©e se nerozv°j°
         jmp       OpenDTW1                 ; plat° jen velikost adres†©e

; ------ vytvo©en° m°sta pro novò index

OpenDTW5:push      ax
         push      bx
         mov       ax,ss:[bp-2]             ; á°slo okna
         xor       bx,bx                    ; poáet vkl†danòch bajtñ HIGH
         mov       cx,3                     ; vkl†daj° se 3 bajty
         mov       dx,es                    ; segment tabulky indexñ
         sub       dx,ss:[bp-4]             ; offset segmentu tabulky
         call      far ptr InsSDat          ; vytvo©en° m°sta pro index
         pop       bx
         pop       ax
         jc        OpnDTW21                 ; chyba pamàti

; ------ uloëen° indexu poloëky

         mov       es:[di],bh               ; offset adresy poloëky
         mov       es:[di+1],ax             ; offset segmentu poloëky

; ------ nastaven° p©°znakñ poloëky

         les       si,ss:[bp-8]             ; adresa poloëky

         or        byte ptr es:[si+FileTPar],bit7 ; poloëka zobrazena
         test      byte ptr ss:[bp-15],bit1 ; p©en†®° se oznaáen° adres†©ñ ?
         jz        OpnDTW82                 ; oznaáen° se nep©en†®°
         mov       al,ss:[bp-16]            ; p©°znak oznaáen° poloëky
         and       byte ptr es:[si+FileAtr],not ATRO ; zru®en° oznaáen°
         or        es:[si+FileAtr],al       ; p©°znak oznaáen° poloëky

; ------ korekce kurzoru

OpnDTW82:mov       es,ss:[bp-4]             ; segment okna
         mov       ax,es:[AWinSouN]         ; starò poáet poloëek
         sub       ax,ss:[bp-14]            ; á°slo vkl†danÇ poloëky
         cmp       ax,es:[AWinKurz]         ; odsouv† se kurzor ?
         ja        OpnDTW85                 ; kurzor se neodsouv†
         inc       word ptr es:[AWinKurz]   ; posun kurzoru
         inc       word ptr es:[AWinFrst]   ; posun poá†tku okna

; ------ posun ukazatelñ

OpnDTW85:inc       word ptr ss:[bp-14]      ; zvò®en° á°taáe zbylòch poloëek
         inc       word ptr es:[AWinSouN]   ; zvò®en° á°taáe poloëek
         add       word ptr es:[AWinKomI],3 ; posun tabulky koment†©ñ
         call      far ptr NormIAWn         ; normalizace adres tabulek
         jmp       OpenDTW2                 ; dal®° poloëka

; ------ n†vrat registrñ

OpenDTW9:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

OpenDTWn ENDP

; -----------------------------------------------------------------------------
;                                   ReadTree
;                            naáten° stromu z disku
;             okno stromu mus° obsahovat 1 poloëku ROOT (a ë†dnÇ jinÇ)
; -----------------------------------------------------------------------------
; VSTUP: AX=á°slo okna stromu
;        DS=datovò segment
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) á°slo okna stromu
;                   SS:[BP-4] (2) adresa okna stromu
;                   SS:[BP-6] (2) ukl†dac° adresa poloëek - segment
;                   SS:[BP-8] (2) ukl†dac° adresa poloëek - offset
;                   SS:[BP-10] (2) á°taá zbylòch poloëek stromu
;
;                   SS:[BP-12] (2) á°slo segmentu bufferu (0=nen°)
;                   SS:[BP-14] (2) velikost bufferu (bajtñ; zarovn†no na FileTSum)
;                   SS:[BP-16] (2) poáet bajtñ naátenòch v bufferu
;                   SS:[BP-18] (2) adresa bufferu (segment)
;                   SS:[BP-20] (2) offset átec° adresy z bufferu (-FileTSum=nen°)
;                   SS:[BP-22] (2) offset zapisovac° adresy z bufferu
;
;                   SS:[BP-24] (2) identifik†tor vstupn°ho souboru (0=nen°)
;                   SS:[BP-26] (2) ... identifik†tor vòstupn°ho souboru (0=nen°)
;                              .... (FileMax) vòstupn° soubor (rezervov†no)
;                              (FileMax) vstupn° soubor
; -----------------------------------------------------------------------------
;˛
ReadTree PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,sp
         sub       sp,26 + 2*FileMax

; ------ lok†ln° promànnÇ

         mov       ss:[bp-2],ax             ; á°slo okna stromu
         xor       bx,bx
         mov       word ptr ss:[bp-12],bx   ; nen° datovò buffer
         mov       word ptr ss:[bp-16],bx   ; v bufferu nejsou data
         mov       word ptr ss:[bp-22],bx   ; ukazatel z†pisovÇ adresy z bufferu
         mov       word ptr ss:[bp-24],bx   ; nen° vstupn° soubor
         mov       word ptr ss:[bp-26],bx   ; nen° vòstupn° soubor
         mov       word ptr ss:[bp-20],-FileTSum ; offset átec° adresy z bufferu

; ------ adresa okna stromu

         call      far ptr GetDat           ; adresa okna stromu
         jnc       ReadTre1
ReadTre0:jmp       ReadTre9

ReadTre1:test      byte ptr es:[AWinPrm1],bit4 ; je to okno stromu ?
         jz        ReadTre0                 ; nen° to okno stromu

; ------ vytvo©en° pracovn°ho bufferu

         mov       bx,1000                  ; asi tak velikost bufferu
         call      far ptr CreatDat         ; vytvo©en° bufferu
         jc        ReadTre0                 ; chyba pamàti
         mov       ss:[bp-12],ax            ; á°slo bufferu
         call      far ptr GetDat           ; adresa bufferu
         jc        ReadTre0                 ; chyba (ale zde nenastane)
         mov       ss:[bp-18],es            ; adresa bufferu

         xchg      ax,bx                    ; AX <- velikost bufferu
         cmp       ax,-FileTSum-10          ; rezerva na konci bufferu
         jb        ReadTr12
         mov       ax,-FileTSum-10          ; omezen° velikosti bufferu
ReadTr12:xor       dx,dx
         mov       cx,FileTSum              ; poáet bajtñ na poloëku
         div       cx                       ; vòpoáet poátu poloëek v bufferu
         mul       cx                       ; zarovnan† velikost bufferu
         mov       ss:[bp-14],ax            ; velikost bufferu (bajtñ)

; ------ oprava adresy okna stromu, p©°prava oznaáen° poloëky ROOT

         mov       ax,ss:[bp-2]             ; á°slo okna stromu
         call      far ptr GetDat           ; adresa okna stromu
         mov       ss:[bp-4],es             ; nov† adresa okna stromu
         mov       dx,word ptr es:[AWinDir]          ; hledanò ROOT ("disk:")

; ------ sestaven° jmÇna vstupn°ho souboru

         mov       si,offset FileNTre       ; soubor "$DOSMAN$.TRE"
         mov       di,sp                    ; buffer v z†sobn°ku
         push      ss
         pop       es
         call      far ptr TempFile         ; sestaven° jmÇna souboru

; ------ otev©en° souboru pro áten°

         mov       si,sp                    ; jmÇno souboru
         call      far ptr OpenR            ; otev©en° souboru pro áten°
         jc        ReadTre0                 ; soubor nenalezen
         mov       ss:[bp-24],ax            ; identifik†tor vstupn°ho souboru

; ------ nalezen° poëadovanÇ poloëky ROOT

ReadTre2:call      ReadTNxt                 ; naáten° dal®° poloëky ze souboru
ReadTr20:jc        ReadTre0                 ; nen° dal®° poloëka
         cmp       byte ptr es:[si+FileTLev],0 ; je to ROOT ?
         jne       ReadTre2                 ; nen° to ROOT - dal®° poloëka
         cmp       dx,word ptr es:[si+FileName]      ; je to hledan† poloëka ROOT ?
         jne       ReadTre2                 ; nalezen° poëadovanÇ poloëky ROOT

; ------ p©enesen° poloëky ROOT do okna

         push      ds
         push      es
         pop       ds                       ; DS <- segment nalezenÇ poloëky
         mov       es,ss:[bp-4]             ; adresa okna stromu
         mov       di,AWinSoub              ; adresa poloëky ROOT v oknà
         mov       cx,FileTSum              ; dÇlka poloëky
         cld
         rep       movsb                    ; uloëen° poloëky
         pop       ds
         and       byte ptr es:[di+FileTPar-FileTSum],not bit0+bit6 ; nen° ovà©en
         and       byte ptr es:[di+FileAtr-FileTSum],not ATRU+ATRO ; poloëka nen° oznaáena
         or        byte ptr es:[di+FileTPar-FileTSum],bit4+bit7; ROOT je zobrazen

; ------ nastaven° maxim†ln° velikosti bufferu (nebudou se zat°m ukl†dat indexy)

         call      far ptr GetFree          ; poskytnut° volnÇ pamàti -> BX
         sub       bx,100h                  ; ponech† se rezerva pro help atd.
         jb        ReadTr20                 ; chyba pamàti
         mov       ax,16
         mul       bx                       ; p©epoáet na bajty
         mov       cx,FileTSum              ; poáet bajtñ na poloëku
         div       cx                       ; vòpoáet poátu poloëek
         mov       ss:[bp-10],ax            ; á°taá zbylòch poloëek
         mul       cx                       ; p©epoáet zpàt na bajty
         xchg      ax,cx                    ; CX <- poáet bajtñ LOW
         mov       bx,dx                    ; BX <- poáet bajtñ HIGH
         mov       ax,ss:[bp-2]             ; á°slo okna stromu
         xor       dx,dx                    ; DX <- 0 (adresa HIGH)
         mov       di,AWinSoub+FileTSum     ; sem se vloë° novÇ poloëky
         call      far ptr InsSDat          ; vytvo©en° m°sta pro poloëky
         jc        ReadTr20                 ; nàjak† chyba

; ------ korekce adres tabulek (byl posun o BX:CX)

         mov       es,ss:[bp-4]             ; adresa stromu
         mov       ax,16
         xchg      ax,cx                    ; AX <- velikost vkl†danòch dat
         mov       dx,bx                    ; DX <- poáet bajtñ HIGH
         div       cx                       ; p©epoáet na odstavce
         add       word ptr es:[AWinSouI],dx         ; posun offsetu
         add       word ptr es:[AWinSouI+2],ax       ; posun segmentu indexovÇ tabulky
         add       word ptr es:[AWinKomI],dx         ; posun offsetu
         add       word ptr es:[AWinKomI+2],ax       ; posun segmentu indexovÇ tabulky
         call      far ptr NormIAWn         ; normalizace adres tabulek

; ------ oprava adresy bufferu

         mov       ax,ss:[bp-12]            ; á°slo bufferu
         call      far ptr GetDat           ; adresa bufferu
         mov       ss:[bp-18],es            ; nov† adresa bufferu

; ------ p©°prava ukl†dac° adresy

         mov       word ptr ss:[bp-8],(AWinSoub+FileTSum) AND 0fh ; offset adresy
         mov       ax,ss:[bp-4]             ; adresa okna stromu
         add       ax,(AWinSoub+FileTSum)/16
         mov       ss:[bp-6],ax             ; segment ukl†dac° adresy poloëek

; ------ nalezen° dal®° poloëky k naáten°

         mov       bl,1                     ; ukazatel hladin poloëek
ReadTre3:call      ReadTNxt                 ; naáten° dal®° poloëky ze souboru
         jc        ReadTre5                 ; nen° dal®° poloëka
         cmp       byte ptr es:[si+FileTLev],0 ; je to ROOT ?
         je        ReadTre5                 ; je to ROOT - konec
         cmp       byte ptr es:[si+FileName+1],":" ; oznaáen° ROOT dal®°ho disku
         je        ReadTre5                 ; dal®° disk - konec
         cmp       bl,es:[si+FileTLev]      ; je hladina v po©†dku ?
         jb        ReadTre3                 ; p©°li® vysok† hladina
         cmp       bl,32                    ; je jië maxim†ln° hloubka ?
         jae       ReadTre4                 ; je jië maxim†ln° hladina
         mov       bl,es:[si+FileTLev]      ; aktu†ln° hladina
         inc       bx                       ; moën† p©°®t° hladina

; ------ test, zda je volnÇ m°sto pro dal®° poloëku

ReadTre4:cmp       word ptr ss:[bp-10],0    ; je voln† dal®° poloëka ?
         je        ReadTre5                 ; nen° voln† dal®° poloëka

; ------ uloëen° poloëky

         push      ds
         push      es
         pop       ds                       ; DS <- segment nalezenÇ poloëky
         les       di,ss:[bp-8]             ; ukazatel adresy poloëky
         mov       cx,FileTSum              ; dÇlka poloëky
         cld
         rep       movsb                    ; uloëen° poloëky
         pop       ds
         and       byte ptr es:[di+FileTPar-FileTSum],not bit0+bit4+bit6+bit7
         and       byte ptr es:[di+FileAtr-FileTSum],not ATRU+ATRO ; poloëka nen° oznaáena
         or        byte ptr es:[di+FileAtr-FileTSum],ATRT ; je to platn† poloëka

; ------ nov† ukl†dac° adresa poloëky

         mov       ax,di                    ; offset novÇ adresy
         and       di,0fh                   ; normalizace offsetu
         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; p©evod offsetu na segment
         mov       cx,es                    ; segment ukl†dac° adresy
         add       ax,cx                    ; p©enos z offsetu
         mov       ss:[bp-8],di             ; novò offset adresy
         mov       ss:[bp-6],ax             ; novò segment adresy

; ------ korekce ukazatelñ

         dec       word ptr ss:[bp-10]      ; sn°ëen° á°taáe zbylòch poloëek
         mov       es,ss:[bp-4]             ; adresa okna stromu
         inc       word ptr es:[AWinSouR]   ; zvò®en° á°taáe souborñ
         jmp       short ReadTre3           ; dal®° poloëka

; ------ zru®en° datovÇho bufferu

ReadTre5:mov       ax,ss:[bp-12]            ; segment bufferu
         call      far ptr DelSeg           ; zru®en° bufferu
         mov       word ptr ss:[bp-12],0    ; oznaáen°, ëe je zru®enò

; ------ zmen®en° velikosti segmentu na minimum

         mov       ax,FileTSum              ; poáet bajtñ na poloëku
         mul       word ptr ss:[bp-10]      ; poáet nevyuëitòch bajtñ
         xchg      ax,cx                    ; CX <- poáet bajtñ k ru®en° LOW
         mov       bx,dx                    ; BX <- poáet bajtñ k ru®en° HIGH
         mov       dx,ss:[bp-6]             ; segment ukl†dac° adresy
         sub       dx,ss:[bp-4]             ; segment adresy relativnà
         mov       di,ss:[bp-8]             ; offset ukl†dac° adresy
         mov       ax,ss:[bp-2]             ; á°slo okna
         call      far ptr DelSDat          ; zru®en° nevyuëitòch dat

; ------ korekce adres tabulek

         mov       es,ss:[bp-4]             ; adresa stromu
         mov       ax,16
         xchg      ax,cx                    ; AX <- velikost ru®enòch dat LOW
         mov       dx,bx                    ; DX <- velikost ru®enòch dat HIGH
         div       cx                       ; p©epoáet na odstavce

         sub       word ptr es:[AWinSouI],dx         ; sn°ëen° offsetu
         jnc       ReadTr52
         add       word ptr es:[AWinSouI],100h ; korekce offsetu
         sub       word ptr es:[AWinSouI+2],100h/16 ; korekce segmentu
ReadTr52:sub       word ptr es:[AWinSouI+2],ax       ; oprava adresy indexovÇ tabulky

         sub       word ptr es:[AWinKomI],dx         ; sn°ëen° offsetu
         jnc       ReadTr54
         add       word ptr es:[AWinKomI],100h ; korekce offsetu
         sub       word ptr es:[AWinKomI+2],100h/16 ; korekce segmentu
ReadTr54:sub       word ptr es:[AWinKomI+2],ax       ; oprava adresy indexovÇ tabulky
         call      far ptr NormIAWn         ; normalizace adres tabulek

; ------ rozvinut° poloëek

         mov       ax,ss:[bp-2]             ; á°slo okna
         xor       bx,bx                    ; BX <- 0 ukazatel á°sla poloëky
ReadTre8:mov       es,ss:[bp-4]             ; adresa okna
         call      far ptr GetESPol         ; adresa poloëky -> ES:SI
         jc        ReadTr88                 ; nen° dal®° poloëka
         test      byte ptr es:[si+FileTPar],bit2 ; jsou podadres†©e rozvinuty ?
         jz        ReadTr81                 ; nejsou rozvinuty
         push      bx
         mov       bl,0                     ; p©°znak - nerozv°j° se podvàtve
         call      OpenDTWn                 ; rozvinut° vàtve
         pop       bx
ReadTr81:inc       bx                       ; zvò®en° ukazatele poloëek
         jmp       short ReadTre8           ; dal®° poloëka

; ------ aktualizace oznaáen° poloëek

ReadTr88:
;call      AktTSiz                  ; aktualizace velikost° adres†©ñ
         clc

; ------ zru®en° pracovn°ho bufferu

ReadTre9:pushf
         mov       ax,ss:[bp-12]            ; segment bufferu
         call      far ptr DelSeg           ; zru®en° bufferu
         mov       ax,ss:[bp-24]            ; vstupn° soubor
         call      far ptr ClosFile         ; uzav©en° vstupn°ho souboru
         popf

; ------ n†vrat registrñ

         mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

ReadTree ENDP

; -----------------------------------------------------------------------------
;        naáten° poloëky ze souboru stromu -> ES:SI, CY=nen° dal®° poloëka
; -----------------------------------------------------------------------------
; vstupn° promànnÇ: SS:[BP-2] (2) á°slo okna stromu
;                   SS:[BP-4] (2) adresa okna stromu
;                   SS:[BP-6] (2) ukazatel adresy poloëek - segment
;                   SS:[BP-8] (2) ukazatel adresy poloëek - offset
;                   SS:[BP-10] (2) á°taá zbylòch poloëek stromu
;
;                   SS:[BP-12] (2) á°slo segmentu bufferu (0=nen°)
;                   SS:[BP-14] (2) velikost bufferu (bajtñ; zarovn†no na FileTSum)
;                   SS:[BP-16] (2) poáet bajtñ naátenòch v bufferu
;                   SS:[BP-18] (2) adresa bufferu (segment)
;                   SS:[BP-20] (2) offset átec° adresy z bufferu
;                   SS:[BP-22] (2) offset zapisovac° adresy z bufferu
;
;                   SS:[BP-24] (2) identifik†tor vstupn°ho souboru (0=nen°)
;                   SS:[BP-26] (2) identifik†tor vòstupn°ho souboru (0=nen°)
;                              (FileMax) vòstupn° soubor
;                              (FileMax) vstupn° soubor
; -----------------------------------------------------------------------------

ReadTNxt PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      di

; ------ zvò®en° ukazatele átec° adresy (je zaji®tàno, ëe nebude p©eteáen° !)

         add       word ptr ss:[bp-20],FileTSum ; zvò®en° adresy v bufferu

; ------ test, zda je dal®° poloëka platn†

         mov       ax,ss:[bp-20]            ; adresa v bufferu
         add       ax,FileTSum              ; adresa konce poloëky
         jc        ReadTNx3                 ; p©eteáen°
         cmp       ax,ss:[bp-16]            ; je to platn† poloëka ?
         jbe       ReadTNx6                 ; je to platn† poloëka OK

; ------ naáten° dal®°ho bloku dat ze souboru

ReadTNx3:call      WritTNxt                 ; z†pis p©edchoz°ch poloëek
         mov       es,ss:[bp-18]            ; segment adresy bufferu
         xor       di,di                    ; offset ukl†dac° adresy
         mov       cx,ss:[bp-14]            ; velikost bufferu (bajtñ)
         mov       ax,ss:[bp-24]            ; identifik†tor vstupn°ho souboru
         call      far ptr ReadFile         ; naáten° bloku dat ze souboru
         mov       ss:[bp-16],cx            ; novò poáet bajtñ v bufferu
         mov       ss:[bp-20],di            ; nov† átec° adresa z bufferu
         mov       ss:[bp-22],di            ; nov† z†pisov† adresa z bufferu
         cmp       cx,FileTSum              ; je dost dat ?
         jae       ReadTNx6                 ; jsou dal®° data OK
         mov       word ptr ss:[bp-20],-FileTSum ; sn°ëen° adresy v bufferu
;         stc                                ; p©°znak konce souboru
         jmp       short ReadTNx7           ; nejsou dal®° data

; ------ je dal®° platn† poloëka

ReadTNx6:les       si,ss:[bp-20]            ; adresa v bufferu
         clc                                ; p©°znak operace OK

; ------ n†vrat registrñ

ReadTNx7:pop       di
         pop       cx
         pop       ax
         ret

ReadTNxt ENDP

; -----------------------------------------------------------------------------
;        z†pis p©edchoz°ch poloëek do souboru stromu -> ES:SI, CY=chyba
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) á°slo okna stromu
;                   SS:[BP-4] (2) adresa okna stromu
;                   SS:[BP-6] (2) ukazatel adresy poloëek - segment
;                   SS:[BP-8] (2) ukazatel adresy poloëek - offset
;                   SS:[BP-10] (2) á°taá zbylòch poloëek stromu
;
;                   SS:[BP-12] (2) á°slo segmentu bufferu (0=nen°)
;                   SS:[BP-14] (2) velikost bufferu (bajtñ; zarovn†no na FileTSum)
;                   SS:[BP-16] (2) poáet bajtñ naátenòch v bufferu
;                   SS:[BP-18] (2) adresa bufferu (segment)
;                   SS:[BP-20] (2) offset átec° adresy z bufferu
;                   SS:[BP-22] (2) offset zapisovac° adresy z bufferu
;
;                   SS:[BP-24] (2) identifik†tor vstupn°ho souboru (0=nen°)
;                   SS:[BP-26] (2) identifik†tor vòstupn°ho souboru (0=nen°)
;                              (FileMax) vòstupn° soubor
;                              (FileMax) vstupn° soubor
; -----------------------------------------------------------------------------

WritTNxt PROC      NEAR

         push      ax
         push      cx
         push      si
         push      es

         mov       ax,ss:[bp-26]            ; identifik†tor vòstupn°ho souboru
         or        ax,ax                    ; je soubor otev©en ?
         jz        WritTNx9                 ; soubor nen° otev©en
         mov       es,ss:[bp-18]            ; adresa bufferu
         mov       si,ss:[bp-22]            ; offset zapisovac° adresy
         mov       cx,ss:[bp-20]            ; offset átec° adresy
         cmp       cx,-FileTSum             ; je platn† átec° adresa ?
         jae       WritTNx9                 ; nen° platn† átec° adresa
         mov       ss:[bp-22],cx            ; nov† zapisovac° adresa
         sub       cx,si                    ; poáet bajtñ k z†pisu
         je        WritTNx9                 ; nejsou ë†dn† data k z†pisu
         call      far ptr WritFile         ; z†pis dat do souboru

WritTNx9:pop       es
         pop       si
         pop       cx
         pop       ax
         ret

WritTNxt ENDP

; -----------------------------------------------------------------------------
;                               WritTree
;                        z†pis stromu na disk
; -----------------------------------------------------------------------------
; VSTUP: AX=á°slo okna stromu
;        DS=datovò segment
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) á°slo okna stromu
;                   SS:[BP-4] (2) adresa okna stromu
;                   SS:[BP-6] (2) ukazatel adresy poloëek - segment
;                   SS:[BP-8] (2) ukazatel adresy poloëek - offset
;                   SS:[BP-10] (2) á°taá zbylòch poloëek stromu k uloëen°
;
;                   SS:[BP-12] (2) á°slo segmentu bufferu (0=nen°)
;                   SS:[BP-14] (2) velikost bufferu (bajtñ; zarovn†no na FileTSum)
;                   SS:[BP-16] (2) poáet bajtñ naátenòch v bufferu
;                   SS:[BP-18] (2) adresa bufferu (segment)
;                   SS:[BP-20] (2) offset átec° adresy z bufferu
;                   SS:[BP-22] (2) offset zapisovac° adresy z bufferu
;
;                   SS:[BP-24] (2) identifik†tor vstupn°ho souboru (0=nen°)
;                   SS:[BP-26] (2) identifik†tor vòstupn°ho souboru (0=nen°)
;                              (FileMax) vòstupn° soubor
;                              (FileMax) vstupn° soubor
; -----------------------------------------------------------------------------
;˛
WritTree PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,sp
         sub       sp,26 + 2*FileMax

; ------ inicializace lok†ln°ch promànnòch

         xor       bx,bx
         mov       word ptr ss:[bp-12],bx   ; nen° datovò buffer
         mov       word ptr ss:[bp-16],bx   ; v bufferu nejsou data
         mov       word ptr ss:[bp-22],bx   ; ukazatel z†pisovÇ adresy z bufferu
         mov       word ptr ss:[bp-24],bx   ; nen° vstupn° soubor
         mov       word ptr ss:[bp-26],bx   ; nen° vòstupn° soubor
         mov       word ptr ss:[bp-20],-FileTSum ; offset átec° adresy z bufferu

; ------ adresa okna stromu

         mov       ss:[bp-2],ax             ; á°slo okna stromu
         call      far ptr GetDat           ; adresa okna stromu
         jnc       WritTre1
WritTre0:jmp       WritTre9

WritTre1:mov       ss:[bp-4],es             ; adresa okna stromu
         test      byte ptr es:[AWinPrm1],bit4 ; je to okno stromu ?
         jz        WritTre0                 ; nen° to okno stromu
WritTr11:and       byte ptr es:[AWinPrm1],not bit2 ; zru®en° poëadavku

; ------ vytvo©en° pracovn°ho bufferu

         mov       bx,1000                  ; asi tak velikost bufferu
         call      far ptr CreatDat         ; vytvo©en° bufferu
         jc        WritTre0                 ; chyba pamàti
         mov       ss:[bp-12],ax            ; á°slo bufferu
         call      far ptr GetDat           ; adresa bufferu
WritTr00:jc        WritTre0                 ; chyba (ale zde nenastane)
         mov       ss:[bp-18],es            ; adresa bufferu

         xchg      ax,bx                    ; AX <- velikost bufferu
         cmp       ax,-FileTSum-10          ; rezerva na konci bufferu
         jb        WritTr12
         mov       ax,-FileTSum-10          ; omezen° velikosti bufferu
WritTr12:xor       dx,dx

;         xor       dx,dx
         mov       cx,FileTSum              ; poáet bajtñ na poloëku
         div       cx                       ; vòpoáet poátu poloëek v bufferu
         mul       cx                       ; zarovnan† velikost bufferu
         mov       ss:[bp-14],ax            ; velikost bufferu (bajtñ)

; ------ oprava adresy okna stromu, p©°prava oznaáen° poloëky ROOT

         mov       ax,ss:[bp-2]             ; á°slo okna stromu
         call      far ptr GetDat           ; adresa okna stromu
         mov       ss:[bp-4],es             ; adresa okna stromu
         mov       dx,word ptr es:[AWinDir]          ; hledanò ROOT (disk:)

; ------ sestaven° jmÇna vstupn°ho souboru

         mov       si,offset FileNTre       ; jmÇno souboru "$DOSMAN$.TRE"
         mov       di,sp                    ; buffer v z†sobn°ku
         push      ss
         pop       es
         call      far ptr TempFile         ; sestaven° jmÇna souboru

; ------ otev©en° vstupn°ho souboru pro áten°

         test      byte ptr ds:[TempDirP],bit0 ; je z†kaz z†pisu ?
         stc                                ; p©°znak chyby
         jnz       WritTr00                 ; je z†kaz z†pisu
         mov       si,sp                    ; jmÇno vstupn°ho souboru
         call      far ptr OpenR            ; otev©en° souboru pro áten°
         jnc       WritTr14                 ; soubor otev©en OK
         call      far ptr CreatFil         ; asi neexistuje - vytvo©en° souboru
         jc        WritTr00                 ; chyba ?
WritTr14:mov       ss:[bp-24],ax            ; identifik†tor vstupn°ho souboru

; ------ vytvo©en° vòstupn°ho souboru

         mov       si,offset FileNTre       ; jmÇno souboru "$DOSMAN$.TRE"
         mov       di,sp                    ; buffer v z†sobn°ku
         add       di,FileMax               ; buffer jmÇna vòstupn°ho souboru
         push      di
         push      ss
         pop       es
         call      far ptr TempFile         ; sestaven° jmÇna souboru
         pop       si                       ; buffer jmÇna souboru
         call      far ptr CreatPF          ; vytvo©en° p©echodnÇho souboru
         jc        WritTr00                 ; chyba
         mov       ss:[bp-26],ax            ; identifik†tor vòstupn°ho souboru

; ------ nalezen° poëadovanÇ poloëky ROOT

WritTre2:call      ReadTNxt                 ; naáten° dal®° poloëky ze souboru
         jc        WritTre3                 ; nen° dal®° poloëka
         cmp       byte ptr es:[si+FileTLev],0 ; je to ROOT ?
         jne       WritTre2                 ; nen° to ROOT
         cmp       dx,word ptr es:[si+FileName]      ; je to hledan† poloëka ROOT ?
         jne       WritTre2                 ; nalezen° poëadovanÇ poloëky ROOT
WritTre3:call      WritTNxt                 ; uloëen° zbòvaj°c°ch poloëek
         jc        WritTr81                 ; chyba z†pisu

; ------ p©°prava átec° adresy z bufferu

         mov       word ptr ss:[bp-8],AWinSoub AND 0fh ; offset prvn° poloëky
         mov       ax,ss:[bp-4]             ; adresa okna stromu
         add       ax,AWinSoub/16           ; segment prvn° poloëky
         mov       ss:[bp-6],ax             ; segment adresy poloëek

; ------ p©°prava á°taáe poloëek

         mov       es,ss:[bp-4]             ; segment okna
         mov       ax,es:[AWinSouR]         ; poáet poloëek v oknà
         mov       ss:[bp-10],ax            ; á°taá zbylòch poloëek

; ------ poáet bajtñ k z†pisu

WritTre4:mov       ax,ss:[bp-10]            ; poáet zbylòch poloëek
         cmp       ax,0f000h/FileTSum       ; maxim†ln° poáet pro jednu operaci
         jb        WritTre5                 ; poáet poloëek je OK
         mov       ax,0f000h/FileTSum       ; omezen° poátu poloëek
WritTre5:sub       ss:[bp-10],ax            ; sn°ëen° á°taáe poloëek
         mov       dx,FileTSum              ; poáet bajtñ na poloëku
         mul       dx                       ; poáet bajtñ k z†pisu
         xchg      ax,cx                    ; CX <- poáet bajtñ k z†pisu
         jcxz      WritTre6                 ; nejsou dal®° data

; ------ z†pis jednoho bloku dat

         les       si,ss:[bp-8]             ; adresa poloëek
         mov       ax,ss:[bp-26]            ; identifik†tor souboru
         call      far ptr WritFile         ; z†pis do souboru
         jc        WritTr81                 ; chyba z†pisu

; ------ zvò®en° adresy poloëek

         add       ss:[bp-8],cx             ; zvò®en° ukazatele adresy
         mov       ax,ss:[bp-8]             ; offset adresy poloëek
         and       word ptr ss:[bp-8],0fh   ; normalizace offsetu adresy poloëek
         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; p©evod offsetu na segment
         add       ss:[bp-6],ax             ; normalizace segmentu adresy
         jmp       short WritTre4           ; dal®° blok dat

; ------ nalezen° stromu dal®°ho disku

WritTre6:mov       ax,ss:[bp-20]            ; átec° adresa z bufferu
         add       ax,FileTSum              ; p©°®t° átec° adresa
         mov       ss:[bp-22],ax            ; zru®en° dat k z†pisu
         call      ReadTNxt                 ; nalezen° dal®° poloëky
         cmc
         jnc       WritTr81                 ; nen° dal®° poloëka
         cmp       byte ptr es:[si+FileTLev],0 ; je to ROOT ?
         jne       WritTre6                 ; nalezen° dal®°ho ROOT

; ------ p©enesen° zbytku souboru

WritTre7:call      ReadTNxt                 ; dal®° poloëka souboru
         jnc       WritTre7
WritTre8:call      WritTNxt                 ; z†pis zbytku poloëek

; ------ uzav©en° souborñ

WritTr81:pushf
         mov       ax,ss:[bp-24]            ; vstupn° soubor
         call      far ptr ClosFile         ; uzav©en° vstupn°ho souboru
         mov       ss:[bp-24],ax            ; soubor uzav©en
         mov       ax,ss:[bp-26]            ; vòstupn° soubor
         call      far ptr ClosFile         ; uzav©en° vòstupn°ho souboru
         mov       ss:[bp-26],ax            ; soubor uzav©en
         popf

; ------ zru®en° vstupn°ho souboru

         push      ss
         pop       es
         mov       si,sp                    ; jmÇno vstupn°ho souboru
         jc        WritTr84                 ; byla chyba z†pisu
         call      far ptr DelFile          ; zru®en° vstupn°ho souboru
         jnc       WritTr82                 ; soubor zru®en OK

; ------ p©i chybà zru®en° vòstupn°ho souboru

WritTr84:add       si,FileMax               ; jmÇno vòstupn°ho souboru
         call      far ptr DelFile          ; zru®en° vòstupn°ho souboru
         jmp       short WritTr83

; ------ p©ejmenov†n° souborñ

WritTr82:mov       dx,ss
         mov       di,sp                    ; novÇ (vstupn°) jmÇno souboru
         add       si,FileMax               ; souáasnÇ (vòstupn°) jmÇno souboru
         call      far ptr RenFile          ; p©ejmenov†n° souborñ

; ------ aktualizace oken

; Nen° povoleno - cyklicky se st†le naá°t† !
;
;         mov       si,di                    ; jmÇno souboru
;         call      far ptr ModiWDir         ; aktualizace oken

         test      byte ptr ds:[WindPar2],bit6 ; velikost DIR ze stromu ?
         jz        WritTr83                 ; nen° velikost DIR ze stromu

         mov       ax,ss:[bp-2]             ; á°slo okna stromu
         call      far ptr GetDat           ; adresa okna stromu
         mov       al,es:[AWinDisk]         ; disk stromu
         mov       ah,bit3                  ; povoleno jen pro adres†©
         call      far ptr ModWDisk         ; modifikace oken pro strom AL

WritTr83:clc

; ------ zru®en° pracovn°ho bufferu

WritTre9:pushf
         mov       ax,ss:[bp-12]            ; segment bufferu
         call      far ptr DelSeg           ; zru®en° bufferu
         mov       ax,ss:[bp-24]            ; vstupn° soubor
         call      far ptr ClosFile         ; uzav©en° vstupn°ho souboru
         mov       ax,ss:[bp-26]            ; vòstupn° soubor
         call      far ptr ClosFile         ; uzav©en° vòstupn°ho souboru
         popf

; ------ n†vrat registrñ

         mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

WritTree ENDP

; *****************************************************************************
;                                 BackTWn
;                   obsluha okna stromu v pozad° (naá°t†n°)
; -----------------------------------------------------------------------------
; VSTUP: AX=á°slo segmentu
;        DS=datovò segment
; VùSTUP: CY=nen° obsluha (nen° strom, je jië naáten nebo je chyba)
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) á°slo segmentu okna
;                   SS:[BP-4] (2) adresa segmentu okna
;                   SS:[BP-6] (2) minim†ln° adresa poloëek (segment)
;                   SS:[BP-8] (2) maxim†ln° adresa poloëek (segment)
;                   SS:[BP-10] (2) adresa klesaj°c° poloëky - segment
;                   SS:[BP-12] (2) adresa klesaj°c° poloëky - offset
;                   SS:[BP-14] (2) adresa rostouc° poloëky - segment
;                   SS:[BP-16] (2) adresa rostouc° poloëky - offset
; *****************************************************************************

BackTWn  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,sp
         sub       sp,16

; ------ adresa okna

         mov       ss:[bp-2],ax             ; á°slo segmentu okna
         call      far ptr GetDat           ; adresa okna
         jnc       BackTWn2
BackTWn1:jmp       BackTWn7
BackTWn2:mov       ss:[bp-4],es             ; adresa okna

; ------ test, zda m† bòt obsluha

         test      byte ptr es:[AWinPrm1],bit4 ; je to strom ?
         jz        BackTWn1                 ; nen° to strom
         test      byte ptr es:[AWinPrm1],bit1 ; je strom jië naáten ?
         jz        BackTW22                 ; strom je®tà nen° naáten

; ------ uloëen° stromu

         test      byte ptr es:[AWinPrm1],bit2 ; m† bòt strom uloëen ?
         jz        BackTWn1                 ; strom nem† bòt uloëen
         mov       ax,ss:[bp-2]             ; á°slo segmentu okna
         push      cs
         call      near ptr AktPathT        ; aktualizace cesty
         call      WritTree                 ; z†pis stromu okna AX na disk
         jmp       BackTW82                 ; p©°znak obsluhy

; ------ minim†ln° adresa poloëek

BackTW22:mov       ax,es                    ; segment okna
         add       ax,AWinSoub/16           ; minim†ln° adresa poloëek
         mov       ss:[bp-6],ax             ; minim†ln° adresa poloëek

; ------ maxim†ln° adresa poloëek

         mov       ax,es                    ; segment okna
         add       ax,word ptr es:[AWinSouI+2]       ; maxim†ln° adresa poloëek
         mov       ss:[bp-8],ax             ; maxim†ln° adresa poloëek

; ------ ukazatele poloëek

         mov       bx,es:[AWinKurz]         ; á°slo kurzoru
         call      far ptr GetESPol         ; adresa poloëky ES:SI
         jc        BackTWn1                 ; chyba ?
         mov       ss:[bp-10],es            ; segment klesaj°c° poloëky
         mov       ss:[bp-12],si            ; offset klesaj°c° poloëky
         mov       ss:[bp-14],es            ; segment rostouc° poloëky
         mov       ss:[bp-16],si            ; offset rostouc° poloëky

; ------ test, zda je rostouc° poloëka platn†

BackTWn3:les       si,ss:[bp-16]            ; adresa rostouc° poloëky
         mov       ax,es                    ; segment rostouc° poloëky
         cmp       ax,ss:[bp-8]             ; kontrola maxim†ln° adresy
         jae       BackTWn5                 ; nen° to platn† poloëka

; ------ test, zda je rostouc° poloëka naátena

         test      byte ptr es:[si+FileTPar],bit0 ; je adres†© naáten ?
         jz        BackTWn8                 ; nalezen nenaátenò adres†©

; ------ zvò®en° adresy rostouc° poloëky

         add       si,FileTSum              ; zvò®en° offsetu adresy
         mov       ax,si                    ; offset adresy poloëky
         and       si,0fh                   ; normalizace offsetu adresy
         mov       ss:[bp-16],si            ; novò offset rostouc° poloëky
         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; p©evod offsetu na segment
         add       ss:[bp-14],ax            ; posun segmentu rostouc° poloëky

; ------ test, zda je klesaj°c° poloëka platn† (tj. zda mñëe bòt dal®° poloëka)

BackTWn5:mov       ax,ss:[bp-10]            ; segment klesaj°c° poloëky
         cmp       ax,ss:[bp-6]             ; kontrola minim†ln° adresy
         jbe       BackTWn6                 ; klesaj°c° poloëka nen° platn†

; ------ sn°ëen° adresy klesaj°c° poloëky

         add       word ptr ss:[bp-12],100h-FileTSum ; sn°ëen° offsetu adresy
         sub       word ptr ss:[bp-10],100h/16 ; posun segmentu adresy
         mov       ax,ss:[bp-12]            ; offset klesaj°c° poloëky
         and       word ptr ss:[bp-12],0fh  ; normalizace offsetu poloëky
         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; p©evod offsetu na segment
         add       ss:[bp-10],ax            ; normalizace segmentu adresy

; ------ test, zda je klesaj°c° poloëka naátena

         les       si,ss:[bp-12]            ; adresa klesaj°c° poloëky
         test      byte ptr es:[si+FileTPar],bit0 ; je adres†© naáten ?
         jz        BackTWn8                 ; nalezen nenaátenò adres†©
         jmp       short BackTWn3           ; dal®° hled†n°

; ------ klesaj°c° poloëka nen° platn† - test rostouc° poloëky

BackTWn6:mov       ax,ss:[bp-14]            ; segment rostouc° poloëky
         cmp       ax,ss:[bp-8]             ; kontrola maxim†ln° adresy
         jb        BackTWn3                 ; je to platn† poloëka

; ------ konec naá°t†n° - z†pis stromu na disk

         mov       es,ss:[bp-4]             ; adresa segmentu okna
         and       byte ptr es:[AWinPrm1],not bit7 ; zru®en° p©°znaku chyby
         or        byte ptr es:[AWinPrm1],bit1+bit2 ; p©°znak naáten° stromu
BackTWn7:stc                                ; p©°znak, ëe nen° obsluha
         jmp       short BackTWn9

; ------ naáten° nalezenÇ poloëky ES:SI

BackTWn8:mov       ax,ss:[bp-2]             ; á°slo segmentu okna
         push      cs
         call      near ptr ReadTWn         ; naáten° poloëky ES:SI
         call      far ptr AktPAthT         ; aktualizace stromu v oknà
         call      AktTSiz                  ; aktualizace velikost° adres†©ñ
BackTW82:clc                                ; obslouëeno

; ------ n†vrat registrñ

BackTWn9:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

BackTWn  ENDP

; *****************************************************************************
;                               AktTSiz
;                 aktualizace velikost° adres†©ñ stromu
; -----------------------------------------------------------------------------
; VSTUP: AX=okno
;        DS=datovò segment
; *****************************************************************************

AktTSiz  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         push      ds

; ------ adresa okna

         call      far ptr GetDat           ; adresa okna
         jc        AktTSiz9
         mov       bp,es                    ; BP <- adresa okna

; ------ p©°prava registrñ

         xor       bx,bx                    ; ukazatel poloëek
         mov       dx,word ptr es:[AWinSouI+2]       ; segment tabulky indexñ
         add       dx,bp                    ; adresa konce poloëek

; ------ adresa aktualizovanÇ poloëky BX

AktTSiz2:mov       es,bp                    ; adresa okna
         call      far ptr GetESPol         ; adresa poloëky
         jc        AktTSiz9                 ; nen° dal®° poloëka
         push      es
         pop       ds                       ; DS:SI=adresa aktualizovanÇ poloëky
         mov       di,si                    ; ES:DI=adresa poloëky

; ------ p©°prava aktu†ln° velikosti

         mov       ax,word ptr ds:[si+FileTSiz]      ; souáet velikost° souborñ
         mov       word ptr ds:[si+FileSize],ax      ; velikost adres†©e
         mov       ax,word ptr ds:[si+FileTSiz+2]
         mov       word ptr ds:[si+FileSize+2],ax

; ------ test, zda je poloëka rozvinuta

         test      byte ptr ds:[si+FileTPar],bit2 ; je poloëka rozvinuta ?
         jnz       AktTSiz8                 ; poloëka je rozvinuta
         test      byte ptr ds:[si+FileTPar],bit1 ; m† poloëka podadres†©e ?
         jz        AktTSiz8                 ; poloëka nem† podadres†©e
         mov       cl,ds:[si+FileTLev]      ; vòchoz° hladina poloëky

; ------ adresa dal®° poloëky

         push      bx
AktTSiz3:add       di,FileTSum              ; adresa dal®° poloëky
         mov       ax,di
         and       di,0fh                   ; normalizace offsetu
         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; p©evod offsetu na segment
         mov       bx,es                    ; segment adresy poloëky
         add       ax,bx                    ; normalizace segmentu
         mov       es,ax                    ; segment dal®° poloëky

; ------ test, zda je to platn† poloëka

         cmp       ax,dx                    ; je to platn† poloëka ?
         jae       AktTSiz7                 ; nen° to platn† poloëka
         cmp       cl,es:[di+FileTLev]      ; m† spr†vnou hladinu ?
         jae       AktTSiz7                 ; nen° to jië spr†vn† poloëka

; ------ p©id†n° velikosti poloëky

         mov       ax,word ptr es:[di+FileTSiz]      ; velikost poloëky
         add       word ptr ds:[si+FileSize],ax      ; p©id†n° k vòchoz° poloëce
         mov       ax,word ptr es:[di+FileTSiz+2]
         adc       word ptr ds:[si+FileSize+2],ax
         jmp       short AktTSiz3           ; dal®° poloëka

AktTSiz7:pop       bx

; ------ p©°prava pro dal®° poloëku

AktTSiz8:inc       bx                       ; zvò®en° ukazatele poloëek
         jmp       short AktTSiz2           ; dal®° poloëka

; ------ n†vrat registrñ

AktTSiz9:pop       ds
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         call      far ptr AktSelct         ; inicializace oznaáen° poloëek
         ret

AktTSiz  ENDP

; *****************************************************************************
;                               AktPthAT
;          aktualizace cesty v aktivn°m oknà stromu (po zmànà kurzoru)
;         testuje, zda to je okno stromu a uchov†v† registr p©°znakñ !
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

AktPthAT PROC      FAR

         push      ax
         mov       ax,ds:[SegmAkt]          ; aktivn° okno
         push      cs
         call      near ptr AktPathT        ; aktualizace cesty
         pop       ax
         ret

AktPthAT ENDP

; *****************************************************************************
;                                AktPathT
;            aktualizace cesty v oknà stromu (po zmànà kurzoru)
;       testuje, zda to je okno stromu a uchov†v† registr p©°znakñ !
; -----------------------------------------------------------------------------
; VSTUP: AX=segment okna
;        DS=datovò segment
; *****************************************************************************

AktPathT PROC      FAR

; ------ £schova registrñ 1

         pushf
         push      es

; ------ adresa okna

         call      far ptr GetDat           ; adresa okna -> ES
         jc        AktPthT0                 ; neplatnÇ okno

; ------ test, zda to je okno stromu

         test      byte ptr es:[AWinPrm1],bit4 ; je to okno stromu ?
         jnz       AktPthT1                 ; je to okno stromu OK
AktPthT0:jmp       AktPthT9                 ; nen° to okno stromu

; ------ £schova registrñ 2

AktPthT1:push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      ds

; ------ adresa kurzoru

         push      es
         mov       bx,es:[AWinKurz]         ; kurzor
         call      far ptr GetESPol         ; adresa kurzoru -> ES:SI
         push      es
         pop       ds                       ; DS <- segment poloëky kurzoru
         pop       es
         jnc       AktPthT2                 ; je platn† poloëka OK
         jmp       AktPthT8                 ; neplatn† poloëka

; ------ sestaven° cesty k poloëce kurzoru

AktPthT2:mov       di,AWinDir               ; buffer adres†©e okna
         push      cs
         call      near ptr GetPthTW        ; sestaven° cesty ke kurzoru
         sub       di,AWinDir               ; dÇlka textu cesty
         mov       es:[AWinDNum],di         ; dÇlka textu cesty

; ------ aktualizace aktivn°ho adres†©e

         pop       ds                       ; datovò segment
         push      ds
         cmp       ax,ds:[SegmAkt]          ; je to aktivn° okno ?
         jne       AktPthT3                 ; nen° to aktivn° okno
         call      far ptr AktADir          ; aktualizace aktivn°ho adres†©e
         call      far ptr DispLCom         ; zobrazen° p©°kazovÇho ©†dku

; ------ p©°prava k spoáten° souborñ ve vàtvi

AktPthT3:call      far ptr GetDat           ; adresa okna
         mov       dx,es                    ; segment okna
         add       dx,word ptr es:[AWinSouI+2]       ; segment tabulky indexñ
         mov       bx,es:[AWinKurz]         ; kurzor
         push      es
         call      far ptr GetESPol         ; adresa poloëky -> ES:SI
         pop       ds                       ; DS <- adresa okna

; ------ inicializace souborñ pro aktivn° poloëku

         mov       cx,word ptr es:[si+FileTFil]      ; poáet souborñ v adres†©i
         mov       word ptr ds:[AWinDFil],cx         ; poáet souborñ v adres†©i
         mov       cx,word ptr es:[si+FileTKap]      ; zabran† kapacita souborñ
         mov       word ptr ds:[AWinDSum],cx         ; zabran† kapacita souborñ
         mov       cx,word ptr es:[si+FileTKap+2]
         mov       word ptr ds:[AWinDSum+2],cx

; ------ test, zda je poloëka rozvinut†

         test      byte ptr es:[si+FileTPar],bit2 ; je poloëka rozvinuta ?
         jnz       AktPthT8                 ; poloëka je rozvinuta
         mov       bl,es:[si+FileTLev]      ; vòchoz° hladina poloëky

; ------ adresa dal®° poloëky -> ES:SI

AktPthT4:add       si,FileTSum              ; adresa dal®° poloëky
         mov       di,si                    ; offset poloëky
         and       si,0fh                   ; normalizace offsetu
         shr       di,1
         shr       di,1
         shr       di,1
         shr       di,1                     ; p©evod offsetu na segment
         mov       cx,es                    ; segment poloëky
         add       di,cx                    ; normalizace segmentu
         mov       es,di                    ; segment dal®° poloëky

; ------ test, zda je platnò podadres†©

         cmp       di,dx                    ; je to platn† poloëka ?
         jae       AktPthT8                 ; nen° dal®° platn† poloëka
         cmp       bl,es:[si+FileTLev]      ; je to podadres†© ?
         jae       AktPthT8                 ; nen° to podadres†© - konec vàtve

; ------ p©id†n° parametrñ poloëky

         mov       cx,word ptr es:[si+FileTFil]      ; poáet souborñ v adres†©i
         add       word ptr ds:[AWinDFil],cx         ; poáet souborñ v adres†©i
         mov       cx,word ptr es:[si+FileTKap]      ; zabran† kapacita souborñ
         add       word ptr ds:[AWinDSum],cx         ; zabran† kapacita souborñ
         mov       cx,word ptr es:[si+FileTKap+2]
         adc       word ptr ds:[AWinDSum+2],cx
         jmp       short AktPthT4           ; dal®° poloëka

; ------ n†vrat registrñ

AktPthT8:pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
AktPthT9:pop       es
         popf
         ret

AktPathT ENDP

; *****************************************************************************
;                                GetPthTW
;                  sestaven° cesty k poloëce v oknà stromu
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa koncovÇ poloëky v oknà
;        ES:DI=buffer k dek¢dov†n° cesty k poloëce
; VùSTUP: ES:DI=adresa konce textu (koncov† 0)
;         SI=adresa konce textu p©ed posledn° poloëkou
;         CY=p©eteáen° dÇlky cesty
; *****************************************************************************

GetPthTW PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      bp

; ------ p©°prava registrñ

         mov       bp,di                    ; BP <- buffer k dek¢dov†n° cesty
         mov       bx,di                    ; BX <- p©ednastaven° adresy konce textu
         mov       dx,ds                    ; DX <- segment adresy poloëky
         xor       cx,cx                    ; CX <- 0 á°taá nalezenòch poloëek
         mov       al,ds:[si+FileTLev]      ; souáasn† £rove§

; ------ uloëen° adresy poloëky

GetPthT1:push      ds                       ; £schova segmentu adresy poloëky
         push      si                       ; £schova offsetu adresy poloëky
         inc       cx                       ; á°taá nalezenòch poloëek

; ------ sn°ëen° ukazatele £rovnà poloëek

         dec       al                       ; sn°ëen° ukazatele £rovnà
         js        GetPthT5                 ; byla jië nejnië®° £rove§ (ROOT)

; ------ adresa p©edchoz° poloëky

GetPthT2:sub       si,FileTSum              ; sn°ëen° ukazatele poloëek
         jns       GetPthT3                 ; nen° podteáen°
         add       si,8000h                 ; korekce offsetu adresy
         sub       dx,8000h/16              ; korekce segmentu adresy
         mov       ds,dx                    ; novò segment adresy poloëky

; ------ test, zda to je hledan† p©edchoz° poloëka

GetPthT3:cmp       al,ds:[si+FileTLev]      ; je to hledan† poloëka ?
         jne       GetPthT2                 ; nen° to hledan† poloëka - dal®°
         jmp       short GetPthT1           ; nalezena p©ede®l† poloëka

; ------ zaji®tàn° oddàlovac°ho znaku "\"

GetPthT4:cld
         mov       bx,di                    ; p©ednastaven° adresy konce textu
         dec       di                       ; n†vrat na posledn° znak "\"
         mov       al,"\"
         scasb                              ; je cesta ukonáena znakem "\" ?
         je        GetPthT5                 ; je jië koncovò znak "\"
         stosb                              ; uloëen° koncovÇho znaku "\"

; ------ adresa poloëky k dek¢dov†n°

GetPthT5:pop       si                       ; offset adresy poloëky k dek¢dov†n°
         pop       ds                       ; segment adresy poloëky k dek¢dov†n°
         inc       si                       ; zaá†tek jmÇna poloëky

; ------ test, zda je jië maxim†ln° dÇlka cesty

         mov       ax,di                    ; ukl†dac° adresa poloëky
         sub       ax,bp                    ; dÇlka cesty
         cmp       ax,64+3-2                ; je jië buffer plnò ?
         jbe       GetPthT8                 ; buffer je®tà nen° plnò

; ------ oznaáen° konce bufferu p©i p©eteáen°

         dec       di                       ; n†vrat na posledn° znak "\"
         mov       byte ptr es:[di],0       ; oznaáen° konce cesty
         jmp       short GetPthT7           ; vypu®tàn° zbòvaj°c°ch poloëek

; ------ p©i chybà vypu®tàn° zbòvaj°c°ch poloëek

GetPthT6:pop       si                       ; zru®en° adresy poloëky
         pop       ds
GetPthT7:loop      GetPthT6                 ; dal®° poloëka
         stc                                ; p©°znak p©eteáen° dÇlky
         jmp       short GetPthT9

; ------ dek¢dov†n° jmÇna poloëky do bufferu

GetPthT8:call      far ptr FileAsc          ; dek¢dov†n° poloëky
         loop      GetPthT4                 ; dal®° poloëka

; ------ kontrola dÇlky cesty

         mov       ax,di                    ; ukl†dac° adresa
         sub       ax,bp                    ; dÇlka cesty
         cmp       ax,64+3+1                ; p©ekroáena dÇlka cesty ?
         cmc

; ------ n†vrat registrñ

GetPthT9:mov       si,bx                    ; konec textu p©ed posledn° poloëkou
         pop       bp
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

GetPthTW ENDP

; *****************************************************************************
;                                ReadTWn
;                   naáten° jednoho adres†©e stromu
; -----------------------------------------------------------------------------
; VSTUP: AX=á°slo segmentu okna
;        ES:SI=adresa poloëky v seznamu k naáten°/ovà©en°
;        DS=datovò segment
; VùSTUP: CY=nedostatek pamàti
; -----------------------------------------------------------------------------
; Lok†ln° promànnÇ: [BP- 1] (1)  £rove§ naá°tanòch podadres†©ñ
;                   [BP- 2] (1)
;                   [BP- 4] (2) pracovn° identifik†tor DTA
;                   [BP- 5] (1)
;                   [BP-18] (13) jmÇno souboru s p©°ponou ASCIIZ
;                   [BP-22] (4)  velikost souboru
;                   [BP-24] (2)  datum souboru
;                   [BP-26] (2)  áas souboru
;                   [BP-27] (1)  atributy souboru
;                   [BP-48] (21) pracovn° adresa DTA - zaá†tek
;
;                   [BP-50] (2)  segment okna (adresa)
;                   [BP-52] (2)  á°slo okna
;                   [BP-54] (2)  segment adresy vòchoz° poloëky v seznamu
;                   [BP-56] (2)  offset adresy vòchoz° poloëky v seznamu
;                   [BP-58] (2)  segment adresy indexovÇ tabulky (=konec poloëek)
; *****************************************************************************
;˛
ReadTWn  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,sp
         sub       sp,58+FileMax+14          ; buffer pro lok†ln° promànnÇ

; ------ p©°prava lok†ln°ch promànnòch

         mov       ss:[bp-54],es            ; segment adresy vòchoz° poloëky
         mov       ss:[bp-56],si            ; offset adresy vòchoz° poloëky
         or        byte ptr es:[si+FileTPar],bit0 ; p©°znak ovà©en° adres†©e
         call      far ptr TestBreak        ; je p©eru®en° operace ?
         jc        ReadTWn0                 ; p©eru®en° operace

         mov       ss:[bp-52],ax            ; á°slo okna
         call      far ptr GetSgAdr         ; adresa okna
         jnc       ReadTWn1
ReadTWn0:jmp       ReadTWn9                 ; chyba operace
ReadTWn1:mov       ss:[bp-50],dx            ; adresa okna
         mov       al,es:[si+FileTLev]      ; £rove§ adres†©e
         inc       ax                       ; zvò®en° ukazatele £rovnà
         mov       ss:[bp-1],al             ; £rove§ podadres†©ñ

; ------ nulov†n° parametrñ naá°tanÇ poloëky

         xor       ax,ax
         mov       word ptr es:[si+FileTFil],ax      ; poáet souborñ v adres†©i
         mov       word ptr es:[si+FileTKap],ax      ; zabran† kapacita LOW
         mov       word ptr es:[si+FileTKap+2],ax    ; zabran† kapacita HIGH
         mov       word ptr es:[si+FileTSiz],ax      ; souáet velikost° LOW
         mov       word ptr es:[si+FileTSiz+2],ax    ; souáet velikost° HIGH
         test      byte ptr es:[si+FileTPar],bit1   ; byly podadres†©e ?
         jnz       ReadTW12                 ; byly podadres†©e
         or        byte ptr es:[si+FileTPar],bit2  ; nebyly - tak budou rozvinuty
ReadTW12:and       byte ptr es:[si+FileTPar],not bit1 ; nejsou podadres†©e

; ------ adresa konce poloëek

         mov       es,dx                    ; adresa okna
         mov       ax,word ptr es:[AWinSouI+2]       ; adresa indexovÇ tabulky (segment)
         add       ax,dx                    ; segment indexovÇ tabulky
         mov       ss:[bp-58],ax            ; segment indexovÇ tabulky

; ------ nulov†n° p©°znakñ nalezen° poloëek podadres†©ñ

         call      NulFTree                 ; nulov†n° podadres†©ñ

; ------ definice bufferu DTA

         push      ss
         pop       es                       ; ES <- segment bufferu v z†sobn°ku
         lea       si,[bp-48]               ; adresa bufferu DTA
         call      far ptr SetDTA           ; nastaven° adresy DTA

; ------ p©°prava vòchoz° cesty k poloëce (ES=SS)

         mov       di,sp                    ; adresa bufferu
         push      ds
         lds       si,ss:[bp-56]            ; adresa vòchoz° poloëky
         push      cs
         call      near ptr GetPthTW        ; sestaven° cesty k poloëce
         pop       ds
         jc        ReadTW34                 ; p©eteáen° dÇlky cesty

; ------ p©id†n° specifikace "*.*"

         cld
         mov       al,"\"                   ; znak oddàlovaáe "\"
         dec       di                       ; posledn° znak cesty
         scasb                              ; je jië oddàlovaá ?
         je        ReadTWn2                 ; je jië oddàlovaá
         stosb                              ; uloëen° oddàlovaáe
ReadTWn2:mov       ax,".*"                  ; text "*.*"
         stosw                              ; uloëen° textu "*.*"
         mov       ah,0                     ; koncov† 0
         stosw

; ------ nalezen° prvn°ho souboru

         mov       cx,SYS+HID+RO+DIR+ARC    ; specifikace - v®echny soubory
         mov       si,sp                    ; specifikace souboru
         call      far ptr SrcFirst         ; nalezen° prvn°ho souboru

; ------ rozli®en°, zda byl nalezen platnò soubor

ReadTWn3:jc        ReadTW34                 ; chyba operace
         jnz       ReadTW34                 ; dal®° soubor nenalezen
         cmp       byte ptr ss:[bp-18],"."  ; je adres†© "." nebo ".." ?
         je        ReadTWn5                 ; adres†© se p©eskoá°

; ------ uloëen° parametrñ platnÇho souboru

         test      byte ptr ss:[bp-27],DIR  ; je to adres†© ?
         jnz       ReadTWn4                 ; je to adres†©
         mov       es,ss:[bp-50]            ; adresa okna
         mov       cx,es:[AWinAlok]         ; velikost alokaán°ho bloku
         test      byte ptr es:[AWinPrm0],bit6 ; je to CD-ROM ?
         jz        ReadTW32                 ; nen° to CD-ROM
         mov       cx,2048                  ; n†hradn° velikost bloku

ReadTW32:les       si,ss:[bp-56]            ; adresa vòchoz° poloëky
         inc       word ptr es:[si+FileTFil] ; zvò®en° á°taáe souborñ
         mov       ax,ss:[bp-22]            ; velikost souboru LOW
         mov       dx,ss:[bp-22+2]          ; velikost souboru HIGH
         add       word ptr es:[si+FileTSiz],ax      ; souáet velikost° LOW
         adc       word ptr es:[si+FileTSiz+2],dx    ; souáet velikost° HIGH
         dec       cx                       ; velikost bloku - 1
         add       ax,cx                    ; zaokrouhlen° na blok
         adc       dx,0                     ; p©enos HIGH
         jc        ReadTW33                 ; p©eteáen° - dal®° soubor
         inc       cx                       ; n†vrat velikosti bloku
         cmp       dx,cx                    ; je p©eteáen° velikosti ?
         jae       ReadTW33                 ; p©eteáen° - dal®° soubor
         div       cx                       ; vòpoáet celòch blokñ
         mul       cx                       ; vòpoáet zaokrouhlenÇ velikosti
ReadTW33:add       word ptr es:[si+FileTKap],ax      ; souáet kapacit LOW
         adc       word ptr es:[si+FileTKap+2],dx    ; souáet kapacit HIGH
         jmp       short ReadTWn5           ; dal®° soubor

ReadTW34:call      far ptr SrcClose         ; uzav©en° starÇho hled†n°
         jmp       short ReadTWn7           ; konec hled†n°

; ------ uloëen° nalezenÇho adres†©e do seznamu

ReadTWn4:cmp       byte ptr ss:[bp-1],32    ; je jië maxim†ln° hladina ?
         ja        ReadTWn5                 ; p©ekroáena maxim†ln° hladina
         call      StorTree                 ; uloëen° adres†©e do seznamu
         jc        ReadTWn6                 ; chyba - p©eteáen° pamàti

; ------ pokus o nalezen° dal®°ho souboru

ReadTWn5:call      far ptr SrcNext          ; nalezen° dal®°ho souboru
         jmp       short ReadTWn3           ; uloëen° poloëky

; ------ hl†®en° - chyba pamàti

ReadTWn6:mov       es,ss:[bp-50]            ; adresa okna
         test      byte ptr es:[AWinPrm1],bit7 ; byla chyba pamàti ?
         jnz       ReadTW62                 ; byla jië chyba pamàti
         or        byte ptr es:[AWinPrm1],bit7 ; p©°znak chyby pamàti
         mov       ax,ss:[bp-52]            ; á°slo okna
         call      far ptr DispAWin         ; zobrazen° okna
         mov       si,offset ChbTrMem
         call      far ptr Lin0MenF
ReadTW62:stc
         jmp       short ReadTWn9

; ------ velikost poloëky

ReadTWn7:
;         les       di,ss:[bp-56]            ; adresa vòchoz° poloëky
;
;         mov       ax,es:[di+FileTSiz]      ; souáet velikost° poloëek
;         mov       es:[di+FileSize],ax      ; je to velikost poloëky adres†©e
;         mov       ax,es:[di+FileTSiz+2]
;         mov       es:[di+FileSize+2],ax

; ------ vypu®tàn° nenaátenòch adres†©ñ

         call      ReadTWV                  ; vypu®tàn° nenaátenòch adres†©ñ

; ------ p©°prava ke korekci p©°znakñ dal®°ch podadres†©ñ

         push      ds

         les       di,ss:[bp-56]            ; adresa vòchoz° poloëky
         mov       dl,ss:[bp-1]             ; £rove§ podadres†©ñ
         mov       dh,0                     ; p©°znak, ëe nen° p©ede®l† poloëka

; ------ adresa dal®° poloëky

ReadTW72:add       di,FileTSum              ; adresa dal®° poloëky
         mov       ax,di                    ; offset adresy poloëky
         and       di,0fh                   ; normalizace offsetu poloëky
         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; p©evod offsetu na segment
         mov       bx,es                    ; segment poloëky
         add       ax,bx                    ; normalizace segmentu poloëky
         mov       es,ax                    ; novò segment poloëky

; ------ oznaáen° p©ede®lÇ poloëky, ëe je podadres†© stejnÇ £rovnà

         cmp       ax,ss:[bp-58]            ; konec seznamu ?
         jae       ReadTW76                 ; konec seznamu
         cmp       dl,es:[di+FileTLev]      ; konec adres†©e ?
         ja        ReadTW76                 ; konec adres†©e
         jb        ReadTW72                 ; nen° stejn† hladina
         and       byte ptr es:[di+FileTPar],not bit3 ; nejsou dal®° adres†©e
         or        dh,dh                    ; je p©ede®l† poloëka ?
         jz        ReadTW74                 ; nen° p©ede®l† poloëka
         or        byte ptr ds:[si+FileTPar],bit3 ; oznaáen° p©ede®lÇ poloëky
ReadTW74:mov       si,di                    ; SI <- £schova offsetu poloëky
         push      es
         pop       ds                       ; DS <- £schova segmentu poloëky
         mov       dh,1                     ; p©°znak, ëe je p©ede®l† poloëka
         jmp       short ReadTW72           ; dal®° poloëka

ReadTW76:pop       ds

; ------ otev©en° vàtve naátenòch adres†©ñ

         les       si,ss:[bp-56]            ; adresa poloëky
         test      byte ptr es:[si+FileTPar],bit1 ; jsou podadres†©e ?
         jnz       ReadTW82                 ; jsou podadres†©e
         and       byte ptr es:[si+FileTPar],not bit2 ; nejsou rozvinuty
ReadTW82:test      byte ptr es:[si+FileTPar],bit2 ; podadres†©e rozvinuty ?
         jz        ReadTWn9                 ; nejsou rozvinuty
         test      byte ptr es:[si+FileTPar],bit7 ; je poloëka zobrazena ?
         jz        ReadTWn9                 ; poloëka nezobrazena
         mov       ax,ss:[bp-52]            ; á°slo okna
         mov       bl,0                     ; jen jedna £rove§
         call      OpenDTWn                 ; otev©en° vàtve adres†©e
         clc

; ------ n†vrat registrñ

ReadTWn9:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

ReadTWn  ENDP

; -----------------------------------------------------------------------------
;        vypustàn° nenaátenòch adres†©ñ
; -----------------------------------------------------------------------------
; Lok†ln° promànnÇ: [BP- 1] (1)  £rove§ naá°tanòch podadres†©ñ
;                   [BP- 2] (1)
;                   [BP- 4] (2) pracovn° identifik†tor DTA
;                   [BP- 5] (1)
;                   [BP-18] (13) jmÇno souboru s p©°ponou ASCIIZ
;                   [BP-22] (4)  velikost souboru
;                   [BP-24] (2)  datum souboru
;                   [BP-26] (2)  áas souboru
;                   [BP-27] (1)  atributy souboru
;                   [BP-48] (21) pracovn° adresa DTA - zaá†tek
;
;                   [BP-50] (2)  segment okna (adresa)
;                   [BP-52] (2)  á°slo okna
;                   [BP-54] (2)  segment adresy vòchoz° poloëky v seznamu
;                   [BP-56] (2)  offset adresy vòchoz° poloëky v seznamu
;                   [BP-58] (2)  segment adresy indexovÇ tabulky (=konec poloëek)
; niá° registry AX, BX, CX, DX, SI, DI a ES
; -----------------------------------------------------------------------------

ReadTWV  PROC      NEAR

         call      far ptr TestBreak        ; je p©eru®en° operace ?
         jc        ReaTWV12                 ; p©eru®en° operace

; ------ nalezen° nenalezenÇho adres†©e

         les       di,ss:[bp-56]            ; adresa vòchoz° poloëky
         mov       bh,ss:[bp-1]             ; £rove§ podadres†©ñ
ReadTWV1:add       di,FileTSum              ; adresa dal®° poloëky
         mov       ax,di                    ; offset adresy poloëky
         and       di,0fh                   ; normalizace offsetu adresy poloëky
         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; p©evod offsetu na segment
         mov       dx,es                    ; segment poloëky
         add       ax,dx                    ; normalizace segmentu poloëky
         mov       es,ax                    ; novò segment poloëky
         cmp       ax,ss:[bp-58]            ; konec seznamu ?
         jae       ReaTWV12                 ; konec seznamu
         cmp       bh,es:[di+FileTLev]      ; konec adres†©e ?
         jb        ReadTWV1                 ; nen° poëadovan† hladina
         je        ReaTWV14                 ; hladina nalezena OK
ReaTWV12:jmp       ReadTWV9                 ; konec adres†©e

ReaTWV14:test      byte ptr es:[di+FileTPar],bit4 ; poloëka naátena ?
         jnz       ReadTWV1                 ; poloëka nalezena OK

; ------ vypustàn° poloëky ES:DI

ReadTWV2:mov       ax,ss:[bp-52]            ; á°slo okna
         mov       cx,FileTSum              ; poáet vypou®tànòch bajtñ LOW
         mov       bl,0                     ; poáet bajtñ HIGH
         mov       dx,es                    ; DX <- adresa poloëky
         sub       dx,ss:[bp-50]            ; segment adresy poloëky relativnà
         call      far ptr DelSDat          ; zru®en° poloëky
         jc        ReaTWV12                 ; nàjak† chyba ?

; ------ korekce ukazatelñ

         push      di
         push      es

         mov       es,ss:[bp-50]            ; adresa okna
         dec       word ptr es:[AWinSouR]   ; sn°ëen° poátu naátenòch poloëek
         add       word ptr es:[AWinSouI],100h-FileTSum ; posun tabulky indexñ
         sub       word ptr es:[AWinSouI+2],100h/16 ; korekce segmentu adresy
         add       word ptr es:[AWinKomI],100h-FileTSum ; posun tabulky indexñ
         sub       word ptr es:[AWinKomI+2],100h/16 ; korekce segmentu adresy
         call      far ptr NormIAWn         ; normalizace adres tabulek
         mov       ax,word ptr es:[AWinSouI+2]       ; segment tabulky indexñ
         add       ax,ss:[bp-50]            ; adresa tabulky indexñ
         mov       ss:[bp-58],ax            ; nov† adresa indexovÇ tabulky

; ------ p©°prava k redukci indexovÇ tabulky

         mov       si,es:[AWinSouN]         ; poáet zobrazenòch poloëek
         mov       di,word ptr es:[AWinSouI]         ; offset adresy indexovÇ tabulky
         mov       es,ax                    ; segment indexovÇ tabulky
         xor       bx,bx                    ; BX <- 0 ukazatel á°sla poloëky
ReaTWV24:or        si,si                    ; je nàjak† poloëka ?
         jnz       ReadTWV3                 ; je nàjak† poloëka
         jmp       ReadTWV8                 ; nen° ë†dn† poloëka

; ------ nalezen° indexovÇ poloëky k redukci

ReadTWV3:cmp       dx,es:[di+1]             ; porovn†n° segmentu poloëky
         ja        ReadTWV6                 ; je za poloëkou - neposouv† se
         jb        ReadTWV5                 ; je p©ed poloëkou - korekce adresy

; ------ vypustàn° poloëky z tabulky

         push      bx
         push      dx

         mov       cx,3                     ; dÇlka indexovÇ poloëky
         xor       bx,bx                    ; BX <- 0 poáet bajtñ HIGH
         mov       ax,ss:[bp-52]            ; á°slo okna
         mov       dx,es                    ; DX <- segment tabulky
         sub       dx,ss:[bp-50]            ; offset segmentu indexovÇ tabulky
         call      far ptr DelSDat          ; zru®en° poloëky indexu

         pop       dx
         pop       bx
         jc        ReadTWV8                 ; nàjak† chyba ?

; ------ korekce ukazatelñ

         push      es
         mov       es,ss:[bp-50]            ; adresa okna
         dec       word ptr es:[AWinSouN]   ; sn°ëen° poátu zobrazenòch poloëek
         add       word ptr es:[AWinKomI],100h-3 ; posun tabulky koment†©ñ
         sub       word ptr es:[AWinKomI+2],100h/16
         call      far ptr NormIAWn         ; normalizace adres tabulek

; ------ korekce kurzoru

         cmp       bx,es:[AWinKurz]         ; je poloëka p©ed kurzorem ?
         jae       ReaTWV42                 ; nen° p©ed kurzorem
         dec       word ptr es:[AWinKurz]   ; posun kurzoru
         cmp       word ptr es:[AWinFrst],0 ; je zobrazen poá†tek okna ?
         je        ReaTWV42                 ; je zobrazen poá†tek okna
         dec       word ptr es:[AWinFrst]   ; posun poá†tku okna
ReaTWV42:pop       es
         jmp       short ReadTWV7

; ------ oprava adresy poloëky (poloëka je za vypou®tànou poloëkou)

ReadTWV5:add       byte ptr es:[di],80h-FileTSum ; posun adresy (offset)
         sub       word ptr es:[di+1],80h/16 ; korekce adresy (segment)
         mov       al,es:[di]               ; offset adresy poloëky
         mov       ah,0                     ; AH <- 0
         and       byte ptr es:[di],0fh     ; normalizace offsetu adresy
         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; p©evod offsetu na segment
         add       word ptr es:[di+1],ax    ; normalizace segmentu adresy

; ------ adresa dal®° poloëky

ReadTWV6:add       di,3                     ; zvò®en° adresy v tabulce indexñ
         inc       bx                       ; zvò®en° ukazatele á°sla poloëky
ReadTWV7:dec       si                       ; á°taá poloëek indexñ
         jmp       ReaTWV24                 ; dal®° poloëka

ReadTWV8:pop       es
         pop       di

; ------ test, zda je dal®° poloëka k vypou®tàn°

         mov       bh,ss:[bp-1]             ; £rove§ podadres†©ñ
         mov       ax,es                    ; segment poloëky
         cmp       ax,ss:[bp-58]            ; konec seznamu ?
         jae       ReadTWV9                 ; konec seznamu
         cmp       bh,es:[di+FileTLev]      ; konec adres†©e ?
         jb        ReaTWV81                 ; je to podadres†© - vypou®t° se
         ja        ReadTWV9                 ; konec adres†©e
         test      byte ptr es:[di+FileTPar],bit4 ; poloëka naátena ?
         jnz       ReaTWV82                 ; poloëka naátena OK
ReaTWV81:jmp       ReadTWV2                 ; poloëka se vypou®t°

ReaTWV82:jmp       ReadTWV1                 ; hled†n° dal®° poloëky

ReadTWV9:ret

ReadTWV  ENDP

; -----------------------------------------------------------------------------
;                                NulFTree
;           nulov†n° p©°znaku nalezen° v jednÇ vàtvi adres†©e
; -----------------------------------------------------------------------------
; VSTUP: SS:BP=ukazatel lok†ln°ch promànnòch
;        DS=datovò segment
; VùSTUP:CY=nedostatek pamàti
; -----------------------------------------------------------------------------
; Lok†ln° promànnÇ: [BP- 1] (1)  £rove§ naá°tanòch podadres†©ñ
;                   [BP- 2] (1)
;                   [BP- 4] (2) pracovn° identifik†tor DTA
;                   [BP- 5] (1)
;                   [BP-18] (13) jmÇno souboru s p©°ponou ASCIIZ
;                   [BP-22] (4)  velikost souboru
;                   [BP-24] (2)  datum souboru
;                   [BP-26] (2)  áas souboru
;                   [BP-27] (1)  atributy souboru
;                   [BP-48] (21) pracovn° adresa DTA - zaá†tek
;
;                   [BP-50] (2)  segment okna (adresa)
;                   [BP-52] (2)  á°slo okna
;                   [BP-54] (2)  segment adresy vòchoz° poloëky v seznamu
;                   [BP-56] (2)  offset adresy vòchoz° poloëky v seznamu
;                   [BP-58] (2)  segment adresy indexovÇ tabulky (=konec poloëek)
; niá° registry AX, BX, CX, DX, SI, DI a ES
; -----------------------------------------------------------------------------

NulFTree PROC      NEAR

; ------ p©°prava registrñ

         les       di,ss:[bp-56]            ; adresa vòchoz° poloëky
         mov       dl,ss:[bp-1]             ; £rove§ naá°tanòch adres†©ñ

; ------ adresa n†sleduj°c° poloëky -> ES:DI

NulFTre1:add       di,FileTSum              ; adresa dal®° poloëky
         mov       ax,di                    ; offset poloëky
         and       di,0fh                   ; normalizace offsetu poloëky
         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; p©evod offsetu na segment
         mov       bx,es                    ; segment poloëky
         add       ax,bx                    ; normalizace segmentu poloëky
         mov       es,ax                    ; segment dal®° poloëky

; ------ test, zda je jië konec poloëek

         cmp       ax,ss:[bp-58]            ; je jië konec poloëek ?
         jae       NulFTre9                 ; je jië konec poloëek

; ------ test, zda je to poloëka poëadovanÇ £rovnà

         cmp       dl,es:[di+FileTLev]      ; je to poëadovan† poloëka ?
         jb        NulFTre1                 ; podadres†© - p©eskoáen°
         ja        NulFTre9                 ; konec podadres†©e
         and       byte ptr es:[di+FileTPar],not bit4 ; p©°znak nenalezen° poloëky
         jmp       short NulFTre1           ; dal®° poloëka

NulFTre9:ret

NulFTree ENDP

; -----------------------------------------------------------------------------
;                                StorTree
;           Za©azen° nalezenÇho adres†©e do seznamu okna stromu
; -----------------------------------------------------------------------------
; VSTUP: SS:BP=ukazatel lok†ln°ch promànnòch
;        DS=datovò segment
; VùSTUP:CY=nedostatek pamàti
; -----------------------------------------------------------------------------
; Lok†ln° promànnÇ: [BP- 1] (1)  £rove§ naá°tanòch podadres†©ñ
;                   [BP- 2] (1)
;                   [BP- 4] (2) pracovn° identifik†tor DTA
;                   [BP- 5] (1)
;                   [BP-18] (13) jmÇno souboru s p©°ponou ASCIIZ
;                   [BP-22] (4)  velikost souboru
;                   [BP-24] (2)  datum souboru
;                   [BP-26] (2)  áas souboru
;                   [BP-27] (1)  atributy souboru
;                   [BP-48] (21) pracovn° adresa DTA - zaá†tek
;
;                   [BP-50] (2)  segment okna (adresa)
;                   [BP-52] (2)  á°slo okna
;                   [BP-54] (2)  segment adresy vòchoz° poloëky v seznamu
;                   [BP-56] (2)  offset adresy vòchoz° poloëky v seznamu
;                   [BP-58] (2)  segment adresy indexovÇ tabulky (=konec poloëek)
; niá° registry AX, BX, CX, DX, SI, DI a ES
; -----------------------------------------------------------------------------

StorTree PROC      NEAR

; ------ dek¢dov†n° nalezenÇ poloëky do tvaru FCB

         lea       si,ss:[bp-48]            ; zaá†tek tabulky DTA
         push      ss
         pop       es                       ; ES <- segment poloëky DTA
         call      far ptr GetBFCB          ; p©°prava poloëky ve tvaru FCB

; ------ p©°prava k nalezen° existuj°c° poloëky

         les       di,ss:[bp-56]            ; adresa vòchoz° poloëky
         or        byte ptr es:[di+FileTPar],bit1 ; p©°znak, ëe jsou podadres†©e
         mov       dl,ss:[bp-1]             ; £rove§ naá°tanòch adres†©ñ
         mov       ch,0                     ; CH <- 0

; ------ adresa n†sleduj°c° poloëky -> ES:DI

StorTre1:add       di,FileTSum              ; adresa dal®° poloëky
         mov       ax,di                    ; offset poloëky
         and       di,0fh                   ; normalizace offsetu poloëky
         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; p©evod offsetu na segment
         mov       bx,es                    ; segment poloëky
         add       ax,bx                    ; normalizace segmentu poloëky
         mov       es,ax                    ; segment dal®° poloëky

; ------ test, zda je jië konec poloëek

         cmp       ax,ss:[bp-58]            ; je jië konec poloëek ?
         jae       StorTre3                 ; je jië konec poloëek

; ------ test, zda je to poloëka poëadovanÇ £rovnà

         cmp       dl,es:[di+FileTLev]      ; je to poëadovan† poloëka ?
         jb        StorTre1                 ; podadres†© - p©eskoáen°
         ja        StorTre3                 ; konec podadres†©e - uloëen°

; ------ test, zda je to shodn† poloëka

         cld
         push      di
         mov       si,offset FileFCB        ; jmÇno hledanÇ poloëky FCB
         mov       cl,11                    ; poáet znakñ k porovn†n°
         inc       di                       ; zaá†tek jmÇna nalezenÇ poloëky
         repe      cmpsb                    ; porovn†n° poloëek
         pop       di
         ja        StorTre1                 ; je p©ed hledanou poloëkou - dal®°
         jb        StorTre3                 ; je za hledanou poloëkou - vloëen°

; ------ nalezena shodn† poloëka - aktualizace parametrñ

         or        byte ptr es:[di+FileTPar],bit4 ; p©°znak nalezen° poloëky
         mov       ax,ss:[bp-24]            ; datum adres†©e
         mov       es:[di+FileDate],ax      ; aktualizace data adres†©e
         mov       ax,ss:[bp-26]            ; áas adres†©e
         mov       es:[di+FileTime],ax      ; aktualizace áasu adres†©e
         mov       al,ss:[bp-27]            ; atributy
         and       al,not ATRU + ATRO       ; zru®en° oznaáen° poloëky
         or        al,ATRT                  ; p©°znak platnÇ poloëky
         and       byte ptr es:[di+FileAtr],ATRU+ATRO ; ponech† se oznaáen°
         or        es:[di+FileAtr],al       ; atributy adres†©e
         jmp       StorTre5

; ------ vytvo©en° m°sta pro novou poloëku (na adrese ES:DI)

StorTre3:push      bx
         push      dx

         mov       cl,FileTSum              ; velikost poloëky
         mov       dx,es                    ; DX <- adresa poloëky
         sub       dx,ss:[bp-50]            ; offset poloëky v segmentu
         xor       bx,bx                    ; poáet bajtñ k vloëen° HIGH
         mov       ax,ss:[bp-52]            ; á°slo okna
         call      far ptr InsSDat          ; vytvo©en° m°sta pro poloëku

         pop       dx
         pop       bx
         jnc       StorTr32
StorTr31:jmp       StorTre9                 ; chyba pamàti

; ------ posun ukazatelñ

StorTr32:push      es
         mov       es,ss:[bp-50]            ; segment okna
         inc       word ptr es:[AWinSouR]   ; zvò®en° á°taáe naátenòch souborñ

         add       word ptr es:[AWinSouI],cx         ; oprava adresy tabulky indexñ
         add       word ptr es:[AWinKomI],cx         ; oprava tabulky indexñ koment†©ñ
         call      far ptr NormIAWn         ; normalizace adres tabulek

         mov       ax,word ptr es:[AWinSouI+2]       ; adresa indexovÇ tabulky (segment)
         add       ax,ss:[bp-50]            ; + adresa okna
         mov       ss:[bp-58],ax            ; nov† adresa indexovÇ tabulky
         pop       es

; ------ p©°prava registrñ k dek¢dov†n° poloëky ES:DI

         push      di                       ; adresa zaá†tku poloëky

; ------ uloëen° parametrñ souboru

         push      ds

         push      ss
         pop       ds                       ; DS <- segment DTA se souborem
         cld

         lea       si,[bp-27]               ; atributy
         lodsb                              ; atributy souboru
         and       al,not ATRO + ATRU       ; nulov†n° nepot©ebnòch atributñ
         or        al,ATRT                  ; p©°znak platnÇ poloëky
         stosb                              ; atributy souboru
         lodsw                              ; áas souboru
         mov       es:[di+FileTime-1],ax    ; áas souboru
         lodsw                              ; datum souboru
         mov       es:[di+FileDate-1],ax    ; datum souboru
         lodsw                              ; velikost souboru - LOW
         mov       word ptr es:[di+FileSize-1],ax    ; velikost souboru - LOW
         lodsw                              ; velikost souboru - HIGH
         mov       word ptr es:[di+FileSize+2-1],ax  ; velikost souboru - HIGH
         mov       es:[di+FileTLev-1],dl    ; £rove§ adres†©e
         mov       byte ptr es:[di+FileTPar-1],bit2+bit4 ; parametry poloëky

         pop       ds

; ------ p©enos jmÇna adres†©e

         mov       si,offset FileFCB        ; p©ipravenÇ jmÇno adres†©e
         mov       cl,11                    ; dÇlka jmÇna adres†©e
         rep       movsb                    ; p©enos jmÇna adres†©e

; ------ nulov†n° ostatn°ch poloëek

         add       di,FileTFil-(FileName+11) ; zaá†tek parametrñ
         xor       ax,ax                    ; AX <- 0
         stosw                              ; poáet souborñ v adres†©i
         stosw
         stosw                              ; zabran† kapacita
         stosw
         stosw                              ; souáet velikost° poloëek

         pop       dx                       ; DL = zaá†tek poloëky (normalizov†no)

; ------ p©°prava ke korekci indexovÇ tabulky

         mov       dh,0                     ; DH <- 0 p©°znak nenalezen° poloëky
         mov       ax,es                    ; AX <- hledan† poloëka (segment)
         sub       ax,ss:[bp-50]            ; offset poloëky v segmentu
         mov       es,ss:[bp-50]            ; segment okna
         mov       cx,es:[AWinSouN]         ; poáet zobrazenòch poloëek
         mov       di,word ptr es:[AWinSouI]         ; adresa indexovÇ tabulky (offset)
         mov       si,word ptr es:[AWinSouI+2]       ; adresa indexovÇ tabulky (segment)
         add       si,ss:[bp-50]            ; + adresa okna
         mov       es,si                    ; ES <- segment indexovÇ tabulky

; ------ korekce indexovÇ tabulky

         jcxz      StorTre5                 ; nen° ë†dn† poloëka
StorTre4:inc       di                       ; p©eskoáen° bajtu offsetu
         scasw                              ; porovn†n° poloëky - segment
         ja        StorTr42                 ; poloëka se nemàn°
         mov       si,es:[di-3]             ; offset poloëky
         and       si,0fh                   ; offset poloëky
         add       byte ptr es:[di-3],FileTSum ; zvò®en° offsetu poloëky
         and       byte ptr es:[di-3],0fh   ; normalizace offsetu poloëky
         add       si,FileTSum              ; zvò®en° offsetu poloëky
         shr       si,1
         shr       si,1
         shr       si,1
         shr       si,1                     ; p©evod offsetu na segment
         add       es:[di-2],si             ; korekce segmentu adresy poloëky
StorTr42:loop      StorTre4                 ; dal®° poloëka

StorTre5:clc                                ; p©°znak operace OK

StorTre9:ret

StorTree ENDP

; *****************************************************************************
;                               DispTWn
;                    zobrazen° okna stromu (vnit©n° ©†dky)
; -----------------------------------------------------------------------------
; VSTUP: AX=á°slo datovÇho bloku okna
;        DL=poá†teán° pozice okna
;        DH=©†dek k zobrazen°
;        CL=poáet ©†dkñ k zobrazen°
;        ES=segment definice okna
;        DS=datovò segment
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) á°slo okna
;                   SS:[BP-4] (2) segment okna
;                   SS:[BP-6] (2) pozice a ©†dek k zobrazen°
;                   SS:[BP-7] (1)
;                   SS:[BP-8] (1) á°taá ©†dkñ k zobrazen°
;                   SS:[BP-10] (2) á°taá aktivn° poloëky
;                   SS:[BP-12] (2) ukazatel á°sla poloëky
;                   SS:[BP-14] (2) maska n†vaznosti stromu (nië®°ch 16 £rovn°)
; *****************************************************************************
;˛
DispTWn  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,sp

; ------ p©°prava bufferu v z†sobn°ku

         sub       sp,2*40 + 14             ; vytvo©en° bufferu v z†sobn°ku

; ------ p©°prava lok†ln°ch promànnòch

         mov       ss:[bp-2],ax             ; £schova á°sla okna
         mov       ss:[bp-4],es             ; segment okna
         mov       ss:[bp-6],dx             ; pozice a ©†dek k zobrazen°
         mov       ch,0                     ; CH <- 0
         mov       ss:[bp-8],cl             ; á°taá ©†dkñ k zobrazen°
         mov       ax,es:[AWinKurz]         ; poloëka s kurzorem
         mov       di,es:[AWinFrst]         ; prvn° poloëka
         sub       ax,di                    ; offset od prvn° poloëky
         inc       ax                       ; p©ednastaven° á°taáe kurzoru
         mov       ss:[bp-10],ax            ; á°taá aktivn° poloëky (kurzoru)
         mov       ss:[bp-12],di            ; ukazatel á°sla poloëky

; ------ p©°prava masky n†vaznosti (CH=0, DI=á°slo poá†teán° poloëky)

         mov       ch,0
         or        di,di
         jz        DispTWn1                 ; je prvn° poloëka
         xor       bx,bx                    ; ukazatel á°sla poloëky
DispTWn0:mov       es,ss:[bp-4]             ; adresa okna
         call      far ptr GetESPol         ; adresa poloëky
         jc        DispTWn1                 ; nen° dal®° poloëka (?)
         mov       cl,es:[si+FileTLev]      ; £rove§ poloëky
         jcxz      DispTW04                 ; poloëka ROOT se nepoá°t†
         dec       cx                       ; hladina - 1
         mov       ax,1                     ; maska
         shl       ax,cl                    ; rotace masky
         or        ss:[bp-14],ax            ; nastaven° masky
         test      byte ptr es:[si+FileTPar],bit3 ; bude dal®° podadres†© ?
         jnz       DispTW04                 ; bude dal®° podadres†©
         xor       ss:[bp-14],ax            ; nulov†n° masky
DispTW04:inc       bx                       ; zvò®en° ukazatele poloëek
         dec       di                       ; á°taá poloëek
         jnz       DispTWn0                 ; dal®° poloëka

; ------ inicializaán° vymaz†n° ©†dku

DispTWn1:push      ss
         pop       es                       ; ES <- segmentu bufferu v z†sobn°ku
         mov       di,sp                    ; buffer v z†sobn°ku
         cld
         mov       ah,ds:[ColXWin1]         ; bàën† barva textu
         mov       al,"∫"                   ; "∫" znak levÇho okraje
         stosw                              ; uloëen° levÇho okraje
         push      di
         mov       al," "                   ; znak mezery pro vymaz†n°
         mov       cl,38
         rep       stosw                    ; vymaz†n° vnit©ku ©†dku
         mov       al,"∫"                   ; "∫" znak pravÇho okraje
         stosw                              ; uloëen° pravÇho okraje
         pop       di                       ; zaá†tek textu ©†dku

; ------ adresa poloëky -> ES:SI

         mov       es,ss:[bp-4]             ; segment definice okna
         mov       bx,ss:[bp-12]            ; ukazatel á°sla poloëky
         call      far ptr GetESPol         ; adresa poloëky
         jnc       DispTWn2                 ; poloëka je OK
         jmp       DispTWn8                 ; dal®° ©†dek

; ------ dek¢dov†n° £vodn° znaáky aktivn°ho adres†©e

DispTWn2:push      es                       ; segment poloëky

         test      byte ptr es:[si+FileTPar],bit6 ; je to aktivn° adres†© ?

         push      ss
         pop       es                       ; ES <- segment bufferu
         mov       ah,ds:[ColXWin2]         ; vysv°cen† barva
         mov       al,16                    ; lev† znaáka
         jnz       DispTW20                 ; je to aktivn° adres†©
         mov       al," "                   ; neaktivn° poloëka
DispTW20:stosw                              ; uloëen° £vodn° znaáky
         jz        DispTW21                 ; nen° to aktivn° adres†©
         mov       al,17                    ; pravò okraj
         mov       es:[di+2*36],ax          ; pravò okraj

DispTW21:pop       es                       ; segment adresy poloëky

; ------ dek¢dov†n° masky n†vaznosti

         push      es                       ; segment poloëky

         mov       ah,ds:[ColXWin1]         ; bàën† barva textu
         mov       cl,es:[si+FileTLev]      ; hladina poloëky
         jcxz      DispTW29                 ; je ROOT
         dec       cx
         jz        DispTW25                 ; je prvn° poloëka - nen° n†vaznost
         push      ss
         pop       es                       ; ES <- segment definice okna
         cmp       cl,11                    ; maxim†ln° hladina
         jb        DispTW22                 ; hladina je OK
         mov       cl,11                    ; omezen° hladiny
DispTW22:mov       dx,ss:[bp-14]            ; maska n†vaznosti stromu
DispTW23:mov       al," "                   ; nen° dal®° adres†©
         shr       dx,1                     ; je dal®° adres†© ?
         jnc       DispTW24                 ; nen° dal®° adres†©
         mov       al,"≥"                   ; znak "≥" (je dal®° podadres†©)
DispTW24:stosw                              ; uloëen° znaku n†vaznosti
         mov       al," "
         stosw                              ; uloëen° oddàlovac° mezery
         loop      DispTW23                 ; dal®° hladina

DispTW25:pop       es

; ------ zobrazen° á†ry p©ed adres†©em

         push      es

         mov       dx,word ptr es:[si+FileTLev]      ; DL <- hladina, DH <- parametry
         push      ss
         pop       es                       ; ES <- segment bufferu
         cmp       dl,11                    ; je p©eteáen° ?
         jbe       DspTW254                 ; nen° p©eteáen°

         mov       al,dl                    ; hladina
         sub       al,11                    ; p©eteáen° hladiny
         add       al,"0"                   ; korekce na znak ASCII
         cmp       al,"9"                   ; je á°slo OK ?
         jbe       DspTW252                 ; á°slo je OK
         sub       al,10                    ; korekce á°sla
         mov       byte ptr es:[di-4],"1"   ; des°tky hladiny = 1
         cmp       al,"9"                   ; je á°slo jië OK ?
         jbe       DspTW252                 ; á°slo je jië OK
         sub       al,10                    ; korekce á°sla
         inc       byte ptr es:[di-4]       ; des°tky hladiny = 2
DspTW252:mov       es:[di-2],al             ; á°slo p©eteáen°
         mov       al,"Ø"                   ; "Ø" indik†tor p©eteáen°
         jmp       short DispTW27           ; je p©eteáen°

DspTW254:mov       al,"¿"                   ; "¿" - je posledn° poloëka
         test      dh,bit3                  ; bude dal®° podadres†© ?
         jz        DispTW26                 ; nebude dal®° podadres†©
         mov       al,"√"                   ; "√" - bude dal®° poloëka
DispTW26:stosw                              ; uloëen° odboáky v cestà
         mov       al,"ƒ"                   ; "ƒ"
DispTW27:stosw                              ; oddàlovac° á†ra

         pop       es

; ------ modifikace masky n†vaznosti (CH=0)

         push      es

         mov       cl,es:[si+FileTLev]      ; £rove§ poloëky
         jcxz      DispTW29                 ; je ROOT
         dec       cx                       ; £rove§ - 1
         mov       dx,1                     ; maska
         shl       dx,cl                    ; rotace masky
         or        ss:[bp-14],dx            ; nastaven° masky
         test      byte ptr es:[si+FileTPar],bit3 ; bude dal®° podadres†© ?
         jnz       DispTW29                 ; bude dal®° podadres†©
         xor       ss:[bp-14],dx            ; nulov†n° masky

DispTW29:pop       es

; ------ p©°prava barvy poloëky (AH=bàën†) -> DH znaáka, AH poloëka, AL vysv°cen†

         mov       al,ds:[ColXWin2]         ; vysv°cen† poloëka
         mov       dh,ds:[ColTre1]          ; bàën† barva znaáky
         test      byte ptr es:[si+FileTPar],bit0 ; je to ovà©enò adres†© ?
         jnz       DispTW2A                 ; je to ovà©enò adres†©
         mov       ah,ds:[ColTre3]          ; barva neovà©enÇ poloëky
DispTW2A:dec       word ptr ss:[bp-10]      ; sn°ëen° á°taáe aktivn° poloëky
         jnz       DispTWn3                 ; nen° to ©†dek s kurzorem
         mov       bx,ss:[bp-2]             ; á°slo okna
         cmp       bx,ds:[SegmAkt]          ; je to aktivn° okno ?
         jne       DispTWn3                 ; nen° to aktivn° okno
         mov       ah,ds:[ColXWin3]         ; barva kurzoru
         mov       al,ds:[ColXWin4]         ; vysv°cenò kurzor
         mov       dh,ds:[ColTre2]          ; barva kurzoru znaáky

; ------ rozli®en° vysv°cenÇ poloëky -> AH barva poloëky

DispTWn3:test      byte ptr es:[si+FileAtr],ATRO ; je to oznaáen† poloëka ?
         jz        DispTWn4                 ; nen° oznaáen† poloëka
         mov       ah,al                    ; barva oznaáenÇ poloëky

; ------ indik†tor poloëky

DispTWn4:push      ds

         push      es                       ; segment poloëky

         mov       dl,es:[si+FileTPar]      ; parametry poloëky
         push      ss
         pop       es                       ; segment bufferu
         test      dl,bit1                  ; jsou adres†©e ?
         jz        DispTWn5                 ; nejsou adres†©e
         xchg      ah,dh                    ; AH <- barva znaáky
         mov       al,"˛"                   ; "˛" - p©°znak podadres†©ñ
         test      dl,bit2                  ; podadres†©e rozvinuty ?
         jnz       DispTW42                 ; podadres†©e rozvinuty
         mov       al,4                     ; 4 - podadres†©e nerozvinuty
DispTW42:stosw                              ; zobrazen° indik†toru
         xchg      ah,dh                    ; AH <- barva poloëky

DispTWn5:pop       ds                       ; segment adresy poloëky

; ------ vymaz†n° podkladu pod poloëkou

         push      di
         mov       cl,12                    ; poáet znakñ na poloëky
         mov       al," "                   ; mazac° znak mezery
         rep       stosw                    ; vymaz†n° poloëky
         pop       di

; ------ dek¢dov†n° jmÇna poloëky

         mov       cl,8                     ; poáet znakñ na jmÇno poloëky
         cld
         inc       si                       ; p©eskoáen° atributñ poloëky
DispTW65:lodsb
         stosw
         loop      DispTW65                 ; dal®° znak jmÇna poloëky

; ------ vypu®tàn° mezer na konci jmÇna poloëky

DispTW66:cmp       byte ptr es:[di-2]," "   ; je mezera ?
         jne       DispTW67                 ; nen° mezera, OK
         dec       di
         dec       di
         jmp       short DispTW66           ; dal®° znak

; ------ dek¢dov†n° p©°pony poloëky

DispTW67:mov       cl,3                     ; poáet znakñ na p©°ponu
         cmp       byte ptr ds:[si+2]," "   ; je p©°pona ?
         jne       DispTW68                 ; je p©°pona
         cmp       word ptr ds:[si],"  "    ; je p©°pona ?
         je        DispTW69                 ; nen° p©°pona
DispTW68:mov       al,"."
         stosw                              ; oddàlovac° teáka
DispTW69:lodsb
         stosw
         loop      DispTW69                 ; dal®° znak

         pop       ds

; ------ zobrazen° jednoho ©†dku

DispTWn8:inc       word ptr ss:[bp-12]      ; zvò®en° ukazatele poloëky
         mov       si,sp                    ; buffer v z†sobn°ku
         mov       cl,40                    ; dÇlka textu ©†dku
         mov       dx,ss:[bp-6]             ; pozice a ©†dek k zobrazen°
         xor       ax,ax                    ; hladina k zobrazen°
         push      ss
         pop       es
         call      far ptr DispMStr         ; zobrazen° textu

; ------ p©°prava k zobrazen° dal®°ho ©†dku

         inc       byte ptr ss:[bp-5]       ; zvò®en° ukazatele ©†dku
         dec       byte ptr ss:[bp-8]       ; sn°ëen° á°taáe ©†dkñ k zobrazen°
         jz        DispTWn9                 ; jsou jië v®echny ©†dky
         jmp       DispTWn1                 ; zobrazen° dal®°ho ©†dku

; ------ n†vrat registrñ

DispTWn9:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispTWn  ENDP

CodeTre  ENDS

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                                 Data
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
Data     SEGMENT

; -----------------------------------------------------------------------------
;        chybovÇ hl†®en° - nedostatek pamàti k naáten° stromu
; -----------------------------------------------------------------------------

ChbTrMem label     byte

         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        1                        ; poáet platnòch poloëek menu
         dw        5                        ; celkovò poáet poloëek menu

         dw        ChbTrMeP                 ; zaá†tek definice poloëek menu
         dw        ChbLnMeH                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@Main                 ; á°slo str†nky velkÇ n†povàdy
         dw        ChbTrMeB                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        ChbLnMeT                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        23                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        52                       ; ®°©ka okna
         db        9                        ; vò®ka okna

         dw        255                      ; maxim†ln° dÇlka textu ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        0                        ; celkovò poáet ©†dkñ
         dw        0                        ; poáet zobrazenòch ©†dkñ

         db        bit3                     ; maska zad†vanòch znakñ
         db        0,'      '               ; zak†zanÇ znaky

         db        0                        ; historie
         db        0                        ; poáet p©edvoleb


ChbTrMeP db        bit6,6,0,'CHYBA'
         db        bit6,42,'Nedostatek pamàti k naáten° stromu disku !'
         db        bit6,0
         db        bit6+bit7,0
         db        1,6,'N†vrat'

ChbTrMeB db        0                        ; blokovac° tabulka

FileNTre db        12,'$DOSMAN$.TRE'

;ColTre1  db        1ch                      ; identifikaán° znaáka adres†©e
;ColTre2  db        3ch                      ; identif. znaáka s kurzorem

Data     ENDS

         END

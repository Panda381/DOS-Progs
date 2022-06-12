
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                            D A T A B è Z E
;
;             Zpracov†n° dat - modifikace z†hlav° datab†ze, SEZNAM
;
; =============================================================================
;
; Ve©ejnÇ procedury:
;
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

CodeDbf  SEGMENT   BYTE PUBLIC
         ASSUME    cs:CodeDbf,ds:Data

; *****************************************************************************
;
;                       Modifikace z†hlav° datab†ze
;
; *****************************************************************************
;˛
; ------ zak†z†no, je-li editace

EditBMod:test      byte ptr es:[DBFParm],bit1 ; je z†kaz z†pisu ?
         jnz       EditBM00                 ; je z†kaz z†pisu
         test      byte ptr ds:[DBFEParm],bit0 ; je editace ?
         jz        EditBMd0                 ; nen° editace
EditBM00:ret

; ------ £schova registrñ

EditBMd0:call      ClosBMem                 ; uzav©en° souboru MEMO

         push      ax
         push      dx
         push      si                       ; mus° bòt jako posledn° !!!
         mov       bx,ds:[si+DBMnuSeg]      ; £schova segmentu datab†ze

; ------ vytvo©en° segmentu popisovaáñ (ES=adresa segmentu datab†ze)

         mov       cx,es:[DBFNumP]          ; poáet popisovaáñ
         call      CreaBMMn                 ; vytvo©en° segmentu
         jnc       EditBMd1                 ; operace OK
         jmp       EditBMd9

EditBMd1:mov       si,offset DBMMMnu        ; menu popisovaáe modifikace
         mov       word ptr ds:[si+DBMMnSeg],ax ; segment okna

; ------ inicializace modifikace (AX=modifikace, BX=datab†ze, ES=modifikace)

         call      IniBMMn                  ; inicializace segmentu

; ------ otev©en° okna modifikace

         call      far ptr OpenMnu          ; otev©en° okna modifikace

; ------ vstup znaku z kl†vesnice -> BX

EditBMd4:call      far ptr NulBreak         ; nulov†n° p©°znaku p©eru®en°
         call      far ptr InpChar          ; znak z kl†vesnice -> BX

; ------ adresa segmentu modifikace

         mov       ax,ds:[si+DBMMnSeg]      ; segment modifikace
         call      far ptr GetDat           ; adresa definice okna

; ------ test, zda je aktivn° platn† poloëka

         xor       di,di                    ; nen° platn† poloëka
         mov       ax,es:[DBFAktM]          ; aktivn° poloëka
         cmp       ax,es:[DBFNumM]          ; je to platn† poloëka ?
         jae       EditBMd5                 ; nen° platn† poloëka

; ------ adresa popisovaáe aktivn° poloëky

         mov       di,DBFM                  ; dÇlka poloëky
         mul       di                       ; offset aktivn° poloëky
         add       ax,DBFPopM               ; adresa aktivn° poloëky
         xchg      ax,di                    ; DI <- adresa aktivn° poloëky
         jmp       short EditBMd6

; ------ ENTER na posledn° poloëce znamen† konec modifikace

EditBMd5:cmp       bl,CR                    ; je CR ?
         je        EditBMd7                 ; konec modifikace

; ------ p©°prava aktivn° poloëky -> AX a poátu poloëek -> DX

EditBMd6:mov       ax,es:[DBFAktM]          ; aktivn° poloëka
         mov       dx,es:[DBFNumM]          ; poáet poloëek

; ------ p©°prava vnit©n° vò®ky okna -> CX

         mov       ch,0
         mov       cl,ds:[si+MnuVys]        ; vò®ka okna
         sub       cl,4                     ; vnit©n° vò®ka okna - 1

; ------ kl†vesy ESC a F10 je takÇ konec

         cmp       bx,MousXKod+MousXRP      ; stisk pravÇho tlaá°tka my®i ?
         je        EdiBMd68                 ; konec
         cmp       bl,ESCP
         je        EditBMd7                 ; ESC konec
         cmp       bx,4400h
         je        EditBMd7                 ; F10 konec

; ------ obsluha editace okna modifikace

         call      EditBMd                  ; obsluha modifikace

; ------ zobrazen° okna modifikace

         call      far ptr DispMnu          ; zobrazen° okna modifikace
         jmp       short EditBMd4           ; dal®° kl†vesa

; ------ ukonáen° editace aktivn° poloëky

EdiBMd68:mov       bl,ESCP                  ; n†hrada k¢dem ESC
EditBMd7:call      EdiDBEnd                 ; ukonáen° editace poloëky

; ------ uzav©en° okna modifikace

         mov       ax,ds:[si+DBMMnSeg]      ; AX <- segment modifikace
         push      si
         call      far ptr ClosMnu          ; uzav©en° okna menu
         pop       si

; ------ pro ESC se operace p©eru®°

         pop       di                       ; definice datab†ze
         push      di

         cmp       bl,ESCP                  ; je ESC ?
         je        EdiBMd72                 ; je ESC - p©eru®en°

; ------ jinak se provede konverze souboru

         mov       word ptr ds:[DBZobOld+2],-1 ; pot©eba naáten° MEMO

         call      far ptr ModiDBF          ; modifikace datab†ze

; ------ operace OK, zru®en° p©°znaku vytvo©en° souboru

EdiBMd72:and       byte ptr ds:[DBFEParm],not bit6 ; zru®en° p©°znaku vytvo©en°

; ------ zru®en° segmentu modifikace datab†ze

         call      far ptr DelSeg           ; zru®en° segmentu

; ------ n†vrat registrñ (a adresy okna)

EditBMd9:pop       si
         pop       dx
         pop       ax
         call      ModiDKor                 ; aktualizace parametrñ okna
         call      DBFAdrES                 ; aktualizace adresy okna -> ES
         ret

; -----------------------------------------------------------------------------
;        modifikace datab†ze (posouv† segmenty !)
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=definice modifikace datab†ze
;        DS:DI=definice aktivn° datab†ze
; VùSTUP: CY=chyba nebo p©eru®en°
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) definice aktivn° datab†ze
;                   SS:[BP-4] (2) definice modifikace datab†ze
;                   SS:[BP-6] (2) segment starÇ datab†ze
;                   SS:[BP-8] (2) segment novÇ datab†ze
;                   SS:[BP-10] (2) segment modifikace datab†ze
;                   SS:[BP-12] (2)  (adresa starÇ datab†ze)
;                   SS:[BP-14] (2)  (adresa novÇ datab†ze)
;                   SS:[BP-16] (2)  (adresa modifikace datab†ze)
;                   SS:[BP-18] (2) vstupn° soubor
;                   SS:[BP-20] (2) vòstupn° soubor
; -----------------------------------------------------------------------------
;˛
ModiDBF  PROC      FAR

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

; ------ p©°prava lok†ln°ch promànnòch

         sub       sp,20
         mov       ss:[bp-2],di             ; definice aktivn° datab†ze
         mov       ss:[bp-4],si             ; definice modifikace datab†ze
         mov       ax,ds:[di+DBMnuSeg]      ; segment datab†ze
         mov       ss:[bp-6],ax             ; segment aktivn° datab†ze
         mov       ax,ds:[si+DBMMnSeg]      ; segment okna modifikace
         mov       ss:[bp-10],ax            ; segment okna modifikace

; ------ zobrazen° hl†®en°

         push      si
         mov       word ptr ds:[InfoKCit],0 ; á°taá ukazatele kurzoru
         mov       word ptr ds:[InfoKCit+2],0
         mov       si,offset DBFModHl       ; hl†®en° o ru®en°
         call      far ptr InfDisp0         ; zobrazen° hl†®en°
         pop       si

; ------ normalizace poloëek (implicitn° dÇlky atd.)

         call      ModDBNrm                 ; normalizace poloëek modifikace

; ------ test, zda je zmàna struktury z†znamu (a p©°p. uloëen° jen z†hlav°)

         call      ModDBStr                 ; test, zda se jen màn° struktura
         jnc       ModiDBF1                 ; bude zmàna struktury
         clc                                ; p©°znak operace OK
         jmp       ModiDBF9

; ------ vytvo©en° vòstupn°ho souboru

ModiDBF1:mov       si,di                    ; SI <- adresa datab†ze
         call      DBFTOpen                 ; vytvo©en° p©echodnÇho souboru
         jnc       ModiDBF3                 ; soubor vytvo©en OK
ModiDBF2:jmp       ModiDBF8                 ; chyba
ModiDBF3:mov       ss:[bp-8],ax             ; segment novÇho okna

; ------ identifik†tor zdrojovÇho souboru

         mov       cx,es:[DBFIdent]         ; identifik†tor souboru
         mov       ss:[bp-18],cx            ; identifik†tor vstupn°ho souboru

; ------ sestaven° popisovaáñ poloëek (AX=segment novÇ datab†ze)

         mov       dx,ss:[bp-10]            ; segment modifikace
         call      ModiPop                  ; sestaven° popisovaáñ poloëek
         jc        ModiDBF2                 ; chyba

; ------ identifik†tor vòstupn°ho souboru

         call      far ptr GetDat           ; adresa novÇ datab†ze
         mov       ax,es:[DBFIdent]         ; identifik†tor souboru
         mov       ss:[bp-20],ax            ; identifik†tor vòstupn°ho souboru

; ------ z†pis z†hlav° na disk (ukazatel resetov†n, chyba se ignoruje)

         mov       si,DBFHlava              ; z†hlav° novÇho souboru
         mov       cx,es:[DBFBytH]          ; velikost z†hlav° (bajtñ)
         call      far ptr WritFile         ; z†pis z†hlav°

; ------ inicializace segmentu modifikace

         call      ModiDIBf                 ; inicializace segmentu modifikace
         jc        ModiDBF2                 ; chyba pamàti

; ------ nastaven° ukazatele ve vstupn°m souboru (chyba se teÉ ignoruje)

         mov       ax,ss:[bp-6]             ; segment starÇ datab†ze
         call      far ptr GetDat           ; adresa segmentu datab†ze
         mov       cx,es:[DBFBytH]          ; poáet bajtñ na z†hlav°
         xor       dx,dx                    ; DX <- 0
         mov       ax,ss:[bp-18]            ; vstupn° soubor
         call      far ptr SetUFile         ; nastaven° ukazatele v souboru

; ------ inicializace kurzoru operace

         xor       cx,cx                    ; CX <- 0
         call      far ptr InfoKurz         ; zobrazen° kurzoru operace

; ------ proveden° konverze souboru

         mov       ax,ss:[bp-10]            ; segment modifikace
         call      ModDBMod                 ; proveden° konverze souboru
         jc        ModiDBF8                 ; chyba z†pisu

; ------ konec konverze souboru

         mov       ax,ss:[bp-8]             ; segment novÇho okna
         call      far ptr GetDat           ; adresa novÇho okna
         call      UlozDEOF                 ; z†pis koncovÇho znaku EOF

         mov       si,ss:[bp-2]             ; adresa definice okna
         call      DBFTClos                 ; uzav©en° vòstupn°ho souboru
         jnc       ModiDBF9                 ; operace OK

; ------ chyba z†pisu do vòstupn°ho souboru

ModiDBF8:mov       di,offset DBHMWrt        ; hl†®en° - chyba z†pisu
         call      far ptr Lin0MenP         ; chybovÇ hl†®en°

; ------ zru®en° vòstupn°ho souboru, zru®en° bufferu

         mov       ax,ss:[bp-8]             ; segment novÇho okna
         mov       si,ss:[bp-2]             ; adresa definice datab†ze
         call      DBFTDel                  ; zru®en° segmentu AX p©i chybà
         stc

; ------ n†vrat registrñ

ModiDBF9:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         call      far ptr InfoClos         ; uzav©en° informaán°ho ©†dku
         ret

ModiDBF  ENDP

; -----------------------------------------------------------------------------
;        normalizace poloëek modifikace datab†ze
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=definice modifikace datab†ze
; -----------------------------------------------------------------------------

ModDBNrm PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      es

; ------ adresa segmentu modifikace -> ES

         mov       ax,ds:[si+DBMMnSeg]      ; segment modifikace datab†ze
         call      far ptr GetDat           ; adresa segmentu -> ES

; ------ p©°prava registrñ

         mov       cx,es:[DBFNumM]          ; poáet poloëek
         jcxz      ModDBNr9                 ; nen° ë†dn† poloëka
         mov       bx,DBFPopM               ; zaá†tek popisovaáñ

; ------ dÇlka mus° bòt minim†lnà 1

ModDBNr2:cmp       byte ptr es:[bx+DBFDelM],0 ; dÇlka minim†lnà 1 ?
         jne       ModDBNr3                 ; dÇlka je OK
         inc       byte ptr es:[bx+DBFDelM] ; minim†ln° dÇlka 1

; ------ pro jinou neë á°selnou poloëku mus° bòt poáet desetinnòch m°st = 0

ModDBNr3:test      byte ptr es:[bx+DBFTypM],bit7 ; jinò typ poloëky ?
         jnz       ModDBNr5                 ; je jinò typ poloëky
         test      byte ptr es:[bx+DBFTypM],bit1+bit2 ; je á°seln† poloëka ?
         jnz       ModDBNr4                 ; je á°seln† poloëka
         mov       byte ptr es:[bx+DBFDesM],0 ; poáet desetinnòch m°st = 0
         jmp       short ModDBNr5

; ------ omezen° dÇlky á°selnÇ poloëky

ModDBNr4:cmp       byte ptr es:[bx+DBFDelM],20 ; maxim†ln° dÇlka á°selnÇ poloëky
         jbe       ModDBN42                 ; dÇlka poloëky je OK
         mov       byte ptr es:[bx+DBFDelM],20 ; maxim†ln° dÇlka á°selnÇ poloëky

; ------ omezen° poátu desetinnòch m°st

ModDBN42:mov       al,es:[bx+DBFDelM]       ; dÇlka poloëky
         sub       al,2                     ; zbytek na desetinn† m°sta
         jnc       ModDBN44                 ; je to OK
         mov       al,0                     ; omezen° p©i podteáen°
ModDBN44:cmp       al,es:[bx+DBFDesM]       ; poáet desetin je OK ?
         jae       ModDBNr5                 ; poáet desetin je OK
         mov       es:[bx+DBFDesM],al       ; omezen° poátu desetinnòch m°st

; ------ implicitn° dÇlka poloëek

ModDBNr5:mov       al,es:[bx+DBFTypM]       ; typ poloëky
         test      al,bit3+bit4+bit5+bit6   ; bude implicitn° dÇlka ?
         jz        ModDBNr8                 ; nebude implicitn° dÇlka

         mov       ah,8                     ; dÇlka pro datum
         test      al,bit3                  ; je datum ?
         jnz       ModDBNr6                 ; je datum

         mov       ah,1                     ; dÇlka pro logickou poloëku
         test      al,bit4                  ; je logick† poloëka ?
         jnz       ModDBNr6                 ; je logick† poloëka

         mov       ah,10                    ; dÇlka pro MEMO pole
         test      al,bit5                  ; je MEMO pole ?
         jnz       ModDBNr6                 ; je MEMO pole

         mov       ah,6                     ; jinak dÇlka pro áas
ModDBNr6:mov       es:[bx+DBFDelM],ah       ; implicitn° dÇlka

; ------ p©°prava pro dal®° poloëku

ModDBNr8:add       bx,DBFM                  ; dal®° poloëka
         loop      ModDBNr2                 ; dal®° poloëka

; ------ n†vrat registrñ

ModDBNr9:pop       es
         pop       cx
         pop       bx
         pop       ax
         ret

ModDBNrm ENDP

; -----------------------------------------------------------------------------
;        test, zda je zmàna struktury z†znamu (a p©°p. uloëen° novÇho z†hlav°)
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=definice modifikace datab†ze
;        DS:DI=definice aktivn° datab†ze
; VùSTUP: CY=chyba nebo nen° zmàna struktury z†znamu
; -----------------------------------------------------------------------------

ModDBStr PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es

; ------ test, zda je p©eru®en° operace

         call      far ptr TestBEsc         ; je p©eru®en° operace ?
         jc        ModDBSt1                 ; je p©eru®en° operace

; ------ adresa segmentu modifikace -> ES

         mov       ax,ds:[si+DBMMnSeg]      ; segment modifikace datab†ze
         call      far ptr GetDat           ; adresa segmentu -> ES

; ------ test platnosti modifikace

         mov       cx,es:[DBFNumM]          ; poáet poloëek v bufferu modifikace
         or        cx,cx                    ; je nàjak† poloëka ?
         jnz       ModDBSt3                 ; je nàjak† poloëka OK

; ------ p©eru®en° operace

ModDBSt1:stc                                ; p©°znak p©eru®en° operace
ModDBSt2:jmp       ModDBSt9

; ------ pro novou datab†zi bude modifikace vëdy

ModDBSt3:test      byte ptr ds:[DBFEParm],bit6 ; je novò soubor ?
         jnz       ModDBSt2                 ; je to novò soubor (je NC !)

; ------ £schova registrñ p©ed ovà©en°m struktury

         push      cx
         push      si
         push      di
         push      ds                       ; £schova DS

; ------ adresa segmentu datab†ze -> DS

         mov       ax,ds:[di+DBMnuSeg]      ; segment datab†ze
         call      far ptr GetSgAdr         ; adresa segmentu -> DX
         mov       ds,dx                    ; DS <- adresa segmentu datab†ze

; ------ test, zda byl zmànàn poáet popisovaáñ

         cmp       cx,ds:[DBFNumP]          ; byl zmànàn poáet popisovaáñ ?
         jne       ModDBSt5                 ; zmànàn poáet popisovaáñ

; ------ p©°prava ukazatelñ

         xor       dx,dx                    ; DX <- ukazatel á°sla poloëky
         mov       di,DBFPopM               ; popisovaáe v modifikaci
         mov       si,ds:[DBFAdrP]          ; popisovaáe v datab†zi

; ------ kontrola á°sla poloëky

ModDBSt4:cmp       dx,es:[di+DBFNumM1]      ; souhlas° á°slo poloëky ?
         jne       ModDBSt5                 ; nesouhlas° á°slo poloëky
         cmp       word ptr es:[di+DBFNumM2],-1 ; je p©ipojena poloëka 2 ?
         jne       ModDBSt5                 ; je p©ipojena poloëka 2

; ------ kontrola dÇlky poloëky

         mov       al,es:[di+DBFDelM]       ; nov† dÇlka poloëky
         cmp       al,ds:[si+DBFDelX]       ; zmànàna dÇlka poloëky ?
         jne       ModDBSt5                 ; dÇlka poloëky zmànàna

; ------ kontrola poátu desetinnòch m°st

         test      byte ptr es:[di+DBFTypM],bit1+bit2 ; je to á°seln† poloëka ?
         jz        ModDBS42                 ; na desetinnòch m°stech nez†leë°
         mov       al,es:[di+DBFDesM]       ; poáet desetinnòch m°st
         mov       bx,ds:[si+DBFNamX]       ; adresa jmÇna popisovaáe
         cmp       al,ds:[bx+17]            ; zmànàn poáet desetinnòch m°st ?
         jne       ModDBSt5                 ; poáet desetinnòch m°st zmànàn

; ------ kontrola poá†teán°ho offsetu v poloëce

ModDBS42:cmp       byte ptr es:[di+DBFPozM],0 ; zmànàn offset v poloëce ?
         jne       ModDBSt5                 ; zmànàn offset v poloëce

; ------ p©°prava pro dal®° poloëku

         inc       dx                       ; zvò®en° ukazatele á°sla poloëky
         add       di,DBFM                  ; dal®° popisovaá modifikace
         add       si,DBFX                  ; dal®° popisovaá datab†ze
         loop      ModDBSt4                 ; dal®° poloëka
         xor       ax,ax                    ; nastaven° p©°znaku ZY=nezmànàno

; ------ n†vrat registrñ po ovà©en° struktury (ZY=struktura nezmànàna)

ModDBSt5:pop       ds
         pop       di
         pop       si
         pop       cx
         clc                                ; p©°znak zmàny struktury z†znamu
         jne       ModDBSt2                 ; struktura z†znamu zmànàna

; ------ zmàna z†hlav° datab†ze

         push      di                       ; adresa definice datab†ze
         push      ds

         mov       ax,ds:[di+DBMnuSeg]      ; segment datab†ze
         call      far ptr GetSgAdr         ; adresa segmentu -> DX
         mov       ds,dx                    ; DS <- adresa segmentu datab†ze

         and       byte ptr ds:[DBFParm],not bit4 ; nen° MEMO soubor

         mov       di,DBFPopM               ; popisovaáe v modifikaci
         mov       si,ds:[DBFAdrP]          ; popisovaáe v datab†zi

ModDBSt6:mov       bx,ds:[si+DBFNamX]       ; adresa jmÇna poloëky
         mov       al,es:[di+DBFDesM]       ; poáet desetinnòch m°st
         mov       ds:[bx+17],al            ; nastaven° poátu desetinnòch m°st

         mov       al,es:[di+DBFTypMC]      ; znak pro jinò typ poloëky
         mov       cs:[ModDBSTb+7],al       ; znak pro jinò typ poloëky

         mov       al,es:[di+DBFTypM]       ; typ poloëky
         mov       ds:[si+DBFParX],al       ; typ poloëky

         cmp       al,bit5                  ; je MEMO poloëka ?
         jne       ModDBS60                 ; nen° MEMO poloëka
         or        byte ptr ds:[DBFParm],bit4 ; p©°znak MEMO souboru

ModDBS60:push      bx
         mov       bx,offset ModDBSTb-1
ModDBS61:inc       bx
         shr       al,1
         jnc       ModDBS61
         mov       al,cs:[bx]               ; oznaáen° typu poloëky
         pop       bx

         mov       ds:[bx+11],al            ; nastaven° typu poloëky

         push      cx
         push      di
         mov       cx,10                    ; dÇlka jmÇna poloëky
         mov       byte ptr ds:[si+DBFNumX],0 ; á°taá dÇlky jmÇna
ModDBS62:mov       al,es:[di+DBFNamM]       ; znak jmÇna poloëky
         cmp       al," "                   ; je to platnò znak ?
         je        ModDBS64                 ; konec jmÇna
         mov       ds:[bx],al               ; uloëen° znaku jmÇna poloëky
         inc       byte ptr ds:[si+DBFNumX] ; zvò®en° á°taáe dÇlky jmÇna
         inc       di
         inc       bx
         loop      ModDBS62                 ; dal®° znak jmÇna
ModDBS64:inc       cx                       ; 1 znak nav°c jako konec
ModDBS66:mov       byte ptr ds:[bx],0       ; koncovò znak 0
         inc       bx
         loop      ModDBS66                 ; vymaz†n° zbytku jmÇna
         pop       di
         pop       cx

         add       di,DBFM                  ; dal®° popisovaá modifikace
         add       si,DBFX                  ; dal®° popisovaá datab†ze
         loop      ModDBSt6                 ; dal®° poloëka

         pop       ds
         pop       si                       ; SI <- adresa definice datab†ze

; ------ z†pis novÇho z†hlav° na disk

         call      DBFAdrES                 ; aktualizace adresy datab†ze -> ES
         or        byte ptr ds:[DBFEParm],bit7 ; datum v z†hlav° se nemàn°
         mov       ax,es:[DBFIdent]         ; identifik†tor souboru
         call      far ptr GetDFile         ; naáten° data a áasu
         jc        ModDBSt8                 ; chyba
         call      far ptr ZapKrit          ; zapnut° kritickÇ sekce
         call      far ptr HlavDBF          ; z†pis z†hlav° na disk
         call      far ptr SetDFile         ; navr†cen° data a áasu
         call      far ptr VypKrit          ; vypnut° kritickÇ sekce
ModDBSt8:stc                                ; p©°znak ukonáen° operace

; ------ n†vrat registrñ

ModDBSt9:pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

ModDBStr ENDP

ModDBSTb db        'CNFDLMT?'               ; typy poloëek

; -----------------------------------------------------------------------------
;        p©°prava p©echodnÇho bufferu (CY=chyba)
; -----------------------------------------------------------------------------

ModiDIBf PROC      NEAR
;˛
; ------ p©°prava velikost° z†znamñ

         mov       ax,ss:[bp-6]             ; segment starÇ datab†ze
         call      far ptr GetDat           ; adresa starÇ datab†ze -> ES

         mov       si,es:[DBFMaxZ]          ; poáet z†znamñ v souboru LOW
         mov       di,es:[DBFMaxZ+2]        ; poáet z†znamñ v souboru HIGH

         mov       cx,es:[DBFBytZ]          ; poáet bajtñ na starò z†znam

         mov       ax,ss:[bp-8]             ; segment novÇ datab†ze
         call      far ptr GetDat           ; adresa novÇ datab†ze -> ES

         mov       es:[DBFMaxZ],si          ; poáet z†znamñ v souboru
         mov       es:[DBFMaxZ+2],di

         mov       bx,es:[DBFBytZ]          ; poáet bajtñ na novò z†znam

         mov       ax,ss:[bp-10]            ; segment modifikace
         call      far ptr GetDat           ; adresa segmentu -> ES

         mov       es:[DBFZaz1M],cx         ; velikost vstupn°ho z†znamu
         mov       es:[DBFZaz2M],bx         ; velikost vòstupn°ho z†znamu

         mov       es:[DBFCitZM],si         ; á°taá z†znamñ LOW
         mov       word ptr ds:[InfoKMax],si ; ukazatel operace LOW
         mov       es:[DBFCitZM+2],di       ; á°taá z†znamñ HIGH
         mov       word ptr ds:[InfoKMax+2],di ; ukazatel operace HIGH

         add       cx,bx                    ; velikost obou z†znamñ
         jc        ModDIBf4                 ; chyba p©eteáen°

; ------ p©°prava volnÇ pamàti v bufferu

         mov       di,es:[0]                ; velikost dat v bufferu
         call      far ptr GetFree          ; voln† pamàü -> BX
         sub       bx,100h                  ; rezerva 4 KB
         jb        ModDIBf4                 ; m†lo pamàti
         cmp       bx,0fffh                 ; maximum pamàti
         jbe       ModDIBf2
         mov       bx,0fffh                 ; omezen° velikosti bloku na 64 KB
ModDIBf2:shl       bx,1
         shl       bx,1
         shl       bx,1
         shl       bx,1                     ; voln† pamàü v bajtech
         add       bx,di                    ; novò konec segmentu
         jnc       ModDIBf3
         mov       bx,0ffffh                ; omezen° p©i p©eteáen°
ModDIBf3:sub       bx,di                    ; voln† pamàü

; ------ zvò®en° velikosti segmentu modifikace

         xchg      ax,bx                    ; AX <- voln† pamàü
         xor       dx,dx                    ; DX <- 0
         div       cx                       ; poáet z†znamñ v bufferu
         mov       es:[DBFMaxM],ax          ; max. poáet z†znamñ
         or        ax,ax                    ; je nàjakò z†znam ?
         stc                                ; p©°znak chyby
         jz        ModDIBf9                 ; chyba pamàti
         mul       cx                       ; poëadovan† pamàü v bajtech
         xchg      ax,cx                    ; CX <- poáet bajtñ k vloëen°
         mov       ax,ss:[bp-10]            ; segment modifikace
         call      far ptr InsDat           ; vytvo©en° m°sta
ModDIBf4:jc        ModDIBf9                 ; chyba pamàti

; ------ inicializace ostatn°ch ukazatelñ

         mov       es:[DBFBeg1M],di         ; zaá†tek vstupn°ho bufferu
         mov       es:[DBFEnd1M],di         ; konec dat ve vstupn°m bufferu
         mov       es:[DBFReadM],di         ; átec° adresa ze vstupn°ho bufferu

         mov       ax,ss:[bp-18]            ; vstupn° soubor
         mov       es:[DBFIdn1M],ax         ; vstupn° soubor
         mov       ax,ss:[bp-20]            ; vòstupn° soubor
         mov       es:[DBFIdn2M],ax         ; vòstupn° soubor

         mov       ax,es:[DBFZaz1M]         ; velikost z†znamu vstup. bufferu
         mul       word ptr es:[DBFMaxM]    ; velikost vstupn°ho bufferu
         add       ax,di                    ; adresa zaá†tku vòstupn°ho bufferu
         mov       es:[DBFBeg2M],ax         ; adresa vòstupn°ho bufferu
         mov       es:[DBFWritM],ax         ; z†pisov† adresa do vòst. bufferu

; ------ konverze á°sel poloëek na offset

         mov       bx,DBFPopM               ; tabulka popisovaáñ
         mov       dx,es:[DBFNumM]          ; poáet popisovaáñ
         or        dx,dx                    ; je nàjakò popisovaá ?
         jz        ModDIBf6                 ; nen° ë†dnò popisovaá
ModDIBf5:call      ModDIBK1                 ; konverze á°sla poloëky 1 na offset
         inc       bx
         inc       bx                       ; poloëka 2
         call      ModDIBK1                 ; konverze á°sla poloëky 2 na offset
         add       bx,DBFM-2                ; dal®° poloëka
         dec       dx
         jnz       ModDIBf5                 ; dal®° poloëka

ModDIBf6:clc                                ; p©°znak operace OK

ModDIBf9:ret

ModiDIBf ENDP

; ------ konverze á°sla poloëky 1 nebo 2 na offset

ModDIBK1:mov       cx,es:[bx+DBFNumM1]      ; á°slo starÇ poloëky
         inc       cx                       ; je platn† poloëka ?
         jz        ModDIBK4                 ; nen° platn† poloëka
         dec       cx                       ; n†vrat á°sla poloëky

         push      es
         mov       ax,ss:[bp-6]             ; segment starÇ datab†ze
         call      far ptr GetDat           ; adresa starÇ datab†ze -> ES
         mov       ax,1                     ; á°taá offsetu v z†znamu
         mov       si,es:[DBFAdrP]          ; adresa popisovaáñ
         jcxz      ModDIBK3                 ; je prvn° poloëka
ModDIBK2:add       ax,es:[si+DBFDelX]       ; offset dal®° poloëky
         add       si,DBFX                  ; dal®° popisovaá
         loop      ModDIBK2                 ; nalezen° offsetu poloëky
ModDIBK3:mov       cx,es:[si+DBFDelX]       ; dÇlka poloëky
         pop       es

         mov       es:[bx+DBFOfsM1],ax      ; offset poloëky
         mov       es:[bx+DBFDelM1],cx      ; dÇlka poloëky

ModDIBK4:ret

; -----------------------------------------------------------------------------
;        konverze dat souboru (AX=definice segmentu modifikace -> CY chyba)
; -----------------------------------------------------------------------------
;˛
ModDBMod PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ adresa segmentu

         call      far ptr GetDat           ; adresa segmentu modifikace

; ------ test, zda je dal®° poloëka ke konverzi

ModDBMd1:mov       ax,es:[DBFCitZM]         ; á°taá z†znamñ LOW
         or        ax,es:[DBFCitZM+2]       ; je dal®° z†znam ?
         jnz       ModDBMd2                 ; je dal®° z†znam
         jmp       ModDBMd8                 ; nejsou dal®° data

; ------ test, zda je dal®° z†znam v bufferu

ModDBMd2:mov       si,es:[DBFReadM]         ; átec° adresa z bufferu
         add       si,es:[DBFZaz1M]         ; konec z†znamu v bufferu
         cmp       si,es:[DBFEnd1M]         ; je konec dat v bufferu ?
         jbe       ModDBMd3                 ; je p©ipraven dal®° z†znam

; ------ test, zda je p©eru®en° operace

         call      far ptr TestBEsc         ; je p©eru®en° operace ?
         jc        ModDBM24                 ; je p©eru®en° operace

; ------ posun dat v souboru (a souáasnà vymaz†n° mezerami vòstupn°ho bufferu)

         call      ModDBMdW                 ; z†pis dat do vòstupn°ho souboru
         jc        ModDBM24                 ; chyba
         call      ModDBMdR                 ; naáten° dal®°ch dat do bufferu
         jnc       ModDBMd3
ModDBM24:jmp       ModDBMd9                 ; chyba

; ------ p©°prava ukazatelñ ke konverzi z†znamu

ModDBMd3:cld
         push      ds                       ; £schova DS

         push      es
         pop       ds                       ; DS <- ES

         mov       si,ds:[DBFReadM]         ; átec° adresa z bufferu
         mov       di,ds:[DBFWritM]         ; z†pisov† adresa do bufferu
         mov       bx,DBFPopM               ; ukazatel popisovaáñ
         movsb                              ; p©enos p©°znaku zru®en° poloëky
         dec       si                       ; poá†tek vstupn°ho z†znamu

; ------ p©°prava ukazatelñ ke konverzi jednÇ poloëky

ModDBMd4:mov       dl,ds:[bx+DBFDelM]       ; dÇlka novÇ poloëky
         mov       dh,0

         push      di
         push      si                       ; (mus° bòt jako posledn° !)

; ------ adresa zdrojovÇ poloëky

         add       si,ds:[bx+DBFOfsM1]      ; adresa poloëky 1
         jc        ModDBMd6                 ; nen° poloëka 1

; ------ p©enos á°selnÇ poloëky

         mov       ch,0                     ; CH <- 0
         test      byte ptr ds:[bx+DBFTypM],bit1+bit2+bit5 ; je á°seln† poloëka?
         jz        ModDBMd5                 ; nen° to á°seln† poloëka

                                          ;* poëadovan† dÇlka celÇ á†sti -> AX
         mov       ax,dx                    ; AX <- poëadovan† dÇlka celkem
         cmp       byte ptr ds:[bx+DBFDesM],0 ; jsou desetiny ?
         je        ModDBM41                 ; nejsou desetiny
         dec       ax                       ; bez oddàlovac° teáky
         sub       al,ds:[bx+DBFDesM]       ; zbytek na celÇ á°slo

                                          ;* posun celÇ á†sti á°sla -> AX
ModDBM41:mov       cl,ds:[bx+DBFDelM1]      ; dÇlka poloëky 1

         push      dx
         push      si
         mov       dl,cs:[DBFOdDes]         ; oddàlovaá desetin
ModDBM42:cmp       byte ptr ds:[si],"."
         je        ModDBM43
         cmp       byte ptr ds:[si],","
         je        ModDBM43
         cmp       ds:[si],dl
         je        ModDBM43
         inc       si
         dec       ax
         loop      ModDBM42
ModDBM43:pop       si
         pop       dx

         or        ax,ax                    ; prodluëuje se cel† á†st ?
         jns       ModDBM44                 ; cel† á†st se prodluëuje
         neg       ax                       ; zkr†cen° celÇ á†sti á°sla
         jmp       short ModDBM51           ; p©enos poloëky

ModDBM44:add       di,ax                    ; posun ukl†dac° adresy
         sub       dx,ax                    ; zkr†cen° zbytku pro á°slo
         xor       ax,ax                    ; nebude zkr†cen°
         jmp       short ModDBM53           ; p©enos poloëky

; ------ p©enos prvn° poloëky

ModDBMd5:mov       al,ds:[bx+DBFPozM]       ; poá†teán° pozice poloëky 1
         mov       ah,0
ModDBM51:add       si,ax                    ; adresa v poloëce 1
ModDBM53:mov       cl,ds:[bx+DBFDelM1]      ; dÇlka poloëky 1
         sub       cx,ax                    ; zkr†cen° dÇlky zbytku poloëky 1
         jbe       ModDBMd6                 ; poá†tek je za koncem poloëky 1
         cmp       cl,dl                    ; poëadov†no mÇnà znakñ ?
         jb        ModDBM52
         mov       cl,dl                    ; omezen° dÇlky poloëky
ModDBM52:sub       dx,cx                    ; zkr†cen° dÇlky zbytku poloëky
         rep       movsb                    ; p©enos poloëky 1

; ------ p©enos druhÇ poloëky

         pop       si                       ; zaá†tek z†znamu
         push      si
         add       si,ds:[bx+DBFOfsM2]      ; adresa poloëky 2
         jc        ModDBMd6                 ; nen° poloëka 2
         mov       cl,ds:[bx+DBFDelM2]      ; dÇlka poloëky 2
         cmp       cl,dl
         jbe       ModDBM54                 ; dÇlka poloëky je OK
         mov       cl,dl                    ; omezen° dÇlky poloëky
ModDBM54:rep       movsb                    ; p©enos poloëky 2

; ------ korekce pro á°selnou poloëku (desetinn† teáka)

ModDBMd6:pop       si
         pop       di

         test      byte ptr ds:[bx+DBFTypM],bit1+bit2 ; á°seln† poloëka ?
         jz        ModDBM62                 ; nen° á°seln† poloëka
         cmp       byte ptr ds:[bx+DBFDesM],0 ; jsou desetiny ?
         je        ModDBM62                 ; nejsou desetiny

         mov       ah,0
         mov       al,ds:[bx+DBFDelM]       ; dÇlka poloëky
         dec       ax                       ; bez oddàlovac° teáky
         sub       al,ds:[bx+DBFDesM]       ; bez desetinnÇ á†sti

         push      dx
         push      di
         add       di,ax                    ; adresa teáky
         mov       dl,cs:[DBFOdDes]         ; oddàlovaá desetin
         mov       byte ptr ds:[di],dl      ; desetinn† teáka
         pop       di
         pop       dx

; ------ posun k dal®° poloëce

ModDBM62:mov       al,ds:[bx+DBFDelM]       ; dÇlka novÇ poloëky
         mov       ah,0
         add       di,ax                    ; posun ukl†dac° adresy poloëky
         add       bx,DBFM                  ; dal®° popisovaá
         cmp       bx,ds:[DBFBeg1M]         ; je konec popisovaáñ ?
         jae       ModDBMd7                 ; jsou jië v®echny popisovaáe
         jmp       ModDBMd4                 ; dal®° popisovaá

; ------ posun k dal®°mu z†znamu

ModDBMd7:pop       ds                       ; n†vrat DS

         mov       ax,es:[DBFZaz1M]         ; velikost vstupn°ho z†znamu
         add       es:[DBFReadM],ax         ; posun átec° adresy
         mov       ax,es:[DBFZaz2M]         ; velikost vòstupn°ho z†znamu
         add       es:[DBFWritM],ax         ; posun z†pisovÇ adresy
         sub       word ptr es:[DBFCitZM],1 ; posun á°taáe z†znamñ
         sbb       word ptr es:[DBFCitZM+2],0
         jmp       ModDBMd1                 ; dal®° z†znam

; ------ vypr†zdnàn° vòstupn°ho bufferu

ModDBMd8:call      ModDBMdW                 ; uloëen° vòstupn°ho bufferu

; ------ n†vrat registrñ

ModDBMd9:pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

ModDBMod ENDP

; ------ naáten° dal®°ch dat do vstupn°ho bufferu (CY=chyba nebo nejsou data)

ModDBMdR:mov       cx,es:[DBFBeg2M]         ; zaá†tek vòstupn°ho bufferu
         mov       di,es:[DBFBeg1M]         ; zaá†tek vstupn°ho bufferu
         sub       cx,di                    ; velikost vstupn°ho bufferu
         mov       ax,es:[DBFIdn1M]         ; vstupn° soubor
         call      far ptr ReadFile         ; naáten° dat do vstupn°ho souboru
         jc        ModDBMR3                 ; chyba áten° dat
         stc
         jcxz      ModDBMR3                 ; chyba - nejsou dal®° data
         mov       es:[DBFReadM],di         ; átec° adresa z bufferu
         add       di,cx                    ; adresa konce dat v bufferu
         mov       es:[DBFEnd1M],di         ; konec dat v bufferu
         clc                                ; p©°znak operace OK
ModDBMR3:ret

; ------ z†pis bufferu do vòstupn°ho souboru (a vynulov†n° bufferu)

ModDBMdW:mov       si,es:[DBFBeg2M]         ; zaá†tek vòstupn°ho bufferu
         mov       cx,es:[DBFWritM]         ; konec dat v bufferu
         mov       es:[DBFWritM],si         ; nov† ukl†dac° adresa do bufferu
         sub       cx,si                    ; poáet bajtñ v bufferu
         mov       ax,es:[DBFIdn2M]         ; vòstupn° soubor
         call      far ptr WritFile         ; z†pis dat do souboru
         jc        ModDBMW3                 ; chyba z†pisu

         xchg      ax,cx                    ; AX <- poáet uloëenòch bajtñ
         xor       dx,dx                    ; DX <- 0
         div       word ptr es:[DBFZaz2M]   ; poáet uloëenòch z†znamñ
         xchg      ax,cx                    ; CX <- poáet uloëenòch z†znamñ
         call      far ptr InfoKurz         ; zobrazen° kurzoru operace

         push      ax
         mov       di,si                    ; DI <- zaá†tek vòstupn°ho bufferu
         mov       cx,es:[0]                ; velikost dat v segmentu
         sub       cx,di                    ; velikost vòstupn°ho bufferu
         cld
         mov       ax,"  "                  ; mazac° mezery
         shr       cx,1                     ; poáet slov
         rep       stosw                    ; vymaz†n° bufferu mezerami
         adc       cx,cx                    ; lich† mezera
         rep       stosb                    ; uloëen° lichÇ mezery
         pop       ax
                                            ; zde je NC - operace OK
ModDBMW3:ret

; -----------------------------------------------------------------------------
;   inicializace popisovaáñ poloëek datab†ze AX z tabulky modifikace DX (CY chyba)
; -----------------------------------------------------------------------------
;˛
ModiPop  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es

; ------ minimalizace datab†ze

         call      far ptr GetDat           ; adresa datab†ze -> ES
         mov       di,DBFPopis+3            ; inicializaán° velikost
         mov       byte ptr es:[di-3],0dh   ; p©°znak konce z†hlav°
         mov       cx,es:[0]
         sub       cx,di                    ; poáet bajtñ ke zru®en°
         call      far ptr DelDat           ; zru®en° dat z bufferu

; ------ inicializace ukazatelñ

         dec       di                       ; 1 bajt v datovÇm bufferu
         mov       es:[DBFAdrD],di          ; adresa datovÇho bufferu
         mov       word ptr es:[DBFMaxD],1  ; buffer na 1 z†znam
         mov       word ptr es:[DBFSizD],1  ; velikost bufferu v bajtech
         dec       di                       ; 1 bajt v editaán°m bufferu
         mov       es:[DBFAdrE],di          ; adresa editaán°ho bufferu
         mov       es:[DBFAdrP],di          ; adresa indexñ popisovaáñ
         mov       word ptr es:[DBFNumP],0  ; nen° ë†dnò popisovaá
         mov       word ptr es:[DBFBytH],33 ; velikost z†hlav°
         mov       word ptr es:[DBFBytZ],1  ; poáet bajtñ na z†znam
         and       byte ptr es:[DBFParm],not bit4 ; nen° MEMO soubor

; ------ p©°prava k sestaven° tabulky popisovaáñ

         xchg      ax,dx                    ; AX <- modifikace, DX <- datab†ze
         call      far ptr GetDat           ; adresa segmentu modifikace -> ES
         xchg      ax,bp                    ; BP <- modifikace (DX = datab†ze)
         mov       di,DBFPopis              ; adresa k ukl†d†n° poloëek
         mov       si,DBFPopM               ; adresa novòch popisovaáñ
         mov       bx,es:[DBFNumM]          ; poáet poloëek v bufferu modifikace
         or        bx,bx                    ; je nàjak† poloëka ?
         jnz       ModiPop2                 ; je nàjak† poloëka
ModiPop1:jmp       ModiPop9                 ; nen° ë†dn† poloëka

; ------ vytvo©en° m°sta pro popisovaá (adresa DI)

ModiPop2:mov       cx,32                    ; dÇlka popisovaáe
         mov       ax,dx                    ; AX <- segment datab†ze
         call      far ptr InsDat           ; vytvo©en° m°sta pro popisovaá
         jc        ModiPop1                 ; chyba
         call      far ptr GetDat           ; adresa segmentu datab†ze -> ES

; ------ posun ukazatelñ po vloëen° popisovaáe

         add       es:[DBFAdrP],cx          ; posun adresy popisovaáñ
         add       es:[DBFAdrE],cx          ; posun editaán°ho bufferu
         add       es:[DBFAdrD],cx          ; posun datovÇho bufferu
         add       es:[DBFBytH],cx          ; zvò®en° dÇlky z†hlav°

; ------ inicializaán° vynulov†n° poloëky

         push      di
         mov       al,0
         cld
         rep       stosb                    ; vynulov†n° poloëky

; ------ vytvo©en° m°sta pro index

         mov       ax,dx                    ; AX <- segment datab†ze
         mov       di,es:[DBFAdrE]          ; adresa konce indexñ
         mov       cl,DBFX                  ; dÇlka indexu
         call      far ptr InsDat           ; vytvo©en° m°sta pro index
         pop       di
         jc        ModiPop1                 ; chyba

; ------ £schova registrñ

         push      bx
         push      dx
         push      ds

; ------ posun ukazatelñ po vloëen° indexu

         inc       word ptr es:[DBFNumP]    ; zvò®en° á°taáe poátu poloëek
         mov       bx,es:[DBFAdrE]          ; adresa aktu†ln°ho indexu
         add       es:[DBFAdrE],cx          ; posun editaán°ho bufferu
         add       es:[DBFAdrD],cx          ; posun datovÇho bufferu

; ------ adresa segmentu modifikace

         mov       ax,bp                    ; AX <- segment modifikace
         call      far ptr GetSgAdr         ; adresa segmentu modifikace
         mov       ds,dx                    ; DS <- segment modifikace

; ------ p©enos jmÇna poloëky

         cld
         mov       es:[bx+DBFNamX],di       ; adresa jmÇna poloëky
         mov       byte ptr es:[bx+DBFNumX],0 ; dÇlka jmÇna popisovaáe
         mov       cl,10                    ; dÇlka jmÇna
         push      si
         push      di
         add       si,DBFNamM               ; jmÇno poloëky
ModiPop3:lodsb
         cmp       al," "
         je        ModiPop4                 ; konec jmÇna
         stosb
         inc       byte ptr es:[bx+DBFNumX] ; zvò®en° á°taáe dÇlky jmÇna
         loop      ModiPop3                 ; p©enesen° jmÇna
ModiPop4:pop       di
         pop       si

; ------ korekce pro MEMO poloëku

         mov       al,ds:[si+DBFTypMC]      ; znak pro jinò typ poloëky
         mov       cs:[ModDBSTb+7],al       ; znak pro jinò typ poloëky

         mov       al,ds:[si+DBFTypM]       ; typ poloëky
         mov       es:[bx+DBFParX],al       ; typ poloëky

         cmp       al,bit5                  ; je MEMO poloëka ?
         jne       ModiPop5                 ; nen° MEMO poloëka
         or        byte ptr es:[DBFParm],bit4 ; p©°znak MEMO souboru

; ------ typ poloëky

ModiPop5:push      bx
         mov       bx,offset ModDBSTb-1
ModiPop6:inc       bx
         shr       al,1
         jnc       ModiPop6
         mov       al,cs:[bx]               ; oznaáen° typu poloëky
         pop       bx
         mov       es:[di+11],al            ; typ poloëky

; ------ dÇlka poloëky a poáet desetinnòch m°st

         mov       ax,ds:[si+DBFDelM]       ; dÇlka poloëky a desetiny
         mov       es:[di+16],ax            ; dÇlka pole a desetiny

; ------ zvò®en° dÇlky z†znamu

         mov       ah,0
         mov       es:[bx+DBFDelX],ax       ; dÇlka poloëky (bajtñ)
         add       es:[DBFBytZ],ax          ; zvò®en° dÇlky z†znamu
         add       es:[DBFAdrD],ax          ; posun adresy datovÇho bufferu
         add       es:[DBFSizD],ax          ; zvò®en° velikosti bufferu

; ------ ®°©ka zobrazen° pole

         mov       al,ds:[si+DBFSirXM]      ; zobrazen† ®°©ka pole
         mov       ah,0
         mov       es:[bx+DBFSirX],ax       ; zobrazen† ®°©ka pole poloëky
         mov       ah,al
         add       ah,DBFPSirC              ; + kontroln° znak
         mov       es:[di+DBFPSirk],ax      ; zobrazen† ®°©ka pole

         pop       ds
         pop       dx
         pop       bx

; ------ dal®° poloëka

         add       si,DBFM                  ; dal®° poloëka
         add       di,32                    ; dal®° popisovaá datab†ze
         dec       bx                       ; á°taá poloëek
         jz        ModiPop7                 ; jsou jië v®echny poloëky
         jmp       ModiPop2                 ; dal®° poloëka

; ------ vytvo©en° m°sta pro editaán° a datovò buffer (kaëdò m† teÉ 1 znak)

ModiPop7:mov       di,es:[DBFAdrE]          ; adresa editaán°ho bufferu
         mov       cx,es:[DBFBytZ]          ; poáet bajtñ na z†znam
         dec       cx                       ; bez prvn°ho bajtu (ten jië je)
         shl       cx,1                     ; poáet bajtñ na oba buffery
         mov       ax,dx                    ; AX <- segment datab†ze
         call      far ptr InsDat           ; vytvo©en° m°sta pro buffery

; ------ n†vrat registrñ

ModiPop9:pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

ModiPop  ENDP

; -----------------------------------------------------------------------------
;        korekce zobrazen° datab†ze DS:SI
; -----------------------------------------------------------------------------

ModiDKor PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      es

; ------ adresa okna

         call      DBFAdrES                 ; aktualizace adresy okna -> ES

; ------ p©°prava k stanoven° parametrñ zobrazen°

         xor       ax,ax
         mov       cx,es:[DBFNumP]          ; poáet popisovaáñ
         mov       bx,es:[DBFAdrP]          ; adresa popisovaáñ
         mov       es:[DBFNumL],ax          ; poáet ©†dkñ str†nkovÇho reëimu
         mov       es:[DBFSirR],ax          ; ®°©ka ©†dku (pozic) = 0
         mov       dl,ds:[si+MnuSir]        ; ®°©ka okna
         sub       dl,15                    ; zbytek na poloëku
         jcxz      ModiDKr9                 ; nen° ë†dn† poloëka
         dec       cx
         mov       es:[DBFSirR],cx          ; inicializaán° ®°©ka (oddàlovaáe)
         inc       cx                       ; poáet poloëek

; ------ zvò®en° á°taáe ®°©ky ©†dku

ModiDKr2:mov       al,es:[bx+DBFSirX]       ; zobrazen† ®°©ka poloëky
         add       es:[DBFSirR],ax          ; zvò®en° á°taáe ®°©ky ©†dku

; ------ zvò®en° á°taáe ©†dkñ str†nkovÇho reëimu

         mov       al,es:[bx+DBFDelX]       ; dÇlka poloëky (bajtñ)
ModiDKr4:inc       word ptr es:[DBFNumL]    ; zvò®en° poátu ©†dkñ str†nk. reëimu
         sub       al,dl                    ; odeáten° ®°©ky jednoho ©†dku
         ja        ModiDKr4                 ; je dal®° ©†dek

; ------ dal®° poloëka

         add       bx,DBFX                  ; adresa dal®° poloëky
         loop      ModiDKr2                 ; dal®° poloëka

; ------- n†vrat registrñ

ModiDKr9:pop       es
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

ModiDKor ENDP

; -----------------------------------------------------------------------------
;      editace okna datab†ze
; -----------------------------------------------------------------------------
; VSTUP: AX=aktivn° poloëka
;        BX=kl†vesa
;        CX=vnit©n° vò®ka okna - 1
;        DX=poáet poloëek celkem
;        DS:SI=adresa definice okna
;        ES:DI=aktivn° poloëka (DI=0 poloëka neplatn†)
;        ES=segment okna
; -----------------------------------------------------------------------------
;˛
EditBMd: call      far ptr JumpBX

         dw        4b00h,EdiDBLft           ; vlevo
         dw        4d00h,EdiDBRgh           ; vpravo
         dw        4800h,EdiDBMdU           ; nahoru
         dw        5000h,EdiDBMdD           ; dolñ
         dw        7300h,EdiDBSTb           ; Ctrl-vlevo
         dw        7400h,EdiDBTab           ; Ctrl-vpravo

         dw        4700h,EdiDBHom           ; Home
         dw        4f00h,EdiDBEdd           ; End
         dw        7700h,EdiDBCHm           ; Ctrl-Home
         dw        7500h,EdiDBCEn           ; Ctrl-End

         dw        4900h,EdiDBPgU           ; PageUp
         dw        5100h,EdiDBPgD           ; PageDown
         dw        8400h,EdiDBCHm           ; Ctrl-PageUp
         dw        7600h,EdiDBCEn           ; Ctrl-PageDown

         dw        1c0dh,EdiDBEnt           ; Enter
         dw        0f09h,EdiDBTab           ; Tab
         dw        0f00h,EdiDBSTb           ; Shift-Tab

         dw        5200h,EdiDBIns           ; Insert

         dw        5300h,EdiDBDel           ; Delete
         dw        0e08h,EdiDBBs            ; BS

         dw        3c00h,EdiDBMU            ; F2 nahoru
         dw        3d00h,EdiDBMD            ; F3 dolñ
         dw        3f00h,EdiDBMK            ; F5 kopie
         dw        4000h,EdiDBMP            ; F6 p©ipoj
         dw        4200h,EdiDBMZ            ; F8 zru®en°

         dw        MousXKod+MousXLP,EdiDBEnt ; stisk levÇho tlaá°tka my®i

         dw        0,EdiDBMCh

EdiDBMd0:ret

; ------ vloëen° znaku do pole
                                          ;* mezera je jako ENTER
EdiDBMCh:cmp       bh,MousXKod/HI           ; je k¢d pro my® ?
         je        EdiDBMd0                 ; k¢d pro my® zak†z†n
         cmp       bl," "
         jne       EdiDBMC0                 ; nen° mezera

         mov       bl,"_"                   ; n†hradn° znak, je-li aktivn° jmÇno
         test      byte ptr es:[DBFPrmM],bit2 ; je aktivn° jmÇno ?
         jnz       EdiDBMC1                 ; pro jmÇno n†hrada znakem "_"
         jmp       EdiDBEnt                 ; jako ENTER
                                          ;* teáka je jako TAB
EdiDBMC0:cmp       bl,ds:[OddelDes]         ; je oddàlovaá desetin ?
         je        EdDBMC02                 ; je oddàlovaá desetin
         cmp       bl,"."                   ; teáka ?
         jne       EdiDBMC1
EdDBMC02:jmp       EdiDBTab                 ; posun na dal®° pole
                                          ;* konverze znaku na velkÇ p°smeno
EdiDBMC1:xchg      ax,bx
         call      far ptr UpCase           ; konverze na velkÇ p°smeno
         xchg      ax,bx
                                          ;* kontrola platnosti znaku
         cmp       bl,"0"
         jb        EdiDBMd0                 ; neplatnò znak
         cmp       bl,"9"
         jbe       EdiDBMC2                 ; platnò znak - á°slice

         test      byte ptr es:[DBFPrmM],bit4+bit5+bit6 ; aktivn° á°slo ?
         jnz       EdiDBMd0                 ; je á°selnÇ pole - neplatnò znak

         cmp       bl,"_"
         je        EdiDBMC2                 ; je platnò znak

         cmp       bl,128                   ; je znak s diakritikou ?
         jae       EdiDBMC2                 ; je znak s diakritikou
         cmp       bl,"Z"
         ja        EdiDBMd0                 ; neplatnò znak
         cmp       bl,"A"
         jb        EdiDBMd0                 ; neplatnò znak

; ------ obsluha pole typu poloëky

EdiDBMC2:test      byte ptr es:[DBFPrmM],bit3 ; je typ poloëky ?
         jz        EdiDBMC3                 ; nen° typ poloëky
                                          ;* znakov† poloëka
         mov       bh,bit0                  ; znakov† poloëka
         cmp       bl,"Z"
         je        EdDBMC22                 ; znakov† poloëka
         cmp       bl,"C"
         je        EdDBMC22                 ; znakov† "C"
                                          ;* á°seln† poloëka Numeric
         mov       bh,bit1                  ; á°seln† NUMERIC
         cmp       bl,"N"
         je        EdDBMC22                 ; á°seln† NUMERIC
                                          ;* á°seln† poloëka Float
         mov       bh,bit2                  ; á°seln† FLOAT
         cmp       bl,"F"
         je        EdDBMC22                 ; á°seln† FLOAT
                                          ;* datum
         mov       bh,bit3                  ; datum
         cmp       bl,"D"
         je        EdDBMC22                 ; datum
                                          ;* logick† poloëka
         mov       bh,bit4                  ; logick†
         cmp       bl,"L"
         je        EdDBMC22                 ; logick†
                                          ;* textovÇ (Memo) pole
         mov       bh,bit5                  ; MEMO
         cmp       bl,"T"
         je        EdDBMC22                 ; textovÇ pole
         cmp       bl,"M"
         je        EdDBMC22                 ; MEMO pole
                                          ;* áas
         mov       bh,bit6
         cmp       bl,"H"
         je        EdDBMC22
EdDBMC21:ret

EdDBMC22:call      EdiDBBlk                 ; nastaven° blokov†n° voleb
         test      bh,ds:[DBTMVBl0]         ; povoleno ?
         jnz       EdDBMC21                 ; nen° povoleno
         mov       es:[di+DBFTypM],bh       ; novò typ poloëky
         jmp       EdiDBTab                 ; dal®° poloëka

; ------ jmÇno poloëky - vytvo©en° novÇho z†znamu

EdiDBMC3:test      byte ptr es:[DBFPrmM],bit2 ; je jmÇno poloëky ?
         jnz       EdDBMC3Z                 ; je jmÇno poloëky
         jmp       EdiDBMC4                 ; nen° jmÇno poloëky
                                          ;* na prvn° pozici jen p°smeno
EdDBMC3Z:cmp       byte ptr es:[DBFKurM],0  ; je kurzor na prvn° pozici ?
         jne       EdDBMC3A                 ; nen° na prvn° pozici
         cmp       bl,128
         jae       EdDBMC3A                 ; je znak s diakritikou
         cmp       bl,"A"
         jb        EdDBMC33                 ; na 1. pozici povoleno jen p°smeno
         cmp       bl,"Z"
         ja        EdDBMC33                 ; nen° p°smeno

EdDBMC3A:push      ax
         push      di                       ; (mus° bòt jako posledn° !)

         or        di,di                    ; je to platn† poloëka ?
         jnz       EdDBMC32                 ; je to platn† poloëka

         mov       ax,ds:[si+DBMMnSeg]      ; segment okna
         mov       di,es:[DBFBytM]          ; poáet bajtñ v bufferu
         mov       cx,DBFM                  ; dÇlka poloëky
         call      far ptr InsDat           ; vytvo©en° m°sta pro poloëku
         jc        EdDBMC32                 ; chyba pamàti

         pop       ax                       ; zru®en° p©°znaku neplatnÇ poloëky
         push      di                       ; adresa novÇ vytvo©enÇ poloëky

         inc       word ptr es:[DBFNumM]    ; zvò®en° poátu poloëek
         mov       ax,es:[DBFAktM]          ; á°slo aktivn° poloëky
         cld
         stosw                              ; á°slo aktivn° poloëky (novò soub.)
         mov       ax,-1
         test      byte ptr ds:[DBFEParm],bit6 ; je novò soubor ?
         jnz       EdDBMC30                 ; je to novò soubor
         mov       word ptr es:[di-2],ax    ; jinak nen° star† poloëka
EdDBMC30:stosw                              ; p©ipojen† poloëka neplat°
         mov       al," "
         mov       cl,10                    ; dÇlka jmÇna poloëky
         rep       stosb                    ; vymaz†n° jmÇna poloëky
         mov       ax,10*HI + bit0          ; textov† poloëka, dÇlka 10
         stosw                              ; textov† poloëka, dÇlka 10
         xor       ax,ax
         stosw                              ; poáet des. m°st, poá†teán° pozice
         mov       ax,10
         stosw                              ; zobrazen† ®°©ka poloëky,
                                            ;  nen° pñvodn° typ poloëky

EdDBMC31:clc                                ; p©°znak operace OK

EdDBMC32:pop       di
         pop       ax
         jnc       EdDBMC34                 ; operace je OK
EdDBMC33:ret                                ; n†vrat p©i chybà

; ------ jmÇno poloëky - vloëen° znaku do bufferu

EdDBMC34:push      di
         add       di,DBFNamM               ; zaá†tek jmÇna
         add       di,es:[DBFKurM]          ; pozice kurzoru
         mov       cx,10                    ; poáet znakñ k odsunu
         sub       cx,es:[DBFKurM]          ; poáet zbylòch znakñ
         call      EditBIII                 ; odsun CX znakñ od kurzoru
         mov       es:[di],bl               ; uloëen° znaku do bufferu
         pop       di

         or        byte ptr es:[DBFPrmM],bit1 ; zah†jena editace

         inc       byte ptr es:[DBFKurM]    ; zvò®en° pozice kurzoru
         cmp       byte ptr es:[DBFKurM],10 ; je jië konec ?
         jb        EdDBMC33                 ; nen° je®tà konec
         jmp       EdiDBTab                 ; posun na dal®° poloëku

; ------ editace á°selnÇ poloëky

EdiDBMC4:sub       bl,"0"                   ; korekce znaku na á°slici
         mov       cl,bl                    ; CL <- vkl†dan† á°slice

         mov       bx,DBFDelM               ; dÇlka
         mov       ch,255                   ; omezen° znakovÇ poloëky
         test      byte ptr es:[di+DBFTypM],bit1+bit2 ; á°seln† poloëka ?
         jz        EdDBMC41                 ; nen° to á°seln† poloëka
         mov       ch,20                    ; omezen° á°selnÇ poloëky
EdDBMC41:test      byte ptr es:[DBFPrmM],bit4 ; dÇlka ?
         jnz       EdDBMC44                 ; je dÇlka

         inc       bx                       ; desetiny
         test      byte ptr es:[di+DBFTypM],bit7 ; je jinò typ poloëky ?
         jnz       EdDBMC42                 ; nen° omezen°
         mov       ch,es:[di+DBFDelM]       ; dÇlka poloëky
         sub       ch,2                     ; maximum na desetiny
         jnc       EdDBMC42                 ; nen° podteáen°
         mov       ch,0
EdDBMC42:test      byte ptr es:[DBFPrmM],bit5 ; desetiny ?
         jnz       EdDBMC44                 ; desetiny

         inc       bx                       ; poá†teán° pozice
         mov       ch,255                   ; omezen° poá†tku

EdDBMC44:xor       ax,ax                    ; AX <- 0 vòchoz° hodnota á°sla
         test      byte ptr es:[DBFPrmM],bit1 ; je editace ?
         jz        EdDBMC45                 ; nen° editace - nulov†n°
;         cmp       ch,es:[di+bx]            ; bylo by jië p©eteáen° ?
;         jbe       EdDBMC45                 ; bylo by jië p©eteáen°
         mov       al,10
         mul       byte ptr es:[di+bx]      ; posun á°slice o ©†d
EdDBMC45:or        ah,ah                    ; p©eteáen° ?
         jnz       EdDBMC46                 ; je p©eteáen°
         add       al,cl                    ; p©iáten° starÇ hodnoty
         jnc       EdDBMC47
EdDBMC46:mov       al,255                   ; omezen° á°sla
EdDBMC47:cmp       al,ch                    ; je vàt®° neë maximum ?
         jbe       EdDBMC48                 ; á°slo je OK
         mov       al,ch                    ; omezen° á°sla
EdDBMC48:mov       es:[di+bx],al            ; uloëen° á°sla
         or        byte ptr es:[DBFPrmM],bit1 ; zah†jena editace
         ret

; ------ Delete

EdiDBDel:or        di,di                    ; je platn† poloëka ?
         jz        EdiDBDl8                 ; nen° platn† poloëka
         test      byte ptr es:[DBFPrmM],bit3 ; je aktivn° typ ?
         jnz       EdiDBDl8                 ; je typ poloëky - nic se nedàje
         or        byte ptr es:[DBFPrmM],bit1 ; zah†jen° editace
         test      byte ptr es:[DBFPrmM],bit4+bit5+bit6 ; je á°selnÇ pole ?
         jnz       EdiDBBS3                 ; je á°selnÇ pole
EdiDBDl2:mov       bl,es:[DBFKurM]          ; pozice kurzoru v poloëce
         mov       bh,0
         add       bx,DBFNamM               ; korekce na zaá†tek jmÇna
         cmp       byte ptr es:[di+bx]," "  ; je platnò znak ?
         je        EdiDBDl8                 ; nen° platnò znak

         push      di
         add       di,bx                    ; pozice kurzoru
         mov       cx,10+DBFNamM            ; poáet znakñ k p©°sunu + korekce
         sub       cx,bx                    ; poáet zbylòch znakñ
         call      EditBDlC                 ; p©°sun CX znakñ za kurzorem
         pop       di

EdiDBDl8:ret

; ------ BS

EdiDBBS: or        di,di                    ; je platn† poloëka ?
         jz        EdiDBBS8                 ; nen° platn† poloëka
         test      byte ptr es:[DBFPrmM],bit3 ; aktivn° typ ?
         jnz       EdiDBBS8                 ; je typ poloëky - nic se nedàje
         or        byte ptr es:[DBFPrmM],bit1 ; zah†jen° editace
         test      byte ptr es:[DBFPrmM],bit4+bit5+bit6 ; je á°selnÇ pole ?
         jnz       EdiDBBS3                 ; je á°selnÇ pole
         cmp       byte ptr es:[DBFKurM],0  ; je jië poá†tek poloëky ?
         je        EdiDBBS8                 ; je jië poá†tek poloëky - nic
         dec       byte ptr es:[DBFKurM]    ; sn°ëen° pozice kurzoru
         jmp       short EdiDBDl2           ; zru®en° znaku za kurzorem

EdiDBBS3:mov       bx,DBFDelM               ; dÇlka poloëky
         test      byte ptr es:[DBFPrmM],bit4 ; je dÇlka poloëky ?
         jnz       EdiDBBS4                 ; je dÇlka poloëky
         inc       bx                       ; desetinn† m°sta
         test      byte ptr es:[DBFPrmM],bit5 ; jsou desetiny ?
         jnz       EdiDBBS4                 ; jsou desetiny
         inc       bx                       ; poá†tek poloëky
EdiDBBS4:mov       al,es:[di+bx]            ; star† hodnota poloëky
         mov       ah,0
         mov       cl,10                    ; dàlitel
         div       cl                       ; vydàlen° á°sla / 10
         mov       es:[di+bx],al            ; nov† hodnota á°sla
EdiDBBS8:ret

; ------ vlevo

EdiDBLft:test      byte ptr es:[DBFPrmM],bit2 ; aktivn° jmÇno ?
         jz        EdiDBLf1                 ; nen° aktivn° jmÇno

         dec       byte ptr es:[DBFKurM]    ; sn°ëen° offsetu v poloëce
         jns       EdiDBLf6                 ; nen° p©eteáen° p©es poá†tek

EdiDBLf1:call      EdiDBSTb                 ; posun na p©ede®lou poloëku
         call      KorBMMn                  ; korekce menu
         test      byte ptr es:[DBFPrmM],bit2 ; je aktivn° jmÇno ?
         jz        EdiDBLf6                 ; nen° aktivn° jmÇno
         cmp       word ptr es:[DBFAktM],0  ; je to prvn° ©†dek ?
         je        EdiDBLf6                 ; je to prvn° ©†dek
         or        di,di                    ; je to platn† poloëka ?
         jz        EdiDBLf6                 ; nen° platn† poloëka

         push      di
         mov       cx,9                     ; max. znakñ k posunu
EdiDBLf2:cmp       byte ptr es:[di+DBFNamM]," " ; nalezen konec poloëky ?
         je        EdiDBLf3                 ; nalezen konec poloëky
         inc       byte ptr es:[DBFKurM]    ; posun kurzoru
         inc       di                       ; zvò®en° ukazatele v poloëce
         loop      EdiDBLf2
EdiDBLf3:pop       di

EdiDBLf6:ret

; ------ vpravo

EdiDBRgh:test      byte ptr es:[DBFPrmM],bit2 ; je aktivn° jmÇno ?
         jz        EdiDBRg6                 ; nen° aktivn° jmÇno
         or        di,di                    ; je platn† poloëka ?
         jz        EdiDBRg6                 ; nen° platn† poloëka

         mov       bx,es:[DBFKurM]          ; pozice kurzoru v poloëce
         cmp       bl,9                     ; je konec poloëky ?
         jae       EdiDBRg6                 ; je konec poloëky
         cmp       byte ptr es:[di+bx+DBFNamM]," " ; je konec poloëky ?
         je        EdiDBRg6                 ; je konec poloëky
         inc       byte ptr es:[DBFKurM]    ; zvò®en° pozice kurzoru v poloëce
         ret

EdiDBRg6:jmp       EdiDBTab                 ; dal®° poloëka

; ------ zaá†tek poloëky Home

EdiDBHom:test      byte ptr es:[DBFPrmM],bit2 ; je aktivn° jmÇno ?
         jz        EdiDBHm2                 ; nen° aktivn° jmÇno
         cmp       byte ptr es:[DBFKurM],0  ; je poá†tek jmÇna ?
         je        EdiDBHm2                 ; je poá†tek jmÇna
         mov       byte ptr es:[DBFKurM],0  ; kurzor na poá†tek poloëky
         ret

EdiDBHm2:jmp       EdiDBSTb                 ; p©edchoz° pole

; ------ konec poloëky End

EdiDBEdd:test      byte ptr es:[DBFPrmM],bit2 ; je aktivn° jmÇno ?
         jz        EdiDBEd4                 ; nen° aktivn° jmÇno
         or        di,di                    ; je platn† poloëka ?
         jz        EdiDBEd4                 ; nen° platn† poloëka

         mov       bx,es:[DBFKurM]          ; offset kurzoru v poloëce
         cmp       byte ptr es:[di+bx+DBFNamM]," " ; je konec jmÇna ?
         je        EdiDBEd4                 ; je konec jmÇna
EdiDBEd1:inc       byte ptr es:[DBFKurM]    ; zvò®en° pozice kurzoru
         inc       bx                       ; zvò®en° pozice kurzoru
         cmp       bl,10                    ; p©eteáen° konce jmÇna ?
         je        EdiDBEd4                 ; p©eteáen° konce jmÇna
         cmp       byte ptr es:[di+bx+DBFNamM]," " ; nalezen konec jmÇna ?
         jne       EdiDBEd1                 ; nalezen° konce jmÇna poloëky
         ret

EdiDBEd4:jmp       EdiDBTab                 ; dal®° pole

; ------ poloëka dolñ

EdiDBMdD:call      EdiDBEnd                 ; ukonáen° editace poloëky
         inc       ax                       ; zvò®en° aktivn° poloëky
EdiDBMD2:mov       es:[DBFAktM],ax          ; nov† aktivn° poloëka
EdiDBMD3:ret

; ------ poloëka nahoru

EdiDBMdU:call      EdiDBEnd                 ; ukonáen° editace poloëky
         or        ax,ax                    ; je prvn° poloëka ?
         jz        EdiDBMD3                 ; je jië prvn° poloëka
         dec       ax                       ; sn°ëen° aktivn° poloëky
         jmp       short EdiDBMD2

; ------ prvn° poloëka

EdiDBCHm:call      EdiDBEnd                 ; ukonáen° editace poloëky
         xor       ax,ax                    ; AX <- poloëka 0
         jmp       short EdiDBMD2

; ------ posledn° poloëka

EdiDBCEn:call      EdiDBEnd                 ; ukonáen° editace poloëky
         mov       ax,dx                    ; AX <- posledn° poloëka
         jmp       short EdiDBMD2

; ------ str†nka nahoru

EdiDBPgU:call      EdiDBEnd                 ; ukonáen° editace poloëky
         cmp       ax,dx                    ; je kurzor na konci ?
         jne       EdDBPgU1                 ; kurzor nen° na konci
         or        ax,ax                    ; je nàjak† poloëka ?
         jz        EdDBPgU1                 ; nen° ë†dn† poloëka
         dec       ax                       ; korekce kurzoru
EdDBPgU1:cmp       word ptr es:[DBFTopM],0  ; je prvn° poloëka ?
         je        EdiDBCHm                 ; je prvn° poloëka - bude HOME
         cmp       cx,es:[DBFTopM]          ; zbòv† je®tà dost poloëek ?
         jbe       EdDBPgU2                 ; zbòv† je®tà dost poloëek
         mov       cx,es:[DBFTopM]          ; omezen° posunu
EdDBPgU2:sub       word ptr es:[DBFTopM],cx ; posun poá†tku
         sub       ax,cx                    ; posun kurzoru
         jmp       short EdiDBMD2           ; nastaven° kurzoru

; ------ str†nka dolñ

EdiDBPgD:call      EdiDBEnd                 ; ukonáen° editace poloëky
         or        ax,ax                    ; je kurzor na poá†tku okna ?
         jnz       EdDBPgD1                 ; nen° na poá†tku okna
         inc       ax                       ; posun kurzoru
EdDBPgD1:mov       bx,dx                    ; poáet poloëek
         sub       bx,cx                    ; maxim†ln° poá†tek
         jnc       EdDBPgD2                 ; je to OK
         xor       bx,bx                    ; omezen° p©i p©eteáen°
EdDBPgD2:cmp       bx,es:[DBFTopM]          ; je jië konec ?
         jbe       EdiDBCEn                 ; posun na konec
         sub       bx,es:[DBFTopM]          ; offset od konce
         cmp       cx,bx                    ; zbòv† dost poloëek ?
         jbe       EdDBPgD3                 ; zbòv† dost poloëek
         mov       cx,bx                    ; omezen° posunu
EdDBPgD3:neg       cx                       ; zmàna smàru posunu
         jmp       short EdDBPgU2           ; posun ukazatelñ

; ------ Enter (mus° n†sledovat obsluha TAB !!!)

EdiDBEnt:call      EdiDBEnd                 ; ukonáen° editace poloëky
         test      byte ptr es:[DBFPrmM],bit3 ; je aktivn° typ ?
         jz        EdiDBTab                 ; nen° aktivn° typ

         push      si
         call      EdiDBBlk                 ; nastaven° blokov†n° voleb
         mov       si,offset DBTMVert
         mov       dl,es:[di+DBFTypM]       ; typ poloëky
         call      far ptr SetSwch          ; nastaven° p©ep°naáñ
         test      dl,bit0+bit1+bit2+bit3+bit4+bit5+bit6
         jnz       EdiDBEn0
         inc       dx                       ; bude aktivn° znakov† poloëka
EdiDBEn0:mov       cl,dl                    ; CL <- typ poloëky
         xor       ax,ax
EdiDBEn1:inc       ax                       ; á°taá aktivn° poloëky
         shr       cl,1
         jnc       EdiDBEn1
         mov       byte ptr ds:[si+MnuAkt],al ; aktivn° poloëka
         call      far ptr CentMenu         ; vyst©edàn° okna menu
         call      far ptr VertMenu         ; obsluha menu
         pop       si
         ret

EdiDBEn2 PROC      FAR                      ; mus° n†sledovat obsluha TAB !!!

         mov       cl,byte ptr ds:[si+MnuAkt] ; aktivn° zvolen† poloëka
         dec       cx                       ; korekce
         mov       dl,bit0                  ; bit k rotaci
         shl       dl,cl                    ; zvolen† poloëka
         mov       es:[di+DBFTypM],dl       ; novò typ poloëky
         call      far ptr SetSwch          ; nastaven° p©ep°naáñ
         cmp       bl," "                   ; je p©ep°naá ?
         jne       EdiDBEn3                 ; nen° p©ep°naá
         call      far ptr DispAll          ; novÇ zobrazen° v®eho
         ret

EdiDBEn3:add       sp,4                     ; zru®en° n†vratovÇ adresy
         call      far ptr ClosMnu          ; uzav©en° okna
         pop       si                       ; n†vrat adresy okna
         mov       ax,es:[DBFAktM]          ; aktivn° poloëka

EdiDBEn2 ENDP

; ------ Tab (n†sleduje za ENTER !!!!)

EdiDBTab:call      EdiDBEnd                 ; ukonáen° editace poloëky
         or        di,di                    ; je platn† poloëka ?
         jz        EdiDBTb9                 ; nen° platn† poloëka

         mov       bl,es:[DBFPrmM]          ; parametry poloëky
         and       byte ptr es:[DBFPrmM],not bit2+bit3+bit4+bit5+bit6
         and       bl,bit2+bit3+bit4+bit5+bit6 ; aktivn° prvek
EdiDBTb1:shl       bl,1                     ; posun aktivn°ho prvku
         test      bl,bit7                  ; p©eteáen° ?
         jnz       EdiDBTb2                 ; p©eteáen°

         test      bl,bit6                  ; aktivn° poá†tek ?
         jz        EdiDBTb3                 ; nen° aktivn° poá†tek
         test      byte ptr es:[di+DBFTypM],bit0+bit7 ; je to textov† poloëka ?
         jz        EdiDBTb2                 ; nen° textov† poloëka - nen° poá†tek
         test      byte ptr ds:[DBFEParm],bit6 ; je novÇ z†hlav° ?
         jz        EdiDBTb8                 ; nen° novÇ z†hlav° - pole plat°
EdiDBTb2:or        byte ptr es:[DBFPrmM],bit2 ; aktivn° jmÇno
         jmp       EdiDBMdD                 ; kurzor dolñ

EdiDBTb3:test      bl,bit5                  ; aktivn° desetiny ?
         jz        EdiDBTb4                 ; nejsou aktivn° desetiny
         test      byte ptr es:[di+DBFTypM],bit1+bit2+bit7 ; je á°slo ?
         jnz       EdiDBTb8                 ; je to á°slo - poloëka plat°
         jmp       short EdiDBTb1           ; dal®° posun

EdiDBTb4:test      bl,bit4                  ; aktivn° dÇlka ?
         jz        EdiDBTb8                 ; nen° aktivn° dÇlka
         test      byte ptr es:[di+DBFTypM],bit3+bit4+bit5+bit6 ; povoleno ?
         jnz       EdiDBTb1                 ; zak†zanÇ pole

EdiDBTb8:or        byte ptr es:[DBFPrmM],bl ; novò aktivn° prvek
EdiDBTb9:ret

; ------ Shift-Tab (vyuë°v† se sr†ëen° kurzoru zpàt p©i korekci zobrazen° !)

EdiDBSTb:call      EdiDBEnd                 ; ukonáen° editace poloëky
         mov       bl,es:[DBFPrmM]          ; parametry poloëky
         and       byte ptr es:[DBFPrmM],not bit2+bit3+bit4+bit5+bit6
         and       bl,bit2+bit3+bit4+bit5+bit6 ; aktivn° prvek

         shr       bl,1                     ; posun aktivn° poloëky
         test      bl,bit1                  ; je p©eteáen° ?
         jz        EdiDBTb8                 ; nen° p©eteáen°
         mov       bl,bit2                  ; aktivn° jmÇno
         or        ax,ax                    ; je prvn° poloëka ?
         jz        EdiDBTb8                 ; je prvn° poloëka
         or        byte ptr es:[DBFPrmM],bit6 ; posledn° prvek
         jmp       EdiDBMdU                 ; kurzor nahoru

; ------ Insert

EdiDBIns:xor       byte ptr ds:[DBFEParm],bit2 ; zmàna p©°znaku INSERT
         ret

; -----------------------------------------------------------------------------
;        nastaven° blokov†n° voleb typu poloëky ES:DI
; -----------------------------------------------------------------------------

EdiDBBlk PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      si

; ------ spojen† poloëka - povolena pouze textov† poloëka

         mov       ah,not bit0              ; povolena pouze textov† poloëka
         cmp       word ptr es:[di+DBFNumM2],-1 ; je to spojen† poloëka ?
         jne       EdiDBBl6                 ; je to spojen† poloëka

; ------ p©evod na textovou poloëku nebo na stejnou

         mov       al,es:[di+DBFTypMO]      ; pñvodn° typ poloëky
         xor       ah,al                    ; vynulov†n° bitu stejnÇho typu
         test      al,bit3+bit4+bit6+bit7   ; datum/logick†/áas/jinò typ
         jnz       EdiDBBl6                 ; p©evod na text nebo beze zmàny

; ------ pro á°slo a MEMO povolen p©evod na textovou poloëku, á°slo nebo MEMO

         mov       ah,not bit0+bit1+bit2+bit5 ; text, á°slo nebo MEMO
         test      al,bit1+bit2+bit5        ; je á°slo nebo MEMO ?
         jnz       EdiDBBl6                 ; je á°slo nebo MEMO

; ------ jinak pro textovou poloëku p©evod na cokoliv

         mov       ah,0                     ; p©evod na cokoliv

; ------ nastaven° p©ep°naáñ

EdiDBBl6:mov       ds:[DBTMVBl0],ah         ; £schova p©ep°naáñ

         mov       si,offset DBTMVBlk       ; blokovac° tabulka
         mov       cx,7                     ; poáet poloëek
EdiDBBl7:and       byte ptr ds:[si],not bit1 ; povoleno
         shr       ah,1                     ; je zak†z†no ?
         jnc       EdiDBBl8                 ; nen° zak†z†no
         or        byte ptr ds:[si],bit1    ; z†kaz poloëky
EdiDBBl8:inc       si
         loop      EdiDBBl7

; ------ n†vrat registrñ

         pop       si
         pop       cx
         pop       ax
         ret

EdiDBBlk ENDP

; -----------------------------------------------------------------------------
;        ukonáen° editace poloëky ES:DI (posune kurzor na poá†tek poloëky)
; -----------------------------------------------------------------------------

EdiDBEnd PROC      NEAR

         mov       word ptr es:[DBFKurM],0  ; posun kurzoru v poloëce

; ------ test, zda je editace poloëky ES:DI

         test      byte ptr es:[DBFPrmM],bit1 ; je editace ?
         jz        EdiDBNd9                 ; nen° editace
         and       byte ptr es:[DBFPrmM],not bit1 ; nen° editace
         or        di,di                    ; je platn† poloëka ?
         jz        EdiDBNd9                 ; nen° to platn† poloëka

; ------ korekce jmÇna, aby zaá°nalo p°smenem

         push      di
         push      cx

         mov       cx,10                    ; poáet zbylòch znakñ
         add       di,DBFNamM               ; zaá†tek jmÇna
EdiDBNd1:cmp       byte ptr es:[di],128     ; je p°smeno s diakritikou ?
         jae       EdiDBNd5                 ; je p°smeno s diakritikou
         cmp       byte ptr es:[di],"A"     ; je to p°smeno ?
         jb        EdiDBNd2                 ; nen° to p°smeno
         cmp       byte ptr es:[di],"Z"     ; je to p°smeno ?
         jbe       EdiDBNd5                 ; je platnò znak (p°smeno)
EdiDBNd2:call      EditBDlC                 ; zru®en° znaku ze zaá†tku pole
         cmp       byte ptr es:[di]," "     ; je mezera ?
         jne       EdiDBNd1                 ; je nàjakò znak

         mov       cx,es:[DBFAktM]          ; aktivn° poloëka
EdiDBNd3:cmp       cx,25
         jbe       EdiDBNd4                 ; je to platnÇ á°slo
         sub       cx,26
         jmp       short EdiDBNd3
EdiDBNd4:add       cl,"A"                   ; korekce na znak ASCII
         mov       byte ptr es:[di],cl      ; implicitn° znak - p°smeno

EdiDBNd5:pop       cx
         pop       di

; ------ korekce dÇlky (mus° bòt minim†lnà 1)

         cmp       byte ptr es:[di+DBFDelM],0 ; je platn† dÇlka poloëky ?
         jne       EdiDBNd9                 ; dÇlka poloëky je OK
         inc       byte ptr es:[di+DBFDelM] ; minim†ln° dÇlka poloëky 1
EdiDBNd9:ret

EdiDBEnd ENDP

; -----------------------------------------------------------------------------
;        F2: posun poloëky nahoru
; -----------------------------------------------------------------------------

EdiDBMU: call      EdiDBEnd                 ; ukonáen° editace poloëky
         cmp       ax,es:[DBFNumM]          ; je to platn† poloëka ?
         jae       EdiDBMU9                 ; nen° to platn† poloëka
         dec       ax                       ; je prvn° poloëka ?
         js        EdiDBMU9                 ; je prvn° poloëka

         push      di
         sub       di,DBFM                  ; p©edch†zej°c° poloëka
EdiDBMU2:mov       es:[DBFAktM],ax          ; nov† aktivn° poloëka
         mov       cx,DBFM                  ; dÇlka poloëky
EdiDBMU4:mov       al,es:[di]
         xchg      al,es:[di+DBFM]
         mov       es:[di],al
         inc       di
         loop      EdiDBMU4
         pop       di

EdiDBMU9:ret

; -----------------------------------------------------------------------------
;        F3: posun poloëky dolñ
; -----------------------------------------------------------------------------

EdiDBMD: call      EdiDBEnd                 ; ukonáen° editace poloëky
         inc       ax                       ; dal®° poloëka
         cmp       ax,es:[DBFNumM]          ; je to posledn° poloëka ?
         jae       EdiDBMD9                 ; je to posledn° poloëka

         push      di
         jmp       short EdiDBMU2           ; z†màna poloëek

EdiDBMD9:ret

; -----------------------------------------------------------------------------
;        F5: kopie
; -----------------------------------------------------------------------------

EdiDBMK: call      EdiDBEnd                 ; ukonáen° editace poloëky
         or        di,di                    ; je to platn† poloëka ?
         jz        EdiDBMK9                 ; nen° to platn† poloëka

         cmp       word ptr es:[DBFNumM],999 ; maxim†ln° poáet poloëek
         jae       EdiDBMK9                 ; je jië maximum poloëek

         mov       ax,ds:[si+DBMMnSeg]      ; segment okna
         mov       cx,DBFM                  ; dÇlka poloëky
         call      far ptr InsDat           ; vytvo©en° m°sta pro poloëku
         jc        EdiDBMK9                 ; chyba pamàti

         inc       word ptr es:[DBFNumM]    ; zvò®en° poátu poloëek
         push      di
EdiDBMK2:mov       al,es:[di+DBFM]
         mov       es:[di],al               ; kopie poloëky
         inc       di
         loop      EdiDBMK2
         pop       di

EdiDBMK9:ret

; -----------------------------------------------------------------------------
;        F6: p©ipoj
; -----------------------------------------------------------------------------

EdiDBMP: call      EdiDBEnd                 ; ukonáen° editace poloëky

         test      byte ptr ds:[DBFEParm],bit6 ; je novò seznam ?
         jnz       EdiDBMP9                 ; je novò seznam - nepovoleno
         inc       ax                       ; dal®° poloëka
         cmp       ax,es:[DBFNumM]          ; je to posledn° poloëka ?
         jae       EdiDBMP9                 ; je to posledn° poloëka

         mov       ax,-1
         test      byte ptr es:[di+DBFTypM],bit0+bit7 ; povolen† poloëka ?
         jz        EdiDBMP9                 ; nepovolen† poloëka
         cmp       es:[di+DBFNumM1],ax      ; existuje star† poloëka ?
         je        EdiDBMP9                 ; neexistuje star† poloëka
         cmp       es:[di+DBFNumM2],ax      ; je jië p©ipojen† poloëka ?
         jne       EdiDBMP9                 ; je jië p©ipojen† poloëka

         test      byte ptr es:[di+DBFTypM+DBFM],bit0+bit7 ; povolen† poloëka ?
         jz        EdiDBMP9                 ; nepovolen† poloëka
         cmp       es:[di+DBFNumM1+DBFM],ax ; je dal®° poloëka platn† ?
         je        EdiDBMP9                 ; dal®° poloëka nen° platn†
         cmp       es:[di+DBFNumM2+DBFM],ax ; je dal®° poloëka spojen† ?
         jne       EdiDBMP9                 ; dal®° poloëka je jië spojen†

         mov       ax,es:[di+DBFNumM1+DBFM] ; á°slo dal®° poloëky
         mov       es:[di+DBFNumM2],ax      ; p©ipojen° k prvn° poloëce

         mov       al,es:[di+DBFSirXM+DBFM] ; zobrazen† ®°©ka dal®° poloëky
         add       es:[di+DBFSirXM],al      ; zvò®en° zobrazenÇ ®°©ky poloëky
         jnc       EdiDBMP2                 ; nen° p©eteáen°
         mov       byte ptr es:[di+DBFSirXM],-1 ; omezen° ®°©ky zobrazen°

EdiDBMP2:mov       al,es:[di+DBFDelM+DBFM]  ; dÇlka dal®° poloëky
         add       es:[di+DBFDelM],al       ; p©iáten° dÇlky poloëky
         jnc       EdiDBMP4                 ; nen° p©eteáen°
         mov       byte ptr es:[di+DBFDelM],-1 ; omezen° dÇlky poloëky

EdiDBMP4:mov       cx,DBFM                  ; dÇlka poloëky
         add       di,cx                    ; adresa dal®° poloëky
         mov       ax,ds:[si+DBMMnSeg]      ; segment okna
         call      far ptr DelDat           ; zru®en° poloëky
         dec       word ptr es:[DBFNumM]    ; sn°ëen° poátu poloëek

EdiDBMP9:ret

; -----------------------------------------------------------------------------
;        F8: zru®en°
; -----------------------------------------------------------------------------

EdiDBMZ: call      EdiDBEnd                 ; ukonáen° editace poloëky
         or        di,di                    ; je platn† poloëka ?
         jz        EdiDBMZ9                 ; nen° platn† poloëka

         mov       ax,ds:[si+DBMMnSeg]      ; segment okna
         mov       cx,DBFM                  ; dÇlka poloëky
         call      far ptr DelDat           ; zru®en° poloëky
         dec       word ptr es:[DBFNumM]    ; sn°ëen° poátu poloëek

EdiDBMZ9:ret

; -----------------------------------------------------------------------------
;        vytvo©en° segmentu modifikace datab†ze (CY=chyba, jinak AX=segment)
; -----------------------------------------------------------------------------
; VSTUP: CX=poáet poloëek
;        DS=datovò segment
; VùSTUP: AX=segment
;         ES=adresa segmentu
;         CY=chyba
; -----------------------------------------------------------------------------

CreaBMMn PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      dx
         push      di

; ------ p©°prava poëadovanÇ velikosti segmentu -> BX

         mov       ax,DBFM                  ; poáet bajtñ na poloëku
         mul       cx                       ; velikost poloëek v bajtech
         add       ax,DBFPopM               ; celkov† poëadovan† velikost
         xchg      ax,bx                    ; BX <- poëadovan† velikost

; ------ vytvo©en° segmentu

         call      far ptr CreatSeg         ; vytvo©en° segmentu
         jc        CreaBMM6                 ; chyba

; ------ nastaven° velikosti segmentu

         call      far ptr ModiSegS         ; nastaven° velikosti segmentu
         jc        CreaBMM4                 ; chyba

; ------ adresa segmentu -> ES

         call      far ptr GetDat           ; adresa bufferu -> ES

; ------ vynulov†n° segmentu

         push      ax
         push      cx

         xor       ax,ax                    ; AX <- 0 nulovac° slovo
         xor       di,di                    ; DI <- 0 poá†tek bufferu
         mov       cx,bx                    ; CX <- velikost segmentu
         cld
         rep       stosb                    ; vynulov†n° segmentu
         mov       es:[DBFBytM],bx          ; velikost segmentu

         pop       cx
         pop       ax

; ------ inicializace parametrñ

         mov       es:[DBFNumM],cx          ; poáet poloëek popisovaáñ
         mov       byte ptr es:[DBFPrmM],bit2 ; parametry
         clc                                ; p©°znak operace OK
         jmp       short CreaBMM8

; ------ zru®en° segmentu AX p©i chybà

CreaBMM4:call      far ptr DelSeg           ; zru®en° segmentu p©i chybà
CreaBMM6:xor       ax,ax                    ; AX <- 0 neplatnò segment
         stc                                ; p©°znak chyby

; ------ n†vrat registrñ

CreaBMM8:pop       di
         pop       dx
         pop       bx
         ret

CreaBMMn ENDP

; -----------------------------------------------------------------------------
;        inicializace segmentu modifikace datab†ze
; -----------------------------------------------------------------------------
; VSTUP: (AX=segment modifikace datab†ze)
;        BX=segment datab†ze
;        ES=adresa segmentu modifikace datab†ze
;        DS=datovò segment
; -----------------------------------------------------------------------------

IniBMMn  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      ds

; ------ adresa segmentu datab†ze -> DS

         xchg      ax,bx                    ; AX <- segment datab†ze
         call      far ptr GetSgAdr         ; adresa okna datab†ze
         mov       ds,dx                    ; adresa okna datab†ze

; ------ p©°prava ke generov†n° ukazatelñ

         mov       cx,ds:[DBFNumP]          ; poáet popisovaáñ
         jcxz      IniBMMn9                 ; nen° ë†dnò popisovaá
         xor       dx,dx                    ; DX <- 0
         mov       bx,ds:[DBFAdrP]          ; adresa popisovaáñ
         mov       di,DBFPopM               ; zaá†tek popisovaáñ modifikace
         cld

; ------ á°slo poloëky 1 a 2

IniBMMn2:mov       es:[di+DBFNumM1],dx      ; á°slo poloëky 1
         mov       word ptr es:[di+DBFNumM2],-1 ; á°slo poloëky 2 = nen°

; ------ typ poloëky

         mov       al,ds:[bx+DBFParX]       ; typ poloëky
         mov       es:[di+DBFTypM],al       ; typ poloëky
         mov       es:[di+DBFTypMO],al      ; pñvodn° typ poloëky

; ------ dÇlka poloëky

         mov       al,ds:[bx+DBFDelX]       ; dÇlka poloëky (bajtñ)
         mov       es:[di+DBFDelM],al       ; dÇlka poloëky (bajtñ)

; ------ poáet desetinnòch m°st poloëky

         mov       si,ds:[bx+DBFNamX]       ; adresa jmÇna popisovaáe
         mov       al,ds:[si+17]            ; poáet desetinnòch m°st
         mov       es:[di+DBFDesM],al       ; poáet desetinnòch m°st

; ------ znak pro jinò typ poloëky

         mov       al,ds:[si+11]            ; oznaáen° typu poloëky
         mov       es:[di+DBFTypMC],al      ; oznaáen° typu poloëky

; ------ poá†teán° pozice v poloëce 1 = 0

         mov       byte ptr es:[di+DBFPozM],0 ; poá†teán° pozice

; ------ inicializace jmÇna poloëky

         push      cx
         push      di

         add       di,DBFNamM               ; buffer jmÇna poloëky
         push      di
         mov       cx,10                    ; dÇlka bufferu jmÇna poloëky
         mov       al," "                   ; mazac° znak mezery
         rep       stosb                    ; vymaz†n° poloëky
         pop       di

         mov       cl,ds:[bx+DBFNumX]       ; dÇlka jmÇna popisovaáe poloëky
         rep       movsb                    ; p©enos jmÇna poloëky

         pop       di
         pop       cx

; ------ zobrazen† ®°©ka poloëky

         mov       al,ds:[bx+DBFSirX]       ; zobrazen† ®°©ka poloëky 1
         mov       es:[di+DBFSirXM],al      ; zobrazen† ®°©ka poloëky 1

; ------ p©°prava pro dal®° poloëku

         add       di,DBFM                  ; popisovaá dal®° poloëky modifikace
         add       bx,DBFX                  ; popisovaá dal®° poloëky datab†ze
         inc       dx                       ; á°slo dal®° poloëky datab†ze
         loop      IniBMMn2                 ; dal®° poloëka

; ------ n†vrat registrñ

IniBMMn9:pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

IniBMMn  ENDP

; -----------------------------------------------------------------------------
;        inicializace okna modifikace datab†ze
; -----------------------------------------------------------------------------

InitBMMn PROC      FAR

         call      far ptr CentMenu
         ret

InitBMMn ENDP

; -----------------------------------------------------------------------------
;        zobrazen° okna modifikace datab†ze
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) definice okna
;                   SS:[BP-4] (2) adresa segmentu poloëek
;                   SS:[BP-5] (1) ukazatel ©†dku na displeji
;                   SS:[BP-6] (1) poá†teán° pozice okna
;                   SS:[BP-7] (1) á°taá ©†dkñ k zobrazen°
;                   SS:[BP-8] (1) ®°©ka okna
;                   SS:[BP-10] (2) ukazatel adresy poloëek definice
;                   SS:[BP-12] (2) á°taá poloëek k zobrazen°
;                   SS:[BP-14] (2) á°taá aktivn° poloëky
;                   SS:[BP-16] (2) hladina k zobrazen° ©†dku
;                   SS:[BP-18] (2) poá†tek k dek¢dov†n° textu
;                   SS:[BP-19] (1) parametry
;                                      bit 0:
;                                      bit 1: 1=zah†jena editace
;                                      bit 2: 1=aktivn° jmÇno
;                                      bit 3: 1=aktivn° typ
;                                      bit 4: 1=aktivn° dÇlka
;                                      bit 5: 1=aktivn° desetiny
;                                      bit 6: 1=aktivn° poá†tek
;                   SS:[BP-20] (1) parametry
;                                      bit 6: 1=je vytvo©en° souboru
;                   SS:[BP-21] (1) barva neaktivn° poloëky
;                   SS:[BP-22] (1) barva aktivn° poloëky
;                   SS:[BP-23] (1) barva needitovatelnÇ poloëky
;                   SS:[BP-24] (1)
; -----------------------------------------------------------------------------
;˛
DispBMMn PROC      FAR

; ------ korekce menu a zobrazen° r†mu

         call      KorBMMn                  ; korekce menu
         call      KurBMMn                  ; zobrazen° kurzoru menu
         call      far ptr DispRamM         ; zobrazen° r†mu okna

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

; ------ p©°prava lok†ln°ch promànnòch

         sub       sp,24
         mov       ss:[bp-2],si             ; adresa definice okna
         mov       ax,ds:[si+DBMMnSeg]      ; segment okna
         call      far ptr GetDat           ; adresa segmentu
         mov       ss:[bp-4],es             ; adresa segmentu poloëek
         mov       ax,word ptr ds:[si+MnuPoz] ; ©†dek a pozice okna
         inc       ah                       ; poá†teán° ©†dek
         mov       ss:[bp-6],ax             ; ©†dek a pozice okna
         mov       ax,word ptr ds:[si+MnuSir] ; ®°©ka a vò®ka okna
         sub       ah,3                     ; vò®ka bez okrajñ
         mov       ss:[bp-8],ax             ; ®°©ka a vò®ka okna
         mov       ah,0
         shl       ax,1
         sub       sp,ax                    ; m°sto pro buffer ©†dku
         mov       ax,DBFM                  ; dÇlka poloëky
         mul       word ptr es:[DBFTopM]    ; offset prvn° poloëky
         add       ax,DBFPopM               ; adresa prvn° poloëky
         mov       ss:[bp-10],ax            ; ukazatel adresy poloëek
         mov       ax,es:[DBFNumM]          ; poáet poloëek
         sub       ax,es:[DBFTopM]          ; poáet zbylòch poloëek
         mov       ss:[bp-12],ax            ; poáet poloëek k zobrazen°
         mov       ax,es:[DBFAktM]          ; aktivn° poloëka
         sub       ax,es:[DBFTopM]          ; offset od poá†tku
         inc       ax                       ; korekce
         mov       ss:[bp-14],ax            ; á°taá aktivn° poloëky
         mov       al,ds:[si+MnuLev]        ; hladina
         mov       ah,0
         mov       ss:[bp-16],ax            ; hladina k zobrazen° ©†dku
         mov       ah,es:[DBFPrmM]          ; parametry
         mov       al,ds:[DBFEParm]         ; parametry
         mov       ss:[bp-20],ax            ; parametry
         mov       al,ss:[bp-8]             ; ®°©ka okna
         sub       al,53                    ; je modifikace
         test      byte ptr ss:[bp-20],bit6 ; je vytvo©en° souboru ?
         jz        DspBMM12                 ; nen° vytvo©en°
         add       al,9                     ; nen° pole poá†tku
DspBMM12:and       ax,0feh                  ; zarovn†n°
         add       ax,sp                    ; adresa k dek¢dov†n° textu
         mov       ss:[bp-18],ax            ; adresa k dek¢dov†n°
         mov       al,ds:[ColDBF13]         ; barva poloëek
         mov       ss:[bp-21],al            ; barva neaktivn° poloëky
         mov       al,ds:[ColDBF12]         ; bàën† barva nadpisu
         mov       ss:[bp-23],al            ; barva needitovatelnÇ poloëky

; ------ zobrazen° ©†dku nadpisu

         call      DispBMMC                 ; vymaz†n° ©†dku

         mov       di,ss:[bp-18]            ; adresa k dek¢dov†n°
         mov       cl,offset(DBMMMNd2-DBMMMNad) ; dÇlka textu - modifikace
         test      byte ptr ss:[bp-20],bit6 ; je vytvo©en° ?
         jz        DspBMM14                 ; nen° vytvo©en°
         mov       cl,offset(DBMMMNd1-DBMMMNad) ; dÇlka textu - vytvo©en°
DspBMM14:mov       si,offset DBMMMNad       ; text nadpisu
         cld
         mov       ah,ds:[ColDBF15]         ; vysv°cen† barva poloëek
DispBMM1:lodsb
         call      far ptr KonvFChr         ; konverze n†rodn°ho k¢du znaku
         cld
         stosw
         loop      DispBMM1

         call      DispBMMD                 ; zobrazen° ©†dku

; ------ inicializaán° vymaz†n° ©†dku

DispBMM2:call      DispBMMC                 ; vymaz†n° ©†dku

; ------ p©°prava barvy ©†dku poloëky

         mov       ah,ds:[ColDBF13]         ; barva poloëek
         dec       word ptr ss:[bp-14]      ; á°taá aktivn° poloëky
         jnz       DispBMM3                 ; nen° aktivn° poloëka
         mov       ah,ds:[ColDBF14]         ; barva aktivn°ho ©†dku
DispBMM3:mov       ss:[bp-22],ah            ; barva aktivn° poloëky

; ------ test, zda je poloëka k zobrazen°

         dec       word ptr ss:[bp-12]      ; á°taá poloëek k zobrazen°
         jns       DispBMM4                 ; je dal®° poloëka

; ------ pro prvn° neplatnò ©†dek bude zobrazeno jako nov† poloëka (=jen jmÇno)

         cmp       word ptr ss:[bp-12],-1   ; je prvn° neplatn† poloëka ?
         jne       DspBMM34                 ; nen° prvn° neplatn† poloëka

         mov       di,ss:[bp-18]            ; adresa k dek¢dov†n° textu
         add       di,2*8                   ; p©eskoáen° pole á°sla poloëky
         mov       cl,10                    ; dÇlka jmÇna
         mov       al," "
         rep       stosw                    ; zobrazen° pr†zdnÇho jmÇna

DspBMM34:jmp       DispBMM8                 ; nen° dal®° poloëka

; ------ p©°prava adresy poloëky (màn° se DS !)

DispBMM4:push      ds

         mov       di,ss:[bp-18]            ; adresa k dek¢dov†n° textu
         mov       bx,ss:[bp-10]            ; ukazatel poloëek
         mov       ds,ss:[bp-4]             ; segment poloëek

; ------ dek¢dov†n° á°sla poloëky

         mov       ah,ss:[bp-23]            ; barva zak†zanÇ poloëky
         mov       cl,3                     ; dÇlka pole
         cmp       word ptr ds:[bx+DBFNumM2],-1 ; je druh† poloëka ?
         jne       DspBMM42                 ; je druh† poloëka
         add       di,2*2                   ; adresa k dek¢dov†n° á°sla
         mov       dx,ds:[bx+DBFNumM1]      ; á°slo prvn° poloëky
         inc       dx                       ; korekce á°sla prvn° poloëky
         jnz       DspBMM41                 ; je prvn° poloëka
         add       di,2*5                   ; p©eskoáen° pole, nen°-li 1.poloëka
         jmp       short DspBMM46

DspBMM41:call      DispBMMU                 ; dek¢dov†n° á°sla (je 1 poloëka)
         add       di,2*2                   ; p©eskoáen° mezery
         jmp       short DspBMM46

DspBMM42:push      di

         mov       dx,ds:[bx+DBFNumM2]      ; druhÇ á°slo
         inc       dx                       ; korekce á°sla druhÇ poloëky
         add       di,4*2                   ; zaá†tek á°sla druhÇ poloëky
         cmp       dx,99
         ja        DspBMM43
         dec       di
         dec       di
         cmp       dl,9
         ja        DspBMM43
         dec       di
         dec       di
DspBMM43:call      DispBMMU                 ; dek¢dov†n° druhÇho á°sla

         pop       di
         push      di

         mov       dx,ds:[bx+DBFNumM1]      ; á°slo prvn° poloëky
         inc       dx                       ; korekce á°sla prvn° poloëky
         call      DispBMMU                 ; dek¢dov†n° á°sla poloëky
         cld
         mov       al,"+"
         stosw                              ; spojovac° znak "+"

         pop       di
         add       di,2*7

DspBMM46:inc       di
         inc       di

; ------ dek¢dov†n° jmÇna poloëky

         mov       cl,10                    ; dÇlka jmÇna poloëky
         lea       si,[bx+DBFNamM]          ; jmÇno poloëky
         cld
         mov       ah,ss:[bp-21]            ; barva neaktivn° poloëky
         test      byte ptr ss:[bp-19],bit2 ; je aktivn° jmÇno ?
         jz        DspBMM51                 ; nen° aktivn° jmÇno
         mov       ah,ss:[bp-22]            ; barva aktivn° poloëky

DspBMM51:jcxz      DspBMM59
         lodsb                              ; naáten° znaku
         dec       cx
         call      far ptr UpCase           ; konverze na velkÇ p°smeno
DspBMM52:stosw                              ; prvn° p°smeno je velkÇ
         cmp       al,"_"
         je        DspBMM51

DspBMM53:jcxz      DspBMM59
         lodsb                              ; naáten° znaku
         dec       cx
         cmp       al,"_"
         je        DspBMM52
         call      far ptr DownCase         ; konverze na malÇ p°smeno
         stosw
         jmp       short DspBMM53

DspBMM59:add       di,2*2

; ------ dek¢dov†n° typu poloëky (navrac° se DS !) (je CLD a CH=0 !)

         mov       cl,7                     ; dÇlka textu

         mov       ah,ds:[bx+DBFTypMC]      ; znak pro jinò typ poloëky
         mov       al,ds:[bx+DBFTypM]       ; typ poloëky

         pop       ds

         mov       ds:[DBMMMTp0+5],ah       ; oznaáen° typu poloëky

         mov       si,offset DBMMMTyp-7
         or        al,bit7                  ; pojistka proti chybà typu
DspBMM61:add       si,cx                    ; adresa dal®°ho textu
         shr       al,1
         jnc       DspBMM61                 ; bude dal®° typ

         mov       ah,ss:[bp-21]            ; barva neaktivn° poloëky
         test      byte ptr ss:[bp-19],bit3 ; je aktivn° typ ?
         jz        DspBMM62                 ; nen° aktivn° typ
         mov       ah,ss:[bp-22]            ; barva aktivn° poloëky

DspBMM62:lodsb
         call      far ptr KonvFChr         ; konverze n†rodn°ho k¢du znaku
         cld
         stosw
         loop      DspBMM62
         add       di,2*3

; ------ dek¢dov†n° dÇlky poloëky (màn° se DS !)

         push      ds
         mov       dh,0
         mov       ah,ss:[bp-23]            ; barva nemànitelnÇ dÇlky
         mov       ds,ss:[bp-4]             ; segment poloëek
         mov       cl,3                     ; dÇlka pole dÇlky poloëky
         mov       al,ds:[bx+DBFTypM]       ; typ poloëky

         mov       dl,6                     ; dÇlka áasu
         test      al,bit6                  ; je áas ?
         jnz       DspBMM63                 ; je pole áasu

         mov       dl,10                    ; dÇlka MEMO pole
         test      al,bit5                  ; je MEMO pole ?
         jnz       DspBMM63                 ; je MEMO pole

         mov       dl,1                     ; dÇlka logickÇ poloëky
         test      al,bit4                  ; je logick† poloëka ?
         jnz       DspBMM63                 ; je logick† poloëka

         mov       dl,8                     ; dÇlka data
         test      al,bit3                  ; je datum ?
         jnz       DspBMM63                 ; je datum

         mov       dl,ds:[bx+DBFDelM]       ; dÇlka poloëky
         test      al,bit1+bit2             ; je á°slo ?
         jz        DspBMM6A                 ; nen° to á°slo

         cmp       dl,20                    ; maxim†ln° dÇlka poloëky
         jbe       DspBMM6A                 ; dÇlka poloëky je OK
         mov       dl,20                    ; omezen° dÇlky poloëky

DspBMM6A:mov       ah,ss:[bp-21]            ; barva neaktivn° poloëky
         test      byte ptr ss:[bp-19],bit4 ; je aktivn° dÇlka ?
         jz        DspBMM63                 ; nen° aktivn° dÇlka
         mov       ah,ss:[bp-22]            ; barva aktivn° poloëky

DspBMM63:call      DispBMMU                 ; dek¢dov†n° dÇlky poloëky
         add       di,2*5

; ------ dek¢dov†n° poátu desetinnòch m°st

         xor       dx,dx                    ; DX <- 0
         mov       ah,ss:[bp-23]            ; barva zak†zanÇ poloëky
         test      byte ptr ds:[bx+DBFTypM],bit1+bit2+bit7 ; á°seln† poloëka ?
         jz        DspBMM65                 ; nen° á°seln† poloëka

DspBMM64:mov       dl,ds:[bx+DBFDesM]       ; poáet desetinnòch m°st
         test      byte ptr ds:[bx+DBFTypM],bit7 ; je jinò typ poloëky ?
         jnz       DspBMM6B                 ; je jinò typ poloëky
         mov       al,ds:[bx+DBFDelM]       ; dÇlka poloëky
         sub       al,2                     ; maxim†ln° poáet deset. m°st
         jnc       DspBMM6D
         mov       al,0
DspBMM6D:cmp       al,18
         jbe       DspBMM6C
         mov       al,18
DspBMM6C:cmp       dl,al                    ; je poáet des. m°st OK ?
         jbe       DspBMM6B                 ; poáet des. m°st je OK
         mov       dl,al                    ; omezen° poátu des. m°st

DspBMM6B:mov       ah,ss:[bp-21]            ; barva neaktivn° poloëky
         test      byte ptr ss:[bp-19],bit5 ; jsou aktivn° desetiny ?
         jz        DspBMM65                 ; nejsou aktivn° desetiny
         mov       ah,ss:[bp-22]            ; barva aktivn° poloëky

DspBMM65:mov       cl,3
         call      DispBMMU                 ; dek¢dov†n° poátu desetinnòch m°st
DspBMM66:add       di,2*6

; ------ dek¢dov†n° poá†tku poloëky (navrac° DS !)

         test      byte ptr ss:[bp-20],bit6 ; je vytvo©en° seznamu ?
         jnz       DspBMM68                 ; je vytvo©en° seznamu

         xor       dx,dx                    ; DX <- 0 nen° poá†teán° pozice
         mov       ah,ss:[bp-23]            ; zak†zan† poloëka

         test      byte ptr ds:[bx+DBFTypM],bit0+bit7 ; je textov† poloëka ?
         jz        DspBMM67                 ; nen° textov† poloëka - nen° poá†tek
;         jz        DspBMM68                 ; nen° textov† poloëka - nen° poá†tek

         mov       dl,ds:[bx+DBFPozM]       ; poá†teán° pozice

         mov       ah,ss:[bp-21]            ; barva neaktivn° poloëky
         test      byte ptr ss:[bp-19],bit6 ; je aktivn° poá†tek ?
         jz        DspBMM67                 ; nen° aktivn° poá†tek
         mov       ah,ss:[bp-22]            ; barva aktivn° poloëky

DspBMM67:mov       cl,3
         call      DispBMMU                 ; dek¢dov†n° poá†teán° pozice

DspBMM68:pop       ds

         add       word ptr ss:[bp-10],DBFM ; adresa dal®° poloëky

; ------ zobrazen° ©†dku

DispBMM8:call      DispBMMD                 ; zobrazen° ©†dku

; ------ p©°prava pro dal®° ©†dek

         dec       byte ptr ss:[bp-7]       ; á°taá ©†dkñ k zobrazen°
         jz        DispBMM9                 ; jsou v®echny ©†dky
         jmp       DispBMM2                 ; dal®° ©†dek

; ------ n†vrat registrñ

DispBMM9:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispBMMn ENDP

; ------ vymaz†n° ©†dku

DispBMMC:push      ss
         pop       es                       ; ES <- segment z†sobn°ku
         mov       di,sp
         inc       di
         inc       di                       ; DI <- zaá†tek bufferu v z†sobn°ku
         cld

         mov       ah,ds:[ColMnu1R]         ; barva pro levò okraj
         mov       al,"≥"                   ; "≥"
         stosw                              ; levò okraj

         mov       ch,0
         mov       cl,ss:[bp-8]             ; ®°©ka okna
         dec       cx
         dec       cx                       ; bez okrajñ
         mov       ah,ds:[ColDBF12]         ; barva podkladu
         mov       al," "
         rep       stosw                    ; vymaz†n° ©†dku

         mov       ah,ds:[ColMnu1L]         ; barva pro pravò okraj
         mov       al,"≥"                   ; "≥"
         stosw                              ; pravò okraj
         ret

; ------ zobrazen° ©†dku

DispBMMD:mov       ax,ss:[bp-16]            ; hladina k zobrazen°
         mov       dx,ss:[bp-6]             ; ©†dek a pozice
         mov       cl,ss:[bp-8]             ; ®°©ka okna
         mov       si,sp
         inc       si
         inc       si
         call      far ptr DispMStr         ; zobrazen° textu
         inc       byte ptr ss:[bp-5]       ; zvò®en° ukazatele ©†dku na displ.
         ret

; ------ dek¢dov†n° á°sla DX, dÇlka pole CX, barva AH, adresa ES:DI

DispBMMU:mov       al," "
         cld
         push      cx
         rep       stosw                    ; vymaz†n° pole
         pop       cx

         push      ax
         push      bx
         push      dx

         xchg      ax,bx                    ; BH <- barva
         xchg      ax,dx                    ; AX <- á°slo
         xor       dx,dx                    ; DX <- 0 á°slo HIGH
         mov       bl,0                     ; nen° oddàlovaá

         cmp       ax,999
         jbe       DspBMMU2
         mov       ax,999
DspBMMU2:call      far ptr DekNumD          ; dek¢dov†n° á°sla

         pop       dx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
;        korekce menu modifikace datab†ze DS:SI
; -----------------------------------------------------------------------------

KorBMMn  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      es

; ------ adresa segmentu okna -> ES

         mov       ax,ds:[si+DBMMnSeg]      ; segment okna
         call      far ptr GetDat           ; adresa segmentu -> ES

; ------ p©°prava ukazatelñ

         mov       ax,es:[DBFAktM]          ; aktivn° poloëka
         mov       bx,es:[DBFTopM]          ; prvn° zobrazen† poloëka
         mov       cl,ds:[si+MnuVys]        ; vò®ka okna
         mov       ch,0
         sub       cl,5                     ; vnit©n° vò®ka okna - 2
         mov       dx,es:[DBFNumM]          ; poáet poloëek

; ------ omezen° kurzoru

         cmp       ax,dx                    ; vyhovuje kurzor ?
         jbe       KorBMMn1                 ; kurzor je OK
         mov       ax,dx                    ; omezen° kurzoru
         mov       es:[DBFAktM],ax          ; omezen† aktivn° poloëka

; ------ kontrola podteáen° poá†tku

KorBMMn1:cmp       ax,bx                    ; je podteáen° poá†tku ?
         ja        KorBMMn2                 ; poá†tek je OK
         mov       bx,ax                    ; poá†tek na kurzor
         or        ax,ax                    ; je jië prvn° ©†dek ?
         jz        KorBMMn2                 ; je jië prvn° ©†dek
         dec       bx                       ; 1 ©†dek rezerva

; ------ kontrola p©eteáen° poá†tku

KorBMMn2:sub       ax,cx                    ; maxim†ln° poá†tek
         jnc       KorBMMn3                 ; zbòv† dost ©†dkñ
         xor       ax,ax                    ; omezen° p©i podteáen°
KorBMMn3:cmp       ax,bx                    ; je poá†tek OK ?
         jbe       KorBMMn4                 ; poá†tek je OK
         xchg      ax,bx                    ; BX <- omezen° poá†tku

; ------ omezen° maxim†ln°ho poá†tku

KorBMMn4:inc       cx                       ; vnit©n° vò®ka okna + 1
         sub       dx,cx                    ; maxim†ln° poá†tek
         jnc       KorBMMn5                 ; je dost ©†dkñ
         xor       dx,dx                    ; DX <- 0 omezen° p©i m†lo ©†dc°ch
KorBMMn5:cmp       bx,dx                    ; p©ekroáen maxim†ln° poá†tek ?
         jbe       KorBMMn6                 ; poá†tek je OK
         mov       bx,dx                    ; omezen° poá†tku
KorBMMn6:mov       es:[DBFTopM],bx          ; novò poá†tek

; ------ p©°prava aktivn°ho prvku v poloëce -> CH

         mov       ch,es:[DBFPrmM]          ; aktivn° prvek
         and       ch,bit2+bit3+bit4+bit5+bit6 ; aktivn° prvek
         and       byte ptr es:[DBFPrmM],not bit2+bit3+bit4+bit5+bit6

; ------ korekce, nen°-li platn† poloëka

         mov       ax,es:[DBFAktM]          ; aktivn° poloëka
         cmp       ax,es:[DBFNumM]          ; je to platn† poloëka ?
         jb        KorBMM72                 ; je to platn† poloëka
         mov       ch,bit2                  ; aktivn° je jmÇno
         jmp       short KorBMMn8

; ------ adresa aktivn° poloëky -> BX

KorBMM72:mov       bx,DBFM                  ; poáet bajtñ na poloëku
         mul       bx                       ; offset aktivn° poloëky
         add       ax,DBFPopM               ; adresa aktivn° poloëky
         xchg      ax,bx                    ; BX <- adresa aktivn° poloëky
         mov       cl,es:[bx+DBFTypM]       ; typ poloëky

; ------ korekce aktivn°ho prvku v poloëce (zak†zan† pole)

         shl       ch,1                     ; p©ednastaven°
KorBMM73:shr       ch,1                     ; posun k poá†tku

         test      ch,bit6                  ; je aktivn° poá†tek ?
         jz        KorBMM74                 ; nen° aktivn° poá†tek
         test      byte ptr ds:[DBFEParm],bit6 ; je novò soubor ?
         jnz       KorBMM73                 ; novò soubor - nepovoleno
         test      cl,bit0+bit7             ; je to textov† poloëka ?
         jz        KorBMM73                 ; nen° textov† poloëka - nepovoleno

KorBMM74:test      ch,bit5                  ; aktivn° desetiny ?
         jz        KorBMM75                 ; nejsou aktivn° desetiny
         test      cl,bit1+bit2+bit7        ; je to á°slo ?
         jz        KorBMM73                 ; nen° to á°slo

KorBMM75:test      ch,bit4                  ; aktivn° dÇlka ?
         jz        KorBMMn8                 ; nen° aktivn° dÇlka
         test      cl,bit3+bit4+bit5+bit6   ; je datum, logic., MEMO, áas ?
         jnz       KorBMM73                 ; nen° moënÇ zmànit dÇlku

; ------ nastaven° novÇho aktivn°ho prvku

KorBMMn8:or        es:[DBFPrmM],ch          ; novò aktivn° prvek

; ------ korekce pozice kurzoru

         test      byte ptr es:[DBFPrmM],bit4+bit5+bit6 ; aktivn° á°slo ?
         jz        KorBMMn9                 ; nen° aktivn° á°slo
         mov       byte ptr es:[DBFKurM],2  ; kurzor v poloëce 3 pozice
         test      byte ptr es:[DBFPrmM],bit5 ; jsou aktivn° desetiny ?
         jz        KorBMMn9                 ; nejsou desetiny
         dec       byte ptr es:[DBFKurM]    ; kurzor v poloëce 2 pozice

; ------ uráen° textu n†povàdy k aktivn°mu prvku poloëky

KorBMMn9:mov       dx,offset DBMMMHl0       ; neplatn† poloëka
         mov       ax,es:[DBFAktM]          ; aktivn° poloëka
         cmp       ax,es:[DBFNumM]          ; je to platn† poloëka ?
         jae       KorBMM92                 ; neplatn† poloëka

         mov       al,es:[DBFPrmM]          ; parametry
         mov       dx,offset DBMMMHl1       ; jmÇno poloëky
         test      al,bit2                  ; je aktivn° jmÇno poloëky ?
         jnz       KorBMM92                 ; aktivn° jmÇno poloëky

         mov       dx,offset DBMMMHl2       ; typ poloëky
         test      al,bit3                  ; je aktivn° typ poloëky ?
         jnz       KorBMM92                 ; aktivn° typ poloëky

         mov       dx,offset DBMMMHl5       ; poáet desetinnòch m°st
         test      al,bit5                  ; aktivn° desetiny ?
         jnz       KorBMM92                 ; aktivn° poáet desetinnòch m°st

         mov       dx,offset DBMMMHl6       ; poá†tek
         test      al,bit6                  ; aktivn° poá†tek poloëky ?
         jnz       KorBMM92                 ; aktivn° poá†tek poloëky

         mov       dx,offset DBMMMHl4       ; dÇlka á°selnÇ poloëky
         test      byte ptr es:[bx+DBFTypM],bit1+bit2 ; á°seln† poloëka ?
         jnz       KorBMM92                 ; dÇlka pro á°selnou poloëku
         mov       dx,offset DBMMMHl3       ; jinak dÇlka pro znakovou poloëku

KorBMM92:mov       ds:[si+MnuHlp],dx        ; adresa n†povàdy k poloëce

; ------ uráen° titulu okna

         mov       word ptr ds:[si+MnuTitl],offset DBMMMTi1 ; novò seznam
         test      byte ptr ds:[DBFEParm],bit6 ; je novò seznam ?
         jnz       KorBMM94                 ; je novò seznam
         mov       word ptr ds:[si+MnuTitl],offset DBMMMTi2 ; modifikace starÇho

; ------ n†vrat registrñ

KorBMM94:pop       es
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

KorBMMn  ENDP

; -----------------------------------------------------------------------------
;        zobrazen° kurzoru menu modifikace DS:SI
; -----------------------------------------------------------------------------

KurBMMn  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      dx
         push      es

; ------ adresa segmentu okna -> ES

         mov       ax,ds:[si+DBMMnSeg]      ; segment okna
         call      far ptr GetDat           ; adresa segmentu -> ES

; ------ ©†dek k zobrazen° kurzoru

         mov       dh,es:[DBFAktM]          ; aktivn° poloëka
         sub       dh,es:[DBFTopM]          ; offset od poá†teán° poloëky
         add       dh,2                     ; p©iáten° okraje okna

; ------ vyst©edàn† pozice poá†tku poloëek

         mov       dl,ds:[si+MnuSir]        ; ®°©ka okna
         sub       dl,53                    ; je modifikace
         test      byte ptr ds:[DBFEParm],bit6 ; je vytvo©en° souboru ?
         jz        KurBMMn2                 ; nen° vytvo©en°
         add       dl,9                     ; nen° pole poá†tku
KurBMMn2:shr       dl,1                     ; polovina na okraj

; ------ bàën† pozice kurzoru v oknà

         add       dl,es:[DBFKurM]          ; pozice kurzoru v poloëce
         add       dl,8                     ; p©eskoáen° á°sla poloëky

; ------ pozice OK, je-li aktivn° jmÇno

         mov       al,es:[DBFPrmM]          ; parametry
         test      al,bit2                  ; aktivn° jmÇno ?
         jnz       KurBMMn5                 ; aktivn° jmÇno

; ------ korekce pro aktivn° typ poloëky

         add       dl,12                    ; p©eskoáen° jmÇna
         test      al,bit3                  ; aktivn° typ ?
         jnz       KurBMMn5                 ; aktivn° typ

; ------ korekce pro aktivn° dÇlku

         add       dl,10                    ; p©eskoáen° typu
         test      al,bit4                  ; aktivn° dÇlka ?
         jnz       KurBMMn5                 ; aktivn° dÇlka

; ------ korekce pro aktivn° desetiny

         add       dl,9                     ; p©eskoáen° dÇlky
         test      al,bit5                  ; aktivn° desetiny ?
         jnz       KurBMMn5                 ; aktivn° desetiny

; ------ korekce pro aktivn° poá†tek

         add       dl,8                     ; p©eskoáen° desetin

; ------ zobrazen° kurzoru

KurBMMn5:add       dx,word ptr ds:[si+MnuPoz] ; p©iáten° poá†tku okna
         call      far ptr SetKurz          ; nastaven° pozice kurzoru

; ------ nastaven° velikosti kurzoru

         test      byte ptr ds:[DBFEParm],bit2 ; je INSERT ?
         jz        KurBMMn8                 ; nen° INSERT
         call      far ptr SizeLKur         ; nastaven° n°zkÇho kurzoru
         jmp       short KurBMMn9

KurBMMn8:call      far ptr SizeHKur         ; nastaven° vysokÇho kurzoru

; ------ n†vrat registrñ

KurBMMn9:pop       es
         pop       dx
         pop       ax
         ret

KurBMMn  ENDP

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                            Seznam souborñ
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
; *****************************************************************************
;                                 FileSel
;                          Obsluha seznamu souborñ
; -----------------------------------------------------------------------------
; VSTUP: SI=menu vòbàru souborñ
;        DS=datovò segment
; VùSTUP: CY=p©eru®en° operace
;         NC=zvolena nàkter† poloëka, k cestà je p©id†no jmÇno zvolenÇ poloëky
;            Po proveden° operace by màl nad©azenò program poloëku z cestu
;            zru®it (SubFSel) a opakovat vyvol†n° FileSel (aë do navr†cen° CY)
;            V bufferu SRSMnPl4 je p©ipraveno jmÇno zvolenÇ poloëky (+dÇlka).
;            V bufferu LinBuff je p©ipraven koment†© k poloëce (dÇlka v LinNum).
;            (dÇlka omezena na 50 znakñ)
; *****************************************************************************

FileSel  PROC      FAR

         test      byte ptr ds:[ParMenu],bit5 ; je vyno©en° z menu ?
         jz        FileSel0                 ; nen° vyno©en° z menu
         stc                                ; p©°znak p©eru®en°
         ret

FileSel0:call      far ptr NulBreak         ; nulov†n° p©°znaku p©eru®en°

; ------ p©°prava textu pro hl†®en°

         push      ds
         pop       es                       ; ES <- datovò segment
         push      si
         mov       si,ds:[si+SMnuText]      ; adresa textu
         mov       cx,7                     ; velikost bufferu
         mov       di,offset SeznTx1X       ; pomocnò buffer
         cld
         rep       movsb                    ; £schova textu
         pop       si

; ------ sestaven° cesty podadres†©e

         cmp       word ptr ds:[si+SMnuPthN],0 ; je cesta definov†na ?
         jne       FileSel1                 ; cesta je jië definov†na

         push      si
         mov       di,ds:[si+SMnuPath]      ; adresa cesty
         add       si,SMnuExtI              ; inicializaán° jmÇno podadres†©e
         call      far ptr TempFile         ; inicializace cesty dat.podadres†©e
         pop       si
         sub       di,ds:[si+SMnuPath]      ; dÇlka textu cesty
         mov       ds:[si+SMnuPthN],di      ; dÇlka textu cesty
         mov       ds:[si+SMnuPth0],di      ; inicializaán° dÇlka textu cesty

; ------ vytvo©en° adres†©e, pokud neexistuje

FileSel1:push      si
         mov       si,ds:[si+SMnuPath]      ; adres†©
         mov       cl,0                     ; atributy vytv†©enòch adres†©ñ
         call      far ptr CreaLDir         ; vytvo©en° datovÇho adres†©e
         pop       si

; ------ vytvo©en° a naáten° okna seznamu souborñ

         call      far ptr InitFSel         ; otev©en° okna seznamu souborñ
         jnc       FileSl12                 ; operace OK
         jmp       FileSel9                 ; chyba

; ------ n†vrat kurzoru

FileSl12:mov       ax,ds:[si+SMnuSeg]       ; segment okna
         call      far ptr GetDat           ; adresa okna -> ES
         mov       ax,ds:[si+SMnuFrst]      ; prvn° poloëka
         mov       es:[AWinFrst],ax         ; prvn° poloëka v oknà
         mov       ax,ds:[si+SMnuKurz]      ; kurzor
         mov       es:[AWinKurz],ax         ; kurzor

; ------ otev©en° okna menu

         call      far ptr InfoClos         ; uzav©en° informaán°ho ©†dku
         call      far ptr OpenMnu          ; otev©en° (a zobrazen°) okna menu

; ------ £schova kurzoru

FileSel2:call      far ptr NulBreak         ; nulov†n° p©°znaku p©eru®en°
         mov       ax,ds:[si+SMnuSeg]       ; segment okna
         call      far ptr GetDat           ; adresa okna -> ES
         mov       ax,es:[AWinFrst]         ; prvn° poloëka
         mov       ds:[si+SMnuFrst],ax      ; £schova prvn° poloëky
         mov       ax,es:[AWinKurz]         ; kurzor
         mov       ds:[si+SMnuKurz],ax      ; £schova kurzoru

; ------ zobrazen° kurzoru na aktu†ln° pozici, zobrazen° okna

         call      far ptr InfoClos         ; uzav©en° informaán°ho ©†dku
         call      far ptr DispMnu          ; zobrazen° okna
         call      far ptr KurzSMnu         ; zobrazen° kurzoru menu

; ------ vstup znaku z kl†vesnice -> BX

         call      far ptr InpChar          ; vstup znaku z kl†vesnice
         mov       di,offset SSMnSHlM       ; menu kl†ves malÇ n†povàdy
         call      far ptr MenKlHlp         ; obsluha menu kl†ves

; ------ korekce k¢du pro my®

         cmp       bh,MousXKod/HI           ; je k¢d my®i ?
         jne       FileSl22                 ; nen° k¢d my®i
         and       bl,not bit6              ; zru®en° p©°znaku druhÇho stisku
         call      far ptr MouseMnu         ; test, zda je okno menu
         jnc       FileSl22                 ; je v oknà menu - nen° p©eru®en°
         cmp       bl,MousXLP               ; je stisk levÇho tlaá°tka ?
         jne       FileSl21                 ; nen° stisk levÇho tlaá°tka
         mov       bl,MousXRP               ; n†hrada stiskem pravÇho tlaá°tka
FileSl21:cmp       bl,MousXLR               ; uvolnàn° levÇho tlaá°tka my®i ?
         je        FileSel2                 ; ë†dn† operace

; ------ skok na obsluhu kl†vesy

FileSl22:call      far ptr JumpBX

         dw        3c00h,FileSF2            ; F2 prototyp
         dw        3d00h,FileSF3            ; F3 zaloëen° textu
         dw        3e00h,FileSF4            ; F4 koment†©
         dw        3f00h,FileSF5            ; F5 kopie
;         dw        4000h,FileSF6            ; F6 p©ejmenov†n°
         dw        4100h,FileSF7            ; F7 zaloëen° skupiny
         dw        4200h,FileSF8            ; F8 zru®en° textu
         dw        4300h,FileSF9            ; F9 nadpis

         dw        1c0dh,FileSEnt           ; Enter
         dw        MousXKod+MousXLR,FileSEnt ; uvolnàn° levÇho tlaá°tka my®i
         dw        MousXKod+MousXRP,FileSel4 ; stisk pravÇho tlaá°tka my®i
         dw        11bh,FileSel4            ; Esc
         dw        0,FileSel3               ; jin† kl†vesa

; ------ jin† kl†vesa

FileSel3:call      far ptr EditSMnu         ; editace okna
         jmp       FileSel2                 ; dal®° kl†vesa

; ------ kl†vesa ESC

FileSel4:test      byte ptr ds:[WindPar],bit3 ; je rychlovyhled†v†n° ?
         jz        FileSel8                 ; nen° rychlovyhled†v†n°
         call      far ptr QSrcEnd          ; ukonáen° rychlovyhled†v†n°
         jmp       FileSel2                 ; dal®° kl†vesa + zobrazen° okna

; ------ zru®en° segmentu bufferu

FileSel8:stc                                ; p©°znak p©eru®en° operace
FileSl88:pushf
         push      si
         call      far ptr ClosMnu          ; uzav©en° okna
         pop       si
         popf
FileSel9:pushf
         call      far ptr ClosFSel         ; uzav©en° seznamu souborñ DS:SI
         mov       ax,ds:[SeznSegm]
         call      far ptr DelSeg           ; zru®en° bufferu
         mov       ds:[SeznSegm],ax         ; p©°znak zru®en°
         popf
         ret

FileSel  ENDP

; -----------------------------------------------------------------------------
;        Enter
; -----------------------------------------------------------------------------

; ------ ukonáen° rychlovyhled†v†n°

FileSEnt:call      far ptr QSrcEnd

; ------ z†kaz uchov†v†n° kurzoru v oknà

         mov       ax,ds:[si+SMnuSeg]       ; segment okna
         call      far ptr GetDat           ; adresa okna -> ES
         or        byte ptr es:[AWinPrm0],bit0 ; neuchov†vat kurzor

; ------ poskytnut° aktivn° poloëky

         call      far ptr AktPFSel         ; poskytnut° aktivn° poloëky
         jc        FileSEn7                 ; neplatn† poloëka

; ------ test, zda poloëka je adres†©

         test      byte ptr es:[di+FileAtr],DIR ; je to adres†© ?
         jz        FileSEn8                 ; nen° to adres†©

; ------ test, zda je to adres†© ".."

         cmp       word ptr es:[di+FileName],".." ; je to ".." ?
         jne       FileSEn6                 ; nen° to ".."

; ------ £schova textu z konce cesty

         push      ds
         pop       es                       ; ES <- datovò segment

         push      si
         mov       ax,ds:[si+SMnuPthN]      ; dÇlka textu cesty
         add       ax,ds:[si+SMnuPath]      ; adresa cesty
         xchg      ax,si                    ; SI <- adresa konce cesty
FileSEn5:dec       si
         cmp       byte ptr ds:[si],"\"
         jne       FileSEn5                 ; nalezen° konce cesty
         inc       si
         mov       di,offset SeznPthF       ; buffer k uloëen° jmÇna
         call      far ptr AsciFCB          ; £schova jmÇna seznamu
         pop       si

; ------ posun cesty o hladinu n°ëe

         call      far ptr SubFSel          ; sn°ëen° hladiny o adres†©
         jmp       FilSF382                 ; naáten° okna

; ------ p©id†n° adres†©e ES:DI pod kurzorem k cestà

FileSEn6:inc       di
         call      far ptr AddFFSel         ; p©id†n° jmÇna poloëky k cestà

; ------ naáten° seznamu souborñ

         call      far ptr ReadFSel         ; novÇ naáten° seznamu
FileSEn7:jmp       FileSel2

; ------ p©°prava jmÇna zvolenÇ poloëky do SRSMnPl4

FileSEn8:call      far ptr DekMFSel         ; dek¢dov†n° jmÇna poloëky do SRSMnPl4

; ------ p©°prava koment†©e k poloëce do bufferu LinBuff

         mov       byte ptr ds:[LinNum],0   ; nen° koment†©
         call      FileSF4K                 ; poskytnut° koment†©e
         jc        FilSEn86                 ; nen° koment†©

         cmp       cl,50                    ; maxim†ln° dÇlka koment†©e
         jbe       FilSEn84                 ; dÇlka je OK
         mov       cl,50                    ; omezen° dÇlky koment†©e
FilSEn84:mov       ds:[LinNum],cl           ; dÇlka koment†©e
         push      ds
         push      si

         mov       si,di                    ; SI <- offset koment†©e
         mov       di,offset LinBuff        ; buffer koment†©e
         push      ds
         push      es
         pop       ds                       ; DS <- segment koment†©e
         pop       es                       ; ES <- datovò segment
         cld
         rep       movsb                    ; uloëen° koment†©e do bufferu

         pop       si
         pop       ds

; ------ p©°prava specifikace zvolenÇ poloëky

FilSEn86:call      far ptr AktPFSel         ; poskytnut° aktivn° poloëky
         inc       di                       ; zaá†tek jmÇna poloëky
         call      far ptr AddFFSel         ; p©°prava pñvodn°ho jmÇna poloëky
         jc        FileSEn7                 ; p©eteáen° cesty
FileSEn9:clc                                ; p©°znak proveden° volby
         jmp       FileSl88

; -----------------------------------------------------------------------------
;        F2 prototyp
; -----------------------------------------------------------------------------

; ------ ukonáen° rychlovyhled†v†n°

FileSF2: call      far ptr QSrcEnd          ; ukonáen° rychlovyhled†v†n°

; ------ sestaven° jmÇna prototypu

         push      ds
         pop       es                       ; ES <- datovò segment
         mov       di,offset SeznProt       ; jmÇno prototypu
         mov       cl,offset(SeznPrt0-SeznProt) ; dÇlka textu
         call      far ptr AddAFSel         ; p©id†n° jmÇna souboru k cestà
         jc        FileSF29                 ; p©eteáen° cesty

; ------ test, zda prototyp jië existuje

         push      si
         mov       si,ds:[si+SMnuPath]      ; jmÇno souboru
         call      far ptr ExisFile         ; test souboru
         pop       si
         jnc       FileSF26                 ; soubor existuje OK

; ------ vytvo©en° prototypu

         push      si
         mov       si,ds:[si+SMnuPath]      ; jmÇno souboru
         call      far ptr CreatFil         ; vytvo©en° souboru
         jc        FileSF24                 ; chyba
         pushf
         call      far ptr ModiWDir         ; aktualizace obsahñ oken
         popf
FileSF24:pop       si
         jc        FileSF29                 ; chyba

;; ------ test, zda je DBF
;
;         cmp       word ptr ds:[si+SMnuExt],"BD" ; je to DBF ?
;         jne       FileSF26                 ; nen° to DBF
;
;; ------ pro DBF soubor uloëen° implicitn°ho obsahu (zde je DS=ES !)
;
;         push      si
;         mov       si,offset DBVzorS
;         mov       cx,offset(DBVzorS0-DBVzorS)
;         call      far ptr WritFile         ; z†pis z†hlav°
;         pop       si

; ------ uzav©en° vòstupn°ho souboru

FileSF26:call      far ptr ClosFile         ; uzav©en° souboru
         mov       byte ptr ds:[LinNum],0   ; nen° koment†©e
         push      si
         mov       cx,8
         mov       di,offset SRSMnPl4+1
         mov       ds:[di-1],cl             ; dÇlka textu
         mov       si,offset SeznProt       ; text "PROTOTYP"
         cld
         rep       movsb                    ; p©enos textu
         pop       si
         jmp       short FileSEn9           ; editace prototypu

FileSF29:jmp       FileSel2

; -----------------------------------------------------------------------------
;        F3 nov† poloëka
; -----------------------------------------------------------------------------

; ------ ukonáen° rychlovyhled†v†n°

FileSF3: call      far ptr QSrcEnd          ; ukonáen° rychlovyhled†v†n°

; ------ zad†n° jmÇna novÇ poloëky

         push      si
         cmp       word ptr ds:[si+SMnuExt],"AT" ; tabulka ?
         mov       si,offset SFSMnLin
         jne       FileSF30                 ; nen° tabulka
         mov       si,offset TBSMnLin
FileSF30:call      far ptr Lin0Menu         ; volba jmÇna seznamu
         pop       si
         jc        FileSF31                 ; p©eru®en° operace

; ------ normalizace jmÇna -> ES:DI/CX

         push      si
         call      far ptr NormFilL         ; normalizace jmÇna souboru
         mov       di,si                    ; DI <- zadanò text
         pop       si
         jcxz      FileSF31                 ; nebylo nic zad†no

; ------ hl†®en° o vytv†©en° (pouë°v† text v bufferu LinBuff)

         push      si
         mov       si,offset SSSMnHls       ; text hl†®en°
         call      far ptr InfDisp0         ; zobrazen° hl†®en°
         pop       si

; ------ p©id†n° p©°pony (do bufferu LinBuff)

         call      far ptr AExtFSel         ; p©id†n° implicitn° p©°pony

; ------ p©id†n° jmÇna souboru ES:DI/CX k cestà

         call      far ptr AddAFSel         ; p©id†n° jmÇna souboru k cestà

; ------ £schova jmÇna poloëky pro nastaven° kurzoru (ES=DS !)

         push      si
         mov       si,offset LinBuff        ; zadanÇ jmÇno souboru
         mov       di,offset SeznPthF       ; buffer k uloëen° jmÇna
         call      far ptr AsciFCB          ; £schova jmÇna seznamu
         pop       si

; ------ test, zda soubor jië existuje

         push      si
         mov       si,ds:[si+SMnuPath]      ; specifikace souboru
         call      far ptr ExisFile         ; test souboru
         pop       si
         jc        FileSF32                 ; soubor neexistuje

; ------ hl†®en° - soubor jië existuje

         call      far ptr SubFSel          ; zru®en° jmÇna z cesty
         mov       di,offset SF3MnLin
         call      far ptr Lin0MenP         ; chybovÇ hl†®en°
FileSF31:jmp       FileSF39

; ------ vytvo©en° souboru -> DX=identifik†tor

FileSF32:push      si
         mov       si,ds:[si+SMnuPath]      ; specifikace souboru
         call      far ptr CreatFil         ; vytvo©en° souboru

; ------ aktualizace oken

         pushf
         jc        FilSF322
         call      far ptr ModiWDir         ; aktualizace obsahñ oken
FilSF322:popf
         pop       si
         xchg      ax,dx                    ; DX <- identifik†tor

; ------ n†vrat konce cesty

         call      far ptr SubFSel          ; zru®en° jmÇna z cesty
         jc        FileSF31                 ; chyba - nelze vytvo©it

; ------ sestaven° jmÇna prototypu

         mov       di,offset SeznProt       ; jmÇno prototypu
         mov       cl,offset(SeznPrt0-SeznProt) ; dÇlka textu
         call      far ptr AddAFSel         ; p©id†n° jmÇna souboru k cestà
         jc        FileSF36                 ; p©eteáen° bufferu

; ------ otev©en° souboru prototypu -> AX

         push      si
         mov       si,ds:[si+SMnuPath]      ; specifikace souboru
         call      far ptr OpenR            ; otev©en° souboru prototypu
         pop       si

; ------ zru®en° jmÇna prototypu z cesty

         call      far ptr SubFSel          ; zru®en° jmÇna z cesty
         jc        FileSF36                 ; soubor prototypu nenalezen

; ------ vytvo©en° datovÇho bufferu

         call      FileSBuf                 ; vytvo©en° bufferu
         jc        FileSF34                 ; chyba pamàti

; ------ naáten° bloku dat ze souboru prototypu

FileSF33:xor       di,di                    ; DI <- ukl†dac° adresa
         mov       cx,ds:[SeznSegN]         ; velikost bufferu
         call      far ptr ReadFile         ; naáten° dat
         jcxz      FileSF34                 ; chyba nebo konec souboru

; ------ z†pis dat do vòstupn°ho souboru

         push      si
         xor       si,si                    ; SI <- 0 átec° adresa
         xchg      ax,dx                    ; AX <- identifik†tor souboru
         call      far ptr WritFile         ; z†pis dat
         xchg      ax,dx
         pop       si
         jnc       FileSF33                 ; dal®° blok dat

; ------ uzav©en° souboru prototypu

FileSF34:call      far ptr ClosFile         ; uzav©en° souboru prototypu
         jmp       short FileSF38

; ------ test, zda to je soubor DBF

FileSF36:
;         cmp       word ptr ds:[si+SMnuExt],"BD" ; je to DBF ?
;         jne       FileSF38                 ; nen° to DBF
;
;; ------ pro DBF soubor uloëen° implicitn°ho obsahu (zde je DS=ES !)
;
;         xchg      ax,dx
;         push      si
;         mov       si,offset DBVzorS
;         mov       cx,offset(DBVzorS0-DBVzorS)
;         call      far ptr WritFile         ; z†pis z†hlav°
;         pop       si
;         xchg      ax,dx

; ------ uzav©en° vòstupn°ho souboru

FileSF38:xchg      ax,dx                    ; AX <- identifik†tor
         call      far ptr ClosFile         ; uzav©en° souboru

; ------ obnoven° seznamu souborñ (sem se sk†áe z F5 a z F7 !)

FilSF382:call      far ptr NulBreak         ; nulov†n° p©°padnÇho p©eru®en°
         call      far ptr ReadFSel         ; novÇ naáten° seznamu

; ------ nalezen° vytvo©enÇ poloëky v oknà

         push      ds
         pop       es                       ; ES <- datovò segment
         push      si
         mov       ax,ds:[si+SMnuSeg]       ; segment okna
         mov       si,offset SeznPthF-FileName ; hledan† poloëka
         call      far ptr SrcWNam          ; nalezen° poloëky v oknà AX
         pop       si
         jc        FileSF39                 ; poloëka nenalezena

; ------ nastaven° kurzoru na nalezenou poloëku BX

         call      far ptr GetDat           ; adresa okna
         mov       es:[AWinKurz],bx         ; novò kurzor

FileSF39:jmp       FileSel2

; -----------------------------------------------------------------------------
;        F4 koment†©
; -----------------------------------------------------------------------------

; ------ ukonáen° rychlovyhled†v†n°

FileSF4: call      far ptr QSrcEnd          ; ukonáen° rychlovyhled†v†n°

; ------ p©°prava jmÇna poloëky

         call      far ptr DekMFSel         ; dek¢dov†n° jmÇna poloëky
         jc        FileSF49                 ; nen° ë†dn† poloëka

; ------ p©°prava koment†©e poloëky jako p©edvolba

         mov       byte ptr ds:[SKSMnPN1],0 ; nen° p©edvolba
         call      FileSF4K                 ; poskytnut° koment†©e
         jc        FileSF44                 ; koment†©e nejsou
         mov       word ptr ds:[SKSMnPA1],di ; offset koment†©e
         mov       word ptr ds:[SKSMnPA1+2],es ; segment koment†©e
         mov       byte ptr ds:[SKSMnPD1],cl ; dÇlka koment†©e
         inc       byte ptr ds:[SKSMnPN1]   ; 1 p©edvolba

; ------ zad†n° novÇho koment†©e poloëky

FileSF44:push      si
         mov       si,offset SKSMnLin
         call      far ptr Lin0Menu         ; zad†n° novÇho koment†©e
         pop       si
         jc        FileSF49                 ; p©eru®en° operace

; ------ uloëen° zadanÇho koment†©e

         mov       ax,ds:[si+SMnuSeg]       ; segment okna
         call      far ptr StorFKom         ; uloëen° zadanÇho koment†©e
FileSF49:jmp       FileSel2

; -----------------------------------------------------------------------------
;        poskytnut° koment†©e k aktivn° poloëce -> ES:DI/CX (CY=nen°)
; -----------------------------------------------------------------------------

FileSF4K PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      dx

; ------ adresa okna

         mov       ax,ds:[si+SMnuSeg]       ; okno
         call      far ptr GetDat           ; adresa okna
         mov       dx,es:[AWinKomS]         ; DX <- segment koment†©ñ

; ------ offset koment†©e

         mov       di,es:[AWinKurz]         ; kurzor
         shl       di,1                     ; offset poloëky
         add       di,word ptr es:[AWinKomI] ; adresa indexu koment†©e
         mov       ax,es
         add       ax,word ptr es:[AWinKomI+2]
         mov       es,ax                    ; segment indexu koment†©e
         mov       di,es:[di]               ; adresa koment†©e
         or        di,di                    ; je koment†© definov†n ?
         stc                                ; p©°znak chyby
         jz        FilSF4K6                 ; koment†© nen° definov†n

; ------ segment koment†©ñ

         xchg      ax,dx                    ; AX <- segment koment†©ñ
         call      far ptr GetDat           ; adresa koment†©ñ
         jc        FilSF4K6                 ; koment†©e nejsou

; ------ p©°prava dÇlky koment†©e

         push      di
         xor       cx,cx                    ; á°taá dÇlky
         dec       cx
         dec       di
FilSF4K2:inc       di
         inc       cx
         cmp       es:[di],ch               ; konec ?
         jne       FilSF4K2                 ; nalezen° konce textu
         pop       di

; ------ test, zda je dÇlka koment†©e = 0

         stc                                ; p©°znak chyby
         jcxz      FilSF4K6                 ; koment†© nen°
         clc                                ; p©°znak - koment†© je OK

; ------ n†vrat registrñ

FilSF4K6:pop       dx
         pop       ax
         ret

FileSF4K ENDP

; -----------------------------------------------------------------------------
;        F5 - kopie (nekop°ruje se PFT !)
; -----------------------------------------------------------------------------

; ------ ukonáen° rychlovyhled†v†n°

FileSF5: call      far ptr QSrcEnd          ; ukonáen° rychlovyhled†v†n°

; ------ test poloëky, zda to nen° adres†© nebo ".."

         call      far ptr AktPFSel         ; poskytnut° aktivn° poloëky
         test      byte ptr es:[di+FileAtr],DIR ; je to adres†© (nap©. "..") ?
         jz        FileSF51                 ; nen° to adres†©
FileSF50:jmp       FileSF59

; ------ p©°prava jmÇna poloëky do bufferu SRSMnPl4 (pro hl†®en°)

FileSF51:call      far ptr DekMFSel         ; dek¢dov†n° jmÇna poloëky
         jc        FileSF50                 ; nen° ë†dn† poloëka

; ------ zad†n° novÇho jmÇna poloëky

         push      si
         mov       si,offset SNSMnLin
         call      far ptr Lin0Menu         ; zad†n° c°lovÇho jmÇna
         pop       si
         jc        FileSF50                 ; p©eru®en° operace

; ------ p©°prava specifikace poloëky

         call      far ptr AktPFSel         ; poskytnut° aktivn° poloëky
         inc       di                       ; zaá†tek jmÇna poloëky
         call      far ptr AddFFSel         ; p©°prava pñvodn°ho jmÇna poloëky
         jc        FileSF50                 ; p©eteáen° cesty

; ------ hl†®en° o kop°rov†n°

         push      si
         mov       si,offset SNSMnHls       ; text hl†®en°
         call      far ptr InfDisp0         ; zobrazen° hl†®en°
         pop       si

; ------ otev©en° zdrojovÇho souboru -> DX

         push      si
         mov       si,ds:[si+SMnuPath]      ; specifikace souboru
         push      ds
         pop       es                       ; ES <- datovò segment
         call      far ptr OpenR            ; otev©en° zdrojovÇho souboru
         pop       si
         xchg      ax,dx                    ; DX <- ident. zdrojovÇho souboru

; ------ zru®en° jmÇna z cesty

         call      far ptr SubFSel          ; zru®en° jmÇna z cesty
         jc        FileSF50                 ; nàjak† chyba, nelze otev©°t

; ------ normalizace jmÇna zadanÇho c°lovÇho souboru -> ES:DI/CX

         push      si
         call      far ptr NormFilL         ; normalizace jmÇna souboru
         mov       di,si                    ; DI <- zadanò text
         pop       si
         jcxz      FileSF52                 ; nebylo nic zad†no

; ------ p©id†n° p©°pony (do bufferu LinBuff)

         call      far ptr AExtFSel         ; p©id†n° implicitn° p©°pony

; ------ p©id†n° jmÇna souboru ES:DI/CX k cestà

         call      far ptr AddAFSel         ; p©id†n° jmÇna souboru k cestà

; ------ £schova jmÇna poloëky pro nastaven° kurzoru (ES=DS !)

         push      si
         mov       si,offset LinBuff        ; zadanÇ jmÇno souboru
         mov       di,offset SeznPthF       ; buffer k uloëen° jmÇna
         call      far ptr AsciFCB          ; £schova jmÇna seznamu
         pop       si

; ------ test, zda soubor jië existuje

         push      si
         mov       si,ds:[si+SMnuPath]      ; specifikace souboru
         call      far ptr ExisFile         ; test souboru
         pop       si
         jc        FileSF53                 ; soubor neexistuje

; ------ hl†®en° - soubor jië existuje

         call      far ptr SubFSel          ; zru®en° jmÇna z cesty
         mov       di,offset SF3MnLin       ; hl†®en° - jië existuje
         call      far ptr Lin0MenP         ; chybovÇ hl†®en°
FileSF52:jmp       short FileSF58

; ------ vytvo©en° c°lovÇho souboru -> AX=identifik†tor

FileSF53:push      si
         mov       si,ds:[si+SMnuPath]      ; specifikace souboru
         call      far ptr CreatFil         ; vytvo©en° souboru
         pushf
         jc        FilSF532                 ; chyba - nevytvo©en
         call      far ptr ModiWDir         ; aktualizace obsahñ oken
FilSF532:popf
         pop       si
         jc        FilSF578                 ; chyba - nelze vytvo©it

; ------ vytvo©en° datovÇho bufferu

         call      FileSBuf                 ; vytvo©en° bufferu
         jc        FileSF55                 ; chyba pamàti

; ------ naáten° bloku dat ze souboru prototypu

FileSF54:xor       di,di                    ; DI <- ukl†dac° adresa
         mov       cx,ds:[SeznSegN]         ; velikost bufferu
         xchg      ax,dx                    ; AX <- identifik†tor souboru
         call      far ptr ReadFile         ; naáten° dat
         xchg      ax,dx
         jc        FileSF55                 ; chyba
         jcxz      FileSF57                 ; konec souboru

; ------ z†pis dat do vòstupn°ho souboru

         push      si
         xor       si,si                    ; SI <- 0 átec° adresa
         call      far ptr WritFile         ; z†pis dat
         pop       si
         jnc       FileSF54                 ; dal®° blok dat

; ------ chyba z†pisu (nastaven CY)

FileSF55:mov       di,offset EURMnLin       ; text hl†®en° (z modulu EDI !)
         call      far ptr Lin0MenP         ; chybovÇ hl†®en°

; ------ uzav©en° vòstupn°ho souboru AX

FileSF57:pushf
         call      far ptr ClosFile         ; uzav©en° souboru prototypu
         popf
         jnc       FilSF578                 ; operace OK

; ------ p©i chybà zru®en° vòstupn°ho souboru

         push      si
         mov       si,ds:[si+SMnuPath]      ; specifikace souboru
         call      far ptr DelFile          ; zru®en° vòstupn°ho souboru
         pop       si
         stc                                ; p©°znak chyby operace

; ------ n†vrat konce cesty

FilSF578:call      far ptr SubFSel          ; zru®en° jmÇna z cesty

; ------ uzav©en° zdrojovÇho souboru DX

FileSF58:xchg      ax,dx                    ; AX <- identifik†tor
         call      far ptr ClosFile         ; uzav©en° souboru
         jmp       FilSF382                 ; uzav©en° souboru, naáten° okna

FileSF59:jmp       FileSel2

; -----------------------------------------------------------------------------
;        F7 - vytvo©en° skupiny
; -----------------------------------------------------------------------------

; ------ ukonáen° rychlovyhled†v†n°

FileSF7: call      far ptr QSrcEnd          ; ukonáen° rychlovyhled†v†n°

; ------ zad†n° jmÇna novÇ skupiny

         push      si
         mov       si,offset SSSMnLin
         call      far ptr Lin0Menu         ; volba jmÇna skupiny
         pop       si
         jnc       FileSF71
FileSF70:jmp       FileSF79                 ; p©eru®en° operace

; ------ normalizace jmÇna -> ES:DI/CX

FileSF71:push      si
         call      far ptr NormFilL         ; normalizace jmÇna adres†©e
         mov       di,si                    ; DI <- zadanò text
         pop       si
         jcxz      FileSF70                 ; nebylo nic zad†no

; ------ hl†®en° o vytv†©en°

         push      si
         mov       si,offset SSSMnHls
         call      far ptr InfDisp0         ; zobrazen° hl†®en°
         pop       si

; ------ p©id†n° jmÇna adres†©e ES:DI k cestà

         call      far ptr AddAFSel         ; p©id†n° jmÇna adres†©e k cestà
         jc        FileSF70                 ; p©eteáen° dÇlky cesty

; ------ £schova jmÇna adres†©e pro nastaven° kurzoru (ES=DS !)

         push      si
         mov       si,offset LinBuff        ; zadanÇ jmÇno souboru
         mov       di,offset SeznPthF       ; buffer k uloëen° jmÇna
         call      far ptr AsciFCB          ; £schova jmÇna seznamu
         pop       si

; ------ vytvo©en° adres†©e (adres†©ov† okna se aktualizuj°)

         push      si
         mov       si,ds:[si+SMnuPath]      ; specifikace souboru
         call      far ptr CreatDir         ; vytvo©en° adres†©e
         pop       si

; ------ n†vrat konce cesty

         call      far ptr SubFSel          ; zru®en° adres†©e z cesty
         jc        FileSF78                 ; chyba

; ------ sestaven° jmÇna prototypu

         mov       di,offset SeznProt       ; jmÇno prototypu
         mov       cl,offset(SeznPrt0-SeznProt) ; dÇlka textu
         call      far ptr AddAFSel         ; p©id†n° jmÇna souboru k cestà
         jc        FileSF77                 ; p©eteáen° cesty

; ------ otev©en° prototypu -> DX

         push      si
         mov       si,ds:[si+SMnuPath]      ; specifikace souboru
         call      far ptr OpenR            ; otev©en° souboru prototypu
         pop       si
         xchg      ax,dx                    ; DX <- identifik†tor

; ------ zru®en° textu prototypu

         call      far ptr SubFSel          ; zru®en° adres†©e z cesty
         jc        FileSF77                 ; soubor nenalezen

; ------ p©id†n° jmÇna adres†©e k cestà

         mov       cl,ds:[LinNum]           ; dÇlka textu
         mov       di,offset LinBuff        ; buffer jmÇna adres†©e
         call      far ptr AddAFSel         ; p©id†n° jmÇna adres†©e k cestà
         jc        FileSF76                 ; p©eteáen° dÇlky cesty

; ------ sestaven° jmÇna prototypu

         mov       di,offset SeznProt       ; jmÇno prototypu
         mov       cl,offset(SeznPrt0-SeznProt) ; dÇlka textu
         call      far ptr AddAFSel         ; p©id†n° jmÇna souboru k cestà
         jc        FileSF75                 ; p©eteáen° cesty

; ------ vytvo©en° souboru prototypu -> AX

         push      si
         mov       si,ds:[si+SMnuPath]      ; specifikace souboru
         call      far ptr CreatFil         ; vytvo©en° souboru prototypu
         pop       si

; ------ zru®en° jmÇna prototypu

         call      far ptr SubFSel          ; zru®en° jmÇna prototypu
         jc        FileSF75                 ; chyba

; ------ vytvo©en° datovÇho bufferu

         call      FileSBuf                 ; vytvo©en° bufferu
         jc        FileSF74                 ; chyba pamàti

; ------ naáten° bloku dat ze souboru prototypu

FileSF73:xor       di,di                    ; DI <- ukl†dac° adresa
         mov       cx,ds:[SeznSegN]         ; velikost bufferu
         xchg      ax,dx                    ; AX <- identifik†tor souboru
         call      far ptr ReadFile         ; naáten° dat
         xchg      ax,dx
         jcxz      FileSF74                 ; chyba nebo konec souboru

; ------ z†pis dat do vòstupn°ho souboru

         push      si
         xor       si,si                    ; SI <- 0 átec° adresa
         call      far ptr WritFile         ; z†pis dat
         pop       si
         jnc       FileSF73                 ; dal®° blok dat

; ------ uzav©en° vòstupn°ho souboru prototypu

FileSF74:call      far ptr ClosFile         ; uzav©en° souboru prototypu

; ------ zru®en° jmÇna adres†©e z cesty

FileSF75:call      far ptr SubFSel          ; zru®en° jmÇna adres†©e

; ------ uzav©en° zdrojovÇho souboru prototypu

FileSF76:xchg      ax,dx                    ; AX <- identifik†tor
         call      far ptr ClosFile         ; uzav©en° zdrojovÇho souboru

FileSF77:jmp       FilSF382                 ; aktualizace seznamu

; ------ hl†®en° chyby - nelze vytvo©it

FileSF78:mov       di,offset SS2MnLin       ; hl†®en° - nelze vytvo©it
         call      far ptr Lin0MenP         ; chybovÇ hl†®en°

FileSF79:jmp       FileSel2

; -----------------------------------------------------------------------------
;        F8 - zru®en° poloëky
; -----------------------------------------------------------------------------

; ------ ukonáen° rychlovyhled†v†n°

FileSF8: call      far ptr QSrcEnd          ; ukonáen° rychlovyhled†v†n°

; ------ aktivn° poloëka

         call      far ptr AktPFSel         ; poskytnut° aktivn° poloëky
         jnc       FileSF81                 ; je nàjak† poloëka OK
FileSF80:jmp       FileSF89                 ; p©i chybà n†vrat

; ------ poloëka ".." se neru®°

FileSF81:cmp       word ptr es:[di+FileName],".." ; je poloëka ".." ?
         je        FileSF80                 ; nen° to platn† poloëka

; ------ p©°prava textu pro hl†®en° 2

         mov       word ptr ds:[SRSMnPl1],offset SeznTx1X ; je to soubor
         mov       word ptr ds:[SR1MnPl1],offset SeznTx1X ; seznam/text
         cmp       word ptr ds:[si+SMnuExt],"AT" ; tabulka ?
         jne       FilSF812                 ; nen° tabulka
         mov       word ptr ds:[SRSMnPl1],offset SeznTx2X ; "tabulku"
         mov       word ptr ds:[SR1MnPl1],offset SeznTx2X ; tabulku

FilSF812:test      byte ptr es:[di+FileAtr],DIR ; je to soubor ?
         jz        FileSF82                 ; je to soubor
         mov       word ptr ds:[SRSMnPl1],offset SRSMnPl3 ; je to adres†©

; ------ dek¢dov†n° jmÇna poloëky

FileSF82:call      far ptr DekMFSel         ; dek¢dov†n° jmÇna poloëky

; ------ hl†®en° 1

         test      byte ptr es:[di+FileAtr],DIR ; je to adres†© ?
         jnz       FileSF83                 ; je to adres†© - jen 1 hl†®en°

         push      si
         mov       si,offset SR1MnLin
         call      far ptr Lin0MenF         ; potvrzen° operace
         pop       si
         jc        FileSF80                 ; p©eru®en°

; ------ hl†®en° 2

FileSF83:push      si
         mov       si,offset SRSMnLin
         call      far ptr Lin0MenF
         pop       si
         jc        FileSF80                 ; p©eru®en°

; ------ hl†®en° o ru®en°

         push      si
         mov       si,offset SRSMnHls
         call      far ptr InfDisp0         ; zobrazen° hl†®en°
         pop       si

; ------ p©°prava jmÇna souboru

         call      far ptr AktPFSel         ; poskytnut° aktivn° poloëky->ES:DI
         mov       al,es:[di+FileAtr]       ; atributy
         inc       di                       ; zaá†tek jmÇna poloëky
         call      far ptr AddFFSel         ; p©id†n° jmÇna poloëky k cestà
         jc        FileSF80

; ------ rozli®en°, zda je ru®en° souboru

         push      ds
         pop       es                       ; ES <- datovò segment
         test      al,DIR                   ; je to adres†© ?
         jnz       FileSF85                 ; je to adres†©

; ------ zru®en° souboru

         call      FilDSF84                 ; zru®en° souboru
         jc        FilSF838                 ; chyba

; ------ zru®en° souboru PFT

         cmp       word ptr ds:[si+SMnuExt],"BD" ; je soubor DBF ?
         jne       FilSF836                 ; nen° DBF
         call      far ptr AktPFSel         ; poskytnut° aktivn° poloëky->ES:DI
         inc       di                       ; zaá†tek jmÇna poloëky
         call      far ptr AddFFSel         ; p©id†n° jmÇna poloëky k cestà
         jc        FilSF836
         mov       di,ds:[si+SMnuPath]      ; adresa cesty
         add       di,ds:[si+SMnuPthN]      ; konec cesty
         mov       word ptr ds:[di-3],"PF"
         mov       byte ptr ds:[di-1],"T"
         call      FilDSF84                 ; zru®en° souboru
FilSF836:jmp       FilSF888                 ; novÇ naáten° okna

; ------ chyba - soubor nelze zru®it

FilSF838:mov       di,offset SR3MnLin       ; menu - text nelze zru®it
         call      far ptr Lin0MenP         ; hl†®en° - nelze zru®it
         jmp       FileSF89

; ------ test, zda existuje podadres†©

FileSF85:mov       di,offset All            ; text "*.*"
         mov       cl,3                     ; dÇlka
         call      FilXSF82                 ; test adres†©e
FilSF852:jc        FileSF86                 ; nic nenalezeno
         cmp       byte ptr ds:[BuffDTA+DTAName],"."
         je        FilSF854                 ; systÇmovò adres†©
         test      byte ptr ds:[BuffDTA+DTAAtrib],DIR ; nalezen adres†© ?
         jnz       FilSF866                 ; chyba
FilSF854:call      far ptr SrcNext          ; dal®° soubor
         je        FilSF852                 ; nàco nalezeno

; ------ test, zda existuje platnò soubor

FileSF86:mov       ax,ds:[si+SMnuExt]
         mov       word ptr ds:[SeznExtF+2],ax
         mov       al,ds:[si+SMnuExt+2]
         mov       ds:[SeznExtF+4],al
         mov       di,offset SeznExtF
         mov       cl,5
         call      FilXSF82                 ; test souboru
         jc        FileSF88                 ; nic nenalezeno

; ------ chyba - adres†© nen° pr†zdnò

FilSF866:call      far ptr SubFSel          ; zru®en° jmÇna adres†©e z cesty
FileSF87:mov       di,offset SR2MnLin
         call      far ptr Lin0MenP         ; hl†®en° - nelze zru®it
         jmp       short FileSF89

; ------ zru®en° souboru FILEINFO v podadres†©i

FileSF88:mov       di,offset FileInfo       ; text "FILEINFO"
         mov       cl,8                     ; dÇlka textu
         call      FilDSF82                 ; zru®en° souboru FILEINFO

; ------ zru®en° souboru PROTOTYP.$$$ v podadres†©i

         mov       di,offset SeznProt       ; jmÇno prototypu
         mov       cl,offset(SeznPrt0-SeznProt) ; dÇlka textu
         call      FilDSF82                 ; zru®en° souboru prototypu

; ------ zru®en° adres†©e

         call      FilDSF81                 ; zru®en° adres†©e
         jc        FileSF87                 ; chyba

; ------ novÇ naáten° okna

FilSF888:call      far ptr ReadFSel         ; novÇ naáten° seznamu
FileSF89:jmp       FileSel2

; -----------------------------------------------------------------------------
;        test existence souboru SMNUPATH
; -----------------------------------------------------------------------------

FilXSF82:call      far ptr AddAFSel         ; p©id†n° textu
         jc        FilXSF88                 ; p©eteáen° cesty
         push      si
         mov       si,ds:[si+SMnuPath]      ; specifikace souboru
         call      far ptr ExisFile         ; test adres†©e
         pop       si
         call      far ptr SubFSel          ; zru®en° textu
FilXSF88:ret

; -----------------------------------------------------------------------------
;        zru®en° souboru/adres†©e v SMNUPATH
; -----------------------------------------------------------------------------

; ------ zru®en° adres†©e

FilDSF81:push      si
         mov       si,ds:[si+SMnuPath]      ; specifikace souboru
         call      far ptr DelDir           ; zru®en° adres†©e
         jmp       short FilDSF85

; ------ zru®en° souboru

FilDSF82:call      far ptr AddAFSel         ; p©id†n° jmÇna souboru k cestà
         jc        FilDSF88                 ; p©eteáen° cesty
FilDSF84:push      si
         mov       si,ds:[si+SMnuPath]      ; specifikace souboru
         push      ds
         pop       es
         call      far ptr DelFile          ; zru®en° souboru
FilDSF85:jc        FilDSF86                 ; soubor nenalezen
         call      far ptr ModiWDir         ; aktualizace obsahñ oken
         clc
FilDSF86:pop       si
         call      far ptr SubFSel          ; zru®en° jmÇna
FilDSF88:ret

; -----------------------------------------------------------------------------
;        F9 - nadpis seznamu
; -----------------------------------------------------------------------------

; ------ ukonáen° rychlovyhled†v†n°

FileSF9: call      far ptr QSrcEnd          ; ukonáen° rychlovyhled†v†n°

; ------ p©°prava koment†©e nadpisu pro p©edvolbu

         mov       ax,ds:[si+SMnuSeg]       ; okno
         call      far ptr GetDat           ; adresa okna
         mov       di,es:[AWinKomA]         ; adresa nadpisu
         mov       cx,es:[AWinKomD]         ; dÇlka nadpisu
         mov       byte ptr ds:[SASMnPN1],0 ; nen° p©edvolba
         jcxz      FileSF92                 ; koment†© nen° definov†n
         inc       byte ptr ds:[SASMnPN1]   ; 1 p©edvolba
         mov       word ptr ds:[SASMnPA1],di; offset koment†©e
         mov       ds:[SASMnPD1],cx         ; dÇlka nadpisu
         mov       ax,es:[AWinKomS]         ; segment koment†©ñ
         call      far ptr GetDat           ; adresa koment†©ñ -> ES
         mov       word ptr ds:[SASMnPA1+2],es ; segment koment†©ñ

; ------ zad†n° novÇho koment†©e poloëky

FileSF92:push      si
         mov       si,offset SASMnLin
         call      far ptr Lin0Menu         ; zad†n° novÇho koment†©e
         pop       si
         jc        FileSF99                 ; p©eru®en° operace

; ------ uloëen° zadanÇho nadpisu

         mov       ax,ds:[si+SMnuSeg]       ; segment okna
         call      far ptr StorNKom         ; uloëen° zadanÇho koment†©e
FileSF99:jmp       FileSel2

; -----------------------------------------------------------------------------
;        vytvo©en° pracovn°ho bufferu pro seznam -> ES (CY=chyba pamàti)
; -----------------------------------------------------------------------------

FileSBuf PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx

; ------ test, zda je buffer jië vytvo©en

         mov       ax,ds:[SeznSegm]         ; segment
         or        ax,ax                    ; je jië vytvo©en ?
         jnz       FileSBf4                 ; je jië vytvo©en

; ------ vytvo©en° bufferu

         mov       bx,1000                  ; asi tak velikost
         call      far ptr CreatDat
         jc        FileSBf8                 ; chyba
         mov       ds:[SeznSegm],ax         ; á°slo segmentu
         mov       ds:[SeznSegN],bx         ; velikost bufferu

; ------ adresa bufferu

FileSBf4:call      far ptr GetDat           ; adresa bufferu

; ------ n†vrat registrñ

FileSBf8:pop       bx
         pop       ax
         ret

FileSBuf ENDP

; *****************************************************************************
;                                InitFSel
;            vytvo©en° a inicializace seznamu souborñ k vòbàru
; -----------------------------------------------------------------------------
; VSTUP: SI=menu vòbàru souborñ
;        DS=datovò segment
; VùSTUP:CY=nedostatek pamàti, okno nevytvo©eno
; *****************************************************************************

InitFSel PROC      FAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      di
         push      es

; ------ vytvo©en° segmentu okna -> AX

         call      far ptr CreatAWn         ; vytvo©en° definice okna
         jc        InitFSl9                 ; chyba pamàti
         mov       ds:[si+SMnuSeg],ax       ; segment okna

; ------ inicializace parametrñ okna

         mov       cx,5
         mov       es:[AWinFilF.AWinFilN],cx ; dÇlka filtru souborñ
         mov       es:[AWinFilM],cl         ; dÇlka prvn° masky filtru
         mov       byte ptr es:[AWinPrm2],2*bit5 ; form†t - komentovanÇ okno
         mov       byte ptr es:[AWinFilP],bit0+bit2+bit7 ; maska
         mov       byte ptr es:[AWinFilF.AWinFAtM],SYS+HID ; SYS a HID = 0

; ------ sestaven° filtru pro vòbàr souborñ

         cld
         mov       di,AWinFilF.AWinFilt     ; adresa filtru souborñ
         push      ax
         mov       ax,".*"                  ; zaá†tek filtru
         stosw                              ; prvn° 2 znaky filtru
         mov       ax,ds:[si+SMnuExt]       ; prvn° 2 znaky p©°pony
         stosw
         mov       al,ds:[si+SMnuExt+2]     ; posledn° znak p©°pony
         stosb
         pop       ax

; ------ p©enesen° textu adres†©e

         call      far ptr SPthFSel         ; kopie textu adres†©e

; ------ naáten° souborñ do seznamu

         call      far ptr ReadDir          ; naáten° seznamu souborñ
         clc                                ; p©°znak operace OK

; ------ n†vrat registrñ

InitFSl9:pop       es
         pop       di
         pop       cx
         pop       ax
         ret

InitFSel  ENDP

; -----------------------------------------------------------------------------
;        dek¢dov†n° jmÇna aktivn° poloëky do bufferu hl†®en° (CY=nen° poloëka)
; -----------------------------------------------------------------------------

DekMFSel PROC      FAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      si
         push      di
         push      es

; ------ aktivn° poloëka -> ES:DI

         call      far ptr AktPFSel         ; poskytnut° aktivn° poloëky
         mov       al,0                     ; dÇlka textu = 0
         jc        DekMFSl4                 ; nen° ë†dn† poloëka

; ------ dek¢dov†n° jmÇna poloëky

         push      ds

         mov       si,di                    ; SI <- poloëka
         inc       si                       ; zaá†tek jmÇna poloëky
         push      ds
         push      es
         pop       ds                       ; DS <- segment poloëky
         pop       es                       ; ES <- datovò segment

         mov       di,offset SRSMnPl4+1     ; buffer k dek¢dov†n° poloëky
         mov       cx,8                     ; dÇlka jmÇna
         cld

         cmp       word ptr ds:[si],".."    ; je to nadadres†© ?
         jne       DekMFSl1                 ; nen° to nadadres†©

         mov       al,4                     ; n†hradn° znak pro adres†©
         stosb
         pop       ds
         jmp       short DekMFSl3

DekMFSl1:rep       movsb                    ; p©enos jmÇna poloëky

         pop       ds

         inc       di                       ; p©ednastaven° + 1
         mov       cl,8
DekMFSl2:dec       di                       ; sn°ëen° konce
         cmp       byte ptr ds:[di-1]," "   ; p©ede®lò znak mezera ?
         loope     DekMFSl2                 ; nalezen° konce jmÇna

DekMFSl3:sub       di,offset SRSMnPl4+1     ; dÇlka textu
         xchg      ax,di                    ; AX <- dÇlka textu

DekMFSl4:mov       ds:[SRSMnPl4],al         ; dÇlka textu
         mov       byte ptr ds:[SNSMnPr1],al ; dÇlka p©edvolby

; ------ n†vrat registrñ

DekMFSl9:pop       es
         pop       di
         pop       si
         pop       cx
         pop       ax
         ret

DekMFSel ENDP

; *****************************************************************************
;                               AktPFSel
;                 poskytnut° aktivn° poloëky okna vòbàru
; -----------------------------------------------------------------------------
; VSTUP: SI=definice menu
;        DS=datovò segment
; VùSTUP: ES:DI=aktivn° poloëka
;         CY=nen° ë†dn† poloëka
; *****************************************************************************

AktPFSel PROC      FAR

         push      ax
         push      bx

         mov       ax,ds:[si+SMnuSeg]       ; okno
         call      far ptr GetDat           ; adresa okna
         jc        AktPFSl9
         mov       bx,es:[AWinKurz]         ; kurzoru
         call      far ptr GetPolDI         ; adresa poloëky -> ES:DI

AktPFSl9:pop       bx
         pop       ax
         ret

AktPFSel ENDP

; *****************************************************************************
;                              AExtFSel
;             p©id†n° implicitn° p©°pony ke jmÇnu poloëky seznamu
; -----------------------------------------------------------------------------
; VSTUP: SI=definice menu vòbàru souborñ
;        ES:DI=buffer textu poloëky ve tvaru ASCII (bez p©°pony)
;        CX=dÇlka textu poloëky
;        DS=datovò segment
; VùSTUP: CX=nov† dÇlka textu poloëky (ukonáena 0)
; *****************************************************************************

AExtFSel PROC      FAR

; ------ £schova registrñ

         push      ax
         push      di

; ------ adresa konce poloëky

         cld
         add       di,cx                    ; adresa konce poloëky
         mov       al,"."                   ; oddàlovac° teáka
         mov       ah,ds:[si+SMnuExt]       ; prvn° znak p©°pony
         stosw                              ; teáka a prvn° znak
         mov       ax,ds:[si+SMnuExt+1]     ; dal®° 2 znaky
         stosw                              ; dal®° 2 znaky
         mov       al,0
         stosb                              ; koncov† 0
         add       cx,4                     ; zvò®en° dÇlky poloëky

; ------ n†vrat registrñ

         pop       di
         pop       ax
         ret

AExtFSel ENDP

; *****************************************************************************
;                               AddAFSel
;              p©id†n° jmÇna poloëky ve tvaru ASCII k cestà
; -----------------------------------------------------------------------------
; VSTUP: SI=definice menu vòbàru souborñ
;        ES:DI=text poloëky k p©id†n° ve tvaru ASCII
;        CL=dÇlka textu poloëky
;        DS=datovò segment
; VùSTUP: CY=p©eteáen° dÇlky cesty
; *****************************************************************************

AddAFSel PROC      FAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      di
         mov       ch,0

; ------ kontrola p©eteáen° dÇlky cesty

         mov       ax,ds:[si+SMnuPthN]      ; dÇlka textu cesty
         add       ax,cx                    ; nov† dÇlka textu cesty
         cmp       ax,FileMax               ; bylo by p©eteáen° dÇlky cesty ?
         cmc
         jc        AddAFSl9                 ; bylo by p©eteáen° dÇlky cesty

; ------ p©°prava registrñ

         push      si                       ; definice menu
         mov       ax,ds:[si+SMnuPthN]      ; dÇlka textu cesty
         mov       si,ds:[si+SMnuPath]      ; adresa cesty
         add       si,ax                    ; adresa konce cesty
         xchg      si,di                    ; SI <- poloëka, DI <- buffer cesty

; ------ p©°prava k dek¢dov†n° poloëky

         push      ds
         push      es

         push      ds
         push      es
         pop       ds                       ; DS <- segment textu
         pop       es                       ; ES <- datovò segment

; ------ zaji®tàn° koncovÇho znaku "\"

         cld
         mov       al,"\"
         dec       di
         scasb                              ; je cesta zakonáena s "\" ?
         je        AddAFSl4                 ; je jië "\" na konci
         stosb                              ; uloëen° "\" na konec

; ------ p©enos poloëky

AddAFSl4:rep       movsb                    ; p©enos textu
         mov       al,0
         stosb                              ; koncov† 0
         dec       di                       ; n†vrat na koncovou 0

         pop       es
         pop       ds

; ------ nastaven° novÇ dÇlky textu cesty

         pop       si                       ; definice menu

         sub       di,ds:[si+SMnuPath]      ; nov† dÇlka cesty
         mov       ds:[si+SMnuPthN],di      ; nov† dÇlka cesty

; ------ p©enesen° cesty do okna souborñ

         call      far ptr SPthFSel         ; uloëen° cesty do definice okna
         clc                                ; p©°znak operace OK

; ------ n†vrat registrñ

AddAFSl9:pop       di
         pop       cx
         pop       ax
         ret

AddAFSel ENDP

; *****************************************************************************
;                               AddFFSel
;              p©id†n° jmÇna poloëky ve tvaru FCB k cestà
; -----------------------------------------------------------------------------
; VSTUP: SI=definice menu vòbàru souborñ
;        ES:DI=text poloëky k p©id†n° ve tvaru FCB (11 znakñ)
;        DS=datovò segment
; VùSTUP: CY=p©eteáen° dÇlky cesty
; *****************************************************************************

AddFFSel PROC      FAR

; ------ £schova registrñ

         push      ax
         push      di

; ------ kontrola p©eteáen° dÇlky cesty

         cmp       word ptr ds:[si+SMnuPthN],FileMax-12; p©eteáen° dÇlky cesty ?
         cmc
         jc        AddFFSl9                 ; bylo by p©eteáen° dÇlky cesty

; ------ p©°prava registrñ

         push      si                       ; definice menu

         mov       ax,ds:[si+SMnuPthN]      ; dÇlka textu cesty
         mov       si,ds:[si+SMnuPath]      ; adresa cesty
         add       si,ax                    ; adresa konce cesty
         xchg      si,di                    ; SI <- poloëka, DI <- buffer cesty

; ------ p©°prava k dek¢dov†n° poloëky

         push      ds
         push      es

         push      ds
         push      es
         pop       ds                       ; DS <- segment poloëky
         pop       es                       ; ES <- datovò segment

; ------ zaji®tàn° koncovÇho znaku "\"

         cld
         mov       al,"\"
         dec       di
         scasb                              ; je cesta zakonáena s "\" ?
         je        AddFFSl4                 ; je jië "\" na konci
         stosb                              ; uloëen° "\" na konec

; ------ dek¢dov†n° jmÇna poloëky

AddFFSl4:call      far ptr FileAsc          ; dek¢dov†n° poloëky do bufferu

         pop       es
         pop       ds

; ------ nastaven° novÇ dÇlky textu cesty

         pop       si                       ; definice menu

         sub       di,ds:[si+SMnuPath]      ; nov† dÇlka cesty
         mov       ds:[si+SMnuPthN],di      ; nov† dÇlka cesty

; ------ p©enesen° cesty do okna souborñ

         call      far ptr SPthFSel         ; uloëen° cesty do definice okna
         clc                                ; p©°znak operace OK

; ------ n†vrat registrñ

AddFFSl9:pop       di
         pop       ax
         ret

AddFFSel ENDP

; *****************************************************************************
;                                SubFSel
;         odstranàn° posledn° poloëky z cesty (uchov†v† p©°znaky !)
; -----------------------------------------------------------------------------
; VSTUP: SI=definice menu vòbàru souborñ
;        DS=datovò segment
; *****************************************************************************

SubFSel  PROC      FAR

; ------ £schova registrñ

         pushf
         push      di

; ------ adresa konce cesty

         mov       di,ds:[si+SMnuPath]      ; adresa cesty
         add       di,ds:[si+SMnuPthN]      ; konec cesty

; ------ nalezen° koncovÇho "\" cesty

SubFSel1:dec       di                       ; sn°ëen° ukazatele
         cmp       byte ptr ds:[di],"\"     ; nalezen koncovò "\" ?
         jne       SubFSel1                 ; nalezen° koncovÇho "\"

; ------ oprava, pokud je dosaëeno ROOT

         cmp       byte ptr ds:[di-1],":"   ; je to ROOT ?
         jne       SubFSel2                 ; nen° to ROOT
         inc       di                       ; koncovò znak "\" se mus° ponechat

; ------ oznaáen° koncovÇ 0

SubFSel2:mov       byte ptr ds:[di],0       ; oznaáen° koncovÇ 0

; ------ nastaven° novÇ dÇlky textu cesty

         sub       di,ds:[si+SMnuPath]      ; nov† dÇlka cesty
         mov       ds:[si+SMnuPthN],di      ; nov† dÇlka cesty

; ------ p©enesen° cesty do okna souborñ

         call      far ptr SPthFSel         ; uloëen° cesty do definice okna

; ------ n†vrat registrñ

SubFSel9:pop       di
         popf
         ret

SubFSel  ENDP

; *****************************************************************************
;                                SPthFSel
;            uloëen° cesty z menu do definice okna vòbàru souborñ
; -----------------------------------------------------------------------------
; VSTUP: SI=menu vòbàru souborñ
;        DS=datovò segment
; *****************************************************************************

SPthFSel PROC      FAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      si
         push      di
         push      es

; ------ adresa definice seznamu souborñ

         mov       ax,ds:[si+SMnuSeg]       ; segment okna se soubory
         call      far ptr GetDat           ; adresa okna
         jc        SPthFSl9                 ; okno je neplatnÇ

; ------ nenaá°tat "..", je-li to z†kladn° adres†©

         and       byte ptr es:[AWinFilP],not bit4 ; ".." se naá°t†
         mov       cx,ds:[si+SMnuPthN]      ; CX <- dÇlka textu cesty
         cmp       cx,ds:[si+SMnuPth0]      ; je to z†kladn° adres†© ?
         ja        SPthFSl2                 ; nen° to z†kladn° adres†©
         or        byte ptr es:[AWinFilP],bit4 ; nenaá°tat ".."

; ------ p©enesen° textu adres†©e

SPthFSl2:cld
         mov       es:[AWinDNum],cx         ; dÇlka textu cesty
         mov       si,ds:[si+SMnuPath]      ; buffer s cestou adres†©e
         mov       al,ds:[si]               ; jmÇno disku
         sub       al,"A"                   ; korekce na á°slo disku
         mov       es:[AWinDisk],al         ; aktivn° disk
         mov       di,AWinDir               ; buffer adres†©e okna
         rep       movsb                    ; p©enos textu adres†©e
         mov       al,0
         stosb                              ; koncov† 0

; ------ n†vrat registrñ

SPthFSl9:pop       es
         pop       di
         pop       si
         pop       cx
         pop       ax
         ret

SPthFSel ENDP

;; -----------------------------------------------------------------------------
;;        uzav©en° reëimu rychlovyhled†v†n° souborñ p©i vòbàru DS:SI (CY=bylo)
;; -----------------------------------------------------------------------------
;
;QSrcFEnd PROC      NEAR
;
;         test      byte ptr ds:[WindPar],bit3 ; je rychlovyhled†v†n° zav©eno ?
;         jz        QSrcFEn9                 ; je jië uzav©eno
;
;         and       byte ptr ds:[WindPar],not bit3 ; zru®en° rychlovyhled†v†n°
;         mov       byte ptr ds:[QSrcNum],0  ; uzav©en° rychlovyhled†v†n°
;         call      far ptr DispMnu          ; novÇ zobrazen° okna
;         stc                                ; p©°znak - bylo rychlovyhled†v†n°
;
;QSrcFEn9:ret
;
;QSrcFEnd ENDP

; *****************************************************************************
;                                ClosFSel
;                    uzav©en° okna vòbàru souborñ
; -----------------------------------------------------------------------------
; VSTUP: SI=definice okna vòbàru souborñ
;        DS=datovò segment
; *****************************************************************************

ClosFSel PROC      FAR

; ------ £schova registrñ

         push      ax

; ------ zru®en° segmentu koment†©ñ a segmentu okna

         mov       ax,ds:[si+SMnuSeg]       ; segment okna se soubory
         call      far ptr DeletAWn         ; zru®en° okna
         mov       word ptr ds:[si+SMnuSeg],0 ; oznaáen° segmentu za zru®enò

; ------ n†vrat registrñ

         pop       ax
         ret

ClosFSel ENDP

; *****************************************************************************
;                              ReadFSel
;            naáten° seznamu souborñ k vòbàru s nastaven°m kurzoru
; -----------------------------------------------------------------------------
; VSTUP: SI=menu vòbàru souborñ
;        DS=datovò segment
; *****************************************************************************

ReadFSel PROC      FAR

; ------ £schova registrñ

         push      ax
         mov       ax,ds:[si+SMnuSeg]       ; adresa segmentu
         call      far ptr ReReadD          ; novÇ naáten° okna
         mov       ds:[si+SMnuSeg],ax       ; novÇ á°slo okna
         pop       ax
         ret

ReadFSel ENDP

; *****************************************************************************
;                              InitSMnu
;                     inicializace menu seznamu
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa definice menu
;        DS=datovò segment
; *****************************************************************************

InitSMnu PROC      FAR

         push      ax
         mov       al,ds:[Radku]
         sub       al,5
         mov       ds:[si+MnuVys],al        ; vò®ka okna
         call      far ptr CentMenu         ; vyst©edàn° okna
         pop       ax
         ret

InitSMnu ENDP

; *****************************************************************************
;                              DispSMnu
;                    zobrazen° menu vòbàru souborñ
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa definice menu
;        DS=datovò segment
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-1] (1) ukazatel ©†dku
;                   SS:[BP-2] (1) poá†teán° pozice okna
;                   SS:[BP-3] (1) á°taá ©†dkñ souborñ k zobrazen°
;                   SS:[BP-4] (1) ®°©ka okna
;                   SS:[BP-6] (2) hladina k zobrazen°
;                   SS:[BP-8] (2) segment definice okna
;                   SS:[BP-10] (2) adresa definice okna
;                   SS:[BP-12] (2) adresa definice koment†©ñ (mñëe bòt neplatn†)
;                   SS:[BP-14] (2) ukazatel á°sla poloëky k zobrazen°
;                   SS:[BP-16] (2) á°taá kurzoru
; *****************************************************************************
;˛
DispSMnu PROC      FAR

; ------ normalizace kurzoru menu

         call      NormSMnu                 ; normalizace kurzoru menu

; ------ zobrazen° r†mu okna

         call      far ptr DispRamM         ; zobrazen° r†mu

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

; ------ buffer v z†sobn°ku

         sub       sp,16                    ; m°sto pro lok†ln° promànnÇ
         mov       ch,0
         mov       cl,ds:[si+MnuSir]        ; CX <- ®°©ka okna
         shl       cx,1                     ; velikost bufferu
         sub       sp,cx                    ; m°sto pro bufferu ©†dku

; ------ inicializace lok†ln°ch promànnòch

         mov       ax,word ptr ds:[si+MnuPoz] ; poá†teán° pozice a ©†dek okna
         inc       ah                       ; zvò®en° ©†dku
         mov       ss:[bp-2],ax             ; poá†teán° pozice a ©†dek okna
         mov       ax,word ptr ds:[si+MnuSir] ; ®°©ka a vò®ka okna
         sub       ah,4                     ; odeáten° okrajñ
         mov       ss:[bp-4],ax             ; ®°©ka a vò®ka okna
         mov       al,ds:[si+MnuLev]        ; hladina k zobrazen°
         mov       ah,0
         mov       ss:[bp-6],ax             ; hladina k zobrazen°
         mov       ax,ds:[si+SMnuSeg]       ; segment definice seznamu
         mov       ss:[bp-8],ax             ; segment definice seznamu
         call      far ptr GetDat           ; adresa segmentu -> ES
         mov       ss:[bp-10],es            ; adresa segmentu definice seznamu
         mov       ax,es:[AWinFrst]         ; prvn° zobrazenò soubor
         mov       ss:[bp-14],ax            ; ukazatel á°sla poloëky k zobrazen°
         mov       ax,es:[AWinKurz]         ; soubor s kurzorem
         sub       ax,ss:[bp-14]            ; offset od poá†tku
         inc       ax
         inc       ax                       ; korekce
         cmp       word ptr es:[AWinSouN],0 ; je nàjakò soubor ?
         jne       DispSMn1                 ; je nàjakò soubor
         xor       ax,ax                    ; kurzor nen°
DispSMn1:mov       ss:[bp-16],ax            ; á°taá kurzoru

; ------ adresa definice koment†©ñ (nevad°, je-li neplatn†)

         mov       ax,es:[AWinKomS]         ; segment definice koment†©ñ
         call      far ptr GetDat           ; adresa segmentu koment†©ñ
         mov       ss:[bp-12],es            ; adresa definice koment†©ñ

; ------ vymaz†n° ©†dku nadpisu

         call      DispS0Mn                 ; vymaz†n° ©†dku

; ------ dek¢dov†n° textu nadpisu

         mov       ah,bh                    ; vysv°cen† barva menu
         push      ds
         mov       ds,ss:[bp-10]            ; adresa definice okna
         mov       cx,ds:[AWinKomD]         ; dÇlka nadpisu
         jcxz      DispSM28                 ; nen° nadpis
         mov       si,ds:[AWinKomA]         ; adresa nadpisu
         mov       ds,ss:[bp-12]            ; adresa definice koment†©ñ
         mov       bh,0
         mov       bl,ss:[bp-4]             ; dÇlka ©†dku
         sub       bl,4                     ; bez okrajñ
         cmp       bx,cx                    ; je text del®° ?
         jae       DispSM22                 ; dÇlka textu je OK
         mov       cx,bx                    ; CX <- omezen° dÇlky textu
DispSM22:sub       bx,cx                    ; zbytek na okraje
         and       bl,not bit0              ; zarovn†n° na sudou adresu
         inc       di
         inc       di                       ; 2. pozice
         add       di,bx                    ; poá†tek k dek¢dov†n° textu
DispSM24:lodsb
         stosw
         loop      DispSM24                 ; dek¢dov†n° textu nadpisu
DispSM28:pop       ds

; ------ zobrazen° ©†dku nadpisu

         call      DispS1Mn                 ; zobrazen° ©†dku nadpisu

; ------ zobrazen° oddàlovac° á†ry (CL=dÇlka ©†dku, AX=hladina)

         mov       di,sp
         mov       cl,ss:[bp-4]             ; ®°©ka okna
         dec       cx
         dec       cx                       ; bez okrajñ
         mov       ah,ds:[ColMnu1R]         ; barva pro levò okraj
         mov       al,"√"                   ; "√" levò okraj
         cld
         stosw                              ; uloëen° levÇho okraje
         mov       ah,ds:[ColMnu1]          ; bàën† barva menu
         mov       al,"ƒ"                   ; "ƒ"
         rep       stosw                    ; vnit©n° mezera
         mov       ah,ds:[ColMnu1L]         ; barva pro pravò okraj
         mov       al,"¥"                   ; "¥"
         stosw                              ; uloëen° pravÇho okraje
         mov       di,sp
         mov       al,"¬"
         mov       es:[di+11*2],al          ; "¬" ; spoj
         call      DispS1Mn                 ; zobrazen° oddàlovac° á†ry

; ------ vymaz†n° ©†dku pro soubory (CH <- 0)

DispSMn3:call      DispS0Mn                 ; vymaz†n° ©†dku

; ------ p©°prava oddàlovac° á†ry

         mov       byte ptr es:[di+10*2],"≥" ; oddàlovac° á†ra

; ------ adresa definice poloëky -> DS:SI

         push      ds

         push      es
         push      bx

         mov       es,ss:[bp-10]            ; segment definice okna
         mov       bx,ss:[bp-14]            ; á°slo poloëky
         call      far ptr GetESPol         ; adresa poloëky -> ES:SI
         push      es
         pop       ds                       ; DS <- segment poloëky

         pop       bx
         pop       es
         jc        DispSMn8                 ; nen° to platnò soubor

; ------ naáten° atributñ -> AL

         cld
         lodsb                              ; AL <- atributy
         inc       di
         inc       di
         mov       cl,8                     ; CX <- dÇlka jmÇna poloëky

; ------ je poloëka ".."

         cmp       word ptr ds:[si],".."    ; je poloëka ".." ?
         jne       DispSMn4                 ; nen° poloëka ".."
         mov       al,4                     ; n†hradn° znak poloëky
         stosb
         add       di,1+8*2                 ; p©eskoáen° zbytku jmÇna poloëky
         jmp       short DispSMn6

; ------ korekce pro poloëku R/O

DispSMn4:test      al,RO                    ; je z†kaz z†pisu ?
         jz        DispSM42                 ; nen° z†kaz z†pisu
         mov       byte ptr es:[di-2],"*"   ; p©°znak z†kazu z†pisu

; ------ korekce, je-li to adres†©

DispSM42:test      al,DIR                   ; je to adres†© ?
         jz        DispSMn5                 ; nen° to adres†©
         mov       ah,bh                    ; vysv°cen† barva
         mov       byte ptr es:[di-2],"["   ; oznaáen° adres†©e
         mov       byte ptr es:[di+2*8],"]"

; ------ dek¢dov†n° jmÇna poloëky

DispSMn5:lodsb
         stosw
         loop      DispSMn5                 ; dek¢dov†n° jmÇna poloëky
         inc       di
         inc       di                       ; p©eskoáen° koncovÇ mezery

; ------ adresa koment†©e

DispSMn6:mov       si,ss:[bp-14]            ; ukazatel á°sla poloëky
         inc       word ptr ss:[bp-14]      ; zvò®en° ukazatele á°sla poloëky
         shl       si,1                     ; offset poloëky v tabulce
         mov       ds,ss:[bp-10]            ; adresa definice okna
         add       si,word ptr ds:[AWinKomI] ; adresa v tabulce indexñ
         mov       ax,ds
         add       ax,word ptr ds:[AWinKomI+2] ; segment koment†©ñ
         mov       ds,ax
         mov       si,ds:[si]               ; adresa koment†©e
         or        si,si                    ; je koment†© definovanò ?
         jz        DispSMn8                 ; nen° koment†©

; ------ dek¢dov†n° koment†©e

         inc       di
         inc       di                       ; p©eskoáen° oddàlovac° á†ry
         mov       cl,ss:[bp-4]             ; ®°©ka okna
         sub       cl,1+10+1+1              ; odeáten° okrajñ
         mov       ds,ss:[bp-12]            ; adresa definice koment†©ñ
DispSMn7:lodsb                              ; naáten° znaku pozn†mky
         cmp       al,0                     ; konec textu ?
         je        DispSMn8                 ; konec textu
         stosb                              ; uloëen° znaku do bufferu
         inc       di                       ; p©eskoáen° barvy
         loop      DispSMn7                 ; dal®° znak

DispSMn8:pop       ds

; ------ zobrazen° ©†dku

         call      DispS1Mn                 ; zobrazen° ©†dku souborñ

; ------ p©°prava pro dal®° ©†dek

         dec       byte ptr ss:[bp-3]       ; á°taá ©†dkñ souborñ
         jz        DispSMn9                 ; jsou jië v®echny ©†dky
         jmp       DispSMn3                 ; dal®° ©†dek

; ------ n†vrat registrñ

DispSMn9:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispSMnu ENDP

; ------ vymaz†n° ©†dku -> ES:DI=poá†tek ©†dku, AH=bàzn†/BH=vysv°cen† barva

DispS0Mn:push      ss
         pop       es                       ; ES <- segment bufferu
         mov       di,sp
         inc       di
         inc       di                       ; zaá†tek bufferu
         mov       ch,0
         mov       cl,ss:[bp-4]             ; CX <- ®°©ka okna
         dec       cx
         dec       cx                       ; bez okrajñ

         cld
         mov       ah,ds:[ColMnu1R]         ; barva pro levò okraj
         mov       al,"≥"                   ; "≥" levò okraj
         stosw                              ; uloëen° levÇho okraje

         push      di

         mov       ah,ds:[ColMnu1]          ; bàën† barva menu
         mov       bh,ds:[ColMnu2]          ; vysv°cen† barva
         dec       word ptr ss:[bp-16]      ; á°taá kurzoru
         jnz       DispS0M2                 ; nen° kurzor
         mov       ah,ds:[ColMnu3]          ; barva kurzoru
         mov       bh,ds:[ColMnu4]          ; vysv°cen† barva kurzoru
DispS0M2:mov       al," "
         rep       stosw                    ; vnit©n° mezera

         push      ax
         mov       ah,ds:[ColMnu1L]         ; pravò okraj
         mov       al,"≥"                   ; "≥" pravò okraj
         stosw                              ; uloëen° pravÇho okraje
         pop       ax

         pop       di                       ; DI <- zaá†tek bufferu
         ret

; ------ zobrazen° ©†dku

DispS1Mn:mov       si,sp
         inc       si
         inc       si                       ; zaá†tek ©†dku
         mov       cl,ss:[bp-4]             ; ®°©ka okna
         mov       dx,ss:[bp-2]             ; ©†dek a pozice
         mov       ax,ss:[bp-6]             ; hladina k zobrazen°
         call      far ptr DispMStr         ; zobrazen° ©†dku
         inc       byte ptr ss:[bp-1]       ; zvò®en° ukazatele ©†dkñ
         ret

; *****************************************************************************
;                               KurzSMnu
;                    zobrazen° kurzoru vòbàru souborñ
; -----------------------------------------------------------------------------
; VSTUP: SI=adresa definice menu
;        DS=datovò segment
; *****************************************************************************

KurzSMnu PROC      FAR

; ------ £schova registrñ

         push      dx

; ------ vypnut° kurzoru, nen°-li rychlovyhled†v†n°

         test      byte ptr ds:[WindPar],bit3 ; je rychlovyhled†v†n° ?
         jnz       KurzSMn2                 ; je rychlovyhled†v†n°
         call      far ptr KurzOff          ; vypnut° kurzoru
         jmp       short KurzSMn9

; ------ zobrazen° kurzoru p©i rychlovyhled†v†n°

KurzSMn2:mov       dx,word ptr ds:[si+MnuPoz]        ; ©†dek a pozice menu
         add       dh,ds:[si+MnuVys]        ; ©†dek pod oknem
         dec       dh                       ; posledn° ©†dek okna
         inc       dx
         inc       dx                       ; korekce pozice
         add       dl,ds:[QSrcNum]          ; pozice kurzoru
         call      far ptr SetKurz          ; zobrazen° kurzoru

; ------ n†vrat registrñ

KurzSMn9:pop       dx
         ret

KurzSMnu ENDP

; -----------------------------------------------------------------------------
;        normalizace kurzoru menu vòbàru souboru DS:SI
; -----------------------------------------------------------------------------

NormSMnu PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      es

; ------ adresa okna -> ES

         mov       ax,ds:[si+SMnuSeg]       ; segment okna
         call      far ptr GetDat           ; adresa okna -> ES

; ------ parametry okna

         mov       ax,es:[AWinKurz]         ; AX <- pozice kurzoru
         mov       ch,0
         mov       cl,ds:[si+MnuVys]        ; CX <- vò®ka okna
         sub       cl,4                     ; bez okrajñ
         mov       bx,es:[AWinFrst]         ; BX <- prvn° zobrazen† poloëka
         mov       dx,es:[AWinSouN]         ; DX <- celkovò poáet souborñ v oknà

; ------ omezen° pozice kurzoru

         cmp       ax,dx                    ; je pozice kurzoru OK ?
         jb        NormSMn4                 ; pozice kurzoru je OK
         mov       ax,dx                    ; omezen° pozice kurzoru
         or        ax,ax                    ; jsou nàjakÇ poloëky ?
         jz        NormSMn3                 ; nejsou ë†dnÇ poloëky
         dec       ax                       ; á°slo posledn° poloëky
NormSMn3:mov       es:[AWinKurz],ax         ; opraven† pozice kurzoru

; ------ stanoven° maxim†ln°ho poá†tku okna -> DX

NormSMn4:sub       dx,cx                    ; maxim†ln° zaá†tek okna
         jbe       NormSMn6                 ; je malò poáet ©†dkñ

; ------ ohraniáen° shora

         sub       ax,1                     ; rezerva na horn°m okraji
         jbe       NormSMn6                 ; je ©†dek 1 nebo 0 - je zaá†tek
         cmp       ax,bx                    ; je nad horn°m okrajem ?
         jb        NormSMn7                 ; je nad horn°m okrajem
         add       ax,3                     ; n†vrat kurzoru + rezerva 1 ©†dek

; ------ ohraniáen° zdola

         sub       ax,cx                    ; korekce, pokud je pod doln°m okr.
         jbe       NormSMn5                 ; nen° je®tà pod doln°m okrajem
         cmp       ax,bx                    ; je pod doln°m okrajem ?
         jae       NormSMn7                 ; je pod doln°m okrajem
NormSMn5:mov       ax,bx                    ; pñvodn° zaá†tek
         jmp       short NormSMn7           ; je konec okna

; ------ je zaá†tek okna

NormSMn6:xor       ax,ax                    ; AX <- n†hradn° zaá†tek okna
         xor       dx,dx                    ; DX <- maxim†ln° zaá†tek okna

; ------ kontrola maxim†ln°ho zaá†tku

NormSMn7:cmp       ax,dx                    ; p©ekroáen maxim†ln° zaá†tek ?
         jbe       NormSMn8                 ; nen° p©ekroáen maxim†ln° zaá†tek
         xchg      ax,dx                    ; AX <- maxim†ln° zaá†tek

; ------ nastaven° novÇho zaá†tku okna

NormSMn8:mov       es:[AWinFrst],ax         ; novò poá†tek okna

; ------ n†vrat registrñ

NormSMn9:pop       es
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

NormSMnu ENDP

CodeDbf  ENDS

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;
;                                 Data
;
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
Data     SEGMENT

; -----------------------------------------------------------------------------
;        menu vytvo©en° novÇho souboru DBF
; -----------------------------------------------------------------------------

DBMMMnu  label     byte
         db        15                       ; typ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        1                        ; poáet poloëek
         dw        1                        ; poáet poloëek celkem

         dw        DBMMMPol                 ; zaá†tek definice poloëek menu
         dw        DBMMMHl1                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@ModifikaceStrukturyDatabazovehoSouboru ; á°slo str†nky velkÇ n†povàdy
         dw        0                        ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        DBMMMTi1                 ; adresa titulu okna
         dw        DBMMMExe                 ; tabulka adres obsluh
         dw        DBMMMMnu                 ; tabulka podmenu
         dd        0                        ; n†vratov† adresa

         db        12                       ; poá†teán° pozice okna
         db        3                        ; poá†teán° ©†dek okna
         db        58                       ; ®°©ka okna
         db        15                       ; vò®ka okna

         dw        0                        ; segment bufferu z†hlav°

DBMMMPol label     byte

HelpS    SEGMENT   BYTE PUBLIC
DBMMMHl0 db        57,'Znaky "A-Z 0-9 _" = nov† poloëka, Enter=konec'
DBMMMHl1 db        100,'Znaky "A-Z 0-9 _", F2=nahoru, F3=dolñ, F5=kopie, F6=p©ipoj, F8=zru®, F10=konec'
DBMMMHl2 db        89,'Poloëka: Znakov†, á°slo Numeric/Float, Datum, Logick†, TextovÇ pole, Hodiny'
DBMMMHl3 db        40,'DÇlka znakovÇ poloëky 1 aë 255 znakñ'
DBMMMHl4 db        76,'DÇlka á°selnÇ poloëky 1 aë 20 á°slic (váetnà desetinnÇ teáky a znamÇnka)'
DBMMMHl5 db        80,'Poáet desetinnòch m°st 0 aë 18, maxim†lnà v®ak o 2 men®° neë dÇlka poloëky'
DBMMMHl6 db        82,'Poá†teán° pozice poloëky ve starÇ poloëce 0 aë 255 (vypu®tàn° zaá†tku poloëky)'
HelpS    ENDS

DBMMMTi1 db        11,'novò seznam'
DBMMMTi2 db        10,'modifikace'
DBMMMExe dd        0
DBMMMMnu dw        0

DBMMMNad db        ' Ä°slo    JmÇno       Typ    DÇlka  Desetin '
DBMMMNd1 db        ' Poá†tek '
DBMMMNd2 label     byte

DBMMMTyp db        'Znakov†'
         db        'N á°slo'
         db        'F á°slo'
         db        'Datum  '
         db        'Logick†'
         db        '<TEXT> '
         db        'Hodiny '
DBMMMTp0 db        '-typ ?-'

DBFModHl db        31,'Modifikuji strukturu seznamu...'

; ------ zobrazen° definice poloëek

;     Cislo    JmÇno       Typ    DÇlka  Desetin  Poá†tek
;        1   Polozka_01  Znakova   123                0
;        2   Polozka_02  Ciselna    13      11        1
;        3   Bezny_Text  Textova    10                0
;        4   Pravda_?    Logicka     1                0
;    123+345 Dnesni_Den  Datum       8                0

; ------ volba typu poloëky

DBTMVert label     byte
         db        2                        ; typ menu - vertik†ln° podmenu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka volby
         dw        7                        ; poáet platnòch poloëek menu
         dw        7                        ; celkovò poáet poloëek menu

         dw        DBTMVPol                 ; adresa definián° tabulky poloëek
         dw        DBTMVHlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@VolbaTypuDatabazovePolozky ; á°slo str†nky velkÇ n†povàdy
         dw        DBTMVBlk                 ; adresa blokovac° tabulky
         dw        DBTMVSwc                 ; adresa tabulky p©ep°naáñ
         dw        DBTMVTit                 ; adresa titulu okna
         dw        DBTMVExe                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        43                       ; poá†teán° pozice
         db        3                        ; poá†teán° ©†dek
         db        21                       ; ®°©ka
         db        9                        ; vò®ka

DBTMVPol db        1+bit7,15,'Znakov† poloëka'
         db        7+bit7,13,'á°slo Numeric'
         db        7+bit7,11,'á°slo Float'
         db        1+bit7,5,'Datum'
         db        1+bit7,15,'Logick† poloëka'
         db        1+bit7,12,'TextovÇ pole'
         db        1+bit7,6,'Hodiny'

DBTMVBlk db        0,0,0,0,0,0,0
DBTMVBl0 db        0                        ; blokovac° tabulka bitovà
DBTMVSwc db        0,0,0,0,0,0,0
DBTMVTit db        11,'typ poloëky'

HelpS    SEGMENT   BYTE PUBLIC
DBTMVHlp db        44,'Znakov† poloëka - ©etàzec 1 aë 255 znakñ'
         db        81,'Ä°seln† poloëka typu Numeric - 1 aë 20 á°slic, 0 aë 18 desetinnòch m°st'
         db        79,'Ä°seln† poloëka typu Float - 1 aë 20 á°slic, 0 aë 18 desetinnòch m°st'
         db        5,'Datum'
         db        37,'Logick† poloëka - hodnoty ANO, NE'
         db        47,'TextovÇ pole (MEMO pole) - text libovolnÇ dÇlky'
         db        12,'Hodiny (áas)'
HelpS    ENDS

DBTMVExe label     dword                    ; obsluhy voleb
         dd        EdiDBEn2                 ; znakov† poloëka
         dd        EdiDBEn2                 ; á°slo Numeric
         dd        EdiDBEn2                 ; á°slo Float
         dd        EdiDBEn2                 ; datum
         dd        EdiDBEn2                 ; logick† poloëka
         dd        EdiDBEn2                 ; textovÇ pole
         dd        EdiDBEn2                 ; áas

; -----------------------------------------------------------------------------
;        menu vòbàru seznamu
; -----------------------------------------------------------------------------

SSMnuSel label     byte

         db        9                        ; typ menu - vòbàr souborñ

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        1                        ; poáet poloëek
         dw        1                        ; poáet poloëek celkem

         dw        0                        ; zaá†tek definice poloëek menu
         dw        SSMnSHlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@DatovySeznam         ; á°slo str†nky velkÇ n†povàdy
         dw        0                        ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        SSMnSTit                 ; adresa titulu okna
         dw        LinMenTM                 ; tabulka adres obsluh
         dw        LinMenTM                 ; tabulka podmenu
         dd        0                        ; n†vratov† adresa

         db        12                       ; poá†teán° pozice okna
         db        3                        ; poá†teán° ©†dek okna
         db        DelKomDB+13              ; ®°©ka okna
         db        18                       ; vò®ka okna

SeznSeg  dw        0                        ; segment se seznamem souborñ
SeznPth0 dw        0                        ; minim. dÇlka textu cesty
SeznPthN dw        0                        ; dÇlka textu cesty seznamu
         dw        SeznPath                 ; buffer s adres†©em seznamu
SeznPthI db        3                        ; inicializaán° jmÇno podadres†©e
SeznExt  db        'DBF'                    ; p©°pona pro vòbàr souborñ
SeznTxt1 dw        SeznTx11                 ; adresa textu "seznam"
OldSFrst dw        0                        ; uschovan† prvn° poloëka seznamu
OldSKurz dw        0                        ; uschovanò kurzor seznamu

SSMnSTit db        13,'volba seznamu'

HelpS    SEGMENT   BYTE PUBLIC
SSMnSHlp db        89,'F2=prototyp, F3=novò, F4=koment†©, F5=kopie, F7=skupina, F8=zru®, F9=nadpis'
HelpS    ENDS

SSMnSHlM label     byte
         db        13
         dw        3c00h                    ; F2
         db        9
         dw        3d00h                    ; F3
         db        13
         dw        3e00h                    ; F4
         db        10
         dw        3f00h                    ; F5
         db        12
         dw        4100h                    ; F7
         db        9
         dw        4200h                    ; F8
         db        -1
         dw        4300h                    ; F9

SeznTx11 db        6,'seznam'

SeznTx1X db        6,'seznam'               ; text "seznam" nebo "text"

SeznTx2X db        7,'tabulku'

; ------ menu F3 - zaloëen° novÇ poloëky

SFSMnLin label     byte

         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        3                        ; poáet platnòch poloëek menu
         dw        5                        ; celkovò poáet poloëek menu

         dw        SFSMnPol                 ; zaá†tek definice poloëek menu
         dw        SFSMnHlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@PodmenuZvlastni      ; á°slo str†nky velkÇ n†povàdy
         dw        SFSMnBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        SFSMnTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        20                       ; poá†teán° pozice okna
         db        0                        ; poá†teán° ©†dek okna
         db        40                       ; ®°©ka okna
         db        8                        ; vò®ka okna

         dw        8                        ; maxim†ln° dÇlka textu ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        1                        ; celkovò poáet ©†dkñ
         dw        1                        ; poáet zobrazenòch ©†dkñ

         db        bit3                     ; maska zad†vanòch znakñ - soubor
         db        6,'?*.\: '               ; zak†zanÇ znaky

         db        HistFile                 ; historie specifikac° souborñ
         db        0                        ; poáet p©edvoleb

SFSMnPol db        bit6,18,'JmÇno novÇho ',1
         dw        SeznTx1X
         db        'u:'
         db        0,0
         db        bit6+bit7,0
         db        1,5,'Zaloë'
         db        1,6,'N†vrat'

SFSMnBlk db        0,0,0                    ; blokovac° tabulka

SFSMnTit db        8,'zaloëen°'

HelpS    SEGMENT   BYTE PUBLIC
SFSMnHlp db        44,'Zadejte jmÇno novÇho ',1
         dw        SeznTx1X
         db        'u (1 aë 8 znakñ)'

         db        33,'Zaloëen° novÇho ',1
         dw        SeznTx1X
         db        'u podle zad†n°'

         db        3,1
         dw        MenuHlP1
HelpS    ENDS

SSSMnHls db        15,'Vytv†©°m ',0,1
         dd        LinNum

; ------ menu F3 - zaloëen° novÇ tabulky

TBSMnLin label     byte

         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        3                        ; poáet platnòch poloëek menu
         dw        5                        ; celkovò poáet poloëek menu

         dw        TBSMnPol                 ; zaá†tek definice poloëek menu
         dw        TBSMnHlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@VyberTabulkyTabulkovehoKalkulatoru ; á°slo str†nky velkÇ n†povàdy
         dw        SFSMnBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        SFSMnTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        20                       ; poá†teán° pozice okna
         db        0                        ; poá†teán° ©†dek okna
         db        40                       ; ®°©ka okna
         db        8                        ; vò®ka okna

         dw        8                        ; maxim†ln° dÇlka textu ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        1                        ; celkovò poáet ©†dkñ
         dw        1                        ; poáet zobrazenòch ©†dkñ

         db        bit3                     ; maska zad†vanòch znakñ - soubor
         db        6,'?*.\: '               ; zak†zanÇ znaky

         db        HistFile                 ; historie specifikac° souborñ
         db        0                        ; poáet p©edvoleb

TBSMnPol db        bit6,19,'JmÇno novÇ tabulky:'
         db        0,0
         db        bit6+bit7,0
         db        1,5,'Zaloë'
         db        1,6,'N†vrat'

HelpS    SEGMENT   BYTE PUBLIC
TBSMnHlp db        45,'Zadejte jmÇno novÇ tabulky (1 aë 8 znakñ)'
         db        34,'Zaloëen° novÇ tabulky podle zad†n°'

         db        3,1
         dw        MenuHlP1
HelpS    ENDS

; ------ hl†®en° - soubor jië existuje

SF3MnLin label     byte
         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        1                        ; poáet platnòch poloëek menu
         dw        6                        ; celkovò poáet poloëek menu

         dw        SF3MnPol                 ; zaá†tek definice poloëek menu
         dw        ChbLnMeH                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@PodmenuZvlastni      ; á°slo str†nky velkÇ n†povàdy
         dw        SF3MnBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        SF3MnTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        20                       ; poá†teán° pozice okna
         db        0                        ; poá†teán° ©†dek okna
         db        45                       ; ®°©ka okna
         db        10                       ; vò®ka okna

         dw        255                      ; maxim†ln° dÇlka textu ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        0                        ; celkovò poáet ©†dkñ
         dw        0                        ; poáet zobrazenòch ©†dkñ

         db        bit3                     ; maska zad†vanòch znakñ - soubor
         db        0,'      '               ; zak†zanÇ znaky

         db        0                        ; historie specifikac° souborñ
         db        0                        ; poáet p©edvoleb

SF3MnPol db        bit6,0
         db        bit6,9,0,'VAROVèNã'
         db        bit6,34,'Zadanò soubor '
         db        0,1
         dw        LinNum
         db        0,' jië existuje !'
         db        bit6,0
         db        bit6+bit7,0
         db        1,6,'N†vrat'

SF3MnBlk db        0

SF3MnTit db        8,'existuje'

;; ------ vzor novÇho DBF souboru
;
;DBVzorS  label     byte                     ; vzor seznamu
;         db        3                        ; identifik†tor
;         db        0,0,0                    ; aktu†ln° datum
;         dd        0                        ; poáet vàt v souboru
;         dw        33                       ; dÇlka z†hlav° (bajtñ)
;         dw        11                       ; dÇlka vàty
;         db        20 dup(0)                ; ... rezervov†no
;         db        0dh                      ; konec z†hlav°
;         db        1ah                      ; konec souboru
;DBVzorS0 label     byte

; ------ menu F4 - koment†© poloëky

SKSMnLin label     byte
         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        3                        ; poáet platnòch poloëek menu
         dw        5                        ; celkovò poáet poloëek menu

         dw        SKSMnPol                 ; zaá†tek definice poloëek menu
         dw        SKSMnHlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@PodmenuZvlastni      ; á°slo str†nky velkÇ n†povàdy
         dw        SKSMnBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        SKSMnTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        20                       ; poá†teán° pozice okna
         db        0                        ; poá†teán° ©†dek okna
         db        DelKomDB+2               ; ®°©ka okna
         db        8                        ; vò®ka okna

         dw        DelKomDB                 ; maxim†ln° dÇlka textu ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        1                        ; celkovò poáet ©†dkñ
         dw        1                        ; poáet zobrazenòch ©†dkñ

         db        bit2                     ; maska zad†vanòch znakñ - v®echny
         db        3,13,10,0,'   '          ; zak†zanÇ znaky

         db        HistKom                  ; historie koment†©ñ
SKSMnPN1 db        1                        ; poáet p©edvoleb
SKSMnPD1 dw        0                        ; dÇlka p©edvolby
SKSMnPA1 dd        0                        ; adresa p©edvolby

SKSMnPol db        bit6,25,'Novò koment†© pro ',0,1
         dw        SRSMnPl4
         db        0,' :'

         db        0,0
         db        bit6+bit7,0
         db        2,6,' Uloë '
         db        1,6,'N†vrat'

SKSMnBlk db        0,0,0                    ; blokovac° tabulka

SKSMnTit db        8,'koment†©'

HelpS    SEGMENT   BYTE PUBLIC
SKSMnHlp db        56,'Zadejte novò koment†© poloëky na ©†dku (max. 50 znakñ)'
         db        26,'Uloëen° zadanÇho koment†©e'
         db        3,1
         dw        MenuHlP2
HelpS    ENDS

; ------ menu F5 - kopie

SNSMnLin label     byte
         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        3                        ; poáet platnòch poloëek menu
         dw        5                        ; celkovò poáet poloëek menu

         dw        SNSMnPol                 ; zaá†tek definice poloëek menu
         dw        SNSMnHlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@PodmenuZvlastni      ; á°slo str†nky velkÇ n†povàdy
         dw        SNSMnBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        SNSMnTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        20                       ; poá†teán° pozice okna
         db        0                        ; poá†teán° ©†dek okna
         db        40                       ; ®°©ka okna
         db        8                        ; vò®ka okna

         dw        8                        ; maxim†ln° dÇlka textu ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        1                        ; celkovò poáet ©†dkñ
         dw        1                        ; poáet zobrazenòch ©†dkñ

         db        bit3                     ; maska zad†vanòch znakñ - soubor
         db        6,'?*.\: '               ; zak†zanÇ znaky

         db        HistFile                 ; historie specifikac° souborñ
         db        1                        ; poáet p©edvoleb
SNSMnPr1 dw        0                        ; dÇlka p©edvolby
         dd        SRSMnPl4+1               ; adresa p©edvolby

SNSMnPol db        bit6,20,'Zkop°rovat ',0,1
         dw        SRSMnPl4
         db        0,' do:'

         db        0,0
         db        bit6+bit7,0
         db        1,7,'Kop°ruj'
         db        1,6,'N†vrat'

SNSMnBlk db        0,0,0                    ; blokovac° tabulka

SNSMnTit db        5,'kopie'

HelpS    SEGMENT   BYTE PUBLIC
SNSMnHlp db        58,'Zadejte novÇ jmÇno ke zkop°rov†n° ',1
         dw        SRSMnPl4
         db        ' (1 aë 8 znakñ)'

         db        23,'Kopie do zadanÇho jmÇna'

         db        3,1
         dw        MenuHlP1
HelpS    ENDS

SNSMnHls db        15,'Kop°ruji ',0,1
         dd        SRSMnPl4

; ------ menu F7 - zaloëen° novÇ skupiny

SSSMnLin label     byte

         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        3                        ; poáet platnòch poloëek menu
         dw        5                        ; celkovò poáet poloëek menu

         dw        SSSMnPol                 ; zaá†tek definice poloëek menu
         dw        SSSMnHlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@PodmenuZvlastni      ; á°slo str†nky velkÇ n†povàdy
         dw        SSSMnBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        SSSMnTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        20                       ; poá†teán° pozice okna
         db        0                        ; poá†teán° ©†dek okna
         db        40                       ; ®°©ka okna
         db        8                        ; vò®ka okna

         dw        8                        ; maxim†ln° dÇlka textu ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        1                        ; celkovò poáet ©†dkñ
         dw        1                        ; poáet zobrazenòch ©†dkñ

         db        bit3                     ; maska zad†vanòch znakñ - soubor
         db        6,'?*.\: '               ; zak†zanÇ znaky

         db        HistFile                 ; historie specifikac° souborñ
         db        0                        ; poáet p©edvoleb

SSSMnPol db        bit6,19,'JmÇno novÇ skupiny:'
         db        0,0
         db        bit6+bit7,0
         db        1,5,'Zaloë'
         db        1,6,'N†vrat'

SSSMnBlk db        0,0,0                    ; blokovac° tabulka

SSSMnTit db        12,'nov† skupina'

HelpS    SEGMENT   BYTE PUBLIC
SSSMnHlp db        45,'Zadejte jmÇno novÇ skupiny (1 aë 8 znakñ)'
         db        34,'Zaloëen° novÇ skupiny podle zad†n°'

         db        3,1
         dw        MenuHlP1
HelpS    ENDS

; ------ hl†®en° - skupinu nelze vytvo©it

SS2MnLin label     byte
         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        1                        ; poáet platnòch poloëek menu
         dw        5                        ; celkovò poáet poloëek menu

         dw        SS2MnPol                 ; zaá†tek definice poloëek menu
         dw        ChbLnMeH                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@PodmenuZvlastni      ; á°slo str†nky velkÇ n†povàdy
         dw        SS2MnBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        SS2MnTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        20                       ; poá†teán° pozice okna
         db        0                        ; poá†teán° ©†dek okna
         db        44                       ; ®°©ka okna
         db        9                        ; vò®ka okna

         dw        255                      ; maxim†ln° dÇlka textu ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        0                        ; celkovò poáet ©†dkñ
         dw        0                        ; poáet zobrazenòch ©†dkñ

         db        bit3                     ; maska zad†vanòch znakñ - soubor
         db        0,'      '               ; zak†zanÇ znaky

         db        0                        ; historie specifikac° souborñ
         db        0                        ; poáet p©edvoleb

SS2MnPol db        bit6,0
         db        bit6,29,'Skupinu ',0,1
         dw        LinNum
         db        ' ',0,'nelze zaloëit !'
         db        bit6,0
         db        bit6+bit7,0
         db        1,6,'N†vrat'

SS2MnBlk db        0                        ; blokovac° tabulka

SS2MnTit db        13,'nelze zaloëit'

; ------ menu F8 - zru®en° poloëky

SRSMnLin label     byte
         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        2                        ; poáet platnòch poloëek menu
         dw        7                        ; celkovò poáet poloëek menu

         dw        SRSMnPol                 ; zaá†tek definice poloëek menu
         dw        SRSMnHlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@PodmenuZvlastni      ; á°slo str†nky velkÇ n†povàdy
         dw        SRSMnBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        SRSMnTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        20                       ; poá†teán° pozice okna
         db        0                        ; poá†teán° ©†dek okna
         db        44                       ; ®°©ka okna
         db        10                       ; vò®ka okna

         dw        255                      ; maxim†ln° dÇlka textu ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        0                        ; celkovò poáet ©†dkñ
         dw        0                        ; poáet zobrazenòch ©†dkñ

         db        bit3                     ; maska zad†vanòch znakñ - soubor
         db        0,'      '               ; zak†zanÇ znaky

         db        0                        ; historie specifikac° souborñ
         db        0                        ; poáet p©edvoleb

SRSMnPol db        bit6,0
         db        bit6,10,0,'VAROVèNã:'
         db        bit6,18,'Zru®°m ',1
SRSMnPl1 dw        SeznTx1X
         db        ' ',0,1
         dw        SRSMnPl4
         db        0,' !'

         db        bit6,0
         db        bit6+bit7,0
         db        1,6,'Zru®it'
         db        1,6,'N†vrat'

SRSMnPl3 db        7,'skupinu'

SRSMnPl4 db        8,'        '

SRSMnBlk db        0,0                      ; blokovac° tabulka

SRSMnTit db        6,'ru®en°'

HelpS    SEGMENT   BYTE PUBLIC
SRSMnHlp db        23,'Zru®en° zvolenÇ poloëky'
         db        3,1
         dw        MenuHlP1
HelpS    ENDS

; ------ menu - zru®en° seznamu 1

SR1MnLin label     byte
         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        2                        ; poáet platnòch poloëek menu
         dw        6                        ; celkovò poáet poloëek menu

         dw        SR1MnPol                 ; zaá†tek definice poloëek menu
         dw        SRSMnHlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@PodmenuZvlastni      ; á°slo str†nky velkÇ n†povàdy
         dw        SR1MnBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        SRSMnTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        20                       ; poá†teán° pozice okna
         db        0                        ; poá†teán° ©†dek okna
         db        50                       ; ®°©ka okna
         db        9                        ; vò®ka okna

         dw        255                      ; maxim†ln° dÇlka textu ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        0                        ; celkovò poáet ©†dkñ
         dw        0                        ; poáet zobrazenòch ©†dkñ

         db        bit3                     ; maska zad†vanòch znakñ - soubor
         db        0,'      '               ; zak†zanÇ znaky

         db        0                        ; historie specifikac° souborñ
         db        0                        ; poáet p©edvoleb

SR1MnPol db        bit6,0
         db        bit6,25,'Chcete zru®it ',1
SR1MnPl1 dw        SeznTx1X
         db        ' ',0,1
         dw        SRSMnPl4
         db        0,' ?'

         db        bit6,0
         db        bit6+bit7,0
         db        1,6,'Zru®it'
         db        1,6,'N†vrat'

SR1MnBlk db        0,0                      ; blokovac° tabulka

; ------ hl†®en° - skupinu nelze zru®it

SR2MnLin label     byte
         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        1                        ; poáet platnòch poloëek menu
         dw        6                        ; celkovò poáet poloëek menu

         dw        SR2MnPol                 ; zaá†tek definice poloëek menu
         dw        ChbLnMeH                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@PodmenuZvlastni      ; á°slo str†nky velkÇ n†povàdy
         dw        SR2MnBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        SR2MnTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        20                       ; poá†teán° pozice okna
         db        0                        ; poá†teán° ©†dek okna
         db        44                       ; ®°©ka okna
         db        10                       ; vò®ka okna

         dw        255                      ; maxim†ln° dÇlka textu ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        0                        ; celkovò poáet ©†dkñ
         dw        0                        ; poáet zobrazenòch ©†dkñ

         db        bit3                     ; maska zad†vanòch znakñ - soubor
         db        0,'      '               ; zak†zanÇ znaky

         db        0                        ; historie specifikac° souborñ
         db        0                        ; poáet p©edvoleb

SR2MnPol db        bit6,0
         db        bit6,27,'Skupinu ',0,1
         dw        SRSMnPl4
         db        ' ',0,'nelze zru®it,'
         db        bit6,28,'obsahuje nezru®enÇ poloëky !'
         db        bit6,0
         db        bit6+bit7,0
         db        1,6,'N†vrat'

SR2MnBlk db        0,0                      ; blokovac° tabulka

SR2MnTit db        12,'nelze zru®it'

SRSMnHls db        12,'Ru®°m ',0,1
         dd        SRSMnPl4

; ------ hl†®en° - text nelze zru®it

SR3MnLin label     byte
         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        1                        ; poáet platnòch poloëek menu
         dw        6                        ; celkovò poáet poloëek menu

         dw        SR3MnPol                 ; zaá†tek definice poloëek menu
         dw        ChbLnMeH                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@PodmenuZvlastni      ; á°slo str†nky velkÇ n†povàdy
         dw        SR2MnBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        SR2MnTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        20                       ; poá†teán° pozice okna
         db        0                        ; poá†teán° ©†dek okna
         db        45                       ; ®°©ka okna
         db        10                       ; vò®ka okna

         dw        255                      ; maxim†ln° dÇlka textu ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        0                        ; celkovò poáet ©†dkñ
         dw        0                        ; poáet zobrazenòch ©†dkñ

         db        bit3                     ; maska zad†vanòch znakñ - soubor
         db        0,'      '               ; zak†zanÇ znaky

         db        0                        ; historie specifikac° souborñ
         db        0                        ; poáet p©edvoleb

SR3MnPol db        bit6,0
         db        bit6,34,'Zvolenò soubor '
         db        0,1
         dw        SRSMnPl4
         db        0,' nelze zru®it,'
         db        bit6,35,'m† nastavenu ochranu proti ru®en° !'
         db        bit6,0
         db        bit6+bit7,0
         db        1,6,'N†vrat'

; ------ menu F9 - nadpis

SASMnLin label     byte
         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        3                        ; poáet platnòch poloëek menu
         dw        5                        ; celkovò poáet poloëek menu

         dw        SASMnPol                 ; zaá†tek definice poloëek menu
         dw        SASMnHlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@PodmenuZvlastni      ; á°slo str†nky velkÇ n†povàdy
         dw        SASMnBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        SASMnTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        20                       ; poá†teán° pozice okna
         db        0                        ; poá†teán° ©†dek okna
         db        DelKomDB+11              ; ®°©ka okna
         db        8                        ; vò®ka okna

         dw        DelKomDB+9               ; maxim†ln° dÇlka textu ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        1                        ; celkovò poáet ©†dkñ
         dw        1                        ; poáet zobrazenòch ©†dkñ

         db        bit2                     ; maska zad†vanòch znakñ - v®echny
         db        3,13,10,0,'   '          ; zak†zanÇ znaky

         db        HistKom                  ; historie koment†©ñ
SASMnPN1 db        0                        ; poáet p©edvoleb
SASMnPD1 dw        0                        ; dÇlka p©edvolby
SASMnPA1 dd        0                        ; adresa p©edvolby

SASMnPol db        bit6,20,'Novò nadpis skupiny:'
         db        0,0
         db        bit6+bit7,0
         db        2,6,' Uloë '
         db        1,6,'N†vrat'

SASMnBlk db        0,0,0                    ; blokovac° tabulka

SASMnTit db        6,'nadpis'

HelpS    SEGMENT   BYTE PUBLIC
SASMnHlp db        45,'Zadejte novò nadpis skupiny (max. 59 znakñ)'
         db        24,'Uloëen° zadanÇho nadpisu'
         db        3,1
         dw        MenuHlP2
HelpS    ENDS

; ------ data pro seznam

SeznPthF db        11 dup(0)                ; poloëka FCB k nastaven° kurzoru

SeznProt db        'PROTOTYP.$$$'           ; prototyp souborñ
SeznPrt0 label     byte

SeznExtF db        '*.   '                  ; specifikace *.NOT nebo *.DBF

SeznSegN dw        0                        ; velikost bufferu
SeznSegm dw        0                        ; pracovn° buffer

SeznPath db        FileMax+4 dup(0)         ; adres†© seznamu

Data     ENDS

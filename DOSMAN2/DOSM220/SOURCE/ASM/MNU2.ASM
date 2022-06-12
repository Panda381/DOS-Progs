
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                                   M E N U
;
;                                Obsluha voleb
;
; =============================================================================
;
;        InitHist (FAR) - inicializace segmentu histori°
;        GetHist  (FAR) - poskytnut° adresy a velikosti historie
;        Srchist  (FAR) - nalezen° ©etàzce v historii
;        DelHist  (FAR) - zru®en° ©etàzce z historie
;        InsHist  (FAR) - vloëen° ©etàzce do historie
;
;        Lin0Menu (FAR) - obsluha ©†dkovÇho menu s plnou obsluhou
;          Lin0MenR (FAR) - n†vrat z menu do procedury Lin0Menu
;        LineMenu (FAR) - obsluha ©†dkovÇho menu
;        InitLMnu (FAR) - inicializace ©†dkovÇho menu
;        RedLMnu  (FAR) - redukce textu ©†dkovÇho menu
;        HistLMnu (FAR) - uloëen° ©†dku z ©†dkovÇho menu do historie
;        EditLMnu (FAR) - editace ©†dkovÇho menu
;        EditLine (FAR) - editace ©†dku ©†dkovÇho menu
;        DispLine (FAR) - zobrazen° ©†dku ©†dkovÇho menu
;        DispLMnu (FAR) - zobrazen° ©†dkovÇho menu
;
;        DiskMenu (FAR) - obsluha menu volby disku
;        InitDMnu (FAR) - inicializace menu volby disku
;        EditDMnu (FAR) - editace menu volby disku
;        DispDMnu (FAR) - zobrazen° menu volby disku
;
;        DiskMnu  (BYTE) - menu volby disku
;        DiskMPlL (BYTE) - nadpis menu volby disku - levÇ okno
;        DiskMPlR (BYTE) - nadpis menu volby disku - pravÇ okno
;        DiskMHl2 (BYTE) - n†povàda k editaci koment†©e disku
;
;        LinMax   (BYTE) - maxim†ln° dÇlka editovanÇho ©†dku ©†dkovÇho menu
;        LinNum   (BYTE) - poáet znakñ v editovanÇm ©†dku ©†dkovÇho menu
;        LinTop   (BYTE) - zobrazen° poá†tek editovanÇho ©†dku ©†dkovÇho menu
;        LinKur   (BYTE) - kurzor v editovanÇm ©†dku ©†dkovÇho menu
;        LinRad   (BYTE) - ©†dek na displeji k zobrazen° edit. ©†dku ©†dk. menu
;        LinBuff  (BYTE) - editaán° buffer editovanÇho ©†dku ©†dkovÇho menu
;
;        ColMnu7  (BYTE) - barva bàënÇho ©†dku ©†dkovÇho menu
;        ColMnu8  (BYTE) - barva ©†dku s kurzorem ©†dkovÇho menu
;        ColMnu9  (BYTE) - barva editovanÇho ©†dku ©†dkovÇho menu
;        ColMnuA  (BYTE) - barva znaku p©eteáen° dÇlky ©†dku ©†dkovÇho menu
;
;        HistSeg  (WORD) - á°slo datovÇho bloku histori°
;        HistSizT (WORD) - tabulka maxim†ln°ch velikost° jednotlivòch histori°
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

INCLUDE  ASM\DEF.ASM

CodeMnu  SEGMENT   BYTE PUBLIC
         ASSUME    cs:CodeMnu,ds:Data

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                    Obsluha histori° textovòch parametrñ
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
; *****************************************************************************
;                                InitHist
;                     inicializace segmentu histori°
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP: CY=nedostatek pamàti
; niá° v®echny registry kromà DS
; *****************************************************************************

InitHist PROC      FAR

; ------ £schova registrñ

         mov       bp,sp
         sub       sp,FileMax               ; buffer pro jmÇno souboru

; ------ vytvo©en° segmentu histori°

         mov       word ptr ds:[HistSeg],0  ; nen° segment histori°
         call      far ptr CreatSeg         ; vytvo©en° segmentu histori°
         jnc       InitHst2                 ; OK
         jmp       InitHst9                 ; nedostatek pamàti

; ------ sestaven° jmÇna souboru histori°

InitHst2:mov       ds:[HistSeg],ax          ; £schova segmentu histori°
         push      ss
         pop       es
         mov       di,sp                    ; buffer jmÇna souboru
         mov       si,offset DosmHist       ; jmÇno souboru $DOSMAN$.HIS
         call      far ptr TempFile         ; sestaven° jmÇna souboru

; ------ otev©en° souboru histori°

         mov       si,sp
         call      far ptr OpenR            ; otev©en° souboru histori°
         jc        InitHst6                 ; soubor histori° nenalezen

; ------ zji®tàn° velikosti souboru

         call      far ptr SizeFile         ; stanoven° velikosti souboru
         jc        InitHst5                 ; nàjak† chyba
         or        bx,bx
         jnz       InitHst5                 ; chyba
         mov       bx,cx                    ; BX <- velikost souboru
         call      far ptr ResFile          ; resetov†n° ukazatele souboru

; ------ nastaven° velikosti bufferu

         push      ax
         mov       ax,ds:[HistSeg]          ; segment histori°
         call      far ptr GetDat           ; adresa segmentu histori°
         call      far ptr ModiSegS         ; nastaven° velikosti segmentu
         pop       ax
         jc        InitHst5                 ; chyba pamàti

; ------ naáten° souboru do bufferu

         xor       di,di                    ; ukl†dac° adresa
         call      far ptr ReadFile         ; naáten° souboru do bufferu
         jc        InitHst5                 ; chyba
         cmp       cx,bx
         jne       InitHst5                 ; chyba

; ------ test obsahu souboru

         call      far ptr ClosFile         ; uzav©en° souboru
         call      TstSHist                 ; test bufferu histori° (CX bajtñ)
         jnc       InitHst9                 ; v®e je OK

; ------ adresa segmentu histori°

         xor       ax,ax                    ; AX <- 0 (soubor je jië uzav©en)
InitHst5:call      far ptr ClosFile         ; uzav©en° souboru AX
InitHst6:mov       ax,ds:[HistSeg]          ; segment histori°
         call      far ptr GetDat           ; poskytnut° adresy datovÇho bloku

; ------ inicializace velikosti seznamu

         mov       bx,HistNum*HistSbeg+2    ; inicializaán° velikost seznamu
         call      far ptr ModiSegS         ; nastaven° velikosti seznamu
         jc        InitHst8                 ; nedostatek pamàti

; ------ inicializace seznamu histori°

         cld
         xor       di,di                    ; poá†teán° adresa v seznamu
         xchg      ax,bx                    ; AX <- velikost seznamu
         stosw                              ; velikost seznamu
         mov       cx,HistNum               ; poáet seznamñ histori°
InitHst7:mov       ax,HistSBeg              ; velikost jednoho seznamu
         stosw                              ; offset dal®°ho seznamu
         xor       ax,ax                    ; poáet poloëek v seznamu = 0
         stosw                              ; poáet poloëek v jednom seznamu
         loop      InitHst7                 ; dal®° seznam
         jmp       short InitHst9         ;* zde je NC = operace OK

; ------ p©i chybà zru®en° segmentu histori°

InitHst8:mov       ax,ds:[HistSeg]          ; segment histori°
         call      far ptr DelSeg           ; zru®en° segmentu
         mov       ds:[HistSeg],ax          ; zru®en° á°sla segmentu
         stc                                ; p©°znak chyby

; ------ n†vrat registrñ

InitHst9:mov       sp,bp
         ret

InitHist ENDP

; -----------------------------------------------------------------------------
;        test naátenÇho bufferu histori° (segment ES, CX bajtñ)
; -----------------------------------------------------------------------------

TstSHist PROC      NEAR

; ------ kontroln° souáet souboru

         mov       dx,es:[0]                ; kontroln° souáet souboru
         mov       es:[0],cx                ; poáet bajtñ v bufferu
         xor       ax,ax                    ; vòchoz° konstanta
         mov       si,2                     ; vòchoz° adresa
         sub       cx,2                     ; poáet zbylòch dat
         jbe       TstSHst8                 ; chyba
TstSHst2:rol       ax,1
         xor       al,es:[si]
         inc       si
         loop      TstSHst2
TstSHst4:cmp       ax,dx                    ; souhlas° kontroln° souáet ?
         jne       TstSHst8                 ; kontroln° souáet nesouhlas°

; ------ ovà©en° struktury souboru

         mov       dx,es:[0]                ; adresa konce dat
         cmp       dx,-4                    ; asi tak maxim†ln° konec
         jae       TstSHst8                 ; chyba
         mov       bx,HistNum               ; poáet histori°
         mov       si,2                     ; ukazatel histori°
         mov       di,si                    ; adresa zaá†tku histori°
TstSHst5:cmp       si,dx                    ; je konec dat ?
         jae       TstSHst8                 ; konec dat - chyba
         add       di,es:[si+HistSOfs]      ; offset dal®°ho seznamu
         jc        TstSHst8                 ; chyba
         mov       cx,es:[si+HistSNum]      ; poáet poloëek histori°
         add       si,HistSBeg              ; zaá†tek histori° jednoho seznamu
         jcxz      TstSHst7                 ; nen° ë†dn† poloëka
TstSHst6:mov       ax,es:[si+HistDelk]      ; dÇlka jednÇ poloëky
         and       ax,HistDelM              ; dÇlka jednÇ poloëky
         inc       si
         inc       si
         add       si,ax                    ; adresa dal®° poloëky
         jc        TstSHst8                 ; chyba
         loop      TstSHst6                 ; dal®° poloëka
TstSHst7:cmp       si,di                    ; souhlas° adresa dal®°ho seznamu ?
         jne       TstSHst8                 ; nesouhlas°
         dec       bx                       ; á°taá histori°
         jnz       TstSHst5                 ; test dal®°ho seznamu

         cmp       si,dx                    ; souhlas° adresa konce ?
         je        TstSHst9                 ; adresa souhlas° OK

TstSHst8:stc
TstSHst9:ret

TstSHist ENDP

; *****************************************************************************
;                             StoSHist
;                 uloëen° segmentu histori° na disk
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

StoSHist PROC      FAR

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
         sub       sp,FileMax

; ------ test, zda byl soubor modifikov†n

         test      byte ptr ds:[HistSPar],bit0 ; byl buffer modifikov†n ?
         jz        StoSHst9                 ; buffer nebyl modifikov†n
         and       byte ptr ds:[HistSPar],not bit0 ; zru®en° p©°znaku modifikace

; ------ sestaven° jmÇna k souboru

         push      ss
         pop       es                       ; ES <- segment z†sobn°ku
         mov       di,sp                    ; DI <- buffer jmÇna v z†sobn°ku
         mov       si,offset DosmHist       ; jmÇno souboru $DOSMAN$.HIS
         call      far ptr TempFile         ; sestaven° jmÇna souboru

; ------ vytvo©en° souboru

         test      byte ptr ds:[TempDirP],bit0 ; je z†kaz z†pisu ?
         stc                                ; p©°znak chyby
         jnz       StoSHst9                 ; je z†kaz z†pisu
         mov       si,sp                    ; SI <- buffer jmÇna v z†sobn°ku
         call      far ptr CreatFil         ; vytvo©en° souboru
         jc        StoSHst9                 ; chyba

         push      ax                       ; identifik†tor souboru

; ------ adresa bufferu s daty

         mov       ax,ds:[HistSeg]          ; segment s bufferem
         call      far ptr GetDat           ; adresa bufferu

; ------ kontroln° souáet dat v bufferu

         mov       cx,es:[0]                ; poáet bajtñ v bufferu
         mov       dx,cx                    ; DX <- £schova poátu bajtñ
         push      cx
         xor       ax,ax                    ; vòchoz° konstanta
         mov       si,2                     ; vòchoz° adresa
         sub       cx,2                     ; poáet zbylòch dat
         jbe       StoSHst4                 ; nejsou ë†dn† data
StoSHst2:rol       ax,1
         xor       al,es:[si]
         inc       si
         loop      StoSHst2
StoSHst4:mov       es:[0],ax                ; kontroln° souáet dat
         pop       cx

; ------ z†pis dat do souboru

         pop       ax                       ; identifik†tor souboru

         xor       si,si                    ; poá†tek bufferu
         call      far ptr WritFile         ; z†pis dat do souboru
         call      far ptr ClosFile         ; uzav©en° souboru
         mov       es:[si],dx               ; n†vrat poátu bajtñ v bufferu

; ------ n†vrat registrñ

StoSHst9:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

StoSHist ENDP

; *****************************************************************************
;                               GetHist
;                poskytnut° adresy seznamu histori°
; -----------------------------------------------------------------------------
; VSTUP: AL=á°slo seznamu histori° (1, 2, ...)
;        DS=datovò segment
; VùSTUP:CY=chybnÇ á°slo seznamu histori° (nebo nen° segment histori° -> BX=0)
;        BX=maxim†ln° velikost seznamu histori° (p©i chybà CY je BX=0)
;        ES:DI=zaá†tek definice seznamu histori°
; *****************************************************************************

GetHist  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      cx

; ------ adresa segmentu histori°

         mov       ah,0
         xchg      ax,cx                    ; CX <- á°slo historie
         xor       bx,bx                    ; maxim†ln° velikost seznamu = 0

         mov       di,2                     ; zaá†tek prvn° historie
         mov       ax,ds:[HistSeg]          ; segment histori°
         call      far ptr GetDat           ; poskytnut° adresy segmentu
         jc        GetHist9                 ; nàjak† chyba - asi nen° seznam

; ------ kontrola á°sla historie

         cmp       cl,1                     ; minim†ln° á°slo
         jb        GetHist9                 ; chybnÇ á°slo historie
         cmp       cl,HistNum+1             ; maxim†ln° á°slo historie
         cmc
         jc        GetHist9                 ; chybnÇ á°slo historie

; ------ maxim†ln° velikost historie

         mov       bx,offset HistSizT-2     ; tabulka velikost° histori° - 2
         add       bx,cx
         add       bx,cx                    ; adresa maxim†ln° velikosti
         mov       bx,ds:[bx]               ; maxim†ln° velikost historie

; ------ nalezen° poëadovanÇ historie

         dec       cx                       ; á°taá á°sla historie
         jz        GetHist4                 ; je prvn° historie
GetHist2:add       di,es:[di+HistSOfs]      ; adresa dal®°ho seznamu
         loop      GetHist2                 ; test dal®° historie
GetHist4:clc                                ; p©°znak operace OK

; ------ n†vrat registrñ

GetHist9:pop       cx
         pop       ax
         ret

GetHist  ENDP

; *****************************************************************************
;                                SrcHist
;                  nalezen° historie v seznamu histori°
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=adresa seznamu histori°
;        DX:SI=text hledanÇ poloëky
;        CX=dÇlka textu poloëky
; VùSTUP:ES:SI=adresa nalezenÇ poloëky (p©i chybà CY je SI=konec seznamu)
;        CY=poloëka nenalezena
; *****************************************************************************

SrcHist  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      di
         push      ds

; ------ p©°prava registrñ k hled†n°

         mov       ds,dx                    ; DS <- segment hledanÇ poloëky
         mov       dx,di                    ; zaá†tek seznamu
         add       dx,es:[di+HistSOfs]      ; konec seznamu historie
         add       di,HistSBeg              ; zaá†tek prvn° poloëky
         cld

; ------ kontrola, zda je jië konec seznamu poloëek

SrcHist2:cmp       di,dx                    ; je jië konec seznamu ?
         jae       SrcHist8                 ; nen° dal®° poloëka

; ------ porovn†n° dÇlky poloëky

         mov       ax,es:[di+HistDelk]      ; dÇlka textu poloëky
         and       ax,HistDelM              ; dÇlka textu poloëky
         cmp       ax,cx                    ; souhlas° dÇlka poloëky ?
         jne       SrcHist3                 ; dÇlka poloëky nesouhlas°

; ------ porovn†n° textu poloëky

         push      si
         push      di
         inc       di
         inc       di                       ; zaá†tek textu poloëky
         cmp       ax,ax                    ; nastaven° p©°znaku ZY
         repe      cmpsb                    ; porovn†n° textñ
         mov       cx,ax                    ; CX <- n†vrat dÇlky textu poloëky
         pop       di
         pop       si
         je        SrcHist9                 ; poloëka nalezena OK

; ------ adresa dal®° poloëky

SrcHist3:inc       di                       ; zaá†tek textu poloëky
         inc       di
         add       di,ax                    ; adresa dal®° poloëky
         jnc       SrcHist2                 ; kontrola dal®° poloëky

; ------ p©i chybà se nastav° konec seznamu

SrcHist8:mov       di,dx                    ; konec seznamu
         stc                                ; p©°znak chyby

; ------ n†vrat registrñ

SrcHist9:mov       si,di                    ; adresa nalezenÇ poloëky
         pop       ds
         pop       di
         pop       dx
         pop       cx
         pop       ax
         ret

SrcHist  ENDP

; *****************************************************************************
;                                   DelHist
;                   zru®en° poloëky ze seznamu histori°
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=adresa seznamu histori°
;        ES:SI=adresa ru®enÇ poloëky
;        DS=datovò segment
; VùSTUP:CY=chybn† adresa, nen° dal®° poloëka nebo je z†kaz ru®en° poloëky
; *****************************************************************************

DelHist  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      cx
         xchg      si,di                    ; SI <- seznam, DI <- ru®en† poloëka

; ------ kontrola, zda je je®tà nàjak† poloëka

         cmp       word ptr es:[si+HistSNum],0 ; je je®tà nàjak† poloëka ?
         stc                                ; p©°znak chyby
         je        DelHist9                 ; nen° jië ë†dn† poloëka

; ------ test, zda je z†kaz ru®en° poloëky

         mov       cx,es:[di+HistDelk]      ; dÇlka textu poloëky
         test      ch,bit15/HI              ; je z†kaz ru®en° ?
         stc                                ; p©°znak chyby
         jnz       DelHist9                 ; je z†kaz ru®en° poloëky

; ------ zru®en° poloëky

         and       cx,HistDelM              ; dÇlka textu poloëky
         inc       cx
         inc       cx                       ; dÇlka celÇ poloëky
         mov       ax,ds:[HistSeg]          ; segment s histori°
         call      far ptr DelDat           ; zru®en° poloëky z bufferu
         jc        DelHist9                 ; nàjak† chyba

; ------ oprava ukazatelñ

         or        byte ptr ds:[HistSPar],bit0 ; p©°znak modifikace bufferu
         dec       word ptr es:[si+HistSNum] ; sn°ëen° poátu poloëek seznamu
         sub       es:[si+HistSOfs],cx      ; oprava offsetu dal®° poloëky
                                          ;* zde je NC = p©°znak operace OK

; ------ n†vrat registrñ

DelHist9:xchg      si,di                    ; n†vrat registrñ
         pop       cx
         pop       ax
         ret

DelHist  ENDP

; *****************************************************************************
;                               HistADir
;            uloëen° aktivn°ho adres†©e do historie adres†©ñ
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; uchov†v† registr p©°znakñ !
; *****************************************************************************

HistADir PROC      FAR

; ------ £schova registrñ

         pushf
         push      ax
         push      cx
         push      si
         push      es

; ------ uloëen° adres†©e

         mov       al,HistAdr               ; historie adres†©ñ
         push      ds
         pop       es
         mov       si,offset AktPath        ; aktu†ln° adres†©
         mov       ch,0
         mov       cl,byte ptr ds:[AktPathN] ; dÇlka textu adres†©e
         call      far ptr InsHist          ; uloëen° do historie

; ------ n†vrat registrñ

         pop       es
         pop       si
         pop       cx
         pop       ax
         popf
         ret

HistADir ENDP

; *****************************************************************************
;                                InsHist
;            uloëen° novÇ poloëky do seznamu histori° (posouv† adresy !)
; -----------------------------------------------------------------------------
; VSTUP: AL=á°slo historie (1, 2, ...)
;        ES:SI=text ukl†danÇ poloëky (pozor, posouvaj° se adresy !)
;        CX=dÇlka textu poloëky
;        DS=datovò segment
; VùSTUP:CY=chyba - nedostatek pamàti
; *****************************************************************************

InsHist  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ p©°prava registrñ

         mov       dx,es                    ; DX <- segment adresy textu

; ------ adresa seznamu histori°

         call      far ptr GetHist          ; adresa historie ES:DI, max. BX
         jc        InsHist9                 ; historie nenalezena

; ------ omezen° dÇlky poloëky na maxim†ln° velikost seznamu

         sub       bx,HistSBeg+HistTxt      ; odeáten° hlaviáek
         jb        InsHist9                 ; to je nàjak† chyba
         cmp       cx,bx                    ; je text del®° neë maximum ?
         jb        InsHist1                 ; dÇlka textu je OK
         mov       cx,bx                    ; omezen° dÇlky textu

; ------ zru®en° stejnÇ poloëky v seznamu (pokud nen° R/O)

InsHist1:push      si
         call      far ptr SrcHist          ; nalezen° poloëky v seznamu
         jc        InsHist3                 ; poloëka nenalezena
         call      far ptr DelHist          ; zru®en° poloëky ze seznamu
         cmc                                ; CY = poloëka byla zru®ena OK
InsHist3:pop       si
         jnc       InsHist9                 ; z†kaz ru®en° poloëky

; ------ uvolnàn° m°sta pro novou poloëku

         push      si
         mov       si,di                    ; zaá†tek seznamu
         add       si,HistSBeg              ; adresa prvn° poloëky
         add       bx,HistSBeg              ; maxim†ln° velikost seznamu - 2
         sub       bx,cx                    ; maxim†ln° pot©ebn† velikost bloku
InsHist4:cmp       bx,es:[di+HistSOfs]      ; je velikost jië dostateánà mal† ?
         jae       InsHist5                 ; je jië dost volnÇho m°sta
         call      far ptr DelHist          ; zru®en° prvn° poloëky seznamu
         jnc       InsHist4                 ; novò test, zda je jië dost m°sta
InsHist5:pop       si
         jc        InsHist9                 ; nen° dost m°sta k vloëen° poloëky

; ------ uloëen° novÇ poloëky na konec seznamu

InsHist6:inc       cx
         inc       cx                       ; m°sto pro £daj dÇlky poloëky
         mov       bx,di                    ; £schova zaá†tku definice historie
InsHst62:add       di,es:[di+HistSOfs]      ; konec seznamu
         mov       ax,ds:[HistSeg]          ; segment s histori°
         call      far ptr InsDat           ; vytvo©en° m°sta pro poloëku
         jnc       InsHist7                 ; je dost m°sta OK

; ------ p©i nedostatku pamàti zru®en° prvn° poloëky (chyba, nen°-li dal®° pol.)

         mov       di,bx                    ; n†vrat adresy definice historie
         push      si
         mov       si,di                    ; zaá†tek seznamu
         add       si,HistSBeg              ; adresa prvn° poloëky
         call      far ptr DelHist          ; zru®en° prvn° poloëky seznamu
         pop       si
         jc        InsHist9                 ; nen° dal®° poloëka ke zru®en°
         jmp       short InsHst62           ; jinak dal®° pokus

; ------ oprava ukazatelñ

InsHist7:add       es:[bx+HistSOfs],cx      ; zvò®en° ukazatele dal®° historie
         inc       word ptr es:[bx+HistSNum] ; zvò®en° poátu histori°
         or        byte ptr ds:[HistSPar],bit0 ; p©°znak modifikace bufferu

; ------ p©enos novÇ poloëky do bufferu

         cld
         dec       cx
         dec       cx                       ; dÇlka textu poloëky
         mov       ax,cx                    ; dÇlka textu poloëky
         stosw                              ; dÇlka textu poloëky
         push      ds
         mov       ds,dx                    ; segment vkl†danÇ poloëky
         rep       movsb                    ; p©enos textu poloëky
         pop       ds

; ------ set©°dàn° historie (chr†nànÇ poloëky na konec)

         call      far ptr SrtHist          ; set©°dàn° historie
         clc                                ; p©°znak operace OK

; ------ n†vrat registrñ

InsHist9:pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

InsHist  ENDP

; *****************************************************************************
;                                 SrtHist
;                            set©°dàn° histori°
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

SrtHist  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ p©°prava registrñ

         mov       di,2                     ; ukazatel adresy v bufferu
         mov       ax,ds:[HistSeg]          ; segment histori°
         call      far ptr GetDat           ; adresa segmentu -> ES
         jc        SrtHist9                 ; chyba ?

; ------ test, zda jsou jië v®echny historie

SrtHist1:cmp       di,es:[HistByts]         ; jsou jië v®echny historie ?
         jae       SrtHist9                 ; jsou jië v®echny historie

; ------ p©°prava ukazatelñ v seznamu

         mov       dx,di                    ; DX <- adresa zaá†tku seznamu
         add       dx,es:[di+HistSOfs]      ; zaá†tek dal®°ho seznamu
         jc        SrtHist9                 ; to je nàjak† chyba
         add       di,HistSBeg              ; zaá†tek prvn° poloëky

; ------ nalezen° prvn° chr†nànÇ poloëky -> ES:DI/CX

SrtHist2:cmp       di,dx                    ; je jië konec seznamu ?
         jae       SrtHist8                 ; je jië konec seznamu
         mov       cx,es:[di+HistDelk]      ; dÇlka poloëky
         test      ch,bit15/HI              ; chr†nàn† poloëka ?
         jnz       SrtHist3                 ; nalezena chr†nàn† poloëka
         and       cx,HistDelM              ; dÇlka poloëky
         inc       di
         inc       di
         add       di,cx                    ; adresa dal®° poloëky
         jmp       short SrtHist2           ; dal®° hled†n°

; ------ nalezen° nechr†nànÇ poloëky -> ES:SI/CX

SrtHist3:mov       si,di                    ; SI <- prvn° chr†nàn† poloëka
SrtHist4:and       cx,HistDelM              ; dÇlka poloëky
         inc       si
         inc       si
         add       si,cx                    ; adresa dal®° poloëky
         jc        SrtHist9
SrtHist5:cmp       si,dx                    ; je jië konec seznamu ?
         jae       SrtHist8                 ; je jië konec seznamu
         mov       cx,es:[si+HistDelk]      ; dÇlka poloëky
         test      ch,bit15/HI              ; chr†nàn† poloëka ?
         jnz       SrtHist4                 ; je to chr†nàn† poloëka - dal®°

; ------ vytvo©en° m°sta k vloëen° poloëky ES:SI p©ed chr†nànou poloëku ES:DI

         and       cx,HistDelM              ; dÇlka poloëky
         inc       cx
         inc       cx                       ; váetnà dÇlky
         call      far ptr InsDat           ; vytvo©en° m°sta
         jc        SrtHist8                 ; chyba pamàti
         add       si,cx                    ; posun zdrojovÇ poloëky

; ------ p©enesen° poloëky

         cld
         push      si                       ; p©en†®en† poloëka
         push      cx
         rep       movs byte ptr es:[di],es:[si] ; p©enesen° poloëky
         pop       cx
         pop       si                       ; p©en†®en† poloëka

; ------ zru®en° pñvodn° poloëky

         push      di
         mov       di,si                    ; adresa zdrojovÇ poloëky
         call      far ptr DelDat           ; zru®en° pñvodn° poloëky
         pop       di                       ; nov† poloëka
         jmp       short SrtHist5           ; dal®° poloëka

; ------ zpracov†n° dal®°ho seznamu

SrtHist8:mov       di,dx                    ; DI <- zaá†tek dal®°ho seznamu
         jmp       short SrtHist1           ; dal®° seznam

; ------ n†vrat registrñ

SrtHist9:pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

SrtHist  ENDP

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                        ©†dkovÇ (a horizont†ln°) menu
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
; *****************************************************************************
;                                 Lin0MenP
;              obsluha ©†dkovÇho menu DS:DI p©i chybovÇm hl†®en°
;                       uchov†v† registr p©°znakñ !
; -----------------------------------------------------------------------------
; VSTUP: DS:DI=adresa definice menu (!)
;        DS=datovò segment
; *****************************************************************************

Lin0MenP PROC      FAR

         pushf
         push      bx
         push      dx
         push      si

         call      far ptr TestBEsc         ; je p©eru®en° ?
         jc        Lin0MnP2                 ; je p©eru®en°

         mov       si,di                    ; SI <- adresa definice menu
         call      far ptr Lin0MenF         ; obsluha hl†®en°

         call      far ptr SetBreak         ; nastaven° p©eru®en° operace

Lin0MnP2:pop       si
         pop       dx
         pop       bx
         popf
         ret

Lin0MenP ENDP

; *****************************************************************************
;                                 LinPMenu
;                obsluha ©†dkovÇho menu s £schovou zvolenÇ poloëky
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa definice menu
;        DS=datovò segment
; VùSTUP: BX=á°slo provedenÇ volby 1... (p©i p©eru®en° ESC je BX=0)
;         CY=p©eru®en° volby (BX=0) nebo zvolena posledn° poloëka
; *****************************************************************************

LinPMenu PROC      FAR

         push      cx
         push      dx

         call      far ptr InfoClos         ; zru®en° p©°znaku inf. ©†dku
         mov       cx,ds:[si+MnuAkt]        ; pñvodn° aktivn° poloëka
         push      cs
         call      near ptr Lin1Menu        ; obsluha menu
         jnc       LinPMnu2                 ; bylo nàco zvoleno
         mov       ds:[si+MnuAkt],cx        ; p©i p©eru®en° n†vrat poloëky

LinPMnu2:pop       dx
         pop       cx
         ret

LinPMenu ENDP

; *****************************************************************************
;                                 Lin0Menu
;                 obsluha ©†dkovÇho menu s plnou obsluhou
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa definice menu
;        DS=datovò segment
; VùSTUP: BX=á°slo provedenÇ volby 1... (p©i p©eru®en° ESC je BX=0)
;         DX=stav p©ep°naáñ menu
;         CY=p©eru®en° volby (BX=0) nebo zvolena posledn° poloëka
;         SI=zñst†v† nezmànàn (tj. adresa definice menu)
; -----------------------------------------------------------------------------
; V obsluze menu by màla bòt jako adresa obsluhy nastavena adresa Lin0MenR,
; tj. n†vratov† adresa do tÇto procedury. Nesm° bòt p©itom definov†no
; navazuj°c° podmenu (tj. mus° bòt 0) ! Po proveden° volby se okno uzav©e
; a navr†t° se zvolen† poloëka. V p©°padà zvl†®tn° obsluhy je v z†sobn°ku
; uloëena nejd©°ve n†vratov† adresa FAR do procedury LineMenu, potom n†vratov†
; adresa FAR do hlavn° procedury, kter† tuto sluëbu vyvolala.
;
; P©i zvolen° posledn° poloëky menu je navr†cen p©°znak p©eru®en° CY,
; v ostatn°ch p©°padech je uloëena historie menu (pokud nen° historie = 0).
; *****************************************************************************

Lin0MenF LABEL     FAR

         call      far ptr DispAll          ; novÇ zobrazen° v®eho
         call      far ptr FlushChr         ; vypr†zdnàn° bufferu kl†vesnice

Lin0Menu PROC      FAR

         call      far ptr InfoClos         ; zru®en° p©°znaku inf. ©†dku
         mov       byte ptr ds:[si+MnuAkt],1 ; aktivn° poloëka 1

Lin1Menu LABEL     FAR

; ------ obsluha poëadovanÇho menu

         call      far ptr LineMenu         ; obsluha ©†dkovÇho menu

; ------ p©eru®en° volby ESC

         mov       si,bx                    ; n†vrat adresy menu
         xor       bx,bx                    ; zru®en° á°sla volby
Lin0Men2:stc                                ; p©°znak p©eru®en° volby
         jmp       short Lin0Men9

; ------ proveden° nàkterÇ volby

Lin0MenR LABEL     FAR

         add       sp,4                     ; zru®en° n†vratovÇ adresy
         and       byte ptr ds:[LinParm],not bit0 ; nen° Ctrl-ENTER
         cmp       bx,1c0ah                 ; je Ctrl-Enter ?
         jne       Lin0Men3                 ; nen° Ctrl-Enter
         or        byte ptr ds:[LinParm],bit0 ; p©°znak Ctrl-Enter
Lin0Men3:mov       bx,ds:[si+MnuAkt]        ; aktivn° zvolen† poloëka

; ------ test, zda je zad†na posledn° poloëka volby

         cmp       bx,ds:[si+MnuNum]        ; je zvolena posledn° poloëka ?
         jne       Lin0Men4                 ; nen° posledn° poloëka menu

; ------ uzav©en° okna p©i p©eru®en°

         push      si
         call      far ptr ClosMnu          ; uzav©en° okna menu
         pop       si
         jmp       short Lin0Men2

; ------ platn† poloëka menu - uloëen° historie menu

Lin0Men4:cmp       byte ptr ds:[si+LMnuHis],0 ; je platn† historie ?
         je        Lin0Men6                 ; nen° platn† historie
         cmp       word ptr ds:[si+LMnuDis],0 ; jsou zobrazeny nàjakÇ ©†dky ?
         je        Lin0Men6                 ; nejsou editovanÇ ©†dky
         cmp       bx,2                     ; je zah†jen° operace ?
         ja        Lin0Men6                 ; nen° zah†jen° operace
         test      byte ptr ds:[LinParm],bit0 ; je Ctrl-Enter ?
         jnz       Lin0Men6                 ; je Ctrl-Enter
         call      far ptr HistLMnu         ; uloëen° historie menu

; ------ uzav©en° okna menu

Lin0Men6:push      si
         call      far ptr ClosMnu          ; uzav©en° okna menu
         pop       si
Lin0Men8:clc                                ; p©°znak operace OK
Lin0Men9:ret

Lin0Menu ENDP

; *****************************************************************************
;                                 LineMenu
;                          obsluha ©†dkovÇho menu
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa definice menu
;        DS=datovò segment
; p©eru®en° volby: DS:SI=adresa p©edch†zej°c°ho menu
;                  BX=adresa definice tohoto menu
; proveden° volby, je adresa navazuj°c°ho menu: DS:SI=adresa novÇho menu
;                                               BX=kl†vesa, kter† provedla volbu
;                                               DX=stav p©ep°naáñ menu
;                                               n†vratov† adresa do novÇho menu
; proveden° volby, nen° adresa dal®°ho menu: DS:SI=adresa tohoto menu
;                                            BX=kl†vesa, kter† provedla volbu
;                                            DX=stav p©ep°naáñ menu
; *****************************************************************************

LineMenu PROC      FAR

; ------ £schova n†vratovÇ adresy z menu

         pop       word ptr ds:[si+MnuBreak] ; £schova n†vratovÇ adresy z menu
         pop       word ptr ds:[si+MnuBreak+2]

; ------ otev©en° line†rn°ho menu

         call      far ptr OpenMnu          ; otev©en° menu

; ------ vstup znaku z kl†vesnice

LineMnu1:call      far ptr NulBreak         ; nulov†n° p©°znaku p©eru®en°
         call      far ptr SizeLKur         ; nastaven° n°zkÇho kurzoru
         call      far ptr InpChar          ; vstup znaku s dynamickou obsluhou
         jc        LineMn16                 ; je p©eru®en° volby ESC

; ------ p©eru®en° menu stiskem pravÇho tlaá°tka nebo stiskem mimo ©†dek

         cmp       bh,MousXKod/HI           ; je k¢d my®i ?
         jne       LineMnu2                 ; nen° k¢d my®i
         cmp       bl,MousXRP               ; stisk pravÇho tlaá°tka ?
         je        LineMn16                 ; p©eru®en° pravòm tlaá°tkem my®i
         test      bl,bit2+bit3             ; stisk nàkterÇho tlaá°tka ?
         jz        LineMnu2                 ; nen° stisk tlaá°tka
         call      far ptr MouseMnu         ; test, zda je okno menu
         jnc       LineMnu2                 ; nen° p©eru®en°

; ------ p©eru®en° volby ESC

LineMn16:mov       bx,si                    ; £schova adresy definice menu
         call      far ptr ClosMnu          ; uzav©en° hlavn°ho menu
         jmp       dword ptr ds:[bx+MnuBreak] ; n†vrat z obsluhy p©i p©eru®en°

; ------ áek†n° na proveden° volby

LineMnu2:call      far ptr NulBreak         ; nulov†n° p©°znaku p©eru®en°
         push      cs
         call      near ptr EditLMnu        ; editace ©†dkovÇho menu
         jc        LineMnu1                 ; áek†n° na potvrzen° volby

; ------ adresa obsluhy volby

         push      bx
         mov       bx,ds:[si+MnuAkt]        ; aktivn° poloëka volby
         shl       bx,1                     ; á°slo volby
         shl       bx,1                     ; á°slo volby * 4
         add       bx,ds:[si+MnuExec]       ; adresa obsluhy
         mov       dx,ds:[bx-4]             ; adresa obsluhy - offset
         mov       word ptr cs:[LineMen0],dx ; offset adresy obsluhy
         mov       dx,ds:[bx-2]             ; adresa obsluhy - segment
         mov       word ptr cs:[LineMen0+2],dx ; segment adresy obsluhy
         or        dx,dx                    ; je obsluha ?
         pop       bx
         jz        LineMnu1                 ; nen° obsluha

; ------ poskytnut° stavu p©ep°naáñ menu

         call      far ptr GetSwch          ; poskytnut° stavu p©ep°naáñ

; ------ rozli®en°, zda je navazuj°c° menu

         push      bx
         mov       bx,ds:[si+MnuAkt]        ; aktivn° poloëka volby
         shl       bx,1                     ; á°slo volby * 2
         add       bx,ds:[si+MnuMnu]        ; adresa tabulky podmenu
         cmp       word ptr ds:[bx-2],0     ; je navazuj°c° podmenu ?
         je        LineMnu8                 ; nen° navazuj°c° podmenu

; ------ adresa definice podmenu, £schova n†vratovÇ adresy

         mov       si,ds:[bx-2]             ; adresa definice podmenu
         mov       word ptr ds:[si+MnuBreak],offset LineMnu1 ; n†vratov† adresa - offset
         mov       word ptr ds:[si+MnuBreak+2],cs    ; n†vratov† adresa - segment

; ------ skok na obsluhu volby

LineMnu8:pop       bx                       ; kl†vesa
         call      dword ptr cs:[LineMen0]  ; obsluha volby
         jmp       LineMnu1                 ; pokraáov†n° volby

LineMenu ENDP

LineMen0 dd        0                        ; adresa obsluhy provedenÇ volby

; *****************************************************************************
;                                InitLMnu
;                      inicializace ©†dkovÇho menu
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=definice menu
;        DS=datovò segment
; *****************************************************************************

InitLMnu PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      di
         push      es

; ------ adresa historie menu

         cmp       word ptr ds:[si+LMnuDis],0 ; jsou zobrazeny nàjakÇ ©†dky ?
         je        InitLMn4                 ; nejsou editovanÇ ©†dky
         mov       byte ptr ds:[si+MnuAkt],1 ; aktivn° poloëka (=editovanò text)

; ------ p©°prava bufferu

         mov       byte ptr ds:[LinKur],0   ; kurzor v ©†dku menu
         mov       byte ptr ds:[LinTop],-1  ; poá†tek ©†dku (-1=nen° editace)
         mov       byte ptr ds:[LinNum],0   ; poáet znakñ v ©†dku menu
         mov       al,ds:[si+LMnuHis]       ; identifik†tor historie
         call      far ptr GetHist          ; poskytnut° adresy historie
;         jc        InitLMn4                 ; neplatn† historie (asi nem†)
         mov       bx,1
         mov       ax,0
         jc        IniLMn12                 ; neplatn† historie

; ------ poáet ostatn°ch ©†dkñ bez editovanòch ©†dkñ

         mov       ah,0
         mov       al,ds:[si+MnuVys]        ; vò®ka okna menu
         sub       ax,ds:[si+LMnuDis]       ; odeáten° zobrazenòch ©†dkñ

; ------ vòpoáet maxim†ln°ho poátu editovanòch ©†dkñ k zobrazen°

         mov       bl,ds:[Radku]            ; poáet ©†dkñ na displeji
         mov       bh,bl
         shr       bh,1
         shr       bh,1
         sub       bl,bh                    ; 3/4 vò®ky obrazovky
         shr       bh,1
         sub       bl,bh                    ; 5/8 vò®ky obrazovky
         mov       bh,0
         sub       bx,ax                    ; zbytek na ©†dky k zobrazen° maxim.
         ja        InitLMn1
         mov       bx,1

; ------ stanoven° celkovÇho poátu editovanòch ©†dkñ

InitLMn1:mov       ax,es:[di+HistSNum]      ; poáet ©†dkñ historie
IniLMn12:add       al,ds:[si+LMnuPreN]      ; + poáet p©edvoleb
         adc       ah,0                     ; p©enos
         or        ax,ax                    ; je nàjakò ©†dek ?
         jnz       InitLMn2                 ; je nàjakò ©†dek
         inc       ax                       ; bude alespo§ 1 ©†dek menu
InitLMn2:mov       ds:[si+LMnuNum],ax       ; celkovò poáet ©†dkñ
         mov       ds:[si+LMnuAkt],ax       ; z†rove§ tÇë aktivn°m ©†dkem + 1
         dec       word ptr ds:[si+LMnuAkt] ; korekce (á°slov†n° je od 0)

; ------ nastaven° novÇho poátu ©†dkñ k zobrazen° a novÇ vò®ky okna

         cmp       ax,bx                    ; p©ekroáen maxim†ln° poáet ©†dkñ ?
         jbe       InitLMn3                 ; poáet ©†dkñ je OK
         mov       ax,bx                    ; omezen° poátu ©†dkñ k zobrazen°
InitLMn3:mov       bx,ax                    ; £schova - poáet ©†dkñ k zobrazen°
         xchg      ax,ds:[si+LMnuDis]       ; novò poáet ©†dkñ k zobrazen°
         sub       bx,ax                    ; zmàna poátu ©†dkñ
         add       ds:[si+MnuVys],bl        ; oprava vò®ky okna

; ------ prvn° zobrazenò ©†dek okna

         mov       ax,ds:[si+LMnuNum]       ; celkovò poáet editovanòch ©†dkñ
         sub       ax,ds:[si+LMnuDis]       ; odeáten° zobrazenòch ©†dkñ
         mov       ds:[si+LMnuTop],ax       ; prvn° zobrazenò ©†dek v oknà

; ------ vyst©edàn° okna vertik†lnà

InitLMn4:call      far ptr CentMenu         ; vyst©edàn° okna menu

; ------ n†vrat registrñ

         pop       es
         pop       di
         pop       bx
         pop       ax
         ret

InitLMnu ENDP

; *****************************************************************************
;                                   RedLMnu
;  redukce bufferu ©†dkovÇho menu (odstranàn° mezer, p©evod na velk† p°smena)
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

RedLMnu  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      si
         push      di
         push      es

; ------ p©°prava registrñ k redukci

         push      ds
         pop       es                       ; ES <- datovò segment
         mov       ch,0
         mov       cl,ds:[LinNum]           ; poáet znakñ v bufferu
         mov       si,offset LinBuff        ; ©†dkovò buffer
         mov       di,si                    ; zaá†tek ukl†dac° adresy

; ------ vypu®tàn° poá†teán°ch mezer

         call      RedLSpc                  ; vypu®tàn° mezer z textu
         jc        RedLMnu9                 ; nen° nic zad†no

; ------ p©enos platnÇho znaku jmÇna souboru

RedLMnu2:call      RedLChr                  ; áten° dal®°ho znaku
         jc        RedLMnu9                 ; konec textu

; ------ mezera - vypu®tàn° nadbyteánòch mezer

         cmp       al," "                   ; je mezera ?
         jne       RedLMnu5                 ; nen° mezera - dal®° znak
         call      RedLSpc                  ; vypu®tàn° mezer z textu
         jc        RedLMnu9                 ; konec textu
         mov       al," "                   ; jedna oddàlovac° mezera

; ------ uloëen° znaku

RedLMnu5:cld
         stosb                              ; uloëen° platnÇho znaku
         jmp       short RedLMnu2           ; dal®° znak

; ------ nastaven° novÇ dÇlky textu

RedLMnu9:sub       di,offset LinBuff        ; poáet znakñ v bufferu
         mov       cx,di
         mov       ds:[LinNum],cl           ; novò poáet znakñ v bufferu

; ------ n†vrat registrñ

         pop       es
         pop       di
         pop       si
         pop       cx
         pop       ax
         ret

RedLMnu  ENDP

; -----------------------------------------------------------------------------
;                                   RedLSpc
;                        vypu®tàn° mezer p©i redukci
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=ukazatel textu
;        CX=poáet zbylòch znakñ
; VùSTUP:AL=p©ipravenò znak
;        CY=konec textu
; -----------------------------------------------------------------------------

RedLSpc  PROC      NEAR

RedLSpc1:call      RedLChr                  ; naáten° dal®°ho znaku
         jc        RedLSpc9                 ; nen° dal®° znak
         cmp       al," "                   ; je to mezera ?
         je        RedLSpc1                 ; vypu®tàn° mezer z textu
         dec       si                       ; n†vrat ukazatele
         inc       cx                       ; n†vrat á°taáe znakñ
         clc                                ; p©°znak operace OK
RedLSpc9:ret

RedLSpc  ENDP

; -----------------------------------------------------------------------------
;                                 RedLChr
;                        áten° znaku p©i redukci
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=ukazatel textu
;        CX=poáet zbylòch znakñ
; VùSTUP:AL=znak textu
;        CY=konec textu
; -----------------------------------------------------------------------------

RedLChr  PROC      NEAR

; ------ naáten° znaku z bufferu

         stc                                ; p©°znak, ëe nen° dal®° znak
         jcxz      RedLChr9                 ; konec textu
         cld
         lodsb                              ; naáten° znaku
         dec       cx                       ; sn°ëen° á°taáe znakñ

; ------ konverze znaku na velkÇ p°smeno

         cmp       al,"a"
         jb        RedLChr8
         cmp       al,"z"
         ja        RedLChr8
         sub       al,32                    ; p©evod na velkÇ p°smeno

RedLChr8:clc                                ; p©°znak platnÇho znaku
RedLChr9:ret

RedLChr  ENDP

; *****************************************************************************
;                                 HistLMnu
;                  uloëen° volby ©†dkovÇho menu do historie
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa definice menu
;        DS=datovò segment
; VùSTUP:CY=nedostatek pamàti
; *****************************************************************************

HistLMnu PROC      FAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      si
         push      es

; ------ uloëen° historie

         mov       al,ds:[si+LMnuHis]       ; á°slo historie
         push      ds
         pop       es                       ; ES <- datovò segment
         mov       si,offset LinBuff        ; ©†dkovò buffer
         mov       ch,0
         mov       cl,ds:[LinNum]           ; poáet znakñ v ©†dku
         call      far ptr InsHist          ; uloëen° historie

; ------ n†vrat registrñ

         pop       es
         pop       si
         pop       cx
         pop       ax
         ret

HistLMnu ENDP

; *****************************************************************************
;                                EditLMnu
;                         editace ©†dkovÇho menu
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa definice menu
;        BX=kl†vesa
; VùSTUP:BX=0 kl†vesa byla obslouëena
;        NC=provedena volba poloëky (BX=kl†vesa, kter† provedla volbu)
;        CY=pokraáuje editace
; *****************************************************************************
;˛
EditLMnu PROC      FAR

; ------ p©echodnÇ vypnut° menu

         call      far ptr MCtrlO           ; p©echodnÇ vypnut° menu
         jnc       EditLMA0                 ; nebyla funkce Ctrl-O
         ret

; ------ £schova registrñ

EditLMA0:push      ax
         push      cx
         push      dx
         push      di
         push      es

; ------ p©°prava registrñ

         push      ds
         pop       es                       ; ES <- datovò segment

; ------ rozli®en°, zda jsou aktivn° volby nebo editace ©†dku

         cmp       word ptr ds:[si+LMnuDis],0 ; je nàjakò ©†dek ?
         je        EditLM0x                 ; nen° ë†dnò ©†dek
         mov       ax,ds:[si+LMnuMax]       ; maxim†ln° dÇlka ©†dku
         mov       ds:[LinMax],al           ; maxim†ln° dÇlka ©†dku
         cmp       word ptr ds:[si+MnuAkt],1 ; jsou aktivn° ©†dky ?
         je        EditLM00                 ; nejsou aktivn° volby
EditLM0x:jmp       EditLMn0                 ; obsluha voleb

; ------ jsou aktivn° editovanÇ ©†dky; editace aktivn°ho ©†dku

EditLM00:mov       dl,ds:[si+MnuPoz]        ; pozice okna menu
         inc       dl                       ; poá†teán° pozice kurzoru
         mov       dh,ds:[LinRad]           ; poloha ©†dku na displeji
         mov       cl,ds:[si+MnuSir]        ; ®°©ka okna
         dec       cx
         dec       cx                       ; dÇlka editovanÇho ©†dku
         call      far ptr EditLine         ; obsluha editace ©†dku menu
         or        bx,bx                    ; byla kl†vesa obslouëena ?
         jnz       EditLM06                 ; nebyla obsluha kl†vesy
EditLM09:jmp       EditLM88                 ; konec obsluhy

; ------ nalezen° horkÇ kl†vesy s Alt-

EditLM06:mov       ax,ds:[si+MnuAkt]        ; aktivn° poloëka
         call      far ptr SrcHotA          ; nalezen° horkÇ kl†vesy s Alt-
         jc        EditL06A                 ; poloëka nenalezena
         jmp       EditLMn7                 ; nastaven° poloëky

; ------ obsluha ©°dic° kl†vesy - jsou aktivn° ©†dky

EditL06A:mov       ax,ds:[si+LMnuAkt]       ; aktivn° ©†dek
         mov       ch,ds:[LinTop]           ; p©°znak zah†jen° editace ©†dku
         call      far ptr JumpBX

         dw        5000h,EditL001           ; dolñ
         dw        2d18h,EditL001           ; Ctrl-X dolñ

         dw        4800h,EditL004           ; nahoru
         dw        1205h,EditL004           ; Ctrl-E nahoru

         dw        8400h,EditL005           ; ^PageUp
         dw        7600h,EditL006           ; ^PageDown
         dw        4900h,EditL011           ; PageUp
         dw        5100h,EditL021           ; PageDown
         dw        7700h,EditL031           ; ^Home
         dw        7500h,EditL041           ; ^End
         dw        8d00h,EditL051           ; ^nahoru (6 ©†dkñ)
         dw        9100h,EditL061           ; ^dolñ (6 ©†dkñ)

         dw        3d00h,EditLRO            ; F3 z†kaz ru®en° poloëky

         dw        0f09h,EditLM07           ; TAB
         dw        0f00h,EditLM08           ; *TAB
         dw        1c0dh,EditLMn2           ; ENTER
         dw        1c0ah,EditLMn2           ; Ctrl-Enter

         dw        MousXKod+MousXLR,EditLMM1 ; uvolnàn° levÇho tlaá°tka my®i
         dw        MousXKod+MousXLP,EditLMM3 ; stisk levÇho tlaá°tka my®i
         dw        MousXKod+MousXLH,EditLMM3 ; drëen° levÇho tlaá°tka (rolov†n°)
         dw        MousXKod+MousXMov,EditLMM3 ; posun my®i
         dw        MousXKod+MousXLD,EditLM21 ; dvoj° stisk levÇho tlaá°tka

         dw        0,EditLM09

; ------ TAB

EditLM07:cmp       word ptr ds:[si+MnuNum],1 ; jsou nàjakÇ volby ?
         je        EditL009                 ; nejsou volby
         mov       ax,2                     ; bude poloëka 2
         jmp       short EditLM0A

; ------ SHIFT-TAB

EditLM08:mov       ax,ds:[si+MnuNum]        ; á°slo posledn° poloëky
EditLM0A:jmp       EditLMn7

; ------ kurzor 6 ©†dkñ nahoru

EditL051:call      StopLMnu                 ; p©eru®en° editace ©†dku
         sub       ax,6                     ; sn°ëen° kurzoru
         jnc       EditL003                 ; kurzor je OK
         jmp       short EditL052           ; omezen° kurzoru na zaá†tek menu

; ------ kurzor o 6 ©†dkñ dolñ

EditL061:call      StopLMnu                 ; p©eru®en° editace ©†dku
         add       ax,6                     ; zvò®en° kurzoru
         cmp       ax,ds:[si+LMnuNum]       ; p©eteáen° konce ?
         jb        EditL003                 ; nen° p©eteáen°
         jmp       short EditL062           ; omezen° kurzoru na konec menu

; ------ kurzor dolñ

EditL001:call      StopLMnu                 ; p©eru®en° editace ©†dku
         inc       ax                       ; zvò®en° á°sla poloëky
         cmp       ax,ds:[si+LMnuNum]       ; je jië konec ?
         jb        EditL003                 ; á°slo ©†dku je OK
EditL002:dec       ax                       ; n†vrat á°sla aktivn°ho ©†dku

; ------ novÇ zobrazen° menu

EditL003:mov       ds:[si+LMnuAkt],ax       ; novò aktivn° ©†dek
         call      far ptr DispMnu          ; novÇ zobrazen° menu
EditL009:jmp       EditLMn8

; ------ kurzor nahoru

EditL004:call      StopLMnu                 ; p©eru®en° editace ©†dku
         or        ax,ax                    ; je jië prvn° ©†dek ?
         jz        EditL003                 ; je jië prvn° ©†dek
         jmp       short EditL002           ; novò aktivn° ©†dek

; ------ zaá†tek ^PageUp

EditL005:call      StopLMnu                 ; p©eru®en° editace ©†dku
EditL052:xor       ax,ax                    ; novò aktivn° ©†dek = 0
         jmp       short EditL003

; ------ konec ^PageDown

EditL006:call      StopLMnu                 ; p©eru®en° editace ©†dku
EditL062:mov       ax,ds:[si+LMnuNum]       ; poáet ©†dkñ celkem
         or        ax,ax                    ; jsou nàjakÇ ©†dky ?
         jz        EditL003                 ; nejsou ë†dnÇ ©†dky
         dec       ax                       ; novò aktivn° ©†dek
         jmp       short EditL003

; ------ str†nka nahoru Page Up

EditL011:call      StopLMnu                 ; p©eru®en° editace ©†dku
         mov       bx,ds:[si+LMnuTop]       ; prvn° zobrazenò ©†dek
         or        bx,bx                    ; zobrazen zaá†tek ?
         jz        EditL005                 ; je zaá†tek - jako ^PageUp
         cmp       bx,ds:[si+LMnuDis]       ; je posun vàt®° neë str†nka ?
         jb        EditL012                 ; posun je OK
         mov       bx,ds:[si+LMnuDis]       ; omezen° na dÇlku str†nky
         dec       bx                       ; dÇlka str†nky - 1
         jnz       EditL012                 ; dÇlka str†nky je OK
         inc       bx                       ; minim†ln° dÇlka str†nky
EditL012:sub       ax,bx                    ; posun kurzoru o str†nku
         sub       ds:[si+LMnuTop],bx       ; posun poá†tku o str†nku
EditL013:jmp       short EditL003

; ------ str†nka dolñ Page Down

EditL021:call      StopLMnu                 ; p©eru®en° editace ©†dku
         mov       bx,ds:[si+LMnuNum]       ; poáet poloëek celkem
         sub       bx,ds:[si+LMnuDis]       ; maxim†ln° poá†tek okna
         jnc       EditL022                 ; poá†tek okna je OK
         xor       bx,bx                    ; oprava maxim†ln°ho poá†tku
EditL022:sub       bx,ds:[si+LMnuTop]       ; offset od souáasnÇho poá†tku
         jbe       EditL006                 ; je konec - jako ^PageDown
         cmp       bx,ds:[si+LMnuDis]       ; je del®° neë str†nka ?
         jb        EditL023                 ; dÇlka je OK
         mov       bx,ds:[si+LMnuDis]       ; dÇlka str†nky
         dec       bx                       ; opraven† dÇlka str†nky
         jnz       EditL023                 ; dÇlka str†nky je OK
         inc       bx                       ; minim†ln° dÇlka str†nky 1 ©†dek
EditL023:add       ax,bx                    ; posun kurzoru o str†nku
         add       ds:[si+LMnuTop],bx       ; posun poá†tku
         jmp       short EditL013

; ------ posun na horn° okraj str†nky

EditL031:call      StopLMnu                 ; p©eru®en° editace ©†dku
         mov       ax,ds:[si+LMnuTop]       ; horn° okraj str†nky
         jmp       short EditL013

; ------ posun na spodn° okraj str†nky

EditL041:call      StopLMnu                 ; p©eru®en° editace ©†dku
         mov       ax,ds:[si+LMnuTop]       ; horn° okraj str†nky
         add       ax,ds:[si+LMnuDis]       ; n†sleduj°c° ©†dek
         dec       ax                       ; spodn° okraj str†nky
         jmp       short EditL013


; ====== jsou aktivn° volby
; ------ nalezen° horkÇ kl†vesy

EditLMn0:call      far ptr SrcHotM          ; nalezen° horkÇ kl†vesy
         jc        EditLM11                 ; kl†vesa nenalezena

; ------ proveden° volby (zvolena poloëka AX)

EditLMn1:call      far ptr EditMEnt         ; proveden° volby menu
         jc        EditLM10
         call      far ptr TestMSwc         ; test, zda to je p©ep°naá
         jnc       EditLM10                 ; je to p©ep°naá - nen° editace
         call      StrtLMnu                 ; p©°padnÇ zah†jen° editace
         clc                                ; p©°znak potvrzen° volby
EditLM10:jmp       EditLMn9                 ; kl†vesa byla obslouëena OK

; ------ ovl†d†n° p©ep°naáe - mezera

EditLM11:mov       ax,ds:[si+MnuAkt]        ; aktivn° poloëka
         cmp       bl," "
         jne       EditLM13
         call      far ptr TestMSwc         ; test, zda je to p©ep°naá
         jnc       EditLMn1                 ; proveden° volby p©ep°naáe
EditLM12:jmp       EditLMn7                 ; jinak se nic nedàje

; ------ obsluha kl†vesy "+" - zapnut° p©ep°naáe

EditLM13:cmp       bl,"+"                   ; je kl†vesa "+" ?
         jne       EditLM14                 ; nen° kl†vesa "+"
         mov       bx,3920h                 ; n†hrada mezerou
         push      cs
         call      near ptr TestMSwc        ; test stavu p©ep°naáe
         jc        EditLM12                 ; nen° to p©ep°naá
         je        EditLMn1                 ; p©ep°naá je vypnutò - OK
         jmp       short EditLM12

; ------ obsluha kl†vesy "-"- vypnut° p©ep°naáe

EditLM14:cmp       bl,"-"                   ; je kl†vesa "-" ?
         jne       EditLMn2                 ; nen° kl†vesa "-"
         mov       bx,3920h                 ; n†hrada mezerou
         push      cs
         call      near ptr TestMSwc        ; test stavu p©ep°naáe
         jc        EditLM12                 ; nen° to p©ep°naá
         jne       EditLMn1                 ; p©ep°naá je zapnutò - OK
         jmp       short EditLM12

; ------ nalezen° horkÇ kl†vesy s Alt-

EditLM21:mov       bx,1c0dh                 ; kl†vesa Enter
EditLMn2:mov       ax,ds:[si+MnuAkt]        ; aktivn° poloëka
         call      far ptr SrcHotA          ; nalezen° horkÇ kl†vesy s Alt-
         jnc       EditLMn7                 ; poloëka nalezena OK

; ------ obsluha ©°dic° kl†vesy - ©†dky nejsou aktivn°

         call      far ptr JumpBX

         dw        MousXKod+MousXLR,EditLMM1 ; uvolnàn° levÇho tlaá°tka my®i
         dw        MousXKod+MousXLP,EditLMM3 ; stisk levÇho tlaá°tka my®i
         dw        MousXKod+MousXLH,EditLMM3 ; drëen° levÇho tlaá°tka (rolov†n°)
         dw        MousXKod+MousXMov,EditLMM3 ; posun my®i

         dw        1c0dh,EditLMn1           ; ENTER
         dw        1c0ah,EditLMn1           ; Ctrl-Enter
         dw        4b00h,EditLM22           ; LEFT
         dw        1f13h,EditLM22           ; Ctrl-S vlevo

         dw        0f00h,EditLMn3           ; *TAB
         dw        4f00h,EditLMn4           ; END
         dw        4d00h,EditLM23           ; RIGHT
         dw        2004h,EditLM23           ; Ctrl-D vpravo

         dw        0f09h,EditLMn5           ; TAB
         dw        4700h,EditLMn6           ; HOME

         dw        0,EditLM88

; ------ posun kurzoru vlevo LEFT

EditLM22:cmp       word ptr ds:[si+LMnuDis],0 ; jsou ©†dky ?
         je        EditLMn3                 ; nejsou ©†dky - jako *TAB
         dec       ax
         cmp       ax,1
         ja        EditLMn7                 ; poloëka OK, jinak p©eskoáen° ©†dkñ

; ------ zpàtnò tabul†tor *TAB

EditLMn3:dec       ax
         jnz       EditLMn7

; ------ posledn° poloëka END

EditLMn4:mov       ax,ds:[si+MnuNum]
         jmp       short EditLMn7

; ------ posun kurzoru vpravo RIGHT

EditLM23:cmp       word ptr ds:[si+LMnuDis],0 ; jsou ©†dky ?
         je        EditLMn5                 ; nejsou ©†dky - jako TAB
         inc       ax
         cmp       ax,ds:[si+MnuNum]        ; je p©eteáen° ?
         jbe       EditLMn7                 ; OK

; ------ posun na prvn° poloëku HOME

EditLMn6:mov       ax,1                     ; prvn° poloëka
         cmp       word ptr ds:[si+LMnuDis],0 ; jsou ©†dku ?
         je        EditLMn7                 ; nejsou ©†dky

; ------ tabul†tor TAB

EditLMn5:inc       ax
         cmp       ax,ds:[si+MnuNum]        ; p©eteáen° ?
         jbe       EditLMn7                 ; OK
         mov       ax,1                     ; zaá†tek

; ------ nastaven° novÇ aktivn° poloëky menu

EditLMn7:mov       ds:[si+MnuAkt],ax        ; nov† aktivn° poloëka menu
EditLM85:call      far ptr DispMnu          ; novÇ zobrazen° menu
EditLMn8:xor       bx,bx                    ; p©°znak obsluhy kl†vesy
EditLM88:stc                                ; p©°znak pokraáuj°c° volby

; ------ n†vrat registrñ

EditLMn9:pop       es
         pop       di
         pop       dx
         pop       cx
         pop       ax
         ret

EditLMnu ENDP
;˛
; ------ uvolnàn° levÇho tlaá°tka my®i

EditLMM1:call      far ptr MouseMnu         ; test, zda je v oknà
         jc        EditLMM4                 ; nen° v oknà
         cmp       word ptr ds:[si+LMnuDis],0
         je        EditLMM2                 ; nejsou editovanÇ ©†dky
         mov       al,ds:[si+MnuRad]        ; ©†dek menu
         add       al,ds:[si+MnuVys]        ; ©†dek pod menu
         sub       al,1+3+1                 ; rezerva pro volby
         cmp       al,byte ptr ds:[MousePoz+1] ; je my® na spodn°ch volb†ch ?
         jae       EditLMM4                 ; my® je nad volbami
EditLMM2:mov       ax,ds:[si+MnuAkt]        ; aktivn° poloëka
         mov       bx,1c0dh                 ; kl†vesa ENTER
         jmp       EditLMn1                 ; proveden° volby

; ------ posun my®i nebo stisk levÇho tlaá°tka my®i

EditLMM3:call      far ptr MouseMnu         ; test, zda je v oknà
         jc        EditLMM4                 ; nen° v oknà
         call      LinMPol                  ; aktivn° poloëka menu z my®i
         jmp       short EditLM85

EditLMM4:jmp       short EditLM88           ; nic se nedàje

; -----------------------------------------------------------------------------
;        F3: z†kaz ru®en° poloëky (AX=aktivn° editovanò ©†dek)
; -----------------------------------------------------------------------------

; ------ adresa historie menu

EditLRO: xchg      ax,cx                    ; CX <- aktivn° editovanò ©†dek
         mov       al,ds:[si+LMnuHis]       ; identifik†tor historie
         call      far ptr GetHist          ; adresa historie
         jc        EditLRO6                 ; nen° historie

; ------ test, zda je editovanò ©†dek v historii

         cmp       cx,es:[di+HistSNum]      ; je ©†dek v historii ?
         jae       EditLRO6                 ; nen° ©†dek v historii

; ------ nalezen° ©†dku v historii

         add       di,HistSBeg              ; adresa prvn° poloëky
         jcxz      EditLRO4                 ; je prvn° poloëka historie
EditLRO2:mov       ax,es:[di+HistDelk]      ; dÇlka textu poloëky historie
         and       ax,HistDelM              ; maska dÇlky poloëky
         inc       di
         inc       di
         add       di,ax                    ; adresa dal®° poloëky historie
         loop      EditLRO2                 ; dal®° poloëka historie
EditLRO4:xor       byte ptr es:[di+HistDelk+1],bit15/HI ; zmàna z†kazu ru®en°
         call      far ptr SrtHist          ; set©°dàn° histori°
         or        byte ptr ds:[HistSPar],bit0 ; buffer modifikov†n

EditLRO6:jmp       EditLM85

; -----------------------------------------------------------------------------
;        aktivn° poloëka menu z my®i
; -----------------------------------------------------------------------------

LinMPol  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp

; ------ p©°prava registrñ

         mov       di,si                    ; DI <- definice menu
         mov       si,ds:[di+MnuPol]        ; adresa definice poloëek
         mov       cx,ds:[di+MnuSum]        ; celkovò poáet poloëek
         mov       bp,1                     ; ukazatel á°sla poloëky
         mov       dx,ds:[MousePoz]         ; pozice a ©†dek my®i
         sub       dl,ds:[di+MnuPoz]        ; pozice my®i relativnà
         jnc       LinMPl11
         mov       dl,0
LinMPl11:sub       dh,ds:[di+MnuRad]        ; ©†dek my®i relativnà
         jnc       LinMPl12
         mov       dh,0
LinMPl12:mov       ah,0
         cld

; ------ p©eskoáen° textu nadpisu

         dec       dh                       ; p©eskoáen° horn° linky
         jcxz      LinMPol2
LinMPl14:test      byte ptr ds:[si+MnuParm],bit6 ; je poloëka ?
         jz        LinMPol2                 ; je to poloëka
         dec       dh                       ; posun ukazatele ©†dku
         inc       si                       ; p©eskoáen° parametrñ
         lodsb                              ; dÇlka textu
         add       si,ax                    ; adresa dal®° poloëky
         loop      LinMPl14

; ------ test, zda jsou editovanÇ ©†dky

LinMPol2:cmp       word ptr ds:[di+LMnuDis],0 ; jsou editovanÇ ©†dky ?
         jne       LinMPl20                 ; jsou nàjakÇ ©†dky
         jmp       LinMPol5                 ; nejsou editovanÇ ©†dky

; ------ listov†n° po str†nk†ch zpàt

LinMPl20:or        dh,dh                    ; je horn° linka ?
         jns       LinMPl24                 ; nen° horn° linka
         mov       ds:[di+MnuAkt],bp        ; aktivn° poloëka - ©†dky
         cmp       word ptr ds:[di+LMnuAkt],0 ; je jië poá†tek okna ?
         je        LinMPl23
         mov       ax,1                     ; posun p©i rolov†n°
         cmp       byte ptr ds:[MouseKey],MousXLH ; je drëen° levÇho tlaá°tka ?
         je        LinMP212                 ; rolov†n° ©†dkñ

         test      byte ptr ds:[MouseKey],bit2 ; je stisk levÇho tlaá°tka ?
         jz        LinMPl23                 ; nen° levÇ tlaá°tko

         call      StopLMnu                 ; p©eru®en° editace ©†dku
         mov       ax,ds:[di+LMnuTop]       ; prvn° zobrazenò ©†dek
         or        ax,ax                    ; zobrazen zaá†tek ?
         jz        LinMPl22                 ; je zaá†tek - jako ^PageUp
         cmp       ax,ds:[di+LMnuDis]       ; je posun vàt®° neë str†nka ?
         jb        LinMPl21                 ; posun je OK
         mov       ax,ds:[di+LMnuDis]       ; omezen° na dÇlku str†nky
         dec       ax                       ; dÇlka str†nky - 1
LinMPl21:sub       ds:[di+LMnuTop],ax       ; posun poá†tku o str†nku
LinMP212:sub       ds:[di+LMnuAkt],ax       ; posun kurzoru
         jmp       short LinMPl23
LinMPl22:mov       ds:[di+LMnuAkt],ax       ; nov† aktivn° poloëka
LinMPl23:jmp       LinMPol9

; ------ listov†n° po str†nk†ch vp©ed

LinMPl24:cmp       dh,byte ptr ds:[di+LMnuDis]       ; je spodn° li®ta ?
         ja        LinMPol4                 ; nejsou editovanÇ ©†dky
         mov       ds:[di+MnuAkt],bp        ; aktivn° poloëka - ©†dky
         jb        LinMPol3                 ; jsou vnit©n° ©†dky

         mov       ax,ds:[di+LMnuNum]       ; poáet poloëek
         or        ax,ax                    ; je nàco ?
         jz        LinMPl23                 ; nen° ë†dnò ©†dek
         dec       ax
         cmp       ax,ds:[di+LMnuAkt]       ; je jië konec ?
         je        LinMPl23                 ; je jië konec
         mov       ax,-1                    ; posun p©i rolov†n°
         cmp       byte ptr ds:[MouseKey],MousXLH ; je drëen° levÇho tlaá°tka ?
         je        LinMP212                 ; rolov†n° ©†dkñ

         test      byte ptr ds:[MouseKey],bit2 ; je stisk levÇho tlaá°tka ?
         jz        LinMPl23                 ; nen° levÇ tlaá°tko

         call      StopLMnu                 ; p©eru®en° editace ©†dku
         mov       ax,ds:[di+LMnuNum]       ; poáet poloëek celkem
         sub       ax,ds:[di+LMnuDis]       ; maxim†ln° poá†tek okna
         jnc       LinMPl25                 ; poá†tek okna je OK
         xor       ax,ax                    ; oprava maxim†ln°ho poá†tku
LinMPl25:sub       ax,ds:[di+LMnuTop]       ; offset od souáasnÇho poá†tku
         jbe       LinMPl27                 ; je konec - jako ^PageDown
         cmp       ax,ds:[di+LMnuDis]       ; je del®° neë str†nka ?
         jb        LinMPl26                 ; dÇlka je OK
         mov       ax,ds:[di+LMnuDis]       ; dÇlka str†nky
         dec       ax                       ; opraven† dÇlka str†nky
LinMPl26:neg       ax
         jmp       short LinMPl21           ; posun ukazatelñ

LinMPl27:mov       ax,ds:[di+LMnuNum]       ; poáet poloëek
         dec       ax                       ; posledn° poloëka
         jmp       short LinMPl22           ; uloëen° á°sla poloëky

; ------ uvnit© ©†dkñ - nastaven° aktivn°ho ©†dku

LinMPol3:mov       al,dh                    ; AL <- relativn° á°slo ©†dku
         mov       ah,0
         add       ax,ds:[di+LMnuTop]
         cmp       ax,ds:[di+LMnuAkt]       ; zmànàn ©†dek ?
         je        LinMPl32                 ; ©†dek nezmànàn
         call      StopLMnu                 ; p©eru®en° editace ©†dku
         mov       ds:[di+LMnuAkt],ax       ; nov† aktivn° poloëka
LinMPl32:jmp       short LinMPl23

; ------ posun ukazatele

LinMPol4:dec       cx
         mov       ah,0
         inc       bp                       ; zvò®en° ukazatele aktivn° poloëky
         inc       si                       ; p©eskoáen° parametrñ
         lodsb                              ; dÇlka textu
         add       si,ax                    ; adresa dal®° poloëky

; ------ p©eskoáen° oddàlovac°ho textu

         jcxz      LinMPol5
LinMPl44:test      byte ptr ds:[si+MnuParm],bit6 ; je poloëka ?
         jz        LinMPol5                 ; je to poloëka
         dec       dh                       ; posun ukazatele ©†dku
         inc       si                       ; p©eskoáen° parametrñ
         lodsb                              ; dÇlka textu
         add       si,ax                    ; adresa dal®° poloëky
         loop      LinMPl44

; ------ souáet dÇlek jednotlivòch poloëek -> BH, poáet BL

LinMPol5:push      si
         push      cx

         xor       bx,bx                    ; BL=poáet poloëek, BH=dÇlka
         mov       ah,0
         jcxz      LinMPl56
LinMPl54:test      byte ptr ds:[si+MnuParm],bit6 ; je platn† poloëka ?
         jnz       LinMPl56                 ; nen° platn† poloëka
         inc       si                       ; p©eskoáen° parametrñ
         lodsb                              ; dÇlka textu
         add       bh,al                    ; st©adaá dÇlky
         add       bh,4                     ; okraje
         inc       bx                       ; poáet poloëek
         add       si,ax                    ; adresa dal®° poloëky
         loop      LinMPl54

LinMPl56:pop       cx
         pop       si

; ------ vòpoáet okrajñ poloëek (AH=0, BH=souáet, BL=poáet)

         mov       al,ds:[di+MnuSir]        ; ®°©ka okna
         sub       al,2                     ; bez okrajñ
         sub       al,bh                    ; zbytek na mezery
         inc       bx                       ; poáet poloëek + 1
         div       bl                       ; vòpoáet oddàlovac° mezery
         mov       bl,al                    ; oddàlovac° mezera
         shr       ah,1                     ; zbytek mezer / 2
         shr       al,1                     ; oddàlovac° mezera / 2
         mov       bh,al                    ; levò okraj
         adc       bh,ah                    ; levò okraj + zbytek / 2
         add       bl,4                     ; oddàlovac° mezera + 4 okraje

; ------ pozice my®i

         inc       bh                       ; + okraj
         sub       dl,bh                    ; odeáten° levÇho okraje
         jc        LinMPol8
         jcxz      LinMPol8

; ------ nalezen° pozice my®i

         mov       ah,0
         dec       bp
LinMPol6:inc       bp
         test      byte ptr ds:[si+MnuParm],bit6
         jnz       LinMPol8
         inc       si
         lodsb                              ; dÇlka poloëky
         add       si,ax                    ; adresa dal®° poloëky
         add       al,bl
         sub       dl,al
         jc        LinMPol8
         loop      LinMPol6

LinMPol8:mov       ds:[di+MnuAkt],bp        ; nov† aktivn° poloëka

; ------ n†vrat registrñ

LinMPol9:pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

LinMPol  ENDP

; *****************************************************************************
;                                EditLine
;                          editace ©†dku voleb
; -----------------------------------------------------------------------------
; VSTUP: BX=k¢d kl†vesy
;        CL=dÇlka ©†dku
;        DL=poá†teán° pozice k zobrazen° ©†dku
;        DH=©†dek k zobrazen° editovanÇho ©†dku
;        DS:SI=adresa definice menu
;        DS=datovò segment
; VùSTUP:BX=0 - kl†vesa byla obslouëena
; *****************************************************************************

EditLine PROC      FAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      di
         push      es

; ------ p©°prava registrñ

         push      ds
         pop       es                       ; ES <- datovò segment
         mov       ch,ds:[LinTop]           ; poá†tek ©†dku

; ------ rozli®en° platnÇho znaku

EditLin1:cmp       bh,MousXKod/HI           ; je my® ?
         je        EditLin2
         or        bx,bx                    ; je Ctrl-Break ?
         jz        EditLin2                 ; je Ctrl-Break
         cmp       bx,0300h                 ; je Ctrl-@ ?
         je        EditLin3                 ; je Ctrl-@
         or        bh,bh                    ; je platnò znak Alt-á°slo ?
         jz        EditLin3                 ; je platnò znak Alt-á°slo
         cmp       bl,32                    ; je platnò znak ?
         jb        EditLin2                 ; je ©°dic° kl†vesa
         cmp       bx,0e7fh                 ; ^BS
         jne       EditLin3                 ; je platnò ASCII znak
EditLin2:jmp       EditLin7                 ; je ©°dic° kl†vesa

; ------ kontrola, zda je znak povolen

EditLin3:mov       bh,0                     ; BX = ASCII hodnota znaku

         push      ds
         push      dx

         mov       al,ds:[si+LMnuMask]      ; maska
         mov       dx,SEG CodeDek
         mov       ds,dx

         ASSUME    ds:CodeDek
         mov       ah,ds:[TabTypCh+bx] ; parametry z tabulky
         ASSUME    ds:Data

         pop       dx
         pop       ds

         and       ah,not 3
         test      al,ah                    ; je znak povolen ?
         jz        EditLn88                 ; znak nen° povolen

         push      si
         mov       al,ds:[si+LMnuZakN]      ; poáet zak†zanòch znakñ
         or        al,al                    ; jsou nàjakÇ zak†zanÇ znaky ?
         jz        EditLn31                 ; nejsou zak†zanÇ znaky
EditLn30:cmp       bl,ds:[si+LMnuZak]       ; je to zak†zanò znak ?
         stc                                ; p©°znak chyby
         je        EditLn31                 ; je to zak†zanò znak
         inc       si                       ; zvò®en° ukazatele znakñ
         sub       al,1                     ; á°taá zak†zanòch znakñ
         jnz       EditLn30                 ; test dal®°ho znaku
EditLn31:pop       si
         jc        EditLn88                 ; je zak†zanò znak

; ------ je platnò ASCII znak - nulov†n° bufferu p©i zah†jen° editace

EditLn32:cmp       byte ptr ds:[LinTop],-1  ; je jië editace ?
         jne       EditLin4                 ; je jië editace
         mov       byte ptr ds:[LinKur],0   ; pozice kurzoru na zaá†tek
         mov       byte ptr ds:[LinNum],0   ; v bufferu nejsou ë†dnÇ znaky
         mov       byte ptr ds:[LinTop],0   ; poá†tek ©†dku

; ------ kontrola, zda je volnÇ m°sto v bufferu

EditLin4:mov       al,ds:[LinNum]           ; poáet znakñ v p©°kazovÇm ©†dku
         cmp       al,ds:[LinMax]           ; je ©†dek plnò ?
         jb        EditLn42                 ; ©†dek je®tà nen° plnò
         mov       ah,ds:[LinKur]           ; kurzor
         call      DelLChar                 ; zru®en° znaku za kurzorem
EditLn42:mov       al,ds:[LinKur]           ; kurzor
         cmp       al,ds:[LinMax]           ; je kurzor na konci ?
         jb        EditLin5
EditLn88:jmp       EditLn89                 ; kurzor je jië na konci

; ------ doplnàn° mezer, pokud je kurzor za koncem textu

EditLin5:cmp       al,ds:[LinNum]           ; je kurzor za textem ?
         jbe       EditLin6                 ; kurzor nen° za textem
         push      cx
         mov       cl,ds:[LinNum]           ; souáasnò poáet znakñ
         mov       ds:[LinNum],al           ; novò poáet znakñ v bufferu
         sub       al,cl                    ; chybàj°c° poáet znakñ
         mov       ch,0                     ; CX=souáasnò poáet znakñ
         mov       di,offset LinBuff        ; buffer
         add       di,cx                    ; konec textu
         cld
         mov       cl,al                    ; chybàj°c° poáet znakñ
         mov       al," "                   ; znak mezery
         rep       stosb                    ; uloëen° znaku mezery
         pop       cx

; ------ odsun textu za kurzorem a vloëen° znaku do bufferu

EditLin6:push      cx
         push      si
         mov       cx,255                   ; max. dÇlka ©†dku - 1
         sub       cl,ds:[LinKur]           ; zbylò poáet znakñ v ©†dku
         mov       di,offset LinBuff+255    ; konec ©†dku
         mov       si,offset LinBuff+254    ; p©edposledn° znak ©†dku
         std                                ; smàr dolñ
         rep       movsb                    ; odsunut° zbytku textu
         mov       al,bl                    ; vkl†danò znak
         stosb                              ; vloëen° znaku do bufferu
         pop       si
         pop       cx

; ------ posun ukazatelñ ©†dku

         inc       byte ptr ds:[LinNum]     ; zvò®en° poátu znakñ v bufferu
         inc       byte ptr ds:[LinKur]     ; zvò®en° pozice kurzoru
         jmp       short EditLn84           ; novÇ zobrazen° ©†dku

; ------ obsluha ©°dic° kl†vesy

EditLin7:xor       ax,ax
         mov       al,ds:[LinKur]           ; kurzor
         mov       di,offset LinBuff        ; buffer
         add       di,ax                    ; adresa platnÇho znaku
         mov       ah,al                    ; aktu†ln° kurzor

         call      far ptr JumpBX           ; obsluha kl†vesy BX

         dw        4b00h,LinLft             ; vlevo - posun kurzoru vlevo
         dw        4d00h,LinRgh             ; vpravo - posun kurzoru vpravo
         dw        4700h,LinHome            ; HOME - kurzor na zaá†tek ©†dku
         dw        4f00h,LinEnd             ; END - kurzor na konec ©†dku
         dw        7300h,LinCLf             ; ^vlevo - slovo vlevo
         dw        7400h,LinCRg             ; ^vpravo - slovo vpravo

         dw        0c1fh,LinCPom            ; ^- - z†màna 2 znakñ
         dw        0e08h,LinBs              ; BS - maz†n° znaku p©ed kurzorem
         dw        5300h,LinDel             ; DEL - maz†n° znaku za kurzorem
         dw        0e7fh,LinCBS             ; ^BS - vymaz†n° slova p©ed kurzorem
         dw        9300h,LinCDel            ; ^DEL - vymaz†n° slova za kurzorem
         dw        1519h,LinClr             ; ^Y - zru®en° ©†dku

         dw        0,EditLin9               ; neobsluhovan† kl†vesa

; ------ novÇ zobrazen° ©†dku

EditLin8:mov       ds:[LinKur],ah           ; nov† pozice kurzoru
EditLn84:mov       al,ds:[si+MnuLev]        ; vòstupn° hladina k zobrazen°
         mov       ah,0
         call      far ptr DispLine         ; novÇ zobrazen° ©†dku
         call      far ptr DispRamM         ; zobrazen° r†mu s á°slem znaku
EditLn89:xor       bx,bx                    ; p©°znak obsluhy kl†vesy

; ------ n†vrat registrñ

EditLin9:pop       es
         pop       di
         pop       cx
         pop       ax
         ret

EditLine ENDP

; -----------------------------------------------------------------------------
;        posun kurzoru o znak vlevo
; -----------------------------------------------------------------------------

LinLft   PROC      NEAR

         call      StrtLMnu                 ; zah†jen° editace ©†dku
         or        ah,ah                    ; je jië zaá†tek ©†dku ?
         jz        LinLft2                  ; je jië zaá†tek ©†dku
         dec       ah                       ; sn°ëen° pozice kurzoru
LinLft2: jmp       short EditLin8

LinLft   ENDP

; -----------------------------------------------------------------------------
;        posun kurzoru o znak vpravo
; -----------------------------------------------------------------------------

LinRgh   PROC      NEAR

         call      StrtLMnu                 ; zah†jen° editace ©†dku
         cmp       ah,ds:[LinMax]           ; je jië maxim†ln° poáet znakñ ?
         jae       LinRgh2                  ; je jië konec ©†dku
         inc       ah                       ; zvò®en° pozice kurzoru
LinRgh2: jmp       short EditLin8

LinRgh   ENDP

; -----------------------------------------------------------------------------
;        posun kurzoru na zaá†tek ©†dku
; -----------------------------------------------------------------------------

LinHome  PROC      NEAR

         call      StrtLMnu                 ; zah†jen° editace ©†dku
         mov       ah,0
         jmp       short EditLin8

LinHome  ENDP

; -----------------------------------------------------------------------------
;        posun kurzoru na konec ©†dku
; -----------------------------------------------------------------------------

LinEnd   PROC      NEAR

         call      StrtLMnu                 ; zah†jen° editace ©†dku
         mov       ah,ds:[LinNum]           ; poáet znakñ v bufferu
LinEnd2: jmp       short EditLin8

LinEnd   ENDP

; -----------------------------------------------------------------------------
;        slovo vlevo
; -----------------------------------------------------------------------------

LinCLf   PROC      NEAR

         call      StrtLMnu                 ; zah†jen° editace ©†dku

; ------ kontrola, zda je jië zaá†tek ©†dku

         or        ah,ah                    ; je kurzor jië na zaá†tku ©†dku ?
         jz        LinEnd2                  ; je jië zaá†tek ©†dku

; ------ posun kurzoru vlevo

LinCLf1: dec       di                       ; sn°ëen° adresy v bufferu
         dec       ah                       ; sn°ëen° pozice kurzoru
         jz        LinEnd2                  ; je jië zaá†tek ©†dku

; ------ test, zda je jië zaá†tek slova

         push      ax
         mov       ax,ds:[di-1]             ; 2 znaky z textu
         call      far ptr TestWrd          ; test, zda je jië zaá†tek slova
         pop       ax
         jc        LinCLf1                  ; nen° zaá†tek slova - dal®° znak
         jmp       short LinEnd2            ; novÇ zobrazen° ©†dku

LinCLf   ENDP

; -----------------------------------------------------------------------------
;        slovo vpravo
; -----------------------------------------------------------------------------

LinCRg   PROC      NEAR

         call      StrtLMnu                 ; zah†jen° editace ©†dku

; ------ kontrola, zda je konec ©†dku

         cmp       ah,ds:[LinNum]           ; je konec ©†dku ?
         jae       LinEnd2                  ; je konec ©†dku

; ------ posun kurzoru vpravo

LinCRg1: inc       ah                       ; zvò®en° pozice kurzoru
         inc       di                       ; zvò®en° adresy v bufferu

; ------ test, zda je jië konec textu

         cmp       ah,ds:[LinNum]           ; je konec ©†dku ?
         jae       LinEnd2                  ; je konec ©†dku

; ------ test, zda je jië zaá†tek slova

         push      ax
         mov       ax,ds:[di-1]             ; novÇ 2 znaky z textu
         call      far ptr TestWrd          ; test, zda je jië zaá†tek slova
         pop       ax
         jc        LinCRg1                  ; nen° zaá†tek slova - dal®° znak
LinCRg4: jmp       short LinEnd2            ; novÇ zobrazen° ©†dku

LinCRg   ENDP

; -----------------------------------------------------------------------------
;        z†màna dvou znakñ za kurzorem
; -----------------------------------------------------------------------------

LinCPom  PROC      NEAR

         call      StrtLMnu                 ; zah†jen° editace ©†dku

; ------ kontrola, zda n†sleduj° 2 znaky

         inc       ax                       ; kurzor + 1
         cmp       al,ds:[LinNum]           ; zbòvaj° 2 znaky ?
         ja        LinCRg4                  ; kurzor je na konci ©†dku
         jb        LinCPom2                 ; n†sleduj° 2 znaky

; ------ z†màna 2 znakñ, pokud n†sleduje 1 znak

         cmp       al,ds:[LinMax]           ; je na konci ©†dku ?
         jae       LinCRg4                  ; je na konci ©†dku - nic se nedàje
         mov       al,ds:[di]
         mov       ds:[di+1],al
         mov       byte ptr ds:[di]," "     ; mezera
         inc       byte ptr ds:[LinNum]     ; zvò®en° poátu znakñ
         jmp       short LinCRg4            ; novÇ zobrazen° ©†dku

; ------ z†màna 2 znakñ za kurzorem

LinCPom2:mov       al,ds:[di]
         xchg      al,ds:[di+1]             ; z†màna znakñ
         mov       ds:[di],al
LinCPom4:jmp       short LinCRg4            ; podm°nànÇ zobrazen° ©†dku

LinCPom  ENDP

; -----------------------------------------------------------------------------
;        maz†n° znaku p©ed kurzorem
; -----------------------------------------------------------------------------

LinBs    PROC      NEAR

         call      StrtLMnu                 ; zah†jen° editace ©†dku

; ------ kontrola, zda je jië zaá†tek ©†dku

         cmp       ah,0                     ; je jië zaá†tek ©†dku ?
         je        LinCPom4                 ; je jië zaá†tek ©†dku

; ------ posun kurzoru o pozici vlevo

         dec       ah                       ; sn°ëen° pozice kurzoru
                                          ;* pokraáuje maz†n° znaku nad kurz.
LinBs    ENDP

; -----------------------------------------------------------------------------
;        maz†n° znaku za kurzorem (mus° n†sledovat za LinBs !)
; -----------------------------------------------------------------------------

LinDel   PROC      NEAR

         call      StrtLMnu                 ; zah†jen° editace ©†dku

; ------ kontrola, zda je co mazat

         cmp       ah,ds:[LinNum]           ; je kurzor na konci ©†dku ?
         jae       LinCPom4                 ; kurzor na konci - nen° co mazat

; ------ maz†n° znaku v bufferu

         call      DelLChar
         jmp       short LinCPom4

LinDel   ENDP

; -----------------------------------------------------------------------------
;        vymaz†n° slova p©ed kurzorem
; -----------------------------------------------------------------------------

LinCBS   PROC      NEAR

         call      StrtLMnu                 ; zah†jen° editace ©†dku

; ------ kontrola, zda je jië zaá†tek ©†dku

         or        ah,ah                    ; je kurzor jië na zaá†tku ©†dku ?
         jz        LinCPom4                 ; je jië zaá†tek ©†dku

; ------ vypu®tàn° jednoho znaku p©ed kurzorem

LinCBS1: dec       ah                       ; sn°ëen° pozice kurzoru
         dec       di                       ; sn°ëen° adresy v bufferu
         mov       bh,ds:[di]               ; vypou®tànò znak
         call      DelLChar                 ; zru®en° jednoho znaku z textu

; ------ test, zda je jië zaá†tek bufferu

         or        ah,ah                    ; je jië zaá†tek ©†dku ?
         jz        LinCPom4                 ; je jië zaá†tek ©†dku

; ------ test, zda je jië zaá†tek slova

         push      ax
         mov       al,ds:[di-1]             ; p©edchoz° znak
         mov       ah,bh                    ; vypou®tànò znak
         call      far ptr TestWrd          ; test, zda je jië zaá†tek slova
         pop       ax
         jc        LinCBS1                  ; nen° zaá†tek slova - dal®° znak
LinCBS4: jmp       short LinCPom4           ; novÇ zobrazen° ©†dku

LinCBS   ENDP

; -----------------------------------------------------------------------------
;        vymaz†n° slova za kurzorem
; -----------------------------------------------------------------------------

LinCDel  PROC      NEAR

         call      StrtLMnu                 ; zah†jen° editace ©†dku

; ------ kontrola, zda je konec ©†dku

         cmp       ah,ds:[LinNum]           ; je konec ©†dku ?
         jae       LinCBS4                  ; je konec ©†dku

; ------ vypu®tàn° jednoho znaku za kurzorem

LinCDel1:mov       bx,ds:[di]               ; n†sleduj°c° 2 znaky
         call      DelLChar                 ; zru®en° jednoho znaku z textu

; ------ test, zda je jië konec textu

         cmp       ah,ds:[LinNum]           ; je konec ©†dku ?
         jae       LinCBS4                  ; je konec ©†dku

; ------ test, zda je jië zaá†tek slova

         push      ax
         xchg      ax,bx                    ; AX <- 2 znaky z textu
         call      far ptr TestWrd          ; test, zda je jië zaá†tek slova
         pop       ax
         jc        LinCDel1                 ; nen° zaá†tek slova - dal®° znak
         jmp       short LinCBS4            ; novÇ zobrazen° ©†dku

LinCDel  ENDP

; -----------------------------------------------------------------------------
;        vymaz†n° ©†dku Ctrl-Y
; -----------------------------------------------------------------------------

LinClr   PROC      NEAR

         mov       ah,0                     ; kurzor na poá†tek ©†dku
         mov       byte ptr ds:[LinTop],0   ; poá†tek ©†dku
         mov       byte ptr ds:[LinNum],0   ; poáet znakñ v ©†dku
         jmp       short LinCBS4

LinClr   ENDP

; -----------------------------------------------------------------------------
;        maz†n° znaku nad kurzorem AH - podprogram
; -----------------------------------------------------------------------------

DelLChar PROC      NEAR

; ------ £schova registrñ

         push      cx
         push      si
         push      di

; ------ maz†n° znaku v bufferu

         mov       cl,ah                    ; kurzor
         xor       ch,ch
         mov       si,offset LinBuff        ; buffer s textem ©†dku
         add       si,cx                    ; adresa kurzoru v bufferu
         mov       di,si                    ; adresa kurzoru
         inc       si                       ; adresa kurzoru + 1
         mov       cl,ds:[LinNum]           ; poáet znakñ v bufferu
         sub       cl,ah                    ; zbylò poáet znakñ za kurzorem
         jbe       DelLChr6                 ; kurzor nen° platnò
         cld                                ; zmàr nahoru
         rep       movsb                    ; p©°sun zbytku textu
         dec       byte ptr ds:[LinNum]     ; sn°ëen° poátu znakñ v bufferu

; ------ n†vrat registrñ

DelLChr6:pop       di
         pop       si
         pop       cx
         ret

DelLChar ENDP

; -----------------------------------------------------------------------------
;                                StrtLMnu
;                    zah†jen° editace ©†dku ©†dkovÇho menu
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa definice ©†dkovÇho menu
;        DS=datovò segment
; -----------------------------------------------------------------------------

StrtLMnu PROC      NEAR

; ------ test, zda je editace jië zah†jena

         cmp       byte ptr ds:[LinTop],-1  ; je editace ?
         jne       StrtLMn9                 ; je jië editace
         cmp       word ptr ds:[si+LMnuDis],0 ; jsou zobrazeny nàjakÇ ©†dky ?
         je        StrtLMn9                 ; nejsou zobrazeny ©†dky

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      si
         push      di
         push      ds
         push      es

; ------ inicializace ukazatelñ ©†dku

         mov       byte ptr ds:[LinTop],0   ; p©°znak zah†jen° editace
         mov       byte ptr ds:[LinNum],0   ; nen° ë†dnò znak v ©†dku

; ------ adresa historie menu

         mov       cx,ds:[si+LMnuAkt]       ; aktivn° editovanò ©†dek (0...)
         mov       al,ds:[si+LMnuHis]       ; identifik†tor historie
         push      ds                       ; datovò segment
         call      far ptr GetHist          ; adresa historie
;         mov       bh,0
;         mov       bl,ds:[LinMax]           ; maxim†ln° dÇlka ©†dku
         push      es
         pop       ds                       ; DS <- segment historie
         pop       es                       ; ES <- datovò segment
         jc        StrtLMn4                 ; nen° historie

; ------ test, zda je editovanò ©†dek v historii

         cld
         cmp       cx,ds:[di+HistSNum]      ; je ©†dek v historii ?
         jae       StrtLMn3                 ; nen° ©†dek v historii

; ------ nalezen° ©†dku v historii

         mov       si,di                    ; adresa historie
         add       si,HistSBeg              ; adresa prvn° poloëky
         jcxz      StrtLMn2                 ; je prvn° poloëka historie
StrtLMn1:lodsw                              ; dÇlka textu poloëky historie
         and       ax,HistDelM              ; maska dÇlky poloëky
         add       si,ax                    ; adresa dal®° poloëky historie
         loop      StrtLMn1                 ; dal®° poloëka historie
StrtLMn2:lodsw                              ; dÇlka poloëky historie
         and       ax,HistDelM              ; maska dÇlky poloëky
         xchg      ax,cx                    ; CX <- dÇlka textu poloëky
         jmp       short StrtLMn5           ; p©enesen° textu ©†dku

; ------ test, zda je editovanò ©†dek v p©edvolb†ch

StrtLMn3:sub       cx,ds:[di+HistSNum]      ; zbylò poáet poloëek
StrtLMn4:push      es
         pop       ds                       ; DS <- datovò segment
         cmp       cl,ds:[si+LMnuPreN]      ; je ©†dek s p©edvolbou ?
         jae       StrtLMn8                 ; nen° ani ©†dek s p©edvolbou

; ------ adresa ©†dku s p©edvolbou

         mov       al,6                     ; poáet bajtñ na poloëku tabulky
         mul       cl                       ; vòpoáet offsetu v tabulce
         add       si,ax                    ; adresa parametrñ p©edvolby
         mov       cx,ds:[si+LMnuPreA]      ; dÇlka textu p©edvolby
         lds       si,ds:[si+LMnuPreA+2]    ; adresa textu p©edvolby

; ------ omezen° dÇlky textu

StrtLMn5:cmp       cx,255                   ; je dÇlka textu OK ?
         jbe       StrtLMn6                 ; dÇlka textu je OK
         mov       cx,255                   ; omezen° maxim†ln° dÇlky textu

; ------ p©enesen° textu ©†dku

StrtLMn6:mov       di,offset LinBuff        ; buffer ©†dku
         mov       es:[LinNum],cl           ; dÇlka textu
         rep       movsb                    ; p©enesen° textu ©†dku do bufferu

; ------ n†vrat registrñ

StrtLMn8:pop       es
         pop       ds
         pop       di
         pop       si
         pop       cx
         pop       bx
         pop       ax

; ------ redukce ©†dku v bufferu

         call      RedLBMnu                 ; redukce bufferu ©†dkovÇho menu
StrtLMn9:ret

StrtLMnu ENDP

; -----------------------------------------------------------------------------
;        redukce bufferu ©†dkovÇho menu DS:SI
; -----------------------------------------------------------------------------

RedLBMnu PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      di

; ------ p©°prava ke korekci bufferu

         mov       di,offset LinBuff        ; átec° adresa z bufferu
         mov       bx,di                    ; ukl†dac° adresa do bufferu
         mov       ch,0
         mov       cl,ds:[LinNum]           ; poáet znakñ v bufferu
         jcxz      RedLBMn7                 ; nen° ë†dnò znak

; ------ znak z bufferu

RedLBMn3:mov       al,ds:[di]               ; znak z bufferu
         inc       di                       ; zvò®en° átec° adresy

; ------ test znaku maskou

         push      cx
         push      bx
         push      ds

         mov       ah,0
         mov       bx,ax                    ; BX <- znak
         mov       dl,ds:[si+LMnuMask]      ; maska
         mov       cx,SEG CodeDek
         mov       ds,cx

         ASSUME    ds:CodeDek
         mov       dh,ds:[TabTypCh+bx] ; parametry z tabulky
         ASSUME    ds:Data

         and       dh,not 3
         test      dl,dh                    ; je znak povolen ?

         pop       ds
         pop       bx
         pop       cx
         jz        RedLBMn6                 ; znak nen° povolen

; ------ nalezen° znaku v tabulce zak†zanòch znakñ

         push      si
         mov       dl,ds:[si+LMnuZakN]      ; poáet zak†zanòch znakñ
         or        dl,dl                    ; jsou nàjakÇ zak†zanÇ znaky ?
         jz        RedLBMn5                 ; nejsou zak†zanÇ znaky
RedLBMn4:cmp       al,ds:[si+LMnuZak]       ; je to zak†zanò znak ?
         stc                                ; p©°znak chyby
         je        RedLBMn5                 ; je to zak†zanò znak
         inc       si                       ; zvò®en° ukazatele znakñ
         sub       dl,1                     ; á°taá zak†zanòch znakñ
         jnz       RedLBMn4                 ; test dal®°ho znaku
RedLBMn5:pop       si
         jc        RedLBMn6                 ; je zak†zanò znak

; ------ znak je povolen - uloëen° znaku

         mov       ds:[bx],al               ; uloëen° znaku
         inc       bx                       ; zvò®en° ukl†dac° adresy znakñ

; ------ dal®° znak

RedLBMn6:loop      RedLBMn3                 ; dal®° znak

; ------ omezen° dÇlky textu v bufferu

RedLBMn7:sub       bx,offset LinBuff        ; dÇlka textu v bufferu
         cmp       bl,ds:[LinMax]           ; je dÇlka textu OK
         jbe       RedLBMn8                 ; dÇlka ©†dku je OK
         mov       bl,ds:[LinMax]           ; omezen° dÇlky textu
RedLBMn8:mov       ds:[LinNum],bl           ; dÇlka textu

; ------ n†vrat registrñ

         pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

RedLBMnu ENDP

; *****************************************************************************
;                                StopLMnu
;                        p©eru®en° editace ©†dku
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

StopLMnu PROC      NEAR

         push      ax

         mov       al,-1                    ; p©°znak neprob°haj°c° editace
         xchg      al,ds:[LinTop]           ; AH <- poá†tek ©†dku
         cmp       al,-1                    ; je zah†jena editace ?
         je        StopLMn2                 ; neprob°h† editace
         sub       ds:[LinKur],al           ; oprava adresy kurzoru
         mov       byte ptr ds:[LinNum],0   ; zru®en° dat v bufferu

StopLMn2:pop       ax
         ret

StopLMnu ENDP

; *****************************************************************************
;                                  DispLine
;           korekce a zobrazen° editovanÇho ©†dku voleb (v reëimu editace)
; -----------------------------------------------------------------------------
; VSTUP: AX=vòstupn° hladina k zobrazen° textu
;        CL=dÇlka ©†dku
;        DL=poá†teán° pozice k zobrazen° ©†dku
;        DH=©†dek k zobrazen° editovanÇho ©†dku
;        DS=datovò segment
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: [BP-2] (2) vòstupn° hladina k zobrazen° textu
; *****************************************************************************

DispLine PROC      FAR

; ------ korekce ukazatelñ ©†dku

         call      KorLine                  ; korekce ukazatelñ ©†dku

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

         mov       ch,0                     ; CX=dÇlka ©†dku
         dec       sp
         dec       sp                       ; lok†ln° promànn†
         sub       sp,cx
         sub       sp,cx                    ; vytvo©en° bufferu v z†sobn°ku
         push      ss
         pop       es                       ; ES <- segment bufferu
         mov       ss:[bp-2],ax             ; vòstupn° hladina k zobrazen°

; ------ inicializaán° vymaz†n° ©†dku

         cld
         mov       di,sp                    ; buffer v z†sobn°ku
         mov       bx,cx                    ; BX <- dÇlka ©†dku
         mov       al," "                   ; mazac° znak mezery
         mov       ah,ds:[ColMnu9]          ; barva - je editace
         rep       stosw                    ; vymaz†n° ©†dku

; ------ p©°prava ukazatelñ editovanÇho ©†dku

         mov       di,sp                    ; buffer v z†sobn°ku
         mov       cl,ds:[LinTop]           ; poá†tek ©†dku (zde je CH=0)
         mov       si,offset LinBuff        ; editaán° buffer ©†dku
         add       si,cx                    ; zaá†tek textu k zobrazen°
         sub       cl,ds:[LinNum]           ; - poáet zbylòch znakñ textu
         jc        DispLin4                 ; poáet znakñ je OK
         mov       cl,0                     ; omezen° - ©†dek je celò vlevo
DispLin4:neg       cl                       ; poáet zbylòch znakñ textu

; ------ omezen° dÇlky textu

         cmp       cx,bx                    ; je text del®° neë ©†dek ?
         jbe       DispLin5                 ; dÇlka textu je OK
         mov       cx,bx                    ; omezen° dÇlky textu
         dec       cx                       ; 1 pozice pro indik†tor p©eteáen°
         inc       bh                       ; BH = 1 p©°znak p©eteáen° konce

; ------ dek¢dov†n° textu

DispLin5:jcxz      DispLin7                 ; nen° ë†dnò text
DispLin6:lodsb                              ; naáten° znaku k zobrazen°
         stosw                              ; uloëen° znaku
         loop      DispLin6                 ; dal®° znak textu

; ------ oznaáen° p©eteáen° konce ©†dku

DispLin7:and       ah,0f0h                  ; zru®en° barvy znaku
         or        ah,ds:[ColMnuA]          ; barva znaku p©eteáen°
         or        bh,bh                    ; bylo p©eteáen° konce ©†dku ?
         jz        DispLin8                 ; nebylo p©eteáen° konce ©†dku
         mov       al,"Ø"                   ; znak p©eteáen° konce ©†dku
         stosw                              ; znak p©eteáen° konce ©†dku

; ------ oznaáen° p©eteáen° zaá†tku ©†dku

DispLin8:mov       si,sp                    ; buffer v z†sobn°ku
         cmp       byte ptr ds:[LinTop],0   ; je zaá†tek ©†dku ?
         je        DispLin9                 ; nen° p©eteáen° zaá†tku ©†dku
         mov       al,"Æ"                   ; znak p©eteáen° zaá†tku ©†dku
         mov       es:[si],ax               ; oznaáen° p©eteáen° zaá†tku ©†dku

; ------ zobrazen° editovanÇho ©†dku

DispLin9:mov       cl,bl                    ; dÇlka ©†dku
         mov       ax,ss:[bp-2]             ; vòstupn° hladina k zobrazen°
         call      far ptr DispMStr         ; zobrazen° ©†dku

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
         call      KurLMnu                  ; zobrazen° kurzoru menu
         ret

DispLine ENDP

; -----------------------------------------------------------------------------
;                                 KorLine
;           oprava ukazatelñ editovanÇho ©†dku menu p©ed zobrazen°m
; -----------------------------------------------------------------------------
; VSTUP: CL=dÇlka zobrazenÇho ©†dku
;        DS=datovò segment
; -----------------------------------------------------------------------------

KorLine  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si

; ------ p©°prava parametrñ ©†dku

         mov       ah,0
         mov       bh,0
         mov       ch,0
         mov       dh,0

         mov       al,ds:[LinMax]           ; maxim†ln° poáet znakñ v ©†dku
         mov       si,ax                    ; SI <- max. poáet znakñ v ©†dku
         mov       al,ds:[LinKur]           ; pozice kurzoru
         mov       bl,ds:[LinNum]           ; poáet znakñ v ©†dku
         mov       dl,ds:[LinTop]           ; poá†tek ©†dku

; ------ omezen° maxim†ln° pozice kurzoru na ©†dku

         cmp       ax,si                    ; p©ekroáen maxim†ln° konec ©†dku ?
         jb        KorLine1                 ; konec ©†dku je OK
         mov       ax,si                    ; maxim†ln° poáet znakñ v ©†dku
         dec       ax                       ; maxim†ln° pozice na ©†dku
         mov       ds:[LinKur],al           ; opravenò kurzor

; ------ oprava poátu znakñ dÇlky textu, je-li kurzor za koncem textu

KorLine1:cmp       ax,bx                    ; je kurzor za koncem textu ?
         jb        KorLine2                 ; kurzor nen° za koncem textu
         mov       bx,ax                    ; oprava - kurzor uráuje konec textu
         inc       bx                       ; váetnà pozice s kurzorem

; ------ stanoven° maxim†ln°ho zaá†tku ©†dku

KorLine2:sub       bx,cx                    ; maxim†ln° poá†tek k zobrazen°
         jbe       KorLine4                 ; ©†dek se zobraz° celò

; ------ ohraniáen° z levÇ strany (kurzor bl°zko okraje nebo p©ed zaá†tkem)

         sub       al,4                     ; rezerva od kurzoru na levÇm okraji
         jbe       KorLine4                 ; bl°zko okraje - zobraz° se zaá†tek
         cmp       ax,dx                    ; je p©ed zaá†tkem ©†dku ?
         jb        KorLine5                 ; je p©ed zaá†tkem - plat° kurzor

; ------ ohraniáen° z pravÇ strany

         add       ax,4+1+4                 ; n†vrat pozice + rezerva vpravo
         sub       ax,cx                    ; korekce pro pravò okraj
         jbe       KorLine3                 ; nen° je®tà za pravòm okrajem
         cmp       ax,dx                    ; je za pravòm okrajem ?
         jae       KorLine5                 ; je za pravòm okrajem - plat°
KorLine3:xchg      ax,dx                    ; AX <- plat° souáasnò poá†tek
         jmp       short KorLine5           ; je konec ©†dku

; ------ zobraz° se zaá†tek ©†dku

KorLine4:xor       ax,ax                    ; bude zaá†tek ©†dku
         xor       bx,bx                    ; fiktivn° maxim†ln° zaá†tek

; ------ kontrola maxim†ln°ho zaá†tku

KorLine5:cmp       ax,bx                    ; p©ekroáen maxim†ln° zaá†tek ?
         jb        KorLine8                 ; nen° p©ekroáen maxim†ln° zaá†tek
         xchg      ax,bx                    ; AX <- omezen° na maxim†ln° zaá†tek

; ------ uloëen° novÇho poá†tku ©†dku

KorLine8:mov       ds:[LinTop],al           ; novò poá†tek ©†dku

; ------ n†vrat registrñ

         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

KorLine  ENDP

; *****************************************************************************
;                                  DispLMnu
;                         zobrazen° ©†dkovÇho menu
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa definice menu
;        DS=datovò segment
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-1] (1) ukazatel ©†dku na displeji
;                   SS:[BP-2] (1) poá†teán° pozice okna
;                   SS:[BP-3] (1)
;                   SS:[BP-4] (1) ®°©ka okna
;                   SS:[BP-6] (2) ukazatel definice poloëek voleb
;                   SS:[BP-8] (2) á°taá poloëek menu
;                   SS:[BP-9] (1) levò okraj poloëek
;                   SS:[BP-10] (1) pravò okraj poloëek
;                   SS:[BP-11] (1) oddàlovac° mezera poloëek
;                   SS:[BP-12] (1) parametry:  bit 0 - edit. ©†dky jsou aktivn°
;                                              bit 1 - zobrazen editovanò ©†dek
;                                              bit 2 - p©eteáen° konce ©†dku
;                   SS:[BP-14] (2) aktivn° poloëka menu
;                   SS:[BP-16] (2) adresa blokovac° tabulky
;                   SS:[BP-18] (2) ukazatel znaáek poloëek horizont†ln°ch voleb
;                   SS:[BP-20] (2) prvn° zobrazenò ©†dek
;                   SS:[BP-22] (2) aktivn° (editovanò) ©†dek
;                   SS:[BP-24] (2) á°taá editovanòch ©†dkñ k zobrazen°
;                   SS:[BP-26] (2) segment historie
;                   SS:[BP-28] (2) ukazatel poloëek historie
;                   SS:[BP-30] (2) poáet ©†dkñ historie
;                   SS:[BP-32] (2) ukazatel p©edvoleb
;                   SS:[BP-34] (2) poáet p©edvoleb
;                   SS:[BP-36] (2) á°slo vòstupn° hladiny k zobrazen° menu
;
;                   SS:[BP-37] (1) bàën† barva volby - vnit©ek
;                   SS:[BP-38] (1) barva kurzoru volby - vnit©ek
;                   SS:[BP-39] (1) p©°znak povolen° poloëky
; *****************************************************************************
;
DispLMnu PROC      FAR

; ------ zobrazen° r†mu okna

         call      far ptr DispRamM         ; zobrazen° horn° a doln° linky
         call      KorLMnu                  ; korekce okna p©ed zobrazen°m

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

; ------ vytvo©en° bufferu v z†sobn°ku

         sub       sp,40                    ; m°sto pro lok†ln° promànnÇ
         mov       al,ds:[si+MnuSir]        ; ®°©ka okna
         mov       ah,0
         mov       ss:[bp-4],ax             ; ®°©ka okna
         shl       ax,1                     ; poáet bajtñ na ©†dek okna menu
         sub       sp,ax                    ; buffer k dek¢dov†n° ©†dku

; ------ inicializace lok†ln°ch promànnòch

         mov       ax,word ptr ds:[si+MnuPoz]        ; poá†teán° pozice a ©†dek okna
         inc       ah                       ; prvn° ©†dek (bez r†mu)
         mov       ss:[bp-2],ax             ; poá†teán° pozice a ©†dek okna
         mov       ax,ds:[si+MnuPol]        ; adresa definice poloëek menu
         mov       ss:[bp-6],ax             ; ukazatel definice poloëek menu
         mov       ax,ds:[si+MnuSum]        ; celkovò poáet poloëek menu
         mov       ss:[bp-8],ax             ; á°taá poloëek menu
         mov       ax,ds:[si+MnuAkt]        ; aktivn° poloëka menu
         mov       ss:[bp-14],ax            ; aktivn° poloëka menu
         mov       byte ptr ss:[bp-12],0    ; parametry
         mov       ax,ds:[si+MnuBlk]        ; adresa blokovac° tabulky
         mov       ss:[bp-16],ax            ; adresa blokovac° tabulky

; ------ definice ©†dkñ

         mov       ax,ds:[si+LMnuTop]       ; prvn° zobrazenò ©†dek
         mov       ss:[bp-20],ax            ; prvn° zobrazenò ©†dek
         mov       ax,ds:[si+LMnuAkt]       ; aktivn° ©†dek
         inc       ax
         mov       ss:[bp-22],ax            ; á°taá aktivn°ho ©†dku
         mov       ax,ds:[si+LMnuDis]       ; poáet zobrazenòch ©†dkñ
         mov       ss:[bp-24],ax            ; á°taá ©†dkñ k zobrazen°

; ------ definice historie

         mov       word ptr ss:[bp-30],0    ; p©ednastaven° - nen° historie
         mov       al,ds:[si+LMnuHis]       ; identifik†tor historie
         call      far ptr GetHist          ; poskytnut° adresy historie
         jc        DispLMn1                 ; nen° historie
         mov       ss:[bp-26],es            ; segment historie
         mov       ax,es:[di+HistSNum]      ; poáet ©†dkñ historie
         mov       ss:[bp-30],ax            ; poáet ©†dkñ historie
         add       di,HistSBeg              ; adresa prvn° poloëky
         mov       ss:[bp-28],di            ; ukazatel poloëek historie

; ------ definice p©edvolby

DispLMn1:mov       word ptr ss:[bp-32],LMnuPreA ; offset p©edvoleb
         add       ss:[bp-32],si            ; adresa p©edvolby
         mov       ah,0
         mov       al,ds:[si+LMnuPreN]      ; poáet p©edvoleb
         mov       ss:[bp-34],ax            ; poáet p©edvoleb

; ------ vòstupn° hladina k zobrazen° menu

         mov       al,ds:[si+MnuLev]        ; vòstupn° hladina
         mov       ss:[bp-36],ax            ; hladina k zobrazen° textu

; ------ dek¢dov†n° ©†dkñ nadpisu

         call      DispLMTx                 ; zobrazen° textovòch ©†dkñ menu

; ------ kontrola, zda se zobraz° editovanÇ ©†dky

         mov       si,ss:[bp-6]             ; adresa definice poloëek menu
         cmp       word ptr ss:[bp-24],0    ; jsou zobrazeny ©†dky ?
         jne       DispLMn2                 ; jsou zobrazeny ©†dky
         jmp       DispLMn8                 ; pokraáuj° volby

; ------ stanoven° p©°znaky aktivity ©†dkñ

DispLMn2:dec       word ptr ss:[bp-14]      ; sn°ëen° ukazatele aktivn° poloëky
         jnz       DispLM22                 ; ©†dky nejsou aktivn°
         or        byte ptr ss:[bp-12],bit0 ; p©°znak aktivity ©†dkñ

; ------ nalezen° prvn°ho ©†dku k zobrazen°

DispLM22:cmp       word ptr ss:[bp-20],0    ; je prvn° ©†dek ?
         je        DispLMn3                 ; ©†dek nalezen
DispLM24:call      DispLMNx                 ; posun na dal®° editovanò ©†dek
         jc        DispLMn3                 ; nen° dal®° ©†dek
         dec       word ptr ss:[bp-22]      ; sn°ëen° aktivn°ho ©†dku
         dec       word ptr ss:[bp-20]      ; sn°ëen° á°taáe prvn°ho ©†dku
         jnz       DispLM24                 ; dal®° ©†dek

; ------ p©°prava registrñ k dek¢dov†n° jednoho ©†dku textu

DispLMn3:push      ss
         pop       es                       ; ES <- segment bufferu v z†sobn°ku
         mov       di,sp                    ; buffer v z†sobn°ku
         and       byte ptr ss:[bp-12],not bit1+bit2 ; nulov†n° p©°znakñ ©†dku
         cld

; ------ levò okraj ©†dku

         mov       ah,ds:[ColMnu1R]         ; bàën† barva menu
         mov       al,"≥"                   ; "≥" levò okraj
         stosw                              ; uloëen° levÇho okraje

; ------ dÇlka ©†dku (vnit©n° ®°©ka okna)

         mov       ch,0
         mov       cl,ss:[bp-4]             ; ®°©ka okna
         dec       cx
         dec       cx                       ; vnit©n° ®°©ka okna

; ------ uráen° barvy ©†dku

         mov       ah,ds:[ColMnu7]          ; bàën† barva ©†dku
         dec       word ptr ss:[bp-22]      ; á°taá aktivn°ho ©†dku
         jnz       DispLM32                 ; nen° aktivn° ©†dek
         mov       ah,ss:[bp-1]             ; ©†dek na displeji
         mov       ds:[LinRad],ah           ; £schova polohy ©†dku na displeji
         mov       ah,ds:[ColMnu8]          ; barva aktivn°ho ©†dku (s kurzorem)
         cmp       byte ptr ds:[LinTop],-1  ; zapoáata editace ©†dku ?
         je        DispLM32                 ; nen° editace ©†dku
         mov       ah,ds:[ColMnu9]          ; barva editovanÇho ©†dku
         or        byte ptr ss:[bp-12],bit1 ; p©°znak zobrazen° editov. ©†dku

; ------ inicializaán° vymaz†n° ©†dku

DispLM32:push      cx                       ; CX=vnit©n° ®°©ka okna
         push      ax                       ; AH=barva ©†dku
         push      di                       ; DI=adresa bufferu v z†sobn°ku
         mov       al," "                   ; mazac° znak mezery
         rep       stosw                    ; vymaz†n° ©†dku
         mov       ah,ds:[ColMnu1L]         ; bàën† barva menu
         mov       al,"≥"                   ; "≥" pravò okraj
         stosw                              ; uloëen° pravÇho okraje
         pop       di                       ; DI=adresa bufferu v z†sobn°ku
         pop       ax                       ; AH=barva ©†dku
         pop       bx                       ; BX <- maxim†ln° dÇlka ©†dku

; ------ bude zobrazen editovanò ©†dek (zde je CX=0 !)

         push      ds                       ; £schova datovÇho segmentu (!!!)
         test      byte ptr ss:[bp-12],bit1 ; je editovanò ©†dek ?
         jz        DispLM36                 ; nen° editovanò ©†dek
         mov       cl,ds:[LinTop]           ; poá†tek ©†dku
         mov       si,offset LinBuff        ; editaán° buffer ©†dku
         add       si,cx                    ; zaá†tek textu k zobrazen°
         sub       cl,ds:[LinNum]           ; - poáet zbylòch znakñ textu
         jc        DispLM34                 ; poáet znakñ OK
         xor       cx,cx                    ; omezen° dÇlky textu na 0
DispLM34:neg       cl                       ; poáet zbylòch znakñ textu
         jmp       short DispLMn4

; ------ p©°prava ©†dku z historie

DispLM36:cmp       word ptr ss:[bp-30],0    ; je ©†dek historie ?
         je        DispLM38                 ; nen° historie
         mov       ch,ds:[ColMnuB]          ; barva z†kazu ru®en°
         cmp       word ptr ss:[bp-22],0    ; je aktivn° ©†dek ?
         jne       DispLM35                 ; nen° aktivn° ©†dek
         mov       ch,ds:[ColMnuC]          ; barva kurzoru na z†kazu
DispLM35:mov       ds,ss:[bp-26]            ; segment historie
         mov       si,ss:[bp-28]            ; ukazatel historie
         test      byte ptr ds:[si+HistDelk+1],bit15/HI ; je z†kaz ru®en° ?
         jz        DispLM37                 ; nen° z†kaz ru®en°
         mov       ah,ch                    ; barva chr†nànÇ poloëky

DispLM37:mov       cx,ds:[si+HistDelk]      ; dÇlka ©†dku historie
         and       cx,HistDelM              ; dÇlka textu historie
         inc       si
         inc       si                       ; zaá†tek textu poloëky historie
         jmp       short DispLMn4

; ------ p©°prava ©†dku z p©edvolby

DispLM38:cmp       word ptr ss:[bp-34],0    ; je dal®° p©edvolba ?
         je        DispLM44                 ; nen° dal®° ©†dek (zde je CX=0 !)
         mov       si,ss:[bp-32]            ; ukazatel p©edvoleb
         mov       cx,ds:[si]               ; dÇlka textu p©edvolby
         lds       si,ds:[si+2]             ; adresa p©edvolby

; ------ omezen° dÇlky textu

DispLMn4:jcxz      DispLM44                 ; nen° text
         cmp       cx,bx                    ; je text del®° neë ©†dek ?
         jbe       DispLM42                 ; dÇlka textu je OK
         mov       cx,bx                    ; omezen° dÇlky textu
         dec       cx                       ; 1 pozice pro indik†tor p©eteáen°
         or        byte ptr ss:[bp-12],bit2 ; p©°znak p©eteáen° konce ©†dku

; ------ dek¢dov†n° textu

DispLM42:lodsb                              ; naáten° znaku k zobrazen°
         stosw                              ; uloëen° znaku
         loop      DispLM42                 ; dal®° znak textu
DispLM44:pop       ds                       ; n†vrat datovÇho segmentu

; ------ oznaáen° p©eteáen° konce ©†dku

         and       ah,0f0h                  ; zru®en° barvy znaku
         or        ah,ds:[ColMnuA]          ; barva znaku p©eteáen°
         test      byte ptr ss:[bp-12],bit2 ; bylo p©eteáen° konce ©†dku ?
         jz        DispLMn5                 ; nebylo p©eteáen° konce ©†dku
         mov       al,"Ø"                   ; znak p©eteáen° konce ©†dku
         stosw                              ; znak p©eteáen° konce ©†dku

; ------ oznaáen° p©eteáen° zaá†tku ©†dku

DispLMn5:mov       si,sp                    ; buffer v z†sobn°ku
         test      byte ptr ss:[bp-12],bit1 ; je zobrazen editovanò ©†dek ?
         jz        DispLMn6                 ; nen° editace ©†dku
         cmp       byte ptr ds:[LinTop],0   ; je zaá†tek ©†dku ?
         je        DispLMn6                 ; nen° p©eteáen° zaá†tku ©†dku
         mov       al,"Æ"                   ; znak p©eteáen° zaá†tku ©†dku
         mov       es:[si+2],ax             ; oznaáen° p©eteáen° zaá†tku ©†dku

; ------ zobrazen° editovanÇho ©†dku

DispLMn6:mov       cl,ss:[bp-4]             ; ®°©ka okna
         mov       dx,ss:[bp-2]             ; aktu†ln° pozice a ©†dek
         mov       ax,ss:[bp-36]            ; á°slo vòstupn° hladiny
         call      far ptr DispMStr         ; zobrazen° ©†dku

; ------ p©°prava pro dal®° ©†dek

         call      DispLMNx                 ; adresa dal®°ho ©†dku
         inc       byte ptr ss:[bp-1]       ; zvò®en° ukazatele ©†dku
         dec       word ptr ss:[bp-24]      ; posun á°taáe ©†dkñ
         jz        DispLMn7                 ; nen° dal®° ©†dek k zobrazen°
         jmp       DispLMn3                 ; dal®° ©†dek

; ------ posun ukazatele definice poloëek na volby

DispLMn7:mov       si,ss:[bp-6]             ; ukazatel poloëek
         cld
         inc       si                       ; p©eskoáen° parametrñ poloëky
         lodsb                              ; dÇlka textu poloëky
         mov       ah,0
         add       si,ax                    ; adresa dal®° poloëky
         mov       ss:[bp-6],si             ; novò ukazatel
         dec       word ptr ss:[bp-8]       ; sn°ëen° á°taáe poloëek
         inc       word ptr ss:[bp-16]      ; zvò®en° ukazat. blokovac° tabulky

; ------ oddàlovac° text mezi editovanòmi ©†dky a volbami

         call      DispLMTx                 ; zobrazen° textovòch ©†dkñ menu

; ------ kontrola, zda jsou nàjakÇ volby (je-li dal®° poloëka, nen° textov†)

DispLMn8:mov       cx,ss:[bp-8]             ; poáet zbylòch poloëek menu
         jcxz      DispLMn9                 ; nejsou dal®° poloëky

; ------ souáet dÇlek jednotlivòch poloëek

         mov       si,ss:[bp-6]             ; ukazatel definice poloëek menu
         xor       dx,dx                    ; st©adaá dÇlky poloëek
         xor       bx,bx                    ; á°taá poátu poloëek
         mov       ah,0
         cld
DispLM82:lodsb                              ; parametry poloëky
         test      al,bit6                  ; je to platn† poloëka ?
         jnz       DispLM84                 ; nen° dal®° platn† poloëka
         lodsb                              ; dÇlka textu poloëky
         add       dl,al                    ; p©iáten° dÇlky poloëky
         add       dl,4                     ; p©iáten° okrajñ poloëky
         inc       bx                       ; zvò®en° á°taáe poloëek
         add       si,ax                    ; adresa dal®° poloëky
         loop      DispLM82                 ; dal®° poloëka menu

; ------ vòpoáet okrajñ poloëek

DispLM84:mov       ah,0
         mov       al,ss:[bp-4]             ; ®°©ka okna
         sub       al,2                     ; odeáten° okrajñ
         sub       ax,dx                    ; zbylÇ mezery
         inc       bx                       ; poáet poloëek + 1
         div       bl                       ; vòpoáet oddàlovac° mezery
         mov       ss:[bp-9],al             ; levò okraj
         mov       ss:[bp-10],al            ; pravò okraj
         mov       ss:[bp-11],al            ; oddàlovac° mezera poloëek
         shr       ah,1                     ; zbytek mezer/2
         adc       ss:[bp-10],ah            ; pravò + zbytek/2 + lich† mezera
         add       ss:[bp-9],ah             ; levò okraj + zbytek/2

; ------ zobrazen° ©†dkñ poloëek menu

         mov       di,sp                    ; adresa bufferu
         push      ss
         pop       es
         mov       word ptr ss:[bp-18],offset HZnakTab ; adresa znaáek poloëek

         mov       al,ds:[ColMnu3L]         ; levò okraj - kurzor
         mov       ah,ds:[ColMnu1L]         ; levò okraj - bàënò
         mov       ss:[bp-38],ax            ; vnit©ek
;                   SS:[BP-37] (1) bàën† barva volby - vnit©ek
;                   SS:[BP-38] (1) barva kurzoru volby - vnit©ek
         call      DispLMHz                 ; zobrazen° prvn°ho ©†dku

         mov       al,ds:[ColMnu3]          ; barva kurzoru
         mov       ah,ds:[ColMnu1]          ; bàën† barva
         mov       ss:[bp-38],ax            ; vnit©ek

         call      DispLMHz                 ; zobrazen° druhÇho ©†dku

         mov       al,ds:[ColMnu3R]         ; pravò okraj - kurzor
         mov       ah,ds:[ColMnu1R]         ; pravò okraj
         mov       ss:[bp-38],ax            ; vnit©ek

         call      DispLMHz                 ; zobrazen° t©et°ho ©†dku
         mov       ss:[bp-6],si             ; novò ukazatel poloëek
         mov       ss:[bp-8],dh             ; zbylò poáet poloëek menu

; ------ oddàlovac° text za poloëkami

DispLMn9:call      DispLMTx                 ; zobrazen° textovòch ©†dkñ menu

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
         call      KurLMnu                  ; zobrazen° kurzoru menu
         ret

DispLMnu ENDP

; -----------------------------------------------------------------------------
;       zobrazen° textovòch ©†dkñ ©†dkovÇho menu (SS:BP=lok†ln° promànnÇ)
; -----------------------------------------------------------------------------

DispLMTx PROC      NEAR

         push      ax
         mov       si,ss:[bp-6]             ; ukazatel definice menu
         mov       bx,ss:[bp-8]             ; poáet zbylòch poloëek menu
         mov       dx,ss:[bp-2]             ; ©†dek a pozice k zobrazen°
         mov       cl,ss:[bp-4]             ; ®°©ka okna
         mov       ax,ss:[bp-36]            ; á°slo vòstupn° hladiny
         call      far ptr DispTxtR         ; zobrazen° textovòch ©†dkñ
         mov       ss:[bp-1],dh             ; novò ©†dek k zobrazen°
         mov       ss:[bp-8],bx             ; novò poáet zbylòch poloëek menu
         mov       ss:[bp-6],si             ; novò ukazatel poloëek
         pop       ax
         ret

DispLMTx ENDP

; -----------------------------------------------------------------------------
;        posun ukazatele edit. ©†dkñ (SS:BP=promànnÇ, CY=nen° dal®° ©†dek)
; -----------------------------------------------------------------------------

DispLMNx PROC      NEAR

; ------ posun na dal®° ©†dek v historii

         cmp       word ptr ss:[bp-30],0    ; je dal®° ©†dek historie ?
         je        DspLMNx2                 ; nen° dal®° ©†dek historie
         dec       word ptr ss:[bp-30]      ; sn°ëen° á°taáe ©†dkñ
         mov       es,ss:[bp-26]            ; segment historie
         mov       si,ss:[bp-28]            ; ukazatel historie
         cld
         mov       ax,es:[si]               ; dÇlka poloëky historie
         and       ax,HistDelM              ; dÇlka textu ©†dku
         inc       si
         inc       si
         add       si,ax                    ; adresa dal®° poloëky historie
         mov       ss:[bp-28],si            ; novò ukazatel historie
         jmp       short DspLMNx4

; ------ posun na dal®° ©†dek p©edvolby

DspLMNx2:cmp       word ptr ss:[bp-34],0    ; je p©edvolba ?
         stc                                ; p©°znak chyby - nen° dal®° ©†dek
         je        DspLMNx6                 ; nen° dal®° p©edvolba
         dec       word ptr ss:[bp-34]      ; sn°ëen° poátu p©edvoleb
         add       word ptr ss:[bp-32],6    ; posun ukazatele p©edvoleb

DspLMNx4:clc                                ; p©°znak operace OK
DspLMNx6:ret

DispLMNx ENDP

; -----------------------------------------------------------------------------
;        zobrazen° linky horizont†ln°ch voleb
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=buffer v z†sobn°ku k dek¢dov†n° textu
;        SS:BP=lok†ln° promànnÇ
; VùSTUP:DS:SI=adresa n†sleduj°c° za poloëkami
;        DH=zbylò poáet poloëek menu
; -----------------------------------------------------------------------------
;˛
DispLMHz PROC      NEAR

; ------ £schova registrñ

         push      di

; ------ p©°prava ukazatelñ k dek¢dov†n° ©†dku

         cld
         mov       si,ss:[bp-6]             ; adresa definice poloëek
         mov       dh,ss:[bp-8]             ; poáet zbylòch poloëek
         mov       dl,ss:[bp-14]            ; á°taá aktivn° poloëky menu
         mov       bx,ss:[bp-16]            ; ukazatel blokovac° tabulky

; ------ levò okraj okna

         mov       ah,ds:[ColMnu1R]         ; levò okraj r†mu
         mov       al,"≥"                   ; "≥" levò okraj
         stosw                              ; uloëen° znaku levÇho okraje

; ------ £vodn° mezera

         mov       ah,ds:[ColMnu1]
         mov       ch,0
         mov       cl,ss:[bp-9]             ; levò okraj
         mov       al," "
         rep       stosw                    ; uloëen° levÇ mezery

; ------ barva zak†zanÇ poloëky

DispLMH1:mov       al,ds:[bx]
         mov       ss:[bp-39],al
         cmp       byte ptr ds:[bx],0       ; je poloëka povolen† ?
         je        DispLM12                 ; poloëka je povolen†

         dec       dl                       ; á°taá aktivn° poloëky
         push      dx
         push      bx
         mov       ah,ds:[ColMnu6]          ; zak†zan† poloëka s kurzorem
         mov       dh,ah                    ; zak†zan† poloëka s kurzorem
         mov       bx,ss:[bp-18]            ; ukazatel znaáek - kurzor
         jz        DispLMH3                 ; je aktivn° poloëka - kurzor

         mov       ah,ds:[ColMnu5]          ; bàën† zak†zan† poloëka
         mov       dh,ah                    ; bàën† zak†zan† poloëka
         jmp       short DispLM14

; ------ uráen° barvy a znakñ povolenÇ poloëky

DispLM12:dec       dl                       ; á°taá aktivn° poloëky
         push      dx
         push      bx

         mov       ah,ds:[ColMnu3L]
         mov       dh,ds:[ColMnu4]          ; vysv°cen† barva kurzoru
         mov       bx,ss:[bp-18]            ; ukazatel znaáek - kurzor
         jz        DispLMH3                 ; je to aktivn° poloëka

         mov       ah,ds:[ColMnu1L]         ; bàën† barva r†mu
         mov       dh,ds:[ColMnu2]          ; vysv°cen† barva poloëky

; ------ korekce typu r†meáku prvn° poloëky, jsou-li aktivn° ©†dky

DispLM14:cmp       dl,0ffh                  ; prvn° poloëka za ©†dky ?
         jne       DispLMH2                 ; nen° prvn° poloëka za ©†dky
         test      byte ptr ss:[bp-12],bit0 ; jsou aktivn° ©†dky ?
         jnz       DispLMH3                 ; ©†dky jsou aktivn° - dvojit† á†ra
DispLMH2:add       bx,3                     ; jednoduch† á†ra poloëky

; ------ jsou-li ©†dky aktivn°, nen° vysv°cen† barva horkÇ kl†vesy

DispLMH3:test      byte ptr ss:[bp-12],bit0 ; jsou aktivn° ©†dky ?
         jz        DispLMH4                 ; nejsou aktivn° ©†dky
         cmp       byte ptr ss:[bp-39],0    ; poloëka povolen† ?
         jne       DispLMH4                 ; nen° povolen†

         mov       dh,ds:[ColMnu1]          ; nen° vysv°cen† barva horkÇ kl†vesy

; ------ dek¢dov†n° levÇho okraje poloëky

DispLMH4:mov       al,ds:[bx]               ; levò okraj poloëky
         stosw                              ; uloëen° levÇho okraje

         cmp       byte ptr ss:[bp-39],0    ; poloëka povolen† ?
         jne       DspLMH42                 ; nen° povolen†
         mov       ah,ss:[bp-37]            ; bàën† barva
         or        dl,dl
         jnz       DspLMH42
         mov       ah,ss:[bp-38]            ; barva kurzoru

; ------ prvn° oddàlovac° znak poloëky

DspLMH42:mov       bx,ds:[bx+1]             ; druhò a t©et° znak poloëky
         mov       al,bl                    ; oddàlovac° znak
         stosw                              ; prvn° oddàlovac° znak poloëky

; ------ p©°prava parametrñ poloëky

         mov       ch,0
         mov       cl,ds:[si+MnuDelk]       ; dÇlka textu poloëky
         mov       dl,ds:[si+MnuParm]       ; parametry poloëky
         and       dl,not bit6 + bit7       ; pozice horkÇho znaku
         inc       si
         inc       si                       ; zaá†tek textu poloëky
         jcxz      DispLMH8                 ; nen° poloëka

; ------ vymaz†n° poloëky, nen°-li vnit©n° ©†dek

         cmp       bl," "                   ; je druhò ©†dek poloëek ?
         je        DispLMH5                 ; je druhò ©†dek poloëek
         add       si,cx                    ; adresa dal®° poloëky
         mov       al,bl                    ; znak linky
         rep       stosw                    ; uloëen° linky
         jmp       short DispLMH8

; ------ zobrazen° textu poloëky ve vnit©n°m ©†dku

DispLMH5:lodsb                              ; znak poloëky k zobrazen°
         dec       dl                       ; á°taá horkÇho znaku
         jnz       DispLMH6                 ; nen° horkò znak
         xchg      ah,dh                    ; barva horkÇho znaku
         stosw                              ; uloëen° horkÇho znaku
         xchg      ah,dh                    ; n†vrat bàënÇ barvy
         jmp       short DispLMH7
DispLMH6:stosw                              ; uloëen° znaku
DispLMH7:loop      DispLMH5                 ; dal®° znak textu poloëky

; ------ z†vàreánò oddàlovac° znak poloëky a pravò okraj

DispLMH8:mov       al,bl                    ; st©edn° znak
         stosw                              ; uloëen° st©edn°ho znaku

         mov       al,bh                    ; pravò okraj poloëky

         pop       bx                       ; ukazatel blokovac° tabulky
         pop       dx                       ; á°taá poloëek a aktivn° poloëky

         cmp       byte ptr ss:[bp-39],0    ; poloëka povolen† ?
         jne       DspLMH82                 ; nen° povolen†

         mov       ah,ds:[ColMnu1R]
         or        dl,dl
         jnz       DspLMH82
         mov       ah,ds:[ColMnu3R]
DspLMH82:stosw                              ; uloëen° pravÇho okraje poloëky

; ------ p©°prava pro dal®° poloëku


         inc       bx                       ; zvò®en° ukazatele blokov. tabulky
         mov       ah,ds:[ColMnu1]          ; bàën† barva
         mov       al," "                   ; mezera
         dec       dh                       ; sn°ëen° á°taáe poloëek
         jz        DispLMH9                 ; jsou jië v®echny poloëky
         test      byte ptr ds:[si+MnuParm],bit6 ; je dal®° poloëka ?
         jnz       DispLMH9                 ; nen° dal®° poloëka

; ------ oddàlovac° mezera mezi poloëkami

         mov       cl,ss:[bp-11]            ; oddàlovac° mezera poloëek
         rep       stosw                    ; uloëen° mezery mezi poloëkami
         jmp       DispLMH1                 ; dek¢dov†n° dal®° poloëky

; ------ z†vàreán† mezera a pravò okraj

DispLMH9:mov       cl,ss:[bp-10]            ; prav† mezera
         rep       stosw                    ; uloëen° pravÇ mezery
         mov       al,"≥"                   ; "≥" pravò okraj
         mov       ah,ds:[ColMnu1L]
         stosw                              ; uloëen° pravÇho okraje

; ------ zobrazen° ©†dku

         pop       di                       ; adresa bufferu v z†sobn°ku

         xchg      si,di                    ; SI <- adresa bufferu
         push      dx
         mov       cl,ss:[bp-4]             ; ®°©ka okna
         mov       dx,ss:[bp-2]             ; ©†dek a pozice okna
         mov       ax,ss:[bp-36]            ; á°slo vòstupn° hladiny
         call      far ptr DispKStr         ; zobrazen° prvn°ho ©†dku
         inc       byte ptr ss:[bp-1]       ; zvò®en° ukazatele ©†dku
         pop       dx
         xchg      si,di                    ; DI <- adresa bufferu

         add       word ptr ss:[bp-18],6    ; zvò®en° ukazatele znaáek poloëek
         ret

DispLMHz ENDP

; -----------------------------------------------------------------------------
;                              KurLMnu
;                   zobrazen° kurzoru ©†dkovÇho menu
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa definice menu
;        DS=datovò segment
; -----------------------------------------------------------------------------

KurLMnu  PROC      NEAR

; ------ £schova registrñ

         push      dx

; ------ vypnut° kurzoru, pokud nejsou aktivn° ©†dky

         cmp       word ptr ds:[si+LMnuDis],0 ; je nàjakò ©†dek ?
         je        KurLMnu1                 ; nen° ë†dnò ©†dek
         cmp       word ptr ds:[si+MnuAkt],1 ; jsou aktivn° ©†dky ?
         je        KurLMnu2                 ; ©†dky jsou aktivn°
KurLMnu1:call      far ptr KurzOff          ; vypnut° kurzoru
         jmp       short KurLMnu9

; ------ nastaven° kurzoru, pokud je zobrazen

KurLMnu2:mov       dl,ds:[si+MnuPoz]        ; pozice okna menu
         inc       dl                       ; poá†teán° pozice kurzoru
         add       dl,byte ptr ds:[LinKur]  ; pozice kurzoru na ©†dku
         cmp       byte ptr ds:[LinTop],-1  ; je ©†dek zobrazen ?
         je        KurLMnu3                 ; ©†dek nen° zobrazen
         sub       dl,byte ptr ds:[LinTop]  ; odeáten° poá†tku ©†dku
KurLMnu3:mov       dh,ds:[LinRad]           ; poloha ©†dku na displeji
         call      far ptr SetKurz          ; nastaven° pozice kurzoru

; ------ n†vrat registrñ

KurLMnu9:pop       dx
         ret

KurLMnu  ENDP

; -----------------------------------------------------------------------------
;                                   KorLmnu
;                 korekce ©†dkovÇho menu p©ed zobrazen°m
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa definice menu
;        DS=datovò segment
; -----------------------------------------------------------------------------

KorLMnu  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx

; ------ test, zda jsou ©†dky

         cmp       word ptr ds:[si+LMnuDis],0 ; jsou nàjakÇ ©†dky ?
         je        KorLMnu9                 ; nejsou editovanÇ ©†dky

; ------ omezen° á°sla aktivn°ho ©†dku

         mov       ax,ds:[si+LMnuAkt]       ; aktivn° ©†dek
         cmp       ax,ds:[si+LMnuNum]       ; p©ekroáen poáet ©†dkñ ?
         jb        KorLMnu2                 ; poáet ©†dkñ je OK
         mov       ax,ds:[si+LMnuNum]       ; poáet ©†dkñ
         or        ax,ax                    ; jsou nàjakÇ ©†dky ?
         jz        korLMnu1                 ; nejsou ë†dnÇ ©†dky
         dec       ax                       ; á°slo posledn°ho ©†dku
KorLMnu1:mov       ds:[si+LMnuAkt],ax       ; opravenò aktivn° ©†dek

; ------ omezen° poá†teán°ho ©†dku shora

KorLMnu2:mov       bx,ds:[si+LMnuTop]       ; poá†teán° ©†dek
         cmp       ax,bx                    ; je kurzor nad poá†teán°m ©†dkem ?
         jae       KorLMnu3                 ; kurzor je OK
         mov       ds:[si+LMnuTop],ax       ; oprava poá†teán°ho ©†dku

; ------ omezen° poá†teán°ho ©†dku zdola

KorLMnu3:sub       ax,ds:[si+LMnuDis]       ; poá†tek
         jb        KorLMnu9                 ; kurzor nen° za koncem
         inc       ax                       ; korekce
         cmp       ax,bx                    ; je kurzor za koncem ?
         jbe       KorLMnu9                 ; kurzor je OK
         mov       ds:[si+LMnuTop],ax       ; novò poá†tek okna

; ------ n†vrat registrñ

KorLMnu9:pop       bx
         pop       ax
         ret

KorLMnu  ENDP

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                            Menu volby diskñ
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
; *****************************************************************************
;                             DiskMenu
;                       obsluha volby disku
; -----------------------------------------------------------------------------
; VSTUP: AL=vòchoz° p©ednastavenò disk
;        DS:SI=adresa definice menu
; VùSTUP: CY=p©eru®en° volby
;         AL=á°slo zvolenÇho disku (DiskMax=historie)
; *****************************************************************************

DiskMenu PROC      FAR

; ------ £schova registrñ

         push      bx

; ------ p©ednastaven° aktivn° poloëky menu

         call      far ptr KonvDN           ; konverze disku na á°slo poloëky
         inc       ax                       ; korekce
         mov       byte ptr ds:[si+MnuAkt],al ; aktivn° poloëka menu

; ------ otev©en° okna menu

         call      far ptr OpenMnu          ; otev©en° okna menu

; ------ vstup znaku z kl†vesnice

DiskMnu2:call      far ptr KurzOff          ; vypnut° kurzoru
         call      far ptr NulBreak         ; nulov†n° p©°znaku p©eru®en°
         call      far ptr InpChar          ; vstup znaku z kl†vesnice
         jc        DiskMnu8                 ; je p©eru®en° volby ESC

; ------ p©eru®en° menu stiskem pravÇho tlaá°tka nebo stiskem mimo ©†dek

         cmp       bh,MousXKod/HI           ; je k¢d my®i ?
         jne       DiskMnu4                 ; nen° k¢d my®i
         and       bl,not bit6              ; zru®en° p©°znaku dvoj°ho stisku
         cmp       bl,MousXRP               ; stisk pravÇho tlaá°tka ?
         je        DiskMnu3                 ; p©eru®en° pravòm tlaá°tkem my®i
         test      bl,bit2+bit3             ; stisk nàkterÇho tlaá°tka ?
         jz        DiskMnu4                 ; nen° stisk tlaá°tka
         call      far ptr MouseMnu         ; test, zda je okno menu
         jnc       DiskMnu4                 ; nen° p©eru®en°
DiskMnu3:stc                                ; p©°znak p©eru®en°
         jmp       short DiskMnu8

; ------ obsluha okna

DiskMnu4:call      far ptr EditDMnu         ; obsluha editace okna
         jc        DiskMnu2                 ; pokraáov†n° v editaci

; ------ uzav©en° okna menu

DiskMnu8:pushf
         push      si
         call      far ptr ClosMnu          ; uzav©en° okna menu
         pop       si

; ------ konverze á°sla zvolenÇ poloëky na á°slo disku

         mov       al,byte ptr ds:[si+MnuAkt] ; aktivn° zvolen† poloëka
         dec       ax                       ; korekce á°sla poloëky
         call      far ptr KonvND           ; konverze na á°slo disku
         popf

; ------ n†vrat registrñ

         pop       bx
         ret

DiskMenu ENDP

; *****************************************************************************
;                              InitDMnu
;                     inicializace diskovÇho menu
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa definice menu
; *****************************************************************************

InitDMnu PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx

; ------ vòpoáet maxim†ln°ho poátu poloëek na ©†dek

         mov       bl,ds:[Pozic]            ; poáet pozic na ©†dek
         sub       bl,6-1                   ; odeáten° okrajñ
         shr       bl,1
         shr       bl,1
         shr       bl,1                     ; /8 = max. poáet poloëek na ©†dek

; ------ celkovò poáet diskñ v oknà

         mov       ax,ds:[DiskNum]          ; poáet diskñ
         inc       ax                       ; váetnà historie
         mov       ds:[si+MnuNum],ax        ; poáet poloëek menu
         mov       ds:[si+MnuSum],ax        ; celkovò poáet poloëek

; ------ vòpoáet poátu ©†dkñ s poloëkami

         add       al,bl                    ; zarovn†n° na 1 ©†dek
         dec       ax                       ; oprava
         div       bl                       ; vòpoáet poátu ©†dkñ s poloëkami
InitDMn1:mov       ds:[si+DMnuRad],al       ; poáet ©†dkñ s poloëkami
         mov       bh,al                    ; poáet ©†dkñ s poloëkami

; ------ vò®ka okna

         shl       al,1
         add       al,bh                    ; poáet ©†dkñ * 3 ©†dky na poloëku
         add       al,4                     ; p©°davnÇ ©†dky
         mov       ds:[si+MnuVys],al        ; vò®ka okna

; ------ vyst©edàn° okna vertik†lnà

         mov       ah,ds:[Radku]            ; poáet ©†dkñ na obrazovku
         sub       ah,3                     ; posun o trochu nahoru
         sub       ah,al                    ; zbytek na okraje
         ja        InitDMn2                 ; nen° p©eteáen°
         mov       ah,0                     ; omezen° poá†teán°ho ©†dku
InitDMn2:shr       ah,1                     ; polovinu na okraje
         mov       ds:[si+MnuRad],ah        ; poá†teán° ©†dek okna

; ------ up©esnàn° poátu poloëek na ©†dek

         mov       ax,ds:[si+MnuNum]        ; celkovò poáet poloëek
         add       al,bh                    ; zarovn†n° na 1 sloupec
         dec       ax                       ; oprava
         div       bh                       ; vòpoáet poátu pozic s poloëkami
         mov       ds:[si+DMnuPol],al       ; poáet poloëek na ©†dek

; ------ ®°©ka okna

         shl       al,1
         shl       al,1
         shl       al,1                     ; poáet pozic na poloëky
         add       al,4-1                   ; p©iáten° okrajñ
         cmp       al,37                    ; minim†ln° ®°©ka okna
         ja        InitDMn3                 ; ®°©ka okna je dostateán†
         mov       al,37                    ; omezen° minim†ln° ®i©ky okna
InitDMn3:mov       ds:[si+MnuSir],al        ; ®°©ka okna

; ------ vyst©edàn° okna horizont†lnà

         mov       ah,ds:[Pozic]            ; poáet pozic na ©†dek
         sub       ah,al                    ; zbytek na okraje
         jnc       InitDMn4
         mov       ah,0                     ; omezen° poá†teán° pozice
InitDMn4:shr       ah,1                     ; polovina na okraje
         mov       ds:[si+MnuPoz],ah        ; poá†teán° pozice okna

; ------ ovà©en°, zda nen° okno p©°li® ®irokÇ

         mov       ah,ds:[si+DMnuPol]       ; poáet poloëek na ©†dek
         cmp       ah,4                     ; je malò poáet poloëek na ©†dek ?
         jbe       InitDMn5                 ; poáet poloëek na ©†dek je malò
         mov       al,ds:[si+DMnuRad]       ; poáet ©†dkñ s poloëkami
         shr       ah,1                     ; polovina poloëek na ©†dek
         cmp       ah,al                    ; je okno p©°li® ®irokÇ ?
         jb        InitDMn5                 ; ®°©ka okna je OK
         inc       ax                       ; zvò®en° poátu ©†dkñ
         jmp       short InitDMn1           ; nov† korekce parametrñ menu

; ------ inicializace adresy koment†©e aktivn°ho disku

InitDMn5:call      DiskMIK                  ; inicializace koment†©e

; ------ n†vrat registrñ

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

InitDMnu ENDP

; -----------------------------------------------------------------------------
;        inicializace adresy koment†©e k aktivn°mu disku v menu DS:SI
; -----------------------------------------------------------------------------

DiskMIK  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      si
         push      es

; ------ p©°prava á°sla aktivn°ho disku

         mov       al,byte ptr ds:[si+MnuAkt] ; aktivn° zvolen† poloëka
         dec       ax                       ; korekce á°sla poloëky
         call      far ptr KonvND           ; konverze na á°slo disku
         mov       ah,0
         xchg      ax,cx                    ; CX <- á°slo aktivn°ho disku

; ------ adresa bufferu koment†©ñ

         mov       ax,ds:[DiskInfS]         ; segment koment†©ñ
         call      far ptr GetDat           ; adresa segmentu koment†©ñ

; ------ nalezen° adresy koment†©e

         mov       si,2                     ; poá†teán° adresa bufferu
         jcxz      DiskMIK4                 ; je prvn° disk
         mov       ah,0
DiskMIK2:mov       al,es:[si]               ; dÇlka textu koment†©e
         inc       si
         add       si,ax                    ; adresa dal®°ho koment†©e
         loop      DiskMIK2                 ; nalezen° koment†©e k disku
DiskMIK4:mov       ds:[DiskInfA],si         ; adresa textu koment†©e

; ------ n†vrat registrñ

         pop       es
         pop       si
         pop       cx
         pop       ax
         ret

DiskMIK  ENDP

; *****************************************************************************
;                                EditDMnu
;                        editace menu volby disku
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa definice menu
;        BX=kl†vesa
; VùSTUP:BX=0 kl†vesa byla obslouëena
;        NC=provedena volba poloëky
;        CY=pokraáuje editace
; *****************************************************************************

EditDMnu PROC      FAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      di
         push      es

; ------ kontrola, zda je zad†no platnÇ oznaáen° disku

         mov       al,bl                    ; zadan† kl†vesa
         call      far ptr UpCase           ; p©evod znaku na velkÇ p°smeno
         cmp       al,"?"
         je        EditDM11
         cmp       al,"/"
         je        EditDM11
         cmp       al,"\"
         jne       EditDM12
         cmp       byte ptr ds:[DiskITab+"\"-"A"],0 ; je disk "\" ?
         jne       EditDM12                 ; je disk "\"
EditDM11:mov       al,"A"+DiskMax           ; n†hrada pro historii
EditDM12:sub       al,"A"                   ; á°slo disku relativnà
         jc        EditDMn0                 ; neplatnò disk
         cmp       al,DiskMax               ; maxim†ln° á°slo disku + 1
         ja        EditDMn0                 ; neplatnò disk

; ------ test, zda byl zad†n platnò disk

         je        EditDM14                 ; je historie
         push      ax
         mov       ah,0
         add       ax,offset DiskITab       ; adresa v tabulce disk. parametrñ
         xchg      ax,di                    ; DI <- adresa v tabulce parametrñ
         cmp       byte ptr ds:[di],0       ; je to platnò disk ?
         pop       ax
         je        EditDMn0                 ; nen° to platnò disk

; ------ nastaven° zadanÇho disku jako aktivn°

EditDM14:call      far ptr KonvDN           ; konverze disku na á°slo
         inc       ax                       ; korekce á°sla poloëky
         mov       byte ptr ds:[si+MnuAkt],al ; nov† aktivn° poloëka
         call      DiskMIK                  ; inicializace koment†©e
         call      far ptr DispMnu          ; novÇ zobrazen° menu

; ------ ukonáen° volby ENTER

EditDMn1:xor       bx,bx
         jmp       EditDMn9

; ------ obsluha ©°dic° kl†vesy

EditDMn0:mov       cx,word ptr ds:[si+DMnuPol] ; CL <- pol. na ©†dek, CH <- ©†dkñ
         mov       al,ch                    ; AL <- poáet ©†dkñ
         mul       cl                       ; celkovò poáet poloëek
         xchg      ax,dx                    ; DL <- celkovò poáet poloëek
         mov       al,byte ptr ds:[si+MnuAkt] ; aktivn° poloëka
         mov       ah,byte ptr ds:[si+MnuNum] ; celkovò poáet poloëek
         call      far ptr JumpBX

         dw        4b00h,EditDMn3           ; VLEVO
         dw        0f00h,EditDMn3           ; *TAB
         dw        4d00h,EditDMn5           ; VPRAVO
         dw        0f09h,EditDMn5           ; TAB
         dw        4700h,EditDMn6           ; HOME
         dw        4f00h,EditDMn4           ; END
         dw        8400h,EditDMn6           ; ^Page Up
         dw        7600h,EditDMn4           ; ^Page Down
         dw        4800h,EditDM27           ; nahoru
         dw        5000h,EditDM28           ; dolñ

         dw        1c0dh,EditDMn1           ; ENTER

         dw        MousXKod+MousXLR,EditDM22 ; uvolnàn° levÇho tlaá°tka my®i
         dw        MousXKod+MousXLP,EditDM23 ; stisk levÇho tlaá°tka my®i
         dw        MousXKod+MousXMov,EditDM23 ; posun my®i

         dw        0,EditDMn8

; ------ uvolnàn° levÇho tlaá°tka my®i

EditDM22:call      far ptr MouseMnu         ; test, zda je my® v oknà
         jc        EditDMn8                 ; nen° v oknà - nic se nedàje
         jmp       short EditDMn1           ; proveden° volby ENTER

; ------ posun my®i

EditDM23:test      byte ptr ds:[MouseKey],bit1 ; je pouze levÇ tlaá°tko ?
         jnz       EditDMn8                 ; nen° jen levÇ tlaá°tko
         call      far ptr MouseMnu         ; je my® v oknà ?
         jc        EditDMn8                 ; nen° v oknà
         call      DiskMPol                 ; poloëka menu z my®i -> AL
         jmp       short EditDMn7

; ------ posun kurzoru nahoru

EditDM27:sub       al,cl                    ; posun o ©†dek nahoru
         ja        EditDM29                 ; kurzor je OK
         add       al,dl                    ; posun na spodn° okraj
         cmp       al,ah
         jbe       EditDM29                 ; kurzor je OK
         sub       al,cl                    ; posun je®tà o ©†dek
         jmp       short EditDM29           ; kurzor je jië OK

; ------ posun kurzoru dolñ

EditDM28:add       al,cl                    ; posun o ©†dek dolñ
         cmp       al,ah                    ; p©ekroáen konec ?
         jbe       EditDMn7                 ; kurzor je OK
         sub       al,dl                    ; posun na horn° okraj
         ja        EditDMn7                 ; kurzor je OK
         add       al,cl                    ; posun je®tà o ©†dek
EditDM29:jmp       short EditDMn7           ; kurzor je jië OK

; ------ posun kurzoru vlevo

EditDMn3:dec       al
         jnz       EditDMn7

; ------ posledn° poloëka

EditDMn4:mov       al,ah
         jmp       short EditDMn7

; ------ posun kurzoru vpravo

EditDMn5:inc       ax
         cmp       al,ah
         jbe       EditDMn7

; ------ posun na prvn° poloëku

EditDMn6:mov       al,1

; ------ nastaven° novÇ pozice kurzoru

EditDMn7:mov       byte ptr ds:[si+MnuAkt],al
         call      DiskMIK                  ; inicializace koment†©e
EditDM88:call      far ptr DispMnu          ; novÇ zobrazen° menu
         xor       bx,bx
EditDMn8:stc                                ; p©°znak pokraáuj°c° volby

; ------ n†vrat registrñ

EditDMn9:pop       es
         pop       di
         pop       dx
         pop       cx
         pop       ax
         ret

EditDMnu ENDP

; -----------------------------------------------------------------------------
;        poloëka menu z my®i -> AL
; -----------------------------------------------------------------------------

DiskMPol PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      cx
         push      dx

; ------ poá†teán° ©†dek a pozice kurzoru my®i relativnà -> DX

         mov       dx,ds:[MousePoz]         ; ©†dek a pozice kurzoru my®i
         sub       dx,word ptr ds:[si+MnuPoz] ; ©†dek a pozice relativnà

; ------ poáet poloëek na ©†dek -> BX

         mov       bh,0
         mov       bl,ds:[si+DMnuPol]       ; poáet poloëek na ©†dek

; ------ nalezen° ©†dku s poloëkou

         mov       ax,1                     ; ukazatel á°sla poloëky
         sub       dh,3                     ; odeáten° horn°ho okraje
         jbe       DiskMPl2                 ; je to ©†dek 0
DiskMPl1:sub       dh,3                     ; odeáten° vò®ky ©†dku
         jb        DiskMPl2                 ; ©†dek nalezen
         add       ax,bx                    ; zvò®en° ukazatele á°sla poloëky
         cmp       ax,ds:[si+MnuNum]        ; je to je®tà platn† poloëka ?
         jbe       DiskMPl1                 ; je to je®tà platn† poloëka
         sub       ax,bx                    ; n†vrat á°sla poloëky

; ------ p©°prava poá†teán° pozice -> CH

DiskMPl2:mov       cl,bl                    ; CL <- poáet poloëek na ©†dek
         shl       cl,1
         shl       cl,1
         shl       cl,1                     ; * 8 = celkov† ®°©ka okÇnek s disky
         dec       cx                       ; korekce - bez posledn° mezery
         mov       ch,ds:[si+MnuSir]        ; ®°©ka okna
         sub       ch,cl                    ; zbytek na okraje
         shr       ch,1                     ; levò okraj

; ------ nalezen° poloëky na ©†dku

         sub       dl,ch                    ; odeáten° levÇho okraje
         jbe       DiskMPl4                 ; je prvn° disk
DiskMPl3:sub       dl,8                     ; odeáten° ®°©ky volby
         jb        DiskMPl4                 ; volba nalezena
         inc       ax                       ; zvò®en° á°sla volby
         dec       bx                       ; á°taá poloëek na ©†dku
         jnz       DiskMPl3                 ; mñëe bòt dal®° poloëka
         dec       ax                       ; n†vrat á°sla poloëky

; ------ omezen° á°sla poloëky

DiskMPl4:cmp       ax,ds:[si+MnuNum]        ; je to je®tà platn† poloëka ?
         jbe       DiskMPl5                 ; je to je®tà platn† poloëka
         mov       ax,ds:[si+MnuNum]        ; omezen° á°sla poloëky

; ------ n†vrat registrñ

DiskMPl5:pop       dx
         pop       cx
         pop       bx
         ret

DiskMPol ENDP

; *****************************************************************************
;                              DispDMnu
;                    zobrazen° menu volby diskñ
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa definice menu
;        DS=datovò segment
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) adresa definice menu
;                   SS:[BP-3] (1) ukazatel ©†dku okna
;                   SS:[BP-4] (1) poá†teán° pozice okna
;                   SS:[BP-5] (1) vò®ka okna
;                   SS:[BP-6] (1) ®°©ka okna
;                   SS:[BP-7] (1) levò okraj
;                   SS:[BP-8] (1) pravò okraj
;                   SS:[BP-10] (2) á°taá diskñ k zobrazen°
;                   SS:[BP-11] (1) á°taá ©†dkñ pro jeden ©†dek poloëek (3 ©†dky)
;                   SS:[BP-12] (1) ukazatel á°sla disku
;                   SS:[BP-14] (2) adresa v definián° tabulce diskñ
;                   SS:[BP-15] (1) á°taá aktivn° poloëky
;                   SS:[BP-16] (1) poáet poloëek na ©†dek
;                   SS:[BP-18] (2) vòstupn° hladina k zobrazen° textu
; *****************************************************************************

DispDMnu PROC      FAR

         call      far ptr DispRamM         ; zobrazen° horn° a doln° linky

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

         mov       cx,word ptr ds:[si+MnuSir] ; ®°©ka a vò®ka okna
         sub       sp,18                    ; m°sto pro lok†ln° promànnÇ
         mov       ss:[bp-6],cx             ; ®°©ka a vò®ka okna
         mov       ch,0
         shl       cx,1                     ; ®°©ka * 2
         sub       sp,cx                    ; m°sto pro textovò ©†dek

; ------ p©°prava lok†ln°ch promànnòch

         mov       ss:[bp-2],si             ; adresa definice menu
         mov       ax,word ptr ds:[si+MnuPoz] ; poá†teán° pozice a ©†dek
         inc       ah                       ; druhò ©†dek
         mov       ss:[bp-4],ax             ; poá†teán° pozice a ©†dek
         mov       ax,ds:[DiskNum]          ; poáet diskñ
         inc       ax                       ; váetnà historie
         mov       ss:[bp-10],ax            ; poáet diskñ

         mov       al,ds:[si+DMnuPol]       ; poáet poloëek na ©†dek
         mov       ss:[bp-16],al            ; poáet diskñ na ©†dek
         mov       ah,0
         shl       ax,1
         shl       ax,1
         shl       ax,1                     ; * 8 = celkov† ®°©ka okÇnek s disky
         dec       ax                       ; korekce - bez posledn° mezery
         shr       cx,1                     ; ®°©ka okna
         sub       cl,al                    ; zbytek na okraje
         shr       cx,1                     ; levò okraj
         dec       cx                       ; odeáten° r†mu
         mov       ss:[bp-7],cl             ; levò okraj
         adc       cl,0                     ; lich† mezera vpravo
         mov       ss:[bp-8],cl             ; pravò okraj
         mov       word ptr ss:[bp-14],offset DiskITab ; tabulka definic diskñ
         mov       byte ptr ss:[bp-12],0    ; ukazatel á°sla disku
         mov       al,byte ptr ds:[si+MnuAkt]        ; aktivn° poloëka
         mov       ss:[bp-15],al            ; aktivn° poloëka
         mov       ah,0
         mov       al,ds:[si+MnuLev]        ; vòstupn° hladina k zobrazen°
         mov       ss:[bp-18],ax            ; vòstupn° hladina k zobrazen° textu

; ------ zobrazen° textu vòzvy a oddàlovac° á†ry

         mov       si,ds:[si+MnuPol]        ; text nadpisu
         mov       cl,ss:[bp-6]             ; ®°©ka okna
         mov       dx,ss:[bp-4]             ; pozice a ©†dek
         call      far ptr DispTxtM         ; zobrazen° pr†zdnÇho ©†dku
         inc       dh                       ; zvò®en° ukazatele ©†dku
         call      far ptr DispCarM         ; zobrazen° pr†zdnÇho ©†dku
         inc       dh                       ; zvò®en° ukazatele ©†dku
         mov       ss:[bp-3],dh             ; novò ©†dek

; ------ p©°prava pro dek¢dov†n°

         mov       byte ptr ss:[bp-11],0    ; á°taá ©†dkñ
         push      ss
         pop       es                       ; ES <- segment v z†sobn°ku
DispDMn2:mov       di,sp                    ; buffet v z†sobn°ku
         cld

; ------ levò okraj

         mov       ah,ds:[ColMnu1R]         ; bàën† barva textu
         mov       al,"≥"                   ; "≥"
         stosw                              ; levò okraj

; ------ lev† mezera

         mov       ah,ds:[ColMnu1]
         mov       al," "
         mov       cl,ss:[bp-7]             ; levò okraj
         mov       ch,0
         rep       stosw                    ; dek¢dov†n° levÇ mezery

; ------ p©°prava k dek¢dov†n° poloëek

         mov       bx,ss:[bp-14]            ; adresa v definián° tabulce diskñ
         mov       dl,ss:[bp-12]            ; á°slo disku
         mov       ch,ss:[bp-15]            ; aktivn° poloëka
         mov       cl,ss:[bp-16]            ; poáet poloëek na ©†dek

; ------ nalezen° dal®°ho platnÇho disku

DispDMn3:cmp       dl,DiskMax               ; platnÇ á°slo disku ?
         ja        DispDM32                 ; neplatnò disk
         mov       si,offset DiskPicH       ; disk historie
         je        DispDM42                 ; je historie
         cmp       byte ptr ds:[bx],0       ; je to platnò disk ?
         jne       DispDMn4                 ; je to platnò disk
         inc       bx                       ; adresa dal®°ho disku
         inc       dx                       ; zvò®en° á°sla disku
         jmp       short DispDMn3           ; test dal®°ho disku

; ------ mezera pro neplatnò disk

DispDM32:push      cx
         mov       al," "                   ; mezera k vymaz†n°
         mov       ah,ds:[ColMnu1]
         mov       cx,7                     ; ®°©ka okÇnka
         rep       stosw
         pop       cx
         jmp       short DispDMn6

; ------ adresa obr†zku poloëky

DispDMn4:mov       si,offset DiskPic - 7*3  ; definice obr†zkñ
         mov       al,7*3                   ; poáet bajtñ na obr†zek
         mov       ah,ds:[bx]
         and       ah,bit0+bit1+bit2        ; typ disku
         mul       ah                       ; vòpoáet offsetu v tabulce
         add       si,ax                    ; adresa definice obr†zku
DispDM42:mov       al,7                     ; ®°©ka okÇnka disku
         mul       byte ptr ss:[bp-11]      ; korekce pro dal®° ©†dky
         add       si,ax                    ; adresa linky

; ------ p©°prava barvy poloëky

         mov       ah,ds:[ColMnu1]          ; bàën† barva
         mov       dh,ds:[ColMnu2]          ; vysv°cen† barva
         dec       ch                       ; á°taá aktivn° poloëky
         jnz       DispDM44                 ; nen° aktivn° poloëka
         mov       ah,ds:[ColMnu3]          ; bàën† barva kurzoru
         mov       dh,ds:[ColMnu4]          ; vysv°cen† barva kurzoru

; ------ p©enesen° ©†dku jednoho obr†zku

DispDM44:push      cx
         mov       cx,7                     ; ®°©ka okÇnka
DispDMn5:lodsb
         stosw
         loop      DispDMn5
         pop       cx

; ------ v prost©edn°m ©†dku oznaáen° disku

         cmp       byte ptr ss:[bp-11],1    ; je prost©edn° ©†dek ?
         jne       DispDMn6                 ; nen° prost©edn° ©†dek
         mov       ah,dh                    ; zvòraznàn† barva
         mov       al,dl                    ; á°slo disku
         add       al,"A"                   ; korekce na znak ASCII
         cmp       al,"A"+DiskMax
         jb        DispDM52
         mov       al,"\"                   ; historie
DispDM52:mov       es:[di - 2*7 + 2],ax     ; oznaáen° disku

; ------ oddàlovac° mezera mezi poloëkami

DispDMn6:mov       al," "
         mov       ah,ds:[ColMnu1]          ; bàën† barva textu
         stosw                              ; uloëen° oddàlovac° mezery

; ------ p©°prava pro dal®° poloëku

         inc       bx                       ; adresa dal®°ho disku
         inc       dx                       ; zvò®en° á°sla disku
         dec       cl                       ; á°taá poloëek na ©†dku
         jnz       DispDMn3                 ; dal®° poloëka na ©†dku

; ------ prav† mezera

         dec       di
         dec       di                       ; zru®en° posledn° oddàlovac° mezery
         mov       al," "
         mov       ah,ds:[ColMnu1]          ; bàën† barva
         mov       cl,ss:[bp-8]             ; pravò okraj
         mov       ch,0
         rep       stosw                    ; uloëen° zbylòch mezer

; ------ pravò okraj

         mov       ah,ds:[ColMnu1L]
         mov       al,"≥"                   ; "≥" pravò okraj
         stosw

; ------ zobrazen° jednoho ©†dku

         mov       si,sp                    ; dek¢dovanò ©†dek v z†sobn°ku
         push      dx                       ; ukazatel á°sla disku
         mov       cl,ss:[bp-6]             ; ®°©ka okna
         mov       dx,ss:[bp-4]             ; pozice a ©†dek
         mov       ax,ss:[bp-18]            ; vòstupn° hladina k zobrazen°
         call      far ptr DispKStr         ; zobrazen° ©†dku okna
         pop       dx
         inc       byte ptr ss:[bp-3]       ; zvò®en° ukazatele ©†dkñ

; ------ p©°prava pro dal®° ©†dek na obrazovce

         inc       byte ptr ss:[bp-11]      ; á°taá ©†dkñ
         cmp       byte ptr ss:[bp-11],3    ; byly jië 3 ©†dky ?
         jb        DispDMn7                 ; nebyly je®tà 3 ©†dky

; ------ posun na dal®° ©†dek poloëek

         mov       byte ptr ss:[bp-11],0    ; novò á°taá ©†dkñ
         mov       ss:[bp-14],bx            ; nov† adresa v tabulce
         mov       ss:[bp-12],dl            ; novÇ á°slo disku
         mov       ah,0
         mov       al,ss:[bp-16]            ; poáet poloëek na ©†dek
         sub       byte ptr ss:[bp-15],al   ; nov† aktivn° poloëka
         sub       word ptr ss:[bp-10],ax   ; á°taá diskñ
         jbe       DispDMn9                 ; nejsou dal®° disky

DispDMn7:jmp       DispDMn2                 ; dal®° ©†dek

; ------ n†vrat registrñ

DispDMn9:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispDMnu ENDP

CodeMnu  ENDS

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;
;                                 Data
;
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
Data     SEGMENT

LinMenTE label     dword                    ; univerz†ln° tabulka adres skokñ
         REPT      10
         dd        Lin0MenR
         ENDM

LinMenTM label     word                     ; univerz†ln° tabulka podmenu
         REPT      2*20
         dw        0
         ENDM

MenuHlP1 db        15,'P©eru®en° volby'     ; univerz†ln° n†povàda - p©eru®en° 1
MenuHlP2 db        17,'P©eru®en° operace'   ; univerz†ln° n†povàda - p©eru®en° 2

; -----------------------------------------------------------------------------
;        menu volby disku
; -----------------------------------------------------------------------------

DiskMnu  db        4                        ; typ menu - volba disku

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        1                        ; poáet platnòch poloëek menu
         dw        1                        ; celkovò poáet poloëek menu

         dw        DiskMPlL                 ; zaá†tek definice poloëek menu
         dw        DiskMHlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@VolbaDisku           ; á°slo str†nky velkÇ n†povàdy
         dw        0                        ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        DiskMTit                 ; adresa titulu okna
         dw        0                        ; adresa tabulky obsluh (nen°)
         dw        0                        ; adresa tabulky podmenu (nen°)
         dd        0                        ; £schova n†vratovÇ adresy (nen°)

         db        18                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        43                       ; ®°©ka okna
         db        6                        ; vò®ka okna

         db        5                        ; poáet poloëek na ©†dek
         db        2                        ; poáet ©†dkñ s poloëkami

DiskMPlL db        bit6,34,'Novò aktivn° disk pro ',0,'levÇ',0,' okno:'
DiskMPlR db        bit6,35,'Novò aktivn° disk pro ',0,'pravÇ',0,' okno:'

DiskMTit db        4,'disk'

HelpS    SEGMENT   BYTE PUBLIC
DiskMHlp db        74,'Zvolte novò disk a stisknàte Enter (\ nebo /=historie, jako Alt-\)'
HelpS    ENDS

DiskPic  db        '⁄ƒƒƒƒƒø'                ; disketa
         db        '≥  o  ≥'
         db        '¿ƒƒ¡ƒƒŸ'
         db        '⁄ƒƒƒƒƒø'                ; pevnò disk
         db        '≥ ÕÕÕÕ≥'
         db        '¿ƒƒƒƒƒŸ'
         db        '⁄ƒƒƒƒƒø'                ; RAM disk
         db        '≥ ∞∞∞∞≥'
         db        '¿¬¬¬¬¬Ÿ'
         db        '⁄ƒƒƒƒø '                ; linka (s°üovò disk)
         db        '≥  >>≈>'
         db        '¿ƒƒƒƒŸ '
         db        '⁄ƒƒƒƒƒø'                ; SUBST
         db        '≥ ƒSUB¥'
         db        '¿ƒƒƒƒƒŸ'
         db        '⁄ƒƒƒƒƒø'                ; CD ROM
         db        '≥ ƒƒCD¥'
         db        '¿ƒƒƒƒƒŸ'

DiskPicH db        '⁄ƒƒƒƒƒø'                ; historie
         db        '≥\hist≥'
         db        '¿ƒƒƒƒƒŸ'

; -----------------------------------------------------------------------------
;        editovanò ©†dek ©†dkovÇho menu
; -----------------------------------------------------------------------------

LinParm  db        0                        ; parametry
                                            ;   bit 0: 1=bylo ukonáen° Ctrl-ENTER

; ------ editovanò ©†dek menu (LinTop = -1 = neprov†d° se editace)

LinMax   db        255                      ; maxim†ln° dÇlka ©†dku menu
LinTop   db        0                        ; zobrazenò poá†tek ©†dku menu
LinKur   db        0                        ; kurzor v ©†dku menu
LinRad   db        0                        ; ©†dek na displeji

; ------ zadanò text - zachovat po©ad° !

LinNum   db        0                        ; poáet znakñ v ©†dku menu
LinBuff  label     byte
         db        256 dup(?)               ; ©†dkovò buffer menu

;ColMnu7  db        70h                      ; editovanÇ ©†dky - bàënÇ
;ColMnu8  db        30h                      ; editovanÇ ©†dky - kurzor
;ColMnu9  db        71h                      ; editovanÇ ©†dky - editace
;ColMnuA  db        0eh                      ; p©eteáen° ©†dku (= barva pop©ed°)

; -----------------------------------------------------------------------------
;        definice histori° textovòch parametrñ
; -----------------------------------------------------------------------------

HistSeg  dw        0                        ; á°slo segmentu histori°
HistSPar db        0                        ; parametry segmentu histori°
                                            ;      bit 0: 1=segment modifikov†n

; ------ tabulka maxim†ln°ch velikost° histori° (váetnà z†hlav°)

HistSizT dw        500                      ; 1: historie souborñ
         dw        2000                     ; 2: historie p©°kazñ
         dw        180                      ; 3: historie hled†n° p©i editaci
         dw        100                      ; 4: historie p©ep°naáñ hled†n°
         dw        180                      ; 5: vòbàr souborñ
         dw        1000                     ; 6: historie adres†©ñ (oken)
         dw        100                      ; 7: volba atributñ
         dw        2000                     ; 8: historie koment†©ñ
         dw        100                      ; 9: historie á°sel
         dw        400                      ; 10: historie uëiv. menu

; ------ znaky pro zobrazen° horizont†ln°ch voleb ©†dkovÇho menu

HZnakTab db        '…Õª⁄ƒø'
         db        '∫ ∫≥ ≥'
         db        '»Õº¿ƒŸ'

DosmHist db        12,'$DOSMAN$.HIS'

Data     ENDS

         END

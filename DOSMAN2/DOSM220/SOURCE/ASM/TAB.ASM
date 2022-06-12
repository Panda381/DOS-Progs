
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                             T A B U L K Y
;
;                          tabulkov˜ kalkul tor
;
; Tajn‚ heslo pro p©¡stup k tabulce: SUPERHESLO
; (m–‘e n sledovat v˜choz¡ heslo pro hledan¡)
; =============================================================================
;
; Ve©ejn‚ procedury:
;
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°


INCLUDE  ASM\DEF.ASM

CodeTab  SEGMENT   BYTE PUBLIC
         ASSUME    cs:CodeTab,ds:Data

; *****************************************************************************
;
;                            Tabulky
;
; *****************************************************************************
;þ
Tablk    PROC      FAR

         add       sp,4                     ; zru¨en¡ n vratov‚ adresy
         call      far ptr ClosMnuA         ; uzav©en¡ menu

; ------ volba souboru ze seznamu

TablkF   LABEL     FAR

         mov       si,offset TBMnuSel       ; specifikace menu v˜bˆru
         call      FileSel                  ; v˜bˆr souboru
         jnc       Tablk1                   ; byl zvolen nˆjak˜ soubor
         jmp       far ptr Main0            ; konec z pisn¡ku

; ------ obsluha tabulky

Tablk1:  push      ds
         pop       es                       ; ES <- datov˜ segment
         mov       di,offset TablPath       ; jm‚no souboru TAB
         mov       cx,ds:[TablPthN]         ; d‚lka jm‚na souboru
         call      far ptr ViewTBL          ; obsluha prohl¡‘e‡e TAB

; ------ zru¨en¡ jm‚na souboru z cesty

         mov       si,offset TBMnuSel       ; specifikace menu v˜bˆru
         call      far ptr SubFSel          ; odstranˆn¡ jm‚na souboru
         jmp       short TablkF

Tablk    ENDP

TablADR  dd        0                        ; adresa jm‚na souboru
TablADRN dw        0                        ; d‚lka jm‚na souboru

; -----------------------------------------------------------------------------
;      obsluha prohl¡‘e‡e TAB (soubor ES:DI, d‚lka CX) (ni‡¡ v¨echny registry !)
; -----------------------------------------------------------------------------

ViewTBL  PROC      FAR

; ------ £schova adresy jm‚na tabulky

         mov       word ptr cs:[TablADR],di
         mov       word ptr cs:[TablADR+2],es
         mov       cs:[TablADRN],cx

; ------ otev©en¡ souboru TBL (adresa ES:DI, d‚lka CX)

         mov       si,offset TBLMnu         ; menu editoru
         call      far ptr OpenTBL          ; otev©en¡ souboru datab ze
         jnc       ViewTBL1                 ; operace OK
         ret                                ; n vrat p©i chybˆ

; ------ otev©en¡ okna editoru TBL

ViewTBL1:call      TBLAdrES                 ; aktualizace adresy okna -> ES
         mov       si,offset TBLMnu         ; menu tabulky
         call      far ptr OpenMnu          ; otev©en¡ okna menu
         call      TBLIni                   ; inicializace kurzoru a po‡ tku

; ------ p©epo‡et tabulky (pokud byly extern¡ bu¤ky)

         call      EdTBPrp0                 ; p©epo‡et tabulky

; ------ zobrazen¡ okna

ViewTBL2:
;þ !!!!!!!!!!!!
         call      OpenVerf                 ; ovˆ©en¡ struktury
         jc        ViewTBL4                 ; p©eru¨en¡
;þ !!!!!!!!!!!!

         and       byte ptr ds:[ParMenu],not bit5 ; nulov n¡ automat. vyno©en¡
         call      far ptr NulBreak         ; nulov n¡ p©¡znaku p©eru¨en¡
         call      far ptr VypKrit          ; vypnut¡ kritick‚ sekce
         call      far ptr DispMnu          ; zobrazen¡ okna

; ------ vstup znaku z kl vesnice -> BX (pozor - kalkula‡ka posouv  segmenty !)

         call      far ptr InpChar          ; vstup znaku z kl vesnice -> BX
;         jc        ViewTBL5                 ; je ESC

         call      TBLAdrES                 ; aktualizace adresy okna -> ES

         push      di
         mov       di,offset TBLMnHM0       ; je formul ©
         test      byte ptr es:[TBLIParm],bit7 ; je formul © ?
         jnz       ViewTBL3                 ; je formul ©
         mov       di,offset TBLMnHM1       ; nen¡ formul ©
ViewTBL3:call      far ptr MenKlHlp         ; obsluha kl vesov‚ho menu mal‚ n povˆdy
         pop       di
         cmp       bl,ESCP
         je        ViewTBL5                 ; p©eru¨en¡ operace ESC

         call      far ptr EdTBLMnu         ; obsluha menu
         jmp       short ViewTBL2

ViewTBL4:jmp       short ViewTBL7

; ------ ESC: ukon‡en¡ operace s blokem

ViewTBL5:test      byte ptr ds:[TBLTParm],bit5 ; je ji‘ ozna‡ov n¡ bloku ?
         jz        ViewTBL6                 ; nen¡ ozna‡ov n¡ bloku

         test      byte ptr ds:[TBLTParm],bit3 ; je ji‘ konec bloku ozna‡en ?
         jz        ViewTB54                 ; nen¡ konec bloku
         and       byte ptr ds:[TBLTParm],not bit3 ; nen¡ konec bloku
         mov       ax,ds:[TBBlokCE]         ; sloupec konce bloku
         or        ax,ds:[TBBlokRE]         ; + © dek konce bloku
         mov       es:[TBLKurz],ax          ; nov˜ kurzor
         jmp       short ViewTBL2

ViewTB54:call      far ptr TDIniBlk         ; konec operace s blokem
ViewTB56:jmp       short ViewTBL2

; ------ test, zda byla tabulka modifikov na

ViewTBL6:test      byte ptr es:[TBLParm],bit0 ; byla tabulka modifikov na ?
         jz        ViewTBL7                 ; nebyla modifikov na
         test      byte ptr es:[TBLIParm],bit7 ; je formul © ?
         jnz       ViewTBL7                 ; pro formul © se nept 
         push      si
         mov       si,offset TBSMnLin
         call      far ptr Lin0MenF         ; dotaz, zda se m  ulo‘it
         pop       si
         jc        ViewTB56                 ; n vrat k editaci
         dec       bx                       ; je ulo‘en¡ ?
         jnz       ViewTBL7                 ; nen¡ ulo‘en¡

; ------ ulo‘en¡ na disk a konec

         call      EdTBUloz                 ; ulo‘en¡ souboru na disk
         jc        ViewTB56                 ; p©eru¨en¡ operace

; ------ ESC: uzav©en¡ okna editoru

ViewTBL7:call      far ptr ClosMnu          ; uzav©en¡ okna

; ------ uzav©en¡ tabulky

         mov       si,offset TBLMnu         ; specifikace menu v˜bˆru
         call      far ptr ClosTBL          ; uzav©en¡ tabulky
         ret

ViewTBL  ENDP

; *****************************************************************************
;                        otev©en¡ segmentu tabulky
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa definice menu
;        ES:DI=jm‚no souboru DBF (pozor - nesm¡ b˜t ovlivnˆno posouv n¡m blok–)
;        CX=d‚lka jm‚na souboru DBF (max. 86 znak– !)
; VSTUP: CY=nedostatek pamˆti, soubor nenalezen nebo m  chybnou strukturu
; *****************************************************************************
;þ
OpenTBL  PROC      FAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,sp

         and       byte ptr ds:[TBLTPrm2],not bit1 ; nen¡ pot©ebn˜ p©epo‡et

; ------ vytvo©en¡ segmentu

         mov       bx,TblDat+1000           ; asi tak minim ln¡ velikost
         call      far ptr CreatDat         ; vytvo©en¡ bufferu
         jnc       OpenTBL1                 ; je to OK
         jmp       OpenTBL9                 ; chyba
OpenTBL1:mov       ds:[si+TbMnuSeg],ax      ; £schova ‡¡sla segmentu

; ------ adresa datov‚ho bloku -> ES

         call      TBLAdrES                 ; aktualizace adresy okna -> ES

; ------ inicializace parametr– bufferu (BX=velikost segmentu)

         xor       di,di
         mov       cx,bx                    ; CX <- velikost bufferu
         xor       ax,ax                    ; AX <- 0
         cld
         rep       stosb                    ; vynulov n¡ bufferu
         mov       es:[0],bx                ; velikost dat v bufferu

         mov       al,ds:[OddelDes]         ; oddˆlova‡ desetin
         mov       es:[TBLICDes],al         ; oddˆlova‡ desetin
         mov       al,ds:[OddelRad]         ; oddˆlova‡ © d–
         mov       es:[TBLICRad],al         ; oddˆlova‡ © d–
         mov       al,ds:[OddelPol]         ; oddˆlova‡ polo‘ek
         mov       es:[TBLICDat],al         ; pou‘it˜ oddˆlova‡ dat

         mov       byte ptr es:[TBLINumN],5 ; po‡et slov na celou ‡ st ‡¡sla
         mov       byte ptr es:[TBLINumD],5 ; po‡et slov na desetinnou ‡ st

         mov       al,ds:[CodePagK]         ; k¢dov  str nka
         cmp       al,0
         jne       OpnTBL12
         inc       ax                       ; implicitnˆ Kamenick˜ch
OpnTBL12:add       al,bit4+bit6-1           ; p©ep¡na‡e tabulky
         mov       byte ptr es:[TblIParm],al ; p©ep¡na‡e tabulky
         mov       word ptr es:[TBLEditO],-4*TBLNasR ; star  bu¤ka neplat¡

; ------ inicializace tabulky ¨¡©ek sloupc–

         mov       di,TblSirTb              ; tabulka ¨¡©ek sloupc–
         mov       cl,TBLMaxC+1             ; po‡et sloupc–
         mov       al,10                    ; inicializa‡n¡ ¨¡©ka sloupce
         rep       stosb                    ; inicializace tabulky ¨¡©ek

; ------ inicializace tabulky desetinn˜ch m¡st

         mov       al,2                     ; inicializa‡n¡ po‡et m¡st
         mov       cl,TBLMaxC+1             ; po‡et sloupc–
         rep       stosb                    ; inicializace tabulky des. m¡st

         mov       word ptr es:[TblIdnt],"BT" ; identifikace
         mov       word ptr es:[TblIdnt+2],"1L" ; identifikace

; ------ jm‚no aktivn¡ho souboru

         push      si

         mov       bx,8                     ; d‚lka bufferu
         mov       si,offset SRSMnPl4+1     ; buffer jm‚na souboru
         mov       ch,0
         mov       cl,ds:[si-1]             ; d‚lka jm‚na souboru
         sub       bx,cx                    ; zbytek bufferu
         cld
         mov       di,TBLName               ; jm‚no souboru
         rep       movsb                    ; p©enos jm‚na souboru
         mov       cl,bl                    ; CL <- zbytek bufferu
         mov       al," "
         rep       stosb                    ; vymaz n¡ zbytku bufferu

; ------ koment © souboru

         mov       si,offset LinBuff        ; buffer s koment ©em
         mov       cl,ds:[si-1]             ; d‚lka textu koment ©e
         mov       es:[TBLNKom],cx          ; d‚lka textu koment ©e
         mov       di,TBLKom                ; buffer koment ©e
         rep       movsb                    ; p©enos koment ©e

         pop       si

; ------ na‡ten¡ souboru do pamˆti

         push      si

         push      es
         les       si,cs:[TablAdr]          ; adresa jm‚na tabulky
         call      far ptr OpenR            ; otev©en¡ souboru pro ‡ten¡
         jnc       OpnTBL16                 ; soubor otev©en OK
         call      far ptr CreatFil         ; vytvo©en¡ souboru tabulky
         jc        OpnTBL16                 ; chyba
         call      far ptr ModiWDir         ; aktualizace okna
         clc                                ; p©¡znak operace OK
OpnTBL16:pop       es
         jc        OpenTBL3

         mov       di,TblTabul
         mov       cx,es:[0]
         sub       cx,di
         call      far ptr ReadFile         ; na‡ten¡ souboru do pamˆti

         pushf
         add       di,cx                    ; konec dat
         cmp       di,TblDat                ; bylo na‡teno m‚nˆ dat ?
         jae       OpenTBL2
         mov       di,TBLDat                ; minim lnˆ na‡teno dat
OpenTBL2:call      far ptr ClosFile         ; uzav©en¡ souboru
         popf

OpenTBL3:pop       si
         jc        OpnTBL31                 ; chyba na‡ten¡ souboru

; ------ ovˆ©en¡ identifikace souboru (nekontroluje se ‡¡slo verze)

         cmp       word ptr es:[TblIdnt],"BT" ; identifikace ?
         jne       OpnTBL31
         cmp       byte ptr es:[TblIdnt+2],"L" ; identifikace
         je        OpnTBL32

; ------ zru¨en¡ segmentu tabulky p©i chybˆ

OpnTBL31:call      far ptr ClosTBL          ; uzav©en¡ segmentu tabulky
         stc                                ; p©¡znak chyby
         jmp       OpenTBL9                 ; nespr vn˜ soubor

; ------ zmen¨en¡ bufferu na minimum (DI=konec dat)

OpnTBL32:mov       cx,es:[0]                ; velikost dat
         sub       cx,di                    ; po‡et bajt– ke zru¨en¡
         mov       ax,ds:[si+TbMnuSeg]      ; segment
         call      far ptr DelDat           ; zru¨en¡ dat

; ------ zad n¡ hesla, je-li soubor zak¢dov n

         test      byte ptr es:[TblIParm],bit3 ; soubor uzam‡en heslem ?
         jnz       OpnTBL36
         jmp       OpnTBL38                 ; nen¡ uzam‡en
OpnTBL36:call      EdTBHesl                 ; zad n¡ hesla
         jc        OpnTBL31                 ; p©eru¨en¡ operace
         call      TBLDekod                 ; odk¢dov n¡ struktury
         call      OpenVerf                 ; ovˆ©en¡ struktury souboru
         jnc       OpnTB371                 ; struktura je OK
         call      TBLZakod                 ; zak¢dov n¡ struktury zpˆt

; ------ test "SUPERHESLO"

         cmp       byte ptr es:[TBLHeslN],offset(SuperTb0-SuperTab)
         jb        OpnTBL36
         mov       di,TBLHeslo              ; zadan‚ heslo
         mov       bx,offset SuperTab-1
         mov       cx,offset(SuperTb0-SuperTab)
         cld
OpnTB362:inc       bx
         mov       al,cs:[bx]
         add       al,"A"
         scasb
         loope     OpnTB362
         jne       OpnTBL36

; ------ p©¡sun zbytku textu hesla

         mov       word ptr ds:[SuperHl0+2],es ; segment textu
         sub       byte ptr es:[TBLHeslN],offset(SuperTb0-SuperTab)
         je        OpnT3712
         push      si
         mov       cl,es:[TBLHeslN]
         mov       si,di
         mov       di,TBLHeslo
         rep       movs byte ptr es:[di],es:[si]
         pop       si

; ------ p©¡prava k vyhled n¡ hesla

OpnTBL37:call      far ptr TestBEsc         ; je p©eru¨en¡ operace ?
         jc        OpnTB375                 ; je p©eru¨en¡ operace

         call      far ptr TestTDis         ; test ‡asovan‚ho zobrazen¡
         jc        OpnTB370                 ; nen¡ pot©eba zobrazen¡

         push      si
         mov       si,offset SuperHls
         call      far ptr InfDisp0         ; zobrazen¡ hl ¨en¡ o operaci
         call      far ptr InfoClos         ; uzav©en¡ informa‡n¡ho © dku
         pop       si

OpnTB370:call      TBLQDek                  ; rychl‚ dek¢dovac¡ ovˆ©en¡
         jc        OpnT3712                 ; nespr vn‚ heslo

         call      TBLDekod                 ; odk¢dov n¡ struktury
         call      OpenVerf                 ; ovˆ©en¡ struktury souboru
OpnTB371:jnc       OpnTBL39                 ; struktura je OK
         call      TBLZakod                 ; zak¢dov n¡ struktury zpˆt

OpnT3712:mov       di,TBLHeslo
         xor       bx,bx
         jmp       short OpnT3732

OpnTB372:inc       byte ptr es:[di+bx]
         cmp       byte ptr es:[di+bx]," "+1
         jne       OpTB3722
         mov       byte ptr es:[di+bx],"0"
OpTB3722:cmp       byte ptr es:[di+bx],"9"+1
         jne       OpnTB373
         mov       byte ptr es:[di+bx],"A"
OpnTB373:cmp       byte ptr es:[di+bx],"Z"
         jbe       OpnTBL37
         mov       byte ptr es:[di+bx]," "
         inc       bx
         cmp       bl,TBLMaxHs              ; maxim ln¡ d‚lka textu
         jae       OpnTB375                 ; p©ete‡en¡
OpnT3732:cmp       bl,es:[TBLHeslN]         ; je to platn˜ znak ?
         jb        OpnTB372                 ; je to je¨tˆ platn˜ znak
         mov       byte ptr es:[di+bx],"0"-1
         inc       byte ptr es:[TBLHeslN]   ; zv˜¨en¡ ‡¡ta‡e znak–
         jmp       short OpnTB372

OpnTB375:jmp       OpnTBL36

; ------ inicializace a ovˆ©en¡ struktury souboru

OpnTBL38:call      OpenVerf                 ; ovˆ©en¡ struktury souboru
         jnc       OpnTBL39
         jmp       OpnTBL31                 ; chybn  struktura souboru

; ------ p©ek¢dov n¡ znak– oddˆlova‡–

OpnTBL39:mov       bl,es:[TBLICDes]         ; star˜ oddˆlova‡ desetin
         mov       bh,es:[TBLICRad]         ; star˜ oddˆlova‡ © d–
         mov       dl,es:[TBLICDat]         ; star˜ oddˆlova‡ dat
         mov       al,ds:[OddelDes]         ; nov˜ oddˆlova‡ desetin
         mov       ah,ds:[OddelRad]         ; nov˜ oddˆlova‡ © d–
         mov       dh,ds:[OddelPol]         ; nov˜ oddˆlova‡ dat
         mov       es:[TBLICDes],al         ; nov˜ oddˆlova‡ desetin
         mov       es:[TBLICRad],ah         ; nov˜ oddˆlova‡ © d–
         mov       es:[TBLICDat],dh         ; nov˜ oddˆlova‡ dat

         mov       di,TblDat                ; ukazatel adresy bunˆk
         mov       cx,es:[TBLBunN]          ; po‡et bunˆk tabulky
         jcxz      OpnTBL3A                 ; nen¡ ‘ dn  bu¤ka

         push      di
         push      cx
OpnTB392:test      byte ptr es:[di+TblXParm],bit2 ; je to v˜raz ?
         jz        OpnTB398                 ; nen¡ to v˜raz

         push      cx
         push      di

         mov       cx,es:[di+TblXOffs]      ; offset dal¨¡ bu¤ky
         add       di,ds:[TBLXText]         ; za‡ tek textu bu¤ky
         sub       cx,ds:[TBLXText]         ; d‚lka textu
         jbe       OpnTB397                 ; nen¡ text
OpnTB393:cmp       cl,2
         jb        OpTB3941
         cmp       word ptr es:[di],".."
         jne       OpTB3941
         inc       di
         dec       cx
         jmp       short OpnTB396

OpTB3941:cmp       bl,es:[di]               ; je oddˆlova‡ desetin ?
         jne       OpTB3942                 ; nen¡ oddˆlova‡ desetin
         mov       es:[di],al               ; n hrada nov˜m oddˆlova‡em
         jmp       short OpnTB396

OpTB3942:cmp       bh,es:[di]               ; je oddˆlova‡ © d– ?
         jne       OpTB3943                 ; nen¡ oddˆlova‡ © d–
         mov       es:[di],ah               ; n hrada nov˜m oddˆlova‡em
         jmp       short OpnTB396

OpTB3943:cmp       dl,es:[di]               ; je oddˆlova‡ dat ?
         jne       OpTB3944                 ; nen¡ oddˆlova‡ dat
         mov       es:[di],dh               ; n hrada nov˜m oddˆlova‡em
         jmp       short OpnTB396

OpTB3944:cmp       byte ptr es:[di],'"'     ; je textov‚ ‡¡slo ?
         jne       OpnTB396                 ; nen¡ textov‚ ‡¡slo

OpTB3945:inc       di                       ; zv˜¨en¡ ukazatele textu
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e znak–
         jcxz      OpnTB397                 ; nen¡ dal¨¡ znak
         cmp       byte ptr es:[di],'"'     ; je konec textov‚ho ‡¡sla ?
         jne       OpTB3945                 ; dal¨¡ znak

OpnTB396:inc       di                       ; zv˜¨en¡ ukazatele textu
         loop      OpnTB393                 ; dal¨¡ znak

OpnTB397:pop       di
         pop       cx

OpnTB398:add       di,es:[di+TblXOffs]      ; adresa dal¨¡ bu¤ky
         loop      OpnTB392                 ; dal¨¡ bu¤ka

         pop       cx
         pop       di

; ------ konverze n rodn¡ch font–

OpnTBL3A:jcxz      OpenTBL6                 ; nen¡ ‘ dn  bu¤ka

         mov       al,es:[TblIParm]         ; p–vodn¡ parametry
         mov       dx,bit3 + bit2*HI        ; zmˆna z Latin2 na Kamenick˜ch
         and       byte ptr es:[TblIParm],not bit0+bit1 ; k¢d Kamenick˜ch
         cmp       byte ptr ds:[CodePagK],2 ; je Latin 2 ?
         jne       OpnTB3A1                 ; nen¡ Latin 2
         inc       byte ptr es:[TblIParm]   ; je k¢d Latin 2
         xchg      dl,dh                    ; oprava smˆru konverze
OpnTB3A1:cmp       al,es:[TblIParm]         ; je zmˆna k¢du ?
         je        OpenTBL4                 ; nen¡ zmˆna k¢du

         or        byte ptr ds:[TBLTPrm2],bit1 ; po‘adavek p©epo‡tu tabulky

         push      cx
         mov       si,di                    ; SI <- ukazatel dat
OpnTB3A2:test      byte ptr es:[si+TblXParm],bit0+bit2 ; je to text/v˜raz ?
         jz        OpnTB3A6                 ; nen¡ to text/v˜raz

         push      si
         push      cx
         mov       cx,es:[si+TblXOffs]      ; offset dal¨¡ bu¤ky
         sub       cx,ds:[TBLXText]         ; d‚lka textu ke konverzi
         add       si,ds:[TBLXText]         ; za‡ tek textu
         call      far ptr KonvFnt          ; konverze font–
         pop       cx
         pop       si

OpnTB3A6:add       si,es:[si+TblXOffs]      ; adresa dal¨¡ bu¤ky
         loop      OpnTB3A2                 ; dal¨¡ bu¤ka
         pop       cx

; ------ na‡ten¡ extern¡ch bunˆk (operaci lze p©eru¨it ESC, tabulka se vyvol )

OpenTBL4:test      byte ptr es:[di+TblXParm],bit3 ; je to extern¡ bu¤ka ?
         jz        OpenTBL5                 ; nen¡ extern¡ bu¤ka
         call      far ptr TestBEsc         ; je p©eru¨en¡ operace ?
         jc        OpenTBL6                 ; je p©eru¨en¡ operace
         call      TBExtern                 ; na‡ten¡ extern¡ bu¤ky
         or        byte ptr ds:[TBLTPrm2],bit1 ; po‘adavek p©epo‡tu tabulky
OpenTBL5:add       di,es:[di+TblXOffs]      ; adresa dal¨¡ bu¤ky
         loop      OpenTBL4                 ; dal¨¡ bu¤ka
OpenTBL6:clc

; ------ n vrat registr–

OpenTBL9:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

OpenTBL  ENDP

SuperTab db        "S"-"A"                  ; tabulka superhesla
         db        "U"-"A"
         db        "P"-"A"
         db        "E"-"A"
         db        "R"-"A"
         db        "H"-"A"
         db        "E"-"A"
         db        "S"-"A"
         db        "L"-"A"
         db        "O"-"A"
SuperTb0 label     byte

; -----------------------------------------------------------------------------
;        rychl‚ dek¢dovac¡ ovˆ©en¡ hesla (okno ES)
; -----------------------------------------------------------------------------

TBLQDek  PROC      NEAR

         push      bp

; ------ p©¡prava k dek¢dov n¡ dat

         mov       di,TblIParm+1            ; za‡ tek dat k zak¢dov n¡
         xor       bx,bx                    ; offset v heslu
         xor       dx,dx                    ; st©ada‡ k¢dovac¡ho kl¡‡e
         mov       ch,0
         mov       ah,0                     ; ‡¡ta‡ odk¢dovan˜ch dat

; ------ p©esko‡en¡ parametr– 2, p©esko‡en¡ 3 znak– oddˆlova‡–

         call      TBLDekd0                 ; dek¢dov n¡ jednoho bajtu
         call      TBLDekd0                 ; dek¢dov n¡ jednoho bajtu
         call      TBLDekd0                 ; dek¢dov n¡ jednoho bajtu
         call      TBLDekd0                 ; dek¢dov n¡ jednoho bajtu

; ------ kontrola slov na celou ‡ st ‡¡sla

         call      TBLDekd0                 ; dek¢dov n¡ jednoho bajtu
         cmp       al,2
         jb        TBLQDek7                 ; chyba
         cmp       al,50
         ja        TBLQDek7                 ; chyba

; ------ kontrola slov na desetinnou ‡ st ‡¡sla

         call      TBLDekd0                 ; dek¢dov n¡ jednoho bajtu
         cmp       al,2
         jb        TBLQDek7                 ; chyba
         cmp       al,50
         ja        TBLQDek7                 ; chyba

; ------ p©esko‡en¡ nekontrolovateln˜ch dat

         mov       bp,6
TBLQDek2:call      TBLDekd0                 ; dek¢dov n¡ jednoho bajtu
         dec       bp
         jnz       TBLQDek2

; ------ kontrola ¨¡©ek sloupc–

         mov       bp,TBLMaxC+1
TBLQDek3:call      TBLDekd0                 ; dek¢dov n¡ jednoho bajtu
         cmp       al,1
         jb        TBLQDek7                 ; chyba
         cmp       al,80
         ja        TBLQDek7
         dec       bp
         jnz       TBLQDek3

; ------ kontrola desetinn˜ch m¡st

         mov       bp,TBLMaxC+1
TBLQDek4:call      TBLDekd0                 ; dek¢dov n¡ jednoho bajtu
         cmp       al,70
         ja        TBLQDek7
         dec       bp
         jnz       TBLQDek4
         clc
         jmp       short TBLQDek8

; ------ zpˆtn‚ zak¢dov n¡ dat

TBLQDek7:stc                                ; p©¡znak chyby
TBLQDek8:pushf
         mov       di,TblIParm+1            ; za‡ tek dat k zak¢dov n¡
         xor       bx,bx                    ; offset v heslu
         xor       dx,dx                    ; st©ada‡ k¢dovac¡ho kl¡‡e
TBLQDek9:call      TBLZakd0                 ; zpˆtn‚ zak¢dov n¡ bajtu
         jnz       TBLQDek9                 ; dal¨¡ bajt
         popf

         pop       bp
         ret

TBLQDek  ENDP

; -----------------------------------------------------------------------------
;        ovˆ©en¡ struktury souboru ES (+ inicializace parametr–) -> CY=chyba
; -----------------------------------------------------------------------------

OpenVerf PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      di

; ------ inicializace parametr– podle tabulky

         call      InitPTBL                 ; inicializace parametr–

; ------ kontrola z hlav¡ souboru

         mov       ax,es:[TBLINumN]         ; slov na celou ‡ st a desetiny
         cmp       al,1                     ; minim lnˆ slov na cel‚ ‡¡slo
         jb        OpenVer8                 ; chyba
         cmp       al,99                    ; maxim lnˆ slov na cel‚ ‡¡slo
         ja        OpenVer8                 ; chyba
         cmp       ah,1                     ; minim lnˆ slov na desetiny
         jb        OpenVer8                 ; chyba
         cmp       ah,99                    ; maxim lnˆ slov na desetiny
         ja        OpenVer8                 ; chyba

; ------ kontrola tabulky ¨¡©ek sloupc–

         mov       di,TblSirTb              ; tabulka ¨¡©ek sloupc–
         mov       cx,TBLMaxC+1             ; po‡et polo‘ek v tabulce
OpenVer2:cmp       byte ptr es:[di],1       ; minim ln¡ ¨¡©ka
         jb        OpenVer8                 ; chyba
         cmp       byte ptr es:[di],99      ; maxim ln¡ ¨¡©ka
         ja        OpenVer8                 ; chyba
         inc       di
         loop      OpenVer2

; ------ kontrola tabulky desetinn˜ch m¡st (DI=za‡ tek tabulky)

         mov       cl,TBLMaxC+1             ; po‡et polo‘ek v tabulce
OpenVer4:cmp       byte ptr es:[di],99      ; maxim ln¡ ¨¡©ka
         ja        OpenVer8                 ; chyba
         inc       di
         loop      OpenVer4

; ------ kontrola struktury polo‘ek (DI=za‡ tek dat)

         mov       cx,es:[TblBunN]          ; po‡et bunˆk v tabulce
         jcxz      OpenVer7                 ; nen¡ ‘ dn  bu¤ka
OpenVer5:cmp       di,es:[0]                ; je platn  adresa ?
         ja        OpenVer8                 ; nen¡ platn  adresa
         mov       ax,es:[di+TblXOffs]      ; offset dal¨¡ bu¤ky
         sub       ax,ds:[TBLXText]         ; ode‡ten¡ z hlav¡
         jb        OpenVer8                 ; chyba
         cmp       ax,255                   ; maxim ln¡ d‚lka textu
         ja        OpenVer8                 ; chyba
         mov       al,es:[di+TblXParm]      ; parametry
         and       al,bit0+bit1+bit2+bit3   ; typ bu¤ky
         cmp       al,bit0                  ; text
         je        OpenVer6
         cmp       al,bit1                  ; konstanta
         je        OpenVer6
         cmp       al,bit2                  ; v˜raz
         je        OpenVer6
         cmp       al,bit3                  ; extern¡ bu¤ka
         jne       OpenVer8                 ; chyba
OpenVer6:add       di,es:[di+TBLXOffs]      ; adresa dal¨¡ bu¤ky
         jc        OpenVer8                 ; p©ete‡en¡
         loop      OpenVer5                 ; dal¨¡ bu¤ka
OpenVer7:cmp       di,es:[0]                ; souhlas¡ konec dat ?
         je        OpenVer9                 ; data souhlas¡ OK

; ------ n vrat registr–

OpenVer8:stc                                ; p©¡znak chyby struktury
OpenVer9:pop       di
         pop       cx
         pop       ax
         ret

OpenVerf ENDP

; -----------------------------------------------------------------------------
;        zak¢dov n¡ souboru tabulky
; -----------------------------------------------------------------------------

TBLZakod PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      di

; ------ p©¡prava registr–

         mov       di,TblIParm+1            ; za‡ tek dat k zak¢dov n¡
         xor       bx,bx                    ; offset v heslu
         cmp       es:[TBLHeslN],bl         ; je heslo ?
         je        TBLZakd9                 ; nen¡ heslo
         xor       dx,dx                    ; st©ada‡ k¢dovac¡ho kl¡‡e
         mov       ch,0                     ; CH <- 0

; ------ zak¢dov n¡ jednoho bajtu

TBLZakd2:call      TBLZakd0                 ; zak¢dov n¡ jednoho bajtu

; ------ test, zda bude dal¨¡ bajt dat

         cmp       di,es:[0]                ; je dal¨¡ bajt dat ?
         jb        TBLZakd2                 ; je je¨tˆ dal¨¡ bajt

; ------ p©¡znak zak¢dov n¡ souboru

         or        byte ptr es:[TblIParm],bit3 ; p©¡znak uzam‡en¡ souboru heslem

; ------ n vrat registr–

TBLZakd9:pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

TBLZakod ENDP

; -----------------------------------------------------------------------------
;        zak¢dov n¡ jednoho bajtu
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=ukazatel dat
;        BX=offset v heslu
;        CH=0
;        DX=st©ada‡ k¢dovac¡ho kl¡‡e
;        AH=‡¡ta‡ bajt–
; VSTUP: ES:DI=ukazatel dat + 1
;         BX=nov˜ offset v heslu
;         DX=nov˜ st©ada‡ k¢dovac¡ho kl¡‡e
;         AH=‡¡ta‡ bajt– - 1 (ZY=nen¡ dal¨¡ bajt)
; ni‡¡ registry AL a CL !
; -----------------------------------------------------------------------------

TBLZakd0 PROC      NEAR

         mov       al,es:[di]               ; bajt k zak¢dov n¡

         xor       dl,bl                    ; po©adov˜ bajt
         add       dx,"DM"                  ; + konstanta
         mov       cl,es:[bx+TBLHeslo]      ; znak hesla
         sub       dx,cx
         and       cl,bit0+bit1+bit2+bit3   ; rotace
         rol       dx,cl                    ; rotace k¢dovac¡ho kl¡‡e

         ror       al,cl                    ; rotace k¢dovan‚ho bajtu
         xor       al,dl                    ; zak¢dov n¡ bajtu

         cld
         stosb

         inc       bx                       ; zv˜¨en¡ offsetu v heslu
         cmp       bl,es:[TBLHeslN]         ; je dal¨¡ znak hesla ?
         jb        TBLZak02                 ; je je¨tˆ dal¨¡ znak hesla
         xor       bx,bx                    ; offset na za‡ tek hesla
TBLZak02:dec       ah                       ; ‡¡ta‡ bajt–
         ret

TBLZakd0 ENDP

; -----------------------------------------------------------------------------
;        odk¢dov n¡ souboru tabulky
; -----------------------------------------------------------------------------

TBLDekod PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      di

; ------ p©¡znak odemknut¡ souboru

         and       byte ptr es:[TblIParm],not bit3 ; p©¡znak odemknut¡ souboru

; ------ p©¡prava registr–

         mov       di,TblIParm+1            ; za‡ tek dat k zak¢dov n¡
         xor       bx,bx                    ; offset v heslu
         cmp       es:[TBLHeslN],bl         ; je heslo ?
         je        TBLDekd9                 ; nen¡ heslo
         xor       dx,dx                    ; st©ada‡ k¢dovac¡ho kl¡‡e
         mov       ch,0

; ------ zak¢dov n¡ jednoho bajtu

TBLDekd2:call      TBLDekd0                 ; dek¢dov n¡ jednoho bajtu

; ------ test, zda bude dal¨¡ bajt dat

         cmp       di,es:[0]                ; je dal¨¡ bajt dat ?
         jb        TBLDekd2                 ; je je¨tˆ dal¨¡ bajt

; ------ n vrat registr–

TBLDekd9:pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

TBLDekod ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ jednoho bajtu
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=ukazatel dat
;        BX=offset v heslu
;        CH=0
;        DX=st©ada‡ k¢dovac¡ho kl¡‡e
;        AH=‡¡ta‡ bajt–
; VSTUP: ES:DI=ukazatel dat + 1
;         BX=nov˜ offset v heslu
;         DX=nov˜ st©ada‡ k¢dovac¡ho kl¡‡e
;         AH=‡¡ta‡ bajt– + 1
;         AL=dek¢dovan˜ bajt
; ni‡¡ registr CL !
; -----------------------------------------------------------------------------

TBLDekd0 PROC      NEAR

         mov       al,es:[di]               ; bajt k zak¢dov n¡

         xor       dl,bl                    ; po©adov˜ bajt
         add       dx,"DM"                  ; + konstanta
         mov       cl,es:[bx+TBLHeslo]      ; znak hesla
         sub       dx,cx
         and       cl,bit0+bit1+bit2+bit3   ; rotace
         rol       dx,cl                    ; rotace k¢dovac¡ho kl¡‡e

         xor       al,dl                    ; odk¢dov n¡ bajtu
         rol       al,cl                    ; rotace k¢dovan‚ho bajtu

         cld
         stosb

; ------ zv˜¨en¡ ukazatele hesla

         inc       bx                       ; zv˜¨en¡ offsetu v heslu
         cmp       bl,es:[TBLHeslN]         ; je dal¨¡ znak hesla ?
         jb        TBLDkd02                 ; je je¨tˆ dal¨¡ znak hesla
         xor       bx,bx
TBLDkd02:inc       ah                       ; ‡¡ta‡ bajt–
         ret

TBLDekd0 ENDP

; -----------------------------------------------------------------------------
;        zad n¡ hesla p©¡stupu k souboru (okno ES) (CY=p©eru¨en¡, ZY=nen¡ zmˆna)
; -----------------------------------------------------------------------------

EdTBHesl PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di

; ------ p©¡prava p©edvolby

         mov       ah,0
         mov       al,es:[TBLHeslN]         ; d‚lka hesla
         mov       ds:[TBLHesPN],ax         ; d‚lka hesla
         mov       word ptr ds:[TBLHesPA],TBLHeslo ; adresa hesla
         mov       word ptr ds:[TBLHesPA+2],es ; segment hesla

; ------ zad n¡ textu hesla

         mov       si,offset TBLHesMn
         call      far ptr Lin0MenF         ; zad n¡ hesla
         jc        EdTBHes9                 ; p©eru¨en¡ operace

; ------ p©¡prava parametr– textu

         cld
         mov       ah,0                     ; p©¡znak - nen¡ zmˆna
         mov       di,TBLHeslo              ; za‡ tek bufferu hesla
         mov       si,offset LinBuff        ; buffer textu
         mov       ch,0
         mov       cl,ds:[LinNum]           ; po‡et bajt– textu
         cmp       cl,es:[TBLHeslN]         ; je zmˆna d‚lky textu hesla ?
         je        EdTBHes2                 ; nen¡ zmˆna d‚lky textu hesla
         mov       ah,1                     ; p©¡znak zmˆny textu hesla
EdTBHes2:jcxz      EdTBHes7                 ; nen¡ dal¨¡ znak

; ------ p©enesen¡ textu hesla

EdTBHes3:lodsb                              ; na‡ten¡ znaku
         cmp       al,es:[di]               ; je zmˆna textu hesla ?
         je        EdTBHes4                 ; nen¡ zmˆna textu hesla
         mov       ah,1                     ; p©¡znak zmˆny textu hesla
EdTBHes4:call      far ptr UpCase           ; konverze na velk‚ p¡smeno
         cmp       al," "
         je        EdTBHs42                 ; mezera povolena
         cmp       al,"0"
         jb        EdTBHes5                 ; nepovolen˜ znak
         cmp       al,"9"
         jbe       EdTBHs42                 ; ‡¡slice je povolena
         cmp       al,"A"
         jb        EdTBHes5                 ; nepovolen˜ znak
         cmp       al,"Z"
         ja        EdTBHes5                 ; nepovolen˜ znak
EdTBHs42:stosb                              ; ulo‘en¡ znaku
EdTBHes5:loop      EdTBHes3                 ; dal¨¡ znak

; ------ vypu¨tˆn¡ nadbyte‡n˜ch mezer

         inc       di                       ; p©ednastaven¡
EdTBHes6:dec       di
         cmp       di,TBLHeslo              ; je ji‘ za‡ tek bufferu ?
         jbe       EdTBHes7                 ; je ji‘ za‡ tek bufferu
         cmp       byte ptr es:[di-1]," "   ; je na konci mezera ?
         je        EdTBHes6                 ; mezera se vypust¡

; ------ ulo‘en¡ d‚lky zadan‚ho textu hesla

EdTBHes7:sub       di,TBLHeslo              ; d‚lka textu
         mov       cx,di                    ; CX <- d‚lka textu hesla
         mov       es:[TBLHeslN],cl         ; d‚lka textu hesla
         or        ah,ah                    ; byla zmˆna hesla (ZY=nebyla) ?
;         clc

; ------ n vrat registr–

EdTBHes9:pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

EdTBHesl ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ obsahu extern¡ bu¤ky ES:DI
; -----------------------------------------------------------------------------
; lok ln¡ promˆnn‚ pro import extern¡ch bunˆk:
;                   SS:[BP-2] (2) identifik tor souboru   ÄÄÄ¿struktura pou‘ita
;                   SS:[BP-4] (2) adresa okna                ³i p©i importu
;                   SS:[BP-6] (2) adresa bu¤ky               ³ souboru !!!
;                   SS:[BP-8] (2) ukazatel ‡¡sla bu¤ky       ³
;                   SS:[BP-10] (2) po‡et bajt– v bufferu     ³
;                   SS:[BP-12] (2) offset adresy v bufferu   ³
;                   SS:[BP-14] (2) adresa za‡ tku bufferu    ÀÄÄÄÄ¿
;                   SS:[BP-15] (1) po‡et slov na celou ‡ st ‡¡sla ³
;                   SS:[BP-16] (1) po‡et slov na desetinnou ‡ st  ³
;                              (256) vstupn¡ buffer      ÄÄÄÄÄÄÄÄÄÙ
; -----------------------------------------------------------------------------
;þ
TBExtern PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,sp

; ------ p©¡prava lok ln¡ch promˆnn˜ch

         sub       sp,16+256
         mov       ss:[bp-4],es             ; adresa okna
         mov       ss:[bp-6],di             ; adresa bu¤ky
         mov       word ptr ss:[bp-10],0    ; v bufferu nic nen¡
         mov       word ptr ss:[bp-12],0    ; offset adresy v bufferu
         mov       ss:[bp-14],sp            ; adresa za‡ tku bufferu

; ------ vynulov n¡ obsahu bu¤ky, SI <- za‡ tek textu

         mov       bx,di                    ; BX <- adresa bu¤ky
         add       di,TblXReal              ; za‡ tek ‡¡sla bu¤ky
         xor       ax,ax                    ; AX <- 0 nulovac¡ slovo
         mov       cx,ds:[TBLNumXW]         ; d‚lka ‡¡sla ve slovech
         cld
         rep       stosw                    ; vynulov n¡ bu¤ky

; ------ p©¡prava textu (ozna‡en¡ bajtem 0)

         add       bx,es:[bx+TBLXOffs]      ; adresa dal¨¡ bu¤ky
         mov       al,es:[bx]               ; n sleduj¡c¡ bajt
         push      ax                       ; £schova n sleduj¡c¡ho bajtu
         push      bx
         mov       byte ptr es:[bx],0       ; ozna‡en¡ konce textu

; ------ nalezen¡ za‡ tku jm‚na souboru

         mov       si,di                    ; SI <- za‡ tek textu bu¤ky
         call      TBExtrnS                 ; vypu¨tˆn¡ mezer

; ------ rozli¨en¡, zda je zad n ROOT

         mov       di,ss:[bp-14]            ; DI <- buffer v z sobn¡ku
         cld
         cmp       byte ptr es:[si+1],":"   ; je zad n disk ?
         je        TBExtrn2                 ; je zad n disk - nen¡ cesta
         mov       cx,cs:[TablAdrN]         ; d‚lka cesty
         cmp       byte ptr es:[si],"\"     ; je zad n ROOT ?
         jne       TBExtr12                 ; nen¡ zad n ROOT
         mov       cx,ds:[TablPth0]         ; inicializa‡n¡ d‚lka cesty
         inc       cx                       ; v‡etnˆ oddˆlovac¡ho "\"

; ------ p©¡prava cesty k aktu ln¡mu adres ©i

TBExtr12:push      si
         push      ds

         lds       si,cs:[TablADR]          ; adresa jm‚na souboru
         mov       bx,di                    ; BX <- £schova konce cesty
TBExtr14:lodsb
         mov       ss:[di],al
         inc       di
         cmp       al,"\"
         jne       TBExtr15
         mov       bx,di                    ; BX <- £schova konce cesty
TBExtr15:loop      TBExtr14
         mov       di,bx                    ; DI <- konec cesty

         pop       ds
         pop       si

; ------ p©¡prava d‚lky textu v z sobn¡ku -> CX

TBExtrn2:mov       cx,di                    ; CX <- ukl dac¡ adresa v z sobn¡ku
         sub       cx,ss:[bp-14]            ; CX <- po‡et bajt– v z sobn¡ku

; ------ p©enesen¡ zadan‚ho jm‚na souboru

TBExtr22:mov       al,es:[si]               ; p©ipraven˜ znak
         cmp       al,0
         je        TBExtr24                 ; konec jm‚na souboru
         inc       si
         cmp       al,"]"
         je        TBExtr24                 ; konec jm‚na souboru
         cmp       cx,240                   ; asi tak max. velikost dat
         jae       TBExtr22                 ; buffer je pln˜
         mov       ss:[di],al               ; ulo‘en¡ znaku
         inc       di                       ; zv˜¨en¡ ukl dac¡ adresy
         inc       cx                       ; zv˜¨en¡ ‡¡ta‡e znak–
         jmp       short TBExtr22

; ------ implicitn¡ p©¡pona "TAB"

TBExtr24:cmp       byte ptr ss:[di-1],"."
         je        TBExtr25
         cmp       byte ptr ss:[di-2],"."
         je        TBExtr25
         cmp       byte ptr ss:[di-3],"."
         je        TBExtr25
         cmp       byte ptr ss:[di-4],"."
         je        TBExtr25
         mov       word ptr ss:[di],"T."
         mov       word ptr ss:[di+2],"BA"
         add       cx,4

; ------ na‡ten¡ ‡¡sla bu¤ky

TBExtr25:call      TBExtrnS                 ; vypu¨tˆn¡ mezer
         call      far ptr ETblFBn          ; na‡ten¡ ‡¡sla bu¤ky -> AX
         mov       ss:[bp-8],ax             ; £schova ‡¡sla bu¤ky

; ------ n vrat p–vodn¡ho bajtu za bu¤kou (CY=neplatn  bu¤ka)

         pop       bx
         pop       ax
         mov       es:[bx],al               ; n vrat n sleduj¡c¡ho bajtu
         jnc       TBExtr28                 ; ‡¡slo bu¤ky je OK
TBExtr26:jmp       TBExtrn9                 ; konec

; ------ otev©en¡ souboru (d‚lka CX)

TBExtr28:push      es
         mov       si,ss:[bp-14]            ; buffer jm‚na souboru
         push      ss
         pop       es                       ; ES <- segment v z sobn¡ku
         call      far ptr NormFile         ; normalizace jm‚na
         call      far ptr FullFile         ; p©evod na pln‚ jm‚no
         call      far ptr OpenR            ; otev©en¡ souboru
         pop       es
         jc        TBExtr26                 ; soubor nenalezen
         mov       ss:[bp-2],ax             ; identifik tor souboru

; ------ na‡ten¡ parametr–

         mov       cx,TblIParm-TblTabul     ; po‡et bajt– k p©esko‡en¡
         call      EdTDImpC                 ; p©esko‡en¡ CX bajt–, na‡ten¡ znaku
         jc        TBExtr58                 ; chyba
         test      al,bit3                  ; je soubor uzam‡en ?
         stc                                ; p©¡znak chyby
         jnz       TBExtr58                 ; soubor je uzam‡en

; ------ na‡ten¡ po‡tu slov na celou ‡ st ‡¡sla

         mov       cx,TBLINumN-(TBLIParm+1) ; po‡et bajt– k p©esko‡en¡
         call      EdTDImpC                 ; p©esko‡en¡ CX bajt–, na‡ten¡ znaku
         jc        TBExtr58                 ; chyba
         mov       ss:[bp-15],al            ; po‡et slov na celou ‡ st ‡¡sla

; ------ na‡ten¡ po‡tu slov na desetinnou ‡ st ‡¡sla

         call      EdTDImpB                 ; na‡ten¡ bajtu
         jc        TBExtr58                 ; chyba
         mov       ss:[bp-16],al            ; po‡et slov na desetinnou ‡ st

; ------ na‡ten¡ offsetu dal¨¡ bu¤ky

         mov       cx,TblDat-(TBLINumD+1)   ; po‡et bajt– k p©esko‡en¡
TBExtrn3:call      EdTDImpC                 ; p©esko‡en¡ CX bajt–, na‡ten¡ znaku
         jc        TBExtr58                 ; chyba
         mov       cl,al                    ; ni‘¨¡ bajt offsetu
         call      EdTDImpB                 ; na‡ten¡ dal¨¡ho znaku
         jc        TBExtr58                 ; chyba
         mov       ch,al                    ; vy¨¨¡ bajt offsetu

; ------ na‡ten¡ ‡¡sla bu¤ky

         call      EdTDImpB                 ; na‡ten¡ dal¨¡ho znaku
         jc        TBExtr58                 ; chyba
         mov       ah,al                    ; ni‘¨¡ bajt ‡¡sla bu¤ky
         call      EdTDImpB                 ; na‡ten¡ dal¨¡ho znaku
         jc        TBExtr58                 ; chyba
         xchg      al,ah                    ; oprava bajt–

; ------ test, zda byla nalezena po‘adovan  bu¤ka

         sub       cx,4                     ; oprava offsetu dal¨¡ bu¤ky
         cmp       ax,ss:[bp-8]             ; nalezena po‘adovan  bu¤ka ?
         jne       TBExtrn3                 ; nen¡ je¨tˆ po‘adovan  bu¤ka

; ------ po‡et bajt– na desetinnou ‡ st na‡¡tan‚ho ‡¡sla -> BX

         mov       bh,0
         mov       bl,ss:[bp-16]            ; po‡et slov na desetinnou ‡ st
         shl       bx,1                     ; po‡et bajt– na desetinnou ‡ st

; ------ ukl dac¡ adresa pro ‡¡slo -> DI

         mov       di,ss:[bp-6]             ; adresa bu¤ky
         add       di,TblXReal              ; za‡ tek ‡¡sla

; ------ p©esko‡en¡ bajtu parametru a za‡ tku desetin, je-li zmen¨en¡

         mov       dx,ds:[TBLNumD]          ; po‡et bajt– desetin
         mov       cx,1                     ; jen bajt parametru
         cmp       dx,bx                    ; bude zmen¨en¡ desetin ?
         jae       TBExtrn4                 ; nebude zmen¨en¡ desetin
         sub       bx,dx                    ; o tolik se mus¡ desetiny zmen¨it
         add       cx,bx                    ; posun v ‡¡sle
         mov       bx,dx                    ; omezen¡ desetin k na‡ten¡
         jmp       short TBExtrn5

TBExtrn4:sub       dx,bx                    ; o tolik se mus¡ desetiny zvˆt¨it
         add       di,dx                    ; oprava ukl dac¡ adresy

TBExtrn5:call      EdTDImpC                 ; p©esko‡en¡ dat
TBExtr58:jc        TBExtrn8                 ; chyba
         call      EdTDImpR                 ; n vrat bajtu

; ------ stanoven¡ po‡tu bajt– k na‡ten¡ (BX=d‚lka desetin) -> CX

         mov       ch,0
         mov       cl,ss:[bp-15]            ; po‡et slov na celou ‡ st ‡¡sla
         shl       cx,1                     ; po‡et bajt– na celou ‡ st ‡¡sla
         cmp       cx,ds:[TBLNumN]          ; po‘aduje se m‚nˆ dat ?
         jb        TBExtrn6                 ; je m‚nˆ dat
         mov       cx,ds:[TBLNumN]          ; omezen¡ cel‚ ‡ sti ‡¡sla
TBExtrn6:add       cx,bx                    ; po‡et bajt– k na‡ten¡

; ------ na‡ten¡ ‡¡sla

TBExtr62:call      EdTDImpB                 ; na‡ten¡ dal¨¡ho bajtu
         jc        TBExtrn8                 ; chyba
         cld
         stosb                              ; ulo‘en¡ bajtu
         loop      TBExtr62                 ; ulo‘en¡ dal¨¡ho bajtu

; ------ test, zda je zvˆt¨en¡ nebo zmen¨en¡ cel‚ ‡ sti ‡¡sla

         mov       cl,ss:[bp-15]            ; po‡et slov na celou ‡ st ‡¡sla
         shl       cx,1                     ; po‡et bajt– na celou ‡ st ‡¡sla
         sub       cx,ds:[TBLNumN]          ; po‡et p©eb˜vaj¡c¡ch bajt–
         je        TBExtrn8                 ; po‡et bajt– je shodn˜
         ja        TBExtrn7                 ; je zmen¨en¡ ‡¡sla

; ------ je zvˆt¨en¡ ‡¡sla - vyplnˆn¡ zbyl˜ch bajt– znam‚nkem

         neg       cx                       ; po‡et bajt– k ulo‘en¡
         or        al,al                    ; je z porn‚ ‡¡slo ?
         mov       al,0                     ; kladn‚ znam‚nko
         jns       TBExtr66                 ; nen¡ z porn‚ ‡¡slo
         dec       ax                       ; z porn‚ znam‚nko
TBExtr66:cld
         rep       stosb                    ; vymaz n¡ zbytku ‡¡sla
         jmp       short TBExtrn8

; ------ je zmen¨en¡ ‡¡sla - na‡ten¡ posledn¡ho bajtu ‡¡sla a oprava znam‚nka

TBExtrn7:dec       cx                       ; 1 bajt z–stane
         call      EdTDImpC                 ; p©esko‡en¡ dat
         jc        TBExtrn8                 ; chyba
         and       byte ptr es:[di-1],not bit7 ; nulov n¡ znam‚nka
         and       al,bit7                  ; znam‚nko ‡¡sla
         or        es:[di-1],al             ; nastaven¡ znam‚nka

; ------ uzav©en¡ souboru

TBExtrn8:mov       ax,ss:[bp-2]             ; identifik tor souboru
         call      far ptr ClosFile         ; uzav©en¡ souboru

; ------ n vrat registr–

TBExtrn9:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

TBExtern ENDP

; ------ vypu¨tˆn¡ mezer ES:SI

TBExtrnS:dec       si
TBExtrS2:inc       si
         cmp       byte ptr es:[si]," "
         je        TBExtrS2
         ret

; -----------------------------------------------------------------------------
;        nastaven¡ parametr– podle tabulky ES (data mohou b˜t neplatn  !)
; -----------------------------------------------------------------------------

InitPTBL PROC      NEAR

         push      ax

         mov       ah,0
         mov       al,es:[TBLINumN]         ; po‡et slov na celou ‡ st ‡¡sla
         mov       ds:[TBLNumNW],ax         ; po‡et slov na celou ‡ st ‡¡sla
         shl       ax,1                     ; p©evod na bajty
         mov       ds:[TBLNumN],ax          ; po‡et bajt– na celou ‡ st ‡¡sla

         mov       ah,0
         mov       al,es:[TBLINumD]         ; po‡et bajt– na desetinnou ‡ st
         mov       ds:[TBLNumDW],ax         ; po‡et slov na desetinnou ‡ st
         shl       ax,1                     ; p©evod na bajty
         mov       ds:[TBLNumD],ax          ; po‡et bajt– na desetinnou ‡ st

         add       ax,ds:[TBLNumN]          ; po‡et bajt– na ‡¡slo celkem
         mov       ds:[TBLNumX],ax          ; po‡et bajt– na ‡¡slo celkem
         push      ax
         shr       ax,1
         mov       ds:[TBLNumXW],ax         ; po‡et slov na ‡¡slo celkem
         pop       ax

         add       ax,TBLXReal              ; offset za‡ tku textu
         mov       ds:[TBLXText],ax         ; offset za‡ tku textu

         pop       ax
         ret

InitPTBL ENDP

; *****************************************************************************
;                            uzav©en¡ segmentu tabulky
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa definice menu
; *****************************************************************************

ClosTBL  PROC      FAR

         push      ax
         mov       ax,ds:[si+TBMnuSeg]      ; segment okna
         call      far ptr DelSeg           ; zru¨en¡ segmentu AX
         mov       ds:[si+TBMnuSeg],ax      ; ozna‡en¡ segmentu za zru¨en˜
         pop       ax
         ret

ClosTBL  ENDP

; *****************************************************************************
;                             EdTBLMnu
;                         editace tabulky
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa definice menu
;        BX=kl vesa
; *****************************************************************************
;þ
EdTBLMnu PROC      FAR

; ------ £schova registr–

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es

; ------ adresa okna -> ES

         call      TBLAdrES                 ; adresa okna -> ES

         and       byte ptr ds:[TBLTPrm2],not bit1 ; nen¡ pot©ebn˜ p©epo‡et

; ------ p©¡prava registr–

         mov       ax,es:[TBLKurz]          ; bu¤ka s kurzorem
         mov       dl,ds:[si+MnuVys]        ; v˜¨ka okna
         mov       dh,0
         sub       dl,5                     ; bez © dk–

; ------ obsluha kl vesy BX

         call      EdTBLMnX                 ; obsluha kl vesy BX
         call      EdTBPrp0                 ; p©epo‡et tabulky
         call      TBLIni                   ; inicializace kurzoru a po‡ tku

; ------ obsluha ozna‡ov n¡ bloku

         test      byte ptr ds:[TBLTParm],bit5 ; je ozna‡ov n¡ bloku ?
         jz        EdTBLMn3                 ; nen¡ ozna‡ov n¡ bloku
         test      byte ptr ds:[TBLTParm],bit3 ; je ji‘ konec bloku ?
         jnz       EdTBLMn3                 ; je ji‘ konec bloku

         mov       bx,ds:[TBBlokO]          ; po‡ tek bloku
         mov       dx,es:[TBLKurz]          ; konec bloku (kurzor)
         call      far ptr TInitBlk         ; inicializace operace s blokem

EdTBLMn3:xor       bx,bx                    ; p©¡znak obsluhy kl vesy
         jmp       EdTBLMn9

; ------ obsluha kl vesy BX

EdTBLMnX:call      far ptr JumpBX

         dw        4b00h,EdTBLft            ; vlevo
         dw        4d00h,EdTBRgh            ; vpravo
         dw        5000h,EdTBDwn            ; dol–
         dw        4800h,EdTBUp             ; nahoru

         dw        4700h,EdTBHom            ; Home
         dw        4f00h,EdTBEnd            ; End
         dw        7700h,EdTBCPU            ; Ctrl-Home
         dw        7500h,EdTBCPD            ; Ctrl-End

         dw        5100h,EdTBPgD            ; PageDown
         dw        4900h,EdTBPgU            ; PageUp
         dw        7600h,EdTBCPD            ; Ctrl-PageDown
         dw        8400h,EdTBCPU            ; Ctrl-PageUp

         dw        1c0dh,EdTbVyrB           ; Enter
         dw        3c00h,EdTbUloz           ; F2
         dw        3d00h,EdTBBlk            ; F3
         dw        3e00h,EdTbVyrA           ; F4

         dw        4100h,EdTbMod            ; F7

         dw        4300h,EdTbPrep           ; F9
         dw        4400h,EdTBMMnu           ; F10

;         dw        5f00h,EdTBSir            ; Ctrl-F2
         dw        6500h,EdTBRO             ; Ctrl-F8

         dw        5200h,EdTBIns            ; INSERT
         dw        5300h,EdTBDel            ; DELETE

         dw        0f09h,EdTBTab            ; Tab
         dw        0f00h,EdTBSTb            ; Shift-Tab

         dw        MousXKod+MousXLP,EdTBMKur ; stisk lev‚ho tla‡¡tka my¨i
         dw        MousXKod+MousXRP,EdTBBlk0 ; stisk prav‚ho tla‡¡tka my¨i
         dw        MousXKod+MousXMov,EdTBMKur ; veden¡ kurzoru my¨¡
         dw        MousXKod+MousXLH,EdTBMKur ; dr‘en¡ lev‚ho tla‡¡tka my¨i
         dw        MousXKod+MousXRH,EdTBMKur ; dr‘en¡ prav‚ho tla‡¡tka my¨i
         dw        MousXKod+MousXRR,EdTbVrB0 ; uvolnˆn¡ prav‚ho tla‡¡tka
         dw        MousXKod+MousXLD,EdTbVyrB ; dvoj¡ stisk lev‚ho tla‡¡tka=ENTER
         dw        MousXKod+MousXMP,EdTBMMnu ; stisk st©edn¡ho tla‡¡tka - menu

         dw        0,EdTBVyr0               ; jin  kl vesa - editace

EdTBLMn8:pop       ax                       ; zru¨en¡ n vratov‚ adresy
         clc

; ------ n vrat registr–

EdTBLMn9:pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

EdTBLMnu ENDP

; -----------------------------------------------------------------------------
;        veden¡ kurzoru my¨¡
; -----------------------------------------------------------------------------
;þ
EdTBMKur PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx

; ------ © dek s polo‘kou

         mov       al,byte ptr ds:[MousePoz+1] ; © dek kurzoru my¨i
         sub       al,ds:[si+MnuRad]        ; ode‡ten¡ © dku menu
         mov       ah,0
         sub       ax,3                     ; ode‡ten¡ horn¡ho okraje
         mov       cl,TBLRotR               ; po‡et rotac¡
         shl       ax,cl                    ; posun © dku na pozici
         add       ax,es:[TBLTop]           ; nov˜ © dek s kurzorem
         and       ax,TBLMaskR              ; maskov n¡ © dku
         cmp       ax,65535-(65535-TBLMaxR*TBLNasR)/2 ; je p©ete‡en¡ dol– ?
         jb        EdTBMKr1                 ; nen¡ p©ete‡en¡ dol–
         xor       ax,ax                    ; omezen¡ p©i p©ete‡en¡ dol–
EdTBMKr1:cmp       ax,TBLMaxR*TBLNasR       ; je p©ete‡en¡ nahoru ?
         jbe       EdTBMKr2                 ; nen¡ p©ete‡en¡ nahoru
         mov       ax,TBLMaxR*TBLNasR       ; omezen¡ p©i p©ete‡en¡ nahoru
EdTBMKr2:mov       es:[TBLKurz],ax          ; kurzor

; ------ sloupec s polo‘kou

         mov       bx,es:[TBLTop]           ; po‡ te‡n¡ bu¤ka
         and       bx,TBLMaskC              ; maska ‡¡sla sloupce
         mov       al,byte ptr ds:[MousePoz] ; pozice kurzoru my¨i
         sub       al,ds:[si+MnuPoz]        ; ode‡ten¡ pozice menu
         sub       al,5                     ; je lev˜ okraj ?
         jnc       EdTBMKr4                 ; nen¡ lev˜ okraj
         dec       bx                       ; p©ede¨l˜ sloupec
         jns       EdTBMKr5                 ; nen¡ podte‡en¡
         jmp       short EdTBMKr6
EdTBMKr3:inc       bx                       ; n vrat kurzoru
         cmp       bx,TBLMaxC               ; je ji‘ maxim ln¡ sloupec ?
         jae       EdTBMKr5                 ; je ji‘ maxim ln¡ sloupec
EdTBMKr4:sub       al,es:[bx+TblSirTb]      ; ode‡ten¡ ¨¡©ky sloupce
         jnc       EdTBMKr3                 ; dal¨¡ sloupec
EdTBMKr5:or        es:[TBLKurz],bx          ; sloupec s kurzorem

; ------ n vrat registr–

EdTBMKr6:pop       cx
         pop       bx
         pop       ax
         ret

EdTBMKur ENDP

; -----------------------------------------------------------------------------
;        bu¤ka vlevo
; -----------------------------------------------------------------------------

EdTBLft  PROC      NEAR

         test      byte ptr es:[TblIParm],bit7 ; je m¢d formul ©e ?
         jz        EdTBLft1                 ; nen¡ m¢d formul ©e
         jmp       EdTBSTb                  ; pro formul © jako Shift-Tab

EdTBLft1:test      al,TBLMaskC              ; je ji‘ po‡ tek © dku ?
         jz        EdTBLft4                 ; je ji‘ po‡ tek © dku
         dec       ax                       ; sn¡‘en¡ sloupce
EdTBLft2:and       al,TBLMaskC              ; maska sloupce
         and       byte ptr es:[TBLKurz],not TBLMaskC ; nulov n¡ sloupce
         or        es:[TBLKurz],al          ; nastaven¡ nov‚ho sloupce
EdTBLft4:ret

EdTBLft  ENDP

; -----------------------------------------------------------------------------
;        bu¤ka vpravo
; -----------------------------------------------------------------------------

EdTBRgh  PROC      NEAR

         test      byte ptr es:[TblIParm],bit7 ; je m¢d formul ©e ?
         jz        EdTBRgh1                 ; nen¡ m¢d formul ©e
         jmp       EdTBTab                  ; pro formul © jako Tab

EdTBRgh1:and       al,TBLMaskC              ; ‡¡slo sloupce
         cmp       al,TBLMaxC               ; je ji‘ maxim ln¡ ‡¡slo sloupce ?
         jae       EdTBLft4                 ; je ji‘ maxim ln¡ ‡¡slo sloupce
         inc       ax                       ; zv˜¨en¡ sloupce
         jmp       short EdTBLft2           ; nastaven¡ nov‚ho sloupce

EdTBRgh  ENDP

; -----------------------------------------------------------------------------
;        Home: prvn¡ sloupec
; -----------------------------------------------------------------------------

EdTBHom  PROC      NEAR

         test      byte ptr es:[TblIParm],bit7 ; je m¢d formul ©e ?
         jz        EdTBHom8                 ; nen¡ m¢d formul ©e

         cmp       word ptr es:[TblBunN],0  ; po‡et bunˆk
         je        EdTBHom9
         mov       di,TblDat                ; za‡ tek dat tabulky
EdTBHom1:add       di,es:[di+TblXOffs]      ; adresa dal¨¡ bu¤ky
         cmp       di,es:[0]                ; je to platn  bu¤ka ?
         jae       EdTBHom9                 ; nen¡ to platn  bu¤ka
         test      byte ptr es:[di+TblXParm],bit7 ; je bu¤ka uzam‡ena ?
         jnz       EdTBHom1                 ; bu¤ka je uzam‡ena - dal¨¡
         jmp       EdTBTab3                 ; nastaven¡ bu¤ky

EdTBHom8:xor       ax,ax                    ; AL <- 0
         jmp       short EdTBLft2

EdTBHom9:ret

EdTBHom  ENDP

; -----------------------------------------------------------------------------
;        End: posledn¡ sloupec na © dku
; -----------------------------------------------------------------------------

EdTBEnd  PROC      NEAR

         mov       di,TblDat                ; za‡ tek dat
         mov       cx,es:[TblBunN]          ; po‡et bunˆk
         jcxz      EdTBHom

         test      byte ptr es:[TblIParm],bit7 ; je m¢d formul ©e ?
         jz        EdTBEnd1                 ; nen¡ m¢d formul ©e

         xor       bx,bx                    ; BX <- 0 p©¡znak, ‘e nen¡ bu¤ka
EdTBEn02:test      byte ptr es:[di+TblXParm],bit7 ; je bu¤ka uzam‡ena ?
         jnz       EdTBEn03                 ; bu¤ka je uzam‡ena - dal¨¡
         mov       bx,di                    ; BX <- £schova adresy bu¤ky
EdTBEn03:add       di,es:[di+TblXOffs]      ; adresa dal¨¡ bu¤ky
         cmp       di,es:[0]                ; je to platn  bu¤ka ?
         jb        EdTBEn02                 ; dal¨¡ bu¤ka

         mov       di,bx                    ; DI <- adresa nalezen‚ bu¤ky
         or        di,di                    ; byla nalezena bu¤ka ?
         jz        EdTBEn09                 ; bu¤ka nenalezena
         jmp       EdTBTab3                 ; nastaven¡ bu¤ky

EdTBEn09:ret

EdTBEnd1:mov       al,0                     ; AL <- pozice 0

         mov       bx,es:[TBLKurz]          ; polo‘ka s kurzorem
         and       bx,TBLMaskR              ; ‡¡slo © dku
EdTBEnd2:mov       dx,es:[di+TblXBunk]      ; ‡¡slo bu¤ky
         and       dx,TBLMaskR              ; ‡¡slo © dku
         cmp       bx,dx                    ; je to kurzor ?
         jne       EdTBEnd4                 ; nen¡ to © dek s kurzorem
         mov       ah,es:[di+TblXBunk]      ; ‡¡slo bu¤ky
         and       ah,TBLMaskC              ; ‡¡slo sloupce
         cmp       ah,al                    ; je vˆt¨¡ sloupec ?
         jbe       EdTBEnd4                 ; nen¡ vˆt¨¡ sloupec
         mov       al,ah                    ; AL <- nov˜ sloupec
EdTBEnd4:add       di,es:[di+TblXOffs]      ; dal¨¡ bu¤ka
         loop      EdTBEnd2                 ; dal¨¡ bu¤ka
         jmp       EdTBLft2                 ; nastaven¡ bu¤ky

EdTBEnd  ENDP

; -----------------------------------------------------------------------------
;        © dek dol–
; -----------------------------------------------------------------------------

EdTBDwn  PROC      NEAR

         test      byte ptr es:[TblIParm],bit7 ; je m¢d formul ©e ?
         jz        EdTBDwn1                 ; nen¡ m¢d formul ©e
         push      ax
         add       ax,TBLNasR               ; posun o © dek dol–
         call      TBLSrc                   ; nalezen¡ adresy kurzoru -> DI
         pop       ax
         jc        EdTBDwn6                 ; nen¡ hledan  bu¤ka
         test      byte ptr es:[di+TblXParm],bit7 ; je bu¤ka uzam‡ena ?
         jnz       EdTBDwn6                 ; bu¤ka je uzam‡ena

EdTBDwn1:add       ax,TBLNasR               ; posun o © dek dol–
EdTBDwn2:jc        EdTBDwn4                 ; p©ete‡en¡
         cmp       ax,(TBLMaxR+1)*TBLNasR   ; p©ekro‡en maxim ln¡ © dek ?
         jae       EdTBDwn4                 ; p©ekro‡en maxim ln¡ © dek
         mov       es:[TBLKurz],ax          ; nov˜ kurzor
EdTBDwn4:ret

EdTBDwn6:jmp       EdTBTab                  ; n hrada kl vesou TAB

EdTBDwn  ENDP

; -----------------------------------------------------------------------------
;        © dek nahoru
; -----------------------------------------------------------------------------

EdTBUp   PROC      NEAR

         test      byte ptr es:[TblIParm],bit7 ; je m¢d formul ©e ?
         jz        EdTBUp1                  ; nen¡ m¢d formul ©e
         push      ax
         sub       ax,TBLNasR               ; posun o © dek nahoru
         call      TBLSrc                   ; nalezen¡ adresy kurzoru -> DI
         pop       ax
         jc        EdTBUp6                  ; nen¡ hledan  bu¤ka
         test      byte ptr es:[di+TblXParm],bit7 ; je bu¤ka uzam‡ena ?
         jnz       EdTBUp6                  ; bu¤ka je uzam‡ena

EdTBUp1: sub       ax,TBLNasR               ; posun o © dek nahoru
         jmp       short EdTBDwn2

EdTBUp6: jmp       EdTBSTb                  ; n hrada kl vesou Shift-Tab

EdTBUp   ENDP

; -----------------------------------------------------------------------------
;        str nka dol–
; -----------------------------------------------------------------------------

EdTBPgD  PROC      NEAR

         dec       dx
         mov       cl,TBLRotR               ; po‡et rotac¡
         shl       dx,cl                    ; p©evod v˜¨ky okna
         add       word ptr es:[TBLKurz],dx ; posun kurzoru
         jc        EdTBPgD8
         cmp       word ptr es:[TBLKurz],TBLMaxR*TBLNasR
         ja        EdTBPgD8
         add       word ptr es:[TBLTop],dx  ; posun po‡ tku
         jnc       EdTBPgD9

EdTBPgD8:and       word ptr es:[TBLKurz],not TBLMaskR ; © dek 0
         or        word ptr es:[TBLKurz],TBLMaxR*TBLNasR ; max. ‡¡slo sloupce
EdTBPgD9:ret

EdTBPgD  ENDP

; -----------------------------------------------------------------------------
;        str nka nahoru
; -----------------------------------------------------------------------------

EdTBPgU  PROC      NEAR

         dec       dx
         mov       cl,TBLRotR               ; po‡et rotac¡
         shl       dx,cl                    ; p©evod v˜¨ky okna
         sub       word ptr es:[TBLKurz],dx ; posun kurzoru
         jc        EdTBPgU2
         sub       word ptr es:[TBLTop],dx
         jnc       EdTBPgU3
EdTBPgU2:and       word ptr es:[TBLKurz],not TBLMaskR ; © dek 0
EdTBPgU3:ret

EdTBPgU  ENDP

; -----------------------------------------------------------------------------
;        za‡ tek tabulky
; -----------------------------------------------------------------------------

EdTBCPU  PROC      NEAR

         mov       word ptr es:[TBLKurz],0  ; © dek 0
         ret

EdTBCPU  ENDP

; -----------------------------------------------------------------------------
;        konec tabulky
; -----------------------------------------------------------------------------

EdTBCPD  PROC      NEAR

         xor       dx,dx                    ; maxim ln¡ sloupec
         xor       ax,ax                    ; pro p©¡pad, ‘e nen¡ bu¤ka
         mov       di,TblDat                ; za‡ tek dat
         mov       cx,es:[TblBunN]          ; po‡et bunˆk
         jcxz      EdTBCPD5
         dec       cx
         jcxz      EdTBCPD4
EdTBCPD2:mov       ax,es:[di+TblXBunk]      ; ‡¡slo bu¤ky
         and       ax,TBLMaskC              ; ‡¡slo sloupce
         cmp       ax,dx                    ; je vˆt¨¡ ‡¡slo sloupce ?
         jb        EdTBCPD3                 ; nen¡ vˆt¨¡ ‡¡slo sloupce
         xchg      ax,dx                    ; DX <- nov˜ maxim ln¡ sloupec
EdTBCPD3:add       di,es:[di+TblXOffs]      ; dal¨¡ bu¤ka
         loop      EdTBCPD2                 ; dal¨¡ bu¤ka

EdTBCPD4:mov       ax,es:[di+TblXBunk]
         and       ax,TBLMaskR              ; nulov n¡ sloupce
         or        ax,dx                    ; maxim ln¡ sloupec
EdTBCPD5:mov       es:[TBLKurz],ax          ; nastaven¡ kurzoru

EdTBCPD8:ret

EdTBCPD  ENDP

; -----------------------------------------------------------------------------
;        Tab: dal¨¡ bu¤ka
; -----------------------------------------------------------------------------

EdTBTab  PROC      NEAR

         mov       di,es:[TBLKurzA]         ; adresa bu¤ky s kurzorem
         test      byte ptr es:[TBLParm],bit4 ; je kurzor platn  bu¤ka ?
         jz        EdTBTab2                 ; kurzor nen¡ platn  bu¤ka
EdTBTab1:add       di,es:[di+TblXOffs]      ; adresa dal¨¡ bu¤ky
EdTBTab2:cmp       di,es:[0]                ; je to platn  bu¤ka ?
         jae       EdTBTab5                 ; nen¡ to platn  bu¤ka
         test      byte ptr es:[TblIParm],bit7 ; je m¢d formul ©e ?
         jz        EdTBTab3                 ; nen¡ m¢d formul ©e
         test      byte ptr es:[di+TblXParm],bit7 ; je bu¤ka uzam‡ena ?
         jnz       EdTBTab1                 ; bu¤ka je uzam‡ena - dal¨¡
EdTBTab3:mov       ax,es:[di+TblXBunk]      ; ‡¡slo nov‚ bu¤ky
         mov       es:[TBLKurz],ax          ; nov˜ kurzor
EdTBTab4:ret

EdTBTab5:test      byte ptr es:[TblIParm],bit7 ; je m¢d formul ©e ?
         jz        EdTBTab3                 ; nen¡ m¢d formul ©e
         jmp       EdTBHom                  ; pro formul © Home

EdTBTab  ENDP

; -----------------------------------------------------------------------------
;        Shift-TAB: p©ede¨l  bu¤ka
; -----------------------------------------------------------------------------

EdTBSTb  PROC      NEAR

         xor       bx,bx                    ; BX <- 0 p©¡znak, ‘e nen¡ bu¤ka
         mov       di,TblDat                ; za‡ tek dat tabulky

         cmp       di,es:[TBLKurzA]
         jae       EdTBSTb5

EdTBSTb2:cmp       di,es:[0]                ; je dal¨¡ bu¤ka ?
         jae       EdTBSTb5                 ; nen¡ dal¨¡ bu¤ka

         test      byte ptr es:[TblIParm],bit7 ; je m¢d formul ©e ?
         jz        EdTBSTb3                 ; nen¡ m¢d formul ©e
         test      byte ptr es:[di+TblXParm],bit7 ; je bu¤ka uzam‡ena ?
         jnz       EdTBSTb4                 ; bu¤ka je uzam‡ena - dal¨¡
EdTBSTb3:mov       bx,di                    ; BX <- £schova adresy bu¤ky

EdTBSTb4:add       di,es:[di+TblXOffs]      ; adresa dal¨¡ bu¤ky
         cmp       di,es:[TBLKurzA]         ; nalezena bu¤ka s kurzorem ?
         jb        EdTBSTb2                 ; nen¡ kurzor - dal¨¡ bu¤ka

EdTBSTb5:mov       di,bx                    ; DI <- adresa nalezen‚ bu¤ky
         or        di,di                    ; byla nalezena bu¤ka ?
         jnz       EdTBTab3                 ; byla nalezena bu¤ka OK
         test      byte ptr es:[TblIParm],bit7 ; je m¢d formul ©e ?
         jz        EdTBSTb6                 ; nen¡ m¢d formul ©e
         jmp       EdTBEnd                  ; pro formul © End

EdTBSTb6:ret

EdTBSTb  ENDP

; -----------------------------------------------------------------------------
;        F10: menu
; -----------------------------------------------------------------------------
;þ
EdTBMMnu PROC      NEAR

         test      byte ptr ds:[TBLTParm],bit5 ; je ozna‡ov n¡ bloku ?
         jz        EdTBMMn7                 ; nen¡ ozna‡ov n¡ bloku
         jmp       EdTBBlk3                 ; ozna‡en¡ bloku

EdTBMMn7:push      si
         mov       si,offset TBMnVert
         call      far ptr CentMenu         ; vyst©edˆn¡ menu
         call      EdTBMPrp                 ; p©¡prava p©ep¡na‡– pro menu
         call      far ptr VertMenu         ; obsluha menu
EdTBMMn8:pop       si
EdTBMMn9:ret

EdTBMMnu ENDP

; ------ proveden¡ volby menu

EdTBMMnF:add       sp,4                     ; zru¨en¡ n vratov‚ adresy
         mov       bx,ds:[si+MnuAkt]        ; zvolen  polo‘ka
         call      far ptr ClosMnu          ; uzav©en¡ menu
         pop       si                       ; n vrat SI = adresa okna

         shl       bx,1                     ; zvolen  polo‘ka * 2
         jmp       word ptr cs:[EdTBMMTF+bx-2]

EdTBMMTF dw        0                        ; Automaticky
         dw        EdTBBlk                  ; Blok
         dw        0                        ; Cel  ‡ st
         dw        0                        ; Desetiny
         dw        EdTBVyr                  ; Editace
         dw        0                        ; Formul ©
         dw        EdTBHs0                  ; Heslo
         dw        EdTBImp                  ; Import
         dw        0                        ; Ladˆn¡
         dw        0                        ; M¡st
         dw        0                        ; Ochrana
         dw        EdTbPrep                 ; P©epo‡et
         dw        0                        ; Radi ny
         dw        0                        ; Sloupec
         dw        0                        ; Tis¡ce
         dw        EdTBUloz                 ; Ulo‘en¡
         dw        EdTBIns                  ; Vlo‘it
         dw        EdTBExp0                 ; eXport
         dw        EdTBDel                  ; Zru¨it

; -----------------------------------------------------------------------------
;        p©¡prava p©ep¡na‡– pro menu DS:SI, okno ES
; -----------------------------------------------------------------------------

EdTBMPrp PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx

; ------ p©¡prava p©ep¡na‡–

         mov       dl,0
         mov       al,es:[TblIParm]         ; p©ep¡na‡e

         test      al,bit2                  ; zobrazen¡ tis¡c– ?
         jz        EdTBMPr1
         or        dl,bit5                  ; p©¡znak zobrazen¡ tis¡c–

EdTBMPr1:test      al,bit4                  ; automatick˜ p©epo‡et ?
         jz        EdTBMPr2                 ; nen¡ automatick˜ p©epo‡et
         or        dl,bit0                  ; p©¡znak automatick‚ho ladˆn¡

EdTBMPr2:test      al,bit7                  ; formul © ?
         jz        EdTBMPr3                 ; nen¡ formul ©
         or        dl,bit1                  ; p©¡znak formul ©e

EdTBMPr3:test      al,bit5                  ; zobrazen¡ v˜raz– ?
         jz        EdTBMPr4                 ; nen¡ zobrazen¡ v˜raz– (ladˆn¡)
         or        dl,bit2                  ; p©¡znak ladˆn¡

EdTBMPr4:test      al,bit6                  ; v˜po‡ty v RAD ?
         jz        EdTBMPr5                 ; nejsou v˜po‡ty v RAD
         or        dl,bit4                  ; p©¡znak v˜po‡t– v RAD

; ------ nulov n¡ blokovac¡ tabulky

EdTBMPr5:mov       bx,offset TBMnVBlk
         mov       cx,ds:[si+MnuNum]        ; po‡et platn˜ch polo‘ek menu
EdTBMP52:and       byte ptr ds:[bx],not bit1 ; polo‘ka povolena
         inc       bx
         loop      EdTBMP52

; ------ z kazy polo‘ek, je-li formul ©

         test      byte ptr es:[TblIParm],bit7 ; je formul © ?
         jz        EdTBMP54                 ; nen¡ formul ©
         or        byte ptr ds:[TBMnVBlk+1],bit1 ; z kaz volby bloku
         or        byte ptr ds:[TBMnVBlk+2],bit1 ; z kaz volby desetin
         or        byte ptr ds:[TBMnVBlk+3],bit1 ; z kaz volby cel‚ ‡ sti
         or        byte ptr ds:[TBMnVBlk+8],bit1 ; z kaz zmˆny ladˆn¡
         or        byte ptr ds:[TBMnVBlk+9],bit1 ; z kaz zmˆny desetinn˜ch m¡st
         or        byte ptr ds:[TBMnVBlk+10],bit1 ; nen¡ ochrana bu¤ky
         or        byte ptr ds:[TBMnVBlk+12],bit1 ; z kaz zmˆny radi n–
         or        byte ptr ds:[TBMnVBlk+13],bit1 ; z kaz zmˆny sloupce
         or        byte ptr ds:[TBMnVBlk+16],bit1 ; z kaz vlo‘en¡
         or        byte ptr ds:[TBMnVBlk+18],bit1 ; z kaz ru¨en¡

; ------ polo‘ka je R/O

EdTBMP54:or        byte ptr ds:[TBMnVBlk+10],bit1 ; nen¡ ochrana bu¤ky
         test      byte ptr es:[TBLParm],bit4 ; je kurzor platn  bu¤ka ?
         jz        EdTBMP57                 ; kurzor nen¡ platn  bu¤ka
         test      byte ptr es:[TblIParm],bit7 ; je formul © ?
         jnz       EdTBMP56                 ; je formul ©
         and       byte ptr ds:[TBMnVBlk+10],not bit1 ; je platn  bu¤ka
EdTBMP56:test      byte ptr es:[TBLParm],bit5 ; je kurzor R/O ?
         jz        EdTBMPr6                 ; kurzor nen¡ R/O
         or        dl,bit3                  ; kurzor je R/O
         jmp       short EdTBMP58           ; z kaz editace bu¤ky

EdTBMP57:test      byte ptr es:[TblIParm],bit7 ; je formul © ?
         jz        EdTBMPr6                 ; nen¡ formul ©

EdTBMP58:or        byte ptr ds:[TBMnVBlk+4],bit1 ; editace bu¤ky zak z na

EdTBMPr6:call      far ptr SetSwch          ; nastaven¡ p©ep¡na‡–

; ------ ¨¡©ka sloupce

         mov       bx,es:[TBLKurz]          ; kurzor
         and       bx,TBLMaskC              ; maska ‡¡sla sloupce
         mov       al,es:[bx+TblSirTb]      ; ¨¡©ka sloupce
         call      EdTBMPDk                 ; dek¢dov n¡ ‡¡sla na ASCII
         mov       word ptr ds:[TBMnVPl4],ax ; ¨¡©ka sloupce

; ------ po‡et desetinn˜ch m¡st

         mov       al,es:[bx+TblDesTb]      ; po‡et desetinn˜ch m¡st
         call      EdTBMPDk                 ; dek¢dov n¡ ‡¡sla na ASCII
         mov       word ptr ds:[TBMnVPl3],ax ; po‡et desetinn˜ch m¡st

; ------ po‡et slov na celou ‡ st ‡¡sla

         mov       al,es:[TBLINumN]         ; po‡et slov na celou ‡ st ‡¡sla
         call      EdTBMPDk                 ; dek¢dov n¡ ‡¡sla na ASCII
         mov       word ptr ds:[TBMnVPl1],ax ; po‡et slov na celou ‡ st ‡¡sla

; ------ po‡et slov na desetinnou ‡ st ‡¡sla

         mov       al,es:[TBLINumD]         ; po‡et slov na desetin. ‡ st ‡¡sla
         call      EdTBMPDk                 ; dek¢dov n¡ ‡¡sla na ASCII
         mov       word ptr ds:[TBMnVPl2],ax ; po‡et slov na desetin. ‡ st ‡¡sla

; ------ indikace hesla

         mov       bx,offset TBMnVPlH
         mov       word ptr ds:[bx],"NA"
         mov       byte ptr ds:[bx+2],"O"
         cmp       byte ptr es:[TBLHeslN],0 ; je heslo ?
         jne       EdTBMPr7
         mov       word ptr ds:[bx],"n "
         mov       byte ptr ds:[bx+2],"e"

; ------ n vrat registr–

EdTBMPr7:pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

EdTBMPrp ENDP

; ------ dek¢dov n¡ ‡¡sla AL na znaky ASCII -> AX

EdTBMPDk:aam                                ; konverze na 2 znaky BCD
         xchg      ah,al                    ; oprava po©ad¡ ‡¡slic
         add       ax,"00"                  ; konverze na ASCII znaky
         cmp       al,"0"                   ; prvn¡ ‡¡slice = 0 ?
         jne       EdTBMPD2                 ; prvn¡ ‡¡slice nen¡ 0
         mov       al," "                   ; potla‡en¡ nev˜znamn‚ nuly
EdTBMPD2:ret

; ------ zad n¡ po‡tu slov na celou ‡ st ‡¡sla

EdTBMMn1:push      es
         push      si

         push      ds
         pop       es                       ; ES <- datov˜ segment
         mov       bx,50                    ; maxim ln¡ hodnota ‡¡sla
         mov       ch,2                     ; minim ln¡ hodnota ‡¡sla
         mov       cl,2                     ; d‚lka textu
         mov       dx,word ptr ds:[si+MnuPoz] ; po‡ te‡n¡ pozice menu
         add       dx,3*HI + 16             ; pozice relativnˆ
         mov       di,offset TBMnVPl1       ; buffer k dek¢dov n¡ pozic
         mov       si,offset TBMnVHl1       ; text n povˆdy
         call      far ptr MenuNum          ; zad n¡ ‡¡sla

         pop       si
         pop       es
         cmp       al,es:[TBLINumN]         ; byl po‡et slov zmˆnˆn ?
         je        EdTBMMn4                 ; po‡et slov nebyl zmˆnˆn
         call      TBStNTst                 ; potvrzen¡ operace
         jc        EdTBMMn4                 ; p©eru¨en¡ operace
         call      TBSetNmN                 ; nastaven¡ slov na celou ‡ st
         jc        EdTBMMn4                 ; chyba operace
         mov       es:[TBLINumN],al         ; po‡et slov na celou ‡ st ‡¡sla
         jmp       short EdTBMM24           ; konverze tabulky

; ------ zad n¡ po‡tu slov na desetinnou ‡ st ‡¡sla

EdTBMMn2:push      es
         push      si

         push      ds
         pop       es                       ; ES <- datov˜ segment
         mov       bx,50                    ; maxim ln¡ hodnota ‡¡sla
         mov       ch,2                     ; minim ln¡ hodnota ‡¡sla
         mov       cl,2                     ; d‚lka textu
         mov       dx,word ptr ds:[si+MnuPoz] ; po‡ te‡n¡ pozice menu
         add       dx,4*HI + 16             ; pozice relativnˆ
         mov       di,offset TBMnVPl2       ; buffer k dek¢dov n¡ pozic
         mov       si,offset TBMnVHl2       ; text n povˆdy
         call      far ptr MenuNum          ; zad n¡ ‡¡sla

         pop       si
         pop       es
         cmp       al,es:[TBLINumD]         ; byl po‡et slov zmˆnˆn ?
         je        EdTBMMn4                 ; po‡et slov nebyl zmˆnˆn
         call      TBStNTst                 ; potvrzen¡ operace
         jc        EdTBMMn4                 ; p©eru¨en¡ operace
         call      TBSetNmD                 ; nastaven¡ bajt– na desetin. ‡ st
         jc        EdTBMMn4                 ; chyba operace
         mov       es:[TBLINumD],al         ; po‡et slov na desetin. ‡ st ‡¡sla
EdTBMM24:or        byte ptr es:[TBLParm],bit0 ; p©¡znak modifikace tabulky

;þ !!!!!!!!!!!!
         call      OpenVerf                 ; ovˆ©en¡ struktury
         jc        EdTBMM54                 ; p©eru¨en¡
;þ !!!!!!!!!!!!

         call      InitPTBL                 ; inicializace parametr–
         call      TBLITop                  ; inicializace po‡ tku
         call      TBLIKur                  ; inicializace kurzoru
         mov       bl,CR                    ; menu se ukon‡¡
         jmp       EdTBMRd2                 ; p©epo‡et

EdTBMMn4:mov       bl," "                   ; menu se nebude ukon‡ovat
         jmp       EdTBMAu3

; ------ zad n¡ po‡tu zobrazen˜ch desetinn˜ch m¡st

EdTBMMn3:push      es
         push      si

         push      ds
         pop       es                       ; ES <- datov˜ segment
         mov       bx,TBLMaxS-2             ; maxim ln¡ hodnota ‡¡sla
         mov       ch,0                     ; minim ln¡ hodnota ‡¡sla
         mov       cl,2                     ; d‚lka textu
         mov       dx,word ptr ds:[si+MnuPoz] ; po‡ te‡n¡ pozice menu
         add       dx,10*HI + 16            ; pozice relativnˆ
         mov       di,offset TBMnVPl3       ; buffer k dek¢dov n¡ pozic
         mov       si,offset TBMnVHl3       ; text n povˆdy
         call      far ptr MenuNum          ; zad n¡ ‡¡sla

         pop       si
         pop       es
         jc        EdTBMMn4                 ; p©eru¨en¡ volby

         mov       bx,es:[TBLKurz]          ; kurzor
         and       bx,TBLMaskC              ; maska ‡¡sla sloupce
         mov       es:[bx+TblDesTb],al      ; ulo‘en¡ po‡tu desetinn˜ch m¡st
         jmp       short EdTBMM54

; ------ zad n¡ ¨¡©ky sloupce

EdTBMMn5:push      es
         push      si

         push      ds
         pop       es                       ; ES <- datov˜ segment
         mov       bx,TBLMaxS               ; maxim ln¡ hodnota ‡¡sla
         mov       ch,1                     ; minim ln¡ hodnota ‡¡sla
         mov       cl,2                     ; d‚lka textu
         mov       dx,word ptr ds:[si+MnuPoz] ; po‡ te‡n¡ pozice menu
         add       dx,14*HI + 16            ; pozice relativnˆ
         mov       di,offset TBMnVPl4       ; buffer k dek¢dov n¡ pozic
         mov       si,offset TBMnVHl4       ; text n povˆdy
         call      far ptr MenuNum          ; zad n¡ ‡¡sla

         pop       si
         pop       es
         jc        EdTBMMn4                 ; p©eru¨en¡ volby

         mov       bx,es:[TBLKurz]          ; kurzor
         and       bx,TBLMaskC              ; maska ‡¡sla sloupce
         mov       es:[bx+TblSirTb],al      ; ulo‘en¡ ¨¡©ky sloupce
EdTBMM54:mov       bl,CR                    ; menu se ukon‡¡
         jmp       short EdTBMAu3

; -----------------------------------------------------------------------------
;        odsazen¡ tis¡c–
; -----------------------------------------------------------------------------

EdTBMTis:push      ax
         mov       al,bit2                  ; p©¡znak odsazen¡ tis¡c–
         jmp       short EdTBMAu2

; -----------------------------------------------------------------------------
;        Automatick˜ m¢d
; -----------------------------------------------------------------------------

EdTBMAut PROC      FAR

         push      ax
         mov       al,bit4                  ; p©¡znak aut. p©epo‡tu

EdTBMAu2:xor       byte ptr es:[TblIParm],al ; zmˆna p©ep¡na‡e
         pop       ax
EdTBMAu3:call      EdTBMPrp                 ; p©¡prava p©ep¡na‡– pro menu
         cmp       bl," "
         jne       EdTBMAu4
         call      far ptr DispAll          ; nov‚ zobrazen¡ v¨eho
         ret

EdTBMAu4:add       sp,4                     ; zru¨en¡ n vratov‚ adresy
         call      far ptr ClosMnu          ; zru¨en¡ hlavn¡ho menu
         jmp       EdTBMMn8                 ; n vrat z menu

EdTBMAut ENDP

; -----------------------------------------------------------------------------
;        m¢d formul ©e
; -----------------------------------------------------------------------------

EdTBMFrm:push      ax
         mov       al,bit7                  ; p©ep¡na‡ formul ©e
         jmp       short EdTBMAu2

; -----------------------------------------------------------------------------
;        m¢d ladˆn¡
; -----------------------------------------------------------------------------

EdTBMLad:push      ax
         mov       al,bit5                  ; p©ep¡na‡ m¢du ladˆn¡
         jmp       short EdTBMAu2

; -----------------------------------------------------------------------------
;        v˜po‡ty v radi nech
; -----------------------------------------------------------------------------

EdTBMRad:xor       byte ptr es:[TblIParm],bit6 ; p©ep¡na‡ radi n–

EdTBMRd2:test      byte ptr es:[TblIParm],bit4 ; automatick˜ p©epo‡et ?
         jz        EdTBMAu3                 ; nen¡ automatick˜ p©epo‡et

         push      ax
         push      cx
         push      si
         push      di

         mov       si,offset TBLMnu         ; menu tabulky
         call      EdTbPrep                 ; p©epo‡et tabulky

         pop       di
         pop       si
         pop       cx
         pop       ax

         jmp       short EdTBMAu3

; -----------------------------------------------------------------------------
;        p©¡znak ochrany bu¤ky
; -----------------------------------------------------------------------------

EdTBMOch:call      EdTBRO                   ; zmˆna p©¡znaku ochrany
         jmp       short EdTBMAu3

; -----------------------------------------------------------------------------
;        potvrzen¡ operace konverze velikosti ‡¡sel (CY=p©eru¨en¡)
; -----------------------------------------------------------------------------

TBStNTst PROC      NEAR

         push      ax
         push      si

         mov       si,offset TBTstMLn
         call      far ptr Lin0MenF         ; potvrzen¡ operace

         pop       si
         pop       ax
         ret

TBStNTst ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ slov na celou ‡ st ‡¡sla na AL (okno ES) (CY=chyba)
; -----------------------------------------------------------------------------

TBSetNmN PROC      NEAR

; ------ p©¡prava pro celou ‡ st ‡¡sla

         push      ax
         push      dx

         mov       dx,TblXReal              ; za‡ tek ‡¡sla
         add       dx,ds:[TBLNumX]          ; konec ‡¡sla
         sub       al,es:[TBLINumN]         ; po‘adovan  zmˆna
         jnc       TBStNmD1                 ; je zvˆt¨en¡
         cbw                                ; konverze na slovo
         add       dx,ax
         add       dx,ax                    ; oprava adresy dat k ru¨en¡
         jmp       short TBStNmD1

TBSetNmN ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ slov na desetinnou ‡ st ‡¡sla na AL (okno ES) (CY=chyba)
; -----------------------------------------------------------------------------

TBSetNmD PROC      NEAR

; ------ p©¡prava pro desetinnou ‡ st ‡¡sla

         push      ax
         push      dx

         sub       al,es:[TBLINumD]         ; po‘adovan  zmˆna
         mov       dx,TblXReal              ; za‡ tek ‡¡sla

; ------ £schova registr–

TBStNmD1:push      bx
         push      cx
         push      di
         push      bp

; ------ p©¡prava registr–

         cbw                                ; konverze zmˆny AL na slovo
         shl       ax,1                     ; p©evod na bajty
         xchg      ax,cx                    ; CX <- po‘adovan  zmˆna
         mov       ax,ds:[TBLMnuSg]         ; AX <- segment tabulky
         mov       di,TblDat                ; za‡ tek dat tabulky

; ------ p©¡prava po‡tu bunˆk -> BP

         mov       bp,es:[TblBunN]          ; po‡et bunˆk tabulky
         or        bp,bp                    ; je nˆjak  bu¤ka ?
         jz        TBStNmD9                 ; nen¡ ‘ dn  bu¤ka (-> NC)

; ------ test, zda je zvˆt¨en¡ nebo zmen¨en¡

         or        cx,cx                    ; je zvˆt¨en¡ ?
         jns       TBStNmD7                 ; je zvˆt¨en¡ velikosti
         neg       cx                       ; oprava znam‚nka pro zmen¨en¡

; ------ zmen¨en¡ velikosti ‡¡sel v bu¤k ch (CF=p©¡znak operace)

         clc                                ; p©¡znak operace OK
TBStNmD2:pushf
TBStNmD3:add       di,dx                    ; adresa dat k ru¨en¡

         cmp       dx,TblXReal              ; jsou desetiny ?
         jbe       TBStNmD4                 ; jsou desetiny

         add       di,cx                    ; adresa konce ‡¡sla
         mov       bl,es:[di-1]             ; £schova posledn¡ho bajtu ‡¡sla
         sub       di,cx                    ; n vrat za‡ tku dat ke zru¨en¡
         and       byte ptr es:[di-1],not bit7 ; nulov n¡ znam‚nkov‚ho bitu
         and       bl,bit7                  ; znam‚nkov˜ bit ‡¡sla
         or        es:[di-1],bl             ; oprava znam‚nkov‚ho bitu

TBStNmD4:call      far ptr DelDat           ; zru¨en¡ dat
         sub       di,dx                    ; n vrat za‡ tku bu¤ky
         sub       es:[di+TblXOffs],cx      ; sn¡‘en¡ velikosti bu¤ky
         add       di,es:[di+TblXOffs]      ; adresa dal¨¡ bu¤ky
         dec       bp                       ; ‡¡ta‡ bunˆk
         jnz       TBStNmD3                 ; modifikace dal¨¡ bu¤ky
         popf
         jnc       TBStNmD9                 ; operace OK
TBStNmD5:call      far ptr MemErr           ; chyba pamˆti
         jmp       short TBStNmD9

; ------ chyba pamˆti

TBStNmD6:mov       di,TblDat                ; za‡ tel dat tabulky
         sub       bp,es:[TblBunN]          ; - po‡et zpracovan˜ch bunˆk
         neg       bp                       ; oprava znam‚nka
         or        bp,bp                    ; byla nˆjak  bu¤ka ?
         stc                                ; p©¡znak chyby pamˆti
         jz        TBStNmD5                 ; nebyla ‘ dn  bu¤ka
         jmp       short TBStNmD2           ; zmen¨en¡ registr– zpˆt

; ------ zvˆt¨en¡ velikosti ‡¡sel

TBStNmD7:add       di,dx                    ; adresa dat k vlo‘en¡
         call      far ptr InsDat           ; vlo‘en¡ dat
         jc        TBStNmD6                 ; chyba pamˆti

         xchg      ax,bx                    ; BX <- £schova ‡¡sla segmentu
         push      cx

         mov       al,0                     ; nulovac¡ bajt

         cmp       dx,TblXReal              ; jsou desetiny ?
         jbe       TBStNmD8                 ; jsou desetiny

         test      byte ptr es:[di-1],bit7  ; z porn‚ ‡¡slo ?
         jz        TBStNmD8                 ; nen¡ to z porn‚ ‡¡slo
         dec       ax                       ; AL <- -1 nulovac¡ bajt

TBStNmD8:cld
         rep       stosb                    ; vynulov n¡ ‡¡sla

         pop       cx
         xchg      ax,bx                    ; AX <- n vrat ‡¡sla segmentu
         sub       di,cx                    ; n vrat m¡sta k vlo‘en¡ dat

         sub       di,dx                    ; n vrat za‡ tku bu¤ky
         add       es:[di+TblXOffs],cx      ; zv˜¨en¡ velikosti bu¤ky
         add       di,es:[di+TblXOffs]      ; adresa dal¨¡ bu¤ky
         dec       bp                       ; ‡¡ta‡ bunˆk
         jnz       TBStNmD7                 ; modifikace dal¨¡ bu¤ky
         clc                                ; p©¡znak operace OK

; ------ n vrat registr–

TBStNmD9:pop       bp
         pop       di
         pop       cx
         pop       bx

         pop       dx
         pop       ax
         ret

TBSetNmD ENDP

; -----------------------------------------------------------------------------
;        zad n¡ hesla
; -----------------------------------------------------------------------------

EdTBHs0  PROC      NEAR

EdTBHs02:call      EdTBHesl                 ; zad n¡ hesla
         jc        EdTBHs09                 ; p©eru¨en¡ operace
         je        EdTBHs09                 ; nebyla zmˆna hesla
         or        byte ptr es:[TBLParm],bit0 ; soubor modifikov n
         cmp       byte ptr es:[TBLHeslN],0 ; je zad no heslo ?
         jne       EdTBHs02                 ; byla zmˆna - opakov n¡ zad n¡
EdTBHs09:ret

EdTBHs0  ENDP

;; -----------------------------------------------------------------------------
;;        Ctrl-F2: nastaven¡ ¨¡©ky sloupce
;; -----------------------------------------------------------------------------
;
;EdTBSir  PROC      NEAR
;
;; ------ p©¡prava k modifikaci ¨¡©ky okna
;
;         mov       di,es:[TBLKurz]          ; bu¤ka s kurzorem
;         and       di,TBLMaskC              ; maska ‡¡sla sloupce
;         add       di,TblSirTb              ; adresa v tabulce ¨¡©ek
;         or        byte ptr ds:[TBLTParm],bit6 ; je nastaven¡ ¨¡©ky sloupce
;
;         test      byte ptr ds:[TBLTParm],bit5 ; je ozna‡ov n¡ bloku ?
;         jnz       EdTBSir9                 ; je ozna‡ov n¡ bloku
;
;         test      byte ptr es:[TblIParm],bit7 ; je m¢d formul ©e ?
;         jnz       EdTBSir9                 ; je m¢d formul ©e
;
;; ------ p©¡prava aktu ln¡ ¨¡©ky sloupce
;
;EdTBSir2:mov       al,es:[di]               ; AL <- aktu ln¡ ¨¡©ka sloupce
;         push      di
;         push      es
;
;         push      ds
;         pop       es                       ; ES <- datov˜ segment
;         mov       di,offset TBLMnHPS+1     ; buffer k ulo‘en¡ ‡¡sla
;         mov       ah,0                     ; barva se neukl d 
;         call      far ptr DekNumB          ; dek¢dov n¡ ‡¡sla do bufferu
;         sub       di,offset TBLMnHPS+1     ; d‚lka textu
;         xchg      ax,di
;         mov       ds:[TBLMnHPS],al         ; d‚lka textu
;
;         pop       es
;         pop       di
;
;; ------ zobrazen¡ okna a ‡ek n¡ na kl vesu
;
;         call      far ptr DispMnu          ; zobrazen¡ okna
;         call      far ptr InpChar          ; vstup znaku z kl vesnice -> BX
;         jc        EdTBSir9                 ; ESC
;
;; ------ skok na obsluhu kl vesy
;
;         call      far ptr JumpBX           ; skok na obsluhu kl vesy
;
;         dw        4b00h,EdTBSir3           ; vlevo
;         dw        4d00h,EdTBSir4           ; vpravo
;         dw        1c0dh,EdTBSir9           ; Enter
;         dw        0,EdTBSir2
;
;; ------ vlevo
;
;EdTBSir3:cmp       byte ptr es:[di],1       ; je ji‘ minim ln¡ ¨¡©ka ?
;         jbe       EdTBSir2                 ; je ji‘ minim ln¡ ¨¡©ka
;         dec       byte ptr es:[di]         ; sn¡‘en¡ ¨¡©ky
;         jmp       short EdTBSir2
;
;; ------ vpravo
;
;EdTBSir4:cmp       byte ptr es:[di],TBLMaxS ; maxim ln¡ ¨¡©ka
;         jae       EdTBSir2                 ; je ji‘ maxim ln¡ ¨¡©ka
;         inc       byte ptr es:[di]         ; zv˜¨en¡ ¨¡©ky
;         jmp       short EdTBSir2
;
;; ------ konec obsluhy
;
;EdTBSir9:and       byte ptr ds:[TBLTParm],not bit6 ; nen¡ nastaven¡ ¨¡©ky
;         ret
;
;EdTBSir  ENDP

; -----------------------------------------------------------------------------
;        Ctrl-F8: z kaz z pisu do bu¤ky (je vol no z obsluhy menu F10 !)
; -----------------------------------------------------------------------------

EdTBRO   PROC      NEAR

         test      byte ptr ds:[TBLTParm],bit5 ; je ozna‡ov n¡ bloku ?
         jnz       EdTBRO4                  ; je ozna‡ov n¡ bloku

         test      byte ptr es:[TblIParm],bit7 ; je m¢d formul ©e ?
         jnz       EdTBRO4                  ; je m¢d formul ©e

         test      byte ptr es:[TBLParm],bit4 ; je kurzor platn  bu¤ka ?
         jz        EdTBRO4                  ; nen¡ platn  bu¤ka
         push      di
         mov       di,es:[TBLKurzA]         ; adresa kurzoru
         or        byte ptr es:[TBLParm],bit0 ; p©¡znak modifikace tabulky
         xor       byte ptr es:[TBLParm],bit5 ; zmˆna p©¡znaku R/O
         xor       byte ptr es:[di+TBLXParm],bit7 ; p©¡znak uzam‡en¡ bu¤ky
         pop       di
EdTBRO4: ret

EdTBRO   ENDP

; -----------------------------------------------------------------------------
;        F2: ulo‘en¡ (CY=chyba, p©eru¨en¡ operace)
; -----------------------------------------------------------------------------

EdTBUloz PROC      NEAR

         test      byte ptr ds:[TBLTParm],bit5 ; je ozna‡ov n¡ bloku ?
         jnz       EdTBUlz9                 ; je ozna‡ov n¡ bloku

         push      ax
         push      bx
         push      cx
         push      si
         push      di

         call      EdTBKNl                  ; nulov n¡ p©¡znak– pro v˜po‡et

         push      es
         les       si,cs:[TablADR]          ; adresa jm‚na souboru
         call      far ptr ModiWDir         ; aktualizace oken
         call      far ptr CreatFil         ; vytvo©en¡ souboru
         pop       es
         jc        EdTBUlz7

         call      TBLZakod                 ; zak¢dov n¡ souboru tabulky

         mov       si,TblTabul
         mov       cx,es:[0]
         sub       cx,si
         call      far ptr WritFile

         pushf

         call      TBLDekod                 ; odk¢dov n¡ souboru tabulky

         call      far ptr ClosFile
         popf
         jc        EdTBUlz7                 ; byla chyba

         and       byte ptr es:[TBLParm],not bit0 ; nulov n¡ p©¡znaku modifikace
         jmp       short EdTBUlz8

EdTBUlz7:push      di
         mov       di,offset TBLErWrt
         call      far ptr Lin0MenP
         pop       di

EdTBUlz8:pop       di
         pop       si
         pop       cx
         pop       bx
         pop       ax
EdTBUlz9:ret

EdTBUloz ENDP

; -----------------------------------------------------------------------------
;        Insert: vlo‘en¡ nov‚ho © dku/sloupce
; -----------------------------------------------------------------------------

EdTBIns  PROC      NEAR

; ------ test, zda je operace povolena

         test      byte ptr ds:[TBLTParm],bit5 ; je ozna‡ov n¡ bloku ?
         jnz       EdTBIns1                 ; je ozna‡ov n¡ bloku
         test      byte ptr es:[TblIParm],bit7 ; je m¢d formul ©e ?
         jz        EdTBIns2                 ; nen¡ m¢d formul ©e
EdTBIns1:ret

; ------ volba vlo‘en¡ © dku/sloupce

EdTBIns2:push      si
         mov       si,offset TBInsMLn       ; menu volby © dku/sloupce
         call      far ptr Lin0Menu         ; volba vlo‘en¡ © dku/sloupce
         pop       si
         jc        EdTBIns1                 ; p©eru¨en¡ operace

; ------ p©¡prava pro konverzi bunˆk

         or        byte ptr ds:[TBLTPrm2],bit1+bit4+bit6 ; je pot©ebn˜ p©epo‡et
         and       byte ptr ds:[TBLTPrm2],not bit5 ; relativn¡ v‘dy ne

; ------ test, zda se vkl d  © dek nebo sloupec

         mov       dx,es:[TBLKurz]          ; kurzor
         mov       di,TblDat                ; za‡ tek dat tabulky
         mov       cx,es:[TblBunN]          ; po‡et bunˆk tabulky
         jcxz      EdTBIns1                 ; nejsou ‘ dn‚ bu¤ky
         or        byte ptr es:[TBLParm],bit0 ; soubor modifikov n
         cmp       byte ptr ds:[TBInsMLn+MnuAkt],1 ; vlo‘en¡ © dku ?
         je        EdTBIns5                 ; vlo‘en¡ © dku

; ------ vlo‘en¡ sloupce

         and       dl,TBLMaskC              ; maskov n¡ ‡¡sla sloupce
EdTBIns3:mov       al,es:[di+TblXBunk]      ; ‡¡slo bu¤ky
         and       al,TBLMaskC              ; ‡¡slo sloupce bu¤ky
         cmp       al,dl                    ; je za kurzorem ?
         jb        EdTBIns4                 ; nen¡ za kurzorem
         cmp       al,TBLMaxC               ; je ji‘ maxim ln¡ ‡¡slo sloupce ?
         jae       EdTBIns4                 ; je ji‘ maxim ln¡ ‡¡slo sloupce
         inc       byte ptr es:[di+TblXBunk] ; zv˜¨en¡ sloupce s bu¤kou
EdTBIns4:add       di,es:[di+TblXOffs]      ; adresa dal¨¡ bu¤ky
         loop      EdTBIns3                 ; dal¨¡ bu¤ka

; ------ p©¡prava ukazatele pro korekci ‡¡sel bunˆk

         mov       bx,es:[TBLKurz]          ; kurzor
         and       bx,TBLMaskC              ; po‡ tek bloku (© dek 0)
         mov       dx,TBLMaxC+TBLMaxR*TBLNasR ; maxim ln¡ bu¤ka - konec bloku
         call      far ptr TInitBlk         ; inicializace bloku
         mov       bx,1                     ; smˆr posunu vpravo
         jmp       short EdTBIns7           ; konverze bunˆk

; ------ vlo‘en¡ © dku

EdTBIns5:and       dx,TBLMaskR              ; maska ‡¡sla © dku s kurzorem
EdTBIn52:mov       ax,es:[di+TblXBunk]      ; ‡¡slo bu¤ky
         and       ax,TBLMaskR              ; ‡¡slo © dku bu¤ky
         cmp       ax,dx                    ; je za kurzorem ?
         jb        EdTBIns6                 ; nen¡ za kurzorem
         cmp       ax,TBLMaxR*TBLNasR       ; je ji‘ maxim ln¡ ‡¡slo © dku ?
         jae       EdTBIns6                 ; je ji‘ maxim ln¡ ‡¡slo © dku
         add       word ptr es:[di+TblXBunk],TBLNasR ; zv˜¨en¡ ‡¡sla © dku
EdTBIns6:add       di,es:[di+TblXOffs]      ; adresa dal¨¡ bu¤ky
         loop      EdTBIn52                 ; dal¨¡ bu¤ka

; ------ p©¡prava ukazatele pro korekci ‡¡sel bunˆk

         mov       bx,es:[TBLKurz]          ; kurzor
         and       bx,TBLMaskR              ; po‡ tek bloku (sloupec 0)
         mov       dx,TBLMaxC+TBLMaxR*TBLNasR ; maxim ln¡ bu¤ka - konec bloku
         call      far ptr TInitBlk         ; inicializace bloku
         mov       bx,TBLNasR               ; smˆr posunu dol–

; ------ korekce ‡¡sla bunˆk

EdTBIns7:mov       di,TblDat                ; za‡ tek dat tabulky
         mov       cx,es:[TblBunN]          ; po‡et bunˆk tabulky
EdTBIns8:call      TBTrans                  ; p©epo‡et bu¤ky
         add       di,es:[di+TblXOffs]      ; zv˜¨en¡ ukazatele adresy
         loop      EdTBIns8

         call      far ptr TDIniBlk         ; ukon‡en¡ pr ce s blokem
         ret

EdTBIns  ENDP

; -----------------------------------------------------------------------------
;        Delete: zru¨en¡ © dku, sloupce, bu¤ky
; -----------------------------------------------------------------------------

EdTBDel  PROC      NEAR

; ------ test, zda je operace povolena

         test      byte ptr ds:[TBLTParm],bit5 ; je ozna‡ov n¡ bloku ?
         jnz       EdTBDel1                 ; je ozna‡ov n¡ bloku
         test      byte ptr es:[TblIParm],bit7 ; je m¢d formul ©e ?
         jz        EdTBDel2                 ; nen¡ m¢d formul ©e
EdTBDel1:ret

; ------ p©¡znak povolen¡ ru¨en¡ bu¤ky s kurzorem

EdTBDel2:or        byte ptr ds:[TBDelMLB],bit1 ; bu¤ka nepovolena
         test      byte ptr es:[TBLParm],bit4 ; je kurzor platn˜ ?
         jz        EdTBDl22                 ; nen¡ platn˜
         test      byte ptr es:[TBLParm],bit5 ; je kurzor R/O ?
         jnz       EdTBDl22                 ; kurzor je R/O
         and       byte ptr ds:[TBDelMLB],not bit1 ; bu¤ka povolena

; ------ volba operace ru¨en¡

EdTBDl22:push      si
         mov       si,offset TBDelMLn
         call      far ptr Lin0MenF         ; volba operace
         pop       si
         jc        EdTBDel1                 ; p©eru¨en¡ operace

; ------ rozli¨en¡ po‘adovan‚ operace

         mov       bx,es:[TBLKurz]          ; bu¤ka s kurzorem
         cmp       byte ptr ds:[TBDelMLn+MnuAkt],2 ; zru¨en¡ © dku ?
         ja        EdTBDel3                 ; ru¨en¡ sloupce
         je        EdTBDel6                 ; ru¨en¡ © dku

; ------ zru¨en¡ bu¤ky pod kurzorem

         mov       ax,es:[TBLKurz]          ; bu¤ka s kurzorem
         call      TBLSrc                   ; nalezen¡ adresy kurzoru -> DI
         jc        EdTBDel1                 ; bu¤ka nenalezena
         test      byte ptr es:[di+TBLXParm],bit7 ; je bu¤ka uzam‡ena ?
         jnz       EdTBDel1                 ; bu¤ka je uzam‡ena
         call      TBLBDel                  ; zru¨en¡ star‚ bu¤ky
         jmp       EdTBVyr8                 ; p©epo‡et tabulky

; ------ zru¨en¡ sloupce

EdTBDel3:and       bx,TBLMaskC              ; po‡ tek bloku (© dek 0)
         mov       dx,bx                    ; po‡ te bloku
         or        dx,TBLMaxR*TBLNasR       ; konec bloku (maxim ln¡ © dek)
         call      far ptr TInitBlk         ; inicializace bloku
         call      EdTBRus                  ; zru¨en¡ bloku
         jc        EdTBDl61                 ; chyba - chr nˆn‚ bu¤ky

; ------ p©¡prava pro korekci bunˆk

         or        byte ptr ds:[TBLTPrm2],bit1+bit4+bit6 ; je pot©ebn˜ p©epo‡et
         and       byte ptr ds:[TBLTPrm2],not bit5 ; relativn¡ v‘dy ne

; ------ ru¨en¡ sloupce

         mov       dx,es:[TBLKurz]          ; kurzor
         and       dl,TBLMaskC              ; maskov n¡ ‡¡sla sloupce
         mov       di,TblDat                ; za‡ tek dat tabulky
         mov       cx,es:[TblBunN]          ; po‡et bunˆk tabulky
         jcxz      EdTBDl62                 ; nen¡ dal¨¡ bu¤ka
EdTBDel4:mov       al,es:[di+TblXBunk]      ; ‡¡slo bu¤ky
         and       al,TBLMaskC              ; ‡¡slo sloupce bu¤ky
         cmp       al,dl                    ; je za kurzorem ?
         jbe       EdTBDel5                 ; nen¡ za kurzorem
         dec       byte ptr es:[di+TblXBunk] ; sn¡‘en¡ sloupce s bu¤kou
EdTBDel5:add       di,es:[di+TblXOffs]      ; adresa dal¨¡ bu¤ky
         loop      EdTBDel4                 ; dal¨¡ bu¤ka

; ------ p©¡prava ukazatele pro korekci ‡¡sel bunˆk

         mov       bx,es:[TBLKurz]          ; kurzor
         and       bx,TBLMaskC              ; po‡ tek bloku (© dek 0)
         inc       bx                       ; n sleduj¡c¡ sloupec
         mov       dx,TBLMaxC+TBLMaxR*TBLNasR ; maxim ln¡ bu¤ka - konec bloku
         call      far ptr TInitBlk         ; inicializace bloku
         mov       bx,-1                    ; smˆr posunu vlevo
         jmp       short EdTBDel8           ; konverze bunˆk

; ------ zru¨en¡ © dku

EdTBDel6:and       bx,TBLMaskR              ; po‡ tek bloku (sloupec 0)
         mov       dx,bx                    ; po‡ te bloku
         or        dx,TBLMaxC               ; konec bloku (maxim ln¡ sloupec)
         call      far ptr TInitBlk         ; inicializace bloku
         call      EdTBRus                  ; zru¨en¡ bloku
EdTBDl61:jc        EdTBDel9                 ; chyba - chr nˆn‚ bu¤ky

; ------ p©¡prava pro korekci bunˆk

         or        byte ptr ds:[TBLTPrm2],bit1+bit4+bit6 ; je pot©ebn˜ p©epo‡et
         and       byte ptr ds:[TBLTPrm2],not bit5 ; relativn¡ v‘dy ne

; ------ zru¨en¡ © dku

         mov       dx,es:[TBLKurz]          ; kurzor
         and       dx,TBLMaskR              ; maska ‡¡sla © dku s kurzorem
         mov       di,TblDat                ; za‡ tek dat tabulky
         mov       cx,es:[TblBunN]          ; po‡et bunˆk tabulky
EdTBDl62:jcxz      EdTBDel9                 ; nen¡ dal¨¡ bu¤ka
EdTBDel7:mov       ax,es:[di+TblXBunk]      ; ‡¡slo bu¤ky
         and       ax,TBLMaskR              ; ‡¡slo © dku bu¤ky
         cmp       ax,dx                    ; je za kurzorem ?
         jbe       EdTBDl74                 ; nen¡ za kurzorem
         sub       word ptr es:[di+TblXBunk],TBLNasR ; sn¡‘en¡ ‡¡sla © dku
EdTBDl74:add       di,es:[di+TblXOffs]      ; adresa dal¨¡ bu¤ky
         loop      EdTBDel7                 ; dal¨¡ bu¤ka

; ------ p©¡prava ukazatele pro korekci ‡¡sel bunˆk

         mov       bx,es:[TBLKurz]          ; kurzor
         and       bx,TBLMaskR              ; po‡ tek bloku (sloupec 0)
         mov       dx,TBLMaxC+TBLMaxR*TBLNasR ; maxim ln¡ bu¤ka - konec bloku
         call      far ptr TInitBlk         ; inicializace bloku
         mov       bx,-TBLNasR              ; smˆr posunu nahoru

; ------ korekce ‡¡sla bunˆk

EdTBDel8:mov       di,TblDat                ; za‡ tek dat tabulky
         mov       cx,es:[TblBunN]          ; po‡et bunˆk tabulky
EdTBDl82:call      TBTrans                  ; p©epo‡et bu¤ky
         add       di,es:[di+TblXOffs]      ; zv˜¨en¡ ukazatele adresy
         loop      EdTBDl82

EdTBDel9:call      far ptr TDIniBlk         ; ukon‡en¡ pr ce s blokem
         ret

EdTBDel  ENDP

; -----------------------------------------------------------------------------
;        F3: operace s blokem
; -----------------------------------------------------------------------------

EdTBBlk0:call      EdTBMKur                 ; veden¡ kurzoru my¨¡

EdTBBlk  PROC      NEAR

; ------ test, zda je operace povolena

         test      byte ptr es:[TblIParm],bit7 ; je m¢d formul ©e ?
         jnz       EdTBBlk1                 ; je m¢d formul ©e - z kaz
         test      byte ptr ds:[TBLTParm],bit5 ; je ji‘ ozna‡ov n¡ bloku ?
         jz        EdTBBlk2                 ; nen¡ ozna‡ov n¡ bloku
         jmp       short EdTBBlk3           ; ukon‡en¡ ozna‡ov n¡

EdTBBlk1:ret

; ------ zah jen¡ operace ozna‡ov n¡ bloku

EdTBBlk2:mov       bx,es:[TBLKurz]          ; bu¤ka s kurzorem
         mov       dx,bx
         mov       ds:[TBBlokO],bx          ; po‡ tek bloku
         call      far ptr TInitBlk         ; inicializace operace s blokem
         ret

; ------ (sem se sk ‡e odjinud) volba operace p©i ukon‡en¡ ozna‡ov n¡ bloku

EdTBBlk3:test      byte ptr ds:[TBLTParm],bit3 ; je ji‘ konec bloku ozna‡en ?
         jnz       EdTBBl32                 ; je ji‘ konec bloku
         push      si
         mov       si,offset TBBlkMnu
         call      far ptr CentMenu         ; vyst©edˆn¡ okna menu
         mov       dl,ds:[TBLTParm]         ; p©ep¡na‡e
         call      far ptr SetSwch          ; nastaven¡ p©ep¡na‡–
         call      far ptr VertMenu         ; volba operace s blokem
         test      byte ptr ds:[MouseKey],bit1 ; je prav‚ tla‡¡tko my¨i ?
         jz        EdTBBl31                 ; nen¡ prav‚ tla‡¡tko my¨i
         call      far ptr TDIniBlk         ; konec operace s blokem
EdTBBl31:pop       si
         ret

EdTBBl32:jmp       EdTBKop2                 ; kop¡rov n¡ bloku

; ------ p©ep¡na‡ "Linky"

EdTBBl37 PROC      FAR

         xor       byte ptr ds:[TBLTParm],bit0 ; zmˆna p©ep¡na‡e
EdTBBl38:mov       dl,ds:[TBLTParm]         ; p©ep¡na‡e
         call      far ptr SetSwch          ; nov‚ nastaven¡ p©¡znak–
         call      far ptr DispMnu          ; nov‚ zobrazen¡ okna menu
         ret

EdTBBl37 ENDP

; ------ p©ep¡na‡ "Sloupce"

EdTBBl39:xor       byte ptr ds:[TBLTParm],bit1 ; zmˆna p©ep¡na‡e
         jmp       short EdTBBl38

; ------ zvolena operace

EdTBBlk4:add       sp,4                     ; zru¨en¡ n vratov‚ adresy
         mov       bx,ds:[si+MnuAkt]        ; zvolen  polo‘ka
         call      far ptr ClosMnu          ; uzav©en¡ okna
         pop       si                       ; n vrat SI

; ------ skok na zvolenou funkci

         shl       bx,1                     ; zvolen  polo‘ka * 2
         call      word ptr cs:[EdTBBlTF+bx-2] ; obsluha funkce
         jc        EdTBBlk5                 ; p©eru¨en¡ operace
         call      far ptr TDIniBlk         ; konec operace s blokem
EdTBBlk5:ret

EdTBBlTF dw        EdTBKop                  ; Kopie
         dw        EdTBNap                  ; Naplnˆn¡
         dw        EdTBOdem                 ; Odemknut¡
         dw        EdTBPres                 ; P©esun
         dw        EdTBRus                  ; Ru¨en¡
         dw        EdTBExp                  ; eXport
         dw        EdTBZamk                 ; Zamknout

;EdTBBlk7:
;
;         ret

EdTBBlk  ENDP

; -----------------------------------------------------------------------------
;        zamknut¡ bunˆk v bloku
; -----------------------------------------------------------------------------

EdTBZamk PROC      NEAR

         mov       cl,bit7                  ; p©¡znak uzam‡en¡ bunˆk
         jmp       short EdTBOdm1           ; nastaven¡ bunˆk

EdTBZamk ENDP

; -----------------------------------------------------------------------------
;        odemknut¡ bunˆk v bloku
; -----------------------------------------------------------------------------

EdTBOdem PROC      NEAR

         mov       cl,0                     ; p©¡znak odemknut¡ bunˆk
EdTBOdm1:call      TBResBlk                 ; resetov n¡ vyhled v n¡ bunˆk
EdTBOdm2:call      far ptr TBGetBlk         ; poskytnut¡ bu¤ky pro operaci
         jc        EdTBOdm6                 ; nen¡ dal¨¡ bu¤ka
         mov       ch,es:[di+TBLXParm]      ; parametry bu¤ky
         and       ch,bit7                  ; p©¡znak uzam‡en¡ bu¤ky
         cmp       ch,cl                    ; je ji‘ bu¤ka OK ?
         je        EdTBOdm2                 ; bu¤ka je ji‘ OK
         or        byte ptr es:[TBLParm],bit0 ; p©¡znak modifikace tabulky
         xor       byte ptr es:[di+TBLXParm],bit7 ; p©¡znak uzam‡en¡ bu¤ky
         cmp       ax,es:[TBLKurz]          ; je to kurzor ?
         jne       EdTBOdm2                 ; nen¡ to kurzor
         xor       byte ptr es:[TBLParm],bit5 ; zmˆna p©¡znaku R/O
         jmp       short EdTBOdm2           ; dal¨¡ bu¤ka

EdTBOdm6:clc                                ; p©¡znak ukon‡en¡ operace
   ;stc                                ; p©¡znak pokra‡ov n¡ operace
         ret

EdTBOdem ENDP

; -----------------------------------------------------------------------------
;        zru¨en¡ bunˆk v ozna‡en‚m bloku (okno ES, DS:SI) (CY=p©eru¨en¡ operace)
; -----------------------------------------------------------------------------

EdTBRus  PROC      NEAR

; ------ zobrazen¡ hl ¨en¡ o ru¨en¡ bloku

         push      si
         mov       si,offset TBRusHls
         call      far ptr InfDisp0
         pop       si

; ------ test, zda jsou bu¤ky chr nˆn‚ proti modifikaci

         call      EdTBBTst                 ; test, zda jsou chr nˆn‚ bu¤ky
         jc        EdTBRus9                 ; p©eru¨en¡ operace

; ------ zru¨en¡ bunˆk v bloku

         call      TBResBlk                 ; resetov n¡ vyhled v n¡ bunˆk
EdTBRus2:call      far ptr TBGetBlk         ; poskytnut¡ bu¤ky pro operaci
         cmc
         jnc       EdTBRus9                 ; nen¡ dal¨¡ bu¤ka
         or        byte ptr ds:[TBLTParm],bit2 ; p©¡znak zru¨en¡ bu¤ky
         or        byte ptr ds:[TBLTPrm2],bit1 ; je pot©ebn˜ p©epo‡et
         call      TBLBDel                  ; zru¨en¡ bu¤ky ES:DI
         jmp       short EdTBRus2           ; dal¨¡ bu¤ka

EdTBRus9:call      far ptr InfoClos
         ret

EdTBRus  ENDP

; -----------------------------------------------------------------------------
;        naplnˆn¡ bloku okna DS:SI/ES
; -----------------------------------------------------------------------------
; lok ln¡ promˆnn‚: SS:[BP-2] (2) adresa menu okna SI
;                   SS:[BP-4] (2) adresa okna ES
;                   SS:[BP-6] (2) d‚lka ukl dan‚ bu¤ky (0=nen¡ bu¤ka)
;                   SS:[BP-8] (2) ukazatel sloupce ‡¡sla bu¤ky
;                   SS:[BP-10] (2) ukazatel © dku ‡¡sla bu¤ky (*posun)
;                   SS:[BP-12] (2) adresa v tabulce
; -----------------------------------------------------------------------------

EdTBNap  PROC      NEAR

; ------ potvrzen¡ operace

         push      si
         mov       si,offset TBNapMLn
         call      far ptr Lin0MenF
         pop       si
         jnc       EdTBNap2                 ; pokra‡ov n¡
         ret

; ------ £schova registr–

EdTBNap2:push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         mov       bp,sp

; ------ p©¡prava lok ln¡ch promˆnn˜ch

         sub       sp,12 + TBLMaxS+30       ; rezerva pro bu¤ku (bez ‡¡sla)
         sub       sp,ds:[TBLXText]         ; rezerva pro ‡¡slo v bu¤ce
         mov       ss:[bp-2],si             ; adresa menu
         mov       ss:[bp-4],es             ; adresa okna
         mov       word ptr ss:[bp-6],0     ; nen¡ bu¤ka
         mov       ax,ds:[TBBlokCB]         ; sloupec po‡ tku bloku
         mov       ss:[bp-8],ax             ; ukazatel sloupce bu¤ky
         mov       ax,ds:[TBBlokRB]         ; © dek po‡ tku bloku * posun
         mov       ss:[bp-10],ax            ; ukazatel © dku bu¤ky * posun

; ------ p©¡prava pro konverzi bunˆk ve v˜razech

         and       byte ptr ds:[TBLTPrm2],not bit4+bit6 ; nen¡ blok
         or        byte ptr ds:[TBLTPrm2],bit5 ; p©epo‡et relativn¡ch bunˆk

; ------ nalezen¡ vzorov‚ bu¤ky

         or        ax,ds:[TBBlokCB]         ; ‡¡slo po‡ te‡n¡ bu¤ky
         call      TBLSrc                   ; vyhled n¡ po‡ te‡n¡ bu¤ky
         mov       ss:[bp-12],di            ; adresa v tabulce
         jc        EdTBNap3                 ; bu¤ka nenalezena

; ------ p©¡prava d‚lky bu¤ky

         mov       cx,es:[di+TblXOffs]      ; offset dal¨¡ bu¤ky
         mov       ax,ds:[TBLXText]         ; d‚lka z hlav¡ s ‡¡slem v bu¤ce
         add       ax,TBLMaxS+20            ; asi tak maximum
         cmp       cx,ax                    ; je d‚lka OK ?
         jbe       EdTBNp22                 ; d‚lka je OK
         xchg      ax,cx                    ; CX <- omezen¡ d‚lky bu¤ky
EdTBNp22:mov       ss:[bp-6],cx             ; d‚lka bu¤ky

; ------ £schova vzorov‚ bu¤ky do bufferu

         mov       si,sp                    ; SI <- buffer v z sobn¡ku

         push      cx
EdTBNp23:mov       al,es:[di]
         mov       ss:[si],al
         inc       si
         inc       di
         loop      EdTBNp23
         pop       cx

         mov       si,sp                    ; SI <- buffer v z sobn¡ku
         mov       ss:[si],cx               ; nov  d‚lka bu¤ky

; ------ zru¨en¡ p–vodn¡ho obsahu bloku

EdTBNap3:mov       si,ss:[bp-2]             ; SI <- adresa menu
         call      EdTBRus                  ; zru¨en¡ bunˆk v bloku
         jc        EdTBNp42                 ; p©eru¨en¡ operace
         cmp       word ptr ss:[bp-6],0     ; je vzorov  bu¤ka ?
         je        EdTBNp42                 ; nen¡ vzorov  bu¤ka

; ------ hl ¨en¡ o plnˆn¡ bloku

         mov       si,offset PlnHlas
         call      far ptr InfDisp0

; ------ vytvo©en¡ m¡sta pro bu¤ku

EdTBNap4:mov       di,ss:[bp-12]            ; DI <- adresa v tabulce
         mov       si,ss:[bp-2]             ; SI <- adresa menu
         mov       cx,ss:[bp-6]             ; CX <- d‚lka bu¤ky
         mov       ax,ds:[si+TbMnuSeg]      ; segment bufferu tabulky
         call      far ptr InsDat           ; vlo‘en¡ bu¤ky
         jnc       EdTBNap5                 ; operace OK

; ------ chyba pamˆti

         call      far ptr MemErr           ; chyba pamˆti
EdTBNp42:jmp       EdTBNap9

; ------ p©¡znak modifikace tabulky

EdTBNap5:or        byte ptr es:[TBLParm],bit0 ; p©¡znak modifikace tabulky
         or        byte ptr ds:[TBLTPrm2],bit1 ; je pot©ebn˜ p©epo‡et
         inc       word ptr es:[TblBunN]    ; zv˜¨en¡ po‡tu bunˆk

; ------ p©¡prava ‡¡sla bu¤ky

         mov       ax,ss:[bp-8]             ; ukazatel ‡¡sla sloupce bu¤ky
         or        ax,ss:[bp-10]            ; ukazatel ‡¡sla © dku bu¤ky
         mov       si,sp                    ; adresa bu¤ky v z sobn¡ku
         mov       ss:[si+TblXBunk],ax      ; nastaven¡ ‡¡sla bu¤ky
         xchg      ax,bx                    ; BX <- ‡¡slo aktu ln¡ bu¤ky

; ------ p©enesen¡ obsahu bu¤ky

EdTBNap6:mov       al,ss:[si]
         mov       es:[di],al
         inc       si
         inc       di
         loop      EdTBNap6

; ------ posun obsahu bu¤ky

         sub       di,ss:[bp-6]             ; n vrat za‡ tku bu¤ky
         mov       si,ss:[bp-2]             ; SI <- adresa menu
         sub       bx,ds:[TBBlokCB]         ; vzd lenost od po‡ te‡n¡ho sloupce
         sub       bx,ds:[TBBlokRB]         ; vzd lenost od po‡ te‡n¡ho © dku

         call      TBTransX                 ; p©epo‡et bu¤ky

         add       di,es:[di+TblXOffs]      ; zv˜¨en¡ ukazatele adresy

; ------ zv˜¨en¡ ‡¡sla sloupce bu¤ky

         inc       word ptr ss:[bp-8]       ; zv˜¨en¡ ‡¡sla sloupce bu¤ky
         mov       ax,ss:[bp-8]             ; ukazatel ‡¡sla sloupce bu¤ky
         cmp       ax,ds:[TBBlokCE]         ; je za sloupcem konce bloku ?
         jbe       EdTBNap7                 ; sloupec je OK
         mov       ax,ds:[TBBlokCB]         ; sloupec po‡ tku bloku
         mov       ss:[bp-8],ax             ; nov˜ ukazatel sloupce

; ------ zv˜¨en¡ ‡¡sla © dku bu¤ky

         add       word ptr ss:[bp-10],TBLNasR ; posun ‡¡sla © dku bu¤ky
         mov       ax,ss:[bp-10]            ; ukazatel ‡¡sla © dku bu¤ky
         cmp       ax,ds:[TBBlokRE]         ; je za © dkem konce bloku ?
         ja        EdTBNap8                 ; konec operace s blokem

; ------ nalezen¡ nov‚ adresy k ulo‘en¡ bu¤ky

EdTBNap7:cmp       di,es:[0]                ; je platn  adresa ?
         jae       EdTBNp76                 ; nen¡ dal¨¡ bu¤ka
         mov       ax,ss:[bp-8]             ; ‡¡slo sloupce bu¤ky
         or        ax,ss:[bp-10]            ; + ‡¡slo © dku bu¤ky
         cmp       ax,es:[di+TblXBunk]      ; je pot©eba posunout adresu ?
         jbe       EdTBNp76                 ; adresa je OK
         add       di,es:[di+TblXOffs]      ; adresa dal¨¡ bu¤ky
         jmp       short EdTBNap7

EdTBNp76:mov       ss:[bp-12],di            ; nov  adresa bu¤ky v tabulce
         jmp       EdTBNap4                 ; vlo‘en¡ dal¨¡ bu¤ky

; ------ n vrat registr–

EdTBNap8:clc                                ; p©¡znak operace OK
EdTBNap9:mov       sp,bp
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         call      far ptr InfoClos
         ret

EdTBNap  ENDP

; -----------------------------------------------------------------------------
;        kopie a p©esun bloku
; -----------------------------------------------------------------------------

; ------ zah jen¡ ozna‡ov n¡ c¡le

EdTBPres:or        byte ptr ds:[TBLTPrm2],bit7 ; je p©esun
         jmp       short EdTBKop1

EdTBKop  PROC      NEAR

         and       byte ptr ds:[TBLTPrm2],not bit7 ; je kop¡rov n¡
EdTBKop1:or        byte ptr ds:[TBLTParm],bit3 ; ozna‡ov n¡ konce bloku
EdTBKp12:stc                                ; p©¡znak pokra‡ov n¡ v operaci
         ret

; ====== Extern¡ vstup po volbˆ c¡le operace !!!

; ------ test p©ekr˜v n¡ c¡lov‚ho bloku

EdTBKop2:mov       ax,es:[TBLKurz]          ; kurzor (=c¡l operace)
         and       ax,TBLMaskC              ; maska ‡¡sla sloupce
         cmp       ax,ds:[TBBlokCE]         ; je za sloupcem konce bloku ?
         ja        EdTBKop3                 ; bloky se nep©ekr˜vaj¡
         add       ax,ds:[TBBlokCE]         ; + sloupec konce bloku
         sub       ax,ds:[TBBlokCB]         ; - sloupec po‡ tku bloku
         cmp       ax,ds:[TBBlokCB]         ; je p©ed po‡ tkem bloku ?
         jb        EdTBKop3                 ; je p©ed po‡ tkem bloku OK

         mov       ax,es:[TBLKurz]          ; kurzor (=c¡l operace)
         and       ax,TBLMaskR              ; maska ‡¡sla © dku
         cmp       ax,ds:[TBBLokRE]         ; je za © dkem konce bloku ?
         ja        EdTBKop3                 ; bloky se nep©ekr˜vaj¡
         mov       bx,ds:[TBBlokRE]         ; © dek konce bloku
         sub       bx,ds:[TBBLokRB]         ; v˜©ka bloku - 1
         add       ax,bx                    ; © dek konce bloku
         jc        EdTBKp22                 ; p©ete‡en¡
         cmp       ax,ds:[TBBlokRB]         ; je p©ed po‡ tkem bloku ?
         jb        EdTBKop3                 ; je p©ed po‡ tkem bloku OK

; ------ chyba - bloky se p©ekr˜vaj¡

EdTBKp22:mov       di,offset TBLErOvr
         call      far ptr Lin0MenP
         ret

; ------ posun bunˆk -> BX

EdTBKop3:mov       ax,es:[TBLKurz]          ; kurzor (=c¡l operace)
         and       ax,TBLMaskC              ; maska ‡¡sla sloupce
         sub       ax,ds:[TBBlokCB]         ; posun od po‡ te‡n¡ho sloupce
         mov       bx,es:[TBLKurz]          ; kurzor (=c¡l operace)
         and       bx,TBLMaskR              ; maska ‡¡sla © dku
         sub       bx,ds:[TBBlokRB]         ; posun od po‡ te‡n¡ho © dku
         add       bx,ax                    ; p©i‡ten¡ posunu pro sloupec

; ------ p©¡prava ke korekci bunˆk

         call      EdTBKNl                  ; nulov n¡ p©¡znak– pro v˜po‡et
         and       byte ptr ds:[TBLTPrm2],not bit4
         or        byte ptr ds:[TBLTPrm2],bit5+bit6 ; relativn¡ v‘dy, abs. blok

; ------ vyhled n¡ bu¤ky k operaci -> DI, AX

         call      TBResBlk                 ; resetov n¡ vyhled v n¡ bunˆk
EdTBKop4:call      far ptr TBGetBlk         ; poskytnut¡ bu¤ky pro operaci
         jnc       EdTBKp41                 ; je dal¨¡ bu¤ka OK
         jmp       EdTBKop7                 ; nen¡ dal¨¡ bu¤ka
EdTBKp41:mov       bp,di                    ; BP <- adresa zdrojov‚ bu¤ky

; ------ vyhled n¡ c¡lov‚ bu¤ky

         add       ax,bx                    ; posun ‡¡sla bu¤ky
         call      TBLSrc                   ; vyhled n¡ c¡lov‚ bu¤ky
         jc        EdTBKop5                 ; bu¤ka nenalezena

; ------ test, zda je c¡lov  bu¤ka chr nˆn  (poprv‚ hl ¨en¡ a pokra‡ov n¡ d le)

         test      byte ptr es:[di+TblXParm],bit7 ; je bu¤ka chr nˆn  ?
         jz        EdTBKp42                 ; bu¤ka nen¡ chr nˆn 
         mov       di,offset TBLErrRO
         call      far ptr Lin0MenP         ; chybov‚ hl ¨en¡, ale pokra‡uje
         jmp       short EdTBKop4           ; dal¨¡ bu¤ka

EdTBKp4A:ret

; ------ zru¨en¡ existuj¡c¡ bu¤ky

EdTBKp42:mov       cx,es:[di+TblXOffs]      ; velikost ru¨en‚ bu¤ky
         call      TBLBDel                  ; zru¨en¡ bu¤ky ES:DI
         cmp       di,bp                    ; le‘¡ pod zdrojovou bu¤kou ?
         jae       EdTBKop5                 ; nele‘¡ pod zdrojovou bu¤kou
         sub       bp,cx                    ; oprava adresy bu¤ky
         sub       word ptr ds:[TBBlokAA],cx ; oprava ukazatele vyhled v n¡

; ------ vytvo©en¡ m¡sta pro novou bu¤ku na adrese DI

EdTBKop5:mov       cx,es:[bp+TblXOffs]      ; velikost nov‚ bu¤ky
         push      cx
         sub       cx,ds:[TBLXText]         ; bez z hlav¡
         push      di
         call      TBLBIns                  ; vytvo©en¡ bu¤ky
         pop       di
         pop       cx
         jc        EdTBKp4A                 ; chyba pamˆti

; ------ oprava adresy zdrojov‚ bu¤ky

         or        byte ptr ds:[TBLTPrm2],bit1 ; je pot©ebn˜ p©epo‡et

         cmp       di,bp                    ; le‘¡ pod zdrojovou bu¤kou ?
         ja        EdTBKp54                 ; nele‘¡ pod zdrojovou bu¤kou
         add       bp,cx                    ; oprava adresy bu¤ky
         add       word ptr ds:[TBBlokAA],cx ; oprava ukazatele vyhled v n¡

; ------ kopie definice bu¤ky

EdTBKp54:push      ax
         push      bp
         push      di
EdTBKop6:mov       al,es:[bp]
         inc       bp
         stosb
         loop      EdTBKop6
         pop       di
         pop       bp
         pop       ax
         mov       word ptr es:[di+TblXBunk],ax ; ‡¡slo bu¤ky
         or        byte ptr es:[di+TblXParm],bit5 ; p©¡znak bu¤ky v bloku

; ------ p©epo‡et odkaz– v bu¤ce

         mov       cx,es:[di+TblXOffs]      ; p–vodn¡ velikost bu¤ky
         call      TBTransX                 ; p©epo‡et bu¤ky
         sub       cx,es:[di+TblXOffs]      ; zmˆna velikosti bu¤ky
         cmp       di,bp                    ; le‘¡ pod zdrojovou bu¤kou ?
         ja        EdTBKp62                 ; nele‘¡ pod zdrojovou bu¤kou
         sub       bp,cx                    ; oprava adresy bu¤ky

; ------ p©i p©esunu zru¨en¡ zdrojov‚ bu¤ky

EdTBKp62:test      byte ptr ds:[TBLTPrm2],bit7 ; je p©esun ?
         jz        EdTBKp64                 ; nen¡ p©esun
         mov       di,bp                    ; DI <- zdrojov  bu¤ka
         or        byte ptr ds:[TBLTParm],bit2 ; p©¡znak zru¨en¡ bu¤ky
         call      TBLBDel                  ; zru¨en¡ bu¤ky ES:DI
EdTBKp64:jmp       EdTBKop4

; ------ korekce bunˆk mimo blok (pouze p©i p©esunu) - posun BX

EdTBKop7:test      byte ptr ds:[TBLTPrm2],bit7 ; je p©esun ?
         jz        EdTBKop9                 ; nen¡ p©esun
         and       byte ptr ds:[TBLTPrm2],not bit5
         or        byte ptr ds:[TBLTPrm2],bit4+bit6 ; relativn¡ blok, abs. blok
         mov       di,TblDat                ; za‡ tek tabulky
         mov       cx,es:[TblBunN]          ; po‡et bunˆk tabulky
         jcxz      EdTBKop9                 ; nen¡ ‘ dn  bu¤ka

EdTBKop8:test      byte ptr es:[di+TblXParm],bit5 ; je mimo blok ?
         jnz       EdTBKp82                 ; je v bloku
         call      TBTrans                  ; p©epo‡et bu¤ky
EdTBKp82:add       di,es:[di+TblXOffs]      ; dal¨¡ bu¤ka
         loop      EdTBKop8

EdTBKop9:call      far ptr TDIniBlk         ; konec operace s blokem
         ret

EdTBKop  ENDP

; -----------------------------------------------------------------------------
;        import dat
; -----------------------------------------------------------------------------
;þ
EdTBImp  PROC      NEAR

; ------ zad n¡ souboru k importu dat

         push      si
         mov       si,offset TBLImpMn
         call      EdTBExPr                 ; nastaven¡ p©ep¡na‡–
         call      far ptr Lin0Menu         ; zad n¡ souboru k importu
         pop       si
         jnc       EdTBImp2                 ; nen¡ p©eru¨en¡ operace
EdTBImp1:ret

; ------ normalizace jm‚na souboru

EdTBImp2:push      si
         push      es
         call      far ptr NormFilL         ; normalizace jm‚na souboru
         jcxz      EdTBImp3                 ; nebylo nic zad no
         call      far ptr FullFile         ; p©evod na pln‚ jm‚no souboru
         call      far ptr OpenR            ; otev©en¡ souboru
EdTBImp3:pop       es
         pop       si
         jcxz      EdTBImp1                 ; nen¡ nic zad no
         jnc       EdTBImp4                 ; soubor otev©en OK

; ------ chyba - soubor nenalezen

         mov       di,offset ChybFndF       ; hl ¨en¡ - soubor nenalezen
         call      far ptr Lin0MenP         ; chybov‚ hl ¨en¡
         ret

; ------ proveden¡ importu souboru

EdTBImp4:call      EdTDImp                  ; proveden¡ importu dat

; ------ uzav©en¡ souboru

         call      far ptr ClosFile         ; uzav©en¡ souboru
         ret

EdTBImp  ENDP

; -----------------------------------------------------------------------------
;        proveden¡ importu dat ze souboru AX do okna ES, menu DS:SI
; -----------------------------------------------------------------------------
; lok ln¡ promˆnn‚: SS:[BP-2] (2) identifik tor souboru   ÄÄÄ¿struktura pou‘ita
;                   SS:[BP-4] (2) adresa okna                ³i p©i otev¡r n¡
;                   SS:[BP-6] (2) (adresa bu¤ky)             ³ tabulky !!!
;                   SS:[BP-8] (2) ukazatel ‡¡sla bu¤ky       ³
;                   SS:[BP-10] (2) po‡et bajt– v bufferu     ³
;                   SS:[BP-12] (2) offset adresy v bufferu   ³
;                   SS:[BP-14] (2) adresa za‡ tku bufferu    ÀÄÄÄÄÄÄ¿
;                   SS:[BP-15] (1) (po‡et slov na celou ‡ st ‡¡sla) ³
;                   SS:[BP-16] (1) (po‡et slov na desetinnou ‡ st)  ³
;                              (256) vstupn¡ buffer      ÄÄÄÄÄÄÄÄÄÄÄÙ
; -----------------------------------------------------------------------------
;þ
EdTDImp  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      di
         push      bp
         mov       bp,sp

; ------ p©¡prava lok ln¡ch promˆnn˜ch

         sub       sp,16+256
         mov       ss:[bp-2],ax             ; identifik tor souboru
         mov       ss:[bp-4],es             ; adresa okna
         mov       ax,es:[TBLKurz]          ; kurzor
         mov       ss:[bp-8],ax             ; ukazatel ‡¡sla bu¤ky
         mov       word ptr ss:[bp-10],0    ; v bufferu nic nen¡
         mov       word ptr ss:[bp-12],0    ; offset adresy v bufferu
         mov       ss:[bp-14],sp            ; adresa za‡ tku bufferu


; ====== obsluha oddˆlova‡– mezi bu¤kami

; ------ na‡ten¡ dal¨¡ho znaku (mezi bu¤kami)

EdTDImp1:call      EdTDImpB                 ; na‡ten¡ dal¨¡ho bajtu z bu¤ky
         jc        EdTDIm19                 ; konec souboru nebo chuba

; ------ zv˜¨en¡ ‡¡sla © dku znakem LF

         cmp       al,LF                    ; je LF ?
         jne       EdTDIm12                 ; nen¡ LF
         add       word ptr ss:[bp-8],TBLNasR ; zv˜¨en¡ ‡¡sla © dku
         and       word ptr ss:[bp-8],not TBLMaskC ; nulov n¡ ‡¡sla sloupce
         mov       ax,es:[TBLKurz]          ; kurzor
         and       ax,TBLMaskC              ; ‡¡slo sloupce s kurzorem
         or        ss:[bp-8],ax             ; ‡¡slo sloupce na po‡ tek bloku
         jmp       short EdTDImp1           ; dal¨¡ znak

; ------ zv˜¨en¡ ‡¡sla sloupce oddˆlova‡em dat

EdTDIm12:cmp       al,ds:[OddelPol]         ; je oddˆlova‡ dat ?
         jne       EdTDIm18                 ; nen¡ oddˆlova‡ dat
         inc       word ptr ss:[bp-8]       ; zv˜¨en¡ ukazatele ‡¡sla sloupce
         jmp       short EdTDImp1           ; dal¨¡ znak

; ------ mezery a ostatn¡ znaky < 32 se vypou¨tˆj¡

EdTDIm18:cmp       al," "                   ; je mezera nebo znak < 32 ?
         jbe       EdTDImp1                 ; znak se vypou¨t¡


; ====== na‡ten¡ textu bu¤ky do edita‡n¡ho bufferu

; ------ p©¡prava k ukl d n¡ textu bu¤ky

         mov       word ptr es:[TBLEditN],0 ; v bufferu nen¡ ‘ dn˜ bajt
         mov       di,TBLEditB              ; za‡ tek edita‡n¡ho bufferu
         mov       ah," "                   ; oddˆlova‡em mezera/tabul tor

; ------ znak uvozovek " ohrani‡uje text nebo v˜raz a vypou¨t¡ se

         cmp       al,'"'                   ; jsou dvojit‚ uvozovky ?
         jne       EdTDImp2                 ; nejsou uvozovky
         mov       ah,al                    ; £schova oddˆlova‡e
         mov       al,"'"                   ; p©¡znak textov‚ bu¤ky
         test      byte ptr ds:[TBLTExpP],bit0 ; na‡¡t  se v˜raz ?
         jz        EdTDIm21                 ; ulo‘en¡ p©¡znaku textov‚ bu¤ky
         jmp       short EdTDIm22           ; znak se neukl d 

EdTDIm19:jmp       EdTDImp9                 ; nen¡ dal¨¡ znak - konec

; ------ znak uvozovek ' ohrani‡uje text a ukl d  se

EdTDImp2:cmp       al,"'"                   ; jsou jednoduch‚ uvozovky ?
         jne       EdTDIm21                 ; nejsou jednoduch‚ uvozovky
         mov       ah,al                    ; £schova oddˆlova‡e

; ------ ulo‘en¡ znaku do bufferu

EdTDIm21:cmp       word ptr es:[TBLEditN],TBLMaxS ; je buffer pln˜ ?
         jae       EdTDIm22                 ; buffer je ji‘ pln˜
         cld
         stosb                              ; £schova bajtu do bufferu
         inc       word ptr es:[TBLEditN]   ; zv˜¨en¡ ‡¡ta‡e bajt–

; ------ na‡ten¡ dal¨¡ho znaku

EdTDIm22:call      EdTDImpB                 ; na‡ten¡ dal¨¡ho bajtu z bu¤ky
         jc        EdTDImp3                 ; konec souboru nebo chyba

; ------ test, zda je oddˆlova‡ dat v ‡¡sle

         cmp       ah," "                   ; je oddˆlova‡em mezera/tabul tor ?
         jne       EdTDIm23                 ; nen¡
         cmp       al," "                   ; je oddˆlovac¡ mezera ?
         je        EdTDIm26                 ; je oddˆlovac¡ mezera
         cmp       al,ds:[OddelPol]         ; je oddˆlova‡ dat ?
         je        EdTDImp3                 ; je oddˆlova‡ dat

; ------ zdvojen˜ znak uvozovek

EdTDIm23:cmp       al,ah                    ; je ukon‡ovac¡ znak uvozovek ?
         jne       EdTDIm24                 ; nen¡ ukon‡ovac¡ znak uvozovek
         call      EdTDImpB                 ; na‡ten¡ dal¨¡ho bajtu z bu¤ky
         jc        EdTDImp3                 ; nen¡ dal¨¡ znak - znak je platn˜
         cmp       al,ah                    ; je to opˆt ukon‡ovac¡ znak ?
         je        EdTDIm24                 ; je opˆt ukon‡en¡ - je to zdvojen‚
         call      EdTDImpR                 ; n vrat znaku do bufferu
         jmp       short EdTDIm26           ; konec textu bu¤ky

; ------ znak LF a CR je v‘dy konec

EdTDIm24:cmp       al,LF
         je        EdTDIm28                 ; je LF - konec (a n vrat znaku)
         cmp       al,CR
         jne       EdTDIm21                 ; jinak ulo‘en¡ znaku do bufferu

; ------ vypu¨tˆn¡ mezer za textem bu¤ky

EdTDIm26:call      EdTDImpB                 ; na‡ten¡ dal¨¡ho bajtu z bu¤ky
         jc        EdTDImp3                 ; konec souboru nebo chyba
         cmp       al," "                   ; je mezera ?
         je        EdTDIm26                 ; mezera se vypou¨t¡

; ------ jeden bˆ‘n˜ oddˆlova‡ se vypou¨t¡

         cmp       al,ds:[OddelPol]         ; oddˆlovac¡ ‡ rka
         je        EdTDImp3                 ; je oddˆlova‡ dat
EdTDIm28:call      EdTDImpR                 ; n vrat znaku do bufferu

; ------ ulo‘en¡ textu bu¤ky do bufferu

EdTDImp3:mov       ax,ss:[bp-8]             ; aktu ln¡ ‡¡slo bu¤ky
         inc       word ptr ss:[bp-8]       ; zv˜¨en¡ ukazatele ‡¡sla sloupce
         or        byte ptr ds:[TBLTPrm2],bit1 ; je pot©ebn˜ p©epo‡et
         call      EdTBVyrU                 ; ulo‘en¡ textu bu¤ky do bufferu
         jc        EdTDImp9                 ; chyba pamˆti
         call      far ptr TestBEsc         ; je p©eru¨en¡ operace ?
         jc        EdTDImp9                 ; je p©eru¨en¡ operace
         jmp       EdTDImp1                 ; dal¨¡ bu¤ka

; ------ n vrat registr–

EdTDImp9:mov       sp,bp
         pop       bp
         pop       di
         pop       cx
         pop       ax
         ret

EdTDImp  ENDP

; ------ navr cen¡ posledn¡ho znaku do bufferu zpˆt (lze pou‘¡t pouze 1x !)

EdTDImpR PROC      NEAR

         dec       word ptr ss:[bp-12]      ; n vrat posledn¡ho znaku
         ret

EdTDImpR ENDP

; ====== Funkce jsou pou‘ity i p©i otev¡r n¡ tabulky !!!!!

; ------ p©esko‡en¡ CX bajt– ze souboru a na‡ten¡ dal¨¡ho bajtu -> AL

EdTDImpC:push      ax
         mov       ax,ss:[bp-10]            ; po‡et bajt– v bufferu
         sub       ax,ss:[bp-12]            ; po‡et zb˜vaj¡c¡ch bajt–
         cmp       cx,ax                    ; je v bufferu dost dat ?
         jbe       EdTDImC2                 ; v bufferu je dost dat
         sub       cx,ax                    ; tolik bude je¨tˆ zb˜vat
         pop       ax
         mov       word ptr ss:[bp-10],0    ; v bufferu nic nen¡
         call      EdTDImB6                 ; na‡ten¡ bufferu
         jnc       EdTDImpC                 ; dal¨¡ ‡ten¡
         ret

EdTDImC2:add       ss:[bp-12],cx            ; zv˜¨en¡ ukazatele adresy
         pop       ax
                                          ;* pokra‡uje ‡ten¡ znaku !!!

; ------ na‡ten¡ bajtu ze vstupn¡ho souboru -> AL, CY=konec souboru nebo chyba

EdTDImpB PROC      NEAR

         push      si
EdTDImB2:mov       si,ss:[bp-12]            ; SI <- offset adresy v bufferu
         cmp       si,ss:[bp-10]            ; je dal¨¡ bajt v bufferu ?
         jae       EdTDImB4                 ; nen¡ dal¨¡ bajt v bufferu
         add       si,ss:[bp-14]            ; + adresa za‡ tku bufferu
         mov       al,ss:[si]               ; na‡ten¡ bajtu
         inc       word ptr ss:[bp-12]      ; zv˜¨en¡ ukazatele dat v bufferu
         clc                                ; p©¡znak operace OK
         pop       si
         ret

EdTDImB4:call      EdTDImB6                 ; na‡ten¡ bufferu
         jnc       EdTDImB2                 ; na‡ten¡ bajtu z bufferu
         pop       si
         ret

EdTDImB6:push      ax
         push      cx
         push      di
         push      es

         mov       ax,ss:[bp-2]             ; identifik tor souboru
         mov       di,ss:[bp-14]            ; adresa bufferu
         push      ss
         pop       es                       ; segment bufferu
         mov       cx,256                   ; velikost bufferu
         call      far ptr ReadFile         ; na‡ten¡ dat ze souboru

         mov       word ptr ss:[bp-10],cx   ; po‡et bajt– v bufferu
         mov       word ptr ss:[bp-12],0    ; ukazatel adresy v bufferu
         cmp       cx,1                     ; bylo nˆco na‡teno ?

         pop       es
         pop       di
         pop       cx
         pop       ax
         ret

EdTDImpB ENDP

; -----------------------------------------------------------------------------
;        export cel‚ho souboru
; -----------------------------------------------------------------------------

EdTBExp0 PROC      NEAR

         xor       bx,bx                    ; po‡ tek bloku
         mov       dx,TBLMaxC+TBLMaxR*TBLNasR ; konec bloku
         call      far ptr TInitBlk         ; inicializace operace s blokem
         call      EdTBExp                  ; export bloku
         call      far ptr TDIniBlk         ; konec operace s blokem
         ret

EdTBExp0 ENDP

; -----------------------------------------------------------------------------
;        export bloku
; -----------------------------------------------------------------------------
;þ
EdTBExp  PROC      NEAR

; ------ zad n¡ souboru k exportu dat

         push      si
         mov       si,offset TBLMSLin
         call      EdTBExPr                 ; nastaven¡ p©ep¡na‡–
         call      far ptr Lin0Menu         ; zad n¡ souboru k exportu
         pop       si
         jnc       EdTBExp2                 ; nen¡ p©eru¨en¡ operace
EdTBExp1:ret

; ------ normalizace jm‚na souboru

EdTBExp2:push      si
         push      es
         call      far ptr NormFilL         ; normalizace jm‚na souboru
         call      far ptr FullFile         ; p©evod na pln‚ jm‚no souboru
         pop       es
         pop       si
         stc                                ; p©¡znak p©eru¨en¡ operace
         jcxz      EdTBExp1                 ; nen¡ nic zad no

; ------ vytvo©en¡ souboru

         push      si

         push      ds
         pop       es
         mov       si,offset LinBuff        ; buffer jm‚na souboru
         call      far ptr ExisFile         ; test, zda soubor existuje
         jc        EdTBEx32                 ; soubor nenalezen

         call      far ptr OpenW            ; otev©en¡ pro z pis
         jc        EdTBEx31                 ; chyba
         call      far ptr TestDev          ; test, zda to je za©¡zen¡
         jnc       EdTBEx36                 ; je to za©¡zen¡
         call      far ptr ClosFile         ; uzav©en¡ souboru

EdTBEx31:push      si
         mov       si,offset KopD4Mnu       ; hl ¨en¡ - soubor ji‘ existuje
         call      far ptr Lin0MenF         ; chybov‚ hl ¨en¡
         pop       si
         jnc       EdTBEx32                 ; pokra‡ov n¡ OK

         call      far ptr SetBreak         ; p©eru¨en¡ operace
         jmp       short EdTBEx36

EdTBEx32:call      far ptr CreatFil         ; vytvo©en¡ souboru
         jc        EdTBEx36                 ; soubor vytvo©en OK

         call      far ptr ModiWDir         ; aktualizace adres ©e
         clc                                ; p©¡znak operace OK

EdTBEx36:pop       si

; ------ obnoven¡ adresy okna

         pushf
         push      ax
         mov       ax,ds:[TBLMnuSg]         ; segment tabulky
         call      far ptr GetDat           ; nov  adresa tabulky
         pop       ax
         popf
         jc        EdTBExp7                 ; chyba vytvo©en¡ souboru

; ------ proveden¡ exportu dat

         call      EdTDExp                  ; export dat
         jnc       EdTBExp9                 ; operace OK
         jmp       short EdTBExp8

; ------ chyba z pisu do souboru

EdTBExp7:xor       ax,ax                    ; AX <- soubor nen¡ otev©en
EdTBExp8:mov       di,offset DBHMWrt        ; hl ¨en¡ - chyba z pisu
         call      far ptr Lin0MenP         ; chybov‚ hl ¨en¡
         stc                                ; p©¡znak chyby operace

; ------ uzav©en¡ v˜stupn¡ho souboru

EdTBExp9:pushf
         call      far ptr ClosFile         ; uzav©en¡ souboru AX
         popf
         ret

EdTBExp  ENDP

; ------ p©ep¡na‡e (pou‘ito t‚‘ p©i importu !)

EdTBExS1 PROC      FAR

         mov       al,bit0
         jmp       short EdTBExS4

EdTBExS3:mov       al,bit1

EdTBExS4:xor       byte ptr ds:[TBLTExpP],al
         call      EdTBExPr
         call      far ptr DispMnu
         ret

EdTBExS1 ENDP

; ------ nastaven¡ parametr– (pro export i import)

EdTBExPr PROC      NEAR

         push      ax
         push      dx

         mov       dl,ds:[TBLTExpP]         ; p©ep¡na‡e
         call      far ptr SetSwch          ; nastaven¡ p©ep¡na‡–

         call      EdTBEPr2
         mov       ds:[TBLMLPl1],al
         mov       ds:[TBLImpP1],al
         call      EdTBEPr2
         mov       ds:[TBLMLPl3],al

         pop       dx
         pop       ax
         ret

EdTBExPr ENDP

EdTBEPr2:mov       al,ds:[ZnakSwch+1]       ; vypnuto
         shr       dl,1
         jnc       EdTBEPr3
         mov       al,ds:[ZnakSwch]         ; zapnuto
EdTBEPr3:ret

; -----------------------------------------------------------------------------
;        export dat z okna ES/DS:SI do souboru AX (-> CY=chyba z pisu)
; -----------------------------------------------------------------------------
; lok ln¡ promˆnn‚: SS:[BP-2] (2) identifik tor souboru
;                   SS:[BP-4] (2) aktu ln¡ © dek
;                   SS:[BP-6] (2) aktu ln¡ sloupec
;                   SS:[BP-8] (2)   (po‡et bajt– ve v˜stupn¡m bufferu)
;                   SS:[BP-10] (2) adresa za‡ tku bufferu v z sobn¡ku (=SP)
;                   SS:[BP-12] (2) ukazatel pozice po‡ tku sloupc–
;                   SS:[BP-14] (2) ukazatel pozice na © dku
; -----------------------------------------------------------------------------

EdTDExp  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         mov       bp,sp

; ------ inicializace lok ln¡ch promˆnn˜ch

         sub       sp,14+2*TBLMaxS+20
         mov       ss:[bp-2],ax             ; identifik tor souboru
         mov       ax,ds:[TBBlokCB]         ; sloupec po‡ tku bloku
         mov       ss:[bp-4],ax             ; aktu ln¡ sloupec
         mov       ax,ds:[TBBlokRB]         ; © dek po‡ tku bloku
         mov       ss:[bp-6],ax             ; aktu ln¡ © dek
         mov       ss:[bp-10],sp            ; adresa bufferu v z sobn¡ku
         mov       word ptr ss:[bp-12],0    ; nulov n¡ pozice po‡ tku sloupce
         mov       word ptr ss:[bp-14],0    ; nulov n¡ pozice na © dku

; ------ vyhled n¡ dal¨¡ polo‘ky k z pisu

         call      TBResBlk                 ; resetov n¡ vyhled v n¡ bunˆk
EdTDExp1:call      far ptr TBGetBlk         ; poskytnut¡ bu¤ky pro operaci
         jnc       EdTDExp2                 ; je dal¨¡ bu¤ka OK

; ------ z pis koncov‚ho CR/LF za neuzav©en˜m © dkem

         cmp       word ptr ss:[bp-14],0    ; je nˆco na © dku ?
         je        EdTDEx19                 ; nen¡ nic na © dku
         call      EdTDExCL                 ; z pis CR/LF
EdTDEx19:jmp       EdTDExp9

; ------ po‡et oddˆlova‡– © dk– -> CX

EdTDExp2:mov       cx,ax                    ; CX <- aktu ln¡ bu¤ka
         and       cx,TBLMaskR              ; ‡¡slo © dku
         sub       cx,ss:[bp-6]             ; byl zmˆnˆn © dek ?
         jbe       EdTDExp4                 ; © dek nebyl zmˆnˆn

; ------ z pis oddˆlovac¡ch CR/LF

EdTDExp3:call      EdTDExCL                 ; z pis CR/LF
         jc        EdTDEx19                 ; chyba
         sub       cx,TBLNasR
         ja        EdTDExp3                 ; dal¨¡ © dek
         mov       cx,ds:[TBBlokCB]         ; sloupec po‡ tku bloku
         mov       ss:[bp-4],cx             ; aktu ln¡ sloupec

; ------ po‡et oddˆlova‡– sloupc– -> AX

EdTDExp4:and       ax,TBLMaskC              ; maska ‡¡sla sloupce
         sub       ax,ss:[bp-4]             ; byl zmˆnˆn sloupec ?
         jbe       EdTDExp6                 ; sloupec nebyl zmˆnˆn

; ------ z pis oddˆlova‡– sloupc–

EdTDExp5:call      EdTDExSL                 ; z pis oddˆlova‡e sloupc–
         jc        EdTDEx19                 ; chyba
         dec       ax                       ; ‡¡ta‡ sloupc–
         jnz       EdTDExp5                 ; z pis dal¨¡ho oddˆlova‡e

; ------ p©¡prava k dek¢dov n¡ polo‘ky

EdTDExp6:mov       si,di                    ; ES:SI <- za‡ tek polo‘ky
         mov       di,sp                    ; DI <- buffer v z sobn¡ku

; ------ rozli¨en¡, zda se bude dek¢dovat ‡¡slo

         test      byte ptr es:[si+TblXParm],bit1 ; je to ‡¡slo ?
         jnz       EdTDEx62                 ; je to ‡¡slo
         test      byte ptr es:[si+TblXParm],bit0 ; je to text ?
         jnz       EdTDEx61                 ; je to text
         test      byte ptr ds:[TBLTExpP],bit0 ; ukl daj¡ se v˜razy ?
         jz        EdTDEx62                 ; neukl daj¡ se v˜razy
EdTDEx61:jmp       EdTDExp7

; ------ dek¢dov n¡ ‡¡sla do bufferu -> CX=d‚lka ‡¡sla, BX=d‚lka cel‚ ‡ sti

EdTDEx62:mov       cx,TBLMaxS               ; velikost bufferu
         mov       dx,ss                    ; DX <- segment adresy bufferu
         call      TBLSMist                 ; nastaven¡ po‡tu desetinn˜ch m¡st
         add       si,TblXReal              ; ‡¡slo k dek¢dov n¡

; ------ p©¡znak ASCII zobrazen¡ (v m¢du v˜raz–)

         test      byte ptr ds:[TBLTExpP],bit0 ; je m¢d v˜raz– ?
         jz        EdTDE621                 ; nen¡ m¢d v˜raz–
         test      byte ptr es:[si+TblXParm-TblXReal],bit4 ; je ASCII zobrazen¡ ?
         jz        EdTDE622                 ; nen¡ ASCII zobrazen¡
         mov       byte ptr ss:[di],"*"     ; p©¡znak ASCII zobrazen¡
         inc       di                       ; zv˜¨en¡ ukl dac¡ adresy
         dec       cx                       ; sn¡‘en¡ velikosti bufferu

; ------ dek¢dov n¡ ‡¡sla

EdTDE622:call      TBLDekNX                 ; dek¢dov n¡ bez textov‚ho tvaru
         jmp       short EdTDE624

EdTDE621:test      byte ptr ds:[TBLTExpP],bit1 ; je tiskov˜ m¢d ?
         jz        EdTDE622                 ; nen¡ tiskov˜ m¢d
EdTDE623:call      TBLDekN                  ; dek¢dov n¡ ‡¡sla do bufferu

; ------ pro datov˜ m¢d se nic dal¨¡ho neupravuje

EdTDE624:test      byte ptr ds:[TBLTExpP],bit1 ; je tiskov˜ m¢d ?
         jnz       EdTDEx63                 ; je tiskov˜ m¢d
         add       di,cx                    ; konec textu
         jmp       EdTDEx78                 ; nen¡ tiskov˜ m¢d

; ------ na‡ten¡ po‘adovan‚ ¨¡©ky bu¤ky -> DX

EdTDEx63:mov       si,ss:[bp-4]             ; SI <- ‡¡slo sloupce + 1
         mov       dh,0
         mov       dl,es:[si+TblSirTb]      ; ¨¡©ka aktu ln¡ho sloupce

; ------ stanoven¡ mezer p©ed za‡ tkem ‡¡sla -> DX

         cmp       word ptr ds:[TBLMist],0  ; jsou desetinn  m¡sta ?
         je        EdTDEx64                 ; nejsou desetinn  m¡sta
         dec       dx                       ; bez desetinn‚ te‡ky
         sub       dx,ds:[TBLMist]          ; zbytek na celou ‡ st ‡¡sla
         jnc       EdTDEx64                 ; nen¡ p©ete‡en¡
         xor       dx,dx                    ; DX <- omezen¡ p©i p©ete‡en¡
EdTDEx64:sub       dx,bx                    ; DX <- zb˜vaj¡c¡ mezery
         jnc       EdTDEx65                 ; je to OK
         xor       dx,dx                    ; omezen¡ p©i p©ete‡en¡

; ------ odsun ‡¡sla o DX znak–

EdTDEx65:mov       si,sp                    ; SI <- za‡ tek bufferu
         add       si,cx                    ; konec bufferu
         dec       si                       ; posledn¡ bajt v bufferu
         mov       di,si                    ; posledn¡ bajt v bufferu
         add       di,dx                    ; posledn¡ bajt k ukl d n¡

         push      cx
         push      es

         push      ss
         pop       es                       ; ES <- segment bufferu
         std                                ; smˆr dol–
         rep       movs byte ptr es:[di],es:[si] ; odsun ‡¡sla
         mov       al," "                   ; mazac¡ znak mezery
         mov       cx,dx                    ; CX <- zbytek dat k vymaz n¡
         rep       stosb                    ; vymaz n¡ za‡ tku bufferu

         pop       es
         pop       cx
         add       cx,dx                    ; zv˜¨en¡ dat v bufferu
         jmp       EdTDExp8

; ------ dek¢dov n¡ textu do bufferu

EdTDExp7:test      byte ptr ds:[TBLTExpP],bit1 ; tiskov˜ export ?
         jnz       EdTDEx74                 ; tiskov˜ export - nep©id v  se nic

; ------ £vodn¡ znak uvozovek

         mov       byte ptr ss:[di],'"'     ; £vodn¡ uvozovky
         inc       di                       ; zv˜¨en¡ ukl dac¡ adresy

; ------ p©¡znak ASCII zobrazen¡ (jen je-li m¢d v˜raz–)

         mov       bl,es:[si+TblXParm]      ; BL <- parametry bu¤ky
         test      bl,bit4                  ; je ASCII zobrazen¡ ?
         jz        EdTDEx71                 ; nen¡ ASCII zobrazen¡
         mov       byte ptr ss:[di],"*"     ; p©¡znak ASCII zobrazen¡
         inc       di                       ; zv˜¨en¡ ukl dac¡ adresy

; ------ p©¡znak extern¡ bu¤ky

EdTDEx71:test      bl,bit3                  ; je extern¡ bu¤ka ?
         jz        EdTDEx72                 ; nen¡ extern¡ bu¤ka
         mov       byte ptr ss:[di],"["     ; p©¡znak extern¡ bu¤ky
         inc       di                       ; zv˜¨en¡ ukl dac¡ adresy

; ------ pro ASCII a extern¡ bu¤ku nen¡ pot©eba nic rozli¨ovat

EdTDEx72:test      bl,bit3+bit4             ; ASCII zobrazen¡/extern¡ bu¤ka ?
         jnz       EdTDEx74                 ; nen¡ pot©eba dal¨¡ rozli¨en¡

; ------ nen¡-li m¢d v˜raz–, nen¡ pot©eba tak‚ nic rozli¨ovat

         test      byte ptr ds:[TBLTExpP],bit0 ; ukl daj¡ se v˜razy ?
         jz        EdTDEx74                 ; neukl daj¡ se v˜razy

; ------ na‡ten¡ prvn¡ho znaku textu -> AL

         push      si
         add       si,ds:[TBLXText]         ; za‡ tek textu
         mov       al,es:[si]               ; prvn¡ znak textu
         pop       si

; ------ test, zda je tento znak ‡¡slo

         call      KorTBVyr                 ; je ‡¡slo ?
         jnc       EdTDEx73                 ; je to ‡¡slo

; ------ zaji¨tˆn¡ ‡¡sla

         test      bl,bit0                  ; je to text ?
         jnz       EdTDEx74                 ; je to text OK
         mov       byte ptr ss:[di],"+"     ; zaji¨tˆn¡ ‡¡sla/v˜razu
         inc       di
         jmp       short EdTDEx74

; ------ zaji¨tˆn¡ textu

EdTDEx73:test      bl,bit0                  ; je to text ?
         jz        EdTDEx74                 ; nen¡ to text OK
         mov       byte ptr ss:[di],"'"     ; zaji¨tˆn¡ textu
         inc       di

; ------ d‚lka textu -> CX

EdTDEx74:mov       cx,es:[si+TblXOffs]      ; offset dal¨¡ bu¤ky
         sub       cx,ds:[TBLXText]         ; d‚lka textu
         jae       EdTDEx75
         xor       cx,cx                    ; CX <- 0
EdTDEx75:add       si,ds:[TBLXText]         ; za‡ tek textu

; ------ omezen¡ d‚lky textu

         jcxz      EdTDEx77                 ; nen¡ text
         cmp       cx,TBLMaxS               ; maxim ln¡ d‚lka textu
         jbe       EdTDEx76
         mov       cx,TBLMaxS               ; omezen¡ d‚lky textu

; ------ p©enesen¡ textu do bufferu

EdTDEx76:mov       al,es:[si]
         inc       si
         mov       ss:[di],al
         inc       di
         cmp       al,'"'
         jne       EdTDE762
         test      byte ptr ds:[TBLTExpP],bit1 ; tiskov˜ export ?
         jnz       EdTDE762                 ; tiskov˜ export
         mov       ss:[di],al
         inc       di
EdTDE762:loop      EdTDEx76

; ------ ukon‡en¡ textu

EdTDEx77:test      byte ptr ds:[TBLTExpP],bit1 ; tiskov˜ export ?
         jnz       EdTDEx78                 ; tiskov˜ export - nep©id v  se nic
         mov       byte ptr ss:[di],'"'     ; ukon‡ovac¡ uvozovky
         inc       di

; ------ d‚lka ulo‘en‚ho textu -> CX

EdTDEx78:sub       di,sp                    ; d‚lka textu
         mov       cx,di                    ; CX <- d‚lka textu v bufferu

; ------ z pis obsahu bu¤ky (CX bajt–)

EdTDExp8:call      EdTDExW                  ; z pis dat
         jc        EdTDExp9                 ; chyba
EdTDEx82:jmp       EdTDExp1                 ; dal¨¡ bu¤ka

; ------ n vrat registr–

EdTDExp9:mov       sp,bp
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

EdTDExp  ENDP

; ------ z pis oddˆlova‡e sloupc– -> CY=chyba

EdTDExSL:push      cx
         push      si

         inc       word ptr ss:[bp-4]       ; zv˜¨en¡ ukazatele sloupce

         test      byte ptr ds:[TBLTExpP],bit1 ; je tiskov˜ export ?
         jnz       EdTDESL3                 ; je tiskov˜ export

         mov       si,ss:[bp-10]            ; SI <- adresa bufferu
         mov       cl,ds:[OddelPol]         ; oddˆlova‡ polo‘ek
         mov       ss:[si],cl               ; oddˆlova‡ polo‘ek
         mov       cx,1                     ; zapisuje se 1 znak
         call      EdTDExW                  ; z pis dat
         jmp       short EdTDESL8

EdTDESL3:mov       si,ss:[bp-4]             ; SI <- ‡¡slo sloupce + 1
         mov       ch,0
         mov       cl,es:[si+TblSirTb-1]    ; ¨¡©ka aktu ln¡ho sloupce
         call      EdTDExSP                 ; z pis mezer po konec sloupce
         add       ss:[bp-12],cx            ; zv˜¨en¡ ukazatele sloupce
         clc                                ; p©¡znak operace OK

EdTDESL8:pop       si
         pop       cx
         ret

; ------ z pis mezer po pozici CX od za‡ tku aktu ln¡ho pole (CF nedefinov no !)

EdTDExSP:push      cx
         push      di

         add       cx,ss:[bp-12]            ; pozice od za‡ tku © dku
         sub       cx,ss:[bp-14]            ; chybˆj¡c¡ pozice
         jbe       EdTDESP6                 ; nen¡ co zapsat

         mov       di,ss:[bp-10]            ; DI <- adresa bufferu
         cmp       cx,TBLMaxS               ; maxim ln¡ po‡et mezer
         jbe       EdTDESP1                 ; je to OK
         mov       cx,TBLMaxS               ; omezen¡ po‡tu mezer

EdTDESP1:push      cx
EdTDESP2:mov       byte ptr ss:[di]," "     ; ulo‘en¡ znaku
         inc       di                       ; zv˜¨en¡ adresy v bufferu
         loop      EdTDESP2                 ; dal¨¡ znak
         pop       cx

         call      EdTDExW                  ; z pis dat

EdTDESP6:pop       di
         pop       cx
         ret

; ------ z pis CR/LF (-> CY=chyba z pisu)

EdTDExCL:push      cx
         push      si

         add       word ptr ss:[bp-6],TBLNasR ; zv˜¨en¡ ukazatele © dku
         mov       si,ss:[bp-10]            ; adresa bufferu v z sobn¡ku
         mov       word ptr ss:[si],CR+LF*HI ; text CR/LF
         mov       cx,2                     ; po‡et znak– k z pisu
         call      EdTDExW                  ; z pis dat
         mov       word ptr ss:[bp-12],0    ; nulov n¡ pozice po‡ tku sloupce
         mov       word ptr ss:[bp-14],0    ; nulov n¡ pozice na © dku

         pop       si
         pop       cx
         ret

; ------ z pis CX bajt– z bufferu do souboru

EdTDExW: push      ax
         push      si
         push      es

         push      ss
         pop       es                       ; ES <- segment bufferu
         add       ss:[bp-14],cx            ; zv˜¨en¡ pozice na © dku
         mov       si,ss:[bp-10]            ; adresa bufferu
         mov       ax,ss:[bp-2]             ; identifik tor souboru
         call      far ptr WritFile         ; z pis dat do souboru

         pop       es
         pop       si
         pop       ax
         ret

; -----------------------------------------------------------------------------
;        test, zda ozna‡en˜ blok obsahuje chr nˆn‚ bu¤ky -> CY=p©eru¨en¡
; -----------------------------------------------------------------------------

EdTBBTst PROC      NEAR

; ------ test, zda je chr nˆn  bu¤ka

         call      TBResBlk                 ; resetov n¡ vyhled v n¡ bunˆk
EdTBBTs2:call      far ptr TBGetBlk         ; poskytnut¡ bu¤ky pro operaci
         cmc
         jnc       EdTBBTs9                 ; nen¡ dal¨¡ bu¤ka
         test      byte ptr es:[di+TblXParm],bit7 ; je bu¤ka chr nˆn  ?
         jz        EdTBBTs2                 ; bu¤ka nen¡ chr nˆn 

; ------ chybov‚ hl ¨en¡

         mov       di,offset TBLErrRO
         call      far ptr Lin0MenP         ; chybov‚ hl ¨en¡
         stc                                ; p©¡znak p©eru¨en¡ operace
EdTBBTs9:ret

EdTBBTst ENDP

; -----------------------------------------------------------------------------
;        p©epo‡et bu¤ku s omezen¡m p©epo‡tu p©ep¡na‡i
; -----------------------------------------------------------------------------

TBTransX PROC      NEAR

         push      bx

         test      byte ptr ds:[TBLTParm],bit1 ; je p©epo‡et sloupc– ?
         jnz       TBTrnsX2                 ; je p©epo‡et sloupc–
         and       bx,not TBLMaskC          ; nulov n¡ posunu sloupc–

TBTrnsX2:test      byte ptr ds:[TBLTParm],bit0 ; je p©epo‡et © dk– ?
         jnz       TBTrnsX4                 ; je p©epo‡et © dk–
         and       bx,not TBLMaskR          ; nulov n¡ posunu © dk–

TBTrnsX4:call      TBTrans                  ; p©epo‡et bu¤ky
         pop       bx
         ret

TBTransX ENDP

; -----------------------------------------------------------------------------
;        p©epo‡et vzorce v bu¤ce DI, okno ES, menu DS:SI, relativn¡ posun BX
; -----------------------------------------------------------------------------
;þ
TBTrans  PROC      NEAR

; ------ test, zda je to v˜raz

         or        bx,bx                    ; je posun ?
         jz        TBTrans0                 ; nen¡ posun
         test      byte ptr es:[di+TblXParm],bit2 ; je to v˜raz ?
         jnz       TBTrans1                 ; je to v˜raz
TBTrans0:ret

; ------ £schova registr–

TBTrans1:push      ax
         push      cx
         push      dx
         push      di
         push      bp

; ------ ozna‡en¡ konce textu (BP uschov no jako posledn¡ !!!)

         mov       bp,di                    ; BP <- za‡ tek bu¤ky
         add       bp,es:[di+TblXOffs]      ; konec bu¤ky
         mov       dl,es:[bp]               ; £schova n sleduj¡c¡ho bajtu
         push      dx
         push      bp                       ; mus¡ b˜t posledn¡ !!!!
         mov       byte ptr es:[bp],0       ; ozna‡en¡ konce textu

; ------ p©¡prava k prohled n¡ textu v˜razu

         mov       bp,di                    ; BP <- £schova za‡ tku bu¤ky
         add       di,ds:[TBLXText]         ; za‡ tek textu

; ------ test, zda je konec textu

TBTrans2:dec       di                       ; p©ednastaven¡ - 1
TBTrns22:inc       di                       ; zv˜¨en¡ ukazatele textu
         mov       al,es:[di]               ; p©ipraven˜ znak
         cmp       al,0                     ; je konec textu ?
         je        TBTrns28                 ; je konec textu

; ------ p©esko‡en¡ textu v uvozovk ch

         cmp       al,'"'                   ; je text v uvozovk ch ?
         jne       TBTrns26
TBTrns23:inc       di                       ; p©esko‡en¡ znaku
         mov       al,es:[di]               ; p©ipraven˜ znak
         cmp       al,0                     ; je konec textu ?
         je        TBTrns28                 ; je konec textu
         cmp       al,'"'                   ; je konec textu ?
         jne       TBTrns23                 ; nalezen¡ konce textu
         jmp       short TBTrns22           ; dal¨¡ hled n¡

; ------ vyhled n¡ p¡smene

TBTrns26:cmp       al,"A"                   ; je to p¡smeno ?
         jb        TBTrns22                 ; nen¡ to p¡smeno
         cmp       al,"Z"                   ; je to p¡smeno ?
         ja        TBTrns22                 ; nen¡ to p¡smeno

; ------ na‡ten¡ ‡¡sla bu¤ky -> AX

         mov       dx,di                    ; DX <- £schova za‡ tku textu
         xchg      si,di
         call      far ptr ETblFBn          ; na‡ten¡ ‡¡sla bu¤ky -> AX
         xchg      si,di
         jc        TBTrans2                 ; nen¡ to platn  bu¤ka

; ------ test, zda je to absolutn¡ bu¤ka

         cmp       byte ptr es:[di-1],"@"   ; je to absolutn¡ bu¤ka ?
         jne       TBTrans3                 ; nen¡ to absolutn¡ bu¤ka
         dec       di                       ; n vrat na znak "@"

; ------ test, zda se bu¤ka p©epo‡¡t v 

         test      byte ptr ds:[TBLTPrm2],bit6 ; p©epo‡et bu¤ky v bloku ?
         jz        TBTrans2                 ; nen¡ p©epo‡et bu¤ky
         jmp       short TBTrans4           ; test bu¤ky v bloku

TBTrns28:jmp       TBTrans9

; ------ test, zda se bu¤ka p©epo‡¡t v 

TBTrans3:test      byte ptr ds:[TBLTPrm2],bit5 ; p©epo‡et bu¤ky v‘dy ?
         jnz       TBTrans5                 ; p©epo‡et bu¤ky v‘dy
         test      byte ptr ds:[TBLTPrm2],bit4 ; p©epo‡et bu¤ky v bloku ?
         jz        TBTrans2                 ; nen¡ p©epo‡et bu¤ky

; ------ test, zda je bu¤ka v bloku

TBTrans4:call      TBTstBlk                 ; test, zda je bu¤ka AX v bloku
         jc        TBTrans2                 ; bu¤ka AX nen¡ v bloku

; ------ posun ‡¡sla bu¤ky

TBTrans5:add       ax,bx                    ; posun ‡¡sla bu¤ky

; ------ dek¢dov n¡ ‡¡sla bu¤ky na text

         call      TBTxtBun                 ; p©¡prava textu bu¤ky

; ------ zji¨tˆn¡ zmˆny d‚lky textu bu¤ky

         mov       ax,ds:[si+TbMnuSeg]      ; segment bufferu tabulky
         mov       cx,di                    ; CX <- text za bu¤kou
         sub       cx,dx                    ; CX <- d‚lka star‚ho textu
         xchg      di,dx                    ; DI <- za‡ tek, DX <- konec
         sub       cx,ds:[TBLBunTN]         ; rozd¡l d‚lek
         je        TBTrans8                 ; d‚lky text– jsou shodn‚
         ja        TBTrans6                 ; text se zkracuje

; ------ text se prodlu‘uje

         neg       cx                       ; po‡et bajt– k vlo‘en¡
         call      far ptr InsDat           ; vlo‘en¡ dat
         jnc       TBTrans7                 ; operace OK
         mov       di,dx                    ; DI <- konec textu za bu¤kou
         jmp       short TBTrns82           ; p©i chybˆ dal¨¡ bu¤ka

; ------ text se zkracuje

TBTrans6:call      far ptr DelDat           ; zru¨en¡ CX bajt– z bufferu
         neg       cx                       ; oprava znam‚nka

; ------ £prava d‚lky o CX bajt–

TBTrans7:add       word ptr es:[bp+TblXOffs],cx ; oprava d‚lky bu¤ky

         push      bp
         add       bp,es:[bp+TblXOffs]      ; konec bu¤ky
         mov       byte ptr es:[bp],0       ; ozna‡en¡ konce textu
         pop       bp

         pop       ax
         add       ax,cx                    ; posun konce bu¤ky
         push      ax
         cmp       di,ds:[TBBlokAA]         ; je p©ed ukazatelem bloku ?
         ja        TBTrans8                 ; nen¡ p©ed ukazatelem bloku
         add       ds:[TBBlokAA],cx         ; oprava ukazatele bloku

; ------ p©enesen¡ textu bu¤ky

TBTrans8:mov       cx,ds:[TBLBunTN]         ; d‚lka textu bu¤ky
         push      si
         mov       si,offset TBLBunTx       ; text bu¤ky
         cld
         rep       movsb                    ; p©enos textu bu¤ky
         pop       si
         or        byte ptr ds:[TBLTPrm2],bit1 ; je pot©ebn˜ p©epo‡et
TBTrns82:jmp       TBTrans2                 ; dal¨¡ bu¤ka

; ------ n vrat konce textu

TBTrans9:pop       bp
         pop       dx
         mov       es:[bp],dl               ; n vrat n sleduj¡c¡ho bajtu

; ------ n vrat registr–

         pop       bp
         pop       di
         pop       dx
         pop       cx
         pop       ax
         ret

TBTrans  ENDP

; -----------------------------------------------------------------------------
;        test, zda je bu¤ka AX v bloku -> CY=nen¡ v bloku
; -----------------------------------------------------------------------------

TBTstBlk PROC      NEAR

         push      cx

         mov       cx,ax                    ; CX <- ‡¡slo bu¤ky
         and       cx,TBLMaskC              ; maska ‡¡sla sloupce
         cmp       cx,ds:[TBBlokCE]         ; kontrola sloupce konce
         ja        TBTstBl8                 ; nen¡ v bloku
         cmp       cx,ds:[TBBlokCB]         ; kontrola sloupce po‡ tku
         jb        TBTstBl8                 ; nen¡ v bloku

         mov       cx,ax                    ; CX <- ‡¡slo bu¤ky
         and       cx,TBLMaskR              ; maska ‡¡sla © dku
         cmp       cx,ds:[TBBlokRE]         ; kontrola © dku konce
         ja        TBTstBl8                 ; nen¡ v bloku
         cmp       cx,ds:[TBBlokRB]         ; kontrola © dku po‡ tku
         jae       TBTstBl9                 ; je v bloku OK

TBTstBl8:stc                                ; p©¡znak, ‘e nen¡ v bloku
TBTstBl9:pop       cx
         ret

TBTstBlk ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ bu¤ky AX do textov‚ho tvaru
; -----------------------------------------------------------------------------

TBTxtBun PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      di
         push      es

; ------ buffer k p©¡pravˆ ozna‡en¡ bu¤ky

         push      ds
         pop       es                       ; ES <- datov˜ segment
         mov       di,offset TBLBunTx       ; buffer textu bu¤ky
         cld

; ------ dek¢dov n¡ ‡¡sla sloupce na ASCII znaky

         push      ax
         and       ax,TBLMaskC              ; maska ‡¡sla sloupce
         mov       cl,26                    ; ‡¡seln  soustava
         div       cl                       ; rozdˆlen¡ na ‡¡slice
         add       ax,"AA"-1                ; korekce na ASCII znaky

; ------ ulo‘en¡ prvn¡ho znaku ‡¡sla sloupce (jen je-li platn˜)

         cmp       al,"A"                   ; je prvn¡ p¡smeno platn˜ znak ?
         jb        TBTxtBn1                 ; nen¡ to platn˜ znak
         stosb                              ; ulo‘en¡ prvn¡ho p¡smene

; ------ ulo‘en¡ druh‚ho znaku ‡¡sla sloupce

TBTxtBn1:mov       al,ah                    ; AL <- druh˜ znak ‡¡sla sloupce
         stosb                              ; ulo‘en¡ druh‚ho znaku ‡¡sla sloupce
         pop       ax                       ; n vrat ‡¡sla bu¤ky s kurzorem

; ------ dek¢dov n¡ ‡¡sla © dku bu¤ky s kurzorem

         mov       cl,TBLRotR               ; po‡et rotac¡ pro p©evod
         shr       ax,cl                    ; rotace ‡¡sla © dku na pozici
         inc       ax                       ; korekce ‡¡sla © dku (+1)
         xor       bx,bx                    ; nen¡ barva
         call      far ptr DekNumW          ; dek¢dov n¡ ‡¡sla © dku

; ------ ulo‘en¡ d‚lky textu

         sub       di,offset TBLBunTx       ; d‚lka textu
         mov       ds:[TBLBunTN],di         ; d‚lka textu

; ------ n vrat registr–

         pop       es
         pop       di
         pop       cx
         pop       bx
         pop       ax
         ret

TBTxtBun ENDP

; -----------------------------------------------------------------------------
;        vyhled n¡ dal¨¡ bu¤ky v bloku ES -> AX=‡¡slo, DI=adresa, CY=nen¡ bu¤ka
; -----------------------------------------------------------------------------

TBGetBlk PROC      FAR

; ------ test, zda byla operace ji‘ zah jena

         mov       di,ds:[TBBlokAA]         ; aktu ln¡ adresa ukazatele
         test      byte ptr ds:[TBLTParm],bit4 ; byla ji‘ nalezena bu¤ka ?
         jnz       TBGtBlk2                 ; byla ji‘ nalezena bu¤ka

; ------ nalezen¡ prvn¡ bu¤ky -> DI

         mov       ax,ds:[TBBlokCB]         ; sloupec po‡ tku bloku
         or        ax,ds:[TBBlokRB]         ; ‡¡slo bu¤ky po‡ tku bloku
         call      TBLSrc                   ; vyhled n¡ bu¤ky AX v oknˆ
         jnc       TBGtBlk8                 ; bu¤ka nalezena OK
         jmp       short TBGtBlk4           ; test bu¤ky DI

; ------ test, zda bude dal¨¡ bu¤ka

TBGtBlk2:mov       al,ds:[TBLTParm]         ; parametry
         and       byte ptr ds:[TBLTParm],not bit2 ; zru¨en¡ p©¡znaku ru¨en¡
         cmp       di,es:[0]                ; bude dal¨¡ bu¤ka ?
         jae       TBGtBlk5                 ; nebude dal¨¡ bu¤ka
         test      al,bit2                  ; byla bu¤ka zru¨ena ?
         jnz       TBGtBlk4                 ; bu¤ka byla zru¨ena

; ------ posun k dal¨¡ bu¤ce

TBGtBlk3:add       di,es:[di+TblXOffs]      ; adresa dal¨¡ bu¤ky
TBGtBlk4:cmp       di,es:[0]                ; je to platn  bu¤ka ?
TBGtBlk5:cmc
         jc        TBGtBlk9                 ; nebude dal¨¡ bu¤ka

; ------ kontrola pozice v bloku

         mov       ax,es:[di+TblXBunk]      ; ‡¡slo bu¤ky
         and       ax,TBLMaskC              ; maska ‡¡sla sloupce
         cmp       ax,ds:[TBBlokCB]         ; kontrola sloupce po‡ tku bloku
         jb        TBGtBlk3                 ; pozice nesouhlas¡
         cmp       ax,ds:[TBBlokCE]         ; kontrola sloupce konce bloku
         ja        TBGtBlk3                 ; pozice nesouhlas¡

; ------ kontrola © dku v bloku

         mov       ax,es:[di+TblXBunk]      ; ‡¡slo bu¤ky
         and       ax,TBLMaskR              ; maska ‡¡sla © dku
         cmp       ax,ds:[TBBlokRB]         ; kontrola © dku po‡ tku bloku
         jb        TBGtBlk3                 ; © dek nesouhlas¡
         cmp       ax,ds:[TBBlokRE]         ; kontrola © dku konce bloku
         ja        TBGtBlk3                 ; © dek nesouhlas¡

; ------ p©¡znak nalezen¡ bu¤ky

TBGtBlk8:mov       ds:[TBBlokAA],di         ; aktu ln¡ adresa ukazatele
         mov       ax,es:[di+TblXBunk]      ; AX <- ‡¡slo bu¤ky
         or        byte ptr ds:[TBLTParm],bit4 ; p©¡znak nalezen¡ bu¤ky

; ------ n vrat registr–

TBGtBlk9:ret

TBGetBlk ENDP

; -----------------------------------------------------------------------------
;        resetov n¡ vyhled v n¡ bunˆk
; -----------------------------------------------------------------------------

TBResBlk PROC      NEAR

         and       byte ptr ds:[TBLTParm],not bit2+bit4 ; nebyla zat¡m ‘ dn  bu¤ka
         ret

TBResBlk ENDP

; -----------------------------------------------------------------------------
;        inicializace operace s blokem (za‡ tek BX, konec DX)
; -----------------------------------------------------------------------------

TInitBlk PROC      FAR

; ------ p©¡znaky operace s blokem

         or        byte ptr ds:[TBLTParm],bit5 ; p©¡znak operace s blokem
         and       byte ptr ds:[TBLTParm],not bit2+bit3+bit4 ; nebyla zat¡m ‘ dn  bu¤ka

; ------ sloupec za‡ tku a konce bloku

         push      bx
         push      dx

         and       bx,TBLMaskC              ; maska ‡¡sla sloupce po‡ tku
         and       dx,TBLMaskC              ; maska ‡¡sla sloupce konce
         cmp       bx,dx                    ; je po©ad¡ OK ?
         jbe       TIniBlk2                 ; po©ad¡ je OK
         xchg      bx,dx                    ; oprava po©ad¡

TIniBlk2:mov       ds:[TBBlokCB],bx         ; sloupec po‡ tku bloku
         mov       ds:[TBBlokCE],dx         ; sloupec konce bloku

         pop       dx
         pop       bx

; ------ © dek za‡ tku a konce bloku

         push      bx
         push      dx

         and       bx,TBLMaskR              ; maska ‡¡sla © dku po‡ tku
         and       dx,TBLMaskR              ; maska ‡¡sla © dku konce
         cmp       bx,dx                    ; je po©ad¡ OK ?
         jbe       TIniBlk4                 ; po©ad¡ je OK
         xchg      bx,dx                    ; oprava po©ad¡

TIniBlk4:mov       ds:[TBBlokRB],bx         ; © dek po‡ tku bloku
         mov       ds:[TBBlokRE],dx         ; © dek konce bloku

         pop       dx
         pop       bx
         ret

TInitBlk ENDP

; -----------------------------------------------------------------------------
;        konec operace s blokem (uchov v  registr p©¡znak– !)
; -----------------------------------------------------------------------------

TDIniBlk PROC      FAR

         pushf
         and       byte ptr ds:[TBLTParm],not bit5 ; nen¡ operace s blokem
         popf
         ret

TDIniBlk ENDP

; -----------------------------------------------------------------------------
;        Enter, F4: editace
; -----------------------------------------------------------------------------
;þ
EdTBVyr  PROC      NEAR

; ------ zah jen¡ editace F4 (kurzor se po ukon‡en¡ ENTER neposune)

EdTBVyrA:mov       ax,es:[TBLKurz]          ; aktu ln¡ pozice kurzoru
         mov       es:[TBLEditO],ax         ; £schova jako star  pozice kurzoru
         jmp       short EdTBVyrB

; ------ zah jen¡ editace ENTER (a F4)

EdTBVrB0:test      byte ptr ds:[TBLTParm],bit5 ; je ozna‡ov n¡ bloku ?
         jnz       EdTBVyrB                 ; je ozna‡ov n¡ bloku
         ret                                ; uvolnˆn¡ prav‚ho tla‡¡tka my¨i->nic

EdTBVyrB:test      byte ptr ds:[TBLTParm],bit5 ; je ozna‡ov n¡ bloku ?
         jz        EdTBVyrG                 ; nen¡ ozna‡ov n¡ bloku
         jmp       EdTBBlk3                 ; ukon‡en¡ ozna‡ov n¡ bloku

EdTBVyrG:or        byte ptr es:[TBLParm],bit7 ; je opravn  editace
         test      byte ptr es:[TBLParm],bit4 ; je kurzor platn˜ ?
         jz        EdTBVyrD                 ; kurzor nen¡ platn˜
         call      EdTBVyrV                 ; na‡ten¡ obsahu bu¤ky
         jmp       short EdTBVyrC

; ------ zah jen¡ editace zad n¡m znaku

EdTBVyr0:cmp       bh,MousXKod/HI           ; je to k¢d my¨i ?
         je        EdTBVyrE                 ; znak my¨i zak zan˜
         cmp       bl," "                   ; je to platn˜ znak ?
         jb        EdTBVyrE                 ; nen¡ to platn˜ znak
         mov       ds:[KeyBuff],bx          ; n vrat kl vesy do bufferu
         and       byte ptr es:[TBLParm],not bit7 ; nen¡ opravn  editace
EdTBVyrD:mov       word ptr es:[TBLEditN],0 ; zru¨en¡ obsahu bufferu

         test      byte ptr es:[TblIParm],bit7 ; je m¢d formul ©e ?
         jz        EdTBVyrC                 ; nen¡ m¢d formul ©e
         test      byte ptr es:[TBLParm],bit4 ; je kurzor platn˜ ?
         jz        EdTBVyrC                 ; kurzor nen¡ platn˜
         call      EdTBVyrV                 ; na‡ten¡ obsahu bu¤ky
         mov       word ptr es:[TBLEditN],1 ; bude minim lnˆ 1 znak platn˜
;         or        byte ptr es:[TBLParm],bit7 ; je opravn  editace

; ------ editace textu

EdTBVyrC:test      byte ptr ds:[TBLTParm],bit5 ; je ozna‡ov n¡ bloku ?
         jnz       EdTBVyrE                 ; je ozna‡ov n¡ bloku

         test      byte ptr es:[TblIParm],bit7 ; je m¢d formul ©e ?
         jz        EdTBVyrF                 ; nen¡ m¢d formul ©e
         test      byte ptr es:[TBLParm],bit4 ; je kurzor platn˜ ?
         jz        EdTBVyrE                 ; kurzor nen¡ platn˜
EdTBVyrF:test      byte ptr es:[TBLParm],bit5 ; je z kaz z pisu ?
         jnz       EdTBVyrE                 ; je z kaz z pisu do bu¤ky
         call      EdTBLEdi                 ; editace © dku
         jnc       EdTBVyr2                 ; editace ukon‡ena OK
EdTBVyrE:mov       word ptr ds:[KeyBuff],0  ; zru¨en¡ kl vesy v bufferu
         ret                                ; nic nezmˆnˆno

;EdTBVyr1:jmp       short EdTBVyr8                 ; p©epo‡et tabulky

; ------ ulo‘en¡ textu bu¤ky

EdTBVyr2:mov       ax,es:[TBLKurz]          ; bu¤ka s kurzorem
         call      EdTBVyrU                 ; ulo‘en¡ textu bu¤ky AX

; ------ p©epo‡et po modifikaci bu¤ky pod kurzorem

EdTBVyr8:test      byte ptr es:[TblIParm],bit4 ; automatick˜ p©epo‡et ?
         jz        EdTBVyr9                 ; nen¡ automatick˜ p©epo‡et

; ------ sem se sk ‡e z F9 !

EdTBVr82:push      si
         mov       si,offset ZKMnuLHl
         call      far ptr InfDisp0         ; zobrazen¡ hl ¨en¡
         pop       si

         push      word ptr ds:[RandomR]    ; £schova gener toru n hodn‚ho ‡¡sla
         push      word ptr ds:[RandomR+2]

EdTBVr84:xor       bx,bx                    ; p©¡znak zmˆny bu¤ky
         mov       di,TblDat                ; za‡ tek tabulky
         mov       cx,es:[TblBunN]          ; po‡et bunˆk tabulky
         jcxz      EdTBVr88                 ; nen¡ ‘ dn  bu¤ka

         pop       word ptr ds:[RandomR+2]  ; n vrat gener toru n hodn‚ho ‡¡sla
         pop       word ptr ds:[RandomR]
         push      word ptr ds:[RandomR]    ; £schova gener toru n hodn‚ho ‡¡sla
         push      word ptr ds:[RandomR+2]

EdTBVr85:call      far ptr TestBEsc         ; test p©eru¨en¡ operace
         jc        EdTBVr88                 ; je p©eru¨en¡ operace
         mov       ax,es:[di+TblXBunk]      ; p©¡padn‚ ‡¡slo bu¤ky
         call      EdTBKal                  ; v˜po‡et obsahu bu¤ky AX
         adc       bx,0                     ; p©¡znak modifikace obsahu bu¤ky
         add       di,es:[di+TblXOffs]      ; adresa dal¨¡ bu¤ky
         loop      EdTBVr85

         or        bx,bx                    ; byla zmˆna ?
         jnz       EdTBVr84                 ; byla zmˆna - dal¨¡ v˜po‡et

EdTBVr88:pop       ax                       ; zru¨en¡ bufferu n hodn‚ho ‡¡sla
         pop       ax
         call      far ptr FlushEsc         ; vypr zdnˆn¡ bufferu kl vesnice
         call      far ptr InfoClos         ; uzav©en¡ informa‡n¡ho © dku
EdTBVyr9:ret

EdTBVyr  ENDP

; -----------------------------------------------------------------------------
;        F9: p©epo‡et cel‚ tabulky (vol no z menu - p©ep¡na‡ Radi ny !)
; -----------------------------------------------------------------------------

EdTBPrp0:test      byte ptr ds:[TBLTPrm2],bit1 ; po‘adov n p©epo‡et ?
         jz        EdTBPrp9                 ; nen¡ po‘adov n p©epo‡et
         test      byte ptr es:[TblIParm],bit4 ; automatick˜ p©epo‡et ?
         jz        EdTBPrp9                 ; nen¡ automatick˜ p©epo‡et

EdTbPrep PROC      NEAR

         test      byte ptr ds:[TBLTParm],bit5 ; je ozna‡ov n¡ bloku ?
         jz        EdTBVr82                 ; nen¡ ozna‡ov n¡ - v˜po‡et
EdTbPrp9:ret

EdTbPrep ENDP

; -----------------------------------------------------------------------------
;        ulo‘en¡ bu¤ky AX z edita‡n¡ho bufferu ES, DS:SI -> CY=chyba pamˆti
; -----------------------------------------------------------------------------

EdTBVyrU PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      di
         push      bp

; ------ nalezen¡ star‚ bu¤ky -> ES:DI=pozice k ulo‘en¡ bu¤ky

         call      TBLSrc                   ; nalezen¡ adresy kurzoru -> DI
         jc        EdTBVU22                 ; bu¤ka nenalezena

; ------ test, zda je star  bu¤ka chr nˆna

         test      byte ptr es:[di+TblXParm],bit7 ; je bu¤ka uzam‡ena ?
         jz        EdTBVrU2                 ; bu¤ka nen¡ uzam‡ena

; ------ chyba - je uzam‡en  bu¤ka

         test      byte ptr es:[TblIParm],bit7 ; je m¢d formul ©e ?
         jnz       EdTBVr42                 ; v m¢du formul ©e se nehl s¡
         mov       di,offset TBLErrRO
         call      far ptr Lin0MenP         ; chybov‚ hl ¨en¡
         jmp       short EdTBVr44

; ------ zru¨en¡ star‚ bu¤ky

EdTBVrU2:call      TBLBDel                  ; zru¨en¡ star‚ bu¤ky
         jmp       short EdTBVrU3

; ------ pro formul © je zak z no vkl d n¡ do pr zdn˜ch polo‘ek

EdTBVU22:test      byte ptr es:[TblIParm],bit7 ; je m¢d formul ©e ?
         jnz       EdTBVr42                 ; je m¢d formul ©e - z kaz

; ------ p©¡prava ukazatel– nov‚ho obsahu bu¤ky

EdTBVrU3:mov       bp,di                    ; BP <- £schova za‡ tku bu¤ky

         mov       bx,TBLEditB              ; zadan˜ text
         mov       cx,es:[TBLEditN]         ; d‚lka textu
         jcxz      EdTBVr42                 ; nen¡ nic - jen zru¨en¡ bu¤ky

; ------ test, zda je ‡¡slo (v˜raz) nebo text

         push      ax
         mov       al,es:[bx]               ; prvn¡ znak textu
         call      KorTBVyr                 ; test, zda je AL prvn¡ znak v˜razu
         pop       ax
         jnc       EdTBVrU5                 ; je to v˜raz

         cmp       byte ptr es:[bx]," "     ; je to textov  bu¤ka ?
         je        EdTBVr33                 ; mezera je jako £vod textu
         cmp       byte ptr es:[bx],'"'     ; je to textov  bu¤ka ?
         je        EdTBVr33                 ; je to textov  bu¤ka
         cmp       byte ptr es:[bx],"'"
         jne       EdTBVr32                 ; nen¡ £vod pro text

; ------ p©esko‡en¡ £vodn¡ho znaku pro text

EdTBVr33:inc       bx                       ; p©esko‡en¡ znaku
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e znak–

; ------ vytvo©en¡ nov‚ bu¤ky (‡¡slo AX, d‚lka CX, typ DL)

EdTBVr32:mov       dl,bit0                  ; typ - textov  bu¤ka
         call      TblBIns                  ; vytvo©en¡ nov‚ bu¤ky
         jc        EdTBVr44                 ; chyba

; ------ p©enesen¡ textu bu¤ky

         jcxz      EdTBVr42                 ; nen¡ dal¨¡ znak
EdTBVrU4:mov       al,es:[bx]               ; na‡ten¡ znaku
         inc       bx                       ; zv˜¨en¡ ukazatele textu
         stosb                              ; ulo‘en¡ znaku
         loop      EdTBVrU4                 ; dal¨¡ znak
EdTBVr42:clc                                ; p©¡znak operace OK
EdTBVr44:jmp       EdTBVrU8                 ; konec (CY=chyba)

; ------ p©¡prava p©¡znaku ASCII zobrazen¡

EdTBVrU5:mov       dl,0                     ; nen¡ ASCII zobrazen¡
         cmp       byte ptr es:[bx],"*"     ; je ASCII zobrazen¡ ?
         jne       EdTBVr50                 ; nen¡ ASCII zobrazen¡
         mov       dl,bit4                  ; p©¡znak ASCII zobrazen¡
         inc       bx                       ; zv˜¨en¡ ukazatele textu
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e znak–

; ------ redukce dopl¤kov‚ho "+" pro formul ©

EdTBVr50:test      byte ptr es:[TblIParm],bit7 ; je m¢d formul ©e ?
         jz        EdTBVr5A                 ; nen¡ m¢d formul ©e
         jcxz      EdTBVr5A                 ; nen¡ dal¨¡ znak
         cmp       bx,TBLEditB              ; je to za‡ tek bufferu ?
         jne       EdTBVr5A                 ; nen¡ to za‡ tek bufferu
         cmp       byte ptr es:[bx],"+"
         jne       EdTBVr5A
         inc       bx                       ; p©esko‡en¡ znaku "+"
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e znak–

; ------ redukce textu v˜razu nebo ‡¡sla

EdTBVr5A:push      si
         push      di
         push      ax

         cld
         jcxz      EdTBVr55                 ; nen¡ dal¨¡ znak

         mov       ah,0                     ; je konverze na velk‚ p¡smeno
         mov       si,bx                    ; SI <- za‡ tek textu
         mov       di,bx                    ; DI <- za‡ tek textu
EdTBVr51:lods      byte ptr es:[si]         ; na‡ten¡ znaku
         cmp       al,'"'                   ; je ASCII ‡¡slo ?
         jne       EdTBVr52                 ; nen¡ ASCII ‡¡slo
         not       ah                       ; zmˆna p©¡znaku ASCII ‡¡sla
EdTBVr52:or        ah,ah                    ; je ASCII ‡¡slo ?
         jnz       EdTBV532                 ; je ASCII ‡¡slo
         call      far ptr UpCase           ; konverze na velk‚ p¡smeno
EdTBV532:stosb                              ; ulo‘en¡ platn‚ho znaku
EdTBVr54:loop      EdTBVr51                 ; dal¨¡ znak
         mov       cx,di                    ; CX <- konec textu
         sub       cx,bx                    ; CX <- nov  d‚lka textu

EdTBVr55:pop       ax
         pop       di
         pop       si

; ------ test, zda je v˜raz nebo ‡¡slo

         push      ax
         push      bx
         push      cx
                                          ;* vypu¨tˆn¡ znak– p©ed ‡¡slem
EdTBVr56:jcxz      EdTBVr58                 ; nen¡ dal¨¡ znak - asi v˜raz
         mov       al,es:[bx]               ; na‡ten¡ znaku z bufferu
         inc       bx                       ; zv˜¨en¡ ukazatele textu
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e zbyl˜ch znak–
         cmp       al," "
         je        EdTBVr56
         cmp       al,"+"                   ; un rn¡ "+" ?
         je        EdTBVr56                 ; je un rn¡ "+"
         cmp       al,"-"                   ; je un rn¡ "-" ?
         je        EdTBVr56                 ; je un rn¡ "-"
         dec       bx                       ; n vrat ukazatele textu
         inc       cx                       ; n vrat ‡¡ta‡e znak–

                                          ;* test, zda je nˆco jin‚ho ne‘ ‡¡slo
EdTBVr57:clc                                ; p©¡znak, ‘e je ‡¡slo
         jcxz      EdTBVr59                 ; nen¡ dal¨¡ znak, je ‡¡slo
         mov       al,es:[bx]               ; na‡ten¡ znaku z bufferu
         inc       bx                       ; zv˜¨en¡ ukazatele textu
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e zbyl˜ch znak–
         cmp       al," "
         je        EdTBVr57
         cmp       al,ds:[OddelRad]
         je        EdTBVr57
         cmp       al,ds:[OddelDes]
         je        EdTBVr57
         cmp       al,"."                   ; desetinn  te‡ka ?
         je        EdTBVr57                 ; desetinn  te‡ka - to je ‡¡slo
         cmp       al,","                   ; desetinn  ‡ rka ?
         je        EdTBVr57                 ; desetinn  ‡ rka - to je ‡¡slo
         cmp       al,"0"                   ; je ‡¡slice ?
         jb        EdTBVr58                 ; nen¡ ‡¡slice
         cmp       al,"9"                   ; je ‡¡slice ?
         jbe       EdTBVr57                 ; je ‡¡slice OK

EdTBVr58:stc                                ; p©¡znak, ‘e nen¡ ‡¡slo

EdTBVr59:pop       cx
         pop       bx
         pop       ax
         jc        EdTBVrU6                 ; je v˜raz nebo extern¡

; ------ vytvo©en¡ bu¤ky pro ‡¡slo

         push      cx                       ; d‚lka zadan‚ho textu ‡¡sla
         xor       cx,cx                    ; CX <- 0 nebude se ukl dat text
         or        dl,bit1                  ; typ - ‡¡slo
         call      TblBIns                  ; vytvo©en¡ nov‚ bu¤ky
         pop       cx                       ; d‚lka zadan‚ho textu ‡¡sla
         jc        EdTBVrU8                 ; chyba

; ------ dek¢dov n¡ zadan‚ho ‡¡sla

         sub       di,ds:[TBLNumX]          ; za‡ tek bufferu ‡¡sla
         push      si
         mov       si,bx                    ; SI <- za‡ tek textu ‡¡sla
         call      TBLInpN                  ; na‡ten¡ ‡¡sla
         pop       si
         clc                                ; p©¡znak operace OK
         jmp       short EdTBVrU8           ; p©epo‡et tabulky

; ------ vytvo©en¡ bu¤ky pro v˜raz nebo extern¡ bu¤ku

EdTBVrU6:jcxz      EdTBVr64                 ; nen¡ dal¨¡ znak
         cmp       byte ptr es:[bx],"["     ; je extern¡ bu¤ka ?
         jne       EdTBVr64                 ; nen¡ extern¡ bu¤ka
         inc       bx                       ; p©esko‡en¡ znaku
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e znak–
         or        dl,bit3                  ; p©¡znak extern¡ bu¤ky
         jmp       short EdTBVr66
EdTBVr64:or        dl,bit2                  ; typ - v˜raz
EdTBVr66:call      TblBIns                  ; vytvo©en¡ nov‚ bu¤ky
         jc        EdTBVrU8                 ; chyba

; ------ p©enesen¡ textu v˜razu

         jcxz      EdTBVrU8                 ; nen¡ dal¨¡ znak
EdTBVrU7:mov       al,es:[bx]               ; na‡ten¡ znaku
         inc       bx                       ; zv˜¨en¡ ukazatele textu
         stosb                              ; ulo‘en¡ znaku
         loop      EdTBVrU7                 ; dal¨¡ znak

; ------ na‡ten¡ extern¡ bu¤ky

         mov       di,bp                    ; DI <- adresa bu¤ky
         test      byte ptr es:[di+TblXParm],bit3 ; je to extern¡ bu¤ka ?
         jz        EdTBVU72                 ; nen¡ extern¡ bu¤ka
         call      TBExtern                 ; na‡ten¡ extern¡ bu¤ky
EdTBVU72:clc                                ; p©¡znak operace OK

; ------ n vrat registr–

EdTBVrU8:pop       bp
         pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

EdTBVyrU ENDP

; -----------------------------------------------------------------------------
;        nulov n¡ p©¡znak–, ‘e je bu¤ka v bloku
; -----------------------------------------------------------------------------

EdTBKNl  PROC      NEAR

         push      cx
         push      di

         mov       di,TblDat                ; za‡ tek tabulky
         mov       cx,es:[TblBunN]          ; po‡et bunˆk tabulky
         jcxz      EdTBKNl9                 ; nen¡ ‘ dn  bu¤ka

EdTBKNl2:and       byte ptr es:[di+TblXParm],not bit5;+bit6 ; nebyl blok
         add       di,es:[di+TblXOffs]      ; adresa dal¨¡ bu¤ky
         loop      EdTBKNl2                 ; dal¨¡ bu¤ka

EdTBKNl9:pop       di
         pop       cx
         ret

EdTBKNl  ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ obsahu bu¤ky pro editaci v oknˆ ES (mus¡ b˜t platn )
; -----------------------------------------------------------------------------

EdTBVyrV PROC      NEAR

; ------ £schova registr–

         push      si

; ------ p©¡prava zdrojov‚ a c¡lov‚ adresy

         mov       di,TBLEditB              ; edita‡n¡ buffer
         mov       si,es:[TBLKurzA]         ; adresa kurzoru
         mov       cx,TBLMaxS               ; velikost bufferu
         mov       word ptr es:[TBLEditN],0 ; v bufferu nic nen¡
         cld

; ------ dopl¤kov˜ znak "+" pro ‡¡slo a v˜raz, nen¡-li jin˜ p©ep¡na‡

         test      byte ptr es:[TblIParm],bit7 ; je m¢d formul ©e ?
         jz        EdTBVrV0                 ; nen¡ m¢d formul ©e
         test      byte ptr es:[si+TBLXParm],bit0+bit3+bit4 ; jin˜ p©¡znak ?
         jnz       EdTBVrV0                 ; bude jin˜ p©¡znak
         mov       al,"+"                   ; p©¡znak ‡¡sla
         stosb                              ; ulo‘en¡ p©¡znaku
         dec       cx                       ; sn¡‘en¡ velikosti bufferu
         inc       word ptr es:[TBLEditN]

; ------ p©¡znak ASCII zobrazen¡

EdTBVrV0:test      byte ptr es:[si+TBLXParm],bit4 ; je ASCII zobrazen¡ ?
         jz        EdTBVrV1                 ; nen¡ ASCII zobrazen¡
         mov       al,"*"                   ; p©¡znak ASCII zobrazen¡
         stosb                              ; ulo‘en¡ p©¡znaku
         dec       cx                       ; sn¡‘en¡ velikosti bufferu
         inc       word ptr es:[TBLEditN]

; ------ test, zda se bude editovat ‡¡slo nebo v˜raz

EdTBVrV1:test      byte ptr es:[si+TBLXParm],bit1 ; je ‡¡slo ?
         jz        EdTBVrV2                 ; nen¡ ‡¡slo

; ------ dek¢dov n¡ ‡¡sla do bufferu

         mov       dx,es                    ; DX <- segment bufferu
         call      TBLSMist                 ; nastaven¡ po‡tu desetinn˜ch m¡st

         add       si,TblXReal              ; ‡¡slo k dek¢dov n¡
;         test      byte ptr es:[si+TblXParm-TblXReal],bit1 ; je to konstanta ?
;         jz        EdTBVV22                 ; nen¡ to konstanta
;         call      TBLSMstM                 ; maximalizace desetinn˜ch m¡st
EdTBVV22:call      TBLDekNX                 ; dek¢dov n¡ ‡¡sla do bufferu

         add       es:[TBLEditN],cx         ; d‚lka ‡¡sla
         jmp       short EdTBVrV7

; ------ p©¡prava d‚lky obsahu textov‚ bu¤ky -> CX (m–‘e b˜t = 0 !)

EdTBVrV2:mov       ax,es:[si+TblXOffs]      ; d‚lka bu¤ky
         sub       ax,ds:[TblXText]         ; d‚lka dat bu¤ky
         cmp       ax,cx                    ; je d‚lka OK ?
         jbe       EdTBVrV4                 ; d‚lka je OK
         mov       ax,cx                    ; omezen¡ d‚lky textu
EdTBVrV4:xchg      ax,cx                    ; CX <- d‚lka textu
         add       es:[TBLEditN],cx         ; po‡et znak– textu

; ------ pro textovou bu¤ku ulo‘en¡ £vodn¡ho p©¡znaku textu '

         mov       al,"["                   ; p©¡znak extern¡ bu¤ky
         test      byte ptr es:[si+TBLXParm],bit3 ; je extern¡ bu¤ka ?
         jnz       EdTBVrV5                 ; je extern¡ bu¤ka
         test      byte ptr es:[si+TBLXParm],bit0 ; je to text ?
         jz        EdTBVrV6                 ; nen¡ to text
         mov       al,"'"                   ; £vodn¡ p©¡znak textu
EdTBVrV5:stosb                              ; ulo‘en¡ p©¡znaku textu
         jcxz      EdTBVrV6                 ; d‚lka textu je = 0
         dec       cx                       ; p©ednastaven¡ - 1
         cmp       cx,TBLMaxS-1             ; je ji‘ maxim ln¡ d‚lka textu ?
         jae       EdTBVrV6                 ; je ji‘ maxim ln¡ d‚lka textu
         inc       cx                       ; n vrat CX
         inc       word ptr es:[TBLEditN]   ; zv˜¨en¡ d‚lky textu

; ------ p©enos obsahu textov‚ bu¤ky nebo v˜razu

EdTBVrV6:add       si,ds:[TblXText]         ; za‡ tek textu bu¤ky
         rep       movs byte ptr es:[di],es:[si] ; p©enos textu

; ------ n vrat registr–

EdTBVrV7:pop       si
         ret

EdTBVyrV ENDP

; -----------------------------------------------------------------------------
;        v˜po‡et obsahu bu¤ky AX (okno ES, DS:SI) -> CY=byla zmˆna £daje
; -----------------------------------------------------------------------------
; lok ln¡ promˆnn‚: SS:[BP-2] (2) segment adresy okna         ÄÄÄÄÄÄÄ¿zachovat
;                   SS:[BP-4] (2) offset k ulo‘en¡ v˜sledku operace ÄÙpo©ad¡ !
;                   SS:[BP-6] (2) ‡¡slo segmentu st©ada‡e operace
;                   SS:[BP-8] (2) adresa st©ada‡e operace (segment)
;                   SS:[BP-10] (2) maxim ln¡ konec st©ada‡e operace (=velikost)
;                   SS:[BP-12] (2) minim ln¡ © dek pro sou‡et intervalu
;                   SS:[BP-14] (2) maxim ln¡ © dek pro sou‡et intervalu
;                   SS:[BP-15] (1) minim ln¡ sloupec pro sou‡et intervalu
;                   SS:[BP-16] (1) maxim ln¡ sloupec pro sou‡et intervalu
;                   SS:[BP-18] (2)
;                   SS:[BP-20] (2)
; -----------------------------------------------------------------------------
;þ
EdTBKal  PROC      NEAR

; ------ test, zda bude prov dˆn p©epo‡et bu¤ky AX

         push      di
         call      TBLSrc                   ; vyhled n¡ bu¤ky AX
         jc        EdTBKal0                 ; bu¤ka nenalezena
         test      byte ptr es:[di+TblXParm],bit2 ; je v˜raz ?
         jnz       EdTBKal1                 ; je v˜raz, bude p©epo‡et

EdTBKal0:pop       di
         clc                                ; p©¡znak, ‘e nen¡ zmˆna obsahu bu¤ky
         ret

; ------ nastaven¡ registr– pro v˜po‡et

EdTBKal1:call      TBLSetRg                 ; nastaven¡ registr– pro v˜po‡et

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      bp
         push      es
         mov       bp,sp

; ------ p©¡prava lok ln¡ch promˆnn˜ch

         sub       sp,20 + TBLMaxS+2        ; buffer
         mov       ss:[bp-4+2],es           ; segment adresy okna
         mov       cx,es:[di+TblXOffs]      ; offset dal¨¡ bu¤ky
         sub       cx,ds:[TblXText]         ; d‚lka textu v˜razu
         add       di,TblXReal              ; buffer k ulo‘en¡ v˜sledku
         mov       ss:[bp-4],di             ; buffer k ulo‘en¡ v˜sledku
         xor       ax,ax                    ; AX <- nulovac¡ slovo
         add       di,ds:[TBLNumX]          ; za‡ tek textu v˜razu

; ------ £schova textu v˜razu do bufferu v z sobn¡ku

         cld
         mov       si,di                    ; SI <- za‡ tek textu
         cmp       cx,TBLMaxS               ; maxim ln¡ d‚lka textu
         jb        EdTBKal2
         mov       cx,TBLMaxS               ; omezen¡ d‚lky textu
EdTBKal2:mov       di,sp                    ; DI <- buffer v z sobn¡ku
         push      ds
         push      es
         pop       ds                       ; DS <- segment textu
         push      ss
         pop       es                       ; ES <- ukl dac¡ adresa
         cld
         rep       movsb                    ; £schova textu do bufferu
         mov       al,0                     ; koncov  0
         stosb                              ; ozna‡en¡ konce textu
         pop       ds

; ------ vytvo©en¡ bufferu st©ada‡e operace

         mov       bl,0
         mov       bh,byte ptr ds:[TBLNumXW]; minim ln¡ velikost bufferu (128 ‡¡sel)
         call      far ptr CreatDat         ; vytvo©en¡ bufferu
         jnc       EdTBKal3                 ; buffer vytvo©en OK
         clc                                ; p©¡znak, ‘e nebyla zmˆna £daje
         jmp       EdTBKal9                 ; chyba

; ------ p©¡prava parametr– bufferu st©ada‡e operace

EdTBKal3:mov       ss:[bp-6],ax             ; ‡¡slo segmentu st©ada‡e operace
         call      far ptr GetDat           ; adresa bufferu st©ada‡e -> ES
         mov       ss:[bp-8],es             ; adresa st©ada‡e operace
         mov       ss:[bp-10],bx            ; velikost bufferu st©ada‡e

; ------ p©¡prava registr– k v˜po‡tu v˜razu

         xor       di,di                    ; DI <- 0 vrchol st©ada‡e operace
         mov       si,sp                    ; SI <- za‡ tek textu v˜razu
         cld

; ------ na‡ten¡ £rovnˆ ADD

         call      far ptr NulBreak         ; nulov n¡ p©¡znaku p©eru¨en¡
         push      bp
         call      far ptr KalFOR           ; na‡ten¡ £rovnˆ OR
         pop       bp

; ------ vymaz n¡ neplatn‚ho ‡¡sla (pou‘ije se, nen¡-li ‘ dn‚ ‡¡slo)

         mov       cx,ds:[TblNumXW]         ; d‚lka ‡¡sla ve slovech
         xor       ax,ax                    ; nulovac¡ slovo
         push      cx
         rep       stosw                    ; vynulov n¡ bufferu ‡¡sla
         pop       cx

; ------ ulo‘en¡ na‡ten‚ho ‡¡sla do bufferu

         push      ds
         xor       si,si                    ; SI <- ‡¡slo ve st©ada‡i
         push      es
         pop       ds                       ; ES <- segment bufferu st©ada‡e
         les       di,ss:[bp-4]             ; adresa k ulo‘en¡ ‡¡sla
         cld
         push      si
         push      di
         push      cx
         repe      cmpsw                    ; porovn n¡ bufferu ‡¡sla
         pop       cx
         pop       di
         pop       si
         je        EdTBKal7                 ; nen¡ zmˆna ‡¡sla
         stc                                ; p©¡znak zmˆny ‡¡sla
         rep       movsw                    ; ulo‘en¡ na‡ten‚ho ‡¡sla
EdTBKal7:pop       ds

; ------ zru¨en¡ segmentu st©ada‡e operace (CY=byla zmˆna obsahu bu¤ky)

         pushf
         mov       ax,ss:[bp-6]             ; segment st©ada‡e operace
         call      far ptr DelSeg           ; zru¨en¡ segmentu st©ada‡e
         popf

; ------ n vrat registr–

EdTBKal9:mov       sp,bp
         pop       es
         pop       bp
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax

         pop       di

; ------ n vrat registr– po v˜po‡tu (CY=byla zmˆna obsahu bu¤ky)

         call      TBLResRg                 ; n vrat registr– po v˜po‡tu
         ret

EdTBKal  ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ ‡¡sla bu¤ky z ES:SI -> AX (-1 = CY =nen¡ platn‚ ‡¡slo bu¤ky)
; -----------------------------------------------------------------------------

ETblFBn  PROC      FAR

; ------ £schova registr–

         push      bx
         push      cx
         push      dx

; ------ p©¡prava k na‡ten¡ ‡¡sla bu¤ky

         mov       cx,-1                    ; st©ada‡ ozna‡en¡ sloupce (-1=neplatn˜)
         xor       bx,bx                    ; st©ada‡ ‡¡sla © dku bu¤ky

; ------ na‡ten¡ ozna‡en¡ sloupce

ETblFBn1:mov       ah,0
         mov       al,es:[si]               ; AL <- p©ipraven˜ znak
         sub       al,"A"                   ; korekce na ‡¡slici
         jc        ETblFBn3                 ; nen¡ p¡smeno
         cmp       al,"Z"-"A"
         ja        ETblFBn3                 ; nen¡ p¡smeno
         inc       si                       ; p©esko‡en¡ znaku

         inc       cx                       ; korekce p©ede¨l‚ho p¡smene + 1

         push      ax
         mov       ax,26                    ; n sobek
         mul       cx                       ; vyn soben¡ st©ada‡e
         pop       cx
         add       cx,ax                    ; nov˜ st©ada‡ ‡¡sla sloupce

         cmp       cx,TBLMaxC               ; je p©ete‡en¡ ?
         jbe       ETblFBn1                 ; nen¡ p©ete‡en¡
         mov       cx,TBLMaxC+1             ; indikace p©ete‡en¡
         jmp       short ETblFBn1           ; dal¨¡ znak

; ------ na‡ten¡ ‡¡sla © dku

ETblFBn3:mov       ah,0
         mov       al,es:[si]               ; AL <- p©ipraven˜ znak
         sub       al,"0"                   ; korekce na ‡¡slici
         jc        ETblFBn5                 ; nen¡ ‡¡slice
         cmp       al,"9"-"0"
         ja        ETblFBn5                 ; nen¡ ‡¡slice
         inc       si                       ; p©esko‡en¡ znaku

         push      ax
         mov       ax,10                    ; n sobek
         mul       bx                       ; vyn soben¡ st©ada‡e
         pop       bx
         add       bx,ax                    ; nov˜ st©ada‡ ‡¡sla © dku

         cmp       bx,TBLMaxR+1             ; je platn‚ ‡¡slo © dku ?
         jbe       ETblFBn3                 ; je platn‚ ‡¡slo © dku
         mov       bx,TBLMaxR+2             ; indikace p©ete‡en¡
         jmp       short ETblFBn3           ; dal¨¡ znak

; ------ vypu¨tˆn¡ p©¡padn‚ho znaku "@" (=p©¡znak absolutn¡ adresace)

ETblFBn5:cmp       byte ptr es:[si],"@"
         jne       ETblFBn6
         inc       si                       ; p©esko‡en¡ znaku "@"

; ------ kontrola, zda bylo p©ete‡en¡

ETblFBn6:mov       ax,-1                    ; p©¡znak p©ete‡en¡
         dec       bx                       ; korekce ‡¡sla © dku
         cmp       cx,TBLMaxC+1             ; je p©ete‡en¡ sloupce ?
         jae       ETblFBn7                 ; je p©ete‡en¡ sloupce
         cmp       bx,TBLMaxR+1             ; je p©ete‡en¡ © dku ?
ETblFBn7:cmc
         jc        ETblFBn9                 ; je p©ete‡en¡ © dku

; ------ sestaven¡ ‡¡sla bu¤ky -> AX, NC=p©¡znak operace OK

         xchg      ax,cx                    ; AX <- ‡¡slo sloupce
         mov       cl,TBLRotR               ; po‡et rotac¡ ‡¡sla © dku
         shl       bx,cl                    ; rotace ‡¡sla © dku na pozici
         or        ax,bx                    ; ‡¡slo bu¤ky

; ------ n vrat registr–

ETblFBn9:pop       dx
         pop       cx
         pop       bx
         ret

ETblFBn  ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ hodnoty bu¤ky AX do bufferu ES:DI (AX=-1 neplatn  bu¤ka)
; -----------------------------------------------------------------------------
; VSTUP: SS:[BP-2] (2) adresa segmentu okna
; -----------------------------------------------------------------------------

ETblFGB  PROC      FAR

         call      far ptr KalFNUL          ; vytvo©en¡ pr zdn‚ho ‡¡sla

         push      di
         push      si
         push      ds
         push      es

         mov       si,di                    ; SI <- konec ‡¡sla

         mov       es,ss:[bp-2]             ; ES <- segment okna
         call      TBLSrc                   ; vyhled n¡ bu¤ky AX
         jc        ETblFGB2                 ; neplatn  bu¤ka
         add       di,TblXReal              ; hodnota bu¤ky
         xchg      si,di                    ; SI <- hodnota bu¤ky, DI <- buffer
         mov       cx,ds:[TBLNumXW]         ; d‚lka ‡¡sla ve slovech
         sub       di,ds:[TBLNumX]          ; ukl dac¡ adresa
         push      es
         pop       ds                       ; DS <- segment ‡¡sla

         pop       es                       ; ES <- segment bufferu
         push      es
         cld
         rep       movsw                    ; p©enos ‡¡sla

ETblFGB2:pop       es
         pop       ds
         pop       si
         pop       di
         clc
         ret

ETblFGB  ENDP

;; -----------------------------------------------------------------------------
;;        aktualizace tabulky po modifikaci bu¤ky AX (okno ES, DS:SI)
;; -----------------------------------------------------------------------------
;
;EdTBAkt  PROC      NEAR
;
;; ------ £schova registr–
;
;         push      ax
;         push      bx
;         push      cx
;         push      si
;         push      di
;
;; ------ p©¡prava k prohled v n¡ bunˆk
;
;         call      TBTxtBun                 ; dek¢dov n¡ textu bu¤ky
;         mov       di,TblDat                ; za‡ tek dat tabulky
;         mov       cx,es:[TblBunN]          ; po‡et bunˆk tabulky
;         jcxz      EdTBAkt9                 ; nen¡ ‘ dn  bu¤ka
;;þþþþþþþþþþþþþþ
;; ------ test, zda m–‘e b˜t bu¤ka prohled na
;
;EdTBAkt2:test      byte ptr es:[di+TblXParm],bit0+bit1+bit3  ;+bit5 ; povoleno ?
;         jnz       EdTBAkt7                 ; test nepovolen
;
;; ------ p©¡prava k vyhled n¡ bu¤ky
;
;         push      cx
;         push      di
;         mov       cx,es:[di+TblXOffs]      ; offset dal¨¡ bu¤ky
;         add       di,ds:[TblXText]         ; za‡ tek textu
;         sub       cx,ds:[TblXText]         ; bez z hlav¡
;         jb        EdTBAkt5                 ; nen¡ ‘ dn˜ text
;         mov       al,ds:[TBLBunTx]         ; prvn¡ znak
;         cld
;
;; ------ vyhled n¡ prvn¡ho znaku
;
;EdTBAkt3:jcxz      EdTBAkt5                 ; nen¡ dal¨¡ znak
;         cmp       byte ptr es:[di],"$"     ; je HEX konstanta ?
;         je        EdTBAk38                 ; je HEX konstanta
;         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e znak–
;         scasb                              ; porovn n¡ jednoho znaku
;         je        EdTBAkt4                 ; znak nalezen OK
;         cmp       byte ptr es:[di-1],'"'   ; je textov  konstanta ?
;         je        EdTBAk36                 ; je textov  konstanta
;         cmp       byte ptr es:[di-1],"."   ; mohl by to b˜t interval ?
;         jne       EdTBAkt3                 ; nen¡ interval
;         cmp       byte ptr es:[di],"."     ; je to interval ?
;         jne       EdTBAkt3                 ; nen¡ interval
;
;; ------ na‡ten¡ po‡ tku intervalu
;
;
;         jmp       short EdTBAkt6           ; bu¤ka se aktualizuje v‘dy (je NC)
;
;; ------ vypu¨tˆn¡ textov‚ konstanty
;
;EdTBAk36:jcxz      EdTBAkt5                 ; nen¡ dal¨¡ znak
;         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e znak–
;         inc       di                       ; zv˜¨en¡ ukazatele textu
;         cmp       byte ptr es:[di-1],'"'   ; je konec konstanty ?
;         jne       EdTBAk32                 ; nalezen¡ konce konstanty
;         jmp       short EdTBAkt3
;
;; ------ vypu¨tˆn¡ HEX konstanty
;
;EdTBAk38:dec       cx                       ; sn¡‘en¡ ‡¡ta‡e znak–
;         inc       di                       ; zv˜¨en¡ ukazatele textu
;         jcxz      EdTBAkt5                 ; nen¡ dal¨¡ znak
;         cmp       byte ptr es:[di]," "     ; je mezera ?
;         je        EdTBAk38                 ; mezera se vypust¡
;         cmp       byte ptr es:[di],"0"     ; je ‡¡slice ?
;         jb        EdTBAkt3                 ; nen¡ HEX znak
;         cmp       byte ptr es:[di],"9"
;         jbe       EdTBAk38                 ; je HEX znak
;         cmp       byte ptr es:[di],"A"
;         jb        EdTBAkt3                 ; nen¡ HEX znak
;         cmp       byte ptr es:[di],"F"
;         jbe       EdTBAk38                 ; je HEX znak
;         jmp       short EdTBAkt3           ; dal¨¡ hled n¡
;
;; ------ porovn n¡ zbytku textu
;
;EdTBAkt4:push      cx
;         push      di
;         mov       si,offset TBLBunTx+1     ; za‡ tek textu + 1
;         mov       cx,ds:[TBLBunTN]         ; d‚lka textu
;         dec       cx                       ; bez 1. znaku
;         repe      cmpsb                    ; porovn n¡ zbytku textu
;         pop       di
;         pop       cx
;         jne       EdTBAkt3                 ; dal¨¡ znak
;         jmp       short EdTBAkt6           ; text nalezen OK
;
;EdTBAkt5:stc                                ; p©¡znak nenalezen¡ bu¤ky
;
;; ------ nastaven¡ p©¡znaku po‘adavku p©epo‡tu bu¤ky
;
;EdTBAkt6:pop       di
;         pop       cx
;         jc        EdTBAkt7                 ; bu¤ka nenalezena
;         or        byte ptr es:[di+TblXParm],bit6 ; po‘adavek p©epo‡tu bu¤ky
;
;; ------ p©¡prava pro dal¨¡ bu¤ku
;
;EdTBAkt7:add       di,es:[di+TblXOffs]      ; adresa dal¨¡ bu¤ky
;         loop      EdTBAkt2                 ; dal¨¡ bu¤ka
;
;; ------ n vrat registr–
;
;EdTBAkt9:pop       di
;         pop       si
;         pop       cx
;         pop       bx
;         pop       ax
;         ret
;
;EdTBAkt  ENDP
;
;; -----------------------------------------------------------------------------
;;        vyhled n¡ dal¨¡ modifikovan‚ bu¤ky -> AX, DI, CY=nen¡ dal¨¡
;; -----------------------------------------------------------------------------
;
;EdTBSMB  PROC      NEAR
;
;; ------ £schova registr–
;
;         push      cx
;
;; ------ p©¡prava k vyhled n¡
;
;         mov       di,TblDat                ; za‡ tek dat tabulky
;         mov       cx,es:[TblBunN]          ; po‡et bunˆk
;         jcxz      EdTBSMB8                 ; nen¡ dal¨¡ bu¤ka
;
;; ------ test, zda je po‘adov n p©epo‡et bu¤ky
;
;EdTBSMB2:mov       ax,es:[di+TblXBunk]      ; p©¡padn‚ ‡¡slo bu¤ky
;         test      byte ptr es:[di+TblXParm],bit6 ; po‘adov n p©epo‡et ?
;         jnz       EdTBSMB9                 ; nalezena bu¤ka
;
;; ------ dal¨¡ bu¤ka
;
;         add       di,es:[di+TblXOffs]      ; adresa dal¨¡ bu¤ky
;         loop      EdTBSMB2
;EdTBSMB8:stc                                ; p©¡znak nenalezen¡ bu¤ky
;
;; ------ n vrat registr–
;
;EdTBSMB9:pop       cx
;         ret
;
;EdTBSMB  ENDP

; -----------------------------------------------------------------------------
;        F7: m¢d zobrazen¡
; -----------------------------------------------------------------------------

EdTbMod  PROC      NEAR

         test      byte ptr es:[TblIParm],bit7 ; je m¢d formul ©e ?
         jnz       EdTBMod2                 ; je m¢d formul ©e
         xor       byte ptr es:[TblIParm],bit5 ; zmˆna m¢du zobrazen¡
EdTBMod2:ret

EdTbMod  ENDP

; -----------------------------------------------------------------------------
;        editace © dku (adresa okna DS:SI/ES) -> CY=p©eru¨en¡
; -----------------------------------------------------------------------------

EdTBLEdi PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      di
         push      bp

; ------ p©¡prava ukazatel–

         or        byte ptr ds:[TBLTParm],bit7 ; zapnut¡ p©¡znaku INSERT
         or        byte ptr es:[TBLParm],bit6 ; je editace © dku
         mov       ax,es:[TBLEditN]         ; po‡et znak– v bufferu
         mov       es:[TBLEditK],ax         ; kurzor na konec textu

; ------ zobrazen¡ okna a kurzoru

EdTBLEd1:call      far ptr DispMnu          ; zobrazen¡ okna
;         call      KurzTBL                  ; zobrazen¡ kurzoru

; ------ vstup znaku z kl vesnice -> BX

         call      far ptr InpChar          ; vstup znaku z kl vesnice
         call      TBLAdrES                 ; aktualizace adresy okna -> ES
         jnc       EdTBLE12                 ; nen¡ ESC
         jmp       EdTBLEd9                 ; p©eru¨en¡ operace ESC

; ------ obsluha kl vesy

EdTBLE12:mov       di,es:[TBLEditK]         ; DI <- kurzor v bufferu
         call      far ptr JumpBX           ; obsluha kl vesy

         dw        4B00h,EdTBLE61           ; vlevo
         dw        4D00h,EdTBLE62           ; vpravo
         dw        7300h,EdTBLE63           ; Ctrl-vlevo
         dw        7400h,EdTBLE65           ; Ctrl-vpravo

         dw        4700h,EdTBLE68           ; Home
         dw        4f00h,EdTBLE69           ; End

         dw        4800h,EdTBLEd8           ; nahoru
         dw        5000h,EdTBLEd8           ; dol–
         dw        7700h,EdTBLEd8           ; Ctrl-Home
         dw        7500h,EdTBLEd8           ; Ctrl-End
         dw        4900h,EdTBLEd8           ; PageUp
         dw        5100h,EdTBLEd8           ; PageDown
         dw        8400h,EdTBLEd8           ; Ctrl-PageUp
         dw        7600h,EdTBLEd8           ; Ctrl-PageDown
         dw        0f00h,EdTBLEd8           ; Tab
         dw        0f09h,EdTBLEd8           ; Shift-Tab

         dw        0e08h,EdTBLEd4           ; BS

         dw        5200h,EdTBLE22           ; INSERT
         dw        5300h,EdTBLE42           ; DELETE

         dw        1c0dh,EdTBLEd7           ; ENTER
         dw        0,EdTBLEd5

; ------ INSERT

EdTBLE22:xor       byte ptr ds:[TBLTParm],bit7 ; zmˆna p©¡znaku INSERT
         jmp       short EdTBLEd1

; ------ zru¨en¡ znaku BS

EdTBLEd4:or        di,di                    ; je kurzor na za‡ tku © dku ?
         jz        EdTBLEd6                 ; kurzor je ji‘ na za‡ tku © dku
         dec       di                       ; sn¡‘en¡ pozice kurzoru
         jnz       EdTBLE42                 ; nen¡ je¨tˆ za‡ tek © dku
         test      byte ptr es:[TblIParm],bit7 ; je m¢d formul ©e ?
         jnz       EdTBLEd6                 ; je m¢d formul ©e

; ------ zru¨en¡ znaku DEL

EdTBLE42:mov       cx,es:[TBLEditN]         ; po‡et znak– v bufferu
         sub       cx,di                    ; po‡et znak– za kurzorem
         jbe       EdTBLEd6                 ; nen sleduje ‘ dn˜ text
         dec       cx                       ; po‡et znak– k p©¡sunu
         dec       word ptr es:[TBLEditN]   ; sn¡‘en¡ po‡tu znak– v bufferu

         push      si
         push      di
         cld
         add       di,TBLEditB              ; DI <- adresa kurzoru
         mov       si,di                    ; SI <- adresa kurzoru
         inc       si                       ; n sleduj¡c¡ znak za kurzorem
         rep       movs byte ptr es:[di],es:[si] ; p©¡sun zbytku textu
         pop       di
         pop       si
         jmp       short EdTBLEd6

; ------ vlo‘en¡ znaku

EdTBLEd5:cmp       bh,MousXKod/HI           ; je k¢d my¨i ?
         jne       EdTBLE51                 ; nen¡ k¢d my¨i
         test      bl,MousXMov+MousXLR+MousXRR ; je posun my¨i/uvolnˆn¡ ?
         jnz       EdTBLEd6                 ; k¢d my¨i zak z n
         test      bl,MousXRP               ; stisk prav‚ho tla‡¡tka ?
         jz        EdTBLE50                 ; nen¡ stisk prav‚ho tla‡¡tka
         stc                                ; p©¡znak p©eru¨en¡ editace
         jmp       EdTBLEd9                 ; p©eru¨en¡ editace

EdTBLE50:jmp       EdTBLEd8                 ; jinak konec editace

EdTBLE51:xchg      ax,bx                    ; AX <- znak
         cmp       al," "                   ; je to platn˜ znak ?
         jb        EdTBLEd6                 ; nen¡ platn˜ znak
         mov       bx,es:[TBLEditN]         ; po‡et bajt– v bufferu
         test      byte ptr ds:[TBLTParm],bit7 ; je INSERT ?
         jnz       EdTBLE52                 ; je INSERT, bude vkl d n¡ dat
         cmp       di,bx                    ; je kurzor na konci ?
         jb        EdTBLE54                 ; nen¡ na konci, po‡et znak– se nezv˜¨¡
EdTBLE52:cmp       bx,TBLMaxS               ; je buffer ji‘ pln˜ ?
         jae       EdTBLEd6                 ; buffer je ji‘ pln˜

         push      di
         push      si

         mov       cx,bx                    ; CX <- po‡et znak– v bufferu
         sub       cx,di                    ; CX <- po‡et znak– za kurzorem
         add       di,TBLEditB              ; DI <- adresa kurzoru
         add       di,cx                    ; adresa za koncem textu
         mov       si,di                    ; SI <- adresa za koncem textu
         dec       si                       ; posledn¡ znak
         std
         rep       movs byte ptr es:[di],es:[si] ; odsun zbytku textu o pozici

         pop       si
         pop       di
         inc       word ptr es:[TBLEditN]   ; zv˜¨en¡ po‡tu znak– v bufferu

EdTBLE54:mov       es:[di+TBLEditB],al      ; ulo‘en¡ znaku
         inc       di                       ; zv˜¨en¡ pozice kurzoru

EdTBLEd6:or        di,di
         jnz       EdTBLE60
         test      byte ptr es:[TblIParm],bit7 ; je m¢d formul ©e ?
         jz        EdTBLE60                 ; nen¡ m¢d formul ©e
         inc       di                       ; minim lnˆ pozice 1
EdTBLE60:mov       es:[TBLEditK],di         ; nov  pozice kurzoru
         jmp       EdTBLEd1

; ------ vlevo

EdTBLE61:test      byte ptr es:[TBLParm],bit7 ; opravn  editace ?
         jz        EdTBLE66                 ; nen¡ opravn  editace
         or        di,di                    ; je ji‘ po‡ tek © dku ?
         jz        EdTBLEd6                 ; je ji‘ po‡ tek © dku
         dec       di                       ; sn¡‘en¡ pozice kurzoru
         jmp       short EdTBLEd6

; ------ vpravo

EdTBLE62:test      byte ptr es:[TBLParm],bit7 ; opravn  editave ?
         jz        EdTBLE66                 ; nen¡ opravn  editace
         cmp       di,es:[TBLEditN]         ; je ji‘ konec textu ?
         jae       EdTBLEd6                 ; je ji‘ konec textu
         inc       di                       ; zv˜¨en¡ pozice kurzoru
         jmp       short EdTBLEd6

; ------ slovo vlevo

EdTBLE63:test      byte ptr es:[TBLParm],bit7 ; opravn  editave ?
         jz        EdTBLE66                 ; nen¡ opravn  editace
EdTBLE64:or        di,di                    ; je ji‘ po‡ tek © dku ?
         jz        EdTBLEd6                 ; je ji‘ po‡ tek © dku
         dec       di                       ; sn¡‘en¡ ukazatele kurzoru
         mov       ax,es:[di+TBLEditB-1]    ; 2 znaky z bufferu
         call      far ptr TestWrd          ; test, zda to je za‡ tek slova
         jc        EdTBLE64                 ; nalezen¡ za‡ tku slova
         jmp       short EdTBLEd6

; ------ slovo vpravo

EdTBLE65:test      byte ptr es:[TBLParm],bit7 ; opravn  editave ?
EdTBLE66:jz        EdTBLEd8                 ; nen¡ opravn  editace
EdTBLE67:cmp       di,es:[TBLEditN]         ; je ji‘ konec textu ?
         jae       EdTBLEd6                 ; je ji‘ konec textu
         inc       di                       ; zv˜¨en¡ pozice kurzoru
         mov       ax,es:[di+TBLEditB-1]    ; 2 znaky z bufferu
         call      far ptr TestWrd          ; test, zda to je za‡ tek slova
         jc        EdTBLE67                 ; nalezen¡ za‡ tku slova
         jmp       short EdTBLEd6

; ------ Home: za‡ tek © dku

EdTBLE68:test      byte ptr es:[TBLParm],bit7 ; opravn  editave ?
         jz        EdTBLEd8                 ; nen¡ opravn  editace
         xor       di,di                    ; kurzor na za‡ tek © dku
         jmp       short EdTBLEd6

; ------ End: konec © dku

EdTBLE69:test      byte ptr es:[TBLParm],bit7 ; opravn  editave ?
         jz        EdTBLEd8                 ; nen¡ opravn  editace
         mov       di,es:[TBLEditN]         ; kurzor na konec © dku
         jmp       EdTBLEd6

; ------ ENTER: ukon‡en¡ editace

EdTBLEd7:mov       ax,es:[TBLKurz]          ; aktu ln¡ bu¤ka
         sub       ax,es:[TBLEditO]         ; porovn n¡ se starou bu¤kou

         mov       bx,4800h                 ; kurzor nahoru
         cmp       ax,-TBLNasR              ; je posun nahoru ?
         je        EdTBLEd8                 ; je posun nahoru

         mov       bx,5000h                 ; kurzor dol–
         cmp       ax,TBLNasR               ; je posun dol– ?
         je        EdTBLEd8                 ; je posun dol–

         mov       bx,4b00h                 ; kurzor vlevo
         inc       ax                       ; je posun vlevo "-1" ?
         jz        EdTBLEd8                 ; je posun vlevo

         mov       bx,4d00h                 ; kurzor vpravo
         dec       ax                       ; n vrat ‡¡sla
         dec       ax                       ; je posun vpravo "+1" ?
         jnz       EdTBLE86                 ; nen¡ posun vpravo

; ------ n vrat znaku do bufferu

EdTBLEd8:mov       ds:[KeyBuff],bx          ; n vrat znaku do bufferu

; ------ editace ukon‡ena OK

EdTBLE86:clc                                ; p©¡znak ukon‡en¡ editace OK

; ------ p©¡znak ukon‡en¡ editace (CY=p©eru¨en¡ editace)

EdTBLEd9:pushf
         and       byte ptr es:[TBLParm],not bit6 ; ukon‡en¡ editace
         popf

; ------ £schova ‡¡sla editovan‚ bu¤ky

         mov       ax,es:[TBLKurz]          ; kurzor
         mov       es:[TBLEditO],ax         ; £schova ‡¡sla bu¤ky

; ------ n vrat registr–

         pop       bp
         pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

EdTBLEdi ENDP

;; *****************************************************************************
;;                              InitTBMn
;;                     inicializace menu tabulky
;; -----------------------------------------------------------------------------
;; VSTUP: DS:SI=adresa definice menu
;; *****************************************************************************
;
;InitTBMn PROC      FAR
;
;         push      ax
;         mov       al,ds:[Pozic]            ; po‡et pozic
;         mov       ds:[si+MnuSir],al        ; ¨¡©ka okna
;         mov       al,ds:[Radku]            ; po‡et © dk–
;         sub       al,4
;         mov       ds:[si+MnuVys],al        ; v˜¨ka okna
;         call      far ptr CentMenu         ; vyst©edˆn¡ okna
;         pop       ax
;         ret
;
;InitTBMn ENDP
;
; *****************************************************************************
;                              DispTBMn
;                  zobrazen¡ okna editoru tabulky
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=definice okna
;        DS=datov˜ segment
; -----------------------------------------------------------------------------
; lok ln¡ promˆnn‚: SS:[BP-2] (2) adresa definice okna
;                   SS:[BP-4] (2) ‡¡slo segmentu okna
;                   SS:[BP-6] (2) adresa segmentu okna
;                   SS:[BP-7] (1) ukazatel © dku na displeji
;                   SS:[BP-8] (1) pozice na displeji
;                   SS:[BP-9] (1) ‡¡ta‡ © dk– okna
;                   SS:[BP-10] (1) ¨¡©ka okna - 2
;                   SS:[BP-12] (2) ukazatel ‡¡sla aktu ln¡ bu¤ky
;                   SS:[BP-14] (2) ukazatel adresy bu¤ky
;                   SS:[BP-16] (2) hladina k zobrazen¡
;                   SS:[BP-18] (2) ukazatel tabulky ¨¡©ek sloupc–
;                   SS:[BP-20] (2) aktivn¡ bu¤ka
;                   SS:[BP-21] (1) barva textu (a voln‚ pole)
;                   SS:[BP-22] (1) barva ‡¡sla
;                   SS:[BP-24] (2) ¨¡©ka bu¤ky
;                   SS:[BP-26] (2) zbyl‚ pozice do konce © dku
;                   SS:[BP-27] (1) barva v˜razu
;                   SS:[BP-28] (1) parametry
;                                      bit 0: 1=automatick˜ p©epo‡et
;                                      bit 1: 1=m¢d zobrazen¡ v˜raz–
;                                      bit 2: 1=v˜po‡ty £hl– v RAD
;                                      bit 3: 1=m¢d formul ©e
;                                      bit 4: 1=kurzor je platn  bu¤ka
;                                      bit 5: 1=kurzor je R/O
;                                      bit 6: 1=je DEMO verze
;                                      bit 7: 1=je INSERT
;                   SS:[BP-28-TBLMaxS] (TBLMaxS) buffer k dek¢dov n¡ ‡¡sla
; *****************************************************************************
;þ
DispTBMn PROC      FAR

; ------ korekce kurzoru, zobrazen¡ r mu a nadpisu tabulky

         call      KorTBMn                  ; korekce menu
         call      far ptr DispRamM         ; zobrazen¡ r mu

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,sp

; ------ vytvo©en¡ bufferu

         sub       sp,28 + TBLMaxS
         mov       cl,ds:[si+MnuSir]        ; ¨¡©ka okna
         mov       ch,0
         shl       cx,1
         sub       sp,cx                    ; m¡sto pro buffer

; ------ inicializace lok ln¡ch promˆnn˜ch

         mov       ss:[bp-2],si             ; adresa definice okna
         mov       ax,ds:[si+TBMnuSeg]      ; datov˜ segment okna
         mov       ss:[bp-4],ax             ; ‡¡slo segmentu okna
         call      far ptr GetDat           ; poskytnut¡ adresy segmentu okna
         mov       ss:[bp-6],es             ; adresa segmentu okna
         mov       dx,word ptr ds:[si+MnuPoz] ; pozice a © dek
         inc       dh                       ; po‡ te‡n¡ © dek (nadpis)
         mov       ss:[bp-8],dx             ; pozice a © dek na displeji
         mov       cx,word ptr ds:[si+MnuSir] ; ¨¡©ka a v˜¨ka okna
         sub       cx,502h
         mov       ss:[bp-10],cx            ; ¨¡©ka a v˜¨ka okna
         mov       ax,es:[TBLTop]           ; po‡ te‡n¡ bu¤ka
         mov       ss:[bp-12],ax            ; ukazatel ‡¡sla aktu ln¡ bu¤ky
         mov       ax,es:[TBLTopA]          ; adresa po‡ te‡n¡ bu¤ky
         mov       ss:[bp-14],ax            ; ukazatel adresy bu¤ky
         mov       al,ds:[si+MnuLev]        ; hladina
         mov       ah,0
         mov       ss:[bp-16],ax            ; hladina k zobrazen¡
         mov       ax,es:[TBLKurz]          ; bu¤ka s kurzorem
         mov       ss:[bp-20],ax            ; aktivn¡ bu¤ka
         mov       ah,es:[TblIParm]
         mov       cl,4
         shr       ah,cl
         mov       al,ds:[TBLTParm]         ; parametry
         and       al,bit7                  ; p©¡znak INSERT
         or        al,ah
         mov       ah,es:[TBLParm]
         and       ah,bit5+bit4
         or        al,ah                    ; p©¡znak R/O kurzoru
         and       al,not bit6              ; nen¡ DEMO verze
         test      byte ptr ds:[LicDPar0],bit4 ; je DEMO verze ?
         jz        DispTBM1                 ; nen¡ DEMO verze
         or        al,bit6                  ; p©¡znak DEMO verze
DispTBM1:mov       ss:[bp-28],al            ; parametry

; ------ zobrazen¡ © dku nadpisu

         mov       ah,ds:[ColTBL1]          ; barva stavov‚ho © dku
         call      DispTBMC                 ; vymaz n¡ © dku barvou AH
         call      DispTBNS                 ; dek¢dov n¡ nadpisu
         call      DispTBMD                 ; zobrazen¡ © dku nadpisu

; ------ zobrazen¡ horn¡ linky (‡¡sla sloupc–)

         mov       ah,ds:[ColTBLRm]         ; barva r mu tabulky
         call      DispTBMC                 ; vymaz n¡ © dku barvou AH
         call      DispTBCN                 ; dek¢dov n¡ ‡¡sel sloupc–
         call      DispTBMD                 ; zobrazen¡ © dku ‡¡sel sloupc–

; ------ p©¡prava ukazatele bunˆk (‡¡slo bu¤ky a ukazatel ¨¡©ek sloupc–)

DispTBM2:mov       es,ss:[bp-6]             ; adresa segmentu okna
         mov       ax,es:[TBLTop]           ; po‡ te‡n¡ bu¤ka
         and       ax,TBLMaskC              ; maska ‡¡sla sloupce
         and       byte ptr ss:[bp-12],not TBLMaskC ; nulov n¡ ‡¡sla sloupce
         or        ss:[bp-12],al            ; nastaven¡ po‡ te‡n¡ho sloupce
         add       ax,TblSirTb              ; adresa v tabulce ¨¡©ek
         mov       ss:[bp-18],ax            ; tabulka ¨¡©ek sloupc–

; ------ vymaz n¡ jednoho © dku

         mov       ah,ds:[ColTBL4]          ; barva textu
         call      DispTBMC                 ; vymaz n¡ © dku barvou AH

; ------ inicializace barvy r mu pro ‡¡sla © dk–

         mov       bh,ds:[ColTBLRm]         ; barva r mu
         mov       es:[di+1],bh
         mov       es:[di+3],bh
         mov       es:[di+5],bh
         mov       es:[di+7],bh

; ------ dek¢dov n¡ ‡¡sla © dku

         add       di,2*3                   ; adresa k dek¢dov n¡ ‡¡sla © dku
         mov       ax,ss:[bp-12]            ; ukazatel ‡¡sla bu¤ky
         mov       cl,TBLRotR               ; po‡et rotac¡ ‡¡sla © dku
         shr       ax,cl                    ; ‡¡slo © dku - 1
         inc       ax                       ; ‡¡slo © dku
         xor       dx,dx                    ; DX <- 0
         mov       bl,0                     ; oddˆlova‡ © d– se neukl d 
         call      far ptr DekNumD          ; dek¢dov n¡ ‡¡sla © dku
         inc       di
         inc       di                       ; po‡ tek k dek¢dov n¡ bunˆk

; ------ p©¡prava k dek¢dov n¡ © dku (zbyl‚ pozice do konce © dku)

         mov       al,ss:[bp-10]            ; ¨¡©ka okna - 2
         sub       al,4                     ; d‚lka © dku
         mov       ah,0
         mov       ss:[bp-26],ax            ; zbyl‚ pozice do konce © dku

; ------ p©¡prava ¨¡©ky bu¤ky

DispTBM3:push      ds
         mov       ds,ss:[bp-6]             ; segment okna
         mov       si,ss:[bp-18]            ; ukazatel tabulky ¨¡©ek
         mov       al,ds:[si]               ; ¨¡©ka bu¤ky
         mov       ah,0
         mov       ss:[bp-24],ax            ; ¨¡©ka bu¤ky

; ------ nalezen¡ po‘adovan‚ bu¤ky (pokud existuje) -> DS:SI, BL=parametry

         mov       bl,bit7                  ; p©¡znak neplatn‚ bu¤ky
         mov       si,ss:[bp-14]            ; ukazatel adresy bunˆk
         mov       ax,ss:[bp-12]            ; ukazatel ‡¡sla bu¤ky
DspTBM30:cmp       si,ds:[0]                ; je to platn  adresa ?
         jae       DspTBM32                 ; nen¡ to platn  adresa
         cmp       ax,ds:[si+TblXBunk]      ; je to tato bu¤ka ?
         je        DspTBM31                 ; bu¤ka nalezena
         jb        DspTBM32                 ; je vˆt¨¡ bu¤ka - nenalezeno
         add       si,ds:[si+TblXOffs]      ; adresa dal¨¡ bu¤ky
         mov       ss:[bp-14],si            ; nov˜ ukazatel bunˆk
         jmp       short DspTBM30

DspTBM31:mov       bl,ds:[si+TblXParm]      ; parametry bu¤ky

DspTBM32:pop       ds

; ------ p©¡prava barvy pro blok

         test      byte ptr ds:[TBLTParm],bit5 ; je operace s blokem ?
         jz        DspTB329                 ; nen¡ operace s blokem

         mov       ax,ss:[bp-12]            ; ukazatel ‡¡sla bu¤ky
         and       ax,TBLMaskC              ; maska ‡¡sla sloupce
         cmp       ax,ds:[TBBlokCB]         ; je za sloupcem po‡ tku ?
         jb        DspTB329                 ; nen¡ blok
         cmp       ax,ds:[TBBlokCE]         ; je za sloupcem konce ?
         ja        DspTB329                 ; nen¡ blok

         mov       ax,ss:[bp-12]            ; ukazatel ‡¡sla bu¤ky
         and       ax,TBLMaskR              ; maska ‡¡sla © dku
         cmp       ax,ds:[TBBlokRB]         ; je za © dkem po‡ tku ?
         jb        DspTB329                 ; nen¡ blok
         cmp       ax,ds:[TBBlokRE]         ; je za © dkem konce ?
         ja        DspTB329                 ; nen¡ blok

         or        bl,bit6                  ; barva se nastav¡ v‘dy, jako kurzor
         mov       ax,ss:[bp-12]            ; ukazatel ‡¡sla bu¤ky
         cmp       ax,ss:[bp-20]            ; je to aktivn¡ bu¤ka ?

         mov       al,ds:[ColTBL8]          ; barva bloku
         jne       DspTB326                 ; nen¡ to kurzor
         mov       al,ds:[ColTBL9]          ; barva kurzoru v bloku
DspTB326:mov       ah,al
         mov       bh,al
         jmp       short DspTBM35           ; nastaven¡ barev

; ------ p©¡prava barvy pro m¢d formul ©e

DspTB329:test      byte ptr ss:[bp-28],bit3 ; je m¢d formul ©e ?
         jz        DspTBM33                 ; nen¡ m¢d formul ©e
         test      bl,bit7                  ; je bu¤ka uzam‡ena ?
         jmp       short DspTBM34

; ------ p©¡prava barvy podle toho, zda je to kurzor (BL=parametry bu¤ky)

DspTBM33:mov       ax,ss:[bp-12]            ; ukazatel ‡¡sla bu¤ky
         cmp       ax,ss:[bp-20]            ; je to aktivn¡ bu¤ka ?
DspTBM34:mov       al,ds:[ColTBL2]          ; barva ‡¡sla
         mov       ah,ds:[ColTBL4]          ; barva textu
         mov       bh,ds:[ColTBL6]          ; barva v˜razu
         jne       DspTBM35                 ; nen¡ to kurzor/bu¤ka uzam‡ena
         mov       al,ds:[ColTBL3]          ; barva kurzoru na ‡¡sle
         mov       ah,ds:[ColTBL5]          ; barva kurzoru na textu
         mov       bh,ds:[ColTBL7]          ; barva kurzoru na v˜razu
         or        bl,bit6                  ; p©¡znak kurzoru
DspTBM35:mov       ss:[bp-22],ax            ; barva ‡¡sla a textu
         mov       ss:[bp-27],bh            ; barva v˜razu

; ------ adresa okna

         push      ds
         mov       ds,ss:[bp-6]             ; segment okna

; ------ p©¡prava barvy k vymaz n¡ bu¤ky -> AH

         mov       ah,ss:[bp-21]            ; barva textu nebo pr zdn‚ bu¤ky
         test      bl,bit1+bit2+bit3        ; je text/pr zdn  bu¤ka ?
         jz        DspTBM36                 ; je to text/pr zdn  bu¤ka
         mov       ah,ss:[bp-22]            ; barva ‡¡sla
         test      bl,bit1                  ; je ‡¡slo ?
         jnz       DspTBM36                 ; je to ‡¡slo
         test      byte ptr ss:[bp-28],bit1 ; m¢d zobrazen¡ v˜raz– ?
         jz        DspTBM36                 ; nen¡ m¢d zobrazen¡ v˜raz–
         mov       ah,ss:[bp-27]            ; AH <- barva v˜razu a extern¡ bu¤ky

; ------ p©¡prava d‚lky k vymaz n¡ bu¤ky -> CX

DspTBM36:mov       cx,ss:[bp-24]            ; ¨¡©ka bu¤ky
         cmp       cx,ss:[bp-26]            ; zb˜v  m‚nˆ znak– ?
         jbe       DspTBM37                 ; zb˜v  dost znak–
         mov       cx,ss:[bp-26]            ; omezen¡ d‚lky bu¤ky

; ------ vymaz n¡ bu¤ky barvou AH

DspTBM37:push      di
         jcxz      DsTBM372
         mov       al," "                   ; mazac¡ znak mezery
         cld
         test      bl,bit0+bit1+bit2+bit3   ; je platn  bu¤ka ?
         jnz       DsTBM373                 ; je platn  bu¤ka
         test      bl,bit6                  ; je to kurzor ?
         jz        DsTBM372                 ; nen¡ to kurzor

DsTBM371:inc       di
         mov       es:[di],ah               ; jen nastaven¡ barvy
         inc       di
         loop      DsTBM371
DsTBM372:pop       di
         jmp       DspTBM48                 ; konec

DsTBM373:rep       stosw                    ; vymaz n¡ bu¤ky
         pop       di

; ------ rozli¨en¡, zda se zobraz¡ ‡¡slo nebo text

DsTBM374:test      bl,bit1                  ; je to ‡¡slo ?
         jnz       DispTBM4                 ; je to ‡¡slo
         test      bl,bit0                  ; je to textov  bu¤ka ?
         jnz       DspTBM38                 ; je to textov  bu¤ka
         test      byte ptr ss:[bp-28],bit1 ; je m¢d zobrazen¡ v˜raz– ?
         jz        DispTBM4                 ; nen¡ zobrazen¡ v˜razu

; ------ p©¡prava d‚lky textu bu¤ky -> CX

DspTBM38:mov       cx,ds:[si+TblXOffs]      ; d‚lka bu¤ky

         pop       ds                       ; DS <- datov˜ segment

         sub       cx,ds:[TblXText]         ; d‚lka textu
         jbe       DspTBM49                 ; nen¡ text
         cmp       cx,ss:[bp-26]            ; zb˜v  dost m¡sta do konce © dku ?
         jbe       DspTBM39                 ; d‚lka textu je OK
         mov       cx,ss:[bp-26]            ; omezen¡ d‚lky textu

DspTBM39:add       si,ds:[TblXText]         ; za‡ tek textu
         xor       dx,dx                    ; centrov n¡ - vlevo

         push      ds

         mov       ds,ss:[bp-6]             ; segment okna

         jmp       short DspTBM46           ; dek¢dov n¡ textu bu¤ky

; ------ dek¢dov n¡ ‡¡sla v˜sledku bu¤ky do bufferu v z sobn¡ku

DispTBM4:push      ds
         pop       es                       ; ES <- segment ‡¡sla

         pop       ds                       ; DS <- n vrat datov‚ho segmentu

         mov       dx,ss                    ; DX <- segment bufferu
         push      di
         lea       di,[BP-28-TBLMaxS]       ; adresa bufferu k dek¢dov n¡ ‡¡sla
         call      TBLSMist                 ; nastaven¡ po‡tu desetinn˜ch m¡st
         add       si,TblXReal              ; ‡¡slo k dek¢dov n¡
         mov       cx,TBLMaxS               ; velikost bufferu
         call      TBLDekN                  ; dek¢dov n¡ ‡¡sla do bufferu
         cld
         pop       di

         push      ds                       ; zpˆt £schova DS

         push      ss
         pop       es                       ; ES <- segment ukl dac¡ adresy
         jcxz      DspTBM48                 ; nˆjak  chyba ?

; ------ p©¡prava ukl dac¡ adresy (zde je DS=datov˜ segment) -> DI

         mov       dx,ss:[bp-24]            ; DX <- ¨¡©ka bu¤ky
         cmp       word ptr ds:[TBLMist],0  ; jsou desetinn  m¡sta ?
         je        DspTBM42                 ; nejsou desetinn  m¡sta
         dec       dx                       ; bez desetinn‚ te‡ky
         sub       dx,ds:[TBLMist]          ; zbytek na celou ‡ st ‡¡sla
         jnc       DspTBM42                 ; nen¡ p©ete‡en¡
         xor       dx,dx                    ; DX <- omezen¡ p©i p©ete‡en¡
DspTBM42:sub       dx,bx                    ; DX <- zb˜vaj¡c¡ mezery
         jnc       DspTBM43                 ; je to OK
         xor       dx,dx                    ; omezen¡ p©i p©ete‡en¡

; ------ p©¡prava d‚lky polo‘ky -> CX

DspTBM43:mov       bx,ss:[bp-26]            ; BX <- po‡et zb˜vaj¡c¡ch pozic
         sub       bx,dx                    ; sn¡‘en¡ po‡tu zbyl˜ch pozic
         jbe       DspTBM48                 ; nezbyla ‘ dn  pozice
         cmp       cx,bx                    ; zb˜v  dost m¡sta ?
         jbe       DspTBM44                 ; zb˜v  dost m¡sta
         mov       cx,bx                    ; CX <- omezen¡ d‚lky textu

; ------ dek¢dov n¡ textu do bufferu

DspTBM44:push      ss
         pop       ds                       ; DS <- segment bufferu ‡¡sla
         lea       si,[BP-28-TBLMaxS]       ; buffer ‡¡sla

; ------ dek¢dov n¡ textu do bufferu (barva AH)

DspTBM46:push      di
         add       di,dx
         add       di,dx                    ; zv˜¨en¡ ukl dac¡ adresy
         cld
DspTBM47:lodsb                              ; na‡ten¡ znaku

         test      byte ptr ss:[bp-28],bit6 ; je DEMO verze ?
         jz        DsTBM472                 ; nen¡ DEMO verze
         test      word ptr ss:[bp-12],not (TBLNasR*0fh + 3) ; 16 © dk–, 4 sloupce
         jz        DsTBM472                 ; nen¡ je¨tˆ 16 © dk–/4 sloupce
         cmp       al," "
         je        DsTBM472
         mov       al,"*"

DsTBM472:stosw                              ; ulo‘en¡ znaku
         loop      DspTBM47
         pop       di

DspTBM48:pop       ds

; ------ zv˜¨en¡ ‡¡sla bu¤ky

DspTBM49:mov       ax,ss:[bp-24]            ; ¨¡©ka bu¤ky
         add       di,ax
         add       di,ax                    ; zv˜¨en¡ ukl dac¡ adresy
         sub       ss:[bp-26],ax            ; sn¡‘en¡ ‡¡ta‡e zbyl˜ch pozic
         jbe       DispTBM5                 ; je konec © dku

         mov       ax,ss:[bp-12]            ; ukazatel ‡¡sla bu¤ky
         and       ax,TBLMaskC              ; maska ‡¡sla sloupce
         cmp       ax,TBLMaxC               ; je ji‘ maxim ln¡ sloupec ?
         jae       DispTBM5                 ; je ji‘ maxim ln¡ sloupec

         inc       word ptr ss:[bp-18]      ; zv˜¨en¡ ukazatele v tabulce ¨¡©ek
         inc       word ptr ss:[bp-12]      ; zv˜¨en¡ ‡¡sla sloupce
         jmp       DispTBM3                 ; dal¨¡ sloupec

; ------ zobrazen¡ © dku

DispTBM5:call      DispTBMD                 ; zobrazen¡ © dku

; ------ p©¡prava pro dal¨¡ © dek

         add       word ptr ss:[bp-12],TBLNasR ; zv˜¨en¡ ukazatele ‡¡sla © dku
         dec       byte ptr ss:[bp-9]       ; ‡¡ta‡ © dk– k zobrazen¡
         jz        DispTBM6                 ; byl posledn¡ © dek
         jmp       DispTBM2                 ; dal¨¡ © dek

; ------ zobrazen¡ informa‡n¡ho © dku

DispTBM6:mov       ah,ds:[ColTBLSt]         ; barva informa‡n¡ho © dku
         call      DispTBMC                 ; vymaz n¡ © dku barvou AH

; ------ p©¡prava zbyl˜ch pozic do konce © dku

         mov       al,ss:[bp-10]            ; ¨¡©ka okna - 2
         mov       ah,0
         mov       ss:[bp-26],ax            ; zbyl‚ pozice do konce © dku

; ------ dek¢dov n¡ ‡¡sla bu¤ky (a oprava d‚lky zbyl‚ho textu)

         call      DispTBMB                 ; dek¢dov n¡ ‡¡sla bu¤ky

; ------ p©¡prava barvy

         mov       ah,ds:[ColTBLSt]         ; barva editovan‚ho © dku
         mov       al,ds:[ColTBL2]          ; barva ‡¡sel
         mov       dh,ds:[ColTBL4]          ; barva textu
         mov       dl,ds:[ColTBL6]          ; barva v˜razu

; ------ je editace © dku (barva AH)

         push      ds                       ; £schova datov‚ho segmentu

         mov       ds,ss:[bp-6]             ; adresa segmentu okna
         mov       si,TBLEditB              ; edita‡n¡ buffer
         mov       cx,ds:[TBLEditN]         ; po‡et bajt– v edita‡n¡m bufferu
         add       si,ds:[TBLEditT]         ; posun o po‡ tek textu
         sub       cx,ds:[TBLEditT]         ; sn¡‘en¡ ‡¡ta‡e zbyl‚ d‚lky
         jnc       DispTBM7
         xor       cx,cx
DispTBM7:test      byte ptr ds:[TBLParm],bit6 ; je editace © dku ?
         jnz       DspTBM87                 ; je editace © dku

; ------ nen¡-li kurzor, konec

         test      byte ptr ds:[TBLParm],bit4 ; je kurzor platn˜ ?
         jz        DspTBM89                 ; kurzor nen¡ platn˜

; ------ textov  bu¤ka

         mov       ah,dh                    ; AH <- barva textu
         mov       si,ds:[TBLKurzA]         ; adresa kurzoru
         mov       dh,al
         mov       al,"'"                   ; p©¡znak textu
         test      byte ptr ds:[si+TBLXParm],bit0 ; je to text ?
         jnz       DspTBM85                 ; je to textov  bu¤ka

; ------ ‡¡seln  bu¤ka

         test      byte ptr ds:[si+TBLXParm],bit1 ; je to ‡¡slo ?
         jnz       DspTBM84                 ; je to ‡¡seln  bu¤ka

; ------ rozli¨en¡ v˜razu, zda bude jako ‡¡slo nebo jako text

         mov       ah,dl                    ; AH <- barva v˜razu
         test      byte ptr ss:[bp-28],bit1 ; je zobrazen¡ v˜razu ?
         jz        DsTBM850                 ; nen¡ m¢d zobrazen¡ v˜razu

; ------ dek¢dov n¡ ‡¡sla

DspTBM84:mov       ah,dh                    ; AH <- barva ‡¡sla
         call      DspTBMAS                 ; p©¡znak zobrazen¡ ASCII

         push      ds
         pop       es                       ; ES <- segment ‡¡sla

         pop       ds                       ; DS <- n vrat datov‚ho segmentu

         mov       dx,ss                    ; DX <- segment bufferu
         push      di
         lea       di,[BP-28-TBLMaxS]       ; adresa bufferu k dek¢dov n¡ ‡¡sla
         mov       cx,TBLMaxS               ; velikost bufferu

         call      TBLSMist                 ; nastaven¡ po‡tu desetinn˜ch m¡st
         add       si,TblXReal              ; ‡¡slo k dek¢dov n¡
;         call      TBLSMstM                 ; maximalizace desetinn˜ch m¡st
         call      TBLDekNX                 ; dek¢dov n¡ ‡¡sla do bufferu

         cld
         pop       di

         push      ds                       ; zpˆt £schova DS

         push      ss
         pop       ds                       ; DS <- segment bufferu ‡¡sla
         lea       si,[BP-28-TBLMaxS]       ; buffer ‡¡sla

         push      ss
         pop       es                       ; ES <- segment ukl dac¡ adresy
         jmp       short DspTBM87           ; dek¢dov n¡ ‡¡sla

; ------ zobrazen¡ v˜razu nebo extern¡ bu¤ky

DsTBM850:call      DspTBMAS                 ; p©¡znak zobrazen¡ ASCII
         test      byte ptr ds:[si+TblXParm],bit3 ; je extern¡ bu¤ka ?
         jz        DspTBM86                 ; nen¡ extern¡ bu¤ka

; ------ p©¡znak textov‚ bu¤ky

         mov       al,"["                   ; p©¡znak extern¡ bu¤ky
DspTBM85:stosw                              ; p©¡znak textu
         dec       word ptr ss:[bp-26]      ; sn¡‘en¡ zbyl‚ d‚lky textu

; ------ p©¡prava k zobrazen¡ textu bu¤ky

DspTBM86:mov       cx,ds:[si+TblXOffs]      ; offset dal¨¡ bu¤ky

         pop       ds

         sub       cx,ds:[TBlXText]         ; bez hlavi‡ky
         jbe       DspTBM8A                 ; nen¡ ‘ dn˜ text
         add       si,ds:[TblXText]         ; za‡ tek textu

         push      ds
         mov       ds,ss:[bp-6]             ; adresa segmentu okna

; ------ dek¢dov n¡ textu DS:SI, d‚lka CX, barva AH

DspTBM87:jcxz      DspTBM89                 ; nen¡ ‘ dn˜ znak
         cmp       cx,ss:[bp-26]            ; zb˜v  m‚nˆ znak– ?
         jbe       DspTBM88                 ; zb˜v  dost znak–
         mov       cx,ss:[bp-26]            ; omezen¡ d‚lky textu
DspTBM88:lodsb
         stosw
         loop      DspTBM88

DspTBM89:pop       ds

; ------ zobrazen¡ informa‡n¡ho © dku

DspTBM8A:call      DispTBMD                 ; zobrazen¡ informa‡n¡ho © dku

; ------ zobrazen¡ kurzoru

DispTBM9:mov       es,ss:[bp-6]             ; adresa okna
         mov       si,ss:[bp-2]             ; adresa definice okna
         call      KurzTBL                  ; zobrazen¡ kurzoru

; ------ n vrat registr–

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

DispTBMn ENDP

; ------ p©¡znak zobrazen¡ ASCII

DspTBMAS:test      byte ptr ds:[si+TBLXParm],bit4 ; je ASCII zobrazen¡ ?
         jz        DspTBMA2                 ; nen¡ ASCII zobrazen¡
         mov       al,"*"
         stosw                              ; p©¡znak textu
         dec       word ptr ss:[bp-26]      ; sn¡‘en¡ zbyl‚ d‚lky textu
DspTBMA2:ret

; -----------------------------------------------------------------------------
;        vymaz n¡ © dku barvou AH -> ES:DI za‡ tek bufferu, CH=0
;             (v z sobn¡ku 1 slovo = n vratov  adresa)
; -----------------------------------------------------------------------------

DispTBMC PROC      NEAR

         mov       di,sp
         inc       di
         inc       di                       ; DI <- za‡ tek bufferu
         push      ss
         pop       es                       ; ES <- segment z sobn¡ku

         push      ax
         mov       ah,ds:[ColMnu1R]         ; bˆ‘n  barva okna
         mov       al,"³"                   ; "³"
         stosw                              ; lev˜ okraj
         pop       ax

         push      di
         mov       al," "
         mov       ch,0
         mov       cl,ss:[bp-10]            ; ¨¡©ka okna - 2
         rep       stosw                    ; vymaz n¡ barvou AH

         mov       ah,ds:[ColMnu1L]         ; bˆ‘n  barva okna
         mov       al,"³"                   ; "³" prav˜ okraj
         stosw
         pop       di
         ret

DispTBMC ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ © dku (v z sobn¡ku 1 slovo = n vratov  adresa)
; -----------------------------------------------------------------------------

DispTBMD PROC      NEAR

         mov       si,sp                    ; SI <- buffer v z sobn¡ku
         inc       si
         inc       si                       ; p©esko‡en¡ n vratov‚ adresy
         mov       dx,ss:[bp-8]             ; © dek a pozice
         mov       cl,ss:[bp-10]            ; ¨¡©ka © dku - 2
         mov       ax,ss:[bp-16]            ; hladina k zobrazen¡
         inc       cx
         inc       cx                       ; ¨¡©ka © dku
         call      far ptr DispMStr         ; zobrazen¡ © dku
         inc       byte ptr ss:[bp-7]       ; zv˜¨en¡ ukazatele © dku
         ret

DispTBMD ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ © dku nadpisu (CLD, CH=0, ES:DI=za‡ tek © dku, BP=promˆnn‚)
; -----------------------------------------------------------------------------

DispTBNS PROC      NEAR

; ------ po‡et bunˆk v tabulce -> AX

         push      ds
         mov       ds,ss:[bp-6]             ; adresa okna
         mov       ax,ds:[TblBunN]          ; po‡et bunˆk v tabulce
         pop       ds

; ------ dek¢dov n¡ po‡tu bunˆk

         push      di
         mov       cl,ss:[bp-10]            ; ¨¡©ka © dku - 2
         mov       ch,0
         add       di,cx
         add       di,cx                    ; konec © dku
         mov       bh,ds:[ColTBL1]          ; barva stavov‚ho © dku
         mov       bl,0                     ; nen¡ oddˆlova‡ © d–
         xor       dx,dx
         call      far ptr DekNumD          ; dek¢dov n¡ ‡¡sla
         pop       di

; ------ p©¡prava registr–

         mov       ah,ds:[ColTBL11]         ; barva nadpisu

         push      ds                       ; datov˜ segment
         mov       ds,ss:[bp-6]             ; segment okna

; ------ nastaven¡ p©¡znaku modifikace

         push      di                       ; za‡ tek textu v bufferu

         mov       al," "                   ; mezera - nen¡ ‘ dn˜ p©¡znak
         test      byte ptr ds:[TBLParm],bit0 ; je buffer modifikov n ?
         jz        DspTBNS1                 ; buffer nen¡ modifikov n
         mov       al,"!"                   ; p©¡znak modifikace bufferu
DspTBNS1:test      byte ptr ds:[TBLParm],bit1 ; je z kaz z pisu ?
         jz        DspTBNS2                 ; nen¡ z kaz z pisu
         mov       al,"*"                   ; ozna‡en¡ z kazu z pisu
DspTBNS2:stosb                              ; p©¡znak p©ed jm‚nem souboru

; ------ dek¢dov n¡ jm‚na souboru (CH=0 !)

         mov       cl,8                     ; d‚lka jm‚na souboru
         mov       si,TBLName               ; jm‚no souboru
DspTBNS3:inc       di
         movsb
         loop      DspTBNS3

         pop       di                       ; za‡ tek textu v bufferu

; ------ p©¡prava d‚lky nadpisu -> CL

         mov       cl,ds:[TBLNKom]          ; d‚lka koment ©e
         mov       bl,ss:[bp-10]            ; ¨¡©ka © dku - 2
         cmp       cl,bl                    ; je d‚lka textu OK ?
         jb        DspTBNS4                 ; d‚lka textu je OK
         mov       cl,bl                    ; omezen¡ d‚lky textu

; ------ vyst©edˆn¡ textu nadpisu

DspTBNS4:mov       bh,0                     ; BX = ¨¡©ka © dku - 2
         sub       bx,cx                    ; zbytek na okraje
         and       bl,not bit0              ; zarovn n¡
         add       di,bx                    ; adresa k ulo‘en¡ textu

; ------ dek¢dov n¡ nadpisu

         jcxz      DspTBNS6
         mov       si,TBLKom                ; koment ©
DspTBNS5:lodsb
         stosw
         loop      DspTBNS5

DspTBNS6:pop       ds
         ret

DispTBNS ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ ‡¡sel sloupc– (CLD, CH=0, ES:DI=za‡ tek © dku, BP=promˆnn‚)
; -----------------------------------------------------------------------------

DispTBCN PROC      NEAR

; ------ p©¡prava k dek¢dov n¡ ozna‡en¡ sloupc–

         push      ds
         mov       ah,ds:[ColTBLRS]         ; barva p©ep¡na‡–

         mov       ds,ss:[bp-6]             ; DS <- adresa segmentu okna

         mov       cl,bit4                  ; maska
         mov       al,"A"                   ; automatick˜ p©epo‡et
         call      DsSTBCN                  ; zobrazen¡ p©ep¡na‡e
         mov       al,"V"                   ; m¢d zobrazen¡ v˜raz–
         call      DsSTBCN                  ; zobrazen¡ p©ep¡na‡e
         mov       al,"R"                   ; v˜po‡ty £hl– v RAD
         call      DsSTBCN                  ; zobrazen¡ p©ep¡na‡e
         mov       al,"F"                   ; m¢d formul ©e
         call      DsSTBCN                  ; zobrazen¡ p©ep¡na‡e

;         dec       di
;         dec       di                       ; p©ednastaven¡

         mov       cl,ss:[bp-10]            ; ¨¡©ka © dku - 2
         sub       cl,4                     ; zbyl  ¨¡©ka © dku

; ------ ukazatel v tabulce ¨¡©ek -> SI, ‡¡slo sloupce -> AX

         mov       ax,ds:[TBLTop]           ; po‡ te‡n¡ bu¤ka
         and       ax,TBLMaskC              ; AX <- ‡¡slo sloupce
         mov       si,TblSirTb-1            ; SI <- tabulka ¨¡©ek - 1
         add       si,ax                    ; SI <- adresa v tabulce ¨¡©ek

; ------ p©¡prava ¨¡©ky sloupce -> BX

DspTBCN2:inc       si                       ; zv˜¨en¡ ukazatele v tabulce ¨¡©ek
         mov       bh,0
         mov       bl,ds:[si]               ; BX <- ¨¡©ka sloupce

; ------ mezi£schova registr–

         push      di                       ; ukl dac¡ adresa

; ------ ukl dac¡ adresa k ulo‘en¡ ‡¡sla sloupce -> DI

         mov       dx,bx                    ; DX <- ¨¡©ka sloupce
         shr       dx,1                     ; polovina
         add       dl,2                     ; 2 znaky rezerva
         cmp       dl,cl                    ; le‘¡ za koncem © dku ?
         jae       DspTBCN6                 ; le‘¡ za koncem © dku
         sub       dl,2                     ; n vrat
         shl       dx,1                     ; offset
         add       di,dx                    ; adresa k ulo‘en¡ ‡¡sla sloupce

; ------ dek¢dov n¡ ozna‡en¡ sloupce

         push      ax                       ; ‡¡slo sloupce
         mov       dl,26                    ; dˆlitel ‡¡seln‚ soustavy
         div       dl                       ; p©epo‡et na znaky
         add       ax,"AA"-1                ; p©epo‡et na ASCII znaky

         cmp       al,"A"                   ; je prvn¡ znak platn˜ ?
         jb        DspTBCN4                 ; nen¡ platn˜ znak
         mov       es:[di-2],al             ; ulo‘en¡ prvn¡ho (vy¨¨¡ho) znaku
;         stosb                              ; ulo‘en¡ prvn¡ho (vy¨¨¡ho) znaku
;         inc       di                       ; p©esko‡en¡ atributu barvy

DspTBCN4:mov       al,ah                    ; AL <- ni‘¨¡ znak ‡¡sla sloupce
         stosb                              ; ulo‘en¡ ni‘¨¡ho znaku ‡¡sla
         pop       ax                       ; AX <- ‡¡slo sloupce

; ------ n vrat registr–

DspTBCN6:pop       di                       ; ukl dac¡ adresa

; ------ zv˜¨en¡ ‡¡sla sloupce

         inc       ax                       ; zv˜¨en¡ ‡¡sla sloupce
         cmp       al,TBLMaxC               ; je ji‘ maxim ln¡ sloupec ?
         ja        DspTBCN8                 ; je ji‘ maxim ln¡ sloupec

; ------ posun ukl dac¡ adresy (BX=¨¡©ka sloupce)

         add       di,bx
         add       di,bx                    ; zv˜¨en¡ ukl dac¡ adresy
         sub       cl,bl                    ; sn¡‘en¡ ‡¡ta‡e ¨¡©ek
         ja        DspTBCN2                 ; bude dal¨¡ sloupec

; ------ n vrat registr–

DspTBCN8:pop       ds
         ret

DispTBCN ENDP

; ------ zobrazen¡ p©ep¡na‡e AL (maska CL)

DsSTBCN: test      byte ptr ds:[TblIParm],cl ; je p©ep¡na‡ nastaven ?
         jnz       DsSTBCN2                 ; p©ep¡na‡ nastaven
         mov       al,"-"                   ; p©ep¡na‡ vypnut
DsSTBCN2:stosw                              ; ulo‘en¡ znaku
         shl       cl,1                     ; posun masky
         ret

; -----------------------------------------------------------------------------
;        dek¢dov n¡ ‡¡sla bu¤ky (je CLD !) (provede korekci SS:[BP-26])
; -----------------------------------------------------------------------------

DispTBMB PROC      NEAR

; ------ £schova za‡ tku ukl dac¡ adresy

         mov       dx,di                    ; DX <- £schova ukl dac¡ adresy

; ------ p©¡znak z kazu z pisu do bu¤ky

         test      byte ptr ss:[bp-28],bit5 ; je kurzor R/O ?
         jz        DspTBMB1                 ; kurzor nen¡ R/O
         mov       al,"*"                   ; p©¡znak R/O
         stosb                              ; ulo‘en¡ p©¡znaku R/O
         inc       di                       ; p©esko‡en¡ atributu barvy

; ------ ‡¡slo bu¤ky s kurzorem -> AX

DspTBMB1:mov       ax,ss:[bp-20]            ; bu¤ka s kurzorem

; ------ p©epo‡et sloupce s bu¤kou na ASCII znaky

         push      ax                       ; £schova ‡¡sla bu¤ky s kurzorem
         and       ax,TBLMaskC              ; maska ‡¡sla sloupce
         mov       cl,26                    ; ‡¡seln  soustava
         div       cl                       ; rozdˆlen¡ na ‡¡slice
         add       ax,"AA"-1                ; korekce na ASCII znaky

; ------ ulo‘en¡ prvn¡ho znaku ‡¡sla sloupce (jen je-li platn˜)

         cmp       al,"A"                   ; je prvn¡ p¡smeno platn˜ znak ?
         jb        DspTBMB2                 ; nen¡ to platn˜ znak
         stosb                              ; ulo‘en¡ prvn¡ho p¡smene
         inc       di                       ; p©esko‡en¡ atributu barvy

; ------ ulo‘en¡ druh‚ho znaku ‡¡sla sloupce

DspTBMB2:mov       al,ah                    ; AL <- druh˜ znak ‡¡sla sloupce
         stosb                              ; ulo‘en¡ druh‚ho znaku ‡¡sla sloupce
         inc       di                       ; p©esko‡en¡ atributu barvy
         pop       ax                       ; n vrat ‡¡sla bu¤ky s kurzorem

; ------ dek¢dov n¡ ‡¡sla © dku bu¤ky s kurzorem

         mov       cl,TBLRotR               ; po‡et rotac¡ pro p©evod
         shr       ax,cl                    ; rotace ‡¡sla © dku na pozici
         inc       ax                       ; korekce ‡¡sla © dku (+1)
         mov       bh,ds:[ColTBLSt]         ; barva informa‡n¡ho © dku
         call      far ptr DekNumW          ; dek¢dov n¡ ‡¡sla © dku

; ------ ulo‘en¡ oddˆlova‡e za ‡¡slem bu¤ky

         cld
         mov       al,":"                   ; oddˆlovac¡ znak ":"
         stosb                              ; ulo‘en¡ oddˆlova‡e
         add       di,3                     ; p©esko‡en¡ barvy a znaku mezery

; ------ oprava ‡¡ta‡e zbyl˜ch znak–

         sub       dx,di                    ; DX <- -d‚lka textu ve znac¡ch
         sar       dx,1                     ; -d‚lka textu v bajtech
         add       ss:[bp-26],dx            ; sn¡‘en¡ ‡¡ta‡e zbyl‚ d‚lky textu
         ret

DispTBMB ENDP

; -----------------------------------------------------------------------------
;        korekce menu tabulky DS:SI
; -----------------------------------------------------------------------------

KorTBMn  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      di
         push      es

; ------ adresa okna -> ES

         call      TBLAdrES                 ; adresa okna -> ES

; ------ p©¡prava textu n povˆdy

         mov       bx,offset TBLMnHlA       ; je operace s blokem - p©esun
         test      byte ptr ds:[TBLTParm],bit3 ; je ji‘ konec bloku ?
         jnz       KorTBM01                 ; je ji‘ konec bloku
         mov       bx,offset TBLMnHl9       ; je operace s blokem
KorTBM01:test      byte ptr ds:[TBLTParm],bit5 ; je operace s blokem ?
         jnz       KorTBMn0                 ; je operace s blokem
;         mov       bx,offset TBLMnHl8       ; je nastaven¡ ¨¡©ky sloupce
;         test      byte ptr ds:[TBLTParm],bit6 ; je nastaven¡ ¨¡©ky ?
;         jnz       KorTBMn0                 ; je nastaven¡ ¨¡©ky sloupce
         mov       bx,offset TBLMnHl0       ; nen¡ editace, je formul ©
         test      byte ptr es:[TBLIParm],bit7 ; je formul © ?
         jnz       KorTBM02                 ; je formul ©
         mov       bx,offset TBLMnHl1       ; nen¡ editace
KorTBM02:test      byte ptr es:[TBLParm],bit6 ; je editace © dku ?
         jz        KorTBMn0                 ; nen¡ editace © dku
         mov       bx,offset TBLMnHl2       ; nen¡ je¨tˆ ‘ dn˜ znak
         cmp       word ptr es:[TBLEditN],0 ; je nˆjak˜ znak ?
         je        KorTBMn0                 ; nen¡ je¨tˆ ‘ dn˜ znak
         mov       al,es:[TBLEditB]         ; prvn¡ znak z bufferu
         mov       bx,offset TBLMnHl5       ; extern¡ bu¤ka
         cmp       al,"["
         je        KorTBMn0                 ; je extern¡ bu¤ka
         mov       bx,offset TBLMnHl4       ; v˜raz
         call      KorTBVyr                 ; test, zda je AL v˜raz
         jnc       KorTBMn0                 ; je to v˜raz
         mov       bx,offset TBLMnHl3       ; jinak je to text
KorTBMn0:mov       ds:[si+MnuHlp],bx        ; adresa n povˆdy

; ------ aktu ln¡ po‡ tek -> DI

         mov       di,es:[TBLTop]           ; aktu ln¡ po‡ tek

; ------ p©¡prava ¨¡©ky okna -> CX

         mov       cl,ds:[si+MnuSir]        ; ¨¡©ka okna
         sub       cl,6                     ; bez okraj–
         mov       ch,0

; ------ omezen¡ po‡ te‡n¡ pozice, aby po‡ tek nebyl za kurzorem

         mov       ax,es:[TBLKurz]          ; bu¤ka s kurzorem
         and       ax,TBLMaskC              ; ‡¡slo sloupce s kurzorem
         mov       bx,di                    ; prvn¡ zobrazen  bu¤ka
         and       bx,TBLMaskC              ; ‡¡slo prvn¡ho sloupce
         cmp       ax,bx                    ; je kurzor za po‡ tkem ?
         jae       KorTBMn1                 ; po‡ tek je OK
         and       di,not TBLMaskC          ; nulov n¡ star‚ho po‡ tku
         or        di,ax                    ; nov˜ po‡ tek podle kurzoru
         mov       bx,ax                    ; BX <- nov˜ po‡ tek

; ------ test, zda je kurzor cel˜ zobrazen

KorTBMn1:sub       ax,bx                    ; AX <- kurzor relativnˆ od po‡ tku
         jz        KorTBMn4                 ; kurzor je ji‘ na po‡ tku
         add       bx,TblSirTb              ; BX <- ukazatel po‡ tku v tabulce

KorTBMn2:push      ax
         push      bx
         push      cx

         inc       ax                       ; v‡etnˆ kurzoru
KorTBMn3:sub       cl,es:[bx]               ; p©i‡ten¡ ¨¡©ky pole
         sbb       ch,0
         jc        KorTBM34                 ; p©ete‡en¡ p©es konec © dku
         inc       bx                       ; zv˜¨en¡ ukazatele v tabulce
         dec       ax                       ; ‡¡ta‡ sloupc–
         jnz       KorTBMn3                 ; dal¨¡ sloupec

KorTBM34:pop       cx
         pop       bx
         pop       ax

         jnc       KorTBMn4                 ; nen¡ p©ete‡en¡ kurzoru

         inc       di                       ; zv˜¨en¡ ‡¡sla sloupce po‡ tku
         inc       bx                       ; zv˜¨en¡ ukazatele v tabulce
         dec       ax
         jnz       KorTBMn2

; ------ kontrola © dku po‡ tku, zda nele‘¡ za kurzorem

KorTBMn4:mov       ax,es:[TBLKurz]          ; bu¤ka s kurzorem
         and       ax,TBLMaskR              ; ‡¡slo © dku s kurzorem
         mov       bx,di                    ; prvn¡ zobrazen  bu¤ka
         and       bx,TBLMaskR              ; ‡¡slo prvn¡ho © dku
         cmp       ax,bx                    ; je kurzor za po‡ tkem ?
         jae       KorTBMn5                 ; po‡ tek je OK
         and       di,not TBLMaskR          ; nulov n¡ star‚ho po‡ tku
         or        di,ax                    ; nov˜ po‡ tek podle kurzoru
         mov       bx,ax                    ; BX <- nov˜ po‡ tek

; ------ p©¡prava v˜¨ky okna -> DX

KorTBMn5:mov       dl,ds:[si+MnuVys]        ; v˜¨ka okna
         sub       dl,6                     ; bez okraj– + 1
         mov       dh,0
         mov       cl,TBLRotR               ; rotace pro p©epo‡et
         shl       dx,cl                    ; p©evod v˜¨ky na © dek bu¤ky

; ------ kontrola © dku po‡ tku, zda nen¡ p©¡li¨ vzd len nad kurzorem

         sub       ax,dx                    ; kurzor - v˜¨ka okna
         jnc       KorTBMn6
         xor       ax,ax                    ; omezen¡ p©i p©ete‡en¡
KorTBMn6:cmp       ax,bx                    ; je po‡ tek OK ?
         jbe       KorTBMn7                 ; po‡ tek je OK
         and       di,not TBLMaskR          ; nulov n¡ star‚ho po‡ tku
         or        di,ax                    ; nov˜ po‡ tek podle kurzoru

; ------ kontrola maxim ln¡ho po‡ tku

KorTBMn7:mov       ax,(TBLMaxR+1)*TBLNasR   ; maxim ln¡ © dek
         sub       ax,dx                    ; maxim ln¡ © dek
         cmp       ax,di
         ja        KorTBMn8
         sub       ax,1*TBLNasR
         and       di,not TBLMaskR
         or        di,ax

; ------ nastaven¡ nov‚ho po‡ tku DI

KorTBMn8:cmp       di,es:[TBLTop]           ; byl po‡ tek zmˆnˆn ?
         je        KorTBMn9                 ; po‡ tek nebyl zmˆnˆn
         mov       es:[TBLTop],di           ; nastaven¡ nov‚ho po‡ tku
         call      TBLITop                  ; inicializace po‡ tku

; ------ korekce po‡ tku p©i editaci © dku

KorTBMn9:test      byte ptr es:[TBLParm],bit6 ; je editace © dku ?
         jz        KorTBMnA                 ; nen¡ editace © dku

; ------ ¨¡©ka editovan‚ho © dku -> CX

         mov       cl,ds:[si+MnuSir]        ; ¨¡©ka okna
         sub       cl,2+10+1                ; bez okraj– + bu¤ka "*BL999: *[" + 1
         mov       ch,0

; ------ maxim ln¡ po‡ tek -> DX

         mov       dx,es:[TBLEditN]         ; po‡et bajt– v bufferu
         sub       dx,cx                    ; po‡ tek
         jnc       KorTBM92
         xor       dx,dx                    ; omezen¡

; ------ kontrola podte‡en¡ kurzoru pod po‡ tek

KorTBM92:mov       bx,es:[TBLEditT]         ; po‡ tek
         mov       ax,es:[TBLEditK]         ; kurzor
         cmp       ax,bx                    ; je podte‡en¡ ?
         jae       KorTBM94                 ; nen¡ podte‡en¡
         mov       bx,ax                    ; BX <- omezen¡

; ------ kontrola p©ete‡en¡ kurzoru za po‡ tek

KorTBM94:sub       ax,cx                    ; minim ln¡ po‡ tek
         jnc       KorTBM95
         xor       ax,ax
KorTBM95:cmp       ax,bx                    ; je po‡ tek OK ?
         jb        KorTBM96                 ; po‡ tek je OK
         mov       bx,ax                    ; BX <- omezen¡

; ------ kontrola maxim ln¡ho po‡ tku

KorTBM96:cmp       bx,dx
         jbe       KorTBM97
         mov       bx,dx

KorTBM97:mov       es:[TBLEditT],bx         ; nov˜ po‡ tek

; ------ n vrat registr–

KorTBMnA:pop       es
         pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

KorTBMn  ENDP

; -----------------------------------------------------------------------------
;        test, zda je znak AL prvn¡ znak v˜razu -> NC=je v˜raz/‡¡slo
; -----------------------------------------------------------------------------

KorTBVyr PROC      NEAR

         cmp       al,"["                   ; extern¡ bu¤ka ?
         je        KorTBVr9                 ; je extern¡ bu¤ka
         cmp       al,"("                   ; z vorka
         je        KorTBVr9                 ; je v˜raz
         cmp       al,"*"                   ; ASCII zobrazen¡ ‡¡sla
         je        KorTBVr9                 ; je v˜raz
         cmp       al,"+"                   ; un rn¡ "+"
         je        KorTBVr9                 ; je ‡¡slo
         cmp       al,"-"                   ; un rn¡ "-"
         je        KorTBVr9                 ; je ‡¡slo
         cmp       al,"."                   ; desetinn  te‡ka
         je        KorTBVr9                 ; je ‡¡slo
         cmp       al,","
         je        KorTBVr9                 ; je ‡¡slo

         cmp       al,"0"
         jb        KorTBVr9                 ; nen¡ ‡¡slo
         cmp       al,"9"+1
         cmc                                ; CY=nen¡ ‡¡slo
KorTBVr9:ret

KorTBVyr ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ kurzoru tabulky (ES=segment okna, DS:SI=definice okna)
; -----------------------------------------------------------------------------

KurzTBL  PROC      NEAR

; ------ vypnut¡ kurzoru, nen¡-li editace

         test      byte ptr es:[TBLParm],bit6 ; je editace ?
         jnz       KurzTBL1                 ; je editace
         test      byte ptr es:[TBLIParm],bit7 ; je m¢d formul ©e ?
         jnz       KurzTBL0                 ; je m¢d formul ©e
         call      far ptr KurzOff          ; vypnut¡ kurzoru
         ret

; ------ zobrazen¡ kurzoru v m¢du formul ©e

KurzTBL0:push      ax
         push      bx
         push      cx
         push      dx

         mov       dx,word ptr ds:[si+MnuPoz] ; © dek a pozice okna
         mov       cx,es:[TBLKurz]          ; bu¤ka s kurzorem
         mov       bx,es:[TBLTop]           ; prvn¡ zobrazen  bu¤ka
         and       cx,TBLMaskC              ; maska ‡¡sla sloupce kurzoru
         and       bx,TBLMaskC              ; maska ‡¡sla sloupce po‡ tku
         sub       cx,bx                    ; vzd lenost kurzoru od po‡ tku
         jbe       KrzTBL02                 ; kurzor na po‡ tku tabulky

         add       bx,TblSirTb              ; adresa v tabulce ¨¡©ek
KrzTBL01:add       dl,es:[bx]               ; p©i‡ten¡ ¨¡©ky sloupce
         inc       bx
         loop      KrzTBL01

KrzTBL02:mov       ax,es:[TBLKurz]          ; bu¤ka s kurzorem
         mov       bx,es:[TBLTop]           ; prvn¡ zobrazen  bu¤ka
         and       ax,TBLMaskR              ; maska ‡¡sla © dku kurzoru
         and       bx,TBLMaskR              ; maska ‡¡sla © dku po‡ tku
         sub       ax,bx                    ; vzd lenost kurzoru od po‡ tku
         mov       cl,TBLRotR               ; po‡et rotac¡ ‡¡sla © dku
         shr       ax,cl                    ; ‡¡slo © dku relativnˆ
         add       dh,al                    ; ‡¡slo © dku relativnˆ

         add       dl,5                     ; p©i‡ten¡ okraje okna
         add       dh,3                     ; p©i‡ten¡ okraje okna

         call      far ptr SetKurz          ; nastaven¡ kurzoru
         call      far ptr SizeLKur         ; n¡zk˜ kurzor, je-li INSERT

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

; ------ £schova registr–

KurzTBL1:push      ax
         push      dx

; ------ z kladn¡ © dek a pozice kurzoru

         mov       ax,es:[TBLKurz]          ; bu¤ka s kurzorem
         mov       dx,word ptr ds:[si+MnuPoz] ; © dek a pozice menu
         add       dh,ds:[si+MnuVys]        ; + v˜¨ka
         add       dl,es:[TBLEditK]         ; p©i‡ten¡ kurzoru
         sub       dl,es:[TBLEditT]         ; ode‡ten¡ po‡ tku
         sub       dh,2                     ; korekce © dku
         add       dl,5                     ; korekce pozice

; ------ korekce pozice, je-li z kaz z pisu (zobraz¡ se indik tor "*")

         test      byte ptr es:[TBLParm],bit5 ; je kurzor R/O ?
         jz        KurzTBL2                 ; kurzor nen¡ R/O
         inc       dx                       ; zv˜¨en¡ pozice

; ------ posun kurzoru podle d‚lky ‡¡sla bu¤ky

KurzTBL2:cmp       ax,9*TBLNasR             ; je © dek 10 a v¡ce ?
         jb        KurzTBL3                 ; je © dek men¨¡ ne‘ 10
         inc       dx                       ; zv˜¨en¡ pozice

KurzTBL3:cmp       ax,99*TBLNasR            ; je © dek 100 a v¡ce ?
         jb        KurzTBL4                 ; je © dek men¨¡ ne‘ 100
         inc       dx                       ; zv˜¨en¡ pozice

KurzTBL4:and       al,TBLMaskC              ; sloupec bu¤ky
         cmp       al,26                    ; je sloupec "AA" a v¡ce ?
         jb        KurzTBL5                 ; sloupec m  1 p¡smeno
         inc       dx                       ; zv˜¨en¡ pozice

; ------ nastaven¡ pozice kurzoru

KurzTBL5:call      far ptr SetKurz          ; nastaven¡ kurzoru

; ------ nastaven¡ velikosti kurzoru

         test      byte ptr es:[TBLParm],bit7 ; je opravn  editace ?
         jz        KurzTBL7                 ; nen¡ opravn  editace
         test      byte ptr ds:[TBLTParm],bit7 ; je INSERT ?
         jnz       KurzTBL7                 ; je INSERT
         call      far ptr SizeHKur         ; vysok˜ kurzor, nen¡-li INSERT
         jmp       short KurzTBL8

KurzTBL7:call      far ptr SizeLKur         ; n¡zk˜ kurzor, je-li INSERT

; ------ n vrat registr–

KurzTBL8:pop       dx
         pop       ax
         ret

KurzTBL  ENDP

; -----------------------------------------------------------------------------
;        inicializace po‡ tku a kurzoru menu DS:SI
; -----------------------------------------------------------------------------

TBLIni   PROC      NEAR

         push      es
         call      TBLAdrES                 ; adresa okna -> ES
         call      TBLITop                  ; inicializace po‡ tku
         call      TBLIKur                  ; inicializace kurzoru
         pop       es
         ret

TBLIni   ENDP

; -----------------------------------------------------------------------------
;        inicializace po‡ tku v oknˆ ES
; -----------------------------------------------------------------------------

TBLITop  PROC      NEAR

         push      ax
         push      di

         mov       ax,es:[TBLTop]           ; bu¤ka s po‡ tkem
         call      TBLSrc                   ; nalezen¡ adresy po‡ tku
         mov       es:[TBLTopA],di          ; adresa po‡ tku

         pop       di
         pop       ax
         ret

TBLITop  ENDP

; -----------------------------------------------------------------------------
;        inicializace kurzoru v oknˆ ES
; -----------------------------------------------------------------------------

TBLIKur  PROC      NEAR

         push      ax
         push      di

         and       byte ptr es:[TBLParm],not bit4+bit5 ; kurzor je neplatn˜
         mov       ax,es:[TBLKurz]          ; bu¤ka s kurzorem
         call      TBLSrc                   ; nalezen¡ adresy kurzoru
         mov       es:[TBLKurzA],di         ; adresa kurzoru
         jc        TBLIKur2                 ; kurzor je neplatn˜
         or        byte ptr es:[TBLParm],bit4 ; kurzor je platn˜
         test      byte ptr es:[di+TblXParm],bit7 ; je z kaz z pisu do bu¤ky ?
         jz        TBLIKur2                 ; nen¡ z kaz z pisu
         or        byte ptr es:[TBLParm],bit5 ; p©¡znak z kazu z pisu

TBLIKur2:pop       di
         pop       ax
         ret

TBLIKur  ENDP

; -----------------------------------------------------------------------------
;    vyhled n¡ bu¤ky AX v oknˆ ES -> DI=adresa, CY=nenalezeno (DI=n sleduj¡c¡)
; -----------------------------------------------------------------------------

TBLSrc   PROC      NEAR

         push      cx

         mov       cx,es:[TblBunN]          ; po‡et bunˆk tabulky
         mov       di,TblDat                ; za‡ tek dat tabulky
         jcxz      TBLSrc8                  ; nen¡ ‘ dn  bu¤ka

TBLSrc2: cmp       ax,es:[di+TblXBunk]      ; je to hledan  bu¤ka ?
         jbe       TBLSrc9                  ; nalezeno nebo je vˆt¨¡ bu¤ka
         add       di,es:[di+TblXOffs]      ; adresa dal¨¡ bu¤ky
         loop      TBLSrc2                  ; test dal¨¡ bu¤ky

TBLSrc8: stc                                ; p©¡znak nenalezen¡ bu¤ky

TBLSrc9: pop       cx
         ret

TBLSrc   ENDP

; -----------------------------------------------------------------------------
; vytvo©en¡ bu¤ky AX na adrese ES:DI, d‚lka textu CX, typ DL, menu DS:SI -> CY, DI=text
; -----------------------------------------------------------------------------

TBLBIns  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx

; ------ vytvo©en¡ m¡sta pro bu¤ku AX

         add       cx,ds:[TblXText]         ; v‡etnˆ z hlav¡
         push      ax                       ; ‡¡slo bu¤ky
         mov       ax,ds:[si+TbMnuSeg]      ; segment bufferu tabulky
         call      far ptr InsDat           ; vlo‘en¡ bu¤ky
         pop       ax                       ; ‡¡slo bu¤ky
         jc        TBLBIns8                 ; chyba pamˆti

; ------ p©¡znak modifikace tabulky

         or        byte ptr es:[TBLParm],bit0 ; p©¡znak modifikace tabulky
         inc       word ptr es:[TblBunN]    ; zv˜¨en¡ po‡tu bunˆk

; ------ inicializace z hlav¡ bu¤ky

         cld
         xchg      ax,cx                    ; AX <- d‚lka bu¤ky
         stosw                              ; ulo‘en¡ d‚lky bu¤ky
         xchg      ax,cx                    ; AX <- ‡¡slo bu¤ky
         stosw                              ; ulo‘en¡ ‡¡sla bu¤ky
         mov       al,dl                    ; AL <- parametry bu¤ky
         stosb                              ; ulo‘en¡ parametr– bu¤ky
         mov       cx,ds:[TBLNumXW]         ; d‚lka hodnoty bu¤ky (slov)
         xor       ax,ax                    ; AX <- 0
         rep       stosw                    ; vynulov n¡ ‡¡sla hodnoty
;         clc                                ; p©¡znak operace OK
         jmp       short TBLBIns9           ; operace OK

; ------ chyba pamˆti

TBLBIns8:call      far ptr MemErr           ; chyba pamˆti

; ------ n vrat registr–

TBLBIns9:pop       cx
         pop       ax
         ret

TBLBIns  ENDP

; -----------------------------------------------------------------------------
;        zru¨en¡ bu¤ky na adrese ES:DI (mus¡ b˜t platn  !), menu DS:SI
; -----------------------------------------------------------------------------

TBLBDel  PROC      NEAR

         push      ax
         push      cx

         or        byte ptr es:[TBLParm],bit0 ; p©¡znak modifikace tabulky

         dec       word ptr es:[TblBunN]    ; sn¡‘en¡ po‡tu bunˆk
         mov       ax,ds:[si+TbMnuSeg]      ; segment bufferu tabulky
         mov       cx,es:[di+TblXOffs]      ; d‚lka bu¤ky
         call      far ptr DelDat           ; zru¨en¡ bu¤ky

         pop       cx
         pop       ax
         ret

TBLBDel  ENDP

; -----------------------------------------------------------------------------
;        aktualizace adresy okna DS:SI -> ES (uchov v  p©¡znaky !)
; -----------------------------------------------------------------------------

TBLAdrES PROC      NEAR

         pushf
         push      ax

         mov       ax,ds:[si+TBMnuSeg]      ; segment tabulky
         call      far ptr GetDat           ; nov  adresa tabulky

         pop       ax
         popf
         ret

TBLAdrES ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ ‡¡sla z textu
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=text k na‡ten¡
;        ES:DI=buffer k ulo‘en¡ ‡¡sla
;        CX=po‡et zbyl˜ch znak– textu ‡¡sla (maxim lnˆ TBLMaxS !)
;        DS=datov˜ segment
; VSTUP: ES:SI=nov˜ ukazatel textu
;         CX=nov˜ po‡et zbyl˜ch znak–
;         CY=nen¡ ‡¡slo
; -----------------------------------------------------------------------------

TBLInpN  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      di
         push      bp
         mov       bp,sp
         sub       sp,TBLMaxS               ; buffer pro £schovu ‡¡sla

; ------ p©¡prava k £schovˆ ‡¡sla do bufferu v z sobn¡ku (pozor na po‡et registr– !)

         cld
         push      dx
         push      di                       ; buffer k ulo‘en¡ ‡¡sla
         push      es
         push      ds

         mov       dl,ds:[OddelDes]         ; oddˆlova‡ desetin
         mov       dh,ds:[OddelRad]         ; oddˆlova‡ © d–
         mov       di,sp                    ; DI <- buffer v z sobn¡ku
         add       di,4*2                   ; p©esko‡en¡ registr– v z sobn¡ku
         push      es
         pop       ds                       ; DS <- segment ‡¡sla k dek¢dov n¡
         push      ss
         pop       es                       ; ES <- segment bufferu v z sobn¡ku

; ------ p©enesen¡ po za‡ tek ‡¡sla

TBLInpN1:jcxz      TBLInpN8                 ; nen¡ dal¨¡ znak
         lodsb                              ; na‡ten¡ znaku
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e znak–
         cmp       al,"+"                   ; je un rn¡ "+" ?
         je        TBLInpN1                 ; un rn¡ "+" se ignoruje
         cmp       al,"-"                   ; je un rn¡ "-" ?
         jne       TBLInpN4                 ; nen¡ un rn¡ "-"
         stosb                              ; ulo‘en¡ znaku do bufferu
         jmp       short TBLInpN1           ; dal¨¡ znak

; ------ p©enesen¡ ‡¡sla

TBLInpN3:jcxz      TBLInpN8                 ; nen¡ dal¨¡ znak
         lodsb                              ; na‡ten¡ znaku
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e znak–
TBLInpN4:cmp       al,dl                    ; oddˆlova‡ desetin ?
         je        TBLInpN5                 ; je oddˆlova‡ desetin
         cmp       al,dh                    ; oddˆlova‡ © d– ?
         je        TBLInpN5                 ; je oddˆlova‡ © d–
         cmp       al,"0"                   ; je ‡¡slice ?
         jb        TBLInpN7                 ; nen¡ ‡¡slice
         cmp       al,"9"                   ; je ‡¡slice ?
         ja        TBLInpN7                 ; nen¡ ‡¡slice
TBLInpN5:stosb                              ; ulo‘en¡ znaku do z sobn¡ku
         jmp       short TBLInpN3           ; dal¨¡ znak

TBLInpN7:dec       si                       ; n vrat neplatn‚ho znaku
         inc       cx

; ------ ozna‡en¡ konce ‡¡sla

TBLInpN8:mov       al,0
         stosb                              ; koncov  0

         pop       ds
         pop       es
         pop       di                       ; DI <- buffer k ulo‘en¡ ‡¡sla
         pop       dx

; ------ na‡ten¡ ‡¡sla (ES:DI=buffer k na‡ten¡ ‡¡sla, SS:SI=text ‡¡sla)

         push      si
         mov       si,sp                    ; SI <- text ‡¡sla - 2
         inc       si                       ; p©esko‡en¡ registru v z sobn¡ku
         inc       si
         cmp       byte ptr ss:[si],1       ; je nˆjak˜ text ‡¡sla ?
         jb        TBLInpN9                 ; nen¡ ‘ dn‚ ‡¡slo
         call      TBLSetRg                 ; nastaven¡ registr– pro v˜po‡et
         call      far ptr KalkNumF         ; na‡ten¡ ‡¡sla z textu
         call      TBLResRg                 ; n vrat registr–
TBLInpN9:pop       si

; ------ n vrat registr–

         mov       sp,bp                    ; n vrat ukazatele z sobn¡ku
         pop       bp
         pop       di
         pop       ax
         ret

TBLInpN  ENDP

; -----------------------------------------------------------------------------
;        p©¡prava po‡tu desetinn˜ch m¡st podle bu¤ky ES:SI
; -----------------------------------------------------------------------------

TBLSMist PROC      NEAR

         push      bx
         mov       bx,es:[si+TblXBunk]      ; ‡¡slo bu¤ky
         and       bx,TBLMaskC              ; maska ‡¡sla sloupce
         mov       bl,es:[bx+TblDesTb]      ; po‡et desetinn˜ch m¡st
         mov       byte ptr ds:[TBLMist],bl ; nastaven¡ desetinn˜ch m¡st
         pop       bx
         ret

TBLSMist ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ maxim ln¡ho po‡tu m¡st (n sleduje po nastaven¡ m¡st !)
; -----------------------------------------------------------------------------
; Nen¡ vhodn‚ pou‘¡t - p©i zv˜¨en¡ bajt– na desetinn  m¡sta se objev¡ na
; desetinn˜ch m¡stech chyba, kter  se zobraz¡ p©i editaci ‡¡sla !

;TBLSMstM PROC      NEAR
;
;         push      ax
;         mov       ax,ds:[TBLNumD]          ; po‡et bajt– na desetinnou ‡ st
;         shl       ax,1                     ; asi tak po‡et desetinn˜ch m¡st
;         cmp       ax,ds:[TBLMist]          ; je v¡ce desetinn˜ch m¡st ?
;         jbe       TBLSMst2                 ; nen¡ v¡ce desetinn˜ch m¡st
;         mov       ds:[TBLMist],ax          ; maximalizace desetinn˜ch m¡st
;TBLSMst2:pop       ax
;         ret
;
;TBLSMstM ENDP
;
; -----------------------------------------------------------------------------
;        dek¢dov n¡ ‡¡sla na textov˜ tvar
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=‡¡slo k dek¢dov n¡ (nebude modifikov no)
;         ES:[SI-1] (1) bit4: 1=ASCII zobrazen¡ ‡¡sla
;        DX:DI=buffer k ulo‘en¡ ‡¡sla
;        CX=velikost bufferu k ulo‘en¡ ‡¡sla
;        DS=datov˜ segment
; VSTUP: CX=d‚lka textu ‡¡sla
;         BX=d‚lka cel‚ ‡ sti ‡¡sla
; -----------------------------------------------------------------------------

TBLDekN  PROC      NEAR

; ------ test, zda bude ASCII zobrazen¡ ‡¡sla

         test      byte ptr es:[si-1],bit4  ; bude ASCII zobrazen¡ ‡¡sla ?
         jz        TBLDekNX                 ; nebude ASCII zobrazen¡ ‡¡sla

; ------ £schova registr– pro ASCII dek¢dov n¡

         push      ax
         push      si
         push      di
         push      ds
         mov       bx,cx                    ; BX <- velikost bufferu k ulo‘en¡

; ------ stanoven¡ d‚lky ‡¡sla -> CX

         mov       cx,ds:[TBLNumN]          ; d‚lka cel‚ ‡ sti ‡¡sla
         add       si,ds:[TBLNumX]          ; konec ‡¡sla
         dec       cx                       ; p©ednastaven¡ - 1
         dec       si                       ; konec ‡¡sla
TBLDekN1:cmp       byte ptr es:[si],0       ; je platn˜ znak ?
         jne       TBLDekN2                 ; nalezen platn˜ znak
         dec       si                       ; sn¡‘en¡ ukazatele textu
         loop      TBLDekN1                 ; dal¨¡ znak
TBLDekN2:inc       cx                       ; oprava d‚lky

; ------ omezen¡ d‚lky ‡¡sla

         cmp       cx,bx                    ; je d‚lka OK ?
         jbe       TBLDekN3                 ; d‚lka ‡¡sla je OK
         mov       cx,bx                    ; CX <- omezen¡ d‚lky ‡¡sla

; ------ p©enesen¡ textu

TBLDekN3:mov       ds,dx                    ; DS <- segment bufferu k ulo‘en¡
         mov       bx,cx                    ; BX <- d‚lka ‡¡sla
TBLDekN4:mov       al,es:[si]               ; bajt ‡¡sla
         mov       ds:[di],al               ; ulo‘en¡ bajtu
         dec       si
         inc       di
         loop      TBLDekN4                 ; dal¨¡ bajt
         mov       cx,bx                    ; CX <- d‚lka ‡¡sla

; ------ n vrat registr– po ASCII dek¢dov n¡

         pop       ds
         pop       di
         pop       si
         pop       ax
         ret

; ------ £schova registr–

TBLDekNX:call      TBLSetRg                 ; nastaven¡ registr– pro v˜po‡et

         push      si
         push      di
         push      es
         sub       sp,ds:[TBLNumX]          ; buffer pro ulo‘en¡ ‡¡sla

; ------ £schova ‡¡sla do bufferu v z sobn¡ku

         push      cx                       ; d‚lka bufferu k ulo‘en¡ ‡¡sla
         push      di                       ; buffer k ulo‘en¡ ‡¡sla
         push      ds

         mov       cx,ds:[TBLNumXW]         ; d‚lka ‡¡sla/2
         mov       di,sp                    ; DI <- buffer v z sobn¡ku
         add       di,3*2                   ; p©esko‡en¡ registr– v z sobn¡ku
         push      es
         pop       ds                       ; DS <- segment ‡¡sla k dek¢dov n¡
         push      ss
         pop       es                       ; ES <- segment bufferu v z sobn¡ku
         cld
         rep       movsw                    ; £schova ‡¡sla do z sobn¡ku

         pop       ds
         pop       si                       ; SI <- buffer k ulo‘en¡ ‡¡sla
         pop       cx                       ; CX <- d‚lka bufferu k ulo‘en¡ ‡¡sla

; ------ dek¢dov n¡ ‡¡sla (ES:DI=konec za ‡¡slem, DX:SI=buffer k dek¢dov n¡)

         call      far ptr KalkDekF         ; dek¢dov n¡ ‡¡sla do textu
         call      TBLResRg                 ; n vrat registr–
         mov       cx,si                    ; CX <- konec za ‡¡slem

; ------ n vrat registr–

         add       sp,ds:[TBLNumX]          ; n vrat ukazatele z sobn¡ku
         pop       es
         pop       di
         pop       si
         sub       cx,di                    ; d‚lka textu ‡¡sla

; ------ stanoven¡ d‚lky cel‚ ‡ sti ‡¡sla -> BX

         push      ax
         push      cx
         push      ds

         mov       al,ds:[OddelDes]         ; oddˆlova‡ desetin
         mov       ds,dx                    ; DS <- segment bufferu ‡¡sla
         xor       bx,bx                    ; ‡¡ta‡ d‚lky cel‚ ‡ sti ‡¡sla
         jcxz      TBLDekN8                 ; nen¡ nic

TBLDekN7:cmp       byte ptr ds:[di+bx],al   ; je desetinn  te‡ka ?
         je        TBLDekN8                 ; nalezena desetinn  te‡ka
         inc       bx                       ; zv˜¨en¡ ‡¡ta‡e d‚lky ‡¡sla
         loop      TBLDekN7                 ; nalezen¡ desetinn‚ te‡ky

TBLDekN8:pop       ds
         pop       cx
         pop       ax
         ret

TBLDekN  ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ registr– pro v˜po‡et (okno ES)
; -----------------------------------------------------------------------------

TBLSetRg PROC      NEAR

         push      word ptr ds:[KalkMist]   ; po‡et m¡st kalkul toru
         pop       word ptr ds:[TBLMist0]   ; £schova po‡tu m¡st

         push      word ptr ds:[KalParm]    ; parametry kalkul toru
         pop       word ptr ds:[TBLKalkP]   ; £schova parametr–

         push      word ptr ds:[TBLNumN]
         pop       word ptr ds:[KalNumN]    ; po‡et bajt– celo‡¡seln‚ ‡ sti

         push      word ptr ds:[TBLNumNW]
         pop       word ptr ds:[KalNumNW]   ; po‡et slov celo‡¡seln‚ ‡ sti

         push      word ptr ds:[TBLNumD]
         pop       word ptr ds:[KalNumD]    ; po‡et bajt– desetinn‚ ‡ sti

         push      word ptr ds:[TBLNumDW]
         pop       word ptr ds:[KalNumDW]   ; po‡et slov desetinn‚ ‡ sti

         push      word ptr ds:[TBLNumX]
         pop       word ptr ds:[KalNumX]    ; po‡et bajt– ‡¡sla celkem

         push      word ptr ds:[TBLNumXW]
         pop       word ptr ds:[KalNumXW]   ; po‡et slov ‡¡sla celkem

         mov       word ptr ds:[KalkZakl],10 ; dekadick  ‡¡seln  soustava

         mov       byte ptr ds:[KalkOdsz],255 ; nen¡ odsazen¡ © d–
         test      byte ptr es:[TblIParm],bit2 ; je odsazen¡ tis¡c– ?
         jz        TBLSetR1                 ; nen¡ odsazen¡ tis¡c–
         mov       byte ptr ds:[KalkOdsz],3 ; odsazen¡ tis¡c–

TBLSetR1:push      word ptr ds:[TBLMist]    ; po‡et desetinn˜ch m¡st ‡¡sla
         pop       word ptr ds:[KalkMist]   ; po‡et desetinn˜ch m¡st ‡¡sla

         mov       byte ptr ds:[KalParm],bit6 ; parametry kalkul toru
         test      byte ptr es:[TblIParm],bit6 ; v˜po‡ty v RAD ?
         jz        TBLSetR2                 ; nejsou RAD
         or        byte ptr ds:[KalParm],bit1 ; p©¡znak v˜po‡t– v RAD

TBLSetR2:ret

TBLSetRg ENDP

; -----------------------------------------------------------------------------
;        n vrat registr– po v˜po‡tu (uchov v  registr p©¡znak– !)
; -----------------------------------------------------------------------------

TBLResRg PROC      NEAR

         push      word ptr ds:[TBLMist0]   ; uschovan˜ po‡et m¡st
         pop       word ptr ds:[KalkMist]   ; n vrat po‡tu m¡st kalkul toru
         push      word ptr ds:[TBLKalkP]   ; uschovan‚ parametry kalkul toru
         pop       word ptr ds:[KalParm]    ; n vrat parametr– kalkul toru
         ret

TBLResRg ENDP

CodeTab  ENDS

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;
;                                 Data
;
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

Data     SEGMENT

; -----------------------------------------------------------------------------
;        menu v˜bˆru tabulky
; -----------------------------------------------------------------------------
;þ
TBMnuSel label     byte

         db        9                        ; typ menu - v˜bˆr soubor–

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        1                        ; po‡et polo‘ek
         dw        1                        ; po‡et polo‘ek celkem

         dw        0                        ; za‡ tek definice polo‘ek menu
         dw        SSMnSHlp                 ; adresa tabulky text– n povˆdy
         dw        Hlp@VyberTabulkyTabulkovehoKalkulatoru ; ‡¡slo str nky velk‚ n povˆdy
         dw        0                        ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        TBMnSTit                 ; adresa titulu okna
         dw        LinMenTM                 ; tabulka adres obsluh
         dw        LinMenTM                 ; tabulka podmenu
         dd        0                        ; n vratov  adresa

         db        12                       ; po‡ te‡n¡ pozice okna
         db        3                        ; po‡ te‡n¡ © dek okna
         db        63                       ; ¨¡©ka okna
         db        18                       ; v˜¨ka okna

TablSeg  dw        0                        ; segment se seznamem soubor–
TablPth0 dw        0                        ; minim. d‚lka textu cesty
TablPthN dw        0                        ; d‚lka textu cesty seznamu
         dw        TablPath                 ; buffer s adres ©em seznamu
TablPthI db        3                        ; inicializa‡n¡ jm‚no podadres ©e
TablExt  db        'TAB'                    ; p©¡pona pro v˜bˆr soubor–
TablTxt1 dw        TablTx11                 ; adresa textu "tabulka"
         dw        0                        ; uschovan  prvn¡ polo‘ka
         dw        0                        ; uschovan˜ kurzor

TBMnSTit db        13,'volba tabulky'

TablTx11 db        6,'tabulk'

; -----------------------------------------------------------------------------
;        okno tabulky
; -----------------------------------------------------------------------------
;þ
TBLMnu   label     byte

         db        7                        ; typ menu - editor tabulky

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        1                        ; po‡et polo‘ek menu
         dw        1                        ; celkov˜ po‡et polo‘ek menu

         dw        0                        ; za‡ tek definice polo‘ek menu
         dw        TBLMnHl1                 ; adresa tabulky text– n povˆdy
         dw        Hlp@TabulkovyKalkulator  ; ‡¡slo str nky velk‚ n povˆdy
         dw        0                        ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        TBLMnTit                 ; adresa titulu okna
         dw        LinMenTM                 ; adresy obsluh
         dw        LinMenTM                 ; adresa podmenu
         dd        0                        ; n vratov  adresa

         db        0                        ; po‡ te‡n¡ pozice okna
         db        1                        ; po‡ te‡n¡ © dek okna
         db        255                      ; ¨¡©ka okna
         db        21                       ; v˜¨ka okna

TBLMnuSg dw        0                        ; segment se souborem

TBLMnTit db        7,'tabulka'

HelpS    SEGMENT   BYTE PUBLIC              ; n povˆda k menu
TBLMnHl0 db        87,'Tab/Shift-Tab=dal¨¡/p©ede¨l  polo‘ka F2=ulo‘ F4=oprava F9=p©epo‡et F10=menu'
TBLMnHl1 db        87,'F2=ulo‘ F3=blok F4=oprava F7=m¢d F9=p©epo‡et Ins=vlo‘ Del=zru¨ F10=menu'
TBLMnHl2 db        77,'Prvn¡ znak: ''=text, (=v˜raz, [=extern¡ bu¤ka, *=ASCII zobrazen¡ ‡¡sla'
TBLMnHl3 db        28,'Textov  bu¤ka - zadejte text'
TBLMnHl4 db        77,'V˜raz: Funkce(‡¡slo), Funkce(bu¤ka1..bu¤ka2), bu¤ka@=absolutn¡ adresace'
TBLMnHl5 db        78,'Zad n¡ extern¡ bu¤ky: [soubor] bu¤ka; p©¡pona implic. TAB, adres © relativn¡'
;TBLMnHl8 db        80,'Nastaven¡ ¨¡©ky sloupce kl vesami vlevo a vpravo, Esc nebo Enter = konec'

;TBLMnHl8 db        56,'vlevo/vpravo=¨¡©ka (',1
;         dw        TBLMnHPS
;         db        '), Esc nebo Enter=konec'

TBLMnHl9 db        77,'Nastavte konec bloku a stisknˆte Enter (nebo F3); Esc=p©eru¨en¡ operace'
TBLMnHlA db        74,'Nastavte c¡lovou pozici po‡ tku bloku a stisknˆte Enter; Esc=p©eru¨en¡'
HelpS    ENDS

TBLMnHPS db        3,'000'

TBLMnHM0 label     byte
         db        5
         dw        0f09h                    ; Tab
         db        10
         dw        0f00h                    ; Shift-Tab
         db        6
         dw        0f09h                    ; dal¨¡ = Tab
         db        16
         dw        0f00h                    ; p©ede¨l  = Shift-Tab
         db        8
         dw        3c00h                    ; F2
         db        10
         dw        3e00h                    ; F4
         db        12
         dw        4300h                    ; F9
         db        -1
         dw        4400h                    ; F10

TBLMnHM1 label     byte
         db        8
         dw        3c00h                    ; F2
         db        8
         dw        3d00h                    ; F3
         db        10
         dw        3e00h                    ; F4
         db        7
         dw        4100h                    ; F7
         db        12
         dw        4300h                    ; F9
         db        9
         dw        5200h                    ; Ins
         db        9
         dw        5300h                    ; Del
         db        -1
         dw        4400h                    ; F10

; -----------------------------------------------------------------------------
;        hlavn¡ menu funkc¡ tabulky
; -----------------------------------------------------------------------------
;þ
TBMnVert label     byte                   ;* menu volby operace v datab zi

         db        2                        ; typ menu - vertik ln¡ podmenu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        19                       ; po‡et platn˜ch polo‘ek menu
         dw        19                       ; celkov˜ po‡et polo‘ek menu

         dw        TBMnVPol                 ; adresa definice polo‘ek
         dw        TBMnVHlp                 ; adresa n povˆd
         dw        Hlp@MenuTabulkovehoKalkulatoru ; ‡¡slo str nky velk‚ n povˆdy
         dw        TBMnVBlk                 ; adresa blokovac¡ tabulky
         dw        TBMnVSwc                 ; adresa tabulky p©ep¡na‡–
         dw        TBMnVTit                 ; adresa titulu okna
         dw        TBMnVExe                 ; adresa obsluh
         dw        LinMenTM                 ; adresa podmenu
         dd        0                        ; n vratov  adresa

         db        30                       ; po‡ te‡n¡ pozice
         db        5                        ; po‡ te‡n¡ © dek
         db        20                       ; ¨¡©ka
         db        21                       ; v˜¨ka

TBMnVPol db        1+bit7,11,'Automaticky'
         db        1,4,'Blok'
         db        1,16,'Cel  ‡ st     '
TBMnVPl1 db        '  '
         db        1,16,'Desetiny      '
TBMnVPl2 db        '  '
         db        1,7,'Editace'
         db        1+bit7,8,'Formul ©'
         db        1,16,'Heslo        '
TBMnVPlH db        '   '
         db        1,6,'Import'
         db        1+bit7,6,'Ladˆn¡'
         db        1,16,'M¡st          '
TBMnVPl3 db        '  '
         db        1+bit7,7,'Ochrana'
         db        1,8,'P©epo‡et'
         db        1+bit7,7,'Radi ny'
         db        1,16,'Sloupec       '
TBMnVPl4 db        '  '
         db        1+bit7,6,'Tis¡ce'
         db        1,7,'Ulo‘en¡'
         db        1,6,'Vlo‘it'
         db        2,6,'eXport'
         db        1,6,'Zru¨it'

TBMnVBlk db        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
TBMnVSwc db        0,0,0,0,0,0
TBMnVTit db        4,'menu'

HelpS    SEGMENT   BYTE PUBLIC
TBMnVHlp db        77,'Automatick˜ p©epo‡et tabulky po modifikaci bu¤ky (p©epo‡et cel‚ tabulky F9)'
         db        72,'Operace s blokem tabulky (kop¡rov n¡, p©esun, export, ru¨en¡ ...) (F3)'

         db        27,'Vnit©n¡ velikost cel‚',1
         dw        TBMnVHlC
         db        1
         dw        TBMnVHlS

         db        32,'Vnit©n¡ velikost desetinn‚',1
         dw        TBMnVHlC
         db        1
         dw        TBMnVHlS

         db        58,'Editace (oprava) obsahu bu¤ky pod kurzorem (F4, Enter)'
         db        61,'Tabulka v m¢du formul ©e - ochrana proti modifikaci struktury'
         db        42,'Zad n¡ hesla k uzam‡en¡ p©¡stupu k tabulce'
         db        40,'Import bloku tabulky z textov‚ho souboru'
         db        49,'Nastaven¡ ladic¡ho m¢du - zobrazen¡ v˜raz– (F7)'
         db        69,'Volba po‡tu zobrazen˜ch desetinn˜ch m¡st ‡¡sel pro sloupec s kurzorem'
         db        66,'Ochrana bu¤ky pod kurzorem proti modifikaci - uzam‡en¡ (Ctrl-F8)'
         db        35,'P©epo‡et obsahu cel‚ tabulky (F9)'
         db        72,'V˜po‡ty goniometrick˜ch funkc¡ prob¡haj¡ v radi nech (jinak ve stupn¡ch)'
         db        44,'Nastaven¡ zobrazen‚ ¨¡©ky sloupce s kurzorem'
         db        32,'Zobrazen¡ ‡¡sel s odsazen¡m © d–'
         db        30,'Ulo‘en¡ tabulky na disk (F2)'
         db        62,'Vlo‘en¡ nov‚ho © dku nebo sloupce na pozici kurzoru (Insert)'
         db        50,'Export tabulky do textov‚ho souboru (t‚‘ pro tisk)'
         db        55,'Zru¨en¡ bu¤ky, sloupce nebo © dku s kurzorem (Delete)'

TBMnVHl1 db        24,1
         dw        TBMnVHlZ
         db        'celou ‡ st ‡¡sla (',1
         dw        TBMnVHlS

TBMnVHl2 db        29,1
         dw        TBMnVHlZ
         db        'desetinnou ‡ st ‡¡sla (',1
         dw        TBMnVHlS

TBMnVHl3 db        73,'Zvolte 0 a‘ 97 zobrazen˜ch desetinn˜ch m¡st ‡¡sel pro aktivn¡ sloupec'
TBMnVHl4 db        49,'Zvolte 1 a‘ 99 znak– ¨¡©ky sloupce s kurzorem'
HelpS    ENDS

TBMnVHlZ db        27,'Zvolte 2 a‘ 50 slov na '
TBMnVHlC db        26,' ‡ sti ‡¡sla (po‡et slov: '
TBMnVHlS db        26,'1 slovo=2 bajty=4 ‡¡slice)'

TBMnVExe dd        EdTBMAut                 ; 1: Automaticky
         dd        EdTBMMnF                 ; 2: Blok
         dd        EdTBMMn1                 ; 3: Cel  ‡ st
         dd        EdTBMMn2                 ; 4: Desetiny
         dd        EdTBMMnF                 ; 5: Editace
         dd        EdTBMFrm                 ; 6: Formul ©
         dd        EdTBMMnF                 ; 7: Heslo
         dd        EdTBMMnF                 ; 8: Import
         dd        EdTBMLad                 ; 9: Ladˆn¡
         dd        EdTBMMn3                 ; 10: M¡st
         dd        EdTBMOch                 ; 11: Ochrana
         dd        EdTBMMnF                 ; 12: P©epo‡et
         dd        EdTBMRad                 ; 13: Radi ny
         dd        EdTBMMn5                 ; 14: Sloupec
         dd        EdTBMTis                 ; 15: Tis¡ce
         dd        EdTBMMnF                 ; 16: Ulo‘en¡
         dd        EdTBMMnF                 ; 17: Vlo‘it
         dd        EdTBMMnF                 ; 18: eXport
         dd        EdTBMMnF                 ; 19: Zru¨it

;TBMnVMnu dw        0                        ; Automaticky
;         dw        0                        ; Blok
;         dw        0                        ; Cel  ‡ st
;         dw        0                        ; Desetiny
;         dw        0                        ; Editace
;         dw        0                        ; Formul ©
;         dw        0                        ; Heslo
;         dw        0                        ; Import
;         dw        0                        ; Ladˆn¡
;         dw        0                        ; M¡st
;         dw        0                        ; Ochrana
;         dw        0                        ; P©epo‡et
;         dw        0                        ; Radi ny
;         dw        0                        ; Sloupec
;         dw        0                        ; Tis¡ce
;         dw        0                        ; Ulo‘en¡
;         dw        0                        ; Vlo‘it
;         dw        0                        ; eXport
;         dw        0                        ; Zru¨it

; ------ potvrzen¡ konverze form tu ‡¡sel

TBTstMLn label     byte
         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        2                        ; po‡et platn˜ch polo‘ek menu
         dw        9                        ; celkov˜ po‡et polo‘ek menu

         dw        TBTstMLP                 ; adresa definice polo‘ek
         dw        TBTstMLH                 ; adresa n povˆd
         dw        Hlp@MenuTabulkovehoKalkulatoru ; ‡¡slo str nky velk‚ n povˆdy
         dw        TBTstMLB                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        TBTstMLT                 ; adresa titulu okna
         dw        LinMenTE                 ; adresa obsluh voleb
         dw        LinMenTM                 ; adresy podmenu
         dd        0                        ; n vratov  adresa

         db        19                       ; po‡ te‡n¡ pozice
         db        7                        ; po‡ te‡n¡ © dek
         db        49                       ; ¨¡©ka
         db        12                       ; v˜¨ka

         dw        0                        ; maxim ln¡ d‚lka © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        0                        ; celkov˜ po‡et © dk–
         dw        0                        ; po‡et zobrazen˜ch © dk–

         db        0                        ; maska znak–
         db        0,'      '               ; zak zan‚ znaky

         db        0                        ; identifik tor historie
         db        0                        ; po‡et p©edvoleb

TBTstMLP db        bit6,0
         db        bit6,9,0,'VAROVN‹'
         db        bit6,36,'Zkonvertuji velikost registr– ‡¡sel.'
         db        bit6,36,'Zmen¨en¡m registr– ‡¡sel m–‘e nastat'
         db        bit6,36,'p©ete‡en¡ nˆkter˜ch operac¡ a ‡¡sel!'
         db        bit6,0
         db        bit6+bit7,0
         db        1,8,'Konverze'
         db        1,6,'N vrat'

TBTstMLB db        0,0
TBTstMLT db        14,'konverze ‡¡sel'

HelpS    SEGMENT   BYTE PUBLIC
TBTstMLH db        47,'Konverze registr– ‡¡sel na po‘adovanou velikost'
         db        3,1
         dw        MenuHlP2
HelpS    ENDS

; ------ volba © dku nebo sloupce k vlo‘en¡

TBInsMLn label     byte
         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        3                        ; po‡et platn˜ch polo‘ek menu
         dw        8                        ; celkov˜ po‡et polo‘ek menu

         dw        TBInsMLP                 ; adresa definice polo‘ek
         dw        TBInsMLH                 ; adresa n povˆd
         dw        Hlp@MenuTabulkovehoKalkulatoru ; ‡¡slo str nky velk‚ n povˆdy
         dw        TBInsMLB                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        TBInsMLT                 ; adresa titulu okna
         dw        LinMenTE                 ; adresa obsluh voleb
         dw        LinMenTM                 ; adresy podmenu
         dd        0                        ; n vratov  adresa

         db        19                       ; po‡ te‡n¡ pozice
         db        7                        ; po‡ te‡n¡ © dek
         db        49                       ; ¨¡©ka
         db        10                       ; v˜¨ka

         dw        0                        ; maxim ln¡ d‚lka © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        0                        ; celkov˜ po‡et © dk–
         dw        0                        ; po‡et zobrazen˜ch © dk–

         db        0                        ; maska znak–
         db        0,'      '               ; zak zan‚ znaky

         db        0                        ; identifik tor historie
         db        0                        ; po‡et p©edvoleb

TBInsMLP db        bit6,0
         db        bit6,29,'Chcete vlo‘it do tabulky nov˜'
         db        bit6,28,'© dek (linku) nebo sloupec ?'
         db        bit6,0
         db        bit6+bit7,0
         db        1,5,'Linku'
         db        1,7,'Sloupec'
         db        1,6,'N vrat'

TBInsMLB db        0,0,0
TBInsMLT db        7,'vlo‘en¡'

HelpS    SEGMENT   BYTE PUBLIC
TBInsMLH db        16,1
         dw        TBInsMH2
         db        '© dek (linka)'

         db        10,1
         dw        TBInsMH2
         db        'sloupec'

         db        3,1
         dw        MenuHlP2
HelpS    ENDS

TBInsMH2 db        46,'Do tabulky na pozici kurzoru bude vlo‘en nov˜ '

; ------ volba © dku nebo sloupce ke zru¨en¡

TBDelMLn label     byte
         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        4                        ; po‡et platn˜ch polo‘ek menu
         dw        9                        ; celkov˜ po‡et polo‘ek menu

         dw        TBDelMLP                 ; adresa definice polo‘ek
         dw        TBDelMLH                 ; adresa n povˆd
         dw        Hlp@MenuTabulkovehoKalkulatoru ; ‡¡slo str nky velk‚ n povˆdy
         dw        TBDelMLB                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        TBDelMLT                 ; adresa titulu okna
         dw        LinMenTE                 ; adresa obsluh voleb
         dw        LinMenTM                 ; adresy podmenu
         dd        0                        ; n vratov  adresa

         db        19                       ; po‡ te‡n¡ pozice
         db        7                        ; po‡ te‡n¡ © dek
         db        49                       ; ¨¡©ka
         db        10                       ; v˜¨ka

         dw        0                        ; maxim ln¡ d‚lka © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        0                        ; celkov˜ po‡et © dk–
         dw        0                        ; po‡et zobrazen˜ch © dk–

         db        0                        ; maska znak–
         db        0,'      '               ; zak zan‚ znaky

         db        0                        ; identifik tor historie
         db        0                        ; po‡et p©edvoleb

TBDelMLP db        bit6,0
         db        bit6,30,'Chcete zru¨it z tabulky bu¤ku,'
         db        bit6,28,'© dek (linku) nebo sloupec ?'
         db        bit6,0
         db        bit6+bit7,0
         db        1,5,'Bu¤ku'
         db        1,5,'Linku'
         db        1,7,'Sloupec'
         db        1,6,'N vrat'

TBDelMLB db        0,0,0,0
TBDelMLT db        6,'ru¨en¡'

HelpS    SEGMENT   BYTE PUBLIC
TBDelMLH db        31,'Zru¨en¡ bu¤ky na pozici kurzoru'
         db        32,'Zru¨en¡ © dku (linky) s kurzorem'
         db        26,'Zru¨en¡ sloupce s kurzorem'

         db        3,1
         dw        MenuHlP2
HelpS    ENDS

TBRusHls db        13,'Ru¨¡m data...'

; ------ chyba - jsou chr nˆn‚ bu¤ky

TBLErrRO label     byte

         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        1                        ; po‡et platn˜ch polo‘ek menu
         dw        7                        ; celkov˜ po‡et polo‘ek menu

         dw        TBLErROP                 ; za‡ tek definice polo‘ek menu
         dw        ChbLnMeH                 ; adresa tabulky text– n povˆdy
         dw        Hlp@BlokoveOperaceTabulky ; ‡¡slo str nky velk‚ n povˆdy
         dw        TBLErROB                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        TBLErROT                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        23                       ; po‡ te‡n¡ pozice okna
         db        7                        ; po‡ te‡n¡ © dek okna
         db        49                       ; ¨¡©ka okna
         db        11                       ; v˜¨ka okna

         dw        255                      ; maxim ln¡ d‚lka textu © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        0                        ; celkov˜ po‡et © dk–
         dw        0                        ; po‡et zobrazen˜ch © dk–

         db        bit3                     ; maska zad van˜ch znak–
         db        0,'      '               ; zak zan‚ znaky

         db        0                        ; historie
         db        0                        ; po‡et p©edvoleb


TBLErROP db        bit6,0
         db        bit6,6,0,'CHYBA'
         db        bit6,33,'V ru¨en‚m/p©episovan‚m bloku jsou'
         db        bit6,33,'bu¤ky chr nˆn‚ proti modifikaci !'
         db        bit6,0
         db        bit6+bit7,0
         db        1,6,'N vrat'

TBLErROB db        0                        ; blokovac¡ tabulka

TBLErROT db        14,'chr nˆn‚ bu¤ky'

; ------ volba operace s blokem
;þ
TBBlkMnu label     byte                   ;* menu volby operace v datab zi
         db        2                        ; typ menu - vertik ln¡ podmenu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        9                        ; po‡et platn˜ch polo‘ek menu
         dw        13                       ; celkov˜ po‡et polo‘ek menu

         dw        TBBlkMnP                 ; adresa definice polo‘ek
         dw        TBBlkMnH                 ; adresa n povˆd
         dw        Hlp@BlokoveOperaceTabulky ; ‡¡slo str nky velk‚ n povˆdy
         dw        TBBlkMnB                 ; adresa blokovac¡ tabulky
         dw        TBBlkMnS                 ; adresa tabulky p©ep¡na‡–
         dw        TBBlkMnT                 ; adresa titulu okna
         dw        TBBlkMnE                 ; adresa obsluh
         dw        LinMenTM                 ; adresa podmenu
         dd        0                        ; n vratov  adresa

         db        30                       ; po‡ te‡n¡ pozice
         db        5                        ; po‡ te‡n¡ © dek
         db        24                       ; ¨¡©ka
         db        15                       ; v˜¨ka

TBBlkMnP db        bit6,18,'Zvolte po‘adovanou'
         db        bit6,16,'operaci s blokem'
         db        bit6+bit7,0
         db        1,5,'Kopie'
         db        1,8,'Naplnˆn¡'
         db        1,9,'Odemknout'
         db        1,6,'P©esun'
         db        1,6,'Ru¨en¡'
         db        2,6,'eXport'
         db        1,8,'Zamknout'
         db        bit6+bit7,0
         db        1+bit7,5,'Linky'
         db        1+bit7,7,'Sloupce'

TBBlkMnB db        0,0,0,0,0,0,0,0,0
TBBlkMnS db        0,0
TBBlkMnT db        16,'operace s blokem'

HelpS    SEGMENT   BYTE PUBLIC
TBBlkMnH db        8,'Kopie',1
         dw        TBBlkMH1

         db        38,'Naplnˆn¡',1
         dw        TBBlkMH2
         db        'obsahem prvn¡ bu¤ky v bloku'

         db        12,'Odemknut¡',1
         dw        TBBlkMH4

         db        9,'P©esun',1
         dw        TBBlkMH1

         db        17,'Zru¨en¡ obsahu',1
         dw        TBBlkMH2

         db        29,'Export',1
         dw        TBBlkMH2
         db        'do textov‚ho souboru'

         db        12,'Uzamknut¡',1
         dw        TBBlkMH4

         db        16,'ž dky (linky)',1
         dw        TBBlkMH3

         db        10,'Sloupce',1
         dw        TBBlkMH3
HelpS    ENDS

TBBlkMH1 db        41,' ozna‡en‚ho bloku na jin‚ m¡sto v tabulce'
TBBlkMH2 db        18,' ozna‡en‚ho bloku '
TBBlkMH3 db        48,' bunˆk ve v˜razech budou relativnˆ p©epo‡¡t v ny'
TBBlkMH4 db        36,' p©¡stupu k bu¤k m v ozna‡en‚m bloku'

TBBlkMnE dd        EdTBBlk4                 ; Kopie
         dd        EdTBBlk4                 ; Naplnˆn¡
         dd        EdTBBlk4                 ; Odemknut¡
         dd        EdTBBlk4                 ; P©esun
         dd        EdTBBlk4                 ; Ru¨en¡
         dd        EdTBBlk4                 ; eXport
         dd        EdTBBlk4                 ; Zamknout
         dd        EdTBBl37                 ; Linky
         dd        EdTBBl39                 ; Sloupce

; ------ zad n¡ souboru k exportu

TBLMSLin label     byte

         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        5                        ; po‡et platn˜ch polo‘ek menu
         dw        7                        ; celkov˜ po‡et polo‘ek menu

         dw        TBLMLPol                 ; za‡ tek definice polo‘ek menu
         dw        TBLMLHlp                 ; adresa tabulky text– n povˆdy
         dw        Hlp@ExportTabulkyDoTextovehoSouboru ; ‡¡slo str nky velk‚ n povˆdy
         dw        TBLMLBlk                 ; adresa blokovac¡ tabulky
         dw        TBLMLSwc                 ; adresa tabulky p©ep¡na‡–
         dw        TBLMLTit                 ; adresa titulu okna
         dw        TBLMLExe                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        20                       ; po‡ te‡n¡ pozice okna
         db        0                        ; po‡ te‡n¡ © dek okna
         db        56                       ; ¨¡©ka okna
         db        8                        ; v˜¨ka okna

         dw        100                      ; maxim ln¡ d‚lka textu © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        1                        ; celkov˜ po‡et © dk–
         dw        1                        ; po‡et zobrazen˜ch © dk–

         db        bit3                     ; maska zad van˜ch znak– - soubor
         db        2,'?*    '               ; zak zan‚ znaky

         db        HistFile                 ; historie soubor–
         db        0                        ; po‡et p©edvoleb

; ------ polo‘ky voleb

TBLMLPol db        bit6,28,'Jm‚no souboru k exportu dat:'
         db        0,0
         db        bit6+bit7,0
         db        1,6,'Export'
         db        1+bit7,8,'V˜razy '
TBLMLPl1 db        '-'
         db        1+bit7,6,'Tisk '
TBLMLPl3 db        '-'
         db        1,6,'N vrat'

TBLMLBlk db        0,0,0,0,0                ; blokovac¡ tabulka
TBLMLSwc db        0,0

TBLMLTit db        6,'export'

TBLMLExe dd        Lin0MenR                 ; © dky
         dd        Lin0MenR                 ; Export
         dd        EdTBExS1                 ; V˜razy
         dd        EdTBExS3                 ; Tisk
         dd        Lin0MenR                 ; N vrat

HelpS    SEGMENT   BYTE PUBLIC
TBLMLHlp db        56,'Zadejte jm‚no souboru, do kter‚ho budou data exportov na'
         db        42,'Proveden¡ exportu dat do textov‚ho souboru'
         db        69,'V˜razy ukl d ny v textov‚m tvaru (jinak ukl d na ‡¡sla jako v˜sledky)'
         db        64,'Polo‘ky ukl d ny do sloupc– jako p©i zobrazen¡ (ur‡eno pro tisk)'
         db        3,1
         dw        MenuHlP2
HelpS    ENDS

;TBLMLHl2 db        26,'Polo‘ky oddˆleny ‡ rkami, '

; ------ zad n¡ souboru k importu

TBLImpMn label     byte

         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        4                        ; po‡et platn˜ch polo‘ek menu
         dw        6                        ; celkov˜ po‡et polo‘ek menu

         dw        TBLImpMP                 ; za‡ tek definice polo‘ek menu
         dw        TBLImpMH                 ; adresa tabulky text– n povˆdy
         dw        Hlp@ImportBlokuTabulkyZTextovehoSouboru ; ‡¡slo str nky velk‚ n povˆdy
         dw        TBLImpMB                 ; adresa blokovac¡ tabulky
         dw        TBLImpMS                 ; adresa tabulky p©ep¡na‡–
         dw        TBLImpMT                 ; adresa titulu okna
         dw        TBLImpEx                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        20                       ; po‡ te‡n¡ pozice okna
         db        0                        ; po‡ te‡n¡ © dek okna
         db        56                       ; ¨¡©ka okna
         db        8                        ; v˜¨ka okna

         dw        100                      ; maxim ln¡ d‚lka textu © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        1                        ; celkov˜ po‡et © dk–
         dw        1                        ; po‡et zobrazen˜ch © dk–

         db        bit3                     ; maska zad van˜ch znak– - soubor
         db        2,'?*    '               ; zak zan‚ znaky

         db        HistFile                 ; historie soubor–
         db        0                        ; po‡et p©edvoleb

TBLImpMP db        bit6,28,'Jm‚no souboru k importu dat:'
         db        0,0
         db        bit6+bit7,0
         db        1,6,'Import'
         db        1+bit7,8,'V˜razy '
TBLImpP1 db        '-'
         db        1,6,'N vrat'

TBLImpMB db        0,0,0,0                  ; blokovac¡ tabulka
TBLImpMS db        0                        ; p©ep¡na‡e

TBLImpMT db        6,'import'

HelpS    SEGMENT   BYTE PUBLIC
TBLImpMH db        55,'Zadejte jm‚no souboru, z kter‚ho budou data importov na'
         db        41,'Proveden¡ importu dat z textov‚ho souboru'
         db        53,'Budou na‡¡t ny v˜razy (jinak uvozovky v‘dy jako text)'
         db        3,1
         dw        MenuHlP2
HelpS    ENDS

TBLImpEx dd        Lin0MenR                 ; © dky
         dd        Lin0MenR                 ; Import
         dd        EdTBExS1                 ; V˜razy
         dd        Lin0MenR                 ; N vrat

; ------ potvrzen¡ naplnˆn¡ bloku

TBNapMLn label     byte
         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        2                        ; po‡et platn˜ch polo‘ek menu
         dw        9                        ; celkov˜ po‡et polo‘ek menu

         dw        TBNapMLP                 ; adresa definice polo‘ek
         dw        TBNapMLH                 ; adresa n povˆd
         dw        Hlp@BlokoveOperaceTabulky ; ‡¡slo str nky velk‚ n povˆdy
         dw        TBNapMLB                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        TBNapMLT                 ; adresa titulu okna
         dw        LinMenTE                 ; adresa obsluh voleb
         dw        LinMenTM                 ; adresy podmenu
         dd        0                        ; n vratov  adresa

         db        19                       ; po‡ te‡n¡ pozice
         db        7                        ; po‡ te‡n¡ © dek
         db        49                       ; ¨¡©ka
         db        12                       ; v˜¨ka

         dw        0                        ; maxim ln¡ d‚lka © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        0                        ; celkov˜ po‡et © dk–
         dw        0                        ; po‡et zobrazen˜ch © dk–

         db        0                        ; maska znak–
         db        0,'      '               ; zak zan‚ znaky

         db        0                        ; identifik tor historie
         db        0                        ; po‡et p©edvoleb

TBNapMLP db        bit6,0
         db        bit6,9,0,'VAROVN‹'
         db        bit6,34,'Ozna‡en˜ blok bude naplnˆn obsahem'
         db        bit6,38,'podle bu¤ky v lev‚m horn¡m rohu bloku.'
         db        bit6,37,'Ostatn¡ bu¤ky v bloku budou zru¨eny !'
         db        bit6,0
         db        bit6+bit7,0
         db        1,8,'Naplnˆn¡'
         db        1,6,'Konec'

TBNapMLB db        0,0
TBNapMLT db        14,'naplnˆn¡ bloku'

HelpS    SEGMENT   BYTE PUBLIC
TBNapMLH db        69,'Naplnˆn¡ ozna‡en‚ho bloku obsahem po‡ te‡n¡ bu¤ky v lev‚m horn¡m rohu'
         db        3,1
         dw        MenuHlP2
HelpS    ENDS

PlnHlas  db        13,'Pln¡m blok...'

; ------ chyba - bloky se p©ekr˜vaj¡

TBLErOvr label     byte

         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        1                        ; po‡et platn˜ch polo‘ek menu
         dw        7                        ; celkov˜ po‡et polo‘ek menu

         dw        TBLErOvP                 ; za‡ tek definice polo‘ek menu
         dw        ChbLnMeH                 ; adresa tabulky text– n povˆdy
         dw        Hlp@BlokoveOperaceTabulky ; ‡¡slo str nky velk‚ n povˆdy
         dw        TBLErOvB                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        TBLErOvT                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        23                       ; po‡ te‡n¡ pozice okna
         db        7                        ; po‡ te‡n¡ © dek okna
         db        40                       ; ¨¡©ka okna
         db        11                       ; v˜¨ka okna

         dw        255                      ; maxim ln¡ d‚lka textu © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        0                        ; celkov˜ po‡et © dk–
         dw        0                        ; po‡et zobrazen˜ch © dk–

         db        bit3                     ; maska zad van˜ch znak–
         db        0,'      '               ; zak zan‚ znaky

         db        0                        ; historie
         db        0                        ; po‡et p©edvoleb


TBLErOvP db        bit6,0
         db        bit6,6,0,'CHYBA'
         db        bit6,25,'C¡lov  pozice bloku nesm¡'
         db        bit6,24,'p©ekr˜vat p–vodn¡ blok !'
         db        bit6,0
         db        bit6+bit7,0
         db        1,6,'N vrat'

TBLErOvB db        0                        ; blokovac¡ tabulka

TBLErOvT db        19,'bloky se p©ekr˜vaj¡'

; ------ menu - ulo‘en¡ souboru

TBSMnLin label     byte
         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        3                        ; po‡et platn˜ch polo‘ek menu
         dw        8                        ; celkov˜ po‡et polo‘ek menu

         dw        TBSMnPol                 ; za‡ tek definice polo‘ek menu
         dw        TBSMnHlp                 ; adresa tabulky text– n povˆdy
         dw        Hlp@MenuTabulkovehoKalkulatoru ; ‡¡slo str nky velk‚ n povˆdy
         dw        TBSMnBlk                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        TBSMnTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        20                       ; po‡ te‡n¡ pozice okna
         db        0                        ; po‡ te‡n¡ © dek okna
         db        44                       ; ¨¡©ka okna
         db        10                       ; v˜¨ka okna

         dw        255                      ; maxim ln¡ d‚lka textu © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        0                        ; celkov˜ po‡et © dk–
         dw        0                        ; po‡et zobrazen˜ch © dk–

         db        bit3                     ; maska zad van˜ch znak– - soubor
         db        0,'      '               ; zak zan‚ znaky

         db        0                        ; historie specifikac¡ soubor–
         db        0                        ; po‡et p©edvoleb

TBSMnPol db        bit6,0
         db        bit6,26,'Tabulka byla modifikov na.'
         db        bit6,31,'Chcete ulo‘it proveden‚ zmˆny ?'
         db        bit6,0
         db        bit6+bit7,0
         db        1,6,'Ulo‘it'
         db        1,8,'Neulo‘it'
         db        1,8,'P©eru¨it'

TBSMnBlk db        0,0,0                    ; blokovac¡ tabulka

HelpS    SEGMENT   BYTE PUBLIC
TBSMnHlp db        15,'Ulo‘en¡ tabulky'
         db        50,'Tabulka se neulo‘¡, p–vodn¡ obsah z–stane nezmˆnˆn'
         db        42,'P©eru¨en¡ operace a n vrat zpˆt do tabulky'
HelpS    ENDS

TBSMnTit db        20,'tabulka modifikov na'

; ------ chyba z pisu

TBLErWrt label     byte

         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        1                        ; po‡et platn˜ch polo‘ek menu
         dw        7                        ; celkov˜ po‡et polo‘ek menu

         dw        TBLErWrP                 ; za‡ tek definice polo‘ek menu
         dw        ChbLnMeH                 ; adresa tabulky text– n povˆdy
         dw        Hlp@MenuTabulkovehoKalkulatoru ; ‡¡slo str nky velk‚ n povˆdy
         dw        TBLErWrB                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        TBLErWrX                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        23                       ; po‡ te‡n¡ pozice okna
         db        7                        ; po‡ te‡n¡ © dek okna
         db        44                       ; ¨¡©ka okna
         db        11                       ; v˜¨ka okna

         dw        255                      ; maxim ln¡ d‚lka textu © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        0                        ; celkov˜ po‡et © dk–
         dw        0                        ; po‡et zobrazen˜ch © dk–

         db        bit3                     ; maska zad van˜ch znak–
         db        0,'      '               ; zak zan‚ znaky

         db        0                        ; historie
         db        0                        ; po‡et p©edvoleb

TBLErWrP db        bit6,0
         db        bit6,6,0,'CHYBA'
         db        bit6,25,'Chyba z pisu do souboru !'
         db        bit6,31,'Soubor m  ochranu proti z pisu.'
         db        bit6,0
         db        bit6+bit7,0
         db        1,6,'N vrat'

TBLErWRB db        0                        ; blokovac¡ tabulka

TBLErWrX db        12,'chyba z pisu'

; ------ zad n¡ hesla

TBLHesMn label     byte
         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        3                        ; po‡et platn˜ch polo‘ek menu
         dw        5                        ; celkov˜ po‡et polo‘ek menu

         dw        TBLHesMP                 ; za‡ tek definice polo‘ek menu
         dw        TBLHesMH                 ; adresa tabulky text– n povˆdy
         dw        Hlp@TabulkovyKalkulator  ; ‡¡slo str nky velk‚ n povˆdy
         dw        TBLHesMB                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        TBLHesMT                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        20                       ; po‡ te‡n¡ pozice okna
         db        0                        ; po‡ te‡n¡ © dek okna
         db        42                       ; ¨¡©ka okna
         db        8                        ; v˜¨ka okna

         dw        TBLMaxHs                 ; maxim ln¡ d‚lka textu © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        1                        ; celkov˜ po‡et © dk–
         dw        1                        ; po‡et zobrazen˜ch © dk–

         db        bit2                     ; maska zad van˜ch znak– - v¨echny
         db        0,'      '               ; zak zan‚ znaky

         db        0                        ; historie nen¡
         db        1                        ; po‡et p©edvoleb
TBLHesPN dw        0                        ; d‚lka textu p©edvolby
TBLHesPA dd        0                        ; adresa textu p©edvolby

TBLHesMP db        bit6,25,'Zadejte p©¡stupov‚ heslo:'
         db        0,0
         db        bit6+bit7,0
         db        1,6,'Platn‚'
         db        1,6,'N vrat'

TBLHesMB db        0,0,0                    ; blokovac¡ tabulka

TBLHesMT db        5,'heslo'

HelpS    SEGMENT   BYTE PUBLIC
TBLHesMH db        63,'Zadejte p©¡stupov‚ heslo (nen¡-li zad n ‘ dn˜ znak, nen¡ heslo)'
         db        25,'Bude pou‘ito zadan‚ heslo'
         db        3,1
         dw        MenuHlP2
HelpS    ENDS

SuperHls db        6,0,1
SuperHl0 dd        TBLHeslN

; ------ data

TBLBunTN dw        0                        ; d‚lka textu bu¤ky
TBLBunTx db        'BL999  '                ; text bu¤ky k hled n¡

TBBlokO  dw        0                        ; po‡ tek p©i nastavov n¡ bloku F3

TBBlokAA dw        0                        ; aktu ln¡ adresa ukazatele

TBBlokCB dw        0                        ; sloupec po‡ tku bloku
TBBlokCE dw        0                        ; sloupec konce bloku
TBBlokRB dw        0                        ; © dek po‡ tku bloku * posun
TBBlokRE dw        0                        ; © dek konce bloku * posun

TBLTParm db        bit0+bit1+bit7           ; p©ep¡na‡e
                                            ;   bit 0: 1=p©epo‡et © dk–
                                            ;   bit 1: 1=p©epo‡et sloupc–
                                            ;   bit 2: 1=bu¤ka bloku zru¨ena
                                            ;   bit 3: 1=konec bloku F3 ozna‡en
                                            ;   bit 4: 1=nalezena bu¤ka v bloku
                                            ;   bit 5: 1=operace s blokem (F3)
                                            ;   bit 6:   (1=nastaven¡ ¨¡©ky sloupce)
                                            ;   bit 7: 1=je INSERT

TBLTPrm2 db        0                        ; p©ep¡na‡e 2
                                            ;   bit 1: 1=pot©ebn˜ p©epo‡et

                                            ;   bit 4: 1=p©epo‡et relativn¡
                                            ;           bu¤ky ukazuj¡c¡ do bloku
                                            ;   bit 5: 1=p©epo‡et relativn¡
                                            ;            bu¤ky v‘dy
                                            ;   bit 6: 1=p©epo‡et absolutn¡
                                            ;           bu¤ky ukazuj¡c¡ do bloku
                                            ;   bit 7: 1=p©esun, 0=kop¡rov n¡

; kopie bloku: v bloku - rel. v‘dy, abs. blok; mimo blok - rel. ne, abs. ne
; p©esun bloku: v bloku - rel. v‘dy, abs. blok; mimo blok - rel. blok, abs. blok
; plnˆn¡ bloku: polo‘ka - rel. v‘dy, abs. ne; mimo polo‘ku - rel. ne, abs. ne
; vlo‘en¡/zru¨en¡: v bloku - rel.blok, abs.blok; mimo blok - rel.blok, abs.blok

; p©ep¡na‡e pro vyp¡n n¡ korekc¡ se uplat¤uj¡ pouze pro vnit©n¡ bu¤ky bloku !


TBLKalkP dw        0                        ; £schova parametr– kalkul toru

TBLTExpP db        bit0                     ; parametry k exportu/importu dat
                                            ;   bit 0: 1=v˜razy (0=‡¡sla)
                                            ;   bit 1: 1=tisk (do sloupc–)

; ------ definice ‡¡sla

TBLMist  dw        2                        ; po‡et desetinn˜ch m¡st
TBLMist0 dw        2                        ; £schova po‡tu m¡st kalkul toru

TBLNumN  dw        10                       ; po‡et bajt– na celou ‡ st ‡¡sla
TBLNumNW dw        5                        ; po‡et slov na celou ‡ st ‡¡sla
TBLNumD  dw        10                       ; po‡et bajt– na desetin. ‡ st ‡¡sla
TBLNumDW dw        5                        ; po‡et slov na desetin. ‡ st ‡¡sla
TBLNumX  dw        20                       ; po‡et bajt– na ‡¡slo celkem
TBLNumXW dw        10                       ; po‡et slov na ‡¡slo celkem
TBLXText dw        TblXReal+20              ; offset za‡ tku textu nebo v˜razu

; ------ definice barev

;ColTBLRm db        4eh                      ; barva r mu tabulky (‡¡sla bunˆk)
;ColTBLRS db        4ah                      ; barva p©ep¡na‡– v r mu tabulky
;ColTBLSt db        0ah                      ; informa‡n¡ © dek na spodu tabulky
;
;ColTBL1  db        71h                      ; stavov˜ © dek - bˆ‘n  barva
;ColTBL11 db        74h                      ; stavov˜ © dek - nadpis
;
;ColTBL2  db        0fh                      ; barva ‡¡sel v tabulce
;ColTBL3  db        1fh                      ; barva kurzoru na ‡¡slech
;ColTBL4  db        0bh                      ; barva textu v tabulce (+pr zdn‚)
;ColTBL5  db        1bh                      ; barva kurzoru na textu (+pr zdn‚)
;ColTBL6  db        0dh                      ; barva v˜razu v tabulce
;ColTBL7  db        1dh                      ; barva kurzoru na v˜razu
;
;ColTBL8  db        30h                      ; barva bloku
;ColTBL9  db        60h                      ; barva kurzoru v bloku

TablPath db        FileMax+4 dup(0)         ; adres © tabulky

Data     ENDS

         END


; *****************************************************************************
;
;                                    JONAS
;
;                      P©edpovàÉ narozen° holky nebo kluka
;                        podle metody MUDr Eugena Jon†®e
;
; *****************************************************************************

code     segment
         assume    cs:code,ds:code
         org       100h

Start:

; ------ zad†n° data narozen° matky

Start1:  mov       dx,offset zad1txt
         call      DispTxt                  ; vòzva

         mov       ah,10
         mov       dx,offset Datum
         int       21h                      ; zad†n° textu

         mov       bh,0
         mov       bl,ds:[Datum+1]
         mov       byte ptr ds:[Datum+2+bx],13 ; konec textu CR
         call      DispCr                   ; od©†dkov†n° textu

Start12: mov       si,offset Datum+2
         call      DekSpc
         jnc       Start13

         jmp       Konec

Start13:
         call      DekDate                  ; dek¢dov†n° zadanÇho data
         jnc       Start3

Start2:  mov       dx,offset Err1Txt        ; chyba zad†n°
         call      DispTxt
         jmp       short Start1

Start3:  call      JulDat                   ; datum narozen° abolutnà
         mov       ds:[N1],ax               ; datum narozen° absolutnà

; ------ zad†n° áasu narozen° matky

Start4:  mov       dx,offset zad2txt
         call      DispTxt                  ; vòzva

         mov       ah,10
         mov       dx,offset Datum
         int       21h                      ; zad†n° textu

         mov       bh,0
         mov       bl,ds:[Datum+1]
         mov       byte ptr ds:[Datum+2+bx],13 ; konec textu CR

         call      DispCr                   ; od©†dkov†n° textu

         mov       si,offset Datum+2
         call      DekSpc
         jnc       Start41

         mov       byte ptr ds:[Minuta],0
         mov       byte ptr ds:[Hodina],12
         jmp       short Start43

Start41:
         call      DekTime                  ; dek¢dov†n° zadanÇho áasu
         jnc       Start43

Start42: mov       dx,offset Err2Txt        ; chyba zad†n°
         call      DispTxt
         jmp       short Start4

; ------ korekce áasu

Start43: mov       al,60                    ; poáet minut na hodinu
         mul       byte ptr ds:[Hodina]     ; p©epoáet hodin na minuty
         add       al,ds:[Minuta]
         adc       ah,0
         mov       ds:[T1],ax               ; áas narozen° matky absolutnà

; ------ vòpoáet f†ze màs°ce

         call      Moon                     ; vòpoáet f†ze màs°ce




;call      JulDat                   ; datum narozen° abolutnà
;         mov       ds:[N1],ax               ; datum narozen° absolutnà

Start44:




Konec:

         int       20h

; -----------------------------------------------------------------------------
;        absolutn° poáet dnñ od 31.12.1899 (AX=poáet dnñ)
; -----------------------------------------------------------------------------

JulDat   PROC      NEAR

         push      bx
         push      cx
         push      dx

         mov       cx,ds:[Rok]
         mov       bh,ds:[Mesic]
         mov       bl,ds:[Den]
         call      KonvDatN                 ; konverze data na den

         sub       ax,word ptr ds:[Den1]
         sbb       dx,word ptr ds:[Den1+2]
         jnc       JulDat3
         xor       ax,ax
JulDat3:

JulDat9: pop       dx
         pop       cx
         pop       bx
         ret

JulDat   ENDP

; -----------------------------------------------------------------------------
;        vòpoáet data z absolutn°ho poátu dnñ od 31.12.1899 (AX=poáet dnñ)
; -----------------------------------------------------------------------------

InvJul   PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx

         xor       dx,dx
         add       ax,word ptr ds:[Den1]
         adc       dx,word ptr ds:[Den1+2]

         call      KonvNDat                 ; vòpoáet data

         mov       ds:[Den],bl
         mov       ds:[Mesic],bh
         mov       ds:[Rok],cx

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

InvJul   ENDP

; *****************************************************************************
;                            KonvDatN
;                     p©evod data na poáet dnñ
; -----------------------------------------------------------------------------
; VSTUP: CX=rok
;        BH=màs°c
;        BL=den
; VùSTUP:DX:AX=den absolutnà
; *****************************************************************************

KonvDatN PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      cx
         push      si

; ------ p©°prava registrñ a p©iáten° dne

         xor       dx,dx                    ; nië®° slovo st©adaáe
         xor       si,si                    ; vy®®° slovo st©adaáe
         mov       dl,bl                    ; den
         dec       dl                       ; korekce (0...)

; ------ p©iáten° màs°cñ

KonvDtN1:dec       bh                       ; sn°ëen° ukazatele màs°ce
         jz        KonvDtN2                 ; byly jië v®echny màs°ce
         call      MesicGet                 ; stanoven° poátu dnñ v màs°ci
         add       dx,ax                    ; p©iáten° poátu dnñ v màs°ci
         jmp       short KonvDtN1           ; dal®° màs°c

; ------ p©iáten° let

KonvDtN2:sub       cx,1                     ; sn°ëen° ukazatele rokñ
         jc        KonvDtN3                 ; byly jië v®echny roky
         cmp       cx,1979
         jne       KonvDtN4

         add       dx,word ptr ds:[Den0]
         adc       si,word ptr ds:[Den0+2]
         jmp       short KonvDtN3

KonvDtN4:call      RokGet                   ; stanoven° poátu dnñ v roce
         add       dx,ax                    ; p©iáten° poátu dnñ v roce
         adc       si,0                     ; p©enos do vy®®°ho slova
         jmp       short KonvDtN2           ; dal®° rok

; ------ n†vrat registrñ

KonvDtN3:mov       ax,dx                    ; den absolutnà LOW
         mov       dx,si                    ; den absolutnà HIGH
         pop       si
         pop       cx
         pop       bx
         ret

KonvDatN ENDP

; *****************************************************************************
;                              KonvNDat
;                  p©evod absolutn°ho dne na datum
; -----------------------------------------------------------------------------
; VSTUP: DX:AX=den absolutnà
; VùSTUP:AL=den v tòdnu (0...)
;        AH=poáet dnñ v màs°ci
;        BH=màs°c
;        BL=den
;        CX=rok
; *****************************************************************************

KonvNDat PROC      NEAR

; ------ £schova registrñ

         push      dx
         push      si
         push      di
         push      bp

; ------ p©°prava registrñ

         mov       bp,dx                    ; den HIGH
         mov       di,ax                    ; den LOW
         mov       si,dx                    ; den HIGH
         mov       dx,ax                    ; den LOW
         xor       cx,cx                    ; CX <- 0

; ------ odeáten° stolet°

KonvNDt1:call      StoGet                   ; stanoven° poátu dnñ ve stolet°
         sub       dx,ax                    ; stolet° dosaëeno ?
         sbb       si,0                     ; p©enos do vy®®°ho slova
         jc        KonvNDt2                 ; stolet° dosaëeno OK
         add       cx,100                   ; zvò®en° ukazatele roku o 100 let
         jmp       short KonvNDt1           ; p©evod dal®°ho stolet°
KonvNDt2:add       dx,ax                    ; n†vrat stolet°
         adc       si,0                     ; p©enos do vy®®°ho slova

; ------ odeáten° rokñ ve stolet°

KonvNDt3:call      RokGet                   ; stanoven° poátu dnñ v roce
         sub       dx,ax                    ; roku dosaëeno ?
         sbb       si,0                     ; p©enos do vy®®°ho slova
         jc        KonvNDt4                 ; rok je nastaven OK
         inc       cx                       ; zvò®en° ukazatele roku
         jmp       short KonvNDt3           ; p©evod dal®°ho roku
KonvNDt4:add       dx,ax                    ; n†vrat roku
         adc       si,0                     ; p©enos do vy®®°ho slova

; ------ odeáten° màs°ce

         xor       bx,bx                    ; p©ednastaven° màs°ce a dne
KonvNDt5:inc       bh                       ; zvò®en° á°sla màs°ce
         call      MesicGet                 ; stanoven° poátu dnñ v màs°ci
         sub       dx,ax                    ; je màs°c nalezen ?
         sbb       si,0                     ; p©enos do vy®®°ho slova
         jnc       KonvNDt5                 ; p©evod dal®°ho màs°ce
         add       dx,ax                    ; n†vrat màs°ce

; ------ stanoven° dne

         inc       dl                       ; den v màs°ci
         mov       bl,dl                    ; den v màs°ci

; ------ vòpoáet dne v tòdnu

         push      bx
         push      ax

         mov       dx,bp                    ; den HIGH
         mov       ax,di                    ; den LOW
         add       ax,3                     ; korekce pro spr†vnò den
         adc       dx,0                     ; p©enod do vy®®°ho slova
         mov       bx,7                     ; poáet dnñ v tòdnu

         push      ax                       ; den LOW
         mov       ax,dx                    ; den HIGH
         xor       dx,dx                    ; DX <- 0
         div       bx                       ; dàlen° vy®®°ho slova
         pop       ax                       ; den LOW
         div       bx                       ; vòpoáet dne v tòdnu
         mov       al,dl                    ; den v tòdnu

         pop       bx                       ; n†vrat poátu dnñ v màs°ci
         mov       ah,bl                    ; poáet dnñ v màs°ci
         pop       bx

; ------ n†vrat registrñ

         pop       bp
         pop       di
         pop       si
         pop       dx
         ret

KonvNDat ENDP

; -----------------------------------------------------------------------------
;                     stanoven° poátu dnñ v màs°ci
; -----------------------------------------------------------------------------
; VSTUP: BH=màs°c
;        CX=rok
;        DS=datovò segment
; VùSTUP:AX=poáet dnñ
; -----------------------------------------------------------------------------

MesicGet PROC      NEAR

         push      bx

; ------ v prosinci 1582 je 28 dnñ

         cmp       cx,1582                  ; je rok 1582 ?
         jne       MesicGt1                 ; nen° rok 1582
         mov       ax,28                    ; je 28 dnñ v prosinci
         cmp       bh,12                    ; je prosinec ?
         je        MesicGt2                 ; je prosinec 1582

; ------ poáet dnñ v màs°ci

MesicGt1:mov       bl,bh                    ; màs°c
         xor       bh,bh                    ; BX=màs°c
         mov       al,ds:[bx+PoctyDnu-1]    ; poáet dnñ v màs°ci
         cbw                                ; poáet dnñ v màs°ci
         cmp       bl,2                     ; je to £nor ?
         jne       MesicGt2                 ; nen° £nor
         call      RokTest                  ; test p©estupnosti roku
         jnc       MesicGt2                 ; rok nen° p©estupnò
         inc       ax                       ; poáet dnñ v £noru = 29

MesicGt2:pop       bx
         ret

MesicGet ENDP

; -----------------------------------------------------------------------------
;                     stanoven° poátu dnñ v roce
; -----------------------------------------------------------------------------
; VSTUP: CX=rok
; VùSTUP:AX=poáet dnñ
; -----------------------------------------------------------------------------

RokGet   PROC      NEAR

; ------ poáet dnñ v roce 1582

         mov       ax,365-3                 ; poáet dnñ v roce 1582
         cmp       cx,1582                  ; je rok 1582 ?
         je        RokGet1                  ;

; ------ poáet dnñ podle p©estupnosti roku

         mov       ax,365                   ; poáet dnñ v nep©estupnÇm roce
         call      RokTest                  ; test p©estupnosti roku
         jnc       RokGet1                  ; rok nen° p©estupnò
         inc       ax                       ; poáet dnñ v p©estup. roce 366
RokGet1: ret

RokGet   ENDP

; -----------------------------------------------------------------------------
;                    test p©estupnosti roku
; -----------------------------------------------------------------------------
; VSTUP: CX=rok
; VùSTUP:CY=je p©estupnò rok
; -----------------------------------------------------------------------------

RokTest  PROC      NEAR

; ------ test, zda rok je n†sobkem 4

         test      cl,3                     ; je p©estupnò rok ?
         jnz       RokTest3                 ; nen° p©estupnò rok

; ------ p©ed rokem 1600 je p©estupnÇ vëdy

         cmp       cx,1600                  ; je p©ed rokem 1600 ?
         jb        RokTest3                 ; p©ed 1600 p©estupnÇ vëdy

; ------ £schova registrñ

         push      ax
         push      bx
         push      dx

; ------ test, zda je stolet° n†sobkem 4

         mov       bx,100                   ; stolet°
         xor       dx,dx                    ; DX <- 0
         mov       ax,cx                    ; rok
         div       bx                       ; vòpoáet stolet°
         or        dx,dx                    ; je stolet° ?
         jnz       RokTest1                 ; nen° stolet° - je p©estupnò
         test      ax,3                     ; je stolet° dàlitelnÇ 4 ?
         jnz       RokTest2                 ; nen° dàlitelnÇ - nen° p©estupnÇ

; ------ n†vrat registrñ

RokTest1:stc                                ; p©°znak p©estupnÇho roku
RokTest2:pop       dx
         pop       bx
         pop       ax

RokTest3:ret

RokTest  ENDP

; -----------------------------------------------------------------------------
;                      stanoven° poátu dnñ ve stolet°
; -----------------------------------------------------------------------------
; VSTUP: CX=rok (koná°c° 00 - stolet°)
; VùSTUP:AX=poáet dnñ ve stolet° (od roku CX po rok CX+99)
; -----------------------------------------------------------------------------

StoGet   PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      dx

; ------ vòpoáet á°sla stolet°

         xor       dx,dx                    ; DX <- 0
         mov       ax,cx                    ; rok
         mov       bx,100                   ; poáet let ve stolet°
         div       bx                       ; vòpoáet stolet°

; ------ poáet let ve stolet° 15xx

         cmp       ax,15                    ; je stolet° 15 ?
         jne       StoGet1                  ; nen° stolet° 15
         mov       ax,25*366+75*365-3       ; zkr†cenÇ p©estupnÇ stolet°
         jmp       short StoGet3

; ------ stolet° p©ed 1582 je p©estupnÇ vëdy

StoGet1: cmp       cx,1600                  ; je p©ed rokem 1600 ?
         jb        StoGet2                  ; je p©ed 1600 - p©estupnÇ vëdy

; ------ poáet let podle p©estupnosti stolet°

         test      al,3                     ; je stolet° dàlitelnÇ 4 ?
         mov       ax,24*366+76*365         ; nep©estupnÇ stolet°
         jnz       StoGet3                  ; stolet° nen° p©estupnÇ
StoGet2: mov       ax,25*366+75*365         ; stolet° je p©estupnÇ

; ------ n†vrat registrñ

StoGet3: pop       dx
         pop       bx
         ret

StoGet   ENDP


; -----------------------------------------------------------------------------
;        dek¢dov†n° áasu
; -----------------------------------------------------------------------------

DekTime  PROC      NEAR

         call      DekNum                   ; dek¢dov†n° hodiny
         jc        DekTime9
         mov       ds:[Hodina],al           ; hodina

         call      DekTec                   ; dek¢dov†n° oddàlovaáe
         jc        DekTime9

         call      DekNum                   ; dek¢dov†n° minuty
         jc        DekTime9
         mov       ds:[Minuta],al           ; minuta
         clc

DekTime9:
         ret

DekTime  ENDP

; -----------------------------------------------------------------------------
;        dek¢dov†n° data
; -----------------------------------------------------------------------------

DekDate  PROC      NEAR

         call      DekNum                   ; dek¢dov†n° data
         jc        DekDate9
         mov       ds:[Den],al              ; den

         call      DekTec                   ; dek¢dov†n° oddàlovaáe
         jc        DekDate9

         call      DekNum                   ; dek¢dov†n° màs°ce
         jc        DekDate9
         mov       ds:[Mesic],al            ; màs°c

         call      DekTec                   ; dek¢dov†n° oddàlovaáe
         jc        DekDate9

         call      DekNum                   ; dek¢dov†n° roku
         jc        DekDate9
         cmp       ax,100
         ja        DekDate2
         add       ax,1900
DekDate2:mov       ds:[Rok],ax              ; rok
         clc

DekDate9:
         ret

DekDate  ENDP

; -----------------------------------------------------------------------------
;        dek¢dov†n° oddàlovac° teáky
; -----------------------------------------------------------------------------

DekTec   PROC      NEAR

         call      DekSpc
         call      DekCh
         jc        DekTec9
         cmp       al,"."
         je        DekTec9
         cmp       al,","
         je        DekTec9
         cmp       al,"/"
         je        DekTec9
         cmp       al,":"
         je        DekTec9
         stc

DekTec9: ret

DekTec   ENDP

; -----------------------------------------------------------------------------
;        dek¢dov†n° á°sla
; -----------------------------------------------------------------------------

DekNum   PROC      NEAR

         push      dx
         xor       dx,dx
         call      DekSpc                   ; vypu®tàn° poá†teán°ch mezer
         call      DekNm                    ; prvn° á°slice
         jc        DekNum9

DekNum1: push      ax
         mov       ax,10
         mul       dx
         pop       dx
         mov       dh,0
         add       dx,ax
         call      DekNm
         jnc       DekNum1
         clc

DekNum9: mov       ax,dx
         pop       dx
         ret

DekNum   ENDP

DekNm    PROC      NEAR

         call      DekCh
         jc        DekNm9
         cmp       al,"0"
         jb        DekNm8
         cmp       al,"9"
         ja        DekNm8
         sub       al,"0"
         ret

DekNm8:  dec       si
         stc
DekNm9:  ret

DekNm    ENDP

; -----------------------------------------------------------------------------
;        vypu®tàn° poá†teán°ch mezer (DS:SI=ukazatel textu, CY=konec textu)
; -----------------------------------------------------------------------------

DekSpc   PROC      NEAR

         call      DekCh
         jc        DekSpc9
         cmp       al," "
         je        DekSpc
         dec       si
DekSpc9: ret

DekSpc   ENDP

; -----------------------------------------------------------------------------
;        vstup znaku p©i dek¢dov†n° (DS:SI=ukazatel textu, CY=nen° dal®° znak)
; -----------------------------------------------------------------------------

DekCh    PROC      NEAR

         mov       al,ds:[si]
         cmp       al,9
         jne       DekCh1
         mov       al," "
DekCh1:  cmp       al," "
         jb        DekCh9
         inc       si
DekCh9:  ret

DekCh    ENDP

; -----------------------------------------------------------------------------
;        od©†dkov†n°
; -----------------------------------------------------------------------------

DispCr   PROC      NEAR

         push      dx
         mov       dx,offset CrTxt
         call      DispTxt
         pop       dx
         ret

DispCr   ENDP

; -----------------------------------------------------------------------------
;        zobrazen° textu
; -----------------------------------------------------------------------------

DispTxt  PROC      NEAR

         push      ax
         mov       ah,9
         int       21h
         pop       ax
         ret

DispTxt  ENDP


; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------

A        db        0
I        db        0
J        db        0
Minuta   db        0
Hodina   db        0
Den      db        0                        ; den
Mesic    db        0                        ; màs°c
Rok      dw        0                        ; rok
N1       dw        0                        ; datum narozen° absolutnà
T1       dw        0                        ; áas narozen° matky absolutnà

Den0     dd        723189                   ; den 1.1.1980
Den1     dd        693970                   ; den 31.12.1899

; ------ poáty dnñ v màs°c°ch roku

PoctyDnu db        31                       ; leden
         db        28                       ; £nor
         db        31                       ; b©ezen
         db        30                       ; duben
         db        31                       ; kvàten
         db        30                       ; áerven
         db        31                       ; áervenec
         db        31                       ; spren
         db        30                       ; z†©°
         db        31                       ; ©°jen
         db        30                       ; listopad
         db        31                       ; prosinec

Zad1Txt  db        'Datum narozeni matky [Den.Mesic.Rok] (Enter=konec): $'
Err1Txt  db        'Chybne zadani data !',13,10,'$'

Zad2Txt  db        'Cas narozeni matky [Hodina:Minuta] (Enter=12:00): $'
Err2Txt  db        'Chybne zadani casu !',13,10,'$'

CrTxt    db        13,10,'$'

Datum    db        127,0,128 dup(?)         ; buffer k zad†n° data

code     ends
         end       Start

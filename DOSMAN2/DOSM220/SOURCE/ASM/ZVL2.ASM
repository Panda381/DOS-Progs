
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                             Z V L è õ T N ã - 2
;
;                    Zvl†®tn° funkce - kalend†©, ASCII tabulka
;
; =============================================================================
;
; Ve©ejnÇ procedury:
;
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

INCLUDE  ASM\DEF.ASM

CodeZvl  SEGMENT   BYTE PUBLIC
         ASSUME    cs:CodeZvl,ds:Data

; *****************************************************************************
;
;                          ASCII tabulka
;
; *****************************************************************************
;˛
AsciiTab PROC      FAR

         add       sp,4                     ; zru®en° n†vratovÇ adresy
         call      far ptr ClosMnuA         ; uzav©en° v®ech oken
         call      far ptr TabAscii
         jmp       far ptr Main0

AsciiTab ENDP

; -----------------------------------------------------------------------------
;        vol†n° tabulky ASCII
; -----------------------------------------------------------------------------

TabAscii PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si

; ------ £schova kurzoru

         call      far ptr GetKurz          ; poskytnut° kurzoru
         mov       ds:[AsciOKur],dx         ; £schova kurzoru

; ------ vypnut° grafickÇ my®i

         or        byte ptr ds:[ParMous2],bit1 ; z†kaz grafickÇ my®i
         call      far ptr RIniMous         ; reinicializace my®i

; ------ otev©en° ASCII tabulky

TabAsci0:mov       si,offset ZAMnuLin       ; okno ASCII tabulky
         call      far ptr OpenMnu          ; otev©en° menu ASCII tabulky
         or        byte ptr ds:[ParZvl],bit0 ; p©°znak zapnut° ASCII tabulky

; ------ áek†n° na znak z kl†vesnice

TabAsci1:call      far ptr KurzOff          ; vypnut° kurzoru
         call      far ptr InpChar          ; vstup znaku z kl†vesnice
         jc        TabAsci9                 ; ESC - p©eru®en°

; ------ p©eru®en° menu stiskem pravÇho tlaá°tka nebo stiskem mimo ©†dek

         cmp       bh,MousXKod/HI           ; je k¢d my®i ?
         jne       TabAsc14                 ; nen° k¢d my®i
         and       bl,not bit6              ; zru®en° p©°znaku dvoj°ho stisku
         cmp       bl,MousXRP               ; stisk pravÇho tlaá°tka ?
         je        TabAsci9                 ; p©eru®en° pravòm tlaá°tkem my®i
         test      bl,bit2+bit3             ; stisk nàkterÇho tlaá°tka ?
         jz        TabAsc12                 ; nen° stisk tlaá°tka
         call      far ptr MouseMnu         ; test, zda je okno menu
         jc        TabAsci9                 ; je p©eru®en°
TabAsc12:cmp       bl,MousXLR               ; uvolnàn° levÇho tlaá°tka
         je        TabAsc14
         cmp       bl,MousXLP               ; stisk levÇho tlaá°tka
         je        TabAsc14
         cmp       bl,MousXMov              ; posun my®i
         jne       TabAsci1

; ------ Tabul†tor - zmàna polohy

TabAsc14:cmp       bx,0f09h                 ; tabul†tor
         jne       TabAsci2
         inc       byte ptr ds:[AscTbSwc]   ; p©ep°naá
         cmp       byte ptr ds:[AscTbSwc],3
         jb        TabAsci3
         mov       byte ptr ds:[AscTbSwc],0
         jmp       short TabAsci3

; ------ Shift-Tab - zmàna polohy

TabAsci2:cmp       bx,0f00h                 ; zpàtnò tabul†tor
         jne       TabAsci4
         dec       byte ptr ds:[AscTbSwc]
         jns       TabAsci3
         mov       byte ptr ds:[AscTbSwc],2
TabAsci3:call      far ptr ClosMnu          ; uzav©en° okna
         jmp       short TabAsci0           ; novÇ otev©en° okna

; ------ mezera - barva/znaky

TabAsci4:cmp       bx,3920h
         jne       TabAsci5
         xor       byte ptr ds:[AscTbSw2],bit0 ; p©°znak barev
         jmp       short TabAsci3

; ------ editace ASCII tabulky

TabAsci5:call      far ptr EditAMnu         ; editace menu ASCII tabulky
         jc        TabAsci1                 ; pokraáov†n° v obsluze

; ------ proveden† volba ASCII tabulky

TabAsci7:xor       ah,ah
         mov       al,byte ptr ds:[si+MnuAkt] ; zvolenò znak
         dec       ax                       ; oprava
         jnz       TabAsci8
         mov       ah,3                     ; n†hrada znakem Ctrl-@
TabAsci8:mov       ds:[KeyBuff],ax          ; £schova do bufferu

; ------ uzav©en° okna

TabAsci9:call      far ptr ClosMnu          ; uzav©en° okna
         and       byte ptr ds:[ParZvl],not bit0 ; p©°znak vypnut° ASCII tabulky

; ------ zapnut° grafickÇ my®i

         and       byte ptr ds:[ParMous2],not bit1 ; zru®en° z†kazu grafickÇ my®i
         call      far ptr RIniMous         ; reinicializace my®i

; ------ navr†cen° kurzoru

         call      far ptr NulBreak         ; nulov†n° p©°znaku p©eru®en°

         mov       dx,ds:[AsciOKur]         ; pñvodn° kurzor
         call      far ptr SetKurz          ; nastaven° kurzoru

; ------ n†vrat registrñ

         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

TabAscii ENDP

; *****************************************************************************
;                                EditAMnu
;                     editace menu ASCII tabulky
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa definice menu
;        BX=kl†vesa
; VùSTUP:BX=0 kl†vesa byla obslouëena
;        NC=provedena volba poloëky
;        CY=pokraáuje editace
; *****************************************************************************

EditAMnu PROC      FAR

; ------ p©echodnÇ vypnut° menu

         call      far ptr MCtrlO           ; p©echodnÇ vypnut° menu
         jnc       EditAM02                 ; nebyla funkce Ctrl-O
         ret

; ------ £schova registrñ

EditAM02:push      ax
         push      cx
         push      dx
         push      si

; ------ obsluha ©°dic° kl†vesy

         mov       al,byte ptr ds:[si+MnuAkt]        ; aktivn° poloëka
         dec       ax
         call      far ptr JumpBX

         dw        4b00h,EditAMn1           ; VLEVO
         dw        4d00h,EditAMn2           ; VPRAVO
         dw        4800h,EditAM42           ; NAHORU
         dw        5000h,EditAM43           ; DOL¶

         dw        4700h,EditAM51           ; HOME
         dw        4f00h,EditAM52           ; END
         dw        4900h,EditAM47           ; PAGEUP
         dw        5100h,EditAM46           ; PAGEDOWN

         dw        7700h,EditAM49           ; ^HOME
         dw        8400h,EditAM49           ; ^PAGEUP
         dw        7500h,EditAM48           ; ^END
         dw        7600h,EditAM48           ; ^PAGEDOWN

         dw        1c0dh,EditAM11           ; ENTER
         dw        1910h,EditAM11           ; Ctrl-P

         dw        MousXKod+MousXLR,EditAMA2 ; uvolnàn° levÇho tlaá°tka my®i
         dw        MousXKod+MousXLP,EditAMA3 ; stisk levÇho tlaá°tka my®i
         dw        MousXKod+MousXMov,EditAMA3 ; posun my®i

         dw        0,EditAMn0

; ------ uvolnàn° levÇho tlaá°tka my®i

EditAMA2:call      far ptr MouseMnu         ; test, zda je my® v oknà
         jnc       EditAM11                 ; proveden° volby
EdiAMA22:jmp       EditAMn8                 ; nen° v oknà - nic se nedàje

; ------ posun my®i

EditAMA3:test      byte ptr ds:[MouseKey],bit1 ; je pouze levÇ tlaá°tko ?
         jnz       EdiAMA22                 ; nen° jen levÇ tlaá°tko
         call      far ptr MouseMnu         ; je my® v oknà ?
         jc        EdiAMA22                 ; nen° v oknà
         mov       ax,word ptr ds:[MousePoz] ; pozice kurzoru
         sub       ax,word ptr ds:[si+MnuPoz] ; pozice a ©†dek relativnà

         sub       ah,2
         jnc       EdiAMA32
         mov       ah,0

EdiAMA32:sub       al,1
         jnc       EdiAMA33
         mov       al,0
EdiAMA33:shr       al,1

         cmp       al,16
         jb        EdiAMA34
         mov       al,15

EdiAMA34:cmp       ah,16
         jb        EdiAMA35
         mov       ah,15

EdiAMA35:shl       ah,1
         shl       ah,1
         shl       ah,1
         shl       ah,1
         or        al,ah
         jmp       short EditAMn6

; ------ zad†n k¢d znaku

EditAMn0:mov       al,bl
         or        bl,bl
         jnz       EditAMn6
         cmp       bx,0300h
         je        EditAMn6
         jmp       short EditAMn8           ; jinak neobslouëen† kl†vesa

; ------ posun na horn° okraj (PageUp)

EditAM47:and       al,not 0f0h
         jmp       short EditAMn6

; ------ posun na doln° okraj (PageDown)

EditAM46:or        al,0f0h
         jmp       short EditAMn6

; ------ prvn° poloëka (Ctrl-Home, Ctrl-PageUp)

EditAM49:mov       al,0
         jmp       short EditAMn6

; ------ posledn° poloëka (Ctrl-PageDown, Ctrl-End)

EditAM48:mov       al,0ffh
         jmp       short EditAMn6

; ------ potvrzen° volby ENTER

EditAM11:xor       bx,bx
         jmp       short EditAMn9

; ------ posun o znak vlevo (VLEVO)

EditAMn1:dec       ax
         jmp       short EditAMn6

; ------ posun o znak vpravo (VPRAVO)

EditAMn2:inc       ax
         jmp       short EditAMn6

; ------ posun o ©†dek nahoru (NAHORU)

EditAM42:sub       al,16
         jmp       short EditAMn6

; ------ posun o ©†dek dolñ (DOL¶)

EditAM43:add       al,16
         jmp       short EditAMn6

; ------ prvn° poloëka na ©†dku (Home)

EditAM51:and       al,not 0fh
         jmp       short EditAMn6

; ------ posledn° poloëka na ©†dku (End)

EditAM52:or        al,0fh

; ------ nastaven° novÇ pozice kurzoru AL

EditAMn6:mov       ah,0                     ; AH <- 0
         inc       ax                       ; korekce á°sla poloëky
         mov       ds:[si+MnuAkt],ax        ; nov† aktivn° poloëka
         call      far ptr DispMnu          ; novÇ zobrazen° menu
         xor       bx,bx                    ; BX <- 0 kl†vesa pouëita
EditAMn8:stc                                ; p©°znak pokraáuj°c° volby

; ------ n†vrat registrñ

EditAMn9:pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

EditAMnu ENDP

; *****************************************************************************
;                              InitAMnu
;                     inicializace menu ASCII
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa definice menu
; *****************************************************************************

InitAMnu PROC      FAR

         push      ax

         mov       word ptr ds:[si+MnuTitl],offset ZAMnuLT1 ; ASCII
         mov       al,35                    ; ®°©ka pro HEX tabulku
         test      byte ptr ds:[AscTbSw2],bit0 ; jsou barvy ?
         jz        InitAMn1                 ; nejsou barvy
         mov       word ptr ds:[si+MnuTitl],offset ZAMnuLT2 ; barvy
         mov       al,35+16                 ; ®°©ka pro barvy

InitAMn1:mov       ds:[si+MnuSir],al        ; ®°©ka okna

         call      far ptr CentMenu         ; vyst©edàn° okna

         cmp       byte ptr ds:[AscTbSwc],1 ; je poloha ve st©edu ?
         je        InitAMn3                 ; je poloha ve st©edu
         mov       al,1                     ; poloha vlevo
         jb        InitAMn2                 ; je poloha vlevo

         mov       al,ds:[MaxPoz]           ; maxim†ln° pozice
         sub       al,ds:[si+MnuSir]        ; odeáten° ®°©ky okna

InitAMn2:mov       ds:[si+MnuPoz],al        ; poá†teán° pozice okna

InitAMn3:pop       ax
         ret

InitAMnu ENDP

; *****************************************************************************
;                               DispAMnu
;                      zobrazen° ASCII tabulky
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
;        DS:SI=definice okna
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-1] (1) ©†dek na displeji
;                   SS:[BP-2] (1) poá†teán° pozice okna
;                   SS:[BP-3] (1) á°taá ©†dkñ k zobrazen°
;                   SS:[BP-4] (1) ®°©ka okna
;                   SS:[BP-6] (2) hladina k zobrazen°
;                   SS:[BP-7] (1) ukazatel á°sla poloëky
;                   SS:[BP-8] (1) aktivn° poloëka
; *****************************************************************************

DispAMnu PROC      FAR

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

; ------ p©°prava lok†ln°ch promànnòch

         sub       sp,8
         mov       ax,word ptr ds:[si+MnuPoz] ; pozice a ©†dek okna
         inc       ah                       ; zvò®en° ukazatele ©†dku
         mov       ss:[bp-2],ax             ; ukazatel ©†dku a pozice
         mov       ax,word ptr ds:[si+MnuSir] ; ®°©ka a vò®ka okna
         sub       ah,3                     ; odeáten° ©†dkñ okrajñ
         mov       ss:[bp-4],ax             ; ®°©ka a vò®ka okna
         mov       ah,0
         shl       ax,1                     ; AX <- ®°©ka okna * 2
         sub       sp,ax                    ; buffer pro ©†dek
         mov       al,ds:[si+MnuLev]        ; hladina k zobrazen°
         mov       ah,0
         mov       ss:[bp-6],ax             ; hladina k zobrazen°
         mov       al,byte ptr ds:[si+MnuAkt] ; aktivn° poloëka
         dec       ax                       ; korekce aktivn° poloëky
         mov       ah,0                     ; ukazatel á°sla poloëky
         mov       ss:[bp-8],ax             ; ukazatel á°sla poloëky

; ------ p©°prava informaán°ho ©†dku (AL=aktivn° poloëka)

         push      ds
         pop       es                       ; ES <- datovò segment
         mov       di,offset TextTD+3       ; buffer pro dekadickò tvar
         mov       word ptr es:[di-3],"  "  ; vymaz†n° starÇho á°sla
         xor       dx,dx                    ; DX <- á°slo HIGH
         xor       bx,bx                    ; barva ani oddàlovaá se neukl†d†
         call      far ptr DekNumD          ; dek¢dov†n° á°sla
         mov       di,offset TextTH
         call      far ptr DekHByte         ; dek¢dov†n° bajtu HEX (AH=0 !)
         mov       di,offset TextTB
         call      far ptr DekBByte         ; dek¢dov†n° bajtu bin†rnà (AH=0 !)

; ------ dek¢dov†n° informaán°ho ©†dku do bufferu

         mov       di,sp                    ; DI <- buffer v z†sobn°ku
         push      ss
         pop       es                       ; ES <- segment z†sobn°ku
         cld

         mov       al,"≥"                   ; "≥"
         mov       ah,ds:[ColMnu1R]
         stosw                              ; levò okraj

         mov       si,offset TextT          ; text k dek¢dov†n°
         mov       ah,ds:[ColT4]            ; zvòraznànò text inf. ©†dku
         mov       dh,ds:[ColT3]            ; bàënò text inf. ©†dku
         mov       cx,offset(TextT0-TextT)-6 ; dÇlka textu (jen platnÇ znaky)
         test      byte ptr ds:[AscTbSw2],bit0 ; jsou barvy ?
         jz        DispAMn1                 ; nejsou barvy
         mov       cl,offset(TextT0-TextT)-6 + 16 ; dÇlka, jsou-li barvy
DispAMn1:xchg      ah,dh                    ; z†màna barvy
DispAMn2:lodsb                              ; naáten° znaku
         or        al,al                    ; je zmàna barvy ?
         jz        DispAMn1                 ; je zmàna barvy
         stosw                              ; uloëen° znaku
         loop      DispAMn2                 ; dal®° znak

         test      byte ptr ds:[AscTbSw2],bit0 ; jsou barvy ?
         jz        DispAMn3                 ; nejsou barvy
         mov       ah,dh                    ; vòrazn† barva
         mov       al,ss:[bp-8]             ; aktivn° poloëka
         mov       es:[di-2*14],ax          ; aktivn° znak

DispAMn3:mov       al,"≥"                   ; "≥"
         mov       ah,ds:[ColMnu1L]
         stosw                              ; pravò okraj

; ------ zobrazen° informaán°ho ©†dku

         mov       si,sp                    ; SI <- text k zobrazen°
         mov       ax,ss:[bp-6]             ; AX <- hladina k zobrazen°
         mov       dx,ss:[bp-2]             ; DX <- ©†dek a pozice
         mov       cx,ss:[bp-4]             ; CL <- ®°©ka okna
         call      far ptr DispMStr         ; zobrazen° ©†dku

; ------ p©°prava k dek¢dov†n° jednoho ©†dku

DispAMn5:inc       byte ptr ss:[bp-1]       ; zvò®en° á°sla ©†dku
         cld

; ------ inicializaán° vymaz†n° ©†dku

         mov       di,sp                    ; DI <- buffer
         mov       al,"≥"                   ; "≥"
         mov       ah,ds:[ColMnu1R]
         stosw                              ; levò okraj

         mov       cl,ss:[bp-4]             ; CL <- ®°©ka okna
         mov       ch,0
         dec       cx
         dec       cx                       ; vnit©n° ®°©ka okna
         mov       al,ds:[ColT1]            ; bàën† barva
         mov       al," "
         rep       stosw                    ; vymaz†n° vnit©ku ©†dku

         mov       al,"≥"                   ; "≥"
         mov       ah,ds:[ColMnu1L]
         stosw                              ; pravò okraj

; ------ uloëen° poloëek

         mov       di,sp                    ; DI <- buffer
         add       di,2*2                   ; poá†teán° pozice k uloëen°

         mov       cl,16                    ; poáet poloëek na ©†dku
DispAMn6:mov       al,ss:[bp-7]             ; ukazatel á°sla poloëky
         test      byte ptr ds:[AscTbSw2],bit0 ; jsou barvy ?
         jz        DispAMn7                 ; nejsou barvy
         mov       ah,al                    ; barva
         or        al,al
         jnz       DispAM62
         mov       al,"0"
         stosw
         stosw
         jmp       short DispAM64
DispAM62:call      far ptr DekHByte         ; dek¢dov†n° hodnoty bajtu
DispAM64:inc       di
         inc       di                       ; p©eskoáen° oddàlovac° mezery
         cmp       ah,ss:[bp-8]             ; je to aktivn° poloëka ?
         jne       DispAM82                 ; nen° to aktivn° poloëka
         mov       byte ptr es:[di-4*2],"["
         mov       byte ptr es:[di-2],"]"
         jmp       short DispAM82

DispAMn7:stosb                              ; uloëen° znaku
         cmp       al,ss:[bp-8]             ; je to aktivn° poloëka ?
         jne       DispAMn8                 ; nen° to aktivn° poloëka
         mov       al,ds:[ColT2]            ; barva kurzoru
         mov       es:[di-2],al             ; oznaáen° kurzoru
         mov       es:[di],al
         mov       es:[di+2],al             ; zobrazen° kurzoru
DispAMn8:add       di,3                     ; adresa pro dal®° poloëku
DispAM82:inc       byte ptr ss:[bp-7]       ; zvò®en° á°sla poloëky
         loop      DispAMn6                 ; dal®° poloëka

; ------ zobrazen° jednoho ©†dku

         mov       si,sp                    ; SI <- buffer k zobrazen°
         mov       ax,ss:[bp-6]             ; AX <- hladina k zobrazen°
         mov       dx,ss:[bp-2]             ; DX <- ©†dek a pozice
         mov       cx,ss:[bp-4]             ; CL <- ®°©ka okna
         call      far ptr DispMStr         ; zobrazen° ©†dku

; ------ p©°prava pro dal®° ©†dek

         dec       byte ptr ss:[bp-3]       ; á°taá ©†dkñ
         jz        DispAMn9
         jmp       DispAMn5                 ; bude dal®° ©†dek

; ------ n†vrat registrñ

DispAMn9:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispAMnu ENDP

; *****************************************************************************
;
;                                 Kalend†©
;
; *****************************************************************************
;˛
Kalendar PROC      FAR

         add       sp,4                     ; zru®en° n†vratovÇ adresy
         call      far ptr ClosMnuA         ; uzav©en° v®ech oken
         call      far ptr Kalend           ; obsluha kalend†©e
         jmp       far ptr Main0

Kalendar ENDP

; -----------------------------------------------------------------------------
;        kalend†©
; -----------------------------------------------------------------------------

Kalend   PROC      FAR

; ------ test, zda je kalend†© jië aktivn° (a zda je povolen)

         test      byte ptr ds:[ParInt24],bit3 ; je z†kaz bàhem INT 24h ?
         jnz       Kalend01                 ; je z†kaz bàhem INT 24h
         test      byte ptr ds:[ParZvl],bit2 ; je kalend†© jië aktivn° ?
         jz        Kalend02                 ; je®tà nen° aktivn°
Kalend01:ret

Kalend02:or        byte ptr ds:[ParZvl],bit2 ; p©°znak aktivity kalend†©e

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es

; ------ £schova kurzoru

         call      far ptr GetKurz          ; poskytnut° kurzoru
         mov       ds:[DiarOKur],dx         ; £schova kurzoru

; ------ zji®tàn° aktu†ln°ho data

         mov       ah,2ah
         int       21h                      ; poskytnut° systÇmovÇho data
         mov       ds:[ADen],dl             ; aktu†ln° den
         mov       ds:[AMesic],dh           ; aktu†ln° màs°c
         mov       ds:[ARok],cx             ; aktu†ln° rok
         mov       bx,dx                    ; BX <- den a màs°c
         call      far ptr KonvDatN         ; konverze na absolutn° den DX:AX
         mov       word ptr ds:[ADenAbs],ax ; den LOW
         mov       word ptr ds:[ADenAbs+2],dx ; den HIGH
         mov       word ptr ds:[DiarADen],ax ; den LOW
         mov       word ptr ds:[DiarADen+2],dx
         mov       word ptr ds:[DiarOffs+2],-1 ; nen° offset

; ------ inicializace souboru adres†©e

Kalend03:mov       word ptr ds:[SegmDDia],0 ; segment dat neplatnò
         mov       word ptr ds:[SegmIDia],0 ; segment indexñ neplatnò

         call      OpenDiar                 ; otev©en° souboru kalend†©e
         jnc       Kalend04                 ; operace OK
         jmp       KalKonc9                 ; konec

; ------ otev©en° okna kalend†©e

Kalend04:mov       si,offset ZDMnu          ; okno kalend†©e
         call      far ptr OpenMnu          ; otev©en° okna kalend†©e

; ------ novÇ zobrazen° okna kalend†©e

Kalend0: mov       si,offset ZDMnu
         call      far ptr DispMnu          ; zobrazen° okna

; ------ vstup znaku z kl†vesnice

Kalend1: mov       si,offset ZDMnu
         call      far ptr KurzOff          ; vypnut° kurzoru
         call      far ptr InpChar          ; vstup znaku z kl†vesnice

         push      bx
         mov       ax,word ptr ds:[DiarADen]
         mov       dx,word ptr ds:[DiarADen+2]
         call      far ptr KonvNDat         ; konverze na datum
         mov       dx,bx                    ; màs°c a den
         pop       bx

         call      far ptr JumpBX           ; skok na funkci

         dw        4b00h,KalLeft            ; vlevo - o den mÇnà
         dw        4d00h,KalRght            ; vpravo - o den v°ce
         dw        4800h,KalUp              ; nahoru - o tòden
         dw        5000h,KalDwn             ; dolñ - o tòden
         dw        4700h,KalHome            ; HOME - zaá†tek màs°ce
         dw        4f00h,KalXEnd            ; END - konec màs°ce
         dw        4900h,KalPgUp            ; Page Up - o màs°c mÇnà
         dw        5100h,KalPgDn            ; Page Down - o màs°c v°ce
         dw        8400h,KalCPgUp           ; ^Page Up - o rok mÇnà
         dw        7600h,KalCPgDn           ; ^Page Down - o rok v°ce
         dw        7700h,KalCHome           ; ^Home - zaá†tek roku
         dw        7500h,KalCEnd            ; ^End - konec roku
         dw        3e00h,KalF4Edi           ; F4 - editace pozn†mek
         dw        3f00h,KalF5Off           ; F5 - offset
         dw        4100h,KalF7100           ; F7 - o 100 let zpàt
         dw        4200h,KalF8100           ; F8 - o 100 let vp©ed

         dw        MousXKod+MousXRP,KalKonec ; stisk pravÇho tlaá°tka my®i
         dw        8200h,KalKonec           ; Alt-- konec
         dw        11bh,KalKonec            ; Esc - konec
         dw        0,Kalend1                ; neobslouëen† kl†vesa

; ------ aktualizace pro novò den

KalNovy: jmp       short Kalend0

; ------ vlevo - o den mÇnà

KalLeft: mov       cx,1
KalLeft1:sub       word ptr ds:[DiarADen],cx; sn°ëen° data
         sbb       word ptr ds:[DiarADen+2],0 ; p©enod HIGH
         jnc       KalLeft4                 ; bylo to OK
KalLeft2:mov       word ptr ds:[DiarADen],0 ; omezen° na den 0
         mov       word ptr ds:[DiarADen+2],0
KalLeft4:jmp       short KalNovy            ; aktualizace pro novò den

; ------ vpravo - o den v°ce

KalRght: mov       cx,1
KalRght1:add       word ptr ds:[DiarADen],cx ; zvò®en° data
         adc       word ptr ds:[DiarADen+2],0 ; p©enos HIGH
KalRght4:jmp       short KalNovy            ; aktualizace pro novò den

; ------ nahoru - o tòden mÇnà

KalUp:   mov       cx,7                     ; poáet dnñ k posunu
         jmp       short KalLeft1

; ------ dolñ - o tòden v°ce

KalDwn:  mov       cx,7                     ; poáet dnñ k posunu
         jmp       short KalRght1

; ------ HOME - prvn° den v màs°ci

KalHome: xor       cx,cx
         mov       cl,dl                    ; den v màs°ci
         dec       cx                       ; poáet dnñ - 1
         jmp       short KalLeft1

; ------ END - posledn° den v màs°ci

KalXEnd: xor       cx,cx
         mov       cl,ah                    ; poáet dnñ v màs°ci
         sub       cl,dl                    ; zbytek do konce màs°ce
KalEnd2: jmp       short KalRght1

; ------ PageUp - o màs°c mÇnà

KalPgUp: mov       bx,dx                    ; màs°c a den
         dec       bh                       ; posun màs°ce
         jnz       KalPgUp1                 ; nebyl to leden
         mov       bh,12                    ; n†hrada prosincem
         sub       cx,1                     ; sn°ëen° roku
         jc        KalHome                  ; je rok 0
KalPgUp1:call      MesicGet                 ; poáet dnñ v p©ede®lÇm màs°ci
         xor       cx,cx
         mov       cl,al                    ; to bude p©°®t° posun
         cmp       cl,dl                    ; je men®° poáet dnñ ?
         jae       KalLeft1                 ; je to OK
         mov       cl,dl                    ; jinak zvò®en°
KalPgUp2:jmp       short KalLeft1

; ------ PageDown - o màs°c v°ce

KalPgDn: cmp       dh,12                    ; je posledn° màs°c ?
         jb        KalPgDn2                 ; nen° posledn° màs°c
         cmp       cx,4000                  ; posledn° rok ?
         jae       KalCPgD0                 ; je jië maxim†ln° rok
         inc       cx                       ; zvò®en° roku
         mov       dh,0                     ; zmàna á°sla màs°ce
KalPgDn2:mov       bx,dx                    ; màs°c a den
         inc       bh                       ; posun màs°ce
         mov       dh,ah                    ; poáet dnñ
         call      MesicGet                 ; poáet dnñ v dal®°m màs°ci
         xor       cx,cx
         mov       cl,dh                    ; posun
         cmp       dl,al
         jbe       KalEnd2                  ; posun OK
         sub       dl,al
         sub       cl,dl                    ; sn°ëen° posunu
         jmp       short KalEnd2

; ------ ^PageUp - o rok mÇnà

KalCPgUp:jcxz      KalCHome                 ; je jië rok 0
         cmp       dh,2                     ; je leden nebo £nor ?
         ja        KalCPgU1
         dec       cx
KalCPgU1:call      RokGet
KalCPgU2:mov       cx,ax
         cmp       dh,2
         jne       KalPgUp2
         cmp       dl,29
         jne       KalPgUp2
         inc       cx                       ; oprava pro 29.£nora
KalCPgU4:jmp       short KalPgUp2

; ------ ^PageDown - o rok v°ce

KalCPgDn:cmp       cx,4000                  ; je jië maxim†ln° rok ?
KalCPgD0:jae       KalCEnd                  ; konec roku
         cmp       dh,2
         jbe       KalCPgD1
         inc       cx
KalCPgD1:call      RokGet
KalCPgD2:mov       cx,ax
         cmp       dh,2
         jne       KalEnd2
         cmp       dl,29
         jne       KalEnd2
         dec       cx                       ; oprava pro 29.£nora
KalCPgD4:jmp       short KalEnd2

; ------ ^Home - zaá†tek roku

KalCHome:mov       bh,dh
         xor       dh,dh
         dec       dx                       ; DX = posun v màs°ci
KalCHom1:dec       bh
         jz        KalCHom2
         call      MesicGet
         add       dx,ax
         jmp       short KalCHom1

KalCHom2:mov       cx,dx
         jmp       short KalCPgU4

; ------ ^End - konec roku

KalCEnd: sub       ah,dl                    ; poáet zbylòch dnñ
         mov       bh,dh                    ; màs°c
         mov       dl,ah
         xor       dh,dh
KalCEnd1:inc       bh
         cmp       bh,12
         ja        KalCEnd2
         call      MesicGet
         add       dx,ax
         jmp       short KalCEnd1

KalCEnd2:mov       cx,dx
         jmp       short KalCPgD4

; ------ F7 - o 100 let mÇnà

KalF7100:sub       cx,100                   ; odeáten° 100 let
         jnc       KalF8102
         xor       cx,cx
         mov       dx,101h                  ; korekce na 1.1.
         jmp       short KalF8102

; ------ F8 - o 100 let v°ce

KalF8100:add       cx,100
         cmp       cx,4000
         jbe       KalF8102
         mov       cx,4000
         mov       dx,12*HI + 31            ; korekce na 31.12.
KalF8102:mov       bx,dx                    ; BX <- màs°c a den
         call      far ptr KonvDatN         ; konverze na á°slo dne
         mov       word ptr ds:[DiarADen],ax ; novÇ á°slo dne
         mov       word ptr ds:[DiarADen+2],dx
KalF8106:jmp       Kalend0

; ------ F5 - offset

KalF5Off:mov       ax,word ptr ds:[DiarADen] ; aktu†ln° den LOW
         mov       word ptr ds:[DiarOffs],ax ; poá†tek offsetu LOW
         mov       ax,word ptr ds:[DiarADen+2]
         mov       word ptr ds:[DiarOffs+2],ax
         jmp       short KalF8106

; ------ F4 - editace koment†©ñ

KalF4Edi:test      byte ptr ds:[ParZvl],bit7 ; je editace z†pisn°kem ?
         jnz       KalF8106                 ; je editace z†pisn°kem

         call      far ptr ClosMnu          ; uzav©en° okna
         mov       ax,ds:[SegmDDia]         ; segment dat di†©e
         call      far ptr DelSeg           ; zru®en° segmentu
         mov       ax,ds:[SegmIDia]         ; segment indexñ di†©e
         call      far ptr DelSeg           ; zru®en° segmentu

         sub       sp,FileMax+30

         push      ss
         pop       es                       ; ES <- segment bufferu v z†sobn°ku
         mov       di,sp                    ; DI <- buffer v z†sobn°ku
         mov       si,offset DosmDiar       ; jmÇno souboru DOSMAN.DIA
         call      far ptr TempFile         ; sestaven° jmÇna souboru

         sub       di,sp                    ; DI <- dÇlka jmÇna souboru
         mov       cx,di                    ; CX <- dÇlka jmÇna souboru
         mov       di,sp                    ; offset jmÇna souboru
         mov       byte ptr ds:[SRSMnPl4],0 ; nen° jmÇno souboru
         mov       byte ptr ds:[LinNum],0   ; nen° koment†© k souboru
         mov       byte ptr ds:[ZapsTypI],5 ; p©°znak souboru DIAR
         call      far ptr EditNOT          ; obsluha editoru NOT

         add       sp,FileMax+30            ; n†vrat ukazatele z†sobn°ku
         jmp       Kalend03

; ------ uzav©en° okna kalend†©e

KalKonec:call      far ptr ClosMnu
KalKonc9:mov       dx,ds:[DiarOKur]         ; pñvodn° kurzor
         call      far ptr SetKurz          ; n†vrat kurzoru
         call      far ptr NulBreak         ; nulov†n° p©°znaku p©eru®en°

         mov       ax,ds:[SegmDDia]         ; segment dat di†©e
         call      far ptr DelSeg           ; zru®en° segmentu
         mov       ds:[SegmDDia],ax         ; p©°znak neplatnosti segmentu

         mov       ax,ds:[SegmIDia]         ; segment indexñ di†©e
         call      far ptr DelSeg           ; zru®en° segmentu
         mov       ds:[SegmIDia],ax         ; p©°znak neplatnosti segmentu

         and       byte ptr ds:[ParZvl],not bit2 ; konec aktivity kalend†©e

; ------ n†vrat registrñ

         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Kalend   ENDP

; -----------------------------------------------------------------------------
;        naáten° souboru di†©e (CY=chyba, p©eru®it operaci), niá° registry !
; -----------------------------------------------------------------------------
;˛
OpenDiar PROC      NEAR

; ------ £schova registrñ

         push      bp
         mov       bp,sp
         sub       sp,FileMax+20            ; buffer pro jmÇno souboru

; ------ vytvo©en° segmentu k naáten° souboru

         mov       bx,2000h                 ; asi tak minim†ln° velikost
         call      far ptr CreatDat         ; vytvo©en° segmentu
         jc        OpenDia2                 ; nedostatek pamàti
         mov       ds:[SegmDDia],ax         ; segment dat di†©e

; ------ sestaven° jmÇna souboru di†©e (BX=velikost bufferu)

         push      ss
         pop       es                       ; ES <- segment bufferu v z†sobn°ku
         mov       si,offset DosmDiar       ; soubor di†©e
         mov       di,sp                    ; buffer v z†sobn°ku
         call      far ptr TempFile         ; sestaven° jmÇna souboru

; ------ otev©en° souboru di†©e (BX=velikost bufferu)

         mov       si,sp                    ; jmÇno souboru
         xor       cx,cx                    ; p©°znak, ëe nejsou ë†dn† data
         call      far ptr OpenR            ; otev©en° souboru pro áten°
         jc        OpenDia1                 ; soubor nenalezen

; ------ naáten° souboru di†©e do bufferu (AX=identifik†tor, BX=velikost)

         push      ax
         mov       ax,ds:[SegmDDia]         ; segment dat di†©e
         call      far ptr GetDat           ; adresa bufferu -> ES
         pop       ax

         mov       di,2                     ; adresa poá†tku bufferu
         mov       cx,bx                    ; CX <- velikost bufferu
         dec       cx
         dec       cx                       ; bez z†hlav°
         call      far ptr ReadFile         ; naáten° obsahu souboru
         call      far ptr ClosFile         ; uzav©en° souboru

; ------ kontrola p©eteáen° pamàti (CX=naáteno bajtñ, BX=velikost bufferu)

OpenDia1:inc       cx
         inc       cx                       ; váetnà z†hlav°
         cmp       cx,bx                    ; je p©eteáen° dat v bufferu ?
         jb        OpenDia3                 ; data jsou OK
         cmp       bx,0ff00h                ; je skuteánà m†lo pamàti ?
         jae       OpenDia3                 ; pamàti je dost

; ------ chyba pamàti

OpenDia2:call      far ptr MemErr           ; chyba p©eteáen° bufferu
         jmp       OpenDia9                 ; zde je CY=chyba

; ------ minimalizace velikosti bufferu (CX=konec dat v bufferu)

OpenDia3:mov       ax,ds:[SegmDDia]         ; segment dat di†©e
         mov       bx,cx                    ; BX <- velikost dat v bufferu
         call      far ptr ModiSegS         ; nastaven° velikosti bufferu

; ------ nastaven° poátu bajtñ v bufferu

         call      far ptr GetDat           ; adresa bufferu -> ES
         mov       es:[0],bx                ; konec dat v bufferu

; ------ test, zda je identifik†tor n†rodn°ho k¢du

         mov       di,2                     ; zaá†tek textu v bufferu
         mov       si,offset IdntISwT       ; p©ep°naá
         call      far ptr GetTISwc         ; naáten° p©ep°naáe
         jc        OpenDia4                 ; nen° p©ep°naá

; ------ naáten° n†rodn°ho k¢du (DI=zaá†tek textu)

         mov       si,offset KodISwcT       ; n†rodn° k¢d
         call      far ptr GetTISwc         ; naáten° p©ep°naáe
         jc        OpenDia4                 ; nen° p©ep°naá
         cmp       al,ds:[CodePagK]         ; je pot©eba zmànit k¢d ?
         je        OpenDia4                 ; nen° pot©eba zmànit k¢d
         cmp       byte ptr ds:[CodePagK],0 ; je k¢d uráen ?
         je        OpenDia4                 ; k¢d nen° uráen

; ------ konverze n†rodn°ho k¢du (DI=zaá†tek textu)

         xchg      ax,cx                    ; CL <- aktu†ln° k¢d
         mov       dl,bit1                  ; p©°prava
         shl       dl,cl                    ; DL = aktu†ln° k¢d
         mov       cl,ds:[CodePagK]         ; poëadovan† k¢dov† str†nka
         mov       dh,bit1                  ; p©°prava
         shl       dh,cl                    ; DH = poëadovanò k¢d
         mov       si,di                    ; SI <- zaá†tek textu
         mov       cx,es:[0]                ; poáet bajtñ v bufferu
         sub       cx,si                    ; CX <- dÇlka textu
         call      far ptr KonvFnt          ; konverze fontñ

; ------ vytvo©en° segmentu indexñ

OpenDia4:mov       bx,400h                  ; asi tak minim†ln° velikost
         call      far ptr CreatDat         ; vytvo©en° segmentu
OpenDia5:jc        OpenDia2                 ; chyba - nedostatek pamàti
         mov       ds:[SegmIDia],ax         ; segment indexñ di†©e

; ------ inicializace segmentu indexñ (BX=velikost bufferu)

         call      far ptr GetDat           ; adresa segmentu -> ES
         sub       bx,DiarPSum              ; rezerva pro 1 poloëku
         mov       word ptr es:[DiarNums],0 ; nen° ë†dn† poloëka

; ------ p©°prava k dek¢dov†n° (BX=maxim†ln° konec indexñ)

         mov       si,2                     ; zaá†tek dat di†©e
         mov       di,DiarIndx              ; tabulka indexñ
         mov       ax,ds:[SegmDDia]         ; segment dat di†©e
         call      far ptr GetSgAdr         ; adresa segmentu dat di†©e -> DX

; ------ test, zda mñëe bòt dal®° poloëka (BX=max.index, DX:SI=data, DI=indexy)

OpenDia6:cmp       bx,di                    ; mñëe bòt dal®° poloëka ?
         jb        OpenDia5                 ; chyba, p©eteáen° velikosti bufferu

; ------ test, zda je platnò ©†dek

OpenDi62:call      ODiarChr                 ; naáten° prvn°ho znaku
         jc        OpenDi64                 ; konec dat
         cmp       al,CR
         je        OpenDi62                 ; znak CR se vypust°
         cmp       al,LF
         je        OpenDi62                 ; pr†zdnò ©†dek se vypust°
         cmp       al,EOF
         je        OpenDi62                 ; konec souboru se vypust°
         dec       si                       ; n†vrat platnÇho znaku
         cmp       al,";"                   ; koment†©
         je        OpenDi63                 ; ©†dek koment†©e se vypust°
         cmp       al,"["                   ; parametry
         je        OpenDi63                 ; ©†dek parametrñ se vypust°
         cmp       al," "                   ; je konec ©†dku ?
         ja        OpenDi65                 ; je platnò znak

; ------ ©†dek se p©eskoá° - nalezen° konce ©†dku

OpenDi63:call      ODiarChr                 ; naáten° dal®°ho znaku
         jc        OpenDi64                 ; konec dat
         cmp       al,LF                    ; konec ©†dku ?
         jne       OpenDi63                 ; nen° je®tà konec ©†dku
         jmp       short OpenDi62           ; dal®° ©†dek

OpenDi64:jmp       OpenDia8                 ; konec dat

; ------ naáten° dne

OpenDi65:call      ODiarNum                 ; naáten° dne
         cmp       ax,31                    ; maxim†ln° á°slo dne
         ja        OpenDia7                 ; nen° platnò den
         mov       es:[di+DiarPPar],al      ; nastaven° á°sla dne

; ------ naáten° màs°ce

         call      ODiarNum                 ; naáten° màs°ce
         cmp       ax,12                    ; maxim†ln° á°slo màs°ce
         ja        OpenDia7                 ; nen° platnò màs°c
         mov       cl,12                    ; poáet rotac°
         shl       ax,cl                    ; rotace màs°ce na pozici
         mov       es:[di+DiarPRok],ax      ; nastaven° á°sla màs°ce

; ------ naáten° roku

         call      ODiarNum                 ; naáten° roku
         cmp       ax,4095                  ; maxim†ln° á°slo roku
         ja        OpenDia7                 ; nen° platnò rok
         or        es:[di+DiarPRok],ax      ; nastaven° á°sla roku

; ------ test, zda jsou dny v tòdnu

         mov       byte ptr es:[di+DiarPDny],0 ; dny v tòdnu
         call      ODiarChr                 ; naáten° znaku
         jc        OpenDi68                 ; nen° dal®° znak
         cmp       al,"@"                   ; jsou dny v tòdnu ?
         jne       OpenDi67                 ; nejsou dny v tòdnu

; ------ naáten° dnñ v tòdnu

OpenDi66:call      ODiarNm0                 ; naáten° dal®° á°slice
         jc        OpenDi68                 ; nen° dal®° á°slice
         dec       ax                       ; korekce
         cmp       al,6                     ; kontrola á°slice
         ja        OpenDi66                 ; nen° platn† á°slice
         xchg      ax,cx                    ; CL <- á°slo dne
         mov       al,bit0                  ; maska
         shl       al,cl                    ; rotace masky na pozici
         or        es:[di+DiarPDny],al      ; p©°znak dne
         jmp       short OpenDi66           ; dal®° den

; ------ korekce dnñ v tòdnu, nebylo-li nic zad†no

OpenDi67:dec       si                       ; n†vrat znaku
OpenDi68:test      byte ptr es:[di+DiarPDny],7fh ; bylo nàco zad†no ?
         jnz       OpenDi69                 ; bylo nàco zad†no OK
         or        byte ptr es:[di+DiarPDny],7fh ; v®echny dny v tòdnu

; ------ naáten° parametrñ - volnÇ dny a zvòraznàn°

OpenDi69:call      ODiarChr                 ; naáten° znaku
         jc        OpenD732                 ; nen° dal®° znak
         cmp       al,"+"                   ; je sv†tek ?
         jne       OpenDi71                 ; nen° sv†tek
         or        byte ptr es:[di+DiarPPar],bit6 ; je sv†tek
         and       byte ptr es:[di+DiarPPar],not bit5 ; nen° pracovn° den
         jmp       short OpenDi69           ; dal®° znak

; ------ nalezen° dal®°ho ©†dku

OpenDia7:call      ODiarChr                 ; naáten° dal®°ho znaku
         jc        OpenDi64                 ; konec dat
         cmp       al,LF                    ; konec ©†dku ?
         jne       OpenDia7                 ; nen° je®tà konec ©†dku
         jmp       OpenDia6                 ; dal®° poloëka

OpenDi71:cmp       al,"-"                   ; je pracovn° den ?
         jne       OpenDi72                 ; nen° pracovn° den
         or        byte ptr es:[di+DiarPPar],bit5 ; je pracovn° den
         and       byte ptr es:[di+DiarPPar],not bit6 ; nen° sv†tek
         jmp       short OpenDi69           ; dal®° znak

OpenDi72:cmp       al,"*"                   ; je zvòraznànò ©†dek ?
         jne       OpenDi73
         or        byte ptr es:[di+DiarPDny],bit7 ; p©°znak zvòraznàn°
         jmp       short OpenDi69           ; dal®° znak

OpenDi73:cmp       al,"!"                   ; je zvòraznànò den ?
         jne       OpenD731
         or        byte ptr es:[di+DiarPPar],bit7 ; zvòraznànò den
         jmp       short OpenDi69           ; dal®° znak

OpenD731:dec       si                       ; n†vrat znaku

; ------ nalezen° zaá†tku textu

OpenD732:call      ODiarChr                 ; naáten° dal®°ho znaku
         jc        OpenD734                 ; nen° dal®° znak
         cmp       al," "
         je        OpenD732                 ; mezera se vypust°
         cmp       al,TAB
         je        OpenD732                 ; tabul†tor se vypust°
         dec       si                       ; n†vrat platnÇho znaku
OpenD734:mov       es:[di+DiarPOfs],si      ; adresa textu

; ------ nalezen° konce ©†dku

         xor       cx,cx                    ; á°taá dÇlky ©†dku
OpenDi74:call      ODiarChr                 ; naáten° dal®°ho znaku
         jc        OpenDi75                 ; nen° dal®° znak
         inc       cx                       ; zvò®en° á°taáe dÇlky
         cmp       al,LF                    ; je konec ©†dku ?
         jne       OpenDi74                 ; nalezen° konce ©†dku
         dec       cx                       ; n†vrat á°taáe dÇlky
         dec       si                       ; n†vrat ukazatele textu na LF

; ------ nalezen° konce textu

OpenDi75:push      ds
         mov       ds,dx                    ; DS <- segment dat
         inc       si
         inc       cx                       ; p©ednastaven°
OpenDi76:dec       si                       ; vypu®tàn° znaku
         dec       cx                       ; zkr†cen° á°taáe dÇlky
         jcxz      OpenDi77                 ; je jië zaá†tek textu
         cmp       byte ptr ds:[si-1]," "   ; je mezera ?
         je        OpenDi76                 ; mezera se vypust°
         cmp       byte ptr ds:[si-1],CR    ; je CR ?
         je        OpenDi76                 ; CR se vypust°
         cmp       byte ptr ds:[si-1],EOF   ; je znak konce souboru ?
         je        OpenDi76                 ; konec souboru se vypust°
         cmp       byte ptr ds:[si-1],TAB   ; je TAB ?
         je        OpenDi76                 ; TAB se vypust°
OpenDi77:cmp       cx,255                   ; je p©eteáen° dÇlky ?
         jbe       OpenDi78                 ; dÇlka je OK
         mov       cl,255                   ; omezen° dÇlky textu
OpenDi78:pop       ds
         mov       es:[di+DiarPDel],cl      ; dÇlka textu ©†dku
         inc       word ptr es:[DiarNums]   ; zvò®en° á°taáe poloëek
         add       di,DiarPSum              ; adresa dal®° poloëky
         jmp       OpenDia7                 ; dal®° ©†dek

; ------ zmen®en° bloku na adresu konec dat DI

OpenDia8:mov       es:[0],di                ; konec dat v bloku
         mov       bx,di                    ; BX <- velikost segmentu
         mov       ax,ds:[SegmIDia]         ; segment indexñ
         call      far ptr ModiSegS         ; zmen®en° bloku
;         clc                                ; p©°znak operace OK

; ------ n†vrat registrñ

OpenDia9:mov       sp,bp
         pop       bp
         ret

OpenDiar ENDP

; ------ naáten° á°sla z di†©e DX:SI -> AX

ODiarNum PROC      NEAR

         push      bx
         xor       bx,bx                    ; st©adaá

ODiarNm2:call      ODiarNm0                 ; naáten° jednÇ á°slice
         jc        ODiarNm8                 ; nen° dal®° á°slice

         push      dx
         mov       ah,0                     ; AX = á°slice
         xchg      ax,bx                    ; AX <- st©adaá, BX <- á°slice
         mov       dx,10                    ; n†sobek pro posun o ©†d
         mul       dx                       ; vyn†soben° st©adaáe
         add       bx,ax                    ; p©id†n° á°slice ke st©adaái
         adc       dx,dx                    ; je p©eteáen° ?
         pop       dx
         jz        ODiarNm2                 ; nen° p©eteáen°
         mov       bx,-1                    ; omezen° p©i p©eteáen°
         jmp       short ODiarNm2           ; dal®° á°slice

ODiarNm8:call      ODiarChr                 ; naáten° znaku
         jc        ODiarNm9                 ; nen° dal®° znak
         cmp       al,"."
         je        ODiarNm9                 ; je oddàlovaá OK
         dec       si                       ; n†vrat znaku

ODiarNm9:xchg      ax,bx                    ; AX <- naátenÇ á°slo
         pop       bx
         ret

ODiarNum ENDP

; ------ naáten° á°slice z di†©e DX:SI -> AL, CY=nen°

ODiarNm0 PROC      NEAR

         call      ODiarChr                 ; naáten° znaku z di†©e
         jc        ODiarN04                 ; nen° dal®° znak
         sub       al,"0"                   ; je á°slice ?
         jb        ODiarN02                 ; nen° á°slice
         cmp       al,10                    ; je platn† á°slice ?
         cmc                                ; CY=nen°
         jnc       ODiarN04                 ; je platn† á°slice OK
ODiarN02:dec       si                       ; n†vrat znaku
ODiarN04:ret

ODiarNm0 ENDP

; ------ naáten° znaku z dat di†©e DX:SI -> AL, CY=nen° (AL=EOF)

ODiarChr PROC      NEAR

         cld
         push      ds
         mov       ds,dx                    ; DS <- segment dat di†©e
         cmp       si,ds:[0]                ; je dal®° znak ?
         cmc
         jc        ODiarCh4                 ; nen° dal®° znak
         lodsb                              ; naáten° znaku
ODiarCh4:pop       ds
         ret

ODiarChr ENDP

; *****************************************************************************
;                              InitRMnu
;                     inicializace menu kalend†©e
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa definice menu
; *****************************************************************************

InitRMnu PROC      FAR

         call      far ptr CentMenu
         ret

InitRMnu ENDP

; *****************************************************************************
;                                DispRMnu
;                          zobrazen° kalend†©e
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa definice kalend†©e
;        DS=datovò segment
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) adresa definice kalend†©e
;                   SS:[BP-4]
;                   SS:[BP-5] (1) poá†teán° ©†dek okna kalend†©e
;                   SS:[BP-6] (1) poá†teán° pozice okna kalend†©e
;                   SS:[BP-7] (1) vò®ka okna kalend†©e
;                   SS:[BP-8] (1) ®°©ka okna kalend†©e
;                   SS:[BP-10] (2) hladina k zobrazen°
;                   SS:[BP-11] (1) vysv°cen† barva okna
;                   SS:[BP-12] (1) bàën† barva okna
;                   SS:[BP-13] (1) vysv°cen† barva kurzoru
;                   SS:[BP-14] (1) bàën† barva kurzoru
;                   SS:[BP-15] (1) barva r†mu - prav† hrana
;                   SS:[BP-16] (1) barva r†mu - lev† hrana
;                   SS:[BP-18] (2) aktu†ln° nastavenò rok
;                   SS:[BP-19] (1) aktu†ln° nastavenò màs°c
;                   SS:[BP-20] (1) aktu†ln° nastavenò den
;                   SS:[BP-21] (1) poáet dnñ màs°ce
;                   SS:[BP-22] (1) den v tòdnu (0=pondàl°, ... 6=nedàle)
;                   SS:[BP-23] (1) ... ukazatel dne v màs°ci
;                   SS:[BP-24] (1) poáet pracovn°ch dnñ
;                   SS:[BP-25] (1) den v tòdnu 1.ledna
;                   SS:[BP-26] (1)
;                   SS:[BP-28] (2) ukazatel v tabulce indexñ pozn†mek
;
;                   SS:[BP-36] (1) skuteánò den v màs°ci pro zobrazen° <x>
; *****************************************************************************
;˛
RMnuLSir EQU       37                       ; ®°©ka levÇ poloviny okna
RMnuRSir EQU       38                       ; ®°©ka pravÇ poloviny okna
                                            ; (+pravò okraj; mus° bòt > !!!)

DispRMnu PROC      FAR

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
         sub       sp,36 + 2*80

; ------ p©°prava lok†ln°ch promànnòch

         mov       ss:[bp-2],si             ; adresa definice kalend†©e
         mov       al,ds:[si+MnuPoz]        ; poá†teán° pozice
         mov       ss:[bp-6],al             ; poá†teán° pozice
         mov       ah,0
         mov       al,ds:[si+MnuLev]        ; hladina k zobrazen°
         mov       ss:[bp-10],ax            ; hladina k zobrazen°
         mov       ax,word ptr ds:[ColMnu1] ; bàën† a vysv°cen† barva okna
         mov       ss:[bp-12],ax            ; bàën† a vysv°cen† barva okna
         mov       ax,word ptr ds:[ColMnu3] ; bàën† a vysv°cen† barva kurzoru
         mov       ss:[bp-14],ax            ; bàën† a vysv°cen† barva kurzoru
         mov       ax,word ptr ds:[ColMnu1L] ; barva r†mu menu
         mov       ss:[bp-16],ax            ; barva r†mu menu
         mov       byte ptr ss:[bp-8],RMnuLSir ; ®°©ka levÇ poloviny okna

; ------ aktu†ln° datum

         mov       ax,word ptr ds:[DiarADen]
         mov       dx,word ptr ds:[DiarADen+2]
DispKl01:call      far ptr KonvNDat         ; konverze na datum
         mov       ss:[bp-18],cx            ; rok
         mov       ss:[bp-20],bx            ; den a màs°c
         mov       ss:[bp-22],ax            ; den v tòdnu a poáet dnñ v màs°ci

; ------ korekce poátu dnñ v ©°jnu 1582

         cmp       cx,1582                  ; je rok 1582 ?
         jne       DispKl02                 ; nen° rok 1582
         cmp       bh,10                    ; je ©°jen 1582 ?
         jne       DispKl02                 ; nen° ©°jen 1582
         mov       byte ptr ss:[bp-21],31   ; oprava poátu dnñ na 31
         cmp       bl,5                     ; je den p©ed 5.10.1582 ?
         jb        DispKl02                 ; je den p©ed 5.10.1582
         add       al,3                     ; korekce dne v tòdnu

; ------ skuteánò den pro zobrazen° ukazatele

DispKl02:mov       ah,80h                   ; den je neplatnò
         cmp       cx,ds:[ARok]             ; je skuteánò rok ?
         jne       DispKal0                 ; nen° skuteánò rok
         cmp       bh,ds:[AMesic]           ; je skuteánò màs°c ?
         jne       DispKal0                 ; nen° skuteánò màs°c
         mov       ah,ds:[ADen]             ; skuteánò den v màs°ci
DispKal0:mov       ss:[bp-36],ah            ; skuteánò den v màs°ci

; ------ stanoven° prvn°ho dne v tòdnu (AL=den v tòdnu)

         mov       ah,0                     ; AH <- 0
         add       al,7*5+1                 ; posun ke kladnÇmu á°slu
         sub       al,bl                    ; odeáten° dne
         mov       bl,7                     ; poáet dnñ v tòdnu
         div       bl                       ; vòpoáet 1.dne
         neg       ah                       ; á°taá dnñ do 1. dne v màs°ci
         inc       ah
         mov       ss:[bp-23],ah            ; ukazatel dne v màs°ci (platnò>=1)

; ------ p©°prava ukazatelñ pro jednu polovinu okna

         mov       si,ss:[bp-2]             ; adresa definice okna
         mov       byte ptr ss:[bp-7],6     ; poáet ©†dkñ kalend†©e
         mov       al,ds:[si+MnuRad]        ; poá†teán° ©†dek
         inc       al                       ; korekce poá†teán°ho ©†dku
         mov       ss:[bp-5],al             ; poá†teán° ©†dek
         mov       byte ptr ss:[bp-24],0    ; á°taá pracovn°ch dnñ

; ------ dek¢dov†n° a zobrazen° aktu†ln°ho data

         call      DispKalC                 ; vymaz†n° ©†dku
         mov       cl,ss:[bp-19]            ; màs°c
         mov       si,offset Mesice         ; tabulka màs°cñ
         xor       ax,ax
DispKal2:add       si,ax                    ; adresa dal®°ho màs°ce
         lodsb                              ; dÇlka textu
         loop      DispKal2                 ; dal®° màs°c
         xchg      ax,cx                    ; CX <- dÇlka textu

         cld
         mov       di,sp
         add       di,6*2
         mov       ah,ss:[bp-11]            ; vysv°cen† barva
DispKal3:lodsb
         stosw
         loop      DispKal3

         mov       bh,ah                    ; barva
         mov       di,sp
         add       di,2*32
         mov       ax,ss:[bp-18]            ; rok
         mov       bl,0                     ; oddàlovaá ©†dñ nen°
         xor       dx,dx
         call      far ptr DekNumD          ; dek¢dov†n° á°sla roku

         call      DispRMnD                 ; zobrazen° ©†dku

; ------ zobrazen° nadpisu - dny v tòdnu

         call      DispKalC                 ; vymaz†n° ©†dku
         mov       si,offset DnyNadp        ; text nadpisu
         mov       cl,offset(DnyNadp0-DnyNadp)-1 ; dÇlka textu
         mov       di,sp                    ; buffer v z†sobn°ku
         add       di,2*6                   ; poá†tek k dek¢dov†n° textu
         mov       dh,ss:[bp-12]            ; bàën† barva
         mov       ah,ss:[bp-11]            ; zvòraznàn† barva
DispKl42:xchg      ah,dh
DispKl44:lodsb
         cmp       al,0
         je        DispKl42
         stosw
         loop      DispKl44
         call      DispRMnD                 ; zobrazen° ©†dku

; ------ p©°prava k dek¢dov†n° dnñ màs°ce

DispKal5:call      DispKalC                 ; vymaz†n° ©†dku

         mov       cl,7                     ; poáet dnñ
         mov       di,sp                    ; buffer k dek¢dov†n° dnñ
         add       di,2*6                   ; zaá†tek k dek¢dov†n°

; ------ test, zda je den platnò

DispKl51:mov       al,ss:[bp-23]            ; ukazatel dne v màs°ci
         cmp       al,1                     ; je den platnò ?
         jl        DispKl52                 ; den nen° platnò
         cmp       al,ss:[bp-21]            ; je za koncem màs°ce ?
         jle       DispKl53                 ; nen° za koncem màs°ce
DispKl52:jmp       DispKl66                 ; dal®° den

; ------ nalezen° pracovn°ho dne
;˛
DispKl53:push      es
         push      cx
         mov       al,ss:[bp-20]            ; nastavenò den
         push      ax
         mov       al,ss:[bp-23]            ; zpracov†vanò den
         mov       ss:[bp-20],al            ; fiktivn° den
         mov       al,7
         sub       al,cl                    ; den v tòdnu
         mov       ss:[bp-22],al            ; den v tòdnu

         mov       ax,ds:[SegmIDia]         ; segment indexñ
         call      far ptr GetDat           ; adresa segmentu -> ES

         xor       dx,dx                    ; p©°znak pracovn°ho dne, DL=bàënò
         cmp       cl,2                     ; je nedàle ?
         ja        DspKl531                 ; je pracovn° den
         mov       dh,1                     ; p©°znak volnÇho dne

DspKl531:mov       si,DiarIndx              ; zaá†tek indexñ
         mov       cx,es:[DiarNums]         ; poáet poloëek indexñ
         jcxz      DspKl536                 ; nen° nic

DspKl532:test      byte ptr es:[si+DiarPPar],bit5+bit6+bit7 ; je zmàna ?
         jz        DspKl535                 ; nen° zmàna
         call      DispKTst                 ; kontrola data
         jc        DspKl535                 ; datum nesouhlas°

         test      byte ptr es:[si+DiarPPar],bit6 ; je sv†tek ?
         jz        DspKl533                 ; nen° sv†tek
         mov       dh,1                     ; sv†tek

DspKl533:test      byte ptr es:[si+DiarPPar],bit5 ; pracovn° den ?
         jz        DspKl534                 ; nen° pracovn° den
         mov       dh,0                     ; pracovn° den

DspKl534:test      byte ptr es:[si+DiarPPar],bit7 ; zvòraznànò den ?
         jz        DspKl535                 ; nen° zvòraznànò den
         mov       dl,1                     ; zvòraznànò den

DspKl535:add       si,DiarPSum              ; dal®° index
         loop      DspKl532                 ; dal®° index

DspKl536:pop       ax
         mov       ss:[bp-20],al            ; n†vrat dne
         pop       cx
         pop       es

; ------ test, zda je jië konec pracovn°ch dnñ (DH=1 volnò, DL=1 vòraznò)

         or        dh,dh                    ; je pracovn° den ?
         mov       ah,ss:[bp-11]            ; bàën† barva vysv°cen†
         mov       dh,ss:[bp-13]            ; kurzor zvòraznànò
         jnz       DispKl63                 ; nen° pracovn° den
         inc       byte ptr ss:[bp-24]      ; á°taá pracovn°ch dnñ
         mov       ah,ss:[bp-12]            ; bàën† barva
         mov       dh,ss:[bp-14]            ; kurzor

; ------ test, zda je den zvòraznànò

DispKl63:or        dl,dl                    ; je zvòraznànò ?
         jz        DispKl64                 ; nen° zvòraznànò
         mov       ah,ds:[DiarColV]         ; zvòraznànò den
         mov       dh,ah                    ; i kurzor

; ------ dek¢dov†n° á°sla dne v màs°ci

DispKl64:mov       al,ss:[bp-23]            ; á°slo dne
         push      di
         call      DekRNum                  ; dek¢dov†n° á°sla màs°ce
         pop       di

; ------ oprava barvy pro kurzor

         cmp       al,ss:[bp-20]            ; je to aktu†ln° den ?
         jne       DispKl65                 ; nen° to aktu†ln° den
         cmp       byte ptr ss:[bp-8],RMnuLSir ; je to lev† polovina okna ?
         jne       DispKl65                 ; nen° to lev† polovina okna
         mov       ah,ss:[bp-14]            ; bàën† barva kurzoru
         mov       es:[di-1],ah             ; oprava barvy
         mov       es:[di+1],dh
         mov       es:[di+3],dh
         mov       es:[di+5],ah

; ------ indik†tory skuteánÇho dne

DispKl65:cmp       al,ss:[bp-36]            ; je skuteánò den v màs°ci ?
         jne       DispKl66                 ; nen° skuteánò den v màs°ci
         mov       byte ptr es:[di-2],"<"   ; levò indik†tor
         mov       byte ptr es:[di+4],">"   ; pravò indik†tor

; ------ p©°prava pro dal®° den v tòdnu

DispKl66:inc       byte ptr ss:[bp-23]      ; zvò®en° á°sla dne
         cmp       word ptr ss:[bp-18],1582 ; je rok 1582 ?
         jne       DispKl68                 ; nen° rok 1582
         cmp       byte ptr ss:[bp-19],10   ; je ©°jen ?
         jne       DispKl68
         cmp       byte ptr ss:[bp-23],5    ; je 5.10.1582 ?
         jne       DispKl68                 ; nen° 5.10.1582
         mov       byte ptr ss:[bp-23],15   ; oprava na 15.10.1582
DispKl68:add       di,4*2                   ; zvò®en° ukl†dac° adresy v bufferu
         dec       cx
         jz        DispKl69
         jmp       DispKl51                 ; dek¢dov†n° dal®°ho dne

DispKl69:

; ------ zobrazen° jednoho ©†dku se dny

         call      DispRMnD                 ; zobrazen° ©†dku kalend†©e

; ------ p©°prava pro dal®° ©†dek

         dec       byte ptr ss:[bp-7]       ; á°taá ©†dkñ k zobrazen°
         jz        DispKal7
         jmp       DispKal5                 ; zobrazen° dal®°ch dnñ


DispKal7:

; ------ zobrazen° poátu pracovn°ch dnñ

         call      DispKalC                 ; vymaz†n° ©†dku
         mov       si,offset ZDMnuPrc       ; text nadpisu
         mov       cx,offset(ZDMnuPr0-ZDMnuPrc) ; dÇlka textu
         mov       di,sp                    ; buffer v z†sobn°ku
         add       di,2*10                  ; poá†tek k dek¢dov†n° textu
         mov       ah,ss:[bp-12]            ; bàën† barva
DispKl72:lodsb
         stosw
         loop      DispKl72
         mov       al,ss:[bp-24]            ; poáet pracovn°ch dnñ
         call      DekRNum                  ; dek¢dov†n° poátu pracovn°ch dnñ
         call      DispRMnD                 ; zobrazen° ©†dku

; ------ zobrazen° dne a tòdne

         call      DispKalC                 ; vymaz†n° ©†dku
         cmp       byte ptr ss:[bp-8],RMnuLSir ; je to lev† polovina okna ?
         jne       DispKl77                 ; nen° to lev† polovina okna

         mov       cx,ss:[bp-18]            ; rok
         mov       bx,101h                  ; 1.ledna
         call      far ptr KonvDatN         ; konverze na absolutn° den
         push      ax
         call      far ptr KonvNDat         ; konverze zpàt na datum
         mov       ss:[bp-25],al            ; den v tòdnu (pondàl° = 0)
         pop       ax
         sub       ax,word ptr ds:[DiarADen] ; -den relativnà
         neg       ax                       ; oprava znamÇnka
         inc       ax                       ; korekce á°sla dne
         xchg      ax,si                    ; SI <- £schova á°sla dne
         inc       cx                       ; n†sleduj°c° rok
         call      far ptr KonvDatN         ; den poá†tku dal®°ho roku
         sub       ax,word ptr ds:[DiarADen] ; zbòvaj°c° poáet dnñ + 1
         dec       ax                       ; korekce á°sla dne
         xchg      ax,si                    ; AX <- den od poá†tku

         push      ds
         pop       es
         mov       di,offset ZDMnuDn1       ; buffer á°sla
         mov       word ptr ds:[di+5],"  "  ; vymaz†n° bufferu
         xor       bx,bx                    ; nen° barva ani oddàlovaá
         call      far ptr DekNumW          ; dek¢dov†n° poátu dnñ

         mov       byte ptr es:[di],"/"
         inc       di
         xchg      ax,si                    ; AX <- zbòvaj°c° poáet dnñ
         call      far ptr DekNumW          ; dek¢dov†n° zbòvaj°c°ch dnñ

         mov       al,ss:[bp-25]            ; den v tòdnu pro 1.1.
         mov       ah,0
         add       ax,si                    ; + á°slo dne v roce
         dec       ax                       ; korekce
         mov       cl,7                     ; poáet dnñ na tòden
         div       cl                       ; vòpoáet á°sla tòdne
         inc       ax                       ; korekce
         xchg      ax,bx                    ; BL <- á°slo tòdne

         push      ss
         pop       es
         cld
         mov       si,offset ZDMnuDen       ; text nadpisu
         mov       cx,offset(ZDMnuDn0-ZDMnuDen) ; dÇlka textu
         mov       di,sp                    ; buffer v z†sobn°ku
         add       di,2*7                   ; poá†tek k dek¢dov†n° textu
         mov       ah,ss:[bp-12]            ; bàën† barva
DispKl74:lodsb
         stosw
         loop      DispKl74

         mov       al,bl                    ; AL <- á°slo tòdne
         call      DekRNum                  ; dek¢dov†n° á°sla tòdne

DispKl77:call      DispRMnD                 ; zobrazen° ©†dku

; ------ zobrazen° juli†nskÇho dne

         call      DispKalC                 ; vymaz†n° ©†dku
         cmp       byte ptr ss:[bp-8],RMnuLSir ; je to lev† polovina okna ?
         jne       DispK776                 ; nen° to lev† polovina okna
         mov       di,sp
         mov       ah,ss:[bp-12]            ; bàën† barva
         cmp       word ptr ds:[DiarOffs+2],-1 ; je offset ?
         je        DispK772                 ; nen° offset

         add       di,2*11
         mov       si,offset ZDMnuOff
         mov       cx,offset(ZDMnuOf0-ZDMnuOff)
DispK771:lodsb
         stosw
         loop      DispK771
         mov       bh,ah
         mov       ax,word ptr ds:[DiarOffs]
         mov       dx,word ptr ds:[DiarOffs+2]
         sub       ax,word ptr ds:[DiarADen]
         sbb       dx,word ptr ds:[DiarADen+2]
         jns       DispK774
         not       ax
         not       dx
         add       ax,1
         adc       dx,0
         jmp       short DispK774

DispK772:mov       si,offset ZDMnuJul
         mov       cx,offset(ZDMnuJl0-ZDMnuJul)
         add       di,2*6
DispK773:lodsb
         stosw
         loop      DispK773

         mov       bh,ah
         mov       ax,word ptr ds:[DiarADen]
         mov       dx,word ptr ds:[DiarADen+2]
         add       ax,17121                 ; p©iáten° korekce 1721057
         adc       dx,26
DispK774:mov       bl,ds:[OddelRad]         ; oddàlovaá ©†dñ
         call      far ptr DekNum           ; dek¢dov†n° á°sla

DispK776:call      DispRMnD                 ; zobrazen° ©†dku

; ------ p©°prava pro pravou polovinu okna

         cmp       byte ptr ss:[bp-8],RMnuRSir ; je jië prav† polovina okna ?
         je        DispKal8                 ; je jië prav† polovina okna
         mov       byte ptr ss:[bp-8],RMnuRSir ; ®°©ka pravÇ poloviny okna
         add       byte ptr ss:[bp-6],RMnuLSir ; posun poá†teán° pozice okna
         mov       cx,ss:[bp-18]            ; rok
         mov       bx,ss:[bp-20]            ; den a màs°c
         inc       bh                       ; dal®° màs°c
         cmp       bh,13                    ; je p©eteáen° ?
         jne       DispKl78                 ; nen° p©eteáen°
         mov       bh,1                     ; korekce na leden
         inc       cx                       ; zvò®en° roku
DispKl78:mov       bl,1                     ; 1. den v màs°ci
         call      far ptr KonvDatN         ; konverze data na á°slo
         jmp       DispKl01                 ; dal®° màs°c

; ------ oddàlovac° á†ra

DispKal8:sub       byte ptr ss:[bp-6],RMnuLSir ; oprava pozice okna
         mov       byte ptr ss:[bp-8],RMnuLSir+RMnuRSir ; ®°©ka ©†dku

         push      ss
         pop       es
         cld
         mov       di,sp
         mov       al,"√"
         mov       ah,ss:[bp-15]            ; lev† hrana r†mu menu
         stosw
         mov       cx,RMnuLSir-1            ; ®°©ka levÇ poloviny okna
         mov       al,"ƒ"
         mov       ah,ss:[bp-12]            ; bàën† barva textu
         rep       stosw
         mov       al,"≈"
         stosw
         mov       al,"ƒ"
         mov       cl,RMnuRSir-2            ; ®°©ka pravÇ poloviny okna
         rep       stosw
         mov       al,"¥"

         push      ax
         mov       ah,ss:[bp-16]            ; prav† hrana r†mu menu
         stosw
         pop       ax

         sub       di,2*60
         mov       si,offset ZDMnuDns       ; text "dnes"
         mov       cl,offset(ZDMnuZit-ZDMnuDns)
DispKl83:lodsb
         stosw
         loop      DispKl83

         add       di,2*30
;         mov       si,offset ZDMnuZit       ; text "z°tra"
         mov       cl,offset(ZDMnZit0-ZDMnuZit)
DispKl84:lodsb
         stosw
         loop      DispKl84

         call      DispRMnD                 ; zobrazen° ©†dku

; ------ p©°prava pro pozn†mky k aktu†ln°mu dni

         mov       byte ptr ss:[bp-8],RMnuLSir ; ®°©ka levÇ poloviny okna
         mov       ax,word ptr ds:[DiarADen]
         mov       dx,word ptr ds:[DiarADen+2]
DispKl86:call      far ptr KonvNDat         ; konverze na datum
         mov       ss:[bp-18],cx            ; rok
         mov       ss:[bp-20],bx            ; den a màs°c
         mov       ss:[bp-22],ax            ; den v tòdnu a poáet dnñ v màs°ci

; ------ p©°prava ukazatelñ pro jednu polovinu okna

         mov       si,ss:[bp-2]             ; adresa definice okna
         mov       al,ds:[si+MnuVys]        ; vò®ka okna
         sub       al,14
         mov       ss:[bp-7],al             ; poáet ©†dkñ k zobrazen°
         mov       al,ds:[si+MnuRad]        ; poá†teán° ©†dek
         add       al,13                    ; korekce poá†teán°ho ©†dku
         mov       ss:[bp-5],al             ; poá†teán° ©†dek
         mov       word ptr ss:[bp-28],DiarIndx ; ukazatel v tabulce indexñ

; ------ vymaz†n° ©†dku

DispKl88:call      DispKalC                 ; vymaz†n° ©†dku

; ------ adresa segmentu pozn†mek -> ES

         mov       ax,ds:[SegmIDia]         ; segment indexñ pozn†mek
         call      far ptr GetDat           ; adresa bufferu -> ES

; ------ test, zda je dal®° index pozn†mek

DispK882:mov       si,ss:[bp-28]            ; ukazatel indexñ pozn†mek
         cmp       si,es:[0]                ; je to platnò index
         jae       DispKl89                 ; nen° dal®° index
         add       word ptr ss:[bp-28],DiarPSum ; zvò®en° ukazatele indexñ

; ------ nulov† dÇlka neplat°

         cmp       byte ptr es:[si+DiarPDel],0 ; je nulov† dÇlka ?
         je        DispK882                 ; nulov† dÇlka neplat°

; ------ kontrola data

         call      DispKTst                 ; kontrola data
         jc        DispK882                 ; datum nesouhlas°

; ------ p©°prava ukl†dac° adresy -> DI

         mov       di,sp                    ; buffer v z†sobn°ku
         inc       di
         inc       di                       ; p©eskoáen° levÇho okraje
         mov       ax,RMnuRSir-2            ; ®°©ka vàt®° poloviny okna
         mov       cl,es:[si+DiarPDel]      ; dÇlka textu
         mov       ch,0
         sub       ax,cx                    ; zbytek na okraje
         jnc       DispK886                 ; je to OK
         xor       ax,ax                    ; omezen° p©i podteáen°
         mov       cl,RMnuRSir-2            ; omezen° dÇlky textu
DispK886:and       al,not bit0              ; okraj/2 * 2
         add       di,ax                    ; DI <- ukl†dac° adresa

; ------ adresa bufferu -> DX

         mov       ax,ds:[SegmDDia]         ; segment dat di†©e
         call      far ptr GetSgAdr         ; adresa bufferu -> DX

; ------ p©°prava barvy textu -> AH

         mov       ah,ss:[bp-12]            ; bàën† barva
         test      byte ptr es:[si+DiarPDny],bit7 ; je to zvòraznàno ?
         jz        DispK887                 ; nen° zvòraznàno
         mov       ah,ss:[bp-11]            ; bàën† barva vysv°cen†

; ------ dek¢dov†n° textu

DispK887:mov       si,es:[si+DiarPOfs]      ; SI <- adresa textu v bufferu
         push      ss
         pop       es                       ; ES <- segment bufferu v z†sobn°ku
         push      ds
         mov       ds,dx                    ; DS <- segment dat di†©e
         cld
DispK888:lodsb
         stosw
         loop      DispK888
         pop       ds

; ------ zobrazen° ©†dku

DispKl89:push      ss
         pop       es                       ; ES <- segment bufferu
         mov       si,sp                    ; buffer s textem
         mov       dx,ss:[bp-6]             ; ©†dek a pozice k zobrazen°
         mov       cl,ss:[bp-8]             ; dÇlka ©†dku
         mov       al,ss:[bp-10]            ; hladina k zobrazen°
         mov       ah,0
         call      far ptr DispMStr         ; zobrazen° ©†dku
         inc       byte ptr ss:[bp-5]       ; zvò®en° ukazatele ©†dku

; ------ p©°prava pro dal®° ©†dek

         dec       byte ptr ss:[bp-7]       ; á°taá ©†dkñ k zobrazen°
         jnz       DispKl88                 ; dal®° ©†dek

; ------ p©°prava pro pravou polovinu okna

DispKal9:cmp       byte ptr ss:[bp-8],RMnuRSir ; je jië prav† polovina okna ?
         je        DispKl94                ; je jië prav† polovina okna
         mov       byte ptr ss:[bp-8],RMnuRSir ; ®°©ka pravÇ poloviny okna
         add       byte ptr ss:[bp-6],RMnuLSir ; posun poá†teán° pozice okna
         mov       ax,word ptr ds:[DiarADen]
         mov       dx,word ptr ds:[DiarADen+2]
         add       ax,1
         adc       dx,0
         jmp       DispKl86                 ; dal®° den

; ------ n†vrat registrñ

DispKl94:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispRMnu ENDP

; ------ zobrazen° ©†dku kalend†©e

DispRMnD:mov       si,sp                    ; buffer s textem
         inc       si
         inc       si
         mov       dx,ss:[bp-6]             ; ©†dek a pozice k zobrazen°
         mov       cl,ss:[bp-8]             ; dÇlka ©†dku
         mov       al,ss:[bp-10]            ; hladina k zobrazen°
         mov       ah,0
         call      far ptr DispKStr         ; zobrazen° horn°ho okraje
         inc       byte ptr ss:[bp-5]       ; zvò®en° ukazatele ©†dku
         ret

; ------ vymaz†n° ©†dku kalend†©e

DispKalC:cld
         push      ss
         pop       es                       ; ES <- segment z†sobn°ku
         mov       di,sp
         inc       di
         inc       di
         mov       al,"≥"
         mov       ah,ss:[bp-15]            ; lev† hrana r†mu menu
         cmp       byte ptr ss:[bp-8],RMnuLSir ; je lev† polovina ?
         je        DispKlC2                 ; je lev† polovina
         mov       ah,ss:[bp-12]            ; oddàlovac° á†ra - bàën† barva
DispKlC2:stosw
         mov       cx,RMnuRSir-2            ; ®°©ka vàt®° poloviny okna
         mov       al," "
         mov       ah,ss:[bp-12]            ; bàën† barva textu
         rep       stosw
         mov       al,"≥"
         mov       ah,ss:[bp-16]            ; prav† hrana r†mu menu
         stosw
         ret

; ------ porovn†n° data ES:SI (niá° AX) -> CY=nesouhlas°

DispKTst PROC      NEAR

         push      cx

         mov       ax,es:[si+DiarPRok]      ; rok
         and       ax,0fffh                 ; maskov†n° roku
         jz        DispKTs2                 ; jsou v®echny roky
         cmp       ax,ss:[bp-18]            ; souhlas° rok ?
         jne       DispKTs8                 ; rok nesouhlas°

DispKTs2:mov       al,es:[si+DiarPRok+1]    ; màs°c
         mov       cl,12-8
         shr       al,cl                    ; màs°c
         jz        DispKTs4                 ; jsou v®echny màs°ce
         cmp       al,ss:[bp-19]            ; souhlas° màs°c ?
         jne       DispKTs8                 ; màs°c nesouhlas°

DispKTs4:mov       al,es:[si+DiarPPar]      ; den
         and       al,1fh                   ; maskov†n° dne
         jz        DispKTs6                 ; jsou v®echny dny
         cmp       al,ss:[bp-20]            ; souhlas° den ?
         jne       DispKTs8                 ; den nesouhlas°

; ------ kontrola dne v tòdnu

DispKTs6:mov       cl,ss:[bp-22]            ; den v tòdnu
         mov       al,bit0                  ; maska
         shl       al,cl                    ; rotace masky na pozici
         test      al,es:[si+DiarPDny]      ; souhlas° den v tòdnu ?
         jnz       DispKTs9                 ; den v tòdnu souhlas° OK

DispKTs8:stc                                ; p©°znak chyby
DispKTs9:pop       cx
         ret

DispKTst ENDP

; *****************************************************************************
;                               DekRNum
;                    dek¢dov†n° dvojá°sl° s mezerou
; -----------------------------------------------------------------------------
; VSTUP: AL=á°slo
;        AH=barva textu
;        ES:DI=ukl†dac° adresa
; *****************************************************************************

DekRNum  PROC      NEAR

         push      cx
         push      ax

         cld
         push      ax
         aam                                ; AH <- á°slo HIGH, AL <- á°slo LOW
         or        ax,"00"                  ; korekce na znaky ASCII
         xchg      ax,cx
         pop       ax

         mov       al,ch                    ; prvn° á°slice
         cmp       al,"0"                   ; je prvn° znak 0 ?
         jne       DekRNum1                 ; nen° 0
         mov       al," "                   ; n†hrada mezerou
DekRNum1:stosw                              ; uloëen° prvn° á°slice

         mov       al,cl                    ; druhÇ á°slo
         stosw                              ; uloëen° druhÇ á°slice

         pop       ax
         pop       cx
         ret

DekRNum  ENDP

;; -----------------------------------------------------------------------------
;;        vòpoáet f†ze Màs°ce pro den DX:AX -> AL (0= aë 28, 0=NOV)
;; -----------------------------------------------------------------------------
;; lok†ln° promànnÇ: SS:[BP-6] (6) dàlenec (den p©epoátenò na desetiny sekund)
;;                   SS:[BP-10] (4) dàlitel (perioda v desetin†ch sekundy)
;;                         (((29*24+12)*60+44)*60+2)*10+7 = 25514427 = 018551BBh
;; -----------------------------------------------------------------------------
;
;FazeMes  PROC      NEAR
;
;         ret
;
;FazeMes  ENDP
;
;velikonoce: prvn° nedàle po prvn°m jarn°m £pl§ku
;f†ze màs°ce:    nov            (nen° vidàt, vznik† novò màs°c)
;                prvn° átvrü    ( D )
;                £plnàk         ( O )
;                posledn° átvrü ( C )
;
;jarn° rovnodenost: 21. b©ezna
;
;lun†rn° den:   24 h 50 min 28 s
;
;synodickò màs°c (mezi dvàma stejnòmi f†zemi): 29 dnñ, 12 h, 44 min, 2.7 s
;                 = 708 h, 44 min, 2.7 s = 42524 min, 2.7 s = 2551442.7 s
;                 = 25'514'427 desetin sekundy = 185'51BB HEX desetin s
;              (4000 let = asi 1'262'300'544'000 = 125'E6F9'BC00 HEX desetin s)
;
;juli†nsk† perioda: obdob° 7980 rokñ s poá†tkem periody 1. ledna 4713 p©. n. l.
;                   (1. leden 1980 m† datum 2444240)

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                               P©epoáty data
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
; *****************************************************************************
;                               KonvDatN
;                      p©evod data na poáet dnñ
; -----------------------------------------------------------------------------
; VSTUP: CX=rok (1 aë 9999)
;        BH=màs°c (1 aë 12)
;        BL=den (1 aë 31)
;        DS=datovò segment
; VùSTUP:DX:AX=den absolutnà (od 1.1. roku 0 = den 0)
; *****************************************************************************

KonvDatN PROC      FAR

; ------ £schova registrñ

         push      bx
         push      si
         push      di

; ------ p©°prava registrñ, p©iáten° dne

         xor       dx,dx                    ; st©adaá HIGH
         xor       si,si                    ; st©adaá LOW
         mov       di,cx                    ; DI <- poëadovanò rok
         xor       cx,cx                    ; ukazatel roku

; ------ vòpoáet stolet°

         xor       ax,ax                    ; AX <- 0 nic se nep©iá°t†
KonvDtN1:add       si,ax                    ; p©iáten° poátu dnñ ve stolet°
         adc       dx,0                     ; p©enos HIGH
         call      StoGet                   ; stanoven° poátu dnñ ve stolet°
         add       cx,100                   ; zvò®en° stolet°
         cmp       cx,di                    ; je dosaëeno poëadovanÇho roku ?
         jbe       KonvDtN1                 ; nen° je®tà poëadovanÇ stolet°
         sub       cx,100                   ; n†vrat á°sla stolet°

; ------ vòpoáet roku

         xor       ax,ax                    ; AX <- 0 nic se nep©iá°t†
KonvDtN2:add       si,ax                    ; p©iáten° poátu dnñ v roce
         adc       dx,0                     ; p©enos HIGH
         call      RokGet                   ; stanoven° poátu dnñ v roce
         inc       cx                       ; zvò®en° ukazatele let
         cmp       cx,di                    ; dosaëeno poëadovanÇho roku ?
         jbe       KonvDtN2                 ; nen° je®tà poëadovanò rok
         dec       cx                       ; n†vrat á°sla roku
         jmp       short KonvDtN4

; ------ p©iáten° màs°cñ (pozp†tku)

KonvDtN3:call      MesicGet                 ; stanoven° poátu dnñ v màs°ci
         add       si,ax                    ; p©iáten° poátu dnñ v màs°ci
         adc       dx,0                     ; p©enos HIGH
KonvDtN4:dec       bh                       ; sn°ëen° á°sla màs°ce
         jnz       KonvDtN3                 ; je dal®° màs°c

; ------ p©iáten° dne

         dec       bx                       ; korekce á°sla dne
         xchg      ax,si                    ; den absolutnà LOW
         add       ax,bx                    ; p©iáten° dne
         adc       dx,0

; ------ n†vrat registrñ

         pop       di
         pop       si
         pop       bx
         ret

KonvDatN ENDP

; *****************************************************************************
;                              KonvNDat
;                  p©evod absolutn°ho dne na datum
; -----------------------------------------------------------------------------
; VSTUP: DX:AX=den absolutnà (od 1.1. roku 0 = den 0)
;        DS=datovò segment
; VùSTUP:AL=den v tòdnu (0=pondàl° aë 6=nedàle)
;        AH=poáet dnñ v màs°ci (28 aë 31)
;        BH=màs°c (1 aë 12)
;        BL=den (1 aë 31)
;        CX=rok (0 aë 9999)
; *****************************************************************************

KonvNDat PROC      FAR

; ------ £schova registrñ

         push      dx
         push      si
         push      di
         push      bp

; ------ p©°prava registrñ

         mov       bp,dx                    ; BP <- den HIGH (pro den v tòdnu)
         mov       di,ax                    ; DI <- den LOW (pro den v tòdnu)
         mov       si,dx                    ; SI <- den HIGH (á°taá k odá°t†n°)
         xchg      ax,dx                    ; DX <- den LOW (á°taá k odá°t†n°)
         xor       cx,cx                    ; CX <- 0 á°taá roku
         xor       bx,bx                    ; p©ednastaven° màs°ce a dne

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

KonvNDt5:inc       bh                       ; zvò®en° á°sla màs°ce
         call      MesicGet                 ; stanoven° poátu dnñ v màs°ci
         sub       dx,ax                    ; je màs°c nalezen ?
         sbb       si,0                     ; p©enos do vy®®°ho slova
         jnc       KonvNDt5                 ; p©evod dal®°ho màs°ce
         add       dx,ax                    ; n†vrat màs°ce

; ------ stanoven° dne

         inc       dx                       ; den v màs°ci
         mov       bl,dl                    ; den v màs°ci

; ------ korekce data pro ©°jen 1582

         cmp       cx,1582
         jne       KonvNDt6
         cmp       bh,10
         jne       KonvNDt6
         cmp       bl,5
         jb        KonvNDt6
         add       bl,10                    ; korekce dne

; ------ vòpoáet dne v tòdnu

KonvNDt6:push      bx                       ; £schova màs°ce a dne
         push      ax                       ; £schova poátu dnñ v màs°ci

         mov       dx,bp                    ; den HIGH
         xchg      ax,di                    ; den LOW
         add       ax,3                     ; korekce pro spr†vnò den
         adc       dx,0                     ; p©enod do vy®®°ho slova
         mov       bx,7                     ; poáet dnñ v tòdnu

         push      ax                       ; den LOW
         xchg      ax,dx                    ; AX <- den HIGH
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
; VSTUP: BH=màs°c (1 aë 12)
;        CX=rok (1 aë 9999)
;        DS=datovò segment
; VùSTUP:AX=poáet dnñ (21 aë 31)
; -----------------------------------------------------------------------------

MesicGet PROC      NEAR

         push      bx

; ------ v ©°jnu 1582 je nam°sto 31 dnñ pouze 21 dnñ

         mov       ax,21                    ; je 21 dnñ v ©°jnu
         cmp       cx,1582                  ; je rok 1582 ?
         jne       MesicGt1                 ; nen° rok 1582
         cmp       bh,10                    ; je ©°jen ?
         je        MesicGt2                 ; je ©°jen 1582

; ------ poáet dnñ v màs°ci

MesicGt1:mov       bl,bh                    ; màs°c
         xor       bh,bh                    ; BX=màs°c
         mov       al,ds:[bx+PoctyDnu-1]    ; poáet dnñ v màs°ci
         cmp       bl,2                     ; je to £nor ?
         jne       MesicGt2                 ; nen° £nor
         call      RokTest                  ; test p©estupnosti roku
         adc       al,ah                    ; pro p©estupnò rok je £nor 29 dnñ

MesicGt2:pop       bx
         ret

MesicGet ENDP

; -----------------------------------------------------------------------------
;                     stanoven° poátu dnñ v roce
; -----------------------------------------------------------------------------
; VSTUP: CX=rok (1 aë 9999)
; VùSTUP:AX=poáet dnñ (355 aë 366)
; -----------------------------------------------------------------------------

RokGet   PROC      NEAR

; ------ poáet dnñ v roce 1582

         mov       ax,365-10                ; poáet dnñ v roce 1582
         cmp       cx,1582                  ; je rok 1582 ?
         je        RokGet1                  ; je rok 1582

; ------ poáet dnñ podle p©estupnosti roku (AH=1)

         mov       al,(365 AND 255)-1       ; poáet dnñ v nep©estupnÇm roce - 1
         call      RokTest                  ; test p©estupnosti roku
         adc       al,ah                    ; pro p©estupnò rok 366 dnñ
RokGet1: ret

RokGet   ENDP

; -----------------------------------------------------------------------------
;                    test p©estupnosti roku
; -----------------------------------------------------------------------------
; VSTUP: CX=rok (1 aë 9999)
; VùSTUP:CY=je p©estupnò rok
; -----------------------------------------------------------------------------

RokTest  PROC      NEAR

; ------ test, zda rok je n†sobkem 4

         test      cl,3                     ; je p©estupnò rok ?
         jnz       RokTest3                 ; nen° p©estupnò rok

; ------ p©ed rokem 1600 je stolet° p©estupnÇ vëdy

         cmp       ch,6                     ; je p©ed rokem 1600 (=1536) ?
         jb        RokTest3                 ; p©ed 1600 p©estupnÇ vëdy

; ------ £schova registrñ

         push      ax
         push      cx

; ------ test, zda je stolet° n†sobkem 4

         mov       al,100                   ; dàlitel stolet°
         xchg      ax,cx                    ; AX <- rok
         div       cl                       ; vòpoáet stolet°
         or        ah,ah                    ; je stolet° ?
         jnz       RokTest1                 ; nen° stolet° - je p©estupnò rok
         and       al,3                     ; je stolet° dàlitelnÇ 4 ?
         jnz       RokTest2                 ; nen° dàlitelnÇ 4 - nen° p©estupnÇ
RokTest1:stc                                ; p©°znak p©estupnÇho roku

; ------ n†vrat registrñ

RokTest2:pop       cx
         pop       ax

RokTest3:ret

RokTest  ENDP

; -----------------------------------------------------------------------------
;                      stanoven° poátu dnñ ve stolet°
; -----------------------------------------------------------------------------
; VSTUP: CX=rok 1 aë 9999 (koná°c° 00 - stolet°)
; VùSTUP:AX=poáet dnñ ve stolet° (od roku CX po rok CX+99)
; -----------------------------------------------------------------------------

StoGet   PROC      NEAR

; ------ £schova registrñ

         push      cx

; ------ vòpoáet á°sla stolet°

         xchg      ax,cx                    ; AX <- rok
         mov       cl,100                   ; poáet let ve stolet°
         div       cl                       ; AL <- vòpoáet stolet°

; ------ poáet let ve stolet° 15xx

         cmp       al,15                    ; je stolet° 15 ?
         jne       StoGet1                  ; nen° stolet° 15
         mov       ax,25*366+75*365-10      ; zkr†cenÇ p©estupnÇ stolet°
         jmp       short StoGet3

; ------ stolet° p©ed 1582 je p©estupnÇ vëdy

StoGet1: jb        StoGet2                  ; je p©ed 1600 - p©estupnÇ vëdy

; ------ poáet let podle p©estupnosti stolet°

         test      al,3                     ; je stolet° dàlitelnÇ 4 ?
         mov       ax,24*366+76*365         ; nep©estupnÇ stolet°
         jnz       StoGet3                  ; stolet° nen° p©estupnÇ
StoGet2: mov       ax,25*366+75*365         ; stolet° je p©estupnÇ

; ------ n†vrat registrñ

StoGet3: pop       cx
         ret

StoGet   ENDP

CodeZvl  ENDS

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
;        ASCII tabulka
; -----------------------------------------------------------------------------

;ColT1    db        70h                      ; bàën† barva tabulky
;ColT2    db        30h                      ; barva kurzoru okna
;ColT3    db        07h                      ; barva informaán°ho ©†dku
;ColT4    db        0fh                      ; barva á°sel informaán°ho ©†dku
;AscTbSwc db        1                        ; p©ep°naá polohy ASCII tabulky
;                                            ;  0 = vlevo
;                                            ;  1 = uprost©ed
;                                            ;  2 = vpravo

TextT    db        ' ',0
TextTD   db        '000',0,' Dek ≥ ',0
TextTH   db        '00',0,' Hex ≥ ',0
TextTB   db        '00000000',0,' Bin '
TextT0   db        '≥ . Ascii       '

AsciOKur dw        0                        ; uschovanò pñvodn° kurzor

; -----------------------------------------------------------------------------
;        definice ASCII tabulky
; -----------------------------------------------------------------------------

ZAMnuLin label     byte

         db        5                        ; typ menu - ASCII tabulka

         db        0                        ; hladina k zobrazen° menu
         dw        1+7*16+7                 ; aktivn° poloëka - znak ASCII
         dw        256                      ; poáet platnòch poloëek
         dw        256                      ; celkovò poáet poloëek

         dw        0                        ; zaá†tek definice poloëek
         dw        ZAMnuLH1                 ; n†povàda
         dw        Hlp@ASCIITabulka         ; á°slo str†nky velkÇ n†povàdy
         dw        0                        ; blokovac° tabulka
         dw        0                        ; p©ep°naáe
         dw        ZAMnuLT1                 ; adresa titulu okna
         dw        0                        ; adresa tabulky obsluh (nen°)
         dw        0                        ; adresa tabulky podmenu (nen°)
         dd        0                        ; £schova n†vratovÇ adresy (nen°)

         db        0                        ; poá†teán° pozice
         db        0                        ; poá†teán° ©†dek
         db        35                       ; ®°©ka okna
         db        19                       ; vò®ka okna

ZAMnuLT1 db        13,'ASCII tabulka'
ZAMnuLT2 db        14,'atributy barev'

HelpS    SEGMENT   BYTE PUBLIC
ZAMnuLH1 db        88,'Tab=poloha, Enter nebo Ctrl-P=znak do textu, mezera=barvy/znaky, Esc=p©eru®en°'
HelpS    ENDS

; -----------------------------------------------------------------------------
; Astronomickò (siderickò) rok = doba, za kterou se Zemà navr†t° vzhledem
;                                k ostatn°m hvàzd†m do stejnÇho m°sta.
;                                Trv† 365 dn°, 6 h, 9 min, 9.5 s = 365.2564 dne
;
; Tropickò rok     = doba mezi dvàma prñchody Slunce jarn°m bodem.
;                    Trv† 365 dn°, 5 h, 48 min, 45.7 s = 365.2422 dne
;
; Juli†nskò kalend†©: - platil do 4.10.1582.
;                     - p©estupnò rok je rok dàlitelnò 4.
;                     - v p©estupnÇm roce je v £noru 29 dnñ, jinak 28 dnñ.
;                     - 1 rok trv† 365.25 dne
;
; Pro opravu kalend†©e bylo 5.10.1582 aë 14.10.1582 (10 dnñ) vypu®tàno.
;
; Gregori†nskò kalend†© - zaveden papeëem ûeho©em XIII, plat° od 15.10.1582
;                       - p©estupnò rok je rok dàlitelnò 4, prvn° rok stolet°
;                         (tj. rok koná°c° 00) je v®ak p©estupnò pouze tehdy,
;                         je-li dàlitelnò 4.
;                       - v p©estupnÇm roce je v £noru 29 dnñ, jinak 28 dnñ.
;                       - 1 rok trv† 365.2425 dne
; -----------------------------------------------------------------------------
;˛
ZDMnu    label     byte                   ;* kalend†©
         db        8                        ; typ okna - kalend†©

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        1                        ; poáet platnòch poloëek menu
         dw        1                        ; celkovò poáet poloëek menu

         dw        0                        ; zaá†tek definice poloëek menu
         dw        ZDMnuLHl                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@Kalendar             ; á°slo str†nky velkÇ n†povàdy
         dw        ZDMnuBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        ZDMnuTit                 ; adresa titulu okna
         dw        0                        ; tabulka obsluh voleb menu
         dw        0                        ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        0                        ; poá†teán° pozice okna
         db        0                        ; poá†teán° ©†dek okna
         db        75                       ; ®°©ka okna
         db        20                       ; vò®ka okna

ZDMnuBlk db        0

ZDMnuTit db        8,'kalend†©'

DnyNadp  db        'Po  ót  St  Ät  P†  ',0,'So  Ne'
DnyNadp0 label     byte

ZDMnuPrc db        'pracovn°ch dnñ: '
ZDMnuPr0 label     byte

ZDMnuDen db        'den: '
ZDMnuDn1 db        '000/000   tòden: '
ZDMnuDn0 label     byte

ZDMnuJul db        'juli†nskÇ datum: '
ZDMnuJl0 label     byte

ZDMnuOff db        'vzd†lenost: '
ZDMnuOf0 label     byte

ZDMnuDns db        ' dnes: '                 ; uvÇst za sebou !
ZDMnuZit db        ' z°tra: '
ZDMnZit0 label     byte

DosmDiar db        10,'DOSMAN.DIA'

HelpS    SEGMENT   BYTE PUBLIC
ZDMnuLHl db        94,'F4=editace, F5=rozd°l, PgUp/PgDn=màs°c, Ctrl-PgUp/Ctrl-PgDn=rok, F7/F8=stolet°'
HelpS    ENDS

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

Mesice   db        5,'leden'
         db        4,'£nor'
         db        6,'b©ezen'
         db        5,'duben'
         db        6,'kvàten'
         db        6,'áerven'
         db        8,'áervenec'
         db        5,'srpen'
         db        4,'z†©°'
         db        5,'©°jen'
         db        8,'listopad'
         db        8,'prosinec'

;DiarColV db        4fh                      ; zvòraznànò den kalend†©e

SegmDDia dw        0                        ; segment dat di†©e (0=nen°)
SegmIDia dw        0                        ; segment indexñ di†©e (0=nen°)

ADen     db        0                        ; aktu†ln° den
AMesic   db        0                        ; aktu†ln° màs°c
ARok     dw        0                        ; aktu†ln° rok
ADenAbs  dd        0                        ; aktu†ln° den (absolutn° á°slo)
DiarADen dd        0                        ; aktu†ln° nastavenò den

DiarOKur dw        0                        ; uschovan† pozice kurzoru
DiarOffs dd        -1                       ; poá†tek offsetu (-1=nen°)

Data     ENDS
         END

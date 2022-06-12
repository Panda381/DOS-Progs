
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                            Z è P I S N ã K
;
;                            pozn†mkovò blok
;
; =============================================================================
;
; Ve©ejnÇ procedury:
;
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞


INCLUDE  ASM\DEF.ASM

CodeZap  SEGMENT   BYTE PUBLIC
         ASSUME    cs:CodeZap,ds:Data

; *****************************************************************************
;
;                           Z†pisn°k
;
; *****************************************************************************
;˛
Zapis    PROC      FAR

         add       sp,4                     ; zru®en° n†vratovÇ adresy
         call      far ptr ClosMnuA         ; uzav©en° menu

; ------ volba souboru ze seznamu

ZapisF   LABEL     FAR

         mov       si,offset ZZMnuSel       ; specifikace menu vòbàru
         call      FileSel                  ; vòbàr souboru
         jnc       Zapis1                   ; byl zvolen nàjakò soubor
         jmp       far ptr Main0            ; konec z†pisn°ku

; ------ obsluha editoru

Zapis1:  push      ds
         pop       es                       ; ES <- datovò segment
         mov       di,offset ZapsPath       ; jmÇno souboru NOT
         mov       cx,ds:[ZapsPthN]         ; dÇlka jmÇna souboru
         mov       byte ptr ds:[ZapsTypI],1 ; p©°znak z†pisn°ku
         call      far ptr EditNOT          ; obsluha editoru NOT

; ------ odstranàn° jmÇna souboru z cesty

         mov       si,offset ZZMnuSel       ; specifikace menu vòbàru
         call      far ptr SubFSel          ; odstranàn° jmÇna souboru
         jmp       short ZapisF

Zapis    ENDP

EditADR  dd        0                        ; adresa jmÇna souboru
EditADRN dw        0                        ; dÇlka jmÇna souboru

; -----------------------------------------------------------------------------
;        obsluha editoru NOT (ES:DI=jmÇno souboru, CX=dÇlka jmÇna souboru)
; -----------------------------------------------------------------------------

EditNOT  PROC      FAR

         mov       word ptr cs:[EditADR],di
         mov       word ptr cs:[EditADR+2],es
         mov       cs:[EditADRN],cx
         or        byte ptr ds:[ParZvl],bit7 ; p©°znak editace z†pisn°kem

; ------ korekce identifik†toru souboru

         cmp       byte ptr ds:[ZapsTypI],2 ; je typ uráen ?
         jne       Zapis16                  ; typ nen° uráen
         mov       byte ptr ds:[ZapsTypI],0 ; implicitnà neukl†dat parametry
         cmp       cx,5                     ; minim†ln° dÇlka
         jb        Zapis16                  ; mal† dÇlka

         push      ax
         push      di

         add       di,cx                    ; konec jmÇna

         mov       ax,es:[di-2]             ; znaky 3 a 4 z konce
         call      far ptr UpCase           ; konverze na velkÇ p°smeno
         xchg      al,ah
         call      far ptr UpCase
         xchg      ax,dx

         mov       ax,es:[di-4]             ; znaky 1 a 2 z konce
         cmp       al,"."                   ; teáka p©ed p©°ponou ?
         jne       Zapis15                  ; nen° teáka

         mov       al,ah
         call      far ptr UpCase           ; konverze na velkÇ p°smeno
         cmp       al,"N"                   ; je NOT ?
         jne       Zapis11                  ; nen° z†pisn°k
         cmp       dx,"OT"
         jne       Zapis11
         inc       byte ptr ds:[ZapsTypI]   ; je z†pisn°k

Zapis11: cmp       al,"M"
         jne       Zapis12                 ; nen° MNU
         cmp       dx,"NU"
         jne       Zapis12
         mov       byte ptr ds:[ZapsTypI],4 ; je uëivatelskÇ menu

Zapis12: cmp       al,"D"
         jne       Zapis15                  ; nen° DIA
         cmp       dx,"IA"
         jne       Zapis15
         mov       byte ptr ds:[ZapsTypI],5 ; je di†©

Zapis15: pop       di
         pop       ax

; ------ otev©en° okna textu

Zapis16: call      far ptr OpenText         ; otev©en° bufferu textu
         jnc       EditNOT1
         and       byte ptr ds:[ParZvl],not bit7 ; p©°znak editace z†pisn°kem
         ret                                ; asi chyba pamàti

EditNOT1:mov       ds:[TextSegm],ax         ; segment okna

; ------ jmÇno aktivn°ho souboru

         push      di
         push      cx

         mov       si,offset SRSMnPl4+1     ; buffer jmÇna souboru
         mov       cl,ds:[si-1]             ; dÇlka jmÇna souboru
         mov       ch,0
         cld
         mov       di,TextName              ; jmÇno souboru
         mov       es:[TextNamN],cx         ; dÇlka jmÇna souboru
         rep       movsb                    ; uloëen° jmÇna souboru

; ------ koment†© souboru

         mov       si,offset LinBuff        ; buffer s koment†©em
         mov       cl,ds:[si-1]             ; dÇlka bufferu
         mov       es:[TextNKom],cx         ; dÇlka komet†©e
         mov       di,TextKom               ; koment†© souboru
         rep       movsb                    ; uloëen° koment†©e

         pop       cx
         pop       di

; ------ otev©en° souboru

         push      es

         les       si,cs:[EditADR]          ; adresa jmÇna souboru
;         push      ds
;         pop       es
;         mov       si,offset ZapsPath       ; jmÇno souboru
         call      far ptr OpenRW           ; otev©en° pro áten° i z†pis
         jnc       Zapis2                   ; OK
         call      far ptr OpenR            ; otev©en° alespo§ pro áten°
         jc        Zapis24                  ; chyba

         pop       es
         or        byte ptr es:[TextParm],bit0 ; z†kaz z†pisu
         push      es

Zapis2:  pop       es
         jnc       Zapis23
Zapis22: jmp       Zapis04                  ; chyba - soubor nelze otev©°t

Zapis24: call      far ptr CreatFil         ; vytvo©en° souboru
         jmp       short Zapis2             ; (CY=chyba)

; ------ naáten° souboru do bufferu ES:DI

Zapis23: mov       bx,cx                    ; BX <- volnÇ m°sto v bufferu
         call      far ptr ReadFile         ; naáten° souboru

; ------ uzav©en° souboru

         pushf
         call      far ptr ClosFile         ; uzav©en° souboru
         popf
         jc        Zapis22                  ; chyba áten° souboru

; ------ kontrola, zda je soubor naáten celò

         cmp       bx,cx                    ; byl soubor naáten celò ?
         ja        Zapis3                   ; soubor byl naáten celò
         or        byte ptr es:[TextParm],bit0 ; z†kaz z†pisu

; ------ odstranàn° koncovÇho znaku EOF

Zapis3:  add       di,cx                    ; adresa konce dat
         jcxz      Zapis32                  ; nebylo nic naáteno
         cmp       byte ptr es:[di-1],EOF   ; je soubor ukonáen EOF ?
         jne       Zapis32                  ; nen° EOF
         dec       cx                       ; sn°ëen° dÇlky textu
         dec       di                       ; sn°ëen° adresy konce

; ------ uloëen° dÇlky textu a sn°ëen° velikosti segmentu

Zapis32: mov       es:[TextByts],di         ; nov† velikost segmentu
         mov       bx,di                    ; BX <- velikost dat
         mov       es:[TextBNum],cx         ; poáet bajtñ textu v bufferu
         mov       ax,ds:[TextSegm]         ; segment textu
         call      far ptr ModiSegS         ; nastaven° velikosti segmentu

; ------ inicializace obsahu bufferu (AX=segment)

         call      far ptr InitText         ; inicializace textu
         jc        Zapis22                  ; p©eru®en° operace

; ------ konverze tabul†torñ na mezery (AX=segment)

         call      ZapTbSp                  ; konverze tabul†torñ na mezery

; ------ p©°prava á°sla velkÇ n†povàdy

         mov       word ptr ds:[TextMnuH],Hlp@EditorZapisniku ; z†pisn°k
         cmp       byte ptr ds:[ZapsTypI],3 ; konfiguraán° soubor ?
         jb        Zapis34                  ; je z†pisn°k
         mov       word ptr ds:[TextMnuH],Hlp@KonfiguracniSoubor ; INI soubor
         je        Zapis34                  ; je INI soubor
         mov       word ptr ds:[TextMnuH],Hlp@UzivatelskeMenu ; uëivatelskÇ menu
         cmp       byte ptr ds:[ZapsTypI],5 ; je kalend†© ?
         jb        Zapis34                  ; nen° kalend†©
         mov       word ptr ds:[TextMnuH],Hlp@PoznamkyKalendare ; kalend†©

; ------ otev©en° okna souboru

Zapis34: mov       si,offset TextMnu        ; menu textu
         call      far ptr OpenMnu          ; otev©en° okna menu

; ------ obnoven° zobrazen° obrazovky

Zapis39: call      far ptr NulBreak         ; nulov†n° p©°znaku p©eru®en°
         call      far ptr InfoClos         ; uzav©en° informaán°ho ©†dku
         mov       si,offset TextMnu        ; menu textu
         call      far ptr KorEMnu          ; korekce okna
         test      byte ptr ds:[TextEPar],bit3 ; pot©eba zobrazen° v®eho ?
         jz        Zapis391                 ; nen° zobrazen° v®eho
         call      far ptr DispAll          ; zobrazen° v®eho
         jmp       short Zapis393

Zapis391:test      byte ptr ds:[TextEPar],bit1+bit2 ; zobrazen° ©†dku/okna ?
         jz        Zapis392                 ; nen° zobrazen° ©†dku/okna
         call      far ptr DispMnu          ; zobrazen° okna
         jmp       short Zapis393

Zapis392:call      DispZNad                 ; zobrazen° nadpisu
         call      far ptr KurEMnu          ; zobrazen° kurzoru

; ------ vstup znaku z kl†vesnice -> BX

Zapis393:call      far ptr InpChar          ; vstup znaku z kl†vesnice -> BX

; ------ menu kl†ves malÇ n†povàdy

         mov       di,offset TxtMnHM1       ; menu kl†ves malÇ n†povàdy
         call      far ptr MenKlHlp         ; obsluha menu kl†ves

; ------ adresa okna -> ES

Zapis394:mov       ax,ds:[si+EdMnuSeg]      ; segment okna
         call      far ptr GetDat           ; adresa segmentu okna

         and       byte ptr ds:[TextEPar],not bit0+bit1+bit2+bit3 ; zru®en° p©°znakñ

         cmp       bl,27
         je        Zapis399                 ; je kl†vesa ESC

; ------ skok na obsluhu funkce

         call      far ptr JumpBX

         dw        3c00h,ZapisUl            ; F2 uloëen°
         dw        4400h,ZapisMn            ; F10 menu
         dw        MousXKod+MousXMP,ZapisMn ; stisk st©edn°ho tlaá°tka=menu F10
         dw        0,Zapis398

; ------ jin† kl†vesa

Zapis398:call      far ptr EditEMnu         ; editace okna
         jmp       Zapis39

; ------ uzav©en° okna editoru ESC

Zapis399:test      byte ptr es:[TextParm],bit1 ; text modifikov†n ?
         jz        Zapis39A                 ; nebyl modifikov†n

; ------ potvrzen°, zda m† bòt uloëen

         mov       si,offset ZUSMnLin
         call      far ptr Lin0Menu         ; volba operace
         jc        Zapis39                  ; p©eru®en° operace
         dec       bx                       ; uloëen° souboru ?
         jnz       Zapis39A                 ; p©eru®en° operace

; ------ uloëen° souboru

         mov       si,offset TextMnu
         call      ZapisUl0                 ; uloëen° souboru
         jnc       Zapis39A
         jmp       Zapis39                  ; chyba

; ------ uzav©en° okna editoru

Zapis39A:call      far ptr ClosMnu          ; uzav©en° okna

; ------ zru®en° segmentu textu

Zapis04: mov       ax,ds:[TextSegm]         ; segment bufferu
         call      far ptr DelSeg           ; zru®en° segmentu
         mov       ds:[TextSegm],ax
         and       byte ptr ds:[ParZvl],not bit7 ; p©°znak editace z†pisn°kem
         ret

EditNOT  ENDP

; ------ uloëen° souboru

ZapisUl: call      ZapisUl0
         jmp       Zapis39

; -----------------------------------------------------------------------------
;        uloëen° souboru okna DS:SI -> CY=chyba, ES=adresa okna
; -----------------------------------------------------------------------------
;˛
ZapisUl0 PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         mov       bp,sp
         sub       sp,256

; ------ test, zda je z†kaz z†pisu do souboru

         mov       ax,ds:[si+EdMnuSeg]
         call      far ptr GetDat           ; adresa segmentu okna
         test      byte ptr es:[TextParm],bit0 ; je z†kaz z†pisu ?
         jz        ZapisUl2                 ; nen° z†kaz z†pisu
         stc                                ; p©°znak chyby operace
         jmp       ZapisUl9                 ; je z†kaz z†pisu

; ------ vytvo©en° vòstupn°ho souboru

ZapisUl2:push      si
         les       si,cs:[EditADR]          ; adresa jmÇna souboru
;         push      ds
;         pop       es
;         mov       si,offset ZapsPath       ; soubor
         call      far ptr ModiWDir         ; aktualizace oken
         call      far ptr CreatFil         ; vytvo©en° souboru
         pop       si

; ------ obnoven° adresy okna -> ES

         pushf
         push      ax
         mov       ax,ds:[si+EdMnuSeg]
         call      far ptr GetDat           ; adresa segmentu okna -> ES
         pop       ax
         popf
         jc        ZapisUl9                 ; byla chyba

; ------ sestaven° a z†pis ©†dku p©ep°naáñ (SI=adresa menu)

         test      byte ptr es:[TextParm],bit3 ; jsou intern° promànnÇ ?
         jz        ZapisUl4                 ; nejsou intern° promànnÇ
         cmp       byte ptr ds:[ZapsTypI],0 ; je z†kaz intern°ch promànnòch ?
         je        ZapisUl4                 ; je z†kaz intern°ch promànnòch

         mov       di,sp                    ; DI <- buffer v z†sobn°ku
         push      es

         push      ss
         pop       es                       ; ES <- segment z†sobn°ku

         push      ax
         mov       ax,ds:[si+EdMnuSeg]
         mov       si,di                    ; SI <- zaá†tek bufferu
         call      far ptr ZapisSwc         ; p©°prava p©ep°naáñ
         pop       ax

         mov       cx,di                    ; CX <- konec textu
         sub       cx,si                    ; CX <- dÇlka textu
         inc       cx
         inc       cx                       ; váetnà koncovÇho CR/LF
         call      far ptr WritFile         ; z†pis ©†dku p©ep°naáñ

         pop       es

; ------ z†pis textu

ZapisUl4:mov       di,TextBBeg              ; zaá†tek textu
         call      far ptr ZapZakod         ; zak¢dov†n° textu
         mov       cx,es:[TextBNum]         ; poáet bajtñ textu
         mov       si,TextBBeg              ; zaá†tek textu
         call      far ptr WritFile         ; z†pis textu

; ------ uzav©en° souboru (zaá†tek textu DI)

         pushf
         call      far ptr ZapDekod         ; dek¢dov†n° textu

         call      far ptr ClosFile         ; uzav©en° souboru
         popf
         jc        ZapisUl9                 ; byla chyba

; ------ p©°znak modifikace INI souboru

         cmp       byte ptr ds:[ZapsTypI],3 ; je konfiguraán° soubor ?
         jne       ZapisUl8                 ; nen° konfiguraán° soubor
         or        byte ptr ds:[StartPar],bit1 ; p©°znak modifikace INI souboru

; ------ p©i operaci OK zru®en° p©°znaku modifikace

ZapisUl8:and       byte ptr es:[TextParm],not bit1 ; zru®en° p©°znaku modifikace
         or        byte ptr ds:[TextEPar],bit2 ; zobrazen° okna -> NC

; ------ n†vrat registrñ

ZapisUl9:mov       sp,bp
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

ZapisUl0 ENDP

; -----------------------------------------------------------------------------
;        p©°prava p©ep°naáñ z†pisn°ku AX do bufferu ES:DI -> DI=konec dat
; -----------------------------------------------------------------------------

ZapisSwc PROC      FAR

; ------ £schova registrñ

         push      ax
         push      dx
         push      si

; ------ adresa okna -> DX

         call      far ptr GetSgAdr         ; adresa okna -> DX

; ------ dek¢dov†n° identifikace

         mov       al,ds:[ZapsTypI]         ; identifik†tor souboru
         mov       si,offset IdntISwT       ; identifikace
         call      far ptr SetTISwc         ; dek¢dov†n° p©ep°naáe

; ------ dek¢dov†n° n†rodn°ho k¢du

         mov       al,ds:[CodePagK]         ; n†rodn° k¢d
         cmp       al,0                     ; je k¢d uráen ?
         je        ZapisSw1                 ; k¢d nen° uráen
         mov       si,offset KodISwcT       ; n†rodn° k¢d
         call      far ptr SetTISwc         ; dek¢dov†n° p©ep°naáe

; ------ dÇlka str†nky

ZapisSw1:mov       ax,ds:[TextEStr]         ; dÇlka str†nky
         mov       si,offset PagISwcT
         call      far ptr SetNISwc         ; dek¢dov†n° p©ep°naáe

; ------ pravò okraj

         mov       ax,ds:[TextEOkr]         ; pravò okraj
         mov       si,offset RghISwcT
         call      far ptr SetNISwc         ; dek¢dov†n° p©ep°naáe

; ------ tabul†tor

         mov       ax,ds:[TextETab]         ; tabul†tor
         mov       si,offset TabISwcT
         call      far ptr SetNISwc         ; dek¢dov†n° p©ep°naáe

; ------ kurzor

         push      dx

         push      es
         mov       es,dx                    ; adresa okna
         mov       ax,es:[TextKPoz]         ; pozice kurzoru na ©†dku
         inc       ax
         mov       dx,es:[TextKLin]         ; ©†dek s kurzorem
         inc       dx
         pop       es

         mov       si,offset CurISwcT
         call      far ptr Set2ISwc         ; dek¢dov†n° p©ep°naáe

         pop       dx

; ------ poá†tek okna

         push      dx

         push      es
         mov       es,dx                    ; adresa okna
         mov       ax,es:[TextTPoz]         ; poá†teán° zobrazen† pozice
         inc       ax
         mov       dx,es:[TextTLin]         ; poá†teán° zobrazenò ©†dek
         inc       dx
         pop       es

         mov       si,offset TopISwcT
         call      far ptr Set2ISwc         ; dek¢dov†n° p©ep°naáe

         pop       dx

; ------ heslo

         push      ds
         cmp       byte ptr ds:[ZapsTypI],2 ; je z†pisn°k ?
         mov       ds,dx                    ; DS <- adresa okna
         ja        ZapisSw2                 ; pro ostatn° je z†kaz hesla
         test      byte ptr ds:[TextParm],bit5 ; je z†kaz hesla ?
         jz        ZapisSw4                 ; nen° z†kaz hesla
ZapisSw2:mov       byte ptr ds:[TextHesN],0 ; zru®en° p©°padnÇho hesla

ZapisSw4:cmp       byte ptr ds:[TextHesN],0 ; soubor uzamáen heslem ?
         pop       ds
         je        ZapisSw6                 ; nen° heslo

         push      di
         push      es
         mov       es,dx                    ; ES <- adresa okna
         mov       di,TextBBeg              ; zaá†tek textu
         call      far ptr ZapisCSm         ; kontroln° souáet z†pisn°ku
         pop       es
         pop       di

         mov       si,offset PswISwcT
         call      far ptr SetNISwc         ; dek¢dov†n° p©ep°naáe

; ------ n†vrat registrñ

ZapisSw6:pop       si
         pop       dx
         pop       ax
         ret

ZapisSwc ENDP

; -----------------------------------------------------------------------------
;        kontroln° souáet textu z†pisn°ku ES:DI -> AX
; -----------------------------------------------------------------------------

ZapisCSm PROC      FAR

; ------ £schova registrñ

         push      di

; ------ kontroln° souáet dat

         xor       ax,ax                    ; st©adaá kontroln°ho souátu
ZapisCS2:cmp       di,es:[0]                ; je dal®° znak ?
         jae       ZapisCS4                 ; nen° dal®° znak
         add       al,es:[di]               ; p©iáten° bajtu
         adc       ah,0                     ; p©enos
         inc       di
         jmp       short ZapisCS2

; ------ n†vrat registrñ

ZapisCS4:pop       di
         ret

ZapisCSm ENDP

; -----------------------------------------------------------------------------
;        F10: menu
; -----------------------------------------------------------------------------
;˛
ZapisMn: push      cs
         call      near ptr ZapisMnX
         jc        ZapisMX1
         jmp       Zapis394                 ; je kl†vesa v BX

ZapisMX1:jmp       Zapis39                  ; p©eru®en° operace

ZapisMnX PROC      FAR

         push      si
         mov       si,offset ZZMMVert       ; menu
         call      far ptr CentMenu         ; vyst©edàn° okna
         call      ZapisSMn                 ; p©°prava p©ep°naáñ
         call      far ptr VertMenu         ; obsluha menu
         pop       si
         stc                                ; p©°znak p©eru®en° operace
         ret

ZapisMnX ENDP

; ------ zad†n° pravÇho okraje

ZapisMn2 PROC      FAR

         push      ax
         push      es

         push      ds
         pop       es                       ; ES <- datovò segment

         mov       bx,9999                  ; maxim†ln° hodnota
         mov       ch,1                     ; minim†ln° hodnota á°sla
         mov       cl,4                     ; dÇlka textu
         mov       dx,word ptr ds:[si+MnuPoz] ; pozice a ©†dek menu
         add       dx,15*HI + 14            ; pozice relativnà
         mov       di,offset ZZMMVPl2       ; buffer k dek¢dov†n° á°sla
         push      si
         mov       si,offset ZZMMVHl2       ; n†povàda
         call      far ptr MenuNum          ; zad†n° á°sla
         pop       si
         mov       ds:[TextEOkr],ax         ; novò pravò okraj
         jmp       short ZapisM32

ZapisMn2 ENDP

; ------ zad†n° pozic na tabul†tor

ZapisMn3 PROC      FAR

         push      ax
         push      es

         push      ds
         pop       es                       ; ES <- datovò segment

         mov       bx,9999                  ; maxim†ln° hodnota á°sla
         mov       ch,1                     ; minim†ln° hodnota á°sla
         mov       cl,4                     ; dÇlka textu
         mov       dx,word ptr ds:[si+MnuPoz] ; pozice a ©†dek menu
         add       dx,16*HI + 14            ; pozice relativnà
         mov       di,offset ZZMMVPl3       ; buffer k dek¢dov†n° á°sla
         push      si
         mov       si,offset ZZMMVHl3       ; n†povàda
         call      far ptr MenuNum          ; zad†n° á°sla
         pop       si
         mov       ds:[TextETab],ax         ; novò poáet pozic na tabul†tor

ZapisM32:call      far ptr DispAll          ; novÇ zobrazen° v®eho

         pop       es
         pop       ax
         ret

ZapisMn3 ENDP

; ------ zad†n° ©†dkñ na str†nku

ZapisMn4 PROC      FAR

         push      ax
         push      es

         push      ds
         pop       es

         mov       bx,9999                  ; maxim†ln° hodnota á°sla
         mov       ch,1                     ; minim†ln° hodnota á°sla
         mov       cl,4                     ; dÇlka textu
         mov       dx,word ptr ds:[si+MnuPoz] ; pozice a ©†dek menu
         add       dx,17*HI + 14            ; pozice relativnà
         mov       di,offset ZZMMVPl4       ; buffer k dek¢dov†n° á°sla
         push      si
         mov       si,offset ZZMMVHl4       ; n†povàda
         call      far ptr MenuNum          ; zad†n° á°sla
         pop       si
         mov       ds:[TextEStr],ax         ; poáet ©†dkñ na str†nku
         jmp       short ZapisM32

ZapisMn4 ENDP

; ------ skok na funkci

ZapisMn0 PROC      FAR

         cmp       bl," "                   ; je mezera (p©ep°naá "zobrazen°")
         jne       ZapisMn1

         push      si
         mov       bx,4300h                 ; F9: zobrazen° bloku
         mov       si,offset TextMnu        ; menu textu
         call      far ptr EditEMnu         ; editace okna
         pop       si
         call      ZapisSMn                 ; p©°prava p©ep°naáñ
         call      far ptr DispAll          ; zobrazen° v®eho
         ret

ZapisMn0 ENDP

ZapisMn1 PROC      FAR

         add       sp,4                     ; zru®en° n†vratovÇ adresy
         mov       bx,ds:[si+MnuAkt]        ; aktivn° zvolen† poloëka
         call      far ptr ClosMnu          ; uzav©en° okna menu
         pop       si                       ; n†vrat SI
         shl       bx,1
         mov       bx,cs:[bx+ZapisMnT-2]    ; n†hrada kl†vesou
         clc
         ret

ZapisMn1 ENDP

ZapisMnT label     word                     ; tabulka kl†ves
         dw        3d00h                    ; F3: zaá†tek bloku
         dw        3e00h                    ; F4: konec bloku
         dw        3f00h                    ; F5: kopie bloku
         dw        4000h                    ; F6: p©esun bloku
         dw        4200h                    ; F8: zru®en° bloku
         dw        4300h                    ; F9: zobrazenò blok
         dw        5800h                    ; Shift-F5 naáti blok
         dw        5600h                    ; Shift-F3 zapi® blok
         dw        3c00h                    ; F2: uloëen° souboru
         dw        4100h                    ; F7: hled†n° textu
         dw        5a00h                    ; Shift-F7: n†hrada textu
         dw        260ch                    ; Ctrl-L pokraáov†n° v hled†n°
         dw        3002h                    ; Ctrl-B form†tov†n° odstavce
         dw        5c00h                    ; Ctrl-OC (Shift-F9) vyst©edàn° ©†dku
         dw        0
         dw        0
         dw        0
         dw        5900h                    ; Ctrl-KP (Shift-F6) tisk
         dw        4567h                    ; zad†n° hesla (nesmysln† kl†vesa)

; -----------------------------------------------------------------------------
;        p©°prava p©ep°naáñ menu DS:SI editoru
; -----------------------------------------------------------------------------

ZapisSMn PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      dx
         push      si
         push      es

; ------ nulov†n° blokovac° tabulky

         mov       ax,ds:[si+EdMnuSeg]      ; segment editoru
         mov       cx,ds:[si+MnuNum]        ; poáet poloëek
         mov       si,ds:[si+MnuBlk]        ; blokovac° tabulka
         push      si
ZapisSM2:and       byte ptr ds:[si],not bit1 ; poloëka povolena
         inc       si
         loop      ZapisSM2
         pop       si

; ------ test, zda je blok vypnut

         mov       byte ptr ds:[ZZMMVSwc],-1 ; blok je zapnutò

         call      far ptr GetDat           ; adresa bufferu

         test      byte ptr es:[TextParm],bit2 ; je blok zapnut ?
         jnz       ZapisSM5                 ; blok je zapnut

ZapisSM4:inc       byte ptr ds:[ZZMMVSwc]   ; vypnut° p©ep°naáe
         or        byte ptr ds:[si+2],bit1  ; z†kaz kopie bloku
         or        byte ptr ds:[si+3],bit1  ; z†kaz p©esunu bloku
         or        byte ptr ds:[si+4],bit1  ; z†kaz ru®en° bloku
         or        byte ptr ds:[si+7],bit1  ; z†kaz uloëen° bloku

; ------ test, zda byl text modifikov†n

ZapisSM5:test      byte ptr es:[TextParm],bit1 ; modifikace ?
         jnz       ZapisSM6                 ; byl modifikov†n
         or        byte ptr ds:[si+8],bit1  ; z†kaz uloëen° souboru

; ------ test, zda je z†kaz z†pisu

ZapisSM6:test      byte ptr es:[TextParm],bit0 ; je z†kaz z†pisu ?
         jz        ZapisSM7                 ; nen° z†kaz z†pisu
         or        byte ptr ds:[si+2],bit1  ; z†kaz kopie bloku
         or        byte ptr ds:[si+3],bit1  ; z†kaz p©esunu bloku
         or        byte ptr ds:[si+4],bit1  ; z†kaz ru®en° bloku
         or        byte ptr ds:[si+6],bit1  ; z†kaz naáten° bloku
         or        byte ptr ds:[si+10],bit1 ; z†kaz n†hrady textu
         or        byte ptr ds:[si+12],bit1 ; z†kaz form†tov†n° textu
         or        byte ptr ds:[si+13],bit1 ; z†kaz centrov†n° ©†dku

; ------ indikace hesla

ZapisSM7:cmp       byte ptr ds:[ZapsTypI],2 ; je z†pisn°k ?
         ja        ZapsSM71                 ; pro ostatn° je z†kaz
         test      byte ptr es:[TextParm],bit5 ; je z†kaz hesla ?
         jz        ZapsSM72                 ; nen° z†kaz hesla
ZapsSM71:or        byte ptr ds:[si+19],bit1 ; z†kaz hesla
         mov       byte ptr es:[TextHesN],0 ; zru®en° hesla

ZapsSM72:mov       bx,offset ZZMnVPlH
         mov       word ptr ds:[bx],"NA"
         mov       byte ptr ds:[bx+2],"O"
         cmp       byte ptr es:[TextHesN],0 ; je heslo ?
         jne       ZapisSM8
         mov       word ptr ds:[bx],"n "
         mov       byte ptr ds:[bx+2],"e"

; ------ pravò okraj

ZapisSM8:push      ds
         pop       es
         mov       ax,ds:[TextEOkr]         ; pravò okraj
         mov       di,offset ZZMMVPl2+4
         call      ZapisSMD                 ; dek¢dov†n° á°sla

; ------ pozic na tabul†tor

         mov       ax,ds:[TextETab]         ; tabul†tor
         mov       di,offset ZZMMVPl3+4
         call      ZapisSMD                 ; dek¢dov†n° á°sla

; ------ poáet ©†dkñ na str†nku

         mov       ax,ds:[TextEStr]         ; str†nka
         mov       di,offset ZZMMVPl4+4
         call      ZapisSMD                 ; dek¢dov†n° á°sla

; ------ n†vrat registrñ

         pop       es
         pop       si
         pop       dx
         pop       bx
         pop       ax
         ret

ZapisSMn ENDP

; ------ dek¢dov†n° á°sla AX do bufferu DI

ZapisSMD:mov       word ptr ds:[di-4],"  "
         mov       byte ptr ds:[di-2]," "
         xor       dx,dx
         xor       bx,bx
         call      far ptr DekNumD          ; dek¢dov†n° á°sla
         ret

; *****************************************************************************
;
;                         Editace datovÇho bloku
;
; *****************************************************************************
;˛
; -----------------------------------------------------------------------------
;                               OpenText
;                    inicializace bufferu editace textu
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP: CY=nedostatek pamàti
;         AX=segment bufferu
;         ES:DI=adresa bufferu k naáten° textu
;         CX=maxim†ln° velikost textu k naáten°
; -----------------------------------------------------------------------------

OpenText PROC      FAR

; ------ £schova registrñ

         push      bx

; ------ inicializace parametrñ editoru

         mov       byte ptr ds:[TextForP],0 ; nen° oznaáov†n° bloku
         mov       byte ptr ds:[TextEPar],0 ; je INSERT

; ------ vytvo©en° segmentu

         mov       bx,4000                  ; minim†lnà asi tak velikost
         call      far ptr CreatDat         ; vytvo©en° bufferu
         jc        OpenTxt9                 ; chyba pamàti
         call      far ptr GetDat           ; ES <- adresa bufferu

; ------ inicializace parametrñ bufferu

         push      ax                       ; segment bufferu
         xor       di,di                    ; DI <- 0 zaá†tek bufferu
         mov       ax,bx                    ; AX <- velikost dat v bufferu
         stosw                              ; velikost dat v bufferu
         mov       cx,TextBBeg-2            ; velikost z†hlav° - 2
         xor       ax,ax                    ; AX <- nulovac° slovo
         cld
         rep       stosb                    ; vymaz†n° z†hlav°
         mov       cx,bx                    ; CX <- velikost bufferu pro data
         sub       cx,di                    ; CX <- zbytek pro naáten° textu
         pop       ax

; ------ n†vrat registrñ

         clc                                ; p©°znak operace OK
OpenTxt9:pop       bx
         ret

OpenText ENDP

; -----------------------------------------------------------------------------
;        inicializace textu v bufferu AX (p©°prava p©ep°naáñ z textu) -> CY=p©eru®en° operace (p©i zad†n° hesla)
; (mus° se volat po naáten° souboru a zmen®en° segmentu, ale p©ed otev©en°m okna)
; -----------------------------------------------------------------------------

InitText PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es

; ------ adresa bufferu -> ES

         call      far ptr GetDat           ; adresa segmentu
         xchg      ax,bp                    ; BP <- á°slo segmentu

; ------ p©°prava aktu†ln°ch parametrñ

         mov       ax,ds:[TexIEOkr]         ; pravò okraj
         mov       ds:[TextEOkr],ax
         mov       ax,ds:[TexIETab]         ; tabul†tor
         mov       ds:[TextETab],ax
         mov       ax,ds:[TexIEStr]         ; dÇlka str†nky
         mov       ds:[TextEStr],ax

; ------ implicitn° pouëit° intern°ch promànnòch

         and       byte ptr es:[TextParm],not bit3  ;+bit5 ; nejsou intern° promànnÇ
         test      byte ptr es:[TextParm],bit4 ; nepouë°t intern° promànnÇ ?
         jnz       InitTxt2                 ; nepouë°t intern° promànnÇ
         or        byte ptr es:[TextParm],bit3 ; jsou intern° promànnÇ

; ------ test, zda je novò soubor

InitTxt2:cmp       word ptr es:[TextBNum],0 ; je nàco v bufferu ?
         jne       Inittxt3                 ; v bufferu je nàjakò text
InitTx28:jmp       InitTxt8                 ; v bufferu nic nen° - novò soubor

; ------ nalezen° identifikaán°ho parametru "IDENT="

InitTxt3:mov       di,TextBBeg              ; zaá†tek textu
         mov       si,offset IdntISwT       ; p©ep°naá
         call      far ptr GetTISwc         ; naáten° p©ep°naáe
         jc        InitTx28                 ; nen° p©ep°naá

         cmp       al,2                     ; prozatimn° identifikace "NOTES"
         jne       InitTx31
         dec       ax                       ; n†hrada identifik†torem "NOTEPAD"

InitTx31:mov       ds:[ZapsTypI],al         ; £schova á°sla typu souboru
         or        byte ptr es:[TextParm],bit3 ; jsou intern° promànnÇ

; ------ naáten° p©°znaku hesla

         mov       si,offset PswISwcT       ; p©ep°naá hesla
         call      far ptr GetNISwc         ; naáten° p©ep°naáe hesla
         jc        InitTxt5                 ; nen° uzamáen° heslem
         mov       ds:[TextPSum],ax         ; kontroln° souáet pro heslo

; ------ nalezen° adresy n†sleduj°c°ho ©†dku -> BX

         mov       bx,di                    ; BX <- ukazatel textu
InitTx32:cmp       bx,es:[0]                ; je konec textu ?
         jae       InitTx36                 ; je konec textu
         cmp       word ptr es:[bx],CR + LF*HI
         je        InitTx34
         cmp       word ptr es:[bx],LF + CR*HI
         je        InitTx34
         cmp       byte ptr es:[bx],LF
         je        InitTx35
         cmp       byte ptr es:[bx],CR
         je        InitTx35
         inc       bx
         jmp       short InitTx32

InitTx34:inc       bx
InitTx35:inc       bx

; ------ test, zda je heslo jië v bufferu zad†no

InitTx36:cmp       byte ptr es:[TextHesN],0 ; je heslo jië v bufferu ?
         jne       InitTxt4                 ; heslo je jië zad†no v bufferu

; ------ zad†n° textu hesla

InitTx42:test      byte ptr es:[TextParm],bit6 ; nem† se heslo ë†dat ?
         stc                                ; p©°znak p©eru®en°
         jnz       InitTx44                 ; heslo se nem† ë†dat
         call      EZapHesl                 ; zad†n° hesla
         jnc       InitTxt4                 ; heslo zad†no OK
InitTx44:jmp       InitTxt9                 ; p©eru®en° operace

; ------ odk¢dov†n° textu ES:BX

InitTxt4:push      di
         mov       di,bx                    ; DI <- adresa textu
         call      far ptr ZapDekod         ; odk¢dov†n° textu DI
         call      far ptr ZapisCSm         ; kontroln° souáet textu DI
         pop       di
         cmp       ax,ds:[TextPSum]         ; souhlas° kontroln° souáet ?
         je        InitTxt5                 ; kontroln° souáet souhlas° OK
         cmp       word ptr es:[0],-512     ; je buffer p©eplnànò ?
         jae       InitTxt5                 ; moën† se soubor nenaáetl celò
         push      di
         mov       di,bx                    ; DI <- adresa textu
         call      far ptr ZapZakod         ; zak¢dov†n° struktury zpàt
         pop       di
         jmp       short InitTx42           ; kontroln° souáet nesouhlas° - znovu

; ------ naáten° n†rodn°ho k¢du

InitTxt5:mov       si,offset KodISwcT       ; n†rodn° k¢d
         call      far ptr GetTISwc         ; naáten° p©ep°naáe
         jc        InitTx52                 ; nen° p©ep°naá
         cmp       al,ds:[CodePagK]         ; je pot©eba zmànit k¢d ?
         je        InitTx52                 ; nen° pot©eba zmànit k¢d
         cmp       byte ptr ds:[CodePagK],0 ; je k¢d uráen ?
         je        InitTx52                 ; k¢d nen° uráen

; ------ konverze n†rodn°ho k¢du

         xchg      ax,cx                    ; CL <- aktu†ln° k¢d
         mov       dl,bit1                  ; p©°prava
         shl       dl,cl                    ; DL = aktu†ln° k¢d
         mov       cl,ds:[CodePagK]         ; poëadovan† k¢dov† str†nka
         mov       dh,bit1                  ; p©°prava
         shl       dh,cl                    ; DH = poëadovanò k¢d
         mov       cx,es:[TextBNum]         ; poáet bajtñ v bufferu
         mov       si,di                    ; SI <- zaá†tek textu
         call      far ptr KonvFnt          ; konverze fontñ

; ------ naáten° dÇlky str†nky

InitTx52:mov       si,offset PagISwcT       ; p©ep°naá
         call      far ptr GetNISwc         ; naáten° p©ep°naáe
         jc        InitTx54                 ; p©ep°naá nenalezen
         or        ax,ax
         jz        InitTx54                 ; dÇlka str†nky nezad†na
         cmp       ax,9999                  ; maxim†ln° hodnota
         jbe       InitTx53                 ; je to OK
         mov       ax,9999                  ; omezen° dÇlky str†nky
InitTx53:mov       ds:[TextEStr],ax         ; poáet ©†dkñ na str†nku

; ------ naáten° poátu pozic na tabul†tor

InitTx54:mov       si,offset TabISwcT       ; p©ep°naá
         call      far ptr GetNISwc         ; naáten° p©ep°naáe
         jc        InitTx56                 ; p©ep°naá nenalezen
         or        ax,ax
         jz        InitTx56                 ; poáet pozic na tabul†tor nezad†n
         cmp       ax,9999                  ; maxim†ln° hodnota
         jbe       InitTx55                 ; je to OK
         mov       ax,9999                  ; omezen° poátu pozic
InitTx55:mov       ds:[TextETab],ax         ; poáet pozic na tabul†tor

; ------ naáten° pravÇho okraje

InitTx56:mov       si,offset RghISwcT       ; p©ep°naá
         call      far ptr GetNISwc         ; naáten° p©ep°naáe
         jc        InitTx58                 ; p©ep°naá nenalezen
         or        ax,ax
         jz        InitTx58                 ; pravò okraj nezad†n
         cmp       ax,9999                  ; maxim†ln° hodnota
         jbe       InitTx57                 ; je to OK
         mov       ax,9999                  ; omezen° pravÇho okraje
InitTx57:mov       ds:[TextEOkr],ax         ; pravò okraj

; ------ naáten° kurzoru

InitTx58:mov       si,offset CurISwcT
         call      far ptr Get2ISwc         ; naáten° p©ep°naáe
         jc        InitTx5A
         or        ax,ax
         jz        InitTx59
         dec       ax
         mov       es:[TextKPoz],ax         ; pozice kurzoru na ©†dku

InitTx59:or        dx,dx
         jz        InitTx5A
         dec       dx
         mov       es:[TextKLin],dx         ; ©†dek s kurzorem

; ------ naáten° poá†tku

InitTx5A:mov       si,offset TopISwcT
         call      far ptr Get2ISwc         ; naáten° p©ep°naáe
         jc        InitTx5C
         or        ax,ax
         jz        InitTx5B
         dec       ax
         mov       es:[TextTPoz],ax         ; zobrazenò poá†tek

InitTx5B:or        dx,dx
         jz        InitTx5C
         dec       dx
         mov       es:[TextTLin],dx         ; ©†dek s poá†tkem

; ------ zru®en° ©†dku s p©ep°naái

InitTx5C:mov       ax,bp                    ; AX <- á°slo segmentu
         call      far ptr DelLISwc         ; zru®en° ©†dku s parametry
         sub       es:[TextBNum],cx         ; sn°ëen° poátu bajtñ v bufferu

; ------ n†vrat registrñ

InitTxt8:clc
InitTxt9:pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

InitText ENDP

; -----------------------------------------------------------------------------
;        konverze tabul†torñ na mezery (okno z†pisn°ku AX)
; -----------------------------------------------------------------------------

ZapTbSp  PROC      NEAR

; ------ £schova registrñ

         push      cx
         push      dx
         push      di
         push      es

; ------ p©°prava ukazatelñ

         call      far ptr GetDat           ; adresa bufferu -> ES
         mov       di,TextBBeg              ; zaá†tek textu

; ------ inicializace ukazatele pozice

ZapTbSp2:xor       dx,dx                    ; DX <- 0 ukazatel pozice na ©†dku

; ------ test, zda bude dal®° znak

ZapTbSp4:cmp       di,es:[TextByts]         ; bude dal®° bajt ?
         jae       ZapTbSp8                 ; nen° dal®° bajt

; ------ test, zda dal®° znak je tabul†tor

         cmp       byte ptr es:[di],TAB     ; je to tabul†tor ?
         je        ZapTbSp6                 ; je to tabul†tor
         inc       di                       ; zvò®en° ukazatele textu
         cmp       byte ptr es:[di-1],CR    ; byl znak CR ?
         je        ZapTbSp4                 ; pozice se nezvò®°
         cmp       byte ptr es:[di-1],LF    ; byl znak LF ?
         je        ZapTbSp2                 ; nulov†n° ukazatele pozice
         inc       dx                       ; jinak zvò®en° ukazatele pozice
         jmp       short ZapTbSp4           ; dal®° znak

; ------ poáet bajtñ k vloëen° -> CX

ZapTbSp6:mov       cx,dx                    ; CX <- aktu†ln° pozice
         add       cx,8                     ; dal®° pozice
         and       cl,not 7                 ; zarovn†n° na tabulaán° pozici
         sub       cx,dx                    ; poáet pozic
         dec       cx                       ; bez 1 pozice
         jz        ZapTbSp7                 ; nen° co vkl†dat

; ------ vytvo©en° m°sta k vloëen° mezer

         call      far ptr InsDat           ; vytvo©en° m°sta
         jnc       ZapTbSp7                 ; operace OK
         xor       cx,cx                    ; nic se neuvolnilo
ZapTbSp7:inc       cx                       ; n†vrat poátu bajtñ k vymaz†n°

; ------ vymaz†n° m°sta mezerami

         cld
         add       dx,cx                    ; zvò®en° ukazatele pozice
         push      ax
         mov       al," "                   ; vkl†dan† mezera
         rep       stosb                    ; vloëen° mezer
         pop       ax
         jmp       short ZapTbSp4           ; dal®° znak

; ------ novò poáet bajtñ v bufferu

ZapTbSp8:sub       di,TextBBeg              ; dÇlka textu
         mov       es:[TextBNum],di         ; novò poáet bajtñ v bufferu

; ------ n†vrat registrñ

         pop       es
         pop       di
         pop       dx
         pop       cx
         ret

ZapTbSp  ENDP

; -----------------------------------------------------------------------------
;        inicializace okna editoru textu DS:SI
; -----------------------------------------------------------------------------

InitEMnu PROC      FAR

         push      ax
         push      es

         mov       al,ds:[Pozic]            ; poáet pozic na ©†dek
         mov       ds:[si+MnuSir],al        ; ®°©ka okna
         mov       al,ds:[Radku]            ; poáet ©†dkñ displeje
         dec       ax
;         sub       al,4
         mov       ds:[si+MnuVys],al        ; vò®ka okna
         mov       word ptr ds:[si+MnuPoz],0 ; poá†teán° ©†dek a pozice

         mov       ax,ds:[si+EdMnuSeg]      ; segment okna
         call      far ptr GetDat           ; adresa okna

         call      IniTLSum                 ; spoáten° poátu ©†dkñ v bufferu
         call      IniTKLin                 ; inicializace ©†dku s kurzorem
         call      IniTTLin                 ; inicializace poá†teán°ho ©†dku

         pop       es
         pop       ax

;         call      far ptr CentMenu         ; vyst©edàn° okna
         ret

InitEMnu ENDP

; -----------------------------------------------------------------------------
;        zobrazen° okna editoru textu DS:SI
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) definice okna
;                   SS:[BP-4] (2) segment okna
;                   SS:[BP-6] (2) adresa segmentu okna
;                   SS:[BP-7] (1) ukazatel ©†dku na displeji
;                   SS:[BP-8] (1) poá†teán° pozice okna
;                   SS:[BP-9] (1) á°taá ©†dkñ k zobrazen°
;                   SS:[BP-10] (1) ®°©ka okna - 2
;                   SS:[BP-12] (2) hladina k zobrazen° okna
;                   SS:[BP-14] (2) ukazatel adresy textu
;                   SS:[BP-16] (2) á°taá zbylòch znakñ textu
;                   SS:[BP-18] (2) poá†teán° pozice ©†dku
;                   SS:[BP-20] (2) ukazatel á°sla ©†dku
; -----------------------------------------------------------------------------
;˛
DispEMnu PROC      FAR

; ------ korekce textu, zobrazen° nadpisu a r†mu

         call      far ptr KorEMnu          ; korekce zobrazen° okna
         call      DispZNad                 ; zobrazen° nadpisu
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
         sub       sp,20

; ------ inicializace lok†ln°ch promànnòch

         mov       ss:[bp-2],si             ; adresa definice okna
         mov       ax,ds:[si+EdMnuSeg]      ; segment okna
         mov       ss:[bp-4],ax             ; segment okna
         call      far ptr GetDat           ; adresa okna
         mov       ss:[bp-6],es             ; adresa okna
         mov       ax,word ptr ds:[si+MnuPoz] ; ©†dek a pozice okna
         add       ah,2                     ; poá†teán° ©†dek
         mov       ss:[bp-8],ax             ; ukazatel pozice a ©†dku
         mov       ax,word ptr ds:[si+MnuSir] ; ®°©ka a vò®ka okna
         sub       ax,302h                  ; oprava ®°©ky a vò®ky
         mov       ss:[bp-10],ax            ; ®°©ka a vò®ka okna
         mov       ah,0
         inc       ax
         inc       ax                       ; ®°©ka ©†dku okna
         shl       ax,1                     ; poáet bajtñ na buffer ©†dku
         sub       sp,ax                    ; m°sto pro ©†dek
         mov       al,ds:[si+MnuLev]        ; hladina k zobrazen°
         mov       ah,0
         mov       ss:[bp-12],ax            ; hladina k zobrazen°
         mov       ax,es:[TextTAdr]         ; adresa prvn°ho ©†dku
         add       ax,TextBBeg              ; adresa prvn°ho ©†dku
         mov       ss:[bp-14],ax            ; ukazatel textu
         mov       ax,es:[TextBNum]         ; poáet bajtñ v bufferu
         sub       ax,es:[TextTAdr]         ; poáet zbylòch znakñ v bufferu
         mov       ss:[bp-16],ax            ; á°taá zbylòch znakñ textu
         mov       ax,es:[TextTPoz]         ; poá†teán° pozice ©†dku
         mov       ss:[bp-18],ax            ; poá†teán° pozice okna
         mov       ax,es:[TextTLin]         ; poá†teán° ©†dek
         mov       ss:[bp-20],ax            ; ukazatel á°sla ©†dku

; ------ levò okraj ©†dku

DispEMn2:push      ss
         pop       es
         mov       di,sp                    ; DI <- buffer ©†dku
         mov       ah,ds:[ColMnu1R]         ; bàën† barva
         mov       al,"≥"                   ; "≥"
         stosw                              ; uloëen° levÇho okraje

; ------ p©°prava parametrñ bloku

         xor       bx,bx                    ; ®°©ka bloku (0=nen°)
         xor       dx,dx                    ; pravò okraj bloku
         mov       ch,0
         mov       cl,ss:[bp-10]            ; ®°©ka okna - 2

         mov       es,ss:[bp-6]             ; adresa segmentu okna
         test      byte ptr es:[TextParm],bit2 ; je blok zapnut ?
         jz        DispEM28                 ; blok nen° zapnut

; ------ test, zda je ©†dek mimo bloku

         mov       ax,ss:[bp-20]            ; á°slo ©†dku
         cmp       ax,es:[TextBELn]         ; je za koncem bloku ?
         ja        DispEM28                 ; je za koncem bloku
         cmp       ax,es:[TextBBLn]         ; je p©ed zaá†tkem bloku ?
         jb        DispEM28                 ; je p©ed zaá†tkem bloku

; ------ omezen° poá†tku bloku

         xchg      cx,bx                    ; CX=levò okraj 0, BX=®°©ka bloku
         jne       DispEM24                 ; nen° poá†teán° ©†dek

         mov       ax,es:[TextBBPz]         ; pozice zaá†tku bloku
         sub       ax,es:[TextTPoz]         ; offset od poá†tku bloku
         jbe       DispEM24                 ; nen° pravò okraj

         cmp       ax,bx                    ; je del®° neë ©†dek ?
         jb        DispEM22                 ; dÇlka je OK
         mov       ax,bx                    ; omezen° dÇlky poá†tku
DispEM22:xchg      ax,cx                    ; CX <- levò okraj
         sub       bx,cx                    ; sn°ëen° ®°©ky bloku

; ------ omezen° konce bloku

DispEM24:mov       ax,ss:[bp-20]            ; á°slo ©†dku
         cmp       ax,es:[TextBELn]         ; je p©ed ©†dkem konce bloku ?
         jne       DispEM27                 ; nen° ©†dek konce bloku

         mov       ax,es:[TextBEPz]         ; pozice konce bloku
         sub       ax,es:[TextTPoz]         ; offset od zaá†tku bloku
         jbe       DispEM25                 ; blok se nezobraz°

         sub       ax,cx                    ; odeáten° poá†tku
         jbe       DispEM25                 ; blok se nezobraz°
         sub       ax,bx
         jb        DispE242
         xor       ax,ax
DispE242:neg       ax
         jmp       short DispEM26

; ------ blok se nezobraz° (je p©ed zobrazenòm poá†tkem)

DispEM25:mov       ax,bx                    ; AX <- omezen° pravÇho okraje
DispEM26:sub       bx,ax                    ; sn°ëen° ®°©ky bloku
         add       dx,ax                    ; DX <- pravò okraj

; ------ vymaz†n° ©†dku p©ed zaá†tkem bloku

DispEM27:push      ss
         pop       es                       ; ES <- segment z†sobn°ku
         mov       ah,ds:[ColText1]         ; bàën† barva textu
         mov       al," "
         rep       stosw                    ; levò okraj bloku

; ------ vymaz†n° vnit©ku bloku

         mov       ah,ds:[ColText2]         ; barva bloku
         mov       cx,bx                    ; ®°©ka bloku
         rep       stosw                    ; zobrazen° bloku

; ------ vymaz†n° zbytku ©†dku (za blokem)

         mov       cx,dx                    ; pravò okraj bloku
DispEM28:mov       ah,ds:[ColText1]         ; bàën† barva textu
         mov       al," "

         push      ss
         pop       es                       ; ES <- segment bufferu
         rep       stosw                    ; vymaz†n° zbytku ©†dku

         mov       ah,ds:[ColMnu1L]         ; bàën† barva
         mov       al,"≥"                   ; "≥"
         stosw                              ; uloëen° pravÇho okraje

; ------ p©°prava k dek¢dov†n° ©†dku

         mov       di,sp                    ; DI <- buffer ©†dku
         inc       di
         inc       di                       ; zaá†tek textu na ©†dku

         push      ds

         mov       ds,ss:[bp-6]             ; adresa segmentu okna
         mov       si,ss:[bp-14]            ; ukazatel textu
         mov       cx,ss:[bp-16]            ; á°taá zbylòch znakñ textu
         mov       dl,ss:[bp-10]            ; ®°©ka okna - 2
         cld

; ------ nalezen° zaá†tku textu ©†dku

         mov       bx,ss:[bp-18]            ; poá†teán° pozice ©†dku
         or        bx,bx                    ; je zaá†tek ©†dku ?
         jz        DispEMn5                 ; je zaá†tek ©†dku
DispEMn4:jcxz      DispEMn8                 ; konec textu
         lodsb                              ; naáten° znaku
         dec       cx                       ; zn°ëen° á°taáe znakñ
         cmp       al,CR                    ; je CR ?
         je        DispEM71                 ; je CR
DispEM41:dec       bx                       ; á°taá pozic
         jnz       DispEMn4                 ; dal®° znak

; ------ dek¢dov†n° textu ©†dku

DispEMn5:jcxz      DispEMn8                 ; konec textu
         lodsb
         dec       cx
         cmp       al,CR                    ; je CR ?
         je        DispEM72                 ; je CR
DispEM51:stosb
         inc       di                       ; p©eskoáen° barvy
         dec       dl                       ; á°taá pozic
         jnz       DispEMn5                 ; dal®° znak

; ------ nalezen° konce ©†dku

DispEMn6:jcxz      DispEMn8                 ; konec textu
         lodsb
         dec       cx
         cmp       al,CR
         jne       DispEMn6
         cmp       byte ptr ds:[si],LF
         jne       DispEMn6                 ; nen° LF
         jmp       short DispEM76

; ------ test, zda je konec ©†dku CR/LF

DispEM71:cmp       byte ptr ds:[si],LF      ; bude dal®° znak LF ?
         jne       DispEM41                 ; dal®° znak nen° LF

DispEM72:cmp       byte ptr ds:[si],LF      ; bude dal®° znak LF ?
         jne       DispEM51                 ; bude dal®° znak LF

DispEM76:jcxz      DispEMn8
         inc       si                       ; p©eskoáen° znaku LF
         dec       cx                       ; sn°ëen° á°taáe znakñ

; ------ ukonáen° dek¢dov†n° ©†dku

DispEMn8:mov       ss:[bp-16],cx            ; á°taá zbylòch znakñ textu
         mov       ss:[bp-14],si            ; novò ukazatel textu

         pop       ds

; ------ zobrazen° pravÇho okraje

         mov       si,sp                    ; buffer v z†sobn°ku
         mov       ch,0
         mov       cl,ss:[bp-10]            ; ®°©ka ©†dku - 2
         mov       ax,ds:[TextEOkr]         ; pravò okraj
         sub       ax,ss:[bp-18]            ; offset od poá†teán° pozice
         jb        DispEM84                 ; je p©ed poá†tkem

         cmp       ax,cx                    ; je za pravòm okrajem ?
         jae       DispEM84                 ; je za pravòm okrajem

         inc       ax                       ; p©eskoáen° pravÇho okraje
         shl       ax,1                     ; offset v bufferu
         push      si
         add       si,ax                    ; adresa v bufferu
         mov       al,ds:[ColText5]         ; barva okraje
         mov       es:[si+1],al             ; nastaven° barvy okraje
         pop       si

; ------ zobrazen° p©elomu str†nky

DispEM84:mov       ax,ss:[bp-20]            ; ukazatel á°sla ©†dku
         or        ax,ax                    ; je to prvn° ©†dek ?
         jz        DispEM86                 ; je to prvn° ©†dek
         xor       dx,dx                    ; DX <- 0
         div       word ptr ds:[TextEStr]   ; vòpoáet ©†dku na str†nce
         or        dx,dx                    ; je to prvn° ©†dek ?
         jnz       DispEM86                 ; nen° to prvn° ©†dek

         mov       ah,ds:[ColText6]         ; barva p©elomu str†nky
         mov       al,16                    ; levò okraj
         mov       es:[si],ax               ; levò okraj p©elomu

         mov       al,17                    ; pravò okraj
         push      si
         add       si,cx
         add       si,cx                    ; pravò okraj
         mov       es:[si+2],ax             ; pravò okraj
         pop       si

; ------ zobrazen° ©†dku

DispEM86:inc       cx
         inc       cx
         mov       ax,ss:[bp-12]            ; hladina k zobrazen° okna
         mov       dx,ss:[bp-8]             ; ©†dek a pozice
         call      far ptr DispMStr         ; zobrazen° ©†dku

; ------ p©°prava pro dal®° ©†dek

         inc       word ptr ss:[bp-20]      ; zvò®en° ukazatele á°sla ©†dku
         inc       byte ptr ss:[bp-7]       ; zvò®en° ©†dku na displeji
         dec       byte ptr ss:[bp-9]       ; á°taá ©†dkñ k zobrazen°
         jz        DispEMn9                 ; jsou jië v®echny ©†dky
         jmp       DispEMn2                 ; dal®° ©†dek

; ------ n†vrat registrñ

DispEMn9:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         call      far ptr KurEMnu          ; zobrazen° kurzoru
         ret

DispEMnu ENDP

; -----------------------------------------------------------------------------
;        Zobrazen° ©†dku nadpisu editoru DS:SI
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) ©†dek a pozice na displeji
;                   SS:[BP-4] (2) adresa definice menu
;                   SS:[BP-6] (2) á°slo segmentu okna
;                   SS:[BP-8] (2) ®°©ka ©†dku
;                   SS:[BP-10] (2) adresa okna
;                   SS:[BP-12] (2) hladina k zobrazen° ©†dku
; -----------------------------------------------------------------------------

DispZNad PROC      NEAR

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

         sub       sp,12                    ; lok†ln° promànnÇ
         mov       ax,word ptr ds:[si+MnuPoz] ; ©†dek a pozice poá†tku okna
         inc       ah                       ; ©†dek a pozice k zobrazen°
         mov       ss:[bp-2],ax             ; ©†dek a pozice na displeji
         mov       ss:[bp-4],si             ; adresa definice menu
         mov       ax,ds:[si+EdMnuSeg]      ; segment okna
         mov       ss:[bp-6],ax             ; segment okna
         call      far ptr GetSgAdr         ; adresa okna -> DX
         mov       ss:[bp-10],dx            ; adresa okna
         mov       al,ds:[si+MnuSir]        ; ®°©ka okna
         mov       ah,0
         sub       sp,ax
         sub       sp,ax                    ; buffer pro ©†dek
         mov       ss:[bp-8],ax             ; ®°©ka ©†dku
         mov       al,ds:[si+MnuLev]        ; hladina k zobrazen° (AH=0)
         mov       ss:[bp-12],ax            ; hladina k zobrazen°

; ------ vymaz†n° ©†dku

         cld
         push      ss
         pop       es                       ; ES <- segment z†sobn°ku
         mov       di,sp                    ; buffer v z†sobn°ku

         mov       al,"≥"                   ; "≥"
         mov       ah,ds:[ColMnu1R]         ; bàën† barva menu
         stosw                              ; levò okraj

         mov       al," "
         mov       ah,ds:[ColText3]         ; barva nadpisu
         mov       cx,ss:[bp-8]             ; ®°©ka ©†dku nadpisu
         dec       cx
         dec       cx                       ; bez okrajñ
         rep       stosw                    ; vymaz†n° ©†dku

         mov       al,"≥"                   ; "≥"
         mov       ah,ds:[ColMnu1L]
         stosw                              ; pravò okraj

; ------ dek¢dov†n° jmÇna souboru

         mov       ah,ds:[ColText3]         ; bàën† barva ©†dku nadpisu
         mov       di,sp
         add       di,2*2                   ; poá†tek k uloëen° textu

         push      ds

         mov       ds,ss:[bp-10]            ; adresa okna

         test      byte ptr ds:[TextParm],bit0 ; je z†kaz z†pisu ?
         jz        DispENd1                 ; nen° z†kaz z†pisu
         mov       byte ptr es:[di-2],"*"   ; oznaáen° z†kazu z†pisu

DispENd1:test      byte ptr ds:[TextParm],bit1 ; je buffer modifikov†n ?
         jz        DispENd2                 ; buffer nen° modifikov†n
         mov       byte ptr es:[di-2],"!"   ; p©°znak modifikace bufferu

DispENd2:mov       si,TextName              ; jmÇno souboru
         mov       cx,ds:[TextNamN]         ; dÇlka jmÇna souboru
         jcxz      DispENd4                 ; nen° jmÇno souboru

DispENd3:lodsb
         stosw
         loop      DispENd3

; ------ p©°prava pro zobrazen° ©†dku a pozice

DispENd4:mov       bh,ah                    ; BH <- bàën† barva
         mov       dx,ds:[TextKLin]         ; ©†dek s kurzorem
         mov       ax,ds:[TextKPoz]         ; pozice s kurzorem
         mov       bl,0                     ; nen° oddàlovaá

         pop       ds

; ------ dek¢dov†n° ©†dku a pozice

         mov       cx,ss:[bp-8]             ; ®°©ka ©†dku
         mov       di,sp
         add       di,cx
         add       di,cx                    ; konec ©†dku
         sub       di,2*4                   ; poá†tek k uloëen° á°sla ©†dku

         inc       ax                       ; korekce pozice
         call      DispENKr                 ; korekce adresy (AX <-> DX !)

         push      dx
         xor       dx,dx                    ; DX <- 0
         div       word ptr ds:[TextEStr]   ; p©epoáet na str†nku a ©†dek

         inc       ax                       ; korekce str†nky
         xchg      ax,dx
         inc       ax                       ; korekce á°sla ©†dku
         call      DispENKr                 ; korekce adresy (AX <-> DX !)

         push      dx                       ; á°slo ©†dku
         xor       dx,dx                    ; DX <- 0
         call      far ptr DekNumD          ; dek¢dov†n° á°sla str†nky
         pop       ax                       ; á°slo ©†dku

         mov       byte ptr es:[di],":"     ; oddàlovaá
         inc       di
         inc       di
         call      far ptr DekNumW          ; dek¢dov†n° á°sla ©†dku

         pop       ax

         mov       byte ptr es:[di],":"     ; oddàlovaá
         inc       di
         inc       di
         call      far ptr DekNumW          ; dek¢dov†n° pozice na ©†dku

; ------ dek¢dov†n° koment†©e

         mov       di,sp                    ; poá†tek bufferu
         mov       ah,ds:[ColText4]         ; barva nadpisu

         push      ds

         mov       ds,ss:[bp-10]            ; segment okna
         mov       cx,ds:[TextNKom]         ; dÇlka koment†©e
         mov       bx,ss:[bp-8]             ; ®°©ka ©†dku okna
         cmp       cx,bx
         jb        DispENd5
         mov       cx,bx
DispENd5:sub       bx,cx                    ; zbytek na okraje
         and       bl,not bit0              ; zarovn†n°
         add       di,bx                    ; ukl†dac° adresa
         jcxz      DispENd7                 ; nen° ë†dnò text

         mov       si,TextKom               ; koment†©
DispENd6:lodsb
         stosw
         loop      DispENd6

DispENd7:pop       ds

; ------ zobrazen° ©†dku nadpisu

         mov       si,sp                    ; zaá†tek bufferu
         mov       dx,ss:[bp-2]             ; ©†dek a pozice na displeji
         mov       cl,ss:[bp-8]             ; ®°©ka ©†dku
         mov       ax,ss:[bp-12]            ; hladina k zobrazen°
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
         ret

DispZNad ENDP

; ------ korekce k uloëen° textu (zamàn° DX a AX !)

DispENKr:push      ax
         push      dx
         push      cx

         mov       cx,10
DispENK2:xor       dx,dx                    ; DX <- 0
         div       cx
         dec       di
         dec       di
         or        ax,ax
         jnz       DispENK2

         pop       cx
         pop       ax
         pop       dx
         ret

; -----------------------------------------------------------------------------
;        zobrazen° kurzoru menu modifikace DS:SI
; -----------------------------------------------------------------------------

KurEMnu  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      dx
         push      es

; ------ adresa segmentu okna

         mov       ax,ds:[si+EdMnuSeg]      ; segment okna
         call      far ptr GetDat           ; adresa segmentu

; ------ zobrazen° kurzoru

         mov       dl,es:[TextKPoz]         ; pozice kurzoru
         sub       dl,es:[TextTPoz]         ; offset od poá†tku ©†dku
         inc       dx
         mov       dh,es:[TextKLin]         ; ©†dek s kurzorem
         sub       dh,es:[TextTLin]         ; offset od poá†teán°ho ©†dku
         add       dh,2                     ; p©iáten° okraje okna
         add       dx,word ptr ds:[si+MnuPoz] ; p©iáten° poá†tku okna
         call      far ptr SetKurz          ; nastaven° pozice kurzoru

; ------ nastaven° velikosti kurzoru

         test      byte ptr ds:[TextEPar],bit7 ; je INSERT ?
         jnz       KurEMnu8                 ; nen° INSERT
         call      far ptr SizeLKur         ; nastaven° n°zkÇho kurzoru
         jmp       short KurEMnu9

KurEMnu8:call      far ptr SizeHKur         ; nastaven° vysokÇho kurzoru

; ------ n†vrat registrñ

KurEMnu9:pop       es
         pop       dx
         pop       ax
         ret

KurEMnu  ENDP

; -----------------------------------------------------------------------------
;        editace okna editoru DS:SI (kl†vesa BX -> BX=0 kl†vesa obslouëena)
; -----------------------------------------------------------------------------
;˛
EditEMnu PROC      FAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      di
         push      bp
         push      es

; ------ p©°prava k editaci

         mov       ax,ds:[si+EdMnuSeg]      ; segment okna
         call      far ptr GetDat           ; adresa okna -> ES
         mov       di,es:[TextTLin]         ; prvn° zobrazenò ©†dek
         mov       cx,es:[TextKPoz]         ; pozice kurzoru na ©†dku
         mov       dx,es:[TextKLin]         ; ©†dek s kurzorem

; ------ obsluha kl†vesy BX

         call      EditEMn0                 ; obsluha kl†vesy

         cmp       di,es:[TextTLin]         ; zmànàn prvn° ©†dek ?
         je        EditEMn6                 ; ©†dek nen° zmànàn
         mov       es:[TextTLin],di         ; novò prvn° ©†dek
         or        byte ptr ds:[TextEPar],bit2 ; zobrazen° okna
         call      IniTTLin                 ; inicializace prvn°ho ©†dku

EditEMn6:cmp       dx,es:[TextKLin]         ; zmànàn ©†dek s kurzorem ?
         je        EditEMn7                 ; ©†dek nen° zmànàn
         mov       es:[TextKLin],dx         ; novò ©†dek s kurzorem
         or        byte ptr ds:[TextEPar],bit0 ; nutnÇ zobrazen° kurzoru
         call      IniTKLin                 ; inicializace ©†dku s kurzorem

EditEMn7:cmp       cx,es:[TextKPoz]         ; zmànàna pozice kurzoru ?
         je        EditEMn8                 ; nen° zmànàna pozice na ©†dku
         mov       es:[TextKPoz],cx         ; nov† pozice na ©†dku
         or        byte ptr ds:[TextEPar],bit0 ; nutnÇ zobrazen° kurzoru

EditEMn8:call      EditERez                 ; odstranàn° nadbyteánòch mezer
         call      EditERC                  ; odstranàn° nadbyteánòch ©†dkñ
         call      far ptr KorEMnu          ; korekce menu
         xor       bx,bx                    ; BX <- 0 p©°znak obsluhy kl†vesy

; ------ n†vrat registrñ

EditEMn9:pop       es
         pop       bp
         pop       di
         pop       dx
         pop       cx
         pop       ax
         ret

EditEMnu ENDP

; ------ obsluha kl†vesy

EditEMn0:push      ax
         mov       al,0                     ; AL <- 0
         xchg      al,ds:[EditPrik]         ; nulov†n° prefixu
         cmp       al,0                     ; byl prefix ?
         je        EditEM09                 ; nebyl prefix

         mov       bh,al                    ; BH <- prefix
         xchg      ax,bx
         call      far ptr UpCase           ; konverze na velkÇ p°smeno
         cmp       al," "                   ; je znak s Ctrl- ?
         jae       EditEM02                 ; nen° znak s Ctrl-
         or        al,40h                   ; konverze na p°smeno
EditEM02:xchg      ax,bx                    ; BX <- znak s Ctrl-

         pop       ax
         jmp       EditEM0P                 ; obsluha kl†ves s prefixem

EditEM09:pop       ax
         call      far ptr JumpBX

         dw        4b00h,EditELft           ; vlevo
         dw        4d00h,EditERgh           ; vpravo
         dw        4800h,EditEUp            ; nahoru
         dw        5000h,EditEDwn           ; dolñ
         dw        7300h,EditECLf           ; Ctrl-vlevo
         dw        7304h,EditECLf           ; Ctrl-Shift-vlevo
         dw        7400h,EditECRg           ; Ctrl-vpravo
         dw        7404h,EditECRg           ; Ctrl-Shift-vpravo

         dw        4700h,EditEHom           ; Home
         dw        4f00h,EditEEnd           ; End
         dw        7700h,EditCPUp           ; Ctrl-Home
         dw        7704h,EditCPUp           ; Ctrl-Shift-Home
         dw        7500h,EditCPDn           ; Ctrl-End
         dw        7504h,EditCPDn           ; Ctrl-Shift-End

         dw        4900h,EdizPgUp           ; PageUp
         dw        5100h,EdizPgDn           ; PageDown
         dw        8400h,EditCPUp           ; Ctrl-PageUp
         dw        8404h,EditCPUp           ; Ctrl-Shift-PageUp
         dw        7600h,EditCPDn           ; Ctrl-PageDown
         dw        7604h,EditCPDn           ; Ctrl-Shift-PageDown

         dw        0f09h,EditETab           ; TAB
         dw        0f00h,EditESTb           ; Shift-Tab

         dw        5200h,EditEIns           ; Insert
         dw        5300h,EditEDel           ; Delete
         dw        0e08h,EditEBs            ; BS
         dw        1c0dh,EditEEnt           ; Enter

         dw        4567h,EditEHes           ; zad†n° hesla

         dw        3d00h,EditBBeg           ; F3: zaá†tek bloku
         dw        3e00h,EditBEnd           ; F4: konec bloku
         dw        3f00h,EditBKoB           ; F5: kopie bloku
         dw        4000h,EditBMvB           ; F6: p©esun bloku
         dw        4100h,EditZHld           ; F7: hled†n°
         dw        4200h,EditBDlB           ; F8: zru® blok
         dw        4300h,EditBZoB           ; F9: zobrazen° bloku

         dw        5600h,EditBWrB           ; Shift-F3 uloëen° bloku
         dw        5800h,EditBReB           ; Shift-F5 naáten° bloku
         dw        5900h,EditBTsk           ; Shift-F6 tisk souborñ
         dw        5a00h,EditZNah           ; Shift-F7 n†hrada
         dw        5c00h,EditZCen           ; Shift-F9 vyst©edàn° ©†dku

         dw        1e01h,EditECLf           ; Ctrl-A slovo vlevo
         dw        3002h,EditBFor           ; Ctrl-B form†tov†n°
         dw        2e03h,EdizPgDn           ; Ctrl-C str†nku dolñ
         dw        2004h,EditERgh           ; Ctrl-D znak vpravo
         dw        1205h,EditEUp            ; Ctrl-E nahoru
         dw        2106h,EditECRg           ; Ctrl-F slovo vpravo
         dw        2207h,EditEDel           ; Ctrl-G zru®en° znaku za kurzorem
         dw        2308h,EditEBs            ; Ctrl-H zru®en° znaku vlevo
         dw        1709h,EditETab           ; Ctrl-I tabul†tor
         dw        240Ah,EditCtrJ           ; Ctrl-J n†povàda, speci†ln° funkce
         dw        250Bh,EditCtrK           ; Ctrl-K soubory a bloky
         dw        260ch,EditZNHl           ; Ctrl-L pokraáov†n° v hled†n°
         dw        320dh,EditEEnt           ; Ctrl-M Enter
;         dw        310eh,EditNLn            ; Ctrl-N vloëen° ©†dku
         dw        180fh,EditCtrO           ; Ctrl-O p©ep°naáe a parametry
;         dw        1910h,                   ; Ctrl-P ASCII tabulka
         dw        1011h,EditCtrQ           ; Ctrl-Q p©esuny kurzoru
         dw        1312h,EdizPgUp           ; Ctrl-R str†nka nahoru
         dw        1f13h,EditELft           ; Ctrl-S znak vlevo
;         dw        1414h,EditCtrT           ; Ctrl-T maz†n° slova za kurzorem
;         dw        1615h,EditCtrU           ; Ctrl-U ???
         dw        2f16h,EditEIns           ; Ctrl-V Insert
;         dw        1117h,EditCtrW           ; Ctrl-W posun obraz. o ©†dek nahoru
         dw        2d18h,EditEDwn           ; Ctrl-X kurzor dolñ
         dw        1519h,EdiZDelL           ; Ctrl-Y zru®en° ©†dku
;         dw        2c1ah,EditCtrZ           ; Ctrl-Z posun obraz. o ©†dek dolñ

         dw        MousXKod+MousXLP,EditEMou ; stisk levÇho tlaá°tka my®i
         dw        MousXKod+MousXMov,EditEMou ; pohyb my®°
         dw        MousXKod+MousXLH,EditEMou ; drëen° levÇho tlaá°tka my®i
         dw        MousXKod+MousXRH,EditEMou ; drëen° pravÇho tlaá°tka my®i
         dw        MousXKod+MousXRP,EditEMo0 ; stisk pravÇho tlaá°tka my®i
         dw        MousXKod+MousXRR,EdZEShft ; uvolnàn° pravÇho tlaá°tka my®i

         dw        0,EditEChr               ; vloëen° znaku
;˛

EditEM0P:call      far ptr JumpBX

         dw        0b00h + "B",EditBBeg     ; Ctrl-KB F3
         dw        0b00h + "K",EditBEnd     ; Ctrl-KK F4
         dw        0b00h + "C",EditBKoB     ; Ctrl-KC F5
         dw        0b00h + "V",EditBMvB     ; Ctrl-KV F6
         dw        1100h + "F",EditZHld     ; Ctrl-QF F7
         dw        0b00h + "Y",EditBDlB     ; Ctrl-KY F8
         dw        0b00h + "H",EditBZoB     ; Ctrl-KH F9
         dw        0b00h + "W",EditBWrB     ; Ctrl-KW Shift-F3
         dw        0b00h + "R",EditBReB     ; Ctrl-KR Shift-F5
         dw        0b00h + "P",EditBTsk     ; Ctrl-KP Shift-F6
         dw        1100h + "A",EditZNah     ; Ctrl-QA Shift-F7
         dw        0f00h + "C",EditZCen     ; Ctrl-OC Shift-F9

         dw        0,EditECh1               ; neplatn† kl†vesa

; -----------------------------------------------------------------------------
;        veden° kurzoru my®° -> CX=pozice, DX=©†dek, DI=prvn° ©†dek, ES=okno
; -----------------------------------------------------------------------------

EditEMo0:call      EdZEShft                 ; ukonáen° oznaáov†n°
         call      EditEMo2                 ; posun kurzoru my®i
         mov       es:[TextKLin],dx         ; novò ©†dek s kurzorem
         call      IniTKLin                 ; inicializace ©†dku s kurzorem
         mov       es:[TextKPoz],cx         ; nov† pozice na ©†dku
         or        byte ptr ds:[TextEPar],bit0 ; nutnÇ zobrazen° kurzoru
         jmp       EdZBShf0                 ; zah†jen° oznaáov†n°


EditEMou PROC      NEAR

; ------ pravÇ tlaá°tko jen je-li oznaáov†n°

         test      byte ptr ds:[MouseKey],bit1 ; je pravÇ tlaá°tko my®i ?
         jz        EditEMo2                 ; nen° pravÇ tlaá°tko my®i
         test      byte ptr ds:[TextForP],bit4 ; je oznaáov†n° ?
         jz        EditEMo9                 ; nen° oznaáov†n° bloku

; ------ zah†jen° oznaáov†n° bloku

EditEMo2:call      EdZBShft                 ; zah†jen° oznaáov†n° SHIFT-

; ------ pozice kurzoru -> CX

         mov       al,ds:[si+MnuPoz]        ; poá†teán° pozice okna
         mov       ah,0
         inc       ax                       ; p©iáten° levÇho okraje
         mov       cl,byte ptr ds:[MousePoz] ; pozice s kurzorem my®i
         mov       ch,0
         sub       cx,ax                    ; pozice kurzoru my®i relativnà
         jnc       EditEMo3
         xor       cx,cx
EditEMo3:mov       al,ds:[si+MnuSir]        ; ®°©ka okna
         sub       al,2+1                   ; bez okrajñ+1
         cmp       cl,al
         jbe       EditEMo4
         mov       cl,al                    ; omezen° pozice kurzoru
EditEMo4:add       cx,es:[TextTPoz]         ; pozice kurzoru na ©†dku

; ------ ©†dek s kurzorem -> DX

         mov       al,ds:[si+MnuRad]        ; poá†teán° ©†dek okna
         mov       ah,0
         add       al,2                     ; p©iáten° horn°ho okraje
         mov       dl,byte ptr ds:[MousePoz+1] ; ©†dek s kurzorem my®i
         mov       dh,0
         sub       dx,ax                    ; ©†dek kurzoru my®i relativnà
         jnc       EditEMo5
         xor       dx,dx
EditEMo5:mov       al,ds:[si+MnuVys]        ; vò®ka okna
         sub       al,3+1                   ; bez okrajñ + 1
         cmp       dl,al
         jbe       EditEMo6
         mov       dl,al                    ; omezen° ©†dku s kurzorem
EditEMo6:add       dx,di                    ; ©†dek s kurzorem my®i

; ------ obsluha oznaáov†n° bloku

         call      EdZShift                 ; obsluha oznaáov†n° SHIFT-
EditEMo9:ret

EditEMou ENDP

; -----------------------------------------------------------------------------
;        Ctrl-J, Ctrl-K, Ctrl-O, Ctrl-Q
; -----------------------------------------------------------------------------

EditCtrJ:
EditCtrK:
EditCtrO:
EditCtrQ:
         mov       ds:[EditPrik],bl         ; p©°znak prefixu
         ret

; ------ zru®en° znaku p©ed kurzorem BS

EditEBs: call      EdZEShft                 ; ukonáen° oznaáov†n° SHIFT-

         or        cx,cx                    ; je poá†tek ©†dku ?
         jnz       EditEBs2                 ; nen° poá†tek ©†dku
         test      byte ptr ds:[TextEPar],bit7 ; vypnut INSERT ?
         jnz       EditEDl0                 ; p©i vypnutÇm INSERT se nepokraáuje
         call      EditELft                 ; p©esun na konec p©ede®lÇho ©†dku
         jc        EditEDl0                 ; nen° dal®° ©†dek
         or        byte ptr ds:[TextEPar],bit0+bit2 ; zobrazen° okna
         mov       es:[TextKPoz],cx         ; nov† pozice kurzoru na ©†dku
         jmp       short EditEDel           ; zru®en° znaku CR/LF

EditEBs2:dec       cx                       ; sn°ëen° pozice
         mov       es:[TextKPoz],cx         ; nov† pozice kurzoru
         or        byte ptr ds:[TextEPar],bit0 ; zobrazit kurzor
         test      byte ptr es:[TextParm],bit0 ; je z†kaz z†pisu ?
         jnz       EditEDl0                 ; je z†kaz z†pisu
         cmp       cx,es:[TextKEnd]         ; je za koncem ©†dku ?
         jae       EditEDl0                 ; je za koncem ©†dku - nic d†le
         test      byte ptr ds:[TextEPar],bit7 ; vypnut INSERT ?
         jz        EditEDel                 ; INSERT je vypnut - d†le

; ------ p©i vypnutÇm INSERT n†hrada maz†n°m mezerou

         push      cx                       ; £schova aktu†ln° pozice
         push      dx                       ; uschovanò ©†dek

         mov       bx," "                   ; mezera k maz†n°
         call      EditEChr                 ; vymaz†n° znaku

         pop       dx
         pop       cx                       ; pñvodn° pozice
         ret

; ------ zru®en° znaku DEL

EditEDel:call      EdZEShft                 ; ukonáen° oznaáov†n° SHIFT-

         test      byte ptr es:[TextParm],bit0 ; je z†kaz z†pisu ?
         jz        EditEDl1                 ; nen° z†kaz z†pisu
EditEDl0:ret

EditEDl1:push      di
         push      cx

; ------ test, zda je platnò ©†dek s kurzorem

         mov       di,es:[TextKLin]         ; ©†dek s kurzorem
         cmp       di,es:[TextBLin]         ; je to platnò ©†dek ?
         jbe       EdiEDl12                 ; je to platnò ©†dek
EdiEDl11:jmp       EditEDl9                 ; nen° to platnò ©†dek

; ------ doplnàn° mezer po kurzor (p©°p. o©ez†n°, jsou-li nav°c)

EdiEDl12:call      EditERez                 ; o©ez†n° mezer na konci ©†dku
         call      EditECrl                 ; vloëen° novòch ©†dkñ za konec
         jc        EdiEDl11                 ; chyba
         call      EditESpc                 ; vloëen° mezer za konec ©†dku
         jc        EdiEDl11                 ; chyba

; ------ test, zda jsou nàjak† data za kurzorem

         mov       di,es:[TextKPoz]         ; pozice kurzoru
         add       di,es:[TextKAdr]         ; offset kurzoru
         add       di,TextBBeg              ; adresa kurzoru
         cmp       di,es:[0]                ; je konec dat ?
         jae       EdiEDl11                 ; je konec dat

; ------ test, zda se ru®° konec ©†dku CR/LF

         cmp       word ptr es:[di],LF*HI + CR ; je konec ©†dku ?
         jne       EditEDl6                 ; nen° konec ©†dku

         inc       di
         cmp       di,es:[0]                ; jsou 2 znaky ?
         jae       EditEDl5                 ; nen° dal®° znak
         dec       di

; ------ ru®° se 2 bajty

         mov       cx,2                     ; ru®° se 2 znaky
         call      far ptr DelDat           ; zru®en° konce ©†dku
         jc        EdiEDl11                 ; chyba

; ------ oprava ukazatelñ po zru®en° p©elomu ©†dku

         sub       es:[TextBNum],cx         ; sn°ëen° poátu bajtñ v bufferu
         dec       word ptr es:[TextBLin]   ; sn°ëen° poátu ©†dkñ v bufferu
         or        byte ptr es:[TextParm],bit1 ; p©°znak modifikace
         or        byte ptr ds:[TextEPar],bit2 ; zobrazit v®e
         call      IniTKLin                 ; inicializace ©†dku s kurzorem

; ------ inicializace ukazatelñ blokñ (DX=©†dek)

         mov       cx,es:[TextKPoz]         ; pozice kurzoru
         mov       bx,TextBBPz              ; zaá†tek bloku
         call      EdiEDlB                  ; aktualizace zaá†tku bloku
         mov       bx,TextBEPz              ; konec bloku
         call      EdiEDlB                  ; aktualizace konce bloku
         jmp       short EditEDl9

; ------ bude se ru®it 1 znak

EditEDl5:dec       di                       ; n†vrat po zvò®en° ukazatele
EditEDl6:mov       cx,1                     ; ru®° se 1 znak
         call      far ptr DelDat           ; zru®en° znaku za kurzorem
         jc        EditEDl9                 ; chyba

; ------ oprava ukazatelñ

         dec       word ptr es:[TextBNum]   ; sn°ëen° poátu bajtñ v bufferu
         or        byte ptr es:[TextParm],bit1 ; p©°znak modifikace
         or        byte ptr ds:[TextEPar],bit1 ; zobrazit ©†dek
         dec       word ptr es:[TextKDel]   ; sn°ëen° dÇlky ©†dku

; ------ sn°ëen° dÇlky textu ©†dku

         mov       cx,es:[TextKPoz]         ; pozice kurzoru
         cmp       cx,es:[TextKEnd]         ; je v textu ?
         jae       EditEDl7                 ; nen° v textu
         dec       word ptr es:[TextKEnd]   ; sn°ëen° dÇlky textu

; ------ oprava pozice bloku

EditEDl7:cmp       dx,es:[TextBBLn]         ; je ©†dek s poá†tkem bloku ?
         jne       EditEDl8                 ; nen° poá†tek bloku
         cmp       cx,es:[TextBBPz]         ; zmàn° se pozice bloku ?
         jae       EditEDl8                 ; pozice se nezmàn°
         dec       word ptr es:[TextBBPz]   ; posun pozice poá†tku bloku

EditEDl8:cmp       dx,es:[TextBELn]         ; je ©†dek s koncem bloku ?
         jne       EditEDl9                 ; nen° konec bloku
         cmp       cx,es:[TextBEPz]         ; zmàn° se pozice bloku ?
         jae       EditEDl9                 ; pozice se nezmàn°
         dec       word ptr es:[TextBEPz]   ; posun pozice konce bloku

EditEDl9:pop       cx
         pop       di
         ret

; ------ ENTER

EditEEnt:call      EdZEShft                 ; ukonáen° oznaáov†n° SHIFT-

         cmp       cx,es:[TextKDel]         ; je kurzor za koncem ©†dku ?
         jae       EditEEn5                 ; je na konci ©†dku - bude INSERT
         test      byte ptr ds:[TextEPar],bit7 ; vypnut INSERT ?
         jz        EditEEn3                 ; je zapnut INSERT
EditEEn2:xor       cx,cx                    ; pozice 0
         inc       dx                       ; ©†dek + 1
         ret

EditEEn5:mov       cx,es:[TextKDel]         ; kurzor na konec ©†dku
EditEEn3:test      byte ptr es:[TextParm],bit0
         jnz       EditEEn2                 ; z†kaz z†pisu
         mov       bx,CR
         call      EditECh2
         jc        EditEEn4
         mov       bx,LF
         call      EditECh2
EditEEn4:ret

; ------ vloëen° znaku BL (s kontrolou platnosti znaku)
;˛
EditEChr:call      EdZEShft                 ; ukonáen° oznaáov†n° SHIFT-

         cmp       bh,MousXKod/HI           ; je k¢d my®i ?
         je        EditECh1
         or        bx,bx                    ; je Ctrl-Break ?
         jz        EditECh1                 ; Ctrl-Break nen° povolen
         or        bh,bh                    ; je to znak s Alt ?
         jz        EditECh2                 ; je to znak s Alt
         cmp       bx,300h                  ; je to znak Ctrl-@ ?
         je        EditECh2                 ; je to znak Ctrl-@
         cmp       bl," "                   ; je to platnò znak ?
         jae       EditECh2                 ; je to platnò znak

; ------ neplatn† kl†vesa

EditECh1:add       sp,2                     ; zru®en° n†vratovÇ adresy
         stc                                ; kl†vesa neobslouëena
         jmp       EditEMn9

; ------ test povolen° operace (jinak jen posun kurzoru)

EditECh2:push      di

         cmp       cx,-5                    ; maxim†ln° pozice
         jae       EditECh3                 ; p©eteáen° pozice

         test      byte ptr es:[TextParm],bit0 ; je z†kaz z†pisu ?
         jz        EditECh4                 ; nen° z†kaz z†pisu

EditECh3:pop       di
         jmp       EditERgh                 ; pouze se posune kurzor

; ------ doplnàn° pr†zdnò ©†dkñ a mezer po kurzor

EditECh4:call      EditECS                  ; doplnàn° ©†dkñ a mezer
         jc        EditECh3                 ; chyba

; ------ test, zda je kurzor na konci ©†dku (zda m† bòt vloëen znak INSERT)

         mov       di,cx                    ; DI <- pozice kurzoru
         add       di,es:[TextKAdr]         ; offset kurzoru
         add       di,TextBBeg              ; adresa kurzoru
         cmp       cx,es:[TextKDel]         ; je konec ©†dku ?
         jae       EditECh6                 ; je na konci ©†dku

; ------ test, zda je INSERT (zda m† bòt znak vloëen)

EditECh5:test      byte ptr ds:[TextEPar],bit7 ; je vypnut INSERT ?
         jnz       EditEC61                 ; je vypnut INSERT

; ------ vytvo©en° m°sta pro znak (je-li INSERT nebo konec ©†dku)

EditECh6:push      cx
         mov       cx,1                     ; vkl†d† se 1 znak
         call      far ptr InsDat           ; vytvo©en° m°sta pro 1 znak
         pop       cx
         jc        EditECh3                 ; chyba
         inc       word ptr es:[TextKDel]   ; zvò®en° dÇlky ©†dku
         inc       word ptr es:[TextKEnd]   ; posun konce textu ©†dku
         inc       word ptr es:[TextBNum]   ; zvò®en° poátu znakñ textu

; ------ posun pozice poá†tku bloku, je-li na ©†dku za kurzorem

         cmp       dx,es:[TextBBLn]         ; je ©†dek s poá†tkem bloku ?
         jne       EditEC60                 ; nen° poá†tek bloku
         cmp       cx,es:[TextBBPz]         ; zmàn° se pozice bloku ?
         ja        EditEC60                 ; pozice se nezmàn°
         inc       word ptr es:[TextBBPz]   ; posun pozice poá†tku bloku

; ------ posun pozice konce bloku, je-li na ©†dku za kurzorem

EditEC60:cmp       dx,es:[TextBELn]         ; je ©†dek s koncem bloku ?
         jne       EditEC61                 ; nen° konec bloku
         cmp       cx,es:[TextBEPz]         ; zmàn° se pozice bloku ?
         jae       EditEC61                 ; pozice se nezmàn°
         inc       word ptr es:[TextBEPz]   ; posun pozice konce bloku

; ------ uloëen° znaku do textu

EditEC61:mov       es:[di],bl               ; vloëen° znaku
         inc       di                       ; zvò®en° ukazatele textu
         or        byte ptr ds:[TextEPar],bit1 ; zobrazen° ©†dku
         or        byte ptr es:[TextParm],bit1 ; p©°znak modifikace textu

; ------ zvò®en° pozice kurzoru a p©°padn† oprava konce textu

         inc       cx                       ; dal®° pozice
         mov       es:[TextKPoz],cx         ; nov† pozice na ©†dku
         cmp       cx,es:[TextKEnd]         ; bylo to za koncem textu ?
         jb        EditECh7                 ; nebylo to za koncem textu
         mov       es:[TextKEnd],cx         ; znak uráuje novò konec textu

; ------ oprava dÇlky ©†dku pro mezeru na konci textu

         cmp       bl," "                   ; je to mezera ?
         jne       EditECh7                 ; nebyla to mezera
         push      di
         dec       di
EditEC63:dec       word ptr es:[TextKEnd]   ; sn°ëen° dÇlky textu
         jz        EditEC64                 ; dÇlka = 0
         dec       di
         cmp       byte ptr es:[di]," "     ; p©ede®lò znak mezera ?
         je        EditEC63                 ; dal®° sn°ëen° dÇlky ©†dku
EditEC64:pop       di

; ------ oprava poátu ©†dkñ, pokud byl CR nebo LF

EditECh7:cmp       bl,LF                    ; byl vloëen znak LF ?
         jne       EditEC74                 ; nebyl to znak LF
         cmp       di,TextBBeg+1            ; je p©ede®lò znak ?
         jbe       EditEC74                 ; nen° p©ede®lò znak
         cmp       byte ptr es:[di-2],CR    ; je p©edchoz° znak CR ?
         je        EditECh8                 ; byl to konec ©†dku

EditEC74:cmp       bl,CR
         jne       EditECh9                 ; nen° CR
         cmp       di,es:[0]                ; je dal®° znak ?
         jae       EditECh9                 ; nen° dal®° znak
         cmp       byte ptr es:[di],LF      ; je dal®° znak LF ?
         jne       EditECh9                 ; nen° konec ©†dku
         inc       di                       ; zvò®en° ukazatele textu

; ------ zvò®en° poátu ©†dkñ

EditECh8:inc       word ptr es:[TextBLin]   ; zvò®en° poátu ©†dkñ

; ------ o©ez†n° mezer na aktu†ln°m ©†dku

         call      EditERez                 ; o©ez†n° mezer na konci ©†dku

; ------ oprava ukazatelñ bloku po CR/LF

         push      si
         mov       si,TextBBPz              ; poá†tek bloku
         call      EditECB                  ; oprava poá†tku bloku
         mov       si,TextBEPz              ; konec bloku
         call      EditECB                  ; oprava konce bloku
         pop       si

; ------ nastaven° novÇho ©†dku a pozice kurzoru

         inc       dx                       ; zvò®en° á°sla ©†dku
         xor       cx,cx                    ; posun na pozici 0
         mov       es:[TextKLin],dx         ; novò ©†dek s kurzorem
         mov       es:[TextKPoz],cx         ; nov† pozice na ©†dku
         or        byte ptr ds:[TextEPar],bit2 ; zobrazen° okna
         call      IniTKLin                 ; inicializace ©†dku s kurzorem

; ------ zform†tov†n° ©†dku s kurzorem, je-li z†pis znaku na pravò okraj

EditECh9:pop       di

         push      cx
         dec       cx                       ; n†vrat p©ede®lÇ pozice
         cmp       cx,ds:[TextEOkr]         ; je to z†pis na okraj ?
         pop       cx
         jne       EditEChA                 ; nen° z†pis na okraj

         cmp       bl,LF
         je        EditEChA
         cmp       bl,CR
         je        EditEChA

         call      EditKFrm                 ; zform†tov†n° ©†dku s kurzorem
         or        byte ptr ds:[TextEPar],bit2 ; zobrazit v®e
EditEChA:clc
         ret


; ------ kurzor vpravo

EditERgh:call      EdZBShft                 ; zah†jen° oznaáov†n° SHIFT-
         cmp       cx,-4                    ; maxim†ln° pozice
         jae       EditERg3                 ; p©eteáen° pozice
         inc       cx                       ; zvò®en° pozice kurzoru na ©†dku
         call      EdZShift                 ; obsluha oznaáov†n° SHIFT-
         clc                                ; p©°znak operace OK
         ret

EditERg3:stc                                ; p©°znak chyby - p©eteáen° pozice
         ret

; ------ kurzor vlevo

EditELft:call      EdZBShft                 ; zah†jen° oznaáov†n° SHIFT-
         jcxz      EditELf2                 ; je jië poá†tek ©†dku
         dec       cx                       ; sn°ëen° pozice kurzoru na ©†dku
         call      EdZShift                 ; obsluha oznaáov†n° SHIFT-
         clc                                ; p©°znak operace OK
         ret

EditELf2:or        dx,dx                    ; je prvn° ©†dek ?
         jz        EditERg3                 ; je prvn° ©†dek - chyba
         dec       dx                       ; sn°ëen° ukazatele ©†dku
         mov       es:[TextKLin],dx         ; novò ©†dek s kurzorem
         or        byte ptr ds:[TextEPar],bit0 ; nutnÇ zobrazen° kurzoru
         call      IniTKLin                 ; inicializace ©†dku s kurzorem
         call      EditEEnd                 ; posun na konec ©†dku
         call      EdZShift                 ; obsluha oznaáov†n° SHIFT-
         clc                                ; p©°znak operace OK
         ret

; ------ vpravo s p©esunem na dal®° ©†dek

EditERg0:cmp       dx,es:[TextBLin]         ; je platnò ©†dek ?
         cmc
         jc        EditER10                 ; nen° platnò ©†dek
         call      EditERgh                 ; posun kurzoru vpravo
         jc        EditER10                 ; nen° dal®° pozice
         cmp       cx,es:[TextKEnd]         ; je za koncem ©†dku ?
         jbe       EditER20                 ; nen° za koncem ©†dku
         xor       cx,cx                    ; pozice na zaá†tek
         inc       dx                       ; zvò®en° ©†dku
         mov       es:[TextKLin],dx         ; novò ©†dek s kurzorem
         or        byte ptr ds:[TextEPar],bit0 ; nutnÇ zobrazen° kurzoru
         call      IniTKLin                 ; inicializace ©†dku s kurzorem

EditER20:clc                                ; p©°znak operace OK
EditER10:ret

; ------ kurzor nahoru

EditEUp: call      EdZBShft                 ; zah†jen° oznaáov†n° SHIFT-
         or        dx,dx                    ; je jië prvn° ©†dek ?
         jz        EditEDw3                 ; je jië prvn° ©†dek - chyba
         dec       dx                       ; sn°ëen° á°sla ©†dku (je NC !)
         call      EdZShift                 ; obsluha oznaáov†n° SHIFT-
         ret

; ------ dolñ

EditEDwn:call      EdZBShft                 ; zah†jen° oznaáov†n° SHIFT-
         cmp       dx,7ff6h                 ; maxim†ln° ©†dek (2 bajty/©†dek !)
         jae       EditEDw3                 ; je jië maxim†ln° ©†dek
         inc       dx                       ; zvò®en° á°sla ©†dku
         call      EdZShift                 ; obsluha oznaáov†n° SHIFT-
         clc                                ; p©°znak operace OK
         ret

EditEDw3:stc                                ; p©°znak chyby
         ret

; ------ slovo vlevo

EditECLf:call      EdZBShft                 ; zah†jen° oznaáov†n° SHIFT-
         push      ax
         call      EditELft                 ; kurzor vlevo
         jc        EditECL6                 ; nen° dal®° znak
         call      EditEGtC                 ; znak na pozici kurzoru -> AL
EditECL2:cmp       cx,es:[TextKDel]         ; je to konec ©†dku ?
         je        EditECL6                 ; je to konec ©†dku
         mov       ah,al                    ; p©ede®lò znak
         call      EditELft                 ; kurzor vlevo
         jc        EditECl6                 ; nen° dal®° pozice
         call      EditEGtC                 ; poskytnut° znaku
         call      far ptr TestWrd          ; test, zda je zaá†tek slova
         jc        EditECL2                 ; nen° zaá†tek slova
         call      EditERg0                 ; n†vrat pozice kurzoru
         clc
EditECL6:pop       ax
         call      EdZShift                 ; obsluha oznaáov†n° SHIFT-
         ret

; ------ slovo vpravo

EditECRg:call      EdZBShft                 ; zah†jen° oznaáov†n° SHIFT-
         push      ax
         call      EditEGtC                 ; znak na pozici kurzoru
         mov       ah,al                    ; £schova znaku
EditECR2:call      EditERg0                 ; posun kurzoru s p©esunem
         jc        EditECR6                 ; nen° dal®° ©†dek
         cmp       cx,es:[TextKDel]         ; je to konec ©†dku ?
         je        EditECR6                 ; je to konec ©†dku
         call      EditEGtC                 ; znak na pozici kurzoru
         xchg      ah,al                    ; oprava po©ad° znakñ
         call      far ptr TestWrd          ; test, zda je zaá†tek slova
         jc        EditECR2                 ; nalezen° zaá†tku slova

EditECR6:pop       ax
         call      EdZShift                 ; obsluha oznaáov†n° SHIFT-
         ret

; ------ str†nka nahoru

EdiZPgUp:call      EdZBShft                 ; zah†jen° oznaáov†n° SHIFT-
         or        di,di                    ; je zobrazem zaá†tek souboru ?
         jz        EditCPUp                 ; je zobrazen zaá†tek souboru
         push      ax
         mov       ah,0
         mov       al,ds:[si+MnuVys]        ; vò®ka okna
         sub       al,4                     ; - okraje - 1
         cmp       di,ax                    ; zbòv† mÇnà ©†dkñ ?
         jae       EditPgU2                 ; zbòv† dost ©†dkñ
         mov       ax,di                    ; omezen° poátu ©†dkñ
EditPgU2:sub       di,ax                    ; posun poá†tku
         sub       dx,ax                    ; posun kurzoru
         pop       ax
         call      EdZShift                 ; obsluha oznaáov†n° SHIFT-
         ret

; ------ str†nka dolñ

EdiZPgDn:call      EdZBShft                 ; zah†jen° oznaáov†n° SHIFT-
         or        dx,dx                    ; je prvn° ©†dek s kurzorem ?
         jnz       EditPgD2                 ; nen° prvn° ©†dek s kurzorem
         inc       dx                       ; korekce ©†dku s kurzorem
EditPgD2:push      ax
         mov       ah,0
         mov       al,ds:[si+MnuVys]        ; vò®ka okna
         sub       al,4                     ; - okraje - 1
         add       dx,ax                    ; posun kurzoru
         add       di,ax                    ; posun poá†tku
         pop       ax
         call      EdZShift                 ; obsluha oznaáov†n° SHIFT-
         ret

; ------ zaá†tek souboru

EditCPUp:call      EdZBShft                 ; zah†jen° oznaáov†n° SHIFT-
         xor       cx,cx                    ; pozice kurzoru 0
         xor       dx,dx                    ; ©†dek kurzoru 0
         xor       di,di                    ; prvn° zobrazenò ©†dek 0
         call      EdZShift                 ; obsluha oznaáov†n° SHIFT-
         ret

; ------ konec souboru

EditCPDn:call      EdZBShft                 ; zah†jen° oznaáov†n° SHIFT-
         xor       cx,cx                    ; kurzor na zaá†tek ©†dku
         mov       dx,es:[TextBLin]         ; kurzor za posledn° ©†dek souboru
         mov       di,dx                    ; poá†tek okna
         push      ax
         mov       ah,0
         mov       al,ds:[si+MnuVys]        ; vò®ka okna
         sub       al,4                     ; - okraje - 1
         sub       di,ax                    ; posun poá†tku okna
         jnc       EditCPD2
         xor       di,di                    ; oprava poá†tku okna
EditCPD2:pop       ax
         call      EdZShift                 ; obsluha oznaáov†n° SHIFT-
         ret

; ------ TAB

EditETab:call      EdZEShft                 ; ukonáen° oznaáov†n° SHIFT-
         push      ax
         push      dx
         mov       ax,cx                    ; AX <- souáasn† pozice
         add       ax,ds:[TextETab]         ; posun o tabul†tor
         jc        EditETb4                 ; bylo by p©eteáen°
EditETb2:xor       dx,dx                    ; DX <- 0
         div       word ptr ds:[TextETab]   ; p©epoáet na poáet tabul†torñ
         mul       word ptr ds:[TextETab]   ; p©epoáet zpàt na pozici
         cmp       ax,-4                    ; bylo by p©eteáen° ?
         jae       EditETb4                 ; bylo by p©eteáen°
         xchg      ax,cx                    ; CX <- nov† pozice plat° OK
EditETb4:pop       dx
         pop       ax
         ret

; ------ Shift-Tab

EditESTb:call      EdZEShft                 ; ukonáen° oznaáov†n° SHIFT-
         push      ax
         push      dx
         xchg      ax,cx                    ; AX <- souáasn† pozice
         sub       ax,1                     ; posun zpàt
         jnc       EditEST2
         xor       ax,ax                    ; omezen°
EditEST2:jmp       short EditETb2           ; vòpoáet novÇ pozice

; ------ Home

EditEHom:call      EdZBShft                 ; zah†jen° oznaáov†n° SHIFT-
         xor       cx,cx                    ; poá†tek ©†dku
         call      EdZShift                 ; obsluha oznaáov†n° SHIFT-
         ret

; ------ End

EditEEnd:call      EdZBShft                 ; zah†jen° oznaáov†n° SHIFT-
         mov       cx,es:[TextKEnd]         ; pozice na konci ©†dku
         call      EdZShift                 ; obsluha oznaáov†n° SHIFT-
         ret

; ------ Insert

EditEIns:xor       byte ptr ds:[TextEPar],bit7 ; zmàna INSERT
         or        byte ptr ds:[TextEPar],bit0 ; nutno zobrazit kurzor
         ret

; -----------------------------------------------------------------------------
;        oprava ukazatele bloku po CR/LF (DX,CX=starÇ ukazatele kurzoru)
; -----------------------------------------------------------------------------

EditECB: cmp       dx,es:[si+TextBBLn-TextBBPz] ; posouv† se zaá†tek bloku ?
         ja        EditECB9                 ; blok se neposouv†
         jb        EditECB8                 ; posouv† se jen ©†dek bloku
         cmp       cx,es:[si]               ; posouv† se pozice ?
         ja        EditECB9                 ; blok se neposouv†
         je        EditECB6                 ; pozice bude = 0
         cmp       bl,CR                    ; byl jako posledn° znak CR ?
         jne       EditECB6
         dec       word ptr es:[si]         ; odeáten° je®tà znaku LF
EditECB6:sub       es:[si],cx               ; posun pozice poá†tku bloku
EditECB8:inc       word ptr es:[si+TextBBLn-TextBBPz] ; posun ©†dku bloku
EditECB9:ret

; -----------------------------------------------------------------------------
;        oprava ukazatele bloku po zru®en° CR/LF (DX/CX=ukazatele kurzoru)
; -----------------------------------------------------------------------------

EdiEDlB: cmp       dx,es:[bx+TextBBLn-TextBBPz] ; je ©†dek ukazatele bloku ?
         jne       EdiEDlB2                 ; nen° ©†dek ukazatele bloku
         cmp       cx,es:[bx]               ; je pozice bloku za koncem ©†dku ?
         jae       EdiEDlB2                 ; pozice bloku se nemus° korigovat
         mov       es:[bx],cx               ; omezen° pozice na konec ©†dku

EdiEDlB2:inc       dx                       ; n†sleduj°c° ©†dek
         cmp       dx,es:[bx+TextBBLn-TextBBPz] ; je ©†dek p©ed blokem ?
         ja        EdiEDlB8                 ; je za blokem - nic se nemàn°
         jb        EdiEDlB7                 ; je p©ed blokem - sn°ëen° ©†dku
         add       es:[bx],cx               ; zvò®en° pozice bloku

EdiEDlB7:dec       word ptr es:[bx+TextBBLn-TextBBPz] ; sn°ëen° á°sla ©†dku
EdiEDlB8:dec       dx                       ; n†vrat á°sla ©†dku
         ret

; -----------------------------------------------------------------------------
;        Shift-F6 tisk souboru
; -----------------------------------------------------------------------------

EditBTsk PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         mov       bp,sp

; ------ p©°prava lok†ln°ho bufferu

         mov       cx,ds:[ZZMnTLft]         ; dÇlka levÇho okraje
         sub       sp,cx                    ; m°sto pro lok†ln° buffer

; ------ p©°prava mezer v bufferu

         mov       di,sp                    ; DI <- zaá†tek bufferu
         push      es
         push      ss
         pop       es                       ; ES <- segment z†sobn°ku
         mov       al," "                   ; znak mezery k z†pisu
         cld
         rep       stosb                    ; vynulov†n° bufferu
         pop       es

; ------ zobrazen° hl†®en°

         mov       si,offset ZZMnTTxt
         call      far ptr InfDisp0         ; zobrazen° hl†®en°

; ------ otev©en° tisk†rny -> AX

         push      es
         push      ds
         pop       es                       ; ES <- datovò segment
         mov       si,offset ZZMnTPRN       ; jmÇno souboru PRN
         call      far ptr OpenW            ; otev©en° pro z†pis
         pop       es
         jnc       EditBTs1                 ; operace OK
         jmp       EditBTs9                 ; nàjak† chyba

; ------ vòstup inicializaán°ho textu

EditBTs1:push      es
         push      ds
         pop       es                       ; ES <- datovò segment
         mov       ch,0
         mov       cl,ds:[ZZMnTIni]         ; dÇlka inicializaán°ho textu
         mov       si,offset ZZMnTIni+1     ; inicializaán° text
         call      far ptr WritFile         ; z†pis ©etàzce
         pop       es
         jc        EditBTs8                 ; chyba

; ------ p©°prava ukazatelñ

         mov       di,TextBBeg              ; zaá†tek textu
         mov       dx,ds:[TextEStr]         ; poáet ©†dkñ na str†nku

; ------ tisk levÇho okraje

EditBTs2:mov       si,sp                    ; SI <- zaá†tek bufferu
         push      es
         push      ss
         pop       es                       ; ES <- segment z†sobn°ku
         mov       cx,ds:[ZZMnTLft]         ; levò okraj tisku
         call      far ptr WritFile         ; z†pis mezer
         pop       es
         jc        EditBTs8                 ; chyba

; ------ zji®tàn° dÇlky jednoho ©†dku

         xor       cx,cx                    ; CX <- á°taá dÇlky ©†dku
         mov       si,di                    ; SI <- zaá†tek ©†dku
EditBTs3:cmp       di,es:[0]                ; je konec textu ?
         jae       EditBTs5                 ; je konec textu
         cmp       word ptr es:[di],CR + LF*HI ; konec ©†dku ?
         je        EditBTs4                 ; je konec ©†dku
         inc       cx                       ; zvò®en° á°taáe dÇlky ©†dku
         inc       di                       ; zvò®en° ukazatele adresy
         jmp       short EditBTs3           ; dal®° znak

EditBTs4:inc       di
         inc       di                       ; p©eskoáen° konce ©†dku

; ------ vyti®tàn° jednoho ©†dku z bufferu

EditBTs5:cmp       cx,ds:[TextEOkr]         ; je ©†dek p©°li® dlouhò ?
         jbe       EditBTs6                 ; dÇlka ©†dku je OK
         mov       cx,ds:[TextEOkr]         ; omezen° dÇlky ©†dku
EditBTs6:call      far ptr WritFile         ; z†pis ©†dku
         jc        EditBTs8                 ; chyba

; ------ vyti®tàn° konce ©†dku

         mov       si,offset ZZMnTCR        ; text od©†dkov†n°
         mov       cx,2                     ; tisknou se 2 znaky
         cmp       di,es:[0]                ; je konec textu ?
         jae       EditBT66                 ; je konec textu
         dec       dx                       ; á°taá ©†dkñ na str†nku
         jnz       EditBTs7                 ; nen° je®tà nov† str†nka
EditBT66:inc       cx                       ; tiskne se i FF
         mov       dx,ds:[TextEStr]         ; poáet ©†dkñ na str†nku
EditBTs7:push      es
         push      ds
         pop       es                       ; ES <- datovò segment
         call      far ptr WritFile         ; z†pis konce ©†dku
         pop       es
         jc        EditBTs8                 ; chyba

; ------ test, zda je p©eru®en° operace

         call      far ptr TestBEsc         ; je p©eru®en° operace ?
         jc        EditBTs8                 ; je p©eru®en° operace

; ------ test, zda je dal®° text

         cmp       di,es:[0]                ; je konec textu ?
         jb        EditBTs2                 ; nen° konec textu

; ------ uzav©en° tiskovÇho za©°zen°

EditBTs8:call      far ptr ClosFile         ; uzav©en° za©°zen°

; ------ uzav©en° informaán°ho ©†dku

EditBTs9:or        byte ptr ds:[TextEPar],bit2 ; zobrazit v®e
         call      far ptr InfoClos         ; uzav©en° informaán°ho ©†dku

; ------ n†vrat registrñ

         mov       sp,bp
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

EditBTsk ENDP

; -----------------------------------------------------------------------------
;        F3: zaá†tek bloku (vol† se p©i oznaáov†n° SHIFT- !)
; -----------------------------------------------------------------------------

EditBBeg:mov       es:[TextBBLn],dx         ; ©†dek zaá†tku bloku
         mov       es:[TextBBPz],cx         ; pozice zaá†tku bloku

; ------ zapnut° bloku (pokud je to moënÇ) - je vol†no z obsluhy SHIFT- !!!

EditBBg1:and       byte ptr es:[TextParm],not bit2 ; blok vypnut

         push      ax
         mov       ax,es:[TextBBLn]         ; ©†dek se zaá†tkem bloku
         cmp       ax,es:[TextBELn]         ; leë° p©ed koncem bloku ?
         jne       EditBBg2

         mov       ax,es:[TextBBPz]         ; pozice se zaá†tkem bloku
         cmp       ax,es:[TextBEPz]         ; leë° p©ed koncem bloku ?
EditBBg2:pop       ax
         jae       EditBBg6                 ; blok nebude zobrazen

         or        byte ptr es:[TextParm],bit2 ; blok zapnut
EditBBg6:or        byte ptr ds:[TextEPar],bit2 ; zobrazit v®e
         ret

; -----------------------------------------------------------------------------
;        F4: zaá†tek bloku (vol† se p©i oznaáov†n° SHIFT- !)
; -----------------------------------------------------------------------------

EditBEnd:mov       es:[TextBELn],dx         ; ©†dek konce bloku
         mov       es:[TextBEPz],cx         ; pozice konce bloku
         jmp       short EditBBg1

; -----------------------------------------------------------------------------
;        F9: zobrazen° bloku
; -----------------------------------------------------------------------------

EditBZoB:call      EdZEShft                 ; ukonáen° oznaáov†n° SHIFT-
         xor       byte ptr es:[TextParm],bit2 ; zmàna zapnut° bloku
         or        byte ptr ds:[TextEPar],bit2 ; zobrazit v®e
         test      byte ptr es:[TextParm],bit2 ; màl by bòt blok zapnut ?
         jnz       EditBBg1                 ; màl by bòt zapnut
         ret

; -----------------------------------------------------------------------------
;        F5: kopie bloku
; -----------------------------------------------------------------------------

; ------ test, zda je operace povolena

EditBKoB:call      EdZEShft                 ; ukonáen° oznaáov†n° SHIFT-
         test      byte ptr es:[TextParm],bit0 ; je z†kaz z†pisu ?
         jz        EdiBKoB1                 ; nen° z†kaz z†pisu
EdiBKoB0:ret

EdiBKoB1:test      byte ptr es:[TextParm],bit2 ; je blok zapnut ?
         jz        EdiBKoB0                 ; blok je vypnut

; ------ £schova registrñ

         push      ax
         push      cx
         push      si
         push      di

; ------ vloëen° ©†dkñ a mezer po kurzor

         call      EditECS                  ; doplnàn° ©†dkñ a mezer
         jc        EdiBKB22                 ; chyba

; ------ stanoven° adresy a dÇlky bloku -> SI, CX

         call      EdiGetBL                 ; stanoven° adresy a dÇlky ©†dku
         mov       si,di                    ; SI <- adresa zaá†tku bloku
         jbe       EdiBKB22                 ; nen° blok

; ------ adresa k uloëen° bloku -> DI

         mov       di,es:[TextKPoz]         ; pozice kurzoru
         add       di,es:[TextKAdr]         ; offset kurzoru
         add       di,TextBBeg              ; adresa kurzoru

; ------ kontrola, zda nen° kurzor v bloku (je-li, tak oprava na poá†tek)

         cmp       di,si                    ; je kurzor v bloku ?
         jbe       EdiBKoB2                 ; nen° v bloku
         mov       bx,si                    ; adresa zaá†tku bloku
         add       bx,cx                    ; adresa konce bloku
         cmp       di,bx                    ; je kurzor v bloku ?
         jae       EdiBKoB2                 ; kurzor nen° v bloku
         mov       di,si                    ; korekce kurzoru na zaá†tek bloku

; ------ vytvo©en° m°sta pro kopii bloku

EdiBKoB2:call      far ptr InsDat           ; vytvo©en° m°sta pro blok
         jnc       EdiBKB24                 ; operace OK
EdiBKB22:jmp       EdiBKoB9                 ; chyba

; ------ oprava adresy bloku (pokud leë° za odsouvanòm m°stem)

EdiBKB24:mov       ax,si                    ; zaá†tek bloku
         sub       ax,di                    ; rozd°l od kurzoru
         cmp       di,si                    ; je blok za kurzorem ?
         ja        EdiBKoB3                 ; blok je p©ed kurzorem
         add       si,cx                    ; posun adresy bloku
EdiBKoB3:add       word ptr es:[TextBNum],cx ; zvò®en° poátu bajtñ

; ------ p©esun dat bloku

         cld
         rep       movs byte ptr es:[di],es:[si] ; kopie bloku

; ------ oprava poátu ©†dkñ bloku

         mov       bx,es:[TextBBLn]         ; ©†dek poá†tku bloku
         mov       cx,es:[TextBELn]         ; ©†dek konce bloku
         sub       cx,bx                    ; rozd°l ©†dkñ
         add       es:[TextBLin],cx         ; zvò®en° poátu ©†dkñ

; ------ novÇ ukazatele bloku

         or        ax,ax                    ; je kurzor na zaá†tku bloku ?
         jz        EdiBKoB4                 ; kurzor je na zaá†tku bloku

         mov       ax,es:[TextKLin]         ; ©†dek s kurzorem
         mov       es:[TextBBLn],ax         ; je to ©†dek zaá†tku bloku
         add       ax,cx                    ; ©†dek konce bloku
         mov       es:[TextBELn],ax         ; ©†dek konce bloku
         mov       ax,es:[TextKPoz]         ; pozice kurzoru na ©†dku
         xchg      ax,es:[TextBBPz]         ; je to pozice zaá†tku bloku

         or        cx,cx                    ; je v°ce ©†dkñ bloku ?
         jnz       EdiBKoB4                 ; je v°ce ©†dkñ - pozice se nemàn°
         sub       ax,es:[TextBEPz]         ; - rozd°l pozic
         neg       ax
         add       ax,es:[TextKPoz]         ; nov† pozice konce
         mov       es:[TextBEPz],ax         ; nov† pozice konce

; ------ inicializace parametrñ

EdiBKoB4:or        byte ptr es:[TextParm],bit1 ; text modifikov†n
         or        byte ptr ds:[TextEPar],bit2 ; zobrazen° okna
         call      IniTLSum                 ; spoáten° poátu ©†dkñ textu
         call      IniTKLin                 ; inicializace ©†dku s kurzorem

; ------ n†vrat registrñ

EdiBKoB9:pop       di
         pop       si
         pop       cx
         pop       ax
         ret

; -----------------------------------------------------------------------------
;        F6: p©esun bloku
; -----------------------------------------------------------------------------

; ------ test, zda je operace povolena

EditBMvB:call      EdZEShft                 ; ukonáen° oznaáov†n° SHIFT-
         test      byte ptr es:[TextParm],bit0 ; je z†kaz z†pisu ?
         jz        EdiBMvB1                 ; nen° z†kaz z†pisu
EdiBMvB0:ret

EdiBMvB1:test      byte ptr es:[TextParm],bit2 ; je blok zapnut ?
         jz        EdiBMvB0                 ; blok je vypnut

; ------ £schova registrñ

         push      ax
         push      si

; ------ vloëen° ©†dkñ a mezer po kurzor

         call      EditECS                  ; doplnàn° ©†dkñ a mezer
         jc        EdiBMB22                 ; chyba

; ------ stanoven° adresy a dÇlky bloku -> SI, CX

         call      EdiGetBL                 ; stanoven° dÇlky a adresy bloku
         mov       si,di                    ; SI <- adresa zaá†tku bloku
         jbe       EdiBMB22                 ; nen° blok

; ------ adresa k uloëen° bloku -> DI

         mov       di,es:[TextKPoz]         ; pozice kurzoru
         add       di,es:[TextKAdr]         ; offset kurzoru
         add       di,TextBBeg              ; adresa kurzoru

; ------ kontrola, zda nen° kurzor v bloku (je-li, tak oprava na poá†tek)

         cmp       di,si                    ; je kurzor v bloku ?
         jb        EdiBMvB2                 ; nen° v bloku
         mov       bx,si                    ; adresa zaá†tku bloku
         add       bx,cx                    ; posun zaá†tku bloku
         cmp       di,bx                    ; je kurzor v bloku ?
         jbe       EdiBMB22                 ; kurzor je v bloku

; ------ vytvo©en° m°sta pro p©esun bloku

EdiBMvB2:call      far ptr InsDat           ; vytvo©en° m°sta pro blok
         jnc       EdiBMB24
EdiBMB22:jmp       EdiBMvB9                 ; chyba

; ------ oprava adresy bloku (pokud leë° za odsouvanòm m°stem)

EdiBMB24:cmp       di,si                    ; je blok za kurzorem ?
         ja        EdiBMvB3                 ; blok je p©ed kurzorem
         add       si,cx                    ; posun adresy bloku

; ------ p©esun dat bloku

EdiBMvB3:push      si
         push      cx
         cld
         rep       movs byte ptr es:[di],es:[si] ; kopie bloku
         pop       cx
         pop       di

; ------ zru®en° pñvodn°ho bloku

         call      far ptr DelDat           ; zru®en° pñvodn°ho bloku

; ------ poáet ©†dkñ p©esouvanÇho bloku

         mov       bx,es:[TextBBLn]         ; ©†dek poá†tku bloku
         mov       cx,es:[TextBELn]         ; ©†dek konce bloku
         sub       cx,bx                    ; rozd°l ©†dkñ

; ------ oprava ukazatelñ kurzoru

         mov       ax,es:[TextKLin]         ; ©†dek s kurzorem
         cmp       ax,bx                    ; je p©ed zaá†tkem bloku ?
         jb        EdiBMB34                 ; je p©ed zaá†tkem bloku
         je        EdiBMB32                 ; je na ©†dku zaá†tku bloku

         sub       es:[TextKLin],cx         ; posun ©†dku kurzoru
         sub       es:[TextTLin],cx         ; posun tÇë poá†teán°ho ©†dku
         jnc       EdiBMB31
         mov       word ptr es:[TextTLin],0 ; poá†teán° ©†dek = 0

; ------ novÇ ukazatele bloku

EdiBMB31:cmp       ax,es:[TextBELn]         ; je za koncem bloku ?
         jne       EdiBMB34                 ; nen° konec bloku

         mov       ax,es:[TextBEPz]
         sub       ax,es:[TextBBPz]
         sub       es:[TextKPoz],ax         ; posun pozice kurzoru
         jmp       short EdiBMB34

EdiBMB32:mov       ax,es:[TextKPoz]         ; pozice kurzoru
         cmp       ax,es:[TextBBPz]         ; je p©ed zaá†tkem bloku ?
         jbe       EdiBMB34                 ; je p©ed zaá†tkem bloku
         mov       ax,es:[TextBEPz]
         sub       ax,es:[TextBBPz]         ; rozd°l pozic
         sub       es:[TextKPoz],ax         ; posun pozice kurzoru

EdiBMB34:mov       ax,es:[TextKLin]         ; ©†dek s kurzorem
         mov       es:[TextBBLn],ax         ; je to ©†dek zaá†tku bloku
         mov       es:[TextBELn],ax         ; ©†dek konce bloku
         mov       ax,es:[TextKPoz]
         xchg      ax,es:[TextBBPz]         ; je to pozice zaá†tku bloku

         add       es:[TextBELn],cx         ; posun ©†dku konce bloku

         or        cx,cx
         jnz       EdiBMvB4                 ; je v°ce ©†dkñ - pozice se nemàn°
         sub       ax,es:[TextBEPz]         ; - rozd°l pozic
         neg       ax
         add       ax,es:[TextKPoz]         ; nov† pozice konce
         mov       es:[TextBEPz],ax         ; nov† pozice konce

; ------ inicializace parametrñ

EdiBMvB4:or        byte ptr es:[TextParm],bit1 ; text modifikov†n
         or        byte ptr ds:[TextEPar],bit2 ; zobrazen° okna
         call      IniTLSum                 ; spoáten° poátu ©†dkñ textu
         call      IniTTLin                 ; inicializace poá†teán°ho ©†dku
         call      IniTKLin                 ; inicializace ©†dku s kurzorem

; ------ n†vrat registrñ

EdiBMvB9:pop       si
         pop       ax

; ------ novÇ ukazatele

         mov       di,es:[TextTLin]         ; prvn° zobrazenò ©†dek
         mov       cx,es:[TextKPoz]         ; pozice kurzoru na ©†dku
         mov       dx,es:[TextKLin]         ; ©†dek s kurzorem
         ret

; -----------------------------------------------------------------------------
;        Shift-F7: n†hrada
; -----------------------------------------------------------------------------

EditZNah:call      EdZEShft                 ; ukonáen° oznaáov†n° SHIFT-
         test      byte ptr es:[TextParm],bit0 ; je z†kaz z†pisu ?
         jz        EditZNh0                 ; nen° z†kaz z†pisu
         ret

EditZNh0:push      ax
         push      di

; ------ zad†n° textu k vyhled†n°

         push      si
         push      dx
         mov       si,offset ZZNMnLin
         call      far ptr Lin0Menu         ; zad†n° textu k hled†n°
         pop       dx
         pop       si
         jnc       EditZNa1
EditZNa0:jmp       EditZNa9

EditZNa1:call      far ptr GetDat           ; obnoven° adresy okna
         call      far ptr EdiZUsch         ; uschov†n° textu do bufferu
         jc        EditZNa0                 ; nen° nic zad†no

; ------ zad†n° n†hradn°ho textu

         push      si
         push      dx
         mov       si,offset ZZN2MLin
         call      far ptr Lin0Menu         ; zad†n° n†hradn°ho textu
         pop       dx
         pop       si
         jc        EditZNa0                 ; p©eru®en° operace
         call      far ptr GetDat           ; obnoven° adresy okna

; ------ £schova textu do bufferu

         push      si
         push      di
         push      cx
         push      es

         mov       ch,0
         mov       cl,ds:[LinNum]           ; dÇlka textu
         cmp       cx,TextSubX
         jbe       EditZNa2
         mov       cl,TextSubX              ; omezen° dÇlky textu

EditZNa2:cld
         mov       ds:[TextSubN],cx         ; dÇlka n†hradn°ho textu
         push      ds
         pop       es
         mov       si,offset LinBuff        ; buffer textu
         mov       di,offset TextSub        ; n†hradn° text
         rep       movsb                    ; £schova textu do bufferu

         pop       es
         pop       cx
         pop       di
         pop       si

; ------ vyhled†n° ©etàzce

         or        byte ptr ds:[TextEPar],bit4 ; je n†hrada textu
EditZNa5:and       byte ptr ds:[TextEPar],not bit6+bit5 ; ©etàzec nenalezen
         mov       di,es:[TextKPoz]         ; pozice kurzoru
         cmp       di,es:[TextKDel]         ; dÇlka ©†dku s kurzorem
         jbe       EditZN52
         mov       di,es:[TextKDel]
EditZN52:add       di,es:[TextKAdr]         ; offset kurzoru
         add       di,TextBBeg              ; adresa kurzoru
         jmp       EditZN86

EditZNa6:call      EditZ0Hl                 ; prohled†n° bufferu
         jc        EditZNa0                 ; nen° dal®° ©etàzec

; ------ dotaz, zda se m† ©etàzec nahradit

EditZN62:test      byte ptr ds:[TextEPar],bit5 ; n†hrada v®ech ?
         jnz       EditZNa8                 ; n†hrada v®ech

         mov       word ptr ds:[si+MnuHlp],offset TxtMnHl2
         or        byte ptr ds:[TextEPar],bit2 ; zobrazit okno
         mov       es:[TextKLin],dx         ; novò ©†dek s kurzorem
         mov       es:[TextKPoz],cx         ; nov† pozice na ©†dku
;         call      IniTKLin                 ; inicializace ©†dku s kurzorem
         call      far ptr DispMnu          ; zobrazen° okna
EditZNa7:call      far ptr KurEMnu          ; zobrazen° kurzoru
         call      far ptr InpChar          ; áek†n° na zad†n° kl†vesy

         push      di
         mov       di,offset TxtMnHM2       ; menu kl†ves malÇ n†povàdy
         call      far ptr MenKlHlp         ; obsluha menu kl†ves malÇ n†povàdy
         pop       di

         mov       word ptr ds:[si+MnuHlp],offset TxtMnHl1

         xchg      ax,bx
         call      far ptr UpCase
         mov       ah,0
         xchg      ax,bx
         call      far ptr JumpBX

         dw        1bh,EditZNa9             ; Esc p©eru®en°
         dw        'N',EditZNa6             ; "N" dal®° hled†n°
;         dw        0dh,EditZNa8             ; Enter nahradit
         dw        'V',EditZN72             ; nahradit v®echny
         dw        'A',EditZNa8             ; "A" nahradit

         dw        0,EditZNa7

; ------ n†hrada textu

EditZN72:or        byte ptr ds:[TextEPar],bit5 ; nahradit v®echny

; ------ zmàna velikosti dat v bufferu

EditZNa8:push      cx
         mov       cx,ds:[TextSubN]         ; dÇlka n†hradn°ho textu
         sub       cx,ds:[TextFndN]         ; rozd°l dÇlek textñ
         je        EditZN82                 ; dÇlky jsou shodnÇ
         ja        EditZN80                 ; novò text je del®°

         neg       cx
         call      far ptr DelDat           ; zru®en° dat z bufferu
         jc        EditZN82
         neg       cx
         jmp       short EditZN81

EditZN80:call      far ptr InsDat           ; vloëen° dat do bufferu
         jc        EditZN82
EditZN81:add       es:[TextBNum],cx
         clc
EditZN82:pop       cx
         jc        EditZNa9                 ; chyba
         or        byte ptr es:[TextParm],bit1 ; text modifikov†n

; ------ p©enesen° textu do bufferu

         push      si
         push      bp
         mov       bp,cx

         cld
         mov       cx,ds:[TextSubN]         ; dÇlka novÇho textu
         jcxz      EditZN85                 ; nen° nic k uloëen°
         mov       si,offset TextSub        ; n†hradn° text
EditZN83:movsb
         inc       bp                       ; zvò®en° ukazatele pozice
         cmp       word ptr es:[di-2],LF*HI + CR ; je novò ©†dek ?
         jne       EditZN84                 ; nen° novò ©†dek
         xor       bp,bp                    ; zaá†tek ©†dku
         inc       dx                       ; zvò®en° ukazatele ©†dku
EditZN84:loop      EditZN83                 ; dal®° znak

EditZN85:mov       cx,bp
         pop       bp
         pop       si

EditZN86:;dec       di
         ;dec       cx
         call      EditZ0Hl                 ; prohled†n° bufferu
         jc        EditZN88                 ; nen° dal®° ©etàzec
         jmp       EditZN62

EditZN88:;inc       cx

; ------ n†vrat registrñ

EditZNa9:pop       di
         pop       ax

         call      IniTLSum                 ; spoáten° poátu ©†dkñ v bufferu
         call      IniTTLin                 ; inicializace poá†teán°ho ©†dku
         call      IniTKLin                 ; inicializace ©†dku s kurzorem
         ret

; -----------------------------------------------------------------------------
;        Ctrl-L pokraáov†n° v hled†n°
; -----------------------------------------------------------------------------

EditZNHl:call      EdZEShft                 ; ukonáen° oznaáov†n° SHIFT-
         push      ax
         push      di

         test      byte ptr ds:[TextEPar],bit4 ; je n†hrada ?
         jz        EditZHl7                 ; nen° n†hrada
         jmp       EditZNa5                 ; je n†hrada

; -----------------------------------------------------------------------------
;        F7: hled†n°
; -----------------------------------------------------------------------------

EditZHld:call      EdZEShft                 ; ukonáen° oznaáov†n° SHIFT-
         push      ax
         push      di

; ------ zad†n° textu k vyhled†n°

         push      si
         push      dx
         mov       si,offset ZZHMnLin
         call      far ptr Lin0Menu         ; zad†n° textu k hled†n°
         pop       dx
         pop       si
         jc        EditZHl9                 ; p©eru®en° operace
         call      far ptr GetDat           ; obnoven° adresy okna
         call      far ptr EdiZUsch         ; uschov†n° textu do bufferu
         jc        EditZHl9                 ; nen° nic zad†no

; ------ prohled†n° bufferu

         and       byte ptr ds:[TextEPar],not bit4 ; nen° n†hrada
EditZHl7:and       byte ptr ds:[TextEPar],not bit6 ; ©etàzec nenalezen
         mov       di,es:[TextKPoz]         ; pozice kurzoru
         cmp       di,es:[TextKDel]         ; je za koncem ©†dku ?
         jbe       EditZHl8                 ; je to OK
         mov       di,es:[TextKDel]         ; omezen° na konec ©†dku
EditZHl8:add       di,es:[TextKAdr]         ; offset kurzoru
         add       di,TextBBeg              ; adresa kurzoru
         call      EditZ0Hl                 ; prohled†n° bufferu

EditZHl9:pop       di
         pop       ax
         ret

; -----------------------------------------------------------------------------
;   vyhled†n° dal®°ho ©etàzce (od adresy ES:DI, ©†dek DX, pozice CX -> CY nen°)
; -----------------------------------------------------------------------------

EditZ0Hl PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      si
         push      bp

         push      cx
         push      dx
         push      di
         mov       bp,cx                    ; BP <- ukazatel pozice na ©†dku

; ------ p©°prava parametrñ k vyhled†n°

         mov       cx,ds:[TextFndN]         ; dÇlka textu k vyhled†n°
         jcxz      EdiZ0Hl6                 ; ©etàzec nenalezen (nic nezad†no)
         mov       bx,es:[TextBNum]         ; poáet bajtñ v bufferu
         add       bx,TextBBeg              ; adresa konce dat
         sub       bx,di                    ; poáet zbylòch dat v bufferu
         jbe       EdiZ0Hl6                 ; nic nezbylo
         sub       bx,cx                    ; poáet zbylòch ©etàzcñ
         jbe       EdiZ0Hl6                 ; nenalezeno

; ------ zvò®en° ukazatele pozice v textu

EdiZ0Hl2:inc       di                       ; zvò®en° adresy v bufferu
         inc       bp                       ; zvò®en° ukazatele pozice na ©†dku
         cmp       word ptr es:[di-2],LF*HI + CR ; je novò ©†dek ?
         jne       EdiZ0Hl3                 ; nen° novò ©†dek
         xor       bp,bp                    ; zaá†tek ©†dku
         inc       dx                       ; zvò®en° ukazatele ©†dku

; ------ porovn†n°, zda je to hledanò text

EdiZ0Hl3:push      di
         push      cx

         mov       si,offset TextFnd-1
EdiZ0Hl4:mov       al,es:[di]
         inc       di
         inc       si
         call      far ptr UpCase           ; konverze na velkÇ p°smeno
EdiZ0Hl5:cmp       al,ds:[si]
         loope     EdiZ0Hl4

         pop       cx
         pop       di

         je        EdiZ0Hl8                 ; ©etàzec nalezen
         dec       bx
         jnz       EdiZ0Hl2                 ; dal®° pokus

; ------ n†vrat registrñ - ©etàzce nenalezen

EdiZ0Hl6:test      byte ptr ds:[TextEPar],bit6
         jnz       EdiZ0Hl7                 ; ©etàzec byl jië nalezen

         mov       al,byte ptr ds:[TextFndN] ; dÇlka hledanÇho textu
         mov       ds:[ZZ2MnPl2],al         ; dÇlka textu hl†®en°

         mov       si,offset ZZ2MnLin
         call      far ptr Lin0Menu         ; hl†®en° - text nenalezen

EdiZ0Hl7:stc                                ; p©°znak chyby - nenalezen
         pop       di
         pop       dx
         pop       cx
         jmp       short EdiZ0Hl9

; ------ zru®en° registrñ v z†sobn°ku - ©etàzec nalezen OK

EdiZ0Hl8:mov       cx,bp                    ; CX <- nalezen† pozice na ©†dku
         add       sp,3*2                   ; zru®en° registrñ v z†sobn°ku
         or        byte ptr ds:[TextEPar],bit6 ; ©etàzec nalezen
;         clc                                ; p©°znak nalezen° ©etàzce OK

EdiZ0Hl9:pop       bp
         pop       si
         pop       bx
         pop       ax
         ret

EditZ0Hl ENDP

; -----------------------------------------------------------------------------
;        £schova textu k hled†n° do bufferu (CY=nen° text)
; -----------------------------------------------------------------------------

EdiZUsch PROC      FAR

; ------ £schova textu do bufferu

         push      ax
         push      cx
         push      si
         push      di
         push      es

         mov       ch,0
         mov       cl,ds:[LinNum]           ; dÇlka hledanÇho textu
         cmp       cl,TextFndX
         jbe       EdiZUsc1
         mov       cl,TextFndX

EdiZUsc1:mov       ds:[TextFndN],cx         ; dÇlka textu
;         mov       ds:[TextFnd0],cl         ; dÇlka textu pro hl†®en°
;         mov       ds:[ZZ2MnPl2],cl         ; dÇlka textu pro hl†®en°
         stc
         jcxz      EdiZUsc4                 ; nen° text

         push      ds
         pop       es                       ; ES <- datovò segment
         mov       di,offset TextFnd
         mov       si,offset LinBuff
         cld
EdiZUsc2:lodsb
         call      far ptr UpCase           ; konverze na velkÇ p°smeno
EdiZUsc3:stosb
         loop      EdiZUsc2
         clc                                ; operace OK - je text

EdiZUsc4:pop       es
         pop       di
         pop       si
         pop       cx
         pop       ax
         ret

EdiZUsch ENDP

; -----------------------------------------------------------------------------
;        Shift-F9: vyst©edàn° ©†dku
; -----------------------------------------------------------------------------

EditZCen:call      EdZEShft                 ; ukonáen° oznaáov†n° SHIFT-
         test      byte ptr es:[TextParm],bit0 ; je z†kaz z†pisu ?
         jz        EditZCn1                 ; nen° z†kaz z†pisu
EditZCn0:ret

EditZCn1:cmp       word ptr es:[TextKEnd],0 ; je nàco na ©†dku ?
         je        EditZCn0                 ; nen° nic na ©†dku
         push      ax
         push      bp
         push      si
         push      di

; ------ p©°prava k nalezen° poá†tku textu

         mov       bp,es:[TextKEnd]         ; BP <- dÇlka textu na ©†dku
         mov       di,es:[TextKAdr]         ; offset ©†dku s kurzorem
         add       di,TextBBeg              ; adresa ©†dku s kurzorem

; ------ zji®tàn° dÇlky textu na ©†dku

         push      di
EditZCn2:cmp       byte ptr es:[di]," "     ; je mezera ?
         jne       EditZCn3                 ; je zaá†tek textu
         inc       di                       ; zvò®en° ukazatele textu
         dec       bp                       ; sn°ëen° á°taáe dÇlky textu
         jnz       EditZCn2                 ; dal®° znak
EditZCn3:pop       di

; ------ stanoven° poëadovanÇ dÇlky textu ©†dku -> SI

         mov       si,ds:[TextEOkr]         ; pravò okraj
         sub       si,bp                    ; zbytek na okraje
         jnc       EditZCn4                 ; je to OK
         xor       si,si                    ; omezen°
EditZCn4:shr       si,1                     ; polovina na okraje
         add       si,bp                    ; poëadovan† dÇlka ©†dku

; ------ poáet mezer k vloëen° nebo zru®en°

         push      cx
         mov       cx,es:[TextKEnd]         ; dÇlka textu na ©†dku
         sub       cx,si                    ; rozd°l mezer
         mov       si,cx                    ; SI <- sn°ëen° pozice
         jb        EditZCn5                 ; bude vloëen° mezer

; ------ zru®en° mezer

         call      far ptr DelDat           ; zru®en° dat
         clc                                ; p©°znak operace OK
         jmp       short EditZCn6

; ------ vloëen° mezer

EditZCn5:neg       cx                       ; poáet mezer k vloëen°
         call      far ptr InsDat           ; vloëen° dat
         jc        EditZCn6                 ; chyba

         mov       al," "                   ; mezery k vloëen°
         cld
         rep       stosb                    ; uloëen° mezer

EditZCn6:pop       cx

; ------ posun ukazatelñ

         or        byte ptr es:[TextParm],bit1 ; text modifikov†n
         or        byte ptr ds:[TextEPar],bit2 ; zobrazen° okna
         sub       word ptr es:[TextBNum],si ; sn°ëen° poátu bajtñ v bufferu
         sub       cx,si                    ; posun kurzoru
         jns       EditZC62                 ; nen° podteáen°
         xor       cx,cx                    ; omezen° p©i podteáen°
EditZC62:sub       word ptr es:[TextKEnd],si ; posun dÇlky textu ©†dku
         sub       word ptr es:[TextKDel],si ; posun dÇlky ©†dku

; ------ oprava poá†tku bloku

         cmp       dx,es:[TextBBLn]         ; je ©†dek se zaá†tkem bloku ?
         jne       EditZC72                 ; nen° ©†dek se zaá†tkem bloku
         sub       word ptr es:[TextBBPz],si ; posun pozice poá†tku bloku
         jns       EditZC72
         mov       word ptr es:[TextBBPz],0

; ------ oprava konce bloku

EditZC72:cmp       dx,es:[TextBELn]         ; je ©†dek s koncem bloku ?
         jne       EditZCn9                 ; nen° ©†dek s koncem bloku
         sub       word ptr es:[TextBEPz],si ; posun pozice konce bloku
         jns       EditZCn9
         mov       word ptr es:[TextBEPz],0 ; oprava pozice konce bloku

; ------ n†vrat registrñ

EditZCn9:pop       di
         pop       si
         pop       bp
         pop       ax
         ret

; -----------------------------------------------------------------------------
;        F8: zru®en° bloku
; -----------------------------------------------------------------------------

EditBDlB:call      EdZEShft                 ; ukonáen° oznaáov†n° SHIFT-
         test      byte ptr es:[TextParm],bit0 ; je z†kaz z†pisu ?
         jz        EdiBDlB1                 ; nen° z†kaz z†pisu
EdiBDlB0:ret

EdiBDlB1:test      byte ptr es:[TextParm],bit2 ; je blok zapnut ?
         jz        EdiBDlB0                 ; blok je vypnut

; ------ £schova registrñ (zachovat po©ad° !)

         push      di
         push      cx                       ; (CX naposledy !)

; ------ p©°prava ukazatelñ bloku

         call      EdiGetBL                 ; stanoven° dÇlky a adresy bloku
         jbe       EdiBDB12                 ; nen° co ru®it

; ------ zru®en° bloku

         call      far ptr DelDat           ; zru®en° bloku
         jnc       EdiBDB14
EdiBDB12:jmp       EdiBDlB9                 ; chyba

; ------ posun ukazatelñ v souboru

EdiBDB14:sub       word ptr es:[TextBNum],cx ; sn°ëen° poátu bajtñ
         or        byte ptr es:[TextParm],bit1 ; text modifikov†n
         or        byte ptr ds:[TextEPar],bit2 ; zobrazen° okna

; ------ oprava ukazatele kurzoru

         pop       cx                       ; pozice kurzoru

         push      ax
         mov       ax,es:[TextBELn]         ; ©†dek konce bloku
         sub       ax,es:[TextBBLn]         ; poáet zru®enòch ©†dkñ
         sub       es:[TextBLin],ax         ; sn°ëen° poátu ©†dkñ

         cmp       dx,es:[TextBBLn]         ; je p©ed zaá†tkem bloku ?
         jne       EdiBDlB2
         cmp       cx,es:[TextBBPz]
EdiBDlB2:jbe       EdiBDlB5                 ; je p©ed zaá†tkem bloku - nemàn° se

         cmp       dx,es:[TextBELn]         ; je za koncem bloku ?
         jne       EdiBDlB3
         cmp       cx,es:[TextBEPz]
EdiBDlB3:jae       EdiBDlB4                 ; je za koncem bloku

         mov       cx,es:[TextBBPz]         ; plat° poá†tek bloku
         mov       dx,es:[TextBBLn]
         jmp       short EdiBDlB5

EdiBDlB4:cmp       dx,es:[TextBELn]         ; je ©†dek s koncem bloku ?
         jne       EdiBDB44
         sub       cx,es:[TextBEPz]         ; posun od konec bloku
         add       cx,es:[TextBBPz]         ; posun o poá†tek bloku
EdiBDB44:sub       dx,ax                    ; oprava ©†dku s kurzorem

; ------ oprava ukazatelñ bloku

EdiBDlB5:sub       es:[TextBELn],ax         ; zaá†tek a konce jsou shodnÇ
         mov       ax,es:[TextBBPz]         ; pozice zaá†tku bloku
         mov       es:[TextBEPz],ax         ; pozice je takÇ shodn†
         pop       ax

; ------ aktualizace kurzoru

         mov       es:[TextKLin],dx         ; novò ©†dek s kurzorem
         mov       es:[TextKPoz],cx         ; nov† pozice na ©†dku
         or        byte ptr ds:[TextEPar],bit2 ; zobrazen° okna
         call      IniTTLin                 ; inicializace prvn°ho ©†dku
         call      IniTKLin                 ; inicializace ©†dku s kurzorem

EdiBDlB8:push      cx

; ------ n†vrat registrñ

EdiBDlB9:pop       cx
         pop       di
         ret

; -----------------------------------------------------------------------------
;        Shift-F3: uloëen° bloku
; -----------------------------------------------------------------------------

EditBWrB PROC      NEAR

         call      EdZEShft                 ; ukonáen° oznaáov†n° SHIFT-
         test      byte ptr es:[TextParm],bit2 ; je blok zapnut ?
         jnz       EdiBWrB2                 ; blok je zapnut
         ret

EdiBWrB2:push      ax
         push      cx
         push      dx
         push      di

; ------ zad†n° jmÇna souboru

         push      si
         mov       si,offset SEZBMLin
         call      far ptr Lin0Menu         ; zad†n° jmÇna souboru
         pop       si
         jc        EditBWB9                 ; p©eru®en° operace
         call      far ptr GetDat           ; obnoven° adresy okna

; ------ normalizace jmÇna souboru

         push      si
         push      es
         call      far ptr NormFilL         ; normalizace jmÇna souboru
         call      far ptr FullFile         ; p©evod na plnÇ jmÇno
         pop       es
         pop       si
         jcxz      EditBWB9                 ; nen° nic zad†no

; ------ stanoven° velikosti souboru

         call      EdiGetBL                 ; stanoven° dÇlky a adresy bloku
         jbe       EditBWB9                 ; nen° co ukl†dat

; ------ otev©en° souboru

         push      si
         push      es

         push      ds
         pop       es
         mov       si,offset LinBuff        ; buffer jmÇna souboru
         push      cx
         call      far ptr ExisFile         ; test, zda soubor jië existuje
         pop       cx
         jc        EditBWB5                 ; soubor neexistuje nebo chyba

         call      far ptr OpenW            ; otev©en° pro z†pis
         jc        EditBWB4                 ; nàjak† chyba
         call      far ptr TestDev          ; test, zda to je za©°zen°
         jnc       EditBWB6                 ; je to za©°zen°
         call      far ptr ClosFile         ; uzav©en° souboru

EditBWB4:push      si
         mov       si,offset ZX1MnLin
         call      far ptr Lin0MenF
         pop       si
         jc        EditBWB6                 ; p©eru®en° operace

EditBWB5:call      far ptr ModiWDir         ; modifikace okna
         call      far ptr CreatFil         ; vytvo©en° souboru

EditBWB6:pop       es
         pop       si

         pushf
         push      ax
         mov       ax,ds:[si+EdMnuSeg]
         call      far ptr GetDat
         pop       ax
         popf

         jc        EditBWB9                 ; chyba

; ------ z†pis souboru

         push      si
         mov       si,di
         call      far ptr WritFile         ; z†pis dat do souboru
         pop       si

         call      far ptr ClosFile         ; uzav©en° souboru

; ------ n†vrat registrñ

EditBWB9:pop       di
         pop       dx
         pop       cx
         pop       ax
         ret

EditBWrB ENDP

; -----------------------------------------------------------------------------
;        Shift-F5: naáten° bloku
; -----------------------------------------------------------------------------

EditBReB PROC      NEAR

         call      EdZEShft                 ; ukonáen° oznaáov†n° SHIFT-
         push      ax
         push      cx
         push      dx
         push      di

; ------ zad†n° jmÇna souboru

         push      si
         mov       si,offset SENBMLin       ; menu zad†n° souboru
         call      far ptr Lin0Menu         ; zad†n° jmÇna souboru
         pop       si
         jc        EditBRB1                 ; p©eru®en° operace
         call      far ptr GetDat           ; obnoven° adresy okna

; ------ normalizace jmÇna souboru

         push      si
         push      es
         call      far ptr NormFilL         ; normalizace jmÇna souboru
         call      far ptr FullFile         ; p©evod na plnÇ jmÇno
         pop       es
         pop       si
         jcxz      EditBRB1                 ; nen° nic zad†no

; ------ otev©en° souboru

         push      si
         push      es

         push      ds
         pop       es
         mov       si,offset LinBuff        ; buffer jmÇna souboru
         call      far ptr OpenR            ; otev©en° souboru pro áten°

         pop       es
         pop       si
         jnc       EditBRB2

; ------ soubor k naáten° nenalezen

         mov       byte ptr ds:[ENFMnLP1],0 ; nen° jmÇno souboru
         mov       di,offset ENFMnLin
         call      far ptr Lin0MenP         ; chybovÇ hl†®en°
EditBRB1:jmp       EditBRB9                 ; chyba

; ------ stanoven° velikosti souboru

EditBRB2:call      far ptr SizeFile         ; poskytnut° velikosti souboru
         jc        EditBRB3                 ; nàjak† chyba
         or        bx,bx
         jnz       EditBRB3                 ; soubor p©°li® velkò

; ------ normalizace kurzoru

         push      ax
         mov       ax,ds:[si+EdMnuSeg]      ; segment okna
         call      EditECS                  ; doplnàn° ©†dkñ a mezer
         jc        EdiBRB23                 ; chyba

; ------ vytvo©en° m°sta pro naáten° souboru

         mov       di,es:[TextKPoz]         ; pozice kurzoru
         add       di,es:[TextKAdr]         ; offset kurzoru
         add       di,TextBBeg              ; adresa kurzoru
         call      far ptr InsDat           ; vytvo©en° m°sta

EdiBRB23:pop       ax
         jnc       EditBRB4

EditBRB3:jmp       EditBRB8                 ; chyba

; ------ naáten° souboru do pamàti

EditBRB4:mov       bx,cx
         call      far ptr ResFile          ; resetov†n° souboru
         call      far ptr ReadFile         ; naáten° souboru
         jc        EditBRB7                 ; chyba
         xchg      bx,cx
         cmp       bx,cx
         jne       EditBRB7                 ; data nesouhlas° (?)

; ------ uzav©en° souboru

         call      far ptr ClosFile         ; uzav©en° souboru

; ------ nastaven° poá†tku bloku

         add       es:[TextBNum],cx         ; zvò®en° poátu bajtñ v bufferu
         mov       ax,es:[TextKLin]         ; ©†dek s kurzorem
         mov       es:[TextBBLn],ax         ; ©†dek poá†tku bloku
         mov       es:[TextBELn],ax         ; ©†dek konce bloku
         mov       ax,es:[TextKPoz]         ; pozice kurzoru
         mov       es:[TextBBPz],ax         ; pozice poá†tku bloku
         mov       es:[TextBEPz],ax         ; pozice konce bloku
         or        byte ptr es:[TextParm],bit1+bit2 ; text modifik., blok zapnut
         or        byte ptr ds:[TextEPar],bit2 ; zobrazit v®e
         call      IniTKLin                 ; inicializace ©†dku s kurzorem

; ------ vyhled†n° konce bloku

         jcxz      EditBRB9
EditBRB5:cmp       byte ptr es:[di],CR
         jne       EditBRB6
         cmp       byte ptr es:[di+1],LF
         jne       EditBRB6

         inc       word ptr es:[TextBLin]
         mov       word ptr es:[TextBEPz],0
         inc       word ptr es:[TextBELn]
         inc       di
         dec       cx
         jz        EditBRB9
         inc       di
         dec       cx
         jz        EditBRB9
         jmp       short EditBRB5

EditBRB6:inc       di
         inc       word ptr es:[TextBEPz]
         loop      EditBRB5
         jmp       short EditBRB9

; ------ p©i chybà zru®en° bloku

EditBRB7:push      ax
         mov       ax,ds:[si+EdMnuSeg]      ; segment okna
         call      far ptr DelDat           ; zru®en° bloku v pamàti
         pop       ax
         stc

; ------ uzav©en° souboru

EditBRB8:pushf
         call      far ptr ClosFile         ; uzav©en° souboru
         popf

; ------ n†vrat registrñ

EditBRB9:pop       di
         pop       dx
         pop       cx
         pop       ax
         ret

EditBReB ENDP

; -----------------------------------------------------------------------------
;        stanoven° adresy DI a dÇlky bloku CX (ES=adresa okna) (CY=nen° blok)
; -----------------------------------------------------------------------------

EdiGetBL PROC      NEAR

         call      EdiGetBE                 ; adresa konce bloku -> DI
         mov       cx,di                    ; CX <- adresa konce bloku
         call      EdiGetBB                 ; adresa zaá†tku bloku -> DI
         sub       cx,di                    ; dÇlka dat
         ret

EdiGetBL ENDP

; -----------------------------------------------------------------------------
;        poskytnut° adresy DI zaá†tku bloku (ES=adresa okna)
; -----------------------------------------------------------------------------

EdiGetBB PROC      NEAR

         push      bx
         mov       bx,TextBBPz              ; pozice poá†tku bloku
         jmp       short EdiGtBE1

EdiGetBB ENDP

; -----------------------------------------------------------------------------
;        poskytnut° adresy DI konce bloku (ES=adresa okna)
; -----------------------------------------------------------------------------

EdiGetBE PROC      NEAR

         push      bx
         mov       bx,TextBEPz              ; pozice konce bloku

EdiGtBE1:push      cx
         push      dx

         mov       dx,es:[bx+TextBELn-TextBEPz] ; ©†dek zaá†tku/konce bloku
         call      SrcLine                  ; nalezen° ©†dku -> DI
         call      LenLine                  ; stanoven° dÇlky ©†dku DI -> CX

         cmp       cx,es:[bx]               ; je pozice bloku platn† ?
         jbe       EdiGtBE2                 ; omezen° na dÇlku ©†dku
         mov       cx,es:[bx]               ; pozice bloku je platn†
EdiGtBE2:add       di,cx                    ; adresa konce bloku

         pop       dx
         pop       cx
         pop       bx
         ret

EdiGetBE ENDP

; -----------------------------------------------------------------------------
;        Ctrl-Y zru®en° ©†dku
; -----------------------------------------------------------------------------

EdiZDelL:call      EdZEShft                 ; ukonáen° oznaáov†n° SHIFT-
         push      ax
         push      bx
         push      cx
         push      dx
         push      di

         mov       di,es:[TextKAdr]         ; offset ©†dku s kurzorem
         add       di,TextBBeg              ; adresa ©†dku

         cmp       di,es:[0]                ; je platnò ©†dek ?
         jae       EditDlL7                 ; nen° platnò ©†dek
         test      byte ptr es:[TextParm],bit0 ; je z†kaz z†pisu ?
         jnz       EditDlL7                 ; je z†kaz z†pisu

         mov       bx,di
         add       bx,es:[TextKDel]         ; adresa konce ©†dku
         cmp       bx,es:[0]                ; jsou dal®° data ?
         jae       EditDlL4                 ; nejsou dal®° data
         inc       bx
         inc       bx                       ; váetnà znakñ CRLF
EditDlL4:mov       cx,bx
         sub       cx,di                    ; dÇlka ©†dku
         call      far ptr DelDat           ; zru®en° ©†dku
         jc        EditDlL7                 ; nàjak† chyba
         dec       word ptr es:[TextBLin]   ; sn°ëen° poátu ©†dkñ
         sub       word ptr es:[TextBNum],cx ; sn°ëen° poátu bajtñ
         or        byte ptr es:[TextParm],bit1 ; text modifikov†n
         or        byte ptr ds:[TextEPar],bit2 ; zobrazen° okna
         call      IniTKLin                 ; inicializace ©†dku s kurzorem

         mov       ax,es:[TextKLin]         ; ©†dek s kurzorem
         cmp       ax,es:[TextBBLn]         ; posouv† se poá†tek bloku ?
         ja        EditDlL5                 ; poá†tek bloku se neposouv†
         je        EdiDlL44                 ; je ©†dek s poá†tkem bloku
         dec       word ptr es:[TextBBLn]   ; posun ©†dku poá†tku bloku
         jmp       short EditDlL5
EdiDlL44:mov       word ptr es:[TextBBPz],0 ; pozice bloku na poá†tek

EditDlL5:cmp       ax,es:[TextBELn]         ; posouv† konec bloku ?
         ja        EditDlL7                 ; konec bloku se neposouv†
         jb        EditDlL6                 ; konec bloku se posouv†
         mov       word ptr es:[TextBEPz],0 ; pozice bloku na poá†tek
         jmp       short EditDlL7

EditDlL6:dec       word ptr es:[TextBELn]   ; posun ©†dku konce bloku

EditDlL7:pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
;        zform†tov†n° ©†dku s kurzorem
; -----------------------------------------------------------------------------
; VSTUP: AX=segment okna
;        BX=posledn° znak
;        CX=pozice kurzoru na ©†dku
;        DX=©†dek kurzoru
;        ES=segment okna
; VùSTUP: CX=nov† pozice kurzoru na ©†dku
;         DX=novò ©†dek s kurzorem
; -----------------------------------------------------------------------------
;˛
; ------ uloëen° ukazatelñ kurzoru

EditKFrm:mov       es:[TextKPoz],cx         ; pozice kurzoru
         mov       es:[TextKLin],dx         ; novò ©†dek s kurzorem
         mov       word ptr ds:[TextEPoz],0 ; poá†teán° pozice ©†dku
         or        byte ptr ds:[TextEPar],bit0 ; nutnÇ zobrazen° kurzoru
         call      IniTKLin                 ; inicializace ©†dku s kurzorem

; ------ £schova registrñ

         push      bp
         push      bx
         push      cx
         push      dx
         push      si
         push      di

; ------ p©°prava parametrñ aktivn°ho ©†dku

         and       byte ptr ds:[TextForP],not bit0+bit1 ; nebyly ©†dky
         mov       di,es:[TextKAdr]         ; offset ©†dku s kurzorem
         add       di,TextBBeg-2            ; adresa aktivn°ho ©†dku - 2
         xor       bx,bx                    ; BX <- 0 dÇlka aktivn°ho ©†dku

; ------ zji®tàn° parametrñ tohoto ©†dku

         call      EdiLNxtP                 ; zji®tàn° parametrñ ©†dku
         jc        EditKFr6                 ; ©†dek nen° platnò

; ------ p©esun parametrñ pro aktivn° ©†dek

         add       di,bx                    ; adresa dal®°ho ©†dku - 2
         inc       di
         inc       di                       ; adresa dal®°ho ©†dku
         mov       cx,si                    ; poá†tek textu aktivn°ho ©†dku
         mov       bx,bp                    ; dÇlka aktivn°ho ©†dku

; ------ minimalizace mezer na aktivn°m ©†dku -> BX=nov† dÇlka

         call      EdiGMini                 ; minimalizace mezer na ©†dku

; ------ rozdàlen° ©†dku

         call      EditLRoz                 ; rozdàlen° dlouhÇho ©†dku
         jc        EditKFr6                 ; chyba pamàti
         jz        EditKFr6                 ; ©†dek nebyl rozdàlen

; ------ maximalizace mezer na ©†dku

         call      EdiGMaxi                 ; maximalizace mezer

; ------ n†vrat registrñ

EditKFr6:pop       di
         pop       si
         pop       dx
         pop       cx                       ; dÇlka ©†dku s kurzorem
         pop       bx
         pop       bp

; ------ oprava kurzoru, pokud byl z†pis mezery na pravò okraj

         cmp       dx,es:[TextKLin]         ; zmànil se ©†dek s kurzorem ?
         jne       EditKFr7                 ; ©†dek se zmànil
         cmp       cx,es:[TextKPoz]         ; zmànila se pozice ?
         jne       EditKFr7                 ; pozice se zmànila
         cmp       bl," "                   ; byla to mezera ?
         jne       EditKFr7                 ; nebyla to mezera
         inc       word ptr es:[TextKLin]   ; zvò®en° ©†dku s kurzorem
         mov       word ptr es:[TextKPoz],0 ; kurzor na poá†tek ©†dku
         call      IniTKLin                 ; inicializace ©†dku s kurzorem

; ------ nov† pozice kurzoru

EditKFr7:mov       dx,es:[TextKLin]         ; novò ©†dek s kurzorem
         mov       cx,es:[TextKPoz]         ; pozice kurzoru
         ret

; -----------------------------------------------------------------------------
;        Ctrl-B zform†tov†n° odstavce
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: AX=á°slo segmentu
;                   BX=celkov† dÇlka aktivn°ho ©†dku
;                   CX=poá†tek textu aktivn°ho ©†dku
;                   DX=ukazatel á°sla ©†dku
;                   SI=poá†tek textu dal®°ho ©†dku
;                   DI=adresa zaá†tku aktivn°ho ©†dku
;                   BP=celkov† dÇlka dal®°ho ©†dku (0=parametry nezn†mÇ)
; -----------------------------------------------------------------------------
;˛
EditBFor:call      EdZEShft                 ; ukonáen° oznaáov†n° SHIFT-
         test      byte ptr es:[TextParm],bit0 ; je z†kaz z†pisu ?
         jz        EditBFr0                 ; nen° z†kaz z†pisu
         ret

EditBFr0:push      si
         push      bp
         push      di

; ------ p©°prava parametrñ k form†tov†n°

         and       byte ptr ds:[TextForP],not bit0+bit1 ; nebyly ©†dky
         mov       di,es:[TextKAdr]         ; offset aktu†ln°ho ©†dku
         add       di,TextBBeg-2            ; adresa ©†dku - 2
         xor       bx,bx                    ; BX <- 0 aktu†ln° ©†dek neplatnò

; ------ zji®tàn° parametrñ prvn°ho ©†dku

         call      EdiLNxtP                 ; zji®tàn° parametrñ ©†dku
         jc        EditBFr8                 ; prvn° ©†dek nen° platnò

; ------ p©esun parametrñ pro novò aktivn° ©†dek

EditBFr1:add       di,bx                    ; adresa dal®°ho ©†dku - 2
         inc       di
         inc       di                       ; adresa dal®°ho ©†dku
         mov       cx,si                    ; poá†tek textu aktivn°ho ©†dku
         mov       bx,bp                    ; dÇlka aktivn°ho ©†dku
         call      EditLUlP                 ; uloëen° parametrñ ©†dku

; ------ minimalizace mezer na aktivn°m ©†dku -> BX=nov† dÇlka

         call      EdiGMini                 ; minimalizace mezer na ©†dku

; ------ doplnàn° mezer na zaá†tek aktivn°ho ©†dku

         call      EdiBIZac                 ; vloëen° poá†teán°ch mezer
         jc        EditBFr8                 ; chyba pamàti

; ------ zji®tàn° poá†tku druhÇho ©†dku, nen°-li zji®tàn

         test      byte ptr ds:[TextForP],bit1 ; jsou parametry druhÇho ©†dku ?
         jnz       EditBFr3                 ; byl jië druhò ©†dek

         push      cx
         call      EdiLNxtP                 ; parametry dal®°ho ©†dku
         jc        EditBFr2                 ; nen° dal®° ©†dek
         mov       cx,si                    ; poá†tek textu dal®°ho ©†dku
         call      EditLUlP                 ; uloëen° parametrñ ©†dku
EditBFr2:pop       cx

; ------ rozdàlen° dlouhÇho ©†dku

EditBFr3:call      EditLRoz                 ; rozdàlen° dlouhÇho ©†dku
         jc        EditBFr8                 ; chyba pamàti
         jnz       EditBFr6                 ; ©†dek byl rozdàlen

; ------ stanoven° parametrñ p©°®t°ho ©†dku

EditBFr4:call      EdiLNxtP                 ; parametry dal®°ho ©†dku
         jc        EditBFr8                 ; nen° dal®° ©†dek - konec

; ------ spojen° kr†tkòch ©†dkñ

         call      EdiLSpoj                 ; spojen° ©†dkñ

; ------ minimalizace mezer na aktivn°m ©†dku -> BX=nov† dÇlka

         call      EdiGMini                 ; minimalizace mezer na ©†dku

; ------ test, zda je ©†dek jië dost dlouhò

         cmp       bx,ds:[TextEOkr]         ; je ©†dek jië dost dlouhò ?
         jb        EditBFr4                 ; ©†dek je je®tà kr†tkò

; ------ rozdàlen° ©†dku, je-li dlouhò

         call      EditLRoz                 ; rozdàlen° ©†dku
         jc        EditBFr8                 ; chyba pamàti

; ------ doplnàn° mezer na maximum

EditBFr6:call      EdiGMaxi                 ; maximalizace mezer
         jc        EditBFr8                 ; chyba pamàti

; ------ p©°prava pro dal®° ©†dek

         inc       dx                       ; zvò®en° ukazatele ©†dku kurzoru
         or        bp,bp                    ; je dal®° ©†dek ?
         jnz       EditBFr1
         call      EdiLNxtP                 ; dal®° ©†dek
         jnc       EditBFr1

; ------ korekce kurzoru, pokud nebyl ë†dnò ©†dek

EditBFr8:inc       dx                       ; jinak p©eskoáen° ©†dku

; ------ n†vrat registrñ

EditBFr9:or        byte ptr ds:[TextEPar],bit2 ; zobrazen° okna
         pop       di
         pop       bp
         pop       si
         xor       cx,cx                    ; CX <- 0 pozice na zaá†tek ©†dku
         ret

; -----------------------------------------------------------------------------
;        vloëen° mezer na zaá†tek ©†dku
; -----------------------------------------------------------------------------
; VSTUP: AX=segment okna
;        BX=celkov† dÇlka aktivn°ho ©†dku bez CR/LF
;        CX=poá†teán° pozice zaá†tku textu aktivn°ho ©†dku
;        ES:DI=adresa zaá†tku aktivn°ho ©†dku
; VùSTUP: BX=nov† dÇlka aktivn°ho ©†dku
;         CX=nov† poá†teán° pozice textu aktivn°ho ©†dku
;         CY=chyba pamàti
; -----------------------------------------------------------------------------

EdiBIZac PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      dx
         push      di

; ------ mezery se do prvn°ho a druhÇho ©†dku nevkl†daj°

         test      byte ptr ds:[TextForP],bit1 ; byl druhò ©†dek ?
         jz        EdiBIZc9                 ; nebyl druhò ©†dek

; ------ poáet mezer k vloëen°

         add       di,cx                    ; adresa zaá†tku textu v ©†dku
         mov       dx,cx                    ; souáasnò poá†tek ©†dku
         mov       cx,ds:[TextEPoz]         ; form†tovac° poá†tek ©†dku
         sub       cx,dx                    ; poëadovanò poáet mezer k vloëen°
         jz        EdiBIZc8                 ; nen° t©eba nic vkl†dat
         cmc
         jnc       EdiBIZc8                 ; chybnò poá†tek ©†dku (?!)

; ------ vytvo©en° m°sta k vloëen° mezer

         call      far ptr InsDat           ; vytvo©en° m°sta
         jc        EdiBIZc8                 ; chyba

; ------ zvò®en° ukazatelñ textu

         add       dx,cx                    ; zvò®en° aktu†ln° poá†teán° pozice
         add       bx,cx                    ; zvò®en° celkovÇ dÇlky ©†dku
         add       word ptr es:[TextBNum],cx ; zvò®en° poátu bajtñ v bufferu
         or        byte ptr es:[TextParm],bit1 ; p©°znak - text modifikov†n

; ------ z†pis mezer do vytvo©enÇho m°sta

         cld
         mov       al," "
         rep       stosb                    ; z†pis mezer
                                          ;* zde je NC = operace OK
; ------ n†vrat registrñ

EdiBIZc8:mov       cx,dx                    ; CX <- novò poá†tek textu ©†dku
EdiBIZc9:pop       di
         pop       dx
         pop       ax
         ret

EdiBIZac ENDP

; -----------------------------------------------------------------------------
;        rozdàlen° ©†dku (©†dek m† minimalizovanÇ mezery !)
; -----------------------------------------------------------------------------
; VSTUP: AX=segment okna
;        BX=aktu†ln° dÇlka ©†dku (bez koncovÇho CR/LF)
;        CX=pozice poá†tku textu na ©†dku
;        DX=á°slo ©†dku
;        ES:DI=adresa poá†tku ©†dku
; VùSTUP: BX=nov† aktu†ln° dÇlka ©†dku
;         SI=pozice poá†tku textu dal®°ho ©†dku
;         BP=dÇlka dal®°ho ©†dku (0=nebyl rozdàlen)
;         CY=chyba pamàti
;         ZY=nic se nerozdàlilo
; -----------------------------------------------------------------------------

EditLRoz PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      di                       ; DI mus° bòt jako posledn° !!!

; ------ p©°prava registrñ

         mov       bp,di                    ; BP <- £schova zaá†tku ©†dku
         add       bp,cx                    ; BP <- poá†tek textu ©†dku
         add       di,ds:[TextEOkr]         ; DI <- adresa p©elomu ©†dku

; ------ test, zda je ©†dek del®° neë pravò okraj

         cmp       bx,ds:[TextEOkr]         ; je ©†dek del®° neë okraj ?
         jbe       EdiLRoz6                 ; nen° t©eba rozdàlen°
         cmp       cx,ds:[TextEOkr]         ; je ©†dek za pravòm okrajem ?
         jae       EdiLRoz6                 ; ©†dek je za pravòm okrajem

; ------ nalezen° zaá†tku posledn°ho slova

         mov       cx,ds:[TextEOkr]         ; pozice konce ©†dku
EdiLRoz1:cmp       byte ptr es:[di]," "     ; je mezera mezi slovy ?
         je        EdiLRoz2                 ; nalezena mezera
         cmp       di,bp                    ; je jië zaá†tek textu ?
         jbe       EdiLRoz4                 ; je jië zaá†tek textu
         dec       di                       ; sn°ëen° ukazatele textu
         dec       cx                       ; sn°ëen° ukazatele pozice
         jmp       short EdiLRoz1           ; test dal®°ho znaku

; ------ test, zda je to kr†tkÇ slovo (p°smeno - p©edloëka)

EdiLRoz2:push      ax
         mov       al,es:[di-1]             ; p©ede®lò znak
         call      far ptr UpCase           ; konverze na velkÇ p°smeno
         cmp       al,"A"                   ; je to p°smeno ?
         jb        EdiLRz22                 ; nen° to p°smeno
         cmp       al,"Z"+1
         cmc
EdiLRz22:pop       ax
         jc        EdiLRoz7                 ; nen° to p°smenn† p©edloëka

         cmp       byte ptr es:[di-2]," "   ; slovo o dÇlce 1 znak ?
         jne       EdiLRoz7                 ; ne - je dost dlouhÇ slovo

; ------ nalezen° dal®°ho slova, je-li kr†tkÇ slovo

EdiLRoz3:cmp       di,bp                    ; je jië zaá†tek textu ?
         jbe       EdiLRoz4                 ; je jië zaá†tek textu
         dec       di                       ; sn°ëen° ukazatele textu
         dec       cx                       ; sn°ëen° ukazatele pozice
         cmp       byte ptr es:[di]," "     ; nalezena mezera ?
         jne       EdiLRoz3                 ; nalezen° mezery
         jmp       short EdiLRoz7           ; teÉ jië bude rozdàlen°

; ------ p©°prava k hled†n° n†sleduj°c°ho p©elomu

EdiLRoz4:mov       bp,es:[TextBNum]         ; poáet bajtñ v bufferu
         add       bp,TextBBeg              ; adresa konce textu

; ------ nalezen° zaá†tku dal®°ho slova

EdiLRoz5:cmp       byte ptr es:[di]," "     ; je mezera mezi slovy ?
         je        EdiLRoz7                 ; nalezena mezera
         cmp       word ptr es:[di],LF*HI + CR ; je konec ©†dku ?
         je        EdiLRoz6                 ; nic se nebude rozdàlovat
         inc       di                       ; zvò®en° adresy textu
         inc       cx                       ; zvò®en° ukazatele pozice
         cmp       di,bp                    ; je jië konec textu ?
         jb        EdiLRoz5                 ; nen° konec - dal®° znak
EdiLRoz6:xor       bp,bp                    ; BP <- 0 nebyl rozdàlen
         jmp       EdiLRoz8                 ; nic se nerozdàluje

; ------ vloëen° konce ©†dku CR/LF a mezer

EdiLRoz7:push      cx
         mov       cx,ds:[TextEPoz]         ; poá†teán° mezery ©†dku
         inc       cx                       ; + 2 znaky (CR/LF) - 1 znak mezery
         call      far ptr InsDat           ; vytvo©en° m°sta pro p©edàl
         xchg      ax,cx                    ; AX <- poáet vkl†danòch bajtñ
         pop       cx
         jnc       EdiLRz72
         jmp       EdiLRoz9                 ; chyba pamàti

EdiLRz72:add       es:[TextBNum],ax         ; zvò®en° poátu bajtñ textu
         or        byte ptr es:[TextParm],bit1 ; p©°znak - text modifikov†n
         inc       word ptr es:[TextBLin]   ; zvò®en° poátu ©†dkñ v bufferu

; ------ uloëen° p©elomu ©†dku a mezer na zaá†tek ©†dku

         mov       bp,bx                    ; BP <- celkov† dÇlka ©†dku
         mov       bx,di                    ; BX <- adresa konce ©†dku
         cld
         mov       ax,LF*HI + CR            ; znak p©elomu
         stosw                              ; uloëen° p©elomu ©†dku CR/LF
         push      cx
         mov       cx,ds:[TextEPoz]         ; poáet mezer na poá†tku
         mov       al," "                   ; £vodn° mezery
         rep       stosb                    ; uloëen° poá†teán°ch mezer
         pop       cx

; ------ korekce ukazatelñ ©†dku

         mov       si,ds:[TextEPoz]         ; novò poá†tek dal®°ho ©†dku
         pop       ax                       ; AX <- adresa zaá†tku ©†dku (DI)
         push      ax
         sub       bx,ax                    ; BX = nov† dÇlka 1. á†sti ©†dku
         dec       bp                       ; byla zru®ena 1 mezera
         sub       bp,bx                    ; BP = dÇlka 2. á†sti ©†dku
         add       bp,si                    ; váetnà poá†teán°ch mezer

; ------ oprava ukazatelñ

         push      si
         mov       ax,si                    ; AX <- poá†tek dal®°ho ©†dku
         mov       si,TextKPoz              ; kurzor
         call      EdiLRzK                  ; korekce pro kurzor
         mov       si,TextBBPz              ; poá†tek bloku
         call      EdiLRzK                  ; korekce pro poá†tek bloku
         mov       si,TextBEPz              ; konec bloku
         call      EdiLRzK                  ; korekce pro konec bloku
         pop       si

; ------ oprava dÇlky ©†dku s kurzorem

         inc       dx                       ; druh† á†st rozdàlenÇho ©†dku
         cmp       dx,es:[TextKLin]         ; je to ©†dek p©ed kurzorem ?
         dec       dx                       ; n†vrat á°sla ©†dku
         jb        EdiLRz78                 ; je to ©†dek p©ed ©†dkem s kurzorem
         cmp       dx,es:[TextKLin]         ; je to ©†dek za kurzorem ?
         jb        EdiLRz76                 ; kurzor je v druhÇ á†sti ©†dku
         ja        EdiLRoz8                 ; je to ©†dek za kurzorem
         mov       es:[TextKDel],bx         ; nov† dÇlka ©†dku s kurzorem
         mov       es:[TextKEnd],bx         ; novò konec textu ©†dku
         jmp       short EdiLRoz8

EdiLRz76:mov       es:[TextKDel],bp         ; nov† dÇlka ©†dku s kurzorem
         mov       es:[TextKEnd],bp
         add       es:[TextKAdr],bx         ; posun adresy ©†dku s kurzorem
         add       word ptr es:[TextKAdr],2
         jmp       short EdiLRoz8

; ------ oprava adresy ©†dku s kurzorem

EdiLRz78:inc       ax                       ; poáet vkl†danòch dat
         add       es:[TextKAdr],ax         ; oprava adresy ©†dku s kurzorem

; ------ n†vrat registrñ

EdiLRoz8:or        bp,bp                    ; rozdàlil se ©†dek ? (ZY=ne)
EdiLRoz9:pop       di
         pop       cx
         pop       ax
         ret

EditLRoz ENDP

; ------ korekce pro poloëku SI

EdiLRzK: cmp       dx,es:[si+2]             ; je to ©†dek s poloëkou ?
         ja        EdiLRzK9                 ; je za poloëkou
         jb        EdiLRzK8                 ; je to ©†dek p©ed poloëkou
         cmp       cx,es:[si]               ; je pozice p©ed poloëkou ?
         ja        EdiLRzK9                 ; pozice je za poloëkou
         je        EdiLRzK7                 ; je pozice na koncovÇ meze©e
         dec       word ptr es:[si]         ; sn°ëen° pozice o zru®enou mezeru
EdiLRzK7:sub       es:[si],bx               ; odeáten° aktu†ln°ho ©†dku
         add       es:[si],ax               ; p©iáten° novÇho ©†dku
EdiLRzK8:inc       word ptr es:[si+2]       ; zvò®en° ©†dku poloëky
EdiLRzK9:ret

; -----------------------------------------------------------------------------
;        spojen° ©†dkñ
; -----------------------------------------------------------------------------
; VSTUP: AX=segment okna
;        BX=dÇlka aktivn°ho ©†dku
;        DX=á°slo ©†dku
;        BP=dÇlka dal®°ho ©†dku
; VùSTUP: BP=0 pokud ©†dky byly spojeny (jinak BP nezmànàn)
;         BX=nov† dÇlka aktivn°ho ©†dku
;         CY=chyba
; -----------------------------------------------------------------------------

EdiLSpoj PROC      NEAR

         push      cx
         push      di

         cmp       bx,ds:[TextEOkr]         ; je ©†dek krat®° neë okraj ?
         jae       EdiLSpj9                 ; ©†dek je dost dlouhò

         add       di,bx                    ; adresa konce ©†dku
         cmp       di,es:[0]                ; je adresa OK ?
         cmc
         jc        EdiLSpj9                 ; chyba
         mov       cx,1                     ; ru®° se 1 znak
         call      far ptr DelDat           ; zru®en° konce ©†dku CR
         jc        EdiLSpj9

         or        byte ptr es:[TextParm],bit1 ; p©°znak - text modifikov†n
         mov       byte ptr es:[di]," "     ; n†hrada oddàlovac° mezerou
         dec       word ptr es:[TextBLin]   ; sn°ëen° poátu ©†dkñ
         dec       word ptr es:[TextBNum]   ; sn°ëen° poátu bajtñ v bufferu

         mov       di,TextBBPz              ; poá†tek bloku
         call      EdiLSpB                  ; korekce bloku
         mov       di,TextBEPz              ; konec bloku
         call      EdiLSpB                  ; korekce bloku
         mov       di,TextKPoz              ; kurzor
         call      EdiLSpB                  ; korekce kurzoru

         add       bx,bp                    ; zvò®en° dÇlky ©†dku
         inc       bx                       ; váetnà oddàlovac° mezery
         call      IniTKLin                 ; inicializace ©†dku s kurzorem
         xor       bp,bp                    ; zru®en° parametrñ dal®°ho ©†dku

EdiLSpj9:pop       di
         pop       cx
         ret

EdiLSpoj ENDP

; ------ korekce bloku DI

EdiLSpB: cmp       dx,es:[di+TextBBLn-TextBBPz] ; je ©†dek bloku ?
         jae       EdiLSpB8                 ; je za ukazatelem bloku
         dec       word ptr es:[di+TextBBLn-TextBBPz] ; oprava ©†dku bloku
         cmp       dx,es:[di+TextBBLn-TextBBPz] ; je n†sleduj°c° ©†dek ?
         jne       EdiLSpB8                 ; nen° n†sleduj°c° ©†dek
         add       es:[di],bx               ; oprava pozice bloku
         inc       word ptr es:[di]         ; p©iáten° mezery
EdiLSpB8:ret

; -----------------------------------------------------------------------------
;        uloëen° parametrñ aktivn°ho ©†dku (poá†tek CX)
; -----------------------------------------------------------------------------

EditLUlP PROC      NEAR

         test      byte ptr ds:[TextForP],bit1 ; byl druhò ©†dek ?
         jnz       EdiLUlP2                 ; byl druhò ©†dek

         mov       ds:[TextEPoz],cx         ; poá†tek ©†dku

         test      byte ptr ds:[TextForP],bit0 ; byl prvn° ©†dek ?
         jz        EdiLUlP1                 ; nebyl prvn° ©†dek

         or        byte ptr ds:[TextForP],bit1 ; byl druhò ©†dek
EdiLUlP1:or        byte ptr ds:[TextForP],bit0 ; byl prvn° ©†dek
EdiLUlP2:ret

EditLUlP ENDP

; -----------------------------------------------------------------------------
;        zji®tàn° parametrñ p©°®t°ho ©†dku
; -----------------------------------------------------------------------------
; VSTUP: BX=celkov† dÇlka aktivn°ho ©†dku bez CR/LF (pro prvn° ©†dek je BX=0)
;        ES:DI=adresa zaá†tku aktivn°ho ©†dku (pro prvn° ©†dek je zaá†tek-2)
; VùSTUP: SI=poá†teán° pozice textu dal®°ho ©†dku
;         BP=celkov† dÇlka dal®°ho ©†dku (bez CR/LF)
;         CY=dal®° ©†dek je neplatnò
; -----------------------------------------------------------------------------

EdiLNxtP PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      dx
         push      di

; ------ adresa dal®°ho ©†dku -> DI

         add       di,bx                    ; adresa konce aktivn°ho ©†dku
         inc       di
         inc       di                       ; zaá†tek dal®°ho ©†dku

; ------ p©°prava ke zji®tàn° poá†tku textu na ©†dku

         xor       bp,bp                    ; BP <- 0 á°taá celkovÇ dÇlky ©†dku
         xor       si,si                    ; SI <- 0 á°taá poá†tku ©†dku
         mov       dx,es:[TextBNum]         ; poáet bajtñ v bufferu
         add       dx,TextBBeg              ; adresa konce textu

; ------ test, zda je jië konec textu

EdiLNxP2:cmp       di,dx                    ; je jië konec textu ?
         jae       EdiLNxP8                 ; je jië konec textu
         mov       ax,es:[di]               ; 2 znaky textu

; ------ test, zda je jië konec ©†dku

         cmp       ax,LF*HI + CR            ; konec ©†dku ?
         je        EdiLNxP8                 ; je konec ©†dku

; ------ test, zda je znak mezery

         cmp       al," "                   ; je znak mezery ?
         jne       EdiLNxP3                 ; nen° znak mezery
         inc       di                       ; zvò®en° ukazatele textu
         inc       si                       ; zvò®en° á°taáe poá†tku
         inc       bp                       ; zvò®en° á°taáe celkovÇ dÇlky
         jmp       short EdiLNxP2           ; dal®° znak na ©†dku

; ------ nalezen zaá†tek ©†dku - test, zda je to platnò znak

EdiLNxP3:cmp       al,181                   ; v Latin 2 je to "è"
         je        EdiLNxP4                 ; platnò znak
         cmp       al,210                   ; v Latin 2 je to "Ö"
         je        EdiLNxP4                 ; platò znak
         cmp       al,"|"
         je        EdiLNxP8                 ; nen° platnò znak
         cmp       al,176
         jb        EdiLNxP4                 ; je platnò znak
         cmp       al,223
         jbe       EdiLNxP8                 ; nen° to platnò znak

; ------ test poá†teán° pozice, zda leë° za p©ede®lou pozic°

EdiLNxP4:test      byte ptr ds:[TextForP],bit1 ; byl druhò ©†dek ?
         jz        EdiLNxP5                 ; nebyl druhò ©†dek
         cmp       si,ds:[TextEPoz]         ; leë° za staròm poá†tkem ?
         jbe       EdiLNxP5                 ; neleë° za staròm poá†tkem

; ------ test, zda je ©†dek zaá†tkem dal®°ho odstavce

         call      EdiLNxO                  ; test, zda to je zaá†tek odstavce
         jc        EdiLNxP8                 ; je to zaá†tek novÇho odstavce

; ------ platnò znak - zvò®en° ukazatele

EdiLNxP5:inc       di                       ; zvò®en° ukazatele textu
         inc       bp                       ; zvò®en° á°taáe celkovÇ dÇlky

; ------ test, zda je jië konec textu

         cmp       di,dx                    ; je jië konec textu ?
         jae       EdiLNxP9                 ; je jië konec textu

; ------ test, zda je jië konec ©†dku

         cmp       word ptr es:[di],LF*HI + CR ; konec ©†dku ?
         jne       EdiLNxP5                 ; nen° konec ©†dku - dal®°
         jmp       short EdiLNxP9           ; je nastaven NC !

; ------ n†vrat registrñ

EdiLNxP8:stc                                ; p©°znak neplatnÇho ©†dku
EdiLNxP9:pop       di
         pop       dx
         pop       ax
         ret

EdiLNxtP ENDP

; ------ test, zda je ©†dek zaá†tkem dal®°ho odstavce (poá†tek SI>0, konec DX)

EdiLNxO: push      di
         push      si

         inc       di
EdiLNxO2:cmp       di,dx                    ; je konec textu ?
         jae       EdiLNxO8                 ; konec textu - nen° odstavec
         inc       di                       ; zvò®en° ukazatele
         cmp       word ptr es:[di-2],LF*HI + CR ; konec ©†dku ?
         jne       EdiLNxO2                 ; nalezen° konce ©†dku

EdiLNxO3:cmp       di,dx                    ; konec textu ?
         jae       EdiLNxO8                 ; konec textu - nen° odstavec
         cmp       word ptr es:[di],LF*HI + CR ; konec ©†dku ?
         je        EdiLNxO8                 ; konec ©†dku - nen° odstavec
         cmp       byte ptr es:[di]," "     ; mezera ?
         stc                                ; p©°znak odstavce
         jne       EdiLNxO9                 ; jinò znak - je to odstavec
         inc       di                       ; zvò®en° ukazatele textu
         dec       si                       ; sn°ëen° á°taáe stejnÇho poá†tku
         jnz       EdiLNxO3                 ; test dal®° pozice

EdiLNxO8:clc                                ; p©°znak - nen° odstavec
EdiLNxO9:pop       si
         pop       di
         ret

; -----------------------------------------------------------------------------
;        minimalizace mezer v ©†dku na 1 mezeru mezi slovy
; -----------------------------------------------------------------------------
; VSTUP: AX=segment okna
;        BX=celkov† dÇlka ©†dku (bez CR/LF)
;        CX=poá†teán° pozice zaá†tku textu ©†dku
;        DX=á°slo ©†dku
;        ES:DI=adresa zaá†tku ©†dku
; VùSTUP: BX=nov† dÇlka ©†dku
; -----------------------------------------------------------------------------

EdiGMini PROC      NEAR

; ------ £schova registrñ

         push      cx
         push      bp
         push      si
         push      di

; ------ p©°prava ukazatelñ

         mov       si,cx                    ; SI <- ukazatel pozice na ©†dku
         add       di,cx                    ; adresa zaá†tku textu ©†dku
         mov       bp,es:[TextBNum]         ; poáet bajtñ v bufferu
         add       bp,TextBBeg              ; BP <- adresa konce textu
         mov       cx,1                     ; bude se ru®it 1 mezera

; ------ test, zda je jië konec textu

EdiGMin2:cmp       di,bp                    ; je konec textu ?
         jae       EdiGMin8                 ; je jië konec textu

; ------ test, zda je konec ©†dku

         cmp       word ptr es:[di],LF*HI + CR ; konec ©†dku ?
         je        EdiGMin8                 ; je konec ©†dku

; ------ test, zda je znak mezery

         cmp       byte ptr es:[di]," "     ; je znak mezery ?
         je        EdiGMin4                 ; je znak mezery

; ------ nen° mezera - zvò®en° ukazatele textu

EdiGMin3:inc       di                       ; zvò®en° ukazatele textu
         inc       si                       ; zvò®en° ukazatele pozice
         jmp       short EdiGMin2           ; dal®° znak

; ------ pokud n†sleduje CR/LF nebo dal®° mezera, mezera se vypust°

EdiGMin4:cmp       di,0fffeh                ; maxim†ln° adresa
         jae       EdiGMin3                 ; z†kaz testov†n° CR/LF
         cmp       word ptr es:[di+1],LF*HI + CR ; n†sleduje CR/LF ?
         je        EdiGMin5                 ; mezera se vypust°
         cmp       byte ptr es:[di+1]," "   ; je dal®° znak mezera ?
         jne       EdiGMin3                 ; mezera se ponech†v†

; ------ vypustàn° mezery

EdiGMin5:call      far ptr DelDat           ; vypu®tàn° znaku mezery
         jc        EdiGMin8                 ; nàjak† chyba
         dec       bp                       ; sn°ëen° adresy konce textu
         dec       bx                       ; sn°ëen° dÇlky ©†dku
         dec       word ptr es:[TextBNum]   ; sn°ëen° poátu bajtñ textu
         or        byte ptr es:[TextParm],bit1 ; p©°znak - text modifikov†n

; ------ korekce ukazatele kurzoru a blokñ

         push      bx
         cmp       word ptr es:[di],LF*HI + CR ; n†sleduje CR/LF ?
         je        EdiGMin6                 ; kurzor se neposune
         mov       bx,TextKPoz              ; kurzor
         call      EdiGMnK                  ; korekce pro kurzor
EdiGMin6:mov       bx,TextBBPz              ; poá†tek bloku
         call      EdiGMnK                  ; korekce pro poá†tek bloku
         mov       bx,TextBEPz              ; konec bloku
         call      EdiGMnK                  ; korekce pro konec bloku
         pop       bx

; ------ oprava dÇlky ©†dku s kurzorem

         cmp       dx,es:[TextKLin]         ; je to ©†dek s kurzorem ?
         jb        EdiGMin7                 ; je to ©†dek p©ed ©†dkem s kurzorem
         jne       EdiGMin2                 ; nen° to ©†dek s kurzorem
         dec       word ptr es:[TextKDel]   ; sn°ëen° dÇlky ©†dku
         cmp       si,es:[TextKEnd]         ; je p©ed koncem textu ©†dku ?
         jae       EdiGMin2                 ; nen° p©ed koncem textu ©†dku
         dec       word ptr es:[TextKEnd]   ; oprava konce textu ©†dku
         jmp       short EdiGMin2           ; dal®° znak

; ------ oprava adresy ©†dku s kurzorem

EdiGMin7:dec       word ptr es:[TextKAdr]   ; oprava adresy ©†dku s kurzorem
         jmp       short EdiGMin2           ; dal®° znak

; ------ n†vrat registrñ

EdiGMin8:pop       di
         pop       si
         pop       bp
         pop       cx
         ret

EdiGMini ENDP

; ------ korekce pro ukazatel BX

EdiGMnK: cmp       dx,es:[bx+2]             ; je to ©†dek s ukazatelem ?
         jne       EdiGMnK2                 ; nen° to ©†dek s ukazatelem
         cmp       si,es:[bx]               ; je ukazatel za pozic° ?
         jae       EdiGMnK2                 ; nen° za pozic°
         dec       word ptr es:[bx]         ; oprava ukazatele pozice
EdiGMnK2:ret

; -----------------------------------------------------------------------------
;        doplnàn° mezer do ©†dku (nen°-li po pravò okraj)
; -----------------------------------------------------------------------------
; VSTUP: AX=segment okna
;        BX=celkov† dÇlka ©†dku (bez CR/LF)
;        CX=pozice poá†tku textu v ©†dku
;        DX=á°slo ©†dku
;        ES:DI=adresa poá†tku ©†dku
; VùSTUP: CY=chyba pamàti
;         BX=nov† dÇlka ©†dku
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ:   (SS:[BP-2] (2) pozice poá†tku textu v ©†dku (CX))
;                   SS:[BP-4] (2) adresa poá†tku ©†dku (DI)
;                   SS:[BP-6] (2) uschovan† dÇlka ©†dku (BX)
;
;                   AX=segment okna
;                   BX=dÇlka ©†dku
;                   CX=ukazatel pozice na ©†dku
;                   DX=á°slo ©†dku
;                   SI=pozice poá†tku textu v ©†dku (CX)
;                   DI=ukazatel textu
; -----------------------------------------------------------------------------

EdiGMaxi PROC      NEAR

; ------ £schova registrñ

         push      cx
         push      si
         push      di
         push      bp
         mov       bp,sp

; ------ p©°prava lok†ln°ch promànnòch

         sub       sp,6
;         mov       ss:[bp-2],cx             ; pozice poá†tku textu v ©†dku
         mov       ss:[bp-4],di             ; adresa poá†tku ©†dku
         mov       si,cx                    ; pozice poá†tku textu v ©†dku

; ------ reset ukazatelñ na konec ©†dku

EdiGMax2:mov       ss:[bp-6],bx             ; £schova dÇlky ©†dku
         mov       cx,bx                    ; CX <- pozice za koncem ©†dku
         mov       di,ss:[bp-4]             ; adresa poá†tku textu v ©†dku
         add       di,bx                    ; DI <- adresa za koncem ©†dku

; ------ nalezen° dal®° mezery na ©†dku

EdiGMax3:cmp       cx,si                    ; je jië poá†tek textu ?
         jbe       EdiGMax7                 ; je jië poá†tek textu
         dec       di                       ; sn°ëen° adresy textu
         dec       cx                       ; sn°ëen° ukazatele pozice v ©†dku
         cmp       byte ptr es:[di]," "     ; je to mezera ?
         jne       EdiGMax3                 ; nen° to mezera - dal®° znak
         cmp       byte ptr es:[di+1]," "   ; je to mezera p©ed slovem ?
         je        EdiGMax3                 ; nen° to prvn° mezera p©ed slovem

; ------ test, zda je jië pot©ebn† dÇlka ©†dku

         cmp       bx,ds:[TextEOkr]         ; je jië dostateán† dÇlka ©†dku ?
         jae       EdiGMax9                 ; je jië dostateán† dÇlka ©†dku (NC)

; ------ vloëen° znaku mezery

         push      cx
         mov       cx,1                     ; vloë° se 1 znak mezery
         call      far ptr InsDat           ; vloëen° 1 znaku
         pop       cx
         jc        EdiGMax9                 ; chyba pamàti
         mov       byte ptr es:[di]," "     ; vloëen° znaku mezery

; ------ oprava ukazatelñ

         inc       word ptr es:[TextBNum]   ; zvò®en° poátu bajtñ v bufferu
         or        byte ptr es:[TextParm],bit1 ; p©°znak - text modifikov†n
         inc       bx                       ; zvò®en° á°taáe dÇlky ©†dku

; ------ korekce ukazatele kurzoru a blokñ

         push      bx
         mov       bx,TextKPoz              ; kurzor
         call      EdiGMaK                  ; korekce pro kurzor
         mov       bx,TextBBPz              ; poá†tek bloku
         call      EdiGMaK                  ; korekce pro poá†tek bloku
         mov       bx,TextBEPz              ; konec bloku
         call      EdiGMaK                  ; korekce pro konec bloku
         pop       bx

; ------ oprava dÇlky ©†dku s kurzorem

         cmp       dx,es:[TextKLin]         ; je to ©†dek s kurzorem ?
         jb        EdiGMax4                 ; je to ©†dek p©ed ©†dkem s kurzorem
         jne       EdiGMax5                 ; nen° to ©†dek s kurzorem
         inc       word ptr es:[TextKDel]   ; zvò®en° dÇlky ©†dku
         cmp       cx,es:[TextKEnd]         ; je p©ed koncem textu ©†dku ?
         jae       EdiGMax5                 ; nen° p©ed koncem textu ©†dku
         inc       word ptr es:[TextKEnd]   ; oprava konce textu ©†dku
         jmp       short EdiGMax5           ; dal®° znak

; ------ oprava adresy ©†dku s kurzorem

EdiGMax4:inc       word ptr es:[TextKAdr]   ; oprava adresy ©†dku s kurzorem
EdiGMax5:jmp       short EdiGMax3

; ------ test, zda mñëe bòt dal®° prñchod

EdiGMax7:cmp       bx,ss:[bp-6]             ; zmànila se dÇlka ©†dku ?
         jne       EdiGMax2                 ; zmànila - mñëe bòt dal®° prñchod
                                          ;* zde je NC !
; ------ n†vrat registrñ

EdiGMax9:mov       sp,bp
         pop       bp
         pop       di
         pop       si
         pop       cx
         ret

EdiGMaxi ENDP

; ------ korekce pro ukazatel BX

EdiGMaK: cmp       dx,es:[bx+2]             ; je to ©†dek s ukazatelem ?
         jne       EdiGMaK2                 ; nen° to ©†dek s ukazatelem
         cmp       cx,es:[bx]               ; je ukazatel za pozic° ?
         ja        EdiGMaK2                 ; nen° za pozic°
         inc       word ptr es:[bx]         ; oprava ukazatele pozice
EdiGMaK2:ret

; -----------------------------------------------------------------------------
;        o©ez†n° pr†zdnòch ©†dkñ na konci souboru (okno AX/ES)
; -----------------------------------------------------------------------------

EditERC  PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      cx
         push      di

; ------ test, zda je z†kaz z†pisu

         test      byte ptr es:[TextParm],bit0 ; je z†kaz z†pisu ?
         jnz       EditERC9                 ; je z†kaz z†pisu

; ------ adresa konce textu -> DI

         mov       bx,es:[TextBNum]         ; poáet bajtñ v bufferu
         mov       di,TextBBeg              ; zaá†tek textu
         add       di,bx                    ; adresa konce textu
         xor       cx,cx                    ; á°taá bajtñ ke zru®en°
         cmp       word ptr es:[di-2],LF*HI + CR ; p©edch†z° konec ©†dku ?
         jne       EditERC9                 ; nen° ukonáen° CR/LF

; ------ nalezen° konce textu

EditERC2:cmp       bx,4                     ; zbòv† je®tà dost dat ?
         jb        EditERC4                 ; zbòv† m†lo dat ?
         cmp       word ptr es:[di-4],LF*HI + CR ; p©edch†z° konec ©†dku ?
         jne       EditERC4                 ; nep©edch†z° konec ©†dku
         dec       di
         dec       di                       ; sn°ëen° ukazatele textu
         inc       cx
         inc       cx                       ; zvò®en° á°taáe dat ke zru®en°
         dec       bx
         dec       bx                       ; sn°ëen° á°taáe zbylòch dat
         jmp       short EditERC2           ; test dal®°ho ©†dku

; ------ zru®en° ©†dkñ

EditERC4:jcxz      EditERC9                 ; nejsou ë†dn† data ke zru®en°
         call      far ptr DelDat           ; zru®en° dat
         jc        EditERC9                 ; byla nàjak† chyba

; ------ oprava ukazatelñ

         sub       es:[TextBNum],cx         ; sn°ëen° poátu bajtñ v bufferu
         shr       cx,1                     ; poáet ©†dkñ
         sub       es:[TextBLin],cx         ; sn°ëen° poátu ©†dkñ

; ------ aktualizace ©†dku s kurzorem a poá†teán°ho ©†dku

         call      IniTTLin                 ; inicializace prvn°ho ©†dku
         call      IniTKLin                 ; inicializace ©†dku s kurzorem

; ------ n†vrat registrñ

EditERC9:pop       di
         pop       cx
         pop       bx
         ret

EditERC  ENDP

; -----------------------------------------------------------------------------
;        o©ez†n° mezer na konci aktivn°ho ©†dku (okno AX/ES)
; -----------------------------------------------------------------------------

EditERez PROC      NEAR

; ------ £schova registrñ

         push      cx
         push      di

; ------ test, zda je z†kaz z†pisu

         test      byte ptr es:[TextParm],bit0 ; je z†kaz z†pisu ?
         jnz       EditERz9                 ; je z†kaz z†pisu

; ------ test, zda jsou mezery na konci ©†dku

         mov       di,es:[TextKEnd]         ; konce textu na ©†dku
         mov       cx,es:[TextKDel]         ; dÇlka ©†dku
         sub       cx,di                    ; je nàjak† mezera k ru®en° ?
         jbe       EditERz9                 ; nen° nic k ru®en°

; ------ zru®en° mezer na konci ©†dku

         add       di,es:[TextKAdr]         ; offset konce ©†dku
         add       di,TextBBeg              ; adresa konce textu
         call      far ptr DelDat           ; zru®en° dat
         jc        EditERz9                 ; chyba

; ------ korekce ukazatelñ

         sub       es:[TextKDel],cx         ; sn°ëen° dÇlky ©†dku
         sub       es:[TextBNum],cx         ; sn°ëen° poátu bajtñ v bufferu

; ------ n†vrat registrñ

EditERz9:pop       di
         pop       cx
         ret

EditERez ENDP

; -----------------------------------------------------------------------------
;        doplnàn° ©†dkñ a mezer po kurzor (okno AX/ES -> CY chyba pamàti)
; -----------------------------------------------------------------------------

EditECS  PROC      NEAR

         call      EditECrl                 ; doplnàn° ©†dkñ po kurzor
         jc        EditECS2                 ; chyba
         call      EditESpc                 ; doplnàn° mezer
EditECS2:ret

EditECS  ENDP

; -----------------------------------------------------------------------------
; doplnàn° novòch ©†dkñ za konec textu po kurzor (okno AX/ES -> CY chyba pamàti)
; -----------------------------------------------------------------------------

EditECrl PROC      NEAR

; ------ £schova registrñ

         push      cx
         push      di

; ------ test, zda je z†kaz z†pisu

         test      byte ptr es:[TextParm],bit0 ; je z†kaz z†pisu ?
         stc
         jnz       EditECI9                 ; je z†kaz z†pisu

; ------ p©°prava adresy a poátu mezer

         mov       di,es:[TextBLin]         ; poáet ©†dkñ textu
         mov       cx,es:[TextKLin]         ; ©†dek s kurzorem
         inc       cx                       ; 1 ©†dek, pokud nen° na konci CRLF
         inc       cx                       ; 1 ©†dek za kurzorem
         sub       cx,di                    ; poëadovanò poáet ©†dkñ
         jbe       EditECI8                 ; nen° pot©eba nic vkl†dat

; ------ vytvo©en° m°sta pro vloëen° novòch ©†dkñ

         shl       cx,1                     ; poáet znakñ k vloëen°
         jc        EditECI9                 ; chyba p©eteáen°
         mov       di,es:[TextBNum]         ; poáet bajtñ v bufferu
         add       di,TextBBeg              ; adresa konce textu
         call      far ptr InsDat           ; vytvo©en° m°sta pro ©†dky
         jc        EditECI9                 ; chyba pamàti

; ------ posun ukazatelñ textu

         add       es:[TextBNum],cx         ; zvò®en° poátu bajtñ v bufferu
         shr       cx,1                     ; poáet ©†dkñ
         add       es:[TextBLin],cx         ; zvò®en° poátu ©†dkñ

; ------ oprava, pokud posledn° ©†dek nebyl ukonáen CRLF

         push      ax
         mov       ax,LF*HI + CR            ; konec ©†dku k vloëen°

         cmp       di,TextBBeg              ; p©edch†zel nàjakò text ?
         je        EditECI6                 ; nep©edch†zel ë†dnò text
         cmp       word ptr es:[di-2],ax    ; bylo ukonáen° CR/LF ?
         je        EditECI6                 ; bylo ukonáen° CR/LF
         dec       word ptr es:[TextBLin]   ; tento ©†dek jië byl zapoá°t†n

; ------ z†pis ©†dkñ

EditECI6:cld
         rep       stosw                    ; vloëen° koncñ ©†dkñ
         pop       ax

; ------ inicializace ukazatelñ poá†teán°ho ©†dku a kurzoru

         call      IniTTLin                 ; inicializace poá†teán°ho ©†dku
         call      IniTKLin                 ; inicializace ©†dku s kurzorem

; ------ n†vrat registrñ

EditECI8:clc                                ; p©°znak operace OK
EditECI9:pop       di
         pop       cx
         ret

EditECrl ENDP

; -----------------------------------------------------------------------------
;        doplnàn° mezer na konec ©†dku po kurzor (okno AX/ES -> CY chyba pamàti)
; -----------------------------------------------------------------------------

EditESpc PROC      NEAR

; ------ £schova registrñ

         push      cx
         push      di

; ------ test, zda je z†kaz z†pisu

         test      byte ptr es:[TextParm],bit0 ; je z†kaz z†pisu ?
         stc
         jnz       EditESp9                 ; je z†kaz z†pisu

; ------ p©°prava adresy a poátu mezer (ES=adresa okna !)

         mov       di,es:[TextKDel]         ; dÇlka ©†dku
         mov       cx,es:[TextKPoz]         ; pozice kurzoru
         sub       cx,di                    ; poáet mezer k vloëen°
         jbe       EditESp8                 ; nen° pot©eba nic vkl†dat

; ------ vytvo©en° m°sta pro vloëen° mezer (AX=á°slo okna !)

         add       di,es:[TextKAdr]         ; adresa konce ©†dku
         add       di,TextBBeg              ; adresa k uloëen° mezer
         call      far ptr InsDat           ; vytvo©en° m°sta pro mezery
         jc        EditESp9                 ; chyba pamàti

; ------ posun ukazatelñ ©†dku

         add       es:[TextKDel],cx         ; zvò®en° dÇlky ©†dku
         add       es:[TextBNum],cx         ; zvò®en° poátu bajtñ v bufferu

; ------ z†pis mezer

         push      ax
         mov       ax,"  "                  ; mezera k vloëen°
         cld
         shr       cx,1                     ; poáet slov k vloëen°
         rep       stosw                    ; vloëen° mezer po slovech
         adc       cx,cx                    ; lich† mezera
         rep       stosb                    ; vloëen° lichÇ mezery
         pop       ax

; ------ n†vrat registrñ

EditESp8:clc                                ; p©°znak operace OK
EditESp9:pop       di
         pop       cx
         ret

EditESpc ENDP

; -----------------------------------------------------------------------------
;    poskytnut° znaku na pozici CX -> AL (okno ES, CY=nen° platnò znak, AL=0)
; -----------------------------------------------------------------------------

EditEGtC PROC      NEAR

; ------ £schova registrñ

         push      bx

; ------ p©°prava adresy znaku

         mov       al,0                     ; n†hradn° znak p©i chybà
         mov       bx,cx                    ; pozice kurzoru na ©†dku
         cmp       bx,es:[TextKDel]         ; je za koncem ©†dku ?
         cmc
         jc        EditEGC4                 ; kurzor je za koncem ©†dku
         add       bx,es:[TextKAdr]         ; offset kurzoru
         add       bx,TextBBeg              ; adresa kurzoru v bufferu
         mov       al,es:[bx]               ; znak na pozici kurzoru
                                          ;* zde je NC !
; ------ n†vrat registrñ

EditEGC4:pop       bx
         ret

EditEGtC ENDP

; -----------------------------------------------------------------------------
;        korekce menu editoru DS:SI p©ed zobrazen°m
; -----------------------------------------------------------------------------

KorEMnu  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ adresa okna

         mov       ax,ds:[si+EdMnuSeg]      ; segment okna
         call      far ptr GetDat           ; adresa okna -> ES

; ------ p©°prava ke korekci poá†teán°ho ©†dku

         mov       ch,0
         mov       cl,ds:[si+MnuVys]        ; vò®ka okna
         sub       cl,6                     ; vnit©n° vò®ka okna - 4
         mov       ax,es:[TextKLin]         ; ©†dek s kurzorem
         mov       bx,es:[TextTLin]         ; ©†dek poá†tku

; ------ kontrola podteáen° poá†tku

         sub       ax,1                     ; 1 ©†dek rezerva
         jnc       KorEMnu0                 ; je ©†dek 0
         xor       ax,ax                    ; omezen° poá†tku
KorEMnu0:cmp       ax,bx                    ; je podteáen° poá†tku ?
         ja        KorEMnu1                 ; poá†tek je OK
         mov       bx,ax                    ; omezen°

; ------ kontrola p©eteáen° poá†tku

KorEMnu1:sub       ax,cx                    ; minim†ln° poá†tek
         jnc       KorEMnu2                 ; nen° podteáen°
         xor       ax,ax                    ; omezen° (je poá†tek textu)
KorEMnu2:cmp       ax,bx                    ; je poá†tek OK ?
         jbe       KorEMnu3                 ; poá†tek je OK
         mov       bx,ax                    ; omezen° poá†tku

; ------ test, zda byl poá†teán° ©†dek zmànàn

KorEMnu3:mov       ax,bx                    ; AX <- novò poá†teán° ©†dek
         xchg      ax,es:[TextTLin]         ; novò poá†teán° ©†dek
         cmp       ax,bx                    ; byl ©†dek zmànàn ?
         je        KorEMnu4                 ; poá†teán° ©†dek nebyl zmànàn
         or        byte ptr ds:[TextEPar],bit2 ; p©°znak zobrazen° okna
         call      IniTTLin                 ; inicializace poá†teán°ho ©†dku

; ------ p©°prava ke korekci poá†teán° pozice

KorEMnu4:mov       ch,0
         mov       cl,ds:[si+MnuSir]        ; ®°©ka okna
         sub       cl,13                    ; vnit©n° ®°©ka okna - 5 - 6
         mov       ax,es:[TextKPoz]         ; pozice kurzoru na ©†dku
         mov       bx,es:[TextTPoz]         ; pozice poá†tku

; ------ kontrola podteáen° poá†tku

         sub       ax,5                     ; rezerva na levÇm okraji
         jnc       KorEMnu5                 ; pozice je OK
         xor       ax,ax                    ; omezen° p©i malÇ pozici
KorEMnu5:cmp       ax,bx                    ; je podteáen° poá†tku ?
         jae       KorEMnu6                 ; poá†tek je OK
         mov       bx,ax                    ; omezen°

; ------ kontrola p©eteáen° poá†tku

KorEMnu6:sub       ax,cx                    ; minim†ln° poá†tek
         jnc       KorEMnu7                 ; pozice je OK
         xor       ax,ax                    ; omezen°, je-li poá†tek ©†dku
KorEMnu7:cmp       ax,bx                    ; je poá†tek OK ?
         jbe       KorEMnu8                 ; poá†tek je OK
         mov       bx,ax                    ; omezen° poá†tku

; ------ test, zda byla poá†teán° pozice zmànàna

KorEMnu8:mov       ax,bx
         xchg      ax,es:[TextTPoz]         ; nov† poá†teán° pozice
         cmp       ax,bx                    ; byla poá†teán° pozice zmànàna ?
         je        KorEMnu9                 ; poá†teán° pozice nebyla zmànàna
         or        byte ptr ds:[TextEPar],bit2 ; p©°znak zobrazen° okna

; ------ n†vrat registrñ

KorEMnu9:pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

KorEMnu  ENDP

; -----------------------------------------------------------------------------
;        vòpoáet poátu ©†dkñ CR/LF v bufferu (adresa okna ES)
; -----------------------------------------------------------------------------

IniTLSum PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      di

; ------ p©°prava ke spoáten° poátu ©†dkñ

         mov       di,TextBBeg              ; zaá†tek bufferu
         mov       cx,es:[TextBNum]         ; poáet bajtñ v bufferu
         xor       bx,bx                    ; á°taá ©†dkñ v bufferu
         mov       al,CR                    ; hledanò znak CR
         cld
IniTLSm2:jcxz      IniTLSm6                 ; konec dat
         inc       bx                       ; je zaá†tek platnÇho ©†dku
IniTLSm3:repne     scasb                    ; nalezen° znaku CR
         jne       IniTLSm6                 ; dal®° znak CR nenalezen
         jcxz      IniTLSm6                 ; je konec dat - znak CR neplat°
         cmp       byte ptr es:[di],LF      ; je dal®° znak LF ?
         jne       IniTLSm3                 ; nen° - tento znak CR neplat°
         inc       di                       ; p©eskoáen° znaku LF
         dec       cx                       ; sn°ëen° á°taáe zbylòch dat
         jmp       short IniTLSm2           ; dal®° ©†dek

IniTLSm6:mov       es:[TextBLin],bx         ; poáet ©†dkñ v bufferu

; ------ n†vrat registrñ

         pop       di
         pop       cx
         pop       bx
         pop       ax
         ret

IniTLSum ENDP

; -----------------------------------------------------------------------------
;        inicializace poá†teán°ho ©†dku (adresa okna ES)
; -----------------------------------------------------------------------------

IniTTLin PROC      NEAR

; ------ £schova registrñ

         push      dx
         push      di

; ------ vyhled†n° adresy prvn°ho ©†dku

         mov       dx,es:[TextTLin]         ; poá†teán° ©†dek
         call      SrcLine                  ; nalezen° adresy ©†dku
         sub       di,TextBBeg              ; offset v bufferu
         mov       es:[TextTAdr],di         ; adresa poá†teán°ho ©†dku

; ------ n†vrat registrñ

         pop       di
         pop       dx
         ret

IniTTLin ENDP

; -----------------------------------------------------------------------------
;        inicializace ©†dku s kurzorem (adresa okna ES)
; -----------------------------------------------------------------------------

IniTKLin PROC      NEAR

; ------ £schova registrñ

         push      dx
         push      cx
         push      di

; ------ vyhled†n° ©†dku s kurzorem

         mov       dx,es:[TextKLin]         ; ©†dek s kurzorem
         call      SrcLine                  ; vyhled†n° ©†dku s kurzorem
         push      di
         sub       di,TextBBeg              ; offset v bufferu
         mov       es:[TextKAdr],di         ; adresa ©†dku s kurzorem
         pop       di

; ------ stanoven° dÇlky ©†dku

         call      LenLine                  ; stanoven° dÇlky ©†dku
         mov       es:[TextKDel],cx         ; dÇlka ©†dku
         add       di,cx                    ; adresa konce ©†dku
         jmp       short IniTKLn6           ; zkr†cen° o koncovÇ mezery

; ------ nalezen° konce textu na ©†dku

IniTKLn4:dec       di                       ; sn°ëen° ukazatele v textu
         dec       cx                       ; sn°ëen° á°taáe dÇlky ©†dku
IniTKLn6:jcxz      IniTKLn8                 ; je jië zaá†tek ©†dku
         cmp       byte ptr es:[di-1]," "   ; je p©ede®lò znak mezera ?
         je        IniTKLn4                 ; vypu®tàn° znaku mezery
IniTKLn8:mov       es:[TextKEnd],cx         ; offset konce textu na ©†dku

; ------ n†vrat registrñ

         pop       di
         pop       cx
         pop       dx
         ret

IniTKLin ENDP

; -----------------------------------------------------------------------------
;        nalezen° adresy ©†dku á°slo DX (adresa okna ES) -> DI
; -----------------------------------------------------------------------------

SrcLine  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx

; ------ p©°prava k vyhled†n° poá†teán°ho ©†dku

         mov       di,TextBBeg              ; adresa textu
         mov       cx,es:[TextBNum]         ; poáet bajtñ v bufferu
         or        dx,dx                    ; je prvn° ©†dek ?
         jz        SrcLine4                 ; je prvn° ©†dek
         mov       al,CR                    ; hledanò znak CR
         cld

; ------ vyhled†n° poëadovanÇho ©†dku

SrcLine1:jcxz      SrcLine4                 ; nen° dal®° znak
         repne     scasb                    ; nalezen° znaku CR
         jne       SrcLine4                 ; dal®° znak CR nenalezen
         jcxz      SrcLine4                 ; nen° dal®° znak - CR nen° konec
         cmp       byte ptr es:[di],LF      ; je dal®° znak LF ?
         jne       SrcLine1                 ; dal®° znak nen° LF - CR neplat°
         inc       di                       ; p©eskoáen° znaku LF
         dec       cx                       ; sn°ëen° á°taáe zbylòch znakñ
         dec       dx                       ; sn°ëen° á°taáe ©†dkñ
         jnz       SrcLine1                 ; hled†n° dal®°ho ©†dku

; ------ n†vrat registrñ

SrcLine4:pop       dx
         pop       cx
         pop       ax
         ret

SrcLine  ENDP

; -----------------------------------------------------------------------------
;        stanoven° dÇlky ©†dku ES:DI (bez koncovÇho CR/LF) -> CX
; -----------------------------------------------------------------------------

LenLine  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      dx
         push      di

; ------ p©°prava k vyhled†n° konce ©†dku

         xor       dx,dx                    ; á°taá dÇlky ©†dku s kurzorem
         mov       cx,es:[TextBNum]         ; poáet bajtñ v bufferu
         add       cx,TextBBeg              ; adresa konce dat v bufferu
         sub       cx,di                    ; poáet zbytku dat
         jbe       LenLine9                 ; je konec dat

; ------ nalezen° konce ©†dku

         cld
         mov       al,CR                    ; hledanò znak CR
LenLine2:inc       dx                       ; zvò®en° á°taáe dÇlky
         scasb                              ; je dal®° znak CR ?
         loopne    LenLine2                 ; nen° znak CR - dal®° znak
         jne       LenLine9                 ; znak CR nenalezen
         jcxz      LenLine9                 ; znak CR platnò (nen° dal®° znak)
         cmp       byte ptr es:[di],LF      ; je dal®° znak LF ?
         jne       LenLine2                 ; nen†sleduje znak LF - pokraáov†n°
         dec       dx                       ; je konec ©†dku, znak CR nen° znak

; ------ n†vrat registrñ

LenLine9:mov       cx,dx                    ; CX <- nalezen† dÇlka ©†dku
         pop       di
         pop       dx
         pop       ax
         ret

LenLine  ENDP

; -----------------------------------------------------------------------------
;        ukonáen° oznaáov†n° bloku SHIFT- (uchov†v† p©°znaky)
; -----------------------------------------------------------------------------

EdZEShft PROC      NEAR

         pushf
         and       byte ptr ds:[TextForP],not bit4+bit5 ; ukonáen° oznaáen°
         popf
         ret

EdZEShft ENDP

; -----------------------------------------------------------------------------
;        zah†jen° oznaáov†n° bloku SHIFT- (ES=adresa, CX=pozice, DX=©†dek)
; -----------------------------------------------------------------------------

; ------ zah†jen° oznaáov†n° pomoc° pravÇho tlaá°tka my®i

EdZBShf0:pushf
         jmp       short EdiBShf2

EdZBShft PROC      NEAR

; ------ £schova registrñ

         pushf

; ------ test, zda je SHIFT-

         test      byte ptr ds:[Presmyk],bit4 ; je SHIFT- ?
         jnz       EdiBShf2                 ; je SHIFT-
         test      byte ptr ds:[MouseKey],bit1 ; je pravÇ tlaá°tko my®i ?
         jnz       EdiBShf9                 ; je pravÇ tlaá°tko - neukonáuje se
         call      EdZEShft                 ; ukonáen° oznaáov†n° bloku se SHIFT-
         jmp       short EdiBShf9

; ------ zah†jen° oznaáov†n° bloku

EdiBShf2:test      byte ptr ds:[TextForP],bit4 ; je oznaáov†n° ?
         jnz       EdiBShf9                 ; oznaáov†n° je jië zah†jeno
         or        byte ptr ds:[TextForP],bit4 ; zah†jen° oznaáov†n°
         and       byte ptr ds:[TextForP],not bit5 ; nen° pevnò konec
         call      EditBBeg                 ; oznaáen° zaá†tku bloku F3
         call      EditBEnd                 ; oznaáen° konce bloku F4

; ------ n†vrat registrñ

EdiBShf9:popf
         ret

EdZBShft ENDP

; -----------------------------------------------------------------------------
;        obsluha oznaáen° bloku SHIFT- (ES=adresa, CX=pozice, DX=©†dek)
; -----------------------------------------------------------------------------

EdZShift PROC      NEAR

; ------ £schova registrñ

         pushf
         push      ax

; ------ test, zda je zah†jeno oznaáov†n° bloku

         test      byte ptr ds:[MouseKey],bit1 ; je pravÇ tlaá°tko my®i ?
         jnz       EdiShft1                 ; je pravÇ tlaá°tko my®i
         test      byte ptr ds:[Presmyk],bit4 ; je p©esmykaá SHIFT- ?
         jz        EdiShft9                 ; nen° SHIFT-
EdiShft1:test      byte ptr ds:[TextForP],bit4 ; je oznaáov†n° ?
         jz        EdiShft9                 ; nen° oznaáov†n° bloku

; ------ nastaven° volnÇho konce podle kurzoru

         test      byte ptr ds:[TextForP],bit5 ; je pevnò konec ?
         jnz       EdiShft2                 ; je pevnò konec bloku
         call      EditBEnd                 ; oznaáen° konce bloku F4
         jmp       short EdiShft3

EdiShft2:call      EditBBeg                 ; oznaáen° zaá†tku bloku F3

; ------ test, zda je blok zapnut

EdiShft3:test      byte ptr es:[TextParm],bit2 ; je blok zapnut ?
         jnz       EdiShft9                 ; blok je zapnut OK

; ------ z†màna zaá†tku a konce bloku

         mov       ax,es:[TextBBLn]         ; ©†dek zaá†tku bloku
         xchg      ax,es:[TextBELn]         ; z†màna s ©†dkem konce bloku
         mov       es:[TextBBLn],ax

         mov       ax,es:[TextBBPz]         ; pozice zaá†tku bloku
         xchg      ax,es:[TextBEPz]         ; z†màna s pozic° konce bloku
         mov       es:[TextBBPz],ax

         xor       byte ptr ds:[TextForP],bit5 ; zmàna p©°znaku volnÇho konec

; ------ novò pokus o zapnut° bloku

         call      EditBBg1                 ; novò pokus o zapnut° bloku

; ------ n†vrat registrñ

EdiShft9:pop       ax
         popf
         ret

EdZShift ENDP

; *****************************************************************************
;
;                    Obsluha intern°ch p©ep°naáñ v souboru
;
; *****************************************************************************
;˛
; -----------------------------------------------------------------------------
;        dek¢dov†n° á°selnÇho p©ep°naáe DS:SI do bufferu ES:DI - 2 á°sla AX a DX
; -----------------------------------------------------------------------------

Set2ISwc PROC      FAR

; ------ £schova registrñ

         push      bx
         push      cx
         push      si

; ------ z†pis zaá†tku p©ep°naáe

         call      SetTISBg                 ; dek¢dov†n° zaá†tku p©ep°naáe

; ------ dek¢dov†n° parametru 1

         xor       bx,bx                    ; nen° barva ani oddàlovaá
         call      far ptr DekNumW          ; dek¢dov†n° á°sla

; ------ oddàlovaá dat

         mov       byte ptr es:[di],","
         inc       di

; ------ dek¢dov†n° parametru 2

         xchg      ax,dx                    ; AX <- parametr 2
         call      far ptr DekNumW          ; dek¢dov†n° á°sla
         xchg      ax,dx                    ; n†vrat parametrñ

; ------ dek¢dov†n° konce p©ep°naáe

         call      SetTISEn                 ; dek¢dov†n° konce p©ep°naáe

; ------ n†vrat registrñ

         pop       si
         pop       cx
         pop       bx
         ret

Set2ISwc ENDP

; -----------------------------------------------------------------------------
;        dek¢dov†n° á°selnÇho p©ep°naáe DS:SI do bufferu ES:DI (hodnota AX/AL)
; -----------------------------------------------------------------------------

SetNISw0 LABEL     FAR

         mov       ah,0

SetNISwc PROC      FAR

; ------ £schova registrñ

         push      bx
         push      cx
         push      si

; ------ z†pis zaá†tku p©ep°naáe

         call      SetTISBg                 ; dek¢dov†n° zaá†tku p©ep°naáe

; ------ dek¢dov†n° parametru

         xor       bx,bx                    ; nen° barva ani oddàlovaá
         call      far ptr DekNumW          ; dek¢dov†n° á°sla

; ------ dek¢dov†n° konce p©ep°naáe

         call      SetTISEn                 ; dek¢dov†n° konce p©ep°naáe

; ------ n†vrat registrñ

         pop       si
         pop       cx
         pop       bx
         ret

SetNISwc ENDP

; -----------------------------------------------------------------------------
;        dek¢dov†n° textovÇho p©ep°naáe DS:SI do bufferu ES:DI (hodnota AL=1...)
; -----------------------------------------------------------------------------

SetTISwc PROC      FAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      si

; ------ z†pis zaá†tku p©ep°naáe

         call      SetTISBg                 ; dek¢dov†n° zaá†tku p©ep°naáe

; ------ nalezen° textu parametru (CX=0 !)

         mov       ah,0                     ; AX <- á°slo p©ep°naáe 1...
SetTISw2:add       si,cx                    ; adresa dal®°ho parametru
         mov       cl,ds:[si]               ; CL <- dÇlka textu
         inc       si                       ; zaá†tek textu parametru
         jcxz      SetTISw8                 ; je konec parametrñ
         dec       ax                       ; á°taá parametrñ
         jnz       SetTISw2                 ; nalezen° parametru

; ------ p©enos textu parametru

         rep       movsb                    ; p©enos textu parametru

; ------ dek¢dov†n° konce p©ep°naáe

SetTISw8:call      SetTISEn                 ; dek¢dov†n° konce p©ep°naáe

; ------ n†vrat registrñ

         pop       si
         pop       cx
         pop       ax
         ret

SetTISwc ENDP

; -----------------------------------------------------------------------------
;        dek¢dov†n° zaá†tku p©ep°naáe "[text" DS:SI do ES:DI -> CX=0
; -----------------------------------------------------------------------------

SetTISBg PROC      NEAR

; ------ z†pis zaá†tku p©ep°naáe

         mov       byte ptr es:[di],"["     ; £vodn° znak p©ep°naáe
         inc       di

; ------ dek¢dov†n° p©ep°naáe

         cld
         mov       ch,0                     ; á°taá hodnoty
         mov       cl,ds:[si]               ; CL <- dÇlka textu
         inc       si                       ; zaá†tek textu
         rep       movsb                    ; p©enos textu
         ret

SetTISBg ENDP

; -----------------------------------------------------------------------------
;        dek¢dov†n° konce p©ep°naáe do ES:DI
; -----------------------------------------------------------------------------

SetTISEn PROC      NEAR

; ------ znak ukonáen° parametru "]"

         mov       byte ptr es:[di],"]"     ; ukonáovac° znak p©ep°naáe
         inc       di

; ------ p©°padnÇ ukonáen° ©†dku CR/LF

         mov       word ptr es:[di],CR + LF*HI ; ukonáen° ©†dku CR/LF
         ret

SetTISEn ENDP

; -----------------------------------------------------------------------------
;        zru®en° ©†dku ES:DI s p©ep°naái ze segmentu AX -> CX=poáet bajtñ
; -----------------------------------------------------------------------------

DelLISwc PROC      FAR

; ------ stanoven° dÇlky ©†dku

         push      di
         dec       di                       ; p©ednastaven° ukazatele dat
DelLISw1:inc       di                       ; zvò®en° ukazatele textu ©†dku

; ------ test, zda je konec dat

         cmp       di,es:[0]                ; je konec dat ?
         jae       DelLISw8                 ; je konec dat

; ------ test, zda je platnò znak

         cmp       byte ptr es:[di],TAB     ; je platnò znak ?
         je        DelLISw1                 ; tabul†tor je platnò znak
         cmp       byte ptr es:[di]," "     ; je platnò znak ?
         jae       DelLISw1                 ; je platnò znak

; ------ test, zda zbòvaj° alespo§ 2 znaky

         mov       cx,di                    ; CX <- ukazatel dat
         inc       cx                       ; n†sleduj°c° adresa
         cmp       cx,es:[0]                ; zbòvaj° 2 bajty ?
         jae       DelLISw3                 ; zbòv† jië jen 1 znak

; ------ test, zda je konec ©†dku k vypu®tàn°

         cmp       word ptr es:[di],CR + LF*HI ; je CR/LF ?
         je        DelLISw4                 ; je CR/LF
         cmp       word ptr es:[di],LF + CR*HI ; je LF/CR ?
         je        DelLISw4                 ; je LF/CR
DelLISw3:cmp       byte ptr es:[di],LF      ; je LF ?
         je        DelLISw6                 ; je LF
         cmp       byte ptr es:[di],CR      ; je CR ?
         jne       DelLISw8                 ; nen° CR

; ------ p©eskoáen° konce ©†dku LF, CR, LF/CR nebo CR/LF

         dec       di                       ; p©ednastaven° ukazatele - 1
DelLISw4:inc       di                       ; p©eskoáen° znaku LF/CR nebo CR/LF
DelLISw6:inc       di                       ; p©eskoáen° znaku LF nebo CR

; ------ p©°prava dÇlky dat ke zru®en° -> CX

DelLISw8:mov       cx,di                    ; CX <- konec textu
         pop       di
         sub       cx,di                    ; CX <- dÇlka textu ©†dku

; ------ zru®en° dat ©†dku

         call      far ptr DelDat           ; zru®en° dat ©†dku
         ret

DelLISwc ENDP

; -----------------------------------------------------------------------------
;        naáten° á°selnÇho p©ep°naáe DS:SI v ©†dku ES:DI -> AX (CY=nen°,AX=0)
; -----------------------------------------------------------------------------

GetNISwc PROC      FAR

         push      di
         xor       ax,ax                    ; p©ednastaven° á°sla
         call      SrcISwch                 ; nalezen° p©ep°naáe
         jc        GetNISw9                 ; p©ep°naá nenalezen
         call      Get0ISwc                 ; naáten° á°sla
GetNISw9:pop       di
         ret

GetNISwc ENDP

; -----------------------------------------------------------------------------
;     naáten° á°selnÇho p©ep°naáe DS:SI v ©†dku ES:DI -> AX,DX (CY=nen°,AX/DX=0)
; -----------------------------------------------------------------------------

Get2ISwc PROC      FAR

         push      di
         xor       ax,ax                    ; p©ednastaven° á°sla
         call      SrcISwch                 ; nalezen° p©ep°naáe
         jc        Get2ISw9                 ; p©ep°naá nenalezen
         call      Get0ISwc                 ; naáten° á°sla
         xchg      ax,dx                    ; DX <- naátenÇ á°slo
         call      Get0ISwc                 ; naáten° á°sla
         xchg      ax,dx                    ; AX <- prvn° á°slo, DX <- druhÇ á°slo
Get2ISw9:pop       di
         ret

Get2ISwc ENDP

; -----------------------------------------------------------------------------
;        naáten° á°sla p©ep°naáe z ES:DI -> AX
; -----------------------------------------------------------------------------

Get0ISwc PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      dx

; ------ naáten° dal®° á°slice

         xor       bx,bx                    ; BX <- p©°prava st©adaáe
Get0ISw2:call      GetISChr                 ; naáten° dal®°ho znaku
         jc        Get0ISw8                 ; nen° dal®° znak
         sub       al,"0"                   ; konverze na á°slo
         cmp       al,9                     ; je to platn† á°slice ?
         ja        Get0ISw7                 ; nen° to platn† á°slice

; ------ p©id†n° á°slice ke st©adaái

         mov       ah,0
         push      ax
         mov       al,10                    ; n†sobitel
         mul       bx                       ; vyn†soben° st©adaáe
         pop       bx                       ; naáten† á°slice
         add       bx,ax                    ; p©id†n° á°slice ke st©adaái
         jmp       short Get0ISw2           ; dal®° á°slice

; ------ p©°pradnò oddàlovaá dat se vypust°

Get0ISw7:cmp       al,";"-"0"               ; je st©edn°k ?
         je        Get0ISw8                 ; st©edn°k se vypust°
         cmp       al,","-"0"               ; je oddàlovaá dat ?
         je        Get0ISw8                 ; á†rka se vypust°
         cmp       al,"."-"0"               ; nebo je desetinn† teáka ?
         je        Get0ISw8                 ; desetinn† teáka se vypust°
         dec       di                       ; n†vrat posledn°ho znaku

; ------ n†vrat registrñ

Get0ISw8:xchg      ax,bx                    ; AX <- naátenÇ á°slo
         clc                                ; p©°znak operace OK
         pop       dx
         pop       bx
         ret

Get0ISwc ENDP

; -----------------------------------------------------------------------------
; naáten° text. p©ep°naáe DS:SI v ©†dku ES:DI -> AX=hodnota 1.. (CY=nen°,AX=0)
; -----------------------------------------------------------------------------

GetTISwc PROC      FAR

; ------ £schova registrñ

         push      bx
         push      si
         push      di

; ------ nalezen° p©ep°naáe DS:SI

         xor       ax,ax                    ; p©ednastaven° á°taáe
         call      SrcISwch                 ; nalezen° p©ep°naáe
         jc        GetTISw9                 ; p©ep°naá nenalezen

; ------ posun ukazatele textu k dal®° poloëce

GetTISw2:mov       bh,0
         mov       bl,ds:[si]               ; dÇlka textu
         inc       si
         add       si,bx                    ; n†sleduj°c° text

; ------ test, zda bude dal®° poloëka

         inc       ax                       ; zvò®en° á°taáe hodnoty
         cmp       byte ptr ds:[si],0       ; je dal®° hodnota ?
         stc                                ; p©°znak chyby
         je        GetTISw9                 ; p©ep°naá nenalezen

; ------ porovn†n° dal®° poloëky p©ep°naáe

         call      TstISTxt                 ; test poloëky p©ep°naáe
         jc        GetTISw2                 ; poloëka neodpov°d† - test dal®°

; ------ n†vrat registrñ

GetTISw9:pop       di
         pop       si
         pop       bx
         ret

GetTISwc ENDP

; -----------------------------------------------------------------------------
;   nalezen° p©ep°naáe DS:SI v ©†dku ES:DI -> CY=nen°, ES:DI=dal®° adresa
; -----------------------------------------------------------------------------

SrcISwch PROC      NEAR

; ------ £schova registrñ

         push      ax

; ------ nalezen° zaá†tku dal®°ho p©ep°naáe

SrcISwc2:call      GetISChr                 ; naáten° dal®°ho znaku
         jc        SrcISwc8                 ; nen° dal®° znak
         cmp       al,"["                   ; je zaá†tek dal®°ho p©ep°naáe
         jne       SrcISwc2                 ; nalezen° zaá†tku p©ep°naáe

; ------ porovn†n° textu p©ep°naáe

         call      TstISTxt                 ; test p©ep°naáe
         jc        SrcISwc2                 ; p©ep°naá neodpov°d† - dal®°

; ------ n†vrat registrñ

SrcISwc8:pop       ax
         ret

SrcISwch ENDP

; -----------------------------------------------------------------------------
;  test textu DS:SI v ©†dku ES:DI -> CY=nen° text, ES:DI=adresa za textem
; -----------------------------------------------------------------------------

TstISTxt PROC      NEAR

; ------ £schova registrñ (DI jako posledn° !)

         push      ax
         push      cx
         push      si

         push      di                       ; mus° bòt jako posledn° !

; ------ p©°prava dÇlky textu

         mov       ch,0
         mov       cl,ds:[si]               ; dÇlka textu

; ------ porovn†n° textu

TstISTx2:call      GetISChr                 ; naáten° znaku s textu
         jc        TstISTx8                 ; nen° dal®° znak
         inc       si                       ; zvò®en° ukazatele textu
         cmp       al,ds:[si]               ; odpov°d† znak ?
         loope     TstISTx2                 ; dal®° znak
         jne       TstISTx8                 ; text neodpov°d†

; ------ text odpov°d† OK (zde je NC=operace OK)

         pop       cx                       ; zru®en° ukazatele textu
         jmp       short TstISTx9

; ------ text neodpov°d†

TstISTx8:stc                                ; p©°znak, ëe text neodpov°d†
         pop       di                       ; n†vrat ukazatele textu

; ------ n†vrat registrñ

TstISTx9:pop       si
         pop       cx
         pop       ax
         ret

TstISTxt ENDP

; -----------------------------------------------------------------------------
;        naáten° znaku z ©†dku ES:DI -> AL (CY=nen° dal®° znak)
; -----------------------------------------------------------------------------

GetISChr PROC      NEAR

GetISCh1:cmp       di,es:[0]                ; je dal®° znak ?
         cmc
         jc        GetISCh2                 ; nen° dal®° znak
         mov       al,es:[di]               ; naáten° znaku
         inc       di                       ; p©eskoáen° znaku
         call      far ptr UpCase           ; konverze na velkÇ p°smeno
         cmp       al,TAB
         je        GetISCh1                 ; tabul†tor se vypust°
         cmp       al," "
         je        GetISCh1                 ; mezera se vypust°
         ja        GetISCh2                 ; je platnò znak OK
         dec       di                       ; n†vrat neplatnÇho znaku
GetISCh2:ret

GetISChr ENDP

; *****************************************************************************
;
;                        Obsluha hesla z†pisn°ku
;
; *****************************************************************************
;˛
; -----------------------------------------------------------------------------
;        zad†n° hesla (okno ES)
; -----------------------------------------------------------------------------

EditEHes PROC      NEAR

EditEHs2:call      EZapHesl                 ; zad†n° hesla
         jc        EditEHs9                 ; p©eru®en° operace
         je        EditEHs9                 ; nebyla zmàna hesla
         or        byte ptr es:[TextParm],bit1+bit3 ; soubor modifikov†n+promànnÇ
         cmp       byte ptr es:[TextHesN],0 ; je zad†no heslo ?
         jne       EditEHs2                 ; byla zmàna - opakov†n° zad†n°
EditEHs9:ret

EditEHes ENDP

; -----------------------------------------------------------------------------
;        zad†n° hesla p©°stupu k souboru (okno ES) (CY=p©eru®en°, ZY=nen° zmàna)
; -----------------------------------------------------------------------------

EZapHesl PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di

; ------ p©°prava p©edvolby

         mov       ah,0
         mov       al,es:[TextHesN]         ; dÇlka hesla
         mov       ds:[TBLHesPN],ax         ; dÇlka hesla
         mov       word ptr ds:[TBLHesPA],TextHesl ; adresa hesla
         mov       word ptr ds:[TBLHesPA+2],es ; segment hesla

; ------ zad†n° textu hesla

         mov       si,offset TBLHesMn
         call      far ptr Lin0MenF         ; zad†n° hesla
         jc        EZapHes9                 ; p©eru®en° operace

; ------ p©°prava parametrñ textu

         cld
         mov       ah,0                     ; p©°znak - nen° zmàna
         mov       di,TextHesl              ; zaá†tek bufferu hesla
         mov       si,offset LinBuff        ; buffer textu
         mov       ch,0
         mov       cl,ds:[LinNum]           ; poáet bajtñ textu
         cmp       cl,es:[TextHesN]         ; je zmàna dÇlky textu hesla ?
         je        EZapHes2                 ; nen° zmàna dÇlky textu hesla
         mov       ah,1                     ; p©°znak zmàny textu hesla
EZapHes2:jcxz      EZapHes7                 ; nen° dal®° znak

; ------ p©enesen° textu hesla

EZapHes3:lodsb                              ; naáten° znaku
         cmp       al,es:[di]               ; je zmàna textu hesla ?
         je        EZapHes4                 ; nen° zmàna textu hesla
         mov       ah,1                     ; p©°znak zmàny textu hesla
EZapHes4:call      far ptr UpCase           ; konverze na velkÇ p°smeno
         cmp       al," "
         je        EZapHs42                 ; mezera povolena
         cmp       al,"0"
         jb        EZapHes5                 ; nepovolenò znak
         cmp       al,"9"
         jbe       EZapHs42                 ; á°slice je povolena
         cmp       al,"A"
         jb        EZapHes5                 ; nepovolenò znak
         cmp       al,"Z"
         ja        EZapHes5                 ; nepovolenò znak
EZapHs42:stosb                              ; uloëen° znaku
EZapHes5:loop      EZapHes3                 ; dal®° znak

; ------ vypu®tàn° nadbyteánòch mezer

         inc       di                       ; p©ednastaven°
EZapHes6:dec       di
         cmp       di,TextHesl              ; je jië zaá†tek bufferu ?
         jbe       EZapHes7                 ; je jië zaá†tek bufferu
         cmp       byte ptr es:[di-1]," "   ; je na konci mezera ?
         je        EZapHes6                 ; mezera se vypust°

; ------ uloëen° dÇlky zadanÇho textu hesla

EZapHes7:sub       di,TextHesl              ; dÇlka textu
         mov       cx,di                    ; CX <- dÇlka textu hesla
         mov       es:[TextHesN],cl         ; dÇlka textu hesla
         or        ah,ah                    ; byla zmàna hesla (ZY=nebyla) ?
;         clc

; ------ n†vrat registrñ

EZapHes9:pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

EZapHesl ENDP

; -----------------------------------------------------------------------------
;        zak¢dov†n° souboru, adresa textu ES:DI
; -----------------------------------------------------------------------------

ZapZakod PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      di

; ------ p©°prava registrñ

         xor       bx,bx                    ; offset v heslu
         cmp       es:[TextHesN],bl         ; je heslo ?
         je        ZapZakd9                 ; nen° heslo
         xor       dx,dx                    ; st©adaá k¢dovac°ho kl°áe
         mov       ch,0                     ; CH <- 0

; ------ zak¢dov†n° jednoho bajtu

ZapZakd2:cmp       di,es:[0]                ; je dal®° bajt dat ?
         jae       ZapZakd9                 ; nen° dal®° bajt
         call      ZapZakd0                 ; zak¢dov†n° jednoho bajtu
         jmp       short ZapZakd2           ; dal®° bajt

; ------ n†vrat registrñ

ZapZakd9:pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

ZapZakod ENDP

; -----------------------------------------------------------------------------
;        zak¢dov†n° jednoho bajtu
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=ukazatel dat
;        BX=offset v heslu
;        CH=0
;        DX=st©adaá k¢dovac°ho kl°áe
;        AH=á°taá bajtñ
; VùSTUP: ES:DI=ukazatel dat + 1
;         BX=novò offset v heslu
;         DX=novò st©adaá k¢dovac°ho kl°áe
;         AH=á°taá bajtñ - 1 (ZY=nen° dal®° bajt)
; niá° registry AL a CL !
; -----------------------------------------------------------------------------

ZapZakd0 PROC      NEAR

         mov       al,es:[di]               ; bajt k zak¢dov†n°

         xor       dl,bl                    ; po©adovò bajt
         add       dx,"DM"                  ; + konstanta
         mov       cl,es:[bx+TextHesl]      ; znak hesla
         sub       dx,cx
         and       cl,bit0+bit1+bit2+bit3   ; rotace
         rol       dx,cl                    ; rotace k¢dovac°ho kl°áe

         ror       al,cl                    ; rotace k¢dovanÇho bajtu
         xor       al,dl                    ; zak¢dov†n° bajtu

         cld
         stosb

         inc       bx                       ; zvò®en° offsetu v heslu
         cmp       bl,es:[TextHesN]         ; je dal®° znak hesla ?
         jb        ZapZak02                 ; je je®tà dal®° znak hesla
         xor       bx,bx                    ; offset na zaá†tek hesla
ZapZak02:dec       ah                       ; á°taá bajtñ
         ret

ZapZakd0 ENDP

; -----------------------------------------------------------------------------
;        odk¢dov†n° souboru tabulky, adresa textu ES:DI
; -----------------------------------------------------------------------------

ZapDekod PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      di

; ------ p©°prava registrñ

         xor       bx,bx                    ; offset v heslu
         cmp       es:[TextHesN],bl         ; je heslo ?
         je        ZapDekd9                 ; nen° heslo
         xor       dx,dx                    ; st©adaá k¢dovac°ho kl°áe
         mov       ch,0

; ------ zak¢dov†n° jednoho bajtu

ZapDekd2:cmp       di,es:[0]                ; je dal®° bajt dat ?
         jae       ZapDekd9                 ; nen° dal®° bajt
         call      ZapDekd0                 ; dek¢dov†n° jednoho bajtu
         jmp       short ZapDekd2           ; dal®° bajt

; ------ n†vrat registrñ

ZapDekd9:pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

ZapDekod ENDP

; -----------------------------------------------------------------------------
;        dek¢dov†n° jednoho bajtu
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=ukazatel dat
;        BX=offset v heslu
;        CH=0
;        DX=st©adaá k¢dovac°ho kl°áe
;        AH=á°taá bajtñ
; VùSTUP: ES:DI=ukazatel dat + 1
;         BX=novò offset v heslu
;         DX=novò st©adaá k¢dovac°ho kl°áe
;         AH=á°taá bajtñ + 1
;         AL=dek¢dovanò bajt
; niá° registr CL !
; -----------------------------------------------------------------------------

ZapDekd0 PROC      NEAR

         mov       al,es:[di]               ; bajt k zak¢dov†n°

         xor       dl,bl                    ; po©adovò bajt
         add       dx,"DM"                  ; + konstanta
         mov       cl,es:[bx+TextHesl]      ; znak hesla
         sub       dx,cx
         and       cl,bit0+bit1+bit2+bit3   ; rotace
         rol       dx,cl                    ; rotace k¢dovac°ho kl°áe

         xor       al,dl                    ; odk¢dov†n° bajtu
         rol       al,cl                    ; rotace k¢dovanÇho bajtu

         cld
         stosb

; ------ zvò®en° ukazatele hesla

         inc       bx                       ; zvò®en° offsetu v heslu
         cmp       bl,es:[TextHesN]         ; je dal®° znak hesla ?
         jb        ZapDkd02                 ; je je®tà dal®° znak hesla
         xor       bx,bx
ZapDkd02:inc       ah                       ; á°taá bajtñ
         ret

ZapDekd0 ENDP

CodeZap  ENDS

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;
;                                 Data
;
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

Data     SEGMENT

; -----------------------------------------------------------------------------
;        menu vòbàru z†pisn°ku
; -----------------------------------------------------------------------------
;˛
ZZMnuSel label     byte

         db        9                        ; typ menu - vòbàr souborñ

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        1                        ; poáet poloëek
         dw        1                        ; poáet poloëek celkem

         dw        0                        ; zaá†tek definice poloëek menu
         dw        SSMnSHlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@Zapisnik             ; á°slo str†nky velkÇ n†povàdy
         dw        0                        ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        ZZMnSTit                 ; adresa titulu okna
         dw        LinMenTM                 ; tabulka adres obsluh
         dw        LinMenTM                 ; tabulka podmenu
         dd        0                        ; n†vratov† adresa

         db        12                       ; poá†teán° pozice okna
         db        3                        ; poá†teán° ©†dek okna
         db        63                       ; ®°©ka okna
         db        18                       ; vò®ka okna

ZapsSeg  dw        0                        ; segment se seznamem souborñ
ZapsPth0 dw        0                        ; minim. dÇlka textu cesty
ZapsPthN dw        0                        ; dÇlka textu cesty seznamu
         dw        ZapsPath                 ; buffer s adres†©em seznamu
ZapsPthI db        3                        ; inicializaán° jmÇno podadres†©e
ZapsExt  db        'NOT'                    ; p©°pona pro vòbàr souborñ
ZapsTxt1 dw        ZapsTx11                 ; adresa textu "text"
OldZFrst dw        0                        ; uschovan† prvn° poloëka z†pisn°ku
OldZKurz dw        0                        ; uschovanò kurzor z†pisn°ku

ZZMnSTit db        8,'z†pisn°k'

ZapsTx11 db        4,'text'

; -----------------------------------------------------------------------------
;        okno editoru z†pisn°ku
; -----------------------------------------------------------------------------
;˛
TextMnu  label     byte

         db        16                       ; typ menu - editace textu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        1                        ; poáet poloëek menu
         dw        1                        ; celkovò poáet poloëek menu

         dw        0                        ; zaá†tek definice poloëek menu
         dw        TxtMnHl1                 ; adresa tabulky textñ n†povàdy
TextMnuH dw        Hlp@EditorZapisniku      ; á°slo str†nky velkÇ n†povàdy
         dw        0                        ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        TxtMnTit                 ; adresa titulu okna
         dw        LinMenTM                 ; adresy obsluh
         dw        LinMenTM                 ; adresa podmenu
         dd        0                        ; n†vratov† adresa

         db        0                        ; poá†teán° pozice okna
         db        1                        ; poá†teán° ©†dek okna
         db        80                       ; ®°©ka okna
         db        21                       ; vò®ka okna

TextSegm dw        0                        ; aktivn° segment s textem

TxtMnTit db        8,'z†pisn°k'

HelpS    SEGMENT   BYTE PUBLIC              ; n†povàda k menu
TxtMnHl1 db        93,'F2 uloë, F3 zaá., F4 konec, F5 kopie, F6 p©esun, F7 hledej, F8 zru®, F10 menu'
TxtMnHl2 db        74,'Nahradit nalezenò ©etàzec ?  A=Ano, N=Ne, V=V®echny, Esc=p©eru®en°'
HelpS    ENDS

TxtMnHM1 label     byte
         db        9
         dw        3c00h                    ; F2
         db        9
         dw        3d00h                    ; F3
         db        10
         dw        3e00h                    ; F4
         db        10
         dw        3f00h                    ; F5
         db        11
         dw        4000h                    ; F6
         db        11
         dw        4100h                    ; F7
         db        9
         dw        4200h                    ; F8
         db        -1
         dw        4400h                    ; F10

TxtMnHM2 label     byte
         db        29
         dw        0                        ; neplatn† kl†vesa
         db        7
         dw        "A"                      ; Ano
         db        6
         dw        "N"                      ; Ne
         db        11
         dw        "V"                      ; V®echny
         db        -1
         dw        11bh                     ; Esc

; ------ menu - uloëen° souboru

ZUSMnLin label     byte
         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        3                        ; poáet platnòch poloëek menu
         dw        8                        ; celkovò poáet poloëek menu

         dw        ZUSMnPol                 ; zaá†tek definice poloëek menu
         dw        ZUSMnHlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@EditorZapisniku      ; á°slo str†nky velkÇ n†povàdy
         dw        ZUSMnBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        ZUSMnTit                 ; adresa titulu okna
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

ZUSMnPol db        bit6,0
         db        bit6,21,'Text byl modifikov†n.'
         db        bit6,31,'Chcete uloëit provedenÇ zmàny ?'
         db        bit6,0
         db        bit6+bit7,0
         db        1,6,'Uloëit'
         db        1,8,'Neuloëit'
         db        1,8,'P©eru®it'

ZUSMnBlk db        0,0,0                    ; blokovac° tabulka

HelpS    SEGMENT   BYTE PUBLIC
ZUSMnHlp db        13,'Uloëen° textu'
         db        47,'Text se neuloë°, pñvodn° obsah zñstane nezmànàn'
         db        42,'P©eru®en° operace a n†vrat k editaci textu'
HelpS    ENDS

ZUSMnTit db        16,'text modifikov†n'

; ------ menu funkc° editoru
;˛
ZZMMVert label     byte

         db        2                        ; typ menu - vertik†ln° podmenu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        19                       ; poáet platnòch poloëek menu
         dw        19                       ; celkovò poáet poloëek menu

         dw        ZZMMVPol                 ; adresa definice poloëek
         dw        ZZMMVHlp                 ; adresa n†povàd
         dw        Hlp@MenuEditoruZapisniku ; á°slo str†nky velkÇ n†povàdy
         dw        ZZMMVBlk                 ; adresa blokovac° tabulky
         dw        ZZMMVSwc                 ; adresa tabulky p©ep°naáñ
         dw        ZZMMVTit                 ; adresa titulu okna
         dw        ZZMMVExe                 ; adresa obsluh
         dw        LinMenTM                 ; adresa podmenu
         dd        0                        ; n†vratov† adresa

         db        30                       ; poá†teán° pozice
         db        5                        ; poá†teán° ©†dek
         db        20                       ; ®°©ka
         db        21                       ; vò®ka

ZZMMVPol db        9,13,'zaá†tek Bloku'     ; F3: zaá†tek bloku
         db        4,11,'konEc bloku'       ; F4: konec bloku
         db        1,11,'Kopie bloku'       ; F5: kopie bloku
         db        1,12,'P©esun bloku'      ; F6: p©esun bloku
         db        1,12,'Ru®en° bloku'      ; F8: zru®en° bloku
         db        1+bit7,14,'Viditelnò blok' ; F9: zobrazenò blok
         db        1,10,'Naáti blok'        ; Shift-F5 naáti blok
         db        1,10,'Zapi® blok'        ; Shift-F3 zapi® blok
         db        1,4,'Uloë'               ; F2: uloëen° souboru
         db        1,6,'Hledej'             ; F7: hled†n° textu
         db        2,6,'nAhraÉ'             ; Shift-F7: n†hrada textu
         db        1,4,'D†le'               ; Ctrl-L: hled†n° d†le
         db        1,8,'Form†tuj'           ; Ctrl-B form†tov†n° odstavce
         db        1,7,'Centruj'            ; Ctrl-OC vyst©edàn° ©†dku
         db        1,16,'Okraj ©†dku '      ; nastaven° pravÇho okraje
ZZMMVPl2 db        '   0'
         db        1,16,'Tabul†tor   '      ; nastaven° poátu pozic na tabul†tor
ZZMMVPl3 db        '   0'
         db        1,16,'Str†nka     '      ; dÇlka str†nky
ZZMMVPl4 db        '   0'
         db        2,4,'tIsk'               ; Ctrl-KP tisk
         db        4,16,'hesLo        '     ; zad†n° hesla
ZZMnVPlH db        '   '

ZZMMVBlk db        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
ZZMMVSwc db        0
ZZMMVTit db        4,'menu'

HelpS    SEGMENT   BYTE PUBLIC
ZZMMVHlp db        40,'Oznaáen° zaá†tku bloku (F3, Ctrl-KB)'
         db        38,'Oznaáen° konce bloku (F4, Ctrl-KK)'
         db        64,'Zkop°rov†n° oznaáenÇho bloku na pozici kurzoru (F5, Ctrl-KC)'
         db        59,'P©esun oznaáenÇho bloku na pozici kurzoru (F6, Ctrl-KV)'
         db        42,'Zru®en° oznaáenÇho bloku (F8, Ctrl-KY)'
         db        49,'Zapnut°/vypnut° zobrazen° bloku (F9, Ctrl-KH)'
         db        48,'Naáten° bloku ze souboru (Shift-F5, Ctrl-KR)'
         db        59,'Uloëen° oznaáenÇho bloku do souboru (Shift-F3, Ctrl-KW)'
         db        50,'Uloëen° obsahu textu, pokud byl modifikov†n (F2)'
         db        56,'Vyhled†v†n° zadanÇho textovÇho ©etàzce (F7, Ctrl-QF)'
         db        72,'Vyhled†v†n° textovÇho ©etàzce s n†hradou za jinò (Shift-F7, Ctrl-QA)'
         db        56,'Pokraáov†n° ve vyhled†v†n° nebo n†hradà textu (Ctrl-L)'
         db        57,'Form†tov†n° textu od kurzoru po konec odstavce (Ctrl-B)'
         db        57,'Vyst©edàn° textu doprost©ed ©†dku (Ctrl-OC, Shift-F9)'
         db        30,'Nastaven° pravÇho okraje ©†dku'
         db        34,'Nastaven° poátu pozic na tabul†tor'
         db        23,'Nastaven° dÇlky str†nky'
         db        53,'Vyti®tàn° souboru na tisk†rnu (Ctrl-KP, Shift-F6)'
         db        40,'Zad†n° hesla k uzamáen° p©°stupu k textu'

ZZMMVHl2 db        39,'Zadejte pravò okraj ©†dku 1 aë 9999'
ZZMMVHl3 db        46,'Zadejte poáet pozic na tabul†tor 1 aë 9999'
ZZMMVHl4 db        44,'Zadejte poáet ©†dkñ na str†nku 1 aë 9999'
HelpS    ENDS

ZZMMVExe dd        ZapisMn0                 ; F3: zaá†tek bloku
         dd        ZapisMn0                 ; F4: konec bloku
         dd        ZapisMn0                 ; F5: kopie bloku
         dd        ZapisMn0                 ; F6: p©esun bloku
         dd        ZapisMn0                 ; F8: zru®en° bloku
         dd        ZapisMn0                 ; F9: zobrazenò blok
         dd        ZapisMn0                 ; Shift-F5 naáti blok
         dd        ZapisMn0                 ; Shift-F3 zapi® blok
         dd        ZapisMn0                 ; F2: uloëen° souboru
         dd        ZapisMn0                 ; F7: hled†n° textu
         dd        ZapisMn0                 ; Shift-F7: n†hrada textu
         dd        ZapisMn0                 ; Ctrl-L: hled†n° d†le
         dd        ZapisMn0                 ; Ctrl-B form†tov†n° odstavce
         dd        ZapisMn0                 ; (Shift-F9) Ctrl-OC vyst©edàn° ©†dku
         dd        ZapisMn2                 ; nastaven° pravÇho okraje
         dd        ZapisMn3                 ; nastaven° pozic na tabul†tor
         dd        ZapisMn4                 ; nastaven° poátu ©†dkñ na str†nku
         dd        ZapisMn0                 ; (Shift-F6) Ctrl-KP tisk
         dd        ZapisMn0                 ; zadan° hesla p©°stupu

; ------ soubor jië existuje

ZX1MnLin label     byte
         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        2                        ; poáet platnòch poloëek menu
         dw        7                        ; celkovò poáet poloëek menu

         dw        ZX1MnPol                 ; zaá†tek definice poloëek menu
         dw        ZX1MnHlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@MenuEditoruZapisniku ; á°slo str†nky velkÇ n†povàdy
         dw        ZX1MnBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        ZX1MnTit                 ; adresa titulu okna
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

ZX1MnPol db        bit6,0
         db        bit6,27,'Zadanò soubor jië existuje.'
         db        bit6,37,'Chcete jej p©epsat ukl†danòm blokem ?'
         db        bit6,0
         db        bit6+bit7,0
         db        1,7,'P©epsat'
         db        1,6,'N†vrat'

ZX1MnBlk db        0,0                      ; blokovac° tabulka

ZX1MnTit db        15,'soubor existuje'

HelpS    SEGMENT   BYTE PUBLIC
ZX1MnHlp db        46,'P©eps†n° existuj°c°ho souboru ukl†danòm blokem'
         db        3,1
         dw        MenuHlP2
HelpS    ENDS

; ------ text k vyhled†n°
; !!!!!!  Menu se vyvol†v† i z n†povàdy !!!!

ZZHMnLin label     byte

         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        3                        ; poáet platnòch poloëek menu
         dw        5                        ; celkovò poáet poloëek menu

         dw        ZZHMnPol                 ; zaá†tek definice poloëek menu
         dw        ZZHMnHlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@MenuEditoruZapisniku ; á°slo str†nky velkÇ n†povàdy
         dw        ZZHMnBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        ZZHMnTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        20                       ; poá†teán° pozice okna
         db        0                        ; poá†teán° ©†dek okna
         db        40                       ; ®°©ka okna
         db        8                        ; vò®ka okna

         dw        TextFndX                 ; maxim†ln° dÇlka textu ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        1                        ; celkovò poáet ©†dkñ
         dw        1                        ; poáet zobrazenòch ©†dkñ

         db        bit2                     ; maska zad†vanòch znakñ - v®echny
         db        0,'      '               ; zak†zanÇ znaky

         db        HistFind                 ; historie hled†n°
         db        0                        ; poáet p©edvoleb

ZZHMnPol db        bit6,17,'Text k vyhled†n°:'
         db        0,0
         db        bit6+bit7,0
         db        1,6,'Hledej'
         db        1,6,'N†vrat'

ZZHMnBlk db        0,0,0                    ; blokovac° tabulka

ZZHMnTit db        6,'hledej'

HelpS    SEGMENT   BYTE PUBLIC
ZZHMnHlp db        73,'Zadejte textovò ©etàzec k vyhled†n° (velk† a mal† p°smena se nerozli®uj°)'
         db        24,'Vyhled†n° zadanÇho textu'
         db        3,1
         dw        MenuHlP2
HelpS    ENDS

; ------ text k vyhled†n° a n†hradà

ZZNMnLin label     byte

         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        3                        ; poáet platnòch poloëek menu
         dw        5                        ; celkovò poáet poloëek menu

         dw        ZZNMnPol                 ; zaá†tek definice poloëek menu
         dw        ZZNMnHlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@MenuEditoruZapisniku ; á°slo str†nky velkÇ n†povàdy
         dw        ZZNMnBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        ZZNMnTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        20                       ; poá†teán° pozice okna
         db        0                        ; poá†teán° ©†dek okna
         db        40                       ; ®°©ka okna
         db        8                        ; vò®ka okna

         dw        TextFndX                 ; maxim†ln° dÇlka textu ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        1                        ; celkovò poáet ©†dkñ
         dw        1                        ; poáet zobrazenòch ©†dkñ

         db        bit2                     ; maska zad†vanòch znakñ - v®echny
         db        0,'      '               ; zak†zanÇ znaky

         db        HistFind                 ; historie hled†n°
         db        0                        ; poáet p©edvoleb

ZZNMnPol db        bit6,27,'Text k vyhled†n° a n†hradà:'
         db        0,0
         db        bit6+bit7,0
         db        1,8,'Pokraáuj'
         db        1,6,'N†vrat'

ZZNMnBlk db        0,0,0                    ; blokovac° tabulka

ZZNMnTit db        13,'n†hrada textu'

HelpS    SEGMENT   BYTE PUBLIC
ZZNMnHlp db        71,'Zadejte textovò ©etàzec k n†hradà (velk† a mal† p°smena se nerozli®uj°)'
         db        55,'Pokraáov†n° zad†n°m textu, kteròm bude ©etàzec nahrazen'
         db        3,1
         dw        MenuHlP2
HelpS    ENDS

; ------ n†hradn° text

ZZN2MLin label     byte

         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        3                        ; poáet platnòch poloëek menu
         dw        5                        ; celkovò poáet poloëek menu

         dw        ZZN2MPol                 ; zaá†tek definice poloëek menu
         dw        ZZN2MHlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@MenuEditoruZapisniku ; á°slo str†nky velkÇ n†povàdy
         dw        ZZN2MBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        ZZN2MTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        20                       ; poá†teán° pozice okna
         db        0                        ; poá†teán° ©†dek okna
         db        44                       ; ®°©ka okna
         db        8                        ; vò®ka okna

         dw        TextSubX                 ; maxim†ln° dÇlka textu ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        1                        ; celkovò poáet ©†dkñ
         dw        1                        ; poáet zobrazenòch ©†dkñ

         db        bit2                     ; maska zad†vanòch znakñ - v®echny
         db        1,26,'     '             ; zak†zanÇ znaky

         db        HistFind                 ; historie hled†n°
         db        0                        ; poáet p©edvoleb

ZZN2MPol db        bit6,34,'Text k n†hradà nalezenÇho ©etàzce:'
         db        0,0
         db        bit6+bit7,0
         db        1,7,'N†hrada'
         db        1,6,'P©eru®'

ZZN2MBlk db        0,0,0                    ; blokovac° tabulka

ZZN2MTit db        14,'text k n†hradà'

HelpS    SEGMENT   BYTE PUBLIC
ZZN2MHlp db        59,'Zadejte textovò ©etàzec, kteròm bude nalezenò text nahrazen'
         db        72,'Vyhled†n° a n†hrada textovÇho ©etàzce (od kurzoru smàrem ke konci textu)'
         db        3,1
         dw        MenuHlP2
HelpS    ENDS

; ------ text nenalezen

ZZ2MnLin label     byte
         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        1                        ; poáet platnòch poloëek menu
         dw        5                        ; celkovò poáet poloëek menu

         dw        ZZ2MnPol                 ; zaá†tek definice poloëek menu
         dw        ChbLnMeH                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@MenuEditoruZapisniku ; á°slo str†nky velkÇ n†povàdy
         dw        ZZ2MnBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        ZZ2MnTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        20                       ; poá†teán° pozice okna
         db        0                        ; poá†teán° ©†dek okna
         db        35                       ; ®°©ka okna
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

ZZ2MnPol db        bit6,0
         db        bit6,23,'Hledanò text nenalezen:'

         db        bit6,11,'"',4,0,3
ZZ2MnPl2 db        0
         dd        TextFnd
         db        0,'"'

         db        bit6+bit7,0
         db        1,6,'N†vrat'

ZZ2MnBlk db        0                        ; blokovac° tabulka

ZZ2MnTit db        14,'text nenalezen'

ZZMnTTxt db        15,'Prob°h† tisk...'
ZZMnTPRN db        'PRN',0
ZZMnTCR  db        13,10,12                 ; CR/LF + FF

; ------ intern° p©ep°naáe

IdntISwT db        6,'IDENT='               ; identifikaán° p©ep°naá
         db        7,'NOTEPAD'              ; 1: z†pisn°k
         db        5,'NOTES'                ; 2: star®° identifik†tor z†pisn°ku
         db        11,'DOSMAN_INIT'         ; 3: konfigurace
         db        11,'DOSMAN_MENU'         ; 4: menu
         db        4,'DIAR'                 ; 5: di†©
         db        0

KodISwcT db        4,'KOD='                 ; n†rodn° k¢d
         db        7,'KEYBCS2'              ; 1: p©°znak k¢du KEYBCS2
         db        6,'LATIN2'               ; 2: p©°znak k¢du Latin 2
         db        0

;VerISwcT db        4,'VER='                 ; oznaáen° verze

PagISwcT db        5,'PAGE='                ; dÇlka str†nky

TabISwcT db        4,'TAB='                 ; poáet pozic na tabul†tor

RghISwcT db        6,'RIGHT='               ; pravò okraj

CurISwcT db        5,'CURS='                ; £schova kurzoru
TopISwcT db        4,'TOP='                 ; zobrazenò poá†tek

PswISwcT db        9,'PASSWORD='            ; p©°znak uzamáen° souboru heslem
                                            ;  (n†sleduje kontroln° souáet)

; ------ data pro z†pisn°k
;
;ColText1 db        1bh                      ; bàën† barva textu
;ColText2 db        70h                      ; barva bloku
;ColText3 db        71h                      ; bàën† barva nadpisu
;ColText4 db        74h                      ; barva koment†©e v nadpisu
;ColText5 db        6ch                      ; barva okraje
;ColText6 db        74h                      ; barva p©elomu str†nky

; ------ aktu†ln° nastaven° parametrñ buÉ z DOSMAN.INI nebo z p©ep°naáñ v textu

ZZMnTIni label     byte
         db        1,20 dup(13)             ; inicializaán° ©etàzec pro tisk
ZZMnTLft dw        0                        ; levò okraj tisku (0 aë 99)
TextEOkr dw        78                       ; pravò okraj (pozice 1 aë 9999)
TextETab dw        8                        ; poáet pozic na tabul†tor (1-9999)
TextEStr dw        66                       ; poáet ©†dkñ na str†nku (1-9999)

; ------ inicializaán° nastaven° z DOSMAN.INI

TexIEOkr dw        78                       ; pravò okraj (pozice 1 aë 9999)
TexIETab dw        8                        ; poáet pozic na tabul†tor (1-9999)
TexIEStr dw        66                       ; poáet ©†dkñ na str†nku (1-9999)

TextEPoz dw        0                        ; uschovan† poá†teán° pozice ©†dku

TextPSum dw        0                        ; kontroln° souáet pro heslo

TextForP db        0                        ; parametry form†tov†n°
                                            ;   bit 0: 1=byl prvn° ©†dek
                                            ;   bit 1: 1=byl druhò ©†dek

                                            ;   bit 4: 1=zah†jeno oznaáov†n°
                                            ;            bloku pomoc° SHIFT
                                            ;   bit 5: 1=pevnò konec bloku p©i
                                            ;            oznaáov†n° se SHIFT

TextEPar db        0                        ; parametry
                                            ;   bit 0: 1=zobrazen° kurzoru
                                            ;   bit 1: 1=zobrazen° ©†dku
                                            ;   bit 2: 1=zobrazen° okna
                                            ;   bit 3: 1=zobrazen° v®eho
                                            ;   bit 4: 1=je n†hrada textu
                                            ;   bit 5: 1=n†hrada v®ech
                                            ;   bit 6: 1=nalezen ©etàzec
                                            ;   bit 7: 1=vypnut INSERT

ZapsTypI db        1                        ; identifik†tor souboru z†pisn°ku
                                            ;  (Nastavuje se p©ed vyvol†n°m
                                            ;   z†pisn°ku pro p©°pad, ëe nen°
                                            ;   identifikace zn†ma ze souboru)
                                            ;    0=neukl†d† se
                                            ;    1=z†pisn°k NOT
                                            ;    (2=neuráeno, nutno up©esnit)
                                            ;    3=konfiguraán° soubor INI
                                            ;    4=uëivatelskÇ menu MNU
                                            ;    5=di†©


ZapsPath db        FileMax+4 dup(0)         ; adres†© z†pisn°ku

Data     ENDS

         END


; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                          D A T A B è Z E - á†st 2
;
;                Zobrazen° datab†ze, obsluha p©°stupu k souboru
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
;                              InitBMnu
;                     inicializace menu datab†ze
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa definice menu
; *****************************************************************************

InitTBMn LABEL     FAR

InitBMnu PROC      FAR

         push      ax
         mov       al,ds:[Pozic]            ; poáet pozic na ©†dek
         mov       ds:[si+MnuSir],al        ; ®°©ka okna
         mov       al,ds:[Radku]            ; poáet ©†dkñ
         dec       ax
;         sub       al,3
         mov       ds:[si+MnuVys],al        ; vò®ka okna
         mov       word ptr ds:[si+MnuPoz],0 ; poá†teán° ©†dek a pozice
;         call      far ptr CentMenu         ; vyst©edàn° okna
         pop       ax
         ret

InitBMnu ENDP

; -----------------------------------------------------------------------------
;        zobrazen° kurzoru editoru datab†ze DS:SI
; -----------------------------------------------------------------------------

DispDBFK PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      dx
         push      es

; ------ vypnut° kurzoru, nen°-li editace

         test      byte ptr ds:[DBFEPar2],bit0 ; je nastaven° ®°©ky pole ?
         jnz       DspDBFK1                 ; je nastaven° ®°©ky pole
         test      byte ptr ds:[DBFEParm],bit0 ; je editace ?
         jnz       DspDBFK1                 ; je editace
         call      far ptr KurzOff          ; vypnut° kurzoru
         jmp       DspDBFK9

; ------ adresa segmentu okna

DspDBFK1:call      DBFAdrES                 ; aktualizace adresy okna -> ES

; ------ test, zda je str†nkovò reëim

         test      byte ptr es:[DBFParm],bit0 ; je str†nkovò reëim ?
         jz        DspDBFK6                 ; nen° str†nkovò reëim

; ------ stanoven° ©†dku kurzoru v str†nkovÇm reëimu

         call      GetDBRK                  ; stanoven° relativn°ho ©†dku
         sub       dx,es:[DBFTopL]          ; offset od prvn°ho ©†dku
         mov       dh,dl                    ; relativn° ©†dek v oknà
         add       dh,2                     ; p©iáten° poá†tku okna
         add       dh,ds:[si+MnuRad]        ; ©†dek

; ------ ukazatel popisovaáe poloëky

         mov       bx,es:[DBFAktP]          ; aktivn° poloëka
         shl       bx,1
         shl       bx,1
         shl       bx,1
         add       bx,es:[DBFAdrP]          ; adresa popisovaáe

; ------ pozice na ©†dku pro MEMO pole

         mov       dl,3                     ; pozice pro MEMO pole
         test      byte ptr es:[bx+DBFParX],bit5 ; je MEMO pole ?
         jnz       DspDBFK5                 ; je MEMO pole

; ------ pozice na ©†dku pro datum

         test      byte ptr es:[bx+DBFParX],bit3 ; je datum ?
         jz        DspDBFK3
         mov       bh,0
         mov       bl,ds:[FormDat]          ; form†t data (0=MDR, 1=DMR, 2=RMD)
         shl       bx,1
         shl       bx,1
         shl       bx,1
         add       bx,es:[DBFKurz]          ; pozice kurzoru v poloëce
         mov       dl,cs:[bx+EditPPT3]      ; pozice kurzoru
         jmp       short DspDBFK5

; ------ pozice na ©†dku pro áas

DspDBFK3:test      byte ptr es:[bx+DBFParX],bit6 ; je to áas ?
         jz        DspDBFK4                 ; nen° to áas
         mov       dl,es:[DBFKurz]          ; kurzor
         cmp       dl,2                     ; je oddàlovaá ?
         jb        DspDBFK5                 ; nen° oddàlovaá
         inc       dx                       ; p©iáten° oddàlovaáe
         cmp       dl,5                     ; je oddàlovaá ?
         jb        DspDBFK5                 ; nen° oddàlovaá
         inc       dx                       ; p©eskoáen° oddàlovaáe
         jmp       short DspDBFK5

; ------ pozice na ©†dku pro ostatn° poloëky

DspDBFK4:mov       bl,ds:[si+MnuSir]        ; ®°©ka okna
         sub       bl,15                    ; maxim†ln° ®°©ka poloëky
         mov       ax,es:[DBFKurz]          ; kurzor na ©†dku
         div       bl                       ; relativn° pozice na ©†dku
         mov       dl,ah                    ; pozice na ©†dku

; ------ korekce pozice

DspDBFK5:add       dl,13                    ; p©iáten° poá†tku okna
         add       dl,ds:[si+MnuPoz]        ; pozice
         jmp       short DspDBFK7           ; zobrazen° kurzoru

; ------ zobrazen° kurzoru v ©†dkovÇm reëimu

DspDBFK6:call      GetDBFK                  ; stanoven° kurzoru na ©†dku
         add       dl,ds:[si+MnuPoz]
         inc       dx
         sub       dx,es:[DBFTopP]          ; odeáten° poá†teán° pozice ©†dku

         mov       dh,-1
         test      byte ptr ds:[DBFEPar2],bit0 ; je nastaven° ®°©ky pole ?
         jnz       DsDBFK62                 ; je nastaven° ®°©ky pole
         mov       dh,es:[DBFAktZ]
         sub       dh,es:[DBFTopZ]
DsDBFK62:add       dh,ds:[si+MnuRad]
         add       dh,3

DspDBFK7:call      far ptr SetKurz          ; nastaven° pozice kurzoru

; ------ nastaven° velikosti kurzoru

         test      byte ptr ds:[DBFEParm],bit2 ; je INSERT ?
         jz        DspDBFK8                 ; nen° INSERT
         call      far ptr SizeLKur         ; nastaven° n°zkÇho kurzoru
         jmp       short DspDBFK9

DspDBFK8:call      far ptr SizeHKur         ; nastaven° vysokÇho kurzoru

; ------ n†vrat registrñ

DspDBFK9:pop       es
         pop       dx
         pop       bx
         pop       ax
         ret

DispDBFK ENDP

; -----------------------------------------------------------------------------
;     vòpoáet relativn°ho ©†dku kurzoru ve str†nkovÇm reëimu (okno ES -> DX)
; -----------------------------------------------------------------------------

GetDBRK  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      si

; ------ maxim†ln° ®°©ka textovÇ poloëky

         mov       dl,ds:[si+MnuSir]        ; ®°©ka okna
         sub       dl,15                    ; zbytek na poloëku
         mov       dh,0

; ------ nalezen° aktivn° poloëky (u kr†tkòch poloëek nep©esnost nevad°)

         xor       si,si                    ; ukazatel relativn°ho ©†dku
         mov       bx,es:[DBFAdrP]          ; ukazatel popisovaáñ
         mov       cx,es:[DBFAktP]          ; aktivn° poloëka
         jcxz      GetDBRK3                 ; je prvn° poloëka
GetDBRK1:mov       ax,es:[bx+DBFDelX]       ; dÇlka poloëky (bajtñ)
         dec       dx                       ; ®°©ka ©†dku - 1
         add       ax,dx                    ; zarovn†n° nahoru
         inc       dx                       ; n†vrat ®°©ky ©†dku
         div       dl                       ; vòpoáet poátu ©†dkñ
         mov       ah,0
         add       si,ax                    ; zvò®en° á°taáe ©†dkñ
         add       bx,DBFX                  ; adresa dal®° poloëky
         loop      GetDBRK1                 ; dal®° poloëka

; ------ korekce ©†dku pro posledn° poloëku

GetDBRK3:mov       ax,es:[DBFKurz]          ; pozice kurzoru v poloëce
         div       dl                       ; vòpoáet celòch ©†dkñ
         mov       ah,0
         add       si,ax                    ; zvò®en° á°taáe ©†dkñ

; ------ n†vrat registrñ

         mov       dx,si                    ; DX <- relativn° ©†dek

         pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

GetDBRK  ENDP

; -----------------------------------------------------------------------------
;  vòpoáet relativn° pozice kurzoru na ©†dku v ©†dkovÇm reëimu (okno ES -> DX)
; -----------------------------------------------------------------------------

GetDBFK  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx

; ------ nalezen° pozice kurzoru na ©†dku v ©†dkovÇm reëimu

         mov       bx,es:[DBFAdrP]          ; ukazatel popisovaáñ
         xor       dx,dx                    ; ukazatel pozice na ©†dku
         xor       ax,ax                    ; AX <- 0
         mov       cx,es:[DBFAktP]          ; aktivn° poloëka
         jcxz      GetDBFK2                 ; je prvn° poloëka
GetDBFK1:add       dx,es:[bx+DBFSirX]       ; zvò®en° ukazatele pozice
         inc       dx                       ; oddàlovac° mezera
         add       bx,DBFX                  ; dal®° popisovaá
         loop      GetDBFK1

; ------ p©°prava dÇlky poloëky -> CX

GetDBFK2:mov       al,es:[bx+DBFParX]       ; parametry poloëky
         mov       cl,10                    ; datum
         test      al,bit3                  ; je to datum ?
         jnz       GetDBFK3                 ; je to datum
         mov       cl,3                     ; logick† poloëka
         test      al,bit4                  ; logick† poloëka ?
         jnz       GetDBFK3                 ; logick† poloëka
         mov       cl,6                     ; MEMO pole
         test      al,bit5                  ; MEMO pole ?
         jnz       GetDBFK3                 ; MEMO pole
         mov       cl,8                     ; áas
         test      al,bit6                  ; áas ?
         jnz       GetDBFK3                 ; je to áas
         mov       cl,es:[bx+DBFDelX]       ; dÇlka pro text a á°slo

; ------ omezen° dÇlky poloëky podle zobrazenÇ ®°©ky

GetDBFK3:cmp       cx,es:[bx+DBFSirX]       ; je poloëka dlouh† ?
         jbe       GetDBFK4                 ; poloëka je OK
         mov       cx,es:[bx+DBFSirX]       ; omezen° dÇlky poloëky

; ------ pozice p©i nastaven° ®°©ky pole - je zaá†tek poloëky

GetDBFK4:test      byte ptr ds:[DBFEPar2],bit0 ; je nastaven° ®°©ky pole ?
         jnz       GetDBFK9                 ; je nastaven° ®°©ky pole

; ------ odsun poloëek o mezeru (kromà textu)

         test      al,bit0                  ; je to text ?
         jnz       GetDBFK5                 ; text se neodsouv†
         mov       ax,es:[bx+DBFSirX]       ; ®°©ka pole
         sub       ax,cx                    ; zbytek na mezeru
         add       dx,ax                    ; odsun o mezeru

; ------ pozice pro logickou a MEMO poloëku

GetDBFK5:test      byte ptr es:[bx+DBFParX],bit4+bit5 ; je logick†/MEMO poloëka?
         jz        GetDBFK6                 ; nen°
         shr       cx,1                     ; polovina ®°©ky poloëky
         add       dx,cx                    ; posun pozice
         jmp       short GetDBFK9

; ------ pozice v datu

GetDBFK6:test      byte ptr es:[bx+DBFParX],bit3 ; je datum ?
         jz        GetDBFK7                 ; nen° datum
         mov       bh,0
         mov       bl,ds:[FormDat]          ; form†t data (0=MDR, 1=DMR, 2=RMD)
         shl       bx,1
         shl       bx,1
         shl       bx,1                     ; form†t data * 8
         add       bx,es:[DBFKurz]          ; pozice kurzoru v poloëce
         add       dl,cs:[bx+EditPPT3]      ; pozice kurzoru v datu
         adc       dh,0
         jmp       short GetDBFK9

; ------ pozice v áasu

GetDBFK7:add       dx,es:[DBFKurz]          ; p©iáten° pozice kurzoru

         test      byte ptr es:[bx+DBFParX],bit6 ; je áas ?
         jz        GetDBFK8                 ; nen° áas
         cmp       byte ptr es:[DBFKurz],1  ; je hodina ?
         jbe       GetDBFK9                 ; je hodina
         inc       dx                       ; p©eskoáen° oddàlovaáe áasu
         cmp       byte ptr es:[DBFKurz],3  ; je minuta ?
         jbe       GetDBFK9                 ; je hodina
         inc       dx                       ; p©eskoáen° oddàlovaáe hodiny
         jmp       short GetDBFK9

; ------ pozice textu a á°sla

GetDBFK8:sub       dx,es:[DBFOffT]          ; odeáten° offsetu poá†tku poloëky

; ------ n†vrat registrñ

GetDBFK9:pop       cx
         pop       bx
         pop       ax
         ret

GetDBFK  ENDP

; *****************************************************************************
;                              DispBMnu
;                  zobrazen° okna editoru datab†ze
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=definice okna
;        DS=datovò segment
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) adresa definice okna
;                   SS:[BP-4] (2) á°slo segmentu okna
;                   SS:[BP-6] (2) adresa segmentu okna
;                   SS:[BP-7] (1) ukazatel ©†dku na displeji
;                   SS:[BP-8] (1) pozice na displeji
;                   SS:[BP-9] (1) á°taá ©†dkñ okna
;                   SS:[BP-10] (1) ®°©ka okna - 2
;                   SS:[BP-14] (4) ukazatel poloëky k zobrazen°
;                   SS:[BP-16] (2) á°taá aktivn° poloëky
;                   SS:[BP-17] (1) barva editovanÇ poloëky
;                   SS:[BP-18] (1) parametry DBFEParm (bit 0: 1=je editace)
;                                                  (bit1: 1=k¢dov†n° pro DEMO)
;                   SS:[BP-20] (2) á°taá aktivn° poloëky v aktivn°m ©†dku
;                   SS:[BP-22] (2) hladina k zobrazen°
;                   SS:[BP-23] (1) oddàlovac° znak data
;                   SS:[BP-24] (1) form†t data (0=MDR, 1=DMR, 2=RMD)
;               -------------- str†nkovò reëim
;                   SS:[BP-26] (2) ukazatel definice poloëek
;                   SS:[BP-28] (2) ukazatel dat v z†znamu
;                   SS:[BP-30] (2) á°taá zbylòch pozic v poloëce
;                   SS:[BP-32] (2) á°taá poloëek v z†znamu k zobrazen°
;                   SS:[BP-34] (2) maxim†ln° dÇlka poloëky na ©†dku
;               --------------
;                   SS:[BP-35] (1) oddàlovac° znak áasu
;                   SS:[BP-36] (1) barva poloëky z†hlav° s nastavovanou ®°©kou
; *****************************************************************************
;˛
DispBMnu PROC      FAR

; ------ korekce kurzoru, zobrazen° r†mu a nadpisu datab†ze

         call      KorBMnu                  ; korekce menu
         call      DispBNad                 ; zobrazen° nadpisu datab†ze
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

; ------ vytvo©en° bufferu

         sub       sp,36
         mov       cl,ds:[si+MnuSir]        ; ®°©ka okna
         mov       ch,0
         shl       cx,1
         sub       sp,cx                    ; m°sto pro buffer

; ------ inicializace lok†ln°ch promànnòch

         mov       ax,ds:[si+DBMnuSeg]      ; datovò segment okna
         mov       ss:[bp-2],si             ; adresa definice okna
         mov       ss:[bp-4],ax             ; á°slo segmentu okna
         call      far ptr GetDat           ; poskytnut° adresy segmentu okna
         mov       ss:[bp-6],es             ; adresa segmentu okna
         mov       dx,word ptr ds:[si+MnuPoz] ; pozice a ©†dek
         add       dh,2
         mov       ss:[bp-8],dx             ; pozice a ©†dek na displeji
         mov       cl,ds:[si+MnuSir]        ; ®°©ka okna
         mov       ch,es:[DBFVysL]          ; vò®ka ©†dkñ okna
         sub       cx,102h
         mov       ss:[bp-10],cx            ; ®°©ka a vò®ka okna
         mov       ax,es:[DBFTopZ]          ; prvn° zobrazenò z†znam
         mov       ss:[bp-14],ax            ; ukazatel poloëky k zobrazen° LOW
         mov       ax,es:[DBFTopZ+2]
         mov       ss:[bp-14+2],ax
         mov       ax,es:[DBFAktZ]          ; aktivn° z†znam
         mov       dx,es:[DBFAktZ+2]
         sub       ax,ss:[bp-14]
         sbb       dx,ss:[bp-12]
         jz        DispBMn1
         xor       ax,ax
DispBMn1:inc       ax                       ; p©ednastaven° + 1
         mov       ss:[bp-16],ax            ; á°taá aktivn° poloëky
         mov       al,ds:[si+MnuLev]        ; hladina
         mov       ah,0
         mov       ss:[bp-22],ax            ; hladina k zobrazen°

         mov       al,ds:[DBFEParm]         ; p©°znak editace
         mov       ah,ds:[ColDBF42]         ; barva editovanÇ poloëky
         and       al,not bit1              ; nen° k¢dov†n° pro DEMO
         mov       ss:[bp-18],ax

         mov       ah,ds:[ZnakDat]          ; oddàlovac° znak data
         mov       al,ds:[FormDat]          ; form†t data
         mov       ss:[bp-24],ax            ; parametry data

         mov       ah,ds:[ZnakTim]          ; oddàlovac° znak áasu
         mov       al,ds:[ColDBF22]         ; poloëka s nastavovanou ®°©kou
         test      byte ptr ds:[DBFEPar2],bit0 ; je nastaven° ®°©ky ?
         jnz       DispBM12                 ; je nastaven° ®°©ky
         mov       al,ds:[ColDBF2]          ; bàën† barva z†hlav° poloëek
DispBM12:mov       ss:[bp-36],ax

         mov       ah,0
         mov       al,ds:[si+MnuSir]        ; ®°©ka okna
         sub       al,15                    ; zbytek na poloëku
         mov       ss:[bp-34],ax            ; maxim†ln° dÇlka poloëky

         test      byte ptr es:[DBFParm],bit0 ; je str†nkovò reëim ?
         jz        DispBM27                 ; je ©†dkovò reëim

         jmp       DispBMn6                 ; je str†nkovò reëim

; ------ vymaz†n° ©†dku z†hlav° (v ©†dkovÇm reëimu)

DispBM27:mov       di,sp                    ; buffer v z†sobn°ku
         push      ss
         pop       es                       ; ES <- segment bufferu
         cld
         mov       ch,0
         mov       cl,ss:[bp-10]            ; ®°©ka okna - 2
         mov       ah,ds:[ColMnu1R]         ; bàën† barva okna
         mov       al,"≥"                   ; "≥"
         stosw                              ; levò okraj
         push      di
         mov       al," "
         mov       ah,ds:[ColDBF2]          ; barva z†hlav° poloëek
         rep       stosw
         mov       ah,ds:[ColMnu1L]         ; bàën† barva okna
         mov       al,"≥"                   ; "≥" pravò okraj
         stosw
         pop       di

; ------ p©°prava registrñ

         mov       ah,ds:[ColDBF2]          ; barva z†hlav° poloëek
         push      ds
         mov       ds,ss:[bp-6]             ; adresa segmentu okna
         mov       dx,ds:[DBFTopP]          ; poá†teán° pozice ©†dku
         neg       dx                       ; ukazatel pozice na ©†dku
         mov       si,ds:[DBFAdrP]          ; tabulka popisovaáñ
         mov       bx,ds:[DBFNumP]          ; poáet popisovaáñ
         mov       ch,0
         cld
         or        bx,bx                    ; je nàjak† poloëka ?
         jz        DispBM3A                 ; nen° ë†dn† poloëka

         mov       ax,ds:[DBFAktP]          ; á°slo aktivn° poloëky
         inc       ax                       ; p©ednastaven° + 1
         mov       ss:[bp-20],ax            ; á°taá aktivn° poloëky

; ------ dek¢dov†n° jmÇna poloëky

DispBM31:push      si

         mov       ah,es:[di+1]             ; bàën† barva z†hlav°
         dec       word ptr ss:[bp-20]      ; á°taá aktivn° poloëky
         jnz       DspBM312                 ; nen° aktivn° poloëka
         mov       ah,ss:[bp-36]            ; barva aktivn° poloëky

DspBM312:mov       cl,ds:[si+DBFNumX]       ; dÇlka jmÇna popisovaáe
         cmp       cl,ds:[si+DBFSirX]       ; je men®° zobrazen† ®°©ka ?
         jbe       DispBM32                 ; dÇlka jmÇna je OK
         mov       cl,ds:[si+DBFSirX]       ; omezen° dÇlky jmÇna
DispBM32:mov       si,ds:[si+DBFNamX]       ; adresa jmÇna popisovaáe
         jcxz      DispBM37                 ; nen° ë†dnò znak

DispBM33:lodsb                              ; naáten° prvn°ho znaku
         call      DispBNC                  ; uloëen° znaku
         cmp       al,"_"                   ; je oddàlovaá jmÇna ?
DispBM34:loope     DispBM33                 ; dal®° znak (pokud je oddàlovaá _)
         jcxz      DispBM37                 ; konec jmÇna

DispBM35:lodsb                              ; znak k zobrazen°
         call      far ptr DownCase         ; konverze na malÇ p°smeno
         call      DispBNC                  ; uloëen° znaku
         cmp       al,"_"                   ; je oddàlovaá jmÇna ?
         je        DispBM34                 ; je oddàlovaá jmÇna
         loop      DispBM35                 ; jinak dal®° znak

DispBM37:pop       si

         mov       cl,ds:[si+DBFSirX]       ; ®°©ka pole
         sub       cl,ds:[si+DBFNumX]       ; poáet zbylòch pozic
         jbe       DispBM39                 ; nezbyla ë†dn† pozice
         mov       al," "                   ; znak mezery
DispBM38:call      DispBNC                  ; uloëen° znaku mezery
         loop      DispBM38                 ; vymaz†n° zbytku poloëky

DispBM39:mov       al,"≥"                   ; oddàlovac° á†ra
         call      DispBNC                  ; oddàlovac° á†ra

         add       si,DBFX                  ; zvò®en° ukazatele indexñ
         dec       bx                       ; á°taá poloëek
         jnz       DispBM31                 ; dal®° poloëka

DispBM3A:pop       ds

; ------ zobrazen° ©†dku z†hlav°

         call      DispBMDs                 ; zobrazen° ©†dku

; ------ p©°prava k¢dov†n° pro DEMO

DispBM5: test      byte ptr ds:[LicDPar0],bit4 ; je DEMO verze ?
         jz        DspBM500                 ; nen° DEMO verze
         or        byte ptr ss:[bp-18],bit1 ; je k¢dov†n° pro DEMO
         cmp       word ptr ss:[bp-14+2],0
         jne       DispBM50                 ; poloëka bude k¢dovan†
         cmp       word ptr ss:[bp-14],30
         jae       DispBM50
DspBM500:and       byte ptr ss:[bp-18],not bit1 ; nebude k¢dov†n°

; ------ p©°prava barvy ©†dku poloëky -> BL, BH

DispBM50:mov       bl,ds:[ColDBF3]          ; bàën† barva
         mov       bh,ds:[ColDBF5]          ; oznaáenò z†znam
         dec       word ptr ss:[bp-16]      ; á°taá kurzoru
         jnz       DispBM51                 ; nen° kurzor
         test      byte ptr ss:[bp-18],bit0 ; je editace ?
         jnz       DispBM51                 ; je editace
         mov       bl,ds:[ColDBF4]          ; bàënò kurzor
         mov       bh,ds:[ColDBF6]          ; oznaáenò kurzor

; ------ p©°prava z†znamu -> ES:SI

DispBM51:mov       si,ss:[bp-2]             ; adresa definice okna
         mov       ax,ss:[bp-14]            ; poloëka k zobrazen° LOW
         mov       dx,ss:[bp-14+2]          ; poloëka k zobrazen° HIGH
         call      far ptr GetDBF           ; poskytnut° poloëky DBF
         mov       si,di                    ; SI <- adresa poloëky

; ------ p©°prava á°taáe aktivn° poloëky na editovanÇm ©†dku

         pushf
         mov       word ptr ss:[bp-20],-1   ; nen° aktivn° poloëka
         cmp       word ptr ss:[bp-16],0    ; je kurzor ?
         jne       DspBM512                 ; nen° kurzor
         test      byte ptr ss:[bp-18],bit0 ; je editace ?
         jz        DspBM512                 ; nen° editace
         mov       ax,es:[DBFAktP]          ; á°slo aktivn° poloëky
         inc       ax                       ; p©ednastaven° + 1
         mov       ss:[bp-20],ax            ; á°taá aktivn° poloëky
         mov       si,es:[DBFAdrE]          ; adresa editaán°ho bufferu
DspBM512:popf

; ------ vymaz†n° ©†dku poloëky (CY=poloëka neplatn†)

         cld
         mov       di,sp                    ; DI <- buffer v z†sobn°ku
         mov       al,"≥"                   ; "≥"
         mov       ah,ds:[ColMnu1R]         ; barva levÇho okraje

         push      ds

         push      es
         push      ss
         pop       es                       ; ES <- segment bufferu v z†sobn°ku
         stosw                              ; uloëen° levÇho okraje
         mov       ah,ds:[ColMnu1L]         ; barva pravÇho okraje
         pop       ds                       ; DS <- segment okna

         pushf

         push      di
         push      ax                       ; AX = znak pravÇho okraje

         mov       ah,bl                    ; AH <- bàën† barva
         mov       al," "                   ; mezera k uloëen°
         jc        DispB520                 ; poloëka neplatn†
         cmp       byte ptr ds:[si]," "     ; oznaáen† poloëka ?
         je        DispB520                 ; poloëka nen° oznaáen†
         mov       ah,bh                    ; zvòraznàn† barva-oznaáen† poloëka
DispB520:mov       cl,ss:[bp-10]            ; ®°©ka ©†dku - 2
         rep       stosw                    ; vymaz†n° ©†dku
         mov       bh,ah                    ; BH <- £schova aktivn° barvy

         pop       ax
         stosw                              ; pravò okraj
         pop       di

         popf
         jnc       DispB524                 ; poloëka OK

; ------ poloëka neplatn† - p©i editaci je jako platn†

DispB522:test      byte ptr ss:[bp-18],bit0 ; je editace ?
         jz        DispB523                 ; nen° editace
         cmp       word ptr ss:[bp-16],0    ; je kurzor ?
         je        DispB524                 ; je kurzor
DispB523:jmp       DispBM5B                 ; jinak konec

; ------ p©°prava k dek¢dov†n° z†znamu

DispB524:inc       si                       ; prvn° poloëka
         mov       ah,bh                    ; barva textu
         mov       dx,ds:[DBFTopP]          ; poá†teán° pozice ©†dku
         mov       bx,ds:[DBFAdrP]          ; adresa indexu popisovaáñ
         mov       cl,ss:[bp-10]            ; ®°©ka ©†dku
         mov       ch,0

; ------ oprava barvy poloëky, je-li editovanò ©†dek

DispB525:push      ax
         cmp       word ptr ss:[bp-16],0    ; je kurzor ?
         jne       DispB528                 ; nen° kurzor
         test      byte ptr ss:[bp-18],bit0 ; je editace ?
         jz        DispB528                 ; nen° editace

         mov       ah,ss:[bp-17]            ; barva editovanÇ poloëky

; ------ dek¢dov†n° poloëky

DispB528:call      DekDBPol                 ; dek¢dov†n° poloëky
         pop       ax
         jcxz      DispBM5B                 ; je konec ©†dku

         push      bx
         mov       bl,1                     ; 1 znak
         mov       al,"≥"                   ; znak oddàlovac° á†ry
         call      DispBCh                  ; uloëen° znaku á†ry
         pop       bx

         push      ax
         mov       ax,ds:[DBFAdrE]          ; edit. buffer = konec poloëek
         sub       ax,DBFX                  ; posledn° index v tabulce
         cmp       bx,ax                    ; jsou jië v®echny poloëky ?
         pop       ax
         jbe       DispB525                 ; je je®tà dal®° poloëka

; ------ zobrazen° ©†dku poloëky

DispBM5B:pop       ds

         call      DispBMDs                 ; zobrazen° ©†dku

; ------ p©°prava pro dal®° ©†dek s poloëkou

         add       word ptr ss:[bp-14],1    ; zvò®en° á°sla poloëky
         adc       word ptr ss:[bp-14+2],0

         dec       byte ptr ss:[bp-9]       ; á°taá ©†dkñ
         jz        DispBM5c                 ; konec
         jmp       DispBM5                  ; dal®° poloëka

DispBM5c:jmp       DispBMn9                 ; konec

; -----------------------------------------------------------------------------
;        zobrazen° str†nkovÇho m¢du
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) adresa definice okna
;                   SS:[BP-4] (2) á°slo segmentu okna
;                   SS:[BP-6] (2) adresa segmentu okna
;                   SS:[BP-7] (1) ukazatel ©†dku na displeji
;                   SS:[BP-8] (1) pozice na displeji
;                   SS:[BP-9] (1) á°taá ©†dkñ okna
;                   SS:[BP-10] (1) ®°©ka okna - 2
;                   SS:[BP-14] (4) ukazatel poloëky k zobrazen°
;                   SS:[BP-16] (2) á°taá aktivn° poloëky
;                   SS:[BP-17] (1) barva editovanÇ poloëky
;                   SS:[BP-18] (1) parametry DBFEParm (bit 0: 1=je editace)
;                                        (bit1: 1=k¢dov†n° pro DEMO)
;                   SS:[BP-20] (2) á°taá aktivn° poloëky v aktivn°m ©†dku
;                   SS:[BP-22] (2) hladina k zobrazen°
;                   SS:[BP-23] (1) oddàlovac° znak data
;                   SS:[BP-24] (1) form†t data (0=MDR, 1=DMR, 2=RMD)
;               -------------- str†nkovò reëim
;                   SS:[BP-26] (2) ukazatel definice poloëek
;                   SS:[BP-28] (2) ukazatel dat v z†znamu
;                   SS:[BP-30] (2) á°taá zbylòch pozic v poloëce
;                   SS:[BP-32] (2) á°taá poloëek v z†znamu k zobrazen°
;                   SS:[BP-34] (2) maxim†ln° dÇlka poloëky na ©†dku
;               --------------
;                   SS:[BP-35] (1) oddàlovac° znak áasu
;                   SS:[BP-36] (1) barva poloëky z†hlav° s nastavovanou ®°©kou
; -----------------------------------------------------------------------------

DispBMn6:inc       byte ptr ss:[bp-9]       ; poáet ©†dkñ k zobrazen°

         test      byte ptr ds:[LicDPar0],bit4 ; je DEMO verze ?
         jz        DspBM600                 ; nen° DEMO verze

         mov       es,ss:[bp-6]             ; adresa segmentu okna
         or        byte ptr ss:[bp-18],bit1 ; je k¢dov†n° pro DEMO
         cmp       word ptr es:[DBFAktZ+2],0
         jne       DspBM601                 ; poloëka bude k¢dovan†
         cmp       word ptr es:[DBFAktZ],30
         jae       DspBM601
DspBM600:and       byte ptr ss:[bp-18],not bit1 ; nebude k¢dov†n°

; ------ p©°prava parametrñ

DspBM601:mov       word ptr ss:[bp-30],0    ; nezbyly ë†dnÇ pozice
         mov       word ptr ss:[bp-32],0    ; nejsou ë†dnÇ poloëky

; ------ p©°prava á°taáe aktivn° poloëky

         mov       es,ss:[bp-6]             ; adresa segmentu okna
         mov       ax,es:[DBFAktP]          ; á°slo aktivn° poloëky
         mov       ss:[bp-20],ax            ; á°taá aktivn° poloëky

; ------ p©°prava z†znamu, pokud je editace

         mov       di,es:[DBFAdrE]          ; adresa editaán°ho bufferu
         test      byte ptr ss:[bp-18],bit0 ; je editace ?
         jnz       DispBM60                 ; je editace
         mov       word ptr ss:[bp-20],-1   ; nen° aktivn° poloëka

; ------ p©°prava z†znamu, nen°-li editace

         call      far ptr GetADBF          ; aktivn° poloëka DBF
         jc        DispBMn7                 ; chyba - nen° ë†dn† poloëka
DispBM60:inc       di                       ; p©eskoáen° znaku oznaáen° poloëky
         mov       ss:[bp-28],di            ; ukazatel dat v z†znamu
         mov       bx,es:[DBFAdrP]          ; adresa popisovaáñ
         mov       ss:[bp-26],bx            ; ukazatel definice poloëek
         mov       ax,es:[DBFNumP]          ; poáet poloëek
         mov       ss:[bp-32],ax            ; á°taá poloëek v z†znamu
         mov       cx,es:[DBFTopL]          ; prvn° zobrazenò ©†dek

; ------ nalezen° poá†teán°ho ©†dku

         jcxz      DispBMn7                 ; je prvn° ©†dek
DispBM61:cmp       word ptr ss:[bp-30],0    ; zbyly pozice ?
         jne       DispBM62                 ; zbyly pozice
         mov       ax,es:[bx+DBFDelX]       ; dÇlka poloëky
         mov       ss:[bp-30],ax            ; zbylÇ pozice

DispBM62:mov       ax,ss:[bp-30]            ; zbylò poáet bajtñ poloëky
         cmp       ax,ss:[bp-34]            ; je del®° neë ©†dek ?
         jbe       DispB622                 ; nen° del®°
         mov       ax,ss:[bp-34]            ; omezen° na dÇlku ©†dku
DispB622:add       di,ax                    ; posun adresy poloëky
         mov       ss:[bp-28],di            ; novò ukazatel dat v z†znamu

         sub       word ptr ss:[bp-30],ax   ; sn°ëen° á°taáe pozice
         jnz       DispBM63                 ; bude je®tà dal®° ©†dek
         add       bx,DBFX                  ; adresa dal®°ho popisovaáe
         mov       ss:[bp-26],bx            ; novò ukazatel definice poloëek
         dec       word ptr ss:[bp-20]      ; sn°ëen° á°taáe aktivn° poloëky
         dec       word ptr ss:[bp-32]      ; sn°ëen° á°taáe poloëek (ZY=konec)

DispBM63:loopnz    DispBM61                 ; dal®° ©†dek

; ------ inicializaán° vymaz†n° ©†dku

DispBMn7:mov       di,sp                    ; buffer v z†sobn°ku
         push      ss
         pop       es                       ; ES <- segment bufferu v z†sobn°ku
         cld
         mov       ch,0
         mov       cl,ss:[bp-10]            ; ®°©ka okna - 2
         mov       ah,ds:[ColMnu1R]         ; bàën† barva okna
         mov       al,"≥"                   ; "≥"
         stosw                              ; levò okraj
         push      di
         mov       al," "                   ; znak mezery k vymaz†n°
         mov       ah,ds:[ColDBF12]         ; barva podkladu
         rep       stosw                    ; vymaz†n° ©†dku
         mov       ah,ds:[ColMnu1L]         ; barva pro pravò okraj
         mov       al,"≥"                   ; "≥" pravò okraj
         stosw
         pop       di

; ------ test, zda m† bòt nadpis poloëky

         add       di,2*12                  ; zaá†tek k dek¢dov†n° textu
         cmp       word ptr ss:[bp-30],0    ; zbyly nàjakÇ pozice ?
         jne       DispBM76                 ; zbyly nàjakÇ pozice
         cmp       word ptr ss:[bp-32],0    ; zbyly nàjakÇ poloëky ?
         je        DispBM76                 ; nezbyly ë†dnÇ poloëky

         mov       ah,ds:[ColDBF15]         ; zvòraznàn† barva
         push      di
         push      ds

         dec       di
         dec       di                       ; oddàlovac° mezera

         mov       ds,ss:[bp-6]             ; adresa segmentu okna
         mov       si,ss:[bp-26]            ; ukazatel indexñ poloëek
         mov       bx,ds:[si+DBFDelX]       ; dÇlka poloëky (bajtñ)
         mov       ss:[bp-30],bx            ; á°taá zbylòch pozic

         mov       cl,ds:[si+DBFNumX]       ; dÇlka jmÇna popisovaáe
         mov       si,ds:[si+DBFNamX]       ; adresa jmÇna popisovaáe
         jcxz      DispBM75                 ; nen° ë†dnò znak

         sub       di,cx
         sub       di,cx                    ; adresa k dek¢dov†n° jmÇna

DispBM71:lodsb                              ; naáten° znaku
         stosw                              ; uloëen° znaku
         cmp       al,"_"                   ; je oddàlovac° mezera ?
DispBM72:loope     DispBM71                 ; dal®° znak
         jcxz      DispBM75                 ; konec

DispBM73:lodsb                              ; znak k zobrazen°
         call      far ptr DownCase         ; konverze na malÇ p°smeno
         stosw                              ; uloëen° znaku
         cmp       al,"_"                   ; byla oddàlovac° mezera ?
         je        DispBM72                 ; byla oddàlovac° mezera
         loop      DispBM73                 ; dal®° znak

DispBM75:pop       ds
         pop       di

; ------ uráen° barvy textu poloëky

DispBM76:mov       ah,ds:[ColDBF13]         ; bàën† poloëka
         cmp       word ptr ss:[bp-20],0    ; je to aktivn° poloëka ?
         jne       DispBM77                 ; nen° to aktivn° poloëka
         mov       ah,ds:[ColDBF14]         ; barva aktivn° poloëky

; ------ dek¢dov†n° textu poloëky

DispBM77:push      ds
         cmp       word ptr ss:[bp-30],0    ; je nàjak† poloëka ?
         je        DispBM78                 ; nen° ë†dn† poloëka
         mov       ds,ss:[bp-6]             ; adresa segmentu okna
         mov       bx,ss:[bp-26]            ; ukazatel definice poloëky
         mov       cx,ss:[bp-34]            ; dÇlka ©†dku
         xor       dx,dx                    ; pozice - je zaá†tek ©†dku
         mov       si,ss:[bp-28]            ; ukazatel dat v z†znamu
         call      DekDBPol                 ; dek¢dov†n° poloëky
         mov       ss:[bp-28],si            ; novò ukazatel dat
DispBM78:pop       ds

; ------ p©°prava pro dal®° ©†dek

         mov       ax,ss:[bp-34]            ; maxim†ln° dÇlka poloëky
         sub       ss:[bp-30],ax            ; sn°ëen° á°taáe zbylòch pozic
         ja        DispBMn8                 ; zbyly nàjakÇ pozice
         mov       word ptr ss:[bp-30],0    ; nezbyla dal®° pozice
         cmp       word ptr ss:[bp-32],0    ; zbyly nàjakÇ poloëky ?
         je        DispBMn8                 ; nezbyly ë†dnÇ poloëky
         add       word ptr ss:[bp-26],DBFX ; novò ukazatele indexñ poloëek
         dec       word ptr ss:[bp-20]      ; sn°ëen° á°taáe aktivn° poloëky
         dec       word ptr ss:[bp-32]      ; sn°ëen° á°taáe poloëek

; ------ zobrazen° ©†dku

DispBMn8:call      DispBMDs                 ; zobrazen° ©†dku

; ------ p©°prava pro dal®° ©†dek

         dec       byte ptr ss:[bp-9]       ; á°taá ©†dkñ
         jz        DispBMn9                 ; konec
         jmp       DispBMn7

; ------ test, zda bude zobrazen° MEMO pole

DispBMn9:mov       es,ss:[bp-6]             ; adresa segmentu okna
         mov       ax,es:[DBFVysQ]          ; vò®ka rychlÇho prohl°ëen°
         or        ax,ax                    ; je rychlÇ prohl°ëen° ?
         jnz       DispBM91                 ; je rychlÇ prohl°ëen°
         jmp       DispBM99                 ; nen° rychlÇ prohl°ëen°
DispBM91:mov       ss:[bp-9],al             ; á°taá ©†dkñ k zobrazen°

; ------ zobrazen° oddàlovac° á†ry

         mov       di,sp                    ; buffer v z†sobn°ku
         push      ss
         pop       es                       ; ES <- segment bufferu v z†sobn°ku
         cld
         mov       ch,0
         mov       cl,ss:[bp-10]            ; ®°©ka okna - 2
         mov       ah,ds:[ColMnu1R]         ; bàën† barva okna
         mov       al,"√"                   ; "√"
         stosw                              ; levò okraj
         mov       al,"ƒ"                   ; znak mezery k vymaz†n°
         mov       ah,ds:[ColMnu1]          ; bàën† barva r†mu
         rep       stosw                    ; vymaz†n° ©†dku
         mov       ah,ds:[ColMnu1L]         ; barva pro pravò okraj
         mov       al,"¥"                   ; "¥" pravò okraj
         stosw
         call      DispBMDs                 ; zobrazen° ©†dku

         mov       ax,ds:[DBZobSeg]         ; segment bufferu
         call      far ptr GetDat           ; adresa bufferu -> ES
         mov       word ptr ss:[bp-28],TextBBeg ; ukazatel dat
         mov       word ptr ss:[bp-30],0    ; á°taá zbylòch dat - nen° nic
         jc        DispBM92                 ; nen° segment MEMO
         mov       ax,es:[TextBNum]         ; poáet bajtñ v bufferu
         mov       ss:[bp-30],ax            ; á°taá zbylòch dat

; ------ vymaz†n° ©†dku pro zobrazen° textu

DispBM92:mov       di,sp                    ; buffer v z†sobn°ku
         push      ss
         pop       es                       ; ES <- segment bufferu v z†sobn°ku
         cld
         mov       ch,0
         mov       cl,ss:[bp-10]            ; ®°©ka okna - 2
         mov       bx,cx                    ; BX <- ®°©ka ©†dku
         mov       ah,ds:[ColMnu1R]         ; bàën† barva okna
         mov       al,"≥"                   ; "≥"
         stosw                              ; levò okraj
         push      di
         mov       al," "                   ; znak mezery k vymaz†n°
         mov       ah,ds:[ColDBF7]          ; bàën† barva textu
         rep       stosw                    ; vymaz†n° ©†dku
         mov       ah,ds:[ColMnu1L]         ; barva pro pravò okraj
         mov       al,"≥"                   ; "≥" pravò okraj
         stosw
         pop       di

; ------ dek¢dov†n° textu ©†dku

         test      byte ptr ds:[DBZobPar],bit4 ; je text MEMO ?
         jnz       DspBM982                 ; nen° text MEMO pole

         push      ds
         mov       ax,ds:[DBZobSeg]         ; segment bufferu
         call      far ptr GetSgAdr         ; adresa bufferu -> DX
         mov       ds,dx                    ; adresa bufferu
         mov       si,ss:[bp-28]            ; SI <- ukazatel dat
         mov       cx,ss:[bp-30]            ; CX <- á°taá zbylòch dat

DispBM94:jcxz      DispBM98                 ; nen° dal®° znak
         lodsb                              ; naáten° znaku
         dec       cx                       ; sn°ëen° á°taáe zbylòch dat
         cmp       al,CR
         je        DispBM94                 ; znak CR se ignoruje
         cmp       al,EOF
         je        DispBM94                 ; znak EOF se ignoruje
         cmp       al,LF
         je        DispBM98                 ; je konec ©†dku
         or        bx,bx                    ; zbyla dal®° pozice ?
         jz        DispBM94                 ; nezbyla dal®° pozice
         stosb                              ; uloëen° znaku
         inc       di                       ; p©eskoáen° barvy
         dec       bx                       ; sn°ëen° á°taáe volnÇho m°sta
         jmp       short DispBM94           ; dal®° znak

DispBM98:mov       ss:[bp-30],cx            ; novò á°taá zbylòch dat
         mov       ss:[bp-28],si            ; novò ukazatel textu
         pop       ds

; ------ zobrazen° ©†dku

DspBM982:call      DispBMDs                 ; zobrazen° ©†dku

; ------ p©°prava pro dal®° ©†dek

         dec       byte ptr ss:[bp-9]       ; á°taá ©†dkñ
         jnz       DispBM92                 ; dal®° ©†dek

; ------ n†vrat registrñ

DispBM99:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispBMnu ENDP

; ------ zobrazen° ©†dku

DispBMDs:mov       si,sp                    ; SI <- buffer v z†sobn°ku
         inc       si
         inc       si                       ; p©eskoáen° n†vratovÇ adresy
         mov       dx,ss:[bp-8]             ; ©†dek a pozice
         mov       cl,ss:[bp-10]            ; ®°©ka ©†dku - 2
         mov       ax,ss:[bp-22]            ; hladina k zobrazen°
         inc       cx
         inc       cx                       ; ®°©ka ©†dku
         call      far ptr DispMStr         ; zobrazen° ©†dku
         inc       byte ptr ss:[bp-7]       ; zvò®en° ukazatele ©†dku
         ret

; -----------------------------------------------------------------------------
;        dek¢dov†n° jednÇ poloëky v z†znamu
; -----------------------------------------------------------------------------
; VSTUP: AH=barva textu
;        DS:BX=ukazatel popisovaáe poloëky
;        CX=á°taá zbylòch pozic do konce ©†dku (mus° bòt kladnÇ á°slo)
;        DX=poáet pozic do zaá†tku ©†dku (kladnÇ á°slo = je p©ed zaá†tkem ©†dku)
;        DS:SI=ukazatel zaá†tku poloëky
;        ES:DI=ukl†dac° adresa
;        CLD
; VùSTUP: DS:BX=ukazatel popisovaáe dal®° poloëky
;         CX=novò á°taá zbylòch pozic do konce ©†dku
;         DX=novò poáet pozic do zaá†tku
;         DS:SI=dal®° poloëka
;         ES:DI=nov† ukl†dac° adresa
; -----------------------------------------------------------------------------
;                   SS:[BP-20] (2) á°taá aktivn° poloëky v aktivn°m ©†dku
;                   SS:[BP-23] (1) oddàlovac° znak data
;                   SS:[BP-24] (1) form†t data (0=MDR, 1=DMR, 2=RMD)
;                   SS:[BP-30] (2) á°taá zbylòch pozic v poloëce
;                   SS:[BP-34] (2) maxim†ln° dÇlka poloëky na ©†dku
;               --------------
;                   SS:[BP-35] (1) oddàlovac° znak áasu
;                   SS:[BP-36] (1) barva poloëky z†hlav° s nastavovanou ®°©kou
; -----------------------------------------------------------------------------

DekDBPol PROC      NEAR

         push      bx
         push      dx
         push      si

; ------ posun poá†tku poloëky pro textovou a á°selnou poloëku

         test      byte ptr ds:[DBFParm],bit0 ; je str†nkovò reëim ?
         jnz       DekDBPl0                 ; je str†nkovò reëim
         dec       word ptr ss:[bp-20]      ; á°taá aktivn° poloëky
         jnz       DekDBPl0                 ; nen° aktivn° poloëka
         test      byte ptr ds:[bx+DBFParX],bit0+bit1+bit2+bit7 ; je text/á°slo ?
         jz        DekDBPl0                 ; nen° text/á°slo
         add       si,ds:[DBFOffT]          ; poá†tek poloëky

; ------ test, zda je poloëka cel† p©ed zaá†tkem ©†dku

DekDBPl0:cmp       dx,ds:[bx+DBFSirX]       ; je poloëka p©ed zaá†tkem ©†dku ?
         jl        DekDBPl1                 ; poloëka je zá†sti zobrazen†
         jmp       DekDBPl9                 ; poloëka je p©ed zaá†tkem ©†dku

; ------ p©°prava k dek¢dov†n° poloëky

DekDBPl1:push      dx
         mov       dh,ds:[bx+DBFSirX]       ; DH (BH) <- ®°©ka poloëky (pozic)
         mov       dl,ds:[bx+DBFDelX]       ; DL (BL) <- dÇlka poloëky (bajtñ)
         mov       al,ds:[bx+DBFParX]       ; AL <- parametry poloëky
         mov       bx,dx                    ; BX <- ®°©ka a dÇlka poloëky
         pop       dx

; ------ oprava dÇlky poloëky -> BL

         test      al,bit3                  ; datum ?
         jz        DkDBP112                 ; nen° datum
         mov       bl,10                    ; dÇlka poloëky "datum"

DkDBP112:test      al,bit4                  ; logick† poloëka ?
         jz        DkDBP113                 ; nen° logick† poloëka
         mov       bl,3                     ; dÇlka logickÇ poloëky

DkDBP113:test      al,bit5                  ; je to MEMO pole ?
         jz        DkDBP114                 ; nen° to MEMO pole
         mov       bl,6                     ; dÇlka pro MEMO pole

DkDBP114:test      al,bit6                  ; je to áas ?
         jz        DekDBP12                 ; nen° to áas
         mov       bl,8                     ; dÇlka pro áas

; ------ omezen° dÇlky poloëky -> BL, zbylÇ mezery -> BH

DekDBP12:test      byte ptr ds:[DBFParm],bit0 ; je str†nkovò reëim ?
         jz        DekDBP16                 ; nen° str†nkovò reëim

         mov       bh,0                     ; nezbòv† ë†dn† mezera
         test      al,bit3+bit4+bit5+bit6   ; implicitn° dÇlka ?
         jnz       DekDBP14                 ; je implicitn° dÇlka
         mov       bl,ss:[bp-30]            ; poáet zbylòch pozic v poloëce
DekDBP14:cmp       bl,ss:[bp-34]            ; p©esahuje dÇlku ©†dku ?
         jbe       DekDBPl2                 ; dÇlka je OK
         mov       bl,ss:[bp-34]            ; omezen° dÇlky ©†dku
         jmp       short DekDBPl2

DekDBP16:cmp       bl,bh                    ; p©esahuje dÇlka ®°©ku poloëky ?
         jb        DekDBP18                 ; dÇlka je OK
         mov       bl,bh                    ; omezen° dÇlky poloëky
DekDBP18:sub       bh,bl                    ; BH <- zbytek na mezery

; ------ £vodn° mezera (p©ed poloëkou) - kromà textu

DekDBPl2:test      al,bit1+bit2+bit3+bit4+bit5+bit6 ; m† bòt mezera ?
         jz        DekDBP22                 ; nem† bòt mezera
         call      DispBSpc                 ; dek¢dov†n° mezer

; ------ datum

DekDBP22:test      al,bit3                  ; je to datum ?
         jz        DekDBPl6                 ; nen° datum

         cmp       byte ptr ss:[bp-24],1    ; evropskò form†t data 1 ?
         jne       DekDBPl3                 ; nen° evropskò form†t

         add       si,6                     ; 2 znaky dne
         call      DispBTx0                 ; dek¢dov†n° dne
         call      DispBChD                 ; uloëen° oddàlovaáe data
         sub       si,4                     ; màs°c
         call      DispBTx0                 ; dek¢dov†n° màs°ce
         call      DispBChD                 ; uloëen° oddàlovaáe data
         sub       si,6                     ; rok
         jmp       short DekDBPl5           ; dek¢dov†n° roku

DekDBPl3:jb        DekDBPl4                 ; je americkò form†t
                                           ;* je japonskò form†t
         mov       al,4                     ; 4 znaky roku
         call      DispBTxt                 ; dek¢dov†n° roku
         call      DispBChD                 ; oddàlovac° znak data
         call      DispBTx0                 ; dek¢dov†n° màs°ce
         call      DispBChD                 ; oddàlovac° znak data
         call      DispBTx0                 ; dek¢dov†n° dne
         jmp       short DekDBP52

DekDBPl4:add       si,4                     ; 2 znaky màs°ce
         call      DispBTx0                 ; dek¢dov†n° màs°ce
         call      DispBChD                 ; uloëen° oddàlovaáe data
         call      DispBTx0                 ; dek¢dov†n° dne
         call      DispBChD                 ; uloëen° oddàlovaáe data
         sub       si,8                     ; adresa roku
DekDBPl5:mov       al,4                     ; 4 znaky roku
         call      DispBTxt                 ; dek¢dov†n° roku
DekDBP52:jmp       DekDBPl9

; ------ dek¢dov†n° MEMO poloëky

DekDBPl6:test      al,bit5                  ; je MEMO poloëka ?
         jz        DekDBP61                 ; nen° MEMO poloëka

         cmp       byte ptr ds:[si+9]," "   ; je MEMO pole platnÇ ?
         mov       si,offset DekDBMT2       ; text pro "nen° MEMO"
         je        DekDBP64                 ; nen° MEMO pole
         mov       si,offset DekDBMmT       ; text pro "je MEMO"
         jmp       short DekDBP64           ; dek¢dov†n° textu

; ------ dek¢dov†n° logickÇ poloëky

DekDBP61:test      al,bit4                  ; je to logick† poloëka ?
         jz        DekDBPl7                 ; nen° to logick† poloëka

         lodsb                              ; znak k zobrazen°
         call      far ptr UpCase           ; konverze na velkÇ p°smeno

         mov       si,offset DekDBLT1       ; text pro nedefinovanou poloëku
         cmp       al,"?"
         je        DekDBP64                 ; nedefinovan† hodnota
         cmp       al," "
         je        DekDBP64                 ; nedefinovan† hodnota

         mov       si,offset DekDBLT2       ; text pro NE
         cmp       bl,1                     ; je kr†tkò text ?
         ja        DekDBP62                 ; je dlouhò text
         mov       si,offset DekDBLT4       ; text pro NE pro kr†tkò text

DekDBP62:cmp       al,"N"
         je        DekDBP64                 ; je NE
         cmp       al,"F"
         je        DekDBP64                 ; je NE

         mov       si,offset DekDBLT3       ; jina ANO
DekDBP64:call      DekDBTxC                 ; dek¢dov†n° textu CS:SI
         jmp       short DekDBPl9

; ------ dek¢dov†n° áasu

DekDBPl7:test      al,bit6                  ; je áas ?
         jz        DekDBPl8                 ; nen° áas

         call      DispBTx0                 ; dek¢dov†n° hodiny
         call      DispBChT                 ; uloëen° oddàlovaáe áasu
         call      DispBTx0                 ; dek¢dov†n° minuty
         call      DispBChT                 ; uloëen° oddàlovaáe áasu
         call      DispBTx0                 ; dek¢dov†n° sekundy
         jmp       short DekDBPl9

; ------ dek¢dov†n° á°selnÇ a textovÇ poloëky

DekDBPl8:test      al,bit1+bit2             ; je to á°slo ?
         mov       al,bl                    ; AL <- poáet znakñ poloëky
         jz        DekDBP86                 ; nen° to á°slo
         call      DispBTxN                 ; dek¢dov†n° á°sla
         jmp       short DekDBP88

DekDBP86:call      DispBTxt                 ; dek¢dov†n° textu
DekDBP88:call      DispBSpc                 ; dek¢dov†n° zbytku mezer

; ------ adresa dal®° poloëky v z†znamu

DekDBPl9:pop       si
         pop       dx
         pop       bx

         test      byte ptr ds:[DBFParm],bit0 ; je str†nkovÇ zobrazen° ?
         jz        DekDBP96                 ; nen° str†nkovÇ zobrazen°

         push      cx
         mov       cx,ss:[bp-30]            ; poáet zbylòch pozic v poloëce
         cmp       cl,ss:[bp-34]            ; p©esahuje dÇlku ©†dku ?
         jbe       DekDBP94                 ; dÇlka je OK
         mov       cl,ss:[bp-34]            ; omezen° dÇlky ©†dku
DekDBP94:add       si,cx                    ; zvò®en° adresy poloëky
         pop       cx
         jmp       short DekDBP98

DekDBP96:add       si,ds:[bx+DBFDelX]       ; adresa dal®° poloëky
         sub       dx,ds:[bx+DBFSirX]       ; sn°ëen° poá†teán° pozice
DekDBP98:add       bx,DBFX                  ; dal®° popisovaá
         ret

DekDBPol ENDP

DekDBMmT db        '<TEXT>'                 ; "je MEMO"
DekDBMT2 db        '-text-'                 ; "nen° MEMO"

DekDBLT1 db        '   '                    ; logick† poloëka nedefinovan†
DekDBLT2 db        ' ne'                    ; logick† poloëka NE
DekDBLT3 db        'ANO'                    ; logick† poloëka YES
DekDBLT4 db        '-'                      ; logick† poloëka NE pro 1 znak

; -----------------------------------------------------------------------------
;        uloëen° textu CS:SI (BL znakñ)
; -----------------------------------------------------------------------------

DekDBTxC PROC      NEAR

DekDBTC2:mov       al,cs:[si]
         inc       si
         call      DispBCh
         or        bl,bl                    ; je jië celò text ?
         jnz       DekDBTC2                 ; dal®° znak
         ret

DekDBTxC ENDP

; -----------------------------------------------------------------------------
;        uloëen° textu do bufferu
; -----------------------------------------------------------------------------
; VSTUP: AH=barva textu
;        AL=dÇlka textu (mñëe bòt = 0)
;        BL=poáet zbòvaj°c°ch znakñ do konce poloëky
;        CX=á°taá zbylòch pozic do konce ©†dku (mus° bòt kladnÇ á°slo)
;        DX=poáet pozic do zaá†tku ©†dku (kladnÇ á°slo = je p©ed zaá†tkem ©†dku)
;        DS:SI=text k uloëen°
;        ES:DI=ukl†dac° adresa
;        CLD
; VùSTUP: BL=novò poáet zbòvaj°c°ch znakñ do konce poloëky
;         CX=novò á°taá zbylòch pozic do konce ©†dku
;         DX=novò poáet pozic do zaá†tku
;         DS:SI=nov† adresa textu
;         ES:DI=nov† ukl†dac° adresa
; zniáenÇ registry: AL
; -----------------------------------------------------------------------------

DispBTx0:mov       al,2                     ; 2 znaky

DispBTxt PROC      NEAR

         cmp       al,0                     ; je nàjakò text ?
         je        DispBTx2                 ; nen° text

DispBTx1:push      ax
         lodsb                              ; znak textu k uloëen°
         call      DispBCh                  ; uloëen° znaku AX
         pop       ax
         dec       al
         jnz       DispBTx1
DispBTx2:ret

DispBTxt ENDP

; ------ dek¢dov†n° textu á°sla

DispBTxN PROC      NEAR

         cmp       al,0                     ; je nàjakò text ?
         je        DispBTN4                 ; nen° text

DispBTN1:push      ax
         lodsb                              ; znak textu k uloëen°
         cmp       al,"."
         jne       DispBTN2
         mov       al,cs:[DBFOdDes]         ; oddàlovaá desetin
DispBTN2:call      DispBCh                  ; uloëen° znaku AX
         pop       ax
         dec       al
         jnz       DispBTN1
DispBTN4:ret

DispBTxN ENDP

; -----------------------------------------------------------------------------
;        uloëen° mezer do bufferu (p©eskoáen°m £seku ©†dku)
; -----------------------------------------------------------------------------
; VSTUP: BH=poáet mezer k uloëen° (mñëe bòt = 0)
;        CX=á°taá zbylòch pozic do konce ©†dku (mus° bòt kladnÇ á°slo)
;        DX=poáet pozic do zaá†tku ©†dku (kladnÇ á°slo = je p©ed zaá†tkem ©†dku)
;        ES:DI=ukl†dac° adresa
;        CLD
; VùSTUP: CX=novò á°taá zbylòch pozic do konce ©†dku
;         DX=novò poáet pozic do zaá†tku
;         ES:DI=nov† ukl†dac° adresa
; zniáenÇ registry: BH
; -----------------------------------------------------------------------------

DispBSpc PROC      NEAR

         or        bh,bh                    ; jsou nàjakÇ mezery k uloëen° ?
         jz        DispBSp3                 ; nejsou ë†dnÇ mezery
DispBSp1:dec       dx                       ; sn°ëen° á°taáe zbylòch pozic
         jns       DispBSp2                 ; je p©ed zaá†tkem okna
         jcxz      DispBSp2                 ; je za koncem ©†dku
         inc       di
         inc       di                       ; p©eskoáen° znaku mezery
         dec       cx                       ; sn°ëen° á°taáe zbylòch pozic
DispBSp2:dec       bh                       ; á°taá mezer k uloëen°
         jnz       DispBSp1                 ; je dal®° mezera
DispBSp3:ret

DispBSpc ENDP

; -----------------------------------------------------------------------------
;        uloëen° jednoho znaku do bufferu
; -----------------------------------------------------------------------------
; VSTUP: AX=znak k uloëen°
;        BL=poáet zbòvaj°c°ch pozic do konce pole poloëky
;        CX=á°taá zbylòch pozic do konce ©†dku (mus° bòt kladnÇ á°slo)
;        DX=poáet pozic do zaá†tku ©†dku (kladnÇ á°slo = je p©ed zaá†tkem ©†dku)
;        ES:DI=ukl†dac° adresa
;        CLD
; VùSTUP: BL=novò poáet zbòvaj°c°ch pozic do konce pole poloëky
;         CX=novò á°taá zbylòch pozic do konce ©†dku
;         DX=novò poáet pozic do zaá†tku
;         ES:DI=nov† ukl†dac° adresa
; -----------------------------------------------------------------------------

DispBChT:mov       al,ss:[bp-35]            ; oddàlovac° znak áasu
         jmp       short DispBCh

DispBChD:mov       al,ss:[bp-23]            ; oddàlovac° znak data

DispBCh  PROC      NEAR

         or        bl,bl                    ; zbòv† dal®° znak ?
         jz        DispBCh2                 ; nezbòv† dal®° znak
         dec       bl                       ; sn°ëen° á°taáe zbylòch znakñ
         dec       dx                       ; sn°ëen° á°taáe zbylòch pozic
         jns       DispBCh2                 ; je p©ed zaá†tkem okna
         jcxz      DispBCh2                 ; je za koncem ©†dku

         test      byte ptr ss:[bp-18],bit1 ; je k¢dov†n° DEMO ?
         jz        DispBCh1                 ; nen° k¢dov†n° DEMO
         cmp       al," "
         je        DispBCh1
         cmp       al,"≥"
         je        DispBCh1
         cmp       al,ss:[bp-35]            ; je oddàlovaá áasu ?
         je        DispBCh1
         cmp       al,ss:[bp-23]            ; je oddàlovac° znak data ?
         je        DispBCh1
         cmp       al,cs:[DBFOdDes]         ; je oddàlovaá desetin ?
         je        DispBCh1

         push      ax
         mov       al,"*"
         stosw
         pop       ax
         dec       cx
         ret

DispBCh1:stosw                              ; uloëen° znaku do bufferu
         dec       cx                       ; sn°ëen° á°taáe zbylòch pozic
DispBCh2:ret

DispBCh  ENDP

; -----------------------------------------------------------------------------
;        dek¢dov†n° znaku z†hlav°
; -----------------------------------------------------------------------------
; VSTUP: AX=znak k uloëen°
;        ES:DI=ukl†dac° adresa
;        DX=ukazatel pozice na ©†dku
;        SS:[BP-10] (1) poáet pozic na ©†dek (®°©ka okna - 2)
;        CLD
; -----------------------------------------------------------------------------

DispBNC  PROC      NEAR

         or        dh,dh
         jnz       DispBNC2                 ; je pozice za ©†dkem
         cmp       dl,ss:[bp-10]            ; p©ekroáen konec ©†dku ?
         jae       DispBNC2                 ; je pozice za ©†dkem
         stosw                              ; uloëen° znaku
DispBNC2:inc       dx                       ; zvò®en° ukazatele pozice
         ret

DispBNC  ENDP

; -----------------------------------------------------------------------------
;        Zobrazen° ©†dku nadpisu datab†ze DS:SI
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) ©†dek a pozice na displeji
;                   SS:[BP-4] (2) adresa definice menu
;                   SS:[BP-6] (2) á°slo segmentu okna
;                   SS:[BP-7] (1) hladina k zobrazen° ©†dku
;                   SS:[BP-8] (1) ®°©ka ©†dku
;                   SS:[BP-10] (2) adresa okna
; -----------------------------------------------------------------------------

DispBNad PROC      NEAR

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

         sub       sp,10                    ; lok†ln° promànnÇ
         mov       ax,word ptr ds:[si+MnuPoz] ; ©†dek a pozice poá†tku okna
         add       ah,1                     ; ©†dek a pozice k zobrazen°
         mov       ss:[bp-2],ax             ; ©†dek a pozice na displeji
         mov       ss:[bp-4],si             ; adresa definice menu
         mov       ax,ds:[si+DBMnuSeg]      ; segment okna
         mov       ss:[bp-6],ax             ; segment okna
         call      far ptr GetSgAdr         ; adresa okna
         mov       ss:[bp-10],dx            ; adresa okna
         mov       al,ds:[si+MnuSir]        ; ®°©ka okna
         mov       ah,0
         sub       sp,ax
         sub       sp,ax                    ; buffer pro ©†dek
         mov       ah,ds:[si+MnuLev]        ; hladina k zobrazen°
         mov       ss:[bp-8],ax             ; ®°©ka ©†dku a hladina

; ------ vymaz†n° ©†dku

         cld
         push      ss
         pop       es                       ; ES <- segment z†sobn°ku
         mov       di,sp                    ; buffer v z†sobn°ku
         mov       al,"≥"                   ; "≥"
         mov       ah,ds:[ColMnu1R]         ; bàën† barva menu
         stosw                              ; levò okraj

         mov       al," "
         mov       ah,ds:[ColDBF1]          ; barva stavovÇho ©†dku
         mov       cl,ss:[bp-8]             ; ®°©ka ©†dku
         mov       ch,0
         dec       cx
         dec       cx                       ; bez okrajñ
         rep       stosw                    ; vymaz†n° ©†dku

         mov       al,"≥"                   ; "≥"
         mov       ah,ds:[ColMnu1L]         ; bàën† barva menu
         stosw                              ; pravò okraj

; ------ dek¢dov†n° jmÇna souboru (CH=0)

         mov       ah,ds:[ColDBF1]          ; bàën† barva ©†dku
         mov       di,sp
         add       di,2*2                   ; zaá†tek k uloëen° jmÇna souboru
         mov       cl,8                     ; dÇlka jmÇna souboru
         push      ds

         test      byte ptr ds:[DBFEParm],bit1 ; je buffer modifikov†n ?
         jz        DispBNd0                 ; buffer nen° modifikov†n
         mov       byte ptr es:[di-2],"!"   ; p©°znak modifikace bufferu

DispBNd0:mov       ds,ss:[bp-10]            ; segment okna
         test      byte ptr ds:[DBFParm],bit1 ; je z†kaz z†pisu ?
         jz        DispBNd1                 ; nen° z†kaz z†pisu
         mov       byte ptr es:[di-2],"*"   ; oznaáen° z†kazu z†pisu

DispBNd1:mov       si,DBFName               ; jmÇno souboru
DispBNd2:lodsb
         stosw
         loop      DispBNd2

         mov       bh,ah                    ; bàën† barva
         mov       ax,ds:[DBFAktZ]          ; aktivn° z†znam LOW
         mov       dx,ds:[DBFAktZ+2]        ; aktivn° z†znam HIGH
         pop       ds

; ------ dek¢dov†n° á°sla poloëky (CH=0)

         add       ax,1                     ; korekce á°sla aktivn° poloëky
         adc       dx,0
         mov       bl,ds:[OddelRad]         ; oddàlovaá ©†dñ
         mov       cl,ss:[bp-8]             ; ®°©ka ©†dku
         mov       di,sp
         add       di,cx
         add       di,cx                    ; konec ©†dku
         sub       di,4                     ; konec k uloëen° á°sla
         call      far ptr Dek10Num         ; dek¢dov†n° á°sla poloëky

; ------ dek¢dov†n° nadpisu (CH=0)

         mov       di,sp                    ; buffer v z†sobn°ku
         mov       ah,ds:[ColDBF11]         ; barva nadpisu
         push      ds
         mov       ds,ss:[bp-10]            ; segment okna
         mov       si,DBFKom                ; koment†©
         mov       cl,ds:[DBFNKom]          ; dÇlka koment†©e
         mov       bl,ss:[bp-8]             ; ®°©ka ©†dku
         cmp       cl,bl
         jb        DspBNd24
         mov       cl,bl
DspBNd24:mov       bh,0
         sub       bx,cx                    ; zbytek na okraje
         and       bl,not bit0              ; zarovn†n°
         add       di,bx                    ; adresa k uloëen° textu
         jcxz      DispBNd4
DispBNd3:lodsb
         stosw
         loop      DispBNd3
DispBNd4:pop       ds

; ------ p©°znak oznaáen° souboru

         mov       cl,ss:[bp-8]             ; ®°©ka ©†dku
         mov       di,sp
         add       di,cx
         add       di,cx                    ; konec ©†dku
         push      es
         push      di
         mov       si,ss:[bp-4]             ; adresa definice menu
         call      far ptr GetADBF          ; poskytnut° aktivn° poloëky
         mov       al,es:[di]               ; p©°znak poloëky
         pop       di
         pop       es
         jc        DispBNd5
         mov       es:[di-4],al             ; p©°znak zru®en° poloëky

; ------ zobrazen° ©†dku nadpisu

DispBNd5:mov       si,sp
         mov       dx,ss:[bp-2]             ; ©†dek a pozice na displeji
         mov       cl,ss:[bp-8]             ; ®°©ka ©†dku
         mov       al,ss:[bp-7]             ; hladina k zobrazen°
         mov       ah,0
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

DispBNad ENDP

; -----------------------------------------------------------------------------
;        korekce menu DS:SI
; -----------------------------------------------------------------------------

KorBMnu  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ adresa okna -> ES

         call      DBFAdrES                 ; aktualizace adresy okna -> ES

; ------ p©°prava vò®ky okna

         mov       ah,0
         mov       al,ds:[si+MnuVys]        ; vò®ka okna
         sub       al,3                     ; bez okrajñ
         mov       es:[DBFVysL],al          ; vò®ka datovòch ©†dkñ
         mov       es:[DBFVysQ],ah          ; vò®ka prohl°ëeáe = 0
         test      byte ptr ds:[DBZobPar],bit0+bit1+bit2 ; povolena funkce ?
         jnz       KorBMn0H                 ; funkce nen° povolena
;         test      byte ptr ds:[DBZobPar],bit4 ; je text naáten ?
;         jnz       KorBMn0H                 ; text nen° naáten
         mov       cl,3
         div       cl                       ; vò®ka okna / 3
         mov       es:[DBFVysQ],al          ; vò®ka prohl°ëeáe
         inc       ax                       ; váetnà oddàlovac° á†ry
         sub       es:[DBFVysL],al          ; 2/3 vò®ky okna

; ------ korekce ©†dkñ ve str†nkovÇm reëimu

KorBMn0H:test      byte ptr es:[DBFParm],bit0 ; je str†nkovò reëim ?
         jz        KorBMn0B                 ; nen° str†nkovò reëim

; ------ omezen° poá†teán°ho ©†dku ve str†nkovÇm reëimu

         test      byte ptr ds:[DBFEParm],bit0 ; je editace ?
         jz        KorBMn0F                 ; nen° editace

         call      GetDBRK                  ; poskytnut° ©†dku s kurzorem -> DX
         mov       ax,es:[DBFTopL]          ; poá†teán° ©†dek
         cmp       ax,dx                    ; je podteáen° poá†tku ?
         jb        KorBMn0C                 ; nen° podteáen° poá†tku
         mov       ax,dx                    ; ©†dek s kurzorem
         or        ax,ax                    ; je ©†dek 0 ?
         jz        KorBMn0D                 ; je ©†dek 0
         dec       ax                       ; novò poá†teán° ©†dek
KorBMn0D:mov       es:[DBFTopL],ax          ; novò poá†teán° ©†dek

; ------ omezen° koncovÇho ©†dku ve str†nkovÇm reëimu

KorBMn0C:mov       cx,es:[DBFVysL]          ; vò®ka okna ©†dkñ
         dec       cx
         dec       cx
;         mov       cl,ds:[si+MnuVys]        ; vò®ka okna
;         mov       ch,0
;         sub       cl,5                     ; poáet vnit©n°ch ©†dkñ - 2
         sub       dx,cx                    ; minim†ln° poá†teán° ©†dek
         jnc       KorBMn0E
         xor       dx,dx                    ; omezen° p©i podteáen°
KorBMn0E:cmp       dx,es:[DBFTopL]          ; poá†teán° ©†dek je OK ?
         jbe       KorBMn0F                 ; poá†teán° ©†dek je OK
         mov       es:[DBFTopL],dx          ; omezen° poá†teán°ho ©†dku

; ------ omezen° na maxim†ln° poá†teán° ©†dek

KorBMn0F:mov       ax,es:[DBFNumL]          ; poáet ©†dkñ ve str†nkovÇm reëimu
;         mov       cl,ds:[si+MnuVys]        ; vò®ka okna
;         mov       ch,0
;         sub       cl,3                     ; poáet vnit©n°ch ©†dkñ
         mov       cx,es:[DBFVysL]          ; vnit©n° vò®ka okna
         sub       ax,cx                    ; maxim†ln° poá†teán° ©†dek
         jnc       KorBMn0A                 ; OK
         xor       ax,ax                    ; m†lo ©†dku - omezen° na 0
KorBMn0A:cmp       ax,es:[DBFTopL]          ; p©ekroáen poá†teán° ©†dek ?
         jae       KorBMn0B                 ; poá†teán° ©†dek nep©ekroáen
         mov       es:[DBFTopL],ax          ; omezen° poá†teán°ho ©†dku

; ------ p©°prava n†povàdy

KorBMn0B:mov       word ptr ds:[si+MnuHlp],offset DBFMnHlP ; je nastaven° ®°©ky
         test      byte ptr ds:[DBFEPar2],bit0 ; nastaven° ®°©ky ?
         jnz       KorBMn0X                 ; je nastaven° ®°©ky
         mov       word ptr ds:[si+MnuHlp],offset DBFMnHl1 ; ©†dkovò reëim
         test      byte ptr es:[DBFParm],bit0 ; je str†nkovò reëim ?
         jz        KorBMn01                 ; nen° str†nkovò reëim
         mov       word ptr ds:[si+MnuHlp],offset DBFMnHl2 ; str†nkovò reëim
KorBMn01:test      byte ptr ds:[DBFEParm],bit0 ; je editace ?
         jnz       KorBMn00                 ; je editace
         jmp       KorBMn08                 ; nen° editace

; ------ p©°prava n†povàdy v reëimu editace

KorBMn00:mov       bx,es:[DBFAktP]          ; aktivn° poloëka
         shl       bx,1
         shl       bx,1
         shl       bx,1                     ; offset v tabulce indexñ popisovaáñ
         add       bx,es:[DBFAdrP]          ; adresa popisovaáe poloëky
         mov       al,es:[bx+DBFParX]       ; parametry poloëky

         mov       bx,offset DBFMnHl3       ; znakovÇ pole
         test      al,bit0+bit7             ; je znakovÇ pole ?
         jnz       KorBMn02                 ; je znakovÇ pole

         mov       bx,offset DBFMnHl4       ; á°slo
         test      al,bit1+bit2             ; je á°slo ?
         jnz       KorBMn02                 ; je á°slo

         mov       bx,offset DBFMnHl8       ; logickÇ pole
         test      al,bit4                  ; je logickÇ pole ?
         jnz       KorBMn02                 ; logickÇ pole

         mov       bx,offset DBFMnHl9       ; textovÇ pole
         test      al,bit5                  ; je textovÇ pole ?
         jnz       KorBMn02                 ; textovÇ pole

         mov       bx,offset DBFMnHlA       ; áas
         test      al,bit6                  ; je áas ?
         jnz       KorBMn02                 ; áas

         mov       bx,offset DBFMnHl5       ; datum DMR
         cmp       byte ptr ds:[FormDat],1  ; evropskò form†t data ?
         je        KorBMn02                 ; form†t data DMR
         mov       bx,offset DBFMnHl6       ; datum MDR
         jb        KorBMn02                 ; form†t data MDR
         mov       bx,offset DBFMnHl7       ; datum RMD
KorBMn02:mov       ds:[si+MnuHlp],bx        ; adresa n†povàdy

; ------ korekce pozice kurzoru na ©†dku (je-li editace v ©†dkovÇm reëimu)

KorBMn0X:test      byte ptr es:[DBFParm],bit0 ; je str†nkovò reëim ?
         jnz       KorBMn08                 ; je str†nkovò reëim

         call      GetDBFK                  ; stanoven° pozice kurzoru na ©†dku
         xchg      ax,dx                    ; AX <- pozice kurzoru na ©†dku
         sub       ax,10                    ; rezerva vlevo
         jnc       KorBMn03
         xor       ax,ax                    ; omezen° p©i podteáen°
KorBMn03:cmp       ax,es:[DBFTopP]          ; podteáen° poá†tku ?
         jae       KorBMn04                 ; nen° podteáen° poá†tku
         mov       es:[DBFTopP],ax          ; omezen° poá†tku
KorBMn04:add       ax,20+2                  ; rezerva vpravo + korekce
         mov       dl,ds:[si+MnuSir]        ; ®°©ka okna
         mov       dh,0
         sub       ax,dx                    ; minim†ln° poá†tek
         jbe       KorBMn08
         cmp       ax,es:[DBFTopP]          ; p©eteáen° konce ?
         jbe       KorBMn08                 ; nen° p©eteáen° konce
         mov       es:[DBFTopP],ax          ; omezen° poá†tku

; ------ omezen° maxim†ln°ho poá†tku ©†dku okna

KorBMn08:mov       ax,es:[DBFSirR]          ; ®°©ka ©†dku
         mov       bl,ds:[si+MnuSir]        ; ®°©ka okna
         sub       bl,2                     ; vnit©n° ®°©ka okna
         mov       bh,0
         sub       ax,bx                    ; maxim†ln° poá†tek
         jnc       KorBMn09
         xor       ax,ax                    ; omezen° poá†tku na 0
KorBMn09:cmp       ax,es:[DBFTopP]          ; p©ekroáen maxim†ln° poá†tek ?
         jae       KorBMnu0                 ; je to OK
         mov       es:[DBFTopP],ax          ; omezen° poá†tku

; ------ p©°prava maxim†ln°ho z†znamu (p©i editaci mñëe bòt 1 nav°c)

KorBMnu0:mov       di,es:[DBFMaxZ]          ; poáet z†znamñ LOW
         mov       bx,es:[DBFMaxZ+2]        ; poáet z†znamñ HIGH
         test      byte ptr ds:[DBFEParm],bit0 ; je editace ?
         jz        KorBMn12                 ; nen° editace
         cmp       bx,es:[DBFAktZ+2]        ; je kurzor na konci ?
         jne       KorBMn11
         cmp       di,es:[DBFAktZ]
KorBMn11:jbe       KorBMnu1                 ; kurzor je na konci
KorBMn12:sub       di,1                     ; á°slo posledn°ho z†znamu
         sbb       bx,0
         jnc       KorBMnu1
         xor       di,di                    ; omezen° p©i p©eteáen°
         xor       bx,bx

; ------ omezen° ©†dku kurzoru na posledn° z†znam

KorBMnu1:mov       dx,es:[DBFAktZ+2]        ; aktivn° z†znam HIGH
         mov       ax,es:[DBFAktZ]          ; aktivn° z†znam LOW
         cmp       dx,bx
         jne       KorBMnu2
         cmp       ax,di
KorBMnu2:jbe       KorBMnu3                 ; kurzor je OK
         mov       ax,di
         mov       dx,bx                    ; omezen° kurzoru
         mov       es:[DBFAktZ],ax
         mov       es:[DBFAktZ+2],dx        ; omezenò maxim†ln° z†znam

; ------ omezen° p©i podteáen° kurzoru pod poá†tek okna

KorBMnu3:cmp       dx,es:[DBFTopZ+2]        ; je podteáen prvn° ©†dek ?
         jne       KorBMnu4
         cmp       ax,es:[DBFTopZ]
KorBMnu4:ja        KorBMnu5                 ; nen° podteáen° pod poá†tek
         mov       es:[DBFTopZ],ax          ; omezen° poá†tku okna
         mov       es:[DBFTopZ+2],dx
         mov       cx,ax
         or        cx,dx                    ; je prvn° z†znam ?
         jz        KorBMnu5                 ; je prvn° z†znam
         sub       word ptr es:[DBFTopZ],1  ; 1 ©†dek bude rezerva
         sbb       word ptr es:[DBFTopZ+2],0

; ------ stanoven° maxim†ln°ho poá†tku -> BX:DI

KorBMnu5:mov       cx,es:[DBFVysL]          ; vnit©n° vò®ka okna
         dec       cx
         dec       cx
;         mov       ch,0
;         mov       cl,ds:[si+MnuVys]        ; celkov† vò®ka okna
;         sub       cl,5                     ; vnit©n° vò®ka okna - 1
         sub       di,cx                    ; maxim†ln° poá†tek
         sbb       bx,0
         jnc       KorBMnu6                 ; nen° p©eteáen°
         xor       di,di                    ; omezen° p©i p©eteáen°
         xor       bx,bx

; ------ stanoven° poá†tku podle kurzoru

KorBMnu6:dec       cx                       ; vnit©n° vò®ka okna
         sub       ax,cx                    ; maxim†ln° poá†tek okna
         sbb       dx,0
         jnc       KorBMnu7
         xor       ax,ax                    ; omezen° p©i podteáen°
         xor       dx,dx

; ------ kontrola p©eteáen° konce okna podle kurzoru

KorBMnu7:cmp       dx,es:[DBFTopZ+2]
         jne       KorBMnu8
         cmp       ax,es:[DBFTopZ]
KorBMnu8:jbe       KorBMn82                 ; nen° p©eteáen° poá†tku
         mov       es:[DBFTopZ+2],dx        ; omezen° poá†tku
         mov       es:[DBFTopZ],ax

; ------ omezen° poá†tku podle maxim†ln°ho poá†tku

KorBMn82:cmp       bx,es:[DBFTopZ+2]
         jne       KorBMn84
         cmp       di,es:[DBFTopZ]
KorBMn84:jae       KorBMnu9
         mov       es:[DBFTopZ+2],bx
         mov       es:[DBFTopZ],di

; ------ n†vrat registrñ

KorBMnu9:pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

KorBMnu  ENDP

; *****************************************************************************
;                             HlavDBF
;                 z†pis z†hlav° do souboru DBF
; -----------------------------------------------------------------------------
; VSTUP: SI=definice okna
;        DS=datovò segment
; VùSTUP:CY=chyba operace
; *****************************************************************************

HlavDBF  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      si
         push      es

; ------ adresa definice okna

         call      DBFAdrES                 ; aktualizace adresy okna -> ES

; ------ oprava poátu z†znamñ

         mov       ax,es:[DBFMaxZ]
         mov       es:[DBFNumZ],ax
         mov       ax,es:[DBFMaxZ+2]
         mov       es:[DBFNumZ+2],ax

; ------ korekce popisovaáe typu souboru

         mov       al,3                     ; bàënò soubor bez MEMO
         test      byte ptr es:[DBFParm],bit4 ; je MEMO soubor ?
         jz        HlavDBF3                 ; nen° MEMO soubor
         mov       al,83h                   ; soubor DBASE MEMO
         test      byte ptr es:[DBFParm],bit3 ; je soubor DBASE MEMO ?
         jnz       HlavDBF3                 ; je soubor DBASE MEMO
         mov       al,0f5h                  ; jinak FOXPRO MEMO
HlavDBF3:mov       es:[DBFVer],al           ; identifik†tor souboru

; ------ aktualizace data

         test      byte ptr ds:[DBFEParm],bit7 ; màn° se datum ?
         jnz       HlavDBF5                 ; datum se nemàn°
         mov       ah,2ah
         int       21h                      ; poskytnut° data
         sub       cx,1900
         cmp       cx,100
         jb        HlavDBF4
         sub       cx,100                   ; korekce roku
HlavDBF4:mov       es:[DBFRok],cl           ; rok
         mov       es:[DBFMes],dh           ; màs°c
         mov       es:[DBFDen],dl           ; den
HlavDBF5:and       byte ptr ds:[DBFEParm],not bit7 ; zru®en° p©°znaku

; ------ inicializace intern°ch p©ep°naáñ

         test      byte ptr es:[DBFParm2],bit0 ; jsou intern° p©ep°naáe ?
         jz        HlavDBF6                 ; nejsou intern° p©ep°naáe
         mov       word ptr es:[DBFSwIdn],"MD" ; identifik†tor intern°ch p©ep°naáñ
         mov       word ptr es:[DBFSwKod],"00" ; k¢d neuráenò
         cmp       byte ptr ds:[CodePagK],0 ; je k¢d uráenò ?
         je        HlavDBF6                 ; k¢d nen° uráenò
         mov       word ptr es:[DBFSwKod],"AK" ; je k¢d Kamenickòch
         cmp       byte ptr ds:[CodePagK],1 ; je Kamenickòch ?
         je        HlavDBF6                 ; je Kamenickòch
         mov       word ptr es:[DBFSwKod],"2L" ; k¢d Latin 2

; ------ z†pis z†hlav° do souboru

HlavDBF6:mov       ax,es:[DBFIdent]
         call      far ptr ResFile          ; ukazatel v souboru na zaá†tek
         jc        HlavDBF9                 ; chyba z†pisu
         mov       si,DBFHlava              ; z†hlav° souboru
         mov       cx,es:[DBFBytH]          ; dÇlka z†hlav° souboru
         call      far ptr WritFile         ; z†pis z†hlav° do souboru
         jc        HlavDBF9                 ; chyba

; ------ vypr†zdnàn° zmàn

         call      far ptr FlshFile         ; uloëen° zmàn na disk

; ------ n†vrat registrñ

HlavDBF9:pop       es
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

HlavDBF  ENDP

; *****************************************************************************
;                           SetADBF
;               uloëen° aktivn°ho z†znamu na disk
; -----------------------------------------------------------------------------
; VSTUP: SI=definice okna
;        DS=datovò segment
; VùSTUP:CY=chyba
; *****************************************************************************

SetADBF  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      dx
         push      di
         push      es

; ------ poskytnut° adresy z†znamu

         call      far ptr GetADBF          ; poskytnut° aktivn° poloëky
         jc        SetADBF2                 ; chyba

; ------ uloëen° aktivn°ho z†znamu

         mov       dx,es:[DBFAktZ+2]        ; á°slo z†znamu HIGH
         mov       ax,es:[DBFAktZ]          ; á°slo z†znamu LOW
         call      far ptr SetDBF           ; uloëen° z†znamu na disk

; ------ n†vrat registrñ

SetADBF2:pop       es
         pop       di
         pop       dx
         pop       ax
         ret

SetADBF  ENDP

; *****************************************************************************
;                              SetDBF
;          uloëen° z†znamu na disk (nezaji®üuje aktualizaci bufferu)
; -----------------------------------------------------------------------------
; VSTUP: SI=adresa definice okna
;        DX:AX=á°slo z†znamu (nekontroluj° se meze)
;        ES:DI=adresa z†znamu
;        DS=datovò segment
; VùSTUP:CY=chyba
; *****************************************************************************

SetDBF   PROC      FAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      si

; ------ adresa okna

         push      es

         push      ax                       ; á°slo z†znamu LOW
         call      DBFAdrES                 ; aktualizace adresy okna -> ES

; ------ vòpoáet offsetu v souboru

         mov       cx,es:[DBFbytZ]          ; poáet bajtñ na z†znam
         xchg      ax,dx                    ; AX <- á°slo z†znam HIGH
         mul       cx                       ; vòpoáet offsetu HIGH
         xchg      ax,cx                    ; CX <- offset HIGH
         pop       dx                       ; á°slo z†znamu LOW
         mul       dx                       ; vòpoáet offsetu LOW
         add       dx,cx                    ; uschovanò offset HIGH
         add       ax,es:[DBFBytH]          ; p©iáten° bajtñ na z†hlav°
         adc       dx,0

; ------ nastaven° ukazatele v souboru

         xchg      ax,cx                    ; ukazatel v souboru LOW
         mov       ax,es:[DBFIdent]         ; identifik†tor souboru
         call      far ptr SetUFile         ; nastaven° ukazatele v souboru
         mov       cx,es:[DBFBytZ]          ; poáet bajtñ na z†znam

         pop       es                       ; adresa z†znamu
         jc        SetDBF2                  ; nàjak† chyba

; ------ uloëen° z†znamu na disk

         or        byte ptr ds:[DBFEPar2],bit5 ; byl z†pis z†znamu na disk
         mov       si,di                    ; SI <- offset z†znamu
         call      far ptr WritFile         ; uloëen° z†znamu na disk

; ------ n†vrat registrñ

SetDBF2: pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

SetDBF   ENDP

; *****************************************************************************
;                             GetADBF
;                 poskytnut° aktivn°ho z†znamu datab†ze
; -----------------------------------------------------------------------------
; VSTUP: SI=definice menu okna editoru datab†ze
;        DS=datovò segment
; VùSTUP:ES:DI=adresa datab†zovÇ poloëky
;        CY=chyba
; *****************************************************************************

GetADBF  PROC      FAR

         push      ax
         push      dx

         call      DBFAdrES                 ; aktualizace adresy okna -> ES

         mov       ax,es:[DBFAktZ]
         mov       dx,es:[DBFAktZ+2]
         call      far ptr GetDBF

GetADBF3:pop       dx
         pop       ax
         ret

GetADBF  ENDP

; *****************************************************************************
;                              GetDBF
;                  poskytnut° poloëky datab†ze
; -----------------------------------------------------------------------------
; VSTUP: DX:AX=á°slo poëadovanÇ poloëky (0...MAX-1)
;        SI=definice menu okna editoru datab†ze
;        DS=datovò segment
; VùSTUP:ES:DI=adresa datab†zovÇ poloëky
;        CY=chyba
; *****************************************************************************

GetDBF   PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si

; ------ adresa definice okna

         call      DBFAdrES                 ; aktualizace adresy okna -> ES

; ------ kontrola, zda je platn† poloëka

         cmp       dx,es:[DBFMaxZ+2]        ; je á°slo z†znamu OK ?
         jne       GetDBF1
         cmp       ax,es:[DBFMaxZ]
GetDBF1: cmc
         jc        GetDBF3                  ; chybnÇ á°slo z†znamu

; ------ kontrola, zda je poloëka v bufferu

GetDBF2: mov       cx,ax                    ; CX <- á°slo poloëky LOW
         mov       bx,dx                    ; BX <- á°slo poloëky HIGH
         sub       cx,es:[DBFBegD]          ; relativn° á°slo poloëky v bufferu
         sbb       bx,es:[DBFBegD+2]
         jnz       GetDBF4                  ; poloëka je pod bufferem nebo za
         cmp       cx,es:[DBFNumD]          ; kontrola konce bufferu
         jae       GetDBF4                  ; poloëka nen° v bufferu

; ------ poloëka je v bufferu - vòpoáet jej° adresy

         mov       ax,es:[DBFBytZ]          ; poáet bajtñ na z†znam
         mul       cx                       ; vòpoáet offsetu v bufferu
         add       ax,es:[DBFAdrD]          ; adresa poloëky v bufferu
         xchg      ax,di                    ; DI <- adresa poloëky
         clc                                ; p©°znak poloëky OK
GetDBF3: jmp       short GetDBF9

; ------ vòpoáet novÇ poá†teán° poloëky v bufferu

GetDBF4: mov       cx,ax                    ; £schova poloëky LOW
         mov       si,es:[DBFMaxD]          ; poáet z†znamñ v bufferu
         shr       si,1                     ; poáet z†znamñ v polovinà bufferu
         sub       ax,si                    ; poá†teán° z†znam v bufferu
         sbb       dx,0
         jnc       GetDBF5
         xor       ax,ax                    ; omezen° p©i podteáen°
         xor       dx,dx
GetDBF5: mov       es:[DBFBegD],ax          ; novò poá†teán° z†znam
         mov       es:[DBFBegD+2],dx
         sub       cx,ax                    ; á°slo z†znamu relativnà v bufferu
         mov       word ptr es:[DBFNumD],0  ; nejsou z†znamy v bufferu

; ------ vòpoáet adresy poloëky -> DI

         push      ax
         push      dx

         xchg      ax,cx                    ; AX <- z†znam relativnà
         mov       cx,es:[DBFBytZ]          ; poáet bajtñ na z†znam
         mul       cx                       ; vòpoáet offsetu v bufferu
         add       ax,es:[DBFAdrD]          ; adresa z†znamu v bufferu
         xchg      ax,di                    ; DI <- adresa z†znamu

         pop       dx
         pop       ax

; ------ vòpoáet offsetu poá†tku v souboru -> DX:AX

         push      ax                       ; á°slo z†znamu LOW
         xchg      ax,dx                    ; AX <- á°slo z†znam HIGH
         mul       cx                       ; vòpoáet offsetu HIGH
         xchg      ax,cx                    ; CX <- offset HIGH
         pop       dx                       ; á°slo z†znamu LOW
         mul       dx                       ; vòpoáet offsetu LOW
         add       dx,cx                    ; uschovanò offset HIGH
         add       ax,es:[DBFBytH]          ; p©iáten° bajtñ na z†hlav°
         adc       dx,0

; ------ nastaven° ukazatele poá†tku bufferu

         xchg      ax,cx                    ; CX <- offset zaá†tku LOW
         mov       ax,es:[DBFIdent]         ; identifik†tor souboru
         call      far ptr SetUFile         ; nastaven° ukazatele souboru
         jc        GetDBF9                  ; chyba operace

; ------ naáten° dat do bufferu

         push      di
         mov       ax,es:[DBFBytZ]          ; poáet bajtñ na z†znam
         mul       word ptr es:[DBFMaxD]    ; poáet bajtñ k naáten°
         xchg      ax,cx                    ; CX <- poáet bajtñ k naáten°
         mov       di,es:[DBFAdrD]          ; adresa bufferu
         mov       ax,es:[DBFIdent]         ; identifik†tor souboru
         call      far ptr ReadFile         ; naáten° dat do bufferu
         pop       di
         jc        GetDBF9                  ; chyba - nen° nic naáteno

; ------ vòpoáet novÇho poátu z†znamñ v bufferu

         xchg      ax,cx                    ; AX <- poáet naátenòch bajtñ
         xor       dx,dx                    ; DX <- 0
         div       word ptr es:[DBFBytZ]    ; vòpoáet novÇho poátu z†znamñ
         mov       es:[DBFNumD],ax          ; novò poáet z†znamñ v bufferu
         clc                                ; p©°znak operace OK

; ------ n†vrat registrñ

GetDBF9: pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

GetDBF   ENDP

; *****************************************************************************
;                               MiniDBF
;     minimalizace velikosti bloku datab†ze (uvolnàn° bufferu) - na 1 z†znam
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
;        SI=definice okna editoru datab†ze
; *****************************************************************************

MiniDBF  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      di
         push      es

; ------ adresa bloku -> ES

         call      DBFAdrES                 ; aktualizace adresy okna -> ES

; ------ vòpoáet poátu bajtñ k vypu®tàn°

         mov       word ptr es:[DBFNumD],0  ; v bufferu nen° ë†dnò z†znam
         mov       ax,es:[DBFBytZ]          ; poáet bajtñ na z†znam
         mov       cx,es:[DBFMaxD]          ; maxim†lnà z†znamñ v bufferu
         jcxz      MiniDBF9                 ; nàjak† chyba ?
         dec       cx                       ; 1 z†znam se ponech†
         jcxz      MiniDBF9                 ; buffer je jië minim†ln°
         mul       cx                       ; vòpoáet velikosti bufferu
         xchg      ax,cx                    ; CX <- poáet bajtñ ke zru®en°
         mov       word ptr es:[DBFMaxD],1  ; velikost bufferu 1 z†znam

; ------ zru®en° nadbyteánÇ á†sti bufferu

         mov       di,es:[DBFAdrD]          ; adresa bufferu
         mov       ax,ds:[si+DBMnuSeg]      ; segment datab†ze
         call      far ptr DelDat           ; zru®en° dat z bufferu

; ------ n†vrat registrñ

MiniDBF9:pop       es
         pop       di
         pop       dx
         pop       cx
         pop       ax
         ret

MiniDBF  ENDP

; *****************************************************************************
;                               MaxiDBF
;        maximalizace velikosti bloku datab†ze (na maxim†ln° volnou pamàü)
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
;        SI=definice okna editoru datab†ze
; *****************************************************************************

MaxiDBF  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      di
         push      es

; ------ adresa bloku -> ES

         call      DBFAdrES                 ; aktualizace adresy okna -> ES

; ------ stanoven° volnÇho m°sta v pamàti

         mov       word ptr es:[DBFNumD],0  ; v bufferu nen° ë†dnò z†znam
         call      far ptr GetFree          ; poskytnut° volnÇ pamàti
         sub       bx,100h                  ; rezerva 4 KB
         jbe       MaxiDBF9                 ; m†lo pamàti
         cmp       bx,0fffh                 ; maximum 64 KB
         jbe       MaxiDBF2                 ; OK
         mov       bx,0fffh                 ; omezen° na 64 KB
MaxiDBF2:mov       cl,4
         shl       bx,cl                    ; voln† pamàü v bajtech

; ------ vòpoáet konce bufferu

         add       bx,es:[0]                ; novò moënò konec bufferu
         jnc       MaxiDBF3                 ; nep©es†hne 64 KB
         mov       bx,0fff0h                ; omezenò konec bufferu

; ------ vòpoáet novÇho poátu z†znamñ v bufferu

MaxiDBF3:sub       bx,es:[0]                ; volnÇ m°sto v bufferu
         jbe       MaxiDBF9                 ; nelze jië zvàt®it
         xchg      ax,bx                    ; AX <- volnÇ m°sto
         xor       dx,dx                    ; DX <- 0
         div       word ptr es:[DBFBytZ]    ; vòpoáet poátu z†znamñ
         mov       bx,ax                    ; BX <- novò poáet z†znamñ
         mul       word ptr es:[DBFBytZ]    ; novò poáet bajtñ k vloëen°
         xchg      ax,cx                    ; CX <- novò poáet bajtñ

; ------ vloëen° novòch dat

         mov       di,es:[DBFAdrD]          ; adresa datovÇho bufferu
         mov       ax,ds:[si+DBMnuSeg]      ; segment datab†ze
         call      far ptr InsDat           ; vytvo©en° m°sta pro buffer
         jc        MaxiDBF9                 ; chyba ?
         add       es:[DBFMaxD],bx          ; zvò®en° poátu z†znamñ v bufferu

; ------ n†vrat registrñ

MaxiDBF9:pop       es
         pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

MaxiDBF  ENDP

; *****************************************************************************
;                               OpenDBF
;                    otev©en° okna editoru datab†ze
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
;        SI=definice okna editoru datab†ze
;        ES:DI=jmÇno souboru DBF (pozor - nesm° bòt ovlivnàno posouv†n°m blokñ)
;        CX=dÇlka jmÇna souboru DBF (max. 86 znakñ !)
; VùSTUP: CY=nedostatek pamàti, soubor nenalezen nebo m† chybnou strukturu
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) segment jmÇna souboru
;                   SS:[BP-4] (2) offset jmÇna souboru
;                   SS:[BP-6] (2) á°slo datovÇho bloku
;                   SS:[BP-7] (1) ®°©ka textovÇ poloëky v str†nkovÇm reëimu
;                   SS:[BP-8] (1)
;                   SS:[BP-10] (2) adresa definice menu
; *****************************************************************************
;˛
OpenDBF  PROC      FAR

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

         sub       sp,10
         mov       ss:[bp-2],es             ; segment jmÇna souboru
         mov       ss:[bp-4],di             ; offset jmÇna souboru
         mov       al,ds:[si+MnuSir]        ; ®°©ka okna
         sub       al,15                    ; zbytek na textovò ©†dek
         mov       ss:[bp-7],al             ; maxim†ln° ®°©ka textovÇ poloëky
         mov       ss:[bp-10],si            ; adresa definice menu

; ------ vytvo©en° datovÇho bloku

         call      far ptr CreatSeg         ; vytvo©en° datovÇho bloku
         jnc       OpenDBF1
         jmp       OpenDBF9                 ; chyba (CY=chyba)

OpenDBF1:mov       ss:[bp-6],ax             ; á°slo datovÇho bloku
         mov       ds:[si+DBMnuSeg],ax      ; á°slo datovÇho bloku

; ------ adresa datovÇho bloku -> ES

         call      DBFAdrES                 ; aktualizace adresy okna -> ES

; ------ nastaven° inicializaán° velikosti datovÇho bloku

         mov       bx,DBFPopis              ; inicializaán° velikost bloku
         call      far ptr ModiSegS         ; nastaven° velikosti bloku
         jnc       OpenDBF3                 ; operace OK
OpenDBF2:jmp       OpenDBF8                 ; chyba - nedostatek pamàti

; ------ nulov†n° bufferu

OpenDBF3:push      cx                       ; dÇlka jmÇna souboru
         cld
         xor       di,di
         mov       ax,bx                    ; AX <- inicializaán° velikost
         stosw                              ; velikost datovÇho bloku
         mov       cx,(DBFPopis+1-2)/2      ; velikost datovÇho bloku ve slovech
         xor       ax,ax                    ; AX <- 0
         rep       stosw                    ; vynulov†n° bloku
         pop       cx                       ; dÇlka jmÇna souboru

; ------ p©°prava jmÇna souboru DBF (CX=dÇlka jmÇna souboru)

         push      ds

         lds       si,ss:[bp-4]             ; adresa jmÇna souboru
         mov       di,DBFSoub               ; jmÇno souboru DBF
         mov       es:[DBFSoubN],cx         ; dÇlka jmÇna souboru
         cld
         push      si
         push      cx
         rep       movsb                    ; p©enos jmÇna souboru
         pop       cx
         pop       si
         mov       al,0
         stosb                              ; koncov† 0

; ------ p©°prava jmÇna souboru FPT

         mov       di,DBFSouT               ; jmÇno souboru DBT
         rep       movsb                    ; p©enos jmÇna souboru
         sub       di,4                     ; n†vrat na oddàlovac° teáku
         mov       cl,4                     ; poáet pozic k hled†n°
         mov       al,"."                   ; oddàlovac° teáka
         repne     scasb                    ; nalezen° oddàlovac° teáky
         je        OpenDB32                 ; teáka nalezena
         stosb                              ; oddàlovac° teáka
OpenDB32:mov       ax,"PF"
         stosw                              ; "FP"
         mov       ax,"T"
         stosw                              ; "T" a koncov† 0

         sub       di,DBFSouT+1             ; dÇlka jmÇna souboru MEMO
         mov       es:[DBFSouTN],di         ; dÇlka jmÇna souboru MEMO

         pop       ds

; ------ otev©en° souboru datab†ze DBF

         mov       si,DBFSoub               ; jmÇno souboru DBF
         call      far ptr OpenRW           ; otev©en° pro áten° i z†pis
         jnc       OpenDB33                 ; soubor otev©en OK
         call      far ptr OpenR            ; otev©en° alespo§ pro áten°
         jc        OpenDBF2                 ; chyba - soubor nenalezen
         or        byte ptr es:[DBFParm],bit1 ; p©°znak z†kazu z†pisu
OpenDB33:mov       es:[DBFIdent],ax         ; identifik†tor souboru

; ------ p©°prava implicitn°ho z†hlav° souboru (je-li novò soubor)

         mov       di,DBFHlava              ; zaá†tek z†hlav° souboru
         mov       byte ptr es:[di],3       ; verze datab†ze
         mov       byte ptr es:[di+DBFBytH-DBFHlava],33 ; dÇlka z†hlav°
         mov       word ptr es:[di+DBFSwIdn-DBFHlava],"MD" ; identifik†tor
         mov       word ptr es:[di+DBFSwKod-DBFHlava],"00" ; k¢d neuráenò
         cmp       byte ptr ds:[CodePagK],0 ; je k¢d uráenò ?
         je        OpnDB332                 ; k¢d nen° uráenò
         mov       word ptr es:[di+DBFSwKod-DBFHlava],"AK" ; k¢d Kamenickòch
         cmp       byte ptr ds:[CodePagK],1 ; je Kamenickòch ?
         je        OpnDB332                 ; je Kamenickòch
         mov       word ptr es:[di+DBFSwKod-DBFHlava],"2L" ; k¢d Latin 2

; ------ naáten° popisovaáe z†hlav° souboru do pamàti

OpnDB332:mov       cx,DBFPopis-DBFHlava     ; dÇlka popisovaáe z†hlav° souboru
         call      far ptr ReadFile         ; naáten° popisovaáe z†hlav°
         jnc       OpnDB333
         jmp       OpenDBF7                 ; chyba áten°

OpnDB333:cmp       word ptr es:[di+DBFBytH-DBFHlava],33 ; minim†ln° dÇlka z†hlav°
         jae       OpnDB334                 ; dÇlka z†hlav° je OK
         mov       word ptr es:[di+DBFBytH-DBFHlava],33 ; minim†ln° dÇlka

OpnDB334:cmp       word ptr es:[di+DBFBytZ-DBFHlava],0 ; je spr†vn† dÇlka z†znamu ?
         jne       OpenDB34                 ; dÇlka z†znamu je OK
         inc       byte ptr es:[di+DBFBytZ-DBFHlava]; oprava dÇlky z†znamu na 1

; ------ rozli®en°, zda je form†t DBASE nebo FOXPRO

OpenDB34:cmp       byte ptr es:[di],83h     ; je MEMO DBASE ?
         jne       OpenDB35                 ; nen° MEMO DBASE (tak je FOXPRO)
         or        byte ptr es:[DBFParm],bit3 ; je MEMO DBASE
         mov       di,es:[DBFSouTN]         ; dÇlka jmÇna souboru MEMO
         mov       word ptr es:[di+DBFSouT-3],"BD" ; je soubor "DBT"

; ------ test, zda jsou intern° p©ep°naáe

OpenDB35:cmp       word ptr es:[DBFSwIdn],"MD" ; jsou intern° p©ep°naáe ?
         jne       OpenDB38                 ; nejsou intern° p©ep°naáe
         mov       dl,bit2                  ; k¢d pro Kamenickòch
         cmp       word ptr es:[DBFSwKod],"AK" ; je k¢d Kamenickòch ?
         je        OpenDB36                 ; je k¢d Kamenickòch
         mov       dl,bit3                  ; k¢d pro Latin 2
         cmp       word ptr es:[DBFSwKod],"2L" ; je k¢d Latin 2 ?
         jne       OpenDB38                 ; nejsou intern° p©ep°naáe
OpenDB36:or        byte ptr es:[DBFParm2],bit0 ; jsou intern° p©ep°naáe
         mov       dh,bit1                  ; p©°prava vòstupn°ho k¢du
         mov       cl,ds:[CodePagK]         ; aktu†ln° k¢d
         cmp       cl,0                     ; je k¢d uráenò ?
         je        OpenDB38                 ; k¢d nen° uráenò
         shl       dh,cl                    ; p©°prava k¢du ke konverzi
         cmp       dh,dl                    ; je pot©eba zmànit k¢d ?
         je        OpenDB38                 ; k¢d nen° pot©eba mànit
         mov       cx,es:[DBFBytH]          ; dÇlka z†hlav° v bajtech
         mov       bx,ss:[bp-6]             ; á°slo datovÇho bloku
         call      OpenKonv                 ; konverze k¢du -> soubor AX
         jc        OpenDB75                 ; chyba nebo p©eru®en°
;˛
OpenDB38:

; ------ vytvo©en° m°sta pro naáten° popisovaáñ poloëek

         mov       cx,es:[DBFBytH]          ; dÇlka z†hlav° v bajtech
         sub       cx,DBFPopis-DBFHlava     ; odeáten° jië naátenÇ á†sti
;         jbe       OpenDB75                 ; mal† dÇlka z†hlav°
         push      ax
         mov       ax,ss:[bp-6]             ; á°slo datovÇho bloku
         mov       di,DBFPopis              ; adresa k naáten° popisovaáñ
         call      far ptr InsDat           ; vytvo©en° m°sta
         pop       ax
         jnc       OpenDB76                 ; operace OK
OpenDB75:jmp       OpenDBF7                 ; chyba - nedostatek pamàti

; ------ vynulov†n° popisovaáñ poloëek

OpenDB76:push      ax
         push      cx
         push      di
         mov       al,CR                    ; p©°znak konce z†hlav°
         cld
         rep       stosb                    ; vynulov†n° popisovaáñ
         pop       di
         pop       cx
         pop       ax

; ------ naáten° popisovaáñ poloëek

         push      cx
         call      far ptr ReadFile         ; naáten° zbytku z†hlav°
         pop       cx
         jc        OpenDB75                 ; byla chyba operace

; ------ p©°prava k vytvo©en° indexovÇ tabulky popisovaáñ

         mov       word ptr ds:[DBZobOld+2],-1 ; pot©eba naáten° MEMO
         or        byte ptr ds:[DBZobPar],bit1+bit4 ; nen° MEMO pole
         and       byte ptr ds:[DBFEParm],not bit6 ; nen° novò soubor
         mov       si,di                    ; adresa zaá†tku popisovaáñ
         add       di,cx                    ; adresa konce popisovaáñ
         mov       bx,di                    ; £schova konce popisovaáñ
         mov       cx,DBFX                  ; dÇlka popisovaáe poloëky
         mov       ax,ss:[bp-6]             ; á°slo datovÇho bloku
         mov       es:[DBFAdrP],di          ; adresa indexu popisovaáñ
         sub       bx,32                    ; rezerva pro celou poloëku

; ------ kontrola, zda je dal®° poloëka popisovaáe

OpenDBF4:cmp       si,bx                    ; je je®tà dal®° popisovaá ?
         jbe       OpenDB4B                 ; je je®tà dal®° popisovaá
         jmp       OpenDBF5                 ; nen° dal®° popisovaá

; ------ kontrola, zda je platnò popisovaá

OpenDB4B:cmp       byte ptr es:[si]," "     ; je platnò popisovaá ?
         jbe       OpenDB4D                 ; nen° platnò popisovaá
         mov       dl,es:[si+16]            ; dÇlka poloëky (bajtñ)
         or        dl,dl                    ; je platn† dÇlka poloëky ?
         jnz       OpenDB4C                 ; poloëka je OK

; ------ vytvo©en° m°sta pro index

OpenDB4D:jmp       OpenDB48                 ; nen° platn† poloëka

OpenDB4C:call      far ptr InsDat           ; vytvo©en° m°sta pro index
         jnc       OpenDB4x                 ; pamàü je OK
OpenDB74:jmp       OpenDBF7

; ------ inicializace indexu

OpenDB4x:inc       word ptr es:[DBFNumP]    ; zvò®en° poátu popisovaáñ
         mov       es:[di+DBFNamX],si       ; adresa jmÇna poloëky
         mov       dh,0
         mov       es:[di+DBFDelX],dx       ; dÇlka poloëky (bajtñ)

; ------ poáet ©†dkñ ve str†nkovÇm reëimu

OpenDB4M:inc       word ptr es:[DBFNumL]    ; zvò®en° poátu ©†dkñ str†nk. reëimu
         sub       dl,ss:[bp-7]             ; odeáten° ®°©ky jednoho ©†dku
         ja        OpenDB4M                 ; je dal®° ©†dek

; ------ typ poloëky

         mov       dl,es:[si+11]            ; typ poloëky

         mov       dh,bit0                  ; textov† poloëka "C"
         cmp       dl,"C"
         je        OpenDB40                 ; je textov† poloëka "C"

         mov       dh,bit1                  ; á°seln† poloëka "N"
         cmp       dl,"N"
         je        OpenDB40                 ; je á°seln† poloëka "N"

         mov       dh,bit2                  ; á°seln† poloëka "F"
         cmp       dl,"F"
         je        OpenDB40                 ; á°seln† poloëka "F"

         cmp       byte ptr es:[si+16],8    ; dÇlka poloëky pro datum ?
         jne       OpnDB4M2                 ; nen° datum
         mov       dh,bit3                  ; datum
         cmp       dl,"D"                   ; je to datum ?
         je        OpenDB40                 ; je poloëka "datum"

OpnDB4M2:cmp       byte ptr es:[si+16],1    ; dÇlka poloëky pro logickou poloëku ?
         jne       OpnDB4M4                 ; nen° datum
         mov       dh,bit4                  ; logick† poloëka
         cmp       dl,"L"
         je        OpenDB40                 ; logick† poloëka "L"

OpnDB4M4:cmp       byte ptr es:[si+16],10   ; dÇlka poloëky pro MEMO pole
         jne       OpenDB4y                 ; nen° MEMO pole
         mov       dh,bit5                  ; memo poloëka
         cmp       dl,"M"
         jne       OpenDB4y
         or        byte ptr es:[DBFParm],bit4 ; p©°znak MEMO souboru
         and       byte ptr ds:[DBZobPar],not bit1 ; je MEMO pole
         jmp       short OpenDB40           ; memo poloëka

OpenDB4y:cmp       byte ptr es:[si+16],6    ; dÇlka poloëky pro áas
         jne       OpenDB4z                 ; nen° áas
         mov       dh,bit6                  ; áas
         cmp       dl,"T"
         je        OpenDB40                 ; je poloëka "áas"

OpenDB4z:mov       dh,bit7                  ; jinak nezn†mò typ poloëky

OpenDB40:mov       es:[di+DBFParX],dh       ; nastaven° typu poloëky

         test      dh,bit7                  ; je nezn†mò typ poloëky ?
         jnz       OpenDB4E                 ; je nezn†mò typ poloëky

         mov       dl,es:[si+16]            ; dÇlka poloëky
         sub       dl,2                     ; poáet desetinnòch m°st
         jnc       OpenDB4F                 ; nen° podteáen°
         mov       dl,0                     ; omezen°
OpenDB4F:cmp       dl,es:[si+17]            ; je poáet desetinnòch m°st OK ?
         ja        OpenDB4E                 ; poáet desetinnòch m°st je OK
         mov       es:[si+17],dl            ; omezen° poátu desetinnòch m°st

; ------ stanoven° dÇlky jmÇna

OpenDB4E:mov       byte ptr es:[di+DBFNumX],0 ; inicializace dÇlky jmÇna
         push      si
OpenDB41:cmp       byte ptr es:[di+DBFNumX],10 ; maxim†ln° dÇlka jmÇna
         jae       OpenDB42                 ; je jië maxim†ln° dÇlka
         inc       byte ptr es:[di+DBFNumX] ; zvò®en° á°taáe dÇlky jmÇna
         inc       si                       ; zvò®en° adresy
         cmp       byte ptr es:[si]," "     ; je jië konec jmÇna ?
         jae       OpenDB41                 ; nen° konec - dal®° znak
OpenDB42:pop       si

; ------ stanoven° ®°©ky pole poloëky

         mov       dx,es:[si+DBFPSirk]      ; poloëka ®°©ky pole
         sub       dh,dl                    ; teÉ by màlo bòt "D"
         sub       dh,DBFPSirC              ; odeáten° kontroln°ho znaku
         jz        OpenDB47                 ; ®°©ka je platn† OK

OpnDB422:mov       dx,es:[di+DBFDelX]       ; dÇlka poloëky
         test      byte ptr es:[di+DBFParX],bit5 ; je MEMO pole ?
         jz        OpenDB43
         mov       dl,6                     ; ®°©ka MEMO pole

OpenDB43:test      byte ptr es:[di+DBFParX],bit4 ; je to logick† poloëka ?
         jz        OpenDB44                 ; nen° to logick† poloëka
         mov       dl,3                     ; ®°©ka logickÇ poloëky 3 znaky

OpenDB44:test      byte ptr es:[di+DBFParX],bit6 ; je to áas ?
         jnz       OpenDB45                 ; je to áas
         test      byte ptr es:[di+DBFParX],bit3 ; je to datum ?
         jz        OpenDB46                 ; nen° to datum
OpenDB45:inc       dx
         inc       dx                       ; p©iáten° pozic pro oddàlovaáe

OpenDB46:cmp       dl,es:[di+DBFNumX]       ; je poloëka del®° neë jmÇno ?
         jae       OpenDB47                 ; poloëka del®° neë jmÇno - OK
         mov       dl,es:[di+DBFNumX]       ; bude platit dÇlka jmÇna

OpenDB47:mov       es:[di+DBFSirX],dx       ; zobrazen† ®°©ka poloëky bez okrajñ
         add       es:[DBFSirR],dx          ; á°taá celkovÇ ®°©ky ©†dku

; ------ p©°prava dal®°ho popisovaáe

         add       di,DBFX                  ; adresa dal®°ho popisovaáe
OpenDB48:add       si,32                    ; adresa dal®°ho popisovaáe
         jmp       OpenDBF4                 ; dal®° popisovaá

; ------ kontrola, zda je alespo§ 1 poloëka

OpenDBF5:mov       ax,es:[DBFNumP]          ; poáet poloëek
         dec       ax                       ; poáet poloëek - 1
         jns       OpnDBF52                 ; poáet poloëek je OK
         xor       ax,ax                    ; omezen°
         or        byte ptr ds:[DBFEParm],bit6 ; je novò soubor
OpnDBF52:add       es:[DBFSirR],ax          ; korekce celkovÇ ®°©ky ©†dku

; ------ vytvo©en° m°sta pro editaán° buffer z†znamu

         mov       di,es:[0]                ; konec datovÇho bloku
         mov       cx,es:[DBFBytZ]          ; poáet bajtñ na z†znam
;         or        cx,cx                    ; je nàco ?
;         jnz       OpnDBF54                 ; je nàco OK
;         inc       word ptr es:[DBFBytZ]    ; minim†lnà 1 bajt
OpnDBF54:inc       cx
         inc       cx                       ; 2 bajty rezerva pro CR/LF
         mov       ax,ss:[bp-6]             ; á°slo datovÇho bloku
         call      far ptr InsDat           ; vytvo©en° m°sta pro buffer
         jc        OpnDBF62                 ; chyba - nedostatek pamàti
         mov       es:[DBFAdrE],di          ; adresa poá†tku bufferu z†znamu

; ------ vytvo©en° m°sta pro datovò buffer

         call      far ptr GetFree          ; poskytnut° volnÇ pamàti -> BX
         mov       di,es:[0]                ; konec datovÇho bloku
         mov       ax,0ffa0h                ; asi tak maxim†ln° konec bloku
         sub       ax,di                    ; poáet zbylòch bajtñ
         jnc       OpnDBF56
         xor       ax,ax                    ; AX <- 0
OpnDBF56:mov       cl,4                     ; poáet rotac°
         shr       ax,cl                    ; zbylÇ m°sto v odstavc°ch
         sub       bx,100h                  ; rezerva 4 KB
         jbe       OpenDBF7                 ; m†lo pamàti
         cmp       bx,ax                    ; je v°ce neë volnÇ m°sto ?
         jb        OpenDBF6                 ; pamàü je OK
         xchg      ax,bx                    ; BX <- omezen° velikosti bloku
OpenDBF6:shl       bx,cl                    ; voln† pamàü v bajtech
         mov       cx,bx                    ; CX <- voln† pamàü v bajtech
         mov       ax,ss:[bp-6]             ; á°slo datovÇho bloku
         call      far ptr InsDat           ; vytvo©en° m°sta pro buffer
OpnDBF62:jc        OpenDBF7                 ; chyba - nedostatek pamàti
         mov       es:[DBFAdrD],di          ; adresa poá†tku bufferu
         xchg      ax,cx                    ; AX <- velikost bufferu v bajtech
         xor       dx,dx                    ; DX <- 0
         div       word ptr es:[DBFBytZ]    ; vòpoáet max. poátu poloëek
         mov       es:[DBFMaxD],ax          ; maxim†ln° poáet z†znamñ v bufferu
         or        ax,ax                    ; alespo§ 1 z†znam ?
         jz        OpenDBF7                 ; chyba - m†lo pamàti
         mul       word ptr es:[DBFBytZ]    ; p©epoáet zpàt na bajty
         mov       es:[DBFSizD],ax          ; velikost bufferu v bajtech

; ------ stanoven° velikosti souboru

         mov       ax,es:[DBFIdent]         ; identifik†tor souboru
         call      far ptr SizeFile         ; stanoven° velikosti souboru
         jc        OpenDBF7                 ; nàjak† chyba
         sub       cx,es:[DBFBytH]          ; odeáten° z†hlav° LOW
         sbb       bx,0                     ; odeáten° z†hlav° HIGH
         jnc       OpnDBF66                 ; dÇlka souboru OK
         xor       cx,cx
         xor       bx,bx                    ; omezen° p©i malÇ dÇlce souboru

; ------ stanoven° skuteánÇho poátu z†znamñ

OpnDBF66:xchg      ax,bx                    ; AX <- velikost HIGH
         xor       dx,dx                    ; DX <- 0
         div       word ptr es:[DBFBytZ]    ; vydàlen° vy®®°ho slova
         mov       es:[DBFMaxZ+2],ax        ; vy®®° bajt poátu z†znamñ
         xchg      ax,cx                    ; AX <- velikost LOW
         div       word ptr es:[DBFBytZ]    ; vydàlen° nië®°ho slova
         mov       es:[DBFMaxZ],ax          ; nië®° bajt poátu z†znamñ

; ------ v®e OK - konec

         clc                                ; p©°znak operace OK
         jmp       short OpenDBF9           ; v®e OK - konec

; ------ p©i chybà uzav©en° souboru datab†ze (ES=adresa definice bloku)

OpenDBF7:call      DBFClosF                 ; uzav©en° souboru v oknà

; ------ p©i chybà zru®en° datovÇho bloku

OpenDBF8:mov       ax,ss:[bp-6]             ; á°slo datovÇho bloku
         call      far ptr DelSeg           ; zru®en° segmentu datovÇho bloku
         mov       si,ss:[bp-10]            ; adresa definice menu
         mov       word ptr ds:[si+DBMnuSeg],0 ; zru®en° á°sla datovÇho bloku
         stc                                ; p©°znak chyby operace

; ------ n†vrat registrñ

OpenDBF9:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

OpenDBF  ENDP

; -----------------------------------------------------------------------------
;        konverze n†rodn°ho k¢du souboru DBF (p©i otev©en° souboru)
; -----------------------------------------------------------------------------
; VSTUP: AX=identifik†tor souboru DBF (tÇë v DBFIdent)
;        BX=á°slo datovÇho bloku DBF editoru
;        CX=dÇlka z†hlav° souboru
;        DL=vstupn° k¢d souboru (bit2=Kam,bit3=Lat)
;        DH=vòstupn° k¢d souboru (bit2=Kam,bit3=Lat)
;        DS=datovò segment
;        ES=segment bloku DBF editoru
;        ES:DBFSoub=jmÇno souboru DBF
; VùSTUP: AX=identifik†tor novÇho souboru DBF (tÇë do DBFIdent)
;         - ukazatel souboru nastaven na zaá†tek popisovaáñ
;         CY=p©eru®en° operace (AX=starò soubor nebo 0)
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) identifik†tor vstupn°ho souboru DBF
;                   SS:[BP-4] (2) identifik†tor vòstupn°ho souboru DBF
;                   SS:[BP-6] (2) segment bloku DBF
;                   SS:[BP-8] (2) adresa bloku DBF
;                   SS:[BP-10] (2) dÇlka z†hlav° souboru
;                        (SS:[BP-12] (2) vstupn° a vòstupn° k¢d ke konverzi)
;                   SS:[BP-14] (2) segment bloku bufferu (0=nen°)
;                        (SS:[BP-16] (2) adresa bloku bufferu)
;                   SS:[BP-18] (2) velikost bloku bufferu
;                   SS:[BP-20] (2) datum souboru
;                   SS:[BP-22] (2) áas souboru
;                   SS:[BP-24] (2) atributy souboru
;                   DX=vstupn° a vòstupn° k¢d ke konverzi
; -----------------------------------------------------------------------------
; niá° registry: BX, CX, DX, SI, DI
; -----------------------------------------------------------------------------
;˛
OpenKonv PROC      NEAR

; ------ £schova registrñ

         push      bp
         push      es
         mov       bp,sp
         sub       sp,24+FileMax

; ------ p©°prava lok†ln°ch promànnòch

         mov       ss:[bp-2],ax             ; identifik†tor vstupn°ho souboru
         mov       ss:[bp-6],bx             ; segment bloku DBF
         mov       ss:[bp-8],es             ; adresa bloku DBF
         mov       ss:[bp-10],cx            ; dÇlka z†hlav° souboru
;         mov       ss:[bp-12],dx            ; vstupn° a vòstupn° k¢d konverze
         mov       word ptr ss:[bp-14],0    ; datovò buffer nen°

; ------ hl†®en° o prov†dàn° konverze

         mov       si,offset DBPMKon        ; hl†®en°
         push      dx
         call      far ptr Lin0MenF         ; zobrazen° hl†®en°
         pop       dx
         jc        OpnKnv10                 ; p©eru®en° operace ESC
         dec       bx                       ; je potvrzen° konverze ?
         jz        OpnKnv04                 ; je konverze
         jmp       OpenKnv9                 ; konverze se neprovede

; ------ hl†®en° o konverzi

OpnKnv04:mov       si,offset OpnKnvHl       ; text hl†®en°
         call      far ptr InfDisp0         ; zobrazen° hl†®en°

; ------ naáten° data, áasu a atributñ souboru AX/ES:SI

         push      dx
         push      cx

         call      far ptr GetDFile         ; poskytnut° data a áasu
         mov       ss:[bp-20],dx            ; datum souboru
         mov       ss:[bp-22],cx            ; áas souboru
         mov       si,DBFSoub               ; jmÇno souboru
         call      far ptr GetAFile         ; poskytnut° atributñ souboru
         mov       ss:[bp-24],cx            ; atributy souboru

         pop       cx
         pop       dx

; ------ £schova jmÇna souboru do bufferu v z†sobn°ku

         mov       di,sp                    ; DI <- buffer v z†sobn°ku
         push      cx
         push      ds

         mov       si,DBFSoub               ; jmÇno souboru DBF
         mov       cx,FileMax               ; velikost dat
         push      es
         pop       ds                       ; DS <- segment bufferu DBF
         push      ss
         pop       es                       ; ES <- segment z†sobn°ku
         cld
         rep       movsb                    ; £schova jmÇna souboru

         pop       ds
         pop       cx

; ------ vytvo©en° vòstupn°ho souboru (ES=SS)

         mov       si,sp                    ; jmÇno souboru DBF
         call      far ptr CreatPF          ; vytvo©en° p©echodnÇho souboru
         jnc       OpnKnv11
OpnKnv10:jmp       OpenKnv8                 ; chyba

OpnKnv11:mov       ss:[bp-4],ax             ; identifik†tor souboru

; ------ vytvo©en° datovÇho bufferu

         mov       bx,cx                    ; BX <- minim†ln° velikost-z†hlav°
         call      far ptr CreatDat         ; vytvo©en° bufferu
         jnc       OpnKnv14
OpnKnv12:jmp       OpenKnv7                 ; chyba pamàti

OpnKnv14:mov       ss:[bp-14],ax            ; segment bufferu
         mov       ss:[bp-18],bx            ; velikost datovÇho bufferu

; ------ adresa datovÇho bufferu -> ES

         call      far ptr GetDat           ; adresa datovÇho bufferu -> ES
;         mov       ss:[bp-16],es            ; adresa datovÇho bufferu

; ------ naáten° z†hlav° souboru do bufferu

         mov       ax,ss:[bp-2]             ; vstupn° soubor
         call      far ptr ResFile          ; resetov†n° ukazatele
         xor       di,di                    ; ukl†dac° adresa
         call      far ptr ReadFile         ; naáten° z†hlav° souboru
         jc        OpnKnv12                 ; chyba

; ------ p©°prava intern°ch promànnòch

         mov       word ptr es:[di+DBFSwIdn-DBFHlava],"MD" ; identifik†tor
         mov       word ptr es:[di+DBFSwKod-DBFHlava],"00" ; k¢d neuráenò
         cmp       byte ptr ds:[CodePagK],0 ; je neuráenò k¢d ?
         je        OpenKnv1                 ; k¢d neuráenò
         mov       word ptr es:[di+DBFSwKod-DBFHlava],"AK" ; k¢d Kamenickòch
         cmp       byte ptr ds:[CodePagK],1 ; je Kamenickòch ?
         je        OpenKnv1                 ; je Kamenickòch
         mov       word ptr es:[di+DBFSwKod-DBFHlava],"2L" ; k¢d Latin 2

; ------ p©ekonvertov†n° z†hlav° souboru (DX=k¢d)

OpenKnv1:push      cx
         mov       si,DBFPopis-DBFHlava     ; ukazatel dat
         mov       bx,cx                    ; BX <- dÇlka z†hlav°
         sub       bx,DBFPopis-DBFHlava     ; dÇlka z†hlav°
         jbe       OpenKnv3
OpenKnv2:sub       bx,32                    ; je dal®° popisovaá ?
         jb        OpenKnv3                 ; nen° dal®° popisovaá
         mov       cx,11                    ; dÇlka jmÇna poloëky
         call      far ptr KonvFnt          ; konverze fontñ
         add       si,32                    ; zvò®en° ukazatele dat
         jmp       short OpenKnv2           ; dal®° poloëka
OpenKnv3:pop       cx

; ------ z†pis dat do vòstupn°ho souboru (CX bajtñ)

OpenKnv4:xor       si,si                    ; zaá†tek z†hlav°
         mov       ax,ss:[bp-4]             ; vòstupn° soubor
         call      far ptr WritFile         ; z†pis z†hlav° souboru
         jc        OpnKnv12                 ; chyba z†pisu

; ------ naáten° dal®°ho bloku dat

         xor       di,di
         mov       ax,ss:[bp-2]             ; vstupn° soubor
         mov       cx,ss:[bp-18]            ; velikost bufferu
         call      far ptr ReadFile         ; naáten° dal®°ch dat
         jc        OpenKnv7                 ; chyba áten°
         jcxz      OpenKnv5                 ; konec souboru

; ------ p©ekonvertov†n° bloku dat (DX=k¢d)

         call      far ptr KonvFnt          ; p©ekonvertov†n° dat
         jmp       short OpenKnv4           ; dal®° blok dat

; ------ uzav©en° vstupn°ho a vòstupn°ho souboru

OpenKnv5:call      far ptr ClosFile         ; uzav©en° vstupn°ho souboru
         mov       ss:[bp-2],ax             ; p©°znak uzav©en° souboru
         mov       ax,ss:[bp-4]             ; vòstupn° soubor
         call      far ptr ClosFile         ; uzav©en° vòstupn°ho souboru

; ------ zru®en° vstupn°ho souboru

         mov       es,ss:[bp-8]             ; adresa bloku DBF
         mov       si,DBFSoub               ; jmÇno vstupn°ho souboru
         xor       cx,cx                    ; atributy se vynuluj°
         call      far ptr SetAFile         ; vynulov†n° atributñ souboru
         call      far ptr DelFile          ; zru®en° vstupn°ho souboru
         jc        OpenKn72                 ; chyba zru®en° souboru

; ------ p©ejmenov†n° souborñ

         mov       dx,es                    ; DX <- segment c°lovÇho jmÇna
         mov       di,si                    ; DI <- c°lovÇ jmÇno
         push      ss
         pop       es                       ; ES <- segment zdrojovÇho jmÇna
         mov       si,sp                    ; SI <- offset zdrojovÇho jmÇna
         call      far ptr RenFile          ; p©ejmenov†n° souborñ
         jc        OpenKnv9                 ; chyba

; ------ nastaven° atributñ souboru

         mov       es,dx                    ; ES <- segment bufferu DBF
         mov       si,di                    ; SI <- jmÇno souboru
         mov       cx,ss:[bp-24]            ; atributy souboru
         call      far ptr SetAFile         ; nastaven° atributñ souboru

; ------ novÇ otev©en° souboru

         and       byte ptr es:[DBFParm],not bit1 ; nen° z†kaz z†pisu
         call      far ptr OpenRW           ; otev©en° pro áten° i z†pis
         jnc       OpenKnv6                 ; soubor otev©en OK
         call      far ptr OpenR            ; otev©en° alespo§ pro áten°
         jc        OpenKnv9                 ; chyba - soubor nelze otev©°t
         or        byte ptr es:[DBFParm],bit1 ; p©°znak z†kazu z†pisu
OpenKnv6:mov       es:[DBFIdent],ax         ; identifik†tor souboru
         mov       ss:[bp-2],ax             ; identifik†tor souboru

; ------ nastaven° data a áasu souboru

         mov       dx,ss:[bp-20]            ; datum souboru
         mov       cx,ss:[bp-22]            ; áas souboru
         call      far ptr SetDFile         ; nastaven° data a áasu souboru
         jmp       short OpenKnv9           ; (CY=chyba)

; ------ chyba - uzav©en° a zru®en° vòstupn°ho souboru

OpenKnv7:mov       ax,ss:[bp-4]             ; identifik†tor vòstup. souboru
         call      far ptr ClosFile         ; uzav©en° vòstupn°ho souboru
OpenKn72:push      ss
         pop       es                       ; ES <- segment z†sobn°ku
         mov       si,sp                    ; SI <- vòstupn° soubor
         call      far ptr DelFile          ; zru®en° vòstupn°ho souboru
OpenKnv8:stc                                ; p©°znak chyby

; ------ zru®en° datovÇho bufferu

OpenKnv9:pushf
         mov       ax,ss:[bp-14]            ; datovò buffer
         call      far ptr DelSeg           ; zru®en° bufferu

; ------ nastaven° ukazatele v souboru

         mov       ax,ss:[bp-2]             ; identifik†tor souboru
         mov       cx,DBFPopis-DBFHlava     ; dÇlka z†hlav°
         xor       dx,dx                    ; DX <- 0
         call      far ptr SetUFile         ; nastaven° ukazatele v souboru
         popf

; ------ n†vrat registrñ

         mov       sp,bp
         pop       es
         pop       bp
         call      far ptr InfoClos         ; uzav©en° informaán°ho ©†dku
         ret

OpenKonv ENDP

; *****************************************************************************
;                               ClosDBF
;                     uzav©en° okna editoru datab†ze
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
;        SI=definice okna editoru datab†ze
; *****************************************************************************

ClosDBF  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      es

; ------ zru®en° segmentu bufferu MEMO

         call      EditBQVD                 ; zru®en° bufferu MEMO

; ------ adresa datovÇho bloku

         mov       ax,ds:[si+DBMnuSeg]      ; segment okna
         call      far ptr GetDat           ; adresa segmentu -> ES
         jc        ClosDBF9

; ------ uzav©en° souboru datab†ze a souboru MEMO

         push      ax
         call      DBFClosF                 ; uzav©en° souboru v oknà
         mov       ax,es:[DBFIdntT]         ; identifik†tor souboru MEMO
         call      far ptr ClosFile         ; uzav©en° souboru
         pop       ax

; ------ zru®en° datovÇho bloku

         call      far ptr DelSeg           ; zru®en° segmentu AX
         mov       ds:[si+DBMnuSeg],ax      ; oznaáen° segmentu za zru®enò

; ------ n†vrat registrñ

ClosDBF9:pop       es
         pop       ax
         ret

ClosDBF  ENDP

CodeDbf  ENDS

; *****************************************************************************
;
;                          Datovò segment
;
; *****************************************************************************
;˛
Data     SEGMENT

; -----------------------------------------------------------------------------
;        potvrzen° konverze souboru
; -----------------------------------------------------------------------------

DBPMKon  label     byte
         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        3                        ; poáet platnòch poloëek menu
         dw        9                        ; celkovò poáet poloëek menu

         dw        DBPMKPol                 ; adresa definice poloëek
         dw        DBPMKHlp                 ; adresa n†povàd
         dw        Hlp@DatabazoveMenu       ; á°slo str†nky velkÇ n†povàdy
         dw        DBPMKBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        DBPMKTit                 ; adresa titulu okna
         dw        LinMenTE                 ; adresa obsluh voleb
         dw        LinMenTM                 ; adresy podmenu
         dd        0                        ; n†vratov† adresa

         db        19                       ; poá†teán° pozice
         db        7                        ; poá†teán° ©†dek
         db        53                       ; ®°©ka
         db        11                       ; vò®ka

         dw        0                        ; maxim†ln° dÇlka ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        0                        ; celkovò poáet ©†dkñ
         dw        0                        ; poáet zobrazenòch ©†dkñ

         db        0                        ; maska znakñ
         db        0,'      '               ; zak†zanÇ znaky

         db        0                        ; identifik†tor historie
         db        0                        ; poáet p©edvoleb

DBPMKPol db        bit6,0
         db        bit6,9,0,'VAROVèNã'
         db        bit6,47,'Soubor je v jinÇm n†rodn°m k¢du neë je nastaven'
         db        bit6,45,'jako aktu†ln°. Mohu provÇst konverzi souboru?'
         db        bit6,0
         db        bit6+bit7,0
         db        1,11,'Konvertovat'
         db        1,13,'Nekonvertovat'
         db        1,8,'P©eru®it'

DBPMKBlk db        0,0,0
DBPMKTit db        23,'konverze n†rodn°ho k¢du'

HelpS    SEGMENT   BYTE PUBLIC
DBPMKHlp db        41,'Proveden° konverze n†rodn°ho k¢du souboru'
         db        74,'N†rodn° k¢d souboru bude ponech†n nezmànàn a bude povaëov†n za platnò k¢d.'
         db        3,1
         dw        MenuHlP2
HelpS    ENDS


Data     ENDS

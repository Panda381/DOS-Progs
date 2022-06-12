
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                                D I S K 1
;                    parkov n¡, jm‚no disku, form tov n¡
;
; =============================================================================
;
; Ve©ejn‚ procedury:
;
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

INCLUDE  ASM\DEF.ASM

CodeDisk SEGMENT   BYTE PUBLIC
         ASSUME    cs:CodeDisk,ds:Data

FrmMnRad EQU       4                        ; po‡et © dk– menu form tov n¡
FrmMnSlo EQU       3                        ; po‡et sloupc– menu form tov n¡

DELKFORM EQU       4                        ; d‚lka popisova‡e form tu

; ------ typy mechanik

M360     EQU       1                        ; mechanika 360 KB
M120     EQU       2                        ; mechanika 1.2 MB
M720     EQU       3                        ; mechanika 720 KB
M144     EQU       4                        ; mechanika 1.44 MB
M288     EQU       5                        ; mechanika 2.88 MB

; ------ p©enosov  rychlost

R500     EQU       0                        ; 500 kb/s
R300     EQU       1                        ; 300 kb/s
R250     EQU       2                        ; 250 kb/s
R1000    EQU       3                        ; 1000 kb/s

FormBajt EQU       0f6h                     ; form tovac¡ bajt

MaxSekt  EQU       50                       ; maxim lnˆ sektor– na stopu
MaxCyl   EQU       89                       ; maxim ln¡ po‡et v lc–

; *****************************************************************************
;
;                        parkov n¡ pevn˜ch disk–
;
; *****************************************************************************
;þ
Parkov   PROC      FAR

         add       sp,4                     ; zru¨en¡ n vratov‚ adresy
         call      far ptr ClosMnuA         ; uzav©en¡ v¨ech oken menu

; ------ zobrazen¡ hl ¨en¡ o parkov n¡

         mov       si,offset ParkTxt
         call      far ptr InfDisp0         ; zobrazen¡ hl ¨en¡

; ------ ulo‘en¡ histori¡ DOS Mana‘eru

         call      far ptr StoSHist         ; ulo‘en¡ historie na disk

; ------ vypr zdnˆn¡ buffer– SMARTDRV

         call      far ptr SmartFls         ; vypr zdnˆn¡ SMARTDRV

; ------ reset diskov‚ho syst‚mu

         call      far ptr ResDisk          ; resetov n¡ disk–

; ------ parkov n¡ pevn˜ch disk–

         mov       byte ptr ds:[PrkMn1P1],"0" ; nen¡ pevn˜ disk
         mov       byte ptr ds:[FAktDisk],80h ; aktivn¡ pracovn¡ disk
Parkov1: call      GetPark                  ; zji¨tˆn¡ parkovac¡ stopy disku
         call      Parkuj                   ; zaparkov n¡ pevn‚ho disku
         inc       byte ptr ds:[FAktDisk]   ; zv˜¨en¡ ‡¡sla disku
         cmp       byte ptr ds:[FAktDisk],84h ; jsou ji‘ v¨echny disky ?
         jb        Parkov1                  ; dal¨¡ disk

; ------ uzav©en¡ informa‡n¡ho © dku

         call      far ptr InfoClos         ; uzav©en¡ informa‡n¡ho © dku

; ------ zobrazen¡ hl ¨en¡

         mov       si,offset PrkMnu1        ; hl ¨en¡
         call      far ptr Lin0MenF         ; ‡ek n¡ na vypnut¡ po‡¡ta‡e
         jmp       far ptr Main0            ; n vrat do programu

Parkov   ENDP

; -----------------------------------------------------------------------------
;        zji¨tˆn¡ parkovac¡ stopy disku -> CX (0=neplatn‚)
; -----------------------------------------------------------------------------

GetPark  PROC      NEAR

; ------ zji¨tˆn¡ parametr– disku

         xor       cx,cx
         stc
         mov       ah,8
         call      Int13                    ; test platnosti disku DL
         jc        GetPark8                 ; disk je neplatn˜
         jcxz      GetPark8                 ; parametry disku neplatn‚
         or        ah,ah                    ; je nˆjak  chyba ?
         jnz       GetPark8                 ; je chyba

; ------ v˜po‡et parkovac¡ stopy

         xchg      ch,cl                    ; CL <- ni‘¨¡ bajt ‡¡sla stopy
         rol       ch,1
         rol       ch,1                     ; bity 8 a 9 ‡¡sla stopy
         and       ch,bit0+bit1             ; bity 8 a 9 ‡¡sla stopy
         dec       cx                       ; posledn¡ stopa disku
;         inc       cx                       ; ‡¡slo n sleduj¡c¡ stopy
         jmp       short GetPark9

GetPark8:xor       cx,cx                    ; nen¡ parkovac¡ stopa
GetPark9:ret

GetPark  ENDP

; -----------------------------------------------------------------------------
;        zaparkov n¡ pevn‚ho disku (parkovac¡ stopa CX)
; -----------------------------------------------------------------------------

Parkuj   PROC      NEAR

         jcxz      Parkuj9                  ; disk neplatn˜

; ------ reset pevn‚ho disku

         call      FResDisk                 ; resetov n¡ disku

; ------ p©¡prava ‡¡sla parkovac¡ stopy

         xchg      ch,cl
         ror       cl,1
         ror       cl,1                     ; bity 8 a 9 do bit– 6 a 7
         inc       cx                       ; -> sektor 1

; ------ zaparkov n¡ disku

         inc       byte ptr ds:[PrkMn1P1]   ; ‡¡ta‡ disk–
         mov       bx,46                    ; po‡et pokus–
Parkuj4: mov       ah,0ch                   ; funkce vystaven¡ hlav
         call      Int130                   ; zaparkov n¡ disku
         dec       bx
         jnz       Parkuj4

Parkuj9: ret

Parkuj   ENDP

; *****************************************************************************
;
;                            Jm‚no disku
;
; *****************************************************************************
;þ
Labs     PROC      FAR

         add       sp,4                     ; zru¨en¡ n vratov‚ adresy
         call      far ptr ClosMnuA         ; uzav©en¡ v¨ech oken menu

LabsF    LABEL     FAR                      ; sem se sk ‡e z kl vesy Ctr-F6

; ------ test, zda je operace povolena

         test      byte ptr ds:[DMnuVBlk+4],bit0 ; je p©ejmenov n¡ disku povoleno ?
         jnz       Labs19                   ; z kaz p©ejmenov n¡ disku

; ------ zobrazen¡ hl ¨en¡ o na‡¡t n¡ jm‚na disku

         mov       si,offset LabSHl1        ; text hl ¨en¡
         call      far ptr InfDisp0         ; zobrazen¡ hl ¨en¡

; ------ p©¡prava ‡¡sla disku

         mov       al,ds:[AktPath]          ; aktivn¡ disk
         mov       ds:[LabsMnT2],al
         mov       ds:[LabsMnT4],al
         sub       al,"A"                   ; ‡¡slo disku

; ------ na‡ten¡ n vˆ¨t¡ disku

         push      ds
         pop       es                       ; ES <- datov˜ segment
         mov       di,offset LabsNam        ; buffer jm‚na disku
         call      far ptr GetVol           ; na‡ten¡ n vˆ¨t¡ disku
         mov       ds:[LabsDelk],cx         ; d‚lka n vˆ¨t¡ disku
         call      far ptr InfoClos         ; uzav©en¡ hl ¨en¡

; ------ p©¡prava menu

         mov       word ptr ds:[LabMnPl1],offset LabsMnT1 ; nen¡ jm‚no disku
         mov       byte ptr ds:[LabsNum],0  ; nen¡ ‘ dn  p©edvolba
         jcxz      Labs1                    ; nen¡ n vˆ¨t¡ disku nebo chyba
         mov       word ptr ds:[LabMnPl1],offset LabsMnT3 ; je jm‚no disku
         inc       byte ptr ds:[LabsNum]    ; je 1 p©edvolba

; ------ dokon‡en¡ textu hl ¨en¡

         add       di,cx                    ; konec jm‚na disku
         cld
         mov       ax,'"'*HI                ; ozna‡en¡ konce
         stosw
         mov       al,"."
         stosb
         xchg      ax,di
         sub       ax,offset LabsMnT3+1
         mov       ds:[LabsMnT3],al         ; d‚lka textu

; ------ test, zda byla chyba

Labs1:   call      far ptr TestBreak        ; bylo p©eru¨en¡ operace ?
         jnc       Labs2                    ; nen¡ p©eru¨en¡ operace
Labs19:  jmp       Labs9                    ; bylo p©eru¨en¡ operace

; ------ zad n¡ nov‚ho jm‚na disku

Labs2:   mov       si,offset LabMnLin       ; menu zad n¡ jm‚na disku
         call      far ptr Lin0Menu         ; zad n¡ nov‚ho jm‚na disku
         jc        Labs19                   ; p©eru¨en¡ operace

; ------ zobrazen¡ hl ¨en¡ o nastavov n¡ jm‚na disku

         mov       si,offset LabSHl2        ; text hl ¨en¡
         call      far ptr InfDisp0         ; zobrazen¡ hl ¨en¡

; ------ p©¡prava k dek¢dov n¡ jm‚na disku

         push      ds
         pop       es                       ; ES <- datov˜ segment
         mov       di,offset LabsNam        ; buffer k ulo‘en¡ jm‚na disku
         mov       bx,di                    ; BX <- konec jm‚na
         mov       ch,0
         mov       si,offset LinBuff        ; buffer zadan‚ho textu
         mov       cl,ds:[LinNum]           ; po‡et zadan˜ch znak–
         cld
         jcxz      Labs7                    ; nebylo nic zad no

; ------ nalezen¡ za‡ tku zadan‚ho jm‚na -> SI/CX

Labs3:   cmp       byte ptr ds:[si]," "     ; mezera ?
         jne       Labs32                   ; je platn˜ znak
         inc       si                       ; vypu¨tˆn¡ mezery
         loop      Labs3                    ; dal¨¡ znak

; ------ test, zda je zad n jin˜ disk

Labs32:  jcxz      Labs7                    ; nen¡ nic zad no
         cmp       cl,2                     ; jsou alespo¤ 2 znaky ?
         jb        Labs4                    ; m lo znak– - nen¡ disk
         cmp       byte ptr ds:[si+1],":"   ; je zad n disk ?
         jne       Labs4                    ; nen¡ zad n disk
         lodsb                              ; na‡ten¡ ozna‡en¡ disku
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e zbyl˜ch znak–
         call      far ptr UpCase           ; p©evod na velk‚ p¡smeno
         mov       ds:[LabsMnT4],al         ; pracovn¡ disk
         inc       si                       ; p©esko‡en¡ oddˆlova‡e ":"
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e zbyl˜ch znak–

; ------ dek¢dov n¡ jm‚na disku

Labs4:   mov       bx,di                    ; BX <- £schova adresy konce jm‚na
Labs5:   jcxz      Labs7                    ; nen¡ dal¨¡ znak
         cmp       di,offset LabsNam+11     ; maxim ln¡ d‚lka jm‚na
         jae       Labs7                    ; je ji‘ maxim ln¡ d‚lka jm‚na
         lodsb                              ; na‡ten¡ zadan‚ho znaku
         call      far ptr UpCase           ; p©evod na velk‚ p¡smeno
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e zbyl˜ch znak–
         cmp       al,":"                   ; zak zan˜ znak ?
         je        Labs5                    ; zak zan˜ znak
         stosb                              ; ulo‘en¡ znaku
         cmp       al," "                   ; byla to mezera ?
         jne       Labs4                    ; nebyla - je platn˜ znak
         jmp       short Labs5              ; jinak dal¨¡ znak

; ------ zad n¡ nov‚ho jm‚na disku

Labs7:   mov       cx,bx                    ; CX <- konec dek¢dovan‚ho jm‚na
         mov       si,offset LabsNam        ; buffer jm‚na disku
         sub       cx,si                    ; d‚lka zadan‚ho jm‚na disku
         mov       al,ds:[LabsMnT4]         ; ozna‡en¡ disku
         sub       al,"A"                   ; ‡¡slo disku
         mov       ah,bit3+bit4+bit5        ; v¨echna okna
         call      far ptr ModWDisk         ; aktualizace oken
         call      far ptr SetVol           ; nastaven¡ jm‚na disku

;; ------ aktualizace n vˆ¨t¡ v oknech
;
;;         pushf
;         mov       ax,ds:[SegmAkt]          ; aktivn¡ okno
;         call      LabsA                    ; obnoven¡ n vˆ¨t¡ disku
;         mov       ax,ds:[SegmNAkt]         ; neaktivn¡ okno
;         call      LabsA                    ; obnoven¡ n vˆ¨t¡ disku
;;         popf
;
;; ------ chyba nastaven¡ n vˆ¨t¡
;
;Labs8:   jnc       Labs82                   ; operace OK
;         call      far ptr TestBreak        ; p©eru¨en¡ operace ?
;         jc        Labs82                   ; p©eru¨en¡ operace
;
;
;
;Labs82:
         call      far ptr InfoClos         ; uzav©en¡ hl ¨en¡
         call      far ptr DispAll          ; nov‚ zobrazen¡
Labs9:   jmp       far ptr Main0

Labs     ENDP

;; -----------------------------------------------------------------------------
;;        na‡ten¡ n vˆ¨t¡ okna AX
;; -----------------------------------------------------------------------------
;
;LabsA:   call      far ptr GetDat           ; adresa okna
;         jc        LabsA2
;         mov       al,es:[AWinDir]          ; disk okna
;         cmp       al,ds:[LabsMnT4]         ; je to pracovn¡ disk ?
;         jne       LabsA2                   ; nen¡ to pracovn¡ disk
;         mov       di,AWinLab               ; n vˆ¨t¡ disku
;         sub       al,"A"
;         call      far ptr GetVol           ; poskytnut¡ n vˆ¨t¡ disku
;         mov       es:[AWinLabN],cl         ; d‚lka n vˆ¨t¡
;
;LabsA2:  ret

; *****************************************************************************
;
;                          Form tov n¡ disket
;
; *****************************************************************************
;þ
; Doplnit - po ukon‡en¡ form tov n¡ na‡¡st cokoliv z diskety, aby se aktualizovaly
;           informace DOS (jedn  se p©edev¨¡m o p©eform tov n¡ na jin˜ form t
;           diskety - p©i n sledn‚m z pisu pomoc¡ DISKFILE byly informace neplatn‚
;           a byl hl ¨en chybn˜ form t)

Format   LABEL     FAR

         add       sp,4                     ; zru¨en¡ n vratov‚ adresy
         call      far ptr ClosMnuA         ; uzav©en¡ v¨ech menu

FormatF  LABEL     FAR

; ------ test, zda je blokov no form tov n¡ disket

         test      byte ptr ds:[DMnuVBlk+2],bit0 ; je z kaz form tov n¡ disket ?
         jnz       Format08                 ; je z kaz form tov n¡ disket

; ------ vytvo©en¡ bufferu mapy chyb

         call      far ptr CreatSeg         ; vytvo©en¡ segmentu
         jc        Format07                 ; chyba
         mov       ds:[FormESeg],ax         ; segment mapy
         mov       bx,2*100*50/8            ; velikost bufferu
         call      far ptr ModiSegS         ; nastaven¡ velikosti segmentu
         jnc       Format09                 ; operace OK
Format07:call      far ptr MemErr           ; chybov‚ hl ¨en¡
Format08:jmp       Format9

; ------ vytvo©en¡ bufferu pro z pisov‚ a form tovac¡ operace

Format09:call      far ptr CreatSeg         ; vytvo©en¡ segmentu
         jc        Format07                 ; chyba
         mov       ds:[FormWSeg],ax         ; segment pro z pis
         mov       bx,2*512 + 32            ; velikost pro 2 sektory + p©ete‡en¡
         call      far ptr ModiSegS         ; vytvo©en¡ bufferu z pisu
         jc        Format07                 ; chyba

;; ------ test platnosti disku A:
;
;         and       byte ptr ds:[FrmDMBlk],not bit1 ; disk A: povolen
;         mov       bl,0                     ; mechanika A:
;         call      FIniDTyp                 ; detekce mechaniky A:
;         jnc       Format10                 ; disk A: platn˜
;         or        byte ptr ds:[FrmDMBlk],bit1 ; z kaz disku A:
;
;; ------ test platnosti disku B:
;
;Format10:and       byte ptr ds:[FrmDMBlk+1],not bit1 ; disk B: povolen
;         mov       bl,1                     ; mechanika B:
;         call      FIniDTyp                 ; detekce mechaniky B:
;         jnc       Format11                 ; disk B: platn˜
;         or        byte ptr ds:[FrmDMBlk+1],bit1 ; z kaz disku B:

; ------ volba mechaniky k form tov n¡ -> BL

Format11:mov       si,offset FrmDMnu        ; menu volby mechaniky
         call      far ptr LinPMenu         ; volba mechaniky k form tov n¡
         jc        Format08                 ; p©eru¨en¡ operace
         dec       bx                       ; zvolen  polo‘ka
         mov       ds:[FAktDisk],bl         ; zvolen˜ aktivn¡ disk
         mov       al,"A"
         add       al,bl                    ; ozna‡en¡ mechaniky
         mov       ds:[FrmD2MnT+6],al       ; ozna‡en¡ mechaniky
         mov       ds:[FrmD3MP2],al         ; ozna‡en¡ mechaniky

; ------ p©¡prava typu mechaniky (BL=zvolen˜ aktivn¡ disk)

         call      FIniDTyp                 ; p©¡prava typu mechaniky BL -> AL

; ------ p©¡prava menu volby form tu

         call      FPrepFrm                 ; p©¡prava menu volby form tu

; ------ volba po‘adovan‚ho form tu

Format18:mov       si,offset FrmD2Mnu       ; menu volby form tu
         call      far ptr CentMenu         ; vyst©edˆn¡ menu
         call      far ptr VertMenu         ; volba form tu
         jmp       short Format11           ; n vrat p©i p©eru¨en¡ volby

; ------ provedena volba: uzav©en¡ menu

Format2: add       sp,4                     ; zru¨en¡ n vratov‚ adresy
         call      far ptr ClosMnuA         ; uzav©en¡ okna menu

; ------ na‡ten¡ parametr– pro zvolen˜ form t

         mov       al,MAXFORM*3 + 1         ; velikost jednoho popisova‡e
         mul       byte ptr ds:[FTypDisk]   ; offset v tabulce
         add       ax,offset FormTab - MAXFORM*3 - 1*3 ; adresa za‡ tku tabulky
         mov       bx,ds:[si+MnuAkt]        ; zvolen˜ form t
         add       ax,bx
         add       ax,bx
         add       ax,bx                    ; adresa zvolen‚ho form tu
         xchg      ax,si                    ; SI <- adresa zvolen‚ho form tu
         call      FGetParm                 ; na‡ten¡ parametr– z DS:SI

; ------ odvozen‚ parametry

         call      FIniParm                 ; inicializace (odvozen¡) parametr–

; ------ dek¢dov n¡ parametr– pro hl ¨en¡

         call      FDekParm                 ; dek¢dov n¡ parametr– pro hl ¨en¡

; ------ potvrzen¡ operace form tov n¡ diskety

Format3: mov       si,offset FrmD3Mnu       ; menu potvrzen¡ operace
         call      FrmD3Pre                 ; p©¡prava p©ep¡na‡– pro menu
         call      far ptr Lin0MenF         ; potvrzen¡ operace
         jc        Format18                 ; n vrat k volbˆ form tu

; ------ zad n¡ jm‚na disku

Format4: call      FZadVol                  ; zad n¡ jm‚na disku
         jc        Format3                  ; p©eru¨en¡ zad n¡

; ------ vymaz n¡ bufferu mapy chyb

         call      FNulErr                  ; nulov n¡ tabulky chyb

; ------ inicializace ukazatel–

         xor       ax,ax
         mov       ds:[FStopAkt],al         ; aktu ln¡ stopa
         mov       ds:[FStrnAkt],al         ; aktu ln¡ strana
         mov       ds:[FStopIni],al         ; p©¡¨t¡ inicializovan  stopa
         mov       ds:[FStrnIni],al         ; p©¡¨t¡ inicializovan  strana
         mov       ds:[FOper],al            ; aktu ln¡ operace
         mov       ds:[FSlidErr],ax         ; rotace pro sn¡‘en¡ chyb
         mov       word ptr ds:[FormMPl2],1 + "0"*HI ; vadn˜ch dat
         and       byte ptr ds:[FormParm],not bit6+bit7 ; nebyla chyba

; ------ p©¡prava s‚riov‚ho ‡¡sla diskety

         call      FSetSer                  ; nastaven¡ s‚riov‚ho ‡¡sla diskety

; ------ aktualizace oken

         mov       al,ds:[FAktDisk]         ; pou‘it˜ disk
         mov       ah,bit3+bit4+bit5        ; v¨echny typy oken
         call      far ptr ModWDisk         ; aktualizace oken

; ------ otev©en¡ okna form tov n¡

         mov       si,offset FormMnu        ; okno form tov n¡
         call      far ptr OpenMnu          ; otev©en¡ okna form tov n¡

; ------ hl ¨en¡, ‘e prob¡h  form tov n¡

         mov       si,offset FormPTxt       ; text hl ¨en¡
         call      far ptr InfDisp0         ; zobrazen¡ hl ¨en¡

; ------ instalace tabulky INT 1Eh

         call      far ptr NulBreak         ; nulov n¡ p©¡znaku p©eru¨en¡
         call      Inst1E                   ; instalace tabulky INT 1Eh

; ------ rozbˆh motoru

         xor       bx,bx                    ; BX <- 0
         mov       es,bx                    ; ES <- 0
         mov       ax,401h                  ; slu‘ba verifikace 1 sektoru
         mov       cx,1                     ; sektor 1, stopa 0
         mov       dh,0                     ; strana 0
         call      Int13                    ; verifikace pro rozto‡en¡ mechaniky
         call      FResDisk                 ; resetov n¡ disku p©i chybˆ

; ------ nastaven¡ form tu disku

         call      FSetForm                 ; nastaven¡ form tu disku

; ------ test, zda je p©eru¨en¡ operace

Format5: call      far ptr DarkNul          ; nulov n¡ stm¡va‡e
         call      far ptr MousBrea         ; test p©eru¨en¡ my¨¡/kl vesnic¡
;         call      far ptr TestBEsc         ; je p©eru¨en¡ operace ?
         jnc       Format51                 ; nen¡ p©eru¨en¡ operace
         jmp       Format6                  ; konec form tov n¡

; ------ form tov n¡ aktivn¡ stopy

Format51:and       byte ptr ds:[FormParm],not bit4 ; nebyl testovac¡ z pis
         call      FFormat                  ; form tov n¡ aktivn¡ stopy
         jc        Format52                 ; chyba

; ------ verifikace aktivn¡ stopy

         cmp       word ptr ds:[FStopAkt],0 ; je stopa 0/strana 0 ?
         je        Forma512                 ; verifikace je v‘dy
         test      byte ptr ds:[FormParm],bit1 ; prov d¡ se verifikace ?
         jz        Format57                 ; verifikace se neprov d¡
Forma512:call      far ptr MousBrea         ; obsluha p©eru¨en¡ my¨¡/kl vesnic¡
         call      FVerify0                 ; verifikace aktu ln¡ stopy
         jnc       Format57                 ; operace OK

; ------ p©i chybˆ resetov n¡ disku

Format52:call      FResDisk                 ; resetov n¡ disku

; ------ druh˜ pokus o zform tov n¡ stopy

         call      far ptr MousBrea         ; obsluha p©eru¨en¡ my¨¡/kl vesnic¡
         call      FFormat                  ; form tov n¡ aktivn¡ stopy
         jc        Format54                 ; chyba

; ------ 2 x verifikace stopy, zda je ji‘ v po© dku

         call      far ptr MousBrea         ; obsluha p©eru¨en¡ my¨¡/kl vesnic¡
         call      FVerify0                 ; verifikace aktu ln¡ stopy
         jc        Format54                 ; chyba
         call      FResDisk                 ; resetov n¡ disku
         call      FVerify0                 ; verifikace aktu ln¡ stopy
         jnc       Format57                 ; je to ji‘ OK

; ------ detekce vadn˜ch sektor–

Format54:or        ah,ah                    ; disk nep©ipraven ?
         js        Format7                  ; chyba - disk nep©ipraven
         cmp       ah,3                     ; je ochrana proti z pisu ?
         je        Format64                 ; je ochrana proti z pisu
         call      FVerBad                  ; detekce vadn˜ch sektor–

; ------ obsluha chyb v syst‚mov‚ oblasti

         test      byte ptr ds:[FormParm],bit6 ; chyba v syst‚mov‚ oblasti ?
         jz        Format57                 ; nebyla chyba
         and       byte ptr ds:[FormParm],not bit6 ; nulov n¡ syst‚mov‚ chyby
         mov       al,byte ptr ds:[FSlidErr] ; rotace syst‚mov˜ch chyb
         cmp       al,ds:[FSekt]            ; je ji‘ maxim ln¡ rotace ?
         jae       Format56                 ; je ji‘ maxim ln¡ rotace
         inc       byte ptr ds:[FSlidErr]   ; rotace stopy 0
         call      FNulErr                  ; vynulov n¡ tabulky chyb
         call      FIniVad                  ; inicializace hl ¨en¡ o chybˆ
         jmp       Format5                  ; dal¨¡ pokus o form tov n¡

; ------ hl ¨en¡ - chyba v syst‚mov‚ oblasti

Format56:mov       si,offset FrmSYMnu       ; hl ¨en¡-chyba v syst‚mov‚ oblasti
         jmp       short Format72           ; hl ¨en¡ chyby

; ------ testovac¡ z pis

Format57:call      FTest                    ; testovac¡ z pis
         jc        Format52                 ; chyba

; ------ zv˜¨en¡ ‡¡sla strany

Format58:inc       byte ptr ds:[FStrnAkt]   ; zv˜¨en¡ aktu ln¡ strany
         mov       al,ds:[FStrnAkt]         ; aktu ln¡ strana
         mov       ds:[FStrnIni],al         ; je to p©¡¨t¡ inicializovan  strana
         cmp       al,ds:[FStran]           ; je ‡¡slo strany OK ?
         jb        Format59                 ; ‡¡slo strany je OK
         mov       byte ptr ds:[FStrnAkt],0 ; posun ‡¡sla strany
         mov       byte ptr ds:[FStrnIni],0

; ------ zv˜¨en¡ ‡¡sla stopy

         inc       byte ptr ds:[FStopAkt]   ; zv˜¨en¡ aktu ln¡ stopy
         mov       al,ds:[FStopAkt]         ; aktu ln¡ stopa
         mov       ds:[FStopIni],al         ; je to p©¡¨t¡ inicializovan  stopa
         cmp       al,ds:[FStop]            ; je ‡¡slo stopy OK ?
         jae       Format6                  ; jsou ji‘ v¨echny stopy
Format59:jmp       Format5                  ; dal¨¡ stopa

; ------ konec form tov n¡ - z pis syst‚mov˜ch dat

Format6: call      FZapSys                  ; z pis syst‚mov˜ch dat na disk
         jmp       short Format8

; ------ chyba - ochrana proti z pisu

Format64:mov       si,offset FrmWPMnu       ; ochrana proti z pisu
         jmp       short Format72

; ------ chyba - disk nep©ipraven

Format7: mov       si,offset FrmRdyMn
Format72:call      far ptr Lin0MenF         ; chybov‚ hl ¨en¡

; ------ n vrat tabulky INT 1Eh

Format8: call      DeInst1E                 ; odinstalov n¡ tabulky INT 1Eh

; ------ vypnut¡ motoru mechaniky

         mov       bx,40h
         mov       es,bx                    ; ES <- segment BIOS
         mov       byte ptr es:[bx],1       ; motor bude brzo vypnut

; ------ obnoven¡ zobrazen¡ okna

         call      far ptr InfoClos         ; uzav©en¡ informa‡n¡ho © dku
         call      far ptr DispAll          ; nov‚ zobrazen¡ v¨eho

; ------ inkrementace jmenovky disku, inidikace konce form tov n¡

         call      far ptr TestBEsc         ; bylo p©eru¨en¡ operace ?
         jc        Format84                 ; bylo p©ed‡asn‚ p©eru¨en¡
         call      FIncVol                  ; inkrementace jm‚na disku
         test      byte ptr ds:[FormParm],bit2 ; je indikace konce ?
         jz        Format84                 ; nen¡ indikace konce
         push      ds
         pop       es                       ; ES <- datov˜ segment
         mov       si,offset FMelod         ; melodie p©i ukon‡en¡ form tov n¡
         call      far ptr PlayMus          ; zahr n¡ melodie
Format84:call      far ptr NulBreak         ; nulov n¡ p©¡znaku p©eru¨en¡

; ------ ‡ek n¡ na stisk kl vesy

         call      far ptr FlushChr         ; vypr zdnˆn¡ bufferu kl vesnice
Format85:call      far ptr InpChar          ; ‡ek n¡ na stisk kl vesy
         cmp       bh,MousXKod/HI           ; je k¢d my¨i ?
         jne       Format87                 ; nen¡ k¢d my¨i
         cmp       bl,MousXRP               ; stisk prav‚ho tla‡¡tka my¨i ?
         je        Format87                 ; p©eru¨en¡ stiskem prav‚ho tla‡¡tka
         cmp       bl,MousXLD               ; dvoj¡ stisk lev‚ho tla‡¡tka ?
         jne       Format85                 ; k¢d neplat¡
         mov       bl,13                    ; n hrada kl vesou ENTER
Format87:call      far ptr ClosMnu          ; uzav©en¡ okna form tov n¡

         cmp       bl,13                    ; je ENTER ?
         je        Format86                 ; je ENTER
         jmp       Format3                  ; jinak nov‚ potvrzen¡

Format86:jmp       Format4                  ; opakov n¡ form tov n¡

; ------ konec

Format9: call      far ptr ClosMnu          ; uzav©en¡ okna

         mov       ax,ds:[FormESeg]         ; segment mapy chyb
         call      far ptr DelSeg           ; zru¨en¡ segmentu
         mov       ds:[FormESeg],ax

         mov       ax,ds:[FormWSeg]         ; z pisov˜ segment
         call      far ptr DelSeg           ; zru¨en¡ segmentu
         mov       ds:[FormWSeg],ax

         jmp       far ptr Main0

; -----------------------------------------------------------------------------
;        testovac¡ z pis (CY=chyba)
; -----------------------------------------------------------------------------

FTest    PROC      NEAR

         test      byte ptr ds:[FormParm],bit3 ; je testovac¡ z pis ?
         jz        FTest2                   ; nen¡ testovac¡ z pis
         test      byte ptr ds:[FormParm],bit4 ; byl ji‘ testovac¡ z pis ?
         jnz       FTest2                   ; byl ji‘ testovac¡ z pis
         or        byte ptr ds:[FormParm],bit4 ; p©¡znak testovac¡ho z pisu

         call      far ptr MousBrea         ; obsluha p©eru¨en¡ my¨¡/kl vesnic¡
         call      FWritTst                 ; testovac¡ z pis
         jc        FTest2                   ; nov˜ pokus o form tov n¡
         call      FVerify0                 ; verifikace aktu ln¡ stopy
         jc        FTest2                   ; chyba

         call      far ptr MousBrea         ; obsluha p©eru¨en¡ my¨¡/kl vesnic¡
         call      FWritNul                 ; nulovac¡ z pis
         jc        FTest2                   ; chyba
         call      FVerify0                 ; verifikace aktu ln¡ stopy
FTest2:  ret

FTest    ENDP

; -----------------------------------------------------------------------------
;        zad n¡ jm‚na disku
; -----------------------------------------------------------------------------

FZadVol  PROC      NEAR

         and       byte ptr ds:[FormParm],not bit5 ; nezad no jm‚no disku
         mov       word ptr ds:[FormMPl5],offset FormMPl6 ; nen¡ jm‚no disku
         test      byte ptr ds:[FormParm],bit0 ; zad v  se jm‚no disku ?
         jz        FZadVol8                 ; jm‚no disku se nezad v 

         mov       byte ptr ds:[FLabMnPN],0 ; nen¡ p©edvolba
         mov       al,ds:[FormMPL3]         ; d‚lka jm‚na disku
         or        al,al                    ; bylo ji‘ nˆco zad no ?
         jz        FZadVol2                 ; nebylo je¨tˆ nic zad no
         inc       byte ptr ds:[FLabMnPN]   ; je 1 p©edvolba
         mov       byte ptr ds:[FLabMnPD],al ; d‚lka p©edvolby

FZadVol2:mov       si,offset FLabMnu        ; menu zad n¡ jm‚na disku
         call      far ptr Lin0Menu         ; zad n¡ jm‚na disku
         jc        FZadVol9                 ; p©eru¨en¡ operace

         mov       ch,0
         mov       cl,ds:[LinNum]           ; po‡et zadan˜ch znak–
         jcxz      FZadVol8                 ; nebylo nic zad no
         or        byte ptr ds:[FormParm],bit5 ; jm‚no disku zad no
         mov       di,offset FormMPl3       ; buffer k ulo‘en¡ jm‚na disku
         mov       ds:[FormMPl5],di         ; zadan‚ jm‚no disku
         mov       ds:[di],cl               ; d‚lka zadan‚ho jm‚na disku
         inc       di                       ; za‡ tek bufferu
         push      ds
         pop       es                       ; ES <- datov˜ segment
         mov       si,offset LinBuff        ; buffer zadan‚ho textu
         cld
         mov       bl,11                    ; d‚lka bufferu jm‚na
         sub       bl,cl                    ; zbytek
FZadVol4:lodsb
         call      far ptr UpCase           ; konverze na velk‚ p¡smeno
         stosb                              ; ulo‘en¡ znaku
         loop      FZadVol4                 ; dal¨¡ znak

         mov       cl,bl                    ; CL <- po‡et zbyl˜ch znak–
         mov       al," "                   ; mazac¡ znak mezery
         rep       stosb                    ; vymaz n¡ zbytku bufferu
FZadVol8:clc                                ; p©¡znak zad n¡ OK
FZadVol9:ret

FZadVol  ENDP

; -----------------------------------------------------------------------------
;        inkrementace jm‚na disku
; -----------------------------------------------------------------------------

FIncVol  PROC      NEAR

         test      byte ptr ds:[FormParm],bit5 ; bylo zad no jm‚no disku ?
         jz        FIncVol9                 ; jm‚no disku nebylo zad no

         mov       si,offset FormMPl3+11    ; konec bufferu jm‚na disku
         mov       cx,11                    ; max. po‡et znak–
FIncVol1:cmp       byte ptr ds:[si],"0"     ; je to ‡¡slice ?
         jb        FIncVol8                 ; nen¡ to ‡¡slice
         cmp       byte ptr ds:[si],"9"
         ja        FIncVol8                 ; nen¡ to ‡¡slice
         inc       byte ptr ds:[si]         ; zv˜¨en¡ ‡¡slice
         cmp       byte ptr ds:[si],"9"     ; je to je¨tˆ platn  ‡¡slice ?
         jbe       FIncVol9                 ; je to je¨tˆ platn  ‡¡slice OK
         mov       byte ptr ds:[si],"0"     ; p©ete‡en¡
FIncVol8:dec       si                       ; sn¡‘en¡ ukazatele v bufferu
         loop      FIncVol1                 ; dal¨¡ znak v bufferu
FIncVol9:ret

FIncVol  ENDP

; -----------------------------------------------------------------------------
;        nulov n¡ tabulky chyb
; -----------------------------------------------------------------------------

FNulErr  PROC      NEAR

         push      ax
         push      cx
         push      di
         push      es

         mov       ax,ds:[FSektN]           ; po‡et sektor– celkem
         add       ax,7                     ; zaokrouhlen¡ nahoru
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; p©epo‡et na bajty
         xchg      ax,cx                    ; CX <- d‚lka mapy v bajtech
         mov       ax,ds:[FormESeg]         ; segment mapy chyb
         call      far ptr GetDat           ; adresa mapy -> ES
         xor       di,di                    ; DI <- po‡ tek mapy
         xor       ax,ax                    ; AX <- nulovac¡ bajt
         cld
         rep       stosb                    ; vymaz n¡ bufferu mapy chyb

         pop       es
         pop       di
         pop       cx
         pop       ax
         ret

FNulErr  ENDP

; -----------------------------------------------------------------------------
;        p©¡prava s‚riov‚ho ‡¡sla
; -----------------------------------------------------------------------------

FSetSer  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      di
         push      es

; ------ stanoven¡ syst‚mov‚ho data

         mov       ah,2ah
         int       21h                      ; poskytnut¡ syst‚mov‚ho data
         push      cx                       ; rok
         push      dx                       ; mˆs¡c a den

; ------ stanoven¡ syst‚mov‚ho ‡asu

         mov       ah,2ch
         int       21h                      ; poskytnut¡ syst‚mov‚ho ‡asu

; ------ nastaven¡ s‚riov‚ho ‡¡sla HIGH

         pop       ax                       ; mˆs¡c a den
         add       ax,dx                    ; mˆs¡c/den + sekundy/setiny
         mov       word ptr cs:[BootSerN+2],ax ; s‚riov‚ ‡¡slo HIGH

; ------ nastaven¡ s‚riov‚ho ‡¡sla LOW

         pop       ax                       ; rok
         add       ax,cx                    ; rok + minuta/hodina
         mov       word ptr cs:[BootSerN],ax ; s‚riov‚ ‡¡slo LOW

; ------ dek¢dov n¡ s‚riov‚ho ‡¡sla do bufferu pro hl ¨en¡

         mov       bh,0                     ; neukl d  se barva
         mov       di,offset FormMPl4+5     ; s‚riov‚ ‡¡slo LOW
         call      far ptr DekHWord         ; dek¢dov n¡ ‡¡sla LOW
         mov       di,offset FormMPl4       ; s‚riov‚ ‡¡slo HIGH
         mov       ax,word ptr cs:[BootSerN+2] ; s‚riov‚ ‡¡slo HIGH
         call      far ptr DekHWord         ; dek¢dov n¡ ‡¡sla HIGH

; ------ n vrat registr–

         pop       es
         pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

FSetSer  ENDP

; -----------------------------------------------------------------------------
;        zmˆna p©ep¡na‡– z menu volby
; -----------------------------------------------------------------------------

FrmD3Ex2:mov       al,bit0                  ; p©ep¡na‡ "Jm‚no"
         jmp       short FrmD3Ex6

FrmD3Ex3:mov       al,bit1                  ; p©ep¡na‡ "Verifikace"
         jmp       short FrmD3Ex6

FrmD3Ex4:mov       al,bit2                  ; p©ep¡na‡ "Indikace"
         jmp       short FrmD3Ex6

FrmD3Ex5 PROC      FAR

         mov       al,bit3                  ; p©ep¡na‡ "Z pis"
FrmD3Ex6:xor       byte ptr ds:[FormParm],al ; zmˆna p©ep¡na‡e
         call      FrmD3Pre                 ; p©¡prava p©ep¡na‡–
         call      far ptr DispMnu          ; nov‚ zobrazen¡ menu
         ret

FrmD3Ex5 ENDP

; -----------------------------------------------------------------------------
;        p©¡prava p©ep¡na‡– pro menu potvrzen¡ operace DS:SI
; -----------------------------------------------------------------------------

FrmD3Pre PROC      NEAR

         push      dx
         push      di

         mov       dh,bit0                  ; maska pro jm‚no disku
         mov       di,offset FrmD3MS1       ; znak p©ep¡na‡e "Jm‚no"
         call      FrmD30Pr                 ; nastaven¡ p©ep¡na‡e

         mov       di,offset FrmD3MS2       ; znak p©ep¡na‡e "Verifikace"
         call      FrmD30Pr                 ; nastaven¡ p©ep¡na‡e

         mov       di,offset FrmD3MS3       ; znak p©ep¡na‡e "Indikace"
         call      FrmD30Pr                 ; nastaven¡ p©ep¡na‡e

         mov       di,offset FrmD3MS4       ; znak p©ep¡na‡e "Z pis"
         call      FrmD30Pr                 ; nastaven¡ p©ep¡na‡e

         mov       dl,ds:[FormParm]         ; parametry
         call      far ptr SetSwch          ; nov‚ nastaven¡ p©ep¡na‡–

         pop       di
         pop       dx
         ret

FrmD3Pre ENDP

FrmD30Pr:mov       dl,ds:[ZnakSwch]         ; znak pro zapnut˜ p©ep¡na‡
         test      byte ptr ds:[FormParm],dh ; je p©ep¡na‡ zapnut˜ ?
         jnz       FrmD30P2                 ; p©ep¡na‡ je zapnut˜
         mov       dl,ds:[ZnakSwch+1]       ; znak pro vypnut˜ p©ep¡na‡
FrmD30P2:mov       ds:[di],dl               ; znak p©ep¡na‡e
         shl       dh,1                     ; posun masky
         ret

; -----------------------------------------------------------------------------
;        p©¡prava menu pro volbu form tu
; -----------------------------------------------------------------------------

FPrepFrm PROC      NEAR

; ------ adresa tabulky form t–

         mov       al,MAXFORM*3 + 1         ; velikost jednoho popisova‡e
         mul       byte ptr ds:[FTypDisk]   ; offset v tabulce
         add       ax,offset FormTab - MAXFORM*3
         xchg      ax,si                    ; SI <- ukazatel definice form t–
         mov       ch,0
         mov       cl,ds:[si-1]             ; CL <- po‡et form t– v tabulce

; ------ p©¡prava parametr– menu

         mov       ax,cx                    ; AX <- po‡et form t–
         mov       byte ptr ds:[FrmD2Mnu+MnuAkt],1 ; aktivn¡ polo‘ka menu
         mov       word ptr ds:[FrmD2Mnu+MnuNum],ax ; po‡et platn˜ch polo‘ek
         mov       word ptr ds:[FrmD2Mnu+MnuSum],ax ; celkov˜ po‡et polo‘ek menu
         inc       ax
         inc       ax
         mov       ds:[FrmD2Mnu+MnuVys],al ; v˜¨ka menu

; ------ ozna‡en¡ nestandardn¡ho form tu

         mov       di,offset FrmD2MnP+6
FPrepFr2:mov       ax,ds:[si]               ; AL <- stop, AH <- sektor–/stopu
         mov       byte ptr ds:[di-1]," "   ; standardn¡ format
         or        al,al                    ; je nestandardn¡ form t ?
         jns       FPrepFr4                 ; standardn¡ form t
         mov       byte ptr ds:[di-1],"*"   ; nestandardn¡ form t

; ------ typ diskety DD/HD/QD

FPrepFr4:and       ax,7f7fh
         mov       byte ptr ds:[di+8],"D"   ; diskety DD
         cmp       ah,13                    ; disketa DD ?
         jbe       FPrepFr6                 ; je disketa DD
         mov       byte ptr ds:[di+8],"H"   ; disketa HD
         cmp       ah,22                    ; disketa HD ?
         jbe       FPrepFr6                 ; disketa HD
         mov       byte ptr ds:[di+8],"Q"   ; disketa QD

; ------ dek¢dov n¡ velikosti diskety

FPrepFr6:mul       ah                       ; po‡et sektor– * po‡et stop
         test      byte ptr ds:[si+1],bit7  ; je 1 strana ?
         jnz       FPrepFr8                 ; je 1 strana
         shl       ax,1                     ; jsou 2 strany
FPrepFr8:mov       dx,512                   ; po‡et bajt– na sektor
         mul       dx                       ; kapacita v bajtech
         call      RghDSize                 ; dek¢dov n¡ kapacity do bufferu
         mov       al,ds:[di+6]             ; ozna‡en¡ "K" nebo "M"
         mov       ds:[di+5],al
         mov       word ptr ds:[di+6],"  "  ; nulov n¡ star‚ho ozna‡en¡ KB, MB

; ------ dal¨¡ form t

         add       di,16                    ; dal¨¡ polo‘ka v menu
         add       si,3                     ; dal¨¡ popisova‡ form tu
         loop      FPrepFr2
         ret

FPrepFrm ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ parametr– z polo‘ky DS:SI
; -----------------------------------------------------------------------------

FGetParm PROC      NEAR

         cld
         lodsb                              ; po‡et v lc–
         and       al,7fh
         mov       ds:[FStop],al            ; po‡et v lc–
         lodsb                              ; po‡et sektor– a po‡et stran
         mov       byte ptr ds:[FStran],2   ; jsou 2 strany
         or        al,al                    ; je 1 strana ?
         jns       FGetPrm2                 ; jsou 2 strany
         dec       byte ptr ds:[FStran]     ; je 1 strana
         and       al,7fh                   ; po‡et sektor– na stopu
FGetPrm2:mov       ds:[FSekt],al            ; po‡et sektor– na stopu
         lodsb                              ; po‡et sektor– na ROOT a blok
         mov       ah,al
         and       al,bit0+bit1+bit2+bit3+bit4 ; platn‚ bity
         inc       ax                       ; oprava
         mov       byte ptr ds:[FRoot],al   ; po‡et sektor– na ROOT
         mov       cl,5
         shr       ah,cl                    ; mocnina velikosti bloku
         mov       cl,ah
         mov       al,bit0                  ; maska
         shl       al,cl
         mov       ds:[FBlok],al            ; po‡et sektor– na blok
         ret

FGetParm ENDP

; -----------------------------------------------------------------------------
;        inicializace (odvozen¡) parametr– form tov n¡
; -----------------------------------------------------------------------------

FIniParm PROC      NEAR

FIniPrm0:mov       bl,ds:[FTypDisk]         ; typ mechaniky

; ------ po‡et polo‘ek ROOT

         mov       ax,ds:[FRoot]            ; po‡et sektor– ROOT
         mov       cl,4
         shl       ax,cl                    ; p©epo‡et na polo‘ky ROOT
         mov       ds:[FRootN],ax           ; po‡et polo‘ek ROOT

; ------ celkov˜ po‡et sektor– m‚dia

         mov       al,ds:[FSekt]            ; po‡et sektor– na stopu
         mul       byte ptr ds:[FStran]     ; po‡et sektor– na v lec
         mul       byte ptr ds:[FStop]      ; po‡et sektor– celkem
         mov       ds:[FSektN],ax           ; celkov˜ po‡et sektor– disku

; ------ po‡et bajt– na aloka‡n¡ blok

         mov       al,0
         mov       ah,ds:[FBlok]            ; AH <- po‡et sektor– na blok
         shl       ax,1                     ; po‡et bajt– na aloka‡n¡ blok
         mov       ds:[FBlokB],ax           ; po‡et bajt– na aloka‡n¡ blok

; ------ krokov n¡ (BL=typ mechaniky)

         mov       byte ptr ds:[FKrok],1    ; krokov n¡ po 1 stopˆ
         cmp       bl,M360                  ; je mechanika 360 KB ?
         je        FIniPrm1                 ; je jednoduch‚ krokov n¡
         cmp       byte ptr ds:[FStop],46   ; je m lo stop ?
         jae       FIniPrm1                 ; je dost stop
         inc       byte ptr ds:[FKrok]      ; krokov n¡ po 2 stop ch

; ------ p©enosov  rychlost (BL=typ mechaniky)

FIniPrm1:mov       al,ds:[FSekt]            ; po‡et sektor– na stopu
         mov       ah,R1000                 ; rychlost pro QD diskety
         cmp       al,22                    ; je disketa QD ?
         ja        FIniPrm2                 ; je disketa QD
         mov       ah,R500                  ; rychlost pro HD diskety
         cmp       al,13                    ; je disketa HD ?
         ja        FIniPrm2                 ; je disketa HD
         mov       ah,R300                  ; rychlost pro DD v mechanice 1.2 MB
         cmp       bl,M120                  ; je mechanika 1.2 MB ?
         je        FIniPrm2                 ; je mechanika 1.2 MB
         cmp       al,11                    ; je 11 a‘ 13 sektor– ?
         jae       FIniPrm2                 ; pro 11 a‘ 13 sektor– rychlost 300
         mov       ah,R250                  ; jinak rychlost 250
FIniPrm2:mov       ds:[FRate],ah            ; p©enosov  rychlost

; ------ mezisektorov  mezera (AH=p©enosov  rychlost, BL=typ mechaniky)

         mov       al,ah                    ; AL <- p©enosov  rychlost
         mov       ah,0
         shl       ax,1
         shl       ax,1
         xchg      ax,si                    ; SI <- offset v tabulce rychlost¡
         mov       ax,word ptr ds:[si+RateTab]   ; p©enosov  rychlost (Bajt–/s)
         mov       dx,word ptr ds:[si+RateTab+2]
         mov       cx,5                     ; 5 ot ‡ek za sekundu
         cmp       bl,M120                  ; je mechanika 1.2 MB ?
         jne       FIniPrm3                 ; nen¡ mechanika 1.2 MB
         inc       cx                       ; pro mechaniku 1.2 MB je 6 ot ‡ek
FIniPrm3:div       cx                       ; v˜po‡et po‡tu bajt– na stopu
         xor       dx,dx                    ; DX <- 0
         mov       cl,ds:[FSekt]            ; CX <- po‡et sektor– na stopu
         div       cx                       ; po‡et bajt– na sektor
         sub       ax,512+62                ; zbytek na mezeru
         jae       FIniPr32                 ; je to OK
         xor       ax,ax                    ; minim ln¡ mezera
FIniPr32:sub       ax,40                    ; tady bude zlom neline rn¡ korekce
         jb        FIniPr34                 ; nen¡ za zlomem
         shr       ax,1                     ; zm¡rnˆn¡ p©¡rustku
FIniPr34:add       ax,40                    ; navr cen¡ zlomu
         jnz       FIniPr36                 ; je ‡¡slo <> 0
         inc       ax                       ; minim ln¡ mezera 1
FIniPr36:or        ah,ah                    ; je v¡ce ne‘ 255 bajt– ?
         jz        FIniPr38                 ; je to OK
         mov       al,255                   ; omezen¡ na 255 bajt–
FIniPr38:mov       ds:[FGap],al             ; mezisektorov  mezera

; ------ prokl d n¡ sektor– (AL=mezisektorov  mezera, BL=typ mechaniky)

         mov       ah,42                    ; omezen¡ GAP pro DD
         cmp       byte ptr ds:[FRate],R300 ; je rychlost 300 Kb/s ?
         je        FIniPrm4                 ; je disketa DD
         cmp       byte ptr ds:[FRate],R250 ; je rychlost 250 Kb/s ?
         je        FIniPrm4                 ; je disketa DD
         mov       ah,27                    ; omezen¡ GAP pro HD a QD
FIniPrm4:cmp       al,ah                    ; je nutn‚ prokl d n¡ ?
         mov       al,1                     ; nen¡ prokl d n¡
         jae       FIniPr42                 ; nen¡ nutn‚ prokl d n¡
         inc       ax                       ; bude prokl d n¡ p©es sektor
         shr       byte ptr ds:[FGap],1     ; zmen¨en¡ mezery GAP
         jnz       FIniPr42                 ; je to OK
         inc       byte ptr ds:[FGap]       ; minim lnˆ 1 mezera
FIniPr42:mov       ds:[FInterl],al          ; prokl d n¡ sektor–

; ------ odsazov n¡ mezi stranami SLIDING X

         mov       al,3                     ; odsazen¡ pro diskety QD
         cmp       byte ptr ds:[FRate],R1000 ; je disketa QD ?
         je        FIniPrm5                 ; je disketa QD
         dec       ax                       ; odsazen¡ pro diskety HD
         cmp       byte ptr ds:[FRate],R500 ; je disketa HD ?
         je        FIniPrm5                 ; je disketa HD
         dec       ax                       ; jinak odsazen¡ pro DD
FIniPrm5:mov       ds:[FSlidX],al           ; odsazov n¡ stran

; ------ odsazov n¡ mezi stopami SLIDING Y (AL=odsazov n¡ stran SLIDING X)

         inc       ax                       ; zv˜¨en¡ odsazen¡
         cmp       byte ptr ds:[FStop],46   ; je m lo stop ?
         jae       FIniPrm6                 ; je dost stop
         inc       ax                       ; zv˜¨en¡ odsazov n¡ (vˆt¨¡ krok)
FIniPrm6:mov       ds:[FSlidY],al           ; odsazov n¡ stop

; ------ popisova‡ m‚dia

         cmp       byte ptr ds:[FStop],46   ; je mal˜ po‡et stop ?
         jb        FIniPrm7                 ; je mal˜ po‡et stop
         mov       al,0f9h                  ; mal˜ po‡et sektor–
         cmp       byte ptr ds:[FSekt],16   ; je mal˜ po‡et sektor– ?
         jbe       FIniPr74                 ; je mal˜ po‡et sektor–
         mov       al,0f0h                  ; velk˜ po‡et sektor–
         jmp       short FIniPr74

FIniPrm7:mov       al,0feh                  ; mal˜ po‡et stop i sektor–
         cmp       byte ptr ds:[FSekt],8    ; je mal˜ po‡et sektor– ?
         jbe       FIniPr72                 ; je mal˜ po‡et sektor–
         mov       al,0fch                  ; m lo stop, dost sektor–
FIniPr72:cmp       byte ptr ds:[FStran],1   ; mal˜ po‡et stran ?
         jbe       FIniPr74                 ; je mal˜ po‡et stran
         or        al,bit0                  ; korekce pro 2 strany
FIniPr74:mov       ds:[FMedia],al           ; popisova‡ m‚dia

; ====== n sleduje v˜po‡et tabulek FAT

FIniPrm8:mov       byte ptr ds:[FFat],0     ; v˜choz¡ hodnota - 1 sektor na FAT
         mov       word ptr ds:[FBlokN],0   ; po‡et aloka‡n¡ch blok–

; ------ po‡et aloka‡n¡ch blok–

FIniPr82:inc       byte ptr ds:[FFat]       ; zv˜¨en¡ po‡tu sektor– FAT
         mov       ax,ds:[FSektN]           ; celkov˜ po‡et sektor– disku
         dec       ax                       ; ode‡ten¡ BOOT sektoru
         jz        FIniPr89                 ; chyba
         mov       cx,ds:[FFat]             ; po‡et sektor– na FAT
         sub       ax,cx                    ; ode‡ten¡ sektor– na FAT 1
         jbe       FIniPr89                 ; chyba
         sub       ax,cx                    ; ode‡ten¡ sektor– na FAT 2
         jbe       FIniPr89                 ; chyba
         sub       ax,ds:[FRoot]            ; ode‡ten¡ sektor– na ROOT
         jbe       FIniPr89                 ; chyba
         xor       dx,dx                    ; DX <- 0
         mov       cl,ds:[FBlok]            ; po‡et sektor– na blok
         div       cx                       ; v˜po‡et po‡tu blok–
         mov       ds:[FBlokN],ax           ; celkov˜ po‡et aloka‡n¡ch blok–
         mov       ds:[FZbyva],dl           ; po‡et p©eb˜vaj¡c¡ch sektor–

; ------ celkov  kapacita disku

         mul       word ptr ds:[FBlokB]     ; * po‡et bajt– na blok
         mov       word ptr ds:[FKapac],ax  ; kapacita disku v bajtech
         mov       word ptr ds:[FKapac+2],dx

; ------ v˜po‡et kapacity tabulky FAT (CH=0) -> AX

         mov       ah,byte ptr ds:[FFat]    ; po‡et sektor– na FAT
         mov       al,0
         shl       ax,1                     ; po‡et bajt– na FAT
         shl       ax,1                     ; po‡et tetr d na FAT
         xor       dx,dx                    ; DX <- 0
         mov       cl,3                     ; po‡et tetr d na polo‘ku FAT
         div       cx                       ; v˜po‡et po‡tu polo‘ek FAT
         dec       ax
         dec       ax                       ; ode‡ten¡ rezervovan˜ch hodot

; ------ kontrola, zda je ji‘ po‡et polo‘ek FAT dosta‡uj¡c¡

         cmp       ax,ds:[FBlokN]           ; sta‡¡ ji‘ po‡et polo‘ek FAT ?
         jb        FIniPr82                 ; po‡et polo‘ek FAT nesta‡¡

; ------ kontrola, zda je p©ekro‡en po‡et aloka‡n¡ch blok–

         cmp       word ptr ds:[FBlokN],0ff6h-2 ; p©ekro‡en po‡et blok– ?
         jb        FIniPr89                 ; po‡et blok– je OK
         shl       byte ptr ds:[FBlok],1    ; zv˜¨en¡ velikosti bloku (sektor–)
         shl       word ptr ds:[FBlokB],1   ; zv˜¨en¡ velikosti bloku (bajt–)
         jmp       short FIniPrm8           ; nov˜ v˜po‡et FAT

; ------ po‡ te‡n¡ datov˜ sektor

FIniPr89:mov       ax,ds:[FFat]             ; po‡et sektor– na FAT
         shl       ax,1                     ; po‡et sektor– na obˆ FAT
         inc       ax                       ; p©i‡ten¡ BOOT
         add       ax,ds:[FRoot]            ; p©i‡ten¡ ROOT
         mov       ds:[FData],ax            ; prvn¡ datov˜ sektor

; ------ zaji¨tˆn¡, aby byl alespo¤ 1 datov˜ blok

         cmp       word ptr ds:[FBlokN],1   ; je alespo¤ 1 datov˜ blok ?
         jae       FIniPr99                 ; zad n¡ je OK

         cmp       byte ptr ds:[FSekt],8    ; je ji‘ dost sektor– ?
         jae       FIniPr92                 ; je ji‘ dost sektor–
         inc       byte ptr ds:[FSekt]      ; zv˜¨en¡ po‡tu sektor–
         jmp       short FIniPr94           ; opakov n¡ v˜po‡tu parametr–

FIniPr92:inc       byte ptr ds:[FStop]      ; zv˜¨en¡ po‡tu stop
FIniPr94:jmp       FIniPrm0                 ; opakov n¡ v˜po‡tu parametr–

FIniPr99:ret

FIniParm ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ parametr– pro hl ¨en¡
; -----------------------------------------------------------------------------

FDekParm PROC      NEAR

; ------ celkov  kapacita disku

         push      ds
         pop       es                       ; ES <- datov˜ segment
         mov       di,offset FrmD3MP3+1     ; buffer k dek¢dov n¡ kapacity
         mov       ax,word ptr ds:[FKapac]  ; kapacita disku LOW
         mov       dx,word ptr ds:[FKapac+2] ; kapacita disku HIGH
         mov       bh,0                     ; barva nen¡
         mov       bl,ds:[OddelRad]         ; oddˆlova‡ © d–
         call      far ptr DekNum           ; dek¢dov n¡ ‡¡sla
         sub       di,offset FrmD3MP3+1     ; d‚lka textu
         xchg      ax,di
         mov       ds:[FrmD3MP3],al         ; d‚lka textu

; ------ po‡et stran

         mov       al,ds:[FStran]           ; po‡et stran
         add       al,"0"                   ; korekce na znak ASCII
         mov       ds:[FrmD3MP5],al         ; po‡et stran

; ------ po‡et stop

         mov       di,offset FrmD3Mp7+1     ; buffer po‡tu stop
         mov       al,ds:[FStop]            ; po‡et stop
         call      FDekPB                   ; dek¢dov n¡ po‡tu stop

; ------ po‡et sektor– na stopu

         mov       al,ds:[FSekt]            ; po‡et sektor– na stopu
         call      FDekPB                   ; dek¢dov n¡ po‡tu sektor– na stopu

; ------ dek¢dov n¡ po‡tu polo‘ek ROOT

         mov       ax,ds:[FRootN]           ; po‡et polo‘ek ROOT
         call      FDekPW                   ; dek¢dov n¡ po‡tu polo‘ek ROOT

; ------ dek¢dov n¡ po‡tu sektor– FAT

         mov       al,byte ptr ds:[FFat]    ; po‡et sektor– FAT
         call      FDekPB                   ; dek¢dov n¡ po‡tu sektor– FAT

; ------ dek¢dov n¡ po‡tu sektor– na blok

         mov       al,ds:[FBlok]            ; po‡et sektor– na blok
         call      FDekPB                   ; dek¢dov n¡ po‡tu sektor– na blok

; ------ dek¢dov n¡ po‡tu zbyl˜ch sektor–

         mov       al,ds:[FZbyva]           ; po‡et zbyl˜ch sektor–
         call      FDekPB                   ; dek¢dov n¡ po‡tu zbyl˜ch sektor–

; ------ mezisektorov  mezera

         mov       al,ds:[FGap]             ; mezisektorov  mezera
         call      FDekPB                   ; dek¢dov n¡ mezisektorov‚ mezery

; ------ p©enosov  rychlost

         mov       cl,ds:[FRate]            ; p©enosov  rychlost
         mov       ax,250
         cmp       cl,R250
         je        FDekPrm2
         mov       ax,300
         cmp       cl,R300
         je        FDekPrm2
         mov       ax,500
         cmp       cl,R500
         je        FDekPrm2
         mov       ax,1000
FDekPrm2:call      FDekPW                   ; dek¢dov n¡ p©enosov‚ rychlosti

; ------ prokl d n¡

         mov       al,ds:[FInterl]          ; prokl d n¡ sektor–
         add       al,"0"                   ; korekce na ASCII znak
         mov       ds:[FrmD3M52],al         ; prokl d n¡ sektor–

; ------ krokov n¡

         mov       al,ds:[FKrok]            ; krokov n¡
         add       al,"0"                   ; korekce na ASCII znak
         mov       ds:[FrmD3M53],al         ; krokov n¡

; ------ odsazov n¡ X

         mov       al,ds:[FSlidX]           ; odsazov n¡ X
         add       al,"0"                   ; korekce na ASCII znak
         mov       ds:[FrmD3M54],al         ; odsazov n¡ X

; ------ odsazov n¡ Y

         mov       al,ds:[FSlidY]           ; odsazov n¡ Y
         add       al,"0"                   ; korekce na ASCII znak
         mov       ds:[FrmD3M55],al         ; odsazov n¡ Y

; ------ popisova‡ m‚dia

         mov       al,ds:[FMedia]           ; popisova‡ m‚dia
         mov       di,offset FrmD3M56       ; buffer k dek¢dov n¡
         mov       ah,0                     ; nen¡ barva
         call      far ptr DekHByte         ; dek¢dov n¡ popisova‡e m‚dia
         ret

FDekParm ENDP

; ------ dek¢dov n¡ bajtu AL (slova AX) do bufferu ES:DI -> DI se zv˜¨¡ o 4

FDekPB:  mov       ah,0
FDekPW:  xor       bx,bx                    ; nen¡ barva ani oddˆlova‡
         mov       si,di                    ; SI <- £schova za‡ tku bufferu
         call      far ptr DekNumW          ; dek¢dov n¡ ‡¡sla AX
         sub       di,si                    ; DI <- d‚lka textu
         xchg      ax,di                    ; AX <- d‚lka textu
         mov       ds:[si-1],al             ; d‚lka textu
         mov       di,si                    ; DI <- za‡ tek bufferu
         add       di,4                     ; adresa dal¨¡ho bufferu
         ret

; -----------------------------------------------------------------------------
;        instalace INT 1Eh
; -----------------------------------------------------------------------------

Inst1e   PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      dx
         push      es

; ------ £schova adresy INT 1eh

         mov       ax,351eh
         int       21h
         mov       word ptr ds:[Old1e],bx
         mov       word ptr ds:[Old1e+2],es

; ------ instalace nov‚ adresy INT 1eh

         mov       ax,251eh
         mov       dx,offset Int1E
         int       21h

; ------ n vrat registr–

         pop       es
         pop       dx
         pop       bx
         pop       ax
         ret

Inst1e   ENDP

; -----------------------------------------------------------------------------
;        odinstalov n¡ INT 1eh
; -----------------------------------------------------------------------------

DeInst1e PROC      NEAR

         push      ax
         push      dx
         push      ds

         mov       ax,251eh
         lds       dx,ds:[Old1e]            ; p–vodn¡ adresa INT 1Eh
         int       21h                      ; n vrat INT 1eh

         pop       ds
         pop       dx
         pop       ax
         ret

DeInst1e ENDP

; -----------------------------------------------------------------------------
;        z pis syst‚mov˜ch sektor–
; -----------------------------------------------------------------------------

FZapSys  PROC      NEAR

; ------ p©¡prava BOOT sektoru

         mov       al,ds:[FBlok]            ; po‡et sektor– na aloka‡n¡ blok
         mov       cs:[BootClst],al         ; po‡et sektor– na aloka‡n¡ blok
         mov       ax,ds:[FRootN]           ; po‡et polo‘ek ROOT
         mov       cs:[BootRoot],ax         ; po‡et polo‘ek ROOT
         mov       ax,ds:[FSektN]           ; celkov˜ po‡et sektor– disku
         mov       cs:[BootSumS],ax         ; celkov˜ po‡et sektor– disku
         mov       al,ds:[FMedia]           ; popisova‡ m‚dia
         mov       cs:[BootMedD],al         ; popisova‡ m‚dia
         mov       ax,ds:[FFat]             ; po‡et sektor– na FAT
         mov       cs:[BootFATS],ax         ; po‡et sektor– na FAT
         mov       al,ds:[FSekt]            ; po‡et sektor– na stopu
         mov       ah,0
         mov       cs:[BootSekt],ax         ; po‡et sektor– na stopu
         mov       al,ds:[FStran]           ; po‡et stran
         mov       cs:[BootSide],ax         ; po‡et stran

; ------ p©enesen¡ BOOT sektoru do bufferu

         call      FGetBuf                  ; poskytnut¡ adresy bufferu -> ES:DI
         mov       si,offset BootBeg        ; za‡ tek BOOT sektoru
         mov       cx,512/2                 ; d‚lka BOOT sektoru
         push      di
         cld
         rep       movs word ptr es:[di],cs:[si] ; ulo‘en¡ do bufferu
         pop       di                       ; DI <- po‡ tek bufferu

; ------ p©enesen¡ jm‚na disku

         test      byte ptr ds:[FormParm],bit5 ; zad no jm‚no disku ?
         jz        FZapSys1                 ; jm‚no disku nezad no
         push      di
         add       di,offset(BootLabl-BootBeg) ; adresa k ulo‘en¡ jm‚na disku
         mov       si,offset FormMPl3+1     ; buffer jm‚na disku
         mov       cx,11                    ; d‚lka jm‚na disku
         rep       movsb                    ; p©enesen¡ jm‚na disku
         pop       di

; ------ z pis BOOT sektoru na disk

FZapSys1:xor       ax,ax                    ; AX <- 0 ‡¡slo BOOT sektoru
         call      FZapis                   ; z pis BOOT sektoru

; ------ z pis sektor– FAT

         inc       ax                       ; AX <- 1 absolutn¡ sektor FAT1
         xor       bx,bx                    ; ukazatel relativn¡ho sektoru FAT
FZapSys2:call      FGetBuf                  ; poskytnut¡ bufferu -> ES:DI
         call      FIniFat                  ; inicializace sektoru FAT
         call      FZapis                   ; z pis sektoru FAT 1
         push      ax
         add       ax,ds:[FFat]             ; druh  FAT
         call      FZapis                   ; z pis sektoru FAT2
         pop       ax
         inc       ax                       ; zv˜¨en¡ absolutn¡ho sektoru
         inc       bx                       ; zv˜¨en¡ relativn¡ho sektoru
         cmp       bx,ds:[FFat]             ; jsou ji‘ v¨echny sektory ?
         jb        FZapSys2                 ; dal¨¡ sektor

; ------ z pis prvn¡ho sektoru ROOT

         add       ax,ds:[FFat]             ; absolutn¡ sektor pro ROOT
         call      FGetBuf                  ; poskytnut¡ bufferu -> ES:DI
         test      byte ptr ds:[FormParm],bit5 ; zad no jm‚no disku ?
         jz        FZapSys7                 ; nen¡ zad no jm‚no disku

         push      ax
         push      di
         mov       si,offset FormMPl3+1     ; buffer jm‚na disku
         mov       cx,11                    ; d‚lka jm‚na disku
         rep       movsb                    ; p©enesen¡ jm‚na disku
         mov       al,VOL                   ; atribut VOL
         stosb                              ; ulo‘en¡ atributu jm‚na
         add       di,10                    ; p©esko‡en¡ rezervovan˜ch dat
         call      far ptr GetSTime         ; poskytnut¡ aktu ln¡ho ‡asu
         xchg      ax,dx                    ; AX <- aktu ln¡ ‡as
         cld
         stosw                              ; ulo‘en¡ ‡asu
         call      far ptr GetSDate         ; poskytnut¡ aktu ln¡ho data
         xchg      ax,dx                    ; AX <- aktu ln¡ datum
         cld
         stosw                              ; ulo‘en¡ data
         pop       di
         pop       ax

FZapSys7:call      FZapis                   ; z pis prvn¡ho sektoru ROOT
         inc       ax                       ; zv˜¨en¡ ‡¡sla sektoru

; ------ z pis ostatn¡ch sektor– ROOT

         mov       cx,ds:[FRoot]            ; po‡et sektor– na ROOT
         dec       cx                       ; bez prvn¡ho sektoru
         jcxz      FZapSys9                 ; nen¡ dal¨¡ sektor

         call      FGetBuf                  ; poskytnut¡ bufferu -> ES:DI
FZapSys8:call      FZapis                   ; z pis sektoru ROOT
         inc       ax                       ; zv˜¨en¡ ‡¡sla sektoru
         loop      FZapSys8                 ; z pis dal¨¡ho sektoru

FZapSys9:ret

FZapSys  ENDP

; -----------------------------------------------------------------------------
;        inicializace sektoru FAT ES:DI, BL=relativn¡ ‡¡slo sektoru FAT
; -----------------------------------------------------------------------------

FIniFat  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      dx
         push      si
         push      di

; ------ p©¡prava ukazatele konce bufferu sektoru

         mov       si,di                    ; SI <- za‡ tek sektoru
         add       si,512                   ; SI <- konec sektoru

; ------ ukazatel ‡¡sla aloka‡n¡ho bloku -> BX (DX=tetr da 0 a‘ 2)

         mov       ah,bl                    ; AH <- ‡¡slo sektoru FAT
         mov       al,0                     ; AX = ‡¡slo sektoru * 256
         shl       ax,1                     ; offset FAT v bajtech
         shl       ax,1                     ; offset FAT v tetr d ch
         xor       dx,dx                    ; DX <- 0
         mov       bx,3                     ; po‡et tetr d na blok
         div       bx                       ; v˜po‡et bloku a tetr dy
         xchg      ax,bx                    ; BX <- ‡¡slo bloku

; ------ p©¡prava masky a adresy

         mov       ax,0ff7h                 ; maska pro tetr du 0
         or        dx,dx                    ; je zarovnan  polo‘ka ?
         jz        FIniFat2                 ; je zarovnan  polo‘ka
         dec       di                       ; posun adresy
         dec       dx                       ; je tetr da 1 ?
         jnz       FIniFat2                 ; je tetr da 2
         mov       ax,0ff70h                ; maska pro tetr du 1

; ------ aloka‡n¡ blok 0

FIniFat2:cmp       bx,1                     ; je aloka‡n¡ blok 1 ?
         je        FIniFat5                 ; je aloka‡n¡ blok 1 (je ji‘ OK)
         ja        FIniFat3                 ; je datov˜ aloka‡n¡ blok
         mov       dl,ds:[FMedia]           ; popisova‡ m‚dia
         mov       es:[di],dl               ; popisova‡ m‚dia
         mov       word ptr es:[di+1],-1    ; 2. a 3. bajt
         jmp       short FIniFat5

; ------ nalezen¡ aloka‡n¡ho bloku v tabulce

FIniFat3:call      FBlokErr                 ; je blok BX vadn˜ ?
         jnc       FIniFat5                 ; blok nen¡ vadn˜
         or        es:[di],ax               ; nastaven¡ bloku jako vadn˜

; ------ zv˜¨en¡ aloka‡n¡ho bloku

FIniFat5:inc       di                       ; zv˜¨en¡ ukl dac¡ adresy
         xor       ax,0ff7h XOR 0ff70h      ; zmˆna masky
         cmp       ah,0fh
         jne       FIniFat6
         inc       di
FIniFat6:inc       bx                       ; zv˜¨en¡ ‡¡sla bloku
         cmp       di,si                    ; je ji‘ konec bufferu ?
         jb        FIniFat2                 ; nen¡ je¨tˆ konec bufferu

; ------ n vrat registr–

         pop       di
         pop       si
         pop       dx
         pop       bx
         pop       ax
         ret

FIniFat  ENDP

; -----------------------------------------------------------------------------
;        nulovac¡ z pis -> CY=chyba
; -----------------------------------------------------------------------------

FWritNul PROC      NEAR

; ------ indik tor z pisu

         mov       al,3                     ; indik tor z pisu
         jmp       short FFormat0

FWritNul ENDP

; -----------------------------------------------------------------------------
;        zform tov n¡ aktu ln¡ stopy -> CY=chyba, AH=k¢d chyby
; -----------------------------------------------------------------------------

FFormat  PROC      NEAR

; ------ inidik tor form tov n¡

         mov       al,1                     ; indik tor form tov n¡

; ------ inicializace parametr–

FFormat0:call      FSetDbl                  ; inicializace parametr–

; ------ zobrazen¡ indik toru operace

         call      FIndik                   ; zobrazen¡ indik toru operace

; ------ £schova registr–

         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es

; ------ stanoven¡ ‡¡sla po‡ te‡n¡ho sektoru -> AX (mus¡ se sni‘ovat od 1 dol–)

         mov       al,ds:[FSlidY]           ; odsazen¡ sektor– stop
         cmp       byte ptr ds:[FStran],1   ; je pouze 1 strana ?
         je        FFormat1                 ; je 1 strana
         add       al,ds:[FSlidX]           ; p©i‡ten¡ odsazen¡ pro strany
FFormat1:mul       byte ptr ds:[FStopAkt]   ; posun odsazen¡m p©ede¨l˜ch stop

         cmp       byte ptr ds:[FStrnAkt],0 ; je strana 0 ?
         je        FFormat2                 ; je strana 0
         add       al,ds:[FSlidX]           ; je¨tˆ jedno odsazen¡ strany
         adc       ah,0

FFormat2:add       ax,ds:[FSlidErr]         ; rotace kv–li chyb m

         mov       cl,ds:[FSekt]            ; po‡et sektor– na stopu
         mov       ch,0
         dec       cx                       ; po‡et sektor– na stopu - 1
         add       ax,cx                    ; korekce po‡ tku posun–
         inc       cx                       ; n vrat po‡tu sektor– na stopu
         xor       dx,dx                    ; DX <- 0
         div       cx                       ; maskov n¡ MOD po‡et sektor–
         xchg      ax,cx                    ; AX <- po‡et sektor– na stopu
         sub       ax,dx                    ; AX <- ‡¡slo po‡ te‡n¡ho sektoru

; ------ p©¡prava bufferu -> ES:DI (+ vynulov n¡)

         call      FGetBuf                  ; poskytnut¡ adresy bufferu -> ES:DI

; ------ p©¡prava registr– ke generov n¡ tabulky

         mov       cl,ds:[FSekt]            ; CL <- po‡et sektor– na stopu
         mov       ch,0
         mov       dl,ds:[FStopAkt]         ; DL <- aktu ln¡ stopa
         mov       dh,ds:[FStrnAkt]         ; DH <- aktu ln¡ strana
         mov       ah,2                     ; AH <- velikost sektoru 512 Bajt–
         mov       bp,cx                    ; BP <- po‡et sektor– na stopu
         shl       bp,1
         shl       bp,1                     ; * 4 = velikost tabulky
         mov       si,bp                    ; SI <- velikost tabulky
         add       bp,di                    ; BP = adresa konce tabulky
         mov       bh,0
         mov       bl,ds:[FInterl]          ; BL <- prokl d n¡ sektor–
         dec       bx                       ; prokl d n¡ - 1
         shl       bx,1
         shl       bx,1                     ; BX <- posun adres sektor–

; ------ zaji¨tˆn¡ platnosti adresy

FFormat3:cmp       di,bp                    ; je adresa OK ?
         jb        FFormat4                 ; adresa je OK
         sub       di,si                    ; posun adresy o 1 stopu dol–
         jmp       short FFormat3

; ------ zaji¨tˆn¡ volnosti polo‘ky v tabulce

FFormat4:cmp       byte ptr es:[di+3],0     ; je voln  polo‘ka (d‚lka sektoru) ?
         je        FFormat5                 ; je voln  polo‘ka
         add       di,4                     ; zv˜¨en¡ ukl dac¡ adresy
         jmp       short FFormat3           ; nov˜ test polo‘ky

; ------ ulo‘en¡ polo‘ky

FFormat5:xchg      ax,dx                    ; AL <- v lec, AH <- hlava
         stosw                              ; ‡¡slo v lce a hlavy
         xchg      ax,dx                    ; AL <- sektor, AH <- velikost
         stosw                              ; ‡¡slo a velikost sektoru

; ------ zv˜¨en¡ ‡¡sla sektoru

         inc       ax                       ; zv˜¨en¡ ‡¡sla sektoru
         cmp       al,ds:[FSekt]            ; je ‡¡slo sektoru je¨tˆ OK ?
         jbe       FFormat6                 ; ‡¡slo sektoru je je¨tˆ OK
         mov       al,1                     ; p©ete‡en¡ ‡¡sla sektoru

; ------ dal¨¡ polo‘ka

FFormat6:add       di,bx                    ; posun polo‘ky p©i prokl d n¡
         loop      FFormat3                 ; dal¨¡ polo‘ka

; ------ form tov n¡ stopy (DH=aktu ln¡ strana, CX=0, DL=aktu ln¡ stopa)

         mov       bx,bp                    ; BX <- adresa konce tabulky
         sub       bx,si                    ; BX <- adresa za‡ tku tabulky
         mov       ah,5                     ; slu‘ba pro form tov n¡
         inc       cx                       ; CL <- po‡ te‡n¡ ‡¡slo sektoru = 1
         mov       al,ds:[FSekt]            ; po‡et sektor–
         mov       ch,dl                    ; CH <- aktu ln¡ stopa
         call      Int130                   ; form tov n¡ stopy

; ------ n vrat registr–

         mov       byte ptr ds:[FOper],0    ; zru¨en¡ p©¡znaku operace
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         ret

FFormat  ENDP

; -----------------------------------------------------------------------------
;        testovac¡ z pis -> CY=chyba
; -----------------------------------------------------------------------------

FWritTst PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      es

; ------ inicializace parametr–

         call      FSetDbl                  ; inicializace parametr–

; ------ zobrazen¡ indik toru z pisu

         mov       al,3                     ; indik tor z pisu
         call      FIndik                   ; zobrazen¡ indik toru operace

; ------ z pis n hodn˜ch dat na disk

         mov       bx,SEG CodeLod           ; segment za‡ tku DOSMANu
         add       bx,2000h                 ; to je nˆkam do st©edu DOSMANu
         and       bx,0f000h                ; zarovn n¡ na hranici 64 KB
         mov       es,bx                    ; ES<-segment (skoro) n hodn˜ch dat
         xor       bx,bx                    ; BX <- 0
         mov       ch,ds:[FStopAkt]         ; aktu ln¡ v lec
         mov       dh,ds:[FStrnAkt]         ; aktu ln¡ strana
         mov       cl,1                     ; od sektoru 1
         mov       al,ds:[FSekt]            ; po‡et sektor– k z pisu
         mov       ah,3                     ; funkce z pisu
         call      Int130                   ; z pis dat na disk
         mov       byte ptr ds:[FOper],0    ; zru¨en¡ p©¡znaku operace

; ------ n vrat registr–

         pop       es
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

FWritTst ENDP

; -----------------------------------------------------------------------------
;        generov n¡ n hodn˜ch dat CX bajt– do bufferu ES:DI
; -----------------------------------------------------------------------------

FRandomS PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      bp
         push      si

; ------ p©¡prava registr–

         cld
         shr       cx,1                     ; po‡et slov ke generov n¡
         mov       si,cx                    ; SI <- po‡et slov ke generov n¡
         mov       bp,8405h                 ; pomocn  konstanta
         mov       ax,word ptr ds:[FRandmR] ; pomocn˜ registr gener toru
         mov       dx,word ptr ds:[FRandmR+2]

; ------ v˜po‡et n hodn‚ho ‡¡sla

FRandmS1:mov       bx,dx
         mov       cx,ax
         mul       bp
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

         xchg      ax,dx
         stosw                              ; ulo‘en¡ n hodn‚ho slova
         xchg      ax,dx

         dec       si                       ; ‡¡ta‡ slov
         jnz       FRandmS1                 ; dal¨¡ slovo

         mov       word ptr ds:[FRandmR],ax
         mov       word ptr ds:[FRandmR+2],dx

; ------ n vrat registr–

         pop       si
         pop       bp
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

FRandomS ENDP

; -----------------------------------------------------------------------------
;        z pis sektoru AX z bufferu ES:DI -> CY chyba
; -----------------------------------------------------------------------------

FZapis   PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx

; ------ v˜po‡et ‡¡sla v lce, strany a sektoru

         div       byte ptr ds:[FSekt]      ; v˜po‡et ‡¡sla stopy
         mov       cl,ah                    ; CL <- ‡¡slo sektoru - 1
         inc       cx                       ; CL = ‡¡slo sektoru
         mov       ah,0
         div       byte ptr ds:[FStran]     ; v˜po‡et ‡¡sla v lce a strany
         mov       ch,al                    ; CH <- ‡¡slo stopy
         mov       dh,ah                    ; DH <- ‡¡slo strany
         mov       ds:[FStopAkt],ch         ; aktu ln¡ ‡¡slo stopy
         mov       ds:[FStrnAkt],dh         ; aktu ln¡ ‡¡slo strany

; ------ inicializace parametr–

         call      FSetDbl                  ; inicializace parametr–

; ------ zobrazen¡ indik toru z pisu

         mov       al,3                     ; indik tor z pisu
         call      FIndik                   ; zobrazen¡ indik toru operace

; ------ z pis sektoru na disk

         mov       bx,di                    ; BX <- buffer
         mov       ax,3*HI + 1              ; z pis 1 sektoru
         call      Int130                   ; z pis dat na disk
         mov       byte ptr ds:[FOper],0    ; zru¨en¡ p©¡znaku operace

; ------ n vrat registr–

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

FZapis   ENDP

; -----------------------------------------------------------------------------
;        detekce vadn˜ch sektor– ve stopˆ (neuchov v  registry !)
; -----------------------------------------------------------------------------

FVerBad  PROC      NEAR

         and       byte ptr ds:[FormParm],not bit7 ; nebyla chyba

; ------ inicializace parametr–

         call      FSetDbl                  ; inicializace parametr–

; ------ zobrazen¡ indik toru verifikace

         mov       al,2                     ; indik tor verifikace
         call      FIndik                   ; zobrazen¡ indik toru operace

; ------ p©¡prava ‡¡sla sektoru -> AX, CL

         mov       al,ds:[FStopAkt]         ; aktu ln¡ stopa
         mul       byte ptr ds:[FStran]     ; p©epo‡et na ‡¡slo strany
         add       al,ds:[FStrnAkt]         ; + aktu ln¡ strana
         mul       byte ptr ds:[FSekt]      ; absolutn¡ ‡¡slo sektoru
         mov       cl,1                     ; relativn¡ ‡¡slo sektoru

; ------ detekce lich˜ch sektor–

         push      ax
FVerBad1:call      far ptr TestBEsc         ; je p©eru¨en¡ operace ?
         jc        FVerBd12                 ; je p©eru¨en¡ operace
         call      FVerD                    ; detekce jednoho sektoru
         inc       ax
         inc       ax                       ; zv˜¨en¡ absolutn¡ho sektoru
         inc       cx
         inc       cx                       ; zv˜¨en¡ relativn¡ho sektoru
         cmp       cl,ds:[FSekt]            ; je to je¨tˆ platn˜ sektor ?
         jbe       FVerBad1                 ; je to je¨tˆ platn˜ sektor
FVerBd12:pop       ax

; ------ detekce lich˜ch sektor–

         push      ax
         inc       ax                       ; 2. sektor
         mov       cl,2                     ; 2. sektor
         jmp       short FVerBad3

FVerBad2:call      far ptr TestBEsc         ; je p©eru¨en¡ operace ?
         jc        FVerBd32                 ; je p©eru¨en¡ operace
         call      FVerD                    ; detekce jednoho sektoru
         inc       ax
         inc       ax                       ; zv˜¨en¡ absolutn¡ho sektoru
         inc       cx
         inc       cx                       ; zv˜¨en¡ relativn¡ho sektoru
FVerBad3:cmp       cl,ds:[FSekt]            ; je to je¨tˆ platn˜ sektor ?
         jbe       FVerBad2                 ; je to je¨tˆ platn˜ sektor
FVerBd32:pop       ax

; ------ korekce, pokud nebyla nalezena ani jedna chyba

         test      byte ptr ds:[FormParm],bit7 ; byla nalezena nˆjak  chyba ?
         jnz       FVerBad5                 ; byla nˆjak  chyba
         mov       cl,ds:[FSekt]            ; CL <- po‡et sektor– na stopu
         mov       ch,0
FVerBad4:call      FSetErr                  ; nastaven¡ p©¡znaku vadn‚ho sektoru
         inc       ax                       ; zv˜¨en¡ ukazatele sektor–
         loop      FVerBad4                 ; nastaven¡ dal¨¡ho sektoru

; ------ aktualizace v˜pisu o chyb ch

FVerBad5:mov       byte ptr ds:[FOper],0    ; zru¨en¡ p©¡znaku operace
         call      FIniVad                  ; inicializace hl ¨en¡ o chybˆ
         ret

FVerBad  ENDP

; -----------------------------------------------------------------------------
;        detekce sektoru AX (‡¡slo na stopˆ CL) (se za©azen¡m do tabulky chyb)
; -----------------------------------------------------------------------------

FVerD    PROC      NEAR

; ------ verifikace sektoru

         push      ax
         mov       al,1
         xor       bx,bx                    ; BX <- fiktivn¡ offset adresy
         mov       es,bx                    ; ES <- fiktivn¡ segment adresy
         mov       ah,4                     ; funkce verifikace
         mov       ch,ds:[FStopAkt]         ; aktu ln¡ v lec
         mov       dh,ds:[FStrnAkt]         ; aktu ln¡ strana
         call      Int130                   ; verifikace dat z disku
         pop       ax
         jnc       FVerD4                   ; operace OK

; ------ ozna‡en¡ sektoru jako vadn˜

         call      FSetErr                  ; nastaven¡ p©¡znaku vadn‚ho sektoru

; ------ n vrat registr–

FVerD4:  ret

FVerD    ENDP

; -----------------------------------------------------------------------------
;        verifikace AL sektor– od sektoru CL -> CY=chyba, AH=k¢d chyby
; -----------------------------------------------------------------------------

FVerify0:mov       cl,1                     ; po‡ te‡n¡ sektor 1
         mov       al,ds:[FSekt]            ; po‡et sektor– k verifikaci

FVerify  PROC      NEAR

; ------ £schova registr–

         push      bx
         push      cx
         push      dx
         push      es

; ------ inicializace parametr–

         call      FSetDbl                  ; inicializace parametr–

; ------ zobrazen¡ indik toru verifikace

         push      ax
         mov       al,2                     ; indik tor verifikace
         call      FIndik                   ; zobrazen¡ indik toru operace
         pop       ax

; ------ verifikace stopy z disku

         xor       bx,bx                    ; BX <- fiktivn¡ offset adresy
         mov       es,bx                    ; ES <- fiktivn¡ segment adresy
         mov       ah,4                     ; funkce verifikace
         mov       ch,ds:[FStopAkt]         ; aktu ln¡ v lec
         mov       dh,ds:[FStrnAkt]         ; aktu ln¡ strana
         call      Int130                   ; verifikace dat z disku

; ------ n vrat registr–

         mov       byte ptr ds:[FOper],0    ; zru¨en¡ p©¡znaku operace
         pop       es
         pop       dx
         pop       cx
         pop       bx
         ret

FVerify  ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ form tu diskety
; -----------------------------------------------------------------------------

FSetForm PROC      NEAR

; ------ ur‡en¡ jmenovit‚ho po‡tu stop diskety pro nastaven¡ slu‘bou 18h

         mov       ch,79                    ; bude jmenovitˆ 80 stop
         cmp       byte ptr ds:[FTypDisk],M120 ; je mechanika 3 1/2" ?
         ja        FSetFrm2                 ; je mechanika 3 1/2" - v‘dy 80 stop
         jb        FSetFrm1                 ; je mechanika 360 KB - v‘dy 40 stop
         cmp       byte ptr ds:[FKrok],2    ; je dvojit‚ krokov n¡ ?
         jb        FSetFrm2                 ; nen¡ dvojit‚ krokov n¡ - 80 stop
FSetFrm1:mov       ch,39                    ; bude jmenovitˆ 40 stop

; ------ ur‡en¡ jmenovit‚ho po‡tu sektor– na stopu pro nastaven¡ slu‘bou 18h

FSetFrm2:mov       cl,9                     ; po‡et sektor– pro disketu DD
         cmp       byte ptr ds:[FSekt],13   ; je disketa DD ?
         jbe       FSetFrm3                 ; je disketa DD
         mov       cl,36                    ; po‡et sektor– pro disketu QD
         cmp       byte ptr ds:[FRate],R1000 ; je disketa QD ?
         je        FSetFrm3                 ; je disketa QD
         mov       cl,15                    ; po‡et sektor– pro HD 5 1/4"
         cmp       byte ptr ds:[FTypDisk],M120 ; je mechanika 1.2 MB ?
         je        FSetFrm3                 ; je mechanika 1.2 MB
         mov       cl,18                    ; po‡et sektor– pro HD 3 1/2"

; ------ prvn¡ pokus o nastaven¡ form tu - slu‘bou 18h

FSetFrm3:mov       dh,1                     ; pro jistotu nˆco jako strana
         call      FSet18F                  ; nastaven¡ form tu slu‘bou 18h

; ------ nastaven¡ bl¡zk‚ho form tu pro mechaniku 1.2 MB, nen¡-li podporov n

         cmp       ah,1                     ; form t nepodporov n ?
         jbe       FSetFrm4                 ; ne, je jin˜ v˜sledek
         cmp       cx,79*HI + 9             ; disketa 720 KB ?
         jne       FSetFrm4                 ; nen¡ disketa 720 KB
         cmp       byte ptr ds:[FTypDisk],M120 ; mechanika 1.2 MB ?
         jne       FSetFrm4                 ; nen¡ mechanika 1.2 MB
         mov       ch,39                    ; bude jako disketa 360 KB
         call      FSet18F                  ; opravn‚ nastaven¡ form tu

; ------ nen¡-li slu‘ba podporov na, nastaven¡ slu‘bou 17h

FSetFrm4:cmp       ah,1                     ; je slu‘ba podporov na ?
         jne       FSetFrm6                 ; slu‘ba asi podporov na OK

         mov       al,1                     ; disketa 360 KB v mechanice 40 stop
         cmp       byte ptr ds:[FTypDisk],M360 ; mechanika 360 KB ?
         je        FSetFrm5                 ; mechanika 360 KB
         inc       ax                       ; disketa 360 KB v mechanice 80 stop
         cmp       byte ptr ds:[FKrok],2    ; je dvojit‚ krokov n¡ ?
         je        FSetFrm5                 ; je dvojit‚ krokov n¡
         inc       ax                       ; disketa HD
         cmp       byte ptr ds:[FSekt],13   ; je disketa HD nebo QD ?
         ja        FSetFrm5                 ; je disketa HD nebo QD
         inc       ax                       ; jinak disketa 720 KB
FSetFrm5:call      FSet17F                  ; nastaven¡ form tu slu‘bou 17h

; ------ up©esnˆn¡ nastaven¡ registr– BIOS

FSetFrm6:call      FSetDbl                  ; nastaven¡ registr– BIOS
         ret

FSetForm ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ registr– BIOS a ukazatel– p©ed ka‘dou operac¡
; -----------------------------------------------------------------------------

FSetDbl  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      es

; ------ p©¡prava ukazatele BIOS -> ES:BX

         mov       bx,40h                   ; segment BIOS
         mov       es,bx                    ; ES <- segment BIOS
         mov       bl,ds:[FAktDisk]         ; BX <- korekce pro aktivn¡ disk

; ------ p©¡prava p©enosov‚ rychlosti

         mov       al,ds:[FRate]            ; p©enosov  rychlost
         ror       al,1
         ror       al,1                     ; posun na pozici (bit 6 a bit7)

; ------ p©¡prava p©¡znaku dvojit‚ho krokov n¡

         cmp       byte ptr ds:[FKrok],2    ; je dvojit‚ krokov n¡ ?
         jne       FSetDbl2                 ; nen¡ dvojit‚ krokov n¡
         or        al,bit5                  ; je dvojit‚ krokov n¡

; ------ nastaven¡ p©¡znaku dvojit‚ho krokov n¡

FSetDbl2:or        al,bit4                  ; p©¡znak, ‘e je m‚dium zn m‚
         and       byte ptr es:[bx+90h],not bit5+bit6+bit7 ; nulov n¡ p©¡znak–
         or        es:[bx+90h],al           ; nastaven¡ p©¡znak–

; ------ nastaven¡ disk– pro EHD BIOS

         cmp       byte ptr es:[8bh],1      ; je EHD BIOS ?
         jne       FSetDbl3                 ; nen¡ EHD BIOS
         and       byte ptr es:[bx+0d7h],not bit5+bit6+bit7 ; nulov n¡ p©¡znak–
         or        es:[bx+0d7h],al          ; nastaven¡ p©¡znak–

; ------ nastaven¡ rychlosti krokov n¡ mechaniky a ‡asu pro zvednut¡ hlavy

FSetDbl3:mov       al,0dfh                  ; krokov n¡ mechaniky 5 1/4"
         cmp       byte ptr ds:[FTypDisk],M720 ; je mechanika 3 1/2"
         jb        FSetDbl4                 ; je mechanika 5 1/4"
         mov       al,0afh                  ; krokov n¡ mechaniky 3 1/2"
FSetDbl4:mov       ds:[Int1ESTP],al         ; ‡as zvednut¡ hlavy mechaniky

; ------ nastaven¡ po‡tu sektor– na stopu pro INT 1Eh

         mov       al,ds:[FSekt]            ; po‡et sektor– na stopu
         mov       ds:[Int1ESEC],al         ; nastaven¡ po‡tu sektor– na stopu

; ------ nastaven¡ mezisektorov‚ mezery pro ‡ten¡ a z pis

         mov       al,2ah                   ; mezisektorov  mezera pro DD
         cmp       byte ptr ds:[FSekt],13   ; je disketa DD ?
         jbe       FSetDbl5                 ; je disketa DD
         mov       al,1bh                   ; mezisektorov  mezera pro HD
FSetDbl5:mov       ds:[Int1EGPR],al         ; mezisektorov  mezera ‡ten¡/z pis

; ------ nastaven¡ mezisektorov‚ mezery pro form tov n¡

         mov       al,ds:[FGap]             ; mezisektorov  mezera form tov n¡
         mov       ds:[Int1EGPF],al         ; nastaven¡ mezisektorov‚ mezery

; ------ nastaven¡ form tovac¡ho bajtu

         mov       byte ptr ds:[Int1EChr],FormBajt ; nastaven¡ form t. bajtu
         test      byte ptr ds:[FormParm],bit3 ; prov d¡ se testovac¡ z pis ?
         jz        FSetDbl6                 ; nen¡ testovac¡ z pis
         test      byte ptr ds:[FormParm],bit4 ; byl ji‘ testovac¡ z pis ?
         jnz       FSetDbl6                 ; byl ji‘ testovac¡ z pis
         mov       byte ptr ds:[Int1EChr],5Ah ; ponˆkud jin  konstanta

; ------ nastaven¡ posledn¡ stopy na disku

FSetDbl6:mov       al,ds:[FStop]            ; po‡et stop
         dec       ax                       ; po‡et stop - 1
         mov       ds:[Int1ECYL],al         ; posledn¡ stopa na disku

; ------ nastaven¡ p©enosov‚ rychlosti

         mov       al,ds:[FRate]            ; p©enosov  rychlost
         ror       al,1
         ror       al,1                     ; rotace na pozici (bit 6 a bit 7)
         mov       ds:[Int1ERAT],al         ; nastaven¡ p©enosov‚ rychlosti

; ------ n vrat registr–

         pop       es
         pop       bx
         pop       ax
         ret

FSetDbl  ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ form tu slu‘bou 17h (AL=kombinace -> CY chyba AH)
; -----------------------------------------------------------------------------

FSet17F  PROC      NEAR

         mov       ah,17h                   ; slu‘ba nastaven¡ form tu
         jmp       short FSet18F0

FSet17F  ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ form tu slu‘bou 18h (CH=stop-1, CL=sektor– -> AH=v˜sledek)
; -----------------------------------------------------------------------------

FSet18F  PROC      NEAR

; ------ £schova registr–

         mov       ah,18h                   ; po‘adovan  slu‘ba
FSet18F0:push      bx
         push      bp

; ------ nastaven¡ typu m‚dia

         xchg      ax,bx                    ; BX <- £schova AX
         mov       bp,3                     ; 3 pokusy
FSet18F1:mov       ax,bx                    ; slu‘ba nastaven¡ form tu
         call      Int130                   ; nastaven¡ form tu
         cmp       ah,bh                    ; z–stal registr nezmˆnˆn ?
         jne       FSet18F2                 ; zmˆnil se
         mov       ah,1                     ; to asi nen¡ podporov no
FSet18F2:cmp       ah,1                     ; bude nov˜ pokus ?
         jbe       FSet18F8                 ; v¨e OK nebo nen¡ podporov no

; ------ p©i chybˆ nov˜ pokus o proveden¡ operace

         call      FResDisk                 ; resetov n¡ diskov‚ho syst‚mu
         dec       bp                       ; ‡¡ta‡ pokus–
         jnz       FSet18F1                 ; dal¨¡ pokus

; ------ n vrat registr–

FSet18F8:pop       bp
         pop       bx
         ret

FSet18F  ENDP

; -----------------------------------------------------------------------------
;        poskytnut¡ bufferu pro form tov n¡ a z pis -> ES:DI
; -----------------------------------------------------------------------------

FGetBuf  PROC      NEAR

         push      ax
         push      cx

         mov       ax,ds:[FormWSeg]         ; segment pro form tov n¡ a z pis
         call      far ptr GetDat           ; poskytnut¡ adresy bufferu
         mov       di,16                    ; offset po‡ tku bufferu
         mov       ax,es                    ; AX <- adresa bufferu
         inc       ax                       ; AX <- p©i‡ten¡ offsetu (=DI)
         and       ax,0fffh                 ; zbytek v modulu 64K
         cmp       ax,1000h-512/16          ; bylo by p©ete‡en¡ hranice ?
         jb        FGetBuf2                 ; nebylo by p©ete‡en¡ hranice
         mov       di,512+16                ; posun za hranici

FGetBuf2:push      di
         mov       cx,512/2                 ; d‚lka sektoru ve slovech
         xor       ax,ax                    ; AX <- 0 nulovac¡ slovo
         cld
         rep       stosw                    ; vynulov n¡ bufferu
         pop       di

         pop       cx
         pop       ax
         ret

FGetBuf  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ indik toru operace AL
; -----------------------------------------------------------------------------

FIndik   PROC      NEAR

         push      si
         mov       ds:[FOper],al            ; aktu ln¡ operace
         call      far ptr DispTime         ; zobrazen¡ ‡asu
         mov       si,offset FormMnu        ; okno form tov n¡
         call      far ptr DispMnu          ; zobrazen¡ okna
         pop       si
         ret

FIndik   ENDP

; *****************************************************************************
;                              InitOMnu
;                inicializace okna form tov n¡ disket
; -----------------------------------------------------------------------------
; VSTUP: SI=definice menu
;        DS=datov˜ segment
; *****************************************************************************

InitOMnu PROC      FAR

         call      far ptr CentMenu         ; centrov n¡ okna
         ret

InitOMnu ENDP

; *****************************************************************************
;                                 DispOMnu
;                   zobrazen¡ okna form tov n¡ disket
; -----------------------------------------------------------------------------
; VSTUP: SI=definice okna
;        DS=datov˜ segment
; -----------------------------------------------------------------------------
; lok ln¡ promˆnn‚: SS:[BP-1] (1) ukazatel © dku na displeji
;                   SS:[BP-2] (1) po‡ te‡n¡ pozice menu
;                   SS:[BP-3] (1) ‡¡ta‡ vnit©n¡ch © dk– k zobrazen¡
;                   SS:[BP-4] (1) ¨¡©ka okna
;                   SS:[BP-6] (2) hladina k zobrazen¡ menu
;                   SS:[BP-7] (1) ukazatel relativn¡ho ‡¡sla © dku
;                   SS:[BP-8] (1) ukazatel ‡¡sla strany  ÄÄ¿ (pou‘¡v  se spolu)
;                   SS:[BP-9] (1) ‡¡slo v lce po‡ tku pole Ù
;                   SS:[BP-10] (1) ‡¡slo v lce konce pole + 1
;                   SS:[BP-11] (1) ‡¡ta‡ © dku k zobrazen¡ po‡ tku mapy
;                   SS:[BP-12] (1) relativn¡ pozice po‡ tku mapy
; *****************************************************************************
;þ
DispOMnu PROC      FAR

         call      far ptr DispRamM         ; zobrazen¡ horn¡ a doln¡ linky

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

; ------ vytvo©en¡ bufferu v z sobn¡ku

         sub       sp,12                    ; m¡sto pro lok ln¡ promˆnn‚
         mov       cl,ds:[si+MnuSir]        ; ¨¡©ka okna
         mov       ch,0
         shl       cx,1                     ; po‡et bajt– na ¨¡©ku okna
         sub       sp,cx                    ; vytvo©en¡ bufferu pro jeden © dek

; ------ inicializace lok ln¡ch promˆnn˜ch

         mov       ax,word ptr ds:[si+MnuPoz] ; pozice a © dek
         inc       ah                       ; po‡ te‡n¡ © dek k zobrazen¡
         mov       ss:[bp-2],ax             ; pozice a © dek
         mov       ax,word ptr ds:[si+MnuSir] ; ¨¡©ka a v˜¨ka
         sub       ah,2                     ; vnit©n¡ v˜¨ka okna
         mov       ss:[bp-4],ax             ; ¨¡©ka a v˜¨ka
         mov       al,ds:[si+MnuLev]        ; hladina k zobrazen¡ menu
         mov       ah,0
         mov       ss:[bp-6],ax             ; hladina k zobrazen¡ menu
         mov       word ptr ss:[bp-8],0     ; ukazatel ‡¡sla hlavy, ‡¡ta‡ © dku

; ------ ‡¡slo v lce po‡ tku a konce pole

         mov       al,ds:[FStop]            ; po‡et stop
         cmp       al,50                    ; maxim lnˆ stop pro p©elom
         jb        DispOM04                 ; nebude p©elom
         shr       al,1                     ; polovi‡n¡ po‡et stop
         adc       al,0                     ; lich  stopa
DispOM04:mov       ah,0
         mov       ss:[bp-10],ax            ; v lec za‡ tku a konce pole

; ------ relativn¡ pozice po‡ tku mapy

         mov       al,ds:[si+MnuSir]        ; ¨¡©ka okna
         sub       al,ss:[bp-10]            ; ode‡ten¡ ¨¡©ky mapy
         add       al,4                     ; korekce - posun vpravo
         shr       al,1                     ; relativn¡ pozice po‡ tku
         mov       ss:[bp-12],al            ; relativn¡ pozice po‡ tku mapy

; ------ v˜¨ka mapy celkem

         mov       al,ds:[FStran]           ; po‡et stran 1 a‘ 2
         add       al,4                     ; p©i‡ten¡ okraj–
         cmp       byte ptr ds:[FStop],50   ; bude p©elom ?
         jb        DispOM06                 ; nebude p©elom
         shl       al,1                     ; dvojn sobn  v˜¨ka mapy

; ------ po‡ te‡n¡ © dek k zobrazen¡ mapy

DispOM06:mov       ah,ds:[si+MnuVys]        ; v˜¨ka okna
         sub       ah,al                    ; zbytek na okraje
         add       ah,2                     ; posun dol–
         shr       ah,1                     ; relativn¡ © dek po‡ tku
         mov       ss:[bp-11],ah            ; ‡¡ta‡ © dku k zobrazen¡ po‡ tku

         push      ss
         pop       es                       ; ES <- segment bufferu v z sobn¡ku

; ------ vymaz n¡ © dku

DispOMn1:mov       di,sp                    ; adresa bufferu v z sobn¡ku
         mov       ah,ds:[ColMnu1R]         ; bˆ‘n  barva textu pro lev˜ okraj
         cld
         mov       al,"³"                   ; "³" lev˜ okraj
         stosw                              ; ulo‘en¡ lev‚ho okraje
         mov       cl,ss:[bp-4]             ; ¨¡©ka okna
         sub       cl,2                     ; vnit©n¡ ¨¡©ka okna
         mov       ah,ds:[ColMnu1]          ; bˆ‘n  barva textu
         mov       al," "                   ; mazac¡ znak mezery
         rep       stosw                    ; vymaz n¡ vnit©ku © dku
         mov       al,"³"                   ; "³" prav˜ okraj
         mov       ah,ds:[ColMnu1L]         ; barva pro prav˜ okraj
         stosw                              ; ulo‘en¡ prav‚ho okraje

; ------ p©¡prava ukazatele v bufferu

         mov       di,sp                    ; DI <- buffer
         mov       al,ss:[bp-12]            ; relativn¡ pozice po‡ tku mapy
         mov       ah,0
         add       di,ax
         add       di,ax                    ; po‡ tek v bufferu
         mov       ch,0                     ; CH <- 0
         mov       bx,ss:[bp-9]             ; BL <- stopa, BH <- strana
         mov       cl,ss:[bp-10]            ; n sleduj¡c¡ v lec
         sub       cl,bl                    ; po‡et v lc– k zobrazen¡

; ------ ‡¡t n¡ © dku po‡ tku mapy

         dec       byte ptr ss:[bp-11]      ; ‡¡ta‡ © dku k zobrazen¡ mapy
         jz        DispOMn2                 ; je horn¡ linka mapy
         js        DispOMn3                 ; jsou vnit©n¡ © dky

; ------ zobrazen¡ informa‡n¡ho © dku

         mov       si,offset FormMPl1       ; text jm‚na disku
         cmp       byte ptr ss:[bp-7],0     ; je prvn¡ © dek ?
         je        DispOM17                 ; je prvn¡ © dek
         cmp       byte ptr ss:[bp-3],1     ; je posledn¡ © dek ?
         jne       DispOM18                 ; nen¡ posledn¡ © dek
         mov       si,offset FormMPol       ; text kapacity
DispOM17:mov       cl,ss:[bp-4]             ; ¨¡©ka okna
         mov       dx,ss:[bp-2]             ; pozice k zobrazen¡ © dku
         mov       ax,ss:[bp-6]             ; hladina k zobrazen¡ menu
         call      far ptr DispTxtM         ; zobrazen¡ textov‚ho © dku
         jmp       DispOM82                 ; dal¨¡ © dek

DispOM18:jmp       DispOMn8                 ; nen¡ © dek mapy

; ------ zobrazen¡ horn¡ho okraje mapy (CX=d‚lka mapy)

DispOMn2:mov       ah,ds:[ColFRam]          ; barva r mu
         mov       al,"Ú"                   ; "Ú"
         stosw                              ; lev˜ horn¡ roh
         mov       al,"Â"                   ; "Â"
         rep       stosw                    ; st©edn¡ linky
         mov       al,"¿"                   ; "¿"
         stosw
         mov       byte ptr ss:[bp-8],0     ; nulov n¡ ukazatele ‡¡sla strany
         jmp       short DispOM18

; ------ test, zda je platn‚ ‡¡slo strany

DispOMn3:cmp       bh,ds:[FStran]           ; je platn‚ ‡¡slo strany ?
         jb        DispOM30                 ; ‡¡slo strany je OK
         jmp       DispOMn4

; ------ dek¢dov n¡ textu "strana" (CX=d‚lka mapy)

DispOM30:sub       di,9*2                   ; po‡ tek k ulo‘en¡ textu
         mov       ah,ds:[ColMnu1]          ; bˆ‘n  barva menu
         mov       si,offset TextFStr
         push      cx
         mov       cl,7                     ; d‚lka textu
DispOM31:lodsb
         stosw
         loop      DispOM31
         pop       cx

; ------ ‡¡slo strany

         mov       al,bh                    ; AL <- ‡¡slo strany
         add       al,"0"                   ; korekce na ASCII znak
         stosw                              ; ulo‘en¡ ‡¡sla strany
         inc       di
         inc       di

; ------ lev˜ okraj r mu

         mov       al,"³"                   ; "³"
         mov       ah,ds:[ColFRam]          ; barva r mu
         stosw

; ------ ukazatel aktu ln¡ operace (CX=d‚lka mapy, BH=strana, BL=stopa)

DispOM32:cmp       bl,ds:[FStopAkt]         ; je to aktu ln¡ stopa ?
         jne       DispOM33                 ; nen¡ aktu ln¡ stopa
         cmp       bh,ds:[FStrnAkt]         ; je to aktu ln¡ strana ?
         jne       DispOM33                 ; nen¡ to aktu ln¡ strana
         cmp       byte ptr ds:[FOper],1    ; je nˆjak  operace ?
         jb        DispOM33                 ; nen¡ operace
         mov       ah,ds:[ColFForm]         ; barva ukazatele
         mov       al,"F"                   ; form tov n¡
         je        DispOM38                 ; je form tov n¡
         cmp       byte ptr ds:[FOper],3    ; je z pis ?
         mov       al,"V"                   ; verifikace
         jb        DispOM38                 ; je verifikace
         mov       al,"W"                   ; z pis
         je        DispOM38                 ; je z pis
         mov       al,"R"                   ; ‡ten¡
         jmp       short DispOM38           ; je ‡ten¡

; ------ barva vnit©ku mapy

DispOM33:mov       ah,ds:[ColFNul]          ; barva neinicializovan‚ pozice
         mov       al,"°"                   ; znak neinicializovan‚ pozice
         cmp       bl,ds:[FStopIni]         ; je stopa inicializovan  ?
         jne       DispOM34
         cmp       bh,ds:[FStrnIni]         ; je strana inicializovan  ?
DispOM34:jae       DispOM38                 ; nen¡ inicializovan 

         call      DispOTst                 ; test stopy BL strana BH
         mov       ah,ds:[ColFOK]           ; barva OK
         mov       al,"²"                   ; znak OK
         jnc       DispOM38                 ; nebyla chyba
         mov       ah,ds:[ColFErr]          ; barva chyby
         mov       al,"x"                   ; znak chyby

DispOM38:stosw                              ; ulo‘en¡ znaku
         inc       bx                       ; zv˜¨en¡ ukazatele ‡¡sla stopy
         loop      DispOM32                 ; dal¨¡ znak

; ------ prav˜ okraj r mu

         mov       al,"³"                   ; "³"
         mov       ah,ds:[ColFRam]          ; barva r mu
         stosw
         jmp       short DispOMn7

; ------ doln¡ okraj mapy (CX=d‚lka mapy, BL=stopa)

DispOMn4:ja        DispOMn5                 ; ‡¡slo strany nen¡ platn‚

         mov       ah,ds:[ColFRam]          ; barva r mu
         mov       al,"À"                   ; "À" lev˜ doln¡ okraj
         stosw

         mov       bh,5                     ; dˆlitel
DispOM42:push      ax
         mov       al,bl                    ; ‡¡slo stopy
         mov       ah,0
         div       bh                       ; dˆlitelnost 5
         or        ah,ah                    ; je ‡¡slo dˆliteln‚ 5 ?
         pop       ax
         mov       al,"Á"                   ; "Á" nen¡ dˆliteln‚ 5
         jnz       DispOM44                 ; nen¡ dˆliteln‚ 5
         mov       al,"Å"                   ; "Å" je dˆliteln‚ 5
DispOM44:stosw                              ; ulo‘en¡ znaku

         inc       bx                       ; zv˜¨en¡ ukazatele ‡¡sla stopy
         loop      DispOM42                 ; dal¨¡ znak

         mov       al,"Ù"                   ; "Ù" prav˜ doln¡ okraj
         stosw
         jmp       short DispOMn7

; ------ © dek s ‡¡sly v lc– (CX=d‚lka mapy, BL=stopa)

DispOMn5:mov       bh,5                     ; dˆlitel
DispOM52:push      ax
         mov       al,bl                    ; ‡¡slo stopy
         mov       ah,0
         div       bh                       ; dˆlitelnost 5
         or        ah,ah                    ; je ‡¡slo dˆliteln‚ 5 ?
         pop       ax
         jnz       DispOM56                 ; nen¡ dˆliteln‚ 5

         push      ax
         mov       al,bl                    ; ‡¡slo stopy
         aam                                ; rozdˆlen¡ na BCD ‡¡slice
         add       ax,"00"                  ; korekce na ASCII znaky
         mov       es:[di+2],al             ; ulo‘en¡ ni‘¨¡ ‡¡slice
         cmp       ah,"0"                   ; je vy¨¨¡ ‡¡slice "0" ?
         je        DispOM54                 ; nev˜znamn  0 se potla‡¡
         mov       es:[di],ah               ; ulo‘en¡ vy¨¨¡ ‡¡slice
DispOM54:pop       ax

DispOM56:inc       di
         inc       di                       ; zv˜¨en¡ ukl dac¡ adresy
         inc       bx                       ; zv˜¨en¡ ukazatele ‡¡sla stopy
         loop      DispOM52                 ; dal¨¡ znak

; ------ p©¡prava pro dal¨¡ mapu

         mov       byte ptr ss:[bp-11],126  ; nebude dal¨¡ © dek
         mov       al,ss:[bp-10]            ; v lec konce mapy
         cmp       al,ds:[FStop]            ; je to ji‘ konec ?
         jae       DispOMn7                 ; je to ji‘ konec
         mov       ss:[bp-9],al             ; bude to v lec po‡ tku pole
         mov       al,ds:[FStop]            ; po‡et stop
         mov       ss:[bp-10],al            ; nov˜ konec pole
         mov       byte ptr ss:[bp-11],2    ; vzd lenost dal¨¡ mapy

; ------ © dek s ‡¡slicemi

DispOMn7:inc       byte ptr ss:[bp-8]       ; zv˜¨en¡ ukazatele ‡¡sla strany

; ------ zobrazen¡ © dku menu

DispOMn8:mov       si,sp                    ; buffer v z sobn¡ku
         mov       cl,ss:[bp-4]             ; ¨¡©ka okna
         mov       dx,ss:[bp-2]             ; pozice k zobrazen¡ © dku
         mov       ax,ss:[bp-6]             ; hladina k zobrazen¡ menu
         call      far ptr DispKStr         ; zobrazen¡ © dku menu

; ------ p©¡prava pro dal¨¡ © dek

DispOM82:inc       byte ptr ss:[bp-1]       ; zv˜¨en¡ ukazatele © dk–
         inc       byte ptr ss:[bp-7]       ; zv˜¨en¡ relat. ukazatele © dku
         dec       byte ptr ss:[bp-3]       ; sn¡‘en¡ ‡¡ta‡e © dk–
         jz        DispOMn9                 ; jsou ji‘ v¨echny © dky
         jmp       DispOMn1                 ; dek¢dov n¡ dal¨¡ho © dku

; ------ n vrat registr–

DispOMn9:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispOMnu ENDP

; -----------------------------------------------------------------------------
;        test stopy BL, strana BH, zda obsahuje chybu -> CY=je chyba
; -----------------------------------------------------------------------------

DispOTst PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx

; ------ v˜po‡et po‡ te‡n¡ho sektoru -> AX

         mov       al,bl                    ; AL <- stopa
         mul       byte ptr ds:[FStran]     ; p©epo‡et na absolutn¡ stranu
         add       al,bh                    ; p©i‡ten¡ ‡¡sla strany
         mov       cl,ds:[FSekt]            ; po‡et sektor– na stopu
         mul       cl                       ; p©epo‡et na absolutn¡ sektor

; ------ nalezen¡ vadn‚ho sektoru

DispOTs2:call      FGetErr                  ; je sektor vadn˜ ?
         jc        DispOTs9                 ; sektor je vadn˜
         inc       ax                       ; zv˜¨en¡ ukazatele ‡¡sla sektoru
         loop      DispOTs2                 ; test dal¨¡ho sektoru

; ------ n vrat registr–

DispOTs9:pop       cx
         pop       ax
         ret

DispOTst ENDP

; -----------------------------------------------------------------------------
;        inicializace hl ¨en¡ o vadn˜ch sektorech
; -----------------------------------------------------------------------------

FIniVad  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      di
         push      es

; ------ spo‡ten¡ vadn˜ch dat

         mov       bx,2                     ; po‡ te‡n¡ aloka‡n¡ blok
         mov       cx,ds:[FBlokN]           ; po‡et blok– celkem
         xor       ax,ax                    ; ‡¡ta‡ vadn˜ch blok–
FIniVad2:call      FBlokErr                 ; test bloku BX
         adc       ax,0                     ; ‡¡t n¡ vadn˜ch blok–
         inc       bx                       ; zv˜¨en¡ ‡¡sla bloku
         loop      FIniVad2                 ; test dal¨¡ho bloku
         mul       word ptr ds:[FBlokB]     ; p©epo‡et na bajty

; ------ dek¢dov n¡ textu pro hl ¨en¡

         push      ds
         pop       es                       ; ES <- datov˜ segment
         mov       di,offset FormMPl2+1     ; buffer k dek¢dov n¡
         mov       bh,0                     ; barva nen¡
         mov       bl,ds:[OddelRad]         ; oddˆlova‡ © d–
         call      far ptr DekNum           ; dek¢dov n¡ ‡¡sla
         sub       di,offset FormMPl2+1     ; d‚lka textu
         xchg      ax,di
         mov       ds:[FormMPl2],al         ; d‚lka textu

; ------ n vrat registr–

         pop       es
         pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

FIniVad  ENDP

; -----------------------------------------------------------------------------
;        poskytnut¡ p©¡znaku chyby pro blok BX -> CY=je chyba
; -----------------------------------------------------------------------------

FBlokErr PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      dx

; ------ v˜po‡et absolutn¡ho sektoru

         mov       ch,0
         mov       cl,ds:[FBlok]            ; po‡et sektor– na blok
         mov       ax,bx                    ; AX <- ‡¡slo bloku
         dec       ax
         dec       ax                       ; AX <- ‡¡slo bloku relativnˆ
         mul       cx                       ; p©epo‡et bloku na sektor
         add       ax,ds:[FRoot]            ; p©i‡ten¡ sektor– na ROOT
         add       ax,ds:[FFat]             ; p©i‡ten¡ sektor– na FAT1
         add       ax,ds:[FFat]             ; p©i‡ten¡ sektor– na FAT2
         inc       ax                       ; p©i‡ten¡ BOOT sektoru

; ------ test chyb v bloku

FBlkErr2:call      FGetErr                  ; test chyby sektoru AX
         jc        FBlkErr8                 ; nalezena chyba
         inc       ax                       ; zv˜¨en¡ ‡¡sla sektoru
         loop      FBlkErr2                 ; test dal¨¡ho sektoru

; ------ n vrat registr–

FBlkErr8:pop       dx
         pop       cx
         pop       ax
         ret

FBlokErr ENDP

; -----------------------------------------------------------------------------
;        poskytnut¡ p©¡znaku chyby pro sektor AX -> CY=je chyba
; -----------------------------------------------------------------------------

FGetErr  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      es

; ------ sektor mimo rozsah je OK

         cmp       ax,ds:[FSektN]           ; je sektor platn˜ ?
         jae       FGetErr9                 ; sektor mimo rozsah je OK
         xchg      ax,bx                    ; BX <- ‡¡slo sektoru

; ------ adresa bufferu -> ES

         mov       ax,ds:[FormESeg]         ; segment mapy chyb
         call      far ptr GetDat           ; adresa bufferu -> ES

; ------ offset bajtu v bufferu

         mov       cl,bl                    ; CL <- ‡¡slo sektoru LOW
         shr       bx,1
         shr       bx,1
         shr       bx,1                     ; BX <- offset bajtu v bufferu

; ------ bitov  maska

         and       cl,7                     ; CL <- pozice bitu
         mov       al,bit0                  ; maska
         shl       al,cl                    ; rotace bitu na pozici

; ------ test bitu

         test      byte ptr es:[bx],al      ; test bitu
         jz        FGetErr9                 ; nen¡ chyba
         stc                                ; p©¡znak chyby

; ------ n vrat registr–

FGetErr9:pop       es
         pop       cx
         pop       bx
         pop       ax
         ret

FGetErr  ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ p©¡znaku chyby pro sektor AX
; -----------------------------------------------------------------------------

FSetErr  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      es

; ------ test, je-li sektor mimo rozsah

         cmp       ax,ds:[FSektN]           ; je sektor platn˜ ?
         jae       FSetErr9                 ; sektor mimo rozsah

; ------ nastaven¡ p©¡znaku chyby

         or        byte ptr ds:[FormParm],bit7 ; byla nˆjak  chyba
         cmp       ax,ds:[FData]            ; je to syst‚mov  oblast ?
         jae       FSetErr2                 ; jsou to platn  data

         mov       bx,ds:[FFat]             ; BX <- po‡et sektor– na FAT tabulku
         cmp       ax,bx                    ; je BOOT nebo FAT 1 ?
         jbe       FSetErr1                 ; je BOOT nebo FAT 1
         shl       bx,1                     ; konec FAT 2
         cmp       ax,bx                    ; je FAT 2 ?
         jbe       FSetErr2                 ; je FAT 2 - ta se ignoruje
FSetErr1:or        byte ptr ds:[FormParm],bit6 ; chyba v syst‚mov‚ oblasti
FSetErr2:xchg      ax,bx                    ; BX <- ‡¡slo sektoru

; ------ adresa bufferu -> ES

         mov       ax,ds:[FormESeg]         ; segment mapy chyb
         call      far ptr GetDat           ; adresa bufferu -> ES

; ------ offset bajtu v bufferu

         mov       cl,bl                    ; CL <- ‡¡slo sektoru LOW
         shr       bx,1
         shr       bx,1
         shr       bx,1                     ; BX <- offset bajtu v bufferu

; ------ bitov  maska

         and       cl,7                     ; CL <- pozice bitu
         mov       al,bit0                  ; maska
         shl       al,cl                    ; rotace bitu na pozici

; ------ nastaven¡ bitu

         or        byte ptr es:[bx],al      ; nastaven¡ bitu

; ------ n vrat registr–

FSetErr9:pop       es
         pop       cx
         pop       bx
         pop       ax
         ret

FSetErr  ENDP

; -----------------------------------------------------------------------------
;        poskytnut¡ typu mechaniky disku BL (+nastaven¡ disku) -> AL (CY=nen¡)
; -----------------------------------------------------------------------------

FIniDTyp PROC      NEAR

         mov       ds:[FAktDisk],bl         ; £schova ‡¡sla disku

; ------ test, zda je disk platn˜

         mov       ah,15h
         call      Int13                    ; test, zda je disk platn˜
         jc        FIniDTp8                 ; nˆjak  chyba
         or        ah,ah                    ; je disk ?
         stc                                ; p©¡znak neplatnosti disku
         jz        FIniDTp8                 ; nen¡ disk

; ------ detekce typu disku

         mov       ah,8                     ; funkce 8
         mov       bl,1                     ; p©ednastaven¡ 360 KB
         call      Int13                    ; poskytnut¡ parametr– disku
         jc        FIniDTp7                 ; chyba
         or        ah,ah
         jnz       FIniDTp7                 ; chyba
         or        bl,bl                    ; je platn˜ disk ?
         jz        FIniDTp7                 ; neplatn˜ disk
         cmp       bl,5                     ; platn‚ ‡¡slo disku ?
         mov       al,5                     ; omezen¡ ‡¡sla disku
         jae       FIniDTp9
         xchg      ax,bx                    ; AL <- typ disku
         clc                                ; p©¡znak operace OK
         jmp       short FIniDTp9

; ------ ulo‘en¡ typu mechaniky

FIniDTp7:clc
FIniDTp8:mov       al,1                     ; mechanika 360 KB
FIniDTp9:mov       ds:[FTypDisk],al         ; typ aktivn¡ mechaniky
         ret

FIniDTyp ENDP

; -----------------------------------------------------------------------------
;        reset diskov‚ho syst‚mu
; -----------------------------------------------------------------------------

FResDisk PROC      NEAR

         push      ax
         mov       ah,0
         call      Int130
         pop       ax
         ret

FResDisk ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 13 s £schovou v¨ech registr– (kromˆ AX)
; -----------------------------------------------------------------------------

Int130   PROC      NEAR

         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

         call      Int13

         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         ret

Int130   ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 13 s £schovou hlavn¡ch registr–
; -----------------------------------------------------------------------------

Int13    PROC      NEAR

         push      bp
         push      ds

         sti
         mov       dl,ds:[FAktDisk]         ; aktivn¡ disk
         int       13h

         pop       ds
         pop       bp
         ret

Int13    ENDP

; -----------------------------------------------------------------------------
;        BOOT sektor
; -----------------------------------------------------------------------------

NOCOM    EQU       1                        ; p©¡znak pro p©eklad jako INCLUDE
INCLUDE  DOSMFLOP\DOSMFLOP.ASM              ; BOOT sektor

CodeDisk ENDS

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;
;                                 Data
;
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;þ
Data     SEGMENT

; -----------------------------------------------------------------------------
;        hl ¨en¡ p©i parkov n¡
; -----------------------------------------------------------------------------

PrkMnu1  label     byte

         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        1                        ; po‡et platn˜ch polo‘ek menu
         dw        8                        ; celkov˜ po‡et polo‘ek menu

         dw        PrkMnu1P                 ; za‡ tek definice polo‘ek menu
         dw        PrkMnu1H                 ; adresa tabulky text– n povˆdy
         dw        Hlp@Parkovani            ; ‡¡slo str nky velk‚ n povˆdy
         dw        PrkMnu1B                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        PrkMnu1T                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        23                       ; po‡ te‡n¡ pozice okna
         db        7                        ; po‡ te‡n¡ © dek okna
         db        44                       ; ¨¡©ka okna
         db        12                       ; v˜¨ka okna

         dw        255                      ; maxim ln¡ d‚lka textu © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        0                        ; celkov˜ po‡et © dk–
         dw        0                        ; po‡et zobrazen˜ch © dk–

         db        bit3                     ; maska zad van˜ch znak–
         db        0,'      '               ; zak zan‚ znaky

         db        HistFile                 ; historie specifikac¡ soubor–
         db        0                        ; po‡et p©edvoleb

PrkMnu1P db        bit6,0
         db        bit6,28,'Pevn‚ disky zaparkov ny ('
PrkMn1P1 db        '0),'
         db        bit6,34,'po‡¡ta‡ uveden do klidov‚ho stavu.'
         db        bit6,0
         db        bit6,29,0,'Nyn¡ m–‘ete po‡¡ta‡ vypnout.'
         db        bit6,0
         db        bit6+bit7,0
         db        1,6,'N vrat'

PrkMnu1T db        9,'parkov n¡'

PrkMnu1B db        0                        ; blokovac¡ tabulka

HelpS    SEGMENT   BYTE PUBLIC
PrkMnu1H db        71,'Vypnˆte po‡¡ta‡ nebo se navraŸte zpˆt stiskem kl ves Esc nebo Enter'
HelpS    ENDS

ParkTxt  db        36,'Uv d¡m po‡¡ta‡ do klidov‚ho stavu...'

; -----------------------------------------------------------------------------
;        zad n¡ jm‚na disku
; -----------------------------------------------------------------------------
;þ
LabMnLin label     byte                   ;* menu vytvo©en¡ adres ©e

         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        3                        ; po‡et platn˜ch polo‘ek menu
         dw        5                        ; celkov˜ po‡et polo‘ek menu

         dw        LabMnPol                 ; za‡ tek definice polo‘ek menu
         dw        LabMnHlp                 ; adresa tabulky text– n povˆdy
         dw        Hlp@ZmenaJmenaDisku      ; ‡¡slo str nky velk‚ n povˆdy
         dw        LabMnBlk                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        LabMnTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        20                       ; po‡ te‡n¡ pozice okna
         db        0                        ; po‡ te‡n¡ © dek okna
         db        48                       ; ¨¡©ka okna
         db        8                        ; v˜¨ka okna

         dw        13                       ; maxim. d‚lka textu © dku (+ disk:)
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        1                        ; celkov˜ po‡et © dk–
         dw        1                        ; po‡et zobrazen˜ch © dk–

         db        bit3                     ; maska zad van˜ch znak– - soubor
         db        4,'\?.*  '               ; zak zan‚ znaky

         db        HistFile                 ; historie specifikac¡ soubor–
LabsNum  db        1                        ; po‡et p©edvoleb

LabsDelk dw        0                        ; d‚lka p©edvolby
         dd        LabsNam                  ; adresa p©edvolby

; ------ polo‘ky voleb

LabMnPol db        bit6,3,1
LabMnPl1 dw        LabsMnT1
         db        0,0
         db        bit6+bit7,0
         db        1,4,'Zmˆ¤'
         db        1,6,'N vrat'

LabMnBlk db        0,0,0                    ; blokovac¡ tabulka

LabMnTit db        11,'jm‚no disku'

; ------ n povˆda

HelpS    SEGMENT   BYTE PUBLIC
LabMnHlp db        71,'Zadejte nov‚ jm‚no disku 1 a‘ 11 znak–, 0 znak– = zru¨en¡ star‚ho jm‚na'
         db        30,'Zmˆna jm‚na disku podle zad n¡'
         db        3,1
         dw        MenuHlP1
HelpS    ENDS

LabsMnT1 db        27,'Disk ',0
LabsMnT2 db        'A:',0,' nem  ‘ dn‚ jm‚no.'

LabsMnT3 db        32,'Sou‡asn‚ jm‚no disku '
LabsMnT4 db        'A: je "',0              ; to je sou‡asnˆ pracovn¡ disk
LabsNam  db        '"',0,'.',11 dup(0)      ; buffer aktu ln¡ho jm‚na disku

LabSHl1  db        22,'Na‡¡t m jm‚no disku...'
LabSHl2  db        24,'Nastavuji jm‚no disku...'

; -----------------------------------------------------------------------------
;        form tov n¡
; -----------------------------------------------------------------------------
;þ
; ------ menu volby mechaniky

FrmDMnu  label     BYTE
         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        3                        ; po‡et platn˜ch polo‘ek menu
         dw        8                        ; celkov˜ po‡et polo‘ek menu

         dw        FrmDMPol                 ; za‡ tek definice polo‘ek menu
         dw        FrmDMHlp                 ; adresa tabulky text– n povˆdy
         dw        Hlp@FormatovaniDisket    ; ‡¡slo str nky velk‚ n povˆdy
         dw        FrmDMBlk                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        FrmDMTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        23                       ; po‡ te‡n¡ pozice okna
         db        7                        ; po‡ te‡n¡ © dek okna
         db        49                       ; ¨¡©ka okna
         db        10                       ; v˜¨ka okna

         dw        255                      ; maxim ln¡ d‚lka textu © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        0                        ; celkov˜ po‡et © dk–
         dw        0                        ; po‡et zobrazen˜ch © dk–

         db        bit3                     ; maska zad van˜ch znak–
         db        0,'      '               ; zak zan‚ znaky

         db        0                        ; historie specifikac¡ soubor–
         db        0                        ; po‡et p©edvoleb

FrmDMPol db        bit6,0
         db        bit6,43,'Zvolte disketovou mechaniku ',0,'A:',0,' nebo ',0,'B:',0,','
         db        bit6,38,'ve kter‚ probˆhne form tov n¡ diskety:'
         db        bit6,0
         db        bit6+bit7,0
         db        3,6,'  A:  '
         db        3,6,'  B:  '
         db        1,9,'P©eru¨en¡'

FrmDMTit db        19,'form tov n¡ diskety'

FrmDMBlk db        0,0,0                    ; blokovac¡ tabulka

HelpS    SEGMENT   BYTE PUBLIC
FrmDMHlp db        5,1
         dw        FrmDMHl1
         db        'A:'

         db        5,1
         dw        FrmDMHl1
         db        'B:'

         db        3,1
         dw        MenuHlP2
HelpS    ENDS

FrmDMHl1 db        33,'Form tov n¡ diskety v mechanice '

; ------ volba form tu diskety

FrmD2Mnu label     BYTE
         db        2                        ; typ menu - vertik ln¡ podmenu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka volby
         dw        MAXFORM                  ; po‡et platn˜ch polo‘ek menu
         dw        MAXFORM                  ; celkov˜ po‡et polo‘ek menu

         dw        FrmD2MnP                 ; defini‡n¡ tabulka polo‘ek
         dw        FrmD2MnH                 ; n povˆda
         dw        Hlp@FormatyDisket        ; ‡¡slo str nky velk‚ n povˆdy
         dw        FrmD2MnB                 ; blokovac¡ tabulka
         dw        0                        ; p©ep¡na‡e
         dw        FrmD2MnT                 ; adresa titulu okna
         dw        FrmD2MnE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        36                       ; po‡ te‡n¡ pozice
         db        10                       ; po‡ te‡n¡ © dek
         db        20                       ; ¨¡©ka okna
         db        MAXFORM+2                ; v˜¨ka okna

FrmD2MnP label     byte
X = 0
         REPT      9
         db        1,14,"1"+X,':          DD'
X = X + 1
         ENDM

X = 0
         REPT      MAXFORM-9
         db        1,14,"A"+X,':          DD'
X = X + 1
         ENDM

FrmD2MnB db        MAXFORM dup(0)           ; blokovac¡ tabulka

FrmD2MnT db        7,'disk A:'

HelpS    SEGMENT   BYTE PUBLIC
FrmD2MnH label     byte

         REPT      MAXFORM
         db        3,1
         dw        FrmD2MH2
         ENDM

HelpS    ENDS

FrmD2MnE label     dword

         REPT      MAXFORM
         dd        Format2
         ENDM

FrmD2MH2 db        40,'Form tov n¡ diskety na zvolenou kapacitu'

; ------ potvrzen¡ p©ed form tov n¡m

FrmD3Mnu label     byte

         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        6                        ; po‡et platn˜ch polo‘ek menu
         dw        13                       ; celkov˜ po‡et polo‘ek menu

         dw        FrmD3MnP                 ; za‡ tek definice polo‘ek menu
         dw        FrmD3MnH                 ; adresa tabulky text– n povˆdy
         dw        Hlp@FormatovaniDisket    ; ‡¡slo str nky velk‚ n povˆdy
         dw        FrmD3MnB                 ; adresa blokovac¡ tabulky
         dw        FrmD3MnS                 ; adresa tabulky p©ep¡na‡–
         dw        FrmD3MnT                 ; adresa titulu okna
         dw        FrmD3MnE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        23                       ; po‡ te‡n¡ pozice okna
         db        7                        ; po‡ te‡n¡ © dek okna
         db        76                       ; ¨¡©ka okna
         db        12                       ; v˜¨ka okna

         dw        255                      ; maxim ln¡ d‚lka textu © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        0                        ; celkov˜ po‡et © dk–
         dw        0                        ; po‡et zobrazen˜ch © dk–

         db        bit3                     ; maska zad van˜ch znak–
         db        0,'      '               ; zak zan‚ znaky

         db        HistFile                 ; historie specifikac¡ soubor–
         db        0                        ; po‡et p©edvoleb

FrmD3MnP db        bit6,0

         db        bit6,13,0,'* VAROVN‹ *'

         db        bit6,42,'Disketa v mechanice '
FrmD3MP2 db        'A: bude zform tov na !'

         db        bit6,27,'Voln  kapacita: ',0,1
         dw        FrmD3MP3
         db        0,' Bajt–'

         db        bit6,0

         db        bit6,offset(FrmD3Mp6-FrmD3Mp4)
FrmD3MP4 db        '(H'
FrmD3MP5 db        '2 T',1
         dw        FrmD3Mp7                 ; po‡et stop
         db        ' N',1
         dw        FrmD3Mp8                 ; po‡et sektor– na stopu
         db        ' R',1
         dw        FrmD3Mp9                 ; po‡et polo‘ek ROOT
         db        ' C',1
         dw        FrmD3MpB                 ; po‡et sektor– na aloka‡n¡ blok
         db        ' - F',1
         dw        FrmD3MpA                 ; po‡et sektor– FAT
         db        ' O',1
         dw        FrmD3MpD                 ; p©enosov  rychlost
         db        ' G',1
         dw        FrmD3MpE                 ; mezisektorov  mezera
         db        ' I'
FrmD3M52 db        '1 J'                    ; prokl d n¡
FrmD3M53 db        '1 X'                    ; krokov n¡
FrmD3M54 db        '1 Y'                    ; odsazov n¡ X
FrmD3M55 db        '1 M'                    ; odsazov n¡ Y
FrmD3M56 db        '00 !',1                 ; popisova‡ m‚dia
         dw        FrmD3MpC                 ; po‡et nevyu‘it˜ch sektor–
         db        ')'
FrmD3Mp6 label     byte

         db        bit6+bit7,0
         db        1,8,'Form tuj'
         db        1+bit7,7,'Jm‚no '
FrmD3MS1 db        '-'
         db        1+bit7,12,'Verifikace '
FrmD3MS2 db        '-'
         db        1+bit7,10,'Indikace '
FrmD3MS3 db        '-'
         db        1+bit7,7,'Z pis '
FrmD3MS4 db        '-'
         db        1,6,'N vrat'

FrmD3MnT db        11,'form tov n¡'

; ------ nemˆnit po©ad¡ a d‚lku polo‘ek (vyu‘¡v  se pevn  d‚lka)

FrmD3MP3 db        0,'          '           ; voln  kapacita diskety
FrmD3Mp7 db        0,'   '                  ; po‡et stop
FrmD3Mp8 db        0,'   '                  ; po‡et sektor– na stopu
FrmD3Mp9 db        0,'   '                  ; po‡et polo‘ek ROOT
FrmD3MpA db        0,'   '                  ; po‡et sektor– FAT
FrmD3MpB db        0,'   '                  ; po‡et sektor– na aloka‡n¡ blok
FrmD3MpC db        0,'   '                  ; po‡et nevyu‘it˜ch sektor–
FrmD3MpE db        0,'   '                  ; mezisektorov  mezera
FrmD3MpD db        0,'    '                 ; p©enosov  rychlost (posledn¡ !)

FrmD3MnB db        0,0,0,0,0,0              ; blokovac¡ tabulka

FrmD3MnS db        0,0,0,0                  ; p©ep¡na‡e

HelpS    SEGMENT   BYTE PUBLIC
FrmD3MnH db        28,'Zah jen¡ form tov n¡ diskety'
         db        56,'P©ed form tov n¡m bude zad no jm‚no disku (VOLUME LABEL)'
         db        50,'Po z pisu bude disketa ovˆ©ov na kontroln¡m ‡ten¡m'
         db        42,'Ukon‡en¡ form tov n¡ bude zvukovˆ ohl ¨eno'
         db        50,'Ovˆ©ov n¡ spolehlivosti diskety testovac¡m z pisem'
         db        3,1
         dw        MenuHlP2
HelpS    ENDS

FrmD3MnE label     dword
         dd        Lin0MenR                 ; Form tuj
         dd        FrmD3Ex2                 ; Jm‚no
         dd        FrmD3Ex3                 ; Verifikace
         dd        FrmD3Ex4                 ; Indikace
         dd        FrmD3Ex5                 ; Z pis
         dd        Lin0MenR                 ; N vrat

; ------ okno form tov n¡
;þ
FormMnu  label     byte
         db        12                       ; typ menu - form tov n¡ disket

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        1                        ; po‡et platn˜ch polo‘ek menu
         dw        1                        ; celkov˜ po‡et polo‘ek menu

         dw        0                        ; adresa definice polo‘ek menu
         dw        FormMHlp                 ; adresa n povˆd
         dw        Hlp@FormatovaniDisket    ; ‡¡slo str nky velk‚ n povˆdy
         dw        0                        ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        FormMTit                 ; adresa titulu okna
         dw        LinMenTM                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        3                        ; po‡ te‡n¡ pozice
         db        1                        ; po‡ te‡n¡ © dek
         db        68                       ; ¨¡©ka
         db        17                       ; v˜¨ka

FormMPl1 db        bit6,43,'Jm‚no disku ',0,1
FormMPl5 dw        FormMPl6
         db        0,', s‚riov‚ ‡¡slo ',0
FormMPl4 db        '0000-0000'

FormMPol db        bit6,32,'Kapacita ',0,1
         dw        FrmD3MP3
         db        0,' B (vadn‚ ',0,1
         dw        FormMPl2
         db        0,' B)'

FormMPl2 db        0,'          '           ; vadn  kapacita diskety

FormMPl3 db        0,11 dup(0)              ; buffer jm‚na disku

FormMPl6 db        1,'-'

FormMTit db        11,'form tov n¡'

HelpS    SEGMENT   BYTE PUBLIC
FormMHlp db        76,'Stisknˆte: Enter=dal¨¡ disketa (pozor - bude p©eps na !), Esc=konec...'
HelpS    ENDS

TextFStr db        'strana '

; ------ zad n¡ jm‚na disku

FLabMnu  label     byte                   ;* menu vytvo©en¡ adres ©e
         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        3                        ; po‡et platn˜ch polo‘ek menu
         dw        5                        ; celkov˜ po‡et polo‘ek menu

         dw        FLabMnuP                 ; za‡ tek definice polo‘ek menu
         dw        FLabMnuH                 ; adresa tabulky text– n povˆdy
         dw        Hlp@FormatovaniDisket    ; ‡¡slo str nky velk‚ n povˆdy
         dw        FLabMnuB                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        LabMnTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        20                       ; po‡ te‡n¡ pozice okna
         db        0                        ; po‡ te‡n¡ © dek okna
         db        48                       ; ¨¡©ka okna
         db        8                        ; v˜¨ka okna

         dw        11                       ; maxim. d‚lka textu © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        1                        ; celkov˜ po‡et © dk–
         dw        1                        ; po‡et zobrazen˜ch © dk–

         db        bit3                     ; maska zad van˜ch znak– - soubor
         db        5,'\?.*: '               ; zak zan‚ znaky

         db        HistFile                 ; historie specifikac¡ soubor–
FLabMnPN db        1                        ; po‡et p©edvoleb
FLabMnPD dw        0                        ; d‚lka p©edvolby
         dd        FormMPl3+1               ; adresa p©edvolby

FLabMnuP db        bit6,20,'Zadejte jm‚no disku:'
         db        0,0
         db        bit6+bit7,0
         db        1,8,'Nastavit'
         db        1,8,'P©eru¨it'

FLabMnuB db        0,0,0                    ; blokovac¡ tabulka

HelpS    SEGMENT   BYTE PUBLIC
FLabMnuH db        68,'Zadejte jm‚no disku 0 a‘ 11 znak– (‡¡slo automaticky inkrementov no)'
         db        34,'Nastaven¡ jm‚na disku podle zad n¡'
         db        3,1
         dw        MenuHlP1
HelpS    ENDS

; ------ chybov‚ hl ¨en¡ - disketa nep©ipravena

FrmRdyMn label     byte

         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        1                        ; po‡et platn˜ch polo‘ek menu
         dw        6                        ; celkov˜ po‡et polo‘ek menu

         dw        FrmRdyMP                 ; za‡ tek definice polo‘ek menu
         dw        ChbLnMeH                 ; adresa tabulky text– n povˆdy
         dw        Hlp@FormatovaniDisket    ; ‡¡slo str nky velk‚ n povˆdy
         dw        FrmRdyMB                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        FrmRdyMT                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        23                       ; po‡ te‡n¡ pozice okna
         db        7                        ; po‡ te‡n¡ © dek okna
         db        48                       ; ¨¡©ka okna
         db        10                       ; v˜¨ka okna

         dw        255                      ; maxim ln¡ d‚lka textu © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        0                        ; celkov˜ po‡et © dk–
         dw        0                        ; po‡et zobrazen˜ch © dk–

         db        bit3                     ; maska zad van˜ch znak–
         db        0,'      '               ; zak zan‚ znaky

         db        0                        ; historie
         db        0                        ; po‡et p©edvoleb


FrmRdyMP db        bit6,0
         db        bit6,6,0,'CHYBA'
         db        bit6,40,'Disketa nep©ipravena - vlo‘te ji znovu !'
         db        bit6,0
         db        bit6+bit7,0
         db        1,6,'N vrat'

FrmRdyMT db        20,'disketa nep©ipravena'

FrmRdyMB db        0                        ; blokovac¡ tabulka

; ------ chybov‚ hl ¨en¡ - je ochrana proti z pisu

FrmWPMnu label     byte

         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        1                        ; po‡et platn˜ch polo‘ek menu
         dw        6                        ; celkov˜ po‡et polo‘ek menu

         dw        FrmWPMnP                 ; za‡ tek definice polo‘ek menu
         dw        ChbLnMeH                 ; adresa tabulky text– n povˆdy
         dw        Hlp@FormatovaniDisket    ; ‡¡slo str nky velk‚ n povˆdy
         dw        FrmWPMnB                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        FrmWPMnT                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        23                       ; po‡ te‡n¡ pozice okna
         db        7                        ; po‡ te‡n¡ © dek okna
         db        49                       ; ¨¡©ka okna
         db        10                       ; v˜¨ka okna

         dw        255                      ; maxim ln¡ d‚lka textu © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        0                        ; celkov˜ po‡et © dk–
         dw        0                        ; po‡et zobrazen˜ch © dk–

         db        bit3                     ; maska zad van˜ch znak–
         db        0,'      '               ; zak zan‚ znaky

         db        0                        ; historie
         db        0                        ; po‡et p©edvoleb


FrmWPMnP db        bit6,0
         db        bit6,6,0,'CHYBA'
         db        bit6,43,'Disketa m  nastavenu ochranu proti z pisu !'
         db        bit6,0
         db        bit6+bit7,0
         db        1,6,'N vrat'

FrmWPMnT db        20,'ochrana proti z pisu'

FrmWPMnB db        0                        ; blokovac¡ tabulka

; ------ chybov‚ hl ¨en¡ - chyba v syst‚mov‚ oblasti

FrmSYMnu label     byte

         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        1                        ; po‡et platn˜ch polo‘ek menu
         dw        7                        ; celkov˜ po‡et polo‘ek menu

         dw        FrmSYMnP                 ; za‡ tek definice polo‘ek menu
         dw        ChbLnMeH                 ; adresa tabulky text– n povˆdy
         dw        Hlp@FormatovaniDisket    ; ‡¡slo str nky velk‚ n povˆdy
         dw        FrmSYMnB                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        FrmSYMnT                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        23                       ; po‡ te‡n¡ pozice okna
         db        7                        ; po‡ te‡n¡ © dek okna
         db        41                       ; ¨¡©ka okna
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


FrmSYMnP db        bit6,0
         db        bit6,6,0,'CHYBA'
         db        bit6,35,'Chyba v syst‚mov‚ oblasti diskety !'
         db        bit6,24,'Chybu nelze vykorigovat.'
         db        bit6,0
         db        bit6+bit7,0
         db        1,6,'N vrat'

FrmSYMnT db        25,'chyba v syst‚mov‚ oblasti'

FrmSYMnB db        0                        ; blokovac¡ tabulka

; ------- melodie po ukon‡en¡ form tov n¡

FMelod   db        M16,MG+MO
         db        M16,ME+MO
         db        M16,MC+MO
         db        M16,MG+MO
         db        0

;ColFRam  db        70h                      ; barva r mu mapy form tov n¡
;ColFNul  db        7                        ; barva pr zdn‚ho pole
;ColFOK   db        0ah                      ; barva OK
;ColFErr  db        4eh                      ; barva chyby
;ColFForm db        1eh                      ; zna‡ka form tov n¡

; ------ tabulka INT 1Eh
;þ
Old1E    dd        0                        ; uschovan  adresa INT 1Eh

Int1E    label     byte                     ; vlastn¡ tabulka INT 1eh
Int1ESTP db        0dfh                     ; bity 0 a‘ 3: rychlost krokov n¡
                                            ; bity 4 a‘ 7: ‡as zvednut¡ hlavy
                                            ;  (5 1/4" -> 0DFh, 3 1/2" -> 0AFh)
         db        2                        ; bit 0: 1=je provoz DMA
                                            ; bity 1 a‘ 7: ‡as spu¨tˆn¡ hlavy
         db        36                       ; 2: vypnut¡ motoru v 1/18 sekundy
         db        2                        ; 3: velikost sektoru
Int1ESEC db        9                        ; 4: po‡et sektor– na stopu
Int1EGPR db        42                       ; 5: mezisekt. mezera ‡ten¡/z pis
                                            ;    (DD -> 2Ah, HD -> 1Bh)
         db        255                      ; 6: d‚lka p©en ¨en˜ch dat
Int1EGPF db        80                       ; 7: mezisekt. mezera form tov n¡
Int1EChr db        FormBajt                 ; 8: form tovac¡ bajt
         db        15                       ; 9: doba ust len¡ hlav v [ms]
         db        8                        ; 10: doba pro rozbˆh motoru v 1/8s
Int1ECYL db        39                       ; 11: posledn¡ stopa na disku
Int1ERAT db        80h                      ; 12: p©enosov  rychlost

; ------ tabulka p©enosov˜ch rychlost¡ v B/s (pro v˜po‡et mezisektorov‚ mezery)

RateTab  dd        500000/8                 ; 500 kb/s
         dd        300000/8                 ; 300 kb/s
         dd        250000/8                 ; 250 kb/s
         dd        1000000/8                ; 1000 kb/s

FRandmR  dd        21510d31h                ; promˆnn  pro gener tor n hody

; ------ prim rn¡ parametry form tov n¡ (zadan‚)

FAktDisk db        0                        ; aktivn¡ (pracovn¡) disk (0 a‘ 1)
FTypDisk db        0                        ; typ aktivn¡ho disku (1 a‘ 5)
                                            ;    1 = 360 K
                                            ;    2 = 1.2 M
                                            ;    3 = 720 K
                                            ;    4 = 1.44 M
                                            ;    5 = 2.88 M
FStran   db        0                        ; po‡et stran (1 a‘ 2)
FStop    db        0                        ; po‡et stop disku (1 a‘ 99)
FSekt    db        0                        ; po‡et sektor– na stopu (1 a‘ 50)
FRoot    dw        0                        ; po‡et sektor– na ROOT (1 a‘ 32)
FBlok    db        0                        ; po‡et sektor– na blok (1 a‘ 64)

FormParm db        bit1                     ; p©ep¡na‡e form tov n¡
                                            ;    bit 0: 1=jm‚no disku
                                            ;    bit 1: 1=verifikace
                                            ;    bit 2: 1=indikace konce
                                            ;    bit 3: 1=testovac¡ z pis
                                            ;    bit 4: 1=testovac¡ z pis proveden
                                            ;    bit 5: 1=zad no jm‚no disku
                                            ;    bit 6: 1=chyba v syst. oblasti
                                            ;    bit 7: 1=byla chyba ve stopˆ

; ------ sekund rn¡ parametry form tov n¡ (odvozen‚)

FRootN   dw        0                        ; po‡et polo‘ek na ROOT (16 a‘ 512)
FBlokB   dw        0                        ; po‡et bajt– na aloka‡n¡ blok
FSektN   dw        0                        ; celkov˜ po‡et sektor– disku
FKrok    db        0                        ; p©¡rustek krokov n¡ stopy (1 a‘ 2)
FRate    db        0                        ; p©enosov  rychlost (0 a‘ 3)
                                            ;     0 = 500 kb/s
                                            ;     1 = 300 kb/s
                                            ;     2 = 250 kb/s
                                            ;     3 = 1000 kb/s
FGap     db        0                        ; mezisektorov  mezera (1 a‘ 255)
FInterl  db        0                        ; prokl d n¡ sektor– (1 a‘ 2)
FSlidX   db        0                        ; odsazen¡ sektor– stran SLIDING X
FSlidY   db        0                        ; odsazen¡ sektor– stop SLIDING Y
FMedia   db        0                        ; popisova‡ m‚dia
FFat     dw        0                        ; po‡et sektor– na FAT (1 a‘ 255)
FBlokN   dw        0                        ; celkov˜ po‡et datov˜ch blok–
FZbyva   db        0                        ; po‡et p©eb˜vaj¡c¡ch sektor–
FKapac   dd        0                        ; celkov  kapacita disku (bajt–)
FData    dw        0                        ; prvn¡ datov˜ sektor absolutnˆ

; ------ ukazatele prob¡haj¡c¡ operace
; zachovat po©ad¡ stopy a strany ! (pou‘¡v  se pro test strany 0 stopy 0)

FStopAkt db        0                        ; aktivn¡ stopa
FStrnAkt db        0                        ; aktivn¡ strana

FStopIni db        0                        ; p©¡¨t¡ inicializovan  stopa
FStrnIni db        0                        ; p©¡¨t¡ inicializovan  strana

FSlidErr dw        0                        ; rotace sektor– pro sn¡‘en¡ chyby

FOper    db        1                        ; aktu ln¡ operace
                                            ;   0 = nic
                                            ;   1 = form tov n¡
                                            ;   2 = verifikace
                                            ;   3 = z pis
                                            ;   4 = ‡ten¡
; ------ buffery

FormESeg dw        0                        ; segment mapy vadn˜ch sektor–
FormWSeg dw        0                        ; segment pro form. a z p. operace


FormTab  label     byte                     ; tabulky form t– disket
;        0: (1) bit 0 a‘ bit 6: po‡et stop
;               bit 7: 1=nestandardn¡ form t
;        1: (1) bit 0 a‘ bit 6: po‡et sektor– na stopu
;               bit 7: 1=jednostrannˆ
;        2: (1) bit 0 a‘ bit 4: po‡et sektor– ROOT-1 (1 a‘ 32 = 16 a‘ 512)
;               bit 5 a‘ bit 7: mocnina velikosti bloku v sektorech (0 a‘ 6)
;                                 (0=1, 1=2, 2=4, 3=8, 4=16, 5=32, 6=64)
; ------ 360 KB
         db        4
         db        40, 9     ,112/16-1 + 1*bit5 ; 360 KB
         db        40, 8     ,112/16-1 + 1*bit5 ; 320 KB
         db        40, 9+bit7, 64/16-1 + 0*bit5 ; 180 KB
         db        40, 8+bit7, 64/16-1 + 0*bit5 ; 160 KB
         db        (MAXFORM-4) * 3 dup(0)

; ------ 1.2 MB
         db        5
         db        80,15     ,224/16-1 + 0*bit5 ; 1.2 MB
         db        40, 9     ,112/16-1 + 1*bit5 ; 360 KB
         db        40, 8     ,112/16-1 + 1*bit5 ; 320 KB
         db        40, 9+bit7, 64/16-1 + 0*bit5 ; 180 KB
         db        40, 8+bit7, 64/16-1 + 0*bit5 ; 160 KB
         db        (MAXFORM-5) * 3 dup(0)

; ------ 720 KB
         db        1
         db        80, 9     ,112/16-1 + 1*bit5 ; 720 KB
         db        (MAXFORM-1) * 3 dup(0)

; ------ 1.44 MB
         db        2
         db        80,18     ,224/16-1 + 0*bit5 ; 1.44 MB
         db        80, 9     ,112/16-1 + 1*bit5 ; 720 KB
         db        (MAXFORM-2) * 3 dup(0)

; ------ 2.88 MB
         db        3
         db        80,36     ,240/16-1 + 1*bit5 ; 2.88 MB
         db        80,18     ,224/16-1 + 0*bit5 ; 1.44 MB
         db        80, 9     ,112/16-1 + 1*bit5 ; 720 KB
         db        (MAXFORM-3) * 3 dup(0)

FormPTxt db        30,'Prob¡h  form tov n¡ diskety...'

Data     ENDS

         END

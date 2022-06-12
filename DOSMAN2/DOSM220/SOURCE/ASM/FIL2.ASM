
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                                F I L E  -  2
;
;              Obsluha soubor– - Adres ©, V˜bˆr, Filtr, Tisk
;
; =============================================================================
;
; Ve©ejn‚ procedury:
;
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

INCLUDE  ASM\DEF.ASM

CodeFil  SEGMENT   BYTE PUBLIC
         ASSUME    cs:CodeFil,ds:Data

; *****************************************************************************
;
;                    vytvo©en¡ adres ©e (volba "Adres ©")
;
; *****************************************************************************
;þ
; ------ uzav©en¡ oken menu (sem se sk ‡e z menu)

AWMMnuSA PROC      FAR

         add       sp,4                     ; zru¨en¡ n vratov‚ adresy
         call      far ptr NulBreak         ; nulov n¡ p©¡znaku p©eru¨en¡ BREAK
         call      far ptr ClosMnuA         ; uzav©en¡ v¨ech oken menu

; ------ zad n¡ jm‚na adres ©e k vytvo©en¡ (sem se sk ‡e z kl vesy F7)

CAdresar label     FAR

         call      far ptr HistADir         ; ulo‘en¡ adres ©e do historie

; ------ p©ednastaven¡ p©edvolby - aktivn¡ adres ©

         mov       ax,ds:[AktPathN]
         mov       ds:[SAMnLPrN],ax         ; d‚lka aktivn¡ho adres ©e
         mov       word ptr ds:[SAMnLPrA],offset AktPath ; aktivn¡ adres ©
         mov       word ptr ds:[SAMnLPrA+2],ds

; ------ test, zda je pod kurzorem platn  polo‘ka

         call      far ptr TestAAWn         ; test zapnut¡ aktivn¡ho okna
         jc        AWMMSA04                 ; aktivn¡ okno nen¡ zapnuto
         call      far ptr GetAKurz         ; poskytnut¡ polo‘ky pod kurzorem
         jc        AWMMSA04                 ; nen¡ kurzor
         cmp       byte ptr es:[si+FileName],"." ; je platn  polo‘ka ?
         je        AWMMSA04                 ; nen¡ platn  polo‘ka
         test      byte ptr es:[si+FileAtr],ATRT ; je to platn  polo‘ka ?
         jz        AWMMSA04                 ; nen¡ platn  polo‘ka

; ------ test, zda je dlouh‚ jm‚no a zobrazen¡ s dlouh˜m jm‚nem

         push      es
         call      far ptr GetAAWin         ; adresa aktivn¡ho okna
         mov       ax,word ptr es:[AWinPrm1] ; parametry 1 a 2
         and       ax,bit3+(bit5+bit6)*HI
         pop       es
         cmp       ax,bit3+3*bit5*HI        ; adres © s dlouh˜mi jm‚ny ?
         jne       AWMMSA01                 ; ne
         mov       al,es:[si+FileLong]      ; d‚lka jm‚na
         or        al,al                    ; je dlouh‚ jm‚no ?
         je        AWMMSA01                 ; nen¡ dlouh‚ jm‚no

; ------ p©edvolba bude dlouh‚ jm‚no

         add       si,FileLong+1            ; za‡ tek jm‚na
         mov       word ptr ds:[SAMnLPrA],si ; adresa jm‚na
         mov       word ptr ds:[SAMnLPrA+2],es ; segment jm‚na
         mov       ah,0
         mov       ds:[SAMnLPrN],ax         ; d‚lka jm‚na
         jmp       short AWMMSA04           ; zad n¡ jm‚na adres ©e

; ------ p©edvolba bude jm‚no polo‘ky pod kurzorem

AWMMSA01:mov       word ptr ds:[SAMnLPrA],offset FileTxtP+1 ; adresa bufferu
         push      ds
         push      es
         push      ds
         pop       es                       ; ES <- segment bufferu
         pop       ds                       ; DS <- segment polo‘ky
         inc       si                       ; za‡ tek jm‚na polo‘ky
         mov       di,offset FileTxtP+1     ; buffer k dek¢dov n¡
         call      far ptr FileAsc          ; dek¢dov n¡ jm‚na souboru
         sub       di,offset FileTxtP+1     ; d‚lka jm‚na polo‘ky
         mov       es:[SAMnLPrN],di         ; d‚lka textu polo‘ky
         test      byte ptr ds:[si-1+FileAtr],DIR ; je to adres © ?
         pop       ds
         jnz       AWMMSA04                 ; je to adres ©

; ------ pro soubor je p©edvolba pouze jm‚no (bez p©¡pony)

         mov       word ptr ds:[SAMnLPrN],-1
         mov       si,offset FileTxtP+1-1
AWMMSA02:inc       word ptr ds:[SAMnLPrN]
         inc       si
         cmp       byte ptr ds:[si],0
         je        AWMMSA04
         cmp       byte ptr ds:[si],"."
         jne       AWMMSA02

; ------ zad n¡ adres ©e k vytvo©en¡

AWMMSA04:mov       si,offset SAMnuLin       ; menu vytvo©en¡ adres ©e
         call      SAMnLExP                 ; p©¡prava p©ep¡na‡–
         call      far ptr RozbCil          ; zad n¡ a rozbor adres ©e
         jnc       AWMMnSA1                 ; volba provedena OK

; ------ n vrat z obsluhy do hlavn¡ho cyklu

AWSMnuMM:jmp       far ptr Main0

; ------ zobrazen¡ hl ¨en¡ o vytv ©en¡ adres ©e

AWMMnSA1:mov       si,offset SAMnLinA       ; text hl ¨en¡
         call      far ptr InfDisp0         ; zobrazen¡ hl ¨en¡

; ------ test, zda je to okno stromu

         call      far ptr GetAAWin         ; adresa aktivn¡ho okna
         jc        AWMSA106
         test      byte ptr es:[AWinPrm1],bit4 ; je to strom ?
         jz        AWMSA106                 ; nen¡ to strom
         mov       bx,es:[AWinFrst]         ; £schova prvn¡ polo‘ky v oknˆ

; ------ nastaven¡ cesty podle pozice kurzoru v oknˆ stromu

         push      ds
         pop       es
         mov       si,offset AktPath
         call      far ptr SetDDir          ; nastaven¡ adres ©e a disku

; ------ nastaven¡ ukazatele v oknˆ

         mov       ax,ds:[SegmAkt]          ; segment aktivn¡ho okna
         call      far ptr InitTWn          ; inicializace ukazatele stromu
         call      far ptr GetDat
         mov       es:[AWinFrst],bx         ; n vrat prvn¡ polo‘ky v oknˆ

; ------ znovuna‡ten¡ adres ©e v protˆj¨¡m oknˆ

         mov       ax,ds:[SegmRAdr]
         test      byte ptr ds:[WindPar],bit0 ; je aktivn¡ lev‚ okno ?
         jnz       AWMSA102                  ; je aktivn¡ lev‚ okno
         mov       ax,ds:[SegmLAdr]
AWMSA102:call      far ptr GetDat
         mov       di,AWinDir               ; buffer cesty
         call      far ptr GetADir          ; poskytnut¡ aktivn¡ cesty
         mov       es:[AWinDNum],cx         ; po‡et bajt–
         or        byte ptr es:[AWinPrm0],bit0 ; neuchov vat kurzor
         call      far ptr ReReadD          ; nov‚ na‡ten¡ okna

; ------ vytvo©en¡ adres ©e s dlouh˜m jm‚nem

AWMSA106:test      byte ptr ds:[SAMnLSw1],bit0 ; m  b˜t dlouh‚ jm‚no ?
         jz        AWMMSA14                 ; nen¡ dlouh‚ jm‚no
         test      byte ptr ds:[Win95Par],bit2 ; povolena dlouh  jm‚na ?
         jnz       AWMMSA14                 ; z kaz dlouh˜ch jmen

         call      far ptr TestBEsc
AWMMSA11:jc        AWSMnuMM                 ; p©eru¨en¡ operace

         call      AWMMIns8                 ; instalace obsluhy data a ‡asu
         mov       bl,ds:[LinNum]           ; po‡et bajt– v bufferu
         mov       bh,0
         mov       ds:[LinBuff+bx],bh       ; ozna‡en¡ konce textu
         mov       si,offset LinBuff        ; zadan˜ adres ©
         push      ds
         pop       es
         call      far ptr CreaXDir         ; vytvo©en¡ adres ©e
;         mov       dx,offset LinBuff        ; zadan˜ adres ©
;         xor       si,si
;         mov       ax,7139h
;         stc                                ; p©ednastaven¡ p©¡znaku chyby
;         int       21h                      ; vytvo©en¡ dlouh‚ho adres ©e
         call      far ptr DInsA08          ; odinstalov n¡ modifikace ‡asu
         jc        AWMMSA14                 ; chyba operace

         test      byte ptr ds:[ModiWPar],bit2 ; po‘aduj¡ se atributy ?
         jz        AWMMSA12                 ; atributy se nepo‘aduj¡
         push      ds
         pop       es
         mov       si,offset LinBuff
         mov       cl,ds:[ModiAtr]          ; po‘adovan‚ atributy
         call      far ptr SetAFile         ; nastaven¡ atribut– adres ©e

AWMMSA12:call      far ptr NormFilL         ; normalizace jm‚na souboru

         mov       di,offset FilePath       ; buffer jm‚na
         cld
         push      cx
         rep       movsb                    ; p©enesen¡ zadan‚ho jm‚na adres ©e
         pop       cx

         mov       si,offset FilePath       ; buffer zadan‚ho adres ©e
         call      far ptr FullFile         ; korekce na pln‚ jm‚no souboru
         mov       ds:[FileFilN],cx         ; nov  d‚lka jm‚na adres ©e

         call      far ptr ModiWDir         ; modifikace obsahu adres ©e
         jmp       AWMMnSA9                 ; adres © vytvo©en OK

AWSMnuMM2:jmp      AWSMnuMM

; ------ normalizace jm‚na zadan‚ho adres ©e (v LINBUFF) -> ES:SI/CX buffer

AWMMSA14:call      far ptr NormFilL         ; normalizace jm‚na souboru
         jcxz      AWSMnuMM2                ; nebylo nic zad no - konec

; ------ p©enesen¡ jm‚na souboru do bufferu FILEPATH (zde je ES=DS !)

         mov       di,offset FilePath       ; buffer jm‚na
         cld
         push      cx
         rep       movsb                    ; p©enesen¡ zadan‚ho jm‚na adres ©e
         pop       cx

; ------ korekce na pln‚ jm‚no

         call      far ptr NulBreak         ; nulov n¡ p©¡padn‚ho p©eru¨en¡
         mov       si,offset FilePath       ; buffer zadan‚ho adres ©e
         call      far ptr FullFile         ; korekce na pln‚ jm‚no souboru
         mov       ds:[FileFilN],cx         ; nov  d‚lka jm‚na adres ©e
         call      far ptr TestBEsc         ; test p©eru¨en¡ operace
         jc        AWMMSA11                 ; p©eru¨en¡ operace

; ------ zobrazen¡ hl ¨en¡ o vytv ©en¡ adres ©e

         mov       di,offset SAMnLinA       ; text hl ¨en¡
         call      far ptr InfFile          ; zobrazen¡ hl ¨en¡

; ------ prvn¡ pokus o vytvo©en¡ adres ©e (kr tk˜ adres ©)

         call      AWMMIns8                 ; instalace obsluhy data a ‡asu
         push      ds
         pop       es                       ; ES <- DS
         mov       si,offset FilePath       ; zadan˜ adres ©
         call      far ptr CreatDir         ; vytvo©en¡ adres ©e
         call      far ptr DInsA08          ; odinstalov n¡ modifikace ‡asu
         jc        AWMMSA23                 ; chyba operace

; ------ operace OK - nastaven¡ atribut– adres ©e

         test      byte ptr ds:[ModiWPar],bit2 ; po‘aduj¡ se atributy ?
         jz        AWMMSA19                 ; atributy se nepo‘aduj¡
         mov       cl,ds:[ModiAtr]          ; po‘adovan‚ atributy
         call      far ptr SetAFile         ; nastaven¡ atribut– adres ©e
AWMMSA19:call      far ptr ModiWDir         ; modifikace obsahu adres ©e
         jmp       AWMMnSA9                 ; adres © vytvo©en OK

; ------ test, zda byl zad n spr vn˜ disk (DS,ES:SI = zadan˜ adres ©)

AWMMSA23:mov       al,ds:[si]               ; ozna‡en¡ disku
         mov       byte ptr ds:[ChbLD1P1],al ; ozna‡en¡ disku
         mov       byte ptr ds:[ChbLD6P2+12],al ; ozna‡en¡ disku
         mov       byte ptr ds:[ChbLD7P2+12],al ; ozna‡en¡ disku
         sub       al,"A"                   ; ‡¡slo disku
         call      far ptr TestBreak        ; bylo p©eru¨en¡ operace ?
         jc        AWMMnSA8                 ; p©eru¨en¡ operace
         call      far ptr TestDisk         ; test spr vnosti zad n¡ disku
         mov       si,offset ChbLnD1        ; hl ¨en¡ o chybn‚m zad n¡ disku
         jc        AWMMnSA8                 ; chybn‚ zad n¡ ozna‡en¡ disku

; ------ test, zda adres © ji‘ existuje

         mov       si,offset FilePath       ; zadan˜ adres ©
         call      far ptr ExisFile         ; test, zda adres © ji‘ existuje
         jc        AWMMnSA4                 ; adres © neexistuje nebo chyba

; ------ chyba - existuje ji‘ soubor nebo adres © zadan‚ho jm‚na

         mov       si,offset ChbLnD3        ; chyba - existuje ji‘ adres ©
         test      cl,DIR                   ; byl nalezen adres © ?
         jnz       AWMMnSA8                 ; nalezen adres ©
AWMMnSA3:mov       si,offset ChbLnD4        ; chyba - existuje ji‘ soubor
         jmp       short AWMMnSA8

; ------ jinak pokus o vytvo©en¡ dlouh‚ho adres ©e ES:SI

AWMMnSA4:call      AWMMIns8                 ; instalace obsluhy data a ‡asu
         mov       cl,ds:[ModiAtr]          ; po‘adovan‚ atributy
         call      far ptr CreaLDir         ; vytvo©en¡ dlouh‚ho adres ©e
         call      far ptr DInsA08          ; odinstalov n¡ modifikace ‡asu
         jnc       AWMMnSA9                 ; adres © vytvo©en OK

; ------ chyba - existuje ji‘ soubor stejn‚ho jm‚na (nˆkde v cestˆ)

         cmp       word ptr ds:[LastErr],Err_Exst_File ; nalezen soubor ?
         je        AWMMnSA3                 ; je ji‘ soubor tohoto jm‚na

; ------ chyba - p©¡li¨ dlouh  cesta

         mov       si,offset ChbLnD2        ; chyba - dlouh‚ jm‚no
         cmp       byte ptr ds:[FileFilN],67 ; p©ekro‡ena d‚lka cesty ?
         jae       AWMMnSA8                 ; p©¡li¨ dlouh‚ jm‚no adres ©e

; ------ chyba - disk je pln˜

         mov       al,ds:[FilePath]         ; zadan˜ disk
         sub       al,"A"
         call      far ptr GetDInfo         ; poskytnut¡ informac¡ o disku
         jc        AWMMnSA7                 ; chyba disku
         or        bx,bx                    ; je voln‚ m¡sto ?
         mov       si,offset ChbLnD6        ; chyba - disk pln˜
         jz        AWMMnSA8                 ; chyba - disk pln˜

; ------ chyba - nedostatek polo‘ek ROOT

AWMMnSA5:mov       di,offset FilePath+3-1   ; zadan˜ adres ©
AWMMnSA6:inc       di
         cmp       byte ptr ds:[di],0
         je        AWMMSA62
         cmp       byte ptr ds:[di],"\"
         jne       AWMMnSA6
AWMMSA62:mov       al,ds:[di]               ; £schova znaku
         mov       byte ptr ds:[di],0       ; konec cesty
         mov       si,offset FilePath       ; zadan˜ adres ©
         call      far ptr ExisFile         ; test, zda existuje adres © ROOT
         mov       ds:[di],al               ; n vrat p–vodn¡ho znaku
         mov       si,offset ChbLnD7        ; chyba - m lo polo‘ek ROOT
         jc        AWMMnSA8                 ; nelze vytvo©it ROOT - asi m lo ROOT

; ------ jin  chyba

AWMMnSA7:mov       si,offset ChbLnD5        ; chyba - adres © nelze vytvo©it

; ------ chybov‚ hl ¨en¡ DS:SI

AWMMnSA8:call      far ptr TestBreak        ; test p©eru¨en¡ operace
         jc        AWMMSA94                 ; je p©eru¨en¡ operace
         call      far ptr Lin0MenF         ; obsluha chybov‚ho hl ¨en¡
         jc        AWMMSA94                 ; p©eru¨en¡ operace
         jmp       near ptr CAdresar        ; opakov n¡ zad n¡

; ====== obnoven¡ obsahu adres ©e p©i operaci OK

; ------ aktualizace diskov˜ch informac¡

AWMMnSA9:call      far ptr TestAAWn         ; test zapnut¡ okna
         jc        AWMMSA94                 ; okno nen¡ zapnut‚
         call      AWMMAkt                  ; aktualizace aktivn¡ho okna
AWMMSA94:jmp       AWSMnuMM

AWMMnuSA ENDP

; ------ instalace obsluhy nastaven¡ data a ‡asu

AWMMIns8:test      byte ptr ds:[ModiWPar],bit4 + bit6 ; zad no datum a ‡as ?
         jz        AWMMIns2                 ; nezad no datum ani ‡as
         call      far ptr GetSTime         ; aktu ln¡ ‡as
         and       dx,ds:[ModiTimM]         ; maskov n¡ ‡asu
         or        dx,ds:[ModiTim]          ; nastaven¡ po‘adovan‚ho ‡asu
         xchg      dx,cx                    ; CX <- ‡as
         call      far ptr GetSDate         ; aktu ln¡ datum
         and       dx,ds:[ModiDatM]         ; maskov n¡ data
         or        dx,ds:[ModiDat]          ; nastaven¡ po‘adovan‚ho data
         call      far ptr InstA08          ; instalace obsluhy ‡asu
AWMMIns2:ret

; -----------------------------------------------------------------------------
;        p©ep¡na‡ Dlouh  jm‚na
; -----------------------------------------------------------------------------

SAMnLExD PROC      FAR

         xor       byte ptr ds:[SAMnLSw1],bit0 ; zmˆna p©ep¡na‡e
         call      SAMnLExP                 ; p©¡prava p©ep¡na‡–
         call      far ptr DispMnu          ; nov‚ zobrazen¡ menu
         ret

SAMnLExD ENDP

; -----------------------------------------------------------------------------
;        p©¡prava p©ep¡na‡– pro menu vytvo©en¡ adres ©e
; -----------------------------------------------------------------------------

SAMnLExP PROC      NEAR

         push      dx

         mov       dl,ds:[SAMnLSw1]         ; p©ep¡na‡e
         and       byte ptr ds:[SAMnLBlk+2],not bit1 ; povoleno
         test      byte ptr ds:[Win95Par],bit2 ; povoleno ?
         jz        SAMnLEP1                 ; povoleno
         or        byte ptr ds:[SAMnLBlk+2],bit1 ; z kaz
         and       dl,not bit0              ; z kaz

SAMnLEP1:call      far ptr SetSwch          ; nastaven¡ p©ep¡na‡–

;         mov       byte ptr ds:[SAMnuLin+LMnuMask],bit2 ; v¨echny znaky
         test      dl,bit0                  ; volba nastavena ?
         mov       dl,ds:[ZnakSwch]         ; zapnut
         jnz       SAMnLEP2                 ; p©ep¡na‡ zapnut
         mov       dl,ds:[ZnakSwch+1]       ; vypnuto
;         mov       byte ptr ds:[SAMnuLin+LMnuMask],bit3+bit6 ; jen znaky DOS
SAMnLEP2:mov       ds:[SAMnLPl1],dl         ; znak p©ep¡na‡e

         pop       dx
         ret

SAMnLExP ENDP

; -----------------------------------------------------------------------------
;        aktualizace aktivn¡ho okna po vytvo©en¡ adres ©e (nastaven¡ kurzoru)
; -----------------------------------------------------------------------------

AWMMAkt  PROC      NEAR

; ------ adresa okna

         mov       ax,ds:[SegmAkt]          ; segment okna
         call      far ptr GetDat           ; adresa okna

; ------ test, zda je to adres ©ov‚ okno

         test      byte ptr es:[AWinPrm1],bit3 ; je to adres ©ov‚ okno ?
         jz        AWMMAkt3                 ; nen¡ to adres ©ov‚ okno

; ------ zaji¨tˆn¡ na‡ten¡ okna AX

         test      byte ptr es:[AWinPrm1],bit1 ; byla zmˆna v oknˆ ?
         jnz       AWMMAkt9                 ; v oknˆ nebyla zmˆna
         call      far ptr ReReadD          ; na‡ten¡ okna
         call      far ptr GetDat           ; nov  adresa okna -> ES

; ------ p©¡prava jm‚na polo‘ky ve tvaru FCB

         mov       si,offset FilePath       ; vytv ©en¡ adres ©
         mov       di,AWinDir               ; adres © okna
         mov       cx,es:[AWinDNum]         ; d‚lka adres ©e okna
         cld
         repe      cmpsb                    ; porovn n¡ adres ©–
         jne       AWMMAkt9                 ; adres ©e nesouhlas¡
         cmp       byte ptr es:[AWinDNum],3 ; je to ROOT adres © ?
         jbe       AWMMAkt1                 ; je to ROOT adres ©
         cmp       byte ptr ds:[si],"\"     ; navazuje podadres © ?
         jne       AWMMAkt9                 ; adres © se neshoduje
         inc       si                       ; p©esko‡en¡ znaku "\"
AWMMAkt1:sub       si,DTAName               ; fiktivn¡ polo‘ka DTA
         push      ds
         pop       es                       ; ES <- datov˜ segment
         call      far ptr GetBFCB          ; konverze na tvar FCB

; ------ nalezen¡ polo‘ky v oknˆ AX (ES=DS)

         mov       si,offset FileFPol       ; hledan  polo‘ka
         call      far ptr SrcWNam          ; nalezen¡ polo‘ky v oknˆ AX
         jc        AWMMAkt9                 ; polo‘ka nenalezena

; ------ nastaven¡ kurzoru na polo‘ku

         call      far ptr GetDat           ; adresa okna
         mov       es:[AWinKurz],bx         ; nov˜ kurzor
         jmp       short AWMMAkt9

; ------ test, zda je to strom

AWMMAkt3:test      byte ptr es:[AWinPrm1],bit4 ; je to strom ?
         jz        AWMMAkt9                 ; nen¡ to strom

; ------ test, zda souhlas¡ disk stromu

         mov       cl,es:[AWinDir]          ; disk okna
         cmp       cl,ds:[FilePath]         ; souhlas¡ disk ?
         jne       AWMMAkt9                 ; disk nesouhlas¡

; ------ nalezen¡ cesty v oknˆ

         push      ds
         pop       es                       ; ES <- datov˜ segment
         mov       si,offset FilePath       ; vytv ©en˜ adres ©
         call      far ptr SrcPathT         ; nalezen¡ konce cesty
         jc        AWMMAkt9

; ------ nastaven¡ kurzoru v oknˆ

         call      far ptr GetDat           ; adresa okna
         mov       es:[AWinKurz],bx         ; nastaven¡ kurzoru na polo‘ku
         call      far ptr AktPAthT         ; aktualizace stromu v oknˆ
AWMMAkt9:ret

AWMMAkt  ENDP

; *****************************************************************************
;
;                      ozna‡en¡ polo‘ek (volba "V˜bˆr")
;
; *****************************************************************************
;þ
AWMMnuSB PROC      FAR

         call      AWMMSBXP                 ; p©¡prava p©ep¡na‡– (menu DS:SI)

         mov       ax,word ptr ds:[SMnuVert+MnuPoz] ; pozice p©edchoz¡ho okna
         add       ax,107h                  ; posun okna
         mov       word ptr ds:[si+MnuPoz],ax ; pozice okna

         jmp       far ptr VertMenu         ; obsluha vertik ln¡ho menu

AWMMnuSB ENDP

; -----------------------------------------------------------------------------
;        p©¡prava p©ep¡na‡– (menu voleb DS:SI)
; -----------------------------------------------------------------------------

AWMMSBXP PROC      NEAR

         push      ax
         push      dx
         push      di

; ------ povolen¡ v¨ech polo‘ek voleb

         mov       ax,NOT (bit1*HI + bit1)
         mov       di,offset SBMnVBlk+3     ; blokovac¡ tabulka menu
         and       ds:[di+3-3],ax           ; kurzor; soubory
         and       ds:[di+5-3],ax           ; v¨echny; COM
         and       ds:[di+7-3],ax           ; zadan‚; uschovan‚
         and       ds:[di+9-3],al           ; porovn n¡m

; ------ blokov n¡ polo‘ek, nen¡-li povoleno aktivn¡ okno

         not       ax                       ; AX <- (bit1*HI + bit1)
         call      far ptr TestAAWn         ; test aktivn¡ho okna
         jnc       AWMSBXP2                 ; okno je zapnuto OK
         or        ds:[di+3-3],ax           ; kurzor; soubory
         or        ds:[di+5-3],ax           ; v¨echny; COM
         or        ds:[di+7-3],ax           ; zadan‚; uschovan‚
         or        ds:[di+9-3],al           ; porovn n¡m

; ------ blokov n¡ polo‘ky "porovn n¡m", nen¡-li druh‚ okno

AWMSBXP2:call      far ptr TestNAWn         ; test neaktivn¡ho okna
         jnc       AWMSBXP3                 ; okno je zapnuto OK
         or        ds:[di+9-3],al           ; porovn n¡m

; ------ nastaven¡ p©ep¡na‡–

AWMSBXP3:mov       dl,ds:[SelParam]         ; parametry pro v˜bˆr polo‘ek
         mov       dh,0
         call      far ptr SetSwch          ; nastaven¡ p©ep¡na‡–

; ------ n vrat registr–

         pop       di
         pop       dx
         pop       ax
         ret

AWMMSBXP ENDP

; -----------------------------------------------------------------------------
;        volby p©ep¡na‡– okna menu v˜bˆru polo‘ek
; -----------------------------------------------------------------------------

; ------ volba "Ozna‡it"

AWMMSB11:and       dl,not bit1 + bit2
         or        dl,bit0
         jmp       short AWMSB132

; ------ volba "Nulovat"

AWMMSB12:and       dl,not bit0 + bit2
         or        dl,bit1
         jmp       short AWMSB132

; ------ volba "Inverze"

AWMMSB13 PROC      FAR

         and       dl,not bit0 + bit1
         or        dl,bit2
AWMSB132:and       byte ptr ds:[SelParam],not bit0+bit1+bit2
         or        ds:[SelParam],dl         ; £schova stavu p©ep¡na‡–
         call      AWMMSBXP                 ; p©¡prava p©ep¡na‡–
         call      far ptr DispMnu          ; nov‚ zobrazen¡ okna menu
         ret                                ; n vrat do menu

AWMMSB13 ENDP

; -----------------------------------------------------------------------------
;        volba "kurzor"
; -----------------------------------------------------------------------------

AWMMSB14:add       sp,4                     ; zru¨en¡ n vratov‚ adresy
         call      far ptr GetAAWin         ; poskytnut¡ adresy aktivn¡ho okna
         mov       bp,es                    ; £schova adresy okna
         mov       bx,es:[AWinKurz]         ; soubor s kurzorem
         call      far ptr GetESPol         ; kurzor okna
         jc        AWMSB146                 ; nen¡ platn  polo‘ka
         test      byte ptr es:[si+FileAtr],ATRT ; je to cesta ?
         jz        AWMSB147                 ; je to cesta
         cmp       byte ptr es:[si+FileName],"." ; je to adres © ".." ?
         je        AWMSB161                 ; ozna‡en¡ v¨ech polo‘ek
         call      SelPolX                  ; ozna‡en¡ polo‘ky
AWMSB146:jmp       AWSMnuMM                 ; n vrat do hlavn¡ obsluhy

; ------ kurzor je na cestˆ - ozna‡en¡ v¨ech polo‘ek adres ©e

AWMSB147:inc       bx                       ; zv˜¨en¡ ukazatele polo‘ek
         mov       es,bp                    ; adresa okna
         call      far ptr GetESPol         ; adresa dal¨¡ polo‘ky
         jc        AWMSB146                 ; nen¡ dal¨¡ polo‘ka
         test      byte ptr es:[si+FileAtr],ATRT ; je to platn  polo‘ka ?
         jz        AWMSB146                 ; nen¡ dal¨¡ platn  polo‘ka
         call      SelPolX                  ; ozna‡en¡ polo‘ky
         jmp       short AWMSB147           ; dal¨¡ polo‘ka

; -----------------------------------------------------------------------------
;        volba "soubory"
; -----------------------------------------------------------------------------

AWMMSB15:add       sp,4                     ; zru¨en¡ n vratov‚ adresy
         call      far ptr GetAAWin         ; poskytnut¡ adresy aktivn¡ho okna
         test      byte ptr es:[AWinPrm1],bit4 ; je to strom ?
         jnz       AWMSB162                 ; je to strom - ozna‡¡ se i adres ©e
         mov       bp,es                    ; BP <- adresa okna
         xor       bx,bx                    ; BX <- ukazatel ‡¡sla polo‘ky
AWMSB152:mov       es,bp                    ; ES <- adresa okna
         call      far ptr GetESPol         ; adresa polo‘ky
         jc        AWMSB146                 ; nen¡ dal¨¡ polo‘ka
         test      byte ptr es:[si+FileAtr],DIR ; je to soubor ?
         jnz       AWMSB153                 ; nen¡ to soubor - je to adres ©
         call      SelPolX                  ; ozna‡en¡ polo‘ky
AWMSB153:inc       bx                       ; zv˜¨en¡ ukazatele polo‘ek
         jmp       short AWMSB152           ; dal¨¡ polo‘ka

; -----------------------------------------------------------------------------
;        volba "v¨echny"
; -----------------------------------------------------------------------------

AWMMSB16:add       sp,4                     ; zru¨en¡ n vratov‚ adresy
AWMSB161:call      far ptr GetAAWin         ; poskytnut¡ adresy aktivn¡ho okna
AWMSB162:mov       bx,es:[AWinSouN]         ; po‡et zobrazen˜ch soubor–
AWMSB164:or        bx,bx                    ; jsou ji‘ v¨echny polo‘ky ?
         jz        AWMSB146                 ; nen¡ dal¨¡ polo‘ka
         dec       bx                       ; sn¡‘en¡ ukazatele polo‘ek
         call      SelPol0X                 ; ozna‡en¡ polo‘ky
         jmp       short AWMSB164           ; dal¨¡ polo‘ka

; -----------------------------------------------------------------------------
;        ozna‡en¡ program– COM/EXE/BAT (DL:bit0=ozna‡,bit1=odzna‡,bit2=invertuj)
; -----------------------------------------------------------------------------

AWMMSB17:add       sp,4                     ; zru¨en¡ n vratov‚ adresy
         call      far ptr GetAAWin         ; poskytnut¡ adresy aktivn¡ho okna
         mov       bp,es                    ; BP <- adresa okna
         xor       bx,bx                    ; ukazatel polo‘ek
AWMSB174:mov       es,bp                    ; ES <- segment okna
         call      far ptr GetESPol         ; adresa polo‘ky
         jc        AWMSB1C6                 ; nen¡ dal¨¡ platn  polo‘ka
         call      far ptr TestProg         ; test, zda je polo‘ka program
         jne       AWMSB176                 ; polo‘ka neodpov¡d 
         call      SelPolX                  ; ozna‡en¡ polo‘ky
AWMSB176:inc       bx                       ; zv˜¨en¡ ukazatele ‡¡sla polo‘ky
         jmp       short AWMSB174           ; test dal¨¡ polo‘ky

; -----------------------------------------------------------------------------
;        ozna‡en¡ polo‘ek s uschovan˜m ozna‡en¡m
; -----------------------------------------------------------------------------

AWMMSB19:add       sp,4                     ; zru¨en¡ n vratov‚ adresy
         call      far ptr GetAAWin         ; poskytnut¡ adresy aktivn¡ho okna
         mov       bp,es                    ; BP <- adresa okna
         xor       bx,bx                    ; ukazatel polo‘ek
AWMSB194:mov       es,bp                    ; ES <- segment okna
         call      far ptr GetESPol         ; adresa polo‘ky
         jc        AWMSB1C6                 ; nen¡ dal¨¡ platn  polo‘ka
         test      byte ptr es:[si+FileAtr],ATRU ; je uschovan‚ ozna‡en¡ ?
         jz        AWMSB196                 ; nen¡ uschovan‚ ozna‡en¡
         call      SelPolX                  ; ozna‡en¡ polo‘ky
AWMSB196:inc       bx                       ; zv˜¨en¡ ukazatele ‡¡sla polo‘ky
         jmp       short AWMSB194           ; test dal¨¡ polo‘ky

; -----------------------------------------------------------------------------
;        ozna‡en¡ soubor– porovn n¡m s protˆj¨¡m oknem
; -----------------------------------------------------------------------------

; ------ p©¡prava pozice k zobrazen¡ okna

AWMMSB1C:mov       ax,word ptr ds:[SBMnVert+MnuPoz] ; pozice p©edchoz¡ho okna
         add       ax,107h                  ; posun okna
         mov       word ptr ds:[si+MnuPoz],ax ; pozice okna
         mov       dl,ds:[SelParam]         ; parametry
         mov       cl,4                     ; po‡et rotac¡
         shr       dl,cl                    ; rotace na pozici
         call      far ptr SetSwch          ; nastaven¡ p©ep¡na‡–
         jmp       far ptr VertMenu         ; obsluha vertik ln¡ho menu

; ------ pokra‡ov n¡ po proveden¡ volby

AWMSB1C2:add       sp,4                     ; zru¨en¡ n vratov‚ adresy
         call      far ptr ClosMnuA         ; uzav©en¡ v¨ech oken menu
         mov       bx,ds:[si+MnuAkt]        ; aktivn¡ zvolen  polo‘ka
         mov       dh,cs:[bx+AWMSTab-1]     ; odpov¡daj¡c¡ p©ep¡na‡e
         mov       dl,ds:[SelParam]         ; parametry pro v˜bˆr
         or        dl,bit6                  ; uchovat ozna‡en¡

; ------ porovn n¡ obsah– oken

         mov       ax,ds:[SegmAkt]          ; aktivn¡ okno
         mov       bx,ds:[SegmNAkt]         ; neaktivn¡ okno
         call      far ptr CompWin          ; porovn n¡ obsahu okna s protˆj¨¡m
AWMSB1C6:jmp       AWSMnuMM                 ; n vrat z obsluhy

; ------ p©ep¡na‡ "Podadres ©e"

AWMSBC22 PROC      FAR

         xor       dl,bit0
AWMSBC23:call      far ptr SetSwch
         mov       cl,4
         shl       dl,cl
         and       byte ptr ds:[SelParam],not bit4+bit5+bit6
         or        ds:[SelParam],dl
         call      far ptr DispMnu
         ret

AWMSBC22 ENDP

; ------ p©ep¡na‡ "Ozna‡en‚"

AWMSBC24 PROC      FAR

         xor       dl,bit1
         jmp       short AWMSBC23

AWMSBC24 ENDP

; ------ p©ep¡na‡ "Uschovat"

AWMSBC26 PROC      FAR

         xor       dl,bit2
         jmp       short AWMSBC23

AWMSBC26 ENDP

; ------ parametry pro operaci

AWMSTab  db        0                        ; 1 = aktu ln¡ (dopl¤kov‚ a novˆj¨¡)
         db        2                        ; 2 = dopl¤kov‚
         db        4                        ; 3 = novˆj¨¡
         db        6                        ; 4 = shodn‚
         db        8                        ; 5 = star¨¡
         db        10                       ; 6 = rozd¡ln‚
         db        12                       ; 7 = existuj¡c¡
         db        bit6                     ; 8 = voln‚ m¡sto

; *****************************************************************************
;                                  CompWin
;                       porovn n¡ a ozna‡en¡ obsahu okna
; -----------------------------------------------------------------------------
; VSTUP: AX=‡¡slo okna k ozna‡en¡ polo‘ek
;        BX=‡¡slo protˆj¨¡ho okna k porovn n¡
;        DL=parametry pro ozna‡en¡ polo‘ek
;               bit 0: ozna‡en¡
;               bit 1: nulov n¡
;               bit 2: inverze
;               bit 4: 1=povoleny podadres ©e
;               bit 5: 1=pouze ozna‡en‚
;               bit 6: 1=uschovat ozna‡en¡
;        DH=parametry pro porovn n¡ polo‘ek
;               bit 1 a‘ bit 3: 0 = aktu ln¡
;                               2 = dopl¤kov‚
;                               4 = novˆj¨¡ (datum a ‡as)
;                               6 = shodn‚ (datum, ‡as i velikost)
;                               8 = star¨¡ (datum a ‡as)
;                               10 = rozd¡ln‚ (datum, ‡as nebo velikost)
;                               12 = existuj¡c¡
;               bit 6 = voln‚ m¡sto (soubory se vejdou do protˆj¨¡ho okna)
;        DS=datov˜ segment
; -----------------------------------------------------------------------------
; lok ln¡ promˆnn‚: SS:[BP-2] (2) datov˜ segment
;                   SS:[BP-3] (1) parametry pro porovn n¡ polo‘ek DH
;                                   bit 1-3: 0 = aktu ln¡
;                                            2 = dopl¤kov‚
;                                            4 = novˆj¨¡ (datum a ‡as)
;                                            6 = shodn‚ (datum, ‡as i velikost)
;                                            8 = star¨¡ (datum a ‡as)
;                                           10 = rozd¡ln‚ (datum, ‡as nebo velikost)
;                                           12 = existuj¡c¡
;                                   bit 6 = voln‚ m¡sto (soubory se vejdou do protˆj¨¡ho okna)
;                   SS:[BP-4] (1) parametry pro ozna‡en¡ polo‘ek DL
;                                    bit 0: ozna‡en¡
;                                    bit 1: nulov n¡
;                                    bit 2: inverze
;                                    bit 3: 1=referen‡n¡ okno je seznam
;                                    bit 4: 1=povoleny podadres ©e
;                                    bit 5: 1=pouze ozna‡en‚
;                                    bit 6: 1=uschovat ozna‡en¡
;                                    bit 7: 1=byla nalezena ref. polo‘ka
;                   SS:[BP-6] (2) ozna‡ovan‚ okno
;                   SS:[BP-8] (2) referen‡n¡ okno
;                   SS:[BP-10] (2) adresa ozna‡ovan‚ho okna
;                   SS:[BP-12] (2) adresa referen‡n¡ho okna
;                   SS:[BP-14] (2) ukazatel ‡¡sla testovan‚ polo‘ky
;                   SS:[BP-16] (2) po‡ te‡n¡ polo‘ka v referen‡n¡m oknˆ
;                   SS:[BP-18] (2) koncov  polo‘ka v referen‡n¡m oknˆ (neplatn )
;                   SS:[BP-20] (2) adresa obsluhy vyhled n¡ polo‘ky
;                   SS:[BP-22] (2) v˜choz¡ d‚lka cesty akt. okna s "\" (2=nen¡)
;                   SS:[BP-24] (2) v˜choz¡ d‚lka cesty ref. okna s "\" (2=nen¡)
; *****************************************************************************

CompWin  PROC      FAR

; ------ zobrazen¡ hl ¨en¡ o prov dˆn¡ operace

         push      si
         mov       si,offset SBPMPorS
         call      far ptr InfDisp0         ; zobrazen¡ hl ¨en¡
         pop       si

         test      dh,bit6                  ; ozna‡uje se voln‚ m¡sto ?
         jz        CompWin0                 ; neozna‡uje se voln‚ m¡sto
         jmp       near ptr CompMWn         ; test okna na voln‚ m¡sto

; ------ £schova registr–

CompWin0:push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es
         mov       bp,sp

; ------ p©¡prava lok ln¡ch promˆnn˜ch

         sub       sp,24
         mov       ss:[bp-2],ds             ; datov˜ segment
         mov       ss:[bp-4],dx             ; parametry pro porovn v n¡ oken
         mov       ss:[bp-6],ax             ; ozna‡ovan‚ okno
         mov       ss:[bp-8],bx             ; referen‡n¡ okno
         call      far ptr GetDat           ; adresa ozna‡ovan‚ho okna
         jc        CompWn03                 ; chyba
         cmp       word ptr es:[AWinSNum],0 ; jsou ozna‡en‚ polo‘ky ?
         jne       CompWn02                 ; jsou ozna‡en‚ polo‘ky
         and       byte ptr ss:[bp-4],not bit5 ; nen¡ pro ozna‡en‚ polo‘ky
CompWn02:mov       ss:[bp-10],es            ; adresa ozna‡ovan‚ho okna
         mov       ax,es:[AWinSouN]         ; po‡et polo‘ek v oknˆ
         mov       word ptr ds:[InfoKMax],ax ; maximum pro kurzor
         xchg      ax,bx                    ; AX <- ‡¡slo referen‡n¡ho okna
         call      far ptr GetDat           ; adresa referen‡n¡ho okna
         jnc       CompWn04                 ; OK
CompWn03:jmp       CompWin9                 ; chyba (nebo konec)
CompWn04:mov       ss:[bp-12],es            ; adresa referen‡n¡ho okna
         xor       ax,ax                    ; AX <- 0
         mov       word ptr ds:[InfoKMax+2],ax
         mov       word ptr ds:[InfoKCit],ax ; ‡¡ta‡ ukazatele kurzoru
         mov       word ptr ds:[InfoKCit+2],ax
         mov       ss:[bp-14],ax            ; ukazatel ‡¡sla testovan‚ polo‘ky
         mov       ss:[bp-16],ax            ; po‡ te‡n¡ polo‘ka v referen‡n¡m oknˆ
         mov       ax,es:[AWinSouN]         ; po‡et polo‘ek v referen‡n¡m oknˆ
         mov       ss:[bp-18],ax            ; koncov  polo‘ka v referen‡n¡m oknˆ
         xor       cx,cx                    ; CX <- 0
         and       byte ptr ss:[bp-4],not bit3 ; nen¡ seznam
         call      far ptr InfoKurz         ; zobrazen¡ informa‡n¡ho kurzoru
         test      byte ptr es:[AWinPrm1],bit5 ; je referen‡n¡ okno seznam ?
         jz        CompWn06                 ; nen¡ to seznam
         or        byte ptr ss:[bp-4],bit3  ; referen‡n¡ okno je seznam
CompWn06:mov       bl,ss:[bp-3]             ; parametry pro porovn n¡
         and       bx,bit1+bit2+bit3        ; pouze pot©ebn‚ bity
         mov       ax,cs:[bx+AWMSTabC]      ; adresa obsluhy
         mov       ss:[bp-20],ax            ; adresa obsluhy

; ------ v˜choz¡ d‚lka cesty aktu ln¡ho okna

         xor       bx,bx                    ; prvn¡ polo‘ka
         mov       word ptr ss:[bp-22],2    ; v˜choz¡ cesta akt. okna nen¡
         mov       es,ss:[bp-10]            ; adresa ozna‡ovan‚ho okna
         call      far ptr GetESPol         ; adresa polo‘ky -> ES:SI
         jc        CompWn08                 ; nen¡ polo‘ka
         test      byte ptr es:[si+FileAtr],ATRT ; je to cesta ?
         jnz       CompWn08                 ; nen¡ to cesta
         mov       al,es:[si]               ; d‚lka cesty
         cmp       al,3                     ; je to ROOT ?
         jbe       CompWn08                 ; to je chyba nebo ROOT
         mov       ss:[bp-22],al            ; d‚lka cesty

; ------ v˜choz¡ d‚lka cesty referen‡n¡ho okna

CompWn08:mov       word ptr ss:[bp-24],2    ; v˜choz¡ cesta ref. okna nen¡
         mov       es,ss:[bp-12]
         call      far ptr GetESPol         ; adresa polo‘ky -> ES:SI
         jc        CompWin1                 ; nen¡ polo‘ka
         test      byte ptr es:[si+FileAtr],ATRT ; je to cesta ?
         jnz       CompWin1                 ; nen¡ to cesta
         mov       al,es:[si]               ; d‚lka cesty
         cmp       al,3                     ; je to ROOT ?
         jbe       CompWin1                 ; to je chyba nebo ROOT
         mov       ss:[bp-24],al            ; d‚lka cesty

; ------ obsluha zobrazen¡ informa‡n¡ho kurzoru

CompWin1:mov       ds,ss:[bp-2]             ; datov˜ segment
         mov       bx,ss:[bp-14]            ; ‡¡slo polo‘ky
         call      far ptr TestTDis         ; test ‡asov‚ho zobrazen¡
         jc        CompWn12                 ; nen¡ je¨tˆ pot©eba zobrazen¡
         mov       cx,bx                    ; ukazatel ‡¡sla polo‘ky
         sub       cx,word ptr ds:[InfoKCit] ; po‡et nezobrazen˜ch polo‘ek
         call      far ptr InfoKurz         ; zobrazen¡ informa‡n¡ho kurzoru

; ------ adresa testovan‚ polo‘ky -> DS:SI

CompWn12:mov       es,ss:[bp-10]            ; adresa ozna‡ovan‚ho okna
         call      far ptr GetESPol         ; adresa polo‘ky -> ES:SI
         jnc       CompWn13                 ; je dal¨¡ polo‘ka OK
         jmp       CompWin9                 ; jsou ji‘ v¨echny soubory

CompWn13:push      es
         pop       ds                       ; DS <- segment polo‘ky
         and       byte ptr ss:[bp-4],not bit7 ; nebyla nalezena polo‘ka

; ------ test, zda to je cesta

         test      byte ptr ds:[si+FileAtr],ATRT ; je to cesta ?
         jnz       CompWn16                 ; nen¡ to cesta
         test      byte ptr ss:[bp-4],bit3  ; je referen‡n¡ okno seznam ?
         jnz       CompWin2                 ; refere‡n¡ okno je seznam
CompWn14:jmp       CompWin8                 ; referen‡n¡ okno nen¡ seznam

; ------ test, zda jsou ozna‡en‚ polo‘ky

CompWn16:test      byte ptr ss:[bp-4],bit5  ; pouze ozna‡en‚ polo‘ky ?
         jz        CompWn18                 ; nejsou pouze ozna‡en‚ polo‘ky
         test      byte ptr ds:[si+FileAtr],ATRO ; je to ozna‡en  polo‘ka ?
         jz        CompWn14                 ; nen¡ ozna‡en  polo‘ka

; ------ test, zda je povolen adres ©

CompWn18:test      byte ptr ds:[si+FileAtr],DIR ; je to adres © ?
         jz        CompWin3                 ; nen¡ to adres © - OK
         test      byte ptr ss:[bp-4],bit4  ; jsou povoleny podadres ©e ?
         jnz       CompWin3                 ; adres ©e povoleny OK
         jmp       short CompWn14           ; jinak nepovoleno

; ------ nalezen¡ odpov¡daj¡c¡ cesty v referen‡n¡m oknˆ

CompWin2:mov       word ptr ss:[bp-18],0    ; koncov  polo‘ka - neplatn 
         xor       bx,bx                    ; ukazatel polo‘ek
CompWn21:mov       es,ss:[bp-12]            ; adresa referen‡n¡ho okna
         call      far ptr GetPolDI         ; adresa polo‘ky -> ES:DI
         inc       bx                       ; zv˜¨en¡ ukazatele polo‘ek
         jc        CompWin3                 ; cesta nenalezena
         test      byte ptr es:[di+FileAtr],ATRT ; je to cesta ?
         jnz       CompWn21                 ; nen¡ to cesta

         mov       ch,0
         mov       cl,ds:[si]               ; d‚lka cesty aktivn¡ho okna
         mov       al,es:[di]               ; referen‡n¡ cesta
         sub       cx,ss:[bp-22]            ; bez v˜choz¡ cesty
         jc        CompWin3                 ; cesta neplatn 
         ja        CompW211                 ; nen¡ v˜choz¡ cesta

         cmp       al,3                     ; je to ROOT ?
         je        CompW222                 ; je to ROOT a v˜choz¡ cesta

CompW211:sub       al,ss:[bp-24]            ; bez v˜choz¡ cesty
         jc        CompWn21                 ; cesta neplatn 
         ja        CompW212                 ; nen¡ v˜choz¡ cesta

         cmp       byte ptr ds:[si],3       ; je to ROOT ?
         je        CompW222                 ; je to ROOT a v˜choz¡ cesta

CompW212:cmp       al,cl                    ; je d‚lka shodn  ?
         jne       CompWn21                 ; nen¡ stejn  d‚lka cesty
         jcxz      CompW222                 ; je to v˜choz¡ cesta

         push      si
         cld
         inc       si                       ; p©esko‡en¡ d‚lky
         add       si,ss:[bp-22]            ; za‡ tek podcesty aktivn¡ho okna
         inc       di                       ; p©esko‡en¡ d‚lky
         add       di,ss:[bp-24]            ; za‡ tek podcesty referen‡n¡ho okna
         repe      cmpsb                    ; porovn n¡ cest
         pop       si
         jne       CompWn21                 ; cesty nejsou shodn‚

; ------ nalezen¡ konce polo‘ek v adres ©i

CompW222:mov       ss:[bp-16],bx            ; po‡ te‡n¡ polo‘ka
CompWn22:mov       ss:[bp-18],bx            ; koncov  polo‘ka
         mov       es,ss:[bp-12]            ; adresa referen‡n¡ho okna
         call      far ptr GetPolDI         ; adresa polo‘ky -> ES:DI
         inc       bx                       ; zv˜¨en¡ ukazatele polo‘ek
         jc        CompWin3                 ; cesta nenalezena
         test      byte ptr es:[di+FileAtr],ATRT ; je to cesta ?
         jnz       CompWn22                 ; nen¡ to cesta

; ------ p©¡prava k vyhled n¡ stejn‚ polo‘ky v referen‡n¡m oknˆ

CompWin3:mov       bx,ss:[bp-16]            ; po‡ te‡n¡ polo‘ka

; ------ test, zda jsou ji‘ v¨echny polo‘ky

CompWin4:cmp       bx,ss:[bp-18]            ; jsou ji‘ v¨echny polo‘ky ?
         jae       CompWin7                 ; jsou ji‘ v¨echny polo‘ky

; ------ adresa dal¨¡ polo‘ky -> ES:DI

         mov       es,ss:[bp-12]            ; adresa referen‡n¡ho okna
         call      far ptr GetPolDI         ; adresa polo‘ky -> ES:DI
         inc       bx                       ; zv˜¨en¡ ukazatele ‡¡sla polo‘ky
         jc        CompWin7                 ; nen¡ dal¨¡ polo‘ka
         test      byte ptr es:[di+FileAtr],ATRT ; je to platn  polo‘ka ?
         jz        CompWin4                 ; nen¡ to platn  polo‘ka

; ------ porovn n¡ jm‚na polo‘ky

         push      si
         push      di
         inc       si                       ; za‡ tek jm‚na
         inc       di                       ; za‡ tek jm‚na
         mov       cx,11                    ; d‚lka jm‚na a p©¡pony
         cld
         repe      cmpsb                    ; porovn n¡ jm‚na polo‘ky
         pop       di
         pop       si
         jne       CompWin4                 ; nen¡ to hledan  polo‘ka - dal¨¡
         or        byte ptr ss:[bp-4],bit7  ; byla nalezena polo‘ka

; ------ test podm¡nky

         call      word ptr ss:[bp-20]      ; porovn n¡ polo‘ek
         jc        CompWin4                 ; podm¡nka neplat¡ - dal¨¡ polo‘ka

; ------ podm¡nka splnˆna - ozna‡en¡ polo‘ky

CompWin6:mov       dl,ss:[bp-4]             ; parametr k ozna‡en¡ polo‘ky
         mov       bx,ss:[bp-14]            ; ‡¡slo polo‘ky
         mov       es,ss:[bp-10]            ; ES <- adresa ozna‡ovan‚ho okna
         call      SelPol0X                 ; ozna‡en¡ polo‘ky
         jmp       short CompWin8           ; dal¨¡ polo‘ka

; ------ polo‘ka nenalezena - test, zda m  b˜t ozna‡ena dopl¤kov  polo‘ka

CompWin7:test      byte ptr ss:[bp-4],bit7  ; byla polo‘ka nalezena ?
         jnz       CompWn72                 ; polo‘ka byla nalezena
         mov       al,ss:[bp-3]
         and       al,bit1+bit2+bit3
         cmp       al,2                     ; jsou dopl¤kov‚ polo‘ky ?
         jbe       CompWin6                 ; je - ozna‡en¡ polo‘ky

; ------ podm¡nka nesplnˆna - odzna‡en¡ polo‘ky

CompWn72:test      byte ptr ss:[bp-4],bit6  ; maj¡ se polo‘ky nulovat ?
         jnz       CompWin8                 ; polo‘ky se nemaj¡ nulovat
         mov       bx,ss:[bp-14]            ; ‡¡slo polo‘ky
         mov       es,ss:[bp-10]            ; ES <- adresa ozna‡ovan‚ho okna
         call      far ptr ResSPol          ; nulov n¡ ozna‡en¡ polo‘ky BX

; ------ p©¡prava k testu dal¨¡ polo‘ky

CompWin8:inc       word ptr ss:[bp-14]      ; zv˜¨en¡ ukazatele polo‘ek
         jmp       CompWin1                 ; dal¨¡ polo‘ka

; ------ n vrat registr–

CompWin9:mov       sp,bp
         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
CompWinA:call      far ptr InfoClos         ; uzav©en¡ hl ¨en¡
         ret

CompWin  ENDP

; ------ adresy obsluh

AWMSTabC dw        CompWnA                  ; 1 = aktu ln¡ (dopl¤kov‚ a novˆj¨¡)
         dw        CompWnD                  ; 2 = dopl¤kov‚
         dw        CompWnN                  ; 3 = novˆj¨¡
         dw        CompWnS                  ; 4 = shodn‚
         dw        CompWnT                  ; 5 = star¨¡
         dw        CompWnR                  ; 6 = rozd¡ln‚
         dw        CompWnE                  ; 7 = existuj¡c¡
         dw        CompWnA

; ------ aktu ln¡ (DS:SI=testovan , ES:DI=referen‡n¡)

CompWnA: call      CompPolD                 ; porovn n¡ data a ‡asu
         ja        CompWnA2                 ; je novˆj¨¡ - OK
         jb        CompWnA1                 ; je star¨¡ - chyba
         call      CompPolS                 ; porovn n¡ velikosti
         jne       CompWnE                  ; rozd¡ln  velikost - ozna‡¡ se
CompWnA1:stc                                ; (z rove¤ pro dopl¤kov‚)
CompWnA2:ret

; ------ novˆj¨¡ (DS:SI=testovan , ES:DI=referen‡n¡)

CompWnN: call      CompPolD                 ; porovn n¡ data a ‡asu
         ja        CompWnN2                 ; je novˆj¨¡ - OK
CompWnD: stc                                ; (z rove¤ pro dopl¤kov‚)
CompWnN2:ret

; ------ shodn‚ (DS:SI=testovan , ES:DI=referen‡n¡)

CompWnS: call      CompPolD                 ; porovn n¡ data a ‡asu
         jne       CompWnD                  ; nen¡ shoda
         call      CompPolS                 ; porovn n¡ velikosti
         jne       CompWnD                  ; nen¡ shoda
CompWnE: clc                                ; (z rove¤ pro existuj¡c¡)
         ret

; ------ star¨¡ (DS:SI=testovan , ES:DI=referen‡n¡)

CompWnT: call      CompPolD                 ; porovn n¡ data a ‡asu
         jb        CompWnE                  ; je star¨¡ - to je OK
         stc                                ; jinak neplat¡
         ret

; ------ rozd¡ln‚ (DS:SI=testovan , ES:DI=referen‡n¡)

CompWnR: call      CompPolD                 ; porovn n¡ data a ‡asu
         jne       CompWnE                  ; jsou rozd¡ln‚ - OK
         call      CompPolS                 ; porovn n¡ velikosti
         jne       CompWnE                  ; jsou rozd¡ln‚ - OK
         stc                                ; jinak neplat¡
         ret

; -----------------------------------------------------------------------------
;                                 CompPolD
;                  porovn n¡ data a ‡asu polo‘ek (ve tvaru FCB)
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=prvn¡ polo‘ka
;        ES:DI=druh  polo‘ka
; VSTUP:ZY=polo‘ky jsou shodn‚
;        CY=polo‘ka DS:SI je star¨¡ ne‘ ES:DI
; ni‡¡ registr AX
; -----------------------------------------------------------------------------

CompPolD PROC      NEAR

         mov       ax,ds:[si+FileDate]      ; datum
         cmp       ax,es:[di+FileDate]      ; porovn n¡ data
         jne       CompPlD9                 ; nen¡ shoda
         mov       ax,ds:[si+FileTime]      ; ‡as
         cmp       ax,es:[di+FileTime]      ; porovn n¡ ‡asu
CompPlD9:ret

CompPolD ENDP

; -----------------------------------------------------------------------------
;                                 CompPolS
;                  porovn n¡ velikosti polo‘ek (ve tvaru FCB)
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=prvn¡ polo‘ka
;        ES:DI=druh  polo‘ka
; VSTUP:ZY=polo‘ky jsou shodn‚
;        CY=polo‘ka DS:SI je men¨¡ ne‘ ES:DI
; ni‡¡ registr AX
; -----------------------------------------------------------------------------

CompPolS PROC      NEAR

         mov       ax,word ptr ds:[si+FileSize+2] ; velikost HIGH
         cmp       ax,word ptr es:[di+FileSize+2] ; porovn n¡ velikosti HIGH
         jne       CompPlS9                 ; nen¡ shoda
         mov       ax,word ptr ds:[si+FileSize] ; velikost LOW
         cmp       ax,word ptr es:[di+FileSize] ; porovn n¡ velikosti LOW
CompPlS9:ret

CompPolS ENDP

; -----------------------------------------------------------------------------
;                                  CompMWn
;            porovn n¡ a ozna‡en¡ obsahu okna podle voln‚ho m¡sta
; -----------------------------------------------------------------------------
; VSTUP: AX=‡¡slo okna k ozna‡en¡ polo‘ek
;        BX=‡¡slo protˆj¨¡ho okna k porovn n¡
;        DL=parametry pro ozna‡en¡ polo‘ek
;               bit 0: ozna‡en¡
;               bit 1: nulov n¡
;               bit 2: inverze
;               bit 4: (1=povoleny podadres ©e)
;               bit 5: 1=pouze ozna‡en‚
;               bit 6  1=uchovat ozna‡en¡
;        DS=datov˜ segment
; -----------------------------------------------------------------------------
; lok ln¡ promˆnn‚: SS:[BP-2] (2) ‡¡slo aktu ln¡ho okna
;                   SS:[BP-4] (2) adresa aktu ln¡ho okna
;                   SS:[BP-6] (2)
;                   SS:[BP-7] (1) (parametry DH)
;                   SS:[BP-8] (1) parametry DL
;                                      bit 0: ozna‡en¡
;                                      bit 1: nulov n¡
;                                      bit 2: inverze
;                                      bit 5: 1=pouze ozna‡en‚
;                                      bit 6: 1=uchovat ozna‡en¡
;                   SS:[BP-10] (2) ‡¡slo datov‚ho bufferu
;                   SS:[BP-12] (2) adresa konce bufferu (=velikost bufferu)
;                   SS:[BP-14] (2) adresa bufferu
;                   SS:[BP-16] (2) po‡et polo‘ek nejlep¨¡ho ©etˆzce (0=nen¡)
;                   SS:[BP-18] (2) adresa konce platn˜ch polo‘ek v bufferu
;                   SS:[BP-20] (2) voln‚ m¡sto nejlep¨¡ho ©etˆzce (blok–)
;                   SS:[BP-22] (2) po‡et polo‘ek testovan‚ho ©etˆzce
;                   SS:[BP-24] (2) po‡et platn˜ch polo‘ek v bufferu
;                   SS:[BP-26] (2) voln‚ m¡sto testovan‚ho ©etˆzce (blok–)
;                   SS:[BP-28] (2) aktu ln¡ po‡et polo‘ek v aloka‡n¡m bloku adr.
;                   SS:[BP-30] (2) po‡et polo‘ek na aloka‡n¡ blok adres ©e (ROOT=-1)
;                   SS:[BP-32] (2) velikost aloka‡n¡ho bloku
;                   SS:[BP-34] (2) datov˜ segment
; -----------------------------------------------------------------------------

CompMWn  PROC      FAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es

; ------ p©¡prava lok ln¡ch promˆnn˜ch

         mov       bp,sp
         sub       sp,34
         mov       ss:[bp-34],ds            ; datov˜ segment
         mov       ss:[bp-2],ax             ; ‡¡slo aktu ln¡ho okna
         call      far ptr GetDat           ; poskytnut¡ adresy prvn¡ho okna
         jc        CompMW15                 ; neplatn‚ okno
         cmp       word ptr es:[AWinSNum],0 ; jsou ozna‡en‚ polo‘ky ?
         jne       CompMw11                 ; jsou ozna‡en‚ polo‘ky
         and       dl,not bit5              ; nen¡ pro ozna‡en‚ polo‘ky
CompMw11:mov       ss:[bp-4],es             ; adresa aktu ln¡ho okna
         mov       ss:[bp-8],dx             ; parametry

; ------ adresa neaktivn¡ho okna

         xchg      ax,bx                    ; AX <- protˆj¨¡ okno
         call      far ptr GetDat           ; adresa protˆj¨¡ho okna
         jc        CompMW15                 ; neplatn‚ okno

; ------ velikost aloka‡n¡ho bloku

         mov       ax,es:[AWinAlok]         ; velikost aloka‡n¡ho bloku
         mov       ss:[bp-32],ax            ; velikost aloka‡n¡ho bloku

; ------ voln  kapacita disku (v bloc¡ch)

         xchg      ax,bx                    ; BX <- velikost aloka‡n¡ho bloku
         mov       ax,word ptr es:[AWinDFre]         ; voln  kapacita disku
         mov       dx,word ptr es:[AWinDFre+2]
         div       bx                       ; po‡et voln˜ch blok–
         mov       ss:[bp-26],ax            ; po‡et voln˜ch blok–

; ------ po‡et polo‘ek na aloka‡n¡ blok adres ©e

         mov       cl,5                     ; po‡et rotac¡
         shr       bx,cl                    ; po‡et polo‘ek na blok
         jnz       CompMW12
         inc       bx                       ; 1 polo‘ka na blok
CompMW12:mov       ss:[bp-30],bx            ; po‡et polo‘ek na blok adres ©e

; ------ ukazatel po‡tu polo‘ek adres ©e

         mov       ax,es:[AWinSouR]         ; po‡et na‡ten˜ch soubor–
         xor       dx,dx
         inc       ax                       ; 1 polo‘ka na "."
         div       bx                       ; v˜po‡et po‡tu polo‘ek v bloku
         mov       ss:[bp-28],dx            ; po‡et polo‘ek v aktu ln¡m bloku

; ------ korekce ukazatele polo‘ek, nen¡-li ROOT

         cmp       byte ptr es:[AWinDNum],3 ; je ROOT ?
         ja        CompMW13                 ; nen¡ ROOT
         mov       word ptr ss:[bp-30],-1   ; po‡et polo‘ek na blok neplatn˜
         mov       word ptr ss:[bp-28],1    ; po‡et polo‘ek pro ROOT

; ------ vytvo©en¡ datov‚ho bufferu

CompMW13:mov       bx,100                   ; asi tak velikost bufferu
         call      far ptr CreatDat         ; vytvo©en¡ datov‚ho bufferu
         jnc       CompMW16                 ; operace OK
CompMW15:jmp       CompMWn9                 ; chyba
CompMW16:mov       ss:[bp-10],ax            ; ‡¡slo datov‚ho bufferu
         mov       ss:[bp-12],bx            ; velikost datov‚ho bufferu
         shr       bx,1                     ; polovina bufferu
         mov       ss:[bp-18],bx            ; konec platn˜ch polo‘ek
         call      far ptr GetDat           ; adresa bufferu
         mov       ss:[bp-14],es            ; adresa bufferu

; ------ p©¡prava ukazatel– k na‡ten¡ polo‘ek

         xor       bx,bx                    ; ukazatel ‡¡sla polo‘ky
         xor       di,di                    ; ukl dac¡ adresa
         push      es
         pop       ds                       ; DS <- adresa datov‚ho bufferu

; ------ adresa dal¨¡ polo‘ky -> ES:SI

         dec       bx                       ; p©ednastaven¡
CompMWn2:mov       dx,ss:[bp-8]             ; parametry
CompMW21:inc       bx                       ; zv˜¨en¡ ukazatele polo‘ek
         mov       es,ss:[bp-4]             ; adresa aktu ln¡ho okna
         call      far ptr GetESPol         ; adresa dal¨¡ polo‘ky -> ES:SI
         jc        CompMW28                 ; nen¡ dal¨¡ polo‘ka

; ------ kontrola, zda je to platn  polo‘ka

CompMW22:test      byte ptr es:[si+FileAtr],ATRT ; je to platn  polo‘ka ?
         jz        CompMW21                 ; nen¡ to platn  polo‘ka
         test      byte ptr es:[si+FileAtr],DIR ; je to adres © ?
         jnz       CompMW21                 ; adres © nen¡ povolen
         test      byte ptr ss:[bp-8],bit5  ; pouze ozna‡en‚ polo‘ky ?
         jz        CompMW26                 ; nejsou pouze ozna‡en‚ polo‘ky
         test      byte ptr es:[si+FileAtr],ATRO ; je to ozna‡en  polo‘ka ?
         jz        CompMW21                 ; nen¡ to ozna‡en  polo‘ka

; ------ v˜po‡et velikosti polo‘ky (po‡et blok–)

CompMW26:mov       ax,word ptr es:[si+FileSize]      ; velikost polo‘ky
         mov       dx,word ptr es:[si+FileSize+2]
         mov       cx,ss:[bp-32]            ; velikost aloka‡n¡ho bloku
         dec       cx                       ; data pro zaokrouhlen¡
         add       ax,cx                    ; zaokrouhlen¡ polo‘ky nahoru
         adc       dx,0
         inc       cx                       ; n vrat velikosti aloka‡n¡ho bloku
         jc        CompMW27                 ; je p©ete‡en¡ velikosti
         cmp       dx,cx                    ; je p©ete‡en¡ velikosti ?
         jae       CompMW27                 ; je p©ete‡en¡ velikosti
         div       cx                       ; v˜po‡et po‡tu blok–

; ------ kontrola velikosti souboru

CompMW27:cmp       ax,ss:[bp-26]            ; je velikost OK ?
         ja        CompMWn2                 ; soubor je p©¡li¨ velk˜

; ------ test, zda je m¡sto v bufferu

         cmp       di,ss:[bp-18]            ; je m¡sto v bufferu ?
         jae       CompMW28                 ; buffer je pln˜

; ------ ulo‘en¡ parametr– souboru

         mov       ds:[di],ax               ; velikost polo‘ky
         inc       di
         inc       di
         mov       ds:[di],bx               ; ‡¡slo polo‘ky
         inc       di
         inc       di
         jmp       short CompMWn2           ; dal¨¡ polo‘ka

; ------ jsou ji‘ v¨echny polo‘ky

CompMW28:push      ds
         pop       es                       ; ES <- adresa bufferu
         mov       ss:[bp-18],di            ; adresa konce polo‘ek
         mov       ax,di
         shr       ax,1
         shr       ax,1
         mov       ss:[bp-24],ax            ; po‡et platn˜ch polo‘ek v bufferu
         cmp       di,8                     ; minim lnˆ 2 polo‘ky
         jb        CompMWn3                 ; je m lo polo‘ek

; ------ set©¡dˆn¡ polo‘ek

         cld
         xor       si,si                    ; ukazatel polo‘ek
CompMW29:lodsw                              ; velikost polo‘ky
         inc       si
         inc       si                       ; p©esko‡en¡ ‡¡sla polo‘ky
         cmp       si,di                    ; je dal¨¡ polo‘ka ?
         jae       CompMWn3                 ; nen¡ dal¨¡ polo‘ka
         cmp       ax,ds:[si]               ; je po©ad¡ polo‘ek OK ?
         jae       CompMW29                 ; po©ad¡ polo‘ek je OK

         xchg      ax,ds:[si]               ; z mˆna polo‘ek
         mov       ds:[si-4],ax
         mov       ax,ds:[si-2]
         xchg      ax,ds:[si+2]
         mov       ds:[si-2],ax
         cmp       si,8                     ; je ji‘ po‡ tek ?
         jb        CompMW29                 ; je ji‘ po‡ tek
         sub       si,8                     ; posun k p©ede¨l‚ polo‘ce
         jmp       short CompMW29

; ------ p©¡prava ukazatel– (DI=konec polo‘ek)

CompMWn3:sti
         mov       word ptr ss:[bp-16],0    ; nen¡ ‘ dn  nalezen  polo‘ka
         mov       word ptr ss:[bp-22],0    ; nen¡ ‘ dn  testovan  polo‘ka
         mov       si,-4                    ; ukazatel testovan˜ch polo‘ek
         mov       bx,ss:[bp-26]            ; voln‚ m¡sto testovan‚ho ©etˆzce

; ------ test, zda je dal¨¡ polo‘ka

CompMW31:add       si,4                     ; zv˜¨en¡ ukazatele polo‘ek
         cmp       si,ss:[bp-18]            ; je dal¨¡ polo‘ka ?
         jae       CompMWn5                 ; nen¡ dal¨¡ polo‘ka

; ------ ode‡ten¡ polo‘ky od st©ada‡e voln‚ho m¡sta

         sub       bx,ds:[si]               ; ode‡ten¡ velikosti polo‘ky
         jc        CompMW38                 ; nen¡ voln‚ m¡sto - n vrat

; ------ test, zda je p©ete‡en¡ p©es okraj bloku adres ©e

         inc       word ptr ss:[bp-28]      ; ‡¡ta‡ polo‘ek v bloku adres ©e
         mov       ax,ss:[bp-28]            ; po‡et polo‘ek v bloku adres ©e
         sub       ax,ss:[bp-30]            ; je p©ete‡en¡ p©es hranici ?
         jbe       CompMW33                 ; nen¡ p©ete‡en¡ p©es hranici
         mov       ss:[bp-28],ax            ; nov˜ po‡et polo‘ek v bloku
         sub       bx,1                     ; sn¡‘en¡ voln‚ho m¡sta
         jc        CompMW37                 ; nedostatek pamˆti

; ------ test, zda je voln‚ m¡sto v tabulce index–

CompMW33:cmp       di,ss:[bp-12]            ; je voln‚ m¡sto ?
         jae       CompMW37                 ; nen¡ voln‚ m¡sto v tabulce

; ------ ulo‘en¡ indexu polo‘ky do tabulky

         mov       ds:[di],si               ; ulo‘en¡ indexu polo‘ky
         inc       di
         inc       di                       ; zv˜¨en¡ ukazatele adresy index–
         inc       word ptr ss:[bp-22]      ; zv˜¨en¡ ‡¡ta‡e polo‘ek
         jmp       short CompMW31

; ------ n vrat p©i p©ete‡en¡ bloku adres ©e

CompMW37:dec       word ptr ss:[bp-28]      ; n vrat ‡¡ta‡e polo‘ek
         jnz       CompMW38                 ; nen¡ p©ete‡en¡ p©es okraj adres ©e
         mov       ax,ss:[bp-30]            ; po‡et polo‘ek na aloka‡n¡ blok
         mov       ss:[bp-28],ax            ; n vrat po‡tu polo‘ek v bloku
         inc       bx                       ; zv˜¨en¡ ‡¡ta‡e voln‚ho m¡sta

; ------ zpˆtn‚ p©i‡ten¡ velikosti polo‘ky

CompMW38:add       bx,ds:[si]               ; n vrat velikosti polo‘ky
CompMW39:jmp       short CompMW31           ; test dal¨¡ polo‘ky

; ------ test, zda byl nalezen dal¨¡ ©etˆzec soubor–

CompMWn5:cmp       word ptr ss:[bp-22],0    ; bylo nˆco nalezeno ?
         je        CompMWn7                 ; nebylo nic nalezeno - konec hled n¡

; ------ test, zda je to prvn¡ ©etˆzec

         cmp       word ptr ss:[bp-16],0    ; bylo ji‘ nˆco nalezeno ?
         je        CompMW54                 ; nebylo je¨tˆ nic nalezeno - vyhovuje

; ------ test, zda nov˜ ©etˆzec je v˜hodnˆj¨¡

         cmp       bx,ss:[bp-20]            ; zbylo m‚nˆ voln‚ho m¡sta ?
         jae       CompMWn6                 ; ©etˆzec je hor¨¡

; ------ test, zda je voln‚ m¡sto k ulo‘en¡ ©etˆzce

CompMW54:mov       ax,ss:[bp-22]            ; po‡et testovan˜ch polo‘ek
         mov       cx,ax                    ; CX <- po‡et polo‘ek
         shl       ax,1                     ; velikost jedn‚ tabulky
         shl       ax,1                     ; velikost 2 tabulek
         add       ax,ss:[bp-18]            ; + adresa za‡ tku tabulky
         cmp       ax,ss:[bp-12]            ; je voln‚ m¡sto ?
         ja        CompMWn6                 ; nen¡ voln‚ m¡sto

; ------ £schova ©etˆzce soubor–

         push      si

         mov       si,ss:[bp-16]            ; po‡et polo‘ek p©ed tabulkou
         shl       si,1                     ; adresa za‡ tku tabulky
         add       si,ss:[bp-18]
         mov       di,ss:[bp-18]
         mov       ss:[bp-16],cx            ; po‡et nalezen˜ch polo‘ek
         cld
         push      cx
         rep       movsw                    ; p©esun tabulky dol–
         pop       cx
         mov       si,ss:[bp-18]            ; uschovan  tabulka
         rep       movsw                    ; tabulka je¨tˆ jednou

         pop       si

; ------ £schova parametr– ©etˆzce

         mov       ss:[bp-20],bx            ; £schova voln‚ho m¡sta
         or        bx,bx                    ; je ji‘ maxim ln¡ ©etˆzec ?
         jz        CompMWn7                 ; ©etˆzec ji‘ vyhovuje
         mov       ax,ss:[bp-16]            ; po‡et nalezen˜ch polo‘ek
         cmp       ax,ss:[bp-24]            ; jsou to v¨echny polo‘ky ?
         jae       CompMWn7                 ; jsou to v¨echny polo‘ky

; ------ vyjmut¡ posledn¡ polo‘ky z tabulky

CompMWn6:dec       di
         dec       di                       ; sn¡‘en¡ ukl dac¡ adresy
         mov       si,ds:[di]               ; adresa p©ede¨l‚ polo‘ky
         dec       word ptr ss:[bp-22]      ; sn¡‘en¡ po‡tu polo‘ek

         push      ds
         mov       ds,ss:[bp-34]
         call      far ptr TestBEsc
         pop       ds
         jnc       CompMW37

; ------ vynulov n¡ neodpov¡daj¡c¡ch polo‘ek

CompMWn7:mov       ds,ss:[bp-34]            ; datov˜ segment
         test      byte ptr ss:[bp-8],bit0  ; je ozna‡en¡ polo‘ek ?
         jz        CompMW70                 ; nen¡ ozna‡en¡ polo‘ek
         test      byte ptr ss:[bp-8],bit5  ; pouze ozna‡en‚ polo‘ky ?
         jnz       CompMW73                 ; pro ozna‡en‚ polo‘ky se nuluje v‘dy
CompMW70:test      byte ptr ss:[bp-8],bit6  ; neodpov¡daj¡c¡ polo‘ky nulovat ?
         jnz       CompMW72                 ; nenuluj¡ se
CompMW73:xor       bx,bx                    ; ukazatel ‡¡sla polo‘ky
         mov       es,ss:[bp-4]             ; adresa okna
CompMW71:cmp       bx,es:[AWinSouN]         ; kontrola ‡¡sla polo‘ky
         jae       CompMW72                 ; nen¡ dal¨¡ polo‘ka
         call      far ptr ResSPol          ; nulov n¡ ozna‡en¡ polo‘ky BX
         inc       bx                       ; zv˜¨en¡ ukazatele polo‘ky
         jmp       short CompMW71

; ------ test, zda byla nˆjak  polo‘ka nalezena

CompMW72:cmp       word ptr ss:[bp-16],0    ; po‡et nalezen˜ch polo‘ek
         je        CompMWn8                 ; nebylo nic nalezeno
         mov       di,ss:[bp-18]            ; ukazatel v tabulce index–
         mov       dx,ss:[bp-8]             ; parametry

; ------ ozna‡en¡ polo‘ky

CompMW74:mov       es,ss:[bp-14]            ; adresa bufferu
         mov       bx,es:[di]               ; adresa indexu
         mov       bx,es:[bx+2]             ; ‡¡slo polo‘ky
         mov       es,ss:[bp-4]             ; adresa okna
         call      SelPol0X                 ; ozna‡en¡ polo‘ky BX
         inc       di
         inc       di                       ; zv˜¨en¡ ukazatele index–
         dec       word ptr ss:[bp-16]      ; ‡¡ta‡ polo‘ek
         jnz       CompMW74                 ; dal¨¡ polo‘ka

; ------ zru¨en¡ datov‚ho bufferu

CompMWn8:mov       ax,ss:[bp-10]            ; datov˜ buffer
         call      far ptr DelSeg           ; zru¨en¡ datov‚ho bufferu

; ------ n vrat registr–

CompMWn9:mov       sp,bp
         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         jmp       CompWinA                 ; uzav©en¡ hl ¨en¡

CompMWn  ENDP

;; -----------------------------------------------------------------------------
;;        nalezen¡ minim ln¡ cesty v oknˆ adresa DX, buffer SS:DI -> d‚lka AX
;; -----------------------------------------------------------------------------
;
;CompWPth PROC      NEAR
;
;; ------ p©¡prava registr–
;
;         xor       bx,bx                    ; ukazatel polo‘ek
;         xor       ax,ax                    ; ukazatel referen‡n¡ d‚lky
;         mov       ch,0                     ; CH <- 0
;         push      bp
;         push      ds
;         mov       bp,dx                    ; BP <- adresa okna
;
;; ------ adresa jedn‚ polo‘ky
;
;CompWPt1:mov       es,bp                    ; ES <- adresa okna
;         call      far ptr GetESPol         ; adresa polo‘ky ES:SI
;         jc        CompWPt9                 ; nen¡ dal¨¡ polo‘ka
;
;; ------ test, zda to je cesta
;
;         test      byte ptr es:[si+FileAtr],ATRT ; je to cesta ?
;         jnz       CompWPt8                 ; nen¡ to cesta
;
;; ------ p©¡prava registr– k dek¢dov n¡ cesty
;
;         cld
;         push      di                       ; £schova za‡ tku bufferu
;
;         push      es
;         pop       ds                       ; DS <- segment polo‘ky
;         push      ss
;         pop       es                       ; ES <- segment bufferu
;         mov       cl,ds:[si]               ; CX <- d‚lka cesty
;         mov       dl,cl                    ; £schova d‚lky cesty polo‘ky
;         inc       si                       ; SI = za‡ tek polo‘ky
;
;; ------ inicializa‡n¡ ulo‘en¡ cesty
;
;         or        ax,ax                    ; byla ji‘ cesta ?
;         jnz       CompWPt3                 ; byla ji‘ cesta
;         cmp       cl,FileMax               ; je d‚lka cesty OK ?
;         jbe       CompWPt2                 ; d‚lka cesty je OK
;         mov       cl,FileMax               ; omezen¡ d‚lky cesty
;CompWPt2:mov       al,cl                    ; AL <- nov  uschovan  d‚lka cesty
;         rep       movsb                    ; £schova cesty
;         jmp       short CompWPt7
;
;; ------ omezen¡ nov‚ d‚lky cesty
;
;CompWPt3:cmp       ax,cx                    ; je d‚lka OK ?
;         jbe       CompWPt4                 ; d‚lka je OK
;         xchg      ax,cx                    ; AX <- omezen¡ d‚lky cesty
;
;; ------ porovn n¡ cest
;
;CompWPt4:mov       cl,al                    ; CL <- shodn  d‚lka cesty
;         repe      cmpsb                    ; porovn n¡ ‡ sti cesty
;         jne       CompWPt5                 ; nalezen rozd¡l cest
;
;; ------ ‡ sti cest shodn‚ - porovn n¡ d‚lky cesty
;
;         cmp       al,dl                    ; je shodn  d‚lka cest ?
;         je        CompWPt7                 ; cesty jsou shodn‚
;
;; ------ uschovan  cesta je krat¨¡ - v bufferu mus¡ b˜t "\"
;
;         ja        CompWPt5                 ; uschovan  cesta je del¨¡
;         cmp       byte ptr ds:[si],"\"     ; je oddˆlova‡ cesty ?
;         jmp       short CmpWPt52
;
;; ------ uschovan  cesta je del¨¡ - mus¡ n sledovat "\"
;
;CompWPt5:cmp       byte ptr es:[di],"\"     ; n sleduje "\" ?
;CmpWPt52:je        CompWPt7                 ; cesta je OK
;
;; ------ cesty se li¨¡ - nalezen¡ nov‚ho konce cest
;
;CompWPt6:sub       al,cl                    ; zkr cen¡ cesty o zbytek
;         cmp       byte ptr es:[di-1],"\"   ; byl odli¨n˜ znak oddˆlova‡ ?
;         jne       CmpWPt62                 ; nebyl
;         dec       di                       ; p©esko‡en¡ znaku oddˆlova‡e
;         dec       ax                       ; sn¡‘en¡ ‡¡ta‡e d‚lky
;         jz        CompWPt7                 ; je ji‘ konec
;CmpWPt62:dec       di                       ; posun ukazatele textu
;         dec       ax                       ; posun ‡¡ta‡e d‚lky
;         jz        CompWPt7                 ; je ji‘ konec
;         cmp       byte ptr es:[di],"\"     ; je oddˆlova‡ cesty ?
;         jne       CmpWPt62                 ; dal¨¡ test
;
;; ------ p©¡prava pro dal¨¡ polo‘ku
;
;CompWPt7:pop       di
;CompWPt8:inc       bx                       ; zv˜¨en¡ ukazatele ‡¡sla polo‘ek
;         jmp       short CompWPt1           ; dal¨¡ polo‘ka
;
;; ------ n vrat registr–
;
;CompWPt9:pop       ds
;         pop       bp
;         ret
;
;CompWPth ENDP
;
;; ------ £schova registr–
;
;CompWin0:push      ax
;         push      bx
;         push      cx
;         push      si
;         push      di
;         push      bp
;         push      ds
;         push      es
;
;; ------ p©¡prava registr– - adresy porovn van˜ch oken
;
;         call      far ptr GetDat           ; poskytnut¡ adresy prvn¡ho okna
;         jc        CompWn04                 ; neplatn˜ segment
;         mov       bp,es                    ; BP <- adresa prvn¡ho okna
;
;         push      ds
;         mov       cx,es:[AWinSouN]         ; po‡et polo‘ek v oknˆ
;         mov       word ptr ds:[InfoKMax],cx ; maximum pro kurzor
;         xor       cx,cx
;         mov       word ptr ds:[InfoKMax+2],cx
;         mov       word ptr ds:[InfoKCit],cx
;         mov       word ptr ds:[InfoKCit+2],cx
;         call      far ptr InfoKurz         ; zobrazen¡ informa‡n¡ho kurzoru
;         pop       cx                       ; CX <- £schova DS
;
;         xchg      ax,bx                    ; AX <- ‡¡slo druh‚ho okna
;         push      dx
;         call      far ptr GetSgAdr         ; adresa protˆj¨¡ho okna
;         xchg      ax,dx                    ; AX <- adresa druh‚ho okna
;         pop       dx
;CompWn04:jc        CompWin9                 ; neplatn˜ segment
;         xor       bx,bx                    ; ukazatel polo‘ek okna
;
;; ------ obsluha zobrazen¡ kurzoru
;
;CompWin1:mov       ds,cx                    ; DS <- datov˜ segment
;         call      far ptr TestTDis         ; test ‡asov‚ho zobrazen¡
;         jc        CompWn14                 ; nen¡ je¨tˆ pot©eba zobrazen¡
;
;         push      cx
;         mov       cx,bx
;         sub       cx,word ptr ds:[InfoKCit]
;         call      far ptr InfoKurz         ; zobrazen¡ kurzoru
;         pop       cx
;
;; ------ adresa prvn¡ testovan‚ polo‘ky ES:DI
;
;CompWn14:mov       es,bp                    ; adresa prvn¡ho okna
;         call      far ptr GetPolDI         ; adresa polo‘ky
;         jc        CompWin9                 ; jsou ji‘ v¨echny soubory
;
;; ------ nalezen¡ testovan‚ polo‘ky ES:DI v protˆj¨¡m oknˆ DS
;
;         mov       ds,ax                    ; adresa druh‚ho okna
;         call      SrcPol                   ; nalezen¡ polo‘ky v protˆj¨¡m oknˆ
;         jnc       CompWin2                 ; nalezena stejn  polo‘ka DS:SI
;
;; ------ polo‘ka nenalezena
;
;         test      dh,bit0                  ; zna‡¡ se dopl¤kov‚ polo‘ky ?
;         jmp       short CompWin5
;
;; ------ porovn n¡ data a ‡asu polo‘ek
;
;CompWin2:call      CompPolD                 ; porovn n¡ polo‘ky ES:DI s DS:SI
;         ja        CompWin3                 ; polo‘ka je novˆj¨¡
;         jb        CompWin4                 ; polo‘ka je star¨¡
;
;; ------ datum a ‡as shodn‚ - porovn n¡ t‚‘ velikosti polo‘ek
;
;         call      CompPolS                 ; porovn n¡ polo‘ky ES:DI s DS:SI
;         je        CompWn23                 ; velikosti jsou tak‚ shodn‚
;
;; ------ velikost je rozd¡ln  - test, zda se zna‡¡ rozd¡ln‚
;
;         test      dh,bit4                  ; zna‡¡ se rozd¡ln‚ ?
;         jmp       short CompWin5
;
;; ------ polo‘ka je shodn 
;
;CompWn23:test      dh,bit3                  ; zna‡¡ se shodn‚ polo‘ky ?
;         jmp       short CompWin5
;
;; ------ polo‘ka je novˆj¨¡
;
;CompWin3:test      dh,bit1                  ; zna‡¡ se novˆj¨¡ ?
;         jmp       short CompWin5
;
;; ------ polo‘ka je star¨¡
;
;CompWin4:test      dh,bit2                  ; zna‡¡ se star¨¡ ?
;CompWin5:jz        CompWin7                 ; nezna‡¡ se star¨¡ - dal¨¡ polo‘ka
;
;; ------ polo‘ka odpov¡d  - ozna‡en¡ polo‘ky
;
;CompWin6:
;         call      SelPolX                  ; ozna‡en¡ polo‘ky BX
;         jmp       short CompWin8
;
;; ------ nulov n¡ neodpov¡daj¡c¡ polo‘ky
;
;CompWin7:test      dh,bit7                  ; nuluj¡ se neodpov¡daj¡c¡ polo‘ky ?
;         jz        CompWin8                 ; polo‘ky se nenuluj¡
;         mov       es,bp                    ; ES <- segment prvn¡ho okna
;         call      far ptr ResSPol          ; nulov n¡ ozna‡en¡ polo‘ky BX
;
;; ------ p©¡prava pro dal¨¡ polo‘ku
;
;CompWin8:inc       bx                       ; zv˜¨en¡ ‡¡sla polo‘ky
;         jmp       short CompWin1           ; test dal¨¡ polo‘ky
;
;; ------ n vrat registr–
;
;CompWin9:pop       es
;         pop       ds
;         pop       bp
;         pop       di
;         pop       si
;         pop       cx
;         pop       bx
;         pop       ax

;; -----------------------------------------------------------------------------
;;                                  SrcPol
;;                 nalezen¡ polo‘ky shodn‚ho jm‚na (ve tvaru FCB)
;; -----------------------------------------------------------------------------
;; VSTUP: ES:DI=hledan  polo‘ka
;;        DS=segment definice okna, ve kter‚m m  b˜t polo‘ka nalezena
;; VSTUP:DS:SI=adresa nalezen‚ shodn‚ polo‘ky
;;        CY=polo‘ka nenalezena
;; -----------------------------------------------------------------------------
;
;SrcPol   PROC      NEAR
;
;; ------ £schova registr–
;
;         push      ax
;         push      bx
;         push      cx
;         push      dx
;         push      bp
;         push      di
;
;; ------ p©¡prava registr–
;
;         cld
;         mov       ch,0                     ; CH <- 0
;         inc       di
;         mov       bp,di                    ; BP <- hledan  polo‘ka (jm‚no)
;         mov       ax,ds                    ; AX <- segment okna
;         xor       bx,bx                    ; ukazatel ‡¡sla polo‘ky
;
;; ------ adresa testovan‚ polo‘ky -> DS:SI
;
;SrcPol1: push      es
;         mov       es,ax                    ; adresa okna
;         call      far ptr GetESPol         ; adresa polo‘ky (nesm¡ mˆnit CLD !)
;         push      es
;         pop       ds                       ; DS <- segment adresy polo‘ky
;         pop       es
;         jc        SrcPol9                  ; nen¡ dal¨¡ polo‘ka
;         mov       dx,si                    ; DX <- £schova offsetu polo‘ky
;         inc       bx                       ; zv˜¨en¡ ‡¡sla polo‘ky
;
;; ------ porovn n¡ polo‘ek
;
;         inc       si                       ; za‡ tek jm‚na nalezen‚ polo‘ky
;         mov       di,bp                    ; DI <- hledan  polo‘ka
;         mov       cl,11                    ; d‚lka jm‚na s p©¡ponou
;         repe      cmpsb                    ; porovn n¡ polo‘ek
;         jne       SrcPol1                  ; polo‘ka nenalezena - dal¨¡
;         mov       si,dx                    ; SI <- adresa nalezen‚ polo‘ky
;
;; ------ n vrat registr–
;
;SrcPol9: pop       di
;         pop       bp
;         pop       dx
;         pop       cx
;         pop       bx
;         pop       ax
;         ret
;
;SrcPol   ENDP

; -----------------------------------------------------------------------------
;        volba "zadan‚"
; -----------------------------------------------------------------------------

AWMMSB18:add       sp,4                     ; zru¨en¡ n vratov‚ adresy
         call      far ptr ClosMnuA         ; uzav©en¡ v¨ech oken menu

; -----------------------------------------------------------------------------
;        ozna‡en¡ zadan˜ch polo‘ek (DL: bit0=ozna‡, bit1=odzna‡, bit2=invertuj)
; -----------------------------------------------------------------------------

; ------ test, zda je aktivn¡ okno zapnuto

SelSelct:call      far ptr TestAAWn         ; test aktivn¡ho okna
         jc        AWMSB1A1                 ; aktivn¡ okno nen¡ zapnuto

; ------ volba polo‘ek k v˜bˆru

SelSelc0:mov       si,offset SB1MnLin       ; menu v˜bˆru soubor– k ozna‡en¡
         test      dl,bit0                  ; ozna‡en¡ ?
         jnz       AWMSB1A0                 ; ozna‡en¡
         mov       si,offset SB2MnLin       ; menu v˜bˆru soubor– k odzna‡en¡
         test      dl,bit1                  ; odzna‡en¡ ?
         jnz       AWMSB1A0                 ; odzna‡en¡
         mov       si,offset SB3MnLin       ; menu v˜bˆru soubor– k inverzi
AWMSB1A0:mov       ds:[SelParm0],dl         ; £schova p©¡znak– volby
         call      far ptr Lin0Menu         ; obsluha menu
         jnc       AWMSB1A3                 ; volba OK
AWMSB1A1:jmp       AWSMnuMM                 ; n vrat do hlavn¡ obsluhy

; ------ rozbor zad n¡ polo‘ek k ozna‡en¡

AWMSB1A3:mov       byte ptr ds:[FileTyp],bit3+bit6 ; parametry hled n¡
         call      far ptr RozborZ          ; rozbor zad n¡ parametr–
         jc        AWMSB1A1                 ; p©eru¨en¡ operace
         mov       dl,ds:[SelParm0]         ; zadan˜ parametr
         jnz       SelSelc0                 ; chyba - opakov n¡ zad n¡

; ------ p©¡prava k vyhled v n¡ polo‘ek

         xor       bx,bx                    ; ukazatel ‡¡sla polo‘ky
         mov       dl,ds:[SelParm0]         ; zadan˜ parametr
         call      far ptr GetAAWin         ; adresa aktivn¡ho okna
         mov       bp,es                    ; BP <- adresa okna
         mov       ax,es:[AWinFrst]         ; po‡ te‡n¡ polo‘ka
         mov       cs:[AWMSBFrs],ax         ; £schova po‡ te‡n¡ polo‘ky
         mov       ax,es:[AWinKurz]         ; kurzor z okna
         mov       cs:[AWMSBKrz],ax         ; £schova kurzoru

; ------ p©ednastaven¡ cesty pro hled n¡ textu

         push      ds
         push      ds
         pop       es                       ; ES <- datov˜ segment
         mov       ds,bp                    ; DS <- segment okna
         mov       si,AWinDir               ; SI <- aktivn¡ adres © okna
         mov       di,offset FilePath       ; adresa bufferu pro operaci
         mov       cx,ds:[AWinDNum]         ; d‚lka aktivn¡ho adres ©e
         cld
         rep       movsb                    ; p©enesen¡ textu adres ©e
         mov       al,"\"
         dec       di                       ; n vrat na posledn¡ znak
         scasb                              ; je cesta ukon‡ena znakem "\" ?
         je        AWMS1A32                 ; je ukon‡ena OK
         stosb                              ; ulo‘en¡ znaku "\"
AWMS1A32:sub       di,offset FilePath       ; d‚lka textu
         pop       ds
         mov       ds:[FilePthN],di         ; d‚lka cesty (s "\" na konci)

; ------ adresa jedn‚ polo‘ky

         dec       bx                       ; p©ednastaven¡
AWMSB1A4:inc       bx                       ; zv˜¨en¡ ukazatele polo‘ek
         mov       es,bp                    ; adresa okna
         mov       es:[AWinKurz],bx         ; nastaven¡ kurzoru v oknˆ
         call      far ptr GetESPol         ; adresa polo‘ky ES:SI
         jnc       AWMS1A42                 ; je dal¨¡ polo‘ka OK

; ------ n vrat kurzoru

AWMS1A41:mov       es,bp                    ; ES <- adresa okna
         mov       ax,cs:[AWMSBKrz]         ; uschovan˜ kurzor
         mov       es:[AWinKurz],ax         ; n vrat p–vodn¡ho kurzoru
         mov       ax,cs:[AWMSBFrs]         ; uschovan  po‡ te‡n¡ polo‘ka
         mov       es:[AWinFrst],ax         ; n vrat po‡ te‡n¡ polo‘ky
         jmp       short AWMSB1A1           ; nen¡ dal¨¡ polo‘ka

; ------ test, zda to je platn  polo‘ka

AWMS1A42:test      byte ptr es:[si+FileAtr],ATRT ; je to platn  polo‘ka ?
         jnz       AWMS1A44                 ; je to platn  polo‘ka

; ------ £schova cesty ze seznamu

         push      ds
         push      es                       ; segment polo‘ky
         push      ds                       ; datov˜ segment
         pop       es                       ; ES <- datov˜ segment
         pop       ds                       ; DS <- segment polo‘ky
         mov       di,offset FilePath       ; adresa bufferu pro operaci
         mov       ch,0
         mov       cl,ds:[si]               ; CX <- d‚lka textu adres ©e
         inc       si                       ; za‡ tek textu adres ©e
         cld
         rep       movsb                    ; p©enesen¡ textu adres ©e
         mov       al,"\"
         dec       di                       ; n vrat na posledn¡ znak
         scasb                              ; je cesta ukon‡ena znakem "\" ?
         je        AWMS1A43                 ; je ukon‡ena OK
         stosb                              ; ulo‘en¡ znaku "\"
AWMS1A43:sub       di,offset FilePath       ; d‚lka textu
         pop       ds
         mov       ds:[FilePthN],di         ; d‚lka cesty (s "\" na konci)
         jmp       short AWMSB1A4           ; dal¨¡ polo‘ka

; ------ test jm‚na polo‘ky, zda odpov¡d  masce

AWMS1A44:inc       si                       ; jm‚no polo‘ky
         mov       di,offset FileMask       ; maska pro hled n¡
         mov       cx,ds:[FileMskN]         ; d‚lka masky pro hled n¡
         call      far ptr TestMask         ; test, zda polo‘ka vyhovuje
         jc        AWMSB1A4                 ; polo‘ka nevyhovuje
         dec       si                       ; n vrat adresy polo‘ky

; ------ p©¡prava fiktivn¡ polo‘ky DTA

         mov       di,offset BuffDTA        ; pracovn¡ buffer DTA
         mov       al,es:[si+FileAtr]       ; atributy polo‘ky
         mov       ds:[di+DTAAtrib],al
         mov       ax,word ptr es:[si+FileSize]
         mov       ds:[di+DTASize],ax
         mov       word ptr ds:[InfoKMax],ax ; velikost kurzoru operace LOW
         mov       ax,word ptr es:[si+FileSize+2]
         mov       ds:[di+DTASize+2],ax
         mov       word ptr ds:[InfoKMax+2],ax ; velikost kurzoru operace HIGH
         mov       ax,es:[si+FileDate]
         mov       ds:[di+DTADate],ax
         mov       ax,es:[si+FileTime]
         mov       ds:[di+DTATime],ax

; ------ test ostatn¡ch parametr– polo‘ky

         push      si                       ; offset testovan‚ polo‘ky
         push      es                       ; segment testovan‚ polo‘ky
         push      ds
         pop       es                       ; ES <- datov˜ segment
         mov       si,di                    ; adresa bufferu DTA
         mov       di,offset SrcAtr         ; za‡ tek parametr–
         call      far ptr GetBTest         ; test parametr– polo‘ky
         pop       es
         pop       si
         jc        AWMSB1A9                 ; polo‘ka nevyhovuje

; ------ test, zda se hled  text

         cmp       byte ptr ds:[SrcTextN],0 ; je zad n text k hled n¡ ?
         je        AWMSB1A8                 ; nen¡ text k hled n¡
         test      byte ptr es:[si+FileAtr],DIR ; je to adres © ?
         jnz       AWMSB1A9                 ; pro adres © je z kaz - nevyhovuje

; ------ test, zda je p©eru¨en¡ operace

         call      far ptr TestBEsc         ; je p©eru¨en¡ operace ?
         jnc       AWMSB1A5                 ; nen¡ p©eru¨en¡ operace
         call      far ptr FlushChr         ; vypr zdnˆn¡ kl vesnice
         jmp       AWMS1A41                 ; p©eru¨en¡ operace

; ------ p©¡prava jm‚na souboru (do bufferu FilePath)

AWMSB1A5:push      ds                       ; datov˜ segment
         mov       di,ds:[FilePthN]         ; d‚lka textu cesty
         add       di,offset FilePath       ; adresa konce cesty
         push      es                       ; segment polo‘ky
         push      ds                       ; datov˜ segment
         pop       es                       ; ES <- datov˜ segment
         pop       ds                       ; DS <- segment polo‘ky
         inc       si                       ; jm‚no polo‘ky
         call      far ptr FileAsc          ; dek¢dov n¡ jm‚na polo‘ky
         mov       si,offset FilePath       ; za‡ tek cesty
         sub       di,si                    ; d‚lka jm‚na polo‘ky
         mov       cx,di                    ; CX <- d‚lka jm‚na polo‘ky
         pop       ds                       ; datov˜ segment

; ------ test, zda soubor ES:SI/CX obsahuje hledan˜ text

         call      far ptr DispAAWn         ; aktu ln¡ zobrazen¡ okna
         call      far ptr DispTime         ; obsluha zobrazen¡ ‡asu
         push      dx
         push      di
         mov       dx,ds                    ; DX <- datov˜ segment
         mov       di,offset SrcInit        ; tabulka parametr– k hled n¡
         call      far ptr SrcFText         ; test, zda soubor obsahuje text
         pop       di
         pop       dx
         jc        AWMSB1A9                 ; text nenalezen

; ------ polo‘ka vyhovuje - ozna‡en¡ polo‘ky (typ ozna‡en¡ v DL)

AWMSB1A8:call      SelPolX                  ; ozna‡en¡ polo‘ky
AWMSB1A9:jmp       AWMSB1A4                 ; test dal¨¡ polo‘ky

AWMSBKrz dw        0                        ; uschovan˜ kurzor z okna
AWMSBFrs dw        0                        ; uschovan  po‡ te‡n¡ polo‘ka

; -----------------------------------------------------------------------------
;        ozna‡en¡ polo‘ek (DL=typ)
; -----------------------------------------------------------------------------

SelPolX  PROC      NEAR

         mov       es,bp
SelPol0X:call      far ptr SelPol0
         ret

SelPolX  ENDP

; *****************************************************************************
;
;                     Filtr soubor– (volba "Filtr")
;
; *****************************************************************************
;þ
AWMMnuSF PROC      FAR

; ------ z kaz polo‘ek "kurzor" a "ozna‡en‚" p©i vypnut‚m aktivn¡m oknˆ

         and       word ptr ds:[SFMnVBlk+9],not (bit1+HI*bit1) ; polo‘ky povoleny
         call      far ptr TestAAWn         ; je aktivn¡ okno zapnuto ?
         jnc       AWMMnSF1                 ; okno je zapnuto
         or        word ptr ds:[SFMnVBlk+9],bit1+HI*bit1 ; z kaz polo‘ek

AWMMnSF1:call      FiltMIni                 ; inicializace menu filtru

         mov       ax,word ptr ds:[SMnuVert+MnuPoz] ; pozice p©edchoz¡ho okna
         add       ax,107h                  ; posun okna
         mov       word ptr ds:[si+MnuPoz],ax        ; pozice okna

         jmp       far ptr VertMenu

AWMMnuSF ENDP

; -----------------------------------------------------------------------------
;        p©¡prava p©ep¡na‡– menu Filtr
; -----------------------------------------------------------------------------

FiltMIni PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      dx
         push      si
         mov       si,offset SFMnVert       ; menu filtrace soubor–

; ------ text vstupn¡ho k¢du souboru

         mov       al,3                     ; po‡et bajt– na polo‘ku
         mul       byte ptr ds:[InpKod]     ; offset textu vstupn¡ho k¢du
         xchg      ax,bx                    ; text vstupn¡ho k¢du
         mov       ax,word ptr ds:[bx+KodyTxtT] ; prvn¡ 2 znaky
         mov       word ptr ds:[SFMnVPl1],ax ; prvn¡ 2 znaky
         mov       al,ds:[bx+KodyTxtT+2]    ; t©et¡ znak
         mov       ds:[SFMnVPl1+2],al       ; posledn¡ znak

; ------ text v˜stupn¡ho k¢du souboru

         mov       al,3                     ; po‡et bajt– na polo‘ku
         mul       byte ptr ds:[OutKod]     ; offset textu v˜stupn¡ho k¢du
         xchg      ax,bx                    ; text v˜stupn¡ho k¢du
         mov       ax,word ptr ds:[bx+KodyTxtT] ; prvn¡ 2 znaky
         mov       word ptr ds:[SFMnVPl2],ax ; prvn¡ 2 znaky
         mov       al,ds:[bx+KodyTxtT+2]    ; t©et¡ znak
         mov       ds:[SFMnVPl2+2],al       ; posledn¡ znak

; ------ nastaven¡ p©ep¡na‡– menu

         mov       dl,ds:[FiltrPar]         ; parametry filtru
         mov       dh,0
         call      far ptr SetSwch          ; nastaven¡ p©ep¡na‡–

; ------ nastaven¡ po‡tu pozic na tabul tor

         mov       al,ds:[TabPozic]         ; po‡et pozic na tabul tor
         aam                                ; konverze na 2 znaky BCD
         xchg      ah,al                    ; oprava po©ad¡ ‡¡slic
         add       ax,"00"                  ; konverze na ASCII znaky
         cmp       al,"0"                   ; prvn¡ ‡¡slice = 0 ?
         jne       FiltMIn2                 ; prvn¡ ‡¡slice nen¡ 0
         mov       al," "                   ; potal‡en¡ nev˜znamn‚ nuly
FiltMIn2:mov       word ptr ds:[SFMnVPl3],ax ; ozna‡en¡ po‡tu pozic

; ------ n vrat registr–

         pop       si
         pop       dx
         pop       bx
         pop       ax
         ret

FiltMIni ENDP

; -----------------------------------------------------------------------------
;        volba vstupn¡ho k¢du souboru
; -----------------------------------------------------------------------------

FiltrS   PROC      FAR

         call      FiltrSX                  ; p©¡prava p©ep¡na‡e vstup. k¢du

         mov       ax,word ptr ds:[SFMnVert+MnuPoz] ; pozice p©edchoz¡ho okna
         add       ax,107h                  ; posun okna
         mov       word ptr ds:[si+MnuPoz],ax        ; pozice okna

         jmp       far ptr VertMenu

FiltrS   ENDP

; -----------------------------------------------------------------------------
;        p©¡prava p©ep¡na‡e vstupn¡ho k¢du
; -----------------------------------------------------------------------------

FiltrSX  PROC      NEAR

         push      cx
         push      dx

         mov       dl,bit0
         mov       cl,ds:[InpKod]           ; vstupn¡ k¢d
         shl       dl,cl                    ; rotace p©ep¡na‡e na pozici
         mov       dh,0
         call      far ptr SetSwch          ; nastaven¡ p©ep¡na‡e

         pop       dx
         pop       cx
         ret

FiltrSX  ENDP

; -----------------------------------------------------------------------------
;        obsluha volby p©ep¡na‡e vstupn¡ho k¢du
; -----------------------------------------------------------------------------

FiltrS1  PROC      FAR

         mov       al,byte ptr ds:[si+MnuAkt] ; aktivn¡ zvolen  polo‘ka
         dec       ax                       ; oprava polo‘ky
         mov       ds:[InpKod],al           ; zvolen˜ vstupn¡ k¢d
         call      FiltrSX                  ; oprava p©ep¡na‡e vstup. k¢du
FiltrS2: call      FiltMIni                 ; oprava p©ep¡na‡e menu filtru
         cmp       bl," "                   ; je mezera ?
         jne       FiltrS3                  ; nen¡ mezera - konec
         call      far ptr DispAll          ; nov‚ zobrazen¡ v¨eho
         ret                                ; n vrat do menu

FiltrS3: add       sp,4                     ; zru¨en¡ n vratov‚ adresy
         push      word ptr ds:[si+MnuBreak+2] ; n vratov  adresa z menu - segm.
         push      word ptr ds:[si+MnuBreak] ; n vratov  adresa z menu - offset
         call      far ptr ClosMnu          ; uzav©en¡ menu volby k¢du
         ret                                ; skok do p©edchoz¡ho menu

FiltrS1  ENDP

; -----------------------------------------------------------------------------
;        volba v˜stupn¡ho k¢du souboru
; -----------------------------------------------------------------------------

FiltrV   PROC      FAR

         call      FiltrVX                  ; p©¡prava p©ep¡na‡e v˜stup. k¢du

         mov       ax,word ptr ds:[SFMnVert+MnuPoz] ; pozice p©edchoz¡ho okna
         add       ax,107h                  ; posun okna
         mov       word ptr ds:[si+MnuPoz],ax        ; pozice okna

         jmp       far ptr VertMenu

FiltrV   ENDP

; -----------------------------------------------------------------------------
;        p©¡prava p©ep¡na‡e v˜stupn¡ho k¢du
; -----------------------------------------------------------------------------

FiltrVX  PROC      NEAR

         push      cx
         push      dx

         mov       dl,bit0
         mov       cl,ds:[OutKod]           ; v˜stupn¡ k¢d
         shl       dl,cl                    ; rotace p©ep¡na‡e na pozici
         mov       dh,0
         call      far ptr SetSwch          ; nastaven¡ p©ep¡na‡e

         pop       dx
         pop       cx
         ret

FiltrVX  ENDP

; -----------------------------------------------------------------------------
;        obsluha volby p©ep¡na‡e v˜stupn¡ho k¢du
; -----------------------------------------------------------------------------

FiltrV1  PROC      FAR

         mov       al,byte ptr ds:[si+MnuAkt] ; aktivn¡ zvolen  polo‘ka
         dec       ax                       ; oprava polo‘ky
         mov       ds:[OutKod],al           ; zvolen˜ vstupn¡ k¢d
         call      FiltrVX                  ; oprava p©ep¡na‡e v˜stup. k¢du
         jmp       short FiltrS2            ; n vrat z menu

FiltrV1  ENDP

; -----------------------------------------------------------------------------
;        Zmˆna tabul tor– na mezery
; -----------------------------------------------------------------------------

FiltrM   PROC      FAR

         xor       dl,bit0                  ; zmˆna Mezery
         and       dl,not bit1 + bit2       ; vypnout Tabul tory a N hrada

; ------ nov‚ nastaven¡ p©ep¡na‡–

Filtr11: mov       ds:[FiltrPar],dl         ; nov‚ nastaven¡ p©ep¡na‡– filtru
         call      FiltMIni                 ; inicializace p©ep¡na‡–
         call      far ptr DispMnu          ; nov‚ zobrazen¡ menu
         ret

FiltrM   ENDP

; -----------------------------------------------------------------------------
;        Zmˆna mezer na tabul tory
; -----------------------------------------------------------------------------

FiltrT:  xor       dl,bit1                  ; zmˆna Tabul tory
         and       dl,not bit0 + bit2       ; vypnout Mezery a N hrada
         jmp       short Filtr11

; -----------------------------------------------------------------------------
;        Mal  p¡smena na velk 
; -----------------------------------------------------------------------------

FiltrU:  xor       dl,bit3                  ; zmˆna Velk 
         and       dl,not bit4              ; vypnout Mal 
         jmp       short Filtr11

; -----------------------------------------------------------------------------
;        Velk  p¡smena na mal 
; -----------------------------------------------------------------------------

FiltrD:  xor       dl,bit4                  ; zmˆna Mal 
         and       dl,not bit3              ; vypnout Velk 
         jmp       short Filtr11

; -----------------------------------------------------------------------------
;        zachov n¡ data a ‡asu souboru
; -----------------------------------------------------------------------------

FiltrC:  xor       dl,bit5                  ; zmˆna Datum a ‡as
         jmp       short Filtr11

; -----------------------------------------------------------------------------
;        N hrada textu
; -----------------------------------------------------------------------------

FiltrN:  xor       dl,bit2                  ; zmˆna N hrada
         and       dl,not bit0 + bit1       ; vypnout Mezery a Tabul toru
         jmp       short Filtr11

; -----------------------------------------------------------------------------
;        Volba po‡tu pozic tabul toru
; -----------------------------------------------------------------------------

FiltrP   PROC      FAR

         push      ds
         pop       es                       ; ES <- datov˜ segment
         mov       bx,99                    ; maxim ln¡ hodnota ‡¡sla
         mov       ch,1                     ; minim ln¡ hodnota ‡¡sla
         mov       cl,2                     ; d‚lka textu
         mov       dx,word ptr ds:[si+MnuPoz] ; po‡ te‡n¡ pozice menu
         add       dx,6*HI + 17             ; pozice relativnˆ
         mov       di,offset SFMnVPl3       ; buffer k dek¢dov n¡ pozic
         push      si
         mov       si,offset TabTxt1        ; text n povˆdy
         call      far ptr MenuNum          ; zad n¡ pozic tabul toru
         pop       si
         mov       ds:[TabPozic],al         ; nov  hodnota tabul toru
         call      FiltMIni                 ; inicializace p©ep¡na‡– menu
         call      far ptr DispMnu          ; nov‚ zobrazen¡ menu
         ret

FiltrP   ENDP

; -----------------------------------------------------------------------------
;        Proveden¡ filtrace soubor–
; -----------------------------------------------------------------------------
;þ
; ------ kurzor

FiltrK   PROC      NEAR

         mov       al,bit0 + bit4 + bit6 + bit7 ; kurzor
         jmp       short FiltrK1

; ------ ozna‡en‚ soubory

FiltrO:  mov       al,bit1 + bit4 + bit6 + bit7 ; ozna‡en‚
         jmp       short FiltrK1

; ------ zadan‚ soubory

FiltrZ:  mov       al,bit3 + bit4 + bit6    ; zadan‚

; ------ inicializace vyhled v n¡

FiltrK1: add       sp,4                     ; zru¨en¡ n vratov‚ adresy
         call      far ptr ClosMnuA         ; uzav©en¡ v¨ech menu
         call      far ptr InitFFil         ; inicializace vyhled v n¡
         jc        FiltrK25                 ; nen¡ ‘ dn  polo‘ka

; ------ zad n¡ soubor– k filtraci p©i zad n¡ textem

         test      byte ptr ds:[FileTyp],bit3 ; je specifikace textem ?
         jz        FiltrK2                  ; nen¡ specifikace textem

FiltrK12:mov       si,offset SFZMLin        ; menu volby soubor–
         call      far ptr Lin0Menu         ; obsluha volby
         jc        FiltrK25                 ; p©eru¨en¡ operace
         call      far ptr RozborZ          ; rozbor zad n¡ parametr– operace
         jc        FiltrK25                 ; p©eru¨en¡ operace
         jnz       FiltrK12                 ; opakov n¡ zad n¡ parametr–

; ------ doplnˆn¡ cesty na pln‚ jm‚no

         mov       si,offset KonvTxt1       ; text "Konvertuji"
         call      far ptr InfDisp0         ; zobrazen¡ textu
         call      far ptr RozbFPth         ; doplnˆn¡ na pln‚ jm‚no

; ------ zad n¡ hledan‚ho textu

FiltrK2: test      byte ptr ds:[FiltrPar],bit2 ; je n hrada textu ?
         jz        FiltrK24                 ; nen¡ n hrada textu
FiltrK21:mov       si,offset SF1MnLin       ; menu zad n¡ hledan‚ho textu
         call      far ptr Lin0Menu         ; proveden¡ volby
         jc        FiltrK25                 ; p©eru¨en¡ operace
         mov       ch,0
         mov       cl,ds:[LinNum]           ; po‡et znak– textu
         cmp       cl,TextFndX
         jbe       FiltrK22
         mov       cl,TextFndX              ; omezen¡ d‚lky textu
FiltrK22:mov       ds:[TextFndN],cx         ; d‚lka hledan‚ho textu
         mov       si,offset LinBuff        ; buffer textu
         mov       di,offset TextFnd        ; hledan˜ text
         push      ds
         pop       es
         cld
         rep       movsb                    ; £schova textu k hled n¡

; ------ zad n¡ n hradn¡ho textu

         mov       si,offset SF2MnLin       ; menu zad n¡ n hradn¡ho textu
         call      far ptr Lin0Menu         ; proveden¡ volby
         jc        FiltrK21                 ; p©eru¨en¡ operace
         mov       ch,0
         mov       cl,ds:[LinNum]           ; po‡et znak– textu (CH=0, ES=DS)
         cmp       cl,TextSubX
         jbe       FiltrK23
         mov       cl,TextSubX
FiltrK23:mov       ds:[TextSubN],cx         ; d‚lka n hradn¡ho textu
         mov       si,offset LinBuff        ; buffer textu
         mov       di,offset TextSub        ; n hradn¡ text
         cld
         rep       movsb                    ; £schova n hradn¡ho textu

; ------ vytvo©en¡ datov‚ho bufferu

FiltrK24:call      far ptr CreatBuf         ; vytvo©en¡ datov‚ho bufferu
         jnc       FiltrK26
FiltrK25:jmp       AWSMnuMM                 ; ukon‡en¡ operace

; ------ p©¡prava parametr– datov‚ho bufferu

FiltrK26:mov       cx,ds:[BuffSize]         ; velikost datov‚ho bufferu
         xor       ax,ax                    ; za‡ tek ‡tec¡ho bufferu
         test      byte ptr ds:[FiltrPar],bit0+bit1+bit2 ; je t©eba 2 buffery ?
         jz        FiltrK27                 ; nejsou 2 buffery
         shr       cx,1                     ; polovina bufferu
         mov       ax,cx                    ; AX <- za‡ tek ‡tec¡ho bufferu
FiltrK27:mov       ds:[FiltSize],cx         ; velikost jednoho bufferu
         mov       ds:[FiltRead],ax         ; za‡ tek ‡tec¡ho bufferu

; ------ p©¡prava registru konverzn¡ho k¢du

         mov       al,bit0
         mov       cl,ds:[InpKod]           ; vstupn¡ k¢d
         shl       al,cl                    ; p©¡prava vstupn¡ho k¢du
         mov       ah,al                    ; v˜stupn¡ k¢d shodn˜
         mov       cl,ds:[OutKod]           ; v˜stupn¡ k¢d
         cmp       cl,6                     ; v˜stupn¡ k¢d nezmˆnˆn ?
         je        FiltrK29                 ; v˜stupn¡ k¢d nezmˆnˆn
         mov       ah,bit0
         shl       ah,cl                    ; p©¡prava v˜stupn¡ho k¢du
FiltrK29:mov       ds:[IOKod],ax            ; vstupn¡ a v˜stupn¡ k¢d
         and       byte ptr ds:[FiltrPar],not bit7 ; nen¡ konverze bez dotazu

; ------ zobrazen¡ £vodn¡ho textu

         call      far ptr HistADir         ; ulo‘en¡ adres ©e do historie
         mov       si,offset KonvTxt1       ; text "Konvertuji"
         call      far ptr InfDisp0         ; zobrazen¡ textu
         call      far ptr InitFSet         ; inicializace ozna‡en¡ polo‘ek

; ------ nalezen¡ dal¨¡ho souboru ke konverzi

FiltrK3: call      far ptr DispTime         ; obsluha zobrazen¡ ‡asu
         call      far ptr DarkNul          ; nulov n¡ stm¡va‡e obrazovky
         call      far ptr TestBEsc         ; test p©eru¨en¡ operace
         jc        FiltrK25                 ; p©eru¨en¡ operace
         call      far ptr GetFFil          ; poskytnut¡ souboru k operaci
         jc        FiltrK25                 ; nen¡ dal¨¡ soubor
         call      far ptr TestBEsc         ; test p©eru¨en¡ operace
         jc        FiltrK25                 ; p©eru¨en¡ operace

; ------ odzna‡en¡ adres ©e

         call      far ptr DispAAWn         ; zobrazen¡ aktivn¡ho okna
         test      byte ptr ds:[FileFAtr],DIR ; je to adres © ?
         jz        FiltrK31                 ; nen¡ to adres ©
         jmp       FiltrK82                 ; odzna‡en¡ adres ©e

; ------ p©¡prava ukazatel– pro jeden soubor

FiltrK31:mov       al,ds:[TabPozic]         ; po‡et pozic na tabul tor
         mov       ds:[KonvPoz],al          ; zbyl˜ po‡et pozic na tabul tor
         mov       byte ptr ds:[KonvSpc],0  ; nen¡ nep©enesen  mezera
         mov       byte ptr ds:[KonvEqu],0  ; nen¡ shoda ©etˆzce
         mov       word ptr ds:[FiltWrit],0 ; ukl dac¡ adresa do z pis. bufferu
         mov       word ptr ds:[FileIdnt],0 ; identifik tor vstupn¡ho souboru
         mov       word ptr ds:[FileOIdn],0 ; identifik tor v˜stupn¡ho souboru
         mov       byte ptr ds:[FileOPth],0 ; v˜stupn¡ soubor nen¡ vytvo©en

; ------ test, zda m  b˜t potvrzen¡ souboru ke konverzi

         test      byte ptr ds:[FileTyp],bit3 ; je specifikace textem ?
         jz        FiltrK33                 ; nen¡ specifikace textem
         call      KonvZad                  ; potvrzen¡ konverze souboru
         jc        FiltrK3                  ; soubor se nekonvertuje - dal¨¡

; ------ otev©en¡ konvertovan‚ho souboru ES:SI

FiltrK33:mov       di,offset KonvTxt1       ; hl ¨en¡ "Konvertuji"
         call      far ptr InfKFile         ; zobrazen¡ jm‚na souboru
         call      far ptr OpenR            ; otev©en¡ souboru pro ‡ten¡
         jnc       FiltrK35                 ; operace OK

; ------ chyba otev©en¡ vstupn¡ho souboru ES:SI

         call      far ptr OpenRErr         ; chybov‚ hl ¨en¡ - nelze otev©¡t
FiltrK34:jmp       short FiltrK3            ; dal¨¡ soubor

; ------ identifik tor vstupn¡ho souboru

FiltrK35:mov       ds:[FileIdnt],ax         ; identifik tor vstupn¡ho souboru

; ------ p©¡prava jm‚na c¡lov‚ho souboru (ES:SI/CX vstupn¡ soubor, DS=ES)

         cld
         mov       di,offset FileOPth
         inc       cx                       ; v‡etnˆ koncov‚ 0
         rep       movsb                    ; p©enos jm‚na souboru

; ------ vytvo©en¡ v˜stupn¡ho souboru

         mov       si,offset FileOPth       ; buffer k vytvo©en¡ jm‚na souboru
         call      far ptr CreatPF          ; vytvo©en¡ p©echodn‚ho souboru
         jnc       FiltrK37                 ; soubor vytvo©en OK

; ------ uzav©en¡ vstupn¡ho souboru p©i chybˆ

         mov       byte ptr ds:[si],0       ; nen¡ v˜stupn¡ soubor
FiltrK36:call      FiltrCls                 ; uzav©en¡ vstupn¡ho souboru

; ------ chyba vytvo©en¡ v˜stupn¡ho souboru nebo chyba z pisu do souboru

         mov       si,offset FilePath       ; jm‚no konvertovan‚ho souboru
         call      far ptr WritErr          ; hl ¨en¡ - chyba z pisu do souboru
         jmp       short FiltrK34           ; p©eru¨en¡ nebo dal¨¡ soubor

; ------ identifik tor v˜stupn¡ho souboru

FiltrK37:mov       ds:[FileOIdn],ax         ; identifik tor v˜stupn¡ho souboru

; ------ na‡ten¡ bloku dat do bufferu

FiltrK4: call      far ptr DispTime         ; obsluha zobrazen¡ ‡asu
         call      far ptr DarkNul          ; nulov n¡ stm¡va‡e obrazovky
         call      far ptr TestBreak        ; je p©eru¨en¡ operace ?
         jc        FiltrK36                 ; je p©eru¨en¡ operace
         call      far ptr GetBuff          ; poskytnut¡ adresy bufferu
         mov       cx,ds:[FiltSize]         ; velikost bufferu
         mov       di,ds:[FiltRead]         ; za‡ tek ‡tec¡ho bufferu
         mov       ax,ds:[FileIdnt]         ; identifik tor souboru
         call      far ptr ReadFile         ; na‡ten¡ bloku dat
         jnc       FiltrK42                 ; operace OK

; ------ chyba ‡ten¡ ze vstupn¡ho souboru

         call      FiltrCls                 ; uzav©en¡ soubor– p©i chybˆ
         mov       si,offset FilePath       ; (zde je ES=DS)
         call      far ptr ReadErr          ; chyba ‡ten¡ ze souboru
         jmp       short FiltrK34           ; dal¨¡ soubor

; ------ zkonvertov n¡ bloku dat (ES=segment, CX=po‡et bajt–)

FiltrK42:jcxz      FiltrK45                 ; konec souboru
         call      FKonv                    ; zkonvertov n¡ bloku dat
FiltrK43:jc        FiltrK36                 ; chyba z pisu

; ------ je-li 1 buffer, z pis bufferu na v˜stup (je CX=po‡et bajt–, ES=buffer)

         test      byte ptr ds:[FiltrPar],bit0+bit1+bit2 ; jsou 2 buffery ?
         jnz       FiltrK44                 ; jsou 2 buffery
         mov       ds:[FiltWrit],cx         ; po‡et bajt– v z pisov‚m bufferu
         call      FiltrWr                  ; z pis bufferu na disk
         jc        FiltrK43                 ; chyba z pisu

; ------ nov‚ zobrazen¡ informa‡n¡ho kurzoru (CX=po‡et bajt–)

FiltrK44:call      far ptr InfoKurz         ; zobrazen¡ kurzoru
         jmp       short FiltrK4            ; dal¨¡ blok dat

; ------ konec souboru OK - vypr zdnˆn¡ v˜stupn¡ho bufferu (zde je ES=buffer)

FiltrK45:mov       ch,0
         mov       cl,ds:[KonvSpc]          ; zbyl˜ po‡et mezer
         jcxz      FiltrK47                 ; nezbyly ‘ dn‚ mezery
FiltrK46:mov       al," "                   ; znak mezery
         call      FiltrWCh                 ; z pis znaku
         jc        FiltrK43                 ; chyba
         loop      FiltrK46                 ; dal¨¡ mezera

FiltrK47:mov       cl,ds:[KonvEqu]          ; d‚lka shody textu p©i n hradˆ
         jcxz      FiltrK49                 ; nezbyl ‘ dn˜ znak
         mov       bx,offset TextFnd        ; buffer textu
FiltrK48:mov       al,ds:[bx]               ; znak k vysl n¡
         call      FiltrWCh                 ; z pis znaku
         jc        FiltrK43                 ; chyba
         inc       bx                       ; zv˜¨en¡ ukazatele textu
         loop      FiltrK48                 ; dal¨¡ znak

FiltrK49:call      FiltrWr                  ; ulo‘en¡ v˜stupn¡ho bufferu
FiltrK4A:jc        FiltrK43                 ; chyba z pisu

; ------ uzav©en¡ soubor– po proveden¡ operace OK

         mov       ax,ds:[FileIdnt]         ; identifik tor souboru
         call      far ptr ClosFile         ; uzav©en¡ vstupn¡ho souboru
         mov       ds:[FileIdnt],ax

         mov       ax,ds:[FileOIdn]         ; identifik tor v˜stupn¡ho souboru
         test      byte ptr ds:[FiltrPar],bit5 ; zachov v  se datum a ‡as ?
         jz        FiltrK53                 ; datum a ‡as se nezachov v 

         mov       cx,ds:[FileFTim]         ; ‡as souboru
         mov       dx,ds:[FileFDat]         ; datum souboru
         call      far ptr SetDFile         ; nastaven¡ data a ‡asu

FiltrK53:call      far ptr ClosFile         ; uzav©en¡ v˜stupn¡ho souboru
         mov       ds:[FileOIdn],ax

; ------ zru¨en¡ zdrojov‚ho souboru

         push      ds
         pop       es                       ; ES <- datov˜ segment
         mov       si,offset FilePath       ; jm‚no zdrojov‚ho souboru
         call      far ptr DelFile          ; zru¨en¡ zdrojov‚ho souboru

; ------ p©ejmenov n¡ v˜stupn¡ho souboru na vstupn¡ (zde je ES=DS)

         pushf
         call      far ptr ZapKrit          ; zapnut¡ kritick‚ sekce
         mov       si,offset FileOPth       ; ES:SI = jm‚no v˜stupn¡ho souboru
         mov       dx,ds
         mov       di,offset FilePath       ; DX:DI = nov‚ jm‚no souboru
         call      far ptr RenFile          ; p©ejmenov n¡ souboru
         call      far ptr VypKrit          ; vypnut¡ kritick‚ sekce
         popf
         jc        FiltrK4A                 ; chyba z pisu

; ------ operace OK - aktualizace informac¡ o souboru ES:SI

         mov       si,offset FilePath       ; konvertovan˜ soubor
         mov       cx,ds:[FilePthN]         ; d‚lka adres ©e
         call      far ptr AktWFile         ; aktualizace informac¡ o souboru
         call      far ptr DispAAWn         ; zobrazen¡ aktivn¡ho okna
         call      far ptr DispNAWn         ; zobrazen¡ neaktivn¡ho okna
         jmp       short FiltrK8            ; nulov n¡ ozna‡en¡ souboru

; ------ nulov n¡ ozna‡en¡ souboru

FiltrK82:test      byte ptr ds:[FileParm],bit3 ; je to adres © p©i n vratu ?
         jz        FiltrK83                 ; nen¡ to adres © p©i n vratu

FiltrK8: call      far ptr ResFFil          ; nulov n¡ ozna‡en¡ souboru
FiltrK83:call      far ptr DispAll          ; zobrazen¡ oken
         call      far ptr TestBEsc         ; je p©eru¨en¡ operace ?
         jc        FiltrK9                  ; je p©eru¨en¡ operace
         jmp       FiltrK3                  ; dal¨¡ soubor

; ------ ukon‡en¡ operace

FiltrK9: jmp       AWSMnuMM                 ; ukon‡en¡ operace

FiltrK   ENDP

; -----------------------------------------------------------------------------
;        uzav©en¡ soubor– p©i chybˆ operace
; -----------------------------------------------------------------------------

FiltrCls PROC      NEAR

; ------ uzav©en¡ vstupn¡ho souboru

         mov       ax,ds:[FileIdnt]         ; identifik tor vstupn¡ho souboru
         call      far ptr ClosFile         ; uzav©en¡ souboru
         mov       ds:[FileIdnt],ax

; ------ uzav©en¡ v˜stupn¡ho souboru

         mov       ax,ds:[FileOIdn]         ; identifik tor v˜stupn¡ho souboru
         call      far ptr ClosFile         ; uzav©en¡ souboru
         mov       ds:[FileOIdn],ax

; ------ zru¨en¡ v˜stupn¡ho souboru

         push      ds
         pop       es                       ; ES <- datov˜ segment
         mov       si,offset FileOPth       ; jm‚no v˜stupn¡ho souboru
         cmp       byte ptr ds:[si],0       ; je v˜stupn¡ soubor vytvo©en ?
         je        FiltrCl2                 ; nen¡ vytvo©en
         call      far ptr ZapKrit          ; zapnut¡ kritick‚ sekce
         call      far ptr DelFile          ; zru¨en¡ v˜stupn¡ho souboru
         call      far ptr VypKrit          ; vypnut¡ kritick‚ sekce
FiltrCl2:ret

FiltrCls ENDP

; -----------------------------------------------------------------------------
;        potvrzen¡, zda se soubor m  zkonvertovat (CY=ne nebo p©eru¨en¡)
; -----------------------------------------------------------------------------

KonvZad  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      dx
         push      si

; ------ test, zda se konvertuj¡ v¨echny polo‘ky

         test      byte ptr ds:[FiltrPar],bit7 ; konvertuj¡ se v¨echny soubory ?
         jnz       KonvZad9                 ; soubory se konvertuj¡ v¨echny

; ------ dotaz na konverzi souboru

         call      far ptr DekFParm         ; dek¢dov n¡ parametr– souboru
         mov       si,offset SF4MnLin       ; menu pro soubor
         call      far ptr Lin0MenF         ; zad n¡ volby
         jc        KonvZad5                 ; p©eru¨en¡ operace
         cmp       bl,2                     ; konvertuje se polo‘ka ?
         jb        KonvZad8                 ; konvertuje se
         ja        KonvZad6                 ; v¨echny
         stc                                ; p©¡znak p©esko‡en¡ (je Dal¨¡)
         jmp       short KonvZad9           ; p©esko‡en¡ polo‘ky

KonvZad5:call      far ptr SetEsc           ; nastaven¡ p©¡znaku p©eru¨en¡ ESC
         jmp       short KonvZad9           ; p©eru¨en¡ operace

; ------ konvertuj¡ se v¨echny n sleduj¡c¡ soubory

KonvZad6:or        byte ptr ds:[FiltrPar],bit7 ; p©¡znak konverze v¨ech soubor–

; ------ obnoven¡ informa‡n¡ho © dku

KonvZad8:call      far ptr InfoDisp         ; obnoven¡ informa‡n¡ho © dku
         clc                                ; p©¡znak konverze polo‘ky

; ------ n vrat registr–

KonvZad9:pop       si
         pop       dx
         pop       bx
         pop       ax
         ret

KonvZad  ENDP

; -----------------------------------------------------------------------------
;                        konverze jednoho bufferu dat
;             pro m¢d 1 buffer se provede konverze p©¡mo v bufferu
;         pro m¢d 2 buffery se data zkonvertuj¡ do z pisov‚ho bufferu
; -----------------------------------------------------------------------------
; VSTUP: CX=po‡et bajt– dat ke konverzi
;        ES=segment datov‚ho bufferu
;        DS=datov˜ segment
; VSTUP: CY=chyba z pisu
; -----------------------------------------------------------------------------

FKonv    PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di

; ------ p©¡prava registr–

         mov       si,ds:[FiltRead]         ; za‡ tek dat v bufferu
         mov       al,ds:[FiltrPar]         ; parametry filtru
         mov       dx,ds:[IOKod]            ; vstupn¡ a v˜stupn¡ k¢d

; ------ konverze mal˜ch a velk˜ch p¡smen v bufferu

         test      al,bit3                  ; konverze mal˜ch p¡smen na velk  ?
         jz        FKonv1                   ; nen¡ konv. mal˜ch p¡smen na velk 
         call      far ptr KonvUpC          ; konverze mal˜ch p¡smen na velk 
FKonv1:  test      al,bit4                  ; konverze velk˜ch p¡smen na mal  ?
         jz        FKonv2                   ; nen¡ konv. velk˜ch p¡smen na mal 
         call      far ptr KonvDnC          ; konverze velk˜ch p¡smen na mal 

; ------ konverze n rodn¡ch font–

FKonv2:  call      far ptr KonvFnt          ; konverze n rodn¡ch font–

; ------ konverze tabul tor– na mezery

         test      al,bit0                  ; konverze tabul tor– na mezery ?
         jz        FKonv3
         call      FiltM                    ; konverze tabul tor– na mezery
         jmp       short FKonv9

; ------ konverze mezer na tabul tory

FKonv3:  test      al,bit1                  ; konverze mezer na tabul tory ?
         jz        FKonv4
         call      FiltT                    ; konverze mezer na tabul tory
         jmp       short FKonv9

; ------ n hrada text–

FKonv4:  test      al,bit2                  ; n hrada textu ?
         jz        FKonv9
         call      FiltF                    ; n hrada textu

; ------ n vrat registr–

FKonv9:  pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

FKonv    ENDP

; -----------------------------------------------------------------------------
;             konverze tabul tor– na mezery (jeden datov˜ blok)
; -----------------------------------------------------------------------------
; VSTUP: ES=segment datov‚ho bufferu
;        DS=datov˜ segment
;        SI=adresa dat v bufferu
;        CX=po‡et bajt– ke konverzi
; VSTUP:CY=chyba z pisu na disk
; -----------------------------------------------------------------------------

FiltM    PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      si

; ------ p©¡prava registr– k dek¢dov n¡

         mov       bl,ds:[TabPozic]         ; po‡et pozic na tabul tor
         mov       bh,ds:[KonvPoz]          ; po‡et zbyl˜ch pozic tabul toru

; ------ ‡ten¡ jednoho znaku ze vstupn¡ho bufferu

FiltM1:  clc                                ; p©¡znak operace OK
         jcxz      FiltM9                   ; nejsou dal¨¡ data
         mov       al,es:[si]               ; znak z bufferu
         inc       si                       ; zv˜¨en¡ adresy v bufferu
         dec       cx                       ; sn¡‘en¡ po‡tu bajt–

; ------ n hrada tabul toru mezerami

         cmp       al,TAB                   ; je tabul tor ?
         jne       FiltM3                   ; nen¡ tabul tor
         mov       al," "                   ; n hradn¡ znak mezery
FiltM2:  call      FiltrWCh                 ; z pis znaku
         jc        FiltM9                   ; chyba z pisu
         dec       bh                       ; ‡¡ta‡ zbyl˜ch pozic
         jnz       FiltM2                   ; z pis dal¨¡ho znaku
         mov       bh,bl                    ; nov˜ po‡et zbyl˜ch znak–
         jmp       short FiltM1             ; dal¨¡ znak

; ------ za‡ tek © dku

FiltM3:  cmp       al,CR
         je        FiltM4                   ; je nov˜ © dku
         cmp       al,LF
         je        FiltM4                   ; je nov˜ © dek

; ------ ostatn¡ znaky

         dec       bh                       ; ‡¡ta‡ zbyl˜ch pozic
         jnz       FiltM5                   ; nen¡ tabula‡n¡ pozice

FiltM4:  mov       bh,bl                    ; nov˜ po‡et zbyl˜ch znak–
FiltM5:  call      FiltrWCh                 ; z pis znaku na v˜stup
         jnc       FiltM1                   ; dal¨¡ znak

; ------ n vrat registr–

FiltM9:  mov       ds:[KonvPoz],bh          ; £schova po‡tu zbyl˜ch pozic
         pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

FiltM   ENDP

; -----------------------------------------------------------------------------
;              konverze mezer na tabul tory (jeden datov˜ blok)
; -----------------------------------------------------------------------------
; VSTUP: ES=segment okna
;        DS=datov˜ segment
;        SI=adresa dat v bufferu
;        CX=po‡et bajt– ke konverzi
; VSTUP:CY=chyba z pisu na disk
; -----------------------------------------------------------------------------

FiltT    PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      si

; ------ p©¡prava registr– k dek¢dov n¡

         mov       bl,ds:[TabPozic]         ; po‡et pozic na tabul tor
         mov       bh,ds:[KonvPoz]          ; po‡et zbyl˜ch pozic tabul toru
         mov       ah,ds:[KonvSpc]          ; ‡¡ta‡ nep©enesen˜ch mezer

; ------ ‡ten¡ jednoho znaku ze vstupn¡ho bufferu

FiltT1:  clc                                ; p©¡znak operace OK
         jcxz      FiltT9                   ; nejsou dal¨¡ data
         mov       al,es:[si]               ; znak z bufferu
         inc       si                       ; zv˜¨en¡ adresy v bufferu
         dec       cx                       ; sn¡‘en¡ po‡tu bajt–

; ------ znak tabul toru - mezery se mohou zru¨it

         cmp       al,TAB                   ; je tabul tor ?
         jne       FiltT5                   ; nen¡ tabul tor
FiltT2:  mov       ah,0                     ; nen¡ ‘ dn  mezera
FiltT3:  mov       bh,bl                    ; zbyl˜ po‡et pozic = pln˜ tabul tor
FiltT4:  call      FiltrWCh                 ; z pis znaku AL na v˜stup
         jc        FiltT9                   ; chyba z pisu
         jmp       short FiltT1             ; dal¨¡ znak

; ------ znak mezery - zv˜¨en¡ ‡¡ta‡e mezer

FiltT5:  cmp       al," "                   ; je mezera ?
         jne       FiltT6                   ; nen¡ mezera
         inc       ah                       ; zv˜¨en¡ ‡¡ta‡e mezer
         dec       bh                       ; ‡¡ta‡ zbyl˜ch pozic tabul toru
         jnz       FiltT1                   ; nen¡ je¨tˆ tabula‡n¡ pozice
         cmp       ah,1                     ; je pouze 1 mezera ?
         je        FiltT2                   ; 1 mezera z–stane mezerou
         mov       al,TAB                   ; znak tabul toru
         jmp       short FiltT2             ; jinak se nahrad¡ tabul torem

; ------ jin‚ znaky - vypr zdnˆn¡ bufferu mezer

FiltT6:  or        ah,ah                    ; je nˆjak  mezera ?
         jz        FiltT8                   ; nen¡ ‘ dn  mezera
FiltT7:  push      ax
         mov       al," "                   ; znak mezery
         call      FiltrWCh                 ; z pis znaku mezery
         pop       ax
         jc        FiltT9                   ; chyba z pisu
         dec       ah                       ; ‡¡ta‡ mezer
         jnz       FiltT7                   ; z pis dal¨¡ mezery

; ------ za‡ tek © dku (CR nebo LF)

FiltT8:  cmp       al,CR
         je        FiltT3                   ; nov˜ © dek
         cmp       al,LF
         je        FiltT3                   ; nov˜ © dek

; ------ jin˜ znak - ‡¡t n¡ tabula‡n¡ pozice

         dec       bh                       ; sn¡‘en¡ ‡¡ta‡e pozic
         jz        FiltT3                   ; tabula‡n¡ pozice
         jmp       short FiltT4

; ------ n vrat registr–

FiltT9:  mov       ds:[KonvPoz],bh          ; £schova po‡tu zbyl˜ch pozic
         mov       ds:[KonvSpc],ah          ; ‡¡ta‡ nep©enesen˜ch mezer
         pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

FiltT   ENDP

; -----------------------------------------------------------------------------
;                   n hrada textu (jeden vstupn¡ datov˜ blok)
; -----------------------------------------------------------------------------
; VSTUP: ES=segment datov‚ho bufferu
;        DS=datov˜ segment
;        SI=‡tec¡ adresa dat v bufferu
;        CX=po‡et vstupn¡ch bajt– ke konverzi
; VSTUP:CY=chyba z pisu na disk
; -----------------------------------------------------------------------------

FiltF    PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp

; ------ p©¡prava registr– k dek¢dov n¡

         mov       dx,ds                    ; DX <- datov˜ segment
         mov       bp,es                    ; BP <- segment bufferu
         mov       ah,ds:[KonvEqu]          ; d‚lka shody textu

; ------ ‡ten¡ jednoho znaku ze vstupn¡ho bufferu

FiltF1:  clc                                ; p©¡znak operace OK
         jcxz      FiltF9                   ; nejsou dal¨¡ data
         mov       al,es:[si]               ; znak z bufferu
         inc       si                       ; zv˜¨en¡ adresy v bufferu
         dec       cx                       ; sn¡‘en¡ po‡tu bajt–

; ------ porovn n¡, zda odpov¡d  znak hledan‚mu textu

FiltF2:  mov       bh,0
         mov       bl,ah                    ; BX <- sou‡asn  d‚lka shody
         cmp       al,ds:[bx+TextFnd]       ; odpov¡d  znak hledan‚mu textu ?
         jne       FiltF4                   ; znak neodpov¡d 
         cmp       byte ptr ds:[TextFndN],0 ; je nˆjak˜ text ?
         je        FiltF4                   ; nen¡ hledan˜ text
         inc       ah                       ; zv˜¨en¡ ‡¡ta‡e d‚lky shody textu

; ------ pokud je hledan˜ text ji‘ cel˜, n hrada textu

         cmp       ah,byte ptr ds:[TextFndN] ; je ji‘ cel˜ text ?
         jb        FiltF1                   ; text je¨tˆ nen¡ cel˜ - dal¨¡ znak
         mov       bx,offset TextSub        ; ukazatel n hradn¡ho textu
         mov       ah,byte ptr ds:[TextSubN] ; d‚lka n hradn¡ho textu
         or        ah,ah                    ; je nˆjak˜ text ?
         jz        FiltF1                   ; nen¡ ‘ dn˜ text
FiltF3:  mov       al,ds:[bx]               ; n hradn¡ znak k vysl n¡
         call      FiltrWCh                 ; z pis znaku
         jc        FiltF9                   ; chyba v˜stupu
         inc       bx                       ; zv˜¨en¡ ukazatele textu
         dec       ah                       ; sn¡‘en¡ ‡¡ta‡e znak–
         jnz       FiltF3                   ; dal¨¡ znak
         jmp       short FiltF1             ; vstup dal¨¡ho znaku

; ------ nen¡ shoda - bude vypr zdnˆn¡ bufferu shody

FiltF4:  cmp       ah,0                     ; je nˆco v bufferu shody ?
         je        FiltF8                   ; nen¡ nic v bufferu shody

; ------ vysl n¡ jednoho znaku z bufferu shody

         mov       bx,offset TextFnd        ; ukazatel v bufferu textu
FiltF5:  push      ax
         mov       al,ds:[bx]               ; bajt z bufferu
         call      FiltrWCh                 ; z pis znaku na v˜stup
         pop       ax
         jc        FiltF9                   ; chyba z pisu
         inc       bx                       ; zv˜¨en¡ ukazatele v bufferu
         dec       ah                       ; sn¡‘en¡ ‡¡ta‡e shody
         jz        FiltF7                   ; jsou ji‘ v¨echna data z bufferu

; ------ porovn n¡, zda je zbytek textu ‡ st¡ hledan‚ho textu

         push      si
         push      cx
         mov       es,dx                    ; ES <- datov˜ segment

         mov       si,bx                    ; adresa zbytku textu
         mov       di,offset TextFnd        ; za‡ tek textu
         mov       cl,ah                    ; d‚lka zbytku textu
         mov       ch,0
         cld
         repe      cmpsb                    ; porovn n¡ text–

         mov       es,bp                    ; ES <- segment bufferu
         pop       cx
         pop       si
         je        FiltF2                   ; text se shoduje - konec
         jmp       short FiltF5             ; vysl n¡ dal¨¡ho znaku

; ------ buffer vypr zdnˆn - test, zda se shoduje posledn¡ znak

FiltF7:  cmp       al,ds:[TextFnd]          ; shoduje se prvn¡ znak ?
         jne       FiltF8                   ; znak se neshoduje
         inc       ah                       ; zv˜¨en¡ ‡¡ta‡e shody
         jmp       short FiltF1             ; dal¨¡ znak

; ------ znak se neshoduje - vysl n¡ na v˜stup

FiltF8:  call      FiltrWCh                 ; z pis znaku na v˜stup
         jnc       FiltF1                   ; dal¨¡ znak

; ------ n vrat registr–

FiltF9:  mov       ds:[KonvEqu],ah          ; nov  d‚lka shody
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

FiltF   ENDP

; -----------------------------------------------------------------------------
;                                 FiltrWCh
;                   ulo‘en¡ znaku do v˜stupn¡ho bufferu
; -----------------------------------------------------------------------------
; VSTUP: AL=znak k ulo‘en¡
;        ES=segment datov‚ho bufferu
;        DS=datov˜ segment
; VSTUP:CY=chyba z pisu na disk
; -----------------------------------------------------------------------------

FiltrWCh PROC      NEAR

; ------ £schova registr–

         push      di

; ------ kontrola, zda je buffer ji‘ pln˜

         mov       di,ds:[FiltWrit]         ; ukl dac¡ adresa do bufferu
         cmp       di,ds:[FiltSize]         ; je buffer ji‘ pln˜ ?
         jb        FiltrWC1                 ; buffer je¨tˆ nen¡ pln˜

; ------ vypr zdnˆn¡ z pisov‚ho bufferu

         call      FiltrWr                  ; vypr zdnˆn¡ bufferu
         jc        FiltrWC2                 ; chyba z pisu na disk
         xor       di,di                    ; nov  ukl dac¡ adresa do bufferu

; ------ ulo‘en¡ znaku do bufferu

FiltrWC1:cld
         stosb                              ; ulo‘en¡ znaku do bufferu
         mov       ds:[FiltWrit],di         ; nov  ukl dac¡ adresa do bufferu
         clc                                ; p©¡znak operace OK

; ------ n vrat registr–

FiltrWC2:pop       di
         ret

FiltrWCh ENDP

; -----------------------------------------------------------------------------
;                                 FiltrWr
;                 z pis v˜stupn¡ho bufferu do souboru
; -----------------------------------------------------------------------------
; VSTUP: ES=segment datov‚ho bufferu
;        DS=datov˜ segment
; VSTUP:CY=chyba operace
; -----------------------------------------------------------------------------

FiltrWr  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      si

; ------ z pis dat na disk

         xor       si,si                    ; za‡ tek dat k z pisu
         xor       cx,cx                    ; CX <- 0
         xchg      cx,ds:[FiltWrit]         ; po‡et bajt– v z pisov‚m bufferu
         jcxz      FiltrWr2                 ; nejsou ‘ dn  data (zde je NC)
         mov       ax,ds:[FileOIdn]         ; identifik tor v˜stupn¡ho souboru
         call      far ptr WritFile         ; z pis dat do souboru

; ------ n vrat registr–

FiltrWr2:pop       si
         pop       cx
         pop       ax
         ret

FiltrWr  ENDP

; *****************************************************************************
;
;                          Tisk soubor–
;
; *****************************************************************************
;þ
AWMMnuST PROC      FAR

         call      AWMSTIni                 ; nastaven¡ p©ep¡na‡–

         mov       ax,word ptr ds:[SMnuVert+MnuPoz] ; pozice p©edchoz¡ho okna
         add       ax,207h                  ; posun okna
         mov       word ptr ds:[si+MnuPoz],ax        ; pozice okna

         jmp       far ptr VertMenu

AWMMnuST ENDP

; -----------------------------------------------------------------------------
;        p©¡prava p©ep¡na‡– volby tisku
; -----------------------------------------------------------------------------

AWMSTIni PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ p©ep¡na‡e menu tisku

         mov       dl,ds:[TiskParm]         ; parametry tisku
         mov       dh,0
         mov       si,offset STMnVert
         call      far ptr SetSwch          ; nastaven¡ p©ep¡na‡–

; ------ p©ep¡na‡e podmenu volby za©¡zen¡

         mov       dx,ds:[TiskOut]          ; v˜stupn¡ za©¡zen¡
         mov       si,offset STTMVert
         call      far ptr SetSwch          ; nastaven¡ p©ep¡na‡–

; ------ text jm‚na za©¡zen¡

         mov       si,offset TiskZTxt-4
AWMSTIn2:add       si,4
         shr       dx,1
         jnc       AWMSTIn2
         mov       di,offset STMnVPl1-6
         mov       cx,4
         cld
         push      ds
         pop       es
         rep       movsb

; ------ dek¢dov n¡ po‡tu p©esko‡en˜ch str nek

         mov       di,offset STMnVPl2-4
         mov       ax,ds:[TiskPres]         ; po‡et p©esko‡en˜ch str nek
         call      AWMSTIn0

; ------ dek¢dov n¡ ‡¡sla po‡ tku str nkov n¡

         mov       di,offset STMnVPl3-4
         mov       ax,ds:[TiskPoc]          ; ‡¡slo po‡ te‡n¡ str nky
         call      AWMSTIn0

; ------ dek¢dov n¡ d‚lky str nky

         mov       di,offset STMnVPl4-4
         mov       ax,ds:[TiskDelk]         ; d‚lka str nky
         call      AWMSTIn0

; ------ dek¢dov n¡ lev‚ho okraje

         mov       di,offset STMnVPl5-4
         mov       ax,ds:[TiskLeft]         ; lev˜ okraj
         call      AWMSTIn0

; ------ dek¢dov n¡ prav‚ho okraje

         mov       di,offset STMnVPl6-4
         mov       ax,ds:[TiskRght]         ; prav˜ okraj
         call      AWMSTIn0

; ------ z kaz polo‘ek "kurzor" a "ozna‡en‚" p©i vypnut‚m aktivn¡m oknˆ

         and       word ptr ds:[STMnVBlk+8],not (bit1+HI*bit1) ; polo‘ky povoleny
         call      far ptr TestAAWn         ; je aktivn¡ okno zapnuto ?
         jnc       AWMSTIn6                 ; okno je zapnuto
         or        word ptr ds:[STMnVBlk+8],bit1+HI*bit1 ; z kaz polo‘ek

; ------ n vrat registr–

AWMSTIn6:pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

AWMSTIni ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ jednoho ‡¡sla AX -> ES:DI
; -----------------------------------------------------------------------------

AWMSTIn0 PROC      NEAR

         push      ax
         mov       al," "
         mov       cl,4
         rep       stosb                    ; vymaz n¡ polo‘ky
         pop       ax
         xor       dx,dx
         xor       bx,bx                    ; nen¡ barva ani oddˆlova‡
         call      far ptr DekNumD          ; dek¢dov n¡ ‡¡sla po‡ te‡n¡ str nky
         ret

AWMSTIn0 ENDP

; -----------------------------------------------------------------------------
;        volba v˜stupn¡ho tiskov‚ho za©¡zen¡
; -----------------------------------------------------------------------------

AWMMnSTT PROC      FAR

         mov       ax,word ptr ds:[STMnVert+MnuPoz] ; pozice p©edchoz¡ho okna
         add       ax,207h                  ; posun okna
         mov       word ptr ds:[si+MnuPoz],ax        ; pozice okna

         call      AWMSTIni                 ; nastaven¡ p©ep¡na‡–

         jmp       far ptr VertMenu

AWMMSTT2:mov       cl,byte ptr ds:[si+MnuAkt] ; aktivn¡ polo‘ka
         dec       cx
         mov       ax,bit0
         shl       ax,cl
         mov       ds:[TiskOut],ax          ; zvolen‚ v˜stupn¡ za©¡zen¡

         call      AWMSTIni                 ; nastaven¡ p©ep¡na‡–
         call      far ptr DispAll          ; nov‚ zobrazen¡ menu

         cmp       bl," "                   ; je jen p©epnut¡ mezerou ?
         je        AWMMSTT4                 ; nen¡ ukon‡en¡

         add       sp,4                     ; zru¨en¡ n vratov‚ adresy z menu
         push      word ptr ds:[si+MnuBreak+2] ; n vratov  adresa z menu - segm.
         push      word ptr ds:[si+MnuBreak] ; n vratov  adresa z menu - offset
         call      far ptr ClosMnu          ; uzav©en¡ tohoto menu

AWMMSTT4:ret

AWMMnSTT ENDP

; -----------------------------------------------------------------------------
;        zad n¡ po‡tu p©esko‡en˜ch str nek
; -----------------------------------------------------------------------------

AWMMnSTN PROC      FAR

         push      ds
         pop       es                       ; ES <- datov˜ segment
         mov       bx,9999                  ; maxim ln¡ hodnota ‡¡sla
         mov       ch,0                     ; minim ln¡ hodnota ‡¡sla
         mov       cl,4                     ; d‚lka textu
         mov       dx,word ptr ds:[si+MnuPoz] ; po‡ te‡n¡ pozice menu
         add       dx,3*HI + 15             ; pozice relativnˆ
         mov       di,offset STMnVPl2-4     ; buffer k dek¢dov n¡
         push      si
         mov       si,offset STMnVHl1       ; text n povˆdy
         call      far ptr MenuNum          ; zad n¡ po‡ te‡n¡ str nky
         pop       si
         mov       ds:[TiskPres],ax         ; nov˜ po‡et p©esko‡en˜ch str nek
         jmp       short AWMMSTL4

AWMMnSTN ENDP

; -----------------------------------------------------------------------------
;        zad n¡ ‡¡sla po‡ te‡n¡ str nky
; -----------------------------------------------------------------------------

AWMMnSTS PROC      FAR

         push      ds
         pop       es                       ; ES <- datov˜ segment
         mov       bx,9999                  ; maxim ln¡ hodnota ‡¡sla
         mov       ch,1                     ; minim ln¡ hodnota ‡¡sla
         mov       cl,4                     ; d‚lka textu
         mov       dx,word ptr ds:[si+MnuPoz] ; po‡ te‡n¡ pozice menu
         add       dx,4*HI + 15             ; pozice relativnˆ
         mov       di,offset STMnVPl3-4     ; buffer k dek¢dov n¡
         push      si
         mov       si,offset STMnVHl2       ; text n povˆdy
         call      far ptr MenuNum          ; zad n¡ po‡ te‡n¡ str nky
         pop       si
         mov       ds:[TiskPoc],ax          ; nov‚ ‡¡slo po‡ te‡n¡ str nky
         jmp       short AWMMSTL4

AWMMnSTS ENDP

; -----------------------------------------------------------------------------
;        zad n¡ d‚lky str nky
; -----------------------------------------------------------------------------

AWMMnSTD PROC      FAR

         push      ds
         pop       es                       ; ES <- datov˜ segment
         mov       bx,999                   ; maxim ln¡ hodnota ‡¡sla
         mov       ch,0                     ; minim ln¡ hodnota ‡¡sla
         mov       cl,3                     ; d‚lka textu
         mov       dx,word ptr ds:[si+MnuPoz] ; po‡ te‡n¡ pozice menu
         add       dx,5*HI + 16             ; pozice relativnˆ
         mov       di,offset STMnVPl4-3     ; buffer k dek¢dov n¡
         push      si
         mov       si,offset STMnVHl3       ; text n povˆdy
         call      far ptr MenuNum          ; zad n¡ d‚lky str nky
         pop       si
         mov       ds:[TiskDelk],ax         ; nov  d‚lka str nky
         jmp       short AWMMSTL4

AWMMnSTD ENDP

; -----------------------------------------------------------------------------
;        zad n¡ lev‚ho okraje
; -----------------------------------------------------------------------------

AWMMnSTL PROC      FAR

         push      ds
         pop       es                       ; ES <- datov˜ segment
         mov       bx,999                   ; maxim ln¡ hodnota ‡¡sla
         mov       ch,1                     ; minim ln¡ hodnota ‡¡sla
         mov       cl,3                     ; d‚lka textu
         mov       dx,word ptr ds:[si+MnuPoz] ; po‡ te‡n¡ pozice menu
         add       dx,6*HI + 16             ; pozice relativnˆ
         mov       di,offset STMnVPl5-3     ; buffer k dek¢dov n¡
         push      si
         mov       si,offset STMnVHl4       ; text n povˆdy
         call      far ptr MenuNum          ; zad n¡ lev‚ho okraje
         pop       si
         mov       ds:[TiskLeft],ax         ; nov˜ lev˜ okraj
AWMMSTL4:call      AWMSTIni                 ; inicializace p©ep¡na‡– menu
         call      far ptr DispMnu          ; nov‚ zobrazen¡ menu
         ret

AWMMnSTL ENDP

; -----------------------------------------------------------------------------
;        zad n¡ prav‚ho okraje
; -----------------------------------------------------------------------------

AWMMnSTR PROC      FAR

         push      ds
         pop       es                       ; ES <- datov˜ segment
         mov       bx,999                   ; maxim ln¡ hodnota ‡¡sla
         mov       ch,0                     ; minim ln¡ hodnota ‡¡sla
         mov       cl,3                     ; d‚lka textu
         mov       dx,word ptr ds:[si+MnuPoz] ; po‡ te‡n¡ pozice menu
         add       dx,7*HI + 16             ; pozice relativnˆ
         mov       di,offset STMnVPl6-3     ; buffer k dek¢dov n¡
         push      si
         mov       si,offset STMnVHl5       ; text n povˆdy
         call      far ptr MenuNum          ; zad n¡ prav‚ho okraje
         pop       si
         mov       ds:[TiskRght],ax         ; nov˜ prav˜ okraj
         jmp       short AWMMSTL4

AWMMnSTR ENDP

; -----------------------------------------------------------------------------
;        zmˆna p©¡znaku tisku z hlav¡
; -----------------------------------------------------------------------------

AWMMnSTH PROC      FAR

         xor       byte ptr ds:[TiskParm],bit0
         jmp       short AWMMSTL4

AWMMnSTH ENDP

; -----------------------------------------------------------------------------
;        zmˆna p©¡znaku v˜mˆny pap¡ru
; -----------------------------------------------------------------------------

AWMMnSTJ PROC      FAR

         xor       byte ptr ds:[TiskParm],bit1
         jmp       short AWMMSTL4

AWMMnSTJ ENDP

; -----------------------------------------------------------------------------
;        zah jen¡ operace tisku souboru
; -----------------------------------------------------------------------------
;þ
AWMMSTKT db        bit0 + bit4 + bit6 + bit7 ; kurzor
         db        bit1 + bit4 + bit6 + bit7 ; ozna‡en‚
         db        bit3 + bit4 + bit6       ; zadan‚

TiskSoub PROC      FAR

; ------ inicializace vyhled v n¡ soubor–

         add       sp,4                     ; zru¨en¡ n vratov‚ adresy
         mov       bx,ds:[si+MnuAkt]        ; aktivn¡ zvolen  polo‘ka
         mov       al,cs:[bx+AWMMSTKT-9]    ; parametry pro v˜bˆr polo‘ek
         call      far ptr ClosMnuA         ; uzav©en¡ v¨ech oken menu
         call      far ptr InitFFil         ; inicializace vyhled v n¡
         jc        TiskSb06                 ; nen¡ ‘ dn  polo‘ka

; ------ zad n¡ specifikace soubor– p©i zad n¡ textem

         test      byte ptr ds:[FileTyp],bit3 ; je specifikace textem ?
         jz        TiskSb05                 ; nen¡ specifikace textem

TiskSb01:mov       si,offset STTZMLin       ; menu zad n¡ soubor–
         call      far ptr Lin0Menu         ; obsluha volby
         jc        TiskSb06                 ; p©eru¨en¡ volby
         call      far ptr RozborZ          ; rozbor zad n¡ parametr– operace
         jc        TiskSb06                 ; p©eru¨en¡ volby
         jnz       TiskSb01                 ; opakov n¡ zad n¡ parametr–

; ------ doplnˆn¡ cesty na pln‚ jm‚no

         mov       si,offset TiskTxt        ; text "Tisknu"
         call      far ptr InfDisp0         ; zobrazen¡ textu
         call      far ptr RozbFPth         ; doplnˆn¡ na pln‚ jm‚no

; ------ vytvo©en¡ datov‚ho bufferu

TiskSb05:call      far ptr CreatBuf         ; vytvo©en¡ pracovn¡ho bufferu
         jnc       TiskSb07                 ; pamˆŸ je OK
TiskSb06:jmp       AWSMnuMM                 ; konec

; ------ inicializa‡n¡ zobrazen¡ hl ¨en¡

TiskSb07:call      far ptr HistADir         ; ulo‘en¡ adres ©e do historie
         mov       si,offset TiskTxt        ; text "Tisknu"
         call      far ptr InfDisp0         ; zobrazen¡ textu
         call      far ptr InitFSet         ; inicializace ozna‡en¡ polo‘ek

; ------ p©¡prava jm‚na v˜stupn¡ho souboru

         mov       si,offset TiskSouT       ; soubor "$DOSMAN$.PRN"
         push      ds
         pop       es                       ; ES <- datov˜ segment
         mov       di,offset FileOPth       ; buffer jm‚na v˜stupn¡ho souboru
         call      far ptr TempFile         ; sestaven¡ jm‚na souboru

; ------ poskytnut¡ dal¨¡ho souboru k tisku -> ES:SI

TiskSb1: call      far ptr DispTime         ; pr–bˆ‘n  obsluha ‡asu
         call      far ptr DarkNul          ; nulov n¡ stm¡va‡e obrazovky
         call      far ptr GetFFil          ; poskytnut¡ dal¨¡ho souboru
         jc        TiskSb10                 ; nen¡ dal¨¡ soubor - konec
         call      far ptr TestBEsc         ; je p©eru¨en¡ operace ?
         jnc       TiskSb11                 ; nen¡ p©eru¨en¡ operace
TiskSb10:jmp       TiskSb9                  ; ukon‡en¡ operace tisku

; ------ test, zda to je adres ©

TiskSb11:call      far ptr DispAAWn         ; zobrazen¡ aktivn¡ho okna
         test      byte ptr ds:[FileFAtr],DIR ; je to adres © ?
         jz        TiskSb12                 ; nen¡ to adres ©
         jmp       TiskSb62                 ; je to adres ©
TiskSb12:call      far ptr DekFParm         ; p©¡prava parametr– souboru

; ------ zobrazen¡ hl ¨en¡ o tisku souboru

         mov       di,offset TiskTxt        ; text "Tisknu"
         call      far ptr InfKFile         ; zobrazen¡ jm‚na souboru

; ------ otev©en¡ souboru ES:SI pro ‡ten¡

         call      far ptr OpenR            ; otev©en¡ souboru pro ‡ten¡
         jnc       TiskSb24                 ; soubor otev©en OK
         call      far ptr OpenRErr         ; chybov‚ hl ¨en¡ - nelze otev©¡t
         jc        TiskSb10                 ; p©eru¨en¡ operace
         jmp       TiskSb7                  ; dal¨¡ soubor

; ------ inicializace ukazatel– pro tisk jednoho souboru

TiskSb24:mov       ds:[FileIdnt],ax         ; identifik tor souboru
         mov       word ptr ds:[TiskAPoz],1 ; aktu ln¡ ‡¡slo pozice
         mov       byte ptr ds:[TiskOld],0  ; zru¨en¡ uschovan‚ho znaku
         mov       word ptr ds:[TiskARad],1 ; aktu ln¡ ‡¡slo © dku
         mov       ax,ds:[TiskPoc]          ; po‡ te‡n¡ ‡¡slo str nky
         mov       ds:[TiskAStr],ax         ; aktu ln¡ str nka

; ------ v˜zva k vlo‘en¡ prvn¡ho listu

         cmp       word ptr ds:[TiskPres],0 ; p©eskakuj¡ se nˆjak‚ str nky ?
         jne       TiskSb3                  ; p©eskakuj¡ se nˆjak‚ str nky
         call      TiskNext                 ; v˜zva k vlo‘en¡ nov‚ str nky
         jc        TiskSb5                  ; p©eru¨en¡ tisku

; ------ obsluha zobrazen¡ ‡asu

TiskSb3: call      far ptr DispTime         ; obsluha zobrazen¡ ‡asu
         call      far ptr DarkNul          ; nulov n¡ stm¡va‡e obrazovky

; ------ na‡ten¡ bloku dat k tisku

         call      far ptr GetBuff          ; poskytnut¡ adresy bufferu -> ES
         mov       cx,ds:[BuffSize]         ; velikost bufferu
         xor       di,di                    ; za‡ tek bufferu
         cmp       cx,400h                  ; asi tak velikost jednoho bloku
         jbe       TiskSb34
         mov       cx,400h                  ; omezen¡ velikosti dat
TiskSb34:mov       ax,ds:[FileIdnt]         ; identifik tor souboru
         call      far ptr ReadFile         ; ‡ten¡ bloku dat
         jc        TiskSb36                 ; chyba ‡ten¡
         jcxz      TiskSb4                  ; konec souboru

; ------ vyti¨tˆn¡ obsahu bufferu

         xor       si,si                    ; za‡ tek bufferu
         call      TiskBuff                 ; vyti¨tˆn¡ obsahu bufferu
         jc        TiskSb5                  ; chyba nebo p©eru¨en¡ operace

; ------ zobrazen¡ kurzoru proveden‚ operace

         call      far ptr InfoKurz         ; zobrazen¡ kurzoru
         jmp       short TiskSb3            ; dal¨¡ blok dat

; ------ chyba ‡ten¡ ze souboru

TiskSb36:mov       ax,ds:[FileIdnt]         ; identifik tor souboru
         call      far ptr ClosFile         ; uzav©en¡ souboru
         mov       ds:[FileIdnt],ax
         push      ds
         pop       es
         mov       si,offset FilePath
         call      far ptr ReadErr          ; chyba ‡ten¡ ze souboru
         jc        TiskSb9                  ; p©eru¨en¡ operace
         jmp       short TiskSb7

; ------ konec souboru - vyti¨tˆn¡ zbytku bufferu a znaku FF

TiskSb4: call      TiskOpen                 ; otev©en¡ za©¡zen¡
         jc        TiskSb5                  ; chyba za©¡zen¡
         cmp       byte ptr ds:[TiskOld],0  ; je uschovan˜ znak CR nebo LF ?
         je        TiskSb42                 ; nen¡
         call      TiskCR                   ; tisk CR/LF
         jc        TiskSb48
TiskSb42:cmp       word ptr ds:[TiskAPoz],1 ; zbyl neukon‡en˜ © dek ?
         je        TiskSb44                 ; nezbyl neukon‡en˜ © dek
         call      TiskCR                   ; ukon‡en¡ © dku
         jc        TiskSb48
TiskSb44:cmp       word ptr ds:[TiskARad],1 ; zbyla neukon‡en  str nka ?
         je        TiskSb48                 ; nen¡ neukon‡en  str nka
         mov       al,FF
         call      Tisk0Chr                 ; ukon‡en¡ str nky
TiskSb48:call      TiskClos                 ; uzav©en¡ za©¡zen¡

; ------ ukon‡en¡ tisku jednoho souboru

TiskSb5: pushf
         mov       ax,ds:[FileIdnt]         ; identifik tor souboru
         call      far ptr ClosFile
         mov       ds:[FileIdnt],ax
         popf
         jnc       TiskSb6                  ; operace probˆhla OK
         call      far ptr TestBEsc         ; test p©eru¨en¡ operace
         jc        TiskSb9                  ; chyba nebo p©eru¨en¡

; ------ hl ¨en¡ - chyba v˜stupu

         mov       si,offset ChbErTO        ; text - chyba v˜stupu
         call      far ptr Lin0MenF         ; chybov‚ hl ¨en¡
         jc        TiskSb9                  ; p©eru¨en¡ operace
         jmp       short TiskSb7            ; dal¨¡ soubor

; ------ odna‡en¡ polo‘ky po £spˆ¨n‚ operaci

TiskSb62:test      byte ptr ds:[FileParm],bit3 ; je to adres © p©i n vratu ?
         jz        TiskSb7                  ; nen¡ to adres © p©i n vratu
TiskSb6: call      far ptr ResFFil          ; nulov n¡ ozna‡en¡ polo‘ky
TiskSb7: call      far ptr DispAAWn         ; nov‚ zobrazen¡ okna

; ------ test p©eru¨en¡ operace

         call      far ptr TestBEsc         ; test p©eru¨en¡ operace
         jc        TiskSb9                  ; p©eru¨en¡ operace
         jmp       TiskSb1                  ; dal¨¡ soubor

; ------ ukon‡en¡ operace tisku

TiskSb9: test      byte ptr ds:[TiskOut+1],bit8/bit8 ; byl v˜stup do souboru ?
         jz        TiskSb92                 ; nebyl v˜stup do souboru
         push      ds
         pop       es
         mov       si,offset FileOPth       ; jm‚no v˜stupn¡ho souboru
         call      far ptr ModiWDir         ; aktualizace obsahu adres ©e

TiskSb92:jmp       AWSMnuMM

TiskSoub ENDP

; -----------------------------------------------------------------------------
;        vyti¨tˆn¡ obsahu bufferu ES:SI/CX bajt–, (CY=chyba nebo p©eru¨en¡ ESC)
; -----------------------------------------------------------------------------

TiskBuff PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di

; ------ otev©en¡ v˜stupn¡ho za©¡zen¡

         call      TiskOpen                 ; otev©en¡ v˜stupn¡ho kan lu -> BX
         jc        TiskBuf8                 ; chyba

; ------ znak k vyti¨tˆn¡

TiskBuf2:call      far ptr TestBreak        ; je p©eru¨en¡ operace ?
         jc        TiskBuf8                 ; je p©eru¨en¡ operace
         clc
         jcxz      TiskBuf8                 ; konec dat
         mov       al,es:[si]               ; znak k vyti¨tˆn¡
         inc       si                       ; zv˜¨en¡ ukazatele dat
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e dat

; ------ vyjmut¡ uschovan‚ho znaku CR nebo LF z bufferu -> AH

         mov       ah,0
         xchg      ah,ds:[TiskOld]          ; AH <- uschovan˜ znak CR, LF

; ------ vyti¨tˆn¡ CR/LF

         or        ah,ah                    ; je uschovan˜ CR nebo LF ?
         jz        TiskBuf3                 ; nen¡ uschovan˜ CR/LF
         call      TiskCR                   ; vyti¨tˆn¡ CR/LF
         jc        TiskBuf8                 ; chyba

; ------ p rov˜ CR/LF se vypust¡

         xor       ah,CR XOR LF             ; inverze znaku z bufferu
         cmp       al,ah                    ; byl to p rov˜ CR/LF ?
         je        TiskBuf2                 ; byl to p rov˜ CR/LF - dal¨¡ znak

; ------ £schova znak– CR a LF pro p©¡¨tˆ

TiskBuf3:cmp       al,CR
         je        TiskBuf4
         cmp       al,LF
         jne       TiskBuf5
TiskBuf4:mov       ds:[TiskOld],al          ; £schova CR/LF pro p©¡¨tˆ
         jmp       short TiskBuf2           ; dal¨¡ znak

; ------ filtrace zak zan˜ch znak–

TiskBuf5:cmp       al,FF
         je        TiskBuf7                 ; znak FF je povolen˜
         cmp       al,TAB
         je        TiskBuf6                 ; TAB je povolen˜ znak
         cmp       al,127
         je        TiskBuf2                 ; z kaz znaku CAN
         cmp       al," "
         jb        TiskBuf2                 ; z kaz jin˜ch znak– < 32

; ------ zaji¨tˆn¡ odsazen¡ za‡ tku © dku

TiskBuf6:call      TiskHLft                 ; zaji¨tˆn¡ lev‚ho okraje
         jc        TiskBuf8

; ------ vyti¨tˆn¡ znaku AL

TiskBuf7:call      TiskChr                  ; vyti¨tˆn¡ znaku AL
         jnc       TiskBuf2                 ; dal¨¡ znak

; ------ n vrat registr–

TiskBuf8:call      TiskClos                 ; uzav©en¡ za©¡zen¡
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

TiskBuff ENDP

; -----------------------------------------------------------------------------
;        otev©en¡ tiskov‚ho za©¡zen¡ -> BX (CY=chyba, BX=0)
; -----------------------------------------------------------------------------

TiskOpen PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      dx

; ------ standardn¡ identifik tor za©¡zen¡ PRN

         mov       bx,4                     ; standardn¡ tiskov‚ za©¡zen¡ PRN
         mov       cx,ds:[TiskOut]          ; tiskov‚ za©¡zen¡
         shr       cx,1                     ; je v˜stup na PRN ?
         jc        TiskOpn8                 ; je v˜stup na PRN

; ------ otev©en¡ za©¡zen¡ LPTn nebo COMn

         xor       bx,bx                    ; p©¡znak - nen¡ otev©eno

         call      far ptr TestBreak
         jc        TiskOpn9

         mov       dx,offset TiskLptT       ; za©¡zen¡ LPTn
         mov       al,"1"                   ; LPT1
         shr       cx,1                     ; je v˜stup na LPT1 ?
         jc        TiskOpn1
         inc       ax                       ; LPT2
         shr       cx,1                     ; je v˜stup na LPT2 ?
         jc        TiskOpn1
         inc       ax                       ; LPT3
         shr       cx,1                     ; je v˜stup na LPT3 ?
         jc        TiskOpn1
         mov       al,"1"                   ; COM1
         mov       dx,offset TiskComT       ; za©¡zen¡ COMn
         shr       cx,1                     ; je v˜stup na COM1 ?
         jc        TiskOpn1
         inc       ax                       ; COM2
         shr       cx,1                     ; je v˜stup na COM2 ?
         jc        TiskOpn1
         inc       ax                       ; COM3
         shr       cx,1                     ; je v˜stup na COM3 ?
         jc        TiskOpn1
         inc       ax                       ; COM4
         shr       cx,1                     ; je v˜stup na COM4 ?
         jc        TiskOpn1
         mov       dx,offset FileOPth       ; soubor
TiskOpn1:mov       ds:[TiskLptT+3],al       ; ‡¡slo LPTn
         mov       ds:[TiskComT+3],al       ; ‡¡slo COMn
TiskOpn2:mov       ax,3d01h                 ; otev©en¡ pro z pis
         int       21h                      ; otev©en¡ za©¡zen¡ LPT
         jnc       TiskOpn4

         call      far ptr TestBreak
         jc        TiskOpn9

         mov       ah,3ch
         xor       cx,cx
         int       21h
         jc        TiskOpn9                 ; chyba

TiskOpn4:xchg      ax,bx                    ; BX <- identifik tor za©¡zen¡

         mov       ax,4202h
         xor       cx,cx
         xor       dx,dx
         int       21h                      ; nastaven¡ ukazatele na konec souboru

; ------ n vrat registr–

TiskOpn8:clc
TiskOpn9:pop       dx
         pop       cx
         pop       ax
         ret

TiskOpen ENDP

; -----------------------------------------------------------------------------
;        uzav©en¡ tiskov‚ho za©¡zen¡ BX (uchov v  registr p©¡znak–)
; -----------------------------------------------------------------------------

TiskClos PROC      NEAR

         pushf
         cmp       bx,4                     ; je za©¡zen¡ otev©eno ?
         jbe       TiskCls9                 ; za©¡zen¡ nen¡ otev©eno
         mov       ah,3eh
         int       21h                      ; uzav©en¡ za©¡zen¡
TiskCls9:popf
         ret

TiskClos ENDP

; -----------------------------------------------------------------------------
;        zaji¨tˆn¡ vyti¨tˆn¡ lev‚ho okraje (BX=ident.) (CY=chyba)
; -----------------------------------------------------------------------------

TiskHLft PROC      NEAR

         push      cx

         mov       cx,ds:[TiskLeft]         ; lev˜ okraj
         jmp       short TiskHTb1           ; zaji¨tˆn¡ lev‚ho okraje

TiskHLft ENDP

; -----------------------------------------------------------------------------
;        tisk mezer po zadanou pozici CX (BX=ident.) (CY=chyba)
; -----------------------------------------------------------------------------

TiskHTab PROC      NEAR

         push      cx

TiskHTb1:sub       cx,ds:[TiskAPoz]         ; po‡et chybˆj¡c¡ch pozic
         je        TiskHTb5                 ; nechyb¡ ‘ dn  pozice
         cmc
         jnc       TiskHTb5                 ; ukazatel je za pozic¡

         push      ax

         mov       al," "
TiskHTb2:call      TiskChr
         jc        TiskHTb3
         loop      TiskHTb2

TiskHTb3:pop       ax

TiskHTb5:pop       cx
         ret

TiskHTab ENDP

; -----------------------------------------------------------------------------
;        tisk konce © dku CR/LF (BX=ident.) (CY=chyba)
; -----------------------------------------------------------------------------

TiskCR   PROC      NEAR

         push      ax
         mov       al,CR
         call      TiskChr
         jc        TiskCR2
         mov       al,LF
         call      TiskChr
TiskCR2: pop       ax
         ret

TiskCR   ENDP

; -----------------------------------------------------------------------------
;        vyti¨tˆn¡ znaku AL s obsluhou z hlav¡ a str nkov n¡ (BX=ident.) (CY=chyba)
; -----------------------------------------------------------------------------

TiskChr  PROC      NEAR

; ------ zaji¨tˆn¡ odstr nkov n¡, je-li znak FF

         cmp       al,FF                    ; je nov  str nka FF ?
         jne       TiskChr2                 ; nen¡ FF
         mov       word ptr ds:[TiskARad],-1 ; p©¡znak znaku FF
         jmp       short TiskChr9

; ------ zaji¨tˆn¡ odstr nkov n¡ p©i p©ekro‡en¡ po‡tu © dk–

TiskChr2:push      ax
         cmp       word ptr ds:[TiskARad],-1 ; byl znak FF ?
         je        TiskChr4                 ; byl znak FF
         mov       ax,ds:[TiskDelk]         ; d‚lka str nky
         or        ax,ax                    ; je str nkov n¡ ?
         jz        TiskChr6                 ; nen¡ str nkov n¡
         cmp       ax,ds:[TiskARad]         ; p©ekro‡en konec str nky ?
         jae       TiskChr6                 ; nen¡ p©ekro‡en konec str nky

TiskChr4:cmp       word ptr ds:[TiskAPoz],1 ; je za‡ tek © dku ?
         je        TiskChr5                 ; je ji‘ za‡ tek © dku
         call      Tisk0CR                  ; tisk CR/LF
         jc        TiskChr6                 ; chyba

TiskChr5:mov       al,FF
         call      Tisk0Chr                 ; vyti¨tˆn¡ znaku FF
         jc        TiskChr6                 ; chyba

         xchg      ax,bx
         call      far ptr FlshFile         ; vypr zdnˆn¡ v˜stupn¡ho bufferu
         xchg      ax,bx

         call      TiskNext                 ; potvrzen¡ v˜mˆny pap¡ru

TiskChr6:pop       ax
         jc        TiskChr9                 ; chyba

; ------ tisk z hlav¡ na za‡ tku str nky

         call      TiskHead                 ; tisk z hlav¡
         jc        TiskChr9

; ------ vyti¨tˆn¡ tabul toru

TiskChr7:cmp       al,TAB                   ; je tabul tor ?
         jne       TiskChr8                 ; nen¡ tabul tor
         push      cx
         mov       cx,ds:[TiskAPoz]         ; aktu ln¡ pozice
         add       cx,7
         and       cl,not 7
         inc       cx
         call      Tisk0Tab                 ; zaji¨tˆn¡ pozice
         pop       cx
         jmp       short TiskChr9

; ------ vyti¨tˆn¡ po‘adovan‚ho znaku

TiskChr8:call      Tisk0Chr                 ; vyti¨tˆn¡ znaku AL
TiskChr9:ret

TiskChr  ENDP

; -----------------------------------------------------------------------------
;        vyti¨tˆn¡ z hlav¡ (nadpis) BX=identifik tor za©¡zen¡ -> CY=chyba
; -----------------------------------------------------------------------------

TiskHead PROC      NEAR

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ test, zda se m  z hlav¡ tisknout

         cmp       word ptr ds:[TiskARad],1 ; je prvn¡ © dek na str nce ?
         jne       TiskHe01                 ; nen¡ prvn¡ © dek na str nce
         test      byte ptr ds:[TiskParm],bit0 ; tiskne se z hlav¡ ?
         jz        TiskHea0                 ; z hlav¡ se netiskne
         cmp       word ptr ds:[TiskDelk],1 ; je d‚lka 1 © dek ?
         jne       TiskHea1                 ; d‚lka vyhovuje
TiskHe01:clc
TiskHea0:jmp       TiskHea9

; ------ tisk £vodn¡ch mezer

TiskHea1:mov       cx,ds:[TiskLeft]         ; lev˜ okraj
         call      Tisk0Tab                 ; vyti¨tˆn¡ lev‚ho okraje
         jc        TiskHea0

; ------ tisk jm‚na souboru

         push      ds
         pop       es                       ; ES <- datov˜ segment
         mov       si,offset SRMnuFil+1     ; jm‚no souboru
         mov       ch,0
         mov       cl,ds:[si-1]             ; d‚lka textu jm‚na souboru
         call      Tisk0Txt                 ; vyti¨tˆn¡ jm‚na souboru
         jc        TiskHea0

; ------ dek¢dov n¡ ‡¡sla str nky -> DI=d‚lka textu ‡¡sla str nky

         mov       di,offset TiskStrn+2     ; buffer k dek¢dov n¡ ‡¡sla strany
         mov       ax,ds:[TiskAStr]         ; aktivn¡ str nka
         push      bx
         xor       bx,bx                    ; nen¡ oddˆlova‡ ani barva
         call      far ptr DekNumW          ; dek¢dov n¡ ‡¡sla
         pop       bx
         cld
         mov       ax,"- "
         stosw
         mov       si,offset TiskStrn       ; SI <- za‡ tek textu
         sub       di,si                    ; DI <- d‚lka textu

; ------ stanoven¡ prav‚ho okraje pro z hlav¡ -> DX

         mov       ax,ds:[TiskRght]         ; prav˜ okraj
         or        ax,ax                    ; je prav˜ okraj ?
         jnz       TiskHea2                 ; je prav˜ okraj
         mov       al,80                    ; implicitn¡ prav˜ okraj
TiskHea2:cmp       ax,250                   ; maxim ln¡ prav˜ okraj
         jbe       TiskHea3                 ; prav˜ okraj je OK
         mov       ax,250                   ; omezen¡ prav‚ho okraje
TiskHea3:xchg      ax,dx                    ; DX <- prav˜ okraj

; ------ tisk oddˆlovac¡ch mezer p©ed ‡¡slem

         mov       cx,dx                    ; prav˜ okraj
         sub       cx,ds:[TiskLeft]         ; ode‡ten¡ lev‚ho okraje -> ¨¡©ka
         jbe       TiskHea4                 ; kr tk˜ © dek
         sub       cx,di                    ; ode‡ten¡ d‚lky ‡¡sla
         jbe       TiskHea4                 ; nezbylo nic na mezery
         shr       cx,1                     ; polovina na mezery
         add       cx,ds:[TiskLeft]         ; pozice pro konec mezer
         call      Tisk0Tab                 ; vyti¨tˆn¡ mezer
         jc        TiskHea0

; ------ tisk ‡¡sla str nky ES:SI (DI=d‚lka)

TiskHea4:mov       cx,di                    ; d‚lka textu ‡¡sla
         call      Tisk0Txt                 ; vyti¨tˆn¡ ‡¡sla str nky
         jc        TiskHea9

; ------ tisk oddˆlovac¡ch mezer za ‡¡slem

         mov       cx,dx                    ; prav˜ okraj © dku
         sub       cx,9                     ; ode‡ten¡ pozic pro datum - 1
         jbe       TiskHea5                 ; nen¡ voln  pozice
         call      Tisk0Tab                 ; tisk mezer po za‡ tek data
         jc        TiskHea9

; ------ tisk data souboru

TiskHea5:mov       cx,10                    ; d‚lka textu data
         mov       si,offset SRMnuDat+1     ; buffer data souboru
         call      Tisk0Txt                 ; tisk data souboru
         jc        TiskHea9

; ------ tisk konce © dku

         cmp       word ptr ds:[TiskDelk],2 ; jsou pr vˆ 2 © dky ?
         je        TiskHea6                 ; nebude druh˜ © dek z hlav¡
         call      Tisk0CR                  ; tisk konce © dku CR/LF
         jc        TiskHea9
TiskHea6:call      Tisk0CR                  ; tisk konce © dku CR/LF

; ------ n vrat registr–

TiskHea9:pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

TiskHead ENDP

; -----------------------------------------------------------------------------
;        vyti¨tˆn¡ textu ES:SI/CX znak– pro tisk z hlav¡ (BX=ident.) (CY=chyba)
; -----------------------------------------------------------------------------

Tisk0Txt PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      si

; ------ tisk textu

         clc
         jcxz      Tisk0Tx3                 ; nen¡ ‘ dn˜ znak k tisku
Tisk0Tx2:mov       al,es:[si]               ; znak k vyti¨tˆn¡
         inc       si                       ; zv˜¨en¡ ukazatele textu
         call      Tisk0Chr                 ; tisk znaku AL
         jc        Tisk0Tx3                 ; chyba
         loop      Tisk0Tx2                 ; dal¨¡ znak

; ------ n vrat registr–

Tisk0Tx3:pop       si
         pop       cx
         pop       ax
         ret

Tisk0Txt ENDP

; -----------------------------------------------------------------------------
;        tisk mezer po zadanou pozici CX = 1... (BX=ident.) (CY=chyba)
; -----------------------------------------------------------------------------

Tisk0Tab PROC      NEAR

         push      cx

Tisk0Tb1:sub       cx,ds:[TiskAPoz]         ; po‡et chybˆj¡c¡ch pozic
         je        Tisk0Tb5                 ; nechyb¡ ‘ dn  pozice
         cmc
         jnc       Tisk0Tb5                 ; ukazatel je za pozic¡

         push      ax

         mov       al," "                   ; znak mezery k vyti¨tˆn¡
Tisk0Tb2:call      Tisk0Chr                 ; tisk znaku mezery
         jc        Tisk0Tb3
         loop      Tisk0Tb2                 ; dal¨¡ znak

Tisk0Tb3:pop       ax

Tisk0Tb5:pop       cx
         ret

Tisk0Tab ENDP

; -----------------------------------------------------------------------------
;        tisk konce © dku CR/LF (BX=ident.) (CY=chyba)
; -----------------------------------------------------------------------------

Tisk0CR  PROC      NEAR

         push      ax
         mov       al,CR
         call      Tisk0Chr                 ; tisk znaku CR
         jc        Tisk0CR2
         mov       al,LF
         call      Tisk0Chr                 ; tisk znaku LF
Tisk0CR2:pop       ax
         ret

Tisk0CR  ENDP

; -----------------------------------------------------------------------------
;        vyti¨tˆn¡ jednoho znaku AL (identifik tor BX, CY=chyba)
;  udr‘uje ukazatele kurzoru, omezuje d‚lku © dku a zaji¨Ÿuje po‡ te‡n¡ str nku
; -----------------------------------------------------------------------------

Tisk0Chr PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      si
         push      es

; ------ kontrola maxim ln¡ pozice

         cmp       al,CR
         je        Tisk0Ch1                 ; pro CR nen¡ omezen¡ pozice
         cmp       al,LF
         je        Tisk0Ch1                 ; pro LF nen¡ omezen¡ pozice
         cmp       al,FF
         je        Tisk0Ch1                 ; pro FF nen¡ omezen¡ pozice
         mov       cx,ds:[TiskRght]         ; prav˜ okraj
         jcxz      Tisk0Ch1                 ; nen¡ prav˜ okraj
         cmp       cx,ds:[TiskAPoz]         ; je p©ekro‡en prav˜ okraj ?
         jb        Tisk0Ch4                 ; p©ekro‡en prav˜ okraj

; ------ kontrola po‡ te‡n¡ str nky

Tisk0Ch1:mov       cx,ds:[TiskAStr]         ; aktu ln¡ str nka
         sub       cx,ds:[TiskPoc]          ; aktu ln¡ str nka relativnˆ 0...
         cmp       cx,ds:[TiskPres]         ; kontrola p©esko‡en˜ch str nek
         jb        Tisk0Ch4                 ; nen¡ je¨tˆ po‡ te‡n¡ str nka

; ------ v˜stup znaku AL na za©¡zen¡

Tisk0Ch2:push      ds
         pop       es                       ; ES <- datov˜ segment
         mov       si,offset TiskBff        ; tiskov˜ buffer
         mov       ds:[si],al               ; ulo‘en¡ znaku do bufferu
         xchg      ax,bx                    ; AX <- identifik tor
         mov       cx,1                     ; zap¡¨e se 1 znak
         call      far ptr WritFile         ; z pis znaku na v˜stup
         xchg      ax,bx
         jc        Tisk0Ch9                 ; chyba

; ------ znak CR

Tisk0Ch4:cmp       al,CR
         jne       Tisk0Ch5
         mov       word ptr ds:[TiskAPoz],1 ; ukazatel na za‡ tek © dku
         jmp       short Tisk0Ch8

; ------ znak FF

Tisk0Ch5:cmp       al,FF
         jne       Tisk0Ch6
         mov       word ptr ds:[TiskARad],1 ; aktu ln¡ © dek
         cmp       word ptr ds:[TiskAStr],9999 ; maxim ln¡ ‡¡slo str nky
         jae       Tisk0Ch8                 ; je ji‘ maxim ln¡ ‡¡slo str nky
         inc       word ptr ds:[TiskAStr]   ; zv˜¨en¡ ‡¡sla aktu ln¡ str nky
         jmp       short Tisk0Ch8

; ------ znak LF

Tisk0Ch6:cmp       al,LF
         jne       Tisk0Ch7
         cmp       word ptr ds:[TiskARad],9999 ; maxim ln¡ ‡¡slo © dku
         jae       Tisk0Ch8                 ; je ji‘ maxim ln¡ ‡¡slo © dku
         inc       word ptr ds:[TiskARad]   ; zv˜¨en¡ ukazatele © dku
         jmp       short Tisk0Ch8

; ------ jin˜ znak

Tisk0Ch7:cmp       word ptr ds:[TiskAPoz],9999 ; maxim ln¡ ‡¡slo pozice
         jae       Tisk0Ch8                 ; je ji‘ maxim ln¡ pozice na © dku
         inc       word ptr ds:[TiskAPoz]   ; zv˜¨en¡ pozice na © dku

; ------ n vrat registr–

Tisk0Ch8:clc
Tisk0Ch9:pop       es
         pop       si
         pop       cx
         pop       ax
         ret

Tisk0Chr ENDP

; -----------------------------------------------------------------------------
;        v˜mˆna pap¡ru (CY=p©eru¨en¡)
; -----------------------------------------------------------------------------

TiskNext PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      si
         push      di
         push      es

; ------ test p©eru¨en¡ tisku p©ed novou str nkou

         call      far ptr TestBEsc         ; je p©eru¨en¡ operace ESC ?
         jc        TiskNxt8                 ; je p©eru¨en¡ operace ESC

; ------ test, zda je povolen  str nka

         test      byte ptr ds:[TiskParm],bit1 ; je v˜mˆna pap¡ru ?
         jz        TiskNxt8                 ; nen¡ v˜mˆna pap¡ru
         mov       ax,ds:[TiskAStr]         ; aktu ln¡ ‡¡slo str nky
         sub       ax,ds:[TiskPoc]          ; ‡¡slo str nky relativnˆ
         cmp       ds:[TiskPres],ax         ; je to ji‘ platn  str nka ?
         ja        TiskNxt8                 ; nen¡ to je¨tˆ platn  str nka

; ------ dek¢dov n¡ ‡¡sla str nky

         push      ds
         pop       es                       ; ES <- datov˜ segment
         mov       di,offset STTXMTi2       ; buffer pro ‡¡slo str nky
         mov       ax,ds:[TiskAStr]         ; aktu ln¡ str nka
         xor       bx,bx                    ; nen¡ oddˆlova‡ ani barva
         call      far ptr DekNumW          ; dek¢dov n¡ ‡¡sla
         xchg      ax,di                    ; AX <- adresa konce textu
         sub       ax,offset STTXMTit+1     ; d‚lka textu
         mov       ds:[STTXMTit],al         ; d‚lka textu

; ------ potvrzen¡ dal¨¡ str nky

         mov       si,offset STTXMLin       ; menu potvrzen¡
         call      far ptr Lin0MenF         ; potvrzen¡ v˜mˆny pap¡ru
         pushf
         call      far ptr InfoDisp         ; obnoven¡ informa‡n¡ho © dku
         popf

; ------ n vrat registr–

TiskNxt8:pop       es
         pop       di
         pop       si
         pop       bx
         pop       ax
         ret

TiskNext ENDP

CodeFil  ENDS

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;
;                                 Data
;
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

Data     SEGMENT
;þ
; -----------------------------------------------------------------------------
;        Definice © dkov‚ho menu - vytvo©en¡ adres ©e
; -----------------------------------------------------------------------------

SAMnuLin label     byte                   ;* menu vytvo©en¡ adres ©e
         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        4                        ; po‡et platn˜ch polo‘ek menu
         dw        6                        ; celkov˜ po‡et polo‘ek menu

         dw        SAMnLPol                 ; za‡ tek definice polo‘ek menu
         dw        SAMnLHlp                 ; adresa tabulky text– n povˆdy
         dw        Hlp@VytvoreniAdresare    ; ‡¡slo str nky velk‚ n povˆdy
         dw        SAMnLBlk                 ; adresa blokovac¡ tabulky
         dw        SAMnLSwc                 ; adresa tabulky p©ep¡na‡–
         dw        SAMnLTit                 ; adresa titulu okna
         dw        SAMnLExe                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        20                       ; po‡ te‡n¡ pozice okna
         db        0                        ; po‡ te‡n¡ © dek okna
         db        50                       ; ¨¡©ka okna
         db        8                        ; v˜¨ka okna

         dw        255                      ; maxim ln¡ d‚lka textu © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        1                        ; celkov˜ po‡et © dk–
         dw        1                        ; po‡et zobrazen˜ch © dk–

         db        bit2                     ; maska - v¨e (kv–li dlouh˜m jm‚n–m)
;         db        bit3+bit6                ; maska zad van˜ch znak– - soubor
         db        2,'?*    '               ; zak zan‚ znaky

         db        HistFile                 ; historie specifikac¡ soubor–
         db        1                        ; po‡et p©edvoleb
SAMnLPrN dw        3                        ; d‚lka p©edvolby
SAMnLPrA dd        AktPath                  ; adresa p©edvolby

; ------ polo‘ky voleb

SAMnLPol db        bit6,20,'Adres © k vytvo©en¡:'
         db        0,0
         db        bit6+bit7,0
         db        1,6,'Vytvo©'
         db        1+bit7,14,'Dlouh  jm‚na '
SAMnLPl1 db        '-'
         db        1,6,'N vrat'

SAMnLBlk db        0,0,0,0                  ; blokovac¡ tabulka

SAMnLSwc db        0

SAMnLSw1 db        bit0                     ; p©ep¡na‡e
                                            ;   bit 0: 1=dlouh  jm‚na

SAMnLTit db        7,'adres ©'

; ------ n povˆda

HelpS    SEGMENT   BYTE PUBLIC
SAMnLHlp db        85,'Zadejte adres © nebo cestu k vytvo©en¡ (syntaxe:  adres © / Ddatum T‡as ASHR)'
         db        38,'Vytvo©en¡ zadan‚ho adres ©e nebo cesty'
         db        50,'Vytvo©en¡ adres ©e s dlouh˜m jm‚nem (WINDOWS 95)'
         db        3,1
         dw        MenuHlP1                 ; 'P©eru¨en¡ volby'
HelpS    ENDS

SAMnLExe dd        Lin0MenR                 ; © dky
         dd        Lin0MenR                 ; Vytvo©
         dd        SAMnLExD                 ; Dlouh  jm‚na
         dd        Lin0MenR                 ; N vrat

SAMnLinA db        18,'Vytv ©¡m adres © ',0

; -----------------------------------------------------------------------------
;        chybov‚ hl ¨en¡ - chybn‚ zad n¡ disku
; -----------------------------------------------------------------------------

ChbLnD1  label     byte
         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        2                        ; po‡et platn˜ch polo‘ek menu
         dw        6                        ; celkov˜ po‡et polo‘ek menu

         dw        ChbLnD1P                 ; za‡ tek definice polo‘ek menu
         dw        ChbLnP1H                 ; adresa tabulky text– n povˆdy
         dw        Hlp@VytvoreniAdresare    ; ‡¡slo str nky velk‚ n povˆdy
         dw        ChbLnP1B                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        ChbLnD1T                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        23                       ; po‡ te‡n¡ pozice okna
         db        7                        ; po‡ te‡n¡ © dek okna
         db        45                       ; ¨¡©ka okna
         db        9                        ; v˜¨ka okna

         dw        255                      ; maxim ln¡ d‚lka textu © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        0                        ; celkov˜ po‡et © dk–
         dw        0                        ; po‡et zobrazen˜ch © dk–

         db        bit3                     ; maska zad van˜ch znak–
         db        0,'      '               ; zak zan‚ znaky

         db        0                        ; historie specifikac¡ soubor–
         db        0                        ; po‡et p©edvoleb

ChbLnD1P db        bit6,6,0,'CHYBA'
         db        bit6,27,'Chybn‚ zad n¡ jm‚na disku !'
         db        bit6,21,'Disk ',0
ChbLD1P1 db        'A:',0,' neexistuje.'
         db        bit6+bit7,0
         db        1,5,'Znovu'
         db        1,8,'P©eru¨it'

ChbLnD1T db        11,'chybn˜ disk'

ChbLnP1B db        0,0                      ; blokovac¡ tabulka

HelpS    SEGMENT   BYTE PUBLIC
ChbLnP1H db        37,'Opakov n¡ zad n¡ adres ©e k vytvo©en¡'
         db        3,1
         dw        MenuHlP2                 ; 'P©eru¨en¡ operace'
HelpS    ENDS

; -----------------------------------------------------------------------------
;        chybov‚ hl ¨en¡ - p©ekro‡ena maxim ln¡ d‚lka cesty
; -----------------------------------------------------------------------------

ChbLnD2  label     byte
         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        2                        ; po‡et platn˜ch polo‘ek menu
         dw        5                        ; celkov˜ po‡et polo‘ek menu

         dw        ChbLnD2P                 ; za‡ tek definice polo‘ek menu
         dw        ChbLnP1H                 ; adresa tabulky text– n povˆdy
         dw        Hlp@VytvoreniAdresare    ; ‡¡slo str nky velk‚ n povˆdy
         dw        ChbLnP1B                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        ChbLnD2T                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        20                       ; po‡ te‡n¡ pozice okna
         db        7                        ; po‡ te‡n¡ © dek okna
         db        45                       ; ¨¡©ka okna
         db        8                        ; v˜¨ka okna

         dw        255                      ; maxim ln¡ d‚lka textu © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        0                        ; celkov˜ po‡et © dk–
         dw        0                        ; po‡et zobrazen˜ch © dk–

         db        bit3                     ; maska zad van˜ch znak–
         db        0,'      '               ; zak zan‚ znaky

         db        0                        ; historie specifikac¡ soubor–
         db        0                        ; po‡et p©edvoleb

; ------ polo‘ky voleb

ChbLnD2P db        bit6,6,0,'CHYBA'
         db        bit6,34,'P©ekro‡ena maxim ln¡ d‚lka cesty !'
         db        bit6+bit7,0
         db        1,5,'Znovu'
         db        1,8,'P©eru¨it'

ChbLnD2T db        12,'chybn  d‚lka'

; -----------------------------------------------------------------------------
;        chybov‚ hl ¨en¡ - vytv ©en˜ adres © ji‘ existuje
; -----------------------------------------------------------------------------

ChbLnD3  label     byte
         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        2                        ; po‡et platn˜ch polo‘ek menu
         dw        5                        ; celkov˜ po‡et polo‘ek menu

         dw        ChbLnD3P                 ; za‡ tek definice polo‘ek menu
         dw        ChbLnP1H                 ; adresa tabulky text– n povˆdy
         dw        Hlp@VytvoreniAdresare    ; ‡¡slo str nky velk‚ n povˆdy
         dw        ChbLnP1B                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        ChbLnD3T                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        22                       ; po‡ te‡n¡ pozice okna
         db        7                        ; po‡ te‡n¡ © dek okna
         db        45                       ; ¨¡©ka okna
         db        8                        ; v˜¨ka okna

         dw        255                      ; maxim ln¡ d‚lka textu © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        0                        ; celkov˜ po‡et © dk–
         dw        0                        ; po‡et zobrazen˜ch © dk–

         db        bit3                     ; maska zad van˜ch znak–
         db        0,'      '               ; zak zan‚ znaky

         db        0                        ; historie specifikac¡ soubor–
         db        0                        ; po‡et p©edvoleb

; ------ polo‘ky voleb

ChbLnD3P db        bit6,6,0,'CHYBA'
         db        bit6,29,'Zadan˜ adres © ji‘ existuje !'
         db        bit6+bit7,0
         db        1,5,'Znovu'
         db        1,8,'P©eru¨it'

ChbLnD3T db        16,'adres © existuje'

; -----------------------------------------------------------------------------
;     chybov‚ hl ¨en¡ - existuje soubor stejn‚ho jm‚na jako vytv ©en˜ adres ©
; -----------------------------------------------------------------------------

ChbLnD4  label     byte
         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        2                        ; po‡et platn˜ch polo‘ek menu
         dw        6                        ; celkov˜ po‡et polo‘ek menu

         dw        ChbLnD4P                 ; za‡ tek definice polo‘ek menu
         dw        ChbLnP1H                 ; adresa tabulky text– n povˆdy
         dw        Hlp@VytvoreniAdresare    ; ‡¡slo str nky velk‚ n povˆdy
         dw        ChbLnP1B                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        ChbLnD4T                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        23                       ; po‡ te‡n¡ pozice okna
         db        6                        ; po‡ te‡n¡ © dek okna
         db        45                       ; ¨¡©ka okna
         db        9                        ; v˜¨ka okna

         dw        255                      ; maxim ln¡ d‚lka textu © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        0                        ; celkov˜ po‡et © dk–
         dw        0                        ; po‡et zobrazen˜ch © dk–

         db        bit3                     ; maska zad van˜ch znak–
         db        0,'      '               ; zak zan‚ znaky

         db        0                        ; historie specifikac¡ soubor–
         db        0                        ; po‡et p©edvoleb

; ------ polo‘ky voleb

ChbLnD4P db        bit6,6,0,'CHYBA'
         db        bit6,28,'Existuje ji‘ soubor stejn‚ho'
         db        bit6,28,' jm‚na jako zadan˜ adres © !'
         db        bit6+bit7,0
         db        1,5,'Znovu'
         db        1,8,'P©eru¨it'

ChbLnD4T db        15,'soubor existuje'

; -----------------------------------------------------------------------------
;     chybov‚ hl ¨en¡ - chybn‚ zad n¡ adres ©e, nelze jej vytvo©it
; -----------------------------------------------------------------------------

ChbLnD5  label     byte

         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        2                        ; po‡et platn˜ch polo‘ek menu
         dw        5                        ; celkov˜ po‡et polo‘ek menu

         dw        ChbLnD5P                 ; za‡ tek definice polo‘ek menu
         dw        ChbLnP1H                 ; adresa tabulky text– n povˆdy
         dw        Hlp@VytvoreniAdresare    ; ‡¡slo str nky velk‚ n povˆdy
         dw        ChbLnP1B                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        ChbLnD5T                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        21                       ; po‡ te‡n¡ pozice okna
         db        6                        ; po‡ te‡n¡ © dek okna
         db        45                       ; ¨¡©ka okna
         db        8                        ; v˜¨ka okna

         dw        255                      ; maxim ln¡ d‚lka textu © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        0                        ; celkov˜ po‡et © dk–
         dw        0                        ; po‡et zobrazen˜ch © dk–

         db        bit3                     ; maska zad van˜ch znak–
         db        0,'      '               ; zak zan‚ znaky

         db        0                        ; historie specifikac¡ soubor–
         db        0                        ; po‡et p©edvoleb

; ------ polo‘ky voleb

ChbLnD5P db        bit6,6,0,'CHYBA'
         db        bit6,31,'Zadan˜ adres © nelze vytvo©it !'
         db        bit6+bit7,0
         db        1,5,'Znovu'
         db        1,8,'P©eru¨it'

ChbLnD5T db        22,'adres © nelze vytvo©it'

; -----------------------------------------------------------------------------
;     chybov‚ hl ¨en¡ - nedostatek m¡sta na disku k vytvo©en¡ adres ©e
; -----------------------------------------------------------------------------

ChbLnD6  label     byte

         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        2                        ; po‡et platn˜ch polo‘ek menu
         dw        6                        ; celkov˜ po‡et polo‘ek menu

         dw        ChbLnD6P                 ; za‡ tek definice polo‘ek menu
         dw        ChbLnP1H                 ; adresa tabulky text– n povˆdy
         dw        Hlp@VytvoreniAdresare    ; ‡¡slo str nky velk‚ n povˆdy
         dw        ChbLnP1B                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        ChbLnD6T                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        21                       ; po‡ te‡n¡ pozice okna
         db        6                        ; po‡ te‡n¡ © dek okna
         db        45                       ; ¨¡©ka okna
         db        9                        ; v˜¨ka okna

         dw        255                      ; maxim ln¡ d‚lka textu © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        0                        ; celkov˜ po‡et © dk–
         dw        0                        ; po‡et zobrazen˜ch © dk–

         db        bit3                     ; maska zad van˜ch znak–
         db        0,'      '               ; zak zan‚ znaky

         db        0                        ; historie specifikac¡ soubor–
         db        0                        ; po‡et p©edvoleb

; ------ polo‘ky voleb

ChbLnD6P db        bit6,6,0,'CHYBA'
         db        bit6,24,'Nedostatek voln‚ho m¡sta'
ChbLD6P2 db        bit6,36,'na disku ',0,'A:',0,' k vytvo©en¡ adres ©e !'
         db        bit6+bit7,0
         db        1,5,'Znovu'
         db        1,8,'P©eru¨it'

ChbLnD6T db        16,'nedostatek m¡sta'

; -----------------------------------------------------------------------------
;     chybov‚ hl ¨en¡ - nedostatek polo‘ek ROOT
; -----------------------------------------------------------------------------

ChbLnD7  label     byte

         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        2                        ; po‡et platn˜ch polo‘ek menu
         dw        6                        ; celkov˜ po‡et polo‘ek menu

         dw        ChbLnD7P                 ; za‡ tek definice polo‘ek menu
         dw        ChbLnP1H                 ; adresa tabulky text– n povˆdy
         dw        Hlp@VytvoreniAdresare    ; ‡¡slo str nky velk‚ n povˆdy
         dw        ChbLnP1B                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        ChbLnD7T                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        21                       ; po‡ te‡n¡ pozice okna
         db        6                        ; po‡ te‡n¡ © dek okna
         db        45                       ; ¨¡©ka okna
         db        9                        ; v˜¨ka okna

         dw        255                      ; maxim ln¡ d‚lka textu © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        0                        ; celkov˜ po‡et © dk–
         dw        0                        ; po‡et zobrazen˜ch © dk–

         db        bit3                     ; maska zad van˜ch znak–
         db        0,'      '               ; zak zan‚ znaky

         db        0                        ; historie specifikac¡ soubor–
         db        0                        ; po‡et p©edvoleb

; ------ polo‘ky voleb

ChbLnD7P db        bit6,6,0,'CHYBA'
         db        bit6,24,'Nedostatek polo‘ek ',0,'ROOT'
ChbLD7P2 db        bit6,36,'na disku ',0,'A:',0,' k vytvo©en¡ adres ©e !'
         db        bit6+bit7,0
         db        1,5,'Znovu'
         db        1,8,'P©eru¨it'

ChbLnD7T db        23,'nedostatek polo‘ek ROOT'

; -----------------------------------------------------------------------------
;        Volba v˜bˆru polo‘ek - vertik ln¡ menu
; -----------------------------------------------------------------------------
;þ
;SelParam db        bit0                     ; parametry pro v˜bˆr polo‘ek
;                                            ;   bit 0: 1=ozna‡it
;                                            ;   bit 1: 1=nulovat
;                                            ;   bit 2: 1=inverze
;                                            ;   bit 4: 1=podadres ©e
;                                            ;   bit 5: 1=ozna‡en‚
;                                            ;   bit 6: 1=uchovat ozna‡en¡

SelParm0 db        0                        ; aktu ln¡ parametry pro v˜bˆr textem
                                            ;   bit 0: 1=ozna‡it
                                            ;   bit 1: 1=nulovat
                                            ;   bit 2: 1=inverze

SBMnVert label     byte                   ;* menu v˜bˆru polo‘ek
         db        2                        ; typ menu - vertik ln¡ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka volby
         dw        10                       ; po‡et platn˜ch polo‘ek menu
         dw        12                       ; celkov˜ po‡et polo‘ek menu

         dw        SBMnVPol                 ; adresa defini‡n¡ tabulky polo‘ek
         dw        SBMnVHlp                 ; adresa tabulky text– n povˆdy
         dw        Hlp@PodmenuOznacovaniSouboru ; ‡¡slo str nky velk‚ n povˆdy
         dw        SBMnVBlk                 ; adresa blokovac¡ tabulky
         dw        SBMnVSwc                 ; adresa tabulky p©ep¡na‡–
         dw        SBMnVTit                 ; adresa titulu okna
         dw        SBMnVExe                 ; tabulka obsluh voleb menu
         dw        SBMnVMnu                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        36                       ; po‡ te‡n¡ pozice
         db        2                        ; po‡ te‡n¡ © dek
         db        20                       ; ¨¡©ka
         db        14                       ; v˜¨ka

SBMnVPol db        1+bit7,7,'Ozna‡it'
         db        1+bit7,7,'Nulovat'
         db        1+bit7,7,'Inverze'
         db        bit6+bit7,0
         db        1,6,'Kurzor'
         db        1,7,'Soubory'
         db        1,7,'V¨echny'
         db        1,13,'COM, EXE, BAT'
         db        1,6,'Zadan‚'
         db        bit6+bit7,0
         db        1,9,'Uschovan‚'
         db        1,17,'Porovn n¡m      ',16

SBMnVBlk db        0,0,0,0,0,0,0,0,0,0
SBMnVSwc db        0,0,0

SBMnVTit db        5,'v˜bˆr'

HelpS    SEGMENT   BYTE PUBLIC
SBMnVHlp db        64,'Ozna‡en¡ polo‘ek se nastav¡ (Shift-[+], Alt-[+], Ctrl-[+])'
         db        62,'Ozna‡en¡ polo‘ek se zru¨¡ (Shift-[-], Alt-[-], Ctrl-[-])'
         db        82,'Ozna‡en¡ polo‘ek se bude invertovat (Insert, Shift-[*], Alt-[*], Ctrl-[*])'

         db        67,1
         dw        SBMnVHl1
         db        'polo‘ky pod kurzorem (Insert, Alt-[+], Alt-[-], Alt-[*])'

         db        60,1
         dw        SBMnVHl1
         db        'v¨ech soubor– v oknˆ (Ctrl-[+], Ctrl-[-], Ctrl-[*])'

         db        63,1
         dw        SBMnVHl1
         db        'v¨ech soubor– a podadres ©– v oknˆ (jako Kurzor na "..")'

         db        56,1
         dw        SBMnVHl1
         db        'spustiteln˜ch program– COM, EXE, BAT (Ctrl-^)'

         db        67,1
         dw        SBMnVHl1
         db        'podle bli‘¨¡ specifikace (Shift-[+], Shift-[-], Shift-[*])'

         db        63,1
         dw        SBMnVHl1
         db        'polo‘ek s uschovan˜m ozna‡en¡m z p©ede¨l‚ operace (Ctrl-])'

         db        52,1
         dw        SBMnVHl1
         db        'porovn n¡m s druh˜m oknem (Alt-F9 pro obˆ okna)'
HelpS    ENDS

SBMnVExe label     dword                    ; adresy obsluh voleb
         dd        AWMMSB11                 ; ozna‡it
         dd        AWMMSB12                 ; nulovat
         dd        AWMMSB13                 ; inverze
         dd        AWMMSB14                 ; kurzor
         dd        AWMMSB15                 ; soubory
         dd        AWMMSB16                 ; v¨echny
         dd        AWMMSB17                 ; COM
         dd        AWMMSB18                 ; zadan‚
         dd        AWMMSB19                 ; uschovan‚
         dd        AWMMSB1C                 ; porovn n¡m

SBMnVMnu label     word                     ; adresy podmenu
         dw        0                        ; ozna‡it
         dw        0                        ; nulovat
         dw        0                        ; inverze
         dw        0                        ; kurzor
         dw        0                        ; soubory
         dw        0                        ; v¨echny
         dw        0                        ; COM
         dw        0                        ; zadan‚
         dw        0                        ; uschovan‚
         dw        SBPMVert                 ; porovn n¡m

SBMnVHl1 db        15,'Zmˆna ozna‡en¡ '

; -----------------------------------------------------------------------------
;        volba soubor– k v˜bˆru porovn n¡m
; -----------------------------------------------------------------------------

SBPMVert label     byte                    ;* menu ozna‡en¡ soubor– porovn n¡m
         db        2                        ; typ menu - vertik ln¡ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka volby
         dw        10                       ; po‡et platn˜ch polo‘ek menu
         dw        11                       ; celkov˜ po‡et polo‘ek menu

         dw        SBPMVPol                 ; adresa defini‡n¡ tabulky polo‘ek
         dw        SBPMVHlp                 ; adresa tabulky text– n povˆdy
         dw        Hlp@PorovnavaniAdresaru  ; ‡¡slo str nky velk‚ n povˆdy
         dw        SBPMVBlk                 ; adresa blokovac¡ tabulky
         dw        SBPMVSwc                 ; adresa tabulky p©ep¡na‡–
         dw        SBPMVTit                 ; adresa titulu okna
         dw        SBPMVExe                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        43                       ; po‡ te‡n¡ pozice
         db        8                        ; po‡ te‡n¡ © dek
         db        20                       ; ¨¡©ka
         db        13                       ; v˜¨ka

SBPMVPol db        1,8,'Aktu ln¡'
         db        1,9,'Dopl¤kov‚'
         db        1,7,'Novˆj¨¡'
         db        1,6,'Shodn‚'
         db        2,6,'sTar¨¡'
         db        1,8,'Rozd¡ln‚'
         db        1,10,'Existuj¡c¡'
         db        1,11,'Voln‚ m¡sto'
         db        bit6+bit7,0
         db        1+bit7,11,'Podadres ©e'
         db        1+bit7,8,'Ozna‡en‚'

SBPMVBlk db        0,0,0,0,0,0,0,0,0,0

SBPMVSwc db        0,0

SBPMVTit db        9,'porovn n¡'

HelpS    SEGMENT   BYTE PUBLIC
SBPMVHlp db        29,1
         dw        SBPMVHl1
         db        'novˆj¨¡ch nebo dopl¤kov˜ch'

         db        17,1
         dw        SBPMVHl1
         db        'chybˆj¡c¡ch',1
         dw        SBPMVHl2

         db        27,1
         dw        SBPMVHl1
         db        'novˆj¨¡ch ne‘ polo‘ky',1
         dw        SBPMVHl2

         db        26,1
         dw        SBPMVHl1
         db        'shodn˜ch s polo‘kami',1
         dw        SBPMVHl2

         db        26,1
         dw        SBPMVHl1
         db        'star¨¡ch ne‘ polo‘ky',1
         dw        SBPMVHl2

         db        26,1
         dw        SBPMVHl1
         db        'odli¨n˜ch od polo‘ek',1
         dw        SBPMVHl2

         db        18,1
         dw        SBPMVHl1
         db        'existuj¡c¡ch',1
         dw        SBPMVHl2

         db        50,1
         dw        SBMnVHl1
         db        'soubor– velikost¡ vyhovuj¡c¡ch voln‚mu m¡stu',1
         dw        SBPMVHl2

         db        3,1
         dw        SBPMVHl3

         db        3,1
         dw        SBPMVHl4
HelpS    ENDS

SBPMVExe label     dword                    ; adresy obsluh voleb
         dd        AWMSB1C2                 ; aktu ln¡
         dd        AWMSB1C2                 ; dopl¤kov‚
         dd        AWMSB1C2                 ; novˆj¨¡
         dd        AWMSB1C2                 ; shodn‚
         dd        AWMSB1C2                 ; star¨¡
         dd        AWMSB1C2                 ; rozd¡ln‚
         dd        AWMSB1C2                 ; existuj¡c¡
         dd        AWMSB1C2                 ; voln‚ m¡sto
         dd        AWMSBC22                 ; podadres ©e
         dd        AWMSBC24                 ; ozna‡en‚

SBPMPorS db        30,'Porovn v m soubory v oknech...'

SBPMVHl1 db        36,'Zmˆna ozna‡en¡ se provede u polo‘ek '
SBPMVHl2 db        14,' v druh‚m oknˆ'
SBPMVHl3 db        75,'Operace se bude prov dˆt t‚‘ pro podadres ©e v oknˆ (kromˆ "Voln‚ m¡sto")'
SBPMVHl4 db        74,'Operace se provede pouze pro ozna‡en‚ polo‘ky (jsou-li nˆjak‚ - jinak v¨e)'

; -----------------------------------------------------------------------------
;        Definice © dkov‚ho menu - volba soubor– k ozna‡en¡
; -----------------------------------------------------------------------------

SB1MnLin label     byte                   ;* menu ozna‡en¡ soubor–

         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        3                        ; po‡et platn˜ch polo‘ek menu
         dw        5                        ; celkov˜ po‡et polo‘ek menu

         dw        SB1MLPol                 ; za‡ tek definice polo‘ek menu
         dw        SB1MLHlp                 ; adresa tabulky text– n povˆdy
         dw        Hlp@StrucnaSyntaxeOznaceniSouboru ; ‡¡slo str nky velk‚ n povˆdy
         dw        SB1MLBlk                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        SB1MLTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        22                       ; po‡ te‡n¡ pozice okna
         db        7                        ; po‡ te‡n¡ © dek okna
         db        40                       ; ¨¡©ka okna
         db        8                        ; v˜¨ka okna

         dw        255                      ; maxim ln¡ d‚lka © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        1                        ; celkov˜ po‡et © dk–
         dw        1                        ; po‡et zobrazen˜ch © dk–

         db        bit2                     ; maska zad van˜ch znak–
         db        0,'      '               ; zak zan‚ znaky

         db        HistSel                  ; identifik tor historie
         db        1                        ; po‡et p©edvoleb

         dw        9                        ; d‚lka p©edvolby
         dd        AllSel                   ; p©edvolba

SB1MLPol db        bit6,19,'Soubory k ozna‡en¡:'
         db        0,0
         db        bit6+bit7,0
         db        1,5,'Ozna‡'
         db        1,6,'N vrat'

SB1MLBlk db        0,0,0                    ; blokovac¡ tabulka

SB1MLTit db        8,'ozna‡en¡'

HelpS    SEGMENT   BYTE PUBLIC
SB1MLHlp db        3,1
         dw        MenuSelH

         db        4,'O',1
         dw        SB1MLHl1

         db        3,1
         dw        MenuHlP1
HelpS    ENDS

SB1MLHl1 db        40,'zna‡en¡ soubor– podle zadan‚ specifikace'

AllSel   db        '*.* /"" u'

; -----------------------------------------------------------------------------
;        Definice © dkov‚ho menu - volba soubor– k odzna‡en¡
; -----------------------------------------------------------------------------

SB2MnLin label     byte                   ;* menu odzna‡en¡ soubor–

         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        3                        ; po‡et platn˜ch polo‘ek menu
         dw        5                        ; celkov˜ po‡et polo‘ek menu

         dw        SB2MLPol                 ; za‡ tek definice polo‘ek menu
         dw        SB2MLHlp                 ; adresa tabulky text– n povˆdy
         dw        Hlp@StrucnaSyntaxeOznaceniSouboru ; ‡¡slo str nky velk‚ n povˆdy
         dw        SB1MLBlk                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        SB2MLTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        22                       ; po‡ te‡n¡ pozice okna
         db        7                        ; po‡ te‡n¡ © dek okna
         db        40                       ; ¨¡©ka okna
         db        8                        ; v˜¨ka okna

         dw        255                      ; maxim ln¡ d‚lka © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        1                        ; celkov˜ po‡et © dk–
         dw        1                        ; po‡et zobrazen˜ch © dk–

         db        bit2                     ; maska zad van˜ch znak–
         db        0,'      '               ; zak zan‚ znaky

         db        HistSel                  ; identifik tor historie
         db        1                        ; po‡et p©edvoleb

         dw        9                        ; d‚lka p©edvolby
         dd        AllSel                   ; p©edvolba

SB2MLPol db        bit6,20,'Soubory k odzna‡en¡:'
         db        0,0
         db        bit6+bit7,0
         db        1,6,'Odzna‡'
         db        1,6,'N vrat'

;SB2MLBlk db        0,0,0                    ; blokovac¡ tabulka

SB2MLTit db        9,'odzna‡en¡'

HelpS    SEGMENT   BYTE PUBLIC
SB2MLHlp db        3,1
         dw        MenuSelH

         db        12,'Zru¨en¡ o',1
         dw        SB1MLHl1

         db        3,1
         dw        MenuHlP1
HelpS    ENDS

; -----------------------------------------------------------------------------
;        Definice © dkov‚ho menu - volba soubor– k inverzi ozna‡en¡
; -----------------------------------------------------------------------------

SB3MnLin label     byte                   ;* menu inverze ozna‡en¡ soubor–

         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        3                        ; po‡et platn˜ch polo‘ek menu
         dw        5                        ; celkov˜ po‡et polo‘ek menu

         dw        SB3MLPol                 ; za‡ tek definice polo‘ek menu
         dw        SB3MLHlp                 ; adresa tabulky text– n povˆdy
         dw        Hlp@StrucnaSyntaxeOznaceniSouboru ; ‡¡slo str nky velk‚ n povˆdy
         dw        SB1MLBlk                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        SB3MLTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        22                       ; po‡ te‡n¡ pozice okna
         db        7                        ; po‡ te‡n¡ © dek okna
         db        40                       ; ¨¡©ka okna
         db        8                        ; v˜¨ka okna

         dw        255                      ; maxim ln¡ d‚lka © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        1                        ; celkov˜ po‡et © dk–
         dw        1                        ; po‡et zobrazen˜ch © dk–

         db        bit2                     ; maska zad van˜ch znak–
         db        0,'      '               ; zak zan‚ znaky

         db        HistSel                  ; identifik tor historie
         db        1                        ; po‡et p©edvoleb

         dw        9                        ; d‚lka p©edvolby
         dd        AllSel                   ; p©edvolba

SB3MLPol db        bit6,27,'Soubory k inverzi ozna‡en¡:'
         db        0,0
         db        bit6+bit7,0
         db        1,6,'Proveƒ'
         db        1,6,'N vrat'

;SB3MLBlk db        0,0,0                    ; blokovac¡ tabulka

SB3MLTit db        16,'inverze ozna‡en¡'

HelpS    SEGMENT   BYTE PUBLIC
SB3MLHlp db        3,1
         dw        MenuSelH

         db        12,'Inverze o',1
         dw        SB1MLHl1

         db        3,1
         dw        MenuHlP1
HelpS    ENDS

; -----------------------------------------------------------------------------
;        filtr soubor– - vertik ln¡ podmenu
; -----------------------------------------------------------------------------
;þ
SFMnVert label     byte                   ;* menu filtru soubor–
         db        2                        ; typ menu - vertik ln¡ podmenu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka volby
         dw        12                       ; po‡et platn˜ch polo‘ek menu
         dw        14                       ; celkov˜ po‡et polo‘ek menu

         dw        SFMnVPol                 ; adresa defini‡n¡ tabulky polo‘ek
         dw        SFMnVHlp                 ; adresa tabulky text– n povˆdy
         dw        Hlp@MenuKonverzeSouboru  ; ‡¡slo str nky velk‚ n povˆdy
         dw        SFMnVBlk                 ; adresa blokovac¡ tabulky
         dw        SFMnVSwc                 ; adresa tabulky p©ep¡na‡–
         dw        SFMnVTit                 ; adresa titulu okna
         dw        SFMnVExe                 ; tabulka obsluh voleb menu
         dw        SFMnVMnu                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        36                       ; po‡ te‡n¡ pozice
         db        2                        ; po‡ te‡n¡ © dek
         db        21                       ; ¨¡©ka
         db        16                       ; v˜¨ka

SFMnVPol db        1,17,'Soubor v k¢du '
SFMnVPl1 db        'KAM'
         db        1,17,'V˜stupn¡ k¢d  '
SFMnVPl2 db        '-"-'
         db        bit6+bit7,0
         db        1+bit7,6,'Mezery'
         db        1+bit7,10,'Tabul tory'
         db        1,17,'Pozic          '
SFMnVPl3 db        ' 8'
         db        1+bit7,13,'N hrada textu'
         db        2+bit7,13,'vElk  p¡smena'
         db        2+bit7,12,'mAl  p¡smena'
         db        1+bit7,11,'Datum a ‡as'
         db        bit6+bit7,0
         db        1,6,'Kurzor'
         db        1,8,'Ozna‡en‚'
         db        1,6,'Zadan‚'

SFMnVBlk db        0,0,0,0,0,0,0,0,0,0,0,0
SFMnVSwc db        0,0,0,0,0,0
SFMnVTit db        5,'filtr'

HelpS    SEGMENT   BYTE PUBLIC
SFMnVHlp db        90,'Volba vstupn¡ho k¢du souboru: ASCII, IBM, Kamenick˜ch, Latin 2, KOI 8, Windows'
         db        91,'Konverze na ASCII, IBM, Kamenick˜ch, Latin 2, KOI 8, Windows, -"- (bez zmˆny)'
         db        53,'V¨echny tabul tory v souboru budou nahrazeny mezerami'
         db        54,'Nadbyte‡n‚ mezery v souboru budou nahrazeny tabul tory'
         db        75,'Nastaven¡ po‡tu pozic na tabul tor (pro operaci n hrady tabul tor– a mezer)'
         db        74,'N hrada textu podle zadan‚ specifikace (rozli¨uj¡ se velk  a mal  p¡smena)'
         db        52,'V¨echna mal  p¡smena budou nahrazena velk˜mi p¡smeny'
         db        52,'V¨echna velk  p¡smena budou nahrazena mal˜mi p¡smeny'
         db        42,'Bude zachov no p–vodn¡ datum a ‡as souboru'
         db        52,'Bude konvertov n soubor, na kter‚m je um¡stˆn kurzor'
         db        35,'Budou konvertov ny ozna‡en‚ soubory'
         db        51,'Budou konvertov ny soubory podle bli‘¨¡ specifikace'

TabTxt1  db        61,'Zadejte po‡et pozic na tabul tor 1 a‘ 99 (standardnˆ 8)'
HelpS    ENDS

SFMnVExe label     dword                    ; obsluhy voleb
         dd        FiltrS                   ; vstupn¡ k¢d
         dd        FiltrV                   ; v˜stupn¡ k¢d
         dd        FiltrM                   ; mezery
         dd        FiltrT                   ; tabul tory
         dd        FiltrP                   ; pozic
         dd        FiltrN                   ; n hrada textu
         dd        FiltrU                   ; velk  p¡smena
         dd        FiltrD                   ; mal  p¡smena
         dd        FiltrC                   ; datum a ‡as
         dd        FiltrK                   ; kurzor
         dd        FiltrO                   ; ozna‡en‚
         dd        FiltrZ                   ; zadan‚

SFMnVMnu label     word                     ; adresy podmenu
         dw        SFSMVert                 ; vstupn¡ k¢d
         dw        SFVMVert                 ; v˜stupn¡ k¢d
         dw        0                        ; mezery
         dw        0                        ; tabul tory
         dw        0                        ; pozic
         dw        0                        ; n hrada textu
         dw        0                        ; velk  p¡smena
         dw        0                        ; mal  p¡smena
         dw        0                        ; datum a ‡as
         dw        0                        ; kurzor
         dw        0                        ; ozna‡en‚
         dw        0                        ; zadan‚

; -----------------------------------------------------------------------------
;        volba vstupn¡ho k¢du souboru
; -----------------------------------------------------------------------------

SFSMVert label     byte

         db        2                        ; typ menu - vertik ln¡ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka volby
         dw        6                        ; po‡et platn˜ch polo‘ek menu
         dw        6                        ; celkov˜ po‡et polo‘ek menu

         dw        SFSMVPol                 ; adresa defini‡n¡ tabulky polo‘ek
         dw        SFSMVHlp                 ; adresa tabulky text– n povˆdy
         dw        Hlp@VolbaVstupnihoKoduKonverzeSouboru ; ‡¡slo str nky velk‚ n povˆdy
         dw        SFSMVBlk                 ; adresa blokovac¡ tabulky
         dw        SFSMVSwc                 ; adresa tabulky p©ep¡na‡–
         dw        SFSMVTit                 ; adresa titulu okna
         dw        SFSMVExe                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        43                       ; po‡ te‡n¡ pozice
         db        3                        ; po‡ te‡n¡ © dek
         db        21                       ; ¨¡©ka
         db        8                        ; v˜¨ka

SFSMVPol db        1+bit7,5,'ASCII'
         db        1+bit7,3,'IBM'
         db        1+bit7,11,'Kamenick˜ch'
         db        1+bit7,7,'Latin 2'
         db        2+bit7,5,'KOI 8'
         db        1+bit7,7,'WINDOWS'

SFSMVBlk db        0,0,0,0,0,0
SFSMVSwc db        0,0,0,0,0,0
SFSMVTit db        11,'vstupn¡ k¢d'

HelpS    SEGMENT   BYTE PUBLIC
SFSMVHlp db        74,'Soubor nen¡ v n rodn¡m k¢du - znaky bez diakritiky (z kladn¡ ASCII sada)'
         db        68,'Soubor je v k¢du IBM (omezen  diakritika: ‚,, ,¡,¢,£)'
         db        56,'Soubor je v n rodn¡m k¢du brat©¡ Kamenick˜ch (KEYBCS2)'
         db        35,'Soubor je v n rodn¡m k¢du Latin 2'
         db        55,'Soubor je v n rodn¡m k¢du KOI 8 (k¢d editoru TEXT602)'
         db        40,'Soubor je v n rodn¡m k¢du WINDOWS 1250'
HelpS    ENDS

SFSMVExe label     dword                    ; obsluhy voleb
         dd        FiltrS1                  ; ASCII
         dd        FiltrS1                  ; IBM
         dd        FiltrS1                  ; Kamenick˜ch
         dd        FiltrS1                  ; Latin 2
         dd        FiltrS1                  ; KOI 8
         dd        FiltrS1                  ; WINDOWS

; -----------------------------------------------------------------------------
;        volba v˜stupn¡ho k¢du souboru
; -----------------------------------------------------------------------------

SFVMVert label     byte

         db        2                        ; typ menu - vertik ln¡ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka volby
         dw        7                        ; po‡et platn˜ch polo‘ek menu
         dw        7                        ; celkov˜ po‡et polo‘ek menu

         dw        SFVMVPol                 ; adresa defini‡n¡ tabulky polo‘ek
         dw        SFVMVHlp                 ; adresa tabulky text– n povˆdy
         dw        Hlp@VolbaVystupnihoKoduKonverzeSouboru ; ‡¡slo str nky velk‚ n povˆdy
         dw        SFVMVBlk                 ; adresa blokovac¡ tabulky
         dw        SFVMVSwc                 ; adresa tabulky p©ep¡na‡–
         dw        SFVMVTit                 ; adresa titulu okna
         dw        SFVMVExe                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        43                       ; po‡ te‡n¡ pozice
         db        3                        ; po‡ te‡n¡ © dek
         db        21                       ; ¨¡©ka
         db        9                        ; v˜¨ka

SFVMVPol db        1+bit7,5,'ASCII'
         db        1+bit7,3,'IBM'
         db        1+bit7,11,'Kamenick˜ch'
         db        1+bit7,7,'Latin 2'
         db        2+bit7,5,'KOI 8'
         db        1+bit7,7,'WINDOWS'
         db        1+bit7,8,'Nezmˆnˆn'

SFVMVBlk db        0,0,0,0,0,0,0
SFVMVSwc db        0,0,0,0,0,0,0
SFVMVTit db        12,'v˜stupn¡ k¢d'

HelpS    SEGMENT   BYTE PUBLIC
SFVMVHlp db        37,'Diakritika bude ze souboru odstranˆna'
         db        83,'Soubor bude zkonvertov n na k¢d IBM (omezen  diakritika: ‚,, ,¡,¢,£)'
         db        70,'Soubor bude zkonvertov n na n rodn¡ k¢d brat©¡ Kamenick˜ch (KEYBCS2)'
         db        49,'Soubor bude zkonvertov n na n rodn¡ k¢d Latin 2'
         db        69,'Soubor bude zkonvertov n na n rodn¡ k¢d KOI 8 (k¢d editoru TEXT602)'
         db        54,'Soubor bude zkonvertov n na n rodn¡ k¢d WINDOWS 1250'
         db        25,'K¢d souboru nebude zmˆnˆn'
HelpS    ENDS

SFVMVExe label     dword                    ; obsluhy voleb
         dd        FiltrV1                  ; ASCII
         dd        FiltrV1                  ; IBM
         dd        FiltrV1                  ; Kamenick˜ch
         dd        FiltrV1                  ; Latin 2
         dd        FiltrV1                  ; KOI 8
         dd        FiltrV1                  ; Windows
         dd        FiltrV1                  ; nezmˆnˆn

; -----------------------------------------------------------------------------
;        Definice © dkov‚ho menu - volba soubor– k filtraci
; -----------------------------------------------------------------------------

SFZMLin  label     byte

         db        3                        ; typ menu - © dkov‚ podmenu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        3                        ; po‡et platn˜ch polo‘ek menu
         dw        5                        ; celkov˜ po‡et polo‘ek menu

         dw        SFZMLPol                 ; za‡ tek definice polo‘ek menu
         dw        SFZMLHlp                 ; adresa tabulky text– n povˆdy
         dw        Hlp@VyberSouboru         ; ‡¡slo str nky velk‚ n povˆdy
         dw        SFZMLBlk                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        SFZMLTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        23                       ; po‡ te‡n¡ pozice okna
         db        7                        ; po‡ te‡n¡ © dek okna
         db        46                       ; ¨¡©ka okna
         db        8                        ; v˜¨ka okna

         dw        255                      ; maxim ln¡ d‚lka © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        1                        ; celkov˜ po‡et © dk–
         dw        1                        ; po‡et zobrazen˜ch © dk–

         db        bit2                     ; maska zad van˜ch znak–
         db        0,'      '               ; zak zan‚ znaky

         db        HistSel                  ; identifik tor historie
         db        1                        ; po‡et p©edvoleb

         dw        3                        ; d‚lka p©edvolby
         dd        All                      ; p©edvolba

; ------ polo‘ky voleb

SFZMLPol db        bit6,28,'Zadejte soubory ke konverzi:'
         db        0,0
         db        bit6+bit7,0
         db        1,6,'Proveƒ'
         db        1,6,'N vrat'

SFZMLBlk db        0,0,0                    ; blokovac¡ tabulka

SFZMLTit db        6,'zadan‚'

; ------ n povˆda

HelpS    SEGMENT   BYTE PUBLIC
SFZMLHlp db        3,1
         dw        MenuFndH
         db        46,'Zkonvertov n¡ soubor– podle zadan‚ specifikace'
         db        3,1
         dw        MenuHlP1
HelpS    ENDS

; -----------------------------------------------------------------------------
;        Definice © dkov‚ho menu - volba textu k hled n¡ p©i konverzi
; -----------------------------------------------------------------------------

SF1MnLin label     byte                   ;* volba hled n¡ textu

         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        3                        ; po‡et platn˜ch polo‘ek menu
         dw        5                        ; celkov˜ po‡et polo‘ek menu

         dw        SF1MLPol                 ; za‡ tek definice polo‘ek menu
         dw        SF1MLHlp                 ; adresa tabulky text– n povˆdy
         dw        Hlp@MenuKonverzeSouboru  ; ‡¡slo str nky velk‚ n povˆdy
         dw        SF1MLBlk                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        SF1MLTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        20                       ; po‡ te‡n¡ pozice okna
         db        7                        ; po‡ te‡n¡ © dek okna
         db        48                       ; ¨¡©ka okna
         db        8                        ; v˜¨ka okna

         dw        TextFndX                 ; maxim ln¡ d‚lka © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        1                        ; celkov˜ po‡et © dk–
         dw        1                        ; po‡et zobrazen˜ch © dk–

         db        bit2                     ; maska zad van˜ch znak–
         db        0,'      '               ; zak zan‚ znaky

         db        HistFind                 ; identifik tor historie
         db        0                        ; po‡et p©edvoleb

; ------ polo‘ky voleb

SF1MLPol db        bit6,28,'Text, kter˜ m  b˜t nahrazen:'
         db        0,0
         db        bit6+bit7,0
         db        1,8,'Pokra‡uj'
         db        1,6,'N vrat'

SF1MLBlk db        0,0,0                    ; blokovac¡ tabulka

SF1MLTit db        6,'hledat'

; ------ n povˆda

HelpS    SEGMENT   BYTE PUBLIC
SF1MLHlp db        66,'Zadejte text, kter˜ m  b˜t v souborech nahrazen (tj. hledan˜ text)'
         db        39,'Pokra‡ov n¡ zad n¡m nahrazuj¡c¡ho textu'
         db        3,1
         dw        MenuHlP1
HelpS    ENDS

; -----------------------------------------------------------------------------
;        Definice © dkov‚ho menu - volba n hradn¡ho textu p©i konverzi
; -----------------------------------------------------------------------------

SF2MnLin label     byte                   ;* volba n hrady textu

         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        3                        ; po‡et platn˜ch polo‘ek menu
         dw        5                        ; celkov˜ po‡et polo‘ek menu

         dw        SF2MLPol                 ; za‡ tek definice polo‘ek menu
         dw        SF2MLHlp                 ; adresa tabulky text– n povˆdy
         dw        Hlp@MenuKonverzeSouboru  ; ‡¡slo str nky velk‚ n povˆdy
         dw        SF2MLBlk                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        SF2MLTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        15                       ; po‡ te‡n¡ pozice okna
         db        7                        ; po‡ te‡n¡ © dek okna
         db        48                       ; ¨¡©ka okna
         db        8                        ; v˜¨ka okna

         dw        TextSubX                 ; maxim ln¡ d‚lka © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        1                        ; celkov˜ po‡et © dk–
         dw        1                        ; po‡et zobrazen˜ch © dk–

         db        bit2                     ; maska zad van˜ch znak–
         db        0,'      '               ; zak zan‚ znaky

         db        HistFind                 ; identifik tor historie
         db        0                        ; po‡et p©edvoleb

; ------ polo‘ky voleb

SF2MLPol db        bit6,41,'Text, kter˜m bude nahrazen nalezen˜ text:'
         db        0,0
         db        bit6+bit7,0
         db        1,8,'Pokra‡uj'
         db        1,6,'N vrat'

SF2MLBlk db        0,0,0                    ; blokovac¡ tabulka

SF2MLTit db        8,'nahradit'

; ------ n povˆda

HelpS    SEGMENT   BYTE PUBLIC
SF2MLHlp db        60,'Zadejte text, kter˜m bude v souborech nahrazen nalezen˜ text'
         db        41,'Zah jen¡ konverze soubor– a n hrady textu'
         db        3,1
         dw        MenuHlP1
HelpS    ENDS

; -----------------------------------------------------------------------------
;        nalezen¡ souboru bˆhem konverze se zad n¡m textem
; -----------------------------------------------------------------------------

SF4MnLin label     byte

         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka volby
         dw        4                        ; po‡et platn˜ch polo‘ek menu
         dw        12                       ; celkov˜ po‡et polo‘ek menu

         dw        SF4MnPol                 ; adresa defini‡n¡ tabulky polo‘ek
         dw        SF4MnHlp                 ; adresa tabulky text– n povˆdy
         dw        Hlp@MenuKonverzeSouboru  ; ‡¡slo str nky velk‚ n povˆdy
         dw        SF4MnBlk                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        SF4MnTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        6                        ; po‡ te‡n¡ pozice
         db        7                        ; po‡ te‡n¡ © dek
         db        60                       ; ¨¡©ka
         db        13                       ; v˜¨ka

         dw        255                      ; maxim ln¡ d‚lka © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        0                        ; celkov˜ po‡et © dk–
         dw        0                        ; po‡et zobrazen˜ch © dk–

         db        bit2                     ; maska zad van˜ch znak–
         db        0,'      '               ; dopl¤uj¡c¡ zak zan‚ znaky

         db        0                        ; identifik tor historie
         db        0                        ; po‡et p©edvoleb

SF4MnPol db        bit6,33,'Nalezen soubor ',0,1
         dw        SRMnuFil                 ; buffer jm‚na souboru
         db        0,' ke konverzi.'

         db        bit6,0

         db        bit6,14,'Velikost: ',0,1
         dw        SRMnuSiz                 ; buffer velikosti

         db        bit6,14,'   Datum: ',0,1
         dw        SRMnuDat                 ; buffer data

         db        bit6,14,'     €as: ',0,1
         dw        SRMnuTim                 ; buffer ‡asu

         db        bit6,0

         db        bit6,38,'P©ejete si tento soubor zkonvertovat ?'

         db        bit6+bit7,0
         db        1,11,'Konvertovat'
         db        1,5,'Dal¨¡'
         db        1,7,'V¨echny'
         db        1,8,'P©eru¨it'

SF4MnBlk db        0,0,0,0

SF4MnTit db        8,'konverze'

HelpS    SEGMENT   BYTE PUBLIC
SF4MnHlp db        27,'Konverze nalezen‚ho souboru'
         db        48,'Pokra‡ov n¡ d le bez konverze nalezen‚ho souboru'
         db        47,'Konverze v¨ech n sleduj¡c¡ch soubor– bez dotazu'
         db        3,1
         dw        MenuHlP2
HelpS    ENDS

;; -----------------------------------------------------------------------------
;;        chybov‚ hl ¨en¡ - soubor nelze zkonvertovat
;; -----------------------------------------------------------------------------
;
;ChbErF2  label     byte
;         db        3                        ; typ menu - © dkov‚ menu
;
;         db        0                        ; hladina k zobrazen¡ menu
;         dw        1                        ; aktivn¡ polo‘ka menu
;         dw        2                        ; po‡et platn˜ch polo‘ek menu
;         dw        5                        ; celkov˜ po‡et polo‘ek menu
;
;         dw        ChbErF2P                 ; za‡ tek definice polo‘ek menu
;         dw        ChbErF2H                 ; adresa tabulky text– n povˆdy
;         dw        Hlp@MenuKonverzeSouboru  ; ‡¡slo str nky velk‚ n povˆdy
;         dw        ChbErF2B                 ; adresa blokovac¡ tabulky
;         dw        0                        ; adresa tabulky p©ep¡na‡–
;         dw        ChbErF2T                 ; adresa titulu okna
;         dw        LinMenTE                 ; tabulka obsluh voleb menu
;         dw        LinMenTM                 ; tabulka adres podmenu
;         dd        0                        ; n vratov  adresa p©i p©eru¨en¡
;
;         db        20                       ; po‡ te‡n¡ pozice okna
;         db        7                        ; po‡ te‡n¡ © dek okna
;         db        45                       ; ¨¡©ka okna
;         db        8                        ; v˜¨ka okna
;
;         dw        255                      ; maxim ln¡ d‚lka textu © dku
;         dw        0                        ; prvn¡ zobrazen˜ © dek
;         dw        0                        ; aktivn¡ zobrazen˜ © dek
;         dw        0                        ; celkov˜ po‡et © dk–
;         dw        0                        ; po‡et zobrazen˜ch © dk–
;
;         db        bit3                     ; maska zad van˜ch znak–
;         db        0,'      '               ; zak zan‚ znaky
;
;         db        0                        ; historie specifikac¡ soubor–
;         db        0                        ; po‡et p©edvoleb
;
;; ------ polo‘ky voleb
;
;ChbErF2P db        bit6,6,0,'CHYBA'
;         db        bit6,33,'Soubor ',0,1
;         dw        SRMnuFil                 ; buffer jm‚na souboru
;         db        0,' nelze zkonvertovat !'
;         db        bit6+bit7,0
;         db        1,5,'Dal¨¡'
;         db        1,8,'P©eru¨it'
;
;ChbErF2T db        13,'chyba operace'
;
;ChbErF2B db        0,0                      ; blokovac¡ tabulka
;
;HelpS    SEGMENT   BYTE PUBLIC
;ChbErF2H db        36,'Pokra‡ov n¡ konverz¡ dal¨¡ho souboru'
;         db        3,1
;         dw        MenuHlP2
;HelpS    ENDS

; -----------------------------------------------------------------------------
;        data pro konverzi
; -----------------------------------------------------------------------------
;þ
; ------ parametry pro filtr soubor–

KonvTxt1 db        12,'Konvertuji ',0

KodyTxtT label     byte                     ; tabulka zkratek k¢d–
         db        'ASC'                    ; 0: ASCII
         db        'IBM'                    ; 1: IBM
         db        'KAM'                    ; 2: Kamenick˜ch
         db        'LAT'                    ; 3: Katin 2
         db        'KOI'                    ; 4: KOI 8
         db        'WIN'                    ; 5: Windows
         db        '-"-'                    ; 6: shodn˜

;TabPozic db        8                        ; po‡et pozic na tabul tor 1 a‘ 99
;
;InpKod   db        0                        ; vstupn¡ k¢d souboru
;                                            ;   0 = ASCII
;                                            ;   1 = IBM
;                                            ;   2 = Kamenick˜ch
;                                            ;   3 = Latin 2
;                                            ;   4 = KOI 8
;                                            ;   5 = Windows
;
;OutKod   db        6                        ; v˜stupn¡ k¢d souboru
;                                            ;   0 = ASCII
;                                            ;   1 = IBM
;                                            ;   2 = Kamenick˜ch
;                                            ;   3 = Latin 2
;                                            ;   4 = KOI 8
;                                            ;   5 = Windows
;                                            ;   6 = nezmˆnˆn

IOKod    dw        0                        ; vstupn¡ a v˜stupn¡ k¢d bitovˆ
                                            ;      0: (1) vstupn¡ k¢d
                                            ;              (bit0 a‘ bit5)
                                            ;      1: (2) v˜stupn¡ k¢d
                                            ;              (bit0 a‘ bit5)
                                            ;  (pomocn˜ odvozen˜ registr)

;FiltrPar db        0                        ; parametry filtru
;                                            ;   bit 0: 1=tabul tory na mezery
;                                            ;   bit 1: 1=mezery na tabul tory
;                                            ;   bit 2: 1=n hrada textu
;                                            ;   bit 3: 1=mal  p¡smena na velk 
;                                            ;   bit 4: 1=velk  p¡smena na mal 
;                                            ;   bit 5: 1=zachov n datum a ‡as
;                                            ;   bit 7: 1=konverze bez dotazu

; ------ ukazatele buffer– (z pisov˜ buffer je v‘dy od 0)

FiltSize dw        0                        ; velikost ‡tec¡ho/z pis. bufferu
FiltWrit dw        0                        ; z pisov  adresa do bufferu
FiltRead dw        0                        ; za‡ tek ‡tec¡ho bufferu
KonvPoz  db        0                        ; zbyl˜ po‡et pozic na tabul tor
KonvSpc  db        0                        ; po‡et nep©enesen˜ch mezer
KonvEqu  db        0                        ; £schovan  d‚lka ‡ sti shody

; ------ parametry pro n hradu textu

;TextFndN dw        0                        ; d‚lka textu k hled n¡
;TextFnd  label     byte
;         db        255 dup(0)               ; text k hled n¡
;TextSubN dw        0                        ; d‚lka textu k n hradˆ
;TextSub  label     byte
;         db        255 dup(0)               ; text k n hradˆ

; -----------------------------------------------------------------------------
;        Tisk soubor– - vertik ln¡ podmenu
; -----------------------------------------------------------------------------
;þ
STMnVert label     byte                   ;* menu tisku soubor–

         db        2                        ; typ menu - vertik ln¡ podmenu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka volby
         dw        11                       ; po‡et platn˜ch polo‘ek menu
         dw        13                       ; celkov˜ po‡et polo‘ek menu

         dw        STMnVPol                 ; adresa defini‡n¡ tabulky polo‘ek
         dw        STMnVHlp                 ; adresa tabulky text– n povˆdy
         dw        Hlp@MenuTiskSouboru      ; ‡¡slo str nky velk‚ n povˆdy
         dw        STMnVBlk                 ; adresa blokovac¡ tabulky
         dw        STMnVSwc                 ; adresa tabulky p©ep¡na‡–
         dw        STMnVTit                 ; adresa titulu okna
         dw        STMnVExe                 ; tabulka obsluh voleb menu
         dw        STMnVMnu                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        36                       ; po‡ te‡n¡ pozice
         db        3                        ; po‡ te‡n¡ © dek
         db        21                       ; ¨¡©ka
         db        15                       ; v˜¨ka

STMnVPol db        1,18,'Tisk na          ',16
STMnVPl1 db        bit6+bit7,0
         db        1,17,'Netisknout       '
STMnVPl2 db        1,17,'Str nkov n¡      '
STMnVPl3 db        1,17,'D‚lka str nky    '
STMnVPl4 db        1,17,'Lev˜ okraj       '
STMnVPl5 db        1,17,'Prav˜ okraj      '
STMnVPl6 db        1+bit7,8,'Hlavi‡ka'
         db        1+bit7,13,'V˜mˆna pap¡ru'
         db        bit6+bit7,0
         db        1,6,'Kurzor'
         db        1,8,'Ozna‡en‚'
         db        1,6,'Zadan‚'

STMnVBlk db        0,0,0,0,0,0,0,0,0,0,0
STMnVSwc db        0,0

STMnVTit db        4,'tisk'

HelpS    SEGMENT   BYTE PUBLIC
STMnVHlp db        65,'Volba v˜stupn¡ho tiskov‚ho za©¡zen¡ (PRN, LPT, COM, Disk)'
         db        78,'Volba po‡tu p©esko‡en˜ch str nek 0... (po‡et str nek, kter‚ nebudou ti¨tˆny)'
         db        64,'Volba po‡ tku ‡¡slov n¡ str nek 1... (tj. ‡¡slo prvn¡ str nky)'
         db        80,'Volba celkov‚ho po‡tu © dk– na str nku v‡etnˆ hlavi‡ky (0=voln  d‚lka str nek)'
         db        60,'Volba lev‚ho okraje (po‡ te‡n¡ pozice textu na © dku 1...)'
         db        73,'Volba prav‚ho okraje (maxim ln¡ konec © dku 1...; 0=nen¡ prav˜ okraj)'
         db        76,'Bude ti¨tˆna hlavi‡ka str nky (2 © dky): jm‚no souboru, ‡¡slo str nky, datum'
         db        58,'Pozastaven¡ tisku po ka‘d‚ str nce, vy‘ d n¡ v˜mˆny pap¡ru'
         db        25,'Tisk souboru pod kurzorem'
         db        36,'Tisk ozna‡en˜ch soubor– (a adres ©–)'
         db        37,'Tisk soubor– podle bli‘¨¡ specifikace'
HelpS    ENDS

STMnVExe label     dword
         dd        AWMMnSTT                 ; Tisk na
         dd        AWMMnSTN                 ; Netisknout
         dd        AWMMnSTS                 ; Str nkov n¡
         dd        AWMMnSTD                 ; D‚lka str nky
         dd        AWMMnSTL                 ; Lev˜ okraj
         dd        AWMMnSTR                 ; Prav˜ okraj
         dd        AWMMnSTH                 ; Hlavi‡ka
         dd        AWMMnSTJ                 ; V˜mˆna pap¡ru
         dd        TiskSoub                 ; Kurzor
         dd        TiskSoub                 ; Ozna‡en‚
         dd        TiskSoub                 ; Zadan‚

STMnVMnu label     word
         dw        STTMVert                 ; Tisk na
         dw        0                        ; Netisknout
         dw        0                        ; Str nkov n¡
         dw        0                        ; D‚lka str nky
         dw        0                        ; Lev˜ okraj
         dw        0                        ; Prav˜ okraj
         dw        0                        ; Hlavi‡ka
         dw        0                        ; V˜mˆna pap¡ru
         dw        0                        ; Kurzor
         dw        0                        ; Ozna‡en‚
         dw        0                        ; Zadan‚

TiskTxt  db        8,'Tisknu ',0

HelpS    SEGMENT   BYTE PUBLIC
STMnVHl1 db        64,'Zadejte po‡et neti¨tˆn˜ch (p©esko‡en˜ch) str nek (0 a‘ 9999)'
STMnVHl2 db        71,'Zadejte ‡¡slo prvn¡ str nky = po‡ tek ‡¡slov n¡ str nek (1 a‘ 9999)'
STMnVHl3 db        77,'Zadejte po‡et © dk– na str nku (0 a‘ 999, 0=nen¡ omezen  d‚lka str nky)'
STMnVHl4 db        66,'Zadejte po‡ te‡n¡ pozici k vyti¨tˆn¡ textu na © dku (1 a‘ 999)'
STMnVHl5 db        78,'Zadejte prav˜ okraj © dku = maxim ln¡ pozice na © dku (0 a‘ 999, 0=nen¡)'
HelpS    ENDS

; -----------------------------------------------------------------------------
;        zad n¡ v˜stupn¡ho tiskov‚ho za©¡zen¡
; -----------------------------------------------------------------------------

STTMVert label     byte                   ;* menu volby tiskov‚ho za©¡zen¡

         db        2                        ; typ menu - vertik ln¡ podmenu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka volby
         dw        9                        ; po‡et platn˜ch polo‘ek menu
         dw        9                        ; celkov˜ po‡et polo‘ek menu

         dw        STTMVPol                 ; adresa defini‡n¡ tabulky polo‘ek
         dw        STTMVHlp                 ; adresa tabulky text– n povˆdy
         dw        Hlp@VystupProTisk        ; ‡¡slo str nky velk‚ n povˆdy
         dw        STTMVBlk                 ; adresa blokovac¡ tabulky
         dw        STTMVSwc                 ; adresa tabulky p©ep¡na‡–
         dw        STTMVTit                 ; adresa titulu okna
         dw        STTMVExe                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        43                       ; po‡ te‡n¡ pozice
         db        3                        ; po‡ te‡n¡ © dek
         db        21                       ; ¨¡©ka
         db        11                       ; v˜¨ka

STTMVPol db        1+bit7,3,'PRN'
         db        1+bit7,7,'1: LPT1'
         db        1+bit7,7,'2: LPT2'
         db        1+bit7,7,'3: LPT3'
         db        1+bit7,7,'4: COM1'
         db        1+bit7,7,'5: COM2'
         db        1+bit7,7,'6: COM3'
         db        1+bit7,7,'7: COM4'
         db        1+bit7,4,'Disk'

STTMVBlk db        0,0,0,0,0,0,0,0,0
STTMVSwc db        0,0,0,0,0,0,0,0,0

STTMVTit db        7,'tisk na'

HelpS    SEGMENT   BYTE PUBLIC
STTMVHlp db        66,'Tisk na standardn¡ tiskov‚ za©¡zen¡ PRN (=paraleln¡ port LPT1)'

         db        42,1
         dw        STTMVHl1
         db        '1 (=standardn¡ tiskov‚ za©¡zen¡ PRN)'

         db        5,1
         dw        STTMVHl1
         db        '2'

         db        5,1
         dw        STTMVHl1
         db        '3'

         db        5,1
         dw        STTMVHl2
         db        '1'

         db        5,1
         dw        STTMVHl2
         db        '2'

         db        5,1
         dw        STTMVHl2
         db        '3'

         db        5,1
         dw        STTMVHl2
         db        '4'

         db        57,'Tisk do souboru $DOSMAN$.PRN v datov‚m adres ©i DosManu'
HelpS    ENDS

STTMVHl1 db        27,'Tisk na paraleln¡ port LPT'
STTMVHl2 db        25,'Tisk na s‚riov˜ port COM'

STTMVExe label     dword
         dd        AWMMSTT2                 ; PRN
         dd        AWMMSTT2                 ; LPT1
         dd        AWMMSTT2                 ; LPT2
         dd        AWMMSTT2                 ; LPT3
         dd        AWMMSTT2                 ; COM1
         dd        AWMMSTT2                 ; COM2
         dd        AWMMSTT2                 ; COM3
         dd        AWMMSTT2                 ; COM4
         dd        AWMMSTT2                 ; Disk

; -----------------------------------------------------------------------------
;        potvrzen¡ tisku dal¨¡ strany
; -----------------------------------------------------------------------------

STTXMLin label     byte                    ;* menu potvrzen¡ tisku dal¨¡ strany

         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka volby
         dw        2                        ; po‡et platn˜ch polo‘ek menu
         dw        5                        ; celkov˜ po‡et polo‘ek menu

         dw        STTXMPol                 ; adresa defini‡n¡ tabulky polo‘ek
         dw        STTXMHlp                 ; adresa tabulky text– n povˆdy
         dw        Hlp@MenuTiskSouboru      ; ‡¡slo str nky velk‚ n povˆdy
         dw        STTXMBlk                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        STTXMTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        6                        ; po‡ te‡n¡ pozice
         db        7                        ; po‡ te‡n¡ © dek
         db        45                       ; ¨¡©ka
         db        8                        ; v˜¨ka

         dw        255                      ; maxim ln¡ d‚lka © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        0                        ; celkov˜ po‡et © dk–
         dw        0                        ; po‡et zobrazen˜ch © dk–

         db        bit2                     ; maska zad van˜ch znak–
         db        0,'      '               ; dopl¤uj¡c¡ zak zan‚ znaky

         db        0                        ; identifik tor historie
         db        0                        ; po‡et p©edvoleb

STTXMPol db        bit6,25,'Prob¡h  tisk souboru ',0,1
         dw        SRMnuFil
         db        bit6,35,'Vlo‘te do tisk rny nov˜ list pap¡ru'
         db        bit6+bit7,0
         db        1,4,'D le'
         db        1,9,'P©eru¨en¡'

STTXMBlk db        0,0

STTXMTit db        7,'str nka '
STTXMTi2 db        '     '

HelpS    SEGMENT   BYTE PUBLIC
STTXMHlp db        50,'Pokra‡ov n¡ v tisku po vlo‘en¡ nov‚ho listu pap¡ru'
         db        15,'P©eru¨en¡ tisku'
HelpS    ENDS

; -----------------------------------------------------------------------------
;        Definice © dkov‚ho menu - volba soubor– k tisku
; -----------------------------------------------------------------------------

STTZMLin label     byte                   ;* menu

         db        3                        ; typ menu - © dkov‚ podmenu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        3                        ; po‡et platn˜ch polo‘ek menu
         dw        5                        ; celkov˜ po‡et polo‘ek menu

         dw        STTZMPol                 ; za‡ tek definice polo‘ek menu
         dw        STTZMHlp                 ; adresa tabulky text– n povˆdy
         dw        Hlp@VyberSouboru         ; ‡¡slo str nky velk‚ n povˆdy
         dw        STTZMBlk                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        STTZMTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        23                       ; po‡ te‡n¡ pozice okna
         db        7                        ; po‡ te‡n¡ © dek okna
         db        44                       ; ¨¡©ka okna
         db        8                        ; v˜¨ka okna

         dw        255                      ; maxim ln¡ d‚lka © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        1                        ; celkov˜ po‡et © dk–
         dw        1                        ; po‡et zobrazen˜ch © dk–

         db        bit2                     ; maska zad van˜ch znak–
         db        0,'      '               ; zak zan‚ znaky

         db        HistSel                  ; identifik tor historie
         db        1                        ; po‡et p©edvoleb

         dw        3                        ; d‚lka p©edvolby
         dd        All                      ; p©edvolba

; ------ polo‘ky voleb

STTZMPol db        bit6,19,'Vytisknout soubory:'
         db        0,0
         db        bit6+bit7,0
         db        1,6,'Tiskni'
         db        1,6,'N vrat'

STTZMBlk db        0,0,0                    ; blokovac¡ tabulka

STTZMTit db        4,'tisk'

; ------ n povˆda

HelpS    SEGMENT   BYTE PUBLIC
STTZMHlp db        3,1
         dw        MenuFndH
         db        42,'Vyti¨tˆn¡ soubor– podle zadan‚ specifikace'
         db        3,1
         dw        MenuHlP1
HelpS    ENDS

;; -----------------------------------------------------------------------------
;;        chybov‚ hl ¨en¡ - soubor nelze vytisknout
;; -----------------------------------------------------------------------------
;
;ChbErT2  label     byte
;         db        3                        ; typ menu - © dkov‚ menu
;
;         db        0                        ; hladina k zobrazen¡ menu
;         dw        1                        ; aktivn¡ polo‘ka menu
;         dw        2                        ; po‡et platn˜ch polo‘ek menu
;         dw        5                        ; celkov˜ po‡et polo‘ek menu
;
;         dw        ChbErT2P                 ; za‡ tek definice polo‘ek menu
;         dw        ChbErT2H                 ; adresa tabulky text– n povˆdy
;         dw        Hlp@MenuTiskSouboru      ; ‡¡slo str nky velk‚ n povˆdy
;         dw        ChbErT2B                 ; adresa blokovac¡ tabulky
;         dw        0                        ; adresa tabulky p©ep¡na‡–
;         dw        ChbErT2T                 ; adresa titulu okna
;         dw        LinMenTE                 ; tabulka obsluh voleb menu
;         dw        LinMenTM                 ; tabulka adres podmenu
;         dd        0                        ; n vratov  adresa p©i p©eru¨en¡
;
;         db        20                       ; po‡ te‡n¡ pozice okna
;         db        7                        ; po‡ te‡n¡ © dek okna
;         db        45                       ; ¨¡©ka okna
;         db        8                        ; v˜¨ka okna
;
;         dw        255                      ; maxim ln¡ d‚lka textu © dku
;         dw        0                        ; prvn¡ zobrazen˜ © dek
;         dw        0                        ; aktivn¡ zobrazen˜ © dek
;         dw        0                        ; celkov˜ po‡et © dk–
;         dw        0                        ; po‡et zobrazen˜ch © dk–
;
;         db        bit3                     ; maska zad van˜ch znak–
;         db        0,'      '               ; zak zan‚ znaky
;
;         db        0                        ; historie specifikac¡ soubor–
;         db        0                        ; po‡et p©edvoleb
;
;; ------ polo‘ky voleb
;
;ChbErT2P db        bit6,6,0,'CHYBA'
;         db        bit6,31,'Soubor ',0,1
;         dw        SRMnuFil                 ; buffer jm‚na souboru
;         db        0,' nelze vytisknout !'
;         db        bit6+bit7,0
;         db        1,5,'Dal¨¡'
;         db        1,8,'P©eru¨it'
;
;ChbErT2T db        13,'chyba operace'

; -----------------------------------------------------------------------------
;        chybov‚ hl ¨en¡ - chyba v˜stupu
; -----------------------------------------------------------------------------

ChbErTO  label     byte
         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        2                        ; po‡et platn˜ch polo‘ek menu
         dw        6                        ; celkov˜ po‡et polo‘ek menu

         dw        ChbErTOP                 ; za‡ tek definice polo‘ek menu
         dw        ChbErT2H                 ; adresa tabulky text– n povˆdy
         dw        Hlp@MenuTiskSouboru      ; ‡¡slo str nky velk‚ n povˆdy
         dw        ChbErT2B                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        ChbErTOT                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        23                       ; po‡ te‡n¡ pozice okna
         db        7                        ; po‡ te‡n¡ © dek okna
         db        49                       ; ¨¡©ka okna
         db        9                        ; v˜¨ka okna

         dw        255                      ; maxim ln¡ d‚lka textu © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        0                        ; celkov˜ po‡et © dk–
         dw        0                        ; po‡et zobrazen˜ch © dk–

         db        bit3                     ; maska zad van˜ch znak–
         db        0,'      '               ; zak zan‚ znaky

         db        0                        ; historie specifikac¡ soubor–
         db        0                        ; po‡et p©edvoleb

ChbErTOT db        11,'chyba tisku'

ChbErTOP db        bit6,6,0,'CHYBA'
         db        bit6,35,'Chyba v˜stupu na tiskov‚ za©¡zen¡ !'
         db        bit6,0
         db        bit6+bit7,0
         db        1,5,'Dal¨¡'
         db        1,8,'P©eru¨it'

ChbErT2B db        0,0                      ; blokovac¡ tabulka

HelpS    SEGMENT   BYTE PUBLIC
ChbErT2H db        34,'Pokra‡ov n¡ tiskem dal¨¡ho souboru'
         db        3,1
         dw        MenuHlP2
HelpS    ENDS

; ------ parametry k tisku

;TiskPres dw        0                        ; po‡et p©esko‡en˜ch str nek 0-9999
;TiskPoc  dw        1                        ; po‡ te‡n¡ ‡¡slo str nky 1-9999
;TiskDelk dw        66                       ; d‚lka str nky (© dk–) 1-999, 0 voln 
;TiskLeft dw        1                        ; lev˜ okraj 1-999
;TiskRght dw        80                       ; prav˜ okraj 1-999, 0 nen¡

TiskAStr dw        1                        ; ukazatel aktu ln¡ho ‡¡sla strany 1...9999
TiskARad dw        1                        ; ukazatel aktu ln¡ho ‡¡sla © dku 1...9999
                                            ;       (-1 = byl naposledy znak FF)
TiskAPoz dw        1                        ; ukazatel aktu ln¡ho ‡¡sla pozice 1...9999

TiskBff  db        0                        ; tiskov˜ buffer pro 1 znak

TiskOld  db        0                        ; uschovan˜ znak CR nebo LF (0=nen¡)

;TiskParm db        bit0+bit1                ; parametry pro tisk
;                                            ;   bit 0: 1=tisk z hlav¡
;                                            ;   bit 1: 1=‡ek n¡ na v˜mˆnu pap¡ru
;
;TiskOut  dw        bit0                     ; definice v˜stupn¡ho kan lu tisku
;                                            ;  bit 0: 1=PRN
;                                            ;  bit 1: 1=LPT1
;                                            ;  bit 2: 1=LPT2
;                                            ;  bit 3: 1=LPT3
;                                            ;  bit 4: 1=COM1
;                                            ;  bit 5: 1=COM2
;                                            ;  bit 6: 1=COM3
;                                            ;  bit 7: 1=COM4
;                                            ;  bit 8: 1=soubor $DOSMAN$.PRN

TiskStrn db        '- 00000 -'              ; buffer k dek¢dov n¡ ‡¡sla str nky

TiskLptT db        'LPT1',0
TiskComT db        'COM1',0
TiskSouT db        12,'$DOSMAN$.PRN'

TiskZTxt db        ' PRN'
         db        'LPT1'
         db        'LPT2'
         db        'LPT3'
         db        'COM1'
         db        'COM2'
         db        'COM3'
         db        'COM4'
         db        'Disk'

Data     ENDS
         END

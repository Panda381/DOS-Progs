
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                              F I L E  -  6
;
;               Obsluha soubor– - Porovn n¡ obsahu soubor–
;
; =============================================================================
;
;
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

INCLUDE  ASM\DEF.ASM

CodeFil  SEGMENT   BYTE PUBLIC
         ASSUME    cs:CodeFil,ds:Data

CompOSiz EQU       800h                     ; velikost v˜stupn¡ho bufferu
CompMaxL EQU       1000                     ; maxim ln¡ d‚lka © dku
CompLSyn EQU       4                        ; po‡et © dk– pro zasynchronizov n¡

; ------ definice bufferu souboru 1 nebo 2

CompSeg  EQU       0                        ; (2) ‡¡slo segmentu souboru
CompNum  EQU       2                        ; (2) po‡et bajt– v bufferu
CompUkz  EQU       4                        ; (4) offset za‡ tku bufferu pro BIN m¢d
                                            ; ukazatel ‡¡sla p©ed. © dku pro TXT m¢d
CompOff  EQU       8                        ; (2) offset p©ede¨l‚ho © dku souboru
CompAOf  EQU       10                       ; (2) offset aktu ln¡ho © dku
CompIdn  EQU       12                       ; (2) identifik tor souboru
CompDef  EQU       14                       ; velikost definice bufferu

; *****************************************************************************
;
;                     Porovn n¡ obsahu soubor–
;
; *****************************************************************************
;þ
; ------ p©¡prava p©ep¡na‡– pro menu SI

CompMSwc PROC      NEAR

         push      dx

         mov       dl,ds:[CompCfg]
         rol       dl,1
         call      far ptr SetSwch

         pop       dx
         ret

CompMSwc ENDP

; ------ p©ep¡na‡ "V˜pis"

CompFlV  PROC      FAR

         xor       dl,bit0
         jmp       short CompFlA2

CompFlV  ENDP

; ------ p©ep¡na‡ "Automaticky"

CompFlA  PROC      FAR

         or        dl,bit1
         and       dl,not bit2+bit3
CompFlA2:ror       dl,1
         mov       ds:[CompCfg],dl
         call      CompMSwc                 ; p©¡prava p©ep¡na‡– pro menu
         call      far ptr DispMnu
         ret

CompFlA  ENDP

; ------ p©ep¡na‡ "Textovˆ"

CompFlT  PROC      FAR

         or        dl,bit2
         and       dl,not bit1+bit3
         jmp       short CompFlA2

CompFlT  ENDP

; ------ p©ep¡na‡ "Bin rnˆ"

CompFlB  PROC      FAR

         or        dl,bit3
         and       dl,not bit1+bit2
         jmp       short CompFlA2

CompFlB  ENDP

; ------ p©ep¡na‡ "ž dky"

CompFlL  PROC      FAR

         xor       dl,bit4
         jmp       short CompFlA2

CompFlL  ENDP

; ------ p©ep¡na‡ "Zkr cen‚"

CompFlZ  PROC      FAR

         xor       dl,bit5
         jmp       short CompFlA2

CompFlZ  ENDP

; ------ zah jen¡ operace z menu

AWMMnuSS LABEL     FAR

         add       sp,4                     ; zru¨en¡ n vratov‚ adresy

; ------ zah jen¡ operace z kl vesy Ctrl-F9

CompFile LABEL     FAR

; ------ nulov n¡ ukazatel–

         xor       ax,ax
         mov       ds:[FileOIdn],ax         ; nen¡ v˜stupn¡ soubor
         mov       ds:[CompOSeg],ax         ; nen¡ v˜stupn¡ segment pro v˜pis
         mov       ds:[CompONum],ax         ; nejsou data ve v˜stupn¡m segmentu
         mov       ds:[CompOTop],ax         ; po‡ te‡n¡ adresa pro zobrazen¡
         mov       ds:[CompSeg1],ax         ; nen¡ segment 1
         mov       ds:[CompSeg2],ax         ; nen¡ segment 2
         mov       ax,offset CompDef1       ; definice bufferu 1
         xor       ax,offset CompDef2       ; definice bufferu 2
         mov       ds:[Comp1X2],ax          ; korekce adres

; ------ £schova kurzoru v neaktivn¡m oknˆ

         call      far ptr GetNAWin         ; adresa neaktivn¡ho okna
         mov       ax,es:[AWinFrst]         ; prvn¡ polo‘ka
         mov       ds:[CompOFrs],ax         ; £schova prvn¡ polo‘ky
         mov       ax,es:[AWinKurz]         ; kurzor
         mov       ds:[CompOKur],ax         ; £schova kurzoru

; ------ test, zda je operace povolena

         call      far ptr TestNAWn         ; zapnuto neaktivn¡ okno ?
         jc        CompFil0                 ; nen¡ zapnuto neaktivn¡ okno
         test      byte ptr ds:[ParamL],bit2 ; je to strom ?
         jnz       CompFil0                 ; strom nepovolen
         test      byte ptr ds:[ParamR],bit2 ; strom ?
         jnz       CompFil0                 ; strom nepovolen

; ------ inicializace operace

         call      far ptr ClosMnuA         ; uzav©en¡ v¨ech oken menu
         mov       al,bit1                  ; ozna‡en‚ soubory (bez adres ©–)
         call      far ptr InitFFil         ; inicializace vyhled v n¡
         jnc       CompFil1                 ; jsou nˆjak‚ soubory OK

; ------ ukon‡en¡ operace

CompFil0:call      CompClos                 ; uzav©en¡ operace porovn v n¡
         jmp       far ptr Main0

; ------ p©¡prava menu

CompFil1:mov       si,offset SS1MnLin       ; menu
         call      far ptr JumpBX

         dw        2,CompFl12               ; soubor pod kurzorem
         dw        6,CompFl16               ; 1 ozna‡en  polo‘ka
         dw        8,CompFl16               ; 2 a‘ 4 ozna‡en‚ polo‘ky
         dw        10,CompFl16              ; 5 a v¡ce ozna‡en˜ch polo‘ek
         dw        12,CompFl18              ; v¨echny soubory
         dw        14,CompFl18              ; v¨echny soubory a adres ©e
         dw        0,CompFil0               ; jin  volba - nic

; ------ soubor pod kurzorem

CompFl12:mov       word ptr ds:[SS1MnPl1],offset SS1MnPl4 ; "souboru"
         mov       word ptr ds:[SS1MnPl2],offset SS1MnPl7 ; "s"

; ------ p©ednastaven¡ nen¡-li nic ozna‡eno - stejn‚ jm‚no souboru

         push      si
         push      ds
         pop       es
         mov       si,offset FileTxtP
         mov       di,offset SRMnuFil
         mov       cx,14
         cld
         rep       movsb                    ; kopie jm‚na souboru

; ------ adresa neaktivn¡ho okna

         call      far ptr GetNAWin         ; adresa neaktivn¡ho okna
         mov       bp,es                    ; BP <- £schova adresy okna

; ------ nalezen¡ ozna‡en‚ polo‘ky

         xor       bx,bx
CompFl13:mov       es,bp                    ; ES <- adresa okna
         call      far ptr GetESPol         ; adresa polo‘ky -> ES:SI
         jc        CompFl15                 ; nen¡ dal¨¡ polo‘ka
         inc       bx                       ; zv˜¨en¡ ukazatele polo‘ek
         test      byte ptr es:[si+FileAtr],ATRT ; je to platn  polo‘ka ?
         jz        CompFl13                 ; nen¡ to platn  polo‘ka
         test      byte ptr es:[si+FileAtr],ATRO ; je to ozna‡en  polo‘ka ?
         jz        CompFl13                 ; nalezen¡ ozna‡en‚ polo‘ky
         test      byte ptr es:[si+FileAtr],DIR ; je to adres © ?
         jnz       CompFl13                 ; adres © neplat¡

; ------ dek¢dov n¡ jm‚na ozna‡en‚ polo‘ky

         push      ds
         push      ds
         push      es
         pop       ds                       ; DS <- segment polo‘ky
         pop       es                       ; ES <- datov˜ segment
         inc       si                       ; za‡ tek jm‚na polo‘ky
         mov       di,offset SRMnuFil+1     ; buffer jm‚na polo‘ky
         call      far ptr FileAsc          ; dek¢dov n¡ na tvar ASCII
         pop       ds
         xchg      ax,di                    ; AX <- adresa konce textu
         sub       ax,offset SRMnuFil+1     ; d‚lka textu
         mov       ds:[SRMnuFil],al         ; d‚lka textu

CompFl15:pop       si
         jmp       short CompFil2

; ------ ozna‡en‚ polo‘ky

CompFl16:mov       word ptr ds:[SS1MnPl1],offset SS1MnPl5 ; "y ozna‡en˜ch soubor–"
         jmp       short CompFl19

; ------ v¨echny soubory

CompFl18:mov       word ptr ds:[SS1MnPl1],offset SS1MnPl6 ; "y v¨ech soubor–"

CompFl19:mov       byte ptr ds:[FileTxtP],0 ; nen¡ 1. soubor
         mov       byte ptr ds:[SRMnuFil],0 ; nen¡ 2. soubor
         mov       word ptr ds:[SS1MnPl2],offset SS1MnPl8 ; "se soubory"

; ------ potvrzen¡ operace

CompFil2:call      CompMSwc                 ; p©¡prava p©ep¡na‡– pro menu
         mov       word ptr ds:[si+MnuAkt],1
         call      far ptr CentMenu         ; centrov n¡ menu
         call      far ptr VertMenu         ; obsluha menu
CompFl20:jmp       CompFil0                 ; p©eru¨en¡ operace

; ------ "Porovnat", "V˜pis"

CompFlX1:add       sp,4                     ; zru¨en¡ n vratov‚ adresy
         call      far ptr ClosMnuA         ; uzav©en¡ v¨ech oken menu

; ------ rozli¨en¡, zda je v˜pis do souboru

CompFl21:mov       al,0                     ; nen¡ v˜pis do souboru
         test      byte ptr ds:[CompCfg],bit7 ; je v˜pis do souboru ?
         jz        CompFl22                 ; nen¡ v˜pis do souboru
         call      CompMVyp                 ; zad n¡ souboru k v˜pisu
         jc        CompFl20                 ; p©eru¨en¡ operace
         mov       al,bit0                  ; je v˜pis do souboru
CompFl22:mov       ds:[CompPar],al          ; parametry pro operaci

; ------ vytvo©en¡ v˜stupn¡ho bufferu

         call      far ptr CreatSeg         ; vytvo©en¡ segmentu
         jc        CompFl24
         mov       ds:[CompOSeg],ax         ; v˜stupn¡ buffer
         mov       bx,CompOSiz              ; velikost bufferu
         call      far ptr ModiSegS         ; nastaven¡ velikosti bufferu
         jnc       CompFl25                 ; operace OK

; ------ chyba pamˆti

CompFl24:call      far ptr MemErr           ; chyba pamˆti
         jmp       short CompFl20

; ------ p©¡prava velikosti buffer– -> BX

CompFl25:call      far ptr GetFree          ; poskytnut¡ voln‚ pamˆti
         cmp       bx,(1000h + 2*1000h)/16  ; minim lnˆ pot©ebn‚ voln‚ m¡sto
         jb        CompFl24                 ; m lo pamˆti
         sub       bx,1000h/16              ; rezerva asi tak 4 KB
         shr       bx,1                     ; voln  pamˆŸ / 2
         cmp       bx,0ffeh                 ; maxim ln¡ velikost bufferu
         jbe       CompFl26                 ; velikost bufferu je OK
         mov       bx,0ffeh                 ; omezen¡ velikosti bufferu
CompFl26:mov       cl,4                     ; po‡et rotac¡
         shl       bx,cl                    ; p©evod velikosti na bajty
         mov       ds:[CompBSiz],bx         ; velikost bufferu (bajt–)

; ------ vytvo©en¡ bufferu 1

         call      far ptr CreatSeg         ; vytvo©en¡ bufferu 1
         jc        CompFl24
         mov       ds:[CompSeg1],ax         ; segment bufferu 1
         call      far ptr ModiSegS         ; nastaven¡ velikosti bufferu 1
         jc        CompFl24

; ------ vytvo©en¡ bufferu 2

         call      far ptr CreatSeg         ; vytvo©en¡ bufferu 2
         jc        CompFl24
         mov       ds:[CompSeg2],ax         ; segment bufferu 2
         call      far ptr ModiSegS         ; nastaven¡ velikosti bufferu 2
         jc        CompFl24

; ------ inicializace operace

         call      CompNIni                 ; inicializace neaktivn¡ho okna
         call      far ptr HistADir         ; ulo‘en¡ adres ©e do historie
         mov       si,offset CompTx1        ; text "Porovn v m"
         call      far ptr InfDisp0         ; zobrazen¡ textu
         call      far ptr InitFSet         ; inicializace ozna‡en¡ polo‘ek

; ------ poskytnut¡ dal¨¡ho souboru k operaci

CompFil3:call      far ptr TestBEsc         ; je p©eru¨en¡ operace ?
         jc        CompFl30                 ; p©eru¨en¡ operace
         call      far ptr DispTime         ; obsluha ‡asu
         call      far ptr DarkNul          ; nulov n¡ stm¡va‡e obrazovky
         call      far ptr GetFFil          ; poskytnut¡ souboru
         jnc       CompFl31                 ; je dal¨¡ soubor OK
CompFl30:jmp       CompFil8                 ; nen¡ dal¨¡ soubor

CompFl31:call      far ptr DispAAWn         ; zobrazen¡ aktivn¡ho okna

; ------ p©¡prava ukazatel– k porovn n¡ soubor–

         xor       ax,ax
         mov       ds:[CompNum1],ax         ; po‡et bajt– v bufferu 1
         mov       ds:[CompNum2],ax         ; po‡et bajt– v bufferu 2
         mov       ds:[CompLine],ax         ; ‡¡ta‡ © dk– pro v˜pis
         mov       word ptr ds:[CompUkaz],ax ; ukazatel offsetu v souboru1
         mov       word ptr ds:[CompUkaz+2],ax
         mov       word ptr ds:[CompUkz2],ax ; ukazatel offsetu v souboru1
         mov       word ptr ds:[CompUkz2+2],ax
         mov       ds:[CompAOff],ax         ; offset aktu ln¡ho © dku 1
         mov       ds:[CompAOf2],ax         ; offset aktu ln¡ho © dku 2
         mov       ds:[CompOffs],ax         ; offset p©ede¨l‚ho © dku 1
         mov       ds:[CompOff2],ax         ; offset p©ede¨l‚ho © dku 2
         and       byte ptr ds:[CompPar],not bit3+bit4+bit5 ; nen¡ hlavi‡ka ani shodn˜ © dek
         call      far ptr DekFParm         ; p©¡prava parametr– souboru

; ------ p©¡prava jm‚na c¡lov‚ho souboru

         call      CompCil                  ; p©¡prava c¡le k porovn n¡
         call      far ptr DispNAWn         ; zobrazen¡ neaktivn¡ho okna

; ------ hl ¨en¡ o prov dˆn¡ operace

         call      CompHlas                 ; hl ¨en¡ o prov dˆn¡ operace

; ------ test, zda je stejn˜ soubor

         push      ds
         pop       es
         mov       si,offset FilePath       ; jm‚no souboru 1
         mov       di,offset CilPath        ; jm‚no souboru 2
         mov       cx,ds:[FileFilN]         ; d‚lka jm‚na souboru
         inc       cx                       ; v‡etnˆ koncov‚ 0
         push      si
         cld
         repe      cmpsb                    ; porovn n¡ jmen soubor–
         pop       si
         jne       CompFl32                 ; soubory nejsou shodn‚
         or        byte ptr ds:[CompPar],bit7 ; nalezen rozd¡ln˜ soubor
         call      far ptr CompWar          ; varov n¡ - soubor se sebou
         jmp       short CompFl33

; ------ otev©en¡ souboru 1

CompFl32:call      far ptr OpenR            ; otev©en¡ souboru 1
         jnc       CompFl34                 ; soubor otev©en OK

; ------ chyba otev©en¡ souboru 1

         or        byte ptr ds:[CompPar],bit7 ; nalezen rozd¡ln˜ soubor
         call      far ptr OpenRErr         ; chyba otev©en¡ souboru
CompFl33:jmp       CompFil3                 ; dal¨¡ soubor

CompFl34:mov       ds:[CompIdn1],ax         ; identifik tor souboru 1

; ------ otev©en¡ souboru 2

         mov       si,offset CilPath        ; jm‚no souboru 2
         call      far ptr OpenR            ; otev©en¡ souboru 2
         jnc       CompFl35                 ; soubor otev©en OK

; ------ chyba otev©en¡ souboru 2

         or        byte ptr ds:[CompPar],bit7 ; nalezen rozd¡ln˜ soubor
         mov       ax,ds:[CompIdn1]         ; identifik tor souboru 1
         call      far ptr ClosFile         ; uzav©en¡ souboru 1
         call      far ptr CompErr          ; chyba otev©en¡ souboru 2
         jmp       short CompFl33           ; dal¨¡ soubor

CompFl35:mov       ds:[CompIdn2],ax         ; identifik tor souboru 2

; ------ detekce m¢du operace (na‡te se p©itom buffer souboru 1)

         and       byte ptr ds:[CompPar],not bit1+bit2 ; m¢d nen¡ zn m˜
         mov       al,ds:[CompCfg]          ; p©ep¡na‡e
         and       al,bit1+bit2             ; je m¢d zn m˜ ?
         jnz       CompFl36                 ; m¢d je zn m˜

         call      CompDet                  ; detekce m¢du operace
         mov       al,bit1                  ; textov˜ m¢d
         jnc       CompFl36                 ; je textov˜ m¢d
         mov       al,bit2                  ; bin rn¡ m¢d

CompFl36:or        ds:[CompPar],al          ; m¢d operace

; ------ porovn n¡ soubor– v textov‚m m¢du

         test      al,bit1                  ; je textov˜ m¢d ?
         jz        CompFil4                 ; nen¡ textov˜ m¢d
         call      CompTxt                  ; porovn n¡ v textov‚m m¢du
         jmp       short CompFil7

; ------ porovn n¡ soubor– v bin rn¡m m¢du

CompFil4:call      CompBin                  ; porovn n¡ v bin rn¡m m¢du

; ------ uzav©en¡ soubor– (CY=porovn n¡ nedokon‡eno)

CompFil7:pushf
         mov       ax,ds:[CompIdn1]         ; identifik tor souboru 1
         call      far ptr ClosFile         ; uzav©en¡ souboru 1
         mov       ax,ds:[CompIdn2]         ; identifik tor souboru 2
         call      far ptr ClosFile         ; uzav©en¡ souboru 2
         popf
         jc        CompFl78                 ; porovn n¡ nedokon‡eno - dal¨¡ soubor

         test      byte ptr ds:[CompPar],bit4 ; nalezeny rozd¡ly ?
         jnz       CompFl78                 ; nalezeny rozd¡ly

; ------ soubory shodn‚ OK - nulov n¡ ozna‡en¡ souboru

         call      far ptr ResFFil          ; nulov n¡ ozna‡en¡ souboru
         call      far ptr GetNAWin         ; adresa neaktivn¡ho okna
         mov       bx,es:[AWinKurz]         ; kurzor
         call      far ptr ResSPol          ; nulov n¡ ozna‡en¡ polo‘ky
         jc        CompFl79
         call      far ptr GetESPol         ; adresa polo‘ky pod kurzorem
         or        byte ptr es:[si+FileAtr],ATRU ; p©¡znak operace OK
         jmp       short CompFl79
CompFl78:or        byte ptr ds:[CompPar],bit7 ; nalezen rozd¡ln˜ soubor
CompFl79:jmp       CompFil3                 ; dal¨¡ soubor

; ------ hl ¨en¡ o proveden¡ operace

CompFil8:call      far ptr TestBEsc         ; je p©eru¨en¡ operace ?
         jc        CompFil9                 ; p©eru¨en¡ operace
         test      byte ptr ds:[CompPar],bit7 ; nalezen rozd¡ln˜ soubor ?
         jnz       CompFil9                 ; nalezen rozd¡ln˜ soubor

         call      CompClos                 ; uzav©en¡ operace porovn v n¡
         call      far ptr InfoClos         ; zru¨en¡ p©¡znaku inf. © dku
         call      far ptr ClosFFil         ; uzav©en¡ vyhled v n¡ soubor–
         call      far ptr DispAll          ; nov‚ zobrazen¡ v¨eho
         mov       si,offset CmpOKMnu       ; hl ¨en¡ - soubory shodn‚
         call      far ptr Lin0Menu         ; hl ¨en¡ o proveden¡ operace
         jmp       far ptr Main0

CompFil9:jmp       CompFil0
;þ
; -----------------------------------------------------------------------------
;        zad n¡ souboru k v˜pisu rozd¡l– porovn n¡ (CY=p©eru¨en¡ operace)
; -----------------------------------------------------------------------------

CompMVyp PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ zad n¡ souboru k v˜pisu

CompMVp1:mov       si,offset SSXMSLin       ; menu pro zad n¡ souboru
         call      far ptr Lin0Menu         ; zad n¡ souboru
         jc        CompMVp9                 ; p©eru¨en¡ operace

; ------ normalizace jm‚na souboru

         call      far ptr NormFilL         ; normalizace jm‚na souboru
         call      far ptr FullFile         ; sestaven¡ pln‚ho jm‚na souboru

; ------ kopie do bufferu FileOPth (CX=d‚lka, ES=DS, SI=buffer LinBuff)

         stc                                ; p©¡znak chyby
         jcxz      CompMVp9                 ; nen¡ nic zad no
         mov       ds:[FileOPtN],cx         ; d‚lka jm‚na souboru
         mov       di,offset FileOPth       ; buffer jm‚na souboru
         cld
         inc       cx                       ; v‡etnˆ koncov‚ 0
         rep       movsb                    ; £schova jm‚na souboru

; ------ otev©en¡ souboru pro z pis

         mov       si,offset FileOPth       ; buffer jm‚na souboru
         call      far ptr OpenRW           ; otev©en¡ souboru pro z pis
         jnc       CompMVp3                 ; soubor otev©en OK

; ------ vytvo©en¡ nov‚ho souboru

         call      far ptr CreatFil         ; vytvo©en¡ souboru
         jnc       CompMVp3                 ; soubor vytvo©en OK

; ------ chyba - soubor nelze otev©¡t

         call      far ptr OpenRErr         ; hl ¨en¡ - chyba otev©en¡
         jc        CompMVp9                 ; p©eru¨en¡ operace
         jmp       short CompMVp1           ; opakov n¡ zad n¡

; ------ nastaven¡ ukazatele na konec souboru

CompMVp3:call      far ptr SizeFile         ; nastaven¡ ukazatele na konec
         mov       ds:[FileOIdn],ax         ; identifik tor v˜stupn¡ho souboru
         call      far ptr ModiWDir         ; aktualizace adres ©e
         clc                                ; p©¡znak operace OK

; ------ n vrat registr–

CompMVp9:pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

CompMVyp ENDP

; -----------------------------------------------------------------------------
;        uzav©en¡ operace porovn v n¡
; -----------------------------------------------------------------------------

CompClos PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      es

; ------ vypr zdnˆn¡ obsahu bufferu

         call      CompOWrt                 ; vypr zdnˆn¡ obsahu bufferu

; ------ test, zda je soubor v˜pisu otev©en

         call      far ptr ZapKrit          ; zapnut¡ kritick‚ sekce
         mov       ax,ds:[FileOIdn]         ; identifik tor souboru
         or        ax,ax                    ; je vytvo©en ?
         jz        CompCls3                 ; soubor nen¡ vytvo©en

; ------ zji¨tˆn¡ velikosti souboru hl ¨en¡

         call      far ptr SizeFile         ; velikost souboru
         jc        CompCls2                 ; nˆjak  chyba
         or        cx,bx                    ; je soubor pr zdn˜ ?
         jnz       CompCls2                 ; soubor nen¡ pr zdn˜

; ------ uzav©en¡ souboru v˜pisu

         call      far ptr ClosFile         ; uzav©en¡ souboru
         mov       ds:[FileOIdn],ax         ; nen¡ identifik tor souboru

; ------ zru¨en¡ souboru v˜pisu

         mov       si,offset FileOPth       ; jm‚no souboru v˜pisu
         push      ds
         pop       es                       ; ES <- datov˜ segment
         call      far ptr DelFile          ; zru¨en¡ souboru v˜pisu
         jmp       short CompCls3

; ------ uzav©en¡ v˜stupn¡ho souboru

CompCls2:call      far ptr ClosFile         ; uzav©en¡ souboru
         mov       ds:[FileOIdn],ax         ; nen¡ identifik tor souboru
CompCls3:call      far ptr VypKrit          ; vypnut¡ kritick‚ sekce

; ------ zru¨en¡ v˜stupn¡ho segmentu

         mov       ax,ds:[CompOSeg]         ; segment v˜stupn¡ho bufferu
         call      far ptr DelSeg           ; zru¨en¡ segmentu
         mov       ds:[CompOSeg],ax         ; nen¡ v˜stupn¡ buffer

; ------ zru¨en¡ bufferu 1

         mov       ax,ds:[CompSeg1]         ; segment 1
         call      far ptr DelSeg           ; zru¨en¡ segmentu 1
         mov       ds:[CompSeg1],ax         ; nen¡ segment 1

; ------ zru¨en¡ bufferu 2

         mov       ax,ds:[CompSeg2]         ; segment 2
         call      far ptr DelSeg           ; zru¨en¡ segmentu 2
         mov       ds:[CompSeg2],ax         ; nen¡ segment 2

; ------ navr cen¡ kurzoru v neaktivn¡m oknˆ

         call      far ptr GetNAWin         ; adresa neaktivn¡ho okna
         mov       ax,ds:[CompOKur]         ; kurzor
         mov       es:[AWinKurz],ax         ; kurzor
         mov       ax,ds:[CompOFrs]         ; prvn¡ polo‘ka
         mov       es:[AWinFrst],ax         ; prvn¡ polo‘ka
         call      far ptr DispNAWn         ; zobrazen¡ neaktivn¡ho okna

; ------ n vrat registr–

         pop       es
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

CompClos ENDP

; -----------------------------------------------------------------------------
;        z pis textu ES:SI/CX do v˜stupn¡ho bufferu (CY=chyba, dal¨¡ nebo p©eru¨en¡)
; -----------------------------------------------------------------------------

CompOTxt PROC      NEAR

         push      ax
         push      cx
         push      si

         clc
         jcxz      CompOTx5
CompOTx2:mov       al,es:[si]
         inc       si
         cmp       al,TAB
         je        CompOTx3                 ; tabul tor je povolen
         cmp       al," "                   ; je to platn˜ znak ?
         jb        CompOTx4                 ; nen¡ to platn˜ znak
CompOTx3:call      CompOChr                 ; z pis znaku AL
         jc        CompOTx5
CompOTx4:loop      CompOTx2
         clc

CompOTx5:pop       si
         pop       cx
         pop       ax
         ret

CompOTxt ENDP

; -----------------------------------------------------------------------------
;        z pis znaku mezery do v˜stupn¡ho bufferu (CY=chyba, dal¨¡ nebo p©eru¨en¡)
; -----------------------------------------------------------------------------

CompOSpc PROC      NEAR

         push      ax
         mov       al," "
         call      CompOChr
         pop       ax
         ret

CompOSpc ENDP

; -----------------------------------------------------------------------------
;        z pis konec © dku CR/LF do v˜stupn¡ho bufferu (CY=chyba, dal¨¡ nebo p©eru¨en¡)
; -----------------------------------------------------------------------------

CompOCr  PROC      NEAR

         push      ax
         mov       al,CR
         call      CompOChr
         jc        CompOCr2
         mov       al,LF
         call      CompOChr
CompOCr2:pop       ax
         ret

CompOCr  ENDP

; -----------------------------------------------------------------------------
;        z pis slova AX HEX do v˜stupn¡ho bufferu (CY=chyba, dal¨¡ nebo p©eru¨en¡)
; -----------------------------------------------------------------------------

CompOWrd PROC      NEAR

         xchg      al,ah
         call      CompOByt
         xchg      al,ah
         jc        CompOHx9                 ; chyba
                                          ;* pokra‡uje z pis bajtu HEX !
CompOWrd ENDP

; -----------------------------------------------------------------------------
;        z pis bajtu AL HEX do v˜stupn¡ho bufferu (CY=chyba, dal¨¡ nebo p©eru¨en¡)
; -----------------------------------------------------------------------------

CompOByt PROC      NEAR

         push      ax
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1
         call      CompOHex
         pop       ax
         jc        CompOHx9                 ; chyba
                                          ;* pokra‡uje z pis znaku HEX !
CompOByt ENDP

; -----------------------------------------------------------------------------
;        z pis znaku HEX do v˜stupn¡ho bufferu (CY=chyba, dal¨¡ nebo p©eru¨en¡)
; -----------------------------------------------------------------------------

CompOHex PROC      NEAR

         push      ax
         and       al,0fh
         cmp       al,10
         jb        CompOHx2
         add       al,7
CompOHx2:add       al,"0"
         call      CompOChr                 ; z pis znaku do bufferu
         pop       ax
CompOHx9:ret

CompOHex ENDP

; -----------------------------------------------------------------------------
;        z pis znaku AL do v˜stupn¡ho bufferu (CY=chyba, dal¨¡ nebo p©eru¨en¡)
; -----------------------------------------------------------------------------

CompOChr PROC      NEAR

; ------ £schova registr–

         push      si
         push      es

; ------ adresa v˜stupn¡ho bufferu

         push      ax
         mov       ax,ds:[CompOSeg]         ; segment v˜stupn¡ho bufferu
         call      far ptr GetDat           ; adresa bufferu -> ES
         pop       ax
         jc        CompOCh8                 ; neplatn˜ buffer

; ------ vypr zdnˆn¡ bufferu

         mov       si,ds:[CompONum]         ; po‡et bajt– v bufferu
         cmp       si,CompOSiz              ; je buffer ji‘ pln˜ ?
         jb        CompOCh3                 ; je¨tˆ nen¡ pln˜
         call      CompOWrt                 ; z pis obsahu bufferu
         jc        CompOCh8                 ; chyba nebo p©eru¨en¡
         xor       si,si                    ; ukazatel v bufferu

; ------ z pis znaku do bufferu

CompOCh3:mov       es:[si],al               ; ulo‘en¡ znaku do bufferu
         inc       word ptr ds:[CompONum]   ; zv˜¨en¡ po‡tu znak– v bufferu

; ------ test, zda to je znak LF

         cmp       al,LF                    ; je to znak LF ?
         jne       CompOCh7                 ; nen¡ to znak LF
         test      byte ptr ds:[CompPar],bit4 ; je v˜stup rozd¡ln˜ch © dk– ?
         jz        CompOCh6                 ; nen¡ v˜stup rozd¡ln˜ch © dk–
         inc       word ptr ds:[CompLine]   ; zv˜¨en¡ ‡¡ta‡e © dk–

; ------ automatick‚ vypr zdnˆn¡ © dk–

CompOCh6:test      byte ptr ds:[CompPar],bit0 ; je v˜pis do souboru ?
         jnz       CompOCh7                 ; je v˜pis do souboru
         cmp       word ptr ds:[CompLine],12 ; je ji‘ dost © dk– ?
         jb        CompOCh7                 ; nen¡ je¨tˆ dost © dk–
         call      CompOWrt                 ; vypr zdnˆn¡ bufferu © dk–
         jc        CompOCh8                 ; chyba nebo p©eru¨en¡

CompOCh7:clc                                ; p©¡znak operace OK

; ------ n vrat registr–

CompOCh8:pop       es
         pop       si
         ret

CompOChr ENDP

; -----------------------------------------------------------------------------
;        z pis obsahu v˜stupn¡ho bufferu do souboru v˜pisu (CY=chyba, p©eru¨en¡ nebo dal¨¡)
; -----------------------------------------------------------------------------

CompOWrt PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      si
         push      es

; ------ hl ¨en¡ o rozd¡lech

         xor       cx,cx                    ; CX <- 0
         mov       ds:[CompLine],cx         ; nejsou ‘ dn‚ © dky k zobrazen¡
         test      byte ptr ds:[CompPar],bit0 ; je v˜pis do souboru ?
         jnz       CompOWr2                 ; je v˜pis do souboru
         test      byte ptr ds:[CompPar],bit4 ; je v˜stup rozd¡ln˜ch © dk– ?
         jz        CompOWr2                 ; nen¡ v˜stup rozd¡ln˜ch © dk–
         call      CompRozd                 ; hl ¨en¡ o rozd¡lech

; ------ po‡et bajt– k z pisu

CompOWr2:mov       word ptr ds:[CompOTop],0 ; po‡ te‡n¡ adresa pro zobrazen¡
         xchg      cx,ds:[CompONum]         ; po‡et bajt– ve v˜stupn¡m bufferu
         jc        CompOWr9                 ; dal¨¡ soubor nebo p©eru¨en¡
         jcxz      CompOWr9                 ; nejsou ‘ dn  data k z pisu
         test      byte ptr ds:[CompPar],bit0 ; je v˜pis do souboru ?
         jz        CompOWr9                 ; nen¡ v˜pis do souboru

; ------ adresa bufferu -> ES

         mov       ax,ds:[CompOSeg]         ; segment v˜stupn¡ho bufferu
         call      far ptr GetDat           ; adresa bufferu
         jc        CompOWr9                 ; neplatn˜ segment

; ------ z pis dat do souboru

         mov       ax,ds:[FileOIdn]         ; identifik tor v˜stupn¡ho souboru
         or        ax,ax
         jz        CompOWr9                 ; soubor nen¡ otev©en
         xor       si,si                    ; za‡ tek dat v bufferu
         call      far ptr WritFile         ; z pis dat do souboru

; ------ n vrat registr–

CompOWr9:pop       es
         pop       si
         pop       cx
         pop       ax
         ret

CompOWrt ENDP

; -----------------------------------------------------------------------------
;        hl ¨en¡ o rozd¡lech (CY=p©eru¨en¡ operace)
; -----------------------------------------------------------------------------

CompRozd PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ test, zda se nˆco zobrazuje

         mov       di,ds:[CompOTop]         ; po‡ te‡n¡ adresa k zobrazen¡
         cmp       di,ds:[CompONum]         ; je nˆco v bufferu ?
         jb        CompRzd1                 ; je nˆco v bufferu
         jmp       CompRzd9                 ; nic se nezobrazuje (-> NC)

; ------ p©¡prava d‚lky jm‚na souboru 2

CompRzd1:mov       ax,ds:[CilPathN]
         mov       ds:[SS2MnPl2],al

; ------ vynulov n¡ © dk–

         mov       bx,offset SS2MnPl3+4     ; definice © dk–
         mov       cx,12
         push      bx
CompRzd2:mov       byte ptr ds:[bx],0
         add       bx,11
         loop      CompRzd2
         pop       bx

; ------ p©¡prava k vyhled n¡ © dk– v bufferu (DI=po‡ te‡n¡ adresa v bufferu)

         mov       dx,12                    ; maxim ln¡ po‡et © dk–
         mov       ax,ds:[CompOSeg]         ; v˜stupn¡ segment
         call      far ptr GetDat           ; adresa segmentu
         mov       cx,ds:[CompONum]         ; po‡et bajt– v segmentu
         sub       cx,di                    ; zbytek dat v bufferu

; ------ na‡ten¡ definic © dk– v bufferu

CompRzd3:jcxz      CompRzd5                 ; nejsou dal¨¡ data
         mov       ds:[bx+3],es             ; segment adresy © dku
         mov       ds:[bx+1],di             ; adresa za‡ tku © dku
         mov       al,LF                    ; hledan˜ znak
         repne     scasb                    ; nalezen¡ konce © dku
         mov       ax,di                    ; AX <- adresa dal¨¡ho © dku
         dec       ax
         dec       ax                       ; bez znak– CR/LF
         sub       ax,ds:[bx+1]             ; d‚lka © dku
         cmp       ax,255                   ; maxim ln¡ d‚lka © dku
         jbe       CompRzd4                 ; d‚lka © dku je OK
         mov       al,255                   ; omezen¡ d‚lky © dku
CompRzd4:mov       ds:[bx],al               ; d‚lka © dku
         add       bx,11                    ; definice dal¨¡ho © dku
         dec       dx                       ; ‡¡ta‡ © dk–
         jnz       CompRzd3                 ; dal¨¡ © dek

; ------ menu

CompRzd5:mov       si,offset SS2MnLin
         call      far ptr Lin0MenF         ; hl ¨en¡

         call      far ptr JumpBX
         dw        1,CompRz88               ; Pokra‡ovat
         dw        2,CompRzd7               ; Dal¨¡
         dw        3,CompRzd8               ; V˜pis
         dw        0,CompRzd6               ; N vrat

; ------ p©eru¨en¡

CompRzd6:call      far ptr SetEsc           ; p©¡znak p©eru¨en¡ operace
         jmp       short CompRzd9

; ------ dal¨¡

CompRzd7:call      far ptr InfoDisp         ; obnoven¡ zobrazen¡ inform. © dku
         stc                                ; p©¡znak p©eru¨en¡
         jmp       short CompRzd9

; ------ v˜pis do souboru

CompRzd8:call      CompMVyp                 ; zad n¡ souboru k v˜pisu
         jc        CompRzd5                 ; n vrat k menu
         or        byte ptr ds:[CompPar],bit0 ; je v˜pis do souboru

; ------ pokra‡ov n¡ v operaci

CompRz88:call      far ptr InfoDisp         ; obnoven¡ zobrazen¡ inform. © dku
         clc                                ; p©¡znak operace OK

; ------ n vrat registr–

CompRzd9:pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

CompRozd ENDP

; -----------------------------------------------------------------------------
;        inicializace neaktivn¡ho okna (£schova ozna‡en¡ polo‘ek; ni‡¡ registry)
; -----------------------------------------------------------------------------

CompNIni PROC      NEAR

         call      far ptr GetNAWin         ; adresa neaktivn¡ho okna
         mov       bp,es                    ; BP <- adresa neaktivn¡ho okna
         xor       bx,bx                    ; ukazatel polo‘ek
         dec       bx
CompNIn2:inc       bx                       ; zv˜¨en¡ ukazatele polo‘ek
         mov       es,bp                    ; ES <- adresa okna
         call      far ptr GetESPol         ; adresa polo‘ky -> ES:SI
         jc        CompNIn9                 ; nen¡ dal¨¡ polo‘ka
         test      byte ptr es:[si+FileAtr],ATRT ; je to platn  polo‘ka ?
         jz        CompNIn2                 ; nen¡ to platn  polo‘ka
         and       byte ptr es:[si+FileAtr],not ATRU ; nulov n¡ £schovy ozna‡en¡
         test      byte ptr es:[si+FileAtr],ATRO ; je to ozna‡en  polo‘ka ?
         jz        CompNIn2                 ; nen¡ to ozna‡en  polo‘ka
         or        byte ptr es:[si+FileAtr],ATRU ; £schova ozna‡en¡
         test      byte ptr es:[si+FileAtr],DIR ; je to adres © ?
         jz        CompNIn2                 ; nen¡ to adres ©
         and       byte ptr es:[si+FileAtr],not ATRU ; nen¡ povolen k operaci
         mov       es,bp                    ; ES <- adresa okna
         call      far ptr ResSPol          ; nulov n¡ ozna‡en¡ polo‘ky
         jmp       short CompNIn2           ; dal¨¡ polo‘ka

CompNIn9:ret

CompNIni ENDP

; -----------------------------------------------------------------------------
;        p©¡prava c¡le k porovn n¡ (ni‡¡ registry)
; -----------------------------------------------------------------------------

CompCil  PROC      NEAR

; ------ p©¡prava cesty k protˆj¨¡mu oknu

         call      far ptr GetNAWin         ; adresa neaktivn¡ho okna
         mov       bp,es                    ; BP <- £schova adresy okna
         push      ds
         push      es
         push      ds
         pop       es                       ; ES <- datov˜ segment
         pop       ds                       ; DS <- segment okna
         mov       si,AWinDir               ; cesta k neaktivn¡mu oknu
         mov       cx,ds:[AWinDNum]         ; d‚lka cesty k oknu
         mov       di,offset CilPath        ; buffer jm‚na souboru
         cld
         rep       movsb                    ; p©enos textu adres ©e
         pop       ds

; ------ nalezen¡ ozna‡en‚ polo‘ky v protˆj¨¡m oknˆ -> ES:SI

         xor       bx,bx                    ; ukazatel ‡¡sla polo‘ky
         dec       bx
CompCil1:inc       bx                       ; zv˜¨en¡ ukazatele ‡¡sla polo‘ky
         mov       es,bp                    ; ES <- adresa okna
         call      far ptr GetESPol         ; adresa polo‘ky -> ES:SI
         jc        CompCil3                 ; nen¡ dal¨¡ polo‘ka

; ------ p©i nalezen¡ cesty £schova nov‚ cesty

         test      byte ptr es:[si+FileAtr],ATRT ; je to platn  polo‘ka ?
         jnz       CompCil2                 ; je to platn  polo‘ka OK
         push      ds
         push      ds
         push      es
         pop       ds                       ; DS <- segment polo‘ky
         pop       es                       ; ES <- datov˜ segment
         mov       cl,ds:[si]               ; d‚lka textu cesty
         inc       si
         mov       di,offset CilPath        ; buffer jm‚na souboru
         cld
         rep       movsb                    ; £schova cesty
         pop       ds
         jmp       short CompCil1           ; dal¨¡ polo‘ka

; ------ test, zda to je ozna‡en  polo‘ka

CompCil2:test      byte ptr es:[si+FileAtr],ATRO ; je polo‘ka ozna‡en  ?
         jz        CompCil1                 ; nen¡ to ozna‡en  polo‘ka
         test      byte ptr es:[si+FileAtr],ATRU ; je to ozna‡en  polo‘ka ?
         jz        CompCil1                 ; nen¡ to ozna‡en  polo‘ka
         and       byte ptr es:[si+FileAtr],not ATRU ; p©¡znak nalezen¡ polo‘ky

; ------ nastaven¡ kurzoru na polo‘ku

         push      es
         mov       es,bp                    ; ES <- adresa okna
         mov       es:[AWinKurz],bx         ; nastaven¡ kurzoru
         pop       es
         jmp       short CompCil4

; ------ polo‘ka nenalezena - nahrad¡ se jm‚nem souboru pod kurzorem -> ES:SI

CompCil3:call      far ptr GetNAWin         ; adresa neaktivn¡ho okna
         push      ds
         push      ds
         pop       es                       ; ES <- datov˜ segment
         mov       ds,bp                    ; DS <- adresa okna
         mov       si,AWinDir               ; cesta k neaktivn¡mu oknu
         mov       cx,ds:[AWinDNum]         ; d‚lka cesty k oknu
         mov       di,offset CilPath        ; buffer jm‚na souboru
         cld
         rep       movsb                    ; p©enos textu adres ©e
         pop       ds

         call      far ptr GetAKurz         ; polo‘ka pod kurzorem

; ------ p©¡prava k dek¢dov n¡ polo‘ky

CompCil4:push      ds
         push      ds
         push      es
         pop       ds                       ; DS <- segment polo‘ky
         pop       es                       ; ES <- datov˜ segment

; ------ zaji¨tˆn¡ oddˆlova‡e "\" na konci cesty

         cld
         dec       di                       ; n vrat na posledn¡ znak
         mov       al,"\"                   ; znak oddˆlova‡e
         scasb                              ; kon‡¡ cesta znakem "\" ?
         je        CompCil5                 ; je OK
         stosb                              ; ulo‘en¡ oddˆlova‡e "\"

; ------ dek¢dov n¡ jm‚na polo‘ky

CompCil5:inc       si                       ; za‡ tek jm‚na polo‘ky
         call      far ptr FileAsc          ; dek¢dov n¡ jm‚na polo‘ky
         pop       ds

; ------ d‚lka cesty

         sub       di,offset CilPath        ; d‚lka cesty
         mov       ds:[CilPathN],di         ; d‚lka cesty
         ret

CompCil  ENDP

; -----------------------------------------------------------------------------
;        hl ¨en¡ o prov dˆn¡ operace
; -----------------------------------------------------------------------------

CompHlas PROC      NEAR

; ------ vymaz n¡ informa‡n¡ho © dku

         call      far ptr InfoClr          ; vymaz n¡ informa‡n¡ho © dku

; ------ dek¢dov n¡ prvn¡ ‡ sti textu "Porovn v m"

         mov       si,offset CompTx1        ; text "Porovn v m"
         call      far ptr InfoTxt          ; dek¢dov n¡ textu

; ------ dek¢dov n¡ jm‚na souboru

         mov       si,offset SRMnuFil       ; jm‚no souboru
         call      far ptr InfoTxt          ; dek¢dov n¡ jm‚na souboru

; ------ dek¢dov n¡ druh‚ ‡ sti textu "s"

         mov       si,offset CompTx2        ; text "s"
         call      far ptr InfoTxt          ; dek¢dov n¡ textu

; ------ dek¢dov n¡ jm‚na druh‚ho souboru

         mov       si,offset CilPath        ; text c¡lov‚ho jm‚na
         mov       cx,ds:[CilPathN]         ; d‚lka jm‚na souboru
         call      far ptr InfoDek          ; dek¢dov n¡ jm‚na souboru

; ------ zobrazen¡ hl ¨en¡ o prov dˆn¡ operace

         xor       cx,cx                    ; CX <- 0 kurzor na 0
         call      far ptr InfoKurz         ; zobrazen¡ © dku s kurzorem
         ret

CompHlas ENDP

; -----------------------------------------------------------------------------
;        detekce m¢du operace -> CY bin rn¡ m¢d (na‡te se obsah bufferu 1) BP=adresa definice bufferu 1
; -----------------------------------------------------------------------------

CompDet  PROC      NEAR

         call      Comp1Rea                 ; na‡ten¡ dat ze souboru 1
         call      Comp1Get                 ; adresa bufferu 1 -> ES
         mov       cx,ds:[CompNum1]         ; po‡et bajt– v bufferu 1
         xor       si,si                    ; za‡ tek dat v bufferu 1
         call      far ptr TextDet          ; detekce m¢du operace
         ret

CompDet  ENDP

; -----------------------------------------------------------------------------
;        porovn n¡ soubor– v textov‚m m¢du -> CY=porovn n¡ nedokon‡eno
; -----------------------------------------------------------------------------
;þ
CompTxt  PROC      NEAR

; ------ na‡ten¡ dat do bufferu 2

         call      Comp2Rea                 ; na‡ten¡ dat do bufferu 2
         jnc       CompTxt1                 ; operace OK
CompTxt0:jmp       CompTxt9                 ; chyba

; ------ na‡ten¡ dat do bufferu 1

CompTxt1:call      Comp1Rea                 ; na‡ten¡ dat do bufferu 1
         jc        CompTxt0                 ; chyba

; ------ stanoven¡ d‚lky aktu ln¡ho © dku 1 -> CX

CompTxt2:mov       di,ds:[CompAOff]         ; offset aktu ln¡ho © dku
         call      CompT1Ln                 ; stanoven¡ d‚lky © dku 1 -> CX
         jnc       CompTxt3                 ; © dek je OK platn˜

; ------ konec © dku nenalezen - posun bufferu 1 (aby se uvolnilo m¡sto)

         call      CompT1Dl                 ; uvolnˆn¡ bufferu 1
         jnc       CompTxt1                 ; bylo nˆco uvolnˆno - na‡ten¡ dat
                                          ;* jinak je konec souboru - CX plat¡
; ------ test, zda je v bufferu 2 dostatek dat (CX=d‚lka © dku v bufferu 1)

CompTxt3:mov       si,di                    ; aktu ln¡ © dek v bufferu 1
CompTx32:mov       ax,ds:[CompAOf2]         ; AX <- aktu ln¡ © dek v bufferu 2
         add       ax,cx                    ; p©edpokl dan˜ konec v bufferu 2
         jc        CompTx34                 ; p©ete‡en¡
         cmp       ax,ds:[CompNum2]         ; zb˜v  dost dat ?
         jbe       CompTx36                 ; zb˜v  dost dat OK

; ------ uvolnˆn¡ bufferu 2

CompTx34:call      CompT2Dl                 ; uvolnˆn¡ bufferu 2
         jc        CompTxt7                 ; nen¡ co uvolnit

; ------ na‡ten¡ dal¨¡ch dat do bufferu 2

         call      Comp2Rea                 ; na‡ten¡ dat do bufferu 2
         jnc       CompTx32                 ; kontrola
         jmp       CompTxt9                 ; chyba

; ------ test, zda jsou nˆjak‚ © dky

CompTx36:mov       di,ds:[CompAOf2]         ; aktu ln¡ © dek v bufferu 2
         cmp       si,ds:[CompNum1]         ; jsou nˆjak‚ © dky ?
         jb        CompTx37                 ; jsou nˆjak  data
         cmp       di,ds:[CompNum2]
         jae       CompTxt8                 ; nejsou © dky k v˜pisu

; ------ porovn n¡ aktu ln¡ho © dku (d‚lka CX)

CompTx37:jcxz      CompTxt7                 ; konec souboru 1 (nen¡ shoda)
         call      CompT1Cm                 ; porovn n¡ © dk–
         jne       CompTxt7                 ; © dky nejsou shodn‚
         or        byte ptr ds:[CompPar],bit5 ; nalezen shodn˜ © dek

; ------ © dky jsou shodn‚ - posun ukazatele o jeden © dek

CompTxt6:add       si,cx                    ; adresa dal¨¡ho © dku v 1
         add       di,cx                    ; adresa dal¨¡ho © dku v 2
         xchg      si,ds:[CompAOff]         ; aktu ln¡ © dek v bufferu 1
         mov       ds:[CompOffs],si         ; offset p©ede¨l‚ho © dku 1
         xchg      di,ds:[CompAOf2]         ; aktu ln¡ © dek v bufferu 2
         mov       ds:[CompOff2],di         ; offset p©ede¨l‚ho © dku 2
         add       word ptr ds:[CompUkaz],1 ; zv˜¨en¡ ‡¡sla © dku 1
         adc       word ptr ds:[CompUkaz+2],0
         add       word ptr ds:[CompUkz2],1 ; zv˜¨en¡ ‡¡sla © dku 2
         adc       word ptr ds:[CompUkz2+2],0
         jmp       short CompTxt2           ; test dal¨¡ho © dku

; ------ aktu ln¡ © dky nejsou shodn‚ (nebo je konec nˆkter‚ho souboru)

CompTxt7:call      CompTSyn                 ; zasynchronizov n¡ © dk–

; ------ n vrat ukazatele ‡¡sla © dk–

         test      byte ptr ds:[CompPar],bit5 ; nalezen shodn˜ © dek ?
         jz        CompTx72
         sub       word ptr ds:[CompUkaz],1 ; zv˜¨en¡ ‡¡sla © dku 1
         sbb       word ptr ds:[CompUkaz+2],0
         sub       word ptr ds:[CompUkz2],1 ; zv˜¨en¡ ‡¡sla © dku 2
         sbb       word ptr ds:[CompUkz2+2],0

; ------ v˜pis rozd¡ln˜ch © dk–

CompTx72:call      CompTHls                 ; v˜pis hl ¨en¡
         jc        CompTxt9                 ; p©eru¨en¡ operace, dal¨¡ nebo chyba
         call      CompOWrt                 ; vypr zdnˆn¡ v˜stupu
         jc        CompTxt9                 ; p©eru¨en¡ operace

         sub       word ptr ds:[CompUkaz],1 ; zv˜¨en¡ ‡¡sla © dku 1
         sbb       word ptr ds:[CompUkaz+2],0
         sub       word ptr ds:[CompUkz2],1 ; zv˜¨en¡ ‡¡sla © dku 2
         sbb       word ptr ds:[CompUkz2+2],0
         and       byte ptr ds:[CompPar],not bit5 ; nebyl shodn˜ © dek
         jmp       CompTxt2                 ; dal¨¡ © dek

; ------ konec soubor– - vypr zdnˆn¡ bufferu v˜pisu

CompTxt8:call      CompOWrt                 ; z pis obsahu v˜pisov‚ho bufferu
CompTxt9:ret

CompTxt  ENDP

; -----------------------------------------------------------------------------
;        hl ¨en¡ rozd¡l– p©i textov‚m porovn n¡ -> CY p©eru¨en¡
; -----------------------------------------------------------------------------

CompTHls PROC      NEAR

; ------ z pis z hlav¡

         call      CompZahl                 ; z pis z hlav¡
         jc        CompTHl9                 ; p©eru¨en¡

; ------ z pis © dk– bufferu 1

         mov       bp,offset CompDef1       ; definice bufferu 1
         call      CompTZap                 ; z pis © dk– rozd¡lu
         jc        CompTHl9                 ; p©eru¨en¡

; ------ oddˆlovac¡ ‡ ra mezi © dky soubor–

         mov       dx,10-1                  ; d‚lka ‡ ry
         call      CompTOdd                 ; oddˆlovac¡ ‡ ra
         jc        CompTHl9                 ; chyba

; ------ z pis © dk– bufferu 2

         mov       bp,offset CompDef2       ; definice bufferu 2
         call      CompTZap                 ; z pis © dk– rozd¡lu
         jc        CompTHl9                 ; p©eru¨en¡

; ------ oddˆlovac¡ ‡ ra za © dky soubor–

         mov       dx,32-1                  ; d‚lka ‡ ry
         call      CompTOdd                 ; oddˆlovac¡ ‡ ra
CompTHl9:ret

CompTHls ENDP

; -----------------------------------------------------------------------------
;   z pis © dk– rozd¡lu (od prvn¡ho © dku po aktu ln¡) bufferu BP (CY=p©eru¨en¡)
; -----------------------------------------------------------------------------

CompTZap PROC      NEAR

; ------ spo‡ten¡ po‡tu © dk– v bufferu k z pisu

         xor       bx,bx                    ; ‡¡ta‡ © dk–
         mov       di,ds:[bp+CompOff]       ; offset prvn¡ho © dku
CompTZp1:cmp       di,ds:[bp+CompAOf]       ; je dal¨¡ platn˜ © dek ?
         ja        CompTZp2                 ; nen¡ dal¨¡ platn˜ © dek
         call      CompT0Ln                 ; d‚lka © dku v bufferu
         jcxz      CompTZp2                 ; nen¡ © dek
         add       di,cx                    ; DI <- adresa dal¨¡ho © dku
         inc       bx                       ; zv˜¨en¡ ‡¡ta‡e © dk–
         jmp       short CompTZp1           ; dal¨¡ © dek

; ------ rozli¨en¡, zda bude zkr cen˜ v˜pis

CompTZp2:sub       bx,5                     ; je velk˜ po‡et © dk– ?
         jbe       CompTZp6                 ; nen¡ velk˜ po‡et © dk–
         test      byte ptr ds:[CompCfg],bit4 ; m  b˜t zkr cen˜ v˜pis ?
         jz        CompTZp6                 ; nem  b˜t zkr cen˜ v˜pis
         inc       bx                       ; po‡et © dk– k p©esko‡en¡

; ------ z pis prvn¡ho a druh‚ho © dku

         call      CompT0Zp                 ; z pis prvn¡ho © dku
         jc        CompTZp9                 ; p©eru¨en¡
         call      CompT0Zp                 ; z pis druh‚ho © dku
         jc        CompTZp9                 ; p©eru¨en¡

; ------ z pis oddˆlovac¡ch te‡ek

         mov       al,"."
         mov       dx,5                     ; po‡et te‡ek
         call      CompTOd2
         jc        CompTZp9                 ; p©eru¨en¡

; ------ p©esko‡en¡ nezobrazen˜ch © dk–

         mov       di,ds:[bp+CompOff]       ; offset aktu ln¡ho © dku
CompTZp3:call      CompT0Ln                 ; d‚lka © dku v bufferu
         add       di,cx                    ; DI <- adresa dal¨¡ho © dku
         mov       ds:[bp+CompOff],di       ; nov˜ offset p©ede¨l‚ho © dku
         add       word ptr ds:[bp+CompUkz],1 ; zv˜¨en¡ ukazatele ‡¡sla © dku
         adc       word ptr ds:[bp+CompUkz+2],0
         dec       bx                       ; ‡¡ta‡ © dk– k p©esko‡en¡
         jnz       CompTZp3                 ; dal¨¡ © dek

; ------ z pis p©edposledn¡ho a posledn¡ho © dku

         call      CompT0Zp                 ; z pis p©edposledn¡ho © dku
         jc        CompTZp9                 ; p©eru¨en¡
         call      CompT0Zp                 ; z pis posledn¡ho © dku
         jmp       short CompTZp9

; ------ z pis © dk– bez zkr cen¡

CompTZp6:add       bx,5                     ; po‡et © dk– k z pisu
         jz        CompTZp9                 ; nen¡ ‘ dn˜ © dek
CompTZp7:call      CompT0Zp                 ; z pis jednoho © dku
         jc        CompTZp9                 ; p©eru¨en¡
         dec       bx                       ; ‡¡ta‡ © dk– k z pisu
         jnz       CompTZp7                 ; z pis dal¨¡ho © dku
CompTZp9:ret

CompTZap ENDP

; -----------------------------------------------------------------------------
;        z pis © dku bufferu BP -> CY p©eru¨en¡ (uchov v  BX !)
; -----------------------------------------------------------------------------

CompT0Zp PROC      NEAR

; ------ d‚lka p©ipraven‚ho © dku DI -> CX

         mov       di,ds:[bp+CompOff]       ; offset p©ede¨l‚ho © dku
         call      CompT0Ln                 ; d‚lka © dku v bufferu

; ------ zv˜¨en¡ ukazatel– © dku

         add       ds:[bp+CompOff],cx       ; nov˜ offset p©ede¨l‚ho © dku
         add       word ptr ds:[bp+CompUkz],1 ; zv˜¨en¡ ukazatele ‡¡sla © dku
         adc       word ptr ds:[bp+CompUkz+2],0

; ------ test, zda se zapisuje ‡¡slo © dku

         test      byte ptr ds:[CompCfg],bit3 ; ‡¡sluj¡ se © dky ?
         jz        CompT0Z3                 ; © dky se ne‡¡sluj¡

; ------ £schova registr–

         push      bx
         push      cx
         push      di

; ------ vymaz n¡ bufferu ‡¡sla

         cld
         push      ds
         pop       es                       ; ES <- datov˜ segment
         mov       di,offset FileTxtP+1     ; buffer k dek¢dov n¡ ‡¡sla
         mov       si,di                    ; SI <- za‡ tek textu
         mov       ax,"  "                  ; mazac¡ znak mezery
         stosw
         stosw
         stosb                              ; 5 mezer

; ------ p©¡prava ‡¡sla © dku

         mov       ax,ds:[bp+CompUkz]       ; ‡¡slo © dku LOW
         mov       dx,ds:[bp+CompUkz+2]     ; ‡¡slo © dku HIGH

; ------ dek¢dov n¡ ‡¡sla do bufferu

         xor       bx,bx                    ; nen¡ oddˆlova‡ ani barva
         or        dx,dx                    ; je velk‚ ‡¡slo ?
         jnz       CompT0Z1                 ; je velk‚ ‡¡slo
         call      far ptr DekNumD          ; mal‚ ‡¡slo se dek¢duje zprava
         jmp       short CompT0Z2
CompT0Z1:mov       di,si                    ; DI <- za‡ tek bufferu
         call      far ptr DekNum           ; velk‚ ‡¡slo se dek¢duje zleva

; ------ oddˆlova‡ za ‡¡slem

CompT0Z2:cld
         mov       ax," :"
         stosw                              ; ulo‘en¡ oddˆlova‡e ": "

; ------ z pis textu ‡¡sla © dku do bufferu

         sub       di,si                    ; d‚lka textu
         mov       cx,di                    ; CX <- d‚lka textu
         call      CompOTxt                 ; z pis ‡¡sla © dku

; ------ n vrat registr–

         pop       di
         pop       cx
         pop       bx
         jc        CompT0Z9                 ; p©eru¨en¡

; ------ z pis textu © dku

CompT0Z3:call      Comp0Get                 ; adresa bufferu -> ES
         mov       si,di                    ; SI <- adresa © dku
         call      CompOTxt                 ; z pis textu © dku
         jc        CompT0Z9                 ; p©eru¨en¡
         call      CompOCr                  ; od© dkov n¡ textu
CompT0Z9:ret

CompT0Zp ENDP

; ------ oddˆlovac¡ ‡ ra

CompTOdd:mov       al,">"
         call      CompOChr                 ; z pis £vodn¡ho znaku
         jc        CompTOd9                 ; chyba
         mov       al,"Ä"                   ; grafick˜ znak
CompTOd2:call      CompOChr                 ; z pis znaku
         jc        CompTOd9                 ; chyba
         dec       dx
         jnz       CompTOd2
         call      CompOCr                  ; od© dkov n¡
CompTOd9:ret

; -----------------------------------------------------------------------------
;        synchronizace ukazatel– (akt. ukaz. na nov‚ shodn‚ © dky), CY=p©eru¨en¡
; -----------------------------------------------------------------------------

CompTSyn PROC      NEAR

         push      cx
         push      si
         push      di

; ------ posun dat na za‡ tek bufferu

         call      CompT1Dl                 ; uvolnˆn¡ bufferu 1
         call      CompT2Dl                 ; uvolnˆn¡ bufferu 2

; ------ doplnˆn¡ dat v bufferu na maximum

         call      Comp2Rea                 ; na‡ten¡ dat do bufferu 2
         jc        CompTSn9                 ; chyba
         call      Comp1Rea                 ; na‡ten¡ dat do bufferu 1
         jc        CompTSn9                 ; chyba

; ------ posun ukazatele bufferu 1

CompTSn2:mov       di,ds:[CompAOff]         ; offset aktu ln¡ho © dku 1
         call      CompT1Ln                 ; d‚lka © dku v bufferu 1
         mov       bx,cx                    ; BX <- £schova d‚lky © dku 1
         add       ds:[CompAOff],cx         ; posun ukazatele © dku v bufferu 1

; ------ posun ukazatele bufferu 2

         mov       di,ds:[CompAOf2]         ; offset aktu ln¡ho © dku 2
         call      CompT2Ln                 ; d‚lka © dku v bufferu 2
         add       ds:[CompAOf2],cx         ; posun ukazatele © dku v bufferu 2

; ------ test, zda je ji‘ konec dat

         or        bx,cx                    ; je konec dat ?
         jz        CompTSn9                 ; je konec dat

; ------ nalezen¡ shodn‚ho © dku s bufferem 1 v bufferu 2

         mov       di,ds:[CompAOff]         ; aktu ln¡ © dek v bufferu 1
         call      CompT1Ln                 ; d‚lka © dku v bufferu 1
         jcxz      CompTSn4                 ; nen¡ dal¨¡ © dek
         mov       si,di                    ; SI <- adresa aktu ln¡ho © dku 1
         call      CompT1Sr                 ; nalezen¡ © dku v bufferu 2
         jc        CompTSn4                 ; © dek nenalezen

; ------ nastaven¡ ukazatel– p©i zasynchronizov n¡

         mov       ds:[CompAOf2],di         ; synchronizace bufferu 2
         jmp       short CompTSn9

; ------ nalezen¡ shodn‚ho © dku s bufferem 2 v bufferu 1

CompTSn4:mov       di,ds:[CompAOf2]         ; aktu ln¡ © dek v bufferu 2
         call      CompT2Ln                 ; d‚lka © dku v bufferu 2
         jcxz      CompTSn2                 ; nen¡ dal¨¡ © dek
         mov       si,di                    ; SI <- adresa aktu ln¡ho © dku 2
         call      CompT2Sr                 ; nalezen¡ © dku v bufferu 1
         jc        CompTSn2                 ; © dek nenalezen

; ------ nastaven¡ ukazatel– p©i zasynchronizov n¡

         mov       ds:[CompAOff],di         ; synchronizace bufferu 1

; ------ n vrat registr–

CompTSn9:pop       di
         pop       si
         pop       cx
         ret

CompTSyn ENDP

; -----------------------------------------------------------------------------
;        nalezen¡ © dku SI (d‚lka CX) bufferu 1 v buffer 2
;   -> adresa © dku DI (v bufferu 2), CY=nenalezen (-> BP=definice bufferu 2)
; -----------------------------------------------------------------------------

CompT1Sr PROC      NEAR

         mov       bp,offset CompDef2       ; adresa definice bufferu 2
         jmp       short CompT2S0

CompT1Sr ENDP

; -----------------------------------------------------------------------------
;          nalezen¡ © dku SI (d‚lka CX) bufferu 2 v bufferu 1
;   -> adresa © dku DI (v bufferu 1), CY=nenalezen (-> BP=definice bufferu 1)
; -----------------------------------------------------------------------------

CompT2Sr PROC      NEAR

         mov       bp,offset CompDef1       ; adresa definice bufferu 1

; ------ £schova registr–

CompT2S0:push      bx
         mov       bx,cx                    ; BX <- d‚lka hledan‚ho © dku

; ------ v˜choz¡ adresa hledan‚ho © dku

         mov       di,ds:[bp+CompOff]       ; offset p©ede¨l‚ho © dku
         test      byte ptr ds:[CompPar],bit5 ; byl nalezen shodn˜ © dek ?
         jz        CompT2S4                 ; nebyl nalezen shodn˜ © dek
         call      CompT0Ln                 ; d‚lka © dku v bufferu
         jcxz      CompT2S7                 ; nen¡ nic v bufferu

; ------ adresa dal¨¡ho testovan‚ho © dku v bufferu -> DI

CompT2S3:add       di,cx                    ; adresa dal¨¡ho © dku
CompT2S4:cmp       di,ds:[bp+CompAOf]       ; je to je¨tˆ platn˜ © dek ?
         ja        CompT2S7                 ; © dek nenalezen

; ------ stanoven¡ d‚lky nov‚ho testovan‚ho © dku -> CX

         call      CompT0Ln                 ; d‚lka © dku v bufferu
         jcxz      CompT2S7                 ; nen¡ dal¨¡ © dek

; ------ porovn n¡ © dk–

         cmp       bx,cx                    ; shoduj¡ se d‚lky © dk– ?
         jne       CompT2S3                 ; d‚lky © dk– se neshoduj¡ - dal¨¡
         call      CompT0Cm                 ; porovn n¡ © dk–
         jc        CompT2S3                 ; © dek nenalezen - dal¨¡

; ------ ovˆ©en¡, zda se shoduj¡ i dal¨¡ © dky

         push      si
         push      di
         push      cx
         push      dx

         mov       dx,CompLSyn-1            ; po‡et © dk– pro zasynchronizov n¡
CompT2S5:add       di,cx                    ; adresa dal¨¡ho © dku v bufferu 1
         add       si,cx                    ; adresa dal¨¡ho © dku v bufferu 2
         call      CompT0Ln                 ; d‚lka dal¨¡ho © dku v bufferu 1
         clc
         jcxz      CompT2S6                 ; konec dat - to je OK
         push      bp
         xor       bp,ds:[Comp1X2]          ; definice druh‚ho bufferu
         cmp       si,ds:[bp+CompNum]       ; je to platn˜ © dek v druh‚m bufferu ?
         pop       bp
         jae       CompT2S6                 ; nen¡ ji‘ v bufferu - asi to je OK

         call      CompT0Cm                 ; porovn n¡ © dk–
         jc        CompT2S6                 ; © dky se neshoduj¡

         dec       dx                       ; ‡¡ta‡ © dk–
         jnz       CompT2S5                 ; test dal¨¡ch © dk–

CompT2S6:pop       dx
         pop       cx
         pop       di
         pop       si
         jnc       CompT2S8                 ; © dky se shoduj¡ OK

; ------ © dek nenalezen

CompT2S7:stc                                ; p©¡znak nenalezen¡ © dku

; ------ n vrat registr–

CompT2S8:pop       bx
         ret

CompT2Sr ENDP

; -----------------------------------------------------------------------------
;        porovn n¡ © dku SI (1. buffer) s © dkem DI (2. buffer), d‚lka CX
;            -> CY=© dky nesouhlas¡  (-> BP=adresa definice bufferu 2)
; -----------------------------------------------------------------------------

CompT1Cm PROC      NEAR

         mov       bp,offset CompDef2       ; definice bufferu 2

; ------ £schova registr–

CompT0Cm:push      cx
         push      si
         push      di
         push      es

; ------ porovn n¡ © dk–

         push      ds
         xor       bp,ds:[Comp1X2]          ; definice prvn¡ho bufferu
         call      Comp0Get                 ; adresa prvn¡ho bufferu -> ES
         push      es
         xor       bp,ds:[Comp1X2]          ; definice druh‚ho bufferu
         call      Comp0Get                 ; adresa druh‚ho bufferu -> ES
         pop       ds                       ; DS <- adresa prvn¡ho bufferu
         cld
         repe      cmpsb                    ; porovn n¡ obsahu bufferu
         pop       ds
         je        CompT1C2                 ; © dky souhlas¡ OK
         stc                                ; p©¡znak chyby

; ------ n vrat registr–

CompT1C2:pop       es
         pop       di
         pop       si
         pop       cx
         ret

CompT1Cm ENDP

; -----------------------------------------------------------------------------
;                  stanoven¡ d‚lky © dku DI v bufferu 2
;   -> CX=d‚lka © dku (nebo ‡ sti), CY=nenalezen konec © dku (CX=d‚lka zbytku)
;                  (-> BP=adresa definice bufferu 2)
; -----------------------------------------------------------------------------

CompT2Ln PROC      NEAR

         mov       bp,offset CompDef2       ; definice bufferu 2
         jmp       short CompT0Ln

CompT2Ln ENDP

; -----------------------------------------------------------------------------
;                  stanoven¡ d‚lky © dku DI v bufferu 1
;   -> CX=d‚lka © dku (nebo ‡ sti), CY=nenalezen konec © dku (CX=d‚lka zbytku)
;                  (-> BP=adresa definice bufferu 1)
; -----------------------------------------------------------------------------

CompT1Ln PROC      NEAR

         mov       bp,offset CompDef1       ; definice bufferu 1

; ------ £schova registr–

CompT0Ln:push      ax
         push      bx
         push      dx
         push      di
         push      es

; ------ p©¡prava ukazatel– bufferu

         call      Comp0Get                 ; adresa bufferu -> ES
         mov       cx,ds:[bp+CompNum]       ; po‡et bajt– v bufferu

; ------ p©¡prava velikosti dat k prohled n¡ -> CX

         mov       bx,di                    ; BX <- £schova za‡ tku © dku
         sub       cx,di                    ; zbytek dat
         jbe       CompT1L5                 ; nejsou dal¨¡ data
         cmp       cx,CompMaxL              ; je to v¡ce ne‘ maxim lnˆ ?
         jbe       CompT1L3                 ; je to OK
         mov       cx,CompMaxL              ; omezen¡ d‚lky © dku na maximum

; ------ nalezen¡ znaku konce © dku

CompT1L3:cld
         mov       al,LF                    ; hledan˜ znak konce © dku
         mov       dx,cx                    ; DX <- £schova d‚lky dat
         repne     scasb                    ; nalezen¡ znaku konce © dku
         je        CompT1L6                 ; konec © dku nalezen OK
         cmp       dx,CompMaxL              ; je omezen¡ d‚lky © dku ?
         je        CompT1L6                 ; bylo omezen¡ d‚lky © dku - OK

; ------ konec © dku nenalezen (zb˜v  m lo dat)

CompT1L5:stc                                ; p©¡znak, ‘e nen¡ konec © dku

; ------ stanoven¡ d‚lky © dku (DI=adresa dal¨¡ho © dku)

CompT1L6:pushf
         mov       cx,di                    ; CX <- za‡ tek nov‚ho © dku
         sub       cx,bx                    ; d‚lka © dku
         popf

; ------ n vrat registr–

CompT1L9:pop       es
         pop       di
         pop       dx
         pop       bx
         pop       ax
         ret

CompT1Ln ENDP

; -----------------------------------------------------------------------------
;        vypu¨tˆn¡ dat v bufferu 1 po p©ede¨l˜ (shodn˜) © dek
;      -> CY=nejsou data k vypou¨tˆn¡, BP=adresa definice bufferu 1
; -----------------------------------------------------------------------------

CompT1Dl PROC      NEAR

         mov       bp,offset CompDef1       ; definice bufferu 1

; ------ £schova registr–

CompT0Dl:push      cx
         push      si
         push      di
         push      es

; ------ p©¡prava registr– k operaci

         mov       si,ds:[bp+CompOff]       ; p©ede¨l˜ © dek v bufferu
         mov       cx,ds:[bp+CompNum]       ; po‡et bajt– v bufferu
         sub       cx,si                    ; velikost zbytku dat
         mov       ds:[bp+CompNum],cx       ; nov˜ po‡et bajt– v bufferu
         sub       ds:[bp+CompOff],si       ; posun p©ede¨l‚ho © dku
         sub       ds:[bp+CompAOf],si       ; posun aktu ln¡ho © dku
         call      Comp0Get                 ; adresa bufferu -> ES

; ------ test, zda je co vypou¨tˆt

         or        si,si                    ; jsou nˆjak  data ?
         stc                                ; p©¡znak chyby
         jz        CompT1D4                 ; nejsou ‘ dn  data k vypou¨tˆn¡

; ------ p©¡sun zbytku dat

         cld
         push      ds
         push      di
         xor       di,di                    ; DI <- ukl dac¡ adresa (-> NC)
         push      es
         pop       ds                       ; DS <- segment bufferu
         rep       movsb                    ; p©¡sun dat v bufferu
         pop       di
         pop       ds
                                          ;* zde je NC = operace OK
; ------ n vrat registr–

CompT1D4:pop       es
         pop       di
         pop       si
         pop       cx
         ret

CompT1Dl ENDP

; -----------------------------------------------------------------------------
;        vypu¨tˆn¡ dat v bufferu 2 po p©ede¨l˜ (shodn˜) © dek
;      -> CY=nejsou data k vypou¨tˆn¡, BP=adresa definice bufferu 2
; -----------------------------------------------------------------------------

CompT2Dl PROC      NEAR

         mov       bp,offset CompDef2       ; definice bufferu 2
         jmp       short CompT0Dl

CompT2Dl ENDP

; -----------------------------------------------------------------------------
;        porovn n¡ soubor– v bin rn¡m m¢du -> CY=porovn n¡ nedokon‡eno
; -----------------------------------------------------------------------------
;þ
CompBin  PROC      NEAR

; ------ na‡ten¡ dat do buffer–

CompBin1:call      Comp1Rea                 ; na‡ten¡ dat do bufferu 1
         jc        CompBin9                 ; chyba
         call      Comp2Rea                 ; na‡ten¡ dat do bufferu 2
         jc        CompBin9                 ; chyba

; ------ test, zda jsou dal¨¡ data

         mov       ax,ds:[CompNum1]         ; po‡et bajt– v bufferu 1
         or        ax,ds:[CompNum2]         ; je nˆco v nˆkter‚m bufferu ?
         jz        CompBin8                 ; nejsou dal¨¡ data

; ------ p©¡prava velikosti dat k porovn n¡ (men¨¡ po‡et bajt–)

         xor       si,si                    ; ukazatel v bufferu 1
         xor       di,di                    ; ukazatel v bufferu 2
         mov       cx,ds:[CompNum1]         ; po‡et bajt– v bufferu 1
         cmp       cx,ds:[CompNum2]         ; je m‚nˆ dat v bufferu 2 ?
         jbe       CompBin2                 ; je to OK
         mov       cx,ds:[CompNum2]         ; v bufferu 2 je m‚nˆ dat

; ------ porovn n¡ dat SI+DI/CX

CompBin2:jcxz      CompBin6                 ; nen¡ nic k porovn n¡
         mov       dx,si                    ; DX <- £schova ukazatele adresy
         push      ds
         call      Comp1Get                 ; adresa bufferu 1 -> ES
         push      es
         call      Comp2Get                 ; adresa bufferu 2 -> ES
         pop       ds                       ; DS <- adresa bufferu 1
         cld
         repe      cmpsb                    ; porovn n¡ obsahu bufferu
         pop       ds
         je        CompBin5                 ; data jsou shodn 

; ------ nalezen rozd¡l - n vrat ukazatele na chybu

         dec       si                       ; n vrat ukazatele na rozd¡ln  data
         dec       di
         cmp       si,dx                    ; je rozd¡ln˜ hned dal¨¡ bajt ?
         je        CompBin3                 ; je to hned dal¨¡ bajt
         and       byte ptr ds:[CompPar],not bit6 ; neulo‘en oddˆlova‡ BIN
CompBin3:inc       cx                       ; n vrat po‡tu zbyl˜ch bajt–

; ------ nalezen rozd¡l na offsetu SI

         call      CompBHls                 ; v˜pis hl ¨en¡ o chybˆ
         jc        CompBin9                 ; p©eru¨en¡ operace, dal¨¡ nebo chyba
         inc       si                       ; zv˜¨en¡ ukazatele dat
         inc       di
         dec       cx
         jmp       short CompBin2

; ------ ‡ st dat OK (je CX=0) - test, zda zbyla neporovnan  data

CompBin5:and       byte ptr ds:[CompPar],not bit6 ; neulo‘en oddˆlova‡ BIN
CompBin6:cmp       si,ds:[CompNum1]         ; zbylo nˆco v bufferu 1 ?
         jb        CompBin3                 ; zbylo nˆco v bufferu 1
         cmp       di,ds:[CompNum2]         ; zbylo nˆco v bufferu 2 ?
         jb        CompBin3                 ; zbylo nˆco v bufferu 2

; ------ vypr zdnˆn¡ buffer–

CompBin7:add       word ptr ds:[CompUkaz],si ; posun ukazatele souboru 1
         adc       word ptr ds:[CompUkaz+2],0
         mov       word ptr ds:[CompNum1],0 ; vypr zdnˆn¡ bufferu 1
         mov       word ptr ds:[CompNum2],0 ; vypr zdnˆn¡ bufferu 2
         jmp       short CompBin1           ; na‡ten¡ dal¨¡ch dat

; ------ vypr zdnˆn¡ bufferu v˜pisu

CompBin8:call      CompOWrt                 ; z pis obsahu v˜pisov‚ho bufferu
CompBin9:ret

CompBin  ENDP

; -----------------------------------------------------------------------------
;        hl ¨en¡ o chybˆ na adrese SI/DI v bin rn¡m m¢du (-> CY=p©eru¨en¡ operace, dal¨¡ nebo chyba)
; -----------------------------------------------------------------------------

CompBHls PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      dx
         push      di
         push      es
         push      bp
         push      si                       ; (mus¡ b˜t posledn¡ !!!)

; ------ z pis z hlav¡

         call      CompZahl                 ; z pis z hlav¡
         jnc       CompBHl3
CompBHl2:jmp       CompBHl9                 ; chyba

; ------ ulo‘en¡ oddˆlova‡e

CompBHl3:test      byte ptr ds:[CompPar],bit6 ; m  b˜t ulo‘en oddˆlova‡ ?
         jnz       CompBHl4                 ; oddˆlova‡ ji‘ byl ulo‘en
         or        byte ptr ds:[CompPar],bit6 ; p©¡znak ulo‘en¡ oddˆlova‡e
         mov       dx,21                    ; d‚lka oddˆlova‡e
         call      CompTOdd                 ; zobrazen¡ oddˆlova‡e
         jc        CompBHl2                 ; chyba

; ------ z pis adresy chyby

CompBHl4:pop       ax                       ; AX <- adresa chyby v bufferu
         push      ax
         xor       dx,dx                    ; DX <- 0
         add       ax,word ptr ds:[CompUkaz] ; ukazatel offsetu v souboru
         adc       dx,word ptr ds:[CompUkaz+2]
         xchg      ax,dx
         call      CompOWrd                 ; z pis adresy HIGH
         jc        CompBHl9                 ; chyba
         mov       al,":"
         call      CompOChr
         jc        CompBHl9                 ; chyba
         xchg      ax,dx
         call      CompOWrd                 ; z pis adresy LOW
         jc        CompBHl9                 ; chyba

; ------ 2 oddˆlovac¡ mezery

         call      CompOSpc
         jc        CompBHl9                 ; chyba
         call      CompOSpc
         jc        CompBHl9                 ; chyba

; ------ bajt HEX v prvn¡m souboru

         pop       si                       ; SI <- adresa
         push      si
         mov       bp,offset CompDef1       ; definice souboru 1
         call      CompBHXX                 ; z pis bajtu 1
         jc        CompBHl9                 ; chyba

; ------ bajt HEX v druh‚m souboru

         mov       bp,offset CompDef2       ; definice souboru 2
         call      CompBHXX                 ; z pis bajtu 2
         jc        CompBHl9                 ; chyba

; ------ druh  oddˆlovac¡ mezera

         call      CompOSpc
         jc        CompBHl9                 ; chyba

; ------ lev˜ apostrof

         mov       al,'"'
         call      CompOChr
         jc        CompBHl9

; ------ bajt ASCII v prvn¡m souboru

         mov       bp,offset CompDef1       ; definice souboru 1
         call      CompBHYY                 ; z pis bajtu 1
         jc        CompBHl9                 ; chyba

; ------ bajt ASCII v druh‚m souboru

         mov       bp,offset CompDef2       ; definice souboru 2
         call      CompBHYY                 ; z pis bajtu 2
         jc        CompBHl9                 ; chyba

; ------ prav˜ apostrof

         mov       al,'"'
         call      CompOChr
         jc        CompBHl9

; ------ z pis CR na konci

         call      CompOCr                  ; od© dkov n¡

; ------ n vrat registr–

CompBHl9:pop       si
         pop       bp
         pop       es
         pop       di
         pop       dx
         pop       cx
         pop       ax
         ret

CompBHls ENDP

; ------ z pis bajtu HEX SI z bufferu (BP=adresa definice souboru)

CompBHXX:call      Comp0Get                 ; adresa bufferu
         cmp       si,ds:[bp+CompNum]       ; je to platn˜ bajt ?
         jae       CompBHX1                 ; nen¡ to platn˜ bajt
         mov       al,es:[si]               ; bajt v 1. bufferu
         call      CompOByt                 ; z pis bajtu AL
         jmp       short CompBHX8

; ------ znak je neplatn˜

CompBHX1:mov       al,"-"
         call      CompOChr                 ; n hradn¡ znak
         jc        CompBHX9
         call      CompOChr
CompBHx8:jc        CompBHx9

; ------ oddˆlovac¡ mezera

         call      CompOSpc
CompBHX9:ret

; ------ z pis bajtu ASCII ES:SI z bufferu (BP=adresa definice souboru)

CompBHYY:call      Comp0Get                 ; adresa bufferu
         cmp       si,ds:[bp+CompNum]       ; je to platn˜ bajt ?
         jae       CompBHY1                 ; nen¡ to platn˜ bajt
         mov       al,es:[si]               ; bajt v 1. bufferu
         cmp       al," "                   ; je to platn˜ bajt ?
         jae       CompBHY2                 ; je to platn˜ bajt
CompBHY1:mov       al," "                   ; n hrada mezerou
CompBHY2:call      CompOChr
         ret

; -----------------------------------------------------------------------------
; z pis z hlav¡ na za‡ tku zobrazen¡ rozd¡lu souboru (CY=chyba, dal¨¡ nebo p©eru¨en¡)
; -----------------------------------------------------------------------------

CompZahl PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      si
         push      es

; ------ test, zda bylo zaps no z hlav¡

         test      byte ptr ds:[CompPar],bit3 ; bylo zaps no z hlav¡ ?
         jnz       CompZah3                 ; bylo ji‘ zaps no z hlav¡
         or        byte ptr ds:[CompPar],bit3+bit6 ; p©¡znak z pisu z hlav¡+oddˆlova‡

; ------ £vodn¡ od© dkov n¡

         call      CompOCr                  ; od© dkov n¡ textu
         jc        CompZah3

; ------ mezera p©ed jm‚ny

         call      CompOSpc                 ; z pis mezery p©ed jm‚ny
         jc        CompZah3

; ------ z pis jm‚na souboru 1

         push      ds
         pop       es
         mov       si,offset SRMnuFil+1     ; jm‚no souboru
         mov       cl,ds:[si-1]             ; d‚lka jm‚na souboru
         mov       ch,0
         call      CompOTxt                 ; z pis jm‚na souboru 1
         jc        CompZah3                 ; chyba

; ------ oddˆlova‡ mezi jm‚ny souboru

         mov       si,offset CompOdHl
         mov       cl,3
         call      CompOTxt                 ; z pis oddˆlova‡e text–
         jc        CompZah3                 ; chyba

; ------ z pis jm‚na souboru 2

         mov       si,offset CilPath
         mov       cx,ds:[CilPathN]
         call      CompOTxt                 ; z pis jm‚na souboru 2
         jc        CompZah3                 ; chyba

; ------ od© dkov n¡

         call      CompOCr                  ; od© dkov n¡
         jc        CompZah3

; ------ oddˆlovac¡ ‡ ra

         mov       cx,70
         mov       al,254                   ; £vodn¡ oddˆlova‡
CompZah2:call      CompOChr                 ; z pis znaku "="
         jc        CompZah3
         mov       al,"Í"
         loop      CompZah2
         call      CompOCr                  ; od© dkov n¡ textu
         jc        CompZah3                 ; chyba

; ------ posun ukazatel–

         mov       ax,ds:[CompONum]         ; po‡et bajt– v bufferu
         mov       ds:[CompOTop],ax         ; po‡ te‡n¡ adresa k zobrazen¡
         or        byte ptr ds:[CompPar],bit4 ; p©¡znak v˜stupu rozd¡l–

; ------ n vrat registr–

CompZah3:pop       es
         pop       si
         pop       cx
         pop       ax
         ret

CompZahl ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ dat do bufferu 1 (do pln‚ho bufferu) -> CY=p©eru¨en¡ operace
;                  (-> BP=adresa definice bufferu 1)
; -----------------------------------------------------------------------------

Comp1Rea PROC      NEAR

         mov       bp,offset CompDef1       ; definice bufferu 1

; ------ £schova registr–

Comp0Rea:push      ax
         push      cx
         push      di
         push      es

; ------ na‡ten¡ dat do bufferu

         call      Comp0Get                 ; adresa bufferu -> ES
         mov       di,ds:[bp+CompNum]       ; po‡et bajt– v bufferu
         mov       ax,ds:[bp+CompIdn]       ; identifik tor souboru
         mov       cx,ds:[CompBSiz]         ; velikost bufferu
         sub       cx,di                    ; zbytek m¡sta v bufferu
         jbe       Comp1Re9                 ; buffer je ji‘ pln˜
         call      far ptr ReadFile         ; na‡ten¡ dat ze souboru
         jc        Comp1Re9                 ; chyba

; ------ pro soubor 1 posun informa‡n¡ho kurzoru

         cmp       bp,offset CompDef1       ; je to soubor 1 ?
         jne       Comp1Re8                 ; nen¡ to soubor 1
         call      far ptr InfoKurz         ; zobrazen¡ informa‡n¡ho kurzoru
Comp1Re8:add       ds:[bp+CompNum],cx       ; zv˜¨en¡ po‡tu dat v bufferu
                                          ;* zde je NC !
; ------ n vrat registr–

Comp1Re9:pop       es
         pop       di
         pop       cx
         pop       ax
         ret

Comp1Rea ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ dat do bufferu 2 (do pln‚ho bufferu) -> CY=p©eru¨en¡ operace
;                  (-> BP=adresa definice bufferu 2)
; -----------------------------------------------------------------------------

Comp2Rea PROC      NEAR

         mov       bp,offset CompDef2       ; definice bufferu 2
         jmp       short Comp0Rea           ; na‡ten¡ dat do bufferu

Comp2Rea ENDP

; -----------------------------------------------------------------------------
;        adresa bufferu 1 -> ES, BP=adresa definice bufferu 1
; -----------------------------------------------------------------------------

Comp1Get PROC      NEAR

         mov       bp,offset CompDef1       ; definice bufferu 1
Comp0Get:push      ax
         mov       ax,ds:[bp+CompSeg]       ; segment bufferu
         call      far ptr GetDat           ; adresa bufferu 1 -> ES
         pop       ax
         ret

Comp1Get ENDP

; -----------------------------------------------------------------------------
;        adresa bufferu 2 -> ES, BP=adresa definice bufferu 2
; -----------------------------------------------------------------------------

Comp2Get PROC      NEAR

         mov       bp,offset CompDef2       ; definice bufferu 2
         jmp       short Comp0Get           ; adresa bufferu

Comp2Get ENDP

CodeFil  ENDS

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
;        hl ¨en¡ o porovn v n¡ soubor– nebo adres ©–
; -----------------------------------------------------------------------------

SS1MnLin label     byte
         db        2                        ; typ menu - vertik ln¡ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka volby
         dw        7                        ; po‡et platn˜ch polo‘ek menu
         dw        12                       ; celkov˜ po‡et polo‘ek menu

         dw        SS1MnPol                 ; adresa defini‡n¡ tabulky polo‘ek
         dw        SS1MnHlp                 ; adresa tabulky text– n povˆdy
         dw        Hlp@PorovnavaniSouboru   ; ‡¡slo str nky velk‚ n povˆdy
         dw        SS1MnBlk                 ; adresa blokovac¡ tabulky
         dw        SS1MnSwc                 ; adresa tabulky p©ep¡na‡–
         dw        SS1MnTit                 ; adresa titulu okna
         dw        SS1MnExe                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        6                        ; po‡ te‡n¡ pozice
         db        7                        ; po‡ te‡n¡ © dek
         db        40                       ; ¨¡©ka
         db        14                       ; v˜¨ka

SS1MnPol db        bit6,21,'Porovn m obsah',1
SS1MnPl1 dw        SS1MnPl4                 ; souboru | y ozna‡en˜ch | y v¨ech
         db        0,1
         dw        FileTxtP                 ; jm‚no souboru 1 | (nic)

         db        bit6,28,1
SS1MnPl2 dw        SS1MnPl7                 ; s | se soubory
         db        0,1
         dw        SRMnuFil                 ; jm‚no souboru 2 | (nic)
         db        0,' v protˆj¨¡m oknˆ...'

         db        bit6,38,'ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ'

         db        9,24,     '        Porovnat soubory'
         db        9+bit7,24,'        V˜pis do souboru'

         db        bit6+bit7,0

         db        9+bit7,27,'        Automatick  detekce'
         db        9+bit7,19,'        Textov˜ m¢d'
         db        9+bit7,19,'        Bin rn¡ m¢d'

         db        bit6+bit7,0

         db        9+bit7,24,'        O‡¡slov n¡ © dk–'
         db        9+bit7,22,'        Zkr cen˜ v˜pis'

SS1MnPl4 db        9,' souboru '
SS1MnPl5 db        20,'y ozna‡en˜ch soubor–'
SS1MnPl6 db        22,'y v¨ech soubor– v oknˆ'
SS1MnPl7 db        2,'s '
SS1MnPl8 db        10,'se soubory'

SS1MnSwc db        0,0,0,0,0,0
SS1MnBlk db        0,0,0,0,0,0,0

SS1MnTit db        17,'porovn n¡ soubor–'

SS1MnHlS db        28,'Soubory se budou porovn vat '

HelpS    SEGMENT   BYTE PUBLIC
SS1MnHlp db        34,'Porovn n¡ obsahu zvolen˜ch soubor–'

         db        41,'Nalezen‚ rozd¡ly budou vyps ny do souboru'

         db        47,'Automatick  volba textov‚ho nebo bin rn¡ho m¢du'

         db        44,1
         dw        SS1MnHlS
         db        'textovˆ se synchronizac¡ © dk– po neshodˆ'

         db        26,1
         dw        SS1MnHlS
         db        'bin rnˆ (bajt po bajtu)'

         db        46,'V textov‚m m¢du se budou vypisovat ‡¡sla © dk–'

         db        77,'Vypisovan‚ rozd¡ly budou omezeny na maxim lnˆ 5 © dk– (pouze pro textov˜ m¢d)'
HelpS    ENDS

SS1MnExe label     dword
         dd        CompFlX1                 ; Porovnat
         dd        CompFlV                  ; V˜pis
         dd        CompFlA                  ; Automat
         dd        CompFlT                  ; Textovˆ
         dd        CompFlB                  ; Bin rnˆ
         dd        CompFlL                  ; ž dky
         dd        CompFlZ                  ; Zkr cen˜

; ------ zad n¡ souboru k ulo‘en¡ v˜pisu

SSXMSLin label     byte
         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        3                        ; po‡et platn˜ch polo‘ek menu
         dw        5                        ; celkov˜ po‡et polo‘ek menu

         dw        SSXMLPol                 ; za‡ tek definice polo‘ek menu
         dw        SSXMLHlp                 ; adresa tabulky text– n povˆdy
         dw        Hlp@OperacePorovnavaniObsahuSouboru ; ‡¡slo str nky velk‚ n povˆdy
         dw        SSXMLBlk                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        SSXMLTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        20                       ; po‡ te‡n¡ pozice okna
         db        0                        ; po‡ te‡n¡ © dek okna
         db        43                       ; ¨¡©ka okna
         db        8                        ; v˜¨ka okna

         dw        FileMax                  ; maxim ln¡ d‚lka textu © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        1                        ; celkov˜ po‡et © dk–
         dw        1                        ; po‡et zobrazen˜ch © dk–

         db        bit3                     ; maska zad van˜ch znak– - soubor
         db        2,'?*    '               ; zak zan‚ znaky

         db        HistFile                 ; historie soubor–
         db        1                        ; po‡et p©edvoleb

         dw        CompVyp0-CompVyp         ; d‚lka p©edvolby
         dd        CompVyp                  ; p©edvolba

; ------ polo‘ky voleb

SSXMLPol db        bit6,31,'Jm‚no souboru k ulo‘en¡ v˜pisu:'
         db        0,0
         db        bit6+bit7,0
         db        1,7,'Prov‚st'
         db        1,6,'N vrat'

SSXMLBlk db        0,0,0                    ; blokovac¡ tabulka

SSXMLTit db        14,'ulo‘en¡ v˜pisu'

HelpS    SEGMENT   BYTE PUBLIC
SSXMLHlp db        69,'Zadejte jm‚no souboru, do kter‚ho bude prov dˆn v˜pis rozd¡l– soubor–'
         db        57,'Zah jen¡ operace porovn v n¡ soubor– s v˜pisem do souboru'
         db        3,1
         dw        MenuHlP2
HelpS    ENDS

; -----------------------------------------------------------------------------
;        hl ¨en¡ o nalezen¡ rozd¡lu mezi soubory
; -----------------------------------------------------------------------------

SS2MnLin label     byte

         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka volby
         dw        4                        ; po‡et platn˜ch polo‘ek menu
         dw        20                       ; celkov˜ po‡et polo‘ek menu

         dw        SS2MnPol                 ; adresa defini‡n¡ tabulky polo‘ek
         dw        SS2MnHlp                 ; adresa tabulky text– n povˆdy
         dw        Hlp@OperacePorovnavaniObsahuSouboru ; ‡¡slo str nky velk‚ n povˆdy
         dw        SS2MnBlk                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        SS2MnTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        6                        ; po‡ te‡n¡ pozice
         db        7                        ; po‡ te‡n¡ © dek
         db        74                       ; ¨¡©ka
         db        21                       ; v˜¨ka

         dw        255                      ; maxim ln¡ d‚lka © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        0                        ; celkov˜ po‡et © dk–
         dw        0                        ; po‡et zobrazen˜ch © dk–

         db        bit2                     ; maska zad van˜ch znak–
         db        0,'      '               ; dopl¤uj¡c¡ zak zan‚ znaky

         db        0                        ; identifik tor historie
         db        0                        ; po‡et p©edvoleb

SS2MnPol db        bit6,33,'Nalezen rozd¡l mezi souborem ',0,1
         dw        SRMnuFil

         db        bit6,9,'a ',0,3
SS2MnPl2 db        0
         dd        CilPath

         db        bit6+bit7,0

SS2MnPl3 label     byte

         REPT      12
         db        bit6,9,4,3
         db        0
         dd        0
         db        2,255                    ; mezery na doplnˆn¡
         ENDM

         db        bit6+bit7,0

         db        1,10,'Pokra‡ovat'
         db        1,5,'Dal¨¡'
         db        1,5,'V˜pis'
         db        1,6,'N vrat'

SS2MnBlk db        0,0,0,0

SS2MnTit db        14,'nalezen rozd¡l'

HelpS    SEGMENT   BYTE PUBLIC
SS2MnHlp db        45,'Pokra‡ov n¡ ve v˜pisu rozd¡l– v tomto souboru'
         db        40,'Pokra‡ov n¡ porovn v n¡m dal¨¡ho souboru'
         db        38,'P©esmˆrov n¡ v˜pisu rozd¡l– do souboru'
         db        3,1
         dw        MenuHlP2
HelpS    ENDS

; -----------------------------------------------------------------------------
;        hl ¨en¡ - v¨echny soubory shodn‚
; -----------------------------------------------------------------------------

CmpOKMnu label     byte

         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        1                        ; po‡et platn˜ch polo‘ek menu
         dw        6                        ; celkov˜ po‡et polo‘ek menu

         dw        CmpOKMnP                 ; za‡ tek definice polo‘ek menu
         dw        ChbLnMeH                 ; adresa tabulky text– n povˆdy
         dw        Hlp@OperacePorovnavaniObsahuSouboru ; ‡¡slo str nky velk‚ n povˆdy
         dw        CmpOKMnB                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        CmpOKMnT                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        23                       ; po‡ te‡n¡ pozice okna
         db        7                        ; po‡ te‡n¡ © dek okna
         db        44                       ; ¨¡©ka okna
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


CmpOKMnP db        bit6,0
         db        bit6,38,'Operace porovn v n¡ soubor– dokon‡ena.'
         db        bit6,30,'V¨echny soubory jsou ',0,'shodn‚',0,'.'
         db        bit6,0
         db        bit6+bit7,0
         db        1,5,'Konec'

CmpOKMnB db        0
CmpOKMnT db        14,'soubory shodn‚'

; -----------------------------------------------------------------------------
;        data k porovn n¡ soubor–
; -----------------------------------------------------------------------------

; ------ soubor v˜pisu

;FileOPtN dw        0                        ; d‚lka jm‚na v˜stupn¡ho souboru
;FileOPth label     byte
;         db        FileMax dup(0)           ; jm‚no v˜stupn¡ho souboru
;FileOIdn dw        0                        ; identifik tor v˜stupn¡ho souboru

CompONum dw        0                        ; po‡et bajt– ve v˜stupn¡m segmentu
CompOTop dw        0                        ; po‡ te‡n¡ adresa pro zobrazen¡
CompOSeg dw        0                        ; v˜stupn¡ segment pro v˜pis

; ------ 1. porovn van˜ soubor

;FileFilN dw        0                        ; d‚lka textu adres ©e + soubor 1
;FilePthN dw        0                        ; d‚lka textu adres ©e 1
;FilePath label     byte
;         db        255 dup(0)               ; buffer adres ©e + soubor 1

; ------ jm‚no 2. porovn van‚ho souboru

;CilPathN dw        0                        ; d‚lka c¡lov‚ cesty se souborem 2
;CilPath  label     byte
;         db        255 dup(0)               ; buffer c¡lov‚ cesty 2

CompOKur dw        0                        ; p–vodn¡ kurzor v neaktivn¡m oknˆ
CompOFrs dw        0                        ; p–vodn¡ prvn¡ polo‘ka neakt. okna

CompTx1  db        12,'Porovn v m ',0
CompTx2  db        5,0,' s ',0

CompOdHl db        ' - '

CompVyp  db        '$DOSMAN$.CMP'
CompVyp0 db        0

; ------ buffer souboru  1

CompDef1 label     word
         db        CompDef dup(0)           ; buffer definice souboru 1

CompSeg1 EQU       CompDef1+CompSeg         ; ‡¡slo segmentu souboru 1
CompNum1 EQU       CompDef1+CompNum         ; po‡et bajt– v bufferu 1
CompUkaz EQU       CompDef1+CompUkz         ; offset za‡ tku bufferu pro BIN m¢d
                                            ; ukazatel ‡¡sla p©ed. © dku pro TXT m¢d
CompOffs EQU       CompDef1+CompOff         ; offset p©ede¨l‚ho © dku souboru 1
CompAOff EQU       CompDef1+CompAOf         ; offset aktu ln¡ho © dku 1
CompIdn1 EQU       CompDef1+CompIdn         ; identifik tor souboru 1

; ------ buffer souboru 2

CompDef2 label     word
         db        CompDef dup(0)           ; buffer definice souboru 2

CompSeg2 EQU       CompDef2+CompSeg         ; ‡¡slo segmentu souboru 2
CompNum2 EQU       CompDef2+CompNum         ; po‡et bajt– v bufferu 2
CompUkz2 EQU       CompDef2+CompUkz         ; ukazatel ‡¡sla p©ed. © dku souboru 2
CompOff2 EQU       CompDef2+CompOff         ; offset p©ede¨l‚ho © dku souboru 2
CompAOf2 EQU       CompDef2+CompAOf         ; offset aktu ln¡ho © dku 2
CompIdn2 EQU       CompDef2+CompIdn         ; identifik tor souboru 2

; ------ ukazatele

CompLine dw        0                        ; ‡¡ta‡ © dk– pro jedno hl ¨en¡
CompBSiz dw        0                        ; velikost jednoho bufferu (bajt–)

Comp1X2  dw        0                        ; CompDef1 XOR CompDef2 (korekce adres)

;CompCfg  db        bit0+bit4                ; konfigurace
;                                            ;   bit 0: automatick‚ rozli¨en¡
;                                            ;   bit 1: textov˜
;                                            ;   bit 2: bin rn¡
;                                            ;   bit 3: 1=‡¡slov n¡ TXT © dk–
;                                            ;   bit 4: 1=zkr cen˜ v˜pis
;                                            ;   bit 7: 1=v˜pis do souboru

CompPar  db        0                        ; parametry (inicializace v¨e na 0)
                                            ;    bit 0: 1=v˜pis do souboru
                                            ;    bit 1: 1=je textov˜ m¢d
                                            ;    bit 2: 1=je bin rn¡ m¢d
                                            ;    bit 3: 1=ulo‘ena hlavi‡ka souboru
                                            ;    bit 4: 1=nalezeny rozd¡ly souboru
                                            ;    bit 5: 1=nalezen shodn˜ © dek
                                            ;    bit 6: 1=ulo‘en oddˆlova‡ BIN
                                            ;    bit 7: 1=nalezen rozd¡ln˜ soubor

Data     ENDS
         END

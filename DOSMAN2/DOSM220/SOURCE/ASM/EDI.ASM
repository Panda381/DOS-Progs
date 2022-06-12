
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                             E D I T O R
;
;                       textov˜ a bin rn¡ editor
;
; =============================================================================
;
; Ve©ejn‚ procedury:
;
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

;BLOKBLOK EQU       8000h                    ; velikost jednoho datov‚ho bloku
;BLOKTEST EQU       0c000h                   ; hranice pro testov n¡ bloku
;BLOKMAXN EQU       ((65535 - EdiABlok)/EdiBlokS)-1-4; maxim ln¡ po‡et blok– souboru
;MAXVTAB  EQU       8*30                     ; maxim lnˆ pozic promˆn. tabul tor–

INCLUDE  ASM\DEF.ASM

CodeEdi  SEGMENT   BYTE PUBLIC
         ASSUME    cs:CodeEdi,ds:Data

; -----------------------------------------------------------------------------
;        inicializace p©ep¡na‡– editoru
; -----------------------------------------------------------------------------

InitIEdi PROC      FAR

; ------ nalezen¡ dal¨¡ho parametru

InitIEd1:call      far ptr NextLIni         ; dal¨¡ © dek
         jnc       InitIEd2                 ; je dal¨¡ © dek OK
IniIEd12:ret

InitIEd2:cmp       byte ptr es:[di],"["
         je        IniIEd12
         call      far ptr JumpPTxt

         db        8,'EDITABUL'
         dw        InitIEd3

         db        8,'TEXTMARK'
         dw        InitIEd4

         db        0
         dw        InitIEd1

; ------ odsazen¡ tabul toru

InitIEd3:call      far ptr InitIWNm         ; na‡ten¡ ‡¡sla
         jc        IniIEd32                 ; chyba
         or        ax,ax                    ; platn‚ ‡¡slo ?
         jz        IniIEd32                 ; nen¡ platn‚ ‡¡slo
         cmp       ax,9999                  ; je platn‚ ‡¡slo ?
         ja        IniIEd32                 ; nen¡ platn‚ ‡¡slo
         mov       ds:[EdiTabul],ax         ; po‡et pozic na tabul tor
IniIEd32:jmp       short InitIEd1

; ------ textov  zna‡ka

InitIEd4:mov       byte ptr ds:[EdiZnTxt],0 ; nulov n¡ d‚lky zna‡ky
         call      far ptr InitISpc         ; vypu¨tˆn¡ mezer z textu
         cmp       byte ptr es:[di],'"'     ; je text v uvozovk ch ?
         jne       InitIE43                 ; nen¡ text
InitIE41:inc       di                       ; zv˜¨en¡ ukazatele textu
         mov       al,es:[di]               ; na‡ten¡ znaku textu
         cmp       al,TAB                   ; je to tabul tor ?
         je        IniIE412                 ; tabul tor je povolen
         cmp       al," "                   ; je to platn˜ znak ?
         jb        InitIE43                 ; nen¡ to platn˜ znak - konec textu
IniIE412:cmp       al,'"'                   ; jsou opˆt uvozovky ?
         jne       InitIE42                 ; nejsou uvozovky
         inc       di                       ; p©esko‡en¡ znaku uvozovek
         cmp       al,es:[di]               ; jsou opakovan‚ uvozovky ?
         jne       InitIE43                 ; nejsou opakovan‚ uvozovky
InitIE42:mov       bh,0
         mov       bl,ds:[EdiZnTxt]         ; d‚lka textu
         inc       bx                       ; zv˜¨en¡ d‚lky textu
         cmp       bl,10                    ; je buffer ji‘ pln˜ ?
         ja        InitIE43                 ; buffer je ji‘ pln˜
         mov       ds:[EdiZnTxt],bl         ; nov  d‚lka bufferu
         mov       ds:[EdiZnTxt+bx],al      ; ulo‘en¡ znaku
         jmp       short InitIE41           ; dal¨¡ znak

InitIE43:cmp       byte ptr ds:[EdiZnTxt],0 ; byla zad na nˆjak  zna‡ka ?
         jne       InitIE44                 ; byla zad na nˆjak  zna‡ka
         inc       byte ptr ds:[EdiZnTxt]   ; minim ln¡ d‚lka zna‡ky 1 znak
         mov       byte ptr ds:[EdiZnTxt+1],"þ" ; implicitn¡ zna‡ka
InitIE44:jmp       short IniIEd32

InitIEdi ENDP

; *****************************************************************************
;
;                     Editace soubor– (volba "Editace")
;
; *****************************************************************************

; ------ zobrazen¡

AWMMnuSZ PROC      FAR

         call      AWMMSESw                 ; nastaven¡ p©ep¡na‡– menu

         mov       ax,word ptr ds:[SMnuVert+MnuPoz] ; pozice p©edchoz¡ho okna
         add       ax,707h                  ; posun okna
         mov       word ptr ds:[si+MnuPoz],ax        ; pozice okna
         jmp       far ptr VertMenu

AWMMnuSZ ENDP


AWMMnuSE PROC      FAR

;; ------ nastaven¡ po‡tu z loh BAK
;
;         mov       al,ds:[EditBAK]          ; po‡et z loh BAK
;         aam                                ; konverze na 2 znaky BCD
;         xchg      ah,al                    ; oprava po©ad¡ ‡¡slic
;         add       ax,"00"                  ; konverze na ASCII znaky
;         cmp       al,"0"                   ; prvn¡ ‡¡slice = 0 ?
;         jne       AWMMnSE1                 ; prvn¡ ‡¡slice nen¡ 0
;         mov       al," "                   ; potla‡en¡ nev˜znamn‚ nuly
;AWMMnSE1:mov       word ptr ds:[SEMnVPl1],ax ; ozna‡en¡ po‡tu z loh

; ------ nastaven¡ p©ep¡na‡–

         call      AWMMSESw                 ; nastaven¡ p©ep¡na‡– menu

         mov       ax,word ptr ds:[SMnuVert+MnuPoz] ; pozice p©edchoz¡ho okna
         add       ax,107h                  ; posun okna
         mov       word ptr ds:[si+MnuPoz],ax        ; pozice okna

         jmp       far ptr VertMenu

AWMMnuSE ENDP

AWEMnuTb db        bit0 ;+bit7                ; kurzor
         db        bit1 ;+bit7                ; ozna‡en‚
         db        bit3                     ; zadan‚

; ------ volba Automaticky

AWMMnSEA PROC      FAR

         mov       al,bit1+bit2             ; automatick˜ m¢d

AWMMSEA1:and       byte ptr ds:[OpenEMod],not bit1+bit2
         or        ds:[OpenEMod],al         ; m¢d otev©en¡ editoru
AWMMSEA2:call      AWMMSESw                 ; nastaven¡ p©ep¡na‡– menu
         call      far ptr DispMnu          ; nov‚ zobrazen¡ menu
         ret

AWMMnSEA ENDP

; ------ volba Textov˜

AWMMnSET PROC      FAR

         mov       al,0                     ; textov˜ m¢d
         jmp       short AWMMSEA1

AWMMnSET ENDP

; ------ volba Bin rn¡ m¢d

AWMMnSEB PROC      FAR

         mov       al,bit2                  ; bin rn¡ m¢d
         jmp       short AWMMSEA1

AWMMnSEB ENDP

; ------ volba Hexadecim ln¡

AWMMnSEH PROC      FAR

         mov       al,bit1                  ; hex. m¢d
         jmp       short AWMMSEA1

AWMMnSEH ENDP

; ------ volba Datum a ‡as

AWMMnSED PROC      FAR

         xor       byte ptr ds:[OpenEMod],bit0 ; zmˆna p©¡znaku
         jmp       short AWMMSEA2

AWMMnSED ENDP

;; ------ po‡et z loh BAK
;
;AWMMnSEP PROC      FAR
;
;         push      ds
;         pop       es                       ; ES <- datov˜ segment
;         mov       bx,99                    ; maxim ln¡ hodnota ‡¡sla
;         mov       ch,0                     ; minim ln¡ hodnota ‡¡sla
;         mov       cl,2                     ; d‚lka textu
;         mov       dx,word ptr ds:[si+MnuPoz] ; po‡ te‡n¡ pozice menu
;         add       dx,7*HI + 16             ; pozice relativnˆ
;         mov       di,offset SEMnVPl1       ; buffer k dek¢dov n¡ pozic
;         push      si
;         mov       si,offset SEMnVHl1       ; text n povˆdy
;         call      far ptr MenuNum          ; zad n¡ pozic tabul toru
;         pop       si
;         mov       ds:[EditBAK],al          ; nov˜ po‡et z loh BAK
;         jmp       short AWMMSEA2
;
;AWMMnSEP ENDP

; ------ nastaven¡ p©ep¡na‡– (menu SI)

AWMMSESw PROC      NEAR

         push      ax
         push      dx

         mov       al,ds:[OpenEMod]         ; nastaven¡ p©ep¡na‡– pro menu
         mov       dl,bit4                  ; je datum a ‡as
         test      al,bit0                  ; je datum a ‡as ?
         jnz       AWMMSES2                 ; je datum a ‡as
         mov       dl,0                     ; nen¡ datum a ‡as

AWMMSES2:or        dl,bit1                  ; textov˜ m¢d
         test      al,bit1+bit2             ; je textov˜ m¢d ?
         jz        AWMMSES3                 ; je textov˜ m¢d
         xor       dl,bit1+bit3             ; hexadecim ln¡ m¢d
         test      al,bit2                  ; je hexadecim ln¡ m¢d ?
         jz        AWMMSES3                 ; je hexadecim ln¡ m¢d
         xor       dl,bit3+bit2             ; bin rn¡ m¢d
         test      al,bit1                  ; je bin rn¡ m¢d ?
         jz        AWMMSES3                 ; je bin rn¡ m¢d
         xor       dl,bit2+bit0             ; jinak automatick˜ m¢d

AWMMSES3:call      far ptr SetSwch          ; nastaven¡ p©ep¡na‡–

         pop       dx
         pop       ax
         ret

AWMMSESw ENDP

; ------ zah jen¡ operace zobrazen¡

EditMZ:  mov       bx,ds:[si+MnuAkt]
         mov       al,cs:[bx+AWEMnuTb-4-1]  ; parametry pro v˜bˆr polo‘ek
         mov       ah,ds:[OpenEMod]         ; m¢d otev©en¡ soubor–
         or        ah,bit3                  ; prohl¡‘e‡
         call      far ptr ClosMnuA         ; uzav©en¡ v¨ech oken menu
         jmp       short EditF1

; ------ zah jen¡ operace editace (volbou z menu)

EditM:   mov       bx,ds:[si+MnuAkt]        ; aktivn¡ zvolen  polo‘ka
         mov       al,cs:[bx+AWEMnuTb-5-1]  ; parametry pro v˜bˆr polo‘ek
         mov       ah,ds:[OpenEMod]         ; m¢d otev©en¡ soubor–
         and       ah,not bit3
         call      far ptr ClosMnuA         ; uzav©en¡ v¨ech oken menu
         jmp       short EditF1

; ------ vstup z funk‡n¡ kl vesy (AL=m¢d hled n¡ soubor–, AH=m¢d otev©en¡)

EditF    LABEL     FAR

         test      al,bit0                  ; je polo‘ka pod kurzorem ?
         jz        EditF1                   ; nen¡ polo‘ka pod kurzorem
         call      far ptr GetAKurz         ; poskytnut¡ aktivn¡ polo‘ky
         jc        EditF1                   ; nen¡ polo‘ka pod kurzorem
         test      byte ptr es:[si+FileAtr],ATRT ; je to platn  polo‘ka ?
         jz        EditF04                  ; je to cesta
         test      byte ptr es:[si+FileAtr],DIR ; je to adres © ?
         jz        EditF1                   ; nen¡ to adres ©
EditF04: mov       al,bit1                  ; n hrada volbou ozna‡en‚ polo‘ky

EditF1:  or        ah,bit4+bit5             ; p©¡znak vytvo©en¡ souboru + INSERT
         mov       ds:[EditParm],ah         ; parametry editoru

         and       byte ptr ds:[OldESwch],not bit0+bit1+bit2
         and       byte ptr ds:[OldESwc2],not bit2

         push      ax

         mov       al,ah
         and       al,bit1+bit2             ; m¢d otev©en¡
         cmp       al,bit1+bit2
         je        EditF100

         or        ds:[OldESwch],al

EditF100:test      ah,bit3                  ; prohl¡‘e‡ ?
         jz        EditF101                 ; nen¡ prohl¡‘e‡
         or        byte ptr ds:[OldESwch],bit0 ; prohl¡‘e‡
         or        byte ptr ds:[OldESwc2],bit2 ; z kaz z pisu
         cmp       al,bit1                  ; je HEX m¢d ?
         je        EditF101                 ; je HEX m¢d
         or        byte ptr ds:[OldESwch],bit2 ; jinak je bin rn¡ m¢d

; ------ vytvo©en¡ segmentu bufferu

EditF101:mov       word ptr ds:[FileFSiz],0 ; velikost souboru - nen¡
         mov       word ptr ds:[FileFSiz+2],0
         mov       byte ptr ds:[FileFAtr],0 ; atributy bufferu - nejsou
         mov       byte ptr ds:[FilePath],0 ; p©¡znak, ‘e je buffer
         call      EditOpen                 ; vytvo©en¡ segmentu bufferu
         jc        EditF102                 ; nˆjak  chyba
         mov       ds:[EditSBuf],ax         ; segment bufferu
EditF102:pop       ax

         call      far ptr HistADir         ; ulo‘en¡ adres ©e do historie

         call      far ptr InitFFil         ; inicializace vyhled v n¡
         jc        Edit0                    ; nen¡ ‘ dn˜ soubor

         mov       ax,ds:[SegmTEdi]
         or        ax,ax
         jnz       EditF11
         call      far ptr CreatSeg         ; vytvo©en¡ segmentu tabulky
         jc        Edit0
         mov       ds:[SegmTEdi],ax         ; ‡¡slo segmentu
EditF11: mov       bx,2                     ; velikost
         call      far ptr ModiSegS
         jc        Edit0
         call      far ptr GetDat
         mov       es:[0],bx

         call      far ptr NulBreak         ; nulov n¡ p©¡znaku p©eru¨en¡
         mov       word ptr ds:[NumEdi],0   ; po‡et otev©en˜ch oken
         mov       word ptr ds:[EdiWAkt],1   ; aktivn¡ okno
         mov       word ptr ds:[EdiWNAkt],1
         mov       word ptr ds:[EdiW1Win],1
         mov       word ptr ds:[EdiW2Win],1
         mov       word ptr ds:[EditBSN],0  ; nen¡ ‘ dn˜ blok
;         mov       word ptr ds:[EditBLst],0
;         mov       word ptr ds:[EditBLsL],0
         and       byte ptr ds:[EditPar2],not bit6 ; aktivn¡ horn¡ okno

; ------ zad n¡ specifikace textem

         test      byte ptr ds:[FileTyp],bit3 ; je specifikace textem ?
         jnz       Edit002                  ; je specifikace textem
         jmp       Edit022                  ; nen¡ specifikace textem

Edit002: mov       si,offset SEZMnLin       ; menu zad n¡ soubor–
         call      Edi0Menu                 ; obsluha volby
         jnc       Edit02                   ; volba OK

; ------ p©eru¨en¡ operace

Edit0:   call      far ptr InfoClos         ; uzav©en¡ informa‡n¡ho © dku
         call      far ptr ClosFFil         ; uzav©en¡ obsluhy vyhled v n¡
         call      far ptr TestBEsc
         jnc       Edit01
         call      far ptr FlushChr
Edit01:  call      far ptr DispAll
         jmp       far ptr Main0

; ------ vytvo©en¡ souboru s dlouh˜m jm‚nem

Edit02:  mov       bl,ds:[LinNum]           ; po‡et znak– v bufferu
         mov       bh,0

         test      byte ptr ds:[Win95Par],bit2 ; povolena dlouh  jm‚na ?
         jnz       Edit02A8                 ; z kaz dlouh˜ch jmen
         test      byte ptr ds:[EditParm],bit3 ; je prohl¡‘e‡ ?
         jnz       Edit02A8                 ; je prohl¡‘e‡

         mov       si,offset LinBuff        ; zadan˜ soubor
         push      ds
         pop       es
         mov       byte ptr ds:[si+bx],bh   ; ozna‡en¡ konce textu
         call      far ptr CreOXFil         ; vytvo©en¡/otev©en¡ souboru s dlouh˜m jm‚nem
         jc        Edit02A8                 ; soubor nelze vytvo©it
         call      far ptr ClosFile         ; uzav©en¡ souboru
         call      far ptr ShrtXFil         ; p©evod na kr tk‚ jm‚no souboru
         mov       ds:[LinNum],cl           ; nov  d‚lka jm‚na souboru
         mov       bx,cx                    ; nov  d‚lka
         call      far ptr ModiWDir         ; modifikace obsahu adres ©e

; ------ rozbor zad n¡ parametr– operace

Edit02A8:cmp       byte ptr ds:[LinBuff+bx-1],"*"
         je        Edit021
         cmp       byte ptr ds:[LinBuff+bx-1],"."
         je        Edit021
         cmp       bl,1
         je        Edit020
         cmp       byte ptr ds:[LinBuff+bx-2],"."
         je        Edit021
         cmp       bl,2
         je        Edit020
         cmp       byte ptr ds:[LinBuff+bx-3],"."
         je        Edit021
         cmp       bl,3
         je        Edit020
         cmp       byte ptr ds:[LinBuff+bx-4],"."
         je        Edit021
Edit020: mov       byte ptr ds:[LinBuff+bx],"." ; poji¨Ÿovac¡ te‡ka jako p©¡pona
         inc       byte ptr ds:[LinNum]
Edit021: call      far ptr Rozbor           ; rozbor zad n¡ parametr– operace
         call      far ptr RozbFPth         ; doplnˆn¡ na pln‚ jm‚no

Edit022: call      far ptr InitFSet         ; inicializace ozna‡en¡ polo‘ek

; ------ poskytnut¡ souboru k editaci

Edit1:   call      far ptr DispTime         ; obsluha ‡asu
         call      far ptr GetFFil          ; poskytnut¡ souboru
         jc        Edit2                    ; nen¡ dal¨¡ soubor
         call      far ptr DispAll          ; zobrazen¡ souboru
         and       byte ptr ds:[EditParm],not bit4 ; byl nalezen nˆjak˜ soubor

; ------ zobrazen¡ informa‡n¡ho textu

         mov       di,offset NacitTxt
         call      far ptr InfFile          ; zobrazen¡ jm‚na polo‘ky

; ------ za©azen¡ souboru do seznamu editovan˜ch soubor–

         call      EditOpen                 ; otev©en¡ nalezen‚ho souboru
         jc        Edit2                    ; chyba (nap©. za©¡zen¡)

; ------ p©i zobrazen¡ detekce, zda se jedn  o textov˜ soubor

         test      byte ptr ds:[OldESwch],bit2 ; bin rn¡ m¢d ?
         jz        Edit16                   ; nen¡ bin rn¡ m¢d
         call      EditDetT                 ; detekce, zda je textov˜ soubor

; ------ p©¡prava pro dal¨¡ polo‘ku

Edit16:  call      far ptr TestBEsc         ; je p©eru¨en¡ operace ?
         jnc       Edit1
Edit19:  jmp       Edit9                    ; p©eru¨en¡


Edit2:   call      far ptr TestBEsc         ; je p©eru¨en¡ operace ?
         jc        Edit19                   ; je p©eru¨en¡ operace

; ------ vytvo©en¡ souboru, pokud nebyl nalezen

         test      byte ptr ds:[EditParm],bit4 ; byl soubor nalezen ?
         jz        Edit3                    ; soubor byl nalezen
         test      byte ptr ds:[FileTyp],bit3 ; je specifikace textem ?
         jz        Edit19                   ; nen¡ specifikace textem
         test      byte ptr ds:[EditParm],bit3 ; je prohl¡‘e‡ ?
         jnz       Edit19                   ; je prohl¡‘e‡

; ------ p©enesen¡ jm‚na souboru do bufferu

         mov       word ptr ds:[FileFSiz],0
         mov       word ptr ds:[FileFSiz+2],0 ; velikost souboru = 0
         mov       byte ptr ds:[FileFAtr],0

         push      ds
         pop       es
         mov       si,offset LinBuff        ; zadan‚ jm‚no souboru
         mov       ch,0
         mov       cl,ds:[LinNum]           ; d‚lka textu jm‚na souboru
         mov       ds:[FileFilN],cx         ; d‚lka textu jm‚na souboru
         mov       di,offset FilePath       ; buffer jm‚na
         cld
         push      cx
         rep       movsb                    ; p©enesen¡ zadan‚ho jm‚na
         pop       cx

; ------ normalizace jm‚na zadan‚ho adres ©e

         mov       si,offset FilePath       ; zadan‚ jm‚no adres ©e
         call      far ptr NormFile         ; normalizace jm‚na souboru
         jcxz      Edit19                   ; nebylo nic zad no - konec
         call      far ptr FullFile         ; korekce na pln‚ jm‚no souboru
         mov       ds:[FileFilN],cx         ; £schova d‚lky adres ©e
         add       si,cx                    ; konec jm‚na
Edit24:  dec       si
         dec       cx
         cmp       byte ptr ds:[si-1],"\"
         jne       Edit24
         cmp       byte ptr ds:[si-2],":"
         je        Edit25
         dec       cx
Edit25:  mov       ds:[FilePthN],cx

; ------ za©azen¡ nalezen‚ho souboru

         call      EditOpen                 ; otev©en¡ nalezen‚ho souboru
         jc        Edit31                   ; chyba

; ------ test, zda byl alespo¤ nˆjak˜ soubor

Edit3:   call      far ptr InfoClos         ; uzav©en¡ informa‡n¡ho © dku
         cmp       word ptr ds:[NumEdi],0   ; nalezen nˆjak˜ soubor ?
         jne       Edit32
Edit31:  jmp       Edit19                   ; nen¡ ‘ dn˜ soubor

Edit32:  and       byte ptr ds:[EditPar2],not bit4
         mov       ax,ds:[SegmTEdi]
         call      far ptr GetDat
         jc        Edit31
         mov       ax,es:[2]
         mov       ds:[EdiSAkt],ax
         mov       ds:[EdiS1Win],ax
         mov       ds:[EdiS2Win],ax
         or        ah,bit15/bit8            ; p©¡znak okna 2
         mov       ds:[EdiSNAkt],ax

         cmp       word ptr ds:[NumEdi],2
         jb        Edit34
         or        byte ptr ds:[EditPar2],bit4
         mov       ax,es:[4]
         mov       ds:[EdiS2Win],ax
         or        ah,bit15/bit8
         mov       ds:[EdiSNAkt],ax
         mov       word ptr ds:[EdiWNAkt],2
         mov       word ptr ds:[EdiW2Win],2

Edit34:
         or        byte ptr ds:[WindPar],bit6 ; p©¡znak re‘imu editace soubor–
         call      EditRozv                 ; rozvr‘en¡ rozm¡stˆn¡ oken

; ------ inicializace ukazatel– soubor–

         xor       bx,bx                    ; ukazatel segment– soubor–
         mov       cx,ds:[NumEdi]           ; po‡et otev©en˜ch soubor–
Edit342: inc       bx
         inc       bx
         mov       ax,ds:[SegmTEdi]         ; segment evidence soubor–
         call      far ptr GetDat           ; adresa segmentu
         mov       dx,es:[bx]               ; segment okna

         push      bx
         push      cx
         push      dx
         mov       di,EdiW1                 ; okno 1
         call      EditGetD                 ; poskytnut¡ adresy okna
         call      EdiCPgUX                 ; inicializace okna 1
         pop       dx
         pop       cx
         pop       bx

         push      bx
         push      cx
         or        dh,bit15/bit8
         mov       di,EdiW2                 ; okno 2
         call      EditGetD                 ; poskytnut¡ adresy okna
         call      EdiCPgUX                 ; inicializace okna 2
         pop       cx
         pop       bx
         loop      Edit342




         call      Edi2CtF1                 ; inicializace rozvr‘en¡ oken

                                            ; n vrat z procedur
EdiMain0 LABEL     FAR
;þ
         and       byte ptr ds:[ParInt24],not bit1 + bit2 ; zru¨en¡ p©eru¨en¡
         mov       word ptr ds:[LastErr],0  ; nulov n¡ p©¡znaku chyby
         and       byte ptr ds:[InfoPar],not bit0 ; zru¨en¡ p©¡znaku inf. © dku
;         call      Edi2CtF1                 ; inicializace rozvr‘en¡ oken
         call      far ptr NulBreak         ; nulov n¡ p©¡znaku p©eru¨en¡ BREAK
         call      far ptr ClosMnuA         ; uzav©en¡ v¨ech menu
         call      far ptr DispAll          ; obnoven¡ zobrazen¡ oken
         call      far ptr InfoClos         ; uzav©en¡ informa‡n¡ho © dku
         call      far ptr ClosFFil         ; uzav©en¡ obsluhy vyhled v n¡

Edit492:
         call      EditEdit

         and       byte ptr ds:[ParMous2],not bit4+bit5 ; zru¨en¡ z kaz– graf. my¨i
         call      far ptr RIniMous         ; reinicializace my¨i

; ------ ulo‘en¡ v¨ech soubor–

Edit493:



Edit49:  and       byte ptr ds:[WindPar],not bit6 ; zru¨en¡ p©¡znaku editace
         call      far ptr DispAll

; ------ uzav©en¡ datov˜ch blok– soubor–

Edit9:   mov       si,offset EditBSTb       ; tabulka p©idˆlen˜ch blok–
         mov       cx,ds:[EditBSN]          ; po‡et blok– v tabulce
         jcxz      Edit92                   ; nen¡ ‘ dn˜ blok
         mov       ax,6                     ; po‡et bajt– na popisova‡
         mul       cx                       ; offset konce
         add       si,ax                    ; adresa konce tabulky
Edit91:  sub       si,6                     ; posun adresy v tabulce
         mov       ax,ds:[si]               ; ‡¡slo datov‚ho bloku
         call      far ptr DelSeg           ; zru¨en¡ datov‚ho bloku
         mov       ds:[si],ax
         loop      Edit91                   ; dal¨¡ datov˜ blok

; ------ uzav©en¡ otev©en˜ch soubor–

Edit92:  call      far ptr NulBreak         ; nulov n¡ p©¡znaku p©eru¨en¡
         mov       cx,ds:[NumEdi]           ; po‡et oken
         jcxz      Edit944                  ; nen¡ ‘ dn‚ okno
         mov       bx,cx                    ; BX <- po‡et oken
         shl       bx,1                     ; offset konce tabulky
Edit93:  mov       ax,ds:[SegmTEdi]
         call      far ptr GetDat
         jc        Edit944
         mov       ax,es:[bx]               ; segment okna
         call      far ptr GetDat           ; adresa okna
         jc        Edit94
         push      ax
         mov       ax,es:[EdiIdent]         ; identifik tor souboru
         call      far ptr ClosFile         ; uzav©en¡ souboru
         pop       ax
Edit94:  call      far ptr DelSeg           ; zru¨en¡ datov‚ho segmentu
         dec       bx                       ; posun ukazatele v tabulce
         dec       bx
         loop      Edit93
         mov       ds:[NumEdi],cx           ; nen¡ otev©eno ‘ dn‚ okno

; ------ zru¨en¡ segmentu p©echodn‚ho souboru

Edit944: mov       ax,ds:[SegmTEdi]
         call      far ptr DelSeg
         mov       ds:[SegmTEdi],ax

; ------ zru¨en¡ segmentu bufferu

         mov       ax,ds:[EditSBuf]         ; segment bufferu
         call      far ptr DelSeg
         mov       ds:[EditSBuf],ax

; ------ uzav©en¡ a zru¨en¡ p©echodn‚ho souboru

Edit95:  call      EditTClo                 ; uzav©en¡ p©echodn‚ho souboru

; ------ uzav©en¡ re‘imu editace

         call      far ptr InfoClos         ; uzav©en¡ informa‡n¡ho © dku
         call      far ptr ClosFFil         ; uzav©en¡ obsluhy vyhled v n¡

         call      far ptr SizeLKur

Edit98:  call      far ptr DispAll


Edit99:  jmp       far ptr Main0

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                   Obsluha edita‡n¡ho okna z kl ves
;
; -----------------------------------------------------------------------------
; Procedury dodr‘uj¡ obsazen¡ registr–:
;            DX = ‡¡slo segmentu okna
;            ES = adresa segmentu okna
;            DI = offset definice okna v segmentu
;            BP = pomocn˜ registr (n vratov  adresa p©i synchronizaci oken ...)
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;þ
EditEdit PROC      NEAR

; ------ nov‚ zobrazen¡ oken

         call      EditRozv                 ; rozvr‘en¡ rozm¡stˆn¡ oken
         or        byte ptr ds:[EditPar2],bit3 ; p©¡znak zobrazen¡ v¨eho
         mov       byte ptr ds:[EditPrik],0 ; nulov n¡ prefixu kl ves

EditEdi0:call      EditAktA                 ; aktualizave oken

         call      EdiShift                 ; obsluha ozna‡ov n¡ bloku

         cmp       word ptr ds:[NumEdi],0   ; zbylo nˆjak‚ okno ?
         jne       EditEd02                 ; zbylo nˆjak‚ okno
         ret

EditEd02:call      EditSHlp                 ; p©¡prava p©ep¡na‡– n povˆdy
         call      far ptr InfoClos         ; uzav©en¡ informa‡n¡ho © dku
         test      byte ptr ds:[EditPar2],bit3 ; zobrazit v¨echno ?
         jz        EditEdi1                 ; nen¡ zobrazen¡ v¨eho
         call      far ptr DispAll          ; zobrazen¡ v¨eho
         jmp       short EditEdi2

; (Ned vat jen zobrazen¡ kurzoru - nap©. v HEX m¢du se neposouv  barevn˜ kurzor)

EditEdi1:test      byte ptr ds:[EditPar2],bit0+bit1+bit2 ; zobraz aktivn¡ okno ?
         jz        EditEdi2                 ; nen¡ zobrazen¡ aktivn¡ho okna
         call      DispEdiA                 ; zobrazen¡ aktivn¡ho okna
;         jmp       short EditEdi2
;
;EditEd12:
;test      byte ptr ds:[EditPar2],bit0 ; zobrazen¡ kurzoru ?
;         jz        EditEdi2                 ; nen¡ zobrazen¡ kurzoru
;         mov       ax,ds:[EdiSAkt]          ; aktivn¡ okno
;         call      DispENad                 ; zobrazen¡ nadpisu okna
;         call      DispKEdi                 ; zobrazen¡ kurzoru okna

; ------ vstup znaku z kl vesnice

EditEdi2:call      far ptr MouseInt         ; obsluha my¨i
         call      far ptr DispTime         ; zobrazen¡ ‡asu
         call      far ptr Darker           ; obsluha stm¡va‡e
         call      far ptr DispFHlp         ; zobrazen¡ n povˆdy k fn. kl ves m
         call      far ptr MenuFnK          ; obsluha menu funk‡n¡ch kl ves
         jc        EditEd21                 ; funkce nebyla
         jnz       EditEd22                 ; zvolena kl vesa

EditEd21:mov       ax,ds:[EdiSAkt]          ; aktivn¡ okno
         call      DispKEdi                 ; zobrazen¡ kurzoru
         call      far ptr MouseGet         ; vstup k¢du my¨i
         jnc       EditE212                 ; byl k¢d my¨i
         call      far ptr TestChar         ; test, zda je znak z kl vesnice
         jc        EditEdi2                 ; ‡ek n¡ na stisk kl vesy
         call      far ptr InpChar          ; vstup znaku z kl vesnice -> BX

; ------ p©¡prava k¢du kl vesy Shift-Esc

EditE212:cmp       bx,11bh                  ; je kl vesa ESC ?
         jne       EditEd22                 ; nen¡ kl vesa ESC
         test      byte ptr ds:[Presmyk],bit4 ; je Shift- ?
         jz        EditEd22                 ; nen¡ Shift-Esc
         mov       bh,81h                   ; symbolick˜ k¢d kl vesy Shift-Esc

EditEd22:call      far ptr NulBreak         ; nulov n¡ p©¡znaku p©eru¨en¡ BREAK
         and       byte ptr ds:[EditPar2],not bit0+bit1+bit2+bit3 ; p©¡znak

; ------ p©¡prava parametr– okna

         mov       dx,ds:[EdiSAkt]          ; aktu ln¡ okno
         call      EditGetD                 ; poskytnut¡ adresy okna -> ES
         mov       di,EdiW1                 ; definice pro okno 1
         or        dx,dx                    ; je aktivn¡ okno 2 ?
         jns       EditEdi3                 ; je aktivn¡ okno 1
         mov       di,EdiW2                 ; definice pro okno 2

; ------ £schova p©ep¡na‡–

EditEdi3:mov       al,es:[di+EdiParm1]
         mov       ds:[OldESwch],al         ; £schova p©ep¡na‡–
         mov       al,es:[EdiParm]
         and       al,not bit2
         and       byte ptr ds:[OldESwc2],bit2
         or        ds:[OldESwc2],al

; ------ test, zda byla prefixov  kl vesa

         mov       al,0
         xchg      al,ds:[EditPrik]         ; nulov n¡ prefixu
         cmp       al,0                     ; byl prefix ?
         je        EditEdi6                 ; nebyl prefix
         push      ax
         mov       ax,ds:[EdiSAkt]          ; segment aktivn¡ho okna
         call      DispENad                 ; nov‚ zobrazen¡ nadpisu
         pop       ax
         cmp       bh,MousXKod/HI           ; je k¢d my¨i ?
         je        EditEd45                 ; je k¢d my¨i

; ------ korekce kl vesy s Ctrl- na p¡smeno

         xchg      ax,bx
         call      far ptr UpCase
         cmp       al," "
         jae       EditEd41
         or        al,40h
EditEd41:mov       ah,0
         xchg      ax,bx

; ------ obsluha prefix–

         cmp       al,0ah                   ; Ctrl-J
         jne       EditEd42
;

EditEd42:cmp       al,0bh                   ; Ctrl-K
         jne       EditEd43
         call      EditEdiK                 ; obsluha Ctrl-K
         jmp       EditEdi0

EditEd43:cmp       al,0fh                   ; Ctrl-O
         jne       EditEd44
;

EditEd44:cmp       al,11h                   ; Ctrl-Q
         jne       EditEdi6
         call      EditEdiQ                 ; obsluha Ctrl-Q
EditEd45:jmp       EditEdi0

; ------ skok na obsluhu kl vesy BX

EditEdi6:call      EditEdi7                 ; obsluha kl vesy
         jmp       EditEdi0

EditEdi7:call      far ptr JumpBX           ; skok na obsluhu kl vesy
;þ
         dw        4b00h,EditLeft           ; kurzor vlevo
         dw        4d00h,EditRght           ; kurzor vpravo
         dw        5000h,EditDown           ; kurzor dol–
         dw        4800h,EditUp             ; kurzor nahoru

         dw        7400h,EditCRgh           ; Ctrl-vpravo
         dw        7404h,EditCRgh           ; Ctrl-Shift-vpravo
         dw        7300h,EditCLft           ; Ctrl-vlevo
         dw        7304h,EditCLft           ; Ctrl-Shift-vlevo

         dw        9800h,EditHlAU           ; Alt-nahoru (hled n¡ zpˆt)
         dw       0A000h,EditHlAD           ; Alt-dol– (hled n¡ vp©ed)

         dw        4900h,EditPgUp           ; PageUp o str nku nahoru
         dw        5100h,EditPgDn           ; PageDown o str nku dol–

         dw        8400h,EditCPgU           ; Ctrl-PageUp za‡ tek souboru
         dw        8404h,EditCPgU           ; Ctrl-Shift-PageUp
         dw        7700h,EditCPgU           ; Ctrl-Home za‡ tek souboru
         dw        7704h,EditCPgU           ; Ctrl-Shift-Home

         dw        7600h,EditCPgD           ; Ctrl-PageDown konec souboru
         dw        7604h,EditCPgD           ; Ctrl-Shift-PageDown
         dw        7500h,EditCPgD           ; Ctrl-End konec souboru
         dw        7504h,EditCPgD           ; Ctrl-Shift-End

         dw        1b1dh,Stor0Blk           ; Ctrl-] ulo‘en¡ bloku do bufferu
         dw        9200h,Stor0Blk           ; Ctrl-Insert ulo‘en¡ bloku
         dw        071eh,Retn0Blk           ; Ctrl-^ n vrat bloku

         dw        4700h,EditHome           ; Home za‡ tek © dku
         dw        4f00h,EditEnd            ; End konec © dku

;         dw        3b00h,EditF1             ; F1 n povˆda
         dw        3c00h,EditUloz           ; F2 ulo‘en¡ souboru
         dw        3d00h,EditF3             ; F3 za‡ tek bloku
         dw        3e00h,EditF4             ; F4 konec bloku
         dw        3f00h,EditF5             ; F5 kopie bloku
         dw        4000h,EditF6             ; F6 p©esun bloku
         dw        4100h,EditF7             ; F7 hled n¡
         dw        4200h,EditF8             ; F8 zru¨en¡ bloku
         dw        4300h,EditF9             ; F9 zobrazen¡ bloku
         dw        4400h,EditF10            ; F10 hlavn¡ menu

         dw        811bh,EditF10X           ; Ctrl-Esc automatick‚ menu

;         dw        5400h,EditSF1            ; Shift-F1 n povˆda
         dw        5500h,EditZap            ; Shift-F2 ulo‘en¡ se zad n¡m
         dw        5600h,EditUlBl           ; Shift-F3 ulo‘en¡ bloku
         dw        5700h,EditNew            ; Shift-F4 na‡ten¡ se zad n¡m
         dw        5800h,EditCtBl           ; Shift-F5 na‡ten¡ bloku
         dw        5900h,EditSF6            ; Shift-F6 uzav©en¡ okna
         dw        5A00h,EditSF7            ; Shift-F7 hled n¡ s n hradou
;         dw        5B00h,EditSF8            ; Shift-F8 obnoven¡ zmˆn
         dw        5C00h,EditSF9            ; Shift-F9 typ bloku
         dw        5D00h,EditSF10           ; Shift-F10 videom¢d EGA/VGA

         dw        5e00h,EditCtF1           ; Ctrl-F1 editace
         dw        5f00h,EditCtF2           ; Ctrl-F2 bin rn¡ m¢d
         dw        6000h,EditCtF3           ; Ctrl-F3 HEX m¢d
;         dw        6100h,EditCtF4           ;
         dw        6200h,EditCtF5           ; Ctrl-F5 tabul tor bˆ‘n˜ znak
         dw        6300h,EditCtF6           ; Ctrl-F6 optimalizace mezer
;         dw        6400h,EditCtF7           ; Ctrl-F7 zvl ¨tn¡ funkce
         dw        6500h,EditCtF8           ; Ctrl-F8 modifikace bloku
         dw        6600h,EditCtF9           ; Ctrl-F9 © dek nahoru
         dw        6700h,EditCF10           ; Ctrl-F10 © dek dol–

         dw        6800h,EditAF1            ; Alt-F1 zmˆna okna
         dw        6900h,EditAF2            ; Alt-F2 p©edchoz¡ soubor
         dw        6a00h,EditAF3            ; Alt-F3 dal¨¡ soubor
         dw        6b00h,EditAF4            ; Alt-F4 po‡et oken
         dw        6c00h,EditAF5            ; Alt-F5 syst‚mov  obrazovka
         dw        6d00h,EditAF6            ; Alt-F6 vertik ln¡ okna
         dw        6e00h,EditAF7            ; Alt-F7 synchronizace oken
         dw        6f00h,EditAF8            ; Alt-F8 nastaven¡ zna‡ky
         dw        7000h,EditAF9            ; Alt-F9 p©edchoz¡ zna‡ka
         dw        7100h,EditAF10           ; Alt-F10 dal¨¡ zna‡ka

         dw        7800h,EditAA1            ; Alt-1 soubor 1
         dw        7900h,EditAA1            ; Alt-2 soubor 2
         dw        7a00h,EditAA1            ; Alt-3 soubor 3
         dw        7b00h,EditAA1            ; Alt-4 soubor 4
         dw        7c00h,EditAA1            ; Alt-5 soubor 5
         dw        7d00h,EditAA1            ; Alt-6 soubor 6
         dw        7e00h,EditAA1            ; Alt-7 soubor 7
         dw        7f00h,EditAA1            ; Alt-8 soubor 8
         dw        8000h,EditAA1            ; Alt-9 soubor 9

         dw        011bh,EditEdi9           ; Esc n vrat

         dw        1e01h,EditCLft           ; Ctrl-A slovo vlevo
         dw        3002h,EditCtrB           ; Ctrl-B n povˆda
         dw        2e03h,EditPgDn           ; Ctrl-C str nku dol–
         dw        2004h,EditRght           ; Ctrl-D znak vpravo
         dw        1205h,EditUp             ; Ctrl-E nahoru
         dw        2106h,EditCRgh           ; Ctrl-F slovo vpravo
         dw        2207h,EditDelC           ; Ctrl-G zru¨en¡ znaku za kurzorem
         dw        2308h,EditBS             ; Ctrl-H zru¨en¡ znaku vlevo
         dw        1709h,EditTab            ; Ctrl-I tabul tor
         dw        240Ah,EditCtrJ           ; Ctrl-J n povˆda, speci ln¡ funkce
         dw        250Bh,EditCtrK           ; Ctrl-K soubory a bloky
         dw        260ch,EditHlCL           ; Ctrl-L pokra‡ov n¡ v hled n¡
         dw        320dh,EditEnt            ; Ctrl-M Enter
         dw        310eh,EditNLn            ; Ctrl-N vlo‘en¡ © dku
         dw        180fh,EditCtrO           ; Ctrl-O p©ep¡na‡e a parametry
;         dw        1910h,                   ; Ctrl-P ASCII tabulka
         dw        1011h,EditCtrQ           ; Ctrl-Q p©esuny kurzoru
         dw        1312h,EditPgUp           ; Ctrl-R str nka nahoru
         dw        1f13h,EditLeft           ; Ctrl-S znak vlevo
         dw        1414h,EditCtrT           ; Ctrl-T maz n¡ slova za kurzorem
;         dw        1615h,EditCtrU           ; Ctrl-U ???
         dw        2f16h,EditIN             ; Ctrl-V Insert
         dw        1117h,EditCtrW           ; Ctrl-W posun obraz. o © dek nahoru
         dw        2d18h,EditDown           ; Ctrl-X kurzor dol–
         dw        1519h,EditDelL           ; Ctrl-Y zru¨en¡ © dku
         dw        2c1ah,EditCtrZ           ; Ctrl-Z posun obraz. o © dek dol–

         dw        0e08h,EditBS             ; zru¨en¡ znaku p©ed kurzorem
         dw        5300h,EditDelC           ; zru¨en¡ znaku za kurzorem
         dw        9300h,EditCtrT           ; Ctrl-Delete maz n¡ slova za kurzorem
         dw        0e7fh,EditCtBS           ; Ctrl-BS maz n¡ slova p©ed kurzorem

         dw        5200h,EditIN             ; nastaven¡ p©ep¡na‡e INSERT

         dw        0f00h,EditSTab           ; Shift-TAB zpˆtn˜ tabul tor
         dw        0f09h,EditTab            ; TAB tabul tor

         dw        1c0dh,EditEnt            ; ENTER dal¨¡ © dek

         dw        MousXKod+MousXLP,EdiMous1 ; stisk lev‚ho tla‡¡tka my¨i
         dw        MousXKod+MousXLH,EdiMous4 ; dr‘en¡ lev‚ho tla‡¡tka my¨i
         dw        MousXKod+MousXLD,EdiMous1 ; dvoj¡ stisk lev‚ho tla‡¡tka

         dw        MousXKod+MousXRP,EdiMous3 ; stisk prav‚ho tla‡¡tka my¨i
         dw        MousXKod+MousXRH,EdiMous4 ; dr‘en¡ prav‚ho tla‡¡tka my¨i
         dw        MousXKod+MousXRD,EdiMous3 ; dvoj¡ stisk prav‚ho tla‡¡tka
         dw        MousXKod+MousXRR,EdiEShft ; uvolnˆn¡ prav‚ho tla‡¡tka my¨i

         dw        MousXKod+MousXMov,EdiMous4 ; posun my¨¡

         dw        0,EditChr

; ------ obsluha Ctrl-Q
;þ
EditEdiQ:call      far ptr JumpBX           ; skok na obsluhu kl vesy

         dw        "A",EditSF7              ; Ctrl-QA hled n¡ s n hradou
         dw        "B",EditCtQB             ; Ctrl-QB za‡ tek bloku
         dw        "C",EditCPgD             ; Ctrl-QC konec textu
         dw        "D",EditEnd              ; Ctrl-QD konec © dku
;         dw        "E",                     ; Ctrl-QE horn¡ okraj
         dw        "F",EditF7               ; Ctrl-QF hled n¡
         dw        "H",EditCtQH             ; Ctrl-QH maz n¡ po za‡ tek © dku
         dw        "K",EditCtQK             ; Ctrl-QK konec bloku
;         dw        "L",                     ; Ctrl-QL obnoven¡
         dw        "M",EditCtQM             ; Ctrl-QM £schova pozice
         dw        "P",EditCtQP             ; Ctrl-QP n vrat pozice
         dw        "R",EditCPgU             ; Ctrl-QR za‡ tek textu
         dw        "S",EditHome             ; Ctrl-QS za‡ tek © dku
         dw        "T",EditCtBS             ; Ctrl-QT maz n¡ slova p©ed kurzorem
;         dw        "X",                     ; Ctrl-QX doln¡ okraj
         dw        "Y",EditCtQY             ; Ctrl-QY maz n¡ po konec © dku
         dw        "Z",EditCtQZ             ; Ctrl-QZ nastaven¡ na pozici

         dw        0,EditEdiX

EditEdiX:ret

; ------ obsluha Ctrl-K

EditEdiK:call      far ptr JumpBX           ; skok na obsluhu kl vesy

         dw        "*",EditAF1              ; Ctrl-K* zmˆna okna
         dw        "-",EditAF2              ; Ctrl-K- p©edchoz¡ soubor
         dw        "+",EditAF3              ; Ctrl-K+ dal¨¡ soubor

;         dw        "A",
         dw        "B",EditF3               ; Ctrl-KB za‡ tek bloku
         dw        "C",EditF5               ; Ctrl-KC kop¡rov n¡ bloku
         dw        "D",EditCKD              ; Ctrl-KD ulo‘en¡ v¨ech soubor–+konec
;         dw        "G",                     ; Ctrl-KG - p©epnut¡ na soubor
         dw        "H",EditF9               ; Ctrl-KH zobrazen¡ bloku
         dw        "K",EditF4               ; Ctrl-KK konec bloku
         dw        "L",EditNew              ; Ctrl-KL otev©en¡ souboru
         dw        "N",EditSF9              ; Ctrl-KN typ bloku
;         dw        "P",                     ; Ctrl-KP tisk
         dw        "Q",EditEdi9             ; Ctrl-KQ p©eru¨en¡ editace
         dw        "R",EditCtBl             ; Ctrl-KR ‡ten¡ bloku
         dw        "S",EditUloz             ; Ctrl-KS ulo‘en¡ souboru
;         dw        "T",                     ; Ctrl-KT modifikace bloku
         dw        "V",EditF6               ; Ctrl-KV p©esun bloku
         dw        "W",EditUlBl             ; Ctrl-KW z pis bloku
;         dw        "X",                     ; Ctrl-KX start programu
         dw        "Y",EditF8               ; Ctrl-KY ru¨en¡ bloku

         dw        "1",EditAA2              ; Ctrl-K1 soubor 1
         dw        "2",EditAA2              ; Ctrl-K2 soubor 2
         dw        "3",EditAA2              ; Ctrl-K3 soubor 3
         dw        "4",EditAA2              ; Ctrl-K4 soubor 4
         dw        "5",EditAA2              ; Ctrl-K5 soubor 5
         dw        "6",EditAA2              ; Ctrl-K6 soubor 6
         dw        "7",EditAA2              ; Ctrl-K7 soubor 7
         dw        "8",EditAA2              ; Ctrl-K8 soubor 8
         dw        "9",EditAA2              ; Ctrl-K9 soubor 9

         dw        0,EditEdiX

; ------ stisk lev‚ho tla‡¡tka my¨i

EdiMous1:cmp       byte ptr ds:[MousePoz+1],0 ; je horn¡ © dek ?
         jne       EdiMous2                 ; nen¡ horn¡ © dek
         jmp       EditF10                  ; vyvol n¡ hlavn¡ho menu

EdiMous2:push      dx
         push      es
         mov       dx,ds:[EdiS1Win]         ; segment okna 1
         call      EditGetD                 ; adresa okna 1 -> ES
         mov       al,es:[EdiW1+EdiSir]     ; ¨¡©ka okna 1
         cmp       al,byte ptr ds:[MousePoz] ; je prav˜ okraj okna 1 ?
         je        EdiMou20                 ; je oddˆlovac¡ ‡ ra
         mov       al,es:[EdiW1+EdiVys]     ; v˜¨ka okna 1
         add       al,es:[EdiW1+EdiRad]     ; © dek pod oknem 1
         cmp       al,byte ptr ds:[MousePoz+1] ; je spodn¡ okraj okna 1?
EdiMou20:pop       es
         pop       dx
         je        EdiMou21                 ; nastaven¡ p©edˆl– mezi okny

         call      EdMousWn                 ; je kurzor my¨i v oknˆ ?
         jnc       EdiMous4                 ; kurzor my¨i je v oknˆ
         jmp       EditAF1                  ; zmˆna aktivn¡ho okna

EdiMou21:pop       ax                       ; zru¨en¡ n vratov‚ adresy
         jmp       EdVMPP40                 ; nastaven¡ rozmˆr–

EdiMou22:ret

; ------ stisk prav‚ho tla‡¡tka my¨i

EdiMous3:call      EdMousWn                 ; je kurzor my¨i v oknˆ ?
         jc        EdiMou22                 ; kurzor my¨i nen¡ v oknˆ
         call      EdiMou42                 ; veden¡ kurzoru my¨i
         call      EditAktA                 ; aktualizave oken
         call      EdiAktBl                 ; pokus o aktualizaci ukazatel– bloku
         call      EdiEShft                 ; ukon‡en¡ ozna‡ov n¡ bloku se SHIFT-
         jmp       EdiBShf0                 ; zah jen¡ ozna‡ov n¡ bloku

; ------ veden¡ kurzoru my¨¡

EdiMous4:call      EdMousWn                 ; je kurzor my¨i v oknˆ ?
         jc        EdiMou22                 ; kurzor my¨i nen¡ v oknˆ

; ------ prav‚ tla‡¡tko jen je-li ozna‡ov n¡

         test      byte ptr ds:[MouseKey],bit1 ; je prav‚ tla‡¡tko my¨i ?
         jz        EdiMou42                 ; nen¡ prav‚ tla‡¡tko my¨i
         test      byte ptr es:[EdiParm0],bit4 ; je ozna‡ov n¡ ?
         jz        EdiMou22                 ; nen¡ ozna‡ov n¡ bloku

; ------ zah jen¡ ozna‡ov n¡ bloku

EdiMou42:call      EdiBShft                 ; zah jen¡ ozna‡ov n¡ SHIFT-

         mov       ah,es:[di+EdiVys]        ; v˜¨ka okna
         sub       ah,1
         mov       al,byte ptr ds:[MousePoz+1] ; © dek s kurzorem my¨i
         sub       al,es:[di+EdiRad]        ; © dek relativnˆ v oknˆ
         jz        EdiMous5
         cmp       al,ah
         jae       EdiMous5
         dec       ax                       ; korekce
EdiMous5:test      byte ptr es:[di+EdiParm1],bit0 ; editace ?
         jz        EdiMous6                 ; je editace
         cmp       bl,MousXMov              ; je posun my¨¡ ?
         je        EdiMous9                 ; nic se neprovede
         shr       ah,1                     ; polovina v˜¨ky okna
         cmp       al,ah                    ; je horn¡ polovina okna ?
         jb        EdiMou52                 ; je horn¡ polovina okna
         jmp       EditPgDn                 ; str nka dol–
EdiMou52:jmp       EditPgUp                 ; str nka nahoru

EdiMous6:mov       ah,0

         add       ax,word ptr es:[di+EdiRTop] ; po‘adovan˜ © dek s kurzorem LOW
         mov       cx,word ptr es:[di+EdiRTop+2] ; po‘adovan˜ © dek HIGH
         adc       cx,0
         call      EditSetK                 ; nastaven¡ © dku s kurzorem
         mov       al,byte ptr ds:[MousePoz] ; pozice s kurzorem my¨i
         sub       al,es:[di+EdiPoz]        ; pozice relativnˆ v oknˆ
         mov       ah,0
         xor       cx,cx                    ; CX <- 0
         test      byte ptr es:[di+EdiParm1],bit1+bit2 ; je textov˜ m¢d ?
         jnz       EdiMousA                 ; nen¡ textov˜ m¢d
         mov       ah,es:[di+EdiSir]        ; ¨¡©ka okna
         dec       ah
         cmp       al,ah
         jb        EdiMous7
         inc       ax
EdiMous7:mov       ah,0
         add       ax,word ptr es:[di+EdiPTop] ; po‘adovan  pozice s kurzorem LOW
         mov       cx,word ptr es:[di+EdiPTop+2] ; po‘adovan  pozice HIGH
         adc       cx,0
EdiMous8:call      EditStKP                 ; nastaven¡ pozice na © dku
EdiMous9:call      EdiShift                 ; obsluha ozna‡ov n¡ SHIFT-
         ret

EdiMousA:test      byte ptr es:[di+EdiParm1],bit1 ; je HEX m¢d ?
         jz        EdiMous8                 ; nen¡ HEX m¢d
         mov       bl,byte ptr es:[di+EdiLSir] ; ¨¡©ka dat
         shl       bl,1                     ; * 2
         add       bl,byte ptr es:[di+EdiLSir] ; ¨¡©ka pole HEX + 1
         cmp       byte ptr es:[di+EdiSir],12 ; je zobrazen offset ?
         jb        EdiMousC                 ; nen¡ zobrazen offset
         sub       al,8                     ; ode‡ten¡ offsetu
         jc        EdiMousB                 ; p©ete‡en¡
         cmp       byte ptr es:[di+EdiSir],80 ; je offset 9 pozic ?
         jb        EdiMousC                 ; offset je 7 pozic
         add       bl,2*1 + 2               ; korekce ¨¡©ky pole HEX
         sub       al,11-8                  ; korekce pro dlouh˜ offset
         jnc       EdiMousC
EdiMousB:mov       al,0                     ; omezen¡ p©i podte‡en¡
EdiMousC:call      Edit1Hex                 ; je prvn¡ znak HEX pole
         cmp       al,bl                    ; je ASCII pole ?
         jb        EdiMousD                 ; nen¡ ASCII pole
         sub       al,bl                    ; offset pro ASCII pole
         or        byte ptr es:[di+EdiParm2],bit2 ; p©¡znak ASCII pole
         cmp       al,byte ptr es:[di+EdiLSir]
         jb        EdiMous8
         mov       al,byte ptr es:[di+EdiLSir]
         dec       ax
         jmp       short EdiMous8           ; nastaven¡ kurzoru

EdiMousD:and       byte ptr es:[di+EdiParm2],not bit2 ; p©¡znak HEX pole
         cmp       byte ptr es:[di+EdiSir],80 ; je offset 9 pozic ?
         jb        EdiMousE                 ; offset je 7 pozic
         cmp       al,4*3                   ; je prvn¡ ‡ st ?
         jb        EdiMousE
         dec       ax
         cmp       al,8*3                   ; je druh  ‡ st ?
         jb        EdiMousE
         dec       ax
         dec       ax
         cmp       al,12*3
         jb        EdiMousE
         dec       ax
EdiMousE:mov       bl,3
         div       bl                       ; v˜po‡et offsetu
         or        ah,ah                    ; bude 2. znak HEX ?
         jz        EdiMousF                 ; bude 1. znak HEX
         or        byte ptr es:[di+EdiParm2],bit1 ; je druh˜ znak HEX pole
EdiMousF:mov       ah,0
         jmp       short EdiMous8

; ------ test, zda je kurzor my¨i v oknˆ -> CY=nen¡

EdMousWn PROC      NEAR

         push      cx
         push      dx
         mov       dx,word ptr es:[di+EdiPoz] ; po‡ te‡n¡ pozice okna
         mov       cx,word ptr es:[di+EdiSir] ; rozmˆry okna
         call      far ptr MouseWin         ; je kurzor my¨i v oknˆ ?
         pop       dx
         pop       cx
         ret

EdMousWn ENDP

; ------ n vrat z procedury ESC

EditEdi9:pop       di                       ; zru¨en¡ n vratov‚ adresy
         or        byte ptr ds:[EditPar2],bit3 ; zobrazit v¨e

         mov       cx,ds:[NumEdi]           ; po‡et soubor–
         jcxz      EditEdiB
EditEdiA:mov       ax,ds:[SegmTEdi]
         call      far ptr GetDat
         jc        EditEdiB

         mov       ax,1                     ; ‡¡slo okna
         mov       dx,es:[2]                ; segment okna
         call      EditClos                 ; uzav©en¡ souboru
         jc        EditEdiC                 ; p©eru¨en¡ operace
         loop      EditEdiA

EditEdiB:ret

EditEdiC:jmp       EditEdi0                 ; pokra‡ov n¡ v editaci

EditEdit ENDP

; -----------------------------------------------------------------------------
;        Ctrl-J, Ctrl-K, Ctrl-O, Ctrl-Q
; -----------------------------------------------------------------------------

EditCtrJ:
EditCtrK:
EditCtrO:
EditCtrQ:
         mov       ds:[EditPrik],bl         ; p©¡znak prefixu
         or        byte ptr ds:[EditPar2],bit2 ; zobrazit okno
         ret

; ------ Ctrl-B n povˆda

EditCtrB PROC      NEAR

         xor       byte ptr ds:[HelpPar],bit0 ; zmˆna p©¡znaku mal‚ n povˆdy
         call      far ptr InitRows         ; inicializace v˜¨ky adres.  oken
         jmp       EditEdit

EditCtrB ENDP

; -----------------------------------------------------------------------------
;        uzav©en¡ souboru DX / ‡¡slo AX (CY=p©eru¨en¡) -> DX/AX nov‚ okno
; -----------------------------------------------------------------------------

EditClos PROC      NEAR

; ------ £schova registr–

         push      bx
         push      cx
         push      si
         push      di
         push      es
         push      bp
         xchg      ax,bp                    ; BP <- ‡¡slo okna

; ------ adresa okna

         call      EditGetD                 ; adresa okna
         jnc       EditCls1
EditCls0:jmp       EditCls9

; ------ test, zda byl soubor modifikov n

EditCls1:test      byte ptr es:[EdiParm],bit0 ; byl soubor modifikov n ?
         jz        EditCls4                 ; nebyl modifikov n

; ------ p©¡prava jm‚na souboru

         mov       cx,es:[EdiSoubN]         ; d‚lka specifikace souboru
         mov       si,es:[EdiSoubJ]         ; offset za‡ tku jm‚na
         sub       cx,si                    ; d‚lka jm‚na souboru
         add       si,EdiSoub               ; adresa jm‚na souboru
         mov       di,offset EUSMnSou+1     ; buffer jm‚na souboru
         mov       ds:[di-1],cl             ; d‚lka jm‚na souboru
         jcxz      EditCls3                 ; chyba ?
         cld
EditCls2:lods      byte ptr es:[si]
         mov       ds:[di],al
         inc       di
         loop      EditCls2

; ------ dotaz na dal¨¡ operaci

EditCls3:mov       si,offset EUSMnLin
         call      Edi0Menu
         jc        EditCls0                 ; p©eru¨en¡

; ------ soubor se neukl d 

         cmp       bl,2                     ; neukl d  se soubor ?
         je        EditCls4                 ; soubor se neukl d 

; ------ ulo‘en¡ souboru

         call      EditUloz                 ; ulo‘en¡ souboru DX
         jc        EditCls0                 ; chyba operace nebo p©eru¨en¡

; ------ uvolnˆn¡ blok– souboru

EditCls4:call      EditGetD                 ; adresa okna -> ES
         call      EditUIFT                 ; uvolnˆn¡ blok– z p©echodn‚ho souboru

; ------ uzav©en¡ souboru okna

         mov       ax,es:[EdiIdent]         ; identifik tor souboru (0=nen¡)
         call      far ptr ClosFile         ; uzav©en¡ souboru

; ------ zru¨en¡ segmentu definice bloku

         mov       ax,dx                    ; AX <- segment definice okna
         and       ah,not bit15/bit8        ; zru¨en¡ p©¡znaku okna
         call      far ptr DelSeg           ; zru¨en¡ segmentu definice okna

; ------ zru¨en¡ souboru ze seznamu

         mov       ax,ds:[SegmTEdi]         ; segment seznamu soubor–
         mov       di,bp                    ; DI <- ‡¡slo souboru
         shl       di,1                     ; offset v segmentu
         mov       cx,2                     ; po‡et bajt– k ru¨en¡
         call      far ptr DelDat           ; zru¨en¡ dat ze seznamu
         call      far ptr GetDat           ; adresa segmentu seznamu

; ------ sn¡‘en¡ po‡tu soubor–

         dec       word ptr ds:[NumEdi]     ; sn¡‘en¡ po‡tu soubor–
         clc
         jz        EditCls0                 ; nen¡ dal¨¡ soubor

; ------ ‡¡slo nov‚ho okna -> BP (SI=star‚)

EdiCls44:mov       si,bp                    ; SI <- £schova star‚ho ‡¡sla souboru
         cmp       bp,ds:[NumEdi]           ; je ‡¡slo souboru OK ?
         jbe       EditCls5                 ; ‡¡slo souboru je OK
         dec       bp                       ; oprava ‡¡sla souboru
         dec       di
         dec       di

; ------ segment nov‚ho okna -> DX (DI=star‚)

EditCls5:mov       di,es:[di]               ; DI <- segment nov‚ho okna
         xchg      di,dx                    ; DX <- nov‚ okno, DI <- star‚ okno
         mov       ax,di                    ; AX <- segment star‚ho okna
         and       ah,bit15/bit8            ; p©¡znak okna 2
         or        dh,ah                    ; p©¡znak okna 2

; ------ n hrada ‡¡sla oken

         xchg      ax,si                    ; AX <- star‚ ‡¡slo souboru
         mov       si,offset EdiWAkt        ; aktivn¡ okno
         mov       cx,4                     ; po‡et oken k n hradˆ
EdiCls51:cmp       ax,ds:[si]               ; je to uzav¡ran‚ okno ?
         je        EdiCls52                 ; je to uzav¡ran‚ okno
         ja        EdiCls53                 ; nen¡ nad uzav¡ran˜m oknem
         dec       word ptr ds:[si]         ; oprava ‡¡sla okna
         jmp       short EdiCls53

EdiCls52:mov       ds:[si],bp               ; ‡¡slo nov‚ho okna
EdiCls53:inc       si
         inc       si                       ; zv˜¨en¡ ukazatele oken
         loop      EdiCls51                 ; dal¨¡ okno

; ------ n hrada segment– oken

EdiCls54:cmp       di,ds:[EdiSAkt]          ; aktivn¡ okno
         jne       EdiCls55
         mov       ds:[EdiSAkt],dx          ; nov‚ aktivn¡ okno

EdiCls55:cmp       di,ds:[EdiSNAkt]         ; neaktivn¡ okno
         jne       EdiCls56
         mov       ds:[EdiSNAkt],dx         ; nov‚ neaktivn¡ okno

EdiCls56:push      di
         push      dx
         xor       di,bit15
         xor       dh,bit15/bit8

         cmp       di,ds:[EdiSAkt]          ; aktivn¡ okno
         jne       EdiCls57
         mov       ds:[EdiSAkt],dx          ; nov‚ aktivn¡ okno

EdiCls57:cmp       di,ds:[EdiSNAkt]         ; neaktivn¡ okno
         jne       EdiCls58
         mov       ds:[EdiSNAkt],dx         ; nov‚ neaktivn¡ okno

EdiCls58:and       di,not bit15
         and       dh,not bit15/bit8

         cmp       di,ds:[EdiS1Win]         ; segment okna 1
         jne       EdiCls59
         mov       ds:[EdiS1Win],dx         ; nov‚ okno 1

EdiCls59:cmp       di,ds:[EdiS2Win]         ; segment okna 2
         jne       EdiCls5A
         mov       ds:[EdiS2Win],dx         ; nov‚ okno 2

EdiCls5A:pop       dx
         pop       di

; ------ nov‚ rozvr‘en¡ oken

         push      bp

         call      EditRozv                 ; rozvr‘en¡ rozm¡stˆn¡ oken

; ------ altualizace okna

         call      Edi2CF0                  ; aktualizace aktivn¡ho okna

; ------ aktualizace parametr– kurzor–

         call      EditAktW                 ; aktualizace parametr– kurzor–

; ------ aktualizace parametr– bloku

         call      EdiAktBl                 ; pokus o aktualizaci ukazatel– bloku

         pop       bp
         clc

; ------ n vrat registr–

EditCls9:xchg      ax,bp                    ; AX <- nov‚ ‡¡slo okna
         pop       bp
         pop       es
         pop       di
         pop       si
         pop       cx
         pop       bx
         ret

EditClos ENDP

; -----------------------------------------------------------------------------
;        otev©en¡ nov‚ho souboru (Shift-F4)
; -----------------------------------------------------------------------------
;þ
EditNew  PROC      NEAR

; ------ zad n¡ jm‚na souboru

         mov       si,offset NEZMnLin       ; menu zad n¡ soubor–
         call      Edi0Menu                 ; obsluha volby
         jnc       EditNew1
EditNew0:ret

; ------ normalizace jm‚na souboru

EditNew1:call      far ptr NormFilL         ; normalizace jm‚na souboru
         jcxz      EditNew0                 ; nen¡ nic zad no
         call      far ptr FullFile         ; p©evod na pln‚ jm‚no souboru

; ------ test, zda je soubor ji‘ v jin‚m oknˆ

         push      ds
         pop       es
         call      EdiFWSrc                 ; nalezen¡ souboru v oknech
         jc        EditNw28                 ; soubor v jin‚m oknˆ nenalezen

; ------ chyba - soubor je ji‘ otev©en

         mov       si,offset EUJMnLin       ; hl ¨en¡, ‘e soubor je ji‘ otev©en
         call      Edi0Menu                 ; chybov‚ hl ¨en¡
         jmp       short EditNew0

; ------ £schova jm‚na souboru

EditNw28:mov       di,offset FilePath
         cld
         mov       ds:[FileFilN],cx         ; d‚lka jm‚na souboru
         mov       ds:[FilePthN],cx         ; d‚lka cesty
         push      cx
         inc       cx                       ; v‡etnˆ koncov‚ 0
         rep       movsb
         pop       cx
         dec       di                       ; n vrat na koncovou 0
EditNew2:dec       di                       ; posun o znak zpˆt
         cmp       byte ptr ds:[di],"\"
         je        EditNew3
         cmp       byte ptr ds:[di],":"
         je        EditNew3
         dec       word ptr ds:[FilePthN]   ; sn¡‘en¡ ‡¡ta‡e d‚lky cesty
         loop      EditNew2

; ------ za©azen¡ souboru do seznamu editovan˜ch soubor–

EditNew3:push      word ptr ds:[NumEdi]     ; po‡et otev©en˜ch soubor–
         call      EditOpen                 ; otev©en¡ nalezen‚ho souboru
         pop       ax                       ; AX <- po‡et otev©en˜ch soubor–
         jc        EditNew0                 ; chyba
         mov       bx,ds:[NumEdi]           ; posledn¡ soubor
         cmp       ax,bx                    ; p©ibyl nˆjak˜ soubor ?
         je        EditNew0                 ; nep©ibyl ‘ dn˜ soubor
         jmp       EditAF22                 ; nastaven¡ nov‚ho aktivn¡ho okna

EditNew  ENDP

; -----------------------------------------------------------------------------
;        ulo‘en¡ souboru DX podle zad n¡ (z pis do souboru)
; -----------------------------------------------------------------------------
; lok ln¡ promˆnn‚: SS:[BP-2] (2) d‚lka jm‚na souboru
; ni‡¡ v¨echny registry kromˆ DX, BP a DS !
; -----------------------------------------------------------------------------

EditZap  PROC      NEAR

; ------ £schova registr– (nemˆnit - navrac¡ se i uvnit© procedury !)

         push      bp
         mov       bp,sp
         sub       sp,FileMax+4

; ------ p©¡prava p©edvolby - jm‚no souboru

         or        byte ptr ds:[EditPar2],bit3 ; zobrazit v¨e
EditZap1:call      EditGetD                 ; adresa okna DX -> ES
         jnc       EditZp14
EditZp12:jmp       EditZap9
EditZp14:mov       ax,es:[EdiSoubN]         ; d‚lka jm‚na souboru
         mov       ds:[SEZZLPre],ax         ; d‚lka p©edvolby
         mov       ds:[SEZZLPre+4],es       ; segment adresy p©edvolby
         mov       ax,word ptr es:[EdiSize] ; velikost souboru
         mov       word ptr ds:[InfoKMax],ax ; velikost ukazatele
         mov       ax,word ptr es:[EdiSize+2]
         mov       word ptr ds:[InfoKMax+2],ax

; ------ zad n¡ jm‚na souboru k ulo‘en¡

         mov       si,offset SEZZMLin       ; menu volby souboru
         cmp       byte ptr es:[EdiSoubN],0 ; je to blok (m  jm‚no) ?
         jne       EditZp15                 ; je nˆjak‚ jm‚no - je to soubor
         mov       si,offset SEZBMLin       ; bude ulo‘en blok

EditZp15:call      Edi0Menu                 ; zad n¡ jm‚na souboru
         jc        EditZp12                 ; p©eru¨en¡ operace

; ------ normalizace jm‚na souboru

         call      far ptr NormFilL         ; normalizace jm‚na souboru
         clc
         jcxz      EditZp12                 ; nen¡ nic zad no
         call      far ptr FullFile         ; p©evod na pln‚ jm‚no souboru
         mov       ss:[bp-2],cx             ; d‚lka jm‚na souboru

; ------ £schova jm‚na souboru do bufferu v z sobn¡ku

         push      ss
         pop       es
         mov       di,sp
         mov       ds:[EUEMnLP2],cl         ; d‚lka jm‚na souboru
         mov       word ptr ds:[EUEMnLP2+1],di ; adresa jm‚na souboru
         mov       word ptr ds:[EUEMnLP2+3],es ; segment jm‚na souboru
         push      cx
         inc       cx                       ; v‡etnˆ koncov‚ 0
         cld
         rep       movsb                    ; £schova jm‚na souboru do z sobn¡ku
         pop       cx

; ------ test, zda je soubor ji‘ v nˆkter‚m oknˆ

         mov       si,sp                    ; SI <- jm‚no souboru
         call      EdiFWSrc                 ; nalezen¡ souboru v oknˆ
         jc        EditZp18                 ; soubor nen¡ v jin‚m oknˆ

; ------ je-li to toto okno, p©ejde se na bˆ‘n‚ ulo‘en¡ souboru

         push      dx
         and       dh,not bit15/bit8        ; zru¨en¡ p©¡znaku okna 2
         cmp       dx,ax                    ; souhlas¡ okno ?
         pop       dx
         jne       EditZp16                 ; okno nesouhlas¡

; ------ zmˆna na bˆ‘n‚ ulo‘en¡ aktivn¡ho okna

         mov       sp,bp
         pop       bp
         jmp       EditUloz                 ; ulo‘en¡ okna

; ------ hl ¨en¡, ‘e soubor je otev©en v jin‚m oknˆ

EditZp16:mov       si,offset EUJMnLin       ; hl ¨en¡
         jmp       EdiZap82

; ------ test, zda soubor ji‘ existuje

EditZp18:mov       si,sp                    ; ES:SI=jm‚no souboru
         call      far ptr ExisFile         ; test, zda soubor ji‘ existuje
         jc        EditZap2                 ; soubor neexistuje

; ------ pro za©¡zen¡ se dotaz neprov d¡

         call      far ptr OpenW            ; otev©en¡ pro z pis
         jc        EditZp1A                 ; chyba
         call      far ptr TestDev          ; je to za©¡zen¡ ?
         jnc       EditZp32                 ; z pis na za©¡zen¡
EditZp1A:call      far ptr ClosFile         ; zpˆt uzav©en¡

; ------ hl ¨en¡ - soubor ji‘ existuje

         mov       si,offset EUEMnLin       ; menu - soubor existuje
         call      Edi0Menu                 ; chybov‚ hl ¨en¡
         jc        EditZp59                 ; p©eru¨en¡ operace
         cmp       bl,2
         jb        EditZap2                 ; p©epis souboru
         ja        EditZp19
         jmp       EditZap1                 ; opakov n¡ zad n¡

; ------ otev©en¡ existuj¡c¡ho souboru pro z pis (p©id n¡ souboru)

EditZp19:mov       si,sp                    ; ES:SI=jm‚no souboru
         call      far ptr OpenRW           ; otev©en¡ souboru pro z pis
         jc        EditZap8                 ; soubor nelze otev©¡t

; ------ vystaven¡ ukazatele na konec souboru

         call      far ptr SizeFile         ; vystaven¡ ukazatele na konec
         jc        EditZap8                 ; chyba
         jmp       short EditZap3

; ------ vytvo©en¡ souboru

EditZap2:mov       si,sp                    ; SI <- jm‚no souboru
         call      far ptr CreatFil         ; vytvo©en¡ souboru
         jc        EditZap8                 ; chyba z pisu
EditZap3:call      far ptr ModiWDir         ; aktualizace adres ©e

; ------ hl ¨en¡ o prov dˆn¡ operace

EditZp32:call      far ptr InfoClr0         ; nulov n¡ informa‡n¡ho © dku
         mov       si,offset EdiZaTxt       ; text hl ¨en¡
         call      far ptr InfoTxt          ; dek¢dov n¡ textu
         mov       cx,ss:[bp-2]             ; d‚lka jm‚na souboru
         push      ss
         pop       es
         mov       si,sp
         call      far ptr InfoDek          ; dek¢dov n¡ jm‚na souboru
         xor       cx,cx                    ; ‡¡ta‡ kurzoru
         call      far ptr InfoKurz         ; zobrazen¡ hl ¨en¡

; ------ ulo‘en¡ souboru AX

         xor       bx,bx                    ; BX <- 0 ukazatel ‡¡sla bloku
EditZap4:call      EditBGet                 ; poskytnut¡ segmentu BX souboru DX
         jc        EditZap7                 ; chyba operace
         jz        EditZap5                 ; konec souboru
         xor       si,si                    ; SI <- offset po‡ tku dat
         call      far ptr WritFile         ; z pis dat do souboru
         jc        EditZap7                 ; chyba operace
         inc       bx                       ; zv˜¨en¡ ukazatele ‡¡sla bloku
         call      far ptr InfoKurz         ; zobrazen¡ informa‡n¡ho kurzoru
         jmp       short EditZap4           ; dal¨¡ blok souboru

; ------ uzav©en¡ v˜stupn¡ho souboru AX

EditZap5:call      far ptr ClosFile         ; uzav©en¡ souboru AX
         jc        EditZap7
         call      EditGetD                 ; adresa okna
         and       byte ptr es:[EdiParm],not bit0 ; zru¨en¡ p©¡znaku modifikace
EditZp59:jmp       short EditZap9

; ------ chyba z pisu do souboru

EditZap7:call      far ptr ClosFile         ; uzav©en¡ souboru AX
         call      far ptr ZapKrit          ; zapnut¡ kritick‚ sekce
         mov       si,sp
         push      ss
         pop       es
         call      far ptr DelFile          ; zru¨en¡ v˜stupn¡ho souboru
         call      far ptr VypKrit          ; vypnut¡ kritick‚ sekce

; ------ chybov‚ hl ¨en¡ - soubor nelze ulo‘it

EditZap8:call      far ptr TestBreak        ; p©eru¨en¡ operace ?
         jc        EditZap9                 ; je p©eru¨en¡ operace

         mov       si,sp
         mov       al,ss:[si]               ; disk
         mov       ds:[EUPMnLP1],al         ; disk
         mov       si,offset EURMnLin       ; chyba z pisu
         cmp       word ptr ds:[LastErr],Err_Plny_Disk ; je pln˜ disk ?
         jne       EdiZap82
         mov       si,offset EUPMnLin       ; disk pln˜
EdiZap82:call      Edi0Menu                 ; chybov‚ hl ¨en¡

; ------ n vrat registr–

EditZap9:mov       sp,bp
         pop       bp
         call      EditGetD                 ; obnoven¡ adresy okna
         call      far ptr InfoClos         ; uzav©en¡ informa‡n¡ho © dku
         ret

EditZap  ENDP

; -----------------------------------------------------------------------------
;        nalezen¡ souboru ES:SI/CX -> AX=segment okna, BX=‡¡slo okna, CY=nen¡
; -----------------------------------------------------------------------------

EdiFWSrc PROC      NEAR

; ------ £schova registr–

         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ p©¡prava k prohled n¡ oken

         mov       dx,ds:[NumEdi]           ; po‡et otev©en˜ch soubor–
         mov       bx,2                     ; ukazatel v tabulce soubor–
         mov       di,es                    ; DI <- segment jm‚na souboru

; ------ adresa souboru -> ES

EdiFWSr2:mov       ax,ds:[SegmTEdi]         ; segment ‡¡sel soubor–
         call      far ptr GetDat           ; adresa okna -> ES
         mov       ax,es:[bx]               ; segment okna
         call      far ptr GetDat           ; adresa okna
         jc        EdiFWSr6                 ; chyba?

; ------ test, zda to je hledan˜ soubor

         push      cx
         push      si
         push      di
         push      ds

         cmp       cx,es:[EdiSoubN]         ; souhlas¡ d‚lka jm‚na souboru ?
         jne       EdiFWSr3                 ; nesouhlas¡ d‚lka jm‚na souboru
         mov       ds,di                    ; DS <- segment jm‚na souboru
         mov       di,EdiSoub               ; jm‚no souboru
         cld
         repe      cmpsb                    ; porovn n¡ jm‚na souboru

EdiFWSr3:pop       ds
         pop       di
         pop       si
         pop       cx
         je        EdiFWSr8                 ; soubor nalezen OK

; ------ p©¡prava pro dal¨¡ soubor

EdiFWSr6:inc       bx
         inc       bx                       ; zv˜¨en¡ ukazatele soubor–
         dec       dx                       ; ‡¡ta‡ soubor–
         jnz       EdiFWSr2
         stc                                ; p©¡znak - soubor nenalezen
         jmp       short EdiFWSr9

; ------ soubor nalezen OK

EdiFWSr8:shr       bx,1                     ; BX = ‡¡slo okna
         mov       ds:[EUJMnLP1],cl         ; d‚lka jm‚na souboru
         mov       word ptr ds:[EUJMnLP1+3],es ; segment adresy jm‚na souboru

; ------ dek¢dov n¡ ‡¡sla okna pro hl ¨en¡

         push      ax
         push      bx

         mov       di,offset EUJMnLP2+1     ; buffer ‡¡sla okna
         push      ds
         pop       es
         xchg      ax,bx                    ; AX <- ‡¡slo okna
         xor       bx,bx                    ; BX <- 0 barva nen¡
         call      far ptr DekNumW          ; dek¢dov n¡ ‡¡sla okna
         sub       di,offset EUJMnLP2+1     ; d‚lka textu
         xchg      ax,di                    ; AX <- d‚lka textu
         mov       ds:[EUJMnLP2],al         ; d‚lka textu

         pop       bx
         pop       ax

         clc                                ; p©¡znak operace OK

; ------ n vrat registr–

EdiFWSr9:pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         ret

EdiFWSrc ENDP

; -----------------------------------------------------------------------------
;        ulo‘en¡ souboru DX (CY=chyba nebo p©eru¨en¡)
; -----------------------------------------------------------------------------
;þþþþþþþþþþþþþþþþþþþþþþþþþþþ
EditUloz PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,sp
         sub       sp,FileMax

; ------ adresa segmentu souboru -> ES

         or        byte ptr ds:[EditPar2],bit2 ; zobrazit okno
         call      EditGetD                 ; adresa okna DX -> ES
         jnc       EditUlz1                 ; okno je platn‚ OK
EditUlz0:jmp       EditUlz9                 ; chyba

; ------ p©enos jm‚na souboru do bufferu

EditUlz1:test      byte ptr es:[EdiParm],bit2 ; je z kaz z pisu ?
         stc                                ; p©¡znak chyby z pisu
         jnz       EditUlz0                 ; je z kaz z pisu do souboru
         mov       di,sp                    ; DI <- buffer v z sobn¡ku
         mov       si,EdiSoub               ; jm‚no souboru
         push      ds
         push      es
         pop       ds                       ; DS <- segment definice souboru
         push      ss
         pop       es                       ; ES <- segment bufferu v z sobn¡ku
         mov       cx,ds:[EdiSoubN]         ; d‚lka jm‚na souboru
         push      cx
         inc       cx                       ; v‡etnˆ koncov‚ 0
         cld
         rep       movsb                    ; p©enos jm‚na souboru do bufferu
         pop       cx                       ; CX = d‚lka jm‚na souboru
         pop       ds

; ------ aktualizace oken s ukl dan˜m souborem

         mov       si,sp                    ; ES:SI=specifikace jm‚na souboru
         call      far ptr ModiWDir         ; aktualizace adres ©e

; ------ vytvo©en¡ p©echodn‚ho souboru ES:SI

         call      far ptr CreatPF          ; vytvo©en¡ p©echodn‚ho souboru
         jnc       EdiUlz18                 ; operace OK, soubor vytvo©en
         call      EditFFre                 ; uvolnˆn¡ nˆkter‚ho identifik toru
         jc        EdiUlz15                 ; nelze uvolnit dal¨¡ identifik tor
         mov       si,sp                    ; SI <- jm‚no vstupn¡ho souboru
         call      far ptr CreatPF          ; vytvo©en¡ p©echodn‚ho souboru
         jnc       EdiUlz18                 ; operace OK
EdiUlz15:jmp       EditUlz5                 ; chyba operace

; ------ ulo‘en¡ souboru AX

EdiUlz18:xor       bx,bx                    ; BX <- 0 ukazatel ‡¡sla bloku
EditUlz2:call      EditBGet                 ; poskytnut¡ segmentu BX souboru DX
         jnc       EditUl22                 ; operace OK
         jmp       EditUlz6                 ; chyba operace

EditUl22:jz        EditUlz3                 ; konec souboru
         xor       si,si                    ; SI <- offset po‡ tku dat
         call      far ptr WritFile         ; z pis dat do souboru
         jc        EditUlz6                 ; chyba operace
         inc       bx                       ; zv˜¨en¡ ukazatele ‡¡sla bloku
         jmp       short EditUlz2           ; dal¨¡ blok souboru

; ------ nastaven¡ data a ‡asu souboru

EditUlz3:call      EditGetD                 ; adresa okna -> ES
         test      byte ptr ds:[EditParm],bit0 ; zachov v  se datum a ‡as ?
         jz        EditUlz4                 ; datum a ‡as se nezachov v 
         push      dx
         mov       dx,es:[EdiDate]          ; p–vodn¡ datum souboru
         mov       cx,es:[EdiTime]          ; p–vodn¡ ‡as souboru
         call      far ptr SetDFile         ; nastaven¡ data a ‡asu souboru
         pop       dx

; ------ uzav©en¡ souboru

EditUlz4:call      far ptr ClosFile         ; uzav©en¡ v˜stupn¡ho souboru
         jc        EditUlz7                 ; chyba

; ------ n vrat atribut– souboru (nap©. HID a SYS)

         mov       cl,es:[EdiAtrib]         ; atributy jm‚na souboru
         test      byte ptr ds:[EditParm],bit0 ; zachov v  se datum a ‡as ?
         jnz       EditUl42                 ; datum a ‡as se zachov v 
         or        cl,ARC                   ; p©¡znak modifikace souboru
EditUl42:push      ss
         pop       es                       ; ES <- segment jm‚na souboru
         mov       si,sp                    ; ES:SI=specifikace jm‚na souboru
         call      far ptr SetAFile         ; n vrat atribut– souboru

; ------ zru¨en¡ vstupn¡ho souboru

         call      EditGetD                 ; adresa okna -> ES
         mov       ax,es:[EdiIdent]         ; identifik tor souboru
         call      far ptr ClosFile         ; uzav©en¡ souboru
         mov       es:[EdiIdent],ax         ; ozna‡en¡, ‘e soubor je uzav©en
         mov       si,EdiSoub               ; ES:SI = jm‚no vstupn¡ho souboru
;         call      EditDBak                 ; zru¨en¡ z loh BAK
         call      far ptr DelFile          ; zru¨en¡ v˜stupn¡ho souboru

; ------ p©ejmenov n¡ souboru

         call      far ptr ZapKrit          ; zapnut¡ kritick‚ sekce
         mov       di,si                    ; DI <- nov‚ jm‚no souboru
         mov       si,sp                    ; SI <- sou‡asn‚ jm‚no souboru
         push      dx
         mov       dx,es                    ; DX <- nov‚ jm‚no souboru
         push      ss
         pop       es                       ; ES <- sou‡asn‚ jm‚no souboru
         call      far ptr RenFile          ; p©ejmenov n¡ souboru
         pop       dx
         call      far ptr VypKrit          ; vypnut¡ kritick‚ sekce
EditUlz5:jc        EditUlz8                 ; ohl ¨en¡ chyby

; ------ zru¨en¡ p©¡znaku modifikace souboru

         call      EditGetD                 ; adresa okna

; ------ inicializace segmentu souboru

         call      EditUIni                 ; inicializace po ulo‘en¡
         clc
         jmp       short EditUlz9           ; operace OK

; ------ uzav©en¡ v˜stupn¡ho souboru p©i chybˆ

EditUlz6:call      far ptr ClosFile         ; uzav©en¡ v˜stupn¡ho souboru

; ------ zru¨en¡ v˜stupn¡ho souboru p©i chybˆ

EditUlz7:call      far ptr ZapKrit          ; zapnut¡ kritick‚ sekce
         mov       si,sp
         push      ss
         pop       es
         call      far ptr DelFile          ; zru¨en¡ v˜stupn¡ho souboru
         call      far ptr VypKrit          ; vypnut¡ kritick‚ sekce

; ------ chybov‚ hl ¨en¡ - soubor nelze ulo‘it

EditUlz8:call      far ptr TestBreak        ; p©eru¨en¡ operace ?
         jc        EditUlz9                 ; je p©eru¨en¡ operace

         call      EditGetD                 ; adresa okna
         mov       al,es:[EdiSoub]          ; disk
         mov       ds:[EUPMnLP1],al         ; disk
         mov       si,offset EURMnLin       ; chyba z pisu
         cmp       word ptr ds:[LastErr],Err_Plny_Disk ; je pln˜ disk ?
         jne       EdiUlz82
         mov       si,offset EUPMnLin       ; disk pln˜

EdiUlz82:call      Edi0Menu                 ; chybov‚ hl ¨en¡
;         stc                                ; p©¡znak chyby

; ------ n vrat registr–

EditUlz9:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

EditUloz ENDP

;; -----------------------------------------------------------------------------
;;        zru¨en¡ souboru ES:SI se z lohov n¡m
;; -----------------------------------------------------------------------------
;; lok ln¡ promˆnn‚: SS:[BP-2] (2) adresa jm‚na souboru
;;                   SS:[BP-3] (1) ‡¡ta‡ z loh BAK
;; -----------------------------------------------------------------------------
;
;EditDBak PROC      NEAR
;
;; ------ £schova registr–
;
;         push      ax
;         push      bx
;         push      cx
;         push      dx
;         push      si
;         push      di
;         push      bp
;         push      es
;         mov       bp,sp
;         sub       sp,FileMax*2
;         mov       dx,si                    ; DX <- £schova jm‚na souboru
;
;; ------ nen¡-li z lohov n¡, jen zru¨en¡ souboru
;
;         mov       bh,ds:[EditBak]          ; po‡et z loh BAK
;         or        bh,bh                    ; jsou z lohy BAK ?
;         jnz       EditDBk1                 ; jsou z lohy BAK
;         call      far ptr DelFile          ; zru¨en¡ souboru
;         jmp       short EditDBk9
;
;; ------ kopie jm‚na souboru
;
;EditDBk1:
;
;
;
;;
;;
;;
;;
;;; ------ test, zda v˜stupn¡ soubor bude BAK
;;
;;         mov       bh,ds:[EditBAK]          ; po‡et z loh BAK
;;         or        bh,bh                    ; bude soubor BAK ?
;;         jz        EdiUlz17                 ; nebude soubor BAK
;;
;;; ------ nalezen¡ p©¡pony jm‚na souboru
;;
;;         add       si,cx                    ; konec jm‚na souboru
;;         mov       di,si                    ; DI <- £schova konce jm‚na
;;EdiUlz11:cmp       byte ptr es:[si-1],"."
;;         je        EdiUlz13                 ; nalezena p©¡pona
;;         dec       si                       ; posun na p©edchoz¡ znak
;;         cmp       byte ptr es:[si],"\"     ; oddˆlova‡ ?
;;         je        EdiUlz12                 ; je ji‘ oddˆlova‡ - nen¡ p©¡pona
;;         cmp       byte ptr es:[si],":"
;;         je        EdiUlz12                 ; nen¡ p©¡pona
;;         loop      EdiUlz11                 ; dal¨¡ znak
;;EdiUlz12:mov       si,di                    ; SI <- n vrat konce jm‚na
;;
;;; ------ vytvo©en¡ p©¡pony BAK
;;
;;EdiUlz13:mov       word ptr es:[si],"AB"
;;         mov       word ptr es:[si+2],"K"
;;
;;;; ------ test, zda soubor ji‘ existuje
;;;
;;;         mov       si,sp                    ; SI <- jm‚no soubor
;;;         call      far ptr ExisFile         ; test existence souboru
;;
;;
;;
;;; ------ vytvo©en¡ c¡lov‚ho souboru ES:SI
;;
;;EdiUlz16:mov       si,sp                    ; SI <- jm‚no souboru
;;         call      far ptr CreatFil         ; vytvo©en¡ souboru
;;         jnc       EdiUlz18                 ; operace OK, soubor vytvo©en
;;         call      EditFFre                 ; uvolnˆn¡ nˆkter‚ho identifik toru
;;         jc        EditUlz5                 ; nelze uvolnit dal¨¡ identifik tor
;;         call      far ptr CreatFil         ; druh˜ pokus o vytvo©en¡
;;         jnc       EdiUlz18                 ; operace OK, soubor vytvo©en
;;         jmp       short EditUlz5           ; soubor nelze vytvo©it
;;
;
;; ------ n vrat registr–
;
;EditDBk9:mov       sp,bp
;         pop       es
;         pop       bp
;         pop       di
;         pop       si
;         pop       dx
;         pop       cx
;         pop       bx
;         pop       ax
;         ret
;
;EditDBak ENDP

; -----------------------------------------------------------------------------
;        inicializace po ulo‘en¡ (segment DX) (t‚‘ n vrat zmˆn souboru)
; -----------------------------------------------------------------------------

EditUIni PROC      NEAR

         call      EditGetD                 ; adresa okna -> ES
         and       byte ptr es:[EdiParm],not bit0 ;+bit1 ; zru¨en¡ p©¡znaku modifikace
         and       byte ptr es:[EdiParm0],not bit0+bit1 ; ukazatele bloku neplatn‚

; ------ uvolnˆn¡ blok– z p©echodn‚ho souboru

         call      EditUIFT                 ; uvolnˆn¡ blok– z p©echodn‚ho souboru

; ------ nastaven¡ nov‚ origin ln¡ velikosti souboru

         mov       ax,word ptr es:[EdiSize] ; velikost souboru LOW
         mov       word ptr es:[EdiOSize],ax ; to je p–vodn¡ velikost souboru
         mov       bx,word ptr es:[EdiSize+2]
         mov       word ptr es:[EdiOSize+2],bx

; ------ v˜po‡et nov‚ho po‡tu blok–

         add       ax,BLOKBLOK-1            ; bude zaokrouhlen¡ na blok
         adc       bx,0                     ; p©enos
         jc        EditUIn2                 ; chyba - soubor p©¡li¨ velk˜
                                            ; v˜po‡et z vis¡ na BLOKBLOK !
         shl       ax,1
         rcl       bx,1                     ; stanoven¡ po‡tu blok–
         jc        EditUIn2                 ; p©ete‡en¡
         cmp       bx,BLOKMAXN              ; maxim ln¡ po‡et popisova‡–
         jbe       EditUIn3                 ; po‡et blok– je OK
EditUIn2:mov       bx,BLOKMAXN AND not 1    ; omezen¡ na maxim ln¡ po‡et blok–
         mov       word ptr es:[EdiSize],0
         mov       word ptr es:[EdiOSize],0
;         mov       word ptr es:[EdiSize],(BLOKMAXN AND 1) * BLOKBLOK
;         mov       word ptr es:[EdiOSize],(BLOKMAXN AND 1) * BLOKBLOK
         mov       word ptr es:[EdiSize+2],BLOKMAXN/2
         mov       word ptr es:[EdiOSize+2],BLOKMAXN/2
EditUIn3:mov       es:[EdiNBlok],bx         ; po‡et blok– v tabulce
         mov       cx,bx                    ; CX <- po‡et blok–

; ------ nastaven¡ inicializa‡n¡ velikosti segmentu

         shl       bx,1
         shl       bx,1
         shl       bx,1                     ; velikost definice blok–
         mov       di,EdiABlok
         add       bx,di                    ; konec definice blok–
         mov       ax,dx                    ; AX <- segment okna
         and       ah,not bit15/bit8
         call      far ptr ModiSegS         ; nastaven¡ velikosti segmentu
         jc        EditUIn9                 ; chyba
         mov       es:[0],bx                ; velikost bloku

; ------ inicializace tabulky popisova‡–

         push      dx

         mov       si,word ptr es:[EdiSize] ; velikost LOW
         mov       dx,word ptr es:[EdiSize+2] ; velikost HIGH
         cld
         jcxz      EditUIn6                 ; nen¡ ‘ dn˜ blok
         xor       bx,bx                    ; popisova‡ - vstupn¡ soubor
EditUIn4:xor       ax,ax                    ; AX <- 0
         stosw                              ; nen¡ blok v pamˆti
         mov       ax,bx                    ; AX <- popisova‡ bloku v souboru
         stosw                              ; ulo‘en¡ popisova‡e bloku

         mov       ax,BLOKBLOK              ; velikost jednoho bloku
         sub       si,ax                    ; sn¡‘en¡ ‡¡ta‡e velikosti
         sbb       dx,0
         jnc       EditUIn5                 ; nen¡ je¨tˆ p©ete‡en¡
         add       si,ax                    ; n vrat velikosti v posledn¡m bloku
         xor       dx,dx                    ; DX <- 0
         xor       ax,ax                    ; AX <- 0
         xchg      ax,si                    ; AX <- velikost posledn¡ho bloku
EditUIn5:stosw                              ; po‡et bajt– v bloku

         mov       ax,-1                    ; p©¡znak - nezn m˜ po‡et © dk–
         stosw                              ; po‡et p©elom– © dk– nezn m˜

         inc       bx                       ; zv˜¨en¡ ukazatele ‡¡sla bloku
         loop      EditUIn4

EditUIn6:mov       word ptr es:[EdiRadku],0 ; po‡et © dk– nezn m˜
         mov       word ptr es:[EdiRadku+2],0

         pop       dx

; ------ aktualizace oken

EditUIn9:
;         xor       dh,bit15/bit8            ; okno 2
;         call      EditModA                 ; po‘adavek aktualizace okna
;         call      EditAktW                 ; aktualizace okna 2
;         xor       dh,bit15/bit8            ; okno 1
         call      EditModA                 ; po‘adavek aktualizace okna
         call      EditAktW                 ; aktualizace okna 1
         ret

EditUIni ENDP

; ------ uvolnˆn¡ blok– z p©echodn‚ho souboru, uvolnˆn¡ pamˆŸov˜ch blok–

EditUIFT:mov       di,EdiABlok              ; popisova‡e blok–
         mov       cx,es:[EdiNBlok]         ; po‡et blok–
         jcxz      EdiUIFT4                 ; nen¡ ‘ dn˜ blok
EdiUIFT2:mov       ax,es:[di+EdiBlokD]      ; identifik tor bloku
         inc       ax                       ; je blok p©idˆlen ?
         jz        EdiUIFT3                 ; blok nen¡ p©idˆlen
         dec       ax
         test      ah,bit15/bit8            ; je to p©echodn˜ soubor ?
         jz        EdiUIFT3                 ; nen¡ to p©edchodn˜ soubor
         call      EditTRes                 ; uvolnˆn¡ bloku souboru
EdiUIFT3:add       di,EdiBlokS
         loop      EdiUIFT2                 ; dal¨¡ blok

; ------ nulov n¡ tabulky blok– (‘ dn˜ buffer nen¡ pou‘it˜)

EdiUIFT4:mov       ax,dx                    ; AX <- segment okna
         and       ah,not bit15/bit8        ; nulov n¡ p©¡znaku okna 2
         mov       di,offset EditBSTb+2     ; tabulka pou‘it˜ch blok–
         mov       cx,ds:[EditBSN]          ; po‡et definic blok–
         jcxz      EdiUIFT9                 ; nen¡ ‘ dn˜ blok
EdiUIFT5:cmp       ds:[di],ax               ; je to obsluhovan‚ okno ?
         jne       EdiUIFT8                 ; nen¡ to obsluhovan‚ okno
         mov       word ptr ds:[di],0       ; je to ru¨en˜ blok - uvolnˆn¡

;         push      ax
;         mov       ax,ds:[di-2]             ; ‡¡slo segmentu bloku
;         cmp       ax,ds:[EditBLst]         ; je to posledn¡ blok ?
;         jne       EdiUIFT6                 ; nen¡ to posledn¡ blok
;         mov       word ptr ds:[EditBLst],0 ; zru¨en¡ popisova‡e posledn¡ho bloku
;EdiUIFT6:cmp       ax,ds:[EditBLsL]         ; je to p©edposledn¡ blok ?
;         jne       EdiUIFT7                 ; nen¡ to p©edposledn¡ blok
;         mov       word ptr ds:[EditBLsL],0 ; zru¨en¡ p©edposledn¡ho bloku
;EdiUIFT7:pop       ax

EdiUIFT8:add       di,6                     ; adresa dal¨¡ho popisova‡e
         loop      EdiUIFT5                 ; dal¨¡ blok
EdiUIFT9:ret

; -----------------------------------------------------------------------------
;        p©¡prava p©ep¡na‡– mal‚ n povˆdy
; -----------------------------------------------------------------------------

EditSHlp PROC      NEAR

; ------ £schova registr–

         push      ax
         push      dx
         push      di
         push      es

; ------ adresa aktivn¡ho okna -> ES:DI

         mov       dx,ds:[EdiSAkt]          ; aktivn¡ okno
         call      EditGetD                 ; adresa aktivn¡ho okna -> ES
         mov       ah,4                     ; zna‡ka pro zapnutou volbu
         mov       di,EdiW1                 ; definice okna 1
         test      byte ptr ds:[EditPar2],bit6 ; je aktivn¡ okno 2 ?
         jz        EditSHl0                 ; je aktivn¡ okno 1
         mov       di,EdiW2                 ; definice okna 2

; ------ zobrazen¡ blok–

EditSHl0:mov       al,"-"
         test      byte ptr es:[EdiW1+EdiParm2],bit5 ; je blok v oknˆ 1 ?
         jnz       EdiSHl02                 ; je blok v oknˆ 1
         test      byte ptr es:[EdiW2+EdiParm2],bit5 ; je blok v oknˆ 2 ?
         jz        EditSHl1                 ; nen¡ blok ani v oknˆ 2
EdiSHl02:mov       al,ah                    ; znak zapnut¡
EditSHl1:mov       ds:[HelpKZob],al         ; blok zobrazen

; ------ typ bloku

         mov       al,"/"                   ; textov˜ blok
         test      byte ptr es:[EdiParm],bit6+bit7 ; je textov˜ blok ?
         jz        EditSHl2                 ; je textov˜ blok
         mov       al,"="                   ; © dkov˜ blok
         test      byte ptr es:[EdiParm],bit7 ; je © dkov˜ blok ?
         jnz       EditSHl2                 ; je © dkov˜ blok
         mov       al,254                   ; jinak sloupcov˜ blok
EditSHl2:mov       ds:[HelpKTyp],al         ; typ bloku

; ------ editace

         mov       al,"-"
         test      byte ptr es:[di+EdiParm1],bit0 ; editace ?
         jnz       EditSHl3                 ; jen zobrazen¡
         mov       al,ah                    ; je editace
EditSHl3:mov       ds:[HelpKEdi],al         ; m¢d editace

; ------ bin rn¡ m¢d

         mov       al,"-"
         test      byte ptr es:[di+EdiParm1],bit2 ; je bin rn¡ m¢d ?
         jz        EditSHl4                 ; nen¡ bin rn¡ m¢d
         mov       al,ah                    ; znak p©ep¡na‡e menu
EditSHl4:mov       ds:[HelpKBin],al         ; bin rn¡ m¢d

; ------ HEX m¢d

         mov       al,"-"
         test      byte ptr es:[di+EdiParm1],bit1 ; je HEX m¢d ?
         jz        EditSHl5                 ; nen¡ HEX m¢d
         mov       al,ah                    ; je HEX m¢d
EditSHl5:mov       ds:[HelpKHex],al         ; HEX m¢d

; ------ zobrazen¡ tabul tor–

         mov       al,"-"
         test      byte ptr es:[di+EdiParm1],bit7 ; tabul tory platn‚ ?
         jnz       EditSHl6                 ; tabul tor je bˆ‘n˜ znak
         mov       al,ah                    ; tabul tor je platn˜
EditSHl6:mov       ds:[HelpKTab],al         ; zobrazen¡ tabul tor–

; ------ optimalizace mezer

         mov       al,"-"
         test      byte ptr es:[di+EdiParm1],bit5 ; je optimalizace ?
         jnz       EditSHl7                 ; optimalizace vypnuta
         mov       al,ah                    ; optimalizace zapnuta
EditSHl7:mov       ds:[HelpKOpt],al         ; optimalizace mezer

; ------ aktivn¡ okno

         mov       al,"1"                   ; aktivn¡ okno 1
         test      byte ptr ds:[EditPar2],bit6 ; aktivn¡ okno 2 ?
         jz        EditSHl8                 ; je aktivn¡ okno 1
         inc       ax                       ; aktivn¡ okno 2
EditSHl8:mov       ds:[HelpKOkn],al         ; aktivn¡ okno

; ------ po‡et oken

         mov       al,"1"                   ; 1 okno
         test      byte ptr ds:[EditPar2],bit4 ; 2 okna ?
         jz        EditSHl9                 ; je 1 okno
         inc       ax                       ; 2 okna
EditSHl9:mov       ds:[HelpKNum],al         ; po‡et oken

; ------ vertik ln¡ okna

         mov       al,"-"
         test      byte ptr ds:[EditPar2],bit5 ; jsou vertik ln¡ okna ?
         jz        EditSH92                 ; jsou horizont ln¡ okna
         mov       al,ah                    ; jsou vertik ln¡ okna
EditSH92:mov       ds:[HelpKVer],al         ; vertik ln¡ okna

; ------ synchronizace oken

         mov       al,"-"
         test      byte ptr ds:[EditParm],bit6 ; synchronizace ?
         jz        EditSH94                 ; nen¡ synchronizace
         mov       al,ah                    ; je synchronizace
EditSH94:mov       ds:[HelpKSyn],al         ; synchronizace

; ------ vnucen‚ zobrazen¡ n povˆdy

         mov       byte ptr ds:[Presmyk],-1 ; bude zobrazen¡ n povˆdy

; ------ n vrat registr–

         pop       es
         pop       di
         pop       dx
         pop       ax
         ret

EditSHlp ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ p©ep¡na‡e INSERT
; -----------------------------------------------------------------------------

EditIN   PROC      NEAR

         call      EdiEShft                 ; ukon‡en¡ ozna‡ov n¡ bloku se SHIFT-
         test      byte ptr ds:[Presmyk],bit4 ; je SHIFT- ?
         jz        EditIN2                  ; nen¡ SHIFT-
         jmp       Retn0Blk                 ; n vrat bloku

EditIN2: test      byte ptr es:[di+EdiParm1],bit1 ; je HEX m¢d ?
         jnz       EditIN3                  ; je HEX m¢d - z kaz
         xor       byte ptr ds:[EditParm],bit5 ; zmˆna p©¡znaku INSERT
         or        byte ptr ds:[EditPar2],bit0 ; p©¡znak - zmˆna kurzoru
EditIN3: ret

EditIN   ENDP

; -----------------------------------------------------------------------------
;        Shift-F10 zmˆna videom¢du
; -----------------------------------------------------------------------------

EditSF10:call      EdiEShft                 ; ukon‡en¡ ozna‡ov n¡ bloku se SHIFT-
         call      far ptr ShiftF10         ; zmˆna videom¢du
         jmp       Edi2CtF1                 ; aktualizace oken

; -----------------------------------------------------------------------------
;        Alt-F1 zmˆna aktivn¡ho okna (vyvol v  se t‚‘ z menu)
; -----------------------------------------------------------------------------
;þ
EditAF1: mov       ax,ds:[EdiSAkt]          ; segment aktivn¡ho okna
         xchg      ax,ds:[EdiSNAkt]         ; z mˆna s neaktivn¡m oknem
         mov       ds:[EdiSAkt],ax

         mov       ax,ds:[EdiWAkt]          ; ‡¡slo aktivn¡ho okna
         xchg      ax,ds:[EdiWNAkt]         ; z mˆna s neaktivn¡m oknem
         mov       ds:[EdiWAkt],ax

         xor       byte ptr ds:[EditPar2],bit6 ; zmˆna aktivn¡ho okna
         or        byte ptr ds:[EditPar2],bit3 ; p©¡znak - zobrazit v¨echno
         jmp       short EditAF28           ; aktualizace oken

; -----------------------------------------------------------------------------
;        Ctrl-Kn p©epnut¡ na soubor
; -----------------------------------------------------------------------------

EditAA2: sub       bl,"0"
         mov       bh,0
         jmp       short EditAA3

; -----------------------------------------------------------------------------
;        Alt-‡¡slo p©epnut¡ na soubor
; -----------------------------------------------------------------------------

EditAA1: sub       bx,7700h                 ; ‡¡slo souboru
         xchg      bh,bl
EditAA3: cmp       bx,ds:[NumEdi]           ; je platn˜ soubor ?
         jbe       EditAF22                 ; soubor je OK
         ret

; -----------------------------------------------------------------------------
;        Alt-F2 p©edchoz¡ soubor
; -----------------------------------------------------------------------------

; ------ ‡¡slo p©edchoz¡ho souboru -> BX

EditAF2: mov       bx,ds:[EdiWAkt]          ; aktivn¡ okno
         dec       bx                       ; sn¡‘en¡ ‡¡sla okna
         jnz       EditAF22                 ; nen¡ podte‡en¡
         mov       bx,ds:[NumEdi]           ; po‡et oken
EditAF22:mov       ds:[EdiWAkt],bx          ; nov‚ aktivn¡ okno

; ------ £schova registr–

         push      es

; ------ segment p©edchoz¡ho okna

         shl       bx,1                     ; BX <- offset v tabulce
         mov       ax,ds:[SegmTEdi]         ; segment ‡¡sel segment– soubor–
         call      far ptr GetDat           ; adresa segmentu soubor–
         mov       ax,es:[bx]               ; segment nov‚ho okna
         shr       bx,1                     ; BX <- ‡¡slo okna

; ------ adresa definice okna

         mov       si,offset EdiW1Win       ; okno 1
         test      byte ptr ds:[EditPar2],bit6 ; je aktivn¡ okno 2 ?
         jz        EditAF24                 ; je aktivn¡ okno 1
         mov       si,offset EdiW2Win       ; okno 2
         or        ah,bit15/bit8            ; p©¡znak, ‘e to je

; ------ ulo‘en¡ ‡¡sla nov‚ho souboru

EditAF24:mov       ds:[EdiSAkt],ax          ; nov‚ aktivn¡ okno
         mov       ds:[si],bx               ; ‡¡slo souboru aktivn¡ho okna
         and       ah,not bit15/bit8        ; bit 15 se neuplat¤uje
         mov       ds:[si+EdiS1Win-EdiW1Win],ax ; segment okna

; ------ n vrat registr–

         pop       es

; ------ nov‚ rozvr‘en¡ oken

EditAF28:call      EditRozv                 ; rozvr‘en¡ rozm¡stˆn¡ oken

; ------ altualizace okna

         call      Edi2CF0                  ; aktualizace aktivn¡ho okna

; ------ aktualizace parametr– kurzor–

         call      EditModA                 ; po‘adavek atkualizace
         call      EditAktW                 ; aktualizace parametr– kurzor–

; ------ aktualizace parametr– bloku

         call      EdiAktBl                 ; pokus o aktualizaci ukazatel– bloku

; ------ aktualizace parametr– kurzor–

         call      EditModA                 ; po‘adavek aktualizace
         ret

; -----------------------------------------------------------------------------
;        Alt-F3 dal¨¡ soubor
; -----------------------------------------------------------------------------

EditAF3: mov       bx,ds:[EdiWAkt]          ; ‡¡slo souboru aktivn¡ho okna
         inc       bx                       ; zv˜¨en¡ ‡¡sla okna
         cmp       bx,ds:[NumEdi]           ; posledn¡ okno ?
         jbe       EditAF22                 ; nen¡ posledn¡ okno
         mov       bx,1                     ; n hrada oknem 1
         jmp       short EditAF22

; -----------------------------------------------------------------------------
;        Alt-F4 zmˆna po‡tu zobrazen˜ch oken
; -----------------------------------------------------------------------------

EditAF4: xor       byte ptr ds:[EditPar2],bit4 ; zmˆna po‡tu oken
         jmp       short Edi2CtF1           ; aktualizace oken

; -----------------------------------------------------------------------------
;        Alt-F5 zobrazen¡ syst‚mov‚ obrazovky
; -----------------------------------------------------------------------------

EditAF5: xor       dx,dx                    ; po‡ te‡n¡ pozice a © dek
         mov       cl,ds:[Pozic]            ; po‡et pozic na © dek
         mov       ch,ds:[Radku]            ; po‡et © dk–
         call      far ptr PopScr           ; zobrazen¡ podkladu
         call      far ptr KurzOff          ; vypnut¡ kurzoru
         call      far ptr MouseOff         ; vypnut¡ kurzoru my¨i
         mov       ah,0
         int       16h                      ; ‡ek n¡ na stisk kl vesy
         call      far ptr MouseOn          ; zapnut¡ kurzoru my¨i
         or        byte ptr ds:[EditPar2],bit3 ; p©¡znak zobrazen¡ v¨eho
         ret

; -----------------------------------------------------------------------------
;        Alt-F6 vertik ln¡ okna
; -----------------------------------------------------------------------------

EditAF6: xor       byte ptr ds:[EditPar2],bit5 ; p©¡znak vertik ln¡ch oken
         jmp       short Edi2CtF1           ; nov‚ rozm¡stˆn¡ oken

; -----------------------------------------------------------------------------
;        Alt-F7 synchronizace
; -----------------------------------------------------------------------------

EditAF7: xor       byte ptr ds:[EditParm],bit6 ; p©¡znak synchronizace
         ret

;; -----------------------------------------------------------------------------
;;        Ctrl-F7 zvl ¨tn¡ funkce
;; -----------------------------------------------------------------------------
;;þ
;EditCtF7:mov       si,offset ZMn2Vert       ; menu zvl ¨tn¡ch funkc¡
;         call      far ptr CentMenu         ; vyst©edˆn¡ okna menu
;         call      far ptr VertMenu
;         ret

; -----------------------------------------------------------------------------
;        Ctrl-F1 m¢d editace
; -----------------------------------------------------------------------------

EditCtF1:xor       byte ptr es:[di+EdiParm1],bit0 ; zmˆna p©¡znaku editace

; ------ nov‚ rozvr‘en¡ oken

Edi2CtF1:call      EditRozv                 ; rozvr‘en¡ rozm¡stˆn¡ oken

; ------ aktualizace oken

         push      dx

         mov       dx,ds:[EdiSNAkt]         ; segment neaktivn¡ho okna
         call      Edi2CF0                  ; aktualizace neaktivn¡ho okna
         test      byte ptr ds:[EditPar2],bit1+bit2 ; zobrazen¡ © dku/okna ?
         jz        Edi2CF12                 ; nen¡ zobrazen¡
         or        byte ptr ds:[EditPar2],bit3 ; zobrazen¡ v¨eho
Edi2CF12:mov       dx,ds:[EdiSAkt]          ; segment aktivn¡ho okna
         call      Edi2CF0                  ; aktualizace aktivn¡ho okna

         pop       dx

; ------ aktualizace parametr– kurzor–

         call      EditAktW                 ; aktualizace parametr– kurzor–

; ------ aktualizace ukazatel– bloku

         call      EdiAktBl                 ; pokus o aktualizaci ukazatel– bloku
         ret

; -----------------------------------------------------------------------------
;        aktualaze parametr– okna DX
; -----------------------------------------------------------------------------

Edi2CF0  PROC      NEAR

; ------ adresa okna DX -> ES:DI

         call      EditGetD                 ; poskytnut¡ adresy okna

         mov       di,EdiW1                 ; definice pro okno 1
         or        dh,dh                    ; je aktivn¡ okno 2 ?
         jns       Edi2CF02                 ; je aktivn¡ okno 1
         mov       di,EdiW2                 ; definice pro okno 2

; ------ parametry kurzoru

Edi2CF02:mov       cx,word ptr es:[di+EdiPKurR] ; relativn¡ © dek a pozice kurzoru
         mov       si,es:[di+EdiOfKur]      ; offset s kurzorem
         mov       bx,es:[di+EdiBBKur]      ; blok s kurzorem

; ------ nalezen¡ © dku a pozice kurzoru BX:SI

         push      cx
         push      di
         call      EdiBORad                 ; nalezen¡ © dku a pozice kurzoru
         mov       si,di                    ; SI <- pozice LOW
         pop       di
         mov       word ptr es:[di+EdiPKur],si ; pozice kurzoru
         mov       word ptr es:[di+EdiPKur+2],bp
         mov       word ptr es:[di+EdiRKur],ax ; © dek kurzoru
         mov       word ptr es:[di+EdiRKur+2],cx
         pop       bx                       ; relativn¡ © dek a pozice

; ------ © dek po‡ tku okna

         or        bh,bh                    ; byl © dek 0 ?
         jnz       Edi2CF04                 ; nebyl © dek 0
         mov       bh,1                     ; minim ln¡ © dek 1
Edi2CF04:mov       bl,bh                    ; BL <- aktivn¡ © dek relativnˆ
         mov       bh,0
         sub       ax,bx                    ; v˜po‡et po‡ te‡n¡ho © dku okna
         sbb       cx,0
         jnc       Edi2CF05                 ; nen¡ podte‡en¡
         add       bx,ax                    ; oprava relativn¡ho © dku
         xor       ax,ax                    ; AX <- omezen˜ po‡ te‡n¡ho © dku
         xor       cx,cx
Edi2CF05:mov       word ptr es:[di+EdiRTop],ax ; © dek po‡ tku okna
         mov       word ptr es:[di+EdiRTop+2],cx
         mov       es:[di+EdiRKurR],bl      ; relativn¡ © dek kurzoru

         call      EdiAktBl                 ; pokus o aktualizaci ukazatel– bloku
         ret

Edi2CF0  ENDP

; -----------------------------------------------------------------------------
;        Ctrl-F2 bin rn¡ m¢d
; -----------------------------------------------------------------------------

EditCtF2:xor       byte ptr es:[di+EdiParm1],bit2 ; zmˆna bin rn¡ho m¢du
         and       byte ptr es:[di+EdiParm1],not bit1 ; nen¡ HEX m¢d
EdiCtF22:jmp       EditAF28                 ; normalizace + zapnut¡ bloku

; -----------------------------------------------------------------------------
;        Ctrl-F3 HEX m¢d
; -----------------------------------------------------------------------------

EditCtF3:xor       byte ptr es:[di+EdiParm1],bit1 ; zmˆna HEX m¢du
         and       byte ptr es:[di+EdiParm1],not bit2 ; nen¡ bin rn¡ m¢d
         jmp       short EdiCtF22           ; normalizace

; -----------------------------------------------------------------------------
;        Ctrl-F5 tabul tor jako bˆ‘n˜ znak
; -----------------------------------------------------------------------------

EditCtF5:xor       byte ptr es:[di+EdiParm1],bit7 ; zmˆna typu tabul toru
         jmp       EditAF28                 ; nov‚ rozm¡stˆn¡ oken

; -----------------------------------------------------------------------------
;        Ctrl-F6 optimalizace mezer
; -----------------------------------------------------------------------------

EditCtF6:xor       byte ptr es:[di+EdiParm1],bit5 ; zmˆna p©¡znaku optimalizace
         ret

; *****************************************************************************
;
;                     Z kladn¡ editace textu
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        vlo‘en¡ znaku BL do textu na pozici kurzoru
; -----------------------------------------------------------------------------

EditChr  PROC      NEAR

; ------ test platnosti znaku

         cmp       bh,MousXKod/HI           ; je k¢d my¨i ?
         je        EditChr1                 ; k¢d my¨i je zak z n
         cmp       bx,0300h                 ; kl vesa Ctrl-@
         je        EditChr0                 ; znak je platn˜ OK
         or        bx,bx                    ; je Ctrl-Break ?
         jz        EditChr1                 ; je Ctrl-Break - z kaz
         cmp       bh,0                     ; je kl vesa s Alt- ?
         je        EditChr0                 ; kl vesa s Alt- je povolena
         cmp       bl,6                     ; je ©¡dic¡ kl vesa ?
         jbe       EditChr1                 ; ©¡dic¡ kl vesa je zak zan 

; ------ v re‘imu zobrazen¡ se nic nedˆje

EditChr0:test      byte ptr es:[di+EdiParm1],bit0 ; je zobrazen¡ ?
         jz        EditChr2                 ; je editace OK
EditChr1:ret


; ====== p©¡prava znaku pro HEX m¢d

; ------ test, zda je editace HEX pole

EditChr2:test      byte ptr es:[di+EdiParm1],bit1 ; je HEX m¢d ?
         jz        EditCh21                 ; nen¡ HEX m¢d
         test      byte ptr es:[di+EdiParm2],bit2 ; je ASCII pole ?
         jnz       EditCh21                 ; je ASCII pole

; ------ kontrola, zda je platn˜ HEX znak

         cmp       bl,"0"
         jb        EditChr1                 ; neplatn˜ znak
         cmp       bl,"9"
         jbe       EditCh20                 ; platn˜ znak OK (je ‡¡slice)
         xchg      ax,bx
         call      far ptr UpCase           ; konverze na velk‚ p¡smeno
         xchg      ax,bx
         cmp       bl,"A"
         jb        EditChr1                 ; neplatn˜ znak
         cmp       bl,"F"
         ja        EditChr1                 ; neplatn˜ znak

; ------ p©¡prava znaku pro HEX m¢d

         sub       bl,7                     ; korekce pro HEX p¡smeno
EditCh20:sub       bl,"0"                   ; korekce HEX znaku na ‡¡slo
         mov       bh,0f0h                  ; maska p–vodn¡ho znaku
         test      byte ptr es:[di+EdiParm2],bit1 ; je druh˜ znak HEX pole ?
         jnz       EditCh21                 ; je druh˜ znak HEX pole
         mov       bh,0fh                   ; maska p–vodn¡ho znaku
         shl       bl,1
         shl       bl,1
         shl       bl,1
         shl       bl,1                     ; vy¨¨¡ znak HEX


; ------ ukon‡en¡ ozna‡ov n¡ bloku

EditCh21:call      EdiEShft                 ; ukon‡en¡ ozna‡ov n¡ bloku se SHIFT-

; ------ p©i z kazu editace pouze posun kurzoru vpravo

         test      byte ptr es:[EdiParm],bit2 ; je povolena editace souboru ?
         jz        EditCh22                 ; nen¡ z kaz z pisu
         jmp       EditRghY                 ; editace souboru zak z na


; ====== doplnˆn¡ mezer/nul po kurzor v m¢du BIN a HEX

; ------ rozli¨en¡, zda je BIN/HEX nebo textov˜ m¢d

EditCh22:test      byte ptr es:[di+EdiParm1],bit1+bit2 ; je bin rn¡/HEX m¢d ?
         jz        EdiCh228                 ; je textov˜ m¢d

; ------ doplnˆn¡ mezer/nul po kurzor

         call      DoplnOff                 ; doplnˆn¡ mezer/nul po kurzor
         jmp       EditCh42                 ; ulo‘en¡ znaku BL


; ------ doplnˆn¡ © dk– po kurzor (v textov‚m m¢du)

EdiCh228:call      EditGetK                 ; poskytnut¡ © dku s kurzorem->CX:AX
         call      DoplnRad                 ; doplnˆn¡ © dk– po kurzor
         jc        EditCh39                 ; chyba operace

; ------ test, zda je kurzor za koncem © dku

EditCh30:call      EditCmKL                 ; porovn n¡ pozice kurzoru s d‚lkou © dku
         jb        EditChr4                 ; kurzor nen¡ za koncem © dku

; ------ mezera za koncem © dku se p©i optimalizaci nevkl d 

         test      byte ptr es:[di+EdiParm1],bit5 ; je povolena optimalizace ?
         jnz       EditCh33                 ; optimalizace je vypnuta
         cmp       bl," "                   ; je mezera ?
         jne       EditCh33                 ; nen¡ mezera
         jmp       EditRghY                 ; mezera za koncem © dku se nevlo‘¡

; ------ doplnˆn¡ mezer po kurzor

EditCh33:call      EditDopS                 ; doplnˆn¡ mezer po kurzor
         jnc       EditChr4                 ; operace OK
EditCh39:ret

; ------ posun kurzoru, aby nebyl na odskoku tabul toru

EditChr4:mov       bp,16                    ; maxim ln¡ po‡et pokus–
EditCh41:test      byte ptr es:[di+EdiParm2],bit0 ; je odskok tabul toru ?
         jz        EditCh42                 ; nen¡ odskok tabul toru
         push      bp
         mov       bp,1                     ; po‡et pozic k posunu
         call      EditKrLf                 ; posun kurzoru vlevo
         call      EditAktW                 ; aktualizace okna
         pop       bp
         dec       bp                       ; ‡¡ta‡ pokus–
         jnz       EditCh41                 ; dal¨¡ pokus


; ====== vlo‘en¡ znaku (pro v¨echny m¢dy)

; ------ rozli¨en¡, zda se znak vlo‘¡ nebo p©ep¡¨e

EditCh42:test      byte ptr es:[di+EdiParm1],bit1 ; je HEX m¢d ?
         jnz       EdiCh422                 ; je HEX m¢d - nen¡ vkl d n¡
         test      byte ptr ds:[EditParm],bit5 ; je zapnut INSERT ?
         jz        EdiCh422                 ; nen¡ zapnut INSERT
         jmp       EditCh46                 ; je zapnut INSERT

; ------ INSERT vypnut - test, zda je kurzor na konci © dku

EdiCh422:call      EditCmKL                 ; porovn n¡ pozice kurzoru s d‚lkou © dku
         jb        EdiCh431                 ; kurzor nen¡ na konci © dku
         jmp       EditCh46                 ; kurzor je na konci © dku-je INSERT

; ------ vlo‘en¡ znaku do textu bez INSERT

EdiCh431:push      bx                       ; BL=znak k vlo‘en¡
         mov       ax,word ptr es:[di+EdiParm1] ; AL <- parametry 1 a 2
         mov       bx,es:[di+EdiBBKur]      ; blok s kurzorem
         mov       si,es:[di+EdiOfKur]      ; offset kurzoru
         call      EditNGet                 ; adresa kurzoru
         pop       cx                       ; CL <- znak k vlo‘en¡, CH <- maska HEX
         xchg      ax,cx                    ; CX <- parametry, AL <- znak
         jz        EditCh39                 ; chyba nebo konec souboru
         test      cl,bit1                  ; je HEX m¢d ?
         jz        EdiCh432                 ; nen¡ HEX m¢d
         test      ch,bit2                  ; je ASCII ‡ st HEX pole ?
         jnz       EdiCh432                 ; je ASCII ‡ st HEX pole
         and       ah,es:[si]               ; AH <- p–vodn¡ tetr da
         or        al,ah                    ; p©id n¡ p–vodn¡ tetr dy

EdiCh432:mov       ah,es:[si]               ; £schova p–vodn¡ho znaku
         mov       es:[si],al               ; ulo‘en¡ znaku
         or        byte ptr ds:[EditPar2],bit1 ; p©¡znak zobrazen¡ © dku

; ------ nastaven¡ p©¡znaku modifikace bloku a souboru (AH=p–vodn¡/AL=nov˜ znak)

         call      EditGetD                 ; adresa okna -> ES
         shl       bx,1
         shl       bx,1
         shl       bx,1                     ; ‡¡slo bloku * 8
         add       bx,EdiABlok              ; adresa bloku

         cmp       word ptr es:[bx+EdiBlokL],-1 ; byl po‡et © dk– zn m˜ ?
         je        EditCh45                 ; po‡et © dk– nebyl zn m˜

         cmp       ah,LF                    ; byl p©episovan˜ znak LF ?
         jne       EditCh44                 ; nebyl p©episovan˜ LF
         dec       word ptr es:[bx+EdiBlokL] ; sn¡‘en¡ po‡tu © dk– v bloku
         sub       word ptr es:[EdiRadku],1 ; sn¡‘en¡ po‡tu © dk– v souboru
         sbb       word ptr es:[EdiRadku+2],0
EditCh44:cmp       al,LF                    ; byl vlo‘en znak LF ?
         jne       EditCh45                 ; nebyl vlo‘en znak LF
         inc       word ptr es:[bx+EdiBlokL] ; zv˜¨en¡ po‡tu © dk– v bloku
         add       word ptr es:[EdiRadku],1 ; zv˜¨en¡ po‡tu © dk– v souboru
         adc       word ptr es:[EdiRadku+2],0

EditCh45:cmp       word ptr es:[bx+EdiBlokM],0 ; je blok v pamˆti ?
         je        EdiCh452                 ; nen¡ blok v pamˆti
         cmp       al,ah                    ; byl znak zmˆnˆn ?
         je        EdiCh452                 ; znak nebyl zmˆnˆn
         or        byte ptr es:[bx+EdiBlokM+1],bit15/bit8 ; p©¡znak modifikace
         or        byte ptr es:[EdiParm],bit0 ; p©¡znak modifikace souboru
EdiCh452:jmp       short EditCh48


; ------ INSERT je zapnut

EditCh46:xchg      ax,bx                    ; AX <- vkl dan˜ znak
         mov       bx,es:[di+EdiBBKur]      ; blok s kurzorem
         mov       si,es:[di+EdiOfKur]      ; offset kurzoru
         mov       cx,1                     ; m¡sto pro 1 znak

; ------ vlo‘en¡ znaku do textu

         push      bx
         push      di
         call      EditIns                  ; vytvo©en¡ m¡sta pro 1 znak
         jc        EditCh47                 ; chyba
         mov       es:[di],al               ; ulo‘en¡ znaku do bufferu
EditCh47:call      EditGt0D                 ; obnoven¡ adresy okna
         pop       di
         pop       bx
         jnc       EdiCh474                 ; byla chyba operace
         ret

EdiCh474:or        byte ptr ds:[EditPar2],bit1 ; p©¡znak zobrazen¡ © dku
         or        byte ptr es:[di+EdiParm2],bit4+bit7 ; nutno aktualizovat © dek

; ------ posun ukazatel– bloku

         mov       bp,offset EdiChPB        ; obsluha pro vlo‘en¡ znaku AL
         call      EdiChPBA                 ; obsluha korekc¡

; ------ oprava ‡¡ta‡e © dk– (BX=‡¡slo bloku s kurzorem)

         cmp       al,LF                    ; je LF ?
         jne       EditCh48                 ; nen¡ LF

         shl       bx,1
         shl       bx,1
         shl       bx,1                     ; ‡¡slo bloku * 8
         add       bx,EdiABlok              ; adresa bloku
         cmp       word ptr es:[bx+EdiBlokL],-1 ; byl po‡et © dk– zn m˜ ?
         je        EditCh48                 ; po‡et © dk– nebyl zn m˜
         inc       word ptr es:[bx+EdiBlokL] ; zv˜¨en¡ po‡tu © dk– v bloku
         add       word ptr es:[EdiRadku],1 ; zv˜¨en¡ po‡tu © dk– v souboru
         adc       word ptr es:[EdiRadku+2],0

; ------ aktualizace © dku s kurzorem, aktualizace ukazatel– bloku

EditCh48:call      EditModA                 ; nutn  aktualizace oken
         call      EditAktW                 ; aktualizace oken
         call      EdiAktBl                 ; aktualizace ukazatel– bloku

; ------ test, zda je LF

         cmp       al,LF                    ; je LF ?
         jne       EditCh4A                 ; nen¡ LF

; ------ korekce pro LF v textov‚m m¢du

         test      byte ptr es:[di+EdiParm1],bit1+bit2 ; je bin rn¡/HEX m¢d ?
         jnz       EditChr5                 ; je bin rn¡/HEX m¢d - kurzor vpravo
         call      EditOrez                 ; o©ez n¡, pokud nebyl CR
         call      EditLftX                 ; n vrat kurzoru vlevo
         call      EditAktW                 ; aktualizace oken
         call      EditOrez                 ; o©ez n¡ mezer na konci © dku
         call      EditDwnY                 ; kurzor dol–
         call      EditHomY                 ; kurzor na za‡ tek © dku

         or        byte ptr ds:[EditPar2],bit2 ; p©¡znak zobrazen¡ okna
         ret

; ------ posun kurzoru, je-li tabul tor

EditCh4A:cmp       al,TAB
         jne       EditChr5
         test      byte ptr es:[di+EdiParm1],bit1+bit2+bit7 ; BIN/HEX/TAB ?
         jnz       EditChr5                 ; je BIN/HEX m¢d nebo TAB=znak

         call      EditGtKP                 ; pozice kurzoru -> CX:AX
         add       ax,8                     ; posun na dal¨¡ tabula‡n¡ pozici
         adc       cx,0
         and       al,not 7
         call      EditStKP                 ; nastaven¡ pozice kurzoru

EditChr9:ret

; ------ zabr nˆn¡ posunu p©i vlo‘en¡ CR za samotn˜ LF

EditChr5:cmp       al,CR                    ; je CR ?
         jne       EditCh58                 ; nen¡ CR
         test      byte ptr es:[di+EdiParm1],bit1+bit2 ; je bin rn¡/HEX m¢d ?
         jnz       EditCh58                 ; je bin rn¡/HEX m¢d - kurzor vpravo

         cmp       word ptr es:[di+EdiPKur],0 ; je po‡ tek © dku ? (=pro zrychlen¡)
         jne       EditCh58                 ; nen¡ po‡ tek © dku
         mov       bx,es:[di+EdiBBKur]      ; blok s kurzorem
         mov       si,es:[di+EdiOfKur]      ; offset kurzoru
         dec       si                       ; ukazatel na CR
         dec       si                       ; p©ede¨l˜ znak p©ed CR
         call      EdiGetCh                 ; na‡ten¡ znaku p©ed
         cmp       al,LF                    ; byl p©ede¨l˜ znak LF ?
         jne       EditCh58                 ; nebyl LF
         dec       si                       ; p©ede¨l˜ znak p©ed LF
         call      EdiGetCh                 ; na‡ten¡ p©ede¨l‚ho znaku
         cmp       al,CR                    ; p©edch z¡ CR ?
         jne       EditCh59                 ; je jen LF - bez posuvu

; ------ posun kurzoru vpravo

EditCh58:call      EditRghY                 ; posun kurzoru vpravo
EditCh59:call      EditAktW                 ; aktualizace oken
         call      EditOrez                 ; o©ez n¡, pokud byla mezera
         ret

EditChr  ENDP


; ====== proveden¡ korekce (adresa BP) pro v¨echny ukazatele

EdiChPBA PROC      NEAR

         push      bx
         push      si

         mov       si,EdiPBBlk              ; po‡ tek bloku
         mov       bl,bit0                  ; p©¡znak platnosti po‡ tku bloku
         call      BP                       ; oprava pozice po‡ tku bloku

         mov       si,EdiPKBlk              ; konec bloku
         mov       bl,bit1                  ; p©¡znak platnosti konce bloku
         call      BP                       ; oprava pozice konce bloku

         mov       si,EdiTZnac              ; buffer zna‡ek
         mov       bx,10*HI                 ; po‡et zna‡ek, nen¡ korekce
EdChPBA2:push      bx
         call      BP                       ; oprava zna‡ky
         pop       bx
         add       si,8                     ; dal¨¡ zna‡ka
         dec       bh
         jnz       EdChPBA2                 ; dal¨¡ zna‡ka

         pop       si
         pop       bx
         ret

EdiChPBA ENDP

; ====== oprava offsetu bloku ES:SI po vypu¨tˆn¡ CX:AX mezer - textov˜ m¢d

EdiChPBD PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx

; ------ porovn n¡ © dku kurzoru

         call      EdiChPBK                 ; je © dek s kurzorem ?
         ja        EdChPBD8                 ; kurzor je za ukazatelem
         jb        EdChPBD6                 ; kurzor je p©ed ukazatelem

; ------ porovn n¡ pozice kurzoru (=star˜ konec © dku)

         call      EdiChPBP                 ; porovn n¡ pozice kurzoru
         jbe       EdChPBD6                 ; kurzor je p©ed ukazatelem

; ------ po‡et zru¨en˜ch mezer p©ed ukazatelem

         sub       ax,word ptr es:[di+EdiPKur] ; -nov˜ konec © dku (z pornˆ)
         sbb       cx,word ptr es:[di+EdiPKur+2]
         add       ax,es:[si]               ; po‡et mezer p©ed ukazatelem
         adc       cx,es:[si+2]
         js        EdChPBD8                 ; to je nˆjak  chyba

; ------ ode‡ten¡ CX:AX mezer od offsetu

EdChPBD6:sub       es:[si+8],ax             ; ode‡ten¡ zru¨en˜ch  mezer
         sbb       es:[si+8+2],cx

; ------ n vrat registr–

EdChPBD8:pop       cx
         pop       ax
         ret

EdiChPBD ENDP


; ====== oprava offsetu bloku ES:SI po vlo‘en¡ CX:AX mezer - textov˜ m¢d

EdiChPBS PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx

; ------ porovn n¡ © dku kurzoru

         call      EdiChPBK                 ; je © dek s kurzorem ?
         ja        EdChPBS8                 ; kurzor je za ukazatelem
         jb        EdChPBS6                 ; kurzor je p©ed ukazatelem

; ------ porovn n¡ pozice kurzoru

         call      EdiChPBP                 ; porovn n¡ pozice kurzoru
         jbe       EdChPBS6                 ; kurzor je p©ed ukazatelem

; ------ porovn n¡ s koncem © dku

         call      EdiChPBL                 ; porovn n¡ s koncem © dku
         jae       EdChPBS8                 ; mezery jsou v¨echny za ukazatelem

; ------ po‡et mezer ke korekci -> CX:AX

         add       ax,word ptr es:[di+EdiPLKur] ; p©i‡ten¡ konce © dku
         adc       cx,word ptr es:[di+EdiPLKur+2]

         cmp       cx,es:[si+2]             ; porovn n¡ pozice ukazatele
         jne       EdChPBS2
         cmp       ax,es:[si]
EdChPBS2:jbe       EdChPBS4                 ; konec mezer je men¨¡ ne‘ pozice

         mov       ax,es:[si]               ; omezen¡ konce na pozici ukazatele
         mov       cx,es:[si+2]

EdChPBS4:sub       ax,word ptr es:[di+EdiPLKur] ; n vrat po‡tu vkl dan˜ch mezer
         sbb       cx,word ptr es:[di+EdiPLKur+2]

; ------ p©i‡ten¡ CX:AX mezer

EdChPBS6:add       es:[si+8],ax             ; p©i‡ten¡ mezer
         adc       es:[si+8+2],cx

; ------ n vrat registr–

EdChPBS8:pop       cx
         pop       ax
         ret

EdiChPBS ENDP


; ====== oprava pozice ES:[SI] bloku po vlo‘en¡ znaku AL (BL=maska platnosti)

EdiChPB  PROC      NEAR

; ------ oprava offsetu ukazatele pro bin rn¡ a HEX m¢d

         test      byte ptr es:[di+EdiParm1],bit1+bit2 ; je BIN/HEX m¢d ?
         jz        EdiChPB4                 ; nen¡ BIN/HEX m¢d
         call      EdiChPBO                 ; test offsetu
         jae       EdiChPB3                 ; nen¡ p©ed offsetem bloku
EdiChPB1:or        es:[EdiParm0],bl         ; ukazatel bloku neplatn˜
EdiChPB2:add       word ptr es:[si+8],1     ; zv˜¨en¡ offsetu bloku
         adc       word ptr es:[si+8+2],0
EdiChPB3:ret

; ------ test, zda se vkl d  znak LF

EdiChPB4:cmp       al,LF                    ; vkl d  se znak LF ?
         je        EdiChPB6                 ; vkl d  se znak LF

; ------ porovn n¡ © dku kurzoru

         call      EdiChPBK                 ; je © dek s kurzorem ?
         ja        EdiChPB3                 ; kurzor je za ukazatelem
         jb        EdiChPB2                 ; kurzor je p©ed ukazatelem

; ------ je © dek s kurzorem - porovn n¡ pozice kurzoru

         call      EdiChPBP                 ; porovn n¡ pozice kurzoru
         jae       EdiChPB3                 ; kurzor je za ukazatelem bloku

; ------ kurzor je p©ed ukazatelem - posune se ‡¡slo pozice

         add       word ptr es:[si],1       ; zv˜¨en¡ ‡¡sla pozice ukazatele
         adc       word ptr es:[si+2],0

; ------ test, zda je pozice ukazatele uvnit© © dku

         call      EdiChPBL                 ; porovn n¡ d‚lky © dku
EdiChPB5:jae       EdiChPB1                 ; uvnit© © dku se ukazatel aktualizuje
         jmp       short EdiChPB2           ; zv˜¨en¡ offsetu ukazatele

; ------ je LF: porovn n¡ © dku kurzoru

EdiChPB6:call      EdiChPBK                 ; je kurzor na © dku p©ed blokem ?
         ja        EdiChPB3                 ; kurzor je za ukazatelem bloku
         je        EdiChPB7                 ; je © dek s kurzorem

; ------ kurzor je p©ed ukazatelem - posune se ‡¡slo © dku

         add       word ptr es:[si+4],1     ; zv˜¨en¡ ‡¡sla © dku ukazatele
         adc       word ptr es:[si+4+2],0
         jmp       short EdiChPB2           ; zv˜¨en¡ offsetu ukazatele

; ------ je © dek s kurzorem - porovn n¡ pozice kurzoru

EdiChPB7:call      EdiChPBP                 ; porovn n¡ pozice kurzoru
         jae       EdiChPB3                 ; kurzor je za ukazatelem bloku

; ------ rozdˆlen¡ © dku - ‡¡slo © dku ukazatele se zv˜¨¡

         add       word ptr es:[si+4],1     ; zv˜¨en¡ ‡¡sla © dku ukazatele
         adc       word ptr es:[si+4+2],0

; ------ porovn n¡ d‚lky © dku, zda je ukazatel uvnit© © dku

         call      EdiChPBL                 ; porovn n¡ d‚lky © dku

; ------ v˜po‡et nov‚ pozice ukazatele

         pushf
         push      ax
         mov       ax,word ptr es:[di+EdiPKur] ; pozice kurzoru LOW
         sub       word ptr es:[si],ax      ; oprava pozice ukazatele
         mov       ax,word ptr es:[di+EdiPKur+2]
         sbb       word ptr es:[si+2],ax
         pop       ax
         popf
         jmp       short EdiChPB5           ; aktualizace ukazatele

EdiChPB  ENDP

; ------ porovn n¡ d‚lky © dku s pozic¡ bloku (ES:SI=ukazatel za‡ tku/konce bloku)

EdiChPBL:push      ax
         mov       ax,word ptr es:[di+EdiPLKur+2] ; d‚lka © dku s kurzorem
         cmp       ax,es:[si+2]             ; je pozice s blokem ?
         jne       EdChPBL2
         mov       ax,word ptr es:[di+EdiPLKur]
         cmp       ax,es:[si]
EdChPBL2:pop       ax
         ret

; ------ porovn n¡ pozice kurzoru s blokem (ES:SI=ukazatel za‡ tku/konce bloku)

EdiChPBP:push      ax
         mov       ax,word ptr es:[di+EdiPKur+2] ; pozice s kurzorem
         cmp       ax,es:[si+2]             ; je pozice s blokem ?
         jne       EdChPBP2                 ; nen¡ pozice s kurzorem
         mov       ax,word ptr es:[di+EdiPKur]
         cmp       ax,es:[si]
EdChPBP2:pop       ax
         ret

; ------ porovn n¡ © dku kurzoru s blokem (ES:SI=ukazatel za‡ tku/konce bloku)

EdiChPBK:push      ax
         mov       ax,word ptr es:[di+EdiRKur+2] ; © dek s kurzorem
         cmp       ax,es:[si+4+2]           ; je na © dku s blokem ?
         jne       EdChPBK2                 ; nen¡ © dek s kurzorem
         mov       ax,word ptr es:[di+EdiRKur]
         cmp       ax,es:[si+4]
EdChPBK2:pop       ax
         ret

; ------ porovn n¡ offsetu kurzoru s blokem (ES:SI=ukazatel za‡ tku/konce bloku)

EdiChPBO:push      ax
         mov       ax,word ptr es:[di+EdiOffsK+2] ; offset kurzoru
         cmp       ax,es:[si+8+2]           ; je p©ed offsetem bloku ?
         jne       EdChPBO6
         mov       ax,word ptr es:[di+EdiOffsK]
         cmp       ax,es:[si+8]
EdChPBO6:pop       ax
         ret

; -----------------------------------------------------------------------------
;    doplnˆn¡ mezer/nul na konec souboru po kurzor (okno DX/ES/DI) -> CY=chyba
; -----------------------------------------------------------------------------

DoplnOff PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      si

; ------ test, zda je z kaz z pisu

         test      byte ptr es:[EdiParm],bit2 ; je povolena editace souboru ?
         stc                                ; p©¡znak chyby
         jnz       DoplnOf9                 ; je z kaz z pisu

; ------ adresa konce souboru -> BX:SI

         mov       ax,word ptr es:[EdiSize] ; velikost souboru LOW
         mov       cx,word ptr es:[EdiSize+2] ; velikost souboru HIGH
         call      EdiGetAd                 ; v˜po‡et ukazatele konce souboru

; ------ teoretick˜ offset kurzoru -> CX:AX

         push      dx
         mov       cx,es:[di+EdiLSir]       ; ¨¡©ka dat v BIN/HEX m¢du
         mov       ax,word ptr es:[di+EdiRKur+2] ; © dek s kurzorem HIGH
         mul       cx                       ; p©epo‡et © dku HIGH na offset
         xchg      ax,cx                    ; CX <- offset HIGH, AX <- ¨¡©ka © dku
         mul       word ptr es:[di+EdiRKur] ; p©epo‡et © dku LOW na offset
         add       cx,dx                    ; CX = offset kurzoru HIGH
         pop       dx
         add       ax,word ptr es:[di+EdiPKur] ; p©i‡ten¡ pozice na © dku
         adc       cx,word ptr es:[di+EdiPKur+2]

; ------ vlo‘en¡ mezer/nul pro bin rn¡/HEX m¢d

         sub       ax,word ptr es:[EdiSize] ; po‡et chybˆj¡c¡ch bajt– LOW
         sbb       cx,word ptr es:[EdiSize+2] ; po‡et chybˆj¡c¡ch bajt– HIGH
         cmc
         jnc       DoplnOf9                 ; kurzor nen¡ za koncem souboru
         jnz       DoplnOf4                 ; chyb¡ znaky
         or        ax,ax                    ; je co vlo‘it ?
         jz        DoplnOf9                 ; nen¡ co vlo‘it

DoplnOf4:test      byte ptr es:[di+EdiParm1],bit1 ; je to HEX m¢d ?
         jnz       DoplnOf6                 ; je to HEX m¢d
         call      EditISpc                 ; vlo‘en¡ mezer
         jmp       short DoplnOf8

DoplnOf6:call      EditINul                 ; vlo‘en¡ nul

; ------ aktualizace ukazatel– po vlo‘en¡ mezer/nul (CY=chyba)

DoplnOf8:pushf
         call      EditModA                 ; po‘adavek aktualizace okna
         call      EditAktW                 ; aktualizace ukazatel– okna
         or        byte ptr es:[EdiParm0],bit0+bit1 ; ukazatele blok– neplatn‚
         popf

; ------ n vrat registr–

DoplnOf9:pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

DoplnOff ENDP

; -----------------------------------------------------------------------------
;        doplnˆn¡ textov˜ch © dk– na CX:AX © dk– (okno ES/DX) -> CY=chyba
; -----------------------------------------------------------------------------

DoplnRad PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      si
         push      di
         push      bp

; ------ adresa okna -> ES

         call      EditGetD                 ; adresa okna
         jc        DoplnRd9

; ------ p©¡prava adresy definice okna -> DI

         mov       di,EdiW1                 ; okno 1
         or        dh,dh                    ; je okno 2 ?
         jns       DoplnRd1                 ; je okno 1
         mov       di,EdiW2                 ; okno 2

; ------ test, zda to je textov˜ m¢d

DoplnRd1:test      byte ptr es:[di+EdiParm1],bit1+bit2 ; je textov˜ m¢d ?
         jnz       DoplnRd9                 ; nen¡ textov˜ m¢d

; ------ test, zda je z kaz z pisu

         test      byte ptr es:[EdiParm],bit2 ; je povolena editace souboru ?
         stc                                ; p©¡znak chyby
         jnz       DoplnRd9                 ; je z kaz z pisu

; ------ p©edbˆ‘n˜ test, zda je po‘adov no v¡ce © dk– ne‘ je

         cmp       cx,word ptr es:[EdiRadku+2]
         jne       DoplnRd2
         cmp       ax,word ptr es:[EdiRadku]
DoplnRd2:je        DoplnRd9                 ; je na konci © dku
         cmc
         jnc       DoplnRd9                 ; nen¡ po‘adov no v¡ce © dk–

; ------ aktualizace po po‘adovan˜ © dek (pro aktualizaci © dk–)->BX:SI

         call      EdiGetLn                 ; poskytnut¡ po‘adovan‚ho © dku->BX:SI
         jc        DoplnRd9                 ; byla chyba operace

; ------ po‡et © dk– k doplnˆn¡ -> CX:AX

         sub       ax,word ptr es:[EdiRadku] ; pot©ebn‚ mno‘stv¡ nov˜ch © dk–
         sbb       cx,word ptr es:[EdiRadku+2]
         ja        DoplnRd4                 ; jsou nˆjak‚ © dky k doplnˆn¡
         clc                                ; p©¡znak operace OK
         jnz       DoplnRd9                 ; kurzor nen¡ za koncem souboru
         or        ax,ax                    ; jsou nˆjak‚ © dky ?
         jz        DoplnRd9                 ; nejsou © dky k doplnˆn¡

; ------ £schova star‚ho po‡tu © dk–

DoplnRd4:push      word ptr es:[EdiRadku]
         push      word ptr es:[EdiRadku+2]

; ------ doplnˆn¡ pot©ebn‚ho mno‘stv¡ © dk– CX:AX

         call      EditILn                  ; vlo‘en¡ nov˜ch © dk–

; ------ star˜ po‡et © dk– -> CX:AX

         pop       cx                       ; star˜ po‡et © dk– HIGH
         pop       ax                       ; star˜ po‡et © dk– LOW

; ------ aktualizace nov‚ho po‡tu © dk– v souboru

         pushf
         call      EdiAktL                  ; aktualizace po‡tu © dk–

; ------ oprava offset– ukazatel–

         mov       bp,offset EdiChPBN
         call      EdiChPBA                 ; korekce ukazatel–

; ------ aktualizace po‡ tku okna a kurzoru (CY=chyba)

         call      EditModA                 ; po‘adavek aktualizace oken
         call      EditAktW                 ; aktualizace ukazatel– kurzor–
         popf

; ------ n vrat registr–

DoplnRd9:pop       bp
         pop       di
         pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

DoplnRad ENDP

; ====== oprava offsetu bloku ES:SI po vlo‘en¡ © dk– (CX:AX=star˜ po‡et © dk–)

EdiChPBN PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      bp

; ------ star˜ po‡et © dk– -> BP:BX

         xchg      ax,bx                    ; BX <- star˜ po‡et © dk– LOW
         mov       bp,cx                    ; BP <- star˜ po‡et © dk– HIGH

; ------ nov˜ po‡et © dk– -> CX:AX

         call      EdiGetCL                 ; poskytnut¡ po‡tu © dk– -> CX:AX

; ------ kontrola, zda je ukazatel p©ed star˜m koncem souboru

         cmp       bp,es:[si+4+2]           ; porovn n¡ © dku HIGH
         jne       EdChPBN1
         cmp       bx,es:[si+4]
EdChPBN1:jae       EdChPBN9                 ; je p©ed koncem - neuplatn¡ se

; ------ kontrola, zda je ukazatel za nov˜m koncem souboru

         cmp       cx,es:[si+4+2]           ; porovn n¡ © dku HIGH
         jne       EdChPBN2
         cmp       ax,es:[si+4]
EdChPBN2:jbe       EdChPBN3                 ; je za nov˜m koncem souboru

; ------ omezen¡ konce zmˆn na ukazatel

         mov       cx,es:[si+4+2]           ; © dek ukazatele
         mov       ax,es:[si+4]

; ------ po‡et © dk– vlo‘en˜ch p©ed ukazatel

EdChPBN3:sub       ax,bx                    ; po‡et vlo‘en˜ch © dk– LOW
         sbb       cx,bp                    ; po‡et vlo‘en˜ch © dk– HIGH

; ------ korekce offsetu ukazatele

         add       es:[si+8],ax             ; korekce offsetu
         adc       es:[si+8+2],cx
         add       es:[si+8],ax
         adc       es:[si+8+2],cx

; ------ n vrat registr–

EdChPBN9:pop       bp
         pop       cx
         pop       bx
         pop       ax
         ret

EdiChPBN ENDP

; -----------------------------------------------------------------------------
;    doplnˆn¡ pozice (okno ES/DX, © dek BX:SI po pozici CX:AX -> adresa BX:SI)
;                      plat¡ pouze pro textov˜ m¢d !!!
;   Pou‘¡v  se pouze p©i na‡¡t n¡ sloupcov‚ho bloku, neaktualizuje ukazatele!
; -----------------------------------------------------------------------------

DoplnPoz PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      di
         push      bp

; ------ d‚lka aktivn¡ho © dku -> BP:DI

         push      ax
         push      cx
         call      EditLenL                 ; d‚lka aktivn¡ho © dku
         xchg      ax,di                    ; DI <- d‚lka aktivn¡ho © dku LOW
         mov       bp,cx                    ; BP <- d‚lka aktivn¡ho © dku HIGH
         pop       cx
         pop       ax
         jc        DoplnPz9                 ; chyba

; ------ nastaven¡ po‘adovan‚ pozice CX:AX

         call      EditGtPO                 ; nastaven¡ pozice s omezen¡m
         jc        DoplnPz9                 ; chyba

; ------ doplnˆn¡ mezer za konec © dku -> BX:SI po‘adovan  pozice

         sub       ax,di                    ; vzd lenost za‡ tku od konce © dku
         sbb       cx,bp
         jc        DoplnPz8                 ; pozice je p©ed koncem © dku
         ja        DoplnPz4                 ; je za koncem © dku
         or        ax,ax                    ; je na konci © dku ?
         jz        DoplnPz8                 ; je na konci © dku
DoplnPz4:call      EditISpc                 ; vlo‘en¡ mezer
         jc        DoplnPz9                 ; chyba operace

; ------ aktualizace parametr– © dku s kurzorem

DoplnPz8:call      EditModA                 ; po‘adavek aktualizace okna
         clc                                ; p©¡znak operace OK

; ------ n vrat registr–

DoplnPz9:pop       bp
         pop       di
         pop       cx
         pop       ax
         ret

DoplnPoz ENDP

; -----------------------------------------------------------------------------
;   doplnˆn¡ mezer po kurzor (DX/ES:DI=okno  -> CY=chyba, ES=nov  adresa okna)
;           (mus¡ b˜t platn˜ © dek, nesm¡ b˜t za koncem souboru !)
; -----------------------------------------------------------------------------

EditDopS PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      si

; ------ test, zda je operace povolena

         test      byte ptr es:[EdiParm],bit2 ; je povolena editace souboru ?
         jnz       EditDpS9                 ; z kaz z pisu
         test      byte ptr es:[di+EdiParm1],bit0 ; je zobrazen¡ ?
         jnz       EditDpS9                 ; je jen zobrazen¡ - ignoruje se

; ------ test, zda je kurzor za koncem © dku

         call      EditCmKL                 ; porovn n¡ pozice kurzoru s d‚lkou © dku
         jbe       EditDpS8                 ; kurzor nen¡ za koncem © dku

; ------ nalezen¡ adresy konce © dku -> BX:SI

         call      EditGtLP                 ; poskytnut¡ d‚lky © dku -> CX:AX
         mov       bx,es:[di+EdiBKur]       ; blok © dku s kurzorem
         mov       si,es:[di+EdiOKur]       ; offset © dku s kurzorem
         push      di
         call      EditGetP                 ; nalezen¡ pozice © dku
         pop       di
         jc        EditDpS9

; ------ stanoven¡ po‡tu mezer k vlo‘en¡

         call      EditGtKP                 ; poskytnut¡ pozice kurzoru -> CX:AX
         sub       ax,word ptr es:[di+EdiPLKur] ; po‘adovan˜ po‡et mezer
         sbb       cx,word ptr es:[di+EdiPLKur+2]
         jb        EditDpS8                 ; chyba

; ------ prodlou‘en¡ konce na po‘adovanou pozici

         push      ax                       ; po‘adovan˜ po‡et mezer LOW
         push      cx                       ; po‘adovan˜ po‡et mezer HIGH
         call      EditISpc                 ; vlo‘en¡ mezer
         xchg      ax,si                    ; AX <- zbyl˜ po‡et mezer LOW
         mov       bx,cx                    ; BX <- zbyl˜ po‡et mezer HIGH
         pop       cx                       ; po‘adovan˜ po‡et mezer HIGH
         pop       ax                       ; po‘adovan˜ po‡et mezer LOW

; ------ korekce ukazatel– bloku

         pushf
         push      bp
         sub       ax,si                    ; AX <- po‡et vlo‘en˜ch mezer LOW
         sbb       cx,bx                    ; CX <- po‡et vlo‘en˜ch mezer HIGH
         mov       bp,offset EdiChPBS
         call      EdiChPBA                 ; korekce ukazatel–
         pop       bp

; ------ aktualizace parametr– © dku s kurzorem

         call      EditModA                 ; po‘adavek aktualizace okna
         call      EditAktW                 ; aktualizace © dku s kurzorem
         popf
         jc        EditDpS9                 ; chyba

; ------ n vrat registr–

EditDpS8:clc                                ; p©¡znak operace OK
EditDpS9:pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

EditDopS ENDP

; -----------------------------------------------------------------------------
;        o©ez n¡ mezer na konci aktivn¡ho © dku (je-li kurzor na konci © dku)
; (VSTUP: DX/ES:DI=definice okna)
; -----------------------------------------------------------------------------

EditOrez PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      si
         push      bp

; ------ test, zda je operace povolena

         test      byte ptr es:[EdiParm],bit2 ; je povolena editace souboru ?
         jnz       EditOrz9                 ; z kaz z pisu
         test      byte ptr es:[di+EdiParm1],bit0+bit1+bit2+bit5 ; zob/BIN/HEX ?
         jnz       EditOrz9                 ; je zobr./BIN/HEX/nen¡ opt. - z kaz

; ------ test, zda je kurzor na konci © dku

         call      EditCmKL                 ; porovn n¡ pozice kurzoru s d‚lkou © dku
         clc                                ; p©¡znak operace OK
         jne       EditOrz9                 ; kurzor nen¡ na konci © dku

; ------ p©¡prava k o©ez n¡ © dku

         xor       bp,bp                    ; BP <- 0 ‡¡ta‡ znak– HIGH
         xor       ax,ax                    ; AX <- 0 ‡¡ta‡ znak– LOW
         mov       bx,es:[di+EdiBBKur]      ; BX <- blok s kurzorem
         mov       si,es:[di+EdiOfKur]      ; SI <- offset kurzoru
         dec       si                       ; posun na posledn¡ znak © dku

; ------ poskytnut¡ bloku s normalizac¡ offsetu -> ES/BX/SI/CX

EditOrz2:call      EditNGet                 ; poskytnut¡ bloku
         jc        EditOrz9                 ; byla chyba operace
         je        EditOrz6                 ; je ji‘ za‡ tek souboru

; ------ zaji¨tˆn¡ platnosti ukazatele

EditOrz4:cmp       si,cx                    ; je platn  adresa ?
         jae       EditOrz2                 ; normalizace adresy

; ------ test, zda to je mezera

         cmp       byte ptr es:[si]," "     ; je to mezera ?
         jne       EditOrz6                 ; nen¡ tabul tor - je platn˜ znak

; ------ nalezena mezera - posun k p©ede¨l‚mu znaku

         dec       si                       ; posun ukazatele
         add       ax,1                     ; zv˜¨en¡ ‡¡ta‡e mezer k ru¨en¡
         adc       bp,0
         jmp       short EditOrz4           ; dal¨¡ znak

; ------ zru¨en¡ znak– mezer z konce © dku

EditOrz6:inc       si                       ; n vrat za nalezen˜ platn˜ znak
         mov       cx,bp                    ; CX <- po‡et znak– HIGH
         or        ax,ax                    ; jsou nˆjak  data ?
         jnz       EditOrz7                 ; jsou nˆjak  data
         jcxz      EditOrz9                 ; nejsou ‘ dn  data k ru¨en¡
EditOrz7:call      EditDel                  ; zru¨en¡ mezer
         jc        EditOrz9                 ; chyba operace

; ------ aktualizace ukazatel– blok–

         call      EditGt0D                 ; obnoven¡ adresy okna
         mov       bp,offset EdiChPBD       ; oprava po vypu¨tˆn¡ mezer
         call      EdiChPBA                 ; oprava ukazatel–

; ------ aktualizace © dku s kurzorem

         call      EditModA                 ; po‘adavek aktualizace okna
         call      EditAktW                 ; aktualizace © dku s kurzorem

; ------ n vrat registr–

EditOrz9:pop       bp
         pop       si
         pop       cx
         pop       bx
         pop       ax
         call      EditGt0D                 ; obnoven¡ adresy okna
         ret

EditOrez ENDP

; -----------------------------------------------------------------------------
;        o©ez n¡ mezer na konci © dku BX:SI (CY=chyba) (okno DX/ES)
;      Pou‘¡v  se p©i ru¨en¡ a navracen¡ bloku - neaktualizuje ukazatele!
; -----------------------------------------------------------------------------

EditLOrz PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      si
         push      di

; ------ adresa aktivn¡ho okna

         mov       di,EdiW1                 ; definice pro okno 1
         or        dh,dh                    ; je aktivn¡ okno 2 ?
         jns       EditLOr1                 ; je aktivn¡ okno 1
         mov       di,EdiW2                 ; definice pro okno 2

; ------ test, zda je operace povolena (povolena editace,text.m¢d,optimalizace)

EditLOr1:test      byte ptr es:[EdiParm],bit2 ; je povolena editace souboru ?
         jnz       EditLOr9                 ; z kaz z pisu
         test      byte ptr es:[di+EdiParm1],bit0+bit1+bit2+bit5 ; zobraz./BIN/HEX/opt. ?
         jnz       EditLOr9                 ; je zobrazen¡/BIN/HEX/opt.-z kaz

; ------ p©esun ukazatele na konec © dku

         mov       cx,-1
         mov       ax,cx                    ; maxim ln¡ pozice
         call      EditGtPO                 ; adresa pozice konce © dku
         jc        EditLOr9

; ------ test, zda je posledn¡ znak mezera

EditLOr3:dec       si                       ; p©ede¨l˜ znak
         call      EdiGetCh                 ; p©ede¨l˜ znak
         jz        EditLOr9                 ; nen¡ dal¨¡ znak (nebo chyba)
         cmp       al," "                   ; je to mezera ?
         clc                                ; p©¡znak operace OK
         jne       EditLOr9                 ; je jin˜ znak - konec

; ------ zru¨en¡ znaku mezery z konce © dku

         xor       cx,cx                    ; CX <- 0
         mov       ax,1                     ; ru¨¡ se 1 znak
         call      EditDel                  ; zru¨en¡ znaku
         jc        EditLOr9                 ; chyba

; ------ aktualizace © dku s kurzorem

         call      EditModA                 ; po‘adavek aktualizace okna
         jmp       short EditLOr3           ; dal¨¡ znak

; ------ n vrat registr–

EditLOr9:pop       di
         pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

EditLOrz ENDP

; -----------------------------------------------------------------------------
;        Ctrl-N vlo‘en¡ konce © dku
; -----------------------------------------------------------------------------

EditNLn  PROC      NEAR

; ------ p©i zobrazen¡ se funkce neprovede

         test      byte ptr es:[di+EdiParm1],bit0 ; je zobrazen¡ ?
         jnz       EditNLn4                 ; je jen zobrazen¡ - ignoruje se

; ------ £schova © dku s kurzorem

         call      EditGetK                 ; poskytnut¡ © dku s kurzorem
         push      ax
         push      cx

; ------ £schova pozice s kurzorem

         call      EditGtKP                 ; poskytnut¡ pozice kurzoru
         push      ax
         push      cx

; ------ £schova p©ep¡na‡e INSERT

         mov       al,ds:[EditParm]         ; p©¡znak INSERT
         push      ax

; ------ zapnut¡ p©¡znaku INSERT (pouze pro textov˜ m¢d)

         test      byte ptr es:[di+EdiParm1],bit1+bit2 ; je textov˜ m¢d ?
         jnz       EditNLn2                 ; nen¡ textov˜ m¢d
         or        byte ptr ds:[EditParm],bit5 ; zapnut¡ INSERT

; ------ vlo‘en¡ nov‚ho © dku CR/LF

EditNLn2:call      EditEnt6                 ; vlo‘en¡ CR/LF

; ------ n vrat p©¡znaku INSERT

         pop       ax
         and       byte ptr ds:[EditParm],not bit5 ; nulov n¡ INSERT
         and       al,bit5                  ; p©¡znak INSERT
         or        ds:[EditParm],al         ; n vrat INSERT

; ------ n vrat pozice kurzoru

         pop       cx
         pop       ax
         test      byte ptr es:[di+EdiParm1],bit1+bit2 ; je textov˜ m¢d ?
         jnz       EditNLn3                 ; nen¡ textov˜ m¢d
         call      EditStKP                 ; nastaven¡ pozice kurzoru

; ------ n vrat © dku s kurzorem

EditNLn3:pop       cx
         pop       ax
         test      byte ptr es:[di+EdiParm1],bit1+bit2 ; je textov˜ m¢d ?
         jnz       EditNLn4                 ; nen¡ textov˜ m¢d
         call      EditSetK                 ; nastaven¡ © dku s kurzorem
EditNLn4:ret

EditNLn  ENDP

; -----------------------------------------------------------------------------
;        ENTER - dal¨¡ © dek
; -----------------------------------------------------------------------------

EditEnt  PROC      NEAR

; ------ test, zda je operace povolena

         test      byte ptr es:[di+EdiParm1],bit0 ; je zobrazen¡ ?
         jnz       EditEnt9                 ; je jen zobrazen¡ - ignoruje se
         call      EdiEShft                 ; ukon‡en¡ ozna‡ov n¡ bloku se SHIFT-
         test      byte ptr es:[EdiParm],bit2 ; je povolena editace souboru ?
         jnz       EditEnt8                  ; z kaz z pisu

; ------ test, zda je zapnut INSERT

         test      byte ptr ds:[EditParm],bit5 ; je INSERT ?
         jz        EditEnt8                 ; nen¡ INSERT
         test      byte ptr es:[di+EdiParm1],bit1+bit2 ; je bin rn¡/HEX m¢d ?
         jnz       EditEnt8                 ; je bin rn¡ nebo HEX m¢d

; ------ test, zda je fyzick˜ konec © dku (nesm¡ b˜t za koncem © dku)

         call      EditCmKL                 ; porovn n¡ pozice kurzoru s d‚lkou © dku
         jbe       EditEnt6                 ; je uvnit© nebo na konci © dku
         call      EditEndX                 ; p©esun na fyzick˜ konec © dku
         call      EditAktW                 ; aktualizace oken

; ------ vlo‘en¡ znak– CR/LF
; Je vol no z EditNLn !!!!
EditEnt6:mov       bx,CR                    ; prvn¡ znak (CR)
         call      EditChr                  ; vlo‘en¡ znaku (CR)
         call      EditAktW                 ; aktualizace oken
         mov       bx,LF                    ; druh˜ znak (LF)
         call      EDitChr                  ; vlo‘en¡ znaku (LF)
         ret

; ------ ENTER, nen¡-li INSERT nebo je-li z kaz z pisu

EditEnt8:call      EditHomY                 ; posun na za‡ tek © dku
         call      EditDwnY                 ; posun o © dek dol–
EditEnt9:ret

EditEnt  ENDP

; -----------------------------------------------------------------------------
;        zru¨en¡ znaku p©ed kurzorem BS
; -----------------------------------------------------------------------------

EditBS   PROC      NEAR

; ------ test, zda je operace povolena

         test      byte ptr es:[di+EdiParm1],bit0 ; je zobrazen¡ ?
         jz        EditBS1                  ; je editace
EditBS0: ret

; ------ p©i editaci ukon‡en¡ ozna‡ov n¡ SHIFT-

EditBS1: call      EdiEShft                 ; ukon‡en¡ ozna‡ov n¡ bloku se SHIFT-

; ------ p©i z kazu z pisu a p©i HEX m¢du/HEX pole pouze posun kurzoru vlevo

         test      byte ptr es:[EdiParm],bit2 ; je z kaz editace ?
         jnz       EditBS2                  ; je z kaz z pisu
         test      byte ptr es:[di+EdiParm1],bit1 ; je HEX m¢d ?
         jz        EditBS3                  ; nen¡ HEX m¢d
         test      byte ptr es:[di+EdiParm2],bit2 ; je ASCII ‡ st HEX pole ?
         jnz       EditBS3                  ; je ASCII ‡ st HEX pole
EditBS2: jmp       EditLftY                 ; posun kurzoru vlevo

; ------ operace zak z na, je-li kurzor na za‡ tku souboru (nutn‚ pro BIN a HEX)

EditBS3: mov       ax,word ptr es:[di+EdiOffsK] ; offset kurzoru
         or        ax,word ptr es:[di+EdiOffsK+2]
         jz        EditBS0                  ; je ji‘ za‡ tek souboru

; ------ je-li kurzor za koncem © dku, nahrad¡ se posunem kurzoru vlevo

         call      EditCmKL                 ; porovn n¡ pozice kurzoru s d‚lkou © dku
         ja        EditBS2                  ; n hrada posuvem kurzoru vlevo

; ------ pro HEX m¢d je trvale vypnut INSERT

         test      byte ptr es:[di+EdiParm1],bit1 ; je HEX m¢d ?
         jnz       EditBS8                  ; je HEX m¢d

; ------ pro bin rn¡ m¢d se neuplat¤uje p©elom © dku

         test      byte ptr es:[di+EdiParm1],bit2 ; je bin rn¡ m¢d ?
         jnz       EditBS6                  ; je bin rn¡ m¢d

; ------ test, zda je ji‘ prvn¡ pozice na © dku

         mov       ax,word ptr es:[di+EdiPKur] ; pozice kurzoru
         or        ax,word ptr es:[di+EdiPKur+2] ; je po‡ tek © dku ?
         jnz       EditBS6                  ; nen¡ po‡ tek © dku

; ------ test, zda je ji‘ prvn¡ © dek

         mov       ax,word ptr es:[di+EdiRKur] ; © dek s kurzorem
         or        ax,word ptr es:[di+EdiRKur+2] ; je prvn¡ © dek ?
         jz        EditBS0                  ; je ji‘ prvn¡ © dek

; ------ je po‡ tek © dku - p©esun na konec p©edch zej¡c¡ho © dku

         call      EditUpY                  ; posun o © dek nahoru
         call      EditAktW                 ; aktualizace okna
         call      EditEndY                 ; posun na konec p©ede¨l‚ho © dku
         call      EditAktW                 ; aktualizace okna

; ------ konec © dku se ru¨¡ jen p©i zapnut‚m INSERT

         test      byte ptr ds:[EditParm],bit5 ; je zapnut INSERT ?
         jnz       EditBS7                  ; je zapnut INSERT
         ret


; ------ test, zda je zapnut INSERT

EditBS6: test      byte ptr ds:[EditParm],bit5 ; je zapnut INSERT ?
         jz        EditBS8                  ; je vypnut INSERT

; ------ je-li kurzor uprost©ed © dku a je zapnut INSERT, znak se zru¨¡

         call      EditLftY                 ; posun kurzoru vlevo
         call      EditAktW                 ; aktualizace okna
EditBS7: jmp       EditDelC                 ; zru¨en¡ znaku za kurzorem

; ------ je-li kurzor uprost©ed © dku a je vypnut INSERT, znak se jen vyma‘e

EditBS8: call      EditLftY                 ; posun kurzoru vlevo
         call      EditAktW                 ; aktualizace okna
         mov       bx," "                   ; znak mezery k vymaz n¡
         call      EditChr                  ; vlo‘en¡ znaku BX
         call      EditAktW                 ; aktualizace okna
EditBS9: jmp       EditLftY                 ; posun kurzoru vlevo

EditBS   ENDP

; -----------------------------------------------------------------------------
;        zru¨en¡ znaku za kurzorem DELETE
; -----------------------------------------------------------------------------

EditDelC PROC      NEAR

; ------ test, zda je operace povolena

         test      byte ptr es:[EdiParm],bit2 ; je povolena editace souboru ?
         jnz       EditDlC2                 ; z kaz z pisu
         test      byte ptr es:[di+EdiParm1],bit0+bit1 ; je zobrazen¡/HEX ?
         jnz       EditDlC2                 ; je jen zobrazen¡/HEX - z kaz

; ------ bude zak z no ozna‡ov n¡ bloku se SHIFT-

         call      EdiEShft                 ; ukon‡en¡ ozna‡ov n¡ bloku se SHIFT-

; ------ normalizace kurzoru, aby nebyl na odskoku tabul toru

         mov       bp,16                    ; maxim ln¡ po‡et pokus–
EditDlC1:test      byte ptr es:[di+EdiParm2],bit0 ; je odskok tabul toru ?
         jz        EditDlC3                 ; nen¡ odskok tabul toru
         push      bp
         mov       bp,1                     ; po‡et pozic k posunu
         call      EditKrLf                 ; posun kurzoru vlevo
         call      EditAktW                 ; aktualizace okna
         pop       bp
         dec       bp                       ; ‡¡ta‡ pokus–
         jnz       EditDlC1                 ; dal¨¡ pokus
EditDlC2:ret

; ------ kontrola, zda je kurzor uvnit© textu

EditDlC3:call      EditCmKO                 ; porovn n¡ kurzoru s d‚lkou textu
         jae       EditDlC2                 ; kurzor je za koncem textu

; ------ doplnˆn¡ mezer po kurzor

         call      EditDopS                 ; doplnˆn¡ mezer po kurzor
         jc        EditDlC2                 ; chyba operace

; ------ test, zda je kurzor na konci © dku (pro BIN m¢d je v‘dy p©ed koncem)

         call      EditCmKL                 ; porovn n¡ pozice kurzoru s d‚lkou © dku
         ja        EditDlC2                 ; kurzor za koncem © dku (=chyba)
         mov       ah," "                   ; fiktivn¡ znak
         jb        EditDlC7                 ; kurzor nen¡ na konci © dku
         or        byte ptr ds:[EditPar2],bit2 ; p©¡znak zobrazen¡ okna

; ------ zji¨tˆn¡ 2 znak– na konci © dku

         mov       bx,es:[di+EdiBBKur]      ; blok s kurzorem
         mov       si,es:[di+EdiOfKur]      ; offset kurzoru
         call      EdiGetCh                 ; znak za kurzorem
         jz        EditDlC2                 ; nen¡ dal¨¡ znak (konec souboru)
         inc       si                       ; n sleduj¡c¡ pozice
         mov       ah,al                    ; AH <- prvn¡ znak
         call      EdiGetCh                 ; n sleduj¡c¡ znak

; ------ test, zda jsou 2 znaky konce © dku

         cmp       ax,CR*HI + LF
         je        EditDlC6                 ; je LF/CR
         cmp       ax,LF*HI + CR
EditDlC6:mov       al,2                     ; AX <- 2 ru¨¡ se 2 znaky
         je        EditDlC8                 ; je LF/CR nebo CR/LF

; ------ zru¨en¡ znaku AH na pozici kurzoru

EditDlC7:mov       al,1                     ; AL <- 1 (ru¨¡ se 1 znak)
EditDlC8:mov       bx,es:[di+EdiBBKur]      ; blok s kurzorem
         mov       si,es:[di+EdiOfKur]      ; offset kurzoru
         xor       cx,cx                    ; CX <- 0
         push      ax                       ; AH=ru¨en˜ znak, AL=po‡et znak–
         mov       ah,0
         call      EditDel                  ; zru¨en¡ znaku
         pop       ax
         jc        EdiDlC88                 ; chyba

; ------ korekce ukazatel– bloku (AL=po‡et znak– 1 nebo 2, AH=ru¨en˜ znak)

         mov       bp,offset EditDlCB       ; korekce ukazatel–
         call      EdiChPBA                 ; korekce ukazatel–

; ------ aktualizace oken

EdiDlC88:or        byte ptr ds:[EditPar2],bit1 ; p©¡znak zobrazen¡ © dku
         call      EditModA                 ; po‘adavek aktualizace okna
         call      EditAktW                 ; aktualizace
         call      EditOrez                 ; o©ez n¡ mezer z konce © dku
         call      EdiAktBl                 ; aktualizace ukazatel– bloku
EditDlC9:ret

EditDelC ENDP

; -----------------------------------------------------------------------------
;        oprava bloku ES:SI po zru¨en¡ AL znak– (AH=znak) za kurzorem (maska BL)
; -----------------------------------------------------------------------------

EditDlCB PROC      NEAR

; ------ £schova registr–

         push      ax
         mov       bh,ah                    ; BH <- £schova ru¨en‚ho znaku
         mov       ah,0                     ; AX = po‡et ru¨en˜ch znak–

; ------ oprava offsetu ukazatele pro bin rn¡ (a HEX) m¢d

         test      byte ptr es:[di+EdiParm1],bit1+bit2 ; je BIN/HEX m¢d ?
         jz        EdiDlCB4                 ; nen¡ BIN/HEX m¢d
         call      EdiChPBO                 ; test offsetu
         jae       EdiDlCB3                 ; nen¡ p©ed offsetem bloku
EdiDlCB1:or        es:[EdiParm0],bl         ; ukazatel bloku neplatn˜
EdiDlCB2:sub       word ptr es:[si+8],ax    ; oprava offsetu bloku
         sbb       word ptr es:[si+8+2],0

; ------ n vrat registr–

EdiDlCB3:pop       ax
         ret

; ------ rozli¨en¡, zda byl ru¨en p©elom © dku

EdiDlCB4:cmp       al,2                     ; ru¨eny 2 znaky ?
         je        EdiDlCB6                 ; ru¨eny 2 znaky - p©elom © dku
         cmp       bh,LF                    ; ru¨en znak LF ?
         je        EdiDlCB6                 ; ru¨en znak LF - p©elom © dku

; ------ ru¨en bˆ‘n˜ znak - kontrola, zda je © dek s kurzorem

         call      EdiChPBK                 ; je © dek s kurzorem ?
         ja        EdiDlCB3                 ; kurzor je za ukazatelem
         jb        EdiDlCB2                 ; kurzor je p©ed ukazatelem

; ------ je © dek s kurzorem - porovn n¡ pozice kurzoru

         call      EdiChPBP                 ; porovn n¡ pozice kurzoru
         jae       EdiDlCB3                 ; kurzor je za ukazatelem bloku

; ------ kurzor je p©ed ukazatelem - posune se ‡¡slo pozice

         sub       word ptr es:[si],ax      ; sn¡‘en¡ ‡¡sla pozice ukazatele
         sbb       word ptr es:[si+2],0

; ------ test, zda je pozice ukazatele uvnit© © dku

         call      EdiChPBL                 ; porovn n¡ d‚lky © dku
EdiDlCB5:jae       EdiDlCB1                 ; uvnit© © dku se ukazatel aktualizuje
         jmp       short EdiDlCB2           ; jen zv˜¨en¡ offsetu ukazatele

; ------ ru¨en p©elom © dku - porovn n¡ © dku kurzoru

EdiDlCB6:call      EdiChPBK                 ; je kurzor na © dku p©ed blokem ?
         ja        EdiDlCB3                 ; kurzor je za ukazatelem bloku
         je        EdiDlCB7                 ; je © dek s kurzorem

; ------ kurzor je p©ed ukazatelem - posune se ‡¡slo © dku

         sub       word ptr es:[si+4],1     ; sn¡‘en¡ ‡¡sla © dku ukazatele
         sbb       word ptr es:[si+4+2],0

; ------ p©i spojen¡ © dk– je nutno pozici aktualizovat

         call      EdiChPBK                 ; je nyn¡ kurzor na © dku bloku ?
         je        EdiDlCB1                 ; ukazatel nutno aktualizovat
         jmp       short EdiDlCB2           ; zv˜¨en¡ offsetu ukazatele

; ------ je © dek s kurzorem - porovn n¡ pozice kurzoru

EdiDlCB7:call      EdiChPBP                 ; porovn n¡ pozice kurzoru
         jae       EdiDlCB3                 ; kurzor je za ukazatelem bloku

; ------ p©i spojen¡ © dk– plat¡ pozice kurzoru jako pozice ukazatele

         push      ax
         mov       ax,word ptr es:[di+EdiPKur] ; pozice kurzoru na © dku
         mov       es:[si],ax               ; je to pozice ukazatele
         mov       ax,word ptr es:[di+EdiPKur+2]
         mov       es:[si+2],ax
         mov       ax,word ptr es:[di+EdiOffsK] ; offset kurzoru
         mov       es:[si+8],ax             ; offset ukazatele
         mov       ax,word ptr es:[di+EdiOffsK+2]
         mov       es:[si+8+2],ax
         pop       ax
         jmp       short EdiDlCB3

EditDlCB ENDP

; -----------------------------------------------------------------------------
;        zru¨en¡ © dku Ctrl-Y
; -----------------------------------------------------------------------------

EditDelL PROC      NEAR

; ------ test, zda je operace povolena

         test      byte ptr es:[EdiParm],bit2 ; je povolena editace souboru ?
         jnz       EditDlL9                 ; z kaz z pisu
         test      byte ptr es:[di+EdiParm1],bit0+bit1+bit2 ; zobr./BIN/HEX ?
         jnz       EditDlL9                 ; je zobrazen¡/BIN/HEX - z kaz

; ------ ukon‡en¡ ozna‡ov n¡ bloku se SHIFT-

         call      EdiEShft                 ; ukon‡en¡ ozna‡ov n¡ bloku se SHIFT-

; ------ nalezen¡ n sleduj¡c¡ho © dku -> CX:AX

         call      EditGetK                 ; poskytnut¡ © dku s kurzorem->CX:AX
         add       ax,1                     ; ‡¡slo n sleduj¡c¡ho © dku
         adc       cx,0
         call      EdiGetLn                 ; ukazatele © dku -> BX:SI
         jc        EditDlL9                 ; chyba
         call      EdiGetOf                 ; offset © dku v souboru -> CX:AX

; ------ v˜po‡et offsetu ru¨en‚ho © dku -> BX:SI

         push      ax
         push      cx
         mov       si,es:[di+EdiOKur]       ; offset aktivn¡ho © dku
         mov       bx,es:[di+EdiBKur]       ; blok s aktivn¡m © dekm
         call      EdiGetOf                 ; v˜po‡et offsetu © dku -> CX:AX
         xchg      ax,si                    ; SI <- offset LOW
         mov       bx,cx                    ; BX <- offset HIGH
         pop       cx
         pop       ax

; ------ po‡et bajt– ke zru¨en¡ -> CX:AX

         sub       ax,si                    ; po‡et bajt– k ru¨en¡
         sbb       cx,bx
         jc        EditDlL9                 ; nˆjak  chyba ?
         jnz       EditDlL3                 ; jsou nˆjak  data k ru¨en¡
         or        ax,ax                    ; jsou nˆjak  data ?
         jz        EditDlL9                 ; je konec souboru

; ------ zru¨en¡ © dku

EditDlL3:mov       si,es:[di+EdiOKur]       ; offset aktivn¡ho © dku
         mov       bx,es:[di+EdiBKur]       ; blok s aktivn¡m © dekm
         call      EditDel                  ; zru¨en¡ © dku
         jc        EditDlL8                 ; nˆjak  chyba operace

; ------ oprava ukazatel– bloku (CX:AX=po‡et ru¨en˜ch bajt–)

         mov       bp,offset EditDlLB       ; obsluha aktualizace ukazatel–
         call      EdiChPBA                 ; proveden¡ korekce ukazatel–

; ------ aktualizace parametr–

EditDlL8:or        byte ptr ds:[EditPar2],bit2 ; p©¡znak zobrazen¡ okna
         call      EditModA                 ; po‘adavek aktualizace oken
EditDlL9:ret

EditDelL ENDP

; -----------------------------------------------------------------------------
;        oprava ukazatele ES:SI bloku (CX:AX=po‡et ru¨en˜ch bajt–, BL=maska)
; -----------------------------------------------------------------------------

EditDlLB PROC      NEAR

; ------ £schova registr–

         push      dx
         push      bp

; ------ p©¡prava offsetu © dku s kurzorem -> BP:DX

         push      ax
         push      bx
         push      cx
         push      si

         mov       bx,es:[di+EdiBKur]       ; blok © dku s kurzorem
         mov       si,es:[di+EdiOKur]       ; offset © dku s kurzorem
         call      EdiGetOf                 ; p©evod na offset v souboru CX:AX

         xchg      ax,dx                    ; DX <- offset LOW
         mov       bp,cx                    ; BP <- offset HIGH

         pop       si
         pop       cx
         pop       bx
         pop       ax

; ------ porovn n¡ © dku s ukazatelem

         call      EdiChPBK                 ; porovn n¡ © dku s ukazatelem
         ja        EdiDlLB9                 ; kurzor je za ukazatelem
         je        EdiDlLB4                 ; je na ru¨en‚m © dku s kurzorem

; ------ kurzor je p©ed ukazatelem - oprava ‡¡sla © dku ukazatele

         sub       word ptr es:[si+4],1     ; sn¡‘en¡ ‡¡sla © dku ukazatele
         sbb       word ptr es:[si+4+2],0

; ------ oprava offsetu ukazatele

         sub       es:[si+8],ax             ; oprava offsetu ukazatele
         sbb       es:[si+8+2],cx
         jnc       EdiDlLB9                 ; nen¡ podte‡en¡ OK

; ------ offset ukazatele nastaven na za‡ tek © dku

EdiDlLB4:mov       es:[si+8],dx             ; nastaven shodnˆ s offsetem © dku
         mov       es:[si+8+2],bp

; ------ pro textov˜ blok nastavena pozice na © dku = 0

         test      byte ptr es:[EdiParm],bit6+bit7 ; je textov˜ blok ?
         jnz       EdiDlLB6                 ; nen¡ textov˜ blok
         mov       word ptr es:[si],0       ; pozice na © dku = 0
         mov       word ptr es:[si+2],0
         jmp       short EdiDlLB9

; ------ pro © dkov˜ a sloupcov˜ blok se konec bloku posune

EdiDlLB6:cmp       bl,bit1                  ; je konec bloku ?
         jne       EdiDlLB9                 ; nen¡ konec bloku
         sub       word ptr es:[si+4],1     ; sn¡‘en¡ ‡¡sla © dku konce bloku
         sbb       word ptr es:[si+4+2],0

; ------ n vrat registr–

EdiDlLB9:pop       bp
         pop       dx
         ret

EditDlLB ENDP

; -----------------------------------------------------------------------------
;        zru¨en¡ slova za kurzorem Ctrl-T a Ctrl-Delete
; -----------------------------------------------------------------------------

EditCtrT PROC      NEAR

; ------ kontrola, zda je operace povolena

         test      byte ptr es:[di+EdiParm1],bit0+bit1 ; editace/HEX ?
         jnz       EdiCtrT9                 ; je HEX m¢d nebo je zobrazen¡
         test      byte ptr es:[EdiParm],bit2 ; je z kaz z pisu ?
         jnz       EdiCtrT9                 ; je z kaz z pisu

; ------ ukon‡en¡ ozna‡ov n¡ bloku

         call      EdiEShft                 ; ukon‡en¡ ozna‡ov n¡ bloku se SHIFT-

; ------ na‡ten¡ hodnoty znaku pod kurzorem -> BH

         call      EditCtTA                 ; na‡ten¡ hodnoty znaku -> BL
         jz        EdiCtrT9                 ; chyba nebo konec dat
         mov       bh,bl                    ; BH <- £schova hodnoty znaku

; ------ £schova velikosti souboru -> CX:AX

         call      EditCtTG                 ; £schova velikosti souboru

; ------ zru¨en¡ znaku pod kurzorem

EdiCtrT4:push      ax
         push      bx
         push      cx

         call      EditDelC                 ; zru¨en¡ znaku za kurzorem
         call      EditAktW                 ; aktualizace okna

         pop       cx
         pop       bx
         pop       ax

; ------ kontrola, zda byl znak zru¨en

         call      EditCtTS                 ; zmen¨ila se velikost souboru ?
         jbe       EdiCtrT9                 ; chyba operace

; ------ test dal¨¡ho znaku, zda se bude ru¨it

         call      EditCtTA                 ; na‡ten¡ hodnoty znaku -> BL
         jz        EdiCtrT9                 ; chyba nebo konec dat
         cmp       bl,bh                    ; je to stejn  hodnota znaku ?
         jne       EdiCtrT9                 ; nen¡ stejn  hodnota znaku

; ------ p©eru¨en¡ operace Ctrl-Break nebo ESC

         call      far ptr TestBEsc         ; je p©eru¨en¡ operace ?
         jnc       EdiCtrT4                 ; nen¡ p©eru¨en¡ - dal¨¡ znak
         call      far ptr FlushEsc         ; vypr zdnˆn¡ bufferu kl vesnice
EdiCtrT9:ret

EditCtrT ENDP

; ------ na‡ten¡ hodnoty znaku p©ed kurzorem -> BL (CY=chyba, ZY=nejsou data)

EditCtTB:mov       si,es:[di+EdiOfKur]      ; offset kurzoru
         dec       si                       ; p©ede¨l˜ znak
         jmp       short EditCTA1

; ------ na‡ten¡ hodnoty znaku pod kurzorem -> BL (CY=chyba, ZY=nejsou data)

EditCtTA:mov       si,es:[di+EdiOfKur]      ; offset kurzoru

EditCTA1:push      ax
         xchg      ax,bx                    ; AH <- £schova BH

         call      EditCmKL                 ; porovn n¡ pozice kurzoru s d‚lkou © dku
         mov       al," "                   ; n hradn¡ znak mezery
         ja        EditCtTC                 ; kurzor je za koncem © dku

         mov       bx,es:[di+EdiBBKur]      ; blok s kurzorem
         call      EdiGetCh                 ; znak za kurzorem

EditCtTC:pushf
         push      ds
         mov       bx,SEG CodeDek           ; segment dek¢dovac¡ tabulky
         mov       ds,bx                    ; DS <- segment dek¢dovac¡ tabulky
         mov       bx,offset TabTypCh       ; tabulka znak–
         xlat                               ; hodnota znaku
         and       al,bit0+bit1             ; maskov n¡ hodnoty znaku
         pop       ds
         popf
         xchg      ax,bx                    ; BL <- na‡ten  hodnota, BH<-n vrat

         pop       ax
         ret

; ------ kontrola, zda byla zmˆnˆna velikost souboru -> chyba p©i JBE xxxx

EditCtTS:cmp       cx,word ptr es:[EdiSize+2]
         jne       EditCtTG
         cmp       ax,word ptr es:[EdiSize]
EditCtTG:mov       cx,word ptr es:[EdiSize+2]
         mov       ax,word ptr es:[EdiSize]
         ret

; -----------------------------------------------------------------------------
;        maz n¡ slova p©ed kurzorem Ctrl-BS
; -----------------------------------------------------------------------------

EditCtBS PROC      NEAR

; ------ kontrola, zda je operace povolena

         test      byte ptr es:[di+EdiParm1],bit0+bit1 ; editace/HEX ?
         jnz       EditCBS9                 ; je HEX m¢d nebo je zobrazen¡
         test      byte ptr es:[EdiParm],bit2 ; je z kaz z pisu ?
         jnz       EditCBS9                 ; je z kaz z pisu

; ------ ukon‡en¡ ozna‡ov n¡ bloku

         call      EdiEShft                 ; ukon‡en¡ ozna‡ov n¡ bloku se SHIFT-

; ------ je-li kurzor za koncem souboru, pouze se provede p©esun na konec souboru

         call      EdiGetCL                 ; poskytnut¡ po‡tu © dk– -> CX:AX
         call      EditCmpK                 ; porovn n¡ © dku kurzoru
         jae       EditCBS2                 ; nen¡ konec souboru
         jmp       EditCPgD                 ; p©esun na konec souboru

; ------ je-li kurzor za koncem © dku, pouze se provede p©esun na konec © dku

EditCBS2:call      EditCmKL                 ; porovn n¡ pozice kurzoru s d‚lkou © dku
         jbe       EditCBS3                 ; kurzor nen¡ za koncem © dku
         jmp       EditEndX                 ; p©esun na konec © dku

; ------ na‡ten¡ hodnoty znaku p©ed kurzorem -> BH

EditCBS3:call      EditCtTB                 ; na‡ten¡ hodnoty znaku -> BL
         jz        EditCBS9                 ; chyba nebo konec dat
         mov       bh,bl                    ; BH <- £schova hodnoty znaku

; ------ £schova velikosti souboru -> CX:AX

         call      EditCtTG                 ; £schova velikosti souboru

; ------ zru¨en¡ znaku p©ed kurzorem

EditCBS4:push      ax
         push      bx
         push      cx

         call      EditBS                   ; zru¨en¡ znaku p©ed kurzorem
         call      EditAktW                 ; aktualizace okna

         pop       cx
         pop       bx
         pop       ax

; ------ kontrola, zda byl znak zru¨en

         call      EditCtTS                 ; zmen¨ila se velikost souboru ?
         jbe       EditCBS9                 ; chyba operace

; ------ test dal¨¡ho znaku, zda se bude ru¨it

         call      EditCtTB                 ; na‡ten¡ hodnoty znaku -> BL
         jz        EditCBS9                 ; chyba nebo konec dat
         cmp       bl,bh                    ; je to stejn  hodnota znaku ?
         jne       EditCBS9                 ; nen¡ stejn  hodnota znaku

; ------ p©eru¨en¡ operace Ctrl-Break nebo ESC

         call      far ptr TestBEsc         ; je p©eru¨en¡ operace ?
         jnc       EditCBS4                 ; nen¡ p©eru¨en¡ - dal¨¡ znak
         call      far ptr FlushEsc         ; vypr zdnˆn¡ bufferu kl vesnice
EditCBS9:ret

EditCtBS ENDP

; -----------------------------------------------------------------------------
;        maz n¡ po za‡ tek © dku Ctrl-QH
; -----------------------------------------------------------------------------

EditCtQH PROC      NEAR

; ------ kontrola, zda je operace povolena

         test      byte ptr es:[di+EdiParm1],bit0+bit1+bit2 ; editace/BIN/HEX ?
         jnz       EditCQH9                 ; nen¡ textov˜ m¢d/nen¡ editace
         test      byte ptr es:[EdiParm],bit2 ; je z kaz z pisu ?
         jnz       EditCQH9                 ; je z kaz z pisu

; ------ ukon‡en¡ ozna‡ov n¡ bloku

         call      EdiEShft                 ; ukon‡en¡ ozna‡ov n¡ bloku se SHIFT-

; ------ £schova a zapnut¡ p©¡znaku INSERT

         push      word ptr ds:[EditParm]   ; £schova p©¡znaku INSERT
         or        byte ptr ds:[EditParm],bit5 ; zapnut¡ INSERT

; ------ £schova velikosti souboru -> CX:AX

         call      EditCtTG                 ; £schova velikosti souboru -> CX:AX

; ------ je-li za koncem © dku, p©esun kurzoru na konec © dku

EditCQH2:call      EditCmKL                 ; porovn n¡ pozice kurzoru s d‚lkou © dku
         jbe       EditCQH4                 ; kurzor nen¡ za koncem © dku

         push      ax
         push      cx
         call      EditEndX                 ; nastaven¡ na konec © dku
         call      EditAktW                 ; aktualizace okna
         pop       cx
         pop       ax

; ------ test, zda je ji‘ za‡ tek © dku

EditCQH4:mov       bx,word ptr es:[di+EdiPKur] ; pozice kurzoru na © dku LOW
         or        bx,word ptr es:[di+EdiPKur+2] ; je ji‘ za‡ tek © dku ?
         jz        EditCQH8                 ; je ji‘ za‡ tek © dku

; ------ vymaz n¡ znaku p©ed kurzorem

         push      ax
         push      cx
         call      EditBS                   ; maz n¡ znaku p©ed kurzorem
         call      EditAktW                 ; aktualizace okna
         pop       cx
         pop       ax

; ------ kontrola, zda byl znak zru¨en

         call      EditCtTS                 ; zmen¨ila se velikost souboru ?
         jbe       EditCQH8                 ; chyba operace

; ------ p©eru¨en¡ operace Ctrl-Break nebo ESC

         call      far ptr TestBEsc         ; je p©eru¨en¡ operace ?
         jnc       EditCQH2                 ; nen¡ p©eru¨en¡ - dal¨¡ znak
         call      far ptr FlushEsc         ; vypr zdnˆn¡ bufferu kl vesnice

; ------ n vrat p©¡znaku INSERT

EditCQH8:pop       ax
         and       byte ptr ds:[EditParm],not bit5 ; nulov n¡ INSERT
         and       al,bit5                  ; p©¡znak INSERT
         or        ds:[EditParm],al         ; n vrat INSERT
EditCQH9:ret

EditCtQH ENDP

; -----------------------------------------------------------------------------
;        useknut¡ konce © dku Ctrl-QY
; -----------------------------------------------------------------------------

EditCtQY PROC      NEAR

; ------ kontrola, zda je operace povolena

         test      byte ptr es:[di+EdiParm1],bit0+bit1+bit2 ; editace/BIN/HEX ?
         jnz       EditCQY9                 ; nen¡ textov˜ m¢d/nen¡ editace
         test      byte ptr es:[EdiParm],bit2 ; je z kaz z pisu ?
         jnz       EditCQY9                 ; je z kaz z pisu

; ------ ukon‡en¡ ozna‡ov n¡ bloku

         call      EdiEShft                 ; ukon‡en¡ ozna‡ov n¡ bloku se SHIFT-

; ------ £schova velikosti souboru -> CX:AX

         call      EditCtTG                 ; £schova velikosti souboru -> CX:AX

; ------ test, zda je ji‘ konec © dku

EditCQY2:call      EditCmKL                 ; porovn n¡ pozice kurzoru s d‚lkou © dku
         jae       EditCQY9                 ; je ji‘ konec © dku

; ------ zru¨en¡ znaku za kurzorem

         push      ax
         push      cx
         call      EditDelC                 ; zru¨en¡ znaku za kurzorem
         call      EditAktW                 ; aktualizace okna
         pop       cx
         pop       ax

; ------ kontrola, zda byl znak zru¨en

         call      EditCtTS                 ; zmen¨ila se velikost souboru ?
         jbe       EditCQY9                 ; chyba operace

; ------ p©eru¨en¡ operace Ctrl-Break nebo ESC

         call      far ptr TestBEsc         ; je p©eru¨en¡ operace ?
         jnc       EditCQY2                 ; nen¡ p©eru¨en¡ - dal¨¡ znak
         call      far ptr FlushEsc         ; vypr zdnˆn¡ bufferu kl vesnice
EditCQY9:ret

EditCtQY ENDP

; *****************************************************************************
;
;                         Posun kurzoru a obrazovky
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        tabul tor
; -----------------------------------------------------------------------------

EditTab  PROC      NEAR

; ------ test, zda je HEX m¢d

         test      byte ptr es:[di+EdiParm1],bit1 ; je HEX m¢d ?
         jz        EditTab2                 ; nen¡ HEX m¢d

; ------ p©i editaci v HEX m¢du se p©epne editovan‚ pole

; sem se sk ‡e z EditSTab !

EditTab1:xor       byte ptr es:[di+EdiParm2],bit2 ; zmˆna p©¡znaku ASCII pole
         call      Edit1Hex                 ; je prvn¡ znak HEX pole
         or        byte ptr ds:[EditPar2],bit0 ; p©¡znak - zmˆna kurzoru
         ret

; ------ ukon‡en¡ ozna‡ov n¡ bloku se SHIFT-

EditTab2:call      EdiEShft                 ; ukon‡en¡ ozna‡ov n¡ bloku se SHIFT-

; ------ obsluha tabul toru v bin rn¡m m¢du (odskoky jsou jako offset v souboru)

         mov       ax,word ptr es:[di+EdiOffsK] ; offset kurzoru v souboru
         mov       cx,word ptr es:[di+EdiOffsK+2]
         test      byte ptr es:[di+EdiParm1],bit2 ; je bin rn¡ m¢d ?
         jnz       EditTab5                 ; je bin rn¡ m¢d

; ------ posun kurzoru na vy¨¨¡ tabula‡n¡ pozici

         call      EditGtKP                 ; poskytnut¡ pozice kurzoru
EditTab5:add       ax,ds:[EdiTabul]         ; p©i‡ten¡ odskoku tabul toru
         adc       cx,0

; ------ vydˆlen¡ pozice kurzoru odskokem tabul toru (pro zarovn n¡)
; sem se sk ‡e z EditSTab !

EditTab6:push      dx
         xchg      ax,bx                    ; BX <- pozice LOW
         mov       ax,ds:[EdiTabul]         ; AX <- po‡et pozic na tabul tor
         xchg      ax,cx                    ; AX <- pozice HIGH, CX <- odskok
         xor       dx,dx                    ; DX <- 0
         div       cx                       ; AX <- odskok– HIGH
         xchg      ax,bx                    ; AX <- pozice LOW, BX <- odskok– HIGH
         div       cx                       ; AX <- odskok– LOW

; ------ vyn soben¡ odskokem tabul toru (pro p©epo‡et zpˆt na pozici)

         xchg      ax,bx                    ; AX <- odskok– HIGH, BX <- odskok– LOW
         mul       cx                       ; AX <- pozice HIGH
         xchg      ax,bx                    ; BX <- pozice HIGH, AX <- odskok– LOW
         mul       cx                       ; DX:AX <- pozice HIGH
         add       dx,bx                    ; DX <- pozice HIGH
         mov       cx,dx                    ; CX <- pozice HIGH
         pop       dx

; ------ test, zda je bin rn¡ m¢d

         test      byte ptr es:[di+EdiParm1],bit2 ; je bin rn¡ m¢d ?
         jz        EditTab8                 ; nen¡ bin rn¡ m¢d

; ------ nastaven¡ © dku a pozice kurzoru pro bin rn¡ m¢d

         call      EdiGetAd                 ; p©epo‡et na blok a offset
         jmp       EditCRg8                 ; nastaven¡ pozice kurzoru

; ------ nastaven¡ nov‚ pozice kurzoru pro textov˜ m¢d

EditTab8:call      EditStKP                 ; nastaven¡ nov‚ pozice kurzoru
EditTab9:ret

EditTab  ENDP

; -----------------------------------------------------------------------------
;        Shift-TAB zpˆtn˜ tabul tor
; -----------------------------------------------------------------------------

EditSTab PROC      NEAR

; ------ test, zda je HEX m¢d

         test      byte ptr es:[di+EdiParm1],bit1 ; je HEX m¢d ?
         jnz       EditTab1                 ; je HEX m¢d

; ------ ukon‡en¡ ozna‡ov n¡ bloku se SHIFT-

         call      EdiEShft                 ; ukon‡en¡ ozna‡ov n¡ bloku se SHIFT-

; ------ obsluha tabul toru v bin rn¡m m¢du (odskoky jsou jako offset v souboru)

         mov       ax,word ptr es:[di+EdiOffsK] ; offset kurzoru v souboru
         mov       cx,word ptr es:[di+EdiOffsK+2]
         test      byte ptr es:[di+EdiParm1],bit2 ; je bin rn¡ m¢d ?
         jnz       EditSTb5                 ; je bin rn¡ m¢d

; ------ posun kurzoru o pozici vlevo

         call      EditGtKP                 ; poskytnut¡ pozice kurzoru
EditSTb5:sub       ax,1                     ; posun kurzoru vlevo
         sbb       cx,0
         jnc       EditTab6                 ; nen¡ podte‡en¡
         ret

EditSTab ENDP

; -----------------------------------------------------------------------------
;        slovo vlevo
; -----------------------------------------------------------------------------

EditCLft PROC      NEAR

; ------ zah jen¡ ozna‡ov n¡ bloku SHIFT- (jen aktivn¡ okno)

         call      EdiBShft                 ; zah jen¡ ozna‡ov n¡ bloku SHIFT-

; ------ synchronizace oken

EditCLfY:call      EditSyn                  ; synchronizace oken

; ------ test, zda m  b˜t posun cel‚ obrazovky (zobrazen¡ textu)

         test      byte ptr es:[di+EdiParm1],bit0 ; je editace ?
         jz        EditCLf2                 ; je editace
         test      byte ptr es:[di+EdiParm1],bit1+bit2 ; je bin rn¡/HEX m¢d ?
         jnz       EditCLf1                 ; je bin rn¡ nebo HEX m¢d -> nic

; ------ p©¡prava po‡tu pozic k posunu obrazovky -> BP

         mov       al,es:[di+EdiSir]        ; ¨¡©ka okna
         mov       ah,0
         shr       ax,1                     ; polovina ¨¡©ky okna
         xchg      ax,bp                    ; BP <- po‡et pozic k posunu

; ------ horizont ln¡ posun obrazovky

         call      EditRlRg                 ; posun obrazovky vpravo
         call      EditKrLf                 ; posun kurzoru vlevo
EditCLf1:ret

; ------ p©i editaci HEX pole v HEX m¢du se jen posune na p©edchoz¡ bajt vlevo

EditCLf2:test      byte ptr es:[di+EdiParm1],bit1 ; je HEX m¢d ?
         jz        EditCLf3                 ; nen¡ HEX m¢d
         test      byte ptr es:[di+EdiParm2],bit2 ; je ASCII ‡ st HEX pole ?
         jnz       EditCLf3                 ; je ASCII ‡ st HEX pole
         call      Edit1Hex                 ; je prvn¡ znak HEX pole
         call      EditLftX                 ; posun kurzoru
         call      Edit1Hex                 ; je prvn¡ znak HEX pole
         ret

; ------ p©¡prava ukazatel– pro operaci -> BX:SI

EditCLf3:mov       bx,es:[di+EdiBBKur]      ; blok s kurzorem
         mov       si,es:[di+EdiOfKur]      ; offset kurzoru
         dec       si                       ; nastaven¡ na p©ede¨l˜ znak

; ------ na‡ten¡ prvn¡ho znaku na pozici kurzoru -> AH

         mov       ah," "                   ; p©¡padn˜ p©ede¨l˜ znak
         call      EditNGet                 ; poskytnut¡ bloku
         je        EditCLf8                 ; chyba nebo konec
         mov       ah,es:[si]               ; znak p©ed kurzorem
         dec       si                       ; nastaven¡ na p©edchoz¡ znak

; ------ poskytnut¡ bloku s normalizac¡ offsetu -> ES/BX/SI/CX

EditCLf5:call      EditNGet                 ; poskytnut¡ bloku
         je        EditCLf8                 ; chyba nebo konec souboru

; ------ na‡ten¡ p©edchoz¡ho znaku -> AL

EditCLf6:cmp       si,cx                    ; je platn  adresa ?
         jae       EditCLf5                 ; normalizace adresy
         mov       al,es:[si]               ; na‡ten¡ dal¨¡ho znaku

; ------ test, zda to je konec © dku LF

         cmp       ah,LF                    ; je ukazatel na LF ?
         je        EditCLf7                 ; je konec © dku

; ------ test, zda to je za‡ tek dal¨¡ho slova

         call      far ptr TestWrd          ; test, zda je za‡ tek slova
         jnc       EditCLf7                 ; nalezen za‡ tek dal¨¡ho slova

; ------ posun na p©edchoz¡ znak

         mov       ah,al                    ; AH <- p©ede¨l˜ znak
         dec       si                       ; sn¡‘en¡ ukazatele dat
         jmp       short EditCLf6           ; test dal¨¡ pozice

; ------ nastaven¡ na druh˜ znak a nastaven¡ kurzoru

EditCLf7:inc       si                       ; n vrat na druh˜ znak
EditCLf8:jmp       EditCRg7                 ; nastaven¡ kurzoru

EditCLft ENDP

; -----------------------------------------------------------------------------
;        slovo vpravo
; -----------------------------------------------------------------------------

EditCRgh PROC      NEAR

; ------ zah jen¡ ozna‡ov n¡ bloku SHIFT- (jen aktivn¡ okno)

         call      EdiBShft                 ; zah jen¡ ozna‡ov n¡ bloku SHIFT-

; ------ synchronizace oken

EditCRgY:call      EditSyn                  ; synchronizace oken

; ------ test, zda m  b˜t posun cel‚ obrazovky (zobrazen¡ textu)

         test      byte ptr es:[di+EdiParm1],bit0 ; je editace ?
         jz        EditCRg2                  ; je editace
         test      byte ptr es:[di+EdiParm1],bit1+bit2 ; je bin rn¡/HEX m¢d ?
         jnz       EditCRg1                  ; je bin rn¡ nebo HEX m¢d -> nic

; ------ p©¡prava po‡tu pozic k posunu obrazovky -> BP

         mov       al,es:[di+EdiSir]        ; ¨¡©ka okna
         mov       ah,0
         shr       ax,1                     ; polovina ¨¡©ky okna
         xchg      ax,bp                    ; BP <- po‡et pozic k posunu

; ------ horizont ln¡ posun obrazovky

         call      EditRlLf                 ; posun obrazovky vlevo
         call      EditKrRg                 ; posun kurzoru vpravo
EditCRg1:ret

; ------ p©i editaci HEX pole v HEX m¢du se jen posune na dal¨¡ bajt vpravo

EditCRg2:test      byte ptr es:[di+EdiParm1],bit1 ; je HEX m¢d ?
         jz        EditCRg3                 ; nen¡ HEX m¢d
         test      byte ptr es:[di+EdiParm2],bit2 ; je ASCII ‡ st HEX pole ?
         jnz       EditCRg3                 ; je ASCII ‡ st HEX pole
         or        byte ptr es:[di+EdiParm2],bit1 ; podhozen¡, ‘e je 2. znak HEX
         jmp       EditRghX                 ; posun kurzoru vpravo

; ------ p©¡prava ukazatel– pro operaci -> BX:SI

EditCRg3:mov       bx,es:[di+EdiBBKur]      ; blok s kurzorem
         mov       si,es:[di+EdiOfKur]      ; offset kurzoru

; ------ p©esko‡en¡ znaku CR, je-li kurzor na konci © dku

         mov       al," "                   ; p©ede¨l˜ znak, je-li za koncem © dku
         call      EditCmKL                 ; je na konci © dku ?
         ja        EditCRg5                 ; je za koncem © dku
         jb        EditCRg4                 ; nen¡ konec © dku
         call      EditNGet                 ; poskytnut¡ bloku
         je        EditCRg7                 ; chyba nebo konec
         cmp       byte ptr es:[si],CR      ; je konec © dku CR/LF ?
         jne       EditCRg4                 ; nen¡ konec © dku CR/LF
         inc       si                       ; p©esko‡en¡ znaku CR

; ------ na‡ten¡ prvn¡ho znaku na pozici kurzoru -> AL

EditCRg4:call      EditNGet                 ; poskytnut¡ bloku
         je        EditCRg7                 ; chyba nebo konec
         mov       al,es:[si]
         inc       si                       ; nastaven¡ na dal¨¡ znak

; ------ poskytnut¡ bloku s normalizac¡ offsetu -> ES/BX/SI/CX

EditCRg5:call      EditNGet                 ; poskytnut¡ bloku
         je        EditCRg7                 ; chyba nebo konec souboru

; ------ na‡ten¡ dal¨¡ho znaku -> AH

EditCRg6:cmp       si,cx                    ; je platn  adresa ?
         jae       EditCRg5                 ; normalizace adresy
         mov       ah,es:[si]               ; na‡ten¡ dal¨¡ho znaku

; ------ test, zda to je konec © dku LF

         cmp       ah,LF                    ; je ukazatel na LF ?
         je        EditCRg7                 ; je konec © dku

; ------ test, zda to je za‡ tek dal¨¡ho slova

         call      far ptr TestWrd          ; test, zda je za‡ tek slova
         jnc       EditCRg7                 ; nalezen za‡ tek dal¨¡ho slova

; ------ posun na dal¨¡ znak

         mov       al,ah                    ; AL <- p©ede¨l˜ znak
         inc       si                       ; zv˜¨en¡ ukazatele dat
         jmp       short EditCRg6           ; test dal¨¡ pozice

; ------ obnoven¡ adresy okna
; Sem se sk ‡e i z EditCLft !

EditCRg7:call      EditGt0D                 ; obnoven¡ adresy okna
         jc        EditCRg9                 ; byla chyba

; ------ korekce ukazatele pro CR/LF v textov‚m m¢du

         cmp       ax,CR + LF*HI            ; je p©elom CR/LF ?
         jne       EditCRg8                 ; nen¡ p©elom CR/LF
         test      byte ptr es:[di+EdiParm1],bit1+bit2 ; je textov˜ m¢d ?
         jnz       EditCRg8                 ; nen¡ textov˜ m¢d
         dec       si                       ; n vrat ukazatele p©ed p©elom

; ------ v˜po‡et nov‚ pozice a © dku (BX:SI -> CX:AX/BP:SI)
; sem se sk ‡e z EditTab !
EditCRg8:push      di
         call      EdiBORad                 ; p©epo‡et na pozici a © dek
         mov       si,di                    ; SI <- pozice LOW
         pop       di
         jc        EditCRg9                 ; chyba operace

; ------ nastaven¡ © dku kurzoru

         call      EditSetK                 ; nastaven¡ © dku s kurzorem

; ------ nastaven¡ pozice kurzoru

         xchg      ax,si                    ; AX <- pozice LOW
         mov       cx,bp                    ; CX <- pozice HIGH
         call      EditStKP                 ; nastaven¡ pozice kurzoru

EditCRg9:ret

EditCRgh ENDP

; -----------------------------------------------------------------------------
;        Ctrl-PageUp za‡ tek souboru
; -----------------------------------------------------------------------------

EditCPgU PROC      NEAR

; ------ zah jen¡ ozna‡ov n¡ bloku SHIFT- (jen aktivn¡ okno)

         call      EdiBShft                 ; zah jen¡ ozna‡ov n¡ bloku SHIFT-

; ------ synchronizace oken

EdiCPgUY:call      EditSyn                  ; synchronizace oken

; ------ pro HEX editor se nastav¡ prvn¡ znak HEX pole

EdiCPgUX:call      Edit1Hex                 ; je prvn¡ znak HEX pole

; ------ v‘dy nutn  aktualizace oken

         call      EditModW                 ; nutn  aktualizace oken v‘dy

; ------ nastaven¡ v¨ech ukazatel– na 0

         xor       ax,ax                    ; AX <- 0
         xor       cx,cx                    ; CX <- 0
         call      EditSetT                 ; nastaven¡ po‡ te‡n¡ho © dku
         call      EditStTP                 ; nastaven¡ po‡ te‡n¡ zobrazen‚ pozice
         call      EditSetK                 ; nastaven¡ © dku s kurzorem
; sem se sk ‡e z EditHome a EditEnd !
EdiCPgU4:call      EditStKP                 ; nastaven¡ pozice kurzoru na © dku
         ret

EditCPgU ENDP

; -----------------------------------------------------------------------------
;        Home za‡ tek © dku
; -----------------------------------------------------------------------------

EditHome PROC      NEAR

; ------ zah jen¡ ozna‡ov n¡ bloku SHIFT- (jen aktivn¡ okno)

         call      EdiBShft                 ; zah jen¡ ozna‡ov n¡ bloku SHIFT-

; ------ synchronizace oken

EditHomY:call      EditSyn                  ; synchronizace oken

; ------ nen¡-li editace, provede se skok na za‡ tek souboru

EditHomX:test      byte ptr es:[di+EdiParm1],bit0 ; je editace ?
         jnz       EdiCPgUX                 ; nen¡ editace -> za‡ tek souboru

; ------ pro HEX editor se nastav¡ prvn¡ znak HEX pole

         call      Edit1Hex                 ; je prvn¡ znak HEX pole

; ------ nov  po‡ te‡n¡ pozice na © dku
; sem se sk ‡e s EditRght !
EditHom4:xor       ax,ax                    ; AX <- 0
         xor       cx,cx                    ; CX <- 0
         jmp       short EdiCPgU4           ; nastaven¡ po‡ tku © dku

EditHome ENDP

; -----------------------------------------------------------------------------
;        konec © dku
; -----------------------------------------------------------------------------

EditEnd  PROC      NEAR

; ------ zah jen¡ ozna‡ov n¡ bloku SHIFT- (jen aktivn¡ okno)

         call      EdiBShft                 ; zah jen¡ ozna‡ov n¡ bloku SHIFT-

; ------ synchronizace oken

EditEndY:call      EditSyn                  ; synchronizace oken

; ------ nen¡-li editace, provede se skok na konec souboru

EditEndX:test      byte ptr es:[di+EdiParm1],bit0 ; je editace ?
         jnz       EdiCPgDX                 ; konec souboru

; ------ d‚lka © dku s kurzorem - konec © dku pro textov˜ m¢d

         call      EditGtLP                 ; poskytnut¡ d‚lky © dku -> CX:AX

; ------ pro bin rn¡/HEX m¢d omezen¡ na posledn¡ pozici © dku (CX=0 !)

         test      byte ptr es:[di+EdiParm1],bit1+bit2 ; je bin rn¡/HEX m¢d ?
         jz        EditEnd4                 ; nen¡ bin rn¡/HEX m¢d
         call      Edit1Hex                 ; je prvn¡ znak HEX pole
         cmp       ax,es:[di+EdiLSir]       ; je p©ete‡en¡ ¨¡©ky dat ?
         jb        EditEnd4                 ; nen¡ p©ete‡en¡ ¨¡©ky dat
         mov       ax,es:[di+EdiLSir]       ; ¨¡©ka dat na © dku
         dec       ax                       ; posledn¡ pozice na © dku

; ------ nastaven¡ nov‚ pozice kurzoru

EditEnd4:jmp       short EdiCPgU4           ; nastaven¡ pozice na © dku

EditEnd  ENDP

; -----------------------------------------------------------------------------
;        Ctrl-PageDown konec souboru
; -----------------------------------------------------------------------------

EditCPgD PROC      NEAR

; ------ zah jen¡ ozna‡ov n¡ bloku SHIFT- (jen aktivn¡ okno)

         call      EdiBShft                 ; zah jen¡ ozna‡ov n¡ bloku SHIFT-

; ------ synchronizace oken

EdiCPgDY:call      EditSyn                  ; synchronizace oken

; ------ p©epo‡et konce souboru na © dek a pozici -> CX:AX/BP:SI

EdiCPgDX:mov       ax,word ptr es:[EdiSize] ; velikost souboru LOW
         mov       cx,word ptr es:[EdiSize+2] ; velikost souboru HIGH
         call      EdiGetAd                 ; p©epo‡et na blok a offset
         push      di
         call      EdiBORad                 ; p©epo‡et na pozici a © dek
         mov       si,di                    ; SI <- pozice LOW
         pop       di
         jc        EditCPD9                 ; chyba operace

; ------ nastaven¡ © dku kurzoru

         call      EditSetK                 ; nastaven¡ © dku s kurzorem

; ------ korekce pro nastaven¡ po‡ tku okna -> BX

         mov       bl,es:[di+EdiVys]        ; BL <- v˜¨ka okna
         mov       bh,0
         dec       bx                       ; bez horn¡ho okraje
         dec       bx                       ; bez 1 © dku

; ------ nastaven¡ po‡ te‡n¡ho © dku okna

         sub       ax,bx                    ; © dek pro po‡ tek okna
         sbb       cx,0
         jnc       EdiCPgD2
         xor       ax,ax                    ; AX <- 0
         xor       cx,cx                    ; CX <- 0
EdiCPgD2:call      EditSetT                 ; nastaven¡ po‡ tku okna

; ------ nastaven¡ pozice kurzoru

         xchg      ax,si                    ; AX <- pozice LOW
         mov       cx,bp                    ; CX <- pozice HIGH
         call      EditStKP                 ; nastaven¡ pozice kurzoru

; ------ inicializace po‡ te‡n¡ zobrazen‚ pozice na 0

         call      Edit1Hex                 ; je prvn¡ znak HEX pole
         xor       ax,ax                    ; AX <- 0
         xor       cx,cx                    ; CX <- 0
         call      EditStTP                 ; nastaven¡ po‡ te‡n¡ pozice na 0

; ------ v‘dy nutn  aktualizace oken

EditCPD9:call      EditModW                 ; nutn  aktualizace oken v‘dy
         ret

EditCPgD ENDP

; -----------------------------------------------------------------------------
;        kurzor vpravo
; -----------------------------------------------------------------------------

EditRght PROC      NEAR

; ------ zah jen¡ ozna‡ov n¡ bloku SHIFT- (jen aktivn¡ okno)

         call      EdiBShft                 ; zah jen¡ ozna‡ov n¡ bloku SHIFT-

; ------ synchronizace oken

EditRghY:call      EditSyn                  ; synchronizace oken

; ------ nen¡-li editace, posun textu vlevo

EditRghX:test      byte ptr es:[di+EdiParm1],bit0 ; je zobrazen¡ ?
         jnz       EditRLfX                 ; je zobrazen¡ - posun textu vlevo

; ------ test, zda je HEX pole HEX m¢du

         test      byte ptr es:[di+EdiParm1],bit1 ; je HEX m¢d ?
         jz        EditRgh4                 ; nen¡ HEX m¢d
         test      byte ptr es:[di+EdiParm2],bit2 ; je ASCII ‡ st HEX pole ?
         jnz       EditRgh4                 ; je ASCII ‡ st HEX pole

; ------ posun kurzoru pro HEX m¢d (HEX pole)

         xor       byte ptr es:[di+EdiParm2],bit1 ; zmˆna ‡¡slice HEX bajtu
         or        byte ptr ds:[EditPar2],bit0 ; p©¡znak - zobraz kurzor
         test      byte ptr es:[di+EdiParm2],bit1 ; je zmˆna z 1. na 2. znak ?
         jnz       EditRgh9                 ; je zmˆna z 1. na 2. znak

; ------ posun kurzoru o pozici vpravo

EditRgh4:mov       bp,1                     ; po‡et pozic a © dk– k posunu
         call      EditKrRg                 ; posun kurzoru vpravo

; ------ pro textov˜ m¢d nen¡ omezen¡ pozice

         test      byte ptr es:[di+EdiParm1],bit1+bit2 ; je bin rn¡/HEX m¢d ?
         jz        EditRgh9                 ; je textov˜ m¢d - lze posunout v‘dy

; ------ v bin rn¡m/HEX m¢du test, zda je p©ete‡en¡ konce © dku

         call      EditGtKP                 ; poskytnut¡ pozice kurzoru
         cmp       ax,es:[di+EdiLSir]       ; je p©ete‡en¡ konce © dku ?
         jb        EditRgh9                 ; nen¡ p©ete‡en¡ konce © dku

; ------ posun na dal¨¡ © dek (BP=1)

         call      EditKrDn                 ; posun kurzoru dol–

; ------ posun kurzoru na za‡ tek dal¨¡ho © dku

         jmp       EditHom4                 ; nastaven¡ na za‡ tek © dku

EditRgh9:ret

EditRght ENDP

; -----------------------------------------------------------------------------
;        posun textu o pozici vlevo
; -----------------------------------------------------------------------------

EditRLft PROC      NEAR

;; ------ zah jen¡ ozna‡ov n¡ bloku SHIFT- (jen aktivn¡ okno)
;
;         call      EdiBShft                 ; zah jen¡ ozna‡ov n¡ bloku SHIFT-
;
;; ------ synchronizace oken
;
;         call      EditSyn                  ; synchronizace oken

; ------ pro bin rn¡ a HEX m¢d se neprovede

EditRLfX:test      byte ptr es:[di+EdiParm1],bit1+bit2 ; je bin rn¡/HEX m¢d ?
         jnz       EditRLf9                 ; posun se neprovede

; ------ posun textu o pozici vlevo

         mov       bp,1                     ; po‡et pozic k posunu
         call      EditRlLf                 ; posun textu vlevo

; ------ p©¡prava rezervy pro kurzor -> BX

         mov       bh,0
         mov       bl,es:[di+EdiSir]        ; ¨¡©ka okna
         shr       bx,1
         shr       bx,1
         shr       bx,1                     ; ¨¡©ka / 8

; ------ p©¡prava minim ln¡ pozice s kurzorem -> CX:AX

         call      EditGtTP                 ; poskytnut¡ po‡ te‡n¡ pozice
         add       ax,bx                    ; korekce pro kurzor
         adc       cx,0

; ------ omezen¡ minim ln¡ pozice s kurzorem

         call      EditCmKP                 ; porovn n¡ pozice s kurzorem
         jbe       EditRLf9                 ; pozice s kurzorem je OK
         call      EditStKP                 ; nastaven¡ pozice s kurzorem
EditRLf9:ret

EditRLft ENDP

; -----------------------------------------------------------------------------
;        kurzor vlevo
; -----------------------------------------------------------------------------

EditLeft PROC      NEAR

; ------ zah jen¡ ozna‡ov n¡ bloku SHIFT- (jen aktivn¡ okno)

         call      EdiBShft                 ; zah jen¡ ozna‡ov n¡ bloku SHIFT-

; ------ synchronizace oken

EditLftY:call      EditSyn                  ; synchronizace oken

; ------ nen¡-li editace, posun textu vpravo

EditLftX:test      byte ptr es:[di+EdiParm1],bit0 ; je zobrazen¡ ?
         jnz       EditRRgX                 ; je zobrazen¡ - posun textu vpravo

; ------ test, zda je HEX pole HEX m¢du

         test      byte ptr es:[di+EdiParm1],bit1 ; je HEX m¢d ?
         jz        EditLft4                 ; nen¡ HEX m¢d
         test      byte ptr es:[di+EdiParm2],bit2 ; je ASCII ‡ st HEX pole ?
         jnz       EditLft4                 ; je ASCII ‡ st HEX pole

; ------ posun kurzoru pro HEX m¢d (HEX pole)

         xor       byte ptr es:[di+EdiParm2],bit1 ; zmˆna ‡¡slice HEX bajtu
         or        byte ptr ds:[EditPar2],bit0 ; p©¡znak - zobraz kurzor
         test      byte ptr es:[di+EdiParm2],bit1 ; je zmˆna z 2. na 1. znak ?
         jz        EditLft9                 ; je zmˆna z 2. na 1. znak

; ------ test, zda je ji‘ prvn¡ pozice na © dku

EditLft4:mov       bp,1                     ; po‡et pozic a © dk– k posunu
         call      EditGtKP                 ; poskytnut¡ pozice kurzoru -> CX:AX
         or        ax,cx                    ; AX <- p©¡znak pozice 0
         jnz       EditLft8                 ; nen¡ je¨tˆ po‡ tek © dku

; ------ pro textov˜ m¢d ji‘ nelze posunout

         test      byte ptr es:[di+EdiParm1],bit1+bit2 ; je bin rn¡/HEX m¢d ?
         jz        EditLft9                 ; textov˜ m¢d - nelze posunout

; ------ pro ostatn¡ m¢dy test, zda je ji‘ prvn¡ © dek

         call      EditGetK                 ; poskytnut¡ © dku s kurzorem
         or        ax,cx                    ; AX <- p©¡znak © dku 0
         jz        EditLft9                 ; je ji‘ © dek 0

; ------ posun o © dek nahoru (BP=1) (EditUp by zmˆnilo p©¡znak HEX !)

         call      EditKrUp                 ; posun o © dek nahoru

; ------ posun kurzoru na konec p©ede¨l‚ho © dku + 1

         xor       cx,cx                    ; CX <- 0
         mov       ax,es:[di+EdiLSir]       ; ¨¡©ka © dku BIN a HEX
         call      EditStKP                 ; nastaven¡ pozice kurzoru

; ------ posun kurzoru o pozici vlevo (BP=1)

EditLft8:call      EditKrLf                 ; posun kurzoru vlevo
EditLft9:ret

EditLeft ENDP

; -----------------------------------------------------------------------------
;        posun textu o pozici vpravo
; -----------------------------------------------------------------------------

EditRRgh PROC      NEAR

;; ------ zah jen¡ ozna‡ov n¡ bloku SHIFT- (jen aktivn¡ okno)
;
;         call      EdiBShft                 ; zah jen¡ ozna‡ov n¡ bloku SHIFT-
;
;; ------ synchronizace oken
;
;         call      EditSyn                  ; synchronizace oken
;
; ------ pro bin rn¡ a HEX m¢d se neprovede

EditRRgX:test      byte ptr es:[di+EdiParm1],bit1+bit2 ; je bin rn¡/HEX m¢d ?
         jnz       EditRRg9                 ; posun se neprovede

; ------ posun textu o pozici vpravo

         mov       bp,1                     ; po‡et pozic k posunu
         call      EditRlRg                 ; posun textu vpravo

; ------ p©¡prava maxim ln¡ pozice s kurzorem -> CX:AX

         call      EditGtTP                 ; poskytnut¡ po‡ te‡n¡ pozice
         mov       bh,0
         mov       bl,es:[di+EdiSir]        ; ¨¡©ka okna
         add       ax,bx                    ; posledn¡ pozice okna
         adc       cx,0
         shr       bx,1
         shr       bx,1
         shr       bx,1                     ; ¨¡©ka / 8
         inc       bx                       ; + 1 pozice pro kurzor
         sub       ax,bx                    ; ode‡ten¡ korekce pro kurzor
         sbb       cx,0

; ------ omezen¡ maxim ln¡ pozice s kurzorem

         call      EditCmKP                 ; porovn n¡ pozice s kurzorem
         jae       EditRRg9                 ; pozice s kurzorem je OK
         call      EditStKP                 ; nastaven¡ pozice s kurzorem
EditRRg9:ret

EditRRgh ENDP

; -----------------------------------------------------------------------------
;        kurzor nahoru
; -----------------------------------------------------------------------------

EditUp   PROC      NEAR

; ------ zah jen¡ ozna‡ov n¡ bloku se SHIFT- (jen aktivn¡ okno)

         call      EdiBShft                 ; zah jen¡ ozna‡ov n¡ bloku SHIFT-

; ------ synchronizace oken

EditUpY: call      EditSyn                  ; synchronizace oken

; ------ pro m¢d zobrazen¡ se posune text o © dek dol–

EditUpX: test      byte ptr es:[di+EdiParm1],bit0 ; je editace ?
         jnz       EditCtWX                 ; je zobrazen¡

; ------ posun kurzoru o © dek nahoru

         mov       bp,1                     ; po‡et © dk– k posunu
         call      EditKrUp                 ; posun kurzoru o © dek nahoru

; ------ pro HEX editor se nastav¡ prvn¡ znak HEX pole

         call      Edit1Hex                 ; je prvn¡ znak HEX pole
         ret

EditUp   ENDP

; -----------------------------------------------------------------------------
;        Ctrl-W posun obrazovky o © dek nahoru (text dol–) (okno DX/ES/DI)
; -----------------------------------------------------------------------------

EditCtrW PROC      NEAR

; ------ zah jen¡ ozna‡ov n¡ bloku SHIFT- (jen aktivn¡ okno)

         call      EdiBShft                 ; zah jen¡ ozna‡ov n¡ bloku SHIFT-

; ------ synchronizace oken

EditCtWY:call      EditSyn                  ; synchronizace oken

; ------ posun textu o © dek dol–

EditCtWX:mov       bp,1                     ; posun o 1 © dek
; sem se sk ‡e z EditPgUp !
EditCtW2:call      EditRlDn                 ; rolov n¡ textu o © dek dol–

; ------ p©¡prava maxim ln¡ho © dku s kurzorem -> CX:AX

         call      EditGetT                 ; poskytnut¡ po‡ te‡n¡ho © dku
         mov       bh,0
         mov       bl,es:[di+EdiVys]        ; v˜¨ka okna
         add       ax,bx                    ; posledn¡ © dek okna
         adc       cx,0
         shr       bx,1
         shr       bx,1
         shr       bx,1                     ; v˜¨ka / 8
         inc       bx
         inc       bx                       ; + 2 © dky pro kurzor
         sub       ax,bx                    ; ode‡ten¡ korekce pro kurzor
         sbb       cx,0

; ------ omezen¡ maxim ln¡ho © dku s kurzorem

         call      EditCmpK                 ; porovn n¡ © dku s kurzorem
         jae       EditCtW9                 ; © dek s kurzorem je OK
         call      EditSetK                 ; nastaven¡ © dku s kurzorem
EditCtW9:ret

EditCtrW ENDP

; -----------------------------------------------------------------------------
;        posun o str nku nahoru
; -----------------------------------------------------------------------------

EditPgUp PROC      NEAR

; ------ zah jen¡ ozna‡ov n¡ bloku SHIFT- (jen aktivn¡ okno)

         call      EdiBShft                 ; zah jen¡ ozna‡ov n¡ bloku SHIFT-

; ------ synchronizace oken

EditPgUY:call      EditSyn                  ; synchronizace oken

; ------ pro HEX editor se nastav¡ prvn¡ znak HEX pole

         call      Edit1Hex                 ; je prvn¡ znak HEX pole

; ------ stanoven¡ po‡tu © dk– k posunu -> BP

         mov       al,es:[di+EdiVys]        ; AL <- v˜¨ka okna
         mov       ah,0
         dec       ax                       ; bez horn¡ho okraje
         cmp       al,3                     ; je dostate‡n  v˜¨ka okna ?
         jbe       EditPgU2                 ; mal  v˜¨ka okna
         dec       ax                       ; 1 © dek pro p©ekryv
EditPgU2:xchg      ax,bp                    ; BP <- po‡et © dk– k posunu

; ------ omezen¡ podle skute‡n‚ho zbyl‚ho po‡tu © dk–

         call      EditGetT                 ; poskytnut¡ po‡ te‡n¡ho © dku
         or        cx,cx                    ; je velk‚ ‡¡slo ?
         jnz       EditPgU4                 ; je velk‚ ‡¡slo
         or        ax,ax                    ; je ji‘ po‡ tek souboru ?
         jz        EditPgU4                 ; neomez¡ se (posune se jen kurzor)
         cmp       ax,bp                    ; je men¨¡ po‡et © dk– ?
         jae       EditPgU4                 ; je to OK
         xchg      ax,bp                    ; BP <- nov˜ po‡et © dk– k posunu

; ------ posun okna o BP © dk– (kurzor i po‡ tek okna)

EditPgU4:call      EditKrUp                 ; posun kurzoru nahoru o BP © dk–
         jmp       short EditCtW2           ; posun podkladu

EditPgUp ENDP

; -----------------------------------------------------------------------------
;        kurzor dol–
; -----------------------------------------------------------------------------

EditDown PROC      NEAR

; ------ zah jen¡ ozna‡ov n¡ bloku SHIFT- (jen aktivn¡ okno)

         call      EdiBShft                 ; zah jen¡ ozna‡ov n¡ bloku SHIFT-

; ------ synchronizace oken

EditDwnY:call      EditSyn                  ; synchronizace oken

; ------ pro m¢d zobrazen¡ se posune text o © dek nahoru

EditDwnX:test      byte ptr es:[di+EdiParm1],bit0 ; je editace ?
         jnz       EditCtZX                 ; je zobrazen¡

; ------ posun kurzoru o © dek dol–

         mov       bp,1                     ; po‡et © dk– k posunu
         call      EditKrDn                 ; posun kurzoru o © dek dol–

; ------ pro HEX editor se nastav¡ prvn¡ znak HEX pole

         call      Edit1Hex                 ; je prvn¡ znak HEX pole
         ret

EditDown ENDP

; -----------------------------------------------------------------------------
;        Ctrl-Z posun obrazovky o © dek dol– (text nahoru) (okno DX/ES/DI)
; -----------------------------------------------------------------------------

EditCtrZ PROC      NEAR

; ------ zah jen¡ ozna‡ov n¡ bloku SHIFT- (jen aktivn¡ okno)

         call      EdiBShft                 ; zah jen¡ ozna‡ov n¡ bloku SHIFT-

; ------ synchronizace oken

EditCtZY:call      EditSyn                  ; synchronizace oken

; ------ posun textu o © dek nahoru

EditCtZX:mov       bp,1                     ; posun o 1 © dek
; sem se sk ‡e z EditPgDn !
EditCtZ2:call      EditRlUp                 ; posun textu o © dek nahoru

; ------ p©¡prava rezervy pro kurzor -> BX

         mov       bh,0
         mov       bl,es:[di+EdiVys]        ; v˜¨ka okna
         shr       bx,1
         shr       bx,1
         shr       bx,1                     ; v˜¨ka / 8

; ------ p©¡prava minim ln¡ho © dku s kurzorem -> CX:AX

         call      EditGetT                 ; poskytnut¡ po‡ te‡n¡ho © dku
         add       ax,bx                    ; p©i‡ten¡ korekce pro kurzor
         adc       cx,0

; ------ omezen¡ minim ln¡ho © dku s kurzorem

         call      EditCmpK                 ; porovn n¡ © dku s kurzorem
         jbe       EditCtZ9                 ; © dek s kurzorem je OK
         call      EditSetK                 ; nastaven¡ © dku s kurzorem
EditCtZ9:ret

EditCtrZ ENDP

; -----------------------------------------------------------------------------
;        posun o str nku dol–
; -----------------------------------------------------------------------------

EditPgDn PROC      NEAR

; ------ zah jen¡ ozna‡ov n¡ bloku SHIFT- (jen aktivn¡ okno)

         call      EdiBShft                 ; zah jen¡ ozna‡ov n¡ bloku SHIFT-

; ------ synchronizace oken

EditPgDY:call      EditSyn                  ; synchronizace oken

; ------ stanoven¡ po‡tu © dk– k posunu -> BP

         mov       al,es:[di+EdiVys]        ; AL <- v˜¨ka okna
         mov       ah,0
         dec       ax                       ; bez horn¡ho okraje
         cmp       al,3                     ; je dostate‡n  v˜¨ka okna ?
         jbe       EditPgD2                 ; mal  v˜¨ka okna
         dec       ax                       ; 1 © dek pro p©ekryv
EditPgD2:xchg      ax,bp                    ; BP <- po‡et © dk– k posunu

; ------ pro HEX editor se nastav¡ prvn¡ znak HEX pole

         call      Edit1Hex                 ; je prvn¡ znak HEX pole

; ------ posun okna o BP © dk– (kurzor i po‡ tek okna)

         call      EditKrDn                 ; posun kurzoru dol– o BP © dk–
         jmp       short EditCtZ2           ; posun podkladu

EditPgDn ENDP

CodeEdi  ENDS

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
;        Editace soubor–
; -----------------------------------------------------------------------------

SEMnVert label     byte                    ;* menu editace soubor–

         db        2                        ; typ menu - vertik ln¡ podmenu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka volby
         dw        8                        ; po‡et platn˜ch polo‘ek menu
         dw        9                        ; celkov˜ po‡et polo‘ek menu

         dw        SEMnVPol                 ; adresa defini‡n¡ tabulky polo‘ek
         dw        SEMnVHlp                 ; adresa tabulky text– n povˆdy
         dw        Hlp@MenuEditaceSouboru   ; ‡¡slo str nky velk‚ n povˆdy
         dw        SEMnVBlk                 ; adresa blokovac¡ tabulky
         dw        SEMnVSwc                 ; adresa tabulky p©ep¡na‡–
         dw        SEMnVTit                 ; adresa titulu okna
         dw        SEMnVExe                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        36                       ; po‡ te‡n¡ pozice
         db        3                        ; po‡ te‡n¡ © dek
         db        20                       ; ¨¡©ka
         db        11                       ; v˜¨ka

SEMnVPol db        1+bit7,11,'Automaticky'
         db        1+bit7,11,'Textov˜ m¢d'
         db        1+bit7,11,'Bin rn¡ m¢d'
         db        1+bit7,14,'Hexadecim. m¢d'
;         db        bit6+bit7,0
         db        1+bit7,11,'Datum a ‡as'
;         db        1,16,'Po‡et z loh   '
;SEMnVPl1 db        ' 0'
         db        bit6+bit7,0
         db        1,6,'Kurzor'
         db        1,8,'Ozna‡en‚'
         db        1,6,'Zadan‚'

SEMnVTit db        7,'editace'

SEMnVBlk db        0,0,0,0,0,0,0,0
SEMnVSwc db        1,0,0,0,1

HelpS    SEGMENT   BYTE PUBLIC
SEMnVHlp db        62,'Bude automaticky detekov n textov˜ nebo bin rn¡ form t souboru'
         db        42,'Soubor bude otev©en v bˆ‘n‚m textov‚m m¢du'
         db        45,'Soubor bude otev©en v bin rn¡m m¢du zobrazen¡'
         db        63,'Soubor bude otev©en v hexadecim ln¡m m¢du zobrazen¡ (Ctrl-F4)'
         db        52,'Bude zachov no p–vodn¡ datum, ‡as a atributy souboru'
;         db        60,'Maxim ln¡ po‡et z loh BAK souboru (0=soubor se nez lohuje)'
         db        40,'Bude editov n soubor pod kurzorem (F4)'
         db        32,'Budou editov ny ozna‡en‚ soubory'
         db        61,'Bude editov n soubor(y) podle bli‘¨¡ specifikace (Shift-F4)'

;SEMnVHl1 db        76,'Zadejte maxim ln¡ po‡et z loh souboru 0 a‘ 99 (0=soubor se nez lohuje)'
HelpS    ENDS

SEMnVExe label     dword                    ; obsluhy voleb
         dd        AWMMnSEA                 ; automaticky
         dd        AWMMnSET                 ; textovˆ
         dd        AWMMnSEB                 ; bin rnˆ
         dd        AWMMnSEH                 ; hexadecim lnˆ
         dd        AWMMnSED                 ; Datum a ‡as
;         dd        AWMMnSEP                 ; po‡et z loh BAK
         dd        EditM                    ; kurzor
         dd        EditM                    ; ozna‡en‚
         dd        EditM                    ; zadan‚

; -----------------------------------------------------------------------------
;        Zobrazen¡ soubor–
; -----------------------------------------------------------------------------

SZMnVert label     byte                    ;* menu editace soubor–

         db        2                        ; typ menu - vertik ln¡ podmenu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka volby
         dw        7                        ; po‡et platn˜ch polo‘ek menu
         dw        8                        ; celkov˜ po‡et polo‘ek menu

         dw        SZMnVPol                 ; adresa defini‡n¡ tabulky polo‘ek
         dw        SZMnVHlp                 ; adresa tabulky text– n povˆdy
         dw        Hlp@MenuZobrazeniSouboru ; ‡¡slo str nky velk‚ n povˆdy
         dw        SZMnVBlk                 ; adresa blokovac¡ tabulky
         dw        SZMnVSwc                 ; adresa tabulky p©ep¡na‡–
         dw        SZMnVTit                 ; adresa titulu okna
         dw        SZMnVExe                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        36                       ; po‡ te‡n¡ pozice
         db        3                        ; po‡ te‡n¡ © dek
         db        20                       ; ¨¡©ka
         db        10                       ; v˜¨ka

SZMnVPol db        1+bit7,11,'Automaticky'
         db        1+bit7,11,'Textov˜ m¢d'
         db        1+bit7,11,'Bin rn¡ m¢d'
         db        1+bit7,14,'Hexadecim. m¢d'
         db        bit6+bit7,0
         db        1,6,'Kurzor'
         db        1,8,'Ozna‡en‚'
         db        1,6,'Zadan‚'

SZMnVTit db        9,'zobrazen¡'

SZMnVBlk db        0,0,0,0,0,0,0
SZMnVSwc db        1,0,0,0

HelpS    SEGMENT   BYTE PUBLIC
SZMnVHlp db        62,'Bude automaticky detekov n textov˜ nebo bin rn¡ form t souboru'
         db        42,'Soubor bude otev©en v bˆ‘n‚m textov‚m m¢du'
         db        45,'Soubor bude otev©en v bin rn¡m m¢du zobrazen¡'
         db        51,'Soubor bude otev©en v hexadecim ln¡m m¢du zobrazen¡'
         db        40,'Bude zobrazen soubor pod kurzorem (F3)'
         db        32,'Budou zobrazeny ozna‡en‚ soubory'
         db        61,'Bude zobrazen soubor(y) podle bli‘¨¡ specifikace (Shift-F3)'
HelpS    ENDS

SZMnVExe label     dword                    ; obsluhy voleb
         dd        AWMMnSEA                 ; automaticky
         dd        AWMMnSET                 ; textovˆ
         dd        AWMMnSEB                 ; bin rnˆ
         dd        AWMMnSEH                 ; hexadecim lnˆ
         dd        EditMZ                   ; kurzor
         dd        EditMZ                   ; ozna‡en‚
         dd        EditMZ                   ; zadan‚

; -----------------------------------------------------------------------------
;        Definice © dkov‚ho menu - volba soubor– k editaci
; -----------------------------------------------------------------------------

SEZMnLin label     byte

         db        3                        ; typ menu - © dkov‚ podmenu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        3                        ; po‡et platn˜ch polo‘ek menu
         dw        5                        ; celkov˜ po‡et polo‘ek menu

         dw        SEZMLPol                 ; za‡ tek definice polo‘ek menu
         dw        SEZMLHlp                 ; adresa tabulky text– n povˆdy
         dw        Hlp@VyberSouboru         ; ‡¡slo str nky velk‚ n povˆdy
         dw        SEZMLBlk                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        SEZMLTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        23                       ; po‡ te‡n¡ pozice okna
         db        7                        ; po‡ te‡n¡ © dek okna
         db        36                       ; ¨¡©ka okna
         db        8                        ; v˜¨ka okna

         dw        255                      ; maxim ln¡ d‚lka © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        1                        ; celkov˜ po‡et © dk–
         dw        1                        ; po‡et zobrazen˜ch © dk–

         db        bit2                     ; maska zad van˜ch znak–
         db        0,'      '               ; zak zan‚ znaky

         db        HistFile                 ; identifik tor historie
         db        0                        ; po‡et p©edvoleb

         dw        0                        ; d‚lka p©edvolby
         dd        0                        ; p©edvolba

; ------ polo‘ky voleb

SEZMLPol db        bit6,20,'Soubor(y) k editaci:'
         db        0,0
         db        bit6+bit7,0
         db        1,6,'Edituj'
         db        1,6,'N vrat'

SEZMLBlk db        0,0,0                    ; blokovac¡ tabulka

SEZMLTit db        6,'zadan‚'

; ------ n povˆda

HelpS    SEGMENT   BYTE PUBLIC
SEZMLHlp db        47,'Zadejte specifikaci souboru (soubor–) k editaci'
         db        57,'Editace (a p©¡padn‚ vytvo©en¡) zadan‚ho souboru (soubor–)'
         db        3,1
         dw        MenuHlP1
HelpS    ENDS

; -----------------------------------------------------------------------------
;        Definice © dkov‚ho menu - volba soubor– k editaci
; -----------------------------------------------------------------------------

NEZMnLin label     byte

         db        3                        ; typ menu - © dkov‚ podmenu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        3                        ; po‡et platn˜ch polo‘ek menu
         dw        5                        ; celkov˜ po‡et polo‘ek menu

         dw        NEZMLPol                 ; za‡ tek definice polo‘ek menu
         dw        NEZMLHlp                 ; adresa tabulky text– n povˆdy
         dw        Hlp@Editor               ; ‡¡slo str nky velk‚ n povˆdy
         dw        NEZMLBlk                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        NEZMLTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        23                       ; po‡ te‡n¡ pozice okna
         db        7                        ; po‡ te‡n¡ © dek okna
         db        42                       ; ¨¡©ka okna
         db        8                        ; v˜¨ka okna

         dw        255                      ; maxim ln¡ d‚lka © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        1                        ; celkov˜ po‡et © dk–
         dw        1                        ; po‡et zobrazen˜ch © dk–

         db        bit3                     ; maska zad van˜ch znak–
         db        2,'*?    '               ; zak zan‚ znaky

         db        HistFile                 ; identifik tor historie
         db        0                        ; po‡et p©edvoleb

         dw        0                        ; d‚lka p©edvolby
         dd        0                        ; p©edvolba

; ------ polo‘ky voleb

NEZMLPol db        bit6,20,'Otev©¡t nov˜ soubor:'
         db        0,0
         db        bit6+bit7,0
         db        1,6,'Otev©i'
         db        1,6,'N vrat'

NEZMLBlk db        0,0,0                    ; blokovac¡ tabulka

NEZMLTit db        16,'otev©en¡ souboru'

; ------ n povˆda

HelpS    SEGMENT   BYTE PUBLIC
NEZMLHlp db        38,'Zadejte specifikaci souboru k otev©en¡'
         db        48,'Otev©en¡ (a p©¡padn‚ vytvo©en¡) zadan‚ho souboru'
         db        3,1
         dw        MenuHlP1
HelpS    ENDS

; -----------------------------------------------------------------------------
;        menu - soubor modifikov n (menu vyu‘¡v  t‚‘ editor z pisn¡ku !)
; -----------------------------------------------------------------------------

EUSMnLin label     byte
         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        3                        ; po‡et platn˜ch polo‘ek menu
         dw        8                        ; celkov˜ po‡et polo‘ek menu

         dw        EUSMnPol                 ; za‡ tek definice polo‘ek menu
         dw        EUSMnHlp                 ; adresa tabulky text– n povˆdy
         dw        Hlp@HlavniMenu           ; ‡¡slo str nky velk‚ n povˆdy
         dw        EUSMnBlk                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        EUSMnTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        20                       ; po‡ te‡n¡ pozice okna
         db        0                        ; po‡ te‡n¡ © dek okna
         db        48                       ; ¨¡©ka okna
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

; ------ polo‘ky voleb

EUSMnPol db        bit6,0
         db        bit6,29,'Soubor ',0,1
         dw        EUSMnSou
         db        0,' byl modifikov n.'
         db        bit6,31,'Chcete ulo‘it proveden‚ zmˆny ?'
         db        bit6,0
         db        bit6+bit7,0
         db        1,6,'Ulo‘it'
         db        1,8,'Neulo‘it'
         db        1,8,'P©eru¨it'

EUSMnSou db        13,13 dup(" ")           ; jm‚no souboru

EUSMnBlk db        0,0,0                    ; blokovac¡ tabulka

HelpS    SEGMENT   BYTE PUBLIC
EUSMnHlp db        23,'Ulo‘en¡ souboru na disk'
         db        49,'Soubor se neulo‘¡, p–vodn¡ obsah z–stane nezmˆnˆn'
         db        44,'P©eru¨en¡ operace a n vrat k editaci souboru'
HelpS    ENDS

EUSMnTit db        18,'soubor modifikov n'

; -----------------------------------------------------------------------------
;        chybov‚ hl ¨en¡ - chyba ulo‘en¡ souboru
; -----------------------------------------------------------------------------

; Hl ¨en¡ se pou‘¡v  i v modulu DBF1 !!!!

EURMnLin label     byte
         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        1                        ; po‡et platn˜ch polo‘ek menu
         dw        4                        ; celkov˜ po‡et polo‘ek menu

         dw        EURMnLnP                 ; za‡ tek definice polo‘ek menu
         dw        ChbLnMeH                 ; adresa tabulky text– n povˆdy
         dw        Hlp@HlavniMenu           ; ‡¡slo str nky velk‚ n povˆdy
         dw        EURMnLnB                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        EURMnLnT                 ; adresa titulu okna
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

EURMnLnP db        bit6,6,0,'CHYBA'
         db        bit6,35,'Chyba z pisu, soubor nelze ulo‘it !'
         db        bit6+bit7,0
         db        1,6,'N vrat'

EURMnLnT db        12,'chyba z pisu'

EURMnLnB db        0                        ; blokovac¡ tabulka

; -----------------------------------------------------------------------------
;        chybov‚ hl ¨en¡ - chyba ulo‘en¡ souboru, disk pln˜
; -----------------------------------------------------------------------------

EUPMnLin label     byte
         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        1                        ; po‡et platn˜ch polo‘ek menu
         dw        5                        ; celkov˜ po‡et polo‘ek menu

         dw        EUPMnLnP                 ; za‡ tek definice polo‘ek menu
         dw        ChbLnMeH                 ; adresa tabulky text– n povˆdy
         dw        Hlp@HlavniMenu           ; ‡¡slo str nky velk‚ n povˆdy
         dw        EURMnLnB                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        EURMnLnT                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        22                       ; po‡ te‡n¡ pozice okna
         db        7                        ; po‡ te‡n¡ © dek okna
         db        41                       ; ¨¡©ka okna
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

EUPMnLnP db        bit6,6,0,'CHYBA'
         db        bit6,29,'Na disku ',0
EUPMnLP1 db        'A:',0,' nen¡ dost m¡sta'
         db        bit6,19,'k ulo‘en¡ souboru !'
         db        bit6+bit7,0
         db        1,6,'N vrat'

; -----------------------------------------------------------------------------
;        chybov‚ hl ¨en¡ - soubor je otev©en v jin‚m oknˆ
; -----------------------------------------------------------------------------

EUJMnLin label     byte
         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        1                        ; po‡et platn˜ch polo‘ek menu
         dw        5                        ; celkov˜ po‡et polo‘ek menu

         dw        EUJMnLnP                 ; za‡ tek definice polo‘ek menu
         dw        ChbLnMeH                 ; adresa tabulky text– n povˆdy
         dw        Hlp@Editor               ; ‡¡slo str nky velk‚ n povˆdy
         dw        EUJMnLnB                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        EUJMnLnT                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        22                       ; po‡ te‡n¡ pozice okna
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

; ------ polo‘ky voleb

EUJMnLnP db        bit6,6,0,'CHYBA'
         db        bit6,47,'Zadan˜ soubor je ji‘ otev©en pod ‡¡slem ',0,1
         dw        EUJMnLP2
         db        0,' !'
         db        bit6,7,0,3
EUJMnLP1 db        0                        ; d‚lka jm‚na souboru
         dd        EdiSoub                  ; adresa jm‚na souboru
         db        bit6+bit7,0
         db        1,6,'N vrat'

EUJMnLP2 db        0,8 dup(" ")             ; ‡¡slo okna

EUJMnLnT db        14,'soubor otev©en'

EUJMnLnB db        0                        ; blokovac¡ tabulka

; -----------------------------------------------------------------------------
;        menu - volba souboru k z pisu
; -----------------------------------------------------------------------------

SEZZMLin label     byte

         db        3                        ; typ menu - © dkov‚ podmenu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        3                        ; po‡et platn˜ch polo‘ek menu
         dw        5                        ; celkov˜ po‡et polo‘ek menu

         dw        SEZZLPol                 ; za‡ tek definice polo‘ek menu
         dw        SEZZLHlp                 ; adresa tabulky text– n povˆdy
         dw        Hlp@PodmenuEditoruSoubor ; ‡¡slo str nky velk‚ n povˆdy
         dw        SEZZLBlk                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        SEZZLTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        23                       ; po‡ te‡n¡ pozice okna
         db        7                        ; po‡ te‡n¡ © dek okna
         db        45                       ; ¨¡©ka okna
         db        8                        ; v˜¨ka okna

         dw        255                      ; maxim ln¡ d‚lka © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        1                        ; celkov˜ po‡et © dk–
         dw        1                        ; po‡et zobrazen˜ch © dk–

         db        bit2                     ; maska zad van˜ch znak–
         db        0,'      '               ; zak zan‚ znaky

         db        HistFile                 ; identifik tor historie
         db        1                        ; po‡et p©edvoleb

SEZZLPre dw        0                        ; d‚lka p©edvolby
         dd        EdiSoub                  ; p©edvolba

; ------ polo‘ky voleb

SEZZLPol db        bit6,29,'Ulo‘it editovan˜ soubor jako:'
         db        0,0
         db        bit6+bit7,0
         db        1,5,'Z pis'
         db        1,6,'N vrat'

SEZZLBlk db        0,0,0                    ; blokovac¡ tabulka

SEZZLTit db        13,'z pis souboru'

; ------ n povˆda

HelpS    SEGMENT   BYTE PUBLIC
SEZZLHlp db        44,'Zadejte jm‚no, pod kter˜m bude soubor ulo‘en'
         db        40,'Z pis souboru na disk pod zadan˜m jm‚nem'
         db        3,1
         dw        MenuHlP1
HelpS    ENDS

; -----------------------------------------------------------------------------
;        menu - volba souboru k z pisu bloku
; -----------------------------------------------------------------------------

SEZBMLin label     byte

         db        3                        ; typ menu - © dkov‚ podmenu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        3                        ; po‡et platn˜ch polo‘ek menu
         dw        5                        ; celkov˜ po‡et polo‘ek menu

         dw        SEZBLPol                 ; za‡ tek definice polo‘ek menu
         dw        SEZBLHlp                 ; adresa tabulky text– n povˆdy
         dw        Hlp@PodmenuEditoruBlok   ; ‡¡slo str nky velk‚ n povˆdy
         dw        SEZBLBlk                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        SEZBLTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        23                       ; po‡ te‡n¡ pozice okna
         db        7                        ; po‡ te‡n¡ © dek okna
         db        45                       ; ¨¡©ka okna
         db        8                        ; v˜¨ka okna

         dw        255                      ; maxim ln¡ d‚lka © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        1                        ; celkov˜ po‡et © dk–
         dw        1                        ; po‡et zobrazen˜ch © dk–

         db        bit2                     ; maska zad van˜ch znak–
         db        0,'      '               ; zak zan‚ znaky

         db        HistFile                 ; identifik tor historie
         db        0                        ; po‡et p©edvoleb

; ------ polo‘ky voleb

SEZBLPol db        bit6,26,'Ulo‘it ozna‡en˜ blok jako:'
         db        0,0
         db        bit6+bit7,0
         db        1,5,'Z pis'
         db        1,6,'N vrat'

SEZBLBlk db        0,0,0                    ; blokovac¡ tabulka

SEZBLTit db        11,'z pis bloku'

; ------ n povˆda

HelpS    SEGMENT   BYTE PUBLIC
SEZBLHlp db        51,'Zadejte jm‚no, pod kter˜m bude ozna‡en˜ blok ulo‘en'
         db        38,'Z pis bloku na disk pod zadan˜m jm‚nem'
         db        3,1
         dw        MenuHlP1
HelpS    ENDS

; -----------------------------------------------------------------------------
;        menu - volba souboru k na‡ten¡ bloku
; -----------------------------------------------------------------------------

SENBMLin label     byte

         db        3                        ; typ menu - © dkov‚ podmenu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        3                        ; po‡et platn˜ch polo‘ek menu
         dw        5                        ; celkov˜ po‡et polo‘ek menu

         dw        SENBLPol                 ; za‡ tek definice polo‘ek menu
         dw        SENBLHlp                 ; adresa tabulky text– n povˆdy
         dw        Hlp@PodmenuEditoruBlok   ; ‡¡slo str nky velk‚ n povˆdy
         dw        SENBLBlk                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        SENBLTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        23                       ; po‡ te‡n¡ pozice okna
         db        7                        ; po‡ te‡n¡ © dek okna
         db        45                       ; ¨¡©ka okna
         db        8                        ; v˜¨ka okna

         dw        255                      ; maxim ln¡ d‚lka © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        1                        ; celkov˜ po‡et © dk–
         dw        1                        ; po‡et zobrazen˜ch © dk–

         db        bit2                     ; maska zad van˜ch znak–
         db        0,'      '               ; zak zan‚ znaky

         db        HistFile                 ; identifik tor historie
         db        0                        ; po‡et p©edvoleb

; ------ polo‘ky voleb

SENBLPol db        bit6,23,'Na‡¡st blok ze souboru:'
         db        0,0
         db        bit6+bit7,0
         db        1,6,'Na‡¡st'
         db        1,8,'P©eru¨it'

SENBLBlk db        0,0,0                    ; blokovac¡ tabulka

SENBLTit db        13,'na‡ten¡ bloku'

; ------ n povˆda

HelpS    SEGMENT   BYTE PUBLIC
SENBLHlp db        50,'Zadejte jm‚no souboru, kter˜ bude na‡ten jako blok'
         db        34,'Na‡ten¡ zadan‚ho souboru jako blok'
         db        3,1
         dw        MenuHlP2
HelpS    ENDS

; -----------------------------------------------------------------------------
;    chybov‚ hl ¨en¡ - soubor ke ‡ten¡ nenalezen (pou‘¡v  i kop¡rov n¡ disket)
; -----------------------------------------------------------------------------

ENFMnLin label     byte
         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        1                        ; po‡et platn˜ch polo‘ek menu
         dw        5                        ; celkov˜ po‡et polo‘ek menu

         dw        ENFMnLnP                 ; za‡ tek definice polo‘ek menu
         dw        ChbLnMeH                 ; adresa tabulky text– n povˆdy
         dw        Hlp@HlavniMenu           ; ‡¡slo str nky velk‚ n povˆdy
         dw        ENFMnLnB                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        ENFMnLnT                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        22                       ; po‡ te‡n¡ pozice okna
         db        7                        ; po‡ te‡n¡ © dek okna
         db        42                       ; ¨¡©ka okna
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

ENFMnLnP db        bit6,6,0,'CHYBA'
         db        bit6,25,'Zadan˜ soubor nenalezen !'
         db        bit6,7,0,3
ENFMnLP1 db        0                        ; d‚lka jm‚na souboru
         dd        0                        ; adresa jm‚na souboru
         db        bit6+bit7,0
         db        1,6,'N vrat'

ENFMnLnT db        16,'soubor nenalezen'

ENFMnLnB db        0                        ; blokovac¡ tabulka

; -----------------------------------------------------------------------------
;        chybov‚ hl ¨en¡ - ukl dan˜ soubor ji‘ existuje
; -----------------------------------------------------------------------------

EUEMnLin label     byte
         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        4                        ; po‡et platn˜ch polo‘ek menu
         dw        8                        ; celkov˜ po‡et polo‘ek menu

         dw        EUEMnLnP                 ; za‡ tek definice polo‘ek menu
         dw        EUEMnLnH                 ; adresa tabulky text– n povˆdy
         dw        Hlp@PodmenuEditoruSoubor ; ‡¡slo str nky velk‚ n povˆdy
         dw        EUEMnLnB                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        EUEMnLnT                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        22                       ; po‡ te‡n¡ pozice okna
         db        7                        ; po‡ te‡n¡ © dek okna
         db        55                       ; ¨¡©ka okna
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

EUEMnLnP db        bit6,9,0,'VAROVN‹'
         db        bit6,34,'Existuje ji‘ soubor zadan‚ho jm‚na'
         db        bit6,7,0,3
EUEMnLP2 db        0                        ; d‚lka jm‚na souboru
         dd        0                        ; adresa jm‚na souboru
         db        bit6+bit7,0
         db        1,7,'P©epsat'
         db        1,8,'Opakovat'
         db        1,7,'Slou‡it'
         db        1,6,'N vrat'

EUEMnLnB db        0,0,0,0                  ; blokovac¡ tabulka

EUEMnLnT db        15,'soubor existuje'

HelpS    SEGMENT   BYTE PUBLIC
EUEMnLnH db        58,'P©eps n¡ obsahu existuj¡c¡ho souboru novˆ ukl dan˜m textem'
         db        37,'Opakov n¡ zad n¡ jin‚ho jm‚na souboru'
         db        54,'P©id n¡ ukl dan‚ho textu na konec existuj¡c¡ho souboru'
         db        3,1
         dw        MenuHlP2
HelpS    ENDS

; -----------------------------------------------------------------------------
;        data pro editor/prohl¡‘e‡
; -----------------------------------------------------------------------------

NacitTxt db        9,'Na‡¡t m ',0

;ColEdi1  db        30h                      ; barva informa‡n¡ho © dku
;ColEdi2  db        3eh                      ; informa‡n¡ © dek zv˜raznˆn˜
;ColEdi3  db        1bh                      ; bˆ‘n˜ text
;ColEdi4  db        1dh                      ; ©¡dic¡ znaky
;ColEdi5  db        1eh                      ; indikace p©ekro‡en¡ © dku
;ColEdi6  db        70h                      ; blok v textu
;ColEdi7  db        30h                      ; neaktivn¡ kurzor

;EditBAK  db        25                       ; po‡et z loh souboru BAK

EdiTabul dw        8                        ; odskoky pro tabul tor

EditPrik db        0                        ; uschovan˜ prvn¡ znak p©¡kazu
                                            ;     0 = nen¡
                                            ;   0Ah = Ctrl-J
                                            ;   0Bh = Ctrl-K
                                            ;   0Fh = Ctrl-O
                                            ;   11h = Ctrl-Q

;Edit0Vys dw        140*256                  ; relativn¡ v˜¨ka okna 1 (0 - 65535)
;Edit0Sir dw        131*256                  ; relativn¡ ¨¡©ka okna 1 (0 - 65535)

;EditParm db        bit5                     ; parametry pro editor
;                                            ;      bit 0: 1=datum a ‡as uchovat
;                                            ;      bit 1: 1=hexadec. Ä¿00=text.
;                                            ;      bit 2: 1=bin rn¡ ÄÄÙ11=autom.
;                                            ;      bit 3: 1=prohl¡‘e‡
;                                            ;      bit 4: 1=soubor byl vytvo©en
;                                            ;      bit 5: 1=je zapnut INSERT
;                                            ;      bit 6: 1=synchronizace oken
;                                            ;      bit 7: 1=p©ech.soub.vytvo©en
;
;EditPar2 db        0                        ; parametry pro editor 2
;                                            ;      bit 0: 1=zobraz kurzor
;                                            ;      bit 1: 1=zobraz akt. © dek
;                                            ;      bit 2: 1=zobraz akt. okno
;                                            ;      bit 3: 1=zobraz v¨echna okna
;                                            ;      bit 4: 1=2 okna (0=1 okno)
;                                            ;      bit 5: 1=vertik ln¡ okna (0=horiz.)
;                                            ;      bit 6: 1=aktivn¡ okno 2
;                                            ;      bit 7: 1=‡as se zobrazuje

;
;OpenEMod db        bit0+bit1+bit2           ; m¢d otev©en¡ editoru pro menu
;                                            ;      bit 0: 1=datum a ‡as uchovat
;                                            ;      bit 1: 1=hexadec.Ä¿00=text.
;                                            ;      bit 2: 1=bin rn¡ ÄÙ11=autom.
;                                            ;      bit 3: 1=prohl¡‘e‡

;
;OldESwch db        0                        ; inicializa‡n¡ p©ep¡na‡ ze souboru
;                                            ;      bit 0: 1=jen zobrazen¡ (0=edit.)
;                                            ;      bit 1: 1=HEX m¢d
;                                            ;      bit 2: 1=bin rn¡ m¢d
;                                            ;      bit 3: 1=line l
;                                            ;      bit 4: 1=tabul tor voln˜
;                                            ;      bit 5: 1=vypnuta optimalizace
;                                            ;      bit 6:
;                                            ;      bit 7: 1=tabul tor bˆ‘n˜ znak
;
;OldESwc2 db        0                        ; parametry souboru editoru
;                                            ;      bit 0:
;                                            ;      bit 1:
;                                            ;      bit 2: 1=z kaz z pisu
;                                            ;      bit 3:
;                                            ;      bit 4:
;                                            ;      bit 5:
;                                            ;      bit 6: 1=sloupcov˜ blokÄ¿0=text.
;                                            ;      bit 7: 1=© dkov˜ blok ÄÄÙ blok

EditOutI dw        0                        ; identifik tor v˜stupn¡ho souboru
                                            ;   (0=nen¡ otev©en)

; ------ popisova‡ oken editoru (‡¡sla soubor– jsou 1...NumEdi)

NumEdi   dw        0                        ; po‡et otev©en˜ch soubor– editoru
SegmTEdi dw        0                        ; segment ‡¡sel segment– soubor–
                                            ;     (na za‡ tku segmentu po‡et
                                            ;      bajt– v segmentu (2 bajty),
                                            ;      n sleduje tabulka ‡¡sel
                                            ;      segment– po 2 bajtech)
                                            ;      (bit 15 = 0 !)

; ------ ‡¡sla oken 1... (nemˆnit po©ad¡ oken 1 a 2 !)

EdiWAkt  dw        0                        ; ‡¡slo souboru aktivn¡ho okna (0=nen¡)
EdiWNAkt dw        0                        ; ‡¡slo souboru neaktivn¡ho okna
EdiW1Win dw        0                        ; ‡¡slo souboru okna 1
EdiW2Win dw        0                        ; ‡¡slo souboru okna 2

; ------ segmenty oken (bit 15: 1=je okno 2)

EdiSAkt  dw        0                        ; segment aktivn¡ho okna (0=nen¡)
EdiSNAkt dw        0                        ; segment neaktivn¡ho okna (0=nen¡)

; ------ segmenty oken (bit 15 = 0)

EdiS1Win dw        0                        ; segment souboru okna 1 (0=nen¡)
EdiS2Win dw        0                        ; segment souboru okna 2 (0=nen¡)

; ------ segment bufferu (je to okno 0)

EditSBuf dw        0                        ; segment bufferu blok–

; ------ hl ¨en¡ o operac¡ch

;EdiCpTxt db        27,0,'Kop¡ruji',0,' ozna‡en˜ blok...'
;EdiMvTxt db        28,0,'P©esouv m',0,' ozna‡en˜ blok...'
;EdiDlTxt db        24,0,'Ru¨¡m',0,' ozna‡en˜ blok...'
;EdiUkTxt db        39,0,'Ukl d m',0,' ozna‡en˜ blok do z sobn¡ku...'
;EdiNaTxt db        31,0,'Navrac¡m',0,' blok ze z sobn¡ku...'

EdiZaTxt db        16,'Ukl d m soubor ',0
;EdiCtTxt db        16,'Na‡¡t m soubor ',0

Data     ENDS

         END

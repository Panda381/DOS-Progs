

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                             Hexadecim ln¡ editor
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

MAXFILE  EQU       0ffffh/(20+2)            ; maxim ln¡ po‡et soubor– seznamu
MAXSEKT  EQU       2000h                    ; maxim ln¡ velikost sektoru (8 KB)

MAXTEXT  EQU       20                       ; maxim. d‚lka textov‚ho parametru

EBUFDELK EQU       20                       ; d‚lka edita‡n¡ho bufferu polo‘ky

FILECOL  EQU       25-9                     ; po‡et soubor– na sloupec
FILESIR  EQU       1+8+1+3+1+1              ; ¨¡©ka jednoho sloupce soubor–
FILECOLS EQU       5                        ; maxim ln¡ po‡et sloupc– na obraz.

DISPMAX  EQU       21*80                    ; maxim ln¡ zobrazen  velikost dat

KODN1    EQU       0                        ; po‡ t. ‡¡slo text– assemb. d‚lky 1
KODN2    EQU       KODN1+1                  ; po‡ t. ‡¡slo text– assemb. d‚lky 2
KODN3    EQU       KODN2+13                 ; po‡ t. ‡¡slo text– assemb. d‚lky 3
KODN4    EQU       KODN3+69                 ; po‡ t. ‡¡slo text– assemb. d‚lky 4
KODN5    EQU       KODN4+37                 ; po‡ t. ‡¡slo text– assemb. d‚lky 5
KODN6    EQU       KODN5+23                 ; po‡ t. ‡¡slo text– assemb. d‚lky 6
KODN7    EQU       KODN6+2                  ; po‡ t. ‡¡slo text– assemb. d‚lky 7

HI       EQU       256

bit0     EQU       1
bit1     EQU       2
bit2     EQU       4
bit3     EQU       8
bit4     EQU       10h
bit5     EQU       20h
bit6     EQU       40h
bit7     EQU       80h
bit8     EQU       100h
bit9     EQU       200h
bit10    EQU       400h
bit11    EQU       800h
bit12    EQU       1000h
bit13    EQU       2000h
bit14    EQU       4000h
bit15    EQU       8000h

; ------ atributy souboru

RO       EQU       1                        ; atribut R/O
HID      EQU       2                        ; atribut HID
SYS      EQU       4                        ; atribut SYS
VOL      EQU       8                        ; atribut VOL
DIR      EQU       10h                      ; atribut DIR
ARC      EQU       20h                      ; atribut ARC

; ------ polo‘ka souboru v seznamu

FileAtr  EQU       0                        ; (1) atribut souboru
FileName EQU       1                        ; (8) jm‚no souboru
FileExt  EQU       9                        ; (3) p©¡pona jm‚na souboru
FileTime EQU       12                       ; (2) ‡as souboru
FileDate EQU       14                       ; (2) datum souboru
FileSize EQU       16                       ; (4) velikost souboru
FileSum  EQU       20                       ; velikost polo‘ky souboru

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; ------ kontrola konce pamˆti

Start:   cmp       sp,offset Zasob          ; kontrola konce z sobn¡ku
         jae       Start2                   ; z sobn¡k je OK

; ------ chyba - nedostatek pamˆti

ErrMem:  mov       dx,offset MemTxt         ; text - nedostatek pamˆti
Chyba:   mov       ah,9
         int       21h                      ; zobrazen¡ chybov‚ho textu
         mov       ax,4c01h
         int       21h                      ; chybov˜ n vrat z programu

; ------ p©edefinov n¡ z sobn¡ku

Start2:  mov       sp,offset Zasob          ; p©edefinov n¡ z sobn¡ku

; ------ zmen¨en¡ bloku programu

         mov       bx,(offset(Zasob-Start)+10fh)/16 ; velikost bloku programu
         mov       ah,4ah
         int       21h                      ; zmen¨en¡ bloku programu
         jc        ErrMem                   ; nˆjak  chyba

; ------ vytvo©en¡ datov‚ho bloku 64 KB

         mov       ah,48h
         mov       bx,1000h                 ; velikost alok. bloku 64 KB
         int       21h                      ; poskytnut¡ maxim ln¡ho alok. bloku
         jc        ErrMem                   ; nedostatek pamˆti
         mov       ds:[BuffSegm],ax         ; b zov  adresa buffer–

; ------ ur‡en¡ adres buffer–

         xor       bx,bx                    ; BX <- adresa bufferu 1 (edita‡n¡)
         mov       dx,8000h                 ; DX <- adresa bufferu 2 (refer.)
         test      ah,8                     ; je p©elom 64 KB ?
         jz        Start3                   ; nebyl by p©elom 64 KB
         xchg      bx,dx                    ; z mˆna buffer– 1 a 3
Start3:  mov       ds:[BuffOff1],bx         ; adresa bufferu 1 (edita‡n¡)
         mov       ds:[BuffOff2],dx         ; adresa bufferu 2 (referen‡n¡)

; ------ vytvo©en¡ datov‚ho bloku 4 KB pro £schovu obsahu obrazovky

         mov       bx,(25*160+16)/16        ; velikost datov‚ho bloku pro VRAM
         mov       ah,48h
         int       21h                      ; vytvo©en¡ datov‚ho bloku
         jc        ErrMem                   ; nedostatek pamˆti
         mov       ds:[BuffVRAM],ax         ; buffer pro £schovu videopamˆti

; ------ rozbor p©¡kazov‚ho © dku

         call      Rozbor                   ; rozbor zad n¡ p©¡kazov‚ho © dku
         jnc       Start47
         mov       dx,offset HelpTxt        ; text n povˆdy
Chyba2:  jmp       Chyba                    ; chyba zad n¡

; ------ test, zda byl zad n soubor (adres ©) k editaci

Start47: cmp       word ptr ds:[SouborN],0  ; byl zad n soubor/adres © ?
         je        Start6                   ; nebyl zad n soubor ani adres ©

; ------ test, zda byl zad n ROOT disku

         cmp       word ptr ds:[SouborN],3
         jne       Start50
         cmp       word ptr ds:[Soubor+1],"\:" ; je ROOT ?
         je        Start52                  ; je zad n ROOT
Start50: cmp       word ptr ds:[SouborN],1
         jne       Start51
         cmp       byte ptr ds:[Soubor],"\"
         je        Start52                  ; je ROOT

; ------ nastaven¡ pracovn¡ adresy DTA

Start51: mov       dx,offset DTA            ; pracovn¡ adresa DTA
         mov       ah,1ah
         int       21h                      ; nastaven¡ pracovn¡ adresy DTA

; ------ pokus o nalezen¡ souboru

         mov       dx,offset Soubor         ; jm‚no zadan‚ho souboru
         mov       cx,ARC + DIR + RO + HID + SYS  ; atributy souboru
         mov       ah,4eh
         int       21h                      ; nalezen¡ zadan‚ho souboru
         mov       dx,offset FndTxt         ; text - soubor nenalezen
         jc        Chyba2                   ; chyba - soubor nenalezen

; ------ rozli¨en¡ typu souboru

         mov       al,bit6                  ; p©¡znak - je soubor
         test      byte ptr ds:[DTAAtrib],DIR ; je to adres © ?
         jz        Start56                  ; je to soubor
Start52: mov       al,bit7                  ; p©¡znak adres ©e
Start56: or        byte ptr ds:[Param],al   ; p©¡znak souboru nebo adres ©e

; ------ vypnut¡ re‘imu hust‚ho © dkov n¡

Start6:  push      ds
         xor       ax,ax
         mov       ds,ax
         and       byte ptr ds:[487h],not bit0 + bit7 ; normalizace bit–
         and       byte ptr ds:[449h],not bit7 ; p©¡znak maz n¡ displeje
         pop       ds

; ------ inicializace videom¢du

         mov       ah,0fh
         call      Int10P                   ; poskytnut¡ videom¢du
         cmp       al,7                     ; je videom¢d 7 ?
         je        Start7                   ; je videom¢d 7
         mov       byte ptr ds:[SegmVRAM+1],0b8h ; jinak videoRAM pro CGA
         cmp       al,2                     ; videom¢d 2 ?
         je        Start7                   ; to je je¨tˆ povolen˜ videom¢d
         mov       al,3                     ; jinak videom¢d 3
Start7:  mov       ah,0
         call      Int10P                   ; inicializace videom¢du

; ------ vypnut¡ re‘imu hust‚ho © dkov n¡

         push      ds
         xor       ax,ax
         mov       ds,ax
         and       byte ptr ds:[487h],not bit0 + bit7 ; normalizace bit–
         and       byte ptr ds:[449h],not bit7 ; p©¡znak maz n¡ displeje
         pop       ds

; ------ inicializace rozmˆr– kurzoru

         mov       cx,607h                  ; kurzor pro CGA
         cmp       byte ptr ds:[SegmVRAM+1],0b8h ; je videom¢d CGA ?
         je        Start72                  ; je videom¢d CGA
         mov       cx,0b0ch                 ; jinak kurzor pro MDA
Start72: mov       ah,1
         call      Int10P                   ; inicializace kurzoru

; ------ inicializace barev pro monochromatick˜ m¢d

         cmp       byte ptr ds:[SegmVRAM+1],0b0h ; je monochrom. m¢d ?
         jne       Start73                  ; nen¡ monochrom. m¢d
         push      ds
         pop       es
         mov       si,offset ColMono        ; monochromn¡ barvy
         mov       di,offset ColTab         ; tabulka barev
         mov       cx,offset(ColTab0-ColTab); d‚lka tabulky
         cld
         rep       movsb                    ; nastaven¡ monochromn¡ch barev

; ------ instalace obsluh p©eru¨en¡

Start73: mov       ax,2523h
         mov       dx,offset INT23
         int       21h
         mov       ax,2524h
         mov       dx,offset INT24
         int       21h
         mov       ax,3300h
         int       21h                      ; poskytnut¡ p©ep¡na‡e BREAK
         mov       ds:[OldBreak],dl         ; £schova p©ep¡na‡e BREAK
         mov       dl,0
         mov       ax,3301h
         int       21h                      ; vypnut¡ p©ep¡na‡e BREAK

; ------ instalace INT 08h

         mov       ax,3508h
         int       21h
         mov       word ptr ds:[Old08],bx
         mov       word ptr ds:[Old08+2],es
         mov       dx,offset Int08
         mov       ax,2508h
         int       21h

; ------ verze syst‚mu

         mov       ah,30h
         int       21h                      ; poskytnut¡ verze syst‚mu
         xchg      ah,al
         mov       ds:[VerzeOS],ax          ; verze opera‡n¡ho syst‚mu

; ------ korekce prodlev pro XT

         mov       ax,0f000h
         mov       es,ax
         cmp       byte ptr es:[0fffeh],0fch ; je AT ?
         je        Menu0                    ; je AT
         mov       byte ptr ds:[HMenu02+1],1 ; korekce pro pomal‚ po‡¡ta‡e

; -----------------------------------------------------------------------------
;        z kladn¡ volby
; -----------------------------------------------------------------------------

; ------ zobrazen¡ podkladov‚ho r mu

Menu0:   call      DispRam                  ; zobrazen¡ podkladu r mu

; ------ zobrazen¡ informa‡n¡ho © dku

         mov       si,offset LicTxt         ; licen‡n¡ text
         call      InfoDis0                 ; zobrazen¡ informa‡n¡ho © dku

; ------ volba akce

Menu1:   mov       si,offset DefM0          ; z kladn¡ volby
         call      Volby                    ; proveden¡ voleb
         call      JumpBX                   ; obsluha volby

         dw        1,Menu11                 ; soubor
         dw        2,Menu12                 ; adres ©
         dw        3,Menu13                 ; tabulka FAT
         dw        4,Menu13                 ; logick˜ disk
         dw        5,Menu14                 ; fyzick˜ disk
         dw        6,Menu15                 ; opera‡n¡ pamˆŸ
         dw        7,Menu16                 ; roz¨¡©en  pamˆŸ
         dw        8,Menu17                 ; pamˆŸ CMOS

         dw        0,Konec                  ; p©eru¨en¡ volby ESC nebo volba 8

; ====== konec programu

Konec:

; ------ n vrat p©¡znaku BREAK

         mov       dl,ds:[OldBreak]         ; p–vodn¡ p©¡znak BREAK
         mov       ax,3301h
         int       21h                      ; n vrat p©¡znaku BREAK

; ------ n vrat adresy INT 08h

         push      ds
         lds       dx,ds:[Old08]
         mov       ax,2508h
         int       21h
         pop       ds

; ------ vymaz n¡ obrazovky

         xor       di,di                    ; po‡ te‡n¡ adresa videopamˆti
         mov       es,ds:[SegmVRAM]         ; segment videopamˆti
         mov       cx,25*80                 ; d‚lka videopamˆti
         mov       ax,720h                  ; mazac¡ znak mezery
         cld
         rep       stosw                    ; vymaz n¡ videopamˆti

; ------ inicializace kurzoru

         xor       dx,dx
         call      SetKurz                  ; nastaven¡ kurzoru vlevo nahoru

; ------ n vrat z programu

         mov       ax,4c00h
         int       21h

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                Editace souboru - volba logick‚ho disku
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;þ
Menu11   PROC      NEAR

; ------ zobrazen¡ podkladov‚ho r mu

         mov       byte ptr ds:[EditObj],bit0 ; p©¡znak editace souboru
         call      DispRam                  ; zobrazen¡ podkladu r mu
         mov       si,offset SoubTxt        ; text "Soubor"
         call      InfoDis0                 ; zobrazen¡ informa‡n¡ho © dku

; ------ inicializace tabulky disk–

         call      IniLDsk                  ; inicializace seznamu disk–
         call      VolLDsk                  ; volba logick‚ho disku
         jc        Menu1102                 ; p©eru¨en¡ ESC
         jmp       MSoub                    ; volba soubor–

Menu1102:jmp       Menu0                    ; z kladn¡ menu

Menu11   ENDP

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                Editace adres ©e - volba logick‚ho disku
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

Menu12   PROC      NEAR

; ------ zobrazen¡ podkladov‚ho r mu

         mov       byte ptr ds:[EditObj],bit1 ; p©¡znak editace adres ©e
         call      DispRam                  ; zobrazen¡ podkladu r mu
         mov       si,offset AdrTxt         ; text "Adresar"
         call      InfoDis0                 ; zobrazen¡ informa‡n¡ho © dku

; ------ inicializace tabulky disk–

         call      IniADsk                  ; inicializace seznamu disk–
         call      VolLDsk                  ; volba logick‚ho disku
         jc        Menu1202                 ; p©eru¨en¡ ESC
         jmp       MSoub                    ; volba adres ©e

Menu1202:jmp       Menu0                    ; z kladn¡ menu

Menu12   ENDP

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                Editace logick‚ho disku - volba logick‚ho disku
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

Menu13   PROC      NEAR

; ------ zobrazen¡ podkladov‚ho r mu

         mov       byte ptr ds:[EditObj],bit2 ; p©¡znak editace logick‚ho disku
         call      DispRam                  ; zobrazen¡ podkladu r mu
         mov       si,offset LDiskTxt       ; text "Logick˜ disk"
         call      InfoDis0                 ; zobrazen¡ informa‡n¡ho © dku

; ------ inicializace tabulky disk–

         call      IniADsk                  ; inicializace seznamu disk–
         call      VolLDsk                  ; volba logick‚ho disku
         jc        Menu1302                 ; p©eru¨en¡ ESC
         jmp       EObj                     ; editace logick‚ho disku

Menu1302:jmp       Menu0                    ; z kladn¡ menu

Menu13   ENDP

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                  Editace fyzick‚ho disku - volba disku
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

Menu14   PROC      NEAR

; ------ zobrazen¡ podkladov‚ho r mu

         mov       byte ptr ds:[EditObj],bit3 ; p©¡znak editace fyzick‚ho disku
         call      DispRam                  ; zobrazen¡ podkladu

; ------ zobrazen¡ informa‡n¡ho © dku

         mov       si,offset FDiskTxt       ; text "Fyzick˜ disk"
         call      InfoDis0                 ; zobrazen¡ informa‡n¡ho © dku

; ------ inicializace tabulky disk–

         call      IniFDsk                  ; inicializace tabulky disk–
Menu1401:call      VolFDsk                  ; volba fyzick‚ho disku
         jc        Menu1402                 ; p©eru¨en¡ ESC
         jmp       EObj                     ; editace fyzick‚ho disku

Menu1402:jmp       Menu0                    ; z kladn¡ volby

Menu14   ENDP

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                      Editace opera‡n¡ pamˆti
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

Menu15   PROC      NEAR

         mov       byte ptr ds:[EditObj],bit4 ; p©¡znak editace opera‡n¡ pamˆti
         jmp       EObj                     ; editace opera‡n¡ pamˆti

Menu15   ENDP

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                      Editace roz¨¡©en‚ pamˆti
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

Menu16   PROC      NEAR

         mov       byte ptr ds:[EditObj],bit5 ; p©¡znak editace roz¨¡©en‚ pamˆti
         jmp       EObj                     ; editace roz¨¡©en‚ pamˆti

Menu16   ENDP

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                      Editace pamˆti CMOS
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

Menu17   PROC      NEAR

         mov       byte ptr ds:[EditObj],bit6 ; p©¡znak editace pamˆti CMOS
         jmp       EObj                     ; editace pamˆti CMOS

Menu17   ENDP

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;             Editace souboru nebo adres ©e - volba souboru k editaci
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;þ
MSoub    PROC      NEAR

; ------ p©¡prava pro p©ednastaven¡ na polo‘ku ".."

         mov       di,offset QckFile        ; buffer rychlovyhled v n¡
         push      ds
         pop       es                       ; ES <- DS
         mov       ax,".."
         stosw                              ; za‡ tek jm‚na ".."
         mov       al," "
         mov       cx,11-2
         rep       stosb                    ; vymaz n¡ zbytku jm‚na mezerami
         mov       byte ptr ds:[QckFileN],11 ; d‚lka jm‚na v bufferu

; ------ zobrazen¡ podkladov‚ho r mu

MSoub1:  push      ds
         pop       es
         call      DispRam                  ; zobrazen¡ podkladu r mu
         mov       si,offset SoubTxt        ; text "Soubor"
         test      byte ptr ds:[EditObj],bit0 ; edituje se soubor ?
         jnz       MSoub11                  ; edituje se soubor
         mov       si,offset AdrTxt         ; jinak text "Adres ©"
MSoub11: push      si
         call      InfoDis0                 ; zobrazen¡ informa‡n¡ho © dku
         call      KurzOff                  ; vypnut¡ kurzoru
         call      InitPath                 ; inicializace (na‡ten¡) cesty
         pop       si                       ; text "Soubor" nebo "Adres ©"
         call      InfoSoub                 ; zobrazen¡ informa‡n¡ho © dku

; ------ na‡ten¡ obsahu adres ©e a p©¡padn‚ p©ednastaven¡ na polo‘ku

         call      ReadDir                  ; na‡ten¡ adres ©e
         cmp       byte ptr ds:[QckFileN],0 ; je nˆco v bufferu ?
         je        MSoub2                   ; v bufferu nic nen¡
         mov       dh,DIR                   ; hled  se nejd©¡ve v adres ©¡ch
         call      QckSrc0                  ; nalezen¡ adres ©e
         jnc       MSoub13                  ; polo‘ka nalezena OK
         mov       dh,0                     ; hled  se v souborech
         call      QckSrc0                  ; nalezen¡ souboru
         jc        MSoub2                   ; polo‘ka nenalezena
MSoub13: mov       ds:[FileAkt],bx          ; aktivn¡ polo‘ka
MSoub2:  mov       byte ptr ds:[QckFileN],0 ; po‡et znak– v bufferu rychlovyhl.
MSoub3:  call      DispDir                  ; zobrazen¡ obsahu adres ©e

; ------ obsluha seznamu soubor–

         call      InpChr                   ; vstup znaku z kl vesnice
         mov       ax,ds:[FileAkt]          ; aktivn¡ polo‘ka
         mov       cx,ds:[FileNum]          ; max. po‡et polo‘ek
         call      JumpBX                   ; obsluha kl vesy

         dw        5000h,MSoub4             ; kurzor dol– DOWN
         dw        4800h,MSoub5             ; kurzor nahoru UP
         dw        4700h,MSoub6             ; za‡ tek HOME
         dw        8400h,MSoub6             ; za‡ tek Ctrl-PGUP
         dw        4f00h,MSoub7             ; konec END
         dw        7600h,MSoub7             ; konec Ctrl-PGDWN
         dw        4b00h,MSoub8             ; vlevo LEFT
         dw        4d00h,MSoub9             ; vpravo RIGHT
         dw        7700h,MSoub64            ; horn¡ okraj Ctrl-HOME
         dw        7500h,MSoub74            ; doln¡ okraj Ctrl-END
         dw        4900h,MSoub66            ; str nka nahoru PGUP
         dw        5100h,MSoub76            ; str nka dol– PGDWN

         dw        1c0dh,MSoubB             ; zmˆna adres ©e ENTER
         dw        1c0ah,MSoubB             ; editace Ctrl-ENTER
         dw        11bh,MSoubE              ; p©eru¨en¡ volby ESC
         dw        0,MSoubA                 ; jin  kl vesa

; ------ kurzor dol–

MSoub4:  inc       ax                       ; zv˜¨en¡ ‡¡sla polo‘ky
MSoub41: cmp       ax,cx                    ; je ji‘ konec ?
         jae       MSoub7                   ; je ji‘ konec
MSoub42: mov       ds:[FileAkt],ax          ; nov  aktivn¡ polo‘ka
         jmp       short MSoub2             ; nov  kl vesa

; ------ kurzor nahoru

MSoub5:  or        ax,ax                    ; je ji‘ za‡ tek ?
         jz        MSoub2                   ; je ji‘ za‡ tek
         dec       ax                       ; sn¡‘en¡ ‡¡sla polo‘ky
         jmp       short MSoub42            ; nov  aktivn¡ polo‘ka

; ------ prvn¡ polo‘ka

MSoub6:  xor       ax,ax                    ; ‡¡slo prvn¡ polo‘ky
         jmp       short MSoub42

; ------ horn¡ okraj

MSoub64: xor       dx,dx                    ; DX <- 0
         mov       bx,FILECOL               ; po‡et polo‘ek na sloupec
         div       bx                       ; v˜po‡et ‡¡sla sloupce
         mul       bx                       ; soubor na horn¡m okraji
         jmp       short MSoub42

; ------ str nka nahoru

MSoub66: mov       bx,ds:[FileTop]          ; po‡ tek seznamu
         mov       dx,bx                    ; £schova po‡ tku
         sub       bx,FILECOL*(FILECOLS-1)  ; ode‡ten¡ soubor– na str nku
         jnc       MSoub67
         xor       bx,bx                    ; omezen¡ po‡ tku
MSoub67: sub       dx,bx                    ; posun po‡ tku
         jz        MSoub6                   ; nebyl posun po‡ tku
         mov       ds:[FileTop],bx          ; nov˜ po‡ tek
         sub       ax,dx                    ; posun kurzoru
         jmp       short MSoub42

; ------ posledn¡ polo‘ka

MSoub7:  mov       ax,cx                    ; po‡et polo‘ek
         or        ax,ax                    ; je nˆjak  polo‘ka ?
         jz        MSoub42                  ; nen¡ ‘ dn  polo‘ka
         dec       ax                       ; ‡¡slo posledn¡ polo‘ky
MSoub422:jmp       short MSoub42

; ------ doln¡ okraj

MSoub74: xor       dx,dx                    ; DX <- 0
         mov       bx,FILECOL               ; po‡et polo‘ek na sloupec
         div       bx                       ; v˜po‡et ‡¡sla sloupce
         mul       bx                       ; soubor na horn¡m okraji
         add       ax,FILECOL-1             ; soubor na spodn¡m okraji
MSoub411:jmp       short MSoub41            ; kontrola kurzoru

; ------ str nka dol–

MSoub76: push      ax
         mov       ax,ds:[FileNum]          ; po‡et soubor–
         or        ax,ax                    ; je nˆjak˜ soubor ?
         jz        MSoub77                  ; nen¡ ‘ dn˜ soubor
         dec       ax                       ; posledn¡ soubor
MSoub77: xor       dx,dx                    ; DX <- 0
         mov       bx,FILECOL               ; po‡et soubor– na sloupec
         div       bx                       ; v˜po‡et ‡¡sla sloupce
         mul       bx                       ; zaokrouhlen˜ sloupec
         sub       ax,FILECOL*(FILECOLS-1)  ; maxim ln¡ po‡ tek
         jnc       MSoub78                  ; nen¡ podte‡en¡
         xor       ax,ax                    ; omezen¡ po‡ tku
MSoub78: xchg      ax,dx                    ; DX <- maxim ln¡ po‡ tek
         pop       ax                       ; aktivn¡ polo‘ka
         sub       dx,ds:[FileTop]          ; maxim ln¡ posun
         jz        MSoub7                   ; je ji‘ konec
         cmp       dx,FILECOL*(FILECOLS-1)  ; maxim ln¡ posun
         jbe       MSoub79                  ; posun je OK
         mov       dx,FILECOL*(FILECOLS-1)  ; omezen¡ posunu
MSoub79: add       ds:[FileTop],dx          ; posun po‡ tku
         add       ax,dx                    ; posun kurzoru
         jmp       short MSoub411

; ------ kurzor vlevo

MSoub8:  sub       ax,FILECOL               ; posun o sloupec
         jc        MSoub6
         jmp       short MSoub422

; ------ kurzor vpravo

MSoub9:  add       ax,FILECOL               ; posun o sloupec
         jmp       short MSoub411

; ------ rychlovyhled v n¡

MSoubA:  call      QckSrc                   ; nalezen¡ nov‚ho souboru
         mov       ds:[FileAkt],ax          ; nov  aktivn¡ polo‘ka
MSoubA3: jmp       MSoub3                   ; pokra‡ov n¡ v editaci

; ------ ENTER, Ctrl-ENTER : v˜bˆr souboru, zmˆna adres ©e

MSoubB:  call      GetAFil                  ; poskytnut¡ aktivn¡ polo‘ky
         jc        MSoubA3                  ; neplatn  polo‘ka
         mov       al,es:[si+FileAtr]       ; £schova atribut– polo‘ky
         call      FcbAsc                   ; konverze na jm‚no ASCIIZ
         call      SubFile                  ; zru¨en¡ textu "*.*"
         mov       si,offset SoubName       ; jm‚no souboru ASCII pod kurzorem
         cmp       word ptr ds:[si],".."    ; je to nadadres © ?
         je        MSoubB6                  ; nastaven¡ adres ©e
         cmp       word ptr ds:[si],"."     ; je aktu ln¡ adres © "." ?
         je        MSoubB8                  ; editace adres ©e
         call      AddFile                  ; p©id n¡ jm‚na souboru/adres ©e
         test      al,DIR                   ; je to adres © ?
         jz        MSoubB8                  ; je to soubor - editace

; ------ rozli¨en¡, zda je editace adres ©e pod kurzorem

         test      byte ptr ds:[EditObj],bit0 ; edituje se soubor ?
         jnz       MSoubB4                  ; je editace souboru - zmˆna adres.
         cmp       bl,0dh                   ; je kl vesa ENTER ?
         jne       MSoubB8                  ; nen¡ kl vesa ENTER - editace adr.

; ------ zmˆna adres ©e pod kurzorem

MSoubB4: mov       si,offset SoubNm0        ; zadan˜ adres © pod kurzorem
         call      SetDir                   ; zmˆna adres ©e
         jmp       MSoub                    ; p©ednastaven¡ na polo‘ku ".."

; ------ zmˆna adres ©e ".."

MSoubB6: call      PrepSrc                  ; p©¡prava rychlovyhled v n¡
         mov       si,offset SoubNm0        ; jm‚no polo‘ky ".."
         call      SetDir                   ; zmˆna adres ©e
         jmp       MSoub1                   ; nov  inicializace adres ©e

; ------ editace souboru/adres ©e

MSoubB8: call      PrepSrc                  ; p©¡prava rychlovyhled v n¡
         or        byte ptr ds:[Param2],bit4 ; p©¡znak £schovy 1. polo‘ky
         jmp       short EObj               ; editace zvolen‚ho souboru/adres ©e

; ------ p©eru¨en¡ volby ESC

MSoubE:  test      byte ptr ds:[EditObj],bit0 ; edituje se soubor ?
         jnz       MSoubE2                  ; edituje se soubor
         jmp       Menu12                   ; volba disku pro adres ©
MSoubE2: jmp       Menu11                   ; volba disku pro soubor

MSoub    ENDP

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                        Editace objektu
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;þ
EObj    PROC      NEAR

; ------ otev©en¡ objektu k editaci

         call      OpenObj                  ; otev©en¡ objektu
         jnc       EObj04

EObj03:  test      byte ptr ds:[EditObj],bit0+bit1
         jz        EObj032
         jmp       MSoub1                   ; n vrat k volbˆ souboru

EObj032: jmp       Menu0

; ------ zobrazen¡ r mu

EObj04: call      OpenDis                  ; otev©en¡ zobrazen‚ho form tu

EObj05: call      DispRm0                  ; zobrazen¡ r mu bez spodn¡ linky
         call      DispFn0                  ; zobrazen¡ funk‡n¡ch kl ves

; ------ zobrazen¡ informa‡n¡ho © dku

         call      InfoClr                  ; vymaz n¡ bufferu inform. © dku
         mov       si,offset SoubTxt        ; text "Soubor"
         call      InfoDek                  ; dek¢dov n¡ prvn¡ ‡ sti textu
         mov       si,offset SoubName       ; jm‚no souboru
         mov       di,offset InfoBuf+2*7
         call      InfoDek                  ; p©enesen¡ textu
         call      InfoDisp                 ; zobrazen¡ informa‡n¡ho © dku

; ------ zobrazen¡ editovan‚ho objektu

EObj3:   push      ds
         pop       es
         call      Disp                     ; zobrazen¡ editovan‚ho objektu
         call      Kurz                     ; zobrazen¡ kurzoru objektu

         call      InpChrF                  ; vstup znaku se zobrazen¡m kl ves

         call      JumpBX

         dw        11bh,EObj9
         dw        0,EObjEd


EObjEd: call      Edit
         jmp       short EObj3

; ------ ukon‡en¡ editace ESC

EObj9:   call      TestBuff                 ; test bufferu, zda byl modifikov n
         jnc       EObj906                  ; buffer nebyl modifikov n

; ------ buffer byl modifikov n - dotaz, zda se m  ulo‘it

         mov       si,offset ModiMnu        ; menu - dotaz na ulo‘en¡ dat
         call      HMenu                    ; horizont ln¡ menu
         call      JumpBX                   ; skok na obsluhu
         dw        1,EObj902                ; ulo‘en¡ zmˆn
         dw        2,EObj906                ; zmˆny se neulo‘¡
         dw        0,EObj3                  ; jinak p©eru¨en¡ operace

; ------ ulo‘en¡ obsahu bufferu

EObj902: call      WritBuff                 ; ulo‘en¡ obsahu bufferu na disk


EObj906:
         test      byte ptr ds:[EditObj],bit0+bit1
         jz        EObj092
         jmp       MSoub1                   ; n vrat k volbˆ souboru

EObj092: jmp       Menu0

EObj    ENDP

;; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;;
;;                           Editace zvolen‚ho adres ©e
;;
;; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;EAdr     PROC      NEAR
;
;; ------ zobrazen¡ r mu
;
;         call      DispRam
;
;; ------ zobrazen¡ informa‡n¡ho © dku
;
;         call      InfoClr                  ; vymaz n¡ bufferu inform. © dku
;         mov       si,offset AdrTxt         ; text "Adres ©"
;         call      InfoDek                  ; dek¢dov n¡ prvn¡ ‡ sti textu
;         mov       si,offset SoubName       ; jm‚no adres ©e
;         mov       di,offset InfoBuf+2*8
;         call      InfoDek                  ; p©enesen¡ textu
;         call      InfoDisp                 ; zobrazen¡ informa‡n¡ho © dku
;
;
;         call      KurzOff
;         call      InpChr
;
;         jmp       MSoub1
;
;EAdr     ENDP

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                             Volby
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;þ
; -----------------------------------------------------------------------------
;        proveden¡ volby DS:SI (v˜stup: BX=zvolen  polo‘ka 1..., 0=ESC)
; -----------------------------------------------------------------------------

Volby    PROC      NEAR

; ------ zobrazen¡ menu

Volby1:  call      DispVol                  ; zobrazen¡ voleb menu

; ------ ‡ek n¡ na zad n¡ znaku z kl vesnice

         call      KurzOff                  ; vypnut¡ kurzoru
         call      InpChr                   ; vstup znaku z kl vesnice
         mov       ax,ds:[si]               ; AL=akt. polo‘ka, AH=po‡et polo‘ek
         call      JumpBX                   ; obsluha kl vesy

         dw        4800h,VolUp              ; nahoru
         dw        0f00h,VolUp              ; Shift-Tab
         dw        5000h,VolDwn             ; dol–
         dw        0f09h,VolDwn             ; Tab
         dw        4700h,VolHome            ; po‡ tek
         dw        4f00h,VolEnd             ; konec
         dw        4900h,VolHome            ; Page Up
         dw        8400h,VolHome            ; ^Page Up
         dw        5100h,VolEnd             ; Page Down
         dw        7600h,VolEnd             ; ^Page Down

         dw        1c0dh,VolEnt             ; ENTER
         dw        11bh,VolEsc              ; ESC

         dw        0,Volby2

; ------ jin  kl vesa - pokus o nalezen¡ jako hork  kl vesa

Volby2:  push      si                       ; adresa definice menu
         mov       dh,0                     ; ukazatel ‡¡sla polo‘ky
         mov       dl,bl                    ; £schova hledan‚ho znaku
         cmp       dl,"a"
         jb        Volby21
         cmp       dl,"z"
         ja        Volby21
         sub       dl,32                    ; korekce na velk‚ p¡smeno
Volby21: cld
         mov       ch,0
         mov       cl,ds:[si+1]             ; po‡et polo‘ek
         add       si,3                     ; adresa d‚lky nadpisu
         lodsb                              ; d‚lka nadpisu
         mov       ah,0
         add       si,ax                    ; adresa prvn¡ polo‘ky
Volby22: inc       dh                       ; zv˜¨en¡ ukazatele ‡¡sla polo‘ky
         lodsw                              ; hork  kl vesa + d‚lka
         mov       bx,ax                    ; BL <- hork  kl vesa, AH=d‚lka
         mov       bh,0
         mov       al,ds:[si+bx-1]          ; hork  kl vesa
         call      UpCase                   ; p©evod na velk‚ p¡smeno
         cmp       al,dl                    ; je to hledan˜ znak ?
         je        Volby25                  ; je to hledan˜ znak

         mov       bl,ah                    ; d‚lka textu polo‘ky (zde je BH=0)
         add       si,bx                    ; adresa n povˆdy
         lodsb                              ; d‚lka textu n povˆdy
         mov       bl,al                    ; d‚lka textu n povˆdy
         add       si,bx                    ; adresa dal¨¡ polo‘ky
         loop      Volby22                  ; dal¨¡ polo‘ka
                                            ; jinak je NZ = polo‘ka nenalezena

Volby25: pop       si
         jne       VolUp4                   ; polo‘ka nenalezena
         mov       ds:[si],dh               ; ‡¡slo nalezen‚ polo‘ky
         jmp       VolEnt                   ; volba polo‘ky

; ------ kurzor nahoru

VolUp:   dec       al                       ; sn¡‘en¡ ‡¡sla polo‘ky
         jnz       VolUp3                   ; nen¡ p©ete‡en¡ prvn¡ polo‘ky

; ------ posledn¡ polo‘ka

VolEnd:  mov       al,ah                    ; posledn¡ polo‘ka
VolUp3:  mov       ds:[si],al               ; nov  aktivn¡ polo‘ka
VolUp4:  jmp       Volby1

; ------ kurzor dol–

VolDwn:  inc       al
         cmp       al,ah                    ; p©ekro‡ena posledn¡ polo‘ka ?
         jbe       VolUp3                   ; nep©ekro‡ena posledn¡ polo‘ka

; ------ prvn¡ polo‘ka

VolHome: mov       al,1                     ; prvn¡ polo‘ka
         jmp       short VolUp3


; ------ p©eru¨en¡ voleb ESC

VolEsc:  xor       bx,bx                    ; p©¡znak p©eru¨en¡ volby ESC
         ret

; ------ konec voleb ENTER

VolEnt:  mov       bh,0
         mov       bl,ds:[si]               ; aktivn¡ zvolen  polo‘ka
         ret

Volby    ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ voleb menu DS:SI
; -----------------------------------------------------------------------------

DispVol  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es

; ------ p©¡prava registr–

         mov       es,ds:[SegmVRAM]         ; segment videopamˆti
         cld
         lodsw                              ; aktivn¡ polo‘ka a po‡et polo‘ek
         xchg      ax,dx                    ; DL<-akt.polo‘ka, DH<-po‡et polo‘ek
         lodsw                              ; AL<-d‚lka kurz., AH<-d‚lka nadpisu
         xchg      ax,bx                    ; BL<-d‚lka kurz., BH<-d‚lka nadpisu

; ------ ur‡en¡ adresy k dek¢dov n¡ textu nadpisu

         mov       ax,4*160+80-2            ; st©ed 4. © dku
         sub       al,bh                    ; zbytek na okraje
         and       al,not 1                 ; zarovn n¡ na sudou adresu
         xchg      ax,di                    ; DI <- adresa k dek¢dov n¡ nadpisu

; ------ dek¢dov n¡ nadpisu menu

         mov       ah,ds:[ColNadp]          ; barva nadpisu
         mov       al," "                   ; znak mezery
         stosw                              ; lev  mezera
DispVol1:lodsb                              ; na‡ten¡ znak nadpisu
         stosw                              ; ulo‘en¡ znaku do videopamˆti
         dec       bh                       ; sn¡‘en¡ ‡¡ta‡e znak–
         jnz       DispVol1                 ; dek¢dov n¡ dal¨¡ho znaku nadpisu
         mov       al," "                   ; znak mezery
         stosw                              ; prav  mezera

; ------ ur‡en¡ po‡ te‡n¡ adresy k zobrazen¡ polo‘ek voleb

         mov       al,25+2                  ; po‡et © dk– obrazovky + korekce
         sub       al,dh                    ; ode‡ten¡ po‡tu polo‘ek
         and       al,not 1                 ; zarovn n¡ na sudou
         mov       ah,160/2                 ; po‡et bajt– na © dek/2
         mul       ah                       ; offset po‡ te‡n¡ho © dku
         xchg      ax,di                    ; DI <- adresa po‡ te‡n¡ho © dku
         mov       ax,80                    ; d‚lka © dku
         sub       al,bl                    ; ode‡ten¡ d‚lky kurzoru = pozice
         and       al,not 1                 ; zarovn n¡ na sudou adresu
         add       di,ax                    ; p©id n¡ po‡ te‡n¡ pozice k adrese

; ------ p©¡prava k dek¢dov n¡ polo‘ky

         dec       bx                       ; d‚lka kurzoru - 1
DispVol2:lodsw                              ; AL<-hork˜ znak, AH<-d‚lka textu
         mov       ch,ah                    ; CH <- d‚lka textu
         mov       cl,bl                    ; CL <- d‚lka kurzoru
         sub       cl,ch                    ; zbytek na konec © dku
         ja        DispVl22                 ; d‚lka je OK
         mov       cl,1                     ; omezen¡ zbytku na 1 znak
DispVl22:mov       ah,0                     ; AX = pozice hork‚ho znaku
         xchg      bp,ax                    ; BP <- ‡¡ta‡ hork‚ho znaku

; ------ p©¡prava barvy polo‘ky

         mov       ah,ds:[ColMenu1]         ; bˆ‘n  barva polo‘ky
         mov       bh,ds:[ColMenu2]         ; barva vysv¡cen‚ho znaku polo‘ky
         dec       dl                       ; ‡¡ta‡ aktivn¡ polo‘ky
         jnz       DispVol3                 ; nen¡ aktivn¡ polo‘ka
         mov       ah,ds:[ColMenu3]         ; barva kurzoru
         mov       bh,ah                    ; vysv¡cen  barva kurzoru

; ------ dek¢dov n¡ textu polo‘ky

DispVol3:push      di
         mov       al," "                   ; £vodn¡ mezera
         stosw                              ; ulo‘en¡ £vodn¡ mezery
DispVol4:lodsb                              ; na‡ten¡ znaku k zobrazen¡
         dec       bp                       ; ‡¡ta‡ hork‚ho znaku
         jnz       DispVol5                 ; nen¡ hork˜ znak
         xchg      ah,bh                    ; vysv¡cen˜ znak
         stosw                              ; ulo‘en¡ vysv¡cen‚ho znaku
         xchg      ah,bh                    ; n vrat bˆ‘n‚ barvy polo‘ky
         jmp       short DispVol6
DispVol5:stosw                              ; ulo‘en¡ bˆ‘n‚ho znaku
DispVol6:dec       ch                       ; ‡¡ta‡ znak– textu
         jnz       DispVol4                 ; dek¢dov n¡ dal¨¡ho znaku
         mov       al," "                   ; koncov  mezera
         rep       stosw                    ; vymaz n¡ zbytku © dku
         pop       di                       ; n vrat adresy polo‘ky

; ------ dek¢dov n¡ n povˆdy

         cmp       dl,0                     ; je aktivn¡ polo‘ka ?
         jne       DispVol8                 ; nen¡ aktivn¡ polo‘ka
         call      DispHlp                  ; zobrazen¡ n povˆdy
         cld

; ------ p©¡prava pro dal¨¡ polo‘ku

DispVol8:lodsb                              ; d‚lka n povˆdy
         mov       ah,0
         add       si,ax                    ; adresa dal¨¡ polo‘ky
DispVl82:add       di,160                   ; posun o © dek
         dec       dh                       ; ‡¡ta‡ polo‘ek
         jnz       DispVol2                 ; dek¢dov n¡ dal¨¡ polo‘ky

; ------ n vrat registr–

DispVol9:pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispVol  ENDP

; -----------------------------------------------------------------------------
;        volba logick‚ho disku -> AL (CY=p©eru¨en¡ ESC)
; -----------------------------------------------------------------------------

VolLDsk  PROC      NEAR

; ------ test, zda je alespo¤ jeden disk

         cmp       byte ptr ds:[NumDisk],0  ; je nˆjak˜ disk ?
         je        VolLDsk2                 ; nen¡ ‘ dn˜ disk

; ------ zobrazen¡ logick˜ch disk–

VolLDsk1:call      DispLDsk                 ; zobrazen¡ logick˜ch disk–
         call      KurzOff                  ; vypnut¡ kurzoru
         call      InpChr                   ; vstup znaku z kl vesnice
         mov       al,ds:[LDisk]            ; aktivn¡ disk
         call      JumpBX                   ; skok na funkci

         dw        4b00h,VolLDsk5           ; kurzor vlevo
         dw        0f00h,VolLDsk5           ; Shift-TAB
         dw        4d00h,VolLDsk6           ; kurzor vpravo
         dw        0f09h,VolLDsk6           ; TAB
         dw        4700h,VolLDsk7           ; prvn¡ polo‘ka HOME
         dw        4f00h,VolLDsk8           ; posledn¡ polo‘ka END

         dw        1c0dh,VolLDsk4           ; potvrzen¡ volby ENTER
         dw        11bh,VolLDsk2            ; p©eru¨en¡ ESC
         dw        0,VolLDsk3               ; jin  kl vesa

; ------ p©eru¨en¡ volby ESC

VolLDsk2:stc                                ; p©¡znak p©eru¨en¡ operace
         ret

; ------ jin  kl vesa - pokus o nalezen¡ disku v tabulce

VolLDsk3:mov       al,bl                    ; zadan˜ znak
         call      UpCase                   ; konverze na velk‚ p¡smeno
         sub       al,"A"                   ; korekce na ‡¡slo disku
         call      SrcDisk                  ; nalezen¡ disku v tabulce
         jc        VolLDsk1                 ; disk nenalezen
         mov       ds:[LDisk],al            ; nov˜ aktivn¡ disk

; ------ potvrzen¡ volby ENTER

VolLDsk4:clc                                ; p©¡znak volby OK
         ret

; ------ kurzor vlevo

VolLDsk5:call      SrcDisk                  ; nalezen¡ disku v tabulce
         dec       bx                       ; sn¡‘en¡ offsetu
         js        VolLDsk8                 ; p©ete‡en¡ - posledn¡ polo‘ka
VolLDs53:mov       al,ds:[bx+TabDisk]       ; nov˜ aktivn¡ disk
VolLDs54:mov       ds:[LDisk],al            ; nov˜ aktivn¡ disk
         jmp       short VolLDsk1

; ------ kurzor vpravo

VolLDsk6:call      SrcDisk                  ; nalezen¡ disku v tabulce
         inc       bx                       ; zv˜¨en¡ offsetu
         cmp       bl,ds:[NumDisk]          ; p©ete‡en¡ konce ?
         jb        VolLDs53                 ; polo‘ka plat¡ - nov˜ aktivn¡ disk

; ------ prvn¡ polo‘ka

VolLDsk7:mov       al,ds:[TabDisk]          ; prvn¡ polo‘ka
         jmp       short VolLDs54           ; nov˜ aktivn¡ disk

; ------ posledn¡ polo‘ka

VolLDsk8:xor       bx,bx
         mov       bl,ds:[NumDisk]          ; po‡et disk–
         dec       bx                       ; posledn¡ disk
         jmp       short VolLDs53           ; nov˜ aktivn¡ disk

VolLDsk  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ voleb logick˜ch disk–
; -----------------------------------------------------------------------------

DispLDsk PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ p©¡prava registr–

         mov       es,ds:[SegmVRAM]         ; segment videopamˆti

; ------ zobrazen¡ nadpisu

         mov       si,offset NadLDisk       ; nadpis k volbˆ logick‚ho disku
         call      DispNadp                 ; zobrazen¡ nadpisu

; ------ adresa k dek¢dov n¡ disk–

         cld
         mov       si,offset TabDisk        ; tabulka disk–
         mov       di,13*160 + 2*40         ; asi tak st©ed obrazovky
         xor       ax,ax
         mov       al,ds:[NumDisk]          ; po‡et disk–
         mov       cx,ax                    ; po‡et disk–
         jcxz      DispLDs9                 ; nen¡ ‘ dn˜ disk
         shl       ax,1                     ; po‡et disk– * 2
         cmp       cl,19                    ; maxim ln¡ po‡et disk–
         ja        DispLDs4                 ; je 20 disk– nebo v¡ce
         shl       ax,1                     ; po‡et disk– * 4

; ------ zobrazen¡ logick˜ch disk– (do po‡tu 19)

         sub       di,ax                    ; za‡ tek k zobrazen¡ disk–
DispLDs2:lodsb                              ; na‡ten¡ ‡¡sla disku
         mov       ah,ds:[ColMenu3]         ; barva kurzoru
         mov       dh,ah
         cmp       al,ds:[LDisk]            ; je to aktivn¡ disk ?
         je        DispLDs3                 ; je to aktivn¡ disk
         mov       ah,ds:[ColMenu2]         ; bˆ‘n  barva vysv¡cen 
         mov       dh,ds:[ColMenu1]         ; bˆ‘n  barva
DispLDs3:push      ax
         mov       al," "                   ; lev˜ okraj
         stosw                              ; ulo‘en¡ lev‚ mezery
         pop       ax
         add       al,"A"                   ; korekce na znak ASCII
         stosw                              ; ulo‘en¡ ozna‡en¡ disku
         mov       al,":"
         xchg      ah,dh
         stosw                              ; oddˆlova‡ disku
         xchg      ah,dh
         mov       al," "                   ; prav˜ okraj
         stosw                              ; ulo‘en¡ prav‚ho okraje
         loop      DispLDs2                 ; dek¢dov n¡ dal¨¡ho disku
         jmp       short DispLDs9

; ------ zobrazen¡ logick˜ch disk– (po‡et 20 a v¡ce)

DispLDs4:sub       di,ax                    ; za‡ tek k zobrazen¡ disk–
DispLDs5:lodsb                              ; na‡ten¡ ‡¡sla disku
         mov       ah,ds:[ColMenu3]         ; barva kurzoru
         mov       dh,ah
         cmp       al,ds:[LDisk]            ; je to aktivn¡ disk ?
         je        DispLDs6                 ; je to aktivn¡ disk
         mov       ah,ds:[ColMenu2]         ; bˆ‘n  barva vysv¡cen 
         mov       dh,ds:[ColMenu1]         ; bˆ‘n  barva
DispLDs6:add       al,"A"                   ; korekce na znak ASCII
         stosw                              ; ulo‘en¡ ozna‡en¡ disku
         mov       al,":"
         xchg      ah,dh
         stosw                              ; oddˆlova‡ disku
         loop      DispLDs5                 ; dek¢dov n¡ dal¨¡ho disku

; ------ zobrazen¡ n povˆdy

DispLDs9:mov       si,offset HlpLDisk
         call      DispHlp                  ; zobrazen¡ n povˆdy

; ------ n vrat registr–

         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

DispLDsk ENDP

; -----------------------------------------------------------------------------
;        volba fyzick‚ho disku
; -----------------------------------------------------------------------------

VolFDsk  PROC      NEAR

; ------ test, zda je alespo¤ jeden disk

         cmp       byte ptr ds:[NumDisk],0  ; je nˆjak˜ disk ?
         je        VolFDsk2                 ; nen¡ ‘ dn˜ disk

; ------ zobrazen¡ fyzick˜ch disk–

VolFDsk1:call      DispFDsk                 ; zobrazen¡ fyzick˜ch disk–
         call      KurzOff                  ; vypnut¡ kurzoru
         call      InpChr                   ; vstup znaku z kl vesnice
         call      JumpBX                   ; skok na funkci

         dw        4800h,VolFDsk5           ; kurzor nahoru
         dw        0f00h,VolFDsk5           ; Shift-TAB
         dw        5000h,VolFDsk6           ; kurzor dol–
         dw        0f09h,VolFDsk6           ; TAB
         dw        4700h,VolFDsk7           ; prvn¡ polo‘ka HOME
         dw        4f00h,VolFDsk8           ; posledn¡ polo‘ka END

         dw        1c0dh,VolFDsk4           ; potvrzen¡ volby ENTER
         dw        11bh,VolFDsk2            ; p©eru¨en¡ ESC
         dw        0,VolFDsk3               ; jin  kl vesa

; ------ p©eru¨en¡ volby ESC

VolFDsk2:stc                                ; p©¡znak p©eru¨en¡ operace
         ret

; ------ jin  kl vesa

VolFDsk3:mov       al,bl                    ; zadan˜ znak
         call      UpCase                   ; konverze na velk‚ p¡smeno
         mov       bh,0
         mov       bl,al
         sub       bl,"A"                   ; korekce na ‡¡slo disku
         cmp       bl,ds:[NumDisk]          ; je platn‚ ozna‡en¡ disku ?
         jae       VolFDsk1                 ; neplatn‚ ozna‡en¡ disku
         mov       al,ds:[bx+TabDisk]       ; zvolen˜ disk
         mov       ds:[FDisk],al            ; nov˜ aktivn¡ disk

; ------ potvrzen¡ volby ENTER

VolFDsk4:mov       al,ds:[FDisk]            ; zvolen˜ aktivn¡ disk
         clc                                ; p©¡znak volby OK
         ret

; ------ kurzor nahoru

VolFDsk5:mov       al,ds:[FDisk]            ; aktivn¡ disk
         call      SrcDisk                  ; nalezen¡ disku v tabulce
         dec       bx                       ; sn¡‘en¡ offsetu
         js        VolFDsk8                 ; p©ete‡en¡ - posledn¡ polo‘ka
VolFDs53:mov       al,ds:[bx+TabDisk]       ; nov˜ aktivn¡ disk
VolFDs54:mov       ds:[FDisk],al
         jmp       short VolFDsk1

; ------ kurzor dol–

VolFDsk6:mov       al,ds:[FDisk]            ; aktivn¡ disk
         call      SrcDisk                  ; nalezen¡ disku v tabulce
         inc       bx                       ; zv˜¨en¡ offsetu
         cmp       bl,ds:[NumDisk]          ; p©ete‡en¡ konce ?
         jb        VolFDs53                 ; polo‘ka plat¡ - nov˜ aktivn¡ disk

; ------ prvn¡ polo‘ka

VolFDsk7:mov       al,ds:[TabDisk]          ; prvn¡ polo‘ka
         jmp       short VolFDs54           ; nov˜ aktivn¡ disk

; ------ posledn¡ polo‘ka

VolFDsk8:xor       bx,bx
         mov       bl,ds:[NumDisk]
         dec       bx
         jmp       short VolFDs53           ; nov˜ aktivn¡ disk

VolFDsk  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ fyzick‚ho disku
; -----------------------------------------------------------------------------

DispFDsk PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ zobrazen¡ nadpisu

         mov       si,offset NadFDisk       ; nadpis k volbˆ fyzick‚ho disku
         call      DispNadp                 ; zobrazen¡ nadpisu

; ------ zobrazen¡ n povˆdy

         mov       si,offset HlpFDisk
         call      DispHlp                  ; zobrazen¡ n povˆdy

; ------ adresa ve videopamˆti

         mov       es,ds:[SegmVRAM]         ; segment videopamˆti
         mov       dl,ds:[NumDisk]          ; po‡et disk–
         mov       al,160                   ; po‡et bajt– na © dek / 2
         mul       dl                       ; korekce adresy po‡ tku
         mov       di,offset(FlopTxt-WinTxt)+160*13+2*40-2*3 ; st©edn¡ © dek
         sub       di,ax                    ; korekce adresy pro vyst©edˆn¡

; ------ p©¡prava registr–

         cld
         mov       si,offset TabDisk        ; tabulka disk–
         cmp       dl,0                     ; je nˆjak˜ disk ?
         je        DispFDs9                 ; nen¡ ‘ dn˜ disk

; ------ ur‡en¡ barvy polo‘ky

DispFDs2:push      di
         push      si
         mov       ah,ds:[ColMenu1]         ; bˆ‘n  barva
         mov       dh,ds:[ColMenu2]         ; vysv¡cen  polo‘ka
         mov       al,ds:[si]               ; disk
         cmp       al,ds:[FDisk]            ; je to aktivn¡ disk ?
         jne       DispFDs3                 ; nen¡ to aktivn¡ disk
         mov       ah,ds:[ColMenu3]         ; barva kurzoru
         mov       dh,ah

; ------ zobrazen¡ ozna‡en¡ disku

DispFDs3:mov       al," "
         stosw
         mov       al,"("
         stosw
         xchg      ah,dh
         mov       cx,si
         sub       cx,offset TabDisk
         mov       al,cl
         add       al,"A"                   ; korekce na p¡smeno
         stosw
         xchg      ah,dh

; ------ zobrazen¡ zbytku textu

         mov       al,ds:[si]               ; ‡¡slo disku
         mov       si,offset FlopTxt        ; text "Floppy disk"
         test      al,80h                   ; je to pevn˜ disk ?
         jz        DispFDs4                 ; je to disketa
         mov       si,offset WinTxt         ; text "Winchester"
DispFDs4:and       al,0fh                   ; ‡¡slo relativnˆ
         add       al,"0"                   ; korekce na ‡¡slici
         mov       ds:[FlopTxt0],al
         mov       ds:[WinTxt0],al
         mov       cx,offset(WinTxt-FlopTxt) ; d‚lka textu
DispFDs5:lodsb
         stosw
         loop      DispFDs5

; ------ p©¡prava pro dal¨¡ polo‘ku

         pop       si
         pop       di
         add       di,2*160                 ; adresa dal¨¡ho © dku
         inc       si
         dec       dl                       ; ‡¡ta‡ polo‘ek
         jnz       DispFDs2                 ; dal¨¡ © dek

; ------ n vrat registr–

DispFDs9:pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispFDsk ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ nadpisu DS:SI
; -----------------------------------------------------------------------------

DispNadp PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      si
         push      di
         push      es

; ------ ur‡en¡ adresy k dek¢dov n¡ textu nadpisu

         mov       es,ds:[SegmVRAM]         ; segment videopamˆti
         mov       di,4*160+2*40            ; st©ed © dku
         cld
         mov       ah,0
         lodsb                              ; d‚lka textu nadpisu
         mov       cx,ax
         add       al,2                     ; p©i‡ten¡ mezer jako okraje
         add       al,1
         and       al,not 1
         sub       di,ax                    ; adresa

; ------ dek¢dov n¡ nadpisu menu

         mov       ah,ds:[ColNadp]          ; barva nadpisu
         mov       al," "                   ; znak mezery
         stosw                              ; lev  mezera
DispNdp1:lodsb                              ; na‡ten¡ znak nadpisu
         stosw                              ; ulo‘en¡ znaku do videopamˆti
         loop      DispNdp1                 ; dal¨¡ znak
         mov       al," "                   ; znak mezery
         stosw                              ; prav  mezera

; ------ n vrat registr–

         pop       es
         pop       di
         pop       si
         pop       cx
         pop       ax
         ret

DispNadp ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ n povˆdy DS:SI
; -----------------------------------------------------------------------------

DispHlp  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      si
         push      di
         push      es

; ------ p©¡prava registr–

         mov       es,ds:[SegmVRAM]         ; segment videopamˆti
         mov       di,23*160+2              ; adresa k ulo‘en¡ n povˆdy
         cld
         lodsb                              ; d‚lka n povˆdy
         xchg      ax,bx                    ; BL <- d‚lka textu n povˆdy
         mov       cx,78                    ; d‚lka © dku
         sub       cl,bl                    ; zbytek na okraje
         shr       cl,1                     ; polovina na okraje
         mov       bh,cl                    ; £schova d‚lky okraje
         adc       bh,0                     ; lich˜ znak vpravo

; ------ dek¢dov n¡ lev‚ mezery

         mov       ah,ds:[ColRam]           ; barva podkladu
         mov       al," "                   ; znak mezery
         rep       stosw                    ; dek¢dov n¡ £vodn¡ mezery

; ------ dek¢dov n¡ textu n povˆdy

         mov       cl,bl                    ; d‚lka textu n povˆdy
         mov       ah,ds:[ColHlp]           ; barva n povˆdy
DispHlp7:lodsb                              ; na‡ten¡ znaku textu n povˆdy
         stosw                              ; ulo‘en¡ znaku do videopamˆti
         loop      DispHlp7                 ; dek¢dov n¡ dal¨¡ho znaku

; ------ dek¢dov n¡ prav‚ mezery

         mov       ah,ds:[ColRam]           ; barva podkladu
         mov       al," "                   ; znak mezery
         mov       cl,bh                    ; d‚lka prav‚ho okraje
         rep       stosw                    ; dek¢dov n¡ z vˆre‡n‚ mezery

; ------ n vrat registr–

         pop       es
         pop       di
         pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

DispHlp  ENDP

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                         Obsluha logick‚ho disku
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;þ
; -----------------------------------------------------------------------------
;        inicializace specifikace adres ©e
; -----------------------------------------------------------------------------

InitPath PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ na‡ten¡ aktivn¡ho adres ©e disku

         mov       al,ds:[LDisk]            ; aktivn¡ disk
         mov       dl,al                    ; £schova ‡¡sla disku
         add       al,"A"                   ; korekce na znak ASCII
         mov       si,offset Soubor+3       ; buffer cesty
         mov       ah,":"                   ; oddˆlova‡ disku
         mov       ds:[si-3],ax             ; ulo‘en¡ ozna‡en¡ disku
         mov       word ptr ds:[si-1],"\"   ; ozna‡en¡ ROOT
         inc       dx                       ; korekce ‡¡sla disku
         mov       ah,47h
         int       21h                      ; na‡ten¡ aktivn¡ho adres ©e disku

; ------ zji¨tˆn¡ d‚lky textu

         push      ds
         pop       es
         mov       di,offset Soubor
         mov       al,0
         cld
         mov       cx,128                   ; max. d‚lka
         repne     scasb                    ; nalezen¡ konce cesty
         sub       cx,127
         neg       cx                       ; d‚lka textu
         mov       ds:[SouborN],cx          ; d‚lka textu

; ------ p©id n¡ specifikace *.*

         mov       si,offset All            ; specifikace "*.*"
         call      AddFile                  ; p©id n¡ specifikace "*.*"

; ------ n vrat registr–

         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

InitPath ENDP

; -----------------------------------------------------------------------------
;        p©id n¡ textu ASCIIZ DS:SI k cestˆ
; -----------------------------------------------------------------------------

AddFile  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      si
         push      di
         push      es

; ------ zaji¨tˆn¡ koncov‚ho lom¡tka

         cld
         push      ds
         pop       es
         mov       di,ds:[SouborN]          ; po‡et znak– v bufferu
         cmp       di,110                   ; asi tak maxim ln¡ d‚lka
         jae       AddFile9                 ; buffer je ji‘ pln˜
         add       di,offset Soubor         ; adresa konce textu v bufferu
         cmp       byte ptr ds:[di-1],"\"   ; kon‡¡ text lom¡tkem ?
         je        AddFile2                 ; kon‡¡ lom¡tkem
         mov       byte ptr ds:[di],"\"     ; koncov‚ lom¡tko
         inc       di

; ------ p©id n¡ textu

AddFile2:lodsb
         stosb
         cmp       al,0                     ; konec textu ?
         jne       AddFile2                 ; dal¨¡ znak
         sub       di,offset Soubor+1       ; nov  d‚lka textu
         mov       ds:[SouborN],di          ; nov  d‚lka textu

; ------ n vrat registr–

AddFile9:pop       es
         pop       di
         pop       si
         pop       ax
         ret

AddFile  ENDP

; -----------------------------------------------------------------------------
;        zru¨en¡ posledn¡ho souboru z cesty
; -----------------------------------------------------------------------------

SubFile  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      si

; ------ adresa konce textu

         mov       si,ds:[SouborN]          ; po‡et znak– v bufferu
         add       si,offset Soubor         ; adresa konce textu v bufferu

; ------ nalezen¡ dal¨¡ho lom¡tka

SubFile2:dec       si
         cmp       byte ptr ds:[si],"\"
         jne       SubFile2

; ------ ozna‡en¡ konce textu

         cmp       byte ptr ds:[si-1],":"
         jne       SubFile3
         inc       si
SubFile3:mov       byte ptr ds:[si],0       ; konec textu
         sub       si,offset Soubor         ; nov  d‚lka textu
         mov       ds:[SouborN],si          ; nov  d‚lka textu

; ------ n vrat registr–

         pop       si
         pop       ax
         ret

SubFile  ENDP

; -----------------------------------------------------------------------------
;        konverze jm‚na polo‘ky FCB (ES:SI) na ASCIIZ (SoubName)
; -----------------------------------------------------------------------------

FCBAsc   PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      si
         push      di

; ------ stanoven¡ d‚lky jm‚na souboru

         inc       si
         mov       al,ds:[Soubor]           ; ozna‡en¡ disku
         mov       ds:[SoubNm0],al          ; ozna‡en¡ disku
         mov       di,offset SoubName       ; buffer k ulo‘en¡ jm‚na
         mov       bx,8                     ; inicializa‡n¡ d‚lka jm‚na
FCBAsc1: cmp       byte ptr es:[si+bx-1]," " ; je mezera ?
         jne       FCBAsc2                  ; nen¡ mezera - je platn˜ znak
         dec       bx                       ; sn¡‘en¡ d‚lky jm‚na
         jnz       FCBAsc1

; ------ p©enesen¡ jm‚na souboru

FCBAsc2: mov       cx,bx                    ; d‚lka jm‚na polo‘ky
         jcxz      FCBAsc4                  ; nen¡ ‘ dn˜ znak jm‚na polo‘ky
         push      si
FCBAsc3: mov       al,es:[si]
         mov       ds:[di],al
         inc       si
         inc       di
         loop      FCBAsc3                  ; dal¨¡ znak
         pop       si

; ------ stanoven¡ d‚lky p©¡pony

FCBAsc4: add       si,8                     ; za‡ tek p©¡pony jm‚na souboru
         mov       bx,3                     ; inicializa‡n¡ d‚lka p©¡pony
FCBAsc5: cmp       byte ptr es:[si+bx-1]," " ; je platn˜ znak ?
         jne       FCBAsc6                  ; nalezen platn˜ znak
         dec       bx                       ; sn¡‘en¡ d‚lky p©¡pony
         jnz       FCBAsc5                  ; je dal¨¡ znak

; ------ p©enesen¡ p©¡pony souboru

FCBAsc6: mov       cx,bx                    ; d‚lka p©¡pony jm‚na souboru
         jcxz      FCBAsc8                  ; nen¡ ‘ dn˜ znak
         mov       byte ptr ds:[di],"."     ; oddˆlovac¡ te‡ka p©¡pony jm‚na
         inc       di
FCBAsc7: mov       al,es:[si]
         mov       ds:[di],al
         inc       si
         inc       di
         loop      FCBAsc7                  ; dal¨¡ znak
FCBAsc8: mov       byte ptr ds:[di],0       ; ozna‡en¡ konce jm‚na souboru

; ------ n vrat registr–

         pop       di
         pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

FCBAsc   ENDP

; -----------------------------------------------------------------------------
;        poskytnut¡ aktivn¡ho souboru ES:SI (CY=nen¡)
; -----------------------------------------------------------------------------

GetAFil  PROC      NEAR

         mov       es,ds:[BuffSegm]         ; buffer soubor–
         mov       si,ds:[FileAkt]          ; aktivn¡ polo‘ka
         cmp       si,ds:[FileNum]          ; je platn  polo‘ka ?
         cmc
         jb        GetAFil3                 ; neplatn  polo‘ka
         shl       si,1                     ; offset v tabulce index–
         mov       si,es:[si]               ; adresa polo‘ky
GetAFil3:ret

GetAFil  ENDP

; -----------------------------------------------------------------------------
;        inicializace tabulky logick˜ch disk– pro souborov‚ operace
; -----------------------------------------------------------------------------

IniLDsk  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      di
         push      es

; ------ £schova aktivn¡ho disku

         call      GetDisk                  ; poskytnut¡ aktivn¡ho disku
         test      byte ptr ds:[Param],bit1 ; byl logick˜ disk ji‘ zvolen ?
         jnz       IniLDsk0                 ; logick˜ disk ji‘ byl zvolen
         mov       ds:[LDisk],al            ; p©ednastaven¡ logick‚ho disku
         or        byte ptr ds:[Param],bit1 ; p©¡znak ur‡en¡ logick‚ho disku
IniLDsk0:push      ax                       ; £schova aktivn¡ho disku

; ------ inicializace ukazatel–

         mov       byte ptr ds:[NumDisk],0  ; nen¡ ‘ dn˜ disk v tabulce
         push      ds
         pop       es                       ; ES <- DS
         mov       di,offset TabDisk        ; tabulka disk–
         mov       al,0                     ; ‡¡slo prvn¡ho disku

; ------ pokus o nastaven¡ jednoho disku

IniLDsk1:call      SetDisk                  ; pokus o nastaven¡ disku
         jc        IniLDsk5                 ; nen¡ to platn˜ disk

; ------ ulo‘en¡ ‡¡sla disku

         cld
         stosb                              ; ulo‘en¡ ‡¡sla disku
         inc       byte ptr ds:[NumDisk]    ; zv˜¨en¡ ‡¡ta‡e disk–

; ------ p©¡prava pro dal¨¡ disk

IniLDsk5:inc       ax                       ; zv˜¨en¡ ukazatele ‡¡sla disku
         cmp       al,31                    ; maxim ln¡ ‡¡slo disku
         jbe       IniLDsk1                 ; test dal¨¡ho disku
         mov       al,0ffh
         cld
         stosb                              ; konec tabulky

; ------ n vrat aktivn¡ho disku

         pop       ax
         call      SetDisk                  ; nastaven¡ p–vodn¡ho aktiv. disku

; ------ n vrat registr–

         pop       es
         pop       di
         pop       ax
         call      KorLDsk                  ; korekce logick‚ho disku
         ret

IniLDsk  ENDP

; -----------------------------------------------------------------------------
;        inicializace tabulky logick˜ch disk– pro adres ©ov‚ operace
; -----------------------------------------------------------------------------

IniADsk  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      di
         push      es

; ------ £schova aktivn¡ho disku

         call      GetDisk                  ; poskytnut¡ aktivn¡ho disku
         test      byte ptr ds:[Param],bit1 ; byl logick˜ disk ji‘ zvolen ?
         jnz       IniADsk0                 ; logick˜ disk ji‘ byl zvolen
         mov       ds:[LDisk],al            ; p©ednastaven¡ logick‚ho disku
         or        byte ptr ds:[Param],bit1 ; p©¡znak ur‡en¡ logick‚ho disku
IniADsk0:push      ax                       ; £schova aktivn¡ho disku

; ------ inicializace ukazatel–

         mov       byte ptr ds:[NumDisk],0  ; nen¡ ‘ dn˜ disk v tabulce
         push      ds
         pop       es                       ; ES <- DS
         mov       di,offset TabDisk        ; tabulka disk–
         mov       al,0                     ; ‡¡slo prvn¡ho disku

; ------ pokus o nastaven¡ jednoho disku

IniADsk1:call      SetDisk                  ; pokus o nastaven¡ disku
         jc        IniADsk5                 ; nen¡ to platn˜ disk

; ------ test platnosti disku DOS

         call      TestDisk                 ; test platnosti disku DOS
         jc        IniADsk5                 ; disk je neplatn˜

; ------ ulo‘en¡ ‡¡sla disku

         cld
         stosb                              ; ulo‘en¡ ‡¡sla disku
         inc       byte ptr ds:[NumDisk]    ; zv˜¨en¡ ‡¡ta‡e disk–

; ------ p©¡prava pro dal¨¡ disk

IniADsk5:inc       ax                       ; zv˜¨en¡ ukazatele ‡¡sla disku
         cmp       al,31                    ; maxim ln¡ ‡¡slo disku
         jbe       IniADsk1                 ; test dal¨¡ho disku
         mov       al,0ffh
         cld
         stosb                              ; konec tabulky

; ------ n vrat aktivn¡ho disku

         pop       ax
         call      SetDisk                  ; nastaven¡ p–vodn¡ho aktiv. disku

; ------ n vrat registr–

         pop       es
         pop       di
         pop       ax
         call      KorLDsk                  ; korekce logick‚ho disku
         ret

IniADsk  ENDP

; -----------------------------------------------------------------------------
;        korekce logick‚ho disku (test, zda je v tabulce)
; -----------------------------------------------------------------------------

KorLDsk  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx

; ------ nalezen¡ logick‚ho disku v tabulce

         mov       al,ds:[LDisk]            ; logick˜ disk
         call      SrcDisk                  ; nalezen¡ disku v tabulce
         mov       al,ds:[bx+TabDisk]       ; aktivn¡ nebo nejbli‘¨¡ disk
         mov       ds:[LDisk],al            ; nejbli‘¨¡ disk v tabulce

; ------ n vrat registr–

         pop       bx
         pop       ax
         ret

KorLDsk  ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ adres ©e DS:SI (jm‚no ASCIIZ)
; -----------------------------------------------------------------------------

SetDir   PROC      NEAR

; ------ £schova registr–

         push      ax
         push      dx

; ------ nastaven¡ po‘adovan‚ho adres ©e

         mov       dx,si                    ; jm‚no po‘adovan‚ho adres ©e
         mov       ah,3bh
         int       21h                      ; nastaven¡ nov‚ho adres ©e

; ------ n vrat registr–

         pop       dx
         pop       ax
         ret

SetDir   ENDP

; -----------------------------------------------------------------------------
;        Poskytnut¡ aktivn¡ho disku -> AL (0=A, 1=B, ...)
; -----------------------------------------------------------------------------

GetDisk  PROC      NEAR

         push      dx
         push      ax
         mov       ah,19h                   ; funkce poskytnut¡ aktivn¡ho disku
         int       21h                      ; poskytnut¡ aktivn¡ho disku
         mov       dl,al                    ; ‡¡slo aktivn¡ho disku
         pop       ax
         mov       al,dl                    ; ‡¡slo aktivn¡ho disku
         pop       dx
         ret

GetDisk  ENDP

; -----------------------------------------------------------------------------
;        Nastaven¡ aktivn¡ho disku AL (CY=neplatn‚ ‡¡slo disku)
; -----------------------------------------------------------------------------

SetDisk  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      dx

; ------ £schova p–vodn¡ho aktivn¡ho disku

         mov       dl,al                    ; po‘adovan˜ nov˜ disk
         mov       ah,19h                   ; funkce poskytnut¡ aktivn¡ho disku
         int       21h                      ; poskytnut¡ aktivn¡ho disku
         mov       dh,al                    ; ‡¡slo p–vodn¡ho aktivn¡ho disku

; ------ nastaven¡ po‘adovan‚ho disku

         mov       ah,0eh                   ; funkce nastaven¡ nov‚ho disku
         int       21h                      ; nastaven¡ nov‚ho disku

; ------ kontrola, zda byl disk nastaven

         mov       ah,19h                   ; funkce poskytnut¡ aktivn¡ho disku
         int       21h                      ; poskytnut¡ aktivn¡ho disku
         cmp       al,dl                    ; byl disk spr vnˆ nastaven ?
         jne       SetDisk4                 ; neplatn˜ disk

; ------ test disku slu‘bou IOCTL

         cmp       word ptr ds:[VerzeOS],300h ; je verze syst‚mu alespo¤ 3.00 ?
         jb        SetDisk3                 ; n¡zk  verze syst‚mu - netestuje se
         push      ax
         push      dx
         mov       bl,al                    ; ‡¡slo disku
         inc       bx                       ; korekce ‡¡sla disku
         mov       ax,4408h                 ; funkce poskytnut¡ typu disku
         int       21h                      ; poskytnut¡ typu disku
         cmp       ax,0fh                   ; chyba - neplatn˜ disk ?
         pop       dx
         pop       ax
SetDisk3:clc
         jne       SetDisk5                 ; disk je platn˜ OK

; ------ neplatn˜ disk - navr cen¡ p–vodn¡ho disku

SetDisk4:mov       dl,dh                    ; p–vodn¡ aktivn¡ disk
         mov       ah,0eh                   ; funkce nastaven¡ aktivn¡ho disku
         int       21h                      ; nastaven¡ p–vodn¡ho aktiv. disku
         stc                                ; p©¡znak chyby - neplatn˜ disk

; ------ n vrat registr–

SetDisk5:pop       dx
         pop       bx
         pop       ax
         ret

SetDisk  ENDP

; -----------------------------------------------------------------------------
;        test platnosti disku DOS AL (CY=disk je neplatn˜)
; -----------------------------------------------------------------------------

TestDisk PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ poskytnut¡ seznamu seznam–

         call      GetLList                 ; poskytnut¡ seznamu seznam–
         cmc
         jnc       TestDsk9                 ; seznam nep©¡stupn˜ - asi OK

; ------ nalezen¡ adresy definice disku

         les       si,es:[si]               ; adresa prvn¡ho diskov‚ho za©¡zen¡
         mov       cx,32                    ; maxim ln¡ po‡et testovan˜ch disk–
TestDsk2:cmp       si,-1eh                  ; je platn  adresa ?
         ja        TestDsk9                 ; neplatn  adresa - asi OK
         cmp       al,es:[si]               ; kontrola ‡¡sla disku
         je        TestDsk9                 ; je to disk OK
         cmp       word ptr ds:[VerzeOS],400h ; je verze syst‚mu 4.00 ?
         jb        TestDsk4                 ; je ni‘¨¡ verze syst‚mu
         inc       si                       ; pro DOS 4 bude offset 19h
TestDsk4:les       si,es:[si+18h]           ; adresa dal¨¡ho za©¡zen¡
         cmp       si,-1                    ; je to posledn¡ za©¡zen¡ ?
         loopne    TestDsk2                 ; test dal¨¡ho za©¡zen¡
         stc                                ; p©¡znak neplatn‚ho disku

; ------ n vrat registr–

TestDsk9:pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

TestDisk ENDP

; -----------------------------------------------------------------------------
;        poskytnut¡ seznamu seznam– -> ES:SI (CY=seznam nen¡ k dispozici)
; -----------------------------------------------------------------------------

GetLList PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx

; ------ poskytnut¡ seznamu seznam–

         mov       bx,-1                    ; inicializace pro kontrolu
         push      cs
         pop       es                       ; tato hodnota je nepravdˆpodobn 
         push      ds
         mov       ah,52h
         int       21h                      ; poskytnut¡ seznamu seznam–
         pop       ds
         mov       si,bx                    ; offset adresy

; ------ kontrola navr cen‚ho stavu

         cmp       bx,-20h
         ja        GetLLst8                 ; neobsluhovan  funkce
         mov       ax,es                    ; navr cen˜ segment
         mov       bx,cs
         cmp       ax,bx                    ; zmˆnˆn segment ?
         clc                                ; p©¡znak operace OK
         jne       GetLLst9                 ; operace OK - seznam platn˜

; ------ n vrat registr–

GetLLst8:stc                                ; p©¡znak chyby
GetLLst9:pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

GetLList ENDP

; -----------------------------------------------------------------------------
;        poskytnut¡ seznamu diskov˜ch parametr– aktiv. logick‚ho disku -> ES:SI
;        CY=seznam nen¡ k dispozici (nekompatibiln¡ syst‚m nebo neplatn˜ disk)
; -----------------------------------------------------------------------------

GetLParm PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx

; ------ poskytnut¡ seznamu parametr– disku

         mov       dl,ds:[LDisk]            ; aktivn¡ logick˜ disk
         push      dx
         push      ds
         mov       bx,-1                    ; p©ednastaven¡ na nesmysl
         inc       dx                       ; korekce ‡¡sla disku
         mov       ax,32ffh
         int       21h                      ; poskytnut¡ seznamu seznam–
         mov       si,bx                    ; offset adresy
         push      ds
         pop       es                       ; ES <- DS
         pop       ds
         pop       dx

; ------ kontrola navr cen‚ho stavu

         cmp       al,0ffh                  ; neplatn˜ disk ?
         je        GetLPrm8                 ; neplatn˜ disk
         mov       cx,es                    ; navr cen˜ segment
         mov       ax,cs                    ; tento segment byl p©ednastaven
         cmp       ax,cx                    ; zmˆnˆn segment ?
         je        GetLPrm8                 ; nezmˆnˆn - adresa neplat¡
         jcxz      GetLPrm8                 ; 0 tak‚ neplat¡
         cmp       si,0ff00h                ; maxim ln¡ adresa
         jae       GetLPrm8                 ; adresa neplat¡
         inc       cx                       ; je segment FFFF ?
         jz        GetLPrm8                 ; segment FFFF neplat¡
         cmp       dl,es:[si]               ; souhlas¡ ‡¡slo disku ?
         je        GetLPrm9                 ; adresa plat¡ OK

; ------ n vrat registr–

GetLPrm8:stc                                ; p©¡znak chyby
GetLPrm9:pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

GetLParm ENDP

; -----------------------------------------------------------------------------
;        nalezen¡ disku AL v tabulce disk– (BX=offset v tab.disk–, CY=nenalezen)
; -----------------------------------------------------------------------------

SrcDisk  PROC      NEAR

; ------ £schova registr–

         push      cx

; ------ nalezen¡ disku v tabulce

         xor       bx,bx                    ; offset v tabulce disk–
         xor       cx,cx
         mov       cl,ds:[NumDisk]          ; po‡et disk–
         jcxz      SrcDisk8                 ; nen¡ ‘ dn˜ disk
SrcDisk1:cmp       byte ptr ds:[bx+TabDisk],al ; nalezen disk ?
         je        SrcDisk9                 ; disk nalezen OK
         cmp       al,byte ptr ds:[bx+TabDisk+1] ; bude dal¨¡ disk ?
         jb        SrcDisk9                 ; nebude dal¨¡ disk
         inc       bx                       ; zv˜¨en¡ ukazatele v tabulce
         loop      SrcDisk1                 ; test dal¨¡ho disku
SrcDisk8:stc                                ; p©¡znak nenalezen¡ disku

; ------ n vrat registr–

SrcDisk9:pop       cx
         ret

SrcDisk  ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ obsahu adres ©e
; -----------------------------------------------------------------------------

ReadDir  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es

; ------ p©¡prava registr–

         test      byte ptr ds:[Param2],bit4 ; £schova 1. polo‘ky seznamu ?
         jnz       ReadDr01                 ; je £schova 1. polo‘ky
         mov       word ptr ds:[FileTop],0  ; prvn¡ zobrazen˜ soubor
ReadDr01:and       byte ptr ds:[Param2],not bit4 ; zru¨en¡ p©¡znaku £schovy
         mov       word ptr ds:[FileAkt],0  ; aktivn¡ zobrazen˜ soubor
         mov       di,3*2*MAXFILE           ; za‡ tek bufferu - polo‘ky
         xor       si,si                    ; za‡ tek bufferu - indexy
         mov       es,ds:[BuffSegm]         ; adresa bufferu soubor–
         cld

; ------ ulo‘en¡ polo‘ky "." - aktivn¡ adres ©

         test      byte ptr ds:[EditObj],bit0 ; je editace souboru ?
         jnz       ReadDr02                 ; je editace souboru - nen¡ "."
         mov       es:[si],di               ; ulo‘en¡ indexu
         inc       si
         inc       si                       ; ukazatel index–
         mov       al,DIR                   ; atribut souboru
         stosb
         mov       al,"."
         stosb
         mov       al," "
         mov       cl,11-1
         rep       stosb                    ; jm‚no a p©¡pona
         xor       ax,ax
         stosw                              ; ‡as
         stosw                              ; datum
         stosw                              ; velikost LOW
         stosw                              ; velikost HIGH

; ------ ulo‘en¡ polo‘ky ".." - nadadres ©

ReadDr02:cmp       word ptr ds:[SouborN],6  ; je ROOT ?
         jbe       ReadDr04                 ; je ROOT disku
         mov       es:[si],di               ; ulo‘en¡ indexu
         inc       si
         inc       si                       ; ukazatel index–
         mov       al,DIR                   ; atribut souboru
         stosb
         mov       ax,".."
         stosw
         mov       al," "
         mov       cx,11-2
         rep       stosb                    ; jm‚no a p©¡pona
         xor       ax,ax
         stosw                              ; ‡as
         stosw                              ; datum
         stosw                              ; velikost LOW
         stosw                              ; velikost HIGH

; ------ nastaven¡ adresy DTA

ReadDr04:mov       dx,offset DTA
         mov       ah,1ah
         int       21h                      ; nastaven¡ adresy DTA

; ------ nalezen¡ prvn¡ho souboru

         mov       dx,offset Soubor         ; maska soubor–
         mov       cx,ARC+DIR+SYS+HID+RO    ; atributy
         mov       ah,4eh

; ------ nalezen¡ dal¨¡ho souboru

ReadDir1:int       21h                      ; nalezen¡ souboru
         jc        ReadDir5                 ; dal¨¡ soubor nenalezen

; ------ test, zda to nen¡ adres © "." nebo ".."

         cmp       byte ptr ds:[DTAName],"." ; je to adres © "." ?
         je        ReadDir4                 ; adres © ".." ani "." neplat¡

; ------ test, zda jsou souboru zak zan‚

         test      byte ptr ds:[DTAAtrib],DIR ; je to adres © ?
         jnz       ReadDr13                 ; je to adres © OK
         test      byte ptr ds:[EditObj],bit0 ; je editace soubor– ?
         jz        ReadDir4                 ; nejsou soubory - z kaz soubor–

; ------ test, zda je voln‚ m¡sto v bufferu

ReadDr13:cmp       si,MAXFILE*2             ; je ji‘ maximum soubor– ?
         jae       ReadDir5                 ; je ji‘ maximum soubor–
         mov       es:[si],di               ; ulo‘en¡ indexu
         inc       si
         inc       si                       ; ukazatel index–

; ------ p©enesen¡ parametr– souboru do bufferu

         cld
         push      si
         mov       si,offset DTAAtrib       ; atributy souboru
         movsb                              ; atributy
         mov       al," "                   ; mazac¡ znak mezery
         mov       cx,11                    ; d‚lka jm‚na s p©¡ponou
         rep       stosb                    ; vymaz n¡ jm‚na s p©¡ponou
         movsw                              ; ‡as
         movsw                              ; datum
         movsw                              ; velikost LOW
         movsw                              ; velikost HIGH

; ------ dek¢dov n¡ jm‚na souboru

         push      di
         mov       si,offset DTAName        ; jm‚no souboru
         sub       di,FileSum-FileName      ; jm‚no souboru
ReadDr21:lodsb
         cmp       al,0
         je        ReadDr24                 ; konec jm‚na souboru
         cmp       al,"."                   ; oddˆlova‡ p©¡pony ?
         je        ReadDr22                 ; je p©¡pona
         stosb                              ; ulo‘en¡ znaku do bufferu
         jmp       short ReadDr21           ; dal¨¡ znak
ReadDr22:pop       di
         push      di
         sub       di,FileSum-FileExt       ; p©¡pona jm‚na souboru
         jmp       short ReadDr21           ; dal¨¡ znak
ReadDr24:pop       di
         pop       si

; ------ dal¨¡ hled n¡

ReadDir4:mov       ah,4fh
         jmp       short ReadDir1

; ------ konec hled n¡ - p©¡prava k set©¡dˆn¡ adres ©e

ReadDir5:shr       si,1                     ; po‡et soubor–
         mov       ds:[FileNum],si          ; po‡et na‡ten˜ch soubor– v seznamu
         push      es
         pop       ds                       ; DS <- buffer se soubory
         cld
         mov       cx,si                    ; po‡et soubor–
         sub       cx,1                     ; po‡et dvojic soubor–
         jbe       ReadDir9                 ; je m lo soubor–
         xor       bx,bx                    ; ukazatel soubor–

; ------ adresa 2 soubor– k porovn n¡

ReadDir6:mov       si,ds:[bx]               ; 1. soubor
         mov       di,ds:[bx+2]             ; 2. soubor

; ------ ni‘¨¡ soubor je ".." nebo "." - to je OK

         cmp       byte ptr ds:[si+FileName],"." ; je to adres © ".." nebo "." ?
         je        ReadDir8                 ; je adres © ".." - to je OK

; ------ porovn n¡ atribut– DIR

         mov       al,ds:[si+FileAtr]       ; atribut 1. souboru
         mov       ah,ds:[di+FileAtr]       ; atribut 2. souboru
         mov       dx,ax                    ; £schova atribut–
         and       ax,DIR*HI + DIR          ; ponechaj¡ se atributy adres ©e
         cmp       al,ah                    ; porovn n¡ atribut–
         jb        ReadDir7                 ; soubor p©ed adres ©em - z mˆna
         ja        ReadDir8                 ; soubor za adres ©em - OK
         test      al,DIR                   ; je to adres © ?
         jnz       ReadDr68                 ; adres ©e se net©¡d¡ podle HID/SYS

; ------ porovn n¡ atribut– soubor– HID a SYS

         mov       ax,dx                    ; atributy
         shl       ax,1                     ; posun atribut– HID -> SYS
         or        ax,dx                    ; slou‡en¡ atribut– HID a SYS -> SYS
         and       ax,SYS*HI + SYS          ; ponech  atributy HID a SYS
         cmp       al,ah                    ; porovn n¡ atribut–
         jb        ReadDir7                 ; norm ln¡ soubor p©ed HID - z mˆna
         ja        ReadDir8                 ; norm ln¡ soubor za HID a SYS - OK

; ------ porovn n¡ jmen soubor–

ReadDr68:push      si
         push      di
         push      cx
         mov       cx,11                    ; d‚lka jm‚na s p©¡ponou
         inc       si                       ; adresa jm‚na 1. souboru
         inc       di                       ; adresa jm‚na 2. souboru
         repe      cmpsb                    ; porovn n¡ jmen soubor–
         pop       cx
         pop       di
         pop       si
         jbe       ReadDir8                 ; po©ad¡ jmen soubor– je OK

; ------ z mˆna soubor–

ReadDir7:mov       ds:[bx],di               ; nov  adresa 1. souboru
         mov       ds:[bx+2],si             ; nov  adresa 2. souboru

; ------ test, zda je ji‘ za‡ tek seznamu

         or        bx,bx                    ; je ji‘ za‡ tek ?
         jz        ReadDir8                 ; je ji‘ za‡ tek - nevrac¡ se zpˆt

; ------ n vrat k p©ede¨l‚ dvojici soubor–

         dec       bx
         dec       bx                       ; sn¡‘en¡ ukazatele v tabulce index–
         inc       cx                       ; zv˜¨en¡ ‡¡ta‡e soubor–
         jmp       short ReadDir6           ; test dal¨¡ dvojice soubor–

; ------ p©¡prava pro dal¨¡ dvojici soubor–

ReadDir8:inc       bx
         inc       bx                       ; zv˜¨en¡ ukazatele v tabulce index–
         loop      ReadDir6                 ; porovn n¡ dal¨¡ch 2 soubor–

; ------ n vrat registr–

ReadDir9:pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

ReadDir  ENDP

; -----------------------------------------------------------------------------
;        normalizace kurzoru adres ©e
; -----------------------------------------------------------------------------

NormDir  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx

; ------ p©¡prava registr–

         mov       ax,ds:[FileAkt]          ; aktivn¡ polo‘ka
         mov       bx,ds:[FileTop]          ; prvn¡ zobrazen  polo‘ka
         mov       cx,ds:[FileNum]          ; po‡et polo‘ek adres ©e
         jcxz      NormDir9                 ; nen¡ ‘ dn  polo‘ka
         dec       cx                       ; ‡¡slo posledn¡ polo‘ky

; ------ omezen¡ kurzoru

         cmp       ax,cx                    ; p©ete‡en¡ kurzoru ?
         jbe       NormDir1                 ; kurzor je OK
         mov       ax,cx                    ; omezen¡ kurzoru
         mov       ds:[FileAkt],ax          ; nov˜ kurzor

; ------ podte‡en¡ kurzoru pod po‡ tek

NormDir1:cmp       ax,bx                    ; je podte‡en¡ kurzoru ?
         jae       NormDir2                 ; kurzor je OK
         sub       bx,FILECOL               ; posun po‡ tku o sloupec
         jmp       short NormDir1           ; dal¨¡ test

; ------ maxim ln¡ po‡ tek od kurzoru

NormDir2:sub       ax,FILECOL*FILECOLS-1    ; maxim ln¡ po‡ tek
         jnc       NormDir3                 ; po‡ tek je OK
         xor       ax,ax                    ; omezen¡ po‡ tku

; ------ p©ete‡en¡ kurzoru za konec

NormDir3:cmp       ax,bx                    ; je po‡ tek p©ed koncem ?
         jbe       NormDir4                 ; po‡ tek je OK
         add       bx,FILECOL               ; posun po‡ tku
         jmp       short NormDir3           ; dal¨¡ test po‡ tku

NormDir4:mov       ds:[FileTop],bx          ; nov˜ po‡ tek

; ------ n vrat registr–

NormDir9:pop       cx
         pop       bx
         pop       ax
         ret

NormDir  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ seznamu soubor–
; -----------------------------------------------------------------------------

DispDir  PROC      NEAR

         call      NormDir                  ; normalizace kurzoru adres ©e

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es

; ------ zobrazen¡ nadpisu a n povˆdy

         mov       si,offset NadSoub        ; nadpis - soubor
         mov       di,offset HlpSoub        ; n povˆda - soubor
         test      byte ptr ds:[EditObj],bit1 ; je editace adres ©e ?
         jz        DispDr10                 ; nen¡ editace adres ©e
         mov       si,offset NadAdr         ; nadpis - adres ©
         mov       di,offset HlpAdr         ; n povˆda - adres ©
DispDr10:call      DispNadp                 ; zobrazen¡ nadpisu
         mov       si,di
         call      DispHlp                  ; zobrazen¡ n povˆdy

; ------ ur‡en¡ po‡tu sloupc– k zobrazen¡

         xor       dx,dx
         mov       ax,ds:[FileNum]          ; po‡et soubor– v seznamu
         add       ax,FILECOL-1             ; zaokrouhlen¡
         mov       cx,FILECOL               ; po‡et soubor– na sloupec
         div       cx                       ; v˜po‡et po‡tu sloupc– celkem
         cmp       ax,FILECOLS              ; maxim ln¡ po‡et sloupc–
         jbe       DispDr11                 ; po‡et sloupc– je OK
         mov       al,FILECOLS              ; omezen¡ po‡tu sloupc–
DispDr11:mov       dl,al                    ; po‡et sloupc– k zobrazen¡

; ------ ur‡en¡ po‡ te‡n¡ adresy k ulo‘en¡

         mov       al,FILESIR               ; ¨¡©ka jednoho sloupce
         mul       dl                       ; v˜po‡et celkov‚ ¨¡©ky
         mov       di,6*160+2*40+2          ; st©ed po‡ tku
         sub       di,ax                    ; po‡ te‡n¡ adresa k zobrazen¡
         and       di,not 1                 ; zarovn n¡ na sudou adresu
         mov       es,ds:[SegmVRAM]         ; segment videopamˆti
         xor       cx,cx                    ; CX <- 0 (aby byl CH=0)

; ------ p©¡prava registr– k dek¢dov n¡

         cld
         mov       bx,ds:[FileTop]          ; prvn¡ zobrazen˜ soubor
         mov       ds,ds:[BuffSegm]         ; buffer soubor–

; ------ p©¡prava k zobrazen¡ jednoho sloupce

DispDir3:mov       dh,FILECOL               ; po‡et soubor– na sloupec

; ------ zobrazen¡ neplatn‚ho souboru

DispDir4:mov       ah,cs:[ColMenu1]         ; bˆ‘n  barva polo‘ky
         cmp       bx,cs:[FileNum]          ; je to platn˜ soubor ?
         jb        DispDir5                 ; je to platn˜ soubor
         mov       al," "
         mov       cl,FILESIR-1             ; ¨¡©ka polo‘ky
         cld
         rep       stosw                    ; vymaz n¡ polo‘ky
         jmp       short DispDr88

; ------ test, je-li to aktivn¡ polo‘ka

DispDir5:cmp       bx,cs:[FileAkt]          ; je to aktivn¡ polo‘ka ?
         jne       DispDr52                 ; nen¡ to aktivn¡ polo‘ka

; ------ zobrazen¡ kurzoru rychlovyhled v n¡

         push      dx
         mov       ax,di                    ; sou©adnice
         mov       dl,160                   ; po‡et bajt– na © dek
         div       dl                       ; v˜po‡et © dku a pozice
         shr       ah,1                     ; offset/2 -> pozice
         mov       dh,al                    ; © dek
         mov       dl,byte ptr cs:[QckFileN] ; po‡et znak– shody
         add       dl,1                     ; + korekce
         cmp       dl,8                     ; je p©¡pona ?
         jbe       DispDr51                 ; nen¡ p©¡pona
         inc       dx                       ; korekce pro p©¡ponu
DispDr51:add       dl,ah                    ; pozice k zobrazen¡
         call      SetKurz                  ; nastaven¡ pozice kurzoru
         pop       dx
         mov       ah,cs:[ColMenu3]         ; barva aktivn¡ polo‘ky
         cld

; ------ adresa polo‘ky

DispDr52:mov       si,bx                    ; ‡¡slo polo‘ky
         shl       si,1                     ; offset v tabulce index–
         mov       si,ds:[si]               ; adresa polo‘ky
         inc       si                       ; jm‚no souboru

; ------ dek¢dov n¡ adres ©e

         test      byte ptr ds:[si+FileAtr-1],DIR ; je to adres © ?
         jz        DispDir6                 ; nen¡ to adres ©
         mov       al,"["                   ; lev˜ okraj
         stosw
         mov       cl,8                     ; d‚lka jm‚na
DispDr54:lodsb
         stosw
         loop      DispDr54                 ; dek¢dov n¡ jm‚na
         mov       al,"°"                   ; p©¡znak HID, SYS
         test      byte ptr ds:[si+FileAtr-8-1],HID+SYS ; je HID nebo SYS ?
         jnz       DispDr55                 ; je HID nebo SYS
         mov       al," "
DispDr55:stosw                              ; oddˆlova‡ p©¡pony
         mov       cl,3                     ; d‚lka p©¡pony
DispDr56:lodsb
         stosw
         loop      DispDr56                 ; dek¢dov n¡ p©¡pony
         mov       al,"]"
         stosw                              ; prav˜ okraj
DispDr88:jmp       short DispDir8

; ------ dek¢dov n¡ souboru

DispDir6:mov       al,"*"                   ; ozna‡en¡ souboru R/O
         test      byte ptr ds:[si+FileAtr-1],RO ; je soubor R/O ?
         jnz       DispDr61                 ; soubor je R/O
         mov       al," "                   ; ozna‡en¡ bˆ‘n‚ polo‘ky
DispDr61:stosw                              ; mezera p©ed jm‚nem
         mov       cl,8                     ; d‚lka jm‚na bˆ‘n‚ho souboru
         test      byte ptr ds:[si+FileAtr-1],HID+SYS ; je soubor HID nebo SYS ?
         jz        DispDr63                 ; je bˆ‘n˜ soubor
         lodsb                              ; prvn¡ znak jm‚na
         stosw                              ; prvn¡ znak jm‚na - velk‚ p¡smeno
         dec       cx                       ; d‚lka jm‚na-1
DispDr63:lodsb
         cmp       al,"A"
         jb        DispDr64
         cmp       al,"Z"
         ja        DispDr64
         add       al,32                    ; korekce na mal‚ p¡smeno
DispDr64:stosw
         loop      DispDr63                 ; dek¢dov n¡ jm‚na souboru
         mov       al,"°"                   ; p©¡znak HID nebo SYS
         test      byte ptr ds:[si+FileAtr-8-1],HID+SYS ; je HID nebo SYS ?
         jnz       DispDr65                 ; je HID nebo SYS
         mov       al," "                   ; jinak bˆ‘n˜ soubor
DispDr65:stosw                              ; oddˆlova‡ p©¡pony
         mov       cl,3                     ; d‚lka p©¡pony
DispDr66:lodsb
         cmp       al,"A"
         jb        DispDr67
         cmp       al,"Z"
         ja        DispDr67
         add       al,32                    ; korekce na mal‚ p¡smeno
DispDr67:stosw
         loop      DispDr66                 ; dek¢dov n¡ p©¡pony
         mov       al," "
         stosw                              ; koncov  mezera

; ------ z vˆre‡n  mezera

DispDir8:mov       ah,cs:[ColMenu1]         ; bˆ‘n  barva
         mov       al,"³"                   ; oddˆlovac¡ ‡ ra
         cmp       dl,1                     ; je dal¨¡ sloupec ?
         ja        DispDr82                 ; bude dal¨¡ sloupec
         mov       al," "                   ; jinak koncov  mezera
DispDr82:stosw

; ------ p©¡prava pro dal¨¡ soubor ve sloupci

         add       di,160-FILESIR*2         ; adresa dal¨¡ho © dku
         inc       bx                       ; zv˜¨en¡ ‡¡sla souboru
         dec       dh                       ; ‡¡ta‡ soubor– ve sloupci
         jz        DispDr84                 ; je ji‘ cel˜ sloupec
         jmp       DispDir4                 ; dal¨¡ polo‘ka ve sloupci

; ------ p©¡prava k zobrazen¡ dal¨¡ho sloupce

DispDr84:sub       di,FILECOL*160-FILESIR*2 ; adresa dal¨¡ho sloupce
         sub       dl,1                     ; ‡¡ta‡ sloupc–
         js        DispDir9
         jz        DispDir9
         jmp       DispDir3                 ; dal¨¡ sloupec soubor–

; ------ n vrat registr–

DispDir9:pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispDir  ENDP

; -----------------------------------------------------------------------------
;        p©¡prava rychlovyhled v n¡ na jm‚no souboru
; -----------------------------------------------------------------------------

PrepSrc  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      si
         push      di
         push      es

; ------ vymaz n¡ bufferu

         cld
         push      ds
         pop       es
         mov       di,offset QckFile        ; buffer
         mov       cx,11                    ; d‚lka bufferu
         mov       byte ptr ds:[QckFileN],cl; d‚lka jm‚na k porovn n¡
         mov       al," "
         rep       stosb                    ; vymaz n¡ bufferu

; ------ nalezen¡ za‡ tku jm‚na

         mov       si,ds:[SouborN]          ; d‚lka jm‚na souboru
         add       si,offset Soubor         ; offset konce jm‚na soubor
PrepSrc2:dec       si                       ; sn¡‘en¡ ukazatele
         cmp       byte ptr ds:[si-1],"\"   ; je za‡ tek jm‚na ?
         jne       PrepSrc2                 ; nalezen¡ za‡ tku jm‚na

; ------ dek¢dov n¡ jm‚na souboru

         mov       di,offset QckFile        ; buffer jm‚na souboru
PrepSrc3:lodsb
         cmp       al,0                     ; konec jm‚na souboru ?
         je        PrepSrc5                 ; konec jm‚na
         cmp       al,"."                   ; je p©¡pona ?
         je        PrepSrc4                 ; p©¡pona
         cmp       di,offset QckFile+11     ; je buffer pln˜ ?
         jae       PrepSrc3                 ; buffer je pln˜
         stosb                              ; ulo‘en¡ znaku
         jmp       short PrepSrc3           ; dal¨¡ znak

PrepSrc4:mov       di,offset QckFile+8      ; p©¡pona jm‚na
         jmp       short PrepSrc3           ; dal¨¡ znak

; ------ n vrat registr–

PrepSrc5:pop       es
         pop       di
         pop       si
         pop       cx
         pop       ax
         ret

PrepSrc  ENDP

; -----------------------------------------------------------------------------
;        rychlovyhled v n¡ souboru (BL=znak, AX=aktivn¡ polo‘ka, CY=nenalezen)
; -----------------------------------------------------------------------------

QckSrc   PROC      NEAR

; ------ £schova registr–

         push      bx
         push      cx
         push      dx

; ------ zru¨en¡ jednoho znaku BS nebo DELETE

         mov       dx,bx                    ; DX <- zadan  kl vesa
         mov       cx,ds:[QckFileN]         ; po‡et znak– v bufferu
         cmp       dl,8                     ; je BS ?
         je        QckSrc2                  ; je BS
         cmp       dx,5300h                 ; je DELETE ?
         jne       QckSrc4                  ; nen¡ DELETE
QckSrc2: jcxz      QckSrc9                  ; buffer je pr zdn˜ (nyn¡ je NC)
         dec       byte ptr ds:[QckFileN]   ; sn¡‘en¡ ‡¡ta‡e znak– v bufferu
         jmp       short QckSrc9            ; aktivn¡ polo‘ka z–st v 

; ------ konverze znaku na velk‚ p¡smeno

QckSrc4: xchg      ax,dx                    ; AL <- hledan˜ znak
         call      UpCase                   ; konverze na velk‚ p¡smeno
         xchg      ax,dx                    ; DL <- hledan˜ znak

; ------ p©¡prava bufferu rychlovyhled v n¡

         mov       bx,cx                    ; po‡et znak– v bufferu
         cmp       bl,11                    ; je buffer pln˜ ?
         jae       QckSrc9                  ; buffer je ji‘ pln˜ - nemˆn¡ se
         mov       ds:[bx+QckFile],dl       ; ulo‘en¡ znaku do bufferu
         inc       byte ptr ds:[QckFileN]   ; zv˜¨en¡ po‡tu znak– v bufferu

; ------ stanoven¡ atributu aktivn¡ polo‘ky

         push      es
         push      si
         call      GetAFil                  ; poskytnut¡ aktivn¡ho souboru
         mov       dh,es:[si+FileAtr]       ; atributy aktivn¡ polo‘ky
         and       dh,DIR                   ; p©¡znak atributu DIR
         pop       si
         pop       es

; ------ nalezen¡ polo‘ky s dan˜m atributem

         call      QckSrc0                  ; nalezen¡ polo‘ky
         jnc       QckSrc8                  ; polo‘ka nalezena OK

; ------ nalezen¡ polo‘ky s opa‡n˜m atributem DIR

         xor       dh,DIR                   ; zmˆna atributu polo‘ky
         call      QckSrc0                  ; nalezen¡ polo‘ky s jin˜m atributem
         jnc       QckSrc8                  ; polo‘ka nalezena OK

; ------ polo‘ka nenalezena - zru¨en¡ zadan‚ho znaku

         dec       byte ptr ds:[QckFileN]   ; n vrat ‡¡ta‡e znak–
         mov       bx,ax                    ; p–vodn¡ aktivn¡ polo‘ka

; ------ polo‘ka nalezena OK

QckSrc8: mov       ax,bx                    ; nalezen  polo‘ka

; ------ n vrat registr–

QckSrc9: pop       dx
         pop       cx
         pop       bx
         ret

QckSrc   ENDP

; -----------------------------------------------------------------------------
;        nalezen¡ polo‘ky s atributem DH (0 nebo DIR) -> BX (CY=nenalezeno)
; -----------------------------------------------------------------------------

QckSrc0  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      si
         push      di
         push      es

; ------ p©¡prava registr– k hled n¡

         cld
         xor       bx,bx                    ; ukazatel ‡¡sla polo‘ky
         mov       es,ds:[BuffSegm]         ; buffer soubor–
         mov       cx,ds:[QckFileN]         ; po‡et znak– v bufferu

; ------ test, zda jsou ji‘ v¨echny polo‘ky

QckSrc01:cmp       bx,ds:[FileNum]          ; jsou ji‘ v¨echny polo‘ky ?
         cmc
         jc        QckSrc08                 ; polo‘ka nenalezena

; ------ adresa testovan‚ polo‘ky

         mov       di,bx                    ; ‡¡slo polo‘ky
         shl       di,1                     ; offset v tabulce index–
         mov       di,es:[di]               ; adresa polo‘ky

; ------ test, zda je spr vn˜ atribut

         mov       al,es:[di+FileAtr]       ; atribut polo‘ky
         and       al,DIR
         cmp       al,dh                    ; je spr vn˜ atribut ?
         jne       QckSrc05                 ; atribut nesouhlas¡

; ------ porovn n¡ jm‚na polo‘ky

         push      cx
         mov       si,offset QckFile        ; jm‚no hledan‚ polo‘ky
         inc       di                       ; p©esko‡en¡ atributu polo‘ky
         repe      cmpsb                    ; porovn n¡ jmen
         pop       cx
         je        QckSrc08                 ; jm‚no polo‘ky nalezeno OK

; ------ dal¨¡ polo‘ka

QckSrc05:inc       bx                       ; zv˜¨en¡ ukazatele polo‘ek
         jmp       short QckSrc01           ; test dal¨¡ polo‘ky

; ------ n vrat registr–

QckSrc08:pop       es
         pop       di
         pop       si
         pop       cx
         pop       ax
         ret

QckSrc0  ENDP

; -----------------------------------------------------------------------------
;        inicializace tabulky fyzick˜ch disk–
; -----------------------------------------------------------------------------

IniFDsk  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es

; ------ zji¨tˆn¡ po‡tu disket z INT 11h

         mov       byte ptr ds:[NumDisk],0  ; p©ednastaven¡ - nen¡ disketa
         mov       byte ptr ds:[TabDisk],0ffh
         push      ds
         int       11h                      ; poskytnut¡ tabulky vybaven¡
         pop       ds
         test      al,bit0                  ; jsou diskety p©¡tomny ?
         jz        IniFDsk1                 ; nen¡ ‘ dn  disketa
         mov       cl,6                     ; po‡et rotac¡
         shr       al,cl                    ; po‡et disket
         inc       ax                       ; korekce + 1
         mov       ds:[NumDisk],al          ; po‡et disket 1 a‘ 4

; ------ zji¨tˆn¡ po‡tu disket z BIOS

IniFDsk1:push      cs
         pop       es
         mov       ax,84ah
         mov       dl,0                     ; disketa 0
         call      Int13                    ; poskytnut¡ po‡tu disket
         or        ax,ax                    ; je slu‘ba platn  ?
         jnz       IniFDsk2                 ; slu‘ba nen¡ podporovan 
         mov       ax,es
         mov       cx,cs
         cmp       ax,cx
         je        IniFDsk2                 ; slu‘ba nepodporovan 
         cmp       dl,4
         jbe       IniFDs12
         mov       dl,4
IniFDs12:mov       ds:[NumDisk],dl          ; po‡et disket

; ------ inicializace tabulky disket

IniFDsk2:mov       di,offset TabDisk        ; tabulka definic disket
         mov       cl,ds:[NumDisk]          ; po‡et disket
         mov       ch,0
         push      ds
         pop       es                       ; ES <- DS
         jcxz      IniFDsk4                 ; nen¡ ‘ dn  disketa
         mov       al,0                     ; ‡¡slo diskety
         cld
IniFDsk3:stosb
         inc       ax                       ; zv˜¨en¡ ‡¡sla diskety
         loop      IniFDsk3                 ; dal¨¡ disketa
         mov       al,0ffh
         stosb
         dec       di

; ------ stanoven¡ po‡tu pevn˜ch disk–

IniFDsk4:mov       ah,8
         mov       dl,80h                   ; ‡¡slo pevn‚ho disku
         push      di
         call      Int13                    ; zji¨tˆn¡ po‡tu pevn˜ch disk–
         pop       di
         cmp       ah,1
         je        IniFDsk7                 ; nen¡ ‘ dn˜ pevn˜ disk

; ------ inicializace tabulky pevn˜ch disk–

         cmp       dl,2
         jbe       IniFDsk5
         mov       dl,2
IniFDsk5:add       ds:[NumDisk],dl          ; zv˜¨en¡ po‡tu disk–
         mov       ch,0
         mov       cl,dl                    ; po‡et pevn˜ch disk–
         push      ds
         pop       es
         jcxz      IniFDsk7                 ; nen¡ ‘ dn˜ pevn˜ disk
         mov       al,80h                   ; ‡¡slo pevn‚ho disku
         cld
IniFDsk6:stosb
         inc       ax
         loop      IniFDsk6
         mov       al,0ffh
         stosb

; ------ p©ednastaven¡ aktivn¡ho disku

IniFDsk7:push      ds
         pop       es
         test      byte ptr ds:[Param],bit2 ; byl fyzick˜ disk ji‘ zvolen ?
         jnz       IniFDsk8                 ; fyzick˜ disk ji‘ byl zvolen
         mov       byte ptr ds:[FDisk],80h  ; p©ednastaven¡ fyzick‚ho disku
         or        byte ptr ds:[Param],bit2 ; p©¡znak volby fyzick‚ho disku
IniFDsk8:mov       di,offset TabDisk
         mov       cl,ds:[NumDisk]          ; po‡et disk–
         mov       ch,0
         jcxz      IniFDsk9                 ; nen¡ ‘ dn˜ disk v tabulce
         mov       al,ds:[FDisk]            ; fyzick˜ disk
         cld
         repne     scasb                    ; nalezen¡ disku v tabulce
         je        IniFDsk9                 ; disk nalezen OK
         mov       al,ds:[TabDisk]          ; prvn¡ disk v tabulce
         mov       ds:[FDisk],al            ; aktivn¡ disk

; ------ n vrat registr–

IniFDsk9:pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

IniFDsk  ENDP

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                            Rozbor zad n¡ parametr–
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;þ
; -----------------------------------------------------------------------------
;        rozbor p©¡kazov‚ho © dku
; -----------------------------------------------------------------------------

Rozbor   PROC      NEAR

; ------ p©¡prava p©¡kazov‚ho © dku

         mov       si,81h                   ; za‡ tek p©¡kazov‚ho © dku
         mov       bh,0
         mov       bl,ds:[si-1]             ; d‚lka textu p©¡kazov‚ho © dku
         and       bl,7fh
         mov       byte ptr ds:[si+bx],0    ; ozna‡en¡ konce p©¡kazov‚ho © dku

; ------ nalezen¡ za‡ tku prvn¡ho parametru

         call      RozbSpc                  ; vypu¨tˆn¡ mezer p©ed parametrem
         jnc       Rozbor1                  ; je nˆco zad no
         clc                                ; p©¡znak operace OK
         ret

; ------ test nepovolen˜ch znak–

Rozbor1: cmp       al,"?"                   ; nepovolen˜ znak
         je        Rozbor2                  ; nepovolen˜ znak - chyba
         cmp       al,"/"                   ; oddˆlova‡ parametr– ?
         je        Rozbor2                  ; nepovolen˜ znak - chyba
         cmp       al,","                   ; oddˆlova‡ parametr– ?
         jne       Rozbor3                  ; OK
Rozbor2: stc                                ; p©¡znak chyby
         ret

; ------ za‡ tek rozboru parametru

Rozbor3: or        byte ptr ds:[Param],bit0 ; p©¡znak zad n¡ parametr–

; ------ pokus o rozbor jako logick˜ disk

         call      RozbLDsk                 ; rozbor jako logick˜ disk
         jnc       Rozbor9                  ; zad n logick˜ disk OK

; ------ pokus o rozbor jako fyzick˜ disk

         call      RozbFDsk                 ; rozbor jako fyzick˜ disk
         jnc       Rozbor9                  ; zad n fyzick˜ disk OK

; ------ pokus o rozbor jako pamˆŸ

         call      RozbMem                  ; rozbor jako editace pamˆti
         jnc       Rozbor9                  ; zad na pamˆŸ OK

; ------ pokus o rozbor jako pamˆŸ CMOS

         call      RozbCMOS                 ; rozbor jako pamˆŸ CMOS
         jnc       Rozbor9                  ; zad na pamˆŸ CMOS OK

; ------ jinak je to jm‚no souboru/adres ©e

         mov       di,offset Soubor         ; jm‚no souboru k editaci
         push      ds
         pop       es
Rozbor6: call      RozbCh                   ; na‡ten¡ dal¨¡ho znaku
         jc        Rozbor8                  ; je konec parametru
         cmp       al,","
         je        Rozbor7                  ; konec parametru
         cmp       al,"/"
         je        Rozbor7                  ; konec parametru
         cmp       al,"?"
         je        Rozbor7                  ; nepovolen˜ znak
         cmp       al,"*"
         je        Rozbor7                  ; nepovolen˜ znak
         cld
         stosb                              ; ulo‘en¡ znaku do bufferu
         inc       word ptr ds:[SouborN]    ; zv˜¨en¡ ‡¡ta‡e d‚lky jm‚na souboru
         jmp       short Rozbor6            ; rozbor dal¨¡ho znaku

Rozbor7: dec       si
Rozbor8: cmp       word ptr ds:[SouborN],3
         jne       Rozbor81
         cmp       word ptr ds:[di-2],"\:"
         je        Rozbor83
Rozbor81:cmp       word ptr ds:[SouborN],1
         je        Rozbor83
         cmp       byte ptr ds:[di-1],"\"   ; je text ukon‡en znakem "\" ?
         jne       Rozbor83                 ; nen¡ ukon‡en znakem "\"
         dec       di                       ; zru¨en¡ koncov‚ho znaku "\"
         dec       word ptr ds:[SouborN]    ; sn¡‘en¡ d‚lky souboru
Rozbor83:mov       al,0                     ; koncov  0
         cld
         stosb                              ; ulo‘en¡ koncov‚ 0

; ------ mus¡ b˜t konec parametr–

Rozbor9: call      RozbSpc                  ; vypu¨tˆn¡ mezer
         cmc                                ; nesm¡ nic n sledovat
         ret

Rozbor   ENDP

; -----------------------------------------------------------------------------
;        rozbor jako logick˜ disk (CY=nen¡ zad n logick˜ disk)
; -----------------------------------------------------------------------------

RozbLDsk PROC      NEAR

; ------ prvn¡ znak parametru

         call      RozbCh                   ; na‡ten¡ prvn¡ho znaku parametru
         jc        RozbLDs9                 ; nen¡ ‘ dn˜ znak

; ------ test, zda je platn‚ ozna‡en¡ logick‚ho disku

         cmp       al,"A"
         jb        RozbLDs8                 ; nen¡ ozna‡en¡ disku
         cmp       al,"Z"
         ja        RozbLDs8                 ; nen¡ ozna‡en¡ disku
         mov       ah,al                    ; £schova ozna‡en¡ disku

; ------ test, zda je to zad n¡ disku

         call      RozbDisk                 ; test zad n¡ disku
         jc        RozbLDs8                 ; nen¡ platn‚ zad n¡ disku

; ------ je platn‚ zad n¡ disku

         sub       ah,"A"                   ; relativn¡ ‡¡slo disku
         mov       ds:[LDisk],ah            ; zadan˜ logick˜ disk
         or        byte ptr ds:[Param],bit1 ; p©¡znak zad n¡ logick‚ho disku
         ret

; ------ chyba - nen¡ zad n logick˜ disk

RozbLDs8:dec       si                       ; n vrat prvn¡ho znaku
RozbLDs9:stc                                ; p©¡znak neplatn‚ho zad n¡ disku
         ret

RozbLDsk ENDP

; -----------------------------------------------------------------------------
;        rozbor jako fyzick˜ disk (CY=nen¡ zad n fyzick˜ disk)
; -----------------------------------------------------------------------------

RozbFDsk PROC      NEAR

; ------ prvn¡ znak parametru

         call      RozbCh                   ; na‡ten¡ prvn¡ho znaku parametru
         jc        RozbFDs9                 ; nen¡ ‘ dn˜ znak

; ------ test zad n¡ ‡¡sla disketov‚ jednotky

         sub       al,"0"                   ; korekce na ‡¡slo
         jc        RozbFDs8                 ; nen¡ zad no ‡¡slo disku
         mov       ah,al                    ; £schova ‡¡sla disku
         cmp       ah,3                     ; zad na disketov  jednotka ?
         ja        RozbFDs3                 ; nen¡ zad na disketov  jednotka

; ------ test, zda je platn‚ ozna‡en¡ disketov‚ jednotky

         call      RozbDisk                 ; test zad n¡ disku
         jc        RozbFDs8                 ; nen¡ zad n fyzick˜ disk

; ------ platn‚ zad n¡ fyzick‚ho disku

RozbFDs2:mov       ds:[FDisk],ah            ; zadan˜ fyzick˜ disk
         or        byte ptr ds:[Param],bit2 ; p©¡znak zad n¡ fyzick‚ho disku
         ret

; ------ test, zda je zad n¡ pevn‚ho disku

RozbFDs3:cmp       ah,8                     ; je zad n¡ pevn‚ho disku ?
         jne       RozbFDs8                 ; nen¡ zad n¡ pevn‚ho disku
         mov       ah,80h                   ; p©ednastaven¡ ‡¡sla disku

; ------ na‡ten¡ dal¨¡ho znaku parametru

         call      RozbCh                   ; na‡ten¡ dal¨¡ho znaku
         jc        RozbFDs8                 ; nen¡ dal¨¡ znak

; ------ dal¨¡ znak mus¡ b˜t ‡¡slice "0" nebo "1"

         sub       al,"0"                   ; je ‡¡slice "0" ?
         jc        RozbFDs7                 ; nen¡ zad n¡ pevn‚ho disku
         cmp       al,1                     ; je zad no ‡¡slo disku ?
         ja        RozbFDs7                 ; nen¡ ‡¡slo pevn‚ho disku
         add       ah,al                    ; ‡¡slo pevn‚ho disku

; ------ test, zda je platn‚ zad n¡ disku

         call      RozbDisk                 ; test zad n¡ disku
         jnc       RozbFDs2                 ; je platn‚ zad n¡ disku

; ------ chyba - nen¡ zad n fyzick˜ disk

RozbFDs7:dec       si                       ; n vrat druh‚ho znaku
RozbFDs8:dec       si                       ; n vrat prvn¡ho znaku
RozbFDs9:stc                                ; p©¡znak neplatn‚ho zad n¡ disku
         ret

RozbFDsk ENDP

; -----------------------------------------------------------------------------
;        rozbor zad n¡ editace pamˆti (*: nebo **:)
; -----------------------------------------------------------------------------

RozbMem  PROC      NEAR

; ------ na‡ten¡ prvn¡ho znaku

         call      RozbCh                   ; na‡ten¡ prvn¡ho znaku
         jc        RozbMem9                 ; nen¡ platn˜ parametr

; ------ test, zda je to ozna‡en¡ editace pamˆti

         cmp       al,"*"                   ; je editace pamˆti ?
         jne       RozbMem8                 ; nen¡ editace pamˆti

; ------ test, zda je oddˆlova‡ disk–

         call      RozbDisk                 ; test, zda je oddˆlova‡ disk–
         jc        RozbMem3                 ; nen¡ konec parametru
         or        byte ptr ds:[Param],bit3 ; zad na editace opera‡n¡ pamˆti
         ret

; ------ test, zda je zad na editace roz¨¡©enˆ pamˆti

RozbMem3:call      RozbCh                   ; na‡ten¡ dal¨¡ho znaku
         jc        RozbMem8                 ; chyba (i kdy‘ nemˆla by nastat)
         cmp       al,"*"                   ; je editace roz¨¡©en‚ pamˆti ?
         jne       RozbMem7                 ; nen¡ editace roz¨¡©en‚ pamˆti
         call      RozbDisk                 ; test, zda je oddˆlova‡ disk–
         jc        RozbMem7                 ; nen¡ konec parametru
         or        byte ptr ds:[Param],bit4 ; zad na editace roz¨¡©en‚ pamˆti
         ret

; ------ nen¡ zad na editace pamˆti

RozbMem7:dec       si                       ; n vrat druh‚ho znaku
RozbMem8:dec       si                       ; n vrat prvn¡ho znaku
RozbMem9:stc
         ret

RozbMem  ENDP

; -----------------------------------------------------------------------------
;        rozbor zad n¡ editace pamˆti CMOS (@:)
; -----------------------------------------------------------------------------

RozbCMOS PROC      NEAR

; ------ na‡ten¡ prvn¡ho znaku parametru

         call      RozbCh                   ; na‡ten¡ prvn¡ho znaku parametru
         jc        RozbCMS9                 ; nen¡ ‘ dn˜ znak

; ------ znak mus¡ b˜t "@"

         cmp       al,"@"                   ; je znak "@" ?
         jne       RozbCMS8                 ; nen¡ znak "@"

; ------ test, zda je oddˆlova‡ disk–

         call      RozbDisk                 ; test zad n¡ oddˆlova‡e disk–
         jc        RozbCMS8                 ; nen¡ oddˆlova‡ disk–
         or        byte ptr ds:[Param],bit5 ; je editace pamˆti CMOS
         ret

; ------ nen¡ zad na editace pamˆti CMOS

RozbCMS8:dec       si                       ; n vrat prvn¡ho znaku
RozbCMS9:stc                                ; p©¡znak, ‘e nen¡ editace CMOS
         ret

RozbCMOS ENDP

; -----------------------------------------------------------------------------
;        rozbor zad n¡ oddˆlova‡e disku ":" (p©i chybˆ CY se SI nemˆn¡)
; -----------------------------------------------------------------------------

RozbDisk PROC      NEAR

; ------ na‡ten¡ dal¨¡ho znaku

         call      RozbCh                   ; na‡ten¡ dal¨¡ho znaku
         jc        RozbDsk9                 ; nen¡ dal¨¡ znak

; ------ dal¨¡ znak mus¡ b˜t oddˆlova‡ ":"

         cmp       al,":"                   ; je oddˆlova‡ disku ":" ?
         jne       RozbDsk7                 ; nen¡ oddˆlova‡ disku ":"

; ------ test, zda je konec parametru

         call      RozbKon                  ; test, zda je konec parametru
         jnc       RozbDsk9                 ; je konec parametru OK

; ------ neplatn‚ zad n¡ disku

RozbDsk7:dec       si                       ; n vrat prvn¡ho znaku
         stc                                ; p©¡znak, ‘e nen¡ oddˆlova‡ disku
RozbDsk9:ret

RozbDisk ENDP

; -----------------------------------------------------------------------------
;        test konce parametru
; -----------------------------------------------------------------------------

RozbKon  PROC      NEAR

; ------ na‡ten¡ dal¨¡ho znaku parametru

         call      RozbCh                   ; na‡ten¡ dal¨¡ho znaku
         jc        RozbKon5                 ; nen¡ dal¨¡ znak - to je OK

; ------ dal¨¡ znak mus¡ b˜t oddˆlova‡

         je        RozbKon4                 ; je oddˆlova‡ - OK
         cmp       al,"/"                   ; je oddˆlova‡ parametr– ?
         je        RozbKon4                 ; je oddˆlova‡ parametr– - OK
         cmp       al,","                   ; je oddˆlovac¡ ‡ rka ?
         je        RozbKon4                 ; je oddˆlovac¡ ‡ rka - OK

; ------ nen¡ konec parametru

         dec       si                       ; n vrat znaku
         stc                                ; p©¡znak, ‘e nen¡ konec parametru
         ret

; ------ je konec parametru OK

RozbKon4:dec       si                       ; n vrat znaku oddˆlova‡e
RozbKon5:clc                                ; p©¡znak zad n¡ OK
         ret

RozbKon  ENDP

; -----------------------------------------------------------------------------
;        vypu¨tˆn¡ oddˆlovac¡ch mezer
; -----------------------------------------------------------------------------

RozbSpc  PROC      NEAR

         call      RozbCh                   ; vstup znaku z p©¡kazov‚ho © dku
         jc        RozbSpc2                 ; konec p©¡kazov‚ho © dku
         je        RozbSpc                  ; oddˆlova‡ - vypu¨tˆn¡
         dec       si                       ; n vrat platn‚ho znaku
RozbSpc2:ret

RozbSpc  ENDP

; -----------------------------------------------------------------------------
;        vstup znaku z p©¡kazov‚ho © dku
; -----------------------------------------------------------------------------

RozbCh   PROC      NEAR

; ------ vstup znaku z p©¡kazov‚ho © dku

         cld
         lodsb                              ; na‡ten¡ znaku z p©¡kazov‚ho © dku

; ------ n hrada tabel toru mezerou

         cmp       al,9                     ; je tabel tor ?
         jne       RozbCh1                  ; nen¡ tabel tor
         mov       al," "                   ; n hrada mezerou

; ------ konverze na velk‚ p¡smeno

RozbCh1: call      UpCase                   ; p©evod znaku na velk‚ p¡smeno

; ------ test, zda je platn˜ znak

RozbCh2: cmp       al," "                   ; je platn˜ znak ?
         jae       RozbCh3                  ; je platn˜ znak
         dec       si                       ; konec textu - n vrat znaku
RozbCh3: ret

RozbCh   ENDP

; -----------------------------------------------------------------------------
;        p©evod znaku na velk‚ p¡smeno
; -----------------------------------------------------------------------------

UpCase   PROC      NEAR

         cmp       al,"a"
         jb        UpCase1
         cmp       al,"z"
         ja        UpCase1
         sub       al,32
UpCase1: ret

UpCase   ENDP

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                       Obsluha informa‡n¡ho © dku
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;þ
; -----------------------------------------------------------------------------
;        zobrazen¡ jm‚na souboru/adres ©e (£vodn¡ text SI)
; -----------------------------------------------------------------------------

InfoSoub PROC      NEAR

         push      cx
         push      si
         push      di

         call      InfoClr                  ; vymaz n¡ bufferu inform. © dku
         call      InfoDek                  ; dek¢dov n¡ prvn¡ ‡ sti textu
         mov       si,offset Soubor         ; jm‚no souboru
         mov       cx,ds:[SouborN]
         call      InfoDek0                 ; p©enesen¡ textu
         call      InfoDisp                 ; zobrazen¡ informa‡n¡ho © dku

         pop       di
         pop       si
         pop       cx
         ret

InfoSoub ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ textu DS:SI v informa‡n¡m © dku
; -----------------------------------------------------------------------------

InfoDis0 PROC      NEAR

         push      di
         call      InfoClr                  ; vymaz n¡ bufferu inform. © dku
         call      InfoDek                  ; dek¢dov n¡ textu
         call      InfoDisp                 ; zobrazen¡ informa‡n¡ho © dku
         pop       di
         ret

InfoDis0 ENDP

; -----------------------------------------------------------------------------
;        vymaz n¡ bufferu informa‡n¡ho © dku
; -----------------------------------------------------------------------------

InfoClr  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      es

; ------ vymaz n¡ bufferu informa‡n¡ho © dku

         push      ds
         pop       es
         mov       di,offset InfoBuf        ; buffer informa‡n¡ho © dku
         mov       cx,76                    ; d‚lka bufferu informa‡n¡ho © dku
         cld
         mov       ah,ds:[ColInf]           ; barva informa‡n¡ho © dku
         mov       al," "                   ; mazac¡ znak mezery
         rep       stosw                    ; vymaz n¡ informa‡n¡ho © dku
         mov       di,offset InfoBuf        ; buffer informa‡n¡ho © dku

; ------ n vrat registr–

         pop       es
         pop       cx
         pop       ax
         ret

InfoClr  ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ textu DS:SI o d‚lce CL do inform. bufferu (od adresy DI)
; -----------------------------------------------------------------------------

InfoDek0 PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      es

; ------ dek¢dov n¡ textu

         push      ds
         pop       es
         mov       ah,ds:[ColInf]           ; barva informa‡n¡ho © dku
         cld
         mov       ch,0
         jcxz      InfoDk03
InfoDk01:lodsb                              ; na‡ten¡ znaku textu
         cmp       di,offset InfoBuf+2*76   ; je konec bufferu ?
         jae       InfoDk02                 ; je konec bufferu
         stosw                              ; ulo‘en¡ znaku do bufferu
InfoDk02:loop      InfoDk01                 ; dal¨¡ znak

; ------ n vrat registr–

InfoDk03:pop       es
         pop       cx
         pop       ax
         ret

InfoDek0 ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ textu ASCIIZ DS:SI do informa‡n¡ho bufferu (od adresy DI)
; -----------------------------------------------------------------------------

InfoDek  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      es

; ------ dek¢dov n¡ textu

         push      ds
         pop       es
         mov       ah,ds:[ColInf]           ; barva informa‡n¡ho © dku
         cld
InfoDek1:lodsb                              ; na‡ten¡ znaku textu
         cmp       al,0                     ; je konec textu ?
         je        InfoDek3                 ; je konec textu
         cmp       di,offset InfoBuf+2*76   ; je konec bufferu ?
         jae       InfoDek1                 ; je konec bufferu
         stosw                              ; ulo‘en¡ znaku do bufferu
         jmp       short InfoDek1           ; dal¨¡ znak

; ------ n vrat registr–

InfoDek3:pop       es
         pop       ax
         ret

InfoDek  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ informa‡n¡ho © dku
; -----------------------------------------------------------------------------

InfoDisp PROC      NEAR

; ------ £schova registr–

         push      cx
         push      si
         push      di
         push      es

; ------ zobrazen¡ textu

         mov       es,ds:[SegmVRAM]         ; segment videopamˆti
         mov       cx,76                    ; d‚lka textu
         mov       di,160+2*2               ; adresa k ulo‘en¡ textu
         mov       si,offset InfoBuf        ; buffer informa‡n¡ho © dku
         cld
         rep       movsw                    ; p©enesen¡ textu do videopamˆti

; ------ n vrat registr–

         pop       es
         pop       di
         pop       si
         pop       cx
         ret

InfoDisp ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ podkladov‚ho r mu pro volby
; -----------------------------------------------------------------------------

DispRam  PROC      NEAR

         call      DispRm0                  ; zobrazen¡ horn¡ ‡ sti r mu

; ------ £schova registr–

         push      ax
         push      cx
         push      di
         push      es

; ------ p©¡prava registr–

         mov       es,ds:[SegmVRAM]         ; segment videopamˆti
         mov       di,24*160                ; adresa spodn¡ linky
         mov       ah,ds:[ColRam]           ; barva podkladov‚ho r mu
         cld

; ------ zobrazen¡ doln¡ linky

         mov       al,"È"                   ; lev˜ spodn¡ roh
         stosw                              ; ulo‘en¡ lev‚ho spodn¡ho rohu
         mov       al,"Í"                   ; vodorovn  linka
         mov       cx,78                    ; d‚lka linky
         rep       stosw                    ; ulo‘en¡ vodorovn‚ linky
         mov       al,"¼"                   ; prav˜ spodn¡ roh
         stosw                              ; ulo‘en¡ prav‚ho spodn¡ho rohu

; ------ n vrat registr–

         pop       es
         pop       di
         pop       cx
         pop       ax
         ret

DispRam  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ podkladov‚ho r mu - horn¡ ‡ st bez spodn¡ linky
; -----------------------------------------------------------------------------

DispRm0  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      di
         push      es

; ------ p©¡prava registr–

         mov       es,ds:[SegmVRAM]         ; segment videopamˆti
         xor       di,di
         mov       ah,ds:[ColRam]           ; barva podkladov‚ho r mu
         cld

; ------ zobrazen¡ horn¡ linky

         mov       al,"É"                   ; lev˜ horn¡ roh
         stosw                              ; ulo‘en¡ lev‚ho horn¡ho rohu
         mov       al,"Í"                   ; vodorovn  linka
         mov       cx,70                    ; d‚lka linky
         rep       stosw                    ; ulo‘en¡ vodorovn‚ linky
         add       di,2*8
         mov       al,"»"                   ; prav˜ horn¡ roh
         stosw                              ; ulo‘en¡ prav‚ho horn¡ho rohu
         mov       byte ptr ds:[CitSek],1
         pushf
         push      cs
         call      Int081                   ; zobrazen¡ ‡asu

; ------ zobrazen¡ informa‡n¡ho © dku

         mov       al,"º"                   ; lev  strana
         stosw                              ; ulo‘en¡ lev‚ strany
         mov       al," "                   ; oddˆlovac¡ mezera
         mov       cl,78                    ; d‚lka mezery
         rep       stosw                    ; ulo‘en¡ oddˆlovac¡ mezery
         mov       al,"º"                   ; prav  strana
         stosw                              ; ulo‘en¡ prav‚ strany

; ------ zobrazen¡ st©edn¡ linky

         mov       al,"Ì"                   ; lev  strana
         stosw                              ; ulo‘en¡ lev‚ strany
         mov       al,"Í"                   ; vodorovn  linka
         mov       cl,78                    ; d‚lka linky
         rep       stosw                    ; ulo‘en¡ vodorovn‚ linky
         mov       al,"¹"                   ; prav  strana
         stosw                              ; ulo‘en¡ prav‚ strany

; ------ zobrazen¡ vnit©n¡ch linek

         mov       bx,25-4                  ; po‡et vnit©n¡ch © dk–
DispRm02:mov       al,"º"                   ; lev  strana
         stosw                              ; ulo‘en¡ lev‚ strany
         mov       cl,78                    ; d‚lka mezery
         mov       al," "                   ; oddˆlovac¡ mezera
         rep       stosw                    ; ulo‘en¡ oddˆlovac¡ mezery
         mov       al,"º"                   ; prav  strana
         stosw                              ; ulo‘en¡ prav‚ strany
         dec       bx                       ; ‡¡ta‡ © dk–
         jnz       DispRm02                 ; dek¢dov n¡ dal¨¡ho © dku

; ------ n vrat registr–

         pop       es
         pop       di
         pop       cx
         pop       bx
         pop       ax
         ret

DispRm0  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ funk‡n¡ch kl ves
; -----------------------------------------------------------------------------

DispFn0: mov       byte ptr ds:[OldPresm],0ffh

DispFn   PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ test stavu p©esmyka‡–

         mov       ah,2
         int       16h                      ; test stavu p©esmyka‡–
         and       al,0fh
         cmp       al,ds:[OldPresm]
         je        DispFn9
         mov       ds:[OldPresm],al

; ------ adresa n povˆdy k funk‡n¡m kl ves m

         mov       si,offset TxtFHlp        ; z kladn¡ n povˆda
         test      al,bit0 + bit1 + bit2 + bit3 ; je nˆjak˜ p©esmyka‡ ?
         jz        DispFn3                  ; nen¡ ‘ dn˜ p©esmyka‡
         add       si,10*7                  ; n povˆda k p©esmyka‡i Shift-
         test      al,bit2 + bit3           ; je p©esmyka‡ Ctrl- nebo Alt- ?
         jz        DispFn3                  ; je pouze p©esmyka‡ Shift-
         add       si,10*7                  ; n povˆda k p©esmyka‡i Ctrl-
         test      al,bit3                  ; je p©esmyka‡ Alt- ?
         jz        DispFn3                  ; nen¡ - je p©esmyka‡ Ctrl-
         add       si,10*7                  ; jinak p©esmyka‡ Alt-

; ------ p©¡prava k dek¢dov n¡ n povˆdy

DispFn3: mov       es,ds:[SegmVRAM]         ; segment videopamˆti
         mov       di,24*160                ; adresa k dek¢dov n¡ n povˆdy
         mov       bl,"1"                   ; ‡¡slo prvn¡ kl vesy
         mov       dx,word ptr ds:[ColFn1]  ; barva funk‡n¡ch kl ves
         cld

; ------ dek¢dov n¡ ‡¡sla kl vesy

DispFn4: mov       ah,dl                    ; barva ‡¡sla funk‡n¡ kl vesy
         mov       al,bl
         stosw                              ; ulo‘en¡ ‡¡sla funk‡n¡ kl vesy

; ------ dek¢dov n¡ textu kl vesy

         mov       cx,7                     ; d‚lka textu kl vesy
         mov       ah,dh                    ; barva textu funk‡n¡ kl vesy
DispFn5: lodsb                              ; na‡ten¡ znaku
         stosw
         loop      DispFn5

; ------ p©¡prava k dal¨¡ kl vese

         cmp       bl,"0"                   ; byla posledn¡ kl vesa ?
         je        DispFn9                  ; posledn¡ kl vesa - konec
         inc       bx                       ; zv˜¨en¡ ‡¡sla kl vesy
         cmp       bl,"9"+1                 ; je kl vesa F10 ?
         jne       DispFn4                  ; nen¡
         mov       bl,"0"                   ; kl vesa F10
         jmp       short DispFn4

; ------ n vrat registr–

DispFn9: pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispFn   ENDP

; *****************************************************************************
;                    skok na obsluhu podle BX
; -----------------------------------------------------------------------------
; Procedura se vol  instrukc¡ CALL JumpBX, za kterou n sleduje tabulka
; skok–. Procedura zmˆn¡ svou n vratovou adresu na adresu podle nalezen‚
; polo‘ky v tabulce (nebo podle polo‘ky pro nenalezenou hodnotu).
; -----------------------------------------------------------------------------
; VSTUP: v z sobn¡ku slovo (n vratov  adresa NEAR) = za‡ tek tabulky skok–
;             stuktura tabulky: 1 slovo testovan  hodnota BX
;                               1 slovo adresa NEAR obsluhy
;             konec tabulky: 1 slovo = 0 (p©¡znak konce tabulky)
;                            1 slovo adresa NEAR obsluhy p©i nenalezen¡ k¢du
; *****************************************************************************

JumpBX   PROC      NEAR

; ------ £schova registr–

                                            ; SS:[BP+4] = IP
         push      si                       ; SS:[BP+2] = SI
         push      bp                       ; SS:[BP+0] = BP
         mov       bp,sp

; ------ nalezen¡ hodnoty v tabulce

         mov       si,ss:[bp+4]             ; offset adresy tabulky
JumpBX1: cmp       word ptr ds:[si],0       ; je konec tabulky ?
         je        JumpBX2                  ; konec tabulky - nenalezeno
         cmp       word ptr ds:[si],bx      ; je to hledan  hodnota ?
         je        JumpBX2                  ; hodnota nalezena
         add       si,4                     ; adresa dal¨¡ polo‘ky
         jmp       short JumpBX1            ; test dal¨¡ polo‘ky

; ------ nastaven¡ n vratov‚ adresy podle tabulky

JumpBX2: mov       si,ds:[si+2]             ; adresa skoku
         mov       ss:[bp+4],si             ; nov  n vratov  adresa

; ------ n vrat registr–

         pop       bp
         pop       si
         ret

JumpBX   ENDP

; -----------------------------------------------------------------------------
;        vypr zdnˆn¡ bufferu kl vesnice
; -----------------------------------------------------------------------------

FlushChr PROC      NEAR

         push      ax
FlushCh1:mov       ah,1
         int       16h
         jz        FlushCh2                 ; nen¡ dal¨¡ kl vesa
         mov       ah,0
         int       16h                      ; zru¨en¡ kl vesy z bufferu
         jmp       short FlushCh1
FlushCh2:pop       ax
         ret

FlushChr ENDP

; -----------------------------------------------------------------------------
;        vstup znaku z kl vesnice s obsluhou funk‡n¡ch kl ves
; -----------------------------------------------------------------------------

InpChrF  PROC      NEAR

; ------ £schova registr–

         push      ax

; ------ ‡ek n¡ na zad n¡ kl vesy

InpChrF1:mov       ah,1
         int       16h                      ; test stavu kl vesnice
         jnz       InpChrF2                 ; znak je p©ipraven
         call      DispFn                   ; zobrazen¡ funk‡n¡ch kl ves
         jmp       short InpChrF1

; ------ n vrat registr– a vstup znaku z kl vesnice

InpChrF2:pop       ax

InpChrF  ENDP                               ; pokra‡uje vstup znaku !!!

; -----------------------------------------------------------------------------
;        vstup znaku z kl vesnice
; -----------------------------------------------------------------------------

InpChr   PROC      NEAR

; ------ vstup znaku z kl vesnice

         push      ax
         mov       ah,0
         int       16h
         or        ax,ax
         jnz       InpChr2                  ; nen¡ Ctrl-Break
         mov       ax,11bh                  ; n hrada kl vesou ESC
InpChr2: xchg      ax,bx                    ; BX <- znak z kl vesnice
         pop       ax
         ret

InpChr   ENDP

; -----------------------------------------------------------------------------
;        vypnut¡ kurzoru
; -----------------------------------------------------------------------------

KurzOff  PROC      NEAR

         push      dx
         mov       dx,25*HI                 ; prvn¡ © dek "za rohem"
         call      SetKurz                  ; nastaven¡ pozice kurzoru
         pop       dx
         ret

KurzOff  ENDP

; -----------------------------------------------------------------------------
;        nadstaven¡ pozice kurzoru DX
; -----------------------------------------------------------------------------

SetKurz  PROC      NEAR

         push      ax
         push      bx
         mov       bh,0                     ; aktivn¡ videostr nka
         mov       ah,2                     ; funkce - nastaven¡ pozice kurzoru
         call      Int10P                   ; nastaven¡ pozice kurzoru
         pop       bx
         pop       ax
         ret

SetKurz  ENDP

; -----------------------------------------------------------------------------
;        obsluha chyby
; -----------------------------------------------------------------------------

INT24    PROC      FAR

         mov       al,0
INT23:   iret

INT24    ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 13h s £schovou registr–
; -----------------------------------------------------------------------------

Int13    PROC      NEAR

         push      bp
         push      ds
         int       13h
         pop       ds
         pop       bp
         ret

Int13    ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 10 s £schovou registr–
; -----------------------------------------------------------------------------

Int10P   PROC      NEAR

         pushf
         push      si
         push      di
         push      bp
         push      ds
         push      es

         int       10h

         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         popf
         ret

Int10P   ENDP

; -----------------------------------------------------------------------------
;        obsluha zobrazen¡ ‡asu bˆhem INT 08h
; -----------------------------------------------------------------------------

Int08    PROC      FAR

; ------ vol n¡ p–vodn¡ obsluhy

         pushf
         call      dword ptr cs:[Old08]

; ------ ‡¡t n¡ zobrazen¡ ‡asu

         dec       byte ptr cs:[CitSek]
         jz        Int081
         iret

; ------ £schova registr–

Int081:  push      ax
         push      bx
         push      cx
         push      dx
         push      di
         push      ds
         push      es

; ------ aktu ln¡ stav ‡¡ta‡e ‡asu

         cld
         xor       ax,ax
         mov       ds,ax                    ; DS <- 0
         mov       ax,ds:[046ch]            ; ‡ten¡ ni‘¨¡ ‡ sti ‡¡ta‡e ‡asu
         mov       dx,ds:[046eh]            ; ‡ten¡ vy¨¨¡ ‡ sti ‡¡ta‡e ‡asu

         push      cs
         pop       ds                       ; DS <- datov˜ segment
         mov       es,ds:[SegmVRAM]
         mov       di,2*71

         mov       cl,4                     ; po‡et rotac¡
         shl       dx,cl                    ; vy¨¨¡ slovo * 16
         mov       bx,ax                    ; ni‘¨¡ slovo ‡¡ta‡e ‡asu
         mov       cl,12
         shr       bx,cl                    ; nejvy¨¨¡ 4 bity ni‘¨¡ho slova
         add       dx,bx                    ; p©enos 4 bit– do vy¨¨¡ho slova
         mov       cl,4
         shl       ax,cl                    ; ni‘¨¡ slovo * 16
         mov       bx,17478
         div       bx                       ; ‡¡ta‡ ‡asu / 1092.375
         push      dx                       ; £schova zbytku v minutˆ
         mov       bx,60                    ; po‡et minut v hodinˆ
         xor       dx,dx                    ; DX <- 0, AX=po‡et minut
         div       bx                       ; v˜po‡et hodiny a minuty
         push      dx                       ; £schova minuty

                                          ;* zobrazen¡ £daje hodin
         mov       ah,ds:[ColDat]
         call      Disp2Nm0                 ; zobrazen¡ hodiny
         mov       al,":"                   ; oddˆlovac¡ znak
         stosw                              ; zobrazen¡ oddˆlovac¡ho znaku

                                          ;* zobrazen¡ £daje minut
         pop       ax                       ; n vrat minut
         mov       ah,ds:[ColDat]
         call      Disp2Nm0                 ; zobrazen¡ minuty
         mov       al,":"                   ; oddˆlovac¡ znak
         stosw                              ; zobrazen¡ oddˆlovac¡ho znaku

                                          ;* zobrazen¡ £daje sekund
         pop       ax                       ; n vrat zbytku do 1 minuty
         mov       bx,60                    ; po‡et sekund v minutˆ
         mul       bx                       ; v˜po‡et po‡tu sekund a setin
         mov       bx,17478                 ; p©evod na abs. £daj
         div       bx                       ; v˜po‡et po‡tu sekund

                                          ;* v˜po‡et ‡ sti sekundy
         push      ax                       ; £schova po‡tu sekund
         xchg      ax,dx                    ; zbytek do 1 sekundy
         mov       bx,18                    ; po‡et impuls– v 1 sekundˆ
         mul       bx                       ; v˜po‡et po‡tu impuls– v sekundˆ
         mov       bx,17478                 ; p©evod na abs. £daj
         div       bx                       ; v˜po‡et po‡tu ‡ sti sekundy
         sub       al,18                    ; -zbytek do sekundy
         neg       al                       ; zbytek do sekundy
         inc       ax
         mov       ds:[CitSek],al           ; ‡¡ta‡ obsluhy hodin
         pop       ax                       ; n vrat po‡tu sekund

         mov       ah,ds:[ColDat]
         call      Disp2Nm0

; ------ n vrat registr–

         pop       es
         pop       ds
         pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         iret

Int08    ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ ‡¡sla AL 2 ‡¡slice s dosplnˆn¡m nuly (AH=barva)
; -----------------------------------------------------------------------------

Disp2Nm0 PROC      NEAR

; ------ dek¢dov n¡ ‡¡sla

         push      cx
         push      ax

         mov       ah,0
         mov       cl,10
         div       cl                       ; v˜po‡et ‡¡slic
         add       ax,"00"                  ; korekce na ASCII ‡¡slice
         xchg      ax,cx

         pop       ax

; ------ zobrazen¡ ‡¡slice des¡tek

         mov       al,cl                    ; des¡tky
         stosw                              ; zobrazen¡ ‡¡slice des¡tek

; ------ zobrazen¡ ‡¡slice jednotek

         mov       al,ch                    ; jednotky
         stosw                              ; zobrazen¡ ‡¡slice jednotek
         pop       cx
         ret

Disp2Nm0 ENDP

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                            Vno©en‚ soubory
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

INCLUDE  HEXAEDI.ASM                        ; editace objekt–

INCLUDE  HEXADSK.ASM                        ; obsluha disku a objekt–

INCLUDE  HEXADIS.ASM                        ; obsluha zobrazen¡

INCLUDE  HEXADAT.ASM                        ; data

; ------ z sobn¡k

         dw        200h dup(0)              ; z sobn¡k
Zasob    label     word

Code     ENDS
         END       Start

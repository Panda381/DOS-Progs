
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                          Definice ©azen¡ segment–
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

StackS   SEGMENT   PARA STACK 'STACK'       ; z sobn¡k
StackS   ENDS

CodeLod  SEGMENT   BYTE PUBLIC              ; zavadˆ‡
CodeLod  ENDS

Data     SEGMENT   BYTE PUBLIC              ; datov˜ segment
Data     ENDS

CodeInt  SEGMENT   BYTE PUBLIC              ; p©eru¨en¡
CodeInt  ENDS

CodeDis  SEGMENT   BYTE PUBLIC              ; zobrazen¡
CodeDis  ENDS

CodeKey  SEGMENT   BYTE PUBLIC              ; kl vesy
CodeKey  ENDS

CodeWin  SEGMENT   BYTE PUBLIC              ; okna
CodeWin  ENDS

CodeDisk SEGMENT   BYTE PUBLIC              ; disk
CodeDisk ENDS

CodeDek  SEGMENT   BYTE PUBLIC              ; dek¢dov n¡
CodeDek  ENDS

CodeLin  SEGMENT   BYTE PUBLIC              ; p©¡kazov˜ © dek
CodeLin  ENDS

CodeHlp  SEGMENT   BYTE PUBLIC              ; n povˆda
CodeHlp  ENDS

CodeMnu  SEGMENT   BYTE PUBLIC              ; menu
CodeMnu  ENDS

CodeFnd  SEGMENT   BYTE PUBLIC              ; hled n¡
CodeFnd  ENDS

CodeFil  SEGMENT   BYTE PUBLIC              ; soubory
CodeFil  ENDS

CodeUnd  SEGMENT   BYTE PUBLIC              ; obnoven¡
CodeUnd  ENDS

CodeTre  SEGMENT   BYTE PUBLIC              ; strom
CodeTre  ENDS

CodeZvl  SEGMENT   BYTE PUBLIC              ; zvl ¨tn¡
CodeZvl  ENDS

CodeDbf  SEGMENT   BYTE PUBLIC              ; datab ze
CodeDbf  ENDS

CodeZap  SEGMENT   BYTE PUBLIC              ; z pisn¡k
CodeZap  ENDS

CodeTab  SEGMENT   BYTE PUBLIC              ; tabulky
CodeTab  ENDS

CodeEdi  SEGMENT   BYTE PUBLIC              ; editor
CodeEdi  ENDS

CodeMem  SEGMENT   BYTE PUBLIC              ; pamˆŸ
CodeMem  ENDS

Code     SEGMENT   WORD PUBLIC              ; hlavn¡ startovac¡ modul
Code     ENDS

Konec0S  SEGMENT   PARA PUBLIC
Konec0S  ENDS

HelpS    SEGMENT   BYTE PUBLIC              ; n povˆda k menu
HelpS    ENDS

KonecS   SEGMENT   PARA PUBLIC              ; konec programu
KonecS   ENDS

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                              D E F I N I C E
;
;                    Definice konstant a symbol– programu 
;
; =============================================================================
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

DMVerze1 EQU       2                        ; hlavn¡ ‡¡slo verze
DMVerze2 EQU       2                        ; desetiny ‡¡sla verze
DMVerze3 EQU       0                        ; setiny ‡¡sla verze

;DEBUG    EQU       1                        ; p©ep¡na‡ - lad¡c¡ m¢d

CESK     EQU       1                        ; p©ep¡na‡ - ‡esk  verze
;SLOV     EQU       1                        ; p©ep¡na‡ - slovensk  verze
;ANGL     EQU       1                        ; p©ep¡na‡ - anglick  verze
;NEMC     EQU       1                        ; p©ep¡na‡ - nˆmeck  verze

; P©echodn‚ pomocn‚ soubory DOS Mana‘eru (automatick‚ ru¨en¡ $DOSMAN$.* !!!):
;  $DOSMAN$.HIS ..... historie povel– a voleb DOS Mana‘eru
;  $DOSMAN$.FIL ..... £schova ozna‡en¡ soubor– v adres ©¡ch
;  $DOSMAN$.BAT ..... posloupnost p©¡kaz– p©i prov dˆn¡ u‘ivatelsk˜ch funkc¡
;  $DOSMAN$.LST ..... seznam ozna‡en˜ch soubor– pro u‘ivatelskou funkci
;  $DOSMAN$.TRE ..... £schova stromov‚ struktury disk–
;  $DOSMAN$.FND ..... £schova nalezen˜ch soubor– funkce hled n¡ soubor– F7
;  $DOSMAN$.CFG ..... uschovan  konfigurace pro n vrat z p©¡kazu v m¢du BAT
;  $DOSMAN$.PRN ..... v˜stupn¡ tiskov˜ soubor (tisk soubor–)
;
; U‘ivatelsky definovan‚ pomocn‚ soubory DOS Mana‘eru (vytv ©eny u‘ivatelem):
;  DOSMAN.INI ....... inicializa‡n¡ nastaven¡ DOS Mana‘eru (konfigurace)
;  DOSMAN.DIA ....... kalend ©
;  FILEINFO ......... koment ©e k soubor–m
; -----------------------------------------------------------------------------
;        konstanty
; -----------------------------------------------------------------------------

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

BS       EQU       8
TAB      EQU       9
LF       EQU       10
FF       EQU       12
CR       EQU       13
EOF      EQU       26
ESCP     EQU       27

PSP_ENV  EQU       2ch                      ; adresa prost©ed¡ v PSP

; -----------------------------------------------------------------------------
;        omezen¡ programu, p©ep¡na‡e
; -----------------------------------------------------------------------------

MenuMax  EQU       30                       ; maxim ln¡ po‡et vˆtven˜ch menu
BlokMax  EQU       200                      ; maxim ln¡ po‡et datov˜ch blok–
FileMax  EQU       86                       ; max.d‚lka pln‚ specifikace souboru
FileDMax EQU       68                       ; max. d‚lka specifikace adres ©e
DiskMax  EQU       32                       ; maxim ln¡ po‡et disk– (t‚‘ [\]^_`)
DirMax   EQU       32                       ; maxim ln¡ hloubka adres ©e
MaxVMod  EQU       21                       ; maxim ln¡ po‡et videom¢d–
MaxUserM EQU       20                       ; maxim ln¡ po‡et u‘ivatelsk˜ch menu
MaxUFors EQU       100                      ; maxim ln¡ po‡et cykl– FOR u‘. menu
MAXFORM  EQU       15                       ; max. mno‘stv¡ form t– form tov n¡

HelpHMax EQU       20                       ; maxim lnˆ str nek historie HELP

TextFndX EQU       100                      ; maxim ln¡ d‚lka hledan‚ho textu
TextSubX EQU       100                      ; maxim ln¡ d‚lka n hradn¡ho textu


MinSP    EQU       100h                     ; minim ln¡ adresa SP

FileTMax EQU       10                       ; maxim lnˆ u‘iv. typ– soubor–

MaxAFile EQU       20000                    ; maxim ln¡ po‡et soubor– v adres ©i

;InfoKPoz EQU       68                       ; po‡ te‡n¡ pozice inform. kurzoru
InfoKSir EQU       12                       ; ¨¡©ka informa‡n¡ho kurzoru

; ------ textov˜ editor

BLOKBLOK EQU       8000h                    ; velikost jednoho datov‚ho bloku
BLOKTEST EQU       0c000h                   ; hranice pro testov n¡ bloku
BLOKMAXN EQU       ((65535 - EdiABlok)/EdiBlokS)-1-4; maxim ln¡ po‡et blok– souboru
MAXVTAB  EQU       8*30                     ; maxim lnˆ pozic promˆn. tabul tor–

; -----------------------------------------------------------------------------
;        tabulka DTA - funkce nalezen¡ souboru
; -----------------------------------------------------------------------------

;DTAAlok2 EQU       0fh                      ; (2) aloka‡n¡ blok DOS >= 3.20
;DTAAlok1 EQU       13h                      ; (2) aloka‡n¡ blok DOS < 3.20

DTAAtrib EQU       15h                      ; (1) atributy nalezen‚ho souboru
DTATime  EQU       16h                      ; (2) ‡as nalezen‚ho souboru
DTADate  EQU       18h                      ; (2) datum nalezen‚ho souboru
DTASize  EQU       1ah                      ; (4) velikost nalezen‚ho souboru
DTAName  EQU       1eh                      ; (13) jm‚no nalez. souboru ASCIIZ
                                            ; (1) ... nepou‘ito
DTALIdnt EQU       2ch                      ; (2) identifik tor pro dlouh‚ hled n¡
                                            ;     (-1 = nen¡ otev©en)

DTAMax   EQU       46                       ; velikost tabulky DTA

; -----------------------------------------------------------------------------
;        definice symbol– pro n povˆdu
; -----------------------------------------------------------------------------

HelpDef  STRUC
INCLUDE  ASM\HELP@DEF.ASM                   ; symboly odkaz– do n povˆdy
HelpDef  ENDS

; ------ znaky p©ep¡na‡– pro menu

HlpChBld EQU       0                        ; znak pro zv˜raznˆn¡
HlpChHey EQU       1                        ; znak ozna‡en¡ kl vesy
HlpChMnu EQU       2                        ; znak ozna‡en¡ menu
HlpChHot EQU       3                        ; znak hork‚ kl vesy menu
HlpChSym EQU       4                        ; znak symbolu
HlpChStn EQU       5                        ; znak barvy st¡nu
HlpChNul EQU       6                        ; znak norm ln¡ barvy
HlpChLin EQU       7                        ; znak konce © dku

; -----------------------------------------------------------------------------
;        atributy soubor–
; -----------------------------------------------------------------------------

RO       EQU       bit0                     ; R/O
HID      EQU       bit1                     ; HID
SYS      EQU       bit2                     ; SYS
VOL      EQU       bit3                     ; VOL
DIR      EQU       bit4                     ; DIR
ARC      EQU       bit5                     ; ARC

ATRU     EQU       bit3                     ; £schova ozna‡en¡ polo‘ky
ATRO     EQU       bit6                     ; ozna‡en¡ polo‘ky
ATRT     EQU       bit7                     ; p©¡znak typu polo‘ky (1=soubor)

; -----------------------------------------------------------------------------
;        noty pro hran¡ melodie
; -----------------------------------------------------------------------------

MC       EQU       0                        ; C
MCI      EQU       1                        ; C#
MD       EQU       2                        ; D
MDI      EQU       3                        ; D#
ME       EQU       4                        ; E
MF       EQU       5                        ; F
MFI      EQU       6                        ; F#
MG       EQU       7                        ; G
MGI      EQU       8                        ; G#
MA       EQU       9                        ; A
MAI      EQU       10                       ; A#
MH       EQU       11                       ; H

M32      EQU       1                        ; d‚lka 1/32
M16      EQU       2                        ; d‚lka 1/16
M8       EQU       4                        ; d‚lka 1/8
M4       EQU       8                        ; d‚lka 1/4
M2       EQU       16                       ; d‚lka 1/2
M1       EQU       32                       ; d‚lka cel 

MO0      EQU       1                        ; okt va 0
MO1      EQU       13                       ; okt va 1
MO2      EQU       25                       ; okt va 2
MO3      EQU       37                       ; okt va 3
MO4      EQU       49                       ; okt va 4
MO5      EQU       61                       ; okt va 5
MO6      EQU       73                       ; okt va 6
MO7      EQU       85                       ; okt va 7
MO8      EQU       97                       ; okt va 8
MO9      EQU       109                      ; okt va 9

MO       EQU       MO4                      ; bˆ‘n  okt va

; *****************************************************************************
;
;         Definice adres ©ov‚ho okna, okna seznamu a okna stromu
;
; *****************************************************************************

; ------ pole pro hled n¡ soubor– (struktura mus¡ souhlasit s hled n¡m FIL1.ASM)

AWinFilS STRUC
AWinFAtr db        ?                        ; (1) atributy soubor–
AWinFAtM db        ?                        ; (1) maska atribut– soubor–

AWinFT1  dw        ?                        ; (2) po‡ te‡n¡ ‡as souboru
AWinFT1M dw        ?                        ; (2) maska po‡ te‡n¡ho ‡asu souboru
AWinFT2  dw        ?                        ; (2) koncov˜ ‡as souboru
AWinFT2M dw        ?                        ; (2) maska koncov‚ho ‡asu souboru

AWinFD1  dw        ?                        ; (2) po‡ te‡n¡ datum souboru
AWinFD1M dw        ?                        ; (2) maska po‡ te‡n¡ho data souboru
AWinFD2  dw        ?                        ; (2) koncov‚ datum souboru
AWinFD2M dw        ?                        ; (2) maska koncov‚ho data souboru

AWinFSz1 dd        ?                        ; (4) minim ln¡ velikost souboru
AWinFSz2 dd        ?                        ; (4) maxim ln¡ velikost souboru

AWinFTxN dw        ?                        ; (2) d‚lka hledan‚ho textu (0=nen¡)
AWinFTxt db        50 dup(?)                ; (50) buffer hledan‚ho textu

AWinFKod db        ?                        ; (1) konverzn¡ k¢d souboru
                                            ;    0 = nen¡ konverze
                                            ;    bit 0: 1=ASCII ("U")
                                            ;    bit 1: 1=IBM ("I")
                                            ;    bit 2: 1=Kamenick˜ch ("K")
                                            ;    bit 3: 1=Latin 2 ("L")
                                            ;    bit 4: 1=KOI 8 ("O")
                                            ;    bit 5: 1=WINDOWS ("W")

AWinFPrm db        ?                        ; (1) parametry pro hled n¡
                                            ;    bit 0: 1=‡as vnˆ intervalu
                                            ;    bit 1: 1=datum vnˆ intervalu

AWinFilN dw        ?                        ; (2) d‚lka filtru soubor– (< 256)
AWinFilt db        256 dup(?)               ; (256) filtr soubor–

AWinFilS ENDS

; ------ struktura okna seznamu soubor–
;þ
AWinStru STRUC
AWinByts db        ?,?,?                    ; (3) d‚lka segmentu definice okna
AWinPrm0 db        ?                        ; (1) parametry okna 0
                                            ;      bit 0: 1=neuchov vat kurzor a
                                            ;               ozna‡en¡ (zmˆna adr.)
                                            ;      bit 1:
                                            ;      bit 2: 1=disk.informace zn m‚
                                            ;      bit 3: 1=ozna‡it odpov¡daj¡c¡ polo‘ky
                                            ;               (pro na‡¡t n¡ GetFFil)
                                            ;               a nehl sit na‡¡t n¡ adres ©e
                                            ;      bit 4: 1=pot©eba zobrazit okno
                                            ;      bit 5:
                                            ;      bit 6: 1=je CD-ROM disk
                                            ;      bit 7: 1=nezjistiteln‚
                                            ;               diskov‚ informace

AWinPrm1 db        ?                        ; (1) parametry okna 1 - typ a stav
                                            ;      bit 0:   1=okno prohl¡‘e‡e
                                            ;      bit 1: ADRES: 1=adres © na‡ten
                                            ;             STROM: 1=strom na‡ten
                                            ;             SEZNM: 1=seznam na‡ten
                                            ;      bit 2: ADRES: 1=(koment © m  b˜t ulo‘en)
                                            ;             STROM: 1=strom m  b˜t ulo‘en
                                            ;             SEZNM: 1=seznam m  b˜t ulo‘en
                                            ;      bit 3:   1=adres ©ov‚ okno
                                            ;      bit 4:   1=okno stromu
                                            ;      bit 5:   1=okno seznamu
                                            ;      bit 6: 1=koment © byl hled n
                                            ;      bit 7: ADRES: 1=koment © nen¡ cel˜
                                            ;             STROM: 1=chyba pamˆti stromu
                                            ;             SEZNM: (1=chyba pamˆti seznamu)

AWinPrm2 db        ?                        ; (1) parametry okna 2 - konfigurace
                                            ;      bit 0: 1=okno se net©¡d¡
                                            ;      bit 1,2: 0=podle jm‚na
                                            ;               1=podle p©¡pony
                                            ;               2=podle velikosti
                                            ;               3=podle data a ‡asu
                                            ;      bit 3: 1=sestupn‚ t©¡dˆn¡
                                            ;      bit 4: 1=nen¡ stavov˜ © dek
                                            ;      bit 5,6: 0=Pln‚ zobrazen¡
                                            ;               1=Zkr cen‚ zobrazen¡
                                            ;               2=Komentovan‚ zobrazen¡
                                            ;               3=Dlouh  jm‚na
                                            ;      bit 7: 1=zobrazeny atributy

; ------ definice na‡ten˜ch soubor– (pro adres © = po‡tu zobrazen˜ch polo‘ek)

AWinSouR dw        ?                        ; (2) po‡et na‡ten˜ch soubor–

; ------ definice zobrazen˜ch soubor–

AWinSouN dw        ?                        ; (2) po‡et zobrazen˜ch polo‘ek
AWinSouI dd        ?                        ; (4) adresa tabulky index– (offset)
                                            ;   (normalizovan˜ SEGMENT:OFFSET !)
; ------ definice kurzoru

AWinFrst dw        ?                        ; (2) prvn¡ zobrazen˜ soubor
AWinKurz dw        ?                        ; (2) soubor s kurzorem

; ------ aktivn¡ adres © okna (zachovat zarovn n¡ na sudou adresu)

AWinDNum dw        ?                        ; (2) d‚lka textu adres ©e
AWinDir  db        ?                        ; (1) disk adres ©ov‚ho okna ASCII
         db        ?                        ; (1) oddˆlova‡ disku ":"
         db        ?                        ; (1) inicializa‡n¡ lom¡tko "\"
         db        250 dup(?)               ; (250) adres © adres ©ov‚ho okna
                                            ;  (ASCIIZ ©etˆzec bez koncov‚ho \)
AWinDir0 db        12 dup(?)                ; konec textu adres ©e
                                            ; (12) rezerva za adres ©em
                                            ;      pro p©ete‡en¡ p©i sestavov n¡

AWinDisk db        ?                        ; (1) ‡¡slo disku adres ©ov‚ho okna

; ------ informace o disku a adres ©i

AWinAlok dw        ?                        ; (2) velikost aloka‡n¡ho bloku 32..
AWinDMax dd        ?                        ; (4) celkov  kapacita disku
AWinDFre dd        ?                        ; (4) voln  kapacita disku

AWinDFil dw        ?                        ; (2) po‡et zobrazen˜ch soubor–
AWinDSum dd        ?                        ; (4) obsazen  kapacita soubory

; ------ ozna‡en‚ soubory

AWinSNum dw        ?                        ; (2) po‡et ozna‡en˜ch soubor–
AWinSSum dd        ?                        ; (4) sou‡et kapacit soubor–

; ------ definice pozn mek

AWinKomS dw        ?                        ; (2) ‡¡slo segmentu pozn mek
AWinKomN dw        ?                        ; (2) po‡et bajt– pozn mek k soub.
                                               ; (2) po‡et polo‘ek v tabulce
                                               ;     adres ©– k hled n¡ p©i hled n¡
AWinKomI dd        ?                        ; (4) adresa tabulky index– koment.
                                            ;     (normalizovan˜ SEGMENT:OFFSET)

AWinKomA dw        ?                        ; (2) adresa nadpisu v seg. pozn mek
AWinKomD dw        ?                        ; (2) d‚lka nadpisu v seg. pozn mek
                                            ;             (bez koncov‚ 0)
   AWinFndA EQU       AWinKomA                 ; (4) adresa k ulo‘en¡ polo‘ky
                                               ;     p©i vyhled v n¡ soubor–

AWinKomB dw        ?                        ; (2) za‡ tek pozn mek k soubor–m

; ------ n vˆ¨t¡ disku

AWinLabN db        ?                        ; (1) po‡et znak– n vˆ¨t¡ disku
AWinLab  db        11 dup(?)                ; (11) n vˆ¨t¡ disku

; ------ filtr soubor– (mus¡ b˜t stejn  struktura jako pro hled n¡ soubor– !)

AWinFilP db        ?                        ; (1) parametry filtru
                                            ;      bit 0: 1=maska p©i na‡¡t n¡
                                            ;      bit 2: 1=adres © na‡¡st v‘dy
                                            ;      bit 4: 1=nena‡¡tat ".."
                                            ;      bit 6,7: 0=v¨echny
                                            ;               1=programy
                                            ;               2=maska
AWinFilM db        ?                        ; (1) d‚lka prvn¡ masky

AWinFilF AWinFilS <>                        ; pole pro hled n¡ soubor–

AWinStru ENDS

AWin     EQU       SIZE AWinStru            ; d‚lka definice adres. okna

; ------ seznam soubor–

AWinSoub EQU       AWin                     ; seznam na‡ten˜ch soubor–

                                            ; N sleduje:
                                            ; - seznam soubor–
                                            ; - tabulka index– soubor– (3 B)
                                            ; - tabulka index– koment ©– (2 B)
                                            ;    (pro strom a seznam nen¡ !!!)

; Pro okno seznamu:
; Tabulka index– koment ©– se pou‘¡v  jako adresy adres ©– k prohled n¡ (3 B).
; Polo‘ka [AWinKomN] ud v  po‡et polo‘ek v indexov‚ tabulce koment ©–.
; segment = -1 posun o hladinu adres ©e n¡‘e (konec podadres ©– jednoho adres ©e)
; Indexy koment ©– se ukl daj¡ shora smˆrem dol– (tj. posouv  se adresa
; po‡ tku tabulky) - adresa po‡ tku nen¡ normalizovan , segment je shodn˜
; se segmentem tabulky index– polo‘ek (aby bylo mo‘n‚ porovn vat offsety).

; Pro strom:
; Tabulka index– koment ©– se pou‘¡v  jako indexy adres ©– k prohled n¡.

; -----------------------------------------------------------------------------
;        Definice filtru soubor–
; -----------------------------------------------------------------------------

; - bˆ‘n˜ text ASCII, polo‘ky maj¡ velk  p¡smena, jsou navz jem oddˆleny
;   jednou mezerou, d‚lka jednoho jm‚na max. 8 znak–, mohou obsahovat ? a *
;   Prvn¡ znak jm‚na souboru "-" = z porn  maska.

; -----------------------------------------------------------------------------
;        Segment koment ©–
; -----------------------------------------------------------------------------
; Na za‡ tku segmentu je 1 slovo = po‡et bajt– v segmentu celkem, ur‡uje konec.
; Jeden © dek:         (1) d‚lka © dku x+1 (text + koncov  0)
;                      (x) text © dku (0 a‘ 254 znak–)
;                      (1) koncov  0 © dku
; Mezery z konc– © dk– jsou odstranˆny. ž dky za‡¡naj¡c¡ mezerami nebo
; tabul tory na za‡ tku segmentu jsou nadpis. ž dky neza‡¡naj¡c¡ mezerami ani
; tabul tory jsou koment ©e k soubor–m - na za‡ tku © dku je jm‚no souboru
; zkonvertovan‚ na velk  p¡smena. N sleduj¡c¡ © dky za‡¡naj¡c¡ mezerami nebo
; tabul tory jsou pokra‡ov n¡m koment ©e - podrobnˆj¨¡ popis souboru.
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
;        Definice polo‘ky souboru v seznamu soubor– (d‚lka stand. ‡ sti 21 B)
; -----------------------------------------------------------------------------
FileStru STRUC
FileAtr  db        ?                        ; (1) atributy souboru
                                            ;       bit 0: 1=atribut R/O
                                            ;       bit 1: 1=atribut HID
                                            ;       bit 2: 1=atribut SYS
                                            ;    ...bit 3: 1=£schova ozna‡. ATRU
                                            ;       bit 4: 1=atribut DIR
                                            ;       bit 5: 1=atribut ARC
                                            ;    ...bit 6: 1=ozna‡. polo‘ky ATRO
                                            ;    ...bit 7: 1=platn  polo‘ka ATRT

FileName db        8 dup(?)                 ; (8) jm‚no souboru
FileExt  db        3 dup(?)                 ; (3) p©¡pona souboru
FileSize dd        ?                        ; (4) velikost souboru
                                            ;      (u adres ©– sou‡et velikost¡
                                            ;       soubor– v podadres ©¡ch)
FileDate dw        ?                        ; (2) datum souboru
                                            ;       bit 0-4: den
                                            ;       bit 5-8: mˆs¡c
                                            ;       bit 9-15: rok - 1980
FileTime dw        ?                        ; (2) ‡as souboru
                                            ;       bit 0-4: sekunda/2
                                            ;       bit 5-10: minuta
                                            ;       bit 11-15: hodina

FileATyp db        ?                        ; (1) typ adres ©ov‚ polo‘ky
                                            ;       0 = ".."
                                            ;       1 = adres ©
                                            ;       2 = HID/SYS
                                            ;       3 = program
                                            ;       4 = u‘iv. 0 (archiv)
                                            ;       5 = u‘iv. 1 (texty)
                                            ;       ....
                                            ;      -1 = ostatn¡

FileATSb EQU       0                        ; typ souboru ".."
FileATDr EQU       1                        ; typ souboru adres ©
FileATHS EQU       2                        ; typ souboru HID/SYS
FileATPr EQU       3                        ; typ souboru program
FileATU0 EQU       4                        ; typ souboru u‘ivatelsk˜ 0 (archiv)
FileATNo EQU       -1                       ; typ souboru - ostatn¡


FileStru ENDS
FileSumm EQU       SIZE FileStru            ; celkov  velikost polo‘ky souboru

; ------ Dlouh‚ jm‚no n sleduje V’DY za polo‘kou souboru. Nen¡-li, je d‚lka = 0.

FileLong EQU       FileSumm                 ; za‡ tek dlouh‚ho jm‚na souboru
                                            ;   (1) d‚lka jm‚na souboru (0=nen¡)
                                            ;   (x) text jm‚na souboru

; ------ definice polo‘ky stromu disku (pokra‡uje za polo‘kou souboru)

FileTStr STRUC
         FileStru <>                        ; tato ‡ st polo‘ky je stejn  se souborem
FileTLev db        ?                        ; (1) £rove¤ (hloubka) adres ©e
                                            ;      ROOT=0 ... 32
FileTPar db        ?                        ; (1) parametry polo‘ky stromu
                                            ;   bit 0: 1=adres © ovˆ©en
                                            ;   bit 1: 1=jsou podadres ©e
                                            ;   bit 2: 1=podadres ©e rozvinuty
                                            ;   bit 3: 1=bude adr. stejn‚ £rovnˆ
                                            ;   bit 4: 1=polo‘ka nalezena
                                            ;   bit 5:
                                            ;   bit 6: 1=je to aktivn¡ adres ©
                                            ;   bit 7: 1=polo‘ka zobrazena
FileTFil dw        ?                        ; (2) po‡et soubor– v adres ©i
FileTKap dd        ?                        ; (4) zabran  kapacita adres ©e
FileTSiz dd        ?                        ; (4) sou‡et velikost¡ polo‘ek

FileTStr ENDS
FileTSum EQU       SIZE FileTStr            ; celkov  celikost polo‘ky stromu

; ------ definice polo‘ky cesty v seznamu soubor– (hled n¡)

FilePStr STRUC
         db        ?                        ; d‚lka textu cesty (bit 7 = 0 !!!)
                                            ;  - polo‘ka odpov¡d  polo‘ce
                                            ;    atribut– soubor– FileAtr !!!
FilePth  db        ?                        ; za‡ tek textu cesty
FilePStr ENDS

; *****************************************************************************
;
;                    Definice editoru a prohl¡‘e‡e
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        Parametry okna 1 nebo 2 (offset v popisova‡i okna)
; -----------------------------------------------------------------------------

EdiWStru STRUC
; Zachovat po©ad¡ EdiParm1 a EdiParm2 !
EdiParm1 db        ?                        ; parametry editoru 1
                                            ;   bit 0: 1=jen zobrazen¡ (0=edit.)
                                            ;   bit 1: 1=HEX m¢d ÄÄÄÄ¿0=text.
                                            ;   bit 2: 1=BIN m¢d ÄÄÄÄÙ  m¢d
                                            ;   bit 3: 1=line l
                                            ;   bit 4: 1=tabul tor voln˜
                                            ;   bit 5: 1=vypnuta optimalizace
                                            ;   bit 6:
                                            ;   bit 7: 1=tabul tor bˆ‘n˜ znak

EdiParm2 db        ?                        ; parametry editoru 2
                                            ;   bit 0: 1=je odskok tabul toru
                                            ;   bit 1: 1=druh˜ znak HEX pole
                                            ;   bit 2: 1=ASCII ‡ st HEX pole
                                            ;   bit 3: 1=je dotaz p©i n hradˆ
                                            ;   bit 4: 1=nutno aktualizovat
                                            ;            pozici kurzoru
                                            ;   bit 5: 1=blok zobrazen
                                            ;   bit 6: 1=nutno aktualizovat
                                            ;            po‡ te‡n¡ © dek okna
                                            ;   bit 7: 1=nutno aktualizovat
                                            ;            © dek s kurzorem

; ------ ukazatele zobrazen‚ho po‡ tku okna

EdiBTop  dw        ?                        ; relativn¡ blok s po‡ tkem
EdiOTop  dw        ?                        ; offset po‡ t. © dku v bloku
EdiPTop  dd        ?                        ; po‡ te‡n¡ zobrazen  pozice
                                            ;  (pouze pro textov˜ m¢d)
EdiRTop  dd        ?                        ; ‡¡slo po‡ te‡n¡ho © dku
EdiOffsT dd        ?                        ; offset po‡ tku © dku v souboru

; ------ ukazatele kurzoru

EdiBKur  dw        ?                        ; relativn¡ blok © dku s kurz.
EdiOKur  dw        ?                        ; offset © dku s kurz. v bloku

EdiBBKur dw        ?                        ; relativn¡ blok s kurzorem
EdiOfKur dw        ?                        ; offset kurzoru v bloku

EdiPKur  dd        ?                        ; pozice kurzoru na © dku
EdiPLKur dd        ?                        ; d‚lka © dku s kurzorem (pozic)
EdiRKur  dd        ?                        ; ‡¡slo © dku s kurzorem
EdiOffsK dd        ?                        ; offset kurzoru v souboru
                                          ;* zachovat po©ad¡ !
EdiPKurR db        ?                        ; pozice kurzoru relativnˆ v oknˆ
EdiRKurR db        ?                        ; © dek kurzoru relativnˆ v oknˆ

; ------ ukazatele rozmˆr– okna (nemˆnit po©ad¡ !)

EdiPoz   db        ?                        ; po‡ te‡n¡ pozice okna
EdiRad   db        ?                        ; po‡ te‡n¡ © dek okna
EdiSir   db        ?                        ; ¨¡©ka okna
EdiVys   db        ?                        ; v˜¨ka okna

EdiLSir  dw        ?                        ; ¨¡©ka dat v m¢du BIN a HEX

EdiWStru ENDS

EdiWSumm EQU       SIZE EdiWStru            ; d‚lka definice jednoho okna

; -----------------------------------------------------------------------------
;        blok definice souboru
; -----------------------------------------------------------------------------
; Soubor je adresov n ©etˆzcem blok–, ukazuj¡c¡ch na bloky 32 KB.
; V bufferu bloku je pou‘it EdiW1+EdiBKur a EdiW1+EdiOKur jako ukazatel
; prov dˆn‚ operace ukl d n¡ nebo ‡ten¡ z bufferu. Ukazatele bloku
; uchov vaj¡ p–vodn¡ nastaven¡ ukl dan‚ho bloku.
; -----------------------------------------------------------------------------

EditStru STRUC

EdiByts  dw        ?                        ; velikost segmentu

EdiParm0 db        ?                        ; parametry souboru
                                            ;   bit 0: 1=© dek a pozice za‡ tku
                                            ;            bloku neplatn‚ pro text. m¢d
                                            ;   bit 1: 1=© dek a pozice konce
                                            ;            bloku neplatn‚ pro text. m¢d
                                            ;   bit 2: 1=pozice bloku zamˆnˆny
                                            ;   bit 3: 1=nutn  z mˆna pozic bloku
                                            ;   bit 4: 1=prob¡h  ozna‡en¡ SHIFT
                                            ;   bit 5: 1=pevn˜ konec SHIFT-

                                            ;   bit 7: 1=je to CLIPBOARD

EdiParm  db        ?                        ; parametry souboru
                                            ;   bit 0: 1=soubor modifikov n
                                            ;   bit 1:   (1=po‡et © dk– zji¨tˆn)
                                            ;            (odstranˆno z programu)
                                            ;   bit 2: 1=z kaz z pisu (zobr.)
                                            ;   bit 3: 1=soubor byl vytvo©en
                                            ;   bit 4: 1=soubor ulo‘en
                                            ;   bit 5:
                                            ;   bit 6: 1=sloupcov˜ blokÄ¿0=text.
                                            ;   bit 7: 1=© dkov˜ blok ÄÄÙ blok

; ------ ukazatele bloku (blok je zobrazen pouze jsou-li ukazatele platn‚)
;        Nemˆnit po©ad¡ ukazatel– !

EdiPBBlk dd        ?                        ; pozice za‡ tku bloku (pro text. m¢d)
EdiRBBlk dd        ?                        ; © dek za‡ tku bloku (pro text. m¢d)
EdiOBBlk dd        ?                        ; offset za‡ tku bloku v souboru

EdiPKBlk dd        ?                        ; pozice konce bloku (pro text. m¢d)
EdiRKBlk dd        ?                        ; © dek konce bloku (pro text. m¢d)
EdiOKBlk dd        ?                        ; offset konce bloku v souboru

; ------ ukazatele zna‡ek

EdiTZnac dd        10*3 dup (?)             ; zna‡ky 0 a‘ 9 (pozice,© dek)
; EdiPZnac EQU       EditZnac                ; pozice zna‡ky
; EdiRZnac EQU       EditZnac+2              ; © dek zna‡ky
; EdiOZnac EQU       EditZnac+4              ; offset zna‡ky

; ------ parametry souboru

EdiAtrib db        ?                        ; p–vodn¡ atributy souboru
         db        ?                        ; ... zarovn n¡ na sudou adresu
EdiDate  dw        ?                        ; p–vodn¡ datum souboru
EdiTime  dw        ?                        ; p–vodn¡ ‡as souboru
EdiOSize dd        ?                        ; p–vodn¡ velikost souboru
EdiSize  dd        ?                        ; aktu ln¡ velikost souboru

; ------ ukazatele souboru

EdiNBlok dw        ?                        ; po‡et blok– v tabulce (max. 7FFFh)
EdiRadku dd        ?                        ; celkov˜ po‡et © dk– v souboru
EdiIdent dw        ?                        ; identif.p–vod.souboru (0=nen¡)
EdiSoubJ dw        ?                        ; offset za‡ tku jm‚na souboru
EdiSoubN dw        ?                        ; d‚lka specifikace souboru
EdiSoub  db        FileMax dup(?)           ; specifikace souboru

; ------ popisova‡e oken

EdiW1    EdiWStru  <>                       ; popisova‡ okna 1
EdiW2    EdiWStru  <>                       ; popisova‡ okna 2

EditStru ENDS

EdiSumm  EQU       SIZE EditStru            ; velikost popisova‡e editoru

; ------ za‡ tek tabulky popisova‡– blok–

EdiABlok EQU       EdiSumm                  ; za‡ tek popisova‡– blok– souboru
                                            ; n sleduj¡ popisova‡e blok–

; -----------------------------------------------------------------------------
;        popisova‡ jednoho bloku souboru (jeden blok = 32 KB, popisova‡ = 8 B)
; -----------------------------------------------------------------------------
; maxim ln¡ po‡et blok– ((65535 - 334)/8)-1 = 8149 (teoreticky 7FFFh !)
; Maxim ln¡ velikost jednoho souboru:
;         8149 * 32768 = 267.026.432 (255MB, asi 260MB)
; -----------------------------------------------------------------------------

; Blok v p©echodn‚m souboru mus¡ b˜t v‘dy pln˜ (=32KB) !

EdiBlokM EQU       0                        ; (2) identifik tor bloku v pamˆti
                                            ;           (0=nen¡ blok v pamˆti)
                                            ;     bit 0 a‘ bit 14: ‡¡slo bloku
                                            ;     bit 15: 1=blok byl modifikov n
EdiBlokD EQU       2                        ; (2) identifik tor bloku na disku
                                            ;           (-1=nen¡ p©idˆlen blok)
                                            ;     bit 0 a‘ bit 14: ‡¡slo bloku
                                            ;     bit 15: 1=p©echodn˜ soubor

EdiBlokN EQU       4                        ; (2) po‡et bajt– v bloku (m–‘e=0)
EdiBlokL EQU       6                        ; (2) po‡et p©elom– © dk– LF
                                            ;      -1=nezn m˜ po‡et © dk–

EdiBlokS EQU       8                        ; velikost jednoho popisova‡e bloku

; *****************************************************************************
;
;                      Definice voleb (menu)
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        obecn  ‡ st definice menu
; -----------------------------------------------------------------------------

MnuStruc STRUC
MnuTyp   db        0                        ; (1) typ menu
                                            ;      0 = hlavn¡ menu        M
                                            ;      1 = vertik ln¡ menu    V
                                            ;      2 = vertik ln¡ podmenu V
                                            ;      3 = © dkov‚ menu       L
                                            ;      4 = menu volby disku   D
                                            ;      5 = ASCII tabulka      A
                                            ;      6 = hodiny             T
                                            ;      7 = tabulka            TB
                                            ;      8 = kalend ©           R
                                            ;      9 = v˜bˆr soubor–      S
                                            ;     10 = editor datab ze    B
                                            ;     11 = obnoven¡ soubor–   U
                                            ;     12 = form tov n¡ disket O
                                            ;     13 = mapa disku         P
                                            ;     14 = zobrazen¡ disku    Z
                                            ;     15 = modifik. datab ze  BM
                                            ;     16 = editace textu      E
                                            ;     17 = funk‡n¡ kl vesy    G
                                            ;     18 = u‘ivatelsk‚ menu   C
                                            ;     19 = CD disk            CD
                                            ;     20 = n povˆda           H

MnuLev   db        0                        ; (1) hladina pro zobrazen¡ menu
MnuAkt   dw        1                        ; (2) aktivn¡ polo‘ka menu (1...)
MnuNum   dw        1                        ; (2) po‡et platn˜ch polo‘ek menu
MnuSum   dw        1                        ; (2) celkov˜ po‡et polo‘ek menu

MnuPol   dw        0                        ; (2) adresa definice polo‘ek menu
MnuHlp   dw        0                        ; (2) adresa n povˆd menu
MnuHelp  dw        0                        ; (2) ‡¡slo velk‚ n povˆdy menu
MnuBlk   dw        0                        ; (2) adresa blokovac¡ tabulky menu
MnuSwch  dw        0                        ; (2) adresa tabulky p©ep¡na‡–
MnuTitl  dw        0                        ; (2) adresa titulu okna (0=nen¡)
MnuExec  dw        0                        ; (2) tabulka adres obsluh menu
MnuMnu   dw        0                        ; (2) tabulka navazuj¡c¡ch menu
                                            ;     (0=nen¡ menu, je podprogram;
                                            ;      jinak se ulo‘¡ n vratov 
                                            ;      adresa do definice menu a
                                            ;      p©ed  se ©¡zen¡ bez n vratu)
MnuBreak dd        0                        ; (4) n vratov  adresa p©i p©eru¨en¡

MnuPoz   db        0                        ; (1) po‡ te‡n¡ pozice okna menu
MnuRad   db        0                        ; (1) po‡ te‡n¡ © dek okna menu
MnuSir   db        60                       ; (1) ¨¡©ka okna menu
MnuVys   db        20                       ; (1) v˜¨ka okna menu
MnuStruc ENDS

Mnu      EQU       SIZE MnuStruc            ; konec obecn‚ definice menu

; -----------------------------------------------------------------------------
;        0: definice hlavn¡ho menu
; -----------------------------------------------------------------------------

MMnuStru STRUC
         MnuStruc  <>                       ; spole‡n  ‡ st menu
MMnuLft  db        ?                        ; (1) lev˜ okraj menu
MMnuSpc  db        ?                        ; (1) mezera na okraji polo‘ky
MMnuOdd  db        ?                        ; (1) oddˆlovac¡ mezera mezi pol.
MMnuRght db        ?                        ; (1) prav˜ okraj menu
MMnuMax  db        ?                        ; (1) omezen¡ d‚lky polo‘ky
MMnuStru ENDS

; -----------------------------------------------------------------------------
;        3: definice © dkov‚ho menu
; -----------------------------------------------------------------------------
; Polo‘ky MnuVys (v˜¨ka okna) a LMnuDis (po‡et zobrazen˜ch © dk–) mus¡ b˜t
; v z jemn‚m souladu - p©i inicializaci menu se obˆ p©epo‡¡t vaj¡ podle po‡tu
; © dk– v historii (nemus¡ se mˆnit p©i zmˆnˆ po‡tu polo‘ek p©edvolby).
; Je-li polo‘ka LMnuDis nastaven na 0 (tj. nen¡ ‘ dn˜ editovan˜ © dek), slou‘¡
; menu jako menu s horizont ln¡mi volbami.
;
; Polo‘ka MnuAkt (aktivn¡ polo‘ka menu) p©i hodnotˆ 1 ozna‡uje aktivn¡
; editovan‚ © dky, p©i ostatn¡ch hodnot ch ozna‡uje horizont ln¡ volby na
; spodu okna. Prvn¡ polo‘ka v menu ozna‡en  jako platn  polo‘ka voleb
; (tedy ne jako text) p©edstavuje editovan‚ © dky okna. Text t‚to polo‘ky se
; ignoruje.
;
; Polo‘ka LMnuTop (prvn¡ zobrazen˜ © dek) se stanov¡ p©i inicializaci menu
; tak, aby byl jako aktivn¡ posledn¡ © dek menu.

LMnuStru STRUC
         MnuStruc  <>                       ; spole‡n  ‡ st menu
LMnuMax  dw        ?                        ; (2) maxim ln¡ d‚lka edit. © dku
LMnuTop  dw        ?                        ; (2) prvn¡ zobrazen˜ edit. © dek
LMnuAkt  dw        ?                        ; (2) aktivn¡ edit. © dek (0...)
LMnuNum  dw        ?                        ; (2) celkov˜ po‡et edit. © dk–
LMnuDis  dw        ?                        ; (2) po‡et zobrazen˜ch edit. © dk–
                                            ;     (0=nejsou editovan‚ © dky)

LMnuMask db        ?                        ; (1) maska zad van˜ch znak–
                                            ; - defini‡n¡ tabulka znak– TabTypCh
                                            ; bit 0:
                                            ; bit 1:
                                            ; bit 2: 1=v¨echny znaky
                                            ; bit 3: 1=jm‚no souboru
                                            ; bit 4: 1=‡¡slo
                                            ; bit 5:
                                            ; bit 6: 1=parametry hled n¡ soubor–
                                            ; bit 7: 1=parametry hled n¡ textu

LMnuZakN db        ?                        ; (1) po‡et zak zan˜ch znak– 0 a‘ 6
LMnuZak  db        '      '                 ; (6) zak zan‚ znaky textu
; Dodˆlat: bit 4 a‘ bit7 - po‡et dopl¤kov˜ch znak– (jsou za zak zan˜mi znaky)

LMnuHis  db        ?                        ; (1) identifik tor historie

LMnuPreN db        ?                        ; (1) po‡et p©edvoleb
LMnuStru ENDS

LMnuPreA EQU       SIZE LMnuStru            ; tabulka adres p©edvoleb (po 6 B)
                                            ;   - (2) d‚lka textu p©edvolby
                                            ;   - (4) adresa p©edvolby

; -----------------------------------------------------------------------------
;        4: definice menu volby disku
; -----------------------------------------------------------------------------

DMnuStru STRUC
         MnuStruc  <>                       ; spole‡n  ‡ st menu
DMnuPol  db        ?                        ; (1) po‡et polo‘ek na © dek
DMnuRad  db        ?                        ; (1) po‡et © dk– s polo‘kami
DMnuStru ENDS

; -----------------------------------------------------------------------------
;        18: u‘ivatelsk‚ menu
; -----------------------------------------------------------------------------
;þ
CMnuStru STRUC
         MnuStruc  <>                       ; spole‡n  ‡ st menu
MnuCSegm dw        ?                        ; (2) segment s definic¡ menu
CMnuStru ENDS
MnuCSumm EQU       SIZE CMnuStru

; ------ definice segmentu menu

UMenByts EQU       0                        ; (2) velikost segmentu definice

UMenPrm1 EQU       2                        ; (1) parametry 1
                                                 ;      bit 0: 1=je form t DOSMAN 2.0
                                            ;      bit 1: 1=ur‡ena intenzita
                                            ;      bit 2: 1=je intenzivn¡ pozad¡

;UMenLevM EQU       3                        ; (1) hloubka menu (0...)

UMenAdrF EQU       4                        ; (2) adresa na‡ten‚ho souboru

; ------ definice titulku a z hlav¡ (0=nen¡ nic, 1=jen titulek, >1=i z hlav¡)

UMenNadI EQU       6                        ; (2) adresa index– z hlav¡
UMenNadN EQU       8                        ; (2) po‡et © dk– z hlav¡ a titulku

; ------ definice zobrazen˜ch © dk–

UMenLinI EQU       10                       ; (2) adresa index– zobraz. © dk–
UMenLinN EQU       12                       ; (2) po‡et zobrazen˜ch © dk– celkem
UMenLinT EQU       14                       ; (2) po‡ te‡n¡ zobrazen˜ © dek
UMenLinK EQU       16                       ; (2) zobrazen˜ © dek s kurzorem
UMenParI EQU       18                       ; (2) adresa parametr– © dk–

; ------ definice © dk– voleb

UMenVolN EQU       20                       ; (2) po‡et © dk– voleb celkem
UMenVolK EQU       22                       ; (2) © dek volby s kurzorem

; ------ definice n povˆd (po‡et jako volby; index 0=nen¡ n povˆda k volbˆ)

UMenHlpI EQU       24                       ; (2) adresa index– © dk– n povˆd

; ------ definice barev

UMenCol1 EQU       26                       ; (1) bˆ‘n  barva menu
UMenCol2 EQU       27                       ; (1) zv˜raznˆn  barva menu
UMenCol3 EQU       28                       ; (1) bˆ‘n  barva kurzoru menu
UMenCol4 EQU       29                       ; (1) zv˜raznˆn  barva kurzoru menu
UMenClR1 EQU       30                       ; (1) barva r mu menu - tmav 
UMenClR2 EQU       31                       ; (1) barva r mu menu - svˆtl 
UMenColT EQU       32                       ; (1) barva titulku menu
UMenColH EQU       33                       ; (1) barva z hlav¡ menu
UMenClH2 EQU       34                       ; (1) zv˜raznˆn  barva z hlav¡
UMenColP EQU       35                       ; (1) barva n povˆdy menu
UMenClP2 EQU       36                       ; (1) zv˜raznˆn  barva n povˆdy
                                            ; (1) zarovn n¡

; ------ zadan‚ rozmˆry menu

UMenMSir EQU       38                       ; (1) ¨¡©ka menu (0 = nezad na)
UMenMVys EQU       39                       ; (1) v˜¨ka menu (0 = nezad na)
UMenMPoz EQU       40                       ; (1) pozice menu (-1 = nezad na)
UMenMRad EQU       41                       ; (1) © dek menu (-1 = nezad n)

; ------ specifikace souboru menu

UMenFile EQU       42                       ; (FileMax) jm‚no souboru

; ------ buffer pro ©etˆzec CASE

UMenCase EQU       UMenFile+FileMax         ; (256) buffer ©etˆzce CASE

; ------ buffer pro cykly FOR

UMenFors EQU       UMenCase+256             ; (3*MaxUFors) buffer cykl– FOR
                                            ;     0: (2) adresa © dku FOR cyklu
                                            ;     2: (1) ‡¡slo ©etˆzce 1...
                                            ;       (0=soubory, 1=nekone‡n˜)
UMenFor0 EQU       UMenFors+3*MaxUFors      ; adresa konce tabulky FOR

; ------ buffery

UMenSumm EQU       UMenFor0                 ; konec standardn¡ definice

                                            ; - indexy © dk– nadpisu (2 B)
                                            ; - indexy zobrazen˜ch © dk– (2 B)
                                            ; - indexy parametr– © dk– (1 B)
                                            ;    bit 0 a‘ bit 3: d‚lka textu
                                            ;                    hork‚ kl vesy
                                            ;    bit 6: 1=je navazuj¡c¡ menu
                                            ;    bit 7: 1=© dek volby (kurzor)
                                            ; - indexy © dk– n povˆd (2 B)
                                            ; - na‡ten˜ soubor

; -----------------------------------------------------------------------------
;        definice blokovac¡ tabulky
; -----------------------------------------------------------------------------

; pro 1 platnou polo‘ku 1 bajt: 0=polo‘ka povolen , jinak=polo‘ka blokovan 
;   bit 0: u‘ivatelsk‚ blokov n¡
;   bit 1: programov‚ blokov n¡

; -----------------------------------------------------------------------------
;        definice tabulky p©ep¡na‡–
; -----------------------------------------------------------------------------

; pro 1 polo‘ku p©ep¡na‡e 1 bajt: 0=p©ep¡na‡ vypnut˜, jinak=p©ep¡na‡ nastaven

; -----------------------------------------------------------------------------
;        definice polo‘ky n povˆdy
; -----------------------------------------------------------------------------

; 1. bajt = d‚lka textu n povˆdy
; nasleduje text n povˆdy

; -----------------------------------------------------------------------------
;        definice polo‘ky volby
; -----------------------------------------------------------------------------

MnuParm  EQU       0                        ; (1) parametry
                                            ;      bit0 a‘ bit5: pozice hork‚ho
                                            ;                    znaku (0=nen¡)
                                            ;      bit 6: 0=je polo‘ka voleb
                                            ;             1=je bˆ‘n˜ text,‡ ra
                                            ;      bit 7: 0=bˆ‘n  polo‘ka/text
                                            ;             1=je p©ep¡na‡/‡ ra
MnuDelk  EQU       1                        ; (1) d‚lka textu polo‘ky
MnuTxt   EQU       2                        ; za‡ tek textu polo‘ky
                                            ;   (0 = p©ep¡na‡ barvy textu)

; -----------------------------------------------------------------------------
;
;                          Segment histori¡
;
; -----------------------------------------------------------------------------

HistByts EQU       0                        ; (2) velikost segmentu histori¡

; ------ definice jednoho seznamu histori¡

HistSOfs EQU       0                        ; (2) offset dal¨¡ho seznamu
HistSNum EQU       2                        ; (2) po‡et polo‘ek histori¡
HistSBeg EQU       4                        ; za‡ tek seznamu histori¡

; ------ definice jedn‚ polo‘ky historie

HistDelk EQU       0                        ; (2) d‚lka jedn‚ polo‘ky historie
                                            ;   bit 15: 1=z kaz ru¨en¡ polo‘ky
HistTxt  EQU       2                        ; text historie

HistDelM EQU       7fffh                    ; maska d‚lky jedn‚ polo‘ky historie

; ------ ‡¡sla seznam– histori¡

HistFile EQU       1                        ; historie soubor–
HistComm EQU       2                        ; historie p©¡kaz–
HistFind EQU       3                        ; historie hled n¡ p©i editaci
HistSwch EQU       4                        ; p©ep¡na‡e hled n¡
HistSel  EQU       5                        ; v˜bˆr (a hled n¡) soubor–
HistAdr  EQU       6                        ; historie adres ©– (oken)
HistAtri EQU       7                        ; historie volby atribut–
HistKom  EQU       8                        ; historie koment ©–
HistCis  EQU       9                        ; historie ‡¡sel
HistMenu EQU       10                       ; historie parametr– u‘iv. menu

HistNum  EQU       10                       ; po‡et seznam– histori¡

; -----------------------------------------------------------------------------
;        9: definice menu v˜bˆru soubor–
; -----------------------------------------------------------------------------

SMnuSeg  EQU       Mnu + 0                  ; (2) datov˜ segment se soubory
SMnuPth0 EQU       Mnu + 2                  ; (2) inicializa‡n¡ d‚lka cesty
SMnuPthN EQU       Mnu + 4                  ; (2) d‚lka textu cesty
SMnuPath EQU       Mnu + 6                  ; (2) adresa bufferu cesty
SMnuExtI EQU       Mnu + 8                  ; (1) d‚lka p©¡pony soubor–
SMnuExt  EQU       Mnu + 9                  ; (3) p©¡pona soubor–
SMnuText EQU       Mnu + 12                 ; (2) adresa hl ¨en¡ "text" "seznam"
SMnuFrst EQU       Mnu + 14                 ; (2) uschovan  prvn¡ polo‘ka
SMnuKurz EQU       Mnu + 16                 ; (2) uschovan˜ kurzor

; -----------------------------------------------------------------------------
;        10: definice editoru datab ze
; -----------------------------------------------------------------------------

DBMnuSeg EQU       Mnu + 0                  ; (2) segment definice datab ze

; *****************************************************************************
;
;                        Definice datab ze
;
; *****************************************************************************
;þ
DBFByts  EQU       0                        ; (2) velikost datab zov‚ho bloku

DBFParm  EQU       2                        ; (1) parametry souboru
                                            ;     bit 0: 1=je str nkov‚ zobr.
                                            ;     bit 1: 1=je z kaz z pisu
                                            ;     bit 2: 1=re‘im modifikace pol.
                                            ;     bit 3: 1=DBASE/0=FOXPRO MEMO
                                            ;     bit 4: 1=je MEMO soubor
                                            ;     bit 5: 1=z kaz z pisu do MEMO
                                            ;     bit 6: 1=byl z pis do MEMO
                                            ;     bit 7: 1=zmˆnˆno ‡¡slo MEMO

DBFParm2 EQU       3                        ; (1) parametry 2
                                            ;     bit 0: 1=jsou intern¡ p©ep¡na‡e

; ------ ukazatele polo‘ek v souboru

DBFAktZ  EQU       4                        ; (4) aktivn¡ z znam s kurzorem
DBFMaxZ  EQU       8                        ; (4) po‡et z znam– v souboru

; ------ zobrazen¡ v © dkov‚m re‘imu

DBFTopZ  EQU       12                       ; (4) prvn¡ zobrazen˜ z znam
DBFTopP  EQU       16                       ; (2) offset po‡ tku © dku (pozic)
DBFSirR  EQU       18                       ; (2) celkov  ¨¡©ka © dku (pozic)

; ------ zobrazen¡ ve str nkov‚m re‘imu

DBFTopL  EQU       20                       ; (2) prvn¡ zobrazen  linka
DBFNumL  EQU       22                       ; (2) po‡et © dk– ve str nk. re‘imu

; ------ definice editavn‚ polo‘ky

DBFOffT  EQU       24                       ; (2) offset zobraz. po‡ tku polo‘ky
DBFKurz  EQU       26                       ; (2) offset kurzoru v polo‘ce
DBFAktP  EQU       28                       ; (2) ‡¡slo aktivn¡ polo‘ky

; ------ popisova‡e polo‘ek v z znamu

DBFAdrP  EQU       30                       ; (2) adresa indexu popisova‡–
DBFNumP  EQU       32                       ; (2) po‡et platn˜ch popisova‡–

; ------ definice edita‡n¡ho bufferu z znamu

DBFAdrE  EQU       34                       ; (2) adresa edita‡n¡ho bufferu
                                            ;     - sou‡asnˆ konec index– !

; ------ definice datov‚ho bufferu

DBFAdrD  EQU       36                       ; (2) adresa datov‚ho bufferu
DBFBegD  EQU       38                       ; (4) prvn¡ z znam v bufferu
DBFNumD  EQU       42                       ; (2) po‡et z znam– v bufferu
DBFMaxD  EQU       44                       ; (2) max. z znam– v bufferu
DBFSizD  EQU       46                       ; (2) velikost bufferu v bajtech

; ------ definice souboru DBF

DBFIdent EQU       48                       ; (2) identifik tor souboru DBF
DBFSoubN EQU       50                       ; (2) d‚lka jm‚na souboru
DBFName  EQU       52                       ; (8) jm‚no souboru (s mezerami)
DBFNKom  EQU       60                       ; (2) d‚lka koment ©e k souboru

; ------ definice souboru MEMO (DBT nebo FPT)

DBFIdntT EQU       62                       ; (2) identifik tor souboru MEMO
DBFSouTN EQU       64                       ; (2) d‚lka jm‚na souboru MEMO
DBFHeadT EQU       66                       ; (2) po‡et bajt– na z hlav¡ MEMO
DBFBlokT EQU       68                       ; (2) velikost bloku MEMO pole
DBFPolBT EQU       70                       ; (4) po‡ te‡n¡ polo‘ka aktiv. MEMO
                                            ;       0 = nen¡ p©idˆlena polo‘ka
DBFPolST EQU       74                       ; (2) velikost m¡sta pro polo‘ku
                                            ;       0 = je konec souboru
;DBFPolNT EQU       76                       ; (2) velikost dat polo‘ky MEMO
DBFLastT EQU       78                       ; (4) ‡¡slo p©¡¨t¡ho z znamu MEMO
DBFLast0 EQU       82                       ; (4) skute‡n˜ p©¡¨t¡ z znam MEMO

; ------ parametry pro rychl˜ prohl¡‘e‡ MEMO

DBFVysL  EQU       86                       ; (2) v˜¨ka okna datov˜ch © dk–
DBFVysQ  EQU       88                       ; (2) v˜¨ka okna rychl‚ho prohl¡‘en¡

; ------ definice hesla (d‚lka mus¡ b˜t p©ed bufferem - zobrazen¡ hl ¨en¡ !)

;DBFCodPg EQU       90                       ; (1) vstupn¡ n rodn¡ k¢d
;                                            ;      bit2=Kamen., bit3=Latin2
DBFHeslN EQU       91                       ; (1) d‚lka hesla
DBFHeslo EQU       92                       ; (TBLMaxHs) heslo

; ------ buffery (d‚lka bufferu v procedu©e DBFTClos !)

DBFKom   EQU       DBFHeslo+TBLMaxHs        ; (50) koment © k souboru
DBFSoub  EQU       DBFKom+50                ; (86) jm‚no souboru DBF
DBFSouT  EQU       DBFSoub+FileMax          ; (88) jm‚no souboru DBT, FPT

DBFBuffT EQU       DBFSouT+FileMax+2        ; (512) buffer pro MEMO soubor

; ------ z hlav¡ datab zov‚ho souboru

DBFHlava EQU       DBFBuffT+512             ; za‡ tek z hlav¡ datab z. souboru

DBFVer   EQU       DBFHlava+0               ; (1) verze datab ze (3, 83h, 0F5h)
                                            ;       03h = DBASE III
                                            ;       83h = DBASE III s memo DBT
                                            ;       F5h = FOXPRO s memo FPT
DBFRok   EQU       DBFHlava+1               ; (1) rok posledn¡ aktualizace
                                            ;       (bez stolet¡)
DBFMes   EQU       DBFHlava+2               ; (1) mˆs¡c posledn¡ aktualizace
DBFDen   EQU       DBFHlava+3               ; (1) den posledn¡ aktualizace
DBFNumZ  EQU       DBFHlava+4               ; (4) po‡et z znam– v souboru
DBFBytH  EQU       DBFHlava+8               ; (2) d‚lka z hlav¡ (bajt–)
DBFBytZ  EQU       DBFHlava+10              ; (2) po‡et bajt– na z znam
DBFRez1  EQU       DBFHlava+12              ; (20) rezervov no (pro verzi 1.00)


DBFSwIdn EQU       DBFRez1                  ; (2) identifik tor intern¡ch
                                            ;     p©ep¡na‡– (text "DM")
DBFSwKod EQU       DBFRez1+2                ; (2) identifik tor n rodn¡ho k¢du
                                            ;   ("KA"=Kamenick˜ch, "L2"=Latin 2)
DBFSwPsw EQU       DBFRez1+4                ; (2) identifik tor hesla
                                            ;     ("PW"=je heslo, 00=nen¡ heslo)


DBFPopis EQU       DBFHlava+32              ; popisova‡e polo‘ek (ka‘d˜ 32B)
                                            ; 0 (11):jm‚no polo‘ky (text ASCIIZ,
                                            ;        0Dh = neplatn  polo‘ka)
                                            ; 11 (1): typ polo‘ky
                                            ;         C=text (d‚lka max. 254)
                                            ;         N=‡¡slo (d‚lka max. 20)
                                            ;         F=‡¡slo (d‚lka max. 20)
                                            ;         D=datum RRRRMMDD (d‚lka 8)
                                            ;         L=logick  (d‚lka 1)
                                            ;          (hodnoty YyNnTtFf?mezera)
                                            ;         M=memo (d‚lka 10)
                                            ;         T=‡as HHMMSS (d‚lka 6)
                                            ;        (P=obr zek)
                                            ;        (G=general, v¨eobecn  data)
                                            ; 12 (4): .... rezervov no
                                            ; 16 (1): d‚lka polo‘ky (v bajtech)
                                            ; 17 (1): po‡et desetinn˜ch m¡st
                                            ; 18 (1): ¨¡©ka zobrazen¡ pole (pozic)
                                            ; 19 (1): ¨¡©ka pole ADD "D" (ovˆ©en¡)
                                            ; 20 (12): ... rezervov no

DBFPSirk EQU       18                       ; polo‘ka ¨¡©ky pole v popisova‡i
DBFPSirC EQU       "D"                      ; kontroln¡ znak ¨¡©ky pole

                                            ; (1) p©¡znak konce z hlav¡ 0Dh

                                            ; - tabulka index– popisova‡–
                                            ; - edita‡n¡ buffer z znamu
                                            ; - datov˜ buffer souboru

; -----------------------------------------------------------------------------
;        polo‘ka indexu popisova‡e
; -----------------------------------------------------------------------------

DBFNamX  EQU       0                        ; (2) adresa jm‚na popisova‡e
DBFNumX  EQU       2                        ; (1) d‚lka jm‚na popisov. (max.10)
DBFSirX  EQU       3                        ; (2) ¨¡©ka pole polo‘ky (pozic)
DBFDelX  EQU       5                        ; (2) d‚lka polo‘ky (bajt–)
DBFParX  EQU       7                        ; (1) parametry polo‘ky
                                            ;       bit 0: 1=textov  polo‘ka C
                                            ;       bit 1: 1=‡¡seln  polo‘ka N
                                            ;       bit 2: 1=‡¡seln  polo‘ka F
                                            ;       bit 3: 1=datum D
                                            ;       bit 4: 1=logick  polo‘ka L
                                            ;       bit 5: 1=MEMO M
                                            ;       bit 6: 1=‡as T
                                            ;       bit 7: 1=jin˜ typ polo‘ky ?

DBFX     EQU       8                        ; d‚lka indexu popisova‡e polo‘ky

; -----------------------------------------------------------------------------
;        modifikace datab ze
; -----------------------------------------------------------------------------

DBMMnSeg EQU       Mnu + 0                  ; (2) segment modifikace datab ze


DBFBytM  EQU       0                        ; (2) po‡et bajt– v bufferu modifik.
DBFNumM  EQU       2                        ; (2) po‡et polo‘ek v bufferu modif.
DBFPrmM  EQU       4                        ; (2) parametry
                                            ;      bit 0:
                                            ;      bit 1: 1=zah jena editace
                                            ;      bit 2: 1=aktivn¡ jm‚no
                                            ;      bit 3: 1=aktivn¡ typ
                                            ;      bit 4: 1=aktivn¡ d‚lka
                                            ;      bit 5: 1=aktivn¡ desetiny
                                            ;      bit 6: 1=aktivn¡ po‡ tek

DBFTopM  EQU       6                        ; (2) prvn¡ zobrazen  polo‘ka
DBFAktM  EQU       8                        ; (2) aktivn¡ zobrazen  polo‘ka
DBFKurM  EQU       10                       ; (2) pozice kurzoru v polo‘ce

; ------ buffer pro konverzi souboru

DBFMaxM  EQU       12                       ; (2) max. z znam– v bufferu
DBFBeg1M EQU       14                       ; (2) za‡ tek vstupn¡ho bufferu
                                            ;      (p©i modifikaci konec index–)
DBFEnd1M EQU       16                       ; (2) konec dat ve vstupn¡m bufferu
DBFBeg2M EQU       18                       ; (2) za‡ tek v˜stupn¡ho bufferu
DBFReadM EQU       20                       ; (2) ‡tec¡ adresa ze vstup. bufferu
DBFWritM EQU       22                       ; (2) z pisov  adresa do v˜s.bufferu
DBFIdn1M EQU       24                       ; (2) identifik tor vstup. souboru
DBFIdn2M EQU       26                       ; (2) identifik tor v˜stup. souboru
DBFZaz1M EQU       28                       ; (2) velikost z znamu vstup. soub.
DBFZaz2M EQU       30                       ; (2) velikost z znamu v˜stup. soub.
DBFCitZM EQU       32                       ; (4) ‡¡ta‡ z znam– ke konverzi

DBFPopM  EQU       36                       ; za‡ tek popisova‡– polo‘ek

; ------ polo‘ka popisova‡e (struktura natvrdo v EdiDBMCh !)
; spojovat lze jen textov‚ polo‘ky, v˜stupem je opˆt textov  polo‘ka !

DBFNumM1 EQU       0                        ; (2) ‡¡slo star‚ modifik. polo‘ky 1
                                            ;     (-1=nen¡)
DBFOfsM1 EQU       0                        ; (2) p©i konverzi offset polo‘ky 1
                                            ;     (-1=nen¡)

DBFNumM2 EQU       2                        ; (2) ‡¡slo p©ipojen‚ polo‘ky 2
                                            ;     (-1=nen¡)
DBFOfsM2 EQU       2                        ; (2) p©i konverzi offset polo‘ky 2
                                            ;     (-1=nen¡)

DBFNamM  EQU       4                        ; (10) jm‚no polo‘ky (s mezerami)
DBFDelM1 EQU       4                        ; (2) d‚lka polo‘ky 1 p©i konverzi
DBFDelM2 EQU       6                        ; (2) d‚lka polo‘ky 2 p©i konverzi

DBFTypM  EQU       14                       ; (1) typ polo‘ky
                                            ;       bit 0: 1=textov  polo‘ka C
                                            ;       bit 1: 1=‡¡seln  polo‘ka N
                                            ;       bit 2: 1=‡¡seln  polo‘ka F
                                            ;       bit 3: 1=datum D
                                            ;       bit 4: 1=logick  polo‘ka L
                                            ;       bit 5: 1=MEMO M
                                            ;       bit 6: 1=‡as T
                                            ;       bit 7: 1=jin˜ typ polo‘ky ?

; Tyto 3 polo‘ky mus¡ za sebou n sledovat (natvrdo v EdiDBBS,EdiDBMCh,ModiPop):
DBFDelM  EQU       15                       ; (1) d‚lka nov‚ polo‘ky (bajt–)
DBFDesM  EQU       16                       ; (1) po‡et desetinn˜ch m¡st
DBFPozM  EQU       17                       ; (1) po‡ te‡n¡ pozice v polo‘ce 1
                                            ;     (jen pro textovou polo‘ku !)

DBFSirXM EQU       18                       ; (1) zobrazen  ¨¡©ka polo‘ky

DBFTypMO EQU       19                       ; (1) p–vodn¡ typ polo‘ky (0=‘ dn˜)
                                            ;       bit 0: 1=textov  polo‘ka C
                                            ;       bit 1: 1=‡¡seln  polo‘ka N
                                            ;       bit 2: 1=‡¡seln  polo‘ka F
                                            ;       bit 3: 1=datum D
                                            ;       bit 4: 1=logick  polo‘ka L
                                            ;       bit 5: 1=MEMO M
                                            ;       bit 6: 1=‡as T
                                            ;       bit 7: 1=jin˜ typ polo‘ky ?

DBFTypMC EQU       20                       ; (1) znak pro jin˜ typ polo‘ky

DBFM     EQU       21                       ; d‚lka polo‘ky

                                            ; - n sleduje vstupn¡ buffer
                                            ; - n sleduje v˜stupn¡ buffer
                                            ;   (konec je pou‘it z [0] !)

; *****************************************************************************
;
;                   Definice tabulkov‚ho kalkul toru
;
; *****************************************************************************
;þ
; Je stejn‚ jako EdMnuSeg - viz "DispRME"
TbMnuSeg EQU       Mnu + 0                  ; segment bufferu tabulky

; ------ konstanty
; Po‡et © dk– by nemˆl b˜t pln˜ch 1023 - rezerva se pou‘¡v  nap©. p©i
; listov n¡ pomoc¡ my¨i (aby se vˆdˆlo, na kterou stranu nastalo p©ete‡en¡).

TBLMaxC  EQU       63                       ; maxim ln¡ ‡¡slo sloupce
TBLMaskC EQU       bit0+bit1+bit2+bit3+bit4+bit5 ; maska ‡¡sla sloupce
TBLMaxR  EQU       998                      ; maxim ln¡ ‡¡slo © dku
TBLRotR  EQU       6                        ; po‡et rotac¡ ‡¡sla © dku
TBLNasR  EQU       64                       ; n sobek ‡¡sla © dku
TBLMaskR EQU       bit6+bit7+bit8+bit9+bit10+bit11+bit12+bit13+bit14+bit15
                                            ; maska ‡¡sla © dku
TBLMaxS  EQU       99                       ; maxim ln¡ ¨¡©ka sloupce bu¤ky

TBLMaxHs EQU       40                       ; maxim ln¡ d‚lka hesla

;; ------ definice ‡¡sla (v¨e sud‚ !!!)
;
;TBLNumN  EQU       8                        ; po‡et bajt– na celou ‡ st ‡¡sla
;TBLNumD  EQU       8                        ; po‡et bajt– na desetinnou ‡ st
;TBLNumX  EQU       TBLNumN+TBLNumD          ; po‡et bajt– na ‡¡slo celkem
;
;; P©epo‡et: 2.35 ‡¡slice na bajt
;
; ------ z hlav¡ segmentu tabulky

TBLByts  EQU       0                        ; (2) velikost segmentu

TBLParm  EQU       2                        ; (1) parametry
                                            ;     bit 0: 1=tabulka modifikov na
                                            ;     bit 1: 1=je z kaz z pisu
                                            ;     bit 2: 1=re‘im modifikace pol.
                                            ;     bit 3: 1=pot©ebn˜ p©epo‡et
                                            ;     bit 4: 1=kurzor je platn  bu¤ka
                                            ;     bit 5: 1=kurzor je R/O
                                            ;     bit 6: 1=je editace © dku
                                            ;     bit 7: 1=editace je opravn 

TBLParm2 EQU       3                        ; (1) parametry 2

; ------ definice ukazatel–

TBLKurzA EQU       4                        ; (2) adresa bu¤ky s kurzorem
TBLTopA  EQU       6                        ; (2) adresa prvn¡ zobrazen‚ bu¤ky

; ------ definice souboru TBL

TBLSoubN EQU       8                        ; (2) d‚lka jm‚na souboru
TBLName  EQU       10                       ; (8) jm‚no souboru (s mezerami)
TBLNKom  EQU       18                       ; (2) d‚lka koment ©e k souboru

; ------ definice hesla (d‚lka mus¡ b˜t p©ed bufferem - zobrazen¡ hl ¨en¡ !)

TBLHeslN EQU       20                       ; (1) d‚lka hesla
TBLHeslo EQU       21                       ; (TBLMaxHs) heslo

; ------ buffery (d‚lka bufferu v procedu©e TBLTClos !)

TBLKom   EQU       TBLHeslo+TBLMaxHs        ; (50) koment © k souboru
TBLSoub  EQU       TBLKom+50                ; (86) jm‚no souboru TBL

; ------ edita‡n¡ buffer © dku

TBLEditK EQU       TBLSoub+86               ; (2) kurzor v edita‡n¡m bufferu
TBLEditN EQU       TBLEditK+2               ; (2) po‡et bajt– v edit. bufferu
TBLEditT EQU       TBLEditN+2               ; (2) zobrazen˜ po‡ tek edit.bufferu
TBLEditO EQU       TblEditT+2               ; (2) star  editovan  bu¤ka (ENTER)
TBLEditB EQU       TBLEditO+2               ; (TBLMaxS) edita‡n¡ buffer

; ------ za‡ tek souboru TBL (struktura napevno v OpenTBL, TBLQDek a TBExtern !)

TblTabul EQU       TBLEditB+TBLMaxS         ; za‡ tek tabulky (=souboru)

TblIdnt  EQU       TblTabul                 ; (4) identifikace - text "TBL1"
                                            ;   (‡¡slo "1" je ‡¡slo verze)

TblIParm EQU       TblTabul+4               ; (1) parametry tabulky
                                            ;      bit 0 a‘ bit 1: n rodn¡ k¢d
                                            ;               0=Kamenick˜ch
                                            ;               1=Latin 2
                                            ;      bit 2: 1=je odsazen¡ tis¡c–
                                            ;      bit 3: 1=soubor uzam‡en heslem
                                            ;      bit 4: 1=automatick˜ p©epo‡et
                                            ;      bit 5: 1=m¢d zobrazen¡ v˜raz–
                                            ;      bit 6: 1=v˜po‡ty £hl– v RAD
                                            ;      bit 7: 1=m¢d formul ©e

; ====== zde je za‡ tek k zak¢dov n¡ dat heslem

TblIPrm2 EQU       TblTabul+5               ; (1) parametry tabulky 2
                                            ;       ... rezervov no -> inic. 0

TBLICDes EQU       TblTabul+6               ; (1) pou‘it˜ oddˆlova‡ desetin
TBLICRad EQU       TblTabul+7               ; (1) pou‘it˜ oddˆlova‡ © d–
TBLICDat EQU       TblTabul+8               ; (1) pou‘it˜ oddˆlova‡ dat

TBLINumN EQU       TblTabul+9               ; (1) slov na celou ‡ st ‡¡sla
TBLINumD EQU       TblTabul+10              ; (1) slov na desetinnou ‡ st ‡¡sla

TblBunN  EQU       TblTabul+11              ; (2) po‡et bunˆk tabulky
TBLKurz  EQU       TblTabul+13              ; (2) bu¤ka s kurzorem
TBLTop   EQU       TblTabul+15              ; (2) prvn¡ zobrazen  bu¤ka

TblSirTb EQU       TblTabul+17              ; (TBLMaxC+1) tabulka ¨¡©ek sloupc–
TblDesTb EQU       TblSirTb+TBLMaxC+1       ; (TBLMaxC+1) tabulka deset. m¡st

TblDat   EQU       TblDesTb+TBLMaxC+1       ; za‡ tek dat tabulky

; ------ definice jedn‚ bu¤ky (struktura natvrdo v TBLBIns !)

TblXOffs EQU       0                        ; (2) offset dal¨¡ bu¤ky
                                            ;     (=d‚lka v‡etnˆ slova offsetu)
TblXBunk EQU       2                        ; (2) ‡¡slo bu¤ky
                                            ;       bit 0 a‘ bit 5: sloupec
                                            ;             0 a‘ 63 == "A" a‘ "BL"
                                            ;       bit 6 a‘ bit 15: © dek - 1
                                            ;             (0 a‘ 998 -> 1 a‘ 999)
TblXParm EQU       4                        ; (1) parametry, typ bu¤ky
                                            ;       bit 0: 1=text
                                            ;       bit 1: 1=konstanta
                                            ;       bit 2: 1=v˜raz
                                            ;       bit 3: 1=extern¡ bu¤ka
                                            ;       bit 4: 1=ASCII zobrazen¡ ‡¡sla
                                            ;       bit 5:   (1=v˜po‡et proveden)
                                            ;              1=ozna‡en  bu¤ka v bloku
                                            ;       bit 6:   (1=po‘adov n p©epo‡et)
                                            ;       bit 7: 1=bu¤ka uzam‡ena
                                            ;                 proti modifikaci

TblXReal EQU       5                        ; (TBLNumX) hodnota bu¤ky (po v˜po‡tu)

; *****************************************************************************
;
;        16: editace textu v bufferu 64 KB
;
; *****************************************************************************
;þ
; Je stejn‚ jako TbMnuSeg - viz "DispRME"
EdMnuSeg EQU       Mnu + 0                  ; segment bufferu editoru

; ------ parametry textu

TextByts EQU       0                        ; (2) velikost textov‚ho segmentu

TextParm EQU       2                        ; (1) parametry 1
                                            ;      bit 0: 1=z kaz z pisu
                                            ;      bit 1: 1=text modifikov n
                                            ;      bit 2: 1=blok je zapnut
                                            ;      bit 3: 1=jsou intern¡ promˆnn‚
                                            ;      bit 4: 1=implicitnˆ nepou‘¡t
                                            ;               intern¡ promˆnn‚
                                            ;      bit 5: 1=z kaz hesla (je DBT)
                                            ;      bit 6: 1=ne‘ dat heslo
                                            ;             (rychl˜ prohl¡‘e‡)

TextPrm2 EQU       3                        ; (1) parametry 2

; ------ definice textu v bufferu

TextBNum EQU       4                        ; (2) po‡et bajt– v bufferu
TextBLin EQU       6                        ; (2) po‡et © dk– textu v bufferu

; ------ zobrazen˜ po‡ tek

TextTLin EQU       8                        ; (2) prvn¡ zobrazen¡ © dek
TextTPoz EQU       10                       ; (2) po‡ te‡n¡ zobrazen  pozice
TextTAdr EQU       12                       ; (2) offset po‡ te‡n¡ho © dku

; ------ definice kurzoru (nemˆnit po©ad¡ pozice/© dek !)

TextKPoz EQU       14                       ; (2) pozice kurzoru na © dku
TextKLin EQU       16                       ; (2) aktivn¡ © dek s kurzorem

TextKAdr EQU       18                       ; (2) offset © dku s kurzorem
TextKDel EQU       20                       ; (2) d‚lka © dku s kurzorem (bajt–)
TextKEnd EQU       22                       ; (2) offset konce textu na © dku

; ------ definice bloku (nemˆnit po©ad¡ polo‘ek pozice/© dek !)

TextBBPz EQU       24                       ; (2) pozice za‡ tku bloku
TextBBLn EQU       26                       ; (2) © dek se za‡ tkem bloku

TextBEPz EQU       28                       ; (2) pozice konce bloku
TextBELn EQU       30                       ; (2) © dek s koncem bloku

; ------ jm‚no souboru

TextNamN EQU       32                       ; (2) d‚lka jm‚na souboru (impl. 8)
TextName EQU       34                       ; (12) jm‚no souboru (impl. 8)
TextNKom EQU       46                       ; (2) d‚lka koment ©e k souboru
TextKom  EQU       48                       ; (50) koment © k souboru

; ------ definice hesla (d‚lka mus¡ b˜t p©ed bufferem - zobrazen¡ hl ¨en¡ !)

TextHesN EQU       98                       ; (1) d‚lka hesla
TextHesl EQU       99                       ; (TBLMaxHs) heslo

; ------ za‡ tek textu

TextDBFH EQU       99+TBLMaxHs              ; (8) rezerva pro z hlav¡ DBF MEMO

TextBBeg EQU       TextDBFH+8               ; za‡ tek bufferu textu

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                         Blok inicializa‡n¡ho souboru
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;þ
InitByts EQU       0                        ; (2) po‡et bajt– v bufferu
InitParm EQU       2                        ; (2) parametry
                                            ;      bit 0: 1=soubor modifikov n
                                            ;      bit 1: 1=z kaz z pisu

InitPath EQU       4                        ; (FileMax) jm‚no souboru DOSMAN.INI
InitData EQU       4+FileMax                ; za‡ tek dat

; *****************************************************************************
;
;                               Segment di ©e
;
; *****************************************************************************
;þ
DiarByts EQU       0                        ; (2) po‡et bajt– v segmentu
DiarNums EQU       2                        ; (2) po‡et polo‘ek v segmentu
DiarIndx EQU       4                        ; indexy polo‘ek

; ------ jedna polo‘ka indexu

DiarPRok EQU       0                        ; (2) bit 0 a‘ bit 11: rok
                                            ;      (1 a‘ 4095; 0=ka‘d˜ rok)
                                            ;     bit 12 a‘ bit 15: mˆs¡c
                                            ;      (1 a‘ 12; 0=ka‘d˜ mˆs¡c)
DiarPPar EQU       2                        ; (1) bit 0 a‘ bit 4: den
                                            ;      (1 a‘ 31; 0=ka‘d˜ den)
                                            ;     bit 5: 1=pracovn¡ den
                                            ;     bit 6: 1=sv tek
                                            ;     bit 7: 1=zv˜raznˆn˜ den
DiarPDny EQU       3                        ; (1) dny v t˜dnu (bit 0: pondˆl¡,
                                            ;     bit 1: £ter˜ .. bit 6: nedˆle)
                                            ;     bit 7: 1=zv˜raznˆn˜ text
DiarPOfs EQU       4                        ; (2) offset textu v bufferu dat
DiarPDel EQU       6                        ; (1) d‚lka textu
DiarPSum EQU       7                        ; d‚lka jedn‚ polo‘ky indexu

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;
;                     Definice glob ln¡ch promˆnn˜ch
;
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°


; Po©ad¡ spojovan˜ch modul–:
;   - LOD (modul zavadˆ‡e)
;   - INT (obsluha p©eru¨en¡)
;   - DIS (obsluha displeje)
;   - KEY (obsluha kl vesnice a my¨i)
;   - DISK (obsluha disku)
;   - DEK (dek¢dov n¡)
;   - LIN (© dkov˜ editor, p©¡kazov˜ © dek)
;   - HLP (obsluha n povˆdy)
;   - MNU (volby)
;   - FIL (soubory)
;   - TRE (strom)
;   - LST (seznam)
;   - ZVL (zvl ¨tn¡ funkce)
;   - DBF (datab ze)
;   - EDI (editor)
;   - MEM (obsluha pamˆti)
;   - DM (hlavn¡ procedura)


; -----------------------------------------------------------------------------
;        Modul LOD
; -----------------------------------------------------------------------------
; segment CodeLod
;þ
GLOBAL   Execute:FAR,Int024:FAR,Int023:FAR
GLOBAL   CodePage:BYTE,CodePagK:BYTE,Cod0PagK:BYTE,CodePag0:BYTE
GLOBAL   ColsBeg:BYTE,ColsEnd:BYTE,ColMono:BYTE,ColColo:BYTE
GLOBAL   RezIdent:BYTE,ConfBeg:BYTE,ConfEnd:BYTE,ExecPck0:WORD
GLOBAL   ExecPack:WORD,ExecPckE:WORD,ExecPck1:WORD,ExecPck2:WORD,ExecPck3:WORD
GLOBAL   ExecPath:BYTE,DosmPath:BYTE,DosmPth0:BYTE
GLOBAL   NWinPath:BYTE,NWinPthN:WORD,ParamLC:BYTE,ParamRC:BYTE
GLOBAL   AWinKFil:BYTE,NWinKFil:BYTE,AWinKOff:WORD,NWinKOff:WORD

; -----------------------------------------------------------------------------
;        Modul INT (obsluha p©eru¨en¡)
; -----------------------------------------------------------------------------
; segment CodeInt

;GLOBAL   InstTInt:FAR,DInsTInt:FAR,
GLOBAL   InstInt:FAR,Int09:FAR,DeInsInt:FAR,Inst2Int:FAR
GLOBAL   GetBreak:FAR,SetEsc:FAR,NulBreak:FAR,TestBreak:FAR,TestEsc:FAR
GLOBAL   TestBEsc:FAR,ZapKrit:FAR,VypKrit:FAR,SetBreak:FAR
GLOBAL   InstA08:FAR,DInsA08:FAR,TestTDis:FAR
GLOBAL   TestQVw:FAR,InitQVw:FAR

GLOBAL   ParInt24:BYTE,Rez13Par:BYTE

; -----------------------------------------------------------------------------
;        Modul DIS (obsluha displeje)
; -----------------------------------------------------------------------------
; segment CodeDis

;GLOBAL   PushWin:FAR,PopWin:FAR
GLOBAL   InitIDis:FAR,ImplVMod:FAR,Intens:FAR
GLOBAL   PushScr:FAR,PopScr:FAR,SetFont:FAR,GetFont:FAR,KurzInv:FAR
GLOBAL   SizeHKur:FAR,SizeLKur:FAR,KurzOff:FAR,SetKurz:FAR,GetKurz:FAR
;GLOBAL   StinWin:FAR
;GLOBAL   Disp1Chr:FAR,DispChr:FAR,
GLOBAL   DispTxt:FAR,DispStr:FAR
GLOBAL   InitVMod:FAR,SetVMode:FAR,AktPDisp:FAR,DetCard:FAR,InitVMdI:FAR
GLOBAL   Int10P:FAR
GLOBAL   NastDis:FAR,PopFont:FAR,InitSFnt:FAR,InitFont:FAR
GLOBAL   ShiftF10:FAR

GLOBAL   DspNMnu:BYTE,KodNMnu:BYTE
GLOBAL   STopAdr:WORD,SSegment:WORD,SBajtRow:WORD,SKurzor:WORD,SPodklad:WORD
GLOBAL   STopLine:BYTE,SRadku:BYTE,SPozic:BYTE,FontSegm:WORD
GLOBAL   AdrVRAM:DWORD,PortCRT:WORD,ByteRow:WORD,Pozic:BYTE,MaxPoz:BYTE
GLOBAL   Radku:BYTE,MaxRow:BYTE,EgaVga:BYTE,ChckSnow:BYTE,AktPage:BYTE
GLOBAL   LineFont:BYTE,UserVMod:BYTE,AktVMod:BYTE,MonoMod:BYTE
GLOBAL   InitVMd:BYTE,NumVMod:WORD
;,InitVMdN:WORD
;GLOBAL   AktVMode:BYTE,NumVMod:WORD,DspNMSwc:BYTE,
GLOBAL   ParDisp2:BYTE,ParDisp:BYTE,ParDisp3:BYTE,MouseKCh:BYTE,CodePagT:WORD

; -----------------------------------------------------------------------------
;        Modul KEY (vstup z kl vesnice, ovl d n¡)
; -----------------------------------------------------------------------------
; segment CodeKey

GLOBAL   DarkNul:FAR,Darker:FAR,DarkParm:BYTE,DarkTime:WORD
GLOBAL   InitMous:FAR,MouseOn:FAR,MouseOff:FAR,GetMouse:FAR,MouseInt:FAR
GLOBAL   MouseWin:FAR,MouseTst:FAR,MouseGet:FAR,MouseMnu:FAR,RIniMous:FAR
GLOBAL   TestChar:FAR,InputChar:FAR,InpPresm:FAR,FlushChr:FAR,InpPres0:FAR
GLOBAL   FlushEsc:FAR,GetCTime:FAR,GetCDelt:FAR,MousBrea:FAR
GLOBAL   PlayMus:FAR,PlayTon:FAR,SoundOn:FAR,SoundOff:FAR
GLOBAL   KeyBuff:Word,Presmyk:byte,MousePoz:WORD,ParMouse:BYTE,MouseChr:WORD
;GLOBAL   DarkChar:WORD,
GLOBAL   DarkExec:BYTE,DarkExeN:WORD,DarkMap:BYTE,MouseKey:BYTE,ParMous2:BYTE

; -----------------------------------------------------------------------------
;        Modul DISK (obsluha disku)
; -----------------------------------------------------------------------------
; segment CodeDisk
;þ
GLOBAL   ResDisk:FAR,GetSerN:FAR
;GLOBAL   InitDKom:FAR,
GLOBAL   IniDSKom:FAR
GLOBAL   InitDPar:FAR,KonvND:FAR,KonvDN:FAR

GLOBAL   GetVol:FAR,GetDInfo:FAR,IntCD:FAR,InpIOCD:FAR,GetRBook:FAR
;GLOBAL   DispPath:FAR
GLOBAL    AktADir:FAR

GLOBAL   SetDTA:FAR,Set0DTA:FAR
GLOBAL   GetDir:FAR,GetADir:FAR,SetDir:FAR,SetDDir:FAR,InitAPth:FAR,InitHPth:FAR
GLOBAL   GetDisk:FAR,SetDisk:FAR,TestDisk:FAR,InitTPth:FAR
GLOBAL   CreatDir:FAR,ResFile:FAR,SizeFile:FAR,CreatFil:FAR,SetUFile:FAR,GetUFile:FAR
GLOBAL   CreaLDir:FAR,CreaXDir:FAR,TestDev:FAR,ClosLDir:FAR,IniLDir:FAR
GLOBAL   ResLDir:FAR,NextLDir:FAR,OpenLDir:FAR
GLOBAL   SrcFirst:FAR,SrcNext:FAR,ExisFile:FAR,SrcClose:FAR
;SrcFKonv:FAR,

GLOBAL   NormFile:FAR,NormFilL:FAR,FullFile:FAR
;,TestChDr:FAR


GLOBAL   GetParB:FAR,InitLDsk:FAR,GetAClus:FAR,OpenLFat:FAR,ClosLFat:FAR
GLOBAL   IniLDskZ:FAR
GLOBAL   ReadLDsk:FAR,WritLDsk:FAR,WritFat:FAR,GetLFat:FAR,OffsFat:FAR
GLOBAL   ClstSekt:FAR,GetClust:FAR,SetClust:FAR
GLOBAL   OpenR:FAR,OpenRW:FAR,OpenRErr:FAR,ReadErr:FAR,WritErr:FAR,CompErr:FAR
GLOBAL   CompWar:FAR,CopDErr:FAR,CopDErPr:FAR,CopErEq:FAR,CreatErr:FAR
GLOBAL   RenDErr:FAR,CopCErr:FAR,OpenW:FAR
GLOBAL   ReadFile:FAR,WritFile:FAR,RenFile:FAR,GetDFile:FAR,SetDFile:FAR,DelFile:FAR,ClosFile:FAR,FlshFile:FAR
GLOBAL   DelDir:FAR,Read0Fil:FAR,SetDTDir:FAR
GLOBAL   SetAFile:FAR,GetAFile:FAR,CreatPF:FAR,CreatTmp:FAR,ShrtXFil:FAR
GLOBAL   RenXFile:FAR,OpenXRW:FAR,CreaXFil:FAR,SetXAFil:FAR,CreOXFil:FAR

GLOBAL   TempDir:BYTE,TempDirN:WORD,TempDirP:BYTE

GLOBAL   SrcLDir:FAR

GLOBAL   SetVol:FAR

GLOBAL   SmartSiz:FAR,SmartSet:FAR,SmartGet:FAR,SmartRes:FAR,SmartFls:FAR
GLOBAL   SmartDet:FAR
GLOBAL   InpIOCD:FAR,NulIOCD:FAR,IntCD:FAR
GLOBAL   PozadCD:BYTE,ZahlCD:BYTE

GLOBAL   GetErr:FAR
GLOBAL   DMnuVTit:BYTE

GLOBAL   DiskNum:WORD,DiskITab:BYTE
;GLOBAL    AktWin:WORD

;GLOBAL   DiskInfT:WORD,
GLOBAL   DiskInfA:WORD,DiskInfS:WORD,DiskInfK:WORD,DiskInfP:BYTE,DTALAtr:BYTE
GLOBAL   BuffDTA:BYTE,VolDate:WORD,VolTime:WORD,DTALCrea:BYTE,DTALOpen:BYTE
;GLOBAL   FileDInf:BYTE

GLOBAL   LastErr:WORD

GLOBAL   DskLDisk:BYTE,DskLPar:BYTE,DskLBSkt:WORD,DskLOSkt:WORD,DskLASkt:WORD
GLOBAL   DskLNSkt:DWORD,DskLSBlk:WORD,DskLOBlk:WORD,DskLBBlk:WORD,DskLRBlk:BYTE
GLOBAL   DskLNBlk:WORD,DskLMBlk:WORD,DskLBFat:WORD,DskLNFat:BYTE,DskLSFat:WORD
GLOBAL   DskLCFat:WORD,DskLBRot:WORD,DskLNRot:WORD,DskLSRot:WORD,DskLBDat:WORD

GLOBAL   DskLDir:BYTE,DskLDirN:WORD,GetCDMxS:DWORD,DskLDir0:BYTE

GLOBAL   BootLabl:BYTE,Boot29:BYTE,BootBeg:BYTE,DMnuVBlk:BYTE

; -----------------------------------------------------------------------------
;        Modul DISK1
; -----------------------------------------------------------------------------

GLOBAL   Parkov:FAR,Labs:FAR,Format:FAR
GLOBAL   LabsF:FAR,FormatF:FAR,InitOMnu:FAR,DispOMnu:FAR
GLOBAL   InitIDsk:FAR,FormTab:BYTE,FormParm:BYTE

GLOBAL   ColFRam:BYTE,ColFNul:BYTE,ColFForm:BYTE,ColFOK:BYTE,ColFErr:BYTE

GLOBAL   FrmDMBlk:BYTE,RusDMBlk:BYTE,KopDMBlk:BYTE,KopD2Blk:BYTE,CmpDMBlk:BYTE
GLOBAL   CmpD2Blk:BYTE

; -----------------------------------------------------------------------------
;        Modul DISK2
; -----------------------------------------------------------------------------

GLOBAL   DiskDInf:FAR,DiskVer:FAR,EdiDisk:FAR,ZobDisk:FAR,DiskSRet:NEAR
GLOBAL   InitPMnu:FAR,DispPMnu:FAR,DiskMap:FAR,CmpDRErr:NEAR,ZobDRErr:NEAR
GLOBAL   ZobDiskF:FAR,DispZMnu:FAR,InitZMnu:FAR,DiskSOff:NEAR,ZobDWErr:NEAR
;GLOBAL   DZHText:BYTE,DZHTextN:WORD,DZHText0:BYTE
GLOBAL   TextFnd:BYTE,TextFndN:WORD,TextFnd0:BYTE
GLOBAL   TextSub:BYTE,TextSubN:WORD,TextSub0:BYTE,DZCMLPl2:BYTE

GLOBAL   ColDMapF:BYTE,ColDMapC:BYTE,ColDMapB:BYTE,ColDMapV:BYTE,ColDMapP:BYTE
GLOBAL   ColDMapS:BYTE,CDColInd:BYTE,DVDSmart:BYTE
GLOBAL   ColDZob0:BYTE,ColDZob1:BYTE,ColDZob2:BYTE,ColDZob3:BYTE,ColDZob4:BYTE
;GLOBAL   DZAktMod:BYTE,DZHText:BYTE,DZHTextN:WORD

; -----------------------------------------------------------------------------
;        Modul DISK3
; -----------------------------------------------------------------------------

GLOBAL   NulDisk:FAR,RusDisk:FAR,KopDisk:FAR,CmpDisk:FAR,RghDSize:NEAR
GLOBAL   KopDiskF:FAR,NulDPar:BYTE,NulDBajt:BYTE
GLOBAL   KopD4Mnu:BYTE,CmpD4Mnu:BYTE

; -----------------------------------------------------------------------------
;        Modul DEK (dek¢dov n¡)
; -----------------------------------------------------------------------------
; segment CodeDek

GLOBAL   TestWrd:FAR,DekTText:FAR
GLOBAL   GetSDate:FAR,GetSTime:FAR
GLOBAL   DekSTime:FAR,DekSDate:FAR,DekDate:FAR,DekDDate:FAR,DekDDat0:FAR
GLOBAL   DekNumB:FAR,DekNumW:FAR,DekNum:FAR
GLOBAL   DekHWord:FAR,DekHByte:FAR,DekBByte:FAR
GLOBAL   Dek10Num:FAR,DekNumD:FAR
GLOBAL   TestKonc:FAR
GLOBAL   KonvFnt:FAR,KonvFChr:FAR
GLOBAL   KonvUpC:FAR,KonvDnC:FAR
GLOBAL   DekUkaz:FAR
GLOBAL   DownCase:FAR,UpCase:FAR

GLOBAL   TabTypCh:BYTE,KonvFntT:WORD
GLOBAL   TbKamCS0:BYTE,TbKamIBM:BYTE,TbKamLat:BYTE,TbKamKoi:BYTE
GLOBAL   TbLatCS0:BYTE,TbLatIBM:BYTE,TbLatKam:BYTE,TbLatKoi:BYTE
GLOBAL   TbIBMUpC:BYTE,TbKamUpC:BYTE,TbLatUpC:BYTE,TbKOIUpC:BYTE,TbWinUpC:BYTE
GLOBAL   TbIBMDnC:BYTE,TbKamDnC:BYTE,TbLatDnC:BYTE,TbKOIDnC:BYTE,TbWinDnC:BYTE

; -----------------------------------------------------------------------------
;        modul WIN1 (zobrazen¡ adres ©ov˜ch oken)
; -----------------------------------------------------------------------------
; segment CodeWin

GLOBAL   InitIWin:FAR,InitWins:FAR,AktIWin:FAR,InitMWin:FAR
GLOBAL   DispAAWn:FAR,DispNAWn:FAR,DispAWin:FAR,InfoFile:FAR,DispWAkt:FAR
GLOBAL   DekAFil:FAR,DekASiz:FAR,DekA4Dat:FAR,DekADat:FAR,DekATim:FAR
GLOBAL   DekATmS:FAR,DekAAtr:FAR,DirSumm:FAR
GLOBAL   GetLAWin:FAR,GetRAWin:FAR,GetAAWin:FAR,GetNAWin:FAR
GLOBAL   TestLAWn:FAR,TestRAWn:FAR,TestAAWn:FAR,TestNAWn:FAR,TestAWin:FAR

GLOBAL   ModWDisk:FAR

GLOBAL   ParamL:BYTE,SegmL:WORD,SegmLAdr:WORD
;,SegmLLst:WORD,SegmLTre:WORD
GLOBAL   ParamR:BYTE,SegmR:WORD,SegmRAdr:WORD
;,SegmRLst:WORD,SegmRTre:WORD
GLOBAL   WindPar:BYTE,SegmAkt:WORD,SegmNAkt:WORD,NumRows:BYTE,NumRows0:BYTE
GLOBAL   OddelRad:BYTE,ZnakTim:BYTE,ZnakDat:BYTE,FormDat:BYTE,OddelDes:BYTE
GLOBAL   OddelPol:BYTE
GLOBAL   QSrcBuff:BYTE,QSrcNum:BYTE,WindPar2:BYTE,SegmFGrp:WORD,GrpSortT:BYTE
GLOBAL   ColAWin1:BYTE,ColAWin2:BYTE,ColAWin3:BYTE,ColAWin4:BYTE,ColAWinT:BYTE
;GLOBAL   ColAWin5:BYTE,ColAWin6:BYTE,ColAWin7:BYTE,ColAWin8:BYTE,ColAWin9:BYTE
GLOBAL   DskTxtN:BYTE,DskTxtP:BYTE
;GLOBAL   LWinIPrm:BYTE,LWinIPr2:BYTE,RWinIPrm:BYTE,RWinIPr2:BYTE
GLOBAL   ColXWin1:BYTE,ColXWin2:BYTE,ColXWin3:BYTE,ColXWin4:BYTE
GLOBAL   ColLWin1:BYTE,ColLWin2:BYTE,ColLWin3:BYTE,ColLWin4:BYTE,ColLWin5:BYTE
GLOBAL   ColTWin1:BYTE,ColTWin2:BYTE,ColTWin3:BYTE,ColTWin4:BYTE,ColLWin6:BYTE

; -----------------------------------------------------------------------------
;        modul WIN2 (obsluha funkc¡ adres ©ov˜ch oken)
; -----------------------------------------------------------------------------
; segment CodeWin

GLOBAL   InitRows:FAR
GLOBAL   EditAWin:FAR,QSrcEnd:FAR,InvSPol:FAR,SetSPol:FAR,ResSPol:FAR
GLOBAL   EditSMnu:FAR,SelPol:FAR,SelPol0:FAR

GLOBAL   ModiWDir:FAR,SrcWNam:FAR,KomSIni:FAR,ModAWDir:FAR
GLOBAL   ReReadD:FAR,ReadDir:FAR,LoadFInf:FAR,InitDInf:FAR,StorFKom:FAR
GLOBAL   StorNKom:FAR,ReRetWK:FAR,SrcWKur:FAR,ReadDirX:FAR,WritFKom:FAR
GLOBAL   DuplAWin:FAR,CreatAWn:FAR,XchgWSeg:FAR,DeletAWn:FAR,NormIAWn:FAR
GLOBAL   SelWDir:FAR,TestMask:FAR,TestProg:FAR
GLOBAL   SortDir:FAR,InitFKom:FAR,GetAKurz:FAR,GetPol:FAR,ReSort:FAR,AktSelct:FAR
;GLOBAL   TestWPol:FAR,
GLOBAL   SortLWn:FAR,GetNKurz:FAR,GetESPol:FAR,GetPolDI:FAR
;GLOBAL   InsNFile:FAR,
GLOBAL   DelWFile:FAR,InsWFile:FAR
;DelWFile:FAR,
;,StorFile:FAR
;,GetKomSI:FAR,GetKomDI:FAR,
GLOBAL   HomeFile:FAR,RetWKur:FAR,TempFile:FAR,AktWFile:FAR

;GLOBAL   MaxFiles:WORD,
GLOBAL   AllDisk:BYTE,AllDir:BYTE,All:BYTE
GLOBAL   HomeDirN:WORD,HomeDir:BYTE,TabScan:BYTE,ChybRDir:BYTE,ChbRDirC:BYTE
GLOBAL   FileInfo:BYTE

; -----------------------------------------------------------------------------
;        modul WIN3 (ovl d n¡ adres ©ov˜ch oken)
; -----------------------------------------------------------------------------
; segment CodeWin

GLOBAL   AWinWin:FAR,AWMOL1D:FAR,AWMOMsk:FAR

GLOBAL   AWMMnuO:FAR,VyskTxt:BYTE

; -----------------------------------------------------------------------------
;        Modul LIN (obsluha p©¡kazov‚ho © dku)
; -----------------------------------------------------------------------------
; segment CodeLin

GLOBAL   DispLCom:FAR,DispLKur:FAR,InitLCom:FAR,EditLCom:FAR,MousLin:FAR

GLOBAL   LinePCol:BYTE,LineCCol:BYTE,LineOCol:BYTE,LineCPar:BYTE
GLOBAL   LineCRad:BYTE,LineCVys:BYTE
GLOBAL   LineCNum:BYTE,LineCMax:BYTE,LineCTop:BYTE,LineCKur:BYTE,LineCBuf:BYTE
GLOBAL   AktPathN:WORD,AktPath:BYTE

; -----------------------------------------------------------------------------
;        Modul HLP (n povˆda)
; -----------------------------------------------------------------------------
; segment CodeHlp

GLOBAL   InitFHlp:FAR,InitGMnu:FAR,DispGMnu:FAR,EditGMnu:FAR,FKeyMenu:FAR
GLOBAL   Disp0Hlp:FAR,DispFHlp:FAR,DispMHlp:FAR,DispHTxt:FAR,MenuFnK:FAR
GLOBAL   HelpPar:BYTE,HelpColH:BYTE,HelpSeg:WORD,HelpKeyA:BYTE,HelpKeyE:BYTE
GLOBAL   HelpKBin:BYTE,HelpKHex:BYTE,HelpKTab:BYTE,HelpKEdi:BYTE
GLOBAL   InitHMnu:FAR,DispHMnu:FAR,HelpF:FAR,HelpAF:FAR,MenKlHlp:FAR
;,HelpKPoc:BYTE
;GLOBAL   HelpKVyb:BYTE,
GLOBAL   HelpKOpt:BYTE,HelpKTyp:BYTE,HelpKZob:BYTE,HelpKVer:BYTE
GLOBAL   HelpColN:BYTE,HelpColT:BYTE,HelpColH:BYTE,HelpClH2:BYTE,GMnuVert:BYTE
GLOBAL   HelpColK:BYTE,HelpFSeg:WORD,HelpKSyn:BYTE,HelpKNum:BYTE,HelpKOkn:BYTE
GLOBAL   HelpColM:BYTE
GLOBAL   ColHlp1:BYTE,ColHlp2:BYTE,ColHlp3:BYTE,ColHlp4:BYTE,ColHlp5:BYTE
GLOBAL   ColHlp6:BYTE,ColHlp7:BYTE,ColHlp8:BYTE,ColHlp9:BYTE,ColHlpA:BYTE
GLOBAL   ColHlpB:BYTE,HlpAStrn:WORD,HelpMenu:BYTE
;GLOBAL   HelpHisU:WORD,HelpHis:WORD

; -----------------------------------------------------------------------------
;        Modul MNU 1 (hlavn¡ a vertik ln¡ menu)
; -----------------------------------------------------------------------------
; segment CodeMnu

GLOBAL   OpenMnu:FAR,ClosMnu:FAR,ClosMnuA:FAR,DispMnu:FAR,MCtrlO:FAR
GLOBAL   EditMEnt:FAR,TestMSwc:FAR,TestMnu:FAR,DispTim0:FAR,DispTime:FAR
GLOBAL   SrcHotA:FAR,SrcHotM:FAR,GetSwch:FAR,SetSwch:FAR
GLOBAL   DispRamM:FAR,DispCarM:FAR,DispTxtM:FAR,DispTxtR:FAR,DispMStr:FAR
GLOBAL   KorPozM:FAR,CentMenu:FAR,DispKStr:FAR
GLOBAL   MainMenu:FAR,InitMMnu:FAR,DispMMnu:FAR,EditMMnu:FAR
GLOBAL   VertMenu:FAR,InitVMnu:FAR,DispVMnu:FAR,EditVMnu:FAR,MenuNum:FAR
GLOBAL   MenBHex:FAR,MenWHex:FAR

GLOBAL   ZnakSwch:BYTE,ZnakSwc0:BYTE,KodFntTb:WORD
GLOBAL   NumMenu:WORD,TabMenu:WORD,PozMenu:WORD,SirMenu:WORD
GLOBAL   AktMenu:WORD,ParMenu:BYTE,InfTxt1:BYTE,ParMenu2:BYTE
GLOBAL   ColTime:BYTE,ColDate:BYTE
GLOBAL   ColMnu1:BYTE,ColMnu2:BYTE,ColMnu3:BYTE,ColMnu4:BYTE
GLOBAL   ColMnu1L:BYTE,ColMnu1R:BYTE,ColMnu3L:BYTE,ColMnu3R:BYTE
GLOBAL   ColMnu5:BYTE,ColMnu6:BYTE,ColMnuN:BYTE

; -----------------------------------------------------------------------------
;        Modul MNU 2 (horizont ln¡ a diskov‚ menu)
; -----------------------------------------------------------------------------

GLOBAL   InitHist:FAR,GetHist:FAR,SrcHist:FAR,DelHist:FAR,InsHist:FAR,SrtHist:FAR
GLOBAL   Lin1Menu:FAR,Lin0Menu:FAR,Lin0MenR:FAR,StoSHist:FAR,HistADir:FAR
GLOBAL   Lin0MenF:FAR,LinPMenu:FAR,Lin0MenP:FAR
GLOBAL   LineMenu:FAR,InitLMnu:FAR,RedLMnu:FAR,HistLMnu:FAR,EditLMnu:FAR
GLOBAL   EditLine:FAR,DispLine:FAR,DispLMnu:FAR
GLOBAL   DiskMenu:FAR,InitDMnu:FAR,EditDMnu:FAR,DispDMnu:FAR

GLOBAL   DiskMnu:BYTE,DiskMPlL:BYTE,DiskMPlR:BYTE ;,DiskMHl2:BYTE
GLOBAL   LinMax:BYTE,LinNum:BYTE,LinTop:BYTE,LinKur:BYTE,LinRad:BYTE
GLOBAL   LinBuff:BYTE,LinParm:BYTE
GLOBAL   ColMnu7:BYTE,ColMnu8:BYTE,ColMnu9:BYTE,ColMnuA:BYTE,ColMnuB:BYTE,ColMnuC:BYTE
GLOBAL   HistSeg:WORD,HistSizT:WORD,LinMenTE:DWORD,LinMenTM:WORD,MenuHlP1:BYTE
GLOBAL   MenuHlP2:BYTE

; -----------------------------------------------------------------------------
;        Modul MNU 3 (u‘ivatelsk‚ menu)
; -----------------------------------------------------------------------------

GLOBAL   UserMenu:FAR,InitCMnu:FAR,DispCMnu:FAR,EditCMnu:FAR,UserDekX:FAR
GLOBAL   UserFnc:FAR,Extens:FAR,SelcExec:FAR

GLOBAL   UserMFil:BYTE,UserSwcM:BYTE,ListMNam:BYTE,UserMNam:BYTE
GLOBAL   UMnuCol1:BYTE,UMnuCol2:BYTE,UMnuCol3:BYTE,UMnuCol4:BYTE
GLOBAL   UMnuClR1:BYTE,UMnuClR2:BYTE,UMnuColT:BYTE,UMnuColH:BYTE,UMnuClH2:BYTE
GLOBAL   UMnuColP:BYTE,UMnuClP2:BYTE,UserLast:WORD

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

GLOBAL   InitAMnu:FAR,InitTMnu:FAR,InitRMnu:FAR
GLOBAL   InitBMnu:FAR,InitSMnu:FAR

GLOBAL   AMnuMain:BYTE,ZMnuVert:BYTE,OMnuVert:BYTE,SMnuVert:BYTE,DMnuVert:BYTE
GLOBAL   NMnuVert:BYTE,KMnuVert:BYTE
GLOBAL   LMnuAktL:WORD,LMnuAktR:WORD,LMnuVert:BYTE,LMnuVT1:BYTE,LMnuVT2:BYTE
GLOBAL   LMnuVH1x:BYTE,LMnVH10x:BYTE
GLOBAL   LZMnAktL:WORD,LZMnAktR:WORD,LZMnVert:BYTE
GLOBAL   LTMnAktL:WORD,LTMnAktR:WORD,LTMnVert:BYTE
GLOBAL   LFMnAktL:WORD,LFMnAktR:WORD,LFMnVert:BYTE
GLOBAL   LFMMnLin:BYTE,SAMnuLin:BYTE

; -----------------------------------------------------------------------------
;        Modul FND (vyhled v n¡)
; -----------------------------------------------------------------------------
; segment CodeFnd


GLOBAL   Hledej:FAR,AWMMnuSH:FAR,AWMMnuSI:FAR,HledClos:FAR ;,CreatLWn:FAR
GLOBAL   AktPthAL:FAR,AktPathL:FAR,AktPth0L:FAR

GLOBAL   SHZMLin:BYTE,HledTxt1:BYTE,HledUloP:BYTE,HledCtiP:BYTE,ChybFndF:BYTE

; -----------------------------------------------------------------------------
;        Modul FIL1 (soubory)
; -----------------------------------------------------------------------------
; segment CodeFil
;þ
GLOBAL   CompWin:FAR,GetBFCB:FAR,AsciFCB:FAR,GetBFCB0:FAR

GLOBAL   CAdresar:FAR,SelSelct:NEAR
;GLOBAL   AWSMnu:FAR,
GLOBAL   FileAsc:FAR,EditF4:NEAR,FileMask:BYTE,FileMskN:WORD

GLOBAL   InfoClr:FAR,InfoTxt:FAR,InfoDek:FAR,InfoDisp:FAR,InfoClos:FAR,InfoAkt:FAR
GLOBAL   InfDisp0:FAR,InfKFile:FAR,InfFile:FAR,InfLDir:FAR,InfoClr0:FAR
GLOBAL   InitFFil:FAR,CloSFFil:FAR,GetFFil:FAR,GetNFFil:FAR,ResFFil:FAR
GLOBAL   CreatBuf:FAR,GetBuff:FAR
GLOBAL   InfoKurz:FAR,InfoKurD:FAR
GLOBAL   RozborZ:FAR,Rozbor:FAR,RozbFPth:FAR,SrcFText:FAR
GLOBAL   GetBTest:FAR,AddGFil:FAR,SubGFil:FAR,DelBuff:FAR
GLOBAL   InitFCil:FAR,GetFCil:FAR,DekFParm:FAR,InitFSet:FAR

GLOBAL   RozbPDt0:NEAR,RozbPHod:NEAR,RozbPMin:NEAR,RozbPSek:NEAR,RozbPCh:NEAR
GLOBAL   RozbPAtr:NEAR,RozbPErr:NEAR,SrcTextN:WORD,RozXPCh:FAR

GLOBAL   InfoCol1:BYTE,InfoCOl2:BYTE
;,SInfHled:BYTE
GLOBAL   FilePath:BYTE,FilePthN:WORD,BuffSeg:WORD,SF1MnLin:BYTE,SF2MnLin:BYTE
GLOBAL   FileFAtr:BYTE,FileFSiz:DWORD,FileFDat:WORD,FileFTim:WORD
GLOBAL   FileIdnt:WORD,FileOPtN:WORD,FileOPth:BYTE,FileOIdn:WORD
GLOBAL   InfoKMax:DWORD,InfoKCit:DWORD,FileFCB:BYTE,InfoPar:BYTE,FileFPol:BYTE
GLOBAL   FileTyp:BYTE,FileParm:BYTE,FileWNum:WORD,FileWSeg:WORD,FileFCB0:BYTE
;FilePrm2:BYTE,
GLOBAL   FileFilN:WORD,BuffSize:WORD,SrcInit:BYTE
GLOBAL   FileTxtP:BYTE,ChybBuff:BYTE
GLOBAL   CilPath:BYTE,CilPathN:WORD,CilPthN0:WORD,CilCilPN:WORD,CilIdent:WORD
GLOBAL   SIMnLHlp:BYTE,SelParam:BYTE,ChbLnPar:BYTE,ChbLnDsk:BYTE,ChbLnDP1:BYTE

GLOBAL   RozXPOdd:FAR,RozXDNum:FAR,RozXHNum:FAR
GLOBAL   TabPozic:BYTE,InpKod:BYTE,OutKod:BYTE,FiltrPar:BYTE,TiskPres:WORD
GLOBAL   TiskPoc:WORD,TiskDelk:WORD,TiskLeft:WORD,TiskRght:WORD,TiskParm:BYTE
GLOBAL   TiskOut:WORD,MenuFndH:BYTE,ChbLnV1T:BYTE,ChbLnP1T:BYTE,ChbLnH1T:BYTE
GLOBAL   NulFBajt:BYTE,ProgSwc:BYTE,ProgSwc2:BYTE,MenuSelH:BYTE,ProgSwc3:BYTE
GLOBAL   CopyParD:BYTE,CompCfg:BYTE,SrcAtr:BYTE,SMnuVBlk:BYTE,CopyPrD2:BYTE

; -----------------------------------------------------------------------------
;        Modul FIL2
; -----------------------------------------------------------------------------

GLOBAL   AWMMnuSA:FAR,AWMMnuSB:FAR,AWMMnuSF:FAR
GLOBAL   AWMMnuST:FAR,AWMSBC22:FAR,AWMSBC24:FAR,AWMSBC26:FAR
;,AWMAkAW:FAR

GLOBAL   SBMnVert:BYTE,SFMnVert:BYTE,STMnVert:BYTE
GLOBAL   SBPMVBlk:BYTE,SBPMVTit:BYTE,SBPMVMnu:WORD,SBPMVHl3:BYTE,SBPMVHl4:BYTE
GLOBAL   ChbLnB1P:BYTE,ChbLnP1B:BYTE,ChbLnP1T:BYTE,ChbLnP1E:DWORD,ChbLnP1M:WORD

; -----------------------------------------------------------------------------
;        Modul FIL3
; -----------------------------------------------------------------------------

GLOBAL   AWMMnuSR:FAR,RusSoubF:FAR
;,AWDAkAW:FAR
GLOBAL   AWMMnuSN:FAR

GLOBAL   SRMnVert:BYTE,SR6MnLin:BYTE
GLOBAL   SNMnVert:BYTE,RusParm2:BYTE
GLOBAL   SRMnuFil:BYTE,SRMnuSiz:BYTE,SRMnuDat:BYTE,SRMnuTim:BYTE,SRMnuAtr:BYTE

;,SR6MnHlp:BYTE,SR6MnBlk:BYTE,SR6MnTit:BYTE
;GLOBAL   SR6MnExe:DWORD,SR6MnAdr:WORD
GLOBAL   RootDir:BYTE,SR8MnBlk:BYTE

; -----------------------------------------------------------------------------
;        Modul FIL4
; -----------------------------------------------------------------------------

GLOBAL   AWMMnuSM:FAR,ModiFilF:FAR,RozbCil:FAR
GLOBAL   ModiRozb:FAR,OpenBPth:FAR
GLOBAL   Program:FAR,ProgrExe:FAR,Progr500:FAR

GLOBAL   SMMnVert:BYTE
GLOBAL   ModiWPar:BYTE,ModiAtr:BYTE,ModiAtrM:BYTE,ModiTim:WORD,ModiTimM:WORD
GLOBAL   ModiDat:WORD,ModiDatM:WORD
GLOBAL   SPMnVert:BYTE,SPZMLinM:WORD
GLOBAL   DosmBat:BYTE,SRMnVBlk:BYTE,SRMnVSwc:BYTE

; -----------------------------------------------------------------------------
;        Modul FIL5
; -----------------------------------------------------------------------------

GLOBAL   AWMMnuSK:FAR,CopyFilF:FAR
GLOBAL   AWMMnuSJ:FAR,MoveFilF:FAR

GLOBAL   SKMnVert:BYTE,SJMnVert:BYTE,CopyDRea:DWORD,CopyDBlk:WORD,CopyPrD2:BYTE

; -----------------------------------------------------------------------------
;        Modul F6
; -----------------------------------------------------------------------------

GLOBAL   AWMMnuSS:FAR,CompFile:FAR

;GLOBAL   SSMnVert:BYTE

; -----------------------------------------------------------------------------
;        Modul UND (obnoven¡ soubor–)
; -----------------------------------------------------------------------------

GLOBAL   Undelete:FAR,InitUMnu:FAR,DispUMnu:FAR,EditUMnu:FAR
GLOBAL   ColUnd1:BYTE,ColUnd2:BYTE,ColUnd3:BYTE,ColUnd4:BYTE
GLOBAL   SMnuVBlk:BYTE

; -----------------------------------------------------------------------------
;        Modul TRE (strom)
; -----------------------------------------------------------------------------
; segment CodeTre

;GLOBAL   DispATre:FAR,EditATre:FAR,LineATre:FAR

GLOBAL   SrcPathT:FAR,TreeClos:FAR
GLOBAL   EditDTWn:FAR,GetPthTW:FAR,InitTWn:FAR,AktPathT:FAR,AktPthAT:FAR
GLOBAL   Strom:FAR,CreatTWn:FAR,DispTWn:FAR,ReadTWn:FAR,BackTWn:FAR
GLOBAL   ColTre1:BYTE,ColTre2:BYTE,ColTre3:BYTE,FileNTre:BYTE

; -----------------------------------------------------------------------------
;        Modul ZVL (zvl ¨tn¡)
; -----------------------------------------------------------------------------
; segment CodeZvl

GLOBAL   ZMn2Vert:BYTE
GLOBAL   AWZMnu:FAR
GLOBAL   CDDisk:FAR

GLOBAL   DispAMnu:FAR,EditAMnu:FAR,TabAscii:FAR
GLOBAL   DispTMnu:FAR,EditTMnu:FAR
;GLOBAL   DispKMnu:FAR,EditKMnu:FAR
GLOBAL   DispRMnu:FAR,EditRMnu:FAR

GLOBAL   InitCDMn:FAR,DispCDMn:FAR   ;,NastIniF:FAR

GLOBAL   FKalMnu:BYTE,Kalkul:FAR,KalkDekF:FAR,KalkNumF:FAR,ZKMnuLHl:BYTE
GLOBAL   KalNumN:WORD,KalNumNW:WORD,KalNumD:WORD,KalNumDW:WORD,KalNumX:WORD
GLOBAL   KalNumXW:WORD,KalParm:BYTE,KalkZakl:WORD,KalkOdsz:WORD,KalkMist:WORD
;GLOBAL   KalFADD:FAR,KalFSUB:FAR,KalFMUL:FAR,KalFDIV:FAR,KalFNEG:FAR,KalFFIX:FAR
;GLOBAL   KalFSQR:FAR,KalFABS:FAR,KalFNUL:FAR
GLOBAL   KalFOR:FAR,KalFNUL:FAR

GLOBAL   ColT1:BYTE,ColT2:BYTE,ColT3:BYTE,ColT4:BYTE,AscTbSwc:BYTE,ColHod:BYTE
GLOBAL   Zaklad:WORD,MaxDes:WORD,OdsadRad:WORD,AscTbSw2:BYTE
;,Cislo1:BYTE,Cislo2:BYTE,CisloM:BYTE
;GLOBAL   CisBuf:BYTE,CisNum:BYTE,KalParm:BYTE,KalPrep:BYTE
;,ColKal1:BYTE,ColKal2:BYTE
;GLOBAL   ColKal3:BYTE,ColKal4:BYTE,ColKal5:BYTE,ColKal6:BYTE,ColKalI:BYTE

GLOBAL   KonvDatN:FAR,KonvNDat:FAR

GLOBAL   KalParm:BYTE,KalkMist:WORD

;GLOBAL   DiarCol1:BYTE,DiarCol2:BYTE,DiarCol3:BYTE,DiarCol4:BYTE
GLOBAL   DiarColV:BYTE

GLOBAL   ParZvl:BYTE,ZNMnVert:BYTE,ZMnuVert:BYTE
GLOBAL   ZAMnuLin:BYTE,ZHMnuLin:BYTE,PoctyDnu:BYTE
GLOBAL   AWZMnu1:FAR,AWZMnu2:FAR,AWZMnu3:FAR,AsciiTab:FAR,Hodiny:FAR
GLOBAL   Kalendar:FAR,AWZMnu7:FAR,AWZMnu8:FAR,AWZMnuA:FAR
GLOBAL   ZNMnVA13:BYTE,Kalend:FAR

;GLOBAL   EdiAMZ,DispTWin,EditTWin

; -----------------------------------------------------------------------------
;        Modul DBF (datab ze)
; -----------------------------------------------------------------------------
; segment CodeDbf
;þ
GLOBAL   DSezn:FAR,DSeznF:FAR,DispSMnu:FAR,EditSMnu:FAR,ReadSel:FAR,DispBMnu:FAR
GLOBAL   InitBMMn:FAR,DispBMMn:FAR,ViewDBF:FAR
GLOBAL   InitFSel:FAR,KurzSMnu:FAR,ClosFSel:FAR,DekMFSel:FAR,AExtFSel:FAR
GLOBAL   SubFSel:FAR,AddFFSel:FAR,AddAFSel:FAR,ReadFSel:FAR,AktPFSel:FAR
GLOBAL   FileSel:FAR,SSMnSHlp:BYTE

GLOBAL   DBFAdrES:NEAR,EditBLM:NEAR,SetADBF:FAR,EditBEnt:NEAR
GLOBAL   EditBDwn:NEAR,EditBMn8:NEAR

GLOBAL   SRSMnPl4:BYTE,SNSMnPr1:WORD,SNSMnLin:BYTE,SKSMnPN1:BYTE,SKSMnPA1:DWORD
GLOBAL   SKSMnPD1:WORD,SKSMnLin:BYTE,SASMnPN1:BYTE,SASMnPA1:DWORD
GLOBAL   SASMnPD1:WORD,SASMnLin:BYTE,DBHMWrt:BYTE,DBNMLHls:BYTE

GLOBAL   ColDBF1:BYTE,ColDBF11:BYTE,ColDBF2:BYTE,ColDBF3:BYTE,ColDBF4:BYTE
GLOBAL   ColDBF42:BYTE,ColDBF5:BYTE,ColDBF6:BYTE,ColDBF12:BYTE,ColDBF13:BYTE
GLOBAL   ColDBF14:BYTE,ColDBF15:BYTE,ColDBF22:BYTE,ColDBF7:BYTE
GLOBAL   MaxCPole:BYTE,DBFEParm:BYTE,DBExpPar:BYTE,DBImpPar:BYTE
;GLOBAL   SeznPath:BYTE,SeznPth1:BYTE,SeznPthN:WORD,SeznPth2:BYTE,SeznPth0:WORD
;GLOBAL   OldSFrst:WORD,OldSKurz:WORD
GLOBAL   DBKMSLin:BYTE,DBSMSLin:BYTE,DBFOdDes:BYTE,DBFOdRad:BYTE
GLOBAL   DBNMLin:BYTE,DBXMSLin:BYTE,DBIMSLin:BYTE,DBMnVert:BYTE,DBZobOld:DWORD

; -----------------------------------------------------------------------------
;        Modul DBF1
; -----------------------------------------------------------------------------
; segment CodeDbf

GLOBAL   ModiDKor:NEAR,ClosBMem:NEAR

; -----------------------------------------------------------------------------
;        Modul DBF2
; -----------------------------------------------------------------------------
; segment CodeDbf

GLOBAL   MaxiDBF:FAR,GetDBF:FAR,HlavDBF:FAR,MiniDBF:FAR,SetDBF:FAR,GetADBF:FAR

; -----------------------------------------------------------------------------
;        Modul DBF3
; -----------------------------------------------------------------------------
; segment CodeDbf

GLOBAL   UlozDBF:NEAR,EditBBS:NEAR,EditBDlt:NEAR,EditBDlC:NEAR,EditBICh:NEAR
GLOBAL   EditBIII:NEAR,EditTstN:NEAR,EditNmEn:NEAR,EditNKR:NEAR,EditTEnd:NEAR
GLOBAL   EdiBGetC:NEAR,EditPEnd:NEAR,EditPBeg:NEAR,EditPNxt:NEAR,EditPPre:NEAR
GLOBAL   EditPCRg:NEAR,EditPCLf:NEAR,EditPCT:NEAR,EditPRgh:NEAR,EditPLft:NEAR
GLOBAL   EditBIns:NEAR,EditBNul:NEAR,EditBExp:FAR,EditBImp:FAR,EditBUnd:NEAR
GLOBAL   EditBBE1:NEAR,EditBBEd:NEAR,EdiBEBeg:NEAR,EditBKop:NEAR,EditBSko:NEAR
GLOBAL   DBGetZNm:NEAR,EditBHlL:NEAR,DBFGetDT:NEAR,DBFSetDT:NEAR,EditBVlo:NEAR
GLOBAL   EdiBZIns:NEAR,EditBRus:NEAR,EdiBODel:NEAR,DBFTOpen:NEAR,DBFTDel:NEAR
GLOBAL   DBFTClos:NEAR,DBFClosF:NEAR,DBFDelF:NEAR,EditBIm1:FAR,EditBIm2:NEAR
GLOBAL   EditBIm3:NEAR,EditBEx1:FAR,EditBEx2:NEAR,EditBEx3:NEAR,EditBHle:NEAR
GLOBAL   UlozDEOF:NEAR

GLOBAL   DBFEPar2:BYTE,EditPPT3:BYTE

; -----------------------------------------------------------------------------
;        Modul ZAP (z pisn¡k)
; -----------------------------------------------------------------------------
; segment CodeZap

GLOBAL   Zapis:FAR,OpenText:FAR,InitEMnu:FAR,DispEMnu:FAR,InitText:FAR
GLOBAL   KorEMnu:FAR,KurEMnu:FAR,EditEMnu:FAR,ZapisMnX:FAR,EditNOT:FAR

GLOBAL   Set2ISwc:FAR,SetNISw0:FAR,SetNISwc:FAR,SetTISwc:FAR,DelLISwc:FAR
GLOBAL   GetNISwc:FAR,Get2ISwc:FAR,GetTISwc:FAR
GLOBAL   ZapisSwc:FAR,ZapZakod:FAR,ZapDekod:FAR,EdiZUsch:FAR
GLOBAL   IdntISwT:BYTE,KodISwcT:BYTE,VerISwcT:BYTE,ZapsTypI:BYTE

GLOBAL   ColText1:BYTE,ColText2:BYTE,ColText3:BYTE,ColText4:BYTE,ColText5:BYTE
GLOBAL   TexIETab:WORD,TexIEOkr:WORD,TexIEStr:WORD,ColText6:BYTE,ZZ2MnLin:BYTE
GLOBAL   ZZ2MnPl2:BYTE,TxtMnHM1:BYTE
;GLOBAL   ZapsPth1:BYTE,ZapsPth2:BYTE,ZapsPthN:WORD,ZapsPth0:WORD,ZapsPath:BYTE
GLOBAL   TextEPar:BYTE,ZUSMnLin:BYTE,TxtMnHl1:BYTE,TxtMnHl2:BYTE,ZZHMnLin:BYTE
GLOBAL   ZZMnTIni:BYTE,ZZMnTLft:WORD,TextEOkr:WORD,TextETab:WORD,TextEStr:WORD

;,NahrBNum:WORD,NahrBTxt:BYTE

; -----------------------------------------------------------------------------
;        Modul TAB (tabulky)
; -----------------------------------------------------------------------------
; segment CodeTab

GLOBAL   Tablk:FAR,InitTBMn:FAR,DispTBMn:FAR,ETblFBn:FAR,ETblFGB:FAR
GLOBAL   TBGetBlk:FAR,TInitBlk:FAR,TDIniBlk:FAR,ViewTBL:FAR
GLOBAL   TBBlokCB:WORD,TBBlokCE:WORD,TBBlokRB:WORD,TBBlokRE:WORD
GLOBAL   TBLHesMn:BYTE,TBLHesPN:WORD,TBLHesPA:DWORD,TablPth0:WORD

GLOBAL   ColTBLRm:BYTE,ColTBLRS:BYTE,ColTBLSt:BYTE,ColTBL1:BYTE,ColTBL11:BYTE
GLOBAL   ColTBL2:BYTE,ColTBL3:BYTE,ColTBL4:BYTE,ColTBL5:BYTE,ColTBL6:BYTE
GLOBAL   ColTBL7:BYTE,ColTBL8:BYTE,ColTBL9:BYTE

; -----------------------------------------------------------------------------
;        Modul EDI (editor - z kladn¡ obsluha)
; -----------------------------------------------------------------------------
; segment CodeEdi
;þ
GLOBAL   InitIEdi:FAR
GLOBAL   AWMMnuSE:FAR,EditF:FAR,DispAEdi:FAR,TextDet:FAR,AWMMnuSZ:FAR
GLOBAL   EditCPgU:NEAR,EditCPgD:NEAR,EditHome:NEAR,EditEnd:NEAR,EditEdi9:NEAR
GLOBAL   EditCRgh:NEAR,EditCLft:NEAR,EditRght:NEAR,EdiAktBl:NEAR
GLOBAL   EditLeft:NEAR,EditDown:NEAR,EditUp:NEAR,Edi2CF0:NEAR
GLOBAL   EditDwnY:NEAR,EditUpY:NEAR
GLOBAL   EditPgDn:NEAR,EditPgUp:NEAR,EditCtrW:NEAR,EditCtrZ:NEAR
GLOBAL   EditClos:NEAR,EditNew:NEAR,EditZap:NEAR,EditUlBl:NEAR,EditCtBl:NEAR
GLOBAL   EdiFWSrc:NEAR,EditUloz:NEAR,EditUIni:NEAR,EditChr:NEAR,EditNLn:NEAR
GLOBAL   EditEnt:NEAR,EditBS:NEAR,EditDelC:NEAR,EditDopS:NEAR,EditOrez:NEAR
GLOBAL   EditLOrz:NEAR,EditDelL:NEAR,EditTab:NEAR,EditSTab:NEAR,EditIN:NEAR
GLOBAL   EditSF10:NEAR,EditCtF9:NEAR,EditCF10:NEAR,EditF3:NEAR,EditF4:NEAR
GLOBAL   EditF5:NEAR,EditF6:NEAR,EditF8:NEAR,Stor0Blk:NEAR,Retn0Blk:NEAR
GLOBAL   DeltBlok:NEAR,StorBlok:NEAR,RetnBlok:NEAR,DoplnRad:NEAR,DoplnPoz:NEAR
GLOBAL   RetBlLn:NEAR,EditAF1:NEAR,EditAF2:NEAR,EditAF3:NEAR,EditAF4:NEAR
GLOBAL   EditAF5:NEAR,EditAF6:NEAR,EditAF7:NEAR,EditCtF1:NEAR,EditCtF2:NEAR
GLOBAL   EditCtF3:NEAR,EditCtF5:NEAR,EditCtF6:NEAR,EditSF9:NEAR,EditF9:NEAR
GLOBAL   EditTstB:NEAR,EditSetP:NEAR,DoplnOff:NEAR,EditCtZY:NEAR,EditCtWY:NEAR
GLOBAL   EditCtQY:NEAR,EditCtQH:NEAR,EditCtBS:NEAR,EditCtrT:NEAR
GLOBAL   EdiChPBL:NEAR,EdiChPBP:NEAR,EdiChPBO:NEAR,EdiChPBK:NEAR

GLOBAL   EditRPBl:NEAR,EditZpUB:NEAR,EditZapB:NEAR,EdiChPBA:NEAR

GLOBAL   ColEdi1:BYTE,ColEdi2:BYTE,ColEdi3:BYTE,ColEdi4:BYTE,ColEdi5:BYTE
GLOBAL   ColEdi6:BYTE,ColEdi7:BYTE

GLOBAL   Tabul:BYTE,SEMnVert:BYTE,EditBAK:BYTE,EditParm:BYTE,EditPar2:BYTE
GLOBAL   OpenEMod:BYTE,OldESwch:BYTE,OldESwc2:BYTE,EdiHlKod:BYTE,SZMnVert:BYTE
GLOBAL   EditTemp:WORD,EditTmpJ:BYTE,EdiHledP:BYTE,EdiHldP2:BYTE
GLOBAL   EdiMain0:FAR,EMnuMain:BYTE,EdiZnTxt:BYTE,ENFMnLin:BYTE,ENFMnLP1:BYTE
;GLOBAL   EdiHMLin:BYTE,EdiHHLin:BYTE
GLOBAL   EdiHF7Za:FAR,EdiHPrN:BYTE,EdiHHPN:BYTE,EURMnLin:BYTE
GLOBAL   SEZBMLin:BYTE,SENBMLin:BYTE,ENFMnLin:BYTE,EditPrik:BYTE
;GLOBAL   EUSMnSou:BYTE,EUSMnLin:BYTE

GLOBAL   NumEdi:WORD,SegmTEdi:WORD,EditOutI:WORD
GLOBAL   EdiWAkt:WORD,EdiWNAkt:WORD,EdiW1Win:WORD,EdiW2Win:WORD
GLOBAL   EdiS1Win:WORD,EdiS2Win:WORD,EdiSAkt:WORD,EdiSNAkt:WORD
GLOBAL   Edit0Vys:WORD,Edit0Sir:WORD,EditSBuf:WORD

; -----------------------------------------------------------------------------
;        Modul EDI1 (editor - menu)
; -----------------------------------------------------------------------------
; segment CodeEdi

GLOBAL   EditF10X:NEAR,EditF10:NEAR,EdVMPP40:NEAR

GLOBAL   EditCtBS:NEAR,EditCtQH:NEAR,EditCtQY:NEAR,EditCtQB:NEAR,EditCtQK:NEAR
GLOBAL   EditCtQM:NEAR,EditCtQP:NEAR,EditCtQZ:NEAR,EditSF6:NEAR,EditCKD:NEAR
GLOBAL   EditCtrT:NEAR

GLOBAL   DispEdi:NEAR,DispENad:NEAR,DispEdiA:NEAR,DispKEdi:NEAR

; -----------------------------------------------------------------------------
;        Modul EDI2 (editor - vnit©n¡ moduly)
; -----------------------------------------------------------------------------
; segment CodeEdi

GLOBAL   EditOpen:NEAR,EditDetT:NEAR,EditRozv:NEAR,EditFFre:NEAR,NulSBuf:NEAR
GLOBAL   InitUBuf:NEAR,EdiCrlBf:NEAR,EdiToBf0:NEAR,EdiToBuf:NEAR,EdiLnBf:NEAR
GLOBAL   EdiNxtBf:NEAR,EdiFrmB0:NEAR,EdiFrmBf:NEAR,EditCopy:NEAR,EditDel:NEAR
GLOBAL   EditBDel:NEAR,EditILn:NEAR,EditINul:NEAR,EditISpc:NEAR,EditIns:NEAR
GLOBAL   EditBNew:NEAR,EditGetP:NEAR,EditLenL:NEAR,EdiBORad:NEAR,EdiOfPoz:NEAR
GLOBAL   EdiGetAd:NEAR,EdiGetOf:NEAR,EdiGetLn:NEAR,EdiGetCL:NEAR,EdiAktL:NEAR
GLOBAL   EdiGetCh:NEAR,EditNGet:NEAR,EditBGet:NEAR,EditBCre:NEAR,EditBSto:NEAR
GLOBAL   Edi0Menu:NEAR,EditGt0D:NEAR,EditGetD:NEAR,EditGetB:NEAR,EditIRea:NEAR
GLOBAL   EditIGet:NEAR,EditTWri:NEAR,EditTRea:NEAR,EditTSet:NEAR,EditTRes:NEAR
GLOBAL   EditTSrc:NEAR,EditTSeg:NEAR,EditTGet:NEAR,EditTClo:NEAR,EditGtPO:NEAR

GLOBAL   EditTemp:WORD,EditTmpS:WORD,EditTmpN:WORD,EditBLst:WORD,EditBLsL:WORD
GLOBAL   EditBSN:WORD,EditBSTb:WORD

; -----------------------------------------------------------------------------
;        Modul EDI3 (editor - hled n¡)
; -----------------------------------------------------------------------------
; segment CodeEdi

GLOBAL   EditSF7:NEAR,EditF7:NEAR,EditHlAU:NEAR,EditHlAD:NEAR,EditHlCL:NEAR
GLOBAL   EditAF8:NEAR,EditAF9:NEAR,EditAF10:NEAR,EditHlKR:NEAR,EditHlKP:NEAR
GLOBAL   EditSyn:NEAR,EditKrDn:NEAR,EditKrUp:NEAR,EditKrLf:NEAR,EditKrRg:NEAR
GLOBAL   EditRlDn:NEAR,EditRlUp:NEAR,EditRlRg:NEAR,EditRlLf:NEAR,EdiChPBY:NEAR
;GLOBAL   EditAk0K:NEAR,EditPz0K:NEAR

GLOBAL   EditAktA:NEAR,EditAktK:NEAR,EditKorT:NEAR,EditAPzK:NEAR,EditPozK:NEAR
GLOBAL   EditSetK:NEAR,EditSetT:NEAR,EdiEShft:NEAR,EdiBShft:NEAR,EdiShift:NEAR
GLOBAL   EditStKP:NEAR,EditAktW:NEAR,EditModW:NEAR,EditGetT:NEAR,EditGetK:NEAR
GLOBAL   EditCmpK:NEAR,EditCmpT:NEAR,EditGtTP:NEAR,EditCmKP:NEAR,EditGtKP:NEAR
GLOBAL   EditStTP:NEAR,Edit1Hex:NEAR,EditGtLP:NEAR,EditCmKL:NEAR,EditModA:NEAR
GLOBAL   EditCMKO:NEAR,EdiBShf0:NEAR,EditCtF8:NEAR

GLOBAL   EdiUkTxt:BYTE,EdiZnTxt:BYTE,EdiMdKod:BYTE

; -----------------------------------------------------------------------------
;        Modul MEM (obsluha pamˆti)
; -----------------------------------------------------------------------------
; segment CodeMem

GLOBAL   InitEnv:FAR,TestAMem:FAR,NextAMem:FAR,GetEnv:FAR,Get0Env:FAR,SetEnv:FAR
GLOBAL   InitMem:FAR,MemErr:FAR,GetIEnv:FAR
GLOBAL   InsDat:FAR,DelDat:FAR,CreatDat:FAR,GetDat:FAR,InsSDat:FAR,DelSDat:FAR
GLOBAL   GetFree:FAR,GetDFree:FAR,CreatSeg:FAR,GetSgAdr:FAR,GetSgSiz:FAR
GLOBAL   GetSeg:FAR,DelSeg:FAR,ModiSegS:FAR,ModiSeg:FAR,SegMove:FAR
;GLOBAL   InstXMS:FAR,Int2F:FAR,XMS:FAR,ReadXMS:FAR,WritXMS:FAR,AlokXMS:FAR
;GLOBAL   FreeXMS:FAR

GLOBAL   Dos0AMem:WORD,EnvSegm:WORD,ChbLnMeH:BYTE,ChbLnMeT:BYTE
GLOBAL   TopSeg:WORD,FreeSeg:WORD,EndSeg:WORD,TabBAdr:WORD,TabBSiz:WORD

; -----------------------------------------------------------------------------
;        Modul DM (hlavn¡ procedura programu)
; -----------------------------------------------------------------------------
; segment Code
; segment StackS
; segment KonecS

GLOBAL   Start:FAR,ReStart:FAR,Main0:FAR,Konec:FAR,DispAll:FAR,MainRead:FAR
GLOBAL   AWMMnuS:FAR,AWMMnuZ:FAR,AWHistW0:FAR
GLOBAL   AWCtF1:NEAR,AWCtF2:NEAR
;GLOBAL   DispWord:FAR,
GLOBAL   InpChar:FAR,Cekej:FAR
GLOBAL   SUpCase:FAR
GLOBAL   AWEnter0:FAR

;GLOBAL   DosHexB:FAR,DosChar:FAR

GLOBAL   TestDSum:FAR,RetPCnf:FAR,StoPCnf:FAR

GLOBAL   AWMMnuO1:FAR,AWMMnuO2:FAR,AWTab:FAR,AWCtrlL:FAR,AWCtrlO:FAR
GLOBAL   AWTabM:FAR,AWCtrlOM:FAR,AWCtrlUM:FAR,AWCtrlLM:FAR
GLOBAL   AWMMnuO6:FAR,AWCtrlU:FAR,AWCtrlN:FAR
GLOBAL   AWMMnu0:FAR,AWMMnuK3:FAR,InitIni:NEAR

GLOBAL   JumpBX:FAR,Random:FAR
GLOBAL   DispDemo:FAR
GLOBAL   OpenGIni:FAR,OpenIni:FAR,ClosIni:FAR,OpenPIni:FAR,GetNPIni:FAR
GLOBAL   GetWPIni:FAR,GetBPIni:FAR,GetSPIni:FAR,GetYPIni:FAR,GetCPar:FAR
GLOBAL   NextLIni:FAR,JumpPTxt:FAR,InitIPYN:FAR,InitIBNm:FAR,InitIPFl:FAR
GLOBAL   JumpPShd:FAR,InitISpc:FAR,InitICar:FAR,InitIWNm:FAR,GetDIni:FAR
GLOBAL   InitIPCh:FAR,NextTIni:FAR,DTALName:BYTE,DTALNamN:WORD

GLOBAL   RezPSP:WORD,RezLoad:WORD,RezData:WORD,StartPar:BYTE,Win95Par:BYTE
GLOBAL   SegPSP:WORD,VerzeOS:WORD,StackSP:WORD,StackSS:WORD
GLOBAL   TabAMenu:WORD,UschMenu:BYTE,RandomR:DWORD

GLOBAL   NulDMnu:BYTE,SBPMVert:BYTE,SFSMVert:BYTE,SFVMVert:BYTE,STTMVert:BYTE
GLOBAL   SVMnVert:BYTE,RMnuVert:BYTE,AWMMnuN:FAR
GLOBAL   StorBCnf:FAR,GroupAdr:WORD,SegmIni:WORD
GLOBAL   ConfSumm:WORD,Vybaveni:WORD,EnvSize:WORD,DosmCnf:BYTE
GLOBAL   DosmIni:BYTE,CPU:BYTE,ModelCPU:WORD,VendrCPU:BYTE,DemoMenu:BYTE
GLOBAL   LicDPar0:BYTE

GLOBAL   Stop:NEAR

; -----------------------------------------------------------------------------
;        Modul DM2 (hlavn¡ procedura programu)
; -----------------------------------------------------------------------------
; segment Code
; segment StackS
; segment KonecS

GLOBAL   NextGIni:FAR,InitIBH1:FAR,InitIOdd:FAR,InitIFHl:FAR

; -----------------------------------------------------------------------------
;        K¢dy chyb
; -----------------------------------------------------------------------------

Err_Plny_Disk      EQU       8080h          ; disk je pln˜
Err_Inv_Disk       EQU       0fh            ; neplatn˜ disk
Err_Exst_File      EQU       8081h          ; existuje soubor jm‚na jako adres ©

; -----------------------------------------------------------------------------
;        k¢dy my¨i
; -----------------------------------------------------------------------------

MousXKod EQU       0ca00h                   ; identifika‡n¡ k¢d my¨i

MousXLP  EQU       bit0+bit2                ; stisk lev‚ho tla‡¡tka
MousXRP  EQU       bit1+bit3                ; stisk prav‚ho tla‡¡tka
MousXMP  EQU       bit0+bit1+bit2+bit3      ; stisk st©edn¡ho tla‡¡tka

MousXLH  EQU       bit0                     ; dr‘en¡ lev‚ho tla‡¡tka
MousXRH  EQU       bit1                     ; dr‘en¡ prav‚ho tla‡¡tka
MousXMH  EQU       bit0+bit1                ; dr‘en¡ st©edn¡ho tla‡¡tka

MousXLR  EQU       bit4                     ; uvolnˆn¡ lev‚ho tla‡¡tka
MousXRR  EQU       bit5                     ; uvolnˆn¡ prav‚ho tla‡¡tka
MousXMR  EQU       bit4+bit5                ; uvolnˆn¡ st©edn¡ho tla‡¡tka

MousXLD  EQU       bit0+bit2+bit6           ; 2. stisk lev‚ho tla‡¡tka
MousXRD  EQU       bit1+bit3+bit6           ; 2. stisk prav‚ho tla‡¡tka
MousXMD  EQU       bit0+bit1+bit2+bit3+bit6 ; 2. stisk st©edn¡ho tla‡¡tka

MousXMov EQU       bit7                     ; je posun my¨i (bˆhem posunu my¨i
                                            ;   nejsou tla‡¡tka sn¡m na,
                                            ;   ponech v  se star˜ stav)

; -----------------------------------------------------------------------------
;        Definice kl ves
; -----------------------------------------------------------------------------

; vy¨¨¡ bajt: 0 = znak generovan˜ s ALT-‡¡slo (nez vis¡ na p©esmyka‡¡ch)
;             1 = platn˜ znak ASCII (nez vis¡ na p©esmyka‡¡ch)
;             2 = ©¡dic¡ znak generovan˜ s Ctrl-p¡smeno
;             3 = ©¡dic¡ kl vesa - z kladn¡ ©ada
;             4 = ©¡dic¡ kl vesa s Shift-
;             5 = ©¡dic¡ kl vesa s Ctrl-
;             6 = ©¡dic¡ kl vesa s Alt-
;             7 = ©¡dic¡ kl vesa s Shift-Ctrl-
;             8 = ©¡dic¡ kl vesa s Shift-Alt-
;             9 = ©¡dic¡ kl vesa s Ctrl-Alt-
;            10 = ©¡dic¡ kl vesa s Shift-Ctrl-Alt-

;ÉÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍ»
;º kl vesa    ³      ³  S   ³  C   ³  A   º
;ÇÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄ¶
;º    Esc     ³ 011B ³ 011B ³ 011B ³ 0100 º
;º    1 !     ³ 0231 ³ 0221 ³   -  ³ 7800 º
;º    2 @     ³ 0332 ³ 0340 ³ 0300 ³ 7900 º
;º    3 #     ³ 0433 ³ 0423 ³   -  ³ 7A00 º
;º    4 $     ³ 0534 ³ 0524 ³   -  ³ 7B00 º
;º    5 %     ³ 0635 ³ 0625 ³   -  ³ 7C00 º
;º    6 ^     ³ 0736 ³ 075E ³ 071E ³ 7D00 º
;º    7 &     ³ 0837 ³ 0826 ³   -  ³ 7E00 º
;º    8 *     ³ 0938 ³ 092A ³   -  ³ 7F00 º
;º    9 (     ³ 0A39 ³ 0A28 ³   -  ³ 8000 º
;º    0 )     ³ 0B30 ³ 0B29 ³   -  ³ 8100 º
;º    - _     ³ 0C2D ³ 0C5F ³ 0C1F ³ 8200 º
;º    = +     ³ 0D3D ³ 0D2B ³   -  ³ 8300 º
;º  Back Space³ 0E08 ³ 0E08 ³ 0E7F ³ 0E00 º
;º    Tab     ³ 0F09 ³ 0F00 ³ 9400 ³ A500 º
;º     Q      ³ 1071 ³ 1051 ³ 1011 ³ 1000 º
;º     W      ³ 1177 ³ 1157 ³ 1117 ³ 1100 º
;º     E      ³ 1265 ³ 1245 ³ 1205 ³ 1200 º
;º     R      ³ 1372 ³ 1352 ³ 1312 ³ 1300 º
;º     T      ³ 1474 ³ 1454 ³ 1414 ³ 1400 º
;º     Y      ³ 1579 ³ 1559 ³ 1519 ³ 1500 º
;º     U      ³ 1675 ³ 1655 ³ 1615 ³ 1600 º
;º     I      ³ 1769 ³ 1749 ³ 1709 ³ 1700 º
;º     O      ³ 186F ³ 184F ³ 180F ³ 1800 º
;º     P      ³ 1970 ³ 1950 ³ 1910 ³ 1900 º
;º    [ {     ³ 1A5B ³ 1A7B ³ 1A1B ³ 1A00 º
;º    ] }     ³ 1B5D ³ 1B7D ³ 1B1D ³ 1B00 º
;º   Enter    ³ 1C0D ³ 1C0D ³ 1C0A ³ 1C00 º
;º     A      ³ 1E61 ³ 1E41 ³ 1E01 ³ 1E00 º
;º     S      ³ 1F73 ³ 1F53 ³ 1F13 ³ 1F00 º
;º     D      ³ 2064 ³ 2044 ³ 2004 ³ 2000 º
;º     F      ³ 2166 ³ 2146 ³ 2106 ³ 2100 º
;º     G      ³ 2267 ³ 2247 ³ 2207 ³ 2200 º
;º     H      ³ 2368 ³ 2348 ³ 2308 ³ 2300 º
;º     J      ³ 246A ³ 244A ³ 240A ³ 2400 º
;º     K      ³ 256B ³ 254B ³ 250B ³ 2500 º
;º     L      ³ 266C ³ 264C ³ 260C ³ 2600 º
;º    ; :     ³ 273B ³ 273A ³   -  ³ 2700 º
;º    ' "     ³ 2827 ³ 2822 ³   -  ³ 2800 º
;º    ` ~     ³ 2960 ³ 297E ³   -  ³ 2900 º
;º    \ |     ³ 2B5C ³ 2B7C ³ 2B1C ³ 2B00 º
;º     Z      ³ 2C7A ³ 2C5A ³ 2C1A ³ 2C00 º
;º     X      ³ 2D78 ³ 2D58 ³ 2D18 ³ 2D00 º
;º     C      ³ 2E63 ³ 2E43 ³ 2E03 ³ 2E00 º
;º     V      ³ 2F76 ³ 2F56 ³ 2F16 ³ 2F00 º
;º     B      ³ 3062 ³ 3042 ³ 3002 ³ 3000 º
;º     N      ³ 316E ³ 314E ³ 310E ³ 3100 º
;º     M      ³ 326D ³ 324D ³ 320D ³ 3200 º
;º    , <     ³ 332C ³ 333C ³   -  ³ 3300 º
;º    . >     ³ 342E ³ 343E ³   -  ³ 3400 º
;º    / ?     ³ 352F ³ 353F ³   -  ³ 3500 º
;ºPrint Screen³   -  ³   -  ³ 7200 ³   -  º
;º    [*]     ³ 372A ³ 372A ³ 9600 ³ 3700 º
;º  mezern¡k  ³ 3920 ³ 3920 ³ 3920 ³ 3920 º
;º    F1      ³ 3B00 ³ 5400 ³ 5E00 ³ 6800 º
;º    F2      ³ 3C00 ³ 5500 ³ 5F00 ³ 6900 º
;º    F3      ³ 3D00 ³ 5600 ³ 6000 ³ 6A00 º
;º    F4      ³ 3E00 ³ 5700 ³ 6100 ³ 6B00 º
;º    F5      ³ 3F00 ³ 5800 ³ 6200 ³ 6C00 º
;º    F6      ³ 4000 ³ 5900 ³ 6300 ³ 6D00 º
;º    F7      ³ 4100 ³ 5A00 ³ 6400 ³ 6E00 º
;º    F8      ³ 4200 ³ 5B00 ³ 6500 ³ 6F00 º
;º    F9      ³ 4300 ³ 5C00 ³ 6600 ³ 7000 º
;º    F10     ³ 4400 ³ 5D00 ³ 6700 ³ 7100 º
;º    [7]     ³ 4737 ³ 4700 ³ 7700 ³   -  º
;º   Home     ³ 4700 ³ 4700 ³ 7700 ³ 9700 º
;º    [8]     ³ 4838 ³ 4800 ³ 8D00 ³   -  º
;ºurzor nahoru³ 4800 ³ 4800 ³ 8D00 ³ 9800 º
;º    [9]     ³ 4939 ³ 4900 ³ 8400 ³   -  º
;º Page Up    ³ 4900 ³ 4900 ³ 8400 ³ 9900 º
;º    [-]     ³ 4A2D ³ 4A2D ³ 8E00 ³ 4A00 º
;º    [4]     ³ 4B34 ³ 4B00 ³ 7300 ³   -  º
;ºkurzor vlevo³ 4B00 ³ 4B00 ³ 7300 ³ 9B00 º
;º    [5]     ³ 4C35 ³ 4C00 ³ 8F00 ³   -  º
;º    [6]     ³ 4D36 ³ 4D00 ³ 7400 ³   -  º
;ºkurzor vprav³ 4D00 ³ 4D00 ³ 7400 ³ 9D00 º
;º    [+]     ³ 4E2B ³ 4E2B ³ 9000 ³ 4E00 º
;º    [1]     ³ 4F31 ³ 4F00 ³ 7500 ³   -  º
;º    End     ³ 4F00 ³ 4F00 ³ 7500 ³ 9F00 º
;º    [2]     ³ 5032 ³ 5000 ³ 9100 ³   -  º
;ºkurzor dol– ³ 5000 ³ 5000 ³ 9100 ³ A000 º
;º    [3]     ³ 5133 ³ 5100 ³ 7600 ³   -  º
;º Page Down  ³ 5100 ³ 5100 ³ 7600 ³ A100 º
;º    [0]     ³ 5230 ³ 5200 ³ 9200 ³   -  º
;º  Insert    ³ 5200 ³ 5200 ³ 9200 ³ A200 º
;º    [.]     ³ 532E ³ 5300 ³ 9300 ³   -  º
;º  Delete    ³ 5300 ³ 5300 ³ 9300 ³ A300 º
;º    F11     ³ 8500 ³ 8700 ³ 8900 ³ 8B00 º
;º    F12     ³ 8600 ³ 8800 ³ 8A00 ³ 8C00 º
;º    [/]     ³ E02F ³ E02F ³ 9500 ³ A400 º
;ÈÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍ¼
;
;Funk‡n¡ kl vesy Ctrl-Shift- : k¢d jako Ctrl-F, LOW bajt = 4
;Funk‡n¡ kl vesy Alt-Shift- : k¢d jako Alt-F, LOW bajt = 5
;Funk‡n¡ kl vesy Ctrl-Alt- : k¢d jako Alt-F, LOW bajt = 6

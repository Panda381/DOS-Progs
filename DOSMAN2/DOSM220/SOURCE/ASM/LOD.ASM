
INCLUDE  ASM\DEF.ASM

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;
;                              Z sobn¡k
;
; Tento z sobn¡k se pou‘¡v  jako z sobn¡k pouze p©i inicializaci DOS Mana‘eru
; a p©i startu jin‚ho programu. Mus¡ b˜t p©ilinkov n jako prvn¡ segment.
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

StackS   SEGMENT   PARA STACK 'STACK'

         db        256/8 dup('Zasobnik')    ; p©echodn˜ z sobn¡k
                                            ; (velikost zachovat - nastavuje
                                            ; se p©¡mo ‡¡selnˆ v programu)

StackS   ENDS

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                           L O A D E R
;
;                   zavadˆ‡ programu DOS Mana‘er
; -----------------------------------------------------------------------------
; tento modul mus¡ b˜t nalinkov n v‘dy jako prvn¡ z programov˜ch modul–
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°


CodeLod  SEGMENT   BYTE PUBLIC
         ASSUME    cs:CodeLod,ds:DATA

LoadBeg  LABEL     BYTE                     ; za‡ tek zavadˆ‡e k identifikaci

; -----------------------------------------------------------------------------
;        start programu - parametry v p©¡kazov‚m © dku
; -----------------------------------------------------------------------------

Execute  LABEL     FAR

; ------ zmen¨en¡ velikosti bloku programu

         mov       bx,offset ConfEnd + 15
         mov       cl,4
         shr       bx,cl
         add       bx,SEG Data              ; adresa konec dat
         mov       es,ds:[SegPSP]           ; segment PSP
         sub       bx,ds:[SegPSP]           ; velikost programu
         mov       ah,4ah
         int       21h                      ; zmen¨en¡ bloku programu

; ------ p©edefinov n¡ INT 24h

Execute1:push      ds
         push      cs
         pop       ds
         mov       dx,offset INT024
         mov       ax,2524h
         int       21h                      ; p©edefinov n¡ INT 24h

; ------ p©edefinov n¡ INT 23h

         mov       dx,offset INT023
         mov       ax,2523h
         int       21h                      ; p©edefinov n¡ INT 23h
         pop       ds

; ------ start programu (DS=datov˜ segment)

         push      ds
         pop       es
         mov       dx,offset ExecPath       ; cesta k programu
         mov       bx,offset ExecPack       ; paket parametr–
         mov       ax,4b00h
         int       21h                      ; start programu

; ------ obnoven¡ ukazatele z sobn¡ku

         mov       ax,SEG StackS            ; segment z sobn¡ku
         mov       ss,ax                    ; segment z sobn¡ku
         mov       sp,256                   ; adresa konce z sobn¡ku
         jnc       Execute5                 ; operace OK

; ------ opakov n¡ operace

         mov       dx,offset ErrCMTxt
         call      ExecErr
         jnc       Execute1

; ------ p©edefinov n¡ INT 24h

Execute5:push      cs
         pop       ds
         mov       dx,offset INT024
         mov       ax,2524h
         int       21h                      ; p©edefinov n¡ INT 24h

; ------ p©edefinov n¡ INT 23h

         mov       dx,offset INT023
         mov       ax,2523h
         int       21                       ; p©edefinov n¡ INT 23h

; ------ obnoven¡ registr–

         mov       ax,SEG Data              ; datov˜ segment
         mov       ds,ax                    ; DS <- datov˜ segment
         mov       es,ax
         mov       ds:[ExecPck1],ax         ; segment p©¡kazov‚ho © dku
         mov       word ptr ds:[ExecPck0],offset RezIdent ; tabulka identifikace

; ------ nov˜ start programu

         mov       dx,offset DosmPath
         mov       bx,offset ExecPack
         mov       ax,4b00h
         int       21h

; ------ obnoven¡ ukazatele z sobn¡ku

         mov       ax,SEG StackS            ; segment z sobn¡ku
         mov       ss,ax                    ; segment z sobn¡ku
         mov       sp,256                   ; adresa konce z sobn¡ku

; ------ obnoven¡ registr–

         mov       ax,SEG Data              ; datov˜ segment
         mov       ds,ax                    ; DS <- datov˜ segment
         jc        Execute8                 ; chyba operace

; ------ test, zda bylo chybov‚ p©eru¨en¡

         mov       ah,4dh
         int       21h                      ; poskytnut¡ n vratov‚ho k¢du
         cmp       ax,2                     ; je chyba ?
         jae       Execut82                 ; je chyba

; ------ rozli¨en¡, zda je dal¨¡ p©¡kaz

         mov       es,ds:[SegPSP]
         cmp       byte ptr es:[80h],1      ; je konec programu ?
         mov       al,1                     ; p©¡znak konce programu
         jb        Execute9                 ; konec
         mov       al,0                     ; p©¡znak povelov‚ho souboru
         je        Execute9                 ; je povelov˜ soubor
         jmp       Execute1                 ; dal¨¡ p©¡kaz

; ------ chyba - nelze zav‚st DOSMAN

Execute8:mov       dx,offset ErrDMTxt
         call      ExecErr
         jnc       Execute5
Execut82:mov       al,2

; ------ konec programu

Execute9:mov       ah,4ch
         int       21h

LoadEnd  LABEL     BYTE                     ; konec zavadˆ‡e k identifikaci

; -----------------------------------------------------------------------------
;        hl ¨en¡ chyby DX a p©¡p. opakov n¡ operace
; -----------------------------------------------------------------------------

ExecErr  PROC      NEAR

         mov       ah,9
         int       21h

         mov       dx,offset ZnovuTxt
         mov       ah,9
         int       21h

ExecErr1:mov       ah,8
         int       21h
         or        al,al
         jnz       ExecErr2
         mov       ah,8
         int       21h

ExecErr2:cmp       al,CR
         je        ExecErr3
         cmp       al,ESCP
         jne       ExecErr1
         stc
ExecErr3:ret

ExecErr  ENDP

; -----------------------------------------------------------------------------
;        p©echodn  obsluha INT 24h a INT 23h
; -----------------------------------------------------------------------------

Int024   PROC      FAR

         mov       al,0

Int023   LABEL     FAR

         iret

Int024   ENDP

CodeLod  ENDS

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;
;                                 Data
;
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;þ
Data     SEGMENT

DataBeg  LABEL     BYTE                     ; za‡ tek dat

; ------ hl ¨en¡ - COMMAND/DOSMAN nelze zav‚st

ErrCMTxt db        'Program$'
ErrDMTxt db        'DOSMAN$'
ZnovuTxt db        ' nelze zavest do pameti !'
         db        13,10,'Stisknete: ENTER=opakovani, ESC=konec...$'

; ------ identifikace rezidentn¡ho modulu DOSMAN.EXE v p©¡kazov‚m © dku

RezIdent db        10,'<DM>'                ; d‚lka © dku + identifikace
SegPSP   dw        0                        ; segment PSP
SegData  dw        SEG Data                 ; datov˜ segment
SegLoad  dw        SEG CodeLod              ; segment zavadˆ‡e

; ------ paket pro spu¨tˆn¡ programu

ExecPack label     word                     ; paket pro spu¨tˆn¡ programu
ExecPckE dw        0                        ; adresa segmentu prost©ed¡
ExecPck0 dw        80h                      ; offset p©¡kazov‚ho © dku
ExecPck1 dw        0                        ; segment p©¡kazov‚ho © dku
         dw        5ch                      ; offset prvn¡ho FCB
ExecPck2 dw        0                        ; segment prvn¡ho FCB
         dw        6ch                      ; offset druh‚ho FCB
ExecPck3 dw        0                        ; segment druh‚ho FCB

; ------ cesta ke spou¨tˆn‚mu programu

ExecPath label     byte
         db        FileMax dup(0)           ; spou¨tˆn˜ program (COMMAND.COM...)
DosmPath label     byte
         db        FileMax dup(0)           ; n vratov  cesta k DOSMAN.EXE
DosmPth0 label     byte

; *****************************************************************************
;
;             Konfigurace (uchov no v pamˆti a ukl d  se na disk)
;
; *****************************************************************************
;þ
ConfBeg  LABEL     BYTE                     ; za‡ tek konfigurace (rezid. data)

; ------ identifikace datov‚ho modulu

ConfIdnt db        'D'                      ; identifikace modulu dat
         db        DMVerze1 XOR 21h         ; hlavn¡ ‡¡slo verze
         db        DMVerze2 XOR 46h         ; desetiny ‡¡sla verze
         db        DMVerze3 XOR 83h         ; setiny ‡¡sla verze

ConfSumm dw        0                        ; kontroln¡ sou‡et modulu dat

; -----------------------------------------------------------------------------
;        displej
; -----------------------------------------------------------------------------

InitVMd  db        80,25                    ; rozmˆry po‘adovan‚ho videom¢du

ParDisp2 db        bit5                     ; parametry displeje 2
                                            ;   bit 0: 1=blik n¡ pozad¡ znak–
                                            ;   bit 1: 1=zv˜¨en  intenzita znak–
                                            ;   bit 2: 1=blik n¡ znak– DOS
                                            ;   bit 3: 1=zv˜¨en  intenzita DOS
                                            ;   bit 4: 1=pou‘¡t ¨ed‚ palety VGA
                                            ;   bit 5: 1=pou‘¡t vlastn¡ fonty
                                            ;   bit 6: 1=okno WINDOWS

MonoMod  db        0                        ; p©¡znak barev
                                            ;   bit 0: 1=po‘adavek MONO (LCD)
                                            ;   bit 1: 1=MONO videom¢d

                                            ;   bit 4: 1=je v˜stup ANSI

CodePag0 db        0                        ; u‘ivatelsky zadan  k¢dov  str nka
                                            ;    0 = nezad no
                                            ;    1 = bez diakritiky
                                            ;    2 = IBM (omezen  diakritika)
                                            ;    3 = KEYBCS2 (Kamenick˜ch)
                                            ;    4 = Latin 2

; -----------------------------------------------------------------------------
;        £schova aktivn¡ch polo‘ek menu
; -----------------------------------------------------------------------------

UschMenu label     byte
         db        31 dup(1)                ; tabulka aktivn¡ch polo‘ek menu

UserLast label     word
         dw        MaxUserM dup(0)          ; uschovan‚ volby u‘iv. menu

; -----------------------------------------------------------------------------
;        DBF
; -----------------------------------------------------------------------------

; ------ data pro datab zi

;MaxCPole db        78                       ; max. zobrazen  d‚lka text. pole>10
;DBFEParm db        bit2                     ; parametry
;                                            ;   bit 0: 1=je editace z znamu
;                                            ;   bit 1: 1=edit.buffer modifikov n
;                                            ;   bit 2: 1=zapnut INSERT
;                                            ;   bit 3: 1=modifikace ‡¡sel. pole
;                                            ;   bit 4: 1=prohl¡‘e‡ TEXT
;                                            ;   bit 5: 1=ozna‡en‚ z znamy/0=v¨e
;                                            ;          1=od kurzoru, 0=na konec
;                                            ;   bit 6: 1=definice nov‚ho z hlav¡
;                                            ;          0=modifik. star‚ho z hl.
;                                            ;   bit 7:
;
;DBExpPar db        bit0                     ; parametry pro export
;                                            ;   bit 0: 1=odˆlova‡ ‡ rka
;                                            ;   bit 1: 1=oddˆlova‡ st©edn¡k
;                                            ;   bit 2: 1=oddˆlova‡ tabul tor
;                                            ;   bit 3: 1=oddˆlova‡ r m
;                                            ;   bit 4: 1=polo‘ky ur‡eny pozic¡
;
;DBImpPar db        bit0                     ; parametry pro import
;                                            ;   bit 0: 1=odˆlova‡ ‡ rka
;                                            ;   bit 1: 1=oddˆlova‡ st©edn¡k
;                                            ;   bit 2: 1=oddˆlova‡ tabul tor
;                                            ;   bit 3: 1=oddˆlova‡ r m
;                                            ;   bit 4: 1=polo‘ky ur‡eny pozic¡

; -----------------------------------------------------------------------------
;        DIS
; -----------------------------------------------------------------------------

; ------ u‘ivatelsk˜ videom¢d

UserVMod db        -1                       ; u‘ivatelsk˜ videom¢d (-1 = nen¡)

; -----------------------------------------------------------------------------
;        DISK
; -----------------------------------------------------------------------------

;FAktDisk db        0                        ; aktivn¡ (pracovn¡) disk

;FAktForm db        1                        ; aktivn¡ form t 1..

; ------ editace disku

;DZAktMod db        0                        ; aktivn¡ m¢d editoru disku
;                                            ;   bit 0: 1=je m¢d editace
;                                            ;   bit 1: 1=byla modifikace dat
;                                            ;   bit 2: 0=HEX pole/1=ASCII pole
;                                            ;   bit 3: 0=1.znak HEX/1=2.znak HEX
;                                            ;   bit 4: 1=byl dotaz pro z pis

; ------ nulov n¡ disku

NulDPar  db        bit0+bit1+bit2           ; parametry pro nulov n¡ disku
                                            ;    bit 0: 1=nuluj¡ se adres ©e
                                            ;    bit 1: 1=nuluj¡ se soubory
                                            ;    bit 2: 1=nuluj¡ se voln‚ bloky
NulDBajt db        0                        ; nulovac¡ bajt disku

; ------ domovsk˜ programov˜ adres © (dodr‘et po©ad¡ polo‘ek !)

HomeDirN dw        3                        ; d‚lka domovsk‚ho adres ©e
HomeDir  db        'C:\',FileDMax-3 dup(0)  ; cesta k domovsk‚mu adres ©i

; ------ konfigura‡n¡ a datov˜ adres © (dodr‘et po©ad¡ polo‘ek !)

TempDirN dw        3                        ; d‚lka konfigura‡n¡ho adres ©e
TempDir  db        'C:\',FileDMax-3 dup(0)  ; cesta ke konfigura‡n¡mu adres ©i

TempDirP db        0                        ; parametry konfigura‡n¡ho adres ©e
                                            ;    bit 0: 1=z kaz z pisu do adres ©e

; -----------------------------------------------------------------------------
;        EDI
; -----------------------------------------------------------------------------

;EditBAK  db        25                        ; po‡et z loh souboru BAK

Edit0Vys dw        140*256                  ; relativn¡ v˜¨ka okna 1 (0 - 65535)
Edit0Sir dw        131*256                  ; relativn¡ ¨¡©ka okna 1 (0 - 65535)

TextFndN dw        0                        ; d‚lka hledan‚ho textu
TextFnd0 db        0                        ; d‚lka textu pro zobrazen¡ hl ¨en¡
TextFnd  label     byte
         db        TextFndX dup(0)          ; buffer hledan‚ho textu

TextSubN dw        0                        ; d‚lka n hradn¡ho textu
TextSub0 db        0                        ; d‚lka textu pro zobrazen¡ hl ¨en¡
TextSub  label     byte
         db        TextSubX dup(0)          ; buffer n hradn¡ho textu

EdiHledP db        0                        ; parametry pro hled n¡
                                            ;    bit 0: 1=hled n¡ zpˆt
                                            ;    bit 1: 1=nerozli¨uje velk /mal 
                                            ;    bit 2: 1=cel˜ soubor
                                            ;    bit 3: 1=ozna‡en˜ blok
                                            ;    bit 4: 1=jen cel  slova
                                            ;    bit 5: 1=v¨echny bez dotazu
                                            ;    bit 6: 1=je n hrada textu
                                            ;    bit 7: 1=otazn¡k platn˜ znak

EdiHldP2 db        0                        ; parametry pro hled n¡ 2
                                            ;    bit 0: 1=hled n¡ bylo zah jeno
                                            ;    bit 1: 1=v ©etˆzci je otazn¡k
                                            ;    bit 2: 1=zad n¡ dat v HEX tvaru
                                            ;    bit 3: 1=hled  se zna‡ka
                                            ;    bit 6: 1=v¨echny dal¨¡ bez dotazu
                                            ;    bit 7: 1=nalezen ©etˆzec

EditParm db        bit5                     ; parametry pro editor
                                            ;      bit 0: 1=datum a ‡as uchovat
                                            ;      bit 1: 1=hexadec. Ä¿00=text.
                                            ;      bit 2: 1=bin rn¡ ÄÄÙ11=autom.
                                            ;      bit 3: 1=prohl¡‘e‡
                                            ;      bit 4: 1=soubor byl vytvo©en
                                            ;      bit 5: 1=je zapnut INSERT
                                            ;      bit 6: 1=synchronizace oken
                                            ;      bit 7: 1=p©ech.soub.vytvo©en

EditPar2 db        0                        ; parametry pro editor 2
                                            ;      bit 0: 1=zobraz kurzor
                                            ;      bit 1: 1=zobraz akt. © dek
                                            ;      bit 2: 1=zobraz akt. okno
                                            ;      bit 3: 1=zobraz v¨echna okna
                                            ;      bit 4: 1=2 okna (0=1 okno)
                                            ;      bit 5: 1=vertik ln¡ (0=horiz.)
                                            ;      bit 6: 1=aktivn¡ okno 2
                                            ;      bit 7: 1=‡as se zobrazuje

EdiHlKod db        0                        ; konverzn¡ k¢d souboru pro hled n¡
                                            ;         0 = implicitn¡
                                            ;         1 = ASCII
                                            ;         2 = IBM
                                            ;         3 = Kamenick˜ch
                                            ;         4 = Latin 2
                                            ;         5 = KOI 8
                                            ;         6 = WINDOWS

EdiMdKod db        1                        ; k¢d pro modifikaci bloku
                                            ;    1 = ASCII
                                            ;    2 = IBM
                                            ;    3 = Kamenick˜ch
                                            ;    4 = Latin 2
                                            ;    5 = KOI 8
                                            ;    6 = WINDOWS

OpenEMod db        bit0+bit1+bit2           ; m¢d otev©en¡ editoru pro menu
                                            ;      bit 0: 1=datum a ‡as uchovat
                                            ;      bit 1: 1=hexadec.Ä¿00=text.
                                            ;      bit 2: 1=bin rn¡ ÄÙ11=autom.
                                            ;      bit 3: 1=prohl¡‘e‡

OldESwch db        0                        ; inicializa‡n¡ p©ep¡na‡ ze souboru
                                            ;      bit 0: 1=jen zobrazen¡ (0=edit.)
                                            ;      bit 1: 1=HEX m¢d
                                            ;      bit 2: 1=bin rn¡ m¢d
                                            ;      bit 3: 1=line l
                                            ;      bit 4: 1=tabul tor voln˜
                                            ;      bit 5: 1=vypnuta optimalizace
                                            ;      bit 6:
                                            ;      bit 7: 1=tabul tor bˆ‘n˜ znak

OldESwc2 db        0                        ; parametry souboru editoru
                                            ;      bit 0:
                                            ;      bit 1:
                                            ;      bit 2: 1=z kaz z pisu
                                            ;      bit 3:
                                            ;      bit 4:
                                            ;      bit 5:
                                            ;      bit 6: 1=sloupcov˜ blokÄ¿0=text.
                                            ;      bit 7: 1=© dkov˜ blok ÄÄÙ blok

; -----------------------------------------------------------------------------
;        FIL
; -----------------------------------------------------------------------------

EnvSize  dw        0                        ; velikost prost©ed¡ (0=standardn¡)

SelParam db        bit2                     ; parametry pro v˜bˆr polo‘ek
                                            ;   bit 0: 1=ozna‡it
                                            ;   bit 1: 1=nulovat
                                            ;   bit 2: 1=inverze
                                            ;   bit 4: 1=podadres ©e
                                            ;   bit 5: 1=ozna‡en‚
                                            ;   bit 6: 1=uchovat ozna‡en¡

; ------ parametry pro konverzi

TabPozic db        8                        ; po‡et pozic na tabul tor 1 a‘ 99

InpKod   db        0                        ; vstupn¡ k¢d souboru
                                            ;   0 = ASCII
                                            ;   1 = IBM
                                            ;   2 = Kamenick˜ch
                                            ;   3 = Latin 2
                                            ;   4 = KOI 8
                                            ;   5 = Windows

OutKod   db        6                        ; v˜stupn¡ k¢d souboru
                                            ;   0 = ASCII
                                            ;   1 = IBM
                                            ;   2 = Kamenick˜ch
                                            ;   3 = Latin 2
                                            ;   4 = KOI 8
                                            ;   5 = Windows
                                            ;   6 = nezmˆnˆn

FiltrPar db        0                        ; parametry filtru
                                            ;   bit 0: tabul tory na mezery
                                            ;   bit 1: mezery na tabul tory
                                            ;   bit 2: n hrada textu
                                            ;   bit 3: mal  p¡smena na velk 
                                            ;   bit 4: velk  p¡smena na mal 
                                            ;   bit 5: 1=zachov n datum a ‡as
                                            ;   bit 7: 1=konverze bez dotazu

; ------ parametry pro tisk

TiskPres dw        0                        ; po‡et p©esko‡en˜ch str nek
TiskPoc  dw        1                        ; po‡ te‡n¡ ‡¡slo str nky
TiskDelk dw        66                       ; d‚lka str nky s nadpisem (© dk–)
TiskLeft dw        1                        ; lev˜ okraj
TiskRght dw        80                       ; prav˜ okraj

TiskParm db        bit0+bit1                ; parametry pro tisk
                                            ;   bit 0: 1=tisk z hlav¡
                                            ;   bit 1: 1=‡ek n¡ na v˜mˆnu pap¡ru

TiskOut  dw        bit0                     ; definice v˜stupn¡ho kan lu tisku
                                            ;  bit 0: 1=PRN
                                            ;  bit 1: 1=LPT1
                                            ;  bit 2: 1=LPT2
                                            ;  bit 3: 1=LPT3
                                            ;  bit 4: 1=COM1
                                            ;  bit 5: 1=COM2
                                            ;  bit 6: 1=COM3
                                            ;  bit 7: 1=COM4
                                            ;  bit 8: 1=soubor $DOSMAN$.PRN

; ------ nulov n¡ soubor–

NulFBajt db        0                        ; nulovac¡ bajt soubor–

; ------ start programu

ProgSwc  db        bit1+bit3+bit5+bit6      ; p©ep¡na‡e voleb
                                            ;   bit 0: 1=BAT m¢d
                                            ;   bit 1: 1=Loader
                                            ;   bit 2: 1=rychl˜ m¢d (perm.)
                                            ;   bit 3: 1=COMMAND.COM
                                            ;   bit 4: 1=dˆlen˜ BAT
                                            ;   bit 5: 1=uschovat v˜bˆr
                                            ;   bit 6: 1=COM/EXE/BAT bez p©¡pon
                                            ;   bit 7: 1=p©¡kaz s $DOSMAN$.BAT

ProgSwc3 db        0                        ;   bit 1: 1=extern¡ stm¡va‡

RusParm2 db        bit1                     ; parametry pro ru¨en¡ z menu
                                            ;   bit 0: 1=prov d¡ se nulov n¡ dat
                                            ;   bit 1: 1=prov d¡ se ru¨en¡

CopyPrD2 db        bit2                     ; parametry pro kop¡rov n¡ a p©esun
                                            ;  bit 0: 1=aktualizace soubor–
                                            ;  bit 1: 1=zmˆna na kr tk  jm‚na
                                            ;  bit 2: 1=uchov vat datum a ‡as adres ©–

                                            ;  bit 5: 1=c¡l m  dlouh‚ jm‚no
                                            ;  bit 6: 1=dlouh  maska se neuplatn¡
                                            ;         (nastaveno v InitFCil)
                                            ;  bit 7: 1=c¡lov‚ jm‚no zru¨eno
                                            ;         (nastaveno v InitFCil)

; ------ porovn n¡ soubor–

CompCfg  db        bit0+bit3                ; konfigurace pro porovn v n¡ soubor–
                                            ;   bit 0: automatick‚ rozli¨en¡
                                            ;   bit 1: textov˜
                                            ;   bit 2: bin rn¡
                                            ;   bit 3: 1=‡¡slov n¡ TXT © dk–
                                            ;   bit 4: 1=zkr cen˜ v˜pis
                                            ;   bit 7: 1=v˜pis do souboru

; -----------------------------------------------------------------------------
;        HLP
; -----------------------------------------------------------------------------

HelpPar  db        bit0                     ; parametry napovˆdy
                                            ;   bit 0: 1=zapnuta mal  n povˆda
                                            ;   bit 1: 1=zobraz¡ se 12 Fn kl ves
                                            ;   bit 2: 1=n povˆda k menu nen¡
                                            ;   bit 3: 1=FN kl vesy jako menu
                                            ;   bit 4: 1=otev©eno menu n povˆdy
                                            ;   bit 5: 1=odkazy p©i exportu
                                            ;   bit 6: 1=prob¡h  export n povˆdy

; -----------------------------------------------------------------------------
;        KEY
; -----------------------------------------------------------------------------

;MouseChr dw        0                        ; uschovan˜ znak kurzoru my¨i
MousePoz dw        -1                       ; uschovan  pozice a © dek kurzoru

;ParMouse db        0                        ; parametry my¨i
;                                            ;  bit 0: 1=pou‘it¡ my¨i zak z no
;                                            ;  bit 1: 1=probˆhla instalace
;                                            ;  bit 2: 1=my¨ je nainstalov na
;                                            ;  bit 3: 1=grafick˜ m¢d my¨i
;                                            ;  bit 4: 1=p©evod sou©adnic X 16*
;                                            ;  bit 5: 1=bylo setmˆn¡ prav˜m rohem

; -----------------------------------------------------------------------------
;        FND
; -----------------------------------------------------------------------------

HledUloP db        bit0                     ; form t pro ulo‘en¡
                                            ;   bit 0: 1=seznam FND
                                            ;   bit 1: 1=jm‚na LST
                                            ;   bit 2: 1=DBF
                                            ;   bit 6: 1=aktualizace na‡¡t n¡

; -----------------------------------------------------------------------------
;        TRE
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
;        UND
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
;        WIN
; -----------------------------------------------------------------------------
;þ
NWinPthN dw        0                        ; d‚lka cesty k neaktivn¡mu oknu
NWinPath label     byte
         db        FileDMax dup(0)          ; cesta k neaktivn¡mu oknu

; ------ parametry k n vratu oken (uchovat po©ad¡ !)

AWinKOff dw        0                        ; po‡ te‡n¡ polo‘ka aktivn¡ho okna
AWinKFil label     byte
         db        FileSumm dup(0)          ; kurzor aktivn¡ho okna

NWinKOff dw        0                        ; po‡ te‡n¡ polo‘ka neaktivn¡ho okna
NWinKFil label     byte
         db        FileSumm dup(0)          ; kurzor neaktivn¡ho okna

; ------ popisova‡e oken (zachovat po©ad¡ ParamL/ParamLC ...!)

NumRows0 db        255                      ; u‘ivatelsk  v˜¨ka okna

WindPar  db        bit1                     ; aktu ln¡ parametry oken
                                            ;  bit 0: 1=aktivn¡ lev‚ okno
                                            ;  bit 1: 1=okna zapnuta (zobrazena)
                                            ;  bit 2: 1=re‘im zmˆny v˜¨ky oken
                                            ;  bit 3: 1=re‘im rychlovyhled v n¡
                                            ;  bit 4: 1=volba param. lev‚ho okna
                                            ;  bit 5:   (1=byla 1. kl vesa Ctrl-K)
                                            ;  bit 6: 1=je re‘im editace soubor–

ParamL   db        bit0 + bit1              ; parametry lev‚ho okna
                                            ;   bit 0: okno je zapnuto
                                            ;   bit 1: zobrazen adres ©
                                            ;   bit 2: zobrazen strom
                                            ;   bit 3: zobrazen seznam
                                            ;   bit 4: protˆj¨¡ okno=prohl¡‘e‡

                                            ;   bit 7: okno je aktivn¡

ParamLC  db        0                        ; parametry lev‚ho okna - konfig.
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

ParamR   db        bit0 + bit1 + bit7       ; parametry prav‚ho okna
                                            ;   bit 0: okno je zapnuto
                                            ;   bit 1: zobrazen adres ©
                                            ;   bit 2: zobrazen strom
                                            ;   bit 3: zobrazen seznam
                                            ;   bit 4: protˆj¨¡ okno=prohl¡‘e‡

                                            ;   bit 7: okno je aktivn¡

ParamRC  db        0                        ; parametry prav‚ho okna - konfig.
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

; -----------------------------------------------------------------------------
;        ZVL
; -----------------------------------------------------------------------------

; ------ ASCII tabulka

AscTbSwc db        1                        ; p©ep¡na‡ polohy ASCII tabulky
                                            ;  0 = vlevo
                                            ;  1 = uprost©ed
                                            ;  2 = vpravo

AscTbSw2 db        0                        ; parametry ASCII tabulky
                                            ;  bit 0: 1=zapnuty barvy

; -----------------------------------------------------------------------------
;        MNU
; -----------------------------------------------------------------------------
;þ
ParMenu  db        0                        ; parametry menu
                                            ;  bit 0: 1=je trval‚ hlavn¡ menu
                                            ;  bit 1: 1=zobrazeno hlavn¡ menu
                                            ;  bit 2: 1=zobrazeno nˆjak‚ menu
                                            ;  bit 3: 1=p©echodn‚ vypnut¡ oken
                                            ;  bit 4: 1=autom. vno©en¡ do menu
                                            ;  bit 5: 1=autom. vyno©en¡ z menu
                                            ;  bit 6: 1=bylo u‘ivatelsk‚ menu
                                            ;  bit 7: 1=z kaz opu¨tˆn¡ u‘iv.menu

ParMenu2 db        0                        ; parametry menu 2
                                            ;  bit 0: 1=m  se navracet u‘iv.menu
                                            ;  bit 1: 1=navr tit u‘iv. menu

ConfEnd  LABEL     BYTE                     ; konec konfigurace

Data     ENDS

         END

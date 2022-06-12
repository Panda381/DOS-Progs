; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                            data
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; þ
; ------ texty

MemTxt   db        'Nedostatek pameti !',13,10,'$'
HelpTxt  db        'Zadejte objekt k editaci:',13,10
         db        '      soubor  - editace souboru',13,10
         db        '      adresar - editace adresare',13,10
         db        '      x:      - editace logickeho disku, x=A az Z',13,10
         db        '      n:      - editace fyzickeho disku, n=0 az 3, 80 az 81',13,10
         db        '      *:      - editace operacni pameti',13,10
         db        '      **:     - editace rozsirene (EXTENDED) pameti',13,10
         db        '      @:      - editace pameti CMOS',13,10
         db        '      ?       - tato napoveda',13,10
         db        '$'
FndTxt   db        'Zadany soubor (adresar) nenalezen !',13,10,'$'

LicTxt   db        ' HEXA V1.0 - hexadecimalni editor                      (c) Miroslav Nemecek',0
SoubTxt  db        'Soubor ',0
AdrTxt   db        'Adresar ',0
LDiskTxt db        'Logicky disk ',0
FDiskTxt db        'Fyzicky disk ',0

NadLDisk db        21,'Volba logickeho disku'
NadFDisk db        21,'Volba fyzickeho disku'

NadSoub  db        23,'Volba souboru k editaci'
NadAdr   db        24,'Volba adresare k editaci'

HlpLDisk db        20,'Zvolte logicky disk.'
HlpFDisk db        20,'Zvolte fyzicky disk.'

HlpSoub  db        50,'ENTER=volba souboru k editaci nebo zmena adresare.'
HlpAdr   db        58,'ENTER=zmena adresare, CTRL-ENTER=volba adresare k editaci.'

All      db        '*.*',0
UpDir    db        '..',0                   ; specifikace nadadres ©e

FlopTxt  db        ') Floppy disk '
FlopTxt0 db        '0 '
WinTxt   db        ') Winchester 8'
WinTxt0  db        '0 '

BadTxt   db        ' <BAD>'

EofTxt   db        ' <EOF>'

TabSys   label     byte                     ; tabulka syst‚m– Partition
         db        0,'  --  '               ; 0 voln˜ popisova‡
         db        1,'DOS-12'               ;  1 DOS 12-bit FAT
         db        2,'XENIX1'               ;  2 XENIX - system
         db        3,'XENIX2'               ;  3 XENIX - data (u‘ivatelsk˜)
         db        4,'DOS-16'               ;  4 DOS 16-bit– FAT
         db        5,'EXTEND'               ;  5 DOS extended partition
         db        6,'BIGDOS'               ;  6 DOS velk˜ disk
         db        7,' QNX  '               ;  7 QNX
         db        8,' AIX1 '               ;  8 AIX system
         db        9,' AIX2 '               ;  9 AIX data
         db        51h,'  DM  '             ; 51h Disk Mana‘er
         db        52h,' CP/M '             ; 52h CP/M
         db        56h,'  GB  '             ; 56h GB
         db        61h,'SpeedS'             ; 61h Speed Stor
         db        63h,' SysV '             ; 63h SysV/386
         db        64h,'Novell'             ; 64h Novell
         db        75h,'PC/IX '             ; 75h PC/IX
         db        80h,'Minix1'             ; 80h Minix V1.3 a ni‘¨¡
         db        81h,'Minix2'             ; 81h Minix V1.5 a vy¨¨¡
         db        0dbh,' CP/M '            ; 0dbh CP/M
         db        0e1h,'SpdE12'            ; 0e1h SpeedStor 12-bit FAT EXTEND
         db        0e4h,'SpdE16'            ; 0e4h SpeedStor 16-bit FAT EXTENE
         db        0ffh,' BBT  '            ; 0ffh BBT
TabSys0  label     byte

PartTxt1 db        'ÚÄÄÄÄÄÄÂÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
         db        '³      ³   ³ pocatecni sektor ³  koncovy sektor  ³  pocatecni  ³   celkova   ³'
         db        '³SYSTEM³AKTÃÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÅÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄ´sektor oddilu³delka oddilu ³'
         db        '³      ³   ³HLAVA³VALEC³SEKTOR³HLAVA³VALEC³SEKTOR³  relativne  ³ v sektorech ³'
         db        'ÃÄÄÄÄÄÄÅÄÄÄÅÄÄÄÄÄÅÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÅÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄ´'
PartTxt2 db        'ÀÄÄÄÄÄÄÁÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'

AnoTxt   db        'Ano'
NeTxt    db        ' Ne'

TabAtr   db        'RHSVDAXY'               ; tabulka atribut–

; ------ dotaz, zda m  b˜t buffer ulo‘en

ModiMnu  label     byte
         dw        19*2+8*160               ; 0: po‡ te‡n¡ adresa okna
         db        39                       ; 2: vnit©n¡ ¨¡©ka okna
         db        9                        ; 3: v˜¨ka okna
         db        3                        ; 4: po‡et voleb
         db        1                        ; 5: aktivn¡ volba
         db        1                        ; 6: po‡et mezer mezi volbami
         db        0                        ; 7: po‡et © dk– textov˜ch parametr–
         dw        ModiMnuN                 ; 8: nadpis
         dw        ModiMnuV                 ; 10: volby
         dw        ModiMnuH                 ; 12: n povˆda

ModiMnuN db        2                        ; po‡et © dk– nadpisu
         db        23,'Data byla modifikovana.'
         db        31,'Chcete ulozit provedene zmeny ?'

ModiMnuV db        6,'Ulozit'
         db        9,'Neukladat'
         db        8,'Prerusit'

ModiMnuH db        36,'Ulozeni provedenych zmen do objektu.'
         db        38,'Provedene zmeny se neulozi do objektu.'
         db        46,'Preruseni operace, navrat k editaci (tez ESC).'

; ------ dotaz, zda m  b˜t buffer ulo‘en

Modi2Mnu label     byte
         dw        20*2+8*160               ; 0: po‡ te‡n¡ adresa okna
         db        38                       ; 2: vnit©n¡ ¨¡©ka okna
         db        9                        ; 3: v˜¨ka okna
         db        3                        ; 4: po‡et voleb
         db        1                        ; 5: aktivn¡ volba
         db        1                        ; 6: po‡et mezer mezi volbami
         db        0                        ; 7: po‡et © dk– textov˜ch parametr–
         dw        Modi2MnN                 ; 8: nadpis
         dw        Modi2MnV                 ; 10: volby
         dw        Modi2MnH                 ; 12: n povˆda

Modi2MnN db        2                        ; po‡et © dk– nadpisu
         db        23,'Data byla modifikovana.'
         db        31,'Chcete ulozit provedene zmeny ?'

Modi2MnV db        6,'Ulozit'               ; sou‡et pro volby 34
         db        8,'Navratit'
         db        8,'Prerusit'

Modi2MnH db        36,'Ulozeni provedenych zmen do objektu.'
         db        45,'Navraceni puvodniho obsahu dat, zruseni zmen.'
         db        46,'Preruseni operace, navrat k editaci (tez ESC).'

; ------ vyhled n¡ dat v objektu

HledMnu  label     byte
         dw        3*2+5*160                ; 0: po‡ te‡n¡ adresa okna
         db        71                       ; 2: vnit©n¡ ¨¡©ka okna
         db        16                       ; 3: v˜¨ka okna
         db        7                        ; 4: celkov˜ po‡et voleb
         db        1                        ; 5: aktivn¡ volba
         db        16                       ; 6: po‡et mezer mezi volbami
         db        5                        ; 7: po‡et voleb textov˜ch parametr–
         dw        HledMnuN                 ; 8: nadpis
         dw        HledMnuV                 ; 10: volby
         dw        HledMnuH                 ; 12: n povˆda
         dw        HledMnuT                 ; 14: texty voleb

HledMnuN db        1                        ; po‡et © dk– nadpisu
         db        33,'Zadejte data k vyhledani/nahrade:'

HledMnuV db        6,'Hledat'               ; sou‡et pro volby 22
         db        8,'Prerusit'

HledMnuH db        72,'Zadejte data k vyhledani ve tvaru ASCII (Ctrl-U = znak se nekontroluje).'
         db        70,'Zadejte data k vyhledani ve tvaru HEX (Ctrl-U = znak se nekontroluje).'
         db        67,'Zadejte data k nahrade ve tvaru ASCII (Ctrl-U = znak se nenahradi).'
         db        65,'Zadejte data k nahrade ve tvaru HEX (Ctrl-U = znak se nenahradi).'
         db        79,'Parametry: B=zpet, L=blok, G=vse, U=velka/mala, N=bez dotazu, W=zapis, n=pocet.'
         db        33,'Zahajeni vyhledavani/nahrady dat.'
         db        46,'Preruseni operace, navrat k editaci (tez ESC).'

HledMnuT label     byte
         db        bit1                     ; 0: parametry - bˆ‘n˜ text
                                            ;     bit 6: 1=lich˜ znak HEX
                                            ;     bit 7: 1=zah jena editace
         db        20                       ; 1: max. po‡et znak–
         dw        HledNum                  ; 2: ukazatel d‚lky textu
         dw        HledAkt                  ; 4: ukazatel kurzoru
         dw        HledDat                  ; 6: zad van˜ text
         dw        HledMask                 ; 8: maska textu
         db        12,'    Hledat: '        ; 10: £vodn¡ text

         db        bit2                     ; parametry - HEX text
                                            ;     bit 6: 1=lich˜ znak HEX
                                            ;     bit 7: 1=zah jena editace
         db        20                       ; max. po‡et znak–
         dw        HledNum                  ; ukazatel d‚lky textu
         dw        HledAkt                  ; ukazatel kurzoru
         dw        HledDat                  ; zad van˜ text
         dw        HledMask                 ; maska textu
         db        12,'            '

         db        bit0                     ; pr zdn˜ © dek

         db        bit1                     ; parametry - bˆ‘n˜ text
                                            ;     bit 6: 1=lich˜ znak HEX
                                            ;     bit 7: 1=zah jena editace
         db        20                       ; max. po‡et znak–
         dw        HledNum                  ; ukazatel d‚lky textu
         dw        HledAkt                  ; ukazatel kurzoru
         dw        NahrDat                  ; zad van˜ text - n hrada dat
         dw        NahrMask                 ; maska zad van‚ho textu
         db        12,'  Nahradit: '

         db        bit2                     ; parametry - HEX text
                                            ;     bit 6: 1=lich˜ znak HEX
                                            ;     bit 7: 1=zah jena editace
         db        20                       ; max. po‡et znak–
         dw        HledNum                  ; ukazatel d‚lky textu
         dw        HledAkt                  ; ukazatel kurzoru
         dw        NahrDat                  ; zad van˜ text - n hrada dat
         dw        NahrMask                 ; maska zad van‚ho textu
         db        12,'            '

         db        bit0                     ; pr zdn˜ © dek

HledMnTP db        bit1                     ; parametry - bˆ‘n˜ text
                                            ;     bit 6: 1=lich˜ znak HEX
                                            ;     bit 7: 1=zah jena editace
         db        20                       ; max. po‡et znak–
         dw        HledPNum                 ; ukazatel d‚lky textu
         dw        HledPAkt                 ; ukazatel kurzoru
         dw        HledPTxt                 ; zadan˜ text - parametry
         dw        0                        ; maska textu - nen¡
         db        12,' Parametry: '

         db        bit0                     ; pr zdn˜ © dek

         db        0                        ; konec


HledNum  dw        0                        ; d‚lka ©etˆzce k hled n¡/nahrazen¡
HledAkt  dw        0                        ; aktivn¡ polo‘ka textu

HledDat  db        21 dup(0)                ; data k vyhled n¡
HledMask db        21 dup(0)                ; maska dat k vyhled n¡

NahrDat  db        21 dup(0)                ; data k nahrazen¡
NahrMask db        21 dup(0)                ; maska dat k nahrazen¡

HledABeg dd        0                        ; ukazatel za‡ tku k hled n¡
HledAEnd dd        0                        ; ukazatel konce k hled n¡

HledPNum dw        0                        ; d‚lka ©etˆzce parametr–
HledPAkt dw        0                        ; aktivn¡ kurzor
HledPTxt db        21 dup(0)                ; zadan‚ parametry pro hled n¡
HledPCit dw        0                        ; ‡¡ta‡ v˜skytu pro hled n¡
HledPCN  dw        0                        ; zadan˜ ‡¡ta‡ v˜skytu pro hled n¡
HledPar  db        0                        ; parametry pro hled n¡
                                            ;   bit 0: 1=hled n¡ zpˆt (B)
                                            ;   bit 1: 1=v cel‚m bloku (L)
                                            ;   bit 2: 1=v cel‚m objektu (G)
                                            ;   bit 3: 1=ignor. velk /mal  (U)
                                            ;   bit 4: 1=n hrada bez dotazu (N)
                                            ;   bit 5: 1=z pis bez dotazu (W)
                                            ;   bit 6: 1=byl nalezen ©etˆzec
                                            ;   bit 7: 1=je n hrada dat

; ------ hl ¨en¡ - zadan˜ text nenalezen

NoFndMnu label     byte
         dw        25*2+8*160               ; 0: po‡ te‡n¡ adresa okna
         db        28                       ; 2: vnit©n¡ ¨¡©ka okna
         db        8                        ; 3: v˜¨ka okna
         db        1                        ; 4: po‡et voleb
         db        1                        ; 5: aktivn¡ volba
         db        11                       ; 6: po‡et mezer mezi volbami
         db        0                        ; 7: po‡et © dk– textov˜ch parametr–
         dw        NoFndMnN                 ; 8: nadpis
         dw        NoFndMnV                 ; 10: volby
         dw        NoFndMnH                 ; 12: n povˆda

NoFndMnN db        1                        ; po‡et © dk– nadpisu
         db        24,'Zadana data nenalezena !'

NoFndMnV db        2,'OK'                   ; sou‡et pro volby 6

NoFndMnH db        41,'Ukonceni hlaseni klavesou ESC nebo ENTER.'

; ------ tabulka pro porovn n¡ znak– za‡ tku slova

TabWrdCh label     byte                     ; tabulka pro porovn n¡ znak– slova
         db        1,31 dup(2),1            ; 0 a‘ 32
         db        2,2,3,3,2,2,2,2,2,2,2,2,2,2,2 ; !"#$%&'()*+,-./
         db        10 dup(3)                ; ‡¡slice
         db        2,2,2,2,2,2              ; :;<=>?
         db        27 dup(3)                ; @ velk  p¡smena
         db        2,2,2,2,2,2              ; [\]^_`
         db        26 dup(3)                ; mal  p¡smena
         db        2,2,2,2,2                ; {|}~
         db        96 dup(3)                ; p¡smena 128 a v˜¨e
         db        32 dup(2)                ; speci ln¡ znaky 240 a v˜¨e

; ------ tabulka d‚lek instrukc¡

DelkIns  db        9,9,9,9,2,3,1,1, 9,9,9,9,2,3,1,1   ; 00h - 0fh
         db        9,9,9,9,2,3,1,1, 9,9,9,9,2,3,1,1   ; 10h - 1fh
         db        9,9,9,9,2,3,1,1, 9,9,9,9,2,3,1,1   ; 20h - 2fh
         db        9,9,9,9,2,3,1,1, 9,9,9,9,2,3,1,1   ; 30h - 3fh
         db        1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1   ; 40h - 4fh
         db        1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1   ; 50h - 5fh
         db        1,1,1,1,1,1,1,1, 3,2,3,2,1,1,1,1   ; 60h - 6fh
         db        2,2,2,2,2,2,2,2, 2,2,2,2,2,2,2,2   ; 70h - 7fh
         db        10,11,10,10,9,9,9,9, 9,9,9,9,9,9,9,9   ; 80h - 8fh
         db        1,1,1,1,1,1,1,1, 1,1,5,1,1,1,1,1   ; 90h - 9fh
         db        3,3,3,3,1,1,1,1, 2,3,1,1,1,1,1,1   ; 0a0h - 0afh
         db        2,2,2,2,2,2,2,2, 3,3,3,3,3,3,3,3   ; 0b0h - 0bfh
         db        2,2,3,1,3,3,4,5, 4,1,3,1,1,2,1,1   ; 0c0h - 0cfh
         db        9,9,9,9,2,2,1,1, 1,1,1,1,1,1,1,1   ; 0d0h - 0dfh
         db        2,2,2,2,2,2,2,2, 3,3,5,2,1,1,1,1   ; 0e0h - 0efh
         db        1,1,1,1,1,1,1,1, 1,1,1,1,1,1,2,2   ; 0f0h - 0ffh

; ------ tabulka instrukc¡

TabInst  db        KODN3+5,1                ; 00h
         db        KODN3+5,2                ; 01h
         db        KODN3+5,3                ; 02h
         db        KODN3+5,4                ; 03h

         db        KODN3+5,5                ; 04h
         db        KODN3+5,6                ; 05h
         db        KODN4+25,7               ; 06h
         db        KODN3+50,7               ; 07h

         db        KODN2+12,1               ; 08h
         db        KODN2+12,2               ; 09h
         db        KODN2+12,3               ; 0ah
         db        KODN2+12,4               ; 0bh

         db        KODN2+12,5               ; 0ch
         db        KODN2+12,6               ; 0dh
         db        KODN4+25,7               ; 0eh
         db        KODN1+0,7                ; 0fh

; ------ 10h

         db        KODN3+4,1                ; 10h
         db        KODN3+4,2                ; 11h
         db        KODN3+4,3                ; 12h
         db        KODN3+4,4                ; 13h

         db        KODN3+4,5                ; 14h
         db        KODN3+4,6                ; 15h
         db        KODN4+25,7               ; 16h
         db        KODN3+50,7               ; 17h

         db        KODN3+59,1               ; 18h
         db        KODN3+59,2               ; 19h
         db        KODN3+59,3               ; 1ah
         db        KODN3+59,4               ; 1bh

         db        KODN3+59,5               ; 1ch
         db        KODN3+59,6               ; 1dh
         db        KODN4+25,7               ; 1eh
         db        KODN3+50,7               ; 1fh

; ------ 20h

         db        KODN3+6,1                ; 20h
         db        KODN3+6,2                ; 21h
         db        KODN3+6,3                ; 22h
         db        KODN3+6,4                ; 23h

         db        KODN3+6,5                ; 24h
         db        KODN3+6,6                ; 25h
         db        KODN3+60,7               ; 26h
         db        KODN3+15,0               ; 27h

         db        KODN3+67,1               ; 28h
         db        KODN3+67,2               ; 29h
         db        KODN3+67,3               ; 2ah
         db        KODN3+67,4               ; 2bh

         db        KODN3+67,5               ; 2ch
         db        KODN3+67,6               ; 2dh
         db        KODN3+60,7               ; 2eh
         db        KODN3+16,0               ; 2fh

; ------ 30h

         db        KODN3+68,1               ; 30h
         db        KODN3+68,2               ; 31h
         db        KODN3+68,3               ; 32h
         db        KODN3+68,4               ; 33h

         db        KODN3+68,5               ; 34h
         db        KODN3+68,6               ; 35h
         db        KODN3+60,7               ; 36h
         db        KODN3+0,0                ; 37h

         db        KODN3+12,1               ; 38h
         db        KODN3+12,2               ; 39h
         db        KODN3+12,3               ; 3ah
         db        KODN3+12,4               ; 3bh

         db        KODN3+12,5               ; 3ch
         db        KODN3+12,6               ; 3dh
         db        KODN3+60,7               ; 3eh
         db        KODN3+3,0                ; 3fh

; ------ 40h

         db        KODN3+21,8               ; 40h
         db        KODN3+21,8               ; 41h
         db        KODN3+21,8               ; 42h
         db        KODN3+21,8               ; 43h

         db        KODN3+21,8               ; 44h
         db        KODN3+21,8               ; 45h
         db        KODN3+21,8               ; 46h
         db        KODN3+21,8               ; 47h

         db        KODN3+17,8               ; 48h
         db        KODN3+17,8               ; 49h
         db        KODN3+17,8               ; 4ah
         db        KODN3+17,8               ; 4bh

         db        KODN3+17,8               ; 4ch
         db        KODN3+17,8               ; 4dh
         db        KODN3+17,8               ; 4eh
         db        KODN3+17,8               ; 4fh

; ------ 50h

         db        KODN3+50,8               ; 50h
         db        KODN3+50,8               ; 51h
         db        KODN3+50,8               ; 52h
         db        KODN3+50,8               ; 53h

         db        KODN3+50,8               ; 54h
         db        KODN3+50,8               ; 55h
         db        KODN3+50,8               ; 56h
         db        KODN3+50,8               ; 57h

         db        KODN4+25,8               ; 58h
         db        KODN4+25,8               ; 59h
         db        KODN4+25,8               ; 5ah
         db        KODN4+25,8               ; 5bh

         db        KODN4+25,8               ; 5ch
         db        KODN4+25,8               ; 5dh
         db        KODN4+25,8               ; 5eh
         db        KODN4+25,8               ; 5fh

; ------ 60h

         db        KODN5+15,0               ; 60h
         db        KODN4+23,0               ; 61h
         db        KODN5+0,0                ; 62h
         db        KODN4+0,0                ; 63h

         db        KODN3+60,0               ; 64h
         db        KODN3+60,0               ; 65h
         db        KODN1+0,0                ; 66h
         db        KODN1+0,0                ; 67h

         db        KODN4+25,0               ; 68h
         db        KODN4+4,0                ; 69h
         db        KODN4+25,0               ; 6ah
         db        KODN4+4,0                ; 6bh

         db        KODN4+5,0                ; 6ch
         db        KODN4+6,0                ; 6dh
         db        KODN5+13,0               ; 6eh
         db        KODN5+14,0               ; 6fh

; ------ 70h

         db        KODN2+8,9                ; 70h
         db        KODN3+34,9               ; 71h
         db        KODN2+4,9                ; 72h
         db        KODN3+30,9               ; 73h

         db        KODN2+11,9               ; 74h
         db        KODN3+37,9               ; 75h
         db        KODN3+24,9               ; 76h
         db        KODN2+2,9                ; 77h

         db        KODN2+10,9               ; 78h
         db        KODN3+36,9               ; 79h
         db        KODN2+9,9                ; 7ah
         db        KODN3+35,9               ; 7bh

         db        KODN2+7,9                ; 7ch
         db        KODN3+25,9               ; 7dh
         db        KODN3+26,9               ; 7eh
         db        KODN2+6,9                ; 7fh

; ------ 80h

         db        0f0h,17                  ; 80h
         db        0f0h,18                  ; 81h
         db        0f0h,19                  ; 82h
         db        0f0h,20                  ; 83h

         db        KODN4+33,1               ; 84h
         db        KODN4+33,2               ; 85h
         db        KODN4+35,3               ; 86h
         db        KODN4+35,4               ; 87h

         db        KODN3+44,1               ; 88h
         db        KODN3+44,2               ; 89h
         db        KODN3+44,3               ; 8ah
         db        KODN3+44,4               ; 8bh

         db        KODN3+44,34              ; 8ch
         db        KODN3+42,4               ; 8dh
         db        KODN3+44,35              ; 8eh
         db        KODN3+50,0               ; 8fh

; ------ 90h

         db        KODN3+47,0               ; 90h
         db        KODN4+35,11              ; 91h
         db        KODN4+35,11              ; 92h
         db        KODN4+35,11              ; 93h

         db        KODN4+35,11              ; 94h
         db        KODN4+35,11              ; 95h
         db        KODN4+35,11              ; 96h
         db        KODN4+35,11              ; 97h

         db        KODN3+7,0                ; 98h
         db        KODN3+14,0               ; 99h
         db        KODN4+1,33               ; 9ah
         db        KODN4+34,0               ; 9bh

         db        KODN5+16,0               ; 9ch
         db        KODN4+24,0               ; 9dh
         db        KODN4+29,0               ; 9eh
         db        KODN4+16,0               ; 9fh

; ------ 0a0h

         db        KODN3+44,27              ; 0a0h
         db        KODN3+44,27              ; 0a1h
         db        KODN3+44,28              ; 0a2h
         db        KODN3+44,28              ; 0a3h

         db        KODN5+11,0               ; 0a4h
         db        KODN5+12,0               ; 0a5h
         db        KODN5+2,0                ; 0a6h
         db        KODN5+3,0                ; 0a7h

         db        KODN4+33,27              ; 0a8h
         db        KODN4+33,27              ; 0a9h
         db        KODN5+21,0               ; 0aah
         db        KODN5+22,0               ; 0abh

         db        KODN5+7,0                ; 0ach
         db        KODN5+8,0                ; 0adh
         db        KODN5+19,0               ; 0aeh
         db        KODN5+20,0               ; 0afh

; ------ 0b0h

         db        KODN3+44,12              ; 0b0h
         db        KODN3+44,12              ; 0b1h
         db        KODN3+44,12              ; 0b2h
         db        KODN3+44,12              ; 0b3h

         db        KODN3+44,12              ; 0b4h
         db        KODN3+44,12              ; 0b5h
         db        KODN3+44,12              ; 0b6h
         db        KODN3+44,12              ; 0b7h

         db        KODN3+44,13              ; 0b8h
         db        KODN3+44,13              ; 0b9h
         db        KODN3+44,13              ; 0bah
         db        KODN3+44,13              ; 0bbh

         db        KODN3+44,13              ; 0bch
         db        KODN3+44,13              ; 0bdh
         db        KODN3+44,13              ; 0beh
         db        KODN3+44,13              ; 0bfh

; ------ 0c0h

         db        0f1h,25                  ; 0c0h
         db        0f1h,26                  ; 0c1h
         db        KODN3+54,15              ; 0c2h
         db        KODN3+54,0               ; 0c3h

         db        KODN3+43,0               ; 0c4h
         db        KODN3+41,0               ; 0c5h
         db        KODN3+44,0               ; 0c6h
         db        KODN3+44,0               ; 0c7h

         db        KODN5+4,0                ; 0c8h
         db        KODN5+6,0                ; 0c9h
         db        KODN4+28,15              ; 0cah
         db        KODN4+28,0               ; 0cbh

         db        KODN4+7,0                ; 0cch
         db        KODN3+22,14              ; 0cdh
         db        KODN4+8,0                ; 0ceh
         db        KODN4+9,0                ; 0cfh

; ------ 0d0h

         db        0f1h,21                  ; 0d0h
         db        0f1h,22                  ; 0d1h
         db        0f1h,23                  ; 0d2h
         db        0f1h,24                  ; 0d3h

         db        KODN3+43,14              ; 0d4h
         db        KODN3+41,14              ; 0d5h
         db        KODN2+0,14               ; 0d6h
         db        KODN4+36,0               ; 0d7h

         db        KODN3+4,16               ; 0d8h
         db        KODN3+6,16               ; 0d9h
         db        KODN3+19,16              ; 0dah
         db        KODN3+19,16              ; 0dbh

         db        KODN3+19,16              ; 0dch
         db        KODN3+19,16              ; 0ddh
         db        KODN3+19,16              ; 0deh
         db        KODN3+19,16              ; 0dfh

; ------ 0e0h

         db        KODN6+1,9                ; 0e0h
         db        KODN5+10,9               ; 0e1h
         db        KODN4+22,9               ; 0e2h
         db        KODN4+10,9               ; 0e3h

         db        KODN2+1,29               ; 0e4h
         db        KODN2+1,29               ; 0e5h
         db        KODN3+49,30              ; 0e6h
         db        KODN3+49,30              ; 0e7h

         db        KODN4+1,10               ; 0e8h
         db        KODN3+27,10              ; 0e9h
         db        KODN3+27,33              ; 0eah
         db        KODN3+27,9               ; 0ebh

         db        KODN2+1,31               ; 0ech
         db        KODN2+1,31               ; 0edh
         db        KODN3+49,32              ; 0eeh
         db        KODN3+49,32              ; 0efh

; ------ 0f0h

         db        KODN4+21,0               ; 0f0h
         db        KODN2+0,14               ; 0f1h
         db        KODN5+18,0               ; 0f2h
         db        KODN4+27,0               ; 0f3h

         db        KODN4+2,0                ; 0f4h
         db        KODN3+11,0               ; 0f5h
         db        KODN1+0,0                ; 0f6h
         db        KODN1+0,0                ; 0f7h

         db        KODN3+8,0                ; 0f8h
         db        KODN3+63,0               ; 0f9h
         db        KODN3+10,0               ; 0fah
         db        KODN3+65,0               ; 0fbh

         db        KODN3+9,0                ; 0fch
         db        KODN3+64,0               ; 0fdh
         db        KODN1+0,0                ; 0feh
         db        KODN1+0,0                ; 0ffh

; ------ tabulka instrukc¡ - skupina 1 (aritmetick‚ operace)

TabInst1 db        KODN3+5                  ; 0: ADD
         db        KODN2+12                 ; 1: OR
         db        KODN3+4                  ; 2: ADC
         db        KODN3+59                 ; 3: SBB
         db        KODN3+6                  ; 4: AND
         db        KODN3+67                 ; 5: SUB
         db        KODN3+68                 ; 6: XOR
         db        KODN3+12                 ; 7: CMP

; ------ tabulka instrukc¡ - skupina 2 (rotace)

TabInst2 db        KODN3+55                 ; 0: ROL
         db        KODN3+56                 ; 1: ROR
         db        KODN3+51                 ; 2: RCL
         db        KODN3+52                 ; 3: RCR
         db        KODN3+61                 ; 4: SHL
         db        KODN3+62                 ; 5: SHR
         db        KODN3+57                 ; 6: SAL
         db        KODN3+58                 ; 7: SAR

; ------ tabulka registr– BAJT

TabReg1  db        'al'                     ; 0
         db        'cl'                     ; 1
         db        'dl'                     ; 2
         db        'bl'                     ; 3
         db        'ah'                     ; 4
         db        'ch'                     ; 5
         db        'dh'                     ; 6
         db        'bh'                     ; 7

; ------ tabulka registr– WORD

TabReg2  db        'ax'                     ; 0
         db        'cx'                     ; 1
         db        'dx'                     ; 2
         db        'bx'                     ; 3
         db        'sp'                     ; 4
         db        'bp'                     ; 5
         db        'si'                     ; 6
         db        'di'                     ; 7

; ------ tabulka registr– - indexy

TabReg3  db        'bx'                     ; 0
         db        'bp'                     ; 1
         db        'si'                     ; 2
         db        'di'                     ; 3

; ------ tabulka registr– - segmenty

TabReg4  db        'es'                     ; 0
         db        'cs'                     ; 1
         db        'ss'                     ; 2
         db        'ds'                     ; 3
         db        'fs'                     ; 4
         db        'gs'                     ; 5
         db        '??'                     ; 6
         db        '??'                     ; 7

; ------ tabulka index– a b z¡

TabReg5  db        5,'bx+si'
         db        5,'bx+di'
         db        5,'bp+si'
         db        5,'bp+di'
         db        2,'si   '
         db        2,'di   '
         db        2,'bp   '
         db        2,'bx   '

; ------ tabulka PTR

TabPtr   db        4,'byte '                ; 0
         db        4,'word '                ; 1
         db        5,'dword'                ; 2
         db        5,'short'                ; 3
         db        4,'near '                ; 4
         db        3,'far  '                ; 5

; ------ tabulka text– instrukc¡

TextInst db        1,KODN2-KODN1
         db        ' '                      ; KODN1+0

         db        2,KODN3-KODN2
         db        'db'                     ; KODN2+0
         db        'in'                     ; KODN2+1
         db        'ja'                     ; KODN2+2
         db        'jb'                     ; KODN2+3
         db        'jc'                     ; KODN2+4
         db        'je'                     ; KODN2+5
         db        'jg'                     ; KODN2+6
         db        'jl'                     ; KODN2+7
         db        'jo'                     ; KODN2+8
         db        'jp'                     ; KODN2+9
         db        'js'                     ; KODN2+10
         db        'jz'                     ; KODN2+11
         db        'or'                     ; KODN2+12

         db        3,KODN4-KODN3
         db        'aaa'                    ; KODN3+0
         db        'aad'                    ; KODN3+1
         db        'aam'                    ; KODN3+2
         db        'aas'                    ; KODN3+3
         db        'adc'                    ; KODN3+4
         db        'add'                    ; KODN3+5
         db        'and'                    ; KODN3+6
         db        'cbw'                    ; KODN3+7
         db        'clc'                    ; KODN3+8
         db        'cld'                    ; KODN3+9
         db        'cli'                    ; KODN3+10
         db        'cmc'                    ; KODN3+11
         db        'cmp'                    ; KODN3+12
         db        'cts'                    ; KODN3+13
         db        'cwd'                    ; KODN3+14
         db        'daa'                    ; KODN3+15
         db        'das'                    ; KODN3+16
         db        'dec'                    ; KODN3+17
         db        'div'                    ; KODN3+18
         db        'esc'                    ; KODN3+19
         db        'hlt'                    ; KODN3+20
         db        'inc'                    ; KODN3+21
         db        'int'                    ; KODN3+22
         db        'jae'                    ; KODN3+23
         db        'jbe'                    ; KODN3+24
         db        'jge'                    ; KODN3+25
         db        'jle'                    ; KODN3+26
         db        'jmp'                    ; KODN3+27
         db        'jna'                    ; KODN3+28
         db        'jnb'                    ; KODN3+29
         db        'jnc'                    ; KODN3+30
         db        'jne'                    ; KODN3+31
         db        'jng'                    ; KODN3+32
         db        'jnl'                    ; KODN3+33
         db        'jno'                    ; KODN3+34
         db        'jnp'                    ; KODN3+35
         db        'jns'                    ; KODN3+36
         db        'jnz'                    ; KODN3+37
         db        'jpe'                    ; KODN3+38
         db        'jpo'                    ; KODN3+39
         db        'lar'                    ; KODN3+40
         db        'lds'                    ; KODN3+41
         db        'lea'                    ; KODN3+42
         db        'les'                    ; KODN3+43
         db        'mov'                    ; KODN3+44
         db        'mul'                    ; KODN3+45
         db        'neg'                    ; KODN3+46
         db        'nop'                    ; KODN3+47
         db        'not'                    ; KODN3+48
         db        'out'                    ; KODN3+49
         db        'pop'                    ; KODN3+50
         db        'rcl'                    ; KODN3+51
         db        'rcr'                    ; KODN3+52
         db        'rep'                    ; KODN3+53
         db        'ret'                    ; KODN3+54
         db        'rol'                    ; KODN3+55
         db        'ror'                    ; KODN3+56
         db        'sal'                    ; KODN3+57
         db        'sar'                    ; KODN3+58
         db        'sbb'                    ; KODN3+59
         db        'seg'                    ; KODN3+60
         db        'shl'                    ; KODN3+61
         db        'shr'                    ; KODN3+62
         db        'stc'                    ; KODN3+63
         db        'std'                    ; KODN3+64
         db        'sti'                    ; KODN3+65
         db        'str'                    ; KODN3+66
         db        'sub'                    ; KODN3+67
         db        'xor'                    ; KODN3+68

         db        4,KODN5-KODN4
         db        'arpl'                   ; KODN4+0
         db        'call'                   ; KODN4+1
         db        'halt'                   ; KODN4+2
         db        'idiv'                   ; KODN4+3
         db        'imul'                   ; KODN4+4
         db        'insb'                   ; KODN4+5
         db        'insw'                   ; KODN4+6
         db        'int3'                   ; KODN4+7
         db        'into'                   ; KODN4+8
         db        'iret'                   ; KODN4+9
         db        'jcxz'                   ; KODN4+10
         db        'jmpf'                   ; KODN4+11
         db        'jnae'                   ; KODN4+12
         db        'jnbe'                   ; KODN4+13
         db        'jnge'                   ; KODN4+14
         db        'jnle'                   ; KODN4+15
         db        'lahf'                   ; KODN4+16
         db        'lgdt'                   ; KODN4+17
         db        'lidt'                   ; KODN4+18
         db        'lldt'                   ; KODN4+19
         db        'lmsw'                   ; KODN4+20
         db        'lock'                   ; KODN4+21
         db        'loop'                   ; KODN4+22
         db        'popa'                   ; KODN4+23
         db        'popf'                   ; KODN4+24
         db        'push'                   ; KODN4+25
         db        'repe'                   ; KODN4+26
         db        'repz'                   ; KODN4+27
         db        'retf'                   ; KODN4+28
         db        'sahf'                   ; KODN4+29
         db        'sgdt'                   ; KODN4+30
         db        'sldt'                   ; KODN4+31
         db        'smsw'                   ; KODN4+32
         db        'test'                   ; KODN4+33
         db        'wait'                   ; KODN4+34
         db        'xchg'                   ; KODN4+35
         db        'xlat'                   ; KODN4+36

         db        5,KODN6-KODN5
         db        'bound'                  ; KODN5+0
         db        'callf'                  ; KODN5+1
         db        'cmpsb'                  ; KODN5+2
         db        'cmpsw'                  ; KODN5+3
         db        'enter'                  ; KODN5+4
         db        'fwait'                  ; KODN5+5
         db        'leave'                  ; KODN5+6
         db        'lodsb'                  ; KODN5+7
         db        'lodsw'                  ; KODN5+8
         db        'loope'                  ; KODN5+9
         db        'loopz'                  ; KODN5+10
         db        'movsb'                  ; KODN5+11
         db        'movsw'                  ; KODN5+12
         db        'outsb'                  ; KODN5+13
         db        'outsw'                  ; KODN5+14
         db        'pusha'                  ; KODN5+15
         db        'pushf'                  ; KODN5+16
         db        'repne'                  ; KODN5+17
         db        'repnz'                  ; KODN5+18
         db        'scasb'                  ; KODN5+19
         db        'scasw'                  ; KODN5+20
         db        'stosb'                  ; KODN5+21
         db        'stosw'                  ; KODN5+22

         db        6,KODN7-KODN6
         db        'loopne'                 ; KODN6+0
         db        'loopnz'                 ; KODN6+1

         db        0,0

; ------ definice z kladn¡ho menu

DefM0    label     byte
         db        1                        ; aktivn¡ polo‘ka
         db        9                        ; po‡et polo‘ek
         db        21                       ; d‚lka kurzoru

         db        23,'Volba objektu k editaci' ; nadpis menu

         db        1,6,'Soubor'             ; hork˜ znak, d‚lka textu, text
         db        21,'Bude editovan soubor.' ; n povˆda, text

         db        1,7,'Adresar'
         db        42,'Bude editovan adresar logickeho disku DOS.'

         db        1,11,'Tabulka FAT'
         db        64,'Bude editovana tabulka FAT alokacnich bloku logickeho disku DOS.'

         db        1,4,'Disk'
         db        31,'Bude editovan logicky disk DOS.'

         db        1,12,'Fyzicky disk'
         db        57,'Bude editovan fyzicky disk BIOS (FLOPPY nebo WINCHESTER).'

         db        1,5,'Pamet'
         db        48,'Bude editovana zakladni operacni pamet pocitace.'

         db        1,8,'Extended'
         db        51,'Bude editovana rozsirena (EXTENDED) pamet pocitace.'

         db        1,4,'CMOS'
         db        49,'Bude editovana pamet CMOS (konfigurace pocitace).'

         db        1,19,'Konec programu HEXA'
         db        50,'Konec programu HEXA, navrat do operacniho systemu.'

; ------ n povˆda k funk‡n¡m kl ves m

TxtFHlp  label     byte
                                          ;* z kladn¡ n povˆda
         db        'Pomoc  '                ; F1 n povˆda
         db        'Uloz   '                ; F2 ulo‘en¡ zmˆn
         db        'Zacat.B'                ; F3 za‡ tek bloku
         db        'Konec B'                ; F4 konec bloku
         db        'Cti   B'                ; F5 ‡ten¡ bloku ze souboru
         db        'Uloz  B'                ; F6 ulo‘en¡ bloku do souboru
         db        'Hledej '                ; F7 hled n¡ dat
         db        'Nuluj B'                ; F8 nulov n¡ - z pis konstanty
         db        'Skok na'                ; F9 skok na danou adresu
         db        'Konec  '                ; F10 konec programu HEXA

                                          ;* n povˆda se Shift-
         db        '       '                ; Shift-F1
         db        '       '                ; Shift-F2
         db        '       '                ; Shift-F3
         db        '       '                ; Shift-F4
         db        '       '                ; Shift-F5
         db        '       '                ; Shift-F6
         db        '       '                ; Shift-F7
         db        '       '                ; Shift-F8
         db        '       '                ; Shift-F9
         db        '       '                ; Shift-F10

                                          ;* n povˆda s Ctrl-
         db        '       '                ; Ctrl-F1
         db        '       '                ; Ctrl-F2
         db        '       '                ; Ctrl-F3
         db        '       '                ; Ctrl-F4
         db        '       '                ; Ctrl-F5
         db        '       '                ; Ctrl-F6
         db        '       '                ; Ctrl-F7
         db        '       '                ; Ctrl-F8
         db        '       '                ; Ctrl-F9
         db        '       '                ; Ctrl-F10

                                          ;* n povˆsa s ALT
         db        'Hex    '                ; Alt-F1 form t zobrazen¡ HEX
         db        'Binar  '                ; Alt-F2 form t zobrazen¡ Binar
         db        'Byte   '                ; Alt-F3 form t zobrazen¡ ‡¡sla BYTE
         db        'Word   '                ; Alt-F4 form t zobrazen¡ ‡¡sla WORD
         db        'Text   '                ; Alt-F5 form t zobrazen¡ textu
         db        'Adresar'                ; Alt-F6 form t zobrazen¡ adres ©e
         db        'FAT    '                ; Alt-F7 form t zobrazen¡ FAT
         db        'Partit.'                ; Alt-F8 form t zobrazen¡ PARTITION
         db        'Assemb.'                ; Alt-F9 form t zobrazen¡ assembleru
         db        '       '
         ;db        'CMOS   '                ; Alt-F10 form t zobrazen¡ CMOS

; ------ barvy

ColTab   label     byte

ColDat   db        30h                      ; barva data a ‡asu
ColRam   db        1fh                      ; barva r mu a podkladu
ColInf   db        1bh                      ; barva textu informa‡n¡ho © dku
ColNadp  db        70h                      ; barva nadpisu menu
ColHlp   db        1bh                      ; barva textu n povˆdy
ColMenu1 db        1fh                      ; bˆ‘n  barva polo‘ky menu
ColMenu2 db        1eh                      ; barva vysv¡cen‚ho znaku polo‘ky
ColMenu3 db        30h                      ; kurzor polo‘ky menu
ColFn1   db        0fh                      ; barva ‡¡sla funk‡n¡ kl vesy
ColFn2   db        30h                      ; barva textu funk‡n¡ kl vesy

ColEd1   db        1fh                      ; bˆ‘n  barva editovan˜ch polo‘ek
ColEd2   db        1eh                      ; vysv¡cen  barva editov. polo‘ek
ColEd3   db        4fh                      ; kurzor - bˆ‘n  barva
ColEd4   db        4eh                      ; kurzor - vysv¡cen  barva
ColEd5   db        30h                      ; barva ozna‡en‚ho bloku dat
ColEd6   db        3eh                      ; barva zv˜raznˆn‚ho bloku dat

ColMnuH  db        30h                      ; barva n povˆdy voleb
ColMnu1  db        70h                      ; bˆ‘n  barva volby
ColMnu2  db        30h                      ; bˆ‘n  barva kurzoru
ColMnu3  db        74h                      ; vysv¡cen  barva volby
ColMnu4  db        34h                      ; vysv¡cen  barva kurzoru

ColTab0  label     byte

; ------ barvy - monochromn¡ re‘im

ColMono  label     byte

         db        70h                      ; barva data a ‡asu
         db        0fh                      ; barva r mu a podkladu
         db        07h                      ; barva textu informa‡n¡ho © dku
         db        70h                      ; barva nadpisu menu
         db        07h                      ; barva textu n povˆdy
         db        07h                      ; bˆ‘n  barva polo‘ky menu
         db        0fh                      ; barva vysv¡cen‚ho znaku polo‘ky
         db        70h                      ; kurzor polo‘ky menu
         db        0fh                      ; barva ‡¡sla funk‡n¡ kl vesy
         db        70h                      ; barva textu funk‡n¡ kl vesy

         db        07h                      ; bˆ‘n  barva editovan˜ch polo‘ek
         db        0fh                      ; vysv¡cen  barva editov. polo‘ek
         db        70h                      ; kurzor - bˆ‘n  barva
         db        70h                      ; kurzor - vysv¡cen  barva
         db        70h                      ; barva ozna‡en‚ho bloku dat
         db        70h                      ; barva zv˜raznˆn‚ho bloku dat

         db        70h                      ; barva n povˆdy voleb
         db        70h                      ; bˆ‘n  barva volby
         db        07h                      ; b‚‘n  barva kurzoru
         db        71h                      ; vysv¡cen  barva volby
         db        0fh                      ; vysv¡cen  barva kurzoru

; ------ zadan‚ parametry

Param    db        0                        ; parametry
                                            ;  bit 0: 1=objekt zad n parametrem
                                            ;  bit 1: 1=logick˜ disk zvolen
                                            ;  bit 2: 1=fyzick˜ disk zvolen
                                            ;  bit 3: 1=editace opera‡n¡ pamˆti
                                            ;  bit 4: 1=editace roz¨¡©. pamˆti
                                            ;  bit 5: 1=editace pamˆti CMOS
                                            ;  bit 6: 1=zvolen soubor k editaci
                                            ;  bit 7: 1=zvolen adres © k editaci

Param2   db        0                        ; parametry 2
                                            ;  bit 0: 1=FAT 16, 0=FAT 12
                                            ;  bit 1: 1=z kaz z pisu do objektu
                                            ;  bit 2:
                                            ;  bit 3: 1=zah jena editace polo‘ky
                                            ;  bit 4: 1=plat¡ 1.polo‘ka seznamu
                                            ;  bit 5: 1=velk˜ logick˜ disk>32MB

EditObj  db        0                        ; editovan˜ objekt
                                            ;  bit 0: 1=soubor
                                            ;  bit 1: 1=adres ©
                                            ;  bit 2: 1=logick˜ disk
                                            ;  bit 3: 1=fyzick˜ disk
                                            ;  bit 4: 1=opera‡n¡ pamˆŸ
                                            ;  bit 5: 1=roz¨¡©en  pamˆŸ
                                            ;  bit 6: 1=pamˆŸ CMOS
                                            ;  bit 7: 1=tabulka FAT

DispMod0 db        0                        ; m¢d zobrazen¡ (‡¡slem)
                                            ;  0=Hex
                                            ;  1=Bit
                                            ;  2=Byte
                                            ;  3=Word
                                            ;  4=Text
                                            ;  5=Adres ©
                                            ;  6=FAT
                                            ;  7=Partition
                                            ;  8=Assembler
                                            ;  9=CMOS

DispMod  dw        bit0                     ; m¢d zobrazen¡
                                            ;  bit 0: 1=Hex
                                            ;  bit 1: 1=Bit
                                            ;  bit 2: 1=Byte
                                            ;  bit 3: 1=Word
                                            ;  bit 4: 1=Text
                                            ;  bit 5: 1=Adres ©
                                            ;  bit 6: 1=FAT
                                            ;  bit 7: 1=Partition
                                            ;  bit 8: 1=Assembler
                                            ;  bit 9: 1=CMOS

; ------ tabulka parametr– pro p©¡stup k logick‚mu disku

Paket    label     byte
PaketSec dd        0                        ; ‡¡slo po‡ te‡n¡ho sektoru
PaketNum dw        0                        ; po‡et sektor–
PaketAdr dd        0                        ; adresa bufferu

; ------ uschovan  aktivn¡ pole m¢d– zobrazen¡

TabPole  db        10 dup(0)                ; uschovan  aktivn¡ pole

; ------ popisova‡e editovan‚ polo‘ky

EditPole db        0                        ; editovan‚ pole objektu (TAB)
KurzPol  db        0                        ; kurzor v editovan‚ polo‘ce
KurzPolM db        0                        ; maxim ln¡ kurzor v edit. polo‘ce

EditBuf  db        EBUFDELK dup(" ")        ; edita‡n¡ buffer ‡¡sla
EditBDel db        0                        ; d‚lka edita‡n¡ho bufferu
EditBNum db        0                        ; po‡et platn˜ch znak– v bufferu
;EditBPoz dw        0                        ; pozice a © dek editovan‚ polo‘ky
EditBAdr dw        0                        ; adresa k zobrazen¡ edit. polo‘ky

KorAdrOp label     byte                     ; oprava (sn¡‘en¡) adresy adres ©e
         db        0,0,0,0,0,0,0,0          ; 0 a‘ 7: jm‚no
         db        0,0,0                    ; 8 a‘ 0ah: p©¡pona
         db        0,1,2,3,4,5,6,7,8,9,10   ; 0bh a‘ 15h: atributy
         db        0,1                      ; 16h a‘ 17h: ‡as
         db        0,1                      ; 18h a‘ 19h: datum
         db        0,1                      ; 1ah a‘ 1bh: alok. blok
         db        0,1,2,3                  ; 1ch a‘ 1fh: velikost

KorAdrK  label     byte                     ; tabulka korekce adres ©e - kurzor
         db        10,11,12,13,14,15,16,17  ; 0 a‘ 7: jm‚no
         db        19,20,21                 ; 8 a‘ 0ah: p©¡pona
         db        57,57,57,57,57,57,57,57,57,57,57 ; 0bh a‘ 15h: atributy
         db        48,48                    ; 16h a‘ 17h: ‡as
         db        37,37                    ; 18h a‘ 19h: datum
         db        73,73                    ; 1ah a‘ 1bh: alok. blok
         db        23,23,23,23              ; 1ch a‘ 1fh: velikost

KorAdrNx label     byte                     ; adresa dal¨¡ho pole adres ©e
         db        8,8,8,8,8,8,8,8          ; 0 a‘ 7: jm‚no
         db        1ch,1ch,1ch              ; 8 a‘ 0ah: p©¡pona
         db        1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah ; 0bh a‘ 15h:atr.
         db        0bh,0bh                  ; 16h a‘ 17h: ‡as
         db        16h,16h                  ; 18h a‘ 19h: datum
         db        20h,20h                  ; 1ah a‘ 1bh: alok. blok
         db        18h,18h,18h,18h          ; 1ch a‘ 1fh: velikost

KorAdrPr label     byte                     ; adresa p©edchoz¡ho pole adres ©e
         db        1ah-20h,1ah-20h,1ah-20h,1ah-20h,1ah-20h,1ah-20h,1ah-20h
         db        1ah-20h                  ; 0 a‘ 7: jm‚no
         db        0,0,0                    ; 8 a‘ 0ah: p©¡pona
         db        16h,16h,16h,16h,16h,16h,16h,16h,16h,16h,16h ; 0bh a‘ 15h:atr.
         db        18h,18h                  ; 16h a‘ 17h: ‡as
         db        1ch,1ch                  ; 18h a‘ 19h: datum
         db        0bh,0bh                  ; 1ah a‘ 1bh: alok. blok
         db        8,8,8,8                  ; 1ch a‘ 1fh: velikost

KorFatP  label     byte                     ; korek‡n¡ tabulka adres FAT 12
         db        2*0,2*1,2*1+bit0         ; 0,1
         db        2*2,2*3,2*3+bit0         ; 2,3
         db        2*4,2*5,2*5+bit0         ; 4,5
         db        2*6,2*7,2*7+bit0         ; 6,7
         db        2*8,2*9,2*9+bit0         ; 8,9

; ------ popisova‡e pracovn¡ch buffer–

VerzeOS  dw        0                        ; verze opera‡n¡ho syst‚mu

BuffVRAM dw        0                        ; buffer pro £schovu videopamˆti
BuffSegm dw        0                        ; b zov  adresa buffer–
BuffOff1 dw        0                        ; offset edita‡n¡ho bufferu
BuffOff2 dw        0                        ; offset referen‡n¡ho bufferu


LDisk    db        0                        ; logick˜ disk
FDisk    db        0                        ; fyzick˜ disk

KorAsm   dw        100h                     ; korekce adresy assembleru

CitSek   db        18                       ; ‡¡ta‡ k zobrazen¡ sekund
Old08    dd        0                        ; p–vodn¡ adresa INT 08h

OldPresm db        0ffh                     ; uschovan˜ stav p©esmyka‡– kl ves

SegmVRAM dw        0b000h                   ; segment videopamˆti

SouborN  dw        0                        ; d‚lka jm‚na souboru
Soubor   db        129 dup(?)               ; zvolen˜ soubor/adres ©
FileNum  dw        0                        ; po‡et soubor– v seznamu
FileTop  dw        0                        ; prvn¡ zobrazen˜ soubor
FileAkt  dw        0                        ; aktivn¡ zobrazen˜ soubor

SoubNm0  db        'C:'                     ; ozna‡en¡ disku
SoubName db        13 dup(?)                ; buffer jm‚na souboru ASCIIZ

QckFile  db        11 dup(?)                ; buffer rychlovyhled v n¡
QckFileN dw        0                        ; po‡et znak– rychlovyhled v n¡

InfoBuf  db        2*76 dup(?)              ; buffer textu informa‡n¡ho © dku

OldBreak db        1                        ; uschovan˜ stav p©¡znaku BREAK

; ------ tabulka DTA nalezen‚ho souboru

DTA      label     byte                     ; tabulka DTA
         db        15h dup(?)
DTAAtrib db        ?                        ; atributy nalezen‚ polo‘ky
DTATime  dw        ?                        ; ‡as souboru
DTADate  dw        ?                        ; datum souboru
DTASize  dd        ?                        ; velikost souboru
DTAName  db        13 dup(?)                ; jm‚no souboru ASCIIZ

; ------ tabulky diskov˜ch parametr–

NumDisk  db        ?                        ; po‡et zji¨tˆn˜ch disk–
TabDisk  db        32+1 dup(?)              ; tabulka zji¨tˆn˜ch disk–
                                            ;   (0ffh=konec tabulky)

; ------ parametry objektu - Soubor

SoubIdnt dw        ?                        ; identifik tor souboru
SoubAtr  dw        ?                        ; atributy souboru
SoubTime dw        ?                        ; ‡as souboru
SoubDate dw        ?                        ; datum souboru

; ------ parametry objektu - Adres ©

SektFatB dw        ?                        ; rel.sektor FAT v bufferu (-1=nen¡)
AdrClusN dw        ?                        ; po‡et blok– adres ©e (max. 256)
AdrClust dw        256 dup(?)               ; ©etˆzec blok– adres ©e

; ------ parametry objektu - logick˜ disk

SektSize dw        ?                        ; po‡et bajt– na sektor
SektClus dw        ?                        ; po‡et sektor– na alok. blok
ClusByte dd        ?                        ; po‡et bajt– na aloka‡n¡ blok
RezSekt  dw        ?                        ; po‡et rezervovan˜ch sektor–
NumFat   db        ?                        ; po‡et tabulek FAT
MaxRoot  dw        ?                        ; po‡et polo‘ek ROOT
DatSekt  dw        ?                        ; ‡¡slo prvn¡ho dat. sektoru
NumClust dw        ?                        ; celkov˜ po‡et aloka‡n¡ch blok– dat
SektFat  dw        ?                        ; po‡et sektor– na FAT
RootSekt dw        ?                        ; po‡ te‡n¡ ‡¡slo sektoru ROOT

NumDSekt dd        ?                        ; celkov˜ po‡et sektor– disku
DiskSize dd        ?                        ; velikost disku v bajtech

; Zobrazen¡ adres ©e:
;
; º adresa ³ jm‚no _ EXT ³ velikost ³DD.MM.RRRR³HH:MM:SS³R H S V D A X Y³blokº
; 1----8---1---8---1---3-1----13----1----10----1----8---1-------15------1-6--1
; pozice    À10           À23        À37        À48      À57             À73
; offset    00h-07h 08h-0Ah 1Ch-1Fh    18h-19h   16h-17h     0Bh(-15h)  1Ah-1Bh

; ------ parametry objektu - Fyzick˜ disk

; ------ parametry objektu - Opera‡n¡ pamˆŸ

; ------ parametry objektu - Roz¨¡©en  pamˆŸ

; ------ parametry objektu - PamˆŸ CMOS




; ------ ukazatele editovan‚ho objektu

UkazBeg  label     byte                     ; za‡ tek ukazatel– pro nulov n¡
EditBeg  dd        ?                        ; adresa po‡ tku dat v bufferu
EditNum  dw        ?                        ; po‡et bajt– v bufferu
EditMax  dd        ?                        ; velikost objektu
EditTop  dd        ?                        ; po‡ tek zobrazen‚ str nky v obj.
EditAkt  dd        ?                        ; poloha kurzoru v objektu
EditAkt0 dd        ?                        ; minim ln¡ poloha kurzoru v bufferu
EditAkt1 dd        ?                        ; maxim ln¡ poloha kurzoru v bufferu
EditBBeg dd        ?                        ; offset za‡ tku bloku (prvn¡ bajt)
EditBEnd dd        ?                        ; offset konce bloku (n sled. bajt)
ObjBlok  dw        ?                        ; velikost nejmen¨¡ho bloku objektu
FatTop   dw        ?                        ; ‡¡slo po‡ te‡n¡ zobraz.polo‘ky FAT
DispNum  dw        ?                        ; po‡et bajt– na zobrazenou str nku
LinNum   dw        ?                        ; po‡et bajt– na zobrazen˜ © dek
UkazEnd  label     byte                     ; konec ukazatel– pro nulov n¡

EditOBeg dd        ?                        ; uschovan˜ po‡ tek v bufferu
EditONum dw        ?                        ; uschovan˜ po‡et bajt– v bufferu
EditOAkt dd        ?                        ; uschovan  pozice kurzoru
EditOTop dd        ?                        ; uschovan˜ po‡ tek str nky
KurzOPol db        ?                        ; uschovan˜ kurzor v polo‘ce

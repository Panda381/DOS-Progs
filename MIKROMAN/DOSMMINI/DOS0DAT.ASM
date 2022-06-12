
; *****************************************************************************
;
;         Konstanty - data s konstantn¡ hodnotou (jsou sou‡ st¡ souboru)
;
; *****************************************************************************
public   textsp1,textsp2,textsp20,textsp21
public   textsp22,textsp23,textsp3,textsp30,textsp31,textsp32,textsp4
public   txthlped,txthlpzo

public   zactxt,konectxt,textcek
public   erredi1,erroper

zactxt   label     byte                   ;* za‡ tek text–

textcek  db        8,' CEKEJTE ! ',0

public   texthlpb

texthlpb db        7,' bajt',0

public   dny,mesice

dny      label     word
         db        0

mesice   label     word
         db        0

textsp1  db        1,' bajt',0
textsp2  db        ' voln',0
textsp20 db        'y',0                    ; koncovka "˜"
textsp21 db        'e',0                    ; koncovka "‚"
textsp22 db        'ych',0
textsp23 db        ' z ',2,0

textsp3  db        1,' soubor',0
textsp30 db        ' zabir',0
textsp31 db        'a ',2,0
textsp32 db        'aji ',2,0
textsp4  db        1,' bajt',0

public   textvy1,textvy11,textvy12,textvy13,textvy14,textvy2,textvy21,textvy22

textvy1  db        1,' bajt',0
textvy11 db        'y',0                    ; koncovka "y"
textvy12 db        'u',0                    ; koncovka "–"
textvy13 db        ' v ',2,0
textvy14 db        ' ve ',2,0

textvy2  db        1,' soubor',0
textvy21 db        'u ',0
textvy22 db        'ech ',0

public   txtsel,txtunsel,txtmov1,txtcop1,txtcop2,txtcop3,txtmov2,txthled
public   txthled3,txthled6,txtedis

txtsel   db        ' vybrat soubory: ',0
txtunsel db        ' zrusit vyber souboru: ',0
txthled  db        ' Soubor k vyhledani: ',0
txtmov1  db        ' Prejmenuji/presunu ',0
txtmov2  db        ' Prejmenuji ',0
txtcop1  db        ' Zkopiruji ',0
txtcop2  db        ' na: ',0
txtcop5  db        'Kopiruji',0
txtmov5  db        'Presouvam',0
txtmov6  db        'Prejmenovavam',0
txtmov7  db        7,' na ',10,0
txtcop6  db        7,' do ',10,0
txtcop3  db        ' oznacen',0
txtvyt1  db        ' Vytvorim adresar: ',0
txtvyt2  db        7,'Vytvarim adresar ',10,0
txtvar   db        8,' VAROVANI ',7,31,0
txtdel1  db        'Zrusim ',0
txtdel3  db        ' !',0
txtadr   db        'adresar',0
txtdel2  db        'Rusim',0
txthled3 db        7,' Hledam ',10,0
txthled6 db        31,'Soubor podle zadane specifikace nenalezen !',0
txtedis  db        'Zadejte jmeno editovaneho souboru: ',0

txtkon1  db        31,'Chcete ukoncit program ',10,'DOS Manazer',7,' ?',0
txtkon2  db        'Ano',0,'Ne',0,0

txtpovel db        ' Historie prikazu: ',0

public   txtmen
txtmen   db        ' Zvolte pozadovanou operaci: ',0

txtdisk1 db        ' Zmena disku pro ',10,0
txtdisk2 db        'leve',0
txtdisk3 db        'prave',0
txtdisk4 db        7,' okno: ',0

public   txtchyb1,txtmenu,txtchyb,soubmen,errhlp1,txthlp1,soubext

errhlp1  db        7,'Soubor napovedy "',10,'DOSMAN.HLP'
         db        7,'" nenalezen !',0

txtmenu  db        7,'Soubor uzivatelskych voleb "',10,'DOSMAN.MNU'
         db        7,'" nenalezen !',0
txtnfnd  db        31,7,'Zadny soubor nenalezen !',0
txtchyb  db        8,' CHYBA ',7,31,0
txtchyb1 db        'OK',0,0
txtatr1  db        31,7,'Nastavim atributy pro ',0
txtatr2  db        'Zobrazeni'
txtatr21 db        ' ',0
         db        'Nastavit',0
         db        'Vynulovat',0
         db        'P©eru¨it operaci',0
         db        0

public   txtfail,txtfai0,txtfai2,txtfai7,txtfai8,txtfaic,txtfaic2,volbfail
public   txtfaid,txtfai4,txtfaifa,txtfaidi

txtfail  db        8,' CHYBA ZARIZENI ! ',7,31,0
txtfai0  db        'Pokousite se zapisovat na disketu, ktera',31
         db        'ma nastavenu ochranu proti zapisu !',0
txtfai2  db        'V disketove mechanice neni vlozena disketa',31
         db        'nebo dvirka nejsou uzavrena !',0
txtfai4  db        'Vadny sektor diskety (chyba dat) !',0
txtfai7  db        'Disketa ma neznamy format !',0
txtfai8  db        'Sektor nebyl nalezen !',0
txtfaic  db        'Chybu nelze blize specifikovat.',31
         db        'kod chyby=',0
txtfaic2 db        ',typ chyby=',0
txtfaid  db        'Poruseno sdileni souboru !',0
txtfaifa db        'Chybna tabulka FAT diskety !',0
txtfaidi db        'Vadny adresar diskety !',0

volbfail db        'Opakovat',0
         db        'Prerusit',0
         db        'Ignorovat',0
         db        0


public   txtcomp1,txtcomp4

txtcomp1 db        7,' Zvolte uroven porovnani adresaru: ',0

txtcomp4 db        'Plne porovnani',0
         db        'Shodne soubory',0
         db        'Rozdilne soubory',0
         db        'Navrat',0
         db        0

txtatr3  db        31,7,'Ktere atributy chcete ',0
txtatr31 db        'nastavit ?',0
txtatr32 db        'nulovat ?',0
txtatr4  db        'Provest operaci',0
txtatr5  db        'ARC ',0
txtatr52 db        'SYS ',0
txtatr53 db        'HID ',0
txtatr54 db        'R/O ',0
         db        'Navrat',0
         db        0

txtatr7  db        'Nastavuji',0
txtatr8  db        'Nuluji',0
txtatr9  db        ' atributy',0
txtatra  db        7,' souboru ',10,0
txtatrb  db        7,' adresare ',10,0

txtwin1  db        7,' Nastavte klic pro trideni adresare: ',0

txtwin5  db        'Jmeno',0
         db        'Pripona',0
         db        'Datum a cas',0
         db        'Velikost',0
         db        'Netridit',0
         db        0

errdel1  db        7,'Soubor ',10,0
errdir1  db        7,'Adresar ',10,0
errdir2  db        7,' nelze zrusit',0
errdir3  db        7,'Adresar musi byt prazdny !',0
;errdir4  db        7,' jiz existuje !',0
;errdir5  db        7,'Existuje jiz soubor ',10,0
errdir6  db        7,' !',0
errdel2  db        ',',31,'protoze ma ochranu proti zapisu !',31,31
errdel3  db        'Chcete jej i presto zrusit ?',0
errcop1  db        'Chybne zadani adresare nebo disku !',0
errcop2  db        'Nelze ',0
errcop21 db        'kopirovat',0
errcop22 db        'presouvat',0
errcop25 db        ' vice souboru do jednoho !',0
errcop3  db        'Soubor nelze kopirovat sam do sebe !',0
errcop4  db        7,' jiz existuje !',31
         db        'Chcete jej prepsat ?',0
errcop5  db        'Na disku ',10,0
errcop51 db        7,' neni dostatek volneho mista !',0
erroper  db        'Operaci nelze provest !',0
erredi2  db        8,' CHYBA ',7,31,'Nedostatek mista v pameti !',0
erredi3  db        31,'Hledany text "',10,0
erredi4  db        7,'" nenalezen !',0
erredi5  db        'Nedostatek mista na disku - soubor byl zrusen !',0
erredi6  db        'Chybne zadani souboru !',0

public   txtedi1,txtedi2,txtedi3,txtedi4,txtedi5,txtedi6,erredi2,txtedi7
public   erredi3,erredi4,txtedi8,edivolb2,erredi5,erredi6,txtedi9,txtedia
public   txtedib,txtedif1,edivolb3,txtedif2,edivolb4

txtedi1  db        'Volne:',0
txtedi2  db        'Radek:',0
txtedi3  db        'Pozice:',0
txtedi4  db        'Offset:',0
txtedi5  db        'EOL',0
txtedi6  db        'EOF',0
txtedi7  db        ' Zadejte hledany text: ',0
txtedi8  db        31,'Soubor byl modifikovan. Chcete jej ulozit ?',0
txtedi9  db        ' Soubor ulozim jako: ',0
txtedia  db        ' Oznaceny blok ulozim jako: ',0
txtedib  db        ' Nactu jako blok soubor: ',0
erredi1  db        'Soubor se nenacetl do pameti cely !',0

txtedif1 db        ' V oznacenem bloku zmenim ceske fonty: ',0

txtedif2 db        ' V oznacenem bloku provedu zmenu na: ',0

; erredi1  db        'Soubor je pro editaci prilis velky !',0

edivolb2 db        'Ulozit',0
         db        'Neukladat',0
         db        'Pokracovat',0
         db        0

edivolb3 db        '1:KAM>bez',0
;         db        '2:KAM>LAT2',0
;         db        '3:LAT2>bez',0
;         db        '4:LAT2>KAM',0
         db        0

edivolb4 db        'Velka pismena',0
;         db        'Mala pismena',0
         db        0

copyvolb db        'Prepsat',0
         db        'Vsechny',0
         db        'Dalsi',0
         db        'Neprepisovat zadny',0
         db        0

delvolb  db        'Zrusit',0
         db        'Vsechny',0
         db        'Dalsi',0
         db        'Preskocit vsechny',0
         db        0

erradres db        7,'Chybne zadani adresare !',0

public   txtsubd,txtupd

txtsubd  db        '<POD--ADR>',0
txtupd   db        '<NAD--ADR>',0


public   txthelp3,txthelp2

txthelp3:
         db        0                        ; Shift-F1
         db        0                        ; Shift-F2
         db        0                        ; Shift-F3
         db        0                        ; Shift-F4
         db        0                        ; Shift-F5
         db        0                        ; Shift-F6
         db        0                        ; Shift-F7
         db        0                        ; Shift-F8
         db        0                        ; Shift-F9
         db        0                        ; Shift-F10

txthelp2:
         db        0                        ; Alt-F1
         db        0                        ; Alt-F2
         db        0                        ; Alt-F3
         db        0                        ; Alt-F4
         db        0                        ; Alt-F5
         db        0                        ; Alt-F6
         db        0                        ; Alt-F7
         db        0                        ; Alt-F8
         db        0                        ; Alt-F9
         db        0                        ; Alt-F10

txthelp:
         db        'Leve',0                 ; F1
         db        'Prave '                 ; F2
         db        'Zobraz'                 ; F3
         db        'Edituj'                 ; F4
         db        'Kopie '                 ; F5
         db        'Presun'                 ; F6
         db        'Vytvor'                 ; F7
         db        'Zrusit'                 ; F8
         db        'Prikaz'                 ; F9
         db        'Konec '                 ; F10

txthlped:                                 ;* editor
         db        'Info',0                 ; F1
         db        'Uloz',0                 ; F2
         db        0                        ; F3
         db        0                        ; F4
         db        0                        ; F5
         db        0                        ; F6
         db        0                        ; F7
         db        0                        ; F8
         db        0                        ; F9
         db        'Konec '                 ; F10

txthlped2:                                ;* editor se SHIFT
         db        0                        ; F1
         db        0                        ; F2
         db        0                        ; F3
         db        0                        ; F4
         db        0                        ; F5
         db        0                        ; F6
         db        0                        ; F7
         db        0                        ; F8
         db        0                        ; F9
         db        0                        ; F10

txthlped3:                                ;* editor s ALT
         db        0                        ; F1
         db        0                        ; F2
         db        0                        ; F3
         db        0                        ; F4
         db        0                        ; F5
         db        0                        ; F6
         db        0                        ; F7
         db        0                        ; F8
         db        0                        ; F9
         db        0                        ; F10

txthlpzo:
         db        'Info',0                 ; F1
         db        0                        ; F2
         db        0                        ; F3
         db        0                        ; F4
         db        0                        ; F5
         db        0                        ; F6
         db        0                        ; F7
         db        0                        ; F8
         db        0                        ; F9
         db        'Konec '                 ; F10

txthlpzo1:                                ;* zobrazen¡ se SHIFT-
         db        0                        ; SHIFT-F1
         db        0                        ; SHIFT-F2
         db        0                        ; SHIFT-F3
         db        0                        ; SHIFT-F4
         db        0                        ; SHIFT-F5
         db        0                        ; SHIFT-F6
         db        0                        ; SHIFT-F7
         db        0                        ; SHIFT-F8
         db        0                        ; SHIFT-F9
         db        0                        ; SHIFT-F10

txthlpzo2:                                ;* zobrazen¡ s ALT-
         db        0                        ; ALT-F1
         db        0                        ; ALT-F2
         db        0                        ; ALT-F3
         db        0                        ; ALT-F4
         db        0                        ; ALT-F5
         db        0                        ; ALT-F6
         db        0                        ; ALT-F7
         db        0                        ; ALT-F8
         db        0                        ; ALT-F9
         db        0                        ; ALT-F10


public   hlptre
hlptre   db        0                        ; F1
         db        0                        ; F2
         db        0                        ; F3
         db        0                        ; F4
         db        0                        ; F5
         db        0                        ; F6
         db        0                        ; F7
         db        0                        ; F8
         db        0                        ; F9
         db        0                        ; F10

public   helped
helped   db        0                        ; F1
         db        0                        ; F2
         db        0                        ; F3
         db        0                        ; F4
         db        0                        ; F5
         db        0                        ; F6
         db        0                        ; F7
         db        0                        ; F8
         db        0                        ; F9
         db        0                        ; F10


public   errmem
errmem   db        'Neni dostatek volne pameti !',13,10,'$'

konectxt label     byte                   ;* konec text–

public   tabhlp0
tabhlp0  label     word
         dw        offset txthelp           ; z kladn¡ n povˆda
         dw        offset txthelp3          ; n povˆda se Shift-
         dw        offset hlpuse            ; n povˆda s Ctrl-
         dw        offset txthelp2          ; n povˆda s Alt-

public   tabhlpt
tabhlpt  label     word
         dw        offset hlptre            ; z kladn¡ n povˆda
         dw        offset helped            ; n povˆda se Shift-
         dw        offset helped            ; n povˆda s Ctrl-
         dw        offset hlptre            ; n povˆda s Alt-

public   tabhlped
tabhlped label     word                   ;* n povˆda pro editor
         dw        offset txthlped          ; z kladn¡ n povˆda
         dw        offset txthlped2         ; n povˆda se Shift-
         dw        offset helped            ; n povˆda s Ctrl-
         dw        offset txthlped3         ; n povˆda s Alt-

public   tabhlzob
tabhlzob label     word                   ;* n povˆda pro zobrazen¡
         dw        offset txthlpzo          ; z kladn¡ n povˆda
         dw        offset txthlpzo1         ; n povˆda se Shift-
         dw        offset helped            ; n povˆda s Ctrl-
         dw        offset txthlpzo2         ; n povˆda s Alt-

public   tabhlfnd
tabhlfnd label     word                   ;* n povˆda pro vyhled v n¡
         dw        0                        ; p©¡znak, ‘e se n povˆda nezobraz¡
;         dw        offset helped            ; z kladn¡ n povˆda
;         dw        offset helped            ; n povˆda se Shift-
;         dw        offset helped            ; n povˆda s Ctrl-
;         dw        offset helped            ; n povˆda s Alt-


public   nadadr,rootdir,all,nuldir
nadadr   db        "..",0                   ; ozna‡en¡ nadadres ©e
rootdir  db        '\',0                    ; ozna‡en¡ hlavn¡ho adres ©e
all      db        '*.*',0                  ; ozna‡en¡ - v¨echny soubory
nuldir   db        0                        ; nulov˜ adres ©

public   filehelp
filehelp db        'DOSMAN.HLP',0           ; soubor n povˆdy
filewiev db        'VIEW',0                 ; jm‚no souboru pro VIEW ALT-F3
fileedit db        'EDIT',0                 ; jm‚no souboru pro EDIT ALT-F4
fileuser db        'USER',0                 ; jm‚no souboru u‘ivatele
filebat  db        '.BAT %1 %2 %3 %4',0     ; p©¡pona pro soubory
fileobn  db        'UNDEL.EXE',0            ; program pro obnoven¡ soubor–

public   menuprf1,menuprf2,menuprf3         ; prefixy pro menu
menuprf1 db        'SHIFT-',0
menuprf2 db        'CTRL-',0
menuprf3 db        'ALT-',0

txthlp1  db        '[HELP HELP]',0

public   soubuse,soubtre,soubcol
soubuse  db        'DOSMAN.USE',0
soubmen  db        'DOSMAN.MNU',0
soubext  db        'DOSMAN.EXT',0
soubtre  db        'DOSMAN.TRE',0           ; strom adres ©e
soubcol  db        'DOSMAN.COL',0

extent   db        'EXECOMBAT'              ; povolen‚ extenty

tabchar  label     byte                     ; tabulka kl ves s Alt


public   upperkam
upperkam label     byte                   ;* velk  p¡smena Kamenick˜ch


public   upperlat
upperlat label     byte                   ;* velk  p¡smena Latin 2

public   prevcs
prevcs   label     byte                   ;* tabulka pro vypnut¡ ‡e¨tiny


public   colcol,colbw

colbw    label     byte                     ; barvy pro monochromatick˜ displej

         db        07h                      ; atribut norm ln¡ho textu okna
         db        0fh                      ; atribut vysv¡cen‚ho textu
         db        70h                      ; atribut negovan‚ho textu
         db        70h                      ; atribut negovan‚ho vysv¡cen‚ho tx.
         db        07h                      ; ukazatel norm ln¡
         db        0fh                      ; ukazatel vysv¡cen¡
         db        70h                      ; norm ln¡ okno
         db        0fh                      ; chybov‚ hl ¨en¡
         db        07h                      ; text ‡¡sla funk‡n¡ kl v. n povˆdy
         db        70h                      ; zv˜raznˆn˜ text v norm ln¡m oknˆ
         db        70h                      ; kurzor pro prov dˆn¡ operace
         db        70h                      ; vysv¡cen˜ kurzor operace
         db        0fh                      ; zobrazen¡ chyby zad n¡ parametru
         db        0fh                      ; vysv¡cen‚ p¡smeno v kurzoru
         db        0fh                      ; ©¡dic¡ znak v textu editoru

         db        07h                      ; barva podkladu n povˆdy
         db        0fh                      ; polo‘ka n povˆdy
         db        70h                      ; kurzor n povˆdy
         db        07h                      ; kurzor v oknˆ voleb

colcol   label     byte                     ; barvy pro barevn˜ displej

         db        1bh                      ; atribut norm ln¡ho textu okna
         db        1eh                      ; atribut vysv¡cen‚ho textu
         db        30h                      ; atribut negovan‚ho textu
         db        3eh                      ; atribut negovan‚ho vysv¡cen‚ho tx.
         db        6fh                      ; ukazatel norm ln¡
         db        6ch                      ; ukazatel vysv¡cen¡
         db        70h                      ; norm ln¡ okno
         db        4fh                      ; chybov‚ hl ¨en¡
         db        07h                      ; text ‡¡sla funk‡n¡ kl v. n povˆdy
         db        74h                      ; zv˜raznˆn˜ text v norm ln¡m oknˆ
         db        60h                      ; kurzor pro prov dˆn¡ operace
         db        6eh                      ; vysv¡cen˜ kurzor operace
         db        4fh                      ; zobrazen¡ chyby zad n¡ parametru
         db        34h                      ; vysv¡cen‚ p¡smeno v kurzoru
         db        1dh                      ; ©¡dic¡ znak v textu editoru

         db        1bh                      ; barva podkladu n povˆdy
         db        1fh                      ; polo‘ka n povˆdy
         db        4fh                      ; kurzor n povˆdy
         db        30h                      ; kurzor v oknˆ voleb


; *****************************************************************************
;
;     Inicializa‡n¡ data - jsou sou‡ st¡ souboru a jsou rezidentn¡ v pamˆti
;
; *****************************************************************************
public   inidata,flags,pozwr,pozwl,config,flags0l,flags0r,conf2,conf3  ;,port

inidata  label     byte                   ;* za‡ tek inicializa‡n¡ch dat

                                          ;* definice oken
 flags    db        00001100b                ; indik tor stav–

                                            ;   bit 0: 1=aktivn¡ je lev‚ okno
                                            ;   bit 1: 1=v¨echna okna vypnuta
                                            ;   bit 2: 1=n povˆda je povolena
                                            ;   bit 3: 1=je rezidentn¡ re‘im
                                            ;   bit 4: 1=nen¡ zobrazen¡ 25 © dk–
                                            ;   bit 5: 1=‡ernob¡l˜ displej
                                            ;   bit 6: 00=z klad. n povˆda,
                                            ;   bit 7:  01=Shift,10=Ctrl,11=Alt

flags0l  db        00000001b              ;* £schova indik toru lev‚ho okna
                                            ;     bit 0: 1=okno je zapnuto
                                            ;     bit 1: 1=adres © je na‡ten
                                            ;     bit 2: 1=adres © se nenuluje
                                            ;     bit 3: 1=okno je zobrazeno
                                            ;     bit 4: 1=okno se net©¡d¡
                                            ;     bit 5: 1=t©¡dˆn¡ podle p©¡pony
                                            ;     bit 6: 1=t©¡dˆn¡ podle data a ‡asu
                                            ;     bit 7: 1=t©¡dˆn¡ podle velikosti

public   setwls,setwrs
setwls   db        ?                      ;* nastaven¡ lev‚ho okna
                                            ; bit 0: 1=trojsloupc. zobrazen¡

setwrs   db        ?                      ;* nastaven¡ prav‚ho okna
                                            ; bit 0: 1=trojsloupc. zobrazen¡

flags0r  db        00000001b              ;* £schova indik toru prav‚ho okna
                                            ;     bit 0: 1=okno je zapnuto
                                            ;     bit 1: 1=adres © je na‡ten
                                            ;     bit 2: 1=adres © se nenuluje
                                            ;     bit 3: 1=okno je zobrazeno
                                            ;     bit 4: 1=okno se net©¡d¡
                                            ;     bit 5: 1=t©¡dˆn¡ podle p©¡pony
                                            ;     bit 6: 1=t©¡dˆn¡ podle data a ‡asu
                                            ;     bit 7: 1=t©¡dˆn¡ podle velikosti

config   db        00000001b              ;* konfigurace programu
                                            ;   bit 0: 1=vypnut¡ ‡e¨tiny
                                            ;   bit 1: 1=je k¢d LATIN 2
                                            ;   bit 2: 1=je zobrazen¡ Ctrl-
                                            ;   bit 3: 1=adres © TREE je na‡ten
                                            ;   bit 4: 1=porovn vaj¡ se shodn‚ soubory
                                            ;   bit 5: 1=porovn vaj¡ se odli¨n‚ soubory
                                            ;   bit 6: 1=nainstalov na my¨
                                            ;   bit 7: 1=je n povˆda SHIFT

conf2    db        00010000b              ;* konfigurace 2
                                            ;   bit 0: (1=prov dˆn¡ p©¡kaz– INT 2Eh)
                                            ;   bit 1: 1=jsou atributy lev‚ho okna
                                            ;   bit 2: 1=jsou atributy prav‚ho okna
                                            ;   bit 3: 1=nucen˜ p©¡znak SHIFT
                                            ;   bit 4: 1=je povolen˜ SHIFT
                                            ;   bit 5-7: typ my¨i, 0=‘ dn  my¨
                                            ;                      1=GENIUS MOUSE
                                            ;                      7=automaticky

pozwr    db        40                       ; po‡ te‡n¡ pozice prav‚ho okna
pozwl    db        0                        ; po‡ te‡n¡ pozice lev‚ho okna

ediflag  db        0                      ;* p©¡znaky editoru
                                            ;   bit 0: 1=soubor byl modifikov n
                                            ;   bit 1: 1=je prefix ^Q
                                            ;   bit 2: 1=je vypnuta funkce INS
                                            ;   bit 3: 1=je zobrazen blok
                                            ;   bit 4: 1=tabel tory se nezobraz¡
                                            ;   bit 5: 1=zobrazen¡ HEX
                                            ;   bit 6: 1=je bin rn¡ editace
                                            ;   bit 7: 1=je prefix ^K

conf3    db        00000100b              ;* konfigurace
                                            ;   bit 0: 1=je automatick‚ menu
                                            ;   bit 1: 1=po‘adavek spu¨tˆn¡ menu
                                            ;   bit 2: 1=standardn¡ kl vesnice


;port     dw        0                        ; ‡¡slo komunika‡n¡ho portu

; *****************************************************************************
;
;    Neinicializovan  data -  nejsou sou‡ st¡ MNS.COM a z–st vaj¡ v pamˆti
;
; *****************************************************************************
public   zacmaz,path,namel,namer,firstwl,firstwr
public   inidend

zacmaz   label     byte                     ; odtuto se pamˆŸ vyma‘e p©i inic.

;pathhome db        128 dup(?)               ; p©¡stupov  cesta k domovsk‚mu adr.
path     db        70 dup(?)                ; cesta k neaktivn¡mu oknu

namel    db        20 dup(?)                ; p©edvolen‚ jm‚no souboru L
namer    db        20 dup(?)                ; p©edvolen‚ jm‚no souboru R
firstwl  dw        ?                        ; uchovan  pozice lev‚ho okna
firstwr  dw        ?                        ; uchovan  pozice prav‚ho okna

bufsel   label     byte                   ;* buffer masek pro selekci soubor–
         dw        ?                        ; d‚lka bufferu
bufsel1  db        130 dup(?)               ; buffer
bufsel2  db        ?                        ; po‡et p©edvoleb
         dw        ?                        ; adresa p©edvolby "*.*"


public   bufcopy,bufcop1,bufcop2,bufcop3

bufcopy  label     byte                   ;* buffer pro kop¡rov n¡ soubor–
         dw        ?                        ; d‚lka bufferu
bufcop1  db        130 dup(?)
bufcop2  db        ?                        ; po‡et p©edvoleb 1 a‘ 2
bufcop3  dw        ?                        ; p©edvolba 1
bufcop4  dw        ?                        ; p©edvolba 2


bufadr   label     byte                   ;* buffer adres ©–
         dw        ?                        ; d‚lka bufferu
bufadr1  db        130 dup(?)
bufadr2  db        ?                        ; po‡et p©edvoleb = 0

bufcomm  label     byte                   ;* buffer povel–
         dw        ?                        ; d‚lka bufferu
bufcomm1 db        130 dup(?)
bufcomm2 db        ?                        ; po‡et p©edvoleb = 1
bufcomm3 dw        ?                        ; p©edvolba - BUFTXT


public   buffind,buffind1,buffind2,buffind3
buffind  label     byte                   ;* buffer pro vyhled v n¡ soubor–
         dw        ?                        ; d‚lka bufferu
buffind1 db        130 dup(?)
buffind2 db        ?                        ; po‡et p©edvoleb = 0
buffind3 dw        ?                        ; p©edvolba - aktivn¡ adres ©

bufhled  label     byte                   ;* buffer pro vyhled v n¡
         dw        ?                        ; d‚lka bufferu
bufhled1 db        130 dup(?)
bufhled2 db        ?                        ; po‡et p©edvoleb = 0

public   bufhlde,bufhlde1,bufhlde2,findstr

bufhlde  label     word                   ;* buffer pro vyhled v n¡ p©i editaci
         dw        ?                        ; d‚lka bufferu
bufhlde1 db        130 dup(?)               ; (velikost nemˆnit !)
bufhlde2 db        ?                        ; po‡et p©edvoleb = 0

findstr  dw        ?                        ; adresa hledan‚ho ©etˆzce

hlptop   dw        ?                        ; po‡ t. adresa zobrazen¡ n povˆdy
hlpkurz  dw        ?                        ; adresa kurzoru n povˆdy

public   hlpuse
hlpuse   db        10 * 6 dup(?)            ; u‘ivatelsk  n povˆda

                                          ;* zna‡ky v souboru
ediblkb  dw        ?                        ; adresa za‡ tku bloku
ediblkk  dw        ?                        ; adresa konce bloku
ediznac  dw        ?                        ; zna‡ka v souboru (0)
ediblk1  dw        ?                        ; zna‡ka v souboru 1
ediblk2  dw        ?                        ; zna‡ka v souboru 2
ediblk3  dw        ?                        ; zna‡ka v souboru 3
ediblk4  dw        ?                        ; zna‡ka v souboru 4
ediblk5  dw        ?                        ; zna‡ka v souboru 5
ediblk6  dw        ?                        ; zna‡ka v souboru 6
ediblk7  dw        ?                        ; zna‡ka v souboru 7
ediblk8  dw        ?                        ; zna‡ka v souboru 8
ediblk9  dw        ?                        ; zna‡ka v souboru 9
ediblk0  dw        ?                        ; zna‡ka v souboru 10

public   col1,col2,col3,col4,col5,col6,col7,col8,col9,col10,col11,col12,col13
public   col16,col19,coldisp

coldisp  label     byte                     ; barvy pro displej

col1     db        ?                        ; atribut norm ln¡ho textu okna
col2     db        ?                        ; atribut vysv¡cen‚ho textu
col3     db        ?                        ; atribut negovan‚ho textu
col4     db        ?                        ; atribut negovan‚ho vysv¡cen‚ho tx.
col5     db        ?                        ; ukazatel norm ln¡
col6     db        ?                        ; ukazatel vysv¡cen¡
col7     db        ?                        ; norm ln¡ okno
col8     db        ?                        ; chybov‚ hl ¨en¡
col9     db        ?                        ; text ‡¡sla funk‡n¡ kl v. n povˆdy
col10    db        ?                        ; zv˜raznˆn˜ text v norm ln¡m oknˆ
col11    db        ?                        ; kurzor pro prov dˆn¡ operace
col12    db        ?                        ; vysv¡cen˜ kurzor operace
col13    db        ?                        ; zobrazen¡ chyby zad n¡ parametru
col14    db        ?                        ; vysv¡cen‚ p¡smeno v kurzoru
col15    db        ?                        ; ©¡dic¡ znak v textu editoru

col16    db        ?                        ; barva podkladu n povˆdy
col17    db        ?                        ; polo‘ka n povˆdy
col18    db        ?                        ; kurzor n povˆdy
col19    db        ?                        ; kurzor v oknˆ voleb

public   presmen
presmen  db        ?                        ; p©edvolen  polo‘ka menu

public   mousepoz
mousepoz dw        ?                        ; sou©adnice kurzoru my¨i

inidend  label     byte                     ; adresa konce rezidentn¡ch dat

; *****************************************************************************
;
;         Neinicializovan  data pracovn¡ - p©i startu programu se ru¨¡
;
; *****************************************************************************
public   zasob,keystat,keyinp,topseg,segend,seznseg,pathr,pathl,licence
public   datseg,verze
public   zacmazr

zacmazr  label     byte                     ; odtuto se pamˆŸ vyma‘e p©i reinic.

verze    dw        ?                        ; ‡¡slo verze opera‡n¡ho syst‚mu
zasob    dw        ?                        ; vrchol z sobn¡ku SP

licence  dd        ?                        ; licen‡n¡ ‡¡slo

keystat  db        ?                        ; k¢d pro ‡ten¡ statusu kl vesnice
keyinp   db        ?                        ; k¢d pro ‡ten¡ znaku z kl vesnice

                                          ;* data pro obsluhu pamˆti
datseg   dw        ?                        ; za‡ tek aloka‡n¡ho bloku dat
topseg   dw        ?                        ; segment za‡ tku voln‚ pamˆti
segend   dw        ?                        ; segment konce voln‚ pamˆti
seznseg  dw        30 dup(?)                ; seznam segment– adres
seznseg0 label     byte                     ; konec seznamu

pathr    db        70 dup(?)                ; cesta k prav‚mu adres ©i
pathl    db        70 dup(?)                ; cesta k lev‚mu adres ©i

public   parint,old23,old24,old1b,citachod,citmouse
public   citacexp

parint   db        ?                        ; p©¡znak obsluh p©eru¨en¡
                                            ;   bit 0: je aktivn¡ INT 08h
                                            ;   bit 1: je aktivn¡ INT 10h
                                            ;   bit 2: je aktivn¡ INT 24h
                                            ;   bit 3: hled n¡ souboru ALT-F7
                                            ;   bit 4: prov d¡ se zobrazen¡ F3
                                            ;   bit 5: prov d¡ se editace F4
                                            ;   bit 6: prob¡h  zobrazen¡ ‡asu
                                            ;   bit 7: povoleno zobrazen¡ ‡asu
;old08    dd        ?                        ; p–vodn¡ adresa obsluhy INT 08h
;old09    dd        ?                        ; p–vodn¡ adresa obsluhy INT 09h
;old10    dd        ?                        ; p–vodn¡ adresa obsluhy INT 10h
old1b    dd        ?                        ; p–vodn¡ adresa obsluhy INT 1Bh
;old21    dd        ?                        ; p–vodn¡ adresa obsluhy INT 21h
old23    dd        ?                        ; p–vodn¡ adresa obsluhy INT 23h
old24    dd        ?                        ; p–vodn¡ adresa obsluhy INT 24h
citachod db        ?                        ; ‡¡ta‡ pro zobrazen¡ hodin
citacexp db        ?                        ; ‡¡ta‡ pro explozi
citmouse db        ?                        ; ‡¡ta‡ pro aktivaci my¨i
mousedat db        ?                        ; uschovan˜ stav tla‡¡tek my¨i

public   typdisp,aktpage
public   adrvram,segvram,citdek,citnum,aktkurz
public   parnum,color,cisvram,insmouse,displ,delvram
                                          ;* £schova p–vodn¡ho m¢du displeje
typdisp  db        ?                        ; typ displeje:
                                            ;    0=nezn m˜ displej (BIOS)
                                            ;    1=MDA
                                            ;    2=CGA,EGA
aktpage  db        ?                        ; aktivn¡ str nka displeje
adrvram  dw        ?                        ; adresa za‡ tku str nky ve VRAM
segvram  dw        ?                        ; segment videopamˆti
aktkurz  dw        ?                        ; £schova p–vodn¡ho kurzoru
cisvram  db        ?                        ; ‡¡slo segmentu s VRAM
delvram  dw        ?                        ; d‚lka bufferu s uschovanou VRAM
insmouse db        ?                        ; parametr ozna‡ov n¡ my¨¡
                                            ;   bit 0: 1=nastaven¡ nen¡ ur‡eno
                                            ;   bit 1: 1=bylo prvn¡ nastaven¡
                                            ;   bit 2: 1=pevn˜ je konec
                                            ;   bit 7: 1=je ozna‡en¡ souboru
displ    db        ?                        ; posledn¡ © dek displeje


public   comlin,normat,poclin

comlin   label     byte                     ; definice povelov‚ho © dku
                                          ;* editace © dku
adrlin   dw        ?                        ; 0: adresa bufferu © dku
seglin   dw        ?                        ; 2: segment adresy
maxlin   dw        ?                        ; 4: maxim ln¡ po‡et znak–
poclin   dw        ?                        ; 6: skute‡n˜ po‡et znak–
kurlin   dw        ?                        ; 8: pozice kurzoru v bufferu
zaclin   dw        ?                        ; 10: pozice zobraz. za‡ tku textu
pozlin   db        ?                        ; 12: po‡ te‡n¡ pozice na displeji
radlin   db        ?                        ; 13: © dek k zobrazen¡ textu
dellin   db        ?                        ; 14: ¨¡©ka © dku textu
normat   db        ?                        ; 15: atribut barvy
                                          ;* parametry pro rolov n¡ oken
pocrol   dw        ?                        ; 16: po‡et © dk– celkem
kurrol   dw        ?                        ; 18: pozice kurzoru
zacrol   dw        ?                        ; 20: prvn¡ zobrazen˜ © dek
delrol   db        ?                        ; 22: po‡et zobrazen˜ch © dk–

public   buftxt

buftxt   db        129 dup(?)               ; textov˜ buffer

public   sellin,numselb,ukazsel,topsel,pocpozsl,pocradsl,delkasel,atribsel
public   radkusel,kurzsel,firstsel,zobrlsel,selbuf,selbufz

sellin   label     byte                     ; definice textu p©i volbˆ
                                          ;* editace © dku
         dw        ?                        ; 0: adresa bufferu © dku
         dw        ?                        ; 2: segment adresy
         dw        ?                        ; 4: maxim ln¡ po‡et znak–
numselb  dw        ?                        ; 6: skute‡n˜ po‡et znak–
ukazsel  dw        ?                        ; 8: pozice kurzoru v bufferu
topsel   dw        ?                        ; 10: pozice zobraz. za‡ tku textu
pocpozsl db        ?                        ; 12: po‡ te‡n¡ pozice na displeji
pocradsl db        ?                        ; 13: © dek k zobrazen¡ textu
delkasel db        ?                        ; 14: ¨¡©ka © dku textu
atribsel db        ?                        ; 15: atribut barvy
                                          ;* parametry pro rolov n¡ oken
radkusel dw        ?                        ; 16: po‡et © dk– celkem
kurzsel  dw        ?                        ; 18: pozice kurzoru
firstsel dw        ?                        ; 20: prvn¡ zobrazen˜ © dek
zobrlsel db        ?                        ; 22: po‡et zobrazen˜ch © dk–

selbuf   db        129 dup(?)               ; buffer pro editaci p©i v˜bˆru
selbufz  db        129 dup(?)               ; buffer pro £schovu textu p©i ^O

public   rozbset,rozbflg,rozbnam,rozbext,rozbdat,rozbcas,rozbvel,rozbats
public   rozbatr,rozbend

rozbset  label     byte                     ; rozbor zad n¡ souboru
rozbflg  db        ?                        ;  0: p©¡znaky rozboru
                                            ;      bit 0: 1=men¨¡ jm‚no
                                            ;      bit 1: 1=vˆt¨¡ jm‚no
                                            ;      bit 2: 1=men¨¡ datum
                                            ;      bit 3: 1=vˆt¨¡ datum
                                            ;      bit 4: 1=men¨¡ ‡as
                                            ;      bit 5: 1=vˆt¨¡ ‡as
                                            ;      bit 6: 1=men¨¡ velikost
                                            ;      bit 7: 1=vˆt¨¡ velikost
rozbnam  db        8 dup(?)                 ;  1: jm‚no souboru
rozbext  db        3 dup(?)                 ;  9: p©¡pona jm‚na souboru
rozbdat  db        6 dup(?)                 ; 12: datum souboru
rozbcas  db        6 dup(?)                 ; 18: ‡as souboru
rozbvel  dd        ?                        ; 24: velikost souboru
rozbats  db        ?                        ; 28: nastavovan‚ atributy
rozbatr  db        ?                        ; 29: nulovan‚ atributy
rozbend  label     byte                     ; 30: konec bufferu rozboru

;normfil  db        20 dup(?)              ;* normalizovan˜ soubor
;                                            ; 0:  1 bajt - atributy
;                                            ; 1:  8 bajt– - jm‚no
;                                            ; 9:  3 bajty - p©¡pona
;                                            ; 12: 4 bajty - velikost
;                                            ; 16: 2 bajty - datum
;                                            ; 18: 2 bajty - ‡as

public   flagsc
flagsc   db        ?                      ;* indik tory pro diskov‚ operace
                                            ; bit 0,1: 0=kop¡rov n¡ soubor–
                                            ;          1=p©ejmenov n¡ soubor–
                                            ;          2=ru¨en¡ soubor–
                                            ;          3=atributy soubor–
                                            ; bit 2: 1=je operace s kurzorem
                                            ; bit 3: 1=p©i rozboru zad na te‡ka
                                            ; bit 4: 1=neprov. se dotaz p©episu
                                            ; bit 5: 0=s. se p©ep¡¨¡/1=p©esko‡¡
                                            ; bit 6: 1=neprov. se dotaz ochrany
                                            ; bit 7: 0=soub. se ru¨¡/1=p©esko‡¡

color    db        ?                        ; aktivn¡ barva textu
         db        ?                        ; (n sled. bajt slou‘¡ t‚‘ k PUSH)






                                          ;* ukazatele pro editaci p©¡kaz. © dku
numchar  db        0                        ; po‡et znak– v bufferu
poztop   db        0                        ; pozice za‡ tku zobrazen‚ho textu
pozcomm  db        0                        ; pozice za‡ tku textu na displeji
pozbuf   db        0                        ; pozice kurzoru v textov‚m bufferu
endadr   dw        offset endshell          ; adresa konce pamˆti (offset)


                                          ;* registry pro dek¢dov n¡ ‡¡sla
citdek   db        0                        ; ‡¡ta‡ platn˜ch ‡¡slic pro p©evod
citnum   db        0                        ; ‡¡ta‡ 1 ‡¡slice
parnum   db        0                        ; parametry pro dek¢dov n¡ ‡¡sla
                                            ;   bit 0=z kaz oddˆlovac¡ te‡ky
                                            ;   bit 1=tisk mezer
                                            ;   bit 2=tisk nul
                                            ;   bit 3=p©echodn˜ z kaz te‡ky
                                            ;   bit 4=z kaz tisku te‡ky tis¡c–

; -----------------------------------------------------------------------------
;                    Definice prav‚ho okna (okno ‡¡slo 1)
; -----------------------------------------------------------------------------
public   tabr,flagsr,adrtabr,pozr,adrpathr,numfr
public   cissegr,firstr,kurzr,alokr,celkr,volnr,soubr,zabr,setwr

TABR     label     byte                     ; tabulka definice prav‚ho okna
                                          ;* definice zobrazen¡ okna
flagsr   db        ?                        ; 0: indik tor stavu okna
                                            ;     bit 0: 1=okno je zapnuto
                                            ;     bit 1: 1=adres © je na‡ten
                                            ;     bit 2: 1=adres © se nenuluje
                                            ;     bit 3: 1=okno je zobrazeno
                                            ;     bit 4: 1=okno se net©¡d¡
                                            ;     bit 5: 1=t©¡dˆn¡ podle p©¡pony
                                            ;     bit 6: 1=t©¡dˆn¡ podle data a ‡asu
                                            ;     bit 7: 1=t©¡dˆn¡ podle velikosti

adrtabr  dw        ?                        ; 1: adresa lev‚ho okna
pozr     db        ?                        ; 3: po‡ te‡n¡ pozice okna
                                          ;* definice polo‘ek v seznamu
adrpathr dw        ?                        ; 4: adresa p©¡stupov‚ cesty k adres ©i
cissegr  db        ?                        ; 6: ‡¡slo segmentu seznamu polo‘ek
numfr    dw        ?                        ; 7: po‡et polo‘ek v seznamu
firstr   dw        ?                        ; 9: ‡¡slo prvn¡ zobrazen‚ polo‘ky
kurzr    dw        ?                        ; 11: ‡¡slo polo‘ky s kurzorem
                                          ;* parametry disku (dodr‘et po©ad¡ !)
alokr    dw        ?                        ; 13: velikost aloka‡n¡ho bloku
celkr    dd        ?                        ; 15: celkov  kapacita disku
volnr    dd        ?                        ; 19: voln  kapacita disku
soubr    dw        ?                        ; 23: po‡et soubor– v adres ©i
zabr     dd        ?                        ; 25: zabran  kapacita soubor–

setwr    db        ?                      ;* 29: nastaven¡ prav‚ho okna
                                            ; bit 0: 1=trojsloupc. zobrazen¡

; -----------------------------------------------------------------------------
;                   Definice lev‚ho okna (okno ‡¡slo 2)
; -----------------------------------------------------------------------------
public   tabl,flagsl,adrtabl,pozl,adrpathl,numfl
public   cissegl,firstl,kurzl,alokl,celkl,volnl,soubl,zabl,setwl

TABL     label     byte                     ; tabulka definice lev‚ho okna
                                          ;* definice zobrazen¡ okna
flagsl   db        ?                        ; 0: indik tor stavu okna
                                            ;     bit 0: 1=okno je zapnuto
                                            ;     bit 1: 1=adres © je na‡ten
                                            ;     bit 2: 1=adres © se nenuluje
                                            ;     bit 3: 1=okno je zobrazeno
                                            ;     bit 4: 1=okno se net©¡d¡
                                            ;     bit 5: 1=t©¡dˆn¡ podle p©¡pony
                                            ;     bit 6: 1=t©¡dˆn¡ podle data a ‡asu
                                            ;     bit 7: 1=t©¡dˆn¡ podle velikosti

adrtabl  dw        ?                        ; 1: adresa prav‚ho okna
pozl     db        ?                        ; 3: po‡ te‡n¡ pozice okna
                                          ;* definice polo‘ek v seznamu
adrpathl dw        ?                        ; 4: adresa p©¡stupov‚ cesty k adres ©i
cissegl  db        ?                        ; 6: ‡¡slo segmentu seznamu polo‘ek
numfl    dw        ?                        ; 7: po‡et polo‘ek v seznamu
firstl   dw        ?                        ; 9: ‡¡slo prvn¡ zobrazen‚ polo‘ky
kurzl    dw        ?                        ; 11: ‡¡slo polo‘ky s kurzorem
                                          ;* parametry disku (dodr‘et po©ad¡ !)
alokl    dw        ?                        ; 13: velikost aloka‡n¡ho bloku
celkl    dd        ?                        ; 15: celkov  kapacita disku
volnl    dd        ?                        ; 19: voln  kapacita disku
soubl    dw        ?                        ; 23: po‡et soubor– v adres ©i
zabl     dd        ?                        ; 25: zabran  kapacita soubor–

setwl    db        ?                      ;* 29: nastaven¡ lev‚ho okna
                                            ; bit 0: 1=trojsloupc. zobrazen¡

endtabw  label     byte                     ; n vˆ¨t¡ konce tabulek oken

; -----------------------------------------------------------------------------
public   numsrc,bufsrc

numsrc   db        ?                        ; po‡et znak– v bufferu vyhled v n¡
         db        ?                        ; atributy souboru (mus¡ b˜t = 0 !)
bufsrc   db        12 dup(?)                ; buffer pro rychl‚ vyhled v n¡

; -----------------------------------------------------------------------------

public   bufwin,adrnadp,bufnadp

bufwin   db        128 dup(?)               ; buffer pro okna
bufnadp  db        128 dup(?)               ; buffer nadpisu pro okna
adrnadp  dw        ?                        ; adresa nadpisu

public   buffedi
buffedi  db        13 dup(?)                ; ulo‘en‚ jm‚no editovan‚ho souboru

public   outbuf,outbuf4
outbuf   db        20 dup(?)                ; tiskov˜ (pracovn¡) buffer
outbuf1  db        20 dup(?)
outbuf2  db        20 dup(?)
outbuf3  db        100 dup(?)
outbuf4  db        100 dup(?)

public   outid,inpid,delkauk,poziceuk,blokuk,transuk

outid    dw        ?                        ; identifik tor v˜stupn¡ho souboru
inpid    dw        ?                        ; identifik tor vstupn¡ho souboru
ukazbuf  dw        ?                        ; ukazatel dat v diskov‚m buffer
numbuf   dw        ?                        ; po‡et bajt– v diskov‚m bufferu
maxdbuf  dw        ?                        ; velikost disk. bufferu
poziceuk db        ?                        ; po‡ te‡n¡ pozice ukazatele
delkauk  db        ?                        ; d‚lka ukazatele
blokuk   dd        ?                        ; velikost bloku ukazatele
transuk  dd        ?                        ; p©enesen  velikost dat


public   editmax,editnum,ediradek,edipoz,ediflag,edikurz,edidrad
public   firstrad,endrad,toppoz,adrradek,delkarad,edinormk,edikey
public   ediblkb,ediblkk
public   zobtop,zobukaz,zobnum,zobbuf,ediznac,edikeym,edikpoz,zobseg,zobadrs
public   zobmid,endpoz

zobtop   dd        ?                        ; adresa za‡ tku zobrazen‚ho textu
zobbuf   dd        ?                        ; ukazatel za‡ tku dat v bufferu
zobukaz  dd        ?                        ; ukazatel pro ‡ten¡ dat
zobnum   dd        ?                        ; celkov˜ po‡et bajt– v souboru

editmax  dw        ?                        ; velikost bufferu pro editaci
editnum  dw        ?                        ; po‡et bajt– souboru v pamˆti
zobseg   db        ?                        ; segment prohl¡‘e‡e
zobadrs  dw        ?                        ; adresa segmentu prohl¡‘e‡e
zobmid   dw        ?                        ; adresa prost©edku bufferu prohl¡‘.

                                          ;* data se vymaz vaj¡ cyklem
firstrad dw        ?                        ; adresa prvn¡ho © dku
endrad   dw        ?                        ; adresa posledn¡ho © dku
adrradek dw        ?                        ; adresa © dku s kurzorem
edikurz  dw        ?                        ; adresa kurzoru absolutnˆ
toppoz   dw        ?                        ; offset po‡ te‡n¡ pozice © dku rel.
endpoz   dw        ?                        ; offset koncov‚ pozice © dku rel.
ediradek dw        ?                        ; ‡¡slo © dku
edipoz   dw        ?                        ; pozice na © dku uchovan 
edikpoz  dw        ?                        ; pozice na © dku skute‡n 
edidrad  db        ?                        ; © dek na displeji

delkarad dw        ?                        ; d‚lka © dku s kurzorem

edikey   dw        ?                        ; uschovan  kl vesa
edikeym  dw        ?                        ; kl vesa od my¨i


edinormk dw        ?                        ; uschovan˜ vhled kurzoru

public   countryh
countryh dd        ?                        ; adresa rutiny pro p©evod p¡smen

public   envexec,adrfl,adrfr,numdskl,konecmaz

envexec  db        ?

adrfl    dw        ?
adrfr    dw        ?
numdskl  db        ?

public   findcit,findsouc
findcit  dw        ?                        ; ‡¡ta‡ nalezen˜ch soubor–
findsouc dd        ?                        ; sou‡et velikost¡ soubor–

public   hlpseg,hlpnum,hlptop,hlpkurz,helpbuf
hlpseg   dw        ?                        ; segment s n povˆdou
hlpnum   dw        ?                        ; po‡et bajt– n povˆdy v pamˆti

konecmaz label     byte                     ; konec maz n¡ dat

public   buffail
buffail  db        300 dup(?)               ; buffer pro hl ¨en¡ chyby INT 24h
helpbuf  db        1024 dup(?)              ; buffer pro n povˆdu
;diskbuf  db        2048 dup(?)              ; diskov˜ buffer
;videoram dw        80*25*2 dup(?)           ; buffer pro £schovu obrazovky

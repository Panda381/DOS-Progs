
; *****************************************************************************
;
;         Konstanty - data s konstantn¡ hodnotou (jsou sou‡ st¡ souboru)
;
; *****************************************************************************
public   textsp1,textsp2,textsp20,textsp21
public   textsp22,textsp23,textsp3,textsp30,textsp31,textsp32,textsp4

public   textcek
public   erroper

textcek  db        8,' CEKEJTE ! ',0

public   texthlpb
texthlpb db        7,' bajt',0

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

public   txtsel,txtunsel,txtmov1,txtcop1,txtcop2,txtcop3,txtmov2
;public   txtedis

txtsel   db        ' vybrat soubory: ',0
txtunsel db        ' zrusit vyber souboru: ',0
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

txtkon1  db        31,'Chcete ukoncit program ',10,'Mikro Manazer',7,' ?',0
txtkon2  db        'Ano',0,'Ne',0,0

txtpovel db        ' Historie prikazu: ',0

txtdisk1 db        ' Zmena disku pro ',10,0
txtdisk2 db        'leve',0
txtdisk3 db        'prave',0
txtdisk4 db        7,' okno: ',0

public   txtchyb1,txtchyb

txtchyb  db        8,' CHYBA ',7,31,0
txtchyb1 db        'OK',0,0

public   txtfail,txtfai0,txtfai2,txtfai8,txtfaic,txtfaic2,volbfail
public   txtfai4

txtfail  db        8,' CHYBA ZARIZENI ! ',7,31,0
txtfai0  db        'Disk ma ochranu proti zapisu !',0
txtfai2  db        'Disk neni pripraven (neuzavrena mechanika) !',0
txtfai4  db        'Vadny sektor disku (chyba dat) !',0
txtfai8  db        'Sektor nenalezen !',0
txtfaic  db        'Neznama chyba ...',31
         db        'kod=',0
txtfaic2 db        ',typ=',0

volbfail db        'Opakovat',0
         db        'Prerusit',0
         db        'Ignorovat',0
         db        0

errdel1  db        7,'Soubor ',10,0
errdir1  db        7,'Adresar ',10,0
errdir2  db        7,' nelze zrusit',0
errdir3  db        7,'Adresar musi byt prazdny !',0
errdir6  db        7,' !',0
errdel2  db        ',',31,'protoze ma ochranu proti zapisu !',31,31
errdel3  db        'Chcete jej i presto zrusit ?',0
errcop1  db        'Chybne zadani adresare nebo disku !',0
errcop2  db        'Nelze ',0
errcop21 db        'kopirovat',0
errcop22 db        'presouvat',0
errcop25 db        ' vice souboru do jednoho !',0
;errcop3  db        'Soubor nelze kopirovat sam do sebe !',0
errcop4  db        7,' jiz existuje !',31
         db        'Chcete jej prepsat ?',0
errcop5  db        'Na disku ',10,0
errcop51 db        7,' neni dost volneho mista !',0
erroper  db        'Operaci nelze provest !',0
erredi5  db        'Disk plny - soubor zrusen !',0

public   erredi5
public   txtedi8,erredi1,edivolb2

txtedi8  db        31,'Soubor byl modifikovan. Chcete jej ulozit ?',0
erredi1  db        'Soubor je prilis velky !',0

edivolb2 db        'Ulozit',0
         db        'Neukladat',0
         db        'Pokracovat',0
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

txthelp:
         db        9,'1',3,'Leve  '         ; F1
         db        9,' 2',3,'Prave '        ; F2
         db        9,' 3',3,'Zobraz'        ; F3
         db        9,' 4',3,'Edituj'        ; F4
         db        9,' 5',3,'Kopie '        ; F5
         db        9,' 6',3,'Presun'        ; F6
         db        9,' 7',3,'Vytvor'        ; F7
         db        9,' 8',3,'Zrusit'        ; F8
         db        9,' 9',3,'Prikaz'        ; F9
         db        9,' 10',3,'Konec '       ; F10
         db        0

public   errmem
errmem   db        'Nedostatek pameti !',13,10,'$'

public   nadadr,rootdir,all,nuldir
nadadr   db        "..",0                   ; ozna‡en¡ nadadres ©e
rootdir  db        '\',0                    ; ozna‡en¡ hlavn¡ho adres ©e
all      db        '*.*',0                  ; ozna‡en¡ - v¨echny soubory
nuldir   db        0                        ; nulov˜ adres ©

extent   db        'EXECOMBAT'              ; povolen‚ extenty

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


; *****************************************************************************
;
;    Neinicializovan  data -  nejsou sou‡ st¡ MNS.COM a z–st vaj¡ v pamˆti
;
; *****************************************************************************
public   zacmaz,path,namel,namer,firstwl,firstwr
public   inidend

zacmaz   label     byte                     ; odtuto se pamˆŸ vyma‘e p©i inic.

path     db        '$',69 dup(?)            ; cesta k neaktivn¡mu oknu

namel    db        20 dup(?)                ; p©edvolen‚ jm‚no souboru L
namer    db        20 dup(?)                ; p©edvolen‚ jm‚no souboru R
firstwl  dw        ?                        ; uchovan  pozice lev‚ho okna
firstwr  dw        ?                        ; uchovan  pozice prav‚ho okna


public   historie,histor1,histor2,histor3,histor4,delhist
historie label     byte                   ;* historie povel–
         dw        ?                        ; d‚lka bufferu
histor1  db        130 dup(?)               ; buffer
histor2  db        ?                        ; po‡et p©edvoleb
histor3  dw        ?                        ; p©edvolba 1
histor4  dw        ?                        ; p©edvolba 2
delhist  equ       histor2-histor1          ; d‚lka bufferu historie

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

inidend  label     byte                     ; adresa konce rezidentn¡ch dat

; *****************************************************************************
;
;         Neinicializovan  data pracovn¡ - p©i startu programu se ru¨¡
;
; *****************************************************************************
public   zasob,topseg,segend,seznseg,pathr,pathl
public   datseg,verze
public   zacmazr

zacmazr  label     byte                     ; odtuto se pamˆŸ vyma‘e p©i reinic.

verze    dw        ?                        ; ‡¡slo verze opera‡n¡ho syst‚mu
zasob    dw        ?                        ; vrchol z sobn¡ku SP

                                          ;* data pro obsluhu pamˆti
datseg   dw        ?                        ; za‡ tek aloka‡n¡ho bloku dat
topseg   dw        ?                        ; segment za‡ tku voln‚ pamˆti
segend   dw        ?                        ; segment konce voln‚ pamˆti
seznseg  dw        10 dup(?)                ; seznam segment– adres
seznseg0 label     byte                     ; konec seznamu

pathr    db        70 dup(?)                ; cesta k prav‚mu adres ©i
pathl    db        70 dup(?)                ; cesta k lev‚mu adres ©i

public   parint,old23,old1b

parint   db        ?                        ; p©¡znak obsluh p©eru¨en¡
                                            ;   bit 0: je aktivn¡ INT 08h
                                            ;   bit 1: je aktivn¡ INT 10h
                                            ;   bit 2: je aktivn¡ INT 24h
                                            ;   bit 3: hled n¡ souboru ALT-F7
                                            ;   bit 4: prov d¡ se zobrazen¡ F3
                                            ;   bit 5: prov d¡ se editace F4
                                            ;   bit 6: prob¡h  zobrazen¡ ‡asu
                                            ;   bit 7: povoleno zobrazen¡ ‡asu
old1b    dd        ?                        ; p–vodn¡ adresa obsluhy INT 1Bh
old23    dd        ?                        ; p–vodn¡ adresa obsluhy INT 23h

public   aktpage
public   adrvram,segvram,citdek,citnum,aktkurz
public   parnum,color,cisvram,displ,delvram
                                          ;* £schova p–vodn¡ho m¢du displeje
aktpage  db        ?                        ; aktivn¡ str nka displeje
adrvram  dw        ?                        ; adresa za‡ tku str nky ve VRAM
segvram  dw        ?                        ; segment videopamˆti
aktkurz  dw        ?                        ; £schova p–vodn¡ho kurzoru
cisvram  db        ?                        ; ‡¡slo segmentu s VRAM
delvram  dw        ?                        ; d‚lka bufferu s uschovanou VRAM
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
public   radkusel,kurzsel,firstsel,zobrlsel,selbuf

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
public   cissegr,firstr,kurzr,alokr,celkr,volnr,soubr,zabr

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

; -----------------------------------------------------------------------------
;                   Definice lev‚ho okna (okno ‡¡slo 2)
; -----------------------------------------------------------------------------
public   tabl,flagsl,adrtabl,pozl,adrpathl,numfl
public   cissegl,firstl,kurzl,alokl,celkl,volnl,soubl,zabl

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

endtabw  label     byte                     ; n vˆ¨t¡ konce tabulek oken


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
outbuf4  db        100 dup(?)

public   outid,inpid

outid    dw        ?                        ; identifik tor v˜stupn¡ho souboru
inpid    dw        ?                        ; identifik tor vstupn¡ho souboru
ukazbuf  dw        ?                        ; ukazatel dat v diskov‚m buffer
numbuf   dw        ?                        ; po‡et bajt– v diskov‚m bufferu
maxdbuf  dw        ?                        ; velikost disk. bufferu


public   editmax,editnum,ediradek,edipoz,ediflag,edikurz,edidrad
public   firstrad,endrad,toppoz,adrradek,delkarad,edikey
public   zobtop,zobukaz,zobnum,zobbuf,edikpoz,zobseg,zobadrs
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


public   adrfl,adrfr,numdskl,konecmaz


adrfl    dw        ?
adrfr    dw        ?
numdskl  db        ?



konecmaz label     byte                     ; konec maz n¡ dat


public   buffail
buffail  db        130 dup(?)               ; buffer pro hl ¨en¡ chyby INT 24h

public   zasobrez
         dw        80 dup (0)               ; z sobn¡k pro rezidentn¡ modul
zasobrez label     word                     ; z sobn¡k


; *****************************************************************************
;
;         Konstanty - data s konstantn° hodnotou (jsou souá†st° souboru)
;
; *****************************************************************************

public   texthlp,textsp1,textsp2,textsp20,textsp21
public   textsp22,textsp23,textsp3,textsp30,textsp31,textsp32,textsp4
public   txthlped,txthlpzo

public   zactxt,konectxt,textcek
public   erredi1,erroper


zactxt   label     byte                   ;* zaá†tek textñ

IFDEF    slov
texthlp  db        3,' <F1>=n†poveda ',0    ; n†povàda
textcek  db        8,' ÄAKAJTE ! ',0
ELSE
texthlp  db        3,' <F1>=n†povàda ',0    ; n†povàda
textcek  db        8,' ÄEKEJTE ! ',0
ENDIF

public   texthlp1,texthlp2,texthlp3,texthlp4,texthlp5,volbhlp1,texthlp6
IFDEF    slov
texthlp1 db        ' Z†kladnÇ inform†cie ',31,31
         db        10,'DOS ManaëÇr',7,' - verzia 1.'
ELSE
texthlp1 db        ' Z†kladn° informace ',31,31
         db        10,'DOS Manaëer',7,' - verze 1.'
ENDIF
ifndef   upver
         db        '22',31
else
         db        '30',31
endif

IFDEF    slov
ifdef    demo
         db        10,'Demonstraán† verzia',7,' (d† sa voåne ®°riü)',0
else
         db        'Licencia  ',10,0
endif
ELSE
ifdef    demo
         db        10,'Demonstraán° verze',7,' (lze volnà ®°©it)',0
else
         db        'Licence  ',10,0
endif
ENDIF

texthlp6:
         db        7,31,'(c) Miroslav Nàmeáek',31,31

         db        ' ≤≤≤≤≤ ≤≤≤≤≤ ≤     ≤≤≤≤≤ ≤   ≤ ',31
         db        ' ≤∞∞∞∞∞≤∞∞∞≤∞≤∞    ≤∞∞∞∞∞≤≤≤≤≤∞',31
         db        ' ≤∞ ≤≤ ≤∞  ≤∞≤∞    ≤≤≤   ≤∞≤∞≤∞',31
         db        ' ≤∞  ≤∞≤∞  ≤∞≤∞    ≤∞∞∞  ≤∞ ∞≤∞',31
         db        ' ≤≤≤≤≤∞≤≤≤≤≤∞≤≤≤≤≤ ≤≤≤≤≤ ≤∞  ≤∞',31
         db        '  ∞∞∞∞∞ ∞∞∞∞∞ ∞∞∞∞∞ ∞∞∞∞∞ ∞   ∞',31,31,0

texthlp3 db        'Dnes je ',0
texthlp4 db        ', ',0

IFDEF    slov
texthlp5 db        31,'Veåkosü pamÑti: ',10,0
texthlp2 db        31,'Voån† pamÑü: ',10,0
volbhlp1 db        'ZakladnÇ voåby n†povedy',0
ELSE
texthlp5 db        31,'Velikost pamàti: ',10,0
texthlp2 db        31,'Voln† pamàü: ',10,0
volbhlp1 db        'Z†kladn° volby n†povàdy',0
ENDIF
         db        0

public   texthlpb

texthlpb db        7,' bajt',0

public   dny,mesice

IFDEF    slov
dny      label     word
         db        'nedeåa',0
         db        'pondelok',0
         db        'utorok',0
         db        'streda',0
         db        '®tvrtok',0
         db        'piatok',0
         db        'sobota',0
         db        0

mesice   label     word
         db        'janu†ra',0
         db        'febru†ra',0
         db        'marca',0
         db        'apr°la',0
         db        'm†ja',0
         db        'j£na',0
         db        'j£la',0
         db        'augusta',0
         db        'septembra',0
         db        'okt¢bra',0
         db        'novembra',0
         db        'decembra',0
         db        0
ELSE
dny      label     word
         db        'nedàle',0
         db        'pondàl°',0
         db        '£terò',0
         db        'st©eda',0
         db        'átvrtek',0
         db        'p†tek',0
         db        'sobota',0
         db        0

mesice   label     word
         db        'ledna',0
         db        '£nora',0
         db        'b©ezna',0
         db        'dubna',0
         db        'kvàtna',0
         db        'áervna',0
         db        'áervence',0
         db        'srpna',0
         db        'z†©°',0
         db        '©°jna',0
         db        'listopadu',0
         db        'prosince',0
         db        0
ENDIF
textsp1  db        1,' bajt',0
IFDEF    slov
textsp2  db        ' voån',0
textsp20 db        98h,0                    ; koncovka "ò"
textsp21 db        82h,0                    ; koncovka "Ç"
textsp22 db        'òch',0
textsp23 db        ' z ',2,0

textsp3  db        1,' s£bor',0
textsp30 db        ' zaber',0
textsp31 db        '† ',2,0
textsp32 db        'aj£ ',2,0
textsp4  db        1,' bajt',0
ELSE
textsp2  db        ' voln',0
textsp20 db        98h,0                    ; koncovka "ò"
textsp21 db        82h,0                    ; koncovka "Ç"
textsp22 db        'òch',0
textsp23 db        ' z ',2,0

textsp3  db        1,' soubor',0
textsp30 db        ' zab°r',0
textsp31 db        '† ',2,0
textsp32 db        'aj° ',2,0
textsp4  db        1,' bajt',0
ENDIF


public   textvy1,textvy11,textvy12,textvy13,textvy14,textvy2,textvy21,textvy22

IFDEF    slov
textvy1  db        1,' bajt',0
textvy11 db        'y',0                    ; koncovka "y"
textvy12 db        'ov',0                   ; koncovka "ov"
textvy13 db        ' v ',2,0
textvy14 db        ' v ',2,0

textvy2  db        1,' s£bor',0
textvy21 db        'e ',0
textvy22 db        'och ',0
ELSE
textvy1  db        1,' bajt',0
textvy11 db        'y',0                    ; koncovka "y"
textvy12 db        96h,0                    ; koncovka "ñ"
textvy13 db        ' v ',2,0
textvy14 db        ' ve ',2,0

textvy2  db        1,' soubor',0
textvy21 db        'u ',0
textvy22 db        'ech ',0
ENDIF

ifdef    upver
public   txtcom1,txtcom2,txtcom3,txtcom4,txtcom5,txtcom6,txtcom7,txtcom8
public   txtcom9,txtcoma

IFDEF    slov
txtcom1  db        ' Vy®lem ',0
txtcom2  db        ' na komunikaánò port: ',0
txtcom3  db        ' Budem prij°maü s£bory z komunikaánÇho portu: ',0
txtcom4  db        8,' ÄAKAJTE ',31,7,' NadvÑzujem spojenie cez port ',10,'COM'
txtcom6  db        '1:',7,31,31,'<Esc>=preru®enie oper†cie',0
txtcom7  db        'Vysielam',0
txtcom8  db        'Prij°mam',0
txtcom9  db        7,' na port ',10,'COM'
ELSE
txtcom1  db        ' Vy®lu ',0
txtcom2  db        ' na komunikaán° port: ',0
txtcom3  db        ' Budu p©ij°mat soubory z komunikaán°ho portu: ',0
txtcom4  db        8,' ÄEKEJTE ',31,7,' Navazuji spojen° p©es port ',10,'COM'
txtcom6  db        '1:',7,31,31,'<Esc>=p©eru®en° operace',0
txtcom7  db        'Vys°l†m',0
txtcom8  db        'P©ij°m†m',0
txtcom9  db        7,' na port ',10,'COM'
ENDIF
txtcoma  db        '1:',0

txtcom5  db        '1 COM1',0
         db        '2 COM2',0
         db        '3 COM3',0
         db        '4 COM4',0
         db        0
endif

public   txtsel,txtunsel,txtmov1,txtcop1,txtcop2,txtcop3,txtmov2,txthled
public   txthled3,txthled6,txtedis

IFDEF    slov
txtsel   db        ' vybraü s£bory: ',0
txtunsel db        ' zru®iü vòber s£borov: ',0
txthled  db        ' S£bor k vyhåadaniu: ',0
txtmov1  db        ' Premenujem/presuniem ',0
txtmov2  db        ' Premenujem ',0
txtcop1  db        ' Skop°rujem ',0
txtcop2  db        ' na: ',0
txtcop5  db        'Kop°rujem',0
txtmov5  db        'Pres£vam',0
txtmov6  db        'Premenov†vam',0
txtmov7  db        7,' na ',10,0
txtcop6  db        7,' do ',10,0
txtcop3  db        ' oznaáen',0
txtvyt1  db        ' Vytvor°m adres†r: ',0
txtvyt2  db        7,'Vytv†ram adres†r ',10,0
txtvar   db        8,' VAROVANIE ',7,31,0
txtdel1  db        'Zru®°m ',0
txtdel3  db        ' !',0
txtadr   db        'adres†r',0
txtdel2  db        'Ru®°m',0
txthled3 db        7,' Håad†m ',10,0
txthled6 db        31,'S£bor podåa zadanej ®pecifik†cie nen†jdenò !',0
txtedis  db        ' Zadajte meno editovanÇho s£boru: ',0
ELSE
txtsel   db        ' vybrat soubory: ',0
txtunsel db        ' zru®it vòbàr souborñ: ',0
txthled  db        ' Soubor k vyhled†n°: ',0
txtmov1  db        ' P©ejmenuji/p©esunu ',0
txtmov2  db        ' P©ejmenuji ',0
txtcop1  db        ' Zkop°ruji ',0
txtcop2  db        ' na: ',0
txtcop5  db        'Kop°ruji',0
txtmov5  db        'P©esouv†m',0
txtmov6  db        'P©ejmenov†v†m',0
txtmov7  db        7,' na ',10,0
txtcop6  db        7,' do ',10,0
txtcop3  db        ' oznaáen',0
txtvyt1  db        ' Vytvo©°m adres†©: ',0
txtvyt2  db        7,'Vytv†©°m adres†© ',10,0
txtvar   db        8,' VAROVèNã ',7,31,0
txtdel1  db        'Zru®°m ',0
txtdel3  db        ' !',0
txtadr   db        'adres†©',0
txtdel2  db        'Ru®°m',0
txthled3 db        7,' Hled†m ',10,0
txthled6 db        31,'Soubor podle zadanÇ specifikace nenalezen !',0
txtedis  db        ' Zadejte jmÇno editovanÇho souboru: ',0
ENDIF

IFDEF    slov
txtkon1  db        31,'Chcete ukonáiü program ',10,'DOS ManaëÇr',7,' ?',0
txtkon2  db        'Ano',0,'Ne',0,0

txtpovel db        ' Hist¢ria pr°kazov: ',0

public   txtmen
txtmen   db        ' Zvoåte poëadovan£ oper†ciu: ',0

txtdisk1 db        ' Zvoåte novò disk pre ',10,0
txtdisk2 db        'åavÇ',7,' okno: ƒ',0
txtdisk3 db        'pravÇ',7,' okno: ',0
;txtdisk4 db        7,' okno: ',0
ELSE
txtkon1  db        31,'Chcete ukonáit program ',10,'DOS Manaëer',7,' ?',0
txtkon2  db        'Ano',0,'Ne',0,0

txtpovel db        ' Historie p©°kazñ: ',0

public   txtmen
txtmen   db        ' Zvolte poëadovanou operaci: ',0

txtdisk1 db        ' Zvolte novò disk pro ',10,0
txtdisk2 db        'levÇ',7,' okno: ƒ',0
txtdisk3 db        'pravÇ',7,' okno: ',0
;txtdisk4 db        7,' okno: ',0
ENDIF

public   txtchyb1,txtmenu,txtchyb,soubmen,errhlp1,txthlp1,soubext

IFDEF    slov
errhlp1  db        7,'S£bor n†povedy "',10,'DOSMAN.HLP'
         db        7,'" nen†jdenò !',0

txtmenu  db        7,'S£bor uëivateåskòch volieb "',10,'DOSMAN.MNU'
         db        7,'" nen†jdenò !',0
txtnfnd  db        31,7,'íiaden s£bor nen†jdenò !',0
txtchyb  db        8,' CHYBA ',7,31,0
txtchyb1 db        'OK',0,0
ELSE
errhlp1  db        7,'Soubor n†povàdy "',10,'DOSMAN.HLP'
         db        7,'" nenalezen !',0

txtmenu  db        7,'Soubor uëivatelskòch voleb "',10,'DOSMAN.MNU'
         db        7,'" nenalezen !',0
txtnfnd  db        31,7,'í†dnò soubor nenalezen !',0
txtchyb  db        8,' CHYBA ',7,31,0
txtchyb1 db        'OK',0,0
ENDIF

public   txtfail,txtfai0,txtfai2,txtfai7,txtfai8,txtfaic,txtfaic2,volbfail
public   txtfaid,txtfai4,txtfaifa,txtfaidi

IFDEF    slov
txtfail  db        8,' CHYBA ZARIADENIA ! ',7,31,0
txtfai0  db        'Pok£®ate sa zapisovaü na disketu, ktor†',31
         db        'm† nastaven£ ochranu proti z†pisu !',0
txtfai2  db        'V disketovej mechanike nieje vloëen† disketa',31
         db        'alebo dvierka niesu zavretÇ !',0
txtfai4  db        'Vadnò sektor diskety (chyba d†t) !',0
txtfai7  db        'Disketa m† nezn†my form†t !',0
txtfai8  db        'Sektor nebol n†jdenò !',0
txtfaic  db        'Chyba sa ned† blië®ie ®pecifikovaü.',31
         db        'k¢d chyby=',0
txtfaic2 db        ',typ chyby=',0
txtfaid  db        'Poru®enÇ zdieåanie s£borov !',0
txtfaifa db        'Chybn† tabuåka FAT diskety !',0
txtfaidi db        'Vadnò adres†r diskety !',0

volbfail db        'Opakovaü',0
         db        'Preru®iü',0
         db        'Ignorovaü',0
ELSE
txtfail  db        8,' CHYBA ZAûãZENã ! ',7,31,0
txtfai0  db        'Pokou®°te se zapisovat na disketu, kter†',31
         db        'm† nastavenu ochranu proti z†pisu !',0
txtfai2  db        'V disketovÇ mechanice nen° vloëena disketa',31
         db        'nebo dv°©ka nejsou uzav©ena !',0
txtfai4  db        'Vadnò sektor diskety (chyba dat) !',0
txtfai7  db        'Disketa m† nezn†mò form†t !',0
txtfai8  db        'Sektor nebyl nalezen !',0
txtfaic  db        'Chybu nelze bl°ëe specifikovat.',31
         db        'k¢d chyby=',0
txtfaic2 db        ',typ chyby=',0
txtfaid  db        'Poru®eno sd°len° souborñ !',0
txtfaifa db        'Chybn† tabulka FAT diskety !',0
txtfaidi db        'Vadnò adres†© diskety !',0

volbfail db        'Opakovat',0
         db        'P©eru®it',0
         db        'Ignorovat',0
ENDIF
         db        0


public   txtcomp1,txtcomp4

IFDEF    slov
txtcomp1 db      7,' KtorÇ s£bory chcete pri porovn†van° adres†rov oznaáiü ? ',0
;txtcomp1 db        7,' Zvolte £rove§ porovn†n° adres†©ñ: ',0

txtcomp4 db        'Aktu†lne',0
         db        'Nov®ie',0
         db        'DoplnkovÇ',0
         db        'ZhodnÇ',0
         db        'Rozdielne',0
         db        0
ELSE
txtcomp1 db        7,' KterÇ soubory chcete p©i porovn†n° adres†©ñ oznaáit ? ',0
;txtcomp1 db        7,' Zvolte £rove§ porovn†n° adres†©ñ: ',0

txtcomp4 db        'Aktu†ln°',0
         db        'Novàj®°',0
         db        'Dopl§kovÇ',0
         db        'ShodnÇ',0
         db        'Rozd°lnÇ',0
         db        0
ENDIF

IFDEF    slov
ifdef    upver
txtatr1  db        ' ',10,'D',7,' d†tum; ',10,'T',7,' áas; atrib£ty nastav '
         db        10,'ASHR',7
         db        ', nuluj ',10,'ashr',7,', zobraz ',10,'+ -',7,' ',0
else
txtatr1  db        ' Atrib£ty: nastaviü ',10,'ASHR',7
         db        ', nulovaü ',10,'ashr',7,', zobraziü ',10,'+ -',7,' ',0
endif
txtatr7  db        'Nastavujem',0
txtatr8  db        'Nulujem',0
txtatr9  db        ' atrib£ty',0
txtatra  db        7,' s£boru ',10,0
txtatrb  db        7,' adres†ra ',10,0

txtwin1  db        7,' Nastavte kå£á pre triedenie adres†ra: ',0

txtwin5  db        'Meno',0
         db        'Pr°pona',0
         db        'D†tum a áas',0
         db        'Veåkosü',0
         db        'Netriediü',0
ELSE
ifdef    upver
txtatr1  db        ' ',10,'D',7,' datum; ',10,'T',7,' áas; atributy nastav '
         db        10,'ASHR',7
         db        ', nuluj ',10,'ashr',7,', zobraz ',10,'+ -',7,' ',0
else
txtatr1  db        ' Atributy: nastavit ',10,'ASHR',7
         db        ', nulovat ',10,'ashr',7,', zobrazit ',10,'+ -',7,' ',0
endif
txtatr7  db        'Nastavuji',0
txtatr8  db        'Nuluji',0
txtatr9  db        ' atributy',0
txtatra  db        7,' souboru ',10,0
txtatrb  db        7,' adres†©e ',10,0

txtwin1  db        7,' Nastavte kl°á pro t©°dàn° adres†©e: ',0

txtwin5  db        'JmÇno',0
         db        'P©°pona',0
         db        'Datum a áas',0
         db        'Velikost',0
         db        'Net©°dit',0
ENDIF
         db        0

IFDEF    slov
errdel1  db        7,'S£bor ',10,0
errdir1  db        7,'Adres†r ',10,0
errdir2  db        7,' sa ned† zru®iü',0
errdir3  db        7,'Adres†r mus° byü pr†zdny !',0
;errdir4  db        7,' uë existuje !',0
;errdir5  db        7,'Existuje uë s£bor ',10,0
errdir6  db        7,' !',0
errdel2  db        ',',31,'pretoëe m† ochranu proti z†pisu !',31,31
errdel3  db        'Chcete ho i tak zru®iü ?',0
errcop1  db        'ChybnÇ zadanie adres†ra alebo disku !',0
errcop2  db        'Ned† sa ',0
errcop21 db        'kop°rovaü',0
errcop22 db        'pres£vaü',0
errcop25 db        ' viac s£borov do jednÇho !',0
errcop3  db        'S£bor sa ned† kop°rovaü s†m do seba !',0
errcop4  db        7,' uë existuje !',31
         db        'Chcete ho prep°saü ?',0
errcop5  db        'Na disku ',10,0
errcop51 db        7,' nieje dostatok voånÇho miesta !',0
erroper  db        'Oper†cia sa ned† previesü !',0
erredi2  db        7,31,'Nedostatok miesta v pamÑti !',0
erredi3  db        31,'Håadanò text "',10,0
erredi4  db        7,'" nen†jdenò !',0
erredi5  db        'Nedostatok miesta na disku - s£bor byl zru®enò !',0
erredi6  db        'ChybnÇ zadanie s£boru !',0
ELSE
errdel1  db        7,'Soubor ',10,0
errdir1  db        7,'Adres†© ',10,0
errdir2  db        7,' nelze zru®it',0
errdir3  db        7,'Adres†© mus° bòt pr†zdnò !',0
;errdir4  db        7,' jië existuje !',0
;errdir5  db        7,'Existuje jië soubor ',10,0
errdir6  db        7,' !',0
errdel2  db        ',',31,'protoëe m† ochranu proti z†pisu !',31,31
errdel3  db        'Chcete jej i p©esto zru®it ?',0
errcop1  db        'ChybnÇ zad†n° adres†©e nebo disku !',0
errcop2  db        'Nelze ',0
errcop21 db        'kop°rovat',0
errcop22 db        'p©esouvat',0
errcop25 db        ' v°ce souborñ do jednoho !',0
errcop3  db        'Soubor nelze kop°rovat s†m do sebe !',0
errcop4  db        7,' jië existuje !',31
         db        'Chcete jej p©epsat ?',0
errcop5  db        'Na disku ',10,0
errcop51 db        7,' nen° dostatek volnÇho m°sta !',0
erroper  db        'Operaci nelze provÇst !',0
erredi2  db        7,31,'Nedostatek m°sta v pamàti !',0
erredi3  db        31,'Hledanò text "',10,0
erredi4  db        7,'" nenalezen !',0
erredi5  db        'Nedostatek m°sta na disku - soubor byl zru®en !',0
erredi6  db        'ChybnÇ zad†n° souboru !',0
ENDIF

public   txtedi1,txtedi2,txtedi3,txtedi4,txtedi5,txtedi6,erredi2,txtedi7
public   erredi3,erredi4,txtedi8,edivolb2,erredi5,erredi6,txtedi9,txtedia
public   txtedib,txtedif1,edivolb3,txtedif2,edivolb4,txtedic,txtedid,txtedie
public   txtedif,txtzob5,txtzob6,txtzob7,txtzob8,txtzob9,txtzob10
public   txtzob11,txtzob12,txtzob13,txtzob14

txtzob11 db        '*BAD*',0
txtzob12 db        '<END>',0
txtzob13 db        '*BAD',0
txtzob14 db        '<END',0
IFDEF    slov
txtzob5  db        'Blok:',0
txtzob6  db        'Sektor:',0
txtzob7  db        '  BOOT',0
txtzob8  db        '  FAT1',0
txtzob9  db        '  ROOT',0
txtzob10 db        ' Zadajte á°slo noveho alokaánÇho bloku: ',0
txtedi1  db        'VoånÇ:',0
txtedi2  db        'Riad.:',0
txtedi3  db        'Poz°c.:',0
txtedi4  db        'Offset:',0
txtedi5  db        'EOL',0
txtedi6  db        'EOF',0
txtedi7  db        ' Zadajte håadanò text: ',0
txtedi8  db        31,'S£bor byl modifikovanò. Chcete ho uloëiü ?',0
txtedi9  db        ' S£bor uloë°m ako: ',0
txtedia  db        ' Oznaáenò blok uloë°m ako: ',0
txtedib  db        ' Naá°tam ako blok s£bor: ',0
txtedic  db        ' ',10,'U',7,'=nerozli®uj, ',10,'B',7,'=spÑü, '
         db        10,'W',7,'=slovo, ',10,'G',7,'=s£bor, ',10,'L',7,'=blok'
txtedid  db        ', ',10,'N',7,'=bez ot†zky ',0
txtedie  db        ' Zadajte text, ktoròm m† byü n†jdenò text nahradenò: ',0
erredi1  db        'S£bor sa nenaá°tal do pamÑti celò !',0
txtedif  db        3,'Chcete n†jdenò text nahradiü ? '
         db        '(',4,'A',3,'no/',4,'N',3,'e/',4,'V',3,'®etky/'
         db        4,'Esc',3,')',0

txtedif1 db        ' V oznaáenom bloku zmen°m ás. fonty: ',0

txtedif2 db        ' V oznaáenom bloku prevediem zmenu na: ',0
ELSE
txtzob5  db        'Blok:',0
txtzob6  db        'Sektor:',0
txtzob7  db        '  BOOT',0
txtzob8  db        '  FAT1',0
txtzob9  db        '  ROOT',0
txtzob10 db        ' Zadejte á°slo novÇho alokaán°ho bloku: ',0
txtedi1  db        'VolnÇ:',0
txtedi2  db        'û†dek:',0
txtedi3  db        'Pozice:',0
txtedi4  db        'Offset:',0
txtedi5  db        'EOL',0
txtedi6  db        'EOF',0
txtedi7  db        ' Zadejte hledanò text: ',0
txtedi8  db        31,'Soubor byl modifikov†n. Chcete jej uloëit ?',0
txtedi9  db        ' Soubor uloë°m jako: ',0
txtedia  db        ' Oznaáenò blok uloë°m jako: ',0
txtedib  db        ' Naátu jako blok soubor: ',0
txtedic  db        ' ',10,'U',7,'=nerozli®uj, ',10,'B',7,'=zpàt, '
         db        10,'W',7,'=slovo, ',10,'G',7,'=soubor, ',10,'L',7,'=blok'
txtedid  db        ', ',10,'N',7,'=bez dotazu ',0
txtedie  db        ' Zadejte text, kteròm m† bòt nalezenò text nahrazen: ',0
erredi1  db        'Soubor se nenaáetl do pamàti celò !',0
txtedif  db        3,'Chcete nalezenò text nahradit ? '
         db        '(',4,'A',3,'no/',4,'N',3,'e/',4,'V',3,'®echny/'
         db        4,'Esc',3,')',0

txtedif1 db        ' V oznaáenÇm bloku zmàn°m áeskÇ fonty: ',0

txtedif2 db        ' V oznaáenÇm bloku provedu zmànu na: ',0
ENDIF

IFDEF    slov
edivolb2 db        'Uloëiü',0
         db        'Neukladaü',0
         db        'Pokraáovaü',0
         db        0

edivolb3 db        '1:KAM>bez',0
         db        '2:KAM>LAT2',0
         db        '3:LAT2>bez',0
         db        '4:LAT2>KAM',0
         db        0

edivolb4 db        'VeåkÇ p°smen†',0
         db        'MalÇ p°smen†',0
         db        0

copyvolb db        'Prep°saü',0
         db        'V®etky',0
         db        'Dal®°',0
         db        'Neprepisovaü ëiaden',0
         db        0

delvolb  db        'Zru®iü',0
         db        'V®etky',0
         db        'Dal®°',0
         db        'Preskoáiü v®etky',0
         db        0

erradres db        7,'ChybnÇ zadanie adres†ra !',0
ELSE
edivolb2 db        'Uloëit',0
         db        'Neukl†dat',0
         db        'Pokraáovat',0
         db        0

edivolb3 db        '1:KAM>bez',0
         db        '2:KAM>LAT2',0
         db        '3:LAT2>bez',0
         db        '4:LAT2>KAM',0
         db        0

edivolb4 db        'Velk† p°smena',0
         db        'Mal† p°smena',0
         db        0

copyvolb db        'P©epsat',0
         db        'V®echny',0
         db        'Dal®°',0
         db        'Nep©episovat ë†dnò',0
         db        0

delvolb  db        'Zru®it',0
         db        'V®echny',0
         db        'Dal®°',0
         db        'P©eskoáit v®echny',0
         db        0

erradres db        7,'ChybnÇ zad†n° adres†©e !',0
ENDIF
public   txtsubd,txtupd

txtsubd  db        '<POD--ADR>',0
txtupd   db        '<NAD--ADR>',0


public   txthelp3,txthelp2

IFDEF    slov
txthelp3:
         db        'Pomoc',0                ; Shift-F1
         db        'Pr°kaz'                 ; Shift-F2
         db        0                        ; Shift-F3
         db        'Edituj'                 ; Shift-F4
ifdef    upver
         db        'Vysiel'                 ; Shift-F5
         db        'Pr°jem'                 ; Shift-F6
else
         db        0                        ; Shift-F5
         db        0                        ; Shift-F6
endif
         db        0                        ; Shift-F7
         db        'Obnov '                 ; Shift-F8
         db        'Zotr. '                 ; Shift-F9
         db        'EgaVga'                 ; Shift-F10
ELSE
txthelp3:
         db        'Pomoc',0                ; Shift-F1
         db        'P©°kaz'                 ; Shift-F2
         db        0                        ; Shift-F3
         db        'Edituj'                 ; Shift-F4
ifdef    upver
         db        'Vys°l.'                 ; Shift-F5
         db        'P©°jem'                 ; Shift-F6
else
         db        0                        ; Shift-F5
         db        0                        ; Shift-F6
endif
         db        0                        ; Shift-F7
         db        'Obnov '                 ; Shift-F8
         db        'Set©iÉ'                 ; Shift-F9
         db        'EgaVga'                 ; Shift-F10
ENDIF
IFDEF    slov
txthelp2:
         db        'úavÇ',0                 ; Alt-F1
         db        'PravÇ '                 ; Alt-F2
         db        'Zobraz'                 ; Alt-F3
         db        'Edituj'                 ; Alt-F4
         db        'K¢pia '                 ; Alt-F5
         db        'Presu§'                 ; Alt-F6
         db        'Håadaj'                 ; Alt-F7
         db        'Zru®iü'                 ; Alt-F8
         db        'Zhoda '                 ; Alt-F9
         db        'Strom '                 ; Alt-F10
ELSE
txthelp2:
         db        'LevÇ',0                 ; Alt-F1
         db        'PravÇ '                 ; Alt-F2
         db        'Zobraz'                 ; Alt-F3
         db        'Edituj'                 ; Alt-F4
         db        'Kopie '                 ; Alt-F5
         db        'P©esu§'                 ; Alt-F6
         db        'Hledej'                 ; Alt-F7
         db        'Zru®it'                 ; Alt-F8
         db        'Shoda '                 ; Alt-F9
         db        'Strom '                 ; Alt-F10
ENDIF

IFDEF    slov
txthelp:
         db        'Pomoc '                 ; F1
         db        'Voåby '                 ; F2
         db        'Zobraz'                 ; F3
         db        'Edituj'                 ; F4
         db        'K¢pia '                 ; F5
         db        'Presu§'                 ; F6
         db        'Vytvor'                 ; F7
         db        'Zru®iü'                 ; F8
         db        'Atrib.'                 ; F9
         db        'Koniec'                 ; F10
ELSE
txthelp:
         db        'Pomoc '                 ; F1
         db        'Volby '                 ; F2
         db        'Zobraz'                 ; F3
         db        'Edituj'                 ; F4
         db        'Kopie '                 ; F5
         db        'P©esu§'                 ; F6
         db        'Vytvo©'                 ; F7
         db        'Zru®it'                 ; F8
         db        'Atrib.'                 ; F9
         db        'Konec '                 ; F10
ENDIF

IFDEF    slov
txthlped:                                 ;* editor
         db        'Pomoc '                 ; F1
         db        'Uloë',0                 ; F2
         db        'Zaá.b.'                 ; F3
         db        'Kon.b.'                 ; F4
         db        'K¢pia '                 ; F5
         db        'Presu§'                 ; F6
         db        'Håadaj'                 ; F7
         db        'Zru®',0                 ; F8
         db        'Zobraz'                 ; F9
         db        'Koniec'                 ; F10
ELSE
txthlped:                                 ;* editor
         db        'Pomoc '                 ; F1
         db        'Uloë',0                 ; F2
         db        'Zaá.b.'                 ; F3
         db        'Kon.b.'                 ; F4
         db        'Kopie '                 ; F5
         db        'P©esu§'                 ; F6
         db        'Hledej'                 ; F7
         db        'Zru®',0                 ; F8
         db        'Zobraz'                 ; F9
         db        'Konec '                 ; F10
ENDIF

IFDEF    slov
txthlped2:                                ;* editor se SHIFT
         db        'Pomoc '                 ; F1
         db        'Uloë',0                 ; F2
         db        'Uloë b'                 ; F3
         db        'Ä°taj',0                ; F4
         db        'Ä°t.b.'                 ; F5
         db        0                        ; F6
         db        'Håadaj'                 ; F7
         db        'NahraÉ'                 ; F8
         db        0                        ; F9
         db        'EgaVga'                 ; F10
ELSE
txthlped2:                                ;* editor se SHIFT
         db        'Pomoc '                 ; F1
         db        'Uloë',0                 ; F2
         db        'Uloë b'                 ; F3
         db        'Äti',0                  ; F4
         db        'Äti b.'                 ; F5
         db        0                        ; F6
         db        'Hledej'                 ; F7
         db        'NahraÉ'                 ; F8
         db        0                        ; F9
         db        'EgaVga'                 ; F10
ENDIF

IFDEF    slov
txthlped3:                                ;* editor s ALT
         db        0                        ; F1
         db        0                        ; F2
         db        'Binar '                 ; F3
         db        'Ctrl- '                 ; F4
         db        'Tabel '                 ; F5
         db        0                        ; F6
         db        'Fonty '                 ; F7
         db        'Znaky '                 ; F8
         db        'Zmena '                 ; F9
         db        'Preru®'                 ; F10
ELSE
txthlped3:                                ;* editor s ALT
         db        0                        ; F1
         db        0                        ; F2
         db        'Binar '                 ; F3
         db        'Ctrl- '                 ; F4
         db        'Tabel '                 ; F5
         db        0                        ; F6
         db        'Fonty '                 ; F7
         db        'Znaky '                 ; F8
         db        'Zmàna '                 ; F9
         db        'P©eru®'                 ; F10
ENDIF

IFDEF    slov
txthlpzo:
         db        'Pomoc '                 ; F1
ifdef    upver
         db        'Prelom'                 ; F2
else
         db        0                        ; F2
endif
         db        'AscHex'                 ; F3
         db        'Ctrl- '                 ; F4
         db        'Tabel '                 ; F5
ifdef    upver
         db        'Skok..'                 ; F6
else
         db        0                        ; F6
endif
         db        'Håadaj'                 ; F7
ifdef    upver
         db        'FAT   '                 ; F8
         db        'Adres.'                 ; F9
else
         db        0                        ; F8
         db        0                        ; F9
endif
         db        'Koniec'                 ; F10
ELSE
txthlpzo:
         db        'Pomoc '                 ; F1
ifdef    upver
         db        'P©elom'                 ; F2
else
         db        0                        ; F2
endif
         db        'AscHex'                 ; F3
         db        'Ctrl- '                 ; F4
         db        'Tabel '                 ; F5
ifdef    upver
         db        'Skok..'                 ; F6
else
         db        0                        ; F6
endif
         db        'Hledej'                 ; F7
ifdef    upver
         db        'FAT   '                 ; F8
         db        'Adres.'                 ; F9
else
         db        0                        ; F8
         db        0                        ; F9
endif
         db        'Konec '                 ; F10
ENDIF

IFDEF    slov
txthlpzo1:                                ;* zobrazen° se SHIFT-
         db        'Pomoc '                 ; SHIFT-F1
         db        0                        ; SHIFT-F2
         db        0                        ; SHIFT-F3
         db        0                        ; SHIFT-F4
         db        0                        ; SHIFT-F5
         db        0                        ; SHIFT-F6
         db        'Håadaj'                 ; SHIFT-F7
         db        0                        ; SHIFT-F8
         db        0                        ; SHIFT-F9
         db        'EgaVga'                 ; SHIFT-F10
ELSE
txthlpzo1:                                ;* zobrazen° se SHIFT-
         db        'Pomoc '                 ; SHIFT-F1
         db        0                        ; SHIFT-F2
         db        0                        ; SHIFT-F3
         db        0                        ; SHIFT-F4
         db        0                        ; SHIFT-F5
         db        0                        ; SHIFT-F6
         db        'Hledej'                 ; SHIFT-F7
         db        0                        ; SHIFT-F8
         db        0                        ; SHIFT-F9
         db        'EgaVga'                 ; SHIFT-F10
ENDIF


txthlpzo2:                                ;* zobrazen° s ALT-
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

IFDEF    slov
public   hlptre
hlptre   db        0                        ; F1
         db        'Aktual'                 ; F2
         db        'Autom.'                 ; F3
         db        0                        ; F4
         db        0                        ; F5
         db        0                        ; F6
         db        0                        ; F7
         db        0                        ; F8
         db        'Preru®'                 ; F9
         db        'Nastav'                 ; F10
ELSE
public   hlptre
hlptre   db        0                        ; F1
         db        'Aktual'                 ; F2
         db        'Autom.'                 ; F3
         db        0                        ; F4
         db        0                        ; F5
         db        0                        ; F6
         db        0                        ; F7
         db        0                        ; F8
         db        'P©eru®'                 ; F9
         db        'Nastav'                 ; F10
ENDIF


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


public   errver,errmem,errcard

IFDEF    slov
errver   db        'Chybna verzia operacneho systemu !',13,10,'$'
errmem   db        'Nieje dostatok volnej pamati !',13,10,'$'
errcard  db        'Nespravny typ grafickej karty !',13,10,'$'
ELSE
errver   db        'Chybna verze operacniho systemu !',13,10,'$'
errmem   db        'Neni dostatek volne pameti !',13,10,'$'
errcard  db        'Nespravny typ graficke karty !',13,10,'$'
ENDIF

konectxt label     byte                   ;* konec textñ

public   tabhlp0
tabhlp0  label     word
         dw        offset txthelp           ; z†kladn° n†povàda
         dw        offset txthelp3          ; n†povàda se Shift-
         dw        offset hlpuse            ; n†povàda s Ctrl-
         dw        offset txthelp2          ; n†povàda s Alt-

public   tabhlpt
tabhlpt  label     word
         dw        offset hlptre            ; z†kladn° n†povàda
         dw        offset helped            ; n†povàda se Shift-
         dw        offset helped            ; n†povàda s Ctrl-
         dw        offset hlptre            ; n†povàda s Alt-

public   tabhlped
tabhlped label     word                   ;* n†povàda pro editor
         dw        offset txthlped          ; z†kladn° n†povàda
         dw        offset txthlped2         ; n†povàda se Shift-
         dw        offset helped            ; n†povàda s Ctrl-
         dw        offset txthlped3         ; n†povàda s Alt-

public   tabhlzob
tabhlzob label     word                   ;* n†povàda pro zobrazen°
         dw        offset txthlpzo          ; z†kladn° n†povàda
         dw        offset txthlpzo1         ; n†povàda se Shift-
         dw        offset helped            ; n†povàda s Ctrl-
         dw        offset txthlpzo2         ; n†povàda s Alt-

public   tabhlfnd
tabhlfnd label     word                   ;* n†povàda pro vyhled†v†n°
         dw        0                        ; p©°znak, ëe se n†povàda nezobraz°
;         dw        offset helped            ; z†kladn° n†povàda
;         dw        offset helped            ; n†povàda se Shift-
;         dw        offset helped            ; n†povàda s Ctrl-
;         dw        offset helped            ; n†povàda s Alt-


public   nadadr,rootdir,all,nuldir
nadadr   db        "..",0                   ; oznaáen° nadadres†©e
rootdir  db        '\',0                    ; oznaáen° hlavn°ho adres†©e
all      db        '*.*',0                  ; oznaáen° - v®echny soubory
nuldir   db        0                        ; nulovò adres†©

public   filehelp
filehelp db        'DOSMAN.HLP',0           ; soubor n†povàdy
filewiev db        'VIEW',0                 ; jmÇno souboru pro VIEW ALT-F3
fileedit db        'EDIT',0                 ; jmÇno souboru pro EDIT ALT-F4
fileuser db        'USER',0                 ; jmÇno souboru uëivatele
filebat  db        '.BAT %1 %2 %3 %4',0     ; p©°pona pro soubory
fileobn  db        'UNDEL.EXE',0            ; program pro obnoven° souborñ

public   menuprf1,menuprf2,menuprf3         ; prefixy pro menu
menuprf1 db        'SHIFT-',0
menuprf2 db        'CTRL-',0
menuprf3 db        'ALT-',0

txthlp1  db        '[HELP HELP]',0

public   soubuse,soubtre,soubcol,soubinf
soubuse  db        'DOSMAN.USE',0
soubmen  db        'DOSMAN.MNU',0
soubext  db        'DOSMAN.EXT',0
soubtre  db        'DOSMAN.TRE',0           ; strom adres†©e
soubcol  db        'DOSMAN.COL',0
soubinf  db        'FILEINFO',0

extent   db        'EXECOMBAT'              ; povolenÇ extenty

tabchar  label     byte                     ; tabulka kl†ves s Alt

         db        1eh,30h,2eh,20h,12h,21h  ; A,B,C,D,E,F
         db        22h,23h,17h,24h,25h,26h  ; G,H,I,J,K,L
         db        32h,31h,18h,19h,10h,13h  ; M,N,O,P,Q,R
         db        1fh,14h,16h,2fh,11h,2dh  ; S,T,U,V,W,X
         db        15h,2ch                  ; Y,Z


public   upperkam
upperkam label     byte                   ;* velk† p°smena Kamenickòch
         db        'Åö'                     ; 129
         db        'Çê'                     ; 130
         db        'ÉÖ'                     ; 131
         db        'Ñé'                     ; 132
         db        'áÄ'                     ; 135
         db        'àâ'                     ; 136
         db        'åú'                     ; 140
         db        'çä'                     ; 141
         db        'ëí'                     ; 145
         db        'ìß'                     ; 147
         db        'îô'                     ; 148
         db        'ñ¶'                     ; 150
         db        'òù'                     ; 152
         db        'üÜ'                     ; 159
         db        '†è'                     ; 160
         db        '°ã'                     ; 161
         db        '¢ï'                     ; 162
         db        '£ó'                     ; 163
         db        '§•'                     ; 164
         db        '®õ'                     ; 168
         db        '©û'                     ; 169
         db        '™´'                     ; 170
         db        0


public   upperlat
upperlat label     byte                   ;* velk† p°smena Latin 2
         db        'Åö'                     ; 129
         db        'Çê'                     ; 130
         db        'É∂'                     ; 131
         db        'Ñé'                     ; 132
         db        'Öﬁ'                     ; 133
         db        'Üè'                     ; 134
         db        'áÄ'                     ; 135
         db        'àù'                     ; 136
         db        'â”'                     ; 137
         db        'ãä'                     ; 139
         db        'å◊'                     ; 140
         db        'íë'                     ; 146
         db        'ì‚'                     ; 147
         db        'îô'                     ; 148
         db        'ñï'                     ; 150
         db        'òó'                     ; 152
         db        'úõ'                     ; 156
         db        'ü¨'                     ; 159
         db        '†µ'                     ; 160
         db        '°÷'                     ; 161
         db        '¢‡'                     ; 162
         db        '£È'                     ; 163
         db        '•§'                     ; 165
         db        'ß¶'                     ; 167
         db        '©®'                     ; 169
         db        '´ç'                     ; 171
         db        '≠∏'                     ; 173
         db        'æΩ'                     ; 190
         db        '«∆'                     ; 199
         db        '–—'                     ; 208
         db        '‘“'                     ; 212
         db        'ÿ∑'                     ; 216
         db        '‰„'                     ; 228
         db        'Â’'                     ; 229
         db        'ÁÊ'                     ; 231
         db        'ÍË'                     ; 234
         db        'ÏÌ'                     ; 236
         db        'Ó›'                     ; 238
         db        '˚Î'                     ; 251
         db        '˝¸'                     ; 253
         db        0


public   prevcs
prevcs   label     byte                   ;* tabulka pro vypnut° áe®tiny
         db        'C¨'                     ; 128 Ä
         db        'uÅ'                     ; 129 Å
         db        'eÇ'                     ; 130 Ç
         db        'd‘'                     ; 131 É
         db        'aÑ'                     ; 132 Ñ
         db        'D“'                     ; 133 Ö
         db        'Tõ'                     ; 134 Ü
         db        'cü'                     ; 135 á
         db        'eÿ'                     ; 136 à
         db        'E∑'                     ; 137 â
         db        'Lë'                     ; 138 ä
         db        'I÷'                     ; 139 ã
         db        'lñ'                     ; 140 å
         db        'lí'                     ; 141 ç
         db        'Aé'                     ; 142 é
         db        'Aµ'                     ; 143 è
         db        'Eê'                     ; 144 ê
         db        'zß'                     ; 145 ë
         db        'Z¶'                     ; 146 í
         db        'oì'                     ; 147 ì
         db        'oî'                     ; 148 î
         db        'O‡'                     ; 149 ï
         db        'uÖ'                     ; 150 ñ
         db        'UÈ'                     ; 151 ó
         db        'yÏ'                     ; 152 ò
         db        'Oô'                     ; 153 ô
         db        'Uö'                     ; 154 ö
         db        'SÊ'                     ; 155 õ
         db        'Lï'                     ; 156 ú
         db        'YÌ'                     ; 157 ù
         db        'R¸'                     ; 158 û
         db        'tú'                     ; 159 ü
         db        'a†'                     ; 160 †
         db        'i°'                     ; 161 °
         db        'o¢'                     ; 162 ¢
         db        'u£'                     ; 163 £
         db        'nÂ'                     ; 164 §
         db        'N’'                     ; 165 •
         db        'Uﬁ'                     ; 166 ¶
         db        'O‚'                     ; 167 ß
         db        'sÁ'                     ; 168 ®
         db        'r˝'                     ; 169 ©
         db        'rÍ'                     ; 170 ™
         db        'RË'                     ; 171 ´


public   colcol,colbw

colbw    label     byte                     ; barvy pro monochromatickò displej

         db        07h                      ; atribut norm†ln°ho textu okna
         db        0fh                      ; atribut vysv°cenÇho textu
         db        70h                      ; atribut negovanÇho textu
         db        70h                      ; atribut negovanÇho vysv°cenÇho tx.
         db        07h                      ; ukazatel norm†ln°
         db        0fh                      ; ukazatel vysv°cen°
         db        70h                      ; norm†ln° okno
         db        0fh                      ; chybovÇ hl†®en°
         db        07h                      ; text á°sla funkán° kl†v. n†povàdy
         db        70h                      ; zvòraznànò text v norm†ln°m oknà
         db        70h                      ; kurzor pro prov†dàn° operace
         db        70h                      ; vysv°cenò kurzor operace
         db        0fh                      ; zobrazen° chyby zad†n° parametru
         db        0fh                      ; vysv°cenÇ p°smeno v kurzoru
         db        0fh                      ; ©°dic° znak v textu editoru

         db        07h                      ; barva podkladu n†povàdy
         db        0fh                      ; poloëka n†povàdy
         db        70h                      ; kurzor n†povàdy
         db        07h                      ; kurzor v oknà voleb

colcol   label     byte                     ; barvy pro barevnò displej

         db        1bh                      ; atribut norm†ln°ho textu okna
         db        1eh                      ; atribut vysv°cenÇho textu
         db        30h                      ; atribut negovanÇho textu
         db        3eh                      ; atribut negovanÇho vysv°cenÇho tx.
         db        6fh                      ; ukazatel norm†ln°
         db        6ch                      ; ukazatel vysv°cen°
         db        70h                      ; norm†ln° okno
         db        4fh                      ; chybovÇ hl†®en°
         db        07h                      ; text á°sla funkán° kl†v. n†povàdy
         db        74h                      ; zvòraznànò text v norm†ln°m oknà
         db        60h                      ; kurzor pro prov†dàn° operace
         db        6eh                      ; vysv°cenò kurzor operace
         db        4fh                      ; zobrazen° chyby zad†n° parametru
         db        34h                      ; vysv°cenÇ p°smeno v kurzoru
         db        1dh                      ; ©°dic° znak v textu editoru

         db        1bh                      ; barva podkladu n†povàdy
         db        1fh                      ; poloëka n†povàdy
         db        4fh                      ; kurzor n†povàdy
         db        30h                      ; kurzor v oknà voleb


; *****************************************************************************
;
;     Inicializaán° data - jsou souá†st° souboru a jsou rezidentn° v pamàti
;
; *****************************************************************************
public   inidata,flags,pozwr,pozwl,config,flags0l,flags0r,conf2,conf3,port
public   conf4,conf5

inidata  label     byte                   ;* zaá†tek inicializaán°ch dat

                                          ;* definice oken
ifndef   demo
 flags    db        00000100b                ; indik†tor stavñ
else
 flags    db        00001100b
endif
                                            ;   bit 0: 1=aktivn° je levÇ okno
                                            ;   bit 1: 1=v®echna okna vypnuta
                                            ;   bit 2: 1=n†povàda je povolena
                                            ;   bit 3: 1=je rezidentn° reëim
                                            ;   bit 4: 1=je font 8x8 bodñ
                                            ;   bit 5: 1=áernob°lò displej
                                            ;   bit 6: 00=z†klad. n†povàda,
                                            ;   bit 7:  01=Shift,10=Ctrl,11=Alt

flags0l  db        00000000b              ;* £schova indik†toru levÇho okna
                                            ;     bit 0: 1=okno je zapnuto
                                            ;     bit 1: 1=adres†© je naáten
                                            ;     bit 2: 1=adres†© se nenuluje
                                            ;     bit 3: 1=okno je zobrazeno
                                            ;     bit 4: 1=okno se net©°d°
                                            ;     bit 5: 1=t©°dàn° podle p©°pony
                                            ;     bit 6: 1=t©°dàn° podle data a áasu
                                            ;     bit 7: 1=t©°dàn° podle velikosti

public   setwls,setwrs
setwls   db        ?                      ;* nastaven° levÇho okna
                                            ; bit 0: 1=trojsloupc. zobrazen°

setwrs   db        ?                      ;* nastaven° pravÇho okna
                                            ; bit 0: 1=trojsloupc. zobrazen°

flags0r  db        00000001b              ;* £schova indik†toru pravÇho okna
                                            ;     bit 0: 1=okno je zapnuto
                                            ;     bit 1: 1=adres†© je naáten
                                            ;     bit 2: 1=adres†© se nenuluje
                                            ;     bit 3: 1=okno je zobrazeno
                                            ;     bit 4: 1=okno se net©°d°
                                            ;     bit 5: 1=t©°dàn° podle p©°pony
                                            ;     bit 6: 1=t©°dàn° podle data a áasu
                                            ;     bit 7: 1=t©°dàn° podle velikosti

config   db        00000001b              ;* konfigurace programu
                                            ;   bit 0: 1=vypnut° áe®tiny
                                            ;   bit 1: 1=je k¢d LATIN 2
                                            ;   bit 2: 1=je zobrazen° Ctrl-
                                            ;   bit 3: 1=adres†© TREE je naáten
                                            ;   bit 4: 1=okno ve stromu naáteno
                                            ;   bit 5: 1=nen° autom. áten° adr.
                                            ;   bit 6: 1=nainstalov†na my®
                                            ;   bit 7: 1=je n†povàda SHIFT

conf2    db        00010000b              ;* konfigurace 2
                                            ;   bit 0: 1=prov†dàn° p©°kazñ INT 2Eh
                                            ;   bit 1: 1=jsou atributy levÇho okna
                                            ;   bit 2: 1=jsou atributy pravÇho okna
                                            ;   bit 3: 1=nucenò p©°znak SHIFT
                                            ;   bit 4: 1=je povolenò SHIFT
                                            ;   bit 5-7: typ my®i, 0=ë†dn† my®
                                            ;                      1=GENIUS MOUSE
                                            ;                      7=automaticky

pozwr    db        40                       ; poá†teán° pozice pravÇho okna
pozwl    db        0                        ; poá†teán° pozice levÇho okna

ediflag  db        0                      ;* p©°znaky editoru
                                            ;   bit 0: 1=soubor byl modifikov†n
                                            ;   bit 1: 1=je prefix ^Q
                                            ;   bit 2: 1=je vypnuta funkce INS
                                            ;   bit 3: 1=je zobrazen blok
                                            ;   bit 4: 1=tabel†tory se nezobraz°
                                            ;   bit 5: 1=zobrazen° HEX
                                            ;   bit 6: 1=je bin†rn° editace
                                            ;   bit 7: 1=je prefix ^K

conf3    db        00000000b              ;* konfigurace
                                            ;   bit 0: 1=je automatickÇ menu
                                            ;   bit 1: 1=poëadavek spu®tàn° menu
                                            ;   bit 2: 1=standardn° kl†vesnice
                                            ;   bit 3: 1=z†kaz pouëit° my®i
                                            ;   bit 4: 1=porovn.-novàj®° soub.
                                            ;   bit 5: 1=porovn.-dopl§kovÇ soub.
                                            ;   bit 6: 1=porovn.-shodnÇ soub.
                                            ;   bit 7: 1=porovn.-rozd°lnÇ soub.

conf4    db        00000000b              ;* p©°znaky pro hled†n° v editoru
                                            ;   bit 0: 1=je n†hrada textu
                                            ;   bit 1: 1=nerozli®uj "U"
                                            ;   bit 2: 1=zpàt "B"
                                            ;   bit 3: 1=celÇ slovo "W"
                                            ;   bit 4: 1=celò soubor "G"
                                            ;   bit 5: 1=oznaáenò blok "L"
                                            ;   bit 6: 1=bez dotazu "N"
                                            ;   bit 7: 1=platnò otazn°k "?"

conf5    db        00000000b              ;* p©°znaky
                                            ;   bit 0: 1=vypnuto zalamov†n° VIEW
                                            ;   bit 1: 1=aktivn° rychlò prohl°ë.
                                            ;   bit 2: 1=zobraz. F3 adres†©e
                                            ;   bit 3: 1=zobraz. F3 FAT tabulek
                                            ;   bit 4: 1=p©i ^Q nalezen FILEINFO

port     dw        0                        ; á°slo komunikaán°ho portu

; *****************************************************************************
;
;    Neinicializovan† data -  nejsou souá†st° MNS.COM a zñst†vaj° v pamàti
;
; *****************************************************************************
public   zacmaz,pathhome,path,namel,namer,firstwl,firstwr
public   inidend

zacmaz   label     byte                     ; odtuto se pamàü vymaëe p©i inic.

pathhome db        128 dup(?)               ; p©°stupov† cesta k domovskÇmu adr.
path     db        70 dup(?)                ; cesta k neaktivn°mu oknu

namel    db        20 dup(?)                ; p©edvolenÇ jmÇno souboru L
namer    db        20 dup(?)                ; p©edvolenÇ jmÇno souboru R
firstwl  dw        ?                        ; uchovan† pozice levÇho okna
firstwr  dw        ?                        ; uchovan† pozice pravÇho okna

bufsel   label     byte                   ;* buffer masek pro selekci souborñ
         dw        ?                        ; dÇlka bufferu
bufsel1  db        200 dup(?)               ; buffer
bufsel2  db        ?                        ; poáet p©edvoleb
         dw        ?                        ; adresa p©edvolby "*.*"


public   bufcopy,bufcop1,bufcop2,bufcop3

bufcopy  label     byte                   ;* buffer pro kop°rov†n° souborñ
         dw        ?                        ; dÇlka bufferu
bufcop1  db        300 dup(?)
bufcop2  db        ?                        ; poáet p©edvoleb 1 aë 2
bufcop3  dw        ?                        ; p©edvolba 1
bufcop4  dw        ?                        ; p©edvolba 2


bufadr   label     byte                   ;* buffer adres†©ñ
         dw        ?                        ; dÇlka bufferu
bufadr1  db        132 dup(?)
bufadr2  db        ?                        ; poáet p©edvoleb = 0

public   bufcomm,bufcomm1,bufcomm2,bufcomm3
bufcomm  label     byte                   ;* buffer povelñ
         dw        ?                        ; dÇlka bufferu
bufcomm1 db        600 dup(?)
bufcomm2 db        ?                        ; poáet p©edvoleb = 1
bufcomm3 dw        ?                        ; p©edvolba - BUFTXT

public   bufatr,bufatr1,bufatr2,bufatr3,preatrib
bufatr   label     byte                   ;* buffer pro volby atributñ
         dw        ?                        ; dÇlka bufferu
bufatr1  db        132 dup(?)
bufatr2  db        ?                        ; poáet p©edvoleb = 1
bufatr3  dw        ?                        ; p©edvolba - zap/vyp atributñ
preatrib db        ?,?                      ; text p©edvolby ("+" nebo "-")

public   buffind,buffind1,buffind2,buffind3
buffind  label     byte                   ;* buffer pro vyhled†v†n° souborñ
         dw        ?                        ; dÇlka bufferu
buffind1 db        132 dup(?)
buffind2 db        ?                        ; poáet p©edvoleb = 1
buffind3 dw        ?                        ; p©edvolba - aktivn° adres†©

public   bufhlde,bufhlde1,bufhlde2,findstr,replstr,bufparh,bufparh1,bufparh2

bufhlde  label     word                   ;* buffer pro vyhled†v†n° p©i editaci
         dw        ?                        ; dÇlka bufferu
bufhlde1 db        132 dup(?)               ; (velikost nemànit !)
bufhlde2 db        ?                        ; poáet p©edvoleb = 0

bufparh  label     word                   ;* buffer parametrñ pro hled†n°
         dw        ?                        ; dÇlka bufferu
bufparh1 db        132 dup(?)               ; buffer (velikost nemànit !)
bufparh2 db        ?                        ; poáet p©edvoleb = 0

public   bufclust,bufclst1,bufclst2
bufclust label     word                   ;* buffer zad†n° á°sla bloku
         dw        ?                        ; dÇlka bufferu
bufclst1 db        132 dup(?)               ; buffer
bufclst2 db        ?                        ; poáet p©edvoleb = 0

findstr  db        129 dup (?)              ; hledanò ©etàzec
replstr  db        129 dup (?)              ; ©etàzec k nahrazen°

hlptop   dw        ?                        ; poá†t. adresa zobrazen° n†povàdy
hlpkurz  dw        ?                        ; adresa kurzoru n†povàdy

public   hlpuse
hlpuse   db        10 * 6 dup(?)            ; uëivatelsk† n†povàda

                                          ;* znaáky v souboru
ediblkb  dw        ?                        ; adresa zaá†tku bloku
ediblkk  dw        ?                        ; adresa konce bloku
ediznac  dw        ?                        ; znaáka v souboru (0)
ediblk1  dw        ?                        ; znaáka v souboru 1
ediblk2  dw        ?                        ; znaáka v souboru 2
ediblk3  dw        ?                        ; znaáka v souboru 3
ediblk4  dw        ?                        ; znaáka v souboru 4
ediblk5  dw        ?                        ; znaáka v souboru 5
ediblk6  dw        ?                        ; znaáka v souboru 6
ediblk7  dw        ?                        ; znaáka v souboru 7
ediblk8  dw        ?                        ; znaáka v souboru 8
ediblk9  dw        ?                        ; znaáka v souboru 9
ediblk0  dw        ?                        ; znaáka v souboru 10

public   col1,col2,col3,col4,col5,col6,col7,col8,col9,col10,col11,col12,col13
public   col16,col19,coldisp

coldisp  label     byte                     ; barvy pro displej

col1     db        ?                        ; atribut norm†ln°ho textu okna
col2     db        ?                        ; atribut vysv°cenÇho textu
col3     db        ?                        ; atribut negovanÇho textu
col4     db        ?                        ; atribut negovanÇho vysv°cenÇho tx.
col5     db        ?                        ; ukazatel norm†ln°
col6     db        ?                        ; ukazatel vysv°cen°
col7     db        ?                        ; norm†ln° okno
col8     db        ?                        ; chybovÇ hl†®en°
col9     db        ?                        ; text á°sla funkán° kl†v. n†povàdy
col10    db        ?                        ; zvòraznànò text v norm†ln°m oknà
col11    db        ?                        ; kurzor pro prov†dàn° operace
col12    db        ?                        ; vysv°cenò kurzor operace
col13    db        ?                        ; zobrazen° chyby zad†n° parametru
col14    db        ?                        ; vysv°cenÇ p°smeno v kurzoru
col15    db        ?                        ; ©°dic° znak v textu editoru

col16    db        ?                        ; barva podkladu n†povàdy
col17    db        ?                        ; poloëka n†povàdy
col18    db        ?                        ; kurzor n†povàdy
col19    db        ?                        ; kurzor v oknà voleb

public   presmen
presmen  db        ?                        ; p©edvolen† poloëka menu

public   mousepoz
mousepoz dw        ?                        ; sou©adnice kurzoru my®i

inidend  label     byte                     ; adresa konce rezidentn°ch dat

; *****************************************************************************
;
;         Neinicializovan† data pracovn° - p©i startu programu se ru®°
;
; *****************************************************************************
public   verze,zasob,keystat,keyinp,topseg,segend,seznseg,pathr,pathl,licence
public   datseg,seznseg0
public   zacmazr

zacmazr  label     byte                     ; odtuto se pamàü vymaëe p©i reinic.

verze    dw        ?                        ; á°slo verze operaán°ho systÇmu
zasob    dw        ?                        ; vrchol z†sobn°ku SP

licence  dd        ?                        ; licenán° á°slo

keystat  db        ?                        ; k¢d pro áten° statusu kl†vesnice
keyinp   db        ?                        ; k¢d pro áten° znaku z kl†vesnice

                                          ;* data pro obsluhu pamàti
datseg   dw        ?                        ; zaá†tek alokaán°ho bloku dat
topseg   dw        ?                        ; segment zaá†tku volnÇ pamàti
segend   dw        ?                        ; segment konce volnÇ pamàti
seznseg  dw        30 dup(?)                ; seznam segmentñ adres
seznseg0 label     byte                     ; konec seznamu

pathr    db        70 dup(?)                ; cesta k pravÇmu adres†©i
pathl    db        70 dup(?)                ; cesta k levÇmu adres†©i

public   parint,old08,old09,old10,old21,old23,old24,old1b,citachod,citmouse
public   citacexp,parint2

parint   db        ?                        ; p©°znak obsluh p©eru®en°
                                            ;   bit 0: je aktivn° INT 08h
                                            ;   bit 1: je aktivn° INT 10h
                                            ;   bit 2: je aktivn° INT 24h
                                            ;   bit 3: hled†n° souboru ALT-F7
                                            ;   bit 4: prov†d° se zobrazen° F3
                                            ;   bit 5: prov†d° se editace F4
                                            ;   bit 6: prob°h† zobrazen° áasu
                                            ;   bit 7: povoleno zobrazen° áasu

parint2  db        ?                        ; p©°znaky p©eru®en°
                                            ;   bit 0: prob°h† zobrazen° stromu

old08    dd        ?                        ; pñvodn° adresa obsluhy INT 08h
old09    dd        ?                        ; pñvodn° adresa obsluhy INT 09h
old10    dd        ?                        ; pñvodn° adresa obsluhy INT 10h
old1b    dd        ?                        ; pñvodn° adresa obsluhy INT 1Bh
old21    dd        ?                        ; pñvodn° adresa obsluhy INT 21h
old23    dd        ?                        ; pñvodn° adresa obsluhy INT 23h
old24    dd        ?                        ; pñvodn° adresa obsluhy INT 24h
citachod db        ?                        ; á°taá pro zobrazen° hodin
citacexp db        ?                        ; á°taá pro explozi
citmouse db        ?                        ; á°taá pro aktivaci my®i
mousedat db        ?                        ; uschovanò stav tlaá°tek my®i

public   typdisp,aktpage
public   adrvram,segvram,citdek,citnum,aktkurz
public   parnum,color,cisvram,insmouse,displ,delvram
                                          ;* £schova pñvodn°ho m¢du displeje
typdisp  db        ?                        ; typ displeje:
                                            ;    0=nezn†mò displej (BIOS)
                                            ;    1=MDA
                                            ;    2=CGA,EGA
aktpage  db        ?                        ; aktivn° str†nka displeje
adrvram  dw        ?                        ; adresa zaá†tku str†nky ve VRAM
segvram  dw        ?                        ; segment videopamàti
aktkurz  dw        ?                        ; £schova pñvodn°ho kurzoru
cisvram  db        ?                        ; á°slo segmentu s VRAM
delvram  dw        ?                        ; dÇlka bufferu s uschovanou VRAM
insmouse db        ?                        ; parametr oznaáov†n° my®°
                                            ;   bit 0: 1=nastaven° nen° uráeno
                                            ;   bit 1: 1=bylo prvn° nastaven°
                                            ;   bit 2: 1=pevnò je konec
                                            ;   bit 7: 1=je oznaáen° souboru
displ    db        ?                        ; posledn° ©†dek displeje


public   comlin,normat,poclin

comlin   label     byte                     ; definice povelovÇho ©†dku
                                          ;* editace ©†dku
adrlin   dw        ?                        ; 0: adresa bufferu ©†dku
seglin   dw        ?                        ; 2: segment adresy
maxlin   dw        ?                        ; 4: maxim†ln° poáet znakñ
poclin   dw        ?                        ; 6: skuteánò poáet znakñ
kurlin   dw        ?                        ; 8: pozice kurzoru v bufferu
zaclin   dw        ?                        ; 10: pozice zobraz. zaá†tku textu
pozlin   db        ?                        ; 12: poá†teán° pozice na displeji
radlin   db        ?                        ; 13: ©†dek k zobrazen° textu
dellin   db        ?                        ; 14: ®°©ka ©†dku textu
normat   db        ?                        ; 15: atribut barvy
                                          ;* parametry pro rolov†n° oken
pocrol   dw        ?                        ; 16: poáet ©†dkñ celkem
kurrol   dw        ?                        ; 18: pozice kurzoru
zacrol   dw        ?                        ; 20: prvn° zobrazenò ©†dek
delrol   db        ?                        ; 22: poáet zobrazenòch ©†dkñ

public   buftxt

buftxt   db        129 dup(?)               ; textovò buffer

public   sellin,numselb,ukazsel,topsel,pocpozsl,pocradsl,delkasel,atribsel
public   radkusel,kurzsel,firstsel,zobrlsel,selbuf,selbufz

sellin   label     byte                     ; definice textu p©i volbà
                                          ;* editace ©†dku
         dw        ?                        ; 0: adresa bufferu ©†dku
         dw        ?                        ; 2: segment adresy
         dw        ?                        ; 4: maxim†ln° poáet znakñ
numselb  dw        ?                        ; 6: skuteánò poáet znakñ
ukazsel  dw        ?                        ; 8: pozice kurzoru v bufferu
topsel   dw        ?                        ; 10: pozice zobraz. zaá†tku textu
pocpozsl db        ?                        ; 12: poá†teán° pozice na displeji
pocradsl db        ?                        ; 13: ©†dek k zobrazen° textu
delkasel db        ?                        ; 14: ®°©ka ©†dku textu
atribsel db        ?                        ; 15: atribut barvy
                                          ;* parametry pro rolov†n° oken
radkusel dw        ?                        ; 16: poáet ©†dkñ celkem
kurzsel  dw        ?                        ; 18: pozice kurzoru
firstsel dw        ?                        ; 20: prvn° zobrazenò ©†dek
zobrlsel db        ?                        ; 22: poáet zobrazenòch ©†dkñ

selbuf   db        129 dup(?)               ; buffer pro editaci p©i vòbàru
selbufz  db        129 dup(?)               ; buffer pro £schovu textu p©i ^O

public   rozbset,rozbflg,rozbnam,rozbext,rozbdat,rozbcas,rozbvel,rozbats
public   rozbatr,rozbend,rozbdat0,rozbcas0

rozbset  label     byte                     ; rozbor zad†n° souboru
rozbflg  db        ?                        ;  0: p©°znaky rozboru
                                            ;      bit 0: 1=men®° jmÇno
                                            ;      bit 1: 1=vàt®° jmÇno
                                            ;      bit 2: 1=men®° datum
                                            ;      bit 3: 1=vàt®° datum
                                            ;      bit 4: 1=men®° áas
                                            ;      bit 5: 1=vàt®° áas
                                            ;      bit 6: 1=men®° velikost
                                            ;      bit 7: 1=vàt®° velikost
rozbnam  db        8 dup(?)                 ;  1: jmÇno souboru
rozbext  db        3 dup(?)                 ;  9: p©°pona jmÇna souboru
rozbdat  db        6 dup(?)                 ; 12: datum souboru

rozbcas  db        6 dup(?)                 ; 18: áas souboru

rozbvel  dd        ?                        ; 24: velikost souboru
rozbats  db        ?                        ; 28: nastavovanÇ atributy
rozbatr  db        ?                        ; 29: nulovanÇ atributy
rozbend  label     byte                     ; 30: konec bufferu rozboru

rozbdat0 db        4 dup(?)                 ;  datum souboru
                                            ;   bit 0: zad†no datum
                                            ;   bit 1: màn° se den
                                            ;   bit 2: màn° se màs°c
                                            ;   bit 3: màn° se rok
                                            ; 1:den
                                            ; 2:màs°c
                                            ; 3:rok

rozbcas0 db        4 dup(?)                 ;  áas souboru
                                            ;   bit 0: zad†n áas
                                            ;   bit 1: màn° se hodina
                                            ;   bit 2: màn° se minuta
                                            ;   bit 3: màn° se sekunda
                                            ; 1:hodina
                                            ; 2:minuta
                                            ; 3:sekunda




;normfil  db        20 dup(?)              ;* normalizovanò soubor
;                                            ; 0:  1 bajt - atributy
;                                            ; 1:  8 bajtñ - jmÇno
;                                            ; 9:  3 bajty - p©°pona
;                                            ; 12: 4 bajty - velikost
;                                            ; 16: 2 bajty - datum
;                                            ; 18: 2 bajty - áas

public   flagsc
flagsc   db        ?                      ;* indik†tory pro diskovÇ operace
                                            ; bit 0,1: 0=kop°rov†n° souborñ
                                            ;          1=p©ejmenov†n° souborñ
                                            ;          2=ru®en° souborñ
                                            ;          3=atributy souborñ
                                            ; bit 2: 1=je operace s kurzorem
                                            ; bit 3: 1=p©i rozboru zad†na teáka
                                            ; bit 4: 1=neprov. se dotaz p©episu
                                            ; bit 5: 0=s. se p©ep°®°/1=p©eskoá°
                                            ; bit 6: 1=neprov. se dotaz ochrany
                                            ; bit 7: 0=soub. se ru®°/1=p©eskoá°

color    db        ?                        ; aktivn° barva textu
         db        ?                        ; (n†sled. bajt slouë° tÇë k PUSH)






                                          ;* ukazatele pro editaci p©°kaz. ©†dku
numchar  db        0                        ; poáet znakñ v bufferu
poztop   db        0                        ; pozice zaá†tku zobrazenÇho textu
pozcomm  db        0                        ; pozice zaá†tku textu na displeji
pozbuf   db        0                        ; pozice kurzoru v textovÇm bufferu
endadr   dw        offset endshell          ; adresa konce pamàti (offset)


                                          ;* registry pro dek¢dov†n° á°sla
citdek   db        0                        ; á°taá platnòch á°slic pro p©evod
citnum   db        0                        ; á°taá 1 á°slice
parnum   db        0                        ; parametry pro dek¢dov†n° á°sla
                                            ;   bit 0=z†kaz oddàlovac° teáky
                                            ;   bit 1=tisk mezer
                                            ;   bit 2=tisk nul
                                            ;   bit 3=p©echodnò z†kaz teáky
                                            ;   bit 4=z†kaz tisku teáky tis°cñ

; -----------------------------------------------------------------------------
;                    Definice pravÇho okna (okno á°slo 1)
; -----------------------------------------------------------------------------
public   tabr,flagsr,adrtabr,pozr,adrpathr,numfr
public   cissegr,firstr,kurzr,alokr,celkr,volnr,soubr,zabr,setwr

TABR     label     byte                     ; tabulka definice pravÇho okna
                                          ;* definice zobrazen° okna
flagsr   db        ?                        ; 0: indik†tor stavu okna
                                            ;     bit 0: 1=okno je zapnuto
                                            ;     bit 1: 1=adres†© je naáten
                                            ;     bit 2: 1=adres†© se nenuluje
                                            ;     bit 3: 1=okno je zobrazeno
                                            ;     bit 4: 1=okno se net©°d°
                                            ;     bit 5: 1=t©°dàn° podle p©°pony
                                            ;     bit 6: 1=t©°dàn° podle data a áasu
                                            ;     bit 7: 1=t©°dàn° podle velikosti

adrtabr  dw        ?                        ; 1: adresa levÇho okna
pozr     db        ?                        ; 3: poá†teán° pozice okna
                                          ;* definice poloëek v seznamu
adrpathr dw        ?                        ; 4: adresa p©°stupovÇ cesty k adres†©i
cissegr  db        ?                        ; 6: á°slo segmentu seznamu poloëek
numfr    dw        ?                        ; 7: poáet poloëek v seznamu
firstr   dw        ?                        ; 9: á°slo prvn° zobrazenÇ poloëky
kurzr    dw        ?                        ; 11: á°slo poloëky s kurzorem
                                          ;* parametry disku (dodrëet po©ad° !)
alokr    dw        ?                        ; 13: velikost alokaán°ho bloku
celkr    dd        ?                        ; 15: celkov† kapacita disku
volnr    dd        ?                        ; 19: voln† kapacita disku
soubr    dw        ?                        ; 23: poáet souborñ v adres†©i
zabr     dd        ?                        ; 25: zabran† kapacita souborñ

setwr    db        ?                      ;* 29: nastaven° pravÇho okna
                                            ; bit 0: 1=trojsloupc. zobrazen°

; -----------------------------------------------------------------------------
;                   Definice levÇho okna (okno á°slo 2)
; -----------------------------------------------------------------------------
public   tabl,flagsl,adrtabl,pozl,adrpathl,numfl
public   cissegl,firstl,kurzl,alokl,celkl,volnl,soubl,zabl,setwl

TABL     label     byte                     ; tabulka definice levÇho okna
                                          ;* definice zobrazen° okna
flagsl   db        ?                        ; 0: indik†tor stavu okna
                                            ;     bit 0: 1=okno je zapnuto
                                            ;     bit 1: 1=adres†© je naáten
                                            ;     bit 2: 1=adres†© se nenuluje
                                            ;     bit 3: 1=okno je zobrazeno
                                            ;     bit 4: 1=okno se net©°d°
                                            ;     bit 5: 1=t©°dàn° podle p©°pony
                                            ;     bit 6: 1=t©°dàn° podle data a áasu
                                            ;     bit 7: 1=t©°dàn° podle velikosti

adrtabl  dw        ?                        ; 1: adresa pravÇho okna
pozl     db        ?                        ; 3: poá†teán° pozice okna
                                          ;* definice poloëek v seznamu
adrpathl dw        ?                        ; 4: adresa p©°stupovÇ cesty k adres†©i
cissegl  db        ?                        ; 6: á°slo segmentu seznamu poloëek
numfl    dw        ?                        ; 7: poáet poloëek v seznamu
firstl   dw        ?                        ; 9: á°slo prvn° zobrazenÇ poloëky
kurzl    dw        ?                        ; 11: á°slo poloëky s kurzorem
                                          ;* parametry disku (dodrëet po©ad° !)
alokl    dw        ?                        ; 13: velikost alokaán°ho bloku
celkl    dd        ?                        ; 15: celkov† kapacita disku
volnl    dd        ?                        ; 19: voln† kapacita disku
soubl    dw        ?                        ; 23: poáet souborñ v adres†©i
zabl     dd        ?                        ; 25: zabran† kapacita souborñ

setwl    db        ?                      ;* 29: nastaven° levÇho okna
                                            ; bit 0: 1=trojsloupc. zobrazen°

endtabw  label     byte                     ; n†và®t° konce tabulek oken

; -----------------------------------------------------------------------------
public   numsrc,bufsrc

numsrc   db        ?                        ; poáet znakñ v bufferu vyhled†v†n°
         db        ?                        ; atributy souboru (mus° bòt = 0 !)
bufsrc   db        12 dup(?)                ; buffer pro rychlÇ vyhled†v†n°

; -----------------------------------------------------------------------------

public   bufwin,adrnadp,bufnadp

bufwin   db        128 dup(?)               ; buffer pro okna
bufnadp  db        128 dup(?)               ; buffer nadpisu pro okna
adrnadp  dw        ?                        ; adresa nadpisu

public   buffedi
buffedi  db        13 dup(?)                ; uloëenÇ jmÇno editovanÇho souboru

public   outbuf,outbuf4
outbuf   db        20 dup(?)                ; tiskovò (pracovn°) buffer
outbuf1  db        20 dup(?)
outbuf2  db        20 dup(?)
outbuf3  db        100 dup(?)
outbuf4  db        100 dup(?)

public   outid,inpid,delkauk,poziceuk,blokuk,transuk

outid    dw        ?                        ; identifik†tor vòstupn°ho souboru
inpid    dw        ?                        ; identifik†tor vstupn°ho souboru
ukazbuf  dw        ?                        ; ukazatel dat v diskovÇm buffer
numbuf   dw        ?                        ; poáet bajtñ v diskovÇm bufferu
maxdbuf  dw        ?                        ; velikost disk. bufferu
poziceuk db        ?                        ; poá†teán° pozice ukazatele
delkauk  db        ?                        ; dÇlka ukazatele
blokuk   dd        ?                        ; velikost bloku ukazatele
transuk  dd        ?                        ; p©enesen† velikost dat


public   editmax,editnum,ediradek,edipoz,ediflag,edikurz,edidrad
public   firstrad,endrad,toppoz,adrradek,delkarad,edinormk,edikey
public   ediblkb,ediblkk,endpoz,zobwrap,editseg
public   zobtop,zobukaz,zobnum,zobbuf,ediznac,edikeym,edikpoz,topseged

zobtop   dd        ?                        ; adresa zaá†tku zobrazenÇho textu
zobbuf   dd        ?                        ; ukazatel zaá†tku dat v bufferu
zobukaz  dd        ?                        ; ukazatel pro áten° dat
zobnum   dd        ?                        ; celkovò poáet bajtñ v souboru
zobwrap  dw        ?                        ; maxim. pozice pro zalamov†n°

editmax  dw        ?                        ; velikost bufferu pro editaci
editnum  dw        ?                        ; poáet bajtñ souboru v pamàti
topseged dw        ?                        ; uschovanò segment
editseg  db        ?                        ; segment se souborem

                                          ;* data se vymaz†vaj° cyklem
firstrad dw        ?                        ; adresa prvn°ho ©†dku
endrad   dw        ?                        ; adresa posledn°ho ©†dku
adrradek dw        ?                        ; adresa ©†dku s kurzorem
edikurz  dw        ?                        ; adresa kurzoru absolutnà
toppoz   dw        ?                        ; offset poá†teán° pozice ©†dku rel.
endpoz   dw        ?                        ; offset koncovÇ pozice ©†dku rel.
ediradek dw        ?                        ; á°slo ©†dku
edipoz   dw        ?                        ; pozice na ©†dku uchovan†
edikpoz  dw        ?                        ; pozice na ©†dku skuteán†
edidrad  db        ?                        ; ©†dek na displeji

delkarad dw        ?                        ; dÇlka ©†dku s kurzorem

edikey   dw        ?                        ; uschovan† kl†vesa
edikeym  dw        ?                        ; kl†vesa od my®i


public   disk25,maxblok,maxsekt,sektclus,bajtsekt,bajtclus,parint25,paket
public   rezervs,sektroot,sektfat

disk25   db        ?                        ; disk pro operaci se sektory
maxblok  dw        ?                        ; maxim†ln° alokaán° blok disku
maxsekt  dd        ?                        ; maxim†ln° sektor disku
sektroot dw        ?                        ; á°slo prvn°ho sektoru ROOT
sektclus db        ?                        ; poáet sektorñ na alokaán° blok
sektfat  db        ?                        ; poáet sektorñ FAT
bajtsekt dw        ?                        ; poáet bajtñ na sektor
bajtclus dw        ?                        ; poáet bajtñ na alokaán° blok
rezervs  dw        ?                        ; poáet rezervovanòch sektorñ
parint25 db        ?                        ; parametry pro INT 25h
                                            ;   bit 0: 1=je obsluha paketem
                                            ;   bit 1: 1=je tabulka FAT16
                                            ;   bit 7: 1=reëim zobrazen° disku
paket    label     byte                   ;* paket pro áten° sektoru
         dd        ?                        ; 0: á°slo poá†teán°ho sektoru
         dw        ?                        ; 4: poáet sektorñ ke áten°
         dd        ?                        ; 6: adresa bufferu k naáten° dat



edinormk dw        ?                        ; uschovanò vhled kurzoru

public   countryh
countryh dd        ?                        ; adresa rutiny pro p©evod p°smen

public   envexec,adrfl,adrfr,numdskl,konecmaz

envexec  db        ?

adrfl    dw        ?
adrfr    dw        ?
numdskl  db        ?

public   findcit,findsouc
findcit  dw        ?                        ; á°taá nalezenòch souborñ
findsouc dd        ?                        ; souáet velikost° souborñ

public   hlpseg,hlpnum,hlptop,hlpkurz,helpbuf
hlpseg   dw        ?                        ; segment s n†povàdou
hlpnum   dw        ?                        ; poáet bajtñ n†povàdy v pamàti

konecmaz label     byte                     ; konec maz†n° dat

public   buffail
buffail  db        300 dup(?)               ; buffer pro hl†®en° chyby INT 24h
helpbuf  db        1024 dup(?)              ; buffer pro n†povàdu
;diskbuf  db        2048 dup(?)              ; diskovò buffer
;videoram dw        80*25*2 dup(?)           ; buffer pro £schovu obrazovky

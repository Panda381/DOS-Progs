; *****************************************************************************
;
;                     Definice oken voleb a n†povàd
;
; *****************************************************************************

tabhlp   dw        offset tab01
         dw        offset tab02
         dw        offset tab03
         dw        offset tab04
         dw        offset tab05
         dw        offset tab06
         dw        offset tab07
         dw        offset tab08
         dw        offset tab09
         dw        offset tab10
         dw        offset tab11
         dw        offset tab12
         dw        offset tab13
         dw        offset tab14
         dw        offset tab15
         dw        offset tab16
         dw        offset tab17
         dw        offset tab18
         dw        offset tab19
         dw        offset tab20
         dw        offset tab21
         dw        offset tab22
         dw        offset tab23
         dw        offset tab24
         dw        offset tab25
         dw        offset tab26
         dw        offset tab27
         dw        offset tab28
         dw        offset tab29
         dw        offset tab30
         dw        offset tab31
         dw        offset tab32
         dw        offset tab33
         dw        offset tab34
         dw        offset tab35


tab01:                                      ; povely s CTRL-
         db        1
         db        27
         db        1
         db        80
         db        18
         db        17,'$$',15
         db        ' Povely s CTRL- ',31
         db        2,'$Kurzor...$ '
         db        4,'$Obrazovka...$'
         db        5,'$Zvl†®tn°...$',31
         db        ' S vlevo',2,'(',0fbh,')'
         db        4,'C str†nka dolñ'
         db        5,'B form†tuj',31
         db        ' X dolñ',3,'(',0f9h,')'
         db        6,'(PgDn)',13,'odstavec',31
         db        ' D vpravo (',0fah,')'
         db        4,'R str†nka nahoru'
         db        3,'L pokraáuj',31
         db        ' E nahoru (',0f8h,')'
         db        6,'(PgUp)',13,'v hled†n°',31
         db        ' A slovo vlevo'
         db        3,'Z ©†dek dolñ'
         db        7,'M konec odstavce',31
         db        ' F slovo vpravo'
         db        2,'W ©†dek nahoru'
         db        7,'<Enter>',31
         db        ' I na dal®°'
         db        25,'N vloëen°',31
         db        3,'tabul†tor'
         db        6,'$Podmenu...$'
         db        8,'©†dku',31
         db        17,'J info/displej'
         db        5,'V vkl†d†n°',31
         db        2,'$Maz†n°...$'
         db        4,'K blok/soubor'
         db        8,'zap/vyp',31
         db        ' G znaku nad'
         db        5,'O form†tov†n°/'
         db        7,'<Insert>',31
         db        3,'kurzorem'
         db        8,'nastavov†n°'
         db        6,'\ zvl†®tn° znaky',31
         db        ' H znaku vlevo'
         db        3,'P typy p°sma'
         db        7,'- z†màna znakñ',31
         db        ' T slova vpravo'
         db        2,'Q p©esuny kurzoru/'
         db        1,'] text do buff.',31
         db        ' Y ©†dku'
         db        11,'hled†n°/z†màna'
         db        3,'^ text z buff.'
         db        0

tab02:                                      ; ^J
         db        0
         db        58
         db        1
         db        80
         db        16
         db        11,' CTRL J ',31
         db        ' B',2,'©†dky displeje',31
         db        ' C',2,'barvy displeje',31
         db        ' F',2,'blik†n° zap/vyp',31
         db        ' H',2,'pomoc zap/vyp',31
         db        ' -------------------',31
         db        ' G',2,'graf.editor',31
         db        ' I',2,'pracovn° prostor',31
         db        ' D',2,'z†pis data',31
         db        ' T',2,'z†pis áasu',31
         db        ' K',2,'kalend†©/hodiny',31
         db        ' -------------------',31
         db        ' R',2,'vòpoáty v textu',31
         db        ' S',2,'sloupcovÇ souáty',31
         db        ' M',2,'sloupcovò prñmàr'
         db        0

tab03:                                      ; ^K
         db        0
         db        35
         db        1
         db        80
         db        14
         db        14,'$$'
         db        17,' CTRL K ',31
         db        17,'$Blok....$',31
         db        ' B',2,'oznaáen° zaá†tku'
         db        6,'C',2,'kop°rov†n° ',31
         db        ' K',2,'oznaáen° konce'
         db        8,'V',2,'p©esunut°',31
         db        ' N',2,'sloupcovò blok'
         db        8,'Y',2,'maz†n°',31
         db        ' H',2,'zobrazen° zap/vyp'
         db        5,'R',2,'áten°',31
         db        ' T',2,'zmàna p°sma'
         db        11,'W',2,'uloëen°',31
         db        ' G',2,'p©enos z'
         db        ' jinÇho pracovn°ho prostoru',31
         db        ' ------------------------------------------',31
         db        ' D',2,'menu souboru'
         db        10,'E',2,'maz†n° textu',31
         db        ' P',2,'menu tisku'
         db        12,'L',2,'áten° textu',31
         db        '1-5 zmàna prac. prostoru'
         db        2,'S',2,'uloëen° textu',31
         db        ' Q',2,'ukonáen° KonTextu'
         db        5,'X',2,'start programu'
         db        0

tab04:                                      ; ^O
         db        0
         db        23
         db        1
         db        80
         db        15
         db        24,'$$'
         db        20,' CTRL O ',31
         db        3,'$P©ep°naáe zap/vyp'
         db        8,'Form†tov†n°$',31
         db        ' J',2,'zarovn†v†n°'
         db        11,'B',2,'form†t. po konec textu',31
         db        ' H',2,'dàlen° slov'
         db        11,'C',2,'centrov†n° ©†dku',31
         db        ' Q',2,'dàlen° s dotazem'
         db        6,'Z',2,'dvousloupcovÇ form†tov†n°',31
         db        ' V',2,'automat.tabul†tor',31
         db        ' M',2,'<Enter>=kon.odst.'
         db        7,'$Nastaven° str†nky$',31
         db        ' P',2,'zobrazen° str†nky'
         db        5,'I',2,'menu line†lu ©†dku',31
         db        ' T',2,'zobrazen° line†lu'
         db        5,'F',2,'pravò okraj=konec ©†dku',31
         db        ' N',2,'nedokumentn° m¢d'
         db        6,'L',2,'levò okraj=pozice kurzoru',31
         db        26,'R',2,'pravò okraj=pozice kurzoru',31
         db        26,'S',2,'poáet ©†dkñ na str†nku',31
         db        ' A',2,'zaá†tek odstavce',2,0f0h
         db        3,'E',2,'zobrazen° z†hlav°/paty',31
         db        ' U',2,'neform†tovat',6,0ffh
         db        3,'O',2,'blok jako z†hlav°/pata'
         db        0

tab05:                                      ; ^P
         db        0
         db        59
         db        1
         db        80
         db        9
         db        10,' CTRL P ',31
         db        ' N=norm†ln°',31
         db        ' F=zvòraznànÇ',31
         db        ' U=podtrëenÇ',31
         db        ' K=kurz°va',31
         db        ' B=®irokÇ',31
         db        ' H=nadsazenÇ',31
         db        ' T=podsazenÇ'
         db        0,0,0,0,0,0,0,0

tab06:                                      ; ^Q
         db        0
         db        39
         db        1
         db        80
         db        13
         db        30,' CTRL Q ',31
         db        ' A',2,'hled†n°/z†màna'
         db        5,'F',2,'hled†n°',31
         db        ' M',2,'nastaven° znaáky'
         db        3,'T',2,'makrokl†vesy',31
         db        ' L',2,'navr†cen° posledn°ch zmàn   ',31
         db        10,'$Pozice kurzoru...$',31
         db        ' S',2,'zaá†tek ©†dku'
         db        6,'D',2,'konec ©†dku',31
         db        ' E',2,'horn° okraj'
         db        8,'X',2,'doln° okraj',31
         db        ' R',2,'zaá†tek textu'
         db        6,'C',2,'konec textu',31
         db        ' B',2,'zaá†tek bloku'
         db        6,'K',2,'konec bloku',31
         db        ' P',2,'na znaáku'
         db        10,'Z',2,'pozice',31
         db        14,'$Maz†n°...$',31
         db        ' H',2,'po zaá†tek ©†dku'
         db        3,'Y',2,'po konec ©†dku'
         db        0,0

tab07:                                      ; ^JC
         db        1
         db        52
         db        1
         db        80
         db        10
         db        16,' CTRL JC ',31,31
         db        2,'--- Nastaven° barev ---',31
         db        ' Zadejte á°slo barvy nebo',31
         db        ' zvolte <Enter>=beze zmàny',31,31
         db        ' Barva p°sma (0..15):',31
         db        ' Barva okol° (0..15):'
         db        0

tab08:                                      ; ^JI
         db        1
         db        54
         db        1
         db        80
         db        13
         db        13,' CTRL JI ',31,31
         db        ' - Pracovn° prostor : - ',31
         db        '$   obsah          ©†dkñ$',31
         db        31,31,31,31,31,31
         db        ' text :'
         db        7,'B volnòch',31
         db        ' makra:'
         db        7,'B volnòch'
         db        0

tab09:                                      ; ^JK
         db        1
         db        49
         db        1
         db        80
         db        16
         db        19,' CTRL JK ',31
         db        31,31,31
         db        2,'PO',2,'óT',2,'ST',2,'ÄT',2,'Pè',2,'SO',2,'NE',31
         db        ' ============================',31
         db        31,31,31,31,31,31
         db        ' ============================',31
         db        1,0fbh,2,'p©edch.'
         db        2,0fah,' n†sled.  màs°c',31
         db        1,0f9h,2,'p©edch.',2,0f8h,' n†sled.  rok '
         db        0

tab10:                                      ; ^KD
         db        1
         db        61
         db        1
         db        80
         db        17
         db        8,' CTRL KD ',31
         db        ' áti text      ^KL',31
         db        ' uloë text     ^KS',31
         db        ' áti blok      ^KR',31
         db        ' uloë blok     ^KW',31
         db        ' zru® soubor',31
         db        ' p©ejmenuj soubor',31
         db        ' kop°ruj soubor',31
         db        ' start programu^KX',31
         db        ' uloë nastaven°',31
         db        ' konec KonTextu^KQ',31
         db        ' ----------------',31
         db        ' form†t KonText',31
         db        ' form†t Layout',31
         db        ' form†t ASCII',31
         db        ' z†loha BAK'
         db        0

tab11:
         db        0
         db        52
         db        1
         db        80
         db        3
         db        'a'
         db        0

tab12:                                      ; zad†n° str†nek k tisku
         db        1
         db        52
         db        1
         db        80
         db        11
         db        31
         db        4,'-- tisk textu   --',31
         db        2,'  Zadejte á°sla nebo     ',31
         db        '   <Enter> = ë†dn† zmàna ',31,31
         db        ' prvn° str†nka:  ',5,'1',31
         db        ' koneán† str†nka:',31
         db        ' prvn° á°slo strany:',2,'1',31
         db        ' exempl†©ñ:',11,'1'
         db        0

tab13:                                      ; ^KP
         db        1
         db        55
         db        1
         db        80
         db        7
         db        13,' CTRL KP ',31,31
         db        ' - prob°h† tisk textu -',31,31
         db        9,'d†le',31
         db        9,'p©eru®en°'
         db        0

tab14:                                      ; ^KQ
         db        1
         db        25
         db        6
         db        54
         db        14
         db        16,' CTRL KQ ',31,31
         db        3,'T°mto povelem ukoná°te',31
         db        ' KonText a navr†t°te se zpàt',31
         db        2,'do operaán°ho systÇmu !!!',31,31
         db        2,'Stisknàte <Enter> = konec',31
         db        3,'nebo <Esc> = pokraáuj'
         db        0

tab15:                                      ; ^OE
         db        0
         db        58
         db        1
         db        80
         db        7
         db        10,' CTRL OE ',31
         db        31
         db        'Jako blok se zobraz°:',31,31
         db        4,'K = z†hlav°',31
         db        4,'F = pata '
         db        0

tab16:                                      ; ^OI
         db        0
         db        53
         db        1
         db        80
         db        15
         db        14,' CTRL OI ',31
         db        2,'-- Tabul†tory/okraje --',31,31
         db        2,0fah,3,'kurzor vpravo',31
         db        2,0fbh,3,'kurzor vlevo',31
         db        ' End',2,'...k pravÇmu okraji',31
         db        ' Home ...k levÇmu okraji',31
         db        2,'L',3,'levò okraj',31
         db        2,'R',3,'pravò okraj',31
         db        ' Tab',2,'nastav/zru® tabul.',31
         db        2,'#',3,'dekadickò tabul†tor',31
         db        ' Del',2,'ru®en°/n†vrat tabul.',31
         db        ' Ret',2,'ukonáen° volby',31
         db        ' Esc',2,'p©eru®en° volby'
         db        0

tab17:                                      ; ^OO
         db        0
         db        58
         db        1
         db        80
         db        7
         db        10,' CTRL OO ',31,31
         db        ' Blok se uloë° jako: ',31,31
         db        4,'K = z†hlav° ',31
         db        4,'F = pata'
         db        0

tab18:                                      ; ^OS
         db        1
         db        46
         db        1
         db        80
         db        11
         db        22,' CTRL OS ',31,31
         db        '   Zadejte novÇ nastaven° nebo',31
         db        2,'stisknàte <Enter>=beze zmàny: ',31,31
         db        ' ©†dkñ na str†nku (4..99):',31
         db        ' z toho: z†hlav°  (0..10):',31
         db        7,'  pata   ',2,'(0..10):',31,31
         db        ' rozteá ©†dkñ :',9,'cm'
         db        0

tab19:                                      ; ^OZ
         db        1
         db        25
         db        4
         db        54
         db        14
         db        17,' CTRL OZ ',31,31
         db        3,'Tento povel zform†tuje',31
         db        4,'text na tÇto stranà',31
         db        4,'dvousloupcovà. NovÇ',31
         db        3,'form†tov†n° jië nad†le',31
         db        7,'nebude moënÇ !',31
         db        10,'Zvolte:',31
         db        5,'<Enter> = potvrzen°',31
         db        2,'<Esc> = p©eru®en° povelu'
         db        0

tab20:                                      ; volby pro hled†n°
         db        0
         db        58
         db        1
         db        80
         db        9
         db        10,' VOLBY ',31
         db        ' B',2,'zpàtnò smàr',31
         db        ' G',2,'v celÇm textu',31
         db        ' L',2,'v celÇm bloku',31
         db        ' W',2,'pouze celÇ slovo',31
         db        ' U',2,'nerozli®uje velk†',31
         db        4,'a mal† p°smena'
         db        0

tab21:                                      ; hl†®en° - Text nebude uloëen
         db        1
         db        27
         db        7
         db        54
         db        13
         db        31
         db        2,' Text v prac.prost.',31
         db        2,'nebude uloëen na disk !',31,31
         db        3,'<Enter>=pokraáov†n°',31
         db        5,'<Esc>=p©eru®en°'
         db        0

tab22:                                      ; zvl†®tn° znaky
         db        1
         db        34
         db        1
         db        80
         db        15
         db        28,' Zvl†®tn° znaky '
         db        0

tab23:                                      ; hl†®en° SETUP
         db        1
         db        25
         db        4
         db        54
         db        13
         db        19,' SETUP ',31,31
         db        ' Tato volba zpñsob°, ëe p©i',31
         db        2,'dal®°m spu®tàn° KonTextu',31
         db        2,'bude opàt pouëito stejnÇ',31
         db        3,'nastaven° parametrñ.',31,31
         db        3,'Zvolte <Enter>=uloëen°',31
         db        4,'nebo <Esc>=p©eru®en°.'
         db        0

tab24:                                      ; CTRL-KN
         db        0
         db        50
         db        1
         db        80
         db        8
         db        18,' CTRL KN ',31,31
         db        3,'Nastaven° sloupc.bloku:',31,31
         db        ' B',2,'zaá†tek (levò horn° roh)',31
         db        ' K',2,'konec (pravò doln° roh) '
         db        0

tab25:                                      ; sÇriovò tisk
         db        1
         db        50
         db        1
         db        80
         db        10
         db        31
         db        5,'--- SÇriovò tisk --',31
         db        ' Pros°m, zadejte novou volbu',31
         db        2,'nebo <Enter> = beze zmàny:',31,31
         db        ' Datovò prostor',2,'(1..5):',31
         db        ' P©eform†tov†n° ',2,'(J/N):',31
         db        0

tab26:                                      ; pauza sÇriovÇho tisku
         db        1
         db        30
         db        7
         db        51
         db        13
         db        31
         db        ' SÇriovò tisk-pauza',31
         db        ' pro',2,'vòmànu pap°ru',31,31
         db        ' pokraáov†n° = <Enter> ,',31
         db        4,'p©eru®en° = <ESC>'
         db        0
;˛
tab27:                                      ; volba KURZOR
         db        1                        ; ©†dek
         db        1                        ; pozice
         db        1                        ; aktivn° poloëka
         db        24 ;21                   ; ®°©ka okna
         db        12                       ; ©†dkñ
         db        31
         db        ' zaá†tek textu     ^QR',31
         db        ' konec textu       ^QC',31
         db        ' zaá†tek bloku     ^QB',31
         db        ' konec bloku       ^QK',31
         db        ' na znaáku         ^QP',31
         db        ' nastaven° znaáky  ^QM',31
         db        ' na danou pozici   ^QZ',31
         db        ' vyhled†n° textu   ^QF',31
         db        ' hled†n°/z†màna    ^QA',31
         db        ' dal®° hled†n°     ^L'
         db        0

tab28:                                      ; volba MAZèNã
         db        1
         db        3
         db        1
         db        24 ;21
         db        9
         db        31
         db        ' slovo vpravo    ^T',31
         db        ' po kurzor       ^QH',31
         db        ' od kurzoru      ^QY',31
         db        ' celò ©†dek      ^Y',31
         db        ' celò blok       ^KY',31
         db        ' obnoven° zmàn   ^QL',31
         db        ' celò text       ^KE'
         db        0

tab29:                                      ; volba BLOK
         db        1
         db        12
         db        1
         db        33 ;29
         db        14
         db        31
         db        ' zaá†tek bloku  ^KB',31
         db        ' konec bloku    ^KK',31
         db        ' sloupc.blok ',0dah,0c4h,' ^KNB',31
         db        ' sloupc.blok',2,0c4h,0d9h,'^KNK',31
         db        ' maz†n°         ^KY',31
         db        ' p©em°stàn°     ^KV',31
         db        ' kop°rov†n°     ^KC',31
         db        ' p©enos z prost.^KG',31
         db        ' áten° z disku  ^KR',31
         db        ' uloëen° na disk^KW',31
         db        ' zmàna p°sma    ^KT',31
         db        ' oznaáen° bloku ^KH'
         db        0

tab30:                                      ; volba PãSMO
         db        1
         db        19
         db        1
         db        40 ;37
         db        9
         db        31
         db        ' norm†ln°        ^PN',31
         db        ' zvòraznànÇ      ^PF',31
         db        ' podtrëenÇ       ^PU',31
         db        ' kurz°va         ^PK',31
         db        ' ®irokÇ          ^PB',31
         db        ' nadsazenÇ       ^PH',31
         db        ' podsazenÇ       ^PT'
         db        0

tab31:                                      ; volba FORMèT.
         db        1
         db        26
         db        1
         db        49 ;46
         db        14
         db        31
         db        ' po konec odstav.  ^B',31
         db        ' po konec textu    ^OB',31
         db        ' dvousloupcovà     ^OZ',31
         db        ' centruj ©†dek     ^OC',31
         db        ' zarovn†v†n°       ^OJ',31
         db        ' rozdàlov†n°       ^OH',31
         db        ' s dotazem         ^OQ',31
         db        ' auto-tabul†tor    ^OV',31
         db        ' <Enter>=odstavec  ^OM',31
         db        ' zaá†t. odstavce ',0f0h,' ^OA',31
         db        ' konec odstavce',2,0f1h,' Ent',31
         db        ' neform†tovat',4,0ffh,' ^OU'
         db        0

tab32:                                      ; volba STRèNKA
         db        1
         db        32
         db        1
         db        60 ;56
         db        14
         db        31
         db        ' ©†dkñ na str†nku      ^OS',31
         db        ' menu line†lu ©†dkñ    ^OI',31
         db        ' levò okraj=kurzor     ^OL',31
         db        ' pravò okraj=kurzor    ^OR',31
         db        ' pravò okraj=konec ©†d.^OF',31
         db        ' zobrazen° z†hlav°     ^OEK',31
         db        ' zobrazen° paty        ^OEF',31
         db        ' blok jako z†hlav°     ^OOK',31
         db        ' blok jako pata        ^OOF',31
         db        ' zobraz. str†nkov†n°   ^OP',31
         db        ' zobr. line†lu ©†dku   ^OT',31
         db        ' nedokumentn° m¢d      ^ON'
         db        0

tab33:                                      ; volba DISPLEJ
         db        1
         db        43
         db        1
         db        64 ;61
         db        8
         db        31
         db        ' TEXTOVù m¢d     ^JB',31
         db        ' GRAFICKù m¢d    ^JB',31
         db        ' ZHUõTâNù m¢d    ^JB',31
         db        ' zmàna barev     ^JC',31
         db        ' n†povàda        ^JH',31
         db        ' blik†n° kurz.   ^JF'
         db        0

tab34:                                      ; volba EXTRA
         db        1
         db        51
         db        1
         db        72 ;69
         db        14
         db        31
         db        ' prac. prostor   ^JI',31
         db        ' text do bufferu ^]',31
         db        ' text z bufferu  ^^',31
         db        ' z†pis áasu      ^JT',31
         db        ' z†pis data      ^JD',31
         db        ' kalend†©        ^JK',31
         db        ' grafickò editor ^JG',31
         db        ' zvl†®tn° znaky  ^\',31
         db        ' makrokl†vesy    ^QT',31
         db        ' kalkul†tor      ^JR',31
         db        ' sloupc. souáet  ^JS',31
         db        ' sloupc. prñmàr  ^JM'
         db        0

tab35:                                      ; volba TISK, ^KP
         db        1
         db        59
         db        1
         db        77
         db        15
         db        6,' CTRL KP ',31
         db        ' tisk textu',31
         db        ' sÇriovò tisk',31
         db        ' áten° instalace',31
         db        ' zmàna instalace',31
         db        ' ---------------',31
         db        ' vy®®° kvalita',31
         db        ' p°smo Elite',31
         db        ' £zkÇ p°smo',31
         db        ' proporcion†l.',31
         db        ' dvoj. p©etisk',31
         db        ' hustÇ ©†dkov.',31
         db        ' samostat.list',31
         db        ' vòmàna pap°ru'
         db        0

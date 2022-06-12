
INCLUDE  DEF.ASM

; ------ p©ep¡na‡e v textu (definov ny v DEF.ASM !)

;LF       EQU       10                       ; nov˜ © dek textu
;FF       EQU       12                       ; nov  str nka
;CR       EQU       13                       ; n vrat na za‡ tek © dku
;TSWCBOLD EQU       4                        ; zv˜raznˆn‚ p¡smo      (SHIFT-F1)
;TSWCKEYS EQU       3                        ; kl vesy na kl vesnici (SHIFT-F2)
;TSWCNADP EQU       2                        ; nadpisy               (SHIFT-F3)
;TSWCNAD2 EQU       1                        ; nadpisy 2             (SHIFT-F4)
;TSWCFONT EQU       5                        ; zmˆna fontu 16/8 linek (SHIFT-F5)
;TSWCPODK EQU       0                        ; podklad               (SHIFT-F6)

XF       EQU       TSWCFONT                 ; zmˆna fontu
XP       EQU       TSWCPODK                 ; barva podkladu (‘lut )
X        EQU       db

HelpSeg  SEGMENT   BYTE PUBLIC

HelpDat  LABEL     BYTE

; ------ 1
;ş
x LF,XF
x'                 ',XP,   'ÕÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ¸',XP,CR
x'                 ',      'ÚÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑ¿',LF
x'                 ',      '                                           Ü¸',CR
x'                 ',XP,   'ŞÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛİ',XP,CR
x'                 ',      'Ç o                                      o ¶',LF
x'                 ',      '                                           Ûİ',CR
x'                 ',XP,   'ŞÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛİ',XP,CR
x'                 ',      'Ç                                          ¶',LF
x'                 ',   XF,'                                           Ûİ',XF,CR
x'                 ',XP,XF,'ŞÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛİ',XF,XP,CR
x'                 ',      'Ç                 VSEMI10                  ¶',LF
x'                 ',      'Ç                                          ¶',LF
x'                 ',      '                                           Ûİ',CR
x'                 ',XP,   'ŞÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛİ',XP,CR

IFDEF    DEMO
x'                 ',      'Ç             verze 2.22 DEMO              ¶',LF
ELSE
x'                 ',      'Ç           verze  2.22 FREEWARE           ¶',LF
ENDIF

x'                 ',   XF,'                                           Ûİ',XF,CR
x'                 ',XP,XF,'ŞÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛİ',XF,XP,CR
x'                 ',      'Ç    V˜uka psan¡ na kl vesnici po‡¡ta‡e    ¶',LF
x'                 ',      'Ç                                          ¶',LF
x'                 ',      '                                           Ûİ',CR
x'                 ',XP,XF,'ŞÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛİ',XF,XP,CR
x'                 ',      'Ç     GEMA Soft,  Ro‘nov pod Radho¨tˆm     ¶',LF
x'                 ',   XF,'                                           Ûİ',XF,CR
x'                 ',XP,XF,'ŞÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛİ',XF,XP,CR
x'                 ',      'Ç        (c) Miroslav Nˆme‡ek, 2022        ¶',LF
x'                 ',      'Ç                                          ¶',LF
x'                 ',   XF,'                                           Ûİ',XF,CR
x'                 ',XP,XF,'ŞÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛİ',XF,XP,CR

;IFNDEF    DEMO
;x'                 ',      'Ç           licence: '
;LicCis2  db        '00000-00000           ¶',LF
;ELSE
x'                 ',      'Ç                                          ¶',LF
;ENDIF

x'                 ',      'Ç o                                      o ¶',LF
x'                 ',      ' ŞÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛİ',CR
x'                 ',XP,   'Ôßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß¾',XP,CR
x'                 ',      'ÀÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÙİ',LF
x'                 ',      ' Ôßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß¾',LF
x LF
x'                                                  ÚÑÑÑÑÑÑÑÑÑÑ¿',LF
x'    Textem  t‚to  n povˆdy  m–‘ete kl vesami      Ç  PageUp  ¶   ',30,' str nka',LF
x'                                                  Ç          ¶°° ',  '³ zpˆt',LF
x'    PageUp a PageDown listovat po str nk ch.      ÀÏÏÏÏÏÏÏÏÏÏÙ°°',LF
x'                                                    °°°°°°°°°°°°',LF
x'    Kl vesami  Home  a  End  se p©esunete na      ÚÑÑÑÑÑÑÑÑÑÑ¿',LF
x'                                                  Ç PageDown ¶   ',  '³ str nka',LF
x'    prvn¡  nebo  posledn¡  str nku n povˆdy.      Ç          ¶°° ',31,' vp©ed',LF
x'                                                  ÀÏÏÏÏÏÏÏÏÏÏÙ°°',LF
x'    Kl vesou ESC n povˆdu opust¡te.                 °°°°°°°°°°°°',LF
x LF
x LF                                                
x'                                                  ÚÑÑÑÑÑÑÑÑÑÑ¿',LF
x'                                                  Ç   Home   ¶   ',30,' prvn¡',LF
x'              ÚÑÑÑÑÑÑÑÑÑÑ¿                        Ç          ¶°° ',  '³ str nka',LF
x'              Ç   ESC    ¶    opu¨tˆn¡            ÀÏÏÏÏÏÏÏÏÏÏÙ°°',LF
x'              Ç          ¶°°  n povˆdy              °°°°°°°°°°°°',LF
x'              ÀÏÏÏÏÏÏÏÏÏÏÙ°°                      ÚÑÑÑÑÑÑÑÑÑÑ¿',LF
x'                °°°°°°°°°°°°                      Ç   End    ¶   ',  '³ posledn¡',LF
x'                                                  Ç          ¶°° ',31,' str nka',LF
x'                                                  ÀÏÏÏÏÏÏÏÏÏÏÙ°°',LF
x'                                                    °°°°°°°°°°°°',LF
IFDEF    DEMO
x LF
x'DEMO verze je omezena na 5 lekc¡ a do protokolu se neukl daj¡ v˜sledky testu !',LF
ENDIF
x FF

; ------ 2
;ş
x LF,XF
x'                         ÚÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑ¿         ///',LF
x'                         Ç                     ¶        ',39,'   /',LF
x'                         Ç                     ¶°°     < o  )',LF
x'                         Ç     Hlavn¡ menu     ¶°°           - .',LF
x'                         Ç                     ¶°°       \',LF
x'                         Ç                     ¶°°          (  \ \',LF
x'                         Ç                     ¶°°         \',LF
x'                         ÀÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÙ°°     \\    -     \',LF
x'                           °°°°°°°°°°°°°°°°°°°°°°°      \\    \\- \',LF
x'                                                         \====((======',LF
x'                                                                   \\\',LF
x'                                                                     \\',LF,XF
x LF
x'Po spu¨tˆn¡ programu VSEMI10 se zobraz¡ hlavn¡ menu programu.  Funkce hlavn¡ho',LF
x'menu  lze volit buƒ nastaven¡m ukazatele na po‘adovan˜ © dek a stiskem kl vesy',LF
x'ENTER  nebo  stiskem zv˜raznˆn‚ho p¡smene voleb menu. Ze v¨ech funkc¡ programu',LF
x'se lze navr tit zpˆt do hlavn¡ho menu stiskem kl vesy ESC.',LF
x LF
x'   V˜uka     - v˜ukov‚ lekce pro v˜uku psan¡',LF
x'   Cvi‡en¡   - procvi‡ov n¡ znalost¡ psan¡m podle vlastn¡ ti¨tˆn‚ p©edlohy',LF
x'   Test      - test znalost¡ opisov n¡m p©ipraven‚ho textu s vyhodnocen¡m chyb',LF
x'   Nastaven¡ - volba kl vesnice a nastaven¡ parametr– programu',LF
x'   Pomoc     - tato n povˆda k programu (z–stane naposledy zobrazen  str nka)',LF
x'   Konec     - ukon‡en¡ programu VSEMI10, n vrat do opera‡n¡ho syst‚mu',LF
x FF

; ------ 3
;ş
x LF,XF
x'                           ÚÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑ¿                  ÜÜ',LF
x'                           Ç                 ¶           ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ',LF
x'                           Ç                 ¶°°         ',XF,'ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ',XF,CR
x'                                                            A  B‚  C‚  D‚ ',LF
x'                           Ç      V˜uka      ¶°°',LF
x'                           Ç                 ¶°°         ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ',CR
x'                                                           ÄÄÄÄÄÄÄÄÄÄÄÄ',LF
x'                           Ç                 ¶°°         ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ',LF
x'                           Ç                 ¶°°           / /      \ \',LF
x'                           ÀÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÙ°°          / /        \ \',LF
x'                             °°°°°°°°°°°°°°°°°°°          ßß          ßß',LF,XF
x LF
x'Po proveden¡ volby V˜uka z hlavn¡ho menu se zobraz¡ nab¡dka lekc¡ v˜uky. Obsah',LF
x'i uspo© d n¡ lekc¡ z vis¡ na zvolen‚ kl vesnici, proto je pot©eba p©ed vlastn¡',LF
x'v˜ukou zvolit nejvhodnˆj¨¡ typ kl vesnice (viz volba Nastaven¡).',LF
x LF
x'Po volbˆ lekce kl vesou ENTER se zobraz¡ text lekce k prob¡ran˜m kl ves m. Pod',LF
x't¡mto  textem  je cvi‡ebn¡ © dek. —kolem je text na tomto © dku opisovat podle',LF
x'instrukc¡  v  textu lekce. Kl vesou F2 lze zapnout/vypnout metronom. P©i tomto',LF
x'cvi‡en¡  nen¡  d–le‘it   rychlost,  ale  p©esnost. Mus¡ b˜t naps no bez jedin‚',LF
x'chyby. Jednotliv˜mi cvi‡en¡mi lze listovat pomoc¡ kl ves PageUp a PageDown.',LF
x LF
x'Po  spr vn‚m  ops n¡  cvi‡ebn¡ch © dk– je p©edlo‘en v¡ce© dkov˜ cvi‡ebn¡ text.',LF
x'V tomto testu je ji‘ d–le‘it  rychlost. Pokra‡ov n¡ ve v˜uce je povoleno pouze',LF
x'je-li  chybovost men¨¡ ne‘ 0.80 % a v˜kon minim lnˆ 100 £hoz–/minutu (v˜kon se',LF
x'sni‘uje o chyby). V˜ukov˜ test je mo‘n‚ opustit kl vesou ESC.',LF
x FF

; ------ 4
;ş
x LF,XF
x'                           ÚÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑ¿                                 ',LF
x'                           Ç                 ¶                                 ',LF
x'                           Ç                 ¶°°                   -^          ',LF
x'                           Ç     Cvi‡en¡     ¶°°        ^u^     o-',39,'o ³         ',LF
x'                           Ç                 ¶°°       (( o ))    \    ³         ',LF
x'                           Ç                 ¶°°        \u/      ',39,'-   \ ^      ',LF
x'                           Ç                 ¶°°       o(          \   \))     ',LF
x'                           ÀÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÙ°°         )o        ³ ^(        ',LF
x'                             °°°°°°°°°°°°°°°°°°°     WwWwWwWwWw   (_/(__/      ',LF,XF
x LF
x'Po  proveden¡  volby  Cvi‡en¡  z  hlavn¡ho menu si program vy‘ d  zad n¡ jm‚na',LF
x'zkou¨en‚  osoby.  Doporu‡uje  se zadat p©¡jmen¡, jm‚no a p©¡padn‚ dal¨¡ £daje,',LF
x'je v¨ak mo‘n‚ jen stisknout ENTER bez zad n¡. P©i zad v n¡ lze kl vesami Home,',LF
x'End, vlevo a vpravo text editovat a t‚‘ obnovit ji‘ d©¡ve zadan˜ text.',LF
x LF
x'Po  zad n¡  jm‚na  osoby lze za‡¡t ps t text. Program pr–bˆ‘nˆ ukazuje na lev‚',LF
x'stranˆ  mˆ©¡tka dosa‘en˜ v˜kon (v £hozech/minutu) a na prav‚ stranˆ ubˆhl˜ ‡as',LF
x'(od okam‘iku stisku prvn¡ kl vesy). Na konci psan‚ho © dku se zobrazuj¡ £hozy.',LF
x'Kl vesou F2 lze zapnout/vypnout metronom, kl vesou F3 indikaci stisku kl vesy.',LF
x LF
x'Cvi‡en¡ lze ukon‡it stiskem kl vesy ESC (‡as se po‡¡t  po naposledy stisknutou',LF
x'kl vesu) nebo je ukon‡eno dosa‘en¡m zadan‚ho ‡asov‚ho omezen¡ (viz Nastaven¡).',LF
x'Na  obrazovce se zobraz¡ po‡et £hoz– a dosa‘en˜ v˜kon a sou‡asnˆ se do souboru',LF
x'ulo‘¡ protokol o proveden¡ testu (viz V˜stupn¡ protokol).',LF
x FF

; ------ 5
;ş
x LF,XF
x'                           ÚÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑ¿                                 ',LF
x'                           Ç                 ¶                                 ',LF
x'                           Ç                 ¶°°                  °°°°°        ',LF
x'                           Ç      Test       ¶°°         /       °°°°°°°°      ',LF
x'                           Ç                 ¶°°       /  \     °°°°°°°°°°     ',LF
x'                           Ç                 ¶°°                /o°°°°°°°°     ',LF
x'                           Ç                 ¶°°      ³    ³   /   °°°°°°°°    ',LF
x'                           ÀÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÙ°°              o_,_ _°°°°°°°\   ',LF
x'                             °°°°°°°°°°°°°°°°°°°       \__/      (/     \)     ',LF,XF
x LF
x'Po  proveden¡  volby Test z hlavn¡ho menu se zad  jm‚no jako ve volbˆ Cvi‡en¡.',LF
x'Po  zad n¡ jm‚na se zobraz¡ seznam test– (testy jsou ulo‘eny v adres ©i TESTY,',LF
x'vnit©n¡  n rodn¡ k¢d Kamenick˜ch - KEYBCS2). Seznamem je mo‘n‚ listovat pomoc¡',LF
x'kl ves PageUp a PageDown, test se zvol¡ kl vesou ENTER.',LF
x LF
x'Po  volbˆ testu se zobraz¡ v doln¡ ‡ sti obrazovky text testu. Bˆhem opisov n¡',LF
x'textu  se  zobrazuje v˜kon, ‡as a £hozy jako ve volbˆ Cvi‡en¡. Nad zapisovan˜m',LF
x'© dkem se zobrazuj¡ chyby, p©i povolen‚ editaci a‘ po odesl n¡ kl vesou ENTER.',LF
x'Kl vesou F2 lze zapnout/vypnout metronom, kl vesou F3 indikaci stisku kl vesy.',LF
x LF
x'Test  lze  p©eru¨it stiskem kl vesy ESC (‡as se po‡¡t  po naposledy stisknutou',LF
x'kl vesu) nebo je p©eru¨en dosa‘en¡m zadan‚ho ‡asov‚ho omezen¡ (viz Nastaven¡).',LF
x'Na  obrazovce se zobraz¡ po‡et £hoz–, dosa‘en˜ v˜kon a chybovost a sou‡asnˆ se',LF
x'do souboru ulo‘¡ protokol o proveden¡ testu (viz V˜stupn¡ protokol).',LF
x FF

; ------ 6
;ş
x LF,XF
x'                         ÚÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑ¿        (,)',LF
x'                         Ç                     ¶      ((,o))',LF
x'                         Ç  V˜stupn¡ protokol  ¶°°   ( ,o),)        ÄÄÄÄ',LF
x'                         Ç                     ¶°°   ((o, o )   ___//__\\',LF
x'                         Ç                     ¶°°     (o³)    /) o        \',LF
x'                         ÀÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÙ°°      ³³     \__________³',LF
x'                           °°°°°°°°°°°°°°°°°°°°°°°      ³³       \_/   \_/',LF,XF
x LF
x'Ve  funkc¡ch Cvi‡en¡ a Test se vytv ©¡ soubor v˜stupn¡ho protokolu o proveden¡',LF
x'testu.  Tento  soubor  je  ulo‘en do adres ©e PROTOKOL programu VSEMI10. Jm‚no',LF
x'souboru je odvozeno od jm‚na testovan‚ osoby (p©¡jmen¡ bez h ‡k– a ‡ rek) nebo',LF
x'se pou‘ije jako implicitn¡ jm‚no znak $ (nen¡-li jm‚no zad no).',LF
x LF,XF
x'P©¡pona  jm‚na  souboru je zvolena tak, aby p©i abecedn¡m t©¡dˆn¡ souhlasilo i',LF
x'‡asov‚ t©¡dˆn¡ soubor–. Prvn¡ znak p©¡pony ud v  ‡¡slo mˆs¡ce (pro 10 a‘ 12 se',LF
x'pou‘ij¡  p¡smena  A a‘ C). Druh˜ znak ud v  ‡¡slo dne (pro 10 a‘ 31 se pou‘ij¡',LF
x'p¡smena A a‘ V). T©et¡ znak ud v  po©adov‚ ‡¡slo, pokud soubor ji‘ existuje.',LF
x LF,XF
x'ÚÄÄÄÄÄÄÄÄÄÄÄ V z hlav¡ protokolu jsou uvedeny n sleduj¡c¡ polo‘ky: ÄÄÄÄÄÄÄÄÄÄ¿',LF,XF
x'³ Jm‚no: jm‚no testovan‚ osoby         ³ V˜kon: ‡ist˜ v˜kon (£hoz–/minutu)   ³',LF
x'³ Datum: datum prov dˆn¡ testu         ³ Oprav: po‡et proveden˜ch oprav      ³',LF
x'³   €as: ‡as prov dˆn¡ testu           ³ Kl v.: nastaven  kl vesnice         ³',LF
x'³ D‚lka: d‚lka testu v min. a sek.     ³  Test: jm‚no souboru testu          ³',LF
x'³ —hoz–: po‡et hrub˜ch £hoz– celkem    ³  Chyb: po‡et chyb a chybovost v %   ³',LF,XF
x'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ',LF,XF
x'Za  z hlav¡m  protokolu  je mezi dvˆma ‡arami ulo‘en zapisovan˜ text. Na konci',LF
x'ka‘d‚ho © dku je uveden po‡et £hoz– na © dku a za lom¡tkem po‡et chyb. V textu',LF
x'je  p©ed ka‘dou chybou uveden znak _ (pro zv˜raznˆn¡ chyby). Za jednu chybu je',LF
x'pova‘ov no: z mˆna 2 znak–, chybˆj¡c¡ znak, znak nav¡c,  chybn˜  znak.  Nejsou',LF
x'detekov ny  rozs hlej¨¡  chyby (z mˆna slov, © dk–) ani nen¡ prov dˆna korekce',LF
x'p©i chybˆ v posledn¡ch 10 £hozech - tyto chyby je nutno o¨et©it ru‡nˆ.',LF
x FF

; ------ 7
;ş
x LF,XF
x'                           ÚÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑ¿       ______Û_',LF
x'                           Ç                 ¶      /ÄÄÄÄÄÄÄÄ\',LF
x'                           Ç                 ¶°°   /ÄÄÄÄÄÄÄÄÄÄ\',LF
x'                           Ç    Nastaven¡    ¶°°  /ÄÄÄÄÄÄÄÄÄÄÄÄ\  (__)',LF
x'                           Ç                 ¶°°   ³          ³   (oo)',LF
x'                           Ç                 ¶°°   ³ÉÍËÍ» ÉÍÍ»³  *(__)ÄÄÄ',LF
x'                           Ç                 ¶°°   ³ÌÍÎÍ¹ º, º³    \ ___ )\',LF
x'                           ÀÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÙ°°   ³ÈÍÊÍ¼ º  º³     º   º  *',LF
x'                             °°°°°°°°°°°°°°°°°°°   ÍÍÍÍÍÍÍÍÍÍÍÍ     ß   ß',LF,XF
x LF
x'Po  proveden¡ volby Nastaven¡ z hlavn¡ho menu se zobraz¡ menu volby kl vesnice',LF
x'a nastaven¡ parametr– programu. Zmˆna p©ep¡na‡– se prov d¡ kl vesou ENTER nebo',LF
x'kl vesou MEZERA. Ka‘d  zmˆna se ihned ulo‘¡ do souboru konfigurace programu.',LF
x LF
x' P¡sa©sk  kl vesnice          - zvol¡ se p¡sa©sk  kl vesnice (typ psac¡ stroj)',LF
x' 1. program torsk  kl vesnice - zvol¡ se program torsk  kl vesnice (typ CSKEY)',LF
x' 2. program torsk  kl vesnice - zvol¡ se program torsk  kl vesnice (typ T602)',LF
x' Anglick  kl vesnice          - zvol¡ se p–vodn¡ IBM kl vesnice',LF
x' Metronom                     - p©i psan¡ textu lupe metronom (t‚‘ kl vesa F2)',LF
x' Rychlost metronomu           - nastaven¡ rychlosti metronomu (tik– za minutu)',LF
x' Zvukov  indikace             - p©i stisku kl vesy se ozve lupnut¡ (t‚‘ F3)',LF
x' Omezen¡ d‚lky testu          - maxim ln¡ d‚lka testu a cvi‡en¡ (v minut ch)',LF
x' Editace chyb                 - ',XF,'p©i  testu a cvi‡en¡ povolena editace (oprava)',LF
x'                                chyb kl vesou BS (t‚‘ DELETE nebo ¨ipka VLEVO)',LF
x LF,LF
x'Nastaven¡m atributu R/O souboru VSEMI10.CNF lze zablokovat zmˆnu konfigurace.',LF
x FF

; ------ 8
;ş
x LF,XF
x'                        ÚÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑ¿                   )',LF
x'                        Ç                       ¶                  ( ___',LF
x'                        Ç  P¡sa©sk  kl vesnice  ¶°°                ³_³Û³',LF
x'                        Ç                       ¶°°       ‚.B      |   ³',LF
x'                        Ç                       ¶°°      E.Cˆ.A  )==ÄÄÄ=.',LF
x'                        ÀÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÙ°°     F‡ƒ.¢¨.D   (ooo)',LF
x'                          °°°°°°°°°°°°°°°°°°°°°°°°°   cXaQf“R.y„Y abcdefghijkl',LF,XF
x LF
x'P¡sa©sk   kl vesnice  m   rozlo‘en¡ kl ves shodn‚ s kl vesnic¡ ‡esk‚ho psac¡ho',LF
x'stroje.  Je  proto ur‡ena pro p¡sa©e p©ivykl‚ psac¡mu stroji a pro bˆ‘n‚ psan¡',LF
x'text– s ‡esk˜mi znaky s diakritikou.',LF,XF
x LF
x'        ÉÍÍÍËÍÍÍËÍÍÍËÍÍÍËÍÍÍËÍÍÍËÍÍÍËÍÍÍËÍÍÍËÍÍÍËÍÍÍËÍÍÍËÍÍÍËÍÍÍÍÍÍÍ»',LF
x'        º ; º 1 º 2 º 3 º 4 º 5 º 6 º 7 º 8 º 9 º 0 º % º ~ º<-BkSpcº',LF
x'        º ` º + º ˆ º ¨ º ‡ º © º ‘ º ˜ º   º ¡ º ‚ º = º ',39,' º       º',LF
x'        ÌÍÍÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÍÍÍÍ¹',LF
x'        ºTab<-º Q º W º E º R º T º Z º U º I º O º P º / º ( º     º',LF
x'        º   ->º   º   º   º   º   º   º   º   º   º   º £ º ) º     º',LF
x'        ÌÍÍÍÍÍÊËÍÍÊËÍÍÊËÍÍÊËÍÍÊËÍÍÊËÍÍÊËÍÍÊËÍÍÊËÍÍÊËÍÍÊËÍÍÊËÍÍ¼     º',LF
x'        ºCpsLckº A º S º D º F º G º H º J º K º L º " º ! º  <-',39,'   º',LF
x'        º      º   º   º   º _ º   º   º _ º   º   º – º ­ º Enter  º',LF
x'        ÌÍÍÍÍÍÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍÍÍÍÍÍÍÍ¹',LF
x'        º Shift  º Y º X º C º V º B º N º M º ? º : º _ º  Shift   º',LF
x'        º        º   º   º   º   º   º   º   º , º . º - º          º',LF
x'        ÌÍÍÍÍÍËÍÍÊÍÍÍÊËÍÍÊÍÍËÊÍÍÍÊÍÍÍÊÍÍÍÊÍÍÍÊÍÍÍÊÍÍËÊÍÍÍÊËÍÍÍËÍÍÍÍÍ¹',LF
x'        ºCtrl º       º Alt º        mezern¡k       º Alt º   ºCtrl º',LF
x'        º     º       º     º                       º     º   º     º',LF
x'        ÈÍÍÍÍÍ¼       ÈÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍ¼   ÈÍÍÍÍÍ¼',LF
x LF
x LF
x'Kl vesa  ',39,'~  je  tzv.  mrtv   (nebo t‚‘ prefixov ) kl vesa. Po jej¡m stisku se',LF
x'kurzor  neposune,  ale  nad  n sleduj¡c¡m p¡smenem se vytvo©¡ ‡ rka nebo h ‡ek',LF
x'(v  z vislosti  na  kl vese  SHIFT). Tuto kl vesu lze vyu‘¡t t‚‘ ke generov n¡',LF
x'nestandardn¡ch  znak– - stiskem jin‚ kl vesy ne‘ p¡smene se vygeneruje p–vodn¡',LF
x'znak podle IBM kl vesnice (dvoj¡m stiskem ',39,39,' se vygeneruje znak ',39,').',LF
x FF

; ------ 9
;ş
x LF,XF
x'                   ÚÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑ¿         )',LF
x'                   Ç                                ¶        ( ___   ©I   d«j',LF
x'                   Ç  1. program torsk  kl vesnice  ¶°°      ³_³Û³ ya.Sg dAgh,',LF
x'                   Ç                                ¶°°      |   ³ °°°°°  ÛÛÛÛÛ ',LF
x'                   Ç                                ¶°°      ,ÄÄÄ=.°°°°°. ÛÛÛÛÛ ',LF
x'                   ÀÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÙ°°       oooo  o o   o o',LF
x'                     °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°  abcdefghijklmnopqrstu',LF,XF
x LF
x'1.  program torsk   kl vesnice je nejvhodnˆj¨¡m typem kl vesnice p©edev¨¡m pro',LF
x'program tory,  ale  i  pro ostatn¡ u‘ivatele ‡asto pou‘¡vaj¡c¡ speci ln¡ znaky',LF
x'po‡¡ta‡e  (jako  nap©.  # $ & @). Z ‡esk‚ho psac¡ho stroje jsou p©evzaty ‡esk‚',LF
x'znaky  v  ‡¡seln‚  ©adˆ,  v¨echny  ostatn¡  znaky jsou zachov ny podle p–vodn¡',LF
x'anglick‚ kl vesnice. €¡slice se zad vaj¡ v numerick‚m poli kl vesnice.',LF,XF
x'        ÉÍÍÍËÍÍÍËÍÍÍËÍÍÍËÍÍÍËÍÍÍËÍÍÍËÍÍÍËÍÍÍËÍÍÍËÍÍÍËÍÍÍËÍÍÍËÍÍÍÍÍÍÍ»',LF
x'        º ~ º ! º @ º # º $ º % º ^ º & º * º ( º ) º _ º + º<-BkSpcº',LF
x'        º ` º – º ˆ º ¨ º ‡ º © º ‘ º ˜ º   º ¡ º ‚ º - º = º       º',LF
x'        ÌÍÍÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÍÍÍÍ¹',LF
x'        ºTab<-º Q º W º E º R º T º Y º U º I º O º P º { º } º     º',LF
x'        º   ->º   º   º   º   º   º   º   º   º   º   º [ º ] º     º',LF
x'        ÌÍÍÍÍÍÊËÍÍÊËÍÍÊËÍÍÊËÍÍÊËÍÍÊËÍÍÊËÍÍÊËÍÍÊËÍÍÊËÍÍÊËÍÍÊËÍÍ¼     º',LF
x'        ºCpsLckº A º S º D º F º G º H º J º K º L º : º " º  <-',39,'   º',LF
x'        º      º   º   º   º _ º   º   º _ º   º   º ; º ',39,' º Enter  º',LF
x'        ÌÍÍÍÍÍÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍÍÍÍÍÍÍÍ¹',LF
x'        º Shift  º Z º X º C º V º B º N º M º < º > º ? º  Shift   º',LF
x'        º        º   º   º   º   º   º   º   º , º . º / º          º',LF
x'        ÌÍÍÍÍÍËÍÍÊÍÍÍÊËÍÍÊÍÍËÊÍÍÍÊÍÍÍÊÍÍÍÊÍÍÍÊÍÍÍÊÍÍËÊÍÍÍÊËÍÍÍËÍÍÍÍÍ¹',LF
x'        ºCtrl º       º Alt º        mezern¡k       º Alt º   ºCtrl º',LF
x'        º     º       º     º                       º     º   º     º',LF
x'        ÈÍÍÍÍÍ¼       ÈÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍ¼   ÈÍÍÍÍÍ¼',LF
x LF
x'Kl vesa  ` je tzv. mrtv  (nebo t‚‘ prefixov ) kl vesa jako u p©ede¨l‚ p¡sa©sk‚',LF
x'kl vesnice.  Na  rozd¡l  od  n¡ se v¨ak pou‘¡v  jak pro h ‡ek tak i pro ‡ rku,',LF
x'podle  stisknut‚ho  p¡smene.  Odchylkou  je  p¡smeno  ˆ‰,  kter‚ se vygeneruje',LF
x'stiskem kl vesy wW, a p¡smeno ¦, kter‚ se vygeneruje stiskem J.',LF
x FF

; ------ 10
;ş
x LF,XF
x'                   ÚÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑ¿',LF
x'                   Ç                                ¶',LF
x'                   Ç  2. program torsk  kl vesnice  ¶°°',LF
x'                   Ç                                ¶°°      ¡ ¨,dS      O',LF
x'                   Ç                                ¶°°    ,!as•sƒ.F   ³/O>',LF
x'                   ÀÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÙ°°   dcsdsd,sWEs  m º',LF
x'                     °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°  afeRgFjjK Dlmnopqrstu',LF,XF
x LF
x'Pro  2. program torskou kl vesnici plat¡ v¨e jako u p©ede¨l‚ 1. program torsk‚',LF
x'kl vesnice  s  t¡m rozd¡lem, ‘e z psac¡ho stroje p©eb¡r  i mrtvou (prefixovou)',LF
x'kl vesu.  Z  toho  vypl˜v  nutnost rozli¨ovat mezi h ‡kem a ‡ rkou a t‚‘ hor¨¡',LF
x'dosa‘itelnost nˆkter˜ch znak– (jako nap©. =), je proto m‚nˆ vhodn˜m typem.',LF,XF
x LF
x'        ÉÍÍÍËÍÍÍËÍÍÍËÍÍÍËÍÍÍËÍÍÍËÍÍÍËÍÍÍËÍÍÍËÍÍÍËÍÍÍËÍÍÍËÍÍÍËÍÍÍÍÍÍÍ»',LF
x'        º ~ º ! º @ º # º $ º % º ^ º & º * º ( º ) º _ º ~ º<-BkSpcº',LF
x'        º ` º + º ˆ º ¨ º ‡ º © º ‘ º ˜ º   º ¡ º ‚ º - º ',39,' º       º',LF
x'        ÌÍÍÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÍÍÍÍ¹',LF
x'        ºTab<-º Q º W º E º R º T º Y º U º I º O º P º { º } º     º',LF
x'        º   ->º   º   º   º   º   º   º   º   º   º   º [ º ] º     º',LF
x'        ÌÍÍÍÍÍÊËÍÍÊËÍÍÊËÍÍÊËÍÍÊËÍÍÊËÍÍÊËÍÍÊËÍÍÊËÍÍÊËÍÍÊËÍÍÊËÍÍ¼     º',LF
x'        ºCpsLckº A º S º D º F º G º H º J º K º L º : º " º  <-',39,'   º',LF
x'        º      º   º   º   º _ º   º   º _ º   º   º ; º ',39,' º Enter  º',LF
x'        ÌÍÍÍÍÍÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍÍÍÍÍÍÍÍ¹',LF
x'        º Shift  º Z º X º C º V º B º N º M º < º > º ? º  Shift   º',LF
x'        º        º   º   º   º   º   º   º   º , º . º / º          º',LF
x'        ÌÍÍÍÍÍËÍÍÊÍÍÍÊËÍÍÊÍÍËÊÍÍÍÊÍÍÍÊÍÍÍÊÍÍÍÊÍÍÍÊÍÍËÊÍÍÍÊËÍÍÍËÍÍÍÍÍ¹',LF
x'        ºCtrl º       º Alt º        mezern¡k       º Alt º   ºCtrl º',LF
x'        º     º       º     º                       º     º   º     º',LF
x'        ÈÍÍÍÍÍ¼       ÈÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍ¼   ÈÍÍÍÍÍ¼',LF
x LF
x'Kl vesa  ',39,'~  je  tzv.  mrtv   (nebo t‚‘ prefixov ) kl vesa. Po jej¡m stisku se',LF
x'kurzor  neposune,  ale  nad n sleduj¡c¡m p¡smenem se vytvo©¡ ‡ rka nebo h ‡ek.',LF
x'Lze  ji  pou‘¡t  t‚‘ ke generov n¡ nestandardn¡ch znak– - stiskem jin‚ kl vesy',LF
x'ne‘ p¡smene se vygeneruje p–vodn¡ znak podle IBM kl vesnice.',LF
x FF

; ------ 11
;ş
x LF,XF
x'                        ÚÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑ¿',LF
x'                        Ç                       ¶      *  ^.^',LF
x'                        Ç  Anglick  kl vesnice  ¶°°   ***       **          * ',LF
x'                        Ç                       ¶°°   ***      **** \ /*** ***',LF
x'                        Ç                       ¶°°    *     * *** * O  ******',LF
x'                        ÀÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÙ°°    º  *** ***** (o)***  º ',LF
x'                          °°°°°°°°°°°°°°°°°°°°°°°°°  abcdefghijklmnopqrstuvwxy',LF,XF
x LF
x'Anglick  kl vesnice je p–vodn¡ kl vesnice po‡¡ta‡e IBM. S minim ln¡ nadstavbou',LF
x'pro  generov n¡ ‡esk˜ch znak– m–‘e b˜t plnˆ vyhovuj¡c¡ kl vesnic¡ program tor–',LF
x'a  v¨ech  ostatn¡ch  u‘ivatel–  nevy‘aduj¡c¡ch  psan¡  dlouh˜ch ‡esk˜ch text–.',LF
x'V¨echny kl vesy z–st vaj¡ zachov ny, je pouze doplnˆna tzv. mrtv  kl vesa.',LF,XF
x LF
x'        ÉÍÍÍËÍÍÍËÍÍÍËÍÍÍËÍÍÍËÍÍÍËÍÍÍËÍÍÍËÍÍÍËÍÍÍËÍÍÍËÍÍÍËÍÍÍËÍÍÍÍÍÍÍ»',LF
x'        º ~ º ! º @ º # º $ º % º ^ º & º * º ( º ) º _ º + º<-BkSpcº',LF
x'        º ` º 1 º 2 º 3 º 4 º 5 º 6 º 7 º 8 º 9 º 0 º - º = º       º',LF
x'        ÌÍÍÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÍÍÍÍ¹',LF
x'        ºTab<-º Q º W º E º R º T º Y º U º I º O º P º { º } º     º',LF
x'        º   ->º   º   º   º   º   º   º   º   º   º   º [ º ] º     º',LF
x'        ÌÍÍÍÍÍÊËÍÍÊËÍÍÊËÍÍÊËÍÍÊËÍÍÊËÍÍÊËÍÍÊËÍÍÊËÍÍÊËÍÍÊËÍÍÊËÍÍ¼     º',LF
x'        ºCpsLckº A º S º D º F º G º H º J º K º L º : º " º  <-',39,'   º',LF
x'        º      º   º   º   º _ º   º   º _ º   º   º ; º ',39,' º Enter  º',LF
x'        ÌÍÍÍÍÍÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍËÍÊÍÍÍÍÍÍÍÍ¹',LF
x'        º Shift  º Z º X º C º V º B º N º M º < º > º ? º  Shift   º',LF
x'        º        º   º   º   º   º   º   º   º , º . º / º          º',LF
x'        ÌÍÍÍÍÍËÍÍÊÍÍÍÊËÍÍÊÍÍËÊÍÍÍÊÍÍÍÊÍÍÍÊÍÍÍÊÍÍÍÊÍÍËÊÍÍÍÊËÍÍÍËÍÍÍÍÍ¹',LF
x'        ºCtrl º       º Alt º        mezern¡k       º Alt º   ºCtrl º',LF
x'        º     º       º     º                       º     º   º     º',LF
x'        ÈÍÍÍÍÍ¼       ÈÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍ¼   ÈÍÍÍÍÍ¼',LF
x LF
x'Kl vesa  `  je  tzv.  mrtv   (nebo  t‚‘  prefixov )  kl vesa  jako  u p¡sa©sk‚',LF
x'kl vesnice.  Na  rozd¡l  od  n¡ se v¨ak pou‘¡v  jak pro h ‡ek tak i pro ‡ rku,',LF
x'podle  stisknut‚ho  p¡smene.  Odchylkou  je  p¡smeno  ˆ‰,  kter‚ se vygeneruje',LF
x'stiskem kl vesy wW, a p¡smeno ¦, kter‚ se vygeneruje stiskem J.',LF
x FF

; ------ 12
;ş
x LF,XF
x'                        ÚÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑ¿                             ',LF
x'                                                        Û                     ',CR
x'                        Ç                       ¶       *        ÄÄÄÄ',LF
x'                                                        Û',CR
x'                        Ç   Spu¨tˆn¡ programu   ¶°°      *     ___//__\\ÄÄÄÄ',LF
x'                                                        Û',CR
x'                        Ç                       ¶°°     *   /) o    ___//__\\',LF
x'                        Ç                       ¶°°     º   \____/) o        \',LF
x'                        ÀÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÙ°°     º     \_/\__________³',LF
x'                          °°°°°°°°°°°°°°°°°°°°°°°°°     º          \_/   \_/',LF,XF
x LF
x'Program VSEMI10 lze spou¨tˆt se zad n¡m n sleduj¡c¡ch parametr–:',LF
x LF
x'  /? ................ zobrazen¡ n povˆdy k zad n¡ parametr–',LF
x'  /C soubor ......... jm‚no konfigura‡n¡ho souboru (p©¡padnˆ i s cestou)',LF
x'                      - implicitnˆ soubor VSEMI10.CNF v domovsk‚m adres ©i',LF
x'  /T adres © ........ adres © obsahuj¡c¡ soubory test–',LF
x'                      - implicitnˆ adres © TESTY v domovsk‚m adres ©i',LF
x'  /P adres © ........ adres © pro ukl d n¡ protokol– test–',LF
x'                      - implicitnˆ adres © PROTOKOL v domovsk‚m adres ©i',LF
x LF,XF
x'P©¡kaz "VSEMI10 /C VSEMI10.CNF /T TESTY /P PROTOKOL" pou‘ije aktu ln¡ adres ©.',LF
x'Oddˆlovac¡  znak  parametr– "/" nen¡ nutn‚ uv dˆt. Jm‚na soubor– a adres ©– se',LF
x'uv dˆj¡  podle  bˆ‘n˜ch  konvenc¡ DOS relativnˆ k aktu ln¡mu adres ©i a disku.',LF
x'Na  konci  adres ©e  m–‘e, ale nemus¡ b˜t uveden znak "\". Domovsk˜ adres © je',LF
x'adres ©,  ve  kter‚m je program VSEMI10 nainstalov n. P©i ‡innosti programu je',LF
x'automaticky zaji¨tˆno vypnut¡ ovlada‡– kl vesnic KEYB.COM a CSKEY.COM (KEYB je',LF
x'syst‚mov˜ ovlada‡ kl vesnice, CSKEY je ovlada‡ dod van˜ spolu se VSEMI10). P©i',LF
x'pou‘it¡  jin˜ch  ovlada‡–  kl vesnic  je  nutno  zajistit  jejich vypnut¡ p©ed',LF
x'spu¨tˆn¡m  programu  VSEMI10  (aby  rozm¡stˆn¡  znak– na kl vesnici odpov¡dalo',LF
x'standardn¡mu  rozm¡stˆn¡  kl vesnice  IBM),  jinak nebude rozm¡stˆn¡ kl ves na',LF
x'kl vesnici spr vn‚.',LF
x FF

HelpSeg  ENDS
         END

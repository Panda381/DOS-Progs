
; Makra KONTEXTu: SHIFT-F1 zvòraznànò text
;                 SHIFT-F2 kl†vesy s p©ek¢dov†n°m
;                 SHIFT-F3 nadpis
;                 SHIFT-F4 nadpis 2
;                 ALT-A  db ' ',LF

; Dodrëovat strukturu:
;   - na zaá†tku cviáen° jsou jedno©†dkov† cviáen° - rozpoznaj° se podle
;     p©edch†zej°c°ho znaku - nesm° p©ed nimi bòt znak FF ! Jedno©†dkov†
;     cviáen° koná° znakem FF, n†sleduj° v°ce©†dkov† cviáen° - ta se
;     rozpoznaj° podle p©edch†zej°c°ho znaku FF. Cviáen° koná° znakem EOT.

INCLUDE  DEF.ASM

LekSeg1  SEGMENT   BYTE PUBLIC

; ------ lekce 00 - £vod
;˛
LekcC00  label     byte
db '                                                                     1/7',LF
db '                   P°sa©sk† kl†vesnice (psac° stroj)',LF
db LF
db 'Kl†vesnice,  kter†  je  nyn°  zvolena, se nazòv† p°sa©sk† kl†vesnice. Je',LF
db 'uráena  pro p°sa©e. Rozloëen° kl†ves se plnà shoduje s rozloëen°m kl†ves',LF
db 'psac°ho stroje. Na mnoha poá°taáovòch kl†vesnic°ch jsou kl†vesy p°sa©skÇ',LF
db 'kl†vesnice  oznaáeny  áervenòm potiskem. Nejsou p©°mo dostupnÇ speci†ln°',LF
db 'znaky poá°taáe (jako nap©. "\"). U nàkteròch ovladaáñ kl†vesnic (jako je',LF
db 'CSKEY)  jsou  tyto znaky dostupnÇ po stisku tzv. mrtvÇ kl†vesy a kl†vesy',LF
db 's poëadovanòm znakem s áernòm potiskem.',LF
db '                                        ... stisknàte libovolnou kl†vesu'
db FF

db '                                                                     2/7',LF
db '                             Technika psan°',LF
db LF
db 'Osvojit si spr†vnou techniku psan°  znamen†  dokonale  prstovà ovl†dnout',LF
db 'kl†vesnici  a  dos†hnout  p©esnÇho  a  rychlÇho  vòkonu  s  co  nejmen®°',LF
db 'psychickou  a fyzickou n†mahou. K tomu je t©eba z°skat hmatovou jistotu,',LF
db 'rovnomàrnost  a  plynulost  p©i  psan°.  Pro  spr†vnou techniku psan° je',LF
db 'dñleëitÇ  drëen°  rukou. Prsty dopadaj° kolmo doprost©ed kl†ves, z†pàst°',LF
db 'nesm° bòt prohnutÇ a dla§ nepokl†d†me na r†m kl†vesnice.',LF
db LF
db '                                        ... stisknàte libovolnou kl†vesu'
db FF

db '                                                                     3/7',LF
db '                             Prstov† cviáen°',LF
db LF
db 'Prstov†  cviáen°  slouë°  k  procviáov†n°  pohybovòch  schopnost° prstñ.',LF
db 'Zvl†®tà  prsten°áky  a mal°áky jsou zpoá†tku velmi neobratnÇ. Proto tato',LF
db 'cviáen° prov†dàjte p©ed zah†jen°m kaëdÇ lekce.',LF
db LF
db 'Poloëte  obà  ruce  na  stñl.  Dbejte na to, aby byly ve spr†vnÇ poloze.',LF
db 'Prsty mus° dopadat kolmo a rychle se vracet zpàt.',LF
db LF
db '                                        ... stisknàte libovolnou kl†vesu'
db FF

db '                                                                     4/7',LF
db 'Obà ruce cviá° shodnà:',LF
db '   1) Kaëdò  prst  samostatnà  üuk†  do  stolu, anië by se ostatn° prsty',LF
db '      zvedaly (cviá° se 4 x palec, 4 x ukazov†áek, atd.).',LF
db LF
db '   2) Zvedejte st©°davà dva sousedn° prsty, ostatn° zñst†vaj° na stole.',LF
db LF
db '   3) Zvedejte  st©°davà  dva  prsty (palec a prost©edn°k, prost©edn°k a',LF
db '      prsten°k, prsten°k a mal°áek), ostatn° prsty mus° zñstat na stole.',LF
db LF
db '                                        ... stisknàte libovolnou kl†vesu'
db FF

db '                                                                     5/7',LF
db 'Z†kladem  rozm°stàn°  znakñ na kl†vesnici je tzv. univerz†ln° kl†vesnice',LF
db 'p©ijat† r. 1888 v Torontu. Kl†vesnici rozdàlujeme do 5 ©ad a 12 sloupcñ:',LF
db LF
db '   1     2     3     4     5     6     7     8     9    10    11    12',LF
db 'E  +1    à2    ®3    á4    ©5    ë6    ò7    †8    °9    Ç0    =%    ',39,'~',LF
db 'D   Q     W     E     R     T     Z     U     I     O     P     £/    )(',LF
db 'C    A     S     D     F     G     H     J     K     L     ñ"    ≠!',LF
db 'B     Y     X     C     V     B     N     M     ,?    .:    -_',LF
db 'A                              m e z e r a',LF
db '                                        ... stisknàte libovolnou kl†vesu'
db FF

db '                                                                     6/7',LF
db 'Nyn°  p©istoup°me  k  jednÇ  z  nejdñleëitàj®°ch  vàc° - z†kladn° poloha',LF
db 'na kl†vesnici. PosaÉte se rovnà a poloëte ruce na kl†vesnici takto:',LF
db 'LEVè RUKA',LF
db 'mal°áek-prsten°áek-prost©edn°áek-ukazov†áek',LF
db '   A        S            D           F                        PRAVè RUKA',LF
db '                             ukazov†áek-prost©edn°áek-prsten°áek-mal°áek',LF
db '                                 J            K           L         ñ',LF
db 'Jistà  jste  zjistili,  ëe  na  kl†ves†ch  F a J jsou vylisov†ny podÇlnÇ',LF
db 'vòstupky. Podle nich se budete orientovat hmatem na kl†vesnici.',LF
db '                                        ... stisknàte libovolnou kl†vesu'
db FF

db '                                                                     7/7',LF
db '                              Rytmus psan°',LF
db LF
db 'Posledn°  vàc,  o  kterÇ  si ©ekneme, neë zaáneme s n†cvikem, je rytmus,',LF
db 'kterò je nutno dodrëovat.  Znamen† to ps†t rovnomàrnà a nezrychlovat p©i',LF
db 'psan° jednoduchòch nebo jië zn†mòch p°smen.',LF
db LF
db 'Vëdy  dbejte  na  dodrëov†n°  rytmu  psan°,  snaëte se nepsat £trëkovità',LF
db 'a nerovnomàrnà! K udrëen° rytmu mñëete pouë°t metronom (kl†vesa F2).',LF
db LF
db '                                        ... stisknàte libovolnou kl†vesu'
db FF
db EOT

LekcI00  label     byte
db '                                                                     1/7',LF
db '                    Anglick† kl†vesnice (origin†ln° IBM)',LF
db LF
db 'Kl†vesnice,  kter† je nyn° zvolena, se nazòv† anglick† kl†vesnice (IBM).',LF
db 'Rozloëen°  kl†ves  odpov°d†  pñvodn°mu rozloëen° kl†ves poá°taáe. Pomoc°',LF
db 'áeskÇ nadstavby je doplnàna funkce tzv. mrtvÇ (prefixovÇ) kl†vesy. Touto',LF
db 'kl†vesou  je moënÇ zapisovat diakritick† znamÇnka nad p°smeny. Na rozd°l',LF
db 'od  obdobnÇ kl†vesy psac°ho stroje nen° pot©eba rozli®ovat mezi h†ákem a',LF
db 'á†rkou,  postaá°  pouze stisknout po kl†vese poëadovanÇ p°smeno nebo p©i',LF
db 'v°ce moënostech stisknout vedlej®° p°smeno.',LF
db '                                        ... stisknàte libovolnou kl†vesu'
db FF

db '                                                                     2/7',LF
db '                             Technika psan°',LF
db LF
db 'Osvojit si spr†vnou techniku psan°  znamen†  dokonale  prstovà ovl†dnout',LF
db 'kl†vesnici  a  dos†hnout  p©esnÇho  a  rychlÇho  vòkonu  s  co  nejmen®°',LF
db 'psychickou  a fyzickou n†mahou. K tomu je t©eba z°skat hmatovou jistotu,',LF
db 'rovnomàrnost  a  plynulost  p©i  psan°.  Pro  spr†vnou techniku psan° je',LF
db 'dñleëitÇ  drëen°  rukou. Prsty dopadaj° kolmo doprost©ed kl†ves, z†pàst°',LF
db 'nesm° bòt prohnutÇ a dla§ nepokl†d†me na r†m kl†vesnice.',LF
db LF
db '                                        ... stisknàte libovolnou kl†vesu'
db FF

db '                                                                     3/7',LF
db '                             Prstov† cviáen°',LF
db LF
db 'Prstov†  cviáen°  slouë°  k  procviáov†n°  pohybovòch  schopnost° prstñ.',LF
db 'Zvl†®tà  prsten°áky  a mal°áky jsou zpoá†tku velmi neobratnÇ. Proto tato',LF
db 'cviáen° prov†dàjte p©ed zah†jen°m kaëdÇ lekce.',LF
db LF
db 'Poloëte  obà  ruce  na  stñl.  Dbejte na to, aby byly ve spr†vnÇ poloze.',LF
db 'Prsty mus° dopadat kolmo a rychle se vracet zpàt.',LF
db LF
db '                                        ... stisknàte libovolnou kl†vesu'
db FF

db '                                                                     4/7',LF
db 'Obà ruce cviá° shodnà:',LF
db '   1) Kaëdò  prst  samostatnà  üuk†  do  stolu, anië by se ostatn° prsty',LF
db '      zvedaly (cviá° se 4 x palec, 4 x ukazov†áek, atd.).',LF
db LF
db '   2) Zvedejte st©°davà dva sousedn° prsty, ostatn° zñst†vaj° na stole.',LF
db LF
db '   3) Zvedejte  st©°davà  dva  prsty (palec a prost©edn°k, prost©edn°k a',LF
db '      prsten°k, prsten°k a mal°áek), ostatn° prsty mus° zñstat na stole.',LF
db LF
db '                                        ... stisknàte libovolnou kl†vesu'
db FF

db '                                                                     5/7',LF
db 'Z†kladem  rozm°stàn°  znakñ na kl†vesnici je tzv. univerz†ln° kl†vesnice',LF
db 'p©ijat† r. 1888 v Torontu. Kl†vesnici rozdàlujeme do 5 ©ad a 12 sloupcñ:',LF
db LF
db '   1     2     3     4     5     6     7     8     9    10    11    12',LF
db 'E  1!    2@    3#    4$    5%    6^    7&    8*    9(    0)    -_    =+',LF
db 'D   Q     W     E     R     T     Y     U     I     O     P     [{    ]}',LF
db 'C    A     S     D     F     G     H     J     K     L     ;:    ',39,'"',LF
db 'B     Z     X     C     V     B     N     M     ,<    .>    /?',LF
db 'A                              m e z e r a',LF
db '                                        ... stisknàte libovolnou kl†vesu'
db FF

db '                                                                     6/7',LF
db 'Nyn°  p©istoup°me  k  jednÇ  z  nejdñleëitàj®°ch  vàc° - z†kladn° poloha',LF
db 'na kl†vesnici. PosaÉte se rovnà a poloëte ruce na kl†vesnici takto:',LF
db 'LEVè RUKA',LF
db 'mal°áek-prsten°áek-prost©edn°áek-ukazov†áek',LF
db '   A        S            D           F                        PRAVè RUKA',LF
db '                             ukazov†áek-prost©edn°áek-prsten°áek-mal°áek',LF
db '                                 J            K           L         ;',LF
db 'Jistà  jste  zjistili,  ëe  na  kl†ves†ch  F a J jsou vylisov†ny podÇlnÇ',LF
db 'vòstupky. Podle nich se budete orientovat hmatem na kl†vesnici.',LF
db '                                        ... stisknàte libovolnou kl†vesu'
db FF

db '                                                                     7/7',LF
db '                              Rytmus psan°',LF
db LF
db 'Posledn°  vàc,  o  kterÇ  si ©ekneme, neë zaáneme s n†cvikem, je rytmus,',LF
db 'kterò je nutno dodrëovat.  Znamen† to ps†t rovnomàrnà a nezrychlovat p©i',LF
db 'psan° jednoduchòch nebo jië zn†mòch p°smen.',LF
db LF
db 'Vëdy  dbejte  na  dodrëov†n°  rytmu  psan°,  snaëte se nepsat £trëkovità',LF
db 'a nerovnomàrnà! K udrëen° rytmu mñëete pouë°t metronom (kl†vesa F2).',LF
db LF
db '                                        ... stisknàte libovolnou kl†vesu'
db FF
db EOT

Lekc100  label     byte
db '                                                                     1/7',LF
db '                   1. program†torsk† kl†vesnice (CSKEY)',LF
db LF
db 'Kl†vesnice,  kter† je nyn° zvolena, se nazòv† program†torsk† kl†vesnice.',LF
db 'Nam°sto á°slic v á°selnÇ ©adà jsou nadefinov†ny áeskÇ znaky s rozloëen°m',LF
db 'podle kl†vesnice psac°ho stroje. Ve stejnÇ ©adà je um°stàna i tzv. mrtv†',LF
db 'kl†vesa uráen† pro z†pis diakritickòch znamÇnek. Nerozli®uje se znak pro',LF
db 'z†pis á†rky a h†áku. Vòznam v®ech ostatn°ch kl†ves zñst†v† zachov†n jako',LF
db 'u pñvodn° anglickÇ kl†vesnice. Ä°slice lze zapsat v numerickÇm poli nebo',LF
db 'stiskem mrtvÇ kl†vesy a kl†vesy s á°slic°.',LF
db '                                        ... stisknàte libovolnou kl†vesu'
db FF

db '                                                                     2/7',LF
db '                             Technika psan°',LF
db LF
db 'Osvojit si spr†vnou techniku psan°  znamen†  dokonale  prstovà ovl†dnout',LF
db 'kl†vesnici  a  dos†hnout  p©esnÇho  a  rychlÇho  vòkonu  s  co  nejmen®°',LF
db 'psychickou  a fyzickou n†mahou. K tomu je t©eba z°skat hmatovou jistotu,',LF
db 'rovnomàrnost  a  plynulost  p©i  psan°.  Pro  spr†vnou techniku psan° je',LF
db 'dñleëitÇ  drëen°  rukou. Prsty dopadaj° kolmo doprost©ed kl†ves, z†pàst°',LF
db 'nesm° bòt prohnutÇ a dla§ nepokl†d†me na r†m kl†vesnice.',LF
db LF
db '                                        ... stisknàte libovolnou kl†vesu'
db FF

db '                                                                     3/7',LF
db '                             Prstov† cviáen°',LF
db LF
db 'Prstov†  cviáen°  slouë°  k  procviáov†n°  pohybovòch  schopnost° prstñ.',LF
db 'Zvl†®tà  prsten°áky  a mal°áky jsou zpoá†tku velmi neobratnÇ. Proto tato',LF
db 'cviáen° prov†dàjte p©ed zah†jen°m kaëdÇ lekce.',LF
db LF
db 'Poloëte  obà  ruce  na  stñl.  Dbejte na to, aby byly ve spr†vnÇ poloze.',LF
db 'Prsty mus° dopadat kolmo a rychle se vracet zpàt.',LF
db LF
db '                                        ... stisknàte libovolnou kl†vesu'
db FF

db '                                                                     4/7',LF
db 'Obà ruce cviá° shodnà:',LF
db '   1) Kaëdò  prst  samostatnà  üuk†  do  stolu, anië by se ostatn° prsty',LF
db '      zvedaly (cviá° se 4 x palec, 4 x ukazov†áek, atd.).',LF
db LF
db '   2) Zvedejte st©°davà dva sousedn° prsty, ostatn° zñst†vaj° na stole.',LF
db LF
db '   3) Zvedejte  st©°davà  dva  prsty (palec a prost©edn°k, prost©edn°k a',LF
db '      prsten°k, prsten°k a mal°áek), ostatn° prsty mus° zñstat na stole.',LF
db LF
db '                                        ... stisknàte libovolnou kl†vesu'
db FF

db '                                                                     5/7',LF
db 'Z†kladem  rozm°stàn°  znakñ na kl†vesnici je tzv. univerz†ln° kl†vesnice',LF
db 'p©ijat† r. 1888 v Torontu. Kl†vesnici rozdàlujeme do 5 ©ad a 12 sloupcñ:',LF
db LF
db '   1     2     3     4     5     6     7     8     9    10    11    12',LF
db 'E  ñ!    à@    ®#    á$    ©%    ë^    ò&    †*    °(    Ç)    -_    =+',LF
db 'D   Q     W     E     R     T     Y     U     I     O     P     [{    ]}',LF
db 'C    A     S     D     F     G     H     J     K     L     ;:    ',39,'"',LF
db 'B     Z     X     C     V     B     N     M     ,<    .>    /?',LF
db 'A                              m e z e r a',LF
db '                                        ... stisknàte libovolnou kl†vesu'
db FF

db '                                                                     6/7',LF
db 'Nyn°  p©istoup°me  k  jednÇ  z  nejdñleëitàj®°ch  vàc° - z†kladn° poloha',LF
db 'na kl†vesnici. PosaÉte se rovnà a poloëte ruce na kl†vesnici takto:',LF
db 'LEVè RUKA',LF
db 'mal°áek-prsten°áek-prost©edn°áek-ukazov†áek',LF
db '   A        S            D           F                        PRAVè RUKA',LF
db '                             ukazov†áek-prost©edn°áek-prsten°áek-mal°áek',LF
db '                                 J            K           L         ;',LF
db 'Jistà  jste  zjistili,  ëe  na  kl†ves†ch  F a J jsou vylisov†ny podÇlnÇ',LF
db 'vòstupky. Podle nich se budete orientovat hmatem na kl†vesnici.',LF
db '                                        ... stisknàte libovolnou kl†vesu'
db FF

db '                                                                     7/7',LF
db '                              Rytmus psan°',LF
db LF
db 'Posledn°  vàc,  o  kterÇ  si ©ekneme, neë zaáneme s n†cvikem, je rytmus,',LF
db 'kterò je nutno dodrëovat.  Znamen† to ps†t rovnomàrnà a nezrychlovat p©i',LF
db 'psan° jednoduchòch nebo jië zn†mòch p°smen.',LF
db LF
db 'Vëdy  dbejte  na  dodrëov†n°  rytmu  psan°,  snaëte se nepsat £trëkovità',LF
db 'a nerovnomàrnà! K udrëen° rytmu mñëete pouë°t metronom (kl†vesa F2).',LF
db LF
db '                                        ... stisknàte libovolnou kl†vesu'
db FF
db EOT

Lekc200  label     byte
db '                                                                     1/7',LF
db '                   2. program†torsk† kl†vesnice (T602)',LF
db LF
db 'Kl†vesnice,  kter† je nyn° zvolena, se nazòv† program†torsk† kl†vesnice.',LF
db 'Nam°sto á°slic v á°selnÇ ©adà jsou nadefinov†ny áeskÇ znaky s rozloëen°m',LF
db 'podle kl†vesnice psac°ho stroje. Ve stejnÇ ©adà je um°stàna i tzv. mrtv†',LF
db 'kl†vesa  uráen†  pro z†pis diakritickòch znamÇnek. Rozli®uje se znak pro',LF
db 'z†pis á†rky a h†áku. Vòznam v®ech ostatn°ch kl†ves zñst†v† zachov†n jako',LF
db 'u pñvodn° anglickÇ kl†vesnice. Ä°slice lze zapsat v numerickÇm poli nebo',LF
db 'stiskem mrtvÇ kl†vesy a kl†vesy s á°slic°.',LF
db '                                        ... stisknàte libovolnou kl†vesu'
db FF

db '                                                                     2/7',LF
db '                             Technika psan°',LF
db LF
db 'Osvojit si spr†vnou techniku psan°  znamen†  dokonale  prstovà ovl†dnout',LF
db 'kl†vesnici  a  dos†hnout  p©esnÇho  a  rychlÇho  vòkonu  s  co  nejmen®°',LF
db 'psychickou  a fyzickou n†mahou. K tomu je t©eba z°skat hmatovou jistotu,',LF
db 'rovnomàrnost  a  plynulost  p©i  psan°.  Pro  spr†vnou techniku psan° je',LF
db 'dñleëitÇ  drëen°  rukou. Prsty dopadaj° kolmo doprost©ed kl†ves, z†pàst°',LF
db 'nesm° bòt prohnutÇ a dla§ nepokl†d†me na r†m kl†vesnice.',LF
db LF
db '                                        ... stisknàte libovolnou kl†vesu'
db FF

db '                                                                     3/7',LF
db '                             Prstov† cviáen°',LF
db LF
db 'Prstov†  cviáen°  slouë°  k  procviáov†n°  pohybovòch  schopnost° prstñ.',LF
db 'Zvl†®tà  prsten°áky  a mal°áky jsou zpoá†tku velmi neobratnÇ. Proto tato',LF
db 'cviáen° prov†dàjte p©ed zah†jen°m kaëdÇ lekce.',LF
db LF
db 'Poloëte  obà  ruce  na  stñl.  Dbejte na to, aby byly ve spr†vnÇ poloze.',LF
db 'Prsty mus° dopadat kolmo a rychle se vracet zpàt.',LF
db LF
db '                                        ... stisknàte libovolnou kl†vesu'
db FF

db '                                                                     4/7',LF
db 'Obà ruce cviá° shodnà:',LF
db '   1) Kaëdò  prst  samostatnà  üuk†  do  stolu, anië by se ostatn° prsty',LF
db '      zvedaly (cviá° se 4 x palec, 4 x ukazov†áek, atd.).',LF
db LF
db '   2) Zvedejte st©°davà dva sousedn° prsty, ostatn° zñst†vaj° na stole.',LF
db LF
db '   3) Zvedejte  st©°davà  dva  prsty (palec a prost©edn°k, prost©edn°k a',LF
db '      prsten°k, prsten°k a mal°áek), ostatn° prsty mus° zñstat na stole.',LF
db LF
db '                                        ... stisknàte libovolnou kl†vesu'
db FF

db '                                                                     5/7',LF
db 'Z†kladem  rozm°stàn°  znakñ na kl†vesnici je tzv. univerz†ln° kl†vesnice',LF
db 'p©ijat† r. 1888 v Torontu. Kl†vesnici rozdàlujeme do 5 ©ad a 12 sloupcñ:',LF
db LF
db '   1     2     3     4     5     6     7     8     9    10    11    12',LF
db 'E  +!    à@    ®#    á$    ©%    ë^    ò&    †*    °(    Ç)    -_    ',39,'~',LF
db 'D   Q     W     E     R     T     Y     U     I     O     P     [{    ]}',LF
db 'C    A     S     D     F     G     H     J     K     L     ;:    ',39,'"',LF
db 'B     Z     X     C     V     B     N     M     ,<    .>    /?',LF
db 'A                              m e z e r a',LF
db '                                        ... stisknàte libovolnou kl†vesu'
db FF

db '                                                                     6/7',LF
db 'Nyn°  p©istoup°me  k  jednÇ  z  nejdñleëitàj®°ch  vàc° - z†kladn° poloha',LF
db 'na kl†vesnici. PosaÉte se rovnà a poloëte ruce na kl†vesnici takto:',LF
db 'LEVè RUKA',LF
db 'mal°áek-prsten°áek-prost©edn°áek-ukazov†áek',LF
db '   A        S            D           F                        PRAVè RUKA',LF
db '                             ukazov†áek-prost©edn°áek-prsten°áek-mal°áek',LF
db '                                 J            K           L         ;',LF
db 'Jistà  jste  zjistili,  ëe  na  kl†ves†ch  F a J jsou vylisov†ny podÇlnÇ',LF
db 'vòstupky. Podle nich se budete orientovat hmatem na kl†vesnici.',LF
db '                                        ... stisknàte libovolnou kl†vesu'
db FF

db '                                                                     7/7',LF
db '                              Rytmus psan°',LF
db LF
db 'Posledn°  vàc,  o  kterÇ  si ©ekneme, neë zaáneme s n†cvikem, je rytmus,',LF
db 'kterò je nutno dodrëovat.  Znamen† to ps†t rovnomàrnà a nezrychlovat p©i',LF
db 'psan° jednoduchòch nebo jië zn†mòch p°smen.',LF
db LF
db 'Vëdy  dbejte  na  dodrëov†n°  rytmu  psan°,  snaëte se nepsat £trëkovità',LF
db 'a nerovnomàrnà! K udrëen° rytmu mñëete pouë°t metronom (kl†vesa F2).',LF
db LF
db '                                        ... stisknàte libovolnou kl†vesu'
db FF
db EOT

LDatC00  label     byte
LDatI00  label     byte
LDat100  label     byte
LDat200  label     byte
db EOT

; ------ lekce 01 - fjdk
;˛
LekcC01  label     byte
LekcI01  label     byte
Lekc101  label     byte
Lekc201  label     byte
db 'dfjk)',LF
db 'Um°stàte ruce do z†kladn° polohy a nacviáujte tato p°smena:',LF
db LF
db '  ukazov†ákem levÇ ruky  - f          ukazov†ákem pravÇ ruky  - j',LF
db 'prost©edn°kem levÇ ruky  - d        prost©edn°kem pravÇ ruky  - k',LF
db LF
db 'Prsty mus° dopadat kolmo a doprost©ed kl†ves. Mezery mezi p°smeny dàl†me',LF
db 'mezern°kem,  kterò  tiskneme  palcem (levòm nebo pravòm). Na konci ©†dku',LF
db 'stisknàte pravòm mal°ákem kl†vesu ENTER. Cviáen° zpàt/vp©ed=PgUp/PgDown.',LF
db LF
db EOT

LDatC01  label     byte
LDatI01  label     byte
LDat101  label     byte
LDat201  label     byte
db 'ffffffff jjjjjjjj dddddddd kkkkkkkk fjfjfjfjfjf dkdkdkdkdkd',LF
db 'dfjk kjfd dfjk kjfd dfjk kjfd dfjk kjfd dfjk kjfd dfjk kjfd',LF
db 'fjf fjd fjf fjd fjf fjd fjf fjd fjf fjd fjf fjd fjf fjd fjf',LF
db 'kjf kjk kjf kjk kjf kjk kjf kjk kjf kjk kjf kjk kjf kjk kjf',LF
db 'dfd dfj dfd dfj dfd dfj dfd dfj dfd dfj dfd dfj dfd dfj dfd',LF
db 'kjjf kjjd kjjf kjjd kjjf kjjd kjjf kjjd kjjf kjjd kjjf kjjd',LF
db 'djjf dffk djjf dffk djjf dffk djjf dffk djjf dffk djjf dffk',LF
db 'fjdk jfdk fjdk jfdk fjdk jfdk fjdk jfdk fjdk jfdk fjdk jfdk',LF
db EOT

; ------ lekce 02 - ña
;˛
LekcC02  label     byte
db 'añ)',LF
db LF
db 'Um°stàte ruce do z†kladn° polohy a nacviáujte tato p°smena:',LF
db LF
db ' mal°ákem levÇ ruky  - a',LF
db 'mal°ákem pravÇ ruky  - ñ',LF
db LF
db 'Bàhem n†cviku si kontrolujte, zda nezved†te ostatn° prsty ze z†kladn°',LF
db 'polohy. Nezvedejte lokty - pap°r vsunutò pod paëi nesm° vypadnout!',LF
db LF
db EOT

LekcI02  label     byte
Lekc102  label     byte
Lekc202  label     byte
db 'a;)',LF
db LF
db 'Um°stàte ruce do z†kladn° polohy a nacviáujte tato p°smena:',LF
db LF
db ' mal°ákem levÇ ruky  - a',LF
db 'mal°ákem pravÇ ruky  - ;',LF
db LF
db 'Bàhem n†cviku si kontrolujte, zda nezved†te ostatn° prsty ze z†kladn°',LF
db 'polohy. Nezvedejte lokty - pap°r vsunutò pod paëi nesm° vypadnout!',LF
db LF
db EOT

LDatC02  label     byte
db 'aaaaaaaaa ñññññññññ fñfñ jñjñ dñdñ kñkñ fafa jaja dada kaka',LF
db 'jak dak jak dak jak dak jak dak jak dak jak dak jak dak jak',LF
db 'adñ afñ adñ afñ adñ afñ adñ afñ adñ afñ adñ afñ adñ afñ adñ',LF
db 'dñj fñj dñj fñj dñj fñj dñj fñj dñj fñj dñj fñj dñj fñj dñj',LF
db 'jak kajak kajakñ kajak kajakñ jak kajak kajakñ kajak kajakñ',LF
db 'kajak jaffa kajak jaffa kajak jaffa kajak jaffa kajak jaffa',LF
db 'fa jñ jaf fñj jaffa fa jñ jaf fñj jaffa fa jñ jaf fñj jaffa',LF
db FF
db 'fajfka kakadñ kajak jaffa dñf fajfka kakadñ kajak jaffa dñf',LF
db EOT

LDatI02  label     byte
LDat102  label     byte
LDat202  label     byte
db 'aaaaaaaaa ;;;;;;;;; f;f; j;j; d;d; k;k; fafa jaja dada kaka',LF
db 'jak dak jak dak jak dak jak dak jak dak jak dak jak dak jak',LF
db 'ad; af; ad; af; ad; af; ad; af; ad; af; ad; af; ad; af; ad;',LF
db 'd;j f;j d;j f;j d;j f;j d;j f;j d;j f;j d;j f;j d;j f;j d;j',LF
db 'jak kajak jak kajak jak kajak jak kajak jak kajak jak kajak',LF
db 'kajak jaffa kajak jaffa kajak jaffa kajak jaffa kajak jaffa',LF
db 'fa ja jaf faj jaffa fa ja jaf faj jaffa fa ja jaf faj jaffa',LF
db FF
db 'fajfka kajak; kajak jaffa daf fajfka kajak; kajak jaffa daf',LF
db EOT

; ------ lekce 03 - ls
;˛
LekcC03  label     byte
LekcI03  label     byte
Lekc103  label     byte
Lekc203  label     byte
db 'sl)',LF
db LF
db 'Um°stàte ruce do z†kladn° polohy a nacviáujte tato p°smena:',LF
db LF
db ' prsten°kem levÇ ruky  - s',LF
db 'prsten°kem pravÇ ruky  - l',LF
db LF
db 'Nezapome§te dodrëovat spr†vnò rytmus psan° a pi®te rovnomàrnà.',LF
db 'Ostatn° prsty nezvedejte!',LF
db LF
db EOT

LDatC03  label     byte
db 'ssssssss llllllll sfsfsf ljljlj sdsdsd lklklk sasasa lñlñlñ',LF
db 'jak jal jak jal jak jal jak jal jak jal jak jal jak jal jak',LF
db 'sñl dñl sñl dñl sñl dñl sñl dñl sñl dñl sñl dñl sñl dñl sñl',LF
db 'kal lak kal lak kal lak kal lak kal lak kal lak kal lak kal',LF
db 'skla sklñ skla sklñ skla sklñ skla sklñ skla sklñ skla sklñ',LF
db 'jas sad jas sad jas sad jas sad jas sad jas sad jas sad jas',LF
db 'klad kladñ sad sadñ klad kladñ sad sadñ klad kladñ sad sadñ',LF
db 'klas klasñ lak lakñ klas klasñ lak lakñ klas klasñ lak lakñ',LF
db 'lada alfa dala lasa lada alfa dala lasa lada alfa dala lasa',LF
db FF
db 'dala kajak dala sñl dala fald dala klas dala dñl dala sklad',LF
db FF
db 'dal kajak kajakñ jak sklad skladñ a sad sadñ jak klas klasñ',LF
db FF
db 'dal lñj jak sñl kladl kñl jak dñl kasa jñ dala sñl kala fñj',LF
db 'jala kñl dala sñl alfa dñl lasa jñl kasa kñl jaffa lñj sada',LF
db FF
db 'sklad kajakñ dal kajak jak sklad lakñ dal lak jak sada kñlñ',LF
db 'sad sadñ klad kladñ slad sladñ lak lakñ fald faldñ jak jakñ',LF
db 'jala dala alfa dñl skla lasa lada sada kñl dala sladñ jaffa',LF
db EOT

LDatI03  label     byte
LDat103  label     byte
LDat203  label     byte
db 'ssssssss llllllll sfsfsf ljljlj sdsdsd lklklk sasasa l;l;l;',LF
db 'jak jal jak jal jak jal jak jal jak jal jak jal jak jal jak',LF
db 'sal dal sal dal sal dal sal dal sal dal sal dal sal dal sal',LF
db 'kal lak kal lak kal lak kal lak kal lak kal lak kal lak kal',LF
db 'skla jak; skla jak; skla jak; skla jak; skla jak; skla jak;',LF
db 'jas sad jas sad jas sad jas sad jas sad jas sad jas sad jas',LF
db 'klad klad; sad sad; klad klad; sad sad; klad klad; sad sad;',LF
db 'klas klas; lak lak; klas klas; lak lak; klas klas; lak lak;',LF
db 'lada alfa dala lasa lada alfa dala lasa lada alfa dala lasa',LF
db FF
db 'dala kajak dal; jak dala fald dala klas dal; lad dala sklad',LF
db FF
db 'dal kajak kajak; jak sklad sklad; a sad sad; jak klas klas;',LF
db FF
db 'dal lad jak sal; kladl lak jak dal; kasa dala sal; kala fal',LF
db 'jala lak dala sal alfa dal lasa jal kasa lak jaffa jal sada',LF
db FF
db 'sklad kajak; dal kajak jak sklad jal; dal lak jak sada jal;',LF
db 'sad sad; klad klad; slad slad; lak lak; fald fald; jak jak;',LF
db 'jala dala alfa dal skla lasa lada sada jak dala slad; jaffa',LF
db EOT

; ------ lekce 04 - ur
;˛
LekcC04  label     byte
LekcI04  label     byte
Lekc104  label     byte
Lekc204  label     byte
db 'ru)',LF
db 'P©i  psan°  kl†ves,  na  nichë  nespoá°vaj° prsty p©i z†kladn° poloze je',LF
db 'nutno  p©°slu®nò  prst  vychòlit  z  tÇto  polohy, p©iáemë ostatn° prsty',LF
db 'v tÇto poloze mus° zñstat. Po stisknut° kl†vesy se prst vrac° zpàt.',LF
db LF
db ' ukazov†ákem levÇ ruky  - r',LF
db 'ukazov†ákem pravÇ ruky  - u',LF
db LF
db 'D†vejte  pozor na to, aby ostatn° prsty zñstaly v z†kladn° poloze, a aby',LF
db 'se prst po naps†n° p°smene vr†til na pñvodn° m°sto (do z†kladn° polohy).',LF
db EOT

LDatC04  label     byte
db 'rrrrrrrr uuuuuuuu frfrfrfrfrf jujujujujuj frdsfrds jukljukl',LF
db 'raf ras raf ras raf ras raf ras raf ras raf ras raf ras raf',LF
db 'ulj ulk ulj ulk ulj ulk ulj ulk ulj ulk ulj ulk ulj ulk ulj',LF
db 'dar jar dar jar dar jar dar jar dar jar dar jar dar jar dar',LF
db 'sar kar sar kar sar kar sar kar sar kar sar kar sar kar sar',LF
db 'duj kuj duj kuj duj kuj duj kuj duj kuj duj kuj duj kuj duj',LF
db 'drf krf drf krf drf krf drf krf drf krf drf krf drf krf drf',LF
db 'druk kurd druk kurd druk kurd druk kurd druk kurd druk kurd',LF
db 'lusk daru lusk daru lusk daru lusk daru lusk daru lusk daru',LF
db 'daru kurs radar lusk krajku alfu araku faul kafru lukñ kadr',LF
db FF
db 'kus kusñ kraj krajñ rada radu kurs kufru dal radu udal kurs',LF
db 'rada ruda sñl sud ruka rus rula fuka luk kajak klas sad dar',LF
db FF
db 'kraj luk ar sadu kus skla kus lasa sud sladu sud laku sklad',LF
db 'dala dar dala krajku dala luk dala ladu dala kufr dala ruku',LF
db 'dal radu udal kurs k radaru k sadu u kajaku u skladu u sudu',LF
db EOT

LDatI04  label     byte
LDat104  label     byte
LDat204  label     byte
db 'rrrrrrrr uuuuuuuu frfrfrfrfrf jujujujujuj frdsfrds jukljukl',LF
db 'raf ras raf ras raf ras raf ras raf ras raf ras raf ras raf',LF
db 'ulj ulk ulj ulk ulj ulk ulj ulk ulj ulk ulj ulk ulj ulk ulj',LF
db 'dar jar dar jar dar jar dar jar dar jar dar jar dar jar dar',LF
db 'sar kar sar kar sar kar sar kar sar kar sar kar sar kar sar',LF
db 'duj kuj duj kuj duj kuj duj kuj duj kuj duj kuj duj kuj duj',LF
db 'drf krf drf krf drf krf drf krf drf krf drf krf drf krf drf',LF
db 'druk kurd druk kurd druk kurd druk kurd druk kurd druk kurd',LF
db 'lusk daru lusk daru lusk daru lusk daru lusk daru lusk daru',LF
db 'daru kurs radar lusk krajku alfu araku faul kafru luka kadr',LF
db FF
db 'kus kus; kraj kraj; rada radu kurs kufru dal radu udal kurs',LF
db 'rada ruda sal sud ruka rus rula fuka luk kajak klas sad dar',LF
db FF
db 'kraj luk ar sadu kus skla kus lasa sud sladu sud laku sklad',LF
db 'dala dar dala krajku dala luk dala ladu dala kufr dala ruku',LF
db 'dal radu udal kurs k radaru k sadu u kajaku u skladu u sudu',LF
db EOT

; ------ lekce 05 - i,
;˛
LekcC05  label     byte
LekcI05  label     byte
Lekc105  label     byte
Lekc205  label     byte
db 'i,)',LF
db LF
db 'V tÇto lekci se nauá°te ps†t prost©edn°kem pravÇ ruky p°smeno i a á†rku.',LF
db LF
db 'prost©edn°kem pravÇ ruky  - i',LF
db 'prost©edn°kem pravÇ ruky  - ,',LF
db LF
db 'V textu se á†rka p©ipojuje bez mezery k p©edch†zej°c°mu slovu. Mezera se',LF
db 'dàl† aë za á†rkou.',LF
db LF
db EOT

LDatC05  label     byte
db 'iiiiiiii ,,,,,,,, kikikikikikik k,k,k,k,k,k,k,k kik,kik,kik',LF
db 'kik jik kik jik kik jik kik jik kik jik kik jik kik jik kik',LF
db 'jak, lak, jak, lak, jak, lak, jak, lak, jak, lak, jak, lak,',LF
db 'kid lid kid lid kid lid kid lid kid lid kid lid kid lid kid',LF
db 'kila sila kila sila kila sila kila sila kila sila kila sila',LF
db 'liji siji liji siji liji siji liji siji liji siji liji siji',LF
db 'lidu lisu lidu lisu lidu lisu lidu lisu lidu lisu lidu lisu',LF
db 'laik a klasik, laik a klasik, laik a klasik, laik a klasik,',LF
db 'dali kari, radil risk, kafir, dali kari, radil risk, kafir,',LF
db 'kraj safari, sili a sklidili kari, lis a klika, sklad kulis',LF
db FF
db 'klasik radil klid, dali kari, udusili sirku, uklidili sklad',LF
db FF
db 'sili jarku, dali skif, lili lak, udali kurs, uklidili kufr,',LF
db 'sklad kulis, sklad lakñ, kila luskñ, kraj safari, kus suku,',LF
db 'radili klid, udusili sirku, sklidili jarku, dali sadu skla,',LF
db FF
db 'ruda rula drak frak kurs radar kñra kuj duj luka dural kal,',LF
db 'sklidili, jiskra jiskru, sklad kajakñ a slad sladñ, uklidil',LF
db 'disk a risk, jak a lak, lid a klid, ruda a rula, duj a kuj,',LF
db 'uklidili sklad, sklidili kraj sadu, udal kurs radaru, ruda,',LF
db 'sklidili kila luskñ, udusil sirku, usadil rusalku u kajaku,',LF
db EOT

LDatI05  label     byte
LDat105  label     byte
LDat205  label     byte
db 'iiiiiiii ,,,,,,,, kikikikikikik k,k,k,k,k,k,k,k kik,kik,kik',LF
db 'kik jik kik jik kik jik kik jik kik jik kik jik kik jik kik',LF
db 'jak, lak, jak, lak, jak, lak, jak, lak, jak, lak, jak, lak,',LF
db 'kid lid kid lid kid lid kid lid kid lid kid lid kid lid kid',LF
db 'kila sila kila sila kila sila kila sila kila sila kila sila',LF
db 'liji siji liji siji liji siji liji siji liji siji liji siji',LF
db 'lidu lisu lidu lisu lidu lisu lidu lisu lidu lisu lidu lisu',LF
db 'laik a klasik, laik a klasik, laik a klasik, laik a klasik,',LF
db 'dali kari, radil risk, kafir, dali kari, radil risk, kafir,',LF
db 'kraj safari, sili a sklidili kari, lis a klika, sklad kulis',LF
db FF
db 'klasik radil klid, dali kari, udusili sirku, uklidili sklad',LF
db FF
db 'sili jarku, dali skif, lili lak, udali kurs, uklidili kufr,',LF
db 'sklad kulis, sklad laku, kila lusku, kraj safari, kus suku,',LF
db 'radili klid, udusili sirku, sklidili jarku, dali sadu skla,',LF
db FF
db 'ruda rula drak frak kurs radar kari kuj duj luka dural kal,',LF
db 'sklidili, jiskra jiskru, sklad kajaku a slad sladu, uklidil',LF
db 'disk a risk, jak a lak, lid a klid, ruda a rula, duj a kuj,',LF
db 'uklidili sklad, sklidili kraj sadu, udal kurs radaru, ruda,',LF
db 'sklidili kila lusku, udusil sirku, usadil rusalku u kajaku,',LF
db EOT

IFNDEF   DEMO

; ------ lekce 06 - pq
;˛
LekcC06  label     byte
LekcI06  label     byte
Lekc106  label     byte
Lekc206  label     byte
db 'qp)',LF
db 'P°smeno  p  p°®eme vychòlen°m mal°áku pravÇ ruky v p©°mÇm smàru na horn°',LF
db '©adu kl†ves. P°smeno q p°®eme vychòlen°m mal°áku levÇ ruky p©°mo nahoru.',LF
db LF
db ' mal°ákem levÇ ruky  - q',LF
db 'mal°ákem pravÇ ruky  - p',LF
db LF
db 'Ukazov†áky na p°smenech f a j nesm° opustit tuto svou kl†vesu, neboü n†m',LF
db 'slouë° jako opàrnò bod.',LF
db LF
db EOT

LDatC06  label     byte
db 'qqqqqqqq pppppppp aqaqaqaqaqaqa ñpñpñpñpñpñpñpñ qapñqapñqap',LF
db 'ñpñ kjk ñpñ kjk ñpñ kjk ñpñ kjk ñpñ kjk ñpñ kjk ñpñ kjk ñpñ',LF
db 'aqa dfd aqa dfd aqa dfd aqa dfd aqa dfd aqa dfd aqa dfd aqa',LF
db 'pñl kñl pñl kñl pñl kñl pñl kñl pñl kñl pñl kñl pñl kñl pñl',LF
db 'qua aqu qua aqu qua aqu qua aqu qua aqu qua aqu qua aqu qua',LF
db 'pñda pñdu kapka aqu pñda pñdu kapka aqu pñda pñdu kapka aqu',LF
db 'pak pas pñl pak pas pñl pak pas pñl pak pas pñl pak pas pñl',LF
db 'parkuji pilu parkuji pilu parkuji pilu parkuji pilu parkuji',LF
db 'spis qua upadl spis qua upadl spis qua upadl spis qua upadl',LF
db 'kupuji sad, kupuji kajak, kupuji ladu, kupuji lak, kup sñl,',LF
db 'kapra kaprñ, paprika papriku, pñl kila paprik, pñlka kapra,',LF
db 'pñlka sirupu, quis aqua, kup purpuru, kup rips, kupuji srp,',LF
db FF
db 'psal spis jak spadla pila, pak sladil sirup a pñlil papriku',LF
db 'parkuji u skladu, u parku, pñjdu k sadu, pak pñjdu k parku,',LF
db FF
db 'sklidili papriku, uklidil slupku, pñlil kapra, upil sirupu,',LF
db 'kup srp a pilku, kup kari a papriku, kupuji rips, kup kafr,',LF
db 'spadla sirka, dali kufr, dali pilku, psali spis, dali skif,',LF
db FF
db 'si asi lid klid dril skif disk lidu klidu drilu skifu disku',LF
db 'usadil jsi, radil jsi, sklidil jsi, uklidil jsi, radil jsi,',LF
db 'spadla lupa, kulil sud, parkuji u parku, pñlil pñlku kapra,',LF
db 'uklidil slupku, sklidili park, dal draka, plakali a plakali',LF
db 'sirka spadla, ukradl pilu, sklidil kila luskñ a kila paprik',LF
db FF
db 'pñl parku, pñl sadu, pñl kila lilku, pñl kila luskñ, pñlka,',LF
db 'sud kaprñ, kraj luk, kurs juda, kus skla, kapka kafru, kus,',LF
db 'dala jsi radu, dala jsi krajku, dal jsi pilku, dal jsi srp,',LF
db 'kup kus ripsu, kup lupu, kup pudr, jdu k sadu, jdu k parku,',LF
db 'pil sirup, udusil sirku, radil klid, slil lak, ulil sirupu,',LF
db 'spadl kufr, spadla kapka laku, uklidil pilku, spadla sirka,',LF
db 'daruji psa, daruji sadu skla, kupuji papriku, kupuji kapra,',LF
db EOT

LDatI06  label     byte
LDat106  label     byte
LDat206  label     byte
db 'qqqqqqqq pppppppp aqaqaqaqaqaqa ;p;p;p;p;p;p;p; qap;qap;qap',LF
db ';p; kjk ;p; kjk ;p; kjk ;p; kjk ;p; kjk ;p; kjk ;p; kjk ;p;',LF
db 'aqa dfd aqa dfd aqa dfd aqa dfd aqa dfd aqa dfd aqa dfd aqa',LF
db 'pil kil pil kil pil kil pil kil pil kil pil kil pil kil pil',LF
db 'qua aqu qua aqu qua aqu qua aqu qua aqu qua aqu qua aqu qua',LF
db 'pak pas pil pak pas pil pak pas pil pak pas pil pak pas pil',LF
db 'parkuji pilu parkuji pilu parkuji pilu parkuji pilu parkuji',LF
db 'spis qua upadl spis qua upadl spis qua upadl spis qua upadl',LF
db 'kupuji sad, kupuji kajak, kupuji ladu, kupuji lak, kup lis,',LF
db 'kapra kapr, paprika papriku, lap kila paprik, pilka, kapra,',LF
db 'pilka; sirup, quis aqua, kup purpuru, kup rips, kupuji srp,',LF
db FF
db 'psal spis jak spadla pila, pak sladil sirup a papriku, dal;',LF
db 'parkuji u skladu, pil u parku, jdu k sadu, pak jdu k parku,',LF
db FF
db 'sklidili papriku, uklidil slupku, lapil kapra, upil sirupu,',LF
db 'kup srp a pilku, kup kari a papriku, kupuji rips, kup kafr,',LF
db 'spadla sirka, dali kufr, dali pilku, psali spis, dali skif,',LF
db FF
db 'si asi lid klid dril skif disk lidu klidu drilu skifu disku',LF
db 'usadil jsi, radil jsi, sklidil jsi, uklidil jsi, radil jsi,',LF
db 'spadla lupa, kulil sud, parkuji u parku, lapil kapku kapra,',LF
db 'uklidil slupku, sklidili park, dal draka, plakali a plakali',LF
db 'sirka spadla, ukradl pilu, sklidil kila lusku a kila paprik',LF
db FF
db 'pil u parku, u sadu, dal kila lilku, dal kila paprik, pila,',LF
db 'sud kapra, kraj luk, kurs juda, kus skla, kapka kafru, kus,',LF
db 'dala jsi radu, dala jsi krajku, dal jsi pilku, dal jsi srp,',LF
db 'kup kus ripsu, kup lupu, kup pudr, jdu k sadu, jdu k parku,',LF
db 'pil sirup, udusil sirku, radil klid, slil lak, ulil sirupu,',LF
db 'spadl kufr, spadla kapka laku, uklidil pilku, spadla sirka,',LF
db 'daruji psa, daruji sadu skla, kupuji papriku, kupuji kapra,',LF
db EOT

; ------ lekce 07 - hg
;˛
LekcC07  label     byte
LekcI07  label     byte
Lekc107  label     byte
Lekc207  label     byte
db 'gh)',LF
db LF
db 'P°smeno h  p°®eme  vychòlen°m pravÇho ukazov†áku p©°mo doleva. P°smeno g',LF
db 'p°®eme  vychòlen°m levÇho ukazov†áku p©°mo doprava. Po stisknut° kl†vesy',LF
db 'se prst vrac° zpàt do z†kladn° polohy.',LF
db LF
db ' ukazov†ákem levÇ ruky  - g',LF
db 'ukazov†ákem pravÇ ruky  - h',LF
db LF
db LF
db EOT

LDatC07  label     byte
db 'gggggggg hhhhhhhh fgfgfgfgfgfgfgf jhjhjhjhjhjhjhj fgfjhjfgf',LF
db 'jhj fgf jhj fgf jhj fgf jhj fgf jhj fgf jhj fgf jhj fgf jhj',LF
db 'dis gis his dis gis his dis gis his dis gis his dis gis his',LF
db 'hasil hasili uhasil hasil hasili uhasil hasil hasili uhasil',LF
db 'jahñdka, lahñdka jahñdka, lahñdka jahñdka, lahñdka jahñdka,',LF
db 'graf hrad graf hrad graf hrad graf hrad graf hrad graf hrad',LF
db 'hra hrad hraji urguj urguji hra hrad hraji urguj urguji hra',LF
db 'hl lihu, ha luk, hl lihu, ha luk, hl lihu, ha luk, hl lihu,',LF
db 'g kafru, kg paprik, kg klihu, g kafru, kg paprik, kg klihu,',LF
db FF
db 'hra hru hrad hradili uhradili druh druhu dluh dluhu druh kg',LF
db FF
db 'pñl kg krup, pñl kg paprik, kg kafru, hl lihu, uhasil sirku',LF
db 'druh laku, g kari, kg klihu, druh duralu, ha sadu, hl lihu,',LF
db 'kupuji gril, urguji dluh, uhradil dluh, hraji ligu, urguji,',LF
db 'uklidili halu, uhasili sirku, uklidili pluh, uhasili lulku,',LF
db 'sklad kulis, pruh sadñ, hlas lidu, hluk pluhñ, druh paprik,',LF
db 'kup kg paprik a kg luskñ, kupuji sadu skla, kupuji kg laku,',LF
db EOT

LDatI07  label     byte
LDat107  label     byte
LDat207  label     byte
db 'gggggggg hhhhhhhh fgfgfgfgfgfgfgf jhjhjhjhjhjhjhj fgfjhjfgf',LF
db 'jhj fgf jhj fgf jhj fgf jhj fgf jhj fgf jhj fgf jhj fgf jhj',LF
db 'dis gis his dis gis his dis gis his dis gis his dis gis his',LF
db 'hasil hasili uhasil hasil hasili uhasil hasil hasili uhasil',LF
db 'gril grilu, liga ligu, gril grilu, hraji ligu, urguji gril;',LF
db 'graf hrad graf hrad graf hrad graf hrad graf hrad graf hrad',LF
db 'hra hrad hraji urguj urguji hra hrad hraji urguj urguji hra',LF
db 'hl lihu, ha luk, hl lihu, ha luk, hl lihu, ha luk, hl lihu,',LF
db 'g kafru, kg paprik, kg klihu, g kafru, kg paprik, kg klihu,',LF
db FF
db 'hra hru hrad hradili uhradili druh druhu dluh dluhu druh kg',LF
db FF
db 'dal kg krup, dal kg paprik, kg kafru, hl lihu, uhasil sirku',LF
db 'druh laku, g kari, kg klihu, druh duralu, ha sadu, hl lihu,',LF
db 'kupuji gril, urguji dluh, uhradil dluh, hraji ligu, urguji,',LF
db 'uklidili halu, uhasili sirku, uklidili pluh, uhasili lulku,',LF
db 'sklad kulis, pruh sadu, hlas lidu, hluk pluhu, druh paprik,',LF
db 'kup kg paprik a kg lusku, kupuji sadu skla, kupuji kg laku,',LF
db EOT

; ------ lekce 08 - e
;˛
LekcC08  label     byte
LekcI08  label     byte
Lekc108  label     byte
Lekc208  label     byte
db 'e)',LF
db LF
db 'Um°stàte ruce do z†kladn° polohy a nacviáujte:',LF
db LF
db 'prost©edn°kem levÇ ruky  - e',LF
db LF
db 'Ostatn° prsty, zejmÇna ukazov†áky, mus° zñstat v z†kladn° poloze.',LF
db LF
db LF
db LF
db EOT

LDatC08  label     byte
db 'eeeeeeeee dedededededed sed sed sed fed fed fed def def def',LF
db 'dre fre dre fre dre fre dre fre dre fre dre fre dre fre dre',LF
db 'rek pek rek pek rek pek rek pek rek pek rek pek rek pek rek',LF
db 'jed led sed jed led sed jed led sed jed led sed jed led sed',LF
db 'deska desek deska desek deska desek deska desek deska desek',LF
db 'jedle jesle jedle jesle jedle jesle jedle jesle jedle jesle',LF
db FF
db 'dle ale jel jela jede jedu ale hledal hledala adresa adresu',LF
db FF
db 'sled kursñ, druh keksñ, druh paprik, pruh lesñ, hluk pluhñ,',LF
db 'urguje dluh, hraje ligu, kupuje galusku, parkuje u galerie,',LF
db 'parkuje u skladu, jel k lesu, sekal u lesa, hledal sedadla,',LF
db FF
db 'jede jekl sedl kefa jel griluje hledal dñlek hledal sekerku',LF
db 'hraje kupuje urguje redukuje parkuje kupuje urguje redukuje',LF
db 'ha lesa, ha pralesa, kg krupek, kg jader, ha sadu, ha lesa,',LF
db 'sekal sekala, sekerka sekerek, sekl sekla, sekerka sekerku,',LF
db 'deska desku, freska fresku, ledek ledku, dñsledek dñsledku,',LF
db FF
db 'hledala jesle, hledala jehlu, hledala adresu, hledala graf,',LF
db 'kupuje sekerku, redukuje sklad, urguje ledek, lakuje kajak,',LF
db 'psal adresu, psal hesla, psal hru, psal fugu, sepsal hesla,',LF
db 'deska praskla, pñda se sesula, pera selhala, sekerka sjela,',LF
db 'pejsek je rek, uhasili fajfku, udali hesla, sedli si u lesa',LF
db EOT

LDatI08  label     byte
LDat108  label     byte
LDat208  label     byte
db 'eeeeeeeee dedededededed sed sed sed fed fed fed def def def',LF
db 'dre fre dre fre dre fre dre fre dre fre dre fre dre fre dre',LF
db 'rek pek rek pek rek pek rek pek rek pek rek pek rek pek rek',LF
db 'jed led sed jed led sed jed led sed jed led sed jed led sed',LF
db 'deska desek deska desek deska desek deska desek deska desek',LF
db 'jedle jesle jedle jesle jedle jesle jedle jesle jedle jesle',LF
db FF
db 'dle ale jel jela jede jedu ale hledal hledala adresa adresu',LF
db FF
db 'sled kursu, druh keksu, druh paprik, pruh lesa, hluk pluhu,',LF
db 'urguje dluh, hraje ligu, kupuje galusku, parkuje u galerie,',LF
db 'parkuje u skladu, jel k lesu, sekal u lesa, hledal sedadla,',LF
db FF
db 'jede jekl sedl kefa jel griluje hledal ledek hledal sekerku',LF
db 'hraje kupuje urguje redukuje parkuje kupuje urguje redukuje',LF
db 'ha lesa, ha pralesa, kg krupek, kg jader, ha sadu, ha lesa,',LF
db 'sekal sekala, sekerka sekerek, sekl sekla, sekerka sekerku,',LF
db 'deska desku, freska fresku, ledek ledku, pejsek pejska lap,',LF
db FF
db 'hledala jesle, hledala jehlu, hledala adresu, hledala graf,',LF
db 'kupuje sekerku, redukuje sklad, urguje ledek, lakuje kajak,',LF
db 'psal adresu, psal hesla, psal hru, psal fugu, sepsal hesla,',LF
db 'deska praskla, ruka se sesula, pera selhala, sekerka sjela,',LF
db 'pejsek je rek, uhasili fajfku, udali hesla, sedli si u lesa',LF
db EOT

; ------ lekce 09 - ow
;˛
LekcC09  label     byte
LekcI09  label     byte
Lekc109  label     byte
Lekc209  label     byte
db 'wo)',LF
db LF
db 'P°smeno  w p°®eme vychòlen°m levÇho prsten°ku na horn° ©adu smàrem vlevo',LF
db 'nahoru.  P°smeno  o  p°®eme vychòlen°m pravÇho prsten°ku nahoru na horn°',LF
db '©adu kl†ves.',LF
db LF
db ' prsten°kem levÇ ruky  - w',LF
db 'prsten°kem pravÇ ruky  - o',LF
db LF
db LF
db EOT

LDatC09  label     byte
db 'wwwwwwww oooooooo swswswswswsws lolololololol swslol swslol',LF
db 'lol pol lol pol lol pol lol pol lol pol lol pol lol pol lol',LF
db 'sws swq sws swq sws swq sws swq sws swq sws swq sws swq sws',LF
db 'jawa kiwi jawa kiwi jawa kiwi jawa kiwi jawa kiwi jawa kiwi',LF
db 'rok lok rok lok rok lok rok lok rok lok rok lok rok lok rok',LF
db 'kolek kolej hokej kolek kolej hokej kolek kolej hokej kolek',LF
db 'opera opora opera opora opera opora opera opora opera opora',LF
db 'spor sporu opora oporu odpor odporu podpora podporuje odpor',LF
db 'odjel odeslal opsal opadalo sokl sojka ohradili sloh korela',LF
db 'rok rokñ, krok krokñ, pokus pokusñ, posudek posudkñ, kolkñ,',LF
db 'how, where, walk, show, well, flower, who, follow, wash, we',LF
db FF
db 'pokud dokud odeslal odsud jako jeho daleko dlouho kolik kdo',LF
db FF
db 'prodej jahod, prodej lahñdek, prodej kolkñ, pokles prodeje,',LF
db 'sklo odeslala jako dar, prodala jawu, odeslala odsud dopis,',LF
db 'spor o doklad, spor o dluh, spor o posudek, dñsledek sporu,',LF
db FF
db 'dodal do skladu kakao, dodal olej, sñl a goudu, dodal sodu,',LF
db 'podepsala dohodu, podepsala posudek, popsala polohu safari,',LF
db 'poslal doklad do rukou soudu, odeslal graf, odeslal adresu,',LF
db 'odjela odsud s jawou, jela dlouho osadou, dojela do okresu,',LF
db FF
db 'hrad hru hradñ dluh grafñ paragraf liga fuga garda gril les',LF
db 'lahñdka hñlka galuska dlahu prodej koleje hokej dolej fokus',LF
db 'pohled k hradu, koule a disk, odeslali dopis k podpisu, los',LF
db 'jeli dlouhou osadou okolo lesa k hradu, popsali polohu sadu',LF
db 'koupili kolo, prodali korek, odeslali sklo, prodali kokosku',LF
db 'uhradili dluh, uklidili hru, parkuji u hradu, kup kg krupek',LF
db 'psal hru, jedl lahñdku, dñsledek hladu, sklad galusek, keks',LF
db 'deska se leskla, sepsal hesla, regres je opak progresu, sad',LF
db 'soudek jahod, odsoudil jeho dohad, dohodli se o odkladu her',LF
db 'doklad o pokusu, porada geologñ, prodej sadu, prodali kokos',LF
db 'poloha pokoje, koupili goudu, hraje ligu, koupili kg housek',LF
db 'hluk se redukuje, posudek od ekologa, propaguje hokej, golf',LF
db EOT

LDatI09  label     byte
LDat109  label     byte
LDat209  label     byte
db 'wwwwwwww oooooooo swswswswswsws lolololololol swslol swslol',LF
db 'lol pol lol pol lol pol lol pol lol pol lol pol lol pol lol',LF
db 'sws swq sws swq sws swq sws swq sws swq sws swq sws swq sws',LF
db 'jawa kiwi jawa kiwi jawa kiwi jawa kiwi jawa kiwi jawa kiwi',LF
db 'rok lok rok lok rok lok rok lok rok lok rok lok rok lok rok',LF
db 'kolek kolej hokej kolek kolej hokej kolek kolej hokej kolek',LF
db 'opera opora opera opora opera opora opera opora opera opora',LF
db 'spor sporu opora oporu odpor odporu podpora podporuje odpor',LF
db 'odjel odeslal opsal opadalo sokl sojka ohradili sloh korela',LF
db 'rok roku, krok kroku, pokus pokusu, posudek posudku, kolek,',LF
db 'how, where, walk, show, well, flower, who, follow, wash, we',LF
db FF
db 'pokud dokud odeslal odsud jako jeho daleko dlouho kolik kdo',LF
db FF
db 'prodej jahod, prodej kolejek, prodej ledku, pokles prodeje;',LF
db 'sklo odeslala jako dar, prodala jawu, odeslala odsud dopis;',LF
db 'spor o doklad, spor o dluh, spor o posudek, spor o sekerku;',LF
db FF
db 'dodal do skladu kakao, dodal olej, led a goudu, dodal sodu,',LF
db 'podepsala dohodu, podepsala posudek, popsala polohu safari,',LF
db 'poslal doklad do rukou soudu, odeslal graf, odeslal adresu,',LF
db 'odjela odsud s jawou, jela dlouho osadou, dojela do okresu,',LF
db FF
db 'hrad hru hrad; dluh graf; paragraf liga fuga garda gril les',LF
db 'polepka polka galuska dlahu prodej koleje hokej dolej fokus',LF
db 'pohled k hradu, koule a disk, odeslali dopis k podpisu, los',LF
db 'jeli dlouhou osadou okolo lesa k hradu, popsali polohu sadu',LF
db 'koupili kolo, prodali korek, odeslali sklo, prodali kokosku',LF
db 'uhradili dluh, uklidili hru, parkuji u hradu, kup kg krupek',LF
db 'psali hru i eseje, jedl keks a papriku, sklad galusek, keks',LF
db 'deska se leskla, sepsal hesla, regres je opak progresu, sad',LF
db 'soudek jahod, odsoudil jeho dohad, dohodli se o odkladu her',LF
db 'doklad o pokusu, geolog upadl, prodej sadu, prodali kokosku',LF
db 'poloha pokoje, koupili goudu, hraje ligu, koupili kg housek',LF
db 'hluk se redukuje, posudek od ekologa, propaguje hokej, golf',LF
db EOT

; ------ lekce 10 - z
;˛
LekcC10  label     byte
db 'z)',LF
db LF
db 'P°smeno  z  p°®eme  vychòlen°m  pravÇho ukazov†áku vlevo vzhñru na horn°',LF
db '©adu kl†ves.',LF
db LF
db 'ukazov†ákem pravÇ ruky  - z',LF
db LF
db 'Uvàdomte  si  rozd°l  mezi  psan°m  u  a  z.  Po  stisknut° znaku vraüte',LF
db 'ukazov†áek do z†kladn° polohy, ostatn° prsty nezvedejte.',LF
db LF
db EOT

LekcI10  label     byte
Lekc110  label     byte
Lekc210  label     byte
db 'z)',LF
db LF
db 'P°smeno z p°®eme vychòlen°m levÇho mal°áku dolñ na doln° ©adu kl†ves.',LF
db LF
db LF
db 'mal°ákem levÇ ruky  - z',LF
db LF
db LF
db LF
db LF
db EOT

LDatC10  label     byte
db 'zzzzzzzzz jzjzjzjzjzjzjzjzj jzj zjz jzj zjz jzj zjz jzj zjz',LF
db 'jzj klñ jzj klñ jzj klñ jzj klñ jzj klñ jzj klñ jzj klñ jzj',LF
db 'zaj zuj zaj zuj zaj zuj zaj zuj zaj zuj zaj zuj zaj zuj zaj',LF
db 'juz zuk juz zuk juz zuk juz zuk juz zuk juz zuk juz zuk juz',LF
db 'zas zde zas zde zas zde zas zde zas zde zas zde zas zde zas',LF
db 'dozor pozor dozor pozor dozor pozor dozor pozor dozor pozor',LF
db 'zajel zadal zajel zadal zajel zadal zajel zadal zajel zadal',LF
db 'dñkazñ rozkazñ dñkazñ rozkazñ dñkazñ rozkazñ dñkazñ rozkazñ',LF
db 'zaslal jezdil odjezd sjezd rozeslal rozhodl zapojil zakupil',LF
db FF
db 'prodali azalku, koupili rezedu, pozor uzel, rozprodali azur',LF
db FF
db 'odeslal prñkaz, rozprodali fazole, zalil rezedu, zase zasil',LF
db 'rozkopal i zahradu, rozhodli se pro hazard, zde se zapojuje',LF
db 'zaslali doklad, zase rozeslali sklo, dali do prodeje fazole',LF
db FF
db 'dal rozkaz, podal dñkaz, kladl dñraz, zisk z prodeje klesl,',LF
db 'prodali kolo, zalepili do dopisu graf a zaslali kopii spisu',LF
db 'zasekl sekerku, zakoupil azalku, zoufale lezl, koza a kñzle',LF
db 'zorali zahradu i sad, dohodli se o kazu, jeli i okolo jezer',LF
db 'zakoupil glazuru, za rok pojedu zase do hor, zas se zapojil',LF
db 'pokosili louku kousek za zahradou a pak zajeli pro papriku,',LF
db 'zapojili proud, zapsal si adresu, zakreslili polohu jezera,',LF
db 'zajel k sadu, zakoupil gril, zde se zapisuje do kursu juda,',LF
db 'hledali kaz, hledali prñkazku, zkazili dopis, popsali spis,',LF
db 'rozhodl se pro odjezd, odjel rok po sjezdu, rozjezdil pole,',LF
db EOT

LDatI10  label     byte
LDat110  label     byte
LDat210  label     byte
db 'zzzzzzzzz azazazazazazazaza aza zaz aza zaz aza zaz aza zaz',LF
db 'aza sdf aza sdf aza sdf aza sdf aza sdf aza sdf aza sdf aza',LF
db 'zas kaz zas kaz zas kaz zas kaz zas kaz zas kaz zas kaz zas',LF
db 'jaz zak jaz zak jaz zak jaz zak jaz zak jaz zak jaz zak jaz',LF
db 'zas zde zas zde zas zde zas zde zas zde zas zde zas zde zas',LF
db 'dozor pozor dozor pozor dozor pozor dozor pozor dozor pozor',LF
db 'zajel zadal zajel zadal zajel zadal zajel zadal zajel zadal',LF
db 'rozhodl rozhodla rozhodli, rozprodal rozprodala rozprodali,',LF
db 'zaslal jezdil odjezd sjezd rozeslal rozhodl zapojil zakupil',LF
db FF
db 'prodali azalku, koupili rezedu, pozor uzel, rozprodali azur',LF
db FF
db 'odeslal rozkaz, rozprodali fazole, zalil rezedu, zase zasil',LF
db 'rozkopal i zahradu, rozhodli se pro hazard, zde se zapojuje',LF
db 'zaslali doklad, zase rozeslali sklo, dali do prodeje fazole',LF
db FF
db 'dal rozkaz, podal dopis, kladl pilku, zisk z prodeje klesl,',LF
db 'prodali kolo, zalepili do dopisu graf a zaslali kopii spisu',LF
db 'zasekl sekerku, zakoupil azalku, zoufale lezl, koza a lilka',LF
db 'zorali zahradu i sad, dohodli se o kazu, jeli i okolo jezer',LF
db 'zakoupil glazuru, za rok pojedu zase do hor, zas se zapojil',LF
db 'pokosili louku kousek za zahradou a pak zajeli pro papriku,',LF
db 'zapojili proud, zapsal si adresu, zakreslili polohu jezera,',LF
db 'zajel k sadu, zakoupil gril, zde se zapisuje do kursu juda,',LF
db 'hledali kaz, koupili fazoli, zkazili dopis, popsali rozpis,',LF
db 'rozhodl se pro odjezd, odjel rok po sjezdu, rozjezdil pole,',LF
db EOT

; ------ lekce 11 - t
;˛
LekcC11  label     byte
LekcI11  label     byte
Lekc111  label     byte
Lekc211  label     byte
db 't)',LF
db LF
db 'P°smeno  t  p°®eme  vychòlen°m  levÇho  ukazov†áku  na horn° ©adu kl†ves',LF
db 'smàrem  vpravo.  Je dñleëitÇ si uvàdomit rozd°l mezi vychòlen°m prstu na',LF
db 'p°smeno r a t. Nezapome§te se vracet do z†kladn° polohy.',LF
db LF
db 'ukazov†ákem levÇ ruky  - t',LF
db LF
db LF
db LF
db EOT

LDatC11  label     byte
db 'ttttttttt ftftftftftftftftf ftf tft ftf tft ftf tft ftf tft',LF
db 'ftf dsa ftf dsa ftf dsa ftf dsa ftf dsa ftf dsa ftf dsa ftf',LF
db 'tuj top tuj top tuj top tuj top tuj top tuj top tuj top tuj',LF
db 'test taft test taft test taft test taft test taft test taft',LF
db 'tas trasa tas trasa tas trasa tas trasa tas trasa tas trasa',LF
db 'topograf fotografie topograf fotografie topograf fotografie',LF
db 'hotel kotel hotel kotel hotel kotel hotel kotel hotel kotel',LF
db 'dost faktur dost faktur dost faktur dost faktur dost faktur',LF
db 'lhñta platit pokutu lhñta platit pokutu lhñta platit pokutu',LF
db 'stodeset trest stodeset trest stodeset trest stodeset trest',LF
db 'pisatel odesilatelñ pisatel odesilatelñ pisatel odesilatelñ',LF
db FF
db 'tak takto tato tuto tou touto toto toho tohoto touto tohoto',LF
db FF
db 'rñst platñ, rñst jakosti, rñst ziskñ, rñst prodeje igelitu,',LF
db 'postoupili fakturu, otiskli statistiku, zastoupili pisatele',LF
db 'zjistili pisatele dopisu, zajistili dotisk tohoto katalogu,',LF
db FF
db 'dostali dopis, dostali lhñtu, dostali pokutu, dostal trest,',LF
db 'pojistil auto, zjistili defekt, zaplatili pojistku za auto,',LF
db 'zaplatili poplatek za rozhlas, zaplatili doplatek za dehet,',LF
db 'podali protest proti hluku, dodali deset aut, dodali kotle,',LF
db 'koupil toto auto, zjistil tato fakta, platili tuto fakturu,',LF
db 'dostali deset strojñ, poslal pro sestru, zaplatili poplatek',LF
db EOT

LDatI11  label     byte
LDat111  label     byte
LDat211  label     byte
db 'ttttttttt ftftftftftftftftf ftf tft ftf tft ftf tft ftf tft',LF
db 'ftf dsa ftf dsa ftf dsa ftf dsa ftf dsa ftf dsa ftf dsa ftf',LF
db 'tuj top tuj top tuj top tuj top tuj top tuj top tuj top tuj',LF
db 'test taft test taft test taft test taft test taft test taft',LF
db 'tas trasa tas trasa tas trasa tas trasa tas trasa tas trasa',LF
db 'topograf fotografie topograf fotografie topograf fotografie',LF
db 'hotel kotel hotel kotel hotel kotel hotel kotel hotel kotel',LF
db 'dost faktur dost faktur dost faktur dost faktur dost faktur',LF
db 'data gesta sta test trest deset stres data deset test gesta',LF
db 'stodeset trest stodeset trest stodeset trest stodeset trest',LF
db 'pisatel odesilatel; pisatel odesilatel; pisatel odesilatel;',LF
db FF
db 'tak takto tato tuto tou touto toto toho tohoto touto tohoto',LF
db FF
db 'dost platu, dost jakosti, dost zisku, dost prodeje igelitu,',LF
db 'postoupili fakturu, otiskli statistiku, zastoupili pisatele',LF
db 'zjistili pisatele dopisu, zajistili dotisk tohoto katalogu,',LF
db FF
db 'dostali dopis, dostali kotel, dostali pokutu, dostal trest,',LF
db 'pojistil auto, zjistili defekt, zaplatili pojistku za auto,',LF
db 'zaplatili poplatek za rozhlas, zaplatili doplatek za dehet,',LF
db 'podali protest proti hluku, dodali deset aut, dodali kotle,',LF
db 'koupil toto auto, zjistil tato fakta, platili tuto fakturu,',LF
db 'dostali deset pokut; poslal pro sestru; zaplatili poplatek;',LF
db EOT

; ------ lekce 12 - £
;˛
LekcC12  label     byte
db '£)',LF
db LF
db 'P°smeno £ p°®eme pravòm mal°ákem, kterò vychylujeme vpravo nahoru.',LF
db LF
db 'mal°ákem pravÇ ruky  - £',LF
db LF
db 'Jde o n†roánÇ cviáen°. Aë se mal°áek unav°, opakujte si p©ede®lou lekci.',LF
db 'D†vejte pozor na spr†vnÇ vychòlen° doprava, jinak budete ps†t p°smeno p.',LF
db LF
db LF
db EOT

LDatC12  label     byte
db '£££££££££££ ñ£ñ£ñ£ñ£ñ£ñ£ñ£ñ£ñ£ñ ñ£ñ £ñ£ ñ£ñ £ñ£ ñ£ñ £ñ£ ñ£ñ',LF
db '£lñ £dñ £lñ £dñ £lñ £dñ £lñ £dñ £lñ £dñ £lñ £dñ £lñ £dñ £lñ',LF
db '£pj kl£ £pj kl£ £pj kl£ £pj kl£ £pj kl£ £pj kl£ £pj kl£ £pj',LF
db 'f£k d£k f£k d£k f£k d£k f£k d£k f£k d£k f£k d£k f£k d£k f£k',LF
db '£kaz £loha £kaz £loha £kaz £loha £kaz £loha £kaz £loha £kaz',LF
db '£kolñ £dajñ £kolñ £dajñ £kolñ £dajñ £kolñ £dajñ £kolñ £dajñ',LF
db '£hlu £derñ £hlu £derñ £hlu £derñ £hlu £derñ £hlu £derñ £hlu',LF
db '£roda £spor £roda £spor £roda £spor £roda £spor £roda £spor',LF
db '£trata £hoz £trata £hoz £trata £hoz £trata £hoz £trata £hoz',LF
db FF
db 'dostali sto £kolñ, je to £der, rozprodali £rodu, psal £pis,',LF
db FF
db '£hrada dluhu, £daje o kursu, £daje o skladu, t£ra k jezeru,',LF
db 'sklidili £rodu, dostali £rok, dostali £lohu, odrazili £der,',LF
db 'zapsali £daje do tohoto tiskopisu, rozprodali £rodu okurek,',LF
db FF
db 'sepsali protokol o £razu, zapsali si £tratu, podepsal £pis,',LF
db 'dostal za £kol zakreslit £hel dopadu, zajistil £sporu tukñ,',LF
db 'zjistili £daje pro statistiku, zaslali £hradu tohoto dluhu,',LF
db 'rozhodl se pro t£ru do hor, zjistil £daje o odletu letadla,',LF
db 'propagujete £sporu oleje, urgujete £hradu dluhu za traktor,',LF
db FF
db 'hrozil ohrozil zkazil pokazil dorazil porazil urazil srazil',LF
db 'ohrozili shodu, hrozil hlad, prorazili sklo, zkazili pokus,',LF
db 'zapsali se zde do kursu, zaslali dopis, zajeli zase k lesu,',LF
db 'rozepsal hru, rozlepil dopis, rozprodal sklo, rozoral pole,',LF
db 'razili heslo, porazili hloh, kladli dñraz, prorazili desku,',LF
db 'zaslali do skladu papriku, koupili kari, rozprodali fazole,',LF
db 'dodatek doplatek dostatek zñstatek statek doplatek poplatek',LF
db 'doplatek za kotel, dodatek k posudku, zñstatek tohoto dluhu',LF
db 'dosahujete usilujete, postupujete, propagujete prosazujete,',LF
db 'tato politika, tato statistika, tato taktika, tato kritika,',LF
db 'soupis poplatkñ, efekt prodeje, sto wattñ, dostatek dñkazñ,',LF
db 'zaplatili za telegraf, doplatili za fotografie a fotokopie,',LF
db 'traktorista zajel ke statku, proplatili fakturu za traktor,',LF
db 'rozhodli se pro koupi traktoru, rozhodli se podle katalogu,',LF
db '£hrada dluhñ, £kol politika, £kol kritika, £kol statistika,',LF
db 'zaplatili jste £rok, tohoto £kolu se zhostil pilot letadla,',LF
db 'zdroj £spor, drez£ra psñ, £sek lesñ, sto £hozñ, £raz lokte,',LF
db '£daje o stroji zapsali do prñkazu, zajistili £sporu strojñ,',LF
db '£sudek geologa, £kol filozofa, sjezd filologñ, £kol pilota,',LF
db 'souhlasili s £sporou petroleje, odeslali £hradu za posudek,',LF
db 'zaplatili za pedik£ru, podepsal rozpis £kolñ, koupil kotel,',LF
db 'dodali dostatek traktorñ, porota rozhodla o trestu pokutou,',LF
db 'prodej tapet stoupl, rozhodli se pro postup touto taktikou,',LF
db 'kokos a datle dodejte do listopadu, jakost asfaltu stoupla,',LF
db 'zaplatili poplatek za telegraf, zajistili dotisk tiskopisñ,',LF
db 'dostal propustku, dostal dekret, auto se dostalo do kolize,',LF
db 'dosahujete £spor lakñ, kupujete stroje, usilujete o dohodu,',LF
db 'pojistili se proti £razu, £daje zjistili z tohoto katalogu,',LF
db 'dostali do tohoto £seku dostatek odlitkñ, zaplatili £tratu,',LF
db 'udejte, kterou fakturu jste proplatili, dodejte fotografie,',LF
db EOT

ELSE

LekceD   label     byte
db LF
db LF
db LF
db '                             D E M O  verze',LF
db LF
db '                 V demonstraán° verzi programu VSEMI10',LF
db '                  je dostupnòch pouze prvn°ch 5 lekc°.',LF
db LF
db LF
db LF
db '                                        ... stisknàte libovolnou kl†vesu'
db FF
db EOT

LDatD    label     byte
db EOT

ENDIF

LekSeg1  ENDS
         END


; Makra KONTEXTu: SHIFT-F1 zvòraznànò text
;                 SHIFT-F2 kl†vesy s p©ek¢dov†n°m
;                 SHIFT-F3 nadpis
;                 SHIFT-F4 nadpis 2
;                 ALT-A  db ' ',LF

INCLUDE  DEF.ASM

LekSeg3  SEGMENT   BYTE PUBLIC

IFNDEF   DEMO

; ------ lekce 25 - †
;˛
LekcC25  label     byte
Lekc125  label     byte
Lekc225  label     byte
db '†)',LF
db LF
db 'P°smeno † p°®eme ukazov†ákem pravÇ ruky. Ukazov†áek vychylujeme m°rnà',LF
db 'vpravo vzhñru.',LF
db LF
db 'ukazov†ákem pravÇ ruky  - †',LF
db LF
db 'Pozor na spojen° n†, m†, h† a z†, doch†z° p©i nich áasto k p©eklepñm.',LF
db LF
db LF
db EOT

LekcI25  label     byte
db '†)',LF
db LF
db LF
db 'P°smeno  †  p°®eme  pomoc° tzv. mrtvÇ (prefixovÇ) kl†vesy. Mal°ákem levÇ',LF
db 'ruky  stiskneme kl†vesu á†rky `, potom stiskneme opàt mal°ákem levÇ ruky',LF
db 'p°smeno a.',LF
db LF
db LF
db LF
db LF
db EOT

LDatC25  label     byte
LDatI25  label     byte
LDat125  label     byte
LDat225  label     byte
db '††††††† j†j†j†j†j†j†j†j j†m†j†m† j†n†j†n† j†h†j†h† j†z†j†z†',LF
db 'm†j v†j n†j b†j m†j v†j n†j b†j m†j v†j n†j b†j m†j v†j n†j',LF
db 'h†j z†j n†j h†j z†j n†j h†j z†j n†j h†j z†j n†j h†j z†j n†j',LF
db 'ju†j ñlk†j ju†j ñlk†j ju†j ñlk†j ju†j ñlk†j ju†j ñlk†j ju†j',LF
db 'mal† jak† mal† jak† mal† jak† mal† jak† mal† jak† mal† jak†',LF
db 'á†ry m†ry á†ry m†ry á†ry m†ry á†ry m†ry á†ry m†ry á†ry m†ry',LF
db 'd†le m†me m†te d†le m†me m†te d†le m†me m†te d†le m†me m†te',LF
db 'r†na slab† r†na slab† r†na slab† r†na slab† r†na slab† r†na',LF
db 'z†jem z†vod n†vrh st†le st†ty pr†ce kter† velk† jasn† dobr†',LF
db 'pl†nov†n° prohlubov†n° prosazov†n° projedn†v†n° poskytov†n°',LF
db 'vl†dn° komise, z†kladn° ukazatel, zdokonalov†n°m pl†nov†n°,',LF
db 'technick† dokumentace, dobr† spolupr†ce, z†vazn† objedn†vka',LF
db 'st†l† kontrola, st†tn° podniky, zas°l†me V†m, St†tn° banka.',LF
db FF
db 'zhodnocov†n° pl†n m†me st†tn° m†te pl†nov†n° áesk† skuteán†',LF
db 'V†s d†le z†vody mezin†rodn°ho kter† pr†ce org†ny objedn†vka',LF
db 'V†m n†s n†rodn° mezin†rodn°ho st†le n†vrhy zas°l†me dod†vky',LF
db 'm† dobr† z†pis zpr†va n†klady z†jem z†silka z†klady n†roán†',LF
db FF
db 'Pros°me V†s, abyste n†m zaslal nab°dku s ud†n°m podrobnost°',LF
db 'o balen° a dodac°ch podm°nk†ch. Z†silka nebyla váas dod†na.',LF
db 'Odvol†v†me se na jedn†n° z listopadu. Pros°me o zpr†vu, zda',LF
db 'm†me d†le poá°tat s objedn†vkou. Z†sady pro uzav°r†n° smluv',LF
db 'V†m zas°l†me. Banka posoudila finanán° pl†n a odeslala svñj',LF
db 'pl†n. N†vrh pl†nu pr†ce je zpracov†n a nyn° je projedn†v†n.',LF
db EOT

; ------ lekce 26 - ©
;˛
LekcC26  label     byte
Lekc126  label     byte
Lekc226  label     byte
db '©)',LF
db LF
db 'P°smeno © p°®eme ukazov†ákem levÇ ruky. Ukazov†áek vychylujeme kolmo',LF
db 'vzhñru.',LF
db LF
db 'ukazov†ákem levÇ ruky  - ©',LF
db LF
db 'D†vejte si pozor na áast† hmatov† spojen° v©, b© a t©.',LF
db LF
db LF
db EOT

LekcI26  label     byte
db '©)',LF
db LF
db LF
db 'P°smeno  ©  p°®eme  pomoc° tzv. mrtvÇ (prefixovÇ) kl†vesy. Mal°ákem levÇ',LF
db 'ruky  stiskneme  kl†vesu  á†rky `, potom stiskneme ukazov†ákem levÇ ruky',LF
db 'p°smeno r.',LF
db LF
db LF
db LF
db LF
db EOT

LDatC26  label     byte
LDatI26  label     byte
LDat126  label     byte
LDat226  label     byte
db '©©©©©©©© f©f©f©f©ff©f©f v©f©v©f© b©f©b©f© g©f©g©f© t©f©t©f©',LF
db 'fr©f asd©f fr©f asd©f fr©f asd©f fr©f asd©f fr©f asd©f fr©f',LF
db '©fa ©f† ©fe ©f° ©fa ©f† ©fe ©f° ©fa ©f† ©fe ©f° ©fa ©f† ©fe',LF
db 'p©es b©eh p©es b©eh p©es b©eh p©es b©eh p©es b©eh p©es b©eh',LF
db 'po©ad ©†dek po©ad ©†dek po©ad ©†dek po©ad ©†dek po©ad ©†dek',LF
db 'h©ib k©ik h©ib k©ik h©ib k©ik h©ib k©ik h©ib k©ik h©ib k©ik',LF
db 'sada© p©esad° ke© sada© p©esad° ke© sada© p©esad° ke© sada©',LF
db '©°jen p©°mo ©°jen p©°mo ©°jen p©°mo ©°jen p©°mo ©°jen p©°mo',LF
db 'dob©e t©eba st©ed ©°jen p©°mo d©evo t©et° p©ece ©°dit ©†dek',LF
db 'p©ikl†d†me p©edkl†d†me p©ikl†d†te p©edkl†d†te p©edpokl†d†me',LF
db FF
db 'p©i p©edem vnit©n° prost©edky opat©en° vytvo©it p©edpoklady',LF
db 'p©°mo ©°zen° p©°lohy £st©edn° d©°ve t©eba pot©eby mimo©†dn†',LF
db '©editel za©°zen° hospod†©stv° dob©e p©itom ve©ejn† p©eprava',LF
db 'mimo©†dn† pozornost, hospod†©sk† spolupr†ce, vnit©n° pokyny',LF
db 'soubory opat©en°, proto je t©eba, vytv†©eli p©itom prostor.',LF
db FF
db 'Potvrzen° objedn†vky jsme nemohli zaslat d©°ve, nejd©°ve je',LF
db 'pot©eba up©esnit platebn° podm°nky. Seznam opat©en° zas°l†m',LF
db 'p©esto v p©°loze. R†di V†m p©iprav°me pot©ebnou dokumentaci',LF
db 'pro zahranián°ho z†kazn°ka. Dob©e regulujeme spot©ebu plynu',LF
db 'a elekt©iny. Zahranián° investián° prost©edky nen° pot©eba.',LF
db 'Jsme p©ipraveni rychle zajistit p©epravu z†silek p©es mo©e.',LF
db 'Program rozvoje vnit©n° struktury byl p©ebudov†n. Rozhodnu-',LF
db 't° je st©edem z†jmu spot©ebitelñ. P©ijat† opat©en° p©edali.',LF
db EOT

; ------ lekce 27 - Ç
;˛
LekcC27  label     byte
Lekc127  label     byte
Lekc227  label     byte
db 'Ç)',LF
db LF
db 'P°smeno Ç p°®eme prsten°kem pravÇ ruky.',LF
db LF
db 'prsten°kem pravÇ ruky  - Ç',LF
db LF
db 'Toto p°smeno je hmatovà velmi obt°ënÇ. Ukazov†áek slouë° jako opàrnò bod',LF
db 'na kl†vesnici, proto mus° zñstat v z†kladn° poloze!',LF
db LF
db LF
db EOT

LekcI27  label     byte
db 'Ç)',LF
db LF
db LF
db 'P°smeno  Ç  p°®eme  pomoc° tzv. mrtvÇ (prefixovÇ) kl†vesy. Mal°ákem levÇ',LF
db 'ruky  stiskneme kl†vesu á†rky `, potom stiskneme prost©edn°kem levÇ ruky',LF
db 'p°smeno e.',LF
db LF
db LF
db LF
db LF
db EOT

LDatC27  label     byte
LDatI27  label     byte
LDat127  label     byte
LDat227  label     byte
db 'ÇÇÇÇÇÇÇÇÇ lÇlÇlÇlÇlÇlÇl kÇlÇkÇlÇ ñÇlÇñÇlÇ jÇlÇjÇlÇ .lÇl.lÇl',LF
db 'loÇl jklÇñ loÇl jklÇñ loÇl jklÇñ loÇl jklÇñ loÇl jklÇñ loÇl',LF
db 'mÇl zÇl nÇl hÇl mÇl zÇl nÇl hÇl mÇl zÇl nÇl hÇl mÇl zÇl nÇl',LF
db 'lÇky lÇpe lÇky lÇpe lÇky lÇpe lÇky lÇpe lÇky lÇpe lÇky lÇpe',LF
db 'dÇle relÇ dÇle relÇ dÇle relÇ dÇle relÇ dÇle relÇ dÇle relÇ',LF
db 'takÇ malÇ takÇ malÇ takÇ malÇ takÇ malÇ takÇ malÇ takÇ malÇ',LF
db 'novÇ starÇ novÇ starÇ novÇ starÇ novÇ starÇ novÇ starÇ novÇ',LF
db 'velkÇ pilnÇ silnÇ mladÇ starÇ dobrÇ kterÇ modrÇ áeskÇ st†lÇ',LF
db 'kvalifikovanÇ £daje, pouhÇ áty©i celÇ, vysokÇ n†roky, jakÇ,',LF
db 'lesklÇ cetky, n†roánÇ £koly, Mozart byl gÇnius, plochÇ sklo',LF
db FF
db 'celÇ pl†novitÇ áeskÇ americkÇ lÇpe prñmyslovÇ hodnotnÇ malÇ',LF
db 'takÇ spr†vnÇ zejmÇna stejnÇho odborovÇ podnikovÇ technickÇm',LF
db 'pÇáe znaánÇ pot©ebnÇ zbyteánÇ malÇ velkÇ kterÇ hospod†©skÇm',LF
db 'jakÇ jednotnÇ problÇm áasovÇm krajskÇm dlouhodobÇm £áelnÇho',LF
db FF
db 'V p©°loze V†m takÇ zas°l†me vypracovanÇ a schv†lenÇ pokyny.',LF
db 'NovÇ ceny budou platit od z†©° t. r., polotovary dod†me jen',LF
db 'v tÇto cenovÇ kategorii. V p©°loze zas°l†m upravovanÇ tech-',LF
db 'nickÇ dokumenty. Pl†n pravidelnÇho z†sobov†n° prodejen jsme',LF
db 'p©epracovali podle V†mi udanÇho novÇho p©epravn°ho systÇmu.',LF
db EOT

; ------ lekce 28 - ®
;˛
LekcC28  label     byte
Lekc128  label     byte
Lekc228  label     byte
db '®)',LF
db LF
db 'P°smeno ® p°®eme prsten°kem levÇ ruky.',LF
db LF
db 'prsten°kem levÇ ruky  - ®',LF
db LF
db 'Toto p°smeno je hmatovà velmi obt°ënÇ. Ukazov†áek slouë° jako opàrnò bod',LF
db 'na kl†vesnici, proto mus° zñstat v z†kladn° poloze!',LF
db LF
db LF
db EOT

LekcI28  label     byte
db '®)',LF
db LF
db LF
db 'P°smeno  ®  p°®eme  pomoc° tzv. mrtvÇ (prefixovÇ) kl†vesy. Mal°ákem levÇ',LF
db 'ruky  stiskneme  kl†vesu  á†rky  `, potom stiskneme prsten°kem levÇ ruky',LF
db 'p°smeno s.',LF
db LF
db LF
db LF
db LF
db EOT

LDatC28  label     byte
LDatI28  label     byte
LDat128  label     byte
LDat228  label     byte
db '®®®®®®®® s®s®s®s®s®s®s a®s®a®s® d®s®d®s® f®s®f®s® sxs®sxs®s',LF
db 'sw® dw® sw® dw® sw® dw® sw® dw® sw® dw® sw® dw® sw® dw® sw®',LF
db 'sw®s fd®sa sw®s fd®sa sw®s fd®sa sw®s fd®sa sw®s fd®sa sw®s',LF
db 'su®e su®° su®e su®° su®e su®° su®e su®° su®e su®° su®e su®°',LF
db '®sa ®si ®se ®s° ®sa ®si ®se ®s° ®sa ®si ®se ®s° ®sa ®si ®se',LF
db 'v†® va® v†® va® v†® va® v†® va® v†® va® v†® va® v†® va® v†®',LF
db '®at ®epot ®at ®epot ®at ®epot ®at ®epot ®at ®epot ®at ®epot',LF
db '®°p ®ik ®°p ®ik ®°p ®ik ®°p ®ik ®°p ®ik ®°p ®ik ®°p ®ik ®°p',LF
db 'lep®° dal®° hor®° lep®° dal®° hor®° lep®° dal®° hor®° lep®°',LF
db '®l†pota ka®tan ®paleta ®nek ®molka ®otek ®koda v®echno ®peh',LF
db 'V®eobecnÇ podm°nky, Va®e zpr†va, v p©°®t°m roce, dal®° rok,',LF
db 'na®e hospod†©stv°, zlep®en°m situace, V†® dopis, p©edev®°m,',LF
db '©e®en° problÇmñ, zvl†®tn° proveden°, reklamovanÇ po®kozen°.',LF
db FF
db 'n†® na®° na®emu na®eho na®ich av®ak dal®° do®la ®kola po®ta',LF
db 'V†® Va®° Va®emu Va®eho Va®ich p©edev®°m p©°slu®nÇ zvy®ov†n°',LF
db 'v®ak p©°®t° v®ichni v®eobecnÇ ov®em dne®n° za®leme nejvy®®°',LF
db FF
db 'Mus°me p©ipravit dal®° formy ©e®en°. NovÇ pokyny V†m za®le-',LF
db 'me po®tou. Reklamaci vy®et©°me a zpr†vu V†m po®leme co nej-',LF
db 'd©°ve. Podle na®ich informac° dod†v† konkurence srovnatelnÇ',LF
db 'stanice za mnohem vy®®° ceny. M†me z†jem o roz®°©en° spolu-',LF
db 'pr†ce s Va®°m podnikem. P©°®t° zpr†vu oáek†v†m koncem roku.',LF
db 'Pro p©°®t° rok p©ipravujeme zlep®en° na®ich za©°zen°. Podle',LF
db 'n†kladn°ho listu byla sice cel† z†silka odesl†na v term°nu,',LF
db 'av®ak do®la po®kozena. P©°®t° p©edn†®ku pl†nujeme v áervnu.',LF
db 'Chceme pokraáovat ve zvy®ov†n° kvality a rychlosti dopravy.',LF
db FF
db 'Investice jsou hmotnÇ a finanán° zdroje vynakl†danÇ na z©°-',LF
db 'zen° z†kladn°ch prost©edkñ a na rekonstrukce, modernizace a',LF
db 'p©°stavby a n†stavby pñvodn°ch z†kladn°ch prost©edkñ. Inve-',LF
db 'stic° jsou takÇ zdroje vynakl†danÇ na n†kup z†kladn°ch pro-',LF
db 'st©edkñ ze zahranián°ch zdrojñ. Rekonstrukce jsou z†sahy do',LF
db 'technologickÇ a konstrukán° á†sti pñvodn°ch z†kladn°ch pro-',LF
db 'st©edkñ. Opravou strojñ se obnovuje jejich á†steánÇ fyzickÇ',LF
db 'opot©eben° nebo po®kozen° za £áelem uveden° znovu do provo-',LF
db 'zu. P©itom se zpravidla modernizuj° jejich technickÇ vlast-',LF
db 'nosti, provozn° kvalita i bezpeánost a provozn° vlastnosti.',LF
db EOT

; ------ lekce 29 - à
;˛
LekcC29  label     byte
Lekc129  label     byte
Lekc229  label     byte
db 'à)',LF
db LF
db 'P°smeno à p°®eme levòm mal°ákem, kterò vychylujeme p©°mo nahoru.',LF
db LF
db 'mal°ákem levÇ ruky  - à',LF
db LF
db 'V áastòch spojen° và, bà a tà je tento pohyb velmi n†roánò.',LF
db LF
db LF
db LF
db EOT

LekcI29  label     byte
db 'à)',LF
db LF
db LF
db 'P°smeno  à  p°®eme  pomoc° tzv. mrtvÇ (prefixovÇ) kl†vesy. Mal°ákem levÇ',LF
db 'ruky  stiskneme  kl†vesu  á†rky  `, potom stiskneme prsten°kem levÇ ruky',LF
db 'p°smeno w (pozor - ne tedy p°smeno e, ale sousedn° p°smeno w !).',LF
db LF
db LF
db LF
db LF
db EOT

LDatC29  label     byte
LDatI29  label     byte
LDat129  label     byte
LDat229  label     byte
db 'ààààààààà aàaàaàaàaàaàa sàaàsàaà dàaàdàaà fàaàfàaà xàaàxàaà',LF
db 'aqàfa fdsàa aqàfa fdsàa aqàfa fdsàa aqàfa fdsàa aqàfa fdsàa',LF
db 'vàda vàta vàda vàta vàda vàta vàda vàta vàda vàta vàda vàta',LF
db 'sedà vàdà sedà vàdà sedà vàdà sedà vàdà sedà vàdà sedà vàdà',LF
db 'dàd bàh dàd bàh dàd bàh dàd bàh dàd bàh dàd bàh dàd bàh dàd',LF
db 'stàna ®tànà stàna ®tànà stàna ®tànà stàna ®tànà stàna ®tànà',LF
db 'kotà robà kotà robà kotà robà kotà robà kotà robà kotà robà',LF
db 'kvalitnà maxim†lnà dñslednà odpovàdnà soustavnà organizaánà',LF
db 'odpovàdnàj®° kvalitnàj®° £spornàj®° aktivnàj®° dñslednàj®°m',LF
db 'p©°snà zamàstnance, je®tà lep®°, áasnà z°tra, v tomto smàru',LF
db 'odbàratelskÇ vztahy, dàlbou pr†ce, v zemàdàlstv°, tà®°me se',LF
db 'nàkterou zpr†vu, vàc° na®ich zamàstnancñ, £spà®nà zvl†dneme',LF
db FF
db 'jistà je®tà svàtà kromà màs°c dàlba dàln°ci dàln°kñ dopravà',LF
db 'dobà plnà màst aktivnà znaánà £spornà zemàdàlci zemàdàlstv°',LF
db 'odpovàdnà vàc vàda vàdy tà®°me vànujeme odpovàdnost dàln°ci',LF
db 'màli vàt®° spoleánà pl†novità zemà kromà dñslednà maxim†lnà',LF
db FF
db 'Dàkujeme V†m za informaci. V posledn° dobà je®tà stoupl po-',LF
db 'áet objedn†vek. Ve druhÇ vlnà pñjde o zmàny cen materi†lñ a',LF
db 'surovin. Provà©ili jsme peálivà celou situaci v dopravà. Na',LF
db 'z†kladà tàchto podkladñ zajist°me p©epravu z†silky. Pomàrnà',LF
db 'lep®° je nab°dka u kvalitnàj®°ch vàc°. K uskuteánàn° tàchto',LF
db 'c°lñ bude pot©eba ode v®ech vyvinout mimo©†dnà velkÇ £sil°.',LF
db FF
db 'Dàlen°m vyr†bànÇho sortimentu do d°lá°ch skupin, kterÇ jsou',LF
db 'pl†nov†ny a sledov†ny ve v®ech á†stech kalkulaán°ho vzorce,',LF
db 'jsme velmi zdokonalili n†® systÇm pl†nov†n° a vyhodnocov†n°',LF
db 'd°lá°ch ukazatelñ. Uplatnili jsme zde hmotnou zainteresova-',LF
db 'nost vedouc°ch pracovn°kñ na plnàn° sortimentu elektromàrñ.',LF
db 'T°m stoupla discipl°na p©i plnàn° prov†dàc°ho pl†nu a je®tà',LF
db 'v°ce se prohloubila vz†jemn† spolupr†ce mezi £seky provozu.',LF
db 'Dnes r†no se uskuteánila porada vedouc°ch pracovn°kñ na®eho',LF
db 'podniku k plnàn° roán°ho pl†nu. Zpr†vu o hospoda©en° a takÇ',LF
db 'zpr†vu o plnàn° pl†nu za pololet° p©ednesl ©editel podniku.',LF
db 'Zpr†vu ©editele doplnil hlavn° technik. Ve svÇ roán° zpr†và',LF
db 'upozornil na problÇmy se zav†dàn°m novÇho zpñsobu obr†bàn°.',LF
db FF
db 'Obrac°me se na V†s s prosbou, abyste ihned zlep®ili kvalitu',LF
db 'balen° p©°strojñ zejmÇna do zahraniá°. P©i kontrole, kterou',LF
db 'jsme v minulÇm roce prov†dàli ve Va®ich skladech, jsme takÇ',LF
db 'na tuto skuteánost upozornili. Va®i pracovn°ci nedostateánà',LF
db 'plnili bedny d©evitou vlnou. Doch†z° tak k po®kozov†n° p©°-',LF
db 'strojñ. Ani dal®° ochrana materi†lu neodpov°dala n†roánosti',LF
db 'p©epravy p©°strojñ. Bedny nemaj° p©edepsanou s°lu prken ani',LF
db 'nejsou zaji®tàny proti po®kozen° p©i nakl†d†n° a vykl†d†n°.',LF
db EOT

; ------ lekce 30 - ò
;˛
LekcC30  label     byte
Lekc130  label     byte
Lekc230  label     byte
db 'ò)',LF
db LF
db 'P°smeno ò p°®eme pravòm ukazov†ákem, kterò vychylujeme vlevo nahoru.',LF
db LF
db 'ukazov†ákem pravÇ ruky  - ò',LF
db LF
db 'Uvàdomte si rozd°l mezi ò a † a dbejte, aby pravò mal°áek, kterò tvo©°',LF
db 'opàrnò bod, zñstal na svÇ kl†vese.',LF
db LF
db LF
db EOT

LekcI30  label     byte
db 'ò)',LF
db LF
db LF
db 'P°smeno  ò  p°®eme  pomoc° tzv. mrtvÇ (prefixovÇ) kl†vesy. Mal°ákem levÇ',LF
db 'ruky  stiskneme  kl†vesu á†rky `, potom stiskneme ukazov†ákem pravÇ ruky',LF
db 'p°smeno y.',LF
db LF
db LF
db LF
db LF
db EOT

LDatC30  label     byte
LDatI30  label     byte
LDat130  label     byte
LDat230  label     byte
db 'òòòòòòòòò jòjòjòjòjòj jòj†jòj† nòjònòjò hòjòhòjò yòjòjyòjòj',LF
db 'juòj ñlkòj juòj ñlkòj juòj ñlkòj juòj ñlkòj juòj ñlkòj juòj',LF
db 'nòch kòch pòch hòch nòch kòch pòch hòch nòch kòch pòch hòch',LF
db 'ròch dòch tòch vòch ròch dòch tòch vòch ròch dòch tòch vòch',LF
db 'sòáek dòmka sòáek dòmka sòáek dòmka sòáek dòmka sòáek dòmka',LF
db 'jakò jinò jakò jinò jakò jinò jakò jinò jakò jinò jakò jinò',LF
db 'st†lò jasnò pevnò nutnò m°rnò dobrò kalnò vadnò velkò áeskò',LF
db 'vòrobn° celkovò pilnò vàdeckò p°semnò zemàdàlskò st†lò milò',LF
db 'slabò stò pouhò dlouhò tuhò vòznamnò vòhradn° vyzòvavò vòti',LF
db 'vòznamnÇ jubileum, sòrovò chleb°áek, sudò tòden, chorò dàd,',LF
db FF
db 'jinòm pevnò celkovò podnikovò kterò kteròch krajskò n†roánò',LF
db 'vòbornò vòroba vòrobn° vòstava vò®e stejnò vòsledky vòkonnò',LF
db 'celò novò jakò áeskò vòznamnò hospod†©skò pl†novanò n†roánò',LF
db FF
db 'Rozhoduj°c° pro posouzen° jakosti vòrobku bude analòza pro-',LF
db 'veden† na z†kladà vzorku. Realizovali jsme vòsledky vòzkumu',LF
db 'a vòvoje. Jde o velmi n†roánò, nalÇhavò ale takÇ neodkladnò',LF
db '£kol. Nezbytn† bude vz†jemn† spolupr†ce mezi dodavatelskòmi',LF
db 'a odbàratelskòmi organizacemi. Poá†tek z†ruán° doby vòrobku',LF
db 'je uráen datem vòroby vyznaáenòm na nàm, dÇlka je pñl roku.',LF
db EOT

; ------ lekce 31 - ë
;˛
LekcC31  label     byte
Lekc131  label     byte
Lekc231  label     byte
db 'ë)',LF
db LF
db 'P°smeno ë p°®eme levòm ukazov†ákem, kterò vychylujeme vpravo nahoru.',LF
db LF
db 'ukazov†ákem levÇ ruky  - ë',LF
db LF
db 'Uvàdomte si rozd°l mezi ë a © a dbejte, aby levò mal°áek, kterò tvo©°',LF
db 'opàrnò bod, zñstal na svÇ kl†vese.',LF
db LF
db LF
db EOT

LekcI31  label     byte
db 'ë)',LF
db LF
db LF
db 'P°smeno  ë  p°®eme  pomoc° tzv. mrtvÇ (prefixovÇ) kl†vesy. Mal°ákem levÇ',LF
db 'ruky  stiskneme kl†vesu á†rky `, potom stiskneme opàt mal°ákem levÇ ruky',LF
db 'p°smeno z.',LF
db LF
db LF
db LF
db LF
db EOT

LDatC31  label     byte
LDatI31  label     byte
LDat131  label     byte
LDat231  label     byte
db 'ëëëëëëëë fëfëfëfëfëf fëf©fëf©fëf© dëfëdëfë sëfësëfë cëfëcëf',LF
db 'ftëf asdëf ftëf asdëf ftëf asdëf ftëf asdëf ftëf asdëf ftëf',LF
db 'ëfÇ ëfn ëf° ëfò ëfÇ ëfn ëf° ëfò ëfÇ ëfn ëf° ëfò ëfÇ ëfn ëf°',LF
db 'ëfe ëfd ëfs ëfd ëfe ëfd ëfs ëfd ëfe ëfd ëfs ëfd ëfe ëfd ëfs',LF
db 'ëal ëel ëal ëel ëal ëel ëal ëel ëal ëel ëal ëel ëal ëel ëal',LF
db 'ë°nà ë†d† ë°nà ë†d† ë°nà ë†d† ë°nà ë†d† ë°nà ë†d† ë°nà ë†d†',LF
db 'jehoë kaëd† jehoë kaëd† jehoë kaëd† jehoë kaëd† jehoë kaëd†',LF
db 'ë†danÇ mnoëstv° zboë°, ëivoái®nou vòrobu, poëadovanÇ sluëby',LF
db 'vòrobn°m druëstvu, tàëkò prñmysl, moënostem vòroby, protoëe',LF
db 'kaëdÇ ë†dosti, ëeleznián° dopravou, s p©†telskòm pozdravem.',LF
db FF
db 'ëe vëdy zboë° kaëdou povaëuj° jië mñëe moënosti n†leëitosti',LF
db 'ë†dnò ë†d†me ëadatel mnoëstv° muëi ëeny ml†deë soutàë tàëba',LF
db 'jakoë nòbrë ëivotn° poëadavky druëstevn° sluëby pokaëdÇ tÇë',LF
db 'kdy jehoë vyuë°v†me nemñëeme moën† koëich poë°vat kñëe jenë',LF
db FF
db 'Va®i zpr†vu jsme obdrëeli p©°li® opoëdànà, tak jië nemñëeme',LF
db 'vyhovàt Va®emu poëadavku. Zjistili jsme, ëe k ë†dnÇmu omylu',LF
db 'nedo®lo. K z†leëitostem se vr†t°me, jakmile obdrë°me od V†s',LF
db 'blië®° £daje. Litujeme, ëe V†m nemñëeme d†t okamëitou zpr†-',LF
db 'vu o moënostech vòroby. PoëadovanÇ zboë° V†m nemñëeme ihned',LF
db 'odeslat. Povolen° k poskytov†n° sluëeb jië nen° vyëadov†no.',LF
db FF
db 'Pro dosaëen° stanovenòch c°lñ m†me jië v®echny p©edpoklady.',LF
db 'Rozhoduj°c° bude, jak dok†ëeme vyuë°t v®ech moënost°. Plat°',LF
db 'totië, ëe chceme-li obst†t v soutàëi se svàtem, mus°me v°ce',LF
db 'zn†t a lÇpe pracovat. S obt°ënost° a mnoëstv°m £kolñ rostou',LF
db 'i poëadavky na vedouc° pracovn°ky. PlacenÇ sluëby p©izpñso-',LF
db 'bujeme poëadavkñm z†kazn°kñ pro uspokojen° v®ech poëadavkñ.',LF
db EOT

; ------ lekce 32 - Éü§
;˛
LekcC32  label     byte
Lekc232  label     byte
db 'Éü§)',LF
db 'Na  á°selnÇ  ©adà  je  um°stàna  kl†vesa  á†rky  a  h†áku,  kter†  m† tu',LF
db 'vlastnost,  ëe  po  jej°m  stisku  se kurzor neposune. Proto je nazòv†na',LF
db 'mrtvou  kl†vesou.  Tato  kl†vesa se pouë°v† k psan° p°smen s á†rkou nebo',LF
db 'h†ákem, kter† nejsou k dispozici na kl†vesnici p©°mo (jako nap©. p°smena',LF
db 'É ü § a v®echna velk† p°smena s h†áky a á†rkami).',LF
db 'P©i  psan°  malòch p°smen s h†ákem stiskneme a drë°me mal°ákem levÇ ruky',LF
db 'levou kl†vesu SHIFT a potom mal°ákem pravÇ ruky stiskneme h†áek. Pust°me',LF
db 'kl†vesu SHIFT a stiskneme kl†vesu s poëadovanòm malòm p°smenem.',LF
db LF
db EOT

LekcI32  label     byte
Lekc132  label     byte
db 'Éü§)',LF
db LF
db 'Tzv.  mrtv†  kl†vesa  (jinak tÇë prefixov† kl†vesa) ` se pouë°v† k psan°',LF
db 'p°smen  s  á†rkou  nebo  h†ákem,  kter† nejsou k dispozici na kl†vesnici',LF
db 'p©°mo (jako jsou p°smena Éü§ a v®echna velk† p°smena s h†áky a á†rkami).',LF
db LF
db 'P©i  psan° malòch p°smen Éü§ stiskneme mal°ákem levÇ ruky kl†vesu zpàtnÇ',LF
db 'á†rky ` a potom stiskneme kl†vesu s poëadovanòm p°smenem DTN.',LF
db LF
db LF
db EOT

LDatC32  label     byte
LDatI32  label     byte
LDat132  label     byte
LDat232  label     byte
db 'Éü§ Éü§ Éü§ Éu üu §u Éu üu §u §uj Éñt Éñm üuk É†p §uf üu§üa',LF
db 'zeÉ màÉ zeÉ màÉ zeÉ màÉ zeÉ màÉ zeÉ màÉ zeÉ màÉ zeÉ màÉ zeÉ',LF
db 'drü suü drü suü drü suü drü suü drü suü drü suü drü suü drü',LF
db 'stupe§ z†rove§ stupe§ z†rove§ stupe§ z†rove§ stupe§ z†rove§',LF
db 's°ü huü traü uhraÉte uáili®ü l†ze§sk† poji®üovna zji®üujeme',LF
db 'up©es§ov†n° pl†nñ, neust†le zdñraz§ujeme, upev§ov†n° svazku',LF
db 'v lo§skÇm roce, ëivotn° £rove§, neboü chce®, pracovn° k†ze§',LF
db 'takÇ pracovi®ü, neboü odpovàÉ poji®üovny, odbornòch uáili®ü',LF
db 'zkvalit§ov†n° pr†ce, odmà§ov†n° pracovn°kñ, zvl†®ü dñleëitÇ',LF
db 'telefonn° s°ü, sklize§ brambor, ihned proveÉte, neboü nechü',LF
db FF
db 'zvl†®ü £rove§ alespo§ sklize§ s°ü neboü vëdyü buÉte odpovàÉ',LF
db 'da§ traü lo§skò zkvalit§ov†n° k†ze§ stupe§ kampa§ spl§ujeme',LF
db FF
db 'OdpovàÉ V†m za®lu do tòdne. Upozor§ujeme na st†le velkò po-',LF
db 'áet rizikovòch pracovi®ü. Na dokonalÇm ©°zen° z†vis° £rove§',LF
db 'pr†ce. Vyëaduje to vànovat se zkvalit§ov†n° a zefektiv§ov†-',LF
db 'n° pr†ce. Nep©ipusüme, aby se p©i up©es§ov†n° pl†nu objevil',LF
db 'nedostatek z lo§skÇho roku. Uji®üujeme, ëe z†soba je n°zk†.',LF
db EOT

; ------ lekce 33 - ûÜõÖÄí•â
;˛
LekcC33  label     byte
db 'âûÜí¶õÖÄ•)',LF
db 'P©i  psan°  velkòch  p°smen  s  h†ákem v pravÇ polovinà kl†vesnice (í¶•)',LF
db 'stiskneme  a  drë°me levòm mal°ákem levou kl†vesu SHIFT, pravòm mal°ákem',LF
db 'stiskneme  h†áek,  p©°slu®nòm  prstem  pravÇ  ruky  stiskneme poëadovanÇ',LF
db 'p°smeno,  a teprve potÇ uvoln°me kl†vesu SHIFT a navr†t°me mal°áek zpàt.',LF
db 'P°smeno  ¶ p°®eme takÇ t°mto zpñsobem - jako bychom psali nad n°m h†áek.',LF
db 'P©i  psan°  velkòch  p°smen s h†ákem v levÇ polovinà kl†vesnice (âûÜõÖÄ)',LF
db 'postupujeme  obdobnà, av®ak po stisku h†áku uvoln°me levou kl†vesu SHIFT',LF
db 'a stiskneme a drë°me pravòm mal°ákem pravou kl†vesu SHIFT.',LF
db LF
db EOT

Lekc233  label     byte
db 'âûÜ¶õÖíÄ•)',LF
db 'P©i  psan°  velkòch  p°smen s h†ákem v pravÇ polovinà kl†vesnice (¶ a •)',LF
db 'stiskneme  a  drë°me levòm mal°ákem levou kl†vesu SHIFT, pravòm mal°ákem',LF
db 'stiskneme  h†áek,  p©°slu®nòm  prstem  pravÇ  ruky  stiskneme poëadovanÇ',LF
db 'p°smeno,  a teprve potÇ uvoln°me kl†vesu SHIFT a navr†t°me mal°áek zpàt.',LF
db 'P°smeno  ¶ p°®eme takÇ t°mto zpñsobem - jako bychom psali nad n°m h†áek.',LF
db 'P©i  psan°  velkòch p°smen s h†ákem v levÇ polovinà kl†vesnice (âûÜõÖíÄ)',LF
db 'postupujeme  obdobnà, av®ak po stisku h†áku uvoln°me levou kl†vesu SHIFT',LF
db 'a stiskneme a drë°me pravòm mal°ákem pravou kl†vesu SHIFT.',LF
db LF
db EOT

LekcI33  label     byte
Lekc133  label     byte
db 'âûÜõ¶ÖíÄ•)',LF
db LF
db 'P©i  psan°  velkòch  p°smen  s  h†ákem  stiskneme levòm mal°ákem kl†vesu',LF
db 'zpàtnÇ  á†rky  `,  potÇ p©°slu®nòm prstem levÇ nebo pravÇ ruky stiskneme',LF
db 'poëadovanÇ p°smeno spolu s kl†vesou SHIFT. Zvl†®tn°m p©°padem je p°smeno',LF
db 'â, u kterÇho stiskneme W (nam°sto E), a p°smeno ¶, u kterÇho stiskneme J',LF
db '(nam°sto p°smene U).',LF
db LF
db LF
db LF
db EOT

LDatC33  label     byte
LDatI33  label     byte
LDat133  label     byte
LDat233  label     byte
db 'í¶• âûÜõÖÄ í¶• âûÜõÖÄ zí u¶ n• eâ rû tÜ sõ dÖ cÄ í¶íO.Ä¶ÄO.',LF
db 'íiëkov û°p õumava Ö†blice íilina õkoda Ä†slav íatec õumperk',LF
db FF
db 'ÄZ, Mõ, ÄSAD, ÄSD, ÄR, PLZE•, HORAíÖOVICE, TûEõÜ, Aõ, ÄENâK',LF
db FF
db 'ÄR, SBÄS, ÄSAV, DOPORUÄENâ, ÄSD, õKODA Plze§, VíKG Ostrava.',LF
db EOT

; ------ lekce 34 - ¢ïó
;˛
LekcC34  label     byte
Lekc234  label     byte
db '¢êóãïèù)',LF
db LF
db 'Kl†vesa  s diakritickou á†rkou ',39,' je opàt tzv. mrtv† kl†vesa. Jej° pomoc°',LF
db 'p°®eme  p°smeno ¢ a velk† p°smena s á†rkou (êóãïèù). P©i psan° p°smena ¢',LF
db 'stiskneme  pravòm  mal°ákem  kl†vesu  s  á†rkou  a potÇ stiskneme pravòm',LF
db 'prsten°kem  kl†vesu  s  p°smenem  o.  Obdobnà, s pouëit°m kl†vesy SHIFT,',LF
db 'p°®eme velk† p°smena s á†rkou (êóãïèù).',LF
db LF
db LF
db LF
db EOT

Lekc134  label     byte
LekcI34  label     byte
db '¢êùóãïè)',LF
db LF
db 'Kl†vesa  s diakritickou á†rkou ` je opàt tzv. mrtv† kl†vesa. Jej° pomoc°',LF
db 'p°®eme  p°smeno ¢ a velk† p°smena s á†rkou (êùóãïè). P©i psan° p°smena ¢',LF
db 'stiskneme  levòm  mal°ákem  kl†vesu  s  á†rkou ` a potÇ stiskneme pravòm',LF
db 'prsten°kem  kl†vesu  s  p°smenem  o.  Obdobnà, s pouëit°m kl†vesy SHIFT,',LF
db 'p°®eme velk† p°smena s á†rkou (êùóãïè).',LF
db LF
db LF
db LF
db EOT

LDatC34  label     byte
LDatI34  label     byte
LDat134  label     byte
LDat234  label     byte
db '¢êóãïèù ¢êóãïèù ¢êóãïèù ¢êóãïèù o¢ñ Eêñ Uóñ Iãñ Oïñ Aèñ Yùñ',LF
db 's¢ja m¢da s¢ja m¢da s¢ja m¢da s¢ja m¢da s¢ja m¢da s¢ja m¢da',LF
db 'ólehla, ãr†n, êra rocku, èmos, óst° na Labem, ïda na radost',LF
db FF
db 'Je jistà velmi obt°ënÇ posuzovat re†lnost uvedenÇ progn¢zy.',LF
db 'Vag¢ny byly dnes naloëeny. M¢dnost n†mi nab°zenÇho zboë° je',LF
db 'plnà srovnateln† s m¢dou ve svàtà. óspà®n† realizace pl†no-',LF
db 'vanòch £kolñ z†vis° na £rovni ©°dic° pr†ce. êra m¢dy jazzu.',LF
db EOT

; ------ lekce 35 - ?
;˛
LekcC35  label     byte
db '?)',LF
db LF
db 'Otazn°k  je  um°stàn  na doln° ©adà a p°®eme ho prost©edn°kem pravÇ ruky',LF
db 'za souáasnÇho stisknut° levÇ kl†vesy SHIFT levòm mal°ákem.',LF
db LF
db 'prost©edn°kem pravÇ ruky  - ?',LF
db LF
db 'V  textu  p°®eme  otazn°k tàsnà za posledn° slovo bez oddàlovac° mezery,',LF
db 'mezeru dàl†me aë za otazn°kem.',LF
db LF
db EOT

LekcI35  label     byte
Lekc135  label     byte
Lekc235  label     byte
db '?)',LF
db LF
db 'Otazn°k  je  um°stàn  na  doln°  ©adà a p°®eme ho mal°ákem pravÇ ruky za',LF
db 'souáasnÇho stisknut° levÇ kl†vesy SHIFT levòm mal°ákem.',LF
db LF
db 'mal°ákem pravÇ ruky  - ?',LF
db LF
db 'V  textu  p°®eme  otazn°k tàsnà za posledn° slovo bez oddàlovac° mezery,',LF
db 'mezeru dàl†me aë za otazn°kem.',LF
db LF
db EOT

LDatC35  label     byte
LDatI35  label     byte
LDat135  label     byte
LDat235  label     byte
db '????? k?k?k?k ,?,?,?,?, ik? ik? ik? ik? j?lñ j?lñ j?lñ j?lñ',LF
db 'Kdy? Kde? Kdo? Kdy? Kde? Kdo? Kdy? Kde? Kdo? Kdy? Kde? Kdo?',LF
db 'Jakò? Jak†? JakÇ? Jakò? Jak†? JakÇ? Jakò? Jak†? JakÇ? Jakò?',LF
db 'Jak? Jakò? Kterò? Ä°? Jak†? Kter†? Kam? Co? Kde? Kdy? Jakò?',LF
db 'Co dàl† vòzkum? V áem to je? Proá k tomu doch†z°? Co je to?',LF
db FF
db 'Ch†pe pracovn°k vòznam svòch £kolñ v podnikovÇ dàlbà pr†ce?',LF
db 'Co uáinit proto, aby i v tomto smàru nastalo zlep®en°? Jakò',LF
db 'je vztah mezi kvalifikac° lid° a £koly, kterÇ jsou jim svà-',LF
db '©ov†ny? Co je t©eba v tÇto vàci zmànit? Hled†te dobrou pra-',LF
db 'covn° p©°leëitost? S jakou perspektivou mohu u v†s poá°tat?',LF
db FF
db 'Co my v°me o jejich pr†ci, o obt°ë°ch, nesn†z°ch a rizik†ch',LF
db 'cesty nezn†mòm terÇnem za novòmi poznatky a ©e®en°mi, o vy-',LF
db 'sokÇ cenà, kter† se za nà plat°? Co takÇ v°me o vòsledc°ch,',LF
db 'k nimë áasto pracnà dospàli, kterÇ odevzd†vaj° spoleánosti?',LF
db 'Zaj°m†me se o nà vskutku tak, jak si zaslouë°? Pom†h†me jim',LF
db '£áinnà vytv†©et spr†vnÇ podm°nky k jejich pr†ci, aby vz†cnò',LF
db 'potenci†l jejich vàdom° byl vyuëit opravdu nejhospod†rnàji?',LF
db EOT

; ------ lekce 36 - !
;˛
LekcC36  label     byte
db '!)',LF
db LF
db 'Vyk©ián°k  p°®eme pravòm mal°ákem, kterò posuneme o jednu kl†vesu vpravo',LF
db 'za souáasnÇho stisku levÇ kl†vesy SHIFT levòm mal°ákem.',LF
db LF
db 'mal°ákem pravÇ ruky  - !',LF
db LF
db 'V  textu p°®eme vyk©ián°k tàsnà za posledn° slovo bez oddàlovac° mezery,',LF
db 'mezeru dàl†me aë za vyk©ián°kem.',LF
db LF
db EOT

LekcI36  label     byte
Lekc136  label     byte
Lekc236  label     byte
db '!)',LF
db LF
db 'Vyk©ián°k p°®eme levòm mal°ákem, kterò posuneme vlevo nahoru na á°selnou',LF
db '©adu kl†ves za souáasnÇho stisku pravÇ kl†vesy SHIFT pravòm mal°ákem.',LF
db LF
db 'mal°ákem levÇ ruky  - !',LF
db LF
db 'V  textu p°®eme vyk©ián°k tàsnà za posledn° slovo bez oddàlovac° mezery,',LF
db 'mezeru dàl†me aë za vyk©ián°kem.',LF
db LF
db EOT

LDatC36  label     byte
db '!!!!!! ñ!ñ!ñ!ñ! j! j! j! j! jñ! jÇ! jñ! jÇ! jñ! jÇ! jñ! jÇ!',LF
db 'dej! ber! dej! ber! dej! ber! dej! ber! dej! ber! dej! ber!',LF
db 'Pozor! Vy©e®eno! Uáte se! Nevypl§ovat! Zastav! Nep©ekl†dat!',LF
db 'Dodrëujte bezpeánostn° p©edpisy! NechoÉte tam! Dejte pozor!',LF
db 'Pi®te pozornà! Dbejte v®ech pokynñ! Zastavte se! Jdàte tam!',LF
db FF
db 'Proto se p©ijÉte i Vy uráità pod°vat! Pracuj! Studuj! Stñj!',LF
db EOT

LDatI36  label     byte
LDat136  label     byte
LDat236  label     byte
db '!!!!!! a!a!a!a! f! f! f! f! fa! fe! fr! fa! fe! fr! fa! fe!',LF
db 'dej! ber! dej! ber! dej! ber! dej! ber! dej! ber! dej! ber!',LF
db 'Pozor! Vy©e®eno! Uáte se! Nevypl§ovat! Zastav! Nep©ekl†dat!',LF
db 'Dodrëujte bezpeánostn° p©edpisy! NechoÉte tam! Dejte pozor!',LF
db 'Pi®te pozornà! Dbejte v®ech pokynñ! Zastavte se! Jdàte tam!',LF
db FF
db 'Proto se p©ijÉte i Vy uráità pod°vat! Pracuj! Studuj! Stñj!',LF
db EOT

ENDIF

LekSeg3  ENDS
         END

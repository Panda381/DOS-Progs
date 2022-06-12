
; Makra KONTEXTu: SHIFT-F1 zv˜raznˆn˜ text
;                 SHIFT-F2 kl vesy s p©ek¢dov n¡m
;                 SHIFT-F3 nadpis
;                 SHIFT-F4 nadpis 2
;                 ALT-A  db ' ',LF

INCLUDE  DEF.ASM

LekSeg2  SEGMENT   BYTE PUBLIC

IFNDEF   DEMO

; ------ lekce 13 - m
;þ
LekcC13  label     byte
LekcI12  label     byte
Lekc112  label     byte
Lekc212  label     byte
db 'm)',LF
db LF
db 'Um¡stˆte ruce do z kladn¡ polohy a nacvi‡ujte:',LF
db LF
db 'ukazov ‡kem prav‚ ruky  - m',LF
db LF
db 'P©i psan¡ p¡smene m je opˆrn˜m bodem na kl vesnici prav˜ mal¡‡ek,',LF
db 'kter˜ proto nezved me.',LF
db LF
db LF
db EOT

LDatC13  label     byte
db 'mmmmmmmmm jmjmjmjmjmjmjmjmj jmj mjm jmj mjm jmj mjm jmj mjm',LF
db 'mol mok mol mok mol mok mol mok mol mok mol mok mol mok mol',LF
db 'm–j mul m–j mul m–j mul m–j mul m–j mul m–j mul m–j mul m–j',LF
db 'mele maso mele maso mele maso mele maso mele maso mele maso',LF
db 'mzdu zamkl mzdu zamkl mzdu zamkl mzdu zamkl mzdu zamkl mzdu',LF
db 'm–j mlok zmokl m–j mlok zmokl m–j mlok zmokl m–j mlok zmokl',LF
db 'milost mladost milost mladost milost mladost milost mladost',LF
db 'forma datum forma datum forma datum forma datum forma datum',LF
db 'dopisem dotazem £kolem £dajem dopisem dotazem £kolem £dajem',LF
db 'importem zmetkem motorismem omezujeme, mezkem £kolem pojmem',LF
db FF
db 'mimo mezi omezit mzda forma firma metoda museli jsme omezit',LF
db FF
db 'dosahujeme usilujeme reklamujeme urgujeme diskutujeme jdeme',LF
db 'pr–zkum dol–, pr–zkum pozemku, program heslem, metr sametu,',LF
db 'radami £hradami £lohami metodami £hradami £sporami metodami',LF
db FF
db 'kol–m £kol–m £hoz–m pluh–m pokoj–m pojm–m £kol–m kol–m mimo',LF
db 'import importem, zmetek zmetkem, motor motorem, motorismus,',LF
db 'smete zmetek omezil program mezi dopisem, reklama pr–zkumem',LF
db 'zjistili datum odjezdu lodi, dostali program sjezdu geolog–',LF
db '£daje o motoru jsme zapsali do pr–kazu, zamezili jsme £razu',LF
db FF
db 'majitel auta zaplatil pojistku, reklamujeme sto metr– taftu',LF
db 'omezili jsme import olej– a tuk–, omezili jsme hluk motor–,',LF
db 'diskutujeme o r–stu motorismu, importujeme mosaz, usilujeme',LF
db 'o r–st jakosti motor–, dosahujeme £spor mazutu, postupujeme',LF
db 'proti zmetk–m, propagujeme tuto formu, prosazujeme reformu,',LF
db 'zajistili pr–zkum tohoto pozemku, odeslali mzdu za listopad',LF
db EOT

LDatI12  label     byte
LDat112  label     byte
LDat212  label     byte
db 'mmmmmmmmm jmjmjmjmjmjmjmjmj jmj mjm jmj mjm jmj mjm jmj mjm',LF
db 'mol mok mol mok mol mok mol mok mol mok mol mok mol mok mol',LF
db 'maj mul maj mul maj mul maj mul maj mul maj mul maj mul maj',LF
db 'mele maso mele maso mele maso mele maso mele maso mele maso',LF
db 'mzdu zamkl mzdu zamkl mzdu zamkl mzdu zamkl mzdu zamkl mzdu',LF
db 'mlok zmokl mlok zmokl mlok zmokl mlok zmokl mlok zmokl mlok',LF
db 'milost mladost milost mladost milost mladost milost mladost',LF
db 'forma datum forma datum forma datum forma datum forma datum',LF
db 'dopisem dotazem kolem dopisem dotazem kolem dopisem dotazem',LF
db 'importem zmetkem motorismem omezujeme; mezkem kolem pojmem;',LF
db FF
db 'mimo mezi omezit mzda forma firma metoda museli jsme omezit',LF
db FF
db 'dosahujeme usilujeme reklamujeme urgujeme diskutujeme jdeme',LF
db 'jel mezkem polem kolem pozemku, program heslem, metr sametu',LF
db 'radami zahradami metodami radami zahradami metodami radami;',LF
db FF
db 'kolem polem hozem; pluhem pokojem pojmem; kolem polem mimo;',LF
db 'import importem, zmetek zmetkem, motor motorem, motorismus,',LF
db 'smete zmetek omezil program mezi dopisem, reklama motorismu',LF
db 'zjistili datum odjezdu lodi, dostali program sjezdu, geolog',LF
db 'test motoru jsme zapsali do spisu, omezili jsme pole motoru',LF
db FF
db 'majitel auta zaplatil pojistku, reklamujeme litr laku taftu',LF
db 'omezili jsme import oleje a tuku, omezili jsme hluk motoru,',LF
db 'diskutujeme o zisku motorismu, importujeme mosaz, spisujeme',LF
db 'reklama jakosti motoru, dokupujeme kilo mazutu, postupujeme',LF
db 'proti programu, propagujeme tuto formu, prosazujeme reformu',LF
db 'zajistili reklamu tohoto pozemku, odeslali mzdu za listopad',LF
db EOT

; ------ lekce 14 - ZUIOPHJKLM
;þ
LekcC14  label     byte
db 'ZUIOPHJKLM)',LF
db LF
db 'V t‚to lekci se nau‡¡te ps t velk  p¡smena na prav‚ polovinˆ kl vesnice.',LF
db 'P©i  psan¡  tˆchto  p¡smen  je  nutno  stisknout  a dr‘et lev˜m mal¡‡kem',LF
db 'kl vesu  SHIFT a pot‚ stisknout p©¡slu¨nou kl vesu spr vn˜m prstem prav‚',LF
db 'ruky. Teprve a‘ po naps n¡ po‘adovan‚ho p¡smene uvolnˆte kl vesu SHIFT.',LF
db LF
db 'Tak‚  u  velk˜ch  p¡smen dodr‘ujte rytmus. Na prvn¡ dobu stisknˆte SHIFT',LF
db 'a na druhou dobu p¡smennou kl vesu.',LF
db LF
db EOT

LekcI13  label     byte
Lekc113  label     byte
Lekc213  label     byte
db 'UIOPHJKLM)',LF
db LF
db 'V t‚to lekci se nau‡¡te ps t velk  p¡smena na prav‚ polovinˆ kl vesnice.',LF
db 'P©i  psan¡  tˆchto  p¡smen  je  nutno  stisknout  a dr‘et lev˜m mal¡‡kem',LF
db 'kl vesu  SHIFT a pot‚ stisknout p©¡slu¨nou kl vesu spr vn˜m prstem prav‚',LF
db 'ruky. Teprve a‘ po naps n¡ po‘adovan‚ho p¡smene uvolnˆte kl vesu SHIFT.',LF
db LF
db 'Tak‚  u  velk˜ch  p¡smen dodr‘ujte rytmus. Na prvn¡ dobu stisknˆte SHIFT',LF
db 'a na druhou dobu p¡smennou kl vesu.',LF
db LF
db EOT

LDatC14  label     byte
db 'jZjZj jUjUj kIkIk lOlOl –P–P– jHjHj jJjJj kKkKk lLlLl jMjMj',LF
db 'Zora Zoja Zora Zoja Zora Zoja Zora Zoja Zora Zoja Zora Zoja',LF
db 'Ulrika Uher Ulrika Uher Ulrika Uher Ulrika Uher Ulrika Uher',LF
db 'Igor Iris Igor Iris Igor Iris Igor Iris Igor Iris Igor Iris',LF
db 'Ota Ola Ota Ola Ota Ola Ota Ola Ota Ola Ota Ola Ota Ola Ota',LF
db 'Petr Polak Petr Polak Petr Polak Petr Polak Petr Polak Petr',LF
db 'Hus Helga Hus Helga Hus Helga Hus Helga Hus Helga Hus Helga',LF
db 'Jarka Jitka Jarka Jitka Jarka Jitka Jarka Jitka Jarka Jitka',LF
db 'Karel Kamil Karel Kamil Karel Kamil Karel Kamil Karel Kamil',LF
db 'Lada Lola Lada Lola Lada Lola Lada Lola Lada Lola Lada Lola',LF
db 'Marek Magda Marek Magda Marek Magda Marek Magda Marek Magda',LF
db FF
db 'Zdirad Utah Ikarus Opel Paul Hamr Josef Karkulka Lego Marie',LF
db FF
db 'U sadu, Za mostem, Za parkem, U jezera, K Motolu, K motelu,',LF
db 'pojedu do Hradiska, £stup z Halle, parkuje u Plas, Jakutsko',LF
db 'letadlo z Portugalska, Lipo z Laktosu Praha, Klaus i Zitek,',LF
db FF
db 'Udali jste adresu do Kuksu, ale dopis dostal Petr Kot Praha',LF
db 'Igor a Petra jeli metrem k Hradu poslat telegram do Popradu',LF
db 'Petr Marek prodal Mazdu a koupil domek se zahradou u Kralup',LF
db FF
db 'Lipka zkoumal rozpis £kol–, Karel Pojar se zapsal do kursu,',LF
db 'dehet dodejte do Plas, asfalt dodejte do skladu do Kozojed,',LF
db 'mzdu Karla Zapletala za listopad jsme poslali do Kostomlat,',LF
db 'jeli autem do Mostaru, zaslali do tisku aktualitu z Mamaie,',LF
db EOT

LDatI13  label     byte
LDat113  label     byte
LDat213  label     byte
db 'jUjUj kIkIk lOlOl ;P;P; jHjHj jJjJj kKkKk lLlLl jMjMj UIOPH',LF
db 'Ulrika Uher Ulrika Uher Ulrika Uher Ulrika Uher Ulrika Uher',LF
db 'Igor Iris Igor Iris Igor Iris Igor Iris Igor Iris Igor Iris',LF
db 'Ota Ola Ota Ola Ota Ola Ota Ola Ota Ola Ota Ola Ota Ola Ota',LF
db 'Petr Polak Petr Polak Petr Polak Petr Polak Petr Polak Petr',LF
db 'Hus Helga Hus Helga Hus Helga Hus Helga Hus Helga Hus Helga',LF
db 'Jarka Jitka Jarka Jitka Jarka Jitka Jarka Jitka Jarka Jitka',LF
db 'Karel Kamil Karel Kamil Karel Kamil Karel Kamil Karel Kamil',LF
db 'Lada Lola Lada Lola Lada Lola Lada Lola Lada Lola Lada Lola',LF
db 'Marek Magda Marek Magda Marek Magda Marek Magda Marek Magda',LF
db FF
db 'Utah Ikarus Opel Paul Hamr Josef Karkulka Lego Marie Kamila',LF
db FF
db 'U mostu, U parku, U jezera, K Motolu, K motelu, U motorestu',LF
db 'pojedu do Hradiska, metro z Halle, parkuje u Plas, Jakutsko',LF
db 'letadlo z Portugalska, Lipo z Laktosu Praha, Klaus i Karel,',LF
db FF
db 'Udali jste adresu do Kuksu, ale dopis dostal Petr Kot Praha',LF
db 'Igor a Petra jeli metrem k Hradu poslat telegram do Popradu',LF
db 'Petr Marek prodal Mazdu a koupil domek se zahradou u Kralup',LF
db FF
db 'Lipka zkoumal rozpis kursu, Karel Pojar se zapsal do kursu,',LF
db 'dehet dodejte do Plas, asfalt dodejte do skladu do Kozojed,',LF
db 'mzdu Kamila Opletala za listopad jsme poslali do Kostomlat,',LF
db 'jeli autem do Mostaru, zaslali do tisku aktualitu z Mamaie,',LF
db EOT

; ------ lekce 15 - .
;þ
LekcC15  label     byte
LekcI14  label     byte
Lekc114  label     byte
Lekc214  label     byte
db '.)',LF
db LF
db 'Um¡stˆte ruce do z kladn¡ polohy a nacvi‡ujte:',LF
db LF
db 'prsten¡kem prav‚ ruky  - .',LF
db LF
db 'Prav˜ ukazov ‡ek tvo©¡ opˆrn˜ bod, nezvedejte ho z kl vesy. V textu',LF
db 'p¡¨eme te‡ku hned za slovem a pak dˆl me mezeru,  pokud nen sleduje',LF
db 'dal¨¡ interpunk‡n¡ znam‚nko.',LF
db LF
db EOT

LDatC15  label     byte
db '....... l.l.l.l.l.l.l.l l.l .l. l.l .l. l.l .l. l.l .l. l.l',LF
db 'l.l lku l.l lku l.l lku l.l lku l.l lku l.l lku l.l lku l.l',LF
db 'l–j. zul. l–j. zul. l–j. zul. l–j. zul. l–j. zul. l–j. zul.',LF
db 'ul. atd. apod. ul. atd. apod. ul. atd. apod. ul. atd. apod.',LF
db FF
db 'atd., aj., tj., t. r., t. m., zkr., odd., dr., pod., apod.,',LF
db FF
db 'Porto za dopis zaplatil odesilatel. Hledali pisatele listu.',LF
db 'Zajistili jsme hotel. Host odeslal z letadla radiotelegram.',LF
db 'Poslali dopis do rukou prof. Hodka. Popsali profil profese.',LF
db 'O tomto postupu rozhodl posudek prof. Jakla. Koupili kotel.',LF
db 'Komise zkoumala efekt tohoto postupu. Popsali projekt domu.',LF
db FF
db 'Podle pr–zkumu trhu zde zajistili prodej motor– a traktor–.',LF
db 'Omezujte import olej– a tuk–. Letos zahajujeme prodej masa.',LF
db 'Prodej a zisk letos zase stoupl s r–stem jakosti soustruh–.',LF
db 'Zajistili jsme program. Podepsali jsme dohodu o koupi medu.',LF
db 'Postupujeme podle programu. Urgujeme £hradu za taft a rips.',LF
db EOT

LDatI14  label     byte
LDat114  label     byte
LDat214  label     byte
db '....... l.l.l.l.l.l.l.l l.l .l. l.l .l. l.l .l. l.l .l. l.l',LF
db 'l.l lku l.l lku l.l lku l.l lku l.l lku l.l lku l.l lku l.l',LF
db 'l;j. zul. l;j. zul. l;j. zul. l;j. zul. l;j. zul. l;j. zul.',LF
db 'ul. atd. apod. ul. atd. apod. ul. atd. apod. ul. atd. apod.',LF
db FF
db 'atd., aj., tj., t. r., t. m., zkr., odd., dr., pod., apod.,',LF
db FF
db 'Porto za dopis zaplatil odesilatel. Hledali pisatele listu.',LF
db 'Pojistili jsme hotel. Host odeslal z letadla radiotelegram.',LF
db 'Poslali dopis do rukou prof. Hodka. Popsali profil profese.',LF
db 'O tomto postupu rozhodl posudek prof. Jakla. Koupili kotel.',LF
db 'Komise zkoumala efekt tohoto postupu. Popsali projekt domu.',LF
db FF
db 'Podle posudku profesora zajistili prodej motoru i traktoru.',LF
db 'Omezujte import oleje a tuku. Letos zahajujeme prodej masa.',LF
db 'Prodej a zisk letos zase stoupl, stoupla i jakost traktoru.',LF
db 'Pojistili jsme program. Podepsali jsme dohodu o koupi medu.',LF
db 'Postupujeme podle programu. Urgujeme i poplatek za projekt.',LF
db EOT

; ------ lekce 16 - .
;þ
LekcC16  label     byte
LekcI15  label     byte
Lekc115  label     byte
Lekc215  label     byte
db 'v)',LF
db LF
db 'Um¡stˆte ruce do z kladn¡ polohy a nacvi‡ujte:',LF
db LF
db 'ukazov ‡kem lev‚ ruky  - v',LF
db LF
db 'P©i psan¡ v je opˆrn˜m bodem na kl vesnici lev˜ mal¡‡ek, kter˜ proto',LF
db 'nezved me.',LF
db LF
db LF
db EOT

LDatC16  label     byte
db 'vvvvvvvvv fvfvfvfvfvfvfvfvfvfvf fvf vfv fvf vfv fvf vfv fvf',LF
db 'fvf dsa fvf dsa fvf dsa fvf dsa fvf dsa fvf dsa fvf dsa fvf',LF
db 'dav dva dav dva dav dva dav dva dav dva dav dva dav dva dav',LF
db 'sva ava sva ava sva ava sva ava sva ava sva ava sva ava sva',LF
db 'svoje dvoje svoje dvoje svoje dvoje svoje dvoje svoje dvoje',LF
db 'vrak vrata vrak vrata vrak vrata vrak vrata vrak vrata vrak',LF
db 'vedou odvoz vedou odvoz vedou odvoz vedou odvoz vedou odvoz',LF
db FF
db 'vada vrstva vrstev stav sestav sestava vede vedete var tvar',LF
db FF
db 'aktivita produktivita efektivita, kolektiv aktiv direktiva,',LF
db 'v £vodu, v projevu, v kovu, vzorek vzorku, rezerva rezervu,',LF
db 'odvoz paliva, vzorek krmiva, rezerva staviva, £prava zdiva,',LF
db FF
db 'Oprava vozu, oprava televizoru, vzorek krmiva, vzorek kovu.',LF
db 'Zajistili rezervu paliva. Klesl dovoz kov–. Opravili kotel.',LF
db 'Pro odvoz staviva rezervujte auto. Provoz vozidel sledujte.',LF
db 'Zkalili vodu odpadem. Opravu vodovodu provedli v listopadu.',LF
db FF
db 'Opravujeme soustruh upravujeme vozovku dopravujeme staviva.',LF
db 'Provedl £pravu, zavedli vodovod, uvedl d–vod, odvedli vodu.',LF
db 'Usilujte o efektivitu stroj–, postupujte proti zmetkovosti.',LF
db 'Zavedu £sporu paliva. Provedli jsme velikou £pravu vozovek.',LF
db 'Pivo z pivovaru vozil vozka. Zavedli do vsi vodu od potoka.',LF
db EOT

LDatI15  label     byte
LDat115  label     byte
LDat215  label     byte
db 'vvvvvvvvv fvfvfvfvfvfvfvfvfvfvf fvf vfv fvf vfv fvf vfv fvf',LF
db 'fvf dsa fvf dsa fvf dsa fvf dsa fvf dsa fvf dsa fvf dsa fvf',LF
db 'dav dva dav dva dav dva dav dva dav dva dav dva dav dva dav',LF
db 'sva ava sva ava sva ava sva ava sva ava sva ava sva ava sva',LF
db 'svoje dvoje svoje dvoje svoje dvoje svoje dvoje svoje dvoje',LF
db 'vrak vrata vrak vrata vrak vrata vrak vrata vrak vrata vrak',LF
db 'vedou odvoz vedou odvoz vedou odvoz vedou odvoz vedou odvoz',LF
db FF
db 'vada vrstva vrstev stav sestav sestava vede vedete var tvar',LF
db FF
db 'aktivita produktivita efektivita, kolektiv aktiv direktiva,',LF
db 've vozu, v projevu, v kovu, vzorek vzorku, rezerva rezervu,',LF
db 'odvoz paliva, vzorek krmiva, rezerva staviva, oprava zdiva,',LF
db FF
db 'Oprava vozu, oprava televizoru, vzorek krmiva, vzorek kovu.',LF
db 'Pojistili rezervu paliva. Klesl dovoz kovu. Opravili kotel.',LF
db 'Pro odvoz staviva rezervujte auto. Provoz vozidel sledujte.',LF
db 'Odvedli vodu odpadem. Opravu vodovodu provedli v listopadu.',LF
db FF
db 'Opravujeme soustruh upravujeme vozovku dopravujeme staviva.',LF
db 'Provedl opravu, zavedli vodovod, zavedl svod, odvedli vodu.',LF
db 'Usilujte o efektivitu stroje, postupujte proti zmetkovosti.',LF
db 'Podal doklad o krmivu. Provedl jsme velikou opravu vozovek.',LF
db 'Pivo z pivovaru vozil vozka. Upravili ve vsi vodu z potoka.',LF
db EOT

; ------ lekce 17 - TREWQGFDSAV
;þ
LekcC17  label     byte
db 'QWERTASDFGV)',LF
db LF
db 'V  t‚to lekci se nau‡¡te ps t velk  p¡smena na lev‚ polovinˆ kl vesnice.',LF
db 'P©i  psan¡  tˆchto  p¡smen  je  nutno  stisknout a dr‘et prav˜m mal¡‡kem',LF
db 'kl vesu  SHIFT  a pot‚ stisknout p©¡slu¨nou kl vesu spr vn˜m prstem lev‚',LF
db 'ruky. Teprve a‘ po naps n¡ po‘adovan‚ho p¡smene uvolnˆte kl vesu SHIFT.',LF
db LF
db 'Nezapome¤te  na  rytmus.  Na prvn¡ dobu stisknˆte SHIFT a na druhou dobu',LF
db 'p¡smennou kl vesu.',LF
db LF
db EOT

LekcI16  label     byte
Lekc116  label     byte
Lekc216  label     byte
db 'QWERTASDFGZV)',LF
db LF
db 'V  t‚to lekci se nau‡¡te ps t velk  p¡smena na lev‚ polovinˆ kl vesnice.',LF
db 'P©i  psan¡  tˆchto  p¡smen  je  nutno  stisknout a dr‘et prav˜m mal¡‡kem',LF
db 'kl vesu  SHIFT  a pot‚ stisknout p©¡slu¨nou kl vesu spr vn˜m prstem lev‚',LF
db 'ruky. Teprve a‘ po naps n¡ po‘adovan‚ho p¡smene uvolnˆte kl vesu SHIFT.',LF
db LF
db 'Nezapome¤te  na  rytmus.  Na prvn¡ dobu stisknˆte SHIFT a na druhou dobu',LF
db 'p¡smennou kl vesu.',LF
db LF
db EOT

LDatC17  label     byte
db 'aQaQa sWsWs dEdEd fRfRf fTfTf aAaA sSsS dDdD fFfF fGfG fVfV',LF
db 'Quis Quido Quis Quido Quis Quido Quis Quido Quis Quido Quis',LF
db 'Wolf West Wolf West Wolf West Wolf West Wolf West Wolf West',LF
db 'Emil Elsa Emil Elsa Emil Elsa Emil Elsa Emil Elsa Emil Elsa',LF
db 'Ruda Radek Ruda Radek Ruda Radek Ruda Radek Ruda Radek Ruda',LF
db 'Turek Tatar Turek Tatar Turek Tatar Turek Tatar Turek Tatar',LF
db 'Ariel Astra Ariel Astra Ariel Astra Ariel Astra Ariel Astra',LF
db 'Sahara Svratka Sahara Svratka Sahara Svratka Sahara Svratka',LF
db 'Dita David Dita David Dita David Dita David Dita David Dita',LF
db 'Filip Ferda Filip Ferda Filip Ferda Filip Ferda Filip Ferda',LF
db 'Gorgo Gappa Gorgo Gappa Gorgo Gappa Gorgo Gappa Gorgo Gappa',LF
db 'Volha Velim Volha Velim Volha Velim Volha Velim Volha Velim',LF
db FF
db 'Evropa Asie Afrika Amerika Arktida Sahara Darja Suez Polsko',LF
db FF
db 'Jarka a Filip dostali dopis od Radka. Rozhodli se pro Akai.',LF
db 'Kladli odpor, ale dopadli jako u Waterloo. Pozdravuj Emila.',LF
db 'Zuzka a Halka jedou za Prahu. Rudolf a Otakar zase zaspali.',LF
db 'Erika pojede s Otou, Olou a Petrou v listopadu do Rakouska.',LF
db FF
db 'gram gramu kilogram telegram program metr kilometr wattmetr',LF
db 'koupili sedm metr– sametu a osm metr– taftu, zaslali pumpu,',LF
db 'reklamujeme sto kilogram– laku, platili jsme osm wattmetr–,',LF
db 'k tomuto datu, o tomto filmu, tato metoda, k tomuto limitu,',LF
db 'dostali dodatek k tomuto posudku, zase zkusili tuto metodu,',LF
db 'museli poslat telegram, mohli jet autem, museli odjet dom–,',LF
db 'projeli Prahou, hledali hotel Merkur, dojeli metrem k Muzeu',LF
db FF
db 'Koupili jsme kameru a sedm film– pro Karla Jirouta z Lokte.',LF
db 'Odklad odletu letadla do Maroka jste mohli zjistit dotazem.',LF
db 'Zjistili jsme £daje pro soupis poplatk–. Prodali jsme Jawu.',LF
db 'Ledek a sodu jsme odeslali po lodi. Olej jsme dodali autem.',LF
db 'Papriku a s–l jsme doprodali. Mouku jsme dostali ze skladu.',LF
db 'Perspektiva rozvoje, soustava mezd a plat–, kvalita krmiva.',LF
db 'Produktivita provoz–, efektivita £prav, aktivita kolektiv–.',LF
db 'Udejte, zda jste fakturovali i doplatek za dopravu k vlaku.',LF
db 'Posuzovali jste stav vozidel. Opravil jste defekt v motoru.',LF
db 'Provedli revizi v tomto skladu. Odeslali vlakovou soupravu.',LF
db 'Dopravu voz– zajistil dodavatel. R. Sudovi poslali pozdrav.',LF
db 'Dopis, vzorek a katalog poslal do Sokolova. Dostal fakturu.',LF
db 'Souhlasili jste s touto lh–tou. Dodavatel potvrdil smlouvu.',LF
db 'Odeslali jsme vzorek veluru. Propaguje prodej podle vzork–.',LF
db 'Poplatek za odvoz popela jsem uhradil. Potvrdil jsem kopii.',LF
db 'Urguji odvoz krmiva ze skladu. Zajistili jsme rozvoz autem.',LF
db 'Dodejte deset druh– tapet dle katalogu. Shodli se v £sudku.',LF
db 'Po rozhovoru s p. Vlkem se rozhodli pro koupi auta a vleku.',LF
db 'V souvislosti s rozvojem dovozu stoupla letos produktivita.',LF
db 'Podepsal dohodu o prodeji motor–. Klesl dovoz kov– a oleje.',LF
db 'Posuzovali spolehlivost vozidel. Posuzovali i stav vozovek.',LF
db 'Zjistili velikost pozemku. Zlikvidovali odpad. Dodali vodu.',LF
db EOT

LDatI16  label     byte
LDat116  label     byte
LDat216  label     byte
db 'aQaQ sWsW dEdE fRfR fTfT aAaA sSsS dDdD fFfF fGfG aZaZ fVfV',LF
db 'Quis Quido Quis Quido Quis Quido Quis Quido Quis Quido Quis',LF
db 'Wolf West Wolf West Wolf West Wolf West Wolf West Wolf West',LF
db 'Emil Elsa Emil Elsa Emil Elsa Emil Elsa Emil Elsa Emil Elsa',LF
db 'Ruda Radek Ruda Radek Ruda Radek Ruda Radek Ruda Radek Ruda',LF
db 'Turek Tatar Turek Tatar Turek Tatar Turek Tatar Turek Tatar',LF
db 'Ariel Astra Ariel Astra Ariel Astra Ariel Astra Ariel Astra',LF
db 'Sahara Svratka Sahara Svratka Sahara Svratka Sahara Svratka',LF
db 'Dita David Dita David Dita David Dita David Dita David Dita',LF
db 'Filip Ferda Filip Ferda Filip Ferda Filip Ferda Filip Ferda',LF
db 'Gorgo Gappa Gorgo Gappa Gorgo Gappa Gorgo Gappa Gorgo Gappa',LF
db 'Zora Zoja Zora Zoja Zora Zoja Zora Zoja Zora Zoja Zora Zoja',LF
db 'Volha Velim Volha Velim Volha Velim Volha Velim Volha Velim',LF
db FF
db 'Evropa Asie Afrika Amerika Arktida Sahara Darja Suez Polsko',LF
db FF
db 'Jarka a Filip dostali dopis od Radka. Rozhodli se pro Akai.',LF
db 'Kladli odpor, ale dopadli jako u Waterloo. Pozdravuj Emila.',LF
db 'Zuzka a Halka jedou za Prahu. Rudolf a Otakar zase zaspali.',LF
db 'Erika pojede s Otou, Olou a Petrou v listopadu do Rakouska.',LF
db FF
db 'gram gramu kilogram telegram program metr kilometr wattmetr',LF
db 'koupil metr sametu, metr taftu a gram kafru, zaslali pumpu,',LF
db 'reklamujeme kilogram laku a litr oleje, platil kilo paprik,',LF
db 'k tomuto datu, o tomto filmu, tato metoda, k tomuto limitu,',LF
db 'dostali dodatek k tomuto posudku, zase zkusili tuto metodu,',LF
db 'museli poslat telegram, mohli jet autem, museli zase odjet,',LF
db 'projeli Prahou, hledali hotel Merkur, dojeli metrem k Muzeu',LF
db FF
db 'Koupili jsme videokameru a film pro Karla Jiroutka z Lokte.',LF
db 'Odklad odletu letadla do Maroka jste mohli zjistit dotazem.',LF
db 'Zjistili jsme datum pro rozpis poplatku. Prodali jsme Jawu.',LF
db 'Ledek a sodu jsme odeslali po lodi. Olej jsme dodali autem.',LF
db 'Papriku a kafr jsme doprodali. Mouku jsem dostal ze skladu.',LF
db 'Perspektiva rozvoje, soustava mezd a platu, kvalita krmiva.',LF
db 'Produktivita provozu, efektivita oprav, aktivita kolektivu.',LF
db 'Udejte, zda jste fakturovali i doplatek za dopravu k vlaku.',LF
db 'Posuzovali jste stav vozidel. Opravil jste defekt v motoru.',LF
db 'Provedli revizi v tomto skladu. Odeslali vlakovou soupravu.',LF
db 'Dopravu vozu zajistil dodavatel. R. Sudovi poslali pozdrav.',LF
db 'Dopis, vzorek a katalog poslal do Sokolova. Dostal fakturu.',LF
db 'Souhlasil jste s touto dohodou. Dodavatel potvrdil smlouvu.',LF
db 'Odeslali jsme vzorek veluru. Propaguje prodej podle vzorku.',LF
db 'Poplatek za odvoz popela jsem uhradil. Potvrdil jsem kopii.',LF
db 'Urguji odvoz krmiva ze skladu. Zajistili jsme rozvoz autem.',LF
db 'Dodejte deset rolek tapet dle katalogu. Shodli se ve stavu.',LF
db 'Po rozhovoru s p. Vlkem se rozhodli pro koupi auta a vleku.',LF
db 'V souvislosti s rozvojem dovozu stoupla letos produktivita.',LF
db 'Podepsal dohodu o prodeji motoru. Klesl dovoz kovu a oleje.',LF
db 'Posuzovali spolehlivost vozidel. Posuzovali i stav vozovek.',LF
db 'Zjistili velikost pozemku. Zlikvidovali odpad. Dodali vodu.',LF
db EOT

; ------ lekce 18 - y-
;þ
LekcC18  label     byte
db 'y-)',LF
db 'P¡smeno y p¡¨eme vych˜len¡m lev‚ho mal¡‡ku dol– na doln¡ ©adu kl ves.',LF
db 'Poml‡ku p¡¨eme vych˜len¡m prav‚ho mal¡‡ku na doln¡ p¡smennou ©adu.',LF
db LF
db 'mal¡‡kem lev‚ ruky  - y               mal¡‡kem prav‚ ruky  - -',LF
db LF
db 'V textu plat¡ pro pou‘it¡ poml‡ky tato pravidla:',LF
db '- jako rozdˆlovac¡ znam‚nko - p¡¨e se bez mezery za posledn¡ p¡smeno',LF
db '- jako spojovn¡k - p¡¨eme bez mezer (nap©. podm¡nkov‚ -li)',LF
db '- jako poml‡ka - p©ed i za poml‡ku p¡¨eme mezeru',LF
db EOT

LekcI17  label     byte
Lekc117  label     byte
Lekc217  label     byte
db 'y-)',LF
db 'P¡smeno y p¡¨eme vych˜len¡m prav‚ho ukazov ‡ku vzh–ru na horn¡ ©adu.',LF
db 'Poml‡ku p¡¨eme vych˜len¡m prav‚ho mal¡‡ku na horn¡ ‡¡selnou ©adu.',LF
db LF
db 'ukazov ‡kem prav‚ ruky  - y               mal¡‡kem prav‚ ruky  - -',LF
db LF
db 'V textu plat¡ pro pou‘it¡ poml‡ky tato pravidla:',LF
db '- jako rozdˆlovac¡ znam‚nko - p¡¨e se bez mezery za posledn¡ p¡smeno',LF
db '- jako spojovn¡k - p¡¨eme bez mezer (nap©. podm¡nkov‚ -li)',LF
db '- jako poml‡ka - p©ed i za poml‡ku p¡¨eme mezeru',LF
db EOT

LDatC18  label     byte
db 'yyyyyyyyy --------- ayayayaya –-–-–-–-– ayayayaya –-–-–-–-–',LF
db 'aya sya aya sya aya sya aya sya aya sya aya sya aya sya aya',LF
db 'dyk rys dyk rys dyk rys dyk rys dyk rys dyk rys dyk rys dyk',LF
db 'k–-ra l–-za k–-ra l–-za k–-ra l–-za k–-ra l–-za k–-ra l–-za',LF
db 'pr–-kazy d–-vody pr–-kazy d–-vody pr–-kazy d–-vody pr–-kazy',LF
db 'p–-jde, vy-jde, vy-hledal, vy-stavil, vy-platil, umy-vadlo,',LF
db 'vykazujete-li, urgujete-li, vystavujete-li, propagujete-li,',LF
db 'vzorky kov– - opravy kotl– - £spory kov– - soupravy vlak– -',LF
db 'rozvoj aktivity - r–st efektivity, produktivity a kvality -',LF
db FF
db 'kdy tedy tady kdy kdykoli kdy mysl smysl £mysl mysl pr–mysl',LF
db FF
db 'Podle £mluvy jsme vyslali soupravy vlak– do Kyjova a Opavy.',LF
db 'Poplatky za dopravu do Prahy jsme kalkulovali podle tarifu.',LF
db 'Vydal spisem autorovy dopisy. Odeslal dva vzorky a katalog.',LF
db FF
db 'Letos vzrostl zisk v souvislosti s poutavou formou prodeje.',LF
db 'Divadlo opakovalo deset let svou velkou hru. Zhotovili jsme',LF
db 'kladku. Opravili vrata, vrata vrzala. Odjeli jsme do Mostu.',LF
db 'Souhlasili s fakturou. Evidovali z–statek. Zajistili dovoz.',LF
db 'Ve skladu je sto metr– tapet. Zajistil jsem dopravu vlakem.',LF
db FF
db '£koly £seky aktivy projekty provozy rezervy devizy pozdravy',LF
db '£spory deviz, metody postupu, £ryvek dopisu, £seky vozovky,',LF
db 'vydali rozkazy, vydali tarify, vymezili £koly, vydali pasy,',LF
db 'poslali pozdravy, upravili vztahy, dodali filtry, traktory,',LF
db 'opravujete-li, postupujete-li, podporujete-li, pojedete-li,',LF
db 'adresy dodavatel– - £spory kov– - £pravy odlitk– - porady -',LF
db 'ze-zdola, re-spekt, pro-spekt, seda-dlo, vy-psat, vy-zvedl,',LF
db 'Dodali podle smlouvy dva druhy odlitk–. Ustoupil od dohody.',LF
db 'mzdy a platy stouply - vklady vzrostly - dodali jsme vzorky',LF
db 'p–dy - rozeslali jsme £tvar–m rozpisy £kol– - vyvodili jsme',LF
db 'd–sledky z kritiky dopravy - sepsali jsme smlouvu o prodeji',LF
db 'auta s vlekem - v hale jsme vystavili modely dvou aut - po-',LF
db 'skytli jsme slevu za opravu vodovodu - zjistili jsme vady -',LF
db EOT

LDatI17  label     byte
LDat117  label     byte
LDat217  label     byte
db 'yyyyyyyyy --------- jyjyjyjyj ;-;-;-;-; jyjyjyjyj ;-;-;-;-;',LF
db 'jyj uyj jyj uyj jyj uyj jyj uyj jyj uyj jyj uyj jyj uyj jyj',LF
db 'kyj pyl kyj pyl kyj pyl kyj pyl kyj pyl kyj pyl kyj pyl kyj',LF
db 'ry-la ki-la ry-la ki-la ry-la ki-la ry-la ki-la ry-la ki-la',LF
db 'roz-kazy do-hody roz-kazy do-hody roz-kazy do-hody roz-kazy',LF
db 'za-jde, vy-jde, vy-hledal, vy-stavil, vy-platil, umy-vadlo,',LF
db 'vykazujete-li, urgujete-li, vystavujete-li, propagujete-li,',LF
db 'vzorky kovu - opravy kotle - dovozy kovu - souprava vlaku -',LF
db 'rozvoj aktivity - stav efektivity, produktivity a kvality -',LF
db FF
db 'kdy tedy tady kdy kdykoli kdy mysl smysl rozmysl mysl smysl',LF
db FF
db 'Podle dohody jsme vyslali soupravu vlaku do Kyjova a Opavy.',LF
db 'Poplatky za dopravu do Prahy jsme kalkulovali podle tarifu.',LF
db 'Vydal spisem autorovy dopisy. Odeslal dva vzorky a katalog.',LF
db FF
db 'Letos vzrostl zisk v souvislosti s poutavou formou prodeje.',LF
db 'Divadlo opakovalo deset let svou velkou hru. Zhotovili jsme',LF
db 'kladku. Opravili vrata, vrata vrzala. Odjeli jsme do Mostu.',LF
db 'Souhlasili s fakturou. Evidovali poplatek. Zajistili dovoz.',LF
db 'Ve skladu je sto rolek tapet. Zajistil jsem dopravu vlakem.',LF
db FF
db 'dohody vody aktivy projekty provozy rezervy devizy pozdravy',LF
db 'dovozy deviz, metody postupu, kousky dopisu, metry vozovky,',LF
db 'vydali rozkazy, vydali tarify, omezili opravy, vydali pasy,',LF
db 'poslali pozdravy, upravili vztahy, dodali filtry, traktory,',LF
db 'opravujete-li, postupujete-li, podporujete-li, pojedete-li,',LF
db 'adresa dodavatele - rozpis kovu - opravy odlitku - porady -',LF
db 'ze-zdola, re-spekt, pro-spekt, seda-dlo, vy-psat, vy-zvedl,',LF
db 'Dodali podle smlouvy dva druhy odlitku. Ustoupil od dohody.',LF
db 'mzdy a platy stouply - vklady vzrostly - dodali jsme vzorky',LF
db 'vody - rozeslali jsme dopisem rozpisy smluv - vyvodili jsme',LF
db 'postihy dle kritiky opravy - sepsali jsme smlouvu o prodeji',LF
db 'auta s vlekem - v hale jsme vystavili modely dvou aut - po-',LF
db 'skytli jsme slevu za opravu vodovodu - zjistili jsme vady -',LF
db EOT

; ------ lekce 19 - c
;þ
LekcC19  label     byte
LekcI18  label     byte
Lekc118  label     byte
Lekc218  label     byte
db 'c)',LF
db LF
db 'Um¡stˆte ruce do z kladn¡ polohy a nacvi‡ujte:',LF
db LF
db 'prost©edn¡kem lev‚ ruky  - c',LF
db LF
db 'Nenechte se sv‚st k psan¡ tohoto p¡smene ukazov ‡kem, jinak si naru¨¡te',LF
db 'prstoklad.',LF
db LF
db LF
db EOT

LDatC19  label     byte
db 'ccccccccc dcdcdcdcdcdcd dcd cdc dcd cdc dcd cdc dcd cdc dcd',LF
db 'dcdf dcds dcdf dcds dcdf dcds dcdf dcds dcdf dcds dcdf dcds',LF
db 'cech dech cech dech cech dech cech dech cech dech cech dech',LF
db 'odchod hoch odchod hoch odchod hoch odchod hoch odchod hoch',LF
db 'pracuje hladce pracuje hladce pracuje hladce pracuje hladce',LF
db 'car cep car cep car cep car cep car cep car cep car cep car',LF
db 'jejich dech jejich dech jejich dech jejich dech jejich dech',LF
db 'privatizace automatizace klimatizace rekvalifikace vegetace',LF
db 'kooperace vchod federace rekreace pr–chod kolouch degradace',LF
db FF
db 'co docela zcela chceme chcete cesty procesy procesu situace',LF
db FF
db 'V tomto roce opravili vodovod a celou vozovku do Chemopolu.',LF
db 'Odeslali dispozice pro dopravu cukrovky autem do cukrovaru.',LF
db 'Vzorky jsme dopravili letecky. Poukazujeme poplatek za clo.',LF
db FF
db 'Chceme urychlit proces automatizace a chemizace v pr–myslu.',LF
db 'Dotace jsou stimulem pro rozvoj literatury, divadel, filmu.',LF
db 'Dostali jsme k dispozici prostory pro sklady mouky a cukru.',LF
db 'Chceme opravit starou cestu. Chodec se zastavil u pr–chodu.',LF
db 'Usilujeme o r–st kvalifikace mistr–. Clo je podle regulace.',LF
db 'Zpracovali data o stavu stroj–. Posoudili situaci v dolech.',LF
db EOT

LDatI18  label     byte
LDat118  label     byte
LDat218  label     byte
db 'ccccccccc dcdcdcdcdcdcd dcd cdc dcd cdc dcd cdc dcd cdc dcd',LF
db 'dcdf dcds dcdf dcds dcdf dcds dcdf dcds dcdf dcds dcdf dcds',LF
db 'cech dech cech dech cech dech cech dech cech dech cech dech',LF
db 'odchod hoch odchod hoch odchod hoch odchod hoch odchod hoch',LF
db 'pracuje hladce pracuje hladce pracuje hladce pracuje hladce',LF
db 'car cep car cep car cep car cep car cep car cep car cep car',LF
db 'jejich dech jejich dech jejich dech jejich dech jejich dech',LF
db 'privatizace automatizace klimatizace rekvalifikace vegetace',LF
db 'kooperace vchod federace rekreace rozchod kolouch degradace',LF
db FF
db 'co docela zcela chceme chcete cesty procesy procesu situace',LF
db FF
db 'V tomto roce opravili vodovod a celou vozovku do Chemopolu.',LF
db 'Odeslali dispozice pro dopravu cukrovky autem do cukrovaru.',LF
db 'Vzorky jsme dopravili letecky. Poukazujeme poplatek za clo.',LF
db FF
db 'Chceme urychlit procesy automatizace a chemizace v provozu.',LF
db 'Dotace jsou stimulem pro rozvoj literatury, divadel, filmu.',LF
db 'Dostali jsme k dispozici prostory pro sklady mouky a cukru.',LF
db 'Chceme opravit starou cestu. Chodci se zastavili ve vchodu.',LF
db 'Urychlete rozvoj kvalifikace mistra. Clo je podle regulace.',LF
db 'Zpracovali data o stavu stroje. Posoudili situaci v dolech.',LF
db EOT

; ------ lekce 20 - n
;þ
LekcC20  label     byte
LekcI19  label     byte
Lekc119  label     byte
Lekc219  label     byte
db 'n)',LF
db LF
db 'P¡smeno  n  p¡¨eme  prav˜m  ukazov ‡kem, kter˜ vychylujeme vlevo dol– na',LF
db 'doln¡ ©adu kl ves.',LF
db LF
db 'ukazov ‡kem prav‚ ruky  - n',LF
db LF
db 'Uvˆdomte si rozd¡l mezi polohou m a n, aby se V m tato p¡smena nepletla.',LF
db LF
db LF
db EOT

LDatC20  label     byte
db 'nnnnnnn jnjnjnjnj jnjmj jmjnj jnjmj jmjnj jnjmj jmjnj jnjmj',LF
db 'jnj kjn jnj kjn jnj kjn jnj kjn jnj kjn jnj kjn jnj kjn jnj',LF
db 'jeden jedna jeden jedna jeden jedna jeden jedna jeden jedna',LF
db 'kuna kino kuna kino kuna kino kuna kino kuna kino kuna kino',LF
db 'konto konec konto konec konto konec konto konec konto konec',LF
db 'ani nejde ani nejde ani nejde ani nejde ani nejde ani nejde',LF
db 'podnik technik cena cenou tunu nuzota nikdo nora nadhled ne',LF
db 'plnit navrhuje povinnost pozornost okolnost efektivnost ano',LF
db 'slunce seno jahody pevnost nestrannost mina vnuk osnova nic',LF
db FF
db 'jen ten, nejen tento jeden den ani nikdy nikdo nikoho nikde',LF
db FF
db 'Provedl technickou kontrolu vozidla. Nedostatky projednali.',LF
db 'Potvrdili telefonickou dohodu. Zdokonalil konstrukci pumpy.',LF
db 'Na veletrhu poutaly pozornost auta Nautilus. Cena vyhovuje.',LF
db 'Reklamoval stany. Fakturu za hrnce z nerezu uhradili ihned.',LF
db FF
db 'Ze dne na den je tu podzim. Nenalezli partnery pro lisovnu.',LF
db 'Podnik zajistil ochranu proti £raz–m, proti hluku a prachu.',LF
db 'Po inovaci tkanin z vlny stoupla jejich prodejnost na trhu.',LF
db 'Je tedy nutno odhalit nedostatky a vyvodit z nich d–sledky.',LF
db 'Zajistil rozvoz ovoce a zeleniny autem ze skladu v Doksech.',LF
db EOT

LDatI19  label     byte
LDat119  label     byte
LDat219  label     byte
db 'nnnnnnn jnjnjnjnj jnjmj jmjnj jnjmj jmjnj jnjmj jmjnj jnjmj',LF
db 'jnj kjn jnj kjn jnj kjn jnj kjn jnj kjn jnj kjn jnj kjn jnj',LF
db 'jeden jedna jeden jedna jeden jedna jeden jedna jeden jedna',LF
db 'kuna kino kuna kino kuna kino kuna kino kuna kino kuna kino',LF
db 'konto konec konto konec konto konec konto konec konto konec',LF
db 'ani nejde ani nejde ani nejde ani nejde ani nejde ani nejde',LF
db 'podnik technik cena cenou tunu nuzota nikdo nora nadhled ne',LF
db 'plnit navrhuje povinnost pozornost okolnost efektivnost ano',LF
db 'slunce seno jahody pevnost nestrannost mina vnuk osnova nic',LF
db FF
db 'jen ten, nejen tento jeden den ani nikdy nikdo nikoho nikde',LF
db FF
db 'Provedl technickou kontrolu vozidla. Nedostatky projednali.',LF
db 'Potvrdili telefonickou dohodu. Zdokonalil konstrukci pumpy.',LF
db 'Na veletrhu poutaly pozornost auta Nautilus. Cena vyhovuje.',LF
db 'Reklamoval stany. Fakturu za hrnce z nerezu uhradili ihned.',LF
db FF
db 'Ze dne na den je tu podzim. Nenalezli partnery pro lisovnu.',LF
db 'Podnik zavedl v provozu linky ochranu proti hluku a prachu.',LF
db 'Po inovaci tkanin z vlny stoupla jejich prodejnost na trhu.',LF
db 'Je proto nutno odhalit nedostatky a vyvodit z nich postihy.',LF
db 'Zajistil rozvoz ovoce a zeleniny autem ze skladu v Doksech.',LF
db EOT

; ------ lekce 21 - b
;þ
LekcC21  label     byte
LekcI20  label     byte
Lekc120  label     byte
Lekc220  label     byte
db 'b)',LF
db LF
db 'P©i  psan¡  p¡smena  b  mus¡me lev˜ ukazov ‡ek vych˜lit hodnˆ doprava na',LF
db 'spodn¡ ©adu p¡smen.',LF
db LF
db 'ukazov ‡kem lev‚ ruky  - b',LF
db LF
db 'P©i psan¡ p¡smena  b  si uvˆdomte rozd¡l mezi polohou v a b a d vejte si',LF
db 'pozor na spojen¡ br a bt. Lev˜ mal¡‡ek mus¡ z–stat v z kladn¡ poloze.',LF
db LF
db EOT

LDatC21  label     byte
db 'bbbbbbbb fbfbfbfbf fbfvf fvfb fbfv fvfb fbfv fvfb fbfv fvfb',LF
db 'fgb fvb fgb fvb fgb fvb fgb fvb fgb fvb fgb fvb fgb fvb fgb',LF
db 'dfgb sfgb dfgb sfgb dfgb sfgb dfgb sfgb dfgb sfgb dfgb sfgb',LF
db 'bas buk bas buk bas buk bas buk bas buk bas buk bas buk bas',LF
db 'obsah bedny obsah bedny obsah bedny obsah bedny obsah bedny',LF
db 'banka bidlo banka bidlo banka bidlo banka bidlo banka bidlo',LF
db 'beton bufet beton bufet beton bufet beton bufet beton bufet',LF
db 'doba obec doba obec doba obec doba obec doba obec doba obec',LF
db 'obratem oborem obnosem obalem bodem oborem obratem rozborem',LF
db 'byla by nebo by nebyla brzy bita kdyby byla zabalila jablka',LF
db 'by aby byste abyste byt byty sebere bratr seberete bere oba',LF
db 'Blansko Beroun Bohosudov Brno Bratislava Brusel Bonn Bouzov',LF
db FF
db 'byl nebyl byli nebyli nebudou zp–sob p–sobit p–sobnost obou',LF
db FF
db 'Oznamte obratem, zda byste mohli zaslat matice a subpanely.',LF
db 'V prosinci klesl objem produkce i objem odbytu na polovinu.',LF
db 'Udejte podrobnosti o obalech a zp–sobu dopravy a fakturace.',LF
db 'Oznamte telegraficky, zda budete moci ihned odeslat jablka.',LF
db FF
db 'V centru Borovan budeme modernizovat mnoho byt–. Byty budou',LF
db 'vybaveny koupelnou. Objednali jsme rekonstrukci plynovodu a',LF
db 'vodovodu. Usilujeme o dobrou kvalitu byt–. Vybudujeme novou',LF
db 'samoobsluhu, zmodernizujeme kino a restauraci. Obchody bude',LF
db 'budovat firma Budostav. Vybudujeme i banku a jedno divadlo.',LF
db EOT

LDatI20  label     byte
LDat120  label     byte
LDat220  label     byte
db 'bbbbbbbb fbfbfbfbf fbfvf fvfb fbfv fvfb fbfv fvfb fbfv fvfb',LF
db 'fgb fvb fgb fvb fgb fvb fgb fvb fgb fvb fgb fvb fgb fvb fgb',LF
db 'dfgb sfgb dfgb sfgb dfgb sfgb dfgb sfgb dfgb sfgb dfgb sfgb',LF
db 'bas buk bas buk bas buk bas buk bas buk bas buk bas buk bas',LF
db 'obsah bedny obsah bedny obsah bedny obsah bedny obsah bedny',LF
db 'banka bidlo banka bidlo banka bidlo banka bidlo banka bidlo',LF
db 'beton bufet beton bufet beton bufet beton bufet beton bufet',LF
db 'doba obec doba obec doba obec doba obec doba obec doba obec',LF
db 'obratem oborem obnosem obalem bodem oborem obratem rozborem',LF
db 'byla by nebo by nebyla brzy bita kdyby byla zabalila jablka',LF
db 'by aby byste abyste byt byty sebere bratr seberete bere oba',LF
db 'Blansko Beroun Bohosudov Brno Bratislava Brusel Bonn Bouzov',LF
db FF
db 'byl nebyl byli nebyli nebudu osoby vzbudit osobnost klobouk',LF
db FF
db 'Oznamte obratem, zda byste mohli zaslat matice a subpanely.',LF
db 'V prosinci klesl objem produkce i objem odbytu na polovinu.',LF
db 'Udejte podrobnosti o obalech, poplatku a rychlosti dopravy.',LF
db 'Oznamte telegraficky, zda budete moci ihned odeslat jablka.',LF
db FF
db 'V centru Borovan budeme modernizovat velkohotel. Byty budou',LF
db 'vybaveny koupelnou. Objednali jsme rekonstrukci plynovodu a',LF
db 'vodovodu. Usilujeme o dobrou kvalitu bytu. Vybudujeme novou',LF
db 'samoobsluhu, zmodernizujeme kino a restauraci. Obchody bude',LF
db 'budovat firma Budostav. Vybudujeme i banku a jedno divadlo.',LF
db EOT

; ------ lekce 22 - x CAPSLOCK
;þ
LekcC22  label     byte
LekcI21  label     byte
Lekc121  label     byte
Lekc221  label     byte
db 'x Caps Lock)',LF
db LF
db 'P¡smeno  x  p¡¨eme vych˜len¡m lev‚ho prsten¡ku vpravo dol– na doln¡ ©adu',LF
db 'kl ves. Jestli‘e je t©eba napsat v¡ce velk˜ch p¡smen za sebou, pou‘ijeme',LF
db 'kl vesu  Caps Lock,  kterou  stiskneme lev˜m mal¡‡kem. Navr cen¡ k mal˜m',LF
db 'p¡smen–m zpˆt je mo‘n‚ opˆtovn˜m stiskem kl vesy Caps Lock.',LF
db LF
db 'prsten¡kem lev‚ ruky  - x',LF
db '  mal¡‡kem lev‚ ruky  - Caps Lock',LF
db LF
db EOT

LDatC22  label     byte
db 'xxxxXXXX sxsxsxsXSXSXSX sxs xsx SXS XSX sxs xsx SXS XSX sxs',LF
db 'sxs sxf sxs sxf sxs sxf sxs sxf sxs sxf sxs sxf sxs sxf sxs',LF
db 'rsx tsx rsx tsx rsx tsx rsx tsx rsx tsx rsx tsx rsx tsx rsx',LF
db 'sxsa sxsd sxsf sxsa SXSD SXSF SXSA SXSD sxsf sxsa sxsd sxsf',LF
db 'luxus extra luxus extra luxus extra luxus extra luxus extra',LF
db 'texty xerox texty xerox texty xerox texty xerox texty xerox',LF
db 'a. s. GUMOTEX, firma PHILIPS, GEMA Soft, kosmetika fy HEAL,',LF
db 'expedice expedovat exploze explodovat exhalace text textilu',LF
db 'IGLA Jihlava, ZSE Praha, s. p. EPL, SIGMA Olomouc, KAVALIER',LF
db FF
db 'export exportovat exportujeme komplex komplexem komplexnost',LF
db FF
db 'Dovolujeme si upozornit na novou kolekci obuvi, kterou jsme',LF
db 'vyvinuli pro export. Tyto druhy textilu bychom mohli prodat',LF
db 'za uvedenou cenu. Expedovali jsme sedm tun vlny a deset tun',LF
db 'bavlny. Na veletrhu jsme sjednali kontrakt pro export skla.',LF
db FF
db 'Exportujeme stroje, textil, sklo, obuv, importujeme bavlnu,',LF
db 'vlnu, kovy, naftu. Chceme omezovat export surovin a poloto-',LF
db 'var–. Je nutno, aby podniky zajistily maximum £spor paliv a',LF
db 'energie. Budeme energicky prosazovat, aby podniky omezovaly',LF
db 'exhalace plyn–. Postavili jsme komplex budov pro nemocnici.',LF
db FF
db 'jeden jedna jednota jednotnou jednotka jednotky jednotlivou',LF
db 'Neuvedli jste cenu za jednotku. Neuvedli jste druhovou spe-',LF
db 'cifikaci vlny. Zatelefonujte, kdy odvezete ze skladu cihly.',LF
db 'Oznamte, zda jste dodali len. Dejte pokyn k transportu mag-',LF
db 'netofon– do provozovny. Defekt na rentgenu vznikl dopravou.',LF
db 'Jsme ochotni situaci projednat a dohodnout se o penalizaci.',LF
db 'bere odebere ubral vybral robot vyrobil hluboko prohlubovat',LF
db 'Obliba tohoto typu bot stoupla. Obaly jsme zaslali obratem.',LF
db 'Je nutno, abychom zajistili dostatek byt– pro obyvatelstvo.',LF
db 'Podepsali jsme dlouhodobou smlouvu s dodavatelem. Budeme-li',LF
db 'spokojeni s dodanou surovinou, mohli bychom rozvinout dlou-',LF
db 'hodobou kooperaci. Objednali jsme bedny pro dopravu jablek.',LF
db 'extrakt exploze expedice expedovat existovat maximum textil',LF
db 'Za dvacet let existence cukrovaru bylo vyrobeno mnoho cukru',LF
db 'pro export. Odeslali jsme ihned £hradu za expertizu obrazu.',LF
db 'Chceme zajistit komplexnost postupu pro stavbu byt–. Cement',LF
db 'jsme expedovali auty na stavbu domk– v Chebu. Zajistili d–l',LF
db 'proti explozi plyn–. Zhotovili jsme na xeroxu kopie dopis–.',LF
db 'Oznamte, zda byste mohli vyrobit obuv podle vzor–. Odeslali',LF
db 'jsme obratem potvrzenou smlouvu. Jablka odebereme ze skladu',LF
db 'v Brodku. Doklady pro fakturaci je nutno poslat do dvou dn–',LF
db 'po expedici. Bude-li kvalita plexiskla vyhovovat, budeme je',LF
db 'trvale kupovat. Bednu brousk– dodejte do provozovny v Boru.',LF
db 'Je nutno prosazovat pokrokovou ekonomickou politiku. Chceme',LF
db 'zdokonalovat dlouhodobou ekonomickou kooperaci a integraci.',LF
db 'Je nutno zdokonalovat metody organizace podnik–, propagovat',LF
db 'inovace stroj–, prosazovat pokrokovou technologii do praxe.',LF
db 'Budeme podporovat rozvoj obchodu. Chceme omezit dovoz kov–.',LF
db EOT

LDatI21  label     byte
LDat121  label     byte
LDat221  label     byte
db 'xxxxXXXX sxsxsxsXSXSXSX sxs xsx SXS XSX sxs xsx SXS XSX sxs',LF
db 'sxs sxf sxs sxf sxs sxf sxs sxf sxs sxf sxs sxf sxs sxf sxs',LF
db 'rsx tsx rsx tsx rsx tsx rsx tsx rsx tsx rsx tsx rsx tsx rsx',LF
db 'sxsa sxsd sxsf sxsa SXSD SXSF SXSA SXSD sxsf sxsa sxsd sxsf',LF
db 'luxus extra luxus extra luxus extra luxus extra luxus extra',LF
db 'texty xerox texty xerox texty xerox texty xerox texty xerox',LF
db 'a. s. GUMOTEX, firma PHILIPS, GEMA Soft, kosmetika fy HEAL,',LF
db 'expedice expedovat exploze explodovat exhalace text textilu',LF
db 'IGLA Jihlava, ZSE Praha, s. p. EPL, SIGMA Olomouc, KAVALIER',LF
db FF
db 'export exportovat exportujeme komplex komplexem komplexnost',LF
db FF
db 'Dovolujeme si upozornit na novou kolekci obuvi, kterou jsme',LF
db 'vyvinuli pro export. Tyto druhy textilu bychom mohli prodat',LF
db 'za uvedenou cenu. Expedovali jsme sedm tun vlny a deset tun',LF
db 'bavlny. Na veletrhu jsme sjednali kontrakt pro export skla.',LF
db FF
db 'Exportujeme stroje, textil, sklo, obuv, importujeme bavlnu,',LF
db 'vlnu, kovy, naftu. Chceme omezovat export surovin a poloto-',LF
db 'varu. Je nutno, aby podniky omezovaly dovoz mosazi, paliv a',LF
db 'energie. Budeme energicky prosazovat, aby podniky omezovaly',LF
db 'exhalace plynu. Postavili jsme komplex budov pro nemocnici.',LF
db FF
db 'jeden jedna jednota jednotnou jednotka jednotky jednotlivou',LF
db 'Neuvedli jste cenu za jednotku. Neuvedli jste druhovou spe-',LF
db 'cifikaci vlny. Zatelefonujte, kdy odvezete ze skladu cihly.',LF
db 'Oznamte, zda jste dodali len. Dejte pokyn k transportu mag-',LF
db 'netofonu do provozovny. Defekt na rentgenu vznikl dopravou.',LF
db 'Jsme ochotni situaci projednat a dohodnout se o penalizaci.',LF
db 'bere odebere ubral vybral robot vyrobil hluboko prohlubovat',LF
db 'Obliba tohoto typu bot stoupla. Obaly jsme zaslali obratem.',LF
db 'Je nutno, abychom zajistili byt i pro obyvatele bez domova.',LF
db 'Podepsali jsme dlouhodobou smlouvu s dodavatelem. Budeme-li',LF
db 'spokojeni s dodanou surovinou, mohli bychom rozvinout dlou-',LF
db 'hodobou kooperaci. Objednali jsme bedny pro dopravu jablek.',LF
db 'extrakt exploze expedice expedovat existovat maximum textil',LF
db 'Za dvacet let existence cukrovaru bylo vyrobeno mnoho cukru',LF
db 'pro export. Odeslali jsme ihned doklad na expertizu obrazu.',LF
db 'Chceme zajistit komplexnost postupu pro stavbu bytu. Cement',LF
db 'jsme expedovali auty na stavbu domku v Chebu. Zajistili lom',LF
db 'proti explozi plynu. Zhotovili jsme na xeroxu kopie dopisu.',LF
db 'Oznamte, zda byste mohli vyrobit obuv podle vzoru. Odeslali',LF
db 'jsme obratem potvrzenou smlouvu. Jablka odebereme ze skladu',LF
db 'v Brodku. Doklady pro fakturaci a smlouvu je nutno zhotovit',LF
db 'po expedici. Bude-li kvalita plexiskla vyhovovat, budeme je',LF
db 'trvale kupovat. Bednu brousku dodejte do provozovny v Boru.',LF
db 'Je nutno prosazovat pokrokovou ekonomickou politiku. Chceme',LF
db 'zdokonalovat dlouhodobou ekonomickou kooperaci a integraci.',LF
db 'Je nutno zdokonalovat metody organizace podniku, propagovat',LF
db 'inovace stroje, prosazovat pokrokovou technologii do praxe.',LF
db 'Budeme podporovat rozvoj obchodu. Chceme omezit dovoz kovu.',LF
db EOT

; ------ lekce 22 -
;þ
LekcI22  label     byte
db '£–)',LF
db '—plnˆ  vlevo  na  ‡¡seln‚  ©adˆ je um¡stˆna kl vesa ‡ rky `, kter  m  tu',LF
db 'vlastnost,  ‘e  po  jej¡m  stisku  se kurzor neposune. Proto je naz˜v na',LF
db 'mrtvou  kl vesou  (jinak t‚‘ prefixov  kl vesa). Tato kl vesa se pou‘¡v ',LF
db 'k  psan¡  p¡smen  s  ‡ rkou  nebo h ‡kem, kter  nejsou k dispozici p©¡mo',LF
db 'na kl vesnici. Kl vesu ` tiskneme lev˜m mal¡‡kem, pak stiskneme p¡smeno,',LF
db 'nad  kter˜m  m  b˜t znam‚nko vytvo©eno (pop©. bl¡zk‚ p¡smeno, je-li v¡ce',LF
db 'mo‘nost¡).  P¡smeno  £  obdr‘¡me  stiskem  p¡smene  u, p¡smeno – stiskem',LF
db 'p¡smene j po mrtv‚ (prefixov‚) kl vese.',LF
db LF
db EOT

Lekc122  label     byte
db '£–)',LF
db '—plnˆ  vlevo  na  ‡¡seln‚  ©adˆ je um¡stˆna kl vesa ‡ rky `, kter  m  tu',LF
db 'vlastnost,  ‘e  po  jej¡m  stisku  se kurzor neposune. Proto je naz˜v na',LF
db 'mrtvou  kl vesou  (jinak t‚‘ prefixov  kl vesa). Tato kl vesa se pou‘¡v ',LF
db 'k  psan¡  p¡smen  s  ‡ rkou  nebo h ‡kem, kter  nejsou k dispozici p©¡mo',LF
db 'na kl vesnici. Kl vesu ` tiskneme lev˜m mal¡‡kem, pak stiskneme p¡smeno,',LF
db 'nad  kter˜m  m  b˜t znam‚nko vytvo©eno (pop©. bl¡zk‚ p¡smeno, je-li v¡ce',LF
db 'mo‘nost¡).  P¡smeno  £  obdr‘¡me  stiskem  p¡smene u po mrtv‚ kl vese `.',LF
db 'P¡smeno – zap¡¨eme mal¡‡kem lev‚ ruky vych˜len¡m vlevo na ‡¡selnou ©adu.',LF
db LF
db EOT

Lekc222  label     byte
db '£–)',LF
db LF
db 'Vpravo na ‡¡seln‚ ©adˆ je um¡stˆna kl vesa ‡ rky a h ‡ku ',39,'~, kter  m  tu',LF
db 'vlastnost,  ‘e  po  jej¡m  stisku  se kurzor neposune. Proto ji naz˜v me',LF
db 'mrtvou  kl vesou  (jinak  t‚‘  prefixov   kl vesa).  P©i psan¡ p¡smene £',LF
db 'stiskneme prav˜m mal¡‡kem kl vesu s ‡ rkou ',39,', potom stiskneme p¡smeno u.',LF
db 'P©i  psan¡  p¡smene  –  stiskneme  prav˜m mal¡‡kem kl vesu s h ‡kem ~ za',LF
db 'sou‡asn‚ho stisku kl vesy SHIFT lev˜m mal¡‡kem a potom stiskneme znak u.',LF
db LF
db LF
db EOT

LDatI22  label     byte
LDat122  label     byte
LDat222  label     byte
db '£££££ ––––– £daj– £raz– £kol– £sek– £der– £skok– £pis– £hl–',LF
db '£kol– £der– £sek– £kol– £der– £sek– £kol– £der– £sek– £kol–',LF
db 'rok rok– £rok £rok– £rokujete rok rok– rokujete £roku £rok–',LF
db 'hrad uhradit £hrada £hradou uhradil uhradili £hradu £hradou',LF
db '£pis £pis– dopis dopis– £pis £pis– rozpis rozpis– £pis spis',LF
db 'kolo £kol £kol– £hoz £hoz– kolik kilo koupil p–l p–lil £kol',LF
db 'rok roku £rok £roku £rokujete £kol £kolu £loha £lohu £lohou',LF
db FF
db 'sepsali protokol o £razu, zapsali si £tratu, podepsal £pis,',LF
db 'dostal za £kol zakreslit £hel dopadu, zajistil £sporu tuk–,',LF
db 'zjistili £daje pro statistiku, zaslali £hradu tohoto dluhu,',LF
db 'rozhodl se pro t£ru do hor, zjistil £daje o odletu letadla,',LF
db 'propagujete £sporu oleje, urgujete £hradu dluhu za traktor,',LF
db EOT

; ------ lekce 23 - ¡
;þ
LekcC23  label     byte
Lekc123  label     byte
Lekc223  label     byte
db '¡)',LF
db LF
db 'P¡smeno ¡ p¡¨eme prost©edn¡kem prav‚ ruky, kter˜ vychylujeme nahoru',LF
db 'a m¡rnˆ vlevo.',LF
db LF
db 'prost©edn¡kem prav‚ ruky  - ¡',LF
db LF
db 'Prav˜ ukazov ‡ek mus¡ z–stat v z kladn¡ poloze!',LF
db LF
db LF
db EOT

LekcI23  label     byte
db '¡)',LF
db LF
db LF
db 'P¡smeno  ¡  p¡¨eme  pomoc¡ tzv. mrtv‚ (prefixov‚) kl vesy. Mal¡‡kem lev‚',LF
db 'ruky stiskneme kl vesu ‡ rky `, potom stiskneme prost©edn¡kem prav‚ ruky',LF
db 'p¡smeno i.',LF
db LF
db LF
db LF
db LF
db EOT

LDatC23  label     byte
LDatI23  label     byte
LDat123  label     byte
LDat223  label     byte
db '¡¡¡¡¡¡¡¡¡ k¡k¡k¡k¡k¡k¡k j¡k k¡k l¡k –¡k j¡k k¡k l¡k –¡k j¡k',LF
db 'ki¡k ji¡k ki¡k ji¡k ki¡k ji¡k ki¡k ji¡k ki¡k ji¡k ki¡k ji¡k',LF
db 's¡k d¡k l¡k s¡k d¡k l¡k s¡k d¡k l¡k s¡k d¡k l¡k s¡k d¡k l¡k',LF
db 'j¡k l¡k k¡k j¡k l¡k k¡k j¡k l¡k k¡k j¡k l¡k k¡k j¡k l¡k k¡k',LF
db 'mal¡k cen¡k mal¡k cen¡k mal¡k cen¡k mal¡k cen¡k mal¡k cen¡k',LF
db 'kon¡k lum¡k kon¡k lum¡k kon¡k lum¡k kon¡k lum¡k kon¡k lum¡k',LF
db 'm¡sa m¡le m¡sa m¡le m¡sa m¡le m¡sa m¡le m¡sa m¡le m¡sa m¡le',LF
db 'd¡ky c¡le v¡ce d¡ky c¡le v¡ce d¡ky c¡le v¡ce d¡ky c¡le v¡ce',LF
db 'maj¡ mus¡ nyn¡ maj¡ mus¡ nyn¡ maj¡ mus¡ nyn¡ maj¡ mus¡ nyn¡',LF
db 'denn¡ jarn¡ letn¡ zimn¡ denn¡ jarn¡ letn¡ zimn¡ denn¡ jarn¡',LF
db 'jakostn¡ kontroln¡ch okresn¡ho dodac¡ch dosavadn¡ ostatn¡ch',LF
db 'kolektivn¡ smlouva, m¡sto placen¡, mnoho lid¡, toto obdob¡,',LF
db 'obchodn¡ dohody, pracovn¡ podm¡nky, v¡ce m¡st, dodac¡ lh–ty',LF
db 'v¡ce uhl¡, m¡sto placen¡, vedouc¡ pracovn¡ci, osobn¡ dopis.',LF
db FF
db 'm¡ru denn¡ mus¡me pracuj¡c¡ch m¡st lid¡ v¡ce obdob¡ ostatn¡',LF
db 't¡m nyn¡ hlavn¡ iniciativn¡ch maj¡ jej¡ pracovn¡ kolektivn¡',LF
db FF
db 'Prodejn¡ balen¡ je kvalitn¡. Velkoobchodn¡ ceny jsou stano-',LF
db 'veny na £rovni cen ostatn¡ch zem¡. Pros¡m o kompletn¡ doda-',LF
db 'c¡ podm¡nky. Platebn¡ lh–ty odpov¡daj¡c¡ platebn¡ podm¡nce.',LF
db 'Exportn¡ £koly pln¡me plynule. Kolektivn¡ smlouvu jsme dnes',LF
db 'podepsali. Nesm¡me opomenout ani pracovn¡ podm¡nky. Kolekce',LF
db 'obuvi vynikaj¡c¡ tvarovou jednoduchost¡ i modern¡m pojet¡m.',LF
db FF
db 'V posledn¡m obdob¡ prudce stoupla iniciativa pracuj¡c¡ch ve',LF
db 'stroj¡renstv¡ a hutnictv¡. Na vesnic¡ch se objevuj¡ snahy o',LF
db 'urychlen¡ jarn¡ch prac¡ na pol¡ch. S r–stem kupn¡ s¡ly oby-',LF
db 'vatelstva vzroste i rozsah nab¡dky potravin. Oznamte pros¡m',LF
db 'dodac¡ podm¡nky a stanovenou prodejn¡ cenu s dan¡ i bez n¡.',LF
db 'Nam¡sto hodiny kreslen¡ byla hodina psan¡ na psac¡m stroji.',LF
db EOT

; ------ lekce 24 - ‡
;þ
LekcC24  label     byte
Lekc124  label     byte
Lekc224  label     byte
db '‡)',LF
db LF
db 'P¡smeno ‡ p¡¨eme prost©edn¡kem lev‚ ruky, kter˜ vych˜l¡me nahoru na',LF
db '‡¡selnou ©adu.',LF
db LF
db 'prost©edn¡kem lev‚ ruky  - ‡',LF
db LF
db 'Oba ukazov ‡ky p©itom mus¡ z–stat v z kladn¡ poloze!',LF
db LF
db LF
db EOT

LekcI24  label     byte
db '‡)',LF
db LF
db LF
db 'P¡smeno  ‡  p¡¨eme  pomoc¡ tzv. mrtv‚ (prefixov‚) kl vesy. Mal¡‡kem lev‚',LF
db 'ruky  stiskneme kl vesu ‡ rky `, potom stiskneme prost©edn¡kem lev‚ ruky',LF
db 'p¡smeno c.',LF
db LF
db LF
db LF
db LF
db EOT

LDatC24  label     byte
LDatI24  label     byte
LDat124  label     byte
LDat224  label     byte
db '‡‡‡‡‡‡‡ d‡d‡d‡d f‡d s‡d a‡d d‡d f‡d s‡d a‡d d‡d f‡d s‡d a‡d',LF
db 'de‡ d‡d de‡ d‡d de‡ d‡d de‡ d‡d de‡ d‡d de‡ d‡d de‡ d‡d de‡',LF
db 'd‡ed as‡edf d‡ed as‡edf d‡ed as‡edf d‡ed as‡edf d‡ed as‡edf',LF
db 'se‡ dcde‡ se‡ dcde‡ se‡ dcde‡ se‡ dcde‡ se‡ dcde‡ se‡ dcde‡',LF
db 'de‡ka se‡ka de‡ka se‡ka de‡ka se‡ka de‡ka se‡ka de‡ka se‡ka',LF
db '£‡et po‡et £‡et po‡et £‡et po‡et £‡et po‡et £‡et po‡et £‡et',LF
db '‡ad ‡dtv ‡dn¡ ‡dsa ‡id ‡ad ‡dtv ‡dn¡ ‡dsa ‡id ‡ad ‡dtv ‡dn¡',LF
db '‡ert ‡tvrt ‡ert ‡tvrt ‡ert ‡tvrt ‡ert ‡tvrt ‡ert ‡tvrt ‡ert',LF
db '‡p¡ ‡lun ‡moud ‡p¡ ‡lun ‡moud ‡p¡ ‡lun ‡moud ‡p¡ ‡lun ‡moud',LF
db FF
db 'K‡ ‡¡slo ‡innosti zahrani‡n¡ ‡len–m finan‡n¡ ‡eskou po‡¡ta‡',LF
db '‡asto po‡et organiza‡n¡ch £‡et v‡as d¡l‡¡ £‡ast¡ ur‡en¡ za‡',LF
db FF
db 'projek‡n¡ investi‡n¡m informa‡n¡ch racionaliza‡n¡ finan‡n¡m',LF
db 'investi‡n¡ celky, obchodn¡ ‡innost, podle £‡asti investor–,',LF
db '‡¡slo bankovn¡ho £‡tu, revolu‡n¡ hnut¡, posledn¡ ‡tvrtlet¡,',LF
db 'd¡l‡¡ informace, finan‡n¡ zabezpe‡en¡, pro zahrani‡n¡ £‡ast',LF
db FF
db 'Pros¡me o ur‡en¡ m¡sta placen¡. V‡as jsem objednal ‡asopis.',LF
db 'Dosavadn¡ obchodn¡ spojen¡ se vyzna‡uje oboustrannou spoko-',LF
db 'jenost¡. Na toto ‡tvrtlet¡ jsme doposud nedostali rozpo‡et.',LF
db 'V ‡ervnu dokon‡ili investi‡n¡ rozpo‡et. Celn¡ poplatky jsme',LF
db 'v‡era vy£‡tovali. Po‡et pracovn¡k– s n¡zkou kvalifikac¡ po-',LF
db 'klesl. Poznamenejte si ‡¡slo bankovn¡ho £‡tu. Mus¡me zabez-',LF
db 'pe‡it hojnou £‡ast podnikatel– na veletrhu v ‡ervenci t. r.',LF
db FF
db 'Dokon‡ili rozpo‡et firmy. Dokon‡en¡ d¡l‡¡ch akc¡ mus¡me za-',LF
db 'bezpe‡it vlastn¡mi silami. Tv–r‡¡ pracovn¡ci se vyzna‡uj¡ i',LF
db 'zna‡nou energi¡ a aktivitou. Rozpo‡et je zabezpe‡en. Jen za',LF
db 'posledn¡ch dvacet let klesl pod¡l les– o dvacetosm procent.',LF
db 'Po‡et ‡len– kolektivu stoupl. Ka‡ka si po‡kala na sv–j ‡aj.',LF
db FF
db 'Teplovodn¡ kotel je ur‡en pro sv¡tiplyn nebo zemn¡ plyn, je',LF
db 'vybaven automatikou zaru‡uj¡c¡ bezpe‡nost, vysokou £‡innost',LF
db 'a levnost provozu. Vyzna‡uje se snadnou a rychlou obsluhou,',LF
db 'vysokou spolehlivost¡ provozu a n¡zkou hlu‡nost¡. Jde o mo-',LF
db 'dern¡ kotel vynikaj¡c¡ jakosti. Je ur‡en pro zahrani‡n¡ trh',LF
db 'i tuzemsko. Kolekce vynikaj¡ tvarovou jednoduchost¡ a velmi',LF
db 'dobrou funk‡nost¡. Pro propaga‡n¡ £‡ely byly zhotoveny tyto',LF
db 'publikace, fotografie a diapozitivy. Byla zabezpe‡ena £‡ast',LF
db 'na veletrz¡ch, reklama v rozhlase, televizi a v ‡asopisech.',LF
db EOT

ENDIF

LekSeg2  ENDS
         END


; Makra KONTEXTu: SHIFT-F1 zv˜raznˆn˜ text
;                 SHIFT-F2 kl vesy s p©ek¢dov n¡m
;                 SHIFT-F3 nadpis
;                 SHIFT-F4 nadpis 2
;                 ALT-A  db ' ',LF

INCLUDE  DEF.ASM

LekSeg4  SEGMENT   BYTE PUBLIC

IFNDEF   DEMO

; ------ lekce 37 - :
;þ
LekcC37  label     byte
db ':)',LF
db LF
db 'Dvojte‡ku : p¡¨eme prav˜m  prsten¡kem  za sou‡asn‚ho stisku lev‚ kl vesy',LF
db 'SHIFT lev˜m mal¡‡kem. V textu dvojte‡ku p¡¨eme tˆsnˆ za posledn¡ p¡smeno',LF
db 'bez mezery, mezeru dˆl me a‘ za dvojte‡kou.',LF
db LF
db 'prsten¡kem prav‚ ruky  - :',LF
db LF
db LF
db LF
db EOT

LekcI37  label     byte
Lekc137  label     byte
Lekc237  label     byte
db ':)',LF
db LF
db 'Dvojte‡ku  :  p¡¨eme prav˜m  mal¡‡kem  za sou‡asn‚ho stisku lev‚ kl vesy',LF
db 'SHIFT lev˜m mal¡‡kem. V textu dvojte‡ku p¡¨eme tˆsnˆ za posledn¡ p¡smeno',LF
db 'bez mezery, mezeru dˆl me a‘ za dvojte‡kou.',LF
db LF
db 'mal¡‡kem prav‚ ruky  - :',LF
db LF
db LF
db LF
db EOT

LDatC37  label     byte
LDatI37  label     byte
LDat137  label     byte
LDat237  label     byte
db ':::::::: l:l:l:l:l:l:l .:.:.:.:.:.:. dˆl: psal: ©ekl: a to:',LF
db 'pravili: ©ekli: takto: jestli‘e: uveden˜ch: Jsou to: podle:',LF
db FF
db 'P©i ©e¨en¡ ot zek m  mistr k dispozici prost©edky, jimi‘ se',LF
db 'vyzna‡uje jeho styl ©¡zen¡. Jsou to:',LF
db 'z hlediska komunikace: kontakt, dotaz, informace, pou‡en¡,',LF
db 'z hlediska stimulace: pochvala, uzn n¡, odmˆna,',LF
db 'z hlediska n pravy: rada, pomoc, p©¡klad, domluva, v˜tka.',LF
db EOT

; ------ lekce 38 ()/
;þ
LekcC38  label     byte
db '()/)',LF
db LF
db 'Kulat‚ z vorky ( a ) p¡¨eme  prav˜m  mal¡‡kem, p©edn¡ z vorku ( s pomoc¡',LF
db 'lev‚  kl vesy  SHIFT. Lom¡tko / p¡¨eme mal¡‡kem prav‚ ruky, tak‚ s levou',LF
db 'kl vesou  SHIFT. V textu p©imyk  p©edn¡ z vorka ( k n sleduj¡c¡mu slovu,',LF
db 'zadn¡  z vorka  )  p©imyk  k p©edch zej¡c¡mu slovu (tj. ke slov–m, kter ',LF
db 'uvozuj¡).  P©ed  p©edn¡  i  za  zadn¡  z vorkou  je mezera. Interpunk‡n¡',LF
db 'znam‚nka za z vorkou se p¡¨¡ bez mezery. Tot‚‘ plat¡ p©i pou‘it¡ lom¡tka',LF
db '/ jako z vorky.',LF
db LF
db EOT

LekcI38  label     byte
Lekc138  label     byte
Lekc238  label     byte
db '()/)',LF
db LF
db 'Levou  kulatou  z vorku  ( p¡¨eme prav˜m prost©edn¡kem, pravou z vorku )',LF
db 'prav˜m  prsten¡kem,  v  obou p©¡padech za sou‡asn‚ho stisku lev‚ kl vesy',LF
db 'SHIFT  lev˜m  mal¡‡kem.  Lom¡tko  /  p¡¨eme mal¡‡kem prav‚ ruky. V textu',LF
db 'p©imyk   p©edn¡ z vorka ( k n sleduj¡c¡mu slovu, zadn¡ z vorka ) p©imyk ',LF
db 'k  p©edch zej¡c¡mu  slovu (tj. p©imykaj¡ ke slov–m, kter  uvozuj¡). P©ed',LF
db 'p©edn¡  i za zadn¡ z vorkou je mezera. Interpunk‡n¡ znam‚nka za z vorkou',LF
db 'se p¡¨¡ bez mezery. Tot‚‘ plat¡ i p©i pou‘it¡ lom¡tka / jako z vorky.',LF
db LF
db EOT

LDatC38  label     byte
LDatI38  label     byte
LDat138  label     byte
LDat238  label     byte
db '(((((()))))) ////// ()()()()() –£)–£)–£)–£)–£) –/(–/(–/(–/(',LF
db '(–) £–/ (–) £–/ (–) £–/ (–) £–/ (–) £–/ (–) £–/ (–) £–/ (–)',LF
db 'pomˆr (v procentech), rychlost (km/h), delta b/a (nebo c/d)',LF
db 'min/max (mil. kus–). km/h. m/s. a/b, U/R, delta b/a, PA/PB,',LF
db FF
db 'Stejnˆ s r–stem ‘ivotn¡ £rovnˆ se zvy¨uj¡ i d©¡ve vypl cen‚',LF
db '(d©¡ve p©iznan‚) d–chody. Zahrani‡nˆ obchodn¡ ‡innost zahr-',LF
db 'nuje t‚‘ p©epravov n¡ vˆc¡ (z silek) v¨emi druhy dopravn¡ch',LF
db 'prost©edk–. U opakuj¡c¡ch se pracovn¡ch ‡innost¡ je obvykl‚',LF
db 'stanovit z kladn¡ (tarifn¡) sazby za jistou ‡asovou jednot-',LF
db 'ku (hodinu, mˆs¡c) nebo za fyzickou jednotku (kus–, metr–).',LF
db FF
db 'Rozdˆlen¡:',LF
db 'a) sn¡mac¡ stroje,',LF
db 'b) pr–tiskov‚ stroje,',LF
db 'c) ofsetov‚ stroje.',LF
db FF
db 'Z kladn¡ doklady v technick‚ p©¡pravˆ v˜roby jsou: v˜kresov ',LF
db 'dokumentace, technologick‚ rozpisy (rozpisky d¡l–), kompletn¡',LF
db 'technick‚ postupy a programov  dokumentace (programov˜ list,',LF
db 'v˜pis programu, n ‡rt dr hy n stroje, ©ezn˜ pl n).',LF
db 'Vedle z kladn¡ch jednotek nebo jejich n sobk– a d¡l– je z prak-',LF
db 'tick˜ch d–vod– povoleno pou‘¡vat i n sleduj¡c¡ch vedlej¨¡ch',LF
db 'jednotek: pro ‡as - minuta (min), hodina (h), den (d), pro plo¨-',LF
db 'n˜ obsah - hektar (ha), pro hmotnost - tuna (t).',LF
db 'V polo‘ce n klad– na propagaci se sleduj¡ zejm‚na n klady na:',LF
db '- zhotoven¡ a po©¡zen¡ propaga‡n¡ch p©edmˆt–, kter‚ maj¡ cha-',LF
db '  rakter u‘itn˜ch p©edmˆt– (plakety, odznaky, vlaje‡ky atd.),',LF
db '  u‘itn˜mi p©edmˆty jsou v¨echny p©edmˆty, kter‚ uspokojuj¡',LF
db '  osobn¡ pot©eby jednotlivc– a kolektiv–, nap©. kalend ©e (s v˜-',LF
db '  jimkou jednolistov˜ch), di ©e, televizory, chladni‡ky, roz-',LF
db '  hlasov‚ p©ij¡ma‡e, umˆleck‚ p©edmˆty apod.,',LF
db '- poskytov n¡ propaga‡n¡ch a d rkov˜ch p©edmˆt– (v‡etnˆ kalen-',LF
db '  d ©– a di ©–) pro zahrani‡n¡ odbˆratele a obchodn¡ z stupce',LF
db '  p©i prov dˆn¡ propaga‡n¡ ‡innosti v zahrani‡n¡m obchodˆ v‡etnˆ',LF
db '  n klad– na jejich adjustaci (t˜k  se pouze OZO nebo organizac¡',LF
db '  povˆ©en˜ch prov dˆn¡m zahrani‡nˆ obchodn¡ ‡innosti),',LF
db '- propagaci v˜kupn¡ ‡innosti jednotliv˜ch organizac¡ povˆ©en˜ch',LF
db '  v˜kupem (nap©. propagace v˜kupu odpadov˜ch surovin, ovoce,',LF
db '  lesn¡ch plodin apod.).',LF
db 'Mzdy poskytovan‚ na z kladˆ pracovn¡ho pomˆru zahrnuj¡:',LF
db 'a) z kladn¡ mzdy (‡asov‚ mzdy v‡etnˆ osobn¡ch plat–, £kolov‚',LF
db '   mzdy, pod¡lov‚ mzdy, sm¡¨en‚ mzdy),',LF
db 'b) p©¡platky a doplatky ke mzdˆ a jin  obdobn  plnˆn¡,',LF
db 'c) osobn¡ ohodnocen¡,',LF
db 'd) pr‚mie a odmˆny (v˜konnostn¡ a mimo© dn‚ odmˆny, penˆ‘it‚',LF
db '   odmˆny za v˜sledky dosa‘en‚ na z kladˆ rozvoje iniciativy',LF
db '   pracuj¡c¡ch a jin‚ druhy odmˆn podle zvl ¨tn¡ch p©edpis–),',LF
db 'e) pod¡ly na hospod ©sk˜ch v˜sledc¡ch,',LF
db 'f) natur ln¡ po‘itky, kter‚ se poskytuj¡ jako sou‡ st mzdy,',LF
db '   pop©¡padˆ penˆ‘it‚ n hrady za nˆ.',LF
db EOT

; ------ lekce 39 "
;þ
LekcC39  label     byte
LekcI39  label     byte
Lekc139  label     byte
Lekc239  label     byte
db '")',LF
db LF
db 'Uvozovky " p¡¨eme  prav˜m  mal¡‡kem  pomoc¡ lev‚ kl vesy SHIFT. Uvozovky',LF
db 'v‘dy p©imykaj¡ ke slov–m, kter  uvozuj¡ (obdobnˆ jako z vorky). Uvozovky',LF
db 'pou‘¡v me t‚‘ ve v˜znamu tzv. stejn¡tek. Jsou to znam‚nka, kter  uv d¡me',LF
db 'pro  opakov n¡  t‚ho‘  slova  na  dal¨¡m © dku. P¡¨eme je v‘dy pod prvn¡',LF
db 'p¡smeno opakovan‚ho v˜razu. Opakovan  ‡¡sla v‘dy vypisujeme.',LF
db LF
db 'mal¡‡kem prav‚ ruky  - "',LF
db LF
db EOT

LDatC39  label     byte
db '"""""" –"–"–"–"–"–"– "j–" "j‚" "j–" "j‚" "j–" "j‚" "Dru‘ba"',LF
db FF
db 'Semin © "Metody ©¡zen¡" uk zal sou‡asn˜ stav pozn n¡ o ©¡zen¡.',LF
db 'Nejde v–bec o nˆjakou kampa¤ "jak proj¡t zimu", ale o dlouho-',LF
db 'dobou koncep‡n¡ ‡innost s c¡lem zabezpe‡it plynul‚ z sobov n¡',LF
db 'palivy a elektrickou energi¡. V˜sledkem jsou nov‚ vˆdn¡ obory,',LF
db '‡asto ozna‡ovan‚ jako "mezn¡" ‡i "hrani‡n¡", jako je geochemie,',LF
db 'bionika atd. Prvky jednotn‚ £dajov‚ z kladny organizac¡ (d le',LF
db 'jen "£dajov  z kladna").',LF
db FF
db 'Vyhl ¨ka upravuje:',LF
db 'a) postup p©i hodnocen¡ technick‚ £rovnˆ v˜robk– a vymezuje',LF
db '   okruh v˜robk– podl‚haj¡c¡ch tomuto hodnocen¡,',LF
db 'b) n le‘itost ‘ dosti pro £‡ely hodnocen¡,',LF
db 'c) lh–ty technicko-ekonomick‚ ‘ivotnosti v˜robk– a stanov¡',LF
db '   okruh v˜robk–, na kter˜ se vztahuj¡.',LF
db EOT

LDatI39  label     byte
LDat139  label     byte
LDat239  label     byte
db '"""""" ;";";";";";"; "jo" "je" "ji" "jo" "je" "ji" "Dru‘ba"',LF
db FF
db 'Semin © "Metody ©¡zen¡" uk zal sou‡asn˜ stav pozn n¡ o ©¡zen¡.',LF
db 'Nejde v–bec o nˆjakou kampa¤ "jak proj¡t zimu", ale o dlouho-',LF
db 'dobou koncep‡n¡ ‡innost s c¡lem zabezpe‡it plynul‚ z sobov n¡',LF
db 'palivy a elektrickou energi¡. V˜sledkem jsou nov‚ vˆdn¡ obory,',LF
db '‡asto ozna‡ovan‚ jako "mezn¡" ‡i "hrani‡n¡", jako je geochemie,',LF
db 'bionika atd. Prvky jednotn‚ £dajov‚ z kladny organizac¡ (d le',LF
db 'jen "£dajov  z kladna").',LF
db FF
db 'Vyhl ¨ka upravuje:',LF
db 'a) postup p©i hodnocen¡ technick‚ £rovnˆ v˜robk– a vymezuje',LF
db '   okruh v˜robk– podl‚haj¡c¡ch tomuto hodnocen¡,',LF
db 'b) n le‘itost ‘ dosti pro £‡ely hodnocen¡,',LF
db 'c) lh–ty technicko-ekonomick‚ ‘ivotnosti v˜robk– a stanov¡',LF
db '   okruh v˜robk–, na kter˜ se vztahuj¡.',LF
db EOT

; ------ lekce 40 _
;þ
LekcC40  label     byte
LekcI40  label     byte
Lekc140  label     byte
Lekc240  label     byte
db '_)',LF
db LF
db 'Podtr‘¡tko _ p¡¨eme prav˜m mal¡‡kem za sou‡asn‚ho stisknut¡ lev‚ kl vesy',LF
db 'SHIFT.  Na kl vesnici psac¡ho stroje se tento znak pou‘¡v  k podtrh v n¡',LF
db 'textu  souvislou  ‡arou.  U  po‡¡ta‡–  se  v¨ak jedn  o samostatn˜ znak.',LF
db 'Pou‘¡v  se p©edev¨¡m jako n hrada za mezeru uvnit© textov˜ch ©etˆzc–, ve',LF
db 'kter˜ch nesmˆj¡ b˜t pou‘ity mezery (nap©. jm‚na procedur v programech).',LF
db LF
db 'mal¡‡kem prav‚ ruky  - _',LF
db LF
db EOT

LDatC40  label     byte
LDatI40  label     byte
LDat140  label     byte
LDat240  label     byte
db '_ _ _ _ a_b_c_d_e_ tento_text_neobsahuje_ani_jednu_mezeru_!',LF
db 'max_row, open_buf, read_string, jm‚no_souboru, adresa_skoku',LF
db EOT

; ------ lekce 41 58­
;þ
LekcC41  label     byte
db '58­)',LF
db '€¡slici 5 p¡¨eme lev˜m ukazov ‡kem s pomoc¡ prav‚ kl vesy SHIFT.',LF
db '€¡slici 8 p¡¨eme prav˜m ukazov ‡kem s pomoc¡ lev‚ kl vesy SHIFT.',LF
db 'Paragraf ­ p¡¨eme prav˜m mal¡‡kem. M  se pou‘¡vat jen ve spojen¡',LF
db 's ‡¡slem (nap©. ­ 28), jinak se vypisuje slovem.',LF
db LF
db ' ukazov ‡kem lev‚ ruky  - 5',LF
db 'ukazov ‡kem prav‚ ruky  - 8',LF
db '   mal¡‡kem prav‚ ruky  - ­',LF
db LF
db EOT

Lekc141  label     byte
db '58­)',LF
db '€¡slice 5 a 8 p¡¨eme buƒ v numerick‚m poli kl vesnice (zapnout Num Lock)',LF
db 'nebo  stiskem  mrtv‚ kl vesy ` a potom kl vesy © resp.  . Druhou mo‘nost',LF
db 'nepodporuj¡ v¨echny ovlada‡e ‡esk‚ kl vesnice. Znak paragrafu ­ zap¡¨eme',LF
db 'stiskem  mrtv‚  kl vesy  ` a potom kl vesy zpˆtn‚ho lom¡tka \. V p©¡padˆ',LF
db 'nutnosti  (nap©. ovlada‡ kl vesnice tento znak neobsluhuje) lze k z pisu',LF
db 'znaku  paragrafu  pou‘¡t tuto metodu: lev˜m mal¡‡kem se stiskne (a dr‘¡)',LF
db 'lev   kl vesa ALT, na numerick‚ kl vesnici se zap¡¨e ‡¡slo 173 a kl vesa',LF
db 'ALT  se  uvoln¡.  Znak  paragrafu se m  pou‘¡vat jen ve spojen¡ s ‡¡slem',LF
db '(nap©. ­ 28), jinak se vypisuje slovem.',LF
db EOT

Lekc241  label     byte
db '58­)',LF
db '€¡slice 5 a 8 p¡¨eme buƒ v numerick‚m poli kl vesnice (zapnout Num Lock)',LF
db 'nebo  stiskem  mrtv‚ kl vesy ',39,' a potom kl vesy © resp.  . Druhou mo‘nost',LF
db 'nepodporuj¡ v¨echny ovlada‡e ‡esk‚ kl vesnice. Znak paragrafu ­ zap¡¨eme',LF
db 'stiskem  mrtv‚  kl vesy  ',39,' a potom kl vesy zpˆtn‚ho lom¡tka \. V p©¡padˆ',LF
db 'nutnosti  (nap©. ovlada‡ kl vesnice tento znak neobsluhuje) lze k z pisu',LF
db 'znaku  paragrafu  pou‘¡t tuto metodu: lev˜m mal¡‡kem se stiskne (a dr‘¡)',LF
db 'lev   kl vesa ALT, na numerick‚ kl vesnici se zap¡¨e ‡¡slo 173 a kl vesa',LF
db 'ALT  se  uvoln¡.  Znak  paragrafu se m  pou‘¡vat jen ve spojen¡ s ‡¡slem',LF
db '(nap©. ­ 28), jinak se vypisuje slovem.',LF
db EOT

LekcI41  label     byte
db '58­)',LF
db '€¡slici  5  p¡¨eme lev˜m ukazov ‡kem vych˜len¡m na ‡¡selnou ©adu kl ves.',LF
db '€¡slici  8 p¡¨eme prav˜m ukazov ‡kem vych˜len¡m na ‡¡selnou ©adu kl ves.',LF
db 'Znak  paragrafu  ­  zap¡¨eme  stiskem  mrtv‚  kl vesy  ` a potom kl vesy',LF
db 'zpˆtn‚ho  lom¡tka  \. V p©¡padˆ nutnosti (nap©. ovlada‡ kl vesnice tento',LF
db 'znak neobsluhuje) lze k z pisu znaku paragrafu pou‘¡t tuto metodu: lev˜m',LF
db 'mal¡‡kem  se  stiskne (a dr‘¡) lev  kl vesa ALT, na numerick‚ kl vesnici',LF
db 'se  zap¡¨e  ‡¡slo  173  a  kl vesa  ALT  se uvoln¡. Znak paragrafu se m ',LF
db 'pou‘¡vat jen ve spojen¡ s ‡¡slem (nap©. ­ 28), jinak se vypisuje slovem.',LF
db LF
db EOT

LDatC41  label     byte
LDatI41  label     byte
LDat141  label     byte
LDat241  label     byte
db '55555 88888 ­­­­­ f5f5f5f j8j8j8j –­–­–­– fr5tf ju8zj –­–­–',LF
db '5 fjk– 55 fjk– 5 fjk– 55 fjk– 5 fjk– 55 fjk– 5 fjk– 55 fjk–',LF
db '8 jfda 8 jfda 88 jfda 88 jfda 8 jfda 8 jfda 88 jfda 88 jfda',LF
db '5 film–, 55 filtr–, 5 forem, 55 filtr–, 5 forem, 55 filtr–,',LF
db '8 jehel, 88 jednotek, 8 j¡del, 8 jehel, 8 jakost¡, 8 jehel,',LF
db FF
db 'Zatelefonujte, zda byste mohli dodat 5 filtr– do 5. ‡ervna.',LF
db 'Do konce listopadu p©edaj¡ do u‘¡v n¡ 88 bytov˜ch jednotek.',LF
db '885 fotografi¡, 855 m flanelu, 558 jednotek, 58 tun jetele.',LF
db '’ ci na¨¡ ¨koly odevzdali v tomto ‡tvrtlet¡ do sbˆru 855 kg',LF
db 'pap¡ru, 588 kg star‚ho ‘eleza a t‚‘ 85 kg ne‘elezn˜ch kov–.',LF
db '’ d m, abyste do 8 dn– uhradili dlu‘nou ‡ stku K‡ 8 858,--.',LF
db 'Dosud jste nezaplatili n jemn‚ K‡ 588,-- za mˆs¡c listopad.',LF
db '­ 55, ­ 88, v ­ 85 ods. 5 p¡sm. b/, v ­ 88 odst. 5 p¡sm. a/',LF
db EOT

; ------ lekce 42 49%
;þ
LekcC42  label     byte
db '49%)',LF
db LF
db '€¡slici 4 p¡¨eme lev˜m prost©edn¡kem  s pomoc¡ prav‚ kl vesy SHIFT.',LF
db '€¡slici 9 p¡¨eme prav˜m prost©edn¡kem  s pomoc¡ lev‚ kl vesy SHIFT.',LF
db 'Znak procenta % p¡¨eme prav˜m mal¡‡kem s pomoc¡ lev‚ kl vesy SHIFT.',LF
db LF
db ' prost©edn¡kem lev‚ ruky  - 4',LF
db 'prost©edn¡kem prav‚ ruky  - 9',LF
db '     mal¡‡kem prav‚ ruky  - %',LF
db LF
db EOT

LekcI42  label     byte
db '49%)',LF
db '€¡slici 4 p¡¨eme lev˜m prost©edn¡kem vych˜len¡m na ‡¡selnou ©adu kl ves.',LF
db '€¡slici  9  p¡¨eme  prav˜m  prost©edn¡kem  vych˜len¡m  na  ‡¡selnou ©adu',LF
db 'kl ves.  Znak  procenta  %  p¡¨eme  lev˜m  ukazov ‡kem  s  pomoc¡  prav‚',LF
db 'kl vesy SHIFT.',LF
db LF
db ' prost©edn¡kem lev‚ ruky  - 4',LF
db 'prost©edn¡kem prav‚ ruky  - 9',LF
db '   ukazov ‡kem lev‚ ruky  - %',LF
db LF
db EOT

Lekc142  label     byte
db '49%)',LF
db LF
db '€¡slice 4 a 9 p¡¨eme buƒ v numerick‚m poli kl vesnice (zapnout Num Lock)',LF
db 'nebo  stiskem  mrtv‚ kl vesy ` a potom kl vesy ‡ resp. ¡. Druhou mo‘nost',LF
db 'nepodporuj¡  v¨echny  ovlada‡e  ‡esk‚ kl vesnice. Znak procenta % p¡¨eme',LF
db 'lev˜m ukazov ‡kem s pomoc¡ prav‚ kl vesy SHIFT.',LF
db LF
db LF
db LF
db LF
db EOT

Lekc242  label     byte
db '49%)',LF
db LF
db '€¡slice 4 a 9 p¡¨eme buƒ v numerick‚m poli kl vesnice (zapnout Num Lock)',LF
db 'nebo  stiskem  mrtv‚ kl vesy ',39,' a potom kl vesy ‡ resp. ¡. Druhou mo‘nost',LF
db 'nepodporuj¡  v¨echny  ovlada‡e  ‡esk‚ kl vesnice. Znak procenta % p¡¨eme',LF
db 'lev˜m ukazov ‡kem s pomoc¡ prav‚ kl vesy SHIFT.',LF
db LF
db LF
db LF
db LF
db EOT

LDatC42  label     byte
LDatI42  label     byte
LDat142  label     byte
LDat242  label     byte
db '444444 999999 %%%%%% d4d4d4d k9k9k9k –%–%–%– de4d ki9k –p%£',LF
db '4 dfl– 44 dfl– 4 dfl– 44 dfl– 4 dfl– 44 dfl– 4 dfl– 44 dfl–',LF
db '9 kfja 9 kfja 99 kfja 99 kfja 9 kfja 9 kfja 99 kfja 99 kfja',LF
db 'asj– % asj– % asj– % asj– %, 89 %, 98 %, 444 %, 59 %, 54 %,',LF
db '44 druh–, 44 d¡l–, 44 defekt–, 44 druh–, 44 d¡l–, 44 d rc–,',LF
db '9 kolektiv–, 9 kolekc¡, 99 kart¢n–, 99 kg cukru, 99 kart¢n–',LF
db '94 % zamˆstnanc– jsou ‘eny. Pl nujeme zv˜¨en¡ obratu o 4 %.',LF
db FF
db 'Z¡skali 44 dobrovoln˜ch d rc– krve. Nab¡zeli 4 druhy l tek.',LF
db 'Dostali 4 d¡ly slovn¡ku. Zakoupili 44 vstupenek do divadla.',LF
db 'Soutˆ‘e se z£‡astnilo 9 student–. Na filmov‚m festivalu by-',LF
db 'lo prom¡tnuto 99 film–. Objednali jsme pro knihovnu 9 knih.',LF
db 'Konference se z£‡astnilo 94 deleg t–. Velkoobchodu bylo na-',LF
db 'b¡dnuto 494 kolekc¡ l tek. Vzd lenost 499 km ujeli za 9 ho-',LF
db 'din. Na¨e v˜stupn¡ kontrola zjistila 58 defektn¡ch odlitk–.',LF
db 'Obdr‘eli jsme z silku 954 sud– a z toho bylo 9 % po¨kozeno.',LF
db FF
db 'V uplynul‚m obdob¡ se v na¨em z vodˆ zv˜¨ila bezpe‡nost a',LF
db 'hygiena pr ce proveden¡m tˆchto opat©en¡: bylo zdokonaleno',LF
db 'ods v n¡ a odvoz prachu z tryskov‚ho boxu st©ediska 45, byla',LF
db 'provedena rekonstrukce a modernizace z suvek ve st©edisku 48',LF
db 'a nyn¡ se pracuje na rekonstrukci osvˆtlen¡ ve st©edisku 49.',LF
db EOT

; ------ lekce 43 38
;þ
LekcC43  label     byte
db '30;)',LF
db '€¡slici  3  p¡¨eme  lev˜m  prsten¡kem  s  pomoc¡  prav‚  kl vesy  SHIFT.',LF
db '€¡slici  0  p¡¨eme  prav˜m  prsten¡kem  s  pomoc¡  lev‚  kl vesy  SHIFT.',LF
db 'Znak  ;  (st©edn¡k)  zap¡¨eme lev˜m mal¡‡kem vych˜len¡m na ‡¡selnou ©adu',LF
db 'kl ves  £plnˆ  vlevo  za  sou‡asn‚ho  stisku  prav‚ kl vesy SHIFT. Jinou',LF
db 'mo‘nost¡  je  stisk  mrtv‚  kl vesy  ',39,' a pak kl vesy – (tj. vygenerov n¡',LF
db 'p–vodn¡ho  znaku kl vesnice). V nutn‚m p©¡padˆ (pokud ovlada‡ kl vesnice',LF
db 'tento znak nepodporuje) lze pou‘¡t tuto metodu: lev˜m mal¡‡kem stisknout',LF
db '(a  dr‘et) levou  kl vesu ALT, na numerick‚ kl vesnici zapsat ‡¡slo 59 a',LF
db 'pot‚ kl vesu ALT uvolnit.',LF
db EOT

LekcI43  label     byte
db '30)',LF
db LF
db '€¡slici  3  p¡¨eme  lev˜m prsten¡kem vych˜len¡m na ‡¡selnou ©adu kl ves.',LF
db '€¡slici  0  p¡¨eme prav˜m prsten¡kem vych˜len¡m na ‡¡selnou ©adu kl ves.',LF
db LF
db ' prsten¡kem lev‚ ruky  - 3',LF
db 'prsten¡kem prav‚ ruky  - 0',LF
db LF
db LF
db LF
db EOT

Lekc143  label     byte
db '30)',LF
db LF
db LF
db '€¡slice 3 a 0 p¡¨eme buƒ v numerick‚m poli kl vesnice (zapnout Num Lock)',LF
db 'nebo  stiskem  mrtv‚ kl vesy ` a potom kl vesy ¨ resp. ‚. Druhou mo‘nost',LF
db 'nepodporuj¡ v¨echny ovlada‡e ‡esk‚ kl vesnice.',LF
db LF
db LF
db LF
db LF
db EOT

Lekc243  label     byte
db '30)',LF
db LF
db LF
db '€¡slice 3 a 0 p¡¨eme buƒ v numerick‚m poli kl vesnice (zapnout Num Lock)',LF
db 'nebo  stiskem  mrtv‚ kl vesy ',39,' a potom kl vesy ¨ resp. ‚. Druhou mo‘nost',LF
db 'nepodporuj¡ v¨echny ovlada‡e ‡esk‚ kl vesnice.',LF
db LF
db LF
db LF
db LF
db EOT

LDatC43  label     byte
db '33333333 00000000 ;;;;;;; s3s3s3s3s l0l0l0l0l sw3sw3 lo0lo0',LF
db '3 sdf– 33 sdf– 3 sdf– 33 sdf– 3 sdf– 33 sdf– 3 sdf– 33 sdf–',LF
db '0 lkja 0 lkja 0 lkja 000 lkja 0 lkja 0 lkja 0 lkja 000 lkja',LF
db '33 sklad–, 333 stol–, 333 stroj–, 33 soustruh–, 33 sektor–,',LF
db '300 kolektiv–; 300 legitimac¡; 30 letenek; 330 lahv¡ oleje;',LF
db FF
db 'Dne 3. £nora t. r. jsme u V s objednali 33 stol– pro ¨koln¡',LF
db 'j¡delnu. V na¨¡ ¨kole byly letos z©¡zeny 3 nov‚ laborato©e.',LF
db 'Svaz ochr nc– p©¡rody v Mostˆ z¡skal letos 300 nov˜ch ‡len–.',LF
db 'Na svaz¡ch hor vys zeli ochr nci p©¡rody 3 000 smrk– a boro-',LF
db 'vic. 3000 tˆchto mlad˜ch stromk– tak p©ispˆje k obnovˆ les–.',LF
db 'Na 8.30 h byla svol na porada vedouc¡ch hospod ©sk˜ch pracov-',LF
db 'n¡k– a energetik–. Vedouc¡ branku fotbalov‚ho z pasu vst©elil',LF
db 'v 30. min st©edn¡ £to‡n¡k. V 8.00 h odj¡‘d¡ rychl¡k do Plznˆ.',LF
db FF
db 'Les nen¡ jen zdrojem d©eva, ale m  pro spole‡nost mnohostran-',LF
db 'n˜ v˜znam. Pln¡ nap©. funkci p–dn¡ ochrany, vodohospod ©skou i',LF
db 'rekrea‡n¡. Progn¢za lesa je v¨ak neradostn . Hlavn¡m negativ-',LF
db 'n¡m ‡initelem lesn¡ho hospod ©stv¡ jsou emise a spad ¨kodlivin,',LF
db 'zejm‚na slou‡enin s¡ry, dus¡ku, flu¢ru, chl¢ru, tˆ‘k˜ch kov–,',LF
db 'uhlovod¡ku a pop¡lku. Tyto ¨kodliviny po¨kozuj¡ asimila‡n¡ or-',LF
db 'g ny lesn¡ch d©evin. P©i prvn¡m stupni po¨kozen¡ lesa klesaj¡',LF
db 'p©¡r–stky d©eva o 30 procent, p©i druh‚m stupni ji‘ o 50 pro-',LF
db 'cent, p©i t©et¡m o 80 procent a p©i ‡tvrt‚m stromy odum¡raj¡.',LF
db 'Je t©eba sn¡‘it toxicitu a objem emis¡ nejm‚nˆ o 50 procent.',LF
db EOT

LDatI43  label     byte
LDat143  label     byte
LDat243  label     byte
db '33333333 00000000 s3s3s3s3s l0l0l0l0l sw3sw3sw3s lo0lo0lo0l',LF
db '3 sdf– 33 sdf– 3 sdf– 33 sdf– 3 sdf– 33 sdf– 3 sdf– 33 sdf–',LF
db '0 lkja 0 lkja 0 lkja 000 lkja 0 lkja 0 lkja 0 lkja 000 lkja',LF
db '33 sklad–, 333 stol–, 333 stroj–, 33 soustruh–, 33 sektor–,',LF
db '300 kolektiv–, 300 legitimac¡, 30 letenek, 330 lahv¡ oleje,',LF
db FF
db 'Dne 3. £nora t. r. jsme u V s objednali 33 stol– pro ¨koln¡',LF
db 'j¡delnu. V na¨¡ ¨kole byly letos z©¡zeny 3 nov‚ laborato©e.',LF
db 'Svaz ochr nc– p©¡rody v Mostˆ z¡skal letos 300 nov˜ch ‡len–.',LF
db 'Na svaz¡ch hor vys zeli ochr nci p©¡rody 3 000 smrk– a boro-',LF
db 'vic. 3000 tˆchto mlad˜ch stromk– tak p©ispˆje k obnovˆ les–.',LF
db 'Na 8.30 h byla svol na porada vedouc¡ch hospod ©sk˜ch pracov-',LF
db 'n¡k– a energetik–. Vedouc¡ branku fotbalov‚ho z pasu vst©elil',LF
db 'v 30. min st©edn¡ £to‡n¡k. V 8.00 h odj¡‘d¡ rychl¡k do Plznˆ.',LF
db FF
db 'Les nen¡ jen zdrojem d©eva, ale m  pro spole‡nost mnohostran-',LF
db 'n˜ v˜znam. Pln¡ nap©. funkci p–dn¡ ochrany, vodohospod ©skou i',LF
db 'rekrea‡n¡. Progn¢za lesa je v¨ak neradostn . Hlavn¡m negativ-',LF
db 'n¡m ‡initelem lesn¡ho hospod ©stv¡ jsou emise a spad ¨kodlivin,',LF
db 'zejm‚na slou‡enin s¡ry, dus¡ku, flu¢ru, chl¢ru, tˆ‘k˜ch kov–,',LF
db 'uhlovod¡ku a pop¡lku. Tyto ¨kodliviny po¨kozuj¡ asimila‡n¡ or-',LF
db 'g ny lesn¡ch d©evin. P©i prvn¡m stupni po¨kozen¡ lesa klesaj¡',LF
db 'p©¡r–stky d©eva o 30 procent, p©i druh‚m stupni ji‘ o 50 pro-',LF
db 'cent, p©i t©et¡m o 80 procent a p©i ‡tvrt‚m stromy odum¡raj¡.',LF
db 'Je t©eba sn¡‘it toxicitu a objem emis¡ nejm‚nˆ o 50 procent.',LF
db EOT

; ------ lekce 44 1+=
;þ
LekcC44  label     byte
db '1+=)',LF
db LF
db '€¡slici 1 p¡¨eme lev˜m mal¡‡kem s pomoc¡ prav‚ kl vesy SHIFT.',LF
db 'Znak + p¡¨eme lev˜m mal¡‡kem, znak = prav˜m mal¡‡kem.',LF
db LF
db ' mal¡‡kem lev‚ ruky  - 1',LF
db ' mal¡‡kem lev‚ ruky  - +',LF
db 'mal¡‡kem prav‚ ruky  - =',LF
db LF
db LF
db EOT

LekcI44  label     byte
db '1+=)',LF
db LF
db '€¡slici  1  p¡¨eme  lev˜m  mal¡‡kem  vych˜len¡m na ‡¡selnou ©adu kl ves.',LF
db 'Znak  +  p¡¨eme prav˜m mal¡‡kem za sou‡asn‚ho stisku lev‚ kl vesy SHIFT.',LF
db 'Znak = p¡¨eme prav˜m mal¡‡kem vych˜len¡m na ‡¡selnou ©adu kl ves vpravo.',LF
db LF
db ' mal¡‡kem lev‚ ruky  - 1',LF
db 'mal¡‡kem prav‚ ruky  - +',LF
db 'mal¡‡kem prav‚ ruky  - =',LF
db LF
db EOT

Lekc144  label     byte
db '1+=)',LF
db LF
db '€¡slici  1  p¡¨eme  buƒ  v numerick‚m poli kl vesnice (zapnout Num Lock)',LF
db 'nebo  stiskem  mrtv‚  kl vesy  `  a  potom  kl vesy  –.  Druhou  mo‘nost',LF
db 'nepodporuj¡  v¨echny  ovlada‡e  ‡esk‚  kl vesnice.  Znak + p¡¨eme prav˜m',LF
db 'mal¡‡kem  za  sou‡asn‚ho stisku lev‚ kl vesy SHIFT. Znak = p¡¨eme prav˜m',LF
db 'mal¡‡kem vych˜len¡m na ‡¡selnou ©adu kl ves vpravo.',LF
db LF
db LF
db LF
db EOT

Lekc244  label     byte
db '1+=)',LF
db '€¡slici  1  p¡¨eme  buƒ  v numerick‚m poli kl vesnice (zapnout Num Lock)',LF
db 'nebo  stiskem  mrtv‚  kl vesy  ',39,'  a  potom  kl vesy  +.  Druhou  mo‘nost',LF
db 'nepodporuj¡  v¨echny  ovlada‡e  ‡esk‚  kl vesnice.  Znak  + p¡¨eme lev˜m',LF
db 'mal¡‡kem  vych˜len¡m na ‡¡selnou ©adu kl ves vlevo. Znak = p¡¨eme dvoj¡m',LF
db 'stiskem mrtv‚ kl vesy ',39,' (tj. vygeneruje se p–vodn¡ znak IBM kl vesnice).',LF
db 'V nutn‚m p©¡padˆ (pokud ovlada‡ ‡esk‚ kl vesnice tento znak nepodporuje)',LF
db 'lze pou‘¡t metodu s ALT: lev˜m mal¡‡kem se stiskne (a dr‘¡) lev  kl vesa',LF
db 'ALT, na numerick‚ kl vesnici se zap¡¨e ‡¡slo 61 a kl vesa ALT se uvoln¡.',LF
db LF
db EOT

LDatC44  label     byte
LDatI44  label     byte
LDat144  label     byte
LDat244  label     byte
db '11111111 ++++++++ ======== aq+1aq+1aq+1 –p=–p=–p= –p‚–p=–p‚',LF
db '1 afj– 1 afj– 11 afj– 11 afj– 1 afj– 1 afj– 11 afj– 11 afj–',LF
db '11 adres, 11 autokar–, 1 akumul tor, 11 automobil–, 1 mapa,',LF
db '11 + 3 = 14, 19 - 1 = 18, 349 + 151 = 500',LF
db '3 x 13 = 39, 5 . 11 = 55, 190 : 5 = 38, a : b = c, a . b = ab,',LF
db FF
db 'Fakturu ‡. 115 881/84 z 15. t. m. na ‡ stku K‡ 115 850,--',LF
db 'jsme obdr‘eli dnes. Zubn¡ l‚ka© ordinuje z¡tra v 10 - 13 h.',LF
db 'Cestovn¡ kancel © nab¡z¡ zlevnˆn‚ 8denn¡ pobyty v Tatr ch.',LF
db '—‡tujeme V m 5procentn¡ (5%n¡) pen le za nedodr‘en¡ lh–ty.',LF
db 'Provˆrku bezpe‡nostn¡ch opat©en¡ jsme provedli v uplynul‚m',LF
db 'obdob¡ 3kr t. Na ledni‡ky poskytuje v˜robce 5letou z ruku.',LF
db FF
db 'V˜¤atek z technick‚ zpr vy o polohopisn‚m mˆ©en¡ v zoologick‚',LF
db 'zahradˆ v katastr ln¡m £zem¡ Olomouc. Mˆ©en¡ bylo provedeno ve',LF
db 'dvoj¡m mˆ©¡tku. Okol¡ b˜val‚ho medvˆdince a voli‚ry o rozloze',LF
db '1,0 ha bylo detailnˆ zamˆ©eno v mˆ©¡tku 1:100, plocha mezi v˜-',LF
db 'bˆhem pro ‘irafy a vodn¡ n dr‘¡ o rozloze 3,0 ha byla zamˆ©ena',LF
db 'v mˆ©¡tku 1:500. K tomuto prostoru bylo pro celkovou orientaci',LF
db 'p©ikresleno tak‚ okol¡ medvˆdince zmen¨en‚ do mˆ©¡tka 1:500.',LF
db EOT

; ------ lekce 45 67
;þ
LekcC45  label     byte
db '67)',LF
db LF
db '€¡slici 6 p¡¨eme lev˜m ukazov ‡kem s pomoc¡ prav‚ kl vesy SHIFT.',LF
db '€¡slici 7 p¡¨eme prav˜m ukazov ‡kem s pomoc¡ lev‚ kl vesy SHIFT.',LF
db LF
db ' ukazov ‡kem lev‚ ruky  - 6',LF
db 'ukazov ‡kem prav‚ ruky  - 7',LF
db LF
db LF
db LF
db EOT

LekcI45  label     byte
db '67)',LF
db LF
db '€¡slici  6  p¡¨eme lev˜m ukazov ‡kem vych˜len¡m na ‡¡selnou ©adu kl ves.',LF
db '€¡slici  7 p¡¨eme prav˜m ukazov ‡kem vych˜len¡m na ‡¡selnou ©adu kl ves.',LF
db LF
db ' ukazov ‡kem lev‚ ruky  - 6',LF
db 'ukazov ‡kem prav‚ ruky  - 7',LF
db LF
db LF
db LF
db EOT

Lekc145  label     byte
db '67)',LF
db LF
db LF
db '€¡slice 6 a 7 p¡¨eme buƒ v numerick‚m poli kl vesnice (zapnout Num Lock)',LF
db 'nebo  stiskem  mrtv‚ kl vesy ` a potom kl vesy ‘ resp. ˜. Druhou mo‘nost',LF
db 'nepodporuj¡ v¨echny ovlada‡e ‡esk‚ kl vesnice.',LF
db LF
db LF
db LF
db LF
db EOT

Lekc245  label     byte
db '67)',LF
db LF
db LF
db '€¡slice 6 a 7 p¡¨eme buƒ v numerick‚m poli kl vesnice (zapnout Num Lock)',LF
db 'nebo  stiskem  mrtv‚ kl vesy ',39,' a potom kl vesy ‘ resp. ˜. Druhou mo‘nost',LF
db 'nepodporuj¡ v¨echny ovlada‡e ‡esk‚ kl vesnice.',LF
db LF
db LF
db LF
db LF
db EOT

LDatC45  label     byte
LDatI45  label     byte
LDat145  label     byte
LDat245  label     byte
db '6666666 7777777 f6f6f6f6f6f j7j7j7j7j7j ft6ft6ft6 ju7ju7ju7',LF
db '6 fkl– 66 fkl– 6 fkl– 66 fkl– 6 fkl– 66 fkl– 6 fkl– 66 fkl–',LF
db '7 jdsa 7 jdsa 7 jdsa 777 jdsa 7 jdsa 7 jdsa 7 jdsa 777 jdsa',LF
db '66 graf–, 66 stenograf–, 6 fotograf–, 66 telegraf–, 6 graf–,',LF
db '7 j¡zd, 77 j¡zdenek, 777 stroj–, 77 p©¡stroj–, 77 kg jahod,',LF
db '1/4 l ¨leha‡ky, 1 3/4 kg masa, 3 1/4 kg medu, 3/4 kg lusk–',LF
db FF
db 'P© telsk‚ utk n¡ v kopan‚ se konalo 6. ‡ervence od 16.00 h',LF
db 'na h©i¨ti SK Nov˜ Rychnov. Dom c¡ vyhr li p©esvˆd‡ivˆ 6:0.',LF
db 'Z odpoledn¡ch po©ad– €T1: 16.00 Teletext, 16.30 Loupe‘nick ',LF
db 'poh dka, 17.10 Zad no pro ‘eny, 17.30 MS v gymnastice mu‘–.',LF
db FF
db 'V leto¨n¡m roce jsem za‡ala nav¨tˆvovat kurs sekret ©sk‚ pr ce',LF
db 'v Tˆsnopisn‚m £stavu Praze. Podle ­ 5 vyhl. ‡. 140/1668 Sb.',LF
db 'mi n le‘¡ 8 hodin studijn¡ho volna mˆs¡‡nˆ. Konzultace se v¨ak',LF
db 'konaj¡ dva dny v mˆs¡ci, co‘ je celkem 16 hodin. Z tohoto d–-',LF
db 'vodu ‘ d m na z kladˆ vyhl ¨ky ‡. 140/1968 Sb. ­ 18 o roz¨¡©e-',LF
db 'n¡ studijn¡ho volna na 16 hodin mˆs¡‡nˆ.',LF
db EOT

; ------ lekce 46 2
;þ
LekcC46  label     byte
db '2)',LF
db LF
db LF
db '€¡slici 2 p¡¨eme lev˜m mal¡‡kem s pomoc¡ prav‚ kl vesy SHIFT.',LF
db LF
db 'mal¡‡kem lev‚ ruky  - 2',LF
db LF
db LF
db LF
db LF
db EOT

LekcI46  label     byte
db '2)',LF
db LF
db LF
db '€¡slici 2 p¡¨eme lev˜m mal¡‡kem vych˜len¡m na ‡¡selnou ©adu kl ves.',LF
db LF
db 'mal¡‡kem lev‚ ruky  - 2',LF
db LF
db LF
db LF
db LF
db EOT

Lekc146  label     byte
db '2)',LF
db LF
db LF
db '€¡slici  2  p¡¨eme  buƒ  v numerick‚m poli kl vesnice (zapnout Num Lock)',LF
db 'nebo  stiskem  mrtv‚  kl vesy  `  a  potom  kl vesy  ˆ.  Druhou  mo‘nost',LF
db 'nepodporuj¡ v¨echny ovlada‡e ‡esk‚ kl vesnice.',LF
db LF
db LF
db LF
db LF
db EOT

Lekc246  label     byte
db '2)',LF
db LF
db LF
db '€¡slici  2  p¡¨eme  buƒ  v numerick‚m poli kl vesnice (zapnout Num Lock)',LF
db 'nebo  stiskem  mrtv‚  kl vesy  ',39,'  a  potom  kl vesy  ˆ.  Druhou  mo‘nost',LF
db 'nepodporuj¡ v¨echny ovlada‡e ‡esk‚ kl vesnice.',LF
db LF
db LF
db LF
db LF
db EOT

LDatC46  label     byte
LDatI46  label     byte
LDat146  label     byte
LDat246  label     byte
db '222 asl– 2 asl– 2 asl– 2 asl– 222 asl– 2 asl– 2 asl– 2 asl–',LF
db '2 alba, 2 ambulance, 222 automobil–, 22 ambulanc¡, 22 akc¡,',LF
db '9. kvˆtna 1945, 9. 5. 1945, 9/5 1945, 15. 3. 1939, 17. 11. 1939',LF
db '450509, 45.05.09, 45-05-09, 5. 5. 1945',LF
db FF
db 'Modern¡ kombin t v Ru‘omberku vyrob¡ 200 tis¡c tun celul¢-',LF
db 'zy ro‡nˆ. Dne 22. 2. t. r. jsme objednali 2 ventily d 3/4".',LF
db FF
db '­ 106 - 109 Z kon¡ku pr ce se t˜k  ‡erp n¡ dovolen˜ch.',LF
db 'V €esk‚ republice spadne z celkov‚ho mno‘stv¡ sr ‘ek',LF
db 'v l‚tˆ 40 %, na ja©e 25 %, na podzim 20 % a v zimˆ jen 15 %.',LF
db 'Po hav rii bylo v krvi ©idi‡e zji¨tˆno 1,3 o/oo alkoholu.',LF
db 'Sch–ze Klubu mlad˜ch filatelist– se kon  dnes od 15.00 h.',LF
db 'Objednali jsme 20 tabul¡ ocelov‚ho plechu 3 x 1000 X 2000 mm.',LF
db '—‡tujeme V m 10% pen le za dod vku materi lu hor¨¡ jakosti.',LF
db 'Autobus do Liberce odj¡‘d¡ z Prahy v 17:00 h. V p©¡loze V m',LF
db 'vrac¡me Va¨i penaliza‡n¡ fakturu ‡. 811/9m ze dne 16.4. t. r.',LF
db 'na ‡ stku K‡ 1.230,--.',LF
db FF
db 'Na nev˜robn¡ oblast p©ipad  v sou‡asn‚ dobˆ t©etina celkov‚',LF
db 'spot©eby elektrick‚ energie v €R. Z toho se t‚mˆ© 20 pro-',LF
db 'cent spot©ebuje v dom cnostech. Pr–mˆrnou celoro‡n¡ spot©ebou',LF
db '1754 kWh na dom cnost se tak ©ad¡me na jedno z p©edn¡ch m¡st',LF
db 'v Evropˆ. P©itom podle re ln˜ch odhad– je mo‘n‚ p©i racion l-',LF
db 'n¡m vyu‘¡v n¡ dos hnout v dom cnostech ro‡n¡ch £spor a‘ ve',LF
db 'v˜¨i jedn‚ ‡tvrtiny celkov‚ spot©eby. To p©edstavuje 3 mi-',LF
db 'li¢ny tun mˆrn‚ho paliva, tedy t‚mˆ© 6,5 mili¢n– tun hnˆd‚ho',LF
db 'uhl¡. Za 1 kWh je mo‘n‚ uva©it obˆd pro 3 osoby, 24 hodin',LF
db 'chladit potraviny ve st©ednˆ velk‚ ledni‡ce, vyprat kilogram',LF
db 'pr dla v automatick‚ pra‡ce, 2 hodiny ‘ehlit nebo oh© t 30 l',LF
db 'vody nad 40 stup¤– Celsia. —spor elektrick‚ energie v dom -',LF
db 'cnostech lze dos hnout nejen £‡eln˜m pou‘¡v n¡m elektrick˜ch',LF
db 'spot©ebi‡–, ale tak‚ zv˜¨en¡m jejich technick‚ £rovnˆ a',LF
db 'pou‘¡v n¡m regula‡n¡ch za©¡zen¡.',LF
db EOT

; ------ lekce 47 *\
;þ
LekcC47  label     byte
db '*\)',LF
db 'Znak  *  zap¡¨eme  stiskem  mrtv‚  kl vesy  ',39,' a potom kl vesy 8 sou‡asnˆ',LF
db 's  kl vesou SHIFT. V nutn‚m p©¡padˆ (pokud ovlada‡ kl vesnice tento znak',LF
db 'nepodporuje) lze pou‘¡t metodu s ALT: lev˜m mal¡‡kem stisknout (a dr‘et)',LF
db 'levou kl vesu ALT, na numerick‚ kl vesnici zapsat ‡¡slo 42 a kl vesu ALT',LF
db 'uvolnit.  Znak  \  zap¡¨eme stiskem mrtv‚ kl vesy ',39,' a potom kl vesy \ (u',LF
db 'nˆkter˜ch kl vesnic neozna‡en  kl vesa, u jin˜ch kl vesnic se zad v  bez',LF
db 'mrtv‚ kl vesy). V nutn‚m p©¡padˆ lze pou‘¡t metodu s ALT: lev˜m mal¡‡kem',LF
db 'stisknout  (a  dr‘et)  levou kl vesu ALT, na numerick‚ kl vesnici zapsat',LF
db '‡¡slo 92 a kl vesu ALT uvolnit.',LF
db EOT

LekcI47  label     byte
Lekc147  label     byte
Lekc247  label     byte
db '*\)',LF
db LF
db 'Znak  *  p¡¨eme  prav˜m  ukazov ‡kem  za  sou‡asn‚ho stisku lev‚ kl vesy',LF
db 'SHIFT.  Znak \ p¡¨eme prav˜m mal¡‡kem (je-li tato kl vesa vpravo naho©e)',LF
db 'pop©.  lev˜m  mal¡‡kem  (je-li kl vesa vlevo dole). V nutn‚m p©¡padˆ lze',LF
db 'pou‘¡t  metodu  s  ALT: lev˜m mal¡‡kem stisknout (a dr‘et) levou kl vesu',LF
db 'ALT, na numerick‚ kl vesnici zapsat ‡¡slo 92 a kl vesu ALT uvolnit.',LF
db LF
db LF
db LF
db EOT

LDatC47  label     byte
LDatI47  label     byte
LDat147  label     byte
LDat247  label     byte
db '***** \\\\\ 8*8*8*8*8 z\z\=\= C:\VYUKA\VSEMI10\*.* A:\*.TXT',LF
db EOT

ENDIF

LekSeg4  ENDS
         END

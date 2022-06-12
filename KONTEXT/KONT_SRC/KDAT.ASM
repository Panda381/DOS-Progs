
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                         Datov˜ segment
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

Data     SEGMENT   PARA PUBLIC
                                            ; datov˜ segment pat©¡ a‘
                                            ; za programov˜ segment

; ------ parametry textov‚ho videom¢du

d_0000   db        ?                        ; z kladn¡ nastaven¡ barev
d_0001   db        ?                        ; inverzn¡ nastaven¡ barev
d_0002   db        ?                        ; barva pop©ed¡
d_0003   db        ?                        ; barvy pozad¡
d_0004   db        ?                        ; sou©ad. lev‚ho horn¡ho rohu okna
d_0005   db        ?                        ; © dek lev‚ho horn¡ho rohu okna
d_0006   db        ?                        ; aktu ln¡ videom¢d
d_0007   db        ?                        ; FF=p©¡znak barevn‚ho displeje
d_0008   db        ?                        ; aktu ln¡ nastaven¡ barev displeje

; ------ parametry grafick‚ho videom¢du

d_0009   db        ?                        ; grafick˜ videom¢d
d_000A   dw        ?                        ; lev  sou©adnice gra. okna X
d_000C   dw        ?                        ; prav  sou©adnice graf. okna X
d_000E   dw        ?                        ; horn¡ sou©adnice graf. okna Y
d_0010   dw        ?                        ; doln¡ sou©adnice graf. okna Y

d_0012   dw        ?                        ; doba prodlevy pro 1 ms
d_0014   dw        ?                        ; funkce 0Ch a barva graf. bodu
d_0016   dw        ?                        ; p©¡rustek sou©adnic ve smˆru X
d_0018   dw        ?                        ; p©¡rustek sou©adnic ve smˆry Y
d_001a   dw        ?                        ; sou©adnice X pro operaci s bodem
d_001c   dw        ?                        ; sou©adnice Y pro operaci s bodem
d_001E   dw        ?                        ; konstanta pro p©¡rustek 2. sou©ad.
d_0020   db        ?                        ; aktu ln¡ barva pozad¡ graf. m¢du
         db        ?

; ------ parametry voln˜ch pamˆŸov˜ch blok–
; Struktura jednoho pamˆŸov‚ho bloku:
;      0: (4) adresa dal¨¡ho voln‚ho pamˆŸov‚ho bloku
;      4: (4) velikost voln‚ho pamˆŸov‚ho bloku (0=konec dat)
;      8: (x) data

d_0022   dd        ?                        ; adresa prvn¡ho pamˆŸov‚ho bloku
d_0026   dd        ?                        ; adresa ukazatele pamˆŸov‚ho bloku
d_002A   dd        ?                        ; uschovan  p–vodn¡ velikost bloku
d_002E   dd        ?                        ; adresa minul‚ho pamˆŸov‚ho bloku
d_0032   dd        ?
d_0036   db        128 dup(?)
d_00b6   db        128 dup(?)               ; buffer k dek¢dov n¡ text. ©etˆzc–
d_00b60  label     byte

; ------ tabulka adres obsluh funkc¡ z kladn¡ho modulu (z adresy l_0A07)

d_0136   dw        ?                        ; test p©ipravenosti znaku z kl ves.
d_0138   dw        ?                        ; vstup znaku z kl vesnice -> AX
d_013a   dw        ?                        ; v˜stup znaku na displej do okna
d_013c   dw        ?                        ; v˜stup znaku na tisk rnu
d_013e   dw        ?                        ; v˜stup znaku na za©¡zen¡ AUX
d_0140   dw        ?                        ; vstup znaku ze za©¡zen¡ AUX
d_0142   dw        ?                        ; v˜stup znaku na displej do okna
d_0144   dw        ?                        ; vstup znaku z kl vesnice -> AX

d_0146   dw        ?                        ; identifik tor souboru 1
d_0148   db        ?
d_0149   db        ?

d_014a   dw        ?                        ; identifik tor souboru 2
d_014c   db        ?
d_014d   db        ?

d_014e   dw        ?                        ; identifik tor souboru 3
d_0150   db        ?
d_0151   db        ?

d_0152   dw        ?                        ; identifik tor souboru 4
d_0154   db        ?
d_0155   db        ?

d_0156   dw        ?                        ; identifik tor souboru 5
d_0158   db        ?
d_0159   db        ?

; ------ parametry standardn¡ho vstupn¡ho za©¡zen¡

d_015a   dw        ?                        ; identifik tor stand. vstup. za©¡z.
d_015c   db        ?                        ; nebo 0
d_015d   db        ?
d_015e   dw        ?                        ; za‡ tek voln‚ pamˆti
d_0160   dw        ?                        ; 1=p©¡znak znakov‚ho za©¡zen¡

         dd        ?

; ------ parametry standardn¡ho v˜stupn¡ho za©¡zen¡

d_0166   dw        ?                        ; identifik tor stand. v˜stup. za©.
d_0168   db        ?                        ; nebo 0
d_0169   db        ?
d_016a   dw        ?
d_016c   dw        ?                        ; 1=p©¡znak znakov‚ho za©¡zen¡

         dd        ?

d_0172   dw        ?                        ; p©¡znaky programu
                                            ;   bit 0: 1=blok programu se zmen¨¡
                                            ;   bit 1: 1=povoleny slu‘by 44h
                                            ;   bit 2: 1=povolena obsluha Ctrl-C
                                            ;   bit 3: 1=instaluje se INT 03h
d_0174   dw        ?                        ; vrchol z sobn¡ku (ukazatel SP)
d_0176   dw        ?                        ; ?
d_0178   dw        ?                        ; ?
d_017a   dw        ?                        ; adresa tabulky ident. soubor–
d_017c   dw        ?                        ; maxim.po‡et identifik tor– soubor–
d_017e   dw        ?                        ; adresa obsluhy p©eru¨en¡
d_0180   db        ?                        ; n vrat. k¢d chyby diskov‚ operace
d_0181   db        ?
d_0182   dw        ?
d_0184   dw        ?
d_0186   dw        ?                        ; adresa vzniku chyby programu
d_0188   dw        ?
d_018a   dd        ?                        ; adresa za‡ tku voln‚ pamˆti
d_018e   dd        ?                        ; p–vodn¡ adresa INT 00h
d_0192   dw        ?                        ; buffer pro £schovu znaku z kl ves.
d_0194   db        ?                        ; bit 0: 1 = povolena obsluha Ctrl-C
                                            ; bit 1: 1 = nastalo p©eru¨en¡ INT 3
d_0195   db        ?
d_0196   db        80 dup(?)               ; domovsk˜ adres © tohoto programu
d_01E6   db        ?                        ; maxim ln¡ d‚lka ©etˆzce ‡¡sla
d_01E7   db        ?
d_01E8   dd        ?                        ; adresa bufferu k dek¢dov n¡ ‡¡sla
d_01EC   dd        ?
d_01F0   dd        ?
d_01F4   db        6 dup(?)                 ; buffer ‡¡sla REAL k dek¢dov n¡
d_01FA   db        ?
d_01FB   db        ?

; ------ gener tor n hodn‚ho ‡¡sla

d_01FC   dd        ?                        ; st©ada‡ n hodn‚ho ‡¡sla


d_0200   db        ?                        ; velikost c¡lov‚ho bufferu
         db        ?
d_0202   dw        ?
         dw        ?
d_0206   dd        ?
d_020A   dd        ?
d_020E   dw        ?
d_0210   dw        ?
d_0212   dw        ?
d_0214   dw        ?
d_0216   dw        ?
d_0218   dw        ?
d_021A   dw        ?
d_021C   dw        ?
d_021E   dw        ?
d_0220   dw        ?
d_0222   dw        ?
d_0224   db        ?
d_0225   db        ?
d_0226   db        12 dup(?)                ; buffer k dek¢dov n¡ mantisy ‡¡sla
d_0232   dd        ?                        ; adresa definice stand. za©¡zen¡
         dw        ?
d_0238   db        ?                        ; bit 0:1=vytvo©en¡/0=otev©en¡ soub.
         db        ?
d_023A   dw        3 dup(?)
d_0240   dw        16 DUP (?)               ; tabulka identifik tor– soubor–

; -----------------------------------------------------------------------------
;        u‘ivatelsk  data
; -----------------------------------------------------------------------------

; ------ definice registr– pro vol n¡ slu‘by DOS

d_0260   dw        ?                        ; registr AX pro vol n¡ INT 21h
d_0262   dw        ?                        ; registr BX pro vol n¡ INT 21h
d_0264   dw        ?                        ; registr CX pro vol n¡ INT 21h
d_0266   dw        ?                        ; registr DX pro vol n¡ INT 21h
         dw        ?                        ; registr BP pro vol n¡ INT 21h
         dw        ?                        ; registr SI pro vol n¡ INT 21h
         dw        ?                        ; registr DI pro vol n¡ INT 21h
d_026E   dw        ?                        ; registr DS pro vol n¡ INT 21h
d_0270   dw        ?                        ; registr ES pro vol n¡ INT 21h
d_0272   dw        ?                        ; registr p©¡znak– FLAG pro INT 21h

; ------ definice textov˜ch © dk– (adresy po‡ tk– © dk–, 0=voln˜ popisova‡)
; V¨echny prostory maj¡ p©idˆlen velikost bloku podle skute‡n‚ho po‡tu © dk–,
; pouze aktivn¡ prostor m  p©idˆlen blok o maxim ln¡ velikosti v‡etnˆ pr zdn˜ch
; © dk–. Tabulka obsahuje adresy po‡ tk– © dk– SEGMENT:OFFSET, 0=nen¡ © dek)

d_0274   dd        MAXLINES+1 dup(?)        ; definice © dk– (adresy po‡ tk–)

; ------ buffer seznamu soubor– (na‡ten˜ obsah adres ©e)/diskov˜ buffer 1800h B

; Struktura (256 polo‘ek po 23 bajtech)
;    0: (1) d‚lka jm‚na polo‘ky + 1 (v‡etnˆ n sleduj¡c¡ho bajtu)
;    1: (1) typ polo‘ky  0=adres ©, " "=soubor
;    2: (13) jm‚no polo‘ky ASCII
;   15: (2) ‡as polo‘ky
;   17: (2) datum polo‘ky
;   19: (4) velikost polo‘ky
; 6218 bajt–, 256 polo‘ek po 23 bajtech

d_CD98   db        256 * 23 dup(?)          ; buffer seznamu soubor–, disk.buff.
         db        330 dup(?)               ; zbytek diskov‚ho bufferu


d_E5E2   dw        ?
d_E5E4   dw        80 dup(?)                ; tabulka ‡¡sel zobrazen˜ch © dk–

d_E684   db        8 dup(?)

d_E68C   db        ?
d_E68D   db        ?
d_E68E   db        ?
d_E68F   db        ?                        ; posledn¡ znak z ASCII tabulky

; ------ ukazatele aktivn¡ho editovan‚ho prostoru

d_E690   dw        ?                        ; © dek za‡ tku bloku
d_E692   dw        ?                        ; © dek konce bloku
d_E694   dw        ?                        ; pozice za‡ tku sloupcov‚ho bloku
d_E696   dw        ?
d_E698   dw        ?                        ; ‡¡slo aktivn¡ho editovan‚ho © dku
d_E69A   dw        ?                        ; pozice kurzoru na © dku
d_E69C   dw        ?                        ; ‡¡slo © dku kurzoru na obrazovce
d_E69E   dw        ?                        ; maxim ln¡ po‡et © dk– prostoru
                                            ; (p©i £schovˆ parametru se prostor
                                            ;  pro soubor zmen¨¡ na skute‡n˜
                                            ;  po‡et © dk– prostoru)
d_E6A0   dw        ?                        ; © dek uschovan‚ zna‡ky v textu
d_E6A2   dw        ?                        ; pozice uschovan‚ zna‡ky v textu
d_E6A4   dw        ?                        ; offset za‡ tku zobrazen‚ho © dku
d_E6A6   dw        ?                        ; maxim ln¡ d‚lka © dku od L okraje
d_E6A8   db        ?                        ; 0=p©¡znak modifikace textu
d_E6A9   db        ?                        ; 1=p©¡znak zapnut¡ zobrazen¡ bloku
d_E6AA   db        ?                        ; 1=p©¡znak sloupcov‚ho bloku
d_E6AB   dd        10 dup(?)                ; adresy © dk– z hlav¡
d_E6D3   dd        10 dup(?)                ; adresy © dk– paty

d_E6FB   db        ?,128 dup(?)             ; jm‚no editovan‚ho souboru (buffer)

; ------ uschovan‚ ukazatele editovan‚ho prostoru

d_E77C   db        5 * PARSIZU dup(?)       ; uschovan‚ ukazatele

; ------ uschovan‚ parametry editovan‚ho prostoru (p©ep¡na‡e)

d_EC18   db        5*13 dup(?)              ; uschovan‚ parametry edit. prostor–


d_ec59   db        ?,255 dup(?)             ; buffer textov‚ho © dku
d_ed59   db        ?,255 dup(?)             ; buffer atribut– znak– © dku
                                            ;   bit 0: 1=nadsazen˜ znak
                                            ;   bit 1: 1=podsazen˜ znak
                                            ;   bit 2: 1=¨ikm‚ p¡smo
                                            ;   bit 3: 1=podtr‘en˜ znak
                                            ;   bit 4: 1=zv˜raznˆn˜ znak
                                            ;   bit 5: 1=inverzn¡ znak
                                            ;   bit 6: 1=znak s rozdˆl.znam‚nkem
                                            ;   bit 7: 1=dvojn sobn  ¨¡©ka znaku
d_ee59   db        ?,255 dup(?)             ; buffer textu (Ctrl-^ a Ctrl-])
d_ef59   db        ?,255 dup(?)
d_f059   db        ?,255 dup(?)             ; druh  ‡ st © dku po rozdˆlen¡
d_f159   db        ?,255 dup(?)             ; druh  ‡ st atribut– © dku po rozd.
d_f259   db        ?,255 dup(?)             ; buffer p©ehr van‚ makrokl vesy
d_F359   db        ?,255 dup(?)             ; edita‡n¡ buffer zad n¡ parametru

d_F459   db        ?,128 dup(?)             ; text k hled n¡
d_F4DA   db        ?,128 dup(?)             ; text k nahrazen¡
d_F55B   db        ?,128 dup(?)             ; jm‚no souboru ke ‡ten¡ bloku
d_F5DC   db        ?,128 dup(?)             ; jm‚no souboru k z pisu bloku
d_F65D   db        ?,128 dup(?)             ; jm‚no ‡ten‚ho souboru z disku
d_F6DE   db        ?,128 dup(?)             ; jm‚no startovan‚ho programu
d_F75F   db        ?,14 dup(?)              ; zadan  pozice kurzoru v souboru

d_F76E   db        15 dup(?)

d_F77D   db        ?,8 dup(?)               ; buffer parametr– hled n¡

d_F786   db        ?                        ; 1=p©¡znak zobrazen¡ horn¡ho menu
d_F787   db        ?
d_F788   db        ?                        ; zvolen˜ aktu ln¡ typ p¡sma
d_F789   db        ?                        ; 1=p©¡znak modifikace edit. © dku
d_F78A   db        ?                        ; 1=p©¡znak p©eru¨en¡ editace volby
d_F78B   db        ?                        ; 1=p©echodn‚ vypnut¡ blik n¡ kurz.
d_F78C   db        ?
d_F78D   db        ?
d_F78E   db        ?
d_F78F   db        ?                        ; 1=p©¡znak dekadick‚ho tabel toru
d_F790   db        ?                        ; 1=povoleno zobrazen¡ menu
d_F791   db        ?
d_F792   db        ?
d_F793   db        ?
d_F794   db        ?
d_F795   db        ?
d_F796   db        ?
d_F797   db        ?
d_F798   db        ?
d_F799   db        ?
d_F79A   db        ?
d_F79B   db        ?                        ; £schova znaku line lu-lev˜ okraj
d_F79C   db        ?                        ; £schova znaku line lu-prav˜ okraj
d_F79D   dw        ?                        ; k¢d chyby KonTextu
                                            ;  0 nen¡ chyba
                                            ;  1 soubor nenalezen
                                            ;  2 chyba ‡ten¡
                                            ;  3 chyba z pisu
                                            ;  4 adres © nenalezen
                                            ;  5 nedostatek pamˆti
                                            ;  6 p©ekro‡en maxim. po‡et © dk–
                                            ;  7 ©etˆzec nenalezen
                                            ;  8 © dek p©¡li¨ dlouh˜
                                            ;  9 chyba zad n¡
                                            ; 10 nen¡ ozna‡en blok
                                            ; 11 makrobuffer pln˜
                                            ; 12 tisk rna nen¡ v provozu
                                            ; 13 chybn˜ form t dat
                                            ; 15 tento soubor ji‘ existuje
                                            ; 16 zdroj.a c¡l.soub.jsou identick‚
                                            ; 17 prostor @ nen¡ dosud vyti¨tˆn
                                            ; 18 sloupcov˜ blok nelze ulo‘it
                                            ; 19 nen¡ ozna‡en sloupc. blok
                                            ; 20 kurz.mus¡ b˜t za prav˜m okrajem
                                            ; 21 nen¡ soubor EXE ani COM
                                            ; 50 nepovolen˜ mat. v˜raz
                                            ; 51 p©ete‡en¡ des. te‡ky
                                            ; 52 dˆlen¡ nulou
                                            ; 53 chybn˜ argument
                                            ; 54 chyba argumentu
                                            ; 99 intern¡ (KONTEXT modifikov n)
                                            ; 100 disket. mechanika nepracuje
                                            ; 153 neo‡ek van˜ konec souboru
                                            ; 196 p©ete‡en¡ Integer
                                            ; 240 disketa p©eplnˆna
                                            ; 241 nepovolen‚ jm‚no souboru

d_F79F   dw        ?                        ; ukazatel p©ehr van‚ makrokl vesy
d_F7A1   dw        ?                        ; po‡et bajt– v tabulce maker
d_F7A3   dw        ?                        ; skute‡n˜ po‡et © dk– prostoru
d_F7A5   dw        ?                        ; po‡ te‡n¡ © dek prostoru v tabulce
d_F7A7   dw        ?                        ; ‡¡slo aktivn¡ho prostoru
d_F7A9   dw        ?                        ; po‡et © dk– na str nku bez okraj–
d_F7AB   dw        ?                        ; uschovan˜ ukazatel z sobn¡ku SP
d_F7AD   dw        ?                        ; uschovan˜ registr BP bˆhem editace
d_F7AF   dw        ?                        ; uschovan˜ registr SP bˆhem editace

d_F7B1   dd        80 dup(?)                ; buffer uschovan˜ch © dk– k obnovˆ

d_F8F1   db        0F941h - 0F8F1h dup(?)

d_F941   dw        ?
d_F943   dw        ?
d_F945   db        ?

; ------ tabulka souboru DTA

d_F946   label     byte                     ; tabulka DTA (43 bajt–)
         db        21 dup(?)                ; (rezervov no)
d_F95B   db        ?                        ; 0: DTAAtrib: atributy souboru
         dw        ?                        ; 1: DTATime : ‡as souboru
         dw        ?                        ; 3: DTADate : datum souboru
         dd        ?                        ; 5: DTASize : velikost souboru
         db        13 dup(?)                ; 9: DTAName : jm‚no souboru ASCIIZ

d_F971   db        ?                        ; 1=prov d¡ se v˜bˆr souboru
d_F972   dw        ?                        ; p–vodn¡ adresa INT 24h - segment
d_F974   dw        ?                        ; p–vodn¡ adresa INT 24h - offset

; ------ ukazatele seznamu soubor–

d_F976   dw        ?                        ; maxim. © dek k zobrazen¡ seznamu
d_F978   dw        ?                        ; po‡ te‡n¡ zobraz. polo‘ka seznamu
d_F97A   dw        ?                        ; polo‘ka seznamu s kurzorem
d_F97C   dw        ?                        ; po‡et polo‘ek v seznamu soubor–

d_F97E   dw        ?                        ; uschovan  adresa DTA - segment
d_F980   dw        ?                        ; uschovan  adresa DTA - offset
d_F982   dw        ?
d_F984   dw        ?
d_F986   dw        ?
d_F988   dw        ?
d_F98A   dw        ?                        ; ‡¡slo ti¨tˆn‚ho prostoru
d_F98C   dw        ?
d_F98E   dw        ?
d_F990   dw        ?
d_F992   dw        ?
d_F994   dw        ?                        ; 1=prob¡h  tisk;0=ne
d_F996   dw        ?
d_F998   dw        ?
d_F99A   dw        ?
d_F99C   dw        ?
d_F99E   dw        ?
d_F9A0   dw        ?
d_F9A2   dw        ?                        ; ukazatel znak– v tiskov‚m bufferu
d_F9A4   db        ?
d_F9A5   db        ?
d_F9A6   db        ?,800 dup(?)             ; tiskov˜ vyrovn vac¡ buffer


d_FCC7   db        ?,255 dup(?)

d_fdc7   dd        ?                        ; adresa vstupn¡ho bodu SCREEN.OVL
d_fdcb   dw        ?                        ; po‡et graf.linek na © dek textu
d_fdcd   dw        ?                        ; max. po‡et znak– na © dek displeje
d_fdcf   dw        ?                        ; po‡et zobrazen˜ch textov˜ch © dk–
d_fdd1   db        4 dup(?)                 ; identifika‡n¡ ©etˆzec graf. karty
d_FDD5   db        128 dup(?)               ; p©¡stupov  cesta k SCREEN.OVL

         db        ?
d_fe56   db        ?                        ; m¢d zobrazen¡ znaku
                                            ;   bit 0: 1=nadsazen˜ znak
                                            ;   bit 1: 1=podsazen˜ znak
                                            ;   bit 2: 1=¨ikm‚ p¡smo
                                            ;   bit 3: 1=podtr‘en˜ znak
                                            ;   bit 4: 1=zv˜raznˆn˜ znak
                                            ;   bit 5: 1=inverzn¡ znak
                                            ;   bit 6: 1=znak s rozdˆl.znam‚nkem
                                            ;   bit 7: 1=dvojn sobn  ¨¡©ka znaku

                                            ; 0=p©¡znak, ‘e © dek p©es hl obraz.
                                            ; 20h=operace se stavov˜m © dkem

Data     ENDS

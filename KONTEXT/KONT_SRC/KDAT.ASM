
; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�
;
;                         Datov� segment
;
; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�

Data     SEGMENT   PARA PUBLIC
                                            ; datov� segment patæ a�
                                            ; za programov� segment

; ------ parametry textov괿o videom줰u

d_0000   db        ?                        ; z쟪ladn� nastaven� barev
d_0001   db        ?                        ; inverzn� nastaven� barev
d_0002   db        ?                        ; barva pop쯥d�
d_0003   db        ?                        ; barvy pozad�
d_0004   db        ?                        ; sou쯠d. lev괿o horn죋o rohu okna
d_0005   db        ?                        ; 찤dek lev괿o horn죋o rohu okna
d_0006   db        ?                        ; aktu쟫n� videom줰
d_0007   db        ?                        ; FF=pæznak barevn괿o displeje
d_0008   db        ?                        ; aktu쟫n� nastaven� barev displeje

; ------ parametry grafick괿o videom줰u

d_0009   db        ?                        ; grafick� videom줰
d_000A   dw        ?                        ; lev� sou쯠dnice gra. okna X
d_000C   dw        ?                        ; prav� sou쯠dnice graf. okna X
d_000E   dw        ?                        ; horn� sou쯠dnice graf. okna Y
d_0010   dw        ?                        ; doln� sou쯠dnice graf. okna Y

d_0012   dw        ?                        ; doba prodlevy pro 1 ms
d_0014   dw        ?                        ; funkce 0Ch a barva graf. bodu
d_0016   dw        ?                        ; pærustek sou쯠dnic ve sm늭u X
d_0018   dw        ?                        ; pærustek sou쯠dnic ve sm늭y Y
d_001a   dw        ?                        ; sou쯠dnice X pro operaci s bodem
d_001c   dw        ?                        ; sou쯠dnice Y pro operaci s bodem
d_001E   dw        ?                        ; konstanta pro pærustek 2. sou쯠d.
d_0020   db        ?                        ; aktu쟫n� barva pozad� graf. m줰u
         db        ?

; ------ parametry voln쁟h pam닟ov쁟h blok�
; Struktura jednoho pam닟ov괿o bloku:
;      0: (4) adresa dalÆho voln괿o pam닟ov괿o bloku
;      4: (4) velikost voln괿o pam닟ov괿o bloku (0=konec dat)
;      8: (x) data

d_0022   dd        ?                        ; adresa prvn죋o pam닟ov괿o bloku
d_0026   dd        ?                        ; adresa ukazatele pam닟ov괿o bloku
d_002A   dd        ?                        ; uschovan� p뻱odn� velikost bloku
d_002E   dd        ?                        ; adresa minul괿o pam닟ov괿o bloku
d_0032   dd        ?
d_0036   db        128 dup(?)
d_00b6   db        128 dup(?)               ; buffer k dek줰ov쟮� text. 쯥t늷c�
d_00b60  label     byte

; ------ tabulka adres obsluh funkc� z쟪ladn죋o modulu (z adresy l_0A07)

d_0136   dw        ?                        ; test p쯫pravenosti znaku z kl쟶es.
d_0138   dw        ?                        ; vstup znaku z kl쟶esnice -> AX
d_013a   dw        ?                        ; v쁲tup znaku na displej do okna
d_013c   dw        ?                        ; v쁲tup znaku na tisk쟲nu
d_013e   dw        ?                        ; v쁲tup znaku na zaæzen� AUX
d_0140   dw        ?                        ; vstup znaku ze zaæzen� AUX
d_0142   dw        ?                        ; v쁲tup znaku na displej do okna
d_0144   dw        ?                        ; vstup znaku z kl쟶esnice -> AX

d_0146   dw        ?                        ; identifik쟴or souboru 1
d_0148   db        ?
d_0149   db        ?

d_014a   dw        ?                        ; identifik쟴or souboru 2
d_014c   db        ?
d_014d   db        ?

d_014e   dw        ?                        ; identifik쟴or souboru 3
d_0150   db        ?
d_0151   db        ?

d_0152   dw        ?                        ; identifik쟴or souboru 4
d_0154   db        ?
d_0155   db        ?

d_0156   dw        ?                        ; identifik쟴or souboru 5
d_0158   db        ?
d_0159   db        ?

; ------ parametry standardn죋o vstupn죋o zaæzen�

d_015a   dw        ?                        ; identifik쟴or stand. vstup. zaæz.
d_015c   db        ?                        ; nebo 0
d_015d   db        ?
d_015e   dw        ?                        ; za뇿tek voln� pam늯i
d_0160   dw        ?                        ; 1=pæznak znakov괿o zaæzen�

         dd        ?

; ------ parametry standardn죋o v쁲tupn죋o zaæzen�

d_0166   dw        ?                        ; identifik쟴or stand. v쁲tup. za�.
d_0168   db        ?                        ; nebo 0
d_0169   db        ?
d_016a   dw        ?
d_016c   dw        ?                        ; 1=pæznak znakov괿o zaæzen�

         dd        ?

d_0172   dw        ?                        ; pæznaky programu
                                            ;   bit 0: 1=blok programu se zmenÆ
                                            ;   bit 1: 1=povoleny slu멳y 44h
                                            ;   bit 2: 1=povolena obsluha Ctrl-C
                                            ;   bit 3: 1=instaluje se INT 03h
d_0174   dw        ?                        ; vrchol z쟳obn죏u (ukazatel SP)
d_0176   dw        ?                        ; ?
d_0178   dw        ?                        ; ?
d_017a   dw        ?                        ; adresa tabulky ident. soubor�
d_017c   dw        ?                        ; maxim.po놽t identifik쟴or� soubor�
d_017e   dw        ?                        ; adresa obsluhy p쯥ru쮍n�
d_0180   db        ?                        ; n쟶rat. k줰 chyby diskov� operace
d_0181   db        ?
d_0182   dw        ?
d_0184   dw        ?
d_0186   dw        ?                        ; adresa vzniku chyby programu
d_0188   dw        ?
d_018a   dd        ?                        ; adresa za뇿tku voln� pam늯i
d_018e   dd        ?                        ; p뻱odn� adresa INT 00h
d_0192   dw        ?                        ; buffer pro 즧chovu znaku z kl쟶es.
d_0194   db        ?                        ; bit 0: 1 = povolena obsluha Ctrl-C
                                            ; bit 1: 1 = nastalo p쯥ru쮍n� INT 3
d_0195   db        ?
d_0196   db        80 dup(?)               ; domovsk� adres젵 tohoto programu
d_01E6   db        ?                        ; maxim쟫n� d굃ka 쯥t늷ce 눀sla
d_01E7   db        ?
d_01E8   dd        ?                        ; adresa bufferu k dek줰ov쟮� 눀sla
d_01EC   dd        ?
d_01F0   dd        ?
d_01F4   db        6 dup(?)                 ; buffer 눀sla REAL k dek줰ov쟮�
d_01FA   db        ?
d_01FB   db        ?

; ------ gener쟴or n쟦odn괿o 눀sla

d_01FC   dd        ?                        ; st쯠da� n쟦odn괿o 눀sla


d_0200   db        ?                        ; velikost c죐ov괿o bufferu
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
d_0226   db        12 dup(?)                ; buffer k dek줰ov쟮� mantisy 눀sla
d_0232   dd        ?                        ; adresa definice stand. zaæzen�
         dw        ?
d_0238   db        ?                        ; bit 0:1=vytvo쯥n�/0=otev쯥n� soub.
         db        ?
d_023A   dw        3 dup(?)
d_0240   dw        16 DUP (?)               ; tabulka identifik쟴or� soubor�

; -----------------------------------------------------------------------------
;        u멼vatelsk� data
; -----------------------------------------------------------------------------

; ------ definice registr� pro vol쟮� slu멳y DOS

d_0260   dw        ?                        ; registr AX pro vol쟮� INT 21h
d_0262   dw        ?                        ; registr BX pro vol쟮� INT 21h
d_0264   dw        ?                        ; registr CX pro vol쟮� INT 21h
d_0266   dw        ?                        ; registr DX pro vol쟮� INT 21h
         dw        ?                        ; registr BP pro vol쟮� INT 21h
         dw        ?                        ; registr SI pro vol쟮� INT 21h
         dw        ?                        ; registr DI pro vol쟮� INT 21h
d_026E   dw        ?                        ; registr DS pro vol쟮� INT 21h
d_0270   dw        ?                        ; registr ES pro vol쟮� INT 21h
d_0272   dw        ?                        ; registr pæznak� FLAG pro INT 21h

; ------ definice textov쁟h 찤dk� (adresy po뇿tk� 찤dk�, 0=voln� popisova�)
; V쮍chny prostory maj� p쯫d늢en velikost bloku podle skute뇆괿o po뇍u 찤dk�,
; pouze aktivn� prostor m� p쯫d늢en blok o maxim쟫n� velikosti v놽tn� pr쟺dn쁟h
; 찤dk�. Tabulka obsahuje adresy po뇿tk� 찤dk� SEGMENT:OFFSET, 0=nen� 찤dek)

d_0274   dd        MAXLINES+1 dup(?)        ; definice 찤dk� (adresy po뇿tk�)

; ------ buffer seznamu soubor� (na뇍en� obsah adres젵e)/diskov� buffer 1800h B

; Struktura (256 polo멷k po 23 bajtech)
;    0: (1) d굃ka jm굈a polo멾y + 1 (v놽tn� n쟳leduj죅죋o bajtu)
;    1: (1) typ polo멾y  0=adres젵, " "=soubor
;    2: (13) jm굈o polo멾y ASCII
;   15: (2) 놹s polo멾y
;   17: (2) datum polo멾y
;   19: (4) velikost polo멾y
; 6218 bajt�, 256 polo멷k po 23 bajtech

d_CD98   db        256 * 23 dup(?)          ; buffer seznamu soubor�, disk.buff.
         db        330 dup(?)               ; zbytek diskov괿o bufferu


d_E5E2   dw        ?
d_E5E4   dw        80 dup(?)                ; tabulka 눀sel zobrazen쁟h 찤dk�

d_E684   db        8 dup(?)

d_E68C   db        ?
d_E68D   db        ?
d_E68E   db        ?
d_E68F   db        ?                        ; posledn� znak z ASCII tabulky

; ------ ukazatele aktivn죋o editovan괿o prostoru

d_E690   dw        ?                        ; 찤dek za뇿tku bloku
d_E692   dw        ?                        ; 찤dek konce bloku
d_E694   dw        ?                        ; pozice za뇿tku sloupcov괿o bloku
d_E696   dw        ?
d_E698   dw        ?                        ; 눀slo aktivn죋o editovan괿o 찤dku
d_E69A   dw        ?                        ; pozice kurzoru na 찤dku
d_E69C   dw        ?                        ; 눀slo 찤dku kurzoru na obrazovce
d_E69E   dw        ?                        ; maxim쟫n� po놽t 찤dk� prostoru
                                            ; (p쯫 즧chov� parametru se prostor
                                            ;  pro soubor zmenÆ na skute뇆�
                                            ;  po놽t 찤dk� prostoru)
d_E6A0   dw        ?                        ; 찤dek uschovan� zna뇃y v textu
d_E6A2   dw        ?                        ; pozice uschovan� zna뇃y v textu
d_E6A4   dw        ?                        ; offset za뇿tku zobrazen괿o 찤dku
d_E6A6   dw        ?                        ; maxim쟫n� d굃ka 찤dku od L okraje
d_E6A8   db        ?                        ; 0=pæznak modifikace textu
d_E6A9   db        ?                        ; 1=pæznak zapnut� zobrazen� bloku
d_E6AA   db        ?                        ; 1=pæznak sloupcov괿o bloku
d_E6AB   dd        10 dup(?)                ; adresy 찤dk� z쟦lav�
d_E6D3   dd        10 dup(?)                ; adresy 찤dk� paty

d_E6FB   db        ?,128 dup(?)             ; jm굈o editovan괿o souboru (buffer)

; ------ uschovan� ukazatele editovan괿o prostoru

d_E77C   db        5 * PARSIZU dup(?)       ; uschovan� ukazatele

; ------ uschovan� parametry editovan괿o prostoru (p쯥p죒a놽)

d_EC18   db        5*13 dup(?)              ; uschovan� parametry edit. prostor�


d_ec59   db        ?,255 dup(?)             ; buffer textov괿o 찤dku
d_ed59   db        ?,255 dup(?)             ; buffer atribut� znak� 찤dku
                                            ;   bit 0: 1=nadsazen� znak
                                            ;   bit 1: 1=podsazen� znak
                                            ;   bit 2: 1=쮑km� p죛mo
                                            ;   bit 3: 1=podtr멷n� znak
                                            ;   bit 4: 1=zv쁱azn늧� znak
                                            ;   bit 5: 1=inverzn� znak
                                            ;   bit 6: 1=znak s rozd늢.znam굈kem
                                            ;   bit 7: 1=dvojn쟳obn� Æ쯭a znaku
d_ee59   db        ?,255 dup(?)             ; buffer textu (Ctrl-^ a Ctrl-])
d_ef59   db        ?,255 dup(?)
d_f059   db        ?,255 dup(?)             ; druh� 뇿st 찤dku po rozd늢en�
d_f159   db        ?,255 dup(?)             ; druh� 뇿st atribut� 찤dku po rozd.
d_f259   db        ?,255 dup(?)             ; buffer p쯥hr쟶an� makrokl쟶esy
d_F359   db        ?,255 dup(?)             ; edita뇆� buffer zad쟮� parametru

d_F459   db        ?,128 dup(?)             ; text k hled쟮�
d_F4DA   db        ?,128 dup(?)             ; text k nahrazen�
d_F55B   db        ?,128 dup(?)             ; jm굈o souboru ke 뇍en� bloku
d_F5DC   db        ?,128 dup(?)             ; jm굈o souboru k z쟰isu bloku
d_F65D   db        ?,128 dup(?)             ; jm굈o 뇍en괿o souboru z disku
d_F6DE   db        ?,128 dup(?)             ; jm굈o startovan괿o programu
d_F75F   db        ?,14 dup(?)              ; zadan� pozice kurzoru v souboru

d_F76E   db        15 dup(?)

d_F77D   db        ?,8 dup(?)               ; buffer parametr� hled쟮�

d_F786   db        ?                        ; 1=pæznak zobrazen� horn죋o menu
d_F787   db        ?
d_F788   db        ?                        ; zvolen� aktu쟫n� typ p죛ma
d_F789   db        ?                        ; 1=pæznak modifikace edit. 찤dku
d_F78A   db        ?                        ; 1=pæznak p쯥ru쮍n� editace volby
d_F78B   db        ?                        ; 1=p쯥chodn� vypnut� blik쟮� kurz.
d_F78C   db        ?
d_F78D   db        ?
d_F78E   db        ?
d_F78F   db        ?                        ; 1=pæznak dekadick괿o tabel쟴oru
d_F790   db        ?                        ; 1=povoleno zobrazen� menu
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
d_F79B   db        ?                        ; 즧chova znaku line쟫u-lev� okraj
d_F79C   db        ?                        ; 즧chova znaku line쟫u-prav� okraj
d_F79D   dw        ?                        ; k줰 chyby KonTextu
                                            ;  0 nen� chyba
                                            ;  1 soubor nenalezen
                                            ;  2 chyba 뇍en�
                                            ;  3 chyba z쟰isu
                                            ;  4 adres젵 nenalezen
                                            ;  5 nedostatek pam늯i
                                            ;  6 p쯥kro놽n maxim. po놽t 찤dk�
                                            ;  7 쯥t늷ec nenalezen
                                            ;  8 찤dek pæli� dlouh�
                                            ;  9 chyba zad쟮�
                                            ; 10 nen� ozna놽n blok
                                            ; 11 makrobuffer pln�
                                            ; 12 tisk쟲na nen� v provozu
                                            ; 13 chybn� form쟴 dat
                                            ; 15 tento soubor ji� existuje
                                            ; 16 zdroj.a c죐.soub.jsou identick�
                                            ; 17 prostor @ nen� dosud vyti쮝늧
                                            ; 18 sloupcov� blok nelze ulo멼t
                                            ; 19 nen� ozna놽n sloupc. blok
                                            ; 20 kurz.mus� b쁳 za prav쁬 okrajem
                                            ; 21 nen� soubor EXE ani COM
                                            ; 50 nepovolen� mat. v쁱az
                                            ; 51 p쯥te놽n� des. te뇃y
                                            ; 52 d늢en� nulou
                                            ; 53 chybn� argument
                                            ; 54 chyba argumentu
                                            ; 99 intern� (KONTEXT modifikov쟮)
                                            ; 100 disket. mechanika nepracuje
                                            ; 153 neo놽k쟶an� konec souboru
                                            ; 196 p쯥te놽n� Integer
                                            ; 240 disketa p쯥pln늧a
                                            ; 241 nepovolen� jm굈o souboru

d_F79F   dw        ?                        ; ukazatel p쯥hr쟶an� makrokl쟶esy
d_F7A1   dw        ?                        ; po놽t bajt� v tabulce maker
d_F7A3   dw        ?                        ; skute뇆� po놽t 찤dk� prostoru
d_F7A5   dw        ?                        ; po뇿te뇆� 찤dek prostoru v tabulce
d_F7A7   dw        ?                        ; 눀slo aktivn죋o prostoru
d_F7A9   dw        ?                        ; po놽t 찤dk� na str쟮ku bez okraj�
d_F7AB   dw        ?                        ; uschovan� ukazatel z쟳obn죏u SP
d_F7AD   dw        ?                        ; uschovan� registr BP b늜em editace
d_F7AF   dw        ?                        ; uschovan� registr SP b늜em editace

d_F7B1   dd        80 dup(?)                ; buffer uschovan쁟h 찤dk� k obnov�

d_F8F1   db        0F941h - 0F8F1h dup(?)

d_F941   dw        ?
d_F943   dw        ?
d_F945   db        ?

; ------ tabulka souboru DTA

d_F946   label     byte                     ; tabulka DTA (43 bajt�)
         db        21 dup(?)                ; (rezervov쟮o)
d_F95B   db        ?                        ; 0: DTAAtrib: atributy souboru
         dw        ?                        ; 1: DTATime : 놹s souboru
         dw        ?                        ; 3: DTADate : datum souboru
         dd        ?                        ; 5: DTASize : velikost souboru
         db        13 dup(?)                ; 9: DTAName : jm굈o souboru ASCIIZ

d_F971   db        ?                        ; 1=prov쟡� se v쁞늭 souboru
d_F972   dw        ?                        ; p뻱odn� adresa INT 24h - segment
d_F974   dw        ?                        ; p뻱odn� adresa INT 24h - offset

; ------ ukazatele seznamu soubor�

d_F976   dw        ?                        ; maxim. 찤dek k zobrazen� seznamu
d_F978   dw        ?                        ; po뇿te뇆� zobraz. polo멾a seznamu
d_F97A   dw        ?                        ; polo멾a seznamu s kurzorem
d_F97C   dw        ?                        ; po놽t polo멷k v seznamu soubor�

d_F97E   dw        ?                        ; uschovan� adresa DTA - segment
d_F980   dw        ?                        ; uschovan� adresa DTA - offset
d_F982   dw        ?
d_F984   dw        ?
d_F986   dw        ?
d_F988   dw        ?
d_F98A   dw        ?                        ; 눀slo ti쮝늧괿o prostoru
d_F98C   dw        ?
d_F98E   dw        ?
d_F990   dw        ?
d_F992   dw        ?
d_F994   dw        ?                        ; 1=prob죋� tisk;0=ne
d_F996   dw        ?
d_F998   dw        ?
d_F99A   dw        ?
d_F99C   dw        ?
d_F99E   dw        ?
d_F9A0   dw        ?
d_F9A2   dw        ?                        ; ukazatel znak� v tiskov굆 bufferu
d_F9A4   db        ?
d_F9A5   db        ?
d_F9A6   db        ?,800 dup(?)             ; tiskov� vyrovn쟶ac� buffer


d_FCC7   db        ?,255 dup(?)

d_fdc7   dd        ?                        ; adresa vstupn죋o bodu SCREEN.OVL
d_fdcb   dw        ?                        ; po놽t graf.linek na 찤dek textu
d_fdcd   dw        ?                        ; max. po놽t znak� na 찤dek displeje
d_fdcf   dw        ?                        ; po놽t zobrazen쁟h textov쁟h 찤dk�
d_fdd1   db        4 dup(?)                 ; identifika뇆� 쯥t늷ec graf. karty
d_FDD5   db        128 dup(?)               ; pæstupov� cesta k SCREEN.OVL

         db        ?
d_fe56   db        ?                        ; m줰 zobrazen� znaku
                                            ;   bit 0: 1=nadsazen� znak
                                            ;   bit 1: 1=podsazen� znak
                                            ;   bit 2: 1=쮑km� p죛mo
                                            ;   bit 3: 1=podtr멷n� znak
                                            ;   bit 4: 1=zv쁱azn늧� znak
                                            ;   bit 5: 1=inverzn� znak
                                            ;   bit 6: 1=znak s rozd늢.znam굈kem
                                            ;   bit 7: 1=dvojn쟳obn� Æ쯭a znaku

                                            ; 0=pæznak, 멷 찤dek p쯥s쟦l obraz.
                                            ; 20h=operace se stavov쁬 찤dkem

Data     ENDS

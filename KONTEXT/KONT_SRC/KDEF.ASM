
MAXLINES EQU       13000                    ; maxim†ln° poáet ©†dkñ
MAXPOZL  EQU       239                      ; maxim†ln° pozice kurzoru na ©†dku
MAXLINE  EQU       254                      ; maxim†ln° dÇlka ©†dku
PROSTORU EQU       5                        ; poáet editaán°ch prostorñ

PARSIZU  EQU       27+40+40+129             ; velikost pole ukazatelñ prostoru
                                            ;   (0ECh = 236)
PARSIZP  EQU       13                       ; velikost pole parametrñ prostoru

; -----------------------------------------------------------------------------
;        konstanty
; -----------------------------------------------------------------------------

CtrlA    EQU       1
CtrlB    EQU       2
CtrlC    EQU       3
CtrlD    EQU       4
CtrlE    EQU       5
CtrlF    EQU       6
CtrlG    EQU       7
CtrlH    EQU       8
CtrlI    EQU       9
CtrlJ    EQU       10
CtrlK    EQU       11
CtrlL    EQU       12
CtrlM    EQU       13
CtrlN    EQU       14
CtrlO    EQU       15
CtrlP    EQU       16
CtrlQ    EQU       17
CtrlR    EQU       18
CtrlS    EQU       19
CtrlT    EQU       20
CtrlU    EQU       21
CtrlV    EQU       22
CtrlW    EQU       23
CtrlX    EQU       24
CtrlY    EQU       25
CtrlZ    EQU       26

b0       EQU       1
b1       EQU       2
b2       EQU       4
b3       EQU       8
b4       EQU       10h
b5       EQU       20h
b6       EQU       40h
b7       EQU       80h
b8       EQU       100h
b9       EQU       200h
b10      EQU       400h
b11      EQU       800h
b12      EQU       1000h
b13      EQU       2000h
b14      EQU       4000h
b15      EQU       8000h

HI       EQU       256

BEL      EQU       7
BS       EQU       8
TAB      EQU       9
LF       EQU       10
FF       EQU       12
CR       EQU       13
EOF      EQU       26
ESCP     EQU       27

; -----------------------------------------------------------------------------
;        tabulka DTA
; -----------------------------------------------------------------------------

DTA      EQU       43                       ; dÇlka tabulky DTA
DTAAtrib EQU       15h                      ; (1) atributy souboru
DTATime  EQU       16h                      ; (2) áas souboru
DTADate  EQU       18h                      ; (2) datum souboru
DTASize  EQU       1Ah                      ; (4) velikost souboru
DTAName  EQU       1Eh                      ; (13) jmÇno souboru

; -----------------------------------------------------------------------------
;        k1.asm
; -----------------------------------------------------------------------------
;˛
GLOBAL   l_18BB:NEAR,l_162F:NEAR,l_1722:NEAR,l_179C:NEAR,l_0EC7:NEAR
GLOBAL   l_093A:NEAR,l_0A81:NEAR,l_0186:NEAR,l_0A7A:NEAR,l_0A56:NEAR
GLOBAL   l_0A44:NEAR,l_0A62:NEAR,l_136C:NEAR,l_19AD:NEAR,l_1AD3:NEAR
GLOBAL   l_1188:NEAR,l_0AAA:NEAR,l_10FC:NEAR,l_1F22:NEAR,l_11AD:NEAR
GLOBAL   l_09D9:NEAR,l_0AB7:NEAR,l_0CAD:NEAR,l_0DF3:NEAR,l_11DC:NEAR
GLOBAL   l_1475:NEAR,l_10B1:NEAR,l_1618:NEAR,l_06A4:NEAR,l_05AD:NEAR
GLOBAL   l_0F2E:NEAR,l_10B4:NEAR,l_0F25:NEAR,l_1609:NEAR,l_135F:NEAR
GLOBAL   l_0F03:NEAR,l_1408:NEAR,l_11C6:NEAR,l_121E:NEAR,l_1460:NEAR
GLOBAL   l_12DE:NEAR,l_1204:NEAR,l_13B0:NEAR,l_1950:NEAR,l_1BC0:NEAR
GLOBAL   l_1B0C:NEAR,l_1003:NEAR,l_0F48:NEAR,l_0F70:NEAR,l_125B:NEAR
GLOBAL   l_07BE:NEAR,l_1970:NEAR,l_1A6D:NEAR,l_195F:NEAR,l_1983:NEAR
GLOBAL   l_199E:NEAR,l_0E0C:NEAR,l_0FFC:NEAR,l_1267:NEAR,l_0E68:NEAR
GLOBAL   l_1320:NEAR,l_1A97:NEAR,l_19BC:NEAR,l_0C6A:FAR,l_07FB:NEAR
GLOBAL   l_1A53:NEAR,l_1AD7:NEAR,l_19E3:NEAR,l_19EB:NEAR,l_1A87:NEAR
GLOBAL   l_1B15:NEAR,l_1B2A:NEAR,l_1D89:NEAR,l_19D4:NEAR,l_1A05:NEAR
GLOBAL   l_1C30:NEAR,l_1CE0:NEAR,l_1B9D:NEAR,l_1B88:NEAR,l_1D89:NEAR
GLOBAL   l_14D9:NEAR,l_14F2:NEAR,l_15BE:NEAR,l_0E6C:NEAR,l_14EB:NEAR
GLOBAL   l_1264:NEAR,l_0DB6:NEAR,l_0D99:NEAR,Start:NEAR

GLOBAL   d_0226:BYTE,d_0225:BYTE,d_0224:BYTE,d_0238:BYTE,d_0166:WORD
GLOBAL   d_00B6:BYTE,d_0238:BYTE,d_0180:BYTE,d_0186:WORD,d_0172:WORD
GLOBAL   d_0238:BYTE,d_0232:DWORD,d_015C:BYTE,d_0181:BYTE,d_0182:WORD
GLOBAL   d_0184:WORD,d_023A:WORD,d_0174:WORD,d_017E:WORD,d_0240:WORD
GLOBAL   d_0136:WORD,d_0138:WORD,d_013A:WORD,d_013C:WORD,d_013E:WORD
GLOBAL   d_0140:WORD,d_0142:WORD,d_0144:WORD,d_0260:WORD,d_0266:WORD
GLOBAL   d_015A:WORD,d_FE56:BYTE,d_FDC7:DWORD,d_FDCB:WORD,d_E6A4:WORD
GLOBAL   d_FDCD:WORD,d_FDCF:WORD,d_FDD1:BYTE,d_0264:WORD
GLOBAL   d_EC59:BYTE,d_ED59:BYTE,d_EE59:BYTE,d_EF59:BYTE,d_F059:BYTE
GLOBAL   d_F159:BYTE,d_F259:BYTE,d_F79D:WORD,d_0274:DWORD,d_F7A3:WORD
GLOBAL   d_F7A5:WORD,d_E6A8:BYTE,d_F7AB:WORD,d_E69E:WORD,d_E6A0:WORD
GLOBAL   d_E690:WORD,d_E692:WORD,d_E6A9:BYTE,d_F79B:BYTE,d_F79C:BYTE
GLOBAL   d_EC18:BYTE,d_018A:DWORD,d_F7A9:WORD,d_F69C:WORD
GLOBAL   d_F7A1:WORD,d_F7A7:WORD,d_E6AA:BYTE,d_E694:WORD,d_E696:WORD
GLOBAL   d_F786:BYTE,d_F78F:BYTE,d_F789:BYTE,d_F78C:BYTE,d_F994:WORD
GLOBAL   d_E69C:WORD,d_E6FB:BYTE,d_E68E:BYTE,d_E698:WORD,d_E69A:WORD
GLOBAL   d_E6A6:WORD,d_E5E4:WORD,d_F988:WORD,d_F98C:WORD
GLOBAL   d_F98E:WORD,d_F986:WORD,d_F9A6:BYTE,d_F982:WORD,d_F99E:WORD
GLOBAL   d_F98A:WORD,d_FCC7:BYTE,d_F990:WORD,d_F984:WORD,d_F996:WORD
GLOBAL   d_F9A0:WORD,d_F9A5:BYTE,d_F9A4:BYTE,d_F992:WORD,d_F998:WORD
GLOBAL   d_F99C:WORD,d_F99A:WORD,d_F9A2:WORD,d_F79F:WORD,d_E68F:BYTE
GLOBAL   d_F78A:BYTE,d_F359:BYTE,d_F790:BYTE,d_F941:WORD,d_F943:WORD
GLOBAL   d_F945:BYTE,d_F8F1:BYTE,d_F7B1:DWORD,d_F79D:BYTE
GLOBAL   d_F459:BYTE,d_F972:WORD,d_F974:WORD,d_026E:WORD,d_F974:WORD
GLOBAL   d_002A:WORD,d_F946:BYTE,d_E5E2:WORD,d_F95B:BYTE
GLOBAL   d_F76E:BYTE,d_0272:WORD,d_CD98:BYTE,d_E6AB:DWORD,d_F76E:BYTE
GLOBAL   d_F5DC:BYTE,d_E6D3:DWORD,d_F55B:BYTE,d_F65D:BYTE,d_F971:BYTE
GLOBAL   d_F978:WORD,d_F976:WORD,d_F97C:WORD,d_F97A:WORD,d_F6DE:BYTE
GLOBAL   d_F97E:WORD,d_F980:WORD,d_F982:WORD,d_F798:BYTE,d_E68D:BYTE
GLOBAL   d_FDD5:BYTE,d_F78D:BYTE,d_F78E:BYTE,d_F799:BYTE,d_F79A:BYTE
GLOBAL   d_F787:BYTE,d_F788:BYTE,d_F793:BYTE,d_F791:BYTE,d_F792:BYTE
GLOBAL   d_F794:BYTE,d_F795:BYTE,d_F796:BYTE,d_F797:BYTE,d_F4DA:BYTE
GLOBAL   d_F77D:BYTE,d_E6A2:WORD,d_F75F:BYTE,d_F78B:BYTE,d_E68C:BYTE
GLOBAL   d_E684:BYTE,d_F7AD:WORD,d_F7AF:WORD,d_0188:WORD,d_0270:WORD
GLOBAL   d_0262:WORD,d_00B60:BYTE,d_0136:BYTE,d_E77C:BYTE

; -----------------------------------------------------------------------------
;        k2.asm
; -----------------------------------------------------------------------------

GLOBAL   l_2CB6:NEAR,l_2307:NEAR,l_230B:NEAR,l_23E4:NEAR,l_20AA:NEAR
GLOBAL   l_2080:NEAR,l_219E:NEAR,l_2225:NEAR,l_24E9:NEAR,l_2819:NEAR
GLOBAL   l_2C0F:NEAR,l_2940:NEAR,l_2B71:NEAR,l_2B8E:NEAR,l_28F1:NEAR
GLOBAL   l_28D9:NEAR,l_2BBF:NEAR,l_2945:NEAR,l_29F6:NEAR,l_299C:NEAR
GLOBAL   l_29C1:NEAR,l_298A:NEAR,l_2A66:NEAR,l_29B9:NEAR

GLOBAL   l_36BB:NEAR,l_3EB2:NEAR,l_36F5:NEAR,l_39D4:NEAR,l_3C8D:NEAR
GLOBAL   l_3F89:NEAR,l_3FB7:NEAR,l_3FED:NEAR,l_3ACA:NEAR,l_34E1:NEAR
GLOBAL   l_34C7:NEAR,l_35B7:NEAR,l_34F8:NEAR,l_3E83:NEAR,l_3F5A:NEAR
GLOBAL   l_3B6A:NEAR,l_3C04:NEAR,l_3A2E:NEAR,l_3589:NEAR,l_355B:NEAR
GLOBAL   l_387D:NEAR,l_384B:NEAR,l_38AF:NEAR,l_38DD:NEAR,l_3589:NEAR
GLOBAL   l_390B:NEAR,l_372A:NEAR,l_3950:NEAR,l_376B:NEAR,l_37F3:NEAR
GLOBAL   l_3799:NEAR,l_3F09:NEAR,l_367B:NEAR,l_3631:NEAR,l_3D53:NEAR
GLOBAL   l_3DC5:NEAR,l_3EDF:NEAR,l_361C:NEAR,l_35CE:NEAR,l_352A:NEAR
GLOBAL   l_399E:NEAR

GLOBAL   l_3199:BYTE,l_30C1:BYTE,l_312D:BYTE,l_31E1:BYTE,l_3217:BYTE
GLOBAL   l_2CD9:BYTE,l_3278:BYTE,l_324F:BYTE,l_3220:BYTE,l_3231:BYTE
GLOBAL   l_3259:BYTE,l_325A:BYTE,l_325B:BYTE,l_325C:BYTE,l_325D:BYTE
GLOBAL   l_3263:BYTE,l_3264:BYTE,l_3267:BYTE,l_326C:BYTE,l_326F:BYTE
GLOBAL   l_34AD:WORD,l_3258:BYTE,l_3251:BYTE,l_324E:BYTE,l_3257:BYTE
GLOBAL   l_3248:BYTE,l_3242:BYTE,l_3378:BYTE,l_326E:BYTE,l_3261:BYTE
GLOBAL   l_3262:BYTE,l_3265:BYTE,l_3263:BYTE,l_34AF:WORD,l_34B1:WORD
GLOBAL   l_34B3:BYTE,l_3271:BYTE,l_3272:BYTE,l_326A:BYTE
GLOBAL   l_3273:BYTE,l_3274:BYTE,l_3275:BYTE,l_326B:BYTE,l_3269:BYTE
GLOBAL   l_3478:BYTE,l_34A0:BYTE,l_3276:BYTE,l_3277:BYTE,l_3268:BYTE
GLOBAL   l_325E:BYTE,l_3D1C:NEAR,l_3270:BYTE,l_325F:BYTE,l_3260:BYTE
GLOBAL   l_3266:BYTE,l_324A:BYTE

; -----------------------------------------------------------------------------
;        k3.asm
; -----------------------------------------------------------------------------

GLOBAL   l_5F02:NEAR,l_48CB:NEAR,l_4855:NEAR,l_5D74:NEAR,l_5CE8:NEAR
GLOBAL   l_4897:NEAR,l_4A3C:NEAR,l_4C6D:NEAR,l_555F:NEAR,l_4978:NEAR
GLOBAL   l_5972:NEAR,l_4832:NEAR,l_5C9F:NEAR,l_5C32:NEAR,l_4832:NEAR
GLOBAL   l_5CB8:NEAR,l_5DC2:NEAR,l_5D88:NEAR,l_5C8B:NEAR,l_425F:NEAR
GLOBAL   l_4D50:NEAR,l_54DE:NEAR,l_4E5D:NEAR,l_4CC6:NEAR,l_591F:NEAR
GLOBAL   l_4304:NEAR,l_43BF:NEAR,l_4450:NEAR,l_4167:NEAR,l_4EE9:NEAR
GLOBAL   l_550C:NEAR,l_48FC:NEAR,l_43F3:NEAR,l_56C0:NEAR,l_44E7:NEAR
GLOBAL   l_4053:NEAR,l_4AAB:NEAR,l_4B97:NEAR,l_5444:NEAR,l_468D:NEAR
GLOBAL   l_5A89:NEAR,l_418B:NEAR,l_5DAD:NEAR,l_5414:NEAR,l_40D2:NEAR
GLOBAL   l_59E4:NEAR,l_5E8C:NEAR,l_557A:NEAR,l_4361:NEAR,l_491F:NEAR
GLOBAL   l_5CFC:NEAR,l_441E:NEAR,l_4EAB:NEAR,l_5317:NEAR,l_5E21:NEAR
GLOBAL   l_5DDF:NEAR,l_5FE6:NEAR,l_5D3A:NEAR

; -----------------------------------------------------------------------------
;        k4.asm
; -----------------------------------------------------------------------------

GLOBAL   l_7534:NEAR,l_6445:NEAR,l_6419:NEAR,l_7463:NEAR,l_652C:NEAR
GLOBAL   l_739F:NEAR,l_63DA:NEAR,l_73F7:NEAR,l_6E80:NEAR,l_725B:NEAR
GLOBAL   l_7E64:NEAR,l_7EC8:NEAR,l_79D9:NEAR,l_7886:NEAR,l_6E3A:NEAR
GLOBAL   l_64D0:NEAR,l_646C:NEAR,l_60F6:NEAR,l_608C:NEAR,l_65E5:NEAR
GLOBAL   l_6801:NEAR,l_6816:NEAR,l_6886:NEAR,l_6144:NEAR,l_70A6:NEAR
GLOBAL   l_6618:NEAR,l_66AD:NEAR,l_66E8:NEAR,l_6B48:NEAR,l_6D3D:NEAR
GLOBAL   l_7F88:NEAR,l_7FF1:NEAR,l_67B7:NEAR,l_632A:NEAR,l_61AC:NEAR
GLOBAL   l_672C:NEAR,l_676D:NEAR,l_6266:NEAR,l_629C:NEAR,l_6003:NEAR
GLOBAL   l_7D61:NEAR

; -----------------------------------------------------------------------------
;        k5.asm
; -----------------------------------------------------------------------------

GLOBAL   l_97DD:NEAR,l_9B20:NEAR,l_9C15:NEAR
GLOBAL   l_9AB1:NEAR,l_9A61:NEAR,l_9840:NEAR,l_98AF:NEAR,l_9916:NEAR
GLOBAL   l_8062:NEAR,l_92F4:NEAR,l_9826:NEAR,l_918B:NEAR,l_8514:NEAR
GLOBAL   l_9826:NEAR,l_962A:NEAR

GLOBAL   l_9AB8:BYTE,l_9A51:BYTE

; -----------------------------------------------------------------------------
;        k6.asm
; -----------------------------------------------------------------------------

GLOBAL   l_BC32:NEAR,l_A666:NEAR,l_BCDB:NEAR,l_B7D2:NEAR,l_B7F0:NEAR
GLOBAL   l_BF2E:NEAR,l_BF6E:NEAR,l_BFC9:NEAR,l_BFAB:NEAR,l_B797:NEAR
GLOBAL   l_B828:NEAR,l_BFE3:NEAR,l_B533:NEAR,l_B63D:NEAR,l_B3AE:NEAR
GLOBAL   l_A973:NEAR,l_B9FD:NEAR,l_A958:NEAR,l_A9CB:NEAR,l_ACF4:NEAR
GLOBAL   l_A6B6:NEAR,l_B222:NEAR,l_B20D:NEAR,l_B237:NEAR,l_B6BA:NEAR
GLOBAL   l_B363:NEAR,l_AD5F:NEAR

; -----------------------------------------------------------------------------
;        k7.asm
; -----------------------------------------------------------------------------

GLOBAL   l_DD08:NEAR,l_D297:NEAR,l_DD51:NEAR
GLOBAL   l_D692:NEAR,l_D6C9:NEAR,l_C9C1:NEAR,l_DD7B:NEAR,l_D764:NEAR
GLOBAL   l_D7F0:NEAR,l_D482:NEAR,l_D737:NEAR,l_DBB2:NEAR,l_DBCF:NEAR
GLOBAL   l_DBEC:NEAR,l_DC09:NEAR,l_DCA9:NEAR,l_C997:NEAR,l_C3F1:NEAR
GLOBAL   l_C9C1:NEAR,l_D2E5:NEAR,l_DEFB:NEAR,l_C53E:NEAR,l_C14D:NEAR
GLOBAL   l_C71A:NEAR

; -----------------------------------------------------------------------------
;        k8.asm
; -----------------------------------------------------------------------------

GLOBAL   l_FAA0:NEAR

;˛
;; -----------------------------------------------------------------------------
;;        struktura form†tu CONTEXT
;; -----------------------------------------------------------------------------
;
;0   - nadsazen° zap/vyp
;1   - podsazen° zap/vyp
;2   - kurz°va zap/vyp
;3   - podtrëen° zap/vyp
;4   - zvòraznànò tisk zap/vyp
;5   - pouze pro vnit©n° pouëit° (inverzn° p°smo-uëiv.funkce)
;6   - oznaáen° rozdàlovac°ho znamÇnka slova na konci ©†dku
;      Pro  p©echodnÇ oznaáen° rozdàlovac°ho znamÇnka v textu (tj. nen°
;      viditelnÇ) je posledn° znak ve slabice (tj. p©i rozdàlov†n° bude
;      um°stàn na konci ©†dku) or†mov†n dvàma znaky s k¢dem 6. Jinak je
;      na konci ©†dku um°stàn znak s k¢dem 6 a rozdàlovac° znak - (toto
;      nastaven°  je  pouëito z dñvodu, aby jinÇ editory p©i ignorov†n°
;      znaku  s  k¢dem 6 byly schopny spr†vnà interpretovat rozdàlovac°
;      znamÇnka v textu).
;7   - vnit©n° pouëit° - p©echodnÇ rozdàlen°
;10  - znak  LF  (novò  ©†dek  v tabulce ASCII) - v KonTextu je ukl†d†n
;      spolu  se  znakem  CR  jako posloupnost znakñ pro ukonáen° ©†dku
;      (posloupnost  k¢dñ CR LF = 13,10), p©i áten° a pr†ci s textem se
;      ignoruje.
;13  - znak CR (konec ©†dku) - je pouë°v†n jako znak pro ukonáen° ©†dku
;      textu - p©i ukl†d†n° textu je n†sledov†n znakem LF (k¢d 10).
;16  - znak pro oznaáen° zaá†tku odstavce
;17  - znak  pro  oznaáen°  konce odstavce - text bude form†tov†n v˙od-
;      stavci po ©†dek, ukonáenò touto znaákou.
;21  - znak paragrafu (jako norm†ln° znak, lze jej zadat jako <Ctrl>-U)
;26  - znak  EOF  -  oznaáuje  konec souboru, data za t°mto znakem jsou
;      ignorov†na,  p©i  ukl†d†n°  textu  je to posledn° bajt, kterò je
;      uloëen v souboru.
;31  - oznaáen°  neform†tovanÇho  odstavce  -  n†sleduj°c°  text nebude
;      form†tov†n.
;255 - oznaáuje  znak, kterò za n°m n†sleduje, jako znak s dvojn†sobnou
;      ®°©kou  (mus° n†sledovat p©ed kaëdòm znakem v textu s dvojn†sob-
;      nou ®°©kou)
;
;; -----------------------------------------------------------------------------
;;        sluëby ovladaáe SCREEN.OVL
;; -----------------------------------------------------------------------------
;BX =  0 - vòstup znaku na danou pozici
;             VSTUP: SS:[BP+4] = ©†dek pro vykreslen° znaku
;                    SS:[BP+6] = pozice znaku na ©†dku
;                    SS:[BP+8] = znak k vòstupu (k¢d ASCII)
;                                (k¢d 255 - n†sleduj°c° znak bude m°t
;                                     dvojn†sobnou ®°©ku - dvà pozice)
;                    AH = m¢d pro vykreslen° znaku
;                             bit 0 = nadsazenò znak ("superscript")(=1)
;                             bit 1 = podsazenò znak ("subscript")(=2)
;                             bit 2 = ®ikmÇ p°smo (=4)
;                             bit 3 = podtrëenò znak (=8)
;                             bit 4 = zvòraznànò znak (=16)
;                             bit 5 = inverzn° znak (=32)
;                             bit 6 = znak s rozdàlovac°m znamÇnkem(=64)
;
;BX =  1 - vykreslen° kurzoru, maz†n° okna
;             VSTUP: SS:[BP+4] = parametr pro vykreslen° okna
;                                   0 = norm†ln° okno
;                                   1 = invertovanÇ okno
;                                   2 = kurzor
;                    SS:[BP+6] = koncovò ©†dek
;                    SS:[BP+8] = koncov† pozice
;                    SS:[BP+10] = poá†teán° ©†dek
;                    SS:[BP+12] = poá†teán° pozice
;
;BX =  2 - rolov†n° okna nahoru
;             VSTUP: SS:[BP+4] = koncovò ©†dek okna k rolov†n°
;                    SS:[BP+6] = koncov† pozice okna k rolov†n°
;                    SS:[BP+8] = poá†teán° ©†dek okna k rolov†n°
;                    SS:[BP+10] = poá†teán° pozice okna k rolov†n°
;
;BX =  3 - rolov†n° okna dolñ
;             VSTUP: SS:[BP+4] = koncovò ©†dek okna k rolov†n°
;                    SS:[BP+6] = koncov† pozice okna k rolov†n°
;                    SS:[BP+8] = poá†teán° ©†dek okna k rolov†n°
;                    SS:[BP+10] = poá†teán° pozice okna k rolov†n°
;
;BX =  4 - vykreslen° pravÇho okraje (á†ra)
;             VSTUP: SS:[BP+4] = maska pro vykreslen° á†ry (vzhled)
;                    SS:[BP+6] = posledn° ©†dek pro vykreslen° á†ry
;                    SS:[BP+8] = prvn° ©†dek pro vykreslen° á†ry
;                    SS:[BP+10] = pozice na ©†dku pro vykreslen° á†ry
;
;BX =  5 - inicializace parametrñ displeje (nastaven° m¢du)
;             VSTUP: SS:[BP+4] = barva podkladu
;                    SS:[BP+6] = barva p°sma
;                    SS:[BP+8] = poëadovanò m¢d ©†dkov†n° (1 aë 3)
;             VùSTUP: AX = poáet znakñ na ©†dek
;                     CX = á°slo posledn°ho ©†dku
;                     CS:SI = ukazatel na identifikaci graf.karty("CGA")
;
;BX =  6 - zpàtnÇ nastaven° textovÇho m¢du - nastav° videom¢d 3
;
;BX =  7 - poskytnut° adresy n†povàdy
;            VSTUP: SS:[BP+4] = á°slo textu n†povàdy 0 aë 34
;            VùSTUP: ES:SI = adresa textu n†povàdy
;             (text je ukonáen batem 0)
;           0  Ctrl-Shift                17  Ctrl-OS
;           1  Ctrl-J                    18  Ctrl-OZ
;           2  Ctrl-K                    19  parametry hled†n°
;           3  Ctrl-O                    20  text nebude uloëen
;           4  Ctrl-P                    21  zvl†®tn° znaky
;           5  Ctrl-Q                    22  uloëen° nastaven°
;           6  Ctrl-JC                   23  Ctrl-KN
;           7  Ctrl-JI                   24  volba sÇriovÇho tisku
;           8  Ctrl-JK                   25  pauza sÇriovÇho tisku
;           9  Ctrl-KD                   26  menu Kurzor
;          10                            27  menu Maz†n°
;          11  volba str†nek k tisku     28  menu Blok
;          12  prob°h† tisk textu        29  menu P°smo
;          13  Ctrl-KQ                   30  menu Form†t
;          14  Ctrl-OE                   31  menu Str†nka
;          15  Ctrl-OI                   32  menu Displej
;          16  Ctrl-OO                   33  menu Extra
;                                        34  menu Tisk Ctrl-KP
;
;BX =  8 - poskytnut° adresy tabulky chybovòch hl†®en°
;            VùSTUP: ES:SI = adresa tabulky chybovòch hl†®en°
;             (v tabulce je vëdy 1. bajt á°slo chybovÇho hl†®en°,
;              n†sleduje text chybovÇho hl†®en° ukonáenò bajtem 0)
;
;BX =  9 - rozdàlov†n° slov
;
;BX = 10 - dek¢dov†n° k¢du kl†ves (rozk¢dov†n° textu na k¢d kl†vesy)
;            VSTUP: ES:SI = ukazatel textu k rozk¢dov†n°
;            VùSTUP: ES:SI = nov† pozice ukazatele textu
;                    AX = k¢d rozk¢dovanÇ kl†vesy
;
;BX = 11 - vòpis k¢du ©°d°c° kl†vesy (zobrazen° v textovÇm tvaru)
;            VSTUP: DS:[BX+DI] = ukazatel v tiskovÇm bufferu
;                   AX = k¢d kl†vesy
;            VùSTUP: DS:[BX+DI] = nov† adresa ukazatele v bufferu

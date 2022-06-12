comment %

 *************************************************************************

                  zav dˆc¡ sektor opera‡n¡ho syst‚mu

 *************************************************************************

    Zav dˆc¡  sektor  opera‡n¡ho  syst‚mu  je  um¡stˆn  v prvn¡m sektoru na
disketˆ  (hlava  0, v lec 0, sektor 1). P©i startu po‡¡ta‡e jej zavede BIOS
pomoc¡ slu‘by INT 19H od adresy 0:7C00H, na kterou potom p©ed  ©¡zen¡.

    Zav dˆc¡  sektor  syst‚mu  resetuje  disk,  zavede  do pamˆti od adresy
0:0500H  prvn¡ sektor z kladn¡ho adres ©e disku, zkontroluje zda jsou prvn¡
dvˆ  polo‘ky  adres ©e  soubory IO.SYS a MSDOS.SYS. Pokud je v¨e v po© dku,
zavede ze za‡ tku datov‚ho prostoru diskety (tj. ze za‡ tku souboru IO.SYS)
od  adresy  0:0700H prvn¡ t©i sektory a p©ed  ©¡zen¡ na tuto adresu (adresa
0070:0000H). Pokud vznikne p©i nˆkter‚ operaci chyba, ohl s¡ chybu zav dˆn¡
syst‚mu a ‡ek  na stisk libovoln‚ kl vesy.

%
         org       7c00H

start:   jmp       boot                     ; start zavadˆ‡e

7c02     db        90h                      ; instrukce NOP
7c03     db        'MSDOS4.0'               ; firemn¡ n zev a verze (OEM)
7c0b   * dw        512                      ; d‚lka sektoru (bajt–)
7c0d     db        2                        ; velikost bloku (sektor–)
7c0e   * dw        1                        ; po‡et rezervov. sektor– p©ed FAT
7c10   * db        2                        ; po‡et aloka‡n¡ch tabulek FAT
7c11   * dw        0070h                    ; max. po‡et polo‘ek z kl. adres ©e
7c13   * dw        02d0h                    ; celkov˜ po‡et sektor– na m‚diu
7c15   * db        0fdh                     ; typ disku (popisova‡ m‚dia)
7c16   * dw        2                        ; po‡et sektor– v jednom FAT
sektnm   dw        9                        ; po‡et sektor– na stopu
7c1a   * dw        2                        ; po‡et hlav disku
7c1c   * dw        0                        ; po‡et skryt˜ch sektor–
7c1e   * dw        0
7c20   * dw        0
7c22     db        0,0
7c24   * db        0                        ; ‡¡slo disku
7c25   * db        0                        ; ‡¡slo hlavy ke ‡ten¡
7c26     db        29h,0d0h,15h,51h,21h
7c2b     db        'NO NAME    FAT12   '



tabdsk:                                     ; zde se ulo‘¡ tabulka diskov˜ch
                                            ; parametr– (p©ekryje ‡ st programu)

comment %

offset:   velikost:

 + 0 (7c3eh) 1        bity 0-3: rychlost krokov.; bity 4-7: ‡as po ‡ten¡ hlavy
 + 1 (7c3fh) 1        bit 0:1=pou‘¡t DMA; bity 2-7: ‡as ‡ten¡ hlavy
 + 2 (7c40h) 1        ‡ek n¡ motoru p©ed vypnut¡m (v jednotk ch 55 ms)
 + 3 (7c41h) 1        velikost sektoru (0=128; 1=256; 2=512; 3=1024)
 + 4 (7c42h) 1        posledn¡ sektor stopy (po‡et sektor–)
 + 5 (7c43h) 1        d‚lka prodlevy pro ‡tec¡/z pisov‚ operace
 + 6 (7c44h) 1        max. d‚lka p©enosu dat
 + 7 (7c45h) 1        d‚lka prodelvy pro form tovac¡ operace
 + 8 (7c46h) 1        pln¡c¡ znak pro form tov n¡ (norm lnˆ 0F6H = 'ö')
 + 9 (7c47h) 1        ‡as p©¡tlaku hlavy (v milisekund ch)
 +10 (7c48h) 1        ‡as pot©ebn˜ k zapnut¡ motoru (v jednotk ch 1/8 sekundy)


 +11 (7c49h) 2        ‡¡ta‡ relativn¡ho ‡¡slo sektoru p©i ‡ten¡ (ni‘¨¡ slovo)
 +13 (7c4Bh) 2        ‡¡ta‡ relativn¡ho ‡¡slo sektoru p©i ‡ten¡ (vy¨¨¡ slovo)
 +15 (7c4dh) 2        ‡¡slo v lce ke ‡ten¡
 +17 (7c4fh) 1        ‡¡slo sektoru ke ‡ten¡
 +18 (7c50h) 2        po‡ te‡n¡ sektor z kladn¡ho adres ©e (ni‘¨¡ slovo)
 +20 (7c52h) 2        po‡ te‡n¡ sektor z kladn¡ho adres ©e (vy¨¨¡ slovo)

        %

boot:                                       ; start programu zavadˆ‡e


7C3E  FA             CLI                    ; z kaz p©eru¨en¡
7C3F  33C0           XOR    AX,AX           ; segment = 0
7C41  8ED0           MOV    SS,AX           ; nastaven¡ segmentu z sobn¡ku 0
7C43  BC007C         MOV    SP,offset start ; ukazatel z sobn¡ku pod program
7C46  16             PUSH   SS              ; = 00
7C47  07             POP    ES              ; ES = 00 (segment 0)
7C48  BB7800         MOV    BX,78h          ; ukazatel disk. parametr– INT 13H
7C4B  36C537         LDS    SI,SS:[BX]      ; DS:SI <-- tabulka disk. parametr–
7C4E  1E             PUSH   DS              ; segment tabulky disk. parametr–
7C4F  56             PUSH   SI              ; offset tabulky diskov˜ch parametr–
7C50  16             PUSH   SS              ; segment 0
7C51  53             PUSH   BX              ; adresa ukazatele tab. disk. param.
7C52  BF3E7C         MOV    DI,offset tabdsk; za‡ tek tabulky parametr–
7C55  B90B00         MOV    CX,11           ; d‚lka tabulky disk. parametr–
7C58  FC             CLD                    ; smˆr p©enosu nahoru
7C59  F3A4           REP    MOVSB           ; na‡ten¡ tabulky disk. parametr–
7C5B  06             PUSH   ES              ; segment 0
7C5C  1F             POP    DS              ; DS <-- 0
7C5D  C645FE0F       MOV    [DI-02],0F      ; 7c3c <-- 0fh
7C61  8B0E187C       MOV    CX,[sektnm]     ; po‡et sektor– na stopu
7C65  884DF9         MOV    [DI-07],CL      ; 7c37 <-- 0
7C68  894702         MOV    [BX+02],AX      ; adresa tab.disk.par.<-- tabdsk
7C6B  C7073E7C       MOV    [BX],offset tabdsk ; nov  adresa tab. disk. par.
7C6F  FB             STI                    ; povolen¡ p©eru¨en¡
7C70  CD13           INT    13              ; reset disku
7C72  727C           JC     7CF0            ; chyba (tisk hl ¨en¡)
7C74  33C0           XOR    AX,AX
7C76  3906137C       CMP    [7C13],AX       ; celkov˜ po‡et sektor– na m‚diu
7C7A  7408           JZ     7C84            ; nen¡ ‘ dn˜ sektor
7C7C  8B0E137C       MOV    CX,[7C13]       ; celkov˜ po‡et sektor– na m‚diu
7C80  890E207C       MOV    [7C20],CX       ; = 0
7C84  A0107C       * MOV    AL,[7C10]       ; po‡et aloka‡n¡ch tabulek FAT
7C87  F726167C       MUL    word ptr [7C16] ; po‡et sektor– v jednom FAT
7C8B  03061C7C       ADD    AX,[7C1C]       ; po‡et skryt˜ch sektor–
7C8F  13161E7C       ADC    DX,[7C1E]       ; = 0
7C93  03060E7C       ADD    AX,[7C0E]       ; po‡et rezervov. sektor– p©ed FAT
7C97  83D200         ADC    DX,0000
7C9A  A3507C         MOV    [7C50],AX       ; po‡ t. sektor z kl. adres ©e (L)
7C9D  8916527C       MOV    [7C52],DX       ; po‡ t. sektor z kl. adres ©e (H)
7CA1  A3497C         MOV    [7C49],AX       ; ‡¡ta‡ rel. ‡. sekt. (ni‘¨¡ slovo)
7CA4  89164B7C       MOV    [7C4B],DX       ; ‡¡ta‡ rel. ‡. sekt. (vy¨¨¡ slovo)
7CA8  B82000         MOV    AX,0020         ; d‚lka polo‘ky adres ©e (bajt–)
7CAB  F726117C       MUL    word ptr [7C11] ; v˜po‡et d‚lky z kl. adres ©e
7CAF  8B1E0B7C       MOV    BX,[7C0B]       ; d‚lka sektoru (bajt–)
7CB3  03C3           ADD    AX,BX           ;
7CB5  48             DEC    AX
7CB6  F7F3           DIV    BX              ; v˜po‡et po‡ te‡n¡ho sektoru dat
7CB8  0106497C       ADD    [7C49],AX       ; ‡¡ta‡ rel. ‡. sekt. (ni‘¨¡ slovo)
7CBC  83164B7C00     ADC    [7C4B],0000     ; ‡¡ta‡ rel. ‡. sekt. (vy¨¨¡ slovo)
7CC1  BB0005         MOV    BX,0500h        ; adresa k zaveden¡ adres ©e
7CC4  8B16527C       MOV    DX,[7C52]       ; po‡ t. sektor z kl. adres ©e (H)
7CC8  A1507C         MOV    AX,[7C50]       ; po‡ t. sektor z kl. adres ©e (L)
7CCB  E88700         CALL   7D55            ; nastaven¡ sektoru, v lce a hlavy
7CCE  7220           JC     7CF0            ; chyba (p©ete‡en¡ disku)
7CD0  B001           MOV    AL,01           ; po‡et sektor– ke ‡ten¡ = 1
7CD2  E8A100         CALL   7D76            ; ‡ten¡ sektoru adres ©e od 0:0500H
7CD5  7219           JC     7CF0            ; chyba ‡ten¡ adres ©e
7CD7  8BFB           MOV    DI,BX           ; konec sektoru adres ©e
7CD9  B90B00         MOV    CX,000B         ; d‚lka jm‚na souboru IO.SYS
7CDC  BEDB7D         MOV    SI,offset soubio ; jm‚no souboru IO.SYS
7CDF  F3A6           REP    CMPSB           ; kontrola jm‚na
7CE1  750D           JNZ    7CF0            ; nen¡ - hl ¨en¡ chyby
7CE3  8D7F20         LEA    DI,[BX+20]      ; DI - ukazuje na druhou polo‘ku
7CE6  BEE67D         MOV    SI,offset soubdos ; jm‚no souboru DOS.SYS
7CE9  B90B00         MOV    CX,000B         ; d‚lka jm‚na DOS.SYS
7CEC  F3A6           REP    CMPSB           ; porovn n¡ jm‚na DOS.SYS
7CEE  7418           JZ     7D08            ; nata‘en¡ zavadˆ‡e syst‚mu
7CF0  BE937D       * MOV    SI,7D93         ; text Nen¡ syst‚mov˜ disk ...
7CF3  E85100         CALL   7D47            ; tisk chybov‚ho hl ¨en¡
7CF6  32E4           XOR    AH,AH           ; funkce ‡ten¡ znaku z kl vesnice
7CF8  CD16           INT    16              ; ‡ek n¡ na stisk kl vesy
7CFA  5E             POP    SI              ;
7CFB  1F             POP    DS
7CFC  8F04           POP    [SI]
7CFE  8F4402         POP    [SI+02]
7D01  CD19           INT    19              ; skok do slu‘by zaveden¡ syst‚mu
7D03  58           * POP    AX
7D04  58             POP    AX
7D05  58             POP    AX
7D06  EBE8           JMP    7CF0            ; skok zpˆt na hl ¨en¡
                                            ; na‡ten¡ 3 sektor– souboru IO.SYS
                                            ; ES = segment (=0)
7D08  BB0007       * MOV    BX,0700h        ; adresa po‡ tku bufferu
7D0B  B90300         MOV    CX,0003         ; po‡et sektor– k na‡ten¡ = 3
7D0E  A1497C         MOV    AX,[7C49]       ; rel. ‡¡slo sektoru - ni‘¨¡ ‡ st
7D11  8B164B7C       MOV    DX,[7C4B]       ; rel. ‡¡slo sektoru - vy¨¨¡ ‡ st
7D15  50           * PUSH   AX              ; ‡¡slo stopy - ni‘¨¡ slovo
7D16  52             PUSH   DX              ; ‡¡slo stopy - vy¨¨¡ slovo
7D17  51             PUSH   CX              ; po‡et sektor–
7D18  E83A00         CALL   7D55            ; nastaven¡ sektoru, v lce a hlavy
7D1B  72E6           JC     7D03            ; chybov‚ hl ¨en¡
7D1D  B001           MOV    AL,01           ; po‡et sektor– ke ‡ten¡ = 1
7D1F  E85400         CALL   7D76            ; na‡ten¡ sektor– do pamˆti
7D22  59             POP    CX              ; po‡et sektor–
7D23  5A             POP    DX              ; ‡¡slo sektoru
7D24  58             POP    AX              ; ‡¡slo stopy
7D25  72C9           JC     7CF0            ; chybov‚ hl ¨en¡
7D27  050100         ADD    AX,0001         ; zv˜¨en¡ ukaz. stopy (ni‘¨¡ slovo)
7D2A  83D200         ADC    DX,0000         ;        -  "  -      (vy¨¨¡ slovo)
7D2D  031E0B7C       ADD    BX,[7C0B]       ; zv˜¨en¡ ukl dac¡ adresy o sektor
7D31  E2E2           LOOP   7D15            ; dal¨¡ sektor ke ‡ten¡
7D33  8A2E157C       MOV    CH,[7C15]       ; typ disku (popisova‡ m‚dia)
7D37  8A16247C       MOV    DL,[7C24]       ; ‡¡slo disku
7D3B  8B1E497C       MOV    BX,[7C49]       ; rel. ‡¡slo n sleduj¡c¡ho sektoru
7D3F  A14B7C         MOV    AX,[7C4B]       ;    -  "  -  (ni‘¨¡ slovo)
7D42  EA00007000     JMP    0070:0000       ; start modulu IO.SYS

                                            ; tisk textu na adrese DS:SI
7D47  AC           * LODSB                  ; p©e‡ten¡ znaku k tisku
7D48  0AC0           OR     AL,AL           ; byl koncov˜ znak ?
7D4A  7429           JZ     7D75            ; konec tisku textu
7D4C  B40E           MOV    AH,0E           ; funkce tisku znaku v TTY m¢du
7D4E  BB0700         MOV    BX,0007         ; = b¡l‚ p¡smo, str nka 0
7D51  CD10           INT    10              ; tisk znaku v AL
7D53  EBF2           JMP    7D47            ; dal¨¡ znak k tisku

                                            ; nastaven¡ sektoru, v lce a hlavy
                                            ; vstup:AX = rel.sektor (ni‘¨¡ ‡ st)
                                            ;       DX = rel.sektor (vy¨¨¡ ‡ st)
7D55  3B16187C     * CMP    DX,[sektnm]     ; po‡et sektor– na stopu
7D59  7319           JNC    7D74            ; nen¡ ji‘ dal¨¡ sektor na stopˆ
7D5B  F736187C       DIV    word ptr [sektnm] ; po‡et sektor– na stopu
7D5F  FEC2           INC    DL              ; ‡¡slo sektoru ke ‡ten¡
7D61  88164F7C       MOV    [7C4F],DL       ; ‡¡slo sektoru ke ‡ten¡
7D65  33D2           XOR    DX,DX
7D67  F7361A7C       DIV    word ptr [7C1A] ; dˆleno po‡tem hlav disku
7D6B  8816257C       MOV    [7C25],DL       ; ‡¡slo hlavy ke ‡ten¡
7D6F  A34D7C         MOV    [7C4D],AX       ; ‡¡slo v lce ke ‡ten¡
7D72  F8             CLC                    ; p©evod OK
7D73  C3             RET
7D74  F9             STC                    ; nastaven¡ p©¡znaku chyby
7D75  C3           * RET
                                            ; na‡ten¡ sektor– do pamˆti
                                            ; vstup:  AL = po‡et sektor–
7D76  B402         * MOV    AH,02           ; funkce ‡ten¡ sektor– do pamˆti
7D78  8B164D7C       MOV    DX,[7C4D]       ; ‡¡slo v lce ke ‡ten¡
7D7C  B106           MOV    CL,06           ; po‡et rotac¡
7D7E  D2E6           SHL    DH,CL           ; vyn soben¡ * 64 (z¡sk n¡ bit– 9,8)
7D80  0A364F7C       OR     DH,[7C4F]       ; ‡ten˜ sektor OR bity 9 a 8 stopy
7D84  8BCA           MOV    CX,DX           ; CL = ‡¡slo v lce; CH = po‡. sektor
7D86  86E9           XCHG   CH,CL           ; CH = ‡¡slo v lce; CL = po‡. sektor
7D88  8A16247C       MOV    DL,[7C24]       ; ‡¡slo disku
7D8C  8A36257C       MOV    DH,[7C25]       ; ‡¡slo hlavy ke ‡ten¡
7D90  CD13           INT    13              ; ‡ten¡ sektor– do pamˆti
7D92  C3             RET

chyba    db        0dh,0ah,'Non-System disk or disk error'
         db        0dh,0ah,'Replace and press any key'
         db        ' when ready',0dh,0ah,0

soubio   db        'IO      SYS'
soubdos  db        'MSDOS   SYS'

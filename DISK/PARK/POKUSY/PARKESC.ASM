3169:0100  E9AD00         JMP    01B0
  
0103     db        'Written by David Chong, June 1987'

0124     db        13,10,'Universal Disk-Park Utility. '
         db        'Version 1.0',13,10,28h
         db        '(c) LIMCO (Products) Mfg. Pte. Ltd.,'
         db        ' 1987',13,10,10,'$'

017d     db        'Power off system or press <ESC> to return to DOS'
         db        13,10,'$'


comment %
0103   57 72 69 74 74 65 6E 20 62 79 20 44 61 76 69 64   Written by David
0113   20 43 68 6F 6E 67 2C 20 4A 75 6E 65 20 31 39 38    Chong, June 198
0123   37 0D 0A 55 6E 69 76 65 72 73 61 6C 20 44 69 73   7..Universal Dis
0133   6B 2D 50 61 72 6B 20 55 74 69 6C 69 74 79 2E 20   k-Park Utility.
0143   56 65 72 73 69 6F 6E 20 31 2E 30 0D 0A 28 63 29   Version 1.0..(c)
0153   20 4C 49 4D 43 4F 20 28 50 72 6F 64 75 63 74 73    LIMCO (Products
0163   29 20 4D 66 67 2E 20 50 74 65 2E 20 4C 74 64 2E   ) Mfg. Pte. Ltd.
0173   2C 20 31 39 38 37 0D 0A 0A 24 50 6F 77 65 72 20   , 1987...$Power
0183   6F 66 66 20 73 79 73 74 65 6D 20 6F 72 20 70 72   off system or pr
0193   65 73 73 20 3C 45 53 43 3E 20 74 6F 20 72 65 74   ess <ESC> to ret
01A3   75 72 6E 20 74 6F 20 44 4F 53 0D 0A 24 BA 24 01   urn to DOS..$.$.
%

01B0  BA2401         MOV    DX,0124         ; £vodn¡ text
01B3  B409           MOV    AH,09           ; funkce tisku textu
01B5  CD21           INT    21              ; tisk £vodn¡ho textu
01B7  B280           MOV    DL,80           ; ‡¡slo disku (pevn˜ disk 0)
01B9  B408           MOV    AH,08           ; funkce poskytnut¡ parametr–
01BB  CD13           INT    13              ; poskytnut¡ parametr– disku
01BD  52             PUSH   DX              ; parametry
01BE  80C501         ADD    CH,01           ; ‡¡slo parkovac¡ho v lce
01C1  7303           JNC    01C6            ; nen¡ p©ete‡en¡ sou‡tu
01C3  80C140         ADD    CL,40           ; korekce horn¡ch 2 bit– ‡¡sla
01C6  B280           MOV    DL,80           ; ‡¡slo pevn‚ho disku 0
01C8  B40C           MOV    AH,0C           ; funkce vystaven¡ na v lec
01CA  CD13           INT    13              ; vystaven¡ na parkovac¡ v lec
01CC  5A             POP    DX              ; parametry disku
01CD  80FA02         CMP    DL,02           ; po‡et pevn˜ch disk– = 2 ?
01D0  7514           JNZ    01E6            ; po‡et disk– = 1
01D2  B281           MOV    DL,81           ; ‡¡slo pevn‚ho disku 1
01D4  B408           MOV    AH,08           ; funkce poskytnut¡ parametr–
01D6  CD13           INT    13              ; poskytnut¡ parametr– disku
01D8  80C501         ADD    CH,01           ; ‡¡slo parkovac¡ho v lce
01DB  7303           JNC    01E0            ; nen¡ p©ete‡en¡ sou‡tu
01DD  80C140         ADD    CL,40           ; korekce horn¡ch 2 bit– ‡¡sla
01E0  B281           MOV    DL,81           ; ‡¡slo pevn‚ho disku 1
01E2  B40C           MOV    AH,0C           ; funkce vystaven¡ na v lec
01E4  CD13           INT    13              ; vystaven¡ na parkovac¡ v lec
01E6  BA7D01         MOV    DX,017D         ; text "Power off ..."
01E9  B409           MOV    AH,09           ; funkce tisku textu
01EB  CD21           INT    21              ; tisk textu na displej
01ED  B407         * MOV    AH,07           ; funkce vstupu znaku bez echa
01EF  CD21           INT    21              ; vstup znaku bez echa
01F1  3C1B           CMP    AL,1B           ; je zadan˜ znak kl v. <Esc> ?
01F3  75F8           JNZ    01ED            ; nen¡ - dal¨¡ vstup znaku
01F5  B80000         MOV    AX,0000         ; funkce p©eru¨en¡ programu
01F8  CD21           INT    21              ; p©eru¨en¡ programu

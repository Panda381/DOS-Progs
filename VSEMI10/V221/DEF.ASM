
bit0     EQU       1
bit1     EQU       2
bit2     EQU       4
bit3     EQU       8
bit4     EQU       10h
bit5     EQU       20h
bit6     EQU       40h
bit7     EQU       80h

; ------ ukazatele pro kl vesnici CSKEY

KLIC1    EQU       4d6ah                    ; kl¡‡ 1 (AX)
KLIC2    EQU       8e4ah                    ; kl¡‡ 2 (BX)
KLIC3    EQU       0a6e3h                   ; kl¡‡ 3 (CX)
KLIC4    EQU       342eh                    ; kl¡‡ 4 (BX v˜stup)

KORIG    EQU       5ch-103h                 ; korekce adres
KlavCSKY EQU       10bh + KORIG             ; typ kl vesnice CSKEY
PrepCSKY EQU       10ch + KORIG             ; p©ep¡na‡e CSKEY
Prf1CSKY EQU       10dh + KORIG             ; prefixy1 CSKEY
Prf2CSKY EQU       10fh + KORIG             ; prefixy2 CSKEY

; ------ p©ep¡na‡e v textu

LF       EQU       10                       ; nov˜ © dek textu
EOT      EQU       0                        ; konec textu
BS       EQU       8                        ; krok zpˆt
FF       EQU       12                       ; nov  str nka
CR       EQU       13                       ; n vrat na za‡ tek © dku

EnterChr EQU       13                       ; znak pro zobrazen¡ ENTER

TSWCBOLD EQU       4                        ; zv˜raznˆn¡ (‡erven )  (SHIFT-F1)
TSWCKEYS EQU       3                        ; kl vesy (modr )       (SHIFT-F2)
TSWCNADP EQU       2                        ; nadpisy (zelen )      (SHIFT-F3)
TSWCNAD2 EQU       1                        ; nadpisy 2 (¨ed )      (SHIFT-F4)
TSWCFONT EQU       5                        ; zmˆna fontu 16/8 linek (SHIFT-F5)
TSWCPODK EQU       0                        ; podklad               (SHIFT-F6)

; ------ definice pole textu

LINKURZ  EQU       4                        ; po‡et linek na kurzor
FONTEXT  EQU       16                       ; font k zobrazen¡ textu
RADTEXT  EQU       11                       ; po‡et © dk– k zobrazen¡ textu
LINTEXT  EQU       RADTEXT*FONTEXT + LINKURZ; po‡et linek k zobrazen¡ textu
ENDTEXT  EQU       LINTEXT*80               ; konec pole k zobrazen¡ textu

LFTPAPIR EQU       2                        ; lev˜ okraj pap¡ru
SIRPAPIR EQU       76                       ; ¨¡©ka pap¡ru
LFTTEXT  EQU       4                        ; lev˜ okraj textu
SIRTEXT  EQU       72                       ; ¨¡©ka textu (znak–)

; ------ definice pole prav¡tka

FONLINE  EQU       8                        ; font k zobrazen¡ prav¡tka
TOPLINE  EQU       ENDTEXT                  ; po‡ tek k zobrazen¡ prav¡tka
LINLINE  EQU       15                       ; po‡et linek k zobrazen¡ prav¡tka
ENDLINE  EQU       TOPLINE + LINLINE*80     ; konec k zobrazen¡ prav¡tka

; ------ definice pole kl vesnice

TOPKLAV  EQU       ENDLINE                  ; za‡ tek pole k zobraz. kl vesnice
LINKLAV  EQU       350-LINLINE-LINTEXT      ; po‡et linek k zobrazen¡ kl vesnice
SIRKEY   EQU       5                        ; ¨¡©ka jedn‚ kl vesy
INCKEY   EQU       2                        ; p©¡rustek pozice kl ves
VYSKEY   EQU       (LINKLAV-10)/5           ; v˜¨ka jedn‚ kl vesy
LEFTKEY  EQU       (80 - SIRKEY*15)/2       ; lev˜ okraj k zobrazen¡ kl ves
TOPKEY   EQU       TOPKLAV+LEFTKEY+5*80     ; po‡ tek k zobrazen¡ prvn¡ kl vesy
RADKEY   EQU       VYSKEY*80                ; p©¡rustek adresy jedn‚ ©ady kl ves

; ------ definice pole testu

TESTLINE EQU       9                        ; po‡et zobrazen˜ch © dk– testu

; ------ definice v˜bˆru soubor–

VYBERADR EQU       5 + 36*80                ; po‡ te‡n¡ adresa ve videopamˆti

VYBERRAD EQU       30                       ; po‡et © dk– se soubory
VYBERCOL EQU       5                        ; po‡et sloupc– se soubory
VYBERMAX EQU       VYBERRAD*VYBERCOL        ; po‡et max. zobrazen˜ch soubor–
VYBERSIR EQU       15                       ; ¨¡©ka jedn‚ polo‘ky
VYBERVYS EQU       10                       ; v˜¨ka jedn‚ polo‘ky

GLOBAL   STOP:NEAR
GLOBAL   LekceD:BYTE,LDatD:BYTE,HelpDat:BYTE,LicCis1:BYTE,LicCis2:BYTE

GLOBAL   LekcI00:BYTE,LekcI01:BYTE,LekcI02:BYTE,LekcI03:BYTE,LekcI04:BYTE
GLOBAL   LekcI05:BYTE,LekcI06:BYTE,LekcI07:BYTE,LekcI08:BYTE,LekcI09:BYTE
GLOBAL   LekcI10:BYTE,LekcI11:BYTE,LekcI12:BYTE,LekcI13:BYTE,LekcI14:BYTE
GLOBAL   LekcI15:BYTE,LekcI16:BYTE,LekcI17:BYTE,LekcI18:BYTE,LekcI19:BYTE
GLOBAL   LekcI20:BYTE,LekcI21:BYTE,LekcI22:BYTE,LekcI23:BYTE,LekcI24:BYTE
GLOBAL   LekcI25:BYTE,LekcI26:BYTE,LekcI27:BYTE,LekcI28:BYTE,LekcI29:BYTE
GLOBAL   LekcI30:BYTE,LekcI31:BYTE,LekcI32:BYTE,LekcI33:BYTE,LekcI34:BYTE
GLOBAL   LekcI35:BYTE,LekcI36:BYTE,LekcI37:BYTE,LekcI38:BYTE,LekcI39:BYTE
GLOBAL   LekcI40:BYTE,LekcI41:BYTE,LekcI42:BYTE,LekcI43:BYTE,LekcI44:BYTE
GLOBAL   LekcI45:BYTE,LekcI46:BYTE,LekcI47:BYTE,LekcI48:BYTE,LekcI49:BYTE

GLOBAL   LDatI00:BYTE,LDatI01:BYTE,LDatI02:BYTE,LDatI03:BYTE,LDatI04:BYTE
GLOBAL   LDatI05:BYTE,LDatI06:BYTE,LDatI07:BYTE,LDatI08:BYTE,LDatI09:BYTE
GLOBAL   LDatI10:BYTE,LDatI11:BYTE,LDatI12:BYTE,LDatI13:BYTE,LDatI14:BYTE
GLOBAL   LDatI15:BYTE,LDatI16:BYTE,LDatI17:BYTE,LDatI18:BYTE,LDatI19:BYTE
GLOBAL   LDatI20:BYTE,LDatI21:BYTE,LDatI22:BYTE,LDatI23:BYTE,LDatI24:BYTE
GLOBAL   LDatI25:BYTE,LDatI26:BYTE,LDatI27:BYTE,LDatI28:BYTE,LDatI29:BYTE
GLOBAL   LDatI30:BYTE,LDatI31:BYTE,LDatI32:BYTE,LDatI33:BYTE,LDatI34:BYTE
GLOBAL   LDatI35:BYTE,LDatI36:BYTE,LDatI37:BYTE,LDatI38:BYTE,LDatI39:BYTE
GLOBAL   LDatI40:BYTE,LDatI41:BYTE,LDatI42:BYTE,LDatI43:BYTE,LDatI44:BYTE
GLOBAL   LDatI45:BYTE,LDatI46:BYTE,LDatI47:BYTE,LDatI48:BYTE,LDatI49:BYTE

GLOBAL   LekcC00:BYTE,LekcC01:BYTE,LekcC02:BYTE,LekcC03:BYTE,LekcC04:BYTE
GLOBAL   LekcC05:BYTE,LekcC06:BYTE,LekcC07:BYTE,LekcC08:BYTE,LekcC09:BYTE
GLOBAL   LekcC10:BYTE,LekcC11:BYTE,LekcC12:BYTE,LekcC13:BYTE,LekcC14:BYTE
GLOBAL   LekcC15:BYTE,LekcC16:BYTE,LekcC17:BYTE,LekcC18:BYTE,LekcC19:BYTE
GLOBAL   LekcC20:BYTE,LekcC21:BYTE,LekcC22:BYTE,LekcC23:BYTE,LekcC24:BYTE
GLOBAL   LekcC25:BYTE,LekcC26:BYTE,LekcC27:BYTE,LekcC28:BYTE,LekcC29:BYTE
GLOBAL   LekcC30:BYTE,LekcC31:BYTE,LekcC32:BYTE,LekcC33:BYTE,LekcC34:BYTE
GLOBAL   LekcC35:BYTE,LekcC36:BYTE,LekcC37:BYTE,LekcC38:BYTE,LekcC39:BYTE
GLOBAL   LekcC40:BYTE,LekcC41:BYTE,LekcC42:BYTE,LekcC43:BYTE,LekcC44:BYTE
GLOBAL   LekcC45:BYTE,LekcC46:BYTE,LekcC47:BYTE,LekcC48:BYTE,LekcC49:BYTE

GLOBAL   LDatC00:BYTE,LDatC01:BYTE,LDatC02:BYTE,LDatC03:BYTE,LDatC04:BYTE
GLOBAL   LDatC05:BYTE,LDatC06:BYTE,LDatC07:BYTE,LDatC08:BYTE,LDatC09:BYTE
GLOBAL   LDatC10:BYTE,LDatC11:BYTE,LDatC12:BYTE,LDatC13:BYTE,LDatC14:BYTE
GLOBAL   LDatC15:BYTE,LDatC16:BYTE,LDatC17:BYTE,LDatC18:BYTE,LDatC19:BYTE
GLOBAL   LDatC20:BYTE,LDatC21:BYTE,LDatC22:BYTE,LDatC23:BYTE,LDatC24:BYTE
GLOBAL   LDatC25:BYTE,LDatC26:BYTE,LDatC27:BYTE,LDatC28:BYTE,LDatC29:BYTE
GLOBAL   LDatC30:BYTE,LDatC31:BYTE,LDatC32:BYTE,LDatC33:BYTE,LDatC34:BYTE
GLOBAL   LDatC35:BYTE,LDatC36:BYTE,LDatC37:BYTE,LDatC38:BYTE,LDatC39:BYTE
GLOBAL   LDatC40:BYTE,LDatC41:BYTE,LDatC42:BYTE,LDatC43:BYTE,LDatC44:BYTE
GLOBAL   LDatC45:BYTE,LDatC46:BYTE,LDatC47:BYTE,LDatC48:BYTE,LDatC49:BYTE

GLOBAL   Lekc100:BYTE,Lekc101:BYTE,Lekc102:BYTE,Lekc103:BYTE,Lekc104:BYTE
GLOBAL   Lekc105:BYTE,Lekc106:BYTE,Lekc107:BYTE,Lekc108:BYTE,Lekc109:BYTE
GLOBAL   Lekc110:BYTE,Lekc111:BYTE,Lekc112:BYTE,Lekc113:BYTE,Lekc114:BYTE
GLOBAL   Lekc115:BYTE,Lekc116:BYTE,Lekc117:BYTE,Lekc118:BYTE,Lekc119:BYTE
GLOBAL   Lekc120:BYTE,Lekc121:BYTE,Lekc122:BYTE,Lekc123:BYTE,Lekc124:BYTE
GLOBAL   Lekc125:BYTE,Lekc126:BYTE,Lekc127:BYTE,Lekc128:BYTE,Lekc129:BYTE
GLOBAL   Lekc130:BYTE,Lekc131:BYTE,Lekc132:BYTE,Lekc133:BYTE,Lekc134:BYTE
GLOBAL   Lekc135:BYTE,Lekc136:BYTE,Lekc137:BYTE,Lekc138:BYTE,Lekc139:BYTE
GLOBAL   Lekc140:BYTE,Lekc141:BYTE,Lekc142:BYTE,Lekc143:BYTE,Lekc144:BYTE
GLOBAL   Lekc145:BYTE,Lekc146:BYTE,Lekc147:BYTE,Lekc148:BYTE,Lekc149:BYTE

GLOBAL   LDat100:BYTE,LDat101:BYTE,LDat102:BYTE,LDat103:BYTE,LDat104:BYTE
GLOBAL   LDat105:BYTE,LDat106:BYTE,LDat107:BYTE,LDat108:BYTE,LDat109:BYTE
GLOBAL   LDat110:BYTE,LDat111:BYTE,LDat112:BYTE,LDat113:BYTE,LDat114:BYTE
GLOBAL   LDat115:BYTE,LDat116:BYTE,LDat117:BYTE,LDat118:BYTE,LDat119:BYTE
GLOBAL   LDat120:BYTE,LDat121:BYTE,LDat122:BYTE,LDat123:BYTE,LDat124:BYTE
GLOBAL   LDat125:BYTE,LDat126:BYTE,LDat127:BYTE,LDat128:BYTE,LDat129:BYTE
GLOBAL   LDat130:BYTE,LDat131:BYTE,LDat132:BYTE,LDat133:BYTE,LDat134:BYTE
GLOBAL   LDat135:BYTE,LDat136:BYTE,LDat137:BYTE,LDat138:BYTE,LDat139:BYTE
GLOBAL   LDat140:BYTE,LDat141:BYTE,LDat142:BYTE,LDat143:BYTE,LDat144:BYTE
GLOBAL   LDat145:BYTE,LDat146:BYTE,LDat147:BYTE,LDat148:BYTE,LDat149:BYTE

GLOBAL   Lekc200:BYTE,Lekc201:BYTE,Lekc202:BYTE,Lekc203:BYTE,Lekc204:BYTE
GLOBAL   Lekc205:BYTE,Lekc206:BYTE,Lekc207:BYTE,Lekc208:BYTE,Lekc209:BYTE
GLOBAL   Lekc210:BYTE,Lekc211:BYTE,Lekc212:BYTE,Lekc213:BYTE,Lekc214:BYTE
GLOBAL   Lekc215:BYTE,Lekc216:BYTE,Lekc217:BYTE,Lekc218:BYTE,Lekc219:BYTE
GLOBAL   Lekc220:BYTE,Lekc221:BYTE,Lekc222:BYTE,Lekc223:BYTE,Lekc224:BYTE
GLOBAL   Lekc225:BYTE,Lekc226:BYTE,Lekc227:BYTE,Lekc228:BYTE,Lekc229:BYTE
GLOBAL   Lekc230:BYTE,Lekc231:BYTE,Lekc232:BYTE,Lekc233:BYTE,Lekc234:BYTE
GLOBAL   Lekc235:BYTE,Lekc236:BYTE,Lekc237:BYTE,Lekc238:BYTE,Lekc239:BYTE
GLOBAL   Lekc240:BYTE,Lekc241:BYTE,Lekc242:BYTE,Lekc243:BYTE,Lekc244:BYTE
GLOBAL   Lekc245:BYTE,Lekc246:BYTE,Lekc247:BYTE,Lekc248:BYTE,Lekc249:BYTE

GLOBAL   LDat200:BYTE,LDat201:BYTE,LDat202:BYTE,LDat203:BYTE,LDat204:BYTE
GLOBAL   LDat205:BYTE,LDat206:BYTE,LDat207:BYTE,LDat208:BYTE,LDat209:BYTE
GLOBAL   LDat210:BYTE,LDat211:BYTE,LDat212:BYTE,LDat213:BYTE,LDat214:BYTE
GLOBAL   LDat215:BYTE,LDat216:BYTE,LDat217:BYTE,LDat218:BYTE,LDat219:BYTE
GLOBAL   LDat220:BYTE,LDat221:BYTE,LDat222:BYTE,LDat223:BYTE,LDat224:BYTE
GLOBAL   LDat225:BYTE,LDat226:BYTE,LDat227:BYTE,LDat228:BYTE,LDat229:BYTE
GLOBAL   LDat230:BYTE,LDat231:BYTE,LDat232:BYTE,LDat233:BYTE,LDat234:BYTE
GLOBAL   LDat235:BYTE,LDat236:BYTE,LDat237:BYTE,LDat238:BYTE,LDat239:BYTE
GLOBAL   LDat240:BYTE,LDat241:BYTE,LDat242:BYTE,LDat243:BYTE,LDat244:BYTE
GLOBAL   LDat245:BYTE,LDat246:BYTE,LDat247:BYTE,LDat248:BYTE,LDat249:BYTE

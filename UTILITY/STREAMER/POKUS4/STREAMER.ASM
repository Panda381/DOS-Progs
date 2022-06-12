
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
; P©enosov† rychlost 115200 Baud
; 8 datovòch bitñ, bez parity, 1 START bit, 1 STOP bit
; 86.80555556 us na bajt
; 230 bajtñ celkem na sektor (19965 us)
; -----------------------------------------------------------------------------
; 10*19: uëiteán† 190, celkem 220   (46080 B)
; 10*18: uëiteán† 180, celkem 209   (43520 B)
;  9*21: uëiteán† 189, celkem 220
;  9*20: uëiteán† 180, celkem 210   (43520 B)
;  8*23: uëiteán† 184, celkem 216
;  8*22: uëiteán† 176, celkem 207   (42496 B)
;  7*26: uëiteán† 182, celkem 216
;  7*25: uëiteán† 175, celkem 208   (42240 B)
;  6*30: uëiteán† 180, celkem 217
;  5*35: uëiteán† 175, celkem 216
;  5*34: uëiteán† 170, celkem 210 ! (40960 B)
;  4*43: uëiteán† 172, celkem 220
;  4*42: uëiteán† 168, celkem 215
;  3*54: uëiteán† 162, celkem 220
;  3*53: uëiteán† 159, celkem 216
;  3*52: uëiteán† 156, celkem 212
;
; Struktura sektoru:
;    Sektor je organizov†n do matice 11 ©†dkñ po 20 bajtech. Posledn° bajt
;    v kaëdÇm ©†dku je kontroln° a je to XOR p©edch†zej°c°ch 19 bajtñ.
;    Posledn° 11. ©†dek je kontroln° a je to XOR p©edch†zej°c°ch 10 ©†dkñ.
;    Platn† data jsou 10*19=190 bajtñ, z toho prvn°ch 10 bajtñ je z†hlav°,
;    skuteánòch dat je 180 bajtñ.
;
;           0: (4) absolutn° áas zaá†tku nahr†vky (poáet sekund od 1.1.1980)
;           4: (2) celkov† dÇlka nahr†vky v sekund†ch/2 (max. 36 hodin)
;                        (0FFFFh = 36 hodin 24 minut 30 sekund a v°ce)
;           6: (2) aktu†ln° á°slo bloku 0 aë 16383
;                  b14: 0=datovò sektor (0 aë 255), 1=korekán° sektor (0 aë 32)
;                  b15: 0=datovò blok, 1=adres†©ovò blok
;           8: (1) aktu†ln° á°slo sektoru v bloku 0 aë 255
;                      korekán° sektor  33 -> z†vàreánò synchronizaán° sektor
;                      korekán° sektor 255 -> poá†teán° synchronizaán° sektor
;           9: (1) informace o dàlen° blokñ do skupin
;                  b0  aë b3 : poáet datovòch blokñ ve skupinà 1 aë 16
;                  b4  aë b7 : oddàlovac° mezera mezi skupinami (2 aë 32 sekund)
;
;   - Poá†teán° synchronizaán° sektor obsahuje na pozici 10: offset popisovaáe
;        prvn°ho souboru v bloku (0ffffh = nezaá°n† ë†dnò popisovaá souboru).
;   - Pro synchronizaán° sektory jsou n†sleduj°c° bajty nastaveny na 0FFh.
;     (tj. nekontroluje se kontroln° souáet, sektor se ovà©uje v°cen†sobnà)
;          10: (9) zbytek prvn°ho ©†dku - data
;          19: (1) kontroln° souáet XOR prvn°ho ©†dku
;
;          20: (180) ostatn° data (9 ©†dkñ x (19 bajtñ + 1 kontroln°))
;
;         200: (20) kontroln° opravnò ©†dek XOR pro data i z†hlav°
;
;         220: (2) kontroln° souáet celÇho sektoru CRC (i se z†hlav°m)
;
;         222: (1) £vodn° synchronizace 0ffh
;         223: (2) sn°mkov† synchronizace 0ffh
;         225: (3) z†vàreán† synchronizace 0ffh
;         228: (1) START bajt 02h
;         229: (1) START bajt 0e5h
; -----------------------------------------------------------------------------
; Struktura bloku:
;          256 sektorñ data (v matici 16*16)
;           16 kontroln° sektory ©†dkñ XOR
;           16 kontroln° sektory sloupcñ XOR
;            1 kontroln° sektor celkovò XOR
;   celkem 289 sektorñ na blok
; -----------------------------------------------------------------------------
; Äasov†n°:
;    1 sektor = 230 bajtñ * 86.80555556 us = 19965.277779 us,  uëiteánòch 180 B
;         efektivn° rychlost 9015.65217 B/sekundu, vyëaduje pamàü 224 Bajtñ
;    1 blok = 289 sektorñ * 19.965277779 ms = 5.76996527 s, uëiteánòch 256 sekt.
;         rychlost 7986.18325 B/sekundu, vyëaduje pamàü 64736 Bajtñ
;    1 blok p©enese 46080 B, vyëaduje 64736 B
;      najednou se p©enesou 4 bloky, vyëaduj° 262144 Bajtñ pamàti (184320 B)
;    áas pro 4 bloky: 23.07986108 sek., mezera asi 7 sekund, celkem 30 sekund
;    efektivn° rychlost = 6144 B/sek. = 368.640 KB/min = 22.118 MB/hod.
; ----------------
;; 160 bajtñ na sektor: rychlost 8000 B/sek., 1 blok = 40960 B
;; 1 blok = 8*32 = 256 dat. sektorñ + 41 kontroln° = 297 sektorñ (5.94 s)
;;    4 bloky = 23.76 s + 7 s mezera = 31 sek. = 5285 B/s = 317 KB/min. = 19 MB/h
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

MAXF     EQU       86                       ; maxim†ln° dÇlka jmÇna souboru
MAXFILES EQU       2978                     ; maxim†ln° poáet souborñ v adres†©i
SOUBDIS  EQU       12                       ; poáet zobrazenòch souborñ v oknà

; ------ definice poloëky seznamu (vypou®t° se poloëky "." a "..")
; Poloëky jednoho adres†©e jsou naáteny pohromadà. Pro kaëdò podadres†©
; v adres†©i n†sleduje za adres†©em dal®° podadres†© (s hlub®° strukturou).
; Kaëdò podadres†© je ukonáen bajtem 0 (offset dal®° poloëky = 0).

FileOffs EQU       0                        ; (1) offset dal®° poloëky
                                            ;      0=konec adres†©e
FileAtr  EQU       1                        ; (1) atributy poloëky
                                            ;      b0: 1=R/O
                                            ;      b1: 1=HID
                                            ;      b2: 1=SYS
                                            ;      b3: 1=soubor p©ijat s chybou
                                            ;      b4: 1=DIR
                                            ;      b5: 1=ARC
                                            ;      b6: 1=£schova oznaáen°
                                            ;      b7: 1=poloëka oznaáena
FileTime EQU       2                        ; (2) áas poloëky
                                            ;      b0 aë b4: sekunda/2 (0 aë 62)
                                            ;      b5 aë b10: minuta (0 aë 63)
                                            ;      b11 aë b15: hodina (0 aë 31)
FileDate EQU       4                        ; (2) datum poloëky
                                            ;      b0 aë b4: den (0 aë 31)
                                            ;      b5 aë b8: màs°c (0 aë 15)
                                            ;      b9 aë b15: rok-1980 (aë 2107)
FileSize EQU       6                        ; (4) velikost poloëky (bajtñ)
FileName EQU       10                       ; (x) jmÇno poloëky ASCII
                                            ;      (v popisovaái souboru
                                            ;       pln† cesta; "\"=ROOT)

; ------ definice seznamu souborñ
;˛
SeznPar  EQU       0                        ; (1) parametry seznamu
                                            ;      b0: 0=disk, 1=streamer
                                            ;      b1: 0=levÇ, 1=pravÇ okno
                                            ;      b2: 1=okno je aktivn°
SeznPar2 EQU       1                        ; (1) parametry seznamu 2
                                            ;      b0: 1=t©°dàn° podle jmÇna
                                            ;      b1: 1=t©°dàn° podle p©°pony
                                            ;      b2: 1=t©°dàn° podle velikosti
                                            ;      b3: 1=t©°dàn° podle data+áasu
                                            ;      b4: 1=adres†© se net©°d°
                                            ;      b5: 1=sestupnÇ t©°dàn° adres.
SeznSeg  EQU       2                        ; (2) segment seznamu souborñ
SeznEnd  EQU       4                        ; (2) segment konce seznamu souborñ
SeznNum  EQU       6                        ; (2) celkovò poáet poloëek v sezn.

SeznSelN EQU       8                        ; (2) poáet oznaáenòch souborñ
SeznSelS EQU       10                       ; (4) souáet oznaáenòch souborñ
SeznSelR EQU       14                       ; (4) - poëadovan† kapacita na disku
                                            ;..(2) - dÇlka z†znamu v sekund†ch/2

SeznDSeg EQU       18                       ; (2) segment zaá†tku adres†©e
SeznDNum EQU       20                       ; (2) poáet poloëek adres†©e
SeznDAkt EQU       22                       ; (2) aktivn° zobraz. poloëka adres.
SeznDTop EQU       24                       ; (2) poá†teán° zobr. poloëka adres.

SeznFFil EQU       26                       ; (2) poáet souborñ v adres†©i
SeznFSum EQU       28                       ; (4) zabran† kapacita soubory

SeznLabN EQU       32                       ; (2) dÇlka n†và®t°
SeznDirN EQU       34                       ; (2) dÇlka adres†©e
SeznLab  EQU       36                       ; (12) n†và®t°
SeznDir  EQU       36+12                    ; (MAXF) aktivn° adres†© seznamu
SeznInd  EQU       SEZNDIR+MAXF             ; (2*MAXFILES) indexy souborñ adres.
SeznSum  EQU       SEZNIND+2*MAXFILES       ; celkov† dÇlka popisovaáe seznamu

AktDir   EQU       offset DatDefL + SeznDir ; adres†© disku
AktDirN  EQU       offset DatDefL + SeznDirN ; dÇlka adres†©e
AktLab   EQU       offset DatDefL + SeznLab ; jmÇno disku
AktLabN  EQU       offset DatDefL + SeznLabN ; dÇlka jmÇna disku

; ------ atributy souborñ

RO       EQU       b0                       ; R/O
HID      EQU       b1                       ; HID
SYS      EQU       b2                       ; SYS
VOL      EQU       b3                       ; VOL
DIR      EQU       b4                       ; DIR
ARC      EQU       b5                       ; ARC

; ------ konstanty

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

; ------ parametry

UVSYNCH  EQU       60                       ; £vodn° synchronizaán° sektory
ZAVSYNCH EQU       30                       ; z†vàreánÇ synchronizaán° sektory
MINSYNCH EQU       12                       ; minim†ln° poáet synchroniz.sektorñ


Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; ------ p©edefinov†n° ukazatele z†sobn°ku

Start:   cmp       sp,offset Zasob          ; je z†sobn°k OK ?
         jb        Start1                   ; nedostatek pamàti
         mov       sp,offset Zasob          ; p©edefinov†n° z†sobn°ku

; ------ zmen®en° bloku programu na minimum

         mov       bx,(offset(Zasob-Start)+10fh)/16 ; velikost programu
         mov       ah,4ah
         int       21h                      ; zmen®en° bloku programu
         jnc       Start2

; ------ chyba - nedostatek pamàti

Start1:  mov       dx,offset MemTxt
         mov       ah,9
         int       21h
         int       20h

; ------ vytvo©en° bufferu souborñ

Start2:  mov       bx,(289*180+15)/16       ; velikost bufferu souborñ
         mov       ah,48h
         int       21h                      ; vytvo©en° bufferu souborñ
         jc        Start1                   ; chyba - nedostatek pamàti
         mov       ds:[BuffSeg],ax          ; adresa bufferu souborñ

; ------ vytvo©en° bufferu sektorñ

         mov       bx,-1
         mov       ah,48h
         int       21h
         jnc       Start1
         mov       ah,48h
         int       21h                      ; vytvo©en° maxim†ln°ho bufferu
         jc        Start1                   ; nedostatek pamàti
         cmp       bx,(289+30)*(224/16)     ; minim†ln° velikost bufferu
         jb        Start1                   ; nedostatek pamàti

; ------ vòpoáet parametrñ bufferu sektorñ

         mov       ds:[SektBSeg],ax         ; adresa zaá†tku bufferu sektorñ
         mov       ds:[DatSegm],ax          ; zaá†tek datovÇho segmentu
         mov       ds:[DatFre],ax           ; zaá†tek volnÇho m°sta v segmentu
         add       ax,bx                    ; adresa konce bufferu sektorñ
         mov       ds:[SektESeg],ax         ; adresa konce bufferu sektorñ
         mov       ds:[DatMax],ax           ; maxim†ln° konec bufferu
         xchg      ax,bx                    ; AX <- velikost bufferu sektorñ
         xor       dx,dx                    ; DX <- 0
         mov       bx,224/16                ; velikost jednoho sektoru
         div       bx                       ; vòpoáet poátu sektorñ
         mov       ds:[SektMax],ax          ; maxim†ln° poáet sektorñ
         sub       ds:[SektESeg],dx         ; oprava konce bufferu sektorñ
         sub       ax,20                    ; p†r sektorñ rezerva
         xor       dx,dx                    ; DX <- 0
         mov       bx,289+3                 ; poáet sektorñ na blok (+ synch.)
         div       bx                       ; vòpoáet poátu blokñ
         mov       ds:[MaxDBlok],ax         ; maxim†ln° poáet datovòch blokñ

; ------ instalace INT 24h

         mov       dx,offset Int24
         mov       ax,2524h
         int       21h

; ------ instalace INT 23h

         mov       dx,offset Int23
         mov       ax,2523h
         int       21h

; ------ £schova p©°znaku BREAK

         mov       ax,3300h
         int       21h                      ; poskytnut° BREAK
         mov       ds:[OldBreak],dl         ; £schova p©°znaku BREAK

; ------ vypnut° p©°znaku BREAK

         mov       ax,3301h
         mov       dl,0
         int       21h                      ; vypnut° BREAK

; ------ inicializace videom¢du

         mov       ah,0fh
         call      Int10P
         cmp       al,7
         je        Start3
         cmp       al,2
         je        Start3
         mov       al,3
Start3:  mov       ah,0
         call      Int10P                   ; nastaven° videom¢du
         call      AktPDisp                 ; nastaven° parametrñ displeje

; ------ nulov†n° seznamñ

         mov       bx,offset DatDefL        ; seznam levÇho okna
         mov       byte ptr ds:[bx+SeznPar],b2 ; levÇ okno, disk, aktivn°
         call      InitSezn                 ; inicializace seznamu levÇho okna
         mov       al,ds:[DatParmL]
         mov       ds:[bx+SeznPar2],al      ; t©°dàn° levÇho okna

         mov       bx,offset DatDefR        ; seznam pravÇho okna
         mov       byte ptr ds:[bx+SeznPar],b0+b1 ; pravÇ, streamer, neaktivn°
         call      InitSezn                 ; inicializace seznamu pravÇho okna
         mov       al,ds:[DatParmR]
         mov       ds:[bx+SeznPar2],al      ; t©°dàn° pravÇho okna

         mov       word ptr ds:[AdrHlp],offset TextHlp0 ; nen° n†povàda
         call      DispAll                  ; zobrazen° obrazovky
         call      KurzOff                  ; vypnut° kurzoru

; ------ inicializace parametrñ disku

         call      AktDPar                  ; inicializace parametrñ akt. disku
         call      DispAll                  ; zobrazen° obrazovky

; ------ naáten° obsahu aktivn°ho disku
;˛
         mov       byte ptr cs:[ParBreak],0 ; nulov†n° p©°znaku p©eru®en°
         mov       bx,offset DatDefL        ; definice seznamu disku
         call      ReadDisk                 ; naáten° obsahu disku seznamu BX

; ------ obsluha kl†vesnice

Start32: mov       word ptr ds:[AdrHlp],offset TextHlp0 ; nen° n†povàda
         call      DispAll                  ; zobrazen° obrazovky

         mov       bx,offset DatDefL        ; levÇ okno
         test      byte ptr ds:[DatParm],b0
         jz        Start4                   ; je levÇ okno
         mov       bx,offset DatDefR        ; pravÇ okno

Start4:  call      InpKey                   ; vstup znaku z kl†vesnice

         cmp       dl," "
         jb        Start422
         mov       dh,0
Start422:

         mov       ax,ds:[bx+SeznDAkt]      ; aktivn° poloëka
         call      JumpDX

         dw        4800h,WUp                ; kurzor nahoru
         dw        5000h,WDown              ; kurzor dolñ
         dw        4700h,WHome              ; prvn° ©†dek
         dw        4f00h,WEnd               ; posledn° ©†dek
         dw        4900h,WPgUp              ; str†nka nahoru
         dw        5100h,WPgDwn             ; str†nka dolñ
         dw        4d00h,WRght              ; vpravo
         dw        4b00h,WLeft              ; vlevo
         dw        0f09h,WTab               ; tabel†tor
         dw        5200h,WIns               ; Insert
         dw        "*",WAIns                ; *
         dw        1c0dh,WEnter             ; Enter

         dw        11bh,Konec               ; konec programu
         dw        0,Start4

; -----------------------------------------------------------------------------
;        konec programu ESC
; -----------------------------------------------------------------------------

Konec:   mov       ah,0fh
         call      Int10P                   ; poskytnut° videom¢du
         mov       ah,0
         call      Int10P                   ; inicializace videom¢du

; ------ n†vrat p©°znaku BREAK

         mov       dl,ds:[OldBreak]
         mov       ax,3301h
         int       21h

         int       20h

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                           Editace oken
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

;˛

; -----------------------------------------------------------------------------
;        posun kurzoru dolñ
; -----------------------------------------------------------------------------

WDown:   inc       ax                       ; zvò®en° á°sla poloëky
         cmp       ax,ds:[bx+SeznDNum]      ; je maxim†ln° poloëka ?
         jae       WDown8                   ; je posledn° poloëka
WDown6:  mov       ds:[bx+SeznDAkt],ax      ; nov† aktivn° poloëka
WDown7:  call      DispWin
WDown8:  jmp       Start4

; -----------------------------------------------------------------------------
;        posun kurzoru nahoru
; -----------------------------------------------------------------------------

WUp:     or        ax,ax                    ; je prvn° poloëka ?
         jz        WDown8                   ; je prvn° poloëka
         dec       ax                       ; posun aktivn° poloëky
         jmp       short WDown6

; -----------------------------------------------------------------------------
;        prvn° ©†dek
; -----------------------------------------------------------------------------

WHome:   xor       ax,ax
         jmp       short WDown6

; -----------------------------------------------------------------------------
;        posledn° ©†dek
; -----------------------------------------------------------------------------

WEnd:    mov       ax,ds:[bx+SeznDNum]      ; poáet poloëek
         or        ax,ax
         jz        WDown8
         dec       ax
         mov       ds:[bx+SeznDAkt],ax
         jmp       short WDown6

; -----------------------------------------------------------------------------
;        posun o str†nku nahoru
; -----------------------------------------------------------------------------

WPgUp:   mov       cx,ds:[bx+SeznDTop]      ; prvn° poloëka
         or        cx,cx
         jz        WHome                    ; je zobrazen zaá†tek
         cmp       cx,SOUBDIS-1
         jb        WPgUp2
         mov       cx,SOUBDIS-1
WPgUp2:  sub       ds:[bx+SeznDTop],cx
         sub       ax,cx
         jmp       short WDown6

; -----------------------------------------------------------------------------
;        posun o str†nku dolñ
; -----------------------------------------------------------------------------

WPgDwn:  mov       cx,ds:[bx+SeznDNum]      ; poáet poloëek
         sub       cx,SOUBDIS               ; prvn° poloëka
         jbe       WEnd                     ; je malò poáet poloëek
         sub       cx,ds:[bx+SeznDTop]      ; posunut° poá†tku
         jbe       WEnd
         cmp       cx,SOUBDIS-1
         jb        WPgDwn2
         mov       cx,SOUBDIS-1
WPgDwn2: add       ds:[bx+SeznDTop],cx
         add       ax,cx
WDown66: jmp       short WDown6

; -----------------------------------------------------------------------------
;        oznaáen° jednÇ poloëky
; -----------------------------------------------------------------------------

WIns:    mov       si,ax                    ; aktivn° poloëka
         cmp       si,ds:[bx+SeznDNum]
         jae       WDown8                   ; neplatn† poloëka
         shl       si,1
         mov       si,ds:[bx+si+SeznInd]    ; adresa poloëky
         push      es
         mov       es,ds:[bx+SeznDSeg]
         cmp       si,-1
         je        WIns3                    ; neplatn† poloëka
         call      InvPol                   ; inverze oznaáen° poloëky ES:SI
WIns3:   pop       es
         inc       ax                       ; zvò®en° á°sla poloëky
         cmp       ax,ds:[bx+SeznDNum]      ; je maxim†ln° poloëka ?
         jb        WDown6
         dec       ax
         jmp       short WDown66

; -----------------------------------------------------------------------------
;        zmàna oznaáen° v®ech poloëek
; -----------------------------------------------------------------------------

WAIns:   mov       cx,ds:[bx+SeznDNum]
         jcxz      WDown8                   ; nen° ë†dn† poloëka
         lea       di,[bx+SeznInd]          ; indexov† tabulka
         push      es
         mov       es,ds:[bx+SeznDSeg]
WAIns2:  mov       si,ds:[di]               ; adresa poloëky
         cmp       si,-1
         je        WAIns3                   ; poloëka ".."
         call      InvPol                   ; inverze poloëky
WAIns3:  inc       di
         inc       di
         loop      WAIns2
         pop       es
         jmp       short WDown66

; -----------------------------------------------------------------------------
;        kurzor vlevo - aktivn° je disk
; -----------------------------------------------------------------------------

WLeft:   mov       bx,offset DatDefL
         and       byte ptr ds:[DatParm],not b0 ; p©°znak aktivn°ho levÇho okna
         and       byte ptr ds:[DatDefR+SeznPar],not b2
         or        byte ptr ds:[bx+SeznPar],b2
WLeft2:  jmp       Start32

; -----------------------------------------------------------------------------
;        kurzor vpravo - aktivn° je streamer
; -----------------------------------------------------------------------------

WRght:   mov       bx,offset DatDefR
         or        byte ptr ds:[DatParm],b0 ; p©°znak aktivn°ho pravÇho okna
         and       byte ptr ds:[DatDefL+SeznPar],not b2
         or        byte ptr ds:[bx+SeznPar],b2
         jmp       short WLeft2

; -----------------------------------------------------------------------------
;        tabel†tor - p©epnut° okna
; -----------------------------------------------------------------------------

WTab:    test      byte ptr ds:[DatParm],b0
         jz        WRght
         jmp       short WLeft

; -----------------------------------------------------------------------------
;        Enter - zmàna adres†©e
; -----------------------------------------------------------------------------

WEnter:  mov       si,ax                    ; aktivn° poloëka
         cmp       si,ds:[bx+SeznDNum]
         jb        WEnter2                  ; poloëka je OK
WDown88: jmp       WDown8                   ; neplatn† poloëka
WEnter2: shl       si,1
         mov       si,ds:[bx+si+SeznInd]    ; adresa poloëky

; ------ posun n°ëe o podadres†©

         mov       byte ptr ds:[DTAName],0  ; zru®en° jmÇna k vyhled†n°
         cmp       si,-1
         jne       WEnter4                  ; neplatn† poloëka

         lea       si,[bx+SeznDir]          ; aktivn° adres†© seznamu
         mov       cx,ds:[bx+SeznDirN]      ; dÇlka aktivn°ho seznamu
         xor       dx,dx                    ; á°taá dÇlky jmÇna adres†©e
         add       si,cx
WEnter3: dec       si
         dec       cx
         inc       dx                       ; á°taá dÇlky jmÇna adres†©e
         cmp       byte ptr ds:[si],"\"
         jne       WEnter3

         push      cx
         push      si
         push      ds
         pop       es
         mov       cx,dx                    ; dÇlka jmÇna adres†©e
         mov       di,offset DTAName - 1    ; jmÇno souboru - 1
         cld
         rep       movsb                    ; p©enos jmÇna souboru
         mov       al,0
         stosb                              ; koncov† 0
         pop       si
         pop       cx

         cmp       byte ptr ds:[si-1],":"
         jne       WEnter32
         inc       si
         inc       cx
WEnter32:mov       byte ptr ds:[si],0
         mov       ds:[bx+SeznDirN],cx      ; nov† dÇlka
         jmp       short WEnter6

; ------ posun vò®e o podadres†©

WEnter4: mov       es,ds:[bx+SeznDSeg]      ; segment adres†©e
         test      byte ptr es:[si+FileAtr],DIR
         jz        WDown88                  ; nen° adres†© - neplat°

         lea       di,[bx+SeznDir]          ; aktivn° adres†© seznamu
         mov       cx,ds:[bx+SeznDirN]
         add       di,cx
         cmp       byte ptr ds:[di-1],"\"
         je        WEnter42
         mov       byte ptr ds:[di],"\"
         inc       di
         inc       word ptr ds:[bx+SeznDirN]

WEnter42:push      ds
         push      es

         push      ds
         push      es
         pop       ds
         pop       es

         mov       cl,ds:[si]
         mov       ch,0
         sub       cx,FileName
         add       es:[bx+SeznDirN],cx      ; zvò®en° dÇlky adres†©e
         add       si,FileName
         cld
         rep       movsb
         mov       al,0
         stosb

         pop       es
         pop       ds

WEnter6:
         mov       si,offset AktDir
         call      SrcPath                  ; nalezen° aktivn°ho adres†©e
         mov       si,di
         call      SelFile
         call      SortFile                 ; set©°dàn° obsahu adres†©e

         mov       si,offset DTAName        ; jmÇno adres†©e k p©ednastaven°
         cmp       byte ptr ds:[si],0       ; je adres†© k vyhled†n° ?
         je        WEnter7                  ; nen° adres†© k vyhled†n°

         call      SrcPol                   ; vyhled†n° poloëky DS:SI
         jc        WEnter7                  ; poloëka nenalezena
         mov       ds:[bx+SeznDAkt],ax      ; nov† aktivn° poloëka

WEnter7: jmp       WDown7




;         cmp       byte ptr ds:[80h],2
;         jne       Start000
;         jmp       Starr
;
;Start000:
;         mov       ax,ds:[SektBSeg]
;         mov       ds:[SektSeg],ax
;
;;         mov       ax,ds:[BuffSeg]
;;         mov       es,ax
;;         xor       di,di
;;         mov       cx,289*180/2
;;         cld
;;         mov       ax,-1
;;         rep       stosw
;
;         call      RSoub
;
;         call      KodBlok                  ; vòpoáet kontroln°ch sektorñ
;
;         call      KodSYNU                  ; k¢dov†n° £vodn°ho synchr. sektoru
;
;         mov       byte ptr ds:[AktSekt],0  ; aktu†ln° á°slo sektoru
;         and       byte ptr ds:[AktBlok+1],not (b14/HI) ; datovò sektor
;         mov       cx,289
;         mov       ax,ds:[BuffSeg]
;         mov       es,ax
;         xor       si,si
;Start001:call      KodSekt
;         inc       byte ptr ds:[AktSekt]
;         jnz       Start002
;         or        byte ptr ds:[AktBlok+1],b14/HI
;
;Start002:add       si,180
;         loop      Start001
;
;         call      KodSYNZ                  ; k¢dov†n° z†vàreánÇho synch.sektoru
;
;         mov       byte ptr ds:[CitByte],0
;         mov       word ptr ds:[CitSekt],0
;
;         mov       ax,ds:[SektBSeg]
;         mov       ds:[SektSeg],ax
;
;         mov       word ptr ds:[SektUkaz],0
;         mov       word ptr ds:[CitSynch],UVSYNCH ; poáet synchroniz. sektorñ
;
;         cli
;         call      InitVys
;         jnc       Start01
;         jmp       Start12
;
;Start01: mov       al,0ffh
;         mov       dx,ds:[AdrPort]
;         out       dx,al
;         add       dx,5
;         in        al,dx
;         sti
;
;Start02:
;
;Start11:  sti
;         call      Kurz
;
;;         push      ds
;;         xor       ax,ax
;;         mov       ds,ax
;;         mov       ax,ds:[41ch]
;;         cmp       ax,ds:[41ah]
;;         pop       ds
;         cmp       byte ptr ds:[KeyBreak],0
;         jne       start13                  ; p©eru®en° ESC
;
;         cmp       word ptr ds:[CitSekt],289+ZAVSYNCH
;         jb        Start11
;
;start13:
;         call      DeInit                   ; odinstalov†n° portu COM
;
;
;Start132:
;         mov       ah,1
;         int       16h
;         jz        start12
;Start133:mov       ah,0
;         int       16h
;start12:



; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

Kurz     PROC      NEAR

         push      ax
         push      es

         mov       ax,0b800h
         mov       es,ax
         inc       byte ptr es:[0]
         jnz       Kurz2
         inc       byte ptr es:[2]
Kurz2:   jnz       Kurz3
         inc       byte ptr es:[4]

Kurz3:
         pop       es
         pop       ax
         ret

Kurz     ENDP

; -----------------------------------------------------------------------------
;        p©°jem
; -----------------------------------------------------------------------------
;˛
Starr:
         mov       al,ds:[82h]
         and       al,3
         mov       ds:[Param],al

         mov       ax,ds:[SektBSeg]
         mov       ds:[SektSeg],ax

         cli
         call      InitPri
         jnc       Starr01
         jmp       Starr2

Starr01: mov       dx,ds:[AdrPort]
         in        al,dx
         add       dx,5
         in        al,dx

         mov       byte ptr ds:[CitByte],-4
         mov       word ptr ds:[CitSekt],0
         mov       word ptr ds:[SektUkaz],0
         mov       word ptr ds:[CitSynch],MINSYNCH ; poáet synchroniz. sektorñ

         sti

         mov       es,ds:[SektSeg]
         xor       di,di

Starr02:

Starr1:  sti
         call      Kurz
         cmp       byte ptr ds:[KeyBreak],0
         jne       starr3                   ; p©eru®en° ESC

         cmp       word ptr ds:[CitSekt],289
         jb        Starr1

Starr3:  call      DeInit

; ------ inicializace mapy vadnòch sektorñ

         push      ds
         pop       es
         mov       di,offset ErrMap
         mov       cx,289
         mov       al,-1
         cld
         rep       stosb                    ; vymaz†n° mapy vadnòch sektorñ
         mov       word ptr ds:[ErrCit],289 ; poáet vadnòch sektorñ

; ------ dek¢dov†n° sektorñ

         mov       ax,ds:[SektBSeg]
         mov       ds:[SektSeg],ax
         mov       cx,289                   ; poáet sektorñ

Starr31: xor       ax,ax
         call      KorSekt                  ; korekce sektoru
         sbb       ax,ax                    ; -1=vadnò sektor, 0=OK
         cmp       bx,289                   ; je á°slo sektoru OK ?
         jae       Starr314                 ; chybnÇ á°slo sektoru
         cmp       byte ptr ds:[ErrMap+bx],0 ; je sektor jië nastaven ?
         je        Starr314                 ; je jië nastaven
         mov       byte ptr ds:[ErrMap+bx],al ; p©°znak vadnÇho sektoru
         inc       ax                       ; 1=OK, 0=vadnò
         sub       word ptr ds:[ErrCit],ax  ; sn°ëen° á°taáe vadnòch sektorñ

         sub       word ptr ds:[SektSeg],224/16 ; sn°ëen° adresy sektoru
         call      DekSekt                  ; dek¢dov†n° sektoru
Starr314:loop      Starr31                  ; dal®° sektor

         call      KorBlok                  ; korekce blokñ (oprava chyb)
         mov       ax,ds:[ErrCit]
         add       ds:[CitChyb],ax

         call      WSoub

         mov       ah,0fh
         call      Int10P                   ; poskytnut° videom¢du
         mov       ah,0
         call      Int10P                   ; inicializace videom¢du

;         mov       dx,offset UvTxt
;         mov       ah,9
;         int       21h


         mov       dx,offset KorTxt1
         mov       ah,9
         int       21h

         mov       ax,ds:[CitKor1]
         call      DispNum

         mov       dx,offset KorTxt2
         mov       ah,9
         int       21h

         mov       ax,ds:[CitKor2]
         call      DispNum

         mov       dx,offset KorTxt3
         mov       ah,9
         int       21h

         mov       ax,ds:[CitChyb]
         call      DispNum

         mov       dx,offset KorTxt4
         mov       ah,9
         int       21h

         mov       ah,1
         int       16h
         jz        starr2
         mov       ah,0
         int       16h
Starr2:
         mov       ax,4c00h
         int       21h

; -----------------------------------------------------------------------------
;        obsluha INT 24h a INT 23h
; -----------------------------------------------------------------------------

Int24    PROC      FAR

         mov       al,0
Int23:   iret

Int24    ENDP

; -----------------------------------------------------------------------------
;        zobrazen° á°sla AX
; -----------------------------------------------------------------------------

DispNum  PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx

         xor       cx,cx
         mov       bx,10
DispNum1:xor       dx,dx
         div       bx
         push      dx
         inc       cx
         or        ax,ax
         jnz       DispNum1

DispNum2:pop       dx
         mov       ah,2
         add       dl,"0"
         int       21h
         loop      DispNum2

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispNum  ENDP

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

RSoub    PROC      NEAR

         mov       dx,offset Soubor
         mov       ax,3d00h
         int       21h
         jc        RSoub9
         mov       bx,ax

         push      ds
         mov       ax,ds:[BuffSeg]
         mov       ds,ax
         xor       dx,dx
         mov       cx,256*180
         mov       ah,3fh
         int       21h
         pop       ds

         mov       ah,3eh
         int       21h
RSoub9:  ret

RSoub    ENDP

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

WSoub    PROC      NEAR

         mov       dx,offset Soubor2
         mov       ah,3ch
         xor       cx,cx
         int       21h
         jc        WSoub9
         mov       bx,ax

         push      ds
         mov       ax,ds:[BuffSeg]
         mov       ds,ax
         xor       dx,dx
         mov       cx,256*180
         mov       ah,40h
         int       21h
         pop       ds

         mov       ah,3eh
         int       21h
WSoub9:  ret

WSoub    ENDP



; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                           Zpracov†n° dat
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
; -----------------------------------------------------------------------------
;        zak¢dov†n° datovÇho bloku (sestaven° kontroln°ch sektorñ)
; -----------------------------------------------------------------------------

KodBlok  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es

; ------ p©°prava registrñ

         mov       es,ds:[BuffSeg]          ; segment bufferu souborñ
         push      es
         pop       ds
         mov       di,256*180               ; ukl†dac° adresa sektorñ
         xor       cx,cx
         cld

; ------ vòpoáet kontroln°ch sektorñ ©†dkñ

         xor       si,si                    ; zaá†tek matice
         mov       bx,16                    ; poáet ©†dkñ sektorñ k vòpoátu
KodBlok1:mov       dx,180                   ; poáet bajtñ v sektoru
KodBlok2:mov       cl,16                    ; poáet sektorñ
         mov       al,0
KodBlok3:xor       al,ds:[si]
         add       si,180                   ; bajt v dal®°m sektoru
         loop      KodBlok3
         stosb                              ; kontroln° bajt sektorñ v ©†dku
         sub       si,16*180-1              ; adresa dal®°ho bajtu
         dec       dx                       ; á°taá bajtñ
         jnz       KodBlok2                 ; dal®° bajt v sektoru
         add       si,16*180-180            ; adresa dal®°ho ©†dku
         dec       bx                       ; á°taá ©†dkñ
         jnz       KodBlok1                 ; vòpoáet dal®°ho ©†dku

; ------ vòpoáet kontroln°ch sektorñ sloupcñ

         mov       dx,16*180                ; poáet sloupcñ
         xor       si,si                    ; poá†teán° adresa matice
KodBlok4:mov       cl,16                    ; poáet sektorñ ve sloupci
         mov       al,0
KodBlok5:xor       al,ds:[si]
         add       si,16*180                ; bajt sektoru v dal®°m ©†dku
         loop      KodBlok5                 ; dal®° ©†dek
         stosb
         sub       si,16*16*180-1           ; dal®° sloupec bajtñ
         dec       dx                       ; á°taá sloupcñ
         jnz       KodBlok4                 ; dal®° sloupec

; ------ koncovò kontroln° souáet

         mov       si,(256+16)*180          ; ©†dek kontroln°ch sektorñ sloupcñ
         mov       dx,180                   ; poáet bajtñ v sektoru
KodBlok6:mov       cl,16                    ; poáet sektorñ
         mov       al,0
KodBlok7:xor       al,ds:[si]
         add       si,180
         loop      KodBlok7                 ; dal®° sektor v ©†dku
         stosb
         sub       si,16*180-1              ; adresa dal®°ho bajtu v sektoru
         dec       dx
         jnz       KodBlok6                 ; dal®° bajt v sektoru

; ------ n†vrat registrñ

         pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

KodBlok  ENDP

; -----------------------------------------------------------------------------
;        proveden° korekce datovÇho bloku
; -----------------------------------------------------------------------------

KorBlok  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es

; ------ p©°prava registrñ

         test      byte ptr ds:[Param],b1   ; prov†d° se korekce 2 ?
         jz        KorBlk11                 ; neprov†d° se korekce 2

         mov       es,ds:[BuffSeg]          ; adresa bufferu souborñ
         xor       cx,cx
         cld
KorBlok1:cmp       word ptr ds:[ErrCit],0   ; jsou nàjakÇ chyby ?
         jne       KorBlok2                 ; jsou nàjakÇ chyby
KorBlk11:jmp       KorBlok9                 ; nejsou chyby

; ------ nalezen° ©†dku s jednou chybou

KorBlok2:mov       di,offset ErrMap+256     ; kontroln° sektory ©†dkñ
         mov       si,offset ErrMap         ; mapa vadnòch sektorñ
         mov       dl,16                    ; DL <- poáet ©†dkñ
KorBlk21:mov       cl,16                    ; poáet pozic v ©†dku
         mov       dh,0                     ; á°taá chyb
KorBlk22:call      TestBlk                  ; test bloku DS:SI, je-li vadnò
         loop      KorBlk22
         xchg      si,di
         call      TestBlk
         xchg      si,di
         cmp       dh,1                     ; je 1 chyba ?
         je        KorBlok3                 ; je 1 chyba
         dec       dl                       ; á°taá ©†dkñ
         jnz       KorBlk21                 ; dal®° ©†dek

; ------ test poátu chyb v kontroln°m ©†dku sloupcñ

         mov       si,offset ErrMap+256+16  ; kontroln° ©†dek sloupcñ
         mov       cl,17                    ; poáet sektorñ ke kontrole
         mov       dh,0                     ; á°taá chyb
KorBlk25:call      TestBlk                  ; test bloku
         loop      KorBlk25
         mov       di,si                    ; kontroln° bajt + 1
         dec       si                       ; korekce na ©†dek+16
         cmp       dh,1                     ; je 1 chyba v kontroln°m ©†dku ?
         je        KorBlok3                 ; je 1 chyba

; ------ test poátu chyb v kontroln°m ©†dku ©†dkñ

         mov       si,offset ErrMap+256
         mov       cl,16                    ; poáet sektorñ ke kontrole
         mov       dh,0                     ; á°taá chyb
KorBlk26:call      TestBlk                  ; test bloku
         loop      KorBlk26
         xchg      si,di                    ; DI <- adresa konce ©†dku
         mov       si,offset ErrMap+256+16+16 ; celkovò kontroln° sektor
         call      TestBlk
         xchg      si,di
         cmp       dh,1                     ; je 1 chyba ?
         jne       KorBLok4                 ; nen° 1 chyba-prohled†v†n° sloupcñ

; ------ vodorovn† korekce sektoru (BX=vadnò sektor, SI=©†dek+16, DI=kontrola+1)

KorBlok3:mov       byte ptr ds:[bx],0       ; zru®en° p©°znaku vadnÇho sektoru
         sub       bx,offset ErrMap         ; á°slo sektoru k opravà
         sub       si,offset ErrMap+16      ; á°slo ©†dku k opravà
         sub       di,offset ErrMap+1       ; á°slo kontroln°ho sektoru

; ------ vòpoáet adres sektorñ

         mov       ax,180                   ; poáet bajtñ na sektor
         mul       bx
         xchg      ax,bx                    ; BX <- adresa sektoru k opravà
         mov       ax,180                   ; poáet bajtñ na sektor
         mul       si
         xchg      ax,si                    ; SI <- adresa ©†dku sektorñ
         mov       ax,180                   ; poáet bajtñ na sektor
         mul       di
         xchg      ax,di                    ; DI <- adresa kontroln°ho sektoru

; ------ proveden° horizont†ln° korekce sektoru

         push      ds
         push      es
         pop       ds                       ; DS <- adresa bufferu sektorñ
         mov       dx,180                   ; poáet bajtñ ke korekci
KorBlk32:mov       cl,16                    ; poáet sektorñ v ©†dku
         mov       al,0                     ; st©adaá kontroln°ho souátu
KorBlk34:xor       al,ds:[si]
         add       si,180
         loop      KorBlk34
         xor       al,ds:[di]               ; kontroln° sektor
         xor       ds:[bx],al               ; proveden° korekce
         sub       si,16*180-1              ; ukazatel sektorñ v ©†dku
         inc       di                       ; ukazatel kontroln°ho sektoru
         inc       bx                       ; ukazatel opravovanÇho sektoru
         dec       dx                       ; á°taá bajtñ v sektoru
         jnz       KorBlk32                 ; dal®° bajt
         pop       ds
         dec       word ptr ds:[ErrCit]     ; sn°ëen° á°taáe chyb
         inc       word ptr ds:[CitKor2]    ; á°taá korekc° 2
         jmp       KorBlok1                 ; dal®° opravy



; ------ nalezen° sloupce s jednou chybou

KorBlok4:mov       di,offset ErrMap+256+16  ; kontroln° sektory sloupcñ
         mov       si,offset ErrMap         ; mapa vadnòch sektorñ
         mov       dl,16                    ; DL <- poáet sloupcñ
KorBlk41:mov       cl,16                    ; poáet ©†dkñ ve sloupci
         mov       dh,0                     ; á°taá chyb
KorBlk42:call      TestBlk                  ; test bloku DS:SI, je-li vadnò
         add       si,16-1                  ; adresa dal®°ho ©†dku
         loop      KorBlk42
         sub       si,16*16-1               ; zaá†tek dal®°ho sloupce
         xchg      si,di
         call      TestBlk
         xchg      si,di
         cmp       dh,1                     ; je 1 chyba ?
         je        KorBlok5                 ; je 1 chyba
         dec       dl                       ; á°taá ©†dkñ
         jnz       KorBlk41                 ; dal®° ©†dek
         jmp       KorBlok9                 ; opravu nelze provÇst

; ------ vertik. korekce sektoru (BX=vadnò sektor, SI=sloupec+1, DI=kontrola+1)

KorBlok5:mov       byte ptr ds:[bx],0       ; zru®en° p©°znaku vadnÇho sektoru
         sub       bx,offset ErrMap         ; á°slo sektoru k opravà
         sub       si,offset ErrMap+1       ; á°slo sloupce k opravà
         sub       di,offset ErrMap+1       ; á°slo kontroln°ho sektoru

; ------ vòpoáet adres sektorñ

         mov       ax,180                   ; poáet bajtñ na sektor
         mul       bx
         xchg      ax,bx                    ; BX <- adresa sektoru k opravà
         mov       ax,180                   ; poáet bajtñ na sektor
         mul       si
         xchg      ax,si                    ; SI <- adresa sloupce sektorñ
         mov       ax,180                   ; poáet bajtñ na sektor
         mul       di
         xchg      ax,di                    ; DI <- adresa kontroln°ho sektoru

; ------ proveden° vertik†ln° korekce sektoru

         push      ds
         push      es
         pop       ds                       ; DS <- adresa bufferu sektorñ
         mov       dx,180                   ; poáet bajtñ ke korekci
KorBlk52:mov       cl,16                    ; poáet sektorñ ve sloupci
         mov       al,0                     ; st©adaá kontroln°ho souátu
KorBlk54:xor       al,ds:[si]
         add       si,16*180
         loop      KorBlk54
         xor       al,ds:[di]               ; kontroln° sektor
         xor       ds:[bx],al               ; proveden° korekce
         sub       si,16*16*180-1           ; ukazatel sektorñ ve sloupci
         inc       di                       ; ukazatel kontroln°ho sektoru
         inc       bx                       ; ukazatel opravovanÇho sektoru
         dec       dx                       ; á°taá bajtñ v sektoru
         jnz       KorBlk52                 ; dal®° bajt
         pop       ds
         dec       word ptr ds:[ErrCit]     ; sn°ëen° á°taáe chyb
         inc       word ptr ds:[CitKor2]    ; á°taá korekc° 2
         jmp       KorBlok1                 ; dal®° opravy

; ------ n†vrat registrñ

KorBlok9:pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

KorBlok  ENDP

; -----------------------------------------------------------------------------
;     test bloku DS:SI, je-li vadnò (DH=á°taá vadnòch blokñ, BX=£schova SI)
; -----------------------------------------------------------------------------

TestBlk  PROC      NEAR

         cmp       byte ptr ds:[si],0
         je        TestBlk1                 ; nen° vadnò
         mov       bx,si                    ; £schova adresy sektoru
         inc       dh                       ; á°taá chyb
TestBlk1:inc       si
         ret

TestBlk  ENDP

; -----------------------------------------------------------------------------
;        zak¢dov†n° sektoru ES:SI (a p©id†n° k seznamu sektorñ)
; -----------------------------------------------------------------------------

KodSekt  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es

; ------ ukl†dac° adresa sektoru

         push      si
         push      es
         mov       es,ds:[SektSeg]          ; segment sektoru
         add       word ptr ds:[SektSeg],224/16 ; posun ukazatele sektorñ

; ------ p©enesen° z†hlav° sektoru

         xor       di,di
         mov       si,offset Zahlavi        ; z†hlav° sektoru
         mov       cx,10/2                  ; dÇlka z†hlav° sektoru
         cld
         rep       movsw                    ; p©enesen° z†hlav° sektoru

; ------ p©enesen° dat sektoru

         pop       ds                       ; DS <- segment dat sektoru
         pop       si
         mov       cl,9/2                   ; zbytek dat v prvn°m ©†dku
         rep       movsw                    ; p©enos zbytku prvn°ho ©†dku
         movsb
         mov       dx,9                     ; poáet zbylòch ©†dkñ dat
KodSekt1:inc       di                       ; p©eskoáen° bajtu souátu XOR
         mov       cl,19/2
         rep       movsw                    ; p©enesen° jednoho ©†dku dat
         movsb
         dec       dx                       ; á°taá ©†dkñ dat
         jnz       KodSekt1                 ; p©enesen° dal®°ho ©†dku dat

; ------ vòpoáet kontroln°ho bajtu ©†dkñ dat XOR

         push      es
         pop       ds                       ; DS <- adresa sektoru
         xor       di,di
         mov       dx,10                    ; poáet ©†dkñ dat se z†hlav°m
KodSekt2:mov       cl,19                    ; dÇlka jednoho ©†kdu
         mov       al,0                     ; vòchoz° hodnota souátu
KodSekt3:xor       al,ds:[di]
         inc       di
         loop      KodSekt3                 ; dal®° bajt ©†dku
         stosb                              ; uloëen° kontroln°ho bajtu XOR
         dec       dx                       ; á°taá ©†dkñ
         jnz       KodSekt2                 ; vòpoáet dal®°ho ©†dku dat

; ------ vòpoáet kontroln°ho opravnÇho ©†dku XOR

         xor       si,si
         mov       dx,20                    ; poáet sloupcñ dat
KodSekt4:mov       cl,10                    ; poáet ©†dkñ dat
         mov       al,0                     ; vòzhoz° hodnota kontroln°ho souátu
KodSekt5:xor       al,ds:[si]
         add       si,20                    ; adresa dal®°ho ©†dku dat
         loop      KodSekt5                 ; bajt v dal®°m ©†dku sloupce
         stosb                              ; uloëen° kontroln°ho bajtu XOR
         sub       si,10*20-1               ; adresa zaá†tku dal®°ho soupce
         dec       dx                       ; á°taá sloupcñ dat
         jnz       KodSekt4                 ; vòpoáet dal®°ho sloupce dat

; ------ vòpoáet kontroln°ho souátu dat CRC

         xor       si,si                    ; SI <- zaá†tek dat sektoru
         mov       cx,220                   ; velikost bloku dat
         mov       dx,-1
         call      CheckSum                 ; vòpoáet kontroln°ho souátu dat
         mov       ds:[di],dx               ; uloëen° kontroln°ho souátu dat
         mov       word ptr ds:[di+2],-1    ; synchronizaán° bajty

; ------ n†vrat registrñ

         pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

KodSekt  ENDP

; -----------------------------------------------------------------------------
;        zak¢dov†n° £vodn°ho synchronizaán°ho sektoru
; -----------------------------------------------------------------------------

KodSYNU  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      si
         push      di
         push      es

; ------ ukl†dac° adresa sektoru

         mov       es,ds:[SektSeg]          ; segment sektoru
         add       word ptr ds:[SektSeg],224/16 ; posun ukazatele sektorñ
         xor       di,di

; ------ p©enesen° z†hlav° sektoru

         mov       si,offset Zahlavi        ; z†hlav° sektoru
         mov       cx,10/2                  ; dÇlka z†hlav° sektoru
         cld
         rep       movsw                    ; p©enesen° z†hlav° sektoru

; ------ korekce poloëek v z†hlav°

         mov       byte ptr es:[di-2],255   ; oznaáen° synchronizaán°ho sektoru
         or        byte ptr es:[di-3],b14/HI ; p©°znak korekán°ho sektoru
         mov       ax,ds:[FileOff]          ; offset prvn°ho souboru
         stosw

; ------ vymaz†n° zbytku sektoru

         mov       ax,-1
         mov       cx,(224-12)/2            ; dÇlka zbytku dat ve slovech
         rep       stosw                    ; vymaz†n° zbytku sektoru

; ------ n†vrat registrñ

         pop       es
         pop       di
         pop       si
         pop       cx
         pop       ax
         ret

KodSYNU  ENDP

; -----------------------------------------------------------------------------
;        zak¢dov†n° z†vàreánÇho synchronizaán°ho sektoru
; -----------------------------------------------------------------------------

KodSYNZ  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      si
         push      di
         push      es

; ------ ukl†dac° adresa sektoru

         mov       es,ds:[SektSeg]          ; segment sektoru
         add       word ptr ds:[SektSeg],224/16 ; posun ukazatele sektorñ
         xor       di,di

; ------ p©enesen° z†hlav° sektoru

         mov       si,offset Zahlavi        ; z†hlav° sektoru
         mov       cx,10/2                  ; dÇlka z†hlav° sektoru
         cld
         rep       movsw                    ; p©enesen° z†hlav° sektoru

; ------ korekce poloëek v z†hlav°

         mov       byte ptr es:[di-2],33    ; oznaáen° synchronizaán°ho sektoru
         or        byte ptr es:[di-3],b14/HI ; p©°znak korekán°ho sektoru

; ------ vymaz†n° zbytku sektoru

         mov       ax,-1
         mov       cx,(224-10)/2            ; dÇlka zbytku dat ve slovech
         rep       stosw                    ; vymaz†n° zbytku sektoru

; ------ n†vrat registrñ

         pop       es
         pop       di
         pop       si
         pop       cx
         pop       ax
         ret

KodSYNZ  ENDP

; -----------------------------------------------------------------------------
;        korekce jednoho sektoru (CY=chyba, BX=á°slo sektoru)
; -----------------------------------------------------------------------------

KorSekt  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      ds

; ------ p©°prava registrñ

         mov       ax,ds:[SektSeg]          ; segment sektoru
         add       word ptr ds:[SektSeg],224/16 ; posun ukazatele sektorñ
         mov       ds,ax

; ------ kontrola ©†dkñ sektoru

         cld
         mov       dx,11                    ; poáet ©†dkñ dat
         xor       cx,cx
         xor       bx,bx                    ; BX <- 0 á°taá vadnòch ©†dkñ
         xor       si,si
KorSekt2:mov       cl,20                    ; poáet bajtñ na ©†dek
         mov       ah,0
KorSekt3:lodsb
         xor       ah,al
         loop      KorSekt3
         jz        KorSekt4                 ; ©†dek je OK
         inc       bx                       ; á°taá vadnòch ©†dkñ
         mov       di,si                    ; adresa konce ©†dku
KorSekt4:dec       dx                       ; á°taá ©†dkñ
         jnz       KorSekt2                 ; kontrola dal®°ho ©†dku

; ------ test, zda je pr†và 1 ©†dek k opravà

         cmp       bl,1                     ; je vadnò 1 ©†dek ?
         ja        KorSekt8                 ; je v°c vadnòch ©†dkñ
         jb        KorSekt7                 ; nen° ë†dnò vadnò ©†dek

; ------ korekce vadnÇho ©†dku

         test      byte ptr cs:[Param],b0   ; prov†d° se korekce 1 ?
         jz        KorSekt7                 ; neprov†d° se korekce 1

         sub       di,20                    ; adresa zaá†tku ©†dku
         xor       si,si                    ; zaá†tek dat
         mov       dx,20                    ; poáet sloupcñ v matici
KorSekt5:mov       cl,11                    ; poáet ©†dkñ
         mov       ah,0
KorSekt6:lodsb
         add       si,20-1                  ; adresa dal®°ho ©†dku
         xor       ah,al
         loop      KorSekt6
         xor       ds:[di],ah               ; korekce vadnÇho bajtu
         inc       di
         sub       si,(11*20)-1
         dec       dx
         jnz       KorSekt5
         inc       word ptr cs:[CitKor1]

; ------ ovà©en° kontroln°ho souátu

KorSekt7:mov       dx,-1
         xor       si,si
         mov       cx,220                   ; velikost bloku dat
         call      CheckSum                 ; vòpoáet kontroln°ho souátu dat
         cmp       ds:[220],dx              ; kontrola kontroln°ho souátu dat
         je        KorSekt9

; ------ chyba

KorSekt8:stc                                ; p©°znak chyby

; ------ á°slo sektoru

KorSekt9:pushf
         mov       bh,0
         mov       bl,ds:[8]                ; aktu†ln° á°slo sektoru
         test      byte ptr ds:[7],b14/HI   ; je to korekán° sektor ?
         jz        KorSektA                 ; nen° to korekán° sektor
         mov       bh,1                     ; á°slo korekán°ho sektoru
KorSektA:popf

; ------ n†vrat registrñ

         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

KorSekt  ENDP

; -----------------------------------------------------------------------------
;        dek¢dov†n° sektoru do bufferu souboru
; -----------------------------------------------------------------------------

DekSekt  PROC      NEAR

; ------ £schova registrñ

         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es

; ------ adresa sektoru

         mov       es,ds:[BuffSeg]          ; segment bufferu souborñ
         mov       cx,ds:[SektSeg]
         add       word ptr ds:[SektSeg],224/16
         mov       ds,cx

; ------ adresa v bufferu souborñ

         mov       ah,0
         mov       al,ds:[8]                ; aktu†ln° á°slo sektoru
         test      byte ptr ds:[7],b14/HI   ; je to korekán° sektor ?
         jz        DekSekt1                 ; nen° to korekán° sektor
         mov       ah,1                     ; á°slo korekán°ho sektoru
DekSekt1:cmp       ax,289
         jae       DekSekt8                 ; neplatnÇ á°slo sektoru
         mov       cx,180                   ; dÇlka dat
         mul       cx                       ; offset sektoru
         xchg      ax,di                    ; ukl†dac° adresa sektoru v bufferu

; ------ p©enos dat sektoru

         cld
         mov       si,10
         mov       cx,9/2
         rep       movsw
         movsb

         mov       dx,9
DekSekt2:inc       si
         mov       cl,19/2
         rep       movsw
         movsb
         dec       dx
         jnz       DekSekt2

; ------ n†vrat registrñ

DekSekt8:pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         ret

DekSekt  ENDP

; -----------------------------------------------------------------------------
;        Kontroln° souáet CRC bloku dat
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=zaá†tek bloku dat
;        CX=poáet bajtñ
;        DX=vstupn° hodnota kontroln°ho souátu
; VùSTUP:DX=vòstupn° hodnota kontroln°ho souátu
; -----------------------------------------------------------------------------

CheckSum PROC      NEAR

         push      ax
         push      cx
         push      di

         jcxz      CheckSm2                 ; nen° ë†dnò bajt
         mov       di,cx                    ; poáet bajtñ pro kontroln° souáet
         cld                                ; smàr nahoru

CheckSm1:lodsb                              ; a = fgetc(fp);
         xor       al,dh                    ; d = a ^= d;
         mov       dh,al
         mov       cl,4
         shr       al,cl                    ; a >>= 4;
         xor       al,dh                    ; d = a ^= d;
         mov       dh,al
         mov       cl,3
         ror       al,cl                    ; a = (a >> 3) | (a << 5);
         mov       ch,al                    ; f = a;
         and       al,1fh                   ; a &= 0x1f;
         xor       al,dl                    ; e = a ^= e;
         mov       dl,al
         mov       al,ch                    ; a = f;
         ror       al,1                     ; a = (a >> 1) | (a << 7);
         and       al,0f0h                  ; a &= 0xf0;
         xor       al,dl                    ; e = a ^= e;
         mov       dl,al
         mov       al,ch                    ; a = f & 0xe0;
         and       al,0e0h
         xor       al,dh                    ; a ^= d;
         mov       dh,dl                    ; d = e;
         mov       dl,al                    ; e = a;

         dec       di
         jnz       CheckSm1                 ; dal®° bajt

CheckSm2:pop       di
         pop       cx
         pop       ax
         ret

CheckSum ENDP

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                        Obsluha vys°l†n° a p©°jmu dat
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
; -----------------------------------------------------------------------------
;        inicializace portu na vys°l†n°
; -----------------------------------------------------------------------------

InitVys  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      es

; ------ adresa portu

         push      ds
         mov       bx,ds:[Port]             ; á°slo portu COMn
         shl       bx,1
         xor       ax,ax
         mov       ds,ax                    ; DS <- 0
         mov       dx,ds:[bx+400h]          ; adresa portu
         pop       ds
         or        dx,dx
         jnz       InitVys1
         stc
         jmp       InitVys8                 ; neplatn† adresa portu COM
InitVys1:mov       ds:[AdrPort],dx          ; adresa portu COM

; ------ zru®en° poëadavkñ od portu

         cli
         in        al,dx                    ; zru®en° p©ij°mac°ho bufferu
         inc       dx                       ; 1: registr povolen° p©eru®en°
         xor       al,al                    ; AL <- 0
         out       dx,al                    ; z†kaz v®ech p©eru®en°
         add       dx,3                     ; 4: ©°dic° registr modemu
         out       dx,al                    ; z†kaz p©eru®en° a sign†lñ modemu
         inc       dx                       ; 5: stavovò registr linky
         in        al,dx                    ; zru®en° poëadavkñ od linky
         inc       dx                       ; 6: stavovò registr modemu
         in        al,dx                    ; zru®en° poëadavkñ modemu

; ------ £schova adresy INT 08h

         mov       ax,3508h
         int       21h
         mov       word ptr ds:[Old08],bx
         mov       word ptr ds:[Old08+2],es

; ------ £schova adresy INT 09h

         mov       ax,3509h
         int       21h
         mov       word ptr ds:[Old09],bx
         mov       word ptr ds:[Old09+2],es

; ------ instalace obsluhy INT 08h

         mov       dx,offset Int08
         mov       ax,2508h
         int       21h

; ------ instalace obsluhy INT 09h

         mov       dx,offset Int09
         mov       ax,2509h
         int       21h

; ------ £schova pñvodn°ho p©eru®en° COM

         call      GetICom                  ; poskytnut° á°sla p©eru®en° COM
         push      ax
         mov       ah,35h
         int       21h
         mov       word ptr ds:[OldComm],bx
         mov       word ptr ds:[OldComm+2],es
         pop       ax

; ------ instalace obsluhy p©eru®en° COM

         push      ax
         mov       ah,25h
         mov       dx,offset IntVys         ; adresa obsluhy vys°laáe
         int       21h                      ; instalace obsluhy vys°laáe
         pop       ax

; ------ inicializace portu COM

         mov       dx,ds:[AdrPort]          ; adresa portu COM
         add       dx,3                     ; 3: ©°dic° registr linky
         mov       al,10000011b
         out       dx,al                    ; DLAB, 8 bitñ bez parity, 1 STOP b.
         inc       dx                       ; 4: ©°dic° registr modemu
         mov       al,1011b                 ; OUT2 a RTS+DTR
         out       dx,al                    ; ©°dic° registr modemu
         sub       dx,4                     ; 0: registr dàliáky LOW
         mov       al,1
         out       dx,al                    ; dàlic° pomàr 1
         inc       dx                       ; 1: registr dàliáky HIGH
         mov       al,0
         out       dx,al
         inc       dx
         inc       dx                       ; 3: ©°dic° registr linky
         mov       al,00000011b             ; 8 bitñ bez parity, 1 STOP bit
         out       dx,al
         dec       dx                       ; 2:
         dec       dx                       ; 1:
         mov       al,0010b                 ; p©eru®en° po vysl†n° znaku
         out       dx,al

; ------ nastaven° registru p©eru®en°

         in        al,[21h]
         mov       ds:[OldInt],al           ; £schova masky p©eru®en°
         mov       al,ah
         out       [21h],al                 ; povoleno p©eru®en°
         clc

; ------ n†vrat registrñ

InitVys8:pop       es
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

InitVys  ENDP

; -----------------------------------------------------------------------------
;        inicializace portu na p©°jem
; -----------------------------------------------------------------------------

InitPri  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      es

; ------ adresa portu

         push      ds
         mov       bx,ds:[Port]             ; á°slo portu COMn
         shl       bx,1
         xor       ax,ax
         mov       ds,ax                    ; DS <- 0
         mov       dx,ds:[bx+400h]          ; adresa portu
         pop       ds
         or        dx,dx
         jnz       InitPri1
         stc
         jmp       InitPri8                 ; neplatn† adresa portu COM
InitPri1:mov       ds:[AdrPort],dx          ; adresa portu COM

; ------ zru®en° poëadavkñ od portu

         cli
         in        al,dx                    ; zru®en° p©ij°mac°ho bufferu
         inc       dx                       ; 1: registr povolen° p©eru®en°
         xor       al,al                    ; AL <- 0
         out       dx,al                    ; z†kaz v®ech p©eru®en°
         add       dx,3                     ; 4: ©°dic° registr modemu
         out       dx,al                    ; z†kaz p©eru®en° a sign†lñ modemu
         inc       dx                       ; 5: stavovò registr linky
         in        al,dx                    ; zru®en° poëadavkñ od linky
         inc       dx                       ; 6: stavovò registr modemu
         in        al,dx                    ; zru®en° poëadavkñ modemu

; ------ £schova adresy INT 08h

         mov       ax,3508h
         int       21h
         mov       word ptr ds:[Old08],bx
         mov       word ptr ds:[Old08+2],es

; ------ £schova adresy INT 09h

         mov       ax,3509h
         int       21h
         mov       word ptr ds:[Old09],bx
         mov       word ptr ds:[Old09+2],es

; ------ instalace obsluhy INT 08h

         mov       dx,offset Int08
         mov       ax,2508h
         int       21h

; ------ instalace obsluhy INT 09h

         mov       dx,offset Int09
         mov       ax,2509h
         int       21h

; ------ £schova pñvodn°ho p©eru®en° COM

         call      GetICom                  ; poskytnut° á°sla p©eru®en° COM
         push      ax
         mov       ah,35h
         int       21h
         mov       word ptr ds:[OldComm],bx
         mov       word ptr ds:[OldComm+2],es
         pop       ax

; ------ instalace obsluhy p©eru®en° COM

         push      ax
         mov       ah,25h
         mov       dx,offset IntPri         ; adresa obsluhy p©ij°maáe
         int       21h                      ; instalace obsluhy p©ij°maáe
         pop       ax

; ------ inicializace portu COM

         mov       dx,ds:[AdrPort]          ; adresa portu COM
         add       dx,3                     ; 3: ©°dic° registr linky
         mov       al,10000011b
         out       dx,al                    ; DLAB, 8 bitñ bez parity, 1 STOP b.
         inc       dx                       ; 4: ©°dic° registr modemu
         mov       al,1010b                 ; OUT2 a RTS
         out       dx,al                    ; ©°dic° registr modemu
         sub       dx,4                     ; 0: registr dàliáky LOW
         mov       al,1
         out       dx,al                    ; dàlic° pomàr 1
         inc       dx                       ; 1: registr dàliáky HIGH
         mov       al,0
         out       dx,al
         inc       dx
         inc       dx                       ; 3: ©°dic° registr linky
         mov       al,00000011b             ; 8 bitñ bez parity, 1 STOP bit
         out       dx,al
         dec       dx                       ; 2:
         dec       dx                       ; 1:
         mov       al,0101b                 ; p©eru®en° p©i p©°jmu znaku
         out       dx,al

; ------ nastaven° registru p©eru®en°

         in        al,[21h]
         mov       ds:[OldInt],al           ; £schova masky p©eru®en°
         mov       al,ah
         out       [21h],al                 ; povoleno p©eru®en°
         clc

; ------ n†vrat registrñ

InitPri8:pop       es
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

InitPri  ENDP

; -----------------------------------------------------------------------------
;        poskytnut° á°sla p©eru®en° (-> AL) a masky p©eru®en° COM (-> AH)
; -----------------------------------------------------------------------------

GetICom  PROC      NEAR

         mov       ax,(NOT b4+b1+b0)*HI + 0ch ; COM1 a COM3
         test      byte ptr ds:[Port],b0      ; je COM1 nebo COM3 ?
         jz        GetICom2                   ; je COM1 nebo COM3
         mov       ax,(NOT b3+b1+b0)*HI + 0bh ; COM2 a COM4
GetICom2:ret

GetICom  ENDP

; -----------------------------------------------------------------------------
;        p©eru®en° p©i vys°l†n° sektoru
; -----------------------------------------------------------------------------

IntVys   PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      dx
         push      ds
         push      es

; ------ p©°prava registrñ

         push      cs
         pop       ds

; ------ prvn° áten° stavovÇho registru p©eru®en°

         mov       dx,ds:[AdrPort]          ; adresa portu COM
         mov       es,ds:[SektSeg]
         inc       dx
         inc       dx
         in        al,dx                    ; stavovò registr p©eru®en°
         jmp       short IntVys2

; ------ test, zda je dal®° p©eru®en° od portu

IntVys1: mov       dx,ds:[AdrPort]          ; adresa portu COM
         inc       dx
         inc       dx
         in        al,dx                    ; stavovò registr p©eru®en°
         test      al,1                     ; je dal®° p©eru®en° ?
         jz        IntVys2
         jmp       IntVys9                  ; nen° dal®° p©eru®en°

; ------ test, zda je p©eru®en° p©i vys°l†n°

IntVys2: cmp       al,2                     ; p©eru®en° p©i vys°l†n° ?
         jne       IntVys8                  ; nen° p©eru®en° p©i vys°l†n°

         dec       dx
         dec       dx

; ------ zvò®en° á°taáe bajtñ sektoru

         mov       ah,ds:[CitByte]          ; á°taá bajtñ sektoru
         inc       ah
         mov       ds:[CitByte],ah          ; novò á°taá bajtñ sektoru

; ------ test, zda jsou data sektoru

         cmp       ah,224+1                 ; jsou data sektoru ?
         jae       IntVys3                  ; nejsou data

; ------ vysl†n° datovÇho bajtu

         mov       bx,ds:[SektUkaz]         ; ukazatel dat sektoru
         mov       al,es:[bx]               ; bajt sektoru k vysl†n°
         inc       bx
         mov       ds:[SektUkaz],bx         ; novò ukazatel dat sektoru
         jmp       short IntVys7

; ------ zaá†tek synchronizace

IntVys3: jne       IntVys4                  ; nen° zaá†tek synchronizace
         add       dx,4
         mov       al,1000b
         out       dx,al
         sub       dx,4

; ------ konec synchronizace

IntVys4: cmp       ah,226+1
         jne       IntVys5
         add       dx,4
         mov       al,1011b
         out       dx,al
         sub       dx,4

; ------ prvn° startovac° bajt

IntVys5: cmp       ah,228+1
         jb        IntVys6
         mov       al,2                     ; prvn° startovac° bajt
         je        IntVys7

; ------ druhò startovac° bajt

         cmp       byte ptr es:[8],33       ; je z†vàreánò synchr. sektor ?
         jne       IntVys52
         test      byte ptr es:[7],b14/HI   ; korekán° sektor ?
         jnz       IntVys57                 ; je z†vàreánò sychr. sektor

IntVys52:mov       word ptr ds:[SektUkaz],0
         cmp       word ptr ds:[CitSynch],0 ; je synchronizaán° sektor ?
         je        IntVys55                 ; nen° synchronizaán° sektor
         dec       word ptr ds:[CitSynch]   ; sn°ëen° á°taáe sektorñ
         jmp       short IntVys56
IntVys55:add       word ptr ds:[SektSeg],224/16
         mov       es,ds:[SektSeg]
IntVys57:inc       word ptr ds:[CitSekt]    ; zvò®en° á°taáe sektorñ
IntVys56:mov       byte ptr ds:[CitByte],0  ; inicializace á°taáe
         mov       al,0e5h                  ; druhò startovac° bajt
         jmp       short IntVys7

; ------ vysl†n° datovÇho bajtu

IntVys6: mov       al,0ffh
IntVys7: out       dx,al
         inc       dx
         inc       dx

; ------ zru®en° stavovÇho registru linky

IntVys8: add       dx,3                     ; 5: stavovò registr linky
         in        al,dx                    ; zru®en° poëadavku od reg. linky
         jmp       IntVys1            ; dal®° test

; ------ n†vrat registrñ

IntVys9: mov       al,20h
         out       [20h],al                 ; uvolnàn° ©adiáe p©eru®en°
         pop       es
         pop       ds
         pop       dx
         pop       bx
         pop       ax
         iret

IntVys   ENDP

; -----------------------------------------------------------------------------
;        p©eru®en° p©i p©°jmu sektoru
; -----------------------------------------------------------------------------

IntPri   PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      dx
         push      ds
         push      es

; ------ p©°prava registrñ

         push      cs
         pop       ds

; ------ prvn° áten° stavovÇho registru p©eru®en°

         mov       dx,ds:[AdrPort]          ; adresa portu COM
         mov       es,ds:[SektSeg]
         inc       dx
         inc       dx
         in        al,dx                    ; stavovò registr p©eru®en°
         jmp       short IntPri2

; ------ test, zda je dal®° p©eru®en° od portu

IntPri1: mov       dx,ds:[AdrPort]          ; adresa portu COM
         inc       dx
         inc       dx
         in        al,dx                    ; stavovò registr p©eru®en°
         test      al,1                     ; je dal®° p©eru®en° ?
         jz        IntPri2
         jmp       IntPri9                  ; nen° dal®° p©eru®en°

; ------ test, zda je p©eru®en° p©i p©°jmu

IntPri2: cmp       al,4                     ; p©eru®en° p©i p©°jmu ?
         jne       IntPri8                  ; nen° p©eru®en° p©i p©°jmu

; ------ p©°jem datovÇho bajtu

         dec       dx
         dec       dx
         in        al,dx                    ; p©°jem bajtu
         inc       dx
         inc       dx

; ------ á°taá bajtñ sektoru

         mov       ah,ds:[CitByte]          ; á°taá bajtñ sektoru
         cmp       ah,222                   ; je platnò bajt ?
         jae       IntPri3                  ; nen° platnò bajt

; ------ p©°jem platnÇho bajtu sektoru

IntPri25:mov       bx,ds:[SektUkaz]         ; ukazatel dat sektoru
         mov       es:[bx],al               ; uloëen° p©ijatÇho bajtu
         inc       bx
         mov       ds:[SektUkaz],bx         ; novò ukazatel dat sektoru
         jmp       short IntPri6

; ------ p©°jem startovac°ho bajtu

IntPri3: cmp       ax,0fe02h                ; prvn° startovac° bajt ?
         je        IntPri6                  ; prvn° startovac° bajt
         cmp       ax,0ffe5h                ; druhò startovac° bajt ?
         je        IntPri6                  ; druhò startovac° bajt

; ------ 2 synchronizaán° bajty

         cmp       al,0ffh                  ; synchronizace ?
         jne       IntPri7                  ; nen° synchronizace
         cmp       ah,-2                    ; je posledn° bajt ?
         je        IntPri61                 ; je posledn° bajt - nezvò®° se

; ------ zvò®en° á°taáe bajtñ sektoru

IntPri6: inc       ah
IntPri61:mov       ds:[CitByte],ah          ; novò á°taá bajtñ sektoru
         cmp       ah,222                   ; jsou jië v®echny bajty sektoru ?
         jne       IntPri8                  ; nejsou je®tà v®echny bajty sektoru
         cmp       byte ptr ds:[CitSynch],0 ; áek† se na synchronizaán° sektor ?
         je        IntPri62                 ; neáek† se na synchronizaci

         cmp       byte ptr es:[8],255      ; je sektor 255 ?
         jne       IntPri66                 ; nen° sektor 255
         test      byte ptr es:[7],b14/HI   ; je synchronizaán° sektor ?
         jz        IntPri66                 ; nen° synchronizaán° sektor
         dec       byte ptr ds:[CitSynch]   ; sn°ëen° á°taáe synch. sektorñ
         jmp       short IntPri66

IntPri62:cmp       byte ptr es:[8],255      ; je sektor 255 ?
         jne       IntPri64                 ; nen° sektor 255
         test      byte ptr es:[7],b14/HI   ; je synchronizaán° sektor ?
         jnz       IntPri66                 ; je synchronizaán° sektor

IntPri64:inc       word ptr ds:[CitSekt]    ; zvò®en° á°taáe sektorñ
         add       word ptr ds:[SektSeg],224/16
         mov       es,ds:[SektSeg]
IntPri66:mov       word ptr ds:[SektUkaz],0 ; oprava ukazatele sektoru
IntPri7: mov       byte ptr ds:[CitByte],-4 ; á°taá startovac°ch bajtñ

; ------ zru®en° stavovÇho registru linky

IntPri8: add       dx,3                     ; 5: stavovò registr linky
         in        al,dx                    ; zru®en° poëadavku od reg. linky
         jmp       IntPri1                  ; dal®° test

; ------ n†vrat registrñ

IntPri9: mov       al,20h
         out       [20h],al                 ; uvolnàn° ©adiáe p©eru®en°
         pop       es
         pop       ds
         pop       dx
         pop       bx
         pop       ax
         iret

IntPri   ENDP

; -----------------------------------------------------------------------------
;        odinstalov†n° portñ
; -----------------------------------------------------------------------------

DeInit   PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      dx

; ------ n†vrat masky p©eru®en°

         cli
         mov       al,ds:[OldInt]           ; pñvodn° maska p©eru®en°
         out       [21h],al                 ; n†vrat masky p©eru®en°

; ------ z†kaz p©eru®en° od portu

         mov       dx,ds:[AdrPort]          ; 0: adresa portu
         in        al,dx                    ; zru®en° p©ijatÇho znaku
         inc       dx                       ; 1: ©°dic° registr p©eru®en°
         xor       al,al                    ; v®echna p©eru®en° zak†z†na
         out       dx,al                    ; z†kaz v®ech p©eru®en°
         inc       dx                       ; 2: stavovò registr p©eru®en°
         in        al,dx                    ; zru®en° stavovÇho registru p©eru®.
         inc       dx                       ; 3: ©°dic° registr linky
         inc       dx                       ; 4: ©°dic° registr modemu
         xor       al,al                    ; v®echny sign†ly vypnuty
         out       dx,al                    ; vypnut° v®ech sign†lñ modemu
         inc       dx                       ; 5: stavovò registr linky
         in        al,dx                    ; zru®en° stavovÇho registru linky
         inc       dx                       ; 6: stavovò registr modemu
         in        al,dx                    ; zru®en° stavovÇho registru modemu

; ------ uvolnàn° ©adiáe p©eru®en°

         mov       al,20h
         out       [20h],al

; ------ n†vrat obsluhy p©eru®en° od portu COM

         call      GetICom                  ; poskytnut° p©eru®en° COM
         mov       ah,25h
         push      ds
         lds       dx,ds:[OldComm]          ; pñvodn° adresa INT COM
         int       21h                      ; n†vrat pñvodn° adresy portu
         pop       ds

; ------ n†vrat obsluhy p©eru®en° INT 08h

         push      ds
         lds       dx,ds:[Old08]            ; pñvodn° adresa INT 08h
         mov       ax,2508h
         int       21h
         pop       ds

; ------ n†vrat obsluhy p©eru®en° INT 09h

         push      ds
         lds       dx,ds:[Old09]            ; pñvodn° adresa INT 09h
         mov       ax,2509h
         int       21h
         pop       ds
         sti

; ------ inicializace hodin

         call      InitClk                  ; n†vrat nastaven° hodin

; ------ n†vrat registrñ

         pop       dx
         pop       ax
         ret

DeInit   ENDP

; -----------------------------------------------------------------------------
;        inicializace nastaven° hodin (AT)
; -----------------------------------------------------------------------------

InitClk  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      es

; ------ áten° hodin systÇmovÇho áasu (AT)

         mov       dl,8ah                   ; p©ednastaven° na nesmysl
         mov       ah,2
         int       1ah                      ; áten° hodin
         cmp       dl,1                     ; p©eteáen° p©es pñlnoc ?
         ja        InitClk8                 ; hodiny neplat°

; ------ n†vrat p©°znaku p©eteáen° p©es pñlnoc

         jne       InitClk2                 ; nen° p©eteáen° p©es pñlnoc
         xor       ax,ax
         mov       es,ax
         mov       byte ptr es:[470h],dl    ; n†vrat p©°znaku p©eteáen° pñlnoci

; ------ konverze z BCD form†tu na bin†rn°

InitClk2:mov       al,ch                    ; hodina
         call      BcdBin                   ; konverze na bin†rn° tvar
         mov       ch,al
         mov       al,cl                    ; minuta
         call      BcdBin                   ; konverze na bin†rn° tvar
         mov       cl,al
         mov       al,dh                    ; sekunda
         call      BcdBin                   ; konverze na bin†rn° tvar
         mov       dh,al

; ------ nastaven° áasu

         xor       dl,dl                    ; setina sekundy
         mov       ah,2dh
         int       21h                      ; nastaven° systÇmovÇho áasu

; ------ n†vrat registrñ

InitClk8:pop       es
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

InitClk  ENDP

; -----------------------------------------------------------------------------
;        Konverze á°sla z BCD tvaru na bin†rn°
; -----------------------------------------------------------------------------

BcdBin   PROC      NEAR

         push      cx
         mov       ch,al
         and       ch,0fh
         and       al,0f0h
         mov       cl,4
         shr       al,cl
         mov       cl,10
         mul       cl
         add       al,ch
         pop       cx
         ret

BcdBin   ENDP

; -----------------------------------------------------------------------------
;        obsluha hodin INT 08h
; -----------------------------------------------------------------------------

Int08    PROC      FAR

         push      ax
         mov       al,20h
         out       [20h],al
         sti
         inc       word ptr cs:[Citac08]    ; posun á°taáe hodin
         pop       ax
         iret

Int08    ENDP

; -----------------------------------------------------------------------------
;        obsluha kl†vesnice INT 09h
; -----------------------------------------------------------------------------

Int09    PROC      FAR

; ------ £schova registrñ

         push      ax

; ------ uvolnàn° ©adiáe p©eru®en°

         mov       al,20h
         out       [20h],al                 ; uvolnàn° ©adiáe p©eru®en°
         sti                                ; povolen° p©eru®en°

         push      cx

; ------ uzamáen° kl†vesnice

         call      Cekej09                  ; áek†n° na p©ipravenost kl†vesnice
         mov       al,0adh
         out       [64h],al                 ; vysl†n° povelu-uzamáen° kl†vesnice

; ------ áten° k¢du kl†vesy

         call      Cekej09                  ; áek†n° na p©ipravenost kl†vesnice
         in        al,[60h]

; ------ test, zda je p©eru®en° ESC

         cmp       al,1                     ; je stisk kl†vesy ESC ?
         jne       Int099                   ; nen° kl†vesa ESC
         mov       byte ptr cs:[KeyBreak],1 ; p©°znak p©eru®en° kl†vesou BREAK

; ------ uvolnàn° kl†vesnice

Int099:  call      Cekej09                  ; áek†n° na p©ipravenost kl†vesnice
         mov       al,0aeh
         out       [64h],al                 ; vysl†n° povelu-uvolnàn° kl†vesnice

; ------ n†vrat registrñ

         pop       cx
         pop       ax
         iret

Int09    ENDP

; -----------------------------------------------------------------------------
;        áek†n° na p©ipravenost kl†vesnice
; -----------------------------------------------------------------------------

Cekej09  PROC      NEAR

         mov       cx,5000
Cekej091:in        al,[64h]
         test      al,b1
         loopnz    Cekej091
         ret

Cekej09  ENDP

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                            Obsluha zobrazen°
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
; -----------------------------------------------------------------------------
;        zobrazen° celÇ obrazovky
; -----------------------------------------------------------------------------

DispAll  PROC      NEAR

         push      bx
         mov       bx,offset DatDefL        ; definice levÇho okna
         call      DispWin                  ; zobrazen° levÇho okna

         mov       bx,offset DatDefR        ; definice pravÇho okna
         call      DispWin                  ; zobrazen° pravÇho okna

         call      DispLHlp                 ; zobrazen° okna malÇ n†povàdy

         pop       bx
         ret

DispAll  ENDP

; -----------------------------------------------------------------------------
;        normalizace kurzoru okna BX
; -----------------------------------------------------------------------------

NormWin  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx

; ------ p©°prava registrñ

         mov       ax,cs:[bx+SeznDAkt]      ; aktivn° poloëka
         mov       cx,cs:[bx+SeznDTop]      ; poá†teán° poloëka
         mov       dx,cs:[bx+SeznDNum]      ; poáet poloëek

; ------ kontrola aktivn° poloëky

         or        dx,dx
         jz        NormWin2                 ; nen° ë†dn† poloëka
         cmp       ax,dx
         jb        NormWin2                 ; kurzor je OK
         mov       ax,dx
         dec       ax                       ; omezen° na posledn° poloëku
         mov       cs:[bx+SeznDAkt],ax      ; nov† aktivn° poloëka

; ------ kontrola podteáen° poá†tku

NormWin2:cmp       ax,cx                    ; je podteáen° pod poá†tek ?
         ja        NormWin3                 ; nen° podteáen° pod poá†tek
         mov       cx,ax                    ; omezen° poá†tku zdola
         jcxz      NormWin3                 ; je prvn° ©†dek
         dec       cx

; ------ vòpoáet maxim†ln°ho prvn°ho ©†dku

NormWin3:or        dx,dx                    ; je nàjakò ©†dek ?
         jz        NormWin5                 ; nen° ë†dnò ©†dek
         dec       dx                       ; maxim†ln° ©†dek
         cmp       ax,dx                    ; je maxim†ln° ©†dek ?
         mov       dx,SOUBDIS               ; poáet ©†dkñ na str†nku
         jae       NormWin4                 ; je posledn° ©†dek
         dec       dx                       ; je®tà jeden ©†dek rezerva
NormWin4:dec       dx                       ; poáet ©†dkñ - 1
         sub       ax,dx                    ; maxim†ln° prvn° ©†dek
         jae       NormWin6
NormWin5:xor       ax,ax                    ; omezen° max. prvn°ho ©†dku

; ------ kontrola p©eteáen° kurzoru za konec

NormWin6:cmp       ax,cx                    ; je p©eteáen° za konec ?
         jbe       NormWin7                 ; kurzor je OK
         mov       cx,ax                    ; omezen° prvn°ho ©†dku

; ------ uloëen° registrñ

NormWin7:mov       cs:[bx+SeznDTop],cx      ; nov† prvn° poloëka

; ------ n†vrat registrñ

         pop       dx
         pop       cx
         pop       ax
         ret

NormWin  ENDP

; -----------------------------------------------------------------------------
;        zobrazen° okna podle definice BX
; -----------------------------------------------------------------------------

DispWin  PROC      NEAR

         push      dx

         call      NormWin                  ; normalizace okna

; ------ pozice okna na obrazovce

         xor       dx,dx
         test      byte ptr cs:[bx+SeznPar],b1 ; je to pravÇ okno ?
         jz        DispWin1                 ; je to levÇ okno
         mov       dl,40                    ; pozice pravÇho okna

; ------ zobrazen° okna

DispWin1:call      DispTop                  ; zobrazen° horn° linky okna
         inc       dh
         call      DispCelk                 ; zobrazen° celkovÇ kapacity disku
         inc       dh
         call      DispAdr                  ; zobrazen° informace o adres†©i
         inc       dh
         call      DispPth                  ; zobrazen° aktivn°ho adres†©e
         inc       dh
         call      DispFile                 ; zobrazen° souborñ adres†©e
         call      DispLin                  ; zobrazen° st©edn° oddàlovac° á†ry
         inc       dh
         call      DispSel                  ; zobrazen° oznaáenòch souborñ
         inc       dh
         call      DispReq                  ; zobrazen° poëadovanÇ kapacity
         inc       dh
         call      DispEnd                  ; zobrazen° koncovÇho ©†dku okna

         pop       dx
         ret

DispWin  ENDP

; -----------------------------------------------------------------------------
;        zobrazen° horn° linky okna (pozice DX, definice BX)
; -----------------------------------------------------------------------------

DispTop  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es

; ------ p©°prava registrñ

         sub       sp,40
         push      cs
         pop       ds
         push      ss
         pop       es

; ------ inicializace linky

         cld
         mov       di,sp                    ; ukl†dac° adresa do z†sobn°ku
         mov       al,"…"                   ; levò horn° roh
         stosb
         mov       al,"Õ"
         mov       cx,38
         rep       stosb                    ; horn° linka
         mov       al,"ª"
         stosb                              ; pravò horn° roh

; ------ dÇlka textu n†zvu disku

         lea       si,[bx+SeznLab]          ; adresa textu n†và®t°
         mov       cx,cs:[bx+SeznLabN]      ; dÇlka n†và®t° disku
         jcxz      DispTop6                 ; nen° nic k zobrazen°
         cmp       cx,36                    ; maxim†ln° dÇlka n†và®t°
         jb        DispTop2                 ; dÇlka je OK
         mov       cx,36                    ; omezen° dÇlky n†và®t°
DispTop2:mov       ax,38                    ; dÇlka ©†dku - 2
         sub       ax,cx                    ; zbytek na okraje
         shr       ax,1                     ; zbytek na levò okraj
         add       ax,sp                    ; adresa poá†tku textu
         xchg      ax,di                    ; DI <- ukl†dac° adresa
         mov       al," "                   ; lev† mezera
         stosb                              ; uloëen° levÇ mezery
         rep       movsb                    ; p©enos n†và®t° do bufferu
         stosb                              ; uloëen° pravÇ mezery

; ------ zobrazen° linky

DispTop6:mov       si,sp                    ; buffer v z†sobn°ku
         mov       cl,40                    ; dÇlka textu
         mov       ah,cs:[Color1]           ; bàën† barva okna
         call      DispTxt                  ; zobrazen° textu

; ------ n†vrat registrñ

         add       sp,40
         pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

DispTop  ENDP

; -----------------------------------------------------------------------------
;        zobrazen° druhÇ linky okna (pozice DX, definice BX)
; -----------------------------------------------------------------------------

DispCelk PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es

; ------ p©°prava registrñ

         sub       sp,2*50
         push      cs
         pop       ds
         push      ss
         pop       es

; ------ dek¢dov†n° volnÇ kapacity disku

         mov       di,sp                    ; buffer v z†sobn°ku

         test      byte ptr ds:[bx+SeznPar],b0 ; je to disk ?
         jnz       DispCel2                 ; nen° to disk

         push      dx

         mov       ax,word ptr ds:[DiskFree] ; voln† kapacita disku LOW
         mov       dx,word ptr ds:[DiskFree+2] ; voln† kapacita disku HIGH
         mov       cl,0                     ; dÇlka pole
         mov       ch,ds:[Color2]           ; vysv°cen† barva textu
         call      DekNum                   ; dek¢dov†n° á°sla do z†sobn°ku

; ------ dek¢dov†n° textu "B volnÇ z"

         mov       ah,ds:[Color1]           ; bàën† barva
         mov       si,offset TextFre1       ; text "B volnÇ z"
         call      DekTxt                   ; dek¢dov†n° textu

; ------ dek¢dov†n° celkovÇ kapacity disku

         mov       ax,word ptr ds:[DiskSumm] ; celkov† kapacita LOW
         mov       dx,word ptr ds:[DiskSumm+2] ; celkov† kapacita HIGH
         call      DekNum                   ; dek¢dov†n° á°sla

         pop       dx

DispCel2:


; ------ dÇlka textu

DispCel5:mov       cx,di                    ; konec textu
         sub       cx,sp                    ; dÇlka textu * 2
         shr       cx,1                     ; dÇlka textu (poáet znakñ)
         cmp       cx,38
         jb        DispCel6
         mov       cx,38                    ; omezen° dÇlky textu

; ------ zobrazen° levÇho okraje

DispCel6:push      cx                       ; dÇlka textu k zobrazen°
         mov       ah,ds:[Color1]           ; bàën† barva textu
         mov       al,"∫"                   ; levò okraj
         call      Disp1Chr                 ; zobrazen° levÇho okraje
         sub       cx,38                    ; zbytek na okraje
         neg       cx
         shr       cx,1                     ; levò okraj
         mov       al," "
         call      DispChr                  ; zobrazen° levÇho okraje
         pop       cx

; ------ zobrazen° textu

         mov       si,sp                    ; buffer v z†sobn°ku
         call      DispStr                  ; zobrazen° textu

; ------ zobrazen° pravÇho okraje

         sub       cx,38                    ; zbytek na okraje
         neg       cx
         inc       cx                       ; zaokrouhlen° nahoru
         shr       cx,1                     ; pravò okraj
         call      DispChr                  ; zobrazen° pravÇho okraje
         mov       al,"∫"
         call      Disp1Chr                 ; zobrazen° pravÇho okraje

; ------ n†vrat registrñ

         add       sp,2*50
         pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

DispCelk ENDP

; -----------------------------------------------------------------------------
;        zobrazen° t©et° linky okna (pozice DX, definice BX)
; -----------------------------------------------------------------------------

DispAdr PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es

; ------ p©°prava registrñ

         sub       sp,2*50
         push      cs
         pop       ds
         push      ss
         pop       es

; ------ dek¢dov†n° poátu souborñ v adres†©i

         mov       di,sp                    ; buffer v z†sobn°ku

         test      byte ptr ds:[bx+SeznPar],b0 ; je to disk ?
         jnz       DispAdr2                 ; nen° to disk

         push      dx

         mov       ax,ds:[bx+SeznFFil]      ; poáet souborñ v adres†©i
         xor       dx,dx
         mov       cl,0                     ; dÇlka pole
         mov       ch,ds:[Color2]           ; vysv°cen† barva textu
         call      DekNum                   ; dek¢dov†n° á°sla do z†sobn°ku

; ------ dek¢dov†n° textu " souboru zabira "

         mov       ah,ds:[Color1]           ; bàën† barva
         mov       si,offset TextFil1       ; text " souboru zabira "
         call      DekTxt                   ; dek¢dov†n° textu

; ------ dek¢dov†n° kapacity disku zabranÇ soubory

         mov       ax,ds:[bx+SeznFSum]      ; zabran† kapacita LOW
         mov       dx,ds:[bx+SeznFSum+2]    ; zabran† kapacita HIGH
         call      DekNum                   ; dek¢dov†n° á°sla

; ------ dek¢dov†n° textu " B"

         mov       ah,ds:[Color1]           ; bàën† barva textu
         mov       si,offset TextFil2       ; text " B"
         call      DekTxt                   ; dek¢dov†n° textu

         pop       dx

DispAdr2:
         jmp       DispCel5                 ; zobrazen° textu

DispAdr  ENDP

; -----------------------------------------------------------------------------
;        zobrazen° st©edn° linky okna (pozice DX, definice BX)
; -----------------------------------------------------------------------------

DispPth  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es

; ------ p©°prava registrñ

         sub       sp,2*50                  ; buffer v z†sobn°ku
         push      cs
         pop       ds
         push      ss
         pop       es

; ------ inicializace linky

         cld
         mov       di,sp                    ; ukl†dac° adresa do z†sobn°ku
         mov       ah,ds:[Color1]           ; bàën† barva textu
         mov       al,"Ã"                   ; levò okraj
         stosw
         mov       al,"Õ"
         mov       cx,38
         rep       stosw                    ; st©edn° linka
         mov       al,"π"
         stosw                              ; pravò okraj

; ------ barva textu cesty

         test      byte ptr ds:[bx+SeznPar],b2 ; je okno aktivn° ?
         jz        DispPth1                 ; okno nen° aktivn°
         mov       ah,ds:[Color3]           ; barva kurzoru

; ------ dÇlka textu adres†©e

DispPth1:mov       di,sp                    ; zaá†tek bufferu v z†sobn°ku
         inc       di
         inc       di                       ; poá†teán° adresa k dek¢dov†n°
         lea       si,[bx+SeznDir]          ; adresa textu adres†©e
         mov       cx,ds:[bx+SeznDirN]      ; dÇlka textu adres†©e
         cmp       cx,36                    ; maxim†ln° dÇlka cesty
         jbe       DispPth2                 ; dÇlka je OK

; ------ dek¢dov†n° poá†tku

         mov       al," "
         stosw                              ; £vodn° mezera
         lodsb
         stosw

; ------ pokud nebyl ROOT, dek¢dov†n° disku

         cmp       al,"\"
         je        DispPt11                 ; disk se nezobraz°
         lodsb
         stosw                              ; znak ":"
         lodsb
         stosw                              ; znak "\"
         add       si,cx                    ; konec textu cesty
         sub       si,3
         mov       cx,36-6                  ; omezen† dÇlka textu s diskem
         jmp       short DispPt12

; ------ omezen° dÇlky textu

DispPt11:add       si,cx                    ; konec textu cesty
         dec       si
         mov       cx,36-4                  ; omezen† dÇlka textu bez disku
DispPt12:sub       si,cx                    ; zaá†tek textu
         mov       al,"."
         stosw
         stosw
         stosw                              ; £vodn° teáky
         jmp       short DispPth3           ; dek¢dov†n° textu cesty

; ------ vyst©edàn° textu

DispPth2:mov       di,38                    ; dÇlka ©†dku - 2
         sub       di,cx                    ; zbytek na okraje
         and       di,not 1                 ; zarovn†n° na slovo
         add       di,sp                    ; adresa poá†tku textu
         mov       al," "                   ; lev† mezera
         stosw                              ; uloëen° levÇ mezery

; ------ dek¢dov†n° textu

DispPth3:lodsb
         stosw
         loop      DispPth3

; ------ z†vàreán† mezera

         mov       al," "
         stosw

; ------ zobrazen° linky

         mov       si,sp                    ; buffer v z†sobn°ku
         mov       cl,40                    ; dÇlka textu
         call      DispStr                  ; zobrazen° textu

; ------ n†vrat registrñ

         add       sp,2*50
         pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

DispPth  ENDP

; -----------------------------------------------------------------------------
;        zobrazen° souborñ v adres†©ovÇm oknà (pozice DX, seznam BX)
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) á°taá aktivn° poloëky
;                   SS:[BP-4] (2) ukazatel á°sla poloëky
; -----------------------------------------------------------------------------

DispFile PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      si
         push      di
         push      bp
         push      ds
         push      es
         mov       bp,sp

; ------ p©°prava bufferu v z†sobn°ku

         sub       sp,2*40 + 4              ; vytvo©en° bufferu v z†sobn°ku

; ------ p©°prava lok†ln°ch promànnòch

         mov       ax,cs:[bx+SeznDAkt]      ; poloëka s kurzorem
         sub       ax,cs:[bx+SeznDTop]      ; offset od prvn° poloëky
         inc       ax                       ; p©ednastaven° á°taáe kurzoru
         mov       ss:[bp-2],ax             ; á°taá aktivn° poloëky (kurzoru)
         mov       ax,cs:[bx+SeznDTop]      ; prvn° zobrazen† poloëka
         mov       ss:[bp-4],ax             ; ukazatel á°sla poloëky
         push      ss
         pop       es                       ; ES <- segmentu bufferu v z†sobn°ku
         mov       ds,cs:[bx+SeznDSeg]      ; segment zaá†tku adres†©e

; ------ inicializaán° dek¢dov†n° okrajñ ©†dku

DispFil1:cld
         mov       di,sp                    ; buffer v z†sobn°ku
         mov       ah,cs:[Color1]           ; bàën† barva textu
         mov       al,"∫"                   ; znak okraje
         stosw                              ; uloëen° levÇho okraje
         mov       es:[di+2*38],ax          ; uloëen° pravÇho okraje

; ------ dek¢dov†n° kurzoru

         mov       al,cs:[Color2]           ; vysv°cen† poloëka
         dec       word ptr ss:[bp-2]       ; sn°ëen° á°taáe aktivn° poloëky
         jnz       DispFil2                 ; nen° to ©†dek s kurzorem
         mov       byte ptr es:[di-2],"∞"   ; znak kurzoru
         mov       byte ptr es:[di+2*38],"∞"; znak kurzoru
         test      byte ptr cs:[bx+SeznPar],b2 ; je okno aktivn° ?
         jz        DispFil2                 ; nen° to aktivn° okno
         mov       si,ss:[bp-4]             ; ukazatel á°sla poloëky
         cmp       si,cs:[bx+SeznDNum]      ; je platnÇ á°slo poloëky ?
         jae       DispFil2                 ; nen° platnÇ á°slo poloëky
         mov       ah,cs:[Color3]           ; barva kurzoru
         mov       al,cs:[Color4]           ; vysv°cenò kurzor

; ------ rozli®en° vysv°cenÇ poloëky

DispFil2:mov       si,ss:[bp-4]             ; ukazatel á°sla poloëky
         cmp       si,cs:[bx+SeznDNum]      ; je platnÇ á°slo poloëky ?
         jae       DispFil3                 ; nen° platnÇ á°slo poloëky
         shl       si,1
         mov       si,cs:[si+bx+SeznInd]    ; offset poloëky
         cmp       si,-1                    ; je to ".." ?
         je        DispFil3                 ; je to ".."
         test      byte ptr ds:[si+FileAtr],b7 ; je to oznaáen† poloëka ?
         jz        DispFil3                 ; nen° oznaáen† poloëka
         mov       ah,al                    ; barva oznaáenÇ poloëky
DispFil3:push      ss
         pop       es                       ; ES <- segment bufferu v z†sobn°ku

; ------ p©°prava neplatnÇ poloëky

         push      di
         mov       al," "
         mov       cx,12
         rep       stosw
         mov       al,"≥"
         stosw
         mov       al," "
         mov       cl,10
         rep       stosw
         mov       al,"≥"
         stosw
         mov       al," "
         mov       cl,8
         rep       stosw
         mov       al,"≥"
         stosw
         mov       al," "
         mov       cl,5
         rep       stosw
         pop       di

; ------ adresa poloëky

DispFil4:mov       si,ss:[bp-4]             ; á°slo poloëky
         cmp       si,cs:[bx+SeznDNum]      ; je to platn† poloëka ?
         jae       DispFil7                 ; nen° to platn† poloëka
         shl       si,1
         mov       si,cs:[bx+si+SeznInd]    ; offset poloëky
         cmp       si,-1                    ; je to ".." ?
         jne       DispFl42

; ------ dek¢dov†n° poloëky ".."

         mov       al,"."
         stosw
         stosw
         add       di,11*2
         mov       si,offset DskTxtD        ; text "<NAD--ADR>"
         push      ds
         push      cs
         pop       ds
         call      DekTxt                   ; dek¢dov†n° textu
         pop       ds
         jmp       short DispFil7

; ------ dek¢dov†n° souboru

DispFl42:call      DekAFil                  ; dek¢dov†n° jmÇna souboru
         mov       al,"≥"
         test      byte ptr ds:[si+FileAtr],b7 ; je to oznaáen† poloëka ?
         jz        DispFil5                 ; nen° to oznaáen† poloëka
         mov       al,"≤"                   ; indik†tor oznaáenÇ poloëky
DispFil5:stosw
         call      DekASiz                  ; dek¢dov†n° velikosti souboru
         mov       al,"≥"
         stosw
         call      DekADat                  ; dek¢dov†n° data souboru
         mov       al,"≥"
         stosw
         call      DekATim                  ; dek¢dov†n° áasu souboru

; ------ zobrazen° jednoho ©†dku

DispFil7:inc       word ptr ss:[bp-4]       ; zvò®en° ukazatele poloëky
         mov       si,sp                    ; buffer v z†sobn°ku
         mov       cl,40                    ; dÇlka textu ©†dku
         push      dx
         call      DispStr                  ; zobrazen° jednoho ©†dku
         pop       dx

; ------ p©°prava k zobrazen° dal®°ho ©†dku

         inc       dh                       ; zvò®en° ukazatele ©†dku
         cmp       dh,SOUBDIS+4
         jae       DispFil9
         jmp       DispFil1                 ; zobrazen° dal®°ho ©†dku

; ------ n†vrat registrñ

DispFil9:mov       sp,bp
         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       cx
         pop       ax
         ret

DispFile ENDP

; -----------------------------------------------------------------------------
;        dek¢dov†n° jmÇna souboru DS:SI do bufferu ES:DI, barva AH
; -----------------------------------------------------------------------------

DekAFil  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si

; ------ p©°prava k dek¢dov†n° jmÇna souboru

         cld
         mov       bl,ds:[si+FileAtr]       ; atributy souboru
         mov       bh,bl                    ; atributy souboru
         mov       ch,0
         mov       cl,ds:[si+FileOffs]      ; offset dal®° poloëky
         sub       cl,FileName              ; dÇlka jmÇna souboru
         add       si,FileName              ; jmÇno souboru

; ------ dek¢dov†n° jmÇna ".."

         mov       dx,8                     ; dÇlka jmÇna souboru
         cmp       cl,2
         jne       DekAFil1
         cmp       word ptr ds:[si],".."
         jne       DekAFil1
         mov       al,"."
         stosw
         stosw                              ; uloëen° textu ".."
         xor       cx,cx
         dec       dx
         dec       dx

; ------ dek¢dov†n° jmÇna souboru

DekAFil1:mov       al," "                   ; n†hradn° znak mezery
         jcxz      DekAFil2                 ; konec jmÇna
         cmp       byte ptr ds:[si],"."     ; je p©°pona ?
         je        DekAFil2                 ; bude p©°pona
         lodsb                              ; naáten° znaku jmÇna souboru
         dec       cx                       ; sn°ëen° á°taáe znakñ
         test      bl,DIR + HID + SYS       ; bude velkÇ p°smeno ?
         jnz       DekAFil2                 ; bude velkÇ p°smeno
         cmp       al,"A"
         jb        DekAFil2                 ; nen° velkÇ p°smeno
         cmp       al,"Z"
         ja        DekAFil2                 ; nen° velkÇ p°smeno
         add       al,32                    ; korekce na malÇ p°smeno
DekAFil2:stosw                              ; uloëen° znaku jmÇna souboru
         and       bl,not HID + SYS         ; zru®en° atributñ HID a SYS
         dec       dx                       ; á°taá znakñ k uloëen°
         jnz       DekAFil1                 ; dek¢dov†n° dal®°ho znaku

; ------ oddàlovac° znak mezi jmÇnem a p©°ponou

         mov       al,"∞"                   ; oznaáen° souborñ HID a SYS
         test      bh,HID + SYS             ; je soubor HID nebo SYS ?
         jnz       DekAFil3                 ; soubor je HID nebo SYS
         mov       al,"*"                   ; oznaáen° souborñ R/O
         test      bh,RO                    ; je soubor R/O ?
         jnz       DekAFil3                 ; soubor je R/O
         mov       al," "                   ; jinak mezera pro bàënò soubor
DekAFil3:stosw

; ------ zru®en° oddàlovac° teáky p©ed p©°ponou

         mov       dx,3                     ; dÇlka p©°pony jmÇna souboru
         jcxz      DekAFil4                 ; nen° dal®° znak
         cmp       byte ptr ds:[si],"."
         jne       DekAFil4
         inc       si
         dec       cx

; ------ dek¢dov†n° p©°pony jmÇna souboru

DekAFil4:mov       al," "                   ; n†hradn° znak mezery
         jcxz      DekAFil5                 ; nen° dal®° znak
         lodsb                              ; naáten° znaku p©°pony jmÇna soub.
         dec       cx                       ; sn°ëen° á°taáe znakñ
         test      bl,DIR                   ; bude velkÇ p°smeno ?
         jnz       DekAFil5                 ; bude velkÇ p°smeno
         cmp       al,"A"
         jb        DekAFil5                 ; nen° velkÇ p°smeno
         cmp       al,"Z"
         ja        DekAFil5                 ; nen° velkÇ p°smeno
         add       al,32                    ; korekce na malÇ p°smeno
DekAFil5:stosw                              ; uloëen° znaku p©°pony jmÇna soub.
         dec       dx                       ; á°taá znakñ k uloëen°
         jnz       DekAFil4                 ; dek¢dov†n° dal®°ho znaku

; ------ n†vrat registrñ

         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DekAFil  ENDP

; -----------------------------------------------------------------------------
;        dek¢dov†n° velikosti souboru DS:SI do bufferu ES:DI, barva AH
; -----------------------------------------------------------------------------

DekASiz  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      dx
         push      si

; ------ test, zda je to adres†©

         test      byte ptr ds:[si+FileAtr],DIR ; je to adres†© ?
         jz        DekASiz3                 ; nen° to adres†© - je to soubor

; ------ dek¢dov†n° identifikaán°ho textu adres†©e

;         cmp       word ptr ds:[si+FileName],".." ; je to nadadres†© ?
;         mov       si,offset DskTxtD        ; text "<NAD--ADR>"
;         je        DekASiz2                 ; je to nadadres†©
         mov       si,offset DskTxtC        ; text "<POD--ADR>"
DekASiz2:push      ds
         push      cs
         pop       ds
         call      DekTxt                   ; dek¢dov†n° textu
         pop       ds
         jmp       short DekASiz9

; ------ dek¢dov†n° velikosti souboru (á°slo)

DekASiz3:mov       ch,ah                    ; barva textu
         mov       cl,10                    ; ®°©ka pole (pozic)
         mov       ax,ds:[si+FileSize]      ; velikost souboru LOW
         mov       dx,ds:[si+FileSize+2]    ; velikost souboru HIGH
         call      Dek10Num                 ; dek¢dov†n° velikosti s omezen°m

; ------ n†vrat registrñ

DekASiz9:pop       si
         pop       dx
         pop       bx
         pop       ax
         ret

DekASiz  ENDP

; -----------------------------------------------------------------------------
;        dek¢dov†n° data souboru DS:SI do bufferu ES:DI, barva AH
; -----------------------------------------------------------------------------

DekADat  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx

; ------ dek¢dov†n° dne

         cld
         mov       al,ds:[si+FileDate]      ; datum LOW
         and       al,31                    ; den
         mov       ch," "                   ; dopl§uj°c° znak
         call      DekADT                   ; dek¢dov†n° dvojá°sl°
         mov       al,"."
         stosw                              ; oddàlovac° znak data

; ------ dek¢dov†n° màs°ce

         mov       dx,ds:[si+FileDate]      ; datum souboru
         mov       cl,5                     ; poáet rotac°
         shr       dx,cl                    ; rotace màs°ce
         mov       al,dl                    ; màs°c
         and       al,15                    ; màs°c
         call      DekADT                   ; dek¢dov†n° dvojá°sl°
         mov       al,"."
         stosw                              ; oddàlovac° znak data

; ------ dek¢dov†n° roku

         mov       al,ds:[si+FileDate+1]    ; datum souboru HIGH
         shr       al,1                     ; rok
         add       al,80                    ; p©iáten° z†kladu bez stolet°
         cmp       al,100                   ; je posledn° dvojá°sl° ?
         jb        DekADat2                 ; á°slo je OK
         sub       al,100                   ; odeáten° stolet°
         cmp       al,100                   ; je jië posledn° dvojá°sl° ?
         jb        DekADat2                 ; á°slo je OK
         sub       al,100                   ; odeáten° stolet°
DekADat2:call      DekADT                   ; dek¢dov†n° dvojá°sl° roku

; ------ n†vrat registrñ

         pop       dx
         pop       cx
         pop       ax
         ret

DekADat  ENDP

; -----------------------------------------------------------------------------
;        dek¢dov†n° áasu souboru DS:SI do bufferu ES:DI, barva AH
; -----------------------------------------------------------------------------

DekATim  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx

; ------ dek¢dov†n° hodiny

         cld
         mov       ch," "                   ; n†hradn° znak
         mov       al,ds:[si+FileTime+1]    ; áas souboru
         mov       cl,11-8                  ; poáet rotac°
         shr       al,cl                    ; hodina
         call      DekADT                   ; dek¢dov†n° £daje hodiny

; ------ oddàlovac° znak áasu

         mov       al,":"                   ; oddàlovac° znak áasu
         stosw                              ; uloëen° oddàlovac°ho znaku áasu

; ------ dek¢dov†n° minuty

         mov       dx,ds:[si+FileTime]      ; áas souboru
         mov       cl,5                     ; poáet rotac°
         shr       dx,cl                    ; minuta
         mov       al,dl                    ; minuta
         and       al,3fh                   ; minuta
         call      DekADT                   ; dek¢dov†n° £daje minut

; ------ n†vrat registrñ

         pop       dx
         pop       cx
         pop       ax
         ret

DekATim  ENDP

; -----------------------------------------------------------------------------
;        dek¢dov†n° dvojá°sl° s doplnàn°m znaku
; -----------------------------------------------------------------------------
; VSTUP: AL=á°slo
;        AH=barva textu
;        CH=znak k doplnàn° (nam°sto prvn° "0")
;        ES:DI=ukl†dac° adresa (mus° bòt smàr CLD)
; VùSTUP:ES:DI=nov† ukl†dac° adresa
;        CH=znak k doplnàn° "0"
; -----------------------------------------------------------------------------
; niá° registry AL a DX
; -----------------------------------------------------------------------------

DekADT   PROC      NEAR

         push      ax
         aam                                ; rozdàlen° AL na 2 á°slice
         add       ax,"00"                  ; korekce na á°slice ASCII
         xchg      ax,dx                    ; £schova á°sla do DX
         pop       ax
         mov       al,dh                    ; vy®®° á°slice
         cmp       al,"0"                   ; je prvn° znak 0 ?
         jne       DekADT1                  ; nen° 0
         mov       al,ch                    ; n†hradn° prvn° znak
DekADT1: stosw                              ; uloëen° prvn° á°slice
         mov       al,dl                    ; druh† á°slice
         stosw                              ; uloëen° druhÇ á°slice
         mov       ch,"0"                   ; dopl§uj°c° znak "0"
         ret

DekADT   ENDP

; -----------------------------------------------------------------------------
;        zobrazen° horn° linky okna (pozice DX, definice BX)
; -----------------------------------------------------------------------------

DispLin  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es

; ------ p©°prava registrñ

         sub       sp,2*40
         push      cs
         pop       ds
         push      ss
         pop       es

; ------ inicializace linky

         cld
         mov       di,sp                    ; ukl†dac° adresa do z†sobn°ku
         mov       ah,ds:[Color1]
         mov       al,"Ã"                   ; levò horn° roh
         stosw
         mov       al,"Õ"
         mov       cx,38
         rep       stosw                    ; horn° linka
         mov       al,"π"
         stosw                              ; pravò horn° roh

; ------ zobrazen° linky

DispLin6:mov       si,sp                    ; buffer v z†sobn°ku
         mov       cl,40                    ; dÇlka textu
         call      DispStr                  ; zobrazen° textu

; ------ n†vrat registrñ

         add       sp,2*40
         pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

DispLin  ENDP

; -----------------------------------------------------------------------------
;        zobrazen° oznaáenòch souborñ (pozice DX, definice BX)
; -----------------------------------------------------------------------------

DispSel  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es

; ------ p©°prava registrñ

         sub       sp,2*50
         push      cs
         pop       ds
         push      ss
         pop       es

; ------ dek¢dov†n° textu "oznaceno "

         mov       di,sp                    ; buffer v z†sobn°ku

         push      dx
         mov       ah,ds:[Color1]           ; bàën† barva
         mov       si,offset TextSel1       ; text "oznaáeno "
         call      DekTxt                   ; dek¢dov†n° textu

; ------ dek¢dov†n° poátu oznaáenòch souborñ

         mov       ax,ds:[bx+SeznSelN]      ; poáet oznaáenòch souborñ
         xor       dx,dx
         mov       cl,0                     ; dÇlka pole
         mov       ch,ds:[Color2]           ; vysv°cen† barva
         call      DekNum                   ; dek¢dov†n° á°sla

; ------ dek¢dov†n° textu " souboru / "

         mov       ah,ds:[Color1]           ; bàën† barva
         mov       si,offset TextSel2       ; text " souboru / "
         call      DekTxt                   ; dek¢dov†n° textu

; ------ dek¢dov†n° souátu oznaáenòch souborñ

         mov       ax,ds:[bx+SeznSelS]      ; oznaáen† kapacita LOW
         mov       dx,ds:[bx+SeznSelS+2]    ; oznaáen† kapacita HIGH
         call      DekNum                   ; dek¢dov†n° á°sla

; ------ dek¢dov†n° textu " B"

         mov       ah,ds:[Color1]           ; bàën† barva textu
         mov       si,offset TextFil2       ; text " B"
         call      DekTxt                   ; dek¢dov†n° textu

         pop       dx

         jmp       DispCel5                 ; zobrazen° textu

DispSel  ENDP

; -----------------------------------------------------------------------------
;        zobrazen° poëadovanÇ kapacity (pozice DX, definice BX)
; -----------------------------------------------------------------------------

DispReq  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es

; ------ p©°prava registrñ

         sub       sp,2*50
         push      cs
         pop       ds
         push      ss
         pop       es

         mov       di,sp                    ; buffer v z†sobn°ku
         push      dx

; ------ rozli®en°, zda je streamer

         test      byte ptr ds:[bx+SeznPar],b0 ; je to streamer ?
         jz        DispReq2                 ; nen° streamer, je to disk

; ------ dek¢dov†n° textu "poëadovan† kapacita "

         mov       ah,ds:[Color1]           ; bàën† barva
         mov       si,offset TextReq1       ; text "poëadovan† kapacita "
         call      DekTxt                   ; dek¢dov†n° textu

; ------ dek¢dov†n° poëadovanÇ kapacity

         mov       ax,ds:[bx+SeznSelR]      ; poëadovan† kapacita LOW
         mov       dx,ds:[bx+SeznSelR+2]    ; poëadovan† kapacita HIGH
         mov       ch,ds:[Color2]           ; vysv°cen† barva
         mov       cl,0                     ; dÇlka pole
         call      DekNum                   ; dek¢dov†n° á°sla

; ------ dek¢dov†n° textu " B"

         mov       ah,ds:[Color1]           ; bàën† barva textu
         mov       si,offset TextFil2       ; text " B"
         call      DekTxt                   ; dek¢dov†n° textu

DispReq1:pop       dx

         jmp       DispCel5                 ; zobrazen° textu

; ------ dek¢dov†n° textu "dÇlka z†znamu "

DispReq2:mov       ah,ds:[Color1]           ; bàën† barva
         mov       si,offset TextReq2       ; text "dÇlka z†znamu "
         call      DekTxt                   ; dek¢dov†n° textu

; ------ vòpoáet poëadovanÇho áasu

         mov       ax,ds:[bx+SeznSelR]      ; poëadovanò áas
         xor       dx,dx
         mov       cx,30                    ; poáet sekund / 2
         div       cx                       ; vòpoáet poátu sekund/2
         shl       dx,1                     ; p©epoáet na sekundy
         mov       cl,60
         div       cl                       ; vòpoáet poátu hodin a minut
                                            ; AL=hodiny, AH=minuty, DL=sekundy

; ------ dek¢dov†n° poátu hodin

         mov       ch,ds:[Color2]           ; zvòraznàn† barva
         mov       cl,0                     ; odsazen°
         or        al,al                    ; jsou hodiny ?
         jz        DispReq3                 ; nejsou hodiny

         push      ax
         push      dx
         mov       ah,0
         xor       dx,dx                    ; DX <- 0
         call      DekNum                   ; dek¢dov†n° poátu hodin
         mov       ah,ds:[Color1]           ; bàën† barva
         mov       si,offset TextReq3       ; text " hod, "
         call      DekTxt                   ; dek¢dov†n° textu
         pop       dx
         pop       ax

; ------ dek¢dov†n° poátu minut

DispReq3:push      dx
         xor       dx,dx                    ; DX <- 0
         mov       al,ah                    ; poáet minut
         mov       ah,0
         call      DekNum                   ; dek¢dov†n° poátu minut
         mov       ah,ds:[Color1]           ; bàën† barva
         mov       si,offset TextReq4       ; text " min, "
         call      DekTxt                   ; dek¢dov†n° textu
         pop       dx

; ------ dek¢dov†n° poátu sekund

         mov       ax,dx                    ; AX <- poáet sekund
         xor       dx,dx                    ; DX <- 0
         call      DekNum                   ; dek¢dov†n° poátu sekund
         mov       ah,ds:[Color1]           ; bàën† barva
         mov       si,offset TextReq5       ; text " sek"
         call      DekTxt                   ; dek¢dov†n° tetu
         jmp       short DispReq1

DispReq  ENDP

; -----------------------------------------------------------------------------
;        zobrazen° koncovÇ linky okna (pozice DX, definice BX)
; -----------------------------------------------------------------------------

DispEnd  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es

; ------ p©°prava registrñ

         sub       sp,2*40
         push      cs
         pop       ds
         push      ss
         pop       es

; ------ inicializace linky

         cld
         mov       di,sp                    ; ukl†dac° adresa do z†sobn°ku
         mov       ah,ds:[Color1]
         mov       al,"»"                   ; levò doln° roh
         stosw
         mov       al,"Õ"
         mov       cx,38
         rep       stosw                    ; doln° linka
         mov       al,"º"
         stosw                              ; pravò doln° roh

; ------ zobrazen° linky

DispEnd6:mov       si,sp                    ; buffer v z†sobn°ku
         mov       cl,40                    ; dÇlka textu
         call      DispStr                  ; zobrazen° textu

; ------ n†vrat registrñ

         add       sp,2*40
         pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

DispEnd  ENDP

; -----------------------------------------------------------------------------
;        zobrazen° okna malÇ n†povàdy
; -----------------------------------------------------------------------------

DispLHlp PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es

; ------ p©°prava registrñ

         sub       sp,2*80
         push      ss
         pop       es
         push      cs
         pop       ds

; ------ zobrazen° horn° linky

         mov       dx,20*HI
         mov       ah,ds:[ColorH1]          ; bàën† barva n†povàdy
         mov       al,"⁄"
         call      Disp1Chr                 ; levò horn° roh
         mov       al,"ƒ"
         mov       cl,78
         call      DispChr                  ; horn° linka
         mov       al,"ø"
         call      Disp1Chr

; ------ p©°prava k zobrazen° vnit©n°ch ©†dkñ

         mov       dh,21                    ; poá†teán° ©†dek
         mov       si,ds:[AdrHlp]           ; adresa textu n†povàdy

; ------ vymaz†n° ©†dku v bufferu

DispLHl2:mov       ah,ds:[ColorH1]          ; bàën† barva n†povàdy
         mov       dl,ds:[ColorH2]          ; vysv°cen† barva n†povàdy
         mov       di,sp                    ; buffer v z†sobn°ku
         cld
         mov       al,"≥"                   ; levò okraj
         stosw                              ; uloëen° levÇho okraje
         mov       al," "                   ; vnit©n° mezera
         mov       cx,78
         rep       stosw                    ; uloëen° vnit©n° mezery
         mov       al,"≥"                   ; pravò okraj
         stosw                              ; uloëen° pravÇho okraje

; ------ dÇlka ©†dku textu

         cld
         lodsb                              ; bajt dÇlky
         mov       cl,al                    ; dÇlka textu
         mov       ch,0
         jcxz      DispLHl6                 ; je pr†zdnò ©†dek

; ------ uráen° ukl†dac° adresy textu

         mov       di,cx                    ; dÇlka textu
         sub       di,80
         neg       di
         and       di,not 1
         add       di,sp                    ; ukl†dac° adresa

; ------ dek¢dov†n° textu ©†dku

DispLHl3:lodsb                              ; bajt textu
         cmp       al,0                     ; je p©ep°naá barvy ?
         jne       DispLHl4                 ; nen° p©ep°naá barvy
         xchg      ah,dl                    ; zmàna barvy
         jmp       short DispLHl3           ; dal®° znak
DispLHl4:stosw                              ; uloëen° znaku do bufferu
         loop      DispLHl3                 ; dal®° znak

; ------ zobrazen° textu ©†dku

DispLHl6:push      si
         mov       si,sp                    ; buffer ©†dku
         inc       si
         inc       si                       ; p©eskoáen° slova v z†sobn°ku
         mov       cl,80                    ; dÇlka ©†dku
         mov       dl,0                     ; poá†teán° pozice
         call      DispStr                  ; zobrazen° textu ©†dku
         pop       si

; ------ p©°prava k zobrazen° dal®°ho ©†dku

         inc       dh                       ; zvò®en° ukazatele ©†dku
         cmp       dh,24
         jne       DispLHl2                 ; dal®° ©†dek

; ------ zobrazen° doln° linky

         mov       dl,0
         mov       ah,ds:[ColorH1]          ; bàën† barva n†povàdy
         mov       al,"¿"
         call      Disp1Chr                 ; levò doln° roh
         mov       al,"ƒ"
         mov       cl,2
         call      DispChr                  ; levò okraj
         mov       si,offset LicTxt1
         mov       cl,22
         call      DispTxt
         mov       cl,30
         call      DispChr
         mov       si,offset LicTxt2
         mov       cl,22
         call      DispTxt
         mov       cl,2
         call      DispChr
         mov       al,"Ÿ"
         call      Disp1Chr

; ------ n†vrat registrñ

         add       sp,2*80
         pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispLHlp ENDP

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                                Obsluha seznamñ
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
; -----------------------------------------------------------------------------
;        inicializace seznamu BX
; -----------------------------------------------------------------------------

InitSezn PROC      NEAR

         push      ax
         push      cx
         push      si
         push      di
         push      es

         push      ds
         pop       es

         mov       ax,ds:[DatFre]           ; zaá†tek volnÇho m°sta
         mov       ds:[bx+SeznSeg],ax       ; adresa seznamu souborñ
         mov       ds:[bx+SeznDSeg],ax      ; adresa zaá†tku adres†©e
         mov       ds:[bx+SeznEnd],ax       ; adresa konce seznamu

         xor       ax,ax
         mov       ds:[bx+SeznNum],ax       ; poáet poloëek v seznamu
         mov       ds:[bx+SeznDNum],ax      ; poáet poloëek adres†©e
         mov       ds:[bx+SeznDAkt],ax      ; aktivn° poloëka adres†©e
         mov       ds:[bx+SeznDTop],ax      ; poá†teán° poloëka adres†©e

         mov       ds:[bx+SeznFFil],ax      ; poáet souborñ v adres†©i
         mov       ds:[bx+SeznFSum],ax      ; zabran† kapacita LOW
         mov       ds:[bx+SeznFSum+2],ax    ; zabran† kapacita HIGH

         mov       ds:[bx+SeznSelN],ax      ; poáet oznaáenòch souborñ
         mov       ds:[bx+SeznSelS],ax      ; oznaáen† kapacita LOW
         mov       ds:[bx+SeznSelS+2],ax    ; oznaáen† kapacita HIGH
         mov       ds:[bx+SeznSelR],ax      ; poëadovan† kapacita LOW
         mov       ds:[bx+SeznSelR+2],ax    ; poëadovan† kapacita HIGH

         mov       word ptr ds:[bx+SeznDirN],1 ; dÇlka textu adres†©e
         mov       byte ptr ds:[bx+SeznDir],"\" ; oznaáen° adres†©e ROOT

         test      byte ptr ds:[bx+SeznPar],b0 ; je to disk ?
         jz        InitSzn2                 ; je to streamer

         mov       si,offset TextStr
         mov       cx,8
         mov       ds:[bx+SeznLabN],cx      ; dÇlka n†và®t°
         cld
         lea       di,[bx+SeznLab]
         rep       movsb

InitSzn2:;mov       byte ptr ds:[bx+SeznPar2],b0 ; t©°dàn° podle jmÇna

         pop       es
         pop       di
         pop       si
         pop       cx
         pop       ax
         ret

InitSezn ENDP

; -----------------------------------------------------------------------------
;        vòbàr souborñ z adres†©e ES:SI seznamu BX
; -----------------------------------------------------------------------------

SelFile  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es

; ------ inicializace ukazatelñ

         xor       ax,ax
         mov       ds:[bx+SeznFFil],ax      ; poáet souborñ v adres†©i
         mov       ds:[bx+SeznFSum],ax      ; zabran† kapacita LOW
         mov       ds:[bx+SeznFSum+2],ax    ; zabran† kapacita HIGH
         mov       ds:[bx+SeznDNum],ax      ; poáet poloëek adres†©e
         mov       ds:[bx+SeznDAkt],ax      ; aktivn° poloëka
         mov       ds:[bx+SeznDTop],ax      ; prvn° zobrazen† poloëka
         mov       ds:[bx+SeznDSeg],es      ; segment adres†©e

; ------ p©°prava registrñ

         push      es
         pop       ds                       ; DS <- segment adres†©e
         push      cs
         pop       es                       ; ES <- CS
         lea       di,[bx+SeznInd]          ; indexov† tabulka souborñ
         mov       bp,bx                    ; ukazatel parametrñ
         mov       cx,word ptr cs:[BlokByte] ; poáet bajtñ na blok LOW
         mov       bx,word ptr cs:[BlokByte+2] ; poáet bajtñ na blok HIGH
         cld

; ------ inicializaán° poloëka ".." pro podadres†©e

         mov       ax,ds
         cmp       ax,cs:[bp+SeznSeg]       ; je to ROOT ?
         je        SelFile2                 ; nen° to ROOT
         mov       ax,-1
         stosw                              ; p©°znak ROOT
         inc       word ptr cs:[bp+SeznDNum] ; á°taá souborñ

; ------ test, zda je jië maximum souborñ v adres†©i

SelFile2:cmp       word ptr cs:[bp+SeznDNum],MAXFILES
         jae       SelFile6

; ------ test, zda je jië konec adres†©e

         cmp       byte ptr ds:[si],0       ; konec adres†©e
         je        SelFile6                 ; konec adres†©e

; ------ á°t†n° platnòch souborñ

         test      byte ptr ds:[si+FileAtr],DIR ; je to adres†© ?
         jnz       SelFile3                 ; je to adres†©
         inc       word ptr cs:[bp+SeznFFil] ; zvò®en° á°taáe souborñ

; ------ vòpoáet zabranÇ kapacity souborem

         mov       ax,ds:[si+FileSize]
         mov       dx,ds:[si+FileSize+2]
         add       ax,cx
         adc       dx,bx
         sub       ax,1
         sbb       dx,0
         call      Vydel
         call      Nasob
         add       word ptr cs:[bp+SeznFSum],ax
         adc       word ptr cs:[bp+SeznFSum+2],dx

; ------ uloëen° adresy poloëky

SelFile3:mov       ax,si
         stosw
         inc       word ptr cs:[bp+SeznDNum]     ; á°taá poloëek v adres†©i

; ------ adresa dal®° poloëky

         lodsb
         dec       si
         mov       ah,0
         add       si,ax
         jmp       short SelFile2           ; dal®° poloëka

; ------ n†vrat registrñ

SelFile6:pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

SelFile  ENDP

; -----------------------------------------------------------------------------
;        set©°dàn° adres†©e seznamu BX
; -----------------------------------------------------------------------------

SortFile PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es

; ------ p©°prava registrñ

         cld
         mov       dl,ds:[bx+SeznPar2]      ; t©°dàn° okna
         test      dl,b4                    ; t©°d° se adres†© ?
         jnz       SortFl99                 ; adres†© se net©°d°

         mov       es,ds:[bx+SeznDSeg]      ; segment zaá†tku adres†©e
         mov       cx,ds:[bx+SeznDNum]      ; poáet poloëek adres†©e
         add       bx,SeznInd               ; tabulka indexñ

; ------ p©eskoáen° prvn° poloëky ".."

         cmp       word ptr ds:[bx],-1      ; je prvn° poloëka ".." ?
         jne       SortFil1                 ; nezaá°n† poloëkou ".."
         inc       bx
         inc       bx                       ; p©eskoáen° prvn° poloëky
         dec       cx

; ------ kontrola minim†ln°ho mnoëstv° poloëek

SortFil1:push      es
         pop       ds                       ; DS <- segment souborñ
         cmp       cx,2                     ; minim†lnà 2 poloëky
         jge       SortFl12                 ; poáet poloëek OK
SortFl99:jmp       SortFil9                 ; m†lo poloëek k set©°dàn°
SortFl12:dec       cx                       ; poáet p†rñ poloëek k set©°dàn°
         mov       bp,cx                    ; £schova poátu p†rñ poloëek

; ------ adresa 2 poloëek k porovn†n°

SortFil2:mov       si,cs:[bx]               ; prvn° poloëka
         mov       di,cs:[bx+2]             ; druh† poloëka

; ------ test po©ad° adres†©/soubor

         mov       al,ds:[si+FileAtr]       ; atributy prvn°ho souboru
         mov       ah,ds:[di+FileAtr]       ; atributy druhÇho
         and       ax,DIR*HI + DIR          ; atributy adres†©ñ
         cmp       al,ah                    ; je po©ad° OK ?
         ja        SortFl82                 ; po©ad° je OK
         jb        SortFl72                 ; nutn† z†màna poloëek

; ------ porovn†n° velikosti

         test      dl,b2                    ; je t©°dàn° podle velikosti ?
         jz        SortFil3                 ; nen° t©°dàn° podle velikosti
         mov       ax,ds:[di+FileSize+2]    ; velikost druhÇ poloëky HIGH
         cmp       ax,ds:[si+FileSize+2]    ; velikost prvn° poloëky HIGH
         jne       SortFil5                 ; velikost HIGH nen° shodn†
         mov       ax,ds:[di+FileSize]      ; velikost druhÇ poloëky LOW
         cmp       ax,ds:[si+FileSize]      ; velikost prvn° poloëky LOW
         jmp       short SortFil5

; ------ porovn†n° data a áasu

SortFil3:test      dl,b3                    ; je t©°dàn° podle data a áasu ?
         jz        SortFil4                 ; nen° t©°dàn° podle data a áasu
         mov       ax,ds:[di+FileDate]      ; datum druhÇ poloëky
         cmp       ax,ds:[si+FileDate]      ; datum prvn° poloëky
         jne       SortFil5                 ; datum nen° shodnÇ
         mov       ax,ds:[di+FileTime]      ; áas druhÇ poloëky
         cmp       ax,ds:[si+FileTime]      ; áas prvn° poloëky
         jmp       short SortFil5

; ------ t©°dàn° podle p©°pony

SortFil4:test      dl,b1                    ; je t©°dàn° podle p©°pony ?
         jz        SortFil6                 ; nen° t©°dàn° podle p©°pony
         call      SortExt                  ; porovn†n° podle p©°pony

; ------ vàtven° poloëek

SortFil5:jb        SortFil8                 ; OK
         ja        SortFil7                 ; z†màna

; ------ porovn†n° jmen

SortFil6:call      SortName                 ; porovn†n° podle jmÇna
         jbe       SortFil8

; ------ z†màna poloëek

SortFil7:test      dl,b5                    ; je sestupnÇ t©°dàn° ?
         jnz       SortFl82                 ; je sestupnÇ t©°dàn°
SortFl72:mov       ax,cs:[bx]
         xchg      ax,cs:[bx+2]
         mov       cs:[bx],ax
         cmp       cx,bp                    ; je jië poá†tek adres†©e ?
         jae       SortFl82                 ; je jië poá†tek adres†©e
         dec       bx                       ; posun na p©edchoz° p†r poloëek
         dec       bx
         inc       cx                       ; p©ednastaven° á°taáe
         jmp       short SortFil2           ; test p©edchoz°ho p†ru poloëek

; ------ poloëky OK - dal®° p†r poloëek

SortFil8:test      dl,b5                    ; je sestupnÇ t©°dàn° ?
         jnz       SortFl72                 ; je sestupnÇ t©°dàn°
SortFl82:inc       bx
         inc       bx                       ; adresa dal®°ho p†ru poloëek
         loop      SortFil2                 ; test dal®°ho p†ru poloëek

; ------ n†vrat registrñ

SortFil9:pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

SortFile ENDP

; -----------------------------------------------------------------------------
;        porovn†n° poloëek DS:SI a ES:DI podle p©°pony (CLD, niá° AX)
; -----------------------------------------------------------------------------

SortExt  PROC      NEAR

; ------ £schova registrñ

         push      si
         push      di
         push      cx

; ------ p©°prava registrñ

         mov       cl,ds:[si]               ; dÇlka jmÇna poloëky 1
         mov       ch,ds:[di]               ; dÇlka jmÇna poloëky 2
         sub       cx,FileName*HI + FileName ; dÇlka jmÇna
         add       si,FileName
         add       di,FileName

; ------ nalezen° p©°pony poloëky 1

SortExt1:or        cl,cl
         jz        SortExt2                 ; je konec jmÇna 1
         lodsb
         dec       cx
         cmp       al,"."
         jne       SortExt1

; ------ nalezen° p©°pony poloëky 2

SortExt2:or        ch,ch
         jz        SortExt3                 ; je konec jmÇna 2
         mov       al,ds:[di]
         inc       di
         dec       ch
         cmp       al,"."
         jne       SortExt2

; ------ test, zda je konec jmen (ZY=poloëky shodnÇ)

SortExt3:mov       al,cl
         or        al,ch
         jz        SortExt9                 ; konec jmen - p©°pony shodnÇ

; ------ je-li konec poloëky 1, je poloëka 1 men®° neë poloëka 2

         or        cl,cl
         jz        SortExt4                 ; je konec poloëky 1

; ------ je-li konec poloëky 2, je poloëka 2 men®° neë poloëka 1

         or        ch,ch
         jnz       SortExt5                 ; nen° konec poloëky 2
SortExt4:cmp       cl,ch                    ; nastaven° p©°znaku NC nebo CY
         jmp       short SortExt9           ; poloëka 2 krat®° neë poloëka 1

; ------ porovn†n° 1 znaku poloëek

SortExt5:dec       ch
         dec       cl
         cmpsb                              ; porovn†n° jednoho znaku
         je        SortExt3                 ; shoda - dal®° znak

; ------ n†vrat registrñ

SortExt9:pop       cx
         pop       di
         pop       si
         ret

SortExt  ENDP

; -----------------------------------------------------------------------------
;        porovn†n° poloëek DS:SI a ES:DI podle jmÇna (niá° SI a DI)
; -----------------------------------------------------------------------------

SortName PROC      NEAR

; ------ £schova registrñ

         push      cx

; ------ p©°prava registrñ

         mov       cl,ds:[si]               ; dÇlka jmÇna poloëky 1
         mov       ch,ds:[di]               ; dÇlka jmÇna poloëky 2
         sub       cx,FileName*HI + FileName ; dÇlka jmÇn
         add       si,FileName
         add       di,FileName

; ------ test, zda je konec jmen (ZY=poloëky shodnÇ)

SortNam1:mov       al,cl
         or        al,ch
         jz        SortNam9                 ; konec jmen - poloëky shodnÇ

; ------ je-li konec poloëky 1, je poloëka 1 men®° neë poloëka 2

         or        cl,cl
         jz        SortNam2                 ; je konec poloëky 1

; ------ je-li konec poloëky 2, je poloëka 2 men®° neë poloëka 1

         or        ch,ch
         jnz       SortNam3                 ; nen° konec poloëky 2
SortNam2:cmp       cl,ch                    ; nastaven° p©°znaku NC
         jmp       short SortNam9           ; poloëka 2 krat®° neë poloëka 1

; ------ porovn†n° 1 znaku poloëek

SortNam3:dec       ch
         dec       cl
         cmpsb                              ; porovn†n° jednoho znaku
         je        SortNam1                 ; shoda - dal®° znak

; ------ pokud byla teáka poloëky 1, je poloëka 1 men®° neë poloëka 2

         mov       al,"."
         pushf
         cmp       ds:[si-1],al             ; byla teáka poloëky 1 ?
         jne       SortNam4                 ; nebyla teáka
         popf                               ; zru®en° F
         cmp       al,"."+1                 ; nastaven° p©°znaku CY
         jmp       short SortNam9

; ------ pokud byla teáka poloëky 2, je poloëka 2 men®° neë poloëka 1

SortNam4:cmp       ds:[di-1],al             ; byla teáka poloëky 2 ?
         jne       SortNam5                 ; nebyla teáka
         popf
         cmp       al,"."-1                 ; nastaven° p©°znaku NC
         pushf
SortNam5:popf

; ------ n†vrat registrñ

SortNam9:pop       cx
         ret

SortName ENDP

; -----------------------------------------------------------------------------
;    nalezen° cesty ASCIIZ DS:SI v seznamu BX -> ES:DI adresa adres†©e, CY=nen°
; -----------------------------------------------------------------------------

SrcPath  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si

; ------ vypu®tàn° zaá†tku cesty

         cld
         cmp       byte ptr ds:[si],0
         je        SrcPath0
         cmp       byte ptr ds:[si+1],":"
         jne       SrcPath0
         lodsw

; ------ p©°prava registrñ

SrcPath0:mov       es,ds:[bx+SeznSeg]       ; segment seznamu souborñ
         xor       di,di                    ; poá†teán° adresa

; ------ vypu®tàn° oddàlovaáe adres†©e

SrcPath1:cmp       byte ptr ds:[si],"\"
         jne       SrcPath2
         inc       si

; ------ test, zda je konec cesty

SrcPath2:cmp       byte ptr ds:[si],0       ; je konec cesty ?
         je        SrcPath9                 ; je konec cesty - adres†© nalezen

; ------ nalezen° podadres†©e

         xor       cx,cx                    ; á°taá adres†©ñ
SrcPath3:cmp       byte ptr es:[di],0       ; konec adres†©e ?
         stc                                ; p©°znak chyby
         je        SrcPath9                 ; je konec adres†©e - nenalezeno
         test      byte ptr es:[di+FileAtr],DIR ; je to adres†© ?
         jz        SrcPath5                 ; nen° to adres†©

; ------ porovn†n° jednoho adres†©e

         push      si

         push      cx
         push      di

         mov       ch,0
         mov       cl,es:[di+FileOffs]      ; offset dal®° poloëky
         sub       cl,FileName              ; dÇlka jmÇna adres†©e
         add       di,FileName              ; jmÇno adres†©e
         repe      cmpsb                    ; porovn†n° jmÇna adres†©e

         pop       di
         pop       cx

         jne       SrcPath4                 ; nen° shodnÇ jmÇno

         cmp       byte ptr ds:[si],0
         je        SrcPath6                 ; je konec jmÇna adres†©e
         cmp       byte ptr ds:[si],"\"
         je        SrcPath6                 ; je konec jmÇna adres†©e

SrcPath4:pop       si
         inc       cx                       ; zvò®en° á°taáe adres†©ñ

; ------ nalezen° dal®° poloëky

SrcPath5:mov       al,es:[di+FileOffs]      ; offset dal®° poloëky
         mov       ah,0
         add       di,ax                    ; adresa dal®° poloëky
         call      NormESDI                 ; normalizace adresy
         jmp       short SrcPath3           ; test dal®° poloëky

; ------ adres†© nalezen - ukazatel v cestà se posune

SrcPath6:pop       ax                       ; zru®en° adresy ze z†sobn°ku

; ------ nalezen° novÇho adres†©e

SrcPath7:push      cx
         call      SrcEAdr                  ; posun na konec adres†©e
         pop       cx
         call      SrcPth                   ; p©eskoáen° CX adres†©ñ
         jmp       short SrcPath1           ; nalezen° dal®°ho podadres†©e

; ------ n†vrat registrñ

SrcPath9:pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

SrcPath  ENDP

; -----------------------------------------------------------------------------
;        posun o CX podadres†©ñ od adresy ES:DI
; -----------------------------------------------------------------------------

SrcPth   PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         jcxz      SrcPth9                  ; nen° podadres†©

; ------ posun o CX podadres†©ñ

SrcPth1: push      cx
         call      SrcEAdr                  ; posun na konec adres†©e
         call      SrcPth                   ; posun o podadres†©e
         pop       cx
         loop      SrcPth1

; ------ n†vrat registrñ

SrcPth9: pop       cx
         pop       ax
         ret

SrcPth   ENDP

; -----------------------------------------------------------------------------
;        nalezen° konce adres†©e ES:DI -> CX=poáet podadres†©ñ
; -----------------------------------------------------------------------------

SrcEAdr  PROC      NEAR

; ------ £schova registrñ

         push      ax
         xor       cx,cx                    ; CX <- 0 á°taá adres†©ñ

; ------ test, zda je konec adres†©e

SrcEAdr1:mov       al,es:[di]               ; offset dal®°ho podadres†©e
         mov       ah,0
         or        ax,ax
         jz        SrcEAdr3                 ; je konec adres†©e

; ------ test, zda je to adres†©

         test      byte ptr es:[di+FileAtr],DIR ; je to adres†© ?
         jz        SrcEAdr2                 ; nen° to adres†©
         inc       cx                       ; zvò®en° á°taáe adres†©ñ

; ------ adresa dal®° poloëky

SrcEAdr2:add       di,ax                    ; adresa dal®° poloëky
         call      NormESDI                 ; normalizace adresy
         jmp       short SrcEAdr1           ; test dal®° poloëky

; ------ n†vrat registrñ

SrcEAdr3:inc       di                       ; p©eskoáen° koncovÇ 0
         pop       ax
         ret

SrcEAdr  ENDP

; -----------------------------------------------------------------------------
;        inverze oznaáen° poloëky ES:SI seznamu DS:BX
; -----------------------------------------------------------------------------

InvPol   PROC      NEAR

         test      byte ptr es:[si+FileAtr],b7 ; je poloëka oznaáen† ?
         jnz       ResPol                   ; poloëka je oznaáen†
                                            ; jinak n†sleduje oznaáen° poloëky

InvPol   ENDP

; -----------------------------------------------------------------------------
;        oznaáen° poloëky ES:SI seznamu DS:BX
; -----------------------------------------------------------------------------

SelPol   PROC      NEAR

; ------ £schova registrñ

         push      ax

; ------ test, zda je poloëka jië oznaáen†

         test      byte ptr es:[si+FileAtr],b7 ; je jië oznaáen† ?
         stc
         jnz       SelPol7                  ; poloëka je jië oznaáen†

; ------ oznaáen° poloëky

         or        byte ptr es:[si+FileAtr],b7 ; oznaáen° poloëky

; ------ ukazatele oznaáen° poloëek

         test      byte ptr es:[si+FileAtr],DIR ; je to adres†© ?
         jnz       SelPol7                  ; je to adres†©
         inc       word ptr ds:[bx+SeznSelN] ; zvò®en° á°taáe oznaáenòch souborñ
         mov       ax,es:[si+FileSize]      ; velikost souboru LOW
         add       word ptr ds:[bx+SeznSelS],ax ; á°taá oznaáenÇ kapacity
         mov       ax,es:[si+FileSize+2]    ; velikost souboru HIGH
         adc       word ptr ds:[bx+SeznSelS+2],ax ; á°taá kapacity HIGH
         clc

; ------ n†vrat registrñ

SelPol7: pop       ax
         ret

SelPol   ENDP

; -----------------------------------------------------------------------------
;        odznaáen° poloëky ES:SI seznamu DS:BX
; -----------------------------------------------------------------------------

ResPol   PROC      NEAR

; ------ £schova registrñ

         push      ax

; ------ test, zda je poloëka jië odznaáen†

         test      byte ptr es:[si+FileAtr],b7 ; je jië oznaáen† ?
         stc
         jz        ResPol7                  ; poloëka nen° oznaáen†

; ------ odznaáen° poloëky

         and       byte ptr es:[si+FileAtr],not b7 ; odznaáen° poloëky

; ------ ukazatele oznaáen° poloëek

         test      byte ptr es:[si+FileAtr],DIR ; je to adres†© ?
         jnz       ResPol7                  ; je to adres†©
         dec       word ptr ds:[bx+SeznSelN] ; sn°ëen° á°taáe oznaáenòch souborñ
         mov       ax,es:[si+FileSize]      ; velikost souboru LOW
         sub       word ptr ds:[bx+SeznSelS],ax ; á°taá oznaáenÇ kapacity
         mov       ax,es:[si+FileSize+2]    ; velikost souboru HIGH
         sbb       word ptr ds:[bx+SeznSelS+2],ax ; á°taá kapacity HIGH
         clc

; ------ n†vrat registrñ

ResPol7: pop       ax
         ret

ResPol   ENDP

; -----------------------------------------------------------------------------
;        vyhled†n° poloëky ASCIIZ DS:SI v seznamu BX -> AX (CY=nenalezena)
; -----------------------------------------------------------------------------

SrcPol   PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      cx
         push      dx
         push      di
         push      es

; ------ p©°prava registrñ

         mov       es,ds:[bx+SeznDSeg]      ; segment adres†©e
         mov       dx,ds:[bx+SeznDNum]      ; poáet poloëek v adres†©i
         xor       ax,ax                    ; ukazatel á°sla poloëky
         or        dx,dx                    ; je nàjak† poloëka ?
         stc
         jz        SrcPol9                  ; nen° ë†dn† poloëka
         add       bx,SeznInd               ; tabulka indexñ
         mov       ch,0
         cld

; ------ porovn†n° jednÇ poloëky

SrcPol2: mov       di,ds:[bx]               ; adresa poloëky
         cmp       di,-1
         je        SrcPol5                  ; neplatn† poloëka

         push      si
         mov       cl,es:[di]               ; offset dal®° poloëky
         sub       cl,FileName              ; dÇlka jmÇna
         add       di,FileName              ; jmÇno souboru
         repe      cmpsb                    ; porovn†n° poloëek
         jne       SrcPol3                  ; nesouhlas°
         cmp       byte ptr ds:[si],0       ; mus° konáit 0
SrcPol3: pop       si
         je        SrcPol9                  ; poloëka nalezena OK

SrcPol5: inc       bx
         inc       bx
         inc       ax                       ; zvò®en° ukazatele á°sla poloëky
         dec       dx
         jnz       SrcPol2                  ; dal®° poloëka
         stc                                ; chyba - nenalezeno

; ------ n†vrat registrñ

SrcPol9: pop       es
         pop       di
         pop       dx
         pop       cx
         pop       bx
         ret

SrcPol   ENDP

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                            Obsluha disku
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
; -----------------------------------------------------------------------------
;        inicializace parametrñ aktivn°ho disku
; -----------------------------------------------------------------------------

AktDPar  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ stanoven° aktivn°ho disku

         mov       word ptr ds:[AktLabN],0  ; nen° n†và®t° disku

         mov       ah,19h
         int       21h
         mov       ds:[AktDisk],al          ; aktivn° disk
         inc       ax                       ; korekce á°sla disku
         mov       dl,al                    ; á°slo disku

; ------ naáten° aktivn°ho adres†©e

         mov       si,AktDir+3
         add       al,"A"-1                 ; jmÇno disku
         mov       ah,":"
         mov       ds:[si-3],ax
         mov       word ptr ds:[si-1],"\"   ; oznaáen° ROOT
         mov       ah,47h
         int       21h
         jc        AktDPr99

; ------ stanoven° dÇlky textu adres†©e

         push      ds
         pop       es
         mov       di,AktDir
         mov       cx,MAXF
         cld
         xor       ax,ax
         repne     scasb                    ; nalezen° konce textu
         sub       cx,MAXF-1
         neg       cx
         mov       ds:[AktDirN],cx          ; dÇlka textu adres†©e

; ------ poskytnut° parametrñ disku

         mov       ah,36h
         int       21h                      ; poskytnut° parametrñ disku

; ------ p©°prava poátu blokñ obsazenÇ kapacity pro indik†tor áten° disku

         mov       ds:[DiskSumC],dx         ; celkovò poáet blokñ
         sub       ds:[DiskSumC],bx         ; vòpoáet obsazenÇ kapacity
         cmp       word ptr ds:[DiskSumC],40
         jae       AktDPar2
         mov       word ptr ds:[DiskSumC],40

; ------ poáet bajtñ na blok

AktDPar2:push      dx                       ; celkovò poáet blokñ
         mov       ds:[BlokSekt],ax         ; poáet sektorñ na alok. blok
         mov       ds:[SektByte],cx         ; poáet bajtñ na sektor
         mul       cx                       ; poáet bajtñ na alokaán° blok
         mov       word ptr ds:[BlokByte],ax ; poáet bajtñ na blok LOW
         mov       word ptr ds:[BlokByte+2],dx; poáet bajtñ na blok HIGH

; ------ voln† kapacita disku

         xchg      ax,cx                    ; CX <- bajtñ na blok LOW
         xchg      ax,bx                    ; AX <- poáet volnòch alok. blokñ
         mov       bx,dx                    ; BX <- bajtñ na blok HIGH
         xor       dx,dx                    ; DX <- 0
         call      Nasob                    ; vyn†soben° DX:AX * BX:CX -> DX:AX
         mov       word ptr ds:[DiskFree],ax ; voln† kapacita LOW
         mov       word ptr ds:[DiskFree+2],dx ; voln† kapacita HIGH
         pop       ax                       ; celkovò poáet blokñ

; ------ celkov† kapacita disku

         xor       dx,dx                    ; DX <- 0
         call      Nasob                    ; vyn†soben° DX:AX * BX:CX -> DX:AX
         mov       word ptr ds:[DiskSumm],ax ; celkov† kapacita LOW
         mov       word ptr ds:[DiskSumm+2],dx ; celkov† kapacita HIGH

; ------ nastaven° adresy DTA

         mov       dx,offset DTA
         mov       ah,1ah
         int       21h                      ; nastaven° adresy DTA

; ------ test p©eru®en° operace

         call      TestBrk                  ; test p©eru®en°
AktDPr99:jc        AktDPar9                 ; p©eru®en° operace

; ------ nalezen° n†và®t° disku

         mov       al,ds:[AktDisk]
         add       al,"A"
         mov       ds:[AllRoot],al          ; aktivn° disk
         mov       dx,offset AllRoot
         mov       cx,VOL                   ; nalezne se n†và®t°
         mov       ah,4eh
         int       21h                      ; nalezen° n†và®t° disku
         jc        AktDPar8                 ; nen° n†và®t° disku

; ------ vymaz†n° bufferu n†và®t°

         mov       di,AktLab                ; buffer n†và®t° disku
         mov       cx,12
         mov       al," "
         cld
         rep       stosb                    ; vymaz†n° bufferu n†và®t°

; ------ p©enesen° textu n†và®t°

         mov       di,AktLab                ; buffer n†và®t° disku
         mov       cx,8                     ; maxim†ln° dÇlka jmÇna disku
         mov       si,offset DTAName        ; jmÇno n†và®t°
AktDPar3:lodsb
         cmp       al,0
         je        AktDPar5                 ; konec textu n†và®t°
         cmp       al,"."
         jne       AktDPar4                 ; nen° p©°pona
         mov       di,AktLab+8
         mov       cl,3
         jmp       short AktDPar3
AktDPar4:jcxz      AktDPar3                 ; p©ekroáen° dÇlky jmÇna
         stosb
         dec       cx
         jmp       short AktDPar3
AktDPar5:sub       di,AktLab                ; dÇlka n†và®t° disku
         mov       ds:[AktLabN],di          ; dÇlka n†và®t° disku

; ------ n†vrat registrñ

AktDPar8:clc
AktDPar9:pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

AktDPar  ENDP

; -----------------------------------------------------------------------------
;        naáten° obsahu aktivn°ho disku (definice seznamu BX)
; -----------------------------------------------------------------------------

ReadDisk PROC      NEAR

; ------ £schova registrñ

         push      si
         push      di
         push      es

; ------ p©°prava specifikace souborñ

         cld
         push      ds
         pop       es
         mov       si,AktDir                ; aktivn° adres†©
         mov       di,offset FilePath       ; specifikace souborñ
         movsw                              ; p©enos "C:"
         movsb                              ; p©enos "\"
         mov       word ptr ds:[FilePthN],3 ; dÇlka textu adres†©e

; ------ p©°prava ukl†dac° adresy do bufferu

         mov       es,ds:[bx+SeznSeg]       ; adresa seznamu
         xor       di,di                    ; offset ukl†dac° adresy
         mov       word ptr ds:[SrcIndxE],0 ; konce bufferu indexñ
         mov       word ptr ds:[DiskSumR],0 ; á°taá naátenòch blokñ disku

; ------ naáten° obsahu adres†©e

         call      ReadDir                  ; naáten° obsahu adres†©e

; ------ posun ukazatelñ

         mov       di,es                    ; segment ukl†dac° adresy
         inc       di                       ; zaokrouhlen°
         mov       ds:[bx+SeznEnd],di       ; konec seznamu
         mov       ds:[DatFre],di           ; novò konec dat

         mov       si,offset AktDir
         call      SrcPath                  ; nalezen° aktivn°ho adres†©e
         mov       si,di
         call      SelFile
         call      SortFile                 ; set©°dàn° obsahu adres†©e

; ------ n†vrat registrñ

         pop       es
         pop       di
         pop       si
         ret

ReadDisk ENDP

; -----------------------------------------------------------------------------
;        naáten° obsahu adres†©e (ES:DI=ukl†dac° adresa, BX=seznam)
; -----------------------------------------------------------------------------

ReadDir  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si

; ------ zobrazen° hl†®en° o naá°t†n° struktury disku

         mov       word ptr ds:[AdrHlp],offset TextHlp1
         mov       al,ds:[AktDisk]          ; aktivn° disk
         add       al,"A"                   ; korekce na oznaáen° disku
         mov       ds:[TextHl11],al         ; oznaáen° disku
         push      di
         push      es

         mov       di,offset TextHl12
         cld
         push      cs
         pop       es
         mov       al,"∞"
         mov       cx,20
         rep       stosb

         mov       ax,ds:[DiskSumR]         ; naátenò poáet blokñ
         mov       cx,21                    ; dÇlka indik†toru+1
         mul       cx
         div       word ptr ds:[DiskSumC]   ; vòpoáet dÇlky indik†toru
         cmp       ax,20
         jb        ReadDr12
         mov       ax,20
ReadDr12:xchg      ax,cx
         mov       di,offset TextHl12
         mov       al,"≤"
         rep       stosb

         pop       es
         pop       di
         call      DispLHlp

; ------ £schova zaá†tku adres†©e do bufferu indexñ

         mov       si,ds:[SrcIndxE]         ; konec seznamu
         mov       word ptr ds:[si+SrcIndx],di ; £schova zaá†tku adres†©e
         mov       word ptr ds:[si+SrcIndx+2],es
         add       word ptr ds:[SrcIndxE],4 ; zvò®en° ukazatele

; ------ p©id†n° textu "*.*"

         push      es
         push      ds
         pop       es
         mov       si,offset All            ; text "*.*"
         mov       cl,3                     ; dÇlka
         call      AddGFil                  ; p©id†n° textu "*.*"
         pop       es
         jc        ReadDir5                 ; p©eteáen°

; ------ nastaven° adresy DTA

         mov       dx,offset DTA
         mov       ah,1ah
         int       21h                      ; nastaven° adresy DTA

; ------ test p©eru®en° operace

         call      TestBrk                  ; test p©eru®en°
         jc        ReadDir5                 ; p©eru®en° operace

; ------ nalezen° prvn°ho souboru

         mov       dx,offset FilePath
         mov       cx,RO+DIR+ARC            ; atributy souboru
         mov       ah,4eh
ReadDir2:int       21h                      ; nalezen° souboru
         jc        ReadDir5                 ; nen° dal®° soubor - konec

; ------ kontrola, zda je platn† poloëka

         cmp       word ptr ds:[DTAName],"."
         je        ReadDir4                 ; nen° platn† poloëka
         cmp       word ptr ds:[DTAName],".."
         je        ReadDir4                 ; nen° platn† poloëka

; ------ kontrola, zda je buffer plnò (rezerva pro 1 poloëku a ukonáovac° bajty)

         mov       ax,es                    ; ukl†dac° adresa
         add       ax,5                     ; rezerva 80 bajtñ
         cmp       ax,ds:[DatMax]           ; je konec bufferu ?
         jae       ReadDir5                 ; buffer je plnò

; ------ p©enesen° zaá†tku

         cld
         inc       word ptr ds:[bx+SeznNum] ; zvò®en° á°taáe poloëek celkem
         inc       di                       ; rezerva m°sta pro offset
         mov       si,offset DTAAtrib       ; zaá†tek poloëky
         lodsb
         and       al,RO+HID+SYS+DIR+ARC    ; atributy poloëky
         stosb                              ; uloëen° atributñ
         movsw                              ; áas
         movsw                              ; datum

         lodsw
         stosw                              ; velikost LOW
         xchg      ax,dx
         lodsw
         stosw                              ; velikost HIGH
         xchg      ax,dx

; ------ zvò®en° á°taáe blokñ

         mov       cx,word ptr cs:[BlokByte] ; poáet bajtñ na blok
         dec       cx
         add       ax,cx
         adc       dx,0
         inc       cx

         cmp       dx,cx
         jae       ReadDr24
         div       cx
         add       cs:[DiskSumR],ax         ; zvò®en° á°taáe blokñ
ReadDr24:

; ------ p©enesen° jmÇna souboru

         mov       cx,FILENAME-1            ; velikost poloëky bez jmÇna
ReadDir3:inc       cx                       ; zvò®en° á°taáe dÇlky poloëky
         lodsb
         stosb                              ; znak jmÇna
         cmp       al,0
         jne       ReadDir3                 ; p©enesen° textu po bajt 0
         dec       di                       ; n†vrat ukazatele
         push      di
         sub       di,cx                    ; n†vrat zaá†tku jmÇna souboru
         mov       es:[di+FileOffs],cl      ; offset dal®° poloëky
         pop       di
         call      NormESDI                 ; normalizace adresy ES:DI

; ------ dal®° poloëka adres†©e

ReadDir4:mov       ah,4fh
         jmp       short ReadDir2

; ------ uloëen° koncovÇho bajtu "0" do seznamu (=konec adres†©e)

ReadDir5:mov       al,0                     ; ukonáovac° bajt "0"
         cld
         stosb
         call      NormESDI                 ; normalizace adresy ES:DI

; ------ odstranàn° textu "*.*" ze jmÇna souboru

         call      SubGFil                  ; odstranàn° textu "*.*"

; ------ nalezen° adres†©e v seznamu

ReadDir6:push      es
         mov       si,ds:[SrcIndxE]         ; konec seznamu
         mov       es,word ptr ds:[si+SrcIndx+2-4]
         mov       si,word ptr ds:[si+SrcIndx-4] ; adresa ukazatele v adres†©i
         cmp       byte ptr es:[si],0       ; je to konec adres†©e ?
         je        ReadDir8                 ; je to konec adres†©e
         test      byte ptr es:[si+FileAtr],DIR ; je to adres†© ?
         jz        ReadDir7                 ; nen° to adres†©

; ------ p©id†n° textu adres†©e

         mov       cl,es:[si+FileOffs]      ; offset dal®° poloëky
         sub       cl,FileName              ; dÇlka textu jmÇna souboru
         add       si,offset FileName       ; jmÇno adres†©e
         call      AddGFil                  ; p©id†n° textu ke jmÇnu adres†©e
         jc        ReadDir7                 ; p©eteáen° hloubky

; ------ naáten° zadanÇho adres†©e

         pop       es
         call      ReadDir                  ; naáten° adres†©e
         push      es

; ------ odstranàn° textu adres†©e

         call      SubGFil                  ; odstranàn° jmÇna adres†©e

; ------ dal®° poloëka adres†©e

ReadDir7:mov       si,ds:[SrcIndxE]         ; konec seznamu
         mov       es,word ptr ds:[si+SrcIndx+2-4]
         mov       si,word ptr ds:[si+SrcIndx-4] ; adresa ukazatele v adres†©i
         mov       al,es:[si+FileOffs]      ; offset dal®° poloëky
         mov       ah,0
         add       si,ax                    ; adresa dal®° poloëky
         call      NormESSI                 ; normalizace adresy ES:SI
         xchg      ax,si                    ; AX <- novò offset poloëky
         mov       si,ds:[SrcIndxE]         ; konec seznamu
         mov       word ptr ds:[si+SrcIndx-4],ax ; adresa dal®° poloëky
         mov       word ptr ds:[si+SrcIndx+2-4],es
         pop       es
         jmp       short ReadDir6           ; test dal®° poloëky

; ------ nen° dal®° poloëka podadres†©e

ReadDir8:pop       es
         sub       word ptr ds:[SrcIndxE],4 ; sn°ëen° ukazatele

; ------ n†vrat registrñ

ReadDir9:pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

ReadDir  ENDP

; -----------------------------------------------------------------------------
;        p©id†n° textu k cestà (ES:SI=text, CL=dÇlka -> CY=p©eteáen°)
; -----------------------------------------------------------------------------

AddGFil  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      si
         push      di

; ------ kontrola, zda bude p©eteáen° bufferu

         mov       ch,0
         mov       ax,cx                    ; dÇlka textu
         add       ax,cs:[FilePthN]         ; nov† dÇlka textu cesty
         cmp       ax,MAXF-1                ; maxim†ln° dÇlka bufferu
         cmc
         jc        AddGFil9                 ; p©eteáen° bufferu

; ------ zaji®tàn° koncovÇho znaku "\"

         mov       di,offset FilePath       ; buffer cesty
         add       di,cs:[FilePthN]         ; konec cesty
         mov       al,"\"
         cmp       cs:[di-1],al             ; koná° znakem "\" ?
         je        AddGFil3                 ; koná° znakem "\" - OK
         mov       cs:[di],al               ; oddàlovac° znak
         inc       di                       ; zvò®en° ukazatele na dal®° znak

; ------ p©enesen° textu

AddGFil3:push      ds
         push      es

         push      cs
         push      es
         pop       ds                       ; DS <- ES
         pop       es                       ; ES <- DS
         cld
         rep       movsb                    ; p©enesen° textu

         pop       es
         pop       ds

; ------ koncov† 0, dÇlka textu

         mov       byte ptr cs:[di],0       ; koncov† 0
         sub       di,offset FilePath       ; nov† dÇlka textu
         mov       cs:[FilePthN],di         ; nov† dÇlka textu
         clc                                ; p©°znak operace OK

; ------ n†vrat registrñ

AddGFil9:pop       di
         pop       si
         pop       cx
         pop       ax
         ret

AddGFil  ENDP

; -----------------------------------------------------------------------------
;        odstranàn° posledn°ho souboru z cesty
; -----------------------------------------------------------------------------

SubGFil  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      si

; ------ konec textu v bufferu

         mov       si,offset FilePath       ; cesta
         add       si,cs:[FilePthN]         ; konec textu cesty

; ------ nalezen° posledn°ho znaku "\"

         mov       al,"\"                   ; hledanò znak "\"
SubGFil1:dec       si                       ; sn°ëen° ukazatele v bufferu
         cmp       cs:[si],al               ; je konec cesty ?
         jne       SubGFil1                 ; nen° - dal®° znak

; ------ oznaáen° konce cesty

         cmp       byte ptr cs:[si-1],":"   ; je to ROOT ?
         jne       SubGFil2                 ; nen° to ROOT
         inc       si                       ; zvò®en° ukazatele - ponech† se "\"
SubGFil2:mov       byte ptr cs:[si],0       ; koncov† 0

; ------ nov† dÇlka cesty

         sub       si,offset FilePath       ; dÇlka textu cesty
         mov       cs:[FilePthN],si         ; nov† dÇlka cesty

; ------ n†vrat registrñ

         pop       si
         pop       cx
         pop       ax
         ret

SubGFil  ENDP


; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                       Univerz†ln° obsluha displeje
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
; -----------------------------------------------------------------------------
;        vypnut° kurzoru
; -----------------------------------------------------------------------------

KurzOff  PROC      NEAR

         push      dx

         mov       dx,25*HI                 ; prvn° ©†dek "za rohem"
         call      SetKurz                  ; nastaven° pozice kurzoru

         pop       dx
         ret

KurzOff  ENDP

; -----------------------------------------------------------------------------
;        nastaven° pozice kurzoru na DX
; -----------------------------------------------------------------------------

SetKurz  PROC      NEAR

         push      ax
         push      bx

         mov       bh,0                     ; aktivn° videostr†nka
         mov       ah,2                     ; funkce - nastaven° pozice kurzoru
         call      Int10P                   ; nastaven° pozice kurzoru

         pop       bx
         pop       ax
         ret

SetKurz  ENDP

; -----------------------------------------------------------------------------
;        Z†pis 1 znaku AX na obrazovku na pozici DX (DL <- nov† pozice)
; -----------------------------------------------------------------------------

Disp1Chr PROC      NEAR

         push      cx
         mov       cl,1                     ; 1 znak k z†pisu
         call      DispChr                  ; z†pis 1 znaku na displej
         pop       cx
         ret

Disp1Chr ENDP

; -----------------------------------------------------------------------------
;        z†pis CL znakñ AX na obrazovku na pozici DX (DL <- nov† pozice)
; -----------------------------------------------------------------------------

DispChr  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      di
         push      es

         xchg      ax,bx                    ; £schova znaku k z†pisu
         mov       ch,0                     ; CX = poáet znakñ

; ------ vòpoáet adresy ve videopamàti

         mov       es,cs:[SegmVRAM]         ; adresa VRAM
         mov       al,80                    ; poáet znakñ na ©†dek
         mul       dh                       ; p©epoáet ©†dkñ na pozice
         mov       dh,0                     ; DX=pozice
         add       ax,dx                    ; p©iáten° pozice
         shl       ax,1                     ; * 2 = offset ve videostr†nce
         xchg      ax,di                    ; DI <- adresa ve videopamàti

; ------ p©°prava dat; zji®tàn°, zda se kontroluje snàëen°

         cld                                ; smàr posunu ukazatele nahoru
         cmp       byte ptr cs:[ChckSnow],0 ; prov†d° se kontrola snàëen° ?
         je        DispChr6                 ; neprov†d° se kontrola snàëen°
         jcxz      DispChr7                 ; nen° ë†dnò znak k p©enosu

; ------ p©enos dat s obsluhou snàëen°

         sti                                ; p©eru®en° povoleno
         mov       dx,cs:[PortCRT]          ; stavovò registr ©adiáe displeje
DispChr2:in        al,dx                    ; áten° stavu video©adiáe 6845
         test      al,8                     ; prob°h† vertik†ln° impuls ?
         jnz       DispChr5                 ; prob°h† vertik†ln° impuls
DispChr3:in        al,dx                    ; áten° stavu video©adiáe 6845
         rcr       al,1                     ; test horizont†ln°ho zpàtnÇho bàhu
         jc        DispChr3                 ; je horiz. zpàtnò bàh - áek†n°
DispChr4:in        al,dx                    ; áten° stavu video©adiáe 6845
         rcr       al,1                     ; test horiz. zpàtnÇho bàhu
         jnc       DispChr4                 ; áek†n° na horiz. zpàtnò bàh
DispChr5:xchg      ax,bx                    ; znak k zobrazen°
         stosw                              ; z†pis jednoho znaku
         xchg      ax,bx
         loop      DispChr2                 ; z†pis dal®°ho znaku

; ------ z†pis znaku bez kontroly snàëen°

DispChr6:xchg      ax,bx                    ; AX <- znak k zobrazen°
         rep       stosw                    ; z†pis znaku bez kontroly snàëen°

; ------ n†vrat registrñ, konec

DispChr7:pop       es
         pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax

         add       dl,cl                    ; zvò®en° pozice
         ret

DispChr  ENDP

; -----------------------------------------------------------------------------
;        Zobrazen° st°nu CL pozic od pozice DX (DL <- nov† pozice)
; -----------------------------------------------------------------------------

DispStin PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      di
         push      es
         mov       ch,0                     ; CX = poáet znakñ

; ------ vòpoáet adresy ve videopamàti

         mov       es,cs:[SegmVRAM]         ; adresa VRAM
         mov       al,80                    ; poáet znakñ na ©†dek
         mul       dh                       ; p©epoáet ©†dkñ na pozice
         mov       dh,0                     ; DX=pozice
         add       ax,dx                    ; p©iáten° pozice
         shl       ax,1                     ; * 2 = offset ve videostr†nce
         xchg      ax,di                    ; DI <- adresa ve videopamàti

; ------ zobrazen° st°nu

         jcxz      DispStn7
         mov       al,7
         inc       di
         cld
DispStn6:stosb
         inc       di
         loop      DispStn6

; ------ n†vrat registrñ, konec

DispStn7:pop       es
         pop       di
         pop       dx
         pop       cx
         pop       ax

         add       dl,cl                    ; zvò®en° pozice
         ret

DispStin ENDP

; -----------------------------------------------------------------------------
;     Zobrazen° textu ES:SI o dÇlce CL a barvà AH od pozice DX (DL<-nov† pozice)
; -----------------------------------------------------------------------------

DispTxt  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es
         mov       ch,0                     ; CX = poáet znakñ

; ------ vòpoáet adresy ve videopamàti

         push      ax                       ; AH=barva textu
         mov       al,80                    ; poáet znakñ na ©†dek
         mul       dh                       ; p©epoáet ©†dkñ na pozice
         mov       dh,0                     ; DX=pozice
         add       ax,dx                    ; p©iáten° pozice
         shl       ax,1                     ; * 2 = offset ve videostr†nce
         xchg      ax,di                    ; DI <- adresa ve videopamàti
         pop       ax                       ; AH=barva textu

; ------ p©°prava dat; zji®tàn°, zda se kontroluje snàëen°

         push      es                       ; segment zdrojovÇho textu
         pop       ds                       ; segment zdrojovÇ adresy
         mov       es,cs:[SegmVRAM]         ; adresa VRAM

         cld                                ; smàr posunu ukazatele nahoru
         cmp       byte ptr cs:[ChckSnow],0 ; prov†d° se kontrola snàëen° ?
         jcxz      DispTxt7                 ; nen° ë†dnò znak k p©enosu
         je        DispTxt6                 ; neprov†d° se kontrola snàëen°

; ------ p©enos dat s obsluhou snàëen°

         sti                                ; p©eru®en° povoleno
         mov       dx,cs:[PortCRT]          ; stavovò registr ©adiáe displeje
DispTxt2:in        al,dx                    ; áten° stavu video©adiáe 6845
         test      al,8                     ; prob°h† vertik†ln° impuls ?
         jnz       DispTxt5                 ; prob°h† vertik†ln° impuls
DispTxt3:in        al,dx                    ; áten° stavu video©adiáe 6845
         rcr       al,1                     ; test horizont†ln°ho zpàtnÇho bàhu
         jc        DispTxt3                 ; je horiz. zpàtnò bàh - áek†n°
DispTxt4:in        al,dx                    ; áten° stavu video©adiáe 6845
         rcr       al,1                     ; test horiz. zpàtnÇho bàhu
         jnc       DispTxt4                 ; áek†n° na horiz. zpàtnò bàh
DispTxt5:lodsb                              ; naáten° znaku k zobrazen°
         stosw                              ; p©enos jednoho znaku
         loop      DispTxt2                 ; p©enos dal®°ho znaku
         jmp       short DispTxt7

; ------ p©enos dat bez kontroly snàëen°

DispTxt6:lodsb                              ; znak k zobrazen°
         stosw                              ; uloëen° znaku
         loop      DispTxt6                 ; p©enos dat bez kontroly snàëen°

; ------ n†vrat registrñ, konec

DispTxt7:pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax

         add       dl,cl                    ; zvò®en° pozice
         ret

DispTxt  ENDP

; -----------------------------------------------------------------------------
;        Zobrazen° ©etàzce ES:SI o dÇlce CL od pozice DX (DL <- nov† pozice)
; -----------------------------------------------------------------------------

DispStr  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es
         mov       ch,0                     ; CX = poáet znakñ

; ------ vòpoáet adresy ve videopamàti

         mov       al,80                    ; poáet znakñ na ©†dek
         mul       dh                       ; p©epoáet ©†dkñ na pozice
         mov       dh,0                     ; DX=pozice
         add       ax,dx                    ; p©iáten° pozice
         shl       ax,1                     ; * 2 = offset ve videostr†nce
         xchg      ax,di                    ; adresa ve videopamàti

; ------ p©°prava dat; zji®tàn°, zda se kontroluje snàëen°

         push      es                       ; £schova segmentu zdrojovÇho textu
         pop       ds                       ; segment zdrojovÇ adresy
         mov       es,cs:[SegmVRAM]         ; adresa VRAM

         cld                                ; smàr posunu ukazatele nahoru
         cmp       byte ptr cs:[ChckSnow],0 ; prov†d° se kontrola snàëen° ?
         je        DispStr6                 ; neprov†d° se kontrola snàëen°
         jcxz      DispStr7                 ; nen° ë†dnò znak k p©enosu

; ------ p©enos dat s obsluhou snàëen°

         sti                                ; povolen° p©eru®en°
         mov       dx,cs:[PortCRT]          ; stavovò registr ©adiáe displeje
DispStr2:in        al,dx                    ; áten° stavu video©adiáe 6845
         test      al,8                     ; prob°h† vertik†ln° impuls ?
         jnz       DispStr5                 ; prob°h† vertik†ln° impuls
DispStr3:in        al,dx                    ; áten° stavu video©adiáe 6845
         rcr       al,1                     ; test horizont†ln°ho zpàtnÇho bàhu
         jc        DispStr3                 ; je horiz. zpàtnò bàh - áek†n°
DispStr4:in        al,dx                    ; áten° stavu video©adiáe 6845
         rcr       al,1                     ; test horiz. zpàtnÇho bàhu
         jnc       DispStr4                 ; áek†n° na horiz. zpàtnò bàh
DispStr5:movsw                              ; p©enos jednoho znaku
         loop      DispStr2                 ; p©enos dal®°ho znaku

; ------ p©enos dat bez kontroly snàëen°

DispStr6:rep       movsw                    ; p©enos dat bez kontroly snàëen°

; ------ n†vrat registrñ, konec

DispStr7:pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax

         add       dl,cl                    ; zvò®en° pozice
         ret

DispStr  ENDP

; -----------------------------------------------------------------------------
;        Atualizace parametrñ displeje
; -----------------------------------------------------------------------------

AktPDisp PROC    NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      ds

; ------ p©°prava registrñ

         xor       bx,bx
         mov       ds,bx                    ; DS <- 0

; ------ aktu†ln° videom¢d

         mov       ah,0fh
         call      Int10P                   ; aktu†ln° videom¢d
         and       al,7fh                   ; zru®en° p©°znaku nemaz†n° displeje

; ------ segment videopamàti a p©ednastaven° p©°znaku obsluhy snàëen°

         mov       byte ptr cs:[ChckSnow],0 ; zru®en° p©°znaku obsluhy snàëen°
         mov       byte ptr cs:[SegmVRAM+1],0B0h ; segment videopamàti pro MDA
         cmp       al,7                     ; je videom¢d MDA ?
         je        AktPDis1                 ; je videom¢d MDA
         inc       byte ptr cs:[ChckSnow]   ; nastav. p©°znaku obsluhy snàëen°
         mov       byte ptr cs:[SegmVRAM+1],0B8h ; segment videopamàti pro CGA

; ------ test videokarty EGA/VGA

AktPDis1:mov       ah,12h                   ; sluëba EGA/VGA - informace o EGA
         mov       bx,4510h                 ; poskytnut° informac° o EGA
         call      Int10P                   ; poskytnut° informac° o EGA/VGA
         mov       byte ptr cs:[EgaVga],0   ; zru®en° p©°znaku karty EGA/VGA
         cmp       bh,1                     ; kontrola navr†cenÇho m¢du displeje
         ja        AktPDis2                 ; nen° to karta EGA/VGA
         cmp       bl,5                     ; maxim†lnà povolen 1 MB pamàti
         ja        AktPDis2                 ; nen° to karta EGA/VGA
         inc       byte ptr cs:[EgaVga]     ; p©°znak karty EGA/VGA

; ------ up©esnàn° p©°znaku kontroly snàëen°

         mov       al,ds:[487h]             ; p©°znak kontroly snàëen°
         shr       al,1
         shr       al,1
         and       al,1                     ; p©°znak obsluhy snàëen°
         mov       cs:[ChckSnow],al         ; nastaven° p©°znaku kontroly snàë.

; ------ zji®tàn° b†zovÇ ©°dic° adresy displeje CRT

AktPDis2:mov       ax,ds:[463h]             ; b†zov† adresa portu ©adiáe CRT
         add       ax,6
         mov       cs:[PortCRT],ax          ; stavovò registr ©adiáe displeje

; ------ n†vrat registrñ

         pop       ds
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

AktPDisp ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 10h s £schovou registrñ
; -----------------------------------------------------------------------------

Int10P   PROC      NEAR

         pushf
         push      si
         push      di
         push      bp
         push      ds
         push      es

         int       10h

         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         popf
         ret

Int10P   ENDP

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                             RñznÇ procedury
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
; -----------------------------------------------------------------------------
;        dek¢dov†n° textu DS:SI do bufferu ES:DI, AH=barva (1. bajt = dÇlka)
; -----------------------------------------------------------------------------

DekTxt   PROC      NEAR

         push      ax
         push      cx

         cld
         lodsb
         mov       cl,al                    ; dÇlka textu
         mov       ch,0
         jcxz      DekTxt4

DekTxt2: lodsb
         stosw
         loop      DekTxt2

DekTxt4: pop       cx
         pop       ax
         ret

DekTxt   ENDP

; -----------------------------------------------------------------------------
;        dek¢dov†n° á°sla DX:AX do ES:DI (CL=®°©ka, CH=barva) s omezen°m dÇlky
; -----------------------------------------------------------------------------

Dek10Num PROC      NEAR

; ------ test, zda je á°slo 100.000.000 a vàt®°

         cmp       dx,1525
         jne       Dek10Nm2
         cmp       ax,57600
Dek10Nm2:jb        DekNum                   ; velikost á°sla je OK

; ------ zkr†cen° dÇlky pole

         cmp       cl,9
         jb        Dek10Nm3
         dec       cl

; ------ vydàlen° á°sla 1000x

Dek10Nm3:push      bx
         push      cx
         mov       cx,1000
         xor       bx,bx
         call      Vydel                    ; vydàlen° DX:AX/1000
         pop       cx
         pop       bx

; ------ dek¢dov†n° á°sla DX:AX

         call      DekNum

; ------ uloëen° koncovÇho oznaáen° "K"

         push      ax
         mov       ah,ch
         mov       al,"K"
         cld
         stosw
         pop       ax
         ret

Dek10Num ENDP

; -----------------------------------------------------------------------------
;   dek¢dov†n° á°sla DX:AX do bufferu ES:DI, CL=®°©ka pole, CH=barva (0=nen°)
; -----------------------------------------------------------------------------

DekNum   PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      bp

; ------ p©°prava registrñ

         xchg      ax,bp                    ; BP <- á°slo LOW
         mov       si,10                    ; SI = dàlitel
         mov       bh,ch                    ; BH <- barva
         mov       ch,0                     ; CH = á°taá á°slic, CL = ®°©ka
         mov       bl,"."                   ; BL = znak mezery, BH = barva

; ------ vòpoáet jednÇ á°slice

DekNum1: xchg      ax,dx                    ; AX <- á°slo HIGH
         xor       dx,dx                    ; DX <- 0
         div       si                       ; vydàlen° á°sla HIGH
         xchg      ax,bp                    ; AX <- n†vrat LOW, BP<-£schova HIGH
         div       si                       ; vydàlen° á°sla LOW

; ------ oddàlovaá ©†dñ

         cmp       ch,3
         je        DekNum2                  ; jsou tis°ce
         cmp       ch,7
         jne       DekNum3                  ; nejsou miliony
DekNum2: push      bx                       ; uloëen° oddàlovac° teáky
         inc       ch                       ; zvò®en° á°taáe á°slic v z†sobn°ku

; ------ uloëen° á°sla

DekNum3: add       dl,"0"                   ; korekce na znak ASCII
         mov       dh,bh                    ; barva
         push      dx                       ; uloëen° á°sla do z†sobn°ku
         inc       ch                       ; zvò®en° á°taáe á°slic v z†sobn°ku
         mov       dx,bp                    ; DX <- n†vrat á°sla HIGH
         xchg      ax,bp                    ; BP <- á°slo LOW, (AX <- HIGH)

; ------ test, zda bude dal®° á°slice

         or        ax,bp                    ; je á°slo jië = 0 ?
         jnz       DekNum1                  ; dek¢dov†n° dal®° á°slice

; ------ rozli®en°, zda se ukl†d† barva

         or        bh,bh                    ; ukl†d† se barva ?
         jnz       DekNum5                  ; barva se ukl†d†

; ------ vymaz†n° bufferu pro uloëen° á°sla (bez barvy)

         mov       si,di                    ; £schova zaá†tku bufferu
         push      cx
         mov       ch,0
         mov       al," "                   ; mezera k vymaz†n° bufferu
         rep       stosb                    ; vymaz†n° bufferu pro á°slo
         pop       ax
         mov       cl,ah                    ; CX = poáet znakñ v z†sobn°ku

; ------ adresa v bufferu k uloëen° á°sla

         sub       di,cx                    ; adresa k uloëen° á°sla
         cmp       di,si                    ; je pod pñvodn°m poá†tkem ?
         ja        DekNum4                  ; poá†tek je OK
         mov       di,si                    ; omezen° na pñvodn° poá†tek

; ------ uloëen° á°sla do bufferu (bez barvy)

DekNum4: pop       ax
         stosb
         loop      DekNum4                  ; dal®° znak
         jmp       short DekNum9

; ------ vymaz†n° bufferu pro uloëen° á°sla (s barvou)

DekNum5: mov       si,di                    ; £schova zaá†tku bufferu
         push      cx
         mov       ch,0
         mov       ah,bh                    ; barva
         mov       al," "                   ; mezera k vymaz†n° bufferu
         rep       stosw                    ; vymaz†n° bufferu pro á°slo
         pop       ax
         mov       cl,ah                    ; CX = poáet znakñ v z†sobn°ku

; ------ adresa v bufferu k uloëen° á°sla

         sub       di,cx
         sub       di,cx                    ; adresa k uloëen° á°sla
         cmp       di,si                    ; je pod pñvodn°m poá†tkem ?
         ja        DekNum6                  ; poá†tek je OK
         mov       di,si                    ; omezen° na pñvodn° poá†tek

; ------ uloëen° á°sla do bufferu (s barvou)

DekNum6: pop       ax
         stosw
         loop      DekNum6                  ; dal®° znak

; ------ n†vrat registrñ

DekNum9: pop       bp
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DekNum   ENDP

; -----------------------------------------------------------------------------
;        p©evod znaku AL na velkÇ p°smeno
; -----------------------------------------------------------------------------

UpCase   PROC      NEAR

         cmp       al,"a"
         jb        UpCase2
         cmp       al,"z"
         ja        UpCase2
         sub       al,32
UpCase2: ret

UpCase   ENDP

; -----------------------------------------------------------------------------
;                    skok na obsluhu podle DX
; -----------------------------------------------------------------------------
; Procedura se vol† instrukc° CALL JumpDX, za kterou n†sleduje tabulka
; skokñ. Procedura zmàn° svou n†vratovou adresu na adresu podle nalezenÇ
; poloëky v tabulce (nebo podle poloëky pro nenalezenou hodnotu).
; -----------------------------------------------------------------------------
; VSTUP: v z†sobn°ku slovo (n†vratov† adresa NEAR) = zaá†tek tabulky skokñ
;             stuktura tabulky: 1 slovo testovan† hodnota DX
;                               1 slovo adresa NEAR obsluhy
;             konec tabulky: 1 slovo = 0 (p©°znak konce tabulky)
;                            1 slovo adresa NEAR obsluhy p©i nenalezen° k¢du
; -----------------------------------------------------------------------------

JumpDX   PROC      NEAR

; ------ £schova registrñ

                                            ; SS:[BP+6] = IP
         push      si                       ; SS:[BP+4] = SI
         push      bp                       ; SS:[BP+2] = BP
         push      ds                       ; SS:[BP+0] = DS
         mov       bp,sp

; ------ nalezen° hodnoty v tabulce

         push      cs
         pop       ds
         mov       si,ss:[bp+6]             ; offset adresy tabulky
JumpDX1: cmp       word ptr ds:[si],0       ; je konec tabulky ?
         je        JumpDX2                  ; konec tabulky - nenalezeno
         cmp       word ptr ds:[si],dx      ; je to hledan† hodnota ?
         je        JumpDX2                  ; hodnota nalezena
         add       si,4                     ; adresa dal®° poloëky
         jmp       short JumpDX1            ; test dal®° poloëky

; ------ nastaven° n†vratovÇ adresy podle tabulky

JumpDX2: mov       si,ds:[si+2]             ; adresa skoku
         mov       ss:[bp+6],si             ; nov† n†vratov† adresa

; ------ n†vrat registrñ

         pop       ds
         pop       bp
         pop       si
         ret

JumpDX   ENDP

; -----------------------------------------------------------------------------
;                                 Cekej
;                        áek†n° po zadanou dobu
; -----------------------------------------------------------------------------
; VSTUP: CX=poáet impulsñ 1/18 s
; -----------------------------------------------------------------------------

Cekej    PROC      NEAR

         push      ax
         push      cx
         push      ds

         xor       ax,ax
         mov       ds,ax
         jcxz      Cekej3
         sti

Cekej1:  mov       ax,ds:[46ch]
Cekej2:  cmp       ax,ds:[46ch]
         je        Cekej2
         loop      Cekej1

Cekej3:  pop       ds
         pop       cx
         pop       ax
         ret

Cekej    ENDP

; -----------------------------------------------------------------------------
;        test p©eru®en° operace (CY=p©eru®en° operace)
; -----------------------------------------------------------------------------

TestBrk  PROC      NEAR

         push      ax

         cmp       byte ptr cs:[ParBreak],0 ; je p©eru®en° operace ?
         jne       TestBrk2                 ; je p©eru®en° operace

         call      TestKey                  ; test, zda je nàjak† kl†vesa
         jc        TestBrk2                 ; nen° ë†dn† kl†vesa

         cmp       ax,11bh
         je        TestBrk1                 ; je kl†vesa ESC
         or        ax,ax
         jnz       TestBrk3                 ; nen° Ctrl-Break

TestBrk1:push      bx
         call      InpKey                   ; vstup znaku z kl†vesnice
         pop       bx
         or        byte ptr cs:[ParBreak],b0 ; p©°znak p©eru®en°

TestBrk2:cmc
TestBrk3:pop       ax
         ret

TestBrk  ENDP

; -----------------------------------------------------------------------------
;        vstup znaku z kl†vesnice do DX (CY=p©eru®en° ESC, BREAK)
; -----------------------------------------------------------------------------

InpKey   PROC      NEAR

         push      ax

; ------ áek†n° na stisk kl†vesy

InpKey1: call      TestKey
         jc        InpKey1                  ; nen° kl†vesa

; ------ vstup znaku z kl†vesnice

         mov       ah,0
         int       16h                      ; vstup znaku z kl†vesnice

; ------ n†hrada Ctrl-Break kl†vesou ESC

         or        ax,ax                    ; je Ctrl-Break ?
         jnz       InpKey2                  ; nen° Ctrl-Break
         mov       ax,11bh                  ; n†hrada ESC

; ------ test, zda je ESC

InpKey2: cmp       ax,11bh                  ; je ESC ?
         clc
         jne       InpKey3                  ; nen° ESC
         stc                                ; p©°znak kl†vesy ESC

InpKey3: xchg      ax,dx                    ; DX <- k¢d kl†vesy
         pop       ax
         ret

InpKey   ENDP

; -----------------------------------------------------------------------------
;        test stavu kl†vesnice (AX=kl†vesa, CY=nen° znak z kl†vesnice)
; -----------------------------------------------------------------------------

TestKey  PROC      NEAR

         push      ds
         xor       ax,ax
         mov       ds,ax
         and       byte ptr ds:[418h],not 80h
         pop       ds

         mov       ah,1
         int       16h                      ; test stavu kl†vesnice
         clc                                ; p©°znak - je kl†vesa
         jnz       TestKey2                 ; je kl†vesa
         stc                                ; p©°znak - nen° kl†vesa
TestKey2:ret

TestKey  ENDP

; -----------------------------------------------------------------------------
;        normalizace adresy ES:DI
; -----------------------------------------------------------------------------

NormESDI PROC      NEAR

         push      ax
         push      di

         mov       ax,es
         shr       di,1
         shr       di,1
         shr       di,1
         shr       di,1
         add       ax,di
         mov       es,ax

         pop       di
         pop       ax
         and       di,0fh
         ret

NormESDI ENDP

; -----------------------------------------------------------------------------
;        normalizace adresy ES:SI
; -----------------------------------------------------------------------------

NormESSI PROC      NEAR

         push      ax
         push      si

         mov       ax,es
         shr       si,1
         shr       si,1
         shr       si,1
         shr       si,1
         add       ax,si
         mov       es,ax

         pop       si
         pop       ax
         and       si,0fh
         ret

NormESSI ENDP

; -----------------------------------------------------------------------------
;        vyn†soben° á°sla DX:AX á°slem BX:CX -> DX:AX souáin (CY=chyba, -> -1)
; -----------------------------------------------------------------------------

Nasob    PROC      NEAR

; ------ £schova registrñ

         push      si
         push      di

; ------ AX*CX

         push      dx
         push      ax
         mul       cx                       ; AX * CX
         xchg      ax,si                    ; SI <- st©adaá LOW
         mov       di,dx                    ; DI <- st©adaá HIGH
         pop       ax

; ------ AX*BX

         mul       bx                       ; AX * BX
         add       di,ax
         adc       dx,0                     ; p©enos
         pop       ax                       ; DX
         jc        Nasob3                   ; p©eteáen°
         jnz       Nasob3                   ; p©eteáen°

; ------ DX*CX

         push      ax
         mul       cx                       ; DX * CX
         add       di,ax
         adc       dx,0
         pop       ax
         jc        Nasob3                   ; p©eteáen°
         jnz       Nasob3                   ; p©eteáen°

; ------ DX*BX

         mul       bx
         or        ax,dx
         jz        Nasob4                   ; nen° p©eteáen°

; ------ p©eteáen° á°sla

Nasob3:  mov       si,-1
         mov       di,si
         stc                                ; p©°znak chyby

; ------ vòsledek operace

Nasob4:  xchg      ax,si
         mov       dx,di

; ------ n†vrat registrñ

         pop       di
         pop       si
         ret

Nasob    ENDP

; -----------------------------------------------------------------------------
;        vydàlen° á°sla DX:AX á°slem BX:CX -> DX:AX pod°l
; -----------------------------------------------------------------------------

Vydel    PROC      NEAR

; ------ £schova registrñ

         push      si

; ------ test, zda je dàlen° velkòm á°slem

         or        bx,bx                    ; je dàlen° velkòm á°slem ?
         jnz       Vydel2                   ; je dàlen° velkòm á°slem

; ------ test, zda je dàlen° nulou

         jcxz      Vydel8                   ; chyba operace - dàlen° nulou

; ------ dàlen° DX:AX á°slem CX

         xchg      ax,si                    ; SI <- dàlenec LOW (AX)
         xchg      ax,dx                    ; AX <- dàlenec HIGH (DX)
         xor       dx,dx                    ; DX <- 0
         div       cx                       ; dàlen° DX/CX
         xchg      ax,si                    ; SI <- novÇ HIGH, AX <- starÇ LOW
         div       cx                       ; dàlen° AX/CX
         xchg      dx,si                    ; DX <- novÇ HIGH, SI <- zbytek
         clc                                ; operace OK
         jmp       short Vydel9

; ------ dàlen° odeá°t†n°m velkÇho á°sla

Vydel2:  xchg      ax,si                    ; SI <- á°slo LOW
         mov       ax,-1                    ; AX <- st©adaá pod°lu
Vydel3:  inc       ax                       ; st©adaá pod°lu
         sub       si,cx                    ; odeáten° dàlitele
         sbb       dx,bx
         jnc       Vydel3                   ; nen° p©eteáen°
         xor       dx,dx
         jmp       short Vydel9

; ------ chyba operace - dàlen° nulou

Vydel8:  mov       ax,-1
         mov       dx,ax
         stc                                ; p©°znak chyby operace

; ------ n†vrat registrñ

Vydel9:  pop       si
         ret

Vydel    ENDP

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                                     data
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛

OldBreak db        1                        ; pñvodn° stav BREAK
ParBreak db        0                        ; p©°znak p©eru®en° operace

; ------ parametry pro displej

         EVEN
SegmVRAM dw        0b000h                   ; segment videopamàti
PortCRT  dw        3dah                     ; b†zov† adresa portu ©adiáe CRT
EgaVga   db        0                        ; p©°znak, ëe je karta EGA/VGA
ChckSnow db        0                        ; p©°znak, ëe se kontroluje snàëen°

; ------ parametry pro komunikaán° port

Port     dw        0                        ; á°slo datovÇho portu
AdrPort  dw        3f8h                     ; adresa portu COM
OldComm  dd        0                        ; pñvodn° adresa komunikaán°ho portu
Old08    dd        0                        ; pñvodn° adresa INT 08h
Old09    dd        0                        ; pñvodn° adresa INT 09h
OldInt   db        0                        ; pñvodn° registr p©eru®en°

; ------ ukazatel sektorñ

VysDBlok dw        0                        ; poáet vys°lanòch datovòch blokñ
PriDBlok dw        0                        ; poáet p©ij°manòch datovòch blokñ
MaxDBlok dw        0                        ; maxim†ln° poáet datovòch blokñ
SektBSeg dw        0                        ; adresa zaá†tku bufferu sektorñ
SektESeg dw        0                        ; adresa konce bufferu sektorñ
SektMax  dw        0                        ; maxim†ln° poáet sektorñ v bufferu
SektSeg  dw        0                        ; segment aktu†ln°ho bufferu sektorñ
SektUkaz dw        0                        ; ukazatel dat v aktu†ln°m sektoru
CitSekt  dw        0                        ; á°taá poátu sektorñ

CitSynch dw        0                        ; á°taá synchronizaán°ch sektorñ
CitByte  db        0                        ; á°taá bajtñ sektoru

Soubor   db        'POKUS1',0
Soubor2  db        'POKUS2',0

KeyBreak db        0                        ; p©°znak p©eru®en° z kl†vesnice
Citac08  dw        0                        ; á°taá hodin INT 08h

; ------ z†hlav° sektoru (10 bajtñ)

         EVEN
Zahlavi  label     byte
TimeBeg  dd        0                        ; absolutn° áas zaá†tku nahr†vky
TimeDel  dw        0                        ; dÇlka celÇ nahr†vky (sek.)
AktBlok  dw        0                        ; aktu†ln° á°slo bloku
AktSekt  db        0                        ; á°slo aktu†ln°ho sektoru
InfBlok  db        0                        ; informace o organizaci blokñ

FileOff  dw        -1                       ; offset prvn°ho souboru v bloku

; ------ datovò buffer souborñ (velikost pro 1 datovò blok = 289*180 B)

BuffSeg  dw        0                        ; segment bufferu souborñ
BuffNum  dw        0                        ; poáet bajtñ v bufferu souborñ

; ------ mapa vadnòch sektorñ

ErrMap   db        289 dup(-1)              ; 0=sektor je OK, -1=vadnò sektor
ErrCit   dw        289                      ; á°taá vadnòch sektorñ

Param    db        0                        ; parametry
                                            ;  bit 0: 1=prov†d° se korekce 1
                                            ;  bit 1: 1=prov†d° se korekce 2
                                            ;  bit 2: 1=neuloëen prac. soubor 1
                                            ;  bit 3: 1=neuloëen prac. soubor 2

; ------ pracovn° soubory na disku

SoubCnf  db    'STREAMER.CNF',MAXF-12 dup(0) ; konfiguraán° soubor STREAMER.CNF
SoubFil1 db    'STREAMER.$$1',MAXF-12 dup(0) ; seznam souborñ disku STREAMER.$$1
SoubFil2 db    'STREAMER.$$2',MAXF-12 dup(0) ; seznam souborñ strm. STREAMER.$$2
SoubFil3 db    'STREAMER.$$3',MAXF-12 dup(0) ; uschovanò p©ij. blok STREAMER.$$3

; ------ konfigurace programu



; ------ texty

KorTxt1  db        13,10,'Oprava 1 ..... $'
KorTxt2  db        13,10,'Oprava 2 ..... $'
KorTxt3  db        13,10,'Chyby ........ $'
KorTxt4  db        13,10,13,10,'$'

CitKor1  dw        0                        ; á°taá korekc° 1
CitKor2  dw        0                        ; á°taá korekc° 2
CitChyb  dw        0                        ; á°taá neopravitelnòch chyb

MemTxt   db        'CHYBA - nedostatek pameti ke spusteni programu !',13,10,'$'

; ------ parametry disku

AktDisk  db        0                        ; aktivn° disk
BlokSekt dw        0                        ; poáet sektorñ na alokaán° blok
SektByte dw        0                        ; poáet bajtñ na sektor
BlokByte dd        0                        ; poáet bajtñ na alokaán° blok
DiskFree dd        0                        ; voln† kapacita disku
DiskSumm dd        0                        ; celkov† kapacita disku
DiskSumC dw        0                        ; obsazen† kapacita disku (blokñ)
                                            ;  (min. 40 - pro indikaci áten°)
DiskSumR dw        0                        ; á°taá naátenòch blokñ disku

; ------ buffer jmÇna souboru

FilePthN dw        0                        ; dÇlka textu adres†©e + soubor
FilePath db        MAXF+2 dup(0)            ; buffer adres†©e + soubor

AllRoot  db        'C:\'
All      db        '*.*',0
TextStr  db        'STREAMER'

AdrHlp   dw        offset TextHlp0          ; adresa textu n†povàdy

SrcIndxE dw        0                        ; offset konce bufferu indexñ
SrcIndx  dd        50 dup(0)                ; buffer indexñ pro hled†n° souborñ

TextFre1 db        11,' B volne z '
TextFil1 db        16,' souboru zabira '
TextFil2 db        2,' B'
DskTxtC  db        10,'<POD--ADR>'
DskTxtD  db        10,'<NAD--ADR>'
TextSel1 db        9,'oznaceno '
TextSel2 db        9,' souboru/'
TextReq1 db        20,'pozadovana kapacita '
TextReq2 db        14,'delka zaznamu '
TextReq3 db        6,' hod, '
TextReq4 db        6,' min, '
TextReq5 db        4,' sek'
LicTxt1  db        ' Video Streamer V1.00 '
LicTxt2  db        ' (c) Miroslav Nemecek '

TextHlp0 db        0,0,0

TextHlp1 db        0
         db        47,'Nacitam strukturu disku ',0
TextHl11 db        ' ',0,': '
TextHl12 db        '∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞'
         db        15,'<ESC>=preruseni'

; ------ barvy

Color1   db        1bh                      ; z†kladn° barva okna
Color2   db        1eh                      ; vysv°cen† barva okna
Color3   db        30h                      ; barva kurzoru
Color4   db        3eh                      ; kurzor na vysv°cenÇ poloëce
ColorH1  db        70h                      ; bàën† barva okna n†povàdy
ColorH2  db        74h                      ; vysv°cen† barva n†povàdy

; ------ tabulka DTA

         EVEN
DTA      label     byte
         db        15h dup(?)
DTAAtrib db        ?                        ; (1) atributy nalezenÇho souboru
DTATime  dw        ?                        ; (2) áas nalezenÇho souboru
DTADate  dw        ?                        ; (2) datum nalezenÇho souboru
DTASize  dd        ?                        ; (4) velikost nalezenÇho souboru
DTAName  db        13 dup(?)                ; (13) jmÇno nalez. souboru ASCIIZ
         db        ?                        ; zarovn†n° na sudou adresu

; ------ definice seznamñ

DatSegm  dw        0                        ; zaá†tek datovÇho segmentu
DatFre   dw        0                        ; konec volnÇho m°sta v dat.segmentu
DatMax   dw        0                        ; maxim†ln° konec datovÇho segmentu

DatParm  db        0                        ; parametry seznamñ
                                            ;   b0: 1=aktivn° pravÇ okno (str.)

DatParmL db        b0                       ; t©°dàn° seznamu L (disk)
                                            ;      b0: 1=t©°dàn° podle jmÇna
                                            ;      b1: 1=t©°dàn° podle p©°pony
                                            ;      b2: 1=t©°dàn° podle velikosti
                                            ;      b3: 1=t©°dàn° podle data+áasu
                                            ;      b4: 1=adres†© se net©°d°
                                            ;      b5: 1=sestupnÇ t©°dàn° adres.

DatParmR db        b0                       ; t©°dàn° seznamu R (streamer)
                                            ;      b0: 1=t©°dàn° podle jmÇna
                                            ;      b1: 1=t©°dàn° podle p©°pony
                                            ;      b2: 1=t©°dàn° podle velikosti
                                            ;      b3: 1=t©°dàn° podle data+áasu
                                            ;      b4: 1=adres†© se net©°d°
                                            ;      b5: 1=sestupnÇ t©°dàn° adres.

         EVEN

; ------ definice levÇho okna - disk

DatDefL  db        SeznSum dup(?)           ; definice seznamu disku

; ------ definice pravÇho okna - streamer

DatDefR  db        SeznSum dup(?)           ; definice seznamu streameru

; ------ z†sobn°k

         dw        800h dup(?)
Zasob    label     word                     ; konec z†sobn°ku

Code     ENDS

         END       Start

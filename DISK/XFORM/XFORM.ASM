
; N vratov‚ k¢dy (zat¡m je¨tˆ neudˆl no !!!)
;       0 = nen¡ nainstalov n
;       1 = je v klidu
;       2 = ‡ek  na vlo‘en¡ diskety
;       3 = form tuje disketu
;       4 = ‡ek  na vyjmut¡ diskety - bez chyby
;       5 = ‡ek  na vyjmut¡ diskety - s chybou

;PUBLIC   TESTBOD                            ; testovac¡ bod pro DEBUGGER

DENXFLOP EQU       4                        ; den souboru XFLOP.COM
MESXFLOP EQU       4                        ; mˆs¡c souboru XFLOP.COM

DEMOTRK  EQU       50                       ; dˆlic¡ stopa pro DEMO a SHAREWARE

; -----------------------------------------------------------------------------
; P©ep¡na‡e p©ekladu:
;
;DEMO     EQU       1                        ; demo verze
;SHARE    EQU       1                        ; shareware verze
;DEBUG    EQU       1                        ; ladic¡ re‘im
; -----------------------------------------------------------------------------

KLIC1    EQU       'XF'                     ; identifik tor 1 (AX)
KLIC2    EQU       'OR'                     ; identifik tor 2 (BX)
KLIC3    EQU       'M?'                     ; identifik tor 3 (CX)
KLIC4    EQU       'OK'                     ; identifik tor 4 (v˜stup v AX)

bit0     EQU       1
bit1     EQU       2
bit2     EQU       4
bit3     EQU       8
bit4     EQU       10h
bit5     EQU       20h
bit6     EQU       40h
bit7     EQU       80h
HI       EQU       256

; -----------------------------------------------------------------------------
;
; Mˆ©en¡ rozsahu GAP mezery:
;  ....... mechanika 5 ot ‡ek/sekundu
;  8 sektor–: I1, G6 a‘ G236, O250
;  9 sektor–: I1, G6 a‘ G135, O250
; 10 sektor–: I1, G6 a‘ G56, O250
; --------------------------------
; 11 sektor–: I1, G6 a‘ G118, O300
; 12 sektor–: I1, G6 a‘ G55, O300
; 13 sektor–: I2, G1 a‘ G3, O300
; --------------------------------
; 18 sektor–: I1, G6 a‘ G127, O500
; 19 sektor–: I1, G6 a‘ G88, O500
; 20 sektor–: I1, G6 a‘ G53, O500
; 21 sektor–: I1 a‘ I2, G6 a‘ G22, O500
;
;  ........ mechanika 6 ot ‡ek/sekundu (O250: 5208,
;  7 sektor–:     max. G198, O250 (obsazeno 5206)
;  8 sektor–:     max. G88, O250 (obsazeno 5208)
;  9 sektor–:     max. G5, O250 (obsazeno 5206)
; -----------------------------------------------------------------------------
; Z maxim ln¡ hodnoty GAP vypo‡tena pevn  ‡ st sektoru na hlavi‡ku 62 bajt– !!!!
; -----------------------------------------------------------------------------
; V˜po‡ty obsazen‚ ‡ sti stopy:
;
;    250000/8/5 = 6250
;  10*(512+62) + 9*56 = 6244
;   9*(512+62) + 8*135 = 6246
;   8*(512+62) + 7*236 = 6244
;
;    300000/8/5 = 7500
;  11*(512+62) + 10*118 = 7494
;  12*(512+62) + 11*55 = 7493
;  13*(512+62) + 12*3 = 7498
;
;    500000/8/5 = 12500
;  18*(512+62) +  17*127 = 12491
;  19*(512+62) + 18*88 = 12490
;  20*(512+62) + 19*53 = 12487
;  21*(512+62) + 20*22 = 12494
;
;   1000000/8/5 = 25000
; -----------------------------------------------------------------------------

TIMEOUT  EQU       2*18                     ; doba pro TIME-OUT (v 1/18 sekund)

MAXERR   EQU       20                       ; maxim ln¡ po‡et blok– chyb

 IFDEF   DEBUG
KORIG    EQU       0
 ELSE
KORIG    EQU       -(103h-5ch)              ; korekce adres programu
 ENDIF

; ------ typy mechanik

M360     EQU       1                        ; mechanika 360 KB
M120     EQU       2                        ; mechanika 1.2 MB
M720     EQU       3                        ; mechanika 720 KB
M144     EQU       4                        ; mechanika 1.44 MB
M288     EQU       5                        ; mechanika 2.88 MB

DMAW     EQU       4ah                      ; povel pro z pis DMA
DMAR     EQU       46h                      ; povel pro ‡ten¡ DMA
DMAV     EQU       42h                      ; povel pro verifikaci DMA

MAXSEKT  EQU       128                      ; maxim ln¡ po‡et sektor–
                                            ;  128*512 = 65536 (max. DMA)
                                            ;  128*4 = 512 (max. polo‘ek)
Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

Start:   jmp       Init

RezBeg   label     byte                     ; za‡ tek rezidentn¡ ‡ sti

; -----------------------------------------------------------------------------
;        parametry rezidentni obsluhy
; -----------------------------------------------------------------------------

; ------ uschovan‚ adresy p©eru¨en¡

Old08    dd        0                        ; p–vodn¡ adresa INT 08h
Old0e    dd        0                        ; p–vodn¡ adresa INT 0Eh
Old40    dd        0                        ; p–vodn¡ adresa INT 40h

LastErr  db        0                        ; posledn¡ chyba
                                            ;   0 = OK
                                            ;   1 = TIME-OUT od INT 0Eh
                                            ;   2 = TIME-OUT p©¡jmu stavu od ©adi‡e
                                            ;   3 = TIME-OUT vysl n¡ povelu na ©adi‡
                                            ;   4 = p©ekro‡en po‡et bajt– stavu (7) od ©adi‡e
                                            ;   5 = chyba vystaven¡ hlav (nen¡ stopa 0)
                                            ;   6 = mechanika nep©ipravena
                                            ;   7 = nenalezena stopa 0
                                            ;   8 = sektor nenalezen
                                            ;   9 = disketa chr nˆna proti z pisu
                                            ;  (10 = p©ete‡en¡ p©enosu DMA)
                                            ;  11 = chyba dat sektoru (CRC)
                                            ;  12 = nesouhlas¡ hlavi‡ka sektoru
                                            ;  13 = chyba resetov n¡ ©adi‡e

                                            ; 255 = jin  chyba (chyba operace)

DatBeg   label     byte                     ; za‡ tek dat k p©enesen¡

; ------ parametry pro operaci

RParam   db        0                        ; rezidentn¡ parametry 1
                                            ;   bit 0: 1=pou‘¡t zvukovou indikaci
                                            ;   bit 1: 1=form tov n¡ v¡ce disket
                                            ;   bit 2: 1=neprov dˆt verifikaci
                                            ;   bit 3: 1=form tov n¡ aktivn¡
                                            ;   bit 4: 1=prob¡h  form tov n¡ diskety
                                            ;   bit 5: 1=po‘adavek p©eru¨en¡ form tov n¡
                                            ;   bit 6: 1=dvoj¡ krokov n¡ diskety
                                            ;   bit 7: 1=‡asov n¡ portem 61h

RParam2  db        0                        ; rezidentn¡ parametry 2
                                            ;   bit 0: 1=aktivn¡ intern¡ obsluha
                                            ;   bit 1: 1=vadn˜ BOOT
                                            ;   bit 2: 1=vadn  FAT1
                                            ;   bit 3: 1=vadn  FAT2
                                            ;   bit 4: 1=vadn˜ ROOT
                                            ;   bit 5: 1=byla chyba v datech
                                            ;   bit 6: 1=z kaz p©eru¨en¡ operace
                                            ;   bit 7: 1=p©i¨lo p©eru¨en¡ INT 0Eh

RParam3  db        0                        ; rezidentn¡ parametry 3
                                            ;   bit 0: 1=ulo‘it LABEL
                                            ;   bit 1: 1=ulo‘it soubor XFLOP.COM
                                            ;   bit 2: 1=nucen  v˜mˆna diskety
                                            ;   bit 3: 1=LABEL se inkrementuje

LabEnd   dw        offset BootLabl+KORIG    ; adresa posledn¡ ‡¡slice ‡¡sla LABEL
LabTime  dw        1                        ; ‡as pro LABEL
LabDate  dw        1                        ; datum pro LABEL

; ------ polo‘ka XFLOP.COM

XFlopNam db        'XFLOP   COM'            ; jm‚no souboru XFLOP.COM
XFlopTim dw        1*bit3*HI + 0*bit5 + 0   ; ‡as souboru XFLOP.COM
XFlopDat dw        (1995-1980)*bit1*HI + MESXFLOP*bit5 + DENXFLOP ; datum souboru XFLOP.COM
XFlopBlk dw        2                        ; aloka‡n¡ blok s programem XFLOP.COM
         dw        512                      ; velikost programu XFLOP.COM
XFlopAbs dw        -1                       ; absolutn¡ sektor s XFLOP.COM


Disk     db        -1                       ; ‡¡slo disku (0=A:, 1=B:)
DiskMask db        bit0                     ; maska ‡¡sla disku (bit0 nebo bit1)


TypDisk  db        1                        ; typ disku
                                            ;   1 = 360 KB (5 1/4")
                                            ;   2 = 1.2 M (5 1/4")
                                            ;   3 = 720 K (3 1/2")
                                            ;   4 = 1.44 M (3 1/2")
                                            ;   5 = 2.88 M (3 1/2")

TestWrit dw        0                        ; po‡et testovac¡ch z pis–
Rate     db        -1                       ; p©enosov  rychlost 0 a‘ 3
                                            ;    0 = 500 Kb/s
                                            ;    1 = 300 Kb/s
                                            ;    2 = 250 Kb/s
                                            ;    3 = 1000 Kb/s

; ------ fyzick‚ parametry diskety

IFDEF    DEMO
DemoStop db        DEMOTRK                  ; DEMO stopa
ENDIF

JmenKap  dw        -1                       ; jmenovit  kapacita (v KB)
Stop     db        -1                       ; po‡et stop
         db        0                        ; doplnˆk na slovo

Sektoru  db        -1                       ; po‡et sektor– na stopu
         db        0                        ; doplnˆk na slovo

Stran    db        -1                       ; po‡et stran
         db        0                        ; doplnˆk na slovo

SlideX   db        -1                       ; odsazov n¡ mezi stranami
SlideY   db        -1                       ; odsazov n¡ mezi stopami
Interl   db        -1                       ; prokl d n¡ sektor–
Gap      dw        -1                       ; mezisektorov  mezera

; ------ logick‚ parametry diskety

Cluster  db        -1                       ; po‡et sektor– na aloka‡n¡ blok
         db        0                        ; doplnˆk na slovo

Root     dw        -1                       ; po‡et sektor– na ROOT
MediaB   db        0f0h                     ; bajt popisova‡e m‚dia
FillCh   db        0f6h                     ; pln¡c¡ bajt dat diskety
DatSekt  dw        0                        ; po‡ te‡n¡ datov˜ sektor (absolutnˆ)

; ------  odvozen‚ parametry

CelkSekt dw        0                        ; celkov˜ po‡et sektor– diskety
FATSekt  dw        1                        ; po‡et sektor– na FAT
NumClust dw        0                        ; po‡et datov˜ch aloka‡n¡ch blok–
Nevyuzit db        0                        ; po‡et nevyu‘it˜ch sektor–

DatEnd   label     byte                     ; konec dat k p©enesen¡

; ------ aktu ln¡ ukazatele operace

AbsSekt  dw        0                        ; absol. ‡¡slo sektoru po‡ tku stopy
NStrana  db        -1                       ; zpracovan  strana
AStrana  db        0                        ; aktivn¡ strana
NStopa   db        -1                       ; zpracovan  stopa
AStopa   db        0                        ; aktivn¡ stopa (form tovan )
AOper    db        0                        ; aktivn¡ operace (pro indikaci)
                                            ;    0=je v klidu (nic neform tuje)
                                            ;    1=‡ek  na vlo‘en¡ diskety
                                            ;    2=‡ek  na vyjmut¡ diskety
                                            ;    3=form tov n¡
                                            ;    4=verifikace
                                            ;    5=z pis
                                            ;    6=‡ten¡
                                            ;    7=DEMO ukazatel operace

; ------ uschovan˜ ukazatel z sobn¡ku

RegSP    dw        0                        ; SP
RegSS    dw        0                        ; SS

; ------ buffery

BuffStat db        7 dup(0)                 ; buffer stavu od ©adi‡e

BuffSekt dw        Buffer+KORIG             ; adresa bufferu sektoru
Zasob    dw        Buffer+2*512-2+KORIG     ; adresa z sobn¡ku (konec)

; ------ mapa chyb
; Struktura:
;        0: (1) po‡et n sleduj¡c¡ch vadn˜ch blok– (0=konec tabulky)
;        1: (2) ‡¡slo po‡ te‡n¡ho vadn‚ho bloku
ErrMEnd  dw        ErrMap+KORIG             ; ukl dac¡ adresa do tabulky
ErrMap   db        MAXERR*3 dup(0)          ; mapa chyb
         db        0                        ; p©¡znak konce tabulky

ErrSekt  db        (MAXSEKT+7)/8 dup(0)     ; mapa vadn˜ch sektor–
ErrSekt0 label     byte

IdentBeg label     byte                     ; za‡ tek k testu identifikace
;þ
; -----------------------------------------------------------------------------
;        obsluha INT 13h
; -----------------------------------------------------------------------------

Int13    PROC      FAR

; ------ test instalace programu

         cmp       ax,KLIC1                 ; identifik tor v AX
         jne       Int131
         cmp       bx,KLIC2                 ; identifik tor v BX
         jne       Int131
         cmp       cx,KLIC3                 ; identifik tor v CX
         jne       Int131
         mov       ax,KLIC4                 ; potvrzen¡ instalace v pamˆti
         push      cs
         pop       es                       ; ES <- segment programu
         jmp       short Int133

; ------ blokov n¡ obsluhy, je-li aktivn¡ rezidentn¡ obsluha

Int131:  or        dl,dl                    ; je disketa ?
         js        Int138                   ; nen¡ disketa
         test      byte ptr cs:[RParam+KORIG],bit3 ; je form tov n¡ aktivn¡ ?
         jz        Int134                   ; nen¡ aktivn¡
         cmp       ah,8
         je        Int138                   ; funkce 8 je povolen  (parametry)
         cmp       ah,16h                   ; test v˜mˆny disku
         mov       ah,80h                   ; p©¡znak nep©ipravenosti
         jne       Int133                   ; nen¡ vymˆnˆn  disketa
Int132:  mov       ah,6                     ; chyba - disketa vymˆnˆna
Int133:  stc
         sti
         ret       2

; ------ vnucen  v˜mˆna diskety

Int134:  cmp       dl,cs:[Disk+KORIG]       ; je to aktivn¡ disk ?
         jne       Int138                   ; nen¡ to aktivn¡ disk
         test      byte ptr cs:[RParam3+KORIG],bit2 ; je nucen  v˜mˆna disku ?
         jz        Int138                   ; nen¡ nucen  v˜mˆna disku

         cmp       ah,16h
         je        Int132                   ; disketa vymˆnˆna
         cmp       ah,2
         jb        Int138
         cmp       ah,5
         jae       Int138
                                          ;* je operace ‡ten¡, z pis, verifikace
Int135:  and       byte ptr cs:[RParam3+KORIG],not bit2 ; zru¨en¡ nucen‚ v˜mˆny
         jmp       short Int132             ; disketa vymˆnˆna

Int138:  jmp       BootIntY                 ; obsluha roz¨¡©en˜ch form t–

Int13    ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 08h
; -----------------------------------------------------------------------------

Int08    PROC      FAR

; ------ test, zda je aktivn¡ vlastn¡ form tov n¡

         test      byte ptr cs:[RParam+KORIG],bit3 ; je form tov n¡ aktivn¡ ?
         jz        Int089                   ; form tov n¡ nen¡ aktivn¡

; ------ nulov n¡ ‡¡ta‡e BIOS pro vypnut¡ motoru

         push      ax
         push      ds

         xor       ax,ax
         mov       ds,ax
         mov       byte ptr ds:[440h],38    ; ‡¡ta‡ pro vypnut¡ motoru BIOS

         pop       ds
         pop       ax

         pushf
         call      dword ptr cs:[Old08+KORIG] ; p–vodn¡ obsluha INT 08h
         call      FlipInt                  ; p©ep¡n n¡ proces–
         iret

Int089:  jmp       dword ptr cs:[Old08+KORIG] ; p–vodn¡ obsluha INT 08h

Int08    ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 40h
; -----------------------------------------------------------------------------

Int40    PROC      FAR

         or        dl,dl                    ; je disketa ?
         js        Int142                   ; nen¡ disketa
         test      byte ptr cs:[RParam+KORIG],bit3 ; je form tov n¡ aktivn¡ ?
         jz        Int142                   ; nen¡ aktivn¡
         mov       ah,80h                   ; p©¡znak nep©ipravenosti
         stc
         sti
         ret       2

Int142:  jmp       dword ptr cs:[Old40+KORIG] ; p–vodn¡ obsluha INT 40h

Int40    ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 0Eh
; -----------------------------------------------------------------------------

Int0E    PROC      FAR

         push      ax
         or        byte ptr cs:[RParam2+KORIG],bit7 ; p©¡znak p©eru¨en¡ INT 0Eh
         mov       al,66h
         out       [20h],al                 ; uvolnˆn¡ ©adi‡e p©eru¨en¡
         pop       ax
         call      FlipInt                  ; p©ep¡n n¡ proces–
         iret

Int0E    ENDP

; -----------------------------------------------------------------------------
;        z mˆna registr– a obsluhy (nemˆnit po©ad¡ registr– v z sobn¡ku !)
; -----------------------------------------------------------------------------

; ------ p©epnut¡ na intern¡ obsluhu z obsluhy p©eru¨en¡

FlipInt: pushf
         test      byte ptr cs:[RParam2+KORIG],bit0 ; je intern¡ obsluha ?
         jnz       FlipFlp9                 ; je ji‘ intern¡ obsluha

; ------ test, zda neprob¡h  nˆjak  obsluha p©eru¨en¡

         cli
         push      ax
         mov       al,bit3+bit1+bit0        ; povel pro ‡ten¡ registru obsluh
         out       [20h],al                 ; vysl n¡ povelu
         jmp       short $+2
         jmp       short $+2                ; mal  prodleva
         in        al,[20h]                 ; ‡ten¡ registru obsluh p©eru¨en¡
         or        al,al                    ; prob¡h  nˆjak  obsluha ?
         pop       ax
         jnz       FlipFlp9                 ; prob¡h  nˆjak  obsluha - z kaz

         popf

FlipFlop PROC      NEAR

; ------ £schova registr– do star‚ho z sobn¡ku

         pushf
         cli
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es

; ------ z mˆna z sobn¡k–

         mov       ax,ss
         xchg      ax,cs:[RegSS+KORIG]
         mov       ss,ax
         xchg      sp,cs:[RegSP+KORIG]
         xor       byte ptr cs:[RParam2+KORIG],bit0 ; zmˆna p©¡znaku obsluhy

; ------ n vrat registr– z nov‚ho z sobn¡ku

         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
FlipFlp9:popf
         ret

FlipFlop ENDP

; -----------------------------------------------------------------------------
;        start operace form tov n¡ (dodr‘ov no DS=ES=CS !)
; -----------------------------------------------------------------------------
;þ
; ------ instalace obsluhy INT 0Eh

FStart:  call      Inst0E                   ; instalace obsluhy INT 0Eh
         and       byte ptr ds:[RParam2+KORIG],not bit6 ; nen¡ z kaz p©eru¨en¡

; ------ ‡ek n¡ na vlo‘en¡ nov‚ diskety

         call      Reset                    ; resetov n¡ disku
         call      WaitIn                   ; ‡ek n¡ na vlo‘en¡ nov‚ diskety
         jnc       FStart1
         jmp       FStart7                  ; p©eru¨en¡ form tov n¡

; ------ start form tov n¡ jedn‚ diskety - p©¡prava ukazatel–

FStart1: or        byte ptr ds:[RParam+KORIG],bit4 ; p©¡znak form tov n¡ diskety
         mov       byte ptr ds:[LastErr+KORIG],0 ; nen¡ ‘ dn  chyba
         and       byte ptr ds:[RParam2+KORIG],not bit1+bit2+bit3+bit4+bit5 ; nulov n¡ chyb
         mov       byte ptr ds:[AStopa+KORIG],0 ; aktivn¡ stopa
         mov       word ptr ds:[AbsSekt+KORIG],0 ; ukazatel absolutn¡ho ‡¡sla sektoru
         mov       byte ptr ds:[NStopa+KORIG],-1 ; posledn¡ zform tovan  stopa
         mov       byte ptr ds:[NStrana+KORIG],-1 ; posledn¡ zform tovan  strana
         or        byte ptr ds:[RParam3+KORIG],bit2 ; nucen  v˜mˆna diskety

; ------ inkrementace jmenovky a s‚riov‚ho ‡¡sla

         test      byte ptr ds:[RParam3+KORIG],bit3 ; inkrementuje se LABEL ?
         jz        FStrt12                  ; neinkrementuje se
         call      LabInc                   ; inkrementace jmenovky a s‚r. ‡¡sla
         and       byte ptr ds:[RParam3+KORIG],not bit3 ; LABEL se neinkrementuje

; ------ vynulov n¡ tabulky vadn˜ch blok– (DS=ES !)

FStrt12: mov       di,offset ErrMap+KORIG   ; mapa vadn˜ch blok–
         mov       ds:[ErrMEnd+KORIG],di    ; ukazatel tabulky
         xor       ax,ax                    ; AX <- 0
         mov       cx,MAXERR*3              ; velikost mapy
         cld
         rep       stosb                    ; vymaz n¡ mapy vadn˜ch blok–

; ------ rozbˆh motoru

         call      ZapDisk                  ; zapnut¡ disku
         mov       cx,18
         call      Cekej                    ; prodleva na rozbˆh motoru
         call      Reset                    ; resetov n¡ disku

; ------ test, zda je p©eru¨en¡ form tov n¡

         call      TstBreak                 ; je p©eru¨en¡ ?
         jc        FStart5                  ; je p©eru¨en¡ form tov n¡

; ------ nastaven¡ aktivn¡ stopy

FStart2: mov       byte ptr ds:[AStrana+KORIG],0 ; aktivn¡ strana
         call      Seek                     ; vystaven¡ na aktivn¡ stopu

; ------ test, zda byla disketa vyjmuta

FStart3: call      TestXchg                 ; test v˜mˆny diskety
         jc        FStart5                  ; disketa byla vyjmuta

; ------ zform tov n¡ jedn‚ stopy (i se z pisy dat)

         call      FForm                    ; zform tov n¡ stopy

; ------ test, zda je disketa chr nˆna proti z pisu

         cmp       byte ptr ds:[LastErr+KORIG],9 ; je ochrana proti z pisu ?
         je        FStart5                  ; disketa chr nˆna proti z pisu

; ------ test, zda je p©eru¨en¡ form tov n¡

         call      TstBreak                 ; je p©eru¨en¡ ?
         jc        FStart4                  ; je p©eru¨en¡ form tov n¡

; ------ ukazatel zpracovan˜ch stop

         mov       al,ds:[AStopa+KORIG]     ; aktivn¡ stopa
         mov       ds:[NStopa+KORIG],al     ; zpracovan  stopa
         mov       al,ds:[AStrana+KORIG]    ; aktivn¡ strana
         mov       ds:[NStrana+KORIG],al    ; zpracovan  strana

; ------ posun absolutn¡ho ‡¡sla sektoru

         mov       ax,word ptr ds:[Sektoru+KORIG] ; po‡et sektor– na stopu
         add       ds:[AbsSekt+KORIG],ax    ; posun ‡¡sla sektoru

; ------ zv˜¨en¡ ‡¡sla strany

         inc       byte ptr ds:[AStrana+KORIG] ; zv˜¨en¡ aktivn¡ strany
         mov       al,ds:[AStrana+KORIG]    ; aktivn¡ strana
         cmp       al,ds:[Stran+KORIG]      ; jsou ji‘ v¨echny strany ?
         jb        FStart3                  ; nejsou v¨echny - dal¨¡ strana

; ------ zv˜¨en¡ ‡¡sla stopy

         inc       byte ptr ds:[AStopa+KORIG] ; zv˜¨en¡ aktivn¡ stopy
         mov       al,ds:[AStopa+KORIG]     ; aktivn¡ stopa
         cmp       al,ds:[Stop+KORIG]       ; jsou ji‘ v¨echny stopy ?
         jb        FStart2                  ; nejsou v¨echny - dal¨¡ stopa
         or        byte ptr ds:[RParam3+KORIG],bit3 ; LABEL se inkrementuje

; ------ z pis chyb FAT 1 a FAT 2 (+ z pis ‡¡sla bloku XFLOP.COM do FAT)

FStart4: or        byte ptr ds:[RParam2+KORIG],bit6 ; z kaz p©eru¨en¡ operace
         call      TestXchg                 ; byla disketa vyjmuta ?
         jc        FStart5                  ; byla vyjmuta
         mov       byte ptr ds:[AOper+KORIG],0 ; aktivn¡ operace - nic se nedˆje
         mov       ax,1                     ; absolutn¡ sektor pro FAT1
         call      WritErr                  ; z pis tabulky chyb FAT 1
         call      TestXchg                 ; byla disketa vyjmuta ?
         jc        FStart5                  ; byla vyjmuta
         mov       ax,ds:[FATSekt+KORIG]    ; po‡et sektor– na FAT
         inc       ax                       ; p©i‡ten¡ BOOT sektoru
         call      WritErr                  ; z pis tabulky chyb FAT 2
         and       byte ptr ds:[RParam2+KORIG],not bit6 ; konec z kazu p©eru¨en¡

; ------ konec form tov n¡ jedn‚ diskety

FStart5: mov       byte ptr ds:[AStopa+KORIG],0 ; aktivn¡ stopa
         call      Seek                     ; vystaven¡ hlav na za‡ tek
         and       byte ptr ds:[RParam+KORIG],not bit4 ; konec form tov n¡ diskety

; ------ ‡ek n¡ na vyjmut¡ diskety z mechaniky

FStart6: cmp       byte ptr ds:[TypDisk+KORIG],M360 ; mechanika 360K
         je        FStart7                  ; nen¡ podporov na v˜mˆna
         call      WaitOut                  ; ‡ek n¡ na vyjmut¡ diskety z mechaniku

; ------ ukon‡en¡ form tov n¡ p©i p©eru¨en¡ nebo nen¡-li v¡c disket

FStart7: call      TstBreak                 ; je p©eru¨en¡ ?
         jc        FStart76                 ; p©eru¨en¡ operace
FStart74:test      byte ptr ds:[RParam+KORIG],bit1 ; je v¡ce disket ?
         jnz       FStart8                  ; je v¡ce disket
FStart76:and       byte ptr ds:[RParam+KORIG],not bit3+bit5 ; p©eru¨en¡ form tov n¡

; ------ vypnut¡ motor– mechanik

FStart8: mov       byte ptr ds:[AOper+KORIG],0 ; je v klidu
         call      VypDisk                  ; vypnut¡ disk–
         call      DInst0E                  ; odinstalov n¡ obsluhy INT 0Eh

; ------ nulov n¡ ‡¡ta‡e pro vypnut¡ motoru BIOS

         push      ax
         push      ds

         xor       ax,ax
         mov       ds,ax                    ; DS <- 0
         mov       byte ptr ds:[440h],38    ; ‡¡ta‡ pro vypnut¡ motoru BIOS
         and       byte ptr ds:[43fh],not 0fh ; nulov n¡ zapnut¡ motor–
         and       byte ptr ds:[43eh],not 0fh ; pot©ebn  rekalibrace
         and       word ptr ds:[490h],not bit4 + HI*bit4 ; m‚dium nezn m‚

         pop       ds
         pop       ax

         call      FlipFlop                 ; rezidentn¡ obsluha
         jmp       FStart                   ; pokra‡ov n¡ dal¨¡ disketou

; -----------------------------------------------------------------------------
;        ‡ek n¡ na vlo‘en¡ diskety (CY=p©eru¨en¡)
; -----------------------------------------------------------------------------

WaitIn   PROC      NEAR

; ------ p©¡znak, ‘e se ‡ek  na vlo‘en¡ diskety

         mov       byte ptr ds:[AOper+KORIG],1 ; ‡ek  na vlo‘en¡ diskety
         mov       byte ptr ds:[AStopa+KORIG],0 ; aktivn¡ stopa

; ------ test, zda je p©eru¨en¡ form tov n¡

WaitIn2: call      TstBreak                 ; test p©eru¨en¡
         jc        WaitIn9                  ; je p©eru¨en¡ form tov n¡

; ------ zapnut¡ disku

         call      ZapDisk                  ; zapnut¡ disku

; ------ mal  prodleva (bliknut¡)

         mov       cx,2
         call      Cekej                    ; ‡ek n¡

; ------ vystaven¡ hlav (posun na jinou stopu)

         xor       byte ptr ds:[AStopa+KORIG],1 ; zmˆna stopy 0/1
         call      Seek                     ; vystaven¡ hlav na novou stopu

; ------ test, zda je vlo‘ena disketa

         call      TestXchg                 ; test v˜mˆny diskety
         jnc       WaitIn9                  ; disketa je vlo‘ena (-> NC)

; ------ vypnut¡ mechaniky

         call      VypDisk                  ; vypnut¡ disku

; ------ prodleva (tma mezi bliknut¡mi)

         mov       cx,26
         call      Cekej                    ; prodleva
         jmp       short WaitIn2            ; znovu zapnut¡

WaitIn9: ret

WaitIn   ENDP

; -----------------------------------------------------------------------------
;        ‡ek n¡ na vyjmut¡ diskety
; -----------------------------------------------------------------------------

WaitOut  PROC      NEAR

; ------ synchronizace na hodiny (aby prvn¡ t¢n nebyl zkr cen˜)

         mov       cx,1
         call      Cekej                    ; synchronizace na hodiny

; ------ test, zda je pot©eba ‡ekat na vyjmut¡ diskety

         test      byte ptr ds:[RParam2+KORIG],bit1+bit2+bit3+bit4+bit5 ; chyba ?
         jnz       WaitOut2                 ; byla chyba - bude se hl sit
         test      byte ptr ds:[RParam+KORIG],bit0+bit1 ; indikace nebo v¡ce disket ?
         jz        WaitIn9                  ; nen¡ pot©eba ‡ekat na vyjmut¡
WaitOut2:mov       byte ptr ds:[AOper+KORIG],2 ; ‡ek  na vyjmut¡ diskety

; ------ test, zda je p©eru¨en¡ operace

WaitOut3:call      TstBreak                 ; je p©eru¨en¡ ?
         jc        WaitIn9                  ; je p©eru¨en¡

; ------ zapnut¡ disku

         call      ZapDisk                  ; zapnut¡ disku

; ------ prodleva p©i zapnut¡ (dlouh  p©i chybˆ, nen¡-li indikace)

         mov       ax,10                    ; kr tk  doba
         test      byte ptr ds:[RParam+KORIG],bit0 ; je zvukov  indikace ?
         jnz       WaitOut4                 ; je zvukov  indikace
         cmp       byte ptr ds:[LastErr+KORIG],9 ; je ochrana proti z pisu ?
         je        WaitOu32                 ; disketa chr nˆna proti z pisu
         test      byte ptr ds:[RParam2+KORIG],bit1+bit2+bit3+bit4+bit5 ; chyba ?
         jz        WaitOut4                 ; nebyla chyba
WaitOu32:mov       ax,600                   ; dlouh  doba p©i chybˆ
WaitOut4:call      WaitT                    ; prodleva (v 15 us)

; ------ test, zda byla disketa vyjmuta

         call      TestXchg                 ; byla disketa vyjmuta ?
         jc        WaitOut9                 ; byla vyjmuta

; ------ vypnut¡ disku

         call      VypDisk                  ; vypnut¡ disku

; ------ test, zda je zvukov  signalizace

         test      byte ptr ds:[RParam+KORIG],bit0
         jz        WaitOut6                 ; nen¡ zvukov  indikace

; ------ p¡pnut¡ p©i zvukov‚ signalizaci

         mov       bx,3500/5                ; vysok˜ t¢n
         test      byte ptr ds:[RParam2+KORIG],bit1+bit2+bit3+bit4+bit5 ; chyba ?
         jnz       WaitOut5                 ; byla chyba - vysok˜ t¢n
         cmp       byte ptr ds:[LastErr+KORIG],9 ; je ochrana proti z pisu ?
         je        WaitOut5                 ; disketa chr nˆna proti z pisu
         mov       bx,3500                  ; hlubok˜ t¢n
WaitOut5:in        al,[61h]
         or        al,bit0+bit1
         out       [61h],al                 ; zapnut¡ zvuku
         mov       al,0b6h
         out       [43h],al
         mov       al,bl
         out       [42h],al
         mov       al,bh
         out       [42h],al

; ------ prodleva pro znˆn¡ zvuku

         mov       cx,1
         call      Cekej                    ; prodleva pro doznˆn¡ t¢nu

; ------ vypnut¡ zvuku

         in        al,[61h]
         and       al,not bit0+bit1
         out       [61h],al

; ------ test, zda je p©eru¨en¡ operace

WaitOut6:call      TstBreak                 ; je p©eru¨en¡ ?
         jc        WaitOut9                 ; je p©eru¨en¡

; ------ prodleva mezi p¡pnut¡mi (a bliknut¡mi)

         mov       cx,4                     ; rychl‚ blik n¡ a p¡p n¡
         cmp       byte ptr ds:[LastErr+KORIG],9 ; je ochrana proti z pisu ?
         je        WaitOut8                 ; disketa chr nˆna proti z pisu
         test      byte ptr ds:[RParam2+KORIG],bit1+bit2+bit3+bit4+bit5 ; chyba ?
         jnz       WaitOut8                 ; byla chyba
         mov       cx,20                    ; pomal‚ blik n¡ a p¡p n¡ (nebyla chyba)
WaitOut8:call      Cekej                    ; prodleva
         jmp       WaitOut3                 ; dal¨¡ ‡ek n¡

WaitOut9:ret

WaitOut  ENDP

; -----------------------------------------------------------------------------
;        inkrementace jmenovky a s‚riov‚ho ‡¡sla
; -----------------------------------------------------------------------------

LabInc   PROC      NEAR

; ------ inkrementace s‚riov‚ho ‡¡sla

         add       word ptr ds:[BootSerN+KORIG],1
         adc       word ptr ds:[BootSerN+KORIG+2],0

; ------ inkrementace jmenovky

         test      byte ptr ds:[RParam3+KORIG],bit0 ; ukl d  se LABEL ?
         jz        LabInc9                  ; LABEL se neukl d 
         mov       si,ds:[LabEnd+KORIG]     ; adresa posledn¡ ‡¡slice
LabInc2: cmp       si,offset BootLabl+KORIG
         jbe       LabInc9                  ; nen¡ voln  pozice

         inc       byte ptr ds:[si]
         cmp       byte ptr ds:[si],"0"+1
         jb        LabInc6
         cmp       byte ptr ds:[si],"9"+1
         ja        LabInc6
         jb        LabInc9
         mov       byte ptr ds:[si],"0"
         dec       si
         jmp       short LabInc2

LabInc6: mov       byte ptr ds:[si],"1"
LabInc9: ret

LabInc   ENDP

; -----------------------------------------------------------------------------
;        z pis sektoru FAT s chybou (AX=absolutn¡ sektor FAT) (ES=DS !)
; -----------------------------------------------------------------------------

WritErr  PROC      NEAR

; ------ p©¡prava registr–

         mov       ds:[AbsSekt+KORIG],ax    ; absolutn¡ sektor FAT
         xor       bx,bx                    ; ukazatel ‡¡sla sektoru FAT

; ------ £schova registr–

WritErr1:push      bx                       ; relativn¡ sektor FAT

; ------ p©epo‡et absolutn¡ho sektoru na stopu, stranu a sektor

         mov       ax,ds:[AbsSekt+KORIG]    ; absolutn¡ sektor
         xor       dx,dx                    ; DX <- 0
         div       word ptr ds:[Sektoru+KORIG] ; AX <- stopa, DX <- sektor
         inc       dx
         mov       bh,dl                    ; BH <- ‡¡slo sektoru na stopˆ
         div       byte ptr ds:[Stran+KORIG] ; AL <- v lec, AH <- strana
         mov       ds:[AStrana+KORIG],ah    ; aktivn¡ strana
         mov       ds:[AStopa+KORIG],al     ; aktivn¡ stopa

; ------ vynulov n¡ bufferu sektoru

         call      NulSekt                  ; vynulov n¡ sektoru
         mov       bp,di                    ; BP <- adresa konce bufferu
         mov       di,si                    ; DI <- za‡ tek bufferu

; ------ ukazatel ‡¡sla aloka‡n¡ho bloku -> AX

         mov       ah,bl                    ; AH <- ‡¡slo sektoru FAT
         mov       al,0
         shl       ax,1                     ; offset FAT v bajtech
         shl       ax,1                     ; offset FAT v tetr d ch
         xor       dx,dx
         mov       cx,3                     ; po‡et tetr d na blok
         div       cx                       ; v˜po‡et bloku a tetr dy

; ------ p©¡prava masky a adresy

         xor       si,si                    ; st©ada‡ modifikace sektoru
         mov       cx,0ff7h                 ; maska pro tetr du 0
         or        dx,dx                    ; je zarovnan  polo‘ka ?
         jz        WritErr2                 ; je zarovnan  polo‘ka
         dec       di                       ; posun adresy
         cmp       dl,2                     ; je tetr da 2 ?
         je        WritErr2                 ; je tetr da 2
         mov       cx,0ff70h                ; maska pro tetr du 1

; ------ aloka‡n¡ blok 0

WritErr2:or        ax,ax                    ; je aloka‡n¡ blok 0 ?
         jnz       WritErr3                 ; nen¡ aloka‡n¡ blok 0
         push      ax
         mov       al,ds:[MediaB+KORIG]     ; popisova‡ m‚dia
         mov       ah,0fh
         or        ds:[di],ax
         pop       ax
         jmp       short WritErr6

; ------ aloka‡n¡ blok 1

WritErr3:cmp       ax,1
         jne       WritErr4
         or        ds:[di],0fff0h
         jmp       short WritErr6

; ------ aloka‡n¡ blok souboru XFLOP.COM

WritErr4:cmp       ax,ds:[XFlopBlk+KORIG]   ; aloka‡n¡ blok s XFLOP.COM
         jne       WritErr5
         test      byte ptr ds:[RParam3+KORIG],bit1 ; zapisuje se XFLOP.COM ?
         jz        WritErr5                 ; nezapisuje se

         push      cx
         cmp       cl,0f7h
         jne       WritEr42
         mov       cl,0ffh
WritEr42:cmp       cl,70h
         jne       WritEr44
         mov       cl,0f0h
WritEr44:or        ds:[di],cx               ; p©¡znak konce souboru
         or        si,cx                    ; p©¡znak modifikace sektoru
         pop       cx
         jmp       short WritErr6

; ------ nalezen¡ aloka‡n¡ho bloku v tabulce

WritErr5:push      si

         mov       si,offset ErrMap+KORIG-3 ; tabulka chyb
WritEr52:add       si,3
         cmp       byte ptr ds:[si],0       ; je konec tabulky chyb ?
         je        WritEr54                 ; je konec tabulky chyb
         cmp       ax,ds:[si+1]             ; je blok p©ed intervalem ?
         jb        WritEr52                 ; blok je p©ed intervalem
         mov       dl,ds:[si]               ; po‡et blok–
         mov       dh,0
         add       dx,ds:[si+1]             ; n sleduj¡c¡ blok za intervalem
         cmp       ax,dx                    ; je uvnit© intervalu ?
         jae       WritEr52                 ; nen¡ v intervalu

; ------ blok je vadn˜

         or        ds:[di],cx               ; nastaven¡ bloku jako vadn˜
         pop       si
         or        si,cx                    ; p©¡znak modifikace sektoru
         push      si

WritEr54:pop       si

; ------ zv˜¨en¡ aloka‡n¡ho bloku

WritErr6:inc       di                       ; zv˜¨en¡ ukl dac¡ adresy
         xor       cx,0ff7h XOR 0ff70h      ; zmˆna masky
         cmp       ch,0fh
         jne       WritEr62
         inc       di
WritEr62:inc       ax                       ; zv˜¨en¡ ‡¡sla bloku
         cmp       di,bp                    ; je ji‘ konec bufferu ?
         jb        WritErr2                 ; nen¡ je¨tˆ konec bufferu

; ------ z pis sektoru

         or        si,si                    ; je pot©eba nˆco ulo‘it ?
         jz        WritErr8                 ; nen¡ pot©eba nic ukl dat

         call      Seek                     ; vystaven¡ hlav
         mov       al,bh                    ; AL <- ‡¡slo sektoru
         call      WritSekt                 ; z pis sektoru na disk

; ------ n vrat registr–

WritErr8:pop       bx

; ------ dal¨¡ sektor FAT

         inc       bx                       ; zv˜¨en¡ ‡¡sla sektoru FAT
         inc       word ptr ds:[AbsSekt+KORIG] ; zv˜¨en¡ absolutn¡ho sektoru
         cmp       bl,byte ptr ds:[FATSekt+KORIG] ; jsou ji‘ v¨echny sektory FAT ?
         jae       WritErr9                 ; jsou ji‘ v¨echny sektory FAT
         call      TestEnd                  ; je p©eru¨en¡ operace ?
         jc        WritErr9                 ; je p©eru¨en¡ operace
         jmp       WritErr1                 ; dal¨¡ sektor FAT

WritErr9:ret

WritErr  ENDP

; -----------------------------------------------------------------------------
;        vynulov n¡ sektoru (ES=DS !) -> DI=konec, SI=za‡ tek
; -----------------------------------------------------------------------------

NulSekt  PROC      NEAR

         push      ax
         push      cx

         mov       di,ds:[BuffSekt+KORIG]   ; adresa bufferu
         mov       si,di                    ; SI <- za‡ tek bufferu
         cld
         xor       ax,ax                    ; AX <- 0
         mov       cx,512/2
         rep       stosw                    ; vynulov n¡ sektoru

         pop       cx
         pop       ax
         ret

NulSekt  ENDP

; -----------------------------------------------------------------------------
;        instalace obsluhy INT 0Eh (p–vodn¡ adresa INT 0Eh uchov na !!!)
; -----------------------------------------------------------------------------

Inst0E   PROC      NEAR

         cli
         push      ax
         push      ds

         xor       ax,ax
         mov       ds,ax
         mov       word ptr ds:[4*0eh],offset Int0E+KORIG ; offset obsluhy
         mov       ds:[4*0eh+2],cs          ; segment obsluhy

         pop       ds
         pop       ax
         and       byte ptr ds:[RParam2+KORIG],not bit7 ; nulov n¡ p©¡znaku p©eru¨en¡
         sti
         ret

Inst0E   ENDP

; -----------------------------------------------------------------------------
;        odinstalov n¡ obsluhy INT 0Eh
; -----------------------------------------------------------------------------

DInst0E  PROC      NEAR

         cli
         push      ax
         push      ds

         xor       ax,ax
         mov       ds,ax
         mov       ax,word ptr cs:[Old0E+KORIG]
         mov       ds:[4*0eh],ax            ; offset p–vodn¡ obsluhy
         mov       ax,word ptr cs:[Old0E+KORIG+2]
         mov       ds:[4*0eh+2],ax          ; segment p–vodn¡ obsluhy

         pop       ds
         pop       ax
         sti
         ret

DInst0E  ENDP

; -----------------------------------------------------------------------------
;        zform tov n¡ aktivn¡ stopy s verifikac¡ a z pisem dat
; -----------------------------------------------------------------------------
;þ
FForm    PROC      NEAR

IFDEF    DEMO
         mov       ah,ds:[AStopa+KORIG]     ; aktu ln¡ stopa
ENDIF

; ------ nulov n¡ tabulky vadn˜ch sektor–

         mov       di,offset ErrSekt+KORIG
         mov       cx,offset(ErrSekt0-ErrSekt)
         mov       al,0
         cld
         rep       stosb                    ; vynulov n¡ tabulky vadn˜ch sektor–

IFDEF    DEMO
; ------ DEMO simulace form tov n¡

         cmp       ah,ds:[DemoStop+KORIG]   ; je to DEMO stopa ?
         jb        FForm02                  ; nen¡ je¨tˆ DEMO stopa
         mov       byte ptr ds:[AOper+KORIG],7 ; aktivn¡ operace - DEMO simulace
         mov       cx,4                     ; asi takov  prodleva
         call      Cekej                    ; ‡ek n¡ po dobu simulace
         jmp       short FForm52            ; ozna‡en¡ vadn˜ch sektor–
FForm02:
ENDIF
; ------ zform tov n¡ aktivn¡ stopy

         call      Format                   ; zform tov n¡ aktivn¡ stopy
         jc        FForm1                   ; chyba

; ------ prvn¡ verifikace cel‚ stopy

         test      byte ptr ds:[RParam+KORIG],bit2 ; prov d¡ se verifikace ?
         jnz       FForm2                   ; verifikace se neprov d¡
         call      Verify0                  ; verifikace cel‚ stopy
         jnc       FForm2                   ; operace je OK

; ------ p©i chybˆ resetov n¡ disku

FForm1:  call      Reset                    ; p©i chybˆ resetov n¡

; ------ druh˜ pokus o zform tov n¡ stopy

         call      Format                   ; zform tov n¡ aktivn¡ stopy
         jc        FForm5                   ; chyba

; ------ verifikace cel‚ stopy

         call      Verify0                  ; verifikace cel‚ stopy
         jc        FForm5                   ; stopa je vadn 

; ------ stopa se zkontroluje testovac¡m z pisem (pro uji¨tˆn¡)

         mov       bp,ds:[TestWrit+KORIG]   ; po‡et testovac¡ch z pis–
         inc       bp
         inc       bp                       ; 2 testy nav¡c
         jmp       short FForm22            ; testovac¡ z pisy

; ------ bude ovˆ©en¡ stopy testovac¡m z pisem

FForm2:  mov       bp,ds:[TestWrit+KORIG]   ; po‡et testovac¡ch z pis–
FForm22: inc       bp                       ; p©ednastaven¡

; ------ p©¡prava pro dal¨¡ testovac¡ z pis

FFOrm3:  dec       bp                       ; ‡¡ta‡ testovac¡ch z pis–
         jz        FForm7                   ; nen¡ dal¨¡ testovac¡ z pis
         call      TestEnd                  ; je p©eru¨en¡ operace ?
         jc        FFOrm9                   ; je p©eru¨en¡ operace

; ------ testovac¡ z pis dat na disketu

         call      WritTst                  ; testovac¡ z pis na disketu
         jnc       FForm4                   ; z pis probˆhl OK
         call      Reset                    ; resetov n¡ p©i chybˆ
         call      WritTst                  ; testovac¡ z pis na disketu
         jc        FForm5                   ; chyba

; ------ verifikace cel‚ stopy

FForm4:  call      Verify0                  ; verifikace cel‚ stopy
         jnc       FForm3                   ; stopa je OK
         call      Reset                    ; p©i chybˆ resetov n¡
         call      Verify0                  ; je¨tˆ jeden pokus pro ovˆ©en¡
         jnc       FForm3                   ; stopa je OK

; ------ detekce vadn˜ch sektor–

FForm5:  call      VerifDet                 ; detekce vadn˜ch sektor–
         mov       bp,3                     ; zb˜vaj¡ 3 z pisy
         call      WritTst                  ; testovac¡ z pis na disketu
         call      VerifDet                 ; detekce vadn˜ch sektor–
         dec       bp                       ; dal¨¡ z pis
         call      WritTst                  ; testovac¡ z pis na disketu
         call      VerifDet                 ; detekce vadn˜ch sektor–
         dec       bp                       ; posledn¡ z pis
         call      WritTst                  ; testovac¡ z pis na disketu
         call      VerifDet                 ; detekce vadn˜ch sektor–

; ------ test, zda byla nalezena alespo¤ 1 chyba

FForm52: mov       di,offset ErrSekt + KORIG ; tabulka chyb
         mov       cx,offset(ErrSekt0-ErrSekt) ; d‚lka tabulky
         mov       al,0
         cld
         push      di
         push      cx
         repe      scasb                    ; test, zda je vadn˜ sektor
         pop       cx
         pop       di
         jne       FForm54                  ; byl nalezen vadn˜ sektor

; ------ nic nenalezeno - nastaven¡ v¨ech sektor– jako vadn‚

         dec       ax                       ; ukl d  se -1
         rep       stosb                    ; vymaz n¡ tabulky

; ------ ulo‘en¡ nalezen˜ch chyb

FForm54: mov       ax,ds:[AbsSekt+KORIG]    ; absolutn¡ ‡¡slo sektoru stopy
         mov       cx,word ptr ds:[Sektoru+KORIG] ; po‡et sektor– na stopu
         mov       bx,offset ErrSekt+KORIG  ; ukazatel tabulky chyb

FForm6:  mov       dh,ds:[bx]               ; bajt p©¡znak– chyby
         mov       dl,8+1                   ; ‡¡ta‡ bit–
         inc       bx                       ; zv˜¨en¡ ukazatele v tabulce
FForm62: dec       dl                       ; ‡¡ta‡ bit–
         jz        FForm6                   ; jsou ji‘ v¨echny bity - dal¨¡
         shr       dh,1                     ; test dal¨¡ho bitu
         jnc       FForm66                  ; nebyla chyba
         call      StorErr                  ; ulo‘en¡ ‡¡sla vadn‚ho bloku
FForm66: inc       ax
         clc
         loop      FForm62                  ; dal¨¡ sektor

; ------ z pis BOOT sektoru

FForm7:  call      WritBoot                 ; z pis BOOT

; ------ z pis tabulky FAT 1

         mov       ax,1                     ; ‡¡slo sektoru pro FAT1
         call      WritFAT                  ; z pis FAT 1

; ------ z pis tabulky FAT 2

         mov       ax,ds:[FATSekt+KORIG]    ; po‡et sektor– na FAT
         inc       ax                       ; p©i‡ten¡ sektoru BOOT
         call      WritFAT                  ; z pis FAT 2

; ------ z pis prvn¡ho sektoru ROOT

         call      WritRoot                 ; z pis sektoru ROOT

; ------ z pis souboru XFLOP.COM

         call      WritXFlp                 ; z pis souboru XFLOP.COM
FForm9:  ret

FForm    ENDP

; -----------------------------------------------------------------------------
;        detekce vadn˜ch sektor–
; -----------------------------------------------------------------------------

VerifDet PROC      NEAR

; ------ test, zda se budou sektory prokl dat

         mov       al,1                     ; po‡ te‡n¡ sektor 1
         cmp       byte ptr ds:[Interl+KORIG],1 ; je ji‘ prokl d n¡ sektor– ?
         je        VerifDt4                 ; nen¡ prokl d n¡ sektor–

; ------ verifikace sektor– bez prokl d n¡

VerifDt2:call      VerifyD                  ; verifikace sektoru
         inc       ax                       ; zv˜¨en¡ ukazatele ‡¡sla sektoru
         cmp       al,ds:[Sektoru+KORIG]    ; je ji‘ posledn¡ sektor ?
         jbe       VerifDt2                 ; verifikace dal¨¡ho sektoru
         jmp       short VerifDt6

; ------ verifikace lich˜ch sektor–

VerifDt4:call      VerifyD                  ; verifikace sektoru
         inc       ax
         inc       ax                       ; zv˜¨en¡ ukazatele ‡¡sla sektoru
         cmp       al,ds:[Sektoru+KORIG]    ; je ji‘ posledn¡ sektor ?
         jbe       VerifDt4                 ; verifikace dal¨¡ho sektoru

; ------ verifikace sud˜ch sektor–

         mov       al,2                     ; ukazatel ‡¡sla sektoru
VerifDt5:cmp       al,ds:[Sektoru+KORIG]    ; je je¨tˆ platn‚ ‡¡slo sektoru ?
         ja        VerifDt6                 ; nen¡ ji‘ platn‚ ‡¡slo sektoru
         call      VerifyD                  ; verifikace sektoru
         inc       ax
         inc       ax                       ; zv˜¨en¡ ukazatele sektor–
         jmp       short VerifDt5           ; verifikace dal¨¡ho sektoru

VerifDt6:ret

VerifDet ENDP

; -----------------------------------------------------------------------------
;    verifikace 1 sektoru ‡¡slo AL s aktualizac¡ tabulky chyb (ni‡¡ BX, CX, AH)
; -----------------------------------------------------------------------------

VerifyD  PROC      NEAR

; ------ p©¡prava bitov‚ masky

         mov       bh,0
         mov       bl,al                    ; BL <- ‡¡slo sektoru 1...
         dec       bx                       ; ‡¡slo sektoru relativnˆ 0...
         mov       cl,bl                    ; CL <- ‡¡slo sektoru
         shr       bx,1
         shr       bx,1
         shr       bx,1                     ; BX = offset v tabulce chyb
         and       cl,7                     ; bitov  pozice v tabulce
         mov       ch,bit0                  ; bitov  maska
         shl       ch,cl                    ; rotace masky na pozici

; ------ test, zda je sektor ji‘ vadn˜

         test      byte ptr ds:[ErrSekt+KORIG+bx],ch ; je sektor ji‘ vadn˜ ?
         jnz       VerifyD9                 ; sektor je ji‘ vadn˜

; ------ verifikace testovan‚ho sektoru

         mov       ah,1                     ; verifikace 1 sektoru
         call      Verify                   ; verifikace sektoru
         jnc       VerifyD9                 ; sektor nen¡ vadn˜

; ------ chyba - test, zda je p©eru¨en¡ operace

         call      TestEnd                  ; je p©eru¨en¡ operace ?
         jc        VerifyD9                 ; je p©eru¨en¡ operace

; ------ ozna‡en¡ sektoru jako vadn˜

         or        byte ptr ds:[ErrSekt+KORIG+bx],ch ; ozna‡en¡ sektoru jako vadn˜
VerifyD9:ret

VerifyD  ENDP

; -----------------------------------------------------------------------------
;        testovac¡ z pis n hodn˜m vzorkem (BP=‡¡ta‡ zbyl˜ch z pis–)
; -----------------------------------------------------------------------------

WritTst  PROC      NEAR

; ------ test, zda je ji‘ posledn¡ testovac¡ z pis

         cmp       bp,1                     ; je posledn¡ testovac¡ z pis ?
         je        WritTst1                 ; je posledn¡ testovac¡ z pis

; ------ adresa n hodn˜ch dat

         call      GetTime                  ; poskytnut¡ ‡¡ta‡e ‡asu -> AX
         sub       al,ds:[AStopa+KORIG]     ; aby se to mˆnilo se stopou
         mov       cl,4
         ror       ax,cl                    ; p©enesen¡ zmˆn do horn¡ch bit–
         add       ax,bp
         add       ax,bp
         add       ax,bp                    ; je¨tˆ se posouv  s ‡¡slem z pisu
         and       ax,701fh                 ; segment adresy
         mov       di,ax                    ; ES <- segment adresy
         xor       si,si                    ; SI <- offset adresy

; ------ z pis n hodn˜ch dat

         mov       ah,ds:[Sektoru+KORIG]    ; po‡et sektor– na stopu
         mov       al,1                     ; ‡¡slo prvn¡ho sektoru
         call      Write                    ; z pis n hodn‚ stopy
         jmp       short WritTst9

; ------ p©¡prava bufferu (vynulov n¡) pro posledn¡ z pis

WritTst1:mov       ax,ds:[AbsSekt+KORIG]    ; sektor po‡ tku stopy
         cmp       ax,ds:[DatSekt+KORIG]    ; je ji‘ v datov‚ oblasti ?
         mov       al,0                     ; bude se zapisovat 0
         jb        WritTst2                 ; je je¨tˆ v syst‚mov‚ oblasti
         mov       al,ds:[FillCh+KORIG]     ; datov˜ vzor
WritTst2:mov       ah,al
         mov       cx,512/2
         mov       di,ds:[BuffSekt+KORIG]   ; buffer sektoru
         mov       si,di                    ; SI <- adresa bufferu
         cld
         rep       stosw                    ; vymaz n¡ bufferu sektoru
         mov       di,ds                    ; DI <- segment bufferu

; ------ test, zda se budou sektory prokl dat

         mov       ax,1*HI + 1              ; 1 sektor od ‡¡sla 1
         cmp       byte ptr ds:[Interl+KORIG],1 ; je ji‘ prokl d n¡ sektor– ?
         je        WritTst4                 ; nen¡ prokl d n¡ sektor–

; ------ z pis sektor– bez prokl d n¡

WritTst3:call      Write                    ; z pis sektoru
         jc        WritTst9
         inc       ax                       ; zv˜¨en¡ ukazatele ‡¡sla sektoru
         cmp       al,ds:[Sektoru+KORIG]    ; je ji‘ posledn¡ sektor ?
         jbe       WritTst3                 ; z pis dal¨¡ho sektoru
         jmp       short WritTst9           ; (zde je NC)

; ------ z pis lich˜ch sektor–

WritTst4:call      Write                    ; z pis sektoru
         jc        WritTst9
         inc       ax
         inc       ax                       ; zv˜¨en¡ ukazatele ‡¡sla sektoru
         cmp       al,ds:[Sektoru+KORIG]    ; je ji‘ posledn¡ sektor ?
         jbe       WritTst4                 ; z pis dal¨¡ho sektoru

; ------ z pis sud˜ch sektor–

         mov       al,2                     ; ukazatel ‡¡sla sektoru
WritTst5:cmp       al,ds:[Sektoru+KORIG]    ; je je¨tˆ platn‚ ‡¡slo sektoru ?
         ja        WritTst9                 ; nen¡ ji‘ platn‚ ‡¡slo sektoru
         call      Write                    ; z pis sektoru
         inc       ax
         inc       ax                       ; zv˜¨en¡ ukazatele sektor–
         jnc       WritTst5                 ; z pis dal¨¡ho sektoru (nebyla-li chyba)
WritTst9:ret

WritTst  ENDP

; -----------------------------------------------------------------------------
;        z pis sektoru AL v aktivn¡ stopˆ (z bufferu sektoru)
; -----------------------------------------------------------------------------

WritSekt PROC      NEAR

; ------ £schova registr–

         push      ax
         push      si
         push      di

; ------ p©¡prava registr–

         mov       ah,1                     ; zap¡¨e se 1 sektor
         mov       di,ds                    ; DI <- segment bufferu sektoru
         mov       si,ds:[BuffSekt+KORIG]   ; SI <- offset bufferu sektoru

; ------ z pis sektoru

         call      Write                    ; z pis sektoru
         jnc       WritSek2                 ; z pis OK
         call      Reset                    ; resetov n¡ disku
         call      Write                    ; druh˜ pokus o z pis
         jc        WritSek9                 ; chyba

; ------ verifikace sektoru

WritSek2:call      Verify                   ; verifikace sektoru
         jnc       WritSek9                 ; operace OK
         call      Reset                    ; resetov n¡ disku
         call      Verify                   ; druh˜ pokus o verifikaci

; ------ n vrat registr–

WritSek9:pop       di
         pop       si
         pop       ax
         ret

WritSekt ENDP

; -----------------------------------------------------------------------------
;        z pis BOOT sektoru
; -----------------------------------------------------------------------------

WritBoot PROC      NEAR

; ------ test, zda je stopa s BOOT

         cmp       word ptr ds:[AbsSekt+KORIG],0 ; je za‡ tek diskety ?
         jne       WritBot9                 ; nen¡ za‡ tek diskety

; ------ p©¡prava BOOT sektoru

         mov       di,ds:[BuffSekt+KORIG]   ; adresa bufferu
         mov       si,offset BootBeg + KORIG  ; BOOT sektor
         mov       cx,512/2                 ; d‚lka BOOT sektoru
         cld
         rep       movsw                    ; p©enos BOOT sektoru

; ------ z pis sektoru v bufferu

         mov       al,1                     ; ‡¡slo sektoru
         call      WritSekt                 ; z pis sektoru na disk
WritBot9:ret

WritBoot ENDP

; -----------------------------------------------------------------------------
;        z pis z hlav¡ FAT (AX=absolutn¡ ‡¡slo sektoru)
; -----------------------------------------------------------------------------

WritFAT  PROC      NEAR

; ------ test, zda je stopa se sektorem FAT

         sub       ax,ds:[AbsSekt+KORIG]    ; ulo‘¡ se FAT ?
         cmc
         jnc       WritFAT8                 ; nen¡ stopa s FAT
         cmp       ax,word ptr ds:[Sektoru+KORIG] ; je sektor je¨tˆ na stopˆ ?
         jae       WritFAT8                 ; sektor ji‘ nen¡ na stopˆ
         inc       ax                       ; AL = ‡¡slo sektoru s FAT

; ------ p©¡prava sektoru

         push      ax
         call      NulSekt                  ; vynulov n¡ sektoru
         mov       di,si                    ; DI <- adresa bufferu
         mov       al,ds:[MediaB+KORIG]     ; popisova‡ m‚dia
         stosb
         mov       ax,-1
         stosw
         pop       ax

; ------ z pis sektoru

         call      WritSekt                 ; z pis sektoru na disk
WritFAT8:ret

WritFAT  ENDP

; -----------------------------------------------------------------------------
;        z pis sektoru ROOT
; -----------------------------------------------------------------------------

WritRoot PROC      NEAR

; ------ test, zda se zapisuje sektor ROOT

         test      byte ptr ds:[RParam3+KORIG],bit0+bit1 ; zapisuje se ROOT ?
         jz        WritRot9                 ; ROOT se nezapisuje

; ------ test, zda je stopa se sektorem ROOT

         mov       ax,ds:[FATSekt+KORIG]    ; po‡et sektor– na FAT
         shl       ax,1                     ; po‡et sektor– na obˆ FAT
         inc       ax                       ; po‡ te‡n¡ sektor ROOT
         sub       ax,ds:[AbsSekt+KORIG]    ; je stopa s ROOT ?
         cmc
         jnc       WritRot9                 ; je stopa za sektorem ROOT
         cmp       ax,word ptr ds:[Sektoru+KORIG] ; je sektor je¨tˆ na stopˆ ?
         jae       WritRot9                 ; sektor ji‘ nen¡ na stopˆ
         inc       ax                       ; AL = ‡¡slo sektoru

         push      ax

; ------ vynulov n¡ bufferu sektoru

         call      NulSekt                  ; vynulov n¡ sektoru

; ------ sestaven¡ polo‘ky LABEL

         mov       di,si                    ; DI <- ukl dac¡ adresa
         test      byte ptr ds:[RParam3+KORIG],bit0 ; zapisuje se LABEL ?
         jz        WritRot4                 ; nezapisuje se LABEL

         mov       si,offset BootLabl+KORIG
         mov       cx,11
         rep       movsb                    ; p©enesen¡ jm‚na LABEL
         mov       al,bit3                  ; atribut LABEL
         stosb                              ; atribut polo‘ky
         add       di,10
         mov       si,offset LabTime+KORIG
         movsw                              ; ‡as
         movsw                              ; datum
         add       di,6

; ------ sestaven¡ polo‘ky XFLOP.COM

WritRot4:test      byte ptr ds:[RParam3+KORIG],bit1 ; zapisuje se XFLOP.COM ?
         jz        WritRot6

         mov       si,offset XFlopNam+KORIG
         mov       cx,11
         rep       movsb                    ; jm‚no souboru
         add       di,11
         mov       cl,4*2
         rep       movsb                    ; parametry

; ------ z pis sektoru ROOT

WritRot6:pop       ax                       ; AL <- ‡¡slo sektoru
         call      WritSekt                 ; z pis sektoru na disk

WritRot9:ret

WritRoot ENDP

; -----------------------------------------------------------------------------
;        z pis souboru XFLOP.COM
; -----------------------------------------------------------------------------

WritXFlp PROC      NEAR

; ------ test, zda se zapisuje XFLOP.COM

         test      byte ptr ds:[RParam3+KORIG],bit1 ; zapisuje se XFLOP.COM ?
         jz        WritXFl9                 ; XFLOP se nezapisuje

; ------ test, zda je stopa s XFLOP.COM

         mov       ax,ds:[XFlopAbs+KORIG]   ; sektor s XFLOP.COM
         sub       ax,ds:[AbsSekt+KORIG]    ; je stopa s XFLOP ?
         cmc
         jnc       WritXFl9                 ; je stopa za sektorem XFLOP
         cmp       ax,word ptr ds:[Sektoru+KORIG] ; je sektor je¨tˆ na stopˆ ?
         jae       WritXFl9                 ; sektor ji‘ nen¡ na stopˆ
         inc       ax                       ; AL = ‡¡slo sektoru

; ------ p©enesen¡ sektoru do bufferu

         push      ax
         mov       di,ds:[BuffSekt+KORIG]   ; adresa bufferu
         push      di
         mov       si,offset BootBeg + KORIG  ; BOOT sektor
         mov       cx,512/2                 ; d‚lka BOOT sektoru
         cld
         rep       movsw                    ; p©enos BOOT sektoru
         pop       si                       ; adresa bufferu
         pop       ax                       ; AL = ‡¡slo sektoru

; ------ z pis sektoru na disk

         call      WritSekt                 ; z pis sektoru na disk

WritXFl9:ret

WritXFlp ENDP

; -----------------------------------------------------------------------------
;        ulo‘en¡ chyby pro absolutn¡ sektor AX
; -----------------------------------------------------------------------------

StorErr  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      dx

; ------ test, zda je vadn˜ BOOT sektor

         sub       ax,1                     ; je to BOOT sektor ?
         jae       StorErr2                 ; nen¡ BOOT sektor
         or        byte ptr ds:[RParam2+KORIG],bit1 ; vadn˜ BOOT sektor
         jmp       short StorErr9

; ------ test, zda je vadn  FAT1

StorErr2:sub       ax,ds:[FATSekt+KORIG]    ; ode‡ten¡ sektor– na FAT 1
         jae       StorErr3                 ; nen¡ FAT1
         or        byte ptr ds:[RParam2+KORIG],bit2 ; vadn  FAT1
         jmp       short StorErr9

; ------ test, zda je vadn  FAT2

StorErr3:sub       ax,ds:[FATSekt+KORIG]    ; ode‡ten¡ sektor– na FAT 2
         jae       StorErr4                 ; nen¡ FAT2
         or        byte ptr ds:[RParam2+KORIG],bit3 ; vadn  FAT 2
         jmp       short StorErr9

; ------ test, zda je vadn˜ ROOT

StorErr4:sub       ax,ds:[Root+KORIG]       ; ode‡ten¡ sektor– na ROOT
         jae       StorErr5                 ; nen¡ ROOT
         or        byte ptr ds:[RParam2+KORIG],bit4 ; vadn˜ ROOT
         jmp       short StorErr9

; ------ p©epo‡et sektoru na ‡¡slo aloka‡n¡ho bloku -> AX

StorErr5:
IFDEF    DEMO
         push      ax
         mov       al,ds:[AStopa+KORIG]
         cmp       al,ds:[DemoStop+KORIG]   ; je to DEMO stopa ?
         pop       ax
         jae       StorEr52                 ; je DEMO stopa
ENDIF
         or        byte ptr ds:[RParam2+KORIG],bit5 ; byla chyba v datech
StorEr52:xor       dx,dx
         div       word ptr ds:[Cluster+KORIG] ; v˜po‡et ‡¡sla bloku

         cmp       ax,ds:[NumClust+KORIG]   ; je to platn˜ aloka‡n¡ blok ?
         jae       StorErr9                 ; nen¡ to platn˜ aloka‡n¡ blok

         inc       ax
         inc       ax                       ; posun + 2 = ‡¡slo bloku

; ------ test, zda je nov  polo‘ka

         mov       bx,ds:[ErrMEnd+KORIG]    ; ukazatel vadn˜ch blok–
         cmp       byte ptr ds:[bx],0       ; je nˆco ulo‘eno ?
         je        StorErr7                 ; nen¡ nic ulo‘eno

; ------ test, zda je pokra‡ov n¡ ©etˆzce

         mov       dl,ds:[bx]               ; po‡et blok– v tabulce
         mov       dh,0
         add       dx,ds:[bx+1]             ; ‡¡slo n sleduj¡c¡ho bloku
         cmp       ax,dx                    ; je n sleduj¡c¡ blok ?
         jb        StorErr9                 ; blok je ji‘ zahrnut
         ja        StorErr6                 ; vytvo©en¡ nov‚ polo‘ky

; ------ test, zda m–‘e b˜t dal¨¡ blok ©etˆzce

         cmp       byte ptr ds:[bx],255     ; m–‘e b˜t dal¨¡ blok ?
         jb        StorErr8                 ; m–‘e b˜t dal¨¡ blok v ©etˆzci

; ------ vytvo©en¡ nov‚ polo‘ky

StorErr6:add       bx,3                     ; zv˜¨en¡ ukazatele polo‘ek
         cmp       bx,offset ErrMap+KORIG+MAXERR*3 ; je tabulka ji‘ pln  ?
         jae       StorErr9                 ; tabulka je ji‘ pln 
         mov       ds:[ErrMEnd+KORIG],bx    ; nov˜ ukazatel polo‘ek

; ------ ulo‘en¡ nov‚ polo‘ky

StorErr7:mov       ds:[bx+1],ax             ; ulo‘en¡ po‡ te‡n¡ho bloku
StorErr8:inc       byte ptr ds:[bx]         ; zv˜¨en¡ po‡tu blok–

; ------ n vrat registr–

StorErr9:pop       dx
         pop       bx
         pop       ax
         ret

StorErr  ENDP

; -----------------------------------------------------------------------------
;        zform tov n¡ aktivn¡ stopy (s opakov n¡m p©i chybˆ DMA)
; -----------------------------------------------------------------------------

Format   PROC      NEAR

         push      bp
         mov       bp,20                    ; po‡et pokus– o verifikaci

Format01:call      TestEnd                  ; test ukon‡en¡ operace
         jc        Format04                 ; p©eru¨en¡ operace
         mov       byte ptr ds:[BuffStat+KORIG+1],0 ; p©ednastaven¡ ST0
         call      Format0                  ; form tov n¡
         jnc       Format04                 ; operace OK
         test      byte ptr ds:[BuffStat+KORIG+1],bit4 ; je p©ete‡en¡ DMA ?
         jz        Format03                 ; nen¡ p©ete‡en¡ DMA
         dec       bp
         jnz       Format01                 ; dal¨¡ pokus
Format03:stc                                ; p©¡znak chyby
Format04:pop       bp
         ret

Format   ENDP

; -----------------------------------------------------------------------------
;        zform tov n¡ aktivn¡ stopy (CY=chyba) (DS=ES=CS)
; -----------------------------------------------------------------------------

Format0  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         mov       byte ptr ds:[AOper+KORIG],3 ; p©¡znak form tov n¡

IFDEF    DEMO
         mov       bx,(DEMOTRK-23)*HI       ; dˆl¡c¡ stopa pro DEMO
ENDIF

IFDEF    DEBUG
         call      ZapDisk                  ; zapnut¡ disku
ENDIF

; ------ vynulov n¡ tabulky sektor– (zachovat BX pro DEMO !)

         call      NulSekt                  ; vynulov n¡ tabulky sektor–
         mov       di,si                    ; DI <- za‡ tek bufferu

; ------ stanoven¡ ‡¡sla po‡ te‡n¡ho sektoru -> AX (zachovat BX pro DEMO !)

         mov       al,ds:[SlideY+KORIG]     ; odsazen¡ sektor– stop
         cmp       byte ptr ds:[Stran+KORIG],1 ; je 1 strana ?
         je        Format1                  ; je 1 strana
         add       al,ds:[SlideX+KORIG]     ; p©i‡ten¡ odsazen¡ pro strany
Format1: mul       byte ptr ds:[AStopa+KORIG] ; posun odsazen¡m p©ede¨l˜ch stop

         cmp       byte ptr ds:[AStrana+KORIG],0 ; je strana 0 ?
         je        Format2                  ; je strana 0
         add       al,ds:[SlideX+KORIG]     ; odsazen¡ podle strany
         adc       ah,0

Format2: mov       cx,word ptr ds:[Sektoru+KORIG] ; po‡et sektor– na stopu
         dec       cx
         add       ax,cx                    ; korekce po‡ tku posun–

IFDEF    DEMO
         add       bh,23                    ; korekce na ‡¡slo dˆl¡c¡ stopy DEMO
ENDIF

         inc       cx
         xor       dx,dx
         div       cx                       ; v˜po‡et odsazen¡
         xchg      ax,cx                    ; AX <- po‡et sektor– na stopu
         sub       ax,dx                    ; AL = ‡¡slo po‡ te‡n¡ho sektoru

; ------ p©¡prava ke generov n¡ tabulky (zachovat BX pro DEMO !)

         mov       dl,ds:[AStopa+KORIG]     ; DL <- aktu ln¡ stopa

IFDEF    DEMO
         add       bh,bl                    ; jen pro zmaten¡ (BL = 0)
         cmp       dl,bh                    ; je DEMO stopa ? (NC=je)
         cmc                                ; zmˆna CY=je DEMO stopa
         adc       dl,bl                    ; pro vy¨¨¡ stopu se ‡¡slo pokaz¡
ENDIF

         mov       dh,ds:[AStrana+KORIG]    ; DH <- aktu ln¡ strana
         mov       ah,2                     ; velikost sektoru 512 B
         mov       cx,word ptr ds:[Sektoru+KORIG] ; po‡et sektor– na stopu
         mov       bp,cx                    ; BP <- po‡et sektor– na stopu
         shl       bp,1
         shl       bp,1                     ; * 4 = velikost tabulky
         mov       si,bp                    ; SI <- velikost tabulky
         add       bp,di                    ; BP = adresa konce tabulky
         mov       bl,ds:[Interl+KORIG]     ; prokl d n¡ sektor–

IFDEF    SHARE
         cmp       byte ptr ds:[AStopa+KORIG],DEMOTRK
         jb        Format32                 ; nen¡ je¨tˆ polovina diskety
;þ
         mov       bl,8
         cmp       bl,ds:[Sektoru+KORIG]
         jb        Format31
         mov       bl,ds:[Sektoru+KORIG]
Format31:cmp       bl,ds:[Interl+KORIG]
         jae       Format32
         mov       bl,ds:[Interl+KORIG]
Format32:

ENDIF

         mov       bh,0
         dec       bx                       ; prokl d n¡ - 1
         shl       bx,1
         shl       bx,1                     ; posun adres sektor–

; ------ zaji¨tˆn¡ platnosti adresy

Format4: cmp       di,bp                    ; je adresa OK ?
         jb        Format5                  ; adresa je OK
         sub       di,si                    ; posun adresy o 1 stopu
         jmp       short Format4

; ------ zaji¨tˆn¡ volnosti polo‘ky

Format5: cmp       byte ptr ds:[di+3],0     ; je voln  polo‘ka (d‚lka sektoru) ?
         je        Format6                  ; je voln  polo‘ka
         add       di,4                     ; zv˜¨en¡ ukl dac¡ adresy
         jmp       short Format4            ; nov˜ test polo‘ky

; ------ ulo‘en¡ polo‘ky

Format6: xchg      ax,dx                    ; AL <- v lec, AH <- hlava
         stosw                              ; ‡¡slo v lce a hlavy
         xchg      ax,dx                    ; AL <- sektor, AH <- velikost
         stosw                              ; ‡¡slo a velikost sektoru

; ------ zv˜¨en¡ ‡¡sla sektoru

         inc       ax                       ; zv˜¨en¡ ‡¡sla sektoru
         cmp       al,ds:[Sektoru+KORIG]    ; je ‡¡slo sektoru je¨tˆ OK ?
         jbe       Format7                  ; ‡¡slo sektoru je je¨tˆ OK
         mov       al,1                     ; p©ete‡en¡ ‡¡sla sektoru

; ------ dal¨¡ polo‘ka

Format7: add       di,bx                    ; posun polo‘ky p©i prokl d n¡
         loop      Format4                  ; dal¨¡ polo‘ka

IFDEF    DEMO
; ------ omezen¡ DEMO stopy (ni‡¡ registr DL !)

         add       dl,17                    ; poka‘en¡ ‡¡sla
         cmp       dl,DEMOTRK+17            ; je DEMO stopa ?
         jae       Format9                  ; omezen¡ pro DEMO stopu
ENDIF
; ------ nastaven¡ kan lu DMA pro z pis

         mov       cx,word ptr ds:[Sektoru+KORIG]    ; po‡et sektor– na stopu
         shl       cx,1
         shl       cx,1                     ; 4 bajty na sektor
         mov       al,DMAW                  ; povel pro z pis DMA
         mov       si,ds:[BuffSekt+KORIG]   ; adresa bufferu
         mov       di,ds                    ; segment adresy bufferu
         call      SetDMA                   ; nastaven¡ kan lu DMA

; ------ vysl n¡ povelu pro form tov n¡

         mov       al,4dh                   ; povel pro form tov n¡
         call      Output                   ; vysl n¡ bajtu
         jc        Format9

; ------ nastaven¡ mechaniky a hlavi‡ky

         mov       al,ds:[AStrana+KORIG]    ; aktivn¡ strana
         shl       al,1
         shl       al,1                     ; rotace na pozici
         or        al,ds:[Disk+KORIG]       ; mechanika
         call      Output                   ; nastaven¡ mechaniky a hlavi‡ky
         jc        Format9

; ------ nastaven¡ d‚lky sektoru

         mov       al,2                     ; 512 bajt–
         call      Output                   ; nastaven¡ d‚lky sektoru
         jc        Format9

; ------ nastaven¡ po‡tu sektor–

         mov       al,ds:[Sektoru+KORIG]    ; po‡et sektor–
         call      Output                   ; nastaven¡ po‡tu sektor–
         jc        Format9

; ------ nastaven¡ mezisektorov‚ mezery

         mov       al,byte ptr ds:[Gap+KORIG] ; mezisektorov  mezera
         call      Output                   ; nastaven¡ mezisektorov‚ mezery
         jc        Format9

; ------ nastaven¡ datov‚ho vzorku

         mov       ax,ds:[AbsSekt+KORIG]    ; sektor po‡ tku stopy
         cmp       ax,ds:[DatSekt+KORIG]    ; je ji‘ v datov‚ oblasti ?
         mov       al,0                     ; bude se zapisovat 0
         jb        Formt76                  ; je je¨tˆ v syst‚mov‚ oblasti
         mov       al,ds:[FillCh+KORIG]     ; datov˜ vzor
Formt76: cmp       word ptr ds:[TestWrit+KORIG],0 ; bude testovac¡ z pis ?
         je        Format8                  ; nebude testovac¡ z pis
         not       al                       ; inverze pro test spolehlivosti
Format8: call      Output                   ; nastaven¡ datov‚ho vzoru
         jc        Format9

; ------ ‡ek n¡ na proveden¡ operace

         call      OperWait                 ; ‡ek n¡ na ukon‡en¡ operace

; ------ n vrat registr–

Format9: pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Format0  ENDP

; -----------------------------------------------------------------------------
;        verifikace cel‚ aktivn¡ stopy (ni‡¡ AX)
; -----------------------------------------------------------------------------

Verify0: mov       ah,ds:[Sektoru+KORIG]    ; po‡et sektor– na stopu
         mov       al,1                     ; po‡ te‡n¡ sektor

; -----------------------------------------------------------------------------
;        verifikace AH sektor– od ‡¡sla AL (s opakov n¡m p©i chybˆ DMA)
; -----------------------------------------------------------------------------

Verify   PROC      NEAR

         push      bp
         mov       bp,20                    ; po‡et pokus– o verifikaci

IFDEF    DEMO
         cmp       byte ptr ds:[AStopa+KORIG],DEMOTRK ; je DEMO stopa ?
         jae       Verify3                  ; je DEMO stopa - chyba
ENDIF

Verify1: call      TestEnd                  ; test ukon‡en¡ operace
         jc        Verify4                  ; p©eru¨en¡ operace
         mov       byte ptr ds:[BuffStat+KORIG+1],0 ; p©ednastaven¡ ST0
         call      Verify8                  ; verifikace
         jnc       Verify4                  ; operace OK
         test      byte ptr ds:[BuffStat+KORIG+1],bit4 ; je p©ete‡en¡ DMA ?
         jz        Verify3                  ; nen¡ p©ete‡en¡ DMA
         dec       bp
         jnz       Verify1
Verify3: stc                                ; p©¡znak chyby operace
Verify4: pop       bp
         ret

Verify   ENDP

; -----------------------------------------------------------------------------
;        verifikace AH sektor– od ‡¡sla AL
; -----------------------------------------------------------------------------

Verify8  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         mov       dx,ax                    ; DL <- ‡¡slo sektoru, DH <- po‡et
         mov       byte ptr ds:[AOper+KORIG],4 ; p©¡znak verifikace

IFDEF    DEBUG
         call      ZapDisk                  ; zapnut¡ disku
ENDIF

; ------ nastaven¡ kan lu DMA pro verifikaci

         mov       al,0                     ; AL <- 0
         shl       ax,1                     ; po‡et bajt–
         xchg      ax,cx                    ; CX <- po‡et bajt– pro z pis
         mov       al,DMAV                  ; povel pro verifikaci DMA
         xor       si,si                    ; SI <- 0 offset adresy
         xor       di,di                    ; DI <- 0 segment adresy
         call      SetDMA                   ; nastaven¡ kan lu DMA

; ------ vysl n¡ povelu pro ‡ten¡

         mov       al,66h                   ; povel pro ‡ten¡
         jmp       short Write1

Verify8  ENDP

; -----------------------------------------------------------------------------
;        z pis AH sektor– od ‡¡sla AL, adresa DI:SI (s opakov n¡m p©i chybˆ DMA)
; -----------------------------------------------------------------------------

Write    PROC      NEAR

         push      bp
         mov       bp,20                    ; po‡et pokus– o z pis

IFDEF    DEMO
         cmp       byte ptr ds:[AStopa+KORIG],DEMOTRK ; je DEMO stopa ?
         jae       WriteX3                  ; je DEMO stopa - chyba
ENDIF

WriteX1: call      TestEnd                  ; test ukon‡en¡ operace
         jc        WriteX5                  ; p©eru¨en¡ operace
         mov       byte ptr ds:[BuffStat+KORIG+1],0 ; p©ednastaven¡ ST0
         call      Write0                   ; z pis
         jnc       WriteX5                  ; operace OK
         test      byte ptr ds:[BuffStat+KORIG+1],bit4 ; je p©ete‡en¡ DMA ?
         jz        WriteX3                  ; nen¡ p©ete‡en¡ DMA
         dec       bp
         jnz       WriteX1                  ; dal¨¡ pokus p©i p©ete‡en¡ DMA
WriteX3: stc
WriteX5: pop       bp
         ret

Write    ENDP

; -----------------------------------------------------------------------------
;        z pis AH sektor– od ‡¡sla AL, adresa DI:SI
; -----------------------------------------------------------------------------

Write0   PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         mov       dx,ax                    ; DL <- ‡¡slo sektoru, DH <- po‡et
         mov       byte ptr ds:[AOper+KORIG],5 ; p©¡znak z pisu

IFDEF    DEBUG
         call      ZapDisk                  ; zapnut¡ disku
ENDIF

; ------ nastaven¡ kan lu DMA pro z pis

         mov       al,0                     ; AL <- 0
         shl       ax,1                     ; po‡et bajt–
         xchg      ax,cx                    ; CX <- po‡et bajt– pro z pis
         mov       al,DMAW                  ; povel pro z pis DMA
         call      SetDMA                   ; nastaven¡ kan lu DMA

; ------ vysl n¡ povelu pro z pis

         mov       al,45h                   ; povel pro z pis
Write1:  call      Output                   ; vysl n¡ bajtu
         jc        Write9

; ------ nastaven¡ mechaniky a hlavi‡ky

         mov       al,ds:[AStrana+KORIG]    ; aktivn¡ strana
         shl       al,1
         shl       al,1                     ; rotace na pozici
         or        al,ds:[Disk+KORIG]       ; mechanika
         call      Output                   ; nastaven¡ mechaniky a hlavi‡ky
         jc        Write9

; ------ nastaven¡ ‡¡sla stopy

         mov       al,ds:[AStopa+KORIG]     ; aktivn¡ stopa
         call      Output                   ; nastaven¡ ‡¡sla stopy
         jc        Write9

; ------ nastaven¡ ‡¡sla strany

         mov       al,ds:[AStrana+KORIG]    ; aktivn¡ strana
         call      Output                   ; nastaven¡ ‡¡sla strany
         jc        Write9

; ------ nastaven¡ ‡¡sla sektoru

         mov       al,dl                    ; ‡¡slo sektoru
         call      Output                   ; nastaven¡ ‡¡sla sektoru
         jc        Write9

; ------ nastaven¡ d‚lky sektoru 512 B

         mov       al,2
         call      Output                   ; nastaven¡ d‚lky sektoru
         jc        Write9

; ------ nastaven¡ ‡¡sla maxim ln¡ho sektoru

         mov       al,ds:[Sektoru+KORIG]    ; po‡et sektor– na stopu
         call      Output                   ; nastaven¡ maxim ln¡ho sektoru
         jc        Write9

; ------ nastaven¡ mezisektorov‚ mezery (pozor - BIOS ji pou‘¡v  27 a‘ 42 !)

         mov       al,2                     ; mezisektorov  mezera (nen¡ pot©eba)
         call      Output                   ; nastaven¡ mezisektorov‚ mezery
         jc        Write9

; ------ po‡et ‡ten˜ch bajt–

         mov       al,255
         call      Output                   ; nastaven¡ po‡tu ‡ten˜ch bajt–
         jc        Write9

; ------ ‡ek n¡ na proveden¡ operace

         call      OperWait                 ; ‡ek n¡ na ukon‡en¡ operace

; ------ n vrat registr–

Write9:  pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

Write0   ENDP

; -----------------------------------------------------------------------------
;        reset ©adi‡e disket (CY=chyba)
; -----------------------------------------------------------------------------

Reset    PROC      NEAR

; ------ £schova registr–

         push      ax
         push      dx

IFDEF    DEMO
; ------ omezen¡ pro DEMO stopu

         mov       al,ds:[AStopa+KORIG]     ; aktivn¡ stopa
         add       al,93
ENDIF
; ------ test, zda je p©eru¨en¡ operace

         call      TestEnd                  ; test ukon‡en¡ operace
         jc        Reset9                   ; p©eru¨en¡ operace

IFDEF    DEMO
; ------ omezen¡ pro DEMO stopu

         cmp       al,DEMOTRK+93            ; je DEMO stopa ?
         jae       Reset9                   ; je DEMO stopa
ENDIF
; ------ vysl n¡ sign lu RESET na ©adi‡ disket

         call      ResDisk                  ; vysl n¡ sign lu pro reset
         call      ZapDisk                  ; uvolnˆn¡ ©adi‡e

; ------ kontrola v˜sledku operace

         call      ChkStat                  ; kontrola stavu
         jc        Reset9
         cmp       byte ptr ds:[BuffStat+KORIG],0c0h ; kontrola navr cen‚ho stavu
         je        Reset1                   ; navr cen˜ stav je OK
         mov       byte ptr ds:[LastErr+KORIG],13 ; chyba resetov n¡ ©adi‡e
         stc
         jmp       short Reset9             ; chyba

; ------ vysl n¡ povelu pro specifikaci parametr– SPECIFY

Reset1:  mov       al,3
         call      Output                   ; vysl n¡ povelu SPECIFY
         jc        Reset9

         mov       al,0dfh                  ; krokov n¡ pro mechaniky 5 1/4"
         cmp       byte ptr ds:[TypDisk+KORIG],M120 ; je mechanika 5 1/4" ?
         jbe       Reset2                   ; mechanika 5 1/4"
         mov       al,0afh                  ; krokov n¡ pro mechaniku 3 1/2"
Reset2:  call      Output                   ; nastaven¡ rychlosti krokov n¡
         jc        Reset9

         mov       al,2
         call      Output                   ; ‡as pro p©iklopen¡ hlavi‡ky, DMA
         jc        Reset9

; ------ nastaven¡ p©enosov‚ rychlosti

         mov       dx,3f7h
         mov       al,ds:[Rate+KORIG]       ; p©enosov  rychlost
         out       dx,al                    ; nastaven¡ p©enosov‚ rychlosti

; ------ rekalibrace disku

         mov       al,7                     ; povel pro rekalibraci disku
         call      Output                   ; vysl n¡ povelu pro rekalibraci
         jc        Reset9
         mov       al,ds:[Disk+KORIG]       ; po‘adovan˜ disk
         call      Output                   ; vysl n¡ ‡¡sla disku
         jc        Reset9

; ------ kontrola operace rekalibrace

         call      ChkStat                  ; kontrola stavu operace
         jc        Reset9                   ; chyba

; ------ vystaven¡ zp tky na stopu

         call      Seek                     ; vystaven¡ hlav

; ------ n vrat registr–

Reset9:  pop       dx
         pop       ax
         ret

Reset    ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ kan lu DMA: AL=povel pro DMA, CX=po‡et bajt–, DI:SI=adresa
; -----------------------------------------------------------------------------

SetDMA   PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx                       ; (mus¡ b˜t posledn¡ !)

; ------ nastaven¡ povelu pro DMA

         cli
         out       [0ch],al                 ; nastaven¡ p©¡znaku n slednosti DMA
         jmp       short $+2                ; prodleva
         out       [0bh],al                 ; nastaven¡ povelu pro DMA

; ------ v˜po‡et adresy pro p©enos DMA -> CH:AX (20 bit–)

         mov       ax,di                    ; AX <- segment adresy
         mov       ch,ah                    ; CH <- vy¨¨¡ bajt adresy
         mov       cl,4                     ; po‡et rotac¡
         shl       ax,cl                    ; p©evod segmentu na offset
         shr       ch,cl                    ; vy¨¨¡ 4 bity adresy v CH
         add       ax,si                    ; adresa bufferu sektoru
         adc       ch,0                     ; p©enos do adresy HIGH

; ------ nastaven¡ adresy pro p©enos DMA (kan l 2)

         out       [4],al                   ; nastaven¡ ni‘¨¡ho bajtu adresy
         mov       al,ah                    ; AL <- vy¨¨¡ bajt adresy
         jmp       short $+2                ; prodleva
         out       [4],al                   ; nastaven¡ vy¨¨¡ho bajtu adresy
         mov       al,ch                    ; AL <- nejvy¨¨¡ 4 bity
         out       [81h],al                 ; nastaven¡ str nkov‚ho registru

; ------ nastaven¡ po‡tu bajt– k p©enosu

         pop       ax                       ; po‡et bajt– k p©enosu
         push      ax
         dec       ax                       ; po‡et bajt– - 1
         out       [5],al                   ; po‡et bajt– LOW
         mov       al,ah                    ; AL <- po‡et bajt– HIGH
         jmp       short $+2                ; prodleva
         out       [5],al                   ; po‡et bajt– HIGH

; ------ povolen¡ p©enosu kan lem DMA 2

         mov       al,2                     ; kan l 2
         out       [0ah],al                 ; povolen¡ p©enosu kan lem 2
         sti

; ------ n vrat registr–

         pop       cx
         pop       ax
         ret

SetDMA   ENDP

; -----------------------------------------------------------------------------
;        vystaven¡ mechaniky na aktivn¡ stopu (CY=chyba)
; -----------------------------------------------------------------------------

Seek     PROC      NEAR

; ------ £schova registr–

         push      ax

; ------ povel pro vystaven¡ na stopu SEEK

         mov       al,0fh                   ; povel pro vystaven¡
         call      Output                   ; vysl n¡ povelu pro vystaven¡
         jc        Seek9

; ------ nastaven¡ ‡¡sla disku

         mov       al,ds:[Disk+KORIG]       ; po‘adovan˜ disk
         call      Output                   ; vysl n¡ ‡¡sla disku
         jc        Seek9                    ; chyba

; ------ nastaven¡ ‡¡sla stopy

         mov       al,ds:[AStopa+KORIG]     ; aktivn¡ stopa
         test      byte ptr ds:[RParam+KORIG],bit6 ; je dvoj¡ krokov n¡ ?
         jz        Seek2                    ; nen¡ dvoj¡ krokov n¡
         shl       al,1                     ; dvojit‚ krokov n¡
Seek2:   call      Output                   ; nastaven¡ ‡¡sla stopy
         jc        Seek9                    ; chyba

; ------ kontrola v˜sledku operace

         call      ChkStat                  ; test v˜sledku operace
         jc        Seek9                    ; chyba

; ------ prodleva pro ust len¡ hlav

         mov       ax,1000
         call      WaitT                    ; ‡ek n¡ 15 ms na ust len¡ hlav
         clc

; ------ n vrat registr–

Seek9:   pop       ax
         ret

Seek     ENDP

; -----------------------------------------------------------------------------
;        vypnut¡ mechaniky
; -----------------------------------------------------------------------------

VypDisk  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      dx

; ------ nastaven¡ registru

         mov       dx,3f2h                  ; adresa ©adi‡e
         mov       al,ds:[Disk+KORIG]       ; zvolen˜ disk
         or        al,bit2+bit3             ; uvolnˆn¡ ©adi‡e, povolen DMA
         out       dx,al

; ------ n vrat registr–

         pop       dx
         pop       ax
         ret

VypDisk  ENDP

; -----------------------------------------------------------------------------
;        resetov n¡ ©adi‡e
; -----------------------------------------------------------------------------

ResDisk  PROC      NEAR

         push      ax
         mov       al,bit3                  ; resetov n¡ ©adi‡e
         jmp       short ZapDisk1

ResDisk  ENDP

; -----------------------------------------------------------------------------
;        zapnut¡ mechaniky
; -----------------------------------------------------------------------------

ZapDisk  PROC      NEAR

; ------ £schova registr–

         push      ax
         mov       al,bit2+bit3             ; uvolnˆn¡ ©adi‡e, povolen DMA
ZapDisk1:push      dx

; ------ nastaven¡ registru

         mov       dx,3f2h                  ; adresa ©adi‡e
         mov       ah,ds:[DiskMask+KORIG]   ; maska disk–
         shl       ah,1
         shl       ah,1
         shl       ah,1
         shl       ah,1
         or        al,ds:[Disk+KORIG]       ; zvolen˜ disk
         or        al,ah                    ; maska zapnut¡ motor–
         out       dx,al

; ------ n vrat registr–

         pop       dx
         pop       ax
         ret

ZapDisk  ENDP

; -----------------------------------------------------------------------------
;        test, zda je ukon‡en¡ operace (p©eru¨en¡ nebo vyjmut¡ diskety) CY=konec
; -----------------------------------------------------------------------------

TestEnd  PROC      NEAR

         call      TstBreak                 ; test p©eru¨en¡ operace
         jc        TestEnd2                 ; je p©eru¨en¡ operace
         call      TestXchg                 ; test vyjmut¡ diskety
TestEnd2:ret

TestEnd  ENDP

; -----------------------------------------------------------------------------
;        test, zda je p©eru¨en¡ operace form tov n¡ (CY=je p©eru¨en¡)
; -----------------------------------------------------------------------------

TstBreak PROC      NEAR

         test      byte ptr ds:[RParam2+KORIG],bit6 ; je z kaz p©eru¨en¡ ?
         jnz       TstBrea2                 ; je z kaz p©eru¨en¡ operace
         test      byte ptr ds:[RParam+KORIG],bit5 ; po‘adavek p©eru¨en¡ ?
         jz        TstBrea2                 ; nen¡ po‘adov no p©eru¨en¡
         stc                                ; p©¡znak p©eru¨en¡
TstBrea2:ret

TstBreak ENDP

; -----------------------------------------------------------------------------
;        test, zda je vlo‘ena disketa (CY=nen¡)
; -----------------------------------------------------------------------------

TestXchg PROC      NEAR

         push      ax
         push      dx

         cmp       byte ptr ds:[TypDisk+KORIG],M360
         je        TestXch8                 ; pro mechaniku 360 KB vlo‘ena

         mov       dx,3f7h
         in        al,dx
         test      al,bit7                  ; je disketa vlo‘ena ?
         jz        TestXch8                 ; je vlo‘ena
         stc                                ; nen¡ vlo‘ena

TestXch8:pop       dx
         pop       ax
         ret

TestXchg ENDP

; -----------------------------------------------------------------------------
;        ‡ek n¡ na proveden¡ operace ‡ten¡/z pis/form tov n¡
; -----------------------------------------------------------------------------

OperWait PROC      NEAR

; ------ ‡ek n¡ na p©¡chod p©eru¨en¡ od ©adi‡e

         call      WaitInt                  ; ‡ek n¡ na p©eru¨en¡ od ©adi‡e
         jc        OperWai9                 ; chyba

; ------ p©¡jem v˜sledku operace od ©adi‡e

         call      Result                   ; p©¡jem v˜sledku operace od ©adi‡e
         jc        OperWai9

; ------ vyhodnocen¡ v˜sledku operace

         test      byte ptr ds:[BuffStat+KORIG],bit6+bit7 ; stavov˜ bajt ST0
         jz        OperWai9                 ; nen¡ chyba

         test      byte ptr ds:[BuffStat+KORIG+1],bit4
         jnz       OperWai8                 ; p©ete‡en¡ p©enosu DMA (nehl s¡ se)

         mov       byte ptr ds:[LastErr+KORIG],6 ; mechanika nep©ipravena
         test      byte ptr ds:[BuffStat+KORIG],bit3
         jne       OperWai8                 ; mechanika nep©ipravena

         mov       byte ptr ds:[LastErr+KORIG],7 ; nenalezena stopa 0
         test      byte ptr ds:[BuffStat+KORIG],bit4
         jnz       OperWai8                 ; nenalezena stopa 0

         mov       byte ptr ds:[LastErr+KORIG],8 ; sektor nenalezen
         test      byte ptr ds:[BuffStat+KORIG+1],bit0+bit2
         jnz       OperWai8                 ; sektor nenalezen

         mov       byte ptr ds:[LastErr+KORIG],9 ; disketa chr nˆna proti z pisu
         test      byte ptr ds:[BuffStat+KORIG+1],bit1
         jnz       OperWai8                 ; ochrana proti z pisu

         mov       byte ptr ds:[LastErr+KORIG],11 ; chyba CRC dat sektoru
         test      byte ptr ds:[BuffStat+KORIG+1],bit5
         jnz       OperWai8                 ; chyba CRC dat sektoru

         mov       byte ptr ds:[LastErr+KORIG],12 ; nesouhlas¡ hlavi‡ka sektoru
         test      byte ptr ds:[BuffStat+KORIG+2],bit1+bit4
         jnz       OperWai8                 ; nesouhlas¡ hlavi‡ka sektoru

         mov       byte ptr ds:[LastErr+KORIG],255 ; jin  chyba

OperWai8:stc                                ; p©¡znak chyby
OperWai9:ret

OperWait ENDP

; -----------------------------------------------------------------------------
;        kontrola v˜sledku operace vystaven¡, rekalibrace, resetu (CY=chyba)
; -----------------------------------------------------------------------------

ChkStat  PROC      NEAR

; ------ £schova registr–

         push      ax

; ------ ‡ek n¡ na p©eru¨en¡ od ©adi‡e (po proveden¡ operace)

         call      WaitInt                  ; ‡ek n¡ na p©eru¨en¡ od ©adi‡e
         jc        ChkStat9                 ; chyba

; ------ vysl n¡ povelu SENSE INTERRUPT STATUS

         mov       al,8                     ; povel SENSE INTERRUPT STATUS
         call      Output                   ; vysl n¡ povelu SENSE INTERRUPT ...
         jc        ChkStat9                 ; chyba operace

; ------ p©¡jem v˜sledku operace od ©adi‡e

         call      Result                   ; p©¡jem v˜sledku operace od ©adi‡e
         jc        ChkStat9                 ; chyba operace

; ------ kontrola navr cen‚ho stavov‚ho bajtu ST0

         mov       al,ds:[BuffStat+KORIG]   ; stavov˜ bajt ST0
         and       al,bit5+bit6             ; kontrolovan‚ bity
         cmp       al,bit5+bit6             ; chyba vystaven¡ ?
         clc                                ; operace OK
         jne       ChkStat9                 ; nen¡ chyba vystaven¡
         mov       byte ptr ds:[LastErr+KORIG],5 ; chyba vystaven¡ hlav
         stc                                ; chyba operace vystaven¡

; ------ n vrat registr–

ChkStat9:pop       ax
         ret

ChkStat  ENDP

; -----------------------------------------------------------------------------
;        vysl n¡ bajtu AL na ©adi‡ (CY=chyba TIME-OUT)
; -----------------------------------------------------------------------------

Output   PROC      NEAR

; ------ £schova registr–

         push      ax
         push      dx

; ------ ‡ek n¡ na p©ipravenost ©adi‡e p©ij¡mat data

         mov       ah,bit7                  ; o‡ek van  hodnota (pro z pis)
         call      WaitPort                 ; ‡ek n¡ na p©ipravenost pro z pis
         jc        Output9                  ; chyba TIME-OUT

; ------ vysl n¡ bajtu AL na ©adi‡

         mov       dx,3f5h
         out       dx,al                    ; vysl n¡ bajtu na ©adi‡
                                          ;* zde je NC = operace OK
; ------ n vrat registr–

Output9: pop       dx
         pop       ax
         ret

Output   ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ stavu od ©adi‡e (CY=chyba)
; -----------------------------------------------------------------------------

Result   PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      dx

; ------ vynulov n¡ bufferu

         mov       bx,offset BuffStat+KORIG ; buffer stavu od ©adi‡e
         xor       ax,ax                    ; AX <- 0
         mov       ds:[bx],ax
         mov       ds:[bx+2],ax
         mov       ds:[bx+4],ax

; ------ ‡ek n¡ na p©ipravenost ©adi‡e

Result1: mov       ah,bit6+bit7             ; po‘adovan  hodnota (pro ‡ten¡)
         call      WaitPort                 ; ‡ek n¡ na p©ipravenost ©adi‡e
         jc        Result9                  ; byla chyba ©adi‡e TIME-OUT

; ------ p©¡jem stavov‚ho bajtu od ©adi‡e

         mov       dx,3f5h
         in        al,dx                    ; ‡ten¡ stavov‚ho bajtu ©adi‡e
         mov       ds:[bx],al               ; ulo‘en¡ bajtu
         inc       bx                       ; zv˜¨en¡ ukl dac¡ adresy

; ------ mal  prodleva (30 us)

         mov       ax,3                     ; (je to trochu v¡c)
         call      WaitT                    ; ‡ekac¡ doba pro odezvu ©adi‡e

; ------ test, zda je je¨tˆ dal¨¡ stavov˜ bajt

         dec       dx                       ; stavov˜ registr ©adi‡e 3f4h
         in        al,dx                    ; ‡ten¡ stavu ©adi‡e
         test      al,bit4                  ; je je¨tˆ dal¨¡ stavov˜ bajt ?
         jz        Result9                  ; nen¡ ji‘ dal¨¡ bajt
         cmp       bx,offset BuffStat+KORIG+7 ; p©ekro‡en po‡et stavov˜ch bajt– ?
         jb        Result1                  ; p©¡jem dal¨¡ho stavov‚ho bajtu
         mov       byte ptr ds:[LastErr+KORIG],4 ; p©ekro‡en po‡et bajt– stavu
                                          ;* p©ekro‡en¡ se ignoruje
; ------ n vrat registr–

Result9: pop       dx
         pop       bx
         pop       ax
         ret

Result   ENDP

; -----------------------------------------------------------------------------
;        ‡ek n¡ na p©ipravenost ©adi‡e - stav AH (CY=chyba TIME-OUT)
; -----------------------------------------------------------------------------

WaitPort PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx

; ------ £schova aktu ln¡ho ‡asu -> BX

         xchg      ax,bx
         call      GetTime                  ; poskytnut¡ ‡¡ta‡e ‡asu -> AX
         xchg      ax,bx                    ; BX <- aktu ln¡ stav ‡¡ta‡e ‡asu
         mov       ch,30                    ; nˆjak  doba bez p©ep¡n n¡ proces–

; ------ test, zda je ©adi‡ p©ipraven

WaitPrt2:mov       dx,3f4h                  ; port ©adi‡e
         in        al,dx                    ; ‡ten¡ stavov‚ho registru ©adi‡e
         and       al,bit6+bit7             ; bity p©ipravenosti
         cmp       al,ah                    ; je ©adi‡ p©ipraven ?
         je        WaitPrt9                 ; ©adi‡ je p©ipraven OK

; ------ zpo‡ tku zrychlen‚ ‡ek n¡

         jcxz      WaitPrt3                 ; nen¡ ji‘ zrychlen‚ ‡ek n¡
         loop      WaitPrt2                 ; rychl‚ ‡ek n¡

; ------ p©ep¡n n¡ proces–

WaitPrt3:sti
         call      FlipFlop                 ; p©ep¡n n¡ proces–

; ------ test, zda je ji‘ TIME-OUT

WaitPrt4:xchg      ax,dx
         call      GetTime                  ; poskytnut¡ ‡¡ta‡e ‡asu -> AX
         xchg      ax,dx
         sub       dx,bx                    ; ubˆhl  doba
         cmp       dx,TIMEOUT               ; je ji‘ doba pro TIME-OUT ?
         jb        WaitPrt2                 ; ‡ek n¡ na dosa‘en¡ po‘adovan‚ doby

         mov       byte ptr ds:[LastErr+KORIG],2 ; TIME-OUT p©¡jmu stavu od ©adi‡e
         test      ah,bit6                  ; o‡ek v  se p©¡jem ?
         jnz       WaitPrt5                 ; o‡ek v  se p©¡jem
         mov       byte ptr ds:[LastErr+KORIG],3 ; TIME-OUT vysl n¡ povelu na ©adi‡

; ------ oprava p©i p©echodu p©es p–lnoc (zmˆn¡ se 00B0 -> 0000)

WaitPrt5:cmp       dx,-0d0h                 ; byl p©echod p©es p–lnoc ?
         jb        WaitPrt9                 ; nen¡ p©echod p©es p–lnoc
         sub       bx,0b0h                  ; oprava
         jmp       short WaitPrt4           ; nov˜ test

; ------ n vrat registr–

WaitPrt9:pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

WaitPort ENDP

; -----------------------------------------------------------------------------
;        ‡ek n¡ na p©eru¨en¡ INT 0Eh (CY=chyba TIME-OUT)
; -----------------------------------------------------------------------------

WaitInt  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx

; ------ povolen¡ p©eru¨en¡ od ©adi‡e p©eru¨en¡

         mov       ch,60                    ; nˆjakou dobu bude zrychlen‚ ‡ek n¡
         in        al,[21h]                 ; registr masky p©eru¨en¡
         jmp       short $+2
         jmp       short $+2
         and       al,not bit6              ; povolen¡ p©eru¨en¡
         out       [21h],al                 ; povolen¡ p©eru¨en¡

; ------ £schova aktu ln¡ho ‡asu -> BX

         call      GetTime                  ; poskytnut¡ ‡¡ta‡e ‡asu -> AX
         xchg      ax,bx                    ; BX <- v˜choz¡ stav ‡¡ta‡e ‡asu

; ------ test, zda ji‘ p©i¨lo p©eru¨en¡

WaitInt4:test      byte ptr ds:[RParam2+KORIG],bit7 ; p©i¨lo p©eru¨en¡ ?
         jnz       WaitInt8                 ; p©eru¨en¡ p©i¨lo OK

; ------ zpo‡ tku zrychlen‚ ‡ek n¡

         jcxz      WaitInt5                 ; nen¡ ji‘ zrychlen‚ ‡ek n¡
         loop      WaitInt4

; ------ p©ep¡n n¡ proces–

WaitInt5:sti
         call      FlipFlop                 ; p©ep¡n n¡ proces–

; ------ test, zda je ji‘ TIME-OUT

WaitInt6:call      GetTime                  ; poskytnut¡ ‡¡ta‡e ‡asu -> AX
         sub       ax,bx                    ; ubˆhl  doba
         cmp       ax,TIMEOUT               ; je ji‘ doba pro TIME-OUT ?
         jb        WaitInt4                 ; ‡ek n¡ na dosa‘en¡ po‘adovan‚ doby
         mov       byte ptr ds:[LastErr+KORIG],1 ; chyba TIME-OUT od INT 0Eh

; ------ oprava p©i p©echodu p©es p–lnoc (zmˆn¡ se 00B0 -> 0000)

         cmp       ax,-0d0h                 ; byl p©echod p©es p–lnoc ?
         jb        WaitInt9                 ; nen¡ p©echod p©es p–lnoc
         sub       bx,0b0h                  ; oprava
         jmp       short WaitInt6           ; nov˜ test

; ------ p©eru¨en¡ INT 0Eh p©i¨lo OK

WaitInt8:and       byte ptr ds:[RParam2+KORIG],not bit7 ; nulov n¡ p©¡znaku p©eru¨en¡
                                          ;* zde je NC
; ------ n vrat registr–

WaitInt9:pop       cx
         pop       bx
         pop       ax
         ret

WaitInt  ENDP

; -----------------------------------------------------------------------------
;        ‡ek n¡ po dobu CX nepodm¡nˆnˆ
; -----------------------------------------------------------------------------

Cekej    PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx

; ------ £schova aktu ln¡ho ‡¡ta‡e ‡asu

         call      GetTime                  ; poskytnut¡ ‡¡ta‡e ‡asu -> AX
         xchg      ax,bx                    ; BX <- £schova v˜choz¡ho ‡asu

; ------ obsluha p©ep¡na‡e proces–

Cekej1:  sti
         call      FlipFlop                 ; p©ep¡n n¡ proces–

; ------ test, zda ji‘ bylo dosa‘eno po‘adovan‚ho ‡asu

Cekej2:  call      GetTime                  ; poskytnut¡ ‡¡ta‡e ‡asu -> AX
         sub       ax,bx                    ; ubˆhl  doba
         cmp       ax,cx                    ; je ji‘ po‘adovan  doba ?
         jb        Cekej1                   ; ‡ek n¡ na dosa‘en¡ po‘adovan‚ doby

; ------ oprava p©i p©echodu p©es p–lnoc (zmˆn¡ se 00B0 -> 0000)

         cmp       ax,-0d0h                 ; byl p©echod p©es p–lnoc ?
         jb        Cekej9                   ; nen¡ p©echod p©es p–lnoc
         sub       bx,0b0h                  ; oprava
         jmp       short Cekej2             ; nov˜ test

; ------ n vrat registr–

Cekej9:  pop       bx
         pop       ax
         ret

Cekej    ENDP

; -----------------------------------------------------------------------------
;        poskytnut¡ aktu ln¡ho stavu ‡¡ta‡e ‡asu -> AX
; -----------------------------------------------------------------------------

GetTime  PROC      NEAR

         push      ds
         xor       ax,ax                    ; AX <- 0
         mov       ds,ax                    ; DS <- 0
         mov       ax,ds:[46ch]             ; aktu ln¡ ‡as
         pop       ds
         ret

GetTime  ENDP

; -----------------------------------------------------------------------------
;        ‡ek n¡ po dobu AX n sobek 15 us
; -----------------------------------------------------------------------------

WaitT    PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      dx

; ------ rozli¨en¡, zda je port [61h]

         xchg      ax,dx                    ; DX <- po‘adovan  doba v 30 us
         test      byte ptr ds:[RParam+KORIG],bit7 ; je port 61h ?
         jnz       WaitT3                   ; je port 61h

; ------ prodleva pro po‡¡ta‡ XT

WaitT2:  mov       cx,10                    ; 17 takt– = 3.5 us, + rezerva
         loop      $                        ; prodleva
         dec       dx
         jnz       WaitT2
         jmp       short WaitT9

; ------ p©¡prava aktu ln¡ho stavu

WaitT3:  in        al,[61h]                 ; ‡ten¡ portu
         and       al,bit4                  ; d–le‘it˜ pouze bit4
WaitT4:  mov       ah,al                    ; £schova stavu

; ------ ‡ek n¡ zmˆnu sign lu hodin

         xor       cx,cx
WaitT5:  in        al,[61h]                 ; ‡ten¡ hodin
         and       al,bit4                  ; aktu ln¡ stav bitu
         cmp       al,ah                    ; je zmˆna ?
         loope     WaitT5                   ; ‡ek n¡ na zmˆnu sign lu
         dec       dx
         jnz       WaitT4                   ; dal¨¡ cyklus

; ------ n vrat registr–

WaitT9:  pop       dx
         pop       cx
         pop       ax
         ret

WaitT    ENDP

IdentEnd label     byte                     ; konec k testu identifikace

; -----------------------------------------------------------------------------
;        BOOT sektor (d‚lka 512 bajt–)
; -----------------------------------------------------------------------------
;þ
NOCOM    EQU       1                        ; p©¡znak pro p©eklad jako INCLUDE
INCLUDE  XFLOP.ASM                          ; BOOT sektor

         dw        0                        ; p©ete‡en¡ pro FAT
Buffer   db        2*512 dup(0)             ; buffer pro z sobn¡k a sektor
         dw        0                        ; p©ete‡en¡ pro FAT

RezEnd   label     byte                     ; konec rezidentn¡ ‡ sti

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                            Start a instalace programu
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;þ
; ------ zobrazen¡ £vodn¡ho textu

Init:    mov       dx,offset UvTxt
         call      DispTxt                  ; zobrazen¡ £vodn¡ho textu

; ------ test, zda je program ji‘ rezidentn¡

         mov       ds:[RezSegm],es          ; tento program je jako rezidentn¡
         push      ds
         mov       ax,KLIC1                 ; identifik tor v AX
         mov       bx,KLIC2                 ; identifik tor v BX
         mov       cx,KLIC3                 ; identifik tor v CX
         int       13h                      ; test instalace programu
         pop       ds
         cmp       ax,KLIC4                 ; je potvrzen¡ operace ?
         jne       Init1                    ; nen¡ rezidentn¡
         mov       ax,es
         cmp       ax,ds:[RezSegm]
         je        Init1                    ; nˆjak˜ program zablokoval ES

; ------ ovˆ©en¡ verze programu v pamˆti

         mov       si,offset IdentBeg       ; za‡ tek k testu identifikace
         mov       di,offset IdentBeg+KORIG
         mov       cx,offset(IdentEnd-IdentBeg) ; d‚lka identifikace
         cld
         repe      cmpsb                    ; porovn n¡ programu
         je        Init04                   ; je to OK

         mov       dx,offset VerzeTxt       ; chyba - je jin  verze
         call      DispTxt
         jmp       short Init1

Init04:  or        byte ptr ds:[Param],bit0 ; je rezidentn¡
         mov       ds:[RezSegm],es          ; segment rezidentn¡ho modulu

; ------ £schova p©¡kazov‚ho © dku do bufferu

Init1:   push      ds
         pop       es                       ; ES <
         mov       si,81h                   ; za‡ tek p©¡kazov‚ho © dku
         mov       di,offset Buffer         ; pracovn¡ buffer
         mov       cl,ds:[si-1]             ; d‚lka p©¡kazov‚ho © dku
         mov       ch,0
         cld
         rep       movsb                    ; £schova p©¡kazov‚ho © dku
         mov       al,0
         stosb                              ; ozna‡en¡ konce textu

; ------ posun programu dol–

         mov       si,offset RezBeg
         mov       di,offset RezBeg+KORIG
         mov       cx,offset(RezEnd-RezBeg)
         rep       movsb                    ; p©esun programu dol–

; ------ p©¡prava adresy bufferu sektoru (mus¡ se nechat mo‘nost p©ete‡en¡ 2 B)

         mov       ax,cs                    ; AX <- segment programu
         mov       cl,4
         shl       ax,cl                    ; p©evod segmentu na offset
         add       ax,offset Buffer+KORIG   ; inicializa‡n¡ adresa bufferu
         add       ax,200h                  ; je p©ete‡en¡ p©es 64 KB ?
         jnc       Init2                    ; nen¡ p©ete‡en¡ p©es 64 KB
         mov       word ptr ds:[BuffSekt+KORIG],offset Buffer+512+KORIG
         mov       word ptr ds:[Zasob+KORIG],offset Buffer+512-2+KORIG

; ------ p©¡prava p©ep¡na‡e proces–

Init2:   mov       si,ds:[Zasob+KORIG]      ; konec z sobn¡ku
         sub       si,11*2                  ; RET F AX BX CX DX SI DI BP DS ES
         mov       word ptr ds:[si+10*2],offset FStart+KORIG ; startovac¡ adresa
         mov       ds:[si+1*2],ds           ; registr DS
         mov       ds:[si+0*2],ds           ; registr ES
         mov       ds:[RegSP+KORIG],si      ; to je ukazatel z sobn¡ku
         mov       ds:[RegSS+KORIG],ds      ; to je segment z sobn¡ku

; ------ p©¡prava ‡asova‡e AT

         call      TestT                    ; test ‡asova‡e AT

; ------ rozbor p©¡kazov‚ho © dku

         call      Rozbor                   ; rozbor p©¡kazov‚ho © dku
         jnc       Init3                    ; zad n¡ je OK

; ------ chybov‚ hl ¨en¡

ChybaH:  mov       dx,offset HelpTxt
Chyba:   call      DispTxt                  ; chyba - nen¡ po‡¡ta‡ AT
         int       20h

; ------ odinstalov n¡ programu z pamˆti

Init3:   test      byte ptr ds:[Param],bit1 ; je odinstalov n¡ ?
         jz        Init4                    ; nen¡ odinstalov n¡

         mov       es,ds:[RezSegm]
         test      byte ptr es:[RParam+KORIG],bit3 ; prob¡h  form tov n¡ ?
         mov       dx,offset JedeTxt        ; text - nutno p©eru¨it
         jnz       Chyba                    ; chyba - nutno p©eru¨it

         jmp       DInstal                  ; odinstalov n¡ programu z pamˆti

; ------ detekce parametr– disku

Init4:   cmp       byte ptr ds:[Disk+KORIG],-1 ; zad n disk ?
         je        Init5                    ; disk nezad n

         mov       es,ds:[RezSegm]
         test      byte ptr es:[RParam+KORIG],bit3 ; prob¡h  form tov n¡ ?
         mov       dx,offset JedeTxt        ; text - nutno p©eru¨it
         jnz       Chyba                    ; chyba - nutno p©eru¨it

         call      DetDisk                  ; detekce typu disku
         jc        Chyba                    ; chyba - neplatn˜ disk
         call      DetParm                  ; detekce parametr– diskety

         call      DispParm                 ; zobrazen¡ parametr– diskety

         test      byte ptr ds:[Param],bit3 ; ‡ek  se na potvrzen¡ ?
         jnz       Init44                   ; ne‡ek  se na potvrzen¡

         mov       dx,offset VarTxt
         mov       al,ds:[Disk+KORIG]
         add       al,"A"
         mov       ds:[VarTxt1],al
         call      DispTxt

         mov       ax,0c08h
         int       21h
         cmp       al,13
         je        Init44
         int       20h

Init44:  or        byte ptr ds:[RParam+KORIG],bit3 ; form tov n¡ aktivn¡

         call      SetSer                   ; p©¡prava s‚riov‚ho ‡¡sla

         mov       si,offset DatBeg+KORIG
         mov       di,si
         mov       cx,offset(DatEnd-DatBeg)
         mov       es,ds:[RezSegm]
         cld
         rep       movsb                    ; p©enos dat

         mov       si,offset BootBeg+KORIG
         mov       di,si
         mov       cx,offset(BootTxt-BootBeg)
         rep       movsb                    ; p©enos dat BOOT sektoru


Init5:   test      byte ptr ds:[Param],bit2 ; po‘adov no p©eru¨en¡ ?
         jz        Init6
         mov       es,ds:[RezSegm]
         or        byte ptr es:[RParam+KORIG],bit5 ; po‘adavek p©eru¨en¡
Init6:
;þ
; ------ instalace do pamˆti

         test      byte ptr ds:[Param],bit0 ; je ji‘ nainstalov n ?
         jnz       InitX                    ; je ji‘ nainstalov n

         mov       dx,offset INT23
         mov       ax,2523h
         int       21h

         call      Instal

         test      byte ptr ds:[Param],bit4 ; zobrazen¡ ?
         jz        InitX1                   ; nen¡ zobrazen¡
         call      Zobraz                   ; zobrazen¡ operace
InitX1:  mov       dx,offset RezEnd+KORIG   ; konec rezidentn¡ ‡ sti
         int       27h                      ; instalace do pamˆti


InitX:
         test      byte ptr ds:[Param],bit4 ; zobrazen¡ ?
         jz        InitX2                   ; nen¡ zobrazen¡
         call      Zobraz                   ; zobrazen¡ operace
InitX2:
         int       20h


INT23:   iret

; -----------------------------------------------------------------------------
;        instalace programu do pamˆti
; -----------------------------------------------------------------------------

; ------ hl ¨en¡ o instalaci do pamˆti

Instal:  mov       dx,offset InstTxt
         call      DispTxt                  ; hl ¨en¡ o instalaci

; ------ £schova INT 08h

         mov       ax,3508h
         int       21h
         mov       word ptr ds:[Old08+KORIG],bx
         mov       word ptr ds:[Old08+KORIG+2],es

; ------ £schova INT 0Eh

         mov       ax,350Eh
         int       21h
         mov       word ptr ds:[Old0e+KORIG],bx
         mov       word ptr ds:[Old0e+KORIG+2],es

; ------ £schova INT 13h

         mov       ax,3513h
         int       21h
         mov       word ptr ds:[BootOld+KORIG],bx
         mov       word ptr ds:[BootOld+KORIG+2],es

; ------ £schova INT 40h

         mov       ax,3540h
         int       21h
         mov       word ptr ds:[Old40+KORIG],bx
         mov       word ptr ds:[Old40+KORIG+2],es

; ------ instalace INT 08h

         mov       dx,offset INT08+KORIG
         mov       ax,2508h
         int       21h                      ; instalace INT 08h

; ------ instalace INT 13h

         mov       dx,offset INT13+KORIG
         mov       ax,2513h
         int       21h                      ; instalace INT 13h

; ------ instalace INT 40h

         mov       dx,offset INT40+KORIG
         mov       ax,2540h
         int       21h                      ; instalace INT 40h

; ------ uvolnˆn¡ segmentu prost©ed¡

         mov       es,ds:[2ch]              ; segment prost©ed¡
         mov       ah,49h
         int       21h                      ; uvolnˆn¡ segmentu prost©ed¡

         ret

; -----------------------------------------------------------------------------
;        odinstalov n¡ programu z pamˆti
; -----------------------------------------------------------------------------

; ------ test, zda je program nainstalov n do pamˆti

DInstal: mov       dx,offset DInsTxt1       ; text - nen¡ nainstalov n
         test      byte ptr ds:[Param],bit0 ; je program nainstalov n ?
         jnz       DInstal2
         jmp       DInstal9                 ; program nen¡ nainstalov n

; ------ kontrola INT 08h

DInstal2:mov       dx,offset DInsTxt2       ; text - nutn‚ odinstalovat pozdˆj¨¡
         mov       ax,3508h
         int       21h
         mov       ax,es
         cmp       ax,ds:[RezSegm]
         jne       DInstal9

; ------ kontrola INT 0Eh

         mov       ax,350eh
         int       21h
         mov       ax,es
         mov       es,ds:[RezSegm]
         cmp       ax,word ptr es:[Old0E+2+KORIG] ; je p–vodn¡ obsluha ?
         je        DInstal3                 ; je p–vodn¡ obsluha
         cmp       ax,ds:[RezSegm]
         jne       DInstal9

; ------ kontrola INT 13h

DInstal3:mov       ax,3513h
         int       21h
         mov       ax,es
         cmp       ax,ds:[RezSegm]
         jne       DInstal9

; ------ kontrola INT 40h

         mov       ax,3540h
         int       21h
         mov       ax,es
         cmp       ax,ds:[RezSegm]
         jne       DInstal9

; ------ n vrat adresy INT 08h

         push      ds
         mov       ds,ds:[RezSegm]          ; rezidentn¡ segment
         lds       dx,ds:[Old08+KORIG]
         mov       ax,2508h
         int       21h                      ; n vrat adresy INT 08h
         pop       ds

; ------ n vrat adresy INT 0Eh

         push      ds
         mov       ds,ds:[RezSegm]          ; rezidentn¡ segment
         lds       dx,ds:[Old0e+KORIG]
         mov       ax,250eh
         int       21h                      ; n vrat adresy INT 0Eh
         pop       ds

; ------ n vrat adresy INT 13h

         push      ds
         mov       ds,ds:[RezSegm]          ; rezidentn¡ segment
         lds       dx,ds:[BootOld+KORIG]
         mov       ax,2513h
         int       21h                      ; n vrat adresy INT 13h
         pop       ds

; ------ n vrat adresy INT 40h

         push      ds
         mov       ds,ds:[RezSegm]          ; rezidentn¡ segment
         lds       dx,ds:[Old40+KORIG]
         mov       ax,2540h
         int       21h                      ; n vrat adresy INT 40h
         pop       ds

; ------ uvolnˆn¡ segmentu programu

         mov       es,ds:[RezSegm]          ; rezidentn¡ segment
         mov       ah,49h
         int       21h                      ; uvolnˆn¡ bloku pamˆti

; ------ hl ¨en¡ o odinstalov n¡

         mov       dx,offset DInsTxt        ; text - byl odinstalov n
DInstal9:call      DispTxt                  ; zobrazen¡ hl ¨en¡
         int       20h

; -----------------------------------------------------------------------------
;        test ‡asova‡e
; -----------------------------------------------------------------------------

TestT    PROC      NEAR

; ------ ‡ek n¡ na stav 0 sign lu hodin

         mov       ch,230                   ; max. doba testu
TestT1:  in        al,[61h]                 ; syst‚mov‚ stavov‚ slovo
         test      al,bit4                  ; jsou hodiny na £rovni 0 ?
         loopnz    TestT1                   ; ‡ek n¡ na stav 0 sign lu hodin
         jcxz      TestT8                   ; nen¡ ‡asova‡ AT

; ------ ‡ek n¡ na stav 1 sign lu hodin

TestT2:  in        al,[61h]                 ; syst‚mov‚ stavov‚ slovo
         test      al,bit4                  ; jsou hodiny na £rovni 1 ?
         loopz     TestT2                   ; ‡ek n¡ na stav 1 sign lu hodin
         jcxz      TestT8                   ; nen¡ ‡asova‡ AT
         or        byte ptr ds:[RParam+KORIG],bit7 ; p©¡znak ‡asova‡e AT

TestT8:  ret

TestT    ENDP

; -----------------------------------------------------------------------------
;        p©¡prava s‚riov‚ho ‡¡sla
; -----------------------------------------------------------------------------

SetSer   PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx

; ------ stanoven¡ syst‚mov‚ho ‡asu

         mov       ah,2ch
         int       21h                      ; poskytnut¡ syst‚mov‚ho ‡asu

         mov       ah,0
         mov       al,dl                    ; setina sekundy 7 bit–
         shr       al,1                     ; setina sekundy 6 bit–

         mov       dl,0
         shr       dx,1
         shr       dx,1
         or        ax,dx                    ; sekunda 6 bit– (p©esahuj¡ 4 bity)

         mov       dh,0
         mov       dl,cl                    ; minuta
         mov       cl,4                     ; po‡et rotac¡
         shl       dx,cl
         or        ah,dl                    ; minuty 4 bity
         mov       dl,dh                    ; minuty 2 bity

         mov       dh,ch                    ; hodina
         shl       dh,1
         shl       dh,1
         or        dl,dh                    ; hodina 5 bit– (zb˜v  1 bit)
         mov       dh,0

         mov       word ptr ds:[BootSerN+KORIG+2],ax
         mov       word ptr ds:[BootSerN+KORIG],dx ; v DX je 7 bit–

; ------ stanoven¡ syst‚mov‚ho data

         mov       ah,2ah
         int       21h                      ; poskytnut¡ syst‚mov‚ho data

         mov       ah,dh                    ; mˆs¡c
         mov       cl,4
         shl       ah,cl                    ; mˆs¡c 4 bity
         mov       dh,0
         mov       cl,7
         shl       dx,cl                    ; den 5 bit–
         or        ax,dx                    ; mˆs¡c + den
         or        word ptr ds:[BootSerN+KORIG],ax ; + mˆs¡c a den

; ------ n vrat registr–

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

SetSer   ENDP

; *****************************************************************************
;
;                        Rozbor p©¡kazov‚ho © dku
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        rozbor p©¡kazov‚ho © dku
; -----------------------------------------------------------------------------

Rozbor   PROC      NEAR

; ------ na‡ten¡ znaku parametru

         mov       si,offset Buffer+KORIG   ; buffer p©¡kazov‚ho © dku
Rozbor1: call      RozbSpc                  ; vypu¨tˆn¡ mezer
         call      RozbChr                  ; na‡ten¡ znaku parametru
         jnc       Rozbor4                  ; je dal¨¡ znak OK
Rozbor2: cmc
Rozbor3: ret

; ------ skok na obsluhu znaku AL

Rozbor4: mov       bx,offset RozbTab-3
Rozbor5: add       bx,3
         cmp       byte ptr cs:[bx],0       ; konec tabulky ?
         je        Rozbor2                  ; chyba - parametr nenalezen
         cmp       byte ptr cs:[bx],al      ; je to hledan˜ znak parametru ?
         jne       Rozbor5                  ; nalezen¡ parametru
         call      word ptr cs:[bx+1]       ; skok na obsluhu parametru
         jmp       short Rozbor1            ; dal¨¡ parametr

Rozbor   ENDP

; ------ tabulka skok– na obsluhy parametr–

RozbTab  label     byte
         db        'A'
         dw        RozbTA
                                            
         db        'B'
         dw        RozbTB
                                            
         db        'C'
         dw        RozbTC

         db        'D'
         dw        RozbTD

         db        'E'
         dw        RozbTE

         db        'F'
         dw        RozbTF

         db        'G'
         dw        RozbTG

         db        'H'
         dw        RozbTH

         db        'I'
         dw        RozbTI

         db        'J'
         dw        RozbTJ

         db        'K'
         dw        RozbTK

         db        'L'
         dw        RozbTL

         db        'M'
         dw        RozbTM

         db        'N'
         dw        RozbTN

         db        'O'
         dw        RozbTO

         db        'P'
         dw        RozbTP

         db        'Q'
         dw        RozbTQ

         db        'R'
         dw        RozbTR

         db        'S'
         dw        RozbTS

         db        'T'
         dw        RozbTT

         db        'U'
         dw        RozbTU

         db        'V'
         dw        RozbTV

         db        'W'
         dw        RozbTW

         db        'X'
         dw        RozbTX

         db        'Y'
         dw        RozbTY

;         db        'Z'
;         dw        RozbTZ

         db        '1'
         dw        RozbT1

         db        '4'
         dw        RozbT4

         db        '8'
         dw        RozbT8

         db        '!'
         dw        RozbT_X

         db        0

; ------ "A" - disk A:

RozbTA:  mov       byte ptr ds:[Disk+KORIG],0 ; je disk A:
         ret

; ------ "B" - disk B:

RozbTB:  mov       byte ptr ds:[Disk+KORIG],1 ; je disk B:
         ret

; ------ "C" - velikost bloku

RozbTC:  call      RozbNumB                 ; na‡ten¡ parametru (bajt)
         or        al,al                    ; je nˆco zad no ?
         jz        RozbTC9                  ; nen¡ nic zad no
         mov       ah,1                     ; 1 sektor na blok
RozbTC4: cmp       al,ah                    ; je ji‘ dostate‡n  velikost bloku ?
         jbe       RozbTC6                  ; nalezen po‡et sektor– na blok
         shl       ah,1                     ; po‡et sektor– * 2
         jnz       RozbTC4                  ; dal¨¡ test
         mov       ah,80h                   ; omezen¡ velikosti bloku
RozbTC6: mov       ds:[Cluster+KORIG],ah    ; po‡et sektor– na aloka‡n¡ blok
RozbTC9: ret

; ------ "D" - zobrazen¡ operace

RozbTD:  or        byte ptr ds:[Param],bit4 ; po‘adavek zobrazen¡ operace
         ret

; ------ "E" - pou‘¡t zvukovou indikaci konce

RozbTE:  or        byte ptr ds:[RParam+KORIG],bit0 ; pou‘¡t zvukovou indikaci
         ret

; ------ "F" - jmenovit  kapacita

RozbTF:  call      RozbNum                  ; na‡ten¡ ‡¡sla
         cmp       ax,10                    ; asi tolik hranice pro KB
         jae       RozbTF2                  ; je to v KB
         add       dx,40                    ; zaokrouhlen¡ nahoru
         adc       ax,0
         mov       cx,dx                    ; £schova desetin
         mov       dx,1000                  ; n sobitel pro p©epo‡et
         mul       dx                       ; p©epo‡et MB na KB
         xchg      ax,cx                    ; CX <- tis¡ce KB
         mov       dx,1000
         mul       dx                       ; p©epo‡et desetin na KB
         xchg      ax,dx                    ; AX <- jednotky KB
         add       ax,cx                    ; kapacita v KB
RozbTF2: or        ax,ax                    ; je zad n¡ OK ?
         jz        RozbTF6                  ; kapacita nen¡ zadan 
         inc       ax                       ; trochu zaokrouhlen¡ nahoru
         mov       ds:[JmenKap+KORIG],ax    ; jmenovit  kapacita v KB
         call      RozbSpc                  ; vypu¨tˆn¡ mezer
         jc        RozbTF6
         cmp       al,"M"
         je        RozbTF4
         cmp       al,"K"
         jne       RozbTF6
RozbTF4: call      RozbChr                  ; zru¨en¡ znaku "K" nebo "M"
         call      RozbChr                  ; dal¨¡ znak
         jc        RozbTF6                  ; nen¡ dal¨¡ znak
         cmp       al,"B"
         je        RozbTF6                  ; zru¨en¡ znaku "B"
         dec       si                       ; n vrat znaku
RozbTF6: ret

; ------ "G" - mezisektorov  mezera

RozbTG:  call      RozbNumB
         mov       ds:[Gap+KORIG],ax
         or        byte ptr ds:[Param],bit7 ; p©¡znak zad n¡ mezery GAP
         ret

; ------ "H" - po‡et hlav

RozbTH:  call      RozbNumB
         or        al,al
         jz        RozbTH4
         cmp       al,2
         jbe       RozbTH2
         mov       al,2
RozbTH2: mov       ds:[Stran+KORIG],al
RozbTH4: ret

; ------ "I" - prokl d n¡ sektor– interleave

RozbTI:  call      RozbNumB
         cmp       al,MAXSEKT
         jb        RozbTI2
         mov       al,MAXSEKT
RozbTI2: mov       ds:[Interl+KORIG],al
         ret

; ------ "J" - dvoj¡ krokov n¡

RozbTJ:  call      RozbNumB
         or        ax,ax
         jz        RozbTJ4
         or        byte ptr ds:[Param],bit6 ; zad no krokov n¡
         and       byte ptr ds:[RParam+KORIG],not bit6 ; nen¡ dvoj¡ krokov n¡
         dec       ax
         jz        RozbTJ4                  ; nen¡ dvoj¡ krokov n¡
         or        byte ptr ds:[RParam+KORIG],bit6 ; je dvoj¡ krokov n¡
RozbTJ4: ret

; ------ "K" - ne‡ekat na potvrzen¡ kl vesnic¡

RozbTK:  or        byte ptr ds:[Param],bit3 ; ne‡ekat na potvrzen¡
         ret

; ------ "L" - pln¡c¡ bajt dat diskety

RozbTL:  call      RozbNumB
         mov       ds:[FillCh+KORIG],al     ; pln¡c¡ bajt dat
         ret

; ------ "M" - popisova‡ m‚dia

RozbTM:  call      RozbNumB
         mov       ds:[MediaB+KORIG],al     ; bajt popisova‡e m‚dia
         or        byte ptr ds:[Param],bit5 ; p©¡znak zad n¡ popisova‡e m‚dia
         ret

; ------ "N" - po‡et sektor–

RozbTN:  call      RozbNumB
         or        al,al                    ; nˆco zad no ?
         jz        RozbTN4                  ; nic nezad no
         cmp       al,MAXSEKT
         jb        RozbTN2
         mov       al,MAXSEKT               ; maxim ln¡ po‡et sektor–
RozbTN2: mov       ds:[Sektoru+KORIG],al    ; po‡et sektor– na stopu
RozbTN4: ret

; ------ "O" - p©enosov  rychlost

RozbTO:  call      RozbNum
         or        ax,ax
         jz        RozbTO4
         mov       bl,2
         cmp       ax,275
         jbe       RozbTO2
         dec       bx
         cmp       ax,400
         jbe       RozbTO2
         dec       bx
         cmp       ax,750
         jbe       RozbTO2
         mov       bl,3
RozbTO2: mov       ds:[Rate+KORIG],bl
RozbTO4: ret

; ------ "P" - form tovat v¡ce disket za sebou

RozbTP:  or        byte ptr ds:[RParam+KORIG],bit1 ; form tov n¡ v¡ce disket
         ret

; ------ "Q" - p©eru¨en¡ operace

RozbTQ:  or        byte ptr ds:[Param],bit2 ; po‘adavek p©eru¨en¡
         ret

; ------ "R" - velikost ROOT

RozbTR:  call      RozbNum
         add       ax,15                    ; zaokrouhlen¡ na sektor
         rcr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; po‡et sektor–
         jz        RozbTR2                  ; nen¡ nic zad no
         mov       ds:[Root+KORIG],ax       ; po‡et sektor– na ROOT
RozbTR2: ret

; ------ "S" - ulo‘it soubor XFLOP.COM

RozbTS:  or        byte ptr ds:[RParam3+KORIG],bit1 ; po‘adavek ulo‘it XFLOP.COM
         ret

; ------ "T" - po‡et stop

RozbTT:  call      RozbNumB
         or        al,al                    ; nˆco zad no ?
         jz        RozbTT2                  ; nic nezad no
         cmp       al,120
         jbe       RozbTT1
         mov       al,120
RozbTT1: mov       ds:[Stop+KORIG],al       ; po‡et stop
RozbTT2: ret

; ------ "U" - neprov dˆt veirifikaci

RozbTU:  or        byte ptr ds:[RParam+KORIG],bit2 ; neprov dˆt verifikaci
         ret

; ------ "V" - jmenovka disku

RozbTV:  call      RozbSpc                  ; vypu¨tˆn¡ mezer
         jc        RozbTV6
         cmp       al,'"'
         jne       RozbTV6
         call      RozbChr                  ; vypu¨tˆn¡ znaku uvozovek
         mov       di,offset BootLabl+KORIG ; buffer n vˆ¨t¡ disku
         push      ds
         pop       es
         mov       cx,11
         mov       al," "
         push      di
         rep       stosb                    ; vymaz n¡ bufferu n vˆ¨t¡
         pop       di
         or        byte ptr ds:[RParam3+KORIG],bit0 ; po‘adavek ulo‘it LABEL
         and       byte ptr ds:[RParam3+KORIG],not bit3 ; LABEL se neinkrementuje
         mov       word ptr ds:[LabEnd+KORIG],di ; adresa posledn¡ ‡¡slice LABEL

RozbTV2: call      RozbChr                  ; na‡ten¡ dal¨¡ho znaku
         jc        RozbTV6                  ; nen¡ dal¨¡ znak
         cmp       al,'"'                   ; jsou koncov‚ uvozovky ?
         je        RozbTV6                  ; jsou koncov‚ uvozovky
         cmp       di,offset BootLab0+KORIG ; je konec bufferu n vˆ¨t¡ ?
         jae       RozbTV2                  ; je konec bufferu n vˆ¨t¡
         cmp       al,"0"
         jb        RozbTV4                  ; nen¡ ‡¡slice
         cmp       al,"9"
         ja        RozbTV4                  ; nen¡ ‡¡slice
         mov       word ptr ds:[LabEnd+KORIG],di ; adresa posledn¡ ‡¡slice LABEL
RozbTV4: stosb                              ; ulo‘en¡ znaku do bufferu
         jmp       short RozbTV2            ; dal¨¡ znak

RozbTV6: ret

; ------ "W" - po‡et testovac¡ch z pis–

RozbTW:  call      RozbNum
         mov       ds:[TestWrit+KORIG],ax   ; po‡et testovac¡ch z pis–
         ret

; ------ "X" - odsazov n¡ mezi stranami

RozbTX:  call      RozbNumB
         cmp       al,MAXSEKT
         jb        RozbTX2
         mov       al,MAXSEKT
RozbTX2: mov       ds:[SlideX+KORIG],al
         ret

; ------ "Y" - odsazov n¡ mezi stopami

RozbTY:  call      RozbNumB
         cmp       al,MAXSEKT
         jb        RozbTY2
         mov       al,MAXSEKT
RozbTY2: mov       ds:[SlideY+KORIG],al
         ret

;; ------ "Z"
;
;RozbTZ:
;         ret


; ------ "1" - jednostrann‚ form tov n¡

RozbT1:  mov       byte ptr ds:[Stran+KORIG],1   ; 1 strana
         ret


; ------ "4" - 40 stop

RozbT4:  mov       byte ptr ds:[Stop+KORIG],40   ; 40 stop
         ret

; ------ "8" - 8 sektor–

RozbT8:  mov       byte ptr ds:[Sektoru+KORIG],8 ; 8 sektor–
         ret


; ------ "!" - odinstalov n¡ z pamˆti

RozbT_X: or        byte ptr ds:[Param],bit1 ; po‘adov no odinstalov n¡
         ret

; -----------------------------------------------------------------------------
;        na‡ten¡ ‡¡sla z p©¡kazov‚ho © dku -> AX (omezen¡ na bajt)
; -----------------------------------------------------------------------------

RozbNumB PROC      NEAR

         push      dx
         call      RozbNum
         or        ah,ah
         jz        RozbNmB1
         mov       ax,255
RozbNmB1:pop       dx
         ret

RozbNumB ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ ‡¡sla z p©¡kazov‚ho © dku -> AX=cel  ‡ st, DX=desetinn  ‡ st
; -----------------------------------------------------------------------------

RozbNum  PROC      NEAR

; ------ vypu¨tˆn¡ mezer p©ed ‡¡slem

         call      RozbSpc                  ; vypu¨tˆn¡ mezer
         jc        RozbNum0
         cmp       al,"$"
         jne       RozbNum0
         call      RozbChr                  ; vypu¨tˆn¡ znaku "$"
         jmp       RozbHex                  ; na‡ten¡ ‡¡sla HEX

; ------ £schova registr–

RozbNum0:push      bx
         push      cx
         push      di
         push      bp

; ------ p©¡prava registr–

         xor       bx,bx                    ; BX <- st©ada‡ ‡¡sla (cel  ‡ st)
         xor       cx,cx                    ; CX <- st©ada‡ ‡¡sla (desetiny)

         mov       bp,10                    ; n sobitel a dˆlitel
         mov       di,6554                  ; (65536/10) desetina

; ------ celo‡¡seln  ‡ st

RozbNum1:call      RozbNm                   ; na‡ten¡ ‡¡slice
         jc        RozbNum2                 ; nen¡ dal¨¡ ‡¡slice
         xchg      ax,bx                    ; BX <- nov  ‡¡slice
         mul       bp                       ; st©ada‡ * 10
         add       bx,ax                    ; p©i‡ten¡ ‡¡slice ke st©ada‡i
         adc       dx,dx                    ; je p©ete‡en¡ ?
         jz        RozbNum1
         mov       bx,-1                    ; omezen¡ ‡¡sla
         jmp       short RozbNum1           ; dal¨¡ ‡¡slice

; ------ p©esko‡en¡ oddˆlova‡e desetin

RozbNum2:cmp       al,","                   ; je ‡ rka ?
         je        RozbNum3                 ; je ‡ rka, budou desetiny
         cmp       al,"."                   ; je te‡ka ?
         jne       RozbNum9                 ; nen¡ ani te‡ka - konec ‡¡sla
RozbNum3:call      RozbChr                  ; p©esko‡en¡ znaku te‡ky nebo ‡ rky

; ------ na‡ten¡ desetinn‚ ‡ sti

RozbNum4:call      RozbNm                   ; na‡ten¡ dal¨¡ ‡¡slice
         jc        RozbNum9                 ; konec ‡¡sla
         mul       di                       ; vyn soben¡ desetiny
         add       cx,ax                    ; p©i‡ten¡ ke st©ada‡i desetin
         xchg      ax,di                    ; AX <- ukazatel desetiny
         xor       dx,dx                    ; DX <- 0
         div       bp                       ; posun desetin o © d dol–
         xchg      ax,di                    ; DI <- nov˜ ukazatel desetiny
         jmp       short RozbNum4           ; dal¨¡ ‡¡slice

; ------ n vrat registr–

RozbNum9:xchg      ax,bx                    ; AX <- ‡¡slo
         mov       dx,cx                    ; DX <- desetiny
         pop       bp
         pop       di
         pop       cx
         pop       bx
         ret

RozbNum  ENDP

; ------ na‡ten¡ ‡¡sla HEX

RozbHex: push      bx
         xor       bx,bx                    ; st©ada‡
RozbHex1:call      RozbChr
         jc        RozbHex5
         cmp       al,"0"
         jb        RozbHex4
         cmp       al,"9"
         jbe       RozbHex2
         cmp       al,"A"
         jb        RozbHex4
         cmp       al,"F"
         ja        RozbHex4
         sub       al,7
RozbHex2:sub       al,"0"
         shl       bx,1
         shl       bx,1
         shl       bx,1
         shl       bx,1
         or        bl,al
         jmp       short RozbHex1

RozbHex4:dec       si
RozbHex5:xchg      ax,bx
         pop       bx
         ret

; -----------------------------------------------------------------------------
;        na‡ten¡ jedn‚ ‡¡slice -> AX (nen¡-li ‡¡slice, je v AL znak)
; -----------------------------------------------------------------------------

RozbNm   PROC      NEAR

         mov       ah,0
         call      RozbChr
         jc        RozbNm9
         cmp       al,"0"
         jb        RozbNm8
         cmp       al,"9"
         ja        RozbNm8
         sub       al,"0"
         ret

RozbNm8: dec       si
         stc
RozbNm9: ret

RozbNm   ENDP

; -----------------------------------------------------------------------------
;        vypu¨tˆn¡ mezer z p©¡kazov‚ho © dku
; -----------------------------------------------------------------------------

RozbSpc  PROC      NEAR

         call      RozbChr
         jc        RozbSpc2
         je        RozbSpc
         cmp       al,"/"
         je        RozbSpc
         cmp       al,":"
         je        RozbSpc
         cmp       al,"="
         je        RozbSpc

         dec       si
         clc
RozbSpc2:ret

RozbSpc  ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ znaku z p©¡kazov‚ho © dku
; -----------------------------------------------------------------------------

RozbChr  PROC      NEAR

         cld
         lodsb
         cmp       al,9
         jne       RozbChr2
         mov       al," "

RozbChr2:cmp       al,"a"
         jb        RozbChr3
         cmp       al,"z"
         ja        RozbChr3
         sub       al,32

RozbChr3:cmp       al," "
         jae       RozbChr4
         dec       si

RozbChr4:ret

RozbChr  ENDP

; *****************************************************************************
;
;                        Zobrazen¡ nastaven¡ parametr–
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        zobrazen¡ parametr– diskety
; -----------------------------------------------------------------------------

DispParm PROC      NEAR

; ------ zobrazen¡ £vodn¡ ‡ sti hl ¨en¡

         mov       dx,offset ParTxt
         call      DispTxt

; ------ zobrazen¡ kapacity v KB

         xor       dx,dx
         mov       ax,ds:[JmenKap+KORIG]
         cmp       ax,1000                  ; hranice pro MB
         jae       DispPrm2                 ; zobraz¡ se MB
         call      DispNum                  ; zobrazen¡ kapacity v KB
         mov       al,"K"
         jmp       short DispPrm3

; ------ zobrazen¡ kapacity v MB

DispPrm2:mov       bx,1000
         div       bx                       ; p©epo‡et na MB
         push      ax
         xor       ax,ax
         div       bx                       ; p©epo‡et
         xchg      ax,dx
         pop       ax
         call      DispNum                  ; zobrazen¡ kapacity v MB
         mov       al,"M"
DispPrm3:call      DispChr

; ------ zobrazen¡ po‡tu stop

         mov       dx,offset ParTxtT
         call      DispTxt
         mov       al,ds:[Stop+KORIG]
         call      DispNumB

; ------ zobrazen¡ po‡tu sektor–

         mov       dx,offset ParTxtN
         call      DispTxt
         mov       al,ds:[Sektoru+KORIG]
         call      DispNumB

; ------ po‡et hlav

         mov       dx,offset ParTxtH
         call      DispTxt
         mov       al,ds:[Stran+KORIG]
         call      DispNumB

; ------ krokov n¡

         mov       dx,offset ParTxtJ
         call      DispTxt
         mov       al,"1"
         test      byte ptr ds:[RParam+KORIG],bit6 ; je dvoj¡ krokov n¡ ?
         jz        DispPr31                 ; nen¡ dvoj¡ krokov n¡
         inc       ax                       ; jinak parametr "2"
DispPr31:call      DispChr

; ------ odsazov n¡ mezi stranami

         mov       dx,offset ParTxtX
         call      DispTxt
         mov       al,ds:[SlideX+KORIG]
         call      DispNumB

; ------ odsazov n¡ mezi stopami

         mov       dx,offset ParTxtY
         call      DispTxt
         mov       al,ds:[SlideY+KORIG]
         call      DispNumB

; ------ prokl d n¡

         mov       dx,offset ParTxtI
         call      DispTxt
         mov       al,ds:[Interl+KORIG]
         call      DispNumB

; ------ mezisektorov  mezera

         mov       dx,offset ParTxtG
         call      DispTxt
         mov       ax,ds:[Gap+KORIG]
         call      DispNum0

; ------ p©enosov  rychlost

         mov       dx,offset ParTxtO
         call      DispTxt
         cmp       byte ptr ds:[Rate+KORIG],1
         mov       ax,500
         jb        DispPr32
         mov       ax,300
         je        DispPr32
         cmp       byte ptr ds:[Rate+KORIG],2
         mov       ax,250
         je        DispPr32
         mov       ax,1000
DispPr32:call      DispNum0

; ------ po‡et sektor– na aloka‡n¡ blok

         mov       dx,offset ParTxtC
         call      DispTxt
         mov       al,ds:[Cluster+KORIG]
         call      DispNumB

; ------ po‡et polo‘ek na ROOT

         mov       dx,offset ParTxtR
         call      DispTxt
         mov       ax,ds:[Root+KORIG]
         mov       cl,4
         shl       ax,cl
         call      DispNum0

; ------ bajt popisova‡e m‚dia

         mov       dx,offset ParTxtM
         call      DispTxt
         mov       al,ds:[MediaB+KORIG]
         call      DispHex

; ------ pln¡c¡ znak dat

         mov       dx,offset ParTxtL
         call      DispTxt
         mov       al,ds:[FillCh+KORIG]
         call      DispHex

; ------ po‡et testovac¡ch z pis–

         mov       dx,offset ParTxtW
         call      DispTxt
         mov       ax,ds:[TestWrit+KORIG]
         call      DispNum0

; ------ neprov dˆt verifikaci

         test      byte ptr ds:[RParam+KORIG],bit2
         jz        DispPrm4
         mov       dx,offset ParTxtU
         call      DispTxt

; ------ jmenovka disku

DispPrm4:test      byte ptr ds:[RParam3+KORIG],bit0
         jz        DispPr44                 ; neukl d  se LABEL
         mov       si,offset BootLabl+KORIG
         mov       di,offset ParTxtV1
         mov       cx,11
         cld
         push      ds
         pop       es
         rep       movsb
DispPr41:cmp       byte ptr ds:[di-1]," "
         jne       DispPr42
         dec       di
         cmp       di,offset ParTxtV1
         ja        DispPr41
DispPr42:mov       ax,'"'
         stosw
         mov       dx,offset ParTxtV
         call      DispTxt

; ------ ukl d  se XFLOP.COM

DispPr44:test      byte ptr ds:[RParam3+KORIG],bit1 ; ukl d  se XFLOP.COM ?
         jz        DispPr46                 ; neukl d  se XFLOP.COM
         mov       dx,offset ParTxtS
         call      DispTxt

; ------ zvukov  indikace konce

DispPr46:test      byte ptr ds:[RParam+KORIG],bit0
         jz        DispPrm5                 ; nen¡ zvukov  indikace
         mov       dx,offset ParTxtE
         call      DispTxt

; ------ form tov n¡ v¡ce disket

DispPrm5:test      byte ptr ds:[RParam+KORIG],bit1
         jz        DispPrm6
         mov       dx,offset ParTxtP
         call      DispTxt

; ------ po‡et sektor– FAT

DispPrm6:mov       dx,offset ParTxtFA
         call      DispTxt
         mov       ax,ds:[FATSekt+KORIG]
         call      DispNum0

; ------ nevyu‘it‚ sektory

         mov       dx,offset ParTxtZB
         call      DispTxt
         mov       al,ds:[Nevyuzit+KORIG]
         call      DispNumB

; ------ voln  kapacita

         mov       dx,offset ParTxtVO
         call      DispTxt
         mov       ax,word ptr ds:[Cluster+KORIG]    ; po‡et sektor– na aloka‡n¡ blok
         mul       word ptr ds:[NumClust+KORIG] ; po‡et datov˜ch sektor– celkem
         mov       dx,512
         mul       dx                       ; voln  kapacita v bajtech
         call      DispNumD

; ------ po‡et aloka‡n¡ch blok–

         mov       dx,offset ParTxtBL
         call      DispTxt
         mov       ax,ds:[NumClust+KORIG]
         call      DispNum0

; ------ zbytek textu

         mov       dx,offset ParTxt0
         call      DispTxt
         ret

DispParm ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ textu DS:DX
; -----------------------------------------------------------------------------

DispTxt  PROC      NEAR

         push      ax
         push      si

         mov       si,dx
DispTxt1:cld
         lodsb
         cmp       al,0
         je        DispTxt2
         call      DispChr
         jmp       short DispTxt1

DispTxt2:pop       si
         pop       ax
         ret

DispTxt  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ ‡¡sla DOS v AX (DX=desetiny)
; -----------------------------------------------------------------------------

DispNumB:mov       ah,0

DispNum0:xor       dx,dx

DispNum  PROC      NEAR

         push      dx
         push      di
         push      es

         push      ds
         pop       es
         mov       di,offset BuffNum
         push      di
         call      DekNum
         pop       dx
         call      DispTxt

         pop       es
         pop       di
         pop       dx
         ret

DispNum  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ ‡¡sla DX:AX
; -----------------------------------------------------------------------------

DispNumD PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di

         mov       si,10
         xor       cx,cx
DispNmD2:xchg      ax,bx                    ; BX <- LOW
         cmp       cl,3
         jne       DispNmD3
         mov       al,"."
         push      ax
         inc       cx
DispNmD3:cmp       cl,7
         jne       DispNmD4
         mov       al,"."
         push      ax
         inc       cx
DispNmD4:xchg      ax,dx                    ; AX <- HIGH
         xor       dx,dx                    ; DX <- 0
         div       si                       ; vydˆlen¡ HIGH / 10
         xchg      ax,bx                    ; AX <- LOW, BX <- nov‚ HIGH
         div       si                       ; vydˆlen¡ LOW
         add       dl,"0"                   ; ‡¡slice
         push      dx
         inc       cx                       ; ‡¡ta‡ znak–
         mov       dx,bx                    ; n vrat HIGH
         or        bx,ax                    ; je ji‘ 0 ?
         jnz       DispNmD2                 ; dal¨¡ ‡¡slice

DispNmD6:pop       ax
         call      DispChr
         loop      DispNmD6

         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispNumD ENDP

; -----------------------------------------------------------------------------
;    dek¢dov n¡ ‡¡sla v AX (DX=desetiny) do bufferu ES:DI -> DI konec (ozna‡¡ 0)
; -----------------------------------------------------------------------------

DekNum   PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx
         push      si

         mov       si,dx                    ; SI <- £schova detesin

         cld
         xor       cx,cx
         mov       bx,10
DekNum1: xor       dx,dx
         div       bx
         push      dx
         inc       cx
         or        ax,ax
         jnz       DekNum1

DekNum2: pop       ax
         add       al,"0"
         stosb
         loop      DekNum2

         inc       si                       ; zaokrouhlen¡ nahoru

         mov       al,"."                   ; oddˆlovac¡ te‡ka
         stosb

         mov       cl,3                     ; max. ‡¡slic
DekNum3: xchg      ax,si                    ; AX <- desetiny
         mul       bx                       ; v˜po‡et dal¨¡ ‡¡slice
         xchg      ax,si                    ; SI <- £schova nov‚ho stavu
         xchg      ax,dx
         add       al,"0"
         stosb
         loop      DekNum3                  ; dek¢dov n¡ dal¨¡ho ‡¡sla

DekNum4: cmp       byte ptr es:[di-1],"0"
         jne       DekNum5
         dec       di
         jmp       short DekNum4

DekNum5: cmp       byte ptr es:[di-1],"."
         jne       DekNum6
         dec       di

DekNum6: mov       byte ptr es:[di],0

         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DekNum   ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ bajtu HEX
; -----------------------------------------------------------------------------

DispHex  PROC      NEAR

         push      ax
         mov       al,"$"
         call      DispChr
         pop       ax

         push      ax
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1
         call      DispHx
         pop       ax

DispHx:  push      ax
         and       al,0fh
         cmp       al,10
         jb        DispHx2
         add       al,7
DispHx2: add       al,"0"
         call      DispChr
         pop       ax
         ret

DispHex  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ znaku DOS
; -----------------------------------------------------------------------------

DispChr  PROC      NEAR

         push      ax
         push      dx
         xchg      ax,dx
         mov       ah,2
         int       21h
         pop       dx
         pop       ax
         ret

DispChr  ENDP

; *****************************************************************************
;
;                           Detekce parametr– disket
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        detekce parametr– diskety (disk je zad n)
; -----------------------------------------------------------------------------

DetParm  PROC      NEAR

         mov       bl,ds:[TypDisk+KORIG]    ; typ mechaniky
         mov       dx,ds:[JmenKap+KORIG]    ; jmenovit  kapacita mechaniky

; ------ STOP: implicitn¡ po‡et stop

         mov       al,ds:[Stop+KORIG]       ; po‡et stop
         cmp       al,-1                    ; zad n po‡et stop ?
         jne       DetParm1                 ; po‡et stop zad n
         mov       al,40                    ; po‡et stop pro 360 KB
         cmp       bl,M360                  ; mechanika 360 KB ?
         je        DetParm1                 ; mechanika 360 KB
         cmp       dx,600                   ; hranice pro 80 stop
         jb        DetParm1                 ; je mal  kapacita
         mov       al,80                    ; jinak implicitnˆ 80 stop
DetParm1:cmp       al,120
         jbe       DetPrm12
         mov       al,120
DetPrm12:mov       ds:[Stop+KORIG],al       ; po‡et stop diskety


IFDEF    DEMO
         push      ax
         shr       al,1                     ; polovi‡n¡ po‡et stop
         cmp       al,DEMOTRK               ; omezen¡ stopy
         jb        DetPrm13                 ; stopa je OK
         mov       al,DEMOTRK               ; omezen¡ stopy
DetPrm13:mov       ds:[DemoStop+KORIG],al   ; DEMO stopa
         pop       ax
ENDIF

; ------ krokov n¡ hlav

         test      byte ptr ds:[Param],bit6 ; zad no krokov n¡ ?
         jnz       DetPrm14                 ; zad no krokov n¡
         and       byte ptr ds:[RParam+KORIG],not bit6 ; nen¡ dvoj¡ krokov n¡
         cmp       bl,M360
         je        DetPrm14                 ; je jednoduch‚ krokov n¡
         cmp       al,50                    ; je m lo stop ?
         jae       DetPrm14                 ; je dost stop
         or        byte ptr ds:[RParam+KORIG],bit6 ; je dvoj¡ krokov n¡

; ------ STRAN: implicitn¡ po‡et stran

DetPrm14:mov       al,ds:[Stran+KORIG]      ; po‡et stran
         cmp       al,-1                    ; zad n po‡et stran ?
         jne       DetParm2                 ; po‡et stran zad n
         mov       al,1                     ; 1 strana
         cmp       dx,280                   ; hranice pro 1 stranu
         jb        DetParm2                 ; bude 1 strana
         mov       al,2                     ; jinak 2 strany
DetParm2:mov       ds:[Stran+KORIG],al      ; po‡et stran diskety
         mov       byte ptr ds:[BootSide+KORIG],al ; po‡et stran diskety

; ------ SEKTORU: implicitn¡ po‡et sektor–

         mov       al,ds:[Sektoru+KORIG]    ; po‡et sektor– na stopu
         cmp       al,-1                    ; zad n po‡et sektor– ?
         jne       DetParm5                 ; po‡et sektor– zad n
         cmp       dx,-1                    ; zad na jmenovit  kapacita ?
         jne       DetParm4                 ; jmenovit  kapacita zad na

; ------ implicitn¡ po‡et sektor– podle typu mechaniky (nezad na kapacita)

         cmp       byte ptr ds:[Stop+KORIG],50 ; po‡et stop
         jb        DetParm3                 ; pro m lo stop - disketa DD
         mov       al,15                    ; disketa HD 5 1/4"
         cmp       bl,M120                  ; mechanika HD 1.2MB
         je        DetParm5
         mov       al,18                    ; disketa HD 3 1/2"
         cmp       bl,M144                  ; mechanika HD 1.44 MB
         je        DetParm5
         mov       al,36                    ; disketa QD 3 1/2"
         cmp       bl,M288                  ; mechanika QD 2.88 MB
         je        DetParm5
DetParm3:mov       al,9                     ; jinak disketa DD
         jmp       short DetParm5

; ------ implicitn¡ po‡et sektor– z kapacity diskety

DetParm4:push      dx                       ; jmenovit  kapacita
         mov       al,ds:[Stran+KORIG]      ; po‡et stran
         mul       byte ptr ds:[Stop+KORIG] ; po‡et stop na cel‚m povrchu diskety
         xchg      ax,cx                    ; CX <- po‡et stop celkem na povrchu
         pop       ax                       ; AX <- jmenovit  kapacita
         mov       dx,1024/512              ; konstanta pro p©epo‡et na sektory
         mul       dx                       ; p©epo‡et kapacity v KB na sektory
         div       cx                       ; v˜po‡et po‡tu sektor– na stopu
         cmp       al,MAXSEKT
         jb        DetPrm42
         mov       al,MAXSEKT
DetPrm42:or        al,al                    ; je £daj OK ?
         jnz       DetParm5                 ; £daj je OK
         inc       ax                       ; minim lnˆ 1 sektor
DetParm5:mov       ds:[Sektoru+KORIG],al    ; po‡et sektor– na stopu
         mov       byte ptr ds:[BootSekt+KORIG],al ; po‡et sektor– na stopu

; ------ JMENKAP: v˜po‡et nov‚ jmenovit‚ kapacity (up©esnˆn‚)

         mul       byte ptr ds:[Stran+KORIG] ; po‡et sektor– na v¨echny strany
         mov       dx,word ptr ds:[Stop+KORIG] ; po‡et stop celkem
         mul       dx                       ; po‡et sektor– celkem
         mov       ds:[CelkSekt+KORIG],ax   ; celkov˜ po‡et sektor– disku
         mov       ds:[BootSumS+KORIG],ax   ; celkov˜ po‡et sektor– disku
         shr       ax,1                     ; jmenovit  kapacita v KB
         mov       ds:[JmenKap+KORIG],ax    ; nov  jmenovit  kapacita

; ------ RATE: p©enosov  rychlost

         mov       ah,ds:[Sektoru+KORIG]    ; po‡et sektor– na stopu
         mov       al,ds:[Rate+KORIG]       ; p©enosov  rychlost
         cmp       al,-1
         jne       DetPrm51                 ; rychlost zad na
         cmp       ah,13
         ja        DetPrm50                 ; je HD nebo QD
         mov       al,1                     ; 300 Kb/s
         cmp       bl,M120
         je        DetPrm5A                 ; mechanika 1.2 MB
         cmp       ah,11
DetPrm5B:jae       DetPrm51                 ; 11 a‘ 13 sektor– - je 300 Kb/s
         mov       al,2                     ; jinak 250 Kb/s
         jmp       short DetPrm51

DetPrm5A:cmp       ah,8                     ; 8 a v¡ce sektor– = 300 Kb/s
         jmp       short DetPrm5B           ; nebo 7 a m‚nˆ = 250 Kb/s

DetPrm50:mov       al,0                     ; 500 Kb/s
         cmp       ah,22
         jbe       DetPrm51                 ; je HD
         mov       al,3                     ; jinak 1 Mb/s pro QD
DetPrm51:mov       ds:[Rate+KORIG],al

; ------ GAP: mezisektorov  mezera

         mov       ax,ds:[Gap+KORIG]
         cmp       ax,-1
         jne       DetParm6

         push      bx
         mov       bl,ds:[Rate+KORIG]       ; p©enosov  rychlost
         mov       bh,0
         shl       bx,1                     ; p©enosov  rychlost * 2
         shl       bx,1
         mov       ax,word ptr ds:[RateTab+bx] ; p©enosov  rychlost
         mov       dx,word ptr ds:[RateTab+bx+2]
         pop       bx
         mov       cx,5                     ; 5 ot ‡ek za sekundu
         cmp       bl,M120
         jne       DetPrm52
         mov       cl,6                     ; pro mechaniku 1.2 MB je 6 ot ‡ek
DetPrm52:div       cx                       ; v˜po‡et po‡tu bajt– na stopu
         xor       dx,dx
         div       word ptr ds:[Sektoru+KORIG] ; po‡et bajt– na sektor
         sub       ax,512+62                ; zbytek na mezeru
         jae       DetPrm53                 ; je to OK
         xor       ax,ax                    ; minim ln¡ mezera
DetPrm53:sub       ax,40                    ; tady bude zlom
         jb        DetPrm54                 ; je men¨¡ mezera
         shr       ax,1                     ; korekce 80+40 -> 40+40
DetPrm54:add       ax,40                    ; navr cen¡ zlomu
         jnz       DetPrm55                 ; je mezera minim lnˆ 1
         inc       ax                       ; korekce mezery na minim lnˆ 1
DetPrm55:or        ah,ah                    ; je v¡ce ne‘ 255 bajt– ?
         jz        DetParm6                 ; nen¡ v¡ce
         mov       al,255                   ; omezen¡ na 255 bajt–
DetParm6:mov       ah,0
         mov       ds:[Gap+KORIG],ax

; ------ INTERL: prokl d n¡ sektor–

         mov       al,ds:[Interl+KORIG]     ; prokl d n¡ sektor–
         cmp       al,-1
         jne       DetParm7                 ; zad no

         mov       ah,42                    ; omezen¡ GAP pro DD
         cmp       byte ptr ds:[Rate+KORIG],1 ; 300 kb/s ?
         je        DetPrm62                 ; je DD
         cmp       byte ptr ds:[Rate+KORIG],2 ; 250 kb/s ?
         je        DetPrm62                 ; je DD
         mov       ah,27                    ; omezen¡ GAP pro HD a QD

DetPrm62:mov       al,1                     ; nen¡ prokl d n¡
         cmp       byte ptr ds:[GAP+KORIG],ah ; je nutn‚ prokl d n¡ ?
         jae       DetParm7                 ; nen¡ nutn‚ prokl d n¡
         mov       al,2                     ; prokl d n¡ p©es sektor
DetParm7:cmp       al,ds:[Sektoru+KORIG]
         jb        DetPrm70
         mov       al,ds:[Sektoru+KORIG]
DetPrm70:mov       ds:[Interl+KORIG],al

; ------ zmen¨en¡ mezery GAP, je-li prokl d n¡ (je zbyte‡n‚, aby byla)

         test      byte ptr ds:[Param],bit7 ; zad na mezera GAP ?
         jnz       DetPrm64                 ; zad na mezera GAP
         cmp       al,1                     ; je prokl d n¡ ?
         je        DetPrm64                 ; nen¡ prokl d n¡
         shr       byte ptr ds:[Gap+KORIG],1 ; sn¡‘en¡ mezery GAP p©i prokl d n¡
         jnz       DetPrm64
         inc       byte ptr ds:[Gap+KORIG]  ; minim lnˆ 1 mezera

; ------ SLIDEX: odsazov n¡ mezi stranami

DetPrm64:mov       al,ds:[SlideX+KORIG]
         cmp       al,-1
         jne       DetPrm71

         mov       al,ds:[SlideY+KORIG]     ; odsazen¡ Y
         dec       al                       ; X = Y-1
         jns       DetPrm71                 ; Y mˆlo rozumnou hodnotu

         mov       al,3                     ; odsazen¡ 3 pro QD diskety
         cmp       byte ptr ds:[Rate+KORIG],3
         je        DetPrm71                 ; disketa QD
         dec       ax                       ; odsazen¡ 2 pro HD diskety
         cmp       byte ptr ds:[Rate+KORIG],0
         je        DetPrm71                 ; disketa HD
         dec       ax                       ; jinak odsazen¡ 1 pro diskety DD
DetPrm71:cmp       al,ds:[Sektoru+KORIG]
         jb        DetPr712
         mov       al,ds:[Sektoru+KORIG]
DetPr712:mov       ds:[SlideX+KORIG],al

; ------ SLIDEY: odsazov n¡ mezi stopami

         mov       al,ds:[SlideY+KORIG]
         cmp       al,-1
         jne       DetPrm72

         mov       al,ds:[SlideX+KORIG]     ; odsazen¡ X
         inc       ax                       ; odsazen¡ Y = X+1

         cmp       byte ptr ds:[Stop+KORIG],50 ; je m lo stop ?
         jae       DetPrm72                 ; je dost stop
         inc       ax                       ; odsazen¡ Y = X+2 (dˆl  vˆt¨¡ krok)

DetPrm72:cmp       al,ds:[Sektoru+KORIG]
         jb        DetPr722
         mov       al,ds:[Sektoru+KORIG]
DetPr722:mov       ds:[SlideY+KORIG],al

; ------ MEDIAB: popisova‡ m‚dia

         mov       al,ds:[MediaB+KORIG]     ; popisova‡ m‚dia
         test      byte ptr ds:[Param],bit5 ; zad n popisova‡ m‚dia ?
         jnz       DetPrm75                 ; popisova‡ m‚dida zad n
         cmp       byte ptr ds:[Stop+KORIG],50 ; mal˜ po‡et stop ?
         jb        DetPrm73                 ; je mal˜ po‡et stop

         mov       al,0f9h                  ; mal˜ po‡et sektor–
         cmp       byte ptr ds:[Sektoru+KORIG],16
         jbe       DetPrm75                 ; je mal˜ po‡et sektor–
         mov       al,0f0h                  ; velk˜ po‡et sektor–
         jmp       short DetPrm75

DetPrm73:mov       al,0feh                  ; mal˜ po‡et stop i sektor–
         cmp       byte ptr ds:[Sektoru+KORIG],8
         jbe       DetPrm74                 ; je mal˜ po‡et sektor–
         mov       al,0fch                  ; m lo stop, ale dost sektor–
DetPrm74:cmp       byte ptr ds:[Stran+KORIG],1 ; je 1 strana ?
         je        DetPrm75                 ; je 1 strana
         or        al,bit0                  ; korekce pro 2 strany
DetPrm75:mov       ds:[MediaB+KORIG],al
         mov       ds:[BootMedD+KORIG],al

; ------ ROOT: po‡et sektor– na ROOT

         mov       ax,ds:[Root+KORIG]       ; po‡et sektor– na ROOT
         cmp       ax,-1
         jne       DetPrm77                 ; po‡et polo‘ek ROOT byl zad n
         mov       ax,7                     ; diskety DD
         cmp       byte ptr ds:[Sektoru+KORIG],14
         jb        DetPrm76
         mov       al,14                    ; diskety HD
         cmp       byte ptr ds:[Sektoru+KORIG],23
         jb        DetPrm76
         mov       al,15                    ; jinak diskety QD
DetPrm76:cmp       byte ptr ds:[Stran+KORIG],1 ; je 1 strana ?
         ja        DetPrm77                 ; je v¡c stran
         shr       ax,1                     ; polovi‡n¡ po‡et ROOT
         cmp       al,4                     ; bylo 7 sektor– ?
         ja        DetPrm77                 ; bylo v¡ce
         inc       ax                       ; korekce
DetPrm77:mov       ds:[Root+KORIG],ax
         shl       ax,1
         shl       ax,1
         shl       ax,1
         shl       ax,1
         mov       ds:[BootRoot+KORIG],ax   ; po‡et polo‘ek ROOT

; ------ CLUSTER: po‡et sektor– na aloka‡n¡ blok

         mov       al,ds:[Cluster+KORIG]
         cmp       al,-1                    ; po‡et sektor– zad n ?
         jne       DetPrm78                 ; zad n
         mov       al,1                     ; 1 sektor na blok
         cmp       byte ptr ds:[Stran+KORIG],1 ; je v¡ce stran ?
         je        DetPrm78                 ; je jen 1 strana
         cmp       byte ptr ds:[Sektoru+KORIG],14 ; je disketa HD ?
         jae       DetPrm78                 ; je disketa HD
         inc       ax                       ; 2 sektory na blok
DetPrm78:mov       ds:[Cluster+KORIG],al    ; po‡et sektor– na aloka‡n¡ blok
         mov       ds:[BootClst+KORIG],al   ; po‡et sektor– na aloka‡n¡ blok

; ------ FATSEKT: ur‡en¡ po‡tu sektor– pro tabulky FAT

; ------ po‡et aloka‡n¡ch blok–

DetParm8:mov       word ptr ds:[FatSekt+KORIG],1 ; v˜choz¡ hodnota-1 sektor na FAT
DetPrm81:mov       ax,ds:[CelkSekt+KORIG]   ; celkov˜ po‡et sektor–
         dec       ax                       ; ode‡ten¡ BOOT sektoru
         mov       bx,ds:[FatSekt+KORIG]    ; po‡et sektor– na FAT (prozat¡mn¡)
         sub       ax,bx                    ; ode‡ten¡ sektor– na FAT 1
         sub       ax,bx                    ; ode‡ten¡ sektor– na FAT 2
         sub       ax,ds:[Root+KORIG]       ; ode‡ten¡ sektor– na ROOT
         xor       dx,dx                    ; DX <- 0
         mov       bl,ds:[Cluster+KORIG]    ; po‡et sektor– na aloka‡n¡ blok
         div       bx                       ; v˜po‡et po‡tu aloka‡n¡ch blok–
         mov       ds:[NumClust+KORIG],ax   ; celkov˜ po‡et aloka‡n¡ch blok–
         mov       ds:[Nevyuzit+KORIG],dl   ; po‡et p©eb˜vaj¡c¡ch sektor–

; ------ v˜po‡et kapacity tabulek FAT

         mov       ah,byte ptr ds:[FatSekt+KORIG] ; po‡et sektor– na FAT
         mov       al,0
         shl       ax,1                     ; po‡et bajt– na FAT
         shl       ax,1                     ; po‡et tetr d
         xor       dx,dx                    ; DX <- 0
         mov       bl,3                     ; po‡et tetr d na polo‘ku FAT
         div       bx                       ; v˜po‡et po‡tu polo‘ek FAT
         dec       ax
         dec       ax                       ; ode‡ten¡ rezervovan˜ch hodnot

; ------ kontrola, zda je po‡et polo‘ek FAT posta‡uj¡c¡

         cmp       ax,ds:[NumClust+KORIG]   ; sta‡¡ po‡et polo‘ek FAT ?
         jae       DetPrm82                 ; po‡et polo‘ek FAT je posta‡uj¡c¡
         inc       word ptr ds:[FatSekt+KORIG] ; zv˜¨en¡ po‡tu polo‘ek FAT
         jmp       short DetPrm81           ; nov˜ test

; ------ kontrola, zda je p©ekro‡en po‡et aloka‡n¡ch blok–

DetPrm82:cmp       word ptr ds:[NumClust+KORIG],0ff6h-2 ; p©ekro‡en max. po‡et blok– ?
         jb        DetPrm83                 ; po‡et blok– je OK
         shl       byte ptr ds:[Cluster+KORIG],1 ; zv˜¨en¡ po‡tu sektor– na blok
         jmp       short DetParm8           ; nov˜ v˜po‡et FAT

DetPrm83:mov       ax,ds:[FatSekt+KORIG]    ; po‡et sektor– na FAT
         mov       ds:[BootFATS+KORIG],ax   ; po‡et sektor– na FAT

; ------ DATSEKT: po‡ te‡n¡ datov˜ sektor (absolutnˆ) (AX=po‡et sektor– na FAT!)

         shl       ax,1                     ; po‡et sektor– na obˆ FAT
         inc       ax                       ; p©i‡ten¡ BOOT
         add       ax,ds:[Root+KORIG]       ; p©i‡ten¡ sektor– na ROOT
         mov       ds:[DatSekt+KORIG],ax    ; po‡ te‡n¡ datov˜ sektor
         mov       ds:[XFlopAbs+KORIG],ax   ; absolutn¡ sektor s XFLOP.COM



         ret

DetParm  ENDP

; ------ tabulka p©enosov˜ch rychlost¡

RateTab  dd        500000/8                 ; 500 kb/s
         dd        300000/8                 ; 300 kb/s
         dd        250000/8                 ; 250 kb/s
         dd        1000000/8                ; 1000 kb/s

; -----------------------------------------------------------------------------
;        detekce typu zadan‚ho disku (CY=chyba, DX=text chyby)
; -----------------------------------------------------------------------------

DetDisk  PROC      NEAR

; ------ maska disku

         mov       cl,ds:[Disk+KORIG]       ; ‡¡slo disku
         mov       al,bit0
         shl       al,cl                    ; rotace na pozici
         mov       ds:[DiskMask+KORIG],al   ; maska disku

; ------ na‡ten¡ typu disku z CMOS

         mov       ah,ds:[Disk+KORIG]       ; zadan˜ disk
         call      GetTDisk                 ; ‡ten¡ typu disku z CMOS
         jnc       DetDisk8                 ; disk detekov n OK
         call      TestCMOS                 ; je pamˆŸ CMOS ?
         mov       al,1                     ; mechanika 360 KB (asi je XT)
         jc        DetDisk8                 ; nen¡ pamˆŸ CMOS, asi je XT

; ------ chyba - disk nen¡ v po‡¡ta‡i

         mov       al,ds:[Disk+KORIG]
         add       al,"A"
         mov       ds:[NDiskTx1],al
         mov       dx,offset NDiskTxt
         stc                                ; p©¡znak chyby
         ret

; ------ ulo‘en¡ typu mechaniky

DetDisk8:mov       ds:[TypDisk+KORIG],al    ; typ mechaniky
         clc                                ; p©¡znak operace OK
         ret

DetDisk  ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ typu mechaniky AH z CMOS -> AL (CY=neplatn˜ disk)
; -----------------------------------------------------------------------------

GetTDisk PROC      NEAR

         push      cx

         call      TestCMOS                 ; test pamˆti CMOS
         jc        GetTDsk3                 ; neplatn  CMOS

         mov       al,ah                    ; AL <- ‡¡slo mechaniky 0=A:, 1=B:
         inc       ax                       ; 1=A:, 2=B:
         shl       al,1
         shl       al,1                     ; 4=A:, 8=B:
         xchg      ax,cx                    ; CL <- 4=A:, 8=B:

         mov       ah,10h                   ; ‡¡slo registru CMOS
         call      ReadCMOS                 ; na‡ten¡ registru z CMOS -> AL
         rol       al,cl                    ; rotace ‡¡sla na pozici
         and       al,0fh                   ; ‡¡slo mechaniky

         cmp       al,1                     ; minim ln¡ ‡¡slo 1
         jb        GetTDsk2                 ; neplatn˜ disk
         cmp       al,6                     ; maxim ln¡ ‡¡slo 5
         cmc

GetTDsk2:mov       ah,ch                    ; n vrat registru AH
GetTDsk3:pop       cx
         ret

GetTDisk ENDP

; -----------------------------------------------------------------------------
;        test kontroln¡ho sou‡tu pamˆti CMOS -> CY=neplatn  pamˆŸ
; -----------------------------------------------------------------------------

TestCMOS PROC      NEAR

; ------ £schova registr–

         push      ax
         push      dx

; ------ kontroln¡ sou‡et CMOS

         xor       dx,dx                    ; st©ada‡ kontroln¡ho sou‡tu
         mov       ah,10h                   ; ukazatel ‡¡sla registru
TestCMS2:call      ReadCMOS                 ; ‡ten¡ bajtu
         add       dl,al                    ; p©i‡ten¡
         adc       dh,0
         inc       ah                       ; zv˜¨en¡ ukazatele
         cmp       ah,2eh
         jne       TestCMS2                 ; dal¨¡ bajt

; ------ kontrola kontroln¡ho sou‡tu

         call      ReadCMOS                 ; ‡ten¡ bajtu 2Eh
         cmp       al,dh                    ; souhlas¡ sou‡et HIGH ?
         jne       TestCMS8                 ; nesouhlas¡
         inc       ah
         call      ReadCMOS                 ; ‡ten¡ bajtu 2Fh
         cmp       al,dl                    ; souhlas¡ sou‡et LOW ?
         je        TestCMS9                 ; souhlas¡ OK
TestCMS8:stc                                ; p©¡znak chyby

; ------ n vrat registr–

TestCMS9:pop       dx
         pop       ax
         ret

TestCMOS ENDP

; -----------------------------------------------------------------------------
;        ‡ten¡ bajtu z pamˆti CMOS (adresa AH) -> AL
; -----------------------------------------------------------------------------

ReadCMOS PROC      NEAR

         xchg      al,ah
         out       [70h],al                 ; nastaven¡ adresy
         xchg      al,ah
         jmp       short $+2
         jmp       short $+2
         jmp       short $+2
         in        al,[71h]                 ; na‡ten¡ hodnoty CMOS
         ret

ReadCMOS ENDP

; *****************************************************************************
;
;                         Obsluha zobrazen¡ operace
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        zobrazen¡ operace (mus¡ b˜t nainstalov n)
; -----------------------------------------------------------------------------

Zobraz   PROC      NEAR

; ------ inicializace videom¢du

         call      InitVMod                 ; inicializace videom¢du
         call      KurzOff                  ; vypnut¡ kurzoru

; ------ vymaz n¡ obrazovky

         call      Clear                    ; vymaz n¡ obrazovky

         mov       es,ds:[RezSegm]
         cmp       byte ptr es:[Disk+KORIG],-1
         je        Zobraz9

; ------ inicializace parametr– zobrazen¡

         call      InitZobr                 ; inicializace zobrazen¡

; ------ zobrazen¡ podkladu mapy

         call      ZobrPod                  ; zobrazen¡ podkladu mapy

; ------ zobrazen¡ aktu ln¡ho nastaven¡ parametr–

         call      ZobrPar                  ; zobrazen¡ nastaven¡ parametr–

; ------ zobrazen¡ mapy

Zobraz2: call      ZobrMap                  ; zobrazen¡ mapy
;         call      ZobrErr                  ; zobrazen¡ posledn¡ chyby
         call      ZobrVol                  ; zobrazen¡ voln‚ kapacity

; ------ sharewarov‚ demo

IFDEF    SHARE
         call      ZobrShar                 ; zobrazen¡ SHAREWARE
ENDIF

; ------ zobrazen¡ demo

IFDEF    DEMO
         call      ZobrDemo                 ; zobrazen¡ DEMO
ENDIF

; ------ zobrazen¡ chyb syst‚mov‚ oblasti

         call      ZobrSyst

; ------ zobrazen¡ jm‚na disku

         call      ZobrLab

; ------ zobrazen¡ s‚riov‚ho ‡¡sla

         call      ZobrSer                  ; zobrazen¡ s‚riov‚ho ‡¡sla

; ------ test, zda je stisk kl vesy

         mov       ah,1
         int       16h
         jnz       Zobraz9
         jmp       Zobraz2

; ------ vypr zdnˆn¡ bufferu kl vesnice

Zobraz9: mov       ah,0
         int       16h
         call      InitVMod
         ret

Zobraz   ENDP

; -----------------------------------------------------------------------------
;        sharewarov‚ demo
; -----------------------------------------------------------------------------
IFDEF    SHARE

ZobrShar PROC      NEAR

; ------ hodnota ‡asova‡e

         xor       bx,bx
         mov       es,bx
         mov       bl,es:[46ch]             ; syst‚mov˜ ‡asova‡
         shr       bl,1
         shr       bl,1
         and       bx,7
         mov       al,ds:[ZobrSTab+bx]

; ------ p©¡prava k zobrazen¡

         mov       es,ds:[AdrVRAM]          ; adresa videopamˆti
         mov       di,(6*80 + 7)*2 + 1
         mov       cx,67
         cld
ZobrShr4:stosb
         inc       di
         loop      ZobrShr4
         ret

ZobrShar ENDP

ZobrSTab label     byte
         db        74h
         db        71h
         db        78h
         db        71h
         db        75h
         db        71h
         db        78h
         db        71h
ENDIF

; -----------------------------------------------------------------------------
;        demo
; -----------------------------------------------------------------------------
IFDEF    DEMO

ZobrDemo PROC      NEAR

; ------ hodnota ‡asova‡e

         xor       bx,bx
         mov       es,bx
         mov       bl,es:[46ch]             ; syst‚mov˜ ‡asova‡
         shr       bl,1
         shr       bl,1
         and       bx,7
         mov       al,ds:[ZobrDTab+bx]

; ------ p©¡prava k zobrazen¡

         mov       es,ds:[AdrVRAM]          ; adresa videopamˆti
         mov       di,(6*80 + 7)*2 + 1
         mov       cx,67
         cld
ZobrDem4:stosb
         inc       di
         loop      ZobrDem4
         ret

ZobrDemo ENDP

ZobrDTab label     byte
         db        74h
         db        71h
         db        78h
         db        71h
         db        75h
         db        71h
         db        78h
         db        71h
ENDIF

; -----------------------------------------------------------------------------
;        zobrazen¡ mapy
; -----------------------------------------------------------------------------

ZobrMap  PROC      NEAR

; ------ p©¡prava ukazatel–

         mov       es,ds:[RezSegm]
         mov       dx,ds:[DTopPoz]          ; po‡ te‡n¡ pozice
         add       dx,101h                  ; pozice prvn¡ho bodu
         mov       ch,ds:[DRadku]           ; © dk–
         mov       cl,ds:[DPozic]           ; ¨¡©ka
         mov       bh,0                     ; ukazatel ‡¡sla stopy

ZobrMap1:mov       bl,0                     ; ukazatel ‡¡sla strany

; ------ £schova ukazatel– pro jeden © dek

ZobrMap2:push      dx
         push      cx
         push      bx

; ------ zobrazen¡ obsahu pol¡‡ka (BL=strana, BH=stopa)

ZobrMap3:call      GetMap                   ; stanoven¡ obsahu
         call      OutChr                   ; zobrazen¡ pol¡‡ka
         inc       bh                       ; zv˜¨en¡ ‡¡sla stopy
         cmp       bh,es:[Stop+KORIG]
         jae       ZobrMap8
         dec       cl
         jnz       ZobrMap3

; ------ n vrat ukazatel– pro jeden © dek

ZobrMap8:pop       bx
         pop       cx
         pop       dx

; ------ posun na dal¨¡ stranu

         inc       dh
         inc       bx                       ; zv˜¨en¡ ‡¡sla strany
         cmp       bl,es:[Stran+KORIG]      ; jsou ji‘ v¨echny strany ?
         jb        ZobrMap2                 ; dal¨¡ strana

; ------ posun ukazatel– na dal¨¡ © dek

         sub       dh,es:[Stran+KORIG]
         add       bh,ds:[DPozic]           ; posun ‡¡sla stopy
         add       dh,ds:[DPosun]           ; posun © dku
         dec       ch
         jnz       ZobrMap1                 ; dal¨¡ © dek
         ret

ZobrMap  ENDP

; -----------------------------------------------------------------------------
;        poskytnut¡ znaku operace (stopa BH, strana BL) -> AX
; -----------------------------------------------------------------------------

GetMap   PROC      NEAR

; ------ £schova registr–

         push      bx

IFDEF    DEMO
         push      cx
         mov       cx,bx                    ; CH <- stopa
ENDIF

         push      dx
         push      es

; ------ test, zda je aktu ln¡ operace

         mov       es,ds:[RezSegm]
         cmp       bh,es:[AStopa+KORIG]
         jne       GetMap2
         cmp       bl,es:[AStrana+KORIG]
         jne       GetMap2

; ------ ur‡en¡ aktu ln¡ operace

IFDEF    DEMO
         mov       ax,"D" + 1eh*HI          ; DEMO simulace
         cmp       byte ptr es:[AOper+KORIG],7
         je        GetMap9
ENDIF

         mov       ax,"R" + 1eh*HI          ; ‡ten¡
         cmp       byte ptr es:[AOper+KORIG],5
         ja        GetMap9
         mov       al,"W"
         je        GetMap9
         mov       al,"V"
         cmp       byte ptr es:[AOper+KORIG],3
         ja        GetMap9
         mov       al,"F"
         je        GetMap9

; ------ stopa je¨tˆ nebyla obslou‘ena

GetMap2: cmp       bh,es:[NStopa+KORIG]
         jne       GetMap22
         cmp       bl,es:[NStrana+KORIG]
GetMap22:mov       ax,"°" + 7*HI
         jg        GetMap9                  ; nen¡ je¨tˆ form tovan  stopa

; ------ p©epo‡et na absolutn¡ sektor

         mov       al,bh                    ; stopa
         mul       byte ptr es:[Stran+KORIG] ; p©epo‡et stopy na strany
         add       al,bl                    ; p©i‡ten¡ strany
         adc       ah,0
         mov       bx,word ptr es:[Sektoru+KORIG] ; po‡et sektor–
         mul       bx                       ; p©epo‡et na absolutn¡ sektor

; ------ test, zda je nˆkter˜ sektor vadn˜

GetMap3: call      GetErrS                  ; test, zda je sektor vadn˜
         jc        GetMap8                  ; nalezen vadn˜ sektor
         inc       ax                       ; zv˜¨en¡ ukazatele sektor–
         dec       bx                       ; ‡¡ta‡ sektor–
         jnz       GetMap3                  ; dal¨¡ sektor

GetMp32: mov       ax,"²" + 0ah*HI          ; stopa je OK
         jmp       short GetMap9

GetMap8: mov       ax,"x" + 4eh*HI          ; chyba

IFDEF    DEMO

         test      byte ptr es:[RParam2+KORIG],bit5 ; byla chyba v datech ?
         jnz       GetMp82                  ; byla chyba
         cmp       ch,es:[DemoStop+KORIG]   ; je stopa p©ed DEMO ?
         jb        GetMp32                  ; nem  b˜t chyba (p©elom) - oprava
GetMp82: sub       ch,es:[DemoStop+KORIG]   ; je DEMO stopa ?
         jb        GetMap9                  ; nen¡ DEMO stopa
         mov       bl,ch                    ; stopa
         and       bx,3                     ; offset v tabulce znak–
         shr       ch,1
         shr       ch,1
         xor       ch,cl                    ;
         mov       al,ds:[DemoChr+bx]       ; znak z textu
         test      ch,bit0
         jz        GetMp84
         mov       al,"-"
GetMp84:

ENDIF

; ------ n vrat registr–

GetMap9: pop       es
         pop       dx

IFDEF    DEMO
         pop       cx
ENDIF

         pop       bx
         ret

GetMap   ENDP


IFDEF    DEMO
DemoChr  db        'DEMO'
ENDIF

; -----------------------------------------------------------------------------
;        poskytnut¡ chyby sektoru AX (CY=chyba)
; -----------------------------------------------------------------------------

GetErrS  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      dx
         push      es
         mov       es,ds:[RezSegm]

; ------ test, zda to je BOOT sektor

         sub       ax,1
         jae       GetErrS1                 ; nen¡ BOOT
         test      byte ptr es:[RParam2+KORIG],bit1 ; je vadn˜ BOOT ?
         jmp       short GetErrS4

; ------ test, zda je vadn  FAT1

GetErrS1:sub       ax,es:[FATSekt+KORIG]
         jae       GetErrS2
         test      byte ptr es:[RParam2+KORIG],bit2
         jmp       short GetErrS4

; ------ test, zda je vadn  FAT 2

GetErrS2:sub       ax,es:[FATSekt+KORIG]
         jae       GetErrS3
         test      byte ptr es:[RParam2+KORIG],bit3
         jmp       short GetErrS4

; ------ test, zda je vadn˜ ROOT

GetErrS3:sub       ax,es:[Root+KORIG]
         jae       GetErrS5
         test      byte ptr es:[RParam2+KORIG],bit4
GetErrS4:jnz       GetErrS8                 ; je vadn˜
         jmp       short GetErrS9           ; je OK

; ------ p©epo‡et na aloka‡n¡ blok

GetErrS5:xor       dx,dx                    ; DX <- 0
         div       word ptr es:[Cluster+KORIG] ; p©epo‡et na aloka‡n¡ blok
         inc       ax
         inc       ax                       ; korekce

; ------ nalezen¡ bloku v tabulce chyb

         mov       bx,offset ErrMap+KORIG - 3
GetErrS6:add       bx,3
         cmp       byte ptr es:[bx],0       ; konec tabulky ?
         je        GetErrS9                 ; konec tabulky
         cmp       ax,es:[bx+1]
         jb        GetErrS6                 ; je p©ed blokem
         mov       dl,es:[bx]               ; po‡et blok– v intervalu
         mov       dh,0
         add       dx,es:[bx+1]             ; n sleduj¡c¡ blok
         cmp       ax,dx
         jae       GetErrS6                 ; nen¡ v tabulce
                                          ;* jinak nalezen OK v chyb ch
; ------ n vrat registr–

GetErrS8:stc
GetErrS9:pop       es
         pop       dx
         pop       bx
         pop       ax
         ret

GetErrS  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ aktu ln¡ho nastaven¡ parametr–
; -----------------------------------------------------------------------------

ZobrPar  PROC      NEAR

         mov       es,ds:[RezSegm]          ; rezidentn¡ segment

; ------ aktivn¡ disk

         mov       ah,74h                   ; barva textu
         mov       al,es:[Disk+KORIG]       ; aktu ln¡ disk
         add       al,"A"
         mov       dx,3
         call      OutChr

; ------ p©¡prava k dek¢dov n¡ kapacity

         mov       ax,es:[JmenKap+KORIG]    ; jmenovit  kapacita v KB
         push      ds
         pop       es                       ; ES <- datov˜ segment
         mov       di,offset BuffNum        ; buffer k dek¢dov n¡ ‡¡sla
         mov       si,di                    ; buffer textu

; ------ dek¢dov n¡ kapacity v KB

         xor       dx,dx                    ; nejsou desetiny
         cmp       ax,1000                  ; hranice pro MB
         jae       ZobrPar1                 ; zobraz¡ se MB
         call      DekNum                   ; dek¢dov n¡ kapacity v KB
         mov       al,"K"
         jmp       short ZobrPar2

; ------ dek¢dov n¡ kapacity v MB

ZobrPar1:mov       cx,1000
         div       cx                       ; p©epo‡et na MB
         push      ax
         xor       ax,ax
         div       cx                       ; p©epo‡et
         xchg      ax,dx
         pop       ax
         call      DekNum                   ; dek¢dov n¡ kapacity v MB
         mov       al,"M"
ZobrPar2:mov       ah,0
         stosw

; ------ zobrazen¡ jmenovit‚ kapacity

         sub       di,si                    ; d‚lka textu
         xchg      ax,di                    ; AL <- d‚lka textu
         mov       dx,1*HI + 20
         sub       dl,al                    ; po‡ te‡n¡ pozice k zobrazen¡
         mov       ah,74h
         call      OutTxt                   ; zobrazen¡ jmenovit‚ kapacity

; ------ po‡et stop

         mov       es,ds:[RezSegm]          ; rezidentn¡ segment
         mov       ax,word ptr es:[Stop+KORIG] ; po‡et stop
         mov       bh,74h                   ; barva
         mov       dx,2*HI + 18
         call      OutNumW                  ; zobrazen¡ po‡tu stop

; ------ po‡et sektor–

         mov       ax,word ptr es:[Sektoru+KORIG] ; po‡et sektor–
         mov       dh,3
         call      OutNumW                  ; zobrazen¡ po‡tu sektor–

; ------ po‡et stran

         mov       ax,word ptr es:[Stran+KORIG] ; po‡et stran
         mov       dh,4
         call      OutNumW                  ; zobrazen¡ po‡tu stran

; ------ krokov n¡

         mov       ax,1                     ; krokov n¡ po 1 stopˆ
         test      byte ptr es:[RParam+KORIG],bit6 ; je dvoj¡ krokov n¡ ?
         jz        ZobrPar3                 ; nen¡ dvoj¡ krokov n¡
         inc       ax                       ; krokov n¡ po 2 stop ch
ZobrPar3:mov       dh,5
         call      OutNumW                  ; zobrazen¡ krokov n¡

; ------ posun stran X

         mov       ah,0
         mov       al,es:[SlideX+KORIG]
         mov       dx,1*HI + 37
         call      OutNumW                  ; zobrazen¡ posunu X

; ------ posun stop Y

         mov       al,es:[SlideY+KORIG]
         mov       dh,2
         call      OutNumW                  ; zobrazen¡ posunu Y

; ------ prokl d n¡

         mov       al,es:[Interl+KORIG]
         mov       dh,3
         call      OutNumW                  ; zobrazen¡ prokl d n¡

; ------ mezisektorov  mezera

         mov       al,byte ptr es:[GAP+KORIG]
         mov       dh,4
         call      OutNumW

; ------ rychlost

         mov       ax,500
         cmp       byte ptr es:[Rate+KORIG],1
         jb        ZobrPar4
         mov       ax,300
         je        ZobrPar4
         mov       ax,250
         cmp       byte ptr es:[Rate+KORIG],2
         je        ZobrPar4
         mov       ax,1000
ZobrPar4:mov       dh,5
         call      OutNumW

; ------ aloka‡n¡ blok

         mov       ax,word ptr es:[Cluster+KORIG]
         mov       dx,1*HI + 56
         call      OutNumW

; ------ po‡et polo‘ek ROOT

         mov       ax,es:[Root+KORIG]
         mov       cl,4
         shl       ax,cl
         mov       dh,2
         call      OutNumW

; ------ po‡et testovac¡ch z pis–

         mov       ax,es:[TestWrit+KORIG]
         mov       dh,5
         call      OutNumW

; ------ popisova‡ m‚dia

         mov       dx,3*HI + 57-3
         mov       ah,74h
         mov       al,"$"
         call      OutChr
         mov       al,es:[MediaB+KORIG]
         call      OutHex

; ------ pln¡c¡ znak form tov n¡

         mov       dx,4*HI + 57-3
         mov       al,"$"
         call      OutChr
         mov       al,es:[FillCh+KORIG]
         call      OutHex

; ------ verifikace

         mov       dx,1*HI + 77
         mov       al,"-"
         test      byte ptr es:[RParam+KORIG],bit2 ; prov d¡ se verifikace ?
         jz        ZobrPar5                 ; prov d¡ se
         mov       al,"o"                   ; verifikace vypnuta
ZobrPar5:call      OutChr

; ------ ulo‘it XFLOP

         mov       dx,3*HI + 77
         mov       al,"-"
         test      byte ptr es:[RParam3+KORIG],bit1 ; ukl d  se XFLOP ?
         jz        ZobrPar7                 ; neukl d  se
         mov       al,"o"                   ; XFLOP se ukl d 
ZobrPar7:call      OutChr

; ------ zvukov  indikace

         mov       dx,4*HI + 77
         mov       al,"-"
         test      byte ptr es:[RParam+KORIG],bit0 ; zvukov  indikace ?
         jz        ZobrPar8                 ; nen¡ zvukov  indikace
         mov       al,"o"
ZobrPar8:call      OutChr

; ------ v¡ce disket

         mov       dx,5*HI + 77
         mov       al,"-"
         test      byte ptr es:[RParam+KORIG],bit1 ; v¡ce disket ?
         jz        ZobrPar9                 ; nen¡ v¡ce disket
         mov       al,"o"
ZobrPar9:call      OutChr
         ret

ZobrPar  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ jm‚na disku
; -----------------------------------------------------------------------------

ZobrLab  PROC      NEAR

         mov       ah,74h
         mov       es,ds:[RezSegm]
         mov       dx,2*HI + 77
         test      byte ptr es:[RParam3+KORIG],bit0 ; ukl d  se LABEL ?
         jnz       ZobrLab1                 ; LABEL se ukl d 

         mov       al,"-"
         call      OutChr
         ret


ZobrLab1:mov       cx,11                    ; maxim ln¡ d‚lka jm‚na
         mov       si,offset BootLabl+KORIG + 11
ZobrLab2:cmp       byte ptr es:[si-1]," "
         jne       ZobrLab3
         dec       si
         loop      ZobrLab2

ZobrLab3:sub       dl,cl
         inc       dx
         jcxz      ZobrLab6

         mov       si,offset BootLabl+KORIG
ZobrLab4:mov       al,es:[si]
         call      OutChr
         inc       si
         loop      ZobrLab4

ZobrLab6:ret

ZobrLab  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ voln‚ kapacity
; -----------------------------------------------------------------------------

ZobrVol  PROC      NEAR

; ------ p©¡prava celkov‚ kapacity

         mov       es,ds:[RezSegm]          ; rezidentn¡ segment
         mov       ax,es:[NumClust+KORIG]   ; po‡et aloka‡n¡ch blok–
         mul       word ptr es:[Cluster+KORIG] ; v˜po‡et po‡tu sektor– celkem
         mov       dx,512
         mul       dx                       ; v˜po‡et celkov‚ kapacity
         mov       word ptr ds:[ZobrVolK],ax ; celkov  kapacita
         mov       word ptr ds:[ZobrVolK+2],dx

IFDEF    DEMO
; ------ p©¡prava ‡¡sla aloka‡n¡ho bloku DEMO dat -> BP

         mov       al,es:[DemoStop+KORIG]   ; DEMO stopa
         mul       byte ptr es:[Stran+KORIG] ; p©epo‡et na po‡et stran
         mul       word ptr es:[Sektoru+KORIG] ; absolutn¡ ‡¡slo sektoru DEMO
         dec       ax                       ; bez BOOT sektoru
         sub       ax,es:[FATSekt+KORIG]    ; ode‡ten¡ sektor– FAT 1
         sub       ax,es:[FATSekt+KORIG]    ; ode‡ten¡ sektor– FAT 2
         sub       ax,es:[Root+KORIG]       ; ode‡ten¡ sektor– ROOT
         xor       dx,dx
         div       word ptr es:[Cluster+KORIG] ; p©epo‡et na ‡¡slo bloku relativnˆ
         inc       ax
         inc       ax                       ; korekce na ‡¡slo bloku
         xchg      ax,bp                    ; BP <- ‡¡slo bloku DEMO
ENDIF

; ------ p©¡prava voln‚ kapacity

         mov       word ptr ds:[ZobrVolF],0
         mov       word ptr ds:[ZobrVolF+2],0
         mov       al,es:[NStopa+KORIG]     ; zpracovan  stopa
         or        al,al
         js        ZobrVol2                 ; stopa neplatn 
         mul       byte ptr es:[Stran+KORIG] ; po‡et zpracovan˜ch stran
         add       al,es:[NStrana+KORIG]
         adc       ah,0
         inc       ax                       ; p©i‡ten¡ aktu ln¡ strany
         mul       word ptr es:[Sektoru+KORIG] ; p©epo‡et na sektory
         sub       ax,1
         jbe       ZobrVol2
         sub       ax,es:[FATSekt+KORIG]    ; ode‡ten¡ FAT1
         jbe       ZobrVol2
         sub       ax,es:[FATSekt+KORIG]    ; ode‡ten¡ FAT 2
         jbe       ZobrVol2
         sub       ax,es:[Root+KORIG]       ; ode‡ten¡ sektor– na ROOT
         jbe       ZobrVol2

         mov       cx,word ptr es:[Cluster+KORIG] ; sektor– na aloka‡n¡ blok
         dec       cx
         add       ax,cx                    ; zaokrouhlen¡ nahoru
         inc       cx
         xor       dx,dx
         div       cx                       ; v˜po‡et po‡tu alok. blok–
         cmp       ax,es:[NumClust+KORIG]   ; p©ekro‡en po‡et blok– ?
         jbe       ZobrVol1
         mov       ax,es:[NumClust+KORIG]   ; omezen¡ po‡tu blok–
ZobrVol1:mul       cx                       ; zarovn n¡ na aloka‡n¡ bloky
         mov       dx,512
         mul       dx                       ; p©epo‡et na bajty
         mov       word ptr ds:[ZobrVolF],ax ; voln  kapacita
         mov       word ptr ds:[ZobrVolF+2],dx

; ------ p©¡prava vadn˜ch dat

ZobrVol2:mov       word ptr ds:[ZobrVolV],0 ; nulov n¡ vadn˜ch dat
         mov       word ptr ds:[ZobrVolV+2],0

IFDEF    DEMO
         mov       word ptr ds:[ZobrVolD],0 ; nulov n¡ DEMO dat
         mov       word ptr ds:[ZobrVolD+2],0
ENDIF

         mov       si,offset ErrMap+KORIG   ; tabulka chyb
ZobrVol3:cmp       byte ptr es:[si],0
         je        ZobrVol4

         mov       al,es:[Cluster+KORIG]    ; po‡et sektor– na blok
         mul       byte ptr es:[si]         ; velikost £seku v sektorech
         mov       dx,512                   ; po‡et bajt– na sektor
         mul       dx                       ; p©epo‡et na bajty

IFDEF    DEMO
         cmp       bp,es:[si+1]             ; je blok DEMO ?
         ja        ZobrVl37                 ; je vadn˜ blok

         add       word ptr ds:[ZobrVolD],ax ; ‡¡ta‡ DEMO dat
         adc       word ptr ds:[ZobrVolD+2],dx
         jmp       short ZobrVl39
ENDIF

ZobrVl37:add       word ptr ds:[ZobrVolV],ax ; ‡¡ta‡ vadn˜ch dat
         adc       word ptr ds:[ZobrVolV+2],dx
ZobrVl39:add       si,3
         jmp       short ZobrVol3

; ------ £vodn¡ ‡ st textu

ZobrVol4:push      ds
         pop       es
         mov       di,offset BuffText
         mov       si,offset TextKap1
         call      DekTxt

; ------ celkov  kapacita

         mov       bh,74h
         mov       ax,word ptr ds:[ZobrVolK]
         mov       dx,word ptr ds:[ZobrVolK+2]
         call      DekNumD                  ; dek¢dov n¡ celkov‚ kapacity

; ------ druh  ‡ st textu

         call      DekTxt

; ------ voln  kapacita

         mov       ax,word ptr ds:[ZobrVolF]
         mov       dx,word ptr ds:[ZobrVolF+2]

IFDEF    DEMO
         sub       ax,word ptr ds:[ZobrVolD]
         sbb       dx,word ptr ds:[ZobrVolD+2]
         jc        ZobrVl48
ENDIF
         sub       ax,word ptr ds:[ZobrVolV]
         sbb       dx,word ptr ds:[ZobrVolV+2]
         jnc       ZobrVol5
ZobrVl48:xor       ax,ax
         xor       dx,dx
ZobrVol5:call      DekNumD

; ------ test, zda jsou vadn  data

         mov       ax,word ptr ds:[ZobrVolV]
         or        ax,word ptr ds:[ZobrVolV+2]
         jz        ZobrVol8                 ; nejsou vadn  data

; ------ t©et¡ ‡ st textu

         call      DekTxt

; ------ vadn  data

         mov       ax,word ptr ds:[ZobrVolV]
         mov       dx,word ptr ds:[ZobrVolV+2]
         call      DekNumD


ZobrVol8:

IFDEF    DEMO

; ------ test, zda jsou DEMO data

         mov       ax,word ptr ds:[ZobrVolD]
         or        ax,word ptr ds:[ZobrVolD+2]
         jz        ZobrVl81                 ; nejsou DEMO data

; ------ t©et¡ ‡ st textu

         mov       si,offset TextKap9
         call      DekTxt

; ------ DEMO data

         mov       ax,word ptr ds:[ZobrVolD]
         mov       dx,word ptr ds:[ZobrVolD+2]
         call      DekNumD

ENDIF

; ------ posledn¡ ‡ st textu

ZobrVl81:mov       si,offset TextKap4
         call      DekTxt

; ------ v˜po‡et okraj–

         mov       si,offset BuffText
         sub       di,si                    ; d‚lka textu * 2
         shr       di,1                     ; d‚lka textu ve znac¡ch
         mov       cx,di                    ; CX <- d‚lka textu
         mov       bx,70                    ; d‚lka © dku
         sub       bx,di                    ; zbytek na okraje
         shr       bx,1                     ; po‡ te‡n¡ pozice
         inc       bx
         inc       bx

; ------ zobrazen¡ lev‚ho okraje

         mov       dx,23*HI + 1
         mov       ax,70h*HI + " "
ZobrVl82:call      OutChr
         dec       bx
         jnz       ZobrVl82

; ------ zobrazen¡ textu

ZobrVol9:cld
         lodsw
         call      OutChr
         loop      ZobrVol9

; ------ zobrazen¡ prav‚ho okraje

         mov       ax,70h*HI + " "
ZobrVl94:call      OutChr
         cmp       dl,72
         jb        ZobrVl94
         ret

ZobrVol  ENDP

ZobrVolK dd        0                        ; celkov  kapacita
ZobrVolF dd        0                        ; voln  kapacita
ZobrVolV dd        0                        ; vadn  data

IFDEF    DEMO
ZobrVolD dd        0                        ; demo data
ENDIF

; -----------------------------------------------------------------------------
;        zobrazen¡ chyb v syst‚mov‚ oblasti
; -----------------------------------------------------------------------------
;þ
ZobrSyst PROC      NEAR

; ------ v˜po‡et absolutn¡ho sektoru zpracovan‚ oblasti

         mov       es,ds:[RezSegm]
         xor       bp,bp
         mov       al,es:[NStopa+KORIG]     ; zpracovan  stopa
         or        al,al
         js        ZobrSys2                 ; stopa neplatn 
         mul       byte ptr es:[Stran+KORIG] ; po‡et zpracovan˜ch stran
         add       al,es:[NStrana+KORIG]
         adc       ah,0
         inc       ax                       ; p©i‡ten¡ aktu ln¡ strany
         mul       word ptr es:[Sektoru+KORIG] ; p©epo‡et na sektory
         xchg      ax,bp                    ; BP <- zpracovan‚ sektory
         or        ax,ax
         jns       ZobrSys2
         mov       bp,7fffh

; ------ text "BOOT"

ZobrSys2:mov       si,offset ErrTxt
         mov       dx,13*HI + 63
         mov       ah,70h
         call      OutTxt

; ------ stav p©ep¡na‡e BOOT

         mov       ah,74h
         mov       al,"-"
         sub       bp,1                     ; sektor na BOOT
         js        ZobrSys3
         mov       al,"o"
         test      byte ptr es:[RParam2+KORIG],bit1 ; vadn˜ BOOT ?
         jz        ZobrSys3                 ; nen¡ vadn˜ BOOT
         mov       al,"X"
ZobrSys3:call      OutChr                   ; zobrazen¡ indik toru

; ------ text "FAT1"

         mov       dx,15*HI + 63
         mov       ah,70h
         call      OutTxt

; ------ stav p©ep¡na‡e FAT 1

         mov       ah,74h
         mov       al,"-"
         sub       bp,es:[FATSekt+KORIG]
         js        ZobrSys4
         mov       al,"o"
         test      byte ptr es:[RParam2+KORIG],bit2 ; vadn  FAT 1 ?
         jz        ZobrSys4
         mov       al,"X"
ZobrSys4:call      OutChr

; ------ text "FAT2"

         mov       dx,17*HI + 63
         mov       ah,70h
         call      OutTxt

; ------ stav p©ep¡na‡e FAT 2

         mov       ah,74h
         mov       al,"-"
         sub       bp,es:[FATSekt+KORIG]
         js        ZobrSys5
         mov       al,"o"
         test      byte ptr es:[RParam2+KORIG],bit3 ; vadn  FAT 2 ?
         jz        ZobrSys5
         mov       al,"X"
ZobrSys5:call      OutChr

; ------ text "ROOT"

         mov       dx,19*HI + 63
         mov       ah,70h
         call      OutTxt

; ------ stav p©ep¡na‡e ROOT

         mov       ah,74h
         mov       al,"-"
         sub       bp,es:[Root+KORIG]
         js        ZobrSys6
         mov       al,"o"
         test      byte ptr es:[RParam2+KORIG],bit4 ; vadn˜ ROOT ?
         jz        ZobrSys6
         mov       al,"X"
ZobrSys6:call      OutChr
         ret

ZobrSyst ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ s‚riov‚ho ‡¡sla
; -----------------------------------------------------------------------------

ZobrSer  PROC      NEAR

; ------ nadpis s‚riov‚ho ‡¡sla

         mov       ah,70h
         mov       si,offset SerNTxt
         mov       dx,9*HI + 63
         call      OutTxt

; ------ zobrazen¡ s‚riov‚ho ‡¡sla

         mov       dx,10*HI + 65
         mov       es,ds:[RezSegm]
         mov       ah,74h
         mov       al,byte ptr es:[BootSerN+KORIG+3]
         call      OutHex
         mov       al,byte ptr es:[BootSerN+KORIG+2]
         call      OutHex
         mov       al,"-"
         call      OutChr
         mov       al,byte ptr es:[BootSerN+KORIG+1]
         call      OutHex
         mov       al,byte ptr es:[BootSerN+KORIG]
         call      OutHex
         ret

ZobrSer  ENDP

; -----------------------------------------------------------------------------
;        p©enesen¡ textu ASCIIZ do bufferu s barvou AH
; -----------------------------------------------------------------------------

DekTxt   PROC      NEAR

         cld
         mov       ah,70h
DekTxt1: lodsb
         cmp       al,0
         je        DekTxt2
         stosw
         jmp       short DekTxt1
DekTxt2: ret

DekTxt   ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ ‡¡sla DX:AX do bufferu ES:DI, barva BH
; -----------------------------------------------------------------------------

DekNumD  PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx
         push      bp
         push      si

         mov       si,10
         xor       cx,cx
DekNumD2:xchg      ax,bp                    ; BP <- LOW
         cmp       cl,3
         jne       DekNumD3
         mov       al,"."
         push      ax
         inc       cx
DekNumD3:cmp       cl,7
         jne       DekNumD4
         mov       al,"."
         push      ax
         inc       cx
DekNumD4:xchg      ax,dx                    ; AX <- HIGH
         xor       dx,dx                    ; DX <- 0
         div       si                       ; vydˆlen¡ HIGH / 10
         xchg      ax,bp                    ; AX <- LOW, BP <- nov‚ HIGH
         div       si                       ; vydˆlen¡ LOW
         add       dl,"0"                   ; ‡¡slice
         push      dx
         inc       cx                       ; ‡¡ta‡ znak–
         mov       dx,bp                    ; n vrat HIGH
         or        bp,ax                    ; je ji‘ 0 ?
         jnz       DekNumD2                 ; dal¨¡ ‡¡slice

DekNumD6:pop       ax
         cld
         mov       ah,bh
         stosw
         loop      DekNumD6

         pop       si
         pop       bp
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DekNumD  ENDP

;; -----------------------------------------------------------------------------
;;        zobrazen¡ posledn¡ chyby
;; -----------------------------------------------------------------------------
;
;ZobrErr  PROC      NEAR
;
;         mov       dx,23*HI + 2
;         mov       si,offset LastETxt
;         mov       ah,70h
;         call      OutTxt
;
;         mov       ah,74h
;         mov       es,ds:[RezSegm]
;         mov       al,es:[LastErr+KORIG]
;         mov       si,offset LastETab
;ZobrErr2:inc       si
;         cmp       al,ds:[si-1]
;         je        ZobrErr5
;         cmp       byte ptr ds:[si-1],0
;         je        ZobrErr5
;ZobrErr3:inc       si
;         cmp       byte ptr ds:[si-1],0
;         jne       ZobrErr3
;         jmp       short ZobrErr2
;
;ZobrErr5:call      OutTxt
;
;
;ZobrErr6:cmp       dl,78
;         jae       ZobrErr7
;         mov       al," "
;         call      OutChr
;         jmp       short ZobrErr6
;
;ZobrErr7:
;         ret
;
;ZobrErr  ENDP
;
; -----------------------------------------------------------------------------
;        zobrazen¡ podkladu mapy
; -----------------------------------------------------------------------------

ZobrPod  PROC      NEAR

; ------ p©¡prava registr–

         mov       es,ds:[RezSegm]
         mov       dx,ds:[DTopPoz]          ; po‡ te‡n¡ pozice mapy
         mov       ch,ds:[DRadku]           ; po‡et © dk– mapy
         mov       cl,ds:[DPozic]           ; po‡et pozic mapy

; ------ zobrazen¡ jednoho © dku

         mov       bh,0                     ; ukazatel ‡¡sla stopy
ZobrPod0:push      dx
         mov       al,es:[Stop+KORIG]
         sub       al,bh
         cmp       al,cl
         jae       ZobrPd02
         mov       cl,al                    ; omezen¡ po‡tu stop

; ------ zobrazen¡ horn¡ linky jednoho © dku

ZobrPd02:push      dx
         push      cx
         mov       ch,0
         mov       ah,70h
         mov       al,"Ú"
         call      OutChr
ZobrPod1:mov       al,"Â"
         call      OutChr
         loop      ZobrPod1
         mov       al,"¿"
         call      OutChr
         pop       cx
         pop       dx
         inc       dh                       ; zv˜¨en¡ ukazatele © dku

; ------ zobrazen¡ vnit©n¡ch linek

         mov       bl,0                     ; ukazatel ‡¡sla strany
ZobrPod2:push      dx
         push      cx

         sub       dl,9
         mov       si,offset StranTxt
         call      OutTxt

         mov       al,bl                    ; ‡¡slo strany
         add       al,"0"
         call      OutChr
         mov       al," "
         call      OutChr
         mov       al,"³"
         call      OutChr
         mov       ch,0
ZobrPod3:mov       ax,"°" + 7*HI
         call      OutChr
         loop      ZobrPod3
         mov       ax,"³" + 70h*HI
         call      OutChr

         pop       cx
         pop       dx
         inc       dh
         inc       bx
         cmp       bl,es:[Stran+KORIG]
         jb        ZobrPod2

; ------ zobrazen¡ spodn¡ linky jednoho © dku

         push      dx
         push      cx

         mov       al,bh                    ; AL <- ‡¡slo stopy
         mov       ah,0
         mov       ch,5
         div       ch                       ; v˜po‡et posunu
         mov       bl,ah

         mov       ch,0
         mov       ah,70h
         mov       al,"À"
         call      OutChr
ZobrPod4:mov       al,"Á"
         dec       bl
         jns       ZobrPod6
         mov       bl,4
         mov       al,"Å"

         push      ax
         push      dx
         inc       dh
         mov       al,bh                    ; ‡¡slo stopy
         cmp       al,10
         jb        ZobrPod5
         dec       dx
ZobrPod5:call      OutNumB                  ; zobrazen¡ ‡¡sla stopy
         pop       dx
         pop       ax

ZobrPod6:call      OutChr
         inc       bh
         loop      ZobrPod4
         mov       al,"Ù"
         call      OutChr

         pop       cx
         pop       dx
         inc       dh                       ; zv˜¨en¡ ukazatele © dku



; ------ p©¡prava k zobrazen¡ dal¨¡ho © dku

         pop       dx
         add       dh,ds:[DPosun]
         dec       ch
         jz        ZobrPod9                 ; konec
         jmp       ZobrPod0
ZobrPod9:ret

ZobrPod  ENDP

; -----------------------------------------------------------------------------
;        inicializace zobrazen¡
; -----------------------------------------------------------------------------
;þ
InitZobr PROC      NEAR

; ------ po‡et © dk– mapy

         mov       es,ds:[RezSegm]          ; rezidentn¡ segment
         mov       ax,word ptr es:[Stop+KORIG] ; po‡et stop celkem
         mov       cx,52                    ; asi tak maxim ln¡ ¨¡©ka
         div       cl                       ; v˜po‡et po‡tu © dk–
         inc       ax                       ; po‡et © dk–
         mov       ds:[DRadku],al           ; po‡et © dk– mapy

; ------ po‡et pozic mapy

         mov       ax,word ptr es:[Stop+KORIG] ; po‡et stop celkem
         div       byte ptr ds:[DRadku]     ; v˜po‡et po‡tu pozic
         mov       ds:[DPozic],al           ; po‡et pozic na © dek mapy

; ------ odsazen¡ jednotliv˜ch © dk– mapy

         mov       al,es:[Stran+KORIG]      ; po‡et stran
         add       al,4                     ; odsazen¡ © dk–
         cmp       byte ptr ds:[DRadku],2
         jbe       InitZob1
         dec       ax                       ; sn¡‘en¡ mezery mezi © dky
InitZob1:mov       ds:[DPosun],al           ; odsazen¡ © dk–
         mul       byte ptr ds:[DRadku]     ; celkov˜ po‡et © dk–
         sub       ax,3                     ; bez okraj–
         xchg      ax,cx                    ; CX <- v˜¨ka okna

; ------ horizont ln¡ po‡ te‡n¡ pozice

         mov       al,54                    ; ¨¡©ka displeje
         sub       al,ds:[DPozic]           ; ode‡ten¡ ¨¡©ky mapy
         shr       al,1                     ; po‡ te‡n¡ pozice mapy
         add       al,9
         mov       byte ptr ds:[DTopPoz],al ; po‡ te‡n¡ pozice mapy

; ------ vertik ln¡ po‡ te‡n¡ pozice

         mov       al,22                    ; v˜¨ka displeje
         sub       al,cl                    ; ode‡ten¡ v˜¨ky mapy
         shr       al,1                     ; po‡ te‡n¡ © dek mapy
         add       al,3
         mov       byte ptr ds:[DTopPoz+1],al ; po‡ te‡n¡ © dek mapy
         ret

InitZobr ENDP

; -----------------------------------------------------------------------------
;        vymaz n¡ obrazovky
; -----------------------------------------------------------------------------

Clear    PROC      NEAR

         push      ax
         push      cx
         push      dx
         push      di
         push      es

         cld
         mov       es,ds:[AdrVRAM]
         xor       di,di

; ------ horn¡ okraj

         mov       si,offset StavTxt
         mov       cx,offset(StavTxt0-StavTxt)
         mov       ah,70h
Clear1:  lodsb
         stosw
         loop      Clear1

; ------ st©edn¡ © dky

         mov       dx,25-7-1
Clear2:  mov       al,"º"
         stosw
         mov       al," "
         mov       cl,78
         rep       stosw
         mov       al,"º"
         stosw
         dec       dx
         jnz       Clear2

; ------ spodn¡ okraj

         mov       al,"È"
         stosw
         mov       cl,78
         mov       al,"Í"
         rep       stosw
         mov       al,"¼"
         stosw

         pop       es
         pop       di
         pop       dx
         pop       cx
         pop       ax
         ret

Clear    ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ ‡¡sla AX (barva BH) od pozice DX zpˆt
; -----------------------------------------------------------------------------

OutNumW  PROC      NEAR

         push      ax
         push      cx
         push      dx
         push      si

         mov       si,10
OutNumW1:mov       cx,dx                    ; CX <- pozice
         xor       dx,dx                    ; DX <- 0
         div       si                       ; AX <- nov˜ pod¡l, DX <- ‡¡slice

         xchg      ax,cx                    ; CX <- pod¡l, AX <- pozice
         xchg      ax,dx                    ; AX <- ‡¡slice, DX <- pozice
         add       al,"0"                   ; korekce na znak ASCII
         mov       ah,bh                    ; barva znaku
         call      OutChr                   ; zobrazen¡ znaku AL
         dec       dx
         dec       dx                       ; posun pozice

         xchg      ax,cx                    ; AX <- pod¡l
         or        ax,ax                    ; je je¨tˆ ‡¡slo ?
         jnz       OutNumW1                 ; dal¨¡ ‡¡slice

         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

OutNumW  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ ‡¡sla AL (barva AH) na pozici DX
; -----------------------------------------------------------------------------

OutNumB  PROC      NEAR

         push      ax
         push      bx
         push      cx

         mov       bh,ah
         mov       bl,10
         xor       cx,cx
OutNumB1:mov       ah,0
         div       bl
         push      ax
         inc       cx
         cmp       al,0
         jne       OutNumB1

OutNumB2:pop       ax
         mov       al,ah
         add       al,"0"
         mov       ah,bh
         call      OutChr
         loop      OutNumB2

         pop       cx
         pop       bx
         pop       ax
         ret

OutNumB  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ textu ASCIIZ DS:SI na pozici DX, barva AH
; -----------------------------------------------------------------------------

OutTxt   PROC      NEAR

         push      ax

OutTxt2: cld
         lodsb
         cmp       al,0
         je        OutTxt9
         call      OutChr
         jmp       short OutTxt2

OutTxt9: pop       ax
         ret

OutTxt   ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ bajtu AL v HEX k¢du (pozice DX, barva AH)
; -----------------------------------------------------------------------------

OutHex   PROC      NEAR

         push      ax
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1
         call      OutHx
         pop       ax

OutHx:   push      ax
         and       al,0fh
         cmp       al,9
         jbe       OutHx2
         add       al,7
OutHx2:  add       al,"0"
         call      OutChr
         pop       ax
         ret

OutHex   ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ znaku AX na pozici DX
; -----------------------------------------------------------------------------

OutChr   PROC      NEAR

         push      di
         push      es

         push      ax
         mov       al,80                    ; po‡et pozic na © dek
         mul       dh                       ; p©epo‡et ©adku na pozice
         add       al,dl                    ; p©i‡ten¡ pozice
         adc       ah,0
         shl       ax,1                     ; offset ve videopamˆti
         xchg      ax,di                    ; DI <- offset ve videopamˆti
         pop       ax
         mov       es,ds:[AdrVRAM]
         cld
         stosw

         pop       es
         pop       di
         inc       dx                       ; zv˜¨en¡ ukazatele © dku
         ret

OutChr   ENDP

; -----------------------------------------------------------------------------
;        vypnut¡ kurzoru
; -----------------------------------------------------------------------------

KurzOff  PROC      NEAR

         push      ax
         push      bx
         push      dx

         xor       bx,bx
         mov       dx,25*HI + 0
         mov       ah,2
         call      Int10

         pop       dx
         pop       bx
         pop       ax
         ret

KurzOff  ENDP

; -----------------------------------------------------------------------------
;        inicializace videom¢du
; -----------------------------------------------------------------------------

InitVMod PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx

         mov       ah,0fh
         call      Int10
         mov       word ptr ds:[AdrVRAM],0b000h
         cmp       al,7
         je        InitVMd2
         mov       word ptr ds:[AdrVRAM],0b800h
         mov       al,3
InitVMd2:mov       ah,0
         call      Int10

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

InitVMod ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 10h
; -----------------------------------------------------------------------------

Int10    PROC      NEAR

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

Int10    ENDP

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                        Data pro instalaci
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;þ

; ------ obsluha zobrazen¡

AdrVRAM  dw        0b800h                   ; adresa videopamˆti

DTopPoz  dw        0                        ; po‡ te‡n¡ pozice mapy
DRadku   db        1                        ; po‡et © dk– mapy stop
DPozic   db        1                        ; po‡et pozic na mapu (¨¡©ka stop)
DPosun   db        1                        ; odsun jednotliv˜ch © dk– mapy

StranTxt db        'strana ',0
;LastETxt db        'posledni stav I/O: ',0
;
;LastETab db        1,'TIME-OUT od preruseni INT 0Eh',0
;         db        2,'TIME-OUT prijmu stavu od radice',0
;         db        3,'TIME-OUT vyslani povelu k radici',0
;         db        4,'prekrocen pocet bajtu stavu od radice',0
;         db        5,'chyba vystaveni hlav',0
;         db        6,'mechanika nepripravena',0
;         db        7,'nenalezena stopa 0',0
;         db        8,'sektor nenalezen',0
;         db        9,'disketa chranena proti zapisu',0
;         db        10,'preteceni prenosu DMA',0
;         db        11,'chyba kontrolniho souctu dat CRC',0
;         db        12,'nesouhlasi hlavicka sektoru',0
;         db        13,'chyba resetovani radice',0
;         db        255,'chyba operace',0
;         db        0,'-',0

IFDEF    DEMO
StavTxt  db        'ÉÍ A: ÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍ XFORM V1.00 DEMO Í»'
         db        'º F kapacita        º X posun stran    º C alok. blok     º U neverifikovat    º'
         db        'º T stop            º Y posun stop     º R pol. ROOT      º V jmeno            º'
         db        'º N sektoru         º I prokladani     º M popisovac      º S ulozit XFLOP     º'
         db        'º H stran           º G mezera         º L vypln dat      º E indikace         º'
         db        'º J krokovani       º O rychlost       º W zapisu         º P vice disket      º'
         db        'ÌÍÍÍÍÍ DEMONSTRACNI verze programu -- formatuje pouze polovinu diskety !!! ÍÍÍÍ¹'
StavTxt0 label     byte
ELSE

IFDEF    SHARE
StavTxt  db        'ÉÍ A: ÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍ XFORM V1.00 Í»'
         db        'º F kapacita        º X posun stran    º C alok. blok     º U neverifikovat    º'
         db        'º T stop            º Y posun stop     º R pol. ROOT      º V jmeno            º'
         db        'º N sektoru         º I prokladani     º M popisovac      º S ulozit XFLOP     º'
         db        'º H stran           º G mezera         º L vypln dat      º E indikace         º'
         db        'º J krokovani       º O rychlost       º W zapisu         º P vice disket      º'
         db        'ÌÍÍÍÍÍ SHAREWARE verze !!!  Druha polovina diskety s pomalym pristupem !!! ÍÍÍÍ¹'
StavTxt0 label     byte
ELSE
StavTxt  db        'ÉÍ A: ÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍ XFORM V1.00 Í»'
         db        'º F kapacita        º X posun stran    º C alok. blok     º U neverifikovat    º'
         db        'º T stop            º Y posun stop     º R pol. ROOT      º V jmeno            º'
         db        'º N sektoru         º I prokladani     º M popisovac      º S ulozit XFLOP     º'
         db        'º H stran           º G mezera         º L vypln dat      º E indikace         º'
         db        'º J krokovani       º O rychlost       º W zapisu         º P vice disket      º'
         db        'ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹'
StavTxt0 label     byte
ENDIF
ENDIF

SerNTxt  db        'Seriove cislo',0

ErrTxt   db        'BOOT ...... ',0
         db        'FAT1 ...... ',0
         db        'FAT2 ...... ',0
         db        'ROOT ...... ',0

Param    db        0                        ; parametry
                                            ;   bit 0: 1=je rezidentn¡ ‡ st
                                            ;   bit 1: 1=po‘adov no odinstalov n¡
                                            ;   bit 2: 1=po‘adov no p©eru¨en¡
                                            ;   bit 3: 1=ne‡ekat na potvrzen¡
                                            ;   bit 4: 1=po‘adov no zobrazen¡ operace
                                            ;   bit 5: 1=zad n popisova‡ m‚dia
                                            ;   bit 6: 1=zad no krokov n¡
                                            ;   bit 7: 1=zad na mezera GAP

RezSegm  dw        0                        ; adresa rezidentn¡ ‡ sti

UvTxt    db        'XFORM v1.00 - rezidentni formatovani disket; (c) Miroslav Nemecek',13,10
IFDEF    SHARE
         db        '*** Toto je SHAREWARE verze - zpomaluje rychlost 1/2 diskety ! ***',13,10
ENDIF
IFDEF    DEMO
         db        '*** Toto je DEMONSTRACNI verze - formatuje jen polovinu diskety ! ***',13,10
ENDIF
         db        0

DInsTxt  db        'Program byl odinstalovan z pameti.',13,10,0
DInsTxt1 db        'Program nelze odinstalovat, nebyl dosud nainstalovan !',13,10,0
DInsTxt2 db        'Je nutno odinstalovat nejdrive programy nainstalovane po programu XFORM !',13,10,0
VerzeTxt db        'V pameti je nainstalovana jina verze programu XFORM !',13,10,0
JedeTxt  db        'Probihajici formatovani je nutno nejdrive prerusit parametrem "Q" !',13,10,0

VarTxt   db        13,10,'Vlozte do mechaniky '
VarTxt1  db        'A: novou disketu a stisknete ENTER.',13,10
         db        'VAROVANI - puvodni obsah diskety bude formatovanim znicen !',13,10,0

NDiskTxt db        'Disk '
NDiskTx1 db        'A: neni nainstalovan v pocitaci !',13,10,0

InstTxt  db        'Program byl nainstalovan do pameti.',13,10,0

; ------ zobrazen¡ form tu diskety

ParTxt   db        13,10
ParTxtF  db        'F',0
ParTxtT  db        ' T',0
ParTxtN  db        ' N',0
ParTxtH  db        ' H',0
ParTxtJ  db        ' J',0
ParTxtX  db        ' X',0
ParTxtY  db        ' Y',0
ParTxtI  db        ' I',0
ParTxtG  db        ' G',0
ParTxtO  db        ' O',0
ParTxtC  db        ' C',0
ParTxtR  db        ' R',0
ParTxtM  db        ' M',0
ParTxtL  db        ' L',0
ParTxtW  db        ' W',0
ParTxtU  db        ' U',0
ParTxtV  db        ' V"'
ParTxtV1 db        11 dup(" "),'"',0
ParTxtS  db        ' S',0
ParTxtE  db        ' E',0
ParTxtP  db        ' P',0

ParTxtFA db        13,10,'sektoru FAT=',0
ParTxtZB db        ', nevyuzito=',0
ParTxtVO db        ', volne=',0
ParTxtBL db        ' B, bloku=',0
ParTxt0  db        13,10,0

BuffNum  db        20 dup(" ")              ; buffer k dek¢dov n¡ ‡¡sla

TextKap1 db        'Kapacita ',0
TextKap2 db        ' B, volne ',0
TextKap3 db        ' B, vadne ',0

IFDEF    DEMO
TextKap9 db        ' B, demo ',0
ENDIF

TextKap4 db        ' B.',0
BuffText db        2*80 dup(" ")            ; buffer k dek¢dov n¡ textu

HelpTxt  db        'Zadejte:   A: nebo B: ........ oznaceni disku A: nebo B: k formatovani',13,10
         db        'ÉÍÍÍÍÍ Fyzicke parametry diskety ÍÍÍÍÍÍËÍÍÍÍÍÍ Logicke parametry diskety ÍÍÍÍÍ»',13,10
         db        'º F kapacita . jmenovita kapacita      º C sektoru .. sektoru na alokacni blokº',13,10
         db        'º T stop ..... pocet stop (valcu)      º R polozek .. pocet polozek ROOT      º',13,10
         db        'º N sektoru .. pocet sektoru na stopu  º M bajt ..... popisovac media         º',13,10
         db        'º H hlav ..... pocet hlav (stran) (1-2)º L bajt ..... plnici bajt dat diskety º',13,10
         db        'º J kroku .... krokovani posunu (1-2)  º                                      º',13,10
         db        'º X sektoru .. posun pri zmene strany  ÌÍÍÍÍÍÍÍÍÍÍ Rizeni formatovani ÍÍÍÍÍÍÍÍ¹',13,10
         db        'º Y sektoru .. posun pri zmene stopy   º W zapisu ... pocet testovacich zapisuº',13,10
         db        'º I interleave prokladani sektoru      º U .......... neprovadet verifikaci   º',13,10
         db        'º G bajtu .... mezisektorova mezera    º V "label" .. jmenovka disku          º',13,10
         db        'º O rate ..... prenos 250/300/500/1000 º S .......... ulozit na disk XFLOP.COMº',13,10
         db        'º 1 .......... 1 strana (jako H1)      º E .......... zvukova indikace konce  º',13,10
         db        'º 4 .......... 40 stop (jako T40)      º P .......... formatovat vice disket  º',13,10
         db        'º 8 .......... 8 sektoru (jako N8)     º K .......... nepotvrzovat klavesnici º',13,10
         db        'ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ Ovladaci povely ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹',13,10
         db        'º D ........... zobrazeni prubehu operace formatovani                         º',13,10
         db        'º Q ........... preruseni probihajiciho formatovani                           º',13,10
         db        'º ! ........... odinstalovani programu z pameti                               º',13,10
         db        'ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼',13,10
         db        'Cisla lze zadat jako HEX uvedenim znaku "$" pred cislem.',13,10
         db        0

Code     ENDS
         END       Start


Code     SEGMENT
         ASSUME    cs:Code,ds:Code

; -----------------------------------------------------------------------------
;        konstanty
; -----------------------------------------------------------------------------

HI       EQU       256

bit0     EQU       1
bit1     EQU       2
bit2     EQU       4
bit3     EQU       8
bit4     EQU       10h
bit5     EQU       20h
bit6     EQU       40h
bit7     EQU       80h
bit8     EQU       100h
bit9     EQU       200h
bit10    EQU       400h
bit11    EQU       800h
bit12    EQU       1000h
bit13    EQU       2000h
bit14    EQU       4000h
bit15    EQU       8000h

; -----------------------------------------------------------------------------

MinF     EQU       4700                     ; minim ln¡ frekvence hodin INT 08h
MaxF     EQU       25000                    ; maxim ln¡ frekvence hodin INT 08h
DelKon   EQU       57;49                       ; konstanta pro v˜po‡et hodin

; -----------------------------------------------------------------------------
;                      Definice souboru *.MOD
; -----------------------------------------------------------------------------
;     je-li v souboru slovo, je na ni‘¨¡ adrese ulo‘en jeho vy¨¨¡ bajt !
; -----------------------------------------------------------------------------
; 00h: (20) n zev melodie ASCIIZ
; 14h: (930, 450) tabulka definic 31 (15) n stroj– (definice ka‘d‚ho n stroje 30 bajt–)
;          0: (20) n zev n stroje ASCIIZ
;        14h: (1)
;        15h: (1)
;        16h: (2) velikost definice vzorku ve slovech (tj. 0 a‘ 128 KB)
;                 (nejd©¡ve vy¨¨¡ bajt, potom ni‘¨¡)
;        18h: (2) hlasitost vzorku (nejd©¡ve vy¨¨¡ bajt, potom ni‘¨¡)
;        1ah: (2) za‡ tek pro opakov n¡ LoopS ve lsovech (vy¨¨¡ bajt, potom ni‘¨¡)
;        1ch: (2) d‚lka pro opakov n¡ LoopL ve slovech (vy¨¨¡ bajt, potom ni‘¨¡)
;
; 3b6h (1d6h): (1) d‚lka skladby (po‡et sekc¡ po 1 KB)
; 3b7h (1d7h): (1)
; 3B8h (1d8h): (80h) tabulka ‡¡sel sekc¡ melodie (‡¡sla blok– 1KB - 128 sekc¡)
; 438h (258h): (4) identifik tor "M.", "FLT4" = po‡et n stroj– = 30 (jinak = 15)
;
; 43ch (258h): za‡ tek melodie (sekce po 1 KB, prvn¡ sekce m  ‡¡slo 0)
;
; Definice melodie: 4 kan ly po 4 bajtech na t¢n:
;              0: bity 0 a‘ 3 = vy¨¨¡ 4 bity dˆlic¡ konstanty (tj. bity 8 a‘ 11)
;                 bit 4 = 5. bit ‡¡sla n stroje (je-li 31 n stroj–)
;              1: ni‘¨¡ch 8 bit– dˆlic¡ konstanty frekvence (tj. bity 0 a‘ 7)
;              2: bity 0 a‘ 3 = p©¡kaz
;                                 0fh: "SD=" nastaven¡ rychlosti hry
;                                            (bajt 3 = rychlost hry)
;                 bity 4 a‘ 7 = ni‘¨¡ 4 bity ‡¡sla n stroje
;              3: parametr povelu
;
;  ‡¡slo n stroje = 0: vzorek se nenastavuje (z–st v  p–vodn¡)
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
;        Defini‡n¡ tabulka kan l–
; -----------------------------------------------------------------------------

; ------ ukazatele pro obsluhu INT 08h

KanSegm  EQU       0                        ; (2) segment adresy vzorku
KanOffs  EQU       2                        ; (2) ukazatel adresy vzorku
KanEnd   EQU       4                        ; (2) adresa konce vzorku

KanBeg0  EQU       6                        ; (2) za‡ tek vzorku pro opakov n¡
KanEnd0  EQU       8                        ; (2) konec vzorku pro opakov n¡

KanInc   EQU       10                       ; (1) p©¡rustek ukazatele vzorku
KanInc0  EQU       11                       ; (1) p©¡rustek ‡¡ta‡e zlomku ukaz.
KanIncZ  EQU       12                       ; (1) ‡¡ta‡ zlomku ukazatele
KanVol   EQU       13                       ; (1) hlasitost kan lu

; ------ ukazatele pro p©¡pravu ovl d n¡ melodie

KanTon   EQU       14                       ; (4) uschovan‚ 4 bajty t¢nu melodie
Kan0Segm EQU       18                       ; (2) segment vzorku
Kan0Size EQU       20                       ; (2) velikost vzorku (ve slovech)

KanTrem  EQU       22                       ; (1) ukazatel f ze tremola
KanTrem0 EQU       23                       ; (1) amplituda tremola

KanFrekv EQU       24                       ; (2) frekvence vzorku (dˆlic¡ kon.)
KanPshF  EQU       26                       ; (2) uschovan  frekvence

KanVol0  EQU       28                       ; (1) mˆnˆn  hlasitost
KanParF  EQU       29                       ; (1) parametr frekvence

KanSize  EQU       30                       ; velikost definice jednoho kan lu


Start:

; ------ dek¢dov n¡ parametr– p©¡kazov‚ho © dku

         call      DekParm                  ; dek¢dov n¡ parametr– p©¡kaz. © dku

         mov       ah,0fh
         int       10h
         cmp       al,7
         jne       Start023
         mov       word ptr cs:[SegmVRAM],0b000h
Start023:mov       ah,0
         int       10h

         mov       dh,25
         mov       dl,0
         mov       ah,2
         int       10h

; ------ zmen¨en¡ bloku programu na minimum

         mov       ax,es                    ; segment PSP
         mov       bx,SEG KonSeg            ; segment konce programu
         sub       bx,ax                    ; d‚lka programu v odstavc¡ch
         mov       ah,4ah
         int       21h

; ------ inicializace segmentov˜ch registr–

         push      cs
         pop       ds
         push      cs
         pop       es

; ------ nastaven¡ adresy DTA

Start08: mov       dx,offset DTA            ; buffer DTA
         mov       ah,1ah
         int       21h                      ; nastaven¡ adresy DTA

; ------ nalezen¡ prvn¡ho souboru

         mov       dx,offset All            ; specifikace jm‚na souboru
         xor       cx,cx                    ; atributy souboru
         mov       ah,4eh
         int       21h                      ; nalezen¡ prvn¡ho souboru
         jnc       Start3                   ; soubor nalezen OK

; ------ chyba - nenalezen ‘ dn˜ soubor

         mov       dx,offset NoFile         ; text - nen¡ soubor
Start1:  mov       ah,9
         int       21h                      ; zobrazen¡ chybov‚ho textu

; ------ konec programu

Start2:  mov       ah,1
         int       16h                      ; test stavu kl vesnice
         jz        Start22                  ; nen¡ ‘ dn  kl vesa
         mov       ah,0
         int       16h                      ; zru¨en¡ kl vesy z bufferu
Start22: xor       dx,dx
         xor       bx,bx
         mov       ah,2
         int       10h

         mov       ax,4c00h
         int       21h

; ------ na‡ten¡ souboru do pamˆti

Start3: ; mov       ah,1
        ; int       16h
        ; jnz       Start2                   ; je nˆjak  kl vesa - konec
         mov       dx,offset DTA+1eh        ; jm‚no souboru
         call      CtiSoub                  ; na‡ten¡ souboru do pamˆti
         jc        Start5                   ; chyba ‡ten¡ nebo neplatn˜ soubor

; ------ p©¡prava ukazatel– programu

         call      InitReg                  ; inicializace ukazatel– a konstant

; ------ start hry melodie

         call      InitPort                 ; inicializace port–
         mov       word ptr ds:[TaktZ],-1

; ------ ‡ek n¡ na ukon‡en¡ hry

Start4:  call      Shows                    ; demonstrace za bˆhu programu
         sti
         test      byte ptr ds:[Param],bit2 + bit3 + bit5 ; je konec hry ?
         jz        Start4                   ; ‡ek n¡ na ukon‡en¡ hry skladby

; ------ n vrat port–

         call      DeInit                   ; deinicializace port–
         test      byte ptr ds:[Param],bit2 ; je p©eru¨en¡ kl vesou ?
         jnz       Start2                   ; p©eru¨en¡ kl vesou

; ------ navr cen¡ stavu po‡¡ta‡e

Start5:  call      ClosFile                 ; uzav©en¡ souboru
         call      DelADat                  ; zru¨en¡ v¨ech datov˜ch blok–

; ------ opakov n¡ skladby

         test      byte ptr ds:[Param],bit5
         jnz       Start3

; ------ nastaven¡ adresy DTA

         mov       dx,offset DTA            ; buffer DTA
         mov       ah,1ah
         int       21h                      ; nastaven¡ adresy DTA

; ------ nalezen¡ dal¨¡ho souboru

         mov       ah,4fh
         int       21h                      ; nalezen¡ dal¨¡ho souboru
         jnc       Start3                   ; obsluha dal¨¡ho souboru
         test      byte ptr ds:[Param2],bit0
         jnz       Start2                   ; bylo nˆco zad no - nen¡ smy‡ka
         jmp       Start08                  ; jinak opakov n¡ v¨eho

;         jc        Start2                   ; nen¡ dal¨¡ soubor
;         jmp       short Start3             ; obsluha dal¨¡ho souboru

; *****************************************************************************
;                                Posun
;                     posun melodie o dal¨¡ krok
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
;        p©eru¨en¡ je povoleno
; procedura nemus¡ uchov vat ‘ dn˜ registr
; *****************************************************************************

Posun    PROC      NEAR

; ------ test, zda je konec hry

         test      byte ptr ds:[Param],bit2 + bit3 ; prob¡h  hra ?
         jz        Posun1                   ; hra prob¡h 
         ret

; ------ zv˜¨en¡ ‡¡ta‡e krok– na takt

Posun1:  mov       al,ds:[CitKrok]          ; ‡¡ta‡ krok– na takt
         inc       ax                       ; zv˜¨en¡ ‡¡ta‡e krok– na takt
         cmp       al,ds:[Rychlost]         ; je ji‘ cel˜ takt ?
         jae       PosTakt                  ; je cel˜ takt - posun taktu
         mov       ds:[CitKrok],al          ; nov˜ stav ‡¡ta‡e takt–

; ------ obsluha kan l– bˆhem jednoho taktu

         mov       si,offset TabKanal       ; tabulka definice kan lu 1
         call      KrokKan                  ; proveden¡ kroku kan lu 1
         mov       si,offset TabKanal+KanSize ; adresa definice dal¨¡ho kan lu
         call      KrokKan                  ; proveden¡ kroku kan lu 2

         call      ZvysF                    ; tady by asi mˆl b˜t impuls hodin

         mov       si,offset TabKanal+2*KanSize ; adresa definice dal¨¡ho kan lu
         call      KrokKan                  ; proveden¡ kroku kan lu 3
         mov       si,offset TabKanal+3*KanSize ; adresa definice dal¨¡ho kan lu
         call      KrokKan                  ; proveden¡ kroku kan lu 4
         test      byte ptr ds:[Param],bit6 ; je p©eru¨en¡ sekce melodie ?
         jnz       BreakS                   ; p©eru¨en¡ sekce melodie
         ret

Posun    ENDP

; *****************************************************************************
;                                PosTakt
;                        posun melodie o dal¨¡ takt
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
;        p©eru¨en¡ je povoleno
; procedura nemus¡ uchov vat ‘ dn˜ registr
; *****************************************************************************

PosTakt  PROC      NEAR

; ------ adresa ‡¡sla sekce melodie

         mov       es,ds:[DatBuff]          ; adresa datov‚ho bufferu melodie
         mov       di,ds:[AdrSekce]         ; adresa sekc¡ melodie
         add       di,word ptr ds:[Sekce]   ; + ‡¡slo aktivn¡ sekce

; ------ adresa ukazatele melodie

         mov       ah,es:[di]               ; ‡¡slo sou‡asn‚ sekce melodie
         mov       al,0
         mov       ds:[CitKrok],al          ; nulov n¡ ‡¡ta‡e krok– v sekci
         shl       ax,1
         shl       ax,1                     ; p©evod KB na bajty
         add       ax,ds:[Takt]             ; p©i‡ten¡ adresy taktu v sekci
         add       ax,ds:[Zahlavi]          ; p©i‡ten¡ z hlav¡ souboru
         mov       di,ax                    ; adresa melodie v souboru

; ------ obsluha taktu jednotliv˜ch kan l–

         mov       si,offset TabKanal       ; tabulka definic kan l–
         call      TonKan                   ; obsluha t¢nu kan lu 1

         call      ZvysF                    ; tady by asi mˆl b˜t impuls hodin

         mov       si,offset TabKanal+KanSize ; adresa definice dal¨¡ho kan lu
         call      TonKan                   ; obsluha t¢nu kan lu 2
         mov       si,offset TabKanal+2*KanSize ; adresa definice dal¨¡ho kan lu
         call      TonKan                   ; obsluha t¢nu kan lu 3
         mov       si,offset TabKanal+3*KanSize ; adresa definice dal¨¡ho kan lu
         call      TonKan                   ; obsluha t¢nu kan lu 4

; ------ posun ukazatele na dal¨¡ t¢n

         add       word ptr ds:[Takt],16    ; zv˜¨en¡ ukazatele taktu v sekci
         cmp       word ptr ds:[Takt],400h  ; je ji‘ cel  sekce ?
         jae       BreakS                   ; je ji‘ cel  sekce - konec
         test      byte ptr ds:[Param],bit6 ; je p©eru¨en¡ sekce melodie ?
         jnz       BreakS                   ; p©eru¨en¡ sekce melodie
         ret

; ------ dal¨¡ sekce melodie

BreakS:  mov       word ptr ds:[Takt],0     ; ukazatel v sekci melodie
         and       byte ptr ds:[Param],not bit6 ; zru¨en¡ p©¡znaku p©eru¨en¡
         mov       al,ds:[Sekce]            ; ‡¡slo aktivn¡ sekce
         inc       ax                       ; zv˜¨en¡ ‡¡sla sekce
         mov       ds:[Sekce],al            ; nov‚ ‡¡slo sekce
         cmp       al,ds:[SekceN]           ; je ji‘ cel  skladba ?
         jb        BreakS1                  ; nen¡ je¨tˆ cel  skladba
         or        byte ptr ds:[Param],bit3 ; p©¡znak ukon‡en¡ melodie
BreakS1: ret

PosTakt  ENDP

; *****************************************************************************
;                             TonKan
;            obsluha t¢nu jednoho kan lu (jeden takt melodie)
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
;        DS:SI=ukazatel definice kan lu
;        ES:DI=ukazatel melodie
; VSTUP:DI=ukazatel melodie dal¨¡ho kan lu
; procedura nemus¡ uchov vat ‘ dn˜ registr kromˆ DS, ES a DI
; *****************************************************************************

TonKan   PROC      NEAR

; ------ £schova definice t¢nu

         mov       ax,es:[di]               ; prvn¡ slovo t¢nu
         mov       ds:[si+KanTon],ax        ; £schova prvn¡ho slova t¢nu
         mov       ax,es:[di+2]             ; druh‚ slovo t¢nu
         mov       ds:[si+KanTon+2],ax      ; £schova druh‚ho slova t¢nu
         add       di,4                     ; zv˜¨en¡ ukazatele melodie

; ------ stanoven¡ ‡¡sla n stroje

         mov       cl,4                     ; po‡et rotac¡
         shr       al,cl                    ; ‡¡slo n stroje
         mov       ah,ds:[si+KanTon]        ; 1. bajt t¢nu
         and       ah,10h                   ; 5. bit ‡¡sla n stroje
         or        al,ah                    ; ‡¡slo n stroje
         jz        TonKan3                  ; nenastavuje se nov˜ vzorek

; ------ segment adresa definice vzorku n stroje

         mov       bl,al                    ; ‡¡slo n stroje 1 ...
         mov       bh,0
         shl       bx,1                     ; ‡¡slo n stroje * 2 + 2
         mov       ax,ds:[bx+TabVzor-2]     ; segment adresy vzorku n stroje
         mov       ds:[si+Kan0Segm],ax      ; segment adresy vzorku n stroje

; ------ velikost vzorku ve slovech

         mov       al,15                    ; d‚lka definice jednoho n stroje/2
         mul       bl                       ; offset v tabulce n stroj– + 30
         mov       bx,ax                    ; offset definice n stroje + 30
         mov       ax,es:[bx+20+16h-30]     ; velikost vzorku
         mov       ds:[si+Kan0Size],ax      ; £schova velikosti vzorku

; ------ nastaven¡ hlasitosti kan lu

         mov       al,es:[bx+20+19h-30]     ; hlasitost vzorku

;         mov       al,64

         mov       ds:[si+KanVol],al        ; nastaven¡ hlasitosti kan lu
         mov       ds:[si+KanVol0],al

; ------ za‡ tek a konec opakov n¡ vzorku

         mov       dx,es:[bx+20+1ch-30]     ; d‚lka pro opakov n¡ vzorku
         xchg      dh,dl                    ; oprava po©ad¡ bajt–
         shl       dx,1                     ; p©evod d‚lky na bajty
         jnc       TonKan11                 ; d‚lka je OK
         mov       dx,0ffffh                ; omezen¡ d‚lky
TonKan11:mov       ax,es:[bx+20+1ah-30]     ; za‡ tek pro opakov n¡ vzorku
         xchg      ah,al                    ; oprava po©ad¡ bajt–
         shl       ax,1                     ; p©evod za‡ tku na bajty
         jnc       TonKan12                 ; za‡ tek je OK
         mov       ax,0ffffh                ; omezen¡ za‡ tku
TonKan12:sub       dx,4                     ; je d‚lka pro opakov n¡ OK ?
         ja        TonKan2                  ; d‚lka je OK
         xor       dx,dx                    ; d‚lka = 0 (nen¡ opakov n¡)
         xor       ax,ax                    ; nen¡ opakov n¡
TonKan2: add       dx,ax                    ; konec pro opakov n¡
         jnc       TonKan22                 ; nen¡ p©ete‡en¡
         mov       dx,0ffffh                ; omezen¡ konce
TonKan22:mov       ds:[si+KanBeg0],ax       ; za‡ tek pro opakov n¡
         mov       ds:[si+KanEnd0],dx       ; konec pro opakov n¡

; ------ test, zda je zad n t¢n

TonKan3: test      word ptr ds:[si+KanTon],0ff0fh ; je zad n t¢n ?
         jz        TonKan8                 ; t¢n nen¡ zad n

; ------ obsluha povelu 3 - £schova t¢nu

         mov       al,ds:[si+KanTon+2]      ; t©et¡ bajt t¢nu (povel)
         and       al,0fh                   ; povel
         cmp       al,3                     ; je povel 3 ?
         jne       TonKan5                  ; nen¡ povel 3
         call      PushTon                  ; £schova t¢nu
         jmp       short TonKan8

; ------ p©¡prava ukazatel– vzorku

TonKan5: mov       ax,ds:[si+Kan0Segm]      ; segment adresy vzorku
         mov       ds:[si+KanSegm],ax       ; segment adresy vzorku
         xor       ax,ax
         mov       ds:[si+KanOffs],ax       ; offset ukazatele vzorku
         mov       ds:[si+KanIncZ],al       ; ‡¡ta‡ zlomku ukazatele
         mov       ds:[si+KanTrem],al       ; ukazatel f ze tremola

; ------ koncov  adresa vzorku

         mov       ax,ds:[si+Kan0Size]      ; velikost vzorku
         shl       ax,1                     ; p©evod velikosti na bajty
         jnc       TonKan6                  ; velikost je OK
         mov       ax,0ffffh                ; omezen¡ velikosti
TonKan6: sub       ax,4
         jnc       TonKan62
         xor       ax,ax
TonKan62:mov       ds:[si+KanEnd],ax        ; koncov  adresa vzorku

; ------ £schova dˆlic¡ konstanty vzorku

         mov       cx,ds:[si+KanTon]        ; dˆlic¡ konstanta vzorku
         xchg      ch,cl                    ; oprava po©ad¡ bajt–
         and       cx,0fffh                 ; maskov n¡ dˆlic¡ konstanty
         mov       ds:[si+KanFrekv],cx      ; £schova dˆlic¡ konstanty

; ------ v˜po‡et p©¡rustku ukazatele vzorku

         call      KrokKn01                 ; v˜po‡et dˆlic¡ konstanty
;         xor       ax,ax
;         jcxz      TonKan7                  ; nen¡ frekvence
;         mov       ax,word ptr ds:[RefFrek] ; konstanta pro v˜po‡et frekvence
;         mov       dx,word ptr ds:[RefFrek+2]
;         div       cx                       ; v˜po‡et frekvence
;TonKan7: mov       ds:[si+KanInc0],al       ; p©¡rustek ‡¡ta‡e zlomku ukazatele
;         mov       ds:[si+KanInc],ah        ; p©¡rustek ukazatele vzorku

; ------ obsluha povelu ‡¡slo 0dh a vy¨¨¡

TonKan8: mov       bl,ds:[si+KanTon+2]      ; t©et¡ bajt t¢nu (povel)
         and       bx,0fh                   ; povel
         sub       bl,11                    ; je povel > 11 ?
         jb        TonKan9                  ; n¡zk‚ ‡¡slo povelu
         shl       bx,1                     ; offset povelu v tabulce
         mov       al,ds:[si+KanTon+3]      ; parametr povelu
         jmp       word ptr ds:[bx+Povely2] ; skok na obsluhu funkce povelu

TonKan9: ret

TonKan   ENDP

Povely2  label     word
         dw        TonJMP                   ; 11 JMP : skok na sekci melodie
         dw        TonVOL                   ; 12 VL= : nastaven¡ hlasitosti
         dw        TonBRK                   ; 13 BRK : p©eru¨en¡ sekce melodie
         dw        TonKan9                  ; 14 FTR : ???
         dw        TonSPD                   ; 15 Sd= : nastaven¡ rychlosti hry

; -----------------------------------------------------------------------------
;        povel 3: TON £schova t¢nu - ‡ st 1
; -----------------------------------------------------------------------------

PushTon  PROC      NEAR

; ------ £schova frekvence

         mov       ax,ds:[si+KanTon]        ; prvn¡ slovo t¢nu
         xchg      ah,al                    ; oprava po©ad¡ bajt–
         and       ax,0fffh                 ; zadan˜ t¢n
         mov       ds:[si+KanPshF],ax       ; £schova frekvence

; ------ porovn n¡ se sou‡asn˜m t¢nem

         mov       cx,ds:[si+KanFrekv]      ; sou‡asn  frekvence
         mov       byte ptr ds:[si+KanParF],0 ; p©¡znak - t¢n je ni‘¨¡
         cmp       ax,cx                    ; porovn n¡ se sou‡asnou frekvenc¡
         je        PushTon3                 ; nen¡ zmˆnˆna
         jg        PushTon4                 ; je vˆt¨¡

; ------ nov˜ t¢n je vy¨¨¡

         mov       byte ptr ds:[si+KanParF],1 ; p©¡znak - t¢n je n¡‘¨¡
         jmp       short KrokPsh            ; povel 3 - ‡ st 2

PushTon3:mov       word ptr ds:[si+KanPshF],0 ; zru¨en¡ uschovan‚ho t¢nu
PushTon4:ret

PushTon  ENDP

; -----------------------------------------------------------------------------
;        povel 3: TON £schova t¢nu - ‡ st 2
; -----------------------------------------------------------------------------

KrokPsh  PROC      NEAR

         mov       al,ds:[si+KanTon+3]      ; povel
         xor       dx,dx
         mov       ds:[si+KanTon+3],dl

         cmp       ds:[di+KanPshF],dx
         je        KrokPsh9                 ; nen¡ uschovan˜ ‘ dn˜ t¢n
         mov       ah,0
         mov       cx,ds:[si+KanFrekv]
         mov       bx,ds:[si+KanPshF]

         cmp       ds:[si+KanParF],dl
         jne       KrokPsh3
         add       cx,ax
         mov       ds:[si+KanFrekv],cx
         cmp       bx,cx
         jae       KrokPsh2
KrokPsh1:mov       ds:[si+KanFrekv],bx
         mov       ds:[si+KanPshF],dx

KrokPsh2:jmp       KrokKan0                 ; nastaven¡ nov‚ frekvence

KrokPsh3:sub       cx,ax
         mov       ds:[si+KanFrekv],cx
         cmp       bx,cx
         jl        KrokPsh2
         mov       cx,bx
         jmp       short KrokPsh1

KrokPsh9:ret

KrokPsh  ENDP

; -----------------------------------------------------------------------------
;        povel 11: JMP skok na danou sekci melodie
; -----------------------------------------------------------------------------

TonJMP   PROC      NEAR

         dec       ax                       ; p©ednastaven¡ ‡¡sla sekce
         mov       ds:[Sekce],al            ; ‡¡slo nov‚ sekce
         or        byte ptr ds:[Param],bit6 ; p©¡znak p©eru¨en¡ sekce skladby
         ret

TonJMP   ENDP

; -----------------------------------------------------------------------------
;        povel 12: VL= nastaven¡ hlasitosti t¢nu
; -----------------------------------------------------------------------------

TonVOL   PROC      NEAR

         cmp       al,64                    ; maxim ln¡ hlasitost
         jbe       TonVol1                  ; hlasitost je OK
         mov       al,64                    ; omezen¡ hlasitosti
TonVol1: mov       ds:[si+KanVol],al        ; nov  hlasitost kan lu
         ret

TonVol   ENDP

; -----------------------------------------------------------------------------
;        povel 13: BRK p©eru¨en¡ sekce melodie
; -----------------------------------------------------------------------------

TonBRK   PROC      NEAR

         or        byte ptr ds:[Param],bit6 ; p©¡znak p©eru¨en¡ sekce skladby
         ret

TonBRK   ENDP

; -----------------------------------------------------------------------------
;        povel 15: Sd= nastaven¡ rychlosti hry
; -----------------------------------------------------------------------------

TonSPD   PROC      NEAR

         cmp       al,31                    ; maxim ln¡ rychlost 31
         jbe       TonSPD1                  ; rychlost je OK
         mov       al,31                    ; omezen¡ rychlosti na 31 krok–
TonSPD1: cmp       al,0                     ; je rychlost 0 ?
         je        TonSPD2                  ; rychlost se nenastavuje
         mov       ds:[Rychlost],al         ; nov  rychlost hry
TonSPD2: ret

TonSPD   ENDP

; *****************************************************************************
;                             KrokKan
;                  proveden¡ kroku t¢nu jednoho kan lu
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
;        SI=ukazatel definice kan lu
;        p©eru¨en¡ je povoleno
; procedura nemus¡ uchov vat ‘ dn˜ registr kromˆ DS
; *****************************************************************************

KrokKan  PROC      NEAR

; ------ nen¡-li ‘ dn  funkce, pouze obnoven¡ frekvence

         test      word ptr ds:[si+KanTon+2],0ff0fh ; je nˆjak  funkce ?
         jnz       KrokKan2                 ; je nˆjak  funkce

                                          ;* sem se sk ‡e z funkc¡
KrokKan0:mov       cx,ds:[si+KanFrekv]      ; uschovan  dˆlic¡ konstanta
KrokKn01:xor       ax,ax
         jcxz      KrokKan1                 ; nen¡ frekvence
         mov       ax,word ptr ds:[RefFrek] ; konstanta pro v˜po‡et frekvence
         mov       dx,word ptr ds:[RefFrek+2]
         div       cx                       ; v˜po‡et frekvence
KrokKan1:mov       ds:[si+KanInc0],al       ; p©¡rustek ‡¡ta‡e zlomku ukazatele
         mov       ds:[si+KanInc],ah        ; p©¡rustek ukazatele vzorku
         ret

; ------ obsluha funkce

KrokKan2:mov       bl,ds:[si+KanTon+2]      ; t©et¡ bajt t¢nu (povel)
         and       bx,0fh                   ; povel
         cmp       bl,4                     ; je povel > 4 ?
         ja        KrokKan3                 ; neobsluhovan˜ povel
         shl       bx,1                     ; offset povelu v tabulce
         mov       ah,0
         mov       al,ds:[si+KanTon+3]      ; parametr povelu
         jmp       word ptr ds:[bx+Povely1] ; skok na obsluhu funkce povelu

; ------ p©epo‡¡t n¡ frekvence

KrokKan3:call      KrokKan0                 ; p©epo‡¡t n¡ frekvence

; ------ obsluha povelu 10

         mov       bl,ds:[si+KanTon+2]      ; t©et¡ bajt t¢nu (povel)
         and       bl,0fh                   ; povel
         cmp       bl,10
         jne       KrokKan9
         jmp       KrokVLS                  ; funkce 10 - zmˆna hlasitosti
KrokKan9:ret

KrokKan  ENDP

Povely1  label     word
         dw        KrokARP                  ; 0 ARP : zmˆna hlasitosti
         dw        KrokUP1                  ; 1 PR^ : zv˜¨en¡ frekvence
         dw        KrokDWN                  ; 2 PRv : sn¡‘en¡ frekvence
         dw        KrokPsh                  ; 3 TON :
         dw        KrokTRM                  ; 4 VIB : tremolo

; -----------------------------------------------------------------------------
;        povel 0: ARP nastaven¡ frekvence
; -----------------------------------------------------------------------------

KrokARP  PROC      NEAR

         mov       al,ds:[CitKrok]          ; ‡¡ta‡ krok– na takt
         mov       ah,0
         mov       bl,3
         div       bl

         mov       al,ah
         cmp       al,0
         je        KrokARP3
         cmp       al,2
         je        KrokARP2

         mov       al,ds:[si+KanTon+3]
         mov       cl,4
         shr       al,cl
         jmp       short KrokARP4

KrokARP2:mov       al,ds:[si+KanTon+3]
         and       al,0fh
         jmp       short KrokARP4

KrokARP3:mov       ax,ds:[si+KanFrekv]
         jmp       short KrokARP6

; ------ nalezen¡ nejbli‘¨¡ frekvence

KrokARP4:mov       ah,0
         shl       ax,1
         mov       bx,ax
         mov       dx,ds:[si+KanFrekv]
         mov       di,offset TabTon+2
         mov       cx,offset(TabTon0-TabTon)/2 - 4
KrokARP5:mov       ax,ds:[bx+di]
         cmp       dx,ds:[di]
         jge       KrokARP6
         add       di,2
         loop      KrokARP5
         ret

KrokARP6:mov       cx,ax
         jmp       KrokKn01                 ; p©epo‡et frekvence

KrokARP  ENDP

; -----------------------------------------------------------------------------
;        povel 1: PR^ zv˜¨en¡ frekvence
; -----------------------------------------------------------------------------

KrokUP1  PROC      NEAR

; ------ sn¡‘en¡ dˆlic¡ konstanty

         mov       dx,ds:[si+KanFrekv]      ; sou‡asn  frekvence
         sub       dx,ax                    ; sn¡‘en¡ dˆlic¡ konstanty
         jc        KrokUP11                 ; podte‡en¡ konstanty

; ------ omezen¡ konstanty zdola

         cmp       dx,71h                   ; minim ln¡ konstanta
         jae       KrokUP12                 ; konstanta je OK
KrokUP11:mov       dx,71h                   ; omezen¡ konstanty
KrokUP12:mov       ds:[si+KanFrekv],dx      ; nov  konstanta

; ------ v˜po‡et p©¡rustku f ze vzorku

         jmp       KrokKan0                 ; v˜po‡et nov‚ konstanty

KrokUP1  ENDP

; -----------------------------------------------------------------------------
;        povel 2: PRv sn¡‘en¡ frekvence
; -----------------------------------------------------------------------------

KrokDWN  PROC      NEAR

; ------ zv˜¨en¡ dˆlic¡ konstanty

         mov       dx,ds:[si+KanFrekv]      ; sou‡asn  frekvence
         add       dx,ax                    ; zv˜¨en¡ dˆlic¡ konstanty
         jc        KrokDWN1                 ; p©ete‡en¡ konstanty

; ------ omezen¡ konstanty shora

         cmp       dx,358h                  ; maxim ln¡ konstanta
         jbe       KrokDWN2                 ; konstanta je OK
KrokDWN1:mov       dx,358h                  ; omezen¡ konstanty
KrokDWN2:mov       ds:[si+KanFrekv],dx      ; nov  konstanta

; ------ v˜po‡et p©¡rustku f ze vzorku

         jmp       KrokKan0                 ; v˜po‡et nov‚ konstanty

KrokDWN  ENDP

; -----------------------------------------------------------------------------
;        povel 4: VIB tremolo
; -----------------------------------------------------------------------------

KrokTRM  PROC      NEAR

;         mov       ds:[si+KanTrem0],al         ; amplituda tremola

; ------ sou‡asn  odchylka frekvence

         mov       bl,ds:[si+KanTrem]       ; f ze tremola
         add       byte ptr ds:[si+KanTrem],8 ; zv˜¨en¡ f ze tremola
;         shr       bl,1
;         shr       bl,1
         and       bx,1fh                   ; 32 stup¤–
         mov       bl,ds:[bx+TabSin]        ; odchylka frekvence absolutnˆ
         sub       bl,80h                   ; p©evod na ‡¡slo se znam‚nkem

; ------ normalizace odchylky amplitudou

;         shr       al,1
;         shr       al,1
;         shr       al,1
;         shr       al,1

         and       al,0fh                   ; amplituda tremola
         imul      bl                       ; v˜po‡et odchylky frekvence
         mov       cl,6
         sar       ax,cl                    ; oprava amplitudy
         add       ax,ds:[si+KanFrekv]      ; nov  frekvence

; ------ v˜po‡et nov‚ konstanty

         mov       cx,ax
         jmp       KrokKn01

;         xor       ax,ax
;         jcxz      KrokTRM1                 ; nen¡ frekvence
;         mov       ax,word ptr ds:[RefFrek] ; konstanta pro v˜po‡et frekvence
;         mov       dx,word ptr ds:[RefFrek+2]
;         div       cx                       ; v˜po‡et frekvence
;KrokTRM1:mov       ds:[si+KanInc0],al       ; p©¡rustek ‡¡ta‡e zlomku ukazatele
;         mov       ds:[si+KanInc],ah        ; p©¡rustek ukazatele vzorku

         ret

KrokTRM  ENDP

; -----------------------------------------------------------------------------
;        povel 10: VLs plynul  zmˆna hlasitosti
; -----------------------------------------------------------------------------

KrokVLS  PROC      NEAR

; ------ zmˆna hlasitosti nahoru

         mov       al,ds:[si+KanTon+3]      ; parametr funkce
         mov       cl,4
         shr       al,cl
         jz        KrokVls2                 ; nen¡ zmˆna hlasitosti nahoru
         mov       ch,ds:[si+KanVol0]       ; uschovan  hlasitost kan lu
         add       ch,al                    ; zv˜¨en¡ hlasitosti

; ------ omezen¡ hlasitosti

         cmp       ch,40h                   ; maxim ln¡ hlasitost
         jbe       KrokVLS1                 ; hlasitost je OK
         mov       ch,40h                   ; omezen¡ hlasitosti

; ------ zmˆna hlasitosti dol–

KrokVLS1:mov       ds:[si+KanVol],ch        ; nov  hlasitost kan lu
         mov       ds:[si+KanVol0],ch       ;
         ret

; ------ zmˆna hlasitosti dol–

KrokVls2:mov       al,ds:[si+KanTon+3]      ; parametr funkce
         and       al,0fh
         mov       ch,ds:[si+KanVol0]       ; uschovan  hlasitost kan lu
         sub       ch,al                    ; sn¡‘en¡ hlasitosti

; ------ omezen¡ hlasitosti

         jnc       KrokVLS3                 ; hlasitost je OK
         mov       ch,0                     ; omezen¡ hlasitosti

; ------ zmˆna hlasitosti nahoru

KrokVLS3:mov       ds:[si+KanVol],ch        ; nov  hlasitost kan lu
         mov       ds:[si+KanVol0],ch       ;
         ret


;; ------ zmˆna hlasitosti nahoru
;
;         mov       ch,ds:[si+KanVol0]       ; sou‡asn  hlasitost kan lu
;         mov       al,ds:[si+KanTon+3]      ; parametr funkce
;         mov       cl,4
;         shr       al,cl                    ; zmˆna hlasitosti nahoru
;         add       ch,al                    ; zv˜¨en¡ hlasitosti
;
;; ------ omezen¡ hlasitosti
;
;         cmp       ch,40h                   ; maxim ln¡ hlasitost
;         jbe       KrokVLS2                 ; hlasitost je OK
;         mov       ch,40h                   ; omezen¡ hlasitosti
;
;; ------ zmˆna hlasitosti dol–
;
;KrokVLS2:mov       al,ds:[si+KanTon+3]      ; parametr funkce
;         and       al,0fh                   ; hlasitost
;         sub       ch,al                    ; sn¡‘en¡ hlasitosti
;         jnc       KrokVLS3                 ; nen¡ podte‡en¡
;         mov       ch,0                     ; omezen¡ p©i podte‡en¡
;KrokVLS3:mov       ds:[si+KanVol],ch        ; nov  hlasitost kan lu
;         mov       ds:[si+KanVol0],ch       ;
;         ret

KrokVLS  ENDP

; *****************************************************************************
;                              Int08
;                 obsluha p©eru¨en¡ hodin INT 08h
; *****************************************************************************

Int08    PROC      FAR

         mov       byte ptr cs:[Par08],1    ; p©¡znak impulsu hodin
         test      byte ptr cs:[Param],bit7 ; je pozastaven¡ melodie ?
         jz        Int08012                 ; nen¡ pozastaven¡ melodie

; ------ ukon‡en¡ p©eru¨en¡ p©i pozastaven¡ melodie

Int08011:push      ax
         mov       al,20h
         out       [20h],al                 ; uvolnˆn¡ ©adi‡e p©eru¨en¡
         pop       ax
         iret

; ------ je p©ete‡en¡ - prob¡h  ji‘ obsluha INT 08h ?

Int08012:test      byte ptr cs:[Param],bit4 ; prob¡h  obsluha INT 08h ?
         jz        Int080                   ; neprob¡h  obsluha INT 08h
         test      byte ptr cs:[Param2],bit3+bit4 ; sni‘uje se rychlost/INT09 ?
         jnz       Int08011                 ; je obsluha sn¡‘en¡ rychlosti/INT09
         or        byte ptr cs:[Param2],bit3 ; p©¡znak obsluhy

; ------ ukon‡en¡ p©eru¨en¡

         push      ax
         mov       al,20h
         out       [20h],al                 ; uvolnˆn¡ ©adi‡e p©eru¨en¡
         pop       ax
         sti                                ; povolen¡ p©eru¨en¡ pro hav rii

; ------ je chyba - sn¡‘en¡ rychlosti hodin

         push      cx
         mov       ch,0
         mov       cl,cs:[Konst08]
         inc       cx                       ; zv˜¨en¡ dˆlic¡ konstanty
         jz        Int08014                 ; je ji‘ maxim ln¡ konstanta
         cli                                ; teƒ u‘ zase z kaz p©eru¨en¡
         mov       cs:[Konst08],cl          ; dˆlic¡ konstanta hodin INT 08h

; ------ nov‚ nastaven¡ hodin

         push      ax
         push      dx

         mov       al,34h
         out       [43h],al                 ; povel pro nastaven¡ hodin
         mov       al,cl                    ; dˆlic¡ konstanta pro hodiny
         out       [40h],al                 ; dˆlic¡ konstanta pro hodiny LOW
         mov       al,0
         out       [40h],al                 ; vy¨¨¡ bajt dˆlic¡ konstanty

; ------ oprava frekvence po zaokrouhlen¡ (25386 a‘ 8007 Hz)

         mov       dx,12h
         mov       ax,34deh                 ; frekvence krystalu 1 193 182 Hz
         div       cx                       ; v˜po‡et zaokrouhlen‚ frekvence
         mov       cs:[Frekv08],ax          ; frekvence hodin INT 08h

; ------ inicializace po‡tu impuls– na krok (497 a‘ 157)

         xor       dx,dx
         div       word ptr cs:[KrokSek]    ; po‡et impuls– hodin na krok
         mov       cs:[Impulsu],ax          ; po‡et impuls– hodin na krok

; ------ p©evodn¡ konstanta frekvence

         mov       ax,300h                  ; konstanta pro mal˜ soubor
         mul       cx                       ; * dˆlic¡ konstanta
         mov       word ptr cs:[RefFrek],ax ; konstanta pro p©evod frekvence LOW
         mov       word ptr cs:[RefFrek+2],dx ; konstanta pro p©evod HIGH

         sti                                ; u‘ m–‘e p©ij¡t p©eru¨en¡
         pop       dx
         pop       ax
Int08014:pop       cx
         cli
         and       byte ptr cs:[Param2],not bit3 ; p©¡znak obsluhy
         iret

; ------ £schova registr–

Int080:  push      ax

; ------ uvolnˆn¡ ©adi‡e p©eru¨en¡ (odteƒ m–‘e nastat znovu p©eru¨en¡ INT 08h)

         or        byte ptr cs:[Param],bit4 ; p©¡znak obsluhy INT 08h
         mov       al,20h
         out       [20h],al                 ; uvolnˆn¡ ©adi‡e p©eru¨en¡
         sti                                ; mo‘n‚ opˆtovn‚ p©eru¨en¡

; ------ £schova registr–

         push      bx
         push      cx
         push      dx
         push      si
         push      ds
         push      es

; ------ p©¡prava registr–

         push      cs
         pop       ds                       ; DS <- CS
         mov       si,offset TabKanal       ; tabulka prvn¡ho kan lu
         mov       dl,0                     ; st©ada‡ amplitudy
         mov       dh,4                     ; po‡et kan l–

; ------ adresa vzorku

Int081:  mov       cx,ds:[si+KanSegm]       ; segment adresy vzorku
         jcxz      Int086                   ; kan l nen¡ aktivn¡
         mov       es,cx                    ; segment adresy vzorku
         mov       bx,ds:[si+KanOffs]       ; offset adresy vzorku

; ------ konec vzorku - jeho opakov n¡

         cmp       bx,ds:[si+KanEnd]        ; je ji‘ konec vzorku ?
         jb        Int082                   ; nen¡ je¨tˆ konec vzorku
         mov       bx,ds:[si+KanBeg0]       ; nov˜ za‡ tek vzorku
         mov       cx,ds:[si+KanEnd0]       ; konec pro opakov n¡ vzorku
         jcxz      Int086                   ; nen¡ opakov n¡ vzorku
         mov       ds:[si+KanEnd],cx        ; nov˜ konec vzorku

; ------ zv˜¨en¡ ukazatele vzorku

Int082:  mov       al,ds:[si+KanInc0]       ; p©¡rustek zlomku p©¡rustku ukaz.
         add       ds:[si+KanIncZ],al       ; zv˜¨en¡ zlomku p©¡rustku
         mov       al,ds:[si+KanInc]        ; p©¡rustek ukazatele vzorku
         mov       ah,0
         adc       bx,ax                    ; zv˜¨en¡ ukazatele vzorku
         mov       ds:[si+KanOffs],bx       ; nov˜ offset ukazatele

; ------ v˜po‡et hodnoty vzorku

         mov       al,es:[bx]               ; vzorek (0 a‘ 256)
         imul      byte ptr ds:[si+KanVol]  ; vyn soben¡ hlasitost¡
         add       dl,ah                    ; p©i‡ten¡ sign lu ke st©ada‡i

; ------ p©¡prava pro dal¨¡ kan l

Int086:  add       si,KanSize               ; adresa dal¨¡ho kan lu
         dec       dh                       ; ‡¡ta‡ kan l–
         jnz       Int081                   ; dal¨¡ kan l

; ------ vysl n¡ sign lu na port LPT

Int087:  mov       al,dl                    ; nast© dan˜ sign l
         sub       al,80h                   ; posun na nulu
         mov       dx,378h                  ; adresa portu LPT
         out       dx,al                    ; vysl n¡ sign lu na port LPT

; ------ vysl n¡ sign lu na reproduktor

         add       al,80h
         mov       bx,offset TabLog         ; tabulka pro logaritmizaci sign lu
         xlat                               ; konverze podle tabulky
         shl       al,1
         shl       al,1
         mul       byte ptr ds:[Konst08]
         mov       al,ah
         out       [42h],al                 ; vysl n¡ sign lu na reproduktor

; ------ ‡¡ta‡ kroku hry skladby

         cli                                ; z kaz p©eru¨en¡
         and       byte ptr ds:[Param],not bit4  ; zru¨en¡ p©¡znaku INT 08h
         dec       word ptr ds:[CitImp]     ; ‡¡ta‡ impuls– bˆhem jednoho kroku
         jnz       Int089                   ; nen¡ cel˜ krok
         mov       ax,ds:[Impulsu]          ; po‡et impuls– na krok
         mov       ds:[CitImp],ax           ; nov˜ ‡¡ta‡ impuls–
         mov       byte ptr ds:[Par08],0    ; zru¨en¡ p©¡znaku impulsu hodin
         sti                                ; p©eru¨en¡ povoleno

; ------ obsluha posuvu melodie

         push      bp
         push      di

         test      byte ptr ds:[Param2],bit2
         jz        Int088
         call      SnizF
Int088:  or        byte ptr ds:[Param2],bit2 ; p©¡znak obsluhy posunu melodie
         call      Posun                    ; posun kroku hry
         and       byte ptr cs:[Param2],not bit2
         pop       di
         pop       bp

; ------ n vrat registr–

Int089:  pop       es
         pop       ds
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         iret

Int08    ENDP

; -----------------------------------------------------------------------------
;        zv˜¨en¡ frekvence hodin
; -----------------------------------------------------------------------------

ZvysF    PROC      NEAR

; ------ zv˜¨en¡ rychlosti hodin

         cmp       byte ptr cs:[Par08],0    ; p©i¨lo p©eru¨en¡ od hodin ?
         je        ZvysF1                   ; nebylo - mˆlo by se zv˜¨it
         ret

ZvysF1:  push      cx
         mov       ch,0
         mov       cl,cs:[Konst08]
         cmp       cl,47                    ; minim ln¡ konstanta pro 25 kHz
         jbe       SnizF2                   ; je ji‘ minim ln¡ konstanta
         dec       cx                       ; sn¡‘en¡ dˆlic¡ konstanty
         jmp       short SnizF1

ZvysF    ENDP

; -----------------------------------------------------------------------------
;        sn¡‘en¡ frekvence hodin
; -----------------------------------------------------------------------------

SnizF    PROC      NEAR

; ------ sn¡‘en¡ rychlosti hodin

         push      cx
         mov       ch,0
         mov       cl,cs:[Konst08]
         inc       cx                       ; zv˜¨en¡ dˆlic¡ konstanty
         jz        SnizF2                   ; je ji‘ maxim ln¡ konstanta
SnizF1:  cli                                ; teƒ u‘ zase z kaz p©eru¨en¡
         mov       cs:[Konst08],cl          ; dˆlic¡ konstanta hodin INT 08h

; ------ nov‚ nastaven¡ hodin

         push      ax
         push      dx

         mov       al,34h
         out       [43h],al                 ; povel pro nastaven¡ hodin
         mov       al,cl                    ; dˆlic¡ konstanta pro hodiny
         out       [40h],al                 ; dˆlic¡ konstanta pro hodiny LOW
         mov       al,0
         out       [40h],al                 ; vy¨¨¡ bajt dˆlic¡ konstanty

; ------ oprava frekvence po zaokrouhlen¡ (25386 a‘ 8007 Hz)

         mov       dx,12h
         mov       ax,34deh                 ; frekvence krystalu 1 193 182 Hz
         div       cx                       ; v˜po‡et zaokrouhlen‚ frekvence
         mov       cs:[Frekv08],ax          ; frekvence hodin INT 08h

; ------ inicializace po‡tu impuls– na krok (497 a‘ 157)

         xor       dx,dx
         div       word ptr cs:[KrokSek]    ; po‡et impuls– hodin na krok
         mov       cs:[Impulsu],ax          ; po‡et impuls– hodin na krok

; ------ p©evodn¡ konstanta frekvence

         mov       ax,300h                  ; konstanta pro mal˜ soubor
         mul       cx                       ; * dˆlic¡ konstanta
         mov       word ptr cs:[RefFrek],ax ; konstanta pro p©evod frekvence LOW
         mov       word ptr cs:[RefFrek+2],dx ; konstanta pro p©evod HIGH

         sti                                ; u‘ m–‘e p©ij¡t p©eru¨en¡
         pop       dx
         pop       ax
SnizF2:  pop       cx
         ret

SnizF    ENDP


; *****************************************************************************
;                               Int09
;                 obsluha p©eru¨en¡ kl vesnice INT 09h
; *****************************************************************************

Int09    PROC      FAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      ds

         push      cs
         pop       ds
         or        byte ptr ds:[Param2],bit4 ; p©¡znak obsluhy INT 09h

; ------ uvolnˆn¡ ©adi‡e p©eru¨en¡

         mov       al,20h
         out       [20h],al                 ; uvolnˆn¡ ©adi‡e p©eru¨en¡
         sti

; ------ uzam‡en¡ kl vesnice

         call      Cekej09                  ; ‡ek n¡ na p©ipravenost kl vesnice
         mov       al,0adh
         out       [64h],al                 ; vysl n¡ povelu-uzam‡en¡ kl vesnice

; ------ ‡ten¡ k¢du kl vesy

         call      Cekej09                  ; ‡ek n¡ na p©ipravenost kl vesnice
         in        al,[60h]

; ------ pozastaven¡ melodie

         test      byte ptr ds:[Param],bit7
         jz        Int090                   ; melodie nen¡ pozastaven 
         test      al,80h                   ; je stisk kl vesy ?
         jnz       Int091                   ; nen¡ stisk kl vesy
         and       byte ptr ds:[Param],not bit7
         jmp       short Int099

Int090:  cmp       al,1ch                   ; ENTER
         jne       Int091
         or        byte ptr ds:[Param],bit7 ; pozastaven¡ melodie

; ------ opakov n¡ skladby

Int091:  cmp       al,47h                   ; HOME
         jne       Int092
         or        byte ptr ds:[Param],bit5 ; p©¡znak opakov n¡ skladby

; ------ ukon‡en¡ jedn‚ skladby

Int092:  cmp       al,4fh                   ; END
         je        Int093
         cmp       al,39h                   ; mezera
         jne       Int094
Int093:  or        byte ptr ds:[Param],bit3 ; p©¡znak ukon‡en¡ jedn‚ skladby

; ------ p©eru¨en¡ programu

Int094:  cmp       al,1
         jne       Int095
         or        byte ptr ds:[Param],bit2 ; p©¡znak p©eru¨en¡ kl vesnic¡

; ------ kurzor vlevo

Int095:  cmp       al,4bh
         jne       Int096
         mov       word ptr ds:[Takt],0     ; ukazatel v sekci melodie
         mov       bl,ds:[Sekce]            ; ‡¡slo aktivn¡ sekce
         sub       bl,1                     ; sn¡‘en¡ ‡¡sla sekce
         jnc       Int0951
         mov       bl,0
Int0951: mov       ds:[Sekce],bl            ; nov‚ ‡¡slo sekce

; ------ kurzor vpravo

Int096:  cmp       al,4dh
         jne       Int097

         mov       word ptr ds:[Takt],0     ; ukazatel v sekci melodie
         mov       bl,ds:[Sekce]            ; ‡¡slo aktivn¡ sekce
         inc       bx                       ; zv˜¨en¡ ‡¡sla sekce
         cmp       bl,ds:[SekceN]           ; je ji‘ posledn¡ sekce ?
         jb        Int0961                  ; nen¡ posledn¡ sekce
         dec       bx
Int0961: mov       ds:[Sekce],bl            ; nov‚ ‡¡slo sekce


Int097:

; ------ uvolnˆn¡ kl vesnice

Int099:  call      Cekej09                  ; ‡ek n¡ na p©ipravenost kl vesnice
         mov       al,0aeh
         out       [64h],al                 ; vysl n¡ povelu-uvolnˆn¡ kl vesnice

; ------ n vrat registr–

         pop       ds
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         cli
         and       byte ptr cs:[Param2],not bit4 ; p©¡znak obsluhy INT 09h
         iret

Int09    ENDP


; -----------------------------------------------------------------------------
;        ‡ek n¡ na p©ipravenost kl vesnice
; -----------------------------------------------------------------------------

Cekej09  PROC      NEAR

         push      ax
         push      cx
         cli
         mov       cx,5000
Cekej091:in        al,[64h]
         test      al,bit1
         loopnz    Cekej091
         pop       cx
         pop       ax
         ret

Cekej09  ENDP

; *****************************************************************************
;                             InitPort
;               inicializace port–, start hry melodie
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
; *****************************************************************************

InitPort PROC      NEAR

         and       byte ptr ds:[Param],not bit3+bit5 ; zru¨en¡ p©¡znak– konce

; ------ vypnut¡ motor– disketov˜ch mechanik

         mov       dx,3f2h
         mov       al,0ch
         out       dx,al                    ; vypnut¡ motor– mechanik
         push      ds
         xor       ax,ax
         mov       ds,ax
         and       byte ptr ds:[43fh],not bit0+bit1+bit2+bit3+bit4+bit5 ; motory
         pop       ds

; ------ £schova vektoru INT 08h

         mov       ax,3508h
         int       21h                      ; poskytnut¡ adresy INT 08h
         mov       word ptr ds:[Old08],bx
         mov       word ptr ds:[Old08+2],es ; £schova adresy INT 08h

; ------ £schova vektoru INT 09h

         mov       ax,3509h
         int       21h                      ; poskytnut¡ adresy INT 09h
         mov       word ptr ds:[Old09],bx
         mov       word ptr ds:[Old09+2],es ; £schova adresy INT 09h

; ------ £schova registru masky p©eru¨en¡

         in        al,[21h]                 ; registr masky p©eru¨en¡
         mov       ds:[OldMask],al          ; £schova masky p©eru¨en¡

; ------ p©echodn˜ z kaz v¨ech p©eru¨en¡

         cli                                ; z kaz p©eru¨en¡
         mov       al,0ffh
         out       [21h],al                 ; z kaz v¨ech p©eru¨en¡

; ------ instalace INT 08h

         mov       dx,offset Int08          ; obsluha INT 08h
         mov       ax,2508h
         int       21h                      ; instalace obsluhy INT 08h

; ------ instalace INT 09h

         mov       dx,offset Int09          ; obsluha INT 09h
         mov       ax,2509h
         int       21h                      ; instalace obsluhy INT 09h

; ------ inicializace hodin INT 08h

         mov       al,34h
         out       [43h],al                 ; povel pro nastaven¡ hodin
         mov       al,ds:[Konst08]          ; dˆlic¡ konstanta pro hodiny
         out       [40h],al                 ; dˆlic¡ konstanta pro hodiny
         mov       al,0
         out       [40h],al                 ; vy¨¨¡ bajt dˆlic¡ konstanty

; ------ inicializace v˜stupu na reproduktor

         mov       al,90h
         out       [43h],al                 ; povel pro reproduktor - impulsy
         in        al,[61h]
         or        al,3                     ; zapnut¡ v˜stupu na reproduktor
         out       [61h],al

; ------ uvolnˆn¡ p©eru¨en¡ od kl vesnice a hodin

         mov       al,0fch
         out       [21h],al                 ; uvolnˆn¡ p©eru¨en¡
         sti                                ; povolen¡ p©eru¨en¡
         ret

InitPort ENDP


; *****************************************************************************
;                                DeInit
;                     odinstalov n¡ port– po h©e
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
; *****************************************************************************

DeInit   PROC      NEAR

; ------ p©echodn˜ z kaz v¨ech p©eru¨en¡

         mov       al,0ffh
         out       [21h],al                 ; z kaz v¨ech p©eru¨en¡
         cli                                ; z kaz p©eru¨en¡

; ------ vypnut¡ v˜stupu na reproduktor

         in        al,[61h]
         and       al,not 3
         out       [61h],al                 ; vypnut¡ v˜stupu na reproduktor

; ------ standardn¡ nastaven¡ hodin

         mov       al,34h
         out       [43h],al                 ; povel
         mov       al,0
         out       [40h],al                 ; konstanta - n¡‘¨¡ bajt
         out       [40h],al                 ; konstanta - vy¨¨¡ bajt

; ------ standardn¡ nastaven¡ ‡¡ta‡e reproduktoru

         mov       al,0b6h                  ; povel
         out       [43h],al
         mov       al,5                     ; konstanta asi tak 920 Hz
         out       [42h],al                 ; konstanta - n¡‘¨¡ bajt
         out       [42h],al                 ; konstanta - vy¨¨¡ bajt

; ------ n vrat adresy INT 08h

         push      ds
         lds       dx,ds:[Old08]            ; p–vodn¡ adresa INT 08h
         mov       ax,2508h
         int       21h                      ; n vrat adresy INT 08h
         pop       ds

; ------ n vrat adresy INT 09h

         push      ds
         lds       dx,ds:[Old09]            ; p–vodn¡ adresa INT 09h
         mov       ax,2509h
         int       21h                      ; n vrat adresy INT 09h
         pop       ds

; ------ n vrat registru p©eru¨en¡

         mov       al,ds:[OldMask]          ; p–vodn¡ registr masky p©eru¨en¡
         out       [21h],al                 ; n vrat registru masky p©eru¨en¡
         sti                                ; povolen¡ p©eru¨en¡

; ------ ‡ten¡ hodin syst‚mov‚ho ‡asu (AT)

         mov       dl,8ah                   ; p©ednastaven¡ na nesmysl
         mov       ah,2
         int       1ah                      ; ‡ten¡ hodin
         cmp       dl,1                     ; p©ete‡en¡ p©es p–lnoc ?
         ja        Deinit3                  ; hodiny neplat¡

; ------ n vrat p©¡znaku p©ete‡en¡ p©es p–lnoc

         jne       DeInit2                  ; nen¡ p©ete‡en¡ p©es p–lnoc
         xor       ax,ax
         mov       es,ax
         mov       byte ptr es:[470h],dl    ; n vrat p©¡znaku p©ete‡en¡ p–lnoci

; ------ konverze z BCD form tu na bin rn¡

DeInit2: mov       al,ch                    ; hodina
         call      BcdBin                   ; konverze na bin rn¡ tvar
         mov       ch,al
         mov       al,cl                    ; minuta
         call      BcdBin                   ; konverze na bin rn¡ tvar
         mov       cl,al
         mov       al,dh                    ; sekunda
         call      BcdBin                   ; konverze na bin rn¡ tvar
         mov       dh,al

; ------ nastaven¡ ‡asu

         xor       dl,dl                    ; setina sekundy
         mov       ah,2dh
         int       21h                      ; nastaven¡ syst‚mov‚ho ‡asu

DeInit3:

         ret

DeInit   ENDP

; -----------------------------------------------------------------------------
;        Konverze ‡¡sla z BCD tvaru na bin rn¡
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

; *****************************************************************************
;                             InitReg
;                  inicializace ukazatel– a konstant
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
; *****************************************************************************

InitReg  PROC      NEAR

; ------ inicializace ukazatele melodie

         mov       byte ptr ds:[Rychlost],6 ; rychlost hry (po‡et krok– na takt)
         xor       ax,ax                    ; AX <- 0
         mov       ds:[CitKrok],al          ; ‡¡ta‡ krok– v jednom taktu
         mov       ds:[Takt],ax             ; ukazatel taktu v sekci
         mov       ds:[Sekce],al            ; ukazatel sekce melodie

; ------ vynulov n¡ defini‡n¡ch tabulek kan l–

         mov       di,offset TabKanal       ; defini‡n¡ tabulka kan l–
         push      ds
         pop       es
         mov       cx,4*KanSize/2           ; velikost tabulky ve slovech
         cld
         xor       ax,ax                    ; nulovac¡ slovo
         rep       stosw                    ; vynulov n¡ tabulek

; ------ test, zda byly hodiny ji‘ cejchov ny

         test      byte ptr ds:[Param2],bit1 ; byly hodiny ji‘ cejchov ny ?
         jz        InitReg0                 ; nebyly je¨tˆ cejchov ny
         mov       ah,0
         mov       al,ds:[Konst08]          ; dˆlic¡ konstanta hodin
         jmp       InitReg6

; ------ instalace obsluhy INT 08h

InitReg0:mov       ax,3508h
         int       21h
         mov       word ptr ds:[Old08],bx
         mov       word ptr ds:[Old08+2],es ; £schova adresy INT 08h
         mov       dx,offset IntR08
         mov       ax,2508h
         int       21h                      ; instalace nov‚ obsluhy INT 08h

; ------ synchonizace na hranu syst‚mov˜ch hodin

         EVEN
         sti                                ; p©eru¨en¡ mus¡ b˜t povoleno
         mov       byte ptr ds:[Par08],0
InitReg1:cmp       byte ptr ds:[Par08],0    ; byla zmˆna hodin ?
         je        InitReg1                 ; ‡ek n¡ na zmˆnu hodin

; ------ zmˆ©en¡ doby mezi dvˆma hranami syst‚mov˜ch hodin

         mov       byte ptr ds:[Par08],0
         xor       ax,ax                    ; ‡¡ta‡ doby LOW
         xor       dx,dx                    ; ‡¡ta‡ doby HIGH
InitReg2:add       ax,1                     ; zv˜¨en¡ ‡¡ta‡e pr–chod–
         adc       dx,0                     ; p©enos HIGH
         cmp       byte ptr ds:[Par08],0    ; byla zmˆna hodin ?
         je        InitReg2                 ; ‡ek n¡ na zmˆnu hodin

; ------ n vrat stavu hodin

         push      ax
         push      dx
         push      ds
         lds       dx,ds:[Old08]
         mov       ax,2508h
         int       21h
         pop       ds
         pop       dx
         pop       ax
         int       08h                      ; oprava hodin
         int       08h                      ; oprava hodin

; ------ v˜po‡et frekvence hodin

         shl       ax,1                     ; konstanta * 2
         rcl       dx,1
         shl       ax,1
         rcl       dx,1
         shl       ax,1
         rcl       dx,1
         shl       ax,1
         rcl       dx,1
         shl       ax,1
         rcl       dx,1
;þ
;         mov       cx,4
         mov       cx,DelKon                ; dˆlic¡ konstanta
         mov       bx,ax
         mov       ax,dx
         xor       dx,dx
         div       cx                       ; vydˆlen¡ vy¨¨¡ho slova
         xchg      ax,bx                    ; n vrat ni‘¨¡ho slova
         div       cx                       ; vydˆlen¡ ni‘¨¡ho slova

;         mov       ax,3e25h

; ------ omezen¡ frekvence shora

         or        bx,bx                    ; je p©ete‡en¡ p©es 64 K ?
         jnz       InitReg3                 ; je p©ete‡en¡ nahoru
         cmp       ax,MaxF                  ; omezen¡ asi na 25 KHz
         jbe       InitReg4                 ; konstanta je OK
InitReg3:mov       ax,MaxF                  ; omezen¡ shora

; ------ omezen¡ frekvence zdola

InitReg4:cmp       ax,MinF                  ; minim ln¡ frekvence
         jae       InitReg5                 ; frekvence je OK
         mov       ax,MinF                  ; omezen¡ zdola
InitReg5:mov       cx,ax                    ; £schova frekvence hodin

; ------ dˆlic¡ konstanta hodin (47 a‘ 149)

         mov       dx,12h
         mov       ax,34deh                 ; frekvence krystalu 1 193 182 Hz
         div       cx                       ; v˜po‡et dˆlic¡ konstanty hodin
         mov       ds:[Konst08],al          ; dˆlic¡ konstanta hodin INT 08h

; ------ oprava frekvence po zaokrouhlen¡ (25386 a‘ 8007 Hz)

InitReg6:mov       cx,ax                    ; vypo‡ten  dˆlic¡ konstanta
         or        byte ptr ds:[Param2],bit1 ; p©¡znak ocejchov n¡ hodin
         mov       dx,12h
         mov       ax,34deh                 ; frekvence krystalu 1 193 182 Hz
         div       cx                       ; v˜po‡et zaokrouhlen‚ frekvence
         mov       ds:[Frekv08],ax          ; frekvence hodin INT 08h

; ------ inicializace po‡tu impuls– na krok (497 a‘ 157)

         xor       dx,dx
         div       word ptr ds:[KrokSek]    ; po‡et impuls– hodin na krok
         mov       ds:[Impulsu],ax          ; po‡et impuls– hodin na krok
         mov       ds:[CitImp],ax           ; ‡¡ta‡ impuls– na jeden krok

; ------ p©evodn¡ konstanta frekvence

         mov       ax,300h                  ; konstanta pro mal˜ soubor
         mul       cx                       ; * dˆlic¡ konstanta
         mov       word ptr ds:[RefFrek],ax ; konstanta pro p©evod frekvence LOW
         mov       word ptr ds:[RefFrek+2],dx ; konstanta pro p©evod HIGH

         ret

InitReg  ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

IntR08   PROC      FAR

         mov       byte ptr cs:[Par08],1
         push      ax
         mov       al,20h
         out       [20h],al
         pop       ax
         iret

IntR08   ENDP

EVEN
Par08    db        0                        ; p©¡znak obsluhy hodin

; *****************************************************************************
;                               CtiSoub
;                    na‡ten¡ souboru MOD do pamˆti
; -----------------------------------------------------------------------------
; VSTUP: DS:DX=jm‚no souboru
;        DS=datov˜ segment
; VSTUP:CY=chyba ‡ten¡, nedostatek pamˆti nebo chybn˜ form t souboru
; -----------------------------------------------------------------------------
; ni‡¡ v¨echny registry kromˆ DS !
; *****************************************************************************

CtiSoub  PROC      NEAR

; ------ standardn¡ nastaven¡ parametr–

         and       byte ptr ds:[Param],not bit1 ; zru¨en¡ p©¡znaku velk‚ho vzorku
         call      SetForm1                 ; nastaven¡ form tu 1 (standardn¡)

; ------ otev©en¡ souboru pro ‡ten¡

         call      OpenFile                 ; otev©en¡ souboru pro ‡ten¡
         jnc       CtiSoub1                 ; soubor otev©en OK
         ret                                ; chyba otev©en¡ souboru

; ------ nastaven¡ ukazatele na identifik tor form tu souboru

CtiSoub1:mov       dx,438h                  ; offset identifik toru souboru
         call      SetUFile                 ; nastaven¡ ukazatele na identifik.
         jc        CtiSoub3                 ; chyba nastaven¡ ukazatele

; ------ na‡ten¡ identifik toru souboru

         mov       dx,offset BuffId         ; buffer identifik toru form tu
         mov       cx,4                     ; po‡et bajt– ke ‡ten¡
         push      ds
         pop       es
         call      ReadFile                 ; na‡ten¡ identifik toru souboru
         jc        CtiSoub3                 ; chyba ‡ten¡

; ------ rozli¨en¡ form tu souboru

         mov       si,dx                    ; buffer s daty
         cmp       word ptr ds:[si],".M"    ; je form t "M." ?
         je        CtiSoub2                 ; je roz¨¡©en˜ form t "M."
         cmp       word ptr ds:[si],"LF"    ; je form t "FLT4" ?
         jne       CtiSoub3                 ; nen¡ form t "FLT4"
         cmp       word ptr ds:[si],"4T"
         jne       CtiSoub3                 ; nen¡ form t 2 "FLT4"
CtiSoub2:call      SetForm2                 ; nastaven¡ form tu 2 (roz¨¡©en˜)

; ------ nastaven¡ ukazatele v souboru na za‡ tek

CtiSoub3:xor       dx,dx
         call      SetUFile                 ; nastaven¡ ukazatele na za‡ tek

; ------ vytvo©en¡ datov‚ho bloku pro z hlav¡ souboru

         mov       ah,48h
         mov       bx,-1
         int       21h                      ; vytvo©en¡ datov‚ho bloku
         mov       ah,48h
         int       21h                      ; vytvo©en¡ datov‚ho bloku
         jc        CtiSoub4
         mov       es,ax                    ; adresa datov‚ho bloku
         mov       bx,ds:[Zahlavi]          ; velikost z hlav¡ souboru
         mov       cx,bx                    ; velikost z hlav¡
         inc       bx                       ; zaokrouhlen¡
         shr       bx,1                     ; p©evod na slova
         call      ModiDat                  ; zmen¨en¡ datov‚ho bloku
         jnc       CtiSoub5                 ; datov˜ blok vytvo©en OK
CtiSoub4:ret
CtiSoub5:mov       ds:[DatBuff],es          ; segment datov‚ho bufferu melodie

;         mov       bx,ds:[Zahlavi]          ; velikost z hlav¡ souboru
;         mov       cx,bx                    ; velikost z hlav¡
;         inc       bx                       ; zaokrouhlen¡
;         shr       bx,1                     ; p©evod na slova
;         call      CreatDat                 ; vytvo©en¡ datov‚ho bloku
;         jnc       CtiSoub5                 ; datov˜ blok vytvo©en OK
;CtiSoub4:ret
;CtiSoub5:mov       ds:[DatBuff],es          ; segment datov‚ho bufferu melodie

; ------ na‡ten¡ z hlav¡ souboru do bufferu

         xor       dx,dx                    ; offset adresy k na‡ten¡ z hlav¡
         call      ReadFile                 ; na‡ten¡ z hlav¡ souboru
         jc        CtiSoub4                 ; chyba ‡ten¡ z hlav¡ souboru

; ------ po‡et sekc¡ melodie

         mov       di,ds:[AdrSekce]         ; adresa tabulky sekc¡ melodie
         mov       al,es:[di-2]             ; d‚lka skladby (po‡et sekc¡)
         mov       ds:[SekceN],al           ; po‡et sekc¡ melodie
         stc
         cmp       al,0                     ; je nˆjak  sekce ?
         je        CtiSoub4                 ; nen¡ nic - chyba

; ------ nalezen¡ ‡¡sla posledn¡ sekce melodie

         mov       cx,127                   ; po‡et sekc¡ melodie
         xor       ax,ax                    ; nejvˆt¨¡ nalezen  sekce
         cld
CtiSoub6:scasb                              ; je vˆt¨¡ sekce ?
         jge       CtiSoub7                 ; nen¡ to vˆt¨¡ sekce
         mov       al,es:[di-1]             ; nov  nejvˆt¨¡ sekce
CtiSoub7:loop      CtiSoub6                 ; test dal¨¡ sekce

; ------ v˜po‡et velikosti melodie

         inc       ax                       ; po‡et sekc¡ melodie
         xchg      ah,al                    ; velikost melodie * 256
         shl       ax,1                     ; velikost melodie ve slovech
         add       bx,ax                    ; nov  velikost dat. bloku (slov)
         shl       ax,1                     ; velikost melodie v bajtech
         mov       cx,ax                    ; velikost melodie v bajtech

; ------ zvˆt¨en¡ datov‚ho bloku (velikost je v BX)

         call      ModiDat                  ; zvˆt¨en¡ datov‚ho bloku
         jc        CtiSoub4                 ; chyba - nedostatek pamˆti

; ------ na‡ten¡ melodie do bufferu

         mov       dx,ds:[Zahlavi]          ; adresa k na‡ten¡ melodie v bufferu
         call      ReadFile                 ; na‡ten¡ melodie do bufferu
         jc        CtiSoub4                 ; chyba ‡ten¡ ze souboru

; ------ p©¡prava k na‡ten¡ vzork– n stroj–

         mov       si,2ah                   ; adresa velikosti prvn¡ho vzorku
         mov       bp,word ptr ds:[Nastroju] ; po‡et n stroj–
         mov       di,offset TabVzor        ; tabulka adres vzork–

; ------ velikost vzorku jednoho n stroje

CtiSoub8:mov       es,ds:[DatBuff]          ; segment datov‚ho bufferu s melodi¡
         mov       cx,es:[si]               ; velikost vzorku n stroje
         xchg      ch,cl                    ; oprava po©ad¡ bajt–
         mov       es:[si],cx               ; opraven  hodnota

; ------ vytvo©en¡ datov‚ho bloku pro vzorek

         jcxz      CtiSoubB                 ; vzorek nen¡ definov n
         mov       bx,cx                    ; velikost vzorku ve slovech
         call      CreatDat                 ; vytvo©en¡ datov‚ho bufferu
         jc        CtiSoubA                 ; chyba - nedostatek pamˆti
         mov       ds:[di],es               ; £schova adresy bufferu

; ------ ‡ten¡ 64 KB, je-li vzorek vˆt¨¡ ne‘ 64 KB

         or        cx,cx                    ; je vzorek vˆt¨¡ ne‘ 64 KB ?
         jns       CtiSoub9                 ; nen¡ vˆt¨¡ ne‘ 64 KB
         mov       cx,8000h                 ; velikost jednoho bloku 32 KB
         xor       dx,dx                    ; adresa k na‡ten¡ dat
         call      ReadFile                 ; ‡ten¡ prvn¡ho bloku 64 KB
;         jc        CtiSoubA                 ; chyba ‡ten¡
         mov       dx,cx                    ; adresa k na‡ten¡ druh‚ho bloku dat
         call      ReadFile                 ; ‡ten¡ druh‚ho bloku 64 KB
;         jc        CtiSoubA                 ; chyba ‡ten¡
         or        byte ptr ds:[Param],bit1 ; p©¡znak velk‚ho souboru
         mov       ax,es                    ; segment adresy
         add       ax,1000h                 ; posun adresy
         mov       es,ax                    ; nov  adresa
         mov       cx,bx                    ; velikost vzorku ve slovech

; ------ ‡ten¡ zbytku dat

CtiSoub9:xor       dx,dx                    ; adresa k na‡ten¡ dat
         shl       cx,1                     ; p©evod slov na bajty
         call      ReadFile                 ; ‡ten¡ bloku dat

         clc

         jnc       CtiSoubB                 ; soubor na‡ten OK
CtiSoubA:ret

; ------ p©¡prava pro dal¨¡ vzorek

CtiSoubB:add       si,1eh                   ; adresa dal¨¡ho n stroje
         inc       di
         inc       di                       ; ukazatel adres buffer–
         dec       bp                       ; ‡¡ta‡ n stroj–
         jnz       CtiSoub8                 ; dal¨¡ n stroj

         clc                                ; p©¡znak operace OK
         ret

CtiSoub  ENDP


; *****************************************************************************
;                             CreatDat
;                      vytvo©en¡ datov‚ho bloku
; -----------------------------------------------------------------------------
; VSTUP: BX=velikost bloku ve slovech
;        DS=datov˜ segment
; VSTUP:ES=segment datov‚ho bloku
;        CY=nedostatek pamˆti
; *****************************************************************************

CreatDat PROC      NEAR

         push      ax
         push      bx

         add       bx,7                     ; zaokrouhlen¡
         shr       bx,1
         shr       bx,1
         shr       bx,1                     ; p©evod na odstavce
         mov       ah,48h
         int       21h                      ; vytvo©en¡ datov‚ho bloku
         mov       es,ax                    ; adresa datov‚ho bloku

         pop       bx
         pop       ax
         ret

CreatDat ENDP

; *****************************************************************************
;                            ModiDat
;                   modifikace datov‚ho bloku
; -----------------------------------------------------------------------------
; VSTUP: BX=nov  velikost datov‚ho bloku ve slovech
;        ES=adresa datov‚ho bloku
; VSTUP:CY=nedostatek pamˆti
; *****************************************************************************

ModiDat0:inc       bx                       ; zaokrouhlen¡
         shr       bx,1                     ; p©evod na slova


ModiDat  PROC      NEAR

         push      ax
         push      bx

         add       bx,7                     ; zaokrouhlen¡
         shr       bx,1
         shr       bx,1
         shr       bx,1                     ; p©evod na odstavce
         mov       ah,4ah
         int       21h                      ; modifikace datov‚ho bloku

         pop       bx
         pop       ax
         ret

ModiDat  ENDP

; *****************************************************************************
;                            DelADat
;              zru¨en¡ v¨ech datov˜ch blok– programu
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
; *****************************************************************************

DelADat  PROC      NEAR

         push      si
         push      cx
         push      es

         mov       es,ds:[DatBuff]          ; datov˜ buffer
         call      DelDat                   ; zru¨en¡ datov‚ho bufferu melodie
         mov       word ptr ds:[DatBuff],0  ; zru¨en¡ adresy bufferu

         mov       si,offset TabVzor        ; tabulka adres vzork– n stroj–
         mov       cx,31                    ; po‡et polo‘ek v tabulce
DelADat1:mov       es,ds:[si]               ; adresa bloku ke zru¨en¡
         call      DelDat                   ; zru¨en¡ datov‚ho bloku
         mov       word ptr ds:[si],0       ; zru¨en¡ adresy bufferu
         inc       si
         inc       si                       ; zv˜¨en¡ ukazatele v tabulce
         loop      DelADat1                 ; dal¨¡ datov˜ blok

         pop       es
         pop       cx
         pop       si
         ret

DelADat  ENDP

; *****************************************************************************
;                           DelDat
;                    zru¨en¡ datov‚ho bloku
; -----------------------------------------------------------------------------
; VSTUP: ES=adresa datov‚ho bloku ke zru¨en¡
; *****************************************************************************

DelDat   PROC      NEAR

         push      ax

         mov       ax,es                    ; adresa datov‚ho bloku
         or        ax,ax                    ; je to platn˜ datov˜ blok ?
         jz        DelDat2                  ; neplatn˜ datov˜ blok

         mov       ah,49h
         int       21h                      ; zru¨en¡ datov‚ho bloku

DelDat2: pop       ax
         ret

DelDat   ENDP

; *****************************************************************************
;                             OpenFile
;                         otev©en¡ souboru
; -----------------------------------------------------------------------------
; VSTUP: DS:DX=jm‚no souboru
; VSTUP:CY=soubor nenalezen
; *****************************************************************************

OpenFile PROC      NEAR

         push      ax

         mov       ax,3d00h
         int       21h                      ; otev©en¡ souboru pro ‡ten¡
         jc        OpenFil2                 ; soubor nenalezen
         mov       ds:[Identif],ax          ; identifik tor souboru

OpenFil2:pop       ax
         ret

OpenFile ENDP

; *****************************************************************************
;                              SetUFile
;                 nastaven¡ ukazatele v souboru (do 64 KB)
; -----------------------------------------------------------------------------
; VSTUP: DX=ukazatel v souboru
;        DS=datov˜ segment
; VSTUP:CY=chyba vystaven¡ ukazatele
; *****************************************************************************

SetUFile PROC      NEAR

         push      ax
         push      bx
         push      cx

         mov       ax,4200h
         xor       cx,cx                    ; vy¨¨¡ slovo
         mov       bx,ds:[Identif]          ; identifik tor souboru
         int       21h                      ; nastaven¡ ukazatele na identifik.

         pop       cx
         pop       bx
         pop       ax
         ret

SetUFile ENDP

; *****************************************************************************
;                            ReadFile
;                     ‡ten¡ dat ze souboru
; -----------------------------------------------------------------------------
; VSTUP: ES:DX=adresa k na‡ten¡ bloku dat ze souboru
;        CX=po‡et bajt– ke ‡ten¡
;        DS=datov˜ segment
; VSTUP:CY=chyba ‡ten¡ nebo nesouhlas¡ po‡et bajt–
; *****************************************************************************

ReadFile PROC      NEAR

         push      ax
         push      bx

         push      ds
         mov       bx,ds:[Identif]          ; idetnifik tor soubrou
         push      es
         pop       ds
         mov       ah,3fh
         int       21h                      ; na‡ten¡ identifik toru souboru
         pop       ds
         jc        ReadFil2                 ; chyba ‡ten¡
         cmp       ax,cx
         je        ReadFil2                 ; po‡et bajt– souhlas¡ OK
         stc                                ; chyba ‡ten¡

ReadFil2:pop       bx
         pop       ax
         ret

ReadFile ENDP

; *****************************************************************************
;                            ClosFile
;                        uzav©en¡ souboru
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
; *****************************************************************************

ClosFile PROC      NEAR

         push      ax
         push      bx

         mov       bx,ds:[Identif]          ; identifik tor souboru
         or        bx,bx                    ; je soubor otev©en ?
         jz        ClosFil2                 ; soubor nen¡ otev©en
         mov       ah,3eh
         int       21h                      ; uzav©en¡ souboru
         mov       word ptr ds:[Identif],0  ; zru¨en¡ p©¡znaku otev©en¡ souboru

ClosFil2:pop       bx
         pop       ax
         ret

ClosFile ENDP

; *****************************************************************************
;                              SetForm1
;         nastaven¡ form tu 1 (standardn¡ form t souboru - 15 n stroj–)
; -----------------------------------------------------------------------------
; *****************************************************************************

SetForm1 PROC      NEAR

         and       byte ptr ds:[Param],not bit0 ; form t souboru 1 (15 n stroj–)
         mov       byte ptr ds:[Nastroju],15    ; po‡et n stroj– = 15
         mov       word ptr ds:[Zahlavi],258h   ; velikost z hlav¡ souboru
         mov       word ptr ds:[AdrSekce],1d8h  ; adresa tabulky sekc¡ melodie
         ret

SetForm1 ENDP

; *****************************************************************************
;                            SetForm2
;         nastaven¡ form tu 2 (roz¨¡©en¡ form t souboru - 31 n stroj–)
; -----------------------------------------------------------------------------
; *****************************************************************************

SetForm2 PROC      NEAR

         or        byte ptr ds:[Param],bit0    ; form t souboru 2 (31 n stroj–)
         mov       byte ptr ds:[Nastroju],31   ; po‡et n stroj– = 31
         mov       word ptr ds:[Zahlavi],43ch  ; velikost z hlav¡ souboru
         mov       word ptr ds:[AdrSekce],3b8h ; adresa tabulky sekc¡ melodie
         ret

SetForm2 ENDP


; *****************************************************************************
;                               Shows
;                       demonstrace za bˆhu programu
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
; *****************************************************************************

Shows    PROC      NEAR

;         cli

         mov       ax,ds:[Takt]
         cmp       ax,ds:[TaktZ]
         jne       Shows1
         jmp       Shows9

Shows1:  mov       ds:[TaktZ],ax

         mov       es,ds:[SegmVRAM]

         cld

         mov       di,ds:[UkladZ]
         mov       word ptr es:[di+138],0
         mov       word ptr es:[di],0

         mov       cx,71
         inc       di
Shows12: and       byte ptr es:[di],0fh
         inc       di
         inc       di
         loop      Shows12

         mov       di,ds:[TaktZ]
         and       di,0f0h
         mov       ax,10
         mul       di
         mov       di,ax
         add       di,4*160
         mov       ds:[UkladZ],di

         mov       al,">"
         mov       ah,12
         stosw
         mov       al," "
         stosw
         mov       al,"<"
         mov       word ptr es:[di+134],ax

         mov       ah,1bh
         mov       al," "
         stosw
         mov       al,179
         stosw
         mov       al," "
         stosw

         mov       al,ds:[Sekce]
         call      DekHex
         mov       al," "
         stosw
         mov       al,byte ptr ds:[Takt+1]
         call      DekHex
         mov       al,byte ptr ds:[Takt]
         call      DekHex

; ------ adresa ukazatele melodie

         push      ds
         push      es
         mov       si,ds:[AdrSekce]         ; adresa sekc¡ melodie
         add       si,word ptr ds:[Sekce]   ; + ‡¡slo aktivn¡ sekce
         mov       es,ds:[DatBuff]          ; adresa datov‚ho bufferu melodie
         mov       ah,es:[si]               ; ‡¡slo sou‡asn‚ sekce melodie
         mov       al,0
         shl       ax,1
         shl       ax,1                     ; p©evod KB na bajty
         add       ax,ds:[Takt]             ; p©i‡ten¡ adresy taktu v sekci
         add       ax,ds:[Zahlavi]          ; p©i‡ten¡ z hlav¡ souboru
         mov       si,ax                    ; adresa melodie v souboru
         mov       ds,ds:[DatBuff]          ; adresa datov‚ho bufferu melodie
         pop       es

         sti

         mov       ax,1b20h
         stosw
         mov       al,179
         stosw
         mov       al," "
         stosw

; ------

         mov       cx,4
Shows3:
         mov       ah,1eh

; ------ ‡¡slo n stroje

         mov       al,ds:[si+2]
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1
         mov       dl,ds:[si]
         and       dl,10h
         or        dl,al
         mov       dh,dl
         mov       al," "
         cmp       dl,10
         jb        Shows312
         mov       al,"1"
         sub       dl,10
Shows312:stosw
         mov       al," "
         cmp       dh,0
         je        Shows313
         mov       al,dl
         add       al,"0"
Shows313:stosw

;         call      DekHex0                  ; ‡¡slo n stroje

;         mov       al," "
;         stosw

; ------ frekvence

;         test      word ptr ds:[si],0ff0fh
;         jnz       Shows32
;         mov       al," "
;         stosw
;         stosw
;         stosw
;         stosw
;         jmp       short Shows33

Shows32: mov       ax,ds:[si]
         xchg      ah,al
         and       ax,0fffh

         push      si
         push      es
         push      di
         push      cx

         push      cs
         pop       es
         mov       di,offset TabTon
         mov       cx,offset(TabTon0-TabTon)/2
         cld
         repne     scasw                    ; nalezen¡ konstanty v tabulce
         jne       Shows321
         dec       di
         dec       di
Shows321:lea       si,[di+TabTon0-TabTon]   ; adresa textu

         pop       cx
         pop       di
         pop       es

         mov       ah,1eh
         cmp       si,offset TabTonX
         jne       Shows323

         pop       si

         mov       al,ds:[si]
         and       al,0fh
         call      DekHex1                  ; dˆlic¡ konstanta
         mov       al,ds:[si+1]
         call      DekHex
         jmp       short Shows324

Shows323:mov       al," "
;         cmp       byte ptr cs:[si],"a"
;         jb        Shows322
;         mov       al,"#"
Shows322:stosw
         mov       al,cs:[si]
         stosw
         mov       al,cs:[si+1]
         stosw
         pop       si

Shows324:
;         mov       al,ds:[si]
;         and       al,0fh
;         call      DekHex                   ; dˆlic¡ konstanta
;         mov       al,ds:[si+1]
;         call      DekHex

; ------ povel

Shows33: mov       al," "
         stosw

         mov       ah,1fh

         test      word ptr ds:[si+2],0ff0fh
         jnz       Shows34
         mov       al," "
;         stosw
         stosw
         stosw
         stosw
         stosw
         jmp       short Shows35

Shows34: mov       bh,0
         mov       bl,ds:[si+2]
         and       bl,0fh
         cmp       bl,10
         jne       Shows342
         test      byte ptr ds:[si+3],0f0h
         jz        Shows342                 ; je dol–
         mov       bl,16
Shows342:
         shl       bl,1

;         mov       al,bl
;         shl       al,1
;         add       bl,al
         add       bx,offset TabPov
         mov       al,cs:[bx]
         stosw
         mov       al,cs:[bx+1]
         stosw
;         mov       al,cs:[bx+2]
;         stosw
         mov       al,ds:[si+3]
         call      DekHex                   ; parametr
Shows35:

Shows43: ;cmp       cl,1
;         je        Shows45
         mov       al," "
;         stosw
         mov       ah,1bh
         stosw
         mov       al,179
         stosw
         mov       al," "
         stosw
         add       si,4
         dec       cx
         jz        Shows45
         jmp       Shows3
Shows45:
         pop       ds

         mov       si,offset DTA+1eh
         mov       cx,15
         xor       di,di
         mov       ah,0fh
         cld
Shows13: lodsb
         cmp       al,0
         jne       Shows14
         dec       si
Shows14: stosw
         loop      Shows13



Shows9:  sti
         ret

Shows    ENDP


DekHex0: cmp       al,0
         jne       DekHex
         mov       al," "
         stosw
         stosw
         ret

DekHex:  push      ax
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1
         call      DekHex1
         pop       ax
DekHex1: and       al,0fh
         cmp       al,10
         jb        DekHex2
         add       al,7
DekHex2: add       al,"0"
         cld
         stosw
         ret


; *****************************************************************************
;                                 DekParm
;                   Dek¢dov n¡ parametr– z p©¡kazov‚ho © dku
; -----------------------------------------------------------------------------
; VSTUP: DS,ES=adresa PSP
; *****************************************************************************

DekParm  PROC      NEAR

         push      ds
         push      es

; ------ p©¡prava registr–

         push      cs
         pop       es
         mov       si,81h
         mov       cl,ds:[si-1]             ; d‚lka parametr–
         mov       ch,0
         cld

; ------ nalezen¡ za‡ tku textu v bufferu

DekParm1:jcxz      DekParm9
         lodsb
         dec       cx
         cmp       al," "
         je        DekParm1
         cmp       al,9
         je        DekParm1
         cmp       al,13
         je        DekParm9

; ------ p©enesen¡ textu do bufferu

         mov       di,offset All
DekParm2:stosb
         jcxz      DekParm3
         lodsb
         dec       cx
         cmp       al," "
         je        DekParm3
         cmp       al,9
         je        DekParm3
         cmp       al,13
         jne       DekParm2

; ------ ozna‡en¡ konce jm‚na souboru

DekParm3:mov       al,0
         stosb
         or        byte ptr cs:[Param2],bit0 ; p©¡znak zad n¡ jm‚na souboru

DekParm9:pop       es
         pop       ds
         ret

DekParm  ENDP

; *****************************************************************************
;
;                            Data
;
; *****************************************************************************

TabPov   label     byte                   ;* tabulka povel–
         db        'AR' ;'ARP'                    ; 0:
         db        'T/' ;'PR^'                    ; 1: t¢n nahoru
         db        'T\' ;'PRv'                    ; 2: t¢n dol–
         db        'T!' ;'TON'                    ; 3: £schova t¢nu
         db        'T~' ;'VIB'                    ; 4: tremolo
         db        '?5' ;'??5'                    ; 5:
         db        '?6' ;'??6'                    ; 6:
         db        '?7' ;'??7'                    ; 7:
         db        '?8' ;'??8'                    ; 8:
         db        '?9' ;'??9'                    ; 9:
         db        'V\' ;'VLs'                    ; 10: zmˆna hlasitosti (dol–)
         db        'JP' ;'JMP'                    ; 11: skok na danou sekci melodie
         db        'V=' ;'VL='                    ; 12: nastaven¡ hlasitosti absolutnˆ
         db        'BR' ;'BRK'                    ; 13: p©eru¨en¡ jedn‚ sekce melodie
         db        'FT' ;'FTR'                    ; 14:
         db        'S=' ;'Sd='                    ; 15: nastaven¡ rychlosti hry
         db        'V/'                           ; (10: zmˆna hlasitosti (nahoru)

TabTon   label     byte                     ; tabulka t¢n–
         dw        0                        ; '  '

         dw        358h                     ; 'C1'
         dw        328h                     ; 'c1'
         dw        2fah                     ; 'D1'
         dw        2d0h                     ; 'd1'
         dw        2a6h                     ; 'E1'
         dw        280h                     ; 'e1'
         dw        25ch                     ; 'F1'
         dw        23ah                     ; 'f1'
         dw        21ah                     ; 'A1'
         dw        1fch                     ; 'a1'
         dw        1e0h                     ; 'B1'
         dw        1c5h                     ; 'b1'

         dw        1ach                     ; 'C2'
         dw        194h                     ; 'c2'
         dw        17dh                     ; 'D2'
         dw        168h                     ; 'd2'
         dw        153h                     ; 'E2'
         dw        140h                     ; 'e2'
         dw        12eh                     ; 'F2'
         dw        11dh                     ; 'f2'
         dw        10dh                     ; 'A2'
         dw        0feh                     ; 'a2'
         dw        0f0h                     ; 'B2'
         dw        0e2h                     ; 'b2'

         dw        0d6h                     ; 'C3'
         dw        0cah                     ; 'c3'
         dw        0beh                     ; 'D3'
         dw        0b4h                     ; 'd3'
         dw        0aah                     ; 'E3'
         dw        0a0h                     ; 'e3'
         dw        97h                      ; 'F3'
         dw        8fh                      ; 'f3'
         dw        87h                      ; 'A3'
         dw        7fh                      ; 'a3'
         dw        78h                      ; 'B3'
         dw        71h                      ; 'b3'

TabTon0  label     byte
         db        '  '

         db        'C1';'C1'
         db        'c1';'c1'
         db        'D1';'D1'
         db        'd1';'d1'
         db        'E1';'E1'
         db        'F1';'e1'
         db        'f1';'F1'
         db        'G1';'f1'
         db        'g1';'A1'
         db        'A1';'a1'
         db        'a1';'B1'
         db        'H1';'b1'
                       ;
         db        'C2';'C2'
         db        'c2';'c2'
         db        'D2';'D2'
         db        'd2';'d2'
         db        'E2';'E2'
         db        'F2';'e2'
         db        'f2';'F2'
         db        'G2';'f2'
         db        'g2';'A2'
         db        'A2';'a2'
         db        'a2';'B2'
         db        'H2';'b2'
                       ;
         db        'C3';'C3'
         db        'c3';'c3'
         db        'D3';'D3'
         db        'd3';'d3'
         db        'E3';'E3'
         db        'F3';'e3'
         db        'f3';'F3'
         db        'G3';'f3'
         db        'g3';'A3'
         db        'A3';'a3'
         db        'a3';'B3'
         db        'H3';'b3'

TabTonX  db        '??'

; ------ tabulka pro logaritmizaci v˜stupu na reproduktor

TabLog   label     near
db       32,31,30,29,28,27,26,25,24,23,22,21,20,19,18,17
db       17,16,16,15,15,14,14,13,13,13,12,12,12,12,11,11
db       11,11,10,10,10,10,10,9,9,9,9,9,9,9,9,9
db       8,8,8,8,8,8,8,8,8,8,8,8,7,7,7,7
db       7,7,7,6,6,6,6,6,6,6,6,6,6,6,5,5
db       5,5,5,5,5,5,5,5,4,4,4,4,4,4,4,4
db       4,4,3,3,3,3,3,3,3,3,3,3,2,2,2,2
db       2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,1
db       64,64,64,64,64,64,64,64,64,64,63,63,63,63,63,63
db       63,63,63,63,63,63,62,62,62,62,62,62,62,62,62,62
db       61,61,61,61,61,61,61,61,61,60,60,60,60,60,60,60
db       60,60,60,59,59,59,59,59,59,59,59,59,59,58,58,58
db       58,58,58,58,58,58,58,57,57,57,57,57,57,57,57,57
db       57,56,56,56,56,56,56,56,56,55,55,55,55,55,54,54
db       54,54,53,53,53,53,52,52,52,51,51,50,50,49,49,48
db       48,47,46,45,44,43,42,41,40,39,38,37,36,35,34,33

; ------ tabulka SIN pro tremolo

TabSin   label     byte
         db        0,18h,31h,4ah,61h,78h,8dh,0a1h
         db        0b4h,0c5h,0d4h,0e0h,0ebh,0f4h,0fah,0fdh
         db        0ffh,0fdh,0fah,0f4h,0ebh,0e0h,0d4h,0c5h
         db        0b4h,0a1h,8dh,78h,61h,4ah,31h,18h

SegmVRAM dw        0b800h                   ; segment videopamˆti
Old09    dd        0                        ; p–vodn¡ obsluha INT 09h
Old08    dd        0                        ; p–vodn¡ obsluha INT 08h
OldMask  db        0                        ; p–vodn¡ maska p©eru¨en¡

Param    db        0                        ; parametry
                                            ;   bit 0: 1=je form t 2 souboru
                                            ;   bit 1: 1=je velk˜ soubor
                                            ;   bit 2: 1=p©eru¨en¡ kl vesou
                                            ;   bit 3: 1=ukon‡en¡ hry skladby
                                            ;   bit 4: 1=prob¡h  obsluha INT 08h
                                            ;   bit 5: 1=opakov n¡ skladby
                                            ;   bit 6: 1=p©eru¨en¡ sekce skladby
                                            ;   bit 7: 1=pozastaven¡ hry

Param2   db        0                        ; parametry 2
                                            ;   bit 0: 1=byl zad n soubor
                                            ;   bit 1: 1=hodiny byly cejchov ny
                                            ;   bit 2: 1=obsluha posunu melodie
                                            ;   bit 3: 1=obsluha sn¡‘en¡ hodin
                                            ;   bit 4: 1=obsluha INT 09h

Identif  dw        0                        ; identifik tor souboru
TabVzor  dw        31 dup(0)                ; tabulka adres vzork–
DatBuff  dw        0                        ; segment datov‚ho bufferu melodie

Frekv08  dw        15000                    ; frekvence hodin INT 08h
Konst08  db        70                       ; dˆlic¡ konstanta hodin INT 08h
RefFrek  dd        3000h                    ; konstanta pro v˜po‡et frekvence

; ------ obsluha ‡¡t n¡ impuls– v jednom kroku

CitImp   dw        0                        ; ‡¡ta‡ impuls– v jednom kroku
Impulsu  dw        0                        ; po‡et hodin. impuls– na krok

; ------ obsluha ‡¡t n¡ krok– v jednom taktu

KrokSek  dw        33h                      ; po‡et krok– za sekundu
CitKrok  db        0                        ; ‡¡ta‡ krok– v jednom taktu
Rychlost db        6                        ; rychlost hry (po‡et krok– na takt)

; ------ obsluha ‡¡t n¡ takt– v sekci a ‡¡t n¡ sekc¡

Takt     dw        0                        ; ukazatel taktu v sekci
Sekce    db        0                        ; ukazatel ‡¡sla sekce
         db        0                        ; zarovn n¡ na slovo
SekceN   db        0                        ; celkov˜ po‡et sekc¡ melodie


TaktZ    dw        0                        ; zobrazen˜ takt
UkladZ   dw        0                        ; ukl dac¡ adresa do videopamˆti

Nastroju db        15                       ; po‡et n stroj–
         db        0                        ; zarovn n¡ na slovo

; ------ defini‡n¡ konstanty souboru

Zahlavi  dw        258h                     ; velikost z hlav¡ souboru
AdrSekce dw        1d8h                     ; adresa sekc¡ melodie

; ------ texty

NoFile   db        'V aktivnim adresari nenalezen zadny soubor *.MOD !',13,10,'$'

All      db        '*.MOD',0                ; specifikace soubor–
         db        128 dup(?)               ; buffer pro £schovu specifikace

; ------ buffery

         EVEN
TabKanal db        4*KanSize dup(?)         ; tabulka definic kan l–
BuffId   db        4 dup(?)                 ; buffer identifik toru form tu

DTA      db        44 dup(?)                ; buffer DTA pro hled n¡ soubor–

Code     ENDS

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                            Z sobn¡k
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

Zasobnik SEGMENT   STACK

         dw        2000h dup(?)

Zasobnik ENDS

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                           Segment konce programu
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

KonSeg   SEGMENT

KonSeg   ENDS

         END       Start


; *****************************************************************************
;
;                              U N L Z E X E
;
;                  dekomprese programu - odstranˆn¡ nadstaveb
;
; *****************************************************************************

BuffSize EQU       6000h                    ; velikost bufferu
InpBuff  EQU       offset(Konec-Start)+100h
OutBuff  EQU       InpBuff+BuffSize


code     SEGMENT
         ASSUME    cs:code,ds:code
         ORG       100h
Start:

; ------ kontrola pamˆti

         mov       ax,sp
         cmp       ax,OutBuff+BuffSize+400h
         jb        ChybaCh                  ; nedostatek pamˆti


         mov       dx,offset UvTxt
         mov       ah,9
         int       21h

; ------ otev©en¡ zdrojov‚ho souboru

         mov       ax,3d00h
         mov       dx,offset soubor1
         int       21h
         jc        ChybaCh
         mov       ds:[Ident1],ax

; ------ vytvo©en¡ c¡lov‚ho souboru

         mov       ah,3ch
         mov       dx,offset soubor2
         xor       cx,cx
         int       21h
         jc        ChybaCh
         mov       ds:[Ident2],ax

; ------ na‡ten¡ z hlav¡

         mov       dx,offset zahlavi
         mov       cx,32
         mov       ah,3fh
         mov       bx,ds:[Ident1]
         int       21h
         jc        ChybaCh
         cmp       ax,cx
         je        Start3

ChybaCh: jmp       Chyba

; ------ ulo‘en¡ z hlav¡ do nov‚ho souboru

Start3:  mov       dx,offset zahlavi
         mov       ah,40h
         mov       bx,ds:[Ident2]
         mov       cx,1ch
         int       21h
         jc        ChybaCh

; ------ nastaven¡ ukazatele na £vodn¡ ‡ st programu

         mov       ax,ds:[RegCS]
         add       ax,ds:[HeadSize]         ; p©i‡ten¡ velikosti z hlav¡
         mov       cx,16
         mul       cx                       ; p©epo‡et segmentu na bajty
;         add       ax,ds:[RegIP]            ; p©i‡ten¡ offsetov‚ ‡ sti
;         adc       dx,0
         mov       cx,dx
         mov       dx,ax
         mov       ax,4200h
         mov       bx,ds:[Ident1]
         int       21h                      ; nastaven¡ ukazatele
         jc        ChybaCh

; ------ na‡ten¡ dek¢dovac¡ho programu

         call      InpRead                  ; p©e‡ten¡ ‡ sti programu

; ------ odstranˆn¡ nadstavby LZEXE

         call      TestLZEX
         jc        ChybaCh
         jne       Prog2

         mov       dx,offset LZEXETxt
         mov       ah,9
         int       21h

         call      DepLZEX
         jc        Chyba
         call      OutWrite

         jmp       short UlozHead



Prog2:


         mov       dx,offset NicTxt
         mov       ah,9
         int       21h
         jmp       short Navrat

UlozHead:
; ------ inicializace velikosti programu

         xor       cx,cx
         xor       dx,dx
         mov       ax,4202h
         mov       bx,ds:[Ident2]
         int       21h
         jc        Chyba
         mov       cx,ax
         and       cx,1ffh
         mov       ds:[delka0],cx
         add       ax,511
         adc       dx,0
         mov       cx,512
         div       cx
         mov       ds:[delka],ax

; ------ ulo‘en¡ z hlav¡ do nov‚ho souboru

         xor       cx,cx
         xor       dx,dx
         mov       ax,4200h
         int       21h                      ; nastaven¡ ukazatele
         jc        Chyba

         mov       dx,offset zahlavi
         mov       ah,40h
         mov       cx,1ch
         int       21h
         jnc       Navrat

Chyba:   mov       dx,offset ErrTxt
         mov       ah,9
         int       21h
Navrat:  mov       ax,4c00h
         int       21h






; *****************************************************************************
;
;                            LZEXE V0.91
;
; *****************************************************************************

; -----------------------------------------------------------------------------
;        kontrola, zda je program LZEXE
; -----------------------------------------------------------------------------

TestLZEX PROC      NEAR

         cmp       word ptr ds:[RegIP],offset(LZVStart-LZEXVzor)
         jne       TestLZX8                 ; nen¡ to program LZEXE

         cmp       word ptr ds:[Num1],offset(LZVRelTb-LZEXVzor) ; minim. vel.
         jbe       TestLZX8                 ; nen¡ LZEXE

         mov       si,InpBuff+offset(LZVStart-LZEXVzor)
         mov       di,offset LZVStart
         mov       cx,offset(LZVRelTb-LZVStart)
         cld
         repe      cmpsb                    ; porovn n¡ programu
         jne       TestLZX8                 ; nen¡ LZEXE

; ------ je LZEXE

TestLZX7:xor       ax,ax
         ret

; ------ nen¡ LZEXE

TestLZX8:xor       ax,ax
         inc       ax

; ------ chyba operace

TestLZX9:ret

TestLZEX ENDP

; -----------------------------------------------------------------------------
;        odstranˆn¡ nadstavby LZEXE
; -----------------------------------------------------------------------------

DepLZEX  PROC      NEAR

; ------ £schova parametr– ze z hlav¡

         mov       si,InpBuff
         mov       ax,ds:[si+LZVRegIP-LZEXVzor]
         mov       ds:[RegIP],ax
         mov       ax,ds:[si+LZVRegCS-LZEXVzor]
         mov       ds:[RegCS],ax
         mov       ax,ds:[si+LZVRegSP-LZEXVzor]
         mov       ds:[RegSP],ax
         mov       ax,ds:[si+LZVRegSS-LZEXVzor]
         mov       ds:[RegSS],ax

; ------ vytvo©en¡ reloka‡n¡ tabulky

         sub       word ptr ds:[minim],offset(LZVRelTb-LZEXVzor)-195
         sub       word ptr ds:[maxim],offset(LZVRelTb-LZEXVzor)-195
         mov       word ptr ds:[nrelok],0   ; nen¡ ‘ dn  polo‘ka relok. tabulky
         mov       word ptr ds:[relok1],1ch
         mov       si,InpBuff+offset(LZVRelTb-LZEXVzor) ; reloka‡n¡ tabulka
         mov       di,OutBuff+BuffSize/2
         sub       word ptr ds:[Num1],offset(LZVRelTb-LZEXVzor) ; zmen¨en¡ dat

         xor       dx,dx                    ; segment adresy
         xor       bx,bx                    ; offset adresy


DepLZEX1:call      InpByte                  ; vstup bajtu
         dec       word ptr ds:[Minim]
         dec       word ptr ds:[Maxim]
         or        al,al                    ; zmˆna adresy slovem ?
         jz        DepLZEX4                 ; zmˆna adresy slovem

         mov       ah,0
DepLZEX2:add       bx,ax                    ; zv˜¨en¡ offsetu programu

         mov       ax,bx                    ; offset adresy
         and       bx,0fh                   ; zbytek v paragrafu
         mov       cl,4                     ; po‡et rotac¡ pro p©evod
         shr       ax,cl                    ; p©evod adresy na segment
         add       dx,ax                    ; p©enos do segmentu

DepLZEX3:mov       ax,bx
         call      OutWord
         mov       ax,dx
         call      OutWord
         inc       word ptr ds:[nrelok]     ; zv˜¨en¡ ‡¡ta‡e relok. polo‘ek
         jmp       short DepLZEX1           ; dal¨¡ polo‘ka

DepLZEX4:call      InpWord
         dec       word ptr ds:[Minim]
         dec       word ptr ds:[Maxim]
         dec       word ptr ds:[Minim]
         dec       word ptr ds:[Maxim]
         or        ax,ax
         jnz       DepLZEX5
         add       dx,0fffh
         jmp       short DepLZEX1

DepLZEX5:cmp       ax,1
         jne       DepLZEX2

         mov       ax,4
         mul       word ptr ds:[nrelok]     ; d‚lka reloka‡n¡ tabulky
         add       ax,1ch                   ; p©i‡ten¡ z hlav¡
         mov       cx,ax                    ;
         add       ax,0fh                   ; zaokrouhlen¡ nahoru
         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; velikost z hlav¡ v odstavc¡ch
         mov       dx,ds:[HeadSize]         ; star  velikost z hlav¡
         mov       ds:[headsize],ax         ; velikost z hlav¡
         and       cx,0fh                   ; zbytek v odstavci 16 B
         jcxz      DepLZEX7                 ; nic nezbylo
DepLZEX6:xor       al,al
         call      OutByte
         inc       cx
         cmp       cl,10h
         jne       DepLZEX6
DepLZEX7:

; ------ nastaven¡ ukazatele na za‡ tek programu

         xor       cx,cx
         shl       dx,1
         rcl       cx,1
         shl       dx,1
         rcl       cx,1
         shl       dx,1
         rcl       cx,1
         shl       dx,1
         rcl       cx,1
         mov       bx,ds:[Ident1]
         mov       ax,4200h
         int       21h
         mov       word ptr ds:[Num1],0

; ------ dekomprese programu

         mov       dx,16                    ; ‡¡ta‡ k ‡¡t n¡ bit– slova p©¡znak–
         call      InpWord                  ; na‡ten¡ prvn¡ho slova p©¡znak–
         mov       bp,ax                    ; slovo p©¡znak–

; ------- p©¡pad p©enesen¡ bajtu beze zmˆny (stav 1, 8b dat)

DekLZEX1:call      DekLZEXI                 ; test bitu p©¡znak–
         jnc       DekLZEX2                 ; nen¡ jednoduch˜ p©enos bajtu dat
         call      InpByte                  ; ‡ten¡ bajtu
         call      OutByte                  ; z pis bajtu dat
         jmp       short DekLZEX1           ; dal¨¡ data

; ------- rozli¨en¡ typu opakov n¡ ©etˆzce

DekLZEX2:xor       cx,cx                    ; CX <- 0
         call      DekLZEXI                 ; test bitu p©¡znak–
         jc        DekLZEX3                 ; je opakov n¡ dlouh‚ho ©etˆzce

; ------- p©¡pad opakov n¡ ©etˆzce 2 a‘ 5 bajt– (stav 00 + 2b d‚lka, 8b offset)

         call      DekLZEXI                 ; ‡ten¡ bitu p©¡znak–
         rcl       cx,1                     ; p©enesen¡ bitu do CX
         call      DekLZEXI                 ; ‡ten¡ bitu p©¡znak–
         rcl       cx,1                     ; p©enesen¡ bitu do CX
         inc       cx
         inc       cx
         call      InpByte                  ; offset ©etˆzce k opakov n¡
         mov       bh,0ffh                  ; vy¨¨¡ bajt offsetu
         mov       bl,al                    ; ni‘¨¡ bajt offsetu (= -256 a‘ -1)
         jmp       short DekLZEX4           ; opakov n¡ ©etˆzce

; ------- p©¡pad opakov n¡ ©etˆzce 3 a‘ 9 bajt– (stav 01, 3b d‚lka + 13b offset)

DekLZEX3:call      InpWord                  ; offset a d‚lka opakovan‚ho ©etˆzce
         mov       bx,ax                    ; offset a d‚lka opakovan‚ho ©etˆzce
         mov       cl,3                     ; po‡et rotac¡ pro p©evod
         shr       bh,cl                    ; adresa je v bitech 11 a‘ 15
         or        bh,0e0h                  ; buffer je posunu o 8 KB dol–
         and       ah,7                     ; po‡et bajt– ©etˆzce - 2
         jz        DekLZEX5                 ; d‚lka ©etˆzce bude v dal¨¡m bajtu
         mov       cl,ah                    ; po‡et bajt– ©etˆzce - 2
         inc       cx
         inc       cx                       ; po‡et bajt– = 3 a‘ 9
DekLZEX4:mov       al,es:[bx+di]            ; bajt z ji‘ existuj¡c¡ho ©etˆzce
         call      OutByte                  ; ulo‘en¡ nov‚ho bajtu dat
         loop      DekLZEX4                 ; p©enos dal¨¡ho bajtu dat
         jmp       short DekLZEX1           ; dal¨¡ data programu

; ------- opakov n¡ ©etˆzce 3 a‘ 256 bajt– (stav 01, 3b=0 + 8b d‚lka + 13b off.)

DekLZEX5:call      InpByte                  ; na‡ten¡ dal¨¡ho bajtu dat
         or        al,al                    ; je konec dat ?
         jz        DekLZEX6                 ; je konec dat
         cmp       al,1                     ; je normalizace adres ukazatel– ?
         je        DekLZEX1                 ; je normalizace adres ukazatel–
         mov       cl,al                    ; d‚lka ©etˆzce - 1
         inc       cx                       ; d‚lka ©etˆzce k p©esunu 3 a‘ 256
         jmp       short DekLZEX4           ; p©esun ji‘ existuj¡c¡ho ©etˆzce

DekLZEX6:


         clc
         ret

DepLZEX  ENDP

DekLZEXI PROC      NEAR

         shr       bp,1                     ; rotace slova p©¡znak–
         dec       dx                       ; sn¡‘en¡ ‡¡ta‡e bit– p©¡znak–
         jnz       DekLZEXX                 ; nejsou je¨tˆ v¨echny bity p©¡znak–
         pushf
         call      InpWord                  ; na‡ten¡ dal¨¡ho slova p©¡znak–
         popf
         mov       bp,ax                    ; slovo p©¡znak–
         mov       dl,16                    ; nov˜ ‡¡ta‡ bit– p©¡znak–
DekLZEXX:ret

DekLZEXI ENDP

; -----------------------------------------------------------------------------
;        vzorek LZEXE V 0.91
; -----------------------------------------------------------------------------

LZEXVzor label     byte

; -----------------------------------------------------------------------------
;        tabulka parametr–
; -----------------------------------------------------------------------------

LZVRegIP dw        0                        ; (0) p–vodn¡ adresa IP
LZVRegCS dw        0                        ; (2) p–vodn¡ adresa CS
LZVRegSP dw        0                        ; (4) p–vodn¡ adresa SP
LZVRegSS dw        0                        ; (6) p–vodn¡ adresa SS
LZVDelka dw        0                        ; (8) d‚lka zkompr. progr. (odstav.)
LZVPosun dw        0                        ; (0ah) posun dek. nahoru (odstavce)
LZVDelDk dw        0                        ; (0ch) d‚lka dekod‚ru s tabulkou

; -----------------------------------------------------------------------------
;        p©esun dekod‚ru za nov˜ konec programu
; -----------------------------------------------------------------------------

LZVStart PROC      FAR                      ; start programu dekod‚ru

         push      es                       ; £shova segmentu PSP
         push      cs
         pop       ds                       ; DS <- CS
         mov       cx,ds:[LZVDelDk-LZEXVzor]; d‚lka dekod‚ru s relok. tabulkou
         mov       si,cx                    ; konec programu
         dec       si                       ; posledn¡ bajt programu s tabul.
;         mov       di,si                    ; posledn¡ bajt programu
         db        89h,0f7h
         mov       bx,ds                    ; BX <- CS
         add       bx,ds:[LZVPosun-LZEXVzor]; nov  adresa dekod‚ru
         mov       es,bx                    ; c¡lov˜ segment
         std                                ; smˆr dol–
         rep       movsb                    ; odsun dekod‚ru nahoru
         push      bx                       ; c¡lov˜ segment
         mov       ax,offset(LZVStrt1-LZEXVzor) ; offset adresy pokra‡ov n¡
         push      ax                       ; offset adresy pokra‡ov n¡
         ret                                ; skok FAR do kopie dekod‚ru

LZVStart ENDP

; -----------------------------------------------------------------------------
;        p©esun zkomprimovan‚ho programu nahoru ke sv‚mu nov‚mu konci
; -----------------------------------------------------------------------------

LZVStrt1:mov       bp,cs:[LZVDelka-LZEXVzor]; d‚lka zkomprimovan‚ho programu
         mov       dx,ds                    ; DX <- DS p–vodn¡ segment CS

LZVStrt2:;mov       ax,bp                    ; d‚lka zkomprimovan‚ho programu
         db        89h,0e8h
         cmp       ax,1000h                 ; je d‚lka vˆt¨¡ ne‘ 64 KB ?
         jbe       LZVStrt3                 ; d‚lka nen¡ vˆt¨¡ ne‘ 64 KB
         mov       ax,1000h                 ; omezen¡ d‚lky na 64 KB

LZVStrt3:;sub       bp,ax                    ; sn¡‘en¡ celkov‚ velikosti
         db        29h,0c5h
         ;sub       dx,ax                    ; sn¡‘en¡ zdrojov‚ adresy
         db        29h,0c2h
         ;sub       bx,ax                    ; sn¡‘en¡ c¡lov‚ adresy
         db        29h,0c3h
         mov       ds,dx                    ; zdrojov  adresa
         mov       es,bx                    ; c¡lov  adresa
         mov       cl,3                     ; po‡et rotac¡ pro p©evod na slova
         shl       ax,cl                    ; p©evod na slova
         ;mov       cx,ax                    ; po‡et slov k p©esunu
         db        89h,0c1h
         shl       ax,1                     ; d‚lka v bajtech
         dec       ax                       ; posledn¡ bajt
         dec       ax                       ; posledn¡ slovo
         mov       si,ax                    ; konec zdrojov‚ adresy
         mov       di,ax                    ; konec c¡lov‚ adresy
         rep       movsw                    ; p©enos ‡ sti programu
         ;or        bp,bp                    ; jsou je¨tˆ nˆjak  data k p©esunu ?
         db        9,0edh
         jnz       LZVStrt2                 ; jsou je¨tˆ data - dal¨¡ p©esun

; -----------------------------------------------------------------------------
;        dekomprese programu
; -----------------------------------------------------------------------------

; Struktura:
;  -  zkomprimovan  data jsou prokl d na p©¡znakov˜mi slovy - pokud se nast© d 
;     v¨ech 16 bit– p©¡znakov‚ho slova, slovo se ulo‘¡ do dat a st© d  se dal¨¡
;     slovo. Prvn¡m slovem dat je p©¡znakov‚ slovo.
;                                          ÚÄÄÄÂÄÄÄ¿
;                                          ³ 0   1 ³
;                                          ÀÄÂÄÁÄÂÄÙ
;                             ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;                         ÚÄÄÄÅÄÄÄ¿                              (1 Bajt)
;                         ³ 0   1 ³                        ÚÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ¿
;                         ÀÄÂÄÁÄÂÄÙ                        ³ 1 bajt se p©enese ³
;               ÚÄÄÄÄÄÄÄÄÄÄÄÙ   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿   ³     beze zmˆny    ³
;           ÚÄÄÄÅÄÄÄ¿                                  ³   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;           ³ x   x ³                                  ³
;           ÀÄÄÄÅÄÄÄÙ                                  ³
;           (1 Bajt)                        ÚÄÄÄÄÄÄ(2 Bajty)ÄÄÄÄÄÄÄÄ¿
; ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿           ³          ÚÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ¿
; ³      opakov n¡ ©etˆzce      ³    bity 8 a‘ 10 = 0  ³  opakov n¡ ©etˆzce    ³
; ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´           ³          ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
; ³   2 bity p©¡znak– ud vaj¡   ³           ³          ³ bity 0 - 7 a 11 - 15  ³
; ³ d‚lku ©etˆzce 2 a‘ 5 bajt–, ³           ³          ³ ud vaj¡ offset ©etˆzce³
; ³ 1 bajt z dat ud v  offset   ³           ³          ³  od ukl dac¡ adresy   ³
; ³    od ukl dac¡ adresy       ³           ³          ³-8192(=0) a‘ -1(=1fff),³
; ³  -256 (=0) a‘ -1 (=0ffh)    ³           ³          ³ bity 8 a‘ 10 ud vaj¡  ³
; ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ           ³          ³  d‚lku 3 (=1) a‘ 9 B  ³
;                                           ³          ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;             ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ(1 Bajt)ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;         bajt = 0                          ³          ÚÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ¿
;             ³                   ÚÄÄÄÄÄÄÄÄÄÙ          ³  opakov n¡ ©etˆzce    ³
;             ³              bajt = 1                  ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
;             ³        ÚÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿     ³ bity 0 - 7 a 11 - 15  ³
;             ³        ³   normalizace zdrojov‚  ³     ³  p©ede¨l‚ho datov‚ho  ³
;             ³        ³  a c¡lov‚ adresy        ³     ³  slova ud vaj¡ offset ³
;             ³        ³  dekomprese dat         ³     ³  ©etˆzce od ukl dac¡  ³
;             ³        ³ - c¡lov  se normalizuje ³     ³ adresy -8192 (=0) a‘  ³
;             ³        ³  na offset minim lnˆ    ³     ³ -1 (=1fffh), dal¨¡    ³
;             ³        ³   2000h (rezerva pro    ³     ³datov˜ bajt ud v  d‚lku³
;             ³        ³      buffer 8 KB)       ³     ³ 3 (=2) a‘ 256 (=0ffh) ³
;             ³        ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ     ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;       konec dekomprese

         cld                                ; smˆr nahoru
         mov       es,dx                    ; segment za‡ tku k ulo‘en¡ programu
         mov       ds,bx                    ; segment za‡ tku star‚ho programu
         ;xor       si,si                    ; za‡ tek adresy star‚ho programu
         db        31h,0f6h
         ;xor       di,di                    ; za‡ tek k ulo‘en¡ programu
         db        31h,0ffh
         mov       dx,16                    ; ‡¡ta‡ k ‡¡t n¡ bit– slova p©¡znak–
         lodsw                              ; na‡ten¡ prvn¡ho slova p©¡znak–
         ;mov       bp,ax                    ; slovo p©¡znak–
         db        89h,0c5h

; ------- p©¡pad p©enesen¡ bajtu beze zmˆny (stav 1, 8b dat)

LZVStrt4:shr       bp,1                     ; rotace slova p©¡znak–
         dec       dx                       ; sn¡‘en¡ ‡¡ta‡e bit– p©¡znak–
         jnz       LZVStrt5                 ; nejsou je¨tˆ v¨echny bity p©¡znak–
         lodsw                              ; na‡ten¡ dal¨¡ho slova p©¡znak–
         ;mov       bp,ax                    ; slovo p©¡znak–
         db        89h,0c5h
         mov       dl,16                    ; nov˜ ‡¡ta‡ bit– p©¡znak–
LZVStrt5:jnc       LZVStrt6                 ; nen¡ jednoduch˜ p©enos bajtu dat
         movsb                              ; p©enos jednoho bajtu dat
         jmp       short LZVStrt4           ; dal¨¡ data programu

; ------- rozli¨en¡ typu opakov n¡ ©etˆzce

LZVStrt6:;xor       cx,cx                    ; CX <- 0
         db        31h,0c9h
         shr       bp,1                     ; rotace dal¨¡ho p©¡znaku
         dec       dx                       ; sn¡‘en¡ ‡¡ta‡e bit– p©¡znak–
         jnz       LZVStrt7                 ; nejsou je¨tˆ v¨echny bity p©¡znak–
         lodsw                              ; na‡ten¡ dal¨¡ho slova p©¡znak–
         ;mov       bp,ax                    ; dal¨¡ slovo p©¡znak–
         db        89h,0c5h
         mov       dl,16                    ; nov˜ ‡¡ta‡ bit– p©¡znak–
LZVStrt7:jc        LZVStrtA                 ; je opakov n¡ dlouh‚ho ©etˆzce

; ------- p©¡pad opakov n¡ ©etˆzce 2 a‘ 5 bajt– (stav 00 + 2b d‚lka, 8b offset)

         shr       bp,1                     ; rotace dal¨¡ho bitu p©¡znak–
         dec       dx                       ; sn¡‘en¡ ‡¡ta‡e bit– p©¡znak–
         jnz       LZVStrt8                 ; nejsou je¨tˆ v¨echny bity p©¡znak–
         lodsw                              ; na‡ten¡ dal¨¡ho slova p©¡znak–
         ;mov       bp,ax                    ; dal¨¡ slovo p©¡znak–
         db        89h,0c5h
         mov       dl,16                    ; nov˜ ‡¡ta‡ bit– slova p©¡znak–
LZVStrt8:rcl       cx,1                     ; p©enesen¡ bitu do CX
         shr       bp,1                     ; rotace dal¨¡ho bitu p©¡znak–
         dec       dx                       ; sn¡‘en¡ ‡¡ta‡e bit– p©¡znak–
         jnz       LZVStrt9                 ; nejsou je¨tˆ v¨echny bity p©¡znak–
         lodsw                              ; na‡ten¡ dal¨¡ho slova p©¡znak–
         ;mov       bp,ax                    ; dal¨¡ slovo p©¡znak–
         db        89h,0c5h
         mov       dl,16                    ; nov˜ ‡¡ta‡ bit– slova p©¡znak–
LZVStrt9:rcl       cx,1                     ; p©enesen¡ bitu do CX
         inc       cx
         inc       cx                       ; po‡et bajt– = 2 a‘ 5
         lodsb                              ; offset ©etˆzce k opakov n¡
         mov       bh,0ffh                  ; vy¨¨¡ bajt offsetu
         mov       bl,al                    ; ni‘¨¡ bajt offsetu (= -256 a‘ -1)
         ;jmp       LZVStrtB                 ; opakov n¡ ©etˆzce
         db        0e9h,13h,0

; ------- p©¡pad opakov n¡ ©etˆzce 3 a‘ 9 bajt– (stav 01, 3b d‚lka + 13b offset)

LZVStrtA:lodsw                              ; offset a d‚lka opakovan‚ho ©etˆzce
         mov       bx,ax                    ; offset a d‚lka opakovan‚ho ©etˆzce
         mov       cl,3                     ; po‡et rotac¡ pro p©evod
         shr       bh,cl                    ; adresa je v bitech 11 a‘ 15
         or        bh,0e0h                  ; buffer je posunu o 8 KB dol–
         and       ah,7                     ; po‡et bajt– ©etˆzce - 2
         jz        LZVStrtC                 ; d‚lka ©etˆzce bude v dal¨¡m bajtu
         ;mov       cl,ah                    ; po‡et bajt– ©etˆzce - 2
         db        88h,0e1h
         inc       cx
         inc       cx                       ; po‡et bajt– = 3 a‘ 9
LZVStrtB:mov       al,es:[bx+di]            ; bajt z ji‘ existuj¡c¡ho ©etˆzce
         stosb                              ; ulo‘en¡ nov‚ho bajtu dat
         loop      LZVStrtB                 ; p©enos dal¨¡ho bajtu dat
         jmp       short LZVStrt4           ; dal¨¡ data programu

; ------- opakov n¡ ©etˆzce 3 a‘ 256 bajt– (stav 01, 3b=0 + 8b d‚lka + 13b off.)

LZVStrtC:lodsb                              ; na‡ten¡ dal¨¡ho bajtu dat
         ;or        al,al                    ; je konec dat ?
         db        8,0c0h
         jz        LZVStrtE                 ; je konec dat - start programu
         cmp       al,1                     ; je normalizace adres ukazatel– ?
         je        LZVStrtD                 ; je normalizace adres ukazatel–
         ;mov       cl,al                    ; d‚lka ©etˆzce - 1
         db        88h,0c1h
         inc       cx                       ; d‚lka ©etˆzce k p©esunu 3 a‘ 256
         jmp       short LZVStrtB           ; p©esun ji‘ existuj¡c¡ho ©etˆzce

; ------- normalizace c¡lov‚ adresy (ponech  se rezerva 8 KB)

LZVStrtD:;mov       bx,di                    ; offset c¡lov‚ adresy
         db        89h,0fbh
         ;and       di,0fh                   ; offset v odstavci
         db        83h,0e7h,0fh
         add       di,2000h                 ; rezerva bufferu 8 KB
         mov       cl,4                     ; po‡et rotac¡ pro p©evod na segment
         shr       bx,cl                    ; p©evod offsetu na segment
         mov       ax,es                    ; c¡lov˜ segment
         ;add       ax,bx                    ; posun c¡lov‚ho segmentu
         db        1,0d8h
         sub       ax,200h                  ; ode‡ten¡ rezervy 8 KB
         mov       es,ax                    ; segment c¡lov‚ adresy

; ------- normalizace zdrojov‚ adresy

         ;mov       bx,si                    ; offset zdrojov‚ adresy
         db        89h,0f3h
         ;and       si,0fh                   ; offset v odstavci
         db        83h,0e6h,0fh
         shr       bx,cl                    ; p©evod offsetu na segment
         mov       ax,ds                    ; segment zdrojov‚ adresy
         ;add       ax,bx                    ; p©i‡ten¡ p©enosu z offsetu
         db        1,0d8h
         mov       ds,ax                    ; nov  zdrojov  adresa
         jmp       LZVStrt4                 ; dal¨¡ data programu

; -----------------------------------------------------------------------------

         db        '*FAB*'                  ; pomocn˜ identifika‡n¡ text

; -----------------------------------------------------------------------------
;        relokace programu podle reloka‡n¡ tabulky
; -----------------------------------------------------------------------------

; Struktura reloka‡n¡ tabulky:
;                              ÚÄÄÄÄÄÄÄÄ¿
;             ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´ 1 bajt ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;             ³                ÀÄÄÄÄÄÄÄÄÙ                    ³
;         bajt = 0                                   bajt = 1 a‘ 0ffh
;             ³                                              ³
;        ÚÄÄÄÄÁÄÄÄÄ¿                              ÚÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;        ³ 1 slovo ³                              ³ bajt se p©i‡te k adrese ÃÄÄ¿
;        ÀÄÄÄÄÂÄÄÄÄÙ                              ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  ³
;             ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿                 ³
;         slovo = 1          slovo = 0             slovo = 2 a‘ 0ffffh         ³
;             ³           ÚÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄ¿      ÚÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿ ³
;             ³           ³ posun segmentu ³      ³ slovo se p©i‡te k adrese ³ ³
;             ³           ³ adresy o 0fffh ³      ÀÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ ³
;             ³           ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                 ³                 ³
;             ³                                     ÚÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ¿        ³
;             ³                                     ³ R E L O K A C E ³<ÄÄÄÄÄÄÄÙ
;             ³                                     ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;  konec relokace programu

LZVStrtE:push      cs
         pop       ds                       ; DS <- CS
         mov       si,offset(LZVRelTb-LZEXVzor) ; reloka‡n¡ tabulka programu
         pop       bx                       ; n vrat uschovan‚ho segmentu PSP
         add       bx,10h                   ; segment za‡ tku programu
         ;mov       dx,bx                    ; DX <- segment za‡ tku programu
         db        89h,0dah
         ;xor       di,di                    ; DI <- offset za‡ tku programu
         db        31h,0ffh

LZVStrtF:lodsb                              ; na‡ten¡ bajtu offsetu adresy
         ;or        al,al                    ; bude zmˆna adresy slovem ?
         db        8,0c0h
         jz        LZVStrtH                 ; zmˆna adresy slovem

         mov       ah,0                     ; bude zv˜¨en¡ adresy o max. 255
LZVStrtG:;add       di,ax                    ; zv˜¨en¡ offsetu programu
         db        1,0c7h
         mov       ax,di                    ; offset adresy
         ;and       di,0fh                   ; zbytek v paragrafu
         db        83h,0e7h,0fh
         mov       cl,4                     ; po‡et rotac¡ pro p©evod na segment
         shr       ax,cl                    ; p©evod adresy na segment
         ;add       dx,ax                    ; nov˜ segment adresy
         db        1,0c2h
         mov       es,dx                    ; segment dal¨¡ polo‘ky
         add       es:[di],bx               ; relokace adresy v programu
         jmp       short LZVStrtF           ; relokace dal¨¡ polo‘ky

LZVStrtH:lodsw                              ; na‡ten¡ slova offsetu adresy
         ;or        ax,ax                    ; bude zmˆna segmentu ?
         db        9,0c0h
         jnz       LZVStrtI                 ; nen¡ zmˆna segmentu
         add       dx,0fffh                 ; zmˆna segmentu o 64 KB
         mov       es,dx                    ; nov˜ segment adresy
         jmp       short LZVStrtF           ; relokace dal¨¡ polo‘ky

LZVStrtI:cmp       ax,1                     ; je konec tabulky ?
         jnz       LZVStrtG                 ; nen¡ konec tabulky - relokace

; -----------------------------------------------------------------------------
;        inicializace registr– na p–vodn¡ stav pro program
; -----------------------------------------------------------------------------

         mov       ax,bx                    ; adresa PSP
         mov       di,ds:[LZVRegSP-LZEXVzor]; p–vodn¡ registr SP programu
         mov       si,ds:[LZVRegSS-LZEXVzor]; p–vodn¡ registr SS programu
         ;add       si,ax                    ; relokace registru SS programu
         db        1,0c6h
         add       ds:[LZVRegCS-LZEXVzor],ax; relokace registru CS programu
         sub       ax,10h                   ; n vrat adresy PSP
         mov       ds,ax                    ; DS <- adresa PSP
         mov       es,ax                    ; ES <- adresa PSP
         ;xor       bx,bx                    ; BX <- 0
         db        31h,0dbh
         cli                                ; z kaz p©eru¨en¡
         mov       ss,si                    ; SS <- p–vodn¡ registr SS programu
         mov       sp,di                    ; SP <- p–vodn¡ registr SP programu
         sti                                ; povolen¡ p©eru¨en¡
         jmp       dword ptr cs:[bx]        ; skok na p–vodn¡ adresu CS:IP

; -----------------------------------------------------------------------------
;        reloka‡n¡ tabulka programu
; -----------------------------------------------------------------------------

LZVRelTb label     byte                     ; reloka‡n¡ tabulka programu

; *****************************************************************************
;
;                    Diskov‚ operace se soubory
;
; *****************************************************************************

; -----------------------------------------------------------------------------
;        ‡ten¡ slova AX ze vstupn¡ho souboru DS:SI
; -----------------------------------------------------------------------------

InpWord  PROC      NEAR

         call      InpByte
         xchg      ah,al
         call      InpByte
         xchg      ah,al
         ret

InpWord  ENDP

; -----------------------------------------------------------------------------
;        ‡ten¡ bajtu AL ze vstupn¡ho souboru DS:SI
; -----------------------------------------------------------------------------

InpByte  PROC      NEAR

         cmp       word ptr ds:[Num1],0
         jne       InpByte1

         call      InpRead
;         jc        InpByte2

InpByte1:cld
         lodsb
         dec       word ptr ds:[Num1]
         clc
InpByte2:ret

InpByte  ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ bufferu ze vstupn¡ho souboru
; -----------------------------------------------------------------------------

InpRead  PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx

         mov       dx,InpBuff               ; vstupn¡ buffer
         mov       si,dx
         mov       cx,BuffSize
         mov       ah,3fh
         mov       bx,ds:[Ident1]
         int       21h                      ; ‡ten¡ dat
         jc        InpRead3
         mov       ds:[Num1],ax
         or        ax,ax
         jz        InpRead3

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

InpRead3:call      OutWrite
         jmp       chyba

InpRead  ENDP

; -----------------------------------------------------------------------------
;        z pis slova AX do v˜stupn¡ho bufferu ES:DI
; -----------------------------------------------------------------------------

OutWord  PROC      NEAR

         call      OutByte
         xchg      ah,al
         call      OutByte
         xchg      ah,al
         ret

OutWord  ENDP

; -----------------------------------------------------------------------------
;        z pis bajtu AL do v˜stupn¡ho bufferu ES:DI
; -----------------------------------------------------------------------------

OutByte  PROC      NEAR

         cmp       word ptr ds:[Num2],BuffSize/2
         jb        OutByte1

         call      OutWrite
;         jc        OutByte2

OutByte1:cld
         stosb
         inc       word ptr ds:[Num2]
         clc

OutByte2:ret

OutByte  ENDP


; -----------------------------------------------------------------------------
;        z pis v˜stupn¡ho bufferu
; -----------------------------------------------------------------------------

OutWrite PROC      NEAR

; ------ £schova ukl dan‚ ‡ sti bufferu

         push      si
         push      cx
         mov       si,OutBuff+BuffSize/2
         mov       di,si
         mov       cx,ds:[Num2]
         sub       di,cx
         cld
         rep       movsb
         pop       cx
         pop       si

; ------ ulo‘en¡ dat

         push      ax
         push      bx
         push      cx
         push      dx

         mov       ah,40h
         mov       bx,ds:[Ident2]
         mov       cx,ds:[Num2]
         mov       word ptr ds:[Num2],0
         mov       dx,OutBuff+BuffSize/2
         jcxz      OutWrit2
         int       21h
         jc        OutWrit3
         cmp       ax,cx
         jne       OutWrit3

OutWrit2:pop       dx
         pop       cx
         pop       bx
         pop       ax

         mov       di,OutBuff+BuffSize/2
         ret

OutWrit3:jmp       chyba

OutWrite ENDP


; *****************************************************************************
;
;                             data programu
;
; *****************************************************************************

Soubor1  db        'FILE1.EXE',0
Ident1   dw        0
Ukaz1    dw        0                        ; ukazatel ‡tec¡ adresy
Num1     dw        0                        ; po‡et bajt– ve ‡tec¡m bufferu

soubor2  db        'FILE2.EXE',0
Ident2   dw        0
Ukaz2    dw        0                        ; ukazatel ukl dac¡ adresy
Num2     dw        0                        ; po‡et bajt– v z pisov‚m bufferu

UvTxt    db        'UNLZEXE V1.0; odpakovani LZEXE programu FILE1.EXE na FILE2.EXE',13,10,'$'


LZEXETxt db        'Program zkomprimovan pomoci LZEXE V0.91',13,10,'$'
NicTxt   db        'Na programu neni zadna nadstavba nebo je neznama.',13,10,'$'

ErrTxt   db        'Chyba !',13,10,'$'

; -----------------------------------------------------------------------------
;        z hlav¡ souboru
; -----------------------------------------------------------------------------

zahlavi  db        'MZ'
delka0   dw        0
delka    dw        0
nrelok   dw        1
headsize dw        2
minim    dw        20h
maxim    dw        0ffffh
regss    dw        0
regsp    dw        0
summ     dw        0
regip    dw        0
regcs    dw        0
relok1   dw        1ch
numovl   dw        0

relok    dw        0
         dw        0

         db        512-20h dup(0)           ; prvn¡ sektor z hlav¡

Konec    label     near                     ; konec programu

code     ENDS
         END       Start

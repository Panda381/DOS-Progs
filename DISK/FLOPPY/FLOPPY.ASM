
; *****************************************************************************
;
;                              F L O P P Y
;                    Nadstavba pro obsluhu disketov˜ch mechanik
;
; *****************************************************************************

;DEBUG    equ       1                        ; p©ep¡na‡ pro ladˆn¡

; ------ definice registr– v z sobn¡ku

RegAX    EQU       word ptr ss:[bp+0]
 RegAL   EQU       byte ptr ss:[bp+0]
 RegAH   EQU       byte ptr ss:[bp+1]
RegBX    EQU       word ptr ss:[bp+2]
 RegBL   EQU       byte ptr ss:[bp+2]
 RegBH   EQU       byte ptr ss:[bp+3]
RegCX    EQU       word ptr ss:[bp+4]
 RegCL   EQU       byte ptr ss:[bp+4]
 RegCH   EQU       byte ptr ss:[bp+5]
RegDX    EQU       word ptr ss:[bp+6]
 RegDL   EQU       byte ptr ss:[bp+6]
 RegDH   EQU       byte ptr ss:[bp+7]
RegSI    EQU       word ptr ss:[bp+8]
RegDI    EQU       word ptr ss:[bp+10]
RegDS    EQU       word ptr ss:[bp+12]
RegES    EQU       word ptr ss:[bp+14]
RegBP    EQU       word ptr ss:[bp+16]
RegIP    EQU       word ptr ss:[bp+18]
RegCS    EQU       word ptr ss:[bp+20]
RegFlag  EQU       word ptr ss:[bp+22]

; -----------------------------------------------------------------------------
;        Rezidentn¡ ‡ st programu
; -----------------------------------------------------------------------------

code     segment
         assume    cs:code,ds:code
         org       100h

Start:   jmp       Init                     ; inicializace programu

Identif  db        'FLOPPY V1.20'           ; identifikace ovlada‡e
Identif0 label     byte

                                          ;* tabulka definic disk–
DefDisk  db        0                        ; 0:
         db        0                        ; 1:
         db        0                        ; 2:
         db        0                        ; 3:

adrport1 dw        3f0h                     ; adresa ©adi‡e #1
adrport2 dw        370h                     ; adresa ©adi‡e #2

WaitAT   db        0                        ; 1=p©¡znak oznamov n¡ ‡ek n¡ AT
TimAT    db        0                        ; 1=p©¡znak ‡asova‡e AT

par40    db        0                        ; 1=p©¡znak obsluhy INT 40h

old40    dd        0                        ; p–vodn¡ obsluha INT 40h
old08    dd        0                        ; p–vodn¡ obsluha INT 08h

Counter  db        0                        ; ‡¡ta‡ pro dlouh‚ ‡asy
Counter2 db        0                        ; ‡¡ta‡ ‡asu pro ‡ten¡ ID

; ------ data pro ©adi‡ #2 (adresa 370h)

ParCtr2  db        0                        ; 1=p©¡znak instalace ©adi‡e #2

                                          ;* 003eh
Rekalib  db        0                        ; p©¡znak rekalibrace disk– 2 a 3
                                          ;* 003fh
Motors   db        0                        ; p©¡znaky motor– disk– 2 a 3
                                          ;* 0041h
LastStat db        0                        ; status posledn¡ diskov‚ operace
                                          ;* 0042h
Stat     db        7 dup(0)                 ; status ©adi‡e


                                          ;* 008bh
LastRate db        0                        ; poslednˆ nastaven  p©enos.rychlost
MaxRate  db        0                        ; maxim ln¡ p©enosov  rychlost

                                          ;* 008fh
Stat2    db        0                        ; stavov˜ bajt disku 2
Stat3    db        0                        ; stavov˜ bajt disku 3


                                          ;* 0090h
Med2     db        0                        ; stav m‚dia disku 2
                                          ;* 0091h
Med3     db        0                        ; stav m‚dia disku 3


                                          ;* 0094h
Stopa2   db        0                        ; aktu ln¡ stopa disku 2
Stopa3   db        0                        ; aktu ln¡ stopa disku 3


; *****************************************************************************
;
;        Obsluha INT 08h
;
; *****************************************************************************

PUBLIC   Int08
Int08    PROC      FAR

         pushf
         call      dword ptr cs:[Old08]     ; p–vodn¡ obsluha INT 08h

; ------ obsluha ‡¡ta‡e dlouh‚ho ‡asu

         cmp       byte ptr cs:[Counter],0  ; je nˆco v ‡¡ta‡i ‡asu ?
         je        Int080                   ; v ‡¡ta‡i ‡asu nic nen¡
         dec       byte ptr cs:[Counter]    ; sn¡‘en¡ ‡¡ta‡e ‡asu

; ------ obsluha ‡¡ta‡e pro ‡ten¡ ID

Int080:  cmp       byte ptr cs:[Counter2],0 ; je nˆco v ‡¡ta‡i ‡asu ?
         je        Int083                   ; v ‡¡ta‡i ‡asu nic nen¡
         dec       byte ptr cs:[Counter2]   ; sn¡‘en¡ ‡¡ta‡e ‡asu

; ------ obsluha vypnut¡ motor– mechanik portu #2

Int083:
         push      ax
         push      dx
         push      ds
         xor       ax,ax
         mov       ds,ax
         cmp       byte ptr ds:[440h],0     ; je dosa‘eno 0 ‡¡ta‡e motor– ?
         jne       Int082                   ; nen¡ 0 ‡¡ta‡e motor–
         cmp       byte ptr cs:[ParCtr2],0  ; je ©adi‡ 2 nainstalov n ?
         je        Int082                   ; ©adi‡ 2 nen¡ nainstalov n
         mov       dx,cs:[AdrPort2]
         add       dx,2                     ; ©¡dic¡ registr motor– ©adi‡e #2
         mov       al,0ch                   ; bajt pro vypnut¡ motor–
         out       dx,al                    ; vypnut¡ motor–
Int082:  pop       ds
         pop       dx
         pop       ax

Int081:  iret

Int08    ENDP


; *****************************************************************************
;        Data pro INT 40h
; *****************************************************************************

; -----------------------------------------------------------------------------
;        Tabulky disketov˜ch parametr–
; -----------------------------------------------------------------------------

TabDisk  label     byte                     ; (1):
Disk1:                                     ; mechanika 360 KB, disketa 360 KB
                                            db   0dfh      ; 0: rychlost krokov n¡, zvednut¡ hlavy
                                            db   2         ; 1: spu¨tˆn¡ p©¡tlaku hlavy
                                            db   37        ; 2: ‡as pro vypnut¡ motoru
                                            db   2         ; 3: velikost sektoru
                                            db   9         ; 4: po‡et sektor– na stopu
                                            db   42        ; 5: mezisekt. mezera ‡ten¡/z pis
                                            db   255       ; 6: d‚lka p©en ¨en˜ch dat
                                            db   80        ; 7: mezisekt. mezera form tov n¡
                                            db   0f6h      ; 8: plnic¡ znak form tov n¡
                                            db   15        ; 9: doba ust len¡ hlav
                                            db   8         ; 10: doba pro rozbˆh motoru
                                            db   39        ; 11: posledn¡ stopa
                                            db   80h       ; 12: p©enosov  rychlost 250K/s

                                            ; (2):
Disk2:                                      ; mechanika 1.2 MB, disketa 360 KB
                                            db   0dfh      ; 0: rychlost krokov n¡, zvednut¡ hlavy
                                            db   2         ; 1: spu¨tˆn¡ p©¡tlaku hlavy
                                            db   37        ; 2: ‡as pro vypnut¡ motoru
                                            db   2         ; 3: velikost sektoru
                                            db   9         ; 4: po‡et sektor– na stopu
                                            db   42        ; 5: mezisekt. mezera ‡ten¡/z pis
                                            db   255       ; 6: d‚lka p©en ¨en˜ch dat
                                            db   80        ; 7: mezisekt. mezera form tov n¡
                                            db   0f6h      ; 8: plnic¡ znak form tov n¡
                                            db   15        ; 9: doba ust len¡ hlav
                                            db   8         ; 10: doba pro rozbˆh motoru
                                            db   39        ; 11: posledn¡ stopa
                                            db   40h       ; 12: p©enosov  rychlost 300K/s

                                            ; (2 zvdojen ):
Disk3:                                      ; mechanika 1.2 MB, disketa 1.2 MB
                                            db   0dfh      ; 0: rychlost krokov n¡, zvednut¡ hlavy
                                            db   2         ; 1: spu¨tˆn¡ p©¡tlaku hlavy
                                            db   37        ; 2: ‡as pro vypnut¡ motoru
                                            db   2         ; 3: velikost sektoru
                                            db   15        ; 4: po‡et sektor– na stopu
                                            db   27        ; 5: mezisekt. mezera ‡ten¡/z pis
                                            db   255       ; 6: d‚lka p©en ¨en˜ch dat
                                            db   84        ; 7: mezisekt. mezera form tov n¡
                                            db   0f6h      ; 8: plnic¡ znak form tov n¡
                                            db   15        ; 9: doba ust len¡ hlav
                                            db   8         ; 10: doba pro rozbˆh motoru
                                            db   79        ; 11: posledn¡ stopa
                                            db   0         ; 12: p©enosov  rychlost 500K/s

                                            ; (3):
Disk4:                                      ; mechanika 720 KB, disketa 720 KB
                                            db   0dfh      ; 0: rychlost krokov n¡, zvednut¡ hlavy
                                            db   2         ; 1: spu¨tˆn¡ p©¡tlaku hlavy
                                            db   37        ; 2: ‡as pro vypnut¡ motoru
                                            db   2         ; 3: velikost sektoru
                                            db   9         ; 4: po‡et sektor– na stopu
                                            db   42        ; 5: mezisekt. mezera ‡ten¡/z pis
                                            db   255       ; 6: d‚lka p©en ¨en˜ch dat
                                            db   80        ; 7: mezisekt. mezera form tov n¡
                                            db   0f6h      ; 8: plnic¡ znak form tov n¡
                                            db   15        ; 9: doba ust len¡ hlav
                                            db   8         ; 10: doba pro rozbˆh motoru
                                            db   79        ; 11: posledn¡ stopa
                                            db   80h       ; 12: p©enosov  rychlost 250 k/s

                                            ; (4):
Disk5:                                      ; mechanika 1.44 MB, disketa 720 KB
                                            db   0dfh      ; 0: rychlost krokov n¡, zvednut¡ hlavy
                                            db   2         ; 1: spu¨tˆn¡ p©¡tlaku hlavy
                                            db   37        ; 2: ‡as pro vypnut¡ motoru
                                            db   2         ; 3: velikost sektoru
                                            db   9         ; 4: po‡et sektor– na stopu
                                            db   42        ; 5: mezisekt. mezera ‡ten¡/z pis
                                            db   255       ; 6: d‚lka p©en ¨en˜ch dat
                                            db   80        ; 7: mezisekt. mezera form tov n¡
                                            db   0f6h      ; 8: plnic¡ znak form tov n¡
                                            db   15        ; 9: doba ust len¡ hlav
                                            db   8         ; 10: doba pro rozbˆh motoru
                                            db   79        ; 11: posledn¡ stopa
                                            db   80h       ; 12: p©enosov  rychlost 250 k/s

                                            ; (4 zdvojen ):
Disk6:                                      ; mechanika 1.44 MB, disketa 1.44 MB
                                            db   0afh      ; 0: rychlost krokov n¡, zvednut¡ hlavy
                                            db   2         ; 1: spu¨tˆn¡ p©¡tlaku hlavy
                                            db   37        ; 2: ‡as pro vypnut¡ motoru
                                            db   2         ; 3: velikost sektoru
                                            db   18        ; 4: po‡et sektor– na stopu
                                            db   27        ; 5: mezisekt. mezera ‡ten¡/z pis
                                            db   255       ; 6: d‚lka p©en ¨en˜ch dat
                                            db   108       ; 7: mezisekt. mezera form tov n¡
                                            db   0f6h      ; 8: plnic¡ znak form tov n¡
                                            db   15        ; 9: doba ust len¡ hlav
                                            db   8         ; 10: doba pro rozbˆh motoru
                                            db   79        ; 11: posledn¡ stopa
                                            db   0         ; 12: p©enosov  rychlost 500 k/s

Disk7:                                      ; mechanika 1.2 MB, disketa 720 KB
                                            db   0dfh      ; 0: rychlost krokov n¡, zvednut¡ hlavy
                                            db   2         ; 1: spu¨tˆn¡ p©¡tlaku hlavy
                                            db   37        ; 2: ‡as pro vypnut¡ motoru
                                            db   2         ; 3: velikost sektoru
                                            db   9         ; 4: po‡et sektor– na stopu
                                            db   42        ; 5: mezisekt. mezera ‡ten¡/z pis
                                            db   255       ; 6: d‚lka p©en ¨en˜ch dat
                                            db   80        ; 7: mezisekt. mezera form tov n¡
                                            db   0f6h      ; 8: plnic¡ znak form tov n¡
                                            db   15        ; 9: doba ust len¡ hlav
                                            db   8         ; 10: doba pro rozbˆh motoru
                                            db   79        ; 11: posledn¡ stopa
                                            db   40h       ; 12: p©enosov  rychlost 500K/s

; *****************************************************************************
;
;        Obsluha disketov˜ch mechanik INT 40h
;
; *****************************************************************************

PUBLIC   Int40
Int40    PROC      FAR

; ------ £schova registr–

                                            ; F  ss:[bp+22]
                                            ; CS ss:[bp+20]
                                            ; IP ss:[bp+18]
         push      bp                       ; BP ss:[bp+16]
         push      es                       ; ES ss:[bp+14]
         push      ds                       ; DS ss:[bp+12]
         push      di                       ; DI ss:[bp+10]
         push      si                       ; SI ss:[bp+8]
         push      dx                       ; DX ss:[bp+6]
         push      cx                       ; CX ss:[bp+4]
         push      bx                       ; BX ss:[bp+2]
         push      ax                       ; AX ss:[bp+0]

         cld                                ; smˆr nahoru
         sti                                ; povolen¡ p©eru¨en¡
         mov       bp,sp                    ; ukazatel registr– v z sobn¡ku
         or        RegFlag,200h             ; nastaven¡ p©¡znaku IF

; ------ inicializace segment–

         push      cs
         pop       ds                       ; DS <- CS
         xor       si,si
         mov       es,si                    ; ES <- 0

; ------ kontrola maxim ln¡ho ‡¡sla funkce

         cmp       ah,18h                   ; maxim ln¡ ‡¡slo funkce
         jbe       Int401                   ; ‡¡slo funkce je OK
         mov       ah,14h                   ; n hrada - nepovolen  funkce

; ------ kontrola maxim ln¡ho ‡¡sla disku

Int401:  cmp       ah,1                     ; je funkce 0 nebo 1 ?
         jbe       Int402                   ; je funkce 0 nebo 1 - nen¡ kontrola
         cmp       ah,8                     ; je funkce 8 - poskytnut¡ param. ?
         je        Int402                   ; je funkce 8 - zat¡m se nekontrol.
         cmp       dl,4                     ; p©ekro‡eno max. ‡¡slo disku ?
         jb        Int402                   ; ‡¡slo disku je OK
         mov       ah,14h                   ; n hrada - nepovolen  funkce

; ------ p©ednastaven¡ registr–

Int402:  mov       bl,dl                    ; ‡¡slo po‘adovan‚ho disku

; ------ proveden¡ obsluhy funkce

Int403:  xchg      ah,al                    ; AL <- ‡¡slo funkce
         xor       ah,ah                    ; AH <- 0
         mov       si,ax                    ; SI <- ‡¡slo funkce
         add       si,si                    ; ‡¡slo funkce * 2
         call      word ptr ds:[si+TabSkok] ; proveden¡ obsluhy funkce

; ------ konverze nov‚ho form tu dat na star˜

Int407:  mov       bl,RegDL                 ; ‡¡slo disku
         call      XlatOld                  ; p©evod nov‚ho form tu na star˜
         cmp       RegAH,15h                ; je funkce 15h
         je        Int40a                   ; je funkce 15h

; ------ nastaven¡ p©¡znaku chyby operace

         mov       byte ptr es:[441h],ah    ; n vratov˜ k¢d
         or        RegFlag,1                ; nastaven¡ p©¡znaku chyby CY
         or        ah,ah                    ; byla chyba operace ?
         jnz       Int40b                   ; byla chyba operace

; ------ operace probˆhla OK, nastaven¡ n vratov‚ho k¢du

Int40a:  and       RegFlag,not 1            ; nulov n¡ p©¡znaku CF
Int40b:  mov       RegAH,ah                 ; nastaven¡ n vratov‚ho k¢du

; ------ nastaven¡ ‡¡ta‡e pro vypnut¡ motoru

         mov       al,2
         call      GetPar                   ; poskytnut¡ parametru 2
         call      SetMOff                  ; nastaven¡ ‡¡ta‡– pro vypnut¡ mot.

; ------ n vrat registr–

         pop       ax
         pop       bx
         pop       cx
         pop       dx
         pop       si
         pop       di
         pop       ds
         pop       es
         pop       bp
         iret

Int40    ENDP

; -----------------------------------------------------------------------------
;        Chybn‚ zad n¡ povelu
; -----------------------------------------------------------------------------

Chyba:   mov       ah,1
         ret

; -----------------------------------------------------------------------------
;        Tabulka adres obsluh funkc¡
; -----------------------------------------------------------------------------

TabSkok  label     word
         dw        offset Funkce00          ; funkce 00h reset diskety
         dw        offset Funkce01          ; funkce 01h poskytnut¡ stavu
         dw        offset Funkce02          ; funkce 02h ‡ten¡ sektor–
         dw        offset Funkce03          ; funkce 03h z pis sektor–
         dw        offset Funkce04          ; funkce 04h verifikace sektor–
         dw        offset Funkce05          ; funkce 05h form tov n¡ stopy
         dw        offset Chyba             ; funkce 06h
         dw        offset Chyba             ; funkce 07h
         dw        offset Funkce08          ; funkce 08h poskytnut¡ disk.par.
         dw        offset Chyba             ; funkce 09h
         dw        offset Funkce0a          ; funkce 0ah nalezen¡ sektor–
         dw        offset Chyba             ; funkce 0bh
         dw        offset Funkce0c          ; funkce 0ch vystaven¡ na v lec
         dw        offset Chyba             ; funkce 0dh
         dw        offset Chyba             ; funkce 0eh
         dw        offset Chyba             ; funkce 0fh
         dw        offset Funkce10          ; funkce 10h test na p©ipravenost
         dw        offset Chyba             ; funkce 11h
         dw        offset Chyba             ; funkce 12h
         dw        offset Chyba             ; funkce 13h
         dw        offset Chyba             ; funkce 14h
         dw        offset Funkce15          ; funkce 15h ‡ten¡ typu DASD
         dw        offset Funkce16          ; funkce 16h status v˜mˆny
         dw        offset Funkce17          ; funkce 17h nastaven¡ DASD
         dw        offset Funkce18          ; funkce 18h nastaven¡ m‚dia

; -----------------------------------------------------------------------------
;        Funkce 00h - resetov n¡ diskov‚ho syst‚mu
; -----------------------------------------------------------------------------

PUBLIC   Funkce00
Funkce00 PROC      NEAR

         cmp       byte ptr ds:[ParCtr2],0  ; je nainstalov n ©adi‡ #2 ?
         je        Fnc001                   ; ©adi‡ #2 nen¡ nainstalov n
         mov       bl,2
         call      DiskRes
Fnc001:  xor       bl,bl
         call      DiskRes
         ret

Funkce00 ENDP

; -----------------------------------------------------------------------------
;        Funkce 01h - poskytnut¡ stavu posledn¡ diskov‚ operace
; -----------------------------------------------------------------------------

PUBLIC   Funkce01
Funkce01 PROC      NEAR

         mov       ah,es:[441h]             ; k¢d posledn¡ diskov‚ operace
         ret

Funkce01 ENDP

; -----------------------------------------------------------------------------
;        Funkce 2, 3, 4 - Operace ‡ten¡, z pis a verifikace
; -----------------------------------------------------------------------------
; - kontrola zad n¡ disku
; - zapnut¡ motoru
; - p©i nezn m‚m m‚diu se nastav¡ po‡ te‡n¡ a koncov  rychlost
;   Opakuje se pro r–zn‚ p©enosov‚ rychlosti:
;     - kontrola v˜mˆny m‚dia (p©i v˜mˆnˆ se m‚dium ozna‡¡ za nezn m‚)
;     - nastaven¡ povelu SPECIFY (proto‘e se mohou rychlosti mˆnit)
;     - nastaven¡ p©enosov‚ rychlosti
;     - vystaven¡ na po‘adovanou stopu
;     - nastaven¡ kan lu DMA
;     - stanoven¡ parametr– operace a vysl n¡ povelu
; - p©i chybˆ operace pokus o opakov n¡ s jin˜mi parametry
; - p©i £spˆchu operace stanoven¡ typu disku, m‚dia a po‡tu p©enes. sektor–
; -----------------------------------------------------------------------------

;
; -----------------------------------------------------------------------------

Funkce02:
Funkce03:
Funkce04:

PUBLIC   RdWrVf
RdWrVf   PROC      NEAR

; ------ kontrola platnosti zad n¡ disku - zda je mechanika nainstalovan 

         call      GetStat                  ; poskytnut¡ stavov‚ho bajtu disku
         jnz       RdWrVf0                  ; mechanika je definovan  - OK
         mov       ah,80h                   ; chyba - disk nep©ipraven
         jmp       RdWrVfc                  ; n vrat s chybou

; ------ nastaven¡ p©¡znaku z pisu nebo ‡ten¡

RdWrVf0: call      ResWr                    ; nastaven¡ p©¡znaku operace ‡ten¡
         cmp       RegAH,3                  ; je operace z pis ?
         jne       RdWrVf1                  ; nen¡ operace z pis
         call      SetWr                    ; nastaven¡ p©¡znaku operace z pis

; ------ zapnut¡ motoru

RdWrVf1: call      MotorOn

; ------ nastaven¡ po‡ te‡n¡ a koncov‚ rychlosti

         call      GetMed                   ; poskytnut¡ stavov‚ho bajtu m‚dia
         test      al,10h                   ; je m‚dium zn m‚ ?
         jnz       RdWrVf2                  ; m‚dium je zn m‚
         call      SetupSt                  ; inic. po‡ t. a kon. rychlosti

; ------ kontrola v˜mˆny m‚dia (zde se za‡¡n  p©i opakov n¡ s jinou rychlost¡)

RdWrVf2: call      MedChng0                 ; kontrola v˜mˆny m‚dia
         jz        RdWrVf3                  ; m‚dium nebylo vymˆnˆno
         jmp       RdWrVfc                  ; m‚dium vymˆnˆno nebo chyba

; ------ stanoven¡ doby pro krokov n¡ hlav

RdWrVf3: mov       cx,2dfh                  ; standardn¡ rychlost krokov n¡
         call      GetMed                   ; poskytnut¡ bajtu stavu m‚dia
         and       al,0c0h                  ; je p©enosov  rychlost 500 k/s ?
         jnz       RdWrVf4                  ; nen¡ p©enosov  rychlost 500 K/s
         call      GetTyp                   ; poskytnut¡ typu disku AL
         cmp       al,4                     ; je mechanika 3 1/2" ?
         jne       RdWrVf4                  ; nen¡ mechanika 3 1/2"
         mov       cl,0afh                  ; krokov n¡ pro 1.44 MB v 1.44 MB

; ------ nastaven¡ povelu SPECIFY

RdWrVf4: push      cx                       ; parametry povely SPECIFY
         mov       si,sp                    ; ukazatel dat v z sobn¡ku
         mov       al,3                     ; povel SPECIFY
         mov       ah,3                     ; po‡et bajt– k vysl n¡
         call      NECOutp                  ; vysl n¡ povelu SPECIFY
         pop       cx                       ; zru¨en¡ dat v z sobn¡ku
         jz        RdWrVf5                  ; operace OK
         jmp       RdWrVfb                  ; chyba - ale je mo‘n‚ opakovat

; ------ nastaven¡ po‘adovan‚ p©enosov‚ rychlosti

RdWrVf5: call      SendRate                 ; vysl n¡ p©enosov‚ rychlosti

; ------ test dvoj¡ho krokov n¡

         call      SetDbl                   ; test dvoj¡ho krokov n¡
         or        ah,ah                    ; byla chyba operace ?
         jz        RdWrVf6
         jmp       RdWrVfb

; ------ vystaven¡ na po‘adovanou stopu

RdWrVf6: mov       al,RegCH                 ; po‘adovan  stopa
         call      Seek                     ; vystaven¡ na po‘adovanou stopu
         jz        RdWrVf7                  ; operace OK
         jmp       RdWrVfb                  ; chyba operace - ale lze opakovat

; ------ nastaven¡ kan lu DMA

RdWrVf7: mov       al,3                     ; parametr 3 - velikost sektoru
         call      GetPar                   ; poskytnut¡ parametru 3
         mov       cl,al                    ; velikost sektoru
         add       cl,7                     ; korekce na © d sektoru
         mov       al,RegAL                 ; po‡et sektor–
         xor       ah,ah                    ; AH <- 0, AX=po‡et sektor–
         shl       ax,cl                    ; v˜po‡et velikosti pamˆti
         dec       ax                       ; po‡et bajt– - 1
         push      ax                       ; velikost bloku pamˆti
         push      RegES                    ; ES segment adresy
         push      RegBX                    ; BX offset adresy
         xor       ch,ch                    ; CH <- 0
         mov       cl,RegAH                 ; po‘adovan  funkce
         mov       si,cx                    ; po‘adovan  funkce
         mov       al,ds:[TabFnc+si-2]      ; povel pro funkci
         mov       si,sp                    ; ukazatel dat v z sobn¡ku
         call      SetDma                   ; nastaven¡ kan lu DMA
         add       sp,6                     ; zru¨en¡ dat v z sobn¡ku
         or        ah,ah                    ; byla chyba operace ?
         jz        RdWrVf8                  ; operace probˆhla OK
         jmp       short RdWrVfb            ; chyba p©ete‡en¡ DMA - lze opakovat

; ------ stanoven¡ d‚lky p©en ¨en˜ch dat a mezisektorov‚ mezery

RdWrVf8: mov       al,6                     ; parametr 6 - d‚lka p©en ¨en˜ch dat
         call      GetPar                   ; poskytnut¡ parametru 6 - d‚lka dat
         mov       ch,al                    ; d‚lka p©en ¨en˜ch dat (bajt–)
         mov       cl,27                    ; mezisektorov  mezera pro disky HD
         call      GetMed                   ; poskytnut¡ bajtu stavu m‚dia
         and       al,0c0h                  ; po‘adovan  p©enosov  rychlost
         jz        RdWrVf9                  ; je p©enosov  rychlost HD 500 k/s
         mov       cl,42                    ; mezisektorov  mezera pro disky DD
RdWrVf9: push      cx                       ; nastaven¡ parametr– do z sobn¡ku

; ------ stanoven¡ maxim ln¡ho sektoru a velikosti sektoru

         mov       al,4                     ; parametr 4 - max. sektor
         call      GetPar                   ; poskytnut¡ parametru 4 - max.sekt.
         mov       ch,al                    ; maxim ln¡ ‡¡slo sektoru
         mov       al,3                     ; parametr 3 - velikost sektoru
         call      GetPar                   ; poskytnut¡ parametru 3 - vel.sekt.
         mov       cl,al                    ; velikost sektoru
         push      cx                       ; nastaven¡ dat do z sobn¡ku

; ------ nastaven¡ po‡ te‡n¡ho sektoru, v lce a hlavy

         mov       ch,RegCL                 ; po‡ te‡n¡ sektor
         mov       cl,RegDH                 ; po‡ te‡n¡ hlava
         push      cx                       ; nastaven¡ dat do z sobn¡ku
         mov       ch,RegCH                 ; po‡ te‡n¡ stopa
         mov       cl,RegDH                 ; hlava
         and       cl,1                     ; hlava
         shl       cl,1
         shl       cl,1
         or        cl,RegDL                 ; hlava + ‡¡slo mechaniky
         and       cl,00000101b             ; disk relativnˆ v ©adi‡i
         push      cx                       ; nastaven¡ dat do z sobn¡ku

; ------ vysl n¡ povelu pro proveden¡ operace

         mov       al,0e6h                  ; povel pro ‡ten¡
         cmp       RegAH,3                  ; je operace z pis ?
         jne       RdWrVfa                  ; nen¡ z pis
         mov       al,0c5h                  ; povel pro z pis
RdWrVfa: mov       ah,9                     ; po‡et bajt– k vysl n¡
         mov       si,sp                    ; ukazatel dat v z sobn¡ku
         call      NECOutp                  ; vysl n¡ povelu na ©adi‡
         add       sp,8                     ; zru¨en¡ dat v z sobn¡ku
         or        ah,ah                    ; probˆhla operace OK ?
         jnz       RdWrVfb                  ; byla chyba operace

; ------ ‡ek n¡ na proveden¡ operace

         call      NECWait                  ; ‡ek n¡ na proveden¡ operace

; ------ n vrat z operace - p©i chybˆ je mo‘n‚ opakov n¡

RdWrVfb: or        ah,ah                    ; byla nˆjak  chyba operace ?
         jz        RdWrVfd                  ; operace probˆhla OK

; ------ kontrola stavu operace (zda je mo‘n‚ opakov n¡)

         cmp       ah,80h                   ; byla chyba nep©ipravenosti ?
         je        RdWrVfc                  ; mechanika nep©ipravena
         cmp       ah,9                     ; byla chyba DMA ?
         je        RdWrVfc                  ; chyba p©ete‡en¡ okraje DMA
         call      GetMed                   ; poskytnut¡ bajtu stavu m‚dia
         test      al,10h                   ; je m‚dium ur‡eno ?
         jnz       RdWrVfc                  ; m‚dium je ur‡eno - je jin  chyba

; ------ opakov n¡ operace s jinou p©enosovou rychlost¡ nebo krokov n¡m

         call      Retry                    ; nastaven¡ dal¨¡ p©enos. rychlosti
         jnz       RdWrVfc                  ; nen¡ mo‘n‚ dal¨¡ opakov n¡
         jmp       RdWrVf2                  ; opakov n¡ s jinou p©enos. rychl.

; ------ chyba operace - nen¡ ‘ dn˜ sektor

RdWrVfc: mov       RegAL,0                  ; nastaven¡ AL - nen¡ ‘ dn˜ sektor
         ret

; ------ operace probˆhla OK - £schova stavu

RdWrVfd: call      DState                   ; ur‡en¡ typu m‚dia a mechaniky
         mov       cx,RegCX                 ; ‡¡slo stopy a sektoru
         mov       dh,RegDH                 ; hlava
         call      NumTrans                 ; ur‡en¡ po‡tu p©enesen˜ch sektor–
         mov       RegAL,al                 ; n vrat po‡tu p©enesen˜ch sektor–
         xor       ah,ah                    ; p©¡znak operace OK
RdWrVfe: ret

RdWrVf   ENDP

TabFnc   db        46h,4ah,42h              ; povely pro funkce 2,3,4

; -----------------------------------------------------------------------------
;        Funkce 5 - form tov n¡ stopy
; -----------------------------------------------------------------------------

PUBLIC   Funkce05
Funkce05 PROC      NEAR

; ------ kontrola, zda je disk instalov n

         call      GetStat                  ; poskytnut¡ stavov‚ho bajtu disku
         jnz       Format1                  ; mechanika je instalov na
         mov       ah,80h                   ; chyba - disk nep©ipraven
         jmp       Format7                  ; chybov˜ n vrat

; ------ ur‡en¡ typu m‚dia

Format1: call      GetMed                   ; poskytnut¡ bajtu stavu m‚dia
         test      al,10h                   ; je m‚dium ur‡eno ?
         jnz       Format2                  ; m‚dium je ur‡eno
         call      MedDet                   ; implicitn¡ ur‡en¡ typu m‚dia

; ------ kontrola v˜mˆny m‚dia

Format2: call      SetWr                    ; p©¡znak operace z pis
         call      MedChng                  ; kontrola v˜mˆny m‚dia
         jz        Format3                  ; m‚dium nebylo vymˆnˆno
         jmp       Format7                  ; m‚dium vymˆnˆno nebo chyba

; ------ vysl n¡ povelu SPECIFY na ©adi‡

Format3: mov       al,1                     ; parametr 1 - spu¨tˆn¡ hlavy
         call      GetPar                   ; poskytnut¡ parametru 1
         mov       ah,al                    ; parametr 1
         xor       al,al                    ; parametr 0 - krokov n¡
         call      GetPar                   ; poskytnut¡ parametru 0
         push      ax                       ; krokov n¡ a doba zpu¨tˆn¡ p©¡tlaku
         mov       si,sp                    ; ukazatel dat v z sobn¡ku
         mov       al,3                     ; povel SPECIFY
         mov       ah,3                     ; po‡et bajt– k vysl n¡
         call      NECOutp                  ; vysl n¡ povelu SPECIFY na ©adi‡
         pop       cx                       ; zru¨en¡ parametr– ze z sobn¡ku
         jz        Format4                  ; operace probˆhla OK
         jmp       short Format7            ; chyba p©i vysl n¡ povelu na ©adi‡

; ------ nastaven¡ p©enosov‚ rychlosti

Format4: call      SendRate                 ; vysl n¡ p©enosov‚ rychlosti

; ------ nastaven¡ kan lu DMA

         mov       al,4                     ; parametr 4 - po‡et sekt. na stopu
         call      GetPar                   ; poskytnut¡ parametru 4
         shl       ax,1
         shl       ax,1                     ; vyn soben¡ 4 bajty na sektor
         dec       ax                       ; po‡et bajt– - 1
         push      ax                       ; po‡et bajt– k vysl n¡ na ©adi‡
         push      RegES                    ; segment adresy tabulky (ES)
         push      RegBX                    ; offset adresy tabulky (BX)
         mov       si,sp                    ; ukazatel dat v z sobn¡ku
         mov       al,4ah                   ; povel pro nastaven¡ ©adi‡e DMA
         call      SetDMA                   ; nastaven¡ kan lu DMA
         add       sp,6                     ; zru¨en¡ dat v z sobn¡ku
         or        ah,ah                    ; probˆhlo nastaven¡ DMA OK ?
         jz        Format5                  ; kan l DMA byl nastaven OK
         jmp       RdWrVfe                  ; n vrat p©i chybˆ

; ------ vystaven¡ hlav na po‘adovanou stopu

Format5: mov       al,RegCH                 ; stopa
         call      Seek                     ; vystaven¡ na po‘adovanou stopu
         jz        Format6                  ; vystaven¡ probˆhlo OK
         jmp       short Format7            ; n vrat p©i chybˆ

; ------ vysl n¡ povelu pro form tov n¡

Format6: mov       al,8                     ; parametr 8 - datov˜ vzor
         call      GetPar                   ; poskytnut¡ parametru 8
         push      ax                       ; plnic¡ znak pro form tov n¡

         mov       al,7                     ; parametr 7 - mezisekt. mezera
         call      GetPar                   ; poskytnut¡ parametru 7
         mov       ah,al                    ; parametr 7

         mov       al,4                     ; parametr 4 - posledn¡ sektor
         call      GetPar                   ; poskytnut¡ parametru 4
         push      ax                       ; nastaven¡ mezery a max. sektoru

         mov       al,3                     ; parametr 3 - velikost sektoru
         call      GetPar                   ; poskytnut¡ parametru 3
         mov       ah,al                    ; parametr 3
         mov       al,RegDH                 ; po‘adovan  hlava
         and       al,1
         shl       al,1
         shl       al,1                     ; rotace na pozici
         or        al,bl                    ; po‘adovan˜ disk
         and       al,00000101b             ; disk relativnˆ
         push      ax                       ; disk a sektor do z sobn¡ku

         mov       si,sp                    ; ukazatel dat v z sobn¡ku
         mov       al,4dh                   ; povel pro form tov n¡
         mov       ah,6                     ; po‡et bajt– k vysl n¡
         call      NECOutp                  ; vysl n¡ povelu na ©adi‡
         add       sp,6                     ; zru¨en¡ dat v z sobn¡ku
         or        ah,ah                    ; byla chyba operace ?
         jnz       Format7                  ; chyba vysl n¡ povelu na ©adi‡

; ------ ‡ek n¡ na proveden¡ operace

         call      NECWait                  ; ‡ek n¡ na proveden¡ operace
Format7: ret

Funkce05 ENDP

; -----------------------------------------------------------------------------
;        Funkce 8 - poskytnut¡ aktu ln¡ch diskov˜ch parametr–
; -----------------------------------------------------------------------------

PUBLIC   Funkce08
Funkce08 PROC      NEAR

; ------ test, zda je nˆjak˜ disk

         mov       al,es:[410h]             ; bajt vybaven¡
         test      al,1                     ; je nˆjak˜ disk ?
         jnz       DiskPar1                 ; je nˆjak˜ disk
         xor       al,al                    ; nen¡ ‘ dn˜ disk
         jmp       short DiskPar2           ; nen¡ ‘ dn˜ disk

; ------ stanoven¡ po‡tu disk–

DiskPar1:rol       al,1
         rol       al,1                     ; AL <- po‡et disk–
         and       al,3                     ; po‡et disk– - 1
         inc       al                       ; po‡et disk–

; ------ kontrola, zda je zad n platn˜ disk

DiskPar2:xchg      al,RegDL                 ; po‡et disk–
         cmp       al,80h                   ; je zad n pevn˜ disk ?
         jb        DiskPar3                 ; je disketa - OK
         mov       ah,1                     ; chyba - neplatn  funkce
         mov       RegDL,0                  ; po‡et disk– = 0
         jmp       DiskPar9

; ------ ovˆ©en¡ po‡tu mechanik

DiskPar3:cmp       RegDL,0                  ; je nˆjak  mechanika ?
         je        DiskPar5                 ; nen¡ ‘ dn  mechanika
         cmp       al,3                     ; je zad n disk 0 a‘ 3 ?
         ja        DiskPar5                 ; chybn‚ ‡¡slo disku

; ------ nastaven¡ typu mechaniky z CMOS

         call      GetTyp                   ; poskytnut¡ typu disku AL
         jz        DiskPar4                 ; nen¡ to platn  mechanika
         mov       cl,al                    ; typ mechaniky
         xor       ch,ch                    ; CH <- 0
         mov       RegBX,cx                 ; nastaven¡ typu mechaniky
         jmp       short DiskPar6

; ------ neplatn  mechanika v CMOS - pokus o ur‡en¡

DiskPar4:call      GetMed                   ; poskytnut¡ bajtu stavu m‚dia
         test      al,10h                   ; je m‚dium ur‡eno ?
         jz        DiskPar5                 ; m‚dium nen¡ ur‡eno
         xor       cx,cx                    ; CX <- 0
         mov       RegBX,cx                 ; registr BX <- 0
         mov       cl,al                    ; stavov˜ bajt m‚dia
         rol       cl,1
         rol       cl,1
         rol       cl,1                     ; CL <- p©enosov  rychlost
         and       cl,6                     ; p©enosov  rychlost * 2
         call      GetStat                  ; poskytnut¡ stavov‚ho bajtu disku
         and       al,1                     ; p©¡znak mechaniky 80 stop
         or        cl,al                    ; nastaven¡ p©¡znaku 80 stop
         mov       si,cx                    ; p©¡znaky mechaniky
         mov       al,ds:[TabDiskP+si]      ; typ disku
         jmp       short DiskPar6

; ------ m‚dium nen¡ ur‡eno

DiskPar5:mov       RegAX,0
         mov       RegBX,0
         mov       RegCX,0
         mov       RegDH,0
         mov       RegES,0
         mov       RegDI,0
         jmp       short DiskPar8

; ------ zji¨tˆn¡ parametr– diskety (AL=typ mechaniky 1 a‘ 4)

DiskPar6:call      GetTab                   ; poskytnut¡ adresy tabulky disku
         test      al,1                     ; je disk DD ?
         jnz       DiskPar7                 ; je disk DD
         add       si,13                    ; je disk HD - je i disketa HD

; ------ nastaven¡ parametr– k n vratu

DiskPar7:mov       RegAX,0
         mov       al,ds:[si+4]             ; posledn¡ sektor na stopˆ
         mov       ah,ds:[si+11]            ; posledn¡ stopa
         mov       RegCX,ax                 ; reg. CX <- posledn¡ sektor a stopa
         mov       RegDH,1                  ; DH <- ‡¡slo posledn¡ hlavy
         mov       RegDI,si                 ; DI <- offset tabulky parametr–
         mov       RegES,cs                 ; ES <- segment tabulky parametr–
DiskPar8:xor       ah,ah                    ; n vratov˜ k¢d (=OK)
DiskPar9:ret

Funkce08 ENDP

TabDiskP db        4                        ; 40 stop, 500 k/s (1.44 MB)
         db        4                        ; 80 stop, 500 k/s (1.44 MB)
         db        2                        ; 40 stop, 300 k/s (1.2 MB)
         db        2                        ; 80 stop, 300 k/s (1.2 MB)
         db        1                        ; 40 stop, 250 k/s (360 KB)
         db        4                        ; 80 stop, 250 k/s (1.44 MB)
         db        4                        ; 40 stop, xxx k/s (1.44 MB)
         db        4                        ; 80 stop, xxx k/s (1.44 MB)

; -----------------------------------------------------------------------------
;        Funkce 0ah - vyhled v n¡ sektor–
; -----------------------------------------------------------------------------

PUBLIC   Funkce0a
Funkce0a PROC      NEAR

; ------ kontrola platnosti zad n¡ disku - zda je mechanika nainstalovan 

         mov       ah,80h                   ; chyba - disk nep©ipraven
         call      GetStat                  ; poskytnut¡ stavov‚ho bajtu disku
         jnz       Fnc0a0                   ; mechanika definovan  OK
Fnc0af2: jmp       Fnc0af                   ; chyba - mechanika nen¡ definovan 

; ------ test, zda je m‚dium zn m‚

Fnc0a0:  mov       ah,0ch                   ; chyba - typ m‚dia nezn m˜
         call      GetMed                   ; poskytnut¡ stavov‚ho bajtu m‚dia
         test      al,10h                   ; je m‚dium zn m‚ ?
         jz        Fnc0af2                  ; chyba - m‚dium nezn m‚

; ------ kontrola v˜mˆny m‚dia

         call      MedChng                  ; kontrola v˜mˆny m‚dia
         jnz       Fnc0af2                  ; m‚dium vymˆnˆno nebo chyba

; ------ nastaven¡ po‘adovan‚ p©enosov‚ rychlosti

         call      SendRate                 ; vysl n¡ p©enosov‚ rychlosti

; ------ vystaven¡ na po‘adovanou stopu

         mov       al,RegCH                 ; po‘adovan  stopa
         call      Seek                     ; vystaven¡ na po‘adovanou stopu
         jnz       Fnc0af2                  ; chyba operace

; ------ doba pro vypnut¡ motoru na maximum

         mov       al,0ffh                  ; inicializa‡n¡ doba pro vypnut¡
         call      SetMOff                  ; nastaven¡ doby pro vypnut¡

; ------ synchonizace na hranu hodin

         mov       byte ptr ds:[Counter2],1 ; hodnota pro synchronizaci hodin
Fnc0a8:  cmp       byte ptr ds:[Counter2],0 ; byla hrana hodin ?
         jne       Fnc0a8                   ; ‡ek n¡ na hranu hodin
         mov       byte ptr ds:[Counter2],4 ; doba pro asi jednu ot ‡ku
         mov       di,RegBX                 ; offset ukl dac¡ adresy
         mov       RegAL,0                  ; po‡et nalezen˜ch identif. = 0

; ------ nalezen¡ identifik toru

Fnc0a9:  mov       dl,RegDH                 ; hlava
         and       dl,1                     ; hlava
         shl       dl,1
         shl       dl,1
         or        dl,bl                    ; hlava + ‡¡slo mechaniky
         and       dl,00000101b             ; disk relativnˆ v ©adi‡i
         push      dx                       ; po‘adovan˜ disk
         mov       si,sp                    ; ukazatel parametr–
         mov       al,4ah                   ; povel pro ‡ten¡ identifik toru ID
         mov       ah,2                     ; po‡et parametr– READ ID
         call      NECOutp                  ; vysl n¡ povelu READ ID na ©adi‡
         pop       dx                       ; zru¨en¡ dat v z sobn¡ku
         jnz       Fnc0af2                  ; byla chyba operace

; ------ test, zda byl ID nalezen

         call      NECWait                  ; ‡ek n¡ na proveden¡ operace
         jnz       Fnc0ah                   ; ID nenalezen - to je OK

; ------ test, zda byl identifik tor ji‘ nalezen

         cmp       byte ptr ds:[Counter2],1 ; p©etekl ji‘ ‡asova‡ ?
         ja        Fnc0ai                   ; ‡asova‡ je¨tˆ nep©etekl

         mov       ah,3                     ; po‡ te‡n¡ polo‘ka - stopa
         mov       si,RegBX                 ; offset bufferu
Fnc0aj:  mov       al,ah                    ; ‡¡slo polo‘ky
         call      GetRes                   ; poskytnut¡ polo‘ky
         push      es
         mov       es,RegES                 ; segment bufferu
         cmp       es:[si],al               ; je polo‘ka stejn  ?
         pop       es
         jne       Fnc0ai                   ; polo‘ka je jin 
         inc       ah                       ; zv˜¨en¡ ‡¡sla polo‘ky
         inc       si                       ; zv˜¨en¡ adresy v bufferu
         cmp       ah,6                     ; byla ji‘ posledn¡ polo‘ka ?
         jbe       Fnc0aj                   ; £schova dal¨¡ polo‘ky
         jmp       short Fnc0ah             ; polo‘ka byla ji‘ nalezena

; ------ operace probˆhla OK - £schova identifik toru

Fnc0ai:  inc       RegAL                    ; zv˜¨en¡ ‡¡ta‡e nalezen˜ch ident.
         mov       ah,3                     ; po‡ te‡n¡ polo‘ka - stopa
Fnc0ae:  mov       al,ah
         call      GetRes                   ; poskytnut¡ polo‘ky
         push      es
         mov       es,RegES                 ; segment bufferu
         mov       es:[di],al               ; ulo‘en¡ parametru do bufferu
         inc       di                       ; zv˜¨en¡ ukl dac¡ adresy
         pop       es
         inc       ah                       ; zv˜¨en¡ ‡¡sla polo‘ky
         cmp       ah,6                     ; byla ji‘ posledn¡ polo‘ka ?
         jbe       Fnc0ae                   ; £schova dal¨¡ polo‘ky

; ------ test, zda se m  pokra‡ovat v hled n¡

         cmp       byte ptr ds:[Counter2],0 ; uplynul ji‘ zadan˜ ‡as ?
         jne       Fnc0a9                   ; ‡as je¨tˆ neuplynul

; ------ set©¡dˆn¡ tabulky v bufferu

Fnc0ah:  xor       cx,cx
         mov       cl,RegAL                 ; po‡et nalezen˜ch sektor–
         jcxz      Fnc0ak                   ; nebyl ‘ dn˜ sektor

; ------ nalezen¡ nejmen¨¡ho sektoru

         push      es
         push      cx
         mov       es,RegES                 ; segment s bufferem
         mov       si,RegBX                 ; offset bufferu
         mov       dh,0ffh                  ; ‡¡slo nejmen¨¡ho sektoru
Fnc0al:  cmp       dh,es:[si+2]             ; je sektor men¨¡ ?
         jbe       Fnc0am                   ; sektor nen¡ men¨¡
         mov       dh,es:[si+2]             ; nov˜ nejmen¨¡ sektor
Fnc0am:  add       si,4                     ; zv˜¨en¡ adresy v bufferu
         loop      Fnc0al                   ; test dal¨¡ho sektoru
         pop       cx
         pop       es

; ------ test, zda je prvn¡ sektor nejni‘¨¡

Fnc0an:  push      es
         mov       es,RegES                 ; segment s bufferem
         mov       si,RegBX                 ; offset bufferu
         cmp       dh,es:[si+2]             ; je prvn¡ sektor nejni‘¨¡ ?
         pop       es
         je        Fnc0ak                   ; sektor je nejni‘¨¡

; ------ rotace sektor– o jeden sektor dol–

         push      es
         push      cx
         push      dx

         dec       cx                       ; sn¡‘en¡ o 1
         add       cx,cx
         add       cx,cx                    ; po‡et polo‘ek * 4

         mov       es,RegES                 ; segment s bufferem
         mov       si,RegBX                 ; offset bufferu

         mov       dx,es:[si]               ; £schova prvn¡ polo‘ky
         mov       di,es:[si+2]

Fnc0ao:  mov       al,es:[si+4]
         mov       es:[si],al
         inc       si
         loop      Fnc0ao

         mov       es:[si],dx
         mov       es:[si+2],di

         pop       dx
         pop       cx
         pop       es
         jmp       short Fnc0an             ; test nov‚ho stavu

Fnc0ak:  xor       ah,ah                    ; p©¡znak - operace OK
Fnc0af:  ret

Funkce0a ENDP

; -----------------------------------------------------------------------------
;        Funkce 0ch - vystaven¡ na v lec
; -----------------------------------------------------------------------------

PUBLIC   Funkce0c
Funkce0c PROC      NEAR

         mov       RegAL,0                  ; p©ednastaven¡ - nen¡ stopa 0

; ------ kontrola platnosti zad n¡ disku - zda je mechanika nainstalovan 

         call      GetStat                  ; poskytnut¡ stavov‚ho bajtu disku
         mov       ax,8000h                 ; chyba - disk nep©ipraven
         jz        Fnc0c2                   ; mechanika nen¡ definovan  - chyba

; ------ test, zda je pouze dotaz na aktu ln¡ stopu

         xor       ah,ah                    ; n vratov˜ k¢d - OK
         cmp       RegCH,0ffh               ; je jenom dotaz na stopu ?
         je        Fnc0c1                   ; nen¡ jenom dotaz na stopu

; ------ zapnut¡ motoru

         call      MotorOn

; ------ vystaven¡ na po‘adovan˜ v lec

         mov       al,RegCH                 ; po‘adovan˜ v lec
         call      Seek                     ; vystaven¡ na po‘adovan˜ v lec
         jnz       Fnc0c1                   ; byla chyba vystaven¡

; ------ test, zda je dosa‘eno stopy 0

         call      DrivStat                 ; poskytnut¡ stavov‚ho bajtu disku
         jnz       Fnc0c1                   ; chyba operace
         test      al,10h                   ; bylo dosa‘eno stopy 0 ?
         jz        Fnc0c1                   ; stopa 0 nenalezena - dal¨¡
         mov       RegAL,0ffh               ; p©¡znak dosa‘en¡ stopy 0

; ------ poskytnut¡ aktu ln¡ho v lce

Fnc0c1:  call      GetSeek                  ; poskytnut¡ aktu ln¡ho v lce
Fnc0c2:  mov       RegCH,al                 ; navr cen¡ aktu ln¡ho v lce
         ret

Funkce0c ENDP

; -----------------------------------------------------------------------------
;        Funkce 10h - test p©ipravenosti disku
; -----------------------------------------------------------------------------

PUBLIC   Funkce10
Funkce10 PROC      NEAR

         mov       RegAL,11011000b          ; p©ednastaven¡ stavu

; ------ kontrola platnosti zad n¡ disku - zda je mechanika nainstalovan 

         call      GetStat                  ; poskytnut¡ stavov‚ho bajtu disku
         mov       ah,80h                   ; chyba - disk nep©ipraven
         jz        Fnc101                   ; mechanika nen¡ definovan  - chyba

; ------ zapnut¡ motoru

         call      MotorOn

; ------ test p©ipravenosti disku

         call      DrivStat                 ; poskytnut¡ stavov‚ho bajtu disku
         jnz       Fnc101                   ; disk nen¡ p©ipraven
         mov       cl,al                    ; £schova stavov‚ho bajtu
         and       cl,not 8                 ; nulov n¡ bitu 3
         call      ReadChng                 ; ‡ten¡ sign lu v˜mˆny
         jz        Fnc102                   ; sign l v˜mˆny nen¡ aktivn¡
         or        cl,8                     ; nastaven¡ p©¡znaku v˜mˆny
Fnc102:  mov       RegAL,cl                 ; stavov˜ bajt diskov‚ jednotky
         test      cl,20h                   ; je disketov  jednotka p©ipravena ?
         jnz       Fnc101                   ; disketov  jednotka je p©ipravena
         mov       ah,80h                   ; p©¡znak nep©ipravenosti disku

Fnc101:  ret

Funkce10 ENDP

; -----------------------------------------------------------------------------
;        Funkce 15h - poskytnut¡ typu disku
; -----------------------------------------------------------------------------

PUBLIC   Funkce15
Funkce15 PROC      NEAR

         call      GetStat                  ; poskytnut¡ stavov‚ho bajtu disku
         jz        Fnc151                   ; disk nen¡ definov n
         and       al,1                     ; p©¡znak 80 stop
         inc       al                       ; p©¡znak indikace v˜mˆny + 1
Fnc151:  mov       ah,al
         ret

Funkce15 ENDP

; -----------------------------------------------------------------------------
;        Funkce 16h - test v˜mˆny m‚dia
; -----------------------------------------------------------------------------

PUBLIC   Funkce16
Funkce16 PROC      NEAR

; ------ zji¨tˆn¡, zda je disk definov n

         mov       ah,80h                   ; p©ednastaven¡ chyby - nen¡ disk
         call      GetStat                  ; poskytnut¡ stavov‚ho bajtu disku
         jz        Fnc161                   ; disk nen¡ definov n

; ------ test, zda m  disk indikaci v˜mˆny m‚dia

         mov       ah,6                     ; p©ednastaven¡ chyby - je v˜mˆna
         test      al,1                     ; je indikace v˜mˆny m‚dia ?
         jz        Fnc161                   ; disk nem  indikaci v˜mˆny m‚dia

; ------ zapnut¡ motoru a test, zda bylo m‚dium vymˆnˆno

         call      MotorOn                  ; zapnut¡ motoru
         call      ReadChng                 ; ‡ten¡ sign lu v˜mˆny m‚dia
         mov       ah,6
         jnz       Fnc161                   ; m‚dium bylo vymˆnˆno
         xor       ah,ah                    ; p©¡znak, ‘e m‚dium nebylo vymˆnˆno
Fnc161:  ret

Funkce16 ENDP

; -----------------------------------------------------------------------------
;        Funkce 17h - nastaven¡ typu disku pro form tov n¡
; -----------------------------------------------------------------------------

PUBLIC   Funkce17
Funkce17 PROC      NEAR

; ------ p©¡pad, ‘e je disk 360 KB v mechanice 360 KB

         cmp       RegAL,1                  ; zad n disk 360K v mechanice 360K ?
         jne       Fnc171                   ; nen¡ disk 360K v mechanice 360K
         xor       ah,ah                    ; p©¡znak operace OK
         mov       cl,90h                   ; rychlost 250 k/s
         jmp       short Fnc176             ; nastaven¡ rychlosti

; ------ test v˜mˆny m‚dia

Fnc171:  call      MedChng                  ; obsluha v˜mˆny m‚dia
         jz        Fnc172                   ; m‚dium nebylo vymˆnˆno
         xor       cl,cl                    ; rychlost 500 k/s
         jmp       short Fnc176             ; nastaven¡ rychlosti

; ------ kontrola zad n¡ typu DASD

Fnc172:  xor       dx,dx                    ; DX <- 0
         or        dl,RegAL                 ; po‘adovan˜ typ DASD
         jz        Fnc173                   ; chybn‚ zad n¡ typu (=0)
         cmp       dl,4                     ; kontrola maxim ln¡ velikosti DASD
         jbe       Fnc174                   ; spr vn˜ typ DASD

; ------ chybn‚ zad n¡ typu DASD

Fnc173:  mov       ah,1                     ; chyba - neplatn˜ povel
         xor       cl,cl                    ; rychlost 500 k/s
         jmp       short Fnc176             ; nastaven¡ rychlosti

; ------ zad n typ 720K (rozli¨en¡ mechaniky 5 1/4" nebo 3 1/2")

Fnc174:  jne       Fnc175                   ; nen¡ zad n typ 720K v 720K
         call      GetTyp                   ; poskytnut¡ typu mechaniky
         cmp       al,2                     ; je mechanika 1.2 MB ?
         jne       Fnc175                   ; nen¡ mechanika 1.2 MB
;         call      GetStat                  ; poskytnut¡ stavov‚ho bajtu disku
;         and       al,6                     ; p©¡znak v¡ce rychlost¡
;         cmp       al,6                     ; je mo‘n‚ v¡ce rychlost¡ ?
;         jne       Fnc175                   ; nen¡ mo‘n‚ v¡ce rychlost¡
         inc       dl                       ; je typ 5 - mechanika 5 1/4" HD

; ------ zji¨tˆn¡ p©enos. rychlosti z tabulky

Fnc175:  mov       di,dx                    ; typ disku
         and       di,7                     ; typ disku
         mov       cl,ds:[TabDASD+di]       ; typ z tabulky DASD

; ------ nastaven¡ p©enosov‚ rychlosti

Fnc176:  call      GetMed                   ; poskytnut¡ bajtu stavu m‚dia
         and       al,0fh                   ; nulov n¡ rychlosti a p©¡znak– typu
         or        al,cl                    ; nastaven¡ rychlosti a typu
         call      SetMed                   ; nastaven¡ bajtu stavu m‚dia
         ret

Funkce17 ENDP

TabDASD  db        0                        ; (0 - nepovolen˜ typ)
         db        0                        ; (1 - 360K/360K (90h); 250k/s)
         db        70h                      ; 2 - 360K/1.2M; 300k/s (2-krok.)
         db        10h                      ; 3 - 1.2M/1.2M, 1.44M/1.44M; 500k/s
         db        90h                      ; 4 - 720K/720K, 720K/1.44M; 250k/s
         db        50h                      ; 5 - 720K/1.2M; 300k/s

; -----------------------------------------------------------------------------
;        Funkce 18h - nastaven¡ typu m‚dia pro form tov n¡
; -----------------------------------------------------------------------------

PUBLIC   Funkce18
Funkce18 PROC      NEAR

; ------ kontrola, zda je disk definov n

         call      GetStat                  ; poskytnut¡ stavov‚ho bajtu disku
         jz        Fnc186                   ; disk nen¡ instalov n

; ------ kontrola, zda m‚dium nebylo vymˆnˆno

         test      al,1                     ; je mechanika 80 stop ?
         jz        Fnc181                   ; je mechanika 40 stop
         call      MedChng                  ; obsluha v˜mˆny m‚dia
         jz        Fnc181                   ; disketa nebyla vymˆnˆna
         cmp       ah,6                     ; m‚dium bylo vymˆnˆno ?
         je        Fnc181                   ; m‚dium vymˆnˆno - OK
         jmp       short Fnc187             ; chyba, pokud disketa byla vymˆnˆna

; ------ zji¨tˆn¡ tabulky podle typu

Fnc181:  call      GetTyp                   ; poskytnut¡ typu disku AL
         jz        Fnc186                   ; nen¡ ‘ dn˜ disk
         cmp       al,2                     ; je mechanika 1.2 MB ?
         jne       Fnc182                   ; nen¡ mechanika 1.2 MB
         cmp       RegCX,4f09h              ; po‘aduje se 720 KB ?
         mov       si,offset Disk7          ; tabulka pro 720 KB v 1.2 MB
         je        Fnc184                   ; je 720 KB v 1.2 MB
Fnc182:  call      GetTab                   ; ur‡en¡ tabulky disku podle typu

; ------ kontrola, zda byla nalezena platn  tabulka

Fnc183:  mov       cl,ds:[si+4]             ; posledn¡ sektor na stopˆ
         mov       ch,ds:[si+11]            ; posledn¡ stopa
         cmp       cx,RegCX                 ; kontrola zadan˜ch parametr–
         je        Fnc184                   ; nalezena platn  tabulka parametr–

; ------ nen¡ platn  tabulka - p©¡padn˜ druh˜ pokus

         test      al,1                     ; je ji‘ prvn¡ typ disku
         jnz       Fnc188                   ; nen¡ povolen˜ dal¨¡ form t
         dec       al                       ; dal¨¡ povolen˜ form t
         add       si,0dh                   ; dal¨¡ tabulka
         jmp       short Fnc183             ; test dal¨¡ tabulky

; ------ nastaven¡ parametr– podle tabulky

Fnc184:  mov       al,ds:[si+12]            ; p©enosov  rychlost
         cmp       al,40h                   ; rychlost 300 K/s ?
         jne       Fnc185                   ; nen¡ rychlost 300 k/s
         cmp       si,offset Disk7          ; je 720 KB v 1.2 MB ?
         je        Fnc185                   ; je 720 KB v 1.2 MB
         or        al,20h                   ; p©¡znak dvoj¡ho krokov n¡
Fnc185:  or        al,10h                   ; p©¡znak ur‡en¡ m‚dia
         call      SetMed                   ; nastaven¡ bajtu stavu m‚dia

; ------ nastaven¡ ukazatele na tabulku

         mov       RegDI,si
         mov       RegES,cs

Fnc186:  xor       ax,ax
Fnc187:  ret

; ------ chyba - typ m‚dia nenalezen

Fnc188:  mov       ah,0ch
         ret

Funkce18 ENDP

; -----------------------------------------------------------------------------
;        Konverze nov‚ho m¢du na star˜
; -----------------------------------------------------------------------------
; VSTUP: BL=‡¡slo disku
;        ES=0
;        DS=CS
; -----------------------------------------------------------------------------

PUBLIC   XlatOld
XlatOld  PROC      NEAR

         push      ax
         push      cx
         push      si
         mov       ch,7                     ; stav - jin˜ typ m‚dia

; ------ p©ednastaven¡ p©¡znaku 80 stop

         call      GetStat                  ; poskytnut¡ bajtu stavu disku
         and       al,1                     ; p©¡znak mechaniky 80 stop
         mov       cl,al                    ; p©¡znak mechaniky 80 stop

; ------ rozli¨en¡ podle p©enosov‚ rychlosti

         call      GetMed                   ; poskytnut¡ bajtu stavu m‚dia
         and       al,0c0h                  ; p©enosov  rychlost
         jz        XlatOld2                 ; je disketa HD (rychlost 500 k/s)
         cmp       al,80h                   ; je rychlost 250 k/s ?
         ja        XlatOld3                 ; chyba - nezn m˜ disk
         je        XlatOld1                 ; je rychlost 250 k/s
         or        cl,8                     ; p©¡znak rychlosti 300 k/s

; ------ konverze typu podle detekovan˜ch p©¡znak–

XlatOld1:call      GetMed                   ; poskytnut¡ bajtu stavu m‚dia
         shr       al,1
         shr       al,1
         shr       al,1
         and       al,6                     ; p©¡znak dvoj. krok. a zn m‚ m‚dium
         or        cl,al
         mov       si,cx                    ; p©¡znaky
         and       si,0fh                   ; maska p©¡znak–
         mov       ch,ds:[TabXlat+si]       ; konverze
         jmp       short XlatOld3           ; nastaven¡ nov‚ho typu m‚dia

; ------ p©enosov  rychlost 500 k/s - je disketa HD

XlatOld2:call      GetTyp                   ; poskytnut¡ typu disku AL
         cmp       al,2                     ; mechanika 1.2 MB ?
         jne       XlatOld3                 ; nen¡ 1.2 MB
         mov       ch,2                     ; disketa 1.2 MB v 1.2 MB nezaved.
         call      GetMed                   ; poskytnut¡ bajtu stavu m‚dia
         test      al,10h                   ; je m‚dium zn m‚ ?
         jz        XlatOld3                 ; m‚dium nen¡ zn m‚
         mov       ch,5                     ; disketa 1.2 MB v 1.2 MB zaved.

; ------ nastaven¡ nov‚ho typu m‚dia

XlatOld3:call      GetMed                   ; poskytnut¡ bajtu stavu m‚dia
         and       al,0f8h                  ; zru¨en¡ star‚ho typu m‚dia
         or        al,ch                    ; nastaven¡ typu m‚dia
         call      SetMed                   ; nastaven¡ stavov‚ho bajtu m‚dia
         pop       si
         pop       cx
         pop       ax
         ret

XlatOld  ENDP


TabXlat  label     byte                   ;* mechaniky 300 ot/min

                                          ;* 360K v 360K nezaveden‚
         db        0                        ; 0 40 stop; m‚dium nezn m‚; 1 krok
         db        7                        ; 1 80 stop; m‚dium nezn m‚; 1 krok

                                          ;* 360K v 360K zaveden‚
         db        3                        ; 2 40 stop; m‚dium zn m‚; 1 krok
         db        7                        ; 3 80 stop; m‚dium zn m‚; 1 krok

                                          ;* 360K v 360K nezaveden‚, 2-kroky
         db        0                        ; 4 40 stop; m‚dium nezn m‚; 2 kroky
         db        7                        ; 5 80 stop; m‚dium nezn m‚; 2 kroky

                                          ;* 360K v 360K nezaveden‚, 2-kroky
         db        3                        ; 6 40 stop; m‚dium zn m‚; 2 kroky
         db        7                        ; 7 80 stop; m‚dium zn m‚; 2 kroky

                                          ;* mechaniky 360 ot/min
         db        7                        ; 8  40 stop; m‚dium nezn m‚; 1 krok
         db        7                        ; 9  80 stop; m‚dium nezn m‚; 1 krok
         db        7                        ; 10 40 stop; m‚dium zn m‚; 1 krok
         db        7                        ; 11 80 stop; m‚dium zn m‚; 1 krok

                                          ;* 360K v 1.2M nezaveden‚
         db        1                        ; 12 40 stop; m‚d. nezn m‚; 2 kroky

                                          ;* 360K v 1.2M nezaveden‚
         db        1                        ; 13 80 stop; m‚d. nezn m‚; 2 kroky

         db        4                        ; 14 40 stop; m‚dium zn m‚; 2 kroky
         db        4                        ; 15 80 stop; m‚dium zn m‚; 2 kroky


; -----------------------------------------------------------------------------
;        Ur‡en¡ po‡tu p©enesen˜ch sektor–
; -----------------------------------------------------------------------------
; VSTUP: BL=‡¡slo disku
;        CL=po‡ te‡n¡ sektor
;        CH=po‡ te‡n¡ v lec
;        DH=po‡ te‡n¡ strana
;        ES=0
;        DS=CS
; VSTUP:AL=po‡et p©enesen˜ch sektor–
; Zni‡en‚ registry: AH
; -----------------------------------------------------------------------------

PUBLIC   NumTrans
NumTrans PROC      NEAR

; ------ posledn¡ p©enesen˜ sektor

         mov       al,5                     ; parametr 5 - posledn¡ sektor
         call      GetRes                   ; poskytnut¡ posledn¡ho sektoru
         mov       ah,al                    ; posledn¡ p©enesen˜ sektor

; ------ test, zda byla zmˆnˆna strana

         mov       al,4                     ; parametr 4 - posledn¡ strana
         call      GetRes                   ; poskytnut¡ posledn¡ strany
         cmp       al,dh                    ; byla zmˆnˆna strana ?
         jne       NumTrns1                 ; byla zmˆnˆna strana

; ------ test, zda byla zmˆnˆna stopa

         mov       al,3                     ; parametr 3 - posledn¡ stopa
         call      GetRes                   ; poskytnut¡ posledn¡ stopy
         cmp       al,ch                    ; byla zmˆnˆna stopa ?
         je        NumTrns2                 ; ani stopa nebyla zmˆnˆna

; ------ p©i‡ten¡ sektor– z cel‚ stopy (2x), pokud byla zmˆnˆna stopa

         mov       al,4                     ; param. 4 - po‡et sektor– na stopu
         call      GetPar                   ; poskytnut¡ parametru 4
         add       ah,al                    ; p©i‡ten¡ sektor– pro dal¨¡ stopu

; ------ p©i‡ten¡ sektor– z cel‚ stopy, pokud byla zmˆnˆna strana

NumTrns1:mov       al,4                     ; param. 4 - po‡et sektor– na stopu
         call      GetPar                   ; poskytnut¡ parametru 4
         add       ah,al                    ; p©i‡ten¡ sektor– pro dal¨¡ stranu

; ------ ode‡ten¡ po‡ te‡n¡ho sektoru

NumTrns2:sub       ah,cl                    ; ode‡ten¡ po‡ te‡n¡ho sektoru
         mov       al,ah                    ; po‡et p©enesen˜ch sektor–
         ret

NumTrans ENDP

; -----------------------------------------------------------------------------
;        Nastaven¡ kan lu DMA (pou‘¡v  se kan l ‡¡slo 2)
; -----------------------------------------------------------------------------
; VSTUP: (BL=‡¡slo disku)
;        AL=povel pro DMA (46h=‡ten¡, 4ah=z pis, 42h=verifikace)
;        SS:SI=ukazatel parametr– v z sobn¡ku (adresa DMA a po‡et bajt–)
;        ES=0
;        DS=CS
; VSTUP:AH=n vratov˜ chybov˜ k¢d (9=chyba p©ekro‡en¡ hranice 64K)
;        ZY=operace OK (AH=0), NZ=chyba operace (AH=9)
; Zni‡en‚ registry: AL
; -----------------------------------------------------------------------------

PUBLIC   SetDma
SetDma   PROC      NEAR

         push      cx

; ------ nastaven¡ povelu pro DMA

         cli                                ; z kaz p©eru¨en¡
         out       [0ch],al                 ; nastaven¡ p©¡znaku n slednosti DMA
         jmp       short $+2                ; prodleva
         out       [0bh],al                 ; nastaven¡ povelu pro DMA

; ------ v˜po‡et adresy pro p©enos DMA

         mov       ax,ss:[si+2]             ; segment adresy
         mov       ch,ah                    ; vy¨¨¡ bajt segmentu adresy
         mov       cl,4                     ; po‡et rotac¡
         shl       ax,cl                    ; segment * 16 -> offset
         shr       ch,cl                    ; vy¨¨¡ 4 bity segmentu
         xor       cl,cl                    ; CL <- 0
         xchg      cl,ch                    ; CX = nejvy¨¨¡ bajt adresy
         add       ax,ss:[si]               ; p©i‡ten¡ offsetu adresy
         adc       cl,ch                    ; p©enos do vy¨¨¡ch 4 bit– adresy

; ------ nastaven¡ adresy pro p©enos DMA (kan l 2)

         out       [4],al                   ; vysl n¡ ni‘¨¡ho bajtu adresy
         xchg      al,ah                    ; AL <- vy¨¨¡ bajt adresy
         jmp       short $+2                ; prodleva
         out       [4],al                   ; vysl n¡ vy¨¨¡ho bajtu adresy
         jmp       short $+2                ; prodleva
         xchg      al,ah                    ; n vrat adresy
         xchg      ax,cx                    ; AX<-vy¨¨¡ bajt, CX<-ni‘¨¡ slovo
         out       [81h],al                 ; nastaven¡ str nkov‚ho registru
         jmp       short $+2                ; prodleva

; ------ nastaven¡ po‡tu bajt– k p©enosu

         mov       ax,ss:[si+4]             ; po‡et bajt– k p©enosu
         out       [5],al                   ; ni‘¨¡ slovo po‡tu bajt–
         mov       al,ah                    ; vy¨¨¡ slovo po‡tu bajt–
         jmp       short $+2                ; prodleva
         out       [5],al                   ; vy¨¨¡ slovo po‡tu bajt–

; ------ volba kan lu pro p©enos DMA

         mov       al,2                     ; kan l 2
         out       [0ah],al                 ; volba kan lu DMA 2
         sti                                ; povolen¡ p©eru¨en¡

; ------ kontrola p©ekro‡en¡ hranice 64K

         mov       ah,9                     ; chyba p©ekro‡en¡ hranice 64K
         add       cx,ss:[si+4]             ; kontrola p©ekro‡en¡ hranice 64K
         jc        SetDMA1                  ; bylo p©ekro‡en¡ hranice 64K
         xor       ah,ah                    ; p©¡znak operace OK

SetDMA1: or        ah,ah                    ; nastaven¡ p©¡znaky chyby ZF
         pop       cx
         ret

SetDma   ENDP

; *****************************************************************************
;        Vystavov n¡ hlav
; *****************************************************************************

; -----------------------------------------------------------------------------
;        Resetov n¡ diskov‚ho syst‚mu
; -----------------------------------------------------------------------------
; VSTUP: BL=‡¡slo disku
;        ES=0
;        DS=CS
; VSTUP:AH=n vratov˜ chybov˜ k¢d
;        ZY=operace OK (AH=0), NZ=chyba operace (AH nen¡ 0)
; Zni‡en‚ registry: AL, CX, DX, SI
; -----------------------------------------------------------------------------

PUBLIC   DiskRes
DiskRes  PROC      NEAR

; ------ nulov n¡ p©¡znak– proveden‚ rekalibrace

         xor       al,al                    ; nulov n¡ p©¡znak– rekalibrace
         call      SetRec                   ; nastaven¡ bajtu p©¡znak– rekalib.

; ------ vysl n¡ sign lu RESET

         cli                                ; z kaz p©eru¨en¡
         call      GetMot                   ; poskytnut¡ bajtu stavu motor–
         rol       al,1
         rol       al,1
         rol       al,1
         rol       al,1                     ; rotace na spr vnou pozici
         and       al,not 4                 ; nastaven¡ sign lu RESET
         or        al,8                     ; povolen¡ p©eru¨en¡ a DMA
         call      GetPrt2                  ; adresa ©¡dic¡ho portu ©adi‡e
         out       dx,al                    ; vysl n¡ sign lu RESET

; ------ prodleva pro p©¡jem povelu RESET ©adi‡e

         jmp       short $+2
         jmp       short $+2
         jmp       short $+2
         jmp       short $+2                ; prodleva pro povel RESET

; ------ ukon‡en¡ sign lu RESET

         or        al,4                     ; vypnut¡ sign lu RESET
         out       dx,al                    ; ukon‡en¡ sign lu RESET
         sti                                ; povolen¡ p©eru¨en¡

; ------ kontrola v˜sledku operace

         call      ChkStat                  ; kontrola v˜sledku operace resetu
         xor       al,al                    ; parametr 0 - registr ST0
         call      GetRes                   ; poskytnut¡ parametru 0 - ST0
         mov       ah,20h                   ; k¢d chyby - chyba ©adi‡e
         cmp       al,0c0h                  ; spr vn˜ v˜sledek operace (ST0) ?
         jne       DiskRes2                 ; chyba resetov n¡ ©adi‡e

; ------ vysl n¡ povelu SPECIFY

         mov       al,1                     ; parametr 1 - spu¨tˆn¡ p©¡tlaku
         call      GetPar                   ; poskytnut¡ parametru 1
         mov       ah,al                    ; parametr 1 - spu¨tˆn¡ p©¡tlaku
         xor       al,al                    ; parametr 0 - rychlost krokov n¡
         call      GetPar                   ; poskytnut¡ parametru 0
         push      ax                       ; parametry pro povel SPECIFY
         mov       si,sp                    ; ukazatel prametr– v z sobn¡ku
         mov       al,3                     ; povel 3 - SPECIFY
         mov       ah,3                     ; celkov˜ po‡et bajt– = 3
         call      NECOutp                  ; vysl n¡ parametr– na ©adi‡
         add       sp,2                     ; zru¨en¡ dat v z sobn¡ku

DiskRes2:or        ah,ah                    ; nastaven¡ p©¡znaku ZF
         ret

DiskRes  ENDP

; -----------------------------------------------------------------------------
;        Vystaven¡ mechaniky BL na stopu AL
; -----------------------------------------------------------------------------
; VSTUP: BL=‡¡slo disku
;        AL=po‘adovan  stopa
;        ES=0
;        DS=CS
; VSTUP:AH=n vratov˜ chybov˜ k¢d
;        ZY=operace OK (AH=0), NZ=chyba operace (AH nen¡ 0)
; Zni‡en‚ registry: AL, SI
; -----------------------------------------------------------------------------

PUBLIC   Seek
Seek     PROC      NEAR

         push      dx
         mov       dh,al                    ; po‘adovan  stopa

; ------ test, zda se vy‘aduje rekalibrace

         mov       ah,bl                    ; disk
         and       ah,1                     ; disk 0 nebo 1
         mov       dl,ah                    ; £schova ‡¡sla disku
         inc       ah                       ; maska rekalibrace (1 nebo 2)
         call      GetRec                   ; poskytnut¡ bajtu rekalibrace
         test      al,ah                    ; vy‘aduje se rekalibrace ?
         jnz       Seek2                    ; rekalibrace se nevy‘aduje

; ------ provede se rekalibrace disku

         or        al,ah                    ; nastaven¡ p©¡znaku rekalibrace
         call      SetRec                   ; nastaven¡ bajtu rekalibrace
         xor       al,al                    ; nov  stopa = 0
         call      SetSeek                  ; nastaven¡ nov‚ stopy
         mov       cx,2                     ; po‡et pokus– = 2

; ------ vysl n¡ povelu pro rekalibraci disku

Seek1:   push      dx                       ; disk pro rekalibraci
         mov       si,sp                    ; ukazatel dat v z sobn¡ku
         mov       al,7                     ; povel 7 - rekalibrace
         mov       ah,2                     ; po‡et bajt– = 2
         call      NECOutp                  ; vysl n¡ povelu na ©adi‡
         pop       dx                       ; n vrat disku pro rekalibraci
         jnz       Seek5                    ; byla chyba ©adi‡e

; ------ kontrola v˜sledku rekalibrace - u mechanik 80 stop opakov n¡

         call      ChkStat                  ; kontrola v˜sledku operace
         loopnz    Seek1                    ; chyba - dal¨¡ pokus pro 80 stop
         jnz       Seek5                    ; byla chyba operace

; ------ po rekalibraci jsou hlavy nastaveny na 0 - p©i stopˆ 0 konec operace

         or        dh,dh                    ; byla stopa 0 ?
         jz        Seek6                    ; byla stopa 0-ji‘ jen ust len¡ hlav

; ------ zdvojen¡ kroku pro disketu 360 KB

Seek2:   call      GetMed                   ; poskytnut¡ bajtu stavu m‚dia
         test      al,20h                   ; m  b˜t dvoj¡ krokov n¡ ?
         jz        Seek3                    ; nen¡ dvoj¡ krokov n¡
         shl       dh,1                     ; zdvojen¡ ‡¡sla stopy

; ------ test, zda je stopa ji‘ nastaven 

Seek3:   call      GetSeek                  ; poskytnut¡ aktu ln¡ stopy
         cmp       al,dh                    ; je stopa ji‘ nastavena ?
         je        Seek4                    ; stopa je ji‘ nastavena
         mov       al,dh                    ; nov  po‘adovan  stopa
         call      SetSeek                  ; nastaven¡ nov‚ stopy

; ------ vysl n¡ povelu pro vystaven¡ na zadanou stopu

         push      dx                       ; po‘adovan  stopa a disk
         mov       si,sp                    ; ukazatel dat v z sobn¡ku
         mov       al,0fh                   ; povel pro vystaven¡ hlav SEEK
         mov       ah,3                     ; po‡et bajt– povelu
         call      NECOutp                  ; vysl n¡ povelu na ©adi‡
         pop       dx                       ; n vrat po‘adovan‚ stopy a disku
         jnz       Seek5                    ; chyba vystaven¡

; ------ kontrola operace vystaven¡

         call      ChkStat                  ; kontrola v˜sledku operace
         jnz       Seek5                    ; byla chyba vystaven¡

; ------ ‡ek n¡ na ust len¡ hlav

Seek6:   call      HdWait                   ; ‡ek n¡ na ust len¡ hlav
Seek4:   xor       ah,ah                    ; p©¡znak - operace OK
Seek5:   or        ah,ah                    ; nastaven¡ p©¡znaku ZF
         pop       dx
         ret

Seek     ENDP

; -----------------------------------------------------------------------------
;        €ek n¡ na ust len¡ hlav po vystaven¡
; -----------------------------------------------------------------------------
; VSTUP: BL=‡¡slo disku
;        ES=0
;        DS=CS
; -----------------------------------------------------------------------------

PUBLIC   HdWait
HdWait   PROC      NEAR

         push      ax

; ------ zji¨tˆn¡ doby pro ust len¡ hlav

         mov       al,9                     ; parametr 9 - doba pro ust len¡
         call      GetPar                   ; poskytnut¡ parametru 9
         or        al,al                    ; je parametr definovan˜ ?
         jnz       HdWait1                  ; parametr je definovan˜

; ------ doba ‡ek n¡ nedefinovan  (je = 0) - automatick‚ ur‡en¡ minim. doby

         call      TestWr                   ; test, zda je operace z pis
         jz        HdWait2                  ; je operace ‡ten¡ - nemus¡ se ‡ekat
         call      GetMed                   ; poskytnut¡ bajtu stavu m‚dia
         or        al,al                    ; je mechanika 300 ot/min ?
         mov       al,20                    ; doba pro ust len¡ mech. 360 KB
         js        HdWait1                  ; je mechanika 300 ot/min
         mov       al,15                    ; doba pro mechaniku HD 1.2 MB

; ------ ‡ek n¡ na ust len¡ hlav po dobu AL milisekund

HdWait1: mov       ah,33                    ; po‡et cykl– 30 us pro dobu 1 ms
         mul       ah                       ; v˜po‡et ‡ekac¡ doby (AX)
         call      WaitT                    ; nepodm¡nˆn‚ ‡ek n¡

HdWait2: pop       ax
         ret

HdWait   ENDP





; *****************************************************************************
;        Ovl d n¡ povel– ©adi‡e
; *****************************************************************************

; -----------------------------------------------------------------------------
;        Zji¨tˆn¡ stavov‚ho bajtu disku ST3
; -----------------------------------------------------------------------------
; VSTUP: BL=‡¡slo disku
;        ES=0
;        DS=CS
; VSTUP:AH=n vratov˜ chybov˜ k¢d
;        AL=stavov˜ bajt disku ST3
;        ZY=operace OK (AH=0), NZ=chyba operace (AH nen¡ 0)
; -----------------------------------------------------------------------------

PUBLIC   DrivStat
DrivStat PROC      NEAR

         push      cx

; ------ vysl n¡ povelu SENSE DRIVE STATUS

         mov       cl,bl                    ; po‘adovan˜ disk
         and       cl,1                     ; disk relativnˆ (0 nebo 1)
         push      cx                       ; po‘adovan˜ disk
         mov       si,sp                    ; ukazatel dat v z sobn¡ku
         mov       al,4                     ; povel SENSE DRIVE STATUS
         mov       ah,2                     ; po‡et bajt–
         call      NECOutp                  ; vysl n¡ povelu SENSE DRIVE STATUS
         pop       cx                       ; n vrat po‘adovan‚ho disku
         jnz       DrivSt1                  ; chyba operace

; ------ navr cen¡ stavov‚ho registru ST3

         call      Result                   ; p©¡jem v˜sledku operace
         jnz       DrivSt1                  ; byla chyba operace
         xor       al,al                    ; parametr 0 - registr ST3
         call      GetRes                   ; poskytnut¡ registru 3

DrivSt1: or        ah,ah
         pop       cx
         ret

DrivStat ENDP

; -----------------------------------------------------------------------------
;        Kontrola v˜sledku operace vystaven¡, rekalibrace, resetu
; -----------------------------------------------------------------------------
; VSTUP: BL=‡¡slo disku
;        ES=0
;        DS=CS
; VSTUP:AH=n vratov˜ chybov˜ k¢d
;        ZY=operace OK (AH=0), NZ=chyba operace (AH nen¡ 0)
; Zni‡en‚ registry: AL
; -----------------------------------------------------------------------------

PUBLIC   ChkStat
ChkStat  PROC      NEAR

; ------ ‡ek n¡ na p©eru¨en¡ od ©adi‡e

         call      WaitInt                  ; ‡ek n¡ na p©eru¨en¡ od ©adi‡e
         jnz       ChkStat1                 ; byla chyba TIME-OUT

; ------ vysl n¡ povelu SENSE INTERRUPT STATUS

         mov       al,8                     ; povel SENSE INTERRUPT STATUS
         mov       ah,1                     ; po‡et bajt– k vysl n¡ = 1
         call      NECOutp                  ; vysl n¡ povelu SENSE INTERRUPT ...
         jnz       ChkStat1                 ; byla chyba operace

; ------ p©¡jem v˜sledku operace od ©adi‡e

         call      Result                   ; p©¡jem v˜sledku operace od ©adi‡e
         jnz       ChkStat1                 ; byla chyba ©adi‡e

; ------ kontrola navr cen‚ho stavov‚ho bajtu ST0

         xor       al,al                    ; AH <- 0 offset bajtu ST0
         call      GetRes                   ; poskytnut¡ stavov‚ho bajtu ST0
         and       al,01100000b             ; kontrolovan‚ bity
         cmp       al,01100000b             ; je chyba vystaven¡ ?
         mov       ah,40h                   ; chyba vystaven¡
         je        ChkStat1                 ; byla chyba vystaven¡
         xor       ah,ah                    ; operace probˆhla OK

ChkStat1:or        ah,ah                    ; nastaven¡ p©¡znaku ZF
         ret

ChkStat  ENDP



; -----------------------------------------------------------------------------
;        €ek n¡ na proveden¡ operace ‡ten¡/z pis/verifikace
; -----------------------------------------------------------------------------
; VSTUP: BL=‡¡slo disku
;        ES=0
;        DS=CS
; VSTUP:AH=n vratov˜ chybov˜ k¢d
;        ZY=operace OK (AH=0), NZ=chyba operace (AH nen¡ 0)
; Zni‡en‚ registry: AL
; -----------------------------------------------------------------------------

PUBLIC   NECWait
NECWait  PROC      NEAR

         call      WaitInt                  ; ‡ek n¡ na p©eru¨en¡ od ©adi‡e
         push      ax                       ; £schova navr cen‚ho k¢du chyby
         call      Result                   ; p©¡jem v˜sledku operace
         mov       cl,ah                    ; £schova k¢du chyby
         pop       ax                       ; n vrat chyby z WaitInt
         or        ah,ah                    ; byla chyba ‡ek n¡ na p©eru¨en¡ ?
         jnz       NECWait1                 ; byla chyba ‡ek n¡ na p©eru¨en¡
         or        ah,cl                    ; byla chyba p©¡jmu v˜sledku ?
         jnz       NECWait1                 ; byla chyba p©¡jmu v˜sledku
         call      ErrCode                  ; sestaven¡ chybov‚ho k¢du
NECWait1:ret

NECWait  ENDP


; -----------------------------------------------------------------------------
;        Sestaven¡ k¢du chyby
; -----------------------------------------------------------------------------
; VSTUP: BL=‡¡slo disku
;        DS=CS
;        ES=0
; VSTUP:AH=n vratov˜ chybov˜ k¢d
;        ZY=operace OK (AH=0), NZ=chyba operace (AH nen¡ 0)
; Zni‡en‚ registry: AL
; -----------------------------------------------------------------------------

PUBLIC   ErrCode
ErrCode  PROC      NEAR

; ------ test, zda je nˆjak  chyba

         xor       al,al                    ; AL <- 0 (offset bajtu 0)
         call      GetRes                   ; poskytnut¡ stavov‚ho bajtu ST0
         and       al,0c0h                  ; je nˆjak  chyba ?
         jz        ErrCode1                 ; nen¡ chyba

; ------ test, zda je nedokon‡en  operace nebo vnit©n¡ chyba ©adi‡e

         cmp       al,40h                   ; je nedokon‡en  operace ?
         mov       ah,20h                   ; chyba ©adi‡e
         jne       ErrCode1                 ; jin  chyba ne‘ nedokon‡en  oper.

; ------ sektor nenalezen nebo velk‚ ‡¡slo sektoru

         mov       al,1                     ; AL <- 1 (offset bajtu ST1)
         call      GetRes                   ; poskytnut¡ stav. bajtu ST1
         test      al,84h                   ; konec stopy nebo sektor nenalezl ?
         mov       ah,4                     ; chyba - sektor nenalezen
         jnz       ErrCode1                 ; sektor nenalezen

; ------ chybn˜ kontroln¡ sou‡et dat sektoru

         test      al,20h                   ; chyba kontroln¡ho sou‡tu CRC ?
         mov       ah,10h                   ; k¢d chyby kontr. sou‡tu CRC dat
         jnz       ErrCode1                 ; byla chyba CRC dat

; ------ chyba p©ete‡en¡ DMA p©es hranici

         test      al,10h                   ; bylo p©ete‡en¡ dat ?
         mov       ah,8                     ; k¢d chyby p©ete‡en¡ DMA
         jnz       ErrCode1                 ; bylo p©ete‡en¡ adresy DMA

; ------ chyba z pisu na disketu s ochranou z pisu

         test      al,2                     ; byla ochrana proti z pisu ?
         mov       ah,3                     ; k¢d chyby ochrany proti z pisu
         jnz       ErrCode1                 ; byla ochrana proti z pisu

; ------ chyba - nenalezena adresov  zna‡ka

         test      al,1                     ; nelze nal‚st adresovou zna‡ku ?
         mov       ah,2                     ; k¢d chyby - nenalezena adr. zna‡ka
         jnz       ErrCode1                 ; chyba nenalezen¡ adres. zna‡ky

; ------ chybu nelze ur‡it - chyba ©adi‡e

         mov       ah,20h                   ; chyba ©adi‡e

ErrCode1:or        ah,ah                    ; nastaven¡ p©¡znaku chyby ZF
         ret

ErrCode  ENDP



; -----------------------------------------------------------------------------
;        Vysl n¡ povelu na ©adi‡
; -----------------------------------------------------------------------------
; VSTUP: BL=disk
;        AL=prvn¡ bajt k vysl n¡
;        AH=po‡et bajt– celkem k vysl n¡
;        SS:SI=data (v z sobn¡ku)
;        DS=CS
;        ES=0
; VSTUP:AH=n vratov˜ chybov˜ k¢d
;        ZY=operace OK (AH=0), NZ=chyba operace (AH nen¡ 0)
; Zni‡en‚ registry: AX, SI
; -----------------------------------------------------------------------------

PUBLIC   NECOutp
NECOutp  PROC      NEAR

         push      cx
         push      dx

; ------ ‡ek n¡ na p©ipravenost ©adi‡e p©ij¡mat data

NECOutp1:push      ax                       ; £schova bajtu k vysl n¡
         mov       ah,80h                   ; o‡ek van  hodnota
         call      WaitPort                 ; ‡ek n¡ na stav portu
         pop       cx                       ; n vrat bajtu k vysl n¡
         jnz       NECOutp4                 ; byla chyba TIME-OUT

; ------ vysl n¡ bajtu na ©adi‡

         call      GetPrt5                  ; povelov˜ registr ©adi‡e
         mov       ax,cx                    ; n vrat AH a AL
         out       dx,al                    ; vysl n¡ bajtu na ©adi‡

; ------ ‡ek n¡ na potvrzen¡ p©evzet¡ bajtu

         dec       dx                       ; stavov˜ registr ©adi‡e
         mov       cx,24                    ; maxim ln¡ doba pro ‡ek n¡
NECOutp2:in        al,dx                    ; ‡ten¡ stavu ©adi‡e
         test      al,80h                   ; p©evzal ©adi‡ bajt ?
         loopnz    NECOutp2                 ; ‡ek n¡ na p©evzet¡ bajtu

; ------ test, zda je dal¨¡ bajt k vysl n¡

         dec       ah                       ; sn¡‘en¡ ‡¡ta‡e bajt– k vysl n¡
         jz        NECOutp3                 ; nen¡ ji‘ dal¨¡ bajt k vysl n¡
         mov       al,ss:[si]               ; dal¨¡ bajt k vysl n¡
         inc       si                       ; zv˜¨en¡ ukazatele dat v z sobn¡ku
         jmp       short NECOutp1           ; vysl n¡ dal¨¡ho bajtu

NECOutp3:xor       ah,ah

NECOutp4:or        ah,ah                    ; nastaven¡ p©¡znaku ZF
         pop       dx
         pop       cx
         ret

NECOutp  ENDP


; -----------------------------------------------------------------------------
;        P©¡jem stavu od ©adi‡e
; -----------------------------------------------------------------------------
; VSTUP: BL=disk
;        DS=CS
;        ES=0
; VSTUP:AH=k¢d chyby (0=operace OK)
;        ZY=operace OK, NZ=chyba operace
; Zni‡en‚ registry: AL
; -----------------------------------------------------------------------------

PUBLIC   Result
Result   PROC      NEAR

         push      bx
         push      dx
         xor       bh,bh                    ; ukazatel bajtu k ulo‘en¡

; ------ ‡ek n¡ na p©ipravenost ©adi‡e

Result1: mov       ah,0c0h                  ; po‘adovan  hodnota
         call      WaitPort                 ; ‡ek n¡ na p©ipravenost ©adi‡e
         jnz       Result2                  ; byla chyba ©adi‡e TIME-OUT

; ------ p©¡jem stavov‚ho bajtu od ©adi‡e

         call      GetPrt5                  ; datov˜ registr ©adi‡e
         in        al,dx                    ; ‡ten¡ stavov‚ho bajtu ©adi‡e
         mov       ah,bh                    ; offset registru v˜sledku
         call      SetRes                   ; ulo‘en¡ stavov‚ho bajtu
         inc       bh                       ; zv˜¨en¡ ukazatele bajt–

; ------ mal  prodleva

         mov       ax,3
         call      WaitT                    ; ‡ekac¡ doba pro odezvu ©adi‡e

; ------ test, zda je je¨tˆ dal¨¡ stavov˜ bajt

         dec       dx                       ; stavov˜ registr ©adi‡e
         in        al,dx                    ; ‡ten¡ stavu ©adi‡e
         test      al,10h                   ; je je¨tˆ dal¨¡ stavov˜ bajt ?
         mov       ah,0                     ; n vratov˜ k¢d operace - OK
         jz        Result2                  ; nen¡ ji‘ dal¨¡ bajt
         mov       ah,20h                   ; p©¡znak - chyba ©adi‡e
         cmp       bh,6                     ; p©ekro‡en po‡et stavov˜ch bajt– ?
         jbe       Result1                  ; p©¡jem dal¨¡ho stavov‚ho bajtu

Result2: or        ah,ah                    ; test v˜sledku operace
         pop       dx
         pop       bx
         ret

Result   ENDP


; -----------------------------------------------------------------------------
;        ‡ek n¡ na p©eru¨en¡ od ©adi‡e
; -----------------------------------------------------------------------------
; VSTUP: DS=CS
;        ES=0
; VSTUP:AH=k¢d chyby (0=operace OK)
;        ZY=operace OK, NZ=chyba operace TIME-OUT
; Zni‡en‚ registry: AL
; -----------------------------------------------------------------------------

PUBLIC   WaitInt
WaitInt  PROC      NEAR

; ------ zah jen¡ ‡ek n¡

         cmp       byte ptr ds:[WaitAT],1   ; m–‘e se ozn mit ‡ek n¡ ?
         jne       WaitInt1                 ; ‡ek n¡ se neoznamuje
         clc                                ; p©ednastaven¡ p©¡znaku NC
         mov       ax,9001h
         int       15h                      ; zah jen¡ operace ‡ek n¡
         jc        WaitInt3                 ; chyba TIME-OUT

; ------ ‡ek n¡ na p©¡chod p©eru¨en¡ INT 0eh (po dobu 1.5 sekundy)

WaitInt1:xor       ah,ah                    ; p©ednastaven¡ operace OK
         mov       byte ptr ds:[Counter],18+9 ; doba pro 1.5 sekundy
WaitInt2:test      byte ptr es:[43eh],80h   ; p©i¨lo ji‘ p©eru¨en¡ ?
         jnz       WaitInt4                 ; p©i¨lo ji‘ p©eru¨en¡ INT 0eh
         cmp       byte ptr ds:[Counter],0  ; uplynula ji‘ maxim ln¡ doba ?
         jne       WaitInt2                 ; je¨tˆ neuplynula maxim ln¡ doba

; ------ chyba TIME-OUT ‡ek n¡

WaitInt3:mov       ah,80h                   ; p©¡znak chyby TIME-OUT

WaitInt4:and       byte ptr es:[43eh],not 80h ; nulov n¡ p©¡znaku p©eru¨en¡
         or        ah,ah                    ; test v˜sledku operace (NZ)
         ret

WaitInt  ENDP




; *****************************************************************************
;        Ovl d n¡ motoru
; *****************************************************************************

; -----------------------------------------------------------------------------
;        Zapnut¡ motoru disku
; -----------------------------------------------------------------------------
; VSTUP: BL=‡¡slo disku
;        ES=0
;        DS=CS
; -----------------------------------------------------------------------------

PUBLIC   MotorOn
MotorOn  PROC      NEAR

         push      ax
         push      cx
         push      dx

; ------ doba pro vypnut¡ motoru na maximum

         mov       al,0ffh                  ; inicializa‡n¡ doba pro vypnut¡
         call      SetMOff                  ; nastaven¡ doby pro vypnut¡

; ------ sestaven¡ nov‚ho stavov‚ho bajtu motor–

         call      GetMot                   ; poskytnut¡ stav motor–
         mov       ah,al                    ; £schova star‚ho stavu motor–
         and       al,not 30h               ; zru¨en¡ p–vodn¡ho aktivn¡ho disku
         mov       ch,1                     ; maska pro motor disku 0 (2)
         test      bl,1                     ; je relativn¡ disk 0 nebo 1 ?
         jz        MotorOn1                 ; je disk 0 (nebo 2)
         inc       ch                       ; maska pro motor disku 1 (3)
         or        al,10h                   ; nov˜ aktivn¡ disk 1
MotorOn1:or        al,ch                    ; p©¡znak zapnut¡ motoru
         call      SetMot                   ; nastaven¡ nov‚ho stavu motor–

; ------ zapnut¡ motoru mechaniky

         mov       cl,4                     ; po‡et rotac¡
         rol       al,cl                    ; rotace na spr vnou pozici
         or        al,0ch                   ; bity pro uvolnˆn¡ ©adi‡e
         call      GetPrt2                  ; ©¡dic¡ registr ©adi‡e
         out       dx,al                    ; zapnut¡ motor–

; ------ test, zda se bude ‡ekat

         sti                                ; povolen¡ p©eru¨en¡
         test      ah,ch                    ; byl motor zapnut ?
         jnz       MotorOn6                 ; motor byl ji‘ zapnut - ne‡ek  se

; ------ zah jen¡ ‡ek n¡

         cmp       byte ptr ds:[WaitAT],1   ; m–‘e se ozn mit ‡ek n¡ ?
         jne       MotorOn2                 ; ‡ek n¡ se neoznamuje
         clc                                ; p©ednastaven¡ p©¡znaku NC
         mov       ax,90fdh
         int       15h                      ; zah jen¡ ‡ek n¡
         jc        MotorOn6                 ; ‡ek n¡ se vyhovˆlo - konec

; ------ doba pro start motoru

MotorOn2:mov       al,10                    ; parametr 10 - ‡as pro start motoru
         call      GetPar                   ; poskytnut¡ parametru 10

; ------ minim ln¡ startovac¡ doba pro z pis

         call      TestWr                   ; test - je operace z pis ?
         jz        MotorOn3                 ; nen¡ z pis - je ‡ten¡
         cmp       al,7                     ; minim ln¡ startovac¡ doba 7
         ja        MotorOn4                 ; startovac¡ doba je dostate‡n 
         mov       al,8                     ; minim ln¡ startovac¡ doba z pisu
         jmp       short MotorOn4           ; pokra‡ov n¡

; ------ minim ln¡ startovac¡ doba pro ‡ten¡

MotorOn3:or        al,al                    ; je startovac¡ doba = 0 ?
         jz        MotorOn6                 ; nen¡ pot©ebn  startovac¡ doba
         cmp       al,4                     ; je doba alespo¤ 4 ?
         ja        MotorOn4                 ; startovac¡ doba je dostate‡n 
         mov       al,4                     ; minim ln¡ startovac¡ doba 4

; ------ ‡ek n¡ po zadanou dobu na start motoru

MotorOn4:mov       ah,al                    ; po‘adovan  doba v 1/8 sekund
         add       al,al                    ; p©evod z 1/8 sekundy na 1/16 sek.
         shr       ah,1
         shr       ah,1                     ; 1/4 po‘adovan‚ doby
         add       al,ah                    ; p©evod z 1/16 sekundy na 1/18 sek.
         mov       byte ptr ds:[Counter],al ; nastaven¡ ‡¡ta‡e dlouh‚ho ‡asu
MotorOn5:cmp       byte ptr ds:[Counter],0  ; uplynul ji‘ ‡as ?
         jne       MotorOn5                 ; ‡as je¨tˆ neuplynul

MotorOn6:pop       dx
         pop       cx
         pop       ax
         ret

MotorOn  ENDP


; *****************************************************************************
;        Ur‡ov n¡ typu m‚dia
; *****************************************************************************



; -----------------------------------------------------------------------------
;        Obsluha v˜mˆny m‚dia (se zapnut¡m motoru)
; -----------------------------------------------------------------------------
; VSTUP: BL=‡¡slo disku
;        ES=0
;        DS=CS
; VSTUP:AH=k¢d chyby (0=operace OK)
;        ZY=operace OK, NZ=chyba operace TIME-OUT nebo m‚dium vymˆnˆno
; Zni‡en‚ registry: AL
; -----------------------------------------------------------------------------

PUBLIC   MedChng0                           ; test v˜mˆny bez zapnut¡ motoru
PUBLIC   MedChng
MedChng  PROC      NEAR

         call      MotorOn                  ; zapnut¡ motoru

; ------ pro mechaniku 40 stop se kontrola neprov d¡ - disketa nevymˆnˆna

MedChng0:call      GetStat                  ; ‡ten¡ stavov‚ho bajtu mechaniky
         test      al,1                     ; je mechanika 40 stop ?
         jz        MedChng4                 ; je mechanika 40 stop - nevymˆnˆna

; ------ ‡ten¡ stavu v˜mˆny m‚dia

         call      ReadChng                 ; ‡ten¡ sign lu v˜mˆny m‚dia
MedChng4:mov       ah,0                     ; n vratov˜ k¢d - m‚dium nevymˆnˆno
         jz        MedChng3                 ; m‚dium nebylo vymˆnˆno

; ------ nulov n¡ p©¡znaku zn mosti m‚dia

         call      GetMed                   ; poskytnut¡ bajtu stavu m‚dia
         and       al,not 10h               ; nulov n¡ p©¡znaku zn mosti m‚dia
         call      SetMed                   ; opˆtn‚ nastaven¡ bajtu stavu m‚dia

; ------ nulov n¡ sign lu v˜mˆny m‚dia

         mov       ah,bl                    ; disk
         and       ah,1                     ; disk 0 nebo 1
         inc       ah                       ; maska rekalibrace (1 nebo 2)
         call      GetRec                   ; poskytnut¡ bajtu rekalibrace
         test      al,ah                    ; vy‘aduje se rekalibrace ?
         jz        MedChng1                 ; nen¡ zn m  aktu ln¡ stopa
         call      GetSeek                  ; poskytnut¡ aktu ln¡ stopy
         or        al,al                    ; je jin  stopa ne‘ 0 ?
         jnz       MedChng2                 ; nen¡ nutn‚ vystaven¡ na stopu 1
MedChng1:mov       al,1                     ; po‘adovan  stopa 1
         call      Seek                     ; vystaven¡ na stopu 1
MedChng2:xor       al,al                    ; po‘adovan  stopa 0
         call      Seek                     ; vystaven¡ na stopu 0

; ------ test, zda se sign l v˜mˆny zmˆnil - pokud ne, jsou dv¡©ka otev©ena

         call      ReadChng                 ; ‡ten¡ sign lu v˜mˆny m‚dia
         mov       ah,6                     ; p©¡znak - m‚dium vymˆnˆno
         jz        MedChng3                 ; sign l v˜mˆny OK
         mov       ah,80h                   ; p©¡znak - mechanika nep©ipravena

MedChng3:or        ah,ah
         ret

MedChng  ENDP

; -----------------------------------------------------------------------------
;        Test dvoj¡ho krokov n¡
; -----------------------------------------------------------------------------
; VSTUP: BL=‡¡slo disku
;        ES=0
;        DS=CS
; VSTUP:AH=k¢d chyby (0=operace OK)
;        ZY=operace OK, NZ=chyba operace TIME-OUT
; Zni‡en‚ registry: AL
; -----------------------------------------------------------------------------

PUBLIC   SetDbl
SetDbl   PROC      NEAR

         push      dx

; ------ test, zda je m‚dium zn m‚

         call      GetMed                   ; ‡ten¡ bajtu stavu m‚dia
         test      al,10h                   ; je m‚dium zn m‚ ?
         jnz       SetDbl5                  ; m‚dium je zn m‚
         and       al,not 20h               ; nulov n¡ p©¡znaku dvoj¡ho krokov.
         call      SetMed                   ; nastaven¡ bajtu stavu m‚dia

; ------ pro mechaniku 40 stop se test neprov d¡

         call      GetStat                  ; ‡ten¡ stavov‚ho bajtu mechaniky AL
         test      al,1                     ; je disketa 40 stop ?
         jz        SetDbl5                  ; je disketa 40 stop

; ------ nulov n¡ p©¡znaku rekalibrace

         call      NulRec                   ; nulov n¡ p©¡znaku rekalibrace

; ------ vystaven¡ na stopu 0 (a potom i na dal¨¡ stopy)

         mov       dl,bl                    ; po‘adovan˜ disk
         and       dl,1                     ; po‘adovan˜ disk relativnˆ
         xor       dh,dh                    ; po‡ te‡n¡ stopa 0
SetDbl2: mov       al,dh                    ; po‘adovan  stopa
         call      Seek                     ; vystaven¡ disku AL na stopu AH
         jnz       SetDbl6                  ; byla chyba vystaven¡

; ------ pokus o ‡ten¡ identifik toru

         push      dx                       ; po‘adovan˜ disk
         mov       si,sp                    ; ukazatel parametr–
         mov       al,4ah                   ; povel pro ‡ten¡ identifik toru ID
         mov       ah,2                     ; po‡et parametr– READ ID
         call      NECOutp                  ; vysl n¡ povelu READ ID na ©adi‡
         pop       dx                       ; zru¨en¡ dat v z sobn¡ku
         jnz       SetDbl6                  ; byla chyba operace

; ------ test, zda byl ID nalezen

         call      NECWait                  ; ‡ek n¡ na proveden¡ operace
         mov       al,0ffh                  ; maxim ln¡ doba vypnut¡ motoru
         call      SETMOff                  ; nastaven¡ doby pro vypnut¡ motoru
         or        dh,dh                    ; byla to stopa 0 ?
         jz        SetDbl3                  ; byla to stopa 0
         or        ah,ah                    ; byla nˆjak  chyba ?
         jz        SetDbl4                  ; nebyla chyba - ID nalezen

; ------ ID nenalezen - dal¨¡ stopa (a‘ po stopu asi tak 20 - 8 pokus–)

         add       dh,2                     ; zv˜¨en¡ ‡¡sla stopy (sud‚ stopy)
         cmp       dh,20                    ; je ji‘ stopa 20 ?
         jb        SetDbl2                  ; nen¡ je¨tˆ stopa 20
         jmp       short SetDbl6            ; chyba - nenalezeno

; ------ byla stopa 0 - test, zda je v–bec ‡iteln 

SetDbl3: or        ah,ah                    ; byla stopa 0 ‡iteln  ?
         jnz       SetDbl6                  ; nen¡ ‡iteln -nem  smysl pokra‡ovat
         mov       dh,4                     ; dal¨¡ stopa bude stopa 4
         jmp       short SetDbl2            ; pokus o ‡ten¡ stopy 4

; ------ ID nalezen - pokud stopa nesouhlas¡, je dvoj¡ krokov n¡

SetDbl4: mov       al,3                     ; po‘adovan˜ bajt - stopa ID
         call      GetRes                   ; poskytnut¡ parametru 3
         cmp       al,dh                    ; souhlas¡ stopa ?
         je        SetDbl5                  ; stopa souhlas¡ - je 80 stop
         call      GetMed                   ; poskytnut¡ bajtu stavu m‚dia
         or        al,20h                   ; p©¡znak dvoj¡ho krokov n¡
         call      SetMed                   ; nastaven¡ bajtu stavu m‚dia

SetDbl5: xor       ah,ah                    ; p©¡znak - operace OK

SetDbl6: or        ah,ah                    ; nastaven¡ p©¡znaku ZF
         pop       dx
         ret

SetDbl   ENDP



; -----------------------------------------------------------------------------
;        Ur‡en¡ implicitn¡ho bajtu stavu m‚dia (pro form tov n¡)
; -----------------------------------------------------------------------------
; VSTUP: BL=‡¡slo disku
;        ES=0
;        DS=CS
; Zni‡en‚ registry: AX
; -----------------------------------------------------------------------------

PUBLIC   MedDet
MedDet   PROC      NEAR

; ------ ur‡en¡ stavov‚ho bajtu m‚dia podle typu mechaniky

         push      bx                       ; £schova BX
         call      GetTyp                   ; poskytnut¡ typu disku
         mov       bl,al                    ; typ disku
         xor       bh,bh                    ; BH <- 0
         mov       ah,ds:[TabMed+bx]        ; konverze na typ m‚dia
         pop       bx                       ; n vrat BX

; ------ ur‡en¡ stavov‚ho bajtu mechaniky 720 KB (rozli¨en¡ 5 1/4" nebo 3 1/2")

         cmp       al,3                     ; je mechanika 720 KB ?
         jne       MedDet2                  ; nen¡ mechanika 720 KB
         call      GetStat                  ; poskytnut¡ stavov‚ho bajtu disku
         and       al,6                     ; p©¡znak v¡ce rychlost¡
         cmp       al,6                     ; je mo‘n‚ v¡ce rychlost¡ ?
         jne       MedDet2                  ; nen¡ mo‘n‚ v¡ce rychlost¡
         mov       ah,50h                   ; rychlost 300 kb/s pro mech. 5 1/4"

; ------ nastaven¡ stavov‚ho bajtu m‚dia

MedDet2: mov       al,ah                    ; nov  hodnota bajtu stavu m‚dia
         call      SetMed                   ; nastaven¡ bajtu stavu m‚dia
         ret

MedDet   ENDP

TabMed   db        0                        ; 0: neur‡en‚ m‚dium
         db        93h                      ; 1: 360 KB (250 k/s)
         db        15h                      ; 2: 1.2 MB (500 k/s)
         db        97h                      ; 3: 720 KB (50h) (250 k/s, 300 k/s)
         db        17h                      ; 4: 1.44 MB (500 k/s)

; -----------------------------------------------------------------------------
;        Ur‡en¡ tabulky disku podle typu disku
; -----------------------------------------------------------------------------
; VSTUP: AL=typ disketov‚ mechaniky 1 a‘ 4
; VSTUP:CS:SI=adresa tabulky disku
; -----------------------------------------------------------------------------

PUBLIC   GetTab
GetTab   PROC      NEAR

         push      ax                       ; £schova AX
         mov       ah,13                    ; d‚lka 1 tabulky
         mul       ah                       ; v˜po‡et offsetu tabulky
         mov       si,ax                    ; offset tabulky
         pop       ax                       ; n vrat AX
         cmp       al,2                     ; byl disk 1 nebo 2 ?
         ja        GetTab1                  ; je mechanika 720 KB nebo 1.44 MB
         sub       si,13                    ; disky 1, 2 (p©esko‡¡ 1.2M v 1.2M)
GetTab1: add       si,offset TabDisk        ; tabulka disk–
         ret

GetTab   ENDP


; -----------------------------------------------------------------------------
;        €ten¡ sign lu v˜mˆny m‚dia
; -----------------------------------------------------------------------------
; VSTUP: BL=‡¡slo disku
;        ES=0
;        DS=CS
; VSTUP:AL=stav sign lu v˜mˆny (0=nebyla v˜mˆna, 80h=byla v˜mˆna)
;        ZY=nebyla v˜mˆna, NZ=disketa vymˆnˆna
; -----------------------------------------------------------------------------

PUBLIC   ReadChng
ReadChng PROC      NEAR

         push      dx                       ; £schova DX
         call      GetPrt7                  ; poskytnut¡ adresy portu 7
         in        al,dx                    ; ‡ten¡ stavu sign lu v˜mˆny
         and       al,80h                   ; test bitu sign lu v˜mˆny
         pop       dx                       ; n vrat DX
         ret

ReadChng ENDP



; *****************************************************************************
;        Obsluha p©enosov‚ rychlosti
; *****************************************************************************



; -----------------------------------------------------------------------------
;        Inicializace koncov‚ p©enosov‚ rychlosti (po‡ te‡n¡ je aktu ln¡)
; -----------------------------------------------------------------------------
; VSTUP: BL=‡¡slo disku
;        ES=0
;        DS=CS
; Zni‡en‚ registry: AL
; -----------------------------------------------------------------------------

PUBLIC   SetupSt
SetupSt  PROC      NEAR

; ------ pro disk s 1 rychlost¡ pouze rychlost 250 k/s

         call      GetStat                  ; ‡ten¡ stavov‚ho bajtu disku
         and       al,6                     ; stavov‚ bity
         cmp       al,4                     ; je pouze 1 rychlost ?
         mov       al,80h                   ; koncov  rychlost 250 kb/s
         je        SetupSt2                 ; je pouze 1 rychlost

; ------ ur‡en¡ maxim ln¡ rychlosti p©i v¡ce rychlostech

         call      GetMed                   ; poskytnut¡ stavov‚ho bajtu m‚dia
         and       al,0c0h                  ; aktu ln¡ p©enosov  rychlost
         add       al,40h                   ; 00h (500) -> 40h (300)
                                            ; 40h (300) -> 80h (250)
                                            ; 80h (250) -> 0c0h (korekce na 00h)
                                            ; 0c0h (neplatn˜) -> 00h
         cmp       al,0c0h                  ; bude korekce ?
         jne       SetupSt2                 ; nebude korekce
         xor       al,al                    ; korekce 80h->00h (250->500)

; ------ nastaven¡ nov‚ maxim ln¡ rychosti

SetupSt2:call      SetMRate                 ; nastaven¡ maxim ln¡ rychlosti
         ret

SetupSt  ENDP

; -----------------------------------------------------------------------------
;        Nastaven¡ p©enosov‚ rychlosti (podle stavov‚ho bajtu m‚dia)
; -----------------------------------------------------------------------------
; VSTUP: BL=‡¡slo disku
;        ES=0
;        DS=CS
; -----------------------------------------------------------------------------

PUBLIC   SendRate
SendRate PROC      NEAR

; ------ kontrola, zda je rychlost ji‘ nastavena

         push      ax
         push      dx
         call      GetLRate                 ; poskytnut¡ posledn¡ p©enos. rychl.
         mov       ah,al                    ; posledn¡ p©enos. rychlost
         call      GetMed                   ; poskytnut¡ stavov‚ho bajtu m‚dia
         and       al,0c0h                  ; po‘adovan  p©enosov  rychlost
         cmp       al,ah                    ; je rychlost ji‘ nastavena ?
         je        SendRat2                 ; rychlost je ji‘ nastavena

; ------ nastaven¡ nov‚ p©enosov‚ rychlosti

         call      SetLRate                 ; nastaven¡ posledn¡ p©enos. rychl.
         call      GetPrt7                  ; poskytnut¡ adresy portu 7
         rol       al,1
         rol       al,1                     ; rychlost -> bity 0 a 1 reg. AL
         out       dx,al                    ; nastaven¡ p©enosov‚ rychlosti

SendRat2:pop       dx
         pop       ax
         ret

SendRate ENDP

; -----------------------------------------------------------------------------
;        Nastaven¡ dal¨¡ p©enosov‚ rychlosti 300->500->250 (40h->00h->80h)
; -----------------------------------------------------------------------------
; VSTUP: BL=‡¡slo disku
;        AH=k¢d chyby z p©ede¨l‚ operace
;        DS=CS
;        ES=0
; VSTUP:AH=p–vodn¡ k¢d chyby nebo 0 - lze prov‚st dal¨¡ pokus
; -----------------------------------------------------------------------------

PUBLIC   Retry
Retry    PROC      NEAR

; ------ test, zda ji‘ byla maxim ln¡ rychlost

         push      bx                       ; £schova BX
         mov       bh,ah                    ; £schova n vratov‚ho k¢du
         call      GetMRate                 ; poskytnut¡ max. p©enos. rychlosti
         mov       ah,al                    ; £schova maxim. p©enos. rychlosti
         call      GetMed                   ; poskytnut¡ bajtu stavu m‚dia
         and       al,0c0h                  ; aktu ln¡ p©enosov  rychlost
         cmp       al,ah                    ; byla ji‘ posledn¡ rychlost ?
         mov       ah,bh                    ; p–vodn¡ n vratov˜ k¢d chyby
         je        Retry3                   ; byly ji‘ v¨echny pokusy - chyba

; ------ ur‡en¡ dal¨¡ p©enosov‚ rychlosti

         call      GetMed                   ; poskytnut¡ bajtu stavu m‚dia
         add       al,0c0h                  ; 00h -> 0c0h (bude korekce na 80h)
                                            ; 40h -> 00h
                                            ; 80h -> 40h
                                            ; 0c0h -> 80h

         jns       Retry2                   ; nen¡ bajt 0c0h ani 80h
         and       al,not 40h               ; korekce na 80h
Retry2:  call      SetMed                   ; nastaven¡ bajtu stavu m‚dia
         xor       ah,ah                    ; AH <- 0 p©¡znak mo‘nosti opakov n¡

Retry3:  or        ah,ah                    ; je mo‘n‚ opakov n¡ ?
         pop       bx
         ret

Retry    ENDP

; -----------------------------------------------------------------------------
;        Ur‡en¡ typu m‚dia a disku po £spˆ¨n‚ operaci ‡ten¡/z pis/verifikace
; -----------------------------------------------------------------------------
; VSTUP: BL=‡¡slo disku
;        ES=0
;        DS=CS
; -----------------------------------------------------------------------------

PUBLIC   DState
DState   PROC      NEAR

         push      ax

; ------ ozna‡en¡ m‚dia za ur‡en‚

         call      GetMed                   ; poskytnut¡ bajtu stavu m‚dia
         or        al,10h                   ; ozna‡en¡ m‚dia jako ur‡en‚
         call      SetMed                   ; nastaven¡ bajtu stavu m‚dia
         mov       ah,al                    ; £schova bajtu stavu m‚dia

; ------ test, zda byla mechanika ji‘ ur‡ena

         call      GetStat                  ; ‡ten¡ stavov‚ho bajtu mechaniky
         test      al,4                     ; je mechanika ji‘ ur‡ena ?
         jnz       DState2                  ; mechanika je ji‘ ur‡ena

; ------ ur‡en¡ typu mechaniky (rozli¨en¡, zda je mo‘n‚ v¡ce rychlost¡)

         or        al,6                     ; mechanika ur‡en , v¡ce rychlost¡
         and       ah,0c0h                  ; p©enosov  rychlost
         cmp       ah,80h                   ; byla rychlost 250 k/s ?
         jne       DState1                  ; nebyla rychlost 250 k/s
         mov       ah,al                    ; £schova bajtu mechaniky
         call      GetTyp                   ; poskytnut¡ typu disku AL
         xchg      ah,al                    ; AH <- typ mechaniky
         jz        DState1                  ; disk nen¡ instalov n
         cmp       ah,4                     ; je mechanika 3 1/2" HD ?
         je        DState1                  ; je mechanika 3 1/2" HD
         and       al,not 2                 ; p©¡znak, ‘e je jen rychlost 250k/s
DState1: call      SetStat                  ; nastaven¡ stavov‚ho bajtu disku

DState2: pop       ax
         ret

DState   ENDP


; *****************************************************************************
;        Nastavov n¡ promˆnn˜ch
; *****************************************************************************


; -----------------------------------------------------------------------------
;        Poskytnut¡ bajtu v˜sledku operace
; -----------------------------------------------------------------------------
; VSTUP: BL=‡¡slo disku
;        AL=offset bajtu (‡¡slo 0 - 6)
;        ES=0
;        DS=CS
; VSTUP:AL=bajt v˜sledku operace
; -----------------------------------------------------------------------------

PUBLIC   GetRes
GetRes   PROC      NEAR

         push      bx                       ; £schova BX
         xor       bh,bh                    ; BH <- 0
         cmp       bl,2                     ; jsou disky 2 nebo 3 ?
         mov       bl,al                    ; offset bajtu
         mov       al,es:[442h+bx]          ; bajty pro disky 0 a 1
         jb        GetRes1                  ; jsou disky 0 nebo 1
         mov       al,ds:[Stat+bx]          ; bajty pro disky 2 a 3
GetRes1: pop       bx
         ret

GetRes   ENDP

; -----------------------------------------------------------------------------
;        Nastaven¡ bajtu v˜sledku operace
; -----------------------------------------------------------------------------
; VSTUP: BL=‡¡slo disku
;        AL=nastavovan  hodnota
;        AH=offset bajtu (‡¡slo 0 - 6)
;        ES=0
;        DS=CS
; -----------------------------------------------------------------------------

PUBLIC   SetRes
SetRes   PROC      NEAR

         push      bx                       ; £schova BX

         xor       bh,bh                    ; BH <- 0
         cmp       bl,2                     ; jsou disky 2 nebo 3 ?
         mov       bl,ah                    ; offset bajtu
         jb        SetRes1                  ; jsou disky 0 nebo 1

; ------ nastaven¡ bajtu disk– 2 a 3

         mov       ds:[Stat+bx],al          ; nastaven¡ bajtu disk– 2 a 3
         jmp       short SetRes2

; ------ nastaven¡ bajtu disk– 0 a 1

SetRes1: mov       es:[442h+bx],al          ; nastaven¡ bajtu disk– 0 a 1

SetRes2: pop       bx
         ret

SetRes   ENDP

;; -----------------------------------------------------------------------------
;;        Poskytnut¡ bajtu ‡¡ta‡e vypnut¡ motor–
;; -----------------------------------------------------------------------------
;; VSTUP: BL=‡¡slo disku
;;        ES=0
;;        DS=CS
;; VSTUP:AL=bajt ‡¡ta‡e vypnut¡ motor–
;; -----------------------------------------------------------------------------
;
;PUBLIC   GetMOff
;GetMOff  PROC      NEAR
;
;         mov       al,ds:[CountMot]         ; ‡¡ta‡ motor– disk– 2 a 3
;         cmp       bl,2                     ; jsou disky 2 nebo 3 ?
;         jae       GetMOff1                 ; je disk 2 nebo 3
;         mov       al,es:[440h]             ; ‡¡ta‡ motor– disk– 0 a 1
;GetMOff1:ret
;
;GetMOff  ENDP

; -----------------------------------------------------------------------------
;        Nastaven¡ bajtu ‡¡ta‡e vypnut¡ motor–
; -----------------------------------------------------------------------------
; VSTUP: BL=‡¡slo disku
;        AL=bajt ‡¡ta‡e vypnut¡ motor–
;        ES=0
;        DS=CS
; -----------------------------------------------------------------------------

PUBLIC   SetMOff
SetMOff  PROC      NEAR

;         mov       ds:[CountMot],al         ; ‡¡ta‡ motor– disk– 2 a 3
         mov       es:[440h],al             ; ‡¡ta‡ motor– disk– 0 a 1
         ret

SetMOff  ENDP


; -----------------------------------------------------------------------------
;        Nulov n¡ p©¡znaku rekalibrace
; -----------------------------------------------------------------------------
; VSTUP: BL=‡¡slo disku
;        ES=0
;        DS=CS
; -----------------------------------------------------------------------------

PUBLIC   NulRec
NulRec   PROC      NEAR

         push      ax
         mov       ah,bl                    ; disk
         and       ah,1                     ; disk 0 nebo 1
         inc       ah                       ; maska rekalibrace (1 nebo 2)
         not       ah                       ; inverzn¡ maska
         call      GetRec                   ; poskytnut¡ bajtu rekalibrace
         and       al,ah                    ; nulov n¡ bitu rekalibrace
         call      SetRec                   ; nastaven¡ nov‚ho bajtu rekalibrace
         pop       ax
         ret

NulRec   ENDP

; -----------------------------------------------------------------------------
;        Poskytnut¡ bajtu rekalibrace
; -----------------------------------------------------------------------------
; VSTUP: BL=‡¡slo disku
;        ES=0
;        DS=CS
; VSTUP:AL=bajt stavu rekalibrace
; -----------------------------------------------------------------------------

PUBLIC   GetRec
GetRec   PROC      NEAR

         mov       al,ds:[Rekalib]          ; stav rekalibrace disk– 2 a 3
         cmp       bl,2                     ; jsou disky 2 nebo 3 ?
         jae       GetRec1                  ; je disk 2 nebo 3
         mov       al,es:[43eh]             ; stav rekalibrace disk– 0 a 1
GetRec1: ret

GetRec   ENDP

; -----------------------------------------------------------------------------
;        Nastaven¡ bajtu rekalibrace
; -----------------------------------------------------------------------------
; VSTUP: BL=‡¡slo disku
;        AL=bajt rekalibrace
;        ES=0
;        DS=CS
; -----------------------------------------------------------------------------

PUBLIC   SetRec
SetRec   PROC      NEAR

         cmp       bl,2                     ; jsou disky 2 nebo 3 ?
         jb        SetRec1                  ; je disk 0 nebo 1
         mov       ds:[Rekalib],al          ; stav rekalibrace disk– 2 a 3
         ret

SetRec1: mov       es:[43eh],al             ; stav rekalibrace disk– 0 a 1
         ret

SetRec   ENDP

; -----------------------------------------------------------------------------
;        Poskytnut¡ bajtu stavu motor–
; -----------------------------------------------------------------------------
; VSTUP: BL=‡¡slo disku
;        ES=0
;        DS=CS
; VSTUP:AL=bajt stavu motor–
; -----------------------------------------------------------------------------

PUBLIC   GetMot
GetMot   PROC      NEAR

         mov       al,ds:[Motors]           ; stav motor– disk– 2 a 3
         cmp       bl,2                     ; jsou disky 2 nebo 3 ?
         jae       GetMot1                  ; je disk 2 nebo 3
         mov       al,es:[43fh]             ; stav motor– disk– 0 a 1
GetMot1: ret

GetMot   ENDP

; -----------------------------------------------------------------------------
;        Nastaven¡ bajtu stavu motor–
; -----------------------------------------------------------------------------
; VSTUP: BL=‡¡slo disku
;        AL=bajt stavu motor–
;        ES=0
;        DS=CS
; -----------------------------------------------------------------------------

PUBLIC   SetMot
SetMot   PROC      NEAR

         cmp       bl,2                     ; jsou disky 2 nebo 3 ?
         jb        SetMot1                  ; je disk 0 nebo 1
         mov       ds:[Motors],al           ; stav motor– disk– 2 a 3
         ret

SetMot1: mov       es:[43fh],al             ; stav motor– disk– 0 a 1
         ret

SetMot   ENDP

; -----------------------------------------------------------------------------
;        Nulov n¡ p©¡znaku operace z pis
; -----------------------------------------------------------------------------
; VSTUP: BL=‡¡slo disku
;        ES=0
;        DS=CS
; -----------------------------------------------------------------------------

PUBLIC   ResWr
ResWr    PROC      NEAR

         cmp       bl,2
         jb        ResWr1
         and       byte ptr ds:[Motors],not 80h ; nulov n¡ p©¡znaku z pis
         ret

ResWr1:  and       byte ptr es:[43fh],not 80h ; nulov n¡ p©¡znaku z pis
         ret

ResWr    ENDP

; -----------------------------------------------------------------------------
;        Nastaven¡ p©¡znaku operace z pis
; -----------------------------------------------------------------------------
; VSTUP: BL=‡¡slo disku
;        ES=0
;        DS=CS
; -----------------------------------------------------------------------------

PUBLIC   SetWr
SetWr    PROC      NEAR

         cmp       bl,2
         jb        SetWr1
         or        byte ptr ds:[Motors],80h ; nastaven¡ p©¡znaku z pis
         ret

SetWr1:  or        byte ptr es:[43fh],80h   ; nastaven¡ p©¡znaku z pis
         ret

SetWr    ENDP

; -----------------------------------------------------------------------------
;        Test, zda je operace z pis
; -----------------------------------------------------------------------------
; VSTUP: BL=‡¡slo disku
;        ES=0
;        DS=CS
; VSTUP:ZY=je ‡ten¡, NZ=je z pis
; -----------------------------------------------------------------------------

PUBLIC   TestWr
TestWr   PROC      NEAR

         cmp       bl,2
         jb        TestWr1
         test      byte ptr ds:[Motors],80h ; test p©¡znaku z pis
         ret

TestWr1: test      byte ptr es:[43fh],80h   ; test p©¡znaku z pis
         ret

TestWr   ENDP

; -----------------------------------------------------------------------------
;        Poskytnut¡ maxim ln¡ p©enosov‚ rychlosti
; -----------------------------------------------------------------------------
; VSTUP: BL=‡¡slo disku
;        ES=0
;        DS=CS
; VSTUP:AL=maxim ln¡ p©enosov  rychlost ©adi‡e (bity 6 a 7)
; -----------------------------------------------------------------------------

PUBLIC   GetMRate
GetMRate PROC      NEAR

         mov       al,ds:[MaxRate]          ; maxim ln¡ p©enos. rychlost
         cmp       bl,2                     ; je disk 2 nebo 3 ?
         jae       GetMRat1                 ; je disk 2 nebo 3 - je ©adi‡ #2
         mov       al,es:[48bh]             ; maxim ln¡ p©enos. rychl.
         shl       al,1
         shl       al,1
         shl       al,1
         shl       al,1                     ; rotace na pozice bit– 6 a 7
GetMRat1:and       al,0c0h                  ; ponech  bity p©enosov‚ rychlosti
         ret

GetMRate ENDP

; -----------------------------------------------------------------------------
;        Nastaven¡ maxim ln¡ p©enosov‚ rychlosti
; -----------------------------------------------------------------------------
; VSTUP: BL=‡¡slo disku
;        AL=maxim ln¡ p©enosov  rychlost ©adi‡e (bity 6 a 7)
;        ES=0
;        DS=CS
; -----------------------------------------------------------------------------

PUBLIC   SetMRate
SetMRate PROC      NEAR

         push      ax
         and       al,0c0h                  ; ponech  bity p©enos. rychlosti

; ------ nastaven¡ pro ©adi‡ #2

         cmp       bl,2                     ; je disk 2 nebo 3 ?
         jb        SetMRat1                 ; je disk 0 nebo 1 - je ©adi‡ #1
         mov       ds:[MaxRate],al          ; maxim ln¡ p©enos. rychlost
         jmp       short SetMRat2

; ------ nastaven¡ pro ©adi‡ #1

SetMRat1:and       byte ptr es:[48bh],not 0ch ; zru¨en¡ p–vodn¡ p©enos. rychl.
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1                     ; rotace na pozice bit– 2 a 3
         or        byte ptr es:[48bh],al    ; nov  maxim ln¡ p©enos. rychlost
SetMRat2:pop       ax
         ret

SetMRate ENDP

; -----------------------------------------------------------------------------
;        Poskytnut¡ posledn¡ p©enosov‚ rychlosti
; -----------------------------------------------------------------------------
; VSTUP: BL=‡¡slo disku
;        ES=0
;        DS=CS
; VSTUP:AL=poslednˆ nastaven  p©enosov  rychlost ©adi‡e (bity 6 a 7)
; -----------------------------------------------------------------------------

PUBLIC   GetLRate
GetLRate PROC      NEAR

         mov       al,ds:[LastRate]         ; poslednˆ nastaven  p©enos.rychlost
         cmp       bl,2                     ; je disk 2 nebo 3 ?
         jae       GetLRat1                 ; je disk 2 nebo 3 - je ©adi‡ #2
         mov       al,es:[48bh]             ; aktu lnˆ nastaven  p©enos. rychl.
GetLRat1:and       al,0c0h                  ; ponech  bity p©enosov‚ rychlosti
         ret

GetLRate ENDP

; -----------------------------------------------------------------------------
;        Nastaven¡ posledn¡ p©enosov‚ rychlosti
; -----------------------------------------------------------------------------
; VSTUP: BL=‡¡slo disku
;        AL=poslednˆ nastaven  p©enosov  rychlost ©adi‡e (bity 6 a 7)
;        ES=0
;        DS=CS
; -----------------------------------------------------------------------------

PUBLIC   SetLRate
SetLRate PROC      NEAR

         push      ax
         and       al,0c0h

; ------ nastaven¡ pro ©adi‡ #2

         cmp       bl,2                     ; je disk 2 nebo 3 ?
         jb        SetLRat1                 ; je disk 0 nebo 1 - je ©adi‡ #1
         mov       ds:[LastRate],al         ; poslednˆ nastaven  p©enos.rychlost
         jmp       short SetLRat2

; ------ nastaven¡ pro ©adi‡ #1

SetLRat1:and       byte ptr es:[48bh],not 0c0h ; zru¨en¡ p–vodn¡ p©enos. rychl.
         or        byte ptr es:[48bh],al    ; nov  p©enosov  rychlost
SetLRat2:pop       ax
         ret

SetLRate ENDP

; -----------------------------------------------------------------------------
;        Poskytnut¡ aktu ln¡ stopy mechaniky AL
; -----------------------------------------------------------------------------
; VSTUP: BL=‡¡slo disku
;        ES=0
;        DS=CS
; VSTUP:AL=aktu ln¡ stopa disku
; -----------------------------------------------------------------------------

PUBLIC   GetSeek
GetSeek  PROC      NEAR

         mov       al,ds:[Stopa3]           ; aktu ln¡ stopa disku 3
         cmp       bl,2                     ; je disk 2 nebo 3 ?
         ja        GetSeek1                 ; je disk 3
         mov       al,ds:[Stopa2]           ; aktu ln¡ stopa disku 2
         je        GetSeek1                 ; je disk 2
         mov       al,es:[494h]             ; aktu ln¡ stopa disku 0
         or        bl,bl                    ; je disk 0 ?
         jz        GetSeek1                 ; je disk 0
         mov       al,es:[495h]             ; aktu ln¡ stopa disku 1
GetSeek1:ret

GetSeek  ENDP

; -----------------------------------------------------------------------------
;        Nastaven¡ aktu ln¡ stopy disku
; -----------------------------------------------------------------------------
; VSTUP: BL=‡¡slo disku
;        AL=nov  aktu ln¡ stopa
;        ES=0
;        DS=CS
; -----------------------------------------------------------------------------

PUBLIC   SetSeek
SetSeek  PROC      NEAR

         cmp       bl,2                     ; jsou disky 2 nebo 3 ?
         jb        SetSeek2                 ; jsou disky 0 nebo 1
         ja        SetSeek1                 ; je disk 3
         mov       ds:[Stopa2],al           ; nastaven¡ stopy disku 2
         ret

SetSeek1:mov       ds:[Stopa3],al           ; nastaven¡ stopy disku 3
         ret

SetSeek2:or        bl,bl                    ; je mechanika 0 ?
         jnz       SetSeek3                 ; je mechanika 1
         mov       es:[494h],al             ; nastaven¡ mechaniky 0
         ret

SetSeek3:mov       es:[495h],al             ; nastaven¡ mechaniky 1
         ret

SetSeek  ENDP

; -----------------------------------------------------------------------------
;        Poskytnut¡ stavov‚ho bajtu m‚dia mechaniky AL
; -----------------------------------------------------------------------------
; VSTUP: BL=‡¡slo disku
;        ES=0
;        DS=CS
; VSTUP:AL=stavov˜ bajt m‚dia
; -----------------------------------------------------------------------------

PUBLIC   GetMed
GetMed   PROC      NEAR

         mov       al,ds:[Med3]             ; stav m‚dia disku 3
         cmp       bl,2                     ; je disk 2 nebo 3 ?
         ja        GetMed1                  ; je disk 3
         mov       al,ds:[Med2]             ; stav m‚dia disku 2
         je        GetMed1                  ; je disk 2
         mov       al,es:[491h]             ; stav m‚dia disku 1
         or        bl,bl                    ; je disk 0 ?
         jnz       GetMed1                  ; je disk 1
         mov       al,es:[490h]             ; stav m‚dia disku 0
GetMed1: ret

GetMed   ENDP

; -----------------------------------------------------------------------------
;        Nastaven¡ stavov‚ho bajtu m‚dia mechaniky AL
; -----------------------------------------------------------------------------
; VSTUP: BL=‡¡slo disku
;        AL=stav m‚dia
;        ES=0
;        DS=CS
; -----------------------------------------------------------------------------

PUBLIC   SetMed
SetMed   PROC      NEAR

         cmp       bl,2                     ; jsou bajty v BIOS-RAM ?
         jb        SetMed2                  ; jsou disky 0 nebo 1

; ------ nastaven¡ disk– 2 nebo 3 (vlastn¡ bajty)

         ja        SetMed1                  ; je disk 3
         mov       byte ptr ds:[Med2],al    ; nastaven¡ stavov‚ho bajtu disku 2
         ret

SetMed1: mov       byte ptr ds:[Med3],al    ; nastaven¡ stavov‚ho bajtu disku 3
         ret

; ------ nastaven¡ disku 1

SetMed2: or        bl,bl                    ; je disk 0 ?
         jz        SetMed3                  ; je disk 0
         mov       es:[491h],al             ; nastaven¡ bajtu disku 1
         ret

; ------ nastaven¡ disku 0

SetMed3: mov       es:[490h],al             ; nastaven bajtu disku 0
         ret

SetMed   ENDP

; -----------------------------------------------------------------------------
;        Poskytnut¡ stavov‚ho bajtu disku
; -----------------------------------------------------------------------------
; VSTUP: BL=‡¡slo disku
;        ES=0
;        DS=CS
; VSTUP:AL=stav disku
;        ZY=disk nen¡ definov n
; -----------------------------------------------------------------------------

PUBLIC   GetStat
GetStat  PROC      NEAR

         mov       al,ds:[Stat3]            ; stav disku 3
         cmp       bl,2                     ; je disk 2 nebo 3 ?
         ja        GetStat1                 ; je disk 3
         mov       al,ds:[Stat2]            ; stav disku 2
         je        GetStat1                 ; je disk 2
         mov       al,es:[48fh]             ; stavov˜ bajt mechnaik
         or        bl,bl                    ; je disk 0 ?
         jz        GetStat1                 ; je disk 0
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1                     ; rotace pro disk 1
GetStat1:and       al,7                     ; ponech  se spr vn˜ po‡et bit–
         ret

GetStat  ENDP

; -----------------------------------------------------------------------------
;        Nastaven¡ stavov‚ho bajtu disku
; -----------------------------------------------------------------------------
; VSTUP: BL=‡¡slo disku
;        AL=stav disku
;        ES=0
;        DS=CS
; -----------------------------------------------------------------------------

PUBLIC   SetStat
SetStat  PROC      NEAR

         push      ax
         and       al,7                     ; ponechaj¡ se jen spr vn‚ bity
         cmp       bl,2                     ; jsou bajty v BIOS-RAM ?
         jb        SetStat2                 ; jsou disky 0 nebo 1

; ------ nastaven¡ disk– 2 nebo 3 (vlastn¡ bajty)

         ja        SetStat1                 ; je disk 3
         mov       byte ptr ds:[Stat2],al   ; nastaven¡ stavov‚ho bajtu disku 2
         jmp       short SetStat5           ; n vrat
SetStat1:mov       byte ptr ds:[Stat3],al   ; nastaven¡ stavov‚ho bajtu disku 3
         jmp       short SetStat5           ; n vrat

; ------ nastaven¡ disku 1

SetStat2:or        bl,bl                    ; je disk 0 ?
         jz        SetStat3                 ; je disk 0
         shl       al,1
         shl       al,1
         shl       al,1
         shl       al,1                     ; rotace pro disk 1 na pozici
         and       byte ptr es:[48fh],not 70h ; zru¨en¡ star‚ho nastaven¡
         jmp       short SetStat4           ; nastaven¡ disku 1

; ------ nastaven¡ disku 0

SetStat3:and       byte ptr es:[48fh],not 7 ; zru¨en¡ star‚ho nastaven¡ disku 0
SetStat4:or        es:[48fh],al             ; nastaven¡ disk– 0 nebo 1

SetStat5:pop       ax
         ret

SetStat  ENDP

; -----------------------------------------------------------------------------
;        Poskytnut¡ typu disku
; -----------------------------------------------------------------------------
; VSTUP: BL=po‘adovan˜ disk
;        DS=CS
; VSTUP:AL=typ disku (0 a‘ 4)
;        ZY=disk nen¡ definov n nebo chyba (AL=0)
; -----------------------------------------------------------------------------

PUBLIC   GetTyp
GetTyp   PROC      NEAR

         push      bx
         xor       bh,bh                    ; BX = po‘adovan˜ disk
         mov       al,ds:[DefDisk+bx]       ; typ disku
         cmp       al,4                     ; je povolen˜ typ disku ?
         jbe       GetTyp1                  ; povolen‚ ‡¡slo disku
         xor       al,al                    ; disk nen¡ definov n
GetTyp1: or        al,al                    ; p©¡znak ZY=disk nen¡ definov n
         pop       bx
         ret

GetTyp   ENDP

; -----------------------------------------------------------------------------
;        Poskytnut¡ disketov‚ho parametru AL
; -----------------------------------------------------------------------------
; VSTUP: ES=0
;        BL=‡¡slo disku
;        AL=‡¡slo parametru (offset v tabulce parametr–)
; VSTUP:AL=parametr z tabulky
; -----------------------------------------------------------------------------

PUBLIC   GetPar
GetPar   PROC      NEAR

         push      bx
         push      si
         push      ds
         lds       si,es:[4*1eh]
         xor       bh,bh
         mov       bl,al
         mov       al,ds:[si+bx]
         pop       ds
         pop       si
         pop       bx
         ret

GetPar   ENDP



; *****************************************************************************
;        Obsluhy ‡ek n¡
; *****************************************************************************


; -----------------------------------------------------------------------------
;        €ek n¡ na p©ipravenost ©adi‡e
; -----------------------------------------------------------------------------
; VSTUP: BL=disk
;        AH=po‘adovan˜ stav portu (maskovan˜ 0c0h)
;        DS=CS
; VSTUP:AH=k¢d chyby (0=operace OK)
;        ZY=operace OK, NZ=chyba operace TIME-OUT
; Zni‡en‚ registry: AL
; -----------------------------------------------------------------------------

PUBLIC   WaitPort
WaitPort PROC      NEAR

         push      dx                       ; £schova DX
         mov       byte ptr ds:[Counter],20;10 ; doba asi 1/2 sekundy
         call      GetPrt4                  ; stavov˜ registr ©adi‡e

; ------ ‡ek n¡ na p©ipravenost ©adi‡e

WaitPrt1:in        al,dx                    ; ‡ten¡ stavov‚ho registru ©adi‡e
         and       al,0c0h                  ; bity p©ipravenosti
         cmp       al,ah                    ; je ©adi‡ p©ipraven ?
         je        WaitPrt2                 ; ©adi‡ je ji‘ p©ipraven
         cmp       byte ptr ds:[Counter],0  ; uplynul ji‘ zadan˜ ‡as ?
         jne       WaitPrt1                 ; ‡as je¨tˆ neuplynul

; ------ p©ekro‡en¡ doby - chyba TIME-OUT

         mov       ah,80h                   ; p©¡znak chyby TIME-OUT
         jmp       short WaitPrt3           ; n vrat z obsluhy

; ------ ©adi‡ je p©ipraven

WaitPrt2:xor       ah,ah                    ; p©¡znak, ‘e ©adi‡ je p©ipraven
WaitPrt3:or        ah,ah                    ; test p©¡znaku chyby
         pop       dx
         ret

WaitPort ENDP

; -----------------------------------------------------------------------------
;        Nepodm¡nˆn‚ ‡ek n¡ po zadanou dobu
; -----------------------------------------------------------------------------
; VSTUP: AX=maxim ln¡ ‡ekac¡ doba (n sobek 30 us)
;        DS=CS
; -----------------------------------------------------------------------------t  

PUBLIC   WaitT
WaitT    PROC      NEAR

         push      cx
         mov       cx,ax                    ; ni‘¨¡ slovo ‡¡ta‡e
WaitT1:  call      Wait0                    ; ‡ek n¡ po dobu 30 mikrosekund
         loop      WaitT1                   ; dal¨¡ ‡ek n¡
         pop       cx
         ret

WaitT    ENDP

; -----------------------------------------------------------------------------
;        €ek n¡ po dobu 30 us
; -----------------------------------------------------------------------------
; VSTUP: DS=CS
; -----------------------------------------------------------------------------

PUBLIC   Wait0
Wait0    PROC      NEAR

         push      ax

; ------ pokud je XT, je zvl ¨tn¡ ‡ekac¡ prodleva

         cmp       byte ptr ds:[TimAT],1    ; je ‡asova‡ AT ?
         je        Wait01                   ; je ‡asova‡ AT
         push      cx

         mov       cx,15                    ; 17 takt– = 3.5 us (+ rezerva)

;         mov       cx,6                     ; 17 takt– = 3.5 us (+ rezerva)
         loop      $                        ; prodleva pro XT asi 30 us
         pop       cx
         jmp       short Wait03             ; dal¨¡ test

; ------ ‡ek n¡ na stav 0 sign lu hodin

Wait01:  in        al,[61h]                 ; syst‚mov‚ stavov‚ slovo
         test      al,10h                   ; jsou hodiny na £rovni 0 ?
         jnz       Wait01                   ; ‡ek n¡ na stav 0 sign lu hodin

; ------ ‡ek n¡ na stav 1 sign lu hodin

Wait02:  in        al,[61h]                 ; syst‚mov‚ stavov‚ slovo
         test      al,10h                   ; jsou hodiny na £rovni 1 ?
         jz        Wait02                   ; ‡ek n¡ na stav 1 sign lu hodin

Wait03:  pop       ax
         ret

Wait0    ENDP

; -----------------------------------------------------------------------------
;        Poskytnut¡ adresy portu
; -----------------------------------------------------------------------------
; VSTUP: BL=‡¡slo disku
; VSTUP:DX=adresa portu
; -----------------------------------------------------------------------------

PUBLIC   GetPrt2
GetPrt2: mov       dl,2
         jmp       short GetPrt


PUBLIC   GetPrt4
GetPrt4: mov       dl,4
         jmp       short GetPrt


PUBLIC   GetPrt5
GetPrt5: mov       dl,5
         jmp       short GetPrt


PUBLIC   GetPrt7
GetPrt7: mov       dl,7


GetPrt:  xor       dh,dh                    ; DX = offset adresy portu
         cmp       bl,2                     ; je disk 0,1 nebo 2,3 ?
         jb        GetPrt0                  ; jsou disky 0 nebo 1
         add       dx,cs:[AdrPort2]         ; adresa portu 2
         ret

GetPrt0: add       dx,cs:[AdrPort1]         ; adresa portu 1
         ret

; *****************************************************************************
;
;        Instalace programu
;
; *****************************************************************************

Init     PROC      NEAR

                                          ;* £vodn¡ text
         mov       dx,offset UvTxt          ; £vodn¡ text
         mov       ah,9
         int       21h                      ; zobrazen¡ £vodn¡ho textu

; ------ test, zda je sign l hodin (port 61h)

         mov       cx,63230                 ; max. doba testu

; ------ ‡ek n¡ na stav 0 sign lu hodin

Init01:  in        al,[61h]                 ; syst‚mov‚ stavov‚ slovo
         test      al,10h                   ; jsou hodiny na £rovni 0 ?
         loopnz    Init01                   ; ‡ek n¡ na stav 0 sign lu hodin
         jcxz      Init08                   ; nen¡ ‡asova‡ AT

; ------ ‡ek n¡ na stav 1 sign lu hodin

Init02:  in        al,[61h]                 ; syst‚mov‚ stavov‚ slovo
         test      al,10h                   ; jsou hodiny na £rovni 1 ?
         loopz     Init02                   ; ‡ek n¡ na stav 1 sign lu hodin
         jcxz      Init08                   ; nen¡ ‡asova‡ AT

; ------ ‡ek n¡ na stav 0 sign lu hodin

Init03:  in        al,[61h]                 ; syst‚mov‚ stavov‚ slovo
         test      al,10h                   ; jsou hodiny na £rovni 0 ?
         loopnz    Init03                   ; ‡ek n¡ na stav 0 sign lu hodin
         jcxz      Init08                   ; nen¡ ‡asova‡ AT

; ------ ‡ek n¡ na stav 1 sign lu hodin

Init04:  in        al,[61h]                 ; syst‚mov‚ stavov‚ slovo
         test      al,10h                   ; jsou hodiny na £rovni 1 ?
         loopz     Init04                   ; ‡ek n¡ na stav 1 sign lu hodin
         jcxz      Init08                   ; nen¡ ‡asova‡ AT

         mov       byte ptr ds:[TimAt],1    ; p©¡znak ‡asova‡e AT

Init08:

; ------ test, zda je po‡¡ta‡ AT

         push      es
         mov       ax,0f000h
         mov       es,ax
         mov       al,es:[0fffeh]           ; identifik tor syst. modelu
         pop       es
         cmp       al,0fch                  ; je AT ?
         ja        Init09                   ; nen¡ AT
         mov       byte ptr ds:[WaitAT],1   ; p©¡znak oznamov n¡ ‡ek n¡ AT

Init09:

                                          ;* dek¢dov n¡ parametr–
         cld                                ; smˆr nahoru
         mov       si,81h                   ; za‡ tek textu parametr–
         mov       di,offset DefDisk        ; tabulka definic disk–
         xor       cx,cx                    ; CX <- 0
         mov       cl,ds:[80h]              ; d‚lka p©¡kazov‚ho © dku
Init1:   jcxz      Init3                    ; konec textu
         lodsb                              ; na‡ten¡ znaku parametr–
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e znak–
         cmp       al,13                    ; je konec textu ?
         je        Init3                    ; je konec textu
         cmp       al," "                   ; je oddˆlova‡ ?
         jbe       Init1                    ; je oddˆlova‡
         cmp       al,","
         je        Init1
         cmp       al,";"
         je        Init1
         cmp       al,"/"
         je        Init1
         sub       al,"0"                   ; korekce znaku na ‡¡slo
         jc        Init2                    ; nen¡ platn˜ znak
         cmp       al,4
         ja        Init2                    ; nen¡ platn‚ ‡¡slo typu disku
         stosb                              ; ulo‘en¡ ‡¡sla disku
         jmp       short Init1              ; dek¢dov n¡ dal¨¡ho znaku

Init2:   mov       dx,offset HlpTxt         ; text n povˆdy
         mov       ah,9
         int       21h                      ; zobrazen¡ textu n povˆdy
         int       20h                      ; n vrat s chybou

Init3:   cmp       di,offset DefDisk        ; byl nainstalov n nˆjak˜ disk ?
         je        Init2                    ; nebyl zad n ‘ dn˜ disk
         cmp       di,offset DefDisk+2      ; bylo zad no v¡c ne‘ 2 disky ?
         jbe       Init4                    ; byly 2 disky nebo m‚nˆ
         inc       byte ptr ds:[ParCtr2]    ; p©¡znak instalace ©adi‡e #2

Init4:
                                          ;* reset disk–
         mov       ah,0dh
         int       21h                      ; reset diskov‚ho syst‚mu
         xor       ax,ax
         xor       dx,dx
         int       13h                      ; reset disk–

                                          ;* instalace obsluhy INT 40h
         mov       ax,3540h
         int       21h                      ; poskynut¡ adresy obsluhy ITN 40h
         mov       word ptr ds:[Old40],bx   ; offset p–vodn¡ obsluhy INT 40h
         mov       word ptr ds:[Old40+2],es ; segment p–vodn¡ obsluhy INT 40h
         mov       dx,offset Int40          ; vlastn¡ obsluha INT 40h
         mov       ax,2540h
         int       21h                      ; instalace vlastn¡ obsluhy INT 40h

                                          ;* instalace obsluhy INT 08h
         mov       ax,3508h
         int       21h                      ; poskynut¡ adresy obsluhy ITN 08h
         mov       word ptr ds:[Old08],bx   ; offset p–vodn¡ obsluhy INT 08h
         mov       word ptr ds:[Old08+2],es ; segment p–vodn¡ obsluhy INT 08h
         mov       dx,offset Int08          ; vlastn¡ obsluha INT 08h
         mov       ax,2508h
         int       21h                      ; instalace vlastn¡ obsluhy INT 08h


         xor       ax,ax
         mov       es,ax                    ; ES <- 0

         mov       bl,0
         call      DrvDet0
         mov       bl,1
         call      DrvDet0
         mov       bl,2
         call      DrvDet0
         mov       bl,3
         call      DrvDet0

;         call      FlopIni                  ; inicializace diskov‚ho syst‚mu



PUBLIC   TestT
TestT:
;         mov       ah,2
;         mov       al,9
;         mov       ch,1
;         mov       cl,1
;         mov       dh,0
;         mov       dl,0
;         push      cs
;         pop       es
;         mov       bx,offset uvtxt
;         int       40h

ifdef    DEBUG
         mov       ax,1701h
         mov       dl,0
         int       13h
         mov       ax,1704h
         mov       dl,0
         int       13h
         mov       ax,1705h
         mov       dl,0
         int       13h
ENDIF


         push      ds
         xor       ax,ax
         mov       ds,ax
         lds       bx,ds:[78h]              ; adresa INT 1eh
         mov       byte ptr ds:[bx+0ah],3   ; ‡as pro spu¨tˆn¡ motoru
         pop       ds

                                           ;* reset disk– po instalaci

         mov       ah,0dh
         int       21h                      ; reset diskov‚ho syst‚mu
         xor       ax,ax
         xor       dx,dx
         int       13h                      ; reset disk–
                                          ;* instalace programu
IFNDEF   DEBUG
         mov       dx,offset Init           ; konec rezidentn¡ ‡ sti programu
         int       27h                      ; instalace programu
ELSE

PUBLIC   Navrat
Navrat:

         lds       dx,cs:[Old08]            ; offset p–vodn¡ obsluhy INT 08h
         mov       ax,2508h
         int       21h                      ; instalace vlastn¡ obsluhy INT 08h

         lds       dx,cs:[Old40]            ; offset p–vodn¡ obsluhy INT 40h
         mov       ax,2540h
         int       21h                      ; instalace vlastn¡ obsluhy INT 40h

         int       20h

ENDIF

Init     ENDP



;; -----------------------------------------------------------------------------
;;        Inicializace diskov‚ho syst‚mu
;; -----------------------------------------------------------------------------
;
;PUBLIC   FlopIni
;FlopIni  PROC      NEAR
;
;         pushf
;         push      ax
;         push      bx
;         push      cx
;         push      dx
;         push      si
;         push      di
;         push      bp
;         push      ds
;         push      es
;
;         cld                                ; smˆr nahoru
;         push      cs
;         pop       ds                       ; DS <- CS
;         xor       ax,ax
;         mov       es,ax                    ; ES <- 0
;
;         lea       di,cs:[43eh]             ; tabulka disketov˜ch parametr–
;         mov       cx,11                    ; po‡et bajt– k inicializaci
;         xor       ax,ax                    ; AX <- 0
;         rep       stosb                    ; vymaz n¡ syst‚mov˜ch tabulek
;
;         lea       di,cs:[48fh]
;         mov       cx,7
;         rep       stosb
;
;         and       byte ptr es:[48bh],0cch
;         or        byte ptr es:[48bh],88h
;
;         mov       byte ptr es:[48bh],88h
;
;         xor       bl,bl
;         mov       al,2
;         call      GetPrt7
;         out       dx,al
;         mov       bl,2
;         call      GetPrt7
;         out       dx,al
;
;         call      Funkce00                 ; reset diskov‚ho syst‚mu
;
;         mov       bl,0                     ; disk 0
;         call      DrvDet                   ; ur‡en¡, zda je mechanika 40 stop
;         mov       bl,1                     ; disk 1
;         call      DrvDet                   ; ur‡en¡, zda je mechanika 40 stop
;         mov       bl,2                     ; disk 2
;         call      DrvDet                   ; ur‡en¡, zda je mechanika 40 stop
;         mov       bl,3                     ; disk 3
;         call      DrvDet                   ; ur‡en¡, zda je mechanika 40 stop
;
;         call      Funkce00                 ; reset diskov‚ho syst‚mu
;
;         mov       al,2
;         call      GetPar                   ; poskytnut¡ parametru 2
;         call      SetMOff                  ; nastaven¡ ‡¡ta‡– pro vypnut¡ mot.
;
;         pop       es
;         pop       ds
;         pop       bp
;         pop       di
;         pop       si
;         pop       dx
;         pop       cx
;         pop       bx
;         pop       ax
;         popf
;
;         ret
;
;FlopIni  ENDP
;
;
;; -----------------------------------------------------------------------------
;;        Ur‡en¡, zda je mechanika 40 nebo 80 stop
;; -----------------------------------------------------------------------------
;; VSTUP: BL=‡¡slo disku
;;        ES=0
;;        DS=CS
;; Zni‡en‚ registry: AX
;; -----------------------------------------------------------------------------
;
;PUBLIC   DrvDet
;DrvDet   PROC      NEAR
;
;         push      cx
;         push      dx
;
;; ------ zapnut¡ motoru
;
;         call      MotorOn                  ; zapnut¡ motoru
;
;; ------ zru¨en¡ p©¡znaku dvoj¡ho krokov n¡
;
;         call      GetMed                   ; poskytnut¡ bajtu stavu m‚dia
;         and       al,not 20h               ; nulov n¡ p©¡znaku dvoj¡ho krokov.
;         call      SetMed                   ; nastaven¡ bajtu stavu m‚dia
;
;; ------ nulov n¡ p©¡znaku rekalibrace
;
;         call      NulRec                   ; nulov n¡ p©¡znaku rekalibrace
;
;; ------ vystaven¡ na stopu 50 (mechanika 40 stop se zastav¡ na dorazu)
;
;         xor       dx,dx                    ; p©ednastaven¡ - nen¡ ‘ dn˜ disk
;         mov       al,50                    ; po‘adovan  stopa 50
;         call      Seek                     ; vystaven¡ na stopu 50
;         jnz       DrvDet3                  ; byla chyba vystaven¡ - nen¡ nech.
;
;; ------ nalezen¡ stopy 0
;
;         mov       ch,11                    ; v˜choz¡ stopa 10
;DrvDet1: dec       ch                       ; sn¡‘en¡ ‡¡sla stopy
;         js        DrvDet2                  ; p©ekro‡ena stopa 0 - chyba
;         mov       al,ch                    ; po‘adovan  stopa
;         call      Seek                     ; vystaven¡ na po‘adovanou stopu
;         jnz       DrvDet3                  ; byla chyba operace - nen¡ mech.
;
;; ------ vysl n¡ povelu SENSE DRIVE STATUS
;
;         mov       cl,bl                    ; po‘adovan˜ disk
;         and       cl,1                     ; disk relativnˆ (0 nebo 1)
;         push      cx                       ; po‘adovan˜ disk
;         mov       si,sp                    ; ukazatel dat v z sobn¡ku
;         mov       al,4                     ; povel SENSE DRIVE STATUS
;         mov       ah,2                     ; po‡et bajt–
;         call      NECOutp                  ; vysl n¡ povelu SENSE DRIVE STATUS
;         pop       cx                       ; n vrat po‘adovan‚ho disku
;         jnz       DrvDet3                  ; chyba operace
;
;; ------ test v˜sledku operace - zda bylo dosa‘eno stopy 0
;
;         call      Result                   ; p©¡jem v˜sledku operace
;         jnz       DrvDet3                  ; byla chyba operace
;         xor       al,al                    ; parametr 0 - registr ST3
;         call      GetRes                   ; poskytnut¡ registru 3
;         test      al,10h                   ; bylo dosa‘eno stopy 0 ?
;         jz        DrvDet1                  ; stopa 0 nenalezena - dal¨¡
;
;; ------ nalezena stopa 0 - rozli¨en¡ mechaniky podle ‡¡sla stopy
;
;DrvDet2: mov       dl,1                     ; p©¡znaky - je 80 stop
;         mov       dh,2                     ; stavov˜ bajt - 1.2 MB v 1.2 MB
;         or        ch,ch                    ; byla stopa 0 ?
;         jz        DrvDet3                  ; byla stopa 0 - je mech. 80 stop
;         mov       dl,4                     ; p©¡znaky - ur‡en  mech. 40 stop
;         mov       dh,93h                   ; stavov˜ bajt - 360 KB v 360 KB
;         call      NulRec                   ; vy‘aduje se opˆt rekalibrace
;
;; ------ nastaven¡ zji¨tˆn‚ho typu mechaniky a inic. typu m‚dia
;
;DrvDet3: mov       al,dh                    ; inicializa‡n¡ typ m‚dia
;         call      SetMed                   ; nastaven¡ bajtu stavu m‚dia
;         mov       al,dl                    ; typ mechaniky
;         call      SetStat                  ; nastaven¡ stavov‚ho bajtu disku
;
;         pop       dx
;         pop       cx
;         ret
;
;DrvDet   ENDP
;

; ------ ur‡en¡ typu m‚dia podle CMOS (p©i inicializaci)

DrvDet0:; push      cx
        ; push      dx
         xor       dx,dx                    ; p©ednastaven¡ - ‘ dn˜ disk
         call      GetTyp                   ; poskytnut¡ typu disku AL
         jz        DrvDet3                  ; nen¡ ‘ dn˜ disk
         mov       dx,9304h                 ; parametry pro mechaniku 360 KB
         cmp       al,1                     ; je mechanika 360 KB ?
         je        DrvDet3                  ; je mechanika 360 KB
         mov       dx,201h                  ; parametry pro jin‚ mechaniky
;         jmp       short DrvDet3            ; je jin  mechanika

; ------ nastaven¡ zji¨tˆn‚ho typu mechaniky a inic. typu m‚dia

DrvDet3: mov       al,dh                    ; inicializa‡n¡ typ m‚dia
         call      SetMed                   ; nastaven¡ bajtu stavu m‚dia
         mov       al,dl                    ; typ mechaniky
         call      SetStat                  ; nastaven¡ stavov‚ho bajtu disku

        ; pop       dx
        ; pop       cx
         ret


UvTxt    db        'FLOPPY V1.20 - ovladac pruznych disku; (c) Miroslav Nemecek',13,10,'$'

HlpTxt   db        13,10,'Zadejte cisla typu mechanik (max. 4 mechaniky):',13,10
         db        '        0 - mechanika nenainstalovana',13,10
         db        '        1 - 360 KB (5 1/4", 40 stop, 300 ot./min.)',13,10
         db        '        2 - 1.2 MB (5 1/4", 80 stop, 360 ot./min.)',13,10
         db        '        3 - 720 KB (5 1/4", 80 stop, 300 ot./min.)',13,10
         db        '            720 KB (3 1/2", 80 stop, 300 ot./min.)',13,10
         db        '        4 - 1.44 MB (3 1/2", 80 stop, 300 ot./min.)',13,10
         db        13,10
         db        '$'

code     ENDS
         END       start

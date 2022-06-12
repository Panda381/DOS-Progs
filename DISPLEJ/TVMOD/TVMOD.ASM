
Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; -----------------------------------------------------------------------------
;        konstanty
; -----------------------------------------------------------------------------

DELKURZ  EQU       38                       ; d‚lka kurzoru pro volby konfig.
VOLNUM   EQU       16                       ; celkovì poŸet voleb konfig.
DELKTAB  EQU       offset(InitTRT0-InitTRT) ; d‚lka jedn‚ tabulky registr…
MAXNTAB  EQU       18                       ; max. poŸet tabulek registr…

; ------ kl¡Ÿe pro identifikaci rezidentn¡ho programu

KLIC1    EQU       043ah                    ; kl¡Ÿ 1 (AX)
KLIC2    EQU       5A36h                    ; kl¡Ÿ 2 (BX)
KLIC3    EQU       0A63Eh                   ; kl¡Ÿ 3 (CX)
KLIC4    EQU       2E31h                    ; kl¡Ÿ 4 (DX)
KLIC5    EQU       6F05h                    ; kl¡Ÿ 5 (BX vìstup)

; ------ Ÿ¡sla typ… videokaret

STANDVGA EQU       0                        ; standardn¡ VGA
TRIDENT1 EQU       1                        ; Trident TVGA 8800
TRIDENT2 EQU       2                        ; Trident TVGA 8900
TRIDENT3 EQU       3                        ; Trident TVGA 9000
OAKTECHN EQU       4                        ; OAK Technology
REALTEK  EQU       5                        ; Realtek
WESTERN  EQU       6                        ; Western Digital
PARADISE EQU       7                        ; Paradise VGA

NUMCARD  EQU       8                        ; poŸet typ… videokaret

; ------ vçeobecn‚ konstanty

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

KORIG    EQU       5ch-103h                 ; korekce adres programu

; -----------------------------------------------------------------------------
;        zaŸ tek programu
; -----------------------------------------------------------------------------

Start:   jmp       Instal                   ; instalace programu

RezidBeg label     byte                     ; zaŸ tek rezidentn¡ho programu

Old10    dd        0                        ; p…vodn¡ adresa INT 10h

; ------ konfigurace

BegCnf   label     byte                     ; zaŸ tek konfigurace

Verze    db        10h                      ; verze konfiguraŸn¡ho souboru
Card     dw        STANDVGA                 ; typ videokarty

Param    db        0                        ; parametry
                                            ;  bit 0: 1=aktivn¡ TV m¢d
                                            ;  bit 1: 1=simulace EGA
                                            ;  bit 2: 1=simulace CGA

                                            ;  bit 6: 1=horiz. synchr. negativn¡
                                            ;  bit 7: 1=vert. synchr. negativn¡

EndCnf   label     byte                     ; konec konfigurace

; -----------------------------------------------------------------------------
;        obsluha INT 10h
; -----------------------------------------------------------------------------

Int10    PROC      FAR

; ------ test instalace programu

         cmp       ax,KLIC1
         jne       Int100
         cmp       bx,KLIC2
         jne       Int100
         cmp       cx,KLIC3
         jne       Int100
         cmp       dx,KLIC4
         jne       Int100
         push      cs
         pop       es                       ; ES <- rezidentn¡ segment
         mov       bx,KLIC5
Int1001: iret

; ------ omezen¡ funkc¡

Int100:  test      byte ptr cs:[Param+KORIG],b1+b2
         jz        Int1009                  ; nen¡ omezen¡ funkc¡
         cmp       ah,13h
         je        Int1009
         ja        Int1001

; ------ omezen¡ funkc¡ na CGA

         test      byte ptr cs:[Param+KORIG],b2  ; simulace CGA ?
         jz        Int1003                  ; nen¡ simulace CGA
         cmp       ax,6
         jbe       Int1009
         cmp       ah,10h
         jae       Int1001
         jmp       short Int1009

; ------ omezen¡ funkc¡ na EGA

Int1003: cmp       ax,10h
         jbe       Int1009

         cmp       ah,12h
         jne       Int1004
         cmp       bl,20h
         ja        Int1001

Int1004: cmp       ah,10h
         jne       Int1005
         cmp       al,3
         ja        Int1001

Int1005: cmp       ah,11h
         jne       Int1009
         test      al,11001100b
         jnz       Int1001
         cmp       al,30h
         jne       Int1009
         cmp       bh,5
         ja        Int1001

; ------ test, zda je zapnut televizn¡ m¢d

Int1009: cmp       ah,0                     ; inicializace videom¢du ?
         jne       Int100b                  ; nen¡ inicializace

         test      byte ptr cs:[Param+KORIG],b0 ; je zapnut TV m¢d ?
         jnz       Int100C                  ; je zapnut TV m¢d

         test      byte ptr cs:[Param+KORIG],b1+b2 ; je omezen¡ funkc¡ ?
         jz        Int100B

         push      ax
         and       al,7fh
         cmp       al,7
         je        Int10092
         cmp       al,3                     ; je textovì videom¢d ?
         ja        Int10093                 ; nen¡ textovì videom¢d
Int10092:push      bx
         mov       ax,1200h
         test      byte ptr cs:[Param+KORIG],b1 ; je EGA ?
         jz        Int10094                 ; nen¡ EGA
         inc       ax                       ; omezen¡ na EGA
Int10094:mov       bl,30h
         call      Exec10                   ; nastaven¡ m¢du 200 linek
         pop       bx
Int10093:pop       ax

Int100B: jmp       dword ptr cs:[Old10+KORIG]

; ------ pro textov‚ m¢dy nastaven¡ vertik ln¡ho rozliçen¡ 200 linek

Int100C: push      ax
         and       al,7fh
         cmp       al,7
         je        Int1012
         cmp       al,3                     ; je textovì videom¢d ?
         ja        Int1013                  ; nen¡ textovì videom¢d
Int1012: push      bx
         mov       ax,1200h
         mov       bl,30h
         call      Exec10                   ; nastaven¡ m¢du 200 linek
         pop       bx
Int1013: pop       ax

; ------ inicializace videom¢du

         call      Exec10                   ; inicializace videom¢du

; ------ inicializace videoregistr… pro TV videom¢d

Int1018: call      InitVReg                 ; inicializace registr… TV videom¢du
         iret

Int10    ENDP

; -----------------------------------------------------------------------------
;        vol n¡ funkce INT 10h
; -----------------------------------------------------------------------------

Exec10   PROC      NEAR

         pushf
         call      dword ptr cs:[Old10+KORIG]
         ret

Exec10   ENDP

; -----------------------------------------------------------------------------
;        inicializace videoregistr…
; -----------------------------------------------------------------------------

InitVReg PROC      NEAR

; ------ £schova registr…

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es

; ------ oprava pro videom¢d 7

         xor       ax,ax
         mov       ds,ax
         mov       al,ds:[449h]
         and       al,7fh
         cmp       al,3
         jbe       InitVRg0
         cmp       al,7
         jne       InitVRg1

         mov       ax,1112h
         mov       bl,0
         call      Exec10

         mov       byte ptr ds:[484h],24
         and       byte ptr ds:[487h],not b0

InitVRg0:mov       word ptr ds:[460h],607h

; ------ pý¡prava registr…

InitVRg1:xor       ax,ax
         mov       es,ax                    ; ES <- 0
         push      cs
         pop       ds                       ; DS <- CS
         cld
         cli

; ------ kontrola Ÿ¡sla videom¢du

         mov       bl,es:[449h]
         and       bl,7fh
         cmp       bl,13h
         jbe       initVRg3
InitVRg2:jmp       InitVRg9

; ------ stanoven¡ Ÿ¡sla tabulky

InitVRg3:mov       bh,0
         mov       ah,ds:[bx+TabInit+KORIG]  ; Ÿ¡slo tabulky
         cmp       ah,-1
         je        InitVRg2

; ------ adresa definiŸn¡ tabulky

         mov       al,DELKTAB               ; d‚lka tabulky registr…
         mul       ah                       ; offset v tabulce
         add       ax,offset InitTRT+KORIG  ; adresa tabulky
         xchg      ax,si                    ; SI <- adresa tabulky registr…

; ------ nastaven¡ registru m¢du (3C0h/10h)

         mov       ah,10h
         call      Get3C0
         or        al,b2
         call      Set3C0

; ------ nastaven¡ posunu bod… PANNING (3C0h/13h)

         lodsb
         mov       ah,13h
         call      Set3C0

; ------ reset ýadiŸe

         mov       ax,1
         call      Set3C4                   ; reset ýadiŸe

; ------ nastaven¡ registru taktov n¡ (3C4h/01h)

         lodsb
         mov       ah,1
         call      Set3C4

         cmp       al,b0                    ; TRIDENT 320x200/256
         jne       InitVR32

         mov       ah,0dh
         call      Get3C4
         or        al,b1
         call      Set3C4

; ------ nastaven¡ frekvence hodin a polarity synchronizace (3C2h)

InitVR32:mov       dx,3CCh
         in        al,dx
         and       al,00110011b
         mov       ah,al
         lodsb
         or        al,ah
         mov       ah,ds:[Param+KORIG]
         and       ah,0c0h
         or        al,ah
         mov       dx,3C2h
         out       dx,al                    ; nastaven¡ ý¡dic¡ch funkc¡

; ------ pý¡prava adresy ýadiŸe displeje

         mov       dl,0b4h
         test      al,b0
         jz        InitVRg4
         mov       dl,0d4h

; ------ uvolnØn¡ ýadiŸe CRT

InitVRg4:mov       ax,3
         call      Set3C4

; ------ povolen¡ pý¡stupu k registr…m

         mov       ax,380h
         call      SetCRT                   ; povolen¡ pý¡stupu pomoc¡ 03h
         mov       ax,1100h
         call      SetCRT                   ; povolen¡ pý¡stupu pomoc¡ 11h

; ------ nastaven¡ registr… CRT

         mov       ah,0
InitVRg5:lodsb
         call      SetCRT
InitVRg6:inc       ah
         cmp       ah,8
         jb        InitVRg5
         je        InitVRg6
         cmp       ah,0ch
         jb        InitVRg5
         cmp       ah,10h
         jb        InitVRg6
         cmp       ah,18h
         jb        InitVRg5

; ------ inicializace hodin videokarty

         mov       si,ds:[Card+KORIG]
         shl       si,1
         cmp       bl,1
         jbe       InitVR71
         cmp       bl,4
         jb        InitVR72
         cmp       bl,6
         jb        InitVR71
         cmp       bl,13
         jne       InitVR72
InitVR71:call      word ptr ds:[si+IniCCard+KORIG]

; ------ inicializace prokl d n¡ videokarty

InitVR72:cmp       bl,15
         jb        InitVR73
         cmp       bl,19
         jae       InitVR73
         call      word ptr ds:[si+IniICard+KORIG]

; ------ uvolnØn¡ displeje

InitVR73:call      DispOn

; ------ n vrat registr…

InitVRg9:pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

InitVReg ENDP

IniCCard label     word                     ; inicializace hodin karet
         dw        IniCStd+KORIG            ; standardn¡ VGA
         dw        IniCStd+KORIG            ; TRIDENT 8800
         dw        IniCTRI+KORIG            ; TRIDENT 8900
         dw        IniCTRI+KORIG            ; TRIDENT 9000
         dw        IniCOAK+KORIG            ; OAK
         dw        IniCRea+KORIG            ; Realtek
         dw        IniCStd+KORIG            ; Western
         dw        IniCStd+KORIG            ; Paradise

IniICard label     word                     ; inicializace prokl d n¡ karet
         dw        IniIStd+KORIG            ; standardn¡ VGA
         dw        IniITRI+KORIG            ; TRIDENT 8800
         dw        IniITRI+KORIG            ; TRIDENT 8900
         dw        IniITRI+KORIG            ; TRIDENT 9000
         dw        IniIOAK+KORIG            ; OAK
         dw        IniIRea+KORIG            ; Realtek
         dw        IniIWes+KORIG            ; Western
         dw        IniIWes+KORIG            ; Paradise
;þ
; -----------------------------------------------------------------------------
;        inicializace hodin TRIDENT
; -----------------------------------------------------------------------------

IniCTRI: mov       ah,0bh
         call      Set3C4
         call      Get3C4
         mov       ah,0dh
         call      Get3C4
         or        al,b1
         call      Set3C4
         mov       ah,0bh
         call      Set3C4
IniCStd: ret

; -----------------------------------------------------------------------------
;        inicializace hodin OAK (hodiny 14 MHz - m¢d emulace EGA)
; -----------------------------------------------------------------------------

IniCOAK: push      dx
         mov       dl,0deh
         mov       ah,0dh
         call      GetCRT
         or        al,b5
         call      SetCRT
         pop       dx
         ret

; -----------------------------------------------------------------------------
;        inicializace hodin Realtek (hodiny 14 MHz - m¢d emulace EGA)
; -----------------------------------------------------------------------------

IniCRea: push      dx
         mov       dl,0ceh
         mov       ah,0bh
         call      GetCRT
         or        al,b1
         call      SetCRT
         pop       dx
         ret

; -----------------------------------------------------------------------------
;        inicializace prokl d n¡ TRIDENT
; -----------------------------------------------------------------------------

IniITRI: mov       ah,1eh
         call      GetCRT
         or        al,b2
         call      SetCRT
IniIStd: ret

; -----------------------------------------------------------------------------
;        inicializace prokl d n¡ OAK
; -----------------------------------------------------------------------------

IniIOAK: push      dx
         mov       dx,3deh
         mov       ax,1480h
         call      SetCRT
         mov       ax,152fh
         call      SetCRT
         pop       dx
         ret

; -----------------------------------------------------------------------------
;        inicializace prokl d n¡ Realtek
; -----------------------------------------------------------------------------

IniIRea: mov       ah,19h
         call      GetCRT
         or        al,b0
         call      SetCRT
         ret

; -----------------------------------------------------------------------------
;        inicializace prokl d n¡ Western a Paradise
; -----------------------------------------------------------------------------

IniIWes: mov       ax,2c25h
         call      SetCRT
         mov       ax,2d24h                 ; b7=pýeruçen¡, b5=IRQ, b2=prokl d.
         call      SetCRT
         ret

; -----------------------------------------------------------------------------
;        Ÿten¡ registru AH portu 3C0h do AL
; -----------------------------------------------------------------------------

Get3C0   PROC      NEAR

         push      dx
         mov       dx,3dah
         in        al,dx
         mov       dl,0bah
         in        al,dx
         mov       dl,0c0h
         mov       al,ah
         out       dx,al
         jmp       short $+2
         inc       dx
         in        al,dx
         pop       dx
         ret

Get3C0   ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ registru AH portu 3C0h na AL
; -----------------------------------------------------------------------------

Set3C0   PROC      NEAR

         push      dx
         push      ax
         mov       dx,3dah
         in        al,dx
         mov       dl,0bah
         in        al,dx
         mov       dl,0c0h
         jmp       short $+2
         mov       al,ah
         out       dx,al
         pop       ax
         jmp       short $+2
         out       dx,al
         pop       dx
         ret

Set3C0   ENDP

; -----------------------------------------------------------------------------
;        Ÿten¡ registru AH portu 3C4h do AL
; -----------------------------------------------------------------------------

Get3C4   PROC      NEAR

         push      dx
         mov       dx,3C4h
         mov       al,ah
         out       dx,al
         inc       dx
         jmp       short $+2
         in        al,dx
         pop       dx
         ret

Get3C4   ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ registru AH portu 3C4h na AL
; -----------------------------------------------------------------------------

Set3C4   PROC      NEAR

         push      dx
         mov       dx,3C4h
         xchg      al,ah
         out       dx,al
         xchg      al,ah
         inc       dx
         jmp       short $+2
         out       dx,al
         pop       dx
         ret

Set3C4   ENDP

; -----------------------------------------------------------------------------
;        Ÿten¡ registru AH ýadiŸe CRT do AL (adresa DX)
; -----------------------------------------------------------------------------

GetCRT   PROC      NEAR

         mov       al,ah
         out       dx,al
         inc       dx
         jmp       short $+2
         in        al,dx
         dec       dx
         ret

GetCRT   ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ registru AH ýadiŸe CRT na AL (adresa DX)
; -----------------------------------------------------------------------------

SetCRT   PROC      NEAR

         xchg      al,ah
         out       dx,al
         xchg      al,ah
         inc       dx
         jmp       short $+2
         out       dx,al
         dec       dx
         ret

SetCRT   ENDP

; -----------------------------------------------------------------------------
;        uvolnØn¡ displeje
; -----------------------------------------------------------------------------

DispOn   PROC      NEAR

         push      dx
         mov       dx,3dah
         in        al,dx
         mov       dl,0bah
         in        al,dx
         mov       dl,0c0h
         jmp       short $+2
         mov       al,20h
         out       dx,al
         pop       dx
         ret

DispOn   ENDP

TabInit  label     byte                     ; tabulka pro inicializaci
         db        0                        ; 00h: text 40x25/16
         db        0                        ; 01h: text 40x25/16
         db        1                        ; 02h: text 80x25/16
         db        1                        ; 03h: text 80x25/16
         db        2                        ; 04h: graf 320x200/4
         db        2                        ; 05h: graf 320x200/4
         db        3                        ; 06h: graf 640x200/2
         db        4                        ; 07h: text 80x25/16
         db        -1                       ; 08h
         db        -1                       ; 09h
         db        -1                       ; 0Ah
         db        -1                       ; 0Bh
         db        -1                       ; 0Ch
         db        5                        ; 0dh: graf 320x200/16
         db        6                        ; 0eh: graf 640x200/16
         db        7                        ; 0fh: graf 640x350/2
         db        7                        ; 10h: graf 640x350/16
         db        8                        ; 11h: graf 640x480/2
         db        8                        ; 12h: graf 640x480/16
         db        9                        ; 13h: graf 320x200/256

InitTRT  label     byte

; ------ 0: 0, 1 (text 40x25/16) standard, TRIDENT 8800
;þ
         db        8                        ; 3C0h/13h: posun bod… PANNING
         db        b3                       ; 3C4h/01h: m¢t taktov n¡
         db        0*b2                     ; 3C2h: frekvence hodin
         db        84                       ; 0: poŸet horiz. pozic celkem - 5
         db        39                       ; 1: poŸet zobrazenìch znak… - 1
         db        56                       ; 2: poŸ tek horizont l. zatemnØn¡
         db        ((56+17) AND 1fh)+b7     ; 3: konec horizont ln¡ho zatemnØn¡
         db        61                       ; 4: poŸ tek horiz. synchronizace
         db        ((61+6) AND 1fh)+(4*((56+17) AND 20h)) ; 5: konec hor.synchr.
         db        (312-2) AND 0ffh         ; 6: poŸet vertik. linek celkem - 2
         db        b0+b4                    ; 7: doplåuj¡c¡ bity registr…
         db        7+b6                     ; 9: poŸet linek na znak - 1
         db        7                        ; 0Ah: poŸ teŸn¡ linka kurzoru
         db        7                        ; 0Bh: koncov  linka kurzoru
         db        252                      ; 10h: zaŸ tek vertik. synchronizace
         db        (252+4) AND 0fh + b7     ; 11h: d‚lka vertik. synchronizace
         db        199                      ; 12h: posledn¡ zobrazen  linka
         db        20                       ; 13h: pý¡rustek adresy v pamØti/2
         db        31                       ; 14h: podtr§en¡ MDA
         db        244                      ; 15h: zaŸ tek vertik l. zatemnØn¡
         db        (244+25) AND 0ffh        ; 16h: konec vertik ln¡ho zatemnØn¡
         db        b7+b5+b1+b0              ; 17h: ý¡dic¡ registr m¢du pamØti
InitTRT0 label     byte

; ------ 1: 2, 3 (text 80x25/16) standard, TRIDENT 8800

         db        0                        ; 3C0h/13h: posun bod… PANNING
         db        b3+b0                    ; 3C4h/01h: m¢t taktov n¡
         db        1*b2                     ; 3C2h: frekvence hodin
         db        107                      ; 0: poŸet horiz. pozic celkem - 5
         db        79                       ; 1: poŸet zobrazenìch znak… - 1
         db        85                       ; 2: poŸ tek horiz. zatemnØn¡
         db        ((85+21) AND 1fh)+b7     ; 3: ç¡ýka horiz. zatemnØn¡
         db        90                       ; 4: poŸ tek horiz. synchronizace
         db        ((90+8) AND 1fh)+(4*((85+21) AND 20h)) ; 5: ç¡ýka hor.synchr.
         db        (312-2) AND 0ffh         ; 6: poŸet vertik. linek celkem - 2
         db        b0+b4                    ; 7: doplåuj¡c¡ bity registr…
         db        7+b6                     ; 9: poŸet linek na znak - 1
         db        7                        ; 0Ah: poŸ teŸn¡ linka kurzoru
         db        7                        ; 0Bh: koncov  linka kurzoru
         db        252                      ; 10h: zaŸ tek vertik. synchronizace
         db        (252+4) AND 0fh + b7     ; 11h: d‚lka vertik. synchronizace
         db        199                      ; 12h: posledn¡ zobrazen  linka
         db        40                       ; 13h: pý¡rustek adresy v pamØti/2
         db        31                       ; 14h: podtr§en¡ MDA
         db        244                      ; 15h: zaŸ tek vertik l. zatemnØn¡
         db        (244+25) AND 0ffh        ; 16h: konec vertik ln¡ho zatemnØn¡
         db        b7+b5+b1+b0              ; 17h: ý¡dic¡ registr m¢du pamØti

; ------ 2: 4, 5: (grafika 320x200/4) standard, TRIDENT 8800

         db        0                        ; 3C0h/13h: posun bod… PANNING
         db        b3+b0                    ; 3C4h/01h: m¢t taktov n¡
         db        0*b2                     ; 3C2h: frekvence hodin
         db        95                       ; 0: poŸet horiz. pozic celkem - 5
         db        39                       ; 1: poŸet zobrazenìch znak… - 1
         db        61                       ; 2: poŸ tek horizont l. zatemnØn¡
         db        ((61+19) AND 1fh)+b7     ; 3: konec horizont ln¡ho zatemnØn¡
         db        65                       ; 4: poŸ tek horiz. synchronizace
         db        ((65+7) AND 1fh)+(4*((61+19) AND 20h)) ; 5: konec hor.synchr.
         db        (312-2) AND 0ffh         ; 6: poŸet vertik. linek celkem - 2
         db        b0+b4                    ; 7: doplåuj¡c¡ bity registr…
         db        1+b6                     ; 9: poŸet linek na znak - 1
         db        1                        ; 0Ah: poŸ teŸn¡ linka kurzoru
         db        0                        ; 0Bh: koncov  linka kurzoru
         db        252                      ; 10h: zaŸ tek vertik. synchronizace
         db        (252+4) AND 0fh + b7     ; 11h: d‚lka vertik. synchronizace
         db        199                      ; 12h: posledn¡ zobrazen  linka
         db        20                       ; 13h: pý¡rustek adresy v pamØti/2
         db        0                        ; 14h: podtr§en¡ MDA
         db        244                      ; 15h: zaŸ tek vertik l. zatemnØn¡
         db        (244+25) AND 0ffh        ; 16h: konec vertik ln¡ho zatemnØn¡
         db        b7+b5+b1                 ; 17h: ý¡dic¡ registr m¢du pamØti

; ------ 3: 6 (graf 640x200/2) standard, TRIDENT 8800

         db        0                        ; 3C0h/13h: posun bod… PANNING
         db        b3+b0                    ; 3C4h/01h: m¢t taktov n¡
         db        1*b2                     ; 3C2h: frekvence hodin
         db        107                      ; 0: poŸet horiz. pozic celkem - 5
         db        79                       ; 1: poŸet zobrazenìch znak… - 1
         db        85                       ; 2: poŸ tek horiz. zatemnØn¡
         db        ((85+21) AND 1fh)+b7     ; 3: ç¡ýka horiz. zatemnØn¡
         db        90                       ; 4: poŸ tek horiz. synchronizace
         db        ((90+8) AND 1fh)+(4*((85+21) AND 20h)) ; 5: ç¡ýka hor.synchr.
         db        (312-2) AND 0ffh         ; 6: poŸet vertik. linek celkem - 2
         db        b0+b4                    ; 7: doplåuj¡c¡ bity registr…
         db        1+b6                     ; 9: poŸet linek na znak - 1
         db        1                        ; 0Ah: poŸ teŸn¡ linka kurzoru
         db        0                        ; 0Bh: koncov  linka kurzoru
         db        252                      ; 10h: zaŸ tek vertik. synchronizace
         db        (252+4) AND 0fh + b7     ; 11h: d‚lka vertik. synchronizace
         db        199                      ; 12h: posledn¡ zobrazen  linka
         db        40                       ; 13h: pý¡rustek adresy v pamØti/2
         db        0                        ; 14h: podtr§en¡ MDA
         db        244                      ; 15h: zaŸ tek vertik l. zatemnØn¡
         db        (244+25) AND 0ffh        ; 16h: konec vertik ln¡ho zatemnØn¡
         db        b7+b6+b1                 ; 17h: ý¡dic¡ registr m¢du pamØti

; ------ 4: 7 (text 80x25/mono) standard, TRIDENT 8800

         db        0                        ; 3C0h/13h: posun bod… PANNING
         db        b3+b0                    ; 3C4h/01h: m¢t taktov n¡
         db        1*b2                     ; 3C2h: frekvence hodin
         db        107                      ; 0: poŸet horiz. pozic celkem - 5
         db        79                       ; 1: poŸet zobrazenìch znak… - 1
         db        85                       ; 2: poŸ tek horiz. zatemnØn¡
         db        ((85+21) AND 1fh)+b7     ; 3: ç¡ýka horiz. zatemnØn¡
         db        90                       ; 4: poŸ tek horiz. synchronizace
         db        ((90+8) AND 1fh)+(4*((85+21) AND 20h)) ; 5: ç¡ýka hor.synchr.
         db        (312-2) AND 0ffh         ; 6: poŸet vertik. linek celkem - 2
         db        b0+b4                    ; 7: doplåuj¡c¡ bity registr…
         db        7+b6                     ; 9: poŸet linek na znak - 1
         db        7                        ; 0Ah: poŸ teŸn¡ linka kurzoru
         db        7                        ; 0Bh: koncov  linka kurzoru
         db        252                      ; 10h: zaŸ tek vertik. synchronizace
         db        (252+4) AND 0fh + b7     ; 11h: d‚lka vertik. synchronizace
         db        199                      ; 12h: posledn¡ zobrazen  linka
         db        40                       ; 13h: pý¡rustek adresy v pamØti/2
         db        7                        ; 14h: podtr§en¡ MDA
         db        244                      ; 15h: zaŸ tek vertik l. zatemnØn¡
         db        (244+25) AND 0ffh        ; 16h: konec vertik ln¡ho zatemnØn¡
         db        b7+b5+b1+b0              ; 17h: ý¡dic¡ registr m¢du pamØti

; ------ 5: 0dh (graf 320x200/16) standard,TRIDENT 8800

         db        0                        ; 3C0h/13h: posun bod… PANNING
         db        b3+b0                    ; 3C4h/01h: m¢t taktov n¡
         db        0*b2                     ; 3C2h: frekvence hodin
         db        95                       ; 0: poŸet horiz. pozic celkem - 5
         db        39                       ; 1: poŸet zobrazenìch znak… - 1
         db        61                       ; 2: poŸ tek horizont l. zatemnØn¡
         db        ((61+19) AND 1fh)+b7     ; 3: konec horizont ln¡ho zatemnØn¡
         db        65                       ; 4: poŸ tek horiz. synchronizace
         db        ((65+7) AND 1fh)+(4*((61+19) AND 20h)) ; 5: konec hor.synchr.
         db        (312-2) AND 0ffh         ; 6: poŸet vertik. linek celkem - 2
         db        b0+b4                    ; 7: doplåuj¡c¡ bity registr…
         db        0+b6                     ; 9: poŸet linek na znak - 1
         db        1                        ; 0Ah: poŸ teŸn¡ linka kurzoru
         db        0                        ; 0Bh: koncov  linka kurzoru
         db        252                      ; 10h: zaŸ tek vertik. synchronizace
         db        (252+4) AND 0fh + b7     ; 11h: d‚lka vertik. synchronizace
         db        199                      ; 12h: posledn¡ zobrazen  linka
         db        20                       ; 13h: pý¡rustek adresy v pamØti/2
         db        0                        ; 14h: podtr§en¡ MDA
         db        244                      ; 15h: zaŸ tek vertik l. zatemnØn¡
         db        (244+25) AND 0ffh        ; 16h: konec vertik ln¡ho zatemnØn¡
         db        b7+b6+b5+b1+b0           ; 17h: ý¡dic¡ registr m¢du pamØti

; ------ 6: 0eh (graf 640x200/16) standard,TRIDENT 8800

         db        0                        ; 3C0h/13h: posun bod… PANNING
         db        b3+b0                    ; 3C4h/01h: m¢t taktov n¡
         db        1*b2                     ; 3C2h: frekvence hodin
         db        107                      ; 0: poŸet horiz. pozic celkem - 5
         db        79                       ; 1: poŸet zobrazenìch znak… - 1
         db        85                       ; 2: poŸ tek horiz. zatemnØn¡
         db        ((85+21) AND 1fh)+b7     ; 3: ç¡ýka horiz. zatemnØn¡
         db        90                       ; 4: poŸ tek horiz. synchronizace
         db        ((90+8) AND 1fh)+(4*((85+21) AND 20h)) ; 5: ç¡ýka hor.synchr.
         db        (312-2) AND 0ffh         ; 6: poŸet vertik. linek celkem - 2
         db        b0+b4                    ; 7: doplåuj¡c¡ bity registr…
         db        0+b6                     ; 9: poŸet linek na znak - 1
         db        1                        ; 0Ah: poŸ teŸn¡ linka kurzoru
         db        0                        ; 0Bh: koncov  linka kurzoru
         db        252                      ; 10h: zaŸ tek vertik. synchronizace
         db        (252+4) AND 0fh + b7     ; 11h: d‚lka vertik. synchronizace
         db        199                      ; 12h: posledn¡ zobrazen  linka
         db        40                       ; 13h: pý¡rustek adresy v pamØti/2
         db        0                        ; 14h: podtr§en¡ MDA
         db        244                      ; 15h: zaŸ tek vertik l. zatemnØn¡
         db        (244+25) AND 0ffh        ; 16h: konec vertik ln¡ho zatemnØn¡
         db        b7+b5+b6+b1+b0           ; 17h: ý¡dic¡ registr m¢du pamØti

; ------ 7: 0fh,10h (graf 640x350/mono a 16) standard,TRIDENT 8800

         db        0                        ; 3C0h/13h: posun bod… PANNING
         db        b3+b0                    ; 3C4h/01h: m¢t taktov n¡
         db        1*b2                     ; 3C2h: frekvence hodin
         db        107                      ; 0: poŸet horiz. pozic celkem - 5
         db        79                       ; 1: poŸet zobrazenìch znak… - 1
         db        85                       ; 2: poŸ tek horiz. zatemnØn¡
         db        ((85+21) AND 1fh)+b7     ; 3: ç¡ýka horiz. zatemnØn¡
         db        90                       ; 4: poŸ tek horiz. synchronizace
         db        ((90+8) AND 1fh)+(4*((85+21) AND 20h)) ; 5: ç¡ýka hor.synchr.
         db        (312-2) AND 0ffh         ; 6: poŸet vertik. linek celkem - 2
         db        b0+b4                    ; 7: doplåuj¡c¡ bity registr…
         db        0+b6                     ; 9: poŸet linek na znak - 1
         db        1                        ; 0Ah: poŸ teŸn¡ linka kurzoru
         db        0                        ; 0Bh: koncov  linka kurzoru
         db        242                      ; 10h: zaŸ tek vertik. synchronizace
         db        (242+4) AND 0fh + b7     ; 11h: d‚lka vertik. synchronizace
         db        174                      ; 12h: posledn¡ zobrazen  linka
         db        80                       ; 13h: pý¡rustek adresy v pamØti/2
         db        0                        ; 14h: podtr§en¡ MDA
         db        244                      ; 15h: zaŸ tek vertik l. zatemnØn¡
         db        (244+25) AND 0ffh        ; 16h: konec vertik ln¡ho zatemnØn¡
         db        b7+b5+b6+b1+b0           ; 17h: ý¡dic¡ registr m¢du pamØti

; ------ 8: 11h, 12h (graf 640x480/mono a 16) standard,TRIDENT 8800

         db        0                        ; 3C0h/13h: posun bod… PANNING
         db        b3+b0                    ; 3C4h/01h: m¢t taktov n¡
         db        1*b2                     ; 3C2h: frekvence hodin
         db        107                      ; 0: poŸet horiz. pozic celkem - 5
         db        79                       ; 1: poŸet zobrazenìch znak… - 1
         db        85                       ; 2: poŸ tek horiz. zatemnØn¡
         db        ((85+21) AND 1fh)+b7     ; 3: ç¡ýka horiz. zatemnØn¡
         db        90                       ; 4: poŸ tek horiz. synchronizace
         db        ((90+8) AND 1fh)+(4*((85+21) AND 20h)) ; 5: ç¡ýka hor.synchr.
         db        (312-2) AND 0ffh         ; 6: poŸet vertik. linek celkem - 2
         db        b0+b2+b4                 ; 7: doplåuj¡c¡ bity registr…
         db        0+b6                     ; 9: poŸet linek na znak - 1
         db        1                        ; 0Ah: poŸ teŸn¡ linka kurzoru
         db        0                        ; 0Bh: koncov  linka kurzoru
         db        268 AND 0ffh             ; 10h: zaŸ tek vertik. synchronizace
         db        (268+4) AND 0fh + b7     ; 11h: d‚lka vertik. synchronizace
         db        239                      ; 12h: posledn¡ zobrazen  linka
         db        80                       ; 13h: pý¡rustek adresy v pamØti/2
         db        0                        ; 14h: podtr§en¡ MDA
         db        244                      ; 15h: zaŸ tek vertik l. zatemnØn¡
         db        (244+25) AND 0ffh        ; 16h: konec vertik ln¡ho zatemnØn¡
         db        b7+b5+b6+b1+b0           ; 17h: ý¡dic¡ registr m¢du pamØti

; ------ 9: 13h (graf 320x200/256) standard,TRIDENT 8800

         db        0                        ; 3C0h/13h: posun bod… PANNING
         db        b3+b0                    ; 3C4h/01h: m¢t taktov n¡
         db        1*b2                     ; 3C2h: frekvence hodin
         db        107                      ; 0: poŸet horiz. pozic celkem - 5
         db        79                       ; 1: poŸet zobrazenìch znak… - 1
         db        85                       ; 2: poŸ tek horiz. zatemnØn¡
         db        ((85+21) AND 1fh)+b7     ; 3: ç¡ýka horiz. zatemnØn¡
         db        90                       ; 4: poŸ tek horiz. synchronizace
         db        ((90+8) AND 1fh)+(4*((85+21) AND 20h)) ; 5: ç¡ýka hor.synchr.
         db        (312-2) AND 0ffh         ; 6: poŸet vertik. linek celkem - 2
         db        b0+b4                    ; 7: doplåuj¡c¡ bity registr…
         db        0+b6                     ; 9: poŸet linek na znak - 1
         db        1                        ; 0Ah: poŸ teŸn¡ linka kurzoru
         db        0                        ; 0Bh: koncov  linka kurzoru
         db        252                      ; 10h: zaŸ tek vertik. synchronizace
         db        (252+4) AND 0fh + b7     ; 11h: d‚lka vertik. synchronizace
         db        199                      ; 12h: posledn¡ zobrazen  linka
         db        40                       ; 13h: pý¡rustek adresy v pamØti/2
         db        b6                       ; 14h: podtr§en¡ MDA
         db        244                      ; 15h: zaŸ tek vertik l. zatemnØn¡
         db        (244+25) AND 0ffh        ; 16h: konec vertik ln¡ho zatemnØn¡
         db        b7+b5+b1+b0              ; 17h: ý¡dic¡ registr m¢du pamØti

RezidEnd label     byte                     ; konec rezidentn¡ho programu

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                            Instalace programu
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;þ

; ------ £schova pý¡kazov‚ho ý dku

Instal:  mov       si,81h                   ; zaŸ tek pý¡kazov‚ho ý dku
         mov       di,offset Command        ; buffer pý¡kazov‚ho ý dku
         mov       cl,ds:[si-1]             ; d‚lka pý¡kazov‚ho ý dku
         mov       ch,0
         cld
         rep       movsb                    ; pýenos textu do bufferu
         mov       ds:[di],ch               ; oznaŸen¡ konce pý¡kazov‚ho ý dku

; ------ posun rezidentn¡ho programu dol…

         mov       si,offset RezidBeg       ; zaŸ tek rezidentn¡ho programu
         mov       di,offset RezidBeg+KORIG ; nov  adresa
         mov       cx,offset(RezidEnd-RezidBeg+1)/2 ; d‚lka programu (slov)
         rep       movsw                    ; posun programu dol…

; ------ pý¡prava konfiguraŸn¡ tabulky posunu

         mov       ds:[RezSegm],ds
         call      StorReg                  ; ulo§en¡ registr…
         push      ds
         pop       es

; ------ test, zda je program ji§ nainstalov n

         mov       ax,KLIC1
         mov       bx,KLIC2
         mov       cx,KLIC3
         mov       dx,KLIC4
         int       10h                      ; test instalace programu
         cmp       bx,KLIC5                 ; je program nainstalov n ?
         je        Instal1                  ; je nainstalov n
         push      cs
         pop       es                       ; ES <- CS
         or        byte ptr ds:[ParamI],b0  ; pý¡znak prvn¡ instalace programu
Instal1: mov       ds:[RezSegm],es          ; rezidentn¡ segment

; ------ rozbor zad n¡ parametr…

         call      Rozbor                   ; rozbor zad n¡ parametr…
         jnc       Instal2                  ; zad n¡ parametr… OK

; ------ chyba

         mov       dx,offset HelpTxt        ; text n povØdy
Chyba:   push      dx
         mov       dx,offset UvTxt          ; £vodn¡ text
         mov       ah,9
         int       21h                      ; zobrazen¡ £vodn¡ho textu
         pop       dx
         mov       ah,9
         int       21h                      ; zobrazen¡ textu chyby
         int       20h

; ------ automatick  detekce videokarty

Instal2: call      DetVGA                   ; detekce videokarty VGA

; ------ inicializace konfiguraŸn¡ho souboru

         mov       al,ds:[Param+KORIG]
         and       al,b0
         push      ax
         call      InitCnf                  ; inicializace konfigurace
         pop       ax
         and       byte ptr ds:[Param+KORIG],not b0
         or        ds:[Param+KORIG],al

         call      StorReg

; ------ nastaven¡ konfigurace programu

         test      byte ptr ds:[ParamI],b2  ; nastaven¡ konfigurace ?
         jz        Instal3                  ; nen¡ nastaven¡ konfigurace
         call      Konfig                   ; nastaven¡ konfigurace programu


Instal3: test      byte ptr ds:[ParamI],b3
         jz        Instal30
         mov       ax,1202h
         mov       bl,30h
         int       10h                      ; nastaven¡ m¢du 480 linek
         mov       ah,0fh
         int       10h
         mov       ah,0
         int       10h

; ------ test, zda m  bìt program odinstalov n

Instal30:test      byte ptr ds:[ParamI],b1  ; po§adov no odinstalov n¡ ?
         jz        Instal4                  ; nen¡ po§adov no odinstalov n¡

; ------ test, zda je program nainstalov n

         mov       dx,offset NicTxt
         test      byte ptr ds:[ParamI],b2  ; je konfigurace ?
         jnz       Instal31
         mov       dx,offset NebylTxt       ; text - nebyl nainstalovan
Instal31:test      byte ptr ds:[ParamI],b0  ; je to prvn¡ instalace ?
         jnz       Chyba                    ; je prvn¡ instalace - konec

; ------ test, zda lze program odinstalovat

         mov       es,ds:[RezSegm]
         call      TestDIns                 ; test odinstalov n¡ programu
         mov       dx,offset NelzeTxt
         jc        Chyba                    ; chyba - nelze odinstalovat

; ------ odinstalov n¡ programu

         call      OdInst                   ; odinstalov n¡
         mov       dx,offset OdInsTxt
Instal39:jmp       short Chyba

; ------ test, zda m  bìt program nainstalov n

Instal4: test      byte ptr ds:[ParamI],b0  ; je to prvn¡ instalace ?
         mov       dx,offset NicTxt
         jz        Instal39                 ; nen¡ to prvn¡ instalace

; ------ instalace INT 10h

         mov       ax,3510h
         int       21h                      ; poskytnut¡ adresy INT 10h
         mov       word ptr ds:[Old10+KORIG],bx
         mov       word ptr ds:[Old10+KORIG+2],es
         mov       dx,offset Int10 + KORIG  ; obsluha INT 10h
         mov       ax,2510h
         int       21h                      ; instalace obsluhy INT 10h

; ------ uvolnØn¡ segmentu prostýed¡

         mov       es,ds:[2ch]              ; segment prostýed¡
         mov       ah,49h
         int       21h                      ; uvolnØn¡ segmentu prostýed¡

; ------ inicializace videom¢du

         call      InitVMod                 ; inicializace videom¢du

; ------ instalace programu do pamØti

         mov       dx,offset Instal + KORIG
         int       27h                      ; instalace programu do pamØti

; -----------------------------------------------------------------------------
;        odinstalov n¡ programu ES
; -----------------------------------------------------------------------------

OdInst   PROC      NEAR

         push      ds
         lds       dx,es:[Old10+KORIG]      ; p…vodn¡ adresa INT 10h
         mov       ax,2510h
         int       21h                      ; n vrat adresy INT 10h
         pop       ds

         test      byte ptr es:[Param+KORIG],b0; je TV m¢d ?
         jz        OdInst2                  ; nen¡ TV m¢d

         push      es
         mov       ax,1202h
         mov       bl,30h
         int       10h                      ; nastaven¡ m¢du 480 linek
         mov       ah,0fh
         int       10h
         mov       ah,0
         int       10h                      ; inicializace videom¢du
         pop       es

OdInst2: mov       ah,49h
         int       21h                      ; uvolnØn¡ bloku pamØti programu

         ret

OdInst   ENDP

; -----------------------------------------------------------------------------
;        test, zda lze program odinstalovat
; -----------------------------------------------------------------------------

TestDIns PROC      NEAR

; ------ test, zda program lze odinstalovat

         push      es
         mov       cx,es
         mov       ax,3510h
         int       21h                      ; poskytnut¡ adresy INT 10h
         mov       ax,es                    ; segment adresy INT 10h
         cmp       ax,cx                    ; je to rezidentn¡ program ?
         pop       es
         je        TestDIn2
         stc
TestDIn2:ret

TestDIns ENDP

; *****************************************************************************
;
;                            Konfigurace programu
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        inicializace konfiguraŸn¡ho souboru
; -----------------------------------------------------------------------------

InitCnf  PROC      NEAR

; ------ test, zda je verze syst‚mu alespoå 3.00

         push      ds
         pop       es
         mov       ah,30h
         int       21h                      ; poskytnut¡ verze syst‚mu
         cmp       al,3
         jb        InitCnf5                 ; je n¡zk  verze syst‚mu

; ------ test platnosti segmentu prostýed¡

         mov       cx,ds:[2ch]              ; segment prostýed¡
         jcxz      InitCnf5                 ; neplatnì segment

; ------ nalezen¡ cesty v prostýed¡

         push      ds
         mov       ds,cx
         xor       ax,ax
         mov       cx,8000h
         xor       si,si
InitCnf2:inc       si
         cmp       ds:[si-1],ax
         loopne    InitCnf2                 ; nalezen¡ konce prostýed¡
         add       si,3                     ; zaŸ tek textu cesty

; ------ pýenesen¡ cesty do bufferu

         mov       cx,88                    ; maxim ln¡ d‚lka textu cesty
         mov       di,offset SoubCnf        ; buffer k ulo§en¡ jm‚na
         cld
InitCnf3:lodsb
         stosb
         cmp       al,0
         loopne    InitCnf3
         dec       di                       ; n vrat na koncovou 0
         pop       ds

; ------ inicializace pý¡pony souboru

         cmp       byte ptr ds:[di-4],"."
         jne       InitCnf4
         sub       di,4
InitCnf4:mov       ax,"C."
         stosw
         mov       ax,"FN"
         stosw
         mov       al,0
         stosb

; ------ pokus o otevýen¡ souboru

InitCnf5:mov       dx,offset SoubCnf
         mov       ax,3d00h
         int       21h                      ; pokus o otevýen¡ souboru
         jc        InitCnf9                 ; chyba
         mov       bx,ax                    ; identifik tor souboru

; ------ naŸten¡ souboru do pamØti

         mov       dx,offset BegCnf+KORIG
         mov       ah,3fh
         mov       cx,offset(EndCnf-BegCnf) ; d‚lka
         int       21h                      ; naŸten¡ souboru do pamØti

; ------ naŸten¡ tabulky posunu

         mov       dx,offset ShiftCnf
         mov       cx,MAXNTAB * 5
         mov       ah,3fh
         int       21h                      ; naŸten¡ tabulky posunu

; ------ korekce tabulek registr…

         mov       si,offset ShiftCnf
         mov       di,offset TabReg
         mov       cx,MAXNTAB
         cld
InitCnf6:lodsb
         mov       ds:[di+ShftRg1-TabReg],al

         lodsb
         and       al,1fh
         and       byte ptr ds:[di+ShftRg2-TabReg],not 1fh
         or        ds:[di+ShftRg2-TabReg],al

         lodsb
         mov       ds:[di+ShftRg3-TabReg],al

         lodsb
         and       al,0fh
         and       byte ptr ds:[di+ShftRg4-TabReg],not 0fh
         or        ds:[di+ShftRg4-TabReg],al

         lodsb
         and       al,b2+b7
         and       byte ptr ds:[di+ShftRg5-TabReg],not b2+b7
         or        ds:[di+ShftRg5-TabReg],al

         add       di,DELKTAB
         loop      InitCnf6

; ------ uzavýen¡ souboru

         mov       ah,3eh
         int       21h
InitCnf9:ret

InitCnf  ENDP

; -----------------------------------------------------------------------------
;        ulo§en¡ definice karty
; -----------------------------------------------------------------------------

StorReg  PROC      NEAR

; ------ sestaven¡ tabulky posunu

         push      ds
         pop       es
         mov       di,offset ShiftCnf
         mov       si,offset TabReg
         mov       cx,MAXNTAB
         cld
StorReg1:mov       al,ds:[si+ShftRg1-TabReg]
         stosb
         mov       al,ds:[si+ShftRg2-TabReg]
         stosb
         mov       al,ds:[si+ShftRg3-TabReg]
         stosb
         mov       al,ds:[si+ShftRg4-TabReg]
         stosb
         mov       al,ds:[si+ShftRg5-TabReg]
         stosb
         add       si,DELKTAB
         loop      StorReg1

; ------ pýenes dat do rezidentn¡ho modulu

         cli
         mov       es,ds:[RezSegm]
         mov       ax,offset(TabStd0-TabStd) ; poŸet videom¢d…
         mul       word ptr es:[Card+KORIG] ; offset definice Ÿ¡sel tabulek
         add       ax,offset TabStd         ; adresa definice Ÿ¡sel tabulek
         xchg      ax,bx                    ; BX <- ukazatel Ÿ¡sel tabulek
         mov       di,offset InitTRT+KORIG
         mov       dx,offset(TabStd0-TabStd) ; poŸet videom¢d…
         cld
StorReg2:mov       al,DELKTAB               ; d‚lka jedn‚ tabulky
         mul       byte ptr ds:[bx]         ; offset tabulky
         inc       bx                       ; adresa dalç¡ tabulky
         add       ax,offset TabReg
         xchg      ax,si                    ; adresa tabulky
         mov       cx,DELKTAB
         rep       movsb                    ; pýenos jedn‚ tabulky
         dec       dx
         jnz       StorReg2                 ; dalç¡ tabulka registr…
         sti
         ret

StorReg  ENDP

; -----------------------------------------------------------------------------
;        ulo§en¡ konfigurace
; -----------------------------------------------------------------------------

StorCnf  PROC      NEAR

         call      StorReg

; ------ vytvoýen¡ souboru

         mov       dx,offset SoubCnf
         mov       ah,3ch
         xor       cx,cx
         int       21h                      ; vytvoýen¡ souboru
         jc        StorCnf8
         xchg      ax,bx                    ; identifik tor soubory

; ------ z pis souboru

         push      ds
         mov       ds,ds:[RezSegm]
         mov       dx,offset BegCnf+KORIG
         mov       cx,offset(EndCnf-BegCnf)
         mov       ah,40h
         int       21h                      ; z pis
         pop       ds

; ------ z pis tabulky posun…

         mov       dx,offset ShiftCnf
         mov       cx,MAXNTAB*5
         mov       ah,40h
         int       21h

; ------ uzavýen¡ souboru

         mov       ah,3eh
         int       21h

StorCnf8:ret

StorCnf  ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ konfigurace programu
; -----------------------------------------------------------------------------

Konfig   PROC      NEAR

         call      InitRnd

; ------ instalace obsluhy INT 10h

         test      byte ptr ds:[ParamI],b0  ; je to prvn¡ instalace ?
         jz        Konfig1                  ; nen¡ to prvn¡ instalace
         mov       ax,3510h
         int       21h                      ; poskytnut¡ adresy INT 10h
         mov       word ptr ds:[Old10+KORIG],bx
         mov       word ptr ds:[Old10+2+KORIG],es
         mov       dx,offset INT10+KORIG
         mov       ax,2510h
         int       21h                      ; instalace obsluhy INT 10h

; ------ nastaven¡ bØ§n‚ho textov‚ho m¢du

Konfig1:
         mov       ax,1202h
         mov       bl,30h
         int       10h                      ; nastaven¡ m¢du 480 linek
         mov       ax,3
         int       10h                      ; nastaven¡ textov‚ho m¢du

; ------ zobrazen¡ horn¡ linky r mu

         mov       ax,0b800h
         mov       es,ax
         xor       di,di
         mov       ah,0fh
         mov       al,"É"
         stosw
         mov       al,"Í"
         mov       cx,78
         rep       stosw
         mov       al,"»"
         stosw

; ------ zobrazen¡ stýedn¡ch linek r mu

         mov       al,"º"
         mov       cx,23                    ; poŸet ý dk…
Konfig12:stosw
         add       di,160-2*2
         stosw
         loop      Konfig12

; ------ zobrazen¡ spodn¡ linky r mu

         mov       al,"È"
         stosw
         mov       cl,78
         mov       al,"Í"
         rep       stosw
         mov       al,"¼"
         stosw

; ------ zobrazen¡ nadpisu

         mov       si,offset VolNadp
         mov       di,(80-offset(VolNadp0-VolNadp)) AND 0fffeh - 2
         mov       cx,offset(VolNadp0-VolNadp)
         mov       ah,70h
         push      cx
Konfig15:lodsb
         stosw
         loop      Konfig15
         pop       cx

; ------ nastaven¡ typu videokarty do voleb

Konfig2: mov       es,ds:[RezSegm]
         mov       cx,offset(VolCard0-VolCard)
         mov       al,byte ptr es:[Card+KORIG] ; karta
         mul       cl
         add       ax,offset VolCard
         xchg      ax,si                    ; adresa textu
         mov       di,offset VolCardT
         cld
         push      ds
         pop       es
         rep       movsb

; ------ nastaven¡ polarity pýep¡naŸ… do voleb

         mov       es,ds:[RezSegm]
         mov       si,offset HorSTxt
         test      byte ptr es:[Param+KORIG],b6
         call      PrepSyn
         mov       si,offset VerSTxt
         test      byte ptr es:[Param+KORIG],b7
         call      PrepSyn


; ------ pý¡prava k zobrazen¡ voleb

         mov       ax,0b800h
         mov       es,ax
         mov       di,3*160+80-(DELKURZ AND 0feh)
         mov       si,offset Volby
         mov       bl,ds:[VolAkt]           ; aktivn¡ polo§ka
         mov       bh,VOLNUM+1              ; poŸet polo§ek
         cld

; ------ zobrazen¡ voleb

         xor       cx,cx
Konfig22:lodsb                              ; d‚lka polo§ky
         mov       cl,al
         jcxz      Konfig26                 ; je pr zdnì ý dek
         mov       dl,DELKURZ-1
         sub       dl,cl

         push      di
         mov       ah,0fh
         dec       bl
         jnz       Konfig23
         mov       ah,70h
         mov       dh,ds:[si]               ; £schova prvn¡ho znaku kurzoru
Konfig23:mov       al," "
         stosw
Konfig24:lodsb
         cmp       al,0
         jne       Konfig25
         test      ah,0f0h
         jnz       Konfig24
         xor       ah,7 XOR 0fh
         jmp       short Konfig24
Konfig25:stosw
         loop      Konfig24
         mov       al," "
         mov       cl,dl
         rep       stosw
         pop       di

Konfig26:add       di,160
         dec       bh
         jnz       Konfig22

; ------ zobrazen¡ detekovan‚ videokarty

         mov       cx,ds:[CardDet]          ; detekovan  videokarta
         mov       si,offset CardTxt        ; tabulka n zv… videokaret
         mov       ah,0
         jcxz      Konfig29
Konfig28:lodsb
         add       si,ax
         loop      Konfig28                 ; nalezen¡ textu karty
Konfig29:mov       di,22*160+80
         mov       al,ds:[si]               ; d‚lka textu karty
         push      si
         mov       si,offset DetCTxt
         mov       cl,ds:[si]
         inc       si
         add       al,cl
         and       al,not 1
         sub       di,ax
         mov       ah,7
Konfig2a:lodsb
         stosw
         loop      Konfig2a
         pop       si
         mov       cl,ds:[si]
         inc       si
         mov       ah,0fh
Konfig2b:lodsb
         stosw
         loop      Konfig2b

; ------ Ÿek n¡ na zad n¡ znaku volby

Konfig3: push      dx
         mov       dx,25*256
         mov       ah,2
         int       10h                      ; vypnut¡ kurzoru
         pop       dx
         mov       ah,0
         int       16h                      ; vstup znaku z kl vesnice
         mov       es,ds:[RezSegm]

; ------ ENTER - plat¡ znak pod kurzorem

         cmp       al,13
         jne       Konfig31
         mov       al,dh

; ------ pýevod znaku na velk‚ p¡smeno

Konfig31:cmp       al,"a"
         jb        Konfig32
         cmp       al,"z"
         ja        Konfig32
         sub       al,32                    ; konverze na velk‚ p¡smeno

; ------ konec programu

Konfig32:or        ax,ax
         jz        Konfig34                 ; Ctrl-Break
         cmp       al,27
         je        Konfig34                 ; Esc
         cmp       al,"Q"
         jne       Konfig4

; ------ n vrat obsluhy INT 10h

Konfig34:test      byte ptr ds:[ParamI],b0  ; je prvn¡ instalace ?
         jz        Konfig36                 ; nen¡ prvn¡ instalace
         push      ds
         lds       dx,ds:[Old10+KORIG]
         mov       ax,2510h
         int       21h                      ; n vrat adresy INT 10h
         pop       ds
Konfig36:mov       ax,3
         int       10h
         ret

; ------ zmØna typu videokarty "V" (nebo kurzory vlevo/vpravo)

Konfig4: cmp       ax,4d00h
         je        Konfig42                 ; vpravo
         cmp       ax,4b00h
         jne       Konfig41                 ; vlevo

Konfig40:mov       ax,es:[Card+KORIG]
         dec       ax
         jns       Konfig43
         mov       ax,NUMCARD-1
         jmp       short Konfig43

Konfig41:cmp       al,"V"
         jne       Konfig5
Konfig42:mov       ax,es:[Card+KORIG]
         inc       ax
         cmp       al,NUMCARD
         jb        Konfig43
         xor       ax,ax
Konfig43:mov       es:[Card+KORIG],ax
Konfig44:call      StorCnf                  ; ulo§en¡ konfigurace
Konfig46:jmp       Konfig2

; ------ zmØna vertik ln¡ synchronizace

Konfig5: cmp       al,"Y"
         jne       Konfig6
         xor       byte ptr es:[Param+KORIG],b7
         jmp       short Konfig44

; ------ zmØna horizont ln¡ synchronizace

Konfig6: cmp       al,"X"
         jne       Konfig7
         xor       byte ptr es:[Param+KORIG],b6
         jmp       short Konfig44

; ------ nastaven¡ videom¢du

Konfig7: cmp       al,"A"
         jb        Konfig8
         cmp       al,"L"
         ja        Konfig8

         sub       al,"A"
         mov       bl,al
         mov       bh,0
         shl       bx,1
         shl       bx,1
         add       bx,offset TabTMod
         mov       ax,ds:[bx]
         mov       word ptr ds:[TestVMod],ax ; testovanì videom¢d a barvy
         mov       ax,ds:[bx+2]
         mov       word ptr ds:[TestVPoz],ax ; pozic a ý dk…

         call      TestMod                  ; test videom¢du
         jmp       Konfig1


; ------ prvn¡ polo§ka a posun kurzoru dol…

Konfig8: cmp       ax,4900h                 ; Page Up
         je        Konfig80
         cmp       ax,4700h                 ; Home
         je        Konfig80
         cmp       ax,5000h                 ; dol…
         jne       Konfig82
         mov       al,ds:[VolAkt]
         inc       al
         cmp       al,VOLNUM
         jbe       Konfig81
Konfig80:mov       al,1
Konfig81:mov       ds:[VolAkt],al
         jmp       short Konfig46

; ------ posledn¡ polo§ka a posun kurzoru nahoru

Konfig82:cmp       ax,5100h                 ; Page Down
         je        Konfig83
         cmp       ax,4f00h                 ; End
         je        Konfig83
         cmp       ax,4800h
         jne       Konfig85
         mov       al,ds:[VolAkt]
         dec       al
         jnz       Konfig81
Konfig83:mov       al,VOLNUM
         jmp       short Konfig81


Konfig85:

         jmp       Konfig3                  ; jinak dalç¡ kl vesa

Konfig   ENDP

; -----------------------------------------------------------------------------
;        pý¡prava textu polarity
; -----------------------------------------------------------------------------

PrepSyn  PROC      NEAR

         mov       ax,"OP"
         mov       bl,"Z"
         jz        PrepSyn2
         mov       ax,"EN"
         mov       bl,"G"
PrepSyn2:mov       ds:[si],ax
         mov       ds:[si+2],bl
         ret

PrepSyn  ENDP

; -----------------------------------------------------------------------------
;        test videom¢du
; -----------------------------------------------------------------------------

TestMod  PROC      NEAR

; ------ £schova pý¡znaku parametr…

         and       byte ptr ds:[ParamI],not b4 ; pý¡znak posunu obrazu
         mov       es,ds:[RezSegm]          ; rezidentn¡ segment
         mov       al,es:[Param+KORIG]      ; parametry
         mov       ds:[OldParam],al         ; £schova pý¡znak…
         or        byte ptr es:[Param+KORIG],b0 ; pý¡znak TV m¢du

         call      StorReg                  ; ulo§en¡ definice registr…

; ------ nastaven¡ videom¢du

         mov       al,ds:[TestVMod]         ; testovanì videom¢d
         mov       ah,0
         int       10h                      ; inicializace videom¢du

; ------ £schova registr… pro posun obrazu

         call      TGetReg                  ; Ÿten¡ registr…
;         call      CRTCON                   ; zapnut¡ videosign lu

; ------ zobrazen¡ r mu

TestMod1:xor       dx,dx
         mov       ah,0fh
;         mov       al,"É"
         mov       al,"²"
         call      Disp1Chr
         mov       cl,ds:[TestVPoz]
         dec       cx
         dec       cx
         mov       al,"Í"
         call      DispChr
;         mov       al,"»"
         mov       al,"²"
         call      Disp1Chr

         mov       ch,ds:[TestVRad]
         sub       ch,2
         mov       dx,100h
         mov       al,"º"
TestMod2:push      dx
         call      Disp1Chr
         add       dl,cl
         call      Disp1Chr
         pop       dx
         inc       dh
         dec       ch
         jnz       TestMod2

;         mov       al,"È"
         mov       al,"²"
         call      Disp1Chr
         mov       al,"Í"
         call      DispChr
;         mov       al,"¼"
         mov       al,"²"
         call      Disp1Chr

; ------ vymaz n¡ vnitýku r mu

         mov       dx,101h
         mov       bh,ds:[TestVCol]
         mov       ch,2
         mov       cl,2
         mov       bl,38
         cmp       byte ptr ds:[TestVPoz],60
         jae       TestMod3
         dec       cx
TestMod3:call      DispBox

         mov       dh,3
         mov       ch,ds:[TestVRad]
         sub       ch,6
         mov       bl,2
         call      DispBox

         mov       dl,40-3
         call      DispBox

         mov       ch,2
         mov       bl,38
         mov       dh,ds:[TestVRad]
         sub       dh,3
         mov       dl,1
         call      DispBox

; ------ zobrazen¡ ASCII tabulky

         mov       dl,ds:[TestVPoz]
         shr       dl,1
         sub       dl,17
         mov       dh,ds:[TestVRad]
         shr       dh,1
         sub       dh,7
         mov       al,dh
         shr       al,1
         shr       al,1
         shr       al,1
         sub       dh,al

         push      dx
         mov       ah,0fh
         mov       al,"Ú"
         call      Disp1Chr
         mov       al,"Ä"
         mov       cl,32
         call      DispChr
         mov       al,"¿"
         call      Disp1Chr
         pop       dx
         inc       dh

         mov       bl,0
TestMod4:push      dx
         mov       al,"³"
         call      Disp1Chr
         mov       ah,7
TestMod5:mov       al,bl
         call      Disp1Chr
         inc       bx
         test      bl,1fh
         jnz       TestMod5
         mov       ah,0fh
         mov       al,"³"
         call      Disp1Chr
         pop       dx
         inc       dh
         cmp       bl,0
         jne       TestMod4

         push      dx
         mov       al,"À"
         call      Disp1Chr
         mov       al,"Ä"
         mov       cl,32
         call      DispChr
         mov       al,"Ù"
         call      Disp1Chr
         pop       dx

; ------ zobrazen¡ barevn‚ stupnice

         mov       bh,ds:[TestVCol]
         mov       dh,ds:[TestVRad]
         shr       dh,1
         shr       dh,1
         sub       dh,2
         mov       dl,ds:[TestVPoz]
         shr       dl,1
         mov       bl,bh
         cmp       bl,16
         jb        TestMd35
         mov       bl,15
TestMd35:inc       bx
         mov       al,bl
         shr       al,1
         sub       dl,al
         dec       dx
         mov       ah,0
         call      DispCol

         mov       dh,ds:[TestVRad]
         shr       dh,1
         mov       al,dh
         shr       al,1
         shr       al,1
         add       dh,al
         cmp       bh,16
         jb        TestMd36
         mov       ah,10h
TestMd36:call      DispCol

; ------ zobrazen¡ textu n povØdy

         mov       dh,ds:[TestVRad]
         mov       al,dh
         shr       al,1
         shr       al,1
         sub       dh,al
         dec       dh
;         shr       al,1
;         sub       dh,al
         mov       si,offset Cent1Txt
         mov       ah,0fh
         call      DispCent
         mov       si,offset Cent2Txt
         call      DispCent

         call      KurzOff

TestMod6:call      TSetReg
         call      TGetReg
         mov       ah,0
         int       16h

; ------ pýeruçen¡ operace ESC

         or        ax,ax
         jz        TestMod9
         cmp       al,27
         je        TestMod9
;þ
; ------ ukonŸen¡ stavu ENTER

         cmp       al,13
         jne       TestMd61
         test      byte ptr ds:[ParamI],b4
         jz        TestMod9                 ; nebyl posun obrazu
         call      TStoReg
         call      StorCnf                  ; ulo§en¡ konfigurace
         jmp       short TestMod9

; ------ posun vlevo

TestMd61:cmp       ax,4b00h
         jne       TestMd62
         or        byte ptr ds:[ParamI],b4  ; pý¡znak posunu obrazu
         call      ShftLeft                 ; posun vlevo
         jmp       short TestMod6

; ------ posun vpravo

TestMd62:cmp       ax,4d00h
         jne       TestMd63
         or        byte ptr ds:[ParamI],b4  ; pý¡znak posunu obrazu
         call      ShftRght                 ; posun vpravo
         jmp       short TestMod6

; ------ posun nahoru

TestMd63:cmp       ax,4800h
         jne       TestMd64
         or        byte ptr ds:[ParamI],b4  ; pý¡znak posunu obrazu
         call      ShftUp                   ; posun nahoru
         jmp       short TestMod6

; ------ posun dol…

TestMd64:cmp       ax,5000h
         jne       TestMd65
         or        byte ptr ds:[ParamI],b4  ; pý¡znak posunu obrazu
         call      ShftDwn                  ; posun dol…
         jmp       short TestMod6

TestMd65:jmp       short TestMod6

; ------ n vrat pý¡znaku parametr…

TestMod9:mov       es,ds:[RezSegm]          ; rezidentn¡ segment
         mov       al,ds:[OldParam]         ; pý¡znaky
         mov       es:[Param+KORIG],al      ; n vrat parametr…
         ret

TestMod  ENDP

OldParam db        0                        ; £schova parametr… (pý¡znak TV)

TXShft   db        0                        ; posun ve smØru X
TXEnd    db        0                        ; konec ve smØru X
TXTotal  db        0                        ; celkov  ç¡ýka X - 5
TXDisp   db        0                        ; poŸet zobrazenìch pozic

TYShft   dw        0                        ; posun ve smØru Y
TYEnd    db        0                        ; konec ve smØru Y
TYDisp   dw        0                        ; poŸet zobrazenìch linek

; -----------------------------------------------------------------------------
;        ulo§en¡ registr…
; -----------------------------------------------------------------------------

TStoReg  PROC      NEAR

         mov       es,ds:[RezSegm]          ; rezidentn¡ segment
         mov       ax,es:[Card+KORIG]       ; karta
         mov       dx,offset(TabStd0-TabStd) ; d‚lka tabulky Ÿ¡sel registr…
         mul       dx                       ; offset tabulky Ÿ¡sel registr…
         add       ax,offset TabStd         ; tabulka definic registr…
         mov       bl,ds:[TestVMod]         ; testovanì videom¢d
         mov       bh,0
         mov       bl,es:[bx+TabInit+KORIG] ; Ÿ¡slo tabulky registr…
         cmp       bl,-1
         je        TStoReg9
         add       bx,ax                    ; adresa Ÿ¡sla tabulky
         mov       al,ds:[bx]               ; Ÿ¡slo tabulky registr…
         mov       ah,DELKTAB               ; d‚lka tabulky
         mul       ah                       ; offset tabulky
         add       ax,offset TabReg         ; adresa tabulky
         xchg      ax,si                    ; SI <- adresa tabulky

         call      GetCPort

         mov       ah,4
         call      ReadReg
         mov       ds:[si+ShftRg1-TabReg],al

         mov       ah,5
         call      ReadReg
         and       al,1fh
         and       byte ptr ds:[si+ShftRg2-TabReg],not 1fh
         or        ds:[si+ShftRg2-TabReg],al

         mov       ah,10h
         call      ReadReg
         mov       ds:[si+ShftRg3-TabReg],al

         mov       ah,7
         call      ReadReg
         and       al,b2+b7
         and       byte ptr ds:[si+ShftRg5-TabReg],not b2+b7
         or        ds:[si+ShftRg5-TabReg],al

         mov       ah,11h
         call      ReadReg
         and       al,0fh
         and       byte ptr ds:[si+ShftRg4-TabReg],not 0fh
         or        ds:[si+ShftRg4-TabReg],al
TStoReg9:ret

TStoReg  ENDP

; -----------------------------------------------------------------------------
;        poskytnut¡ registr…
; -----------------------------------------------------------------------------

TGetReg  PROC      NEAR

         call      GetCPort

         mov       ah,0
         call      ReadReg
         mov       ds:[TXTotal],al

         mov       ah,1
         call      ReadReg
         mov       ds:[TXDisp],al

         mov       ah,4
         call      ReadReg
         mov       ds:[TXShft],al

         mov       ah,5
         call      ReadReg
         mov       ds:[TXEnd],al

         mov       ah,10h
         call      ReadReg
         mov       byte ptr ds:[TYShft],al

         mov       ah,7
         call      ReadReg
         mov       ah,al
         and       al,b2
         shr       al,1
         shr       al,1
         and       ah,b7
         rol       ah,1
         rol       ah,1
         or        al,ah
         mov       byte ptr ds:[TYShft+1],al

         mov       ah,11h
         call      ReadReg
         mov       ds:[TYEnd],al

;         call      CRTCON
         ret

TGetReg  ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ registr…
; -----------------------------------------------------------------------------

TSetReg  PROC      NEAR

         call      GetCPort                 ; adresa ýadiŸe CRT

         mov       ah,11h
         call      ReadReg
         and       al,not 80h               ; povolen¡ pý¡stupu k reg. 0-7
         call      WritReg

         mov       ah,3
         call      ReadReg
         or        al,80h                   ; povolen¡ pý¡stupu k reg. 10h-11h
         call      WritReg

         mov       al,ds:[TXShft]           ; posun X
         mov       ah,4
         call      WritReg

         mov       ah,5
         call      ReadReg
         mov       cl,ds:[TXEnd]
         and       al,not 1fh
         and       cl,1fh
         or        al,cl
         call      WritReg                  ; konec horiz. synchr.

         mov       ah,10h
         mov       al,byte ptr ds:[TYShft]
         call      WritReg

         mov       ah,7
         call      ReadReg
         mov       cl,byte ptr ds:[TYShft+1]
         mov       ch,cl
         shl       cl,1
         shl       cl,1
         ror       ch,1
         ror       ch,1
         and       cx,b7*HI+b2
         and       al,not b2+b7
         or        al,cl
         or        al,ch
         call      WritReg

         mov       ah,11h
         call      ReadReg
         and       al,not 0fh
         mov       cl,ds:[TYEnd]
         and       cl,0fh
         or        al,cl
         call      WritReg


         mov       ah,3
         call      ReadReg
         and       al,not 80h               ; z kaz pý¡stupu k reg. 10h-11h
         call      WritReg

         mov       ah,11h
         call      ReadReg
         or        al,80h                   ; z kaz pý¡stupu k reg. 0-7
         call      WritReg

         ret

TSetReg  ENDP

; -----------------------------------------------------------------------------
;        posun vlevo
; -----------------------------------------------------------------------------

ShftLeft PROC      NEAR

         xor       ax,ax
         xor       cx,cx
         mov       cl,ds:[TXShft]
         mov       al,ds:[TXTotal]
         add       cx,2

         cmp       ax,cx
         jb        ShftLft2

         inc       byte ptr ds:[TXShft]
         inc       byte ptr ds:[TXEnd]
         clc
ShftLft2:
         ret

ShftLeft ENDP

; -----------------------------------------------------------------------------
;        posun vpravo
; -----------------------------------------------------------------------------

ShftRght PROC      NEAR

         xor       ax,ax
         xor       cx,cx
         mov       cl,ds:[TXDisp]
         mov       al,ds:[TXShft]
         inc       cx
         inc       cx
         cmp       al,cl
         jb        ShftRgh9

         dec       byte ptr ds:[TXShft]
         dec       byte ptr ds:[TXEnd]
         clc
ShftRgh9:ret

ShftRght ENDP

; -----------------------------------------------------------------------------
;        posun nahoru
; -----------------------------------------------------------------------------

ShftUp   PROC      NEAR


         inc       word ptr ds:[TYShft]
         inc       byte ptr ds:[TYEnd]
         clc
         ret

ShftUp   ENDP

; -----------------------------------------------------------------------------
;        posun dol…
; -----------------------------------------------------------------------------

ShftDwn  PROC      NEAR


         dec       word ptr ds:[TYShft]
         dec       byte ptr ds:[TYEnd]
         clc
         ret

ShftDwn  ENDP

; -----------------------------------------------------------------------------
;        rozsv¡cen¡ displeje
; -----------------------------------------------------------------------------

CRTCON   PROC      NEAR

         call      GetCPort
         add       dl,6
         in        al,dx
         mov       dl,0c0h
         mov       al,20h
         out       dx,al
         ret

CRTCON   ENDP

; -----------------------------------------------------------------------------
;        poskytnut¡ ý¡dic¡ho registru ýadiŸe
; -----------------------------------------------------------------------------

GetCPort PROC      NEAR

         push      ds
         xor       dx,dx
         mov       ds,dx
         mov       dx,ds:[463h]
         pop       ds
         ret

GetCPort ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ registru AH ýadiŸe grafiky na AL
; -----------------------------------------------------------------------------

WritCRTC PROC      NEAR

         call      GetCPort
         push      ax
         add       dl,6
         in        al,dx
         mov       dx,3c0h
         mov       al,ah
         out       dx,al                    ; volba registru
         pop       ax
         out       dx,al                    ; nastaven¡ registru
         ret

WritCRTC ENDP

; -----------------------------------------------------------------------------
;        z pis registru AH portu DX
; -----------------------------------------------------------------------------

WritReg  PROC      NEAR

         xchg      al,ah
         out       dx,al                    ; nastaven¡ Ÿ¡sla registru
         inc       dx
         xchg      ah,al
         jmp       short $+2
         out       dx,al                    ; z pis do registru
         dec       dx
         ret

WritReg  ENDP

; -----------------------------------------------------------------------------
;        Ÿten¡ registru AH ýadiŸe grafiky
; -----------------------------------------------------------------------------

ReadCRTC PROC      NEAR

         call      GetCPort
         add       dl,6
         in        al,dx
         jmp       short $+2
         mov       dx,3c0h
                                            ; pokraŸuje Ÿten¡ registru AH !

ReadCRTC ENDP

; -----------------------------------------------------------------------------
;        Ÿten¡ registru AH portu DX
; -----------------------------------------------------------------------------

ReadReg  PROC      NEAR

         mov       al,ah
         out       dx,al                    ; nastaven¡ Ÿ¡sla registru
         inc       dx
         jmp       short $+2
         in        al,dx                    ; Ÿten¡ registru
         dec       dx
         ret

ReadReg  ENDP

; -----------------------------------------------------------------------------
;      zobrazen¡ obd‚ln¡ku barev (BH=max. barva, BL=ç¡ýka, CH=vìçka, DX=pozice)
; -----------------------------------------------------------------------------

DispBox  PROC      NEAR

         push      ax
         push      cx
         push      dx

         cmp       cl,1
         je        DispBox1
         shl       dl,1

DispBox1:push      bx
         push      dx

DispBox2:mov       al,bh
         mov       ah,0
         inc       ax
         call      Random
         cmp       bh,2
         jne       DispBox3
         cmp       al,2
         jne       DispBox3
         mov       al,0fh
DispBox3:mov       ah,al
         mov       al,"Û"
         cmp       bh,1
         jne       DispBox4
         cmp       ah,0
         jne       DispBox4
         mov       ax," "
DispBox4:call      DispChr
         dec       bl
         jnz       DispBox2

         pop       dx
         pop       bx
         inc       dh
         dec       ch
         jnz       DispBox1

         pop       dx
         pop       cx
         pop       ax
         ret

DispBox  ENDP

; -----------------------------------------------------------------------------
;      zobrazen¡ obd‚ln¡ku barev (BH=max. barva, BL=ç¡ýka, DX=pozice)
; -----------------------------------------------------------------------------

DispCol  PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx

         push      ax
         mov       ah,0fh
         mov       al,16
         call      Disp1Chr
         pop       ax

         dec       ah

DispCol2:inc       ah
         cmp       ah,bh
         jbe       DispCl22
         mov       ah,0
DispCl22:
         cmp       bh,2
         jne       DispCol3
         cmp       ah,2
         jne       DispCol3
         mov       ah,0fh
DispCol3:
         mov       al,"Û"
         cmp       bh,1
         jne       DispCol4
         cmp       ah,0
         jne       DispCol4
         mov       al," "
DispCol4:call      Disp1Chr
         dec       bl
         jnz       DispCol2

         mov       ah,0fh
         mov       al,17
         call      Disp1Chr

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispCol  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ Ÿ¡sla AL (barva AH, pozice DX, d‚lka CL)
; -----------------------------------------------------------------------------

DispByte PROC      NEAR

         push      ax
         push      cx

         xchg      al,cl                    ; CL <- Ÿ¡slo, AL <- d‚lka
         mov       ch,0
         call      DispWord                 ; zobrazen¡ Ÿ¡sla

         pop       cx
         pop       ax
         ret

DispByte ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ Ÿ¡sla CX (barva AH, pozice DX, d‚lka AL)
; -----------------------------------------------------------------------------

DispWord PROC      NEAR

; ------ £schova registr…

         push      ax
         push      bx
         push      cx
         push      si
         push      di

; ------ pý¡prava registr…

         mov       di,dx                    ; £schova pozice k zobrazen¡
         xchg      ax,bx                    ; BH <- barva textu, BL <- d‚lka
         xchg      ax,cx                    ; AX <- Ÿ¡slo k zobrazen¡
         xor       cx,cx                    ; Ÿ¡taŸ poŸtu Ÿ¡slic
         mov       si,10                    ; dØlitel Ÿ¡sla

; ------ dek¢dov n¡ Ÿ¡sla

DispWrd1:xor       dx,dx                    ; DX <- 0
         div       si                       ; vìpoŸet jedn‚ Ÿ¡slice
         add       dl,"0"                   ; korekce na znak ASCII
         mov       dh,bh                    ; barva textu
         push      dx                       ; £schova Ÿ¡slice
         inc       cx                       ; Ÿ¡taŸ Ÿ¡slic
         dec       bl                       ; Ÿ¡taŸ pozic
         jns       DispWrd2
         inc       bl
DispWrd2:or        ax,ax                    ; je jeçtØ Ÿ¡slo ?
         jnz       DispWrd1                 ; vìpoŸet dalç¡ Ÿ¡slice

; ------ zobrazen¡ mezer pýed Ÿ¡slem

         mov       dx,di                    ; ý dek a pozice k zobrazen¡ Ÿ¡sla
         mov       ah,bh                    ; barva textu
         mov       al," "                   ; znak mezery
         push      cx
         mov       cl,bl                    ; poŸet zbylìch mezer
         call      DispChr                  ; zobrazen¡ mezer pýed Ÿ¡slem
         pop       cx

; ------ zobrazen¡ dek¢dovan‚ho Ÿ¡sla

DispWrd3:pop       ax
         call      Disp1Chr                 ; zobrazen¡ Ÿ¡slice
         loop      DispWrd3

; ------ n vrat registr… (bez DX)

         pop       di
         pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

DispWord ENDP

; -----------------------------------------------------------------------------
;        z pis ýetØzce znak… vystýedØnØ
; -----------------------------------------------------------------------------

DispCent PROC      NEAR

         push      dx
         mov       dl,ds:[TestVPoz]         ; poŸet pozic na ý dek
         sub       dl,ds:[si]               ; zbylì poŸet na okraje
         shr       dl,1                     ; poŸ teŸn¡ pozice
         call      DispStr                  ; zobrazen¡ ýetØzce
         pop       dx
         inc       dh                       ; zvìçen¡ ý dku
         ret

DispCent ENDP

; -----------------------------------------------------------------------------
;        z pis ýetØ§ce znak… DS:SI od pozice DX, barva AH (1. bajt = d‚lka)
; -----------------------------------------------------------------------------

DispStr  PROC      NEAR

; ------ £schova registr…

         push      ax
         push      cx

; ------ zobrazen¡ textu

         mov       ch,0
         mov       cl,ds:[si]               ; d‚lka ýetØzce
         inc       si                       ; zaŸ tek textu
         jcxz      DispStr2                 ; nen¡ text
DispStr1:cld
         lodsb                              ; znak k zobrazen¡
         call      Disp1Chr                 ; zobrazen¡ znaku
         loop      DispStr1                 ; zobrazen¡ dalç¡ho znaku

; ------ n vrat registr…

DispStr2:pop       cx
         pop       ax
         ret

DispStr  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ CL mezer
; -----------------------------------------------------------------------------

DispSpc  PROC      NEAR

         push      ax
         mov       al," "
         call      DispChr
         pop       ax
         ret

DispSpc  ENDP

; -----------------------------------------------------------------------------
;        z pis jednoho znaku AX na pozici DX
; -----------------------------------------------------------------------------

Disp1Chr PROC      NEAR

         push      cx
         mov       cl,1
         call      DispChr
         pop       cx
         ret

Disp1Chr ENDP

; -----------------------------------------------------------------------------
;        z pis znaku AX na pozici DX - poŸet CL (BIOS)
; -----------------------------------------------------------------------------

DispChr  PROC      NEAR

; ------ £schova registr…

         push      ax
         push      bx
         push      cx

; ------ nastaven¡ pozice kurzoru

         call      SetKurz                  ; nastaven¡ pozice kurzoru

; ------ z pis znaku na pozici kurzoru

         mov       ch,0
         jcxz      DispChr2                 ; nejsou znaky k zobrazen¡
         mov       bl,ah                    ; barva
         mov       ah,9
         mov       bh,0                     ; aktu ln¡ videostr nka
         call      Int10A                   ; z pis znaku

; ------ n vrat registr…

DispChr2:pop       cx
         pop       bx
         pop       ax
         add       dl,cl                    ; zvìçen¡ pozice
         ret

DispChr  ENDP

; -----------------------------------------------------------------------------
;        vypnut¡ kurzoru
; -----------------------------------------------------------------------------

KurzOff  PROC      NEAR

         push      dx
         mov       dh,ds:[TestVRad]         ; ý dek "za rohem"
         mov       dl,0
         call      SetKurz                  ; nastaven¡ pozice kurzoru
         pop       dx
         ret

KurzOff  ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ pozice kurzoru DX
; -----------------------------------------------------------------------------

SetKurz  PROC      NEAR

         push      ax
         push      bx
         mov       bh,0                     ; aktu ln¡ videostr nka
         mov       ah,2
         call      Int10A                   ; nastaven¡ pozice kurzoru
         pop       bx
         pop       ax
         ret

SetKurz  ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 10h s £schovou vçech registr…
; -----------------------------------------------------------------------------

Int10A   PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx

         call      Int10P

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Int10A   ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 10h s £schovou registr…
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

; *****************************************************************************
;
;                    Detekce videokarty (AX=Ÿ¡slo videokarty)
;
; *****************************************************************************
;þ
DetVGA   PROC      NEAR

; ------ pýedbØ§n‚ rozliçen¡ videokarty podle ROM BIOS

         call      Det0VGA                  ; detekce videokarty podle ROM BIOS

; ------ upýesnØn¡ videokarty TRIDENT

         cmp       ax,TRIDENT1              ; je karta TRIDENT ?
         jne       DetVGA1                  ; nen¡ TRIDENT
         call      DetTrid                  ; detekce videokarty TRIDENT


DetVGA1:


         mov       ds:[Card+KORIG],ax       ; ulo§en¡ pýedbØ§n‚ho typu karty
         mov       ds:[CardDet],ax          ; detekovanì typ videokarty
         ret

DetVGA   ENDP

; -----------------------------------------------------------------------------
;        detekce videokarty podle ROM BIOS (AX=Ÿ¡slo videokarty)
; -----------------------------------------------------------------------------

Det0VGA  PROC      NEAR

; ------ pý¡prava k prohled n¡ ROM BIOS videokarty

         mov       ax,0c000h
         mov       es,ax                    ; ES <- segment VGA ROM BIOS
         mov       si,offset CardVzor       ; tabulka vzork… videokaret
         cld

; ------ test, zda je ji§ konec tabulky

Det0VGA1:lodsb                              ; Ÿ¡slo typu videokarty
         mov       ah,0
         cmp       al,STANDVGA              ; je ji§ konec ?
         je        Det0VGA9                 ; videokarta nenalezena

; ------ pý¡prava k vyhled n¡ vzorku

         xor       di,di                    ; poŸ teŸn¡ adresa ve VGA ROM BIOS
         lodsb                              ; d‚lka textu vzorku
         xchg      ax,cx                    ; CX <- d‚lka textu vzorku

; ------ porovn n¡ vzorku na jedn‚ adrese DI

Det0VGA2:push      si
         push      di
         push      cx
Det0VGA3:lodsb                              ; znak vzorku
         mov       ah,es:[di]               ; vzorek z ROM BIOS
         inc       di                       ; zvìçen¡ ukazatele v ROM BIOS
         cmp       ah,"a"
         jb        Det0VGA4
         cmp       ah,"z"
         ja        Det0VGA4
         sub       ah,32                    ; korekce na velk‚ p¡smeno
Det0VGA4:cmp       al,ah                    ; souhlas¡ znak ?
         loope     Det0VGA3                 ; znak souhlas¡ - test dalç¡ho
         pop       cx
         pop       di
         pop       si

; ------ nesouhlas¡-li vzorek, test dalç¡ adresy

         je        Det0VGA8                 ; vzorek souhlas¡ OK
         inc       di                       ; zvìçen¡ adresy v pamØti ROM BIOS
         cmp       di,400h                  ; maxim ln¡ adresa
         jb        Det0VGA2                 ; test dalç¡ adresy

; ------ vzorek nesouhlas¡ - dalç¡ vzorek v tabulce

         add       si,cx                    ; adresa dalç¡ho vzorku
         jmp       short Det0VGA1           ; test dalç¡ho vzorku

; ------ karta nalezena OK

Det0VGA8:mov       al,ds:[si-2]             ; Ÿ¡slo videokarty
         mov       ah,0
Det0VGA9:ret

Det0VGA  ENDP

; -----------------------------------------------------------------------------
;        detekce videokarty TRIDENT (AX=typ videokarty)
; -----------------------------------------------------------------------------

DetTrid  PROC      NEAR

         mov       dx,3c4h
         mov       al,0bh
         out       dx,al                    ; volba Ÿ¡sla registru
         inc       dx
         in        al,dx                    ; Ÿten¡ Ÿ¡sla verze Ÿipu
         xchg      ax,dx
         mov       ax,TRIDENT1              ; Trident 8800
         cmp       dl,3
         jb        DetTrid2                 ; je Trident 8800
         mov       al,TRIDENT2              ; Trident 8900
         je        DetTrid2                 ; je Trident 8900
         mov       al,TRIDENT3              ; Trident 9000
DetTrid2:ret

DetTrid  ENDP

; *****************************************************************************
;
;                         Rozbor zad n¡ parametr…
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        rozbor zad n¡ parametr… (DS=datovì segment, ES=rezidentn¡ program)
; -----------------------------------------------------------------------------

Rozbor   PROC      NEAR

; ------ nalezen¡ platn‚ho znaku

         mov       si,offset Command
Rozbor1: call      RozbSpc                  ; vypuçtØn¡ mezer
         call      RozbChr                  ; naŸten¡ znaku
         jnc       Rozbor2
         clc                                ; pý¡znak zad n¡ parametr… OK
         ret
Rozbor2: cmp       al,"/"
         je        Rozbor1                  ; znak "/" se ignoruje

; ------ parametr "A" - zapnut¡ televizn¡ho m¢du

Rozbor3: cmp       al,"A"
         jne       Rozbor4
         or        byte ptr es:[Param+KORIG],b0 ; zapnut¡ m¢du TV
         or        byte ptr ds:[ParamI],b3  ; po§adavek reinicializace
         jmp       short Rozbor1            ; dalç¡ parametr

; ------ parametr "N" - vypnut¡ televizn¡ho m¢du

Rozbor4: cmp       al,"N"
         jne       Rozbor5
         and       byte ptr es:[Param+KORIG],not b0 ; vypnut¡ m¢du TV
         or        byte ptr ds:[ParamI],b3  ; po§adavek reinicializace
         jmp       short Rozbor1

; ------ parametr "!" - odinstalov n¡ programu

Rozbor5: cmp       al,"!"
         jne       Rozbor6
         or        byte ptr ds:[ParamI],b1  ; povel pro odinstalov n¡
         jmp       short Rozbor1

; ------ parametr "C" - nastaven¡ konfigurace programu

Rozbor6: cmp       al,"C"
         jne       Rozbor7
         or        byte ptr ds:[ParamI],b2  ; po§adavek konfigurace
         jmp       short Rozbor1

; ------ nastaven¡ m¢du emulace CGA, EGA nebo VGA

Rozbor7: mov       ah,b2
         cmp       al,"G"
         je        Rozbor72
         mov       ah,b1
         cmp       al,"E"
         je        Rozbor72
         mov       ah,0
         cmp       al,"V"
         jne       Rozbor73
Rozbor72:and       byte ptr es:[Param+KORIG],not b1+b2
         or        es:[Param+KORIG],ah
         or        byte ptr ds:[ParamI],b3  ; po§adavek reinicializace
         jmp       short Rozbor1

Rozbor73:
         stc                                ; pý¡znak chyby zad n¡ parametr…
         ret

Rozbor   ENDP

; -----------------------------------------------------------------------------
;        vypuçtØn¡ mezer z pý¡kazov‚ho ý dku
; -----------------------------------------------------------------------------

RozbSpc  PROC      NEAR

         call      RozbChr                  ; naŸten¡ znaku z pý¡kazov‚ho ý dku
         jc        RozbSpc2                 ; konec textu
         je        RozbSpc                  ; mezera
         dec       si
RozbSpc2:ret

RozbSpc  ENDP

; -----------------------------------------------------------------------------
;        naŸten¡ znaku z pý¡kazov‚ho ý dku
; -----------------------------------------------------------------------------

RozbChr  PROC      NEAR

; ------ naŸten¡ znaku

         cld
         lodsb

; ------ n hrada tabel toru mezerou

         cmp       al,9
         jne       RozbChr1
         mov       al," "                   ; n hrada tabel toru mezerou

; ------ konverze na velk‚ p¡smeno

RozbChr1:cmp       al,"a"
         jb        RozbChr2
         cmp       al,"z"
         ja        RozbChr2
         sub       al,32                    ; konverze na velk‚ p¡smeno

; ------ test, zda je konec textu

RozbChr2:cmp       al," "
         jae       RozbChr3
         dec       si
RozbChr3:ret

RozbChr  ENDP

; -----------------------------------------------------------------------------
;        inicializace videom¢du
; -----------------------------------------------------------------------------

InitVMod PROC      NEAR

; ------ v bØ§n‚m m¢du nastaven¡ 480 linek

         test      byte ptr ds:[Param+KORIG],b0 ; aktivn¡ TV m¢d ?
         jnz       InitVMd1                 ; je aktivn¡ TV m¢d
         mov       ax,1202h
         mov       bl,30h
         int       10h                      ; nastaven¡ m¢du 480 linek

; ------ pýedefinov n¡ videom¢du

InitVMd1:mov       ah,0fh
         int       10h                      ; poskytnut¡ videom¢du
         mov       ah,0
         int       10h                      ; pýeinstalov n¡ videom¢du

; ------ hl çen¡ o instalaci programu

         mov       ax,1301h
         mov       bx,70h                   ; barva textu a str nka
         mov       cx,offset(InstTxt0-InstTxt) ; d‚lka textu
         xor       dx,dx                    ; poŸ teŸn¡ pozice a ý dek
         mov       bp,offset InstTxt        ; text k zobrazen¡
         push      cs
         pop       es
         int       10h                      ; zobrazen¡ £vodn¡ho textu
         ret

InitVMod ENDP

; -----------------------------------------------------------------------------
;                         InitRnd
;                  inicializace gener toru n hody
; -----------------------------------------------------------------------------
; VSTUP: DS=datovì segment
; -----------------------------------------------------------------------------

InitRnd  PROC      NEAR

         push      ax
         push      ds
         xor       ax,ax
         mov       ds,ax
         mov       ax,ds:[46ch]             ; Ÿ¡taŸ syst‚mov‚ho ŸasovaŸe
         pop       ds
         mov       word ptr ds:[RandomR],ax ; inicializaŸn¡ konstanta
         pop       ax
         ret

InitRnd  ENDP

; -----------------------------------------------------------------------------
;                           Random
;                   gener tor n hodn‚ho Ÿ¡sla
; -----------------------------------------------------------------------------
; VSTUP: AX=max. hodnota
;        DS=datovì segment
; VíSTUP: AX=Ÿ¡slo 0 a§ (max. hodnota - 1)
; -----------------------------------------------------------------------------

Random   PROC      NEAR

         push      bx
         push      dx
         or        ax,ax
         jz        Random1
         mov       bx,ax                    ; po§adovanì rozsah
         call      Random0                  ; generov n¡ n hodn‚ho Ÿ¡sla DX:AX
         xchg      ax,dx                    ; AX <- n hodn‚ Ÿ¡slo
         xor       dx,dx
         div       bx
         xchg      ax,dx
Random1: pop       dx
         pop       bx
         ret

Random   ENDP

; -----------------------------------------------------------------------------

Random0  PROC      NEAR

         push      bx
         push      cx
         mov       ax,word ptr ds:[RandomR]
         mov       bx,word ptr ds:[RandomR+2]
         mov       cx,ax
         mul       word ptr cs:[RandomD]
         shl       cx,1
         shl       cx,1
         shl       cx,1
         add       ch,cl
         add       dx,cx
         add       dx,bx
         shl       bx,1
         shl       bx,1
         add       dx,bx
         add       dh,bl
         mov       cl,5
         shl       bx,cl
         add       dh,bl
         add       ax,1
         adc       dx,0
         mov       word ptr ds:[RandomR],ax
         mov       word ptr ds:[RandomR+2],dx
         pop       cx
         pop       bx
         ret

Random0  ENDP

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                                    data
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;þ

; ------ gener tor n hody

RandomR  dd        21510d31h                ; promØnn  pro gener tor n hody
RandomD  dw        8405h                    ; pomocn  konstanta

SoubCnf  db        'TVMOD.CNF',90 dup(0)    ; konfiguraŸn¡ soubor

RezSegm  dw        0                        ; segment rezidentn¡ho programu

ParamI   db        0                        ; parametry pro inicializaci
                                            ;  bit 0: 1=je prvn¡ instalace
                                            ;  bit 1: 1=po§adov no odinstalov n¡
                                            ;  bit 2: 1=po§adov na konfigurace
                                            ;  bit 3: 1=nutn  reinicialice m¢du
                                            ;  bit 4: 1=byl posun obrazu

UvTxt    db        'TVMOD V1.20 - televizni emulator; (c) Miroslav Nemecek 1997',13,10,'$'
HelpTxt  db        'Zadejte: A .... zapnuti televizniho modu (emulator aktivni)',13,10
         db        '         N .... vypnuti televizniho modu (emulator neaktivni)',13,10
         db        '         ! .... odinstalovani programu z pameti',13,10
         db        '         C .... nastaveni konfigurace programu',13,10
         db        '         G .... mod simulace CGA',13,10
         db        '         E .... mod simulace EGA',13,10
         db        '         V .... plny mod VGA',13,10
NicTxt   db        '$'

NebylTxt db        'TVMOD nebyl dosud nainstalovan !',13,10,'$'
NelzeTxt db        'TVMOD nelze odinstalovat ! Odinstalujte',13,10
         db        'nejdrive programy nainstalovane po nem.',13,10,'$'
OdInsTxt db        'TVMOD byl odinstalovan z pameti.',13,10,'$'

InstTxt  db        13,10
         db        ' ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ» ',13,10
         db        ' º           TVMOD V 1.20           º ',13,10
         db        ' º televizni emulator pro kartu VGA º ',13,10
         db        ' º       (c) Miroslav Nemecek       º ',13,10
         db        ' ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼ ',13,10
InstTxt0 label     byte

CardVzor label     byte                     ; vzorky k hled n¡ videokaret
         db        TRIDENT1,7,'TRIDENT'     ; Trident
         db        OAKTECHN,9,'OAK TECHN'   ; OAK Technology
         db        REALTEK,7,'REALTEK'      ; Realtek
         db        WESTERN,11,'WESTERN DIG' ; Western Digital
         db        PARADISE,8,'PARADISE'    ; Paradise VGA
         db        STANDVGA                 ; jinak standardn¡ VGA

CardTxt  label     byte                     ; n zvy videokaret
         db        12,'VGA standard'
         db        17,'Trident TVGA 8800'
         db        17,'Trident TVGA 8900'
         db        17,'Trident TVGA 9000'
         db        18,'OAK Technology VGA'
         db        11,'Realtek VGA'
         db        19,'Western Digital VGA'
         db        12,'Paradise VGA'

; ------ volby pro nastaven¡ konfigurace

VolAkt   db        1                        ; aktivn¡ volba (1...)

VolNadp  db        ' Konfigurace programu TVMOD '
VolNadp0 label     byte

Volby    label     byte                     ; volby pro nastaven¡ konfigurace
         db        32,'A',0,' ... Textovy mod 40x25 16 barev'
         db        32,'B',0,' ... Textovy mod 80x25 16 barev'
         db        33,'C',0,' ... Textovy mod 80x25 monochrom'
         db        34,'D',0,' ... Graficky mod 320x200 4 barvy'
         db        34,'E',0,' ... Graficky mod 640x200 2 barvy'
         db        35,'F',0,' ... Graficky mod 320x200 16 barev'
         db        35,'G',0,' ... Graficky mod 640x200 16 barev'
         db        36,'H',0,' ... Graficky mod 640x350 monochrom'
         db        35,'I',0,' ... Graficky mod 640x350 16 barev'
         db        34,'J',0,' ... Graficky mod 640x480 2 barvy'
         db        35,'K',0,' ... Graficky mod 640x480 16 barev'
         db        36,'L',0,' ... Graficky mod 320x200 256 barev'
         db        0
         db        36,'V',0,' ... Videokarta (',0
VolCardT db        'VGA standard',0,')     '
         db        36,'X',0,' ... Horizontalni synchronizace ',0
HorSTxt  db        'POZ'
         db        36,'Y',0,' ... Vertikalni synchronizace   ',0
VerSTxt  db        'POZ'
         db        23,'Q',0,' ... Konec konfigurace'

DetCTxt  db        22,'Detekovana videokarta '

VolCard  label     byte                     ; volen‚ videokarty
         db        'VGA standard',0,')     '
VolCard0 db        'Trident TVGA 8800',0,')'
         db        'Trident TVGA 8900',0,')'
         db        'Trident TVGA 9000',0,')'
         db        'OAK Technology',0,')   '
         db        'Realtek VGA',0,')      '
         db        'Western Digital',0,')  '
         db        'Paradise VGA',0,')     '

CardDet  dw        STANDVGA                 ; detekovanì typ videokarty

; ------ test videom¢du

TestVMod db        0                        ; testovanì videom¢d
TestVCol db        0                        ; poŸet barev videom¢du
TestVPoz db        0                        ; poŸet pozic na ý de
TestVRad db        0                        ; poŸet ý dk…

TabTMod  label     byte                     ; tabulka definic videom¢d…
         db        1,15,40,25               ; Ÿ¡slo m¢du, barev, pozic, ý dk…
         db        3,15,80,25
         db        7,2,80,25
         db        5,3,40,25
         db        6,1,80,25
         db        13,15,40,25
         db        14,15,80,25
         db        15,2,80,25
         db        16,15,80,25
         db        17,1,80,30
         db        18,15,80,30
         db        19,127,40,25

Cent1Txt db        18,'KURZORY=vystredeni'
Cent2Txt db        28,'ENTER=ulozeni, ESC=preruseni'

; ------ standardn¡ karta VGA

TabStd   label     byte                     ; tabulka pro inicializaci
         db        0                        ; 00h, 01h: text 40x25/16
         db        1                        ; 02h, 03h: text 80x25/16
         db        2                        ; 04h, 05h: graf 320x200/4
         db        3                        ; 06h: graf 640x200/2
         db        4                        ; 07h: text 80x25/16
         db        5                        ; 0dh: graf 320x200/16
         db        6                        ; 0eh: graf 640x200/16
         db        7                        ; 0fh, 10h: graf 640x350/2
         db        8                        ; 11h, 12h: graf 640x480/2
         db        9                        ; 13h: graf 320x200/256
TabStd0  label     byte

; ------ TRIDENT 8800

TabTri1  label     byte                     ; tabulka pro inicializaci
         db        0                        ; 00h, 01h: text 40x25/16
         db        1                        ; 02h, 03h: text 80x25/16
         db        2                        ; 04h, 05h: graf 320x200/4
         db        3                        ; 06h: graf 640x200/2
         db        4                        ; 07h: text 80x25/16
         db        5                        ; 0dh: graf 320x200/16
         db        6                        ; 0eh: graf 640x200/16
         db        7                        ; 0fh, 10h: graf 640x350/2
         db        8                        ; 11h, 12h: graf 640x480/2
         db        18                       ; 13h: graf 320x200/256

; ------ TRIDENT 8900

TabTri2  label     byte                     ; tabulka pro inicializaci
         db        10                       ; 00h, 01h: text 40x25/16
         db        1                        ; 02h, 03h: text 80x25/16
         db        11                       ; 04h, 05h: graf 320x200/4
         db        3                        ; 06h: graf 640x200/2
         db        4                        ; 07h: text 80x25/16
         db        12                       ; 0dh: graf 320x200/16
         db        6                        ; 0eh: graf 640x200/16
         db        7                        ; 0fh, 10h: graf 640x350/2
         db        8                        ; 11h, 12h: graf 640x480/2
         db        18                       ; 13h: graf 320x200/256

; ------ TRIDENT 9000

TabTri3  label     byte                     ; tabulka pro inicializaci
         db        10                       ; 00h, 01h: text 40x25/16
         db        1                        ; 02h, 03h: text 80x25/16
         db        11                       ; 04h, 05h: graf 320x200/4
         db        3                        ; 06h: graf 640x200/2
         db        4                        ; 07h: text 80x25/16
         db        12                       ; 0dh: graf 320x200/16
         db        6                        ; 0eh: graf 640x200/16
         db        7                        ; 0fh, 10h: graf 640x350/2
         db        8                        ; 11h, 12h: graf 640x480/2
         db        18                       ; 13h: graf 320x200/256

; ------ OAK

TabOAK   label     byte                     ; tabulka pro inicializaci
         db        13                       ; 00h, 01h: text 40x25/16
         db        1                        ; 02h, 03h: text 80x25/16
         db        14                       ; 04h, 05h: graf 320x200/4
         db        3                        ; 06h: graf 640x200/2
         db        4                        ; 07h: text 80x25/16
         db        15                       ; 0dh: graf 320x200/16
         db        6                        ; 0eh: graf 640x200/16
         db        16                       ; 0fh, 10h: graf 640x350/2
         db        17                       ; 11h, 12h: graf 640x480/2
         db        9                        ; 13h: graf 320x200/256

; ------ Realtek VGA

TabReal  label     byte                     ; tabulka pro inicializaci
         db        10                       ; 00h, 01h: text 40x25/16
         db        1                        ; 02h, 03h: text 80x25/16
         db        11                       ; 04h, 05h: graf 320x200/4
         db        3                        ; 06h: graf 640x200/2
         db        4                        ; 07h: text 80x25/16
         db        12                       ; 0dh: graf 320x200/16
         db        6                        ; 0eh: graf 640x200/16
         db        7                        ; 0fh, 10h: graf 640x350/2
         db        8                        ; 11h, 12h: graf 640x480/2
         db        9                        ; 13h: graf 320x200/256

; ------ Western Digital VGA

TabWest  label     byte                     ; tabulka pro inicializaci
         db        0                        ; 00h, 01h: text 40x25/16
         db        1                        ; 02h, 03h: text 80x25/16
         db        2                        ; 04h, 05h: graf 320x200/4
         db        3                        ; 06h: graf 640x200/2
         db        4                        ; 07h: text 80x25/16
         db        5                        ; 0dh: graf 320x200/16
         db        6                        ; 0eh: graf 640x200/16
         db        16                       ; 0fh, 10h: graf 640x350/2
         db        17                       ; 11h, 12h: graf 640x480/2
         db        9                        ; 13h: graf 320x200/256

; ------ Paradise VGA

TabPar   label     byte                     ; tabulka pro inicializaci
         db        0                        ; 00h, 01h: text 40x25/16
         db        1                        ; 02h, 03h: text 80x25/16
         db        2                        ; 04h, 05h: graf 320x200/4
         db        3                        ; 06h: graf 640x200/2
         db        4                        ; 07h: text 80x25/16
         db        5                        ; 0dh: graf 320x200/16
         db        6                        ; 0eh: graf 640x200/16
         db        16                       ; 0fh, 10h: graf 640x350/2
         db        17                       ; 11h, 12h: graf 640x480/2
         db        9                        ; 13h: graf 320x200/256

TabReg   label     byte
; -----------------------------------------------------------------------------
;        standardn¡ VGA, TRIDENT 8800
; -----------------------------------------------------------------------------
;þ
; ------ 0: 0, 1 (text 40x25/16) standard, TRIDENT 8800, Western
; 06Ch,027h,028h,08Eh,05Bh,083h,036h,011h, 047h, 0FCh,013h,0C7h,014h, 0F8h,005h

         db        8                        ; 3C0h/13h: posun bod… PANNING
         db        b3                       ; 3C4h/01h: m¢t taktov n¡
         db        0*b2                     ; 3C2h: frekvence hodin
         db        84                       ; 0: poŸet horiz. pozic celkem - 5
         db        39                       ; 1: poŸet zobrazenìch znak… - 1
         db        56                       ; 2: poŸ tek horizont l. zatemnØn¡
         db        ((56+17) AND 1fh)+b7     ; 3: konec horizont ln¡ho zatemnØn¡
ShftRg1  db        61                       ; 4: poŸ tek horiz. synchronizace
ShftRg2  db        ((61+6) AND 1fh)+(4*((56+17) AND 20h)) ; 5: konec hor.synchr.
         db        (312-2) AND 0ffh         ; 6: poŸet vertik. linek celkem - 2
ShftRg5  db        b0+b4                    ; 7: doplåuj¡c¡ bity registr…
         db        7+b6                     ; 9: poŸet linek na znak - 1
         db        7                        ; 0Ah: poŸ teŸn¡ linka kurzoru
         db        7                        ; 0Bh: koncov  linka kurzoru
ShftRg3  db        245                      ; 10h: zaŸ tek vertik. synchronizace
ShftRg4  db        (245+4) AND 0fh + b7     ; 11h: d‚lka vertik. synchronizace
         db        199                      ; 12h: posledn¡ zobrazen  linka
         db        20                       ; 13h: pý¡rustek adresy v pamØti/2
         db        31                       ; 14h: podtr§en¡ MDA
         db        244                      ; 15h: zaŸ tek vertik l. zatemnØn¡
         db        (244+25) AND 0ffh        ; 16h: konec vertik ln¡ho zatemnØn¡
         db        b7+b5+b1+b0              ; 17h: ý¡dic¡ registr m¢du pamØti

; ------ 1: 2, 3 (text 80x25/16) standard, TRIDENT 8800, Realtek, Western
; 06Ch,04Fh,050h,08Eh,05Bh,083h,036h,011h, 047h, 0FBh,013h,0C7h,028h, 0F8h,005h

         db        0                        ; 3C0h/13h: posun bod… PANNING
         db        b3+b0                    ; 3C4h/01h: m¢t taktov n¡
         db        1*b2                     ; 3C2h: frekvence hodin
         db        107                      ; 0: poŸet horiz. pozic celkem - 5
         db        79                       ; 1: poŸet zobrazenìch znak… - 1
         db        85                       ; 2: poŸ tek horiz. zatemnØn¡
         db        ((85+21) AND 1fh)+b7     ; 3: ç¡ýka horiz. zatemnØn¡
         db        91                       ; 4: poŸ tek horiz. synchronizace
         db        ((91+8) AND 1fh)+(4*((85+21) AND 20h)) ; 5: ç¡ýka hor.synchr.
         db        (312-2) AND 0ffh         ; 6: poŸet vertik. linek celkem - 2
         db        b0+b4                    ; 7: doplåuj¡c¡ bity registr…
         db        7+b6                     ; 9: poŸet linek na znak - 1
         db        7                        ; 0Ah: poŸ teŸn¡ linka kurzoru
         db        7                        ; 0Bh: koncov  linka kurzoru
         db        245                      ; 10h: zaŸ tek vertik. synchronizace
         db        (245+4) AND 0fh + b7     ; 11h: d‚lka vertik. synchronizace
         db        199                      ; 12h: posledn¡ zobrazen  linka
         db        40                       ; 13h: pý¡rustek adresy v pamØti/2
         db        31                       ; 14h: podtr§en¡ MDA
         db        244                      ; 15h: zaŸ tek vertik l. zatemnØn¡
         db        (244+25) AND 0ffh        ; 16h: konec vertik ln¡ho zatemnØn¡
         db        b7+b5+b1+b0              ; 17h: ý¡dic¡ registr m¢du pamØti

; ------ 2: 4, 5: (grafika 320x200/4) standard, TRIDENT 8800
; 06Ch,027h,028h,08Eh,05Bh,083h,036h,011h, 041h, 0FCh,013h,0C7h,014h, 0F8h,005h

         db        0                        ; 3C0h/13h: posun bod… PANNING
         db        b3+b0                    ; 3C4h/01h: m¢t taktov n¡
         db        0*b2                     ; 3C2h: frekvence hodin
         db        95                       ; 0: poŸet horiz. pozic celkem - 5
         db        39                       ; 1: poŸet zobrazenìch znak… - 1
         db        61                       ; 2: poŸ tek horizont l. zatemnØn¡
         db        ((61+19) AND 1fh)+b7     ; 3: konec horizont ln¡ho zatemnØn¡
         db        65                       ; 4: poŸ tek horiz. synchronizace
         db        ((65+7) AND 1fh)+(4*((61+19) AND 20h)) ; 5: konec hor.synchr.
         db        (312-2) AND 0ffh         ; 6: poŸet vertik. linek celkem - 2
         db        b0+b4                    ; 7: doplåuj¡c¡ bity registr…
         db        1+b6                     ; 9: poŸet linek na znak - 1
         db        1                        ; 0Ah: poŸ teŸn¡ linka kurzoru
         db        0                        ; 0Bh: koncov  linka kurzoru
         db        245                      ; 10h: zaŸ tek vertik. synchronizace
         db        (245+4) AND 0fh + b7     ; 11h: d‚lka vertik. synchronizace
         db        199                      ; 12h: posledn¡ zobrazen  linka
         db        20                       ; 13h: pý¡rustek adresy v pamØti/2
         db        0                        ; 14h: podtr§en¡ MDA
         db        244                      ; 15h: zaŸ tek vertik l. zatemnØn¡
         db        (244+25) AND 0ffh        ; 16h: konec vertik ln¡ho zatemnØn¡
         db        b7+b5+b1                 ; 17h: ý¡dic¡ registr m¢du pamØti

; ------ 3: 6 (graf 640x200/2) standard, TRIDENT 8800, Western
; 06Ch,04Fh,050h,08Eh,05Bh,083h,036h,011h, 041h, 0FBh,013h,0C7h,028h, 0F8h,005h

         db        0                        ; 3C0h/13h: posun bod… PANNING
         db        b3+b0                    ; 3C4h/01h: m¢t taktov n¡
         db        1*b2                     ; 3C2h: frekvence hodin
         db        107                      ; 0: poŸet horiz. pozic celkem - 5
         db        79                       ; 1: poŸet zobrazenìch znak… - 1
         db        85                       ; 2: poŸ tek horiz. zatemnØn¡
         db        ((85+21) AND 1fh)+b7     ; 3: ç¡ýka horiz. zatemnØn¡
         db        90                       ; 4: poŸ tek horiz. synchronizace
         db        ((90+8) AND 1fh)+(4*((85+21) AND 20h)) ; 5: ç¡ýka hor.synchr.
         db        (312-2) AND 0ffh         ; 6: poŸet vertik. linek celkem - 2
         db        b0+b4                    ; 7: doplåuj¡c¡ bity registr…
         db        1+b6                     ; 9: poŸet linek na znak - 1
         db        1                        ; 0Ah: poŸ teŸn¡ linka kurzoru
         db        0                        ; 0Bh: koncov  linka kurzoru
         db        245                      ; 10h: zaŸ tek vertik. synchronizace
         db        (245+4) AND 0fh + b7     ; 11h: d‚lka vertik. synchronizace
         db        199                      ; 12h: posledn¡ zobrazen  linka
         db        40                       ; 13h: pý¡rustek adresy v pamØti/2
         db        0                        ; 14h: podtr§en¡ MDA
         db        244                      ; 15h: zaŸ tek vertik l. zatemnØn¡
         db        (244+25) AND 0ffh        ; 16h: konec vertik ln¡ho zatemnØn¡
         db        b7+b6+b1                 ; 17h: ý¡dic¡ registr m¢du pamØti

; ------ 4: 7 (text 80x25/mono) standard, TRIDENT 8800, Western
; 06Ch,04Fh,050h,08Eh,05Bh,083h,036h,011h, 047h, 0FBh,013h,0C7h,028h, 0F8h,005h

         db        0                        ; 3C0h/13h: posun bod… PANNING
         db        b3+b0                    ; 3C4h/01h: m¢t taktov n¡
         db        1*b2                     ; 3C2h: frekvence hodin
         db        107                      ; 0: poŸet horiz. pozic celkem - 5
         db        79                       ; 1: poŸet zobrazenìch znak… - 1
         db        85                       ; 2: poŸ tek horiz. zatemnØn¡
         db        ((85+21) AND 1fh)+b7     ; 3: ç¡ýka horiz. zatemnØn¡
         db        91                       ; 4: poŸ tek horiz. synchronizace
         db        ((91+8) AND 1fh)+(4*((85+21) AND 20h)) ; 5: ç¡ýka hor.synchr.
         db        (312-2) AND 0ffh         ; 6: poŸet vertik. linek celkem - 2
         db        b0+b4                    ; 7: doplåuj¡c¡ bity registr…
         db        7+b6                     ; 9: poŸet linek na znak - 1
         db        7                        ; 0Ah: poŸ teŸn¡ linka kurzoru
         db        7                        ; 0Bh: koncov  linka kurzoru
         db        245                      ; 10h: zaŸ tek vertik. synchronizace
         db        (245+4) AND 0fh + b7     ; 11h: d‚lka vertik. synchronizace
         db        199                      ; 12h: posledn¡ zobrazen  linka
         db        40                       ; 13h: pý¡rustek adresy v pamØti/2
         db        7                        ; 14h: podtr§en¡ MDA
         db        244                      ; 15h: zaŸ tek vertik l. zatemnØn¡
         db        (244+25) AND 0ffh        ; 16h: konec vertik ln¡ho zatemnØn¡
         db        b7+b5+b1+b0              ; 17h: ý¡dic¡ registr m¢du pamØti

; ------ 5: 0dh (graf 320x200/16) standard,TRIDENT 8800, Western
; 06Ch,027h,028h,08Eh,05Bh,083h,036h,011h, 040h, 0FCh,013h,0C7h,014h, 0F8h,005h

         db        0                        ; 3C0h/13h: posun bod… PANNING
         db        b3+b0                    ; 3C4h/01h: m¢t taktov n¡
         db        0*b2                     ; 3C2h: frekvence hodin
         db        95                       ; 0: poŸet horiz. pozic celkem - 5
         db        39                       ; 1: poŸet zobrazenìch znak… - 1
         db        61                       ; 2: poŸ tek horizont l. zatemnØn¡
         db        ((61+19) AND 1fh)+b7     ; 3: konec horizont ln¡ho zatemnØn¡
         db        65                       ; 4: poŸ tek horiz. synchronizace
         db        ((65+7) AND 1fh)+(4*((61+19) AND 20h)) ; 5: konec hor.synchr.
         db        (312-2) AND 0ffh         ; 6: poŸet vertik. linek celkem - 2
         db        b0+b4                    ; 7: doplåuj¡c¡ bity registr…
         db        0+b6                     ; 9: poŸet linek na znak - 1
         db        1                        ; 0Ah: poŸ teŸn¡ linka kurzoru
         db        0                        ; 0Bh: koncov  linka kurzoru
         db        245                      ; 10h: zaŸ tek vertik. synchronizace
         db        (245+4) AND 0fh + b7     ; 11h: d‚lka vertik. synchronizace
         db        199                      ; 12h: posledn¡ zobrazen  linka
         db        20                       ; 13h: pý¡rustek adresy v pamØti/2
         db        0                        ; 14h: podtr§en¡ MDA
         db        244                      ; 15h: zaŸ tek vertik l. zatemnØn¡
         db        (244+25) AND 0ffh        ; 16h: konec vertik ln¡ho zatemnØn¡
         db        b7+b6+b5+b1+b0           ; 17h: ý¡dic¡ registr m¢du pamØti

; ------ 6: 0eh (graf 640x200/16) standard,TRIDENT 8800, Western
; 06Ch,04Fh,050h,08Eh,05Bh,083h,036h,011h, 040h, 0FBh,013h,0C7h,028h, 0F8h,005h

         db        0                        ; 3C0h/13h: posun bod… PANNING
         db        b3+b0                    ; 3C4h/01h: m¢t taktov n¡
         db        1*b2                     ; 3C2h: frekvence hodin
         db        107                      ; 0: poŸet horiz. pozic celkem - 5
         db        79                       ; 1: poŸet zobrazenìch znak… - 1
         db        85                       ; 2: poŸ tek horiz. zatemnØn¡
         db        ((85+21) AND 1fh)+b7     ; 3: ç¡ýka horiz. zatemnØn¡
         db        90                       ; 4: poŸ tek horiz. synchronizace
         db        ((90+8) AND 1fh)+(4*((85+21) AND 20h)) ; 5: ç¡ýka hor.synchr.
         db        (312-2) AND 0ffh         ; 6: poŸet vertik. linek celkem - 2
         db        b0+b4                    ; 7: doplåuj¡c¡ bity registr…
         db        0+b6                     ; 9: poŸet linek na znak - 1
         db        1                        ; 0Ah: poŸ teŸn¡ linka kurzoru
         db        0                        ; 0Bh: koncov  linka kurzoru
         db        245                      ; 10h: zaŸ tek vertik. synchronizace
         db        (245+4) AND 0fh + b7     ; 11h: d‚lka vertik. synchronizace
         db        199                      ; 12h: posledn¡ zobrazen  linka
         db        40                       ; 13h: pý¡rustek adresy v pamØti/2
         db        0                        ; 14h: podtr§en¡ MDA
         db        244                      ; 15h: zaŸ tek vertik l. zatemnØn¡
         db        (244+25) AND 0ffh        ; 16h: konec vertik ln¡ho zatemnØn¡
         db        b7+b5+b6+b1+b0           ; 17h: ý¡dic¡ registr m¢du pamØti

; ------ 7: 0fh,10h (graf 640x350/mono a 16) standard,TRIDENT 8800
; 06Ch,04Fh,050h,08Eh,05Bh,083h,036h,011h, 040h, 0F1h,019h,0AEh,050h, 0EBh,0FBh

         db        0                        ; 3C0h/13h: posun bod… PANNING
         db        b3+b0                    ; 3C4h/01h: m¢t taktov n¡
         db        1*b2                     ; 3C2h: frekvence hodin
         db        107                      ; 0: poŸet horiz. pozic celkem - 5
         db        79                       ; 1: poŸet zobrazenìch znak… - 1
         db        85                       ; 2: poŸ tek horiz. zatemnØn¡
         db        ((85+21) AND 1fh)+b7     ; 3: ç¡ýka horiz. zatemnØn¡
         db        90                       ; 4: poŸ tek horiz. synchronizace
         db        ((90+8) AND 1fh)+(4*((85+21) AND 20h)) ; 5: ç¡ýka hor.synchr.
         db        (312-2) AND 0ffh         ; 6: poŸet vertik. linek celkem - 2
         db        b0+b4                    ; 7: doplåuj¡c¡ bity registr…
         db        0+b6                     ; 9: poŸet linek na znak - 1
         db        1                        ; 0Ah: poŸ teŸn¡ linka kurzoru
         db        0                        ; 0Bh: koncov  linka kurzoru
         db        235                      ; 10h: zaŸ tek vertik. synchronizace
         db        (235+4) AND 0fh + b7     ; 11h: d‚lka vertik. synchronizace
         db        174                      ; 12h: posledn¡ zobrazen  linka
         db        80                       ; 13h: pý¡rustek adresy v pamØti/2
         db        0                        ; 14h: podtr§en¡ MDA
         db        244                      ; 15h: zaŸ tek vertik l. zatemnØn¡
         db        (244+25) AND 0ffh        ; 16h: konec vertik ln¡ho zatemnØn¡
         db        b7+b5+b6+b1+b0           ; 17h: ý¡dic¡ registr m¢du pamØti

; ------ 8: 11h, 12h (graf 640x480/mono a 16) standard,TRIDENT 8800
; 06Ch,04Fh,050h,08Eh,05Bh,083h,036h,01Dh, 040h, 00Fh,017h,0EFh,050h, 00Ah,019h

         db        0                        ; 3C0h/13h: posun bod… PANNING
         db        b3+b0                    ; 3C4h/01h: m¢t taktov n¡
         db        1*b2                     ; 3C2h: frekvence hodin
         db        107                      ; 0: poŸet horiz. pozic celkem - 5
         db        79                       ; 1: poŸet zobrazenìch znak… - 1
         db        85                       ; 2: poŸ tek horiz. zatemnØn¡
         db        ((85+21) AND 1fh)+b7     ; 3: ç¡ýka horiz. zatemnØn¡
         db        90                       ; 4: poŸ tek horiz. synchronizace
         db        ((90+8) AND 1fh)+(4*((85+21) AND 20h)) ; 5: ç¡ýka hor.synchr.
         db        (312-2) AND 0ffh         ; 6: poŸet vertik. linek celkem - 2
         db        b0+b2+b4                 ; 7: doplåuj¡c¡ bity registr…
         db        0+b6                     ; 9: poŸet linek na znak - 1
         db        1                        ; 0Ah: poŸ teŸn¡ linka kurzoru
         db        0                        ; 0Bh: koncov  linka kurzoru
         db        264 AND 0ffh             ; 10h: zaŸ tek vertik. synchronizace
         db        (264+4) AND 0fh + b7     ; 11h: d‚lka vertik. synchronizace
         db        239                      ; 12h: posledn¡ zobrazen  linka
         db        80                       ; 13h: pý¡rustek adresy v pamØti/2
         db        0                        ; 14h: podtr§en¡ MDA
         db        244                      ; 15h: zaŸ tek vertik l. zatemnØn¡
         db        (244+25) AND 0ffh        ; 16h: konec vertik ln¡ho zatemnØn¡
         db        b7+b5+b6+b1+b0           ; 17h: ý¡dic¡ registr m¢du pamØti

; ------ 9: 13h (graf 320x200/256) standard
; 06Ch,04Fh,050h,08Eh,05Bh,083h,036h,011h, 040h, 0FBh,093h,0C7h,028h, 0F8h,005h

         db        0                        ; 3C0h/13h: posun bod… PANNING
         db        b3+b0                    ; 3C4h/01h: m¢t taktov n¡
         db        1*b2                     ; 3C2h: frekvence hodin
         db        107                      ; 0: poŸet horiz. pozic celkem - 5
         db        79                       ; 1: poŸet zobrazenìch znak… - 1
         db        85                       ; 2: poŸ tek horiz. zatemnØn¡
         db        ((85+21) AND 1fh)+b7     ; 3: ç¡ýka horiz. zatemnØn¡
         db        91                       ; 4: poŸ tek horiz. synchronizace
         db        ((91+8) AND 1fh)+(4*((85+21) AND 20h)) ; 5: ç¡ýka hor.synchr.
         db        (312-2) AND 0ffh         ; 6: poŸet vertik. linek celkem - 2
         db        b0+b4                    ; 7: doplåuj¡c¡ bity registr…
         db        0+b6                     ; 9: poŸet linek na znak - 1
         db        1                        ; 0Ah: poŸ teŸn¡ linka kurzoru
         db        0                        ; 0Bh: koncov  linka kurzoru
         db        244                      ; 10h: zaŸ tek vertik. synchronizace
         db        (244+4) AND 0fh + b7     ; 11h: d‚lka vertik. synchronizace
         db        199                      ; 12h: posledn¡ zobrazen  linka
         db        40                       ; 13h: pý¡rustek adresy v pamØti/2
         db        b6                       ; 14h: podtr§en¡ MDA
         db        244                      ; 15h: zaŸ tek vertik l. zatemnØn¡
         db        (244+25) AND 0ffh        ; 16h: konec vertik ln¡ho zatemnØn¡
         db        b7+b5+b1+b0              ; 17h: ý¡dic¡ registr m¢du pamØti

; -----------------------------------------------------------------------------
;        TRIDENT 8900, 9000
; -----------------------------------------------------------------------------
;þ
; ------ 10: 0, 1 (text 40x25/16) TRIDENT 8900, TRIDENT 9000
; 034h,027h,028h,095h,02Fh,0B3h,036h,011h, 047h, 0FBh,005h,0C7h,014h, 0DAh,0E6h

         db        0                        ; 3C0h/13h: posun bod… PANNING
         db        b3+b0                    ; 3C4h/01h: m¢t taktov n¡
         db        1*b2                     ; 3C2h: frekvence hodin
         db        51                       ; 0: poŸet horiz. pozic celkem - 5
         db        39                       ; 1: poŸet zobrazenìch znak… - 1
         db        40                       ; 2: poŸ tek horizont l. zatemnØn¡
         db        ((40+11) AND 1fh)+b7     ; 3: konec horizont ln¡ho zatemnØn¡
         db        47                       ; 4: poŸ tek horiz. synchronizace
         db        ((47+4) AND 1fh)+(4*((40+11) AND 20h)) ; 5: konec hor.synchr.
         db        (312-2) AND 0ffh         ; 6: poŸet vertik. linek celkem - 2
         db        b0+b4                    ; 7: doplåuj¡c¡ bity registr…
         db        7+b6                     ; 9: poŸet linek na znak - 1
         db        7                        ; 0Ah: poŸ teŸn¡ linka kurzoru
         db        7                        ; 0Bh: koncov  linka kurzoru
         db        245                      ; 10h: zaŸ tek vertik. synchronizace
         db        (245+4) AND 0fh + b7     ; 11h: d‚lka vertik. synchronizace
         db        199                      ; 12h: posledn¡ zobrazen  linka
         db        20                       ; 13h: pý¡rustek adresy v pamØti/2
         db        31                       ; 14h: podtr§en¡ MDA
         db        244                      ; 15h: zaŸ tek vertik l. zatemnØn¡
         db        (244+25) AND 0ffh        ; 16h: konec vertik ln¡ho zatemnØn¡
         db        b7+b5+b1+b0              ; 17h: ý¡dic¡ registr m¢du pamØti

; ------ 11: 4, 5: (grafika 320x200/4) TRIDENT 8900, TRIDENT 9000
; 034h,027h,028h,095h,02Fh,093h,036h,011h, 041h, 0FBh,005h,0C7h,014h, 0DAh,0E6h

         db        0                        ; 3C0h/13h: posun bod… PANNING
         db        b3+b0                    ; 3C4h/01h: m¢t taktov n¡
         db        1*b2                     ; 3C2h: frekvence hodin
         db        51                       ; 0: poŸet horiz. pozic celkem - 5
         db        39                       ; 1: poŸet zobrazenìch znak… - 1
         db        40                       ; 2: poŸ tek horizont l. zatemnØn¡
         db        ((40+11) AND 1fh)+b7     ; 3: konec horizont ln¡ho zatemnØn¡
         db        46                       ; 4: poŸ tek horiz. synchronizace
         db        ((46+4) AND 1fh)+(4*((40+11) AND 20h)) ; 5: konec hor.synchr.
         db        (312-2) AND 0ffh         ; 6: poŸet vertik. linek celkem - 2
         db        b0+b4                    ; 7: doplåuj¡c¡ bity registr…
         db        1+b6                     ; 9: poŸet linek na znak - 1
         db        1                        ; 0Ah: poŸ teŸn¡ linka kurzoru
         db        0                        ; 0Bh: koncov  linka kurzoru
         db        245                      ; 10h: zaŸ tek vertik. synchronizace
         db        (245+4) AND 0fh + b7     ; 11h: d‚lka vertik. synchronizace
         db        199                      ; 12h: posledn¡ zobrazen  linka
         db        20                       ; 13h: pý¡rustek adresy v pamØti/2
         db        0                        ; 14h: podtr§en¡ MDA
         db        244                      ; 15h: zaŸ tek vertik l. zatemnØn¡
         db        (244+25) AND 0ffh        ; 16h: konec vertik ln¡ho zatemnØn¡
         db        b7+b5+b1                 ; 17h: ý¡dic¡ registr m¢du pamØti

; ------ 12: 0dh (graf 320x200/16) TRIDENT 8900, TRIDENT 9000
; 034h,027h,028h,095h,02Fh,093h,036h,011h, 040h, 0FBh,005h,0C7h,014h, 0DAh,0E6h

         db        0                        ; 3C0h/13h: posun bod… PANNING
         db        b3+b0                    ; 3C4h/01h: m¢t taktov n¡
         db        1*b2                     ; 3C2h: frekvence hodin
         db        51                       ; 0: poŸet horiz. pozic celkem - 5
         db        39                       ; 1: poŸet zobrazenìch znak… - 1
         db        40                       ; 2: poŸ tek horizont l. zatemnØn¡
         db        ((40+11) AND 1fh)+b7     ; 3: konec horizont ln¡ho zatemnØn¡
         db        46                       ; 4: poŸ tek horiz. synchronizace
         db        ((46+4) AND 1fh)+(4*((40+11) AND 20h)) ; 5: konec hor.synchr.
         db        (312-2) AND 0ffh         ; 6: poŸet vertik. linek celkem - 2
         db        b0+b4                    ; 7: doplåuj¡c¡ bity registr…
         db        0+b6                     ; 9: poŸet linek na znak - 1
         db        1                        ; 0Ah: poŸ teŸn¡ linka kurzoru
         db        0                        ; 0Bh: koncov  linka kurzoru
         db        245                      ; 10h: zaŸ tek vertik. synchronizace
         db        (245+4) AND 0fh + b7     ; 11h: d‚lka vertik. synchronizace
         db        199                      ; 12h: posledn¡ zobrazen  linka
         db        20                       ; 13h: pý¡rustek adresy v pamØti/2
         db        0                        ; 14h: podtr§en¡ MDA
         db        244                      ; 15h: zaŸ tek vertik l. zatemnØn¡
         db        (244+25) AND 0ffh        ; 16h: konec vertik ln¡ho zatemnØn¡
         db        b7+b6+b5+b1+b0           ; 17h: ý¡dic¡ registr m¢du pamØti

; -----------------------------------------------------------------------------
;        OAK Technology
; -----------------------------------------------------------------------------
;þ
; ------ 13: 0, 1 (text 40x25/16) OAK Technology
; 034h,027h,028h,095h,02Fh,0B3h,036h,011h, 047h, 0FBh,005h,0C7h,014h, 0DAh,0E6h

         db        0                        ; 3C0h/13h: posun bod… PANNING
         db        b3+b0                    ; 3C4h/01h: m¢t taktov n¡
         db        0*b2                     ; 3C2h: frekvence hodin
         db        51                       ; 0: poŸet horiz. pozic celkem - 5
         db        39                       ; 1: poŸet zobrazenìch znak… - 1
         db        40                       ; 2: poŸ tek horizont l. zatemnØn¡
         db        ((40+11) AND 1fh)+b7     ; 3: konec horizont ln¡ho zatemnØn¡
         db        47                       ; 4: poŸ tek horiz. synchronizace
         db        ((47+4) AND 1fh)+(4*((40+11) AND 20h)) ; 5: konec hor.synchr.
         db        (312-2) AND 0ffh         ; 6: poŸet vertik. linek celkem - 2
         db        b0+b4                    ; 7: doplåuj¡c¡ bity registr…
         db        7+b6                     ; 9: poŸet linek na znak - 1
         db        7                        ; 0Ah: poŸ teŸn¡ linka kurzoru
         db        7                        ; 0Bh: koncov  linka kurzoru
         db        245                      ; 10h: zaŸ tek vertik. synchronizace
         db        (245+4) AND 0fh + b7     ; 11h: d‚lka vertik. synchronizace
         db        199                      ; 12h: posledn¡ zobrazen  linka
         db        20                       ; 13h: pý¡rustek adresy v pamØti/2
         db        31                       ; 14h: podtr§en¡ MDA
         db        244                      ; 15h: zaŸ tek vertik l. zatemnØn¡
         db        (244+25) AND 0ffh        ; 16h: konec vertik ln¡ho zatemnØn¡
         db        b7+b5+b1+b0              ; 17h: ý¡dic¡ registr m¢du pamØti

; ------ 14: 4, 5: (grafika 320x200/16) OAK Technology
; 034h,027h,028h,095h,02Fh,093h,036h,011h, 041h, 0FBh,005h,0C7h,014h, 0DAh,0E6h

         db        0                        ; 3C0h/13h: posun bod… PANNING
         db        b3+b0                    ; 3C4h/01h: m¢t taktov n¡
         db        0*b2                     ; 3C2h: frekvence hodin
         db        51                       ; 0: poŸet horiz. pozic celkem - 5
         db        39                       ; 1: poŸet zobrazenìch znak… - 1
         db        40                       ; 2: poŸ tek horizont l. zatemnØn¡
         db        ((40+11) AND 1fh)+b7     ; 3: konec horizont ln¡ho zatemnØn¡
         db        46                       ; 4: poŸ tek horiz. synchronizace
         db        ((46+4) AND 1fh)+(4*((40+11) AND 20h)) ; 5: konec hor.synchr.
         db        (312-2) AND 0ffh         ; 6: poŸet vertik. linek celkem - 2
         db        b0+b4                    ; 7: doplåuj¡c¡ bity registr…
         db        1+b6                     ; 9: poŸet linek na znak - 1
         db        1                        ; 0Ah: poŸ teŸn¡ linka kurzoru
         db        0                        ; 0Bh: koncov  linka kurzoru
         db        245                      ; 10h: zaŸ tek vertik. synchronizace
         db        (245+4) AND 0fh + b7     ; 11h: d‚lka vertik. synchronizace
         db        199                      ; 12h: posledn¡ zobrazen  linka
         db        20                       ; 13h: pý¡rustek adresy v pamØti/2
         db        0                        ; 14h: podtr§en¡ MDA
         db        244                      ; 15h: zaŸ tek vertik l. zatemnØn¡
         db        (244+25) AND 0ffh        ; 16h: konec vertik ln¡ho zatemnØn¡
         db        b7+b5+b1                 ; 17h: ý¡dic¡ registr m¢du pamØti

; ------ 15: 0dh (graf 320x200/16) OAK Technology
; 034h,027h,028h,095h,02Fh,093h,036h,011h, 040h, 0FBh,005h,0C7h,014h, 0DAh,0E6h

         db        0                        ; 3C0h/13h: posun bod… PANNING
         db        b3+b0                    ; 3C4h/01h: m¢t taktov n¡
         db        0*b2                     ; 3C2h: frekvence hodin
         db        51                       ; 0: poŸet horiz. pozic celkem - 5
         db        39                       ; 1: poŸet zobrazenìch znak… - 1
         db        40                       ; 2: poŸ tek horizont l. zatemnØn¡
         db        ((40+11) AND 1fh)+b7     ; 3: konec horizont ln¡ho zatemnØn¡
         db        46                       ; 4: poŸ tek horiz. synchronizace
         db        ((46+4) AND 1fh)+(4*((40+11) AND 20h)) ; 5: konec hor.synchr.
         db        (312-2) AND 0ffh         ; 6: poŸet vertik. linek celkem - 2
         db        b0+b4                    ; 7: doplåuj¡c¡ bity registr…
         db        0+b6                     ; 9: poŸet linek na znak - 1
         db        1                        ; 0Ah: poŸ teŸn¡ linka kurzoru
         db        0                        ; 0Bh: koncov  linka kurzoru
         db        245                      ; 10h: zaŸ tek vertik. synchronizace
         db        (245+4) AND 0fh + b7     ; 11h: d‚lka vertik. synchronizace
         db        199                      ; 12h: posledn¡ zobrazen  linka
         db        20                       ; 13h: pý¡rustek adresy v pamØti/2
         db        0                        ; 14h: podtr§en¡ MDA
         db        244                      ; 15h: zaŸ tek vertik l. zatemnØn¡
         db        (244+25) AND 0ffh        ; 16h: konec vertik ln¡ho zatemnØn¡
         db        b7+b6+b5+b1+b0           ; 17h: ý¡dic¡ registr m¢du pamØti

; ------ 16: 0fh,10h (graf 640x350/mono a 16) standard,TRIDENT 8800, Western
; 06Ch,04Fh,050h,08Eh,05Bh,083h,036h,011h, 040h, 0F1h,019h,0AEh,028h, 0EBh,0FBh

         db        0                        ; 3C0h/13h: posun bod… PANNING
         db        b3+b0                    ; 3C4h/01h: m¢t taktov n¡
         db        1*b2                     ; 3C2h: frekvence hodin
         db        107                      ; 0: poŸet horiz. pozic celkem - 5
         db        79                       ; 1: poŸet zobrazenìch znak… - 1
         db        85                       ; 2: poŸ tek horiz. zatemnØn¡
         db        ((85+21) AND 1fh)+b7     ; 3: ç¡ýka horiz. zatemnØn¡
         db        90                       ; 4: poŸ tek horiz. synchronizace
         db        ((90+8) AND 1fh)+(4*((85+21) AND 20h)) ; 5: ç¡ýka hor.synchr.
         db        (312-2) AND 0ffh         ; 6: poŸet vertik. linek celkem - 2
         db        b0+b4                    ; 7: doplåuj¡c¡ bity registr…
         db        0+b6                     ; 9: poŸet linek na znak - 1
         db        1                        ; 0Ah: poŸ teŸn¡ linka kurzoru
         db        0                        ; 0Bh: koncov  linka kurzoru
         db        235                      ; 10h: zaŸ tek vertik. synchronizace
         db        (235+4) AND 0fh + b7     ; 11h: d‚lka vertik. synchronizace
         db        174                      ; 12h: posledn¡ zobrazen  linka
         db        40                       ; 13h: pý¡rustek adresy v pamØti/2
         db        0                        ; 14h: podtr§en¡ MDA
         db        244                      ; 15h: zaŸ tek vertik l. zatemnØn¡
         db        (244+25) AND 0ffh        ; 16h: konec vertik ln¡ho zatemnØn¡
         db        b7+b5+b6+b1+b0           ; 17h: ý¡dic¡ registr m¢du pamØti

; ------ 17: 11h, 12h (graf 640x480/mono a 16) standard,TRIDENT 8800, Western
; 06Ch,04Fh,050h,08Eh,05Bh,083h,036h,01Dh, 040h, 00Fh,017h,0EFh,028h, 00Ah,019h

         db        0                        ; 3C0h/13h: posun bod… PANNING
         db        b3+b0                    ; 3C4h/01h: m¢t taktov n¡
         db        1*b2                     ; 3C2h: frekvence hodin
         db        107                      ; 0: poŸet horiz. pozic celkem - 5
         db        79                       ; 1: poŸet zobrazenìch znak… - 1
         db        85                       ; 2: poŸ tek horiz. zatemnØn¡
         db        ((85+21) AND 1fh)+b7     ; 3: ç¡ýka horiz. zatemnØn¡
         db        90                       ; 4: poŸ tek horiz. synchronizace
         db        ((90+8) AND 1fh)+(4*((85+21) AND 20h)) ; 5: ç¡ýka hor.synchr.
         db        (312-2) AND 0ffh         ; 6: poŸet vertik. linek celkem - 2
         db        b0+b2+b4                 ; 7: doplåuj¡c¡ bity registr…
         db        0+b6                     ; 9: poŸet linek na znak - 1
         db        1                        ; 0Ah: poŸ teŸn¡ linka kurzoru
         db        0                        ; 0Bh: koncov  linka kurzoru
         db        264 AND 0ffh             ; 10h: zaŸ tek vertik. synchronizace
         db        (264+4) AND 0fh + b7     ; 11h: d‚lka vertik. synchronizace
         db        239                      ; 12h: posledn¡ zobrazen  linka
         db        40                       ; 13h: pý¡rustek adresy v pamØti/2
         db        0                        ; 14h: podtr§en¡ MDA
         db        244                      ; 15h: zaŸ tek vertik l. zatemnØn¡
         db        (244+25) AND 0ffh        ; 16h: konec vertik ln¡ho zatemnØn¡
         db        b7+b5+b6+b1+b0           ; 17h: ý¡dic¡ registr m¢du pamØti

; ------ 18: 13h (graf 320x200/256) TRIDENT
; 06Ch,04Fh,050h,08Eh,05Bh,083h,036h,011h, 040h, 0FBh,093h,0C7h,028h, 0F8h,005h

         db        0                        ; 3C0h/13h: posun bod… PANNING
         db        b0                       ; 3C4h/01h: m¢t taktov n¡
         db        1*b2                     ; 3C2h: frekvence hodin
         db        107                      ; 0: poŸet horiz. pozic celkem - 5
         db        79                       ; 1: poŸet zobrazenìch znak… - 1
         db        85                       ; 2: poŸ tek horiz. zatemnØn¡
         db        ((85+21) AND 1fh)+b7     ; 3: ç¡ýka horiz. zatemnØn¡
         db        91                       ; 4: poŸ tek horiz. synchronizace
         db        ((91+8) AND 1fh)+(4*((85+21) AND 20h)) ; 5: ç¡ýka hor.synchr.
         db        (312-2) AND 0ffh         ; 6: poŸet vertik. linek celkem - 2
         db        b0+b4                    ; 7: doplåuj¡c¡ bity registr…
         db        0+b6                     ; 9: poŸet linek na znak - 1
         db        1                        ; 0Ah: poŸ teŸn¡ linka kurzoru
         db        0                        ; 0Bh: koncov  linka kurzoru
         db        244                      ; 10h: zaŸ tek vertik. synchronizace
         db        (244+4) AND 0fh + b7     ; 11h: d‚lka vertik. synchronizace
         db        199                      ; 12h: posledn¡ zobrazen  linka
         db        40                       ; 13h: pý¡rustek adresy v pamØti/2
         db        b6                       ; 14h: podtr§en¡ MDA
         db        244                      ; 15h: zaŸ tek vertik l. zatemnØn¡
         db        (244+25) AND 0ffh        ; 16h: konec vertik ln¡ho zatemnØn¡
         db        b7+b5+b1+b0              ; 17h: ý¡dic¡ registr m¢du pamØti

Command  db        128 dup(?)               ; buffer pý¡kazov‚ho ý dku

; ------ nastaven¡ registr… posuvu obrazovky

ShiftCnf db        MAXNTAB dup(?,?,?,?,?)

; Struktura: (1) poŸ tek horiz. synchronizace (reg. 4 portu 3x4h)
;            (1) konec horiz. synchronizace (reg. 5 portu 3x4h)
;            (1) poŸ tek vertik. synchronizace (reg. 10h portu 3x4h)
;            (1) konec vertik. synchronizace (reg. 11h portu 3x4h)
;            (1) doplåuj¡c¡ bity (reg. 7 portu 3x4h)

Code     ENDS
         END       Start

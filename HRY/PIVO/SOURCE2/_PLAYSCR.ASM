
; Nelze urychlit p©ehr v n¡ ani nelze p©eru¨it kl vesou ESC.

IDENT1   EQU       3a51h                    ; identifik tor 1 (BX)
IDENT2   EQU       9e46h                    ; identifik tor 2 (CX)
IDENT3   EQU       0a6e4h                   ; identifik tor 3 (DX)
IDENT4   EQU       1a57h                    ; identifik tor 4 (BX v˜stup)

BufSize  equ       800h                     ; velikost diskov‚ho bufferu
                                            ; (mus¡ b˜t alespo¤ 1+18+3*256=786
                                            ;  pro palety)

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                      Sn¡ma‡ obrazovky - rezidentn¡ ‡ st
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

Start:   jmp       Instal                   ; instalace programu

Identif  db        'GD'                     ; kontroln¡ identifik tor

; *****************************************************************************
;
;                        Data sn¡ma‡e obrazovky
;
; *****************************************************************************

SParam   db        21h                      ; parametry sn¡ma‡e obrazovky
                                            ;   bit 0: 0=po‘adavek obsluhy
                                            ;   bit 1: 1=prob¡h  obsluha
                                            ; parametry programu GDEMO
                                            ;   bit 2: 1=po‘adavek instalace
                                            ;   bit 3: 1=po‘adavek odinstalov n¡
                                            ;   bit 4: 1=je prvn¡ instalace
                                            ;   bit 5: 1=povoleno sn¡m n¡
                                            ;   bit 6: 1=je re‘im demonstrace
                                            ;   bit 7: 1=aktivn¡ ‡asov‚ sn¡m n¡

SParam2  db        40h+20h+8+2              ; parametry 2
                                            ;   bit 0: 1=palety CGA v‘dy
                                            ;   bit 1: 1=palety CGA automaticky
                                            ;   bit 2: 1=palety EGA v‘dy
                                            ;   bit 3: 1=palety EGA automaticky
                                            ;   bit 4: 1=palety VGA v‘dy
                                            ;   bit 5: 1=palety VGA automaticky
                                            ;   bit 6: 1=test portem 60h
                                            ;   bit 7: 1=testovac¡ v˜pis

SParam3  db        0                        ; parametry 3
                                            ;   bit 0: 1=videom¢d p©ednastaven
                                            ;   bit 1: 1=netestovat p©¡znak DOS

Old08    dd        0                        ; p–vodn¡ adresa obsluhy INT 08h
Old09    dd        0                        ; p–vodn¡ adresa obsluhy INT 09h
Old10    dd        0                        ; p–vodn¡ adresa obsluhy INT 10h
Old28    dd        0                        ; p–vodn¡ adresa obsluhy INT 28h
OldInt   dd        0                        ; p–vodn¡ adresa obsluhy INT n
NumInt   db        0B9h                     ; voliteln‚ p©eru¨en¡ INT n

SDelay   dw        0                        ; konstanta prodlevy (0=jednor zov‚)
SCitac   dw        0                        ; ‡¡ta‡ prodlevy ukl d n¡

Aktiv21  dd        0                        ; adresa p©¡znaku aktivity DOS

Card     db        2                        ; typ videokarty
                                            ;   1=Hercules
                                            ;   2=CGA
                                            ;   3=EGA
                                            ;   4=VGA

Old23    dd        0                        ; p–vodn¡ adresa INT 23h (p©echodnˆ)
Old24    dd        0                        ; p–vodn¡ adresa INT 24h (p©echodnˆ)

OldKey   db        0                        ; uschovan  kl vesa portu (0=nen¡)
CitKey   db        2*18                     ; ‡¡ta‡ pro testov n¡ portu

; -----------------------------------------------------------------------------
;        z hlav¡ souboru obr zku
; -----------------------------------------------------------------------------

Zahlavi  label     byte                   ;* z hlav¡ souboru SCREEN (d‚lka 16 B)
Ident    db        'SCR'                    ; identifikace souboru displeje
Verze    db        1                        ; verze souboru
Sirka    dw        0                        ; ¨¡©ka v˜©ezu (pozic, bod–)
Vyska    dw        0                        ; v˜¨ka v˜©ezu (linek)
Rovin    db        0                        ; po‡et barevn˜ch rovin
         db        0                        ; (rezervov no)
Pozadi   db        0                        ; barva pozad¡
Komentar db        0                        ; po‡et bajt– koment ©e + informace
Palet    dw        0                        ; po‡et bajt– za z hlav¡m
VMod     db        0                        ; videom¢d displeje
Param    db        1                        ; parametry
                                            ;  bit 0: 1=komprese
                                            ;  bit 1: 1=textov˜ videom¢d
                                            ;  bit 2: 1=paraleln¡ ulo‘en¡ barev
                                            ;  bit 3: 1=obsahuje masku
                                            ;  bit 4: 1=jsou palety CGA
                                            ;  bit 5: 1=jsou palety EGA
                                            ;  bit 6: 1=jsou palety VGA
                                            ;  bit 7:
KonHl    label     byte                     ; konec z hlav¡

; -----------------------------------------------------------------------------
;        obsluha v˜stupn¡ho souboru
; -----------------------------------------------------------------------------

NumBuff  dw        0                        ; po‡et bajt– v diskov‚m bufferu

AdrSoub  dw        0                        ; adresa ‡¡sla souboru
Soubor   db        'A:\',64+14 dup(0)       ; buffer pro adres © a soubor

Idents   dw        0                        ; identifik tor v˜stupn¡ho souboru

; -----------------------------------------------------------------------------
;        displej
; -----------------------------------------------------------------------------

SIncAdr  dw        80                       ; p©¡rustek adresy linek
SZlom    dw        -1                       ; ‡¡slo videolinky pro p©elom obrazu

; -----------------------------------------------------------------------------
;        komprese
; -----------------------------------------------------------------------------

; —sek shodn‚ho opakovan‚ho bajtu (komrese):
KompCit  dw        0                        ; ‡¡ta‡ shodn‚ho bajtu
KompChar db        0                        ; znak k opakov n¡

; —sek neshodn˜ch bajt– (nen¡ komprese):
KompBNum dw        0                        ; po‡et bajt– v kompresn¡m bufferu
KompBuff db        255 dup(0)               ; kompresn¡ buffer

; P©¡znak £seku komprese
KompPar  db        1                        ; 1=p©¡znak kompresn¡ho m¢du

; *****************************************************************************
;
;                         Obsluhy p©eru¨en¡
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        Obsluha INT 10h - test instalace
; -----------------------------------------------------------------------------

Int10    PROC      FAR

         pushf
         cmp       ah,0fh
         jne       Int101
         cmp       bx,IDENT1
         jne       Int101
         cmp       cx,IDENT2
         jne       Int101
         cmp       dx,IDENT3
         jne       Int101
         mov       bx,IDENT4                ; v˜stupn¡ identifik tor
         push      cs
         pop       es                       ; ES <- segment programu
         popf
         retf

Int101:  popf
         jmp       dword ptr cs:[Old10]     ; pokra‡ov n¡ v obsluze INT 10h

Int10    ENDP

; -----------------------------------------------------------------------------
;        Obsluha INT 08h
; -----------------------------------------------------------------------------

Int08    PROC      FAR

; ------ p–vodn¡ obsluha INT 08h

         pushf
         call      dword ptr cs:[Old08]     ; p–vodn¡ obsluha INT 08h

; ------ test, zda je tla‡¡tko PrintScreen na portu

         test      byte ptr cs:[SParam],20h ; povolena obsluha sn¡m n¡ ?
         jz        Int081                   ; nen¡ povolena obsluha sn¡m n¡
         test      byte ptr cs:[SParam2],40h ; povolen p©¡stup k portu ?
         jz        Int082                   ; nepovolen p©¡stup k portu
         cmp       byte ptr cs:[CitKey],0
         je        Int0801
         dec       byte ptr cs:[CitKey]
         jnz       Int082

Int0801: push      ax
         in        al,[60h]                 ; ‡ten¡ portu
         mov       ah,al
         xchg      al,cs:[OldKey]           ; ulo‘en¡ kl vesy
         cmp       al,ah                    ; je zmˆna ?
         je        Int0802                  ; nen¡ zmˆna
         cmp       al,0
         je        Int0802
         cmp       ah,37h
         je        Int0800
Int0802: stc                                ; p©¡znak - nen¡ obsluha
Int0800: pop       ax
         jnc       Int080                   ; m  b˜t obsluha

; ------ ‡¡t n¡ prodlevy ‡asov‚ho sn¡m n¡

Int082:  test      byte ptr cs:[SParam],80h ; je aktivn¡ ‡asov‚ sn¡m n¡ ?
         jz        Int081                   ; ‡asov‚ sn¡m n¡ nen¡ aktivn¡
         cmp       word ptr cs:[SCitac],0   ; prob¡h  ‡¡t n¡ doby ?
         je        Int081                   ; neprob¡h  ‡¡t n¡ doby
         dec       word ptr cs:[SCitac]     ; sn¡‘en¡ ‡¡ta‡e doby prodlevy
         jnz       Int081                   ; nen¡ dosa‘ena doba

; ------ po‘adavek sejmut¡ obrazovky

Int080:  and       byte ptr cs:[SParam],not 1 ; po‘adavek obsluhy sn¡m n¡
         push      ax
         push      ds
         xor       ax,ax
         mov       ds,ax
         mov       byte ptr ds:[500h],1     ; p©¡znak obsluhy PRINT SCREEN
         pop       ds
         pop       ax

; ------ obsluha sn¡m n¡ obrazovky

Int081:  call      Screen                   ; obsluha sn¡ma‡e obrazovky
         iret

Int08    ENDP

; -----------------------------------------------------------------------------
;        Obsluha INT 28h
; -----------------------------------------------------------------------------

Int28    PROC      FAR

         pushf
         call      dword ptr cs:[Old28]     ; p–vodn¡ obsluha INT 28h
         call      Screen                   ; obsluha sn¡ma‡e obrazovky
         iret

Int28    ENDP

; -----------------------------------------------------------------------------
;        Obsluha INT n
; -----------------------------------------------------------------------------

IntInt   PROC      FAR

         sti
         pushf
         call      dword ptr cs:[OldInt]    ; p–vodn¡ obsluha INT n

         pushf

; ------ test, zda je tla‡¡tko PrintScreen na portu

         test      byte ptr cs:[SParam],20h ; povolena obsluha sn¡m n¡ ?
         jz        IntInt6                  ; nen¡ povolena obsluha sn¡m n¡
         push      ax
         in        al,[60h]                 ; ‡ten¡ portu
         mov       ah,al
         xchg      al,cs:[OldKey]           ; ulo‘en¡ kl vesy
         cmp       al,ah                    ; je zmˆna ?
         je        IntInt2                  ; nen¡ zmˆna
         cmp       al,0
         je        IntInt2
         cmp       ah,37h
         je        IntInt3
         cmp       ah,37h+80h
         je        IntInt3
IntInt2: stc                                ; p©¡znak - nen¡ obsluha
IntInt3: pop       ax
         jc        IntInt6                  ; nem  b˜t obsluha

; ------ po‘adavek sejmut¡ obrazovky

IntInt4: and       byte ptr cs:[SParam],not 1 ; po‘adavek obsluhy sn¡m n¡
         push      ax
         push      ds
         xor       ax,ax
         mov       ds,ax
         mov       byte ptr ds:[500h],1     ; p©¡znak obsluhy PRINT SCREEN
         pop       ds
         pop       ax

; ------ obsluha sn¡m n¡ obrazovky

IntInt6: call      Screen                   ; obsluha sn¡ma‡e obrazovky
         popf
         ret       2

IntInt   ENDP

; -----------------------------------------------------------------------------
;        Obsluha INT 09h
; -----------------------------------------------------------------------------

Int09    PROC      FAR

; ------ £schova registr–

         push      ax
         push      bx
         push      ds
         mov       byte ptr cs:[Citkey],2*18

; ------ £schova ukl dac¡ adresy do bufferu kl vesnice

         mov       bx,40h
         mov       ds,bx                    ; DS <- 40h
         mov       bx,ds:[1ch]              ; ukl dac¡ adresa do bufferu

; ------ test, zda je povoleno sn¡m n¡

         test      byte ptr cs:[SParam],20h ; je povoleno sn¡m n¡ ?
         jz        Int095                   ; nen¡ povoleno sn¡m n¡

; ------ test, zda je kl vesa PrintScreen

         in        al,[60h]                 ; orienta‡n¡ k¢d kl vesy
         mov       cs:[OldKey],al
         cmp       al,37h                   ; je kl vesa <Print Screen> ?
         jne       Int095                   ; nen¡ <Print Screen>

; ------ ukon‡en¡ funkce ‡asov‚ho sn¡m n¡

         test      byte ptr cs:[SParam],80h ; je ‡asov‚ sn¡m n¡ ?
         jz        Int091                   ; nen¡ ‡asov‚ sn¡m n¡
         and       byte ptr cs:[SParam],not 80h ; zru¨en¡ funkce ‡as. sn¡m n¡
         or        byte ptr cs:[SParam],1   ; zru¨en¡ po‘adavku sejmut¡
         cmp       byte ptr ds:[100h],1     ; prob¡h  obsluha ?
         je        Int094                   ; prob¡h  obsluha
         mov       byte ptr ds:[100h],1     ; p©¡znak obsluhy PRINT SCREEN
         pushf
         call      dword ptr cs:[Old09]     ; p–vodn¡ obsluha INT 09h
         mov       ds:[1ch],bx              ; zru¨en¡ znaku z bufferu
         mov       byte ptr ds:[100h],0     ; zru¨en¡ p©¡znaku PRINT SCREEN
         jmp       short Int098

; ------ zah jen¡ funkce ‡asov‚ho sn¡m n¡

Int091:  mov       ax,cs:[SDelay]           ; prodleva ‡asov‚ho sn¡m n¡
         or        ax,ax                    ; je funkce ‡asov‚ho sn¡m n¡ ?
         jz        Int092                   ; nen¡ funkce ‡asov‚ho sn¡m n¡
         mov       cs:[SCitac],ax           ; inicializace ‡¡ta‡e prodlevy
         or        byte ptr cs:[SParam],80h ; p©¡znak aktivn¡ho ‡asov‚ho sn¡m n¡

; ------ p©¡znak zah jen¡ funkce sn¡m n¡ obrazovky

Int092:  and       byte ptr cs:[SParam],not 1; p©¡znak po‘adavku sejmut¡ displeje
         mov       byte ptr ds:[100h],1     ; p©¡znak obsluhy PRINT SCREEN

; ------ vol n¡ p–vodn¡ funkce INT 09h se zru¨en¡m bufferu kl vesnice

Int094:  pushf
         call      dword ptr cs:[Old09]     ; p–vodn¡ obsluha INT 09h
         mov       ds:[1ch],bx              ; zru¨en¡ znaku z bufferu
         jmp       short Int098

; ------ vol n¡ p–vodn¡ funkce INT 09h

Int095:  pushf
         call      dword ptr cs:[old09]     ; obsluha INT 09h

; ------ n vrat registr–

Int098:  pop       ds
         pop       bx
         pop       ax
         iret

Int09    ENDP

; *****************************************************************************
;
;                     Obsluha sejmut¡ obrazovky
;
; *****************************************************************************
;þ
Screen0: ret

; ------ test, zda je po‘adov na obsluha sejmut¡ obrazovky

Screen   PROC      NEAR

         test      byte ptr cs:[SParam],1+2 ; po‘adov na obsluha ?
         jnz       Screen0                  ; nepo‘adov na nebo ji‘ prob¡h 

; ------ test p©¡znaku aktivity DOS

         test      byte ptr cs:[SParam3],2  ; netestovat DOS ?
         jnz       Screen03                 ; netestovat DOS
         push      ds
         push      bx
         lds       bx,cs:[Aktiv21]          ; adresa p©¡znaku aktivity DOS
         cmp       bx,-1                    ; je adresa definov na ?
         je        Screen02                 ; nen¡ definov na
         cmp       byte ptr ds:[bx],0       ; je DOS aktivn¡ ?
Screen02:pop       bx
         pop       ds
         jne       Screen0                  ; DOS je aktivn¡

; ------ p©¡znak zah jen¡ operace

Screen03:or        byte ptr cs:[SParam],2   ; p©¡znak aktivity sn¡m n¡

; ------ instalace obsluh p©eru¨en¡ INT 23h a INT 24h

         cli
         call      SInstInt                 ; instalace obsluh INT 23h a INT 24h

; ------ £schova registr–

         sti                                ; p©eru¨en¡ povoleno
         pushf
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es

         push      cs
         pop       ds                       ; DS <- segment programu

; ------ obsluha testovac¡ho re‘imu

         test      byte ptr ds:[SParam2],80h ; je testovac¡ re‘im ?
         jz        Screen1                  ; nen¡ testovac¡ re‘im
         call      STest                    ; obsluha testovac¡ho re‘imu
         jmp       short Screen8

; ------ p©¡prava parametr– podle videom¢du

Screen1: call      SInitMod                 ; p©¡prava parametr– podle videom¢du
         jc        Screen8                  ; nepovolen˜ videom¢d

; ------ inicializace tabulky barev (do bufferu)

         call      SInitPal                 ; inicializace palet displeje

; ------ zvukov  signalizace

         call      SBeep                    ; zvukov  signalizace zah jen¡

; ------ otev©en¡ v˜stupn¡ho souboru

         call      SIniFile                 ; otev©en¡ v˜stupn¡ho souboru
         jc        Screen7                  ; chyba - soubor nevytvo©en

; ------ inicializace ukazatel– komprese

         mov       word ptr ds:[KompCit],0  ; ‡¡ta‡ komprese
         mov       word ptr ds:[KompBNum],0 ; zru¨en¡ ‡¡ta‡e bajt– v bufferu
         mov       byte ptr ds:[KompPar],1  ; nastaven¡ p©¡znaku komprese

; ------ z pis z hlav¡ do souboru

         mov       dx,offset Zahlavi        ; z hlav¡ souboru
         mov       cx,offset(KonHl-Zahlavi) ; d‚lka z hlav¡ souboru
         mov       bx,ds:[Idents]           ; identifik tor souboru
         mov       ah,40h                   ; funkce z pisu do souboru
         int       21h                      ; z pis z hlav¡ do souboru
         jc        Screen6                  ; chyba z pisu na disk

; ------ z pis palet barev do souboru

         mov       cx,ds:[Palet]            ; po‡et bajt– palet VGA
         jcxz      Screen4                  ; nejsou ‘ dn‚ palety
         mov       dx,offset Buffer         ; buffer s na‡ten˜mi paletami
         mov       bx,ds:[Idents]           ; identifik tor souboru
         mov       ah,40h                   ; funkce z pisu do souboru
         int       21h                      ; z pis palet do souboru
         jc        Screen6                  ; chyba z pisu na disk

; ------ ulo‘en¡ obsahu obrazovky na disk

Screen4: call      BP                       ; obsluha z pisu na disk
         jc        Screen6                  ; chyba z pisu na disk

; ------ vypr zdnˆn¡ buffer–

         call      FlushQ                   ; vypr zdnˆn¡ bufferu shody
         jc        Screen6                  ; chyba z pisu na disk
         call      FlushB                   ; vypr zdnˆn¡ bˆ‘n‚ho bufferu
         jc        Screen6                  ; chyba z pisu na disk
         call      WritBuff                 ; z pis bufferu na disk

; ------ uzav©en¡ souboru

Screen6: pushf
         mov       ah,3eh
         mov       bx,ds:[Idents]           ; identifik tor v˜stupn¡ho souboru
         int       21h                      ; uzav©en¡ souboru
         popf
         jnc       Screen8                  ; operace OK

; ------ chyba z pisu na disk

Screen7: call      SEBeep                   ; p¡pnut¡ p©i chybˆ

; ------ zru¨en¡ p©¡znaku obsluhy PRINT SCREEN

Screen8: cli
         mov       ax,ds:[SDelay]           ; prodleva ‡asov‚ho ukl d n¡
         mov       ds:[SCitac],ax           ; inicializace ‡¡ta‡e prodlevy
         mov       ax,40h
         mov       ds,ax
         mov       byte ptr ds:[100h],0     ; zru¨en¡ p©¡znaku PRINT SCREEN

; ------ n vrat registr–

         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         popf

; ------ odinstalov n¡ obsluh p©eru¨en¡

         cli                                ; z kaz p©eru¨en¡
         call      SDinsInt                 ; odinstalov n¡ INT 23h a INT 24h

; ------ nulov n¡ p©¡znaku obsluhy

         mov       byte ptr cs:[OldKey],0
         or        byte ptr cs:[SParam],1   ; zru¨en¡ po‘adavku obsluhy
         and       byte ptr cs:[SParam],not 2; ru¨en¡ p©¡zn., ‘e prob¡h  obsluha
         ret

Screen   ENDP

; -----------------------------------------------------------------------------
;        instalace obsluh p©eru¨en¡ pro sn¡ma‡ obrazovky
; -----------------------------------------------------------------------------

SInstInt PROC      NEAR

; ------ £schova registr–

         push      ax
         push      ds

; ------ p©¡prava DS

         xor       ax,ax
         mov       ds,ax                    ; DS <- 0

; ------ £schova adresy INT 23h

         mov       ax,ds:[4*23h]            ; offset INT 23h
         mov       word ptr cs:[Old23],ax   ; £schova offsetu INT 23h
         mov       ax,ds:[4*23h+2]          ; segment INT 23h
         mov       word ptr cs:[Old23+2],ax ; £schova segmentu INT 23h

; ------ £schova adresy INT 24h

         mov       ax,ds:[4*24h]            ; offset INT 24h
         mov       word ptr cs:[Old24],ax   ; £schova offsetu INT 24h
         mov       ax,ds:[4*24h+2]          ; segment INT 24h
         mov       word ptr cs:[Old24+2],ax ; £schova segmentu INT 24h

; ------ instalace obsluhy INT 23h

         mov       word ptr ds:[4*23h],offset SInt23 ; offset obsluhy INT 23h
         mov       ds:[4*23h+2],cs          ; segment obsluhy INT 23h

; ------ instalace obsluhy INT 24h

         mov       word ptr ds:[4*24h],offset SInt24 ; offset obsluhy INT 24h
         mov       ds:[4*24h+2],cs          ; segment obsluhy INT 24h

; ------ n vrat registr–

         pop       ds
         pop       ax
         ret

SInstInt ENDP

; -----------------------------------------------------------------------------
;        Odinstalov n¡ obsluh p©eru¨en¡ pro sn¡ma‡ obrazovky
; -----------------------------------------------------------------------------

SDinsInt PROC      NEAR

; ------ £schova registr–

         push      ax
         push      ds

; ------ p©¡prava DS

         xor       ax,ax
         mov       ds,ax                    ; DS <- 0

; ------ n vrat adresy INT 23h

         mov       ax,word ptr cs:[Old23]   ; offset INT 23h
         mov       ds:[4*23h],ax            ; n vrat offsetu INT 23h
         mov       ax,word ptr cs:[Old23+2] ; segment INT 23h
         mov       ds:[4*23h+2],ax          ; n vrat segmentu INT 23h

; ------ n vrat adresy INT 24h

         mov       ax,word ptr cs:[Old24]   ; offset INT 24h
         mov       ds:[4*24h],ax            ; n vrat offsetu INT 24h
         mov       ax,word ptr cs:[Old24+2] ; segment INT 24h
         mov       ds:[4*24h+2],ax          ; n vrat segmentu INT 24h

; ------ n vrat registr–

         pop       ds
         pop       ax
         ret

SDinsInt ENDP

; -----------------------------------------------------------------------------
;        obsluha p©eru¨en¡ INT 23h a INT 24h
; -----------------------------------------------------------------------------

SInt24   PROC      FAR

         mov       al,0
SInt23:  iret

SInt24   ENDP

; -----------------------------------------------------------------------------
;        obsluha testovac¡ho re‘imu (DS=datov˜ segment)
; -----------------------------------------------------------------------------
;þ
STest    PROC      NEAR

; ------ zvukov  signalizace

         call      SBeep                    ; zvukov  signalizace zah jen¡

; ------ otev©en¡ v˜stupn¡ho souboru

         call      SIniFile                 ; otev©en¡ v˜stupn¡ho souboru
         jnc       STest1
         jmp       STest9                   ; chyba - soubor nevytvo©en

; ------ z pis ‡¡sla videom¢du

STest1:  mov       si,offset STxtVMod
         call      STestTxt
         xor       ax,ax
         mov       es,ax
         mov       al,es:[449h]
         call      STstBytH                ; z pis bajtu v HEX m¢du
         call      STestCR
         call      STestCR

; ------ z pis registr– 3b4h/3d4h

         mov       dx,es:[463h]
         mov       cl,19h
         call      STstRRR

; ------ z pis registru 3BAh/3DAh

         add       dl,6
         mov       ax,dx
         call      STstWrdH
         mov       si,offset STxtR
         call      STestTxt
         in        al,dx
         call      STstBin

         mov       ax,dx
         call      STstWrdH
         mov       si,offset STxtW
         call      STestTxt
         push      dx
         mov       dx,3cah
         in        al,dx
         pop       dx
         call      STstBin
         call      STestCR

; ------ z pis registr– palet 3C0h

         mov       dx,es:[463h]
         add       dl,6
         mov       ah,0                     ; index
STest2:  in        al,dx                    ; synchronizace
         push      dx
         mov       dx,3c0h
         mov       al,ah
         out       dx,al                    ; nastaven¡ ‡¡sla registru
         inc       dx
         in        al,dx
         dec       dx
         call      STstIndx
         pop       dx
         inc       ah
         cmp       ah,14h
         jbe       STest2

         in        al,dx
         mov       dx,3c0h
         mov       al,20h
         out       dx,al
         call      STestCR

; ------ z pis registru 3C2h

         mov       si,offset STxtRC2
         call      STestTxt
         mov       dx,3c2h
         in        al,dx
         call      STstBin
         call      STestTxt
         mov       dl,0cch
         in        al,dx
         call      STstBin
         call      STestCR

; ------ z pis registru 3C4h

         mov       dx,3c4h
         mov       cl,5
         call      STstRRR

; ------ z pis registru 3CEh

         mov       dx,3ceh
         mov       cl,9
         call      STstRRR

; ------ z pis registr– barev

         mov       si,offset STxtBar
         call      STestTxt
         mov       dx,3c7h
         xor       ax,ax
         out       dx,al
         inc       dx
         inc       dx
STest4:  mov       al,ah
         call      STstBytH
         mov       al,":"
         call      WritB0
         in        al,dx
         call      STestNum
         mov       al,","
         call      WritB0
         in        al,dx
         call      STestNum
         mov       al,","
         call      WritB0
         in        al,dx
         call      STestNum

         inc       ah
         jz        STest44
         test      ah,3
         jnz       STest42
         call      STestCR
         jmp       short STest4

STest42: mov       al,9
         call      WritB0
         jmp       short STest4

STest44: call      STestCR
         call      STestCR



;; ------ z pis z hlav¡ do souboru
;
;         mov       dx,offset Zahlavi        ; z hlav¡ souboru
;         mov       cx,offset(KonHl-Zahlavi) ; d‚lka z hlav¡ souboru
;         mov       bx,ds:[Idents]           ; identifik tor souboru
;         mov       ah,40h                   ; funkce z pisu do souboru
;         int       21h                      ; z pis z hlav¡ do souboru
;         jc        Screen6                  ; chyba z pisu na disk
;
;; ------ z pis palet barev do souboru
;
;         mov       cx,ds:[Palet]            ; po‡et bajt– palet VGA
;         jcxz      Screen4                  ; nejsou ‘ dn‚ palety
;         mov       dx,offset Buffer         ; buffer s na‡ten˜mi paletami
;         mov       bx,ds:[Idents]           ; identifik tor souboru
;         mov       ah,40h                   ; funkce z pisu do souboru
;         int       21h                      ; z pis palet do souboru
;         jc        Screen6                  ; chyba z pisu na disk

; ------ vypr zdnˆn¡ bufferu

         call      WritBuff                 ; z pis bufferu na disk

; ------ uzav©en¡ souboru

STest8:  mov       ah,3eh
         mov       bx,ds:[Idents]           ; identifik tor v˜stupn¡ho souboru
         int       21h                      ; uzav©en¡ souboru
STest9:  ret

STest    ENDP

STxtVMOD db        'Aktivni videomod: ',0

STxtRC2  db        '03C2h'
STxtR    db        ' (R): ',0
STxtWC2  db        '03C2h'
STxtW    db        ' (W): ',0

STxtBar  db        'Registry barev:',13,10,0

; -----------------------------------------------------------------------------
;        z pis CL registr–
; -----------------------------------------------------------------------------

STstRRR  PROC      NEAR

         in        al,dx
         push      ax

         mov       ah,0
         mov       ch,0
STstRRR1:mov       al,ah
         out       dx,al
         inc       dx
         in        al,dx
         dec       dx
         call      STstIndx
         inc       ah
         loop      STstRRR1

         pop       ax
         out       dx,al

         call      STestCR
         ret

STstRRR  ENDP

; -----------------------------------------------------------------------------
;        z pis registru DX v bin rn¡m tvaru
; -----------------------------------------------------------------------------

STstReg: push      ax
         mov       ax,dx
         call      STstWrdH
         jmp       short STstInd1

; -----------------------------------------------------------------------------
;        z pis registru DX s indexem AH
; -----------------------------------------------------------------------------

STstIndx PROC      NEAR

         push      ax
         mov       ax,dx
         call      STstWrdH
         mov       al,"/"
         call      WritB0
         pop       ax
         push      ax
         mov       al,ah
         call      STstBytH
STstInd1:mov       al,":"
         call      WritB0
         call      STestSpc
         pop       ax
         call      STstBin
         ret

STstIndx ENDP

; -----------------------------------------------------------------------------
;        z pis bajtu AL v bin rn¡m tvaru
; -----------------------------------------------------------------------------

STstBin  PROC      NEAR

         push      ax
         push      cx
         mov       cx,8
         mov       ah,al
STstBin1:mov       al,"0"
         shl       ah,1
         jnc       STstBin2
         inc       ax
STstBin2:call      WritB0
         loop      STstBin1
         mov       al,"b"
         call      WritB0

         call      STestSpc
         mov       al,"="
         call      WritB0
         call      STestSpc

         pop       cx
         pop       ax

         call      STstBytH

         push      ax
         call      STestSpc
         mov       al,"="
         call      WritB0
         call      STestSpc
         pop       ax

         call      STestNum
         call      STestCR
         ret

STstBin  ENDP

; -----------------------------------------------------------------------------
;        z pis bajtu v dekadick‚m tvaru
; -----------------------------------------------------------------------------

STestNum PROC      NEAR

         push      ax
         push      cx

         mov       cx,100
         call      STstNm1
         mov       cl,10
         call      STstNm1
         mov       cx,101h
         call      StstNm1

         pop       cx
         pop       ax
         ret

STestNum ENDP

STstNm1: mov       ah,0
         div       cl
         cmp       al,0
         jne       STstNm2
         cmp       ch,0
         je        STstNm3
STstNm2: add       al,"0"
         call      WritB0
         inc       ch
STstNm3: xchg      al,ah
         ret

; -----------------------------------------------------------------------------
;        z pis slova HEX se znakem H
; -----------------------------------------------------------------------------

STstWrdH PROC      NEAR

         call      STstWord
         jc        STstWrH2
         push      ax
         mov       al,"h"
         call      WritB0
         pop       ax
STstWrH2:ret

STstWrdH ENDP

; -----------------------------------------------------------------------------
;        z pis slova v HEX k¢du
; -----------------------------------------------------------------------------

STstWord PROC      NEAR

         xchg      al,ah
         call      STstByte
         xchg      al,ah
         jc        STstWrd3
         call      STstByte
STstWrd3:ret

STstWord ENDP

; -----------------------------------------------------------------------------
;        z pis bajtu HEX se znakem H
; -----------------------------------------------------------------------------

STstBytH PROC      NEAR

         call      STstByte
         jc        STstBtH2
         push      ax
         mov       al,"h"
         call      WritB0
         pop       ax
STstBtH2:ret

STstBytH ENDP

; -----------------------------------------------------------------------------
;        z pis bajtu v HEX k¢du
; -----------------------------------------------------------------------------

STstByte PROC      NEAR

         push      ax
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1
         call      STstHex
         pop       ax
         jc        STstHex3
STstHex: push      ax
         and       al,0fh
         cmp       al,10
         jb        STstHex2
         add       al,7
STstHex2:add       al,"0"
         call      WritB0
         pop       ax
STstHex3:ret

STstByte ENDP

; -----------------------------------------------------------------------------
;        z pis textu DS:SI (po 0)
; -----------------------------------------------------------------------------

STestTxt PROC      NEAR

         push      ax
STstTxt1:cld
         lodsb
         cmp       al,0
         je        STstTxt2
         call      WritB0
         jnc       STstTxt1
STstTxt2:pop       ax
         ret

STestTxt ENDP

; -----------------------------------------------------------------------------
;        z pis mezery
; -----------------------------------------------------------------------------

STestSpc PROC      NEAR

         push      ax
         mov       al," "
         call      WritB0
         pop       ax
         ret

STestSpc ENDP

; -----------------------------------------------------------------------------
;        z pis konce © dku
; -----------------------------------------------------------------------------

STestCR  PROC      NEAR

         push      ax
         mov       al,13
         call      WritB0
         jc        STestCR1
         mov       al,10
         call      WritB0
STestCR1:pop       ax
         ret

STestCR  ENDP

; -----------------------------------------------------------------------------
;        poskytnut¡ obsahu ©¡dic¡ho registru VGA (CY=nen¡ VGA)
; -----------------------------------------------------------------------------
; VSTUP: AH=‡¡slo registru
;        DS=datov˜ segment
; VSTUP:AL=hodnota registru
;        CY=nen¡ VGA
; -----------------------------------------------------------------------------

SGetCReg PROC      NEAR

; ------ test, zda je karta VGA

         cmp       byte ptr ds:[Card],4     ; je karta VGA ?
         jb        SGetCRg9                 ; nen¡ karta VGA

; ------ £schova registr–

         push      ds
         push      bx
         push      dx

; ------ adresa ©¡dic¡ho registru

         xor       dx,dx
         mov       ds,dx                    ; DS <- 0
         mov       dx,ds:[463h]             ; b zov  ©¡dic¡ adresa displeje

; ------ £schova ‡¡sla registru do BL

         in        al,dx
         mov       bl,al

; ------ nastaven¡ ‡¡sla registru

         mov       al,ah                    ; ‡¡slo registru
         out       dx,al                    ; nastaven¡ ‡¡sla registru

; ------ ‡ten¡ stavu portu

         inc       dx
         in        al,dx                    ; ‡ten¡ stavu portu

; ------ n vrat ‡¡sla registru

         dec       dx
         xchg      al,bl
         out       dx,al
         xchg      al,bl

; ------ n vrat registr– (zde je NC !)

         pop       dx
         pop       bx
         pop       ds
SGetCRg9:ret

SGetCReg ENDP

; -----------------------------------------------------------------------------
;        p©¡prava parametr– videom¢du
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
; VSTUP:ES:SI=adresa videopamˆti
;        BP=adresa obsluhy ulo‘en¡ videostr nky
;        CY=neobsluhovan˜ videom¢d
; zni‡en‚ registry: AX
; -----------------------------------------------------------------------------

SInitMod PROC      NEAR

; ------ ‡¡slo videom¢du

         xor       bx,bx                    ; BX <- 0
         mov       es,bx                    ; DS <- 0
         mov       bl,ds:[VMod]
         test      byte ptr ds:[SParam3],1
         jnz       SInitM02                 ; automatick˜ videom¢d
         mov       bl,es:[449h]             ; aktivn¡ videom¢d
SInitM02:mov       ds:[VMod],bl             ; aktivn¡ videom¢d

; ------ kontrola ‡¡sla videom¢du

         cmp       bl,20                    ; maxim ln¡ videom¢d+1
         jb        SInitM01
         mov       bl,19
;         jae       SInitMd0                 ; nepovolen˜ videom¢d
SInitM01:
         mov       ax,0b800h                ; adresa videopamˆti CGA
         cmp       bl,7                     ; povolen˜ textov˜ videom¢d ?
         jb        SInitMd1                 ; je videom¢d CGA
         mov       ah,0b0h                  ; adresa videopamˆti MDA
         je        SInitMd1                 ; je videom¢d MDA
         mov       ah,0a0h                  ; jinak adresa videopamˆti EGA/VGA
         sub       bl,5                     ; korekce ‡¡sla videom¢du
         cmp       bl,13-5                  ; je videom¢d 13 a v˜¨e ?
         jae       SInitMd1                 ; videom¢d OK
SInitMd0:stc                                ; p©¡znak neobsluhovan‚ho m¢du
         ret

; ------ adresa videopamˆti

SInitMd1:mov       si,es:[44eh]             ; offset adresy videopamˆti
         mov       es,ax                    ; segment videopamˆti

; ------ p©¡rustek adresy videolinky

         mov       ah,0
         mov       al,ds:[bx+STabInc]       ; p©¡rustek adresy videolinky
         shl       ax,1
         mov       ds:[SIncAdr],ax          ; p©¡rustek adresy

         mov       word ptr ds:[SZlom],-1   ; nen¡ zlom linek

; ------ up©esnˆn¡ p©¡rustku pro VGA

         mov       ah,13h
         call      SGetCReg                 ; ‡ten¡ registru p©¡rustku adresy
         jc        SInitMd3                 ; nen¡ karta VGA
         mov       ah,0
         shl       ax,1
         mov       ds:[SIncAdr],ax          ; p©¡rustek adresy

; ------ up©esnˆn¡ adresy videopamˆti pro VGA

         mov       ah,0ch                   ; registr adresy HIGH
         call      SGetCReg                 ; ‡ten¡ registru
         mov       ch,al
         mov       ah,0dh                   ; registr adresy LOW
         call      SGetCReg                 ; ‡ten¡ registru
         mov       ah,ch                    ; adresa HIGH
         xchg      ax,si                    ; SI <- adresa videopamˆti
         cmp       bl,3                     ; je textov˜ m¢d CGA ?
         jbe       SInitMd2                 ; je textov˜ m¢d CGA
         cmp       bl,7                     ; je textov˜ m¢d HGC ?
         jne       SIniMd22                 ; nen¡ textov˜ m¢d
SInitMd2:shl       si,1                     ; adresa * 2 (prokl d n¡ rovin)

; ------ stanoven¡ linky pro dˆlenou obrazovku

SIniMd22:mov       ah,18h                   ; registr linky dˆlen‚ obrazovky
         call      SGetCReg                 ; ‡ten¡ linky dˆlen‚ obrazovky
         mov       cl,al                    ; ni‘¨¡ch 8 bit– ‡¡sla linky
         mov       ah,7
         call      SGetCReg                 ; ‡ten¡ dopl¤uj¡c¡ch bit–
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1
         and       al,1                     ; bit 8 linky zlomu
         mov       ch,al
         mov       ah,9
         call      SGetCReg
         mov       ah,al
         rol       al,1
         rol       al,1
         rol       al,1
         and       al,2
         or        ch,al                    ; bit 9 linky zlomu
         inc       cx
         test      ah,80h                   ; konverze 200 linek na 400 ?
         jz        SIniM222                 ; nen¡ zdvojen¡
         shr       cx,1                     ; polovi‡n¡ po‡et linek
SIniM222:mov       word ptr ds:[SZlom],cx   ; linka zlomu obrazovky

SIniMd23:

; ------ adresa parametr–

SInitMd3:mov       cl,3
         shl       bx,cl                    ; ‡¡slo videom¢du * 8
         add       bx,offset TabMod         ; tabulka videom¢d–

; ------ stanoven¡ parametr– podle tabulky

         mov       ax,ds:[bx]               ; ¨¡©ka obrazovky
         mov       ds:[Sirka],ax            ; ¨¡©ka v˜©ezu
         mov       ax,ds:[bx+2]             ; v˜¨ka obrazovky
         mov       ds:[Vyska],ax            ; v˜¨ka obrazovky
         mov       ax,ds:[bx+4]             ; po‡et rovin a parametry
         mov       ds:[Rovin],al            ; po‡et barevn˜ch rovin
         and       byte ptr ds:[Param],not 2 + 4 ; nulov n¡ star˜ch p©¡znak–
         or        byte ptr ds:[Param],ah   ; nastaven¡ nov˜ch p©¡znak–

; ------ up©esnˆn¡ © dk– v textov‚m m¢du

         cmp       byte ptr ds:[Card],3     ; je karta EGA/VGA ?
         jb        SInitMd8                 ; nen¡ karta EGA/VGA
         test      ah,2                     ; je textov˜ videom¢d ?
         jz        SInitMd8                 ; nen¡ textov˜ videom¢d
         push      ds
         xor       ax,ax                    ; AX <- 0
         mov       ds,ax                    ; DS <- 0
         mov       al,ds:[484h]             ; ‡¡slo posledn¡ho © dku
         inc       ax                       ; po‡et © dk– na obrazovku
         pop       ds
         cmp       al,25                    ; je alespo¤ 25 © dk– ?
         jb        SInitMd8                 ; mal˜ po‡et © dk–
         mov       ds:[Vyska],ax            ; opraven  v˜¨ka displeje

; ------ adresa obsluhy z pisu do souboru

SInitMd8:mov       bp,ds:[bx+6]             ; adresa obsluhy
         clc                                ; p©¡znak operace OK
SInitMd9:ret

SInitMod ENDP

; -----------------------------------------------------------------------------
;        inicializace palet displeje
; -----------------------------------------------------------------------------
;þ
SInitPal PROC      NEAR

; ------ p©¡prava registr–

         and       byte ptr ds:[Param],not 40h+20h+10h ; zru¨en¡ p©¡znak– palet
         mov       word ptr ds:[Palet],0    ; zru¨en¡ p©¡znaku palet
         mov       bx,offset Buffer         ; buffer k na‡ten¡ palet

; ------ na‡ten¡ palet CGA

SIniPal0:test      byte ptr ds:[SParam2],1  ; palety CGA v‘dy ?
         jnz       SIniPal1                 ; palety CGA v‘dy
         test      byte ptr ds:[SParam2],2  ; povoleny ?
         jz        SIniPl13                 ; nejsou povoleny
         cmp       byte ptr ds:[VMod],6     ; pouze pro m¢dy CGA
         ja        SIniPl13                 ; nen¡ m¢d CGA

SIniPal1:push      ds
         xor       ax,ax
         mov       ds,ax                    ; DS <- 0
         mov       ax,ds:[465h]             ; nastaven¡ port– 3d8h a 3d9h
         pop       ds

         shl       al,1
         and       ax,3f40h                 ; p©¡znak blik n¡ a barva
         test      byte ptr ds:[Param],2    ; je textov˜ m¢d ?
         jz        SIniPl11                 ; nen¡ textov˜ m¢d
         or        ah,al                    ; p©¡znak blik n¡
SIniPl11:mov       ds:[bx],ah               ; ulo‘en¡ bajtu do bufferu
         inc       bx                       ; zv˜¨en¡ ukazatele v bufferu
         or        byte ptr ds:[Param],10h  ; p©¡znak palet CGA
         inc       word ptr ds:[Palet]      ; zv˜¨en¡ ‡¡ta‡e bajt– palet

; ------ na‡ten¡ palet EGA

SIniPl13:
         cmp       byte ptr ds:[Card],4     ; je karta VGA ?
         jae       SIniPl14                 ; je karta VGA
         ret

SIniPl14:test      byte ptr ds:[SParam2],4  ; palety EGA v‘dy ?
         jnz       SIniPl15                 ; palety EGA v‘dy
         test      byte ptr ds:[SParam2],8  ; palety EGA nikdy ?
         jz        SIniPal3                 ; palety EGA nikdy
         cmp       byte ptr ds:[VMod],13
         jb        SIniPal3                 ; nen¡ m¢d EGA
         cmp       byte ptr ds:[VMod],19
         jae       SIniPal3
SIniPl15:or        byte ptr ds:[Param],20h  ; p©¡znak palet EGA
         push      ds
         xor       ax,ax
         mov       ds,ax                    ; DS <- 0
         mov       dx,ds:[463h]             ; b zov  adresa displeje
         pop       ds
         add       dl,6
         in        al,dx                    ; synchronizace n slednosti

         mov       dx,3c0h                  ; port palet
         mov       ah,0                     ; po‡ te‡n¡ paleta 0
         mov       cx,18                    ; po‡et bajt– k na‡ten¡
         add       ds:[Palet],cx            ; po‡et bajt– palet
         dec       cx
SIniPal2:mov       al,ah                    ; ‡¡slo registru
         out       dx,al                    ; volba ‡¡sla registru
         inc       dx
         in        al,dx                    ; ‡ten¡ palety
         dec       dx
         out       dx,al

         mov       ds:[bx],al               ; ulo‘en¡ bajtu do bufferu
         inc       bx                       ; zv˜¨en¡ ukazatele v bufferu
         inc       ah                       ; zv˜¨en¡ ‡¡sla registru
         cmp       ah,10h
         jne       SIniPl22
         inc       ah
SIniPl22:loop      SIniPal2                 ; dal¨¡ bajt palety

         mov       al,10h
         out       dx,al
         inc       dx
         in        al,dx
         dec       dx
         out       dx,al
         mov       ah,al

         mov       al,14h
         out       dx,al
         inc       dx
         in        al,dx
         dec       dx
         out       dx,al

         mov       cl,4
         shl       al,cl
         mov       cl,ah
         and       ah,8
         or        al,ah
         rol       cl,1
         and       cl,1
         or        al,cl

         mov       ds:[bx],al               ; ulo‘en¡ bajtu do bufferu
         inc       bx                       ; zv˜¨en¡ ukazatele v bufferu

         mov       al,20h
         out       dx,al                    ; zapnut¡ videosign lu

; ------ na‡ten¡ palet VGA

SIniPal3:test      byte ptr ds:[SParam2],10h; jsou palety VGA v‘dy ?
         jnz       SIniPal4                 ; palety VGA v‘dy
         test      byte ptr ds:[SParam2],20h; jsou palety VGA povolen‚ ?
         jz        SIniPal9                 ; palety VGA nejsou povolen‚
         cmp       byte ptr ds:[VMod],13
         jb        SIniPal9                 ; nen¡ m¢d EGA nebo VGA
SIniPal4:or        byte ptr ds:[Param],40h  ; p©¡znak palet VGA
         mov       dx,3c7h                  ; port ‡tec¡ adresy palet
         mov       al,0                     ; po‡ te‡n¡ paleta 0
         out       dx,al                    ; nastaven¡ ‡tec¡ palety 0
         inc       dx
         inc       dx                       ; datov˜ port palet VGA
         mov       cx,3*256                 ; po‡et bajt– k na‡ten¡
         add       ds:[Palet],cx            ; po‡et bajt– palet
SIniPal5:in        al,dx                    ; na‡ten¡ bajtu palety
         mov       ds:[bx],al               ; ulo‘en¡ bajtu do bufferu
         inc       bx                       ; zv˜¨en¡ ukazatele v bufferu
         loop      SIniPal5                 ; dal¨¡ bajt palety

SInipal9:ret

SInitPal ENDP

; -----------------------------------------------------------------------------
;        zvukov  signalizace zah jen¡ sn¡m n¡ obrazovky
; -----------------------------------------------------------------------------

SBeep    PROC      NEAR

; ------ zapnut¡ zvukov‚ho gener toru

         mov       cx,10                    ; po‡et cykl– celkem
SBeep1:  push      cx                       ; £schova ‡¡ta‡e pr–chod–
         in        al,[61h]                 ; port zvukov‚ho v˜stupu
         or        al,3                     ; zapnut¡ zvukov‚ho gener toru
         out       [61h],al

; ------ prodleva 1

         mov       ch,30                    ; asi tak prvn¡ prodleva
         loop      $                        ; prodleva

; ------ vypnut¡ zvukov‚ho gener toru

         and       al,0fch                  ; vypnut¡ gener toru
         out       [61h],al

; ------ prodleva 2

         mov       ch,20                    ; asi tak druh  prodleva
         loop      $
         pop       cx
         loop      SBeep1                   ; dal¨¡ impuls
         ret

SBeep    ENDP

; -----------------------------------------------------------------------------
;        zvukov  signalizace chyby z pisu do souboru
; -----------------------------------------------------------------------------

SEBeep   PROC      NEAR

; ------ zapnut¡ zvukov‚ho gener toru

         in        al,[61h]                 ; port zvukov‚ho v˜stupu
         or        al,3                     ; zapnut¡ zvukov‚ho gener toru
         out       [61h],al

; ------ prodleva

         xor       cx,cx
         loop      $                        ; prodleva

; ------ vypnut¡ zvukov‚ho gener toru

         and       al,0fch                  ; vypnut¡ gener toru
         out       [61h],al
         ret

SEBeep   ENDP

; -----------------------------------------------------------------------------
;        inicializace v˜stupn¡ho souboru (DS=datov˜ segment)
; -----------------------------------------------------------------------------

SIniFile PROC      NEAR

; ------ inicializace ‡¡sla souboru

         mov       bx,ds:[AdrSoub]          ; adresa ‡¡sla souboru
         mov       word ptr ds:[bx-1],"00"  ; nulov n¡ ‡¡sla souboru
         mov       byte ptr ds:[bx-2],"0"

; ------ test, zda soubor existuje

SIniFil1:mov       dx,offset Soubor         ; jm‚no v˜stupn¡ho souboru
         mov       ax,3d00h                 ; funkce otev©en¡ pro ‡ten¡
         int       21h                      ; pokus o otev©en¡ souboru
         jc        SIniFil3                 ; soubor z©ejmˆ neexistuje - OK
         mov       bx,ax                    ; identifik tor souboru
         mov       ah,3eh
         int       21h                      ; uzav©en¡ souboru

; ------ zv˜¨en¡ ‡¡sla souboru

         mov       bx,ds:[AdrSoub]          ; adresa ‡¡sla souboru
SIniFil2:inc       byte ptr ds:[bx]         ; zv˜¨en¡ jedn‚ ‡¡slice
         cmp       byte ptr ds:[bx],"9"+1   ; je p©ete‡en¡ ‡¡slice ?
         jne       SIniFil1                 ; nen¡ p©ete‡en¡ - nov˜ test
         mov       byte ptr ds:[bx],"0"     ; nulov n¡ ‡¡slice
         dec       bx                       ; posun ukazatele
         jmp       short SIniFil2           ; zv˜¨en¡ dal¨¡ ‡¡slice

; ------ vytvo©en¡ nov‚ho souboru

SIniFil3:mov       ah,3ch
         xor       cx,cx                    ; atributy
         int       21h                      ; vytvo©en¡ nov‚ho souboru
         mov       ds:[Idents],ax           ; identifik tor souboru
         ret

SIniFile ENDP

; *****************************************************************************
;
;                 Z pis obsahu videopamˆti do souboru
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        ulo‘en¡ obrazovky v textov‚m m¢du
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=adresa videopamˆti
;        DS=datov˜ segment
; VSTUP:CY=chyba z pisu do souboru
; zni‡en‚ registry: AX, BX, CX, DX
; -----------------------------------------------------------------------------
                                          ;* ‡ten¡ v textov‚m m¢du
ReadTxt  PROC      NEAR

         mov       bx,ds:[Vyska]            ; po‡et © dk–
         mov       cx,ds:[Sirka]            ; po‡et znak– na © dek
         mov       dx,ds:[SIncAdr]          ; p©¡rustek adresy linek
         shl       dx,1
         call      Read0Txt
         jc        ReadTxt9                 ; chyba z pisu do souboru
         inc       si                       ; adresa atribut– barev
         call      Read0Txt
ReadTxt9:ret

ReadTxt  ENDP

; -----------------------------------------------------------------------------
;        ulo‘en¡ jedn‚ textov‚ roviny
; -----------------------------------------------------------------------------

Read0Txt PROC      NEAR

         push      bx
         push      cx
         push      si

Read0Tx1:push      cx
         push      si

Read0Tx2:mov       al,es:[si]               ; bajt znaku
         inc       si
         inc       si                       ; zv˜¨en¡ adresy ve videopamˆti
         call      WritB                    ; z pis bajtu do souboru
         jc        Read0Tx3                 ; chyba z pisu do souboru
         loop      Read0Tx2                 ; z pis dal¨¡ho znaku

Read0Tx3:pop       si
         pop       cx
         jc        Read0Tx4

         add       si,dx                    ; zv˜¨en¡ adresy © dku
         dec       bx
         jnz       Read0Tx1                 ; dal¨¡ © dek

Read0Tx4:pop       si
         pop       cx
         pop       bx
         ret

Read0Txt ENDP

; -----------------------------------------------------------------------------
;        ulo‘en¡ obrazovky v m¢du CGA
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=adresa videopamˆti
;        DS=datov˜ segment
; VSTUP:CY=chyba z pisu do souboru
; zni‡en‚ registry: AX, BX, CX, DX
; -----------------------------------------------------------------------------

ReadCGA  PROC      NEAR

         mov       bx,200                   ; po‡et linek
         mov       cx,80/2                  ; po‡et slov na linku
         mov       dx,2000h                 ; posun adresy linky
ReadCGA2:call      WritStr                  ; z pis jedn‚ linky do souboru
         jc        ReadCGA9                 ; chyba z pisu do souboru
         add       si,dx                    ; adresa dal¨¡ linky
         xor       dx,2000h XOR (80-2000h)  ; p©eklopen¡ p©¡rustku adresy
         dec       bx                       ; ‡¡ta‡ linek
         jnz       ReadCGA2                 ; z pis dal¨¡ linky
         clc                                ; p©¡znak operace OK
ReadCGA9:ret

ReadCGA  ENDP

; -----------------------------------------------------------------------------
;        ulo‘en¡ obrazovky v m¢du MCGA
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=adresa videopamˆti
;        DS=datov˜ segment
; VSTUP:CY=chyba z pisu do souboru
; zni‡en‚ registry: AX, BX, CX, DX
; -----------------------------------------------------------------------------
;þ
ReadMCG  PROC      NEAR

         mov       bp,ds:[SZlom]
         mov       bx,200

         mov       dx,3c4h
         in        al,dx
         push      ax
         mov       al,4
         out       dx,al
         inc       dx
         in        al,dx
         dec       dx
         test      al,8                     ; je z©etˆzen¡ pamˆti ?
         pop       dx
         out       dx,al

         mov       di,ds:[SIncAdr]          ; p©¡rustek adresy
         jz        ReadMCG2                 ; adresov n¡ maskou

         shl       di,1
         shl       di,1                     ; roviny se st©¡daj¡ za sebou

         shl       si,1
         shl       si,1
         shl       si,1

         mov       cx,320/2
ReadMCG1:call      WritStr
         jc        ReadMCG9
         add       si,di
         dec       bp
         jnz       ReadMC11
         xor       si,si
ReadMC11:dec       bx
         jnz       ReadMCG1
         clc
ReadMCG9:ret


ReadMCG2:
ReadMC22:;mov       ah,9
         ;call      SGetCReg
         ;test      al,80h                   ; konverze 200 linek na 400 ?
         ;jnz       ReadMC24                 ; je zdvojen¡
         ;mov       ah,17h
         ;call      SGetCReg
         ;test      al,4
         ;jnz       ReadMC24                 ; zdvojen¡ linek
         ;
         ;shl       di,1                     ; dvojn sobn˜ p©¡rustek
         ;shr       bp,1                     ; polovi‡n¡ p©elom dˆlen¡

ReadMC24:mov       cx,80
         push      si

         mov       dx,3ceh

ReadMCG3:mov       ah,0
         call      ReadBt
         call      WritB                    ; z pis prvn¡ho bajtu
         jc        ReadMCG4                 ; chyba z pisu do souboru

         mov       ah,1
         call      ReadBt
         call      WritB                    ; z pis prvn¡ho bajtu
         jc        ReadMCG4                 ; chyba z pisu do souboru

         mov       ah,2
         call      ReadBt
         call      WritB                    ; z pis prvn¡ho bajtu
         jc        ReadMCG4                 ; chyba z pisu do souboru

         mov       ah,3
         call      ReadBt
         call      WritB                    ; z pis prvn¡ho bajtu
         jc        ReadMCG4                 ; chyba z pisu do souboru

         inc       si                       ; zv˜¨en¡ adresy ve videopamˆti
         loop      ReadMCG3                 ; z pis dal¨¡ch 2 bajt–

ReadMCG4:pop       si
         jc        ReadMCG5

         add       si,di
         dec       bp
         jnz       ReadMC42
         xor       si,si
ReadMC42:dec       bx
         jnz       ReadMC24
         clc
ReadMCG5:ret

ReadMCG  ENDP

; -----------------------------------------------------------------------------
;        ‡ten¡ bajtu z roviny AH (DX=port 3CEh)
; -----------------------------------------------------------------------------

ReadBt   PROC      NEAR

         cli
         push      cx

         in        al,dx
         mov       ch,al                    ; CH <- p–vodn¡ ‡¡slo registru
         mov       al,4
         out       dx,al

         inc       dx
         in        al,dx
         mov       cl,al                    ; CL <- p–vodn¡ ‡tec¡ rovina
         mov       al,ah
         out       dx,al

         mov       al,cl
         mov       cl,es:[si]
         out       dx,al                    ; n vrat ‡tec¡ roviny

         dec       dx
         mov       al,ch
         out       dx,al                    ; n vrat ‡¡sla registru

         mov       al,cl                    ; na‡ten˜ bajt

         pop       cx
         sti
         ret

ReadBt   ENDP

; -----------------------------------------------------------------------------
;        ulo‘en¡ obrazovky v m¢du EGA
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=adresa videopamˆti
;        DS=datov˜ segment
; VSTUP:CY=chyba z pisu do souboru
; zni‡en‚ registry: AX, BX, CX, DX
; -----------------------------------------------------------------------------

ReadEGA  PROC      NEAR

; ------ ur‡en¡ po‡tu bajt– na linku

         mov       cx,ds:[Sirka]            ; ¨¡©ka obrazovky
         shr       cx,1
         shr       cx,1
         shr       cx,1
         shr       cx,1                     ; po‡et bajt– na linku/2

; ------ £schova nastaven¡ registru m¢du

         mov       ax,800h
         cmp       byte ptr ds:[Card],4
         jb        ReadEGA0
         mov       dx,3ceh
         in        al,dx
         mov       ah,al
         mov       al,5
         out       dx,al
         inc       dx
         in        al,dx
ReadEGA0:push      ax

; ------ inicializace ukazatele rovin

         xor       bx,bx                    ; BX <- ‡¡slo po‡ te‡n¡ roviny 0

; ------ z pis roviny na v˜stup

ReadEGA1:mov       dx,ds:[SIncAdr]          ; p©¡rustek adresy / 2

         push      si
         push      bx
         mov       di,ds:[Vyska]            ; v˜¨ka (po‡et linek)
         mov       bp,ds:[SZlom]

ReadEGA2:push      dx
         push      si
         push      cx

; ------ inicializace ‡tec¡ho videom¢du

         mov       dx,3ceh                  ; registry ©adi‡e grafiky
ReadEGA3:cli
         mov       al,5                     ; registr 5
         out       dx,al                    ; volba registru m¢du 5
         inc       dx
         mov       al,0                     ; m¢d ‡ten¡ 0
         out       dx,al                    ; nastaven¡ m¢du ‡ten¡ 0
         dec       dx

; ------ volba ‡tec¡ roviny

         mov       al,4                     ; registr volby ‡tec¡ roviny
         out       dx,al                    ; volba registru ‡¡sla roviny 4
         inc       dx
         mov       al,bl                    ; ‡¡slo ‡tec¡ roviny
         out       dx,al                    ; nastaven¡ ‡¡sla roviny ke ‡ten¡
         dec       dx

; ------ z pis jednoho slova

         mov       al,es:[si]
         inc       si
         mov       ah,es:[si]
         inc       si
         sti
         call      WritB
         jc        ReadEGA4                 ; chyba
         mov       al,ah
         call      WritB
         jc        ReadEGA4                 ; chyba
         loop      ReadEGA3

; ------ p©¡prava pro dal¨¡ linku

ReadEGA4:pop       cx
         pop       si
         pop       dx
         jc        ReadEGA5                 ; chyba

         add       si,dx                    ; zv˜¨en¡ adresy linky
         dec       bp
         jnz       ReadEG42
         xor       si,si
ReadEG42:dec       di                       ; ‡¡ta‡ linek
         jnz       ReadEGA2                 ; dal¨¡ linka

ReadEGA5:pop       bx
         pop       si
         jc        ReadEGA9                 ; chyba z pisu do souboru

; ------ p©¡prava pro dal¨¡ rovinu barev

         inc       bx                       ; zv˜¨en¡ ukazatele barevn˜ch rovin
         cmp       bl,ds:[Rovin]            ; jsou ji‘ v¨echny barevn‚ roviny ?
         jb        ReadEGA1                 ; ulo‘en¡ dal¨¡ barevn‚ roviny

; ------ n vrat nastaven¡ registru m¢du

ReadEGA9:mov       dx,3ceh
         mov       al,5
         out       dx,al
         pop       ax
         inc       dx
         out       dx,al
         dec       dx
         mov       al,ah
         out       dx,al
         ret

ReadEGA  ENDP

; *****************************************************************************
;
;                            Z pis dat do souboru
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        z pis ©etˆzce z obrazovky do souboru (CX slov od adresy ES:SI)
; -----------------------------------------------------------------------------

WritStr  PROC      NEAR

         push      cx
         push      si
WritStr1:mov       al,es:[si]               ; 2 bajty z videopamˆti
         inc       si
         mov       ah,es:[si]
         inc       si                       ; zv˜¨en¡ adresy ve videopamˆti
         call      WritB                    ; z pis prvn¡ho bajtu
         jc        WritStr4                 ; chyba z pisu do souboru
         mov       al,ah                    ; 2. bajt
         call      WritB                    ; z pis druh‚ho bajtu
         jc        WritStr4                 ; chyba z pisu do souboru
         loop      WritStr1                 ; z pis dal¨¡ch 2 bajt–
WritStr4:pop       si
         pop       cx
         ret

WritStr  ENDP

; -----------------------------------------------------------------------------
;        z pis bajtu do souboru s kompres¡ (DS=datov˜ segment, CY=chyba)
; -----------------------------------------------------------------------------
; Syntaxe komprese:
;    bajt - po‡et n sleduj¡c¡ch bajt– dat 0 a‘ 255 (0=pouze p©ep¡na‡ m¢du)
;         - kromˆ bajtu 255 se p©epne p©¡znak komprese/data
;    za bajtem n sleduje buƒ bajt, kter˜ se m  opakovat, nebo data o dan‚m po‡tu
;    Na za‡ tku souboru je nastaven p©¡znak komprese, prvn¡ bajt r–zn˜
;    od 255 tedy ud v  po‡et n sleduj¡c¡ch dat v bˆ‘n‚m m¢du
; -----------------------------------------------------------------------------

WritB    PROC      NEAR

; ------ rozli¨en¡, zda je m¢d komprese

         test      byte ptr ds:[Param],1    ; je komprese ?
         jz        WritB1                   ; nen¡ komprese

; ------ test, zda je bajt shodn˜ s bajtem v ‡¡ta‡i shody

         cmp       al,ds:[KompChar]         ; je bajt shodn˜ ?
         je        WritB4                   ; bajt je shodn˜
         call      FlushQ                   ; vypr zdnˆn¡ bufferu shody
         jc        WritB9                   ; chyba v˜stupu do souboru

; ------ ulo‘en¡ bajtu do bufferu shody

WritB4:  mov       ds:[KompChar],al         ; ulo‘en¡ shodn‚ho znaku
         inc       byte ptr ds:[KompCit]    ; zv˜¨en¡ ‡¡ta‡e shodn˜ch znak–

; ------ je-li 255 stejn˜ch znak–, vypr zdnˆn¡ bufferu shody

         cmp       byte ptr ds:[KompCit],255; je buffer ji‘ pln˜ ?
         clc                                ; p©¡znak operace OK
         jne       WritB9                   ; buffer je¨tˆ nen¡ pln˜
         call      FlushQ                   ; vypr zdnˆn¡ bufferu shody
WritB9:  ret

WritB1:  jmp       WritB0                   ; z pis bez komprese

WritB    ENDP

; -----------------------------------------------------------------------------
;        vypr zdnˆn¡ bufferu shody (DS=datov˜ segment, CY=chyba)
; -----------------------------------------------------------------------------

FlushQ   PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx

; ------ test, zda jsou nˆjak  data v bufferu opakov n¡

         mov       cx,ds:[KompCit]          ; po‡et shodn˜ch bajt–
         jcxz      FlushQ8                  ; v bufferu nic nen¡

; ------ kontrola, zda je dostate‡n˜ po‡et opakovan˜ch bajt–

         cmp       cl,3                     ; dostate‡n˜ po‡et bajt– ?
         jb        FlushQ5                  ; je mal˜ po‡et bajt–

; ------ je dostate‡n˜ po‡et bajt– - vypr zdnˆn¡ bˆ‘n‚ho bufferu

         call      FlushB                   ; vypr zdnˆn¡ bˆ‘n‚ho bufferu
         jc        FlushQ9                  ; chyba v˜stupu do souboru

; ------ p©¡padn‚ p©epnut¡ do kompresn¡ho m¢du

         cmp       byte ptr ds:[KompPar],0  ; je kompresn¡ m¢d ?
         jne       FlushQ3                  ; je kompresn¡ m¢d - OK
         mov       al,0                     ; bajt pro p©epnut¡ m¢du
         call      WritB0                   ; p©epnut¡ do kompresn¡ho m¢du
         jc        FlushQ9                  ; chyba v˜stupu do souboru
         inc       byte ptr ds:[KompPar]    ; p©¡znak kompresn¡ho m¢du

; ------ z pis bajtu d‚lky a opakovan‚ho bajtu

FlushQ3: mov       al,cl                    ; po‡et opakov n¡ bajtu
         call      WritB0                   ; z pis po‡tu bajt–
         jc        FlushQ9                  ; chyba v˜stupu do souboru
         mov       al,ds:[KompChar]         ; opakovan˜ znak
         call      WritB0                   ; z pis opakovan‚ho bajtu
         jc        FlushQ9                  ; chyba v˜stupu do souboru

; ------ nastaven¡ p©¡znaku m¢du komprese

         inc       cl                       ; je 255 znak– ?
         je        FlushQ7                  ; je 255 znak– - m¢d se nep©epne
         dec       byte ptr ds:[KompPar]    ; p©¡znak nekompresn¡ho m¢du
         jmp       short FlushQ7

; ------ mal˜ po‡et bajt– - vypr zdnˆn¡ p©es bˆ‘n˜ buffer

FlushQ5: mov       al,ds:[KompChar]         ; shodn˜ znak
FlushQ6: call      StorBuf                  ; ulo‘en¡ do bˆ‘n‚ho bufferu
         jc        FlushQ9                  ; chyba v˜stupu do souboru
         loop      FlushQ6                  ; ulo‘en¡ dal¨¡ho bajtu

; ------ nulov n¡ bufferu shody

FlushQ7: mov       byte ptr ds:[KompCit],0  ; zru¨en¡ ‡¡ta‡e bajt– v bufferu
FlushQ8: clc                                ; p©¡znak operace OK

; ------ n vrat registr–

FlushQ9: pop       cx
         pop       ax
         ret

FlushQ   ENDP

; -----------------------------------------------------------------------------
;        ulo‘en¡ bajtu AL do bˆ‘n‚ho bufferu (DS=datov˜ segment, CY=chyba)
; -----------------------------------------------------------------------------

StorBuf  PROC      NEAR

; ------ £schova registr–

         push      bx

; ------ ulo‘en¡ bajtu do bufferu

         mov       bx,ds:[KompBNum]         ; po‡et bajt– v kompresn¡m bufferu
         mov       ds:[bx+KompBuff],al      ; ulo‘en¡ bajtu do bufferu
         inc       bx                       ; zv˜¨en¡ ‡¡ta‡e bajt– v bufferu
         mov       ds:[KompBNum],bx         ; nov˜ po‡et bajt– v bufferu

; ------ p©i zaplnˆn¡ bufferu jeho vypr zdnˆn¡

         cmp       bl,255                   ; je buffer ji‘ pln˜ ?
         clc                                ; p©¡znak operace OK
         jne       StorBuf2                 ; buffer je¨tˆ nen¡ pln˜
         call      FlushB                   ; vypr zdnˆn¡ bufferu

; ------ n vrat registr–

StorBuf2:pop       bx
         ret

StorBuf  ENDP

; -----------------------------------------------------------------------------
;        vypr zdnˆn¡ bˆ‘n‚ho bufferu (DS=datov˜ segment, CY=chyba)
; -----------------------------------------------------------------------------

FlushB   PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      si

; ------ kontrola, zda v bufferu nˆco je

         clc                                ; p©¡znak operace OK
         mov       cx,ds:[KompBNum]         ; po‡et bajt– v kompresn¡m bufferu
         jcxz      FlushB9                  ; v bufferu nic nen¡

; ------ p©¡padn‚ p©epnut¡ do nekompresn¡ho m¢du

         cmp       byte ptr ds:[KompPar],0  ; je kompresn¡ m¢d ?
         je        FlushB3                  ; nen¡ kompresn¡ m¢d - OK
         mov       al,0                     ; bajt pro p©epnut¡ m¢du
         call      WritB0                   ; p©epnut¡ do norm ln¡ho m¢du
         jc        FlushB9                  ; chyba z pisu
         dec       byte ptr ds:[KompPar]    ; p©¡znak bˆ‘n‚ho m¢du

; ------ vysl n¡ bajtu d‚lky ©etˆzce

FlushB3: mov       al,cl                    ; po‡et n sleduj¡c¡ch bajt– textu
         call      WritB0                   ; vysl n¡ bajtu d‚lky
         jc        FlushB9                  ; chyba z pisu

; ------ nastaven¡ p©¡znaku p©epnut¡ m¢du

         cmp       al,255                   ; je 255 bajt– ?
         je        FlushB4                  ; je 255 znak– - m¢d se nep©epne
         inc       byte ptr ds:[KompPar]    ; jinak p©¡znak kompresn¡ho m¢du

; ------ vysl n¡ bufferu dat

FlushB4: mov        si,offset KompBuff      ; buffer s daty
FlushB5: cld
         lodsb                              ; bajt dat k vysl n¡
         call      WritB0                   ; vysl n¡ bajtu
         jc        FlushB9                  ; chyba z pisu
         loop      FlushB5                  ; vysl n¡ dal¨¡ho bajtu
         mov       byte ptr ds:[KompBNum],0 ; zru¨en¡ ‡¡ta‡e bajt– v bufferu

; ------ n vrat registr–

FlushB9: pop       si
         pop       cx
         pop       ax
         ret

FlushB   ENDP

; -----------------------------------------------------------------------------
;        Z pis bajtu do diskov‚ho bufferu (DS=datov˜ segment, CY=chyba)
; -----------------------------------------------------------------------------

WritB0   PROC      NEAR

; ------ vypr zdnˆn¡ bufferu, pokud je ji‘ zaplnˆn

         cmp       word ptr ds:[NumBuff],BufSize ; buffer je ji‘ zaplnˆn ?
         jb        WritB2                   ; buffer je¨tˆ nen¡ zaplnˆn
         call      WritBuff                 ; z pis bufferu na disk
         jc        WritB3                   ; byla chyba z pisu

; ------ ulo‘en¡ bajtu do bufferu

WritB2:  push      si
         mov       si,ds:[NumBuff]          ; po‡et bajt– v bufferu
         mov       ds:[si+Buffer],al        ; z pis nov‚ho bajtu do bufferu
         inc       si                       ; zv˜¨en¡ ‡¡ta‡e bajt–
         mov       ds:[NumBuff],si          ; nov˜ stav ‡¡ta‡e bajt– v bufferu
         pop       si
         clc                                ; p©¡znak operace OK
WritB3:  ret

WritB0   ENDP

; -----------------------------------------------------------------------------
;        Z pis diskov‚ho bufferu do souboru (DS=datov˜ segment, CY=chyba)
; -----------------------------------------------------------------------------

WritBuff PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx

; ------ z pis obsahu bufferu do souboru

         clc                                ; p©ednastaven¡ p©¡znaku OK
         mov       cx,ds:[NumBuff]          ; po‡et bajt– v diskov‚m bufferu
         jcxz      WritBff2                 ; nen¡ ‘ dn˜ bajt k z pisu
         mov       ah,40h                   ; funkce z pisu
         mov       bx,ds:[Idents]           ; identifik tor souboru
         mov       dx,offset Buffer         ; diskov˜ buffer
         int       21h                      ; z pis souboru
         mov       word ptr ds:[NumBuff],0  ; vynulov n¡ bufferu
         jc        WritBff2                 ; byla chyba
         cmp       ax,cx                    ; souhlas¡ po‡et bajt– ?

; ------ n vrat registr–

WritBff2:pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

WritBuff ENDP

; *****************************************************************************
;
;                     Tabulky parametr– videom¢d–
;
; *****************************************************************************
;þ
TabMod   label     word                   ;* tabulka videom¢d–

                                          ;* 0: 40x25 text
         dw        40,25                    ; ¨¡©ka, v˜¨ka
         db        2,2                      ; po‡et rovin, typ
         dw        ReadTxt                  ; obsluha z pisu do souboru

                                          ;* 1: 40x25 text
         dw        40,25
         db        2,2
         dw        ReadTxt

                                          ;* 2: 80x25 text
         dw        80,25
         db        2,2
         dw        ReadTxt

                                          ;* 3: 80x25 text
         dw        80,25
         db        2,2
         dw        ReadTxt

                                          ;* 4: 320x200/4 graf
         dw        320,200
         db        2,4
         dw        ReadCGA

                                          ;* 5: 320x200/4 graf
         dw        320,200
         db        2,4
         dw        ReadCGA

                                          ;* 6: 640x200/2 graf
         dw        640,200
         db        1,4
         dw        ReadCGA

                                          ;* 7: 80x25 text
         dw        80,25
         db        2,2
         dw        ReadTXT

                                          ;* 13: 320x200/16 graf
         dw        320,200
         db        4,0
         dw        ReadEGA

                                          ;* 14: 640x200/16 graf
         dw        640,200
         db        4,0
         dw        ReadEGA

                                          ;* 15: 640x350/2 graf
         dw        640,350
         db        1,0
         dw        ReadEGA

                                          ;* 16: 640x350/16 graf
         dw        640,350
         db        4,0
         dw        ReadEGA

                                          ;* 17: 640x480/2 graf
         dw        640,480
         db        1,0
         dw        ReadEGA

                                          ;* 18: 640x480/16 graf
         dw        640,480
         db        4,0
         dw        ReadEGA

                                          ;* 19: 320x200/256 graf
         dw        320,200
         db        8,4
         dw        ReadMCG

STabInc  label     byte                     ; tabulka p©¡rustk– adres © dk–
         db        80/2                     ; 0: 40x25 text
         db        80/2                     ; 1: 40x25 text
         db        160/2                    ; 2: 80x25 text
         db        160/2                    ; 3: 80x25 text
         db        80/2                     ; 4: 320x200/4 graf
         db        80/2                     ; 5: 320x200/4 graf
         db        80/2                     ; 6: 640x200/2 graf
         db        160/4                    ; 7: 80x25 text
         db        40/2                     ; 13: 320x200/16 graf
         db        80/2                     ; 14: 640x200/16 graf
         db        80/2                     ; 15: 640x350/2 graf
         db        80/2                     ; 16: 640x350/16 graf
         db        80/2                     ; 17: 640x480/2 graf
         db        80/2                     ; 18: 640x480/16 graf
         db        320/2                    ; 19: 320x200/256 graf

Buffer   label     byte                     ; diskov˜ buffer

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;               Start programu, instalace sn¡ma‡e obrazovky
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;þ
; ------ test, zda je program nainstalov n v pamˆti

Instal:  mov       ah,0fh
         mov       bx,IDENT1
         mov       cx,IDENT2
         mov       dx,IDENT3
         int       10h                      ; dotaz na instalaci programu
         mov       ax,es                    ; navr cen˜ segment ?
         mov       cx,cs
         cmp       ax,cx                    ; byl segment zmˆnˆn ?
         je        Instal10                 ; nebyl zmˆnˆn
         cmp       bx,IDENT4                ; je nainstalov n ?
         jne       Instal10                 ; nen¡ nainstalov n
         cmp       word ptr es:[Identif],"DG" ; souhlas¡ identifik tor ?
         je        Instal11                 ; je nainstalov n OK
Instal10:or        byte ptr ds:[SParam],10h ; p©¡znak prvn¡ instalace
         push      cs
         pop       es                       ; ES <- CS
Instal11:mov       ds:[RezSegm],es          ; segment rezidentn¡ho programu

; ------ test, zda je videokarta EGA/VGA

         mov       ah,12h
         mov       bx,0ff10h
         int       10h                      ; test instalace karty EGA/VGA
         cmp       bh,1                     ; m¢d displeje
         ja        Instal2                  ; nen¡ karta EGA/VGA
         cmp       bl,5                     ; pamˆŸ
         ja        Instal2                  ; nen¡ karta EGA/VGA

; ------ test, zda je videokarta VGA

         mov       byte ptr ds:[Card],3     ; p©ednastaven¡ - karta EGA
         mov       ax,1a00h
         int       10h                      ; dotaz na instalaci videokarty
         cmp       al,1ah                   ; je funkce obsluhovan  ?
         jne       Instal3                  ; funkce nen¡ obsluhovan 
         cmp       bl,7
         je        Instal1                  ; je karta VGA
         cmp       bl,8
         je        Instal1                  ; je karta VGA
         cmp       bl,11
         je        Instal1                  ; je karta VGA
         cmp       bl,12
         jne       Instal3                  ; nen¡ karta VGA
Instal1: mov       byte ptr ds:[Card],4     ; je karta VGA
         jmp       short Instal3

; ------ test, zda je videokarta CGA

Instal2: xor       ax,ax
         mov       es,ax                    ; ES <- 0
         mov       byte ptr ds:[Card],1     ; karta Hercules
         cmp       word ptr es:[463h],3b4h  ; je karta Hercules ?
         je        Instal3                  ; je karta Hercules
         mov       byte ptr ds:[Card],2     ; jinak je karta CGA

; ------ dek¢dov n¡ zadan˜ch parametr–

Instal3: mov       es,ds:[RezSegm]          ; rezidentn¡ segment
         call      Rozbor                   ; dek¢dov n¡ zadan˜ch parametr–
         jnc       Instal4                  ; zad n¡ parametr– OK

; ------ chyba

         mov       dx,offset HlpTxt         ; text n povˆdy
Chyba:   push      dx
         mov       dx,offset UvTxt          ; £vodn¡ text
         mov       ah,9
         int       21h                      ; zobrazen¡ £vodn¡ho textu
         pop       dx
         mov       ah,9
         int       21h                      ; zobrazen¡ textu chyby
         int       20h

; ------ instalace programu

Instal4: test      byte ptr ds:[SParam],4   ; po‘aduje se instalace ?
         jz        Instal5                  ; nepo‘aduje se instalace
         mov       dx,offset NicTxt
         test      byte ptr ds:[SParam],10h ; je prvn¡ instalace ?
         jz        Chyba                    ; nen¡ prvn¡ instalace - konec
         jmp       Inst                     ; prvn¡ instalace programu

; ------ odinstalov n¡ programu

Instal5: test      byte ptr ds:[SParam],8   ; je po‘adavek odinstalov n¡ ?
         jz        Instal6                  ; nepo‘aduje se odinstalov n¡
         mov       dx,offset NenITxt        ; text - nebyl nainstalov n
         test      byte ptr ds:[SParam],10h ; je prvn¡ instalace ?
         jnz       Chyba                    ; nen¡ nainstalov n - chyba
         call      TestDIns                 ; test, zda lze odinstalovat
         mov       dx,offset NelzeTxt       ; text - nelze odinstalovat
         jc        Chyba                    ; chyba - nelze odinstalovat
         jmp       OdInst                   ; odinstalov n¡ programu z pamˆti

; ------ £schova aktu ln¡ho ‡asu

Instal6: push      ds
         xor       ax,ax
         mov       ds,ax
         mov       ax,ds:[46ch]
         pop       ds
         mov       ds:[LastTime],ax

; ------ korekce velikosti datov‚ho bloku programu

         push      ds
         pop       es
         mov       sp,offset Zasobnik       ; p©edefinov n¡ z sobn¡ku
         mov       bx,offset(Zasobnik-Start+10fh)/16 ; velikost programu
         mov       ah,4ah
         int       21h                      ; nastaven¡ velikosti bloku
Instal62:mov       dx,offset MemTxt         ; text - nedostatek pamˆti
         jc        Chyba                    ; chyba - nedostatek pamˆti

; ------ vytvo©en¡ datov‚ho bloku

         mov       bx,0ffffh
         mov       ah,48h
         int       21h
         mov       ah,48h
         int       21h                      ; p©idˆlen¡ maxim ln¡ho bloku
         jc        Instal62                 ; nedostatek pamˆti
         cmp       bx,100h
         jb        Instal62                 ; buffer je p©¡li¨ mal˜
         mov       ds:[DatSegm],ax          ; adresa bufferu
         mov       ds:[SoubSegm],ax
         mov       ds:[DatSize],bx          ; velikost bufferu
         cmp       bx,1000h
         jb        Instal63
         mov       bx,0fffh
Instal63:mov       cl,4
         shl       bx,cl                    ; p©epo‡et na bajty
         mov       ds:[SoubSize],bx         ; velikost bufferu pro soubor

; ------ zobrazen¡ souboru

         cmp       byte ptr ds:[SoubView],0 ; byl zad n soubor ?
         je        Instal7                  ; nebyl zad n soubor
         jmp       View                     ; obsluha prohl¡‘e‡e souboru

; ------ re‘im demonstrace

Instal7: test      byte ptr ds:[SParam],40h ; je re‘im demonstrace ?
         jz        Instal8                  ; nen¡ re‘im demonstrace
         jmp       Demo                     ; demonstrace

; ------ bylo pouze nastaven¡ parametr– - konec programu

Instal8: int       20h

; -----------------------------------------------------------------------------
;        instalace programu
; -----------------------------------------------------------------------------

Inst:

; ------ nastaven¡ aktivn¡ho disku do jm‚na souboru

         mov       ah,19h
         int       21h                      ; poskytnut¡ aktivn¡ho disku
         add       byte ptr ds:[Soubor],al  ; ozna‡en¡ aktivn¡ho disku

; ------ na‡ten¡ aktivn¡ho adres ©e

         mov       ah,47h                   ; funkce poskytnut¡ adres ©e
         mov       dl,0                     ; aktivn¡ disk
         mov       si,offset Soubor + 3     ; buffer k na‡ten¡ adres ©e
         int       21h                      ; poskytnut¡ aktivn¡ho adres ©e

; ------ nalezen¡ konce cesty adres ©e

         dec       si                       ; p©ednastaven¡ ukazatele
Inst3:   inc       si                       ; zv˜¨en¡ ukazatele adres ©e
         cmp       byte ptr ds:[si],0       ; je konec jm‚na adres ©e ?
         jne       Inst3                    ; nalezen¡ konce adres ©e

; ------ zaji¨tˆn¡ koncov‚ho znaku "\"

         cmp       byte ptr ds:[si-1],"\"   ; je to z kladn¡ adres © ?
         je        Inst4                    ; je to z kladn¡ adres ©
         mov       byte ptr ds:[si],"\"     ; ozna‡en¡ konce adres ©e
         inc       si                       ; p©esko‡en¡ znaku "\"

; ------ p©id n¡ jm‚na souboru

Inst4:   mov       di,si                    ; adresa k ulo‘en¡ jm‚na souboru
         mov       si,offset Soubor0        ; jm‚no souboru
         mov       cx,offset(Soubor1-Soubor0) ; d‚lka jm‚na souboru
         push      cs
         pop       es                       ; ES <- CS
         cld
         rep       movsb                    ; p©enos jm‚na souboru

; ------ adresa ‡¡sla souboru

         sub       di,6                     ; adresa konce ‡¡sla
         mov       ds:[AdrSoub],di          ; adresa ‡¡sla souboru

; ------ zobrazen¡ £vodn¡ho textu

         mov       dx,offset UvTxt          ; £vodn¡ text
         mov       ah,9
         int       21h                      ; zobrazen¡ £vodn¡ho textu

; ------ hl ¨en¡ o instalaci do pamˆti

         mov       dx,offset InstTxt        ; text - byl nainstalov n
         mov       ah,9
         int       21h                      ; hl ¨en¡ o instalaci

; ------ £schova adresy obsluhy INT 08h

         cli
         mov       ax,3508h
         int       21h                      ; poskytnut¡ adresy INT 08h
         mov       word ptr ds:[Old08],bx   ; offset INT 08h
         mov       word ptr ds:[Old08+2],es ; segment INT 08h

; ------ £schova adresy obsluhy INT 09h

         mov       ax,3509h
         int       21h                      ; poskytnut¡ adresy INT 09h
         mov       word ptr ds:[Old09],bx   ; offset INT 09h
         mov       word ptr ds:[Old09+2],es ; segment INT 09h

; ------ £schova adresy obsluhy INT 10h

         mov       ax,3510h
         int       21h                      ; poskytnut¡ adresy INT 10h
         mov       word ptr ds:[Old10],bx   ; offset INT 10h
         mov       word ptr ds:[Old10+2],es ; segment INT 10h

; ------ £schova adresy obsluhy INT 28h

         mov       ax,3528h
         int       21h                      ; poskytnut¡ adresy INT 28h
         mov       word ptr ds:[Old28],bx   ; offset INT 28h
         mov       word ptr ds:[Old28+2],es ; segment INT 28h

; ------ £schova adresy obsluhy INT n

         mov       al,ds:[NumInt]
         mov       ah,35h
         int       21h                      ; poskytnut¡ adresy INT n
         mov       word ptr ds:[OldInt],bx   ; offset INT n
         mov       word ptr ds:[OldInt+2],es ; segment INT n

; ------ instalace obsluhy INT 08h

         mov       dx,offset Int08          ; adresa obsluhy INT 08h
         mov       ax,2508h
         int       21h                      ; instalace obsluhy INT 08h

; ------ instalace obsluhy INT 09h

         mov       dx,offset Int09          ; adresa obsluhy INT 09h
         mov       ax,2509h
         int       21h                      ; instalace obsluhy INT 09h

; ------ instalace obsluhy INT 10h

         mov       dx,offset Int10          ; adresa obsluhy INT 10h
         mov       ax,2510h
         int       21h                      ; instalace obsluhy INT 10h

; ------ instalace obsluhy INT 28h

         mov       dx,offset Int28          ; adresa obsluhy INT 28h
         mov       ax,2528h
         int       21h                      ; instalace obsluhy INT 28h

; ------ instalace obsluhy INT n

         mov       dx,offset IntInt         ; adresa obsluhy INT n
         mov       al,ds:[NumInt]
         mov       ah,25h
         int       21h                      ; instalace obsluhy INT n

; ------ instalace p©¡znaku aktivity DOS

         mov       bx,-1                    ; BX <- 0ffffh nepovolen  hodnota
         mov       es,bx                    ; ES <- 0ffffh nepovolen  hodnota
         mov       ah,34h
         int       21h                      ; poskytnut¡ p©¡znaku aktivity DOS
         mov       ax,es
         inc       ax                       ; m  ES povolenou hodnotu ?
         jnz       Inst2                    ; ES je definov no OK
         mov       bx,es                    ; ES i BX maj¡ hodnotu 0ffffh
Inst2:   mov       word ptr [Aktiv21],bx    ; adresa p©¡znaku aktivity DOS
         mov       word ptr [Aktiv21+2],es  ; segment p©¡znaku aktivity DOS
         sti                                ; povolen¡ p©eru¨en¡

; ------ uvolnˆn¡ segmentu prost©ed¡

         mov       es,ds:[2ch]              ; adresa prost©ed¡
         mov       ah,49h
         int       21h                      ; uvolnˆn¡ segmentu prost©ed¡

; ------ instalace programu do pamˆti

         mov       dx,offset(Instal+BufSize) ; konec programu
         int       27h                      ; instalace jako rezidentn¡

; -----------------------------------------------------------------------------
;        odinstalov n¡ programu z pamˆti
; -----------------------------------------------------------------------------

OdInst:  cli
         mov       es,ds:[RezSegm]          ; rezidentn¡ segment
         push      ds

; ------ n vrat adresy INT 08h

         lds       dx,es:[Old08]            ; p–vodn¡ adresa INT 08h
         mov       ax,2508h
         int       21h                      ; n vrat adresy INT 08h

; ------ n vrat adresy INT 09h

         lds       dx,es:[Old09]            ; p–vodn¡ adresa INT 09h
         mov       ax,2509h
         int       21h                      ; n vrat adresy INT 09h

; ------ n vrat adresy INT 10h

         lds       dx,es:[Old10]            ; p–vodn¡ adresa INT 10h
         mov       ax,2510h
         int       21h                      ; n vrat adresy INT 10h

; ------ n vrat adresy INT 28h

         lds       dx,es:[Old28]            ; p–vodn¡ adresa INT 28h
         mov       ax,2528h
         int       21h                      ; n vrat adresy INT 28h

; ------ n vrat adresy INT n

         lds       dx,es:[OldInt]           ; p–vodn¡ adresa INT n
         mov       al,es:[NumInt]
         mov       ah,25h
         int       21h                      ; n vrat adresy INT n

         pop       ds
         sti

; ------ uvolnˆn¡ segmentu bloku pamˆti

         mov       ah,49h
         int       21h                      ; uvolnˆn¡ bloku pamˆti

; ------ hl ¨en¡ o odinstalov n¡ z pamˆti

         mov       dx,offset OdInsTxt       ; text - byl odinstalov n
         jmp       Chyba                    ; hl ¨en¡, ‘e byl odinstalov n

; -----------------------------------------------------------------------------
;        test, zda lze program odinstalovat (CY=nelze)
; -----------------------------------------------------------------------------

TestDIns PROC      NEAR

; ------ test adresy obsluhy INT 08h

         mov       ax,3508h
         int       21h                      ; poskytnut¡ adresy INT 08h
         mov       ax,es                    ; segment adresy obsluhy
         cmp       ax,ds:[RezSegm]          ; souhlas¡ adresa ?
         jne       TstDIns8                 ; nesouhlas¡ - nelze odinstalovat

; ------ test adresy obsluhy INT 09h

         mov       ax,3509h
         int       21h                      ; poskytnut¡ adresy INT 09h
         mov       ax,es                    ; segment adresy obsluhy
         cmp       ax,ds:[RezSegm]          ; souhlas¡ adresa ?
         jne       TstDIns8                 ; nesouhlas¡ - nelze odinstalovat

; ------ test adresy obsluhy INT 10h

         mov       ax,3510h
         int       21h                      ; poskytnut¡ adresy INT 10h
         mov       ax,es                    ; segment adresy obsluhy
         cmp       ax,ds:[RezSegm]          ; souhlas¡ adresa ?
         jne       TstDIns8                 ; nesouhlas¡ - nelze odinstalovat

; ------ test adresy obsluhy INT n

         mov       es,ds:[RezSegm]
         mov       al,es:[NumInt]
         mov       ah,35h
         int       21h                      ; poskytnut¡ adresy INT n
         mov       ax,es                    ; segment adresy obsluhy
         cmp       ax,ds:[RezSegm]          ; souhlas¡ adresa ?
         jne       TstDIns8                 ; nesouhlas¡ - nelze odinstalovat

; ------ test adresy obsluhy INT 28h

         mov       ax,3528h
         int       21h                      ; poskytnut¡ adresy INT 28h
         mov       ax,es                    ; segment adresy obsluhy
         cmp       ax,ds:[RezSegm]          ; souhlas¡ adresa ?
         je        TstDIns9                 ; souhlas¡ - lze odinstalovat OK

TstDIns8:stc                                ; p©¡znak chyby - nelze odinstalovat
TstDIns9:ret

TestDIns ENDP

; -----------------------------------------------------------------------------
;        rozbor zadan˜ch parametr– (DS=datov˜ segment, ES=rezidentn¡ program)
; -----------------------------------------------------------------------------

Rozbor   PROC      NEAR

; ------ p©¡prava p©¡kazov‚ho © dku

         mov       si,81h                   ; za‡ tek p©¡kazov‚ho © dku
         mov       bl,ds:[si-1]             ; d‚lka p©¡kazov‚ho © dku
         and       bx,7fh
         mov       ds:[si+bx],bh            ; ozna‡en¡ konce p©¡kazov‚ho © dku

; ------ test, zda je nˆco zad no (nen¡-li nic, je re‘im demonstrace)

         call      RozbSpc                  ; vypu¨tˆn¡ mezer z p©¡kaz. © dku
;         jnc       Rozbor2                  ; je nˆco zad no
         or        byte ptr ds:[SParam],40h ; je re‘im demonstrace
Rozbor1: ret

; ------ test, zda je parametr

Rozbor2: call      RozbCh                   ; znak z bufferu
         cmp       al,"/"                   ; je parametr ?
         je        Rozbor21                 ; je parametr
         jmp       Rozbor8                  ; nen¡ parametr

; ------ na‡ten¡ znaku parametru

Rozbor21:call      RozbSpc                  ; vypu¨tˆn¡ mezer
         jc        Rozbor1                  ; nen¡ dal¨¡ znak - chyba
         call      RozbCh                   ; na‡ten¡ dal¨¡ho znaku

; ------ parametry "/Cn", "/En", "/V" - volba palet CGA, EGA, VGA

         mov       cl,0
         cmp       al,"C"
         je        Rozbor26                 ; je volba palet CGA
         mov       cl,2
         cmp       al,"E"
         je        Rozbor26                 ; je volba palet EGA
         mov       cl,4
         cmp       al,"V"
         jne       Rozbor28                 ; nen¡ volba palet
Rozbor26:call      RozbCh                   ; dal¨¡ znak
         jc        Rozbor1                  ; nen¡ dal¨¡ znak - chyba
         mov       ah,1
         cmp       al,"+"
         je        Rozbor27                 ; v‘dy
         mov       ah,0
         cmp       al,"-"
         je        Rozbor27                 ; nikdy
         mov       ah,2
         cmp       al,"*"
         stc
         jne       Rozbor1                  ; chyba zad n¡
Rozbor27:mov       al,3
         shl       ax,cl
         not       al
         and       byte ptr es:[SParam2],al
         or        byte ptr es:[SParam2],ah
         jmp       short Rozbr289

; ------ parametr "/P" - sn¡ma‡ je aktivn¡ bez testu portu

Rozbor28:cmp       al,"P"
         jne       Rozbr282
         and       byte ptr es:[SParam2],not 40h ; zak z n p©¡stup k portu
         or        byte ptr es:[SParam],20h ; p©¡znak aktivity sn¡ma‡e
         jmp       short Rozbr289

; ------ parametr "/#n" - instalace s obsluhou p©eru¨en¡ INT n

Rozbr282:cmp       al,"#"
         jne       Rozbr288
         call      RozbSpc
         call      RozbHx                   ; vztup znaku HEX
         jnc       Rozbr283
         ret
Rozbr283:mov       byte ptr ds:[NumInt],al
         mov       ah,al
         or        byte ptr ds:[SParam],4   ; p©¡znak po‘adavku instalace
         call      RozbHx
         jc        Rozbr289
         mov       cl,4
         shl       ah,cl
         or        al,ah
         mov       ds:[NumInt],al
Rozbr289:jmp       short Rozbor77

; ------ parametr "/A" - sn¡ma‡ je aktivn¡

Rozbr288:cmp       al,"A"
         jne       Rozbor29
         or        byte ptr es:[SParam2],40h ; povolen p©¡stup k portu
         or        byte ptr es:[SParam],20h ; p©¡znak aktivity sn¡ma‡e
         jmp       short Rozbor77

; ------ parametr "/Mn" - p©ednastaven¡ videom¢du

Rozbor29:cmp       al,"M"
         jne       Rozbr292
         and       byte ptr es:[SParam3],not 1 ; automatick˜ videom¢d
         call      RozbNum                  ; dek¢dov n¡ ‡¡sla
         jc        Rozbor77
         cmp       ax,19
         ja        Rozbor77
         or        byte ptr es:[SParam3],1
         mov       es:[VMod],al
         jmp       short Rozbor77

; ------ parametr "/X" - sn¡ma‡ je neaktivn¡

Rozbr292:cmp       al,"X"
         jne       Rozbor2a
         and       byte ptr es:[SParam2],not 40h; z kaz p©¡stupu k portu
         and       byte ptr es:[SParam],not 20h ; zru¨en¡ p©¡znaku aktivity
         jmp       short Rozbor77

; ------ parametr /"text" - koment © souboru SCR

Rozbor2a:cmp       al,"'"
         je        Rozbr2a0
         cmp       al,34
         jne       Rozbor2b
Rozbr2a0:mov       ah,al
         mov       di,offset Koment
         cld
Rozbr2a1:lodsb
         cmp       al,9
         je        Rozbr2a2
         cmp       al,ah
         je        Rozbr2a3
         cmp       al,0
         je        Rozbr2a3
         cmp       al,13
         je        Rozbr2a3
Rozbr2a2:stosb
         jmp       short Rozbr2a1
Rozbr2a3:sub       di,offset Koment
         mov       ds:[KomentN],di          ; d‚lka textu koment ©e
Rozbor77:jmp       short Rozbor7

; ------ parametr "/I" - instalace programu

Rozbor2b:cmp       al,"I"                   ; je parametr "/I" ?
         jne       Rozbor3                  ; nen¡ parametr "/I"
         or        byte ptr ds:[SParam],4   ; p©¡znak po‘adavku instalace
         jmp       short Rozbor7            ; p©¡prava dal¨¡ho parametru

; ------ parametr "/!" - odinstalov n¡ programu

Rozbor3: cmp       al,"!"                   ; je parametr "/!" ?
         jne       Rozbor4                  ; nen¡ parametr "/!"
         or        byte ptr ds:[SParam],8   ; p©¡znak po‘adavku odinstalov n¡
         jmp       short Rozbor7            ; p©¡prava dal¨¡ho parametru

; ------ parametr "/K" - kompresn¡ m¢d

Rozbor4: cmp       al,"K"                   ; je parametr "/K" ?
         jne       Rozbor5                  ; nen¡ parametr "/K"
         or        byte ptr es:[Param],1    ; p©¡znak komprese
         and       byte ptr es:[SParam2],not 80h ; vypnut¡ testovac¡ho re‘imu
         or        byte ptr ds:[SParam],4   ; p©¡znak po‘adavku instalace
         jmp       short Rozbor7            ; p©¡prava dal¨¡ho parametru

; ------ parametr "/N" - nekompresn¡ m¢d

Rozbor5: cmp       al,"N"                   ; je parametr "/N" ?
         jne       Rozbor6                  ; nen¡ parametr "/N"
         and       byte ptr es:[Param],not 1 ; zru¨en¡ p©¡znaku komprese
         and       byte ptr es:[SParam2],not 80h ; vypnut¡ testovac¡ho re‘imu
         or        byte ptr ds:[SParam],4   ; p©¡znak po‘adavku instalace
         jmp       short Rozbor7            ; p©¡prava dal¨¡ho parametru

; ------ parametr "/T" - testovac¡ m¢d

Rozbor6: cmp       al,"T"
         jne       Rozbor61
         or        byte ptr es:[SParam2],80h ; testovac¡ re‘im
         jmp       short Rozbor7

; ------ parametr "/B" - netestovat p©¡znak DOS

Rozbor61:cmp       al,"B"
         jne       Rozbor62
         or        byte ptr es:[SParam3],2  ; netestovat DOS
         jmp       short Rozbor7

; ------ parametr "/cislo" - ‡asovan‚ ukl d n¡

Rozbor62:dec       si                       ; n vrat znaku
         call      RozbNum                  ; vstup zad n¡ ‡¡sla
         jc        Rozbor72                 ; chyba zad n¡
         or        byte ptr ds:[SParam],4   ; p©¡znak po‘adavku instalace
         mov       es:[SDelay],ax           ; prodleva ‡asov‚ho sn¡m n¡
         or        ax,ax                    ; je vypnut¡ funkce ?
         jnz       Rozbor7                  ; nen¡ vypnut¡
         and       byte ptr es:[SParam],not 80h ; vypnut¡ funkce sn¡m n¡
         mov       word ptr es:[SCitac],0   ; nulov n¡ ‡¡ta‡e prodlevy

; ------ test, zda je dal¨¡ parametr

Rozbor7: call      RozbSpc                  ; test, zda je nˆco je¨tˆ zad no
         jc        Rozbor71
         jmp       Rozbor2                  ; je dal¨¡ parametr
Rozbor71:clc                                ; p©¡znak operace OK
Rozbor72:ret

; ------ test nepovolen˜ch znak– souboru (asi chce zobrazen¡ n povˆdy)

Rozbor8: cmp       al,'"'
         je        Rozbor88
         cmp       al,"*"
         je        Rozbor88
         cmp       al,"."
         je        Rozbor88
         cmp       al,":"
         je        Rozbor88
         cmp       al,";"
         je        Rozbor88
         cmp       al,","
         je        Rozbor88
         cmp       al,"?"                   ; je dotaz na n povˆdu ?
Rozbor88:stc
         je        Rozbor72                 ; po‘adavek n povˆdy

; ------ rozbor zad n¡ souboru

         mov       di,offset SoubView       ; soubor pro prohl¡‘e‡
Rozbor9: mov       ds:[di],al               ; ulo‘en¡ znaku do bufferu
         inc       di                       ; zv˜¨en¡ ukl dac¡ adresy
         cmp       byte ptr ds:[si],"/"     ; bude parametr ?
         je        Rozbor92                 ; bude parametr - konec
         call      RozbCh                   ; dal¨¡ znak jm‚na souboru
         ja        Rozbor9                  ; je dal¨¡ znak - ulo‘en¡ znaku
Rozbor92:mov       byte ptr ds:[di],0       ; ozna‡en¡ konce jm‚na souboru
         jmp       short Rozbor7            ; test, zda je dal¨¡ parametr

Rozbor   ENDP

; -----------------------------------------------------------------------------
;        vstup znaku HEX
; -----------------------------------------------------------------------------

RozbHx   PROC      NEAR

         call      RozbCh
         jc        RozbHx4
         cmp       al,"0"
         jb        RozbHx3
         cmp       al,"9"
         jbe       RozbHx2
         cmp       al,"A"
         jb        RozbHx3
         cmp       al,"F"
         ja        RozbHx3

         sub       al,6

RozbHx2: sub       al,"0"
         ret

RozbHx3: dec       si
         stc
RozbHx4: ret

RozbHx   ENDP

; -----------------------------------------------------------------------------
;        vstup ‡¡sla AX
; -----------------------------------------------------------------------------

RozbNum  PROC      NEAR

; ------ £schova registr–

         push      cx
         push      dx

; ------ p©¡prava registr–

         xor       cx,cx                    ; nulov n¡ st©ada‡e ‡¡sla

; ------ test, zda je nˆjak  ‡¡slice

         call      RozbSpc                  ; vypu¨tˆn¡ mezer
         call      RozbNm                   ; test, zda je prvn¡ ‡¡slice
         jc        RozbNum9                 ; nen¡ platn‚ ‡¡slo

; ------ dek¢dov n¡ ‡¡sla

RozbNum1:push      ax                       ; £schova ‡¡sla
         mov       ax,10                    ; n sobitel st©ada‡e
         mul       cx                       ; vyn soben¡ st©ada‡e 10x
         pop       cx                       ; nov  ‡¡slice
         or        dx,dx                    ; je p©ete‡en¡ ‡¡sla ?
         jnz       RozbNum2                 ; je p©ete‡en¡ ‡¡sla
         mov       ch,0
         add       cx,ax                    ; p©i‡ten¡ nov‚ ‡¡slice
         jnc       RozbNum3                 ; nen¡ p©ete‡en¡
RozbNum2:mov       cx,0ffffh                ; omezen¡ ‡¡sla p©i p©ete‡en¡
RozbNum3:call      RozbNm                   ; na‡ten¡ dal¨¡ ‡¡slice
         jnc       RozbNum1                 ; je dal¨¡ ‡¡slice OK
         clc                                ; p©¡znak operace OK

; ------ n vrat registr–

RozbNum9:xchg      ax,cx                    ; AX <- na‡ten‚ ‡¡slo
         pop       dx
         pop       cx
         ret

RozbNum  ENDP

; -----------------------------------------------------------------------------
;        vstup jedn‚ ‡¡slice AL
; -----------------------------------------------------------------------------

RozbNm   PROC      NEAR

         call      RozbCh                   ; vstup znaku z p©¡kazov‚ho © dku
         jc        RozbNm2                  ; nen¡ dal¨¡ znak
         cmp       al,"0"                   ; je platn˜ znak ?
         jb        RozbNm1                  ; nen¡ platn˜ znak
         cmp       al,"9"+1
         cmc
         jc        RozbNm1                  ; neplatn˜ znak
         sub       al,"0"                   ; ‡¡slo
         ret

RozbNm1: dec       si                       ; n vrat neplatn‚ho znaku
RozbNm2: ret

RozbNm   ENDP

; -----------------------------------------------------------------------------
;        vypu¨tˆn¡ mezer z p©¡kazov‚ho © dku
; -----------------------------------------------------------------------------

RozbSpc  PROC      NEAR

         call      RozbCh                   ; vstup znaku z p©¡kazov‚ho © dku
         jc        RozbSpc3                 ; nen¡ dal¨¡ znak
         je        RozbSpc                  ; vypu¨tˆn¡ mezery
         dec       si
RozbSpc3:ret

RozbSpc  ENDP

; -----------------------------------------------------------------------------
;        vstup znaku z p©¡kazov‚ho © dku
; -----------------------------------------------------------------------------

RozbCh   PROC      NEAR

; ------ na‡ten¡ znaku

         cld
         lodsb

; ------ n hrada tabel toru mezerou

         cmp       al,9
         jne       RozbCh1
         mov       al," "

; ------ konverze na velk‚ p¡smeno

RozbCh1: cmp       al,"a"
         jb        RozbCh2
         cmp       al,"z"
         ja        RozbCh2
         sub       al,32

; ------ test, zda je konec © dku

RozbCh2: cmp       al," "
         jae       RozbCh3                  ; je platn˜ znak
         dec       si                       ; n vrat konce © dku
RozbCh3: ret

RozbCh   ENDP

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                          Demonstrace programu
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

;þ

; ------ test verze syst‚mu

Demo:    push      ds
         pop       es
         mov       ah,30h
         int       21h                      ; poskytnut¡ verze syst‚mu
         cmp       al,3                     ; je alespo¤ 3.xx ?
         jb        Demo17                   ; n¡zk  verze syst‚mu

; ------ p©¡prava jm‚na souboru

         mov       cx,ds:[2ch]              ; adresa prost©ed¡
         jcxz      Demo17                   ; nedefinov no
         push      ds
         mov       ds,cx                    ; segment prost©ed¡
         xor       si,si                    ; po‡ tek
         xor       ax,ax                    ; hledan‚ slovo
Demo12:  inc       si
         cmp       ds:[si-1],ax
         jne       Demo12
         add       si,3
         mov       di,offset SoubDemo
         cld
Demo14:  lodsb
         stosb
         cmp       al,0
         jne       Demo14
         cmp       byte ptr es:[di-5],"."   ; m  p©¡ponu OK ?
         jne       Demo16                   ; nen¡ p©¡pona
         sub       di,5
Demo16:  mov       ax,"D."
         stosw
         mov       ax,"TA"
         stosw
         mov       al,0
         stosb
         pop       ds

; ------ otev©en¡ datov‚ho souboru

Demo17:  mov       dx,offset SoubDemo       ; jm‚no souboru
         mov       ax,3d00h
         int       21h                      ; otev©en¡ souboru
         jnc       Demo18                   ; soubor otev©en OK
         mov       dx,offset DemoErr
         jmp       Chyba

; ------ na‡ten¡ souboru do pamˆti

Demo18:  mov       bx,ax                    ; identifik tor souboru
         mov       cx,ds:[DatSize]          ; velikost datov‚ho bufferu
         jcxz      Demo19
         dec       cx
         cmp       cx,1000h
         jb        Demo19
         mov       cx,0fffh
Demo19:  shl       cx,1
         shl       cx,1
         shl       cx,1
         shl       cx,1
         mov       ah,3fh
         xor       dx,dx
         push      ds
         mov       ds,ds:[DatSegm]
         int       21h                      ; na‡ten¡ souboru do bufferu
         jnc       Demo1a
         xor       ax,ax
Demo1a:  mov       si,ax
         mov       byte ptr ds:[si],0       ; ozna‡en¡ konce dat
         pop       ds
         mov       ds:[DatNum],ax           ; velikost souboru

; ------ oprava bufferu souboru

         add       ax,15
         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1
         add       ds:[SoubSegm],ax         ; adresa segmentu souboru
         mov       cx,ds:[DatSize]          ; velikost bufferu
         sub       cx,ax                    ; zbyl  velikost
         cmp       cx,1000h
         jb        Demo1b
         mov       cx,0fffh
Demo1b:  shl       cx,1
         shl       cx,1
         shl       cx,1
         shl       cx,1
         mov       ds:[SoubSize],cx         ; velikost bufferu souboru

; ------ uzav©en¡ souboru

         mov       ah,3eh
         int       21h

; ------ instalace INT 23h

         mov       dx,offset INT23
         mov       ax,2523h
         int       21h                      ; instalace INT 23h

; ------ £schova aktivn¡ho videom¢du

Demo2:   mov       ah,0fh
         int       10h
         mov       ds:[OldVMod],al          ; p–vodn¡ aktivn¡ videom¢d

; ------ p©¡prava k intepretaci programu

         xor       si,si

; ------ nalezen¡ za‡ tku textu

Demo3:   call      DemoSpc                  ; za‡ tek textu
         call      DemoChr
         jnc       Demo32                   ; nalezen za‡ tek textu
         inc       si
         cmp       al,0
         jne       Demo3                    ; dal¨¡ © dek
         jmp       Demo9                    ; konec textu

; ------ pozn mka se ignoruje

Demo32:  cmp       al,";"
         jne       Demo34
Demo33:  call      DemoChr
         jnc       Demo33
         jmp       short Demo3

; ------ nen¡-li te‡ka, je to soubor

Demo34:  cmp       al,"."
         je        Demo4                    ; je to te‡ka
         push      ds
         pop       es
         mov       di,offset SoubView
         mov       cx,120
         cld
Demo35:  stosb
         call      DemoChr
         jbe       Demo36
         loop      Demo35
Demo36:  mov       al,0
         stosb

         push      si
         call      OpenFile
         pop       si
         jc        Demo33
         push      si
         call      DispSCR
         pop       si
         mov       ds:[LastDemo],si         ; adresa posledn¡ho souboru

;; ------ krok zpˆt
;
;         cmp       byte ptr ds:[ParamBS],0  ; je krok zpˆt ?
;         je        Demo333                  ; nen¡ krok zpˆt
;
;; ------ n vrat na za‡ tek © dku
;
;Demo362: call      DemoBack                 ; p©ede¨l˜ znak
;         jc        Demo366
;         cmp       ah," "
;         jae       Demo362
;
;; ------ nalezen¡ za‡ tku dal¨¡ho © dku
;
;Demo364: call      DemoBack                 ; p©ede¨l˜ znak
;         jc        Demo366
;         cmp       ah," "
;         jae       Demo364
;         cmp       al," "
;         jb        Demo364
;
;; ------ test, zda je platn˜ © dek
;
;         push      si
;         call      DemoSpc                  ; za‡ tek textu
;         call      DemoChr                  ; prvn¡ znak
;         pop       si
;         jc        Demo366
;         cmp       al,";"
;         je        Demo364                  ; pozn mka
;         cmp       al,"."
;         je        Demo364                  ; prodleva
;Demo366: jmp       Demo3

Demo333: jmp       short Demo33

; ------ zad n¡ prodlevy

Demo4:   call      DemoNum
         jc        Demo5
         mov       ds:[DelTime],ax          ; po‘adovan  prodleva

Demo42:  call      DemoBS                   ; test p©eru¨en¡ ‡ek n¡
         jc        Demo45                   ; je p©eru¨en¡ ‡ek n¡

         push      ds
         xor       ax,ax
         mov       ds,ax
         mov       ax,ds:[46ch]
         pop       ds
         sub       ax,ds:[LastTime]
         cmp       ax,ds:[DelTime]
         jb        Demo42

Demo44:  jmp       short Demo333

; ------ krok zpˆt

Demo45:  mov       si,ds:[LastDemo]         ; adresa posledn¡ho obr zku

; ------ n vrat na za‡ tek © dku

Demo462: call      DemoBack                 ; p©ede¨l˜ znak
         jc        Demo466
         cmp       ah," "
         jae       Demo462

; ------ nalezen¡ za‡ tku dal¨¡ho © dku

Demo464: call      DemoBack                 ; p©ede¨l˜ znak
         jc        Demo466
         cmp       ah," "
         jae       Demo464
         cmp       al," "
         jb        Demo464

; ------ test, zda je platn˜ © dek

         push      si
         call      DemoSpc                  ; za‡ tek textu
         call      DemoChr                  ; prvn¡ znak
         pop       si
         jc        Demo466
         cmp       al,";"
         je        Demo464                  ; pozn mka
         cmp       al,"."
         je        Demo464                  ; prodleva
Demo466: jmp       Demo3

Demo5:

Demo8:
         jmp       Demo33


INT23:
Demo9:
         mov       al,ds:[OldVMod]          ; p–vodn¡ aktivn¡ videom¢d
         mov       ah,0
         int       10h                      ; n vrat videom¢du

         int       20h

; -----------------------------------------------------------------------------
;        obsluha testu zpˆtn‚ho kroku (CY=je p©eru¨en¡ ‡ek n¡)
; -----------------------------------------------------------------------------

DemoBS   PROC      NEAR

         push      ax
         mov       ah,0bh
         int       21h                      ; p©eru¨en¡ programu
         cmp       al,0                     ; je znak ?
         je        DemoBS2                  ; nen¡ znak
         mov       ah,8
         int       21h                      ; na‡ten¡ znaku
         mov       ah,0
         cmp       al,8                     ; je BS ?
         je        DemoBS1                  ; je p©eru¨en¡ BS

         cmp       al,0                     ; je bˆ‘n˜ znak ?
         jne       DemoBS2                  ; je bˆ‘n˜ znak

         mov       ah,8
         int       21h                      ; vstup SCAN k¢du
         cmp       al,4bh                   ; kurzor vlevo ?
         clc                                ; p©¡znak, ‘e nen¡ p©eru¨en¡
         jne       DemoBS2                  ; nen¡ p©eru¨en¡ BS

DemoBS1: ;mov       byte ptr ds:[ParamBS],1  ; p©¡znak p©eru¨en¡ BS
         stc                                ; p©¡znak p©eru¨en¡ BS

DemoBS2: pop       ax
         ret

DemoBS   ENDP

; -----------------------------------------------------------------------------
;        ‡ten¡ ‡¡sla
; -----------------------------------------------------------------------------

DemoNum  PROC      NEAR

         push      bx
         push      dx

         xor       bx,bx                    ; st©ada‡
         call      DemoSpc
         call      DemoNm
         jc        DemoNum9                 ; nen¡ ‘ dn  ‡¡slice
DemoNum1:push      ax
         mov       ax,10
         mul       bx
         pop       bx
         mov       bh,0
         add       bx,ax

         call      DemoNm
         jnc       DemoNum1
         clc

DemoNum9:xchg      ax,bx
         pop       dx
         pop       bx
         ret

DemoNum  ENDP

; -----------------------------------------------------------------------------
;        ‡ten¡ ‡¡slice
; -----------------------------------------------------------------------------

DemoNm   PROC      NEAR

         call      DemoChr
         jc        DemoNm4
         cmp       al,"0"
         jb        DemoNm3
         cmp       al,"9"
         ja        DemoNm3
         sub       al,"0"
         ret

DemoNm3: dec       si
         stc
DemoNm4: ret

DemoNm   ENDP

; -----------------------------------------------------------------------------
;        vypu¨tˆn¡ mezer
; -----------------------------------------------------------------------------

DemoSpc  PROC      NEAR

         call      DemoChr
         jc        DemoSpc3
         je        DemoSpc
         dec       si
DemoSpc3:ret

DemoSpc  ENDP

; -----------------------------------------------------------------------------
;        n vrat k p©ede¨l‚mu znaku -> AL (CY=nen¡), AH=p©edch zej¡c¡ znak
; -----------------------------------------------------------------------------

DemoBack PROC      NEAR

         xor       ax,ax                    ; AX <- 0
         or        si,si                    ; je ji‘ za‡ tek bufferu ?
         stc
         jz        DemoBck4                 ; nen¡ p©ede¨l˜ znak

         push      ds
         mov       ds,ds:[DatSegm]
         dec       si
         mov       al,ds:[si]               ; p©ede¨l˜ znak
         clc                                ; p©¡znak operace OK
         jz        DemoBck2                 ; nen¡ dal¨¡ znak
         mov       ah,ds:[si-1]             ; p©edch zej¡c¡ znak
DemoBck2:pop       ds

DemoBck4:ret

DemoBack ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ znaku z bufferu
; -----------------------------------------------------------------------------

DemoChr  PROC      NEAR

         push      ds
         mov       ds,ds:[DatSegm]
         cld
         lodsb
         cmp       al,"a"
         jb        DemoChr2
         cmp       al,"z"
         ja        DemoChr2
         sub       al,32                    ; konverze na velk‚ p¡smeno
DemoChr2:cmp       al,9
         jne       DemoChr3
         mov       al," "                   ; n hrada tabel toru mezerou
DemoChr3:cmp       al," "
         jae       DemoChr5
         dec       si                       ; n vrat konce © dku/textu
DemoChr5:pop       ds
         ret

DemoChr  ENDP

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                      Obsluha zobrazen¡ souboru
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;þ
View:

; ------ otev©en¡ zadan‚ho souboru

         call      OpenFile                 ; otev©en¡ souboru k zobrazen¡
         jnc       View2                    ; soubor otev©en OK

; ------ chyba - soubor nenalezen

         mov       dx,offset FndTxt         ; soubor nenalezen
         jmp       Chyba                    ; zobrazen¡ chybov‚ho hl ¨en¡

; ------ test, zda je pouze nastaven¡ koment ©e

View2:   cmp       byte ptr ds:[KomentN],-1 ; byl zad n koment © ?
         je        View21                   ; nebyl koment ©
         jmp       SetKom                   ; nastaven¡ koment ©e souboru

; ------ £schova aktivn¡ho videom¢du

View21:  mov       ah,0fh
         int       10h
         mov       ds:[OldVMod],al          ; p–vodn¡ aktivn¡ videom¢d

; ------ na‡ten¡ parametr– souboru

         call      ReadHl                   ; na‡ten¡ z hlav¡ souboru
         jc        View211                  ; soubor nenalezen

; ------ p©¡prava palet displeje

         call      ReadPal                  ; na‡ten¡ palet displeje

; ------ zobrazen¡ koment ©e k souboru

         mov       si,offset Palety
         mov       cl,ds:[Komentar]         ; d‚lka textu koment ©e
         mov       ch,0
         jcxz      View2106
         mov       al,13
         call      OutChr
         cld
View2102:lodsb
         call      OutChr
         loop      View2102
         mov       al,13
         call      OutChr
         mov       al,10
         call      OutChr
         mov       ah,0
         int       16h

; ------ inicializace videom¢du

View2106:call      InitVMod                 ; inicializace videom¢du

; ------ zobrazen¡ souboru

;         mov       byte ptr ds:[ParamBS],0  ; nen¡ krok zpˆt
         call      DispSC11                 ; zobrazen¡ souboru
         jnc       View22

View211: mov       dx,offset SCRTxt
View2112:mov       ah,9
         int       21h
         int       20h

View22:  mov       ah,0
         int       16h

         mov       al,ds:[OldVMod]          ; p–vodn¡ aktivn¡ videom¢d
         mov       ah,0
         int       10h                      ; n vrat videom¢du

         int       20h

View5:   mov       dx,offset MemTxt
         jmp       short View2112

; -----------------------------------------------------------------------------
;        zobrazen¡ znaku BIOS
; -----------------------------------------------------------------------------

OutChr   PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx

         mov       bx,7
         mov       ah,0eh
         call      Int10I

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

OutChr   ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ koment ©e souboru
; -----------------------------------------------------------------------------

SetKom   PROC      NEAR

; ------ na‡ten¡ z hlav¡ souboru a palet

         call      ReadHl                   ; na‡ten¡ z hlav¡ souboru
         jc        View211                  ; chyba - neplatn˜ soubor
         call      ReadPal                  ; na‡ten¡ palet

; ------ na‡ten¡ souboru do bufferu

         mov       si,ds:[DatSegm]          ; adresa bufferu
         mov       di,ds:[DatSize]          ; velikost bufferu
SetKom1: mov       cx,800h
         cmp       cx,di
         jbe       SetKom2
         mov       cx,di
SetKom2: jcxz      View5                    ; chyba - nedostatek pamˆti
         sub       di,cx                    ; zmen¨en¡ velikosti
         shl       cx,1
         shl       cx,1
         shl       cx,1
         shl       cx,1                     ; po‡et bajt–
         mov       bx,ds:[Idents]
         mov       ah,3fh
         xor       dx,dx
         push      ds
         mov       ds,si                    ; adresa bufferu
         int       21h                      ; na‡ten¡ bloku dat ze souboru
         pop       ds
         jnc       SetKom3
         xor       ax,ax
SetKom3: add       si,800h                  ; zv˜¨en¡ adresy
         add       ds:[DatNum],ax           ; zv˜¨en¡ dat v bufferu
         adc       word ptr ds:[DatNumH],0  ; p©enos HIGH
         cmp       ax,8000h
         je        SetKom1                  ; dal¨¡ data

; ------ reset ukazatele souboru

         mov       ax,4200h
         xor       cx,cx
         xor       dx,dx
         int       21h                      ; reset ukazatele souboru

; ------ zmˆna z hlav¡ souboru

         mov       cx,ds:[KomentN]          ; nov  d‚lka koment ©e
         mov       ah,0
         mov       al,ds:[Komentar]         ; star  d‚lka koment ©e
         mov       ds:[Komentar],cl         ; nov  d‚lka koment ©e
         sub       ds:[Palet],ax            ; ode‡ten¡ star‚ho koment ©e
         add       ds:[Palet],cx            ; p©i‡ten¡ nov‚ho koment ©e

; ------ z pis nov‚ho z hlav¡

         push      ax
         push      cx
         mov       bx,ds:[Idents]
         mov       cx,offset(KonHl-Zahlavi)
         mov       ah,40h
         mov       dx,offset Zahlavi
         int       21h                      ; z pis nov‚ho z hlav¡ souboru

; ------ z pis nov‚ho koment ©e

         pop       cx
         mov       dx,offset Koment
         mov       ah,40h
         int       21h                      ; z pis nov‚ho koment ©e

; ------ z pis palet

         pop       dx                       ; d‚lka star‚ho koment ©e
         add       dx,offset Palety         ; adresa palet
         sub       cx,ds:[Palet]            ; - d‚lka palet
         neg       cx                       ; d‚lka palet
         mov       ah,40h
         int       21h                      ; z pis palet

; ------ z pis souboru

         mov       si,ds:[DatSegm]          ; datov˜ segment
SetKom4: mov       cx,8000h
         sub       word ptr ds:[DatNum],cx
         sbb       word ptr ds:[DatNumH],0
         jnc       SetKom5
         mov       cx,ds:[DatNum]
         add       cx,8000h
SetKom5: xor       dx,dx
         mov       ah,40h
         push      ds
         mov       ds,si                    ; adresa dat
         int       21h                      ; z pis dat
         pop       ds
         add       si,800h
         cmp       cx,8000h
         je        SetKom4

; ------ uzav©en¡ souboru

         mov       ah,3eh
         int       21h

         int       20h

SetKom   ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ souboru (CY=neplatn˜ soubor)
; -----------------------------------------------------------------------------

DispSCR  PROC      NEAR

; ------ na‡ten¡ parametr– souboru

         call      ReadHl                   ; na‡ten¡ z hlav¡ souboru
         jnc       DispSC10                 ; operace OK
         ret

; ------ inicializace videom¢du

DispSC10:call      InitVMod                 ; inicializace videom¢du

; ------ p©¡prava palet displeje

         call      ReadPal                  ; na‡ten¡ palet displeje

DispSC11:mov       bl,ds:[VMod]
         mov       bh,0
         cmp       bl,13h
         ja        DispSCR9
         mov       cl,ds:[bx+PageMod]       ; po‡et str nek

         mov       cx,1

         mov       ds:[PgNum],cl            ; po‡et str nek
         shl       bx,1
         mov       ax,ds:[bx+PageSize]      ; velikost str nky
         mov       ds:[PgSize],ax           ; velikost str nky
         dec       cx
         mul       cx                       ; maxim ln¡ adresa
         mov       ds:[MaxPAdr],ax          ; maxim ln¡ adresa str nky

;         mov       di,ds:[DispVRAM]         ; zobrazen  videostr nka
;         add       di,ds:[PgSize]           ; adresa dal¨¡ str nky
;         jc        DispSCR1                 ; p©ete‡en¡
;         cmp       di,ax
;         jbe       DispSCR2                 ; adresa je OK
DispSCR1:xor       di,di
DispSCR2:mov       ds:[OUtVRAM],di          ; nov  adresa str nky

         cmp       byte ptr ds:[PgNum],1    ; je jen 1 str nka ?
         ja        DispSC22                 ; je v¡ce str nek
         push      bx
         call      InitPal                  ; nastaven¡ palet displeje
         pop       bx
DispSC22:

         push      ds
         xor       si,si                    ; ‡tec¡ adresa z bufferu
         cld
         mov       bp,sp
         sub       sp,6
         mov       al,ds:[Param]
         mov       ss:[bp-1],al
         mov       al,byte ptr ds:[KompCit]
         mov       ss:[bp-2],al
         mov       al,ds:[KompChar]
         mov       ss:[bp-3],al
         mov       al,ds:[KompPar]
         mov       ss:[bp-4],al
         mov       ax,ds:[NumBuf]           ; po‡et bajt– v bufferu
         mov       ss:[bp-6],ax

; Lok ln¡ promˆnn‚:
;     SS:[BP-1] (1) Param (bit 0: 1=je komprese)
;     SS:[BP-2] (1) KompCit (‡¡ta‡ shodn‚ho bajtu)
;     SS:[BP-3] (1) KompChar (znak k opakov n¡)
;     SS:[BP-4] (1) KompPar (bit 0: 1=je komprese)
;     SS:[BP-6] (2) NumBuf (po‡et bajt– v bufferu)

         mov       di,ds:[OutVRAM]          ; adresa videopamˆti
         mov       ds,ds:[SoubSegm]         ; segment souboru
         call      word ptr cs:[bx+DispMod] ; obsluha zobrazen¡
         mov       sp,bp

         pop       ds

; ------ uzav©en¡ vstupn¡ho souboru

DispSCR9:mov       bx,ds:[Idents]
         mov       ah,3eh
         int       21h                      ; uzav©en¡ souboru k zobrazen¡

; ------ ‡ek n¡ na dosa‘en¡ ‡asu

DispSCR7:

; ------ nastaven¡ palet (pro v¡ce str nek)

DispSC72:cmp       byte ptr ds:[PgNum],1    ; je jen 1 str nka ?
         jbe       DispSC32                 ; je 1 str nka
         call      InitPal                  ; nastaven¡ palet displeje
DispSC32:

; ------ zapnut¡ aktivn¡ videostr nky

         mov       cx,ds:[OutVRAM]          ; v˜stupn¡ str nka
         mov       ds:[DispVRAM],cx         ; zobrazen  str nka

         push      ds
         xor       ax,ax
         mov       ds,ax
         mov       ds:[44eh],cx             ; adresa videostr nky
         pop       ds

         cmp       byte ptr ds:[VMod],7
         je        DispSCR3
         cmp       byte ptr ds:[VMod],3
         ja        DispSCR4
DispSCR3:shr       cx,1
DispSCR4:call      SetPage                  ; nastaven¡ adresy str nky

; ------ £schova ‡asu

         push      ds
         xor       ax,ax
         mov       ds,ax
         mov       ax,ds:[46ch]
         pop       ds
         mov       ds:[LastTime],ax         ; aktivn¡ ‡as

         clc
         ret

DispSCR  ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ adresy videostr nky CX
; -----------------------------------------------------------------------------

SetPage  PROC      NEAR

         push      ds
         xor       ax,ax
         mov       ds,ax
         mov       dx,ds:[463h]
         pop       ds

         mov       al,0ch
         out       dx,al
         inc       dx
         mov       al,ch
         out       dx,al                    ; adresa HIGH

         ret

SetPage  ENDP

; -----------------------------------------------------------------------------
;        otev©en¡ souboru k zobrazen¡ (CY=nenalezen)
; -----------------------------------------------------------------------------

OpenFile PROC      NEAR

         mov       dx,offset SoubView       ; zadan˜ soubor k zobrazen¡
         mov       ax,3d00h
         cmp       byte ptr ds:[KomentN],-1
         je        OpenFil1
         mov       al,2
OpenFil1:int       21h                      ; otev©en¡ souboru pro ‡ten¡
         jc        OpenFil2                 ; chyba - soubor nenalezen
         mov       ds:[Idents],ax           ; identifik tor souboru

         mov       word ptr ds:[KompCit],0  ; ‡¡ta‡ komprese
         mov       word ptr ds:[KompBNum],0 ; zru¨en¡ ‡¡ta‡e bajt– v bufferu
         mov       byte ptr ds:[KompPar],1  ; nastaven¡ p©¡znaku komprese
         mov       word ptr ds:[ReadBuf],0
         mov       word ptr ds:[NumBuf],0   ; v bufferu nejsou ‘ dn  data

OpenFil2:ret

OpenFile ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ z hlav¡ souboru (CY=chyba)
; -----------------------------------------------------------------------------

ReadHL   PROC      NEAR

; ------ na‡ten¡ z hlav¡ souboru

         mov       dx,offset Zahlavi        ; adresa z hlav¡ souboru
         mov       ah,3fh
         mov       bx,ds:[Idents]           ; identifik tor souboru
         mov       cx,offset(KonHl-Zahlavi) ; d‚lka z hlav¡
         int       21h                      ; na‡ten¡ z hlav¡ souboru
         jc        ReadHL2
         cmp       ax,cx
         jb        ReadHL2
         cmp       word ptr ds:[Ident],"CS"
         jne       ReadHL1
         cmp       word ptr ds:[Ident+2],1*256 + "R"
         je        ReadHL2
ReadHL1: stc
ReadHL2: ret

ReadHL   ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ palet souboru
; -----------------------------------------------------------------------------

ReadPal  PROC      NEAR

; ------ na‡ten¡ palet ze souboru

         mov       cx,ds:[Palet]            ; po‡et palet displeje
         jcxz      ReadPal3                 ; nejsou ‘ dn‚ palety
         cmp       cx,1+18+3*256+256
         jb        ReadPal1
         mov       cx,1+18+3*256+256
ReadPal1:mov       dx,offset Palety         ; buffer k na‡ten¡ palet VGA
         mov       ah,3fh
         mov       bx,ds:[Idents]           ; identifik tor souboru
         int       21h                      ; na‡ten¡ palet ze souboru
ReadPal3:ret

ReadPal  ENDP

; -----------------------------------------------------------------------------
;        inicializace palet VGA
; -----------------------------------------------------------------------------
;þ
InitPal  PROC      NEAR

; ------ p©¡prava registr–

         mov       si,offset Palety         ; buffer palet
         cld
         mov       bx,ds:[Palet]            ; po‡et bajt– palet
         mov       al,ds:[Komentar]         ; po‡et bajt– koment ©e
         mov       ah,0
         add       si,ax                    ; posun za koment ©
         sub       bx,ax
         jnc       InitPl11
         xor       bx,bx
InitPl11:

; ------ nastaven¡ palet CGA

         test      byte ptr ds:[Param],10h  ; jsou palety CGA ?
         jz        InitPal2                 ; nejsou palety CGA
         or        bx,bx
         jz        InitPal2

         lodsb
         push      ds
         xor       cx,cx
         mov       ds,cx
         mov       dx,ds:[463h]             ; port displeje
         add       dl,4                     ; adresa 3d8h
         shr       al,1                     ; p©¡znak blik n¡
         and       al,20h
         mov       ah,ds:[465h]             ; stav portu 3d8h
         and       ah,not 20h
         or        al,ah
         out       dx,al                    ; nastaven¡ blik n¡ CGA
         pop       ds

         cmp       byte ptr ds:[VMod],6
         je        InitPl14

         push      bx
         mov       bl,ds:[si-1]
         and       bl,1fh
         mov       ah,0bh
         mov       bh,0
         call      Int10I                   ; barva pozad¡

         mov       bl,ds:[si-1]
         mov       cl,5
         shr       bl,cl
         and       bl,1
         mov       ah,0bh
         mov       bh,1
         call      Int10I                   ; paleta m¢du CGA

         mov       bl,ds:[si-1]
         mov       cl,6
         shr       bl,cl
         and       bl,1
         mov       ax,1003h
         call      Int10I                   ; re‘im blik n¡
         pop       bx

InitPl14:dec       bx

; ------ nastaven¡ palet EGA

InitPal2:test      byte ptr ds:[Param],20h  ; jsou palety EGA ?
         jnz       InitPl20
         jmp       InitPal6                 ; nejsou palety EGA

InitPl20:mov       cx,17
         cmp       cx,bx
         jbe       InitPal3
         mov       cx,bx
InitPal3:sub       bx,cx
         or        cx,cx
         jnz       InitPl30
         ret                                ; nejsou ‘ dn‚ dal¨¡ palety

InitPl30:push      ds
         xor       ax,ax
         mov       ds,ax
         mov       dx,ds:[463h]
         pop       ds
         add       dl,6

InitPl31:sti
         in        al,dx
         test      al,8
         jnz       InitPl31

InitPl32:sti
         in        al,dx
         test      al,8
         jz        InitPl32

         mov       ah,0                     ; ukazatel registr–
         mov       dx,3c0h
InitPal4:mov       al,ah                    ; ‡¡slo registru
         out       dx,al
         lodsb
         out       dx,al                    ; nastaven¡ palety
         inc       ah
         cmp       ah,10h
         jne       InitPal5
         inc       ah
InitPal5:loop      InitPal4

         or        bx,bx
         jz        InitPl52
         dec       bx

         mov       al,10h
         out       dx,al
         lodsb
         mov       ah,al
         mov       cl,al
         and       al,8                     ; p©¡znak blik n¡
         ror       cl,1
         and       cl,80h                   ; volba adresov n¡ palet
         or        cl,al

         mov       al,0000b
         cmp       byte ptr ds:[VMod],3
         jbe       InitPl50
         mov       al,0010b
         cmp       byte ptr ds:[VMod],7
         je        InitPl50
         mov       al,0011b
InitPl50:cmp       byte ptr ds:[Card],4
         jb        InitPl51                 ; nen¡ VGA

         inc       dx
         in        al,dx
         and       al,not 88h
         dec       dx

InitPl51:or        al,cl
         out       dx,al                    ; nastaven¡ registru 10h

         mov       al,14h
         out       dx,al
         mov       al,ah
         mov       cl,4
         shr       al,cl
         out       dx,al                    ; nastaven¡ registru 14h

InitPl52:mov       al,20h
         out       dx,al

; ------ nastaven¡ palet VGA

InitPal6:test      byte ptr ds:[Param],40h  ; jsou palety VGA ?
         jz        InitPal9                 ; nejsou palety VGA
         mov       cx,3*256
         cmp       cx,bx
         jbe       InitPal7
         mov       cx,bx
InitPal7:sub       bx,cx
         jcxz      InitPal9                 ; nejsou ‘ dn‚ dal¨¡ palety
         mov       dx,3c8h
         mov       al,0
         out       dx,al                    ; nastaven¡ ‡¡sla palety
         inc       dx
InitPal8:lodsb
         out       dx,al
         loop      InitPal8
InitPal9:ret

InitPal  ENDP

; -----------------------------------------------------------------------------
;        inicializace videom¢du
; -----------------------------------------------------------------------------

InitVMod PROC      NEAR

; ------ test, zda je videom¢d ji‘ nastaven

         mov       al,ds:[VMod]             ; po‘adovan˜ videom¢d
         cmp       al,7
         jne       InitVMd0
         cmp       byte ptr ds:[Card],1
         je        InitVMd0
         cmp       byte ptr ds:[Card],4
         jae       InitVMd0
         mov       al,3
InitVMd0:cmp       al,ds:[AktVMod]          ; je videom¢d ji‘ nastaven ?
         je        InitVMd3                 ; je ji‘ nastaven

; ------ nastaven¡ po‘adovan‚ho videom¢du

         mov       ds:[AktVMod],al          ; nov˜ aktivn¡ videom¢d
         mov       ah,0
         int       10h                      ; inicializace videom¢du

         mov       word ptr ds:[DispVRAM],0
         mov       word ptr ds:[OutVRAM],0

InitVMd3:ret

InitVMod ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ bajtu z bufferu souboru DS:SI (CLD)
; -----------------------------------------------------------------------------
; Lok ln¡ promˆnn‚:
;     SS:[BP-1] (1) Param (bit 0: 1=je komprese)
;     SS:[BP-2] (1) KompCit (‡¡ta‡ shodn‚ho bajtu)
;     SS:[BP-3] (1) KompChar (znak k opakov n¡)
;     SS:[BP-4] (1) KompPar (bit 0: 1=je komprese)
;     SS:[BP-6] (2) NumBuf (po‡et bajt– v bufferu)
; -----------------------------------------------------------------------------

ReadByte PROC      NEAR

         test      byte ptr ss:[bp-1],1     ; je komprese ?
         jz        ReadB                    ; nen¡ komprese

; ------ na‡ten¡ bajtu po‡tu dat komprese

         cmp       byte ptr ss:[bp-2],0     ; je ‡¡ta‡ platn˜ ?
         jne       ReadByt4                 ; ‡¡ta‡ je dosud platn˜
ReadByt1:call      ReadB                    ; na‡ten¡ bajtu ‡¡ta‡e
         mov       byte ptr ss:[bp-2],al    ; po‡et n sleduj¡c¡ch bajt–

; ------ p©ep¡na‡ m¢du komprese

         or        al,al                    ; je to jen p©ep¡na‡ ?
         jnz       ReadByt2                 ; nen¡ to p©ep¡na‡
         xor       byte ptr ss:[bp-4],1     ; zmˆna p©¡znaku komprese
         jmp       short ReadByt1           ; nov‚ ‡ten¡ bajtu

; ------ na‡ten¡ bajtu k opakov n¡

ReadByt2:and       byte ptr ss:[bp-4],not 2 ; zru¨en¡ p©¡znaku komprese
         test      byte ptr ss:[bp-4],1    ; je m¢d komprese ?
         jz        ReadByt3                 ; nen¡ m¢d komprese
         or        byte ptr ss:[bp-4],2   ; p©¡znak komprese
         call      ReadB                    ; na‡ten¡ bajtu k opakov n¡
         mov       ss:[bp-3],al            ; bajt k opakov n¡

; ------ zmˆna p©¡znaku m¢du komprese

ReadByt3:cmp       byte ptr ss:[bp-2],255  ; je zmˆna m¢du komprese ?
         je        ReadByt4                 ; nen¡ zmˆna m¢du komprese
         xor       byte ptr ss:[bp-4],1  ; zmˆna p©¡znaku komprese

; ------ na‡ten¡ dal¨¡ho bajtu

ReadByt4:mov       al,ss:[bp-3]          ; bajt p©i opakov n¡ dat
         test      byte ptr ss:[bp-4],2  ; je opakov n¡ dat ?
         jnz       ReadByt5                 ; je opakov n¡ dat
         call      ReadB                    ; na‡ten¡ bˆ‘n‚ho bajtu dat

; ------ sn¡‘en¡ ‡¡ta‡e bajt–

ReadByt5:dec       byte ptr ss:[bp-2]    ; sn¡‘en¡ ‡¡ta‡e komprese
         ret

ReadByte ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ bajtu z bufferu souboru bez komprese DS:SI
; -----------------------------------------------------------------------------

; ------ test, zda je v bufferu dal¨¡ bajt

ReadB:   cmp       si,ss:[bp-6]             ; je ji‘ konec bufferu ?
         jae       ReadB2                   ; je konec bufferu

; ------ na‡ten¡ dal¨¡ho bajtu z bufferu

ReadB3:  lodsb                              ; na‡ten¡ bajtu z bufferu
         ret

; ------ na‡ten¡ dal¨¡ho bloku dat

ReadB2:  xor       si,si                    ; nov˜ ukazatel ‡tec¡ adresy
         push      ax
         push      bx
         push      cx
         push      dx

         mov       ah,3fh
         mov       bx,cs:[Idents]           ; identifik tor souboru
         xor       dx,dx                    ; po‡ tek bufferu
         mov       cx,cs:[SoubSize]         ; velikost bufferu
         int       21h                      ; na‡ten¡ bloku dat z buferu
         jc        ReadB5
         mov       cs:[NumBuf],ax           ; nov˜ po‡et bajt– v bufferu
         mov       ss:[bp-6],ax
         or        ax,ax
         jnz       ReadB5                   ; je nˆco na‡teno
         stc                                ; p©¡znak konce souboru

Readb5:  pop       dx
         pop       cx
         pop       bx
         pop       ax
         cld
         jmp       short ReadB3

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

Int10I   PROC      NEAR

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

Int10I   ENDP

; *****************************************************************************
;
;                             Zobrazen¡
;
; *****************************************************************************

; -----------------------------------------------------------------------------
;        zobrazen¡ v textov‚m m¢du (DS:SI=ukazatel v bufferu; CLD)
; -----------------------------------------------------------------------------

DispTXT  PROC      NEAR

         mov       ax,0b800h
         cmp       byte ptr cs:[VMod],7
         jne       DispTxt1
         mov       ah,0b0h
DispTxt1:mov       es,ax

         mov       ax,cs:[Vyska]
         mul       word ptr cs:[Sirka]
         xchg      ax,cx

         push      cx
         push      di
DispTxt2:call      ReadByte
         stosb
         inc       di
         loop      DispTxt2
DispTxt3:pop       di
         pop       cx

         inc       di
DispTxt4:call      ReadByte
         stosb
         inc       di
         loop      DispTxt4

DispTxt9:
         ret

DispTXT  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ v m¢du CGA (DS:SI=ukazatel v bufferu; CLD)
; -----------------------------------------------------------------------------

DispCGA  PROC      NEAR

         mov       ax,0b800h
         mov       es,ax
         mov       bx,200                   ; po‡et linek
         mov       cx,80/2                  ; po‡et slov na linku
         mov       dx,2000h                 ; posun adresy linky
DispCGA2:call      ReadStr                  ; ‡ten¡ jedn‚ linky ze souboru
         add       di,dx                    ; adresa dal¨¡ linky
         xor       dx,2000h XOR (80-2000h)  ; p©eklopen¡ p©¡rustku adresy
         dec       bx                       ; ‡¡ta‡ linek
         jnz       DispCGA2                 ; z pis dal¨¡ linky
         clc                                ; p©¡znak operace OK
DispCGA9:ret

DispCGA  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ v m¢du EGA (DS:SI=ukazatel v bufferu; CLD)
; -----------------------------------------------------------------------------

DispEGA  PROC      NEAR

         mov       ax,0a000h
         mov       es,ax

; ------ ur‡en¡ po‡tu bajt– na rovinu

         mov       ax,cs:[Sirka]            ; ¨¡©ka obrazovky
         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; po‡et bajt– na linku/2
         mul       word ptr cs:[Vyska]      ; v˜po‡et po‡tu bajt– na str nku/2
         xchg      ax,cx                    ; CX <- po‡et bajt– na str nku/2

; ------ inicializace ukazatele rovin

         mov       bx,100h                  ; ‡¡slo po‡ te‡n¡ roviny 0

; ------ volba z pisov‚ roviny

DispEGA1:mov       dx,3c4h
         mov       al,2                     ; registr volby ‡tec¡ roviny
         out       dx,al                    ; volba registru ‡¡sla roviny 2
         inc       dx
         mov       al,bh                    ; ‡¡slo z pisov‚ roviny
         out       dx,al                    ; nastaven¡ ‡¡sla roviny ke ‡ten¡

; ------ z pis roviny na v˜stup

         call      ReadStr                  ; na‡ten¡ obsahu videopamˆti

; ------ p©¡prava pro dal¨¡ rovinu barev

         shl       bh,1                     ; zv˜¨en¡ ukazatele barevn˜ch rovin
         inc       bx
         cmp       bl,cs:[Rovin]            ; jsou ji‘ v¨echny barevn‚ roviny ?
         jb        DispEGA1                 ; ulo‘en¡ dal¨¡ barevn‚ roviny

DispEGA9:ret

DispEGA  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ v m¢du VGA (DS:SI=ukazatel v bufferu; CLD)
; -----------------------------------------------------------------------------

DispVGA  PROC      NEAR

         mov       ax,0a000h
         mov       es,ax
         mov       cx,320*200/2
         call      ReadStr
         ret

DispVGA  ENDP

; -----------------------------------------------------------------------------
;        ‡ten¡ ©etˆzce slov (DS:SI=ukazatel v bufferu; CLD)
; -----------------------------------------------------------------------------

ReadStr  PROC      NEAR

         push      di
         push      cx
ReadStr1:call      ReadByte
         mov       ah,al
         call      ReadByte
         xchg      al,ah
         stosw
         loop      ReadStr1
ReadStr2:pop       cx
         pop       di
         ret

ReadStr  ENDP

; *****************************************************************************
;
;                          Data programu GDEMO
;
; *****************************************************************************
;þ

LastTime dw        0                        ; posledn¡ ‡as
DelTime  dw        0                        ; po‘adovan  prodleva

PgNum    db        0                        ; po‡et str nek
PgSize   dw        0                        ; velikost str nky
MaxPAdr  dw        0                        ; maxim ln¡ adresa str nky
DispVRAM dw        0                        ; zobrazen  videostr nka
OutVRAM  dw        0                        ; videostr nka pro v˜stup

DispMod  label     word                     ; tabulka obsluh m¢d–
         dw        DispTXT                  ; 0: text
         dw        DispTXT                  ; 1:
         dw        DispTXT                  ; 2:
         dw        DispTXT                  ; 3:
         dw        DispCGA                  ; 4:
         dw        DispCGA                  ; 5:
         dw        DispCGA                  ; 6:
         dw        DispTXT                  ; 7:
         dw        DispTXT                  ; 8: ?
         dw        DispTXT                  ; 9: ?
         dw        DispTXT                  ; 10: ?
         dw        DispTXT                  ; 11: ?
         dw        DispTXT                  ; 12: ?
         dw        DispEGA                  ; 13:
         dw        DispEGA                  ; 14:
         dw        DispEGA                  ; 15:
         dw        DispEGA                  ; 16:
         dw        DispEGA                  ; 17:
         dw        DispEGA                  ; 18:
         dw        DispVGA                  ; 19:

PageMod  label     byte                     ; tabulka po‡t– str nek
         db        8                        ; 0: text
         db        8                        ; 1:
         db        4                        ; 2:
         db        4                        ; 3:
         db        1                        ; 4:
         db        1                        ; 5:
         db        1                        ; 6:
         db        4                        ; 7:
         db        1                        ; 8: ?
         db        1                        ; 9: ?
         db        1                        ; 10: ?
         db        1                        ; 11: ?
         db        1                        ; 12: ?
         db        8                        ; 13:
         db        4                        ; 14:
         db        2                        ; 15:
         db        2                        ; 16:
         db        1                        ; 17:
         db        1                        ; 18:
         db        1                        ; 19:

PageSize label     word                     ; velikosti str nek
         dw        800h                     ; 0: text
         dw        800h                     ; 1:
         dw        1000h                    ; 2:
         dw        1000h                    ; 3:
         dw        4000h                    ; 4:
         dw        4000h                    ; 5:
         dw        4000h                    ; 6:
         dw        1000h                    ; 7:
         dw        1000h                    ; 8: ?
         dw        1000h                    ; 9: ?
         dw        1000h                    ; 10: ?
         dw        1000h                    ; 11: ?
         dw        1000h                    ; 12: ?
         dw        2000h                    ; 13:
         dw        4000h                    ; 14:
         dw        8000h                    ; 15:
         dw        8000h                    ; 16:
         dw        9600h                    ; 17:
         dw        9600h                    ; 18:
         dw        0fa00h                   ; 19:

OldVMod  db        0                        ; p–vodn¡ videom¢d

DatSegm  dw        0                        ; adresa datov‚ho bufferu souboru
DatSize  dw        0                        ; velikost datov‚ho bufferu (odst.)
DatNum   dw        0                        ; velikost datov‚ho souboru
DatNumH  dw        0                        ; velikost dat v bufferu HIGH


LastDemo dw        0                        ; adresa posledn¡ho © dku obr zku

SoubSegm dw        0                        ; segment v datov‚m buff. pro soubor
SoubSize dw        0                        ; velikost bufferu pro soubor (Bajt)
ReadBuf  dw        0                        ; ‡tec¡ adresa z bufferu
NumBuf   dw        0                        ; po‡et bajt– v bufferu souboru

Soubor0  db        'GDEMO000.SCR',0         ; jm‚no souboru
Soubor1  label     byte

AktVMod  db        0ffh                     ; aktu ln¡ videom¢d

SoubView db        128 dup(0)               ; soubor pro prohl¡‘e‡
SoubDemo db        'GDEMO.DAT',80 dup(0)    ; soubor pro demonstraci

MemTxt   db        'Chyba - nedostatek pameti !',13,10,'$'

InstTxt  db        'Program byl nainstalovan do pameti.',13,10
         db        'Sejmuti obrazovky klavesou PrintScreen.',13,10,'$'
OdInsTxt db        'Program byl odinstalovan z pameti.',13,10,'$'

DemoErr  db        'Nenalezen datovy animacni soubor (?=napoveda) !',13,10,'$'

FndTxt   db        'Soubor k zobrazeni nenalezen (?=napoveda) !',13,10,'$'
SCRTxt   db        'Neplatny soubor SCR !',13,10,'$'

;JeInsTxt db        'Program je jiz nainstalovan v pameti !',13,10,'$'
NeniTxt  db        'Program nelze odinstalovat - nebyl nainstalovan !',13,10,'$'
NelzeTxt db        'Program nelze odinstalovat - je nutno odinstalovat',13,10
         db        'nejdrive programy nainstalovane pozdeji !',13,10,'$'

RezSegm  dw        0                        ; segment rezidentn¡ho modulu

UvTxt    db        'PLAYSCR V1.13 - prehravac SCR; (c) Miroslav Nemecek',13,10,'$'

Palety   label     byte                     ; buffer k na‡ten¡ palet VGA
         db        256+3*256+18+1 dup(0)

KomentN  dw        -1                       ; d‚lka textu koment ©e (-1=nen¡)
Koment   db        128 dup(0)               ; text koment ©e souboru SCR

HlpTxt   db        13,10
;         db        'ÉÍÍÍÍÍÍÍÍÍ» /I ...... instalace snimace obrazovky do pameti (Print Screen)',13,10
;         db        'º Zadejte:º /#n ..... instalace s testem snimani behem prerus. INT n (HEX kod)',13,10
;         db        'ÈÍÍÍÍÍÍÍÍÍ¼ /! ...... odinstalovani snimace obrazovky z pameti',13,10
;         db        '            /Mn ..... videomod (n=0 az 19, bez zadani n je autodetekce)',13,10
;         db        '            /A ...... snimani je aktivni (pomoci klavesy Print Screen)',13,10
;         db        '            /P ...... snimani je aktivni bez testovani portu klavesnice',13,10
;         db        '            /X ...... snimani je neaktivni (Print Screen ma beznou funkci)',13,10
;         db        '            /K ...... ukladani souboru v kompresnim modu (implicitne)',13,10
;         db        '            /N ...... ukladani souboru v nekompresnim modu',13,10
;         db        '            /T ...... ukladani v testovacim rezimu - vypis registru VGA karty',13,10
;         db        '            /B ...... netestovat priznak zaneprazdnenosti DOS',13,10
;         db        '            /cislo .. casovane snimani; cislo=prodleva v 1/18 sek.',13,10
;         db        '                      (start/stop snimani PrintScreen, 0=jednorazove)',13,10
;         db        '            /Cn /En /Vn .... volba ukladani palet CGA,EGA,VGA (jen karta VGA)',13,10
;         db        '                         n=+ ano, n=- ne, n=* automaticky (implicitne)',13,10
;         db        '            soubor .. zobrazeni souboru v grafickem formatu SCR',13,10
;         db        '            /"text" (nebo /',39,'text',39,')... nastaveni komentare souboru SCR',13,10
;         db        13,10
;         db        'Bez zadani parametru se provadi graficka demonstrace podle',13,10
;         db        'definice v souboru GDEMO.DAT:',13,10
;;         db        13,10
;         db        '  soubor           ; jmeno souboru grafickeho obrazku',13,10
;;         db        '.#navesti        ; navesti pro povely skoku',13,10
;         db        '  .cislo           ; prodleva mezi obrazky (v 1/18 sekundy)',13,10
;;         db        '.GOTO navesti    ; skok na navesti',13,10
;;         db        '.GOSUB navesti   ; vyvolani podprogramu oznaceneho navestim',13,10
;;         db        '.RETURN          ; navrat z podprogramu',13,10
;;         db        '.TESTKEY navesti ; skok na navesti, je-li pripravena klavesa',13,10
;;         db        '.KEY             ; vstup znaku z klavesnice',13,10
;;         db        '.ON znak navesti ; skok na navesti, pokud byla stisknuta zadana klavesa',13,10
;;         db        '                 ;  (lze zapsat tez jmeno klavesy: F1, Ctrl-Home,...)',13,10
;;         db        '.CARD typ navesti; skok na navesti, je-li dany typ videokarty',13,10
;;         db        '.SET priznak     ; nastaveni priznaku zadaneho jmena',13,10
;;         db        '.RES priznak     ; nulovani priznaku zadaneho jmena',13,10
;;         db        '.TEST priznak navesti ; skok na navesti, je-li nastaven priznak',13,10
;;         db        '.COUNT citac cislo ; inicializace citace na vychozi hodnotu',13,10
;;         db        '.LOOP citac navesti ; skok na navesti, neni-li jeste dosazeno 0 citace',13,10
;;         db        '                 ; ... text za strednikem se ignoruje (poznamka)',13,10
NicTxt   db        '$'

Zasobnik label     byte                     ; konec z sobn¡ku

Code     ENDS
         END       Start

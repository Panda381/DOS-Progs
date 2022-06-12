

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                          Form†tov†n° disket
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

NUMVOL   EQU       15                       ; poáet poloëek voleb parametrñ
FORMOFFS EQU       9                        ; offset definice jednoho form†tu
VOLOFFS  EQU       7                        ; offset definice jednÇ poloëky
MAXSEKT  EQU       36                       ; maxim†ln° poáet sektorñ
BUFFSIZE EQU       36*200h                  ; velikost jednoho diskovÇho bufferu
MAXFAT   EQU       17                       ; maxim†ln° poáet sektorñ FAT
BUFFFAT  EQU       17*200h                  ; velikost bufferu pro FAT

COMMENT %                        Vzhled obrazovky:
…ÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕÕÕÕÕÕª
∫ 12.06.1993 ∫       FORM verze 2.0    (c) Miroslav Nàmeáek       ∫  12:33:40  ∫
ÃÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕÕÕÕÕÕπ
∫   Operaán° systÇm  ˚      Zobrazen° obsahu  ˚      Opakov†n° p©i chybà   1   ∫
∫   N†và®t° disku    ˚      Zrychlenò start   ˚      Testovac° z†pis       0   ∫
∫   Zachov†n° dat DISK      Zpàtnò smàr       ˚      Form†tovac° znak     F6   ∫
∫   Jedna strana     ˚      Zvukov† indikace  ˚      Äernob°lò displej     ˚   ∫
∫   Poloëek v Root 224      Verifikace        ˚      Äe®tina     Kamenickòch   ∫
»ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº
  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
∞                                                                              ∞
∞                …ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕª          …ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕª                  ∞
∞                ∫    Disk A:    ∫∞∞        ∫    Disk  B:   ∫∞∞                ∞
∞                ÃÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ∞∞        ÃÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ∞∞                ∞
∞                ∫  Automatickò  ∫∞∞        ∫  Automatickò  ∫∞∞                ∞
∞                ∫   1:  1.2M    ∫∞∞        ∫   1: 1.44M    ∫∞∞                ∞
∞                ∫   2:  720K    ∫∞∞        ∫   2:  720K    ∫∞∞                ∞
∞                ∫   3:  360K    ∫∞∞        ∫   3: 2.88M    ∫∞∞                ∞
∞                ∫   4:  320K    ∫∞∞        ∫   4:  360K    ∫∞∞                ∞
∞                ∫               ∫∞∞        ∫               ∫∞∞                ∞
∞                ∫               ∫∞∞        ∫               ∫∞∞                ∞
∞                »ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº∞∞        »ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº∞∞                ∞
∞                  ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞          ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞                ∞
∞                                                                              ∞
∞  F1=n†povàda; vlevo/vpravo=volba disku; TAB=zmàna okna; ENTER=volba form†tu  ∞
%

; -----------------------------------------------------------------------------
;        konstanty
; -----------------------------------------------------------------------------

HI       EQU       256

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

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                          Start programu
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         org       100h

; ------ p©edefinov†n° z†sobn°ku

Start:   mov       dx,offset MemTxt         ; text - nedostatek pamàti
         cmp       sp,offset Konec
         jb        Chyba                    ; nedostatek pamàti
         mov       sp,offset Konec

; ------ zmen®en° velikosti bloku programu

         mov       ah,4ah
         mov       bx,(offset(Konec-Start)+10fh)/16
         int       21h                      ; zmen®en° bloku programu
         jc        Chyba                    ; chyba

; ------ vytvo©en° bufferu textñ

         mov       bx,(offset(TextEnd-TextBeg)+0fh)/16 ; velikost bufferu textñ
         mov       ah,48h
         int       21h                      ; vytvo©en° bufferu textñ
         jc        Chyba                    ; chyba pamàti
         mov       ds:[BuffTxt],ax          ; adresa bufferu textñ

; ------ £schova textñ do bufferu

         mov       es,ax                    ; adresa bufferu
         xor       di,di
         mov       si,offset TextBeg        ; zaá†tek textñ
         mov       cx,offset(TextEnd-TextBeg)
         cld
         rep       movsb                    ; £schova textñ do bufferu

; ------ vytvo©en° datovÇho bloku pro buffery

         mov       bx,4*(BUFFSIZE/16)+17    ; velikost bufferñ
         mov       ah,48h
         int       21h                      ; vytvo©en° datovòch bufferñ
         jc        Chyba                    ; chyba - nedostatek pamàti

; ------ adresy bufferñ

         call      InitBuff                 ; adresa bufferu 1
         mov       ds:[BufferW],cx          ; adresa z†pisovÇho bufferu
         call      InitBuff                 ; adresa bufferu 2
         mov       ds:[BufferR],cx          ; adresa átec°ho bufferu
         call      InitBuff                 ; adresa bufferu 3
         mov       ds:[BufferD],cx          ; adresa datovÇho bufferu
         call      InitBuff                 ; je®tà p©°padnò buffer pro FAT
         cmp       word ptr ds:[BufferF],0  ; byl buffer FAT vytvo©en ?
         jne       Start1                   ; byl vytvo©en OK
         mov       ds:[BufferF],cx          ; adresa bufferu FAT

; ------ stanoven° poátu a parametrñ disketovòch mechanik

Start1:  call      GetDTyp                  ; stanoven° poátu a parametrñ mech.

; ------ chyba - nen° ë†dn† disketov† mechanika

         cmp       byte ptr ds:[NumDisk],0
         jne       Start2                   ; je nàjak† mechanika OK
         mov       dx,offset DiskTxt        ; chyba - nen° ë†dn† mechanika
Chyba:   mov       ah,9
         int       21h
         int       20h

; ------ instalace obsluh p©eru®en°

Start2:  mov       ax,2523h
         mov       dx,offset INT23
         int       21h
         mov       ax,2524h
         mov       dx,offset INT24
         int       21h

; ------ instalace INT 08h

         mov       ax,3508h
         int       21h
         mov       word ptr ds:[Old08],bx
         mov       word ptr ds:[Old08+2],es
         mov       dx,offset Int08
         mov       ax,2508h
         int       21h

; ------ instalace p©°znaku p©eru®en°

         mov       ax,3300h
         int       21h                      ; poskytnut° BREAK
         mov       ds:[OldBreak],dl         ; £schova p©°znaku BREAK
         mov       dl,0                     ; BREAK je vypnut
         mov       ax,3301h
         int       21h                      ; z†kaz p©°znaku BREAK

; ------ inicializace videom¢du

         call      DetCard                  ; detekce videokarty EGA/VGA
         call      InitFont                 ; inicializace fontñ a videom¢du
         call      InitMous                 ; inicializace ovladaáe my®i
         call      InitRnd                  ; inicializace gener†toru n†hody

; ------ stanoven° pozic k zobrazen° jednotlivòch diskñ

         mov       bh,ds:[NumDisk]          ; poáet diskñ
         mov       al,18                    ; ®°©ka jednoho okna
         mul       bh                       ; ®°©ka na v®echna okna
         sub       ax,80
         neg       ax                       ; zbytek na mezery
         inc       bh                       ; poáet diskñ + 1
         div       bh                       ; jedna mezera
         mov       bl,al                    ; £schova mezery
         inc       ax                       ; trochu korekce
         mov       cx,4
         mov       ds:[PozDiskT],al         ; pozice disku A:
         add       al,18
         add       al,bl
         mov       ds:[PozDiskT+1],al       ; pozice disku B:
         add       al,18
         add       al,bl
         mov       ds:[PozDiskT+2],al       ; pozice disku C:
         add       al,18
         add       al,bl
         mov       ds:[PozDiskT+3],al       ; pozice disku D:
         call      IniDPar                  ; inicializace parametrñ akt. disku

; ------ zobrazen° obrazovky pro volbu form†tu

         call      DispRam                  ; zobrazen° podkladovÇho r†mu

Start5:  call      DispPod                  ; zobrazen° podkladu

; ------ zobrazen° v®ech diskñ

Start51: call      DispADsk                 ; zobrazen° v®ech diskñ
         call      DispVol                  ; zobrazen° voleb

; ------ áek†n° na stisk kl†vesy

Start53: call      KurzOff
         call      MouseGet                 ; vstup z ovladaáe my®i
         cmp       bl,4                     ; stisk pravÇho tlaá°tka ?
         jne       Start54
         jmp       Start9                   ; stisk pravÇho tlaá°tka - konec
Start54: cmp       bl,6                     ; druhò stisk levÇho tlaá°tka ?
         je        Strt5402
Start540:cmp       bl,3                     ; stisk levÇho tlaá°tka ?
         je        Strt5402
Strt5401:jmp       Start55                  ; nen° stisk levÇho tlaá°tka
Strt5402:cmp       dh,9
         ja        Start541
         and       byte ptr ds:[MouseKey],not b0 ; zru®en° levÇho tlaá°tka
         xor       byte ptr ds:[MouseTim+1],1 ; neplatnò áas my®i
         jmp       Start8                   ; volba parametrñ

; ------ volba form†tu v oknech

Start541:cmp       dh,11
         jb        Strt5401
         cmp       dh,21
         ja        Strt553
         mov       al,0                     ; ukazatel á°sla disku
         mov       si,offset PozDiskT       ; tabulka pozic oken diskñ
Start542:mov       bh,ds:[si]               ; poá†teán° pozice okna disku
         cmp       dl,bh
         jb        Start543
         add       bh,17
         cmp       dl,bh
         jb        Start544
Start543:inc       al
         inc       si
         cmp       al,ds:[NumDisk]
         jb        Start542
         jmp       short Start55

Start544:cmp       al,ds:[AktDisk]
         je        Strt5442
         mov       bl,3
Strt5442:mov       ds:[AktDisk],al          ; novò aktivn° disk
         mov       bh,ds:[AktForm]
         mov       byte ptr ds:[AktForm],-1 ; aktivn° form†t neplatnò
         call      IniDPar                  ; inicializace parametrñ akt. disku
         sub       dl,ds:[si]
         je        Strt5445
         cmp       dl,16
         je        Strt5445
         sub       dh,14
         jb        Strt5445
         cmp       dh,ds:[NumForm]
         jae       Strt5445
         mov       ds:[AktForm],dh
         cmp       bh,ds:[AktForm]
         je        Strt5443
Strt5445:mov       bl,3
Strt5443:call      IniDPar
Start545:cmp       bl,6
         mov       bx,0dh
         je        Start56
Strt5444:jmp       Start51

; ------ ovl†d†n° my®° pomoc° n†povàdy

Strt553: cmp       dh,24
         jne       Start55
         cmp       bl,3
         jne       Start55
         cmp       dl,39
         jb        Start55
         mov       bx,0dh                   ; Enter
         cmp       dl,54
         jbe       Start56
         mov       bl,1bh                   ; Esc
         cmp       dl,65
         jbe       Start56
         mov       bx,3b00h                 ; F1
         jmp       short Start56

Start55: call      TestKey
         jnc       Start552
         jmp       Start53                  ; nen° znak z kl†vesnice

Start552:
         call      InpKey

Start56: mov       al,ds:[AktForm]          ; aktivn° form†t
         mov       ah,ds:[NumForm]          ; poáet moënòch form†tñ
         call      JumpBX                   ; skok na obsluhu podle kl†vesy

         dw        9,Start66                ; Tab
         dw        0f00h,Start65            ; Shift-Tab
         dw        4d00h,Start64            ; vpravo
         dw        4b00h,Start63            ; vlevo
         dw        4800h,Start62            ; nahoru
         dw        5000h,Start61            ; dolñ
         dw        4700h,Start611           ; Home
         dw        4f00h,Start621           ; End
         dw        4900h,Start611           ; Page Up
         dw        5100h,Start621           ; Page Down
         dw        4300h,Start8             ; F9
         dw        13,Start7                ; ENTER
         dw        27,Start9                ; ESC

         dw        0,Start53

; ------ kurzor dolñ

Start61: inc       al
         cmp       al,ah
         jb        Start612
Start611:mov       al,0
Start612:mov       ds:[AktForm],al
Start613:call      IniDPar                  ; inicializace parametrñ akt. disku
         jmp       Start51

; ------ kurzor nahoru

Start62: dec       al
         jns       Start612
Start621:mov       al,ah
         dec       al
         jmp       short Start612

; ------ kurzor vlevo

Start63: mov       al,ds:[AktDisk]
         or        al,al
         jz        Start632
         dec       al
Start632:mov       ds:[AktDisk],al          ; novò aktivn° disk
         mov       byte ptr ds:[AktForm],-1 ; aktivn° form†t neplatnò
         jmp       short Start613           ; inicializace parametrñ

; ------ kurzor vpravo

Start64: mov       al,ds:[AktDisk]
         cmp       al,ds:[NumDisk]
         jae       Start632
         inc       ax
         jmp       short Start632

; ------ Shift-Tab

Start65: mov       al,ds:[AktDisk]
         dec       al
         jns       Start632
         mov       al,ds:[NumDisk]          ; poáet diskñ
         dec       ax                       ; á°slo posledn°ho disku
         jmp       short Start632

; ------ Tab

Start66: mov       al,ds:[AktDisk]
         inc       al
         cmp       al,ds:[NumDisk]
         jb        Start632
         mov       al,0
         jmp       short Start632

; ------ form†tov†n° disku

Start7:  call      FormDsk
         jmp       Start5

; ------ volba parametrñ

Start8:  call      Volby                    ; ovl†d†n° voleb
         cmp       byte ptr ds:[MousePoz+1],24
         je        Start82
         and       byte ptr ds:[MouseKey],not b0 ; zru®en° levÇho tlaá°tka
         xor       byte ptr ds:[MouseTim+1],1 ; neplatnò áas
Start82: jmp       Start53

; ------ ESC: konec programu

Start9:  call      MouseOff
         mov       ah,0fh
         call      Int10
         mov       ah,0
         call      Int10
         mov       dl,ds:[OldBreak]         ; pñvodn° p©°znak p©eru®en°
         mov       ax,3301h
         int       21h                      ; n†vrat p©°znaku BREAK
         lds       dx,ds:[Old08]
         mov       ax,2508h
         int       21h
         int       20h

; -----------------------------------------------------------------------------
;        stanoven° adresy diskovÇho bufferu (AX=adresa) -> CX
; -----------------------------------------------------------------------------

InitBuff PROC      NEAR

; ------ adresa nejblië®° vy®®° hranice 64 KB

         mov       bx,ax                    ; aktu†ln° adresa bufferu
         and       bx,not 0fffh             ; zarovn†n° na 64 KB
         add       bh,10h                   ; adresa dal®° hranice 64 KB
         jnc       InitBuf1                 ; nen° p©elom p©es 1 MB
         mov       bx,-1                    ; omezen° na 1 MB

; ------ kontrola, zda je dost m°sta pro datovò buffer

InitBuf1:mov       cx,bx                    ; nejblië®° p©elom 64 KB
         sub       cx,ax                    ; zbylÇ m°sto do 64 KB
         cmp       cx,BUFFSIZE/16           ; staá° pro diskovò buffer ?
         ja        InitBuf3                 ; velikost pro buffer je dostateán†

; ------ test, zda m°sto staá° alespo§ pro buffer FAT

         cmp       cx,BUFFFAT/16            ; staá° alespo§ pro buffer FAT ?
         jbe       InitBuf2                 ; m†lo m°sta pro buffer FAT
         cmp       word ptr ds:[BufferF],0  ; je buffer FAT jië vytvo©en ?
         jne       InitBuf2                 ; buffer FAT je jië vytvo©en
         mov       ds:[BufferF],ax          ; adresa bufferu FAT

; ------ posun adresy bufferu na zaá†tek dal®°ho p©elomu

InitBuf2:mov       ax,bx                    ; posun zaá†tku bufferu na p©elom
InitBuf3:mov       cx,ax                    ; adresa bufferu
         add       ax,BUFFSIZE/16           ; posun adresy
         ret

InitBuff ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 23h a INT 24h
; -----------------------------------------------------------------------------

INT24    PROC      FAR

         mov       al,0
INT23:   iret

INT24    ENDP

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                          Form†tov†n° disku
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
FormDsk  PROC      NEAR

; ------ instalace INT 1eh

         call      Inst1e                   ; instalace INT 1Eh

; ------ p©°prava BOOT sektoru

FormDsk0:call      SetSer                   ; nastaven° sÇriovÇho á°sla

; ------ inicializace ukazatelñ

         xor       ax,ax
         mov       byte ptr ds:[AktStop],al ; ukazatel stop
         mov       byte ptr ds:[AktStran],al ; strana
         mov       word ptr ds:[CitVol],ax
         mov       word ptr ds:[CitVol+2],ax
         mov       word ptr ds:[CitBad],ax
         mov       word ptr ds:[CitBad+2],ax
         mov       ds:[ErrDat],al           ; p©°znak chyby 1. sektoru bloku

;         mov       word ptr ds:[AktSekt],ax ; ukazatel absolutn°ho sektoru
;         and       byte ptr ds:[Priznaky],not bit0 + bit1 ; nulov†n° p©°znakñ
;         mov       word ptr ds:[VolSekt],ax
;         mov       word ptr ds:[BadSekt],ax
;         mov       word ptr ds:[FrstChar],ax
;         mov       byte ptr ds:[FillCh],0   ; plnic° znak pro form†tov†n°

         mov       al,1
         mov       ds:[ErrBoot],al
         mov       ds:[ErrFat1],al
         mov       ds:[ErrFat2],al
         mov       ds:[ErrRoot],al

         mov       al,ds:[ParBack]          ; smàr
         mov       ds:[Smer],al             ; smàr form†tov†n°
         cmp       al,0
         je        FormDs02
         mov       al,ds:[NumStop]          ; poáet stop
         dec       ax
         mov       ds:[AktStop],al          ; posledn° stopa
         mov       al,ds:[NumStran]
         dec       ax
         mov       ds:[AktStran],al         ; posledn° strana
FormDs02:

; ------ nulov†n° tabulky FAT

         mov       es,ds:[BufferF]          ; segment bufferu s FAT
         mov       ch,ds:[FatSekt]          ; poáet sektorñ tabulky FAT
         mov       cl,0
         xor       ax,ax
         xor       di,di
         cld
         rep       stosw                    ; nulov†n° tabulky FAT
         dec       ax
         mov       es:[1],ax                ; zaá†tek tabulky FAT
         mov       al,ds:[Popis]            ; popisovaá mÇdia
         mov       es:[0],al                ; popisovaá mÇdia

; ------ p©°prava ukazatele k zobrazen° mapy disku

         cmp       byte ptr ds:[NumStran],2 ; jsou 2 strany ?
         je        FormDs21                 ; jsou 2 strany
         mov       al,4                     ; vò®ka - 1 strana 40 stop
         cmp       byte ptr ds:[NumStop],40 ; je 40 stop ?
         je        FormDs22                 ; je 40 stop
         mov       al,9                     ; vò®ka - 1 strana 80 stop
         jmp       short FormDs22           ; je 80 stop

FormDs21:mov       al,5                     ; vò®ka - 2 strany 40 stop
         cmp       byte ptr ds:[NumStop],60 ; je 40 stop ?
         jb        FormDs22                 ; je 40 stop
         mov       al,11                    ; vò®ka - 2 strany 80 stop
FormDs22:mov       byte ptr ds:[SirMap+1],al ; vò®ka mapy disku
         sub       al,11
         neg       al                       ; zbytek na okraje
         shr       al,1
         add       al,11                    ; poá†teán° ©†dek
         mov       byte ptr ds:[PozMap+1],al ; poá†teán° ©†dek k zobrazen° mapy

         mov       al,ds:[NumStop]          ; poáet stop
         cmp       al,60
         jb        FormDs23                 ; je 40 stop
         inc       ax                       ; zaokrouhlen° nahoru
         shr       al,1                     ; poáet stop / 2
FormDs23:add       al,13                    ; korekce na okraje
         mov       byte ptr ds:[SirMap],al  ; ®°©ka okna
         sub       al,58
         neg       al
         shr       al,1
         mov       byte ptr ds:[PozMap],al  ; poá†teán° pozice okna

; ------ roztoáen° mechaniky

         xor       bx,bx
         mov       es,bx
         mov       ax,401h
         mov       cx,1
         call      Int13                    ; verifikace pro roztoáen° mechaniky
         call      ResDisk                  ; £vodn° reset disku

; ------ nastaven° form†tu disku

         call      SetForm                  ; nastaven° form†tu diskety
         jnc       FormDs40
         jmp       FormDsk9


FormDs40:
         call      DispPod                  ; zobrazen° podkladu
         call      DispVol                  ; zobrazen° voleb

         call      DispMap                  ; zobrazen° mapy disky
         call      DispInf                  ; zobrazen° informaán°ho okna

         xor       ax,ax
         mov       es,ax
         mov       ax,es:[46ch]
         mov       ds:[BegTime],ax

         mov       byte ptr ds:[ParsTime],1 ; p©°znak zobrazen° doby akce

FormDsk4:

; ------ oznaáen° tabulky chyb - v®echny sektory OK

         push      cs
         pop       es
         mov       di,offset TabBad
         mov       cx,word ptr ds:[NumSekt] ; poáet sektorñ na stopu
         mov       al,0                     ; nulovac° hodnota
         cld
         rep       stosb                    ; vymaz†n° tabulky vadnòch stop

         cmp       byte ptr ds:[ParDat],0
         je        FormD411

         mov       cl,1
         mov       al,ds:[NumSekt]
         mov       es,ds:[bufferD]
         xor       bx,bx
         call      Cteni
         jc        FormD416

FormD411:
         call      Format
         jc        FormD416

         call      TestRnd                  ; test n†hodnòm z†pisem
         jc        FormD416

         cmp       byte ptr ds:[AktStran],0
         jne       FormD413
         cmp       byte ptr ds:[AktStop],0
         jne       FormD413

         mov       es,ds:[BufferW]
         xor       di,di
         mov       si,offset Boot
         mov       cx,offset(BootEnd-Boot)
         cld
         rep       movsb
         xor       ax,ax
         mov       cx,offset(Boot-BootEnd)+512
         rep       stosb
         mov       al,ds:[Popis]
         stosb
         mov       ax,-1
         stosw
         mov       cx,512-3
         mov       al,0
         rep       stosb
         mov       cl,1
         mov       al,2
         xor       bx,bx
         call      Zapis
         jc        FormD416

FormD413:
         cmp       byte ptr ds:[ParDat],0
         je        FormD412

         mov       cl,1
         mov       al,ds:[NumSekt]
         mov       es,ds:[BufferD]
         xor       bx,bx
         call      Zapis
         jc        FormD416


FormD412:cmp       byte ptr ds:[ParVerif],0
         je        FormD414

         call      Verif                    ; verifikace
         jnc       FormD414

FormD416:
         call      ReadBad                  ; áten° vadnÇ stopy
         stc

FormD414:

         mov       ah,ds:[ColOK]
         mov       al,"≤"
         jnc       FormDs42
FormDs41:mov       ah,ds:[ColErr]
         mov       al,"x"
FormDs42:call      DispFCh


         mov       ah,1
         int       16h
         jz        FormDs76
         call      InpKey
         cmp       bl,27
         je        FormDsk9

; ------ za©azen° naátenòch sektorñ

FormDs76:call      StorSekt                 ; za©azen° sektorñ stopy
         call      DispKap                  ; zobrazen° kapacit disku

; ------ zvò®en° á°sla stopy

         mov       al,ds:[AktStran]         ; aktu†ln° strana
         cmp       byte ptr ds:[Smer],0
         je        FormDs77                 ; je smàr nahoru
         dec       al                       ; sn°ëen° á°sla strany
         jz        FormDs78

         mov       al,ds:[AktStop]
         dec       al
         js        FormDs79                 ; jsou jië v®echny stopy
         mov       ds:[AktStop],al

         mov       al,ds:[NumStran]
         dec       ax
         jmp       short FormDs78

FormDs77:inc       ax                       ; zvò®en° á°sla aktu†ln° strany
         cmp       al,ds:[NumStran]         ; jsou jië v®echny strany ?
         jb        FormDs78                 ; nejsou je®tà v®echny strany

         mov       al,ds:[AktStop]          ; aktu†ln° stopa
         inc       ax                       ; zvò®en° á°sla stopy
         cmp       al,ds:[NumStop]          ; jsou jië v®echny stopy ?
         jae       FormDs79                 ; jsou jië v®echny stopy
         mov       ds:[AktStop],al          ; aktu†ln° stopa
         mov       al,0                     ; strana 0
FormDs78:mov       ds:[AktStran],al         ; aktu†ln° strana

         jmp       FormDsk4                 ; form†tov†n° dal®° stopy

FormDs79:


FormDsk8:

         mov       byte ptr ds:[ParsTime],0 ; zru®en° p©°znaku zobrazen° áasu
         call      InpKey

FormDsk9:

         call      DeInst1E                 ; odinstalov†n° INT 1eh
         mov       byte ptr ds:[ParsTime],0 ; zru®en° p©°znaku zobrazen° áasu

         ret

FormDsk  ENDP

; -----------------------------------------------------------------------------
;        test stopy n†hodnòm z†pisem
; -----------------------------------------------------------------------------

TestRnd  PROC      NEAR

; ------ kontrola, zda se prov†dàj° testovac° z†pisy

         mov       al,ds:[ParTest]          ; poáet testovac°ch z†pisñ
         cmp       al,0                     ; jsou testovac° z†pisy ?
         jne       TestRnd1                 ; jsou testovac° z†pisy
         ret

; ------ p©°prava registrñ

TestRnd1:mov       ah,0
         mov       bp,ax                    ; á°taá testovac°ch z†pisñ

; ------ je-li posledn° z†pis, je nulovac° konstanta

TestRnd2:mov       es,ds:[BufferW]          ; buffer k z†pisu
         xor       di,di                    ; poá†tek bufferu
         mov       cx,word ptr ds:[NumSekt] ; poáet sektorñ na stopu
         cmp       bp,1                     ; je posledn° z†pis
         jne       TestRnd3                 ; nen° posledn° z†pis
         mov       ch,cl                    ; poáet sektorñ
         mov       cl,0                     ; CX = poáet slov dat
         mov       al,ds:[ParChar]          ; nulovac° konstanta
         mov       ah,al
         cld
         rep       stosw                    ; vymaz†n° dat
         jmp       short TestRnd4

; ------ p©°prava dat k z†pisu - n†hodn† data

TestRnd3:call      RandomS                  ; vygenerov†n° sektoru
         loop      TestRnd3                 ; dal®° sektor

; ------ z†pis dat na disk

TestRnd4:mov       al,ds:[NumSekt]          ; poáet sektorñ k z†pisu
         mov       cl,1                     ; poá†teán° sektor
         xor       bx,bx                    ; poá†tek dat
         call      Zapis                    ; z†pis dat na disk
         jc        TestRnd9                 ; chyba dat

; ------ kontroln° áten° dat

         mov       al,ds:[NumSekt]
         mov       cl,1
         xor       bx,bx
         mov       es,ds:[BufferR]          ; átec° buffer
         call      Cteni
         jc        TestRnd9

; ------ porovn†n° dat

         push      ds
         mov       ch,ds:[NumSekt]
         mov       cl,0
         mov       ds,ds:[BufferW]
         xor       si,si
         xor       di,di
         cld
         repe      cmpsw                    ; porovn†n° dat
         pop       ds
         stc
         jne       TestRnd9                 ; data nesouhlas°

         dec       bp
         jnz       TestRnd2                 ; dal®° z†pis
         clc

TestRnd9:ret

TestRnd  ENDP

; -----------------------------------------------------------------------------
;        naáten° BOOT sektoru
; -----------------------------------------------------------------------------

ReadBoot PROC      NEAR






         ret

ReadBoot ENDP

; -----------------------------------------------------------------------------
;        instalace obsluhy INT 1eh
; -----------------------------------------------------------------------------

Inst1e   PROC      NEAR

; ------ £schova adresy INT 1eh

         mov       ax,351eh
         int       21h
         mov       word ptr ds:[Old1e],bx
         mov       word ptr ds:[Old1e+2],es

; ------ instalace novÇ adresy INT 1eh

         mov       ax,251eh
         mov       dx,offset Int1e
         int       21h
         ret

Inst1e   ENDP

; -----------------------------------------------------------------------------
;        odinstalov†n° INT 1eh
; -----------------------------------------------------------------------------

DeInst1e PROC      NEAR

         push      ds
         mov       ax,251eh
         lds       dx,ds:[Old1e]
         int       21h                      ; n†vrat INT 1eh
         pop       ds
         ret

DeInst1e ENDP

; -----------------------------------------------------------------------------
;        nastaven° sÇriovÇho á°sla
; -----------------------------------------------------------------------------

SetSer   PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx

; ------ stanoven° systÇmovÇho áasu

         mov       ah,2ch
         int       21h                      ; poskytnut° systÇmovÇho áasu

         mov       ah,0
         mov       al,dl                    ; setina sekundy 7 bitñ
         shr       al,1                     ; setina sekundy 6 bitñ

         mov       dl,0
         shr       dx,1
         shr       dx,1
         or        ax,dx                    ; sekunda 6 bitñ (p©esahuj° 4 bity)

         mov       dh,0
         mov       dl,cl                    ; minuta
         mov       cl,4                     ; poáet rotac°
         shl       dx,cl
         or        ah,dl                    ; minuty 4 bity
         mov       dl,dh                    ; minuty 2 bity

         mov       dh,ch                    ; hodina
         shl       dh,1
         shl       dh,1
         or        dl,dh                    ; hodina 5 bitñ (zbòv† 1 bit)
         mov       dh,0

         mov       word ptr ds:[BSerie+2],ax
         mov       word ptr ds:[BSerie],dx  ; v DX je 7 bitñ

; ------ stanoven° systÇmovÇho data

         mov       ah,2ah
         int       21h                      ; poskytnut° systÇmovÇho data

         mov       ah,dh                    ; màs°c
         mov       cl,4
         shl       ah,cl                    ; màs°c 4 bity
         mov       dh,0
         mov       cl,7
         shl       dx,cl                    ; den 5 bitñ
         or        ax,dx                    ; màs°c + den
         or        word ptr ds:[BSerie],ax  ; + màs°c a den

; ------ n†vrat registrñ

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

SetSer   ENDP

; -----------------------------------------------------------------------------
;        za©azen° sektorñ stopy
; -----------------------------------------------------------------------------

StorSekt PROC      NEAR

; ------ p©°prava registrñ

         mov       cx,word ptr ds:[NumSekt] ; poáet sektorñ na stopu
         mov       si,offset TabBad         ; tabulka vadnòch sektorñ
         mov       al,ds:[AktStop]          ; aktu†ln° stopa
         mul       byte ptr ds:[NumStran]   ; poáet jië zpracovanòch stop
         add       al,ds:[AktStran]         ; p©iáten° aktu†ln° strany
         mul       cl                       ; absolutn° á°slo sektoru stopy
         xchg      ax,bx                    ; BX <- ukazatel á°sla sektoru

; ------ naáten° parametrñ sektoru

StorSkt1:cld
         lodsb                              ; naáten° sektoru
         push      bx

; ------ oznaáen° sektoru BOOT

         sub       bx,1                     ; je BOOT sektor ?
         ja        StorSkt2                 ; nen° BOOT sektor
         je        StorSk22
         mov       ds:[ErrBoot],al          ; p©°znak BOOT sektoru
         jmp       short StorSkt9

; ------ oznaáen° sektoru FAT 1

StorSk22:mov       ds:[ErrFat1],al
StorSkt2:sub       bx,word ptr ds:[FatSekt] ; odeáten° sektorñ FAT 1
         ja        StorSkt3
         je        StorSk32
         or        ds:[ErrFat1],al          ; p©°znak FAT 1
         jmp       short StorSkt9

; ------ oznaáen° sektoru FAT 2

StorSk32:mov       ds:[ErrFat2],al
StorSkt3:sub       bx,word ptr ds:[FatSekt] ; odeáten° sektorñ FAT 2
         ja        StorSkt4
         je        StorSk42
         or        ds:[ErrFat2],al          ; p©°znak FAT 2
         jmp       short StorSkt9

; ------ oznaáen° sektoru ROOT

StorSk42:mov       ds:[ErrRoot],al
StorSkt4:sub       bx,word ptr ds:[RootSekt] ; odeáten° sektorñ na ROOT
         jae       StorSkt5
         or        ds:[ErrRoot],al          ; p©°znak ROOT
         jmp       short StorSkt9

; ------ vadn† data - oznaáen° sektoru v tabulce FAT

StorSkt5:cmp       al,0                     ; je sektor OK ?
         je        StorSk52                 ; sektor je OK
         push      ax
         push      bx
         cmp       byte ptr ds:[BlokSekt],1
         je        StorSk51
         shr       bx,1                     ; sektor / 2
StorSk51:mov       ax,0ff7h
         inc       bx
         inc       bx                       ; zaá°n† se od bloku 2
         call      SetFat                   ; oznaáen° vadnÇho bloku BX ve FAT
         pop       bx
         pop       ax

; ------ zvò®en° á°taáe dat

StorSk52:cmp       byte ptr ds:[BlokSekt],1 ; je 1 sektor na blok ?
         je        StorSkt7                 ; je 1 sektor na blok
         test      bl,1                     ; je lichò datovò sektor ?
         jnz       StorSkt6                 ; je lichò datovò sektor
         mov       ds:[ErrDat],al           ; £schova p©°znaku sektoru
         jmp       short StorSkt9
StorSkt6:or        al,ds:[ErrDat]           ; slouáen° se sudòm sektorem
StorSkt7:cmp       al,0                     ; je blok OK ?
         mov       ax,ds:[BlokByte]         ; poáet bajtñ na alokaán° blok
         je        StorSkt8                 ; blok je OK
         add       word ptr ds:[CitBad],ax  ; á°taá vadnòch blokñ
         adc       word ptr ds:[CitBad+2],0
         jmp       short StorSkt9

StorSkt8:add       word ptr ds:[CitVol],ax  ; á°taá volnòch blokñ
         adc       word ptr ds:[CitVol+2],0

; ------ p©°prava pro dal®° sektor

StorSkt9:pop       bx
         inc       bx
         dec       cx
         jz        StorSktA
         jmp       StorSkt1                 ; dal®° sektor
StorSktA:ret

StorSekt ENDP

; -----------------------------------------------------------------------------
;        nastaven° poloëky BX v tabulce FAT na hodnotu AX
; -----------------------------------------------------------------------------

SetFat   PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      ds

; ------ stanoven° adresy poloëky ve FAT tabulce

         mov       cx,bx                    ; á°slo bloku
         shr       bx,1                     ; á°slo bloku / 2
         add       bx,cx                    ; á°slo bloku * 1.5
         mov       ds,ds:[BufferF]          ; buffer s tabulkou FAT

; ------ nastaven° hodnoty FAT - sud† poloëka

         test      cl,1                     ; je sud† poloëka ?
         jnz       SetFat3                  ; je lich† poloëka
         and       word ptr ds:[bx],0f000h  ; nulov†n° starÇ hodnoty
         jmp       short SetFat4

; ------ nastaven° hodnoty FAT - lich† poloëka

SetFat3: and       word ptr ds:[bx],0fh     ; nulov†n° starÇ hodnoty
         mov       cl,4                     ; poáet rotac°
         shl       ax,cl                    ; rotace hodnoty na pozici
SetFat4: or        ds:[bx],ax               ; nastaven° novÇ hodnoty

; ------ n†vrat registrñ

SetFat9: pop       ds
         pop       cx
         pop       bx
         pop       ax
         ret

SetFat   ENDP

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                              Obsluha disku
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
; -----------------------------------------------------------------------------
;        naáten° obsahu vadnÇ stopy
; -----------------------------------------------------------------------------

ReadBad  PROC      NEAR

; ------ inicializace tabulky vadnòch stop

         push      ds
         pop       es
         mov       di,offset TabBad         ; tabulka vadnòch stop
         mov       cx,word ptr ds:[NumSekt] ; poáet sektorñ na stopu
         mov       al,-1                    ; nulovac° hodnota
         cld
         rep       stosb                    ; vymaz†n° tabulky vadnòch stop

; ------ p©°prava ukazatelñ

         cmp       byte ptr ds:[ParOptim],0 ; dàl† se optimalizace chyb ?
         je        ReadBad9                 ; optimalizace se nedàl†
         mov       es,ds:[BufferR]          ; buffer pro áten°
         mov       dh,0
         mov       ch,ds:[NumSekt]          ; poáet sektorñ na stopu

; ------ p©°prava ukazatelñ pro áten° skupiny blokñ velikosti CL

ReadBad3:shr       ch,1
         adc       ch,0                     ; polovina poátu sektorñ
         shr       ch,1
         adc       ch,0                     ; átvrtina poátu sektorñ
         mov       cl,1                     ; á°slo poá†teán°ho sektoru
         xor       bx,bx                    ; adresa zaá†tku bufferu
         mov       di,offset TabBad         ; tabulka vadnòch sektorñ

; ------ stanoven° skuteánÇho poátu zbylòch sektorñ

ReadBad4:mov       dl,ch                    ; DH <- poáet sektorñ ke áten°
         add       dl,cl                    ; á°slo dal®°ho sektoru
         cmp       dl,ds:[NumSekt]          ; p©eteáen° poátu sektorñ ?
         jbe       ReadBad5                 ; á°slo sektoru je OK
         mov       dl,ds:[NumSekt]          ; omezen° max. á°sla sektoru
         inc       dx                       ; n†sleduj°c° sektor
ReadBad5:sub       dl,cl                    ; poáet sektorñ ke áten°

; ------ test, zda je pot©eba á°st zvolenou skupinku sektorñ

         push      cx
         push      di
         push      es
         push      cs
         pop       es                       ; ES <- CS
         mov       al,-1                    ; hledanò vadnò sektor
         mov       cx,dx                    ; poáet sektorñ ke áten°
         cld
         repne     scasb                    ; nalezen° vadnÇho sektoru
         pop       es
         pop       di
         pop       cx
         jne       ReadBad7                 ; vadnò sektor nen°, nen° t©eba á°st

; ------ naáten° jednÇ skupinky sektorñ

         push      cx
         push      dx
         xchg      ax,dx                    ; AL <- poáet sektorñ ke áten°
         call      Cteni                    ; áten° jednÇ skupiny sektorñ
         pop       dx
         pop       cx
         jc        ReadBad7                 ; áten° ne£spà®nÇ

; ------ p©i £spà®nÇm áten° nulov†n° p©eátenòch sektorñ

         push      cx
         push      es
         push      di
         push      cs
         pop       es
         cld
         mov       al,0
         mov       cx,dx                    ; poáet naátenòch sektorñ
         rep       stosb                    ; vynulov†n° p©eátenòch sektorñ
         pop       di
         pop       es
         pop       cx

; ------ zvò®en° ukazatele sektorñ

ReadBad7:add       bh,ch
         add       bh,ch                    ; zvò®en° adresy dat v bufferu
         add       di,dx                    ; zvò®en° ukazatele v tabulce chyb
         add       cl,dl                    ; zvò®en° ukazatele sektorñ
         cmp       cl,ds:[NumSekt]          ; jsou jië v®echny sektory ?
         jbe       ReadBad4                 ; áten° dal®° skupinky sektorñ

; ------ p©°prava pro áten° jemnàj®°ho dàlen° skupin

         cmp       ch,1                     ; byl jië 1 sektor ?
         jne       ReadBad3                 ; áten° dal®°ho dàlen° sektorñ
ReadBad9:ret

ReadBad  ENDP

; -----------------------------------------------------------------------------
;        p©°prava parametrñ aktivn°ho disku
; -----------------------------------------------------------------------------

IniDPar  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si

; ------ p©°prava ukazatele aktivn°ho disku

         mov       bl,ds:[AktDisk]          ; aktivn° disk
         cmp       bl,ds:[NumDisk]          ; je platnÇ á°slo disku ?
         jb        IniDPar1                 ; á°slo aktivn°ho disku je OK
         mov       bl,ds:[NumDisk]          ; poáet diskñ
         dec       bx                       ; omezen° na posledn° disk
         mov       ds:[AktDisk],bl          ; novò aktivn° disk
IniDPar1:mov       bh,0

; ------ £schova aktivn°ho form†tu aktivn°ho disku

         mov       al,ds:[AktForm]          ; aktivn° form†t
         cmp       al,-1                    ; je aktivn° form†t platnò ?
         je        IniDPar2                 ; aktivn° form†t nen° platnò
         mov       ds:[AktFormT+bx],al      ; £schova aktivn°ho form†tu

; ------ tabulka definice form†tñ disku

IniDPar2:mov       al,ds:[TypDiskT+bx]      ; typ aktivn°ho disku
         mov       ds:[TypDisk],al          ; typ aktivn°ho disku
         mov       ah,0
         shl       ax,1                     ; typ aktivn°ho disku * 2
         xchg      ax,si                    ; SI <- typ aktivn°ho disku * 2
         mov       si,ds:[TabForm+si-2]     ; adresa definice form†tu disku

; ------ poáet form†tñ disku

         mov       ah,ds:[si]               ; poáet platnòch form†tñ disku
         mov       ds:[NumForm],ah          ; poáet form†tñ disku
         inc       si                       ; adresa prvn°ho form†tu

; ------ n†vrat aktivn°ho form†tu disku

         mov       al,ds:[AktFormT+bx]      ; aktivn° form†t aktivn°ho disku
         cmp       al,ah                    ; je á°slo form†tu platnÇ ?
         jb        IniDPar3                 ; á°slo form†tu je platnÇ
         mov       al,ah                    ; omezen° á°sla form†tu
         dec       al
IniDPar3:mov       ds:[AktForm],al          ; aktivn° form†t

; ------ adresa aktivn°ho form†tu disku

;         dec       al                       ; aktivn° form†t - 1
;         jns       IniDPar4
;         jmp       IniDPar9                 ; je automatickò form†t
IniDPar4:mov       ah,FORMOFFS              ; dÇlka definice jednoho form†tu
         mul       ah                       ; offset aktivn°ho form†tu
         add       si,ax                    ; adresa aktivn°ho form†tu

; ------ poáet stop

         mov       al,39                    ; 40 stop
         test      byte ptr ds:[si+0],b0    ; je 80 stop ?
         jz        IniDPr41                 ; je 40 stop
         mov       al,79                    ; jinak 80 stop
IniDPr41:mov       ds:[TypStop],al          ; jmenovitò poáet stop - 1
         inc       ax                       ; jmenovitò poáet stop
         add       al,ds:[ParStop]          ; p©iáten° dopl§uj°c°ch stop
         mov       ds:[NumStop],al          ; poáet stop

; ------ poáet stran

         mov       al,1                     ; 1 strana
         cmp       byte ptr ds:[ParStra],0  ; je 1 strana ?
         jne       IniDPr42                 ; je 1 strana
         mov       al,2                     ; 2 strany
IniDPr42:mov       ds:[NumStran],al         ; poáet stran

; ------ p©°znak dvojitÇho krokov†n°

         mov       al,1                     ; p©°znak dvojitÇho krokov†n°
         test      byte ptr ds:[si+0],b2    ; je dvojitÇ krokov†n° ?
         jnz       IniDPr43                 ; je dvojitÇ krokov†n°
         mov       al,0                     ; nen° dvojitÇ krokov†n°
IniDPr43:mov       ds:[Krokov],al           ; p©°znak dvojitÇho krokov†n°

; ------ poáet sektorñ na blok

         mov       al,1                     ; 1 sektor na blok
         cmp       byte ptr ds:[NumStran],1 ; je 1 strana ?
         je        IniDPr44                 ; je 1 strana
         test      byte ptr ds:[si+0],b1    ; 2 sektory na blok ?
         jz        IniDPr44                 ; 1 sektor na blok
         mov       al,2                     ; 2 sektory na blok
IniDPr44:mov       ds:[BlokSekt],al         ; poáet sektorñ na blok

; ------ poáet sektorñ na stopu

         mov       al,ds:[si+1]             ; poáet sektorñ na stopu
         mov       ds:[NumSekt],al          ; poáet sektorñ na stopu

; ------ odsazen° sektorñ SLIDING

         mov       byte ptr ds:[SlidX],0    ; vypnut° funkce Sliding
         mov       byte ptr ds:[SlidY],0
         test      byte ptr ds:[si+0],b5    ; prov†d° se SLIDING ?
         jz        IniDP444                 ; SLIDING se neprov†d°
         cmp       al,13                    ; je disketa HD ?
         mov       al,1                     ; SLIDING pro disketu DD = 1
         jbe       IniDP442                 ; je disketa DD
         inc       ax                       ; SLIDING pro disketu HD = 2
IniDP442:mov       ds:[SlidX],al            ; Sliding stran
         inc       ax
         mov       ds:[SlidY],al            ; Sliding stop

; ------ faktor prokl†d†n° sektorñ

IniDP444:mov       al,1                     ; faktor prokl†d†n° = 1
         test      byte ptr ds:[si+0],b4    ; je prokl†d†n° sektorñ = 2 ?
         jz        IniDP445                 ; je prokl†d†n° = 1
         inc       ax                       ; faktor prokl†d†n° = 2
IniDP445:mov       ds:[Inter],al            ; faktor prokl†d†n° sektorñ

; ------ poáet sektorñ na ROOT

         mov       al,ds:[si+2]             ; poáet sektorñ na ROOT
         cmp       byte ptr ds:[NumStran],1 ; je 1 strana ?
         jne       IniDPr45                 ; jsou 2 strany
         shr       al,1                     ; poáet sektorñ/2
         adc       al,0                     ; p©enos CF
IniDPr45:cmp       byte ptr ds:[ParRoot],0  ; zad†n poáet poloëek na ROOT ?
         je        IniDPr46                 ; nen° zad†n poáet poloëek na Root
         mov       byte ptr ds:[BlokSekt],1 ; vëdy je 1 sektor na blok
         mov       al,ds:[ParRoot]          ; poáet poloëek na ROOT
IniDPr46:mov       ds:[RootSekt],al         ; poáet sektorñ na ROOT
         mov       ah,0
         shl       ax,1
         shl       ax,1
         shl       ax,1
         shl       ax,1
         mov       ds:[RootMax],ax          ; poáet poloëek na ROOT

; ------ popisovaá mÇdia

         mov       al,ds:[si+3]             ; popisovaá mÇdia
         cmp       byte ptr ds:[NumStran],1 ; je 1 strana ?
         je        IniDPr47                 ; je 1 strana
         or        al,1                     ; korekce pro 2 strany
IniDPr47:mov       ds:[Popis],al            ; popisovaá mÇdia

; ------ celkovò poáet sektorñ mÇdia

         mov       al,ds:[NumSekt]          ; poáet sektorñ na stopu
         mul       byte ptr ds:[NumStran]   ; vyn†soben° poátem stran
         mul       byte ptr ds:[NumStop]    ; vyn†soben° poátem sektorñ
         mov       ds:[CelkSekt],ax         ; celkovò poáet sektorñ mÇdia

; ------ p©°prava k nalezen° dostateánÇho poátu sektorñ na FAT

         mov       byte ptr ds:[FatSekt],1  ; vòchoz° hodnota - 1 sektor na FAT

; ------ poáet alokaán°ch blokñ

IniDPar5:mov       ax,ds:[CelkSekt]         ; celkovò poáet sektorñ
         dec       ax                       ; odeáten° BOOT sektoru
         mov       bh,0
         mov       bl,ds:[FatSekt]          ; poáet sektorñ na FAT
         sub       ax,bx                    ; odeáten° sektorñ na FAT 1
         sub       ax,bx                    ; odeáten° sektorñ na FAT 2
         sub       al,ds:[RootSekt]         ; odeáten° sektorñ na ROOT
         sbb       ah,0
         xor       dx,dx
         mov       bl,ds:[BlokSekt]         ; poáet sektorñ na alokaán° blok
         div       bx                       ; vòpoáet poátu alokaán°ch blokñ
         mov       ds:[CelkBlok],ax         ; celkovò poáet alokaán°ch blokñ

; ------ vòpoáet kapacity tabulek FAT

         mov       ah,ds:[FatSekt]          ; poáet sektorñ na FAT
         mov       al,0
         shl       ax,1                     ; poáet bajtñ na FAT
         shl       ax,1                     ; poáet tetr†d
         xor       dx,dx
         mov       bl,3                     ; poáet tetr†d na poloëku FAT
         div       bx                       ; vòpoáet poátu poloëek FAT
         sub       ax,2 + 16                ; odeáten° rezervovanòch hodnot

; ------ kontrola, zda je poáet poloëek FAT postaáuj°c°

         cmp       ax,ds:[CelkBlok]         ; staá° poáet poloëek FAT ?
         jae       IniDPar6                 ; poáet poloëek FAT je postaáuj°c°
         inc       byte ptr ds:[FatSekt]    ; zvò®en° poátu poloëek FAT
         jmp       short IniDPar5           ; novò test

; ------ poáet bajtñ na alokaán° blok

IniDPar6:mov       ah,ds:[BlokSekt]         ; poáet sektorñ na alokaán° blok
         mov       al,0
         shl       ax,1                     ; poáet sektorñ * 512 bajtñ
         mov       ds:[BlokByte],ax         ; poáet bajtñ na alokaán° blok

; ------ vòpoáet celkovÇ kapacity disku

         mov       ax,ds:[CelkBlok]         ; celkovò poáet alokaán°ch blokñ
         mul       word ptr ds:[BlokByte]   ; vyn†soben° poátem bajtñ na blok
         mov       word ptr ds:[CelkKap],ax ; celkov† kapacita LOW
         mov       word ptr ds:[CelkKap+2],dx ; celkov† kapacita HIGH

; ------ n†vrat registrñ

IniDPar9:pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

IniDPar  ENDP

; -----------------------------------------------------------------------------
;        stanoven° poátu a typñ disketovòch mechanik
; -----------------------------------------------------------------------------

GetDTyp  PROC      NEAR

; ------ stanoven° poátu disketovòch mechanik v systÇmu

         push      ds
         int       11h                      ; poskytnut° vòpisu vybaven°
         pop       ds
         test      al,b0                    ; je v systÇmu nàjak† mechanika ?
         jz        GetDTyp9                 ; v systÇmu nen° ë†dn† mechanika
         rol       al,1
         rol       al,1
         and       al,3                     ; poáet disketovòch mechanik - 1
         inc       ax                       ; poáet disketovòch mechanik
         mov       ds:[NumDisk],al          ; poáet disketovòch mechanik

; ------ stanoven° typñ jednotlivòch diskñ

         mov       si,offset TypDiskT       ; tabulka typñ diskñ
         mov       dl,0                     ; ukazatel á°sla disku

GetDTyp1:push      dx
         push      si

         mov       ax,86eh                  ; funkce 8, AL=nesmysl pro kontrolu
         xor       cx,cx                    ; p©ednastaven° nesmyslñ
         mov       bl,0                     ; p©ednastaven° - nezn†mò typ
         call      Int13                    ; poskytnut° parametrñ disku

         pop       si
         pop       dx

; ------ stanoven° typu disku

         or        ax,ax
         jnz       GetDTyp3                 ; funkce nen° podporovan†
         cmp       bl,0                     ; je typ mechaniky zn†m ?
         je        GetDTyp2                 ; typ mechaniky nen° zn†m
         cmp       bl,5
         jbe       GetDTyp4                 ; typ mechaniky je OK
GetDTyp2:cmp       ch,79                    ; je 80 stop ?
         jb        GetDTyp3                 ; je asi mechanika 360 KB
         mov       bl,3                     ; mechanika 702 KB
         cmp       cl,13
         jbe       GetDTyp4                 ; mechanika 720 KB
         mov       bl,2                     ; mechanika 1.2 MB
         cmp       cl,16
         jbe       GetDTyp4                 ; mechanika 1.2 MB
         mov       bl,4                     ; mechanika 1.44 MB
         cmp       cl,20
         jbe       GetDTyp4                 ; mechanika 1.44 MB
         mov       bl,5                     ; jinak mechanika 2.88 MB
         jmp       short GetDTyp4

; ------ p©°prava pro dal®° disk

GetDTyp3:mov       bl,1                     ; mechanika 360 KB
GetDTyp4:mov       ds:[si],bl               ; typ disketovÇ mechaniky
         inc       si                       ; zvò®en° ukazatele v tabulce
         inc       dx                       ; zvò®en° á°sla disku
         cmp       dl,ds:[NumDisk]          ; jsou jië v®echny disky ?
         jb        GetDTyp1                 ; stanoven° dal®°ho disku

GetDTyp9:ret

GetDTyp  ENDP

; -----------------------------------------------------------------------------
;        zform†tov†n° aktu†ln° stopy (CY=chyba, AH=k¢d chyby)
; -----------------------------------------------------------------------------

Format   PROC      NEAR

; ------ zobrazen° indik†toru form†tov†n°

         mov       al,"F"
         mov       ah,ds:[ColForm]          ; barva
         call      DispFCh                  ; zobrazen° indik†toru

; ------ stanoven° á°sla poá†teán°ho sektoru

         mov       al,ds:[SlidX]            ; odsazen° sektorñ stran
         add       al,ds:[SlidY]            ; selkovÇ odsazen° na stopu
         mul       byte ptr ds:[AktStop]    ; posun odsazen°m p©ede®lòch stop
         cmp       byte ptr ds:[AktStran],0 ; je strana 0 ?
         je        Format02                 ; je strana 0
         add       al,ds:[SlidX]            ; je®tà jedno odsazen° strany
         adc       ah,0                     ; p©enos
Format02:div       byte ptr ds:[NumSekt]    ; maskov†n° MOD poáet sektorñ
         mov       al,ah                    ; poá†teán° á°slo sektoru - 1
         inc       ax                       ; poá†teán° á°slo sektoru

; ------ p©°prava registrñ ke generov†n° tabulky

         clc
         xor       di,di
         mov       es,ds:[BufferW]          ; z†pisovò buffer
         mov       dl,ds:[AktStop]          ; aktu†ln° form†tovan† stopa
         mov       dh,ds:[AktStran]         ; aktu†ln° form†tovan† strana
         mov       ah,2                     ; velikost sektoru
         mov       ch,0
         mov       cl,ds:[NumSekt]          ; poáet sektorñ na stopu
         mov       bp,cx                    ; poáet sektorñ na stopu
         shl       bp,1
         shl       bp,1                     ; * 4 = offset konce tabulky
         mov       bl,ds:[Inter]            ; faktor prokl†d†n°
         mov       bh,0
         dec       bx
         shl       bx,1
         shl       bx,1                     ; faktor prokl†d†n° * 4 - 4

; ------ generov†n° definián° tabulky stopy

Format1: xchg      ax,dx
         stosw                              ; á°slo v†lce a hlavy
         xchg      ax,dx
         stosw                              ; á°slo a velikost sektoru
         add       di,bx                    ; korekce prokl†d†n°
         inc       ax                       ; zvò®en° á°sla stopy
         cmp       al,ds:[NumSekt]          ; p©ekroáeno á°slo sektoru ?
         jbe       Format2                  ; á°slo sektoru je OK
         mov       al,1                     ; korekce na sektor 1
Format2: cmp       di,bp                    ; p©ekroáen konec tabulky ?
         jb        Format3                  ; adresa je OK
         mov       di,4                     ; korekce adresy na 2. sektor
Format3: loop      Format1

; ------ form†tov†n° stopy

         mov       ah,5
         inc       cl                       ; poá†teán° á°slo sektoru = 1
         mov       al,ds:[NumSekt]          ; poáet sektorñ
         xor       bx,bx                    ; adresa tabulky definice sektorñ
         mov       dl,ds:[AktDisk]          ; aktivn° disk
         mov       ch,ds:[AktStop]          ; aktu†ln° stopa
         call      Int13                    ; form†tov†n° stopy
         ret

Format   ENDP

; -----------------------------------------------------------------------------
;     áten° AL sektorñ od sektoru CL do bufferu ES:BX -> CY chyba, AH=k¢d chyby
; -----------------------------------------------------------------------------

Cteni    PROC      NEAR

; ------ zobrazen° indik†toru

         push      ax
         mov       al,"R"
         mov       ah,ds:[ColRead]          ; barva
         call      DispFCh                  ; zobrazen° indik†toru
         pop       ax

; ------ áten° dat z disku

         mov       ah,2
         mov       ch,ds:[AktStop]          ; á°slo v†lce
         mov       dh,ds:[AktStran]         ; á°slo strany
         call      Int130                   ; z†pis dat na disk
         ret

Cteni    ENDP

; -----------------------------------------------------------------------------
;     z†pis AL sektorñ od sektoru CL z bufferu ES:BX -> CY chyba, AH=k¢d chyby
; -----------------------------------------------------------------------------

Zapis    PROC      NEAR

; ------ zobrazen° indik†toru

         push      ax
         mov       al,"W"
         mov       ah,ds:[ColWrite]         ; barva
         call      DispFCh                  ; zobrazen° indik†toru
         pop       ax

; ------ z†pis dat na disk

         mov       ah,3
         mov       ch,ds:[AktStop]          ; á°slo v†lce
         mov       dh,ds:[AktStran]         ; á°slo strany
         call      Int130                   ; z†pis dat na disk
         ret

Zapis    ENDP

; -----------------------------------------------------------------------------
;        verifikace dat diskety (CY=chyba, AH=k¢d chyby)
; -----------------------------------------------------------------------------

Verif    PROC      NEAR

; ------ zobrazen° indik†toru

         mov       al,"V"
         mov       ah,ds:[ColVerif]         ; barva
         call      DispFCh                  ; zobrazen° indik†toru

; ------ verifikace stopy z disku

         xor       bx,bx                    ; offset adresy
         mov       es,bx
         mov       al,ds:[NumSekt]          ; poáet sektorñ
         mov       ah,4
         mov       ch,ds:[AktStop]          ; á°slo v†lce
         mov       cl,1                     ; poá†teán° á°slo sektoru
         mov       dh,ds:[AktStran]         ; strana
         call      Int130                   ; áten° dat z disku
         ret

Verif    ENDP

; -----------------------------------------------------------------------------
;        nastaven° form†tu diskety pro form†tov†n° (CY=chyba, AH=k¢d chyby)
; -----------------------------------------------------------------------------

SetForm  PROC      NEAR

; ------ nastaven° form†tu sluëbou 18h

         mov       bp,3                     ; poáet pokusñ
SetForm1:mov       ah,18h
         mov       ch,ds:[TypStop]          ; jmenovitò poáet stop disku
         mov       cl,ds:[NumSekt]          ; max. poáet sektorñ
         cmp       cl,8
         jne       SetForm3
         mov       cl,9
SetForm3:call      Int13                    ; nastaven° form†tu diskety
         jnc       SetForm4
         cmp       ah,1
         je        SetForm5                 ; funkce nepodporovan†

         call      ResDisk
         dec       bp
         jnz       SetForm1                 ; dal®° pokus
         stc
         jmp       short SetForm9           ; chyba

; ------ inicializace tabulky parametrñ

SetForm4:mov       bl,cl
         mov       cx,12
         push      ds
         push      ds
         push      es
         pop       ds
         pop       es
         mov       si,di
         mov       di,offset Int1e
         rep       movsb                    ; £schova tabulky parametrñ
         pop       ds
         mov       cl,bl

SetForm5:mov       bl,cl
         mov       si,offset Int1e
         mov       byte ptr ds:[si+2],4     ; áas pro vypnut° motoru
         mov       byte ptr ds:[si+3],2     ; velikost sektoru 512 bajtñ
         mov       byte ptr ds:[si+4],bl    ; poáet sektorñ na stopu
         mov       byte ptr ds:[si+8],0     ; plnic° znak form†tov†n°
         clc                                ; p©°znak operace OK

SetForm9:
         ret

SetForm  ENDP

; -----------------------------------------------------------------------------
;        reset diskovÇho systÇmu
; -----------------------------------------------------------------------------

ResDisk  PROC      NEAR

         push      ax
         mov       ah,0
         call      Int130
         pop       ax
         ret

ResDisk  ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 13 s £schovou v®ech registrñ
; -----------------------------------------------------------------------------

Int130   PROC      NEAR

         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

         call      Int13

         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         ret

Int130   ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 13 s £schovou registrñ
; -----------------------------------------------------------------------------

Int13    PROC      NEAR

         push      bp
         push      ds

         sti
         mov       dl,ds:[AktDisk]          ; aktivn° disk
         int       13h

         pop       ds
         pop       bp
         ret

Int13    ENDP

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                               Volby parametrñ
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
; -----------------------------------------------------------------------------
;        volby parametrñ
; -----------------------------------------------------------------------------

Volby    PROC      NEAR

; ------ zobrazen° voleb

         mov       byte ptr ds:[AktVolby],1 ; p©°znak aktivn°ch voleb
         call      DispVol                  ; zobrazen° voleb
         call      DispADsk                 ; zobrazen° diskñ
         call      KurzOff

; ------ vstup z ovladaáe my®i

Volby1:  call      MouseGet                 ; test my®i
         cmp       bl,4
         jne       Volby11
         jmp       Volby7                   ; stisk pravÇho tlaá°tka
Volby11: cmp       bl,6
         je        Volby12                  ; druhò stisk levÇho tlaá°tka
         cmp       bl,3
         je        Volby12                  ; stisk levÇho tlaá°tka
         test      byte ptr ds:[MouseKey],b0 ; je levÇ tlaá°tko stisknuto ?
         je        Volby5                   ; nen° levÇ tlaá°tko stisknuto
         jmp       short Volby22            ; vodàn° kurzoru po poloëk†ch

; ------ test, zda je ovl†d†n° n†povàdy

Volby12: cmp       dh,24
         jne       Volby2
         cmp       dl,42
         jb        Volby5                   ; neplatn† kl†vesa
         mov       bx,0dh
         cmp       dl,54
         jbe       Volby6                   ; ENTER
         cmp       dl,65
         jbe       Volby7                   ; ESC
         mov       bx,3b00h
         jmp       short Volby6             ; jinak F1

; ------ test, zda je platnò ©†dek poloëek

Volby2:  cmp       dh,9
         ja        Volby7                   ; p©eru®en° voleb
Volby22: cmp       dh,3
         jb        Volby5
         cmp       dh,7
         ja        Volby5

; ------ rozli®en° sloupce poloëek

         or        dl,dl
         jz        Volby5
         cmp       dl,79
         je        Volby5
         cmp       dl,25
         jae       Volby3
         mov       dl,4
         jmp       short Volby4
Volby3:  cmp       dl,50
         mov       dl,28
         jb        Volby4
         mov       dl,53

; ------ test, zda je platn† poloëka

Volby4:  call      SrcPol
         jc        Volby5                   ; nen° platn† poloëka
         cmp       bl,3
         je        Volby42
         cmp       bl,6
         je        Volby42
         cmp       al,ds:[AktVol]
         je        Volby5
         mov       ds:[AktVol],al           ; á°slo novÇ aktivn° poloëky
         call      DispVol
         jmp       short Volby5

Volby42: mov       ds:[AktVol],al           ; á°slo novÇ aktivn° poloëky
         call      DispVol
         mov       bx,0dh                   ; kl†vesa ENTER
         jmp       short Volby6             ; zmàna poloëky

; ------ vstup znaku z kl†vesnice

Volby5:  call      TestKey
         jnc       Volby52
Volby51: jmp       Volby1                   ; áek†n° na stisk kl†vesy

Volby52: call      InpKey
         cmp       bl,1bh
         je        Volby7                   ; p©eru®en° ESC

Volby6:  call      EditVol                  ; editace voleb
         jmp       short Volby51            ; dal®° kl†vesa

; ------ zobrazen° voleb

Volby7:  mov       byte ptr ds:[AktVolby],0 ; p©°znak aktivn°ch voleb
         call      IniDPar                  ; inicializace diskovòch parametrñ
         call      DispVol                  ; zobrazen° voleb
         call      DispADsk                 ; zobrazen° diskñ
         ret

Volby    ENDP

; -----------------------------------------------------------------------------
;        editace voleb (BX=kl†vesa)
; -----------------------------------------------------------------------------

EditVol  PROC      NEAR

         mov       al,ds:[AktVol]
         call      GetPol
         mov       di,ds:[si+1]
         mov       al,ds:[di]
         mov       dx,ds:[si+3]
         mov       cl,ds:[si+6]

         call      JumpBX                   ; obsluha kl†vesy BX

         dw        5100h,EditVl41           ; Page Down
         dw        4900h,EditVl30           ; Page Up
         dw        4f00h,EditVl82           ; End
         dw        4700h,EditVl72           ; Home
         dw        0f00h,EditVol8           ; Shift-Tab
         dw        9,EditVol7               ; Tabel†tor
         dw        4d00h,EditVol6           ; vpravo
         dw        4b00h,EditVol5           ; vlevo
         dw        4800h,EditVol8           ; nahoru
         dw        5000h,EditVol7           ; dolñ
         dw        20h,EditVol2             ; mezera
         dw        0dh,EditVol2             ; ENTER
         dw        0,EditVol1

EditVol1:ret

; ------ mezera, Enter

EditVol2:test      byte ptr ds:[si+0],b0
         jz        EditVl22
         cmp       al,0
         mov       al,0
         jne       EditVl21
         not       al
EditVl21:mov       ds:[di],al
         call      DispVol
         ret

; ------ á°seln† poloëka

EditVl22:test      byte ptr ds:[si+0],b1
         jz        EditVl24

         push      dx
         push      si
         mov       ah,ds:[ColHelp]
         mov       si,offset PocZHlp        ; poáet ovà©ovac°ch z†pisñ
         cmp       dh,4
         je        EditVl23
         mov       si,offset PocPHlp        ; poáet dopl§uj°c°ch stop
EditVl23:mov       dx,24*HI
         call      Disp0Txt
         pop       si
         pop       dx

         mov       ch,ds:[ColEdi]
         add       dl,ds:[si+5]
         mov       ah,0
         cmp       dh,4
         je        EditV232
         cmp       byte ptr ds:[TypStop],40
         ja        EditV232
         shr       al,1
EditV232:call      EditNum
         cmp       dh,4
         je        EditV234
         cmp       byte ptr ds:[TypStop],40
         ja        EditV233
         shl       al,1
EditV233:cmp       al,6
         jbe       EditV234
         mov       al,6
EditV234:mov       ds:[di],al
         call      DispVol
         ret

; ------ hexadecim†ln° poloëka

EditVl24:test      byte ptr ds:[si+0],b2
         jz        EditVl26

         push      dx
         push      si
         mov       ah,ds:[ColHelp]
         mov       si,offset HexFHlp        ; znak pro form†tov†n°
         mov       dx,24*HI
         call      Disp0Txt
         pop       si
         pop       dx

         mov       ah,ds:[ColEdi]
         add       dl,ds:[si+5]
         call      EditHByt
         jmp       short EditVl21

; ------ volba áe®tiny

EditVl26:test      byte ptr ds:[si+0],b3
         jz        EditVl28
         inc       ax
         cmp       al,3
EditVl27:jbe       EditV271
         mov       al,0
EditV271:mov       ds:[di],al
         call      InitFont                 ; inicializace fontñ
         call      DispADsk                 ; zobrazen° v®ech diskñ
         ret

; ------ volba zachov†n° dat

EditVl28:
;test      byte ptr ds:[si+0],b4
         ;jz        EditVl29
         ;inc       ax
         ;cmp       al,2

; ------ volba poátu poloëek v ROOT

EditVl29:test      byte ptr ds:[si+0],b5
         jz        EditVl2a

         push      dx
         push      si
         mov       ah,ds:[ColHelp]
         mov       dx,24*HI
         mov       si,offset RootHlp
         call      Disp0Txt
         pop       si
         pop       dx

         mov       ch,ds:[ColEdi]
         add       dl,ds:[si+5]
         mov       ah,0
         shl       ax,1
         shl       ax,1
         shl       ax,1
         shl       ax,1                     ; poáet poloëek ROOT
         call      EditNum
         add       ax,15                    ; zaokrouhlen° nahoru
         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1
         cmp       al,62
         jbe       EditV211
         mov       al,62
EditV211:jmp       EditVL21

EditVl2a:ret

; ------ Page Down

EditVl41:mov       dh,7
         jmp       short EditVl31

; ------ vlevo

EditVol5:cmp       dl,4
         jne       EditVl53
         mov       dl,53
         jmp       short EditVl31
EditVl53:cmp       dl,28
         mov       dl,4
         je        EditVl31
         mov       dl,28
         jmp       short EditVl31

; ------ Page Up

EditVl30:mov       dh,3
EditVl31:call      SrcPol
EditVl32:mov       ds:[AktVol],al
         call      DispVol
         ret

; ------ vpravo

EditVol6:cmp       dl,53
         jne       EditVl62
         mov       dl,4
         jmp       short EditVl31
EditVl62:cmp       dl,28
         mov       dl,53
         je        EditVl31
         mov       dl,28
         jmp       short EditVl31

; ------ tabel†tor

EditVol7:mov       al,ds:[AktVol]
         inc       al
         cmp       al,NUMVOL
         jb        EditVl32
EditVl72:mov       al,0
         jmp       short EditVl32

; ------ zpàtnò tabel†tor

EditVol8:mov       al,ds:[AktVol]
         dec       al
         jns       EditVl32
EditVl82:mov       al,NUMVOL-1
         jmp       short EditVl32

EditVol  ENDP

; -----------------------------------------------------------------------------
;        nalezen° poloëky se sou©adnicemi DX -> AL (CY=nenalezeno)
; -----------------------------------------------------------------------------

SrcPol   PROC      NEAR

         push      cx
         push      si

         mov       ch,0
         mov       si,offset VolDef
         mov       al,0
SrcPol1: cmp       dx,ds:[si+3]
         je        SrcPol9
         add       si,VOLOFFS
         inc       ax
         cmp       si,offset VolDef0
         jb        SrcPol1
         stc

SrcPol9: pop       si
         pop       cx
         ret

SrcPol   ENDP

; -----------------------------------------------------------------------------
;        nalezen° adresy poloëky AL -> SI
; -----------------------------------------------------------------------------

GetPol   PROC      NEAR

         push      ax
         mov       ah,VOLOFFS
         mul       ah
         add       ax,offset VolDef
         xchg      ax,si
         pop       ax
         ret

GetPol   ENDP

; -----------------------------------------------------------------------------
;     editace á°sla AX (CL=®°©ka pole, CH=barva, DX=pozice)
; -----------------------------------------------------------------------------

EditNum  PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      dx
         push      si

; ------ prvn° zobrazen° á°sla

         mov       si,ax                    ; pñvodn° hodnota á°sla
         xor       bx,bx
         push      dx
         call      MouseOff
         call      DispNum                  ; zobrazen° á°sla
         call      MouseOn
         dec       dl
         call      SetKurz                  ; zobrazen° kurzoru
         pop       dx

; ------ áek†n° na prvn° kl†vesu

EditNum1:push      dx
         call      MouseGet
         pop       dx
         cmp       bl,3
         jne       EditNm11
EditNm10:jmp       EditNum8                 ; levÇ tlaá°tko
EditNm11:cmp       bl,4
         je        EditNm10                 ; pravÇ tlaá°tko
         call      TestKey
         jc        EditNum1

         call      InpKey                   ; vstup znaku z kl†vesnice
         cmp       bh,53h
         jne       EditNm14
EditNm13:jmp       EditNum7                 ; Delete
EditNm14:cmp       bl,8
         je        EditNm13                 ; Bs
         cmp       bl,1bh                   ; ESC
         je        EditNm10                 ; p©eru®en° editace
         cmp       bl,0dh                   ; ENTER
         je        EditNm10                 ; á°slo se nemàn°
         sub       bx,"0"
         jb        EditNum1                 ; neplatn† kl†vesa
         cmp       bl,9
         ja        EditNum1                 ; neplatn† kl†vesa
         xor       ax,ax                    ; vòchoz° hodnota á°sla

; ------ p©id†n° novÇ á°slice k á°slu

EditNum2:push      dx
         mov       dx,10
         mul       dx                       ; á°slo * 10
         pop       dx
         add       ax,bx                    ; p©id†n° zadanÇho á°sla

; ------ stanoven° maxim†ln° hodnoty á°sla

         mov       bl,10
         cmp       cl,1
         je        EditNum3
         mov       bl,100
         cmp       cl,2
         je        EditNum3
         mov       bx,1000
         cmp       cl,3
         je        EditNum3
         mov       bx,10000

; ------ omezen° velikosti á°sla

EditNum3:cmp       ax,bx
         jb        EditNum4                 ; nen° p©esah á°sla
         push      dx
         xor       dx,dx
         div       bx                       ; zarovn†n° á°sla
         xchg      ax,dx                    ; AX <- zbytek á°sla
         pop       dx

; ------ zobrazen° novÇ hodnoty á°sla

EditNum4:xor       bx,bx
         push      dx
         call      MouseOff
         call      DispNum
         call      MouseOn
         pop       dx

; ------ áek†n° na dal®° kl†vesu

EditNum6:push      dx
         call      MouseGet
         pop       dx
         cmp       bl,3
         jne       EditNm62                 ; nen° levÇ tlaá°tko
         cmp       dh,byte ptr ds:[MousePoz+1]
         jne       EditNum8
         cmp       dl,byte ptr ds:[MousePoz]
         ja        EditNum8
         mov       bl,dl
         add       bl,cl
         cmp       bl,byte ptr ds:[MousePoz]
         ja        EditNum9
         jmp       short EditNum8

EditNm62:cmp       bl,4
         je        EditNum8                 ; pravÇ tlaá°tko
         call      TestKey
         jc        EditNum6

EditNm64:call      TestKey
         jc        EditNum6

         call      InpKey
         cmp       bh,53h
         je        EditNum7                 ; Delete
         cmp       bl,8
         je        EditNum7                 ; Bs
         cmp       bl,1bh
         je        EditNum8                 ; p©eru®en° editace
         cmp       bl,0dh
         je        EditNum9                 ; ukonáen° volby ENTER
         sub       bx,"0"
         jb        EditNum6
         cmp       bl,9
         ja        EditNum6
         jmp       EditNum2

; ------ zru®en° posledn° á°slice BS, DELETE

EditNum7:mov       bx,10
         push      dx
         xor       dx,dx
         div       bx
         pop       dx
         jmp       short EditNum4           ; dal®° kl†vesa

; ------ p©eru®en° ESC, navr†cen° pñvodn°ho á°sla

EditNum8:mov       ax,si                    ; pñvodn° á°slo
EditNum9:xor       bx,bx
         call      MouseOff
         call      DispNum                  ; zobrazen° vòslednÇ hodnoty á°sla
         call      MouseOn
         call      KurzOff                  ; vypnut° kurzoru

; ------ n†vrat registrñ

         pop       si
         pop       dx
         pop       bx
         ret

EditNum  ENDP

; -----------------------------------------------------------------------------
;        editace hexadecim†ln°ho bajtu AL (AH=barva, DX=pozice)
; -----------------------------------------------------------------------------

EditHByt PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      cx
         push      dx

; ------ prvn° zobrazen° á°sla

         mov       ch,al                    ; pñvodn° hodnota á°sla
         push      dx
         call      MouseOff
         call      DispHByt
         call      MouseOn
         dec       dl
         call      SetKurz                  ; zobrazen° kurzoru
         pop       dx

; ------ áek†n° na prvn° kl†vesu

EditHBy1:push      dx
         call      MouseGet
         pop       dx
         cmp       bl,3
         jne       EditHB11
EditHB10:jmp       EditHBy8                 ; levÇ tlaá°tko
EditHB11:cmp       bl,4
         je        EditHB10                 ; pravÇ tlaá°tko
         call      TestKey
         jc        EditHBy1

         call      InpKey                   ; vstup znaku z kl†vesnice
         cmp       bh,53h
         jne       EditHB14
EditHB13:jmp       EditHBy7                 ; Delete
EditHB14:cmp       bl,8
         je        EditHB13                 ; Bs
         cmp       bl,1bh                   ; ESC
         je        EditHB10                 ; p©eru®en° editace
         cmp       bl,0dh                   ; ENTER
         je        EditHB10                 ; á°slo se nemàn°
         sub       bl,"0"
         jb        EditHBy1                 ; neplatn† kl†vesa
         cmp       bl,9
         jbe       EditHB17
         sub       bl,7
         cmp       bl,15
         ja        EditHBy1
         cmp       bl,10
         jb        EditHBy1
EditHB17:mov       al,0                     ; vòchoz° hodnota á°sla

; ------ p©id†n° novÇ á°slice k á°slu

EditHBy2:shl       al,1
         shl       al,1
         shl       al,1
         shl       al,1
         or        al,bl                    ; p©id†n° zadanÇho á°sla

; ------ zobrazen° novÇ hodnoty á°sla

EditHBy4:push      dx
         call      MouseOff
         call      DispHByt
         call      MouseOn
         pop       dx

; ------ áek†n° na dal®° kl†vesu

EditHBy6:push      dx
         call      MouseGet
         pop       dx
         cmp       bl,3
         jne       EditHB62                 ; nen° levÇ tlaá°tko
         cmp       dh,byte ptr ds:[MousePoz+1]
         jne       EditHBy8
         cmp       dl,byte ptr ds:[MousePoz]
         ja        EditHBy8
         mov       bl,dl
         add       bl,2
         cmp       bl,byte ptr ds:[MousePoz]
         ja        EditHBy9
         jmp       short EditHBy8

EditHB62:cmp       bl,4
         je        EditHBy8                 ; pravÇ tlaá°tko
         call      TestKey
         jc        EditHBy6

EditHB64:call      TestKey
         jc        EditHBy6

         call      InpKey
         cmp       bh,53h
         je        EditHBy7                 ; Delete
         cmp       bl,8
         je        EditHBy7                 ; Bs
         cmp       bl,1bh                   ; ESC
         je        EditHBy8                 ; p©eru®en° editace
         cmp       bl,0dh                   ; ENTER
         je        EditHBy9                 ; konec editace
         sub       bl,"0"
         jb        EditHBy6                 ; neplatn† kl†vesa
         cmp       bl,9
         jbe       EditHBy2
         sub       bl,7
         cmp       bl,15
         ja        EditHBy6
         cmp       bl,10
         jb        EditHBy6
         jmp       short EditHBy2

; ------ Delete

EditHBy7:shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1
         jmp       short EditHBy4

; ------ p©eru®en° ESC, navr†cen° pñvodn°ho á°sla

EditHBy8:mov       al,ch                    ; pñvodn° á°slo
EditHBy9:call      MouseOff
         call      DispHByt                 ; zobrazen° vòslednÇ hodnoty á°sla
         call      MouseOn
         call      KurzOff                  ; vypnut° kurzoru

; ------ n†vrat registrñ

         pop       dx
         pop       cx
         pop       bx
         ret

EditHByt ENDP

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                           Obsluha zobrazen°
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
; -----------------------------------------------------------------------------
;        zobrazen° znaku AX na pozici form†tov†n°
; -----------------------------------------------------------------------------

DispFCh  PROC      NEAR

         push      cx
         push      dx

         mov       dx,ds:[PozMap]           ; poá†tek okna
         inc       dh
         add       dl,11
         mov       cl,ds:[AktStop]          ; stopa
         mov       ch,ds:[NumStop]
         cmp       ch,60
         jb        DispFCh1
         shr       ch,1
DispFCh1:cmp       cl,ch
         jb        DispFCh2
         sub       cl,ch
         add       dh,6
         cmp       byte ptr ds:[NumStran],2
         je        DispFCh2
         dec       dh
DispFCh2:add       dl,cl
         add       dh,ds:[AktStran]
         call      Disp1Chr

         pop       dx
         pop       cx
         ret

DispFCh  ENDP

; -----------------------------------------------------------------------------
;        zobrazen° informaán°ho okna o prñbàhu form†tov†n°
; -----------------------------------------------------------------------------
;˛
DispInf  PROC      NEAR

         call      MouseOff
         push      ax
         push      bx
         push      cx
         push      dx
         push      si

         mov       al,ds:[SelChar]
         mov       ds:[TextOK+2],al

; ------ zobrazen° st°nu pod oknem

         mov       dx,11*HI+59
         mov       cx,11*HI+18
         call      StinWin

; ------ zobrazen° horn° linky okna

         mov       dx,11*HI+59
         mov       ah,ds:[ColRFR]
         mov       al,"…"
         call      Disp1Chr
         mov       cl,16
         mov       al,"Õ"
         call      DispChr
         mov       al,"ª"
         call      Disp1Chr

; ------ vnit©n° ©†dky okna

         mov       ch,9                     ; poáet ©†dkñ
DispInf2:mov       dl,59
         inc       dh
         mov       al,"∫"
         call      Disp1Chr
         mov       al," "
         call      DispChr
         mov       al,"∫"
         call      Disp1Chr
         dec       ch
         jnz       DispInf2

; ------ spodn° ©†dek okna

         inc       dh
         mov       dl,59
         mov       al,"»"
         call      Disp1Chr
         mov       al,"Õ"
         call      DispChr
         mov       al,"º"
         call      Disp1Chr

; ------ zobrazen° textñ nadpisñ

         mov       dx,12*HI+60
         mov       si,offset TextKap
         mov       ah,ds:[ColRF]
         call      Disp0Txt

         mov       dx,13*HI+61
         mov       si,offset TextVol
         call      Disp0Txt

         mov       dx,14*HI+61
         mov       si,offset TextBad
         call      Disp0Txt

; ------ text "doba"

         mov       dx,19*HI+63
         mov       si,offset TextDob
         call      Disp0Txt

; ------ oddàlovac° linky

         mov       dx,15*HI+60
         mov       cl,16
         mov       ah,ds:[ColRFR]
         mov       al,"ƒ"
         call      DispChr
         mov       dx,18*HI+60
         call      DispChr
         mov       byte ptr ds:[CitSek],1 ; p©°znak k okamëitÇmu zobrazen° áasu

; ------ n†vrat registrñ

         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         call      MouseOn
                                            ; pokraáuje zobrazen° kapacit !!!

DispInf  ENDP

; -----------------------------------------------------------------------------
;        zobrazen° kapacit disku v informaán°m oknà
; -----------------------------------------------------------------------------

DispKap  PROC      NEAR

         call      MouseOff
         push      ax
         push      bx
         push      cx
         push      dx
         push      si

; ------ zobrazen° celkovÇ kapacity

         mov       dx,12*HI+67
         mov       ch,ds:[ColRF0]
         mov       ax,word ptr ds:[CelkKap]
         mov       bx,word ptr ds:[CelkKap+2]
         mov       cl,1
         call      DispNum

; ------ zobrazen° volnÇ kapacity

         mov       dx,13*HI+67
         mov       ax,word ptr ds:[CitVol]
         mov       bx,word ptr ds:[CitVol+2]
         mov       cl,1
         call      DispNum

; ------ zobrazen° vadnÇ kapacity

         mov       dx,14*HI+67
         mov       ax,word ptr ds:[CitBad]
         mov       bx,word ptr ds:[CitBad+2]
         mov       cl,1
         call      DispNum

; ------ zobrazen° p©°znakñ

         mov       al,ds:[ErrBoot]
         mov       si,offset TextBoot
         mov       dx,16*HI+61
         call      DispInS

         mov       al,ds:[ErrRoot]
         mov       si,offset TextRoot
         mov       dx,17*HI+61
         call      DispInS

         mov       al,ds:[ErrFat1]
         mov       si,offset TextFat1
         mov       dx,16*HI+69
         call      DispInS

         mov       al,ds:[ErrFat2]
         mov       si,offset TextFat2
         mov       dx,17*HI+69
         call      DispInS

; ------ n†vrat registrñ

         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         call      MouseOn
         ret

DispKap  ENDP

; -----------------------------------------------------------------------------
;        zobrazen° jednoho p©°znaku (pozice DX, text SI, stav AL)
; -----------------------------------------------------------------------------

DispInS  PROC      NEAR

         mov       ah,ds:[ColRF]
         call      Disp0Txt
         mov       si,offset TextOK
         cmp       al,0                     ; je OK ?
         je        DispInS1
         mov       si,offset TextNOK
         cmp       al,0ffh                  ; vadnò ?
         je        DispInS1                 ; vadnò
         mov       si,offset TextXOK
DispInS1:mov       ah,ds:[ColRF0]
         call      Disp0Txt
         ret

DispInS  ENDP

; -----------------------------------------------------------------------------
;        zobrazen° mapy disku
; -----------------------------------------------------------------------------

DispMap  PROC      NEAR

; ------ £schova registrñ

         call      MouseOff
         push      ax
         push      bx
         push      cx
         push      dx
         push      si

; ------ p©edàlov† stopa mapy

         mov       al,ds:[NumStop]
         cmp       al,60
         jb        DispMp10
         shr       al,1
DispMp10:mov       ds:[CitMap],al           ; á°taá stop mapy

; ------ zobrazen° st°nu pod oknem

         mov       dx,ds:[PozMap]           ; poá†teán° pozice
         mov       cx,ds:[SirMap]           ; rozmàry okna
         call      StinWin

; ------ zobrazen° r†mu

         push      dx
         mov       ah,ds:[ColRF]
DispMp11:push      dx
         mov       al," "
         call      DispChr
         pop       dx
         inc       dh
         dec       ch
         jnz       DispMp11
         pop       dx

; ------ zobrazen° mapy

         mov       bl,0                     ; poá†teán° á°slo stopy
DispMap1:mov       bh,0                     ; á°slo strany

; ------ zobrazen° horn°ho okraje

         mov       ah,ds:[ColRF0]           ; barva r†meáku
         push      dx
         add       dl,10
         mov       al,"⁄"
         call      Disp1Chr
         mov       al,"¬"
         mov       cl,ds:[CitMap]
         call      DispChr
         mov       al,"ø"
         call      Disp1Chr
         pop       dx
         inc       dh

; ------ levò okraj ©†dku

DispMap2:push      dx
         inc       dl
         mov       ah,ds:[ColRF]
         mov       si,offset TextStra
         call      Disp0Txt
         mov       al,bh
         add       al,"0"
         mov       ah,ds:[ColRF0]
         call      Disp1Chr
         inc       dx
;         mov       ah,ds:[ColRF]
         mov       al,"≥"
         call      Disp1Chr

; ------ zobrazen° vnit©ku ©†dku

         mov       cl,ds:[CitMap]
         mov       ah,ds:[ColRFNul]
         mov       al,"∞"
         call      DispChr

; ------ pravò okraj

         mov       ah,ds:[ColRF0]           ; barva r†meáku
         mov       al,"≥"
         call      Disp1Chr                 ; zobrazen° pravÇho okraje
         pop       dx
         inc       dh
         inc       bh                       ; zvò®en° á°sla strany
         cmp       bh,ds:[NumStran]         ; jsou jië v®echny strany ?
         jb        DispMap2                 ; dal®° strana

; ------ zobrazen° spodn°ho okraje

         push      bx
         push      dx
         add       dl,10
         mov       al,"¿"
         call      Disp1Chr                 ; zobrazen° levÇho spodn°ho rohu

         mov       bh,ds:[CitMap]           ; poáet stop k zobrazen°
DispMap4:push      ax
         mov       al,bl                    ; á°slo stopy
         mov       ah,0
         mov       cl,5
         div       cl                       ; dàlitelnost 5
         or        ah,ah                    ; je á°slo dàlitelnÇ 5 ?
         pop       ax
         mov       al,"≈"                   ; dàlitelnÇ 5
         jz        DispMp42
         mov       al,"¡"
DispMp42:call      Disp1Chr

         inc       bl
         dec       bh
         jnz       DispMap4

         mov       al,"Ÿ"
         call      Disp1Chr                 ; zobrazen° pravÇho doln°ho rohu
         pop       dx
         pop       bx
         inc       dh

; ------ zobrazen° á°sel stop

         push      dx
         add       dl,10
         mov       bh,ds:[CitMap]           ; poáet stop k zobrazen°
;         mov       ah,ds:[ColRF0]
DispMap5:
         push      ax
         mov       al,bl                    ; á°slo stopy
         mov       ah,0
         mov       cl,5
         div       cl
         or        ah,ah                    ; je dàlitelnÇ 5 ?
         pop       ax
         jnz       DispMp52                 ; nen° dàlitelnÇ 5

         push      ax
         push      bx
         push      cx
         push      dx

         mov       al,bl
         mov       ch,ah
         xor       bx,bx
         xor       ah,ah
         mov       cl,2
         call      DispNum                  ; zobrazen° á°sla stopy

         pop       dx
         pop       cx
         pop       bx
         pop       ax

DispMp52:inc       dl                       ; zvò®en° pozice
         inc       bx                       ; zvò®en° á°sla stopy
         dec       bh
         jnz       DispMap5                 ; dal®° stopa
         pop       dx

; ------ p©°prava k zobrazen° dal®°ho r†meáku

         add       dh,2
         cmp       bl,ds:[NumStop]          ; jsou jië v®echny stopy ?
         jae       DispMap6
         mov       al,ds:[NumStop]
         sub       al,ds:[CitMap]
         mov       ds:[CitMap],al
         jmp       DispMap1                 ; dal®° stopy

; ------ oddàlovac° á†ra mezi mapami pro 80 stop

DispMap6:cmp       byte ptr ds:[NumStop],60
         jbe       DispMap9
         sub       dh,7
         cmp       byte ptr ds:[NumStran],1
         jne       DispMap7
         inc       dh
DispMap7:mov       al,"ƒ"
;         mov       ah,ds:[ColRF0]
         mov       cl,byte ptr ds:[SirMap]
         call      DispChr

; ------ n†vrat registrñ

DispMap9:pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         call      MouseOn
         ret

DispMap  ENDP

; -----------------------------------------------------------------------------
;        zobrazen° v®ech diskñ
; -----------------------------------------------------------------------------

DispADsk PROC      NEAR

         push      ax
         mov       al,0
DispADs2:call      DispDisk                 ; zobrazeni disku A:
         inc       ax
         cmp       al,ds:[NumDisk]
         jb        DispADs2
         pop       ax
         ret

DispADsk ENDP

; -----------------------------------------------------------------------------
;        zobrazen° disku AL
; -----------------------------------------------------------------------------

DispDisk PROC      NEAR

; ------ £schova registrñ

         call      MouseOff                 ; vypnut° kurzoru my®i
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di

; ------ p©°prava registrñ

         mov       bh,0
         mov       bl,al                    ; á°slo disku
         mov       dh,11                    ; poá†teán° ©†dek k zobrazen°
         mov       dl,ds:[PozDiskT+bx]      ; pozice k zobrazen° disku

; ------ zobrazen° st°nu

         mov       cl,17
         mov       ch,11
         call      StinWin                  ; zobrazen° st°nu pod oknem

; ------ horn° okraj okna

         mov       ah,ds:[ColDiskR]         ; barva r†mu
         mov       al,"…"
         call      Disp1Chr
         mov       al,"Õ"
         mov       cl,15
         call      DispChr
         mov       al,"ª"
         call      Disp1Chr
         sub       dl,17
         inc       dh

; ------ st©edn° ©†dek nadpisu - á°slo disku

         mov       al,"∫"
         call      Disp1Chr
         mov       al," "
         mov       cl,4
         call      DispChr
         mov       si,offset TextDisk
         mov       ah,ds:[ColDisk1]
         call      Disp0Txt
         mov       al,bl
         add       al,"A"
         call      Disp1Chr
         mov       al,":"
         call      Disp1Chr
         mov       ah,ds:[ColDiskR]         ; barva r†mu
         mov       cl,4
         mov       al," "
         call      DispChr
         mov       al,"∫"
         call      Disp1Chr
         sub       dl,17
         inc       dh

; ------ oddàlovac° linka

         mov       al,"Ã"
         call      Disp1Chr
         mov       al,"Õ"
         mov       cl,15
         call      DispChr
         mov       al,"π"
         call      Disp1Chr
         sub       dl,17
         inc       dh

; ------ ©†dek volby "Automatickò"

;         mov       al,"∫"
;         call      Disp1Chr
;         mov       al," "
;         call      Disp1Chr
;         mov       bh,ds:[ColDisk1]         ; bàën† barva poloëek
;         mov       ah,bh
;         cmp       bl,ds:[AktDisk]          ; je to aktivn° disk ?
;         jne       DispDsk2                 ; nen° to aktivn° disk
;         cmp       byte ptr ds:[AktVolby],0 ; jsou aktivn° volby ?
;         jne       DispDsk2                 ; jsou aktivn° volby
;         mov       ah,ds:[ColDisk4]         ; vysv°cen† barva
;         cmp       byte ptr ds:[AktForm],0  ; je to atkivn° form†t ?
;         jne       DispDsk2                 ; nen° to aktivn° format
;         mov       ah,ds:[ColDisk3]         ; barva kurzoru
;         mov       bh,ah
;DispDsk2:call      Disp1Chr                 ; zobrazen° jednÇ mezery
;         mov       al,"A"
;         call      Disp1Chr                 ; zobrazen° horkÇ kl†vesy
;         mov       si,offset TextAut        ; text "Automatickò"
;         mov       ah,bh
;         call      Disp0Txt                 ; zobrazen° textu
;         mov       al," "
;         call      Disp1Chr                 ; zobrazen° mezery
;         mov       ah,ds:[ColDiskR]         ; barva r†mu
;         call      Disp1Chr
;         mov       al,"∫"
;         call      Disp1Chr
;         sub       dl,17
;         inc       dh

; ------ p©°prava k zobrazen° textñ form†tñ

         mov       bh,0
         mov       al,ds:[TypDiskT+bx]      ; typ disku
         mov       ah,0
         shl       ax,1                     ; typ disku * 2
         xchg      ax,si                    ; SI <- typ disku * 2
         mov       si,ds:[si+TabForm-2]     ; adresa popisovaáe form†tu
         mov       cl,ds:[si]               ; poáet poloëek form†tñ
         inc       si
         mov       ch,0                     ; á°slo form†tu k zobrazen°

; ------ levò okraj

DispDsk3:mov       ah,ds:[ColDiskR]         ; barva r†mu
         mov       al,"∫"
         call      Disp1Chr
         mov       al," "
         call      Disp1Chr

; ------ uráen° barvy ©†dku

         mov       bh,ds:[ColDisk1]         ; bàën† barva poloëek
         mov       ah,bh
         cmp       bl,ds:[AktDisk]          ; je to aktivn° disk ?
         jne       DispDsk4                 ; nen° to aktivn° disk
         cmp       byte ptr ds:[AktVolby],0 ; jsou aktivn° volby ?
         jne       DispDsk4                 ; jsou aktivn° volby
         mov       ah,ds:[ColDisk4]         ; vysv°cen† barva
         cmp       ds:[AktForm],ch          ; je to aktivn° form†t ?
         jne       DispDsk4                 ; nen° to aktivn° format
         mov       ah,ds:[ColDisk3]         ; barva kurzoru
         mov       bh,ah
DispDsk4:call      Disp1Chr                 ; zobrazen° mezery
         call      Disp1Chr

; ------ zobrazen° pr†zdnÇho ©†dku

         dec       cl
         jns       DispDsk5
         push      cx
         mov       cl,11
         call      DispChr
         pop       cx
         jmp       short DispDsk6

; ------ zobrazen° textu volby form†tu

DispDsk5:mov       al,ch                    ; á°slo form†tu
         add       al,"1"
         call      Disp1Chr                 ; zobrazen° á°sla form†tu
         mov       ah,bh
         mov       al,":"
         call      Disp1Chr
         mov       al," "
         call      Disp1Chr
         test      byte ptr ds:[si+0],b3    ; je to nestandardn° form†t ?
         jz        DispDs52                 ; je to standardn° form†t
         mov       al,"*"                   ; p©°znak nestandardn°ho form†tu
DispDs52:call      Disp1Chr
         add       si,4
         push      cx
         mov       cl,5
         call      DispTxt
         mov       al," "
         mov       cl,2
         call      DispChr
         pop       cx

; ------ pravò okraj

DispDsk6:mov       ah,ds:[ColDiskR]         ; barva r†mu
         call      Disp1Chr
         mov       al,"∫"
         call      Disp1Chr

; ------ p©°prava pro dal®° poloëku

         sub       dl,17
         inc       dh
         inc       ch
         cmp       ch,7
         jae       DispDsk7
         jmp       DispDsk3

; ------ spodn° okraj okna

DispDsk7:mov       ah,ds:[ColDiskR]         ; barva r†mu
         mov       al,"»"
         call      Disp1Chr
         mov       al,"Õ"
         mov       cl,15
         call      DispChr
         mov       al,"º"
         call      Disp1Chr

; ------ zobrazen° n†povàdy pro aktivn° form†t aktivn°ho disku

         cmp       byte ptr ds:[AktVolby],0 ; jsou aktivn° volby ?
         jne       DispDs99                 ; jsou aktivn° volby
         cmp       bl,ds:[AktDisk]          ; je to aktivn° disk ?
         je        DispDs80                 ; je to aktivn° disk
DispDs99:jmp       DispDsk9
DispDs80:mov       dx,24*HI

; ------ zobrazen° n†povàdy pro automatickò form†t

;         cmp       byte ptr ds:[AktForm],0  ; automatickò form†t ?
;         jne       DispDsk8                 ; nen° automatickò form†t
;         mov       ah,ds:[ColHelp]
;         mov       si,offset FormHlpA
;         call      Disp0Txt
;         jmp       short DispDs88

; ------ p©°prava prvn° á†sti textu

DispDsk8:mov       si,offset FormHlp1
         mov       ax,"45"                  ; disk 5 1/4"
         cmp       byte ptr ds:[TypDisk],3  ; je disk 3 1/2" ?
         jb        DispDs82                 ; je disk 5 1/4"
         mov       ax,"23"                  ; jinak disk 3 1/2"
DispDs82:mov       ds:[si+2],al
         mov       ds:[si+6],ah             ; oznaáen° disku 3 1/2 nebo 5 1/4

         mov       al,"D"                   ; disketa DD
         cmp       byte ptr ds:[NumSekt],13
         jbe       DispDs83                 ; disketa DD
         mov       al,"H"                   ; disketa HD
         cmp       byte ptr ds:[NumSekt],30
         jb        DispDs83
         mov       al,"Q"                   ; jinak QD
DispDs83:mov       ds:[si+9],al             ; oznaáen° DD, HD, QD

         mov       al,"S"                   ; 1 strana
         cmp       byte ptr ds:[NumStran],1 ; je 1 strana ?
         je        DispDs84                 ; je 1 strana
         mov       al,"D"                   ; 2 strany
DispDs84:mov       ds:[si+12],al            ; oznaáen° SS nebo DS

; ------ zobrazen° prvn° á†sti tetxu

         mov       ah,ds:[ColHelp]
         call      Disp0Txt

; ------ zobrazen° kapacity disku

         mov       ch,ah                    ; barva
         mov       ax,word ptr ds:[CelkKap] ; celkov† kapacita disku
         mov       bx,word ptr ds:[CelkKap+2]
         mov       cl,0                     ; CL = ®°©ka pole
         call      DispNum                  ; zobrazen° celkovÇ kapacity disku
         mov       ah,ch

; ------ zobrazen° druhÇ á†sti textu

         mov       si,offset FormHlp2
         call      Disp0Txt

; ------ zobrazen° poátu poloëek v ROOT

         mov       ch,ah                    ; barva
         mov       ax,ds:[RootMax]          ; poáet poloëek v ROOT
         xor       bx,bx
         mov       cl,0                     ; CL ®°©ka pole
         call      DispNum                  ; zobrazen° poátu poloëek v ROOT
         mov       ah,ch

; ------ zobrazen° zbytku mezer

DispDs88:mov       cl,38
         sub       cl,dl
         jbe       DispDs89
         mov       al," "
         call      DispChr

; ------ zobrazen° zbytku textu n†povàdy

DispDs89:mov       ch,ds:[ColHelp1]         ; vysv°cen† barva textu
         mov       si,offset FormHlp0       ; text
         call      Disp0Txt                 ; zobrazen° textu n†povàdy

; ------ n†vrat registrñ

DispDsk9:pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         call      MouseOn                  ; zapnut° kurzoru my®i
         ret

DispDisk ENDP

; -----------------------------------------------------------------------------
;        zobrazen° voleb
; -----------------------------------------------------------------------------

DispVol  PROC      NEAR

; ------ £schova registrñ

         call      MouseOff                 ; vypnut° kurzoru my®i
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp

; ------ p©°prava k zobrazen° poloëek

         mov       si,offset VolDef         ; definice poloëek
         mov       bp,offset VolText        ; texty n†povàd k volb†m
         mov       bl,0                     ; ukazatel á°sla volby

; ------ p©°prava barvy poloëky

DispVol1:mov       ah,ds:[ColVol0]          ; bàën† barva poloëky
         mov       bh,ds:[ColVol]
         cmp       bl,ds:[AktVol]           ; je to aktivn° poloëka ?
         jne       DispVol2                 ; nen° to aktivn° poloëka
         cmp       byte ptr ds:[AktVolby],0 ; jsou aktivn° volby ?
         je        DispVol2                 ; volby nejsou aktivn°
         mov       ah,ds:[ColVolK]          ; jinak barva kurzoru
         mov       bh,ah

; ------ zobrazen° £vodn° mezery poloëky

DispVol2:mov       dx,ds:[si+3]             ; poá†teán° pozice na obrazovce
         dec       dl
         mov       al," "
         call      Disp1Chr                 ; zobrazen° £vodn° mezery poloëky

; ------ zobrazen° n†zvu poloëky

         push      si
         mov       si,bp
         mov       cl,ds:[si]
         mov       ch,0
         call      Disp0Txt
         pop       si
         inc       bp
         add       bp,cx

; ------ zobrazen° oddàlovac° mezery

         sub       cl,ds:[si+5]             ; offset poá†tku parametru
         neg       cl
         call      DispChr                  ; zobrazen° oddàlovac° mezery

; ------ zobrazen° jednoduchÇho p©ep°naáe

         mov       ah,bh
         mov       di,ds:[si+1]             ; adresa parametru poloëky
         mov       al,ds:[di]               ; parametr poloëky
         mov       cl,ds:[si+6]             ; dÇlka pole parametru poloëky
         test      byte ptr ds:[si+0],b0    ; je to jednoduchò p©ep°naá ?
         jz        DispVol4                 ; nen° to jednoduchò p©ep°naá
         cmp       al,0                     ; je p©ep°naá zapnut ?
         mov       al,ds:[SelChar]          ; volba - p©ep°naá zapnut
         jne       DispVol3                 ; p©ep°naá je zapnut
         mov       al,"-"                   ; jinak p©ep°naá neaktivn°
DispVol3:call      Disp1Chr                 ; zobrazen° p©ep°naáe
         jmp       short DispVol8

; ------ zobrazen° dekadickÇ á°selnÇ poloëky

DispVol4:test      byte ptr ds:[si+0],b1    ; je dekadick† á°seln† poloëka ?
         jz        DispVol5                 ; nen° dekadick† á°seln† poloëka
         push      bx
         push      ax
         xor       bx,bx
         mov       ch,ah                    ; barva á°sla
         cmp       word ptr ds:[si+1],offset ParStop ; je volba dal®°ch stop ?
         jne       DispVl42                 ; nen° volba dal®°ch stop
         mov       ah,"6"                   ; max. 6 stop

         cmp       byte ptr ds:[TypStop],40
         ja        DispVl41                 ; je 80 stop
         shr       al,1                     ; poáet stop/2
         mov       ah,"3"                   ; max. 3 stopy

DispVl41:mov       ds:[PocPHlp1],ah         ; max. poáet stop
         mov       ds:[PocPHlp2],ah
DispVl42:mov       ah,0
         call      DispNum                  ; zobrazen° á°selnÇ poloëky
         pop       ax
         pop       bx
         jmp       short DispVol8

; ------ zobrazen° hexadecim†ln° poloëky - bajt

DispVol5:test      byte ptr ds:[si+0],b2    ; je hexadecim†ln° poloëka ?
         jz        DispVol6
         call      DispHByt                 ; zobrazen° hexadecim†ln°ho bajtu
         jmp       short DispVol8

; ------ zobrazen° k¢du áe®tiny

DispVol6:test      byte ptr ds:[si+0],b3    ; je volba áe®tiny ?
         jz        DispVol7                 ; nen° volba áe®tiny
         push      si
         mov       si,offset VolTCest
DispVl62:push      ax
         mul       cl
         add       si,ax
         pop       ax
         call      DispTxt
         pop       si
         jmp       short DispVol8

; ------ zobrazen° k¢du zachov†n° dat

DispVol7:;test      byte ptr ds:[si+0],b4    ; je volba zachov†n° dat ?
         ;jz        DispVl72
         ;push      si
         ;mov       si,offset VolTZach
         ;jmp       short DispVl62

; ------ zobrazen° poátu poloëek na Root

DispVl72:test      byte ptr ds:[si+0],b5    ; je volba poátu poloëek na Root ?
         jz        DispVol8
         or        al,al
         jz        DispVl73
         push      bx
         push      ax
         mov       ch,ah                    ; barva á°sla
         xor       bx,bx
         mov       ah,0
         shl       ax,1
         shl       ax,1
         shl       ax,1
         shl       ax,1
         call      DispNum                  ; zobrazen° á°selnÇ poloëky
         pop       ax
         pop       bx
         jmp       short DispVol8

DispVl73:push      si
         mov       si,offset VolTStd
         jmp       short DispVl62

; ------ zobrazen° z†vàreánÇ mezery

DispVol8:mov       al," "
         call      Disp1Chr

; ------ adresa dal®° poloëky

         add       si,VOLOFFS
         inc       bx                       ; zvò®en° ukazatele á°sla poloëky
         cmp       bl,NUMVOL                ; jsou jië v®echny poloëky ?
         je        DispVol9                 ; jsou jië v®echny poloëky
         jmp       DispVol1                 ; zobrazen° dal®° poloëky

; ------ adresa n†povàdy k zobrazen°

DispVol9:cmp       byte ptr ds:[AktVolby],0 ; jsou volby aktivn° ?
         je        DispVolC                 ; volby nejsou aktivn°
         mov       cl,ds:[AktVol]           ; Aktivn° poloëka voleb
         mov       ch,0
         mov       si,offset VolHlp
         jcxz      DispVolB
         cld
         mov       ah,0
DispVolA:lodsb
         add       si,ax
         loop      DispVolA

; ------ zobrazen° prvn° á†sti n†povàdy

DispVolB:mov       dx,24*HI
         mov       ah,ds:[ColHelp]
         mov       al," "
         call      Disp1Chr                 ; zobrazen° £vodn° mezery
         call      Disp0Txt                 ; zobrazen° textu n†povàdy

; ------ zobrazen° mezer do zbytku ©†dku

         mov       cl,41
         sub       cl,dl
         mov       al," "
         call      DispChr

; ------ zobrazen° druhÇ á†sti n†povàdy

         mov       si,offset VolHlp0
         mov       ch,ds:[ColHelp1]
         call      Disp0Txt

; ------ n†vrat registrñ

DispVolC:pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         call      MouseOn                  ; zapnut° kurzoru my®i
         ret

DispVol  ENDP

; -----------------------------------------------------------------------------
;        zobrazen° podkladovÇho r†mu
; -----------------------------------------------------------------------------

DispRam  PROC      NEAR

; ------ £schova registrñ

         call      MouseOff                 ; vypnut° kurzoru my®i
         push      ax
         push      bx
         push      cx
         push      dx
         push      si

; ------ zobrazen° horn° linky nadpisu

         mov       dh,0                     ; poá†teán° ©†dek
         mov       ah,ds:[ColRamN]          ; barva r†mu nadpisu
         mov       al,"…"                   ; levò horn° roh
         mov       bx,"ÕÀ"                  ; oddàlovac° znak a linka
         mov       ch,"ª"                   ; pravò horn° roh
         call      DispRL1                  ; zobrazen° horn° linky nadpisu

; ------ zobrazen° st©edn° linky nadpisu

         mov       al,"∫"                   ; levò okraj
         mov       bx," ∫"                  ; oddàlovac° znak a linka
         mov       ch,"∫"                   ; pravò okraj
         call      DispRL1                  ; zobrazen° st©edn° linky nadpisu

; ------ zobrazen° spodn° linky nadpisu

         mov       al,"Ã"                   ; levò okraj
         mov       bx,"Õ "                  ; oddàlovac° znak a linka
         mov       ch,"π"                   ; pravò okraj
         call      DispRL1                  ; zobrazen° spodn° linky nadpisu

; ------ zobrazen° ©†dkñ voleb

         mov       bx,"∫ "                  ; levò a st©edn° znak
         mov       cx,"∫"*HI + 5            ; pravò znak, 5 ©†dkñ
         call      DispRL2

; ------ oddàlovac° linka pod volbami

         mov       bx,"»Õ"                  ; levò a st©edn° znak
         mov       cx,"º"*HI + 1            ; pravò znak, 1 ©†dek
         call      DispRL2                  ; oddàlovac° linka

; ------ zobrazen° podkladu

         mov       ah,ds:[ColPod]           ; barva podkladu
         mov       bx,"∞∞"                  ; levò a st©edn° znak
         mov       cx,"∞"*HI + 15           ; pravò znak, 15 ©†dkñ
         call      DispRL2

; ------ ©†dek n†povàdy

         mov       ah,ds:[ColHelp]          ; bavra r†mu n†povàdy
         mov       bx,"  "                  ; levò a st©edn° znak
         mov       cx," "*HI + 1            ; pravò znak, 1 ©†dek
         call      DispRL2

; ------ zobrazen° licenán°ho textu

         mov       si,offset LicTxt         ; licenán° text
         mov       dx,1*HI+20               ; poá†teán° pozice
         mov       ah,ds:[ColNadp]          ; barva textu
         call      Disp0Txt                 ; zobrazen° textu

; ------ zobrazen° st°nu pod volbami

         mov       dx,9*HI+2
         mov       cl,78
         call      DispStin

; ------ n†vrat registrñ

         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         call      MouseOn                  ; zapnut° kurzoru my®i

; ------ zobrazen° data a áasu

         call      DispDate                 ; zobrazen° aktu†ln°ho data
         mov       byte ptr ds:[CitSek],1
         ret

DispRam  ENDP

; -----------------------------------------------------------------------------
;        zobrazen° podkladovÇ plochy
; -----------------------------------------------------------------------------

DispPod  PROC      NEAR

; ------ £schova registrñ

         call      MouseOff                 ; vypnut° kurzoru my®i
         push      ax
         push      bx
         push      cx
         push      dx

; ------ zobrazen° podkladu

         mov       dh,10
         mov       ah,ds:[ColPod]           ; barva podkladu
         mov       bx,"∞∞"                  ; levò a st©edn° znak
         mov       cx,"∞"*HI + 14           ; pravò znak, 14 ©†dkñ
         call      DispRL2

; ------ n†vrat registrñ

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         call      MouseOn                  ; zapnut° kurzoru my®i
         ret

DispPod  ENDP

; -----------------------------------------------------------------------------
;        zobrazen° horn° linky r†mu
; (©†dek DH, AX=prvn° znak, BH=linka, BL=oddàlovac° znak, CH=posledn° znak)
; -----------------------------------------------------------------------------

DispRL1  PROC      NEAR

         mov       dl,0
         call      Disp1Chr                 ; zobrazen° levÇho okraje
         mov       al,bh                    ; vodorovn† linka
         mov       cl,12                    ; dÇlka linky
         call      DispChr                  ; zobrazen° vodorvnÇ linky
         mov       al,bl                    ; oddàlovac° znak
         call      Disp1Chr                 ; zobrazen° oddàlovac°ho znaku
         mov       al,bh                    ; vodorovn† linka
         mov       cl,52                    ; dÇlka linky
         call      DispChr                  ; zobrazen° vodorovnÇ linky
         mov       al,bl                    ; oddàlovac° znak
         call      Disp1Chr                 ; zobrazen° oddàlovac°ho znaku
         mov       al,bh                    ; vodorovn† linka
         mov       cl,12                    ; dÇlka linky
         call      DispChr                  ; zobrazen° vodorovnÇ linky
         mov       al,ch                    ; posledn° znak
         call      Disp1Chr                 ; zobrazen° posledn°ho znaku
         inc       dh                       ; zvò®en° ukazatele ©†dku
         ret

DispRL1  ENDP

; -----------------------------------------------------------------------------
;       zobrazen° linky (©†dek DH, BH=levò, BL=st©edn°, CH=pravò znak, CL=©†dkñ)
; -----------------------------------------------------------------------------

DispRL2  PROC      NEAR

DispRL22:push      cx
         mov       dl,0                     ; poá†teán° pozice
         mov       al,bh                    ; levò okraj
         call      Disp1Chr                 ; zobrazen° levÇho okraje
         mov       al,bl                    ; st©edn° znak
         mov       cl,78                    ; dÇlka ©†dku
         call      DispChr                  ; zobrazen° st©edn°ho znaku
         mov       al,ch                    ; pravò znak
         call      Disp1Chr                 ; zobrazen° pravÇho znaku
         inc       dh                       ; zvò®en° ukazatele ©†dku
         pop       cx
         dec       cl
         jnz       DispRL22
         ret

DispRL2  ENDP

; -----------------------------------------------------------------------------
;        zobrazen° aktu†ln°ho data
; -----------------------------------------------------------------------------

DispDate PROC      NEAR

; ------ £schova registrñ

         call      MouseOff                 ; vypnut° kurzoru my®i
         push      ax
         push      bx
         push      cx
         push      dx

; ------ zji®tàn° systÇmovÇho data

         mov       ah,2ah
         int       21h                      ; zji®tàn° systÇmovÇho data

; ------ p©°prava pro zobrazen°

         mov       bx,dx                    ; £schova dne a màs°ce
         mov       dx,102h                  ; poá†teán° pozice k zobrazen°
         mov       ah,ds:[ColDat]           ; barva k zobrazen° data

; ------ zobrazen° data

         mov       al,bl                    ; aktu†ln° den
         call      Disp2NmS                 ; zobrazen° dne
         mov       al,"."
         call      Disp1Chr                 ; zobrazen° oddàlovac° teáky
         mov       al,bh                    ; màs°c
         call      Disp2Nm0                 ; zobrazen° màs°ce
         mov       al,"."
         call      Disp1Chr                 ; zobrazen° oddàlovac° teáky
         push      ax
         push      dx
         mov       ax,100
         xchg      ax,cx
         xor       dx,dx
         div       cx                       ; vòpoáet stolet° a roku
         mov       ah,dl                    ; rok
         xchg      ax,cx
         pop       dx
         pop       ax
         mov       al,cl                    ; stolet°
         call      Disp2Nm0                 ; zobrazen° stolet°
         mov       al,ch                    ; rok
         call      Disp2Nm0                 ; zobrazen° roku

; ------ n†vrat registrñ

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         call      MouseOn                  ; zapnut° kurzoru my®i
         ret

DispDate ENDP

; -----------------------------------------------------------------------------
;        inicializace fontñ
; -----------------------------------------------------------------------------

InitFont PROC      NEAR

; ------ n†vrat textñ z bufferu

         push      ds
         push      cs
         pop       es
         xor       si,si
         mov       ds,ds:[BuffTxt]
         mov       di,offset TextBeg
         mov       cx,offset(TextEnd-TextBeg)
         cld
         rep       movsb                    ; n†vrat textñ
         pop       ds

; ------ stanoven° konverzn° tabulky pro texty

         mov       byte ptr ds:[SelChar],"*" ; znak pro oznaáen° vòbàru voleb
         mov       bx,offset TbKamLat       ; konverze na k¢d Latin 2
         cmp       byte ptr ds:[ParCest],3  ; je k¢d Latin 2 ?
         je        InitFnt2                 ; je k¢d Latin 2
         mov       byte ptr ds:[SelChar],"˚" ; znak pro oznaáen° vòbàru voleb
         mov       bx,offset TbKamCS0       ; tabulka k odstranàn° diakritiky
         cmp       byte ptr ds:[ParCest],0  ; je bez diakritiky ?
         je        InitFnt2                 ; je bez diakritiky
         cmp       byte ptr ds:[ParCest],1  ; je vlastn° diakritika ?
         jne       InitFnt5                 ; nen° vlastn° - je Kamenickòch
         cmp       byte ptr ds:[EgaVga],0   ; je karta EGA nebo VGA ?
         jne       InitFnt5                 ; je EGA nebo VGA

; ------ p©ekonvertov†n° textñ

InitFnt2:mov       si,offset TextBeg
         mov       cx,offset(TextEnd-TextBeg)
InitFnt3:lodsb
         sub       al,128
         jb        InitFnt4
         xlat
         mov       ds:[si-1],al
InitFnt4:loop      InitFnt3

; ------ inicializace videom¢du

InitFnt5:call      MouseOff                 ; vypnut° kurzoru my®i
         mov       ah,0fh
         call      Int10                    ; poskytnut° aktivn°ho videom¢du

         mov       byte ptr ds:[SegmVRAM+1],0b0h
         cmp       al,7
         je        InitFnt6
         mov       byte ptr ds:[SegmVRAM+1],0b8h
         cmp       al,2
         je        InitFnt6
         mov       al,3
InitFnt6:mov       ah,0
         call      Int10                    ; inicializace videom¢du

; ------ p©edefinov†n° vlastn°ch fontñ

         cmp       byte ptr ds:[ParCest],1  ; jsou vlastn° fonty ?
         jne       InitFnt9                 ; nejsou vlastn° fonty
         cmp       byte ptr ds:[EgaVga],0   ; je karta EGA/VGA ?
         je        InitFnt9                 ; nen° karta EGA/VGA

         xor       ax,ax
         mov       es,ax                    ; ES <- 0
         mov       bh,14                    ; 14 bajtñ na znak
         cmp       es:[485h],bh             ; je 14 linek na znak ?
         mov       bp,offset Font14         ; font 14 linek na znak
         je        InitFnt8                 ; je 14 linek na znak

         cmp       byte ptr es:[485h],16
         je        InitFnt7                 ; je font 16 linek na znak
         mov       ax,1114h
         mov       bl,0
         call      Int10                    ; naáten° standard. fontu 16 linek
InitFnt7:mov       bp,offset Font16         ; font 16 linek na znak
         mov       bh,16                    ; 16 bajtñ na znak

InitFnt8:mov       cx,128                   ; poáet znakñ k p©edefinov†n°
         mov       dx,cx                    ; poá†teán° znak k p©edefinov†n°
         mov       ax,1110h                 ; naáten° uëivatelskòch fontñ
         push      cs
         pop       es                       ; ES <- CS
         mov       bl,0                     ; blok fontu
         call      Int10                    ; p©edefinov†n° fontñ

; ------ zobrazen° univerz†ln° á†sti

InitFnt9:call      MouseOn                  ; zapnut° kurzoru my®i
         call      DispRam                  ; zobrazen° podkladovÇho r†mu
         call      DispPod                  ; zobrazen° podkladu
         call      DispVol                  ; zobrazen° voleb
         call      KurzOff                  ; vypnut° kurzoru
         ret

InitFont ENDP

; -----------------------------------------------------------------------------
;        obsluha zobrazen° áasu bàhem INT 08h
; -----------------------------------------------------------------------------

Int08    PROC      FAR

; ------ vol†n° pñvodn° obsluhy

         pushf
         call      dword ptr cs:[Old08]

; ------ á°t†n° zobrazen° áasu

         dec       byte ptr cs:[CitSek]
         jz        Int081
         iret

; ------ £schova registrñ

Int081:  push      ax
         push      bx
         push      cx
         push      dx
         push      ds

; ------ aktu†ln° stav á°taáe áasu

         xor       ax,ax
         mov       ds,ax                    ; DS <- 0
         mov       ax,ds:[046ch]            ; áten° nië®° á†sti á°taáe áasu
         mov       dx,ds:[046eh]            ; áten° vy®®° á†sti á°taáe áasu

         push      cs
         pop       ds                       ; DS <- datovò segment

         mov       cl,4                     ; poáet rotac°
         shl       dx,cl                    ; vy®®° slovo * 16
         mov       bx,ax                    ; nië®° slovo á°taáe áasu
         mov       cl,12
         shr       bx,cl                    ; nejvy®®° 4 bity nië®°ho slova
         add       dx,bx                    ; p©enos 4 bitñ do vy®®°ho slova
         mov       cl,4
         shl       ax,cl                    ; nië®° slovo * 16
         mov       bx,17478
         div       bx                       ; á°taá áasu / 1092.375
         push      dx                       ; £schova zbytku v minutà
         mov       bx,60                    ; poáet minut v hodinà
         xor       dx,dx                    ; DX <- 0, AX=poáet minut
         div       bx                       ; vòpoáet hodiny a minuty
         push      dx                       ; £schova minuty

                                          ;* zobrazen° £daje hodin
         mov       dx,1*HI+69               ; poá†teán° pozice textu
         mov       ah,ds:[ColDat]
         call      Disp2Nm0
         mov       al,":"                   ; oddàlovac° znak
         call      Disp1Chr                 ; zobrazen° oddàlovac°ho znaku

                                          ;* zobrazen° £daje minut
         pop       ax                       ; n†vrat minut
         mov       ah,ds:[ColDat]
         call      Disp2Nm0
         mov       al,":"                   ; oddàlovac° znak
         call      Disp1Chr                 ; zobrazen° oddàlovac°ho znaku

                                          ;* zobrazen° £daje sekund
         pop       ax                       ; n†vrat zbytku do 1 minuty
         push      dx                       ; £schova pozice textu
         mov       bx,60                    ; poáet sekund v minutà
         mul       bx                       ; vòpoáet poátu sekund a setin
         mov       bx,17478                 ; p©evod na abs. £daj
         div       bx                       ; vòpoáet poátu sekund

                                          ;* vòpoáet á†sti sekundy
         push      ax                       ; £schova poátu sekund
         mov       ax,dx                    ; zbytek do 1 sekundy
         mov       bx,18                    ; poáet impulsñ v 1 sekundà
         mul       bx                       ; vòpoáet poátu impulsñ v sekundà
         mov       bx,17478                 ; p©evod na abs. £daj
         div       bx                       ; vòpoáet poátu á†sti sekundy
         sub       al,18                    ; -zbytek do sekundy
         neg       al                       ; zbytek do sekundy
         inc       al
         mov       ds:[CitSek],al           ; á°taá obsluhy hodin
         pop       ax                       ; n†vrat poátu sekund

         pop       dx                       ; n†vrat pozice textu
         mov       ah,ds:[ColDat]
         call      Disp2Nm0

; ------ p©°prava k zobrazen° uplynulÇ doby akce

         cmp       byte ptr ds:[ParsTime],0 ; zobraz° se uplynulò áas ?
         je        Int089                   ; nezobraz° se

; ------ vòpoáet poátu minut

         xor       ax,ax
         mov       ds,ax
         mov       ax,ds:[46ch]
         push      cs
         pop       ds
         sub       ax,ds:[BegTime]          ; uplynul† doba
         xor       dx,dx
         mov       cx,1092                  ; poáet impulsñ na minutu
         div       cx                       ; vòpoáet poátu minut
         push      dx

         mov       dx,19*HI+67
         xor       bx,bx
         mov       ah,0
         mov       cl,2                     ; ®°©ka pole
         mov       ch,ds:[ColRF0]
         call      DispNum

; ------ oddàlovac° teáka

         mov       ah,ch
         mov       al,":"
         call      Disp1Chr

; ------ zobrazen° £daje sekund

         pop       ax
         mov       cl,18
         div       cl
         mov       ah,ch
         call      Disp2Nm0

; ------ n†vrat registrñ

Int089:  pop       ds
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         iret

Int08    ENDP

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                   Univerz†ln° obsluha kl†vesnice a my®i
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
; -----------------------------------------------------------------------------
;        vypr†zdnàn° bufferu kl†vesnice
; -----------------------------------------------------------------------------

FlushKey PROC      NEAR

         push      bx

FlshKey1:call      TestKey                  ; test, zda je p©ipraven znak
         jc        FlshKey2                 ; nen° dal®° znak z kl†vesnice
         call      InpKey                   ; zru®en° znaku z kl†vesnice
         jmp       short FlshKey1           ; test dal®°ho znaku

FlshKey2:pop       bx
         ret

FlushKey ENDP

; -----------------------------------------------------------------------------
;      test, zda je p©ipraven znak z kl†vesnice (CY=nen°, jinak BX=k¢d kl†vesy)
; -----------------------------------------------------------------------------

TestKey  PROC      NEAR

         push      ax

; ------ nulov†n° p©°znaku stisku INSERT (pro opakov†n° kl†vesy INSERT)

         push      ds
         xor       ax,ax
         mov       ds,ax                    ; DS <- 0
         and       byte ptr ds:[418h],not b7 ; nulov†n° p©°znaku stisku INSERT
         pop       ds

; ------ test znaku z kl†vesnice

         mov       ah,1
         int       16h                      ; test stavu kl†vesnice
         jnz       TestKey2                 ; je p©ipravena kl†vesa

; ------ obsluha bàhem áek†n° na kl†vesu

         call      Int28                    ; obsluha bàhem áek†n° na znak
         mov       ah,1
         int       16h                      ; test stavu kl†vesnice
         jnz       TestKey2                 ; je p©ipravena kl†vesa
         stc                                ; p©°znak - nen° kl†vesa
         pop       ax
         ret

TestKey2:cmp       al,0
         je        TestKey3
         mov       ah,0
TestKey3:clc
         xchg      ax,bx
         pop       ax
         ret

TestKey  ENDP

; -----------------------------------------------------------------------------
;        vstup znaku z kl†vesnice -> BX
; -----------------------------------------------------------------------------

InpKey   PROC      NEAR

         push      ax

; ------ áek†n° na vstup znaku z kl†vesnice

InpKey1: sti
         call      TestKey                  ; test znaku z kl†vesnice
         jc        InpKey1

; ------ vstup znaku z kl†vesnice

InpKey2: mov       ah,0
         int       16h

; ------ korekce k¢du kl†vesy

         cmp       al,0
         je        InpKey3
         mov       ah,0
InpKey3: call      UpCase

; ------ n†hrada kl†vesy Ctrl-Break kl†vesou Esc

         or        ax,ax                    ; je kl†vesa Ctrl-Break ?
         jnz       InpKey4                  ; nen° kl†vesa Ctrl-Break
         mov       ax,1bh                   ; n†hrada kl†vesou Esc

InpKey4: xchg      ax,bx                    ; BX <- kl†vesa
         pop       ax
         ret

InpKey   ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 28h s £schovou registrñ
; -----------------------------------------------------------------------------

Int28    PROC      NEAR

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

         int       28h

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
         ret

Int28    ENDP

; -----------------------------------------------------------------------------
;        inicializace obsluhy my®i
; -----------------------------------------------------------------------------

InitMous PROC      NEAR

; ------ kontrola adresy INT 33h, zda je platn†

         mov       ax,3533h
         int       21h                      ; poskytnut° adresy INT 33h
         mov       ax,es                    ; segment adresy
         cmp       ax,60h                   ; minim†ln° segment
         jb        IniMous1                 ; neplatn† adresa INT 33h
         inc       bx                       ; offset 0ffffh je takÇ neplatnò
         jz        IniMous1                 ; neplatn† adresa INT 33h

; ------ test instalace my®i

         mov       al,0
         call      Int33                    ; test instalace my®i
         inc       ax                       ; je my® nainstalovan† ?
         jz        IniMous2                 ; my® je nainstalovan† OK
IniMous1:mov       byte ptr ds:[MouseIns],0 ; p©°znak - nen° instalovan† my®
         ret

IniMous2:mov       byte ptr ds:[MouseIns],1 ; p©°znak nainstalovanÇ my®i

; ------ definov†n° kurzoru my®i

         mov       al,10
         xor       bx,bx                    ; p©°znak softwarovÇho kurzoru
         mov       cx,0ffffh                ; maska obrazovky (AND)
         mov       dx,7700h                 ; maska kurzoru (XOR)
         call      Int33                    ; instalace rozmàrñ okna

; ------ definice vertik†ln°ch rozmàrñ okna

         mov       al,8
         xor       cx,cx                    ; minim†ln° ©†dek
         mov       dx,24*8                  ; maxim†ln° ©†dek okna
         call      Int33                    ; definice ©†dkñ okna

; ------ definice horizont†ln°ch rozmàrñ okna

         mov       al,7
         xor       cx,cx                    ; minim†ln° pozice
         mov       dx,79*8                  ; maxim†ln° pozice okna
         call      Int33                    ; definov†n° pozic okna

; ------ nastaven° pozice kurzoru my®i

         mov       al,4
         xor       cx,cx
         xor       dx,dx
         mov       ds:[MousePoz],dx         ; nulov†n° pozice kurzoru my®i
         call      Int33                    ; nastaven° pozice kurzoru my®i

; ------ zapnut° kurzoru my®i

         mov       byte ptr ds:[MouseAkt],0 ; p©°znak - kurzor my®i nen° zapnutò
         call      MouseOn                  ; zapnut° kurzoru my®i

IniMous9:ret

InitMous ENDP

; -----------------------------------------------------------------------------
;        zapnut° kurzoru my®i
; -----------------------------------------------------------------------------

MouseOn  PROC      NEAR

; ------ test, zda lze kurzor my®i zapnout

         cmp       byte ptr ds:[MouseIns],0 ; je my® nainstalovan† ?
         je        MouseOn9                 ; my® nen° nainstalovan†
         cmp       byte ptr ds:[MouseAkt],0 ; je kurzor my®i zapnutò ?
         jne       MouseOn9                 ; kurzor mu®i je jië zapnutò

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx

; ------ zapnut° kurzoru my®i

         mov       al,1
         call      Int33                    ; zapnut° kurzoru my®i
         mov       byte ptr ds:[MouseAkt],1 ; p©°znak zapnut° kurzoru my®i

; ------ n†vrat registrñ

         pop       dx
         pop       cx
         pop       bx
         pop       ax
MouseOn9:ret

MouseOn  ENDP

; -----------------------------------------------------------------------------
;        vypnut° kurzoru my®i
; -----------------------------------------------------------------------------

MouseOff PROC      NEAR

; ------ test, zda lze kurzor my®i vypnout

         cmp       byte ptr ds:[MouseIns],0 ; je my® nainstalovan† ?
         je        MouseOf9                 ; my® nen° nainstalovan†
         cmp       byte ptr ds:[MouseAkt],0 ; je kurzor my®i zapnutò ?
         je        MouseOn9                 ; kurzor mu®i je jië vypnutò

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx

; ------ vypnut° kurzoru my®i

         mov       al,2
         call      Int33                    ; vypnut° kurzoru my®i
         mov       byte ptr ds:[MouseAkt],0 ; p©°znak vypnut° kurzoru my®i

; ------ n†vrat registrñ

         pop       dx
         pop       cx
         pop       bx
         pop       ax
MouseOf9:ret

MouseOff ENDP

; -----------------------------------------------------------------------------
;        poskytnut° stavu my®i -> BX (CY=nen° ë†dn† zmàna)
; -----------------------------------------------------------------------------
; VùSTUP:  BX:  0 = nebyla ë†dn† zmàna (nastaven CY)
;               1 = zmàna sou©adnic my®i
;               2 = uvolnàn° nàkterÇho tlaá°tka
;               3 = stisk levÇho tlaá°tka
;               4 = stisk pravÇho tlaá°tka
;               5 = stisk st©edn°ho tlaá°tka
;               6 = druhò stisk levÇho tlaá°tka
;               7 = druhò stisk pravÇho tlaá°tka
;               8 = druhò stisk st©edn°ho tlaá°tka
;          DX=aktu†ln° sou©adnice kurzoru my®i (DL=pozice, DH=©†dek)
; -----------------------------------------------------------------------------

MouseGet PROC      NEAR

; ------ test, zda je my® nainstalovan†

         cmp       byte ptr ds:[MouseIns],0 ; je my® nainstalovan† ?
         jne       MouseGt2                 ; my® je nainstalovan†
         xor       dx,dx                    ; aktu†ln° pozice kurzoru my®i
         xor       bx,bx                    ; p©°znak - nen° zmàna
         stc                                ; p©°znak, ëe nen° ë†dn† zmàna
         ret

; ------ £schova registrñ

MouseGt2:push      ax
         push      cx

; ------ zji®tàn° aktu†ln°ho stavu my®i

         mov       al,3
         call      Int33                    ; navr†cen° aktu†ln°ho stavu my®i

; ------ vòpoáet aktu†ln°ch sou©adnic my®i

         shr       cx,1
         shr       cx,1
         shr       cx,1
         shr       dx,1
         shr       dx,1
         shr       dx,1
         mov       dh,dl                    ; aktu†ln° ©†dek
         mov       dl,cl                    ; aktu†ln° pozice

; ------ £schova aktu†ln°ho stavu tlaá°tek

         and       bx,7                     ; pouze platnÇ bity
         mov       al,bl                    ; novò stav tlaá°tek
         xchg      bl,ds:[MouseKey]         ; uloëen° novÇho stavu tlaá°tek
         mov       ah,bl                    ; starò stav tlaá°tek
         mov       cx,ax                    ; £schova starÇho a novÇho stavu
         not       ah                       ; maska - uvolnàn† tlaá°tka
         and       al,ah                    ; stisknut† tlaá°tka
         jz        MouseGt5                 ; nebyl stisk ë†dnÇho tlaá°tka

; ------ porovn†n° áasu p©ede®lÇho stisku tlaá°tka

         push      ax
         push      ds
         xor       ax,ax
         mov       ds,ax
         mov       ax,ds:[46ch]             ; áas
         pop       ds
         sub       ax,ds:[MouseTim]         ; uplynul† doba
         add       ds:[MouseTim],ax         ; novò aktu†ln° áas
         cmp       ax,4                     ; byla asi 1/4 sekundy ?
         pop       ax
         mov       bl,3                     ; p©°znak - stisk levÇho tlaá°tka
         ja        MouseGt4                 ; byl del®° áas
         mov       bl,6                     ; p©°znak - druhò stisk tlaá°tka

; ------ rozli®en°, zda bylo nàkterÇ tlaá°tko stisknuto

MouseGt4:shr       al,1                     ; stisknuto levÇ tlaá°tko ?
         jc        MouseGt6                 ; stisknuto levÇ tlaá°tko
         inc       bx                       ; p©°znak - stisk pravÇho tlaá°tka
         shr       al,1                     ; stisknuto pravÇ tlaá°tko ?
         jc        MouseGt6                 ; stisknuto pravÇ tlaá°tko
         inc       bx                       ; p©°znak - stisk st©edn°ho tlaá°tka
         shr       al,1                     ; stisknuto st©edn° tlaá°tko ?
         jc        MouseGt6                 ; stisknuto st©edn° tlaá°tko

; ------ test, zda bylo nàkterÇ tlaá°tko uvolnàno

MouseGt5:mov       bl,2                     ; p©°znak uvolnàn° tlaá°tka
         not       cl                       ; maska uvolnànòch tlaá°tek
         and       cl,ch                    ; bylo nàkterÇ tlaá°tko uvolnàno ?
         jnz       MouseGt6                 ; bylo nàkterÇ tlaá°tko uvolnàno
         xor       bx,bx                    ; jinak ë†dn† zmàna

; ------ uloëen° novòch sou©adnic my®i a rozli®en° stavu

MouseGt6:or        bx,bx                    ; byla nàjak† zmàna tlaá°tek ?
         mov       cx,ds:[MousePoz]         ; £schova staròch sou©adnic my®i
         mov       ds:[MousePoz],dx         ; uloëen° novòch sou©adnic my®i
         jnz       MouseGt8                 ; byla nàjak† zmàna tlaá°tek
         cmp       dx,cx                    ; byla zmàna sou©adnic my®i ?
         stc                                ; p©°znak, ëe nebyla ë†dn† zmàna
         je        MouseGt8                 ; nebyla zmàna sou©adnic my®i
         inc       bx                       ; BX <- 1 p©°znak zmàny sou©adnic
         clc                                ; p©°znak, ëe byla nàjak† zmàna

; ------ n†vrat registrñ

MouseGt8:pop       cx
         pop       ax
         ret

MouseGet ENDP

; -----------------------------------------------------------------------------
;        vol†n° obsluhy INT 33h s £schovou registrñ (funkce v AL)
; -----------------------------------------------------------------------------

Int33    PROC      NEAR

         pushf
         push      si
         push      di
         push      bp
         push      ds
         push      es

         sti
         mov       ah,0
         int       33h

         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         popf
         ret

Int33    ENDP

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                     Univerz†ln° obsluha displeje
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
; -----------------------------------------------------------------------------
;        vypnut° kurzoru
; -----------------------------------------------------------------------------

KurzOff  PROC      NEAR

         push      dx
         mov       dx,25*256                ; prvn° ©†dek "za rohem"
         call      SetKurz                  ; nastaven° pozice kurzoru
         pop       dx
         ret

KurzOff  ENDP

; -----------------------------------------------------------------------------
;        nastaven° pozice kurzoru DX
; -----------------------------------------------------------------------------

SetKurz  PROC      NEAR

         push      ax
         push      bx
         mov       bh,0                     ; aktivn° videostr†nka 0
         mov       ah,2                     ; funkce - nastaven° pozice kurzoru
         call      Int10                    ; nastaven° pozice kurzoru
         pop       bx
         pop       ax
         ret

SetKurz  ENDP

; -----------------------------------------------------------------------------
;        zobrazen° hexadecim†ln°ho bajtu AL (AH=barva, DX=pozice)
; -----------------------------------------------------------------------------

DispHByt PROC      NEAR

         push      ax
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1
         call      DispHx
         pop       ax
         call      DispHx
         ret

DispHByt ENDP

; -----------------------------------------------------------------------------
;        zobrazen° hexadecim†ln°ho znaku AL (AH=barva, DX=pozice)
; -----------------------------------------------------------------------------

DispHx   PROC      NEAR

         push      ax
         and       al,0fh
         cmp       al,10
         jb        DispHx2
         add       al,7
DispHx2: add       al,"0"
         call      Disp1Chr
         pop       ax
         ret

DispHx   ENDP

; -----------------------------------------------------------------------------
;        zobrazen° á°sla AL 2 á°slice s dosplnàn°m nuly (AH=barva)
; -----------------------------------------------------------------------------

Disp2Nm0 PROC      NEAR

; ------ dek¢dov†n° á°sla

         push      cx
         push      ax

         mov       ah,0
         mov       cl,10
         div       cl                       ; vòpoáet á°slic
         add       ax,"00"                  ; korekce na ASCII á°slice
         xchg      ax,cx

         pop       ax

; ------ zobrazen° á°slice des°tek

         mov       al,cl                    ; des°tky
         call      Disp1Chr                 ; zobrazen° á°slice des°tek

; ------ zobrazen° á°slice jednotek

         mov       al,ch                    ; jednotky
         call      Disp1Chr                 ; zobrazen° á°slice jednotek
         pop       cx
         ret

Disp2Nm0 ENDP

; -----------------------------------------------------------------------------
;        zobrazen° á°sla AL 2 á°slice s doplnàn°m mezery (AH=barva)
; -----------------------------------------------------------------------------

Disp2NmS PROC      NEAR

; ------ dek¢dov†n° á°sla

         push      cx
         push      ax

         mov       ah,0
         mov       cl,10
         div       cl                       ; vòpoáet á°slic
         add       ax,"00"                  ; korekce na ASCII á°slice
         xchg      ax,cx

         pop       ax

; ------ zobrazen° á°slice des°tek

         mov       al,cl                    ; des°tky
         cmp       al,"0"                   ; je prvn° znak nula ?
         jne       Disp2NS2                 ; nen° nula
         mov       al," "                   ; n†hrada nuly mezerou
Disp2NS2:call      Disp1Chr                 ; zobrazen° á°slice des°tek

; ------ zobrazen° á°slice jednotek

         mov       al,ch                    ; jednotky
         call      Disp1Chr                 ; zobrazen° á°slice jednotek
         pop       cx
         ret

Disp2NmS ENDP

; -----------------------------------------------------------------------------
;        zobrazen° á°sla BX:AX; CL=®°©ka pole, CH=barva, DX=pozice (zmàn° se)
; -----------------------------------------------------------------------------

DispNum  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      si
         push      di
         push      bp

; ------ p©°prava registrñ

         mov       di,dx                    ; DI <- £schova pozice na displeji
         mov       dx,bx                    ; á°slo HIGH
         xchg      ax,bp                    ; BP <- á°slo LOW
         mov       si,10                    ; SI = dàlitel
         mov       bh,ch                    ; BH <- barva
         mov       ch,0                     ; CH = á°taá á°slic, CL = ®°©ka
         mov       bl,"."                   ; BL = znak mezery, BH = barva

; ------ vòpoáet jednÇ á°slice

DispNum1:xchg      ax,dx                    ; AX <- á°slo HIGH
         xor       dx,dx                    ; DX <- 0
         div       si                       ; vydàlen° á°sla HIGH
         xchg      ax,bp                    ; AX <- n†vrat LOW, BP<-£schova HIGH
         div       si                       ; vydàlen° á°sla LOW

; ------ oddàlovaá ©†dñ

         cmp       ch,3
         je        DispNum2                 ; jsou tis°ce
         cmp       ch,7
         jne       DispNum3                 ; nejsou miliony
DispNum2:push      bx                       ; uloëen° oddàlovac° teáky
         inc       ch                       ; zvò®en° á°taáe znakñ v z†sobn°ku

; ------ uloëen° á°sla

DispNum3:add       dl,"0"                   ; korekce na znak ASCII
         mov       dh,bh                    ; barva
         push      dx                       ; uloëen° á°sla do z†sobn°ku
         inc       ch                       ; zvò®en° á°taáe á°slic v z†sobn°ku
         mov       dx,bp                    ; DX <- n†vrat á°sla HIGH
         xchg      ax,bp                    ; BP <- á°slo LOW, (AX <- HIGH)

; ------ test, zda bude dal®° á°slice

         or        ax,bp                    ; je á°slo jië = 0 ?
         jnz       DispNum1                 ; dek¢dov†n° dal®° á°slice

; ------ zobrazen° £vodn°ch mezer

         mov       dx,di                    ; n†vrat pozice na displeji
         push      cx
         sub       cl,ch                    ; odeáten° á°slic k zobrazen°
         mov       ch,0
         jbe       DispNum4                 ; nezbyly ë†dnÇ mezery
         mov       ah,bh                    ; barva
         mov       al," "                   ; mezera k vymaz†n° bufferu
         call      DispChr                  ; zobrazen° £vodn°ch mezer
DispNum4:pop       ax
         mov       cl,ah                    ; CX = poáet znakñ v z†sobn°ku

; ------ zobrazen° á°sla

DispNum6:pop       ax
         call      Disp1Chr
         loop      DispNum6                  ; dal®° znak

; ------ n†vrat registrñ

         pop       bp
         pop       di
         pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

DispNum  ENDP

; -----------------------------------------------------------------------------
;        zobrazen° st°nu pod oknem (poá†tek DX, rozmàry CX)
; -----------------------------------------------------------------------------

StinWin  PROC      NEAR

; ------ zobrazen° st°nu po pravÇ stranà okna

         push      cx
         push      dx
         add       dl,cl                    ; pozice za oknem
         inc       dh                       ; druhò ©†dek okna
         mov       cl,2                     ; ®°©ka st°nu 2 pozice
StinWin1:call      DispStin                 ; zobrazen° st°nu na jednom ©†dku
         inc       dh                       ; zvò®en° ukazatele ©†dku
         dec       ch                       ; sn°ëen° á°taáe vò®ky okna
         jnz       StinWin1                 ; st°n na dal®°m ©†dku
         pop       dx
         pop       cx

; ------ zobrazen° st°nu pod oknem

         push      cx
         push      dx
         add       dh,ch                    ; ©†dek pod oknem
         add       dl,2                     ; poá†teán° pozice
         sub       cl,2                     ; sn°ëen° ®°©ky o 2
         call      DispStin                 ; zobrazen° st°nu
         pop       dx
         pop       cx
         ret

StinWin  ENDP

; -----------------------------------------------------------------------------
;        Zobrazen° st°nu (DX=pozice, CL=dÇlka, DL se nezmàn°)
; -----------------------------------------------------------------------------

DispStin PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      di
         push      es

; ------ vòpoáet adresy ve videopamàti

         mov       es,ds:[SegmVRAM]         ; segment videopamàti
         mov       al,80                    ; poáet znakñ na ©†dek
         mul       dh                       ; p©epoáet ©†dkñ na pozice
         add       al,dl                    ; p©iáten° pozice
         adc       ah,0
         shl       ax,1                     ; * 2 = offset ve videostr†nce
         xchg      ax,di                    ; adresa ve videopamàti

; ------ z†pis st°nu

         cld                                ; smàr posunu ukazatele nahoru
         mov       ch,0
         jcxz      DispStn7                 ; nen° ë†dnò znak k z†pisu
         mov       al,7                     ; barva st°nu
DispStn6:inc       di                       ; p©eskoáen° znaku
         stosb                              ; z†pis st°nu
         loop      DispStn6                 ; z†pis dal®°ho st°nu

; ------ n†vrat registrñ, konec

DispStn7:pop       es
         pop       di
         pop       cx
         pop       ax
         ret

DispStin ENDP

; -----------------------------------------------------------------------------
;        Zobrazen° jednoho znaku AX (DX=pozice, DL se zmàn°)
; -----------------------------------------------------------------------------

Disp1Chr PROC      NEAR

; ------ £schova registrñ

         push      di
         push      es

; ------ vòpoáet adresy ve videopamàti

         push      ax
         mov       es,ds:[SegmVRAM]         ; segment videopamàti
         mov       al,80                    ; poáet znakñ na ©†dek
         mul       dh                       ; p©epoáet ©†dkñ na pozice
         add       al,dl                    ; p©iáten° pozice
         adc       ah,0
         shl       ax,1                     ; * 2 = offset ve videostr†nce
         xchg      ax,di                    ; adresa ve videopamàti
         pop       ax

; ------ zobrazen° znaku

         cld                                ; smàr posunu ukazatele nahoru
         stosw                              ; z†pis znaku bez kontroly snàëen°

; ------ n†vrat registrñ, konec

         pop       es
         pop       di
         inc       dx                       ; zvò®en° pozice
         ret

Disp1Chr ENDP

; -----------------------------------------------------------------------------
;        Zobrazen° znaku AX (DX=pozice, CL=poáet znakñ, DL se zmàn°)
; -----------------------------------------------------------------------------

DispChr  PROC      NEAR

; ------ £schova registrñ

         push      cx
         push      di
         push      es

; ------ vòpoáet adresy ve videopamàti

         push      ax
         mov       es,ds:[SegmVRAM]         ; segment videopamàti
         mov       al,80                    ; poáet znakñ na ©†dek
         mul       dh                       ; p©epoáet ©†dkñ na pozice
         add       al,dl                    ; p©iáten° pozice
         adc       ah,0
         shl       ax,1                     ; * 2 = offset ve videostr†nce
         xchg      ax,di                    ; adresa ve videopamàti
         pop       ax

; ------ zobrazen° znaku

         cld                                ; smàr posunu ukazatele nahoru
         mov       ch,0                     ; CX = poáet znakñ k zobrazen°
         rep       stosw                    ; z†pis znaku bez kontroly snàëen°

; ------ n†vrat registrñ, konec

         pop       es
         pop       di
         pop       cx
         add       dl,cl                    ; zvò®en° pozice
         ret

DispChr  ENDP

; -----------------------------------------------------------------------------
;   zobrazen° textu DS:SI s dÇlkou (DX=pozice, AH=barva, CH=vysv°cen† barva)
; -----------------------------------------------------------------------------

Disp0Txt PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      di
         push      es

; ------ vòpoáet adresy ve videopamàti

         mov       es,ds:[SegmVRAM]         ; segment videopamàti
         push      ax                       ; £schova atributu barvy
         mov       al,80                    ; poáet znakñ na ©†dek
         mul       dh                       ; p©epoáet ©†dkñ na pozice
         add       al,dl                    ; p©iáten° pozice
         adc       ah,0
         shl       ax,1                     ; * 2 = offset ve videostr†nce
         xchg      ax,di                    ; DI <- adresa ve videopamàti
         pop       ax                       ; AH = atribut barvy

; ------ p©°prava parametrñ textu

         cld                                ; smàr posunu ukazatele nahoru
         mov       bh,ch                    ; alternativn° barva
         mov       ch,0
         lodsb
         mov       cl,al                    ; poáet bajtñ textu

; ------ zobrazen° textu

         jcxz      Disp0Tx7                 ; nen° ë†dnò znak k zobrazen°
Disp0Tx3:lodsb                              ; znak k zobrazen°
         or        al,al                    ; je p©ep°naá barvy ?
         jnz       Disp0Tx4                 ; nen° p©ep°naá barvy
         xchg      ah,bh                    ; zmàna barvy
         jmp       short Disp0Tx5
Disp0Tx4:stosw                              ; uloëen° znaku
         inc       dx                       ; zvò®en° ukazatele pozice
Disp0Tx5:loop      Disp0Tx3                 ; p©enos dat bez kontroly snàëen°

; ------ n†vrat registrñ, konec

Disp0Tx7:pop       es
         pop       di
         pop       cx
         pop       bx
         pop       ax
         ret

Disp0Txt ENDP

; -----------------------------------------------------------------------------
;  Zobrazen° textu DS:SI (AH=barva, DX=pozice, CL=poáet znakñ, DL a SI se zmàn°)
; -----------------------------------------------------------------------------

DispTxt  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      di
         push      es
         mov       ch,0                     ; CX = poáet znakñ

; ------ vòpoáet adresy ve videopamàti

         mov       es,ds:[SegmVRAM]         ; segment videopamàti
         push      ax                       ; £schova atributu barvy
         mov       al,80                    ; poáet znakñ na ©†dek
         mul       dh                       ; p©epoáet ©†dkñ na pozice
         add       al,dl                    ; p©iáten° pozice
         adc       ah,0
         shl       ax,1                     ; * 2 = offset ve videostr†nce
         xchg      ax,di                    ; DI <- adresa ve videopamàti
         pop       ax                       ; AH = atribut barvy

; ------ zobrazen° textu

         mov       ch,0
         jcxz      DispTxt7
         cld                                ; smàr posunu ukazatele nahoru
DispTxt6:lodsb                              ; znak k zobrazen°
         stosw                              ; uloëen° znaku
         loop      DispTxt6                 ; p©enos dat bez kontroly snàëen°

; ------ n†vrat registrñ, konec

DispTxt7:pop       es
         pop       di
         pop       cx
         pop       ax
         add       dl,cl                    ; zvò®en° pozice
         ret

DispTxt  ENDP

; -----------------------------------------------------------------------------
;        Detekce videokarty EGA/VGA
; -----------------------------------------------------------------------------

DetCard  PROC      NEAR

         mov       ah,12h                   ; sluëba EGA/VGA - informace o EGA
         mov       bx,4510h                 ; poskytnut° informac° o EGA
         call      Int10                    ; poskytnut° informac° o EGA/VGA
         cmp       bh,1                     ; kontrola navr†cenÇho m¢du displeje
         ja        DetCard1                 ; nen° to karta EGA/VGA
         cmp       bl,3                     ; maxim†lnà povolen 1 MB pamàti
         ja        DetCard1                 ; nen° to karta EGA/VGA
         inc       byte ptr ds:[EgaVga]     ; 1=p©°znak karty EGA/VGA
DetCard1:ret

DetCard  ENDP

; -----------------------------------------------------------------------------
;        Vol†n° INT 10h s £schovou registrñ
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

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                       RñznÇ univerz†ln° procedury
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
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
;                    skok na obsluhu podle BX
; -----------------------------------------------------------------------------
; Procedura se vol† instrukc° CALL JumpBX, za kterou n†sleduje tabulka
; skokñ. Procedura zmàn° svou n†vratovou adresu na adresu podle nalezenÇ
; poloëky v tabulce (nebo podle poloëky pro nenalezenou hodnotu).
; -----------------------------------------------------------------------------
; VSTUP: v z†sobn°ku slovo (n†vratov† adresa NEAR) = zaá†tek tabulky skokñ
;             stuktura tabulky: 1 slovo testovan† hodnota BX
;                               1 slovo adresa NEAR obsluhy
;             konec tabulky: 1 slovo = 0 (p©°znak konce tabulky)
;                            1 slovo adresa NEAR obsluhy p©i nenalezen° k¢du
; -----------------------------------------------------------------------------

JumpBX   PROC      NEAR

; ------ £schova registrñ

                                            ; SS:[BP+4] = IP
         push      si                       ; SS:[BP+2] = SI
         push      bp                       ; SS:[BP+0] = BP
         mov       bp,sp

; ------ nalezen° hodnoty v tabulce

         mov       si,ss:[bp+4]             ; offset adresy tabulky
JumpBX1: cmp       word ptr ds:[si],0       ; je konec tabulky ?
         je        JumpBX2                  ; konec tabulky - nenalezeno
         cmp       word ptr ds:[si],bx      ; je to hledan† hodnota ?
         je        JumpBX2                  ; hodnota nalezena
         add       si,4                     ; adresa dal®° poloëky
         jmp       short JumpBX1            ; test dal®° poloëky

; ------ nastaven° n†vratovÇ adresy podle tabulky

JumpBX2: mov       si,ds:[si+2]             ; adresa skoku
         mov       ss:[bp+4],si             ; nov† n†vratov† adresa

; ------ n†vrat registrñ

         pop       bp
         pop       si
         ret

JumpBX   ENDP

; -----------------------------------------------------------------------------
;        áek†n° po dobu CX (CX=poáet impulsñ 1/18 sekundy)
; -----------------------------------------------------------------------------

Cekej    PROC      NEAR

         push      ax
         push      cx
         push      ds

         xor       ax,ax
         mov       ds,ax
         jcxz      Cekej3

Cekej1:  mov       ax,ds:[46ch]
         sti
Cekej2:  cmp       ax,ds:[46ch]
         je        Cekej2
         loop      Cekej1

Cekej3:  pop       ds
         pop       cx
         pop       ax
         ret

Cekej    ENDP

; -----------------------------------------------------------------------------
;        zapnut° t¢novÇho gener†toru
; -----------------------------------------------------------------------------
; VSTUP: BX=dàlic° konstanta
;         dw        36485,34437,32505,30680,28958,27333 ; okt†va 0
;         dw        25799,24351,22984,21694,20477,19327
;         dw        18243,17219,16252,15340,14479,13667 ; okt†va 1
;         dw        12899,12175,11492,10847,10238,9664
;         dw        9121,8609,8126,7670,7240,6833       ; okt†va 2
;         dw        6450,6088,5746,5424,5119,4832
;         dw        4561,4305,4063,3835,3620,3417       ; okt†va 3
;         dw        3225,3044,2873,2712,2560,2416
;         dw        2280,2152,2032,1918,1810,1708       ; okt†va 4
;         dw        1612,1522,1437,1356,1280,1208
;         dw        1140,1076,1016,959,905,854          ; okt†va 5
;         dw        806,761,718,678,640,604
;         dw        570,538,508,479,452,427             ; okt†va 6
;         dw        403,380,359,339,320,302
;         dw        285,269,254,240,226,214             ; okt†va 7
;         dw        202,190,180,169,160,151
;         dw        143,135,127,120,113,107             ; okt†va 8
;         dw        101,95,90,85,80,75
;         dw        71,67,63,60,57,53,50,48,45,42,40,38 ; okt†va 9
; -----------------------------------------------------------------------------

Ton      PROC      NEAR

         cmp       byte ptr ds:[ParInd],0   ; je zvuk zapnut ?
         je        Ton9                     ; zvuk je vypnut
         push      ax
         mov       al,0b6h
         out       [43h],al
         mov       al,bl
         out       [42h],al
         mov       al,bh
         out       [42h],al
         in        al,[61h]
         or        al,3
         out       [61h],al
         pop       ax
Ton9:    ret

Ton      ENDP

; -----------------------------------------------------------------------------
;        vypnut° zvukovÇho gener†toru
; -----------------------------------------------------------------------------

TonOff   PROC      NEAR

         push      ax
         in        al,[61h]
         and       al,not 3
         out       [61h],al                 ; vypnut° gener†toru
         pop       ax
         ret

TonOff   ENDP

; -----------------------------------------------------------------------------
;        inicializace gener†toru n†hody
; -----------------------------------------------------------------------------

InitRnd  PROC      NEAR

         push      ax
         push      ds
         xor       ax,ax
         mov       ds,ax
         mov       ax,ds:[46ch]             ; á°taá systÇmovÇho áasovaáe
         pop       ds
         mov       word ptr ds:[RandomR],ax ; inicializaán° konstanta
         pop       ax
         ret

InitRnd  ENDP

; -----------------------------------------------------------------------------
;        gener†tor n†hodnÇho sektoru ES:DI (512 bajtñ) -> DI nov† adresa
; -----------------------------------------------------------------------------

RandomS  PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx
         push      bp
         push      si

         cld
         mov       si,256                   ; poáet slov ke generov†n°
         mov       bp,8405h                 ; pomocn† konstanta
         mov       ax,word ptr ds:[RandomR]
         mov       dx,word ptr ds:[RandomR+2]

RandomS1:mov       bx,dx
         mov       cx,ax
         mul       bp
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

         xchg      ax,dx
         stosw
         xchg      ax,dx

         dec       si
         jnz       RandomS1                 ; dal®° slovo

         mov       word ptr ds:[RandomR],ax
         mov       word ptr ds:[RandomR+2],dx

         pop       si
         pop       bp
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

RandomS  ENDP

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                           BOOT sektor
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
Boot:    jmp       Bstart

         db        'FORM 2.0'               ; identifikace

         dw        512                      ; dÇlka sektoru
BlokSekt db        2                        ; poáet sektorñ na alokaán° blok
  ;BBlok    db        2                        ; velikost bloku (sektorñ)
         dw        1                        ; poáet rezervovanòch sektorñ
         db        2                        ; poáet alok. tabulek FAT
RootMax  dw        70h                      ; maxim†ln° poloëek ROOT
  ;BRoot    dw        70h                      ; max. poáet poloëek ROOT
CelkSekt dw        2*40*9                   ; celkovò poáet sektorñ mÇdia
  ;BNMax    dw        720                      ; celkem sektorñ na mÇdiu
Popis    db        0ffh                     ; popisovaá mÇdia
  ;BIdent   db        0fdh                     ; popisovaá mÇdia
FatSekt  db        2                        ; poáet sektorñ na FAT
         db        0
  ;BNFat    dw        3                        ; poáet sektorñ v jednÇ FAT
NumSekt  db        9                        ; poáet sektorñ na stopu
         db        0                        ; doplnàn° na slovo
  ;BSekt    dw        9                        ; poáet sektorñ na stopu
NumStran db        2                        ; poáet stran disku
         db        0
  ;BStran   dw        2                        ; poáet hlav disku
         dd        0                        ; skrytòch sektorñ (4-bajty)
         dd        0                        ; celkem sektorñ (4-bajty)

         db        0                        ; disk (pracovn°)
         db        0                        ; hlava (pracovn°)

         db        29h                      ; identifik†tor
BSerie   dd        0                        ; sÇriovÇ á°slo

         db        'NO NAME    '
         db        'FAT12   '

Bstart:  xor       ax,ax
         mov       ss,ax
         mov       sp,7c00h
         sti

         push      ss
         pop       ds
         push      ss
         pop       es

         mov       si,offset(BText-Boot)+7c00h

BDispTxt:cld
         lodsb
         or        al,al
         jz        BRet
         mov       ah,0eh
         mov       bx,7
         int       10h
         jmp       short BDispTxt

BRet:    sti
         xor       ax,ax
         int       16h

         int       19h

BText    db        13
         db        'Nesystemova disketa. Vymente ji',13,10
         db        'a stisknete libovolnou klavesu.',13,10,0

BootEnd  label     byte

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                                 Data
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛

INCLUDE  FONT14.ASM
INCLUDE  FONT16.ASM

; ------ konverzn° tabulka z k¢du Kamenickòch na k¢d bez diakritiky

TbKamCS0 label     byte
         db        'CuedaDTceELIllAA'
         db        'EzZooOuUyOUSLYRt'
         db        'aiounNUOsrrR',172,173,174,175
         db        176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191
         db        192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207
         db        208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223
         db        224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239
         db        240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255

; ------ konverzn° tabulka z k¢du Kamenickòch na k¢d Latin 2

TbKamLat label     byte
         db        172,'ÅÇ',212,'Ñ',210,155,159,216,183,145,214,150,146,'é',181
         db        'ê',167,166,'ìî',224,133,233,236,'ôö',230,149,237,252,156
         db        '†°¢£',229,213,222,226,231,253,234,232,'/',245,174,175
         db        176,177,178,179,180,179,186,187,191,185,186,187,188,188,217,191
         db        192,193,194,195,196,197,179,186,200,201,202,203,204,205,206,205
         db        188,205,196,200,192,218,201,186,205,217,218,219,220,219,219,223
         db        'a',225,'G','p','S','s','m','t','f','T','O','d','0','/','E','N'
         db        '=','+','>','<',218,217,246,'=',248,250,250,'V','n','2',254,255

; ------ chybov† hl†®en° p©i startu programu

DiskTxt  db        'Neni nainstalovana zadna disketova mechanika !',13,10,'$'
MemTxt   db        'Chyba - nedostatek pameti ke spusteni programu !',13,10,'$'

SelChar  db        251                      ; znak pro oznaáen° vòbàru voleb

BuffTxt  dw        0                        ; adresa bufferu textñ

; -----------------------------------------------------------------------------
;        texty (bajty dÇlek se nekonvertuj°, protoëe jsou vëdy < 128 !)
; -----------------------------------------------------------------------------

TextBeg  label     byte                     ; zaá†tek textñ k transpozici

TextKap  db        6,'celkem'
TextVol  db        5,'volne'
TextBad  db        5,'vadne'
TextBoot db        4,'BOOT'
TextRoot db        4,'ROOT'
TextFat1 db        4,'FAT1'
TextFat2 db        4,'FAT2'
TextDob  db        4,'doba'

TextOK   db        2,' ˚'
TextNOK  db        2,' x'
TextXOK  db        2,'  '

LicTxt   db        40,'FORM verze 2.00     (c) Miroslav Nàmeáek'
TextDisk db        5,'Disk '
TextAut  db        10,'utomatickò'
TextStra db        7,'strana '

VolText  label     byte                     ; texty k volb†m
         db        15,'Operaán° systÇm'
         db        13,'N†và®t° disku'
         db        13,'Zachov†n° dat'
         db        12,'Jedna strana'
         db        14,'Poloëek v Root'
         db        16,'Zobrazen° obsahu'
         db        15,'Zrychlenò start'
         db        11,'Zpàtnò smàr'
         db        16,'Zvukov† indikace'
         db        10,'Verifikace'
         db        16,'Dopl§uj°c° stopy'
         db        15,'Testovac° z†pis'
         db        16,'Form†tovac° znak'
         db        17,'Optimalizace chyb'
         db        7,'Äe®tina'

VolHlp   label     byte                     ; n†povàdy k volb†m
         db        39,'Instalace operaán°ho systÇmu na disketu'
         db        38,'Zad†n° n†và®t° disku (jmenovka, LABEL)'
         db        32,'Zachov†n° pñvodn°ho obsahu disku'
         db        36,'Form†tov†n° disku pouze jednostrannà'
         db        38,'Poáet poloëek z†kladn°ho adres†©e Root'
         db        39,'Zobrazen° obsahu diskety k zform†tov†n°'
         db        37,'Zrychlenò start s p©edrozbàhem motoru'
         db        39,'Form†tov†n° smàrem od vy®®°ch stop dolñ'
         db        37,'Zvukov† indikace ukonáen° form†tov†n°'
         db        37,'Kontroln° áten° stopy po zform†tov†n°'
         db        38,'Poáet dopl§uj°c°ch stop disku (0 aë '
PocPHlp2 db        '6)'
         db        34,'Poáet ovà©ovac°ch z†pisñ (0 aë 99)'
         db        35,'Form†tovac° znak (HEX k¢d 00 aë FF)'
         db        36,'Optimalizace sektorñ p©i vzniku chyb'
         db        29,'K¢d áe®tiny k zobrazen° textñ'

RootHlp  db        40,' Zadejte 16 aë 992, 0=standardn° form†t '
PocPHlp  db        40,' Zadejte poáet stop 0 aë '
PocPHlp1 db        '6, 0=standard  '
PocZHlp  db        41,' Zadejte poáet testovac°ch z†pisñ 0 aë 99'
HexFHlp  db        40,' Zadejte form†tovac° znak 00 aë FF (HEX)'

VolHlp0  db        44,' (',0,'ENTER',0,'=zmàna, ',0,'ESC',0,'=konec, ',0,'F1',0,'=n†povàda) '

FormHlpA db        37,' Autom. detekce form†tu podle diskety'
FormHlp1 db        15,' 5 1/4" HD SS, '
FormHlp2 db        9,' B, Root '

FormHlp0 db        48,' (',0,'ENTER',0,'=form†tuj, ',0,'ESC',0,'=konec, ',0,'F1',0,'=n†povàda) '

; -----------------------------------------------------------------------------
;        p©ep°naáe
; -----------------------------------------------------------------------------

VolTCest db        '          -'
         db        '    vlastn°'
         db        'Kamenickòch'
         db        '    Latin 2'

VolTStd  db        'STD'

TextEnd  label     byte                     ; konec textñ k transpozici

; -----------------------------------------------------------------------------
;        definice voleb
; -----------------------------------------------------------------------------
; Definice jednÇ poloëky voleb:
;    0: (1) parametry poloëky
;              bit 0: 1=p©ep°naá
;              bit 1: 1=dekadick† poloëka (bajt)
;              bit 2: 1=hexadecim†ln° poloëka (bajt)
;              bit 3: 1=volba áe®tiny (poloëky BEZ, DWN, KAM, LAT)
;                  (bit 4: 1=volba zachov†n° dat (poloëky -, STOP, DISK))
;              bit 5: 1=poáet poloëek v ROOT
;    1: (2) adresa parametru poloëky
;    3: (1) poá†teán° pozice k zobrazen° volby
;    4: (1) poá†teán° ©†dek k zobrazen° volby
;    5: (1) offset pozice k zobrazen° parametru poloëky (na obrazovce)
;    6: (1) dÇlka pole parametru poloëky (na obrazovce)
; -----------------------------------------------------------------------------

VolDef   label     byte
         db        b0
         dw        ParSys
         db        4,3,18,1

         db        b0
         dw        ParLab
         db        4,4,18,1

         db        b0
         dw        ParDat
         db        4,5,18,1

         db        b0
         dw        ParStra
         db        4,6,18,1

         db        b5
         dw        ParRoot
         db        4,7,16,3

         db        b0
         dw        ParObs
         db        28,3,19,1

         db        b0
         dw        ParStrt
         db        28,4,19,1

         db        b0
         dw        ParBack
         db        28,5,19,1

         db        b0
         dw        ParInd
         db        28,6,19,1

         db        b0
         dw        ParVerif
         db        28,7,19,1

         db        b1
         dw        ParStop
         db        53,3,22,1

         db        b1
         dw        ParTest
         db        53,4,21,2

         db        b2
         dw        ParChar
         db        53,5,21,2

         db        b0
         dw        ParOptim
         db        53,6,22,1

         db        b3
         dw        ParCest
         db        53,7,12,11
VolDef0  label     byte

; -----------------------------------------------------------------------------
;        £schova aktu†ln°ho zobrazen° data a áasu
; -----------------------------------------------------------------------------

OldBreak db        1                        ; £schova p©°znaku BREAK

CitSek   db        18                       ; á°taá k zobrazen° sekund
Old08    dd        0                        ; pñvodn° adresa INT 08h

BegTime  dw        0                        ; áas zaá†tku akce (nië®° slovo)
;ElapsTim dw        0                        ; uplynul† doba akce
ParsTime db        0                        ; p©°znak, ëe se zobraz° doba akce

RandomR  dd        21510d31h                ; promànn† pro gener†tor n†hody

; -----------------------------------------------------------------------------
;        tabulka disketovòch parametrñ
; -----------------------------------------------------------------------------

Old1e    dd        -1                       ; pñvodn° vektor INT 1eh

Int1e    label     byte                     ; vlastn° tabulka INT 1eh
         db        0dfh                     ; bity 0 aë 3: rychlost krokov†n°
                                            ; bity 4 aë 7: áas zvednut° hlavy
         db        2                        ; bit 0: 1=je provoz DMA
                                            ; bity 1 aë 7: áas spu®tàn° hlavy
MotorOff db        37                       ; 2: vypnut° motoru v 1/18 sekundy
         db        2                        ; 3: velikost sektoru
         db        9                        ; 4: poáet sektorñ na stopu
         db        42                       ; 5: mezisekt. mezera áten°/z†pis
         db        255                      ; 6: dÇlka p©en†®enòch dat
         db        80                       ; 7: mezisekt. mezera form†tov†n°
FillCh   db        0                        ; 8: plnic° znak form†tov†n°
         db        15                       ; 9: doba ust†len° hlav v [ms]
MotorOn  db        8                        ; 10: doba pro rozbàh motoru v 1/8s
         db        39                       ; 11: posledn° stopa na disku
         db        80h                      ; 12: p©enosov† rychlost

; -----------------------------------------------------------------------------
;        parametry displeje
; -----------------------------------------------------------------------------

         EVEN
SegmVRAM dw        0b800h                   ; segment videopamàti
EgaVga   db        0                        ; 1=p©°znak, ëe je karta EGA/VGA

; -----------------------------------------------------------------------------
;        parametry my®i
; -----------------------------------------------------------------------------

MousePoz dw        0                        ; aktu†ln° pozice my®i
MouseKey db        0                        ; aktu†ln° stav tlaá°tek
                                            ;   bit 0: 1=levÇ tlaá°tko
                                            ;   bit 1: 1=pravÇ tlaá°tko
                                            ;   bit 2: 1=st©edn° tlaá°tko
MouseTim dw        0                        ; áas minulÇho stisku tlaá°tka
MouseIns db        0                        ; 1=p©°znak instalace my®i
MouseAkt db        0                        ; 1=p©°znak zapnut° kurzoru my®i

; -----------------------------------------------------------------------------
;        barvy
; -----------------------------------------------------------------------------

ColDat   db        1bh                      ; barva data a áasu

ColNadp  db        1bh                      ; barva textu nadpisu

ColVol0  db        1bh
ColVol   db        1fh                      ; barva textu voleb v nadpisu
ColVolK  db        30h                      ; barva kurzoru
ColEdi   db        0fh                      ; barva editovanÇ poloëky

ColDiskR db        1eh                      ; barva r†mu volby form†tu
ColDisk1 db        1bh                      ; bàën† barva
;ColDisk2 db        1fh                      ; vysv°cen† barva poloëek
ColDisk3 db        30h                      ; barva kurzoru
ColDisk4 db        1eh                      ; barva horkÇ kl†vesy

ColRamN  db        1eh                      ; barva r†mu nadpisu

ColPod   db        70h                      ; barva podkladu obrazovky

ColHelp  db        30h                      ; z†kladn° barva textu n†povàdy
ColHelp1 db        34h                      ; vysv°cen† barva textu n†povàdy

ColRF    db        1bh                      ; barva r†meáku form†tov†n°
ColRFR   db        1eh                      ; barva r†meáku
ColRF0   db        1fh                      ; vysv°cen† barva r†meáku
ColRFNul db        7                        ; barva - pr†zdnÇ pole v r†meáku

ColForm  db        70h                      ; znaáka form†tov†n°
ColVerif db        70h                      ; znaáka verifikace
ColWrite db        70h                      ; znaáka z†pisu
ColRead  db        70h                      ; znaáka áten°
ColOK    db        0ah                      ; barva OK
ColErr   db        4eh                      ; barva chyby

; -----------------------------------------------------------------------------
;        diskovÇ parametry
; -----------------------------------------------------------------------------

BufferW  dw        0                        ; segment bufferu pro z†pis
BufferR  dw        0                        ; segment bufferu pro áten°
BufferD  dw        0                        ; segment bufferu pro £schovu stopy
BufferF  dw        0                        ; segment bufferu s tabulkou FAT

NumDisk  db        0                        ; poáet diskñ v systÇmu
TypDiskT db        4 dup(1)                 ; tabulka typñ diskñ
PozDiskT db        4 dup(0)                 ; tabulka pozic k zobrazen° diskñ

TypDisk  db        1                        ; typ aktivn°ho disku
                                            ;    1 = 360 K
                                            ;    2 = 1.2 M
                                            ;    3 = 720 K
                                            ;    4 = 1.44 M
                                            ;    5 = 2.88 M

AktVolby db        0                        ; p©°znak aktivn°ch voleb

AktForm  db        -1                       ; aktivn° form†t (-1=neplat°)
NumForm  db        0                        ; poáet moënòch form†tñ disku
AktStop  db        0                        ; aktivn° stopa
AktStran db        0                        ; aktivn° strana

Krokov   db        0                        ; p©°znak dvojitÇho krokov†n°
TypStop  db        39                       ; jmenovitò poáet stop - 1
NumStop  db        40                       ; celkovò poáet stop disku
BlokByte dw        400h                     ; poáet bajtñ na alokaán° blok
RootSekt db        7                        ; poáet sektorñ na ROOT
         db        0                        ; doplnàk na slovo

CelkBlok dw        (2*40*9-1-7-2*2)/2       ; celkovò poáet datovòch blokñ
CelkKap  dd        362000                   ; celkov† kapacita disku
FirstDat dw        0                        ; prvn° datovò sektor absolutnà

CitVol   dd        0                        ; á°taá volnÇ kapacity disku
CitBad   dd        0                        ; á°taá vadnòch dat disku

ErrBoot  db        1                        ; p©°znak BOOT (0=OK, FF=vadnò, 1=?)
ErrFAT1  db        1                        ; p©°znak FAT1 (0=OK, FF=vadn†, 1=?)
ErrFAT2  db        1                        ; p©°znak FAT2 (0=OK, FF=vadn†, 1=?)
ErrRoot  db        1                        ; p©°znak ROOT (0=OK, FF=vadnò, 1=?)
ErrDat   db        0                        ; p©°znak chyby 1. sektoru bloku

SlidX    db        0                        ; odsazen° sektorñ stran (SLIDING X)
SlidY    db        0                        ; odsazen° sektorñ v†lcñ (SLIDING Y)
Inter    db        1                        ; prokl†d†n° sektorñ (1 nebo 2)
Smer     db        0                        ; smàr form†tov†n° (0=nahoru)

PozMap   dw        11*HI+2                  ; pozice k zobrazen° mapy disku
SirMap   dw        13*HI+53                 ; ®°©ka a vò®ka okna mapy disku
CitMap   db        40                       ; á°taá stop mapy

; -----------------------------------------------------------------------------
;        definice form†tñ diskñ
; -----------------------------------------------------------------------------
; Z†kladn° parametry:
;     0: (1) p©°znaky
;               bit 0: 1=80 stop
;               bit 1: 1=v oboustrannÇm form†tu 2 sektory na blok
;               bit 2: 1=dvojitÇ krokov†n°
;               bit 3: 1=nestandardn° form†t pro tuto mechaniku
;               bit 4: 1=faktor prokl†d†n° = 2
;               bit 5: 1=prov†d° se odstup sektorñ SLIDING (1 a 2 nebo 2 a 3)
;     1: (1) poáet sektorñ na stopu (8, 9, 15 nebo 18)
;     2: (1) poáet sektorñ na ROOT
;     3: (1) popisovaá mÇdia v jednostrannÇm form†tu
;     4: (5) n†zev form†tu pro zobrazen° v menu
; Poáet sektorñ na ROOT v jednostrannÇm form†tu: vydàlen° 2 + p©enos CF
; Poáet sektorñ na ROOT v £spornÇm form†tu: vydàlen° 2 (bez p©enosu)
; Popisovaá mÇdia v oboustranÇm form†tu: popisovaá OR 1
; -----------------------------------------------------------------------------

TabForm  dw        Form1                    ; adresy definic form†tñ
         dw        Form2
         dw        Form3
         dw        Form4
         dw        Form5

Form1    label     byte                     ; definice form†tñ mechaniky typu 1
         db        3
         db        b1,    9, 7,0fch,' 360K'
         db        b1,    8, 7,0feh,' 320K'
         db  b5+b3+b1,   10, 7,0fch,' 400K'

Form2    label     byte                     ; definice form†tñ mechaniky typu 2
         db        6
         db        b0,   15,14,0f9h,' 1.2M'
         db        b1+b2, 9, 7,0fch,' 360K'
         db        b1+b2, 8, 7,0feh,' 320K'
         db  b5+b4+b3+b0,18,14,0f9h,'1.44M'
         db  b5+b3+b0+b1,10, 7,0f9h,' 800K'
         db     b3+b0+b1, 9, 7,0f9h,' 720K'

Form3    label     byte                     ; definice form†tñ mechaniky typu 3
         db        6
         db        b0+b1, 9, 7,0f9h,' 720K'
         db  b5+b3+b0+b1,12, 7,0f9h,' 980K'
         db  b5+b3+b0+b1,10, 7,0f9h,' 800K'
         db  b5+b3+b1,   10, 7,0fch,' 400K'
         db     b3+b1+b2, 9, 7,0fch,' 360K'
         db     b3+b1+b2, 8, 7,0feh,' 320K'

Form4    label     byte                     ; definice form†tñ mechaniky typu 4
         db        7
         db        b0,   18,14,0f9h,'1.44M'
         db        b0+b1, 9, 7,0f9h,' 720K'
         db  b5+b4+b3+b0,21,14,0f9h,'1.68M'
         db     b3+b0,   15,14,0f9h,' 1.2M'
         db  b5+b3+b0+b1,12, 7,0f9h,' 980K'
         db  b5+b3+b0+b1,10, 7,0f9h,' 800K'
         db     b3+b1+b2, 9, 7,0fch,' 360K'

Form5    label     byte                     ; definice form†tñ mechaniky typu 5
         db        7
         db        b0,   36,28,0f9h,'2.88M'
         db        b0,   18,14,0f9h,'1.44M'
         db        b0+b1, 9, 7,0f9h,' 720K'
         db  b5+b4+b3+b0,21,14,0f9h,'1.68M'
         db     b3+b0,   15,14,0f9h,' 1.2M'
         db  b5+b3+b0+b1,12, 7,0f9h,' 980K'
         db     b3+b1+b2, 9, 7,0fch,' 360K'

; -----------------------------------------------------------------------------
;        konfigurace programu
; -----------------------------------------------------------------------------

Konfig   label     byte

KonfIdnt db        'FORM'                   ; identifikaán° text souboru
KonfVer  db        20h                      ; verze programu FORM

AktDisk  db        0                        ; aktivn° disk
AktVol   db        0                        ; aktivn° poloëka voleb
ParSys   db        0                        ; p©°znak - je operaán° systÇm
ParLab   db        0                        ; p©°znak - zad†v† se n†và®t°
ParDat   db        0                        ; p©°znak - zachov†n° dat
ParStra  db        0                        ; p©°znak - jedna strana
ParRoot  db        0                        ; poáet sektorñ v ROOT (0=stand.)
ParObs   db        1                        ; p©°znak - zobrazen° obsahu
ParStrt  db        0                        ; p©°znak - zrychlenò start
ParBack  db        0                        ; p©°znak - zpàtnò smàr
ParInd   db        1                        ; p©°znak - zvukov† indikace
ParVerif db        1                        ; p©°znak - prov†dàn° verifikace
ParStop  db        0                        ; poáet dopl§uj°c°ch stop (0 aë 6)
ParTest  db        0                        ; poáet testovac°ch z†pisñ
ParChar  db        0f6h                     ; form†tovac° znak
ParOptim db        1                        ; p©°znak - optimalizace chyb
ParCest  db        1                        ; áe®tina na displeji
                                            ;   0=bez
                                            ;   1=Vlastn°
                                            ;   2=Kamenickòch
                                            ;   3=Latin 2
AktFormT db        4 dup(0)                 ; aktivn° form†ty diskñ A aë D

Konfig0  label     byte

TabBad   db        MAXSEKT dup(?)           ; tabulka vadnòch sektorñ stopy

         db        300h dup(?)              ; z†sobn°k
Konec    label     byte                     ; konec programu

CODE     ENDS

         END       Start


; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                                DETCARD.ASM
;
;              detekce typu videokarty a obsluhovanòch videom¢dñ
;
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

bit0     EQU       1
bit1     EQU       2
bit2     EQU       4
bit3     EQU       8
bit4     EQU       10h
bit5     EQU       20h
bit6     EQU       40h
bit7     EQU       80h

HI       EQU       256

; ------ definice barev (©†d poátu barev)

C1       EQU       HI*0
C2       EQU       HI*1
C4       EQU       HI*2
C16      EQU       HI*4
C256     EQU       HI*8
C32K     EQU       HI*15
C64K     EQU       HI*16
C16M     EQU       HI*24
C4G      EQU       HI*32

; -----------------------------------------------------------------------------
;                   definice á°sel typñ videokaret
; -----------------------------------------------------------------------------

CardStru STRUC

; ------ standardn° videokarty

CardNul  db        ?                        ; 0: nedetekov†no
CardCGA  db        ?                        ; 1: CGA
CardMCGA db        ?                        ; 2: MCGA
CardEGA  db        ?                        ; 3: EGA
CardEG64 db        ?                        ; 4: EGA 64 KB
CardEGAM db        ?                        ; 5: EGA Mono
CardEG6M db        ?                        ; 6: EGA 64 KB Mono
CardHerc db        ?                        ; 7: Hercules
CardVGA  db        ?                        ; 8: VGA
CardVESA db        ?                        ; 9: VESA SVGA (nerozpozn†n áip)

CardSVGA EQU       CardVESA+1               ; 10: SVGA zaá†tek definic SVGA

; ------ uráenÇ videokarty

CardACUM db        ?                        ; Acumos SuperVGA

CardADVL db        ?                        ; Advance Logic AL2101 SuperVGA

CardAHEA db        ?                        ; AHEAD A SuperVGA
CardAHEB db        ?                        ; AHEAD B SuperVGA

CardATI  db        ?                        ; ATI Technologies SuperVGA 18800
CardATI1 db        ?                        ; ATI Technologies SuperVGA 18800-1
CardATI2 db        ?                        ; ATI Technologies SuperVGA 28800-2
CardATI4 db        ?                        ; ATI Technologies SuperVGA 28800-4
CardATI5 db        ?                        ; ATI Technologies SuperVGA 28800-5
CardATI6 db        ?                        ; ATI Technologies SuperVGA 38800-1
CardATI7 db        ?                        ; ATI Technologies SuperVGA 68800

CardCHIP db        ?                        ; Chips & Technologies SVGA 82c451,82c455,82c456
CardCHI1 db        ?                        ; Chips & Technologies SVGA 82c452
CardCHI2 db        ?                        ; Chips & Technologies SVGA 82c453

CardCirr db        ?                        ; Cirrus 5422 SuperVGA

CardEVER db        ?                        ; Everex SuperVGA normal chipset
CardEVE1 db        ?                        ; Everex SuperVGA Ev236 (Trident) UltraGraphics
CardEVE2 db        ?                        ; Everex SuperVGA Ev620 (Trident) Vision VGA
CardEVE3 db        ?                        ; Everex SuperVGA Ev629 (ET4000) ViewPoint TC
CardEVE4 db        ?                        ; Everex SuperVGA Ev673 (Trident) EVGA
CardEVE5 db        ?                        ; Everex SuperVGA Ev678 (Trident) VidewPoint TC

CardGEN1 db        ?                        ; Genoa Systems SuperVGA GVGA 6100
CardGEN2 db        ?                        ; Genoa Systems SuperVGA GVGA 62/300
CardGEN4 db        ?                        ; Genoa Systems SuperVGA GVGA 64/600

CardMXIC db        ?                        ; MXIC 68010 SuperVGA

CardNCR0 db        ?                        ; NCR 77C20/21 SuperVGA
CardNCR2 db        ?                        ; NCR 77C22E SuperVGA

CardOAK  db        ?                        ; OAK Technologies SuperVGA OTI-037C
CardOAK1 db        ?                        ; OAK Technologies SuperVGA OTI-067
CardOAK2 db        ?                        ; OAK Technologies SuperVGA OTI-077

CardPAR  db        ?                        ; Paradise SuperVGA PVGA1A
CardPA00 db        ?                        ; Paradise SuperVGA WD90C00 chipset
CardPA10 db        ?                        ; Paradise SuperVGA WD90C10 chipset
CardPA11 db        ?                        ; Paradise SuperVGA WD90C11 chipset
CardPA20 db        ?                        ; Paradise SuperVGA WD90C20 chipset
CardPA30 db        ?                        ; Paradise SuperVGA WD90C30 chipset
CardPA31 db        ?                        ; Paradise SuperVGA WD90C31 chipset

CardPRIM db        ?                        ; Primus 2000 SuperVGA

CardReal db        ?                        ; RealTek 3106 SuperVGA

CardS911 db        ?                        ; S3 SuperVGA 86c911
CardS924 db        ?                        ; S3 SuperVGA 86c924
CardS801 db        ?                        ; S3 SuperVGA 86c801/86c805
CardS928 db        ?                        ; S3 SuperVGA 86c928

CardTRI8 db        ?                        ; Trident 8800 SuperVGA
CardTRI9 db        ?                        ; Trident 8900 SuperVGA, 9000 SuperVGA

CardET30 db        ?                        ; Tseng Labs ET3000 SuperVGA
                                            ; (Tseng Labs ET4000 SuperVGA):
CardET40 db        ?                        ; Standard Tseng MegaEva/2 ET4000
CardET41 db        ?                        ; Diamond Speedstar 24 ET4000 (24 bit)
CardET42 db        ?                        ; Genoa 7900 ET4000 (24 bit)

CardVID7 db        ?                        ; Video7 SuperVGA

CardStru ENDS

CardNumN EQU       size CardStru            ; poáet definovanòch videokaret

; -----------------------------------------------------------------------------
;        definice poloëky v tabulce videom¢dñ
; -----------------------------------------------------------------------------

MAXMOD   EQU       100                      ; maxim†ln° poáet videom¢dñ

ModStru  STRUC
ModMod   dw        ?                        ; á°slo videom¢du
ModPar   db        ?                        ; parametry videom¢du
                                            ;    bit 0: 0=textovò/1=grafickò m¢d
                                            ;    bit 7: 1=je videom¢d VESA
ModCol   db        ?                        ; poáet bitñ na barvu (0=MONO)
ModX     dw        ?                        ; ®°©ka obrazovky (bodñ, znakñ)
ModY     dw        ?                        ; vò®ka obrazovky (linek, ©†dkñ)
ModStru  ENDS

ModSize  EQU       size ModStru             ; velikost poloëky videom¢du

; -----------------------------------------------------------------------------
;        definice typu VGA DAC (p©evodn°k na paletu)
; -----------------------------------------------------------------------------

DACTyp0  EQU       0                        ; MONO
DACTyp1  EQU       1                        ; 1 bit, 2 barvy
DACTyp2  EQU       2                        ; 2 bity, 4 barvy CGA
DACTyp4  EQU       3                        ; 4 bity, 16 barev EGA
DACTyp8  EQU       4                        ; 8 bitñ, 256 barev VGA
DACTyp15 EQU       5                        ; 15 bitñ, HiColor SVGA
DACTyp16 EQU       6                        ; 16 bitñ, HiColor SVGA
DACTyp24 EQU       7                        ; 24 bitñ, TrueColor SVGA
DACTyp32 EQU       8                        ; 32 bitñ, TrueColor SVGA

; -----------------------------------------------------------------------------
;        ostatn° konstanty
; -----------------------------------------------------------------------------

;CRTC     EQU       3D4h                     ; adresa ©adiáe CRTC - barevnò
;CRTCM    EQU       3B4h                     ; adresa ©adiáe CRTC - MONO


Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

Start:   mov       ax,offset Code:DataBeg + 0fh
         mov       cl,4
         shr       ax,cl
         mov       bx,cs
         add       ax,bx
         mov       ds,ax                    ; DS <- datovò segment


         call      DetSVGA
         jnc       Start1
         xor       ax,ax
         mov       bx,256

Start1:  mov       ds:[VMemSize],bx         ; velikost videopamàti
         mov       ds:[VCard],ax            ; á°slo videokarty

         push      ax
         mov       ax,3
         call      Int10P
         pop       ax

         mov       si,offset TDefCard

;         mov       ax,CardEnds

         or        ax,ax
         jz        Start3

Start2:  mov       si,cs:[si]
         dec       ax
         jnz       Start2

Start3:  inc       si
         inc       si

         push      ds
         push      cs
         pop       ds
         call      DispTxt
         pop       ds

         mov       si,offset TextKB1
         call      DispTxt
         mov       ax,ds:[VMemSize]
         call      DispNum
         mov       si,offset TextKB2
         call      DispTxt

         int       20h

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                          ObsluënÇ procedury
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞



; -----------------------------------------------------------------------------
;        zobrazen° á°sla AX
; -----------------------------------------------------------------------------

DispNum  PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx

         mov       bx,10
         xor       cx,cx
DispNum1:xor       dx,dx
         div       bx
         push      dx
         inc       cx
         or        ax,ax
         jnz       DispNum1

DispNum2:pop       ax
         add       al,"0"
         call      DispChr
         loop      DispNum2

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispNum  ENDP

; -----------------------------------------------------------------------------
;        zobrazen° textu DS:SI (1. bajt = dÇlka textu)
; -----------------------------------------------------------------------------

DispTxt  PROC      NEAR

         push      cx
         push      si

         mov       cl,ds:[si]
         inc       si
         call      DispTxt0

         pop       si
         pop       cx
         ret

DispTxt  ENDP

; -----------------------------------------------------------------------------
;        zobrazen° textu DS:SI/CL znakñ
; -----------------------------------------------------------------------------

DispTxt0 PROC      NEAR

         push      ax
         push      cx
         push      si

         mov       ch,0
         jcxz      DispTxt3
DispTxt1:cld
         lodsb
         call      DispChr
         loop      DispTxt1

DispTxt3:pop       si
         pop       cx
         pop       ax
         ret

DispTxt0 ENDP

; -----------------------------------------------------------------------------
;        zobrazen° znaku AL
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
;                              Int10P
;                obsluha INT 10h s £schovou registrñ
; -----------------------------------------------------------------------------
;
; *****************************************************************************

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
;                              Inicializace videom¢dñ
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

; -----------------------------------------------------------------------------
;        inicializace videom¢du AL bàënou sluëbou
; -----------------------------------------------------------------------------

InitNul  PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx

         mov       ah,0
         call      Int10P

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

InitNul  ENDP

; -----------------------------------------------------------------------------
;        inicializace ATI
; -----------------------------------------------------------------------------

InitATI  PROC      NEAR

         pushf
         push      ax
         push      bx
         push      cx
         push      dx

         mov       ah,0
         call      Int10P

; ------ nastaven° 1-bankovÇho m¢du

         cli
         mov       dx,cs:[PortATI]          ; adresa portu ATI
         mov       ah,0beh
         call      ReadIPrt
         and       al,not bit3              ; nastaven° 1-bankovÇho m¢du
         call      WritIPrt                 ; nastaven° 1-bankovÇho m¢du

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         popf
         ret

InitATI  ENDP

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                             Detekce videokaret
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛



; *****************************************************************************
;                              DetSVGA
;                       detekce videokarty SVGA
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP: CY=nenalezena
;         AX=identifikaán° k¢d karty
;         BX=velikost videopamàti
; *****************************************************************************

DetSVGA  PROC      NEAR

         push      cx
         push      si
         push      di
         push      es

; ------ provà©en° struktury tabulky

         mov       si,offset TDefCard
         xor       ax,ax                    ; ukazatel á°sla karty
         mov       ch,0
DetSVGA1:mov       di,si                    ; zaá†tek definice karty
         mov       si,cs:[di]               ; adresa definice dal®° karty
         inc       di
         inc       di
         mov       cl,cs:[di]               ; dÇlka textu n†zvu karty
         inc       di
         add       di,cx                    ; p©eskoáen° textu n†zvu
         mov       cl,cs:[di]               ; dÇlka textu hledac°ho textu
         inc       di
         add       di,cx                    ; p©eskoáen° hledac°ho textu
         add       di,2+2                   ; p©eskoáen° adresy testu+inic.
         cmp       di,si                    ; souhlas° ?
         jne       DetSVGA2

         inc       ax
         cmp       ax,CardNumN
         jb        DetSVGA1
         xor       ax,ax
         cmp       si,offset TDefCrd0       ; je konec tabulky ?
DetSVGA2:clc
         jne       DetSVGA9

; ------ vyhled†n° karty SVGA testem ©etàzce i portñ

         mov       cx,CardSVGA-1            ; ukazatel á°sla karty
DetSVGA3:inc       cx                       ; zvò®en° ukazatele á°sla karty
         call      GetPCard                 ; p©°prava parametrñ dal®° karty
         jc        DetSVGA4                 ; karta nenalezena
         call      TestCSrc                 ; test vyhled†n°m ©etàzce
         jc        DetSVGA3                 ; nenalezen - dal®° karta
         call      TestCPrt                 ; test portñ karty
         jc        DetSVGA3                 ; nenalezen -> AX=á°slo karty
         jmp       short DetSVGA9           ; souhlas° test ©etàzce i portñ

; ------ vyhled†n° karty SVGA testem jen portñ

DetSVGA4:mov       cx,CardSVGA-1
DetSVG42:inc       cx                       ; zvò®en° ukazatele á°sla karty
         call      GetPCard                 ; p©°prava parametrñ dal®° karty
         jc        DetSVGA5                 ; karta nenalezena
         call      TestCPrt                 ; test portñ karty
         jc        DetSVG42                 ; nenalezen -> AX=á°slo karty
         jmp       short DetSVGA9           ; souhlas° test portñ

; ------ vyhled†n° karty SVGA testem jen ©etàzce

DetSVGA5:mov       cx,CardSVGA-1            ; ukazatel á°sla karty
DetSVG52:inc       cx                       ; zvò®en° ukazatele á°sla karty
         call      GetPCard                 ; p©°prava parametrñ dal®° karty
         jc        DetSVGA6                 ; karta nenalezena
         call      TestCSrc                 ; test vyhled†n°m ©etàzce
         jc        DetSVG52                 ; nenalezen - dal®° karta

         xchg      ax,cx                    ; AX <- á°slo nalezenÇ videokarty
         mov       bx,256                   ; z©ejmà bude 256 KB pamàti

DetSVGA6:

DetSVGA9:pop       es
         pop       di
         pop       si
         pop       cx
         ret

DetSVGA  ENDP

; *****************************************************************************
;                                TestCSrc
;                   test aktivn° karty vyhled†n°m ©etàzce
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP: CY=nen° ©etàzec
; *****************************************************************************

TestCSrc PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      si
         push      di
         push      ds
         push      es

; ------ test, zda m† bòt ©etàzec vyhled†v†n

         mov       di,ds:[ACardSrc]         ; adresa vyhled†vac°ho ©etàzce
         push      cs
         pop       es                       ; ES <- segment definián° tabulky
         mov       cl,es:[di]               ; dÇlka ©etàzce
         mov       ch,0
         inc       di                       ; zaá†tek textu k vyhled†n°
         jcxz      TestCSr8                 ; nen° ©etàzec k vyhled†n°

; ------ p©°prava parametrñ

         mov       ax,0c000h                ; segment BIOS
         mov       ds,ax                    ; DS <- segment BIOS
         xor       si,si                    ; vyhled†vac° adresa
         cld

; ------ porovn†n° ©etàzce na jednÇ adrese

TestCSr2:push      si
         push      di
         push      cx

TestCSr3:lodsb                              ; naáten° znaku z BIOS
         cmp       al,"a"
         jb        TestCSr4
         cmp       al,"z"
         ja        TestCSr4
         sub       al,32                    ; konverze na velkÇ p°smeno
TestCSr4:scasb                              ; porovn†n° s referenán°m textem
         loope     TestCSr3                 ; p©i shodà dal®° znak

         pop       cx
         pop       di
         pop       si
         je        TestCSr9                 ; ©etàzec nalezen OK

; ------ p©°prava pro dal®° adresu

         inc       si                       ; zvò®en° adresy v BIOS
         cmp       si,400h                  ; asi tak maxim†ln° adresa
         jb        TestCSr2                 ; test dal®° adresy

TestCSr8:stc                                ; p©°znak nenalezen° ©etàzce

; ------ n†vrat registrñ

TestCSr9:pop       es
         pop       ds
         pop       di
         pop       si
         pop       cx
         pop       ax
         ret

TestCSrc ENDP

; *****************************************************************************
;                               TestCPrt
;                      test aktivn° karty testem portñ
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP: CY=karta nesouhlas°
;         AX=identifikaán° á°slo karty
;         BX=velikost videopamàti v KB
; *****************************************************************************

TestCPrt PROC      NEAR

; ------ £schova registrñ

         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es

; ------ test, zda se prov†d° test

         cmp       word ptr ds:[ACardTst],1 ; prov†d° se test ?
         jb        TestCPr9                 ; test se neprov†d°
         call      word ptr ds:[ACardTst]   ; proveden° testu videokarty

; ------ n†vrat registrñ

TestCPr9:pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         ret

TestCPrt ENDP

; *****************************************************************************
;                               GetPCard
;                      poskytnut° parametrñ karty
; -----------------------------------------------------------------------------
; VSTUP: CX=á°slo videokarty
;        DS=datovò segment
; VùSTUP: CY=neplatnÇ á°slo videokarty
; *****************************************************************************

GetPCard PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      si

; ------ kontrola á°sla videokarty

         cmp       cx,CardNumN-1            ; kontrola maxim†ln°ho á°sla
         cmc
         jc        GetPCar9                 ; neplatnÇ á°slo karty

; ------ vyhled†n° definice karty

         mov       si,offset TDefCard       ; tabulka definic karet
         jcxz      GetPCar2                 ; je karta 0
GetPCar1:mov       si,cs:[si]               ; adresa definice dal®° karty
         loop      GetPCar1                 ; nalezen° definice karty

; ------ uloëen° adresy definic

GetPCar2:inc       si
         inc       si                       ; p©eskoáen° adresy dal®° karty
         mov       ds:[ACardNam],si         ; adresa jmÇna karty

         mov       al,cs:[si]               ; dÇlka textu jmÇna karty
         inc       si
         mov       ah,0
         add       si,ax                    ; p©eskoáen° jmÇna karty
         mov       ds:[ACardSrc],si         ; adresa vyhled†vac°ho ©etàzce

         mov       al,cs:[si]               ; dÇlka vyhled†vac°ho ©etàzce
         inc       si
         add       si,ax                    ; p©eskoáen° vyhled†vac°ho ©etàzce
         mov       ax,cs:[si]
         mov       ds:[ACardTst],ax         ; adresa obsluhy testu karty

         inc       si
         inc       si
         mov       ax,cs:[si]
         mov       ds:[ACardIni],ax         ; adresa inicializace videom¢du AX

; ------ n†vrat registrñ

         clc                                ; p©°znak platnÇho á°sla karty
GetPCar9:pop       si
         pop       cx
         pop       ax
         ret

GetPCard ENDP

; *****************************************************************************
;                             TestVESA
;                        test ovladaáe VESA
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP: CY=nen° ovladaá VESA
; *****************************************************************************

TestVESA PROC      NEAR

; ------ naáten° informac° VESA

         push      ds
         pop       es                       ; ES <- datovò segment
         mov       di,offset VesaInfo       ; DI <- buffer informac° VESA
         mov       ax,4f00h
         call      Int10P                   ; test ovladaáe VESA

; ------ test navr†cenÇho stavu

         cmp       ax,4fh
         jne       TestVES8                 ; nen° VESA
         cmp       word ptr es:[di],"EV"
         jne       TestVES8                 ; nen° VESA
         cmp       word ptr es:[di+2],"AS"
         jne       TestVES8


         mov       bx,256

         jmp       short TestVES9

;; We have a VESA compatible SuperVGA, so determine how much memory must
;; be on the video board by finding the amount of memory used by the
;; highest resolution video mode supported.
;;
;; At the same time initialise the table of valid video modes for this
;; SuperVGA, and bytes per line values for the video mode.
;
;        push    ds
;        push    bp
;        mov     ax,[WORD es:di+16]
;        mov     ds,ax
;        mov     bp,[WORD es:di+14]  ; DS:BP -> List of valid VESA modes
;        mov si,offset AllVesaModes
;        mov     bx,offset VesaModes
;        cld
;
;@@VesaMemLoop:
;        lods    [WORD cs:si]        ; Load VESA mode number
;        mov     cx,ax
;        jcxz    @@EndVESA           ; Finished when mode number is zero
;        lods    [WORD cs:si]        ; Load amount of memory required for mode
;        push    ax          ;   and save on stack
;        lods    [WORD cs:si]        ; Load MGL video mode number
;        push    ax                  ;   and save on stack
;
;; First check to see if the mode is a valid VESA mode.
;
;        mov     di,bp               ; DS:DI -> mode list
;@@CheckMode:
;        mov     ax,[WORD ds:di]
;        inc     di
;        inc     di
;        cmp     ax,-1
;        je      @@NotFound
;        cmp     ax,cx
;        je      @@FoundMode         ; Yes mode was found
;        jmp     @@CheckMode         ; Loop for all valid modes
;
;@@NotFound:
;        pop     ax                  ; Restore stack
;        pop     ax
;        jmp     @@VesaMemLoop       ; Continue loop
;
;@@FoundMode:
;        mov     ax,seg VesaBuf
;        mov     es,ax
;        mov     di,offset VesaBuf
;        mov     ax,4F01h            ; AX := Query Mode Information
;        int     10h
;        pop     dx                  ; DX := MGL Mode Number
;        pop     cx                  ; CX := Video memory required
;        or      ah,ah
;        jnz     @@VesaMemLoop       ; Mode not supported, try next one
;        test    [BYTE es:di],1
;        jz      @@VesaMemLoop       ; Mode not supported, try next one
;
;; Video mode is supported, so add to mode table.
;
;        push    bx
;        mov     bx,[WORD es:di+16]
;        mov     ax,dx
;        call    setBytesPerLine     ; Set the bytes per line value for mode
;        pop     bx
;        mov     [BYTE cs:bx],dl     ; Store the mode number
;        inc     bx
;
;        cmp     cx,[WORD VideoMem]
;        jle     @@VesaMemLoop       ; Memory is less, try next mode
;        mov     [WORD VideoMem],cx  ; Increase the memory size
;        jmp     @@VesaMemLoop
;
;@@EndVESA:
;        pop     bp
;        pop     ds
;        call    checkVESAPageFlip   ; Does VESA support page flipping?
;        jc      @@NoFlip
;        mov     [PageFlip],true
;
;@@NoFlip:
;        mov     [WORD VideoModes],offset VesaModes
;        mov     ax,grSVGA
;        stc
;        ret
;
;@@NoVESA:
;        clc
;        ret
;
;ENDP    FindVESA
;

TestVES8:stc
TestVES9:mov       ax,CardVESA              ; identifik†tor VESA
         ret

TestVESA ENDP

; *****************************************************************************
;                                 TestS3
;                           test karty S3 SVGA
; -----------------------------------------------------------------------------
; VùSTUP: CY=nen° karta S3 SVGA
;         AX=identifik†tor karty
;         BX=velikost videopamàti (v KB)
; *****************************************************************************

TestS3   PROC      NEAR

; ------ £schova z†mku registrñ

         mov       dx,3d4h
         mov       ah,38h
         call      ReadIPrt                 ; áten° z†mku registrñ
         mov       ch,al                    ; CH <- £schova z†mku

; ------ uzamáen° registrñ

         mov       al,0
         call      WritIPrt                 ; uzamáen° registrñ

; ------ test registrñ - nesm° bòt modifikovatelnÇ

         mov       ax,35h*HI + bit0+bit1+bit2+bit3
         call      TestIPrt                 ; test registru
         cmc
         jc        TestS39                  ; nen° S3 SVGA

; ------ odemknut° registrñ

         mov       ax,38h*HI + 48h
         call      WritIPrt                 ; odemknut° registrñ

; ------ test registrñ - mus° bòt modifikovatelnÇ

         mov       ax,35h*HI + bit0+bit1+bit2+bit3
         call      TestIPrt                 ; test registru
         jc        TestS39                  ; nen° S3 SVGA

; ------ detekce typu áipu S3 SVGA -> BX

         mov       ah,30h
         call      ReadIPrt                 ; áten° á°sla verze áipu
         mov       bx,CardS928              ; identifik†tor S3 SVGA 86c928
         cmp       al,90h
         je        TestS32                  ; je S3 SVGA 86c928
         mov       bx,CardS801              ; identifik†tor S3 SVGA 86c801/805
         cmp       al,0a0h
         je        TestS32                  ; je S3 SVGA 86c801/805
         mov       bx,CardS924              ; identifik†tor S3 SVGA 86c924
         cmp       al,82h
         je        TestS32                  ; je S3 SVGA 86c924
         mov       bx,CardS911              ; jinak je S3 SVGA 86c911

; ------ detekce velikosti videopamàti

TestS32: push      bx                       ; identifik†tor karty
         mov       ah,36h
         call      ReadIPrt                 ; áten° registru velikosti pamàti
         mov       cl,5
         shr       al,cl                    ; rotace na pozici

         cmp       bx,CardS911
         je        TestS34                  ; je S3 SVGA 86c911
         cmp       bx,CardS924
         je        TestS34                  ; je S3 SVGA 86c924

; ------ velikost pamàti pro 86c801/86c805/86c928

         mov       bx,512                   ; 512 KB pamàti
         cmp       al,7
         je        TestS36
         shl       bx,1                     ; 1 MB pamàti
         cmp       al,6
         je        TestS36
         shl       bx,1                     ; 2 MB pamàti
         cmp       al,4
         je        TestS36
         mov       bx,3072                  ; 3 MB pamàti
         cmp       al,2
         je        TestS36
         mov       bx,4096                  ; jinak 4 MB pamàti
         jmp       short TestS36

; ------ velikost pamàti pro 86c911/86c924

TestS34: mov       bx,512                   ; 512 KB pamàti
         test      al,bit0
         jnz       TestS36
         shl       bx,1                     ; jinak 1 MB pamàti
TestS36: pop       ax                       ; identifik†tor S3 SVGA
         clc                                ; p©°znak operace OK

; ------ n†vrat registru z†mku (DX=3d4h)

TestS39: pushf
         push      ax
         mov       ah,38h
         mov       al,ch
         call      WritIPrt                 ; n†vrat registru z†mku
         pop       ax
         popf
         ret

TestS3   ENDP

; *****************************************************************************
;                                 TestATI
;                      test karty ATI Technologies SuperVGA
; -----------------------------------------------------------------------------
; VùSTUP: CY=nen° karta ATI Technologies SuperVGA
;         AX=identifik†tor karty
;         BX=velikost videopamàti (v KB)
; *****************************************************************************

TestATI  PROC      NEAR

; ------ detekce podle pamàti BIOS

         mov       ax,0c000h
         mov       es,ax
         xor       bx,bx
;         cmp       word ptr es:[bx+40h],"13"; identifikace "ATI" pro VGA
;         jne       TestATI2                 ; nen° ATI Technologies SuperVGA

; ------ kontrola ©etàzce "761295520"

         cmp       word ptr es:[bx+31h],"67"
         jne       TestATI2
         cmp       word ptr es:[bx+31h+2],"21"
         jne       TestATI2
         cmp       word ptr es:[bx+31h+4],"59"
         jne       TestATI2
         cmp       word ptr es:[bx+31h+6],"25"
         jne       TestATI2
         cmp       byte ptr es:[bx+31h+8],"0"
TestATI2:stc
         jne       TestATI9

; ------ test registru volby banky

         mov       dx,es:[bx+10h]           ; b†zov† adresa roz®°©enòch portñ
         mov       ax,0b2h*HI + bit1+bit2+bit3 ; registr volby banky
         call      TestIPrt                 ; test portu volby banky
         jnc       TestAT22                 ; port je OK
         mov       dx,1ceh                  ; to je implicitn° adresa
         call      TestIPrt                 ; test implicitn° adresy
         jc        TestATI9                 ; nen° karta ATI SuperVGA
TestAT22:mov       cs:[PortATI],dx          ; adresa portu ATI

; ------ detekce verze áipu ATI 18800 nebo 18800-1

         mov       ch,es:[bx+43h]           ; verze áipu ATI
         cmp       ch,"2"
         ja        TestATI4                 ; je vy®®° verze áipu

         mov       ax,CardATI1              ; je ATI Technologies SVGA 18800-1
         je        TestATI3                 ; verze 2
         mov       ax,CardATI               ; je ATI Technologies SuperVGA 18800

; ------ detekce velikosti pamàti pro 18800 a 18800-1

TestATI3:push      ax
         mov       ah,0bbh
         call      ReadIPrt                 ; áten° velikosti pamàti
         mov       bx,256                   ; 256 KB videopamàti
         test      al,bit5                  ; je 256 KB pamàti ?
         pop       ax
         jz        TestATI7                 ; je 256 KB pamàti
         shl       bx,1                     ; 512 KB pamàti
         jmp       short TestATI7

; ------ detekce velikosti pamàti pro 28800-2, 28800-4 a 28800-5

TestATI4:mov       ah,0b0h
         call      ReadIPrt                 ; áten° velikosti pamàti
         mov       bx,256                   ; 256 KB videopamàti
         test      al,bit4                  ; je 256 KB pamàti ?
         jz        TestATI5                 ; je 256 KB pamàti
         shl       bx,1                     ; je 512 KB pamàti
TestATI5:mov       cl,al                    ; CL <- £schova bajtu

; ------ detekce verze áipu ATI 28800-2, 28800-4 nebo 28800-5

         mov       ax,CardATI2              ; ATI Technologies SVGA 28800-2
         cmp       ch,"4"
         jb        TestATI7                 ; je ATI Technologies SVGA 28800-2
         mov       ax,CardATI4              ; ATI Technologies SVGA 28800-4
         je        TestATI6                 ; je ATI Technologies SVGA 28800-4
         mov       ax,CardATI5              ; ATI Technologies SVGA 28800-5
         cmp       ch,"5"
         je        TestATI6                 ; je ATI Technologies SVGA 28800-5
         mov       ax,CardATI7              ; ATI Technologies SVGA 68800
         or        ch,20h                   ; konverze na malÇ p°smeno
         cmp       ch,"a"
         jae       TestATI6                 ; je ATI Technologies SVGA 68800
         mov       ax,CardATI6              ; ATI Technologies SVGA 38800

; ------ up©esnàn° velikosti pamàti pro 28800-4 a vy®®°

TestATI6:test      cl,bit3                  ; up©esnàn° velikosti pamàti
         jz        TestATI7                 ; nen° 1 MB pamàti
         shl       bx,1                     ; je 1 MB pamàti (pop©. 2 MB ?)
TestATI7:clc                                ; p©°znak platnosti karty

TestATI9:ret

TestATI  ENDP

PortATI  dw        1ceh                     ; adresa portu ATI

; *****************************************************************************
;                                 TestNCR
;                      test karty NCR 77C22E SuperVGA
; -----------------------------------------------------------------------------
; VùSTUP: CY=nen° karta NCR 77C22E SuperVGA
;         AX=identifik†tor karty
;         BX=velikost videopamàti (v KB)
; *****************************************************************************

TestNCR  PROC      NEAR

; ------ £schova registru roz®°©enÇho m¢du

         mov       dx,3c4h
         mov       ah,5                     ; index
         call      ReadIPrt                 ; áten° registru
         mov       ch,al                    ; CH <- £schova registru

; ------ test registru roz®°©enÇho m¢du

         mov       al,bit0+bit2             ; AL <- maska
         call      TestIPrt                 ; test registru
         jc        TestNCR9                 ; nen° karta NCR 77C22E SuperVGA

; ------ z†kaz registrñ

         mov       al,0
         call      WritIPrt                 ; z†kaz registrñ

; ------ test registrñ - nesm° bòt zapisovatelnÇ

         mov       ax,10h*HI + 0ffh
         call      TestIPrt                 ; nesm° bòt z†pis
         cmc
         jc        TestNCR9                 ; lze zapisovat - neplat°

; ------ povolen° registrñ

         mov       ax,5*HI + 1              ; AH <- index, AL <- hodnota
         call      WritIPrt                 ; povolen° registrñ

; ------ test registrñ - teÉ mus° bòt modifikovatelnÇ

         mov       ax,10h*HI + 0ffh
         call      TestIPrt                 ; test registru
         jc        TestNCR9                 ; nelze zapisovat - chyba

; ------ detekce verze áipu

         mov       ah,8                     ; index
         call      ReadIPrt                 ; áten° verze áipu
         mov       cl,4
         shr       al,cl
         cmp       al,2
         mov       ax,CardNCR0              ; identifikace NCR77C20/21
         jb        TestNCR2                 ; je NCR77C20/21
         mov       ax,CardNCR2              ; identifikace NCR77C22

; ------ nastaven° videom¢du

TestNCR2:push      ax
         mov       ax,5eh
         call      Int10P                   ; nastaven° videom¢du 640x400/256

; ------ detekce velikosti videopamàti

         mov       bx,4096                  ; maxim†lnà 4 MB videopamàti
         mov       dx,offset BankNCR        ; obsluha p©ep°n†n° banky
         call      TestMem                  ; detekce velikosti videopamàti
         pop       ax
                                          ;* zde je CY = chyba pamàti
; ------ n†vrat registru roz®°©enÇho m¢du

TestNCR9:pushf
         push      ax
         mov       ah,5                     ; index
         mov       al,ch                    ; pñvodn° hodnota
         mov       dx,3c4h
         call      WritIPrt                 ; n†vrat registru
         pop       ax
         popf
         ret

TestNCR  ENDP

; *****************************************************************************
;                                 TestTri
;                      test karty Trident SuperVGA
; -----------------------------------------------------------------------------
; VùSTUP: CY=nen° karta Trident SuperVGA
;         AX=identifik†tor karty
;         BX=velikost videopamàti (v KB)
; *****************************************************************************

TestTri  PROC      NEAR

; Pozn.: NàkterÇ star®° verze Trident nesn†®ej° p©°stup na port "star† definice"
;        16 bitñ, mus° se prov†dàt 8-bitovà. Test popisovanò v VGADOC (z†pis
;        vzorku do registu volby banky) zpñsobuje u nàkteròch TVGA hav†rii.
;        Zd† se, ëe problÇm odstran° resetov†n° karty nastaven°m videom¢du
;        p©ed p©epnut°m banky.

; ------ nastaven° starÇ definice

         mov       dx,3c4h
         mov       al,0bh
         out       dx,al                    ; index 0Bh
         inc       dx
         mov       al,0
         out       dx,al                    ; nastaven° starÇ definice

; ------ detekce karty Trident SuperVGA

         in        al,dx                    ; nastaven° novÇ definice
         and       al,0fh
         cmp       al,2
         jb        TestTri9                 ; nen° Trident SuperVGA
         je        TestTri4                 ; je Trident 8800

; ------ je Trident 8900/9000 - detekce velikosti pamàti

         mov       dl,0d4h                  ; port 3D4h
         mov       ah,1fh                   ; registr pamàti
         call      ReadIPrt                 ; áten° registu pamàti
         and       al,bit0+bit1
         mov       bx,256                   ; je 256 KB pamàti
         cmp       al,1
         jb        TestTri2                 ; je 256 KB pamàti
         shl       bx,1                     ; 512 KB pamàti
         cmp       al,3
         jb        TestTri2                 ; je 512 KB pamàti
         shl       bx,1                     ; 1 MB pamàti
TestTri2:mov       ax,CardTri9              ; identifikace Trident 8900
         jmp       short TestTri6

; ------ je Trident 8800 - detekce velikosti pamàti

TestTri4:mov       ah,1fh                   ; registr pamàti
         mov       dl,0d4h                  ; port 3D4h
         call      ReadIPrt                 ; áten° registru pamàti
         mov       bx,256                   ; je 256 KB pamàti
         and       al,bit1
         jz        TestTri5                 ; je 256 KB pamàti
         shl       bx,1                     ; je 512 KB pamàti
TestTri5:mov       ax,CardTri8              ; identifikace Trident 8800
TestTri6:clc                                ; p©°znak operace OK

TestTri9:ret

TestTri  ENDP

; *****************************************************************************
;                                 TestVID
;                      test karty Video7 SuperVGA
; -----------------------------------------------------------------------------
; VùSTUP: CY=nen° karta Video7 SuperVGA
;         AX=identifik†tor karty
;         BX=velikost videopamàti (v KB)
; *****************************************************************************

TestVID  PROC      NEAR

; ------ detekce videokarty

         mov       ax,6f00h
         xor       bx,bx
         call      Int10P
         cmp       bx,"V7"
         stc                                ; p©°znak chyby
         jne       TestVID9                 ; nen° Video7 SuperVGA

; ------ detekce velikosti videopamàti

         mov       ax,6f07h
         call      Int10P
         and       ah,7fh
         mov       bx,256                   ; je 256 KB pamàti
         cmp       ah,2
         jb        TestVID2                 ; je 256 KB videopamàti
         shl       bx,1                     ; je 512 KB pamàti
         cmp       ah,4
         jb        TestVID2                 ; je 512 KB pamàti
         shl       bx,1                     ; je 1 MB pamàti

TestVID2:mov       ax,CardVID7              ; identifik†tor karty
         clc                                ; p©°znak operace OK
TestVID9:ret

TestVID  ENDP

; *****************************************************************************
;                                 TestGENO
;                      test karty Genoa GVGA SuperVGA
; -----------------------------------------------------------------------------
; VùSTUP: CY=nen° karta Genoa GVGA SuperVGA
;         AX=identifik†tor karty
;         BX=velikost videopamàti (v KB)
; *****************************************************************************

TestGENO PROC      NEAR

; ------ test identifikace v pamàti

         mov       ax,0c000h
         mov       es,ax                    ; ES <- segment pamàti BIOS SVGA
         mov       bx,es:[37h]              ; offset informaán° tabulky
         cmp       byte ptr es:[bx],77h     ; je GENOA ?
         jne       TestGEN8                 ; nen° GENOA
         cmp       word ptr es:[bx+2],6699h
         jne       TestGEN8                 ; nen° GENOA

; ------ rozli®en° varianty GENOA

         mov       cl,es:[bx+1]             ; á°slo varianty karty
         mov       bx,256                   ; je 256 KB videopamàti
         mov       ax,CardGEN2              ; identifikace GENOA 62/300
         or        cl,cl
         jz        TestGEN9                 ; je GENOA 62/300
         mov       ax,CardGEN1
         cmp       cl,22h
         je        TestGEN9                 ; je GENOA 6100
         shl       bx,1                     ; je 512 KB videopamàti
         mov       ax,CardGEN4
         cmp       cl,11h
         je        TestGEN9                 ; je GENOA 64/600
TestGEN8:stc                                ; p©°znak neplatnÇ karty
TestGEN9:ret

TestGENO ENDP

; *****************************************************************************
;                                 TestPAR
;                      test karty Paradise SuperVGA
; -----------------------------------------------------------------------------
; VùSTUP: CY=nen° karta Paradise SuperVGA
;         AX=identifik†tor karty
;         BX=velikost videopamàti (v KB)
; *****************************************************************************

TestPAR  PROC      NEAR

; ------ £schova registru z†mku (b0 aë b2: 5=odemknut° R9 aë R0D)

         mov       dx,3ceh
         mov       ah,0fh
         call      ReadIPrt                 ; áten° registru z†mku
         mov       ch,al                    ; CH <- £schova registru

; ------ uzamáen° registrñ 9 aë 0D (pro áten° i z†pis)

         and       al,not bit0+bit1+bit2+bit4 ; nulov†n° bitñ
         call      WritIPrt                 ; z†pis - uzamáen° registrñ

; ------ test modifikace registru volby banky (nesm° bòt mànitelnò)

         mov       ax,9*HI + 7fh            ; AH <- index, AL <- maska
         call      TestIPrt                 ; test registru volby banky
         jnc       TestPAR2                 ; je mànitelnò - chyba

; ------ odemknut° registrñ 9 aë 0D

         mov       ax,0fh*HI + 5            ; AH <- index, AL <- hodnota
         call      WritIPrt                 ; odemknut° registrñ

; ------ test modifikace registru volby banky (mus° bòt mànitelnò)

         mov       ax,9*HI + 7fh            ; AH <- index, AL <- maska
         call      TestIPrt                 ; test registru volby banky
         jnc       TestPAR3                 ; je karta OK
TestPAR2:stc                                ; p©°znak chyby karty
         jmp       TestPAR9                 ; nen° mànitelnò - chyba

; ====== je Paradise SVGA - detekce áipu PVGA1A

; ------ £schova registru z†mku WD90Cxx (b0 aë b2: 5=odemknut° R2A aë R30)

TestPAR3:mov       dl,0d4h                  ; port 3D4h
         mov       ah,29h
         call      ReadIPrt                 ; naáten° stavu registru
         mov       cl,al                    ; CL <- £schova registru z†mku

; ------ odemknut° registru z†mku WD90Cxx

         and       al,not bit0+bit1+bit2+bit3 ; z†pis povolen
         or        al,5+bit7                ; áten° povoleno
         call      WritIPrt                 ; odemknut° registrñ

; ------ test registru "scratch" WD90Cxx

         mov       ax,2bh*HI + 0ffh         ; AH <- index, AL <- maska
         call      TestIPrt                 ; test registru "scratch"

; ------ n†vrat registru z†mku WD90Cxx

         pushf
         mov       ah,29h                   ; registr z†mku
         mov       al,cl                    ; pñvodn° hodnota registru
         call      WritIPrt                 ; n†vrat obsahu registru z†mku
         popf
         mov       ax,CardPAR               ; identifik†tor PVGA1A
         jc        TestPAR7                 ; chyba - je karta PVGA1

; ====== je WD90Cxx - detekce áipu

; ------ £schova registru 6 karty WD90C1x

         mov       dl,0c4h                  ; port 3C4h
         mov       ah,6                     ; index
         call      ReadIPrt                 ; áten° registru
         mov       cl,al                    ; CL <- £schova registru 6

; ------ odemknut° registrñ WD90C1x

         mov       al,48h
         call      WritIPrt                 ; odemknut° registrñ

; ------ test registru 7 "scratch"

         mov       ax,7*HI + bit4+bit5+bit6+bit7 ; AH <- index, AL <- maska
         call      TestIPrt                 ; test registru
         mov       ax,CardPA00              ; identifik†tor WD90C00
         jc        TestPAR6                 ; je WD90C00

; ------ test, zda je WD90C2x

         mov       ax,10h*HI + 0ffh
         call      TestIPrt
         mov       ax,CardPA20              ; identifik†tor WD90C20
         jc        TestPAR6                 ; je áip WD90C2x

; ------ test, zda je WD90C1x

         mov       ax,14h*HI + bit0+bit1+bit2+bit3
         call      TestIPrt                 ; test portu
         jc        TestPAR4                 ; je áip WD90C1x

; ------ je WD90C3x - rozli®en° varianty

         mov       dl,0d4h                  ; port 3D4h
         mov       ah,37h                   ; index
         call      ReadIPrt                 ; áten° registru
         cmp       al,"1"                   ; je WD90C31 ?
         mov       ax,CardPA31              ; identifik†tor áipu WD90C31
         je        TestPAR6                 ; je WD90C31
         mov       ax,CardPA30              ; identifik†tor áipu WD90C30
         jmp       short TestPAR6

; ------ je áip WD90C1x - rozli®en° varianty (registr interface pamàti)
;!!!! (kterò registr plat° ? - 10h nebo 0Ah)
TestPAR4:
         mov       ax,10h*HI + bit2         ; AH <- index, AL <- maska
         call      TestIPrt                 ; test registru
         jnc       TestPAR5
;!!!!!
         mov       ax,0Ah*HI + bit2         ; AH <- index, AL <- maska
         call      TestIPrt                 ; test registru
         mov       ax,CardPA10              ; identifik†tor WD90C10
         jc        TestPAR6                 ; je WD90C10
TestPAR5:mov       ax,CardPA11              ; jinak je WD90C11

; ------ n†vrat registru 6

TestPAR6:push      ax
         mov       dl,0c4h                  ; port 3C4h
         mov       ah,6                     ; index
         mov       al,cl                    ; AL <- pñvodn° obsah
         call      WritIPrt                 ; n†vrat registru
         pop       ax

; ------ detekce velikosti videopamàti (AX=identifik†tor) -> BX

TestPAR7:push      ax
         mov       dl,0ceh                  ; port 3CEh
         mov       ah,0bh                   ; index
         call      ReadIPrt                 ; áten° registru pamàti
         mov       cl,6
         shr       al,cl                    ; rotace na pozici
         mov       bx,256                   ; 256 KB pamàti
         cmp       al,2
         jb        TestPAR8                 ; je 256 KB videopamàti
         mov       bh,512/HI                ; 512 KB pamàti
         je        TestPAR8                 ; je 512 KB pamàti
         mov       bh,1024/HI               ; 1 MB pamàti
TestPAR8:pop       ax
         clc                                ; p©°znak operace OK

; ------ n†vrat registu z†mku 0fh

TestPAR9:pushf
         push      ax
         mov       dl,0ceh                  ; port 3CEh
         mov       ah,0fh
         mov       al,ch                    ; uschovanò stav
         call      WritIPrt                 ; n†vrat registru z†mku
         pop       ax
         popf
         ret

TestPAR  ENDP

; *****************************************************************************
;                                 TestCHIP
;                   test karty Chips & Technologies SuperVGA
; -----------------------------------------------------------------------------
; VùSTUP: CY=nen° karta Chips & Technologies SuperVGA
;         AX=identifik†tor karty
;         BX=velikost videopamàti (v KB)
; *****************************************************************************

TestChip PROC      NEAR

; ------ detekce karty Chips & Technologies SuperVGA

         mov       ax,5f00h
         xor       bx,bx
         call      Int10P                   ; detekce karty
         cmp       al,5fh                   ; je Chips & Technologies SuperVGA ?
         stc                                ; p©°znak neplatnÇ karty
         jne       TestChi9                 ; nen° Chips & Technologies SuperVGA

; ------ up©esnàn° verze áipu

         mov       cl,4
         shr       bl,cl
         mov       ax,CardCHIP              ; áip  82c451
         jz        TestChi4                 ; 0 = je áip 82c451
         cmp       bl,2
         je        TestChi4                 ; 2 = je áip 82c455 (jako 82c451)
         cmp       bl,4
         je        TestChi4                 ; 4 = je áip 82c456 (jako 82c451)

         mov       ax,CardCHI1              ; áip 82c452
         cmp       bl,1
         je        TestChi4                 ; 1 = je áip 82c452

         mov       ax,CardCHI2              ; jinak áip 82c453 a vy®®°

; ------ velikost videopamàti

TestChi4:mov       cl,bh                    ; CL <- velikost videopamàti
         mov       bx,256                   ; 256 KB videopamàti
         shl       bx,cl                    ; velikost videopamàti
         clc                                ; p©°znak operace OK
TestChi9:ret

TestChip ENDP

; *****************************************************************************
;                                 TestET30
;                       test karty ET3000/ET4000 SuperVGA
; -----------------------------------------------------------------------------
; VùSTUP: CY=nen° karta ET3000/ET4000 SuperVGA
;         AX=identifik†tor karty
;         BX=velikost videopamàti (v KB)
; *****************************************************************************

TestET30 PROC      NEAR

; ------ povolen° roz®°©enÇho m¢du ET4000

         mov       dx,3bfh
         mov       al,3
         out       dx,al

         mov       dl,0d8h                  ; port 3D8h
         mov       al,0a0h
         out       dx,al                    ; povolen° roz®°©enÇho m¢du ET4000

; ------ test registru p©ep°n†n° banky

         mov       dl,0cdh                  ; port 3CDh
         mov       al,3fh                   ; maska
         call      TestPort                 ; test portu volby banky
         jc        TestET39                 ; nen° karta ET3000/ET4000 SuperVGA

; ------ detekce karty ET4000 - test registru roz®°©enÇ poá†teán° adresy

         mov       dl,0d4h                  ; port 3D4h
         mov       ax,33h*HI + bit0+bit1+bit2+bit3 ; AH <- index, AL <- maska
         call      TestIPrt                 ; test registru roz®°©enÇ adresy
         jnc       TestET32                 ; je platnò - je karta ET4000

; ------ nastaven° videom¢du pro kartu ET3000

         mov       ax,2dh
         call      Int10P                   ; videom¢d 640x350/256

; ------ detekce velikosti pamàti pro ET3000

         mov       bx,512                   ; maxim†lnà 512 KB videopamàti
         mov       dx,offset BankET30       ; obsluha p©ep°n†n° banky
         call      TestMem                  ; detekce velikosti videopamàti
         mov       ax,CardET30              ; je karta ET3000 SuperVGA
         jmp       short TestET39           ; CY=chyba pamàti

; ------ detekce velikosti pamàti pro ET4000

TestET32:mov       ah,37h                   ; index (port = 3D4h)
         call      ReadIPrt                 ; áten° registru pamàti
         and       al,bit0+bit1+bit7        ; bity velikosti pamàti
         mov       bx,256                   ; 256 KB videopamàti
         cmp       al,bit1+bit7             ; je 256 KB pamàti ?
         jb        TestET34                 ; je 256 KB pamàti
         mov       bh,512/HI                ; 512 KB videopamàti
         je        TestET34                 ; je 512 KB pamàti
         mov       bh,1024/HI               ; jinak 1024 KB pamàti

; ------ detekce videokarty Diamond Speedstar 24

TestET34:push      bx
         mov       ax,10e0h
         mov       bx,2eh OR 80h
         call      Int10P                   ; nastaven° videom¢du
         pop       bx
         cmp       ax,10h                   ; videom¢d nastaven ?
         mov       ax,CardET41              ; identifik†tor karty Speedstar
         je        TestET36                 ; je Diamond Speedstar 24

; ------ detekce videokarty Genoa 7900

         push      bx
         mov       ax,10f0h
         mov       bx,3eh OR 80h
         call      Int10P                   ; nastaven° videom¢du
         pop       bx
         cmp       ax,10h                   ; videom¢d nastaven OK
         mov       ax,CardET42              ; identifik†tor karty Genoa
         je        TestET36                 ; je Genoa 7900

; ------ jinak je videokarta MegaEga

         mov       ax,CardET40              ; je MegaEga
TestET36:clc                                ; p©°znak
TestET39:ret

TestET30 ENDP

; *****************************************************************************
;                                 TestEVER
;                       test karty Everex SuperVGA
; -----------------------------------------------------------------------------
; VùSTUP: CY=nen° karta Everex SuperVGA
;         AX=identifik†tor karty
;         BX=velikost videopamàti (v KB)
; *****************************************************************************

TestEVER PROC      NEAR

; ------ poskytnut° informac° o kartà Everex SuperVGA

         mov       ax,7000h
         xor       bx,bx
         call      Int10P                   ; detekce parametrñ
         cmp       al,70h                   ; je karta Everex SuperVGA ?
         stc                                ; p©°znak, ëe nen° Everex SuperVGA
         jne       TestEVE9                 ; nen° karta Everex SuperVGA

; ------ rozli®en° typu áipu videokarty

         mov       cl,4                     ; poáet rotac°
         shr       dx,cl                    ; identifikaán° á°slo áipu

; ------ karta UltraGraphics - áip Trident 236

         mov       ax,CardEVE1
         cmp       dx,236h
         je        TestEVE2                 ; je áip Trident 236

; ------ karta Vision VGA - áip Trident 620

         mov       ax,CardEVE2
         cmp       dx,620h
         je        TestEVE2                 ; je áip Trident 620

; ------ karta ViewPoint TC - áip ET4000 629

         mov       ax,CardEVE3
         cmp       dx,629h
         je        TestEVE2                 ; je áip ET4000 629

; ------ karta EVGA - áip Trident 673

         mov       ax,CardEVE4
         cmp       dx,673h
         je        TestEVE2                 ; je áip Trident 673

; ------ karta VidewPoint TC - áip Trident 678

         mov       ax,CardEVE5
         cmp       dx,678h
         je        TestEVE2                 ; je áip Trident 678

; ------ jinak standardn° áip Everex SuperVGA

         mov       ax,CardEVER              ; bàënò áip Everex SuperVGA

; ------ detekce velikosti videopamàti

TestEVE2:mov       cl,6                     ; poáet rotac°
         shr       ch,cl                    ; velikost pamàti
         mov       cl,ch                    ; CL <- velikost videopamàti
         mov       bx,256                   ; velikost videopamàti 256 KB
         shl       bx,cl                    ; velikost videopamàti v KB
         clc                                ; p©°znak platnosti karty
TestEVE9:ret

TestEVER ENDP

; *****************************************************************************
;                                 TestAheA
;                       test karty Ahead A/B SuperVGA
; -----------------------------------------------------------------------------
; VùSTUP: CY=nen° karta Ahead A/B SuperVGA
;         AX=identifik†tor karty
;         BX=velikost videopamàti (v KB)
; *****************************************************************************

TestAheA PROC      NEAR

; ------ £schova registru povolen° roz®°©enÇho m¢du registrñ -> CH

         mov       dx,3ceh
         mov       ah,0fh                   ; index registru
         call      ReadIPrt                 ; áten° registru
         mov       ch,al                    ; CH <- £schova registru

; ------ z†kaz roz®°©enÇho m¢du registrñ

         mov       al,0                     ; zapisovan† hodnota
         call      WritIPrt                 ; povolen° roz®°©enÇho m¢du

; ------ test registru volby banky (nesm° bòt zapisovatelnò)

         mov       ax,0dh*HI + 0ffh         ; AH <- registr, AL <- maska
         call      TestIPrt                 ; test registru volby banky
         cmc
         jc        TestAhe2                 ; lze zapisovat - nen° Ahead A/B

; ------ povolen° roz®°©enÇho m¢du registrñ

         mov       ax,0fh*HI + bit5         ; AH <- registr, AL <- hodnota
         call      WritIPrt                 ; povolen° roz®°©enÇho m¢du

; ------ test, zda jië lze zapisovat do registru volby banky

         mov       ax,0dh*HI + 0ffh         ; AH <- registr, AL <- maska
         call      TestIPrt                 ; test registru volby banky

; ------ n†vrat registru povolen° roz®°©enÇho m¢du

TestAhe2:pushf
         mov       ah,0fh                   ; registr
         mov       al,ch                    ; pñvodn° hodnota
         call      WritIPrt                 ; n†vrat obsahu registru
         popf
         jc        TestAhe9                 ; nen° Ahead A/B SuperVGA

; ------ nastaven° videom¢du 640x480/256

         push      ax
         mov       ax,60h
         call      Int10P                   ; nastaven° videom¢du 640x480/256
         pop       ax

; ------ je karta Ahead A/B SuperVGA - up©esnàn° typu a detekce velikosti pamàti

         test      al,bit0+bit1+bit2+bit3   ; je karta Ahead A SuperVGA ?
         mov       ax,CardAHEA              ; karta Ahead A SuperVGA
         mov       bx,512                   ; maxim†lnà 512 KB pamàti
         mov       dx,offset BankAheA       ; p©ep°n†n° banky Ahead A SuperVGA
         jz        TestAhe4                 ; je Ahead A SuperVGA
         mov       ax,CardAHEB              ; jinak je Ahead B SuperVGA
         shl       bx,1                     ; maxim†lnà 1 MB pamàti
         mov       dx,offset BankAheB       ; p©ep°n†n° banky Ahead B SuperVGA
TestAhe4:call      TestMem                  ; test velikosti videopamàti
                                           ;* zde je CY=chyba pamàti
TestAhe9:ret

TestAheA ENDP

; *****************************************************************************
;                                 TestCirr
;                       test karty Cirrus 54xx SuperVGA
; -----------------------------------------------------------------------------
; VùSTUP: CY=nen° karta Cirrus 54xx SuperVGA
;         AX=identifik†tor karty
;         BX=velikost videopamàti (v KB)
; *****************************************************************************

TestCirr PROC      NEAR

; ------ £schova registru povolen° roz®°©enÇho m¢du registrñ -> CH

         mov       dx,3c4h
         mov       ah,6                     ; index registru
         call      ReadIPrt                 ; áten° registru
         mov       ch,al                    ; CH <- £schova registru

; ------ povolen° roz®°©enÇho m¢du registrñ

         mov       ax,6*HI + bit1+bit4      ; AH <- index, AL <- hodnota
         call      WritIPrt                 ; povolen° roz®°©enÇho m¢du

; ------ ovà©en° zapsanÇ hodnoty

         call      ReadIPrt                 ; zpàtnÇ naáten° zapsanÇ hodnoty
         cmp       al,bit1+bit4             ; je pñvodn° hodnota ?
         stc                                ; p©°znak chyby
         jne       TestCir9                 ; chyba - nen° Cirrus 54xx SuperVGA

; ------ test registru 1Eh

         mov       ax,1Eh*HI + 3Fh          ; AH <- registr, AL <- maska
         call      TestIPrt                 ; test registru
         jc        TestCir9                 ; nen° Cirrus 54xx SuperVGA

; ------ test registru 1Bh portu 3D4h

         mov       dl,0d4h                  ; port 3D4h
         mov       ax,1Bh*HI + 0ffh         ; AH <- registr, AL <- maska
         call      TestIPrt                 ; test registru
         jc        TestCir9                 ; nen° Cirrus 54xx SuperVGA

; ------ detekce velikosti videopamàti

         mov       dl,0c4h                  ; port 3C4h
         mov       ah,0fh                   ; registr
         call      ReadIPrt                 ; áten° registru
         shr       al,1
         shr       al,1
         shr       al,1                     ; rotace na pozici
         and       al,bit0+bit1             ; maskov†n° bitñ velikosti pamàti
         mov       cl,al                    ; CL <- velikost pamàti
         mov       bx,256                   ; velikost pamàti 256 KB
         shl       bx,cl                    ; vòpoáet velikosti videopamàti
         clc                                ; p©°znak operace OK

; ------ n†vrat registru povolen° roz®°©enÇho m¢du registrñ

TestCir9:pushf
         mov       dl,0c4h
         mov       ah,6
         mov       al,ch                    ; AL <- uschovan† hodnota
         call      WritIPrt                 ; n†vrat hodnoty registru
         popf
         mov       ax,CardCirr              ; identifik†tor karty
         ret

TestCirr ENDP

; *****************************************************************************
;                                 TestAcum
;                       test karty AcuMos SuperVGA
; -----------------------------------------------------------------------------
; VùSTUP: CY=nen° karta AcuMos SuperVGA
;         AX=identifik†tor karty
;         BX=velikost videopamàti (v KB)
; *****************************************************************************

TestAcum PROC      NEAR

; ------ £schova registru povolen° roz®°©enÇho m¢du registrñ -> CH

         mov       dx,3c4h
         mov       ah,6                     ; index registru
         call      ReadIPrt                 ; áten° registru
         mov       ch,al                    ; CH <- £schova registru

; ------ povolen° roz®°©enÇho m¢du registrñ

         mov       ax,6*HI + 10010b         ; AH <- index, AL <- hodnota
         call      WritIPrt                 ; povolen° roz®°©enÇho m¢du

; ------ test registru 9

         mov       dl,0ceh                  ; port 3CEh
         mov       ax,9*HI + 110000b        ; AH <- index, AL <- maska
         call      TestIPrt                 ; test portu
         jc        TestAcu9                 ; nen° to karta AcuMos SuperVGA

; ------ detekce velikosti videopamàti

         mov       ah,0ah
         mov       dl,0c4h                  ; port 3C4h
         call      ReadIPrt                 ; áten° registru pamàti
         and       al,bit0+bit1             ; platnÇ bity
         mov       cl,al                    ; CL <- platnÇ bity
         mov       bx,256                   ; velikost pamàti 256 KB
         shl       bx,cl                    ; velikost pamàti v KB
         clc

; ------ n†vrat registru povolen° roz®°©enÇho m¢du registrñ

TestAcu9:pushf
         mov       dl,0c4h
         mov       ah,6
         mov       al,ch                    ; AL <- uschovan† hodnota
         call      WritIPrt                 ; n†vrat hodnoty registru
         popf
         mov       ax,CardACUM              ; identifik†tor karty
         ret

TestAcum ENDP

; *****************************************************************************
;                                 TestOAK
;                       test karty OAK Technologies SVGA
; -----------------------------------------------------------------------------
; VùSTUP: CY=nen° karta OAK Technologies SVGA
;         AX=identifik†tor karty
;         BX=velikost videopamàti (v KB)
; *****************************************************************************

TestOAK  PROC      NEAR

         mov       bx,256                   ; velikost videopamàti 256 KB

; ------ test registru velikosti videopamàti

         mov       dx,3deh
         mov       ax,0dh*HI + 111000b      ; AH <- index, AL <- maska
         call      TestIPrt                 ; test portu
         jc        TestOAK9                 ; nen° karta OAK Technologies SVGA

; ------ test áipu OTI-037C (registr p©ep°n†n° bank je R/O)

         mov       ch,0
         mov       ax,11h*HI + 0ffh         ; AH <- index, AL <- maska
         call      TestIPrt                 ; test portu
         jnc       TestOAK3                 ; lze zapisovat - nen° OTI-037C

; ------ detekce velikosti videopamàti pro áip OTI-037C

         mov       ah,0dh
         call      ReadIPrt                 ; áten° registru velikosti pamàti
         test      al,bit6+bit7             ; je velikost pamàti 256 KB ?
         mov       ax,CardOAK               ; identifik†tor áipu OTI-037C
         jz        TestOAK8                 ; je 256 KB pamàti
         shl       bx,1                     ; jinak 512 KB pamàti
         jmp       short TestOAK8

; ------ detekce velikosti videopamàti pro áipy OTI-077 a OTI-067

TestOAK3:mov       ah,0dh
         call      ReadIPrt                 ; áten° registru velikosti pamàti
         mov       cl,6
         shr       al,cl                    ; rotace bitñ na pozici
         jz        TestOAK4                 ; je 256 KB
         shl       bx,1                     ; 512 KB
         cmp       al,2                     ; je 512 KB ?
         jbe       TestOAK4                 ; je 512 KB
         shl       bx,1                     ; jinak je 1 MB

; ------ áten° registru á°sla verze áipu OAK

TestOAK4:mov       ah,0bh                   ; index
         call      ReadIPrt                 ; áten° registru verze
         mov       cl,5                     ; poáet rotac°
         shr       al,cl                    ; rotace na pozici

; ------ rozli®en° typu áipu OAK

         cmp       al,5                     ; je OTI-077 ?
         mov       ax,CardOAK1              ; typ OTI-067
         jne       TestOAK8                 ; je typ OTI-067
         mov       ax,CardOAK2              ; typ OTI-077
TestOAK8:clc                                ; p©°znak karty OAK
TestOAK9:ret

TestOAK  ENDP

; *****************************************************************************
;                                 TestADVL
;                       test karty Advance Logic 2101 SVGA
; -----------------------------------------------------------------------------
; VùSTUP: CY=nen° karta Advance Logic 2101 SVGA
;         AX=identifik†tor karty
;         BX=velikost videopamàti (v KB)
; *****************************************************************************

TestADVL PROC      NEAR

; ------ test registru poá†teán°ho bodu LOW

         mov       dx,8286h                 ; port
         mov       al,0ffh                  ; maska
         call      TestPort                 ; test registr poá†teán°ho bodu LOW
         jc        TestADV9                 ; nen° Advance Logic 2101 SVGA

; ------ test emulaán°ho registru

         mov       dx,3D4h                  ; port
         mov       ax,1fh*HI + 111011b      ; AH <- registr, AL <- maska
         call      TestIPrt                 ; test registru
         jc        TestAdv9                 ; nen° Advance Logic 2101 SVGA

; ------ test registru barevnÇ vòplnà

         mov       ax,0dh*HI + 1111b        ; AH <- registr, AL <- maska
         call      TestIPrt                 ; test registru
         jc        TestAdv9                 ; nen° Advance Logic 2101 SVGA

; ------ áten° registru velikosti pamàti

         mov       ah,1eh                   ; registr velikosti pamàti
         call      ReadIPrt                 ; áten° registru velikosti pamàti
         and       al,3                     ; velikost pamàti

; ------ velikost pamàti

         xchg      ax,cx                    ; CL <- velikost pamàti 0,1,2,3
         mov       bx,256                   ; 256 KB videopamàti
         shl       bx,cl                    ; vòpoáet velikosti videopamàti

; ------ je karta Advance Logic 2101 SVGA

         mov       ax,CardADVL              ; identifik†tor karty
         clc                                ; p©°znak operace OK
TestADV9:ret

TestADVL ENDP

; *****************************************************************************
;                                 TestMXIC
;                        test karty MXIC 68010 SVGA
; -----------------------------------------------------------------------------
; VùSTUP: CY=nen° karta MXIC 68010 SVGA
;         AX=identifik†tor karty
;         BX=velikost videopamàti (v KB)
; *****************************************************************************

TestMXIC PROC      NEAR

; ------ £schova registru povolen° roz®°©enÇho m¢du registrñ -> CL

         mov       dx,3c4h
         mov       ah,0a7h                  ; index registru
         call      ReadIPrt                 ; áten° registru
         mov       cl,al                    ; CL <- £schova registru

; ------ z†kaz roz®°©enÇho m¢du registrñ

         mov       al,0                     ; m¢d zak†z†n
         call      WritIPrt                 ; z†kaz roz®°©enÇho m¢du

; ------ test registru p©ep°n†n° bank (p©i z†kazu nesm° bòt funkán°)

         mov       ax,0c5h*HI + 0ffh        ; AH <- index, AL <- maska
         call      TestIPrt                 ; test registru
         cmc                                ; registr nesm° bòt funkán°
         jc        TestMXI3                 ; nen° MXIC 68010 SVGA

; ------ povolen° roz®°©enÇho m¢du registrñ

         mov       ax,0a7h*HI + 87h         ; m¢d povolen
         call      WritIPrt                 ; povolen° roz®°©enÇho m¢du

; ------ test registru p©ep°n†n° bank (teÉ uë mus° bòt funkán°)

         mov       ax,0c5h*HI + 0ffh        ; AH <- index, AL <- maska
         call      TestIPrt                 ; test registru

; ------ n†vrat pñvodn°ho obsahu registru roz®°©enÇho m¢du

TestMXI3:pushf
         xchg      ax,cx                    ; AL <- pñvodn° hodnota registru
         mov       ah,0a7h                  ; index registru
         call      WritIPrt                 ; n†vrat hodnoty registru
         popf
         jc        TestMXI9                 ; nen° MXIC 68010 SVGA

; ------ áten° registru velikosti pamàti

         mov       ah,0c2h                  ; registr velikosti pamàti
         call      ReadIPrt                 ; áten° registru velikosti pamàti
         shr       al,1
         shr       al,1                     ; rotace bitñ na pozici
         and       al,3                     ; velikost pamàti

; ------ velikost pamàti

         xchg      ax,cx                    ; CL <- velikost pamàti 0,1,2,3
         mov       bx,256                   ; 256 KB videopamàti
         shl       bx,cl                    ; vòpoáet velikosti videopamàti

; ------ karta detekov†na OK

         mov       ax,CardMXIC              ; identifik†tor karty
         clc                                ; p©°znak platnosti karty
TestMXI9:ret

TestMXIC ENDP

; *****************************************************************************
;                                 TestPrim
;                        test karty Primus 2000 SVGA
; -----------------------------------------------------------------------------
; VùSTUP: CY=nen° karta RealTek 3106 SVGA
;         AX=identifik†tor karty
;         BX=velikost videopamàti (v KB)
; *****************************************************************************

TestPrim PROC      NEAR

; ------ test stavovÇho povelovÇho registru

         mov       dx,3ceh
         mov       ax,3Dh*HI + 3Fh          ; AH <- stavovò registr, AL <- maska
         call      TestIPrt                 ; test registru
         jc        TestPrm9                 ; nen° Primus 2000

; ------ test registru zmàny banky 1

         mov       dl,0d6h                  ; adresa registru (3D6h)
         mov       al,bit0+bit1+bit2+bit3+bit4 ; maska
         call      TestPort                 ; test registru
         jc        TestPrm9                 ; nen° RealTek 3106

; ------ test registru zmàny banky 2

         inc       dx                       ; adresa registru (3D7h)
         call      TestPort                 ; test registru (maska = 0fh)
         jc        TestPrm9                 ; nen° RealTek 3106

; ------ nastaven° videom¢du 640x480/256

         mov       ax,2ch
         call      Int10P                   ; nastaven° videom¢du 640x480/256

; ------ test velikosti pamàti

         mov       bx,2048                  ; maxim†lnà 2 MB pamàti
         mov       dx,offset BankPrim       ; p©ep°n†n° banky Primus 2000
         call      TestMem                  ; test velikosti videopamàti
         jc        TestPrm9                 ; chyba pamàti

; ------ karta detekov†na OK

TestPrm8:mov       ax,CardPRIM              ; je karta Primus 2000 SVGA
         clc
TestPrm9:ret

TestPrim ENDP

; *****************************************************************************
;                                 TestRT3
;                        test karty RealTek 3106 SVGA
; -----------------------------------------------------------------------------
; VùSTUP: CY=nen° karta RealTek 3106 SVGA
;         AX=identifik†tor karty
;         BX=velikost videopamàti (v KB)
; *****************************************************************************

TestRT3  PROC      NEAR

; ------ test emulaán°ho registru

         mov       dx,3D4h                  ; b†zov† adresa portñ
         mov       ax,1fh*HI + bit0+bit1    ; registr 1fh, maska bit0+bit1
         call      TestIPrt                 ; test registru emulace
         jc        TestRT39                 ; nen° RealTek 3106

; ------ test registru zmàny banky 1

         mov       dl,0d6h                  ; adresa registru (3D6h)
         mov       al,bit0+bit1+bit2+bit3   ; maska
         call      TestPort                 ; test registru
         jc        TestRT39                 ; nen° RealTek 3106

; ------ test registru zmàny banky 2

         inc       dx                       ; adresa registru (3D7h)
         call      TestPort                 ; test registru (maska = 0fh)
         jc        TestRT39                 ; nen° RealTek 3106

; ------ naáten° identifikaán°ho á°sla áipu

         mov       dl,0d4h                  ; b†zov† adresa portñ 3d4h
         mov       ah,1ah                   ; registr
         call      ReadIPrt                 ; áten° á°sla áipu - vy®®° 2 bity
         mov       cl,6                     ; poáet rotac°
         shr       al,cl                    ; rotace bitñ na pozici 0 a 1
         mov       ah,0
         xchg      ax,cx                    ; CL <- £schova á°sla áipu HIGH

; ------ naáten° velikosti pamàti

         mov       ah,1eh
         call      ReadIPrt                 ; áten° velikosti pamàti
         and       al,bit0+bit1+bit2+bit3   ; velikost pamàti

; ------ je 256 KB pamàti

         mov       bx,256                   ; 256 KB videopamàti
         jz        TestRT38                 ; je 256 KB pamàti

; ------ 512 KB pamàti

         shl       bx,1                     ; 512 KB videopamàti
         cmp       al,1
         je        TestRT38                 ; 1 = je 512 KB pamàti

; ------ test, zda je verze videokarty 0

         jcxz      TestRT36                 ; je verze karty 0
         shl       bx,1                     ; 1 MB pamàti

; ------ 1 MB pamàti pro verzi 0, 2 MB pamàti pro vy®®° verzi

TestRT36:cmp       al,3                     ; je 1 MB (2 MB) pamàti ?
         jb        TestRT38                 ; je 512 KB (1 MB) pamàti
         shl       bx,1                     ; pamàü * 2

TestRT38:mov       ax,CardReal              ; identifik†tor karty
         clc                                ; p©°znak karty RealTek 3106 SVGA
TestRT39:ret

TestRT3  ENDP

;; *****************************************************************************
;;                               Test6845
;;                            test áipu 6845
;;     Test spoá°v† v z†pisu a áten° registru 0Fh áipu (pozice kurzoru LOW).
;;                  Naáten† hodnota mus° bòt stejn† jako zapsan†.
;; -----------------------------------------------------------------------------
;; VSTUP: DX=b†zov† adresa ©adiáe CRTC
;; VùSTUP: CY=nen° áip 6845
;;         zakazuje p©eru®en° !
;; *****************************************************************************
;
;Test6845 PROC      NEAR
;
;         push      ax
;         mov       ax,0fh*HI + 0ffh         ; AL <- maska, AH <- registr
;         call      TestIPrt                 ; test portu
;         pop       ax
;         ret
;
;Test6845 ENDP
;
; *****************************************************************************
;                                  TestMem
;     test velikosti videopamàti pro aktu†lnà nastavenò videom¢d 256 barev
; -----------------------------------------------------------------------------
; VSTUP: BX=maxim†ln° velikost videopamàti v KB (64, 128, 256, 512, 1024,...)
;        DX=adresa obsluhy volby banky (á°slo banky v registru AL)
; VùSTUP: BX=skuteán† hodnota velikosti videopamàti v KB (p©i chybà je BX=0)
;         CY=nen° videopamàü (chybnò videom¢d, velikost = 0 KB)
; *****************************************************************************

TestMem  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,dx                    ; BP <- adresa obsluhy volby banky

; ------ p©°prava adresy ve videopamàti -> ES:DI

         mov       ax,0a000h
         mov       es,ax                    ; ES <- segment videopamàti
         xor       di,di                    ; DI <- 0 offset ve videopamàti

; ------ nastaven° posledn° banky 64 KB

TestMem2:mov       ax,bx                    ; aktu†ln° velikost videopamàti
         mov       cl,6                     ; poáet rotac°
         shr       ax,cl                    ; p©epoáet na poáet bank 64 KB
         dec       ax                       ; á°slo posledn° banky
         call      bp                       ; volba poëadovanÇ banky
         xchg      ax,cx                    ; CX <- £schova á°sla banky

; ------ zmàna obsahu videopamàti

         mov       ax,es:[di]               ; aktu†ln° obsah videopamàti
         mov       dx,ax                    ; DX <- £schova obsahu videpamàti
         xor       ax,5aa5h                 ; zmàna vzorku
         mov       es:[di],ax               ; uloëen° zmànànÇho vzorku
         jmp       short $+2
         jmp       short $+2                ; mal† prodleva

; ------ test vzorku videopamàti

         mov       ax,es:[di]               ; novò obsah videopamàti
         mov       es:[di],dx               ; n†vrat obsahu videopamàti
         xor       ax,5aa5h                 ; n†vrat pñvodn° hodnoty
         cmp       ax,dx                    ; je obsah videopamàti platnò ?
         jne       TestMem7                 ; nen° platnò - sn°ëen° velikosti

; ------ nastaven° posledn° banky 64 KB v polovinà detekovanÇ pamàti

         mov       ax,cx                    ; AX <- á°slo posledn° banky
         inc       ax                       ; poáet bank 64 KB
         shr       ax,1                     ; polovina videopamàti
         clc                                ; p©°znak operace OK
         jz        TestMem8                 ; je to jië posledn° banka 64 KB
         dec       ax                       ; banka v polovinà pamàti
         call      bp                       ; volba poëadovanÇ banky
         xchg      ax,si                    ; SI <- £schova banky poloviny

; ------ z†pis negovanÇho vzorku do poloviny pamàti

         mov       ax,es:[di]               ; £schova pñvodn°ho obsahu
         push      dx
         xor       dx,0a56dh                ; asi takovò vzorek
         mov       es:[di],dx               ; z†pis negovanÇho vzorku
         pop       dx

; ------ nastaven° posledn° banky

         xchg      ax,cx                    ; AX <- posledn° banka, CX <- hodnota
         call      bp                       ; volba posledn° banky

; ------ test, zda byl zmànàn obsah posledn° banky

         mov       ax,es:[di]               ; aktu†ln° hodnota
         cmp       ax,dx                    ; byla hodnota zmànàna ?

; ------ n†vrat pñvodn°ho obsahu v polovinà

         pushf
         xchg      ax,si                    ; á°slo banky v polovinà
         call      bp                       ; volba banky v polovinà
         mov       es:[di],cx               ; n†vrat pñvodn°ho obsahu
         popf
         je        TestMem8                 ; hodnota se nezmànila - to je OK

; ------ chyba - sn°ëen° velikosti videopamàti

TestMem7:shr       bx,1                     ; sn°ëen° velikosti videopamàti
         cmp       bx,64                    ; je je®tà velikost OK ?
         jae       TestMem2                 ; velikost je je®tà OK
         xor       bx,bx                    ; chyba - nen° videopamàü
         stc                                ; p©°znak chyby

; ------ n†vrat registrñ

TestMem8:pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

TestMem  ENDP

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                          P©ep°n†n° bank
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
; *****************************************************************************
;                               BankATI
;                 volba banky karty ATI Technologies SVGA
; -----------------------------------------------------------------------------
; VSTUP: AL=á°slo banky 64 KB
; *****************************************************************************

BankATI  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      dx
         xchg      ax,bx                    ; BL <- £schova á°sla banky

; ------ nastaven° poëadovanÇ banky

         mov       dx,cs:[PortATI]          ; adresa portu ATI
         mov       ah,0b2h
         call      ReadIPrt                 ; áten° registru 0B2h
         shl       bl,1                     ; rotace banky na pozici bitu 1
         and       al,not bit1+bit2+bit3+bit4
         or        al,bl
         call      WritIPrt                 ; z†pis registru 0B2h

; ------ n†vrat registrñ

         pop       dx
         pop       bx
         pop       ax
         ret

BankATI  ENDP

; *****************************************************************************
;                                BankNCR
;                       volba banky karty NCR 77C22E
; -----------------------------------------------------------------------------
; VSTUP: AL=á°slo banky 64 KB
; *****************************************************************************

BankNCR  PROC      NEAR

; ------ £schova registrñ

         pushf
         push      ax
         push      dx
         cli

; ------ zmàna banky 64 KB na 16 KB

         shl       al,1
         shl       al,1                     ; zmàna na á°slov†n° po 16 KB
         mov       ah,al                    ; AH <- £schova á°sla banky

; ------ nastaven° á°sla banky pro z†pis

         mov       dx,3c4h
         mov       al,18h
         out       dx,al                    ; index registru z†pisovÇ banky
         inc       dx
         mov       al,ah                    ; AL <- á°slo banky
         out       dx,al                    ; nastaven° banky pro z†pis

; ------ nastaven° á°sla banky pro áten°

         dec       dx                       ; port 3C4h
         mov       al,1ch
         out       dx,al                    ; index registru átec° banky
         inc       dx
         mov       al,ah                    ; AL <- á°slo banky
         out       dx,al                    ; nastaven° banky pro áten°

; ------ n†vrat registrñ

         pop       dx
         pop       ax
         popf
         ret

BankNCR  ENDP

; *****************************************************************************
;                              BankET30
;                      volba banky karty ET3000
; -----------------------------------------------------------------------------
; VSTUP: AL=á°slo banky
; *****************************************************************************

BankET30 PROC      NEAR

; ------ £schova registrñ

         pushf
         push      ax
         push      dx
         cli

; ------ p©°prava dat pro volbu banky

         mov       ah,al                    ; poëadovan† banka
         shl       al,1
         shl       al,1
         shl       al,1
         or        al,ah
         or        al,bit6                  ; volba segmentñ 64 KB
         mov       dx,3cdh
         out       dx,al                    ; volba poëadovanÇ banky

; ------ n†vrat registrñ

         pop       dx
         pop       ax
         popf
         ret

BankET30 ENDP

; *****************************************************************************
;                               BankAheA
;                     volba banky karty Ahead A
; -----------------------------------------------------------------------------
; VSTUP: AL=á°slo banky
; *****************************************************************************

BankAheA PROC      NEAR

; ------ £schova registrñ

         pushf
         push      ax
         push      dx
         mov       ah,al                    ; £schova á°sla banky
         cli

; ------ áten° registru "Misc Output"

         mov       dx,3cch
         in        al,dx                    ; áten° registru "Misc Output"

; ------ nastaven° bitu 0 á°sla banky

         mov       dl,0c2h                  ; port 3C2h
         and       al,not bit5              ; nulov†n° bitu 0 á°sla banky
         shr       ah,1                     ; m† bòt bit nastaven ?
         jnc       BankAhA2                 ; bit nem† bòt nastaven
         or        al,bit5                  ; nastaven° bitu 0 á°sla banky
BankAhA2:out       dx,al                    ; nastaven° novÇ hodnoty bitu 0

; ------ nastaven° bitñ 1 aë 3 á°sla banky

         mov       dl,0ceh                  ; port 3CEh
         mov       al,0dh
         out       dx,al                    ; volba registru á°sla banky
         inc       dx
         mov       al,ah                    ; á°slo banky - bity 1 aë 3
         out       dx,al                    ; nastaven° bitñ 1 aë 3 á°sla banky

; ------ n†vrat registrñ

         pop       dx
         pop       ax
         popf
         ret

BankAheA ENDP

; *****************************************************************************
;                               BankAheB
;                     volba banky karty Ahead B
; -----------------------------------------------------------------------------
; VSTUP: AL=á°slo banky
; *****************************************************************************

BankAheB PROC      NEAR

; ------ £schova registrñ

         pushf
         push      ax
         push      dx
         cli

; ------ p©°prava dat pro volbu banky

         mov       ah,al                    ; poëadovan† banka
         shl       al,1
         shl       al,1
         shl       al,1
         shl       al,1
         or        ah,al

; ------ volba registru volby banky

         mov       al,0dh                   ; index registru volby banky
         mov       dx,3ceh
         out       dx,al                    ; volba registru p©ep°naáe banky

; ------ nastaven° poëadovanÇ banky

         inc       dx                       ; data 3CFh
         mov       al,ah                    ; poëadovan† banka
         out       dx,al                    ; volba poëadovanÇ banky

; ------ n†vrat registrñ

         pop       dx
         pop       ax
         popf
         ret

BankAheB ENDP

; *****************************************************************************
;                              BankPrim
;                    volba banky karty Primus 2000
; -----------------------------------------------------------------------------
; VSTUP: AL=á°slo banky
; *****************************************************************************

BankPrim PROC      NEAR

         push      dx

         mov       dx,3d6h
         out       dx,al                    ; volba banky pro áten°
         inc       dx
         out       dx,al                    ; volba banky pro z†pis

         pop       dx
         ret

BankPrim ENDP

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                       Univerz†ln° obsluhy portñ
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
; *****************************************************************************
;                              TestIPrt
;            test bitñ indexovanÇho portu áten°m a z†pisem
; -----------------------------------------------------------------------------
; VSTUP: DX=b†zov† adresa portu (tj. adresa indexñ)
;        AL=maska (testovanÇ bity = 1)
;        AH=index (á°slo registru)
; VùSTUP: CY=neodpov°d†
;        zakazuje p©eru®en° !
; *****************************************************************************

TestIPrt PROC      NEAR

; ------ £schova registrñ

         push      bx
         cli

; ------ £schova nastavenÇho indexu

         xchg      ax,bx                    ; BX <- mezi£schova registrñ
         in        al,dx                    ; naáten° aktu†ln°ho á°sla registru
         xchg      ax,bx                    ; BL <- £schova á°sla registru

; ------ nastaven° poëadovanÇho indexu

         xchg      al,ah                    ; AL <- á°slo indexu
         out       dx,al                    ; nastaven° poëadovanÇho registru
         xchg      al,ah

; ------ test portu

         inc       dx                       ; data registru
         call      TestPort                 ; test portu
         dec       dx                       ; n†vrat adresy indexu

; ------ n†vrat pñvodn°ho indexu

         xchg      ax,bx                    ; AL <- pñvodnà nastavenò index
         out       dx,al                    ; n†vrat pñvodn°ho indexu
         xchg      ax,bx

; ------ n†vrat registrñ

         pop       bx
         ret

TestIPrt ENDP

; *****************************************************************************
;                               TestPort
;          test bitñ portu áten°m a z†pisem (áten° mus° odpov°dat z†pisu)
; -----------------------------------------------------------------------------
; VSTUP: DX=adresa portu
;        AL=maska (testovanÇ bity = 1)
; VùSTUP: CY=neodpov°d†
;         zakazuje p©eru®en° !
; *****************************************************************************

TestPort PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         cli

; ------ p©°prava masky -> BX

         mov       bl,al                    ; BL <- maska bitñ k testov†n°
         not       al                       ; negace masky
         mov       bh,al                    ; BH <- negovan† maska bitñ k testu

; ------ £schova pñvodn°ho obsahu portu -> AH

         in        al,dx                    ; naáten° pñvodn°ho obsahu portu
         mov       ah,al                    ; AH <- £schova pñvodn°ho obsahu portu

; ------ z†pis vzorku 1 - testovanÇ bity jsou vynulov†ny

         and       al,bh                    ; vynulov†n° testovanòch bitñ
         out       dx,al                    ; z†pis vzorku 1 - vynulovanÇ bity

; ------ mal† prodleva

         jmp       short $+2
         jmp       short $+2
         jmp       short $+2

; ------ test vzorku 1 - testovanÇ bity mus° bòt vynulovanÇ

         in        al,dx                    ; naáten° novÇho stavu portu
         and       al,bl                    ; maskov†n° testovanòch bitñ
         jnz       TestPrt8                 ; chyba - bity nejsou platnÇ

; ------ z†pis vzorku 2 - testovanÇ bity jsou nastaveny

         mov       al,ah                    ; AL <- pñvodn° obsah portu
         or        al,bl                    ; nastaven° testovanòch bitñ
         out       dx,al                    ; z†pis vzorku 2 - nastavenÇ bity

; ------ mal† prodleva

         jmp       short $+2
         jmp       short $+2
         jmp       short $+2

; ------ test vzorku 2 - testovanÇ bity mus° bòt nastavenÇ

         in        al,dx                    ; nastaven° novÇho stavu portu
         and       al,bl                    ; maskov†n° testovanòch bitñ
         cmp       al,bl                    ; jsou bity nastavenÇ ?
         je        TestPrt9                 ; bity jsou platnÇ OK
TestPrt8:stc                                ; p©°znak chyby - port neplatnò

; ------ n†vrat pñvodn°ho obsahu portu

TestPrt9:mov       al,ah                    ; AL <- pñvodn° obsah portu
         out       dx,al                    ; n†vrat pñvodn°ho obsahu portu

; ------ n†vrat registrñ

         pop       bx
         pop       ax
         ret

TestPort ENDP

; *****************************************************************************
;                                ReadIPrt
;                       áten° indexovanÇho portu
; -----------------------------------------------------------------------------
; VSTUP: DX=b†zov† adresa portu (tj. adresa indexñ)
;        AH=index (á°slo registru)
; VùSTUP: AL=naátenò bajt
; *****************************************************************************

ReadIPrt PROC      NEAR

; ------ £schova registrñ

         pushf
         push      bx
         cli

; ------ £schova pñvodn°ho nastaven° registru -> BL

         in        al,dx                    ; naáten° registru
         mov       bl,al                    ; BL <- £schova á°sla registru

; ------ nastaven° poëadovanÇho á°sla registru

         mov       al,ah                    ; AL <- á°slo registru
         out       dx,al                    ; nastaven° poëadovanÇho registru

; ------ naáten° hodnoty z registru -> AL

         inc       dx                       ; datovò port
         in        al,dx                    ; naáten° dat z registru
         dec       dx                       ; n†vrat adresy portu

; ------ n†vrat pñvodnà nastavenÇho registru

         xchg      al,bl                    ; AL <- pñvodn° hodnota, BL <- data
         out       dx,al                    ; n†vrat á°sla registru
         mov       al,bl                    ; AL <- naáten† data

; ------ n†vrat registrñ

         pop       bx
         popf
         ret

ReadIPrt ENDP

; *****************************************************************************
;                                 WritIPrt
;                       z†pis do indexovanÇho portu
; -----------------------------------------------------------------------------
; VSTUP: DX=b†zov† adresa portu (tj. adresa indexñ)
;        AH=index (á°slo registru)
;        AL=hodnota k z†pisu
; *****************************************************************************

WritIPrt PROC      NEAR

; ------ £schova registrñ

         pushf
         push      bx
         cli

; ------ £schova pñvodn°ho nastaven° registru -> BL

         xchg      ax,bx                    ; BX <- £schova AX
         in        al,dx                    ; naáten° registru
         xchg      ax,bx                    ; BL <- £schova registru, n†vrat AX

; ------ nastaven° poëadovanÇho á°sla registru

         xchg      al,ah                    ; AL <- á°slo registru
         out       dx,al                    ; nastaven° poëadovanÇho registru
         xchg      al,ah

; ------ z†pis hodnoty do registru

         inc       dx                       ; datovò port
         out       dx,al                    ; z†pis dat do registru
         dec       dx                       ; n†vrat adresy portu

; ------ n†vrat pñvodnà nastavenÇho registru

         xchg      ax,bx                    ; AL <- pñvodn° hodnota, BL <- data
         out       dx,al                    ; n†vrat á°sla registru
         xchg      ax,bx                    ; n†vrat AX

; ------ n†vrat registrñ

         pop       bx
         popf
         ret

WritIPrt ENDP

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                      Tabulka definic videokaret
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
TDefCard label     byte

         dw        _NUL
         db        3,'???'
         db        0
         dw        0
         dw        InitNul
_NUL:

         dw        _CGA
         db        3,'CGA'
         db        0
         dw        0
         dw        InitNul
_CGA:

         dw        _MCGA
         db        4,'MCGA'
         db        0
         dw        0
         dw        InitNul
_MCGA:

         dw        _EGA
         db        3,'EGA'
         db        0
         dw        0
         dw        InitNul
_EGA:

         dw        _EGA64
         db        9,'EGA 64 KB'
         db        0
         dw        0
         dw        InitNul
_EGA64:

         dw        _EGAM
         db        8,'EGA Mono'
         db        0
         dw        0
         dw        InitNul
_EGAM:

         dw        _EGA6M
         db        14,'EGA 64 KB Mono'
         db        0
         dw        0
         dw        InitNul
_EGA6M:

         dw        _Herc
         db        8,'Hercules'
         db        0
         dw        0
         dw        InitNul
_Herc:

         dw        _VGA
         db        3,'VGA'
         db        0
         dw        0
         dw        InitNul
_VGA:

         dw        _VESA
         db        13,'VESA SuperVGA'
         db        0
         dw        TestVESA
         dw        InitNul
_VESA:

         dw        _ACUM
         db        15,'Acumos SuperVGA'
         db        6,'ACUMOS'
         dw        TestAcum
         dw        InitNul
_ACUM:

         dw        _ADVL
         db        29,'Advance Logic AL2101 SuperVGA'
         db        13,'ADVANCE LOGIC'
         dw        TestADVL
         dw        InitNul
_ADVL:

         dw        _AHEA
         db        16,'AHEAD A SuperVGA'
         db        5,'AHEAD'
         dw        TestAheA
         dw        InitNul
_AHEA:

         dw        _AHEB
         db        16,'AHEAD B SuperVGA'
         db        5,'AHEAD'
         dw        TestAheA
         dw        InitNul
_AHEB:

         dw        _ATI
         db        42,'VGA Wonder ATI Technologies SuperVGA 18800'
         db        9,'ATI TECHN'
         dw        TestATI
         dw        InitATI
_ATI:

         dw        _ATI1
         db        44,'VGA Wonder ATI Technologies SuperVGA 18800-1'
         db        10,'VGA WONDER'
         dw        TestATI
         dw        InitATI
_ATI1:

         dw        _ATI2
         db        45,'VGA Wonder+ ATI Technologies SuperVGA 28800-2'
         db        11,'VGA WONDER+'
         dw        TestATI
         dw        InitATI
_ATI2:

         dw        _ATI4
         db        47,'VGA Wonder XL ATI Technologies SuperVGA 28800-4'
         db        13,'VGA WONDER XL'
         dw        TestATI
         dw        InitATI
_ATI4:

         dw        _ATI5
         db        52,'VGA Graphics/Ultra ATI Technologies SuperVGA 28800-5'
         db        12,'VGA GRAPHICS'
         dw        TestATI
         dw        InitATI
_ATI5:

         dw        _ATI6
         db        61,'Mach 8. 8514/Graphics/Ultra ATI Technologies SuperVGA 38800-1'
         db        6,'MACH 8'
         dw        TestATI
         dw        InitATI
_ATI6:

         dw        _ATI7
         db        61,'Mach 32. Graphics Ultra Pro/+ ATI Technologies SuperVGA 68800'
         db        7,'MACH 32'
         dw        TestATI
         dw        InitATI
_ATI7:

         dw        _CHIP
         db        46,'Chips & Technologies SVGA 82c451,82c455,82c456'
         db        5,'CHIPS'
         dw        TestCHIP
         dw        InitNul
_CHIP:

         dw        _CHI1
         db        32,'Chips & Technologies SVGA 82c452'
         db        5,'CHIPS'
         dw        TestCHIP
         dw        InitNul
_CHI1:

         dw        _CHI2
         db        32,'Chips & Technologies SVGA 82c453'
         db        5,'CHIPS'
         dw        TestCHIP
         dw        InitNul
_CHI2:

         dw        _Cirr
         db        20,'Cirrus 5422 SuperVGA'
         db        6,'CIRRUS'
         dw        TestCirr
         dw        InitNul
_Cirr:

         dw        _EVER
         db        15,'Everex SuperVGA'
         db        6,'EVEREX'
         dw        TestEVER
         dw        InitNul
_EVER:

         dw        _EVE1
         db        35,'UltraGraphics Ev236 Everex SuperVGA'
         db        9,'ULTRAGRAP'
         dw        TestEVER
         dw        InitNul
_EVE1:

         dw        _EVE2
         db        32,'Vision VGA Ev620 Everex SuperVGA'
         db        6,'VISION'
         dw        TestEVER
         dw        InitNul
_EVE2:

         dw        _EVE3
         db        34,'ViewPoint TC Ev629 Everex SuperVGA'
         db        9,'VIEWPOINT'
         dw        TestEVER
         dw        InitNul
_EVE3:

         dw        _EVE4
         db        26,'EVGA Ev673 Everex SuperVGA'
         db        4,'EVGA'
         dw        TestEVER
         dw        InitNul
_EVE4:

         dw        _EVE5
         db        34,'ViewPoint TC Ev678 Everex SuperVGA'
         db        9,'VIEWPOINT'
         dw        TestEVER
         dw        InitNul
_EVE5:

         dw        _GEN1
         db        32,'Genoa Systems SuperVGA GVGA 6100'
         db        5,'GENOA'
         dw        TestGENO
         dw        InitNul
_GEN1:

         dw        _GEN2
         db        34,'Genoa Systems SuperVGA GVGA 62/300'
         db        5,'GENOA'
         dw        TestGENO
         dw        InitNul
_GEN2:

         dw        _GEN4
         db        34,'Genoa Systems SuperVGA GVGA 64/600'
         db        5,'GENOA'
         dw        TestGENO
         dw        InitNul
_GEN4:

         dw        _MXIC
         db        19,'MXIC 68010 SuperVGA'
         db        4,'MXIC'
         dw        TestMXIC
         dw        InitNul
_MXIC:

         dw        _NCR0
         db        21,'NCR 77C20/21 SuperVGA'
         db        5,'NCR 7'
         dw        TestNCR
         dw        InitNul
_NCR0:

         dw        _NCR2
         db        19,'NCR 77C22E SuperVGA'
         db        5,'NCR 7'
         dw        TestNCR
         dw        InitNul
_NCR2:

         dw        _OAK
         db        34,'OAK Technologies SuperVGA OTI-037C'
         db        9,'OAK TECHN'
         dw        TestOAK
         dw        InitNul
_OAK:

         dw        _OAK1
         db        33,'OAK Technologies SuperVGA OTI-067'
         db        9,'OAK TECHN'
         dw        TestOAK
         dw        InitNul
_OAK1:

         dw        _OAK2
         db        33,'OAK Technologies SuperVGA OTI-077'
         db        9,'OAK TECHN'
         dw        TestOAK
         dw        InitNul
_OAK2:

         dw        _PAR
         db        24,'Paradise SuperVGA PVGA1A'
         db        8,'PARADISE'
         dw        TestPar
         dw        InitNul
_PAR:

         dw        _PA00
         db        25,'Paradise SuperVGA WD90C00'
         db        7,'WESTERN'
         dw        TestPar
         dw        InitNul
_PA00:

         dw        _PA10
         db        25,'Paradise SuperVGA WD90C10'
         db        7,'WESTERN'
         dw        TestPar
         dw        InitNul
_PA10:

         dw        _PA11
         db        25,'Paradise SuperVGA WD90C11'
         db        7,'WESTERN'
         dw        TestPar
         dw        InitNul
_PA11:

         dw        _PA20
         db        25,'Paradise SuperVGA WD90C20'
         db        7,'WESTERN'
         dw        TestPar
         dw        InitNul
_PA20:

         dw        _PA30
         db        25,'Paradise SuperVGA WD90C30'
         db        7,'WESTERN'
         dw        TestPar
         dw        InitNul
_PA30:

         dw        _PA31
         db        25,'Paradise SuperVGA WD90C31'
         db        7,'WESTERN'
         dw        TestPar
         dw        InitNul
_PA31:

         dw        _PRIM
         db        20,'Primus 2000 SuperVGA'
         db        6,'PRIMUS'
         dw        TestPrim
         dw        InitNul
_PRIM:

         dw        _Real
         db        21,'RealTek 3106 SuperVGA'
         db        7,'REALTEK'
         dw        TestRT3
         dw        InitNul
_Real:

         dw        _S911
         db        18,'S3 SuperVGA 86c911'
         db        6,'86C911'
         dw        TestS3
         dw        InitNul
_S911:

         dw        _S924
         db        18,'S3 SuperVGA 86c924'
         db        6,'86C924'
         dw        TestS3
         dw        InitNul
_S924:

         dw        _S801
         db        25,'S3 SuperVGA 86c801/86c805'
         db        5,'86C80'
         dw        TestS3
         dw        InitNul
_S801:

         dw        _S928
         db        18,'S3 SuperVGA 86c928'
         db        6,'86C928'
         dw        TestS3
         dw        InitNul
_S928:

         dw        _TRI8
         db        21,'Trident 8800 SuperVGA'
         db        7,'TRIDENT'
         dw        TestTri
         dw        InitNul
_TRI8:

         dw        _TRI9
         db        26,'Trident 8900/9000 SuperVGA'
         db        7,'TRIDENT'
         dw        TestTri
         dw        InitNul
_TRI9:

         dw        _ET30
         db        26,'Tseng Labs ET3000 SuperVGA'
         db        5,'TSENG'
         dw        TestET30
         dw        InitNul
_ET30:

         dw        _ET40
         db        36,'MegaEva/2 Tseng Labs ET4000 SuperVGA'
         db        7,'MEGAEVA'
         dw        TestET30
         dw        InitNul
_ET40:

         dw        _ET41
         db        47,'Diamond Speedstar 24 Tseng Labs ET4000 SuperVGA'
         db        7,'DIAMOND'
         dw        TestET30
         dw        InitNul
_ET41:

         dw        _ET42
         db        37,'Genoa 7900 Tseng Labs ET4000 SuperVGA'
         db        5,'GENOA'
         dw        TestET30
         dw        InitNul
_ET42:

         dw        _VID7
         db        15,'Video7 SuperVGA'
         db        6,'VIDEO7'
         dw        TestVID
         dw        InitNul
_VID7:

TDefCrd0 label     byte                     ; konec tabulky

Code     ENDS

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                          Datovò segment
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
Data     SEGMENT   PARA

DataBeg  label     byte                     ; zaá†tek datovÇho segmentu

TextKB1  db        2,' ('
TextKB2  db        18,' KB videopameti)',13,10

; ------ ukazatele parametrñ aktu†ln° karty

ACardNam dw        0                        ; adresa jmÇna karty
ACardSrc dw        0                        ; adresa vyhled†vac°ho ©etàzce karty
ACardTst dw        0                        ; adresa obsluhy testu karty (0=nen°)
ACardIni dw        0                        ; adresa inicializace videom¢du

; ------

VMemSize dw        256                      ; velikost videopamàti v KB
VParam   db        0                        ; parametry
                                            ;   bit 0: 1=moënÇ p©ep°n†n° str†nek

VDACType dw        DACTyp0                  ; typ DAC registru

CardParm db        0                        ; parametry videokarty
                                            ;    bit 0: 1=kompatibilita CGA
                                            ;    bit 1: 1=kompatibilita Hercules
                                            ;    bit 2: 1=kompatibilita EGA
                                            ;    bit 3: 1=rozhran° VESA

VCard    dw        0                        ; á°slo videokarty (0=nezn†m†)

VChipID  dw        0                        ; intern° identifik†tor áipu SVGA
VideoMem dw        256                      ; velikost videopamàti (v KB)

ModNum   dw        0                        ; aktu†ln° poáet videom¢dñ v tabulce
ModTab   label     word                     ; seznam povolenòch videom¢dñ
         db        MAXMOD*ModSize dup(?)    ; tabulka videom¢dñ

VesaInfo db        256 dup(?)               ; buffer informaán°ho bloku VESA

Data     ENDS

         END       Start


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
;                      Definice souboru *.MOD
; -----------------------------------------------------------------------------
;     je-li v souboru slovo, je na nië®° adrese uloëen jeho vy®®° bajt !
; -----------------------------------------------------------------------------
; 00h: (20) n†zev melodie ASCIIZ
; 14h: (930, 450) tabulka definic 31 (15) n†strojñ (definice kaëdÇho n†stroje 30 bajtñ)
;          0: (20) n†zev n†stroje ASCIIZ
;        14h: (1)
;        15h: (1)
;        16h: (2) velikost definice vzorku ve slovech (tj. 0 aë 128 KB)
;                 (nejd©°ve vy®®° bajt, potom nië®°)
;        18h: (2) hlasitost vzorku (nejd©°ve vy®®° bajt, potom nië®°)
;        1ah: (2) zaá†tek pro opakov†n° LoopS ve lsovech (vy®®° bajt, potom nië®°)
;        1ch: (2) dÇlka pro opakov†n° LoopL ve slovech (vy®®° bajt, potom nië®°)
;
; 3b6h (1d6h): (1) dÇlka skladby (poáet sekc° po 1 KB)
; 3b7h (1d7h): (1)
; 3B8h (1d8h): (80h) tabulka á°sel sekc° melodie (á°sla blokñ 1KB - 128 sekc°)
; 438h (258h): (4) identifik†tor "M.", "FLT4" = poáet n†strojñ = 30 (jinak = 15)
;
; 43ch (258h): zaá†tek melodie (sekce po 1 KB, prvn° sekce m† á°slo 0)
;
; Definice melodie: 4 kan†ly po 4 bajtech na t¢n:
;              0: bity 0 aë 3 = vy®®° 4 bity dàlic° konstanty (tj. bity 8 aë 11)
;                 bit 4 = 5. bit á°sla n†stroje (je-li 31 n†strojñ)
;              1: nië®°ch 8 bitñ dàlic° konstanty frekvence (tj. bity 0 aë 7)
;              2: bity 0 aë 3 = p©°kaz
;                                 0fh: "SD=" nastaven° rychlosti hry
;                                            (bajt 3 = rychlost hry)
;                 bity 4 aë 7 = nië®° 4 bity á°sla n†stroje
;              3: parametr povelu
;
;  á°slo n†stroje = 0: vzorek se nenastavuje (zñst†v† pñvodn°)
; -----------------------------------------------------------------------------

Start:

; ------ dek¢dov†n° parametrñ p©°kazovÇho ©†dku

         call      DekParm                  ; dek¢dov†n° parametrñ p©°kaz. ©†dku

; ------ zmen®en° bloku programu na minimum

         mov       ax,es                    ; segment PSP
         mov       bx,SEG KonSeg            ; segment konce programu
         sub       bx,ax                    ; dÇlka programu v odstavc°ch
         mov       ah,4ah
         int       21h

; ------ inicializace segmentovòch registrñ

         push      cs
         pop       ds
         push      cs
         pop       es

         mov       dx,offset UvTxt
         mov       ah,9
         int       21h                      ; zobrazen° £vodn°ho textu

; ------ nastaven° adresy DTA

Start08: mov       dx,offset DTA            ; buffer DTA
         mov       ah,1ah
         int       21h                      ; nastaven° adresy DTA

; ------ nalezen° prvn°ho souboru

         mov       dx,offset All            ; specifikace jmÇna souboru
         xor       cx,cx                    ; atributy souboru
         mov       ah,4eh
         int       21h                      ; nalezen° prvn°ho souboru
         jnc       Start3                   ; soubor nalezen OK

; ------ chyba - nenalezen ë†dnò soubor

         mov       dx,offset NoFile         ; text - nen° soubor
Start1:  mov       ah,9
         int       21h                      ; zobrazen° chybovÇho textu

; ------ konec programu

Start2:
         mov       ax,4c00h
         int       21h

; ------ naáten° souboru do pamàti

Start3:  mov       dx,offset DTA+1eh        ; jmÇno souboru
         call      CtiSoub                  ; naáten° souboru do pamàti

; ------ navr†cen° stavu poá°taáe

Start5:  call      ClosFile                 ; uzav©en° souboru
         call      DelADat                  ; zru®en° v®ech datovòch blokñ

; ------ nastaven° adresy DTA

         mov       dx,offset DTA            ; buffer DTA
         mov       ah,1ah
         int       21h                      ; nastaven° adresy DTA

; ------ nalezen° dal®°ho souboru

         mov       ah,4fh
         int       21h                      ; nalezen° dal®°ho souboru
         jnc       Start3                   ; obsluha dal®°ho souboru
         jmp       short Start2

; *****************************************************************************
;                               CtiSoub
;                    naáten° souboru MOD do pamàti
; -----------------------------------------------------------------------------
; VSTUP: DS:DX=jmÇno souboru
;        DS=datovò segment
; VùSTUP:CY=chyba áten°, nedostatek pamàti nebo chybnò form†t souboru
; -----------------------------------------------------------------------------
; niá° v®echny registry kromà DS !
; *****************************************************************************

CtiSoub  PROC      NEAR

; ------ standardn° nastaven° parametrñ

         and       byte ptr ds:[Param],not bit1 ; zru®en° p©°znaku velkÇho vzorku
         call      SetForm1                 ; nastaven° form†tu 1 (standardn°)

; ------ otev©en° souboru pro áten°

         call      OpenFile                 ; otev©en° souboru pro áten°
         jnc       CtiSoub1                 ; soubor otev©en OK
         ret                                ; chyba otev©en° souboru

; ------ nastaven° ukazatele na identifik†tor form†tu souboru

CtiSoub1:mov       dx,438h                  ; offset identifik†toru souboru
         call      SetUFile                 ; nastaven° ukazatele na identifik.
         jc        CtiSoub3                 ; chyba nastaven° ukazatele

; ------ naáten° identifik†toru souboru

         mov       dx,offset BuffId         ; buffer identifik†toru form†tu
         mov       cx,4                     ; poáet bajtñ ke áten°
         push      ds
         pop       es
         call      ReadFile                 ; naáten° identifik†toru souboru
         jc        CtiSoub3                 ; chyba áten°

; ------ rozli®en° form†tu souboru

         mov       si,dx                    ; buffer s daty
         cmp       word ptr ds:[si],".M"    ; je form†t "M." ?
         je        CtiSoub2                 ; je roz®°©enò form†t "M."
         cmp       word ptr ds:[si],"LF"    ; je form†t "FLT4" ?
         jne       CtiSoub3                 ; nen° form†t "FLT4"
         cmp       word ptr ds:[si],"4T"
         jne       CtiSoub3                 ; nen° form†t 2 "FLT4"
CtiSoub2:call      SetForm2                 ; nastaven° form†tu 2 (roz®°©enò)

; ------ nastaven° ukazatele v souboru na zaá†tek

CtiSoub3:xor       dx,dx
         call      SetUFile                 ; nastaven° ukazatele na zaá†tek

; ------ vytvo©en° datovÇho bloku pro z†hlav° souboru

         mov       ah,48h
         mov       bx,-1
         int       21h                      ; vytvo©en° datovÇho bloku
         mov       ah,48h
         int       21h                      ; vytvo©en° datovÇho bloku
         jc        CtiSoub4
         mov       es,ax                    ; adresa datovÇho bloku
         mov       bx,ds:[Zahlavi]          ; velikost z†hlav° souboru
         mov       cx,bx                    ; velikost z†hlav°
         inc       bx                       ; zaokrouhlen°
         shr       bx,1                     ; p©evod na slova
         call      ModiDat                  ; zmen®en° datovÇho bloku
         jnc       CtiSoub5                 ; datovò blok vytvo©en OK
CtiSoub4:ret
CtiSoub5:mov       ds:[DatBuff],es          ; segment datovÇho bufferu melodie

; ------ naáten° z†hlav° souboru do bufferu

         xor       dx,dx                    ; offset adresy k naáten° z†hlav°
         call      ReadFile                 ; naáten° z†hlav° souboru
         jc        CtiSoub4                 ; chyba áten° z†hlav° souboru

         mov       di,ds:[AdrSekce]         ; adresa tabulky sekc° melodie

; ------ nalezen° á°sla posledn° sekce melodie

         mov       cx,127                   ; poáet sekc° melodie
         xor       ax,ax                    ; nejvàt®° nalezen† sekce
         cld
CtiSoub6:scasb                              ; je vàt®° sekce ?
         jge       CtiSoub7                 ; nen° to vàt®° sekce
         mov       al,es:[di-1]             ; nov† nejvàt®° sekce
CtiSoub7:loop      CtiSoub6                 ; test dal®° sekce

; ------ vòpoáet velikosti melodie

         inc       ax                       ; poáet sekc° melodie
         xchg      ah,al                    ; velikost melodie * 256
         shl       ax,1                     ; velikost melodie ve slovech
         add       bx,ax                    ; nov† velikost dat. bloku (slov)
         shl       ax,1                     ; velikost melodie v bajtech
         mov       cx,ax                    ; velikost melodie v bajtech

; ------ zvàt®en° datovÇho bloku (velikost je v BX)

         call      ModiDat                  ; zvàt®en° datovÇho bloku
         jc        CtiSoub4                 ; chyba - nedostatek pamàti

; ------ naáten° melodie do bufferu

         mov       dx,ds:[Zahlavi]          ; adresa k naáten° melodie v bufferu
         call      ReadFile                 ; naáten° melodie do bufferu
         jc        CtiSoub4                 ; chyba áten° ze souboru

; ------ p©°prava k naáten° vzorkñ n†strojñ

         mov       si,2ah                   ; adresa velikosti prvn°ho vzorku
         mov       bp,word ptr ds:[Nastroju] ; poáet n†strojñ
         mov       di,offset TabVzor        ; tabulka adres vzorkñ

; ------ otev©en° vòstupn°ho souboru

CtiSoub8:mov       es,ds:[DatBuff]          ; segment datovÇho bufferu s melodi°

         and       byte ptr ds:[Param],not bit2
         cmp       word ptr es:[si],0
         jne       CtiSou89
         or        byte ptr ds:[Param],bit2
         jmp       short CtiSou8a
CtiSou89:
         mov       ah,3ch
         mov       dx,offset Soubor
         xor       cx,cx                    ; vytvo©en° souboru
         int       21h
         jc        CtiSoubA                 ; chyba
         mov       ds:[OutIdn],ax           ; identifik†tor souboru
         mov       bx,ax

; ------ velikost vzorku jednoho n†stroje

CtiSou8a:
         mov       cx,es:[si]               ; velikost vzorku n†stroje
         xchg      ch,cl                    ; oprava po©ad° bajtñ
         cmp       cx,8000h
         jb        CtiSou82
         mov       cx,7fffh                 ; omezen° na 64 KB
         xchg      ch,cl
         mov       es:[si],cx
         xchg      ch,cl

; ------ z†pis z†hlav° souboru

CtiSou82:test      byte ptr ds:[Param],bit2
         jnz       CtiSou85
         push      ds
         push      cx
         mov       dx,si
         sub       dx,16h
         push      es
         pop       ds
         mov       cx,30                    ; dÇlka z†hlav°
         mov       ah,40h
;         int       21h
         pop       cx
         pop       ds

; ------ vytvo©en° datovÇho bloku pro vzorek

CtiSou85:jcxz      CtiSoubB                 ; vzorek nen° definov†n
         mov       bx,cx                    ; velikost vzorku ve slovech
         call      CreatDat                 ; vytvo©en° datovÇho bufferu
         jc        CtiSoubA                 ; chyba - nedostatek pamàti
         mov       ds:[di],es               ; £schova adresy bufferu

; ------ áten° zbytku dat

CtiSoub9:xor       dx,dx                    ; adresa k naáten° dat
         shl       cx,1                     ; p©evod slov na bajty
         call      ReadFile                 ; áten° bloku dat

         test      byte ptr ds:[Param],bit2
         jnz       CtiSouBb

         mov       bx,ds:[OutIdn]
         mov       ah,40h
         push      ds
         push      es
         pop       ds
         int       21h                      ; z†pis vzorku
         pop       ds
         jmp       short CtiSoubB

         clc
CtiSoubA:ret

; ------ p©°prava pro dal®° vzorek

CtiSoubB:
         test      byte ptr ds:[Param],bit2
         jnz       CtiSouBe

         mov       bx,ds:[OutIdn]
         mov       ah,3eh
         int       21h                      ; uzav©en° souboru

         push      si
         mov       si,offset Soubor0
CtiSoubd:dec       si
         inc       byte ptr ds:[si]
         cmp       byte ptr ds:[si],"9"+1
         jne       CtiSoubc
         mov       byte ptr ds:[si],"0"
         jmp       short CtiSoubd
CtiSoubc:pop       si

CtiSoube:add       si,1eh                   ; adresa dal®°ho n†stroje
         inc       di
         inc       di                       ; ukazatel adres bufferñ
         dec       bp                       ; á°taá n†strojñ
         jz        CtiSoubo

         jmp       CtiSoub8                 ; dal®° n†stroj

CtiSoubo:
         clc                                ; p©°znak operace OK
         ret

CtiSoub  ENDP


; *****************************************************************************
;                             CreatDat
;                      vytvo©en° datovÇho bloku
; -----------------------------------------------------------------------------
; VSTUP: BX=velikost bloku ve slovech
;        DS=datovò segment
; VùSTUP:ES=segment datovÇho bloku
;        CY=nedostatek pamàti
; *****************************************************************************

CreatDat PROC      NEAR

         push      ax
         push      bx

         add       bx,7                     ; zaokrouhlen°
         shr       bx,1
         shr       bx,1
         shr       bx,1                     ; p©evod na odstavce
         mov       ah,48h
         int       21h                      ; vytvo©en° datovÇho bloku
         mov       es,ax                    ; adresa datovÇho bloku

         pop       bx
         pop       ax
         ret

CreatDat ENDP

; *****************************************************************************
;                            ModiDat
;                   modifikace datovÇho bloku
; -----------------------------------------------------------------------------
; VSTUP: BX=nov† velikost datovÇho bloku ve slovech
;        ES=adresa datovÇho bloku
; VùSTUP:CY=nedostatek pamàti
; *****************************************************************************

ModiDat0:inc       bx                       ; zaokrouhlen°
         shr       bx,1                     ; p©evod na slova


ModiDat  PROC      NEAR

         push      ax
         push      bx

         add       bx,7                     ; zaokrouhlen°
         shr       bx,1
         shr       bx,1
         shr       bx,1                     ; p©evod na odstavce
         mov       ah,4ah
         int       21h                      ; modifikace datovÇho bloku

         pop       bx
         pop       ax
         ret

ModiDat  ENDP

; *****************************************************************************
;                            DelADat
;              zru®en° v®ech datovòch blokñ programu
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

DelADat  PROC      NEAR

         push      si
         push      cx
         push      es

         mov       es,ds:[DatBuff]          ; datovò buffer
         call      DelDat                   ; zru®en° datovÇho bufferu melodie
         mov       word ptr ds:[DatBuff],0  ; zru®en° adresy bufferu

         mov       si,offset TabVzor        ; tabulka adres vzorkñ n†strojñ
         mov       cx,31                    ; poáet poloëek v tabulce
DelADat1:mov       es,ds:[si]               ; adresa bloku ke zru®en°
         call      DelDat                   ; zru®en° datovÇho bloku
         mov       word ptr ds:[si],0       ; zru®en° adresy bufferu
         inc       si
         inc       si                       ; zvò®en° ukazatele v tabulce
         loop      DelADat1                 ; dal®° datovò blok

         pop       es
         pop       cx
         pop       si
         ret

DelADat  ENDP

; *****************************************************************************
;                           DelDat
;                    zru®en° datovÇho bloku
; -----------------------------------------------------------------------------
; VSTUP: ES=adresa datovÇho bloku ke zru®en°
; *****************************************************************************

DelDat   PROC      NEAR

         push      ax

         mov       ax,es                    ; adresa datovÇho bloku
         or        ax,ax                    ; je to platnò datovò blok ?
         jz        DelDat2                  ; neplatnò datovò blok

         mov       ah,49h
         int       21h                      ; zru®en° datovÇho bloku

DelDat2: pop       ax
         ret

DelDat   ENDP

; *****************************************************************************
;                             OpenFile
;                         otev©en° souboru
; -----------------------------------------------------------------------------
; VSTUP: DS:DX=jmÇno souboru
; VùSTUP:CY=soubor nenalezen
; *****************************************************************************

OpenFile PROC      NEAR

         push      ax

         mov       ax,3d00h
         int       21h                      ; otev©en° souboru pro áten°
         jc        OpenFil2                 ; soubor nenalezen
         mov       ds:[Identif],ax          ; identifik†tor souboru

OpenFil2:pop       ax
         ret

OpenFile ENDP

; *****************************************************************************
;                              SetUFile
;                 nastaven° ukazatele v souboru (do 64 KB)
; -----------------------------------------------------------------------------
; VSTUP: DX=ukazatel v souboru
;        DS=datovò segment
; VùSTUP:CY=chyba vystaven° ukazatele
; *****************************************************************************

SetUFile PROC      NEAR

         push      ax
         push      bx
         push      cx

         mov       ax,4200h
         xor       cx,cx                    ; vy®®° slovo
         mov       bx,ds:[Identif]          ; identifik†tor souboru
         int       21h                      ; nastaven° ukazatele na identifik.

         pop       cx
         pop       bx
         pop       ax
         ret

SetUFile ENDP

; *****************************************************************************
;                            ReadFile
;                     áten° dat ze souboru
; -----------------------------------------------------------------------------
; VSTUP: ES:DX=adresa k naáten° bloku dat ze souboru
;        CX=poáet bajtñ ke áten°
;        DS=datovò segment
; VùSTUP:CY=chyba áten° nebo nesouhlas° poáet bajtñ
; *****************************************************************************

ReadFile PROC      NEAR

         push      ax
         push      bx

         push      ds
         mov       bx,ds:[Identif]          ; idetnifik†tor soubrou
         push      es
         pop       ds
         mov       ah,3fh
         int       21h                      ; naáten° identifik†toru souboru
         pop       ds
         jc        ReadFil2                 ; chyba áten°
         cmp       ax,cx
         je        ReadFil2                 ; poáet bajtñ souhlas° OK
         stc                                ; chyba áten°

ReadFil2:pop       bx
         pop       ax
         ret

ReadFile ENDP

; *****************************************************************************
;                            ClosFile
;                        uzav©en° souboru
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

ClosFile PROC      NEAR

         push      ax
         push      bx

         mov       bx,ds:[Identif]          ; identifik†tor souboru
         or        bx,bx                    ; je soubor otev©en ?
         jz        ClosFil2                 ; soubor nen° otev©en
         mov       ah,3eh
         int       21h                      ; uzav©en° souboru
         mov       word ptr ds:[Identif],0  ; zru®en° p©°znaku otev©en° souboru

ClosFil2:pop       bx
         pop       ax
         ret

ClosFile ENDP

; *****************************************************************************
;                              SetForm1
;         nastaven° form†tu 1 (standardn° form†t souboru - 15 n†strojñ)
; -----------------------------------------------------------------------------
; *****************************************************************************

SetForm1 PROC      NEAR

         and       byte ptr ds:[Param],not bit0 ; form†t souboru 1 (15 n†strojñ)
         mov       byte ptr ds:[Nastroju],15    ; poáet n†strojñ = 15
         mov       word ptr ds:[Zahlavi],258h   ; velikost z†hlav° souboru
         mov       word ptr ds:[AdrSekce],1d8h  ; adresa tabulky sekc° melodie
         ret

SetForm1 ENDP

; *****************************************************************************
;                            SetForm2
;         nastaven° form†tu 2 (roz®°©en° form†t souboru - 31 n†strojñ)
; -----------------------------------------------------------------------------
; *****************************************************************************

SetForm2 PROC      NEAR

         or        byte ptr ds:[Param],bit0    ; form†t souboru 2 (31 n†strojñ)
         mov       byte ptr ds:[Nastroju],31   ; poáet n†strojñ = 31
         mov       word ptr ds:[Zahlavi],43ch  ; velikost z†hlav° souboru
         mov       word ptr ds:[AdrSekce],3b8h ; adresa tabulky sekc° melodie
         ret

SetForm2 ENDP

; *****************************************************************************
;                                 DekParm
;                   Dek¢dov†n° parametrñ z p©°kazovÇho ©†dku
; -----------------------------------------------------------------------------
; VSTUP: DS,ES=adresa PSP
; *****************************************************************************

DekParm  PROC      NEAR

         push      ds
         push      es

; ------ p©°prava registrñ

         push      cs
         pop       es
         mov       si,81h
         mov       cl,ds:[si-1]             ; dÇlka parametrñ
         mov       ch,0
         cld

; ------ nalezen° zaá†tku textu v bufferu

DekParm1:jcxz      DekParm9
         lodsb
         dec       cx
         cmp       al," "
         je        DekParm1
         cmp       al,9
         je        DekParm1
         cmp       al,13
         je        DekParm9

; ------ p©enesen° textu do bufferu

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

; ------ oznaáen° konce jmÇna souboru

DekParm3:mov       al,0
         stosb

DekParm9:pop       es
         pop       ds
         ret

DekParm  ENDP

; *****************************************************************************
;
;                            Data
;
; *****************************************************************************

Param    db        0                        ; parametry
                                            ;   bit 0: 1=je form†t 2 souboru
                                            ;   bit 1: 1=je velkò soubor
                                            ;   bit 2: 1=neplatnò vzorek

Identif  dw        0                        ; identifik†tor souboru
TabVzor  dw        31 dup(0)                ; tabulka adres vzorkñ
DatBuff  dw        0                        ; segment datovÇho bufferu melodie

Nastroju db        15                       ; poáet n†strojñ
         db        0                        ; zarovn†n° na slovo

; ------ definián° konstanty souboru

Zahlavi  dw        258h                     ; velikost z†hlav° souboru
AdrSekce dw        1d8h                     ; adresa sekc° melodie

BuffId   dd        0                        ; buffer identifik†toru souboru

; ------ texty

UvTxt    db        'SAVESAM V1.0 - ukladani vzorku na disk; (c) Miroslav Nemecek',13,10,'$'
NoFile   db        'V aktivnim adresari nenalezen zadny soubor *.MOD !',13,10,'$'

Soubor   db        'SAMP0000'
Soubor0  db        '.SAM',0
OutIdn   dw        0                        ; identifik†tor souboru

All      db        '*.MOD',0                ; specifikace souborñ
         db        128 dup(?)               ; buffer pro £schovu specifikace

DTA      db        44 dup(?)                ; buffer DTA pro hled†n° souborñ

Code     ENDS

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                            Z†sobn°k
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

Zasobnik SEGMENT   STACK

         dw        2000h dup(?)

Zasobnik ENDS

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                           Segment konce programu
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

KonSeg   SEGMENT

KonSeg   ENDS

         END       Start

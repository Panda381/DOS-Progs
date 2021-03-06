
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
;     je-li v souboru slovo, je na ni��� adrese ulo�en jeho vy��� bajt !
; -----------------------------------------------------------------------------
; 00h: (20) n�zev melodie ASCIIZ
; 14h: (930, 450) tabulka definic 31 (15) n�stroj� (definice ka�d�ho n�stroje 30 bajt�)
;          0: (20) n�zev n�stroje ASCIIZ
;        14h: (1)
;        15h: (1)
;        16h: (2) velikost definice vzorku ve slovech (tj. 0 a� 128 KB)
;                 (nejd��ve vy��� bajt, potom ni���)
;        18h: (2) hlasitost vzorku (nejd��ve vy��� bajt, potom ni���)
;        1ah: (2) za��tek pro opakov�n� LoopS ve lsovech (vy��� bajt, potom ni���)
;        1ch: (2) d�lka pro opakov�n� LoopL ve slovech (vy��� bajt, potom ni���)
;
; 3b6h (1d6h): (1) d�lka skladby (po�et sekc� po 1 KB)
; 3b7h (1d7h): (1)
; 3B8h (1d8h): (80h) tabulka ��sel sekc� melodie (��sla blok� 1KB - 128 sekc�)
; 438h (258h): (4) identifik�tor "M.", "FLT4" = po�et n�stroj� = 30 (jinak = 15)
;
; 43ch (258h): za��tek melodie (sekce po 1 KB, prvn� sekce m� ��slo 0)
;
; Definice melodie: 4 kan�ly po 4 bajtech na t�n:
;              0: bity 0 a� 3 = vy��� 4 bity d�lic� konstanty (tj. bity 8 a� 11)
;                 bit 4 = 5. bit ��sla n�stroje (je-li 31 n�stroj�)
;              1: ni���ch 8 bit� d�lic� konstanty frekvence (tj. bity 0 a� 7)
;              2: bity 0 a� 3 = p��kaz
;                                 0fh: "SD=" nastaven� rychlosti hry
;                                            (bajt 3 = rychlost hry)
;                 bity 4 a� 7 = ni��� 4 bity ��sla n�stroje
;              3: parametr povelu
;
;  ��slo n�stroje = 0: vzorek se nenastavuje (z�st�v� p�vodn�)
; -----------------------------------------------------------------------------

Start:

; ------ dek�dov�n� parametr� p��kazov�ho ��dku

         call      DekParm                  ; dek�dov�n� parametr� p��kaz. ��dku

; ------ zmen�en� bloku programu na minimum

         mov       ax,es                    ; segment PSP
         mov       bx,SEG KonSeg            ; segment konce programu
         sub       bx,ax                    ; d�lka programu v odstavc�ch
         mov       ah,4ah
         int       21h

; ------ inicializace segmentov�ch registr�

         push      cs
         pop       ds
         push      cs
         pop       es

         mov       dx,offset UvTxt
         mov       ah,9
         int       21h                      ; zobrazen� �vodn�ho textu

; ------ nastaven� adresy DTA

Start08: mov       dx,offset DTA            ; buffer DTA
         mov       ah,1ah
         int       21h                      ; nastaven� adresy DTA

; ------ nalezen� prvn�ho souboru

         mov       dx,offset All            ; specifikace jm�na souboru
         xor       cx,cx                    ; atributy souboru
         mov       ah,4eh
         int       21h                      ; nalezen� prvn�ho souboru
         jnc       Start3                   ; soubor nalezen OK

; ------ chyba - nenalezen ��dn� soubor

         mov       dx,offset NoFile         ; text - nen� soubor
Start1:  mov       ah,9
         int       21h                      ; zobrazen� chybov�ho textu

; ------ konec programu

Start2:
         mov       ax,4c00h
         int       21h

; ------ na�ten� souboru do pam�ti

Start3:  mov       dx,offset DTA+1eh        ; jm�no souboru
         call      CtiSoub                  ; na�ten� souboru do pam�ti

; ------ navr�cen� stavu po��ta�e

Start5:  call      ClosFile                 ; uzav�en� souboru
         call      DelADat                  ; zru�en� v�ech datov�ch blok�

; ------ nastaven� adresy DTA

         mov       dx,offset DTA            ; buffer DTA
         mov       ah,1ah
         int       21h                      ; nastaven� adresy DTA

; ------ nalezen� dal��ho souboru

         mov       ah,4fh
         int       21h                      ; nalezen� dal��ho souboru
         jnc       Start3                   ; obsluha dal��ho souboru
         jmp       short Start2

; *****************************************************************************
;                               CtiSoub
;                    na�ten� souboru MOD do pam�ti
; -----------------------------------------------------------------------------
; VSTUP: DS:DX=jm�no souboru
;        DS=datov� segment
; V�STUP:CY=chyba �ten�, nedostatek pam�ti nebo chybn� form�t souboru
; -----------------------------------------------------------------------------
; ni�� v�echny registry krom� DS !
; *****************************************************************************

CtiSoub  PROC      NEAR

; ------ standardn� nastaven� parametr�

         and       byte ptr ds:[Param],not bit1 ; zru�en� p��znaku velk�ho vzorku
         call      SetForm1                 ; nastaven� form�tu 1 (standardn�)

; ------ otev�en� souboru pro �ten�

         call      OpenFile                 ; otev�en� souboru pro �ten�
         jnc       CtiSoub1                 ; soubor otev�en OK
         ret                                ; chyba otev�en� souboru

; ------ nastaven� ukazatele na identifik�tor form�tu souboru

CtiSoub1:mov       dx,438h                  ; offset identifik�toru souboru
         call      SetUFile                 ; nastaven� ukazatele na identifik.
         jc        CtiSoub3                 ; chyba nastaven� ukazatele

; ------ na�ten� identifik�toru souboru

         mov       dx,offset BuffId         ; buffer identifik�toru form�tu
         mov       cx,4                     ; po�et bajt� ke �ten�
         push      ds
         pop       es
         call      ReadFile                 ; na�ten� identifik�toru souboru
         jc        CtiSoub3                 ; chyba �ten�

; ------ rozli�en� form�tu souboru

         mov       si,dx                    ; buffer s daty
         cmp       word ptr ds:[si],".M"    ; je form�t "M." ?
         je        CtiSoub2                 ; je roz���en� form�t "M."
         cmp       word ptr ds:[si],"LF"    ; je form�t "FLT4" ?
         jne       CtiSoub3                 ; nen� form�t "FLT4"
         cmp       word ptr ds:[si],"4T"
         jne       CtiSoub3                 ; nen� form�t 2 "FLT4"
CtiSoub2:call      SetForm2                 ; nastaven� form�tu 2 (roz���en�)

; ------ nastaven� ukazatele v souboru na za��tek

CtiSoub3:xor       dx,dx
         call      SetUFile                 ; nastaven� ukazatele na za��tek

; ------ vytvo�en� datov�ho bloku pro z�hlav� souboru

         mov       ah,48h
         mov       bx,-1
         int       21h                      ; vytvo�en� datov�ho bloku
         mov       ah,48h
         int       21h                      ; vytvo�en� datov�ho bloku
         jc        CtiSoub4
         mov       es,ax                    ; adresa datov�ho bloku
         mov       bx,ds:[Zahlavi]          ; velikost z�hlav� souboru
         mov       cx,bx                    ; velikost z�hlav�
         inc       bx                       ; zaokrouhlen�
         shr       bx,1                     ; p�evod na slova
         call      ModiDat                  ; zmen�en� datov�ho bloku
         jnc       CtiSoub5                 ; datov� blok vytvo�en OK
CtiSoub4:ret
CtiSoub5:mov       ds:[DatBuff],es          ; segment datov�ho bufferu melodie

; ------ na�ten� z�hlav� souboru do bufferu

         xor       dx,dx                    ; offset adresy k na�ten� z�hlav�
         call      ReadFile                 ; na�ten� z�hlav� souboru
         jc        CtiSoub4                 ; chyba �ten� z�hlav� souboru

         mov       di,ds:[AdrSekce]         ; adresa tabulky sekc� melodie

; ------ nalezen� ��sla posledn� sekce melodie

         mov       cx,127                   ; po�et sekc� melodie
         xor       ax,ax                    ; nejv�t�� nalezen� sekce
         cld
CtiSoub6:scasb                              ; je v�t�� sekce ?
         jge       CtiSoub7                 ; nen� to v�t�� sekce
         mov       al,es:[di-1]             ; nov� nejv�t�� sekce
CtiSoub7:loop      CtiSoub6                 ; test dal�� sekce

; ------ v�po�et velikosti melodie

         inc       ax                       ; po�et sekc� melodie
         xchg      ah,al                    ; velikost melodie * 256
         shl       ax,1                     ; velikost melodie ve slovech
         add       bx,ax                    ; nov� velikost dat. bloku (slov)
         shl       ax,1                     ; velikost melodie v bajtech
         mov       cx,ax                    ; velikost melodie v bajtech

; ------ zv�t�en� datov�ho bloku (velikost je v BX)

         call      ModiDat                  ; zv�t�en� datov�ho bloku
         jc        CtiSoub4                 ; chyba - nedostatek pam�ti

; ------ na�ten� melodie do bufferu

         mov       dx,ds:[Zahlavi]          ; adresa k na�ten� melodie v bufferu
         call      ReadFile                 ; na�ten� melodie do bufferu
         jc        CtiSoub4                 ; chyba �ten� ze souboru

; ------ p��prava k na�ten� vzork� n�stroj�

         mov       si,2ah                   ; adresa velikosti prvn�ho vzorku
         mov       bp,word ptr ds:[Nastroju] ; po�et n�stroj�
         mov       di,offset TabVzor        ; tabulka adres vzork�

; ------ otev�en� v�stupn�ho souboru

CtiSoub8:mov       es,ds:[DatBuff]          ; segment datov�ho bufferu s melodi�

         and       byte ptr ds:[Param],not bit2
         cmp       word ptr es:[si],0
         jne       CtiSou89
         or        byte ptr ds:[Param],bit2
         jmp       short CtiSou8a
CtiSou89:
         mov       ah,3ch
         mov       dx,offset Soubor
         xor       cx,cx                    ; vytvo�en� souboru
         int       21h
         jc        CtiSoubA                 ; chyba
         mov       ds:[OutIdn],ax           ; identifik�tor souboru
         mov       bx,ax

; ------ velikost vzorku jednoho n�stroje

CtiSou8a:
         mov       cx,es:[si]               ; velikost vzorku n�stroje
         xchg      ch,cl                    ; oprava po�ad� bajt�
         cmp       cx,8000h
         jb        CtiSou82
         mov       cx,7fffh                 ; omezen� na 64 KB
         xchg      ch,cl
         mov       es:[si],cx
         xchg      ch,cl

; ------ z�pis z�hlav� souboru

CtiSou82:test      byte ptr ds:[Param],bit2
         jnz       CtiSou85
         push      ds
         push      cx
         mov       dx,si
         sub       dx,16h
         push      es
         pop       ds
         mov       cx,30                    ; d�lka z�hlav�
         mov       ah,40h
;         int       21h
         pop       cx
         pop       ds

; ------ vytvo�en� datov�ho bloku pro vzorek

CtiSou85:jcxz      CtiSoubB                 ; vzorek nen� definov�n
         mov       bx,cx                    ; velikost vzorku ve slovech
         call      CreatDat                 ; vytvo�en� datov�ho bufferu
         jc        CtiSoubA                 ; chyba - nedostatek pam�ti
         mov       ds:[di],es               ; �schova adresy bufferu

; ------ �ten� zbytku dat

CtiSoub9:xor       dx,dx                    ; adresa k na�ten� dat
         shl       cx,1                     ; p�evod slov na bajty
         call      ReadFile                 ; �ten� bloku dat

         test      byte ptr ds:[Param],bit2
         jnz       CtiSouBb

         mov       bx,ds:[OutIdn]
         mov       ah,40h
         push      ds
         push      es
         pop       ds
         int       21h                      ; z�pis vzorku
         pop       ds
         jmp       short CtiSoubB

         clc
CtiSoubA:ret

; ------ p��prava pro dal�� vzorek

CtiSoubB:
         test      byte ptr ds:[Param],bit2
         jnz       CtiSouBe

         mov       bx,ds:[OutIdn]
         mov       ah,3eh
         int       21h                      ; uzav�en� souboru

         push      si
         mov       si,offset Soubor0
CtiSoubd:dec       si
         inc       byte ptr ds:[si]
         cmp       byte ptr ds:[si],"9"+1
         jne       CtiSoubc
         mov       byte ptr ds:[si],"0"
         jmp       short CtiSoubd
CtiSoubc:pop       si

CtiSoube:add       si,1eh                   ; adresa dal��ho n�stroje
         inc       di
         inc       di                       ; ukazatel adres buffer�
         dec       bp                       ; ��ta� n�stroj�
         jz        CtiSoubo

         jmp       CtiSoub8                 ; dal�� n�stroj

CtiSoubo:
         clc                                ; p��znak operace OK
         ret

CtiSoub  ENDP


; *****************************************************************************
;                             CreatDat
;                      vytvo�en� datov�ho bloku
; -----------------------------------------------------------------------------
; VSTUP: BX=velikost bloku ve slovech
;        DS=datov� segment
; V�STUP:ES=segment datov�ho bloku
;        CY=nedostatek pam�ti
; *****************************************************************************

CreatDat PROC      NEAR

         push      ax
         push      bx

         add       bx,7                     ; zaokrouhlen�
         shr       bx,1
         shr       bx,1
         shr       bx,1                     ; p�evod na odstavce
         mov       ah,48h
         int       21h                      ; vytvo�en� datov�ho bloku
         mov       es,ax                    ; adresa datov�ho bloku

         pop       bx
         pop       ax
         ret

CreatDat ENDP

; *****************************************************************************
;                            ModiDat
;                   modifikace datov�ho bloku
; -----------------------------------------------------------------------------
; VSTUP: BX=nov� velikost datov�ho bloku ve slovech
;        ES=adresa datov�ho bloku
; V�STUP:CY=nedostatek pam�ti
; *****************************************************************************

ModiDat0:inc       bx                       ; zaokrouhlen�
         shr       bx,1                     ; p�evod na slova


ModiDat  PROC      NEAR

         push      ax
         push      bx

         add       bx,7                     ; zaokrouhlen�
         shr       bx,1
         shr       bx,1
         shr       bx,1                     ; p�evod na odstavce
         mov       ah,4ah
         int       21h                      ; modifikace datov�ho bloku

         pop       bx
         pop       ax
         ret

ModiDat  ENDP

; *****************************************************************************
;                            DelADat
;              zru�en� v�ech datov�ch blok� programu
; -----------------------------------------------------------------------------
; VSTUP: DS=datov� segment
; *****************************************************************************

DelADat  PROC      NEAR

         push      si
         push      cx
         push      es

         mov       es,ds:[DatBuff]          ; datov� buffer
         call      DelDat                   ; zru�en� datov�ho bufferu melodie
         mov       word ptr ds:[DatBuff],0  ; zru�en� adresy bufferu

         mov       si,offset TabVzor        ; tabulka adres vzork� n�stroj�
         mov       cx,31                    ; po�et polo�ek v tabulce
DelADat1:mov       es,ds:[si]               ; adresa bloku ke zru�en�
         call      DelDat                   ; zru�en� datov�ho bloku
         mov       word ptr ds:[si],0       ; zru�en� adresy bufferu
         inc       si
         inc       si                       ; zv��en� ukazatele v tabulce
         loop      DelADat1                 ; dal�� datov� blok

         pop       es
         pop       cx
         pop       si
         ret

DelADat  ENDP

; *****************************************************************************
;                           DelDat
;                    zru�en� datov�ho bloku
; -----------------------------------------------------------------------------
; VSTUP: ES=adresa datov�ho bloku ke zru�en�
; *****************************************************************************

DelDat   PROC      NEAR

         push      ax

         mov       ax,es                    ; adresa datov�ho bloku
         or        ax,ax                    ; je to platn� datov� blok ?
         jz        DelDat2                  ; neplatn� datov� blok

         mov       ah,49h
         int       21h                      ; zru�en� datov�ho bloku

DelDat2: pop       ax
         ret

DelDat   ENDP

; *****************************************************************************
;                             OpenFile
;                         otev�en� souboru
; -----------------------------------------------------------------------------
; VSTUP: DS:DX=jm�no souboru
; V�STUP:CY=soubor nenalezen
; *****************************************************************************

OpenFile PROC      NEAR

         push      ax

         mov       ax,3d00h
         int       21h                      ; otev�en� souboru pro �ten�
         jc        OpenFil2                 ; soubor nenalezen
         mov       ds:[Identif],ax          ; identifik�tor souboru

OpenFil2:pop       ax
         ret

OpenFile ENDP

; *****************************************************************************
;                              SetUFile
;                 nastaven� ukazatele v souboru (do 64 KB)
; -----------------------------------------------------------------------------
; VSTUP: DX=ukazatel v souboru
;        DS=datov� segment
; V�STUP:CY=chyba vystaven� ukazatele
; *****************************************************************************

SetUFile PROC      NEAR

         push      ax
         push      bx
         push      cx

         mov       ax,4200h
         xor       cx,cx                    ; vy��� slovo
         mov       bx,ds:[Identif]          ; identifik�tor souboru
         int       21h                      ; nastaven� ukazatele na identifik.

         pop       cx
         pop       bx
         pop       ax
         ret

SetUFile ENDP

; *****************************************************************************
;                            ReadFile
;                     �ten� dat ze souboru
; -----------------------------------------------------------------------------
; VSTUP: ES:DX=adresa k na�ten� bloku dat ze souboru
;        CX=po�et bajt� ke �ten�
;        DS=datov� segment
; V�STUP:CY=chyba �ten� nebo nesouhlas� po�et bajt�
; *****************************************************************************

ReadFile PROC      NEAR

         push      ax
         push      bx

         push      ds
         mov       bx,ds:[Identif]          ; idetnifik�tor soubrou
         push      es
         pop       ds
         mov       ah,3fh
         int       21h                      ; na�ten� identifik�toru souboru
         pop       ds
         jc        ReadFil2                 ; chyba �ten�
         cmp       ax,cx
         je        ReadFil2                 ; po�et bajt� souhlas� OK
         stc                                ; chyba �ten�

ReadFil2:pop       bx
         pop       ax
         ret

ReadFile ENDP

; *****************************************************************************
;                            ClosFile
;                        uzav�en� souboru
; -----------------------------------------------------------------------------
; VSTUP: DS=datov� segment
; *****************************************************************************

ClosFile PROC      NEAR

         push      ax
         push      bx

         mov       bx,ds:[Identif]          ; identifik�tor souboru
         or        bx,bx                    ; je soubor otev�en ?
         jz        ClosFil2                 ; soubor nen� otev�en
         mov       ah,3eh
         int       21h                      ; uzav�en� souboru
         mov       word ptr ds:[Identif],0  ; zru�en� p��znaku otev�en� souboru

ClosFil2:pop       bx
         pop       ax
         ret

ClosFile ENDP

; *****************************************************************************
;                              SetForm1
;         nastaven� form�tu 1 (standardn� form�t souboru - 15 n�stroj�)
; -----------------------------------------------------------------------------
; *****************************************************************************

SetForm1 PROC      NEAR

         and       byte ptr ds:[Param],not bit0 ; form�t souboru 1 (15 n�stroj�)
         mov       byte ptr ds:[Nastroju],15    ; po�et n�stroj� = 15
         mov       word ptr ds:[Zahlavi],258h   ; velikost z�hlav� souboru
         mov       word ptr ds:[AdrSekce],1d8h  ; adresa tabulky sekc� melodie
         ret

SetForm1 ENDP

; *****************************************************************************
;                            SetForm2
;         nastaven� form�tu 2 (roz���en� form�t souboru - 31 n�stroj�)
; -----------------------------------------------------------------------------
; *****************************************************************************

SetForm2 PROC      NEAR

         or        byte ptr ds:[Param],bit0    ; form�t souboru 2 (31 n�stroj�)
         mov       byte ptr ds:[Nastroju],31   ; po�et n�stroj� = 31
         mov       word ptr ds:[Zahlavi],43ch  ; velikost z�hlav� souboru
         mov       word ptr ds:[AdrSekce],3b8h ; adresa tabulky sekc� melodie
         ret

SetForm2 ENDP

; *****************************************************************************
;                                 DekParm
;                   Dek�dov�n� parametr� z p��kazov�ho ��dku
; -----------------------------------------------------------------------------
; VSTUP: DS,ES=adresa PSP
; *****************************************************************************

DekParm  PROC      NEAR

         push      ds
         push      es

; ------ p��prava registr�

         push      cs
         pop       es
         mov       si,81h
         mov       cl,ds:[si-1]             ; d�lka parametr�
         mov       ch,0
         cld

; ------ nalezen� za��tku textu v bufferu

DekParm1:jcxz      DekParm9
         lodsb
         dec       cx
         cmp       al," "
         je        DekParm1
         cmp       al,9
         je        DekParm1
         cmp       al,13
         je        DekParm9

; ------ p�enesen� textu do bufferu

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

; ------ ozna�en� konce jm�na souboru

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
                                            ;   bit 0: 1=je form�t 2 souboru
                                            ;   bit 1: 1=je velk� soubor
                                            ;   bit 2: 1=neplatn� vzorek

Identif  dw        0                        ; identifik�tor souboru
TabVzor  dw        31 dup(0)                ; tabulka adres vzork�
DatBuff  dw        0                        ; segment datov�ho bufferu melodie

Nastroju db        15                       ; po�et n�stroj�
         db        0                        ; zarovn�n� na slovo

; ------ defini�n� konstanty souboru

Zahlavi  dw        258h                     ; velikost z�hlav� souboru
AdrSekce dw        1d8h                     ; adresa sekc� melodie

BuffId   dd        0                        ; buffer identifik�toru souboru

; ------ texty

UvTxt    db        'SAVESAM V1.0 - ukladani vzorku na disk; (c) Miroslav Nemecek',13,10,'$'
NoFile   db        'V aktivnim adresari nenalezen zadny soubor *.MOD !',13,10,'$'

Soubor   db        'SAMP0000'
Soubor0  db        '.SAM',0
OutIdn   dw        0                        ; identifik�tor souboru

All      db        '*.MOD',0                ; specifikace soubor�
         db        128 dup(?)               ; buffer pro �schovu specifikace

DTA      db        44 dup(?)                ; buffer DTA pro hled�n� soubor�

Code     ENDS

; �����������������������������������������������������������������������������
;
;                            Z�sobn�k
;
; �����������������������������������������������������������������������������

Zasobnik SEGMENT   STACK

         dw        2000h dup(?)

Zasobnik ENDS

; �����������������������������������������������������������������������������
;
;                           Segment konce programu
;
; �����������������������������������������������������������������������������

KonSeg   SEGMENT

KonSeg   ENDS

         END       Start


; *****************************************************************************
;
;          Zak¢dov n¡ programu .EXE a soubor– .APP pro FoxPro
;
; *****************************************************************************

; P©ep¡na‡e:
;    V20 ... pro FoxPro verze 2.0
;    V25 ... pro FoxPro verze 2.5
;    V26 ... pro FoxPro verze 2.6


BUFFSIZE EQU       2000h                    ; velikost datov‚ho bufferu
KlicN    EQU       257                      ; d‚lka kl¡‡e
MINEXT   EQU       1600                     ; po‘adovan  minim ln¡ pamˆŸ v KB

MaxFil   EQU       256                      ; max. po‡et otev©en˜ch soubor–

code     segment
         assume    cs:code,ds:code

         dw        SEG ExeSeg               ; offset zavadˆ‡e

; ------ zobrazen¡ £vodn¡ho textu

Start:   mov       dx,offset UvTxt
         call      DispTxt                  ; zobrazen¡ £vodn¡ho textu

; ------ inicializace gener toru masky

         xor       ax,ax
         mov       es,ax
         mov       dx,es:[46ch]             ; v˜choz¡ hodnota k¢du (n hodn )
         mov       cs:[ExeSumm],dx          ; v˜choz¡ hodnota masky k¢du
         push      cs
         pop       es

; ------ p©¡prava k dek¢dov n¡ zadan˜ch parametr–

         mov       si,81h                   ; za‡ tek textu p©¡kazov‚ho © dku
         mov       cl,ds:[si-1]             ; d‚lka textu
         and       cx,7fh                   ; d‚lka textu
         jcxz      Start1

; ------ konverze p©¡kazov‚ho © dku na velk  p¡smena

         push      si
         push      cx

         cld
Start01: lodsb
         cmp       al,"a"
         jb        Start011
         cmp       al,"z"
         ja        Start011
         sub       al,32
Start011:mov       ds:[si-1],al
         loop      Start01

         pop       cx
         pop       si

; ------ nalezen¡ za‡ tku hesla

         call      DekSpc                   ; nalezen¡ za‡ tku jm‚na souboru
         jc        Start1                   ; nen¡ nic zad no

; ------ test, jestli je heslo zad no

Start02: call      DekChr                   ; na‡ten¡ dal¨¡ho znaku
         jc        Start1
         cmp       al,'"'
         jne       Start05

; ------ zji¨tˆn¡ d‚lky hesla

         mov       di,si                    ; za‡ tek hesla
         xor       bx,bx                    ; ‡¡ta‡ d‚lky hesla
         dec       bx
Start03: inc       bx                       ; ‡¡ta‡ d‚lky hesla
         call      DekChr
         jc        Start1
         cmp       al,'"'
         jne       Start03
         mov       dx,offset HesloTxt
         cmp       bl,3                     ; minim ln¡ d‚lka hesla
         jb        Start2                   ; heslo p©¡li¨ kr tk‚

; ------ generov n¡ kl¡‡e

         push      cx
         push      si
         mov       cx,bx                    ; CX <- d‚lka hesla
         mov       dx,-1                    ; v˜choz¡ hodnota CRC
         mov       si,di                    ; adresa za‡ tku hesla
         call      CheckSum                 ; generov n¡ kl¡‡e
         mov       cs:[ExeSumm],dx          ; v˜choz¡ hodnota kl¡‡e
         pop       si
         pop       cx
         jmp       short Start06

; ------ n vrat znaku

Start05: dec       si
         inc       cx

; ------ dek¢dov n¡ jm‚na zdrojov‚ho souboru

Start06: push      cs
         pop       es
         mov       di,offset Soubor1        ; zdrojov˜ soubor
         call      DekFile                  ; dek¢dov n¡ jm‚na zdroj. souboru
         jnc       Start3                   ; soubor zad n OK
Start1:  mov       dx,offset HelpTxt        ; chyba zad n¡

; ------ chyba programu (chyba pamˆti nebo chyba zad n¡ souboru)

Start2:  call      DispTxt
         mov       ax,4c01h
         int       21h

; ------ rozli¨en¡ typu zdrojov‚ho souboru

Start3:  cmp       word ptr es:[di-1-2],"EX"
         jne       Start31
         cmp       word ptr es:[di-1-4],"E."
         je        Start34                  ; je EXE OK

Start31: mov       dx,offset VstupTxt
         cmp       word ptr es:[di-1-2],"PP"
         jne       Start2
         cmp       word ptr es:[di-1-4],"A."
         jne       Start2
         or        byte ptr cs:[ParIni],1   ; je soubor APP

; ------ dek¢dov n¡ jm‚na c¡lov‚ho souboru

Start34: mov       di,offset Soubor2        ; c¡lov˜ soubor
         call      DekFile                  ; dek¢dov n¡ jm‚na c¡l. souboru
         jc        Start1                   ; chyba - soubor nezad n
         push      cs
         pop       ds

; ------ otev©en¡ zdrojov‚ho souboru

         mov       ax,3d00h
         mov       dx,offset Soubor1
         int       21h                      ; otev©en¡ pro ‡ten¡
         mov       dx,offset ErrSoub1
         jc        Start2                   ; chyba
         mov       ds:[Ident1],ax

; ------ vytvo©en¡ c¡lov‚ho souboru

         mov       ah,3ch
         xor       cx,cx
         mov       dx,offset Soubor2
         int       21h                      ; vytvo©en¡ c¡lov‚ho souboru
         mov       dx,offset ErrSoub2
         jc        Start2                   ; soubor nelze vytvo©it
         mov       ds:[Ident2],ax

; ------ sestaven¡ k¢dovac¡ho kl¡‡e

         mov       dx,ds:[ExeSumm]
         push      ds
         pop       es
         mov       di,offset Klic           ; k¢dovac¡ kl¡‡
         mov       bx,KlicN                 ; d‚lka k¢dovac¡ho kl¡‡e
         mov       cx,offset(CheckSm9-CheckSum) ; d‚lka vzoru ke generaci masky

; ------ v˜po‡et k¢dovac¡ho kl¡‡e

Start4:  mov       si,offset CheckSum       ; data ke generov n¡ masky
         call      CheckSum                 ; kontroln¡ sou‡et kl¡‡e
         mov       ds:[di],dl               ; ni‘¨¡ bajt kontroln¡ho sou‡tu
         inc       di                       ; zv˜¨en¡ ukl dac¡ adresy v kl¡‡i
         dec       bx                       ; ‡¡ta‡ d‚lky kl¡‡e
         jnz       Start4                   ; dal¨¡ bajt kl¡‡e

; ------ na‡ten¡ za‡ tku zdrojov‚ho souboru

         test      byte ptr ds:[ParIni],1   ; je soubor APP ?
         jnz       Start6                   ; je soubor APP

         mov       bx,ds:[Ident1]
         mov       dx,offset Buffer
         mov       ah,3fh
         mov       cx,6
         int       21h                      ; na‡ten¡ za‡ tku souboru

; ------ nastaven¡ ukazatele ve zdrojov‚m souboru

         mov       dx,word ptr ds:[Buffer+2]; d‚lka posledn¡ str nky programu
         mov       cx,word ptr ds:[Buffer+4]; po‡et str nek 512 B
         or        dx,dx                    ; jsou data v posledn¡ str nce ?
         jz        Start5                   ; nejsou data
         dec       cx                       ; oprava po‡tu str nek
Start5:  shl       cx,1                     ; p©evod na str nky 256 B
         add       dh,cl
         mov       cl,ch
         mov       ch,0                     ; CX:DX=offset v souboru
         mov       ax,4200h
         int       21h                      ; nastaven¡ ukazatele v souboru

; ------ stanoven¡ d‚lky zavadˆ‡e a f ze dek¢dov n¡

         mov       cx,ds:[ExePag0]          ; d‚lka posledn¡ str nky programu
         mov       dx,ds:[ExePage]          ; po‡et str nek 512 B
         jcxz      Start52                  ; nejsou data posledn¡ str nky
         dec       dx                       ; oprava po‡tu str nek
Start52: shl       dx,1                     ; p©evod na str nky 256 B
         add       ch,dl
         mov       ds:[TopFaze],cx          ; f ze pro dek¢dov n¡

; ------ z pis programu zavadˆ‡e do v˜stupn¡ho souboru

         mov       dx,offset Code:ExeBeg       ; za‡ tek programu zavadˆ‡e
         mov       ah,40h
         mov       bx,ds:[Ident2]
         int       21h                      ; z pis programu zavadˆ‡e

; ------ na‡ten¡ bloku dat ze vstupn¡ho souboru

Start6:  mov       dx,offset Buffer         ; datov˜ buffer bloku
         mov       cx,BUFFSIZE              ; velikost bufferu
         mov       ah,3fh
         mov       bx,ds:[Ident1]
         int       21h                      ; na‡ten¡ bloku dat ze souboru
         jnc       Start7                   ; operace OK
         mov       dx,offset ErrRead        ; text - chyba ‡ten¡
         jmp       Start2                   ; n vrat s chybou
Start7:  mov       cx,ax                    ; po‡et na‡ten˜ch dat
         jcxz      Start9                   ; konec dat

; ------ zak¢dov n¡ bloku dat

         mov       di,dx                    ; adresa bufferu
         mov       bx,ds:[Ident2]           ; v˜stupn¡ soubor
         call      AdrId                    ; adresa (f ze) v souboru
         call      Kod                      ; zak¢dov n¡ dat p©ed z pisem

; ------ z pis bloku dat

         mov       bx,ds:[Ident2]           ; v˜stupn¡ soubor
         mov       ah,40h
         mov       dx,offset Buffer
         int       21h                      ; z pis dat do souboru
         jc        ErrWrit
         cmp       ax,cx
         jne       ErrWrit
         jmp       short Start6             ; dal¨¡ blok dat

; ------ zav©en¡ EXE soubor–

Start9:  mov       bx,ds:[Ident1]
         mov       ah,3eh
         int       21h
         mov       bx,ds:[Ident2]
         mov       ah,3eh
         int       21h

; ------ konec programu

         mov       ax,4c00h
         int       21h

; ------ chyba z pisu na v˜stup

ErrWrit: mov       dx,offset ErrWrite
ErrWrit2:jmp       Start2

; -----------------------------------------------------------------------------
;        zak¢dov n¡ dat ES:DI/CX p©ed z pisem, f ze BL
; -----------------------------------------------------------------------------
; zni‡en‚ registry: BX
; -----------------------------------------------------------------------------

Kod      PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      dx
         push      si

         mov       si,offset Klic           ; k¢dovac¡ kl¡‡
         xor       bh,bh                    ; BH <- 0 vy¨¨¡ bajt f ze
         jcxz      Kod4
         mov       dx,cx                    ; po‡et bajt–
         cld                                ; smˆr nahoru

; ------ zak¢dov n¡ dat

Kod1:    mov       cx,ds:[si+bx]            ; vzorek kl¡‡e
         mov       al,ds:[di]               ; vzorek dat
         and       cl,7                     ; omezen¡ po‡tu rotac¡
         rol       al,cl                    ; rotace vlevo
         xor       al,ch                    ; maskov n¡ vzorkem dat
         stosb                              ; ulo‘en¡ zak¢dovan˜ch dat
         inc       bl                       ; zv˜¨en¡ f ze v tabulce kl¡‡e
         dec       dx                       ; sn¡‘en¡ ‡¡ta‡e bajt–
         jnz       Kod1                     ; zak¢dov n¡ dal¨¡ho bajtu

; ------ n vrat registr–

Kod4:    pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

Kod      ENDP

; -----------------------------------------------------------------------------
;        poskytnut¡ f ze BL identifik toru BX
; -----------------------------------------------------------------------------

AdrId    PROC      NEAR

         push      ax
         push      cx
         push      dx

         mov       ax,4201h
         xor       cx,cx
         xor       dx,dx
         int       21h                      ; poskytnut¡ ukazatele souboru
         test      byte ptr ds:[ParIni],1   ; je APP ?
         jnz       AdrId2                   ; je APP

         sub       ax,ds:[TopFaze]          ; ode‡ten¡ po‡ te‡n¡ f ze souboru
AdrId2:  mov       bl,al                    ; f ze souboru

         pop       dx
         pop       cx
         pop       ax
         ret

AdrId    ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ textu CS:DX
; -----------------------------------------------------------------------------

DispTxt  PROC      NEAR

         push      ds
         push      ax
         push      cs
         pop       ds
         mov       ah,9
         int       21h
         pop       ax
         pop       ds
         ret

DispTxt  ENDP

; *****************************************************************************
;                       dek¢dov n¡ jm‚na souboru
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=ukazatel p©¡kazov‚ho © dku
;        ES:DI=buffer k ulo‘en¡ jm‚na souboru
;        CX=po‡et zbyl˜ch znak– p©¡kazov‚ho © dku
; VSTUP:CY=jm‚no nen¡ zad no
;        ES:DI=adresa konce jm‚na souboru (ukazuje za koncovou 0)
; *****************************************************************************

DekFile  PROC      NEAR

; ------ nalezen¡ za‡ tku jm‚na

         call      DekSpc                   ; nalezen¡ za‡ tku jm‚na souboru
         jc        DekFile9                 ; nen¡ nic zad no

; ------ p©enos jm‚na a‘ po oddˆlova‡

DekFile1:call      DekChr                   ; na‡ten¡ dal¨¡ho znaku jm‚na
         jc        DekFile8                 ; nen¡ dal¨¡ znak jm‚na souboru
         je        DekFile8                 ; je oddˆlova‡ - konec jm‚na
         cld
         stosb                              ; ulo‘en¡ znaku jm‚na
         jmp       short DekFile1           ; dek¢dov n¡ dal¨¡ho jm‚na souboru

DekFile8:clc                                ; p©¡znak jm‚na souboru OK
DekFile9:cld
         mov       al,0
         stosb                              ; ulo‘en¡ koncov‚ 0 jm‚na
         ret

DekFile  ENDP

; *****************************************************************************
;                   p©esko‡en¡ oddˆlova‡– v textu
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=ukazatel p©¡kazov‚ho © dku
;        CX=po‡et zbyl˜ch znak– p©¡kazov‚ho © dku
; VSTUP:CY=nen¡ dal¨¡ znak
;        AL=p©ichystan˜ dal¨¡ znak
; *****************************************************************************

DekSpc   PROC      NEAR

DekSpc1: call      DekChr                   ; na‡ten¡ znaku
         jc        DekSpc2                  ; nen¡ dal¨¡ znak
         je        DekSpc1                  ; je oddˆlova‡ - dal¨¡ znak
         dec       si                       ; n vrat posledn¡ho znaku
         inc       cx                       ; n vrat ‡¡ta‡e znak–
DekSpc2: ret

DekSpc   ENDP

; *****************************************************************************
;                  Na‡ten¡ jednoho znaku z p©¡kazov‚ho © dku
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=ukazatel p©¡kazov‚ho © dku
;        CX=po‡et zbyl˜ch znak– p©¡kazov‚ho © dku
; VSTUP:AL=znak z p©¡kazov‚ho © dku
;        ZY=je to oddˆlova‡
;        CY=nen¡ dal¨¡ znak
; *****************************************************************************

DekChr   PROC      NEAR

         stc
         jcxz      DekChr9                  ; nen¡ dal¨¡ znak
         cld
         lodsb                              ; na‡ten¡ znaku
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e znak–
         cmp       al,9                     ; tabel tor ?
         je        DekChr9                  ; oddˆlova‡ tabel tor
         cmp       al,","                   ; ‡ rka ?
         je        DekChr9                  ; oddˆlova‡ ‡ rka
         cmp       al,";"
         je        DekChr9                  ; oddˆlovac¡ st©edn¡k
         cmp       al," "                   ; mezera (nebo konec © dku) ?

DekChr9: ret

DekChr   ENDP

; *****************************************************************************
;        Kontroln¡ sou‡et CRC bloku dat - NEM‰NIT, z procedury se generuje kl¡‡
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=za‡ tek bloku dat
;        CX=po‡et bajt–
;        DX=vstupn¡ hodnota kontroln¡ho sou‡tu
; VSTUP:DX=v˜stupn¡ hodnota kontroln¡ho sou‡tu
; *****************************************************************************

CheckSum PROC      NEAR

         push      ax
         push      cx
         push      di
         jcxz      CheckSm2                 ; nejsou ‘ dn  data
         mov       di,cx                    ; po‡et bajt– pro kontroln¡ sou‡et
         cld                                ; smˆr nahoru

CheckSm1:lodsb                              ; a = fgetc(fp);
         xor       al,dh                    ; d = a ^= d;
         mov       dh,al
         mov       cl,4
         shr       al,cl                    ; a >>= 4;
         xor       al,dh                    ; d = a ^= d;
         mov       dh,al
         mov       cl,3
         ror       al,cl                    ; a = (a >> 3) | (a << 5);
         mov       ch,al                    ; f = a;
         and       al,1fh                   ; a &= 0x1f;
         xor       al,dl                    ; e = a ^= e;
         mov       dl,al
         mov       al,ch                    ; a = f;
         ror       al,1                     ; a = (a >> 1) | (a << 7);
         and       al,0f0h                  ; a &= 0xf0;
         xor       al,dl                    ; e = a ^= e;
         mov       dl,al
         mov       al,ch                    ; a = f & 0xe0;
         and       al,0e0h
         xor       al,dh                    ; a ^= d;
         mov       dh,dl                    ; d = e;
         mov       dl,al                    ; e = a;

         dec       di
         jnz       CheckSm1                 ; dal¨¡ bajt

CheckSm2:pop       di
         pop       cx
         pop       ax
         ret

CheckSm9 label     near

CheckSum ENDP

; *****************************************************************************
;
;                             Data
;
; *****************************************************************************

TopFaze  dw        offset(LoadEnd-LoadBeg) + 32 ; po‡ tek dat v souboru

ParIni   db        0                        ; parametry pro inicializaci
                                            ;    bit 0: 1=je soubor APP

Ident1   dw        0                        ; identifik tor zdrojov‚ho souboru
Ident2   dw        0                        ; identifik tor c¡lov‚ho souboru

Soubor1  db        128 dup(0)               ; jm‚no souboru 1 (zdrojov˜)
Soubor2  db        128 dup(0)               ; jm‚no souboru 2 (c¡lov˜)

IfDef    V20
UvTxt    db        'FOXKOD20 V2.10 - uzamykani programu FoxPro 2.0; (c) Miroslav Nemecek',13,10,'$'
EndIf

IfDef    V25
UvTxt    db        'FOXKOD25 V2.10 - uzamykani programu FoxPro 2.5; (c) Miroslav Nemecek',13,10,'$'
EndIf

IfDef    V26
UvTxt    db        'FOXKOD26 V2.10 - uzamykani programu FoxPro 2.6; (c) Miroslav Nemecek',13,10,'$'
EndIf

HelpTxt  db        'Zadejte: ["heslo"] vstupni_soubor vystupni_soubor',13,10,'$'
HesloTxt db        'Heslo musi mit delku minimalne 3 znaky !',13,10,'$'
VstupTxt db        'Vstupni soubor musi byt typu EXE nebo APP !',13,10,'$'
ErrSoub1 db        'Chybne zadani vstupniho souboru !',13,10,'$'
ErrSoub2 db        'Chybne zadani vystupniho souboru !',13,10,'$'
ErrRead  db        'Chyba cteni ze vstupniho souboru !',13,10,'$'
ErrWrite db        'Chyba zapisu do vystupniho souboru !',13,10,'$'

Klic     db        KlicN dup(0)             ; k¢dovac¡ kl¡‡

Buffer   db        BUFFSIZE dup(0)          ; datov˜ buffer

code     ends

; *****************************************************************************
;
;                             z sobn¡k
;
; *****************************************************************************

zasob    segment   stack

         dw        200h dup(?)

zasob    ends

; *****************************************************************************
;
;                        Z hlav¡ programu zavadˆ‡e
;
;    n sleduj¡c¡ ‡ st se m–‘e cel  nahradit zak¢dovanou verz¡ zavadˆ‡e
;
; *****************************************************************************

ExeSeg   SEGMENT

ExeBeg   label     byte
         db        'MZ'                     ; (0) identifik tor programu
ExePag0  dw        (offset(LoadEnd-LoadBeg) + 32 ) AND 1ffh ; d‚lka posledn¡ str nky
ExePage  dw        (offset(LoadEnd-LoadBeg) + 32 + 1ffh)/200h ; po‡et str nek 512 B
         dw        0                        ; (6) po‡et polo‘ek relok. tabulky
         dw        2                        ; (8) velikost z hlav¡ v 16 B
         dw        (offset(LoadEnd-LoadEnd)+100h)/16 ; (0ah) minimum pamˆti
         dw        0ffffh                   ; (0ch) maximum pamˆti
         dw        0                        ; (0eh) registr SS
         dw        offset(LoadZas-LoadBeg)  ; (10h) registr SP
ExeSumm  dw        0                        ; (12h) kontroln¡ sou‡et
         dw        offset(LStart-LoadBeg)   ; (14h) startovac¡ adresa IP
         dw        0                        ; (16h) registr CS
         dw        1ch                      ; (18h) 1. relok. polo‘ka
         dw        0                        ; (1ah) ‡¡slo OVL
         dd        0                        ; (1ch) 1. relok. polo‘ka
ExeEnd   label     byte

ExeSeg   ENDS

; *****************************************************************************
;
;                               Zavadˆ‡
;
; *****************************************************************************
;þ
Load     SEGMENT
         ASSUME    cs:Load,ds:Load

Maz2Beg  label     byte                     ; za‡ tek maz n¡

LoadBeg  label     byte

; ------ inicializace segment–

LStart:  sti
         push      cs
         pop       ds
         mov       ds:[LSegPSP],es          ; £schova segmentu PSP

; ------ kontrola kompatibility syst‚mu

         push      ds
         xor       bx,bx                    ; p©ednastaven¡ BX <- 0
         mov       ah,51h
         int       21h                      ; poskytnut¡ aktivn¡ho PSP
         pop       ds
         cmp       bx,ds:[LSegPSP]          ; je to platn  adresa PSP ?
         je        LStart02                 ; je to kompatibiln¡ syst‚m OK
         and       byte ptr ds:[LParam],not 1 ; p©¡znak nekompatibiln¡ho syst‚mu

; ------ kontrola verze syst‚mu

LStart02:mov       ah,30h
         int       21h                      ; poskytnut¡ verze syst‚mu
         cmp       al,3                     ; je verze alespo¤ 3.00 ?
         jae       LStart1                  ; verze syst‚mu je OK

; ------ chyba verze syst‚mu

         mov       dx,offset VerzeTxt
LChyba:  push      cs
         pop       ds
         mov       ah,9
         int       21h
         mov       ax,4cfeh
         int       21h

; ------ nalezen¡ jm‚na programu v prost©ed¡

LStart1: mov       ds,ds:[LSegPSP]
         mov       ds,ds:[2ch]              ; segment prost©ed¡
         push      cs
         pop       es
         xor       si,si                    ; po‡ tek prost©ed¡
         cld
LStart2: inc       si
         cmp       word ptr ds:[si-1],0
         jne       LStart2                  ; nalezen¡ konce prost©ed¡
         add       si,3                     ; za‡ tek jm‚na programu

; ------ stanoven¡ po‡ te‡n¡ f ze dat

         push      ds
         mov       dx,si                    ; jm‚no programu
         mov       ax,3d00h
         int       21h                      ; otev©en¡ souboru pro ‡ten¡
         jc        LStart27                 ; chyba - nelze otev©¡t
         push      cs
         pop       ds
         mov       bx,ax                    ; identifik tor
         mov       dx,offset LExeBuff       ; buffer k na‡ten¡ z hlav¡
         mov       cx,32
         mov       ah,3fh
         int       21h                      ; na‡ten¡ z hlav¡ programu
         mov       ax,word ptr ds:[LExeBuff+2] ; d‚lka posledn¡ str nky
         mov       dx,word ptr ds:[LExeBuff+4] ; po‡et str nek
         or        ax,ax
         jz        LStart25
         dec       dx
LStart25:shl       dx,1                     ; po‡et str nek 256 B
         add       ah,dl
         mov       ds:[LTopFaze],ax         ; po‡ te‡n¡ f ze
         mov       ah,3eh
         int       21h                      ; uzav©en¡ souboru
LStart27:pop       ds

; ------ p©enos jm‚na programu do bufferu

         mov       di,offset LPrikaz+1      ; buffer p©¡kaz. © dku
         mov       al," "
         cld
         stosb                              ; £vodn¡ mezera
         mov       cx,7eh                   ; maxim ln¡ d‚lka textu
LStart3: lodsb
         cmp       al,0
         je        LStart32
         cmp       al,"a"
         jb        LStart31
         cmp       al,"z"
         ja        LStart31
         sub       al,20h
LStart31:stosb
         loop      LStart3

; ------ p©id n¡ p©¡kazov‚ho © dku

LStart32:mov       dx,di
         sub       dx,offset LPrikaz+2      ; d‚lka jm‚na programu
         mov       cs:[LJmeno],dx           ; jm‚no programu
         push      cs
         pop       es
         mov       ds,cs:[LSegPSP]          ; segment PSP
         mov       si,81h                   ; p©¡kazov˜ © dek
         cmp       cl,ds:[si-1]             ; je p©¡kaz. © dek krat¨¡ ?
         jbe       LStart4                  ; je del¨¡
         mov       cl,ds:[si-1]             ; omezen¡ d‚lky textu
LStart4: rep       movsb                    ; p©enos textu
         mov       byte ptr es:[di],0dh     ; ozna‡en¡ konce textu
         sub       di,offset LPrikaz+1      ; d‚lka textu
         mov       ax,di                    ; d‚lka textu
         push      cs
         pop       ds
         mov       ds:[LPrikaz],al          ; d‚lka textu

; ------ zmen¨en¡ bloku programu na minimum

         mov       es,ds:[LSegPSP]          ; segment PSP
         mov       bx,(offset(LoadEnd-LoadBeg)+10fh)/16 ; konec programu
         mov       ah,4ah
         int       21h

; ------ ur‡en¡, zda se bude nejd©¡ve hledat FOXPROX.ESL

         call      LTestX                   ; test roz¨¡©en‚ pamˆti
         jc        LStart5                  ; nen¡ roz¨¡©en  pamˆŸ
         or        byte ptr ds:[LParam],10h ; p©¡znak roz¨¡©en‚ pamˆti

; ------ hled n¡ souboru FOXPROX.ESL a potom FOXPRO.ESL na disku

         mov       si,offset LSoub2         ; soubor FOXPROX.ESL
         call      L0Hled                   ; nalezen¡ souboru na disku
         jnc       LStart7                  ; soubor nalezen OK
         mov       si,offset LSoub1         ; soubor FOXPRO.ESL
         call      L0Hled                   ; hled n¡ souboru na disku
         jnc       LStart7                  ; soubor nalezen OK
         jmp       short LStart6            ; chyba - soubor nenalezen

; ------ hled n¡ souboru FOXPRO.ESL a potom FOXPROX.ESL na disku

LStart5: mov       si,offset LSoub1         ; soubor FOXPRO.ESL
         call      L0Hled                   ; nalezen¡ souboru na disku
         jnc       LStart7                  ; soubor nalezen OK
         mov       si,offset LSoub2         ; soubor FOXPROX.ESL
         call      L0Hled                   ; hled n¡ souboru na disku
         jnc       LStart7                  ; soubor nalezen OK

; ------ chyba - ‘ dn˜ program FOXPRO nenalezen

LStart6: mov       dx,offset NoFox          ; text - nen¡ FOXPRO
         jmp       LChyba                   ; chyba - nen¡ FOXPRO

; ------ generov n¡ masky dek¢dovac¡ho kl¡‡e

LStart7: push      cs
         pop       ds
         push      cs
         pop       es
         mov       di,offset LKlic          ; dek¢dovac¡ kl¡‡
         mov       bx,KlicN                 ; d‚lka k¢dovac¡ho kl¡‡e
         mov       cx,offset(LChckSm9-LChckSum) ; d‚lka vzoru ke generaci masky
         mov       dx,word ptr ds:[LExeBuff+12h] ; v˜choz¡ hodnota masky

; ------ v˜po‡et k¢dovac¡ho kl¡‡e

LStart72:mov       si,offset LChckSum       ; data ke generov n¡ masky
         call      LChckSum                 ; kontroln¡ sou‡et kl¡‡e
         mov       ds:[di],dl               ; ni‘¨¡ bajt kontroln¡ho sou‡tu
         inc       di                       ; zv˜¨en¡ ukl dac¡ adresy v kl¡‡i
         dec       bx                       ; ‡¡ta‡ d‚lky kl¡‡e
         jnz       LStart72                 ; dal¨¡ bajt kl¡‡e

; ------ vymaz n¡ £vodn¡ ‡ sti programu

         mov       di,offset Maz1Beg
         mov       si,offset Maz2End+12
         mov       cx,offset(Maz1End-Maz1Beg)
         cld
         rep       movsb

         mov       di,offset Maz2Beg
Maz2End  label     byte
         mov       cx,offset(Maz2End-Maz2Beg-1)
         rep       movsb

; ------ soubor nalezen - p©¡prava k jeho startu

         push      cs
         pop       ds
         mov       bx,offset tab

; ------ nastaven¡ ukazatele prost©ed¡

         mov       es,ds:[LSegPSP]          ; segment PSP
         mov       ax,es:[2ch]              ; segment prost©ed¡
         mov       ds:[bx],ax               ; segment prost©ed¡

; ------ ukazatel p©¡kazov‚ho © dku

         mov       word ptr ds:[bx+2],offset LPrikaz ; p©¡kazov˜ © dek
         mov       word ptr ds:[bx+4],ds    ; segment p©¡kazov‚ho © dku

; ------ p©¡prava FCB1

         push      cs
         pop       es
         mov       di,offset LFCB1          ; FCB 1
         mov       si,offset LPrikaz+1      ; text k rozboru
         mov       ds:[bx+6],di
         mov       ds:[bx+8],es
         mov       ax,2901h
         int       21h                      ; rozbor p©¡kazov‚ho © dku

; ------ p©¡prava FCB2

         mov       di,offset LFCB2          ; FCB 2
         mov       si,offset LPrikaz+1      ; text k zozboru
         mov       ds:[bx+10],di
         mov       ds:[bx+12],es
         mov       ax,2901h
         int       21h                      ; rozbor p©¡kazov‚ho © dku

; ------ £schova adresy INT 21h

         mov       ax,3521h
         int       21h                      ; poskytnut¡ adresy INT 21h
         mov       word ptr ds:[LOld21],bx  ; offset INT 21h
         mov       word ptr ds:[LOld21+2],es ; segment INT 21h

; ------ instalace p©eru¨en¡ INT 23h

         mov       dx,offset LInt23         ; obsluha p©eru¨en¡ INT 23h
         mov       ax,2523h
         int       21h                      ; instalace obsluhy INT 23h

; ------ instalace obsluhy INT 21h

         mov       dx,offset LInt21
         mov       ax,2521h
         int       21h                      ; instalace obsluhy INT 21h

; ------ test p©eru¨en¡ programu Ctrl-Break

         mov       ah,0bh
         int       21h                      ; test p©eru¨en¡ programu

; ------ start programu

         push      cs
         pop       es
         mov       dx,offset LSoubor        ; nalezen˜ soubor
         mov       bx,offset tab
         mov       ax,4b00h
         int       21h
         jmp       short LInt231

; ------ m¡sto p©eru¨en¡ INT 23h - inicializace z sobn¡ku

LInt23:  stc                                ; p©¡znak p©eru¨en¡ INT 23h
LInt231: mov       ax,cs
         mov       ss,ax
         mov       sp,offset LoadZas        ; z sobn¡k

; ------ zji¨tˆn¡ n vratov‚ho k¢du programu

         mov       al,0feh                  ; n vratov˜ k¢d p©i chybˆ
         jc        LInst233                 ; byla chyba
         mov       ah,4dh
         int       21h                      ; poskytnut¡ n vratov‚ho k¢du progr.

; ------ n vrat p©eru¨en¡ INT 21h

LInst233:push      ax
         lds       dx,cs:[LOld21]           ; p–vodn¡ adresa INT 21h
         mov       ax,2521h
         int       21h                      ; n vrat adresy INT 21h
         pop       ax

; ------ n vrat z programu (s n vratov˜m k¢dem programu)

         mov       ah,4ch
         int       21h


LOld21   dd        0                        ; p–vodn¡ adresa INT 12h

; -----------------------------------------------------------------------------
;        obsluha INT 21h
; -----------------------------------------------------------------------------

LInt21   PROC      FAR
;þ
; ------ kontrola funkce

         pushf
         cmp       ah,3dh                   ; otev©en¡ souboru ?
         je        LInt211                  ; je otev©en¡ souboru
         cmp       ah,6ch
         je        LInt2112                 ; otev©en¡ souboru funkc¡ 6ch
         cmp       ah,3fh                   ; ‡ten¡ ze souboru ?
         jne       LInt2100
         jmp       LInt212                  ; je ‡ten¡ ze souboru

; ------ uzav©en¡ .EXE souboru

LInt2100:cmp       ah,3eh                   ; uzav©en¡ souboru ?
         jne       LInt2108                 ; nen¡ uzav©en¡ souboru

         cmp       bx,cs:[LIdent]
         jne       LInt2101                 ; nen¡ to tento soubor
         call      LTestPSP                 ; test PSP
         jne       LInt2108                 ; nen¡ hlavn¡ program
         mov       word ptr cs:[LIdent],-1  ; zru¨en¡ identifik toru souboru
         jmp       short LInt2108

; ------ uzav©en¡ .APP souboru

LInt2101:cmp       bx,MaxFil
         jnb       LInt2108                 ; je p©ekro‡en max. po‡et otev. soubor–
         mov       cs:[JeApp[bx]],0         ; zru¨en¡ p©¡znaku otev©en¡

; ------ pokra‡ov n¡ p–vodn¡ funkc¡

LInt2108:popf
LInt210: jmp       dword ptr cs:[LOld21]    ; p–vodn¡ obsluha INT 21h

; ------ otev©en¡ souboru funkc¡ 6ch

LInt2112:cmp       word ptr cs:[LIdent],-1  ; je soubor ji‘ otev©en ?
         jne       LIn21142                 ; soubor je ji‘ otev©en
         xchg      si,dx                    ; DX <- jm‚no souboru
         call      LSrovnej                 ; porovn n¡ jm‚na souboru
         xchg      si,dx                    ; SI <- n vrat jm‚na souboru
         jmp       short LInt2113

; ------ otev©en¡ souboru - kontrola, zda jde o spr vn˜ soubor

LInt211: cmp       word ptr cs:[LIdent],-1  ; je soubor ji‘ otev©en ?
         jne       LInt2115                 ; soubor je ji‘ otev©en
         call      LSrovnej                 ; porovn n¡ jm‚na souboru
LInt2113:jne       LInt2115                 ; nen¡ to tento program
         call      LTestPSP                 ; test PSP
         jne       LInt2108                 ; nen¡ hlavn¡ program

; ------ je to hledan˜ soubor - otev©en¡ souboru
                                            ; zde je FLAG ji‘ v z sobn¡ku
         call      dword ptr cs:[LOld21]    ; otev©en¡ souboru

; ------ £schova identifik toru souboru

         jc        LInt2114                 ; chyba - soubor nebyl otev©en
         mov       cs:[LIdent],ax           ; £schova identifik toru
LInt2114:jmp       LInt21R                  ; n vrat v˜sledku operace

LIn21142:xchg      si,dx                    ; DX <- jm‚no souboru
         call      LJeAPP
         xchg      si,dx                    ; SI <- n vrat jm‚na souboru
         jmp       short LInt2116

; ------ kontrola zda je to *.APP

LInt2115:call      LJeAPP
LInt2116:jne       LInt2108                 ; nen¡ to .APP

; ------ je to soubor .APP - otev©en¡ souboru
                                            ; zde je FLAG ji‘ v z sobn¡ku
         call      dword ptr cs:[LOld21]    ; otev©en¡ souboru

; ------ nastaven¡ p©¡znaku .APP souboru

         jc        LInt2114                 ; chyba - soubor nebyl otev©en
         cmp       ax,MaxFil
         jnb       LInt21R                  ; je p©ekro‡en max. po‡et otev©en˜ch soubor–
         push      bx
         mov       bx,ax
         mov       cs:[JeAPP[bx]],1
         pop       bx
         clc
         jmp       short LInt21R            ; n vrat v˜sledku operace

; ------ ‡ten¡ ze souboru - kontrola identifik toru

LInt212: and       byte ptr cs:[LParam],not 2 ; nen¡ APP
         cmp       bx,cs:[LIdent]           ; souhlas¡ identifik tor ?
         je        LInt2121                 ; souhlas¡ identifik tor

; ------ kontrola zda je .APP

         cmp       bx,MaxFil
         jae       LInt2108
         cmp       cs:[JeAPP[bx]],1
         jne       LInt2108
         or        byte ptr cs:[LParam],2   ; je APP

LInt2121:call      LTestPSP                 ; souhlas¡ PSP ?
         jne       LInt2116                 ; nesouhlas¡ PSP

; ------ £schova f ze ukazatele v souboru

         push      bx
         push      bp
         call      LAdrId                   ; adresa (f ze) v souboru

         mov       word ptr cs:[LFaze],bx   ; £schova f ze LOW
         mov       word ptr cs:[LFaze+2],bp ; £schova f ze HIGH
         pop       bp
         pop       bx
                                            ; v z sobn¡ku je FLAG
         call      dword ptr cs:[LOld21]    ; ‡ten¡ ze souboru
         jc        LInt21R                  ; chyba ‡ten¡

         pushf
         push      bx
         push      cx
         push      di
         push      bp
         push      es

         push      ds
         pop       es                       ; segment adresy bufferu
         mov       di,dx                    ; offset adresy bufferu
         mov       cx,ax                    ; d‚lka na‡ten˜ch dat
         mov       bx,word ptr cs:[LFaze]   ; f ze dat v souboru
         mov       bp,word ptr cs:[LFaze+2] ; f ze dat v souboru HIGH
         call      LDekod                   ; dek¢dov n¡ dat po ‡ten¡

         pop       es
         pop       bp
         pop       di
         pop       cx
         pop       bx
         popf

; ------ n vrat z operace INT 21h s navr cen¡m stavu

LInt21R:                                    ; SS:[BP+8]=Flag
                                            ; SS:[BP+6]=CS
                                            ; SS:[BP+4]=IP
         push      bp                       ; SS:[BP+2]=BP
         push      ax                       ; SS:[BP+0]=AX
         mov       bp,sp                    ; ukazatel dat v z sobn¡ku
         pushf                              ; navr cen˜ registr p©¡znak–
         pop       ax                       ; AX <- Flag
         mov       ss:[bp+8],al             ; navr cen‚ p©¡znaky
         pop       ax
         pop       bp
         iret

LInt21   ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ dat ES:DI/CX po ‡ten¡, f ze BP:BX
; -----------------------------------------------------------------------------

LDeKod   PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      dx
         push      si
         push      ds
         push      cs
         pop       ds

         mov       si,offset LKlic          ; k¢dovac¡ kl¡‡
         jcxz      LDekod2                  ; nejsou ‘ dn  data
         mov       dx,cx                    ; po‡et bajt–
         cld                                ; smˆr nahoru

; ------ dek¢dov n¡ dat

LDeKod1: mov       al,es:[di]               ; vzorek dat

         cmp       bp,-1
         je        LDekod12                 ; dek¢dov n¡ se neprov d¡

         push      bx
         mov       bh,0
         mov       cx,ds:[si+bx]            ; vzorek kl¡‡e
         pop       bx
         and       cl,7                     ; omezen¡ po‡tu rotac¡
         xor       al,ch                    ; odmaskov n¡ vzorku dat
         ror       al,cl                    ; rotace vpravo

LDekod12:stosb                              ; ulo‘en¡ dek¢dovan˜ch dat
         add       bx,1                     ; zv˜¨en¡ f ze v tabulce kl¡‡e
         adc       bp,0
         dec       dx                       ; sn¡‘en¡ ‡¡ta‡e bajt–
         jnz       LDeKod1                  ; dek¢dov n¡ dal¨¡ho bajtu dat

; ------ n vrat registr–

LDeKod2: pop       ds
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

LDeKod   ENDP

; -----------------------------------------------------------------------------
;        kontrola platnosti PSP programu (NZ=neplatn˜)
; -----------------------------------------------------------------------------

LTestPSP PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di

; ------ kontrola kompatibility syst‚mu

         test      byte ptr cs:[LParam],1   ; je kompatibiln¡ syst‚m ?
         jz        LTstPSP9                 ; nekompatibiln¡ syst‚m

; ------ poskytnut¡ aktivn¡ho PSP

         mov       ah,51h
         pushf
         call      dword ptr cs:[LOld21]    ; poskytnut¡ adresy aktivn¡ho PSP

; ------ prvn¡ inicializace PSP

         cmp       word ptr cs:[LFoxPSP],0  ; byl inicializov n ?
         jne       LTstPSP4                 ; byl ji‘ inicializov n
         mov       cs:[LFoxPSP],bx          ; £schova PSP
         jmp       short LTstPSP9           ; n vrat OK

; ------ kontrola PSP

LTstPSP4:cmp       cs:[LFoxPSP],bx          ; souhlas¡ PSP ?

; ------ n vrat registr–

LTstPSP9:pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

LTestPSP ENDP

; -----------------------------------------------------------------------------
;        porovn n¡ jm‚na souboru p©i operaci otev©en¡ (NZ=nen¡ shodn‚)
; -----------------------------------------------------------------------------

LSrovnej PROC      NEAR

         push      ax
         push      cx
         push      si
         push      di
         push      es

         mov       di,offset LPrikaz+2
         mov       si,dx
         push      cs
         pop       es
         mov       cx,cs:[LJmeno]
         cmp       cl,0ffh
         jcxz      LSrovn9

         cld

LSrovn1: lodsb
         cmp       al,"a"
         jb        LSrovn2
         cmp       al,"z"
         ja        LSrovn2
         sub       al,20h

LSrovn2: mov       ah,es:[di]
         inc       di
         cmp       ah,"a"
         jb        LSrovn3
         cmp       ah,"z"
         ja        LSrovn3
         sub       ah,20h

LSrovn3: cmp       al,ah
         loope     LSrovn1

LSrovn9: pop       es
         pop       di
         pop       si
         pop       cx
         pop       ax
         ret

LSrovnej ENDP

; -----------------------------------------------------------------------------
;        kontrola jm‚na, zda je .APP (NZ=nen¡ .APP)
; -----------------------------------------------------------------------------
; Vstup: DX - Adresa jm‚na
; -----------------------------------------------------------------------------

LJeAPP   PROC      NEAR

         push      ax
         push      si

         cld
         mov       si,dx
LJeAPP02:lodsb
         cmp       al,0
         jne       LJeAPP02

         sub       si,5
         cmp       si,dx
         ja        LJeAPP0
         cmp       al,-1                    ; Nastaven¡ NE
         jmp       short LJeAPP99

LJeAPP0: lodsb
         cmp       al,'.'
         jne       LJeAPP99

LJeAPP1: lodsb
         cmp       al,'a'
         je        LJeAPP1a
         cmp       al,'A'
         jne       LJeAPP99
LJeAPP1a:lodsb
         cmp       al,'p'
         je        LJeAPP1b
         cmp       al,'P'
         jne       LJeAPP99
LJeAPP1b:lodsb
         cmp       al,'p'
         je        LJeAPP99
         cmp       al,'P'

LJeApp99:pop       si
         pop       ax
         ret

LJeAPP   ENDP

; -----------------------------------------------------------------------------
;        poskytnut¡ f ze BP:BX identifik toru BX
; -----------------------------------------------------------------------------

LAdrId   PROC      NEAR

         push      ax
         push      cx
         push      dx

         mov       ax,4201h
         xor       cx,cx
         xor       dx,dx
         pushf
         call      dword ptr cs:[LOld21]    ; poskytnut¡ ukazatele souboru

         mov       bx,ax                    ; f ze
         mov       bp,dx

         test      byte ptr cs:[LParam],2
         jnz       LAdrId2                  ; je APP

         sub       bx,cs:[LTopFaze]         ; ode‡ten¡ po‡ te‡n¡ f ze
         sbb       bp,0                     ; p©enos

LAdrId2: pop       dx
         pop       cx
         pop       ax
         ret

LAdrId   ENDP

; *****************************************************************************
;
;                      za‡ tek maz n¡ po inicializaci
;
; *****************************************************************************

Maz1Beg  label     byte

; -----------------------------------------------------------------------------
;        nalezen¡ souboru DS:SI na disku (CY=nenalezen)
; -----------------------------------------------------------------------------

L0Hled   PROC      NEAR

; ------ hled n¡ souboru v aktivn¡m adres ©i

         push      cs
         pop       es
         mov       di,offset LSoubor        ; buffer k ulo‘en¡ jm‚na souboru
         mov       ds:[LSoubAdr],si         ; £schova jm‚na souboru
         call      LHled                    ; hled n¡ souboru v adres ©i
         jnc       L0Hled8                  ; soubor nalezen OK

; ------ nalezen¡ parametru PATH v prost©ed¡

         mov       ds,ds:[LSegPSP]          ; segment PSP
         mov       ds,ds:[2ch]              ; segment prost©ed¡
         xor       si,si                    ; ukazatel prost©ed¡
         cld
L0Hled2: cmp       byte ptr ds:[si],0       ; konec prost©ed¡ ?
         stc
         je        L0Hled8                  ; konec prost©ed¡ - chyba
         mov       ax,ds:[si]               ; 2 znaky z prost©ed¡
         and       ax,not 2020h             ; p©evod na velk  p¡smena
         cmp       ax,"AP"                  ; je parametr "PATH" ?
         jne       L0Hled3                  ; nen¡ PATH
         mov       ax,ds:[si+2]             ; dal¨¡ 2 znaky z prost©ed¡
         and       ax,not 2020h             ; p©evod na velk  p¡smena
         cmp       ax,"HT"                  ; je parametr "PATH" ?
         jne       L0Hled3                  ; nen¡ PATH
         cmp       byte ptr ds:[si+4],"="   ; oddˆlova‡ parametru ?
         je        L0Hled4                  ; parametr nalezen OK
L0Hled3: lodsb
         cmp       al,0
         jne       L0Hled3                  ; nalezen¡ konce parametru
         jmp       short L0Hled2            ; test dal¨¡ho parametru

; ------ p©¡prava k prohled v n¡ adres ©– PATH

L0Hled4: add       si,5                     ; za‡ tek textu ©etˆzc–
         push      cs
         pop       ds
         mov       ds:[LUkazPth],si         ; ukazatel parametr– PATH

; ------ prohled n¡ v¨ech cest z PATH

L0Hled5: call      LNextP                   ; p©¡prava dal¨¡ cesty (DI=konec)
         jc        L0Hled8                  ; nen¡ dal¨¡ cesta
         call      LHled                    ; test souboru
         jc        L0Hled5                  ; nenalezen - dal¨¡ hled n¡ souboru

L0Hled8: push      cs
         pop       ds
         ret

L0Hled   ENDP

; -----------------------------------------------------------------------------
;        hled n¡ souboru v adres ©i (DI=konec textu v bufferu jm‚na)
; -----------------------------------------------------------------------------

LHled    PROC      NEAR

; ------ p©id n¡ jm‚na souboru k cestˆ v bufferu

         cld
         push      cs
         pop       es
         mov       si,ds:[LSoubAdr]         ; adresa jm‚na hledan‚ho souboru
LHled1:  lodsb
         stosb
         cmp       al,0
         jne       LHled1

; ------ nastaven¡ adresy DTA

         mov       dx,offset LBufDTA
         mov       ah,1ah
         int       21h                      ; nastaven¡ adresy DTA

; ------ nalezen¡ souboru v adres ©i

         mov       dx,offset LSoubor
         xor       cx,cx
         mov       ah,4eh
         int       21h                      ; nalezen¡ souboru v adres ©i
         jc        LHled2                   ; byla chyba

         cmp       word ptr ds:[LBufDTA+1ch],5 ; minim ln¡ velikost 320 KB

LHled2:
         ret

LHled    ENDP

; -----------------------------------------------------------------------------
;        poskytnut¡ dal¨¡ cesty z parametru PATH (v˜stup: DI=adresa konce)
; -----------------------------------------------------------------------------

LNextP   PROC      NEAR

; ------ p©¡prava registr–

         push      ds
         mov       ds,cs:[LSegPSP]          ; segment PSP
         mov       ds,ds:[2ch]              ; segment prost©ed¡
         mov       si,cs:[LUkazPth]         ; ukazatel textu PATH

; ------ test, zda je ji‘ konec parametru

LNextP1: mov       al,ds:[si]               ; p©ipraven˜ znak
         cmp       al,9
         je        LNextP2                  ; tabel tor je povolen
         cmp       al," "
         jb        LNextP9                  ; je konec textu

; ------ nalezen¡ za‡ tku dal¨¡ho parametru

LNextP2: cmp       al,";"                   ; oddˆlova‡ ?
         je        LNextP3
         cmp       al," "
         ja        LNextP4                  ; je platn˜ znak
LNextP3: inc       si                       ; zv˜¨en¡ ukazatele textu
         jmp       short LNextP1            ; hled n¡ dal¨¡ho znaku

; ------ p©enos jednoho parametru

LNextP4: mov       cx,80h - 12              ; maxim ln¡ d‚lka textu
         mov       di,offset LSoubor        ; buffer jm‚na souboru
         cld
LNextP5: lodsb                              ; na‡ten¡ znaku textu
         cmp       al,";"
         je        LNextP6                  ; konec
         cmp       al," "
         jbe       LNextP6                  ; je oddˆlova‡
         stosb                              ; ulo‘en¡ platn‚ho znaku
         loop      LNextP5                  ; dal¨¡ znak textu

; ------ oprava konce textu adres ©e

LNextP6: mov       al,"\"
         cmp       es:[di-1],al             ; byl posledn¡ znak "\" ?
         je        LNextP7                  ; posledn¡ znak byl OK
         stosb                              ; ulo‘en¡ koncov‚ho "\"
LNextP7: dec       si
         mov       cs:[LUkazPth],si         ; nov  hodnota ukazatele parametru
         clc                                ; p©¡znak platn‚ho parametru

LNextP9: pop       ds
         ret

LNextP   ENDP

; -----------------------------------------------------------------------------
;        test, zda se pou‘ije verze pro roz¨¡©enou pamˆŸ (CY=nepou‘ije se)
; -----------------------------------------------------------------------------

LTestX   PROC      NEAR

; ------ test vhodnosti procesoru

         call      LTstCpu                  ; test procesoru
         jc        LTestX9                  ; nevhodn˜ procesor

; ------ test, zda je ovlada‡ chr nˆn‚ho m¢du DOS

         mov       ax,1687h
         int       2fh                      ; test instalace chr nˆn‚ho m¢du DOS
         or        ax,ax                    ; je nainstalov n ovlada‡ DOS ?
         stc
         jz        LTestX9                  ; chyba - je ovlada‡ chr n. m¢du DOS

; ------ test instalace roz¨¡©en‚ pamˆti EMS

         call      LTstEms                  ; test pamˆti EMS
         jnc       LTestX9                  ; pamˆŸ EMS je OK

; ------ test, zda m–‘e b˜t pamˆŸ XMS

         db        0fh,1,0e0h               ; instrukce SMSW AX
         and       ax,1
         stc
         jnz       LTestX9                  ; nem–‘e b˜t pamˆŸ XMS

; ------ test pamˆti XMS

         call      LTstXms                  ; test pamˆti XMS
         jnc       LTestX9                  ; pamˆŸ XMS je OK

; ------ test voln‚ roz¨¡©en‚ pamˆti BIOS

         call      LTstBio                  ; test pamˆti BIOS
LTestX9: ret

LTestX   ENDP

; -----------------------------------------------------------------------------
;        test vhodnosti procesoru
; -----------------------------------------------------------------------------

LTstCpu  PROC      NEAR

         pushf

; ------ test, zda je 80186 a ni‘¨¡ (bity 12 a‘ 15 registru p©¡znak– st le "1")

         xor       ax,ax
         push      ax
         popf
         pushf
         pop       ax
         and       ah,0f0h
         cmp       ah,0f0h
         je        LTstCpu8

; ------ test, zda je 80286 (bity 12 a‘ 15 registru p©¡znak– st le "0")

         mov       ax,0f000h
         push      ax
         popf
         pushf
         pop       ax
         and       ah,0f0h
         jz        LTstCpu8
         popf
         clc                                ; p©¡znak - 80386 nebo vy¨¨¡
         ret

LTstCpu8:popf
         stc                                ; p©¡znak - nevhodn˜ procesor
         ret

LTstCpu  ENDP

; -----------------------------------------------------------------------------
;        test pamˆti EMS
; -----------------------------------------------------------------------------

LTstEms  PROC      NEAR

; ------ zji¨tˆn¡ adresy ovlada‡e EMS

         mov       ax,3567h
         int       21h                      ; poskytnut¡ adresy INT 67h
         mov       ax,es                    ; segment INT 67h
         cmp       ax,70h
         jb        LTstEms8                 ; neplatn  adresa

; ------ test, zda je to ovlada‡ EMS

         mov       di,10                    ; za‡ tek identifik toru
         mov       si,offset LTxtEms
         mov       cx,8
         cld
         rep       cmpsb                    ; porovn n¡ z hlav¡
         jne       LTstEms8                 ; nen¡ ovlada‡ EMS

; ------ test stavu EMS

         mov       ah,40h
         int       67h                      ; test stavu EMS
         or        ah,ah                    ; je EMS ?
         jnz       LTstEms8                 ; nen¡ EMS

; ------ kontrola voln‚ pamˆti EMS

         mov       ah,42h
         int       67h                      ; poskytnut¡ voln‚ pamˆti EMS
         or        ah,ah                    ; je OK ?
         jnz       LtstEms8                 ; nen¡ OK
         cmp       bx,MINEXT/16             ; je dost voln‚ pamˆti ?
         jb        LTstEms8                 ; nen¡ voln  pamˆŸ

; ------ p©idˆlen¡ 1 str nky EMS

         mov       ah,43h
         mov       bx,1                     ; po‡et str nek k p©idˆlen¡
         int       67h                      ; p©idˆlen¡ 1 str nky EMS
         or        ah,ah                    ; je OK ?
         jnz       LTstEms8                 ; nen¡ OK

; ------ kontrola instalace VCPI

         push      dx
         mov       ax,0de00h
         int       67h                      ; test stavu VCPI
         pop       dx

; ------ uvolnˆn¡ p©idˆlen‚ str nky EMS

         push      ax                       ; £schova n vratov‚ho k¢du
         mov       ah,45h
         int       67h                      ; uvolnˆn¡ p©idˆlen‚ str nky EMS
         pop       ax
         or        ah,ah                    ; je VCPI nainstalov n ?
         jz        LTstEms9                 ; VCPI je nainstalov n OK

LTstEms8:stc
LTstEms9:ret

LTstEms  ENDP

; -----------------------------------------------------------------------------
;        test pamˆti XMS
; -----------------------------------------------------------------------------

LTstXms  PROC      NEAR

; ------ test instalace pamˆti XMS

         mov       ax,4300h
         int       2fh                      ; test pamˆti XMS
         cmp       al,80h                   ; je pamˆŸ XMS ?
         jne       LTstXms8                 ; nen¡ pamˆŸ XMS

; ------ poskytnut¡ adresy ovlada‡e XMS

         mov       bx,-1
         mov       ax,4310h
         int       2fh                      ; poskytnut¡ adresy ovlada‡e XMS
         mov       word ptr ds:[LAdrXms],bx ; offset ovlada‡e XMS
         mov       word ptr ds:[LAdrXms+2],es ; segment ovlada‡e XMS
         inc       bx
         jz        LTstXms8                 ; chyba - nen¡ XMS

; ------ zji¨tˆn¡ voln‚ pamˆti XMS

         mov       ah,8
         call      dword ptr ds:[LAdrXms]   ; vol n¡ obsluhy XMS
         or        ax,ax                    ; je voln  pamˆŸ ?
         jz        LTstXms8                 ; nen¡ voln  pamˆŸ
         cmp       dx,MINEXT                ; je dost voln‚ pamˆti XMS ?
         jae       LTstXms9                 ; je dost voln‚ pamˆti XMS

LTstXms8:stc
LTstXms9:ret

LTstXms  ENDP

; -----------------------------------------------------------------------------
;        test roz¨¡©en‚ pamˆti BIOS
; -----------------------------------------------------------------------------

LTstBio  PROC      NEAR

         push      ds
         mov       ah,88h
         int       15h                      ; poskytnut¡ voln‚ pamˆti BIOS
         pop       ds
         cmp       ax,MINEXT                ; je dost roz¨¡©en‚ pamˆti BIOS ?
         ret

LTstBio  ENDP

; -----------------------------------------------------------------------------
;        Kontroln¡ sou‡et CRC bloku dat - NEM‰NIT, z procedury se generuje kl¡‡
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=za‡ tek bloku dat
;        CX=po‡et bajt–
;        DX=vstupn¡ hodnota kontroln¡ho sou‡tu
; VSTUP:DX=v˜stupn¡ hodnota kontroln¡ho sou‡tu
; -----------------------------------------------------------------------------

LChckSum PROC      NEAR

         push      ax
         push      cx
         push      di
         jcxz      LChckSm2                 ; nejsou ‘ dn  data
         mov       di,cx                    ; po‡et bajt– pro kontroln¡ sou‡et
         cld                                ; smˆr nahoru

LChckSm1:lodsb                              ; a = fgetc(fp);
         xor       al,dh                    ; d = a ^= d;
         mov       dh,al
         mov       cl,4
         shr       al,cl                    ; a >>= 4;
         xor       al,dh                    ; d = a ^= d;
         mov       dh,al
         mov       cl,3
         ror       al,cl                    ; a = (a >> 3) | (a << 5);
         mov       ch,al                    ; f = a;
         and       al,1fh                   ; a &= 0x1f;
         xor       al,dl                    ; e = a ^= e;
         mov       dl,al
         mov       al,ch                    ; a = f;
         ror       al,1                     ; a = (a >> 1) | (a << 7);
         and       al,0f0h                  ; a &= 0xf0;
         xor       al,dl                    ; e = a ^= e;
         mov       dl,al
         mov       al,ch                    ; a = f & 0xe0;
         and       al,0e0h
         xor       al,dh                    ; a ^= d;
         mov       dh,dl                    ; d = e;
         mov       dl,al                    ; e = a;

         dec       di
         jnz       LChckSm1                 ; dal¨¡ bajt

LChckSm2:pop       di
         pop       cx
         pop       ax
         ret

LChckSm9 label     near

LChckSum ENDP

Maz1End  label     byte

; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------

LParam   db        1                        ; parametry
                                            ;  bit 0: 1=kompatibiln¡ syst‚m
                                            ;  bit 1: 1=je soubor APP
                                            ;  bit 4: 1=roz¨¡©en  pamˆŸ X

LTopFaze dw        offset(LoadEnd-LoadBeg) + 32 ; po‡ te‡n¡ f ze souboru

LFaze    dd        0                        ; uschovan  f ze

LUkazPth dw        0                        ; ukazatel textu parametru PATH

LFCB1    db        16 dup(0)                ; FCB 1
LFCB2    db        16 dup(0)                ; FCB 2

LFoxPSP  dw        0                        ; PSP hlavn¡ho programu FOXPRO
LIdent   dw        -1                       ; identifik tor programu

LSegPSP  dw        0                        ; uschovan˜ segment PSP

tab      label     byte                     ; tabulka pro start programu
         db        14 dup(0)

IfDef    V20
NoFox    db        'Lituji, ale program nelze spustit bez pritomnosti',13,10
         db        'souboru FOXPRO.ESL resp. FOXPROX.ESL !',13,10,'$'

LSoub1   db        'FOXPRO.ESL',0
LSoub2   db        'FOXPROX.ESL',0
EndIf

IfDef    V25
NoFox    db        'Lituji, ale program nelze spustit bez pritomnosti',13,10
         db        'souboru FOXD250A.ESL resp. FOXDX25A.ESL !',13,10,'$'

LSoub1   db        'FOXD250A.ESL',0
LSoub2   db        'FOXDX25A.ESL',0
EndIf

IfDef    V26
NoFox    db        'Lituji, ale program nelze spustit bez pritomnosti',13,10
         db        'souboru FOXD2600.ESL resp. FOXDX260.ESL !',13,10,'$'

LSoub1   db        'FOXD2600.ESL',0
LSoub2   db        'FOXDX260.ESL',0
EndIf

VerzeTxt db        'Program nelze spustit pod nizsi verzi systemu nez 3.00 !',13,10,'$'

LTxtEMS  db        'EMMXXXX0'               ; identifik tor EMS

LAdrXms  dd        0                        ; adresa ovlada‡e XMS

; ------ n sleduj¡ buffery, neukl daj¡ se na disk

LKlic    db        KlicN dup(0)             ; dek¢dovac¡ kl¡‡

         db        200h dup(0)              ; z sobn¡k
LoadZas  label     byte

LExeBuff db        32 dup(0)                ; buffer k na‡ten¡ hlavi‡ky EXE

LJmeno   dw        0                        ; d‚lka jm‚na programu

LPrikaz  db        80h dup(0)               ; p©¡kazov˜ © dek pro program

LSoubAdr dw        0                        ; adresa jm‚na hledan‚ho souboru
LSoubor  db        80h dup(0)               ; pracovn¡ specifikace souboru
         db        0                        ; rezerva pro koncov˜ CR

LBufDTA  db        44 dup(0)                ; pracovn¡ buffer DTA

JeAPP    db        MaxFil dup (0)           ; Tabulka p©¡znak– .APP soubor–

LoadEnd  label     byte                     ; konec zavadˆ‡e

Load     ENDS
         end       start

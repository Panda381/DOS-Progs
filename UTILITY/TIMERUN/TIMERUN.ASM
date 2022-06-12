
Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; ------ rozbor p©¡kazov‚ho © dku

Start:   call      Rozbor
         jnc       Start1

; ------ zobrazen¡ n povˆdy

         mov       dx,offset HelpTxt
         mov       cx,offset(HelpTxt0-HelpTxt)

Chyba:   push      dx
         mov       dx,offset UvTxt
         mov       ah,9
         int       21h
         pop       dx

         mov       ah,40h
         mov       bx,2
         int       21h
Kod0:    mov       ax,4c00h
         int       21h

; ------ chyba - nedostatek pamˆti

MemErr:  mov       dx,offset MemTxt
         mov       cx,offset(MemTxt0-MemTxt)
         jmp       short Chyba

; ------ p©edefinov n¡ ukazatele z sobn¡ku

Start1:  cmp       sp,offset Zasob
         jb        MemErr
         mov       sp,offset Zasob

; ------ zmen¨en¡ bloku programu

         push      ds
         pop       es
         mov       ah,4ah
         mov       bx,(offset(Zasob-Start)+10fh)/16
         int       21h
         jc        Chyba

; ------ vytvo©en¡ nov‚ho bloku

         mov       bx,0fffh                 ; asi tak 64 KB
         mov       ah,48h
         int       21h
         jnc       Start2
         mov       ah,48h
         int       21h
         jc        Chyba

; ------ ulo‘en¡ parametr– bloku

Start2:  shl       bx,1
         shl       bx,1
         shl       bx,1
         shl       bx,1                     ; p©epo‡et na bajty
         cmp       bx,200h                  ; asi tak minim ln¡ velikost
         jb        Chyba                    ; m lo pamˆti
         mov       ds:[BuffSgmN],bx         ; velikost bufferu v bajtech
         mov       ds:[BuffSegm],ax         ; adresa bufferu

; ------ p©¡prava aktu ln¡ho data

         call      InitDat                  ; p©¡prava data

; ------ otev©en¡ datov‚ho souboru

         call      ReadSoub                 ; na‡ten¡ datov‚ho souboru

; ------ nalezen¡ podm¡nky v bufferu -> AX po‡et dn–

         call      SrcPodm                  ; nalezen¡ podm¡nky v bufferu

; ------ zobrazen¡ po‡tu ubˆhl˜ch dn–

         test      byte ptr ds:[Param],2
         jz        Start5
         push      ax
         cmp       ax,ds:[AktDate]
         jne       Start4
         mov       dl,"?"
         mov       ah,2
         int       21h                      ; po‡et dn– nezn m˜
         jmp       short Start42
Start4:  call      DispNum
Start42: pop       ax

; ------ zobrazen¡ po‡tu zb˜vaj¡c¡ch dn–

Start5:  test      byte ptr ds:[Param],4
         jz        Start6
         push      ax
         cmp       ax,ds:[AktDate]
         jne       Start52
         mov       ax,ds:[PocetDnu]
Start52: sub       ax,ds:[PocetDnu]
         jbe       Start54
         xor       ax,ax
Start54: neg       ax
         call      DispNum
         pop       ax

; ------ test, zda ubˆhlo po‘adovan‚ mno‘stv¡ dn–

Start6:  cmp       ax,ds:[PocetDnu]         ; je po‘adovan˜ po‡et dn– ?
         mov       al,0                     ; je po‘adovan˜ po‡et dn–
         jae       Start7                   ; je po‘adovan˜ po‡et dn–
         mov       al,1                     ; nen¡ je¨tˆ po‘adovan‚ mno‘stv¡ dn–
Start7:  mov       byte ptr ds:[Kod0+1],al  ; n vratov˜ k¢d p©i chybˆ

; ------ z pis datov‚ho souboru

         cmp       al,0                     ; je podm¡nka splnˆna ?
         jne       Start8                   ; podm¡nka nesplnˆna
         test      byte ptr ds:[Param],1    ; m  se datum aktualizovat ?
         jz        Start8                   ; nem  se aktualizovat
         push      ax
         call      WritSoub                 ; z pis datov‚ho souboru
         pop       ax

; ------ konec programu

Start8:  mov       ah,4ch
         int       21h

; -----------------------------------------------------------------------------
;        nalezen¡ podm¡nky v bufferu -> AX po‡et uplynul˜ch dn–
; -----------------------------------------------------------------------------
;þ
SrcPodm  PROC      NEAR

; ------ p©¡prava registr–

         mov       es,ds:[BuffSegm]         ; adresa bufferu
         xor       di,di
         xor       cx,cx
         xor       ax,ax
         cld

; ------ test, zda je ji‘ konec dat

SrcPodm1:cmp       di,ds:[SouborN]          ; je ji‘ konec dat ?
         jae       SrcPodm4                 ; je konec dat

; ------ porovn n¡ d‚lky jm‚na podm¡nky

         push      di
         mov       al,es:[di]               ; d‚lka jm‚na
         cmp       al,ds:[JmenoN]           ; souhlas¡ d‚lka jm‚na ?
         jne       SrcPodm2

; ------ porovn n¡ jm‚na podm¡nky

         mov       cl,al
         inc       di
         mov       si,offset Jmeno          ; hledan‚ jm‚no
         repe      cmpsb                    ; porovn n¡ jm‚na
         jne       SrcPodm2                 ; jm‚no nesouhlas¡

; ------ podm¡nka nalezena - aktualizace data

         pop       ax                       ; zru¨en¡ adresy za‡ tku polo‘ky
         mov       ax,ds:[AktDate]          ; aktu ln¡ datum
         mov       bx,ax
         xchg      bx,es:[di]               ; aktualizace data
         sub       ax,bx                    ; po‡et ubˆhl˜ch dn–
         jnc       SrcPodm9
         xor       ax,ax                    ; omezen¡, je-li datum zpˆt
         jmp       short SrcPodm9

; ------ adresa dal¨¡ podm¡nky

SrcPodm2:pop       di
         add       di,3
         jc        SrcPodm3
         add       di,ax
         jnc       SrcPodm1

; ------ chyba - nedostatek pamˆti

SrcPodm3:jmp       MemErr

; ------ test p©ete‡en¡ pamˆti

SrcPodm4:mov       ax,di                    ; AX <- adresa k ulo‘en¡ podm¡nky
         mov       cl,ds:[JmenoN]           ; d‚lka jm‚na podm¡nky
         add       ax,cx                    ; bude p©ete‡en¡ ?
         jc        SrcPodm3                 ; p©ete‡en¡
         add       ax,3
         jc        SrcPodm3
         cmp       ax,ds:[BuffSgmN]
         jae       SrcPodm3                 ; p©ete‡en¡ bufferu

; ------ ulo‘en¡ podm¡nky

         mov       al,cl                    ; AL <- d‚lka jm‚na podm¡nky
         stosb                              ; ulo‘en¡ d‚lky jm‚na podm¡nky
         mov       si,offset Jmeno          ; jm‚no podm¡nky
         rep       movsb                    ; p©enesen¡ jm‚na podm¡nky
         mov       ax,ds:[AktDate]          ; aktu ln¡ datum
         stosw                              ; aktu ln¡ datum podm¡nky
         mov       ds:[SouborN],di          ; nov˜ po‡et bajt– v bufferu
                                            ; AX = po‡et ubˆhl˜ch dn–
SrcPodm9:ret

SrcPodm  ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ datov‚ho souboru
; -----------------------------------------------------------------------------
;þ
ReadSoub PROC      NEAR

         push      ds

; ------ test verze syst‚mu

         mov       ah,30h
         int       21h
         cmp       al,3
         jb        ReadSou5                 ; n¡zk  verze syst‚mu

; ------ adresa prost©ed¡

         mov       ax,ds:[2ch]              ; segment prost©ed¡
         cmp       ax,70h
         jb        ReadSou5
         mov       ds,ax

; ------ nalezen¡ konce prost©ed¡

         xor       ax,ax
         xor       di,di
ReadSou2:inc       di
         cmp       ds:[di-1],ax
         jne       ReadSou2

; ------ za‡ tek jm‚na souboru

         inc       di
         cmp       ds:[di],ax
         je        ReadSou5
         inc       di
         inc       di
         mov       dx,di

; ------ konec jm‚na souboru

ReadSou3:inc       di
         cmp       ds:[di],al
         jne       ReadSou3

; ------ test, zda je platn  p©¡pona

         cmp       byte ptr ds:[di-4],"."
         jne       ReadSou5

; ------ nastaven¡ p©¡pony "DAT"

         mov       word ptr ds:[di-3],"AD"
         mov       byte ptr ds:[di-1],"T"
         jmp       short ReadSou6

; ------ datov˜ soubor je v aktu ln¡m adres ©i

ReadSou5:push      cs
         pop       ds
         mov       dx,offset Soubor

; ------ otev©en¡ souboru pro ‡ten¡

ReadSou6:mov       word ptr cs:[SouborA],dx
         mov       word ptr cs:[SouborA+2],ds
         mov       ax,3d00h
         int       21h                      ; otev©en¡ pro ‡ten¡
         pop       ds
         jc        ReadSou9                 ; chyba - asi neexistuje
         xchg      ax,bx

; ------ na‡ten¡ souboru do bufferu

         push      ds
         mov       cx,ds:[BuffSgmN]         ; velikost bufferu
         mov       ds,ds:[BuffSegm]         ; segment bufferu
         xor       dx,dx
         mov       ah,3fh
         int       21h                      ; na‡ten¡ souboru
         pop       ds
         jc        ReadSou8                 ; nˆjak  chyba

; ------ kontrola velikosti dat

         cmp       ax,cx
         jb        ReadSou7                 ; buffer nen¡ pln˜
         jmp       MemErr                   ; chyba - m lo pamˆti
ReadSou7:mov       ds:[SouborN],ax          ; po‡et bajt– v bufferu

; ------ uzav©en¡ souboru

ReadSou8:mov       ah,3eh
         int       21h                      ; uzav©en¡ souboru
ReadSou9:ret

ReadSoub ENDP

; -----------------------------------------------------------------------------
;        z pis datov‚ho souboru
; -----------------------------------------------------------------------------

WritSoub PROC      NEAR

; ------ otev©en¡ souboru pro z pis

         push      ds
         lds       dx,ds:[SouborA]          ; adresa jm‚na souboru
         mov       ax,3d01h
         int       21h                      ; otev©en¡ pro z pis
         pop       ds
         jnc       WritSou2

; ------ pokus o vytvo©en¡ souboru

         push      ds
         lds       dx,ds:[SouborA]          ; adresa jm‚na souboru
         xor       cx,cx
         mov       ah,3ch
         int       21h                      ; vytvo©en¡ souboru
         pop       ds
         jnc       WritSou2

; ------ chyba z pisu do souboru

WritSou1:mov       dx,offset WritTxt
         mov       cx,offset(WritTxt0-WritTxt)
         jmp       Chyba

; ------ z pis dat do souboru

WritSou2:xchg      ax,bx                    ; BX <- identifik tor souboru
         mov       cx,ds:[SouborN]          ; po‡et bajt– v bufferu
         xor       dx,dx
         push      ds
         mov       ds,ds:[BuffSegm]
         mov       ah,40h
         int       21h                      ; z pis dat do souboru
         pop       ds
         jc        WritSou1                 ; chyba
         cmp       ax,cx
         jne       WritSou1

; ------ uzav©en¡ souboru

         mov       ah,3eh
         int       21h
         ret

WritSoub ENDP

; -----------------------------------------------------------------------------
;        p©¡prava aktu ln¡ho data
; -----------------------------------------------------------------------------
;þ
InitDat  PROC      NEAR

; ------ aktu ln¡ datum

         mov       ah,2ah
         int       21h                      ; aktu ln¡ datum
         mov       bx,dx                    ; BH <- mˆs¡c, BL <- den
         mov       di,cx                    ; DI <- rok
         xor       si,si                    ; SI <- 0 st©ada‡ data LOW
         mov       cx,1980                  ; CX <- 1980 ukazatel roku

; ------ p©i‡ten¡ rok–

InitDat2:cmp       cx,di
         jae       InitDat4
         call      RokGet                   ; stanoven¡ po‡tu dn– v roce
         add       si,ax                    ; zv˜¨en¡ st©ada‡e
         inc       cx                       ; zv˜¨en¡ ‡¡sla roku
         jmp       short InitDat2

; ------ p©i‡ten¡ mˆs¡c–

InitDat3:call      MesicGet                 ; po‡et dn–
         add       si,ax                    ; p©i‡ten¡ dn– v mˆs¡ci
InitDat4:dec       bh                       ; sn¡‘en¡ ‡¡sla mˆs¡ce
         jnz       InitDat3                 ; dal¨¡ mˆs¡c

; ------ p©i‡ten¡ dne

         dec       bx
         add       si,bx
         mov       ds:[AktDate],si          ; aktu ln¡ datum
         ret

InitDat  ENDP

; -----------------------------------------------------------------------------
;                     stanoven¡ po‡tu dn– v mˆs¡ci
; -----------------------------------------------------------------------------
; VSTUP: BH=mˆs¡c (1 a‘ 12)
;        CX=rok (1 a‘ 9999)
;        DS=datov˜ segment
; VSTUP:AX=po‡et dn– (21 a‘ 31)
; -----------------------------------------------------------------------------

MesicGet PROC      NEAR

         push      bx

; ------ v ©¡jnu 1582 je nam¡sto 31 dn– pouze 21 dn–

         mov       ax,21                    ; je 21 dn– v ©¡jnu
         cmp       cx,1582                  ; je rok 1582 ?
         jne       MesicGt1                 ; nen¡ rok 1582
         cmp       bh,10                    ; je ©¡jen ?
         je        MesicGt2                 ; je ©¡jen 1582

; ------ po‡et dn– v mˆs¡ci

MesicGt1:mov       bl,bh                    ; mˆs¡c
         xor       bh,bh                    ; BX=mˆs¡c
         mov       al,ds:[bx+PoctyDnu-1]    ; po‡et dn– v mˆs¡ci
         cmp       bl,2                     ; je to £nor ?
         jne       MesicGt2                 ; nen¡ £nor
         call      RokTest                  ; test p©estupnosti roku
         adc       al,ah                    ; pro p©estupn˜ rok je £nor 29 dn–

MesicGt2:pop       bx
         ret

MesicGet ENDP

; -----------------------------------------------------------------------------
;                     stanoven¡ po‡tu dn– v roce
; -----------------------------------------------------------------------------
; VSTUP: CX=rok (1 a‘ 9999)
; VSTUP:AX=po‡et dn– (355 a‘ 366)
; -----------------------------------------------------------------------------

RokGet   PROC      NEAR

; ------ po‡et dn– v roce 1582

         mov       ax,365-10                ; po‡et dn– v roce 1582
         cmp       cx,1582                  ; je rok 1582 ?
         je        RokGet1                  ; je rok 1582

; ------ po‡et dn– podle p©estupnosti roku (AH=1)

         mov       al,(365 AND 255)-1       ; po‡et dn– v nep©estupn‚m roce - 1
         call      RokTest                  ; test p©estupnosti roku
         adc       al,ah                    ; pro p©estupn˜ rok 366 dn–
RokGet1: ret

RokGet   ENDP

; -----------------------------------------------------------------------------
;                    test p©estupnosti roku
; -----------------------------------------------------------------------------
; VSTUP: CX=rok (1 a‘ 9999)
; VSTUP:CY=je p©estupn˜ rok
; -----------------------------------------------------------------------------

RokTest  PROC      NEAR

; ------ test, zda rok je n sobkem 4

         test      cl,3                     ; je p©estupn˜ rok ?
         jnz       RokTest3                 ; nen¡ p©estupn˜ rok

; ------ p©ed rokem 1600 je stolet¡ p©estupn‚ v‘dy

         cmp       ch,6                     ; je p©ed rokem 1600 (=1536) ?
         jb        RokTest3                 ; p©ed 1600 p©estupn‚ v‘dy

; ------ £schova registr–

         push      ax
         push      cx

; ------ test, zda je stolet¡ n sobkem 4

         mov       al,100                   ; dˆlitel stolet¡
         xchg      ax,cx                    ; AX <- rok
         div       cl                       ; v˜po‡et stolet¡
         or        ah,ah                    ; je stolet¡ ?
         jnz       RokTest1                 ; nen¡ stolet¡ - je p©estupn˜ rok
         and       al,3                     ; je stolet¡ dˆliteln‚ 4 ?
         jnz       RokTest2                 ; nen¡ dˆliteln‚ 4 - nen¡ p©estupn‚
RokTest1:stc                                ; p©¡znak p©estupn‚ho roku

; ------ n vrat registr–

RokTest2:pop       cx
         pop       ax

RokTest3:ret

RokTest  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ ‡¡sla AX
; -----------------------------------------------------------------------------

DispNum  PROC      NEAR

         xor       cx,cx
         mov       bx,10
DispNum1:xor       dx,dx
         div       bx
         push      dx
         inc       cx
         or        ax,ax
         jnz       DispNum1

DispNum2:pop       dx
         add       dl,"0"
         mov       ah,2
         int       21h
         loop      DispNum2
         ret

DispNum  ENDP

; -----------------------------------------------------------------------------
;        rozbor p©¡kazov‚ho © dku
; -----------------------------------------------------------------------------

Rozbor   PROC      NEAR

; ------ p©¡prava p©¡kazov‚ho © dku

         mov       si,81h
         mov       bl,ds:[si-1]
         mov       bh,0
         mov       ds:[si+bx],bh
         call      RozbSpc                  ; vypu¨tˆn¡ mezer
         jc        Rozbor9                  ; nen¡ nic zad no
         cmp       al,"/"
         stc
         je        Rozbor9

; ------ dek¢dov n¡ jm‚na parametru

         push      ds
         pop       es
         mov       di,offset Jmeno
Rozbor1: call      RozbChr
         jc        Rozbor2                  ; konec textu
         je        Rozbor2                  ; mezera
         cmp       al,"/"
         je        Rozbor2
         cmp       byte ptr ds:[JmenoN],40
         jae       Rozbor1
         cld
         stosb
         inc       byte ptr ds:[JmenoN]     ; ‡¡ta‡ d‚lky jm‚na
         jmp       short Rozbor1

; ------ za‡ tek dal¨¡ho parametru

Rozbor2: call      RozbSpc                  ; vypu¨tˆn¡ mezer
         jc        Rozbor8                  ; nen¡ dal¨¡ parametr
         call      RozbChr                  ; na‡ten¡ znaku
         cmp       al,"/"
         je        Rozbor2

; ------ parametr "A" - aktualizace

         cmp       al,"A"
         jne       Rozbor3
         or        byte ptr ds:[Param],1    ; p©¡znak aktualizace data
         jmp       short Rozbor2            ; dal¨¡ parametr

; ------ parametr "P" - zobrazen¡ ubˆhl‚ho po‡tu dn–

Rozbor3: cmp       al,"P"
         jne       Rozbor32
         or        byte ptr ds:[Param],2    ; p©¡znak zobrazen¡ po‡tu dn–
         jmp       short Rozbor2

; ------ parametr "R" - zobrazen¡ zbyl‚ho po‡tu dn–

Rozbor32:cmp       al,"R"
         jne       Rozbor34
         or        byte ptr ds:[Param],4
         jmp       short Rozbor2

; ------ test, zda je ‡¡slice

Rozbor34:dec       si                       ; n vrat znaku
         call      RozbNm                   ; na‡ten¡ prvn¡ ‡¡slice
         jc        Rozbor9                  ; nen¡ ‡¡slice
         mov       word ptr ds:[PocetDnu],0 ; nulov n¡ st©ada‡e

; ------ p©id n¡ ‡¡slice ke st©ada‡i

Rozbor4: push      ax
         mov       ax,10
         mul       word ptr ds:[PocetDnu]
         pop       dx
         mov       dh,0
         add       ax,dx
         mov       ds:[PocetDnu],ax

; ------ dal¨¡ ‡¡slice

         call      RozbNm
         jnc       Rozbor4
         jmp       short Rozbor2

Rozbor8: clc
Rozbor9: ret

Rozbor   ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ ‡¡slice
; -----------------------------------------------------------------------------

RozbNm   PROC      NEAR

         call      RozbChr                  ; na‡ten¡ znaku
         jc        RozbNm9
         cmp       al,"9"
         ja        RozbNm8
         sub       al,"0"
         jnc       RozbNm9
RozbNm8: dec       si
         stc
RozbNm9: ret

RozbNm   ENDP

; -----------------------------------------------------------------------------
;        vypu¨tˆn¡ mezer z p©¡kazov‚ho © dku
; -----------------------------------------------------------------------------

RozbSpc  PROC      NEAR

         call      RozbChr
         jc        RozbSpc2
         je        RozbSpc
         dec       si
RozbSpc2:ret

RozbSpc  ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ znaku z p©¡kazov‚ho © dku
; -----------------------------------------------------------------------------

RozbChr  PROC      NEAR

         cld
         lodsb

         cmp       al,9
         jne       RozbChr1
         mov       al," "

RozbChr1:cmp       al,"a"
         jb        RozbChr2
         cmp       al,"z"
         ja        RozbChr2
         sub       al,32

RozbChr2:cmp       al," "
         jae       RozbChr4
         dec       si

RozbChr4:ret

RozbChr  ENDP

; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------
;þ
Param    db        0                        ; parametry
                                            ;   bit 0: 1=aktualizovat datum
                                            ;   bit 1: 1=zobrazen¡ ubˆhl‚ho po‡tu dn–
                                            ;   bit 2: 1=zobrazen¡ zbyl‚ho po‡tu dn–

PocetDnu dw        1                        ; po‘adovan˜ po‡et dn–

; ------ nov  polo‘ka k z pisu (zachovat po©ad¡ !)

JmenoN   db        0                        ; d‚lka jm‚na
Jmeno    db        40 dup(0)                ; jm‚no podm¡nky
AktDate  dw        0                        ; aktu ln¡ datum v absolutn¡m tvaru

; ------ po‡ty dn– v mˆs¡c¡ch roku

PoctyDnu db        31                       ; leden
         db        28                       ; £nor
         db        31                       ; b©ezen
         db        30                       ; duben
         db        31                       ; kvˆten
         db        30                       ; ‡erven
         db        31                       ; ‡ervenec
         db        31                       ; spren
         db        30                       ; z ©¡
         db        31                       ; ©¡jen
         db        30                       ; listopad
         db        31                       ; prosinec

SouborA  dd        0                        ; adresa jm‚na souboru
Soubor   db        'TIMERUN.DAT',0          ; datov˜ soubor, nen¡-li v prost©ed¡

SouborN  dw        0                        ; po‡et bajt– v bufferu

BuffSegm dw        0                        ; adresa segmentu bufferu
BuffSgmN dw        0                        ; velikost bufferu (bajt–)

UvTxt    db        'TIMERUN V1.0 - casovane spousteni programu; (c) Miroslav Nemecek',13,10,'$'

MemTxt   db        'Chyba - nedostatek pameti ke spusteni programu TIMERUN !',13,10,7
MemTxt0  label     byte

WritTxt  db        'Chyba pri zapisu do souboru TIMERUN.DAT !',13,10,7
WritTxt0 label     byte

HelpTxt  db        'Zadejte:    TIMERUN  jmeno  [dnu]  [/A]  [/?]',13,10
         db        '               jmeno ........... jmeno testovane podminky (napr. jmeno',13,10
         db        '                                 programu) - lze pouzit bezne znaky DOS krome',13,10
         db        '                                 mezer a "/"; podminka se eviduje v TIMERUN.DAT',13,10
         db        '               dnu ............. pocet dnu od posledniho spusteni programu',13,10
         db        '                                 (implicitne 1 den)',13,10
         db        '               /A .............. aktualizace data podminky (program spusten)',13,10
         db        '                                 - provede se jen pri splneni podminky',13,10
         db        '               /P .............. zobrazeni ubehleho poctu dnu podminky',13,10
         db        '               /R .............. zobrazeni zbyleho poctu dnu podminky',13,10
         db        13,10
         db        'Navratovy kod: 0 ............... dosazeno pozadovaneho poctu dnu',13,10
         db        '               1 ............... program jeste neni potreba spoustet',13,10
         db        13,10
         db        'Priklad:       TIMERUN chkdsk 7 /A',13,10
         db        '               IF ERRORLEVEL 1 GOTO dale',13,10
         db        '               chkdsk',13,10
         db        '               :dale',13,10
HelpTxt0 label     byte

         db        100h dup(?)              ; z sobn¡k (m–‘e trochu p©epsat text)
Zasob    label     word

Code     ENDS
         END       Start

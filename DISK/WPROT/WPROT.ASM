
; PARX je p©¡znak verze pro druh˜ disk

KORIG    EQU       5ch-103h                 ; korekce adres

KLIC1    EQU       "W"                      ; AX (AH = 0 - reset disku)
KLIC2    EQU       "PR"                     ; BX
KLIC3    EQU       "OT"                     ; CX

IFDEF    PARX
KLIC4    EQU       "X?"                     ; DX (DL=neplatn˜ disk)
ELSE
KLIC4    EQU       " ?"                     ; DX (DL=neplatn˜ disk)
ENDIF

KLIC5    EQU       "OK"                     ; AX n vratov˜ k¢d (t‚‘ NC)

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

Start:   jmp       Init                     ; start instalace

RezBeg   label     byte                     ; za‡ tek rezidentn¡ch dat

Ident    db        'WP'                     ; identifikace rezidentu

Old13    dd        0                        ; p–vodn¡ obsluha INT 13h

Disk     db        255                      ; obsluhovan˜ disk (255=vypnuto)

Valec1   dw        0                        ; po‡ te‡n¡ v lec
                                            ;  HIGH = v lec HIGH * bit6
                                            ;  (tj. horn¡ 2 bity jsou v b6 a b7)
Hlava1   db        0                        ; po‡ te‡n¡ hlava

Valec2   dw        0                        ; koncov˜ v lec
                                            ;  HIGH = v lec HIGH * bit6
                                            ;  (tj. horn¡ 2 bity jsou v b6 a b7)
Hlava2   db        0                        ; koncov  hlava

; -----------------------------------------------------------------------------
;        obsluha INT 13h
; -----------------------------------------------------------------------------

Int13    PROC      FAR

; ------ dotaz na instalaci

         cmp       ax,KLIC1
         jne       Int132
         cmp       bx,KLIC2
         jne       Int132
         cmp       cx,KLIC3
         jne       Int132
         cmp       dx,KLIC4
         jne       Int132
         push      cs
         pop       es                       ; ES <- segment programu
         clc
         mov       ax,KLIC5                 ; n vratov˜ k¢d
Int131:  sti
         ret       2

; ------ test disku

Int132:  cmp       dl,cs:[Disk+KORIG]       ; souhlas¡ disk ?
         jne       Int139                   ; disk nesouhlas¡

; ------ test operace z pisu nebo form tov n¡

         cmp       ah,3                     ; z pis na disk
         jb        Int139                   ; nen¡ z pis
         cmp       ah,4                     ; je verifikace ?
         je        Int139                   ; verifikace
         cmp       ah,0bh                   ; dlouh˜ z pis
         je        Int133
         cmp       ah,7                     ; form tov n¡
         ja        Int139                   ; nen¡ form tov n¡ ani z pis

; ------ test, zda je MASTER BOOT sektor

Int133:  cmp       cx,1                     ; je stopa 0 ?
         jne       Int1336                  ; nen¡ stopa 0
         or        dl,dl                    ; je pevn˜ disk ?
         jns       Int1336                  ; nen¡ pevn˜ disk
         or        dh,dh                    ; je hlava 0 ?
         jz        Int135                   ; je hlava 0 (je MASTER BOOT)

; ------ test po‡ tku oblasti

Int1336: push      cx
         and       cl,0c0h                  ; horn¡ 2 bity ‡¡sla v lce
         xchg      cl,ch                    ; CL <- LOW, CH <- HIGH
         cmp       cx,cs:[Valec1+KORIG]     ; vyhovuje v lec po‡ tku ?
         pop       cx
         jne       Int1338
         cmp       dh,cs:[Hlava1+KORIG]     ; kontrola po‡ te‡n¡ hlavy
Int1338: jb        Int139                   ; po‡ tek oblasti nevyhovuje

; ------ test konce oblasti

Int134:  push      cx
         and       cl,0c0h                  ; horn¡ 2 bity ‡¡sla v lce
         xchg      cl,ch                    ; CL <- LOW, CH <- HIGH
         cmp       cx,cs:[Valec2+KORIG]     ; vyhovuje v lec konce ?
         pop       cx
         jne       Int1348
         cmp       dh,cs:[Hlava2+KORIG]     ; kontrola koncov‚ hlavy
Int1348: ja        Int139                   ; hlava nevyhovuje

; ------ hl ¨en¡ chyby z pisu

Int135:  push      ds
         xor       ax,ax
         mov       ds,ax                    ; DS <- 0
         mov       ax,0300h                 ; AH = chyba ochrany proti z pisu

         or        dl,dl                    ; je z pis na disketu ?
         jns       Int136                   ; je z pis na disketu
         mov       ds:[474h],ah             ; p©¡znak chyby pro pevn˜ disk
         jmp       short Int137

Int136:  mov       ds:[441h],ah             ; p©¡znak chyby pro disketu

Int137:  pop       ds
         stc                                ; p©¡znak chyby
         jmp       short Int131             ; n vrat

; ------ pokra‡ov n¡ p–vodn¡ obsluhou

Int139:  jmp       dword ptr cs:[Old13+KORIG] ; p–vodn¡ obsluha INT 13h

Int13    ENDP

RezEnd   label     byte                     ; konec rezidentn¡ ‡ sti

; -----------------------------------------------------------------------------
;
;                            Inicializace programu
;
; -----------------------------------------------------------------------------
;þ
; ------ £vodn¡ text

Init:    mov       dx,offset UvTxt
         call      DispTxt                  ; zobrazen¡ £vodn¡ho textu

; ------ £schova p©¡kazov‚ho © dku do bufferu

         mov       si,81h                   ; za‡ tek p©¡kazov‚ho © dku
         mov       di,offset Buffer         ; buffer k ulo‘en¡ p©¡kazov‚ho © dku
         mov       cl,ds:[si-1]             ; d‚lka p©¡kazov‚ho © dku
         mov       ch,0                     ; CH <- 0
         cld
         rep       movsb                    ; £schova p©¡kazov‚ho © dku
         mov       al,0                     ; koncov  0
         stosb                              ; ozna‡en¡ konce textu

; ------ posun programu dol– (DS=ES)

         mov       si,offset RezBeg         ; sou‡asn˜ za‡ tek rezidentu
         mov       di,offset RezBeg+KORIG   ; po‘adovan˜ za‡ tek rezidentu
         mov       cx,offset(RezEnd-RezBeg) ; d‚lka rezidentu
         rep       movsb                    ; p©esun programu dol–

; ------ test instalace programu

         mov       ds:[RezSegm],ds          ; adresa tohoto programu
         mov       ax,KLIC1
         mov       bx,KLIC2
         mov       cx,KLIC3
         mov       dx,KLIC4
         push      ds
         int       13h                      ; test instalace programu
         pop       ds
         jc        Init0                    ; nen¡ rezident
         cmp       ax,KLIC5
         jne       Init0                    ; nen¡ rezident
         mov       ax,es
         mov       bx,ds
         cmp       ax,bx
         je        Init0                    ; ES nezmˆnˆn, nen¡ rezident
         cmp       word ptr es:[Ident+KORIG],"PW"
         je        Init1

Init0:   push      ds
         pop       es                       ; ES <- tento program
         jmp       short Init2

Init1:   mov       ds:[RezSegm],es          ; navr cen  adresa
         or        byte ptr ds:[Param],1    ; program je rezidetn¡

; ------ p©¡prava p©¡kazov‚ho © dku

Init2:   mov       si,offset Buffer         ; za‡ tek p©¡kazov‚ho © dku

; ------ instalace, nen¡-li nic zad no

         call      ParSpc                   ; test, zda je nˆco zad no
         jc        Init6                    ; nen¡ nic zad no

; ------ ‡¡slo disku

         call      ParNum                   ; na‡ten¡ prvn¡ho ‡¡sla
         jc        Init4
         cmp       ax,255
         jbe       Init22
         mov       al,255
Init22:  mov       ds:[Disk+KORIG],al       ; ‡¡slo disku
         cmp       al,255                   ; disk vypnut ?
         je        Init55                   ; je vypnut¡ funkce

; ------ informace o disku

         call      ParSpc                   ; vypu¨tˆn¡ mezer
         jnc       Init3                    ; je je¨tˆ nˆco zad no
         call      DispInf                  ; zobrazen¡ informac¡ o disku
         int       20h

; ------ po‡ te‡n¡ v lec

Init3:   call      ParNum
         jc        Init4
         cmp       ax,1023
         jbe       Init32
         mov       ax,1023
Init32:  mov       cl,6
         shl       ah,cl
         mov       ds:[Valec1+KORIG],ax

; ------ po‡ te‡n¡ hlava

         call      ParNum
         jc        Init4
         cmp       ax,63
         jbe       Init33
         mov       al,63
Init33:  mov       ds:[Hlava1+KORIG],al

; ------ koncov˜ v lec

         call      ParNum
         jc        Init4
         cmp       ax,1023
         jbe       Init34
         mov       ax,1023
Init34:  shl       ah,cl
         mov       ds:[Valec2+KORIG],ax

; ------ koncov  hlava

         call      ParNum
         jc        Init4
         cmp       ax,63
         jbe       Init35
         mov       al,63
Init35:  mov       ds:[Hlava2+KORIG],al

; ------ test, zda je je¨tˆ nˆco zad no

         call      ParSpc                   ; je je¨tˆ nˆco ?
         jc        Init55                   ; jinak nic nen¡

; ------ n povˆda

Init4:   mov       dx,offset HelpTxt
         call      DispTxt
Init5:   int       20h

; ------ ulo‘en¡ dat do rezidentn¡ho modulu ES

Init55:  mov       si,offset Disk+KORIG
         mov       di,si
         mov       cx,1 + 2 + 1 + 2 + 1
         cld
         rep       movsb

; ------ zobrazen¡ aktu ln¡ho stavu programu

Init6:   call      DispStav                 ; zobrazen¡ stavu programu

; ------ test, zda bude instalace programu

         test      byte ptr ds:[Param],1    ; je program rezidentn¡ ?
         jnz       Init5                    ; program je ji‘ rezidentn¡

; ------ instalace programu do pamˆti

         mov       ax,3513h
         int       21h                      ; poskytnut¡ adresy obsluhy
         mov       word ptr ds:[Old13+KORIG],bx
         mov       word ptr ds:[Old13+2+KORIG],es

         mov       dx,offset Int13+KORIG
         mov       ax,2513h
         int       21h                      ; instalace vlastn¡ obsluhy

         mov       ah,49h
         mov       es,ds:[2ch]
         int       21h                      ; uvolnˆn¡ segmentu prost©ed¡

         mov       dx,offset RezEnd+KORIG
         int       27h                      ; instalace do pamˆti

; -----------------------------------------------------------------------------
;        na‡ten¡ ‡¡sla AX
; -----------------------------------------------------------------------------

ParNum   PROC      NEAR

         push      bx
         push      dx

         xor       bx,bx                    ; st©ada‡

         call      ParSpc                   ; vypu¨tˆn¡ mezer
         call      ParNm                    ; na‡ten¡ prvn¡ ‡¡slice
         jc        ParNum9

ParNum2: mov       ah,0
         push      ax
         mov       ax,10
         mul       bx                       ; vyn soben¡ st©ada‡e
         pop       bx
         add       bx,ax
         adc       dx,dx
         jz        ParNum3
         mov       bx,-1
ParNum3: call      ParNm                    ; na‡ten¡ dal¨¡ ‡¡slice
         jnc       ParNum2                  ; je dal¨¡ ‡¡slice OK
         clc

ParNum9: xchg      ax,bx
         pop       dx
         pop       bx
         ret

ParNum   ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ ‡¡slice AL
; -----------------------------------------------------------------------------

ParNm    PROC      NEAR

         call      ParChr                   ; na‡ten¡ znaku
         jc        ParNm9
         cmp       al,"9"
         ja        ParNm8
         sub       al,"0"
         jae       ParNm9
ParNm8:  dec       si
         stc
ParNm9:  ret

ParNm    ENDP

; -----------------------------------------------------------------------------
;        vypu¨tˆn¡ mezer z p©¡kazov‚ho © dku
; -----------------------------------------------------------------------------

ParSpc   PROC      NEAR

         call      ParChr
         jc        ParSpc2
         je        ParSpc
         cmp       al,";"
         je        ParSpc
         cmp       al,","
         je        ParSpc
         cmp       al,"."
         je        ParSpc
         cmp       al,"/"
         je        ParSpc
         clc
         dec       si
ParSpc2: ret

ParSpc   ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ znaku z p©¡kazov‚ho © dku
; -----------------------------------------------------------------------------

ParChr   PROC      NEAR

         cld
         lodsb
         cmp       al," "
         jae       ParChr3
         dec       si
ParChr3: ret

ParChr   ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ informac¡ o disku
; -----------------------------------------------------------------------------

DispInf  PROC      NEAR

; ------ na‡ten¡ BOOT sektoru disku

         mov       bx,offset Buffer
         call      ReadBoot                 ; 1. pokus - buffer 1
         jnc       DispInf2
         call      ReadBoot                 ; 2. pokus - buffer 1
         jnc       DispInf2

         mov       bx,offset Buffer + 1024  ; buffer 2
         call      ReadBoot                 ; 1. pokus - buffer 2
         jnc       DispInf2
         call      ReadBoot                 ; 2. pokus - buffer 2
         jnc       DispInf2

DispInf1:mov       dx,offset PristTxt
         call      DispTxt                  ; chyba - disk nep©¡stupn˜
         ret

; ------ zobrazen¡ £vodn¡ho textu

DispInf2:mov       dx,offset InfTxt
         call      DispTxt

; ------ rozli¨en¡, zda to je pevn˜ disk

         mov       ah,0
         mov       al,ds:[Disk+KORIG]       ; zadan˜ disk
         or        al,al                    ; je to pevn˜ disk ?
         js        DispInf3                 ; je to pevn˜ disk
         cmp       word ptr ds:[bx+18h],0   ; po‡et sektor– na stopu
         je        DispInf1                 ; chyba
         cmp       word ptr ds:[bx+1ah],0   ; po‡et hlav
         je        DispInf1                 ; chyba

; ------ zobrazen¡ ‡¡sla disku

         call      DispNumS                 ; zobrazen¡ ‡¡sla disku

; ------ po‡ te‡n¡ v lec a hlava

         xor       ax,ax
         call      DispNumS                 ; po‡ te‡n¡ v lec diskety
         call      DispNumS                 ; po‡ te‡n¡ hlava diskety

; ------ posledn¡ v lec

         mov       ax,ds:[bx+13h]           ; po‡et sektor– celkem
         dec       ax                       ; posledn¡ sektor
         xor       dx,dx                    ; DX <- 0
         div       word ptr ds:[bx+18h]     ; v˜po‡et ‡¡sla stopy absolutnˆ
         xor       dx,dx
         div       word ptr ds:[bx+1ah]     ; v˜po‡et po‡tu v lc–
         call      DispNumS                 ; ‡¡slo posledn¡ho v lce

; ------ posledn¡ hlava

         xchg      ax,dx
         call      DispNumS                 ; posledn¡ hlava

; ------ od© dkov n¡

         call      DispCR                   ; od© dkov n¡
         jmp       short DispInf9

; ------ p©¡prava k zobrazen¡ partition pevn‚ho disku

DispInf3:add       bx,1beh                  ; odd¡l 1
         mov       bp,4                     ; po‡et odd¡l– disku

; ------ test platnosti odd¡lu

DispInf4:mov       ax,ds:[bx+12]            ; velikost LOW
         or        ax,ds:[bx+14]            ; je platn˜ odd¡l ?
         jz        DispInf8                 ; odd¡l nen¡ platn˜

; ------ zobrazen¡ ‡¡sla disku

         mov       ah,0
         mov       al,ds:[Disk+KORIG]       ; zadan˜ disk
         call      DispNumS                 ; zobrazen¡ ‡¡sla disku

; ------ po‡ te‡n¡ v lec

         mov       cl,6
         mov       ax,ds:[bx+2]             ; v lec za‡ tku
         shr       al,cl
         xchg      al,ah
         call      DispNumS                 ; po‡ te‡n¡ v lec

; ------ po‡ te‡n¡ hlava

         mov       ah,0
         mov       al,ds:[bx+1]
         call      DispNumS                 ; po‡ te‡n¡ hlava

; ------ koncov˜ v lec

         mov       ax,ds:[bx+6]
         shr       al,cl
         xchg      al,ah
         call      DispNumS                 ; koncov˜ v lec

; ------ koncov  hlava

         mov       ah,0
         mov       al,ds:[bx+5]
         call      DispNumS                 ; koncov  hlava

; ------ od© dkov n¡

         call      DispCR

; ------ dal¨¡ odd¡l

DispInf8:add       bx,16
         dec       bp
         jnz       DispInf4                 ; dal¨¡ odd¡l
DispInf9:ret

DispInf  ENDP

DispNumS:call      DispSpc
         call      DispSpc
         call      DispSpc

         cmp       ax,1000
         jae       DispNmS2
         call      DispSpc
DispNmS2:cmp       ax,100
         jae       DispNmS3
         call      DispSpc
DispNmS3:cmp       ax,10
         jae       DispNmS4
         call      DispSpc

DispNmS4:jmp       DispNum                  ; zobrazen¡ ‡¡sla AX

; -----------------------------------------------------------------------------
;        na‡ten¡ BOOT sektoru do bufferu DS:BX
; -----------------------------------------------------------------------------

ReadBoot PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es

         mov       ax,201h
         mov       cx,1                     ; CH = v lec, CL = sektor
         mov       dl,ds:[Disk+KORIG]       ; zadan˜ disk
         mov       dh,0                     ; strana
         push      ds
         pop       es                       ; ES <- datov˜ segment
         push      dx
         int       13h                      ; na‡ten¡ sektoru
         pop       dx
         jnc       ReadBot2                 ; operace OK

         mov       ah,0
         int       13h                      ; resetov n¡ disku
         stc                                ; p©¡znak chyby operace

ReadBot2:pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

ReadBoot ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ stavu (ES=rezidentn¡ segment)
; -----------------------------------------------------------------------------

DispStav PROC      NEAR

; ------ funkce programu vypnuta

         mov       al,es:[Disk+KORIG]       ; nastaven˜ disk
         cmp       al,255                   ; je funkce vypnuta ?
         jne       DispSta2                 ; nen¡ vypnuta

         mov       dx,offset VypTxt
         jmp       DispTxt

; ------ ‡¡slo disku

DispSta2:mov       dx,offset StavTxt
         call      DispNm0C                 ; zobrazen¡ ‡¡sla disku

; ------ po‡ te‡n¡ v lec

         mov       dx,offset Stav2Txt
         mov       cl,6                     ; po‡et rotac¡
         mov       ax,es:[Valec1+KORIG]     ; po‡ te‡n¡ v lec
         shr       ah,cl
         call      DispNumC                 ; zobrazen¡ po‡ te‡n¡ho v lce

; ------ po‡ te‡n¡ hlava

         mov       al,es:[Hlava1+KORIG]
         mov       dx,offset Stav3Txt
         call      DispNm0C                 ; zobrazen¡ po‡ te‡n¡ hlavy

; ------ koncov˜ v lec

         mov       dx,offset Stav4Txt
         mov       ax,es:[Valec2+KORIG]     ; koncov˜ v lec
         shr       ah,cl
         call      DispNumC                 ; zobrazen¡ koncov‚ho v lec

; ------ koncov  hlava

         mov       al,es:[Hlava2+KORIG]
         mov       dx,offset Stav5Txt
         call      DispNm0C                 ; zobrazen¡ koncov‚ hlavy
         ret

DispStav ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ textu DX a ‡¡sla AX se zobrazen¡m od© dkov n¡
; -----------------------------------------------------------------------------

DispNm0C:mov       ah,0                     ; AX = ‡¡slo (bajt)

DispNumC PROC      NEAR

         call      DispTxt                  ; zobrazen¡ £vodn¡ ‡ sti textu
         call      DispNum                  ; zobrazen¡ ‡¡sla AX
DispCR:  push      dx
         mov       dx,offset CRTxt
         call      DispTxt                  ; zobrazen¡ od© dkov n¡
         pop       dx
         ret

DispNumC ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ ‡¡sla AX
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
;        zobrazen¡ mezery
; -----------------------------------------------------------------------------

DispSpc  PROC      NEAR

         push      ax
         mov       al," "
         call      DispChr
         pop       ax
         ret

DispSpc  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ znaku AL
; -----------------------------------------------------------------------------

DispChr  PROC      NEAR

         push      ax
         push      dx
         xchg      ax,dx                    ; DL <- znak
         mov       ah,2
         int       21h
         pop       dx
         pop       ax
         ret

DispChr  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ textu DS:DX
; -----------------------------------------------------------------------------

DispTxt  PROC      NEAR

         push      ax
         mov       ah,9
         int       21h
         pop       ax
         ret

DispTxt  ENDP

; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------

Param    db        0                        ; parametry
                                            ;    bit 0: 1=program je rezidentn¡
RezSegm  dw        0                        ; segment rezidentn¡ ‡ sti

IFDEF    PARX

UvTxt    db        'WPROTX V1.0 - ochrana disku proti zapisu; (c) Miroslav Nemecek',13,10,'$'

HelpTxt  db        'Zadejte:  WPROTX   disk   valec1  hlava1   valec2  hlava2',13,10
         db        13,10
         db        '            disk ....... cislo disku podle cislovani v BIOS',13,10
         db        '                         (0=disketa A:, 128=pevny disk C:)',13,10
         db        '            valec1 ..... cislo valce pocatku chranene oblasti (0 - 1023)',13,10
         db        '            hlava1 ..... cislo hlavy pocatku chranene oblasti (0 - 63)',13,10
         db        '            valec2 ..... cislo valce konce chranene oblasti (0 - 1023)',13,10
         db        '            hlava2 ..... cislo hlavy konce chranene oblasti (0 - 63)',13,10
         db        '          (napr.:  WPROTX 128 0 0 1023 63  - ochrana celeho disku C:)',13,10
         db        13,10
         db        '   nebo:  WPROTX   disk',13,10
         db        '            zobrazeni informaci o zadanem disku',13,10
         db        13,10
         db        '   nebo:  WPROTX   255',13,10
         db        '            vypnuti funkce programu',13,10
CRTxt    db        13,10
         db        '$'

VypTxt   db        'Funkce programu WPROTX je vypnuta.',13,10,'$'

ELSE

UvTxt    db        'WPROT V1.0 - ochrana disku proti zapisu; (c) Miroslav Nemecek',13,10,'$'

HelpTxt  db        'Zadejte:  WPROT   disk   valec1  hlava1   valec2  hlava2',13,10
         db        13,10
         db        '            disk ....... cislo disku podle cislovani v BIOS',13,10
         db        '                         (0=disketa A:, 128=pevny disk C:)',13,10
         db        '            valec1 ..... cislo valce pocatku chranene oblasti (0 - 1023)',13,10
         db        '            hlava1 ..... cislo hlavy pocatku chranene oblasti (0 - 63)',13,10
         db        '            valec2 ..... cislo valce konce chranene oblasti (0 - 1023)',13,10
         db        '            hlava2 ..... cislo hlavy konce chranene oblasti (0 - 63)',13,10
         db        '          (napr.:  WPROT 128 0 0 1023 63  - ochrana celeho disku C:)',13,10
         db        13,10
         db        '   nebo:  WPROT   disk',13,10
         db        '            zobrazeni informaci o zadanem disku',13,10
         db        13,10
         db        '   nebo:  WPROT   255',13,10
         db        '            vypnuti funkce programu',13,10
CRTxt    db        13,10
         db        '$'

VypTxt   db        'Funkce programu WPROT je vypnuta.',13,10,'$'

ENDIF

PristTxt db        'Disk neni pristupny !',13,10,'$'

InfTxt   db        'Nastaveni parametru pro zadany disk:',13,10,'$'

StavTxt  db        'Zapnuta ochrana proti zapisu pro oblast:',13,10
         db        '          Cislo disku: $'
Stav2Txt db        '      Pocatecni valec: $'
Stav3Txt db        '      Pocatecni hlava: $'
Stav4Txt db        '        Koncovy valec: $'
Stav5Txt db        '        Koncova hlava: $'

Buffer   label     byte                     ; buffer (t‚‘ pro p©¡kazov˜ © dek)

Code     ENDS
         END       Start

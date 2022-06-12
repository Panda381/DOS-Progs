
Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; ------ zobrazen¡ £vodn¡ho textu

Start:   mov       dx,offset UvTxt
         mov       ah,9
         int       21h                      ; zobrazen¡ £vodn¡ho textu

; ------ p©¡prava k rozboru p©¡kazov‚ho © dku

         mov       si,81h                   ; za‡ tek p©¡kazov‚ho © dku
         mov       cl,ds:[si-1]             ; d‚lka p©¡kazov‚ho © dku
         mov       ch,0
         cld

; ------ nalezen¡ za‡ tku jm‚na souboru

Start1:  jcxz      Start12                  ; nen¡ nic zad no
         mov       dx,si                    ; za‡ tek jm‚na souboru
         lodsb                              ; na‡ten¡ znaku
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e znak–
         cmp       al," "
         je        Start1                   ; oddˆlovac¡ mezera
         cmp       al,9
         je        Start1
         cmp       al,"?"
         je        Start12
         cmp       al,"*"
         je        Start12
         cmp       al,"/"
         jne       Start2
Start12: mov       dx,offset HelpTxt        ; n povˆda
         jmp       short Chyba              ; parametr

; ------ nalezen¡ konce jm‚na souboru

Start2:  mov       di,si                    ; konec jm‚na souboru
         jcxz      Start3
         lodsb
         dec       cx
         cmp       al," "
         ja        Start2

; ------ koncov  te‡ka

Start3:  dec       di
         dec       di
         dec       di
         mov       al,"."
         cmp       byte ptr ds:[di-1],al
         je        Start4
         inc       di
         cmp       byte ptr ds:[di-1],al
         je        Start4
         inc       di
         cmp       byte ptr ds:[di-1],al
         je        Start4
         inc       di
         cmp       byte ptr ds:[di-1],al
         je        Start4
         stosb

; ------ otev©en¡ datov‚ho souboru DBF

Start4:  mov       word ptr ds:[di],"BD"    ; p©¡pona DBF
         mov       word ptr ds:[di+2],"F"
         mov       ax,3d00h
         int       21h                      ; otev©en¡ pro ‡ten¡
         mov       ds:[SoubDbf],ax          ; datov˜ soubor
         jnc       Start5                   ; soubor otev©en OK

; ------ zobrazen¡ n povˆdy

         mov       dx,offset NeniTxt        ; text - nenalezen
Chyba:   mov       ah,9
         int       21h
         int       20h

; ------ test, zda v˜stupn¡ soubor DAT ji‘ existuje

Start5:  mov       word ptr ds:[di],"AD"
         mov       word ptr ds:[di+2],"T"
         xor       cx,cx                    ; atributy
         mov       ah,4eh
         int       21h                      ; nalezen¡ v˜stupn¡ho souboru
         jc        Start6
         mov       dx,offset ExistTxt
         jmp       short Chyba

; ------ otev©en¡ v˜stupn¡ho souboru

Start6:  mov       ah,3ch
         xor       cx,cx
         int       21h                      ; vytvo©en¡ v˜stupn¡ho souboru
Start62: mov       dx,offset WritTxt        ; chyba z pisu
         jc        Chyba                    ; chyba vytvo©en¡ souboru
         mov       ds:[SoubDat],ax          ; v˜stupn¡ soubor

; ------ na‡ten¡ z hlav¡ souboru

         mov       dx,offset HeadDBF
         mov       cx,32                    ; d‚lka z hlav¡
         mov       ah,3fh
         mov       bx,ds:[SoubDBF]
         int       21h                      ; na‡ten¡ z hlav¡
         jc        Start62
         cmp       ax,cx
         jne       Start62

; ------ kontrola, zda se z hlav¡ vejde do pamˆti

         mov       ax,ds:[HeadByte]
         add       ax,dx
         add       ax,200h
         cmp       ax,sp
         mov       dx,offset MemTxt
         jae       Start62                  ; nedostatek pamˆti

; ------ na‡ten¡ z hlav¡ do pamˆti

         mov       cx,ds:[HeadByte]
         sub       cx,32
         mov       dx,offset TabPopis
         mov       ah,3fh
         int       21h                      ; na‡ten¡ definice polo‘ek
         jc        Start62
         cmp       ax,cx
         jne       Start62
         add       ds:[AdrBuff],cx          ; adresa k na‡ten¡ z znamu

; ------ kontrola, zda se 1 z znam vejde do pamˆti

         mov       ax,ds:[AdrBuff]          ; adresa bufferu z znamu
         add       ax,ds:[ZaznByte]
         add       ax,200h
         cmp       ax,sp
         jae       Start62                  ; nedostatek pamˆti

; ------ na‡ten¡ jednoho z znamu

Start8:  mov       dx,ds:[AdrBuff]
         mov       cx,ds:[ZaznByte]
         mov       ah,3fh
         mov       bx,ds:[SoubDbf]
         int       21h                      ; na‡ten¡ z znamu
         jc        Start98
         cmp       ax,cx
         jne       Start98

; ------ korekce © dku

         dec       cx                       ; bez £vodn¡ho bajtu
         inc       dx
         mov       si,dx
         mov       di,si
         cld
Start82: lodsb
         cmp       al," "
         jne       Start85
         cmp       byte ptr ds:[si]," "
         jne       Start85
         mov       al,9
         stosb
         dec       cx
         jz        Start86
Start83: lodsb
         cmp       al," "
         jne       Start85
         loop      Start83
         jmp       short Start86

Start85: stosb
         loop      Start82

Start86: cmp       byte ptr ds:[di-1],9
         jne       Start87
         dec       di
Start87: ;mov       al,13
         ;stosb
         mov       al,10
         stosb

; ------ z pis © dku

         sub       di,dx
         mov       cx,di
         mov       bx,ds:[SoubDat]
         mov       ah,40h
         int       21h
         jnc       Start8

; ------ uzav©en¡ soubor–

Start98: mov       bx,ds:[SoubDbf]
         mov       ah,3eh
         int       21h
         mov       bx,ds:[SoubDat]
         mov       ah,3eh
         int       21h
         int       20h

; -----------------------------------------------------------------------------
;        Data
; -----------------------------------------------------------------------------
;þ
SoubDbf  dw        0                        ; identifik tor vstupn¡ho souboru
SoubDat  dw        0                        ; identifik tor v˜stupn¡ho souboru

UvTxt    db        'SEZNDAT V1.0 - konverze DBF na seznam; (c) Miroslav Nemecek',13,10,'$'

NeniTxt  db        'Zadany vstupni soubor DBF nenalezen !',13,10
HelpTxt  db        '  Zadejte JMENO souboru DBF ke konverzi do seznamu.',13,10
         db        '  Bude zkonvertovan soubor JMENO.DBF na JMENO.DAT.',13,10,'$'

ExistTxt db        'Vystupni soubor DAT jiz existuje !',13,10,'$'
MemTxt   db        'Nedostatek pameti k provedeni konverze !',13,10,'$'
WritTxt  db        'Chyba zapisu do vystupniho souboru DAT !',13,10,'$'

Nadpis   db        300 dup(" ")             ; nadpis
Maska    db        300 dup("#")             ; maska

AdrBuff  dw        offset TabPopis

; ------ z hlav¡ souboru DBF

HeadDBF  label     byte
Verze    db        3                        ; 0: verze datab ze
Rok      db        0                        ; 1: rok
Mesic    db        1                        ; 2: mˆs¡c
Den      db        1                        ; 3: den
PocVet   dd        0                        ; 4: po‡et vˆt
HeadByte dw        33                       ; 8: velikost z hlav¡ (bajt–)
ZaznByte dw        1                        ; 0Ah: d‚lka z znamu (bajt–)
         db        20 dup(0)                ; 0Ch:  ... rezervov no
TabPopis label     byte                     ; 20h: tabulka popisova‡–

; Popisova‡ (ka‘d˜ 32 bajt–, za posledn¡m popisova‡em je 0Dh):
;             0 (11) jm‚no polo‘ky ASCIIZ (s 0 na konci)
;            11 (1) typ polo‘ky (C, N, F, L, D nebo M)
;                          typ C (Character): text doplnˆn¡ zprava mezerami
;                                             d‚lka max. 254 znak–
;                          typ N (Numeric): ‡¡slo s pevnou desetinnou te‡kou,
;                                           znaky "0" a‘ "9","-", "+" a "."
;                                           max. 20 pozic (max. 15 des. m¡st)
;                          typ F (Float): re ln‚ ‡¡slo s pohyblivou te‡kou,
;                                           max. 20 pozic (max. 15 des. m¡st),
;                                           rozsah 0.9xE+308 a‘ 0.1xE-307,
;                                           max. 15 ‡¡slic p©ed te‡kou a 9 za
;                          typ L (Logical): hodnoty Y,y,N,n,T,t,F,f,mezera
;                          typ D (Date): osum ‡¡slic RRRRMMDD
;                          typ M (Memo): deset ‡¡slic - ‡¡slo po‡ te‡n¡ho bloku
;                                        .DBT textu k polo‘ce
;                          typ P (Picture): (pouze FOXPRO)
;            12 (4) adresa obsahu polo‘ky v pamˆti
;            16 (1) d‚lka polo‘ky v z znamu (bajt–)
;            17 (1) po‡et desetinn˜ch m¡st
;            18 (2) ... rezervov no
;            20 (1) ozna‡en¡ pracovn¡ oblasti
;            21 (2) ... rezervov no
;            23 (1) n vˆ¨t¡ pro SET FIELDS TO (...)
;            24 (8) ... rezervov no
;
; z znam:     0 (1) p©¡znak zru¨en‚ polo‘ky - "*"=zru¨en , jinak " "
;             1 (x) polo‘ky (n sleduj¡ bezprost©ednˆ za sebou)

Code     ENDS
         END       Start

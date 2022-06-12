
Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; ------ zobrazen¡ £vodn¡ho textu

Start:   mov       dx,offset UvTxt
         mov       ah,9
         int       21h                      ; zobrazen¡ £vodn¡ho textu

; ------ p©¡prava aktu ln¡ho data do z hlav¡

         mov       ah,2ah
         int       21h                      ; poskytnut¡ syst‚mov‚ho data
         sub       cx,1900
         mov       ds:[Rok],cl              ; rok
         mov       ds:[Mesic],dh            ; mˆs¡c
         mov       ds:[Den],dl              ; den

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
         je        Start33
         inc       di
         cmp       byte ptr ds:[di-1],al
         je        Start33
         inc       di
         cmp       byte ptr ds:[di-1],al
         je        Start33
         inc       di
         cmp       byte ptr ds:[di-1],al
         je        Start33
         stosb

; ------ otev©en¡ defini‡n¡ho souboru

Start33: mov       word ptr ds:[di],"ED"    ; p©¡pona "DEF"
         mov       word ptr ds:[di+2],"F"
         mov       ax,3d00h
         int       21h                      ; otev©en¡ pro ‡ten¡
         jc        Start4                   ; chyba
         mov       ds:[SoubDef],ax          ; defini‡n¡ soubor

; ------ otev©en¡ datov‚ho souboru

Start4:  mov       word ptr ds:[di],"AD"    ; p©¡pona DAT
         mov       word ptr ds:[di+2],"T"
         mov       ax,3d00h
         int       21h                      ; otev©en¡ pro z pis
         mov       ds:[SoubDat],ax          ; datov˜ soubor
         jnc       Start5                   ; soubor otev©en OK

; ------ zobrazen¡ n povˆdy

         mov       dx,offset NeniTxt        ; text - nenalezen
Chyba:   mov       ah,9
         int       21h
         int       20h

; ------ test, zda v˜stupn¡ soubor DBF ji‘ existuje

Start5:  mov       word ptr ds:[di],"BD"
         mov       word ptr ds:[di+2],"F"
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
         mov       ds:[SoubDbf],ax          ; v˜stupn¡ soubor

; ------ na‡ten¡ © dku nadpisu a masky z defini‡n¡ho souboru

         mov       bx,ds:[SoubDef]          ; defini‡n¡ soubor
         or        bx,bx                    ; soubor otev©en ?
         jz        Start7                   ; soubor neotev©en
         mov       di,offset Nadpis         ; buffer © dku nadpisu
         call      ReadLine                 ; na‡ten¡ © dku nadpisu
         mov       di,offset Maska
         call      ReadLine                 ; na‡ten¡ © dku masky

; ------ p©¡prava k rozboru polo‘ek

Start7:  mov       si,offset Maska          ; definice masky
         mov       di,offset TabPopis       ; tabulka popisova‡–
         mov       cx,300                   ; po‡et bajt– masky
         cld

; ------ kontrola, zda zb˜v  voln  pamˆŸ k ulo‘en¡ popisova‡e

Start8:  mov       ax,di                    ; ukl dac¡ adresa popisova‡–
         add       ax,32+200h               ; rezerva
         cmp       ax,sp                    ; zb˜v  dost pamˆti ?
         mov       dx,offset MemTxt         ; chyba pamˆti
         jae       Chyba                    ; chyba pamˆti

; ------ jm‚no polo‘ky

         mov       ax,ds:[JmenPol]          ; jm‚no polo‘ky
         cmp       ah,"0"
         jne       Start80
         mov       ah,0                     ; korekce
Start80: stosw                              ; jm‚no polo‘ky
         inc       al
         cmp       al,"Z"
         jbe       Start802
         mov       al,"A"
         inc       ah
Start802:mov       ds:[JmenPol],ax

; ------ inicializace nov‚ho popisova‡e

         push      cx
         mov       cx,(32-2)/2              ; d‚lka bufferu popisova‡e
         xor       ax,ax
         rep       stosw                    ; vynulov n¡ popisova‡e
         pop       cx
         mov       byte ptr ds:[di-32+11],"C" ; znakov  polo‘ka

; ------ nalezen¡ za‡ tku masky

         mov       dx,si                    ; za‡ tek masky
         mov       bx,si                    ; konec masky
Start81: jcxz      Start83                  ; konec masky
         mov       dx,si                    ; £schova za‡ tku masky
         lodsb                              ; na‡ten¡ znaku
         dec       cx                       ; ‡¡ta‡ zbyl˜ch znak–
         cmp       al,"#"
         jne       Start81                  ; nalezen¡ za‡ tku polo‘ky

; ------ nalezen¡ konce masky

Start82: jcxz      Start83                  ; konec masky
         mov       bx,si                    ; konec masky
         lodsb                              ; na‡ten¡ znaku
         dec       cx                       ; ‡¡ta‡ zbyl˜ch znak–
         cmp       al,"#"
         je        Start82                  ; nalezen¡ konce masky

; ------ stanoven¡ d‚lky polo‘ky

Start83: sub       bx,dx                    ; d‚lka polo‘ky
         jbe       Start88                  ; konec polo‘ek
         or        bh,bh
         jz        Start84
         mov       bx,255
Start84: mov       ds:[di-32+16],bl         ; d‚lka polo‘ky
         add       ds:[ZaznByte],bx         ; zv˜¨en¡ ‡¡ta‡e d‚lky z znamu
         add       word ptr ds:[HeadByte],32 ; zv˜¨en¡ velikosti z hlav¡
         jmp       short Start8             ; dal¨¡ polo‘ka

; ------ konec masek - z pis z hlav¡ souboru

Start88: sub       di,32
         mov       byte ptr ds:[di],13      ; ozna‡en¡ konce z hlav¡
         mov       cx,ds:[HeadByte]         ; velikost z hlav¡
         mov       bx,ds:[SoubDbf]          ; soubor DBF
         mov       ah,40h
         mov       dx,offset HeadDbf        ; z hlav¡
         int       21h                      ; z pis z hlav¡ souboru
         jnc       Start89                  ; operace OK
Start882:mov       dx,offset WritTxt
         jmp       Chyba

Start89: cmp       word ptr ds:[ZaznByte],1 ; je nˆjak˜ z znam ?
         jbe       Start882                 ; nen¡ ‘ dn˜ z znam

; ------ konverze dat souboru

Start9:  mov       di,offset Zaznam         ; buffer jednoho z znamu
         mov       bx,ds:[SoubDat]          ; datov˜ soubor
         call      ReadLine                 ; na‡ten¡ © dku
         jc        Start96                  ; konec souboru

         mov       bx,ds:[SoubDbf]
         mov       dx,offset Zaznam0
         mov       cx,ds:[ZaznByte]         ; d‚lka z znamu
         mov       ah,40h
         int       21h                      ; z pis dat
         jc        Start882                 ; chyba z pisu
         cmp       ax,cx
         jne       Start882                 ; disk pln˜

         add       word ptr ds:[PocVet],1   ; zv˜¨en¡ ‡¡ta‡e vˆt
         adc       word ptr ds:[PocVet+2],0
         jmp       short Start9

; ------ z pis EOF na konec souboru

Start96: mov       dx,offset Eof
         mov       cx,1
         mov       bx,ds:[SoubDbf]
         mov       ah,40h
         int       21h

; ------ z pis nov‚ho z hlav¡

         xor       cx,cx
         xor       dx,dx
         mov       ax,4200h
         int       21h

         mov       cx,32                    ; velikost z hlav¡
         mov       ah,40h
         mov       dx,offset HeadDbf        ; z hlav¡
         int       21h                      ; z pis z hlav¡ souboru
         jc        Start882

; ------ uzav©en¡ soubor–

Start98: mov       bx,ds:[SoubDef]
         or        bx,bx
         jz        Start99                  ; nebyl otev©en
         mov       ah,3eh
         int       21h                      ; uzav©en¡ souboru
Start99: mov       bx,ds:[SoubDat]
         mov       ah,3eh
         int       21h
         mov       bx,ds:[SoubDbf]
         mov       ah,3eh
         int       21h
         int       20h

; -----------------------------------------------------------------------------
;        na‡ten¡ © dku ze souboru BX do bufferu (ES) DS:DI (CY=konec)
; -----------------------------------------------------------------------------

ReadLine PROC      NEAR

; ------ na‡ten¡ maxima dat

         mov       bp,di                    ; BP <- adresa za‡ tku bufferu
         mov       dx,di                    ; buffer © dku
         mov       ah,3fh
         mov       cx,300                   ; po‡et bajt–
         int       21h                      ; na‡ten¡ obsahu bufferu
         jnc       ReadLin1
         xor       ax,ax                    ; p©i chybˆ konec
ReadLin1:xchg      ax,cx                    ; CX <- po‡et na‡ten˜ch bajt–
         stc                                ; p©¡znak chyby
         jcxz      ReadLin9                 ; nebylo nic na‡teno - konec

; ------ nalezen¡ konce dat LF s vypu¨tˆn¡m v¨ech CR a EOF

         mov       si,di                    ; buffer © dku
         cld
ReadLin2:lodsb                              ; na‡ten¡ znaku
         cmp       al,26
         je        ReadLin3                 ; EOF se ignoruje
         cmp       al,13
         je        ReadLin3                 ; CR se ignoruje
         cmp       al,10
         je        ReadLin4                 ; konec © dku LF
         stosb                              ; ulo‘en¡ znaku
ReadLin3:loop      ReadLin2                 ; dal¨¡ znak

; ------ n vrat ukazatele souboru o p©ebytek © dku zpˆt

         inc       cx
ReadLin4:dec       cx                       ; korekce ukazatele
         jz        ReadLin5
         mov       dx,cx                    ; p©ebytek © dku LOW
         neg       dx                       ; z porn˜ offset
         mov       cx,-1                    ; p©ebytek © dku HIGH
         mov       ax,4201h
         int       21h                      ; n vrat ukazatele v souboru

; ------ vymaz n¡ zbytku © dku

ReadLin5:mov       cx,bp                    ; adresa za‡ tku © dku
         add       cx,300                   ; konec bufferu
         sub       cx,di                    ; zbytek © dku
         mov       al," "                   ; mazac¡ mezera
         cld
         rep       stosb                    ; vymaz n¡ zbytku © dku

         clc                                ; p©¡znak operace OK
ReadLin9:ret

ReadLine ENDP

; -----------------------------------------------------------------------------
;        Data
; -----------------------------------------------------------------------------
;þ
SoubDef  dw        0                        ; identifik tor defini‡n¡ho souboru
SoubDat  dw        0                        ; identifik tor vstupn¡ho souboru
SoubDbf  dw        0                        ; identifik tor v˜stupn¡ho souboru

Eof      db        1ah                      ; p©¡znak konce souboru

UvTxt    db        'SEZNDBF V1.0 - konverze seznamu do DBF; (c) Miroslav Nemecek',13,10,'$'

NeniTxt  db        'Zadany vstupni soubor DAT nenalezen !',13,10
HelpTxt  db        '  Zadejte JMENO souboru seznamu ke konverzi do DBF.',13,10
         db        '  Bude zkonvertovan soubor JMENO.DAT s definici JMENO.DEF',13,10
         db        '  do vystupniho souboru JMENO.DBF.',13,10,'$'

ExistTxt db        'Vystupni soubor DBF jiz existuje !',13,10,'$'
MemTxt   db        'Nedostatek pameti k provedeni konverze !',13,10,'$'
WritTxt  db        'Chyba zapisu do vystupniho souboru DBF !',13,10,'$'

Nadpis   db        300 dup(" ")             ; nadpis
Maska    db        300 dup("#")             ; maska

Zaznam0  db        ' '                      ; p©¡znak zru¨en‚ polo‘ky
Zaznam   db        300 dup(" ")             ; buffer jednoho z znamu

JmenPol  dw        '0A'                     ; ukazatel ‡¡sel polo‘ek

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
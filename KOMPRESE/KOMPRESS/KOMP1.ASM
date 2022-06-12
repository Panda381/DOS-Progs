
; *****************************************************************************
;                                  Komprese dat
; *****************************************************************************

buffsize equ       4096                     ; velikost kruhovÇho bufferu
null     equ       buffsize                 ; nulovac° slovo - koncov† poloëka
matchlim equ       18                       ; maxim†ln° dÇlka shody
threshld equ       2                        ; minim†ln° dÇlka shody


code     SEGMENT
         ASSUME    cs:code,ds:code
         ORG       100h
komp:    jmp       komp1                    ; skok na start programu

         dw        offset konec             ; konec programu

komp1:                                    ;* vstupn° souboru
         mov       di,offset commbuf        ; buffer p©°kazovÇho ©†dku
         call      parnorm                  ; normalizace zadanòch parametrñ
         jc        chyba                    ; nen° ë†dnò parametr
         mov       si,offset commbuf        ; buffer p©°kazovÇho ©†dku
         xor       cx,cx                    ; á°slo parametru = 0
         call      parget                   ; poskytnut° adresy parametru 0
         jc        chyba                    ; nen° prvn° parametr
         mov       dx,si                    ; specifikace vstupn°ho souboru
         mov       ax,3d00h
         int       21h
         jc        chyba
         mov       ds:[inpid],ax
                                          ;* vòstupn° soubor
         mov       si,offset commbuf        ; buffer p©°kazovÇho ©†dku
         mov       cx,1                     ; á°slo parametru = 1
         call      parget                   ; poskytnut° adresy parametru 1
         jc        chyba                    ; nen° druhò parametr
         mov       dx,si                    ; druhò parametr
         mov       ah,3ch
         xor       cx,cx
         int       21h
         jc        chyba
         mov       ds:[outid],ax


         call      kode                     ; zak¢dov†n° souboru LZSS

navrat:  call      writefbuf                ; vypr†zdnàn° vòstupn°ho bufferu
         mov       ax,4c00h
         int       21h

chyba:   mov       dx,offset errtxt
         mov       ah,9
         int       21h
         mov       ax,4c01h
         int       21h

; -----------------------------------------------------------------------------
;                      K¢dov†n° LZSS - kruhovò buffer
; -----------------------------------------------------------------------------
public   kode
kode:                                     ;* zak¢dov†n° jednoho souboru
         call      inittree                 ; inicializace stromu bufferu
         mov       byte ptr ds:[codebuf],0  ; nastaven° p©°znaku pozic
         mov       dh,1                     ; maska
         mov       di,offset codebuf +1     ; buffer k¢dñ
         mov       word ptr ds:[ukazs],0
         mov       word ptr ds:[ukazr],buffsize-matchlim ; dÇlka bufferu
         mov       byte ptr ds:[len],0      ; dÇlka = 0
                                          ;* naáten° MATCHLIM bajtu na konec
         push      di
         mov       cx,matchlim              ; max. dÇlka shody
         mov       di,offset (textbuf+buffsize-matchlim) ; zaá†tek oblasti MATCHLIM
kode2:   call      rbyte                    ; áten° bajtu ze souboru
         jbe       kode3                    ; chyba nebo konec souboru
         stosb                              ; uloëen° bajtu do bufferu
         inc       byte ptr ds:[len]        ; zvò®en° á°taáe dÇlky dat
         loop      kode2                    ; naáten° dal®°ho bajtu
kode3:   pop       di
         cmp       byte ptr ds:[len],0      ; je nàjakò bajt ?
         jne       kode33                   ; v bufferu je nàjakò znak
         ret                                ; n†vrat, pokud je pr†zdnò soubor

kode33:                                   ;* inicializaán° uloëen° ©etàzcñ
         mov       cx,matchlim              ; poáet znakñ
         mov       si,ds:[ukazr]            ; ukazatel konce bufferu
kode34:  dec       si
         call      insertn                  ; vloëen° ©etàzce mezer
         loop      kode34                   ; dal®° ©etàzec

         mov       si,ds:[ukazr]            ; ukazatel ukl†dac° adresy
         call      insertn                  ; vloëen° naátenÇho ©etàzce

                                          ;* zaá†tek cyklu k¢dov†n°
                                            ; DH=maska pro k¢dov†n°
                                            ; DL=dÇlka shody
                                            ; BX=index shodnÇho ©etàzce
                                            ; DI=ukl†dac° adresa do buff. k¢du

kode4:                                    ;* omezen° dÇlky shody
         cmp       dl,ds:[len]              ; je dÇlka shody > bajty v buff. ?
         jbe       kode5                    ; nen° vàt®°
         mov       dl,ds:[len]              ; omezen° dÇlky shody
kode5:                                    ;* p©°li® kr†tk† shoda - nen° kompr.
         cmp       dl,threshld              ; je dostateán† dÇlka shody ?
         ja        kode6                    ; je dostateán† dÇlka shody
         mov       dl,1                     ; omezen° dÇlky shody na 1
         or        byte ptr ds:[codebuf],dh ; informace, ëe je p©°mò bajt
         mov       si,ds:[ukazr]            ; átec° index z bufferu
         mov       al,ds:[si+textbuf]       ; vkl†danò znak z bufferu
         jmp       short kode8
kode6:                                    ;* dostateán† shoda - je komprese
         mov       al,bl                    ; nië®° bajt indexu shody
         stosb                              ; uloëen° LOW indexu shody
         mov       al,bh                    ; vy®®° bajt indexu shody
         mov       cl,4
         shl       al,cl
         add       al,dl                    ; dÇlka shody do nië®°ch 4 bitñ
         sub       al,threshld+1            ; korekce od 0
kode8:                                    ;* vypr†zdnàn° bufferu k¢du
         stosb                              ; uloëen° vy®®°ho bajtu/znaku
         shl       dh,1                     ; rotace masky o 1 bit vlevo
         or        dh,dh
         jnz       kodea                    ; nen° je®tà 0 - dal®°
         mov       cx,di                    ; konec uloëenòch dat
         mov       si,offset codebuf        ; buffer k¢du
         sub       cx,si                    ; poáet bajtñ v bufferu
kode9:   lodsb                              ; bajt k vysl†n°
         call      wbyte                    ; z†pis bajtu do souboru
         loop      kode9                    ; z†pis dal®°ho bajtu
         mov       dh,1                     ; maska k¢du
         mov       di,offset codebuf +1     ; buffer k¢dñ
         mov       byte ptr ds:[di-1],0     ; nulov†n° identifikace k¢du
kodea:                                    ;* naáten° dal®°ch dat
         xor       cx,cx                    ; CX <- 0
         mov       cl,dl                    ; dÇlka shody
kodeb:   mov       si,ds:[ukazs]
         call      deleten                  ; zru®en° starÇho ©etàzce
         call      rbyte                    ; áten° dal®°ho znaku ze souboru
         jbe       kodef                    ; chyba nebo konec souboru
         mov       si,ds:[ukazs]            ; ukazatel ukl†dac° adresy
         mov       ds:[si+textbuf],al       ; uloëen° znaku do bufferu
         cmp       si,matchlim-1            ; je na zaá†tku bufferu ?
         jae       kodec                    ; nen° na zaá†tku bufferu
         mov       ds:[si+textbuf+buffsize],al ; zvojen° i na konec bufferu
kodec:   inc       si                       ; zvò®en° ukl†dac° adresy
         cmp       si,buffsize              ; je za koncem bufferu ?
         jb        koded                    ; nen° je®tà za koncem bufferu
         xor       si,si                    ; ukazatel na zaá†tek bufferu
koded:   mov       ds:[ukazs],si            ; nov† ukl†dac° adresa
         mov       si,ds:[ukazr]            ; átec° adresa
         inc       si                       ; zvò®en° átec° adresy
         cmp       si,buffsize              ; je za koncem bufferu ?
         jb        kodee                    ; nen° je®tà za koncem bufferu
         xor       si,si                    ; ukazatel na zaá†tek bufferu
kodee:   mov       ds:[ukazr],si            ; nov† átec° adresa
         call      insertn                  ; vloëen° novÇ ©etàzce
         loop      kodeb                    ; naáten° dal®°ho bajtu ze souboru

         jmp       short kodeg              ; nen° je®tà konec souboru

kodef:                                    ;* konec souboru - zru®en° zbylòch ©.
         mov       si,ds:[ukazs]
         call      deleten                  ; zru®en° vàtve
         mov       si,ds:[ukazs]            ; ukazatel ukl†dac° adresy
         inc       si                       ; zvò®en° ukl†dac° adresy
         cmp       si,buffsize              ; je za koncem bufferu ?
         jb        kodeh                    ; nen° je®tà za koncem bufferu
         xor       si,si                    ; ukazatel na zaá†tek bufferu
kodeh:   mov       ds:[ukazs],si            ; nov† ukl†dac° adresa
         mov       si,ds:[ukazr]            ; átec° adresa
         inc       si                       ; zvò®en° átec° adresy
         cmp       si,buffsize              ; je za koncem bufferu ?
         jb        kodei                    ; nen° je®tà za koncem bufferu
         xor       si,si                    ; ukazatel na zaá†tek bufferu
kodei:   mov       ds:[ukazr],si            ; nov† átec° adresa
         dec       byte ptr ds:[len]
         cmp       byte ptr ds:[len],0
         je        kodej
         mov       si,ds:[ukazr]            ; novà naátenò ©etàzec
         call      insertn                  ; vloëen° novÇ ©etàzce
kodej:   loop      kodef                    ; dal®° znak

kodeg:   cmp       byte ptr ds:[len],0
         jbe       kodel                    ; konec
         jmp       kode4                    ; dal®° k¢d

kodel:                                    ;* vypr†zdnàn° zbytku bufferu k¢du

         mov       cx,di                    ; konec uloëenòch dat
         mov       si,offset codebuf        ; buffer k¢du
         sub       cx,si                    ; poáet bajtñ v bufferu
         jcxz      koden                    ; nen° dal®° znak
kodem:   lodsb                              ; bajt k vysl†n°
         call      wbyte                    ; z†pis bajtu do souboru
         loop      kodem                    ; z†pis dal®°ho bajtu
koden:   ret


; -----------------------------------------------------------------------------
public   inittree
inittree:                                 ;* inicializace hledac°ho stromu

         mov       cx,offset (konini-zacini)/2 ; velikost bufferñ ve slovech
         mov       di,offset zacini         ; zaá†tek bufferñ
         mov       ax,null                  ; nulovac° slovo
         cld                                ; smàr nahoru
         rep       stosw                    ; vymaz†n° bufferñ
                                          ;* inicializace kruhovÇho bufferu
         mov       di,offset textbuf        ; kruhovò buffer
         mov       cx,buffsize + matchlim   ; velikost kruhovÇho bufferu
         mov       al," "                   ; znak mezery
         rep       stosb                    ; vymaz†n° kruhovÇho bufferu

         ret

; -----------------------------------------------------------------------------
public   insertn
insertn:                                  ;* vloëen° ©etàzce do stromu
                                            ; VSTUP: SI=index ©etàzce
                                            ; VùSTUP: DL=dÇlka shody
                                            ;         BX=index shodnÇho ©etàzce


         push      ax
         push      cx
         push      si
         push      di

         mov       byte ptr ds:[comp],1     ; p©°znak porovn†n° ©etàzcñ

         mov       di,word ptr ds:[si+textbuf] ; poá†teán° znak ©etàzce
         and       di,0ffh                  ; ponech† znak ©etàzce
         add       di,buffsize + 1          ; index v bufferu

         push      si
         add       si,si                    ; index * 2
         mov       ds:[si+rson],null        ; inicializace ©etàzce
         mov       ds:[si+lson],null        ; inicializace ©etàzce
         pop       si

         xor       dl,dl                    ; dÇlka shody = 0

insertn1:                                 ;* zaá†tek cyklu vyhled†v†n°
         cmp       byte ptr ds:[comp],0     ; je p©°znak porovn†n° >= 0 ?
         jl        insertn3                 ; p©°znak porovn†n° je z†pornò

         push      di
         add       di,di
         mov       ax,ds:[di+rson]
         pop       di
         cmp       ax,null                  ; je konec ?
         je        insertn2

         mov       di,ax
         jmp       short insertn7

insertn2:push      di
         add       di,di
         mov       ds:[di+rson],si
         pop       di
         push      si
         add       si,si
         mov       ds:[si+dad],di
         pop       si
         jmp       insertnx                 ; konec


insertn3:
         push      di
         add       di,di
         mov       ax,ds:[di+lson]
         pop       di
         cmp       ax,null                  ; je konec ?
         je        insertn4
         mov       di,ax
         jmp       short insertn7

insertn4:push      di
         add       di,di
         mov       ds:[di+lson],si
         pop       di
         push      si
         add       si,si
         mov       ds:[si+dad],di
         pop       si
         jmp       insertnx                 ; konec


insertn7:                                 ;* porovn†n° ©etàzcñ
         mov       cx,matchlim-1            ; max. dÇlka textu
         push      si
         push      di
insertn8:inc       si
         inc       di
         mov       al,ds:[si+textbuf]
         sub       al,ds:[di+textbuf]
         jnz       insert88
         loopz     insertn8                 ; je shoda - dal®° znak
insert88:pop       di
         pop       si
         mov       ds:[comp],al             ; rozd°l znakñ

         mov       al,matchlim              ; maxim†ln° dÇlka ©etàzce
         sub       al,cl                    ; poáet shodnòch znakñ
         cmp       al,dl                    ; je del®° ©etàzec ?
         jbe       insertna                 ; nen° del®° ©etàzec
                                          ;* nalezen vàt®° ©etàz
         mov       bx,di                    ; nov† pozice
         mov       dl,al                    ; dÇlka novÇho ©etàzce
         cmp       dl,matchlim              ; je maxim†ln° ©etàzec ?
         jae       insertnd                 ; je maxim†ln° ©etàzec
insertna:
         jmp       insertn1                 ; dal®° test
                                          ;* je velmi dlouh† shoda
insertnd:
         push      di
         add       di,di
         mov       ax,ds:[di+dad]
         pop       di
         push      si
         add       si,si
         mov       ds:[si+dad],ax
         pop       si

         push      di
         add       di,di
         mov       ax,ds:[di+lson]
         pop       di
         push      si
         add       si,si
         mov       ds:[si+lson],ax
         pop       si

         push      di
         add       di,di
         mov       ax,ds:[di+rson]
         pop       di
         push      si
         add       si,si
         mov       ds:[si+rson],ax
         pop       si

         push      di
         add       di,di
         mov       ax,ds:[di+rson]
         mov       di,ds:[di+lson]
         add       di,di
         mov       ds:[di+dad],si
         mov       di,ax
         add       di,di
         mov       ds:[di+dad],si
         pop       di

         push      di
         mov       ax,di
         add       di,di
         mov       di,ds:[di+dad]
         add       di,di
         cmp       ds:[di+rson],ax
         jne       insertne
         mov       ds:[di+rson],si
         jmp       short insertnf
insertne:mov       ds:[di+lson],si
insertnf:pop       di

         push      di
         add       di,di
         mov       word ptr ds:[di+dad],null
         pop       di

insertnx:
         pop       di
         pop       si
         pop       cx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   deleten
deleten:                                  ;* zru®en° ©etàzce
                                            ; VSTUP: SI=index ©etàzce

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di

         push      si
         add       si,si
         cmp       word ptr ds:[si+dad],null
         pop       si
         jne       deleten1
         jmp       deleten9

deleten1:push      si
         add       si,si
         cmp       word ptr ds:[si+rson],null
         pop       si
         jne       deleten2

         push      si
         add       si,si
         mov       di,ds:[si+lson]
         pop       si
         jmp       deleten6

deleten2:
         push      si
         add       si,si
         cmp       word ptr ds:[si+lson],null
         pop       si
         jne       delete22

         push      si
         add       si,si
         mov       di,ds:[si+rson]
         pop       si
         jmp       short deleten6

delete22:

         push      si
         add       si,si
         mov       di,ds:[si+lson]
         pop       si

         push      di
         add       di,di
         cmp       word ptr ds:[di+rson],null
         pop       di
         je        deleten4

deleten3:add       di,di
         mov       di,ds:[di+rson]

         push      di
         add       di,di
         cmp       word ptr ds:[di+rson],null
         pop       di
         jne       deleten3

         push      di
         add       di,di
         mov       ax,ds:[di+lson]
         mov       di,ds:[di+dad]
         add       di,di
         mov       ds:[di+rson],ax
         pop       di

         push      di
         add       di,di
         mov       ax,ds:[di+dad]
         mov       di,ds:[di+lson]
         add       di,di
         mov       ds:[di+dad],ax
         pop       di

         push      si
         add       si,si
         mov       ax,ds:[si+lson]
         pop       si
         push      di
         add       di,di
         mov       ds:[di+lson],ax
         pop       di

         push      si
         mov       si,ax
         add       si,si
         mov       ds:[si+dad],di
         pop       si

deleten4:
         push      si
         add       si,si
         mov       ax,ds:[si+rson]
         pop       si
         push      di
         add       di,di
         mov       ds:[di+rson],ax
         pop       di

         push      si
         mov       si,ax
         add       si,si
         mov       ds:[si+dad],di
         pop       si


deleten6:

         push      si
         add       si,si
         mov       ax,ds:[si+dad]
         pop       si
         push      di
         add       di,di
         mov       ds:[di+dad],ax
         pop       di

         push      si
         add       si,si
         mov       ax,ds:[si+dad]
         pop       si
         push      di
         mov       di,ax
         add       di,di
         cmp       ds:[di+rson],si
         pop       di
         jne       deleten7

         push      si
         mov       si,ax
         add       si,si
         mov       ds:[si+rson],di
         pop       si
         jmp       short deleten8

deleten7:
         push      si
         mov       si,ax
         add       si,si
         mov       ds:[si+lson],di
         pop       si
deleten8:
         add       si,si
         mov       word ptr ds:[si+dad],null
deleten9:
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret
; -----------------------------------------------------------------------------
;                       Rozbor p©°kazovÇho ©†dku
; -----------------------------------------------------------------------------
public   parnorm
parnorm:                                  ;* normalizace zadanòch parametrñ
                                            ; VSTUP: ES:DI=ukl†dac° adresa
                                            ;        DS=segment PSP
                                            ; VùSTUP: CX=poáet parametrñ
                                            ;         ZY=nen° ë†dnò parametr

         push      ax
         push      si
         push      di
         cld                                ; smàr nahoru
         xor       cx,cx                    ; á°taá parametrñ
         mov       si,81h                   ; zaá†tek parametrñ
         push      si
         add       si,ds:[si-1]             ; konec parametrñ
         and       si,0ffh                  ; adresa konce textu
         mov       byte ptr ds:[si],0       ; oznaáen° konce textu
         pop       si
                                          ;* nalezen° zaá†tku parametru
parnorm1:call      parread                  ; naáten° znaku parametrñ
         jc        parnorm2                 ; je konec textu
         jz        parnorm1                 ; je oddàlovaá - dal®° znak
         inc       cx                       ; zvò®en° á°taáe parametrñ
parnorm3:                                 ;* p©enesen° textu
         stosb                              ; uloëen° platnÇho znaku
         call      parread                  ; naáten° dal®°ho znaku
         ja        parnorm3                 ; je platnò znak - dal®° znak
         xor       al,al                    ; ukonáovac° znak
         stosb                              ; oznaáen° konce textu
         jmp       short parnorm1           ; dal®° parametr

parnorm2:xor       al,al                    ; koncovò bajt parametrñ
         stosb                              ; oznaáen° konce parametrñ
         or        cx,cx                    ; je nàjakò parametr ?
         pop       di
         pop       si
         pop       ax
         ret
; -----------------------------------------------------------------------------
public   parget
parget:                                   ;* poskytnut° adresy parametru
                                            ; VSTUP: CX=á°slo parametru
                                            ;        DS:SI=adresa bufferu
                                            ; VùSTUP: DS:SI=adresa parametru
                                            ;         CY=neplatnò parametr
         push      ax
         push      cx
parget1:                                  ;* nalezen° zaá†tku dal®°ho parametru
         cmp       byte ptr ds:[si],0       ; je platnò parametr ?
         stc                                ; p©°znak - nen° dal®° parametr
         je        parget3                  ; nen° dal®° parametr
         clc
         jcxz      parget3                  ; nalezen parametr
parget2: lodsb                              ; naáten° dal®°ho znaku
         or        al,al
         jnz       parget2
         dec       cx
         jmp       short parget1            ; dal®° parametr
parget3:
         pop       cx
         pop       ax
         ret
; -----------------------------------------------------------------------------
public   parrozb
parrozb:                                  ;* rozbor zad†n° souboru
                                            ; VSTUP: DS:SI=adresa textu
                                            ;        ES:DI=adresa rozboru
                                            ;           1 B: jmÇno disku
                                            ;           1 B: oddàlovaá ":"
                                            ;          64 B: cesta ASCIIZ
                                            ;          13 B: jmÇno soub. ASCIIZ
         push      ax
         push      si
         push      di
parrozb1:call      parread                  ; áten° znaku textu
         jc        parrozb3                 ; konec textu





parrozb3:
         pop       di
         pop       si
         pop       ax
         ret
; -----------------------------------------------------------------------------
parread:                                  ;* áten° bajtu z p©°kaz. ©†dku
                                            ; VSTUP: DS:SI=ukazatel textu
                                            ; VùSTUP: AL=znak
                                            ;         CY=nen° dal®° znak
                                            ;         ZY=je oddàlovaá

         mov       al,ds:[si]               ; znak
         or        al,al
         jz        parread1                 ; je konec textu
         cmp       al,13
         je        parread1                 ; konec textu
         inc       si                       ; zvò®en° adresy
         cmp       al,9                     ; je tabel†tor ?
         je        parread2                 ; je tabel†tor
         cmp       al," "                   ; je mezera ?
         je        parread2                 ; je mezera
         stc                                ; p©°znak - znak OK
parread1:cmc
parread2:ret
; -----------------------------------------------------------------------------
;                              DiskovÇ operace
; -----------------------------------------------------------------------------
public   wbyte
wbyte:                                    ;* z†pis bajtu do vòstupn°ho souboru
         push      ax
         push      bx
         mov       bx,ds:[outnum]           ; poáet bajtñ ve vòstupn°m bufferu
         cmp       bx,4095                  ; je jië konec bufferu ?
         jb        writefb3                 ; nen° je®tà konec bufferu
         call      writefbuf                ; z†pis bufferu do souboru
         jc        writefb4                 ; chyba z†pisu
writefb3:mov       bx,ds:[outnum]           ; ukazatel konce dat v bufferu
         mov       ds:[bx+outbuf],al        ; uloëen° bajtu do bufferu
         inc       bx                       ; zvò®en° ukl†dac° adresy
         mov       ds:[outnum],bx           ; novò poáet bajtñ v bufferu


         clc
writefb4:pop       bx
         pop       ax
         ret
; -----------------------------------------------------------------------------
public   writefbuf
writefbuf:                                ;* z†pis bufferu do souboru
         push      ax
         push      bx
         push      cx
         push      dx
         mov       cx,ds:[outnum]           ; poáet bajtñ v souboru
         or        cx,cx                    ; p©°znak operace OK
         jz        writefb2                 ; v bufferu nen° ë†dnò bajt
         mov       bx,ds:[outid]            ; identifik†tor vòstupn°ho souboru
         mov       dx,offset outbuf         ; vòstupn° buffer
         mov       ah,40h
         int       21h                      ; z†pis dat do souboru
         jc        writefb2                 ; chyba z†pisu
         cmp       ax,cx                    ; souhlas° poáet zapsanòch bajtñ ?
writefb2:mov       word ptr ds:[outnum],0   ; vynulov†n° vòstupn°ho bufferu
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret
; -----------------------------------------------------------------------------
public   rbyte
rbyte:                                    ;* áten° bajtu ze souboru
                                            ; VùSTUP: CY=chyba operace áten°
                                            ;         ZY=je konec souboru
                                            ;         AL=naátenò znak

         push      bx
         mov       al,27
         mov       bx,ds:[inpuk]            ; ukazatel átenòch dat
         inc       bx                       ; zvò®en° ukazatele átenòch dat
         mov       ds:[inpuk],bx
         cmp       ds:[inpnum],bx           ; je jië konec dat ?
         ja        readfb2                  ; nen° je®tà konec dat v bufferu
         call      readfbuf                 ; naáten° dal®°ho bloku dat
         mov       al,27
         jbe       readfb3                  ; chyba áten° nebo konec souboru
readfb2: mov       bx,ds:[inpuk]            ; ukazatel átenòch dat
         mov       al,ds:[bx+inpbuf]        ; bajt z bufferu
readfb3:
         pushf
         dec       word ptr ds:[citac]
         jnz       zobrfb5
         push      ax
         push      dx
         mov       dl,"."
         mov       ah,2
         int       21h
         pop       dx
         pop       ax
         mov       word ptr ds:[citac],400h
zobrfb5: popf

         pop       bx
         ret
; -----------------------------------------------------------------------------
public   readfbuf
readfbuf:                                 ;* naáten° bufferu vstupn°ho souboru
                                            ; VùSTUP: CY=chyba operace áten°
                                            ;         ZY=je konec souboru

         push      ax
         push      bx
         push      cx
         push      dx

         mov       word ptr ds:[inpnum],0   ; vynulov†n° vstupn°ho bufferu
         mov       word ptr ds:[inpuk],0    ; vynulov†n° ukazatele átenòch dat
         mov       cx,4096                  ; dÇlka vstupn°ho bufferu
         mov       bx,ds:[inpid]            ; identifik†tor vstupn°ho souboru
         mov       dx,offset inpbuf         ; vstupn° buffer
         mov       ah,3fh
         int       21h                      ; naáten° dat ze souboru
         jc        readfbf2                 ; je chyba áten°
         mov       ds:[inpnum],ax           ; uloëen° poátu naátenòch dat
         or        ax,ax                    ; nastaven° p©°znaku ZF

readfbf2:pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret
; -----------------------------------------------------------------------------
;                                 Data
; -----------------------------------------------------------------------------
public   inpid,outid,inpnum,inpuk,outnum

errtxt   db        'Komprese metodou LZSS;  (c) Miroslav Nemecek',13,10
         db        'Zadejte: KOMP vstupni_soubor vystupni_soubor',13,10,'$'

inpid    dw        0                        ; identifik†tor vstupn°ho souboru
outid    dw        0                        ; identifik†tor vòstupn°ho souboru

inpnum   dw        0                        ; poáet bajtñ ve vstupn°m souboru
inpuk    dw        0                        ; ukazatel dat ve vstupn°m souboru
outnum   dw        0                        ; poáet bajtñ ve vòstupn°m souboru
citac    dw        400h                     ; á°taá pro zobrazen° prñbàhu

konec    label     near                     ; konec programu

public   codebuf,ukazs,ukazr,ukazp,len,comp

codebuf  db        17 dup(?)                ; buffer k¢dñ
ukazs    dw        ?                        ; ukl†dac° index do bufferu
ukazr    dw        ?                        ; átec° index z bufferu
ukazp    dw        ?                        ; pomocnò ukazatel bufferu
len      db        ?                        ; dÇlka shody
comp     db        ?                        ; p©°znak porovn†n°

commbuf  db        128 dup(?)               ; buffer p©°kazovÇho ©†dku
; ----------------------------- buffery dat -----------------------------------
public   inpbuf,outbuf,textbuf,lson,rson,dad

inpbuf   db        4096 dup(?)              ; buffer vstupn°ho souboru
outbuf   db        4096 dup(?)              ; buffer vòstupn°ho souboru

textbuf  db        buffsize + matchlim dup(?)  ; kruhovò buffer

zacini   label     byte                   ;* zaá†tek inicializace
lson     dw        buffsize + 1 dup(?)      ; lev† vàtev
rson     dw        buffsize + 1 + 256 dup(?); prav† vàtev + ko©eny
dad      dw        buffsize + 1 dup(?)      ; otcovskÇ vàtve
konini   label     byte                   ;* konec inicializace

code     ENDS
         END       komp

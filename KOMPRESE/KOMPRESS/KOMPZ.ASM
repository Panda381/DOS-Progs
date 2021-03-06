
; *****************************************************************************
;                                  Komprese dat
; *****************************************************************************

buffsize equ       4096                     ; velikost kruhov�ho bufferu
null     equ       buffsize                 ; nulovac� slovo - koncov� polo�ka
matchlim equ       18                       ; maxim�ln� d�lka shody
threshld equ       2                        ; minim�ln� d�lka shody


code     SEGMENT
         ASSUME    cs:code,ds:code
         ORG       100h
komp:    jmp       komp1                    ; skok na start programu

         dw        offset konec             ; konec programu

komp1:                                    ;* vstupn� souboru
         mov       di,offset commbuf        ; buffer p��kazov�ho ��dku
         call      parnorm                  ; normalizace zadan�ch parametr�
         jc        chyba                    ; nen� ��dn� parametr
         mov       si,offset commbuf        ; buffer p��kazov�ho ��dku
         xor       cx,cx                    ; ��slo parametru = 0
         call      parget                   ; poskytnut� adresy parametru 0
         jc        chyba                    ; nen� prvn� parametr
         mov       dx,si                    ; specifikace vstupn�ho souboru
         mov       ax,3d00h
         int       21h
         jc        chyba
         mov       ds:[inpid],ax
                                          ;* v�stupn� soubor
         mov       si,offset commbuf        ; buffer p��kazov�ho ��dku
         mov       cx,1                     ; ��slo parametru = 1
         call      parget                   ; poskytnut� adresy parametru 1
         jc        chyba                    ; nen� druh� parametr
         mov       dx,si                    ; druh� parametr
         mov       ah,3ch
         xor       cx,cx
         int       21h
         jc        chyba
         mov       ds:[outid],ax


         call      kode                     ; zak�dov�n� souboru LZSS

navrat:  call      writefbuf                ; vypr�zdn�n� v�stupn�ho bufferu
         mov       ax,4c00h
         int       21h

chyba:   mov       dx,offset errtxt
         mov       ah,9
         int       21h
         mov       ax,4c01h
         int       21h

; -----------------------------------------------------------------------------
;                      K�dov�n� LZSS - kruhov� buffer
; -----------------------------------------------------------------------------
public   kode
kode:                                     ;* zak�dov�n� jednoho souboru
         call      inittree                 ; inicializace stromu bufferu
         mov       byte ptr ds:[codebuf],0  ; nastaven� p��znaku pozic
         mov       dh,1                     ; maska
         mov       di,offset codebuf +1     ; buffer k�d�
         mov       word ptr ds:[ukazs],0
         mov       word ptr ds:[ukazr],buffsize-matchlim ; d�lka bufferu
         mov       byte ptr ds:[len],0      ; d�lka = 0
                                          ;* na�ten� MATCHLIM bajtu na konec
         push      di
         mov       cx,matchlim              ; max. d�lka shody
         mov       di,offset (textbuf+buffsize-matchlim) ; za��tek oblasti MATCHLIM
kode2:   call      rbyte                    ; �ten� bajtu ze souboru
         jbe       kode3                    ; chyba nebo konec souboru
         stosb                              ; ulo�en� bajtu do bufferu
         inc       byte ptr ds:[len]        ; zv��en� ��ta�e d�lky dat
         loop      kode2                    ; na�ten� dal��ho bajtu
kode3:   pop       di
         cmp       byte ptr ds:[len],0      ; je n�jak� bajt ?
         jne       kode33                   ; v bufferu je n�jak� znak
         ret                                ; n�vrat, pokud je pr�zdn� soubor

kode33:                                   ;* inicializa�n� ulo�en� �et�zc�
         mov       cx,matchlim              ; po�et znak�
         mov       si,ds:[ukazr]            ; ukazatel konce bufferu
kode34:  dec       si
         call      insertn                  ; vlo�en� �et�zce mezer
         loop      kode34                   ; dal�� �et�zec

         mov       si,ds:[ukazr]            ; ukazatel ukl�dac� adresy
         call      insertn                  ; vlo�en� na�ten�ho �et�zce

                                          ;* za��tek cyklu k�dov�n�
                                            ; DH=maska pro k�dov�n�
                                            ; DL=d�lka shody
                                            ; BX=index shodn�ho �et�zce
                                            ; DI=ukl�dac� adresa do buff. k�du

kode4:                                    ;* omezen� d�lky shody
         cmp       dl,ds:[len]              ; je d�lka shody > bajty v buff. ?
         jbe       kode5                    ; nen� v�t��
         mov       dl,ds:[len]              ; omezen� d�lky shody
kode5:                                    ;* p��li� kr�tk� shoda - nen� kompr.
         cmp       dl,threshld              ; je dostate�n� d�lka shody ?
         ja        kode6                    ; je dostate�n� d�lka shody
         mov       dl,1                     ; omezen� d�lky shody na 1
         or        byte ptr ds:[codebuf],dh ; informace, �e je p��m� bajt
         mov       si,ds:[ukazr]            ; �tec� index z bufferu
         mov       al,ds:[si+textbuf]       ; vkl�dan� znak z bufferu
         jmp       short kode8
kode6:                                    ;* dostate�n� shoda - je komprese
         mov       al,bl                    ; ni��� bajt indexu shody
         stosb                              ; ulo�en� LOW indexu shody
         mov       al,bh                    ; vy��� bajt indexu shody
         mov       cl,4
         shl       al,cl
         add       al,dl                    ; d�lka shody do ni���ch 4 bit�
         sub       al,threshld+1            ; korekce od 0
kode8:                                    ;* vypr�zdn�n� bufferu k�du
         stosb                              ; ulo�en� vy���ho bajtu/znaku
         shl       dh,1                     ; rotace masky o 1 bit vlevo
         or        dh,dh
         jnz       kodea                    ; nen� je�t� 0 - dal��
         mov       cx,di                    ; konec ulo�en�ch dat
         mov       si,offset codebuf        ; buffer k�du
         sub       cx,si                    ; po�et bajt� v bufferu
kode9:   lodsb                              ; bajt k vysl�n�
         call      wbyte                    ; z�pis bajtu do souboru
         loop      kode9                    ; z�pis dal��ho bajtu
         mov       dh,1                     ; maska k�du
         mov       di,offset codebuf +1     ; buffer k�d�
         mov       byte ptr ds:[di-1],0     ; nulov�n� identifikace k�du
kodea:                                    ;* na�ten� dal��ch dat
         xor       cx,cx                    ; CX <- 0
         mov       cl,dl                    ; d�lka shody
kodeb:   mov       si,ds:[ukazs]
         call      deleten                  ; zru�en� star�ho �et�zce
         call      rbyte                    ; �ten� dal��ho znaku ze souboru
         jbe       kodef                    ; chyba nebo konec souboru
         mov       si,ds:[ukazs]            ; ukazatel ukl�dac� adresy
         mov       ds:[si+textbuf],al       ; ulo�en� znaku do bufferu
         cmp       si,matchlim-1            ; je na za��tku bufferu ?
         jae       kodec                    ; nen� na za��tku bufferu
         mov       ds:[si+textbuf+buffsize],al ; zvojen� i na konec bufferu
kodec:   inc       si                       ; zv��en� ukl�dac� adresy
         cmp       si,buffsize              ; je za koncem bufferu ?
         jb        koded                    ; nen� je�t� za koncem bufferu
         xor       si,si                    ; ukazatel na za��tek bufferu
koded:   mov       ds:[ukazs],si            ; nov� ukl�dac� adresa
         mov       si,ds:[ukazr]            ; �tec� adresa
         inc       si                       ; zv��en� �tec� adresy
         cmp       si,buffsize              ; je za koncem bufferu ?
         jb        kodee                    ; nen� je�t� za koncem bufferu
         xor       si,si                    ; ukazatel na za��tek bufferu
kodee:   mov       ds:[ukazr],si            ; nov� �tec� adresa
         call      insertn                  ; vlo�en� nov� �et�zce
         loop      kodeb                    ; na�ten� dal��ho bajtu ze souboru

         jmp       short kodeg              ; nen� je�t� konec souboru

kodef:                                    ;* konec souboru - zru�en� zbyl�ch �.
         mov       si,ds:[ukazs]
         call      deleten                  ; zru�en� v�tve
         mov       si,ds:[ukazs]            ; ukazatel ukl�dac� adresy
         inc       si                       ; zv��en� ukl�dac� adresy
         cmp       si,buffsize              ; je za koncem bufferu ?
         jb        kodeh                    ; nen� je�t� za koncem bufferu
         xor       si,si                    ; ukazatel na za��tek bufferu
kodeh:   mov       ds:[ukazs],si            ; nov� ukl�dac� adresa
         mov       si,ds:[ukazr]            ; �tec� adresa
         inc       si                       ; zv��en� �tec� adresy
         cmp       si,buffsize              ; je za koncem bufferu ?
         jb        kodei                    ; nen� je�t� za koncem bufferu
         xor       si,si                    ; ukazatel na za��tek bufferu
kodei:   mov       ds:[ukazr],si            ; nov� �tec� adresa
         dec       byte ptr ds:[len]
         cmp       byte ptr ds:[len],0
         je        kodej
         mov       si,ds:[ukazr]            ; nov� na�ten� �et�zec
         call      insertn                  ; vlo�en� nov� �et�zce
kodej:   loop      kodef                    ; dal�� znak

kodeg:   cmp       byte ptr ds:[len],0
         jbe       kodel                    ; konec
         jmp       kode4                    ; dal�� k�d

kodel:                                    ;* vypr�zdn�n� zbytku bufferu k�du

         mov       cx,di                    ; konec ulo�en�ch dat
         mov       si,offset codebuf        ; buffer k�du
         sub       cx,si                    ; po�et bajt� v bufferu
         jcxz      koden                    ; nen� dal�� znak
kodem:   lodsb                              ; bajt k vysl�n�
         call      wbyte                    ; z�pis bajtu do souboru
         loop      kodem                    ; z�pis dal��ho bajtu
koden:   ret


; -----------------------------------------------------------------------------
public   inittree
inittree:                                 ;* inicializace hledac�ho stromu

         mov       cx,offset (konini-zacini)/2 ; velikost buffer� ve slovech
         mov       di,offset zacini         ; za��tek buffer�
         mov       ax,null                  ; nulovac� slovo
         cld                                ; sm�r nahoru
         rep       stosw                    ; vymaz�n� buffer�
                                          ;* inicializace kruhov�ho bufferu
         mov       di,offset textbuf        ; kruhov� buffer
         mov       cx,buffsize + matchlim   ; velikost kruhov�ho bufferu
         mov       al," "                   ; znak mezery
         rep       stosb                    ; vymaz�n� kruhov�ho bufferu

         ret

; -----------------------------------------------------------------------------
public   insertn
insertn:                                  ;* vlo�en� �et�zce do stromu
                                            ; VSTUP: SI=index �et�zce
                                            ; V�STUP: DL=d�lka shody
                                            ;         BX=index shodn�ho �et�zce


         push      ax
         push      cx
         push      si
         push      di

         mov       byte ptr ds:[comp],1     ; p��znak porovn�n� �et�zc�

         mov       di,word ptr ds:[si+textbuf] ; po��te�n� znak �et�zce
         and       di,0ffh                  ; ponech� znak �et�zce
         add       di,buffsize + 1          ; index v bufferu

         push      si
         add       si,si                    ; index * 2
         mov       ds:[si+rson],null        ; inicializace �et�zce
         mov       ds:[si+lson],null        ; inicializace �et�zce
         pop       si

         xor       dl,dl                    ; d�lka shody = 0

insertn1:                                 ;* za��tek cyklu vyhled�v�n�
         cmp       byte ptr ds:[comp],0     ; je p��znak porovn�n� >= 0 ?
         jl        insertn3                 ; p��znak porovn�n� je z�porn�

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


insertn7:                                 ;* porovn�n� �et�zc�
         mov       cx,matchlim-1            ; max. d�lka textu
         push      si
         push      di
insertn8:inc       si
         inc       di
         mov       al,ds:[si+textbuf]
         sub       al,ds:[di+textbuf]
         jnz       insert88
         loopz     insertn8                 ; je shoda - dal�� znak
insert88:pop       di
         pop       si
         mov       ds:[comp],al             ; rozd�l znak�

         mov       al,matchlim              ; maxim�ln� d�lka �et�zce
         sub       al,cl                    ; po�et shodn�ch znak�
         cmp       al,dl                    ; je del�� �et�zec ?
         jbe       insertna                 ; nen� del�� �et�zec
                                          ;* nalezen v�t�� �et�z
         mov       bx,di                    ; nov� pozice
         mov       dl,al                    ; d�lka nov�ho �et�zce
         cmp       dl,matchlim              ; je maxim�ln� �et�zec ?
         jae       insertnd                 ; je maxim�ln� �et�zec
insertna:
         jmp       insertn1                 ; dal�� test
                                          ;* je velmi dlouh� shoda
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
deleten:                                  ;* zru�en� �et�zce
                                            ; VSTUP: SI=index �et�zce

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
;                       Rozbor p��kazov�ho ��dku
; -----------------------------------------------------------------------------
public   parnorm
parnorm:                                  ;* normalizace zadan�ch parametr�
                                            ; VSTUP: ES:DI=ukl�dac� adresa
                                            ;        DS=segment PSP
                                            ; V�STUP: CX=po�et parametr�
                                            ;         ZY=nen� ��dn� parametr

         push      ax
         push      si
         push      di
         cld                                ; sm�r nahoru
         xor       cx,cx                    ; ��ta� parametr�
         mov       si,81h                   ; za��tek parametr�
         push      si
         add       si,ds:[si-1]             ; konec parametr�
         and       si,0ffh                  ; adresa konce textu
         mov       byte ptr ds:[si],0       ; ozna�en� konce textu
         pop       si
                                          ;* nalezen� za��tku parametru
parnorm1:call      parread                  ; na�ten� znaku parametr�
         jc        parnorm2                 ; je konec textu
         jz        parnorm1                 ; je odd�lova� - dal�� znak
         inc       cx                       ; zv��en� ��ta�e parametr�
parnorm3:                                 ;* p�enesen� textu
         stosb                              ; ulo�en� platn�ho znaku
         call      parread                  ; na�ten� dal��ho znaku
         ja        parnorm3                 ; je platn� znak - dal�� znak
         xor       al,al                    ; ukon�ovac� znak
         stosb                              ; ozna�en� konce textu
         jmp       short parnorm1           ; dal�� parametr

parnorm2:xor       al,al                    ; koncov� bajt parametr�
         stosb                              ; ozna�en� konce parametr�
         or        cx,cx                    ; je n�jak� parametr ?
         pop       di
         pop       si
         pop       ax
         ret
; -----------------------------------------------------------------------------
public   parget
parget:                                   ;* poskytnut� adresy parametru
                                            ; VSTUP: CX=��slo parametru
                                            ;        DS:SI=adresa bufferu
                                            ; V�STUP: DS:SI=adresa parametru
                                            ;         CY=neplatn� parametr
         push      ax
         push      cx
parget1:                                  ;* nalezen� za��tku dal��ho parametru
         cmp       byte ptr ds:[si],0       ; je platn� parametr ?
         stc                                ; p��znak - nen� dal�� parametr
         je        parget3                  ; nen� dal�� parametr
         clc
         jcxz      parget3                  ; nalezen parametr
parget2: lodsb                              ; na�ten� dal��ho znaku
         or        al,al
         jnz       parget2
         dec       cx
         jmp       short parget1            ; dal�� parametr
parget3:
         pop       cx
         pop       ax
         ret
; -----------------------------------------------------------------------------
public   parrozb
parrozb:                                  ;* rozbor zad�n� souboru
                                            ; VSTUP: DS:SI=adresa textu
                                            ;        ES:DI=adresa rozboru
                                            ;           1 B: jm�no disku
                                            ;           1 B: odd�lova� ":"
                                            ;          64 B: cesta ASCIIZ
                                            ;          13 B: jm�no soub. ASCIIZ
         push      ax
         push      si
         push      di
parrozb1:call      parread                  ; �ten� znaku textu
         jc        parrozb3                 ; konec textu





parrozb3:
         pop       di
         pop       si
         pop       ax
         ret
; -----------------------------------------------------------------------------
parread:                                  ;* �ten� bajtu z p��kaz. ��dku
                                            ; VSTUP: DS:SI=ukazatel textu
                                            ; V�STUP: AL=znak
                                            ;         CY=nen� dal�� znak
                                            ;         ZY=je odd�lova�

         mov       al,ds:[si]               ; znak
         or        al,al
         jz        parread1                 ; je konec textu
         cmp       al,13
         je        parread1                 ; konec textu
         inc       si                       ; zv��en� adresy
         cmp       al,9                     ; je tabel�tor ?
         je        parread2                 ; je tabel�tor
         cmp       al," "                   ; je mezera ?
         je        parread2                 ; je mezera
         stc                                ; p��znak - znak OK
parread1:cmc
parread2:ret
; -----------------------------------------------------------------------------
;                              Diskov� operace
; -----------------------------------------------------------------------------
public   wbyte
wbyte:                                    ;* z�pis bajtu do v�stupn�ho souboru
         push      ax
         push      bx
         mov       bx,ds:[outnum]           ; po�et bajt� ve v�stupn�m bufferu
         cmp       bx,4095                  ; je ji� konec bufferu ?
         jb        writefb3                 ; nen� je�t� konec bufferu
         call      writefbuf                ; z�pis bufferu do souboru
         jc        writefb4                 ; chyba z�pisu
writefb3:mov       bx,ds:[outnum]           ; ukazatel konce dat v bufferu
         mov       ds:[bx+outbuf],al        ; ulo�en� bajtu do bufferu
         inc       bx                       ; zv��en� ukl�dac� adresy
         mov       ds:[outnum],bx           ; nov� po�et bajt� v bufferu


         clc
writefb4:pop       bx
         pop       ax
         ret
; -----------------------------------------------------------------------------
public   writefbuf
writefbuf:                                ;* z�pis bufferu do souboru
         push      ax
         push      bx
         push      cx
         push      dx
         mov       cx,ds:[outnum]           ; po�et bajt� v souboru
         or        cx,cx                    ; p��znak operace OK
         jz        writefb2                 ; v bufferu nen� ��dn� bajt
         mov       bx,ds:[outid]            ; identifik�tor v�stupn�ho souboru
         mov       dx,offset outbuf         ; v�stupn� buffer
         mov       ah,40h
         int       21h                      ; z�pis dat do souboru
         jc        writefb2                 ; chyba z�pisu
         cmp       ax,cx                    ; souhlas� po�et zapsan�ch bajt� ?
writefb2:mov       word ptr ds:[outnum],0   ; vynulov�n� v�stupn�ho bufferu
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret
; -----------------------------------------------------------------------------
public   rbyte
rbyte:                                    ;* �ten� bajtu ze souboru
                                            ; V�STUP: CY=chyba operace �ten�
                                            ;         ZY=je konec souboru
                                            ;         AL=na�ten� znak

         push      bx
         mov       al,27
         mov       bx,ds:[inpuk]            ; ukazatel �ten�ch dat
         inc       bx                       ; zv��en� ukazatele �ten�ch dat
         mov       ds:[inpuk],bx
         cmp       ds:[inpnum],bx           ; je ji� konec dat ?
         ja        readfb2                  ; nen� je�t� konec dat v bufferu
         call      readfbuf                 ; na�ten� dal��ho bloku dat
         mov       al,27
         jbe       readfb3                  ; chyba �ten� nebo konec souboru
readfb2: mov       bx,ds:[inpuk]            ; ukazatel �ten�ch dat
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
readfbuf:                                 ;* na�ten� bufferu vstupn�ho souboru
                                            ; V�STUP: CY=chyba operace �ten�
                                            ;         ZY=je konec souboru

         push      ax
         push      bx
         push      cx
         push      dx

         mov       word ptr ds:[inpnum],0   ; vynulov�n� vstupn�ho bufferu
         mov       word ptr ds:[inpuk],0    ; vynulov�n� ukazatele �ten�ch dat
         mov       cx,4096                  ; d�lka vstupn�ho bufferu
         mov       bx,ds:[inpid]            ; identifik�tor vstupn�ho souboru
         mov       dx,offset inpbuf         ; vstupn� buffer
         mov       ah,3fh
         int       21h                      ; na�ten� dat ze souboru
         jc        readfbf2                 ; je chyba �ten�
         mov       ds:[inpnum],ax           ; ulo�en� po�tu na�ten�ch dat
         or        ax,ax                    ; nastaven� p��znaku ZF

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

inpid    dw        0                        ; identifik�tor vstupn�ho souboru
outid    dw        0                        ; identifik�tor v�stupn�ho souboru

inpnum   dw        0                        ; po�et bajt� ve vstupn�m souboru
inpuk    dw        0                        ; ukazatel dat ve vstupn�m souboru
outnum   dw        0                        ; po�et bajt� ve v�stupn�m souboru
citac    dw        400h                     ; ��ta� pro zobrazen� pr�b�hu

konec    label     near                     ; konec programu

public   codebuf,ukazs,ukazr,ukazp,len,comp

codebuf  db        17 dup(?)                ; buffer k�d�
ukazs    dw        ?                        ; ukl�dac� index do bufferu
ukazr    dw        ?                        ; �tec� index z bufferu
ukazp    dw        ?                        ; pomocn� ukazatel bufferu
len      db        ?                        ; d�lka shody
comp     db        ?                        ; p��znak porovn�n�

commbuf  db        128 dup(?)               ; buffer p��kazov�ho ��dku
; ----------------------------- buffery dat -----------------------------------
public   inpbuf,outbuf,textbuf,lson,rson,dad

inpbuf   db        4096 dup(?)              ; buffer vstupn�ho souboru
outbuf   db        4096 dup(?)              ; buffer v�stupn�ho souboru

textbuf  db        buffsize + matchlim dup(?)  ; kruhov� buffer

zacini   label     byte                   ;* za��tek inicializace
lson     dw        buffsize + 1 dup(?)      ; lev� v�tev
rson     dw        buffsize + 1 + 256 dup(?); prav� v�tev + ko�eny
dad      dw        buffsize + 1 dup(?)      ; otcovsk� v�tve
konini   label     byte                   ;* konec inicializace

code     ENDS
         END       komp

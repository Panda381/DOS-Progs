
; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�
;
;                               Komprese dat
;
; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�

BuffSizB EQU



Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; Obsazen� pam늯i:
;    - program, vstupn� a v쁲tupn� buffer souboru (asi 10 KB)
;    - datov� buffer 8 KB
;    -



Start:






; *****************************************************************************
;
;                                 D A T A
;
; *****************************************************************************

UvTxt    db        'Komp V 1.0 - komprese dat; (c) Miroslav N늤e놽k',13,10,'$'

MemTxt   db        'Chyba - nedostatek pam늯i !',13,10,'$'

Code     ENDS
         END       Start










; *****************************************************************************
;                                  Komprese dat
; *****************************************************************************

buffsize equ       4096                     ; velikost kruhov괿o bufferu
null     equ       buffsize                 ; nulovac� slovo - koncov� polo멾a
matchlim equ       18                       ; maxim쟫n� d굃ka shody
threshld equ       2                        ; minim쟫n� d굃ka shody


code     SEGMENT
         ASSUME    cs:code,ds:code
         ORG       100h
komp:    jmp       komp1                    ; skok na start programu

         dw        offset konec             ; konec programu

komp1:                                    ;* vstupn� souboru
         mov       di,offset commbuf        ; buffer pækazov괿o 찤dku
         call      parnorm                  ; normalizace zadan쁟h parametr�
         jc        chyba                    ; nen� 몺dn� parametr
         mov       si,offset commbuf        ; buffer pækazov괿o 찤dku
         xor       cx,cx                    ; 눀slo parametru = 0
         call      parget                   ; poskytnut� adresy parametru 0
         jc        chyba                    ; nen� prvn� parametr
         mov       dx,si                    ; specifikace vstupn죋o souboru
         mov       ax,3d00h
         int       21h
         jc        chyba
         mov       ds:[inpid],ax
                                          ;* v쁲tupn� soubor
         mov       si,offset commbuf        ; buffer pækazov괿o 찤dku
         mov       cx,1                     ; 눀slo parametru = 1
         call      parget                   ; poskytnut� adresy parametru 1
         jc        chyba                    ; nen� druh� parametr
         mov       dx,si                    ; druh� parametr
         mov       ah,3ch
         xor       cx,cx
         int       21h
         jc        chyba
         mov       ds:[outid],ax


         call      kode                     ; zak줰ov쟮� souboru LZSS

navrat:  call      writefbuf                ; vypr쟺dn늧� v쁲tupn죋o bufferu
         mov       ax,4c00h
         int       21h

chyba:   mov       dx,offset errtxt
         mov       ah,9
         int       21h
         mov       ax,4c01h
         int       21h

; -----------------------------------------------------------------------------
;                      K줰ov쟮� LZSS - kruhov� buffer
; -----------------------------------------------------------------------------
public   kode
kode:                                     ;* zak줰ov쟮� jednoho souboru
         call      inittree                 ; inicializace stromu bufferu
         mov       byte ptr ds:[codebuf],0  ; nastaven� pæznaku pozic
         mov       dh,1                     ; maska
         mov       di,offset codebuf +1     ; buffer k줰�
         mov       word ptr ds:[ukazs],0
         mov       word ptr ds:[ukazr],buffsize-matchlim ; d굃ka bufferu
         mov       byte ptr ds:[len],0      ; d굃ka = 0
                                          ;* na뇍en� MATCHLIM bajtu na konec
         push      di
         mov       cx,matchlim              ; max. d굃ka shody
         mov       di,offset (textbuf+buffsize-matchlim) ; za뇿tek oblasti MATCHLIM
kode2:   call      rbyte                    ; 뇍en� bajtu ze souboru
         jbe       kode3                    ; chyba nebo konec souboru
         stosb                              ; ulo멷n� bajtu do bufferu
         inc       byte ptr ds:[len]        ; zv삩en� 눀ta놽 d굃ky dat
         loop      kode2                    ; na뇍en� dalÆho bajtu
kode3:   pop       di
         cmp       byte ptr ds:[len],0      ; je n늞ak� bajt ?
         jne       kode33                   ; v bufferu je n늞ak� znak
         ret                                ; n쟶rat, pokud je pr쟺dn� soubor

kode33:                                   ;* inicializa뇆� ulo멷n� 쯥t늷c�
         mov       cx,matchlim              ; po놽t znak�
         mov       si,ds:[ukazr]            ; ukazatel konce bufferu
kode34:  dec       si
         call      insertn                  ; vlo멷n� 쯥t늷ce mezer
         loop      kode34                   ; dalÆ 쯥t늷ec

         mov       si,ds:[ukazr]            ; ukazatel ukl쟡ac� adresy
         call      insertn                  ; vlo멷n� na뇍en괿o 쯥t늷ce

                                          ;* za뇿tek cyklu k줰ov쟮�
                                            ; DH=maska pro k줰ov쟮�
                                            ; DL=d굃ka shody
                                            ; BX=index shodn괿o 쯥t늷ce
                                            ; DI=ukl쟡ac� adresa do buff. k줰u

kode4:                                    ;* omezen� d굃ky shody
         cmp       dl,ds:[len]              ; je d굃ka shody > bajty v buff. ?
         jbe       kode5                    ; nen� v늯Æ
         mov       dl,ds:[len]              ; omezen� d굃ky shody
kode5:                                    ;* pæli� kr쟴k� shoda - nen� kompr.
         cmp       dl,threshld              ; je dostate뇆� d굃ka shody ?
         ja        kode6                    ; je dostate뇆� d굃ka shody
         mov       dl,1                     ; omezen� d굃ky shody na 1
         or        byte ptr ds:[codebuf],dh ; informace, 멷 je pæm� bajt
         mov       si,ds:[ukazr]            ; 뇍ec� index z bufferu
         mov       al,ds:[si+textbuf]       ; vkl쟡an� znak z bufferu
         jmp       short kode8
kode6:                                    ;* dostate뇆� shoda - je komprese
         mov       al,bl                    ; ni뫅� bajt indexu shody
         stosb                              ; ulo멷n� LOW indexu shody
         mov       al,bh                    ; vyĿ� bajt indexu shody
         mov       cl,4
         shl       al,cl
         add       al,dl                    ; d굃ka shody do ni뫅죅h 4 bit�
         sub       al,threshld+1            ; korekce od 0
kode8:                                    ;* vypr쟺dn늧� bufferu k줰u
         stosb                              ; ulo멷n� vyĿ죋o bajtu/znaku
         shl       dh,1                     ; rotace masky o 1 bit vlevo
         or        dh,dh
         jnz       kodea                    ; nen� je쮝� 0 - dalÆ
         mov       cx,di                    ; konec ulo멷n쁟h dat
         mov       si,offset codebuf        ; buffer k줰u
         sub       cx,si                    ; po놽t bajt� v bufferu
kode9:   lodsb                              ; bajt k vysl쟮�
         call      wbyte                    ; z쟰is bajtu do souboru
         loop      kode9                    ; z쟰is dalÆho bajtu
         mov       dh,1                     ; maska k줰u
         mov       di,offset codebuf +1     ; buffer k줰�
         mov       byte ptr ds:[di-1],0     ; nulov쟮� identifikace k줰u
kodea:                                    ;* na뇍en� dalÆch dat
         xor       cx,cx                    ; CX <- 0
         mov       cl,dl                    ; d굃ka shody
kodeb:   mov       si,ds:[ukazs]
         call      deleten                  ; zru쮍n� star괿o 쯥t늷ce
         call      rbyte                    ; 뇍en� dalÆho znaku ze souboru
         jbe       kodef                    ; chyba nebo konec souboru
         mov       si,ds:[ukazs]            ; ukazatel ukl쟡ac� adresy
         mov       ds:[si+textbuf],al       ; ulo멷n� znaku do bufferu
         cmp       si,matchlim-1            ; je na za뇿tku bufferu ?
         jae       kodec                    ; nen� na za뇿tku bufferu
         mov       ds:[si+textbuf+buffsize],al ; zvojen� i na konec bufferu
kodec:   inc       si                       ; zv삩en� ukl쟡ac� adresy
         cmp       si,buffsize              ; je za koncem bufferu ?
         jb        koded                    ; nen� je쮝� za koncem bufferu
         xor       si,si                    ; ukazatel na za뇿tek bufferu
koded:   mov       ds:[ukazs],si            ; nov� ukl쟡ac� adresa
         mov       si,ds:[ukazr]            ; 뇍ec� adresa
         inc       si                       ; zv삩en� 뇍ec� adresy
         cmp       si,buffsize              ; je za koncem bufferu ?
         jb        kodee                    ; nen� je쮝� za koncem bufferu
         xor       si,si                    ; ukazatel na za뇿tek bufferu
kodee:   mov       ds:[ukazr],si            ; nov� 뇍ec� adresa
         call      insertn                  ; vlo멷n� nov� 쯥t늷ce
         loop      kodeb                    ; na뇍en� dalÆho bajtu ze souboru

         jmp       short kodeg              ; nen� je쮝� konec souboru

kodef:                                    ;* konec souboru - zru쮍n� zbyl쁟h �.
         mov       si,ds:[ukazs]
         call      deleten                  ; zru쮍n� v늯ve
         mov       si,ds:[ukazs]            ; ukazatel ukl쟡ac� adresy
         inc       si                       ; zv삩en� ukl쟡ac� adresy
         cmp       si,buffsize              ; je za koncem bufferu ?
         jb        kodeh                    ; nen� je쮝� za koncem bufferu
         xor       si,si                    ; ukazatel na za뇿tek bufferu
kodeh:   mov       ds:[ukazs],si            ; nov� ukl쟡ac� adresa
         mov       si,ds:[ukazr]            ; 뇍ec� adresa
         inc       si                       ; zv삩en� 뇍ec� adresy
         cmp       si,buffsize              ; je za koncem bufferu ?
         jb        kodei                    ; nen� je쮝� za koncem bufferu
         xor       si,si                    ; ukazatel na za뇿tek bufferu
kodei:   mov       ds:[ukazr],si            ; nov� 뇍ec� adresa
         dec       byte ptr ds:[len]
         cmp       byte ptr ds:[len],0
         je        kodej
         mov       si,ds:[ukazr]            ; nov� na뇍en� 쯥t늷ec
         call      insertn                  ; vlo멷n� nov� 쯥t늷ce
kodej:   loop      kodef                    ; dalÆ znak

kodeg:   cmp       byte ptr ds:[len],0
         jbe       kodel                    ; konec
         jmp       kode4                    ; dalÆ k줰

kodel:                                    ;* vypr쟺dn늧� zbytku bufferu k줰u

         mov       cx,di                    ; konec ulo멷n쁟h dat
         mov       si,offset codebuf        ; buffer k줰u
         sub       cx,si                    ; po놽t bajt� v bufferu
         jcxz      koden                    ; nen� dalÆ znak
kodem:   lodsb                              ; bajt k vysl쟮�
         call      wbyte                    ; z쟰is bajtu do souboru
         loop      kodem                    ; z쟰is dalÆho bajtu
koden:   ret


; -----------------------------------------------------------------------------
public   inittree
inittree:                                 ;* inicializace hledac죋o stromu

         mov       cx,offset (konini-zacini)/2 ; velikost buffer� ve slovech
         mov       di,offset zacini         ; za뇿tek buffer�
         mov       ax,null                  ; nulovac� slovo
         cld                                ; sm늭 nahoru
         rep       stosw                    ; vymaz쟮� buffer�
                                          ;* inicializace kruhov괿o bufferu
         mov       di,offset textbuf        ; kruhov� buffer
         mov       cx,buffsize + matchlim   ; velikost kruhov괿o bufferu
         mov       al," "                   ; znak mezery
         rep       stosb                    ; vymaz쟮� kruhov괿o bufferu

         ret

; -----------------------------------------------------------------------------
public   insertn
insertn:                                  ;* vlo멷n� 쯥t늷ce do stromu
                                            ; VSTUP: SI=index 쯥t늷ce
                                            ; V쒾TUP: DL=d굃ka shody
                                            ;         BX=index shodn괿o 쯥t늷ce


         push      ax
         push      cx
         push      si
         push      di

         mov       byte ptr ds:[comp],1     ; pæznak porovn쟮� 쯥t늷c�

         mov       di,word ptr ds:[si+textbuf] ; po뇿te뇆� znak 쯥t늷ce
         and       di,0ffh                  ; ponech� znak 쯥t늷ce
         add       di,buffsize + 1          ; index v bufferu

         push      si
         add       si,si                    ; index * 2
         mov       ds:[si+rson],null        ; inicializace 쯥t늷ce
         mov       ds:[si+lson],null        ; inicializace 쯥t늷ce
         pop       si

         xor       dl,dl                    ; d굃ka shody = 0

insertn1:                                 ;* za뇿tek cyklu vyhled쟶쟮�
         cmp       byte ptr ds:[comp],0     ; je pæznak porovn쟮� >= 0 ?
         jl        insertn3                 ; pæznak porovn쟮� je z쟰orn�

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


insertn7:                                 ;* porovn쟮� 쯥t늷c�
         mov       cx,matchlim-1            ; max. d굃ka textu
         push      si
         push      di
insertn8:inc       si
         inc       di
         mov       al,ds:[si+textbuf]
         sub       al,ds:[di+textbuf]
         jnz       insert88
         loopz     insertn8                 ; je shoda - dalÆ znak
insert88:pop       di
         pop       si
         mov       ds:[comp],al             ; rozd죐 znak�

         mov       al,matchlim              ; maxim쟫n� d굃ka 쯥t늷ce
         sub       al,cl                    ; po놽t shodn쁟h znak�
         cmp       al,dl                    ; je delÆ 쯥t늷ec ?
         jbe       insertna                 ; nen� delÆ 쯥t늷ec
                                          ;* nalezen v늯Æ 쯥t늷
         mov       bx,di                    ; nov� pozice
         mov       dl,al                    ; d굃ka nov괿o 쯥t늷ce
         cmp       dl,matchlim              ; je maxim쟫n� 쯥t늷ec ?
         jae       insertnd                 ; je maxim쟫n� 쯥t늷ec
insertna:
         jmp       insertn1                 ; dalÆ test
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
deleten:                                  ;* zru쮍n� 쯥t늷ce
                                            ; VSTUP: SI=index 쯥t늷ce

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
;                       Rozbor pækazov괿o 찤dku
; -----------------------------------------------------------------------------
public   parnorm
parnorm:                                  ;* normalizace zadan쁟h parametr�
                                            ; VSTUP: ES:DI=ukl쟡ac� adresa
                                            ;        DS=segment PSP
                                            ; V쒾TUP: CX=po놽t parametr�
                                            ;         ZY=nen� 몺dn� parametr

         push      ax
         push      si
         push      di
         cld                                ; sm늭 nahoru
         xor       cx,cx                    ; 눀ta� parametr�
         mov       si,81h                   ; za뇿tek parametr�
         push      si
         add       si,ds:[si-1]             ; konec parametr�
         and       si,0ffh                  ; adresa konce textu
         mov       byte ptr ds:[si],0       ; ozna놽n� konce textu
         pop       si
                                          ;* nalezen� za뇿tku parametru
parnorm1:call      parread                  ; na뇍en� znaku parametr�
         jc        parnorm2                 ; je konec textu
         jz        parnorm1                 ; je odd늢ova� - dalÆ znak
         inc       cx                       ; zv삩en� 눀ta놽 parametr�
parnorm3:                                 ;* p쯥nesen� textu
         stosb                              ; ulo멷n� platn괿o znaku
         call      parread                  ; na뇍en� dalÆho znaku
         ja        parnorm3                 ; je platn� znak - dalÆ znak
         xor       al,al                    ; ukon뇇vac� znak
         stosb                              ; ozna놽n� konce textu
         jmp       short parnorm1           ; dalÆ parametr

parnorm2:xor       al,al                    ; koncov� bajt parametr�
         stosb                              ; ozna놽n� konce parametr�
         or        cx,cx                    ; je n늞ak� parametr ?
         pop       di
         pop       si
         pop       ax
         ret
; -----------------------------------------------------------------------------
public   parget
parget:                                   ;* poskytnut� adresy parametru
                                            ; VSTUP: CX=눀slo parametru
                                            ;        DS:SI=adresa bufferu
                                            ; V쒾TUP: DS:SI=adresa parametru
                                            ;         CY=neplatn� parametr
         push      ax
         push      cx
parget1:                                  ;* nalezen� za뇿tku dalÆho parametru
         cmp       byte ptr ds:[si],0       ; je platn� parametr ?
         stc                                ; pæznak - nen� dalÆ parametr
         je        parget3                  ; nen� dalÆ parametr
         clc
         jcxz      parget3                  ; nalezen parametr
parget2: lodsb                              ; na뇍en� dalÆho znaku
         or        al,al
         jnz       parget2
         dec       cx
         jmp       short parget1            ; dalÆ parametr
parget3:
         pop       cx
         pop       ax
         ret
; -----------------------------------------------------------------------------
public   parrozb
parrozb:                                  ;* rozbor zad쟮� souboru
                                            ; VSTUP: DS:SI=adresa textu
                                            ;        ES:DI=adresa rozboru
                                            ;           1 B: jm굈o disku
                                            ;           1 B: odd늢ova� ":"
                                            ;          64 B: cesta ASCIIZ
                                            ;          13 B: jm굈o soub. ASCIIZ
         push      ax
         push      si
         push      di
parrozb1:call      parread                  ; 뇍en� znaku textu
         jc        parrozb3                 ; konec textu





parrozb3:
         pop       di
         pop       si
         pop       ax
         ret
; -----------------------------------------------------------------------------
parread:                                  ;* 뇍en� bajtu z pækaz. 찤dku
                                            ; VSTUP: DS:SI=ukazatel textu
                                            ; V쒾TUP: AL=znak
                                            ;         CY=nen� dalÆ znak
                                            ;         ZY=je odd늢ova�

         mov       al,ds:[si]               ; znak
         or        al,al
         jz        parread1                 ; je konec textu
         cmp       al,13
         je        parread1                 ; konec textu
         inc       si                       ; zv삩en� adresy
         cmp       al,9                     ; je tabel쟴or ?
         je        parread2                 ; je tabel쟴or
         cmp       al," "                   ; je mezera ?
         je        parread2                 ; je mezera
         stc                                ; pæznak - znak OK
parread1:cmc
parread2:ret
; -----------------------------------------------------------------------------
;                              Diskov� operace
; -----------------------------------------------------------------------------
public   wbyte
wbyte:                                    ;* z쟰is bajtu do v쁲tupn죋o souboru
         push      ax
         push      bx
         mov       bx,ds:[outnum]           ; po놽t bajt� ve v쁲tupn죑 bufferu
         cmp       bx,4095                  ; je ji� konec bufferu ?
         jb        writefb3                 ; nen� je쮝� konec bufferu
         call      writefbuf                ; z쟰is bufferu do souboru
         jc        writefb4                 ; chyba z쟰isu
writefb3:mov       bx,ds:[outnum]           ; ukazatel konce dat v bufferu
         mov       ds:[bx+outbuf],al        ; ulo멷n� bajtu do bufferu
         inc       bx                       ; zv삩en� ukl쟡ac� adresy
         mov       ds:[outnum],bx           ; nov� po놽t bajt� v bufferu


         clc
writefb4:pop       bx
         pop       ax
         ret
; -----------------------------------------------------------------------------
public   writefbuf
writefbuf:                                ;* z쟰is bufferu do souboru
         push      ax
         push      bx
         push      cx
         push      dx
         mov       cx,ds:[outnum]           ; po놽t bajt� v souboru
         or        cx,cx                    ; pæznak operace OK
         jz        writefb2                 ; v bufferu nen� 몺dn� bajt
         mov       bx,ds:[outid]            ; identifik쟴or v쁲tupn죋o souboru
         mov       dx,offset outbuf         ; v쁲tupn� buffer
         mov       ah,40h
         int       21h                      ; z쟰is dat do souboru
         jc        writefb2                 ; chyba z쟰isu
         cmp       ax,cx                    ; souhlas� po놽t zapsan쁟h bajt� ?
writefb2:mov       word ptr ds:[outnum],0   ; vynulov쟮� v쁲tupn죋o bufferu
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret
; -----------------------------------------------------------------------------
public   rbyte
rbyte:                                    ;* 뇍en� bajtu ze souboru
                                            ; V쒾TUP: CY=chyba operace 뇍en�
                                            ;         ZY=je konec souboru
                                            ;         AL=na뇍en� znak

         push      bx
         mov       al,27
         mov       bx,ds:[inpuk]            ; ukazatel 뇍en쁟h dat
         inc       bx                       ; zv삩en� ukazatele 뇍en쁟h dat
         mov       ds:[inpuk],bx
         cmp       ds:[inpnum],bx           ; je ji� konec dat ?
         ja        readfb2                  ; nen� je쮝� konec dat v bufferu
         call      readfbuf                 ; na뇍en� dalÆho bloku dat
         mov       al,27
         jbe       readfb3                  ; chyba 뇍en� nebo konec souboru
readfb2: mov       bx,ds:[inpuk]            ; ukazatel 뇍en쁟h dat
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
readfbuf:                                 ;* na뇍en� bufferu vstupn죋o souboru
                                            ; V쒾TUP: CY=chyba operace 뇍en�
                                            ;         ZY=je konec souboru

         push      ax
         push      bx
         push      cx
         push      dx

         mov       word ptr ds:[inpnum],0   ; vynulov쟮� vstupn죋o bufferu
         mov       word ptr ds:[inpuk],0    ; vynulov쟮� ukazatele 뇍en쁟h dat
         mov       cx,4096                  ; d굃ka vstupn죋o bufferu
         mov       bx,ds:[inpid]            ; identifik쟴or vstupn죋o souboru
         mov       dx,offset inpbuf         ; vstupn� buffer
         mov       ah,3fh
         int       21h                      ; na뇍en� dat ze souboru
         jc        readfbf2                 ; je chyba 뇍en�
         mov       ds:[inpnum],ax           ; ulo멷n� po뇍u na뇍en쁟h dat
         or        ax,ax                    ; nastaven� pæznaku ZF

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

inpid    dw        0                        ; identifik쟴or vstupn죋o souboru
outid    dw        0                        ; identifik쟴or v쁲tupn죋o souboru

inpnum   dw        0                        ; po놽t bajt� ve vstupn죑 souboru
inpuk    dw        0                        ; ukazatel dat ve vstupn죑 souboru
outnum   dw        0                        ; po놽t bajt� ve v쁲tupn죑 souboru
citac    dw        400h                     ; 눀ta� pro zobrazen� pr뻖늜u

konec    label     near                     ; konec programu

public   codebuf,ukazs,ukazr,ukazp,len,comp

codebuf  db        17 dup(?)                ; buffer k줰�
ukazs    dw        ?                        ; ukl쟡ac� index do bufferu
ukazr    dw        ?                        ; 뇍ec� index z bufferu
ukazp    dw        ?                        ; pomocn� ukazatel bufferu
len      db        ?                        ; d굃ka shody
comp     db        ?                        ; pæznak porovn쟮�

commbuf  db        128 dup(?)               ; buffer pækazov괿o 찤dku
; ----------------------------- buffery dat -----------------------------------
public   inpbuf,outbuf,textbuf,lson,rson,dad

inpbuf   db        4096 dup(?)              ; buffer vstupn죋o souboru
outbuf   db        4096 dup(?)              ; buffer v쁲tupn죋o souboru

textbuf  db        buffsize + matchlim dup(?)  ; kruhov� buffer

zacini   label     byte                   ;* za뇿tek inicializace
lson     dw        buffsize + 1 dup(?)      ; lev� v늯ev
rson     dw        buffsize + 1 + 256 dup(?); prav� v늯ev + ko쯥ny
dad      dw        buffsize + 1 dup(?)      ; otcovsk� v늯ve
konini   label     byte                   ;* konec inicializace

code     ENDS
         END       komp

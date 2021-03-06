
; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�
;
;                                    SUBPAR
;                       dosazeni parametru ze seznamu
;
; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; ------ zobrazen� 즪odn죋o textu

Start:   mov       dx,offset UvTxt
         mov       ah,9
         int       21h                      ; zobrazen� 즪odn죋o textu

; ------ kontrola velikosti pam늯i

         cmp       sp,offset Konec + 200h   ; je dosta pam늯i ?
         jae       Start1                   ; pam닟 je OK

; ------ chyba

         mov       dx,offset MemTxt         ; chyba - nedostatek pam늯i
Chyba:   mov       ah,9
         int       21h
         mov       ax,4c01h
         int       21h                      ; konec s chybou

; ------ pæprava pækazov괿o 찤dku

Start1:  mov       si,81h                   ; za뇿tek pækazov괿o 찤dku
         mov       bl,ds:[si-1]             ; d굃ka pækazov괿o 찤dku
         mov       bh,0
         mov       ds:[si+bx],bh            ; ozna놽n� konce textu pækaz. 찤dku
         mov       dx,offset HelpTxt        ; n쟰ov늕a p쯫 chyb� zad쟮�

; ------ nalezen� za뇿tku jm굈a souboru

         call      ParSpc                   ; vypu쮝늧� mezer
         jc        Chyba                    ; chyba - soubor nezad쟮

; ------ nalezen� konce jm굈a souboru

         mov       di,si                    ; 즧chova za뇿tku jm굈a souboru
Start2:  call      ParChr                   ; vstup dalÆho znaku
         ja        Start2                   ; platn� znak
         jc        Chyba                    ; chyba - nen� zad쟮 pækaz
         mov       ds:[si-1],bh             ; ozna놽n� konce jm굈a souboru

; ------ nalezen� za뇿tku pækazu

         call      ParSpc                   ; vypu쮝늧� mezer
         jc        Chyba                    ; chyba - parametr nezad쟮
         cmp       al,'"'                   ; je 즪odn� znak uvozovek ?
         jne       Start21                  ; nen� 즪odn� znak uvozovek
         inc       si                       ; vypu쮝늧� znaku uvozovek
Start21: mov       ds:[AdrComm],si          ; 즧chova za뇿tku pækazu

; ------ kontrola, zda je alespo� jeden parametr @

Start23: call      ParChr                   ; dalÆ znak
         jc        Chyba                    ; chyba - nen� znak "@"
         cmp       al,'"'                   ; jsou uvozovky ?
         jne       Start24                  ; nejsou uvozovky
         call      ParChr                   ; dalÆ znak parametru
         jc        Chyba                    ; chyba - nen� znak "@"
         cmp       al,'"'
         jne       Chyba                    ; konec parametru - nen� znak "@"

Start24: cmp       al,"@"                   ; je znak parametru ?
         jne       Start23                  ; nen� znak parametru
         call      ParChr                   ; dalÆ znak parametru
         jc        Start25                  ; konec parametru - to je OK
         cmp       al,"@"                   ; je zdvojen� znak "@" ?
         je        Start23                  ; je zdvojen� znak parametru

; ------ otev쯥n� vstupn죋o souboru parametr�

Start25: mov       dx,di                    ; jm굈o vstupn죋o souboru parametr�
         mov       ax,3d00h
         int       21h                      ; otev쯥n� vstupn죋o souboru
         mov       dx,offset FndTxt         ; text - soubor nenalezen
Chyba2:  jc        Chyba                    ; chyba - soubor nenalezen
         mov       ds:[InpIdnt],ax          ; identifik쟴or vstupn죋o souboru

; ------ test verze syst굆u (zda je cesta v prost쯥d�)

         mov       ah,30h
         int       21h                      ; poskytnut� verze syst굆u
         cmp       al,3                     ; je verze alespo� 3.00 ?
         jb        Start4                   ; n죥k� verze syst굆u

; ------ nalezen� cesty k programu v prost쯥d�

         mov       cx,ds:[2ch]              ; segment prost쯥d�
         jcxz      Start4                   ; prost쯥d� nedefinov쟮o
         push      ds
         xor       ax,ax
         mov       ds,cx                    ; segment prost쯥d�
         xor       si,si
Start3:  inc       si                       ; zv삩en� ukazatele v prost쯥d�
         cmp       ds:[si-1],ax             ; konec prost쯥d� ?
         jne       Start3                   ; nalezen� konce prost쯥d�

; ------ p쯥nesen� jm굈a souboru

         mov       di,offset SoubBuf        ; buffer jm굈a souboru
         add       si,3                     ; za뇿tek textu jm굈a souboru
         cld
         mov       cx,76/2                  ; max. d굃ka textu cesty
         rep       movsw                    ; p쯥nesen� jm굈a souboru
         pop       ds

; ------ nalezen� konce cesty souboru

Start4:  mov       si,offset SoubBuf        ; buffer jm굈a souboru
         mov       dx,si                    ; 즧chova za뇿tku jm굈a souboru
         cld
Start5:  mov       di,si                    ; 즧chova za뇿tku jm굈a souboru
Start6:  lodsb                              ; na뇍en� znaku
         cmp       al,"\"                   ; odd늢ova� cesty ?
         je        Start5                   ; odd늢ova� cesty
         cmp       al,":"                   ; odd늢ova� disku ?
         je        Start5                   ; odd늢ova� disku
         cmp       al,0                     ; konec jm굈a souboru ?
         jne       Start6                   ; je platn� znak jm굈a

; ------ p쯫d쟮� jm굈a souboru SUBPAR_.BAT

         mov       si,offset Soubor         ; jm굈o souboru
         mov       cx,12/2                  ; d굃ka textu jm굈a souboru
         rep       movsw                    ; p쯫d쟮� jm굈a souboru

; ------ otev쯥n� v쁲tupn죋o souboru (zde je CX=0)

         mov       ah,3ch
;         xor       cx,cx                    ; atributy souboru
         int       21h                      ; vytvo쯥n� souboru
         mov       dx,offset WritTxt        ; text - chyba z쟰isu
         jc        Chyba2                   ; chyba vytvo쯥n� souboru
         mov       ds:[OutIdnt],ax          ; idetnifik쟴or v쁲tupn죋o souboru

; ------ pæprava k dalÆmu pækazu

Start7:  call      InpCh                    ; vstup dalÆho znaku
         jc        Start9                   ; nen� dalÆ parametr - konec
         mov       ds:[StackCh],al          ; 즧chova znaku

; ------ p쯥nesen� textu

         mov       si,ds:[AdrComm]          ; adresa povelu
Start80: call      ParChr                   ; znak parametru
         jc        Start89                  ; konec parametru
         cmp       al,'"'                   ;
         jne       Start82
         call      ParChr                   ; dalÆ znak
         jc        Start89                  ; konec parametru
         cmp       al,'"'
         jne       Start89                  ; konec parametru

Start82: cmp       al,"@"
         jne       Start88                  ; nen� znak "@"
         call      ParChr                   ; dalÆ znak
         jc        Start83                  ; byl to parametr
         cmp       al,"@"
         je        Start88                  ; byl to zdvojen� znak
         dec       si                       ; n쟶rat znaku

Start83: call      InpCh                    ; znak 찤dku
         jc        Start80                  ; nen� dalÆ znak
         cmp       al,13                    ; je CR ?
         je        Start80                  ; konec 찤dku
         call      OutCh                    ; z쟰is znaku parametru
         jmp       short Start83

Start88: call      OutCh                    ; ulo멷n� znaku
         jmp       short Start80            ; dalÆ znak

; ------ z쟰is konce 찤dku

Start89: mov       al,13
         call      OutCh                    ; z쟰is znaku CR
         mov       al,10
         call      OutCh                    ; z쟰is znaku LF
         jmp       short Start7             ; dalÆ 찤dek pækazu

; ------ uzav쯥n� vstupn죋o souboru

Start9:  mov       bx,ds:[InpIdnt]          ; identifik쟴or vstupn죋o souboru
         mov       ah,3eh
         int       21h                      ; uzav쯥n� vstupn죋o souboru

; ------ uzav쯥n� v쁲tupn죋o souboru

         call      WritBuf                  ; ulo멷n� bufferu na disk
         mov       bx,ds:[OutIdnt]          ; identifik쟴or v쁲tupn죋o souboru
         mov       ah,3eh
         int       21h                      ; uzav쯥n� v쁲tupn죋o souboru

; ------ konec programu OK

         mov       ax,4c00h
         int       21h

; -----------------------------------------------------------------------------
;        vypu쮝늧� mezer z pækazov괿o 찤dku
; -----------------------------------------------------------------------------

ParSpc   PROC      NEAR

         call      ParChr                   ; na뇍en� znaku z pækaz. 찤dku
         jc        ParChr                   ; nen� dalÆ znak
         je        ParSpc                   ; vypu쮝늧� mezery
         dec       si                       ; n쟶rat platn괿o znaku
ParSpc2: ret

ParSpc   ENDP

; -----------------------------------------------------------------------------
;        na뇍en� znaku z pækazov괿o 찤dku
; -----------------------------------------------------------------------------

ParChr   PROC      NEAR

; ------ vstup znaku z pækazov괿o 찤dku

         cld
         lodsb                              ; na뇍en� znaku z pækazov괿o 찤dku

; ------ kontrola, zda je to platn� znak

         cmp       al," "                   ; je to platn� znak ?
         jae       ParChr2                  ; je to platn� znak nebo mezera
         dec       si                       ; n쟶rat neplatn괿o znaku
ParChr2: ret

ParChr   ENDP

; -----------------------------------------------------------------------------
;        vstup znaku ze vstupn죋o souboru (CY=nen� dalÆ znak)
; -----------------------------------------------------------------------------

InpCh    PROC      NEAR

; ------ na뇍en� znaku ze z쟳obn죏u

         mov       al,1ah                   ; znak konce souboru
         xchg      al,ds:[StackCh]          ; vyjmut� znaku z bufferu
         cmp       al,1ah                   ; je v bufferu znak ?
         clc
         jne       InpCh6                   ; v bufferu byl znak

; ------ test, zda jsou v bufferu je쮝� data

         push      si
InpCh1:  mov       si,ds:[InpBRead]         ; 뇍ec� offset z bufferu
         cmp       si,ds:[InpBNum]          ; jsou ji� v쮍chna data z bufferu ?
         jb        InpCh3                   ; v bufferu jsou je쮝� data

; ------ na뇍en� dalÆho bloku do bufferu

         push      ax
         push      bx
         push      cx
         push      dx
         mov       dx,offset InpBuff        ; vstupn� buffer
         mov       bx,ds:[InpIdnt]          ; identifik쟴or vstupn죋o souboru
         mov       ah,3fh
         mov       cx,100h                  ; velikost vstupn죋o bufferu
         int       21h
         jnc       InpCh2                   ; 뇍en� OK
         xor       ax,ax                    ; chyba operace
InpCh2:  mov       ds:[InpBNum],ax          ; nov� po놽t bajt� v bufferu
         cmp       ax,1                     ; test, zda bylo n늓o na뇍eno
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         mov       al,1ah                   ; n쟦radn� znak konce souboru
         jc        InpCh5                   ; konec souboru

; ------ vstup znaku z bufferu

         xor       si,si                    ; nov� offset v bufferu
InpCh3:  mov       al,ds:[si+InpBuff]       ; znak z bufferu
         inc       si
         mov       ds:[InpBRead],si         ; nov� 뇍ec� adresa z bufferu

; ------ ignorov쟮� zvl젴tn죅h znak�

         cmp       al,10                    ; znak LF ?
         je        InpCh1                   ; LF se ignoruje
         cmp       al,1ah                   ; je konec souboru ?
         je        InpCh1                   ; je znak konce souboru

; ------ n쟶rat registr�

InpCh5:  pop       si
InpCh6:  ret

InpCh    ENDP

; -----------------------------------------------------------------------------
;        v쁲tup znaku do v쁲tupn죋o bufferu
; -----------------------------------------------------------------------------

OutCh    PROC      NEAR

         push      si
         mov       si,ds:[OutBNum]          ; po놽t bajt� v bufferu
         cmp       si,100h                  ; je buffer pln� ?
         jb        OutCh2                   ; buffer nen� pln�
         call      WritBuf                  ; ulo멷n� bufferu na disk
         xor       si,si                    ; nov� po놽t bajt� v bufferu
OutCh2:  mov       ds:[OutBuff+si],al       ; ulo멷n� znaku do bufferu
         inc       si                       ; zv삩en� po뇍u bajt�
         mov       ds:[OutBNum],si          ; nov� po놽t bajt� v bufferu
OutCh4:  pop       si
         ret

OutCh    ENDP

; -----------------------------------------------------------------------------
;        z쟰is v쁲tupn죋o bufferu na disk (CY=chyba)
; -----------------------------------------------------------------------------

WritBuf  PROC      NEAR

; ------ 즧chova registr�

         push      ax
         push      bx
         push      cx
         push      dx

; ------ z쟰is bufferu na disk

         mov       ah,40h
         mov       bx,ds:[OutIdnt]          ; identifik쟴or v쁲tupn죋o souboru
         mov       cx,ds:[OutBNum]          ; po놽t bajt� ve v쁲tupn죑 bufferu
         mov       dx,offset OutBuff        ; v쁲tupn� bufferu
         int       21h                      ; z쟰is bufferu na disk
         mov       word ptr ds:[OutBNum],0  ; zru쮍n� dat z bufferu
         jc        WritBuf2                 ; chyba operace
         cmp       ax,cx                    ; byla zaps쟮a v쮍chna data ?

; ------ n쟶rat registr�

WritBuf2:pop       dx
         pop       cx
         pop       bx
         pop       ax
         jc        WritBuf4                 ; chyba
         ret

WritBuf4:mov       dx,offset WritTxt
         jmp       Chyba                    ; chyba z쟰isu

WritBuf  ENDP

; *****************************************************************************
;
;                                Data
;
; *****************************************************************************

MemTxt   db        'Nedostatek pameti !',13,10,'$'

FndTxt   db        'Chyba - soubor se seznamem parametru nenalezen !',13,10,'$'
WritTxt  db        'Chyba zapisu do vystupniho souboru SUBPAR@.BAT !',13,10,'$'

UvTxt    db        'SUBPAR V1.0 - dosazeni parametru ze seznamu; (c) Miroslav Nemecek',13,10,'$'

HelpTxt  db        ' Zadejte: SUBPAR  seznam  "prikaz"',13,10
         db        '                    �        읕컴컴 prikaz k vicenasobnemu provedeni',13,10
         db        '                    읕컴컴컴컴컴컴� jmeno souboru se seznamem parametru',13,10
         db        ' V prikazu se za kazdy znak @ dosadi jeden radek ze seznamu.',13,10
         db        ' Platny znak @ (resp. ") se uvede jako dva znaky @@ (resp. "").',13,10
         db        ' Vystupem je povelovy soubor SUBPAR@.BAT v adresari programu SUBPAR.',13,10
         db        '$'

Soubor   db        'SUBPAR@.BAT',0
SoubBuf  db        88 dup(0)                ; v쁲tupn� soubor

StackCh  db        1ah                      ; uschovan� znak za뇿tku parametru
                                            ;  (1ah - je konec souboru)

         EVEN
InpBNum  dw        0                        ; po놽t bajt� ve vstupn죑 bufferu
InpBRead dw        0                        ; 뇍ec� offset ve vstupn죑 bufferu
OutBNum  dw        0                        ; po놽t bajt� ve v쁲tupn죑 bufferu

InpIdnt  dw        ?                        ; identifik쟴or vstupn죋o souboru
OutIdnt  dw        ?                        ; identifik쟴or v쁲tupn죋o souboru
AdrComm  dw        ?                        ; adresa povelu k substituci

InpBuff  db        100h dup(?)              ; vstupn� buffer
OutBuff  db        100h dup(?)              ; v쁲tupn� buffer

Konec    label     near                     ; konec programu

Code     ENDS
         END       Start

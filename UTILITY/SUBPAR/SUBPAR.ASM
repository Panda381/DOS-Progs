
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                                    SUBPAR
;                       dosazeni parametru ze seznamu
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; ------ zobrazen¡ £vodn¡ho textu

Start:   mov       dx,offset UvTxt
         mov       ah,9
         int       21h                      ; zobrazen¡ £vodn¡ho textu

; ------ kontrola velikosti pamˆti

         cmp       sp,offset Konec + 200h   ; je dosta pamˆti ?
         jae       Start1                   ; pamˆŸ je OK

; ------ chyba

         mov       dx,offset MemTxt         ; chyba - nedostatek pamˆti
Chyba:   mov       ah,9
         int       21h
         mov       ax,4c01h
         int       21h                      ; konec s chybou

; ------ p©¡prava p©¡kazov‚ho © dku

Start1:  mov       si,81h                   ; za‡ tek p©¡kazov‚ho © dku
         mov       bl,ds:[si-1]             ; d‚lka p©¡kazov‚ho © dku
         mov       bh,0
         mov       ds:[si+bx],bh            ; ozna‡en¡ konce textu p©¡kaz. © dku
         mov       dx,offset HelpTxt        ; n povˆda p©i chybˆ zad n¡

; ------ nalezen¡ za‡ tku jm‚na souboru

         call      ParSpc                   ; vypu¨tˆn¡ mezer
         jc        Chyba                    ; chyba - soubor nezad n

; ------ nalezen¡ konce jm‚na souboru

         mov       di,si                    ; £schova za‡ tku jm‚na souboru
Start2:  call      ParChr                   ; vstup dal¨¡ho znaku
         ja        Start2                   ; platn˜ znak
         jc        Chyba                    ; chyba - nen¡ zad n p©¡kaz
         mov       ds:[si-1],bh             ; ozna‡en¡ konce jm‚na souboru

; ------ nalezen¡ za‡ tku p©¡kazu

         call      ParSpc                   ; vypu¨tˆn¡ mezer
         jc        Chyba                    ; chyba - parametr nezad n
         cmp       al,'"'                   ; je £vodn¡ znak uvozovek ?
         jne       Start21                  ; nen¡ £vodn¡ znak uvozovek
         inc       si                       ; vypu¨tˆn¡ znaku uvozovek
Start21: mov       ds:[AdrComm],si          ; £schova za‡ tku p©¡kazu

; ------ kontrola, zda je alespo¤ jeden parametr @

Start23: call      ParChr                   ; dal¨¡ znak
         jc        Chyba                    ; chyba - nen¡ znak "@"
         cmp       al,'"'                   ; jsou uvozovky ?
         jne       Start24                  ; nejsou uvozovky
         call      ParChr                   ; dal¨¡ znak parametru
         jc        Chyba                    ; chyba - nen¡ znak "@"
         cmp       al,'"'
         jne       Chyba                    ; konec parametru - nen¡ znak "@"

Start24: cmp       al,"@"                   ; je znak parametru ?
         jne       Start23                  ; nen¡ znak parametru
         call      ParChr                   ; dal¨¡ znak parametru
         jc        Start25                  ; konec parametru - to je OK
         cmp       al,"@"                   ; je zdvojen˜ znak "@" ?
         je        Start23                  ; je zdvojen˜ znak parametru

; ------ otev©en¡ vstupn¡ho souboru parametr–

Start25: mov       dx,di                    ; jm‚no vstupn¡ho souboru parametr–
         mov       ax,3d00h
         int       21h                      ; otev©en¡ vstupn¡ho souboru
         mov       dx,offset FndTxt         ; text - soubor nenalezen
Chyba2:  jc        Chyba                    ; chyba - soubor nenalezen
         mov       ds:[InpIdnt],ax          ; identifik tor vstupn¡ho souboru

; ------ test verze syst‚mu (zda je cesta v prost©ed¡)

         mov       ah,30h
         int       21h                      ; poskytnut¡ verze syst‚mu
         cmp       al,3                     ; je verze alespo¤ 3.00 ?
         jb        Start4                   ; n¡zk  verze syst‚mu

; ------ nalezen¡ cesty k programu v prost©ed¡

         mov       cx,ds:[2ch]              ; segment prost©ed¡
         jcxz      Start4                   ; prost©ed¡ nedefinov no
         push      ds
         xor       ax,ax
         mov       ds,cx                    ; segment prost©ed¡
         xor       si,si
Start3:  inc       si                       ; zv˜¨en¡ ukazatele v prost©ed¡
         cmp       ds:[si-1],ax             ; konec prost©ed¡ ?
         jne       Start3                   ; nalezen¡ konce prost©ed¡

; ------ p©enesen¡ jm‚na souboru

         mov       di,offset SoubBuf        ; buffer jm‚na souboru
         add       si,3                     ; za‡ tek textu jm‚na souboru
         cld
         mov       cx,76/2                  ; max. d‚lka textu cesty
         rep       movsw                    ; p©enesen¡ jm‚na souboru
         pop       ds

; ------ nalezen¡ konce cesty souboru

Start4:  mov       si,offset SoubBuf        ; buffer jm‚na souboru
         mov       dx,si                    ; £schova za‡ tku jm‚na souboru
         cld
Start5:  mov       di,si                    ; £schova za‡ tku jm‚na souboru
Start6:  lodsb                              ; na‡ten¡ znaku
         cmp       al,"\"                   ; oddˆlova‡ cesty ?
         je        Start5                   ; oddˆlova‡ cesty
         cmp       al,":"                   ; oddˆlova‡ disku ?
         je        Start5                   ; oddˆlova‡ disku
         cmp       al,0                     ; konec jm‚na souboru ?
         jne       Start6                   ; je platn˜ znak jm‚na

; ------ p©id n¡ jm‚na souboru SUBPAR_.BAT

         mov       si,offset Soubor         ; jm‚no souboru
         mov       cx,12/2                  ; d‚lka textu jm‚na souboru
         rep       movsw                    ; p©id n¡ jm‚na souboru

; ------ otev©en¡ v˜stupn¡ho souboru (zde je CX=0)

         mov       ah,3ch
;         xor       cx,cx                    ; atributy souboru
         int       21h                      ; vytvo©en¡ souboru
         mov       dx,offset WritTxt        ; text - chyba z pisu
         jc        Chyba2                   ; chyba vytvo©en¡ souboru
         mov       ds:[OutIdnt],ax          ; idetnifik tor v˜stupn¡ho souboru

; ------ p©¡prava k dal¨¡mu p©¡kazu

Start7:  call      InpCh                    ; vstup dal¨¡ho znaku
         jc        Start9                   ; nen¡ dal¨¡ parametr - konec
         mov       ds:[StackCh],al          ; £schova znaku

; ------ p©enesen¡ textu

         mov       si,ds:[AdrComm]          ; adresa povelu
Start80: call      ParChr                   ; znak parametru
         jc        Start89                  ; konec parametru
         cmp       al,'"'                   ;
         jne       Start82
         call      ParChr                   ; dal¨¡ znak
         jc        Start89                  ; konec parametru
         cmp       al,'"'
         jne       Start89                  ; konec parametru

Start82: cmp       al,"@"
         jne       Start88                  ; nen¡ znak "@"
         call      ParChr                   ; dal¨¡ znak
         jc        Start83                  ; byl to parametr
         cmp       al,"@"
         je        Start88                  ; byl to zdvojen˜ znak
         dec       si                       ; n vrat znaku

Start83: call      InpCh                    ; znak © dku
         jc        Start80                  ; nen¡ dal¨¡ znak
         cmp       al,13                    ; je CR ?
         je        Start80                  ; konec © dku
         call      OutCh                    ; z pis znaku parametru
         jmp       short Start83

Start88: call      OutCh                    ; ulo‘en¡ znaku
         jmp       short Start80            ; dal¨¡ znak

; ------ z pis konce © dku

Start89: mov       al,13
         call      OutCh                    ; z pis znaku CR
         mov       al,10
         call      OutCh                    ; z pis znaku LF
         jmp       short Start7             ; dal¨¡ © dek p©¡kazu

; ------ uzav©en¡ vstupn¡ho souboru

Start9:  mov       bx,ds:[InpIdnt]          ; identifik tor vstupn¡ho souboru
         mov       ah,3eh
         int       21h                      ; uzav©en¡ vstupn¡ho souboru

; ------ uzav©en¡ v˜stupn¡ho souboru

         call      WritBuf                  ; ulo‘en¡ bufferu na disk
         mov       bx,ds:[OutIdnt]          ; identifik tor v˜stupn¡ho souboru
         mov       ah,3eh
         int       21h                      ; uzav©en¡ v˜stupn¡ho souboru

; ------ konec programu OK

         mov       ax,4c00h
         int       21h

; -----------------------------------------------------------------------------
;        vypu¨tˆn¡ mezer z p©¡kazov‚ho © dku
; -----------------------------------------------------------------------------

ParSpc   PROC      NEAR

         call      ParChr                   ; na‡ten¡ znaku z p©¡kaz. © dku
         jc        ParChr                   ; nen¡ dal¨¡ znak
         je        ParSpc                   ; vypu¨tˆn¡ mezery
         dec       si                       ; n vrat platn‚ho znaku
ParSpc2: ret

ParSpc   ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ znaku z p©¡kazov‚ho © dku
; -----------------------------------------------------------------------------

ParChr   PROC      NEAR

; ------ vstup znaku z p©¡kazov‚ho © dku

         cld
         lodsb                              ; na‡ten¡ znaku z p©¡kazov‚ho © dku

; ------ kontrola, zda je to platn˜ znak

         cmp       al," "                   ; je to platn˜ znak ?
         jae       ParChr2                  ; je to platn˜ znak nebo mezera
         dec       si                       ; n vrat neplatn‚ho znaku
ParChr2: ret

ParChr   ENDP

; -----------------------------------------------------------------------------
;        vstup znaku ze vstupn¡ho souboru (CY=nen¡ dal¨¡ znak)
; -----------------------------------------------------------------------------

InpCh    PROC      NEAR

; ------ na‡ten¡ znaku ze z sobn¡ku

         mov       al,1ah                   ; znak konce souboru
         xchg      al,ds:[StackCh]          ; vyjmut¡ znaku z bufferu
         cmp       al,1ah                   ; je v bufferu znak ?
         clc
         jne       InpCh6                   ; v bufferu byl znak

; ------ test, zda jsou v bufferu je¨tˆ data

         push      si
InpCh1:  mov       si,ds:[InpBRead]         ; ‡tec¡ offset z bufferu
         cmp       si,ds:[InpBNum]          ; jsou ji‘ v¨echna data z bufferu ?
         jb        InpCh3                   ; v bufferu jsou je¨tˆ data

; ------ na‡ten¡ dal¨¡ho bloku do bufferu

         push      ax
         push      bx
         push      cx
         push      dx
         mov       dx,offset InpBuff        ; vstupn¡ buffer
         mov       bx,ds:[InpIdnt]          ; identifik tor vstupn¡ho souboru
         mov       ah,3fh
         mov       cx,100h                  ; velikost vstupn¡ho bufferu
         int       21h
         jnc       InpCh2                   ; ‡ten¡ OK
         xor       ax,ax                    ; chyba operace
InpCh2:  mov       ds:[InpBNum],ax          ; nov˜ po‡et bajt– v bufferu
         cmp       ax,1                     ; test, zda bylo nˆco na‡teno
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         mov       al,1ah                   ; n hradn¡ znak konce souboru
         jc        InpCh5                   ; konec souboru

; ------ vstup znaku z bufferu

         xor       si,si                    ; nov˜ offset v bufferu
InpCh3:  mov       al,ds:[si+InpBuff]       ; znak z bufferu
         inc       si
         mov       ds:[InpBRead],si         ; nov  ‡tec¡ adresa z bufferu

; ------ ignorov n¡ zvl ¨tn¡ch znak–

         cmp       al,10                    ; znak LF ?
         je        InpCh1                   ; LF se ignoruje
         cmp       al,1ah                   ; je konec souboru ?
         je        InpCh1                   ; je znak konce souboru

; ------ n vrat registr–

InpCh5:  pop       si
InpCh6:  ret

InpCh    ENDP

; -----------------------------------------------------------------------------
;        v˜stup znaku do v˜stupn¡ho bufferu
; -----------------------------------------------------------------------------

OutCh    PROC      NEAR

         push      si
         mov       si,ds:[OutBNum]          ; po‡et bajt– v bufferu
         cmp       si,100h                  ; je buffer pln˜ ?
         jb        OutCh2                   ; buffer nen¡ pln˜
         call      WritBuf                  ; ulo‘en¡ bufferu na disk
         xor       si,si                    ; nov˜ po‡et bajt– v bufferu
OutCh2:  mov       ds:[OutBuff+si],al       ; ulo‘en¡ znaku do bufferu
         inc       si                       ; zv˜¨en¡ po‡tu bajt–
         mov       ds:[OutBNum],si          ; nov˜ po‡et bajt– v bufferu
OutCh4:  pop       si
         ret

OutCh    ENDP

; -----------------------------------------------------------------------------
;        z pis v˜stupn¡ho bufferu na disk (CY=chyba)
; -----------------------------------------------------------------------------

WritBuf  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx

; ------ z pis bufferu na disk

         mov       ah,40h
         mov       bx,ds:[OutIdnt]          ; identifik tor v˜stupn¡ho souboru
         mov       cx,ds:[OutBNum]          ; po‡et bajt– ve v˜stupn¡m bufferu
         mov       dx,offset OutBuff        ; v˜stupn¡ bufferu
         int       21h                      ; z pis bufferu na disk
         mov       word ptr ds:[OutBNum],0  ; zru¨en¡ dat z bufferu
         jc        WritBuf2                 ; chyba operace
         cmp       ax,cx                    ; byla zaps na v¨echna data ?

; ------ n vrat registr–

WritBuf2:pop       dx
         pop       cx
         pop       bx
         pop       ax
         jc        WritBuf4                 ; chyba
         ret

WritBuf4:mov       dx,offset WritTxt
         jmp       Chyba                    ; chyba z pisu

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
         db        '                    ³        ÀÄÄÄÄÄ prikaz k vicenasobnemu provedeni',13,10
         db        '                    ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄ jmeno souboru se seznamem parametru',13,10
         db        ' V prikazu se za kazdy znak @ dosadi jeden radek ze seznamu.',13,10
         db        ' Platny znak @ (resp. ") se uvede jako dva znaky @@ (resp. "").',13,10
         db        ' Vystupem je povelovy soubor SUBPAR@.BAT v adresari programu SUBPAR.',13,10
         db        '$'

Soubor   db        'SUBPAR@.BAT',0
SoubBuf  db        88 dup(0)                ; v˜stupn¡ soubor

StackCh  db        1ah                      ; uschovan˜ znak za‡ tku parametru
                                            ;  (1ah - je konec souboru)

         EVEN
InpBNum  dw        0                        ; po‡et bajt– ve vstupn¡m bufferu
InpBRead dw        0                        ; ‡tec¡ offset ve vstupn¡m bufferu
OutBNum  dw        0                        ; po‡et bajt– ve v˜stupn¡m bufferu

InpIdnt  dw        ?                        ; identifik tor vstupn¡ho souboru
OutIdnt  dw        ?                        ; identifik tor v˜stupn¡ho souboru
AdrComm  dw        ?                        ; adresa povelu k substituci

InpBuff  db        100h dup(?)              ; vstupn¡ buffer
OutBuff  db        100h dup(?)              ; v˜stupn¡ buffer

Konec    label     near                     ; konec programu

Code     ENDS
         END       Start

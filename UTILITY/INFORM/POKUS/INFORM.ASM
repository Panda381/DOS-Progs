COMMENT %
                             Informace o po‡¡ta‡i
        %

;------------------------------------------------------------------------------
;                             Programov˜ segment
;------------------------------------------------------------------------------

code     SEGMENT
         ASSUME    cs:code,ds:code

         org       100h

start:                                      ; hlavn¡ tˆlo programu

         mov       word ptr ds:[stackSP],sp   ; £schova SP
         mov       word ptr ds:[stackSP+2],ss ; £schova SS
         mov       si,offset uvtxt          ; £vodn¡ text
         call      tsktxt                   ; tisk textu na displej

         call      open                     ; otev©en¡ v˜stupn¡ho souboru


         mov       si,offset outuvod        ; z kladn¡ text k v˜stupu
         call      outtxt                   ; z pis £vodn¡ho textu

         call      identpc
         call      outtxt


         mov       cx,5
strt1:   mov       si,offset outcr
         call      outtxt
         loop      strt1

         call      close                    ; uzav©en¡ souboru

         int       20h                      ; ukon‡en¡ programu







identpc:                                    ; identifikace PC
         push      ds
         mov       ax,0f000h
         mov       ds,ax
         mov       si,0fffeh
         lodsb
         pop       ds
         mov       si,offset outnezn
         cmp       al,0ffh
         jne       identpc1
         mov       si,offset outpc
identpc1:cmp       al,0feh
         jne       identpc2
         mov       si,offset outpcxt
identpc2:cmp       al,0fdh
         jne       identpc3
         mov       si,offset outpcjr
identpc3:cmp       al,0fch
         jne       identpc4
         mov       si,offset outat
identpc4:cmp       al,0fbh
         jne       identpc5
         mov       si,offset outxt
identpc5:cmp       al,0f9h
         jne       identpc6
         mov       si,offset outpccon
identpc6:ret


outtxt:                                     ; v˜stup textu do souboru
                                            ; VSTUP: DS:SI=text k v˜stupu

         push      cx                       ; £schova CX
outtx0:  lodsb                              ; znak k tisku
         or        al,al                    ; je ji‘ posledn¡ znak textu ?
         jz        outtx4                   ; je konec textu
         cmp       al,31                    ; je ©¡d¡c¡ znak ?
         ja        outtx1                   ; nen¡ ©¡d¡c¡ znak
         jb        outtx2                   ; je k¢d pro po‡et mezer
         mov       al,13                    ; je od© dkov n¡ - znak <CR>
         call      zapis                    ; v˜stup znaku <CR>
         mov       al,10                    ; znak <LF>
outtx1:  call      zapis                    ; z pis znaku do souboru
         jmp       short outtx0             ; dal¨¡ znak k zobrazen¡
outtx2:  xor       cx,cx                    ; CX <- 0000
         mov       cl,al                    ; po‡et mezer k v˜stupu
         mov       al,32                    ; znak mezery
outtx3:  call      zapis                    ; v˜stup znaku mezery
         loop      outtx3                   ; v˜stup dal¨¡ho znaku mezery
         jmp       short outtx0             ; dal¨¡ znak k zobrazen¡
outtx4:  pop        cx                       ; n vrat CX
         ret



tsktxt:                                     ; tisk textu na displej
                                            ; VSTUP: DS:SI=text k tisku

         push      dx
tsktxt0: lodsb                              ; znak k tisku
         or        al,al                    ; je ji‘ posledn¡ znak textu ?
         jz        tsktxt2                  ; je konec textu
         mov       ah,2                     ; funkce zobrazen¡ znaku
         mov       dl,al                    ; znak k zobrazen¡
         int       21h                      ; zobrazen¡ znaku textu
         jmp       short tsktxt0            ; dal¨¡ znak k zobrazen¡
tsktxt2: pop       dx
         ret




open:                                       ; otev©en¡ v˜stupn¡ho souboru
         mov       ah,11h                   ; funkce nalezen¡ souboru FCB
         mov       dx,offset fcb            ; FCB souboru
         int       21h                      ; nalezen¡ souboru
         inc       al                       ; soubor nalezen ?
         jz        open2                    ; soubor nenalezen - lze vytvo©it
         mov       si,offset soubex + 3     ; konec extentu
open1:   call      incsoub                  ; zv˜¨en¡ ‡¡slice souboru
         jc        open1                    ; je p©enos - dal¨¡ znak
         cmp       byte ptr [si],"0"        ; je prvn¡ z ‡¡slic 0 ?
         jne       open                     ; nen¡ ‡¡slice "0"
         mov       byte ptr [si],"1"        ; nastaven¡ na ‡¡slici "1"
         jmp       short open               ; test, zda je soubor v adres ©i
open2:   mov       ah,16h                   ; funkce vytvo©en¡ souboru FCB
         mov       dx,offset fcb            ; FCB souboru
         int       21h                      ; vytvo©en¡ souboru
         inc       al                       ; soubor £spˆ¨nˆ otev©en ?
         jz        open3                    ; soubor nevytvo©en
         mov       dx,offset dta            ; nov  adresa DTA
         mov       ah,1ah                   ; funkce nastaven¡ adresy DTA
         int       21h                      ; nastaven¡ nov‚ adresy DTA
         ret                                ; soubor £spˆ¨nˆ otev©en
open3:   mov       si,offset txtvyt         ; text chyby vytvo©en¡ souboru
error:   call      tsktxt                   ; tisk chybov‚ho textu
         cli                                ; z kaz p©eru¨en¡
         mov       sp,word ptr ds:[stackSP]   ; n vrat SP
         mov       ss,word ptr ds:[stackSP+2] ; n vrat SS
         sti                                ; povolen¡ p©eru¨en¡
         int       20h                      ; n vrat z programu


incsoub:                                    ; zv˜¨en¡ jm‚na souboru
                                            ; VSTUP: DS:SI=ukazatel znaku

         dec       si                       ; sn¡‘en¡ ukazatele
         cmp       si,offset soubex-1       ; je ukazatel na zak zan‚ pozici ?
         jne       incsou0                  ; ukazatel nen¡ na zak zan‚ pozici
         dec       si                       ; dal¨¡ sn¡‘en¡ ukazatele
incsou0: mov       al,[si]                  ; znak k zv˜¨en¡
         cmp       al,"0"                   ; je platn  ‡¡slice ?
         cmc                                ; negace CF
         ja        incsou1                  ; je znak men¨¡ ne‘ "0"
         cmp       al,"9"                   ; je platn  ‡¡slice nebo "9" ?
         ja        incsou1                  ; je znak vˆt¨¡ ne‘ "9"
         inc       al                       ; zv˜¨en¡ ‡¡slice
         cmp       al,"9"                   ; z–stala platn  ‡¡slice ?
         je        incsou2                  ; je ‡¡slice "9" - OK
         cmc                                ; negace CF
         ja        incsou2                  ; je platn  ‡¡slice
incsou1: mov       al,"0"                   ; nov  ‡¡slice
incsou2: mov       [si],al                  ; ulo‘en¡ nov‚ho znaku
         ret                                ; CY=je p©enos na vy¨¨¡ ‡¡slici



zapis:                                      ; z pis znaku do v˜stupn¡ho bufferu
                                            ; VSTUP: AL=znak k z pisu

         push      di                       ; £schova DI
         push      ax                       ; £schova AX
         push      bx                       ; £schova BX
         push      dx                       ; £schova DX
         mov       di,offset dta            ; pracovn¡ DTA
         mov       bx,ds:[citdta]           ; ‡¡ta‡ ulo‘en˜ch znak–
         add       di,bx                    ; ukl dac¡ adresa znaku
         mov       [di],al                  ; ulo‘en¡ znaku
         inc       bx                       ; zv˜¨en¡ ‡¡ta‡e znak–
zapis1:  mov       ds:[citdta],bx           ; ulo‘en¡ nov‚ho ‡¡ta‡e znak–
         cmp       bx,128                   ; je buffer zaplnˆn ?
         jae       zapis2                   ; buffer je zaplnˆn
         pop       dx                       ; n vrat DX
         pop       bx                       ; n vrat BX
         pop       ax                       ; n vrat AX
         pop       di                       ; n vrat DI
         ret

zapis2:  mov       ah,15h                   ; funkce sekven‡n¡ho z pisu do soub.
         mov       dx,offset fcb            ; FCB souboru
         int       21h                      ; sekven‡n¡ z pis do souboru
         xor       bx,bx                    ; nulov n¡ ‡¡ta‡e znak–
         or        al,al                    ; z znam £spˆ¨nˆ ulo‘en ?
         jz        zapis1                   ; z pis £spˆ¨nˆ proveden
zapise:  mov       ah,10h                   ; funkce uzav©en¡ souboru
         int       21h                      ; uzav©en¡ souboru
         mov       si,offset txtzap         ; text chyby z pisu do souboru
         jmp       error                    ; chybov‚ hl ¨en¡


close:                                      ; uzav©en¡ v˜stupn¡ho souboru

         push      ax                       ; £schova AX
         push      dx                       ; £schova DX
         mov       al,1ah                   ; znak ^Z (konec souboru)
         mov       cx,128                   ; po‡et znak– k z pisu
close1:  call      zapis                    ; z pis znaku ^Z
         loop      close1                   ; z pis znak– do konce souboru
         mov       dx,offset fcb            ; FCB souboru
         mov       ah,10h                   ; funkce uzav©en¡ souboru
         int       21h                      ; uzav©en¡ souboru
         inc       al                       ; soubor £spˆ¨nˆ uzav©en ?
         jz        close2                   ; soubor nebyl £spˆ¨nˆ uzav©en
         pop       dx                       ; n vrat DX
         pop       ax                       ; n vrat AX
         ret
close2:  mov       si,offset txtuz          ; text chyby uzav©en¡ souboru
         jmp       error                    ; chybov‚ hl ¨en¡



                                            ; zde je FCB souboru

fcb      db        0                        ; diskov  jednotka = aktu ln¡ disk
soubor   db        'INFORM  '               ; jm‚no v˜stupn¡ho souboru
soubex   db        'LST'                    ; extent v˜stupn¡ho souboru
         db        25 dup(0)                ; parametry FCB


stackSP    dd        0                        ; £schova SS:SP


uvtxt    db        'Generovani informaci o pocitaci INFORM V 1.0',13,10,0
txtvyt   db        'Chyba vytvoreni vystupniho souboru !',13,10,0
txtzap   db        'Chyba zapisu do vystupniho souboru !',13,10,0
txtuz    db        'Chyba uzavreni vystupniho souboru !',13,10,0

citdta   dw        0                        ; ‡¡ta‡ ulo‘en˜ch znak–
dta      db        128 dup(0)               ; pracovn¡ adresa DTA




outcr    db        31,0


outuvod  db        ' INFORM - verze 1.0',30,17,'(c) NMS 1990',31,31,31
         db        26,'Z kladn¡ informace o po‡¡ta‡i',31
         db        26,'=============================',31,31
         db        'Typ po‡¡ta‡e ...................... ',0

outpc    db        'PC',0
outxt    db        'XT',0
outpcxt  db        'PC-XT',0
outpcjr  db        'PCjr',0
outat    db        'AT',0
outxt286 db        'XT 286',0
outpccon db        'konvertabiln¡ PC',0
outnezn  db        'nezn m˜ typ',0





         db        0



code     ENDS


         END       start                    ; startovac¡ adresa


; Program pro konverzi souboru DOSMAN.HLP na DOSMAN.TXT

code     SEGMENT
         ASSUME    cs:code,ds:code

delkabuf equ       1024                     ; d‚lka diskov‚ho bufferu

         org       100h

start:
                                          ;* £vodn¡ hl ¨en¡
         mov       dx,offset uvtxt          ; £vodn¡ text
         mov       ah,9                     ; funkce tisku textu
         int       21h                      ; tisk £vodn¡ho textu
                                          ;* otev©en¡ vstupn¡ho souboru
         lea       dx,[soubin]              ; specifikace souboru
         mov       ax,3d00h                 ; otev©en¡ souboru pro ‡ten¡
         int       21h                      ; otev©en¡ souboru
         lea       dx,[txtchyb1]            ; text chyby - nenalezen
         jc        chyba                    ; chyba otev©en¡ souboru
         mov       ds:[zdroj],ax            ; identifik tor zdrojov‚ho souboru
                                          ;* vytvo©en¡ v˜stupn¡ho souboru
         lea       dx,[soubout]             ; specifikace c¡lov‚ho souboru
         xor       cx,cx                    ; atributy - norm ln¡ soubor
         mov       ah,3ch                   ; vytvo©en¡ souboru
         int       21h
         jc        chyba1                   ; je chyba vytvo©en¡ souboru
         mov       [cil],ax                 ; identifik tor c¡lov‚ho souboru
                                          ;* konverze soubor–
         call      konvfile                 ; konverze soubor–
                                          ;* vypr zdnˆn¡ v˜stupn¡ho bufferu
         mov       cx,[outuk]               ; po‡et znak– ve v˜stupn¡m bufferu
         mov       bx,[cil]                 ; c¡lov˜ soubor
         lea       dx,[outbuf]              ; v˜stupn¡ buffer
         mov       ah,40h                   ; funkce z pisu do souboru
         int       21h                      ; z pis zbytku dat do souboru
         jc        chyba1                   ; chyba z pisu
         cmp       ax,cx                    ; souhlas¡ po‡et zapsan˜ch bajt– ?
         jz        navrat                   ; konec programu (je-li z pis OK)
chyba1:  lea       dx,[txtchyb3]            ; nespecifikovan  chyba
chyba:   mov       ah,9
         int       21h                      ; tisk ©etˆzce chybov‚ho hl ¨en¡
navrat:  mov       ah,4ch                   ; ukon‡en¡ programu
         int       21h


readch:                                     ; ‡ten¡ znaku ze vstupn¡ho souboru
         push      bx
         push      cx
         push      dx
         push      si
         mov       si,ds:[inpuk]            ; ukazatel dat p©i ‡ten¡
         cmp       si,ds:[pocinp]           ; dosa‘eno konce dat ?
         jb        readch2                  ; nen¡ je¨tˆ konec bufferu
                                          ;* na‡ten¡ dal¨¡ho bloku dat
         lea       dx,[inpbuf]              ; vstupn¡ buffer
         mov       bx,[zdroj]               ; zdrojov˜ soubor
         mov       cx,delkabuf              ; po‡et ‡ten˜ch bajt–
         mov       ah,3fh                   ; funkce ‡ten¡ ze souboru
         int       21h                      ; ‡ten¡ ze souboru
         jc        chyba1                   ; chyba souboru
         mov       [pocinp],ax              ; po‡et p©e‡ten˜ch vstupn¡ch znak–
         or        ax,ax
         stc
         jz        readche                  ; nen¡ ‘ dn˜ dal¨¡ znak
         xor       si,si
         mov       ds:[inpuk],si            ; nulov n¡ ukazatel pro ‡ten¡
                                          ;* v pamˆti jsou data - ‡ten¡ bajtu
readch2: mov       al,ds:[inpbuf+si]        ; znak ze vstupn¡ho souboru
         inc       si                       ; zv˜¨en¡ ukazatele pro ‡ten¡
         mov       ds:[inpuk],si            ; nov˜ ukazatel
         clc                                ; p©¡znak - operace OK
readche: pop       si
         pop       dx
         pop       cx
         pop       bx
         ret

writech:                                    ; z pis znaku do souboru
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         mov       si,ds:[outuk]            ; ukazatel vstupn¡ho souboru
         mov       ds:[si+outbuf],al        ; znak do v˜stupn¡ho souboru
         inc       si                       ; zv˜¨en¡ ukazatele pro z pis
         cmp       si,delkabuf              ; p©ekro‡en konec ?
         cmc
         jnc       writche                  ; nen¡ je¨tˆ zaplnˆn buffer
         mov       ah,40h                   ; funkce z pisu do souboru
         mov       bx,ds:[cil]              ; c¡lov˜ soubor
         lea       dx,[outbuf]              ; v˜stupn¡ buffer
         mov       cx,delkabuf              ; po‡et bajt– pro z pis
         int       21h
         jc        chyba1                   ; chyba z pisu dat
         cmp       ax,cx                    ; po‡et zapsan˜ch bajt–
         jnz       chyba1                   ; nesouhlas¡ po‡et zapsan˜ch bajt–
         mov       si,0                     ; ukazatel na za‡ tek
writche: mov       ds:[outuk],si            ; nov  hodnota ukazatele z pisu
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret



konvfile:                                 ;* konverze souboru
         call      readch                   ; vstup znaku
         jc        konvf9                   ; nen¡ platn˜ znak
konvf0:  or        al,al
         jz        konvf9                   ; konec souboru
         mov       cx,1                     ; po‡et z pis– = 1
                                          ;* z pis speci ln¡ho k¢du
         cmp       al,1fh                   ; je speci ln¡ k¢d ?
         jne       konvf1                   ; nen¡ speci ln¡ k¢d
         mov       al,"%"                   ; n hradn¡ znak "%"
         jmp       short konvf7             ; z pis n hradn¡ho znaku "%"
konvf1:                                   ;* n hrada znaku "%"
         cmp       al,"%"                   ; je znak "%" ?
         jne       konvf2                   ; nen¡ znak "%"
         inc       cx                       ; po‡et z pis– = 2
         jmp       short konvf7             ; z pis znak– "%%"
konvf2:                                   ;* z pis CR-LF
         cmp       al,1eh                   ; je konec © dku EOL ?
         jne       konvf3                   ; nen¡ EOL
         mov       al,13
         call      writech                  ; z pis znaku CR
         mov       al,10
         jmp       short konvf7             ; z pis znaku LF
konvf3:                                   ;* z pis platn‚ho znaku
         cmp       al,32                    ; je platn˜ znak ASCII ?
         jae       konvf7                   ; z pis znaku
                                          ;* z pis mezer
         cmp       al,1                     ; je zvl ¨tn¡ identifik tor ?
         mov       cl,al                    ; po‡et mezer
         mov       al," "                   ; n hradn¡ mezera
         ja        konvf7                   ; je tabel tor
                                          ;* z pis opakova‡e
         call      readch                   ; ‡ten¡ po‡tu opakov n¡
         jc        konvf9                   ; nen¡ ji‘ dal¨¡ znak
         cmp       al,32                    ; je men¨¡ znak ne‘ 32 ?
         jb        konvf0                   ; je men¨¡ znak ne‘ 32
         sub       al,32                    ; v˜po‡et po‡tu opakov n¡
         mov       cl,al                    ; po‡et opakov n¡
         call      readch                   ; ‡ten¡ znaku k opakov n¡
         jc        konvf9                   ; nen¡ ji‘ dal¨¡ znak
                                          ;* kontrola, zda je spec. ©¡d. znak
         or        cx,cx                    ; je po‡et = 0 ?
         jne       konvf7                   ; nen¡ = 0
         inc       cx                       ; po‡et = 1
         sub       al,"@"                   ; korekce na ©¡dic¡ znak
konvf7:  call      writech                  ; z pis znaku
         loop      konvf7                   ; z pis dal¨¡ho znaku
         jmp       short konvfile           ; vstup dal¨¡ho znaku

konvf9:  ret


soubin   db        'DOSMAN.HLP',0             ; vstupn¡ soubor
soubout  db        'DOSMAN.TXT',0             ; v˜stupn¡ soubor

uvtxt    db        "KONVTXT - konverze DOSMAN.HLP na DOSMAN.TXT",13,10,"$"
txtchyb1 db        "Soubor DOSMAN.HLP nenalezen !",13,10,10,"$"
txtchyb3 db        "Chyba p©i p©evodu soubor– !",13,10,"$"

zdroj    dw        0                        ; identifik tor zdrojov‚ho souboru
cil      dw        0                        ; identifik tor c¡lov‚ho souboru

pocinp   dw        0                        ; po‡et znak– v bufferu
inpuk    dw        0                        ; ukazatel p©i ‡ten¡ z bufferu
outuk    dw        0                        ; ukazatel v˜stupn¡ho bufferu

inpbuf   label     byte                     ; vstupn¡ buffer
outbuf   equ       inpbuf+delkabuf          ; v˜stupn¡ buffer

code     ENDS

         END       start               ; startovac¡ adresa

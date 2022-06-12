
; Program pro konverzi souboru DOSMAN.TXT na DOSMAN.HLP

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
         xor       dx,dx                    ; DL=‡¡ta‡ stejn˜ch znak–

konvf1:  call      readch                   ; ‡ten¡ dal¨¡ho znaku
         jnc       konvf2                   ; je dal¨¡ znak
         xor       al,al                    ; ukon‡ovac¡ bajt 00
         call      writech                  ; z pis ukon‡en¡ souboru
         ret
konvf2:                                   ;* nahrazen¡ znaku CR
         cmp       al,0dh
         jne       konvf3                   ; nen¡ konec © dku CR-LF
         and       byte ptr ds:[param],not 1; zru¨en¡ p©¡znaku v˜razn‚ho textu
         mov       al,1eh                   ; n hradn¡ znak EOL
         jmp       short konvf4             ; ulo‘en¡ znaku EOL do bufferu
konvf3:                                   ;* z pis znak– < 32
         cmp       al,10                    ; je znak LF ?
         je        konvf1                   ; je LF - ignorov n¡
         cmp       al,4                     ; je v˜razn‚ p¡smo ?
         jne       konvf39                  ; nen¡ v˜razn‚ p¡smo

         call      vyraz                    ; zv˜raznˆn˜ text
         jmp       short konvf1


konvf39: cmp       al,32
         jb        konvf6                   ; je ©¡dic¡ znak
                                          ;* z pis spec. znaku "%"
         cmp       al,"%"                   ; je spec. znak "%" ?
         jne       konvf7                   ; nen¡ spec. znak "%"
         call      flushk                   ; vypr zdnˆn¡ bufferu
         call      readch                   ; ‡ten¡ dal¨¡ho znaku
         cmp       al,"%"                   ; je platn˜ znak "%" ?
         je        konvf5                   ; z pis znaku "%"
         push      ax
         mov       al,1fh                   ; identifik tor spec. povelu
         call      writech                  ; z pis identifik toru
         pop       ax
         jmp       short konvf2             ; dal¨¡ znak

konvf7:                                   ;* kontrola po‡tu opakov n¡
         cmp       al,dh                    ; je stejn˜ znak ?
         jne       konvf4                   ; nen¡ stejn˜ znak
         cmp       dl,127-32                ; je ji‘ dosa‘eno max. po‡tu dat ?
         jae       konvf4                   ; ‡¡ta‡ je ji‘ zaplnˆn
         inc       dl                       ; zv˜¨en¡ ‡¡ta‡e znak–
         jmp       short konvf1             ; vstup dal¨¡ho znaku
konvf4:                                   ;* ulo‘en¡ nov‚ho znaku
         call      flushk                   ; vypr zdnˆn¡ bufferu
konvf5:  mov       dh,al                    ; £schova znaku
         mov       dl,1                     ; nastaven¡ ‡¡ta‡e znak– na 1
         jmp       short konvf1             ; vstup dal¨¡ho znaku
konvf6:                                   ;* z pis ©¡dic¡ho znaku
         push      ax
         call      flushk                   ; vypr zdnˆn¡ bufferu
         mov       al,1                     ; speci ln¡ povel
         call      writech                  ; z pis spec. povelu
         mov       al," "                   ; identifik tor ©¡dic¡ho znaku
         call      writech                  ; z pis identifik toru
         pop       ax
         add       al,"@"                   ; konverze na znak ASCII
         call      writech                  ; z pis dal¨¡ho znaku
         jmp       short konvf1             ; dal¨¡ znak


vyraz:                                    ;* zv˜raznˆn˜ text
         xor       byte ptr ds:[param],1    ; zmˆna p©¡znaku zv˜raznˆn‚ho textu
         call      flushk                   ; vypr zdnˆn¡ bufferu
         mov       al,1fh                   ; identifik tor spec. povelu
         call      writech                  ; z pis identifik toru
         mov       al,"N"                   ; norm ln¡
         test      byte ptr ds:[param],1    ; je zv˜raznˆn˜ text ?
         jz        vyraz3                   ; nen¡ zv˜raznˆn˜ text
         mov       al,"Y"
         call      writech
         mov       al,"E"
vyraz3:  call      writech
         ret


flushk:                                   ;* vypr zdnˆn¡ bufferu opakov n¡
         push      ax
         cmp       dl,1
         jb        flushk8                  ; nen¡ ‘ dn˜ znak
         je        flushk6                  ; je pouze jeden znak - z pis
                                          ;* opakov n¡ mezery
         cmp       dh," "                   ; je mezera ?
         jne       flushk4                  ; nen¡ mezera
         mov       al,dl                    ; po‡et mezer
         cmp       dl,1dh                   ; je vˆt¨¡ po‡et ne‘ 1dh ?
         jbe       flushk7                  ; z pis identifik toru mezer
flushk4:                                  ;* opakov n¡ znaku
         mov       al,dh                    ; znak k z pisu
         cmp       dl,3                     ; jsou 2 znaky ?
         jb        flushk5                  ; jsou 2 znaky - jejich z pis
         ja        flushk2                  ; je v¡ce znak– ne‘ 3
         call      writech                  ; z pis 2. znaku
         jmp       short flushk5            ; z pis 3. znaku
flushk2: mov       al,1                     ; identifik tor opakov n¡
         call      writech                  ; z pis identifik toru opakov n¡
         mov       al,dl                    ; po‡et opakov n¡ znaku
         add       al,32                    ; po‡et opakov n¡
flushk5: call      writech                  ; z pis znaku nebo po‡tu opakov n¡
flushk6: mov       al,dh                    ; znak k opakov n¡
flushk7: call      writech                  ; z pis opakovan‚ho znaku
flushk8: xor       dx,dx                    ; vynulov n¡ ‡¡ta‡e opakov n¡
         pop       ax
         ret

soubin   db        'DOSMAN.TXT',0             ; vstupn¡ soubor
soubout  db        'DOSMAN.HLP',0             ; v˜stupn¡ soubor

uvtxt    db        "KONVHLP - konverze DOSMAN.TXT na DOSMAN.HLP",13,10,"$"
txtchyb1 db        "Soubor DOSMAN.TXT nenalezen !",13,10,10,"$"
txtchyb3 db        "Chyba p©i p©evodu soubor– !",13,10,"$"

param    db        0                        ; p©¡znaky
                                            ; bit 0: 1=je zv˜raznˆn‚ p¡smo

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
COMMENT %
                   Zobrazen¡ souboru ve form tu displeje
        %

;------------------------------------------------------------------------------
;                             Programov˜ segment
;------------------------------------------------------------------------------

code     SEGMENT   page
         ASSUME    cs:code,ds:code

         ORG       100h

start:

         mov       ah,0fh                   ; funkce dotazu na videom¢d
         int       10h                      ; dotaz na aktu ln¡ videom¢d
         mov       ds:[aktmod],al           ; aktu ln¡ videom¢d

         mov       al,ds:[stranka]          ; aktivn¡ str nka displeje
         mov       ah,5                     ; funkce nastaven¡ str nky displeje
         int       10h                      ; nastaven¡ aktivn¡ str nky displeje

         cli                                ; z kaz p©eru¨en¡
         mov       ax,cs                    ; segment programu
         mov       ss,ax                    ; segment programu
         mov       sp,offset stack          ; vlastn¡ z sobn¡k
         sti                                ; povolen¡ p©eru¨en¡

         mov       bx,offset konec          ; adresa konce p©idˆlen‚ pamˆti
         shr       bx,1                     ; BX / 2
         shr       bx,1                     ; BX / 4
         shr       bx,1                     ; BX / 8
         shr       bx,1                     ; BX / 16 - d‚lka programu
         inc       bx                       ; zaokrouhlen¡ d‚lky pamˆti
         mov       ah,4ah                   ; funkce modifikace pamˆti
         int       21h                      ; modifikace pamˆti
         jc        start7                   ; chyba p©idˆlen¡ pamˆti

         mov       bx,0fffh                 ; po‘adavek na p©idˆlen¡ 64 KB RAM
         mov       ah,48h                   ; po‘adavek na p©idˆlen¡ pamˆti
         int       21h                      ; p©idˆlen¡ pamˆti
         jnc       start5                   ; pamˆŸ p©idˆlena OK
         mov       ah,48h
         int       21h                      ; p©idˆlen¡ skute‡nˆ voln‚ pamˆti
         jc        start7
start5:  mov       ds:[segbuff],ax          ; segment bufferu
         add       bx,bx                    ; BX * 2
         add       bx,bx                    ; BX * 4
         add       bx,bx                    ; BX * 8
         add       bx,bx                    ; BX * 16
         mov       ds:[delbuff],bx          ; d‚lka bufferu
         or        bx,bx                    ; je alespo¤ nˆjak˜ buffer ?
         jnz       start6                   ; buffer OK

start7:  mov       dx,offset err2           ; chybov‚ hl ¨en¡
         mov       ah,9
         int       21h                      ; tisk chybov‚ho hl ¨en¡
         mov       ax,4c03h
         int       21h                      ; ukon‡en¡ programu s chybou

start6:  mov       si,81h                   ; p©¡kazov˜ © dek
         mov       di,offset jmeno          ; jm‚na soubor– k zobrazen¡
         xor       cx,cx                    ; cx <- 0000
         mov       cl,ds:[80h]              ; po‡et zadan˜ch znak–
         jcxz      strt8                    ; nen¡ zad n ‘ dn˜ parametr
strt1:   lodsb                              ; znak zad n¡
         cmp       al,20h                   ; je mezera nebo ©¡dic¡ znak ?
         ja        strt3                    ; je platn˜ znak - p©enos
strt2:   loop      strt1                    ; vypustˆn¡ dal¨¡ho znaku
         jmp       short strt5              ; nen¡ zad n ‘ dn˜ dal¨¡ soubor
strt3:   stosb                              ; ulo‘en¡ platn‚ho znaku
         lodsb                              ; na‡ten¡ dal¨¡ho znaku
         cmp       al,20h                   ; je platn˜ znak ?
         ja        strt4                    ; je platn˜ znak - ulo‘en¡
         xor       al,al
         stosb                              ; koncov˜ znak jm‚na
         inc       byte ptr ds:[pocetjm]
         jmp       short strt1              ; p©enos dal¨¡ho jm‚na
strt4:   loop      strt3                    ; p©enos dal¨¡ho znaku
         xor       al,al
         stosb                              ; ulo‘en¡ koncov‚ 0
         inc       byte ptr ds:[pocetjm]
strt5:
         cmp       byte ptr ds:[jmeno],0    ; je nˆjak˜ soubor ?
         je        strt8                    ; nen¡ zad n ‘ dn˜ soubor
         mov       ax,offset jmeno          ; zadan  jm‚na
         mov       ds:[adrpar],ax           ; ukazatel zadan˜ch jmen

start1:  mov       si,ds:[adrpar]           ; ukazatel zadan˜ch jmen
         cmp       byte ptr ds:[si],0       ; je je¨tˆ nˆjak‚ jm‚no ?
         jne       start2                   ; je nˆjak‚ jm‚no
         mov       si,offset jmeno          ; opˆt za‡ tek soubor–
start2:  mov       dx,si                    ; adresa po‘adovan‚ho souboru
start3:  inc       si
         cmp       byte ptr ds:[si],0       ; je ji‘ konec jm‚na ?
         jnz       start3                   ; nalezen¡ konce jm‚na
         inc       si                       ; za‡ tek jm‚na dal¨¡ho souboru
         mov       ds:[adrpar],si           ; nov  adresa parametru

         mov       ah,3dh                   ; otev©en¡ souboru
         mov       al,0                     ; otev©en¡ pro ‡ten¡
         int       21h                      ; otev©en¡ souboru
         jnc       soubje                   ; soubor otev©en OK
strt9:
         mov       dx,offset err1           ; chyba otev©en¡ souboru
         mov       ah,9                     ; funkce tisku textu
         int       21h                      ; tisk chybov‚ho textu
         mov       al,2                     ; ukon‡en¡ programu s chybou

navrat:  push      ax                       ; £schova n vratov‚ho k¢du
         mov       ax,cs:[segbuff]          ; segment bufferu dat
         mov       es,ax                    ; segment bufferu dat
         mov       ah,49h                   ; funkce uvolnˆn¡ pamˆti
         int       21h                      ; uvolnˆn¡ p©idˆlen‚ pamˆti
         pop       ax
         mov       ah,4ch                   ; funkce n vratu
         int       21h                      ; ukon‡en¡ programu

strt8:   mov       dx,offset uvtxt          ; £vodn¡ text
         mov       ah,9                     ; funkce tisku textu
         int       21h                      ; tisk £vodn¡ho textu
         mov       al,1                     ; ukon‡en¡ programu s chybou
         jmp       short navrat

soubje:
         mov       ds:[idents],ax           ; identifik tor souboru
         mov       byte ptr ds:[citbyte],0  ; nulov n¡ ‡¡ta‡e bajt–
         mov       byte ptr ds:[pareq],0    ; parametr - je norm ln¡ stav
         mov       byte ptr ds:[parnext],0
         mov       word ptr ds:[pocbyte],0  ; nastaven¡ po‡tu p©e‡ten˜ch bajt–
         mov       word ptr ds:[adrbyte],0  ; vynulov n¡ bufferu
         mov       di,offset ident          ; adresa hlavi‡ky souboru
         mov       cx,konhl - ident         ; d‚lka hlavi‡ky souboru

         cmp       byte ptr ds:[pocetjm],2
         jne       soubj2
         cmp       byte ptr ds:[pocetsc],2
         je        soub5x

soubj2:  call      readb                    ; ‡ten¡ bajtu ze souboru
         jnc       soubj5                   ; ‡ten¡ souboru OK
soubj6:  jmp       strt9                    ; chyba ‡ten¡ souboru
soubj5:  stosb                              ; ulo‘en¡ bajtu
         loop      soubj2                   ; ‡ten¡ dal¨¡ho bajtu

         inc       byte ptr ds:[pocetsc]
soub5x:
         cmp       word ptr [ident],'CS'    ; prvn¡ dva znaky identifikace
         jne       soubj6                   ; nen¡ spr vn˜ form t souboru
         cmp       byte ptr [ident+2],'R'   ; t©et¡ znak identifikace
         jne       soubj6                   ; nen¡ spr vn˜ form t souboru
         cmp       byte ptr [mod],16        ; kontrola max. ‡¡sla videom¢du
         jna       soub1                    ; nen¡ p©ekro‡en videom¢d
         mov       byte ptr [mod],3         ; n hradn¡ videom¢d
         mov       word ptr [sirka],80      ; n hradn¡ ¨¡©ka
         mov       word ptr [vyska],25      ; n hradn¡ v˜¨ka
soub1:
                                           ;* obsluha p©epnut¡ displeje
         mov       ah,0fh                   ; funkce dotazu na videom¢d
         int       10h                      ; dotaz na aktu ln¡ videom¢d
         cmp       ds:[mod],al              ; aktu ln¡ videom¢d = po‘adovan˜ ?
         je        soubj4                   ; nen¡ zmˆna videom¢du
         cmp       byte ptr ds:[parscr],0   ; je obr zek v pamˆti ?
         je        soubj7                   ; v pamˆti nen¡ obr zek

         mov       cx,2000
soubj8x: mov       ah,1
         int       16h
         jnz       soubj8y
         loop      soubj8x
         mov       al," "
         jmp       short soubj8z
soubj8y: xor       ax,ax
         int       16h                      ; ‡ek n¡ na stisk libovoln‚ kl vesy
soubj8z: cmp       al,20h                   ; je mezera ?
         je        soubj8
         jmp       soubend2                 ; konec programu
soubj8:  dec       byte ptr ds:[parscr]     ; sn¡‘en¡ po‡tu obr zk– v pamˆti
         mov       al,ds:[stranka]          ; aktivn¡ str nka displeje
         xor       al,1
         mov       ds:[stranka],al          ; zmˆna str nky
         mov       ah,5                     ; funkce nastaven¡ str nky displeje
         int       10h                      ; nastaven¡ aktivn¡ str nky displeje
soubj7:  mov       ah,0                     ; funkce nastaven¡ videom¢du
         mov       al,ds:[mod]              ; videom¢d
         int       10h                      ; nastaven¡ videom¢du
         mov       byte ptr ds:[pocetsc],0
         mov       byte ptr ds:[parscr],0   ; p©¡znak - v pamˆti nen¡ obr zek
         mov       byte ptr ds:[stranka],0  ; aktivn¡ str nka 0
soubj4:  mov       al,ds:[stranka]          ; aktivn¡ str nka displeje
         xor       al,1                     ; nastaven¡ opa‡n‚ str nky displeje
         mov       ah,5                     ; funkce nastaven¡ str nky displeje
         int       10h                      ; nastaven¡ aktivn¡ str nky displeje
         mov       ax,0                     ; segment 0
         mov       ds,ax                    ; segment 0
         mov       ax,ds:[44eh]             ; po‡ te‡n¡ adresa displeje
         push      cs
         pop       ds                       ; DS <- CS
         mov       [adrvideo],ax            ; po‡ te‡n¡ adresa displeje
         mov       al,ds:[stranka]          ; aktivn¡ str nka displeje
         mov       ah,5                     ; funkce nastaven¡ str nky displeje
         int       10h                      ; nastaven¡ aktivn¡ str nky displeje

         mov       si,offset tabdim         ; tabulka rozmˆr– displeje
         xor       bh,bh                    ; BH <- 00
         mov       bl,ds:[mod]              ; videom¢d
         cmp       bl,16                    ; kontrola max. ‡¡sla videom¢du
         jna       open20                   ; je zn m˜ videom¢d
         mov       bl,3                     ; je nezn m˜ videom¢d
open20:  add       bx,bx                    ; BX * 2
         add       bx,bx                    ; BX * 4
         add       si,bx                    ; adresa videom¢du
         lodsw                              ; horizont ln¡ rozmˆr
         mov       [maxsir],ax              ; maxim ln¡ ¨¡©ka © dku
         lodsw                              ; vertik ln¡ rozmˆr
         mov       [maxvys],ax              ; maxim ln¡ v˜¨ka displeje

         cmp       byte ptr ds:[pocetjm],2
         jne       open20x
         cmp       byte ptr ds:[pocetsc],2
         jne       open20x
         jmp       soubend

open20x:
         mov       al,ds:[mod]              ; videom¢d
         cmp       al,3                     ; je textov˜ m¢d ?
         ja        soub2                    ; nen¡ textov˜ m¢d
                                           ;* ‡ten¡ standardn¡ho textov‚ho m¢du
         push      es
         mov       ax,0b800h
         mov       es,ax                    ; segment videopamˆti
         mov       di,cs:[adrvideo]         ; po‡ te‡n¡ adresa obrazu
         call      readt                    ; ‡ten¡ textov‚ obrazovky
         pop       es
         mov       ah,2                     ; nastaven¡ pozice kurzoru
         mov       bh,0                     ; str nka displeje
         mov       dl,byte ptr ds:[maxsir]  ; koncov  pozice kurzoru
         mov       dh,byte ptr ds:[maxvys]  ; koncov˜ © dek kurzoru
         int       10h                      ; nastaven¡ kurzoru za displej
         jmp       soubend                  ; konec ‡ten¡ ze souboru

soub2:
         cmp       al,14                    ; je videom¢d 640x200/16 ?
         je        soub22
         cmp       al,16                    ; je videom¢d 640x350/16 ?
         je        soub22
         cmp       al,13                    ; je videom¢d 320x200/16 ?
         jne       soub4

soub22:  push      es
         mov       di,cs:[adrvideo]         ; po‡ te‡n¡ adresa obrazu
         mov       ax,0a000h
         mov       es,ax
         mov       ah,1
         xor       bx,bx
         call      readmap
         jc        soub9                    ; chyba ‡ten¡ dat
         mov       ah,2
         mov       bx,1
         call      readmap
         jc        soub9                    ; chyba ‡ten¡ dat
         mov       ah,4
         mov       bx,2
         call      readmap
         jc        soub9                    ; chyba ‡ten¡ dat
         mov       ah,8
         mov       bx,3
         call      readmap
         jmp       soub9

soub4:

soub9:   pop       es

soubend:
         mov       ah,3eh
         mov       bx,ds:[idents]
         int       21h
         inc       byte ptr ds:[parscr]     ; zv˜¨en¡ po‡tu ulo‘en˜ch obr zk–

soube21:
         cmp       byte ptr ds:[parscr],2   ; je v pamˆti obr zek ?
         jb        soube24                  ; je max. jeden obr zek
         mov       cx,2000
soubj9x: mov       ah,1
         int       16h
         jnz       soubj9z
         loop      soubj9x
         mov       al," "
         jmp       short soubj9y
soubj9z:
         xor       ax,ax
         int       16h                      ; ‡ek n¡ na stisk libovoln‚ kl vesy
soubj9y: dec       byte ptr ds:[parscr]     ; sn¡‘en¡ po‡tu obr zk– v pamˆti


         cmp       al,20h                   ; je mezera ?
         jne       soubend2                 ; nen¡ mezera
soube24:
         push      ax
         mov       al,ds:[stranka]          ; aktivn¡ str nka displeje
         xor       al,1
         mov       ds:[stranka],al          ; zmˆna str nky
         mov       ah,5                     ; funkce nastaven¡ str nky displeje
         int       10h                      ; nastaven¡ aktivn¡ str nky displeje
         pop       ax
         jmp       start1                   ; pokra‡ov n¡ v zobrazov n¡
soubend2:mov       ah,0
         mov       al,ds:[aktmod]           ; aktu ln¡ videom¢d
         int       10h                      ; nastaven¡ p–vodn¡ho videom¢du
         mov       al,0
         jmp       navrat                   ; ukon‡en¡ programu


readmap:
         mov       dx,03c4h
         mov       al,2
         out       dx,al
         inc       dx
         mov       al,ah
         out       dx,al

         mov       dx,03ceh
         mov       al,4
         out       dx,al
         inc       dx
         mov       al,bl
         out       dx,al

         call      readg                    ; ‡ten¡ grafick‚ obrazovky
         ret


readt:                                      ; ‡ten¡ textov‚ obrazovky
                                            ; VSTUP: ES:DI=adresa obrazu
         push      cx
         push      di
         mov       cx,cs:[vyska]            ; po‡et linek k z pisu
readt1:  push      di                       ; £schova DI - ukazatel dat
         push      cx                       ; £schova ‡¡ta‡e linek
         mov       cx,cs:[sirka]            ; po‡et bajt– na © dek
readt2:  call      readk                    ; ‡ten¡ bajtu ze souboru
         jc        readg3                   ; chyba ‡ten¡ ze souboru
         stosb                              ; ulo‘en¡ bajtu
         inc       di                       ; zv˜¨en¡ adresy o atribut
         loop      readt2                   ; ‡ten¡ dal¨¡ho bajtu
         pop       cx                       ; n vrat ‡¡ta‡e linek
         pop       di                       ; n vrat ukazatele dat DI
         add       di,cs:[maxsir]           ; adresa dal¨¡ linky
         add       di,cs:[maxsir]           ; dal¨¡ linka
         loop      readt1                   ; ‡ten¡ dal¨¡ linky
         pop       di                       ; adresa obrazovky
         push      di
         inc       di                       ; po‡ te‡n¡ adresa + 1
         mov       cx,cs:[vyska]            ; po‡et linek k z pisu
readt3:  push      di                       ; £schova SI - ukazatel dat
         push      cx                       ; £schova ‡¡ta‡e linek
         mov       cx,cs:[sirka]            ; po‡et bajt– na © dek
readt4:  call      readk                    ; ‡ten¡ bajtu ze souboru
         jc        readg3                   ; chyba ‡ten¡ ze souboru
         stosb                              ; ulo‘en¡ bajtu
         inc       di                       ; zv˜¨en¡ adresy o atribut
         loop      readt4                   ; ‡ten¡ dal¨¡ho bajtu
         pop       cx                       ; n vrat ‡¡ta‡e linek
         pop       di                       ; n vrat ukazatele dat SI
         add       di,cs:[maxsir]           ; adresa dal¨¡ linky
         add       di,cs:[maxsir]           ; dal¨¡ linka
         loop      readt3                   ; ‡ten¡ dal¨¡ linky
         clc
         pop       di
         pop       cx
         ret


readg3:  pop       cx
         pop       di
         pop       di
         pop       cx
         ret

readg:                                      ; ‡ten¡ obrazovky v grafick‚m m¢du
                                            ; VSTUP: ES:DI=adresa obrazu
         push      cx
         push      di
         mov       cx,cs:[vyska]            ; po‡et linek ke ‡ten¡
readg1:  push      di                       ; £schova DI - ukazatel dat
         push      cx                       ; £schova ‡¡ta‡e linek
         mov       cx,cs:[sirka]            ; po‡et bajt– na © dek
readg2:  call      readk                    ; ‡ten¡ bajtu ze souboru
         jc        readg3                   ; chyba ‡ten¡ ze souboru
         stosb                              ; ulo‘en¡ bajtu
         loop      readg2                   ; dal¨¡ bajt ke ‡ten¡
         pop       cx                       ; n vrat ‡¡ta‡e linek
         pop       di                       ; n vrat ukazatele dat DI
         add       di,cs:[maxsir]           ; adresa dal¨¡ linky
         loop      readg1                   ; ‡ten¡ dal¨¡ linky
         clc
         pop       di
         pop       cx
         ret

readk:                                      ; ‡ten¡ bajtu v kompresn¡m m¢du
                                            ; VSTUP: AL=bajt (pokud CN)
                                            ;         CY=nejsou dal¨¡ data

         test      byte ptr cs:[verze],1    ; je kompresn¡ m¢d ?
         jnz       readk1                   ; je kompresn¡ m¢d
         jmp       readb                    ; z pis bajtu bez komprese
readk1:
         push      ds
         push      cs
         pop       ds
         cmp       byte ptr ds:[citbyte],0  ; je je¨tˆ p©ipraven nˆjak˜ bajt ?
         jne       readk4                   ; je je¨tˆ nˆjak˜ bajt
                                           ;* na‡ten¡ dal¨¡ definice komprese
readk2:  mov       al,ds:[parnext]
         mov       ds:[pareq],al
         call      readb                    ; ‡ten¡ identifik toru komprese
         jc        readk6                   ; nejsou dal¨¡ data
         cmp       al,255                   ; je m¢d bez p©epnut¡ ?
         je        readk3                   ; nen¡ p©epnut¡ m¢du
         xor       byte ptr ds:[parnext],1  ; zmˆna n sleduj¡c¡ho stavu
readk3:  or        al,al                    ; je nˆjak˜ bajt ?
         jz        readk2                   ; nen¡ ‘ dn˜ bajt - dal¨¡
         mov       ds:[citbyte],al          ; ‡¡ta‡ bajt–
         cmp       byte ptr ds:[pareq],0    ; je komprese ?
         je        readk4                   ; nen¡ komprese
         call      readb                    ; ‡ten¡ bajtu k opakov n¡
         jc        readk6                   ; nejsou dal¨¡ data
         mov       ds:[byteeq],al           ; bajt k opakov n¡
                                           ;* ‡ten¡ bajtu
readk4:  cmp       byte ptr ds:[pareq],0    ; je stav komprese ?
         mov       al,ds:[byteeq]           ; kompresovan˜ bajt
         jne       readk5                   ; je komprese
         call      readb                    ; ‡ten¡ datov‚ho bajtu
         jc        readk6                   ; chyba ‡ten¡
readk5:  dec       byte ptr ds:[citbyte]    ; sn¡‘en¡ ‡¡ta‡e bajt–
         clc
readk6:  pop       ds
         ret

citbyte  db        0                        ; ‡¡ta‡ bajt–
byteeq   db        0                        ; kompresovan˜ bajt
pareq    db        0                        ; parametr: 1=je stav komprese
parnext  db        0                        ; n sleduj¡c¡ stav


readb:                                      ; z pis bajtu do souboru
                                            ; VSTUP: AL=bajt (pokud CN)
                                            ;         CY=nejsou dal¨¡ data

         push      si                       ; £schova SI
         push      ds                       ; £schova DS
         cmp       word ptr ds:[pocbyte],0  ; jsou nˆjak  data v bufferu ?
         mov       ds,ds:[segbuff]          ; segment bufferu
         jne       readb1                   ; jsou dal¨¡ data
                                           ;* na‡ten¡ dat do bufferu
         push      bx
         push      cx
         push      dx
         mov       bx,cs:[idents]           ; identifik tor souboru
         mov       cx,cs:[delbuff]          ; d‚lka datov‚ho bufferu
         mov       dx,0                     ; po‡ te‡n¡ adresa bufferu
         mov       ah,3fh                   ; funkce ‡ten¡ ze souboru
         int       21h                      ; na‡ten¡ dat z bufferu
         pop       dx
         pop       cx
         pop       bx
         jc        readb2                   ; chyba ‡ten¡
         mov       word ptr cs:[pocbyte],ax ; nastaven¡ po‡tu p©e‡ten˜ch bajt–
         mov       word ptr cs:[adrbyte],0  ; vynulov n¡ bufferu
         or        ax,ax                    ; jsou na‡tena nˆjak  data ?
         stc                                ; p©¡znak chyby - nejsou dal¨¡ data
         jz        readb2                   ; nejsou dal¨¡ data
                                           ;* p©e‡ten¡ bajtu z bufferu
readb1:  mov       si,cs:[adrbyte]          ; adresa ke ‡ten¡ bajtu (offset)
         lodsb                              ; na‡ten¡ dal¨¡ho bajtu dat
         inc       word ptr cs:[adrbyte]    ; zv˜¨en¡ ‡tec¡ adresy bajtu
         dec       word ptr cs:[pocbyte]    ; sn¡‘en¡ po‡tu ulo‘en˜ch bajt–
         clc                                ; p©¡znak - ‡ten¡ OK
readb2:  pop       ds
         pop       si
         ret


adrbyte  dw        0                        ; adresa ke ‡ten¡ bajtu (offset)
segbuff  dw        0                        ; adresa datov‚ho bufferu (segment)
pocbyte  dw        0                        ; po‡et zbyl˜ch bajt– v sektoru
delbuff  dw        0                        ; d‚lka datov‚ho bufferu

idents   dw        0                        ; identifikace souboru

ident    db        'SCR'                    ; identifikace souboru displeje
verze    db        0                        ; verze souboru
                                            ;  bit 0: 1=je kompresn¡ m¢d
mod      db        0                        ; aktu ln¡ videom¢d displeje
sirka    dw        40                       ; ¨¡©ka © dku displeje (bajt–)
vyska    dw        200                      ; v˜¨ka displeje (linek)
konhl:                                      ; konec z hlav¡ souboru

adrvideo dw        0                        ; po‡ te‡n¡ adresa zobrazen‚ str nky
maxsir   dw        0                        ; maxim ln¡ ¨¡©ka © dku
maxvys   dw        0                        ; maxim ln¡ v˜¨ka © dku

stranka  db        0                        ; aktivn¡ str nka displeje
parscr   db        0                        ; po‡et obr zk– v pamˆti

adrpar   dw        0                        ; adresa ukazatele p©¡kazu

tabdim:                                     ; tabulka rozmˆr– videom¢d–
         dw        40,25                    ; 0 = text 40x25/16 (B800h)
         dw        40,25                    ; 1 = text 40x25/16,8 (B800h)
         dw        80,25                    ; 2 = text 80x25/16 (B800h)
         dw        80,25                    ; 3 = text 80x25/16,8 (B800h)
         dw        40,200                   ; 4 = grafika 320x200/4 (B800h)
         dw        40,200                   ; 5 = grafika 320x200/4 (B800h)
         dw        80,200                   ; 6 = grafika 640x200/2 (B800h)
         dw        80,25                    ; 7 = text 80x25/2 (B000h)
         dw        20,200                   ; 8 = grafika 160x200/16 (B000h)
         dw        40,200                   ; 9 = grafika 320x200/16 (B000h)
         dw        80,200                   ; 10 = grafika 640x200/4 (B000h)
         dw        80,25                    ; 11 = rezervov no
         dw        80,25                    ; 12 = rezervov no
         dw        40,200                   ; 13 = grafika 320x200/16 (A000h)
         dw        80,200                   ; 14 = grafika 640x200/16 (A000h)
         dw        80,350                   ; 15 = grafika 640x350/2 (A000h)
         dw        80,350                   ; 16 = grafika 640x350/16 (A000h)


uvtxt    db        'Zobrazen¡ souboru ve form tu displeje.',13,10
         db        'Zadejte: DISPSCR <jm‚no_souboru> ...',13,10
         db        'Mezera = cyklov n¡ obr zk–, jinak konec',13,10,'$'


err1     db        'Soubor nenalezen nebo chyba ‡ten¡ !',13,10,'$'

err2     db        'Chyba p©idˆlen¡ pamˆti !',13,10,'$'

aktmod   db        0                        ; aktu ln¡ videom¢d

jmeno    db        128 dup(0)               ; jm‚na zadan˜ch soubor–
         db        0

pocetjm  db        0                        ; po‡et jmen soubor–
pocetsc  db        0                        ; po‡et zobrazen˜ch obr zk–

         dw        256 dup(0)               ; z sobn¡k
stack    dd        0                        ; vlastn¡ z sobn¡k

konec:                                      ; konec programu

code     ENDS


         END       start                    ; startovac¡ adresa


code     segment
         assume    cs:code,ds:code
         org       100h

start:

; ------ £schova p©¡znaku VERIFY

         mov       ah,54h
         int       21h                      ; poskytnut¡ VERIFY
         mov       ds:[OldVerif],al         ; £schova VERIFY

; ------ zapnut¡ VERIFY

         mov       ax,2e01h
         int       21h                      ; zapnut¡ p©¡znaku VERIFY

; ------ £schova p–vodn¡ho aktivn¡ho disku

         mov       ah,19h
         int       21h                      ; poskytnut¡ aktivn¡ho disku
         mov       ds:[olddisk],al          ; £schova p–vodn¡ho aktivn¡ho disku

; ------ p©edefinov n¡ obsluhy p©eru¨en¡

         mov       ax,2523h
         mov       dx,offset prerus
         int       21h                      ; p©edefinov n¡ obsluhy p©eru¨en¡

; ------ v˜po‡et segmentu za‡ tku bufferu

         mov       bx,cs                    ; aktu ln¡ segment
         add       bx,offset(konec-start+100h+15)/16 ; p©i‡ten¡ konce programu
         mov       ds:[topbuf],bx           ; segment za‡ tku bufferu

; ------ segment konce bufferu, kontrola dostatku pamˆti

         mov       ax,ds:[2]                ; segment konce pamˆti
         sub       ax,100h                  ; rezerva pro z sobn¡k 4 KB
         mov       ds:[endbuf],ax           ; segment konce bufferu
         sub       ax,0f00h                 ; rezerva pro data
         cmp       ax,bx                    ; je dostatek pamˆti ?
         jae       start2                   ; je dostatek pamˆti
         mov       dx,offset memtxt         ; chyba nedostatku pamˆti
         jmp       chyba                    ; nen¡ dostatek pamˆti

; ------ definice nov‚ho z sobn¡ku

start2:  mov       ss,ax                    ; nov˜ pracovn¡ z sobn¡k
         xor       sp,sp                    ; pracovn¡ vrchol z sobn¡ku

; ------ reset diskov‚ho syst‚mu

         mov       ah,0dh
         int       21h                      ; reset diskov‚ho syst‚mu DOS

; ------ p©¡prava textu zad n¡

         cld
         mov       si,81h                   ; za‡ tek textu
         mov       di,si                    ; za‡ tek textu
         xor       ch,ch                    ; CH <- 0
         mov       cl,ds:[80h]              ; po‡et znak– textu
         jcxz      priprav3                 ; nen¡ ‘ dn˜ znak
priprav: lodsb                              ; na‡ten¡ znaku
         cmp       al,"a"
         jb        priprav1
         cmp       al,"z"
         ja        priprav1
         sub       al,32                    ; korekce na velk‚ p¡smeno
priprav1:cmp       al,"W"                   ; je p©ep¡na‡ "/W" ?
         jne       priprav4                 ; nen¡ p©ep¡na‡ "/W"
         cmp       byte ptr ds:[si-2],"/"   ; byl to parametr "/W" ?
         jne       priprav4                 ; nebyl to parametr "/W"
         mov       byte ptr ds:[overwrit],1 ; p©ep¡na‡ - p©epis bez varov n¡
         mov       al," "                   ; n hradn¡ znak mezery
         mov       ds:[si-2],al             ; n hrada znaku "/"
priprav4:cmp       al,13                    ; je konec © dku ?
         je        priprav3                 ; je konec © dku
         cmp       al," "                   ; je platn˜ znak ?
         jae       priprav2                 ; je platn˜ znak
         mov       al," "                   ; n hradn¡ mezera
priprav2:stosb                              ; ulo‘en¡ p©ek¢dovan‚ho znaku
         loop      priprav                  ; p©¡prava dal¨¡ho znaku
priprav3:xor       al,al
         stosb                              ; ozna‡en¡ konce textu

; ------ rozli¨en¡ prvn¡ho parametru (zda je disk)

         mov       si,81h                   ; za‡ tek textu
         call      disk                     ; na‡ten¡ oznacen¡ disku
         jc        souborx                  ; nen¡ disk - bude soubor
         call      disk5                    ; test ‡¡sla disku
         mov       dx,offset disktxt        ; chyba zad n¡ disku
         jc        chyba                    ; chybn‚ zad n¡ ‡¡sla disku

; ------ druh˜m parametrem bude soubor

         call      soubor                   ; rozbor zad n¡ jm‚na souboru
         mov       dx,offset errtxt
         jc        chyba                    ; chyba zad n¡

; ------ vytvo©en¡ c¡lov‚ho souboru pro z pis

         mov       dx,di                    ; jm‚no souboru
         cmp       byte ptr ds:[overwrit],1 ; potvrzen¡ z pisu ?
         je        soubex1                  ; soubor se m–‘e p©epsat
         mov       ah,4eh
         mov       cx,17h
         int       21h                      ; test, zda soubor existuje
         jnc       soubex                   ; soubor nalezen - chyba
soubex1: xor       cx,cx
         mov       ah,3ch
         int       21h                      ; vytvo©en¡ souboru
         mov       dx,offset zadtxt
         jc        chyba                    ; chybn‚ zad n¡ souboru
         mov       word ptr ds:[identif],ax ; identifik tor souboru

         call      copdf                    ; kop¡rov n¡ z disku do souboru
         jc        chyba                    ; chyba operace

navrat:  push      cs
         pop       es
         push      cs
         pop       ds
         mov       al," "
         mov       cx,22
         cld
         mov       di,offset kurz
         mov       dx,di
         rep       stosb
         call      disptxt
         xor       al,al
         jmp       short chyba1

soubex:  mov       dx,offset existtxt
chyba:   push      cs
         pop       ds
         call      disptxt                  ; zobrazen¡ chybov‚ho textu
prerus:  mov       al,1                     ; n vratov˜ k¢d

chyba1:  push      cs
         pop       ds
         push      ax
         mov       bx,ds:[identif]
         or        bx,bx
         jz        chyba2
         mov       ah,3eh
         int       21h
chyba2:  mov       dl,ds:[olddisk]
         mov       ah,0eh
         int       21h                      ; n vrat p–vodn¡ho disku

; ------ n vrat VERIFY

         mov       al,ds:[OldVerif]         ; p–vodn¡ p©¡znak VERIFY
         mov       ah,2eh
         int       21h                      ; n vrat p©¡znaku VERIFY

         pop       ax

         mov       ah,4ch
         int       21h                      ; ukon‡en¡ s chybou

; ------ prvn¡m parametrem je asi soubor (nen¡ to disk)

souborx: mov       si,81h                   ; za‡ tek textu
         call      soubor                   ; rozbor zad n¡ jm‚na souboru
         mov       dx,offset errtxt
         jc        chyba                    ; chyba zad n¡

; ------ otev©en¡ zdrojov‚ho souboru

         mov       dx,di                    ; jm‚no souboru
         mov       ax,3d00h
         int       21h                      ; otev©en¡ souboru pro ‡ten¡
         mov       dx,offset fndtxt
         jc        chyba                    ; chyba - soubor nenalezen
         mov       word ptr ds:[identif],ax ; identifik tor souboru

; ------ druh˜m parametrem m  b˜t disk

         call      disk                     ; na‡ten¡ oznacen¡ disku
         mov       dx,offset errtxt
         jc        chyba                    ; nen¡ disk - chyba
         call      disk5                    ; test ‡¡sla disku
         mov       dx,offset disktxt        ; chyba zad n¡ disku
         jc        chyba                    ; chybn‚ zad n¡ ‡¡sla disku

; ------ kop¡rov n¡ souboru na disk

         call      copfd                    ; kop¡rov n¡ ze souboru na disk
         jc        chyba                    ; chyba operace
         jmp       short navrat


; =============================================================================

copdf89: ret


                                         ;* kop¡rov n¡ disku do souboru
copdf:
         call      pardisk                  ; nastaven¡ parametr– disku
         jc        copdf89                  ; nekompatibiln¡ syst‚m

; ------ na‡ten¡ sektor– z disku do cel‚ pamˆti

; ------ nastaven¡ ukazatel– na za‡ tek bufferu

copdf1:  mov       ax,ds:[readsekt]         ; ukazatel sektor– ke ‡ten¡
         mov       ds:[frstsekt],ax         ; £schova prvn¡ho sektoru
         mov       ax,ds:[topbuf]           ; za‡ tek bufferu
         mov       ds:[readseg],ax          ; ‡tec¡ adresa

; ------ v˜po‡et po‡tu sektor– pro jednu operaci ‡ten¡

copdf22: mov       ax,ds:[endbuf]           ; konec pamˆti
         sub       ax,ds:[readseg]          ; v˜po‡et velikosti voln‚ pamˆti
         xor       dx,dx
         div       word ptr ds:[sektsiz4]   ; v˜po‡et po‡tu sektor–
         mov       cx,ax                    ; po‡et sektor–
         cmp       cx,ds:[bufsekt]          ; max. po‡et sektor– pro operaci
         jbe       copdf23                  ; po‡et sektor– OK
         mov       cx,ds:[bufsekt]          ; omezen¡ sektor– na 64 KB
copdf23: mov       ax,ds:[maxsekt]          ; maxim ln¡ po‡et sektor– na disku
         sub       ax,ds:[readsekt]         ; po‡et zbyl˜ch sektor–
         cmp       ax,cx                    ; zb˜v  m‚nˆ sektor– ?
         jae       copdf3                   ; po‘adovan˜ po‡et sektor– men¨¡
         mov       cx,ax                    ; omezen¡ na sektory do konce disku

; ------ na‡ten¡ bloku sektor– (max. 64 KB) do pamˆti

copdf3:  clc
         jcxz      copdf33                  ; je ji‘ konec pamˆti
         mov       dx,ds:[readsekt]
         mov       bx,ds:[readseg]
         call      readskt                  ; na‡ten¡ bloku dat do pamˆti
         mov       dx,offset readdtxt
         jc        copdf89                  ; chyba ‡ten¡ z diskety
         add       ds:[readsekt],cx         ; zv˜¨en¡ ukazatele sektor–
         mov       ax,ds:[sektsiz4]         ; velikost sektoru
         mul       cx                       ; v˜po‡et p©¡rustku adresy
         add       ds:[readseg],ax          ; zv˜¨en¡ ukl dac¡ adresy

; ------ zobrazen¡ kurzoru

         call      dispkurr                 ; zobrazen¡ kurzoru pro ‡ten¡

; ------ test, zda je ji‘ konec pamˆti

         cmp       bx,ds:[endbuf]           ; je ji‘ konec pamˆti ?
         jb        copdf22                  ; nen¡ je¨tˆ konec pamˆti

; ------ nastaven¡ ukazatel– na za‡ tek bufferu

copdf33: mov       ax,ds:[topbuf]           ; za‡ tek bufferu
         mov       ds:[writseg],ax          ; z posov  adresa

copdf34:

         push      bx
         push      ds

         mov       ax,ds:[readsekt]         ; poslednˆ na‡ten˜ sektor
         sub       ax,ds:[writsekt]         ; po‡et zbyl˜ch sektor– pro z pis
         cmp       ax,ds:[bufsekt]          ; je velk˜ po‡et sektor– ?
         jbe       copdf35                  ; po‡et sektor– je OK
         mov       ax,ds:[bufsekt]          ; omezen¡ po‡tu sektor–
copdf35: add       ds:[writsekt],ax         ; zv˜¨en¡ ukazatele sektor–
         mul       word ptr ds:[sektsize]   ; p©epo‡et na bajty
         mov       cx,ax                    ; po‡et bajt– k z pisu

         mov       ds,ds:[writseg]          ; adresa pro z pis
         xor       dx,dx                    ; offset adresy
         mov       bx,cs:[identif]
         mov       ah,40h
         clc
         jcxz      copdf36
         int       21h                      ; z pis dat do souboru
copdf36:
         pop       ds
         pop       bx
         jcxz      copdf5

         jc        copdf6
         cmp       ax,cx
         jne       copdf6

         shr       cx,1
         shr       cx,1
         shr       cx,1
         shr       cx,1
         add       ds:[writseg],cx          ; zv˜¨en¡ z pisov‚ho segmentu

; ------ zobrazen¡ kurzoru

         call      dispkurw                 ; zobrazen¡ kurzoru pro z pis

         mov       ax,ds:[writseg]
         cmp       ax,ds:[endbuf]
         jb        copdf34                  ; z pis dal¨¡ho bloku

copdf5:  mov       ax,ds:[readsekt]
         cmp       ax,ds:[maxsekt]
         jae       copdf9
         jmp       copdf1


copdf6:  mov       dx,offset writftxt
         stc
         ret

copdf7:  mov       dx,offset readdtxt
copdf8:  stc
copdf9:  ret



                                           ;* kop¡rov n¡ souboru na disk
copfd:
         mov       al,ds:[disket]
         add       al,"A"
         mov       ds:[vartxt1],al
         mov       dx,offset vartxt
         cmp       byte ptr ds:[overwrit],1 ; potvrzen¡ z pisu ?
         je        copfd0                   ; z pis se nepotvrzuje
         call      disptxt                  ; zobrazen¡ textu varov n¡
         mov       ax,0c01h
         int       21h                      ; vstup znaku z kl vesnice
         push      ax
         mov       dx,offset systxt1
         call      disptxt                  ; od© dkov n¡ textu
         pop       ax
         cmp       al,13                    ; je Enter ?
         je        copfd0                   ; je Enter - pokra‡ov n¡ operace

         stc ; clc
copfda:  ret

copfd0:

         call      pardisk                  ; nastaven¡ parametr– disku
         jc        copfda                   ; nekompatibiln¡ syst‚m

                                          ;* zji¨tˆn¡ velikosti souboru
         mov       bx,ds:[identif]
         mov       ax,4202h
         xor       cx,cx
         xor       dx,dx
         int       21h
         div       word ptr ds:[sektsize]   ; v˜po‡et po‡tu sektor–
         cmp       ds:[maxsekt],ax          ; kontrola po‡tu sektor– disku
         mov       dx,offset formtxt
         stc
         jne       copfda                   ; chyba - nespr vn˜ form t disku
         xor       cx,cx
         xor       dx,dx
         mov       ax,4200h
         int       21h

; ------ nastaven¡ ukazatel– na za‡ tek bufferu

copfd1:  mov       ax,ds:[readsekt]         ; ukazatel sektor– ke ‡ten¡
         mov       ds:[frstsekt],ax         ; £schova prvn¡ho sektoru
         mov       ax,ds:[topbuf]           ; za‡ tek bufferu
         mov       ds:[readseg],ax          ; ‡tec¡ adresa

; ------ v˜po‡et po‡tu sektor– pro jednu operaci ‡ten¡

copfd22: mov       ax,ds:[endbuf]           ; konec pamˆti
         sub       ax,ds:[readseg]          ; v˜po‡et velikosti voln‚ pamˆti
         xor       dx,dx
         div       word ptr ds:[sektsiz4]   ; v˜po‡et po‡tu sektor–
         mov       cx,ax                    ; po‡et sektor–
         cmp       cx,ds:[bufsekt]          ; max. po‡et sektor– pro operaci
         jbe       copfd23                  ; po‡et sektor– OK
         mov       cx,ds:[bufsekt]          ; omezen¡ sektor– na 64 KB
copfd23: mov       ax,ds:[sektsize]         ; velikost sektoru
         mul       cx                       ; p©epo‡et sektor– na bajty
         mov       cx,ax                    ; po‡et bajt– ke ‡ten¡

; ------ na‡ten¡ bloku sektor– ze souboru

         clc
         jcxz      copfd33                  ; je ji‘ konec pamˆti
         push      ds
         mov       bx,ds:[identif]
         mov       ds,ds:[readseg]          ; segment ke ‡ten¡ dat
         xor       dx,dx                    ; offset adresy
         mov       ah,3fh
         int       21h                      ; ‡ten¡ dat ze souboru
         pop       ds
         mov       dx,offset readftxt
         jc        copfda                   ; chyba ‡ten¡
         push      ax
         xor       dx,dx
         div       word ptr ds:[sektsize]   ; v˜po‡et po‡tu sektor–
         add       ds:[readsekt],ax         ; zv˜¨en¡ ukazatele ‡ten‚ho sektoru
         pop       ax

         call      dispkurr                 ; zobrazen¡ kurzoru pro ‡ten¡

         mov       cl,4
         shr       ax,cl                    ; p©evod na‡ten˜ch dat na odstavce
         add       ds:[readseg],ax          ; zv˜¨en¡ adresy ‡ten˜ch dat
         or        ax,ax
         jz        copfd33                  ; je konec souboru
         mov       ax,ds:[endbuf]
         cmp       ax,ds:[readseg]
         ja        copfd22                  ; dal¨¡ blok dat

; ------ z pis sektor– na disk

copfd33: mov       ax,ds:[topbuf]           ; za‡ tek bufferu
         mov       ds:[writseg],ax          ; z posov  adresa
         mov       ax,ds:[readsekt]
         cmp       ax,ds:[writsekt]
         je        copfdb                   ; jsou ji‘ v¨echny sektory

; ------ z pis 64 KB na disk

copfd34:
         mov       ax,ds:[readsekt]         ; poslednˆ na‡ten˜ sektor
         sub       ax,ds:[writsekt]         ; po‡et zbyl˜ch sektor– pro z pis
         cmp       ax,ds:[bufsekt]          ; je velk˜ po‡et sektor– ?
         jbe       copfd35                  ; po‡et sektor– je OK
         mov       ax,ds:[bufsekt]          ; omezen¡ po‡tu sektor–
copfd35: mov       cx,ax                    ; po‡et sektor– pro z pis
         jcxz      copfd36                  ; jsou ji‘ v¨echna data

         mov       dx,ds:[writsekt]
         mov       bx,ds:[writseg]
         add       ds:[writsekt],cx         ; zv˜¨en¡ ukazatele sektor–

         call      writskt                  ; z pis sektor– na disk
         jc        copfd6                   ; chyba z pisu na disk

         mov       ax,ds:[sektsiz4]
         mul       cx                       ; p©¡rustek adresy v odstavc¡ch
         add       ds:[writseg],ax          ; zv˜¨en¡ adresy


copfd36:
         call      dispkurw                 ; zobrazen¡ kurzoru pro z pis

         mov       ax,ds:[writsekt]
         cmp       ax,ds:[readsekt]
         jb        copfd34                  ; z pis dal¨¡ho bloku

copfd5:
         jmp       copfd1

copfd6:  mov       dx,offset writdtxt
         stc
copfdb:  ret


; =============================================================================

                                          ;* na‡ten¡ parametru - ozna‡en¡ disku
disk:
         call      readspc                  ; vypustˆn¡ mezer
         jc        disk1                    ; nen¡ ‘ dn˜ parametr

; ------ rozli¨en¡, zda je parametrem zad n¡ disku

         cmp       byte ptr ds:[si+1],":"   ; je zad n disk ?
         jne       disk1                    ; nen¡ zad n disk
         cmp       byte ptr ds:[si+2]," "   ; je platn˜ znak ?
         ja        disk1                    ; je platn˜ znak - nen¡ disk
         call      readch                   ; na‡ten¡ ozna‡en¡ disku
         sub       al,"A"                   ; korekce na ‡¡slo disku
         mov       ds:[disket],al           ; £schova ozna‡en¡ disku
         inc       si                       ; p©esko‡en¡ znaku ":"
         clc
         ret

disk1:   stc
         ret

; ------ test, zda je zad na existuj¡c¡ mechanika

disk5:
         mov       dl,ds:[disket]           ; zadan˜ disk
         mov       ah,0eh
         int       21h
         mov       ah,19h
         int       21h
         cmp       al,ds:[disket]           ; je ‡¡slo diskety OK ?
         je        disk4
         stc
disk4:   pushf
         mov       ah,0eh
         mov       dl,ds:[OldDisk]
         int       21h
         popf
         ret



                                          ;* nastaven¡ ozna‡en¡ souboru
soubor:

; ------ nalezen¡ za‡ tku druh‚ho parametru

         call      readspc                  ; vypustˆn¡ mezer
         jc        soubor5                  ; chyba zad n¡ - nen¡ parametr

; ------ test, zda je zad no ozna‡en¡ disku

         cmp       byte ptr ds:[si+1],":"   ; je ozna‡en¡ disku ?
         jne       soubor2                  ; nen¡ ozna‡en¡ disku
         cmp       byte ptr ds:[si+2]," "+1 ; je d le nˆjak˜ platn˜ znak ?
         jb        soubor5                  ; je zad n jen disk

; ------ ozna‡en¡ konce jm‚na souboru

soubor2: mov       di,si                    ; £schova za‡ tku jm‚na souboru
soubor3: call      readch
         jc        soubor4                  ; konec textu
         jne       soubor3                  ; nen¡ konec textu
         mov       byte ptr ds:[si-1],0     ; ozna‡en¡ konce jm‚na souboru

soubor4: clc
soubor5: ret



                                          ;* na‡ten¡ sektor– do pamˆti
                                            ; VSTUP: CX=po‡et sektor–
                                            ;        DX=po‡ te‡n¡ sektor
                                            ;        BX=segment adresy
readskt:
         mov       bp,4                     ; po‡et pokus–

readsek1:dec       bp
         stc
         jz        readsek2                 ; chyba

         push      bp
         push      ax
         push      bx
         push      cx
         push      dx
         push      ds

         mov       ds,bx
         xor       bx,bx

         mov       al,cs:[disket]

         mov       cs:[zasobnik],sp
         int       25h
         mov       sp,cs:[zasobnik]

         pop       ds
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         pop       bp
         jc        readsek1

readsek2:ret


                                          ;* z pis sektor– na disk
                                            ; VSTUP: CX=po‡et sektor–
                                            ;        DX=po‡ te‡n¡ sektor
                                            ;        BX=segment adresy
writskt:
         mov       bp,4                     ; po‡et pokus–

writsek1:dec       bp
         stc
         jz        writsek2                 ; chyba

         push      bp
         push      ax
         push      bx
         push      cx
         push      dx
         push      ds

         mov       ds,bx
         xor       bx,bx

         mov       al,cs:[disket]

         mov       cs:[zasobnik],sp
         int       26h
         mov       sp,cs:[zasobnik]

         pop       ds
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         pop       bp
         jc        writsek1

writsek2:ret




                                          ;* zji¨tˆn¡ parametr– disku
pardisk:

         mov       dx,offset kurz
         call      disptxt

; ------ na‡ten¡ prvn¡ho sektoru z diskety

         mov       cx,1                     ; 1 sektor
         xor       dx,dx                    ;
         mov       bx,ds:[topbuf]
         call      readskt                  ; na‡ten¡ BOOT sektoru
         mov       dx,offset readdtxt
         jc        pardisk2                 ; chyba ‡ten¡ zavadˆ‡e z diskety

; ------ ur‡en¡ velikosti disku

         call      InitINT25                ; inicializace parametr– disku
         mov       dx,offset systtxt
         jc        pardisk2                 ; chyba disku

; ------ v˜po‡et maxim ln¡ho po‡tu sektor– pro jednu operaci

         mov       ax,0ffffh
         xor       dx,dx                    ; maxim ln¡ velikost 64 KB - 1
         div       word ptr ds:[Sektsize]   ; v˜po‡et po‡tu sektor–
         mov       ds:[bufsekt],ax          ; po‡et sektor– do 64 KB

         clc

pardisk2:ret




public   InitINT25
InitINT25:                                ;* inicializace obsluhy INT 25h

         push      ds
                                          ;* poskytnut¡ tabulky parametr– disku
         mov       dl,cs:[disket]           ; disk pro obsluhu INT 25h
         inc       dl
         mov       ax,32ffh
         int       21h                      ; poskytnut¡ bloku parametr– disku

                                          ;* test spr vnosti disku
         cmp       al,0ffh                  ; je chyba ?
         stc
         je        InitI255                 ; je chyba - neplatn˜ disk
         dec       dl                       ; ‡¡slo po‘adovan‚ho disku
         cmp       dl,ds:[bx]               ; souhlas¡ ‡¡slo disku ?
         stc
         jne       InitI255                 ; ‡¡slo disku nesouhlas¡ - chyba

                                          ;* zji¨tˆn¡ celkov‚ho po‡tu sektor–
         mov       ax,ds:[bx+0dh]           ; max. ‡¡slo aloka‡n¡ho bloku
         dec       ax                       ; po‡et aloka‡n¡ch blok–
         xor       cx,cx                    ; CX <- 0
         mov       cl,ds:[bx+4]             ; maxim ln¡ ‡¡slo sektoru v bloku
         inc       cx                       ; po‡et sektor– v aloka‡n¡m bloku
         mul       cx                       ; v˜po‡et po‡tu sektor– dat celkem
         add       ax,ds:[bx+0bh]           ; p©i‡ten¡ rezervovan˜ch sektor–
         jc        InitI255                 ; velk˜ po‡et sektor–
         or        dx,dx
         stc
         jnz       InitI255                 ; velk˜ po‡et sektor–

         mov       word ptr cs:[maxsekt],ax ; po‡et sektor– disku celkem
         cmp       ax,128                   ; minim ln¡ po‡et sektor–
         jb        InitI255                 ; chybn˜ po‡et sektor–
         cmp       ax,4000h                 ; maxim ln¡ velikost z©ejmˆ 8 MB
         cmc
         jc        InitI255                 ; chybn˜ po‡et sektor–

         mov       ax,ds:[bx+2]             ; po‡et bajt– na sektor
         mov       cs:[Sektsize],ax         ; velikost sektoru
         cmp       ax,64
         jb        InitI255
         cmp       ax,4000h
         cmc
         jc        InitI255
         test      ax,63                    ; n sobek 2 ?
         stc
         jnz       initi255                 ; chybn  velikost
         mov       cl,4
         shr       ax,cl                    ; p©evod na odstavce
         mov       cs:[sektsiz4],ax         ; po‡et odstavc– na sektor

         clc

InitI255:pop       ds
         ret


dispkurr:                                 ;* zobrazen¡ kurzoru pro ‡ten¡

         push      ax
         push      cx
         mov       al,176
         mov       cx,cs:[readsekt]
         call      dispkur
         pop       cx
         pop       ax
         ret

dispkurw:                                 ;* zobrazen¡ kurzoru pro z pis

         push      ax
         push      cx
         mov       al,178
         mov       cx,cs:[writsekt]
         call      dispkur
         pop       cx
         pop       ax
         ret



                                          ;* zobrazen¡ kurzoru
                                            ; VSTUP: CX=aktu ln¡ sektor
                                            ;        AL=znak kurzoru

dispkur: push      ax
         push      cx
         push      dx
         push      si

         push      ax
         mov       ax,cx                    ; nov˜ kurzor
         call      pozkur                   ; v˜po‡et pozice
         mov       cx,si                    ; £schova pozice
         mov       ax,cs:[frstsekt]         ; star˜ kurzor
         call      pozkur
         sub       cx,si                    ; p©¡rustek pozic
         pop       ax
         jcxz      dispkur3
dispkur2:mov       ds:[si],al
         inc       si
         loop      dispkur2

         mov       dx,offset kurz
         call      disptxt

dispkur3:pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

                                          ;* v˜po‡et pozice kurzoru
                                            ; VSTUP: AX=‡¡slo sektoru
                                            ; VSTUP:SI=adresa kurzoru
pozkur:  push      ax
         push      cx
         push      dx

         mov       cx,20                    ; po‡et znak–
         mul       cx                       ; vyn soben¡ 20x
         mov       cx,cs:[maxsekt]          ; celkov˜ po‡et sektor–
         div       cx                       ; v˜po‡et offsetu kurzoru
         mov       si,ax                    ; offset kurzoru
         add       si,offset kurz+1         ; adresa kurzoru

         pop       dx
         pop       cx
         pop       ax
         ret


; =============================================================================



readspc: call      readch
         jc        readspc2
         je        readspc
         dec       si
readspc2:ret


readch:  lodsb                              ; na‡ten¡ znaku
         cmp       al," "                   ; rozli¨en¡ oddˆlova‡e, konce
         jae       readch2                  ; nen¡ konec textu
         dec       si                       ; n vrat posledn¡ho znaku
readch2: ret




disptxt: push      ax
         mov       ah,9
         int       21h
         pop       ax
         ret

; =============================================================================

errtxt   db        'DISKFILE V1.11 - kopirovani disket; (c) Miroslav Nemecek',13,10
         db        '--------------------------------------------------------',13,10
         db        'Zadejte: DISKFILE  zdrojovy_disk:   cilovy_soubor',13,10
         db        '   nebo: DISKFILE  zdrojovy_soubor  cilovy_disk:',13,10
         db        '/W - cilovy soubor nebo disk se prepise bez varovani',13,10
         db        '$'

memtxt   db        'Nedostatek pameti !',13,10,'$'
fndtxt   db        'Zdrojovy soubor nenalezen !',13,10,'$'
zadtxt   db        'Chybne zadani jmena souboru !',13,10,'$'
disktxt  db        'Chybne zadani disketove jednotky !',13,10,'$'
readftxt db        'Chyba cteni ze zdrojoveho souboru !',13,10,'$'
writftxt db        'Chyba zapisu do ciloveho souboru !',13,10,'$'
readdtxt db        'Chyba cteni z diskety !',13,10,'$'
writdtxt db        'Chyba zapisu na disketu !',13,10,'$'
existtxt db        'Cilovy soubor jiz existuje !',13,10,'$'
systtxt  db        'Chyba systemu nebo nezformatovany disk !'
systxt1: db        13,10,'$'
vartxt   db        'ÚÄÄÄÄ< Vlozte novou disketu do mechaniky  '
vartxt1  db        'A: >ÄÄÄÄ¿',13,10
         db        '³ VAROVANI: v¨echna data na disku budou znicena ! ³',13,10
         db        'ÀÄÄÄ Enter=pokracovani, jina klavesa=preruseni ÄÄÄÙ$'
formtxt  db        'Nespravny format ciloveho disku !',13,10,'$'

kurz     db        '> . . . . . . . . .  <',13,'$'

overwrit db        0                        ; p©¡znak: 1=p©epis bez varov n¡
frstsekt dw        0                        ; prvn¡ sektor v pamˆti
readsekt dw        0                        ; ukazatel ‡ten˜ch sektor–
writsekt dw        0                        ; ukazatel zapisovan˜ch sektor–
readseg  dw        0                        ; ‡tec¡ adresa
writseg  dw        0                        ; z pisov  adresa
lastsekt dw        0                        ; posledn¡ sektor v pamˆti + 1

maxsekt  dw        0                        ; celkov˜ po‡et sektor– disku
sektsize dw        0                        ; po‡et bajt– na sektor
sektsiz4 dw        0                        ; velikost sektoru v odstac¡ch
bufsekt  dw        0                        ; maxim ln¡ po‡et sektor– do 64 KB

olddisk  db        0                        ; £schova p–vodn¡ho aktivn¡ho disku
zasobnik dw        0                        ; £schova ukazatele z sobn¡ku
disket   db        0                        ; disketov  jednotka
identif  dw        0                        ; identifik tor souboru

topbuf   dw        0                        ; segment za‡ tku bufferu
endbuf   dw        0                        ; segment konce bufferu

OldVerif db        0                        ; uschovan˜ p©¡znak VERIFY

konec    label     byte                     ; konec programu

code     ends
         end       start

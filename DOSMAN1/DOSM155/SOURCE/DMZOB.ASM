
; modul DOSMZOB.ASM - zobrazen°

; *****************************************************************************
;
;                          Zobrazen° souborñ
;
; *****************************************************************************

code     segment   public
         assume    cs:code,ds:code

extrn    zobrchyb:near,getkurz:near,outbuf:byte,dekfile:near,segend:word
extrn    topseg:word,editmax:word,windret:near,outhelp:near,aktdir:near
extrn    getkurz:near,erroper:byte,outch10:near,inpid:word,editnum:word
extrn    erredi2:byte,inpkey:near,outch1:near,outch:near
extrn    zobtop:dword,zobukaz:dword,zobnum:dword,zobbuf:dword
extrn    parint:byte,skokax:near,edikey:word,testkey:near,ediroll:near
extrn    testakth:near,getakt:near,outtxt:near,blokuk:dword
extrn    poziceuk:byte,delkauk:byte,txthlpzo:byte,flags:byte,outthlp:near
extrn    ediflag:byte,outhexw:near,outhexb:near,kurzout:near
extrn    deknum:near,texthlpb:byte,setkonc:near,transtxt:near
extrn    highcase:near,volbyh:near,erredi4:byte,txtchyb1:byte
extrn    findstr:word,txtedi7:byte,bufhlde:byte,lensi:near
extrn    bufhlde2:byte,select:near,erredi3:byte
extrn    testbreak:near,msgcek:near,inpkeyf:near
extrn    althelp:near,help:near,config:byte,parbreak:word
extrn    testaktw:near,tabhlzob:word,getpocl:near
extrn    mousepoz:word,mouseget:near,mousemen:near,modihlp:near
extrn    edikey:word,mouseon:near,mouseoff:near,egaset:near
extrn    conf5:byte,toppoz:word,endpoz:word,zobwrap:word
extrn    deknum5:near,txtedi3:byte,citachod:byte,tisknm0:near
extrn    citacexp:byte,getnakt:near,topline:near,getnuml:near
extrn    deledis:near,iniedis:near,getatrib0:near,all:byte
extrn    bufwin:byte,creatfile:near,zobrfiln:near
extrn    zobrfilv:near,zobrfild:near,zobrfilc:near
extrn    disk25:byte,maxblok:word,maxsekt:dword,sektclus:byte
extrn    bajtsekt:word,bajtclus:word,parint25:byte,paket:byte
extrn    tisknm2s:near,tisknm20:near,zobrfd0:near
extrn    setspc:near,setfre:near,txtzob5:byte,txtzob6:byte
extrn    rezervs:word,txtzob7:byte,txtzob8:byte,txtzob9:byte
extrn    sektroot:word,sektfat:byte,outbuf4:byte,verze:word
extrn    txtzob10:byte
;,bufclust:word,bufclst1:byte,bufclst2:byte
extrn    setvysl:near,bufcalc:word,bufcalc1:byte,bufcalc2:byte,bufcalc3:word
extrn    helpbuf:byte

extrn    rozborcis:near,txtzob11:byte,txtzob12:byte,parnum:byte
extrn    txtzob13:byte,txtzob14:byte,deknum4:near,soubinf:byte
extrn    rozbor:near,rozbflg:byte,cmpfile:near,outbuf4:byte
extrn    aktokna:near,getnumlw:near,aktuald:near

ifdef    upver
extrn    txthlpzo3:near
endif

public   quickv
quickv:                                   ;* rychlÇ zobrazen°

IFDEF    upver
         pushf
         and       byte ptr cs:[conf5],not 0ch ; zru®en° p©°znakñ DIR a FAT
         and       byte ptr cs:[parint25],7fh ; zru®en° p©°znaku disku
         test      byte ptr cs:[conf5],2    ; je povoleno zobrazen° ?
         jz        quickv8                  ; nen° povoleno zobrazen°
         test      byte ptr cs:[config],10h ; m† bòt okno zobrazeno ?
         jnz       quickv8                  ; nem† bòt zobrazeno okno
         cmp       byte ptr cs:[citacexp],0 ; je á°taá jië 0 ?
         jne       quickv8                  ; áek†n° na p©°chod znaku
         call      testaktw                 ; je okno aktivn° ?
         jc        quickv8                  ; okno nen° zapnuto
;quickv0: popf
;         ret
;quickv1:                                  ;* poloëka se zobraz°
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es
         push      cs
         pop       ds
         push      cs
         pop       es
         call      mouseoff
         call      getatrib0                ; test, zda je poloëka
         jc        quickv6                  ; nen° ë†dnò soubor
                                          ;* nastaven° aktivn°ho adres†©e
         mov       si,ds:[bp+4]             ; adresa cesty k adres†©i
         call      aktdir                   ; nastaven° aktivn°ho adres†©e
         jc        quickv6                  ; chyba operace
                                          ;* nastaven° podadres†©e (je-li)
         test      bl,10h                   ; je to adres†© ?
         jz        quickv3                  ; nen° to adres†©
         call      getkurz                  ; soubor s kurzorem
         lea       di,[outbuf]              ; pomocnò buffer
         push      di
         call      dekfile                  ; dek¢dov†n° jmÇna souboru
         pop       si                       ; jmÇno adres†©e
         push      cs
         pop       ds                       ; DS <- CS
         call      aktdir                   ; zmàna adres†©e
quickv3:
         call      quickvp                  ; zobrazen° podkladu okna

         call      getatrib0                ; poskytnut° atributñ poloëky
         test      bl,10h                   ; je to adres†© ?
         jnz       quickv5                  ; je to adres†©
         call      quickz                   ; zobrazen° obsahu souboru
         jmp       short quickv6
quickv5: call      quicka                   ; zobrazen° obsahu adres†©e
quickv6:
         or        byte ptr ds:[config],10h ; p©°znak zobrazen° okna
         mov       word ptr ds:[parbreak],0 ; zru®en° p©°znaku chyby
         call      mouseon
         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax

quickv8: popf
         ret

; -----------------------------------------------------------------------------
public   quicka
quicka:                                   ;* zobrazen° obsahu adres†©e

         call      getnumlw                 ; poskytnut° poátu ©†dkñ okna

         push      bp
         call      getnakt
         mov       dl,ds:[bp+3]             ; poá†teán° pozice okna
         pop       bp
         inc       dl                       ; poá†teán° pozice pro zobrazen°
         mov       dh,4                     ; poá†teán° ©†dek
         test      byte ptr ds:[conf5],10h  ; byl nalezen soubor FILEINFO ?
         jnz       quicka5                  ; soubor FILEINFO byl nalezen
         mov       dh,1                     ; poá†teán° ©†dek
         add       cx,3
quicka5: xor       bx,bx                    ; p©°znak - pouze adres†©e
quicka0:                                  ;* naáten° prvn° poloëky
         push      cx
         push      dx
         mov       cx,16h                   ; atribut pro hled†n° poloëek
         lea       dx,[all]                 ; specifikace - v®echny soubory
         mov       ah,4eh                   ; funkce nalezen° prvn° poloëky
         int       21h                      ; naáten° prvn° poloëky
         pop       dx
         pop       cx
         jmp       short quicka2

quicka1: int       21h                      ; naáten° poloëky adres†©e
quicka2: jc        quicka7                  ; nen° dal®° poloëka
         inc       cx
                                          ;* filtr - pouze soubor
         or        bx,bx                    ; m† bòt adres†© ?
         jz        quicka22                 ; m† bòt adres†©
         test      byte ptr ds:[95h],10h    ; je to adres†© ?
         jnz       quicka6                  ; je to adres†© - nem† bòt
         jmp       short quicka3            ; je soubor - OK
                                          ;* filtr - pouze adres†©
quicka22:test      byte ptr ds:[95h],10h    ; je to adres†© ?
         jz        quicka6                  ; nen° to adres†© - poloëka neplat°
         cmp       word ptr ds:[9eh],"."    ; je to oznaáen° aktiv. adres†©e ?
         je        quicka6                  ; je aktivn° adres†© - neplat°
quicka3: dec       cx
         lea       si,[bufwin]              ; pracovn° buffer
         call      creatfile                ; vytvo©en° poloëky souboru
                                          ;* zobrazen° nalezenÇ poloëky
         push      dx
         call      zobrfiln                 ; zobrazen° jmÇna poloëky
         mov       al,179                   ; svisl† á†ra
         call      outch1                   ; zobrazen° oddàlovac° á†ry
         call      zobrfilv                 ; zobrazen° velikosti souboru
         mov       al,179                   ; svisl† á†ra
         call      outch1                   ; zobrazen° oddàlovac° á†ry
         call      zobrfild                 ; zobrazen° data souboru
         mov       al,179                   ; svisl† á†ra
         call      outch1                   ; zobrazen° oddàlovac° á†ry
         call      zobrfilc                 ; zobrazen° áasu souboru
         pop       dx
         inc       dh

quicka6: mov       ah,4fh                   ; funkce nalezen° dal®° poloëky
         loop      quicka1                  ; nalezen° dal®° poloëky
         jmp       short quicka9
quicka7: or        bx,bx                    ; byly jië soubory ?
         jnz       quicka8                  ; byly jië soubory
         inc       bx
         jmp       short quicka0            ; nalezen° souborñ
quicka8: jcxz      quicka9
         push      ax
         push      cx
         push      dx
         mov       al,179                   ; jednoduch† svisl† á†ra
         add       dl,12
         call      outch1                   ; zobrazen° oddàlovac° á†ry
         add       dl,10
         call      outch1                   ; zobrazen° oddàlovac° á†ry
         add       dl,8
         call      outch1                   ; zobrazen° oddàlovac° á†ry
         pop       dx
         pop       cx
         pop       ax
         inc       dh
         loop      quicka8
quicka9: ret

; -----------------------------------------------------------------------------
public   quickz
quickz:                                   ;* zobrazen° obsahu souboru

         call      getkurz                  ; soubor s kurzorem
         mov       ax,ds:[si+12]            ; nië®° slovo velikosti
         mov       word ptr cs:[zobnum],ax
         mov       ax,ds:[si+14]            ; vy®®° slovo velikosti
         mov       word ptr cs:[zobnum+2],ax
         lea       di,[outbuf]              ; pomocnò buffer
         mov       dx,di                    ; jmÇno souboru
         call      dekfile                  ; dek¢dov†n° jmÇna souboru
         push      cs
         pop       ds                       ; DS <- CS
                                          ;* otev©en° souboru
         call      zobcpgup1                ; nastaven° na zaá†tek souboru
         mov       ax,3d00h                 ; otev©en° souboru pro áten°
         int       21h                      ; otev©en° souboru
         jnc       quickz02
         call      aktuald
         mov       byte ptr ds:[citachod],0 ; poëadavek okamëitÇho zobrazen°
         mov       ax,3d00h                 ; otev©en° souboru pro áten°
         int       21h                      ; otev©en° souboru
quickz02:jc        quickz0                  ; chyba operace
         mov       ds:[inpid],ax            ; identifik†tor souboru
         call      iniedis                  ; inicializace pracovn°ho segmentu
         call      quickz2                  ; zobrazen° v®ech ©†dkñ
         call      deledis                  ; zru®en° pracovn°ho segmentu
         mov       bx,ds:[inpid]            ; identifik†tor souboru
         mov       ah,3eh                   ; funkce uzav©en° souboru
         int       21h                      ; uzav©en° souboru
quickz0: ret

; -----------------------------------------------------------------------------
public   quickz2
quickz2:                                  ;* zobrazen° v®ech ©†dkñ

         mov       word ptr ds:[endpoz],38  ; koncov† pozice ©†dku
         mov       word ptr ds:[zobwrap],128; max. pozice pro zalamov†n°
         call      zobgett                  ; adresa zaá†tku zobrazen°
         call      zobsetk                  ; nastaven° kurzoru
         call      getnumlw                 ; poskytnut° poátu ©†dkñ okna
;         add       cx,3                     ; poáet ©†dkñ k zobrazen°
         mov       dh,4                     ; poá†teán° ©†dek
         test      byte ptr ds:[conf5],10h  ; byl nalezen soubor FILEINFO ?
         jnz       quickz1                  ; soubor FILEINFO byl nalezen
         mov       dh,1                     ; poá†teán° ©†dek
         add       cx,3
quickz1: push      bp
         call      getnakt
         mov       dl,ds:[bp+3]             ; poá†teán° pozice okna
         pop       bp
         inc       dl                       ; poá†teán° pozice pro zobrazen°
quickz3: call      zobline0                 ; zobrazen° jednoho ©†dku okna
         cmp       word ptr cs:[parbreak],0 ; je chyba ?
         jne       quickz4                  ; je chyba
         inc       dh                       ; zvò®en° ukazatele ©†dku
         loop      quickz3                  ; zobrazen° dal®°ho ©†dku
quickz4: ret

; -----------------------------------------------------------------------------
public   quickvp
quickvp:                                  ;* zobrazen° podkladu rychlÇho zobr.

                                          ;* pokus o nalezen° souboru FILEINFO
         and       byte ptr ds:[conf5],not 10h ; zru®en° p©°znaku FILEINFO
         mov       dx,offset soubinf        ; soubor FILEINFO
         mov       cx,27h                   ; soubor HID, SYS, R/O
         mov       ah,4eh
         int       21h                      ; pokus o nalezen° souboru FILEINFO
         jc        quickvp1                 ; soubor nenalezen
                                          ;* nastaven° parametrñ souboru
         mov       ax,ds:[9ah]              ; nië®° slovo velikosti
         mov       word ptr ds:[zobnum],ax
         mov       ax,ds:[9ch]              ; vy®®° slovo velikosti
         mov       word ptr ds:[zobnum+2],ax
         or        byte ptr ds:[conf5],10h  ; p©°znak nalezen° souboru FILEINFO
quickvp1:
         push      bp
         call      getnakt
         xor       dx,dx
         mov       dl,ds:[bp+3]             ; poá†teán° pozice okna
         pop       bp
                                          ;* zobrazen° horn°ho ©†dku okna
         push      dx
         mov       al,1                     ; atribut 1
         call      outch1                   ; nastaven° atributu 1
         mov       al,201                   ; levò horn° roh
         call      outch1                   ; zobrazen° znaku rohu
         mov       al,205                   ; rovn† dvojit† á†ra
         mov       cx,38                    ; dÇlka linky
         call      outch                    ; zobrazen° horn° linky
         mov       al,187                   ; pravò horn° roh
         call      outch1                   ; zobrazen° pravÇho horn°ho rohu
         pop       dx
         inc       dh

         call      getnumlw                 ; poskytnut° poátu ©†dkñ okna
         add       cx,3
         test      byte ptr ds:[conf5],10h  ; byl nalezen soubor FILEINFO ?
         jz        quickvpa                 ; soubor FILEINFO nebyl nalezen

         mov       cx,2
         call      quickvp2                 ; horn° 2 ©†dky
                                          ;* zobrazen° oddàlovac° linky
         push      dx
         mov       al,204                   ; lev† strana
         call      outch1                   ; zobrazen° znaku rohu
         mov       al,205                   ; rovn† dvojit† á†ra
         mov       cx,38                    ; dÇlka linky
         call      outch                    ; zobrazen° horn° linky
         mov       al,185                   ; prav† strana
         call      outch1                   ; zobrazen° pravÇ strany
         pop       dx
         inc       dh
                                          ;* zobrazen° vnit©n°ch ©†dkñ
         call      getnumlw                 ; poskytnut° poátu ©†dkñ okna
quickvpa:call      quickvp2
                                          ;* zobrazen° spodn°ho ©†dku
         mov       al,200                   ; levò doln° roh
         call      outch1                   ; zobrazen° levÇho doln°ho rohu
         mov       al,205                   ; rovn† dvojit† á†ra
         mov       cx,38                    ; dÇlka linky
         call      outch                    ; zobrazen° horn° linky
         mov       al,188                   ; pravò doln° roh
         call      outch1                   ; zobrazen° pravÇho doln°ho rohu

         test      byte ptr ds:[conf5],10h  ; byl nalezen soubor FILEINFO ?
         jz        quickvp9                 ; soubor FILEINFO nenalezen
                                          ;* otev©en° souboru FILEINFO
         mov       dx,offset soubinf        ; soubor FILEINFO
         mov       ax,3d00h
         int       21h                      ; otev©en° souboru pro áten°
         jc        quickvp9                 ; soubor nenalezen
         mov       ds:[inpid],ax            ; identifik†tor souboru
         call      zobcpgup1                ; nastaven° na zaá†tek souboru
         call      iniedis                  ; inicializace pracovn°ho segmentu
                                          ;* zobrazen° prvn°ho ©†dku ze souboru
;         mov       word ptr ds:[endpoz],38  ; koncov† pozice ©†dku
;         mov       word ptr ds:[zobwrap],128; max. pozice pro zalamov†n°
         call      zobgett                  ; adresa zaá†tku zobrazen°
         call      zobsetk                  ; nastaven° kurzoru
         mov       dh,1                     ; poá†teán° ©†dek
         push      bp
         call      getnakt
         mov       dl,ds:[bp+3]             ; poá†teán° pozice okna
         pop       bp
         inc       dl                       ; poá†teán° pozice pro zobrazen°

         call      quickl1                  ; zobrazen° prvn°ho ©†dku
;         call      quickinf                 ; zobrazen° prvn°ho ©†dku FILEINFO

         cmp       word ptr cs:[parbreak],0 ; je chyba ?
         jne       quickvp7                 ; je chyba

         call      getatrib0                ; poskytnut° atributñ
         test      bl,10h                   ; je to adres†© ?
         jnz       quickvp7                 ; je to adres†©
         call      quickinf                 ; zobrazen° druhÇho ©†dku FILEINFO
quickvp7:
         call      deledis                  ; zru®en° pracovn°ho segmentu
         mov       bx,ds:[inpid]            ; identifik†tor souboru
         mov       ah,3eh                   ; funkce uzav©en° souboru
         int       21h                      ; uzav©en° souboru FILEINFO
quickvp9:
         mov       byte ptr ds:[citachod],0 ; poëadavek okamëitÇho zobrazen°
ENDIF
         ret

public   quickvp2
                                          ;* zobrazen° CX vnit©n°ch ©†dkñ
quickvp2:push      dx
         mov       al,186                   ; levò okraj
         call      outch1
         push      cx
         mov       cx,38
         mov       al," "
         call      outch                    ; mezera
         pop       cx
         mov       al,186
         call      outch1                   ; pravò okraj
         pop       dx
         inc       dh
         loop      quickvp2
         ret


public   quickinf
quickinf:                                 ;* zobrazen° druhÇho ©†dku FILEINFO

quicki2:                                  ;* test jednoho ©†dku

         call      quickos                  ; vypustàn° poá†teán°ch oddàlovaáñ
         jc        quicki9                  ; nen° jië dal®° znak - konec soub.
         je        quicki2                  ; je konec ©†dku LF - dal®° ©†dek
         cmp       al,";"                   ; je pozn†mka ?
         je        quicki6                  ; je pozn†mka
         cmp       al,"'"
         je        quicki6                  ; je pozn†mka
                                          ;* uloëen° textu specifikace
         mov       cx,14                    ; maxim†ln° poáet znakñ specifikace
         mov       di,offset outbuf4        ; pracovn° buffer
quicki3: stosb                              ; uloëen° znaku do bufferu
         dec       cx                       ; sn°ëen° á°taáe znakñ
         jcxz      quicki4                  ; je jië plnò poáet znakñ
         call      zobchnxt                 ; naáten° dal®°ho znaku
         jc        quicki4                  ; konec souboru
         cmp       al," "                   ; je mezera ?
         ja        quicki3                  ; je platnò znak - dal®°
quicki4: xor       ax,ax
         stosb                              ; oznaáen° konce textu
                                          ;* dek¢dov†n° jmÇna souboru
         mov       si,offset outbuf4        ; text jmÇna souboru
         call      rozbor                   ; rozbor jmÇna souboru
         jc        quicki6                  ; chyba zad†n° - dal®° ©†dek
                                          ;* porovn†n° jmÇna s kurzorem
         call      getkurz                  ; adresa souboru s kurzorem
         mov       di,offset rozbflg        ; rozbor jmÇna
         call      cmpfile                  ; porovn†n° specifikac°
         push      cs
         pop       ds
         je        quickl                   ; jmÇno je OK - zobrazen°

quicki6:                                  ;* nalezen° konce ©†dku
         call      zobchnxt                 ; naáten° dal®°ho znaku
         jc        quicki9                  ; nen° jië dal®° znak - konec
         cmp       al,10                    ; je konec ©†dku ?
         jne       quicki6                  ; nalezen° konce ©†dku
         jmp       short quicki2            ; test dal®°ho ©†dku

quicki9:
         ret

quickl1:                                  ;* zobrazen° prvn°ho nepr†zdnÇho ©†dku
         push      dx
         call      quickos                  ; vypustàn° poá†teán°ch oddàlovaáñ
         jc        quickl9                  ; nen° jië dal®° znak - konec
         jne       quickl2                  ; nen° LF - zobrazen° ©†dku
         pop       dx
         jmp       short quickl1            ; je konec ©†dku LF - dal®° ©†dek

public   quickl
quickl:                                   ;* zobrazen° ©†dku ze souboru FILEINFO
                                            ; VSTUP: DX=poá†teán° pozice ©†dku

         push      dx
         call      quickos                  ; vypustàn° poá†teán°ch oddàlovaáñ
         jc        quickl9                  ; nen° jië dal®° znak - konec
         je        quickl9                  ; je konec ©†dku LF - nen° text
quickl2:                                  ;* p©enos textu do bufferu
         mov       cx,38                    ; maxim†ln° poáet znakñ
         mov       di,offset outbuf         ; pracovn° buffer
         push      di
         push      cx
quickl3: jcxz      quickl5
         add       sp,4                     ; zru®en° dat v z†sobn°ku
         push      di                       ; mezi£schova konce textu
         push      cx
quickl4: jcxz      quickl5                  ; jsou jië v®echny znaky
         stosb                              ; uloëen° znaku do bufferu
         dec       cx                       ; sn°ëen° á°taáe znakñ
quickl5: call      zobchnxt                 ; naáten° dal®°ho znaku
         jc        quickl6                  ; konec souboru
         cmp       al,13                    ; je CR ?
         je        quickl4                  ; je CR - nen° platnò znak
         cmp       al," "                   ; je mezera ?
         je        quickl4                  ; je mezera - nen° platnò znak
         cmp       al,9                     ; je tabel†tor ?
         je        quickl4                  ; je tabel†tor - nen° platnò znak
         cmp       al,10                    ; je LF (konec ©†dku) ?
         jne       quickl3                  ; uloëen° platnÇho znaku
quickl6: pop       cx
         pop       di                       ; konec textu v bufferu
         inc       di
;         inc       cx
         xor       ax,ax
         stosb                              ; oznaáen° konce textu
         shr       cx,1                     ; zbylò okraj textu
         add       dl,cl                    ; zvò®en° pozice textu (vyst©edàn°)
                                          ;* zobrazen° textu
         mov       al,1
         call      outch1
         mov       si,offset outbuf
quickl7: lodsb                              ; znak k zobrazen°
         or        al,al                    ; je konec ?
         jz        quickl9                  ; je konec textu
         call      outch10                  ; zobrazen° znaku
         jmp       short quickl7            ; dal®° znak

quickl9: pop       dx
         inc       dh                       ; zvò®en° ©†dku
         ret


                                          ;* vypustàn° oddàlovaáñ
                                            ; VùSTUP: CY=konec souboru
                                            ;         ZY=konec ©†dku

quickos: call      zobchnxt                 ; naáten° dal®°ho znaku
         jc        quickos2                 ; nen° jië dal®° znak - konec
         cmp       al,13                    ; je CR ?
         je        quickos                  ; je CR - ignorov†n°
         cmp       al," "                   ; je mezera ?
         je        quickos                  ; je mezera - ignorov†n°
         cmp       al,9                     ; je tabel†tor ?
         je        quickos                  ; je tabel†tor - ignorov†n°
         cmp       al,10                    ; je konec ©†dku ?
         clc
quickos2:ret

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------
public   zobrazs                            ; zobrazen° disku
zobrazs:

ifdef    upver
         or        byte ptr cs:[parint25],80h ; p©°znak zobrazen° disku
         jmp       short zobrazs2
else
         ret
endif


public   zobraz
zobraz:                                   ;* zobrazen° souboru
                                          ;* test opr†vnànosti poëadavku
         call      testaktw
         jnc       zobraz0
zobraz01:ret                                ; okno nen° zapnuto
zobraz0:
         and       byte ptr cs:[parint25],7fh ; zru®en° p©°znaku zobrazen° disku
zobrazs2:and       byte ptr cs:[conf5],not 0ch; zru®en° p©°znaku adres†©e a FAT
         mov       word ptr cs:[tabhlzob],offset txthlpzo ; n†povàda prohl°ëeáe
         mov       word ptr cs:[inpid],0    ; zru®en° identifik†toru souboru
         and       byte ptr cs:[parint25],not 8 ; zru®en° p©°znaku p©eru®en°
         push      cs
         pop       es                       ; ES <- CS

         mov       si,cs:[bp+4]             ; adresa cesty k adres†©i
         mov       al,cs:[si]               ; oznaáen° disku
         sub       al,40h                   ; p©evod na á°slo disku 1...
         mov       cs:[disk25],al           ; disk pro zobrazen°

         test      byte ptr cs:[parint25],80h ; p©°znak zobrazen° disku
         jnz       zobraz07                 ; je zobrazen° disku

         call      getkurz                  ; soubor s kurzorem
ifndef   upver
         jc        zobraz01                 ; neni zadny soubor
else
         jc        zobraz07                 ; je zobrazen° disku
endif
         test      byte ptr ds:[si],10h     ; je to adres†© ?
ifndef   upver
         jnz       zobraz01                 ; je to adres†© - n†vrat
endif
         jz        zobraz08                 ; nen° to podadres†©

zobraz07:
ifdef    upver
         mov       word ptr cs:[tabhlzob],offset txthlpzo3 ; zobrazen° disku
         call      InitINT25                ; inicializace disku
         jmp       short zobraz09           ; p©eskoáen° inicializace souboru
endif

zobraz08:mov       ax,ds:[si+12]            ; nië®° slovo velikosti
         mov       word ptr cs:[zobnum],ax
         mov       ax,ds:[si+14]            ; vy®®° slovo velikosti
         mov       word ptr cs:[zobnum+2],ax
         lea       di,[outbuf]              ; pomocnò buffer
         call      dekfile                  ; dek¢dov†n° jmÇna souboru

zobraz09:                                 ;* nastaven° velikosti bufferu
         push      cs
         pop       ds                       ; DS <- CS
         mov       ax,ds:[segend]           ; segment konce pamàti
         sub       ax,2                     ; rezerva
         sub       ax,ds:[topseg]           ; voln† pamàü
         jnc       zobraz2                  ; pamàü dostaáuje
zobraz1:                                  ;* chyba - nedostatek pamàti
         lea       si,[erredi2]             ; chybovò text "Nedostatek m°sta"
zobraz4: push      cs
         pop       ds
         call      zobrchyb                 ; zobrazen° chyby
zobrazer:jmp       zobraz9

zobraz2: cmp       ax,1000h                 ; je vàt®° neë 64 KB ?
         jb        zobraz3                  ; nen° vàt®° neë 64 KB
         mov       ax,0fffh                 ; omezen° na 64 KB
zobraz3: mov       cl,4
         shl       ax,cl                    ; voln† kapacita (v bajtech)
         cmp       ax,2000h                 ; minim†ln° kapacita 8 KB
         jb        zobraz1                  ; chyba - nedostatek pamàti
         mov       cs:[editmax],ax          ; £schova velikosti bufferu
                                          ;* otev©en° souboru
         call      aktokna                  ; aktualizace historie oken
         or        byte ptr cs:[parint],10h ; nastaven° p©°znaku zobrazen° F3
         call      msgcek                   ; zobrazen° hl†®en° "áekejte"
         push      cs
         pop       ds
         mov       si,ds:[bp+4]             ; adresa cesty k adres†©i
         call      aktdir                   ; nastaven° aktivn°ho adres†©e
         jc        zobraz9                  ; chyba operace
         test      byte ptr cs:[parint25],80h ; je zobrazen° disku ?
         jnz       zobraz7                  ; je zobrazen° disku
         lea       dx,[outbuf]              ; jmÇno souboru
         push      cs
         pop       ds
         mov       ax,3d00h                 ; otev©en° souboru pro áten°
         int       21h                      ; otev©en° souboru
         lea       si,[erroper]             ; text chyby
         jc        zobraz9                  ; chyba operace
         mov       ds:[inpid],ax            ; identifik†tor souboru
         mov       bx,ax                    ; identifik†tor souboru

zobraz7: call      zobred                   ; obsluha prohl°ëen° souboru

zobraz8:
         mov       bx,ds:[inpid]            ; identifik†tor souboru
         or        bx,bx                    ; je platnò identifik†tor ?
         jz        zobraz9                  ; nen° platnò identifik†tor
         mov       ah,3eh                   ; funkce uzav©en° souboru
         int       21h                      ; uzav©en° souboru

zobraz9: pushf
         and       byte ptr cs:[parint],0efh ; zru®en° p©°znaku zobrazen° F3
         mov       word ptr cs:[editnum],0  ; zru®en° dat v pamàti
         popf
         push      cs
         pop       ds
         jnc       zobraz9e                 ; operace OK
         call      aktuald                  ; aktualizace obsahu disku
zobraz9e:
         call      windret                  ; n†vrat zobrazen° oken
;         call      obrcomm                  ; zobrazen° p©°kazovÇho ©†dku
         call      outhelp                  ; zobrazen° n†povàdy
         ret

zobraz6: mov       bx,ds:[inpid]            ; identifik†tor souboru
         mov       ah,3eh                   ; funkce uzav©en° souboru
         int       21h                      ; uzav©en° souboru
         lea       si,[erroper]             ; text chyby
         jmp       zobraz4


; -----------------------------------------------------------------------------
public   zobred

zobred:                                   ;* obsluha prohl°ëen° souboru

         mov       word ptr cs:[edikey],0   ; zru®en° znaku v bufferu
         mov       word ptr cs:[toppoz],0   ; poá†teán° pozice ©†dku
;         mov       byte ptr cs:[citachod],0 ; nastaven° hodin
         call      zobtopini                ; inicializace horn°ho ©†dku
         call      zobhlp0                  ; zobrazen° n†povàdy
         test      byte ptr cs:[parint25],80h ; je zobrazen° disku ?
         jnz       zobred00                 ; je zobrazen° disku
         call      zobcpgup1                ; nastaven° na zaá†tek souboru
zobred00:call      zobcpgup2
zobred1: mov       word ptr cs:[parbreak],0 ; zru®en° p©°znaku chyby
         push      cs
         pop       ds
         push      cs
         pop       es

         call      zoball                   ; zobrazen° v®ech ©†dkñ
         call      kurzout                  ; vypnut° kurzoru
         mov       al,27
         test      byte ptr cs:[parint25],8 ; je p©eru®en° funkce ?
         jnz       zobred2                  ; je p©eru®en° funkce

         call      inpkeyz                  ; vstup znaku pro zobrazov†n°

zobred2: cmp       al,27                    ; Esc
         je        zobred9
         cmp       ah,44h                   ; F10
         je        zobred9

         lea       bx,[skokzob]             ; tabulka skokñ obsluhy zobrazen°
         call      skokax
         jmp       short zobred1


zobred9: ret



public   inpkeyz
inpkeyz:                                  ;* vstup znaku pro zobrazov†n°

         call      mouseget                 ; vstup z my®i
         jz        inpkeyz4                 ; nen° tlaá°tko
         call      mousemen                 ; funkán° kl†vesy
         jnc       inpkeyz6                 ; je funkán° kl†vesa
                                          ;* test kl†vesy ESC
         mov       ax,011bh                 ; ESC
         cmp       bl,11                    ; uvolnàn° pravÇho tlaá°tka ?
         je        inpkeyz6                 ; je ESC

         call      getpocl                  ; poáet ©†dkñ CX
         inc       cx
;         call      testakth                 ; je n†povàda aktivn° ?
;         jc        inpkeyz1                 ; n†povàda nen° aktivn°
         cmp       byte ptr cs:[mousepoz+1],cl ; je posledn° ©†dek ?
         jae       inpkeyz4                 ; posledn° ©†dek - neplat°

         shr       cl,1
         mov       ch,cl
         shr       ch,1
         shr       ch,1
;inpkeyz1:
         cmp       bl,1                     ; drë° se levÇ tlaá°tko ?
         jne       inpkeyz4                 ; nen° levÇ tlaá°tko
                                          ;* test kl†vesy posunu nahoru
         mov       ax,4800h                 ; kurzor nahoru
         sub       cl,ch                    ; horn° polovina
         cmp       byte ptr cs:[mousepoz+1],cl ; je horn° á†st obrazovky ?
         jb        inpkeyz6                 ; je horn° á†st obrazovky
                                          ;* test kl†vesy posunu dolñ
         add       cl,ch
         add       cl,ch
         mov       ax,5000h                 ; kurzor dolñ
         cmp       byte ptr cs:[mousepoz+1],cl ; je doln° á†st obrazovky ?
         ja        inpkeyz6                 ; je doln° á†st obrazovky

inpkeyz4:lea       si,[tabhlzob]
         call      modihlp                  ; modifikace n†povàdy
         cmp       word ptr cs:[edikey],0   ; je nàjakò znak v bufferu ?
         jne       inpkeyz5                 ; v bufferu je nàjakò znak
         call      testkey                  ; je p©ipraven znak ?
         jz        inpkeyz                  ; áek†n° na p©°chod znaku
inpkeyz5:;lea       si,[tabhlzob]
         call      inpkeyf                  ; vstup znaku s vyprazd§ov†n°m
inpkeyz6:ret



skokzob  label     word                     ; obsluha zobrazen°

         db        40h+26                   ; testuje se AH
         db        50h                      ; kurzor dolñ DOWN
         dw        offset zobdown
         db        48h                      ; kurzor nahoru UP
         dw        offset zobup
         db        4bh                      ; kurzor vlevo LEFT
         dw        offset zobleft
         db        4dh                      ; kurzor vpravo RIGHT
         dw        offset zobright
         db        73h                      ; kurzor vlevo ^LEFT
         dw        offset zobcleft
         db        74h                      ; kurzor vpravo ^RIGHT
         dw        offset zobcright
         db        91h                      ; kurzor dolñ ^DOWN
         dw        offset zobcdown
         db        8dh                      ; kurzor nahoru ^UP
         dw        offset zobcup
         db        49h                      ; str†nka nahoru PAGE UP
         dw        offset zobpgup
         db        51h                      ; str†nka dolñ PAGE DOWN
         dw        offset zobpgdn
         db        84h                      ; zaá†tek souboru ^PAGE UP
         dw        offset zobcpgup
         db        76h                      ; konec souboru ^PAGE DOWN
         dw        offset zobcpgdn
         db        47h                      ; zaá†tek souboru Home
         dw        offset zobcpgup
         db        4fh                      ; konec souboru End
         dw        offset zobcpgdn
         db        3ch                      ; p©epnut° zobrazen° WRAP (F2)
         dw        offset zobsetwrp
         db        3dh                      ; p©epnut° zobrazen° ASCII/HEX (F3)
         dw        offset zobxchg
         db        3eh                      ; p©epnut° zobrazen° Ctrl- (F4)
         dw        offset zobsetct
         db        3fh                      ; p©epnut° zobrazen° tabel†torñ (F5)
         dw        offset zobsetta
         db        40h                      ; skok na zadanò blok F6
         dw        offset skokclust
         db        41h                      ; vyhled†v†n° textu F7
         dw        offset zobfind
         db        5ah                      ; pokraáov†n° v hled†n° SHIFT-F7
         dw        offset zobfindn
         db        42h                      ; zobrazen° FAT tabulek F8
         dw        offset zobfat
         db        43h                      ; zobrazen° disku F9
         dw        offset zobdisk
         db        3bh                      ; n†povàda F1
         dw        offset help
         db        54h                      ; n†povàda Shift-F1
         dw        offset althelp
         db        5dh                      ; ©†dkov†n° EGA 43 Shift-F10
         dw        offset zobega43

         db        00h+4                    ; testuje se AL
         db        02h                      ; p©epnut° n†povàdy ^B
         dw        offset zobhelp
         db        09h                      ; p©epnut° zobrazen° TAB
         dw        offset zobxchg
         db        0ch                      ; pokraáov†n° v hled†n° ^L
         dw        offset zobfindn
         db        11h                      ; hled†n° textu ^QF
         dw        offset zobfindq

         db        80h+1
         dw        0f00h                    ; p©epnut° zobrazen° SHIFT-TAB
         dw        offset zobxchg

         db        0

; -----------------------------------------------------------------------------
public   zobcleft
zobcleft:                                  ;* posun vlevo

IFDEF    upver
         test      byte ptr cs:[ediflag],20h; je zobrazen° HEX ?
         jnz       zobcrig2                 ; je zobrazen° HEX
         test      byte ptr cs:[conf5],4    ; je zobrazen° adres†©e ?
         jnz       zobcrig2                 ; je zobrazen° adres†©e
         cmp       word ptr ds:[toppoz],8   ; je jië zaá†tek ©†dku ?
         jb        zobleft2                 ; je jië zaá†tek ©†dku
         sub       word ptr ds:[toppoz],80  ; sn°ëen° poá†tku ©†dku
         jnc       zobcleft1
         mov       word ptr ds:[toppoz],0
zobcleft1:mov       bh,80h                   ; p©°znak p©ekreslen° obrazovky
ENDIF

zobcleft2:ret
; -----------------------------------------------------------------------------
public   zobcright
zobcright:                                 ;* posun kurzoru vpravo

IFDEF    upver
         test      byte ptr cs:[ediflag],20h; je zobrazen° HEX ?
         jnz       zobcrig2                 ; je zobrazen° HEX
         test      byte ptr cs:[conf5],4    ; je zobrazen° adres†©e ?
         jnz       zobcrig2                 ; je zobrazen° adres†©e
         add       word ptr ds:[toppoz],80  ; zvò®en° poá†tku ©†dku
         mov       bh,80h
ENDIF

zobcrig2:ret
; -----------------------------------------------------------------------------
public   zobleft
zobleft:                                  ;* posun vlevo

IFDEF    upver
         test      byte ptr cs:[ediflag],20h; je zobrazen° HEX ?
         jnz       zobcrig2                 ; je zobrazen° HEX
         test      byte ptr cs:[conf5],0ch  ; je zobrazen° adres†©e nebo FAT ?
         jnz       zobcrig2                 ; je zobrazen° adres†©e
         cmp       word ptr ds:[toppoz],8   ; je jië zaá†tek ©†dku ?
         jb        zobleft2                 ; je jië zaá†tek ©†dku
         sub       word ptr ds:[toppoz],8   ; sn°ëen° poá†tku ©†dku
         mov       bh,80h                   ; p©°znak p©ekreslen° obrazovky
ENDIF

zobleft2:ret
; -----------------------------------------------------------------------------
public   zobright
zobright:                                 ;* posun kurzoru vpravo

IFDEF    upver
         test      byte ptr cs:[ediflag],20h; je zobrazen° HEX ?
         jnz       zobcrig2                 ; je zobrazen° HEX
         test      byte ptr cs:[conf5],0ch  ; je zobrazen° adres†©e nebo FAT ?
         jnz       zobcrig2                 ; je zobrazen° adres†©e
         add       word ptr ds:[toppoz],8   ; zvò®en° poá†tku ©†dku
         mov       bh,80h
ENDIF
         ret
; -----------------------------------------------------------------------------
public   zobsetwrp
zobsetwrp:                                ;* p©epnut° zobrazen° WRAP (F2)
IFDEF    upver
         test      byte ptr cs:[ediflag],20h; je zobrazen° HEX ?
         jnz       zobcrig2                 ; je zobrazen° HEX
         test      byte ptr cs:[conf5],4    ; je zobrazen° adres†©e ?
         jnz       zobcrig2                 ; je zobrazen° adres†©e
         xor       byte ptr ds:[conf5],1    ; zmàna p©°znaku zalamov†n° WRAP
         mov       bh,80h
ENDIF
         ret
; -----------------------------------------------------------------------------
public   zobega43
zobega43:                                 ;* zmàna zobrazen° ©†dkov†n° EGA 43

         call      egaset                   ; zmàna zobrazen°
         call      windret
         mov       bh,80h
zobega4q:ret

; -----------------------------------------------------------------------------
public   zobfind,zobfindn,zobfindq

zobfindq:                                 ;* hled†n° textu ^QF
         call      inpkeyf                  ; vstup znaku s vyprazd§ov†n°m
         or        al,60h                   ; p©evod na velkÇ p°smeno
         cmp       al,"f"
         jne       zobega4q                 ; nen° ^QF

zobfind:                                  ;* nalezen° textu ^QF,F7

         mov       word ptr ds:[bufhlde],132 ; nastaven° dÇlky bufferu
         mov       byte ptr ds:[bufhlde2],0 ; poáet p©edvoleb = 0
         lea       di,[txtedi7]             ; nadpis "Zadejte hledanò text:"
         lea       si,[bufhlde]             ; buffer voleb
         call      select                   ; proveden° volby
         jnc       zobfind0                 ; zad†n° OK
zobfind3:jmp       zobfind6                 ; operace p©eru®ena
zobfind0:
         mov       di,offset findstr        ; buffer k uschov†n° ©etàzce
         call      transtxt                 ; £schova hledanÇho ©etàzce

zobfindn:                                 ;* pokraáov†n° v hled†n° ^L, SHIFT-F7
         call      zobgett                  ; vrchol obrazovky
         call      zobsetk                  ; nastaven° kurzoru

         mov       si,offset findstr        ; hledanò ©etàzec
         cmp       byte ptr ds:[si],0       ; je zad†n nàjakò text ?
         je        zobfind3                 ; nebyl zad†n ë†dnò text
         mov       di,si
         mov       cx,128
         push      cs
         pop       es
         xor       al,al                    ; ukonáovac° bajt
         repnz     scasb
         mov       al,127
         sub       al,cl
         xor       dx,dx
         mov       dl,al                    ; £schova dÇlky textu
         or        al,al                    ; je nàjakò text ?
         jnz       zobfnd11
         jmp       zobfind6                 ; nen° ë†dnò text
                                          ;* p©eveden° textu na velk† p°smena
zobfnd11:push      si                       ; adresa ©etàzce
         push      si
         pop       di
         mov       cx,dx                    ; dÇlka textu
zobfind1:lodsb
         call      highcase                 ; p©evod na velkÇ p°smeno
         stosb
         loop      zobfind1                 ; dal®° znak
         pop       si                       ; adresa ©etàzce

         push      ax
         push      dx
         mov       al,3
         call      outch
         xor       dx,dx
         mov       al,"*"
         call      outch1                   ; indik†tor hled†n°
         call      outch1                   ; indik†tor hled†n°
         pop       dx
         pop       ax

         call      kurzout                  ; vypnut° kurzoru
                                          ;* nalezen° textovÇho ©etàzce
         push      cs
         pop       ds
         push      cs
         pop       es
zobfind2:
         call      zobchnxt                 ; dal®° znak
         jc        zobfind7                 ; konec textu
         dec       dh                       ; á°taá pro zobrazen° ukazatele
         jnz       zobfnd25
                                          ;* zobrazen° ukazatele
         call      zobtopl                  ; zobrazen° ukazatele
         call      testbreak                ; je p©eru®en° ?
         jc        zobfind7                 ; je p©eru®en°

zobfnd25:push      word ptr cs:[zobukaz]
         push      word ptr cs:[zobukaz+2]
         push      si
         mov       cl,dl                    ; dÇlka textu
         xor       ch,ch
zobfind4:inc       si
         call      zobchnxt
         jc        zobfnd42
         call      highcase                 ; p©evod na velkÇ p°smeno
         cmp       byte ptr ds:[si-1],"?"   ; kontroluje se znak ?
         je        zobfind5                 ; znak se nekontroluje
         cmp       al,ds:[si-1]             ; porovn†n° s hledanòm znakem
zobfind5:loopz     zobfind4                 ; p©i shodà test dal®°ho znaku
         clc
zobfnd42:pop       si
         pop       word ptr cs:[zobukaz+2]
         pop       word ptr cs:[zobukaz]

         jc        zobfind7                 ; konec souboru
         jne       zobfind2
                                          ;* nastaven° kurzoru

         pushf
         push      ax
         push      dx
         mov       al,3
         call      outch
         xor       dx,dx
         mov       al," "
         call      outch1                   ; vymaz†n° indik†toru hled†n°
         call      outch1                   ; vymaz†n° indik†toru hled†n°
         pop       dx
         pop       ax
         popf


         call      zobgetk
         call      zobsett
         jmp       short zobfind6           ; text nalezen

zobfind7:                                 ;* ©etàzec nenalezen

         pushf
         push      ax
         push      dx
         mov       al,3
         call      outch
         xor       dx,dx
         mov       al," "
         call      outch1                   ; vymaz†n° indik†toru hled†n°
         call      outch1                   ; vymaz†n° indik†toru hled†n°
         pop       dx
         pop       ax
         popf

         mov       word ptr cs:[editnum],0  ; poáet bajtñ v bufferu = 0
         call      zobgett                  ; poskytnut° adresy zaá†tku
         mov       word ptr cs:[zobbuf],ax  ; zaá†tek bufferu
         mov       word ptr cs:[zobbuf+2],dx

         push      cs
         pop       ds
         push      cs
         pop       es
         mov       bh,80h                   ; p©°znak p©ekreslen° obrazovky
         call      zoball                   ; zobrazen° text obrazovky
         lea       di,[outbuf]
         push      di
         lea       si,[erredi3]             ; text "Hledanò text"
         call      transtxt                 ; p©enos textu
         mov       si,offset findstr        ; adresa ©etàzce
         call      lensi                    ; dÇlka textu
         cmp       al,30                    ; je del®° text neë 20 znakñ ?
         jb        zobfind8                 ; je men®° neë 30 znakñ
         mov       al,30
zobfind8:mov       cl,al                    ; dÇlka textu
         xor       ch,ch                    ; CH <- 0
         rep       movsb                    ; p©enos textu
         lea       si,[erredi4]             ; text "nenalezen !"
         call      transtxt
         pop       di                       ; text hl†®en°
         lea       si,[txtchyb1]            ; volba OK
         xor       al,al                    ; p©edvolen† poloëka
         call      volbyh                   ; zobrazen° hl†®en°
zobfind6:call      zobhlp0                  ; zobrazen° n†povàdy
         mov       bh,80h                   ; p©°znak p©ekreslen° obrazovky
         ret

; -----------------------------------------------------------------------------
public   zobfat
zobfat:                                   ;* zobrazen° FAT tabulek disku F8

ifdef    upver

         test      byte ptr ds:[parint25],80h ; je jië zobrazen° disku ?
         jz        zobfat2                  ; nen° zobrazen° disku
         xor       byte ptr cs:[conf5],8    ; p©°znak FAT tabulky
;         jnz       zobfat1                  ; je jië zobrazen° disku

         test      byte ptr cs:[conf5],8
         jz        zobfat1                  ; nen° zobrazen° FAT

;         call      zobcpgup1                ; inicializace ukazatelñ
;         call      InitINT25                ; inicializace disku
;         or        byte ptr cs:[conf5],8    ; p©°znak FAT tabulky
         xor       ax,ax
         mov       word ptr cs:[zobbuf+2],ax
         mov       word ptr cs:[zobtop+2],ax
         mov       word ptr cs:[toppoz],ax
         mov       cs:[editnum],ax          ; poáet bajtñ v bufferu = 0
         mov       ax,cs:[bajtsekt]         ; poáet bajtñ na sektor
         mov       word ptr cs:[zobbuf],ax  ; nië®° slovo offsetu
         mov       word ptr cs:[zobtop],ax  ; adresa zaá†tku zobrazenÇho textu

zobfat1: and       byte ptr cs:[conf5],not 4;zru®en° p©°znaku DIR
         call      zobtopini                ; inicializace horn°ho ©†dku
         mov       bh,80h
endif
zobfat2: ret
; -----------------------------------------------------------------------------
public   zobdisk
zobdisk:                                  ;* zobrazen° disku F9

ifdef    upver
zobdisk0:test      byte ptr ds:[parint25],80h ; je jië zobrazen° disku ?
         jz        zobdisk2                 ; nen° zobrazen° disku
         xor       byte ptr cs:[conf5],4    ; p©°znak adres†©e F6
;         jnz       zobdisk1                 ; je jië zobrazen° disku

;         call      zobcpgup1                ; inicializace ukazatelñ
;         call      InitINT25                ; inicializace disku
zobdisk1:and       byte ptr cs:[conf5],not 8; zru®en° p©°znaku FAT tabulky
         call      zobtopini                ; inicializace horn°ho ©†dku
         mov       bh,80h
endif
zobdisk2:ret
; -----------------------------------------------------------------------------
public   zobxchg

zobxchg:                                  ;* p©epnut° zobrazen° TAB

         test      byte ptr cs:[conf5],0ch  ; je zobrazen° adres†©e ?
         jnz       zobxchg2                 ; je zobrazen° adres†©e - vypnut°
         xor       byte ptr cs:[ediflag],20h ; zmàna p©°znaku HEX
zobxchg2:and       byte ptr cs:[conf5],not 0ch; zru®en° p©°znakñ DIR a FAT
         mov       bh,80h
         ret
; -----------------------------------------------------------------------------
public   zobsetta

zobsetta:                                 ;* zmàna zobrazen° tabel†torñ (F5)
         xor       byte ptr cs:[ediflag],10h
         mov       bh,80h
         ret

; -----------------------------------------------------------------------------
public   zobsetct

zobsetct:                                 ;* zmàna zobrazen° Ctrl- (F4)

         xor       byte ptr cs:[config],4   ; zmàna p©°znaku Ctrl-
         mov       bh,80h
         ret

; -----------------------------------------------------------------------------
public   zobhelp,zobhlp0

zobhelp:                                  ;* p©epnut° zobrazen° n†povàdy ^B

         xor       byte ptr cs:[flags],4    ; zmàna p©°znaku n†povàdy
zobhlp0: call      testakth                 ; je n†povàda aktivn° ?
         jc        zobhlp2                  ; n†povàda nen° aktivn°
         push      ds
         push      cs
         pop       ds
         push      si

         lea       si,[txthlpzo]            ; n†povàda zobrazen°

ifdef    upver
         test      byte ptr ds:[parint25],80h ; je zobrazen° disku ?
         jz        zobhlp3                  ; nen° zobrazen° disku
         mov       si,offset txthlpzo3      ; n†povàda pro disk
endif

zobhlp3: call      outthlp                  ; zobrazen° n†povàdy
         pop       si
         pop       ds
zobhlp2: mov       bh,80h                   ; p©°znak p©episu okna
         ret

; -----------------------------------------------------------------------------
public   zobtopini

zobtopini:                                ;* inicializace horn°ho ©†dku

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es
         push      cs
         pop       ds
         push      cs
         pop       es
         call      mouseoff                 ; vypnut° my®i
         mov       al,3                     ; barva 3
         call      outch1                   ; nastaven° barvy
                                          ;* vymaz†n° horn°ho ©†dku
         xor       dx,dx                    ; poá†teán° pozice
         mov       al," "                   ; mazac° znak
         mov       cx,71                    ; poáet znakñ k tisku
         call      outch                    ; vymaz†n° ©†dku
                                          ;* zobrazen° oddàlovaáñ pol°
         mov       al,179                   ; oddàlovaá pole
         mov       dx,2
         call      outch1
         mov       dl,15
         call      outch1
         mov       dl,29
         call      outch1
         mov       dl,59
         call      outch1
         mov       dl,70
         call      outch1
         mov       dl,79
         call      outch1
                                          ;* zobrazen° jmÇna souboru
         lea       di,[outbuf]              ; pracovn° buffer
         push      di
         mov       si,cs:[bp+4]             ; adresa cesty k adres†©i
         mov       ax,cs:[si]               ; oznaáen° disku
         stosw
         xor       ax,ax
         stosb
         test      byte ptr cs:[parint25],80h
         jnz       zobtin8
         pop       di
         push      di
         call      getkurz                  ; poskytnut° editovanÇho souboru
         call      dekfile                  ; dek¢dov†n° jmÇna souboru
zobtin8: pop       si
         push      cs
         pop       ds
         mov       dx,3
         call      outtxt                   ; zobrazen° jmÇna souboru
         mov       dx,16

         mov       byte ptr ds:[citachod],0 ; nastaven° hodin

IFDEF    upver
         mov       si,offset txtedi3
         call      outtxt

         test      byte ptr ds:[parint25],80h ; je zobrazen° disku ?
         jz        zobtin5                  ; nen° zobrazen° disku
                                          ;* zobrazen° alok. bloku a sektoru
         mov       si,offset txtzob5
         mov       dx,30
         call      outtxt
         mov       al,179                   ; oddàlovaá pole
         mov       dx,41
         call      outch1
         mov       si,offset txtzob6
         call      outtxt

zobtin5:

ENDIF

         xor       ax,ax
         mov       word ptr ds:[blokuk],ax
         mov       word ptr ds:[blokuk+2],ax ; vynulov†n° velikosti ukazatele
                                          ;* vòpoáet dÇlky ukazatele
         mov       ax,word ptr cs:[zobnum]  ; velikost souboru - nië®° slovo
         mov       dx,word ptr cs:[zobnum+2]; velikost souboru - vy®®° slovo
         push      ax
         push      dx
         xor       bh,bh                    ; á°taá znakñ ukazatele
zobtin1: or        dx,dx                    ; je vy®®° slovo jië 0 ?
         jnz       zobtin2                  ; nen° vy®®° slovo = 0
         cmp       ax,3                     ; je á°slo men®° nebo rovno 3 ?
         jbe       zobtin3                  ; je jië á°slo men®° nebo rovno 3
zobtin2: shr       dx,1                     ; DX / 2
         rcr       ax,1                     ; velikost / 2
         add       bh,4                     ; zvò®en° dÇlky o 4 znaky
         jmp       short zobtin1            ; dal®° test
zobtin3: add       bh,al                    ; celkov† ®°©ka (znakñ)
         sub       bh,32                    ; odeáten° poá†tku pro 512 bajtñ
         jc        zobtin32                 ; je men®°
         cmp       bh,4
         jae       zobtin31                 ; je vàt®° neë 512 bajtñ
zobtin32:mov       bh,4                     ; n†hradn° dÇlka
zobtin31:mov       bl,29                    ; maxim†ln° dÇlka
         cmp       bh,bl                    ; je vàt®° neë povolen† dÇlka ?
         ja        zobtin4                  ; je vàt®°
         mov       bl,bh                    ; omezen° na vypoátenou velikost
zobtin4:                                  ;* vòpoáet parametrñ ukazatele
         pop       ax                       ; velikost souboru - vy®®° slovo
         pop       cx                       ; velikost souboru - nië®° slovo
         xor       dx,dx
         xor       bh,bh
         div       bx                       ; vòpoáet vy®®°ho slova bloku
         xchg      ax,cx                    ; £schova vy®®°ho slova bloku
         div       bx                       ; vòpoáet nië®°ho slova bloku
         mov       word ptr ds:[blokuk],ax
         mov       word ptr ds:[blokuk+2],cx; uloëen° velikosti ukazatele
         or        ax,cx                    ; je povoleno zobrazen° ?
         jz        zobtin6                  ; zobrazen° nen° povoleno
                                          ;* nastaven° ukazatele
         mov       dl,79                    ; konec zobrazen°
         sub       dl,bl                    ; poá†teán° pozice zobrazen°
         shr       dl,1                     ; vyst©edàn° ukazatele
         add       dl,5                     ; posun vpravo
         mov       ds:[poziceuk],dl         ; poá†teán° pozice ukazatele
         mov       ds:[delkauk],bl          ; £schova dÇlky ukazatele
zobtin6:
                                          ;* zobrazen° velikosti souboru
         push      cs
         pop       es
         push      cs
         pop       ds
;         lea       di,[outbuf]              ; pracovn° buffer
;         push      di
         mov       dx,60
         mov       ax,word ptr cs:[zobnum]  ; velikost souboru - nië®° slovo
         mov       bx,word ptr cs:[zobnum+2]; velikost souboru - vy®®° slovo
         call      tisknm0
;         call      deknum                   ; dek¢dov†n° á°sla
;         lea       si,[texthlpb+1]          ; text "bajt"
;         call      transtxt
;         pop       si
;         push      si
;         call      setkonc                  ; nastaven° koncovky
;         pop       si
;         mov       dx,65
;         mov       dx,58                    ; pozice pro zobrazen°
;         call      outtxt                   ; zobrazen° velikosti souboru
         call      mouseon                  ; zapnut° my®i
         pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   zobtopl

zobtopl:                                  ;* zobrazen° horn°ho ©†dku

         call      mouseoff                 ; vypnut° my®i
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      ds
         push      es
         push      cs
         pop       ds
         push      cs
         pop       es

IFDEF    upver
                                          ;* zobrazen° pozice ©†dku
         mov       al,3                     ; barva 3
         call      outch1                   ; nastaven° barvy
;         mov       dx,23                    ; poá†teán° pozice
;         mov       al," "                   ; mazac° znak
;         mov       cx,6                     ; poáet znakñ k tisku
;         call      outch                    ; vymaz†n°
         lea       di,[outbuf]              ; pracovn° buffer
         push      di
         call      setspc                   ; nastaven° m¢du tisku mezer
         mov       ax,word ptr cs:[toppoz]  ; pozice ©†dku
         xor       dx,dx
         call      deknum5                  ; dek¢dov†n° á°sla
         call      setfre                   ; nastaven° volnÇho form†tu
         pop       si
         mov       dx,23                    ; pozice pro zobrazen°
         call      outtxt                   ; zobrazen° velikosti souboru
         test      byte ptr ds:[parint25],80h ; je zobrazen° disku ?
         jz        zobtuk4                  ; nen° zobrazen° disku
                                          ;* zobrazen° alok. bloku a sektoru
         mov       bx,word ptr cs:[zobtop]  ; adresa zaá†tku zobrazenÇho textu
         mov       ax,word ptr cs:[zobtop+2]; vy®®° slovo adresy
         xor       dx,dx
         div       word ptr cs:[bajtsekt]   ; á°slo sektoru - vy®®° slovo
         xchg      ax,bx                    ; ukazatel dat - nië®° slovo
         div       word ptr cs:[bajtsekt]   ; á°slo sektoru - nië®° slovo
         push      ax
         push      bx
         mov       dx,49                    ; pozice pro zobrazen° sektoru
         call      tisknm0
         pop       dx
         pop       ax
         sub       ax,cs:[rezervs]          ; odeáten° rezervovanòch sektorñ
         sbb       dx,0                     ; p©enos
         jnc       zobtuk3                  ; nen° podteáen°
         mov       si,offset txtzob7        ; text "ROOT"
         add       ax,cs:[rezervs]          ; n†vrat á°sla sektoru
         jz        zobtuk5
         mov       si,offset txtzob9        ; text "ROOT"
         cmp       ax,cs:[sektroot]         ; je sektor ROOT ?
         jae       zobtuk5                  ; je sektor ROOT
         mov       si,offset txtzob8        ; text "FAT"
         dec       ax
         div       byte ptr cs:[sektfat]    ; vòpoáet á°sla FAT
         add       al,"1"
         mov       ds:[si+5],al
         jmp       short zobtuk5
zobtuk3:
         xor       cx,cx
         mov       cl,cs:[sektclus]         ; poáet sektorñ na blok
         div       cx
         xor       dx,dx                    ; zbytek nezaj°mavò
         add       ax,2
         lea       di,[outbuf]              ; pracovn° buffer
         push      di
         call      setspc                   ; nastaven° m¢du tisku mezer
         call      deknum5                  ; dek¢dov†n° á°sla
         call      setfre                   ; nastaven° volnÇho form†tu
         pop       si
zobtuk5: mov       dx,35                    ; pozice pro zobrazen°
         call      outtxt                   ; zobrazen° velikosti souboru
         jmp       short zobtuk6
ENDIF

zobtuk4: mov       ax,word ptr ds:[blokuk]  ; nië®° slovo velikosti bloku
         or        ax,word ptr ds:[blokuk+2]; vy®®° slovo velikosti bloku
         jz        zobtuk6                  ; zobrazen° nen° povoleno
                                          ;* zobrazen° podkladu
         xor       dh,dh                    ; ©†dek pro zobrazen° ukazatele
         xor       ch,ch
         mov       dl,cs:[poziceuk]         ; pozice ukazatele
         mov       cl,cs:[delkauk]          ; dÇlka zobrazen° ukazatele
         mov       al,3                     ; barva
         call      outch1                   ; nastaven° barvy
         mov       al,0b0h                  ; podklad ukazatele
         call      outch                    ; zobrazen° podkladu ukazatele
                                          ;* vòpoáet pozic blokñ
         call      zobgett                  ; poskytnut° adresy zaá†tku
         call      zobtukb                  ; vòpoáet á°sla bloku ukazatele
         cmp       ch,cs:[delkauk]
         jb        zobtuk53
         mov       ch,cs:[delkauk]
         dec       ch
zobtuk53:mov       ch,cl                    ; £schova á°sla bloku
         call      zobgetk                  ; poskytnut° adresy konce
         call      zobtukb                  ; vòpoáet á°sla bloku konce
         sub       cl,ch                    ; ®°©ka ukazatele
         inc       cl                       ; ®°©ka ukazatele
         jns       zobtuk54
         mov       cl,1
Zobtuk54:mov       dl,ch                    ; offset prvn°ho bloku
                                          ;* zobrazen° ukazatele
         add       dl,ds:[poziceuk]         ; poá†teán° pozice ukazatele
         xor       dh,dh                    ; ©†dek pro zobrazen°
         xor       ch,ch
         mov       al,0b2h                  ; znak ukazatele
         call      outch                    ; zobrazen° ukazatele
         call      kurzout                  ; vypnut° kurzoru
zobtuk6: pop       es
         pop       ds
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         call      mouseon                  ; zapnut° my®i
         ret

                                          ;* p©epoáet ukazatele na á°slo bloku
zobtukb:                                    ; VSTUP: DX:AX=adresa ukazatele
                                            ; VùSTUP: CL=á°slo bloku

         push      ax
         push      dx
         xor       cl,cl                    ; á°taá blokñ
zobtukb2:inc       cl                       ; zvò®en° á°taáe blokñ
         sub       ax,word ptr cs:[blokuk]  ; nië®° slovo
         sbb       dx,word ptr cs:[blokuk+2]; vy®®° slovo
         jnc       zobtukb2                 ; dal®° blok
         cmp       cl,cs:[delkauk]          ; p©ekroáena dÇlka ?
         jbe       zobtukb3
         mov       cl,cs:[delkauk]
zobtukb3:dec       cl
         pop       dx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   zobcpgup

zobcpgup:                                 ;* zaá†tek souboru ^PAGE UP

         xor       ax,ax
         cmp       ax,word ptr cs:[zobtop+2]
         jne       zobcpgup1
         cmp       ax,word ptr cs:[zobtop]
         jne       zobcpgup1
         cmp       ax,word ptr cs:[toppoz]
         jne       zobcpgup1
         ret

zobcpgup1:xor      ax,ax
         mov       word ptr cs:[zobbuf],ax  ; zaá†tek bufferu
         mov       word ptr cs:[zobbuf+2],ax
         mov       word ptr cs:[zobtop],ax  ; adresa zaá†tku zobrazenÇho textu
         mov       word ptr cs:[zobtop+2],ax
zobcpgup2:xor      ax,ax
         mov       word ptr cs:[toppoz],ax
         mov       cs:[editnum],ax          ; poáet bajtñ v bufferu = 0
         mov       bh,80h                   ; p©epsat v®echny ©†dky
         ret

; -----------------------------------------------------------------------------
public   zobcpgdn

zobcpgdn:                                 ;* konec souboru ^PAGE DOWN

         mov       ax,word ptr cs:[zobnum]  ; poáet bajtñ v souboru
         mov       dx,word ptr cs:[zobnum+2]
zobcpgdn3:call      zobsett                  ; nastaven° poá†tku pro zobrazen°
         mov       word ptr cs:[zobbuf],ax  ; zaá†tek bufferu
         mov       word ptr cs:[zobbuf+2],dx
         mov       word ptr cs:[editnum],0  ; vynulov†n° pamàti
         mov       word ptr cs:[toppoz],0
zobcpgdn2:                                ;* n†vrat o str†nku nahoru
         push      cx
         call      getpocl
         dec       cx                      ; poáet ©†dkñ k rotaci
         jmp       short zobpgup1

; -----------------------------------------------------------------------------
public   zobcdown

zobcdown:                                 ;* 6 ©†dkñ dolñ ^DOWN
         push      cx
         mov       cx,6                     ; poáet ©†dkñ k posunu
zobcdn1: call      zobdown                  ; posun o ©†dek dolñ
         jc        zobcdn2                  ; konec souboru
         loop      zobcdn1
zobcdn2: pop       cx
         ret

; -----------------------------------------------------------------------------
public   zobcup

zobcup:                                   ;* 6 ©†dkñ nahoru ^UP
         push      cx
         mov       cx,6                     ; poáet ©†dkñ k rotaci
zobcup1: call      zobup                    ; posun o ©†dek nahoru
         jc        zobcup2                  ; zaá†tek souboru
         loop      zobcup1
zobcup2: pop       cx
         ret

; -----------------------------------------------------------------------------
public   zobpgdn

zobpgdn:                                  ;* str†nka dolñ PAGE DOWN
         push      cx
         call      getpocl
         dec       cx
;         mov       cx,21                    ; poáet ©†dkñ k rotaci
zobpgdn1:call      zobdown                  ; posun o ©†dek dolñ
         jc        zobpgdn2                 ; konec souboru
         loop      zobpgdn1
zobpgdn2:pop       cx
         ret

; -----------------------------------------------------------------------------
public   zobpgup

zobpgup:                                  ;* str†nka nahoru PAGE UP
         push      cx
         call      getpocl
         dec       cx
;         mov       cx,21                    ; poáet ©†dkñ k rotaci
zobpgup1:call      zobup                    ; posun o ©†dek nahoru
         jc        zobpgup2                 ; zaá†tek souboru
         loop      zobpgup1
zobpgup2:pop       cx
         ret

; -----------------------------------------------------------------------------
public   zobdown

zobdown:                                  ;* posun kurzoru dolñ DOWN

         call      zobgett                  ; poskytnut° adresy zaá†tku
         call      zobsnxt                  ; nalezen° dal®°ho ©†dku
         jc        zobdown2                 ; konec souboru
         call      zobsett                  ; nastaven° novÇho zaá†tku textu
         inc       bh                       ; zvò®en° p©°znaku
zobdown2:ret



public   zobup

zobup:                                    ;* posun kurzoru nahoru UP

         call      zobgett                  ; poskytnut° adresy zaá†tku
         call      zobspre                  ; nalezen° p©edch†zej°c°ho ©†dku
         jc        zobup2                   ; zaá†tek souboru
         call      zobsett                  ; nastaven° novÇho zaá†tku textu
         dec       bh                       ; p©°znak rolov†n° dolñ
zobup2:  ret

; -----------------------------------------------------------------------------
public   zobsnxt

zobsnxt:                                  ;* nalezen° dal®°ho ©†dku
                                            ; VSTUP: DX:AX=adresa v souboru
                                            ; VùSTUP: DX:AX=nov† adresa
                                            ;         CY=nen° dal®° ©†dek

         push      cx
         call      zobsetk                  ; nastaven° kurzoru
         mov       cx,80                    ; ®°©ka ©†dku
         test      byte ptr cs:[conf5],1    ; je zobrazen° bez zalamov†n° ?
         jz        zobsnxt0                 ; je zalamov†n°
         mov       cx,512                   ; vypnuto zalamov†n°
zobsnxt0:                                 ;* posun p©i zobrazen° adres†©e
         test      byte ptr cs:[conf5],8    ; je zobrazen° FAT ?
         jz        zobsnxtd                 ; nen° zobrazen° FAT
         mov       cx,24
         jmp       short zobsnxt5
zobsnxtd:test      byte ptr cs:[conf5],4    ; je zobrazen° adres†©e ?
         jz        zobsnxta                 ; nen° zobrazen° adres†©e
         mov       cx,32
         jmp       short zobsnxt5
zobsnxta:test      byte ptr cs:[ediflag],20h ; je zobrazen° HEX ?
         jz        zobsnxt1                 ; nen° zobrazen° HEX
                                          ;* posun p©i zobrazen° HEX
         mov       cx,16                    ; ®°©ka ©†dku
zobsnxt5:call      zobchnxt                 ; dal®° znak
         loop      zobsnxt5                 ; dal®° znak
                                          ;* zarovn†n° na dal®° odstavec
         pushf
         test      byte ptr cs:[conf5],8    ; je zobrazen° FAT ?
         jz        zobsnxte                 ; nen° zobrazen° FAT
         call      zoblnf8x                 ; zarovn†n° FAT
         jmp       short zobsnxtf
zobsnxte:call      zobgetk                  ; poskytnut° adresy kurzoru
         test      byte ptr cs:[conf5],4    ; je zobrazen° adres†©e ?
         jz        zobsnxtc                 ; nen° zobrazen° adres†©e
         add       ax,1fh                   ; hodnota pro zaokrouhlen°
         adc       dx,0                     ; p©enos do vy®®°ho slova
         and       ax,not 1fh               ; zarovn†n° na odstavec
         jmp       short zobsnxtb
zobsnxtc:add       ax,0fh                   ; hodnota pro zaokrouhlen°
         adc       dx,0                     ; p©enos do vy®®°ho slova
         and       ax,not 0fh               ; zarovn†n° na odstavec
zobsnxtb:call      zobsetk                  ; nastaven° adresy kurzoru
zobsnxtf:popf
         jmp       short zobsnxt4           ; konec ©†dku

zobsnxt1:call      zobchnxt
         jc        zobsnxt4                 ; nen° jië dal®° znak
         test      byte ptr cs:[ediflag],10h
         jnz       zobsnxt2                 ; tabel†tory se ignoruj°
         cmp       al,9
         jne       zobsnxt2                 ; nen° tabel†tor
         dec       cx
         and       cx,not 7
         jcxz      zobsnxt7                 ; je jië konec ©†dku
         jmp       short zobsnxt1

zobsnxt2:cmp       al,0dh                   ; je konec ©†dku <CR> ?
         jne       zobsnxt3                 ; nen° konec ©†dku
         call      zobchnxt                 ; naáten° znaku 0ah <LF>
         jc        zobsnxt4                 ; nen° dal®° znak
         cmp       al,0ah
         je        zobsnxt4                 ; je konec ©†dku
         call      zobchpre
zobsnxt3:loop      zobsnxt1                 ; dal®° znak
zobsnxt7:                                 ;* vynech†n° koncovÇho EOL
         call      zobchnxt
         jc        zobsnxt6
         cmp       al,0dh
         jne       zobsnxt8
         call      zobchnxt
         jc        zobsnxt8
         cmp       al,0ah
         je        zobsnxt4
         call      zobchpre
zobsnxt8:call      zobchpre
zobsnxt6:clc
zobsnxt4:call      zobgetk                  ; poskytnut° adresy kurzoru
         pop       cx
         ret

; -----------------------------------------------------------------------------
public   zobspre

zobspre:                                  ;* nalezen° p©edchoz°ho ©†dku
                                            ; VSTUP: DX:AX=adresa v souboru
                                            ; VùSTUP: DX:AX=nov† adresa
                                            ;         CY=nen° dal®° ©†dek

         push      cx
         call      zobsetk                  ; nastaven° kurzoru
         mov       cx,80                    ; ®°©ka ©†dku
         test      byte ptr cs:[conf5],1    ; je zobrazen° bez zalamov†n° ?
         jz        zobspre9                 ; je zalamov†n°
         mov       cx,512                   ; vypnuto zalamov†n°
zobspre9:                                 ;* posun p©i zobrazen° adres†©e
         test      byte ptr cs:[conf5],8    ; je zobrazen° FAT ?
         jz        zobspred                 ; nen° zobrazen° FAT
         mov       cx,24
         jmp       short zobspre6
zobspred:test      byte ptr cs:[conf5],4    ; je zobrazen° adres†©e ?
         jz        zobsprea                 ; nen° zobrazen° adres†©e
         mov       cx,32
         jmp       short zobspre6
zobsprea:test      byte ptr cs:[ediflag],20h ; je zobrazen° HEX ?
         jz        zobspre0                 ; nen° zobrazen° HEX
                                          ;* posun p©i zobrazen° HEX
         mov       cx,16                    ; ®°©ka ©†dku
zobspre6:call      zobchpre                 ; dal®° znak
         loop      zobspre6                 ; dal®° znak
                                          ;* zarovn†n° na p©edchoz° odstavec
         pushf
         test      byte ptr cs:[conf5],8    ; je zobrazen° FAT ?
         jz        zobspree                 ; nen° zobrazen° FAT
         call      zoblinf8                 ; zarovn†n° FAT
         jmp       short zobspref
zobspree:call      zobgetk                  ; poskytnut° adresy kurzoru
         test      byte ptr cs:[conf5],4    ; je zobrazen° adres†©e ?
         jz        zobspreb                 ; nen° zobrazen° adres†©e
         and       ax,not 1fh               ; zarovn†n° na 32 bajtñ
zobspreb:and       ax,not 0fh               ; zarovn†n° na odstavec
         call      zobsetk                  ; nastaven° adresy kurzoru
zobspref:popf
         jmp       short zobspre4           ; konec ©†dku

zobspre0:call      zobchpre                 ; p©eskoáen° konce ©†dku
         jc        zobspre4                 ; nen° jië dal®° znak
         cmp       al,10
         jne       zobspr03
         call      zobchpre                 ; nacteni znaku CR
         jc        zobspr03
         cmp       al,13
         je        zobspre1                 ; CR-LF se ignoruje

         call      zobchnxt                 ; navrat znaku CR
zobspr03:call      zobchnxt                 ; navrat znaku LF

zobspre1:call      zobchpre                 ; naáten° p©edchoz°ho znaku
         jc        zobspre5                 ; nen° jië dal®° znak
         test      byte ptr cs:[ediflag],10h
         jnz       zobspre7                 ; tabel†tory se ignoruj°
         cmp       al,9
         jne       zobspre7
         dec       cx
         and       cx,not 7
         jcxz      zobspre5                 ; je jië konec ©†dku
         jmp       short zobspre1

zobspre7:cmp       al,0ah                   ; je konec ©†dku <LF> ?
         jne       zobspre3                 ; nen° konec ©†dku
         call      zobchpre                 ; naáten° p©edchoz°ho znaku <CR>
         jc        zobspre3
         push      ax
         call      zobchnxt                 ; n†vrat posledn°ho znaku
         pop       ax
         cmp       al,0dh
         jne       zobspre3
         call      zobchnxt                 ; n†vrat znaku
         jmp       short zobspre5
zobspre3:loop      zobspre1                 ; dal®° znak
zobspre5:clc
zobspre4:call      zobgetk                  ; poskytnut° adresy kurzoru
         pop       cx
         ret

; -----------------------------------------------------------------------------
public   zobsett

zobsett:                                  ;* nastaven° zaá†tku textu
                                            ; VSTUP: DX:AX=nov† adresa zaá†tku

         mov       word ptr cs:[zobtop],ax           ; nië®° slovo ukazatele zaá†tku
         mov       word ptr cs:[zobtop+2],dx         ; vy®®° slovo ukazatele zaá†tku
         ret

; -----------------------------------------------------------------------------
public   zobgett

zobgett:                                  ;* poskytnut° zaá†tku textu
                                            ; VùSTUP: DX:AX=adresa zaá†tku

         mov       ax,word ptr cs:[zobtop]  ; nië®° slovo ukazatele zaá†tku
         mov       dx,word ptr cs:[zobtop+2]; vy®®° slovo ukazatele zaá†tku
         ret

; -----------------------------------------------------------------------------
public   zobsetk

zobsetk:                                  ;* nastaven° kurzoru
                                            ; VSTUP: DX:AX=nov† adresa kurzoru

         mov       word ptr cs:[zobukaz],ax ; nië®° slovo ukazatele kurzoru
         mov       word ptr cs:[zobukaz+2],dx ; vy®®° slovo ukazatele kurzoru
         ret

; -----------------------------------------------------------------------------
public   zobgetk

zobgetk:                                  ;* poskytnut° kurzoru
                                            ; VùSTUP: DX:AX=adresa kurzoru

         mov       ax,word ptr cs:[zobukaz] ; nië®° slovo ukazatele kurzoru
         mov       dx,word ptr cs:[zobukaz+2] ; vy®®° slovo ukazatele kurzoru
         ret

; -----------------------------------------------------------------------------
public   zoball

zoball:                                   ;* zobrazen° v®ech ©†dkñ
                                            ; VSTUP: BH=poáet ©†dkñ k rolov†n°

         push      ax
         push      si
         push      cx
         push      dx

         mov       dx,80                    ; max. pozice se zalamov†n°m
         mov       ax,cs:[toppoz]
         add       ax,dx
         mov       cs:[endpoz],ax           ; koncov† pozice ©†dku
         test      byte ptr cs:[conf5],1    ; je zalamov†n° ?
         jz        zoball01                 ; zalamov†n° je zapnuto
         mov       dx,512                   ; max. pozice bez zalamov†n°
zoball01:mov       cs:[zobwrap],dx          ; max. pozice pro zalamov†n°
         mov       dh,1                     ; poá†teán° ©†dek
         call      getpocl
         push      dx
         call      zobgett                  ; adresa zaá†tku zobrazen°
         call      zobsetk                  ; nastaven° kurzoru
         pop       dx
         or        bh,bh                    ; jsou ©†dkovÇ zmàny ?
         jz        zoball9                  ; nejsou ©†dkovÇ zmàny
         jns       zoball4                  ; je rolov†n° nahoru
         test      byte ptr cs:[ediflag],20h ; je zobrazen° HEX ?
         jnz       zoball14                 ; je zobrazen° HEX

                                          ;* rolov†n° dolñ
zoball1: call      zobline                  ; zobrazen° ©†dku
         inc       dh
         loop      zoball1
         jmp       short zoball5

zoball14:
         mov       al,bh                    ; poáet ©†dkñ k rolov†n°
         neg       al
         cmp       al,10                    ; je vàt®° poáet ©†dkñ neë 10 ?
         jae       zoball71                 ; je velkò poáet ©†dkñ
         mov       ah,7                     ; funkce rolov†n° dolñ
         call      ediroll                  ; rolov†n° obrazovky dolñ
zoball71:cbw                                ; AX <- AL
         cmp       ax,10                    ; je celkò poáet ©†dkñ ?
         jb        zoball72                 ; nen° velkò poáet ©†dkñ
         mov       ax,cx                    ; omezen° poátu ©†dkñ
zoball72:sub       cx,ax                    ; zbylò poáet ©†dkñ
         push      cx                       ; celkovò poáet ©†dkñ
         mov       cx,ax                    ; poáet novòch ©†dkñ
zoball8: call      zobline                  ; zobrazen° jednoho ©†dku
         inc       dh                       ; zvò®en° ©†dku na displeji
         loop      zoball8
         pop       cx                       ; zbylò poáet ©†dkñ
         jcxz      zoball5                 ; nezbòv† ë†dnò ©†dek
edital81:
;         call      edisnxt                  ; nalezen° dal®°ho ©†dku
;         loop      edital81
         jmp       short zoball5

zoball4:                                  ;* rolov†n° nahoru

         mov       al,bh                    ; poáet ©†dkñ k rolov†n°
         cmp       al,10
         jae       zobal43                  ; je velkò poáet ©†dkñ
         mov       ah,6                     ; funkce rolov†n° nahoru
         call      ediroll                  ; rolov†n° obrazovky nahoru
zobal43: cbw                                ; AX <- AL
         cmp       ax,10                    ; je vàt®° poáet ©†dkñ ?
         jb        zobal42                  ; nen° velkò poáet ©†dkñ
         mov       ax,cx                    ; omezen° poátu ©†dkñ
zobal42: sub       cx,ax                    ; zbylò poáet ©†dkñ
         jz        zobal62                  ; nezbyl ë†dnò ©†dek
zobal61: push      ax
         push      dx
         call      zobgetk                  ; poskytnut° kurzoru
         call      zobsnxt                  ; nalezen° dal®°ho ©†dku
         pop       dx
         pop       ax
         inc       dh                       ; zvò®en° ©†dku na displeji
         loop      zobal61                  ; nalezen° adresy ©†dku
zobal62: mov       cx,ax                    ; poáet novòch ©†dkñ
zoball6:
         call      zobline                  ; zobrazen° jednoho ©†dku
         inc       dh                       ; zvò®en° ©†dku na displeji
         loop      zoball6

zoball5: xor       bx,bx
         call      zobtopl                  ; zobrazen° horn°ho ©†dku
zoball9:
         pop       dx
         pop       cx
         pop       si
         pop       ax
         ret


; -----------------------------------------------------------------------------
public   zoblinf
zoblinf:                                  ;* zobrazen° ve tvaru FAT

         push      ax
         push      bx
         push      cx
         push      dx
         push      ds
         mov       al,1
         call      outch1                   ; nastaven° barvy textu
         mov       bh,dh                    ; £schova adresy ©†dku
         call      zoblinf8                 ; zarovn†n° adresy
         cmp       dx,word ptr cs:[zobnum+2]; (velikost souboru)
         jne       zoblinf1
         cmp       ax,word ptr cs:[zobnum]  ; porovn†n° s koncem dat
zoblinf1:jb        zoblinf2                 ; nen° je®tà konec dat
         jmp       zoblnh14                 ; vymaz†n° ©†dku
zoblinf2:
         mov       dh,bh                    ; n†vrat adresy ©†dku
         xor       dl,dl                    ; poá†teán° pozice pro zobrazen°
         or        byte ptr cs:[parnum],10h ; z†kaz tisku teáku tis°cñ

         test      byte ptr cs:[parint25],2 ; je tabulka FAT12 ?
         jz        zoblinf6                 ; je tabulka FAT12
         mov       al," "
         call      outch1
         push      dx
         call      zobgetk                  ; ukazatel kurzoru
         sub       ax,cs:[bajtsekt]         ; odeáten° BOOT sektoru
         sbb       dx,0
         shr       dx,1
         rcr       ax,1
         pop       dx
         call      zoblcls1                 ; zobrazen° á°sla bloku
         mov       al,":"                   ; oddàlovac° znak ":"
         call      outch1
         mov       al,186                   ; oddàlovac° á†ra "∫"
         call      outch1
         mov       cx,12                    ; poáet poloëek pro FAT16
zoblinf3:
         call      zobchnxt                 ; naáten° nië®°ho bajtu á°sla bloku
         mov       ah,al                    ; £schova
         call      zobchnxt                 ; naáten° vy®®°ho bajtu á°sla bloku
         xchg      ah,al
         cmp       ax,0fff7h
         jb        zoblinf5
         mov       si,offset txtzob11       ; vadnò blok
         je        zoblinf4                 ; je vadnò blok
         mov       si,offset txtzob12       ; konec souboru
zoblinf4:call      outtxt
         mov       al,179                   ; oddàlovac° á†ra "≥"
         call      outch1
         jmp       short zoblnf55
zoblinf5:call      zoblcls1                 ; zobrazen° á°sla alokaán°ho bloku
         mov       al,179                   ; oddàlovac° á†ra "≥"
         call      outch1
zoblnf55:loop      zoblinf3                 ; dal®° alokaán° blok
         jmp       short zoblinf7

zoblinf6:
         mov       cx,8                     ; poáet dvojic poloëek FAT12
zoblinf9:
         call      zobchnxt                 ; naáten° nië®°ho bajtu á°sla bloku
         mov       ah,al                    ; £schova
         call      zobchnxt                 ; naáten° vy®®°ho bajtu á°sla bloku
         xchg      ah,al
         call      zobcls12
         call      zobchnxt
         xchg      ah,al
         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1
         call      zobcls12
         loop      zoblinf9


zoblinf7:and       byte ptr cs:[parnum],0efh; povolen° tisku teáky tis°cñ
         call      zoblnf8x
         pop       ds
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         call      mouseon                  ; zapnut° my®i
         ret

public   zoblnf8x
zoblnf8x:
         call      zobgetk                  ; poskytnut° adresy kurzoru
;         or        dx,dx
;         jnz       zoblnf8e
;         cmp       ax,cs:[bajtsekt]
;         jb        zoblnf8d
zoblnf8e:add       ax,23                    ; posun ukazatele
         adc       dx,0                     ; p©enos
zoblnf8d:call      zobsetk                  ; nastaven° adresy kurzoru

public   zoblinf8
zoblinf8:                                 ;* zarovn†n° adresy FAT
         push      bx
         push      cx
         push      si
         call      zobgetk                  ; poskytnut° adresy kurzoru
         mov       cx,ax
         or        cx,dx                    ; je adresa = 0 ?
         jz        zoblnf8g
         sub       ax,cs:[bajtsekt]         ; odeáten° sektoru BOOT
         sbb       dx,0                     ; p©enos
;         jc        zoblnf8c
                                          ;* vydàlen° adresy 24
         mov       cx,24                    ; poáet bajtñ na ©†dek
         mov       bx,ax                    ; nië®° slovo adresy
         mov       ax,dx                    ; vy®®° slovo
         xor       dx,dx
         div       cx                       ; vydàlen° vy®®°ho slova
         xchg      ax,bx                    ; AX<-nië®° slovo, BX<-novÇ vy®®° s.
         div       cx                       ; vydàlen° nië®°ho slova
;         mov       dx,bx                    ; novÇ vy®®° slovo
                                          ;* vyn†soben° adresy 24
         mul       cx                       ; vyn†soben° nië®°ho slova
         xchg      ax,bx                    ; AX<-vy®®° slovo,BX<-novÇ nië®° s.
         mov       si,dx                    ; £schova p©enosu do vy®®°ho slova
         mul       cx                       ; vyn†soben° vy®®°ho slova
         mov       dx,ax                    ; novÇ vy®®° slovo
         mov       ax,bx                    ; novÇ nië®° slovo
         add       dx,si                    ; p©enos do vy®®°ho slova

zoblnf8c:add       ax,cs:[bajtsekt]         ; n†vrat sektoru BOOT
         adc       dx,0                     ; p©enos
         call      zobsetk                  ; nastaven° adresy kurzoru
zoblnf8g:pop       si
         pop       cx
         pop       bx
         ret


zobcls12:                                 ;* zobrazen° bloku 12 bitñ
         push      ax
         and       ax,0fffh                 ; zamaskov†n° 12 bitñ
         cmp       ax,0ff7h
         mov       si,offset txtzob13       ; vadnò blok
         je        zoblnf24                 ; je vadnò blok
         mov       si,offset txtzob14       ; konec souboru
         ja        zoblnf24
         push      ds
         push      es
         push      cs
         pop       ds
         push      cs
         pop       es
         push      dx
         push      bx
         push      cx
         mov       di,offset bufwin         ; tiskovò buffer
         xor       dx,dx
         call      setspc                   ; nastaven° m¢du tisku mezer
         call      deknum4                  ; dek¢dov†n° á°sla 4 á°slic
         call      setfre                   ; volnò form†t tisku á°sla
         pop       cx
         pop       bx
         pop       dx                       ; pozice
         pop       es
         pop       ds
         mov       si,offset bufwin         ; tiskovò buffer
zoblnf24:call      outtxt                   ; zobrazen° textu
         mov       al,179                   ; oddàlovac° á†ra "≥"
         call      outch1
         pop       ax
         ret
; -----------------------------------------------------------------------------
public   zoblind
zoblind:                                  ;* zobrazen° ve tvaru adres†©e

         push      ax
         push      bx
         push      cx
         push      dx
         push      ds
         mov       al,1
         call      outch1                   ; nastaven° barvy textu
         mov       bh,dh                    ; £schova adresy ©†dku
         call      zobgetk                  ; poskytnut° adresy kurzoru
         and       ax,not 1fh               ; zarovn†n° na 32 bajtñ
         call      zobsetk                  ; nastaven° adresy kurzoru
         cmp       dx,word ptr cs:[zobnum+2]; (velikost souboru)
         jne       zoblnd11
         cmp       ax,word ptr cs:[zobnum]  ; porovn†n° s koncem dat
zoblnd11:jb        zoblnd12                 ; nen° je®tà konec dat
         jmp       zoblnh14                 ; vymaz†n° ©†dku
                                          ;* zobrazen° jmÇna a p©°pony
zoblnd12:mov       dh,bh                    ; n†vrat adresy ©†dku
         xor       dl,dl
         mov       cx,8                     ; poáet znakñ jmÇna
         call      zoblnd8
         mov       al," "
         call      outch1
         mov       cx,3
         call      zoblnd8
         mov       al,179                   ; oddàlovac° á†ra "≥"
         call      outch1
                                          ;* zobrazen° atributñ
         call      zobchnxt                 ; naáten° atributñ
         mov       bh,al                    ; atributy souboru
         mov       al,"1"
         call      zoblnda
         mov       al,"1"
         call      zoblnda
         mov       al,"A"
         call      zoblnda
         mov       al,"D"
         call      zoblnda
         mov       al,"V"
         call      zoblnda
         mov       al,"S"
         call      zoblnda
         mov       al,"H"
         call      zoblnda
         mov       al,"R"
         call      zoblnda
         mov       al,179                   ; oddàlovac° á†ra "≥"
         call      outch1                   ; zobrazen° oddàlovaáe
                                          ;* zobrazen° rezervovanòch dat
         mov       cx,10                    ; poáet oddàlovacòch bajtñ
zoblnd3: call      zobchnxt                 ; naáten° bajtu
         call      outhexb                  ; zobrazen° bajtu HEX
         mov       al," "                   ; oddàlovac° mezera
         loop      zoblnd3                  ; dal®° bajt
;         mov       al," "
;         call      outch1
;         mov       cx,5                     ; poáet oddàlovacòch bajtñ
;zoblnd4: call      zobchnxt                 ; naáten° bajtu
;         call      outhexb                  ; zobrazen° bajtu HEX
;         mov       al," "                   ; oddàlovac° mezera
;         loop      zoblnd4                  ; dal®° bajt
         mov       al,179                   ; oddàlovac° á†ra "≥"
         call      outch1
                                          ;* zobrazen° áasu z†pisu
         call      zobchnxt                 ; naáten° nië®°ho bajtu áasu
         mov       ah,al
         call      zobchnxt                 ; naáten° vy®®°ho bajtu áasu
         xchg      ah,al
         push      ax                       ; £schova áasu souboru
         mov       cl,11                    ; poáet rotac°
         shr       ax,cl                    ; AX >> hodina
         and       al,1fh                   ; maska pro hodinu
         call      tisknm2s                 ; zobrazen° hodiny
         mov       al,":"                   ; oddàlovac° znak
         call      outch1                   ; zobrazen° oddàlovac° teáky
         pop       ax                       ; n†vrat áasu souboru
         push      ax
         mov       cl,5                     ; poáet rotac°
         shr       ax,cl                    ; AX >> minuta
         and       al,3fh                   ; maska pro minutu
         call      tisknm20                 ; zobrazen° minuty
         mov       al,":"                   ; oddàlovac° znak
         call      outch1                   ; zobrazen° oddàlovac° teáky
         pop       ax
         and       al,1fh
         add       al,al                    ; sekundy * 2
         call      tisknm20                 ; zobrazen° sekund
         mov       al,179                   ; oddàlovac° á†ra "≥"
         call      outch1
                                          ;* zobrazen° data
         call      zobchnxt                 ; naáten° nië®°ho bajtu data
         mov       ah,al
         call      zobchnxt                 ; naáten° vy®®°ho bajtu data
         xchg      ah,al
         push      ax
         call      zobrfd0                  ; zobrazen° data souboru
         pop       ax
         dec       dl
         dec       dl
         xchg      al,ah
         shr       ax,1
         and       ax,7fh
         add       ax,1980
         or        byte ptr cs:[parnum],10h ; z†kaz tisku teáku tis°cñ
         push      dx
         mov       di,offset bufwin         ; tiskovò buffer
         xor       dx,dx
         call      deknum4                  ; dek¢dov†n° á°sla 4 á°slic
         pop       dx                       ; pozice
         and       byte ptr cs:[parnum],0efh ; zru®en° z†kazu tisku teáku tis°cñ
         mov       si,offset bufwin         ; tiskovò buffer
         call      outtxt                   ; zobrazen° textu
         mov       al,179                   ; oddàlovac° á†ra "≥"
         call      outch1
                                          ;* zobrazen° alokaán°ho bloku
         call      zoblclus                 ; zobrazen° alokaán°ho bloku
         mov       al,179                   ; oddàlovac° á†ra "≥"
         call      outch1
                                          ;* zobrazen° velikosti souboru
         call      zobchnxt
         mov       ah,al
         call      zobchnxt
         mov       bh,al
         call      zobchnxt
         mov       bl,al
         call      zobchnxt
         xchg      bh,al
         xchg      ah,al
         call      tisknm0                  ; tisk á°sla velikosti (10 á°slic)

;         mov       al,179                   ; oddàlovac° á†ra "≥"
;         call      outch1

         call      zobgetk                  ; poskytnut° adresy kurzoru
         add       ax,1fh                   ; hodnota pro zaokrouhlen°
         and       ax,not 1fh               ; zarovn†n° na odstavec
         call      zobsetk                  ; nastaven° adresy kurzoru
         pop       ds
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         call      mouseon                  ; zapnut° my®i
         ret

zoblnda: test      bh,80h
         jnz       zoblndb
         mov       al,"."
zoblndb: call      outch1
         shl       bh,1
         ret

zoblnd8: call      zobchnxt                 ; naáten° bajtu
         jc        zoblnd9
         call      outch10
         loop      zoblnd8
zoblnd9: ret






zoblclus:                                 ;* zobrazen° alokaán°ho bloku
         call      zobchnxt                 ; naáten° nië®°ho bajtu á°sla bloku
         mov       ah,al                    ; £schova
         call      zobchnxt                 ; naáten° vy®®°ho bajtu á°sla bloku
         xchg      ah,al
zoblcls1:call      setspc                   ; nastaven° m¢du tisku mezer
         push      ds
         push      es
         push      cs
         pop       ds
         push      cs
         pop       es
         push      dx
         push      bx
         push      cx
         mov       di,offset bufwin         ; tiskovò buffer
         xor       dx,dx
         call      deknum5                  ; dek¢dov†n° á°sla 5 á°slic
         pop       cx
         pop       bx
         pop       dx                       ; pozice
         mov       si,offset bufwin         ; tiskovò buffer
         call      outtxt                   ; zobrazen° textu
         call      setfre                   ; volnò form†t tisku á°sla
         pop       es
         pop       ds
         ret
; -----------------------------------------------------------------------------
public   zobline

zobline:                                  ;* zobrazen° jednoho ©†dku
         xor       dl,dl                    ; poá†teán° pozice
         call      mouseoff                 ; vypnut° my®i
         test      byte ptr cs:[conf5],8    ; p©°znak FAT tabulky
         jz        zoblinrr                 ; nen° zobrazen° FAT
         jmp       zoblinf                  ; zobrazen° FAT

zoblinrr:test      byte ptr cs:[conf5],4    ; je zobrazen° adres†©e ?
         jz        zobliner                 ; nen° zobrazen° adres†©e
         jmp       zoblind                  ; zobrazen° adres†©e

zobliner:test      byte ptr cs:[ediflag],20h ; je zobrazen° HEX ?
         jnz       zoblinh0                 ; je zobrazen° HEX
         jmp       zobline0                 ; nen° zobrazen° HEX

zoblinh0:push      ax
         push      bx
         push      cx
         push      dx
         push      ds
         mov       al,1
         call      outch1                   ; nastaven° barvy textu
                                          ;* zarovn†n° na odstavec
         mov       bh,dh                    ; £schova adresy ©†dku
;         cmp       byte ptr cs:[parbreak],0
;         jne       zoblnh14                 ; je diskov† chyba
         call      zobgetk                  ; poskytnut° adresy kurzoru
         and       ax,not 0fh               ; zarovn†n° na odstavec
         call      zobsetk                  ; nastaven° adresy kurzoru
         cmp       dx,word ptr cs:[zobnum+2]; (velikost souboru)
         jne       zoblnh11
         cmp       ax,word ptr cs:[zobnum]  ; porovn†n° s koncem dat
zoblnh11:jb        zoblnh12                 ; nen° je®tà konec dat
zoblnh14:mov       dh,bh                    ; n†vrat adresy ©†dku
         xor       dl,dl                    ; poá†teán° pozice
         mov       al," "
         mov       cx,80
         call      outch                    ; vymaz†n° ©†dku
         jmp       zoblinh8

zoblnh12:push      ax                       ; £schova adresy kurzoru
         push      dx
         mov       dh,bh                    ; n†vrat adresy ©†dku
         xor       dl,dl                    ; poá†teán° pozice
         mov       al,186
         call      outch1                   ; zobrazen° levÇho okraje
                                          ;* zobrazen° adresy
         mov       ax,word ptr cs:[zobukaz+2] ; vy®®° slovo ukazatele kurzoru
         call      outhexw                  ; zobrazen° vy®®°ho slova HEX
         mov       al,"."
         call      outch1
         mov       ax,word ptr cs:[zobukaz] ; nië®° slovo ukazatele kurzoru
         call      outhexw                  ; zobrazen° nië®°ho slova HEX

         mov       al,179
                                          ;* zobrazen° dat HEX
         mov       cx,16                    ; á°taá dat
zoblinh1:call      outch1                   ; prvn° oddàlovac° znak
         call      zobchnxt                 ; naáten° bajtu
         pushf
         jnc       zoblinh2                 ; nen° je®tà konec souboru
         mov       al," "
         call      outch1
         call      outch1                   ; n†hradn° mezera
         jmp       short zoblnh21
zoblinh2:cmp       al," "                   ; je ©°dic° znak ?
         jae       zoblnh22                 ; nen° ©°dic° znak
;         test      byte ptr cs:[config],4   ; je zobrazen° Ctrl- ?
;         jz        zoblnh22                 ; nen° zobrazen° s Ctrl-
         push      ax
         mov       al,15
         call      outch1                   ; nastaven° barvy
         pop       ax
zoblnh22:call      outhexb                  ; zobrazen° bajtu HEX
         mov       al,1
         call      outch1
zoblnh21:dec       cl
         test      cl,3                     ; je oddàlovaá tetr†dy ?
         jne       zoblinh4                 ; nen° oddàlovaá tetr†dy
         mov       al," "                   ; oddàlovac° mezera
         call      outch1
zoblinh4:popf
         mov       al,"-"
         jnc       zoblnh42
         mov       al," "
zoblnh42:cmp       cl,8                     ; je prost©edn° oddàlovac° mezera ?
         jne       zoblinh3                 ; nen° prost©edn° oddàl. mezera
         call      outch1
zoblinh3:inc       cl
         mov       al," "
         loop      zoblinh1                 ; dal®° znak

zoblinh5:                                 ;* zobrazen° dat ASCII
         pop       dx                       ; n†vrat adresy kurzoru
         pop       ax
         call      zobsetk                  ; nastaven° adresy kurzoru
         mov       dh,bh                    ; n†vrat adresy ©†dku
         mov       cx,16                    ; á°taá dat
         mov       dl,62                    ; poá†teán° pozice
         mov       al,179                   ; oddàlovaá dat ASCII
         call      outch1
zoblinh6:call      zobchnxt                 ; naáten° bajtu
         jnc       zoblinh7                 ; nen° konec souboru
         mov       al," "                   ; n†hradn° mezera
zoblinh7:cmp       al," "                   ; je ©°dic° znak ?
         jae       zoblnh72                 ; nen° ©°dic° znak
         push      ax
         mov       al,15
         call      outch1                   ; nastaven° barvy
         pop       ax
         test      byte ptr cs:[config],4   ; je zobrazen° Ctrl- ?
         jz        zoblnh72                 ; nen° zobrazen° s Ctrl-
;         cmp       al,32
;         jae       zoblnh72                 ; nen° ©°dic° znak
         add       al,"@"                   ; korekce na znak ASCII
zoblnh72:or        al,al
         jnz       zoblnh76
         mov       al,"."                   ; n†hradn° znak "."
zoblnh76:call      outch10                  ; zobrazen° bajtu
         mov       al,1
         call      outch1
         loop      zoblinh6                 ; dal®° znak
         mov       dl,79
         mov       al,186
         call      outch1
                                          ;* zarovn†n° na dal®° odstavec
zoblnh9: call      zobgetk                  ; poskytnut° adresy kurzoru
         add       ax,0fh                   ; hodnota pro zaokrouhlen°
         adc       dx,0                     ; p©enos do vy®®°ho slova
         and       ax,not 0fh               ; zarovn†n° na odstavec
         call      zobsetk                  ; nastaven° adresy kurzoru
zoblinh8:pop       ds
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         call      mouseon                  ; zapnut° my®i
         ret

; -----------------------------------------------------------------------------
public   zobline0                         ;* zobrazen° ©†dku (textovò tvar)
zobline0:push      ax
         push      bx
         push      dx
         push      ds
         xor       bx,bx                    ; ukazatel relativn° pozice
         cmp       word ptr cs:[toppoz],0
         je        zoblined
         mov       al,2
         call      outch1
         mov       al,174
         call      outch1
zoblined:mov       al,1
         call      outch1
                                          ;* vstup jednoho znaku
zobline2:cmp       bx,cs:[zobwrap]          ; dosaëeno pozice zalamov†n° ?
         jae       zoblin11                 ; dosaëeno pozice zalamov†n°
         call      zobchnxt                 ; naáten° dal®°ho znaku
         jc        zobline1                 ; nen° jië dal®° znak - vymaz†n° ©.
         cmp       al,0dh                   ; je CR ?
         jne       zobline3                 ; nen° CR - zobrazen° znaku
         call      zobchnxt                 ; naáten° znaku 0ah <LF>
         jc        zobline4                 ; konec - n†vrat znaku
         cmp       al,0ah                   ; je znak LF ?
         je        zobline1                 ; je konec ©†dku
         call      zobchpre                 ; n†vrat posledn°ho znaku
zobline4:mov       al,0dh                   ; n†vrat znaku CR
         jmp       short zobline3           ; zobrazen° znaku <CR>

zoblin11:                                 ;* dosazeno pozice zalamovani
         call      zobchnxt                 ; naáten° dal®°ho znaku
         jc        zobline1                 ; nen° jië dal®° znak - vymaz†n° r.
         cmp       al,0dh
         jne       zoblin12
         call      zobchnxt                 ; nacteni dalsiho znaku
         jc        zoblin12                 ; neni dalsi znak - navrat CR
         cmp       al,0ah
         je        zobline1                 ; je LF - ignoruje se
         call      zobchpre                 ; navrat znaku LF
zoblin12:call      zobchpre                 ; navrat znaku CR
                                          ;* vymaz†n° zbytku ©†dku
zobline1:mov       al," "
         call      zobchout                 ; zobrazen° mezery
         jc        zobline1                 ; zobrazen° dal®°ho znaku
         jmp       zobline5                 ; konec
                                          ;* znak se zobraz°
zobline3:cmp       al," "                   ; je ©°dic° znak ?
         jae       zobline6                 ; nen° ©°dic° znak
         push      ax
         mov       al,15
         call      outch1                   ; nastaven° barvy
         pop       ax
         test      byte ptr cs:[config],4   ; je zobrazen° Ctrl- ?
         jz        zobline6                 ; nen° zobrazen° s Ctrl-
 ;        cmp       al,32
 ;        jae       zobline6
         test      byte ptr cs:[ediflag],10h
         jnz       zoblin66                 ; tabel†tory jsou vypnuty
         cmp       al,9                     ; je tabel†tor ?
         je        zobline6                 ; je tabel†tor
zoblin66:add       al,"@"                   ; korekce na znak ASCII
         jmp       short zobline7
zobline6:
         test      byte ptr cs:[ediflag],10h
         jnz       zoblinea                 ; tabel†tory jsou vypnuty
         cmp       al,9
         jne       zoblinea                 ; nen° tabel†tor
         mov       al," "
zoblineb:
         call      zobchout
;         dec       cx
;         inc       bx
         test      bx,7
         jnz       zoblineb
         mov       al,1
         call      outch1
;         jcxz      zoblinec
zoblineg:jmp       zobline2

zoblinea:or        al,al
         jnz       zobline7
         mov       al,"."
zobline7:;cmp       bx,cs:[toppoz]
         ;jb        zoblin72
         ;call      outch10                  ; zobrazen° znaku
zoblin72:;inc       bx                       ; zvò®en° ukazatele pozice
         cmp       bx,cs:[endpoz]           ; dosaëeno pozice konce ©†dku ?
         jne       zoblinee                 ; nen° dosaëeno pozice zalamov†n°
         mov       al,2
         call      outch
         mov       al,175                   ; znak "Ø"
         dec       dl
         call      outch1
zoblinee:
         call      zobchout                 ; zobrazen° znaku
;         pushf
         mov       al,1
         call      outch1
         jmp       short zoblineg
;         popf
;         jc        zobline2                 ; nen° je®tà konec ©†dku
;         loop      zobline2                 ; dal®° znak
zoblinec:                                 ;* vynech†n° koncovÇho EOL
         call      zobchnxt
         jc        zobline5
         cmp       al,0dh
         jne       zobline8
         call      zobchnxt
         jc        zobline8
         cmp       al,0ah
         je        zobline5
         call      zobchpre
zobline8:call      zobchpre

zobline5:pop       ds
         pop       dx
;         pop       cx
         pop       bx
         pop       ax
         call      mouseon                  ; zapnut° my®i
         ret
; -----------------------------------------------------------------------------
public   zobchout
zobchout:                                 ;* zobrazen° znaku na displej
                                            ; VSTUP: AL=znak k zobrazen°
                                            ;        BX=ukazatel pozice
                                            ;        CY=nen° je®tà konec ©†dku

         cmp       word ptr cs:[toppoz],0   ; je posunutò zaá†tek ?
         je        zobchou1                 ; zaá†tek nen° posunutò
         cmp       bx,cs:[toppoz]           ; je p©ed poá†teán° pozic° ?
         jbe       zobchou2                 ; je p©ed poá†teán° pozic°
zobchou1:cmp       bx,cs:[endpoz]           ; je za koncovou pozic° ?
         jae       zobchou2                 ; je za koncovou pozic°
         call      outch10                  ; zobrazen° znaku
zobchou2:inc       bx                       ; zvò®en° relativn° pozice
         cmp       bx,cs:[endpoz]           ; je jië koncov† pozice ?
         ret
; -----------------------------------------------------------------------------
;                    Äten° dal®°ho/p©edchoz°ho znaku
; -----------------------------------------------------------------------------
public   zobchnxt
zobchnxt:                                 ;* naáten° dal®°ho znaku
                                            ; VùSTUP: AL=naátenò znak
                                            ;         CY=nen° jië dal®° znak

         push      si
         push      ds
         call      zobgkurz                 ; poskytnut° adresy kurzoru v pamàti
         jnc       zobchnx1                 ; jsou dal®° data
         call      zoblnxt                  ; naáten° dal®°ho bloku dat
         jc        zobchnx2                 ; nejsou jië dal®° data
         call      zobgkurz                 ; poskytnut° adresy kurzoru v pamàti
zobchnx1:lodsb                              ; naáten° znaku z pamàti
         add       word ptr cs:[zobukaz],1  ; zvò®en° ukazatele kurzoru
         adc       word ptr cs:[zobukaz+2],0 ; p©enos
zobchnx2:pop       ds
         pop       si
         ret
; -----------------------------------------------------------------------------
public   zobchpre
zobchpre:                                 ;* naáten° dal®°ho znaku
                                            ; VùSTUP: AL=naátenò znak
                                            ;         CY=nen° jië dal®° znak

         push      si
         push      ds
         sub       word ptr cs:[zobukaz],1  ; sn°ëen° ukazatele kurzoru
         sbb       word ptr cs:[zobukaz+2],0 ; p©enos
         jnc       zobchpr0                 ; nen° p©eteáen°
         mov       word ptr cs:[zobukaz],0  ; n†vrat ukazatele kurzoru
         mov       word ptr cs:[zobukaz+2],0
         jmp       short zobchpr3           ; nejsou v bufferu data - naáten°

zobchpr0:call      zobgkurz                 ; poskytnut° adresy kurzoru v pamàti
         jnc       zobchpr1                 ; jsou dal®° data
zobchpr3:;cmp       byte ptr cs:[parbreak],0 ; je diskov† chyba ?
         ;stc
         ;jne       zobchpr2                 ; je diskov† chyba
         call      zoblpre                  ; naáten° dal®°ho bloku dat
         jc        zobchpr2                 ; nejsou jië dal®° data
         call      zobgkurz                 ; poskytnut° adresy kurzoru v pamàti
zobchpr1:mov       al,ds:[si]               ; naáten° znaku z pamàti
zobchpr2:pop       ds
         pop       si
         ret
; -----------------------------------------------------------------------------
public   zobgkurz
zobgkurz:                                 ;* poskytnut° adresy kurzoru v pamàti
                                            ; VùSTUP: DS:SI=adresa v pamàti
                                            ;         CY=kurzor je mimo rozsah

         mov       si,word ptr cs:[zobukaz] ; ukazatel zaá†tku dat v bufferu
         sub       si,word ptr cs:[zobbuf]  ; offset v souboru
         mov       ds,cs:[topseg]           ; segment s daty
         cmp       si,cs:[editnum]          ; kontrola s daty v pamàti
         cmc
         ret
; -----------------------------------------------------------------------------
public   zoblpre

zoblpre:                                  ;* naáten° p©edchoz°ho bloku dat 2 KB
                                            ; VùSTUP: CY=nejsou jië dal®° data

         push      ax
         push      bx
         push      cx
         push      dx
         push      ds
         push      es
                                          ;* test, zda jsou jië v®echna data
         mov       ax,word ptr cs:[zobbuf]
         mov       dx,word ptr cs:[zobbuf+2]; naáten° ukaz. zaá†tku dat v buff.
         or        ax,dx                    ; je jië zaá†tek souboru ?
         jnz       zoblpre2                 ; nen° zaá†tek souboru
         stc
zoblprea:jmp       zoblpre3                 ; jsou jië naátena v®echna data
zoblpre2:test      byte ptr cs:[parint],4   ; je aktivn° INT 24h ?
         stc
         jnz       zoblprea                 ; je aktivn° INT 24h
                                          ;* sn°ëen° ukazatele zaá†tku bufferu
         cmp       word ptr cs:[zobbuf+2],0 ; je zaá†tek nad 64 KB ?
         jne       zoblpr22                 ; zaá†tek je nad 64 KB
         mov       si,word ptr cs:[zobbuf]  ; zaá†tek bufferu
         cmp       si,1000h                 ; je zaá†tek nad 1000h ?
         jbe       zoblpr23                 ; zaá†tek je pod 1000h
zoblpr22:mov       si,1000h                 ; p©edpokl†danò posun ukazatele
zoblpr23:test      byte ptr cs:[parint25],80h ; je zobrazen° disku ?
         jz        zoblpre9                  ; nen° zobrazen° disku
         mov       si,cs:[bajtsekt]         ; poáet bajtñ na sektor
zoblpre9:
 ;        cmp       word ptr cs:[zobbuf+2],0 ; je ukazatel zaá†tku pod 4 KB ?
 ;        jne       zoblpre4                 ; nen° pod 4 KB
 ;        cmp       word ptr cs:[zobbuf],si
 ;        ja        zoblpre4                 ; nen° pod 4 KB
 ;        mov       si,word ptr cs:[zobbuf]  ; pot©ebn† velikost dat k naáten°
zoblpre4:sub       word ptr cs:[zobbuf],si  ; sn°ëen° adresy zaá†tku v bufferu
         sbb       word ptr cs:[zobbuf+2],0 ; p©enos do vy®®°ho slova
                                          ;* uvolnàn° pamàti (4 KB)
         push      si                       ; poëadovan† velikost prostoru
         mov       di,si
         xor       si,si                    ; c°lov† adresa
         mov       cx,cs:[editmax]          ; velikost bufferu
         sub       cx,di                    ; dÇlka dat k odsunu
         add       si,cx
         add       di,cx
         dec       si
         dec       di
         mov       ds,cs:[topseg]           ; segment s daty
         push      ds
         pop       es                       ; segment s daty
         std
         rep       movsb                    ; p©esun dat dolñ
         cld
                                          ;* nastaven° poátu bajtñ v bufferu
         pop       si                       ; velikost novà naátenòch dat
         xchg      si,cs:[editnum]
         add       si,cs:[editnum]          ; nov† velikost dat
         jc        zoblpre6                 ; p©eteáen° - bude omezen°
         cmp       si,cs:[editmax]          ; p©ekroáen konec ?
         jae       zoblpre6                 ; byl p©ekroáen konec
;zoblpre6:mov       si,cs:[editmax]          ; skluteán† velikost dat v bufferu
zoblpre7:mov       cs:[editnum],si          ; nastaven° velikosti dat v bufferu
zoblpre6:

         test      byte ptr cs:[parint25],80h ; je zobrazen° disku ?
         jz        zoblpre8                 ; nen° zobrazen° disku
                                          ;* naáten° sektoru z disku
         mov       bx,word ptr cs:[zobbuf]  ; ukazatel zaá†tku dat v bufferu
         mov       ax,word ptr cs:[zobbuf+2]
         xor       dx,dx
         div       word ptr cs:[bajtsekt]   ; á°slo sektoru - vy®®° slovo
         xchg      ax,bx                    ; ukazatel dat - nië®° slovo
         div       word ptr cs:[bajtsekt]   ; á°slo sektoru - nië®° slovo
         mov       dx,bx                    ; n†vrat vy®®°ho slova
         mov       cx,1                     ; 1 sektor k naáten°
         xor       bx,bx                    ; adresa v bufferu
         mov       es,cs:[topseg]           ; segment s daty
         call      ReadSekt                 ; naáten° sektoru s daty
         jmp       short zoblpre3

zoblpre8:
         push      si
                                          ;* nastaven° ukazatele souboru
         mov       ax,4200h                 ; funkce nastaven° ukazatele souboru
         mov       bx,cs:[inpid]            ; identifik†tor souboru
         mov       dx,word ptr cs:[zobbuf]  ; ukazatel zaá†tku dat v bufferu
         mov       cx,word ptr cs:[zobbuf+2]
         int       21h                      ; nastaven° ukazatele souboru
                                          ;* naáten° dal®°ho bloku dat
         pop       cx                       ; dÇlka dat k naáten° (max. 4 KB)
         mov       ah,3fh                   ; funkce áten° ze souboru
         mov       bx,cs:[inpid]            ; identifik†tor souboru
         xor       dx,dx                    ; adresa k uloëen° dal®°ch dat
         mov       ds,cs:[topseg]           ; segment s daty
         int       21h                      ; naáten° dal®°ch dat
zoblpre3:pop       es
         pop       ds
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret



public   zoblnxt

zoblnxt:                                  ;* naáten° dal®°ho bloku dat 4 KB
                                            ; VùSTUP: CY=nejsou jië dal®° data

         push      ax
         push      bx
         push      cx
         push      dx
         push      ds
         push      es
                                          ;* test, zda jsou jië v®echna data
         mov       ax,word ptr cs:[zobbuf]
         mov       dx,word ptr cs:[zobbuf+2]; naáten° ukaz. zaá†tku dat v buff.
         add       ax,cs:[editnum]          ; adresa konce dat v pamàti
         adc       dx,0                     ; p©enos
         mov       cx,word ptr cs:[zobnum]  ; porovn†n° s koncem dat
         mov       bx,word ptr cs:[zobnum+2]; (velikost souboru)
         call      compdword                ; jsou jië naátena v®echna data ?
         jnc       zoblnxta                 ; jsou jië naátena v®echna data
         test      byte ptr cs:[parint],4   ; je aktivn° INT 24h ?
         jz        zoblnxtb                 ; nen° aktivn° INT 24h
zoblnxta:
         stc
         jmp       zoblnxt3
zoblnxtb:                                 ;* uvolnàn° 4 KB pamàti
         mov       cx,cs:[editmax]          ; kapacita pamàti
         sub       cx,cs:[editnum]          ; volnÇ m°sto v pamàti
         mov       si,1000h                 ; poëadovanò prostor 4 KB
         test      byte ptr cs:[parint25],80h ; je zobrazen° disku ?
         jz        zoblnx7                   ; nen° zobrazen° disku
         mov       si,cs:[bajtsekt]         ; poáet bajtñ na sektor
zoblnx7:
         cmp       cx,si                    ; je alespo§ 4 KB volnÇ pamàti ?
         jae       zoblnx2                  ; je alespo§ 4 KB volnÇ pamàti
;         sub       si,cx                    ; rozd°l - nadbytek dat
         sub       cs:[editnum],si          ; sn°ëen° poátu dat v pamàti
         add       word ptr cs:[zobbuf],si  ; zvò®en° adresy zaá†tku v bufferu
         adc       word ptr cs:[zobbuf+2],0 ; p©enos do vy®®°ho slova
         xor       di,di                    ; c°lov† adresa
         mov       ds,cs:[topseg]           ; segment s daty
         push      ds
         pop       es                       ; segment s daty
         mov       cx,cs:[editmax]          ; kapacita pamàti
         sub       cx,si                    ; zbytek dat v pamàti
         rep       movsb                    ; p©esun dat dolñ
zoblnx2: test      byte ptr cs:[parint25],80h ; je zobrazen° disku ?
         jz        zoblnx4                  ; nen° zobrazen° disku
                                          ;* naáten° sektoru z disku
         mov       bx,word ptr cs:[zobbuf]  ; ukazatel zaá†tku dat v bufferu
         mov       ax,word ptr cs:[zobbuf+2]
         add       bx,cs:[editnum]          ; souáasnò ukazatel konce dat
         adc       ax,0
         xor       dx,dx
         div       word ptr cs:[bajtsekt]   ; á°slo sektoru - vy®®° slovo
         xchg      ax,bx                    ; ukazatel dat - nië®° slovo
         div       word ptr cs:[bajtsekt]   ; á°slo sektoru - nië®° slovo
         mov       dx,bx                    ; n†vrat vy®®°ho slova
         mov       cx,1                     ; 1 sektor k naáten°
         mov       bx,cs:[editnum]          ; adresa v bufferu
         mov       es,cs:[topseg]           ; segment s daty
         call      ReadSekt                 ; naáten° sektoru s daty
         mov       ax,cs:[bajtsekt]         ; poáet bajtñ na sektor
         jmp       short zoblnxt5

zoblnx4:                                  ;* nastaven° ukazatele souboru
         mov       ax,4200h                 ; funkce nastaven° ukazatele souboru
         mov       bx,cs:[inpid]            ; identifik†tor souboru
         mov       dx,word ptr cs:[zobbuf]  ; ukazatel zaá†tku dat v bufferu
         mov       cx,word ptr cs:[zobbuf+2]
         add       dx,cs:[editnum]          ; souáasnò ukazatel konce dat
         adc       cx,0
         int       21h                      ; nastaven° ukazatele souboru
         jc        zoblnxt3
                                          ;* naáten° dal®°ho bloku dat
         mov       ah,3fh                   ; funkce áten° ze souboru
         mov       bx,cs:[inpid]            ; identifik†tor souboru
         mov       dx,cs:[editnum]          ; adresa k uloëen° dal®°ch dat
         mov       cx,1000h                 ; dÇlka dat k naáten° 4 KB
         mov       ds,cs:[topseg]           ; segment s daty
         int       21h                      ; naáten° dal®°ch dat
         jc        zoblnxt3                 ; chyba áten° dat
zoblnxt5:add       cs:[editnum],ax          ; zvò®en° poátu bajtñ v pamàti
         clc
zoblnxt3:pop       es
         pop       ds
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret




public   compdword

compdword:                                ;* porovn†n° dvojslova DX:AX ? BX:CX
                                            ; VSTUP: DX:AX=prvn° á°slo
                                            ;        BX:CX=druhÇ á°slo

         cmp       dx,bx
         jne       cmpdw2
         cmp       ax,cx
cmpdw2:  ret
; -----------------------------------------------------------------------------
;                       Nalezen° alokaán°ho bloku souboru
; -----------------------------------------------------------------------------
public   hledclus
hledclus:                                 ;* nalezen° alokaán°ho bloku souboru
                                            ; VùSTUP: AX=á°slo alokaán°ho bloku
         push      cs
         pop       ds
         mov       si,ds:[bp+4]             ; adresa cesty k adres†©i
         call      aktdir                   ; nastaven° aktivn°ho adres†©e
         mov       dx,offset all
         mov       cx,16h                   ; v®echny soubory
         mov       ah,4eh
         int       21h                      ; nalezen° souboru
         jc        hledcls7                 ; nenalezen ë†dnò soubor
         mov       bx,ds:[verze]            ; verze operaán°ho systÇmu
         mov       ax,ds:[93h]              ; alokaán° blok pro DOS 2.x a <3.2
         cmp       bx,3*256+20              ; je nië®° verze neë 3.20 ?
         jb        hledcls8                 ; je nië®° verze neë 3.20
         mov       ax,ds:[8fh]
         ret
hledcls7:xor       ax,ax
hledcls8:ret
; -----------------------------------------------------------------------------
;                     Inicializace operac° se sektory
; -----------------------------------------------------------------------------

InitI256:pop       ds
         ret


public   InitINT25
InitINT25:                                ;* inicializace obsluhy INT 25h

         or        byte ptr cs:[conf5],4    ; p©°znak adres†©e
         push      ds
;                                          ;* reset diskovÇho systÇmu
;         mov       ah,0dh
;         int       21h                      ; reset diskovÇho systÇmu
                                          ;* poskytnut° tabulky parametrñ disku
         and       byte ptr cs:[parint25],not 83h ; zru®en° p©°zn.paketu a FAT16
         mov       dl,cs:[disk25]           ; disk pro obsluhu INT 25h
         mov       ah,32h
         int       21h                      ; poskytnut° bloku parametrñ disku
         cmp       al,0ffh                  ; je chyba ?
         je        InitI256                 ; je chyba - neplatnò disk
         dec       dl                       ; á°slo poëadovanÇho disku
         cmp       dl,ds:[bx]               ; souhlas° á°slo disku ?
         jne       InitI256                 ; á°slo disku nesouhlas° - chyba
                                          ;* je platnò disk - z°sk†n° parametrñ
         mov       ax,ds:[bx+2]             ; poáet bajtñ na sektor
         mov       cs:[bajtsekt],ax         ; poáet bajtñ na sektor
         mov       al,ds:[bx+0fh]           ; poáet sektorñ FAT
         mov       cs:[sektfat],al          ; £schova poátu sektorñ FAT
         mul       byte ptr ds:[bx+8]       ; celkovò poáet sektorñ FAT
         inc       ax                       ; á°slo prvn°ho sektoru ROOT
         mov       cs:[sektroot],ax         ; á°slo sektoru ROOT
         mov       ax,ds:[bx+0dh]           ; poáet alokaán°ch blokñ dat
         dec       ax                       ; maxim†ln° á°slo alokaán°ho bloku
         mov       cs:[maxblok],ax          ; maxim†ln° alokaán° blok disku
         cmp       ax,0ff6h                 ; bude tabulka FAT16 ?
         jbe       InitI252                 ; je tabulka FAT12
         or        byte ptr cs:[parint25],2 ; nastaven° p©°znaku tabulky FAT16
InitI252:                                 ;* zji®tàn° celkovÇho poátu sektorñ
         xor       cx,cx                    ; CX <- 0
         mov       cl,ds:[bx+4]             ; maxim†ln° á°slo sektoru v bloku
         inc       cx                       ; poáet sektorñ v alokaán°m bloku
         mov       cs:[sektclus],cl         ; poáet sektorñ v alokaán°m bloku
         mul       cx                       ; vòpoáet poátu sektorñ dat celkem
         mov       cx,ds:[bx+0bh]           ; poáet rezervovanòch sektorñ
         mov       cs:[rezervs],cx          ; poáet rezervovanòch sektorñ
         add       ax,cx                    ; p©iáten° poátu rezervovanòch sekt.
         adc       dx,0                     ; p©enos do vy®®°ho slova
         mov       word ptr cs:[maxsekt],ax ; maxim†ln° sektoru disku - LOW
         mov       word ptr cs:[maxsekt+2],dx ; maxim†ln° sektoru disku - HIGH
         jz        InitI254                 ; poáet sektorñ nen° vàt®° neë FFFFh
         or        byte ptr cs:[parint25],3 ; nastaven° p©°znaku FAT16 a paketu

InitI254:or        byte ptr cs:[parint25],80h ; p©°znak zobrazen° disku
                                          ;* zji®tàn° velikosti disku
         mov       bx,dx                    ; £schova vy®®. slova poátu sektorñ
         mul       word ptr cs:[bajtsekt]   ; poáet bajtñ celkem - LOW
         mov       word ptr cs:[zobnum],ax  ; max. bajt - nië®° slovo
         mov       ax,dx                    ; p©enos do vy®®°ho slova
         xchg      ax,bx                    ; n†vrat vy®®°ho slova
         mul       word ptr cs:[bajtsekt]   ; poáet bajtñ celkem - HIGH
         add       ax,bx                    ; p©iáten° p©enosu z nië®°ho slova
         mov       word ptr cs:[zobnum+2],ax; max. bajt - vy®®° slovo

         call      hledclus                 ; nalezen° alokaán°ho bloku souboru

InitI25a:
         cmp       ax,cs:[maxblok]          ; kontrola maxim†ln°ho bloku
         ja        InitI259                 ; p©ekroáen maxim†ln° blok
         sub       ax,2
         jnc       InitI257
InitI259:mov       ax,cs:[sektroot]         ; á°slo sektoru ROOT
         xor       dx,dx
         jmp       short InitI258
InitI257:xor       bx,bx
         mov       bl,cs:[sektclus]         ; poáet sektorñ na alok. blok
         mul       bx                       ; vòpoáet sektoru
         add       ax,cs:[rezervs]
         adc       dx,0
InitI258:
         mov       bx,dx                    ; £schova vy®®°ho slova
         mul       word ptr cs:[bajtsekt]   ; nië®° slovo
         mov       word ptr cs:[zobbuf],ax  ; nië®° slovo offsetu
         mov       word ptr cs:[zobtop],ax  ; adresa zaá†tku zobrazenÇho textu
         mov       ax,bx                    ; AX<-vy®®° slovo
         mov       cx,dx                    ; £schova zbytku
         mul       word ptr cs:[bajtsekt]   ; vòpoáet offsetu
         add       ax,cx
         mov       word ptr cs:[zobbuf+2],ax
         mov       word ptr cs:[zobtop+2],ax
         xor       ax,ax
         mov       word ptr cs:[toppoz],ax
         mov       cs:[editnum],ax          ; poáet bajtñ v bufferu = 0
         mov       bh,80h                   ; p©epsat v®echny ©†dky
InitI255:pop       ds
         ret
; -----------------------------------------------------------------------------
;                      Skok na novò alokaán° blok
; -----------------------------------------------------------------------------
public   skokclust
skokclust:                                ;* skok na novò alok. blok F6

IFDEF    upver

         test      byte ptr cs:[parint25],80h ; je zobrazen° disku ?
         jz        skokcls6                 ; nen° zobrazen° disku
;         mov       si,offset bufclust
;         mov       ax,offset bufclst2
;         sub       ax,offset bufclst1
;         mov       ds:[si],ax               ; dÇlka bufferu
;         mov       byte ptr ds:[bufclst2],0 ; poáet p©edvoleb = 0

         call      setvysl                  ; vòsledek operace kalkul†toru
         mov       si,offset bufcalc        ; buffer kalkul†toru
         mov       word ptr ds:[si],132     ; velikost bufferu
         mov       byte ptr ds:[bufcalc2],1 ; poáet p©edvoleb = 1
         mov       word ptr ds:[bufcalc3],offset helpbuf ; text á°sla

         mov       di,offset txtzob10
         call      select                   ; zad†n° á°sla bloku
         call      windret
         jc        skokcls6                 ; p©eru®en° operace
         call      rozborcis                ; rozbor á°sla DX:AX
         push      ds
         jmp       InitI25a                 ; zmàna alokaán°ho bloku

skokcls6:xor       bx,bx

ENDIF
         ret
; -----------------------------------------------------------------------------
;                           LogickÇ sektory disku
; -----------------------------------------------------------------------------
public   ReadSekt
ReadSekt:                                 ;* áten° sektorñ z disku
                                            ; VSTUP: DX:AX=á°slo poá†t. sektoru
                                            ;        CX=poáet sektorñ
                                            ;        ES:BX=adresa bufferu
                                            ; VùSTUP: AX=chybovò k¢d (ZY;0=OK)

         pushf
         push      bx
         push      cx
         push      dx
         push      ds
         push      es
         push      es
         pop       ds

         mov       word ptr cs:[paket],ax   ; á°slo poá†teán°ho sektoru - LOW
         mov       word ptr cs:[paket+2],dx ; á°slo poá†teán°ho sektoru - HIGH
         mov       word ptr cs:[paket+4],cx ; poáet sektorñ
         mov       word ptr cs:[paket+6],bx ; offset adresy bufferu pro áten°
         mov       word ptr cs:[paket+8],ds ; segment adresy bufferu pro áten°
         mov       dx,ax                    ; á°slo sektoru - LOW
         mov       al,cs:[disk25]           ; disk pro operaci
         dec       al
         test      byte ptr cs:[parint25],1 ; je obsluha paketem ?
         jz        ReadSek2                 ; nen° obsluha paketem
         mov       cx,0ffffh                ; identifikace obsluhy paketem
         push      cs
         pop       ds                       ; DS <- CS segment s paketem
         mov       bx,offset paket          ; adresa paketu
ReadSek2:int       25h                      ; áten° sektorñ z disku
         pop       cx                       ; zru®en° registru p©°znakñ v z†sob.
         jc        ReadSek3                 ; je chyba
         xor       ax,ax                    ; p©°znak - operace OK
ReadSek3:pop       es
         pop       ds
         pop       dx
         pop       cx
         pop       bx
         popf
         or        ax,ax                    ; aktualizace p©°znaku ZF
         ret


code     ends

         end

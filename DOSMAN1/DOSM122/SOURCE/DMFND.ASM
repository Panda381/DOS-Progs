
; modul DOSMFND.ASM - zobrazen¡

; *****************************************************************************
;
;                          Hled n¡ soubor–
;
; *****************************************************************************

code     segment   public
         assume    cs:code,ds:code

;upver    label     near                     ; p©ep¡na‡ vy¨¨¡ verze

extrn    hlpram:near,buffind:byte,buffind1:byte,buffind2:byte,dekfile:near
extrn    select:near,outbuf:near,selbuf:byte,rozbflg:byte,inpkey:near
extrn    windret:near,txthled:byte,parint:byte,txthled3:byte
extrn    outtxt:near,outch1:near,rozbnam:byte,rozbext:byte
extrn    segend:word,topseg:word,nadadr:byte,editmax:word,rootdir:byte
extrn    all:byte,outch:near,loadpath:near,findcit:word,findsouc:dword
extrn    tisknm0:near,deknum:near,transtxt:near,center:near,kurzout:near
extrn    textsp3:byte,setkonc:near,textsp4:byte,editnum:word,edikurz:word
extrn    testbreak:near,txthled6:byte,zobrchyb:near,firstrad:word
extrn    edidrad:byte,skokax:near,inpkeyf:near,testshft:near
extrn    lowcase0:near,namel:byte,namer:byte,rozborn:near,tabr:byte
extrn    readdir:near,topret:near,aktdir:near,volbyh:near,txtchyb1:byte
extrn    testkey:near,outhelp:near,parbreak:word,tabhlfnd:word
extrn    mouseget:near,edikey:word,mouseon:near,mouseoff:near,mousepoz:word
extrn    flagsc:byte,getdispcx:near,getdispl:near,buffind3:word,outbuf4:byte
extrn    rozbdat:byte,zobrfilv:near,zobrfild:near,zobrfilc:near

public   hledej

hledej:                                   ;* vyhled v n¡ souboru ALT-F7

                                          ;* nastaven¡ voln‚ pamˆti
         mov       ax,ds:[segend]           ; segment konce pamˆti
         sub       ax,2                     ; rezerva
         sub       ax,ds:[topseg]           ; voln  pamˆŸ
         jnc       hledej1                  ; pamˆŸ dosta‡uje
hledej0: jmp       hledej9                  ; chyba - nedostatek pamˆti
hledej1: cmp       ax,1000h                 ; je vˆt¨¡ ne‘ 64 KB ?
         jb        hledej2                  ; nen¡ vˆt¨¡ ne‘ 64 KB
         mov       ax,0fffh                 ; omezen¡ na 64 KB
hledej2: mov       cl,4
         shl       ax,cl                    ; voln  kapacita (v bajtech)
         mov       ds:[editmax],ax          ; £schova velikosti bufferu
         mov       word ptr ds:[editnum],0  ; vynulov n¡ bufferu
         mov       word ptr ds:[firstrad],0 ; prvn¡ zobrazen˜ © dek
         mov       word ptr ds:[edikurz],-1 ; kurzor na za‡ tku
         mov       byte ptr ds:[edidrad],1  ; © dek s kurzorem
                                          ;* nastaven¡ p©edvolby
         mov       si,ds:[bp+4]             ; aktivn¡ adres ©
         lea       di,[outbuf4]             ; pracovn¡ buffer
         mov       ds:[buffind3],di         ; adresa cesty
         call      transtxt
         mov       al,"\"
         cmp       ds:[di-1],al             ; byl posledn¡ znak "\" ?
         je        hledej22                 ; byl posledn¡ znak "\"
         stosb
         xor       al,al
         stosb
hledej22:;lea       si,[all]
         ;call      transtxt
                                          ;* zad n¡ jm‚na souboru
         lea       si,[buffind]             ; buffer pro v˜bˆr
         mov       ax,offset buffind2
         sub       ax,offset buffind1       ; d‚lka bufferu
         mov       ds:[si],ax
         mov       byte ptr ds:[buffind2],1 ; po‡et p©edvoleb = 1
         lea       di,[txthled]             ; nadpis
         call      select                   ; zad n¡ hledan‚ho souboru
         jc        hledej0                  ; p©eru¨en¡ operace
                                          ;* nahrazen¡ mezer otazn¡ky
         test      byte ptr ds:[flagsc],8   ; byla zad na te‡ka ?
         jnz       hledej34                 ; te‡ka byla zad na
         lea       si,[rozbnam]             ; zadan‚ jm‚no souboru
         mov       cx,11                    ; d‚lka jm‚na s p©¡ponou
hledej3: lodsb                              ; na‡ten¡ znaku z bufferu
         cmp       al," "                   ; je oddˆlovac¡ mezera ?
         jne       hledej33                 ; nen¡ oddˆlovac¡ mezera
         mov       byte ptr ds:[si-1],"?"   ; n hradn¡ znak otazn¡ku
hledej33:loop      hledej3                  ; n hrada dal¨¡ho znaku
hledej34:
         call      hlpram                   ; zobrazen¡ r mu pro hled n¡
         call      kurzout                  ; vypnut¡ kurzoru
                                          ;* nastaven¡ v˜choz¡ho adres ©e
         mov       si,ds:[bp+4]             ; adresa p©¡stupov‚ cesty
         lodsb                              ; ozna‡en¡ aktivn¡ho disku
         sub       al,"A"                   ; korekce na ‡¡slo disku
         mov       dl,al                    ; ‡¡slo disku
         mov       ah,0eh
         int       21h                      ; nastaven¡ aktivn¡ho disku
         lea       dx,[rootdir]             ; z kladn¡ adres ©
         mov       ah,3bh                   ; funkce nastaven¡ adres ©e
         int       21h                      ; nastaven¡ z kladn¡ho adres ©e
         lea       si,[outbuf]              ; zadan˜ adres ©
         call      aktdir                   ; nastaven¡ aktivn¡ho adres ©e
                                          ;* dek¢dov n¡ jm‚na souboru
         or        byte ptr ds:[parint],8   ; p©¡znak operace hled n¡ souboru
         lea       si,[rozbflg]             ; zadan‚ jm‚no
         mov       byte ptr ds:[si],0
         lea       di,[selbuf]              ; pracovn¡ buffer
         push      di
         call      dekfile                  ; dek¢dov n¡ jm‚na souboru
         lea       di,[outbuf]              ; pracovn¡ buffer
         lea       si,[txthled3]            ; text "Hled m"
         call      transtxt                 ; zobrazen¡ textu
         pop       si
         call      transtxt                 ; zobrazen¡ jm‚na souboru
         mov       ax," "
         stosw
         lea       si,[outbuf]
         mov       cl,76
         mov       dx,1
         call      center
         call      mouseoff                 ; vypnut¡ my¨i
         call      outtxt
         call      mouseon                  ; zapnut¡ my¨i
         call      kurzout                  ; vypnut¡ kurzoru
                                          ;* prohled v n¡ soubor–
         call      hledx                    ; prohled v n¡ adres ©–

         cmp       word ptr cs:[editnum],0
         je        hledej4                  ; nen¡ ‘ d  polo‘ka
         dec       word ptr cs:[editnum]    ; zru¨en¡ koncov‚ 0
         call      hledhome                 ; za‡ tek seznamu
         call      hledend                  ; konec seznamu
hledej4:
         call      mouseoff                 ; vypnut¡ my¨i
         mov       al,1
         call      outch1
         mov       al,205                   ; horn¡ linka
         mov       dx,10
         mov       cx,50
         call      outch                    ; vymaz n¡ horn¡ linky
         call      mouseon                  ; zapnut¡ my¨i

         mov       bh,80h
         call      hledall

         push      cs
         pop       ds
         cmp       word ptr ds:[findcit],0  ; nalezen nˆjak˜ soubor ?
         jne       hledej7                  ; je nˆjak˜ soubor

         lea       di,[txthled6]            ; text "Soubor nenalezen !"
         lea       si,[txtchyb1]
         xor       al,al
         call      volbyh
         call      windret                  ; p–vodn¡ zobrazen¡ oken
         call      outhelp
         ret

hledej9: and       byte ptr ds:[parint],not 8 ; zru¨en¡ p©¡znaku hled n¡ souboru
         push      cs
         pop       ds
         push      cs
         pop       es
         call      windret                  ; n vrat zobrazen¡ okna
         call      outhelp
         ret

hledej7:                                  ;* je nˆjak˜ soubor
         call      mouseget                 ; vstup my¨i
         jz        hledej76
                                          ;* prav‚ tla‡¡tko
         mov       ax,011bh
         cmp       bl,11
         je        hledej79
                                          ;* lev‚ tla‡¡tko
         mov       ax,1c0dh
         cmp       bl,7                     ; je lev‚ tla‡¡tko
         je        hledej79                 ; je lev‚ tla‡¡tko 2x

         mov       dx,cs:[mousepoz]         ; pozice my¨i
         mov       ax,5000h                 ; kurzor dol–
         cmp       dh,cs:[edidrad]          ; © dek s kurzorem
         ja        hledej79                 ; je posun dol–
         mov       ax,4800h                 ; kurzor nahoru
         jb        hledej79                 ; je posun nahoru

hledej76:cmp       word ptr cs:[edikey],0
         jnz       hledej78
         call      testkey                  ; je p©ipraven znak ?
         jz        hledej7                  ; ‡ek n¡ na p©¡chod znaku
hledej78:lea       si,[tabhlfnd]            ; n povˆda pro vyhled v n¡
         call      inpkeyf                  ; vstup znaku s vyprazd¤ov n¡m
hledej79:

         cmp       al,27
         je        hledej9
         cmp       al,13
         je        hledent                  ; je nastaven¡ na polo‘ku
         lea       bx,[hledskok]            ; tabulka skok– pro hled n¡
         call      skokax
         jc        hledej7                  ; kl vesa neobslou‘ena

         call      hledall
         jmp       short hledej7


hledent:                                  ;* zvolen¡ polo‘ky ENTER
                                          ;* nalezen¡ konce polo‘ky
         mov       es,cs:[topseg]
         mov       di,cs:[edikurz]          ; polo‘ka s kurzorem
         cmp       byte ptr es:[di],0
         je        hledej9
         mov       cx,90
         xor       al,al
         repnz     scasb                    ; nalezen¡ konce polo‘ky
         sub       di,2                     ; adresa konce polo‘ky
                                          ;* nalezen¡ posledn¡ho znaku "\"
         mov       al,"\"
         std                                ; smˆr hled n¡ dol–
         repnz     scasb                    ; nalezen¡ znaku "\"
         cld                                ; smˆr hled n¡ nahoru
         inc       di                       ; n vrat adresy "\"
         xor       al,al                    ; oddˆlovac¡ bajt 00
         stosb                              ; konec cesty
         push      di                       ; adresa jm‚na souboru
                                          ;* p©enesen¡ cesty k adres ©i
         mov       si,cs:[edikurz]          ; adresa polo‘ky
         mov       ds,cs:[topseg]
         push      cs
         pop       es                       ; ES <- CS
         mov       di,cs:[bp+4]             ; adresa cesty k adres ©i
         call      transtxt                 ; p©enesen¡ cesty k adres ©i
                                          ;* p©enesen¡ jm‚na souboru
         pop       si                       ; adresa jm‚na souboru
         lea       di,[namel+1]             ; jm‚no souboru L
         lea       ax,[tabr]                ; tabulka prav‚ho okna
         cmp       ax,bp                    ; je to prav‚ okno ?
         jnz       hledent2                 ; je aktivn¡ lev‚ okno
         lea       di,[namer+1]             ; jm‚no souboru R
hledent2:mov       byte ptr es:[di-1],0
         call      rozborn                  ; zak¢dov n¡ jm‚na souboru
         push      cs
         pop       ds
         call      readdir                  ; na‡ten¡ nov‚ho adres ©e
         call      topret                   ; navr cen¡ horn¡ho © dku
         jmp       hledej9


hledskok label     byte                   ;* tabulka skok– pro hled n¡
         db        40h+10                   ; testuje se AH
         db        50h                      ; kurzor dol– DOWN
         dw        offset hleddown
         db        48h                      ; kurzor nahoru UP
         dw        offset hledup
         db        47h                      ; prvn¡ polo‘ka HOME
         dw        offset hledhome
         db        4fh                      ; posledn¡ polo‘ka END
         dw        offset hledend
         db        49h                      ; str nka nahoru PAGE UP
         dw        offset hledpgup
         db        51h                      ; str nka dol– PAGE DOWN
         dw        offset hledpgdn
         db        84h                      ; prvn¡ polo‘ka ^PAGE UP
         dw        offset hledhome
         db        76h                      ; posledn¡ polo‘ka ^PAGE DOWN
         dw        offset hledend
         db        8dh                      ; 6 © dk– nahoru ^UP
         dw        offset hledcup
         db        91h                      ; 6 © dk– dol– ^DOWN
         dw        offset hledcdown

         db        0


public   hledcup

hledcup:                                  ;* posun o 6 © dk– nahoru ^UP
         push      cx
         mov       cx,6
         jmp       short hledpgu1

public   hledpgup

hledpgup:                                 ;* str nka nahoru PAGE UP
         push      cx
         call      getdispcx
         sub       cx,2
hledpgu1:call      hledup
         jc        hledpgu2
         loop      hledpgu1
hledpgu2:pop       cx
         ret


public   hledcdown

hledcdown:                                ;* posun o 6 © dk– dol– ^DOWN
         push      cx
         mov       cx,6
         jmp       short hledpgd1


public   hledpgdn

hledpgdn:                                 ;* str nka nahoru PAGE DOWN
         push      cx
         call      getdispcx
         sub       cx,2
hledpgd1:call      hleddown
         jc        hledpgd2
         loop      hledpgd1
hledpgd2:pop       cx
         ret



public   hledhome

hledhome:                                 ;* prvn¡ polo‘ka HOME
         call      hledup
         jnc       hledhome
         ret


public   hledend

hledend:                                  ;* posledn¡ polo‘ka END
         call      hleddown
         jnc       hledend
         ret


public   hleddown

hleddown:                                   ;* posun kurzoru dol–
                                            ; VSTUP: CY=nebyl posun

         push      si
         push      cx
         mov       si,cs:[edikurz]          ; adresa kurzoru
         call      hlednext                 ; nalezen¡ dal¨¡ho © dku
         jc        hleddn5                  ; nen¡ dal¨¡ © dek
         mov       cs:[edikurz],si          ; nov  adresa kurzoru
         mov       bh,80h                   ; p©¡znak nov‚ho zobrazen¡
         call      testshft                 ; je stisknuta kl vesa SHIFT ?
         jnz       hleddn3                  ; kl vesa SHIFT je stisknuta
         inc       byte ptr cs:[edidrad]

         call      getdispcx
;         dec       cx
         cmp       byte ptr cs:[edidrad],cl ; je ji‘ posledn¡ © dek ?
         jb        hleddn4                  ; nen¡ je¨tˆ na konci
         dec       byte ptr cs:[edidrad]
hleddn3: mov       si,cs:[firstrad]         ; adresa prvn¡ho © dku
         call      hlednext                 ; nalezen¡ dal¨¡ho © dku
         jc        hleddn4                  ; nen¡ dal¨¡ © dek
         mov       cs:[firstrad],si
hleddn4: clc
hleddn5: pop       cx
         pop       si
         ret


public   hledup

hledup:                                   ;* posun kurzoru nahoru
                                            ; VSTUP: CY=nebyl posun

         push      si
         mov       si,cs:[edikurz]          ; adresa kurzoru
         call      hledpred                 ; nalezen¡ p©edchoz¡ho © dku
         jc        hledup5                  ; nen¡ dal¨¡ © dek
         mov       cs:[edikurz],si          ; nov  adresa kurzoru
         mov       bh,80h                   ; p©¡znak nov‚ho zobrazen¡
         call      testshft                 ; je stisknuta kl vesa SHIFT ?
         jnz       hledup2                  ; kl vesa SHIFT je stisknuta
         dec       byte ptr cs:[edidrad]
         cmp       byte ptr cs:[edidrad],1  ; je ji‘ prvn¡ © dek ?
         jae       hledup5                  ; nen¡ je¨tˆ na za‡ tku
         inc       byte ptr cs:[edidrad]
hledup2: mov       si,cs:[firstrad]         ; adresa prvn¡ho © dku
         call      hledpred                 ; nalezen¡ dal¨¡ho © dku
         jc        hledup4
         mov       cs:[firstrad],si
hledup4: clc
hledup5: pop       si
         ret


public   hlednext

hlednext:                                 ;* nalezen¡ dal¨¡ho © dku
                                            ; VSTUP: SI=adresa © dku
                                            ; VSTUP: CY=nen¡ dal¨¡ © dek
                                            ;         SI=adresa dal¨¡ho © dku
         push      ds
         mov       ds,cs:[topseg]           ; segment se seznamem
hlednxt1:inc       si
         cmp       si,cs:[editnum]
         cmc
         jc        hlednxt2                 ; je ji‘ konec
         cmp       byte ptr ds:[si-1],0     ; je dal¨¡ © dek ?
         jne       hlednxt1
         add       si,10
         jc        hlednxt2
         cmp       si,cs:[editnum]
         cmc
         jc        hlednxt2                 ; je ji‘ konec
         clc
         inc       si
hlednxt2:dec       si
         pop       ds
         ret


public   hledpred

hledpred:                                 ;* nalezen¡ p©edchoz¡ho © dku
                                            ; VSTUP: SI=adresa © dku
                                            ; VSTUP: CY=nen¡ dal¨¡ © dek
                                            ;         SI=adresa dal¨¡ho © dku
         push      ds
         mov       ds,cs:[topseg]           ; segment se seznamem
         or        si,si                    ; je ji‘ za‡ tek ?
         stc
         jz        hledpre2                 ; je ji‘ za‡ tek seznamu
         sub       si,10                    ; ode‡ten¡ informac¡ o souboru
         jc        hledpre2                 ; podte‡en¡
hledpre1:or        si,si                    ; je ji‘ za‡ tek ?
         jz        hledpre2                 ; je ji‘ za‡ tek seznamu
         dec       si                       ; dal¨¡ znak
         cmp       byte ptr ds:[si-1],0     ; je dal¨¡ © dek ?
         jne       hledpre1                 ; nalezen¡ konce p©ede¨l‚ho © dku
         clc
hledpre2:pop       ds
         ret



public   hledx

hledx:                                    ;* prohled v n¡ adres ©–

         mov       word ptr ds:[findcit],0
         mov       word ptr ds:[findsouc],0
         mov       word ptr ds:[findsouc+2],0

         call      hledadr                  ; prohled v n¡ jednoho adres ©e

         mov       word ptr ds:[parbreak],0 ; zru¨en¡ p©¡znaku p©eru¨en¡

         ret


public   hledadr

hledadr:                                  ;* prohled v n¡ jednoho adres ©e
                                            ; VSTUP: CY=p©eru¨en¡ operace
         call      mouseoff                 ; vypnut¡ my¨i
         mov       al,3
         call      outch1
         mov       dh,cs:[edidrad]
         mov       dl,2
         push      dx
         mov       al," "
         mov       cx,76
         call      outch
         pop       dx
         lea       di,[outbuf]
         push      di
         call      loadpath
         pop       si
         call      outtxt
         call      mouseon                  ; zapnut¡ my¨i
                                          ;* hled n¡ podadres ©–
         mov       ah,4eh
         lea       dx,[all]                 ; specifikace - v¨echny adres ©e
         mov       cx,17h                   ; atributy - adres ©e
hledadd1:int       21h                      ; nalezen¡ prvn¡ho podadres ©e
         jc        hledadd9                 ; nen¡ ji‘ dal¨¡ adres ©
         call      testbreak                ; test p©eru¨en¡
         jc        hledadr3                 ; p©eru¨en¡ operace
         call      testkey                  ; je stisknuta kl vesa ?
         jz        hledadd3                 ; nen¡ kl vesa
         call      inpkey                   ; zru¨en¡ kl vesy
         stc                                ; p©¡znak p©eru¨en¡ operace
         ret
                                          ;* hled n¡ v podadres ©i
hledadd3:test      byte ptr ds:[95h],10h    ; je to adres © ?
         jz        hledadd2                 ; nen¡ adres © - dal¨¡ soubor
         cmp       word ptr ds:[9eh],".."   ; je nadadres © ".." ?
         je        hledadd2
         cmp       word ptr ds:[9eh],"."    ; je adres © "." ?
         je        hledadd2
                                          ;* £schova tabulky
         mov       si,80h
         mov       cx,22                    ; po‡et slov k ulo‘en¡
hledadd4:lodsw
         push      ax                       ; £schova slova s definice
         loop      hledadd4                 ; dal¨¡ slovo
         push      si
                                          ;* p©epnut¡ adres ©e
         mov       dx,9eh                   ; jm‚no adres ©e
         mov       ah,3bh                   ; funkce nastaven¡ adres ©e
         int       21h                      ; nastaven¡ nov‚ho adres ©e
         jc        hledadd5                 ; adres © nenalezen
                                          ;* prohled v n¡ adres ©e
         call      hledadr                  ; prohled v n¡ adres ©e
         jc        hledad51                 ; p©eru¨en¡ operace
                                          ;* navr cen¡ adres ©e
         lea       dx,[nadadr]              ; cesta k nadadres ©i ".."
         mov       ah,3bh                   ; funkce nastaven¡ adres ©e
         int       21h                      ; navr cen¡ p–vodn¡ho adres ©e
hledadd5:clc
hledad51:                                 ;* navr cen¡ tabulky
         pop       di
         mov       cx,22                    ; po‡et slov k ulo‘en¡
hledadd6:dec       di
         dec       di
         pop       ax                       ; navr cen¡ slova
         mov       ds:[di],ax
         loop      hledadd6                 ; dal¨¡ slovo
         jc        hledadr3                 ; p©eru¨en¡ operace
                                          ;* dal¨¡ soubor
hledadd2:mov       ah,4fh                   ; funkce nalezen¡ dal¨¡ho adres ©e
         jmp       short hledadd1           ; dal¨¡ adres ©


hledadd9:                                 ;* hled n¡ souboru v adres ©i
         lea       dx,[selbuf]              ; po‘adovan‚ jm‚no souboru
         mov       cx,110111b               ; atributy - soubory i adres ©e
         mov       ah,4eh
hledadr1:int       21h                      ; nalezen¡ prvn¡ho souboru
         jnc       hledadr5                 ; nalezen dal¨¡ soubor
         clc
hledadr3:ret
                                          ;* ulo‘en¡ souboru do seznamu
hledadr5:lea       di,[outbuf]              ; pracovn¡ buffer
         mov       al," "
         stosb
         mov       al,2
         stosb                              ; nastaven¡ zv˜raznˆn‚ho textu
         push      di
         inc       word ptr ds:[findcit]
         mov       ax,ds:[findcit]
         xor       dx,dx
         call      deknum
         lea       si,[textsp3]             ; text "soubor"
         call      transtxt
         pop       si
         call      setkonc                  ; nastaven¡ koncovky
         mov       al," "
         stosb
         mov       ax,".."
         stosw
         stosw
         stosw
         mov       ax,2*256+" "
         stosw

         mov       ax,ds:[9ah]              ; velikost souboru - ni‘¨¡ slovo
         add       word ptr ds:[findsouc],ax
         mov       ax,ds:[9ch]
         adc       word ptr ds:[findsouc+2],ax
         mov       ax,word ptr ds:[findsouc]
         mov       dx,word ptr ds:[findsouc+2]
         push      di
         call      deknum
         lea       si,[textsp4]             ; text "bajt"
         call      transtxt
         pop       si
         call      setkonc                  ; nastaven¡ koncovky
         mov       ax," "
         stosw

         call      mouseoff                 ; vypnut¡ my¨i
         mov       al,1
         call      outch1
         call      getdispl
         mov       dl,1
;         mov       dx,24*256+1
         push      dx
         mov       al,205                   ; vodorovn  linka
         mov       cx,78
         call      outch
         pop       dx
         lea       si,[outbuf]              ; pracovn¡ buffer
         call      center                   ; centrov n¡ textu
         call      outtxt
         call      mouseon                  ; zapnut¡ my¨i
         call      hledstore                ; ulo‘en¡ jm‚na souboru
         call      hleddown                 ; posun kurzoru dol–
         call      hledall                  ; zobrazen¡ soubor–
                                          ;* dal¨¡ soubor
hledadr2:
         call      testbreak                ; test p©eru¨en¡
         jc        hledad29                 ; p©eru¨en¡ operace
         call      testkey                  ; je stisknuta kl vesa ?
         jz        hledad28                 ; nen¡ kl vesa
         call      inpkey                   ; zru¨en¡ kl vesy
hledad29:stc                                ; p©¡znak p©eru¨en¡ operace
         ret

hledad28:mov       ah,4fh                   ; funkce nalezen¡ dal¨¡ho souboru
         jmp       hledadr1                 ; nalezen¡ dal¨¡ho souboru


hledstore:                                ;* ulo‘en¡ jm‚na souboru do bufferu
         mov       di,ds:[editnum]          ; konec dat v bufferu
         or        di,di
         jz        hledst1
         dec       di
hledst1: cmp       di,-88                   ; rezerva do 64 KB
         ja        hledst7                  ; p©ete‡en¡ bufferu
         push      di
         add       di,88                    ; rezerva
         cmp       di,ds:[editmax]          ; buffer zaplnˆn ?
         pop       di
         ja        hledst7                  ; p©ete‡en¡ bufferu
         mov       cs:[edikurz],di          ; nov  adresa kurzoru
         mov       es,ds:[topseg]           ; segment k ulo‘en¡ dat
         call      loadpath                 ; na‡ten¡ cesty k souboru
         xor       al,al
         mov       cx,70
         repnz     scasb                    ; nalezen¡ konce cesty
         dec       di
         mov       al,"\"                   ; znak konce cesty
         cmp       byte ptr es:[di-1],al    ; je znak oddˆlova‡e cesty ?
         je        hledst4                  ; je oddˆlova‡ cesty
         stosb                              ; ulo‘en¡ oddˆlova‡e cesty
hledst4: mov       bh,ds:[95h]              ; atributy souboru
         mov       si,9eh                   ; jm‚no souboru
hledst5: lodsb                              ; na‡ten¡ znaku
         or        al,al                    ; je ji‘ konec textu ?
         jz        hledst6                  ; konec
         test      bh,16h                   ; je adres © nebo souboru SYS/HID ?
         jnz       hledst52                 ; je adres © nebo souboru SYS/HID
         call      lowcase0
hledst52:stosb                              ; ulo‘en¡ znaku
         and       bh,not 6                 ; zru¨en¡ p©¡znak– SYS/HID
         jmp       short hledst5
hledst6: xor       ax,ax
         stosb
         mov       si,95h
         movsb                              ; atributy polo‘ky
         mov       si,9ah
         movsw
         movsw                              ; velikost souboru
         mov       si,98h
         movsw                              ; datum
         mov       si,96h
         movsw                              ; ‡as
         stosw                              ; koncov  0
         push      cs
         pop       es
         mov       ds:[editnum],di          ; nov  adresa konce
hledst7: ret




public   hledall

hledall:                                  ;* zobrazen¡ obrazovky
                                            ; VSTUP: CX=po‡et © dk–
         push      cx
         push      dx
         push      si
         mov       si,cs:[firstrad]         ; adresa prvn¡ho © dku
         mov       dh,1                     ; © dek k zobrazen¡
         call      getdispcx
         dec       cx
;         mov       cx,23
hledall1:call      hledlin                  ; zobrazen¡ © dku
         inc       dh
         loop      hledall1
         call      kurzout                  ; vypnut¡ kurzoru
         pop       si
         pop       dx
         pop       cx
         ret


public   hledlin

hledlin:                                  ;* zobrazen¡ © dku
                                            ; VSTUP: SI=adresa textu
                                            ;        DH=© dek na obrazovce

         call      mouseoff                 ; vypnut¡ my¨i
         push      ax
         push      cx
         push      dx
         push      ds
         mov       dl,2                     ; po‡ te‡n¡ pozice
         cmp       si,cs:[edikurz]          ; je © dek s kurzorem ?
         mov       al,1
         jne       hledlin0                 ; nen¡ kurzor
         cmp       word ptr cs:[editnum],0
         je        hledlin0
         mov       al,3                     ; kurzor
         mov       cs:[edidrad],dh          ; © dek s kurzorem
hledlin0:call      outch1
         mov       cx,77
         cmp       si,cs:[editnum]          ; dosa‘eno konce seznamu ?
         jae       hledlin5                 ; je konec seznamu
         mov       cx,51
ifndef   upver
         mov       cx,76
endif
         mov       ds,cs:[topseg]
hledlin1:cmp       si,cs:[editnum]          ; dosa‘eno konce seznamu ?
         jae       hledlin5                 ; je konec seznamu
         lodsb
         or        al,al
         jz        hledlin4
         jcxz      hledlin1
         call      outch1
         loop      hledlin1
         jmp       short hledlin1
hledlin4:call      hledlatr                 ; zobrazen¡ dopl¤uj¡c¡ch informac¡
hledlin5:mov       al," "
         call      outch                    ; vymaz n¡ zbytku © dku
         pop       ds
         pop       dx
         pop       cx
         pop       ax
         call      mouseon                  ; zapnut¡ my¨i
         ret

hledlatr:                                 ;* zobrazen¡ dopl¤uj¡c¡ch atribut–
         mov       al," "
         call      outch                    ; vymaz n¡ zbytku © dku
         push      dx
         push      si
         push      di
         push      ds
         push      es
         push      cs
         pop       es
         mov       di,offset rozbflg
         movsb
         mov       di,offset rozbdat
         movsw
         movsw                              ; velikost
         movsw                              ; datum
         movsw                              ; ‡as
         push      cs
         pop       ds

IFDEF    upver
         mov       dl,53
         mov       si,offset rozbflg
         mov       al,186                   ; svisl  ‡ ra
         call      outch1                   ; zobrazen¡ oddˆlovac¡ ‡ ry
         call      zobrfilv                 ; zobrazen¡ velikosti souboru
         mov       al,179                   ; svisl  ‡ ra
         call      outch1                   ; zobrazen¡ oddˆlovac¡ ‡ ry
         call      zobrfild                 ; zobrazen¡ data souboru
         mov       al,179                   ; svisl  ‡ ra
         call      outch1                   ; zobrazen¡ oddˆlovac¡ ‡ ry
         call      zobrfilc                 ; zobrazen¡ ‡asu souboru
ENDIF

         pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         add       si,10
         mov       cx,26

IFDEF    upver
         cmp       si,cs:[editnum]
         ja        hledat4
ENDIF
         xor       cx,cx

hledat4: ret

code     ends

         end

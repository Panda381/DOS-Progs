
; modul DOSMMEN.ASM - u‘ivatelsk‚ volby

; *****************************************************************************
;
;                          U‘ivatelsk‚ volby
;
; *****************************************************************************

code     segment   public
         assume    cs:code,ds:code

extrn    outbuf:byte,txtchyb:byte,transtxt:near,txtmenu:byte,txtchyb1:byte
extrn    volbyh:near,windret:near,soubmen:byte,inpid:word,pathhome:byte
extrn    segend:word,editnum:word,topseg:word,setwsel:near,txtmen:byte
extrn    selwin:near,inpkey:near,sellin:word,firstsel:byte,zobrlsel:byte
extrn    col3:byte,col7:byte,col19:byte,kurzsel:byte,atribsel:byte,numselb:word
extrn    selbuf:byte,ukazsel:word,topsel:word,pocradsl:byte,obrlin:near
extrn    highcase:near,outtxt:near,skokax:near,radkusel:word,kurzout:near
extrn    edikey:word,testkey:near,msgcek:near,topret:near,execute:near
extrn    getkurz:near,outch1:near,inpkeyf:near,soubext:byte,cmpfile:near
extrn    rozbor:near,rozbset:byte,bufwin:byte,identnm:byte,getnakt:near
extrn    aktdir:near,rootdir:byte,parbreak:word,inpkeys:near
extrn    menuprf1:byte,menuprf2:byte,menuprf3:byte,mouseon:near,mouseoff:near
extrn    conf3:byte,presmen:byte,windretx:near

; -----------------------------------------------------------------------------
public   exten

exten:                                    ;* operace podle p©¡pony souboru

         push      cs
         pop       ds
         push      cs
         pop       es
                                          ;* sestaven¡ cesty k DOSM.EXT
         lea       di,[outbuf]              ; buffer pro ulo‘en¡ jm‚na programu
         push      di
         lea       si,[pathhome]            ; cesta k dom c¡mu adres ©i
         call      transtxt
         mov       al,"\"
         cmp       byte ptr es:[di-1],al    ; je posledn¡ znak "\" ?
         je        extent2                  ; posledn¡ znak je ji‘ "\"
         stosb                              ; oddˆlova‡ cesty a jm‚na programu
extent2: lea       si,[soubext]             ; jm‚no souboru DOSM.EXT
         mov       cx,12
         rep       movsb                    ; p©enesen¡ jm‚na programu
         pop       dx                       ; jm‚no programu DOSM
                                          ;* otev©en¡ souboru
         mov       ax,3d00h                 ; funkce otev©en¡ souboru pro ‡ten¡
         int       21h                      ; otev©en¡ souboru pro ‡ten¡
         mov       bx,ax                    ; identifik tor souboru
         jc        extent9                  ; soubor nenalezen
                                          ;* nastaven¡ velikosti souboru
         mov       ax,ds:[segend]           ; segment konce pamˆti
         sub       ax,2                     ; rezerva
         sub       ax,ds:[topseg]           ; voln  pamˆŸ
         jc        extent9                  ; pamˆŸ nedosta‡uje
         cmp       ax,1000h                 ; je vˆt¨¡ ne‘ 64 KB ?
         jb        extent4                  ; nen¡ vˆt¨¡ ne‘ 64 KB
         mov       ax,0fffh                 ; omezen¡ na 64 KB
extent4: mov       cl,4
         shl       ax,cl                    ; voln  kapacita (v bajtech)
                                          ;* na‡ten¡ souboru do pamˆti
         push      bx                       ; identifik tor souboru
         mov       cx,ax                    ; maxim ln¡ d‚lka dat
         mov       ah,3fh
         mov       ds,ds:[topseg]           ; segment pro ulo‘en¡ dat
         xor       dx,dx                    ; offset adresy k ulo‘en¡
         int       21h                      ; na‡ten¡ dat do pamˆti
         mov       cs:[editnum],ax          ; po‡et bajt– dat v pamˆti
         pop       bx                       ; identifik tor souboru
         push      cs
         pop       ds
                                          ;* uzav©en¡ souboru
         push      ax
         pushf
         mov       ah,3eh                   ; funkce uzav©en¡ souboru
         int       21h                      ; uzav©en¡ souboru
         popf
         pop       ax
         jc        extent9                  ; chyba operace
         or        ax,ax
         jz        extent9                  ; nen¡ ‘ dn˜ znak v souboru

         xor       si,si                    ; po‡ te‡n¡ adresa v souboru
extent5:                                  ;* test, zda je pr zdn˜ © dek
         call      mendell                  ; zji¨tˆn¡ d‚lky © dku
         cmp       al,2
         jb        extent8                  ; je kr tk˜ © dek
         xor       cx,cx
         mov       cl,al                    ; d‚lka © dku
         push      si
extentb: call      menchr                   ; na‡ten¡ dal¨¡ho znaku
         jc        extentc                  ; nen¡ dal¨¡ znak
         cmp       al,32
         ja        extentc                  ; je platn˜ znak
         loop      extentb                  ; dal¨¡ znak
extentc: pop       si
         jc        extent8                  ; je pr zdn˜ © dek

         call      exttest                  ; test, zda je nalezen soubor
         jc        extent8                  ; soubor nen¡ nalezen

                                          ;* nalezen¡ za‡ tku jm‚na
extent6: call      menchr                   ; dal¨¡ znak
         jc        extent9                  ; konec
         cmp       al,33
         jb        extent6
                                          ;* nalezen¡ za‡ tku p©¡kazu
extent7: cmp       al,33
         jb        extenta
         cmp       al,":"
         je        extenta
         cmp       al,"/"
         je        extenta
         call      menchr
         jc        extent9
         jmp       short extent7

extenta: jmp       menexec                  ; proveden¡ p©¡kazu

extent8: call      mennxl                   ; nalezen¡ za‡ tku dal¨¡ho © dku
         jnc       extent5                  ; je dal¨¡ © dek

extent9: ret                                ; n vrat - p©¡pona nenalezena

; -----------------------------------------------------------------------------
public   exttest

exttest:                                  ;* test, zda odpov¡d  jm‚no souboru
         push      si
         push      cs
         pop       es
                                          ;* p©enesen¡ © dku textu
         lea       di,[bufwin]              ; pracovn¡ buffer
         call      mendell                  ; zji¨tˆn¡ d‚lky © dku
         cmp       al,3
         jb        exttest8                 ; p©¡li¨ kr tk˜ © dek
         mov       ds,cs:[topseg]           ; segment s textem
         xor       ah,ah
         mov       cx,ax                    ; d‚lka © dku
         push      di
         rep       movsb                    ; p©enesen¡ © dku
         xor       al,al
         stosb
         pop       si                       ; SI <- adresa textu
         push      cs
         pop       ds                       ; DS <- CS
                                          ;* rozbor textu
         call      rozbor                   ; rozbor textu
         call      getkurz                  ; adresa kurzoru
         push      cs
         pop       es
         lea       di,[rozbset]             ; rozbor jm‚na
         mov       byte ptr es:[di],0       ; atributy - norm ln¡ soubor
         call      cmpfile                  ; porovn n¡ soubor–
         je        exttest8                 ; soubor odpov¡d 
         mov       byte ptr es:[di],6
         call      cmpfile
         je        exttest8
         stc
exttest8:pop       si
         push      cs
         pop       ds
         ret

; -----------------------------------------------------------------------------
public   menu

menu:                                     ;* u‘ivatelsk‚ volby F2
         and       byte ptr ds:[conf3],not 2 ; zru¨en¡ po‘adavku u‘iv. volby

         call      msgcek                   ; hl ¨en¡ "‡ekejte"
                                          ;* pokus o nalezen¡ v akt. adres ©i
         mov       si,cs:[bp+4]             ; aktivn¡ adres ©
         call      aktdir                   ; nastaven¡ aktu ln¡ho adres ©e
         jc        menu002                  ; chyba
                                          ;* otev©en¡ souboru
         lea       dx,[soubmen]             ; jm‚no souboru DOSM.MNU
         mov       ax,3d00h                 ; funkce otev©en¡ souboru pro ‡ten¡
         int       21h                      ; otev©en¡ souboru pro ‡ten¡
         jnc       menu003                  ; soubor nalezen OK
;                                          ;* pokus o nalezen¡ v z kladn¡m adres.
;         cmp       byte ptr ds:[si+3],0     ; byl to ji‘ z kladn¡ adres © ?
;         je        menu002                  ; byl to ji‘ z kladn¡ adres ©
;         lea       si,[rootdir]             ; ozna‡en¡ z kladn¡ho adres ©e
;         call      aktdir                   ; nastaven¡ z kladn¡ho adres ©e
;         jc        menu002                  ; chyba
;
;         lea       dx,[soubmen]             ; jm‚no souboru DOSM.EXT
;         mov       ax,3d00h                 ; funkce otev©en¡ souboru pro ‡ten¡
;         int       21h                      ; otev©en¡ souboru pro ‡ten¡
;         jnc       menu003                  ; soubor nalezen OK
;
menu002: mov       word ptr cs:[parbreak],0 ; zru¨en¡ p©¡znaku chyby
                                          ;* sestaven¡ cesty k MNSHELL.MNU
         lea       di,[outbuf]              ; buffer pro ulo‘en¡ jm‚na programu
         push      di
         lea       si,[pathhome]            ; cesta k dom c¡mu adres ©i
menu1:   lodsb
         stosb
         or        al,al
         jnz       menu1                    ; nen¡ je¨tˆ konec - dal¨¡ znak
         dec       di                       ; n vrat konce ©etˆzce
         mov       al,"\"
         cmp       byte ptr es:[di-1],al    ; byl posledn¡ znak "\" ?
         je        menu2                    ; posledn¡ znak je ji‘ "\"
         stosb                              ; oddˆlova‡ cesty a jm‚na programu
menu2:   lea       si,[soubmen]             ; jm‚no souboru MNSHELL.MNU
         mov       cx,12
         rep       movsb                    ; p©enesen¡ jm‚na programu
         pop       dx                       ; jm‚no programu MNSHELL
                                          ;* otev©en¡ souboru
         mov       ax,3d00h                 ; funkce otev©en¡ souboru pro ‡ten¡
         int       21h                      ; otev©en¡ souboru pro ‡ten¡
menu003: mov       bx,ax                    ; identifik tor souboru
         jnc       menu3                    ; soubor otev©en OK
menu21:                                   ;* chyba - soubor nenalezen
         lea       di,[outbuf]
         push      di
         lea       si,[txtchyb]
         call      transtxt
         lea       si,[txtmenu]             ; text "Soubor voleb nenalezen !"
         call      transtxt
         pop       di
         lea       si,[txtchyb1]            ; polo‘ka "OK"
         xor       al,al
         call      volbyh
         call      windret
         ret

menu3:                                    ;* ur‡en¡ voln‚ pamˆti
         mov       ax,ds:[segend]           ; segment konce pamˆti
         sub       ax,2                     ; rezerva
         sub       ax,ds:[topseg]           ; voln  pamˆŸ
         jc        menu21                   ; pamˆŸ nedosta‡uje
         cmp       ax,1000h                 ; je vˆt¨¡ ne‘ 64 KB ?
         jb        menu4                    ; nen¡ vˆt¨¡ ne‘ 64 KB
         mov       ax,0fffh                 ; omezen¡ na 64 KB
menu4:   mov       cl,4
         shl       ax,cl                    ; voln  kapacita (v bajtech)
                                          ;* na‡ten¡ souboru do pamˆti
         push      bx                       ; identifik tor souboru
         mov       cx,ax                    ; maxim ln¡ d‚lka dat
         mov       ah,3fh
         mov       ds,ds:[topseg]           ; segment pro ulo‘en¡ dat
         xor       dx,dx                    ; offset adresy k ulo‘en¡
         int       21h                      ; na‡ten¡ dat do pamˆti
         mov       cs:[editnum],ax          ; po‡et bajt– dat v pamˆti
         pop       bx                       ; identifik tor souboru
         push      cs
         pop       ds
                                          ;* uzav©en¡ souboru
         push      ax
         pushf
         mov       ah,3eh                   ; funkce uzav©en¡ souboru
         int       21h                      ; uzav©en¡ souboru
         popf
         pop       ax
         jc        menu21                   ; chyba operace
         or        ax,ax
         jz        menu21                   ; nen¡ ‘ dn˜ znak v souboru

                                          ;* nastaven¡ parametr– okna
         call      testmen                  ; test polo‘ek voleb
         lea       di,[txtmen]              ; text nadpisu
         call      setwsel                  ; nastaven¡ parametr– okna pro volby
         mov       byte ptr cs:[kurzsel],0  ; kurzor na prvn¡m © dku
         mov       byte ptr cs:[firstsel],0 ; prvn¡ zobrazen˜ © dek
         call      topret                   ; n vrat horn¡ho © dku
         call      selwin                   ; vykreslen¡ okna pro volby
         mov       bh,80h                   ; p©¡znak p©ekreslen¡ okna
;         call      menuall                  ; zobrazen¡ v¨ech polo‘ek voleb
;         mov       bh,80h
menu44:  mov       al,byte ptr cs:[kurzsel] ; pozice kurzoru
         cmp       al,cs:[presmen]          ; nalezena odpov¡daj¡c¡ polo‘ka ?
         jae       menu6                    ; nalezena odpov¡daj¡c¡ polo‘ka
         call      menudown                 ; posun o polo‘ku dol–
         jnc       menu44                   ; dal¨¡ posun
menu6:   call      menuall                  ; zobrazen¡ v¨ech polo‘ek voleb
menu61:  call      kurzout                  ; vypnut¡ kurzoru
         call      inpkeys                  ; vstup znaku
;         push      cx
;         xor       ax,ax
;         xchg      ax,cs:[edikey]           ; vyjmut¡ znaku z bufferu
;         or        ax,ax                    ; je nˆjak  kl vesa ?
;         jnz       menu610                  ; byla nˆjak  kl vesa
;         call      inpkey                   ; vstup znaku
;menu610: mov       cx,ax                    ; £schova znaku
;menu612: call      testkey                  ; test p©ipraven‚ kl vesy
;         jz        menu611                  ; nen¡ p©ipraven ‘ dn˜ znak
;         cmp       ax,cx                    ; je stejn˜ znak ?
;         jne       menu611                 ; nen¡ stejn˜ znak
;         call      inpkey                   ; vypr zdnˆn¡ bufferu kl vesnice
;         mov       cs:[edikey],ax           ; £schova znaku
;         jmp       short menu612           ; dal¨¡ znak
;menu611: mov       ax,cx                    ; n vrat znaku
;         pop       cx

         cmp       al,27
         je        menu9

         cmp       al,13
         je        menu7
         cmp       al,32
         jae       menu64
         or        ah,ah
         jz        menu64

         lea       bx,[menuskok]            ; tabulka skok– voleb
         call      skokax                   ; obsluha funkce
         jnc       menu6
menu64:
         call      menuhled                 ; nalezen¡ kl vesy v textu
         jc        menu61                   ; kl vesa nenalezena

         mov       byte ptr cs:[kurzsel],al ; nov  pozice kurzoru
         mov       cs:[presmen],al          ; ulo‘en¡ polo‘ky
         call      menuall                  ; nov‚ zobrazen¡ polo‘ek
         jmp       short menu72
menu7:   mov       al,byte ptr cs:[kurzsel] ; pozice kurzoru
         mov       cs:[presmen],al          ; ulo‘en¡ polo‘ky
         call      askmen                   ; nalezen¡ adresy polo‘ky
menu72:
         call      mennxl                   ; adresa dal¨¡ho © dku
         jc        menu61                   ; nen¡ dal¨¡ © dek
         push      si
         call      mendekod                 ; je © dek polo‘ky ?
         pop       si
         jnc       menu61                   ; je © dek polo‘ky - chyba
         test      byte ptr cs:[conf3],1    ; je automatick‚ menu ?
         jz        menexec                  ; nen¡ automatick‚ menu
         or        byte ptr cs:[conf3],2    ; p©¡znak po‘adavku automat. menu
         jmp       short menexec            ; proveden¡ p©¡kazu

menu9:   call      windretx
         mov       word ptr cs:[editnum],0  ; zru¨en¡ dat v pamˆti
         ret

;public   inpkeym
;inpkeym:                                  ;* vstup znaku pro menu
;                                            ; VSTUP:DL=po‡ tek okna
;                                            ;       DH=© dek okna
;                                            ;       CL=¨¡©ka okna
;                                            ;       CH=v˜¨ka okna
;
;         call      mouseget                 ; vstup z my¨i
;         jz        inpkeym7                 ; nen¡ ‘ dn‚ tla‡¡tko my¨i
;                                          ;* test kl vesy ESC
;         mov       ax,011bh                 ; ESC
;         cmp       bl,11                    ; uvolnˆn¡ prav‚ho tla‡¡tka ?
;         je        inpkeym9                 ; je ESC
;                                          ;* kontrola hranic
;         mov       al,dl
;         cmp       al,byte ptr cs:[mousepoz]
;         ja        inpkeym7                 ; kurzor p©¡li¨ vlevo
;         add       al,cl
;         cmp       al,byte ptr cs:[mousepoz]
;         jbe       inpkeys4                 ; kurzoru p©¡li¨ vpravo
;         mov       al,dh
;         add       al,ch
;         cmp       al,byte ptr cs:[mousepoz+1]
;         jbe       inpkeys4                 ; kurzor p©¡li¨ dole
;         mov       al,byte ptr cs:[mousepoz+1]
;         sub       al,dh                    ; relativn¡ © dek
;         jb        inpkeys4                 ; kurzor p©¡li¨ naho©e
;                                          ;* funkce ENTER
;         cmp       bl,10                    ; uvolnˆn¡ lev‚ho tla‡¡tka ?
;         jne       inpkeys3                 ; nen¡ funkce ENTER
;         mov       ax,1c0dh                 ; ENTER
;         jmp       short inpkeys6
;inpkeys3:                                 ;* v˜po‡et ‡¡sla polo‘ky
;         sub       al,2                     ; horn¡ okraj
;         jnc       inpkeys1                 ; nen¡ v horn¡m okraji
;         xor       al,al
;inpkeys1:cbw                                ; offset © dku
;         add       ax,cs:[firstsel]         ; po‘adovan  polo‘ka
;                                          ;* test dosa‘en¡ polo‘ky
;         cmp       ax,cs:[kurzsel]          ; je ji‘ polo‘ky dosa‘eno ?
;         je        inpkeys4                 ; polo‘ky je ji‘ dosa‘eno
;         mov       ax,4800h                 ; kurzor nahoru
;         jb        inpkeys6                 ; je posun nahoru
;         mov       ax,5000h                 ; kurzor dol–
;         jmp       short inpkeys6           ; posun dol–
;
;
;
;
;
;
;inpkeym7:cmp       word ptr cs:[edikey],0   ; je nˆjak˜ znak v bufferu ?
;         jne       inpkeym8                 ; v bufferu je nˆjak˜ znak
;         call      testkey                  ; je p©ipraven znak ?
;         jz        inpkeym                  ; ‡ek n¡ na p©¡chod znaku
;inpkeym8:call      inpkeyf                  ; vstup znaku s vyprazd¤ov n¡m
;inpkeym9:ret
;
;

public   menexec

menexec:                                  ;* proveden¡ p©¡kazu

         lea       di,[outbuf]              ; pracovn¡ buffer
         mov       dx,si                    ; DX=0 p©¡znak, ‘e se text nezobraz¡
                                          ;* vypu¨tˆn¡ po‡ te‡n¡ch oddˆlova‡–
menexe1: call      menchr                   ; na‡ten¡ znaku
         jc        menexe8                  ; konec textu
         cmp       al," "
         je        menexe1                  ; je mezera
         cmp       al,9
         je        menexe1
         dec       si                       ; n vrat znaku
menexe2: call      menchr                   ; na‡ten¡ dal¨¡ho znaku
         jc        menexe8                  ; konec textu
menexe21:cmp       al,13
         je        menexe8                  ; konec © dku
         cmp       al,"%"                   ; je parametr ?
         jne       menexe6                  ; nen¡ parametr

         call      menchr                   ; na‡ten¡ ‡¡sla parametru
         lea       bx,[menexsk]             ; tabulka skok–
         call      skokax                   ; proveden¡ skoku
         jnc       menexe63                 ; znak byl platn˜

menexe6: stosb
menexe63:cmp       di,offset outbuf+126     ; je konec textu ?
         jb        menexe2                  ; dal¨¡ znak
menexe8: xor       al,al
         stosb
         lea       si,[outbuf]
         jmp       execute                  ; proveden¡ p©¡kazu


menexsk  label     byte                   ;* tabulka skok– podle parametr–
         db        00h+5                    ; testuje se AL
         db        '0'                      ; specifikace programu
         dw        offset menexc0
         db        '1'                      ; jm‚no souboru + p©¡pona
         dw        offset menexc1
         db        '2'                      ; neaktivn¡ okno
         dw        offset menexc2
         db        '3'                      ; domovsk˜ adres ©
         dw        offset menexc3
         db        '4'                      ; neaktivn¡ disk
         dw        offset menexc4
         db        0

menexc0:                                  ;* p©enesen¡ jm‚na programu
         call      menexc3                  ; p©enesen¡ dom c¡ cesty
         lea       ax,[identnm]             ; jm‚no programu DOSMAN.EXE
         call      menextr                  ; p©enos textu
         ret

menexc1:                                  ;* p©enesen¡ jm‚na s p©¡ponou
         call      menexn                   ; p©enesen¡ jm‚na
         mov       al,"."
         stosb                              ; ulo‘en¡ oddˆlovac¡ te‡ky
         call      menext                   ; p©enesen¡ p©¡pony
         ret

menexc2:                                  ;* neaktivn¡ adres ©
         push      bp
         call      getnakt                  ; neaktivn¡ okno
         mov       ax,cs:[bp+4]             ; adresa p©¡stup. cesty
         pop       bp
         jmp       short menexc33           ; ulo‘en¡ oddˆlova‡e "\"

public   menexc3
menexc3:                                  ;* domovsk˜ adres ©
         lea       ax,[pathhome]            ; ozna‡en¡ domovsk‚ cesty
menexc33:call      menextr
         mov       al,"\"
         cmp       es:[di-1],al             ; byl posledn¡ znak "\" ?
         je        menexhp5                 ; byl posledn¡ znak "\"
         stosb
menexhp5: ret

menexc4:                                  ;* p©enesen¡ jm‚na

menexn:                                   ;* p©enesen¡ jm‚na souboru
         push      ds
         push      si
         call      getkurz                  ; poskytnut¡ adresy kurzoru
         inc       si
         mov       cx,8                     ; d‚lka jm‚na
menexn3: lodsb                              ; znak jm‚na souboru
         cmp       al," "
         jbe       menexn4                  ; konec jm‚na
         stosb
         loop      menexn3                  ; dal¨¡ znak
menexn4: pop       si
         pop       ds
         ret


menext:                                   ;* p©enesen¡ p©¡pony souboru
         push      ds
         push      si
         call      getkurz                  ; poskytnut¡ adresy kurzoru
         add       si,9
         mov       cx,3                     ; d‚lka p©¡pony
menext52:lodsb                              ; znak jm‚na souboru
         cmp       al," "
         jbe       menext53                 ; konec jm‚na
         stosb
         loop      menext52                 ; dal¨¡ znak
menext53:pop       si
         pop       ds
         ret

menextr:                                  ;* p©enesen¡ textu AX
         push      si
         push      ds
         mov       si,ax
         push      cs
         pop       ds
menextr7:lodsb
         or        al,al
         jz        menextr8
         stosb
         jmp       short menextr7
menextr8:pop       ds
         pop       si
         ret


menuskok label     word

         db        40h+10                   ; testuje se AH
         db        50h                      ; kurzor dol– DOWN
         dw        offset menudown
         db        48h                      ; kurzoru nahoru UP
         dw        offset menuup
         db        49h                      ; str nka nahoru PGUP
         dw        offset menupgup
         db        51h                      ; str nka dol– PGDN
         dw        offset menupgdn
         db        47h                      ; za‡ tek voleb HOME
         dw        offset menuhome
         db        4fh                      ; konec voleb END
         dw        offset menuend
         db        84h                      ; za‡ tek voleb ^PGUP
         dw        offset menuhome
         db        76h                      ; konec voleb ^PGDN
         dw        offset menuend
         db        8dh                      ; 6 © dk– nahoru ^UP
         dw        offset menucup
         db        91h                      ; 6 © dk– dol– ^DOWN
         dw        offset menucdn

         db        0


public   menuhled

menuhled:                                 ;* vyhled n¡ polo‘ky podle kl vesy
                                            ; VSTUP: AX=hledan  kl vesa
                                            ; VSTUP: SI=adresa polo‘ky
                                            ;         AL=‡¡slo polo‘ky
                                            ;         CY=kl vesa nenalezena

         push      bx
         push      dx
         or        al,al                    ; je ©¡dic¡ kl vesa ?
         jz        menuhl2                  ; je ©¡dic¡ kl vesa
         call      highcase                 ; p©evod na velk‚ p¡smeno
         xor       ah,ah
menuhl2: mov       dx,ax                    ; £schova hledan‚ kl vesy
         xor       bl,bl                    ; BL=‡¡ta‡ polo‘ek
         xor       si,si                    ; ukazatel textu
menuhl4: push      si
         call      mendekod                 ; dek¢dov n¡ k¢du kl vesy
         pop       si
         jc        menuhl3                  ; nen¡ platn  polo‘ka
         cmp       ax,dx                    ; je hledan  kl vesa ?
         je        menuhl5                  ; kl vesa nalezena
         inc       bl                       ; zv˜¨en¡ ukazatele polo‘ek
         stc
         jz        menuhl5                  ; p©ekro‡en po‡et polo‘ek
menuhl3: call      mennxp                   ; nalezen¡ dal¨¡ polo‘ky
         jnc       menuhl4                  ; test dal¨¡ polo‘ky
menuhl5: mov       al,bl                    ; ‡¡slo polo‘ky
         pop       dx
         pop       bx
         ret







public   menucup

menucup:                                  ;* posun o 6 © dk– nahoru

         push      ax
         mov       al,6                     ; posun
menucu1: call      menuup                   ; posun o © dek nahoru
         jc        menucu2
         dec       al
         jnz       menucu1
menucu2: pop       ax
         ret


public   menucdn

menucdn:                                  ;* posun o 6 © dk– dol–

         push      ax
         mov       al,6                     ; posun
menucd1: call      menudown                 ; posun o © dek dol–
         jc        menucd2
         dec       al
         jnz       menucd1
menucd2: pop       ax
         ret


public   menupgup

menupgup:                                 ;* posun o str nku nahoru PGUP

         push      ax
         mov       al,ch                    ; v˜¨ka okna
         sub       al,5                     ; ode‡ten¡ okraj–
         jbe       menupgu2                 ; mal˜ po‡et © dk–
menupgu1:call      menuup                   ; posun o © dek nahoru
         jc        menupgu2
         dec       al
         jnz       menupgu1
menupgu2:pop       ax
         ret


public   menupgdn

menupgdn:                                 ;* posun o str nku dol– PGDN

         push      ax
         mov       al,ch                    ; v˜¨ka okna
         sub       al,5                     ; ode‡ten¡ okraj–
         jbe       menupgd2                 ; mal˜ po‡et © dk–
menupgd1:call      menudown                 ; posun o © dek dol–
         jc        menupgd2
         dec       al
         jnz       menupgd1
menupgd2:pop       ax
         ret


public   menuhome

menuhome:                                 ;* za‡ tek polo‘ek
         call      menuup                   ; posun o © dek nahoru
         jnc       menuhome
         ret


public   menuend

menuend:                                  ;* konec polo‘ek
         call      menudown                 ; posun o © dek dol–
         jnc       menuend
         ret


public   menudown

menudown:                                 ;* kurzor dol– DOWN
                                            ; VSTUP: CY=nebyl posun kurzoru

         push      ax
         push      dx
         mov       al,byte ptr cs:[kurzsel]
         inc       al                       ; zv˜¨en¡ © dku s kurzorem
         cmp       al,byte ptr cs:[radkusel] ; dosa‘eno konce ?
         cmc
         jc        menudwn2                 ; je ji‘ na konci
         mov       byte ptr cs:[kurzsel],al ; nov  pozice kurzoru
         add       dh,ch                    ; koncov˜ © dek
         sub       dh,5                     ; ode‡ten¡ okraj–
         add       dh,byte ptr cs:[firstsel]; posledn¡ zobrazen˜ © dek
         cmp       al,dh                    ; je je¨tˆ v oknˆ ?
         jc        menudwn1                 ; je v oknˆ
         inc       byte ptr cs:[firstsel]   ; zv˜¨en¡ prvn¡ho zobraz. © dku
menudwn1:clc
menudwn2:pop       dx
         pop       ax
         ret


public   menuup

menuup:                                   ;* kurzoru nahoru UP
         push      ax
         mov       al,byte ptr cs:[kurzsel] ; pozice kurzoru
         or        al,al
         stc
         jz        menuup2                  ; je ji‘ prvn¡ © dek
         dec       al
         mov       byte ptr cs:[kurzsel],al ; nov  pozice kurzoru
         cmp       al,byte ptr cs:[firstsel] ; je je¨tˆ v oknˆ ?
         jae       menuup1                  ; je je¨tˆ v oknˆ
         dec       byte ptr cs:[firstsel]   ; sn¡‘en¡ prvn¡ polo‘ky
menuup1: clc
menuup2: pop       ax
         ret


public   menuall

menuall:                                  ;* zobrazen¡ v¨ech polo‘ek voleb
                                            ; VSTUP:DL=po‡ tek okna
                                            ;       DH=© dek okna
                                            ;       CL=¨¡©ka okna
                                            ;       CH=v˜¨ka okna

         push      ax
         push      cx
         push      dx
         push      si
         mov       al,byte ptr ds:[firstsel] ; prvn¡ zobrazen  polo‘ka voleb
         mov       ah,ds:[zobrlsel]         ; po‡et polo‘ek k zobrazen¡
         or        ah,ah
         jz        menuall2                 ; nen¡ ‘ dn  polo‘ka
         push      ax
         call      askmen                   ; nalezen¡ adresy polo‘ky
         pop       ax
menuall1:call      menulin                  ; zobrazen¡ © dku
         inc       al                       ; zv˜¨en¡ ‡¡sla polo‘ky
         call      mennxp                   ; nalezen¡ dal¨¡ polo‘ky volby
         jc        menuall2                 ; polo‘ka nenalezena
         dec       ah                       ; sn¡‘en¡ ‡¡ta‡e © dk–
         jnz       menuall1                 ; zobrazen¡ dal¨¡ polo‘ky
menuall2:pop       si
         pop       dx
         pop       cx
         pop       ax
         ret


public   menulin

menulin:                                  ;* zobrazen¡ polo‘ky volby
                                            ; VSTUP: AL=‡¡slo polo‘ky k zobraz.
                                            ;        SI=adresa polo‘ky
                                            ;        DH=po‡ te‡n¡ © dek okna
                                            ;        DL=po‡ te‡n¡ pozice okna
                                            ;        CL=¨¡©ka okna
                                            ;        CH=v˜¨ka okna

         push      ax
         push      bx
         push      cx
         push      dx
         push      si

         push      ax
         mov       bl,cl                    ; ¨¡©ka okna
         xor       bh,bh
         sub       bl,8                     ; ode‡ten¡ okraj–
         call      mendell                  ; poskytnut¡ d‚lky polo‘ky
         cbw                                ; d‚lka © dku
         sub       bx,2
         cmp       ax,bx                    ; je text del¨¡ ne‘ okno ?
         jbe       menulin2                 ; text nen¡ del¨¡
         mov       ax,bx                    ; n hrada d‚lky textu
menulin2:add       bx,2
         mov       cx,ax                    ; d‚lka textu
         pop       ax

         lea       di,[selbuf]              ; buffer pro editaci
         mov       ds,cs:[topseg]           ; adresa s textem
         call      transmen                 ; p©enos textu polo‘ky
         push      cs
         pop       ds
         sub       al,byte ptr ds:[firstsel] ; ode‡ten¡ prvn¡ polo‘ky
         add       al,dh                    ; p©i‡ten¡ po‡ te‡n¡ho © dku
         add       al,2                     ; p©i‡ten¡ spodn¡ho okraje
         mov       dh,al                    ; ©adek k zobrazen¡ textu
         lea       si,[selbuf]
         add       dl,5                     ; po‡ te‡n¡ pozice
         call      outtxtt                  ; zobrazen¡ textu s tabel tory
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

public   outtxtt

outtxtt:                                  ;* zobrazen¡ textu s tabel tory
                                            ; VSTUP: DS:SI=ukazatel textu
         call      mouseoff                 ; vypnut¡ my¨i
         push      ax
         push      bx
         xor       bl,bl                    ; Bl <- 0 ‡¡ta‡ pozice
outtxtt0:lodsb                              ; na‡ten¡ znaku k tisku
         cmp       al,32
         jb        outtxtt4                 ; je ©¡dic¡ znak
         inc       bl                       ; zv˜¨en¡ ukazatele pozice
outtxtt4:or        al,al                    ; je koncov˜ bajt 0 ?
         jz        outtxtt1                 ; je koncov˜ bajt 0 - konec
         cmp       al,13
         je        outtxtt1
         cmp       al,9                     ; je tabel tor ?
         jne       outtxtt2                 ; je konec © dku
outtxtt3:mov       al," "
         call      outch1
         inc       bl
         test      bl,7
         jnz       outtxtt3
         jmp       short outtxtt0
outtxtt2:call      outch1                   ; tisk 1 znaku
         jmp       short outtxtt0           ; tisk dal¨¡ho znaku
outtxtt1:pop       ax
         pop       bx
         call      mouseon                  ; zapnut¡ my¨i
         ret

public   menuatr

menuatr:                                  ;* nastaven¡ barvy textu
                                            ; VSTUP: AL=‡¡slo polo‘ky
                                            ;        ES:DI=ukl dac¡ adresa
                                            ; VSTUP: AL=‡¡slo atributu barvy

         push      ax                       ; ‡¡slo polo‘ky
         mov       ah,7                     ; barva pro norm ln¡ polo‘ku
         cmp       al,byte ptr cs:[kurzsel] ; je polo‘ka s kurzorem ?
         jne       menuatr0                 ; nen¡ polo‘ka s kurzorem
         mov       ah,19                    ; barva polo‘ky s kurzorem
menuatr0:mov       al,ah                    ; barva pro zobrazen¡ polo‘ky
         stosb
         pop       ax
         ret


;public   menuset
;
;menuset:                                  ;* nastaven¡ parametr– polo‘ky
;                                            ; VSTUP: AL=‡¡slo polo‘ky k zobraz.
;                                            ;        DH=po‡ te‡n¡ © dek okna
;                                            ;        DL=po‡ te‡n¡ pozice okna
;                                            ;        CL=¨¡©ka okna
;                                            ;        CH=v˜¨ka okna
;
;         push      ax
;         push      bx
;         push      cx
;         push      dx
;         push      si
;         push      ax                       ; ‡¡slo polo‘ky
;         mov       ah,ds:[col7]             ; barva pro norm ln¡ polo‘ku
;         cmp       al,byte ptr ds:[kurzsel] ; je polo‘ka s kurzorem ?
;         jne       menuset0                 ; nen¡ polo‘ka s kurzorem
;         mov       ah,ds:[col3]             ; barva polo‘ky s kurzorem
;menuset0:mov       ds:[atribsel],ah         ; barva pro zobrazen¡ polo‘ky
;         call      askmen                   ; poskytnut¡ adresy polo‘ky
;         cbw
;         mov       ds:[numselb],ax          ; nastaven¡ d‚lky textu
;         mov       cx,ax                    ; d‚lka textu
;         lea       di,[selbuf]              ; buffer pro editaci
;         mov       ds,cs:[topseg]           ; adresa s textem
;         call      transmen                 ; p©enos textu polo‘ky
;         push      cs
;         pop       ds
;         xor       ax,ax
;         mov       ds:[ukazsel],ax          ; pozice kurzoru
;         mov       ds:[topsel],ax           ; po‡ tek zobrazen¡ © dku
;         pop       ax                       ; ‡¡slo polo‘ky
;         sub       al,byte ptr ds:[firstsel] ; ode‡ten¡ prvn¡ polo‘ky
;         add       al,dh                    ; p©i‡ten¡ po‡ te‡n¡ho © dku
;         add       al,2                     ; p©i‡ten¡ spodn¡ho okraje
;         mov       ds:[pocradsl],al         ; nastaven¡ © dku k zobrazen¡
;         pop       si
;         pop       dx
;         pop       cx
;         pop       bx
;         pop       ax
;         ret
;


public   transmen

transmen:                                 ;* p©enos textu polo‘ky do bufferu
                                            ; VSTUP: DS:SI=adresa © dku
                                            ;        ES:DI=ukl dac¡ adresa
                                            ;        AL=‡¡slo polo‘ky
                                            ;        CX=d‚lka © dku
                                            ;        BX=max. d‚lka © dku

         push      bx
         push      dx
         push      ax
         mov       dx,bx                    ; £schova max. d‚lky © dku
         call      menuatr                  ; nastaven¡ atributu © dku -> AL
         mov       bx,si                    ; £schova adresy
         call      mendekod                 ; dek¢dov n¡ k¢du kl vesy
                                          ;* vymaz n¡ bufferu
         push      cx
         push      di                       ; za‡ tek bufferu
         mov       cx,dx                    ; max. d‚lka © dku
         mov       al," "                   ; mazac¡ mezera
         rep       stosb                    ; vymaz n¡ bufferu
         xor       al,al
         stosb                              ; koncov˜ bajt 0
         pop       di
         pop       cx

         pop       ax
         push      ax                       ; Al = ‡¡slo polo‘ky
         xchg      bx,si                    ; BX <- nov  adresa,SI <- star  adr.
         sub       bx,si                    ; d‚lka textu start. kl vesy
         or        bx,bx                    ; je ozna‡en¡ start. kl vesy ?
         jz        transmn3                 ; nen¡ ‘ dn  start. kl vesa
         mov       ah,10                    ; barva pro norm ln¡ polo‘ku
         cmp       al,byte ptr cs:[kurzsel] ; je polo‘ka s kurzorem ?
         jne       transmn1                 ; nen¡ polo‘ka s kurzorem
         mov       ah,14                    ; barva polo‘ky s kurzorem
transmn1:mov       al,ah                    ; barva pro zobrazen¡ polo‘ky
         stosb
transmn2:movsb                              ; p©enos znaku
         dec       bx
         loopnz    transmn2                 ; p©enos textu start. kl vesy
         pop       ax                       ; AL = ‡¡slo polo‘ky
         push      ax
         call      menuatr                  ; atributy
                                          ;* p©enos zbytku © dku
transmn3:rep       movsb
         pop       ax
         pop       dx
         pop       bx
         ret


public testmen

testmen:                                  ;* test polo‘ek voleb
                                            ; VSTUP: BH=maxim. d‚lka ©etˆzce
                                            ;         BL=po‡et polo‘ek

         push      ax
         push      si
         xor       bx,bx                    ; BH=max. d‚lka, BL=po‡et polo‘ek
         xor       si,si                    ; adresa za‡ tku textu
         push      si
         call      mendekod                 ; test, zda je polo‘ka volby
         pop       si
         jnc       testmn4                  ; je prvn¡ polo‘ka volby
testmn1: call      mennxp                   ; nalezen¡ dal¨¡ polo‘ky volby
         jc        testmn3                  ; dal¨¡ polo‘ka nenalezena
testmn4: call      mendell                  ; nalezen¡ d‚lky polo‘ky
         cmp       al,bh                    ; maxim ln¡ d‚lka ©etˆzc–
         jb        testmn5                  ; nen¡ vˆt¨¡ d‚lka
         mov       bh,al                    ; nov  maxim ln¡ d‚lka
testmn5: inc       bl                       ; zv˜¨en¡ ‡¡ta‡e polo‘ek
         jnz       testmn1                  ; dal¨¡ polo‘ka
         dec       bl                       ; BL <- 255 max. po‡et ©etˆzc–
testmn3: pop       si
         pop       ax
         ret


public   askmen

askmen:                                   ;* poskytnut¡ polo‘ky voleb
                                            ; VSTUP: AL=‡¡slo polo‘ky 0...
                                            ; VSTUP: SI=adresa textu polo‘ky
                                            ;         AL=d‚lka textu polo‘ky
                                            ;         CY=neplatn‚ ‡¡slo polo‘ky

         xor       si,si                    ; adresa za‡ tku textu
         push      si
         push      ax
         call      mendekod                 ; test, zda je polo‘ka volby
         pop       ax
         pop       si
         jnc       askmen2                  ; je prvn¡ polo‘ka volby
askmen1: call      mennxp                   ; nalezen¡ dal¨¡ polo‘ky volby
         jc        askmen4                  ; polo‘ka nenalezena
askmen2: or        al,al                    ; je po‘adovan  polo‘ka ?
         jz        askmen3                  ; je po‘adovan  polo‘ka
         dec       al                       ; sn¡‘en¡ ‡¡ta‡e polo‘ek
         jmp       short askmen1            ; nalezen¡ dal¨¡ polo‘ky
askmen3:                                  ;* polo‘ka nalezena - parametry
         call      mendell                  ; nalezen¡ d‚lky polo‘ky
         clc
askmen4: ret


public   mennxp

mennxp:                                   ;* nalezen¡ dal¨¡ polo‘ky volby
                                            ; VSTUP: SI=adresa ukazatele
                                            ; VSTUP: SI=adresa dal¨¡ volby
                                            ;         CY=nen¡ ji‘ dal¨¡ volba

         call      mennxl                   ; nalezen¡ dal¨¡ho © dku
         jc        mennxp2                  ; nen¡ ji‘ dal¨¡ © dek
         push      si
         push      ax
         call      mendekod                 ; dek¢dov n¡ k¢du kl vesy
         pop       ax
         pop       si
         jc        mennxp                   ; test dal¨¡ho © dku
mennxp2: ret


public   mendekod

mendekod:                                 ;* dek¢dov n¡ k¢du kl vesy
                                            ; VSTUP: SI=adresa ukazatele textu
                                            ; VSTUP: AX=k¢d kl vesy
                                            ;         SI=nov  adresa ukazatele
                                            ;         CY=nen¡ polo‘ka volby

         push      bx
         push      dx
         push      di
         mov       di,si                    ; £schova ukazatele SI
         call      menchr                   ; na‡ten¡ prvn¡ho znaku z © dku
         jc        mendek0                  ; konec textu
         cmp       al,33                    ; je oddˆlova‡ ?
         jb        mendek0                  ; je oddˆlova‡
         cmp       al,60h                   ; je pozn mka ' ?
         stc
         je        mendek0                  ; je pozn mka
         cmp       al,";"                   ; je pozn mka ";" ?
         stc
         jne       mendek1                  ; nen¡ pozn mka
mendek0: jmp       mendek9                  ; nen¡ polo‘ka volby
mendek1:                                  ;* pokus o funk‡n¡ kl vesu
         mov       bx,8754h                 ; k¢dy kl ves pro SHIFT
         cmp       al,"*"                   ; je kl vesa se SHIFT ?
         je        mendek2                  ; je ozna‡en¡ SHIFT
         lea       dx,[menuprf1]            ; text "SHIFT-"
         call      mendekp                  ; pokus o textov˜ prefix
         jnc       mendek2                  ; k¢d kl vesy nalezen
         mov       bx,895eh                 ; k¢dy kl ves pro CTRL
         cmp       al,"^"                   ; je kl vesa s CTRL ?
         je        mendek2                  ; je ozna‡en¡ CTRL
         lea       dx,[menuprf2]            ; text "CTRL-"
         call      mendekp                  ; pokus o textov˜ prefix
         jnc       mendek2                  ; k¢d kl vesy nalezen
         mov       bx,8b68h                 ; k¢dy kl ves s ALT
         lea       dx,[menuprf3]            ; text "ALT-"
         call      mendekp                  ; pokus o textov˜ prefix
         jnc       mendek2                  ; k¢d kl vesy nalezen
         mov       bx,853bh                 ; k¢dy kl ves bez p©esmyka‡e
         cmp       al,"/"                   ; je kl vesa s ALT ?
         jne       mendek3                  ; nen¡ kl vesa s ALT
         mov       bx,8b68h                 ; k¢dy kl ves s ALT
mendek2: call      menchr                   ; na‡ten¡ dal¨¡ho znaku
         jc        mendek7                  ; konec textu
mendek3: cmp       al,"F"                   ; je fuk‡n¡ kl vesa ?
         je        mendek4                  ; je funk‡n¡ kl vesa
         cmp       al,"f"
         jne       mendek7                  ; nen¡ funk‡n¡ kl vesa
mendek4: call      menchr                   ; ‡¡slo kl vesy
         jc        mendek7                  ; nen¡ dal¨¡ znak
         call      mendekn                  ; dek¢dov n¡ na ‡¡slici
         jc        mendek7                  ; nen¡ platn  ‡¡slice
         mov       ah,al                    ; £schova ‡¡sla
         call      menchr                   ; dal¨¡ ‡¡slice
         jc        mendek5                  ; nen¡ dal¨¡ znak
         call      mendekn                  ; dek¢dov n¡ na ‡¡slici
         jc        mendek5                  ; nen¡ platn  ‡¡slice
         add       al,ah
         add       al,ah
         add       ah,ah
         add       ah,ah
         add       ah,ah
         add       al,ah
         mov       ah,al
         inc       si
mendek5: dec       si
         or        ah,ah                    ; je ‡¡slo = 0 ?
         jz        mendek7                  ; nen¡ funk‡n¡ kl vesa
         cmp       ah,12                    ; je ‡¡slo vˆt¨¡ ne‘ 12 ?
         ja        mendek7                  ; nen¡ funk‡n¡ kl vesa
         dec       ah
         add       bl,ah                    ; k¢d funk‡n¡ kl vesy
         sub       ah,10                    ; je kl vesa F11, F12 ?
         jc        mendek6                  ; nen¡ kl vesa F11, F12
         add       bh,ah                    ; k¢d kl vesy F11, F12
         xchg      bl,bh
mendek6: mov       ah,bl                    ; k¢d funk‡n¡ kl vesy
         xor       al,al
         clc
         jmp       short mendeka            ; n vrat - operace OK
mendek7:                                  ;* nen¡ funk‡n¡ kl vesa
         mov       si,di                    ; n vrat ukazatele textu
         call      menchr                   ; na‡ten¡ prvn¡ho znaku
         call      highcase                 ; p©evod na velk‚ p¡smeno
         xor       ah,ah
         clc
         jmp       short mendeka
mendek9: mov       si,di                    ; n vrat ukazatele
mendeka: pop       di
         pop       dx
         pop       bx
         ret

public   mendekp
mendekp:                                  ;* pokus o textov˜ prefix
                                            ; VSTUP: SI=adresa ukazatele textu
                                            ;        DX=adresa referen‡n¡ho textu
                                            ;        AL=prvn¡ na‡ten˜ znak
                                            ; VSTUP: (SI=nov  adresa ukazatele)
                                            ;         CY=nen¡ polo‘ka volby

         push      ax                       ; £schova prvn¡ho znaku
         push      bx
         push      cx
         push      di
         mov       bx,dx                    ; referen‡n¡ text
         mov       cx,si                    ; £schova ukazatele
mendekp2:mov       ah,cs:[bx]               ; referen‡n¡ znak
         inc       bx                       ; zv˜¨en¡ referen‡n¡ho ukazatele
         or        ah,ah                    ; je konec textu ?
         jz        mendekp9                 ; n vrat p©i £spˆchu
         call      highcase                 ; p©evod na velk‚ p¡smeno
         xchg      ah,al
         call      highcase                 ; p©evod na velk‚ p¡smeno
         cmp       al,ah                    ; je shoda ?
         jne       mendekp8                 ; nen¡ shoda
         call      menchr                   ; na‡ten¡ prvn¡ho znaku
         jnc       mendekp2                 ; test dal¨¡ho znaku
mendekp8:mov       si,cx                    ; n vrat ukazatele p©i ne£spˆchu
         stc                                ; p©¡znak ne£spˆchu
         inc       si
mendekp9:dec       si                       ; n vrat ukazatele
         pop       di
         pop       cx
         pop       bx
         pop       ax
         ret



public   mendekn

mendekn:                                  ;* dek¢dov n¡ znaku na ‡¡slici
                                            ; VSTUP: AL=znak ASCII
                                            ; VSTUP: AL=‡¡slo (nebo znak)
                                            ;         CY=nen¡ ‡¡slice
         push      bx
         mov       bl,al                    ; £schova znaku
         sub       al,"0"                   ; korekce na ‡¡slici
         jc        mendekn2                 ; nen¡ platn  ‡¡slice
         cmp       al,10                    ; je platn  ‡¡slice ?
         cmc
         jnc       mendekn3                 ; je platn  ‡¡slice
mendekn2:mov       al,bl                    ; n vrat znaku
mendekn3:pop       bx
         ret


public   mendell

mendell:                                  ;* zji¨tˆn¡ d‚lky © dku
                                            ; VSTUP: SI=adresa za‡ tku © dku
                                            ; VSTUP: AL=d‚lka © dku (max. 127)

         push      si
         push      bx
         xor       bl,bl                    ; ‡¡ta‡ d‚lky © dku
mendel1: call      menchr                   ; na‡ten¡ dal¨¡ho znaku
         jc        mendel2                  ; konec textu
         cmp       al,13
         je        mendel2                  ; konec © dku
         inc       bl                       ; zv˜¨en¡ ‡¡ta‡e znak–
         cmp       al,9
         jne       mendel3                  ; nen¡ tabel tor
         add       bl,7
         and       bl,not 7
mendel3: or        bl,bl
         jns       mendel1                  ; nen¡ p©ekro‡en po‡et znak–
         dec       bl
mendel2: mov       al,bl                    ; d‚lka © dku
         pop       bx
         pop       si
         ret


public   mennxl

mennxl:                                   ;* nalezen¡ za‡ tku dal¨¡ho © dku
                                            ; VSTUP: SI=adresa ukazatele
                                            ; VSTUP: SI=adresa za‡ tku © dku
                                            ;         CY=nen¡ ji‘ dal¨¡ © dek

         push      ds
         mov       ds,cs:[topseg]           ; segment s textem
         or        si,si
         jnz       mennxl1
         inc       si
mennxl1: cmp       si,cs:[editnum]          ; je ji‘ na konci souboru ?
         cmc
         jb        mennxl2                  ; nen¡ ji‘ dal¨¡ © dek
         inc       si                       ; zv˜¨en¡ ukazatele
         cmp       ds:[si-2],0a0dh          ; je konec © dku ?
         jne       mennxl1                  ; nen¡ konec © dku - dal¨¡ znak
mennxl2: pop       ds
         ret


public   menchr

menchr:                                   ;* na‡ten¡ znaku z bufferu
                                            ; VSTUP: SI=adresa ukazatele
                                            ; VSTUP: SI=nov˜ ukazatel
                                            ;         AL=znak
                                            ;         CY=nen¡ ji‘ dal¨¡ znak

         push      ds
         mov       ds,cs:[topseg]           ; segment s textem
         cmp       si,cs:[editnum]          ; je ji‘ na konci souboru ?
         cmc
         jb        mench2                   ; nen¡ ji‘ dal¨¡ © dek
         lodsb                              ; na‡ten¡ znaku
mench2:  pop       ds
         ret





code     ends

         end

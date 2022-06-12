
; modul DOSMHLP.ASM - n†povàda

; *****************************************************************************
;
;                          N†povàda
;
; *****************************************************************************

code     segment   public
         assume    cs:code,ds:code

extrn    outbuf:byte,transtxt:near,texthlp1:byte,texthlp2:byte,texthlp3:byte
extrn    texthlp4:byte,texthlp5:byte,volbhlp1:byte,texthlpb:byte
extrn    deknum:near,setkonc:near,transtxt:near,dny:word,mesice:word
extrn    askvol:near,parnum:byte,volbyh:near,windret:near,filehelp:byte
extrn    errhlp1:byte,zobrchyb:near,segend:word,topseg:word
extrn    hlpseg:word,hlpnum:word,pathhome:byte,editnum:word,outch:near
extrn    outch1:near,outch10:near,inpkey:near,citachod:byte,kurzout:near
extrn    outhelp:near,helpbuf:byte,txtchyb:byte,txtchyb1:byte
extrn    hlptop:word,outch0:near,color:byte,parint:byte,highcase:near
extrn    col16:byte,skokax:near,inpkeyf:near,txthlp1:byte,hlpkurz:word
extrn    testalt:near,konvfnt:near,texthlp6:byte,licence:dword
extrn    setnul:near,setfre:near,deknum5:near,tabhlfnd:word,endshell:byte
extrn    mouseon:near,mouseoff:near,mouseget:near,segrez:word
extrn    inidend:byte,inidata:byte,datarez:byte,flags:byte
extrn    edikey:word,testkey:near,getdispcx:near

; -----------------------------------------------------------------------------

public   help

help:                                  ;* zobrazen° n†povàdy
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

         lea       di,[helpbuf]
         lea       si,[texthlp1]            ; £vodn° text
         call      transtxt

ifndef   demo
                                          ;* zobrazen° licenán°ho á°sla
         call      setnul                   ; nastaven° tisku nul
         or        byte ptr ds:[parnum],8   ; p©echodnò z†kaz teáky
         mov       ax,word ptr ds:[licence+2] ; vy®®° slovo licenán°ho á°sla
         xor       dx,dx
         call      deknum5                  ; dek¢dov†n° á°sla
         mov       al,"-"
         stosb                              ; oddàlovac° pomláka
         or        byte ptr ds:[parnum],8   ; p©echodnò z†kaz teáky
         mov       ax,word ptr ds:[licence] ; nië®° slovo licenán°ho á°sla
         xor       dx,dx
         call      deknum5                  ; dek¢dov†n° á°sla
         call      setfre                   ; volnò form†t tisku á°sla
endif

         lea       si,[texthlp6]            ; pokraáov†n° textu
         call      transtxt

                                          ;* datum
         lea       si,[texthlp3]            ; text "dnes je"
         call      transtxt
         mov       ah,2ah
         int       21h                      ; poskytnut° systÇmovÇho data
         lea       si,[dny]                 ; seznam dnñ
         call      askvol                   ; poskytnut° adresy dne v tòdnu
         call      transtxt                 ; p©enos textu dne
         lea       si,[texthlp4]            ; oddàlovac° á†rka
         call      transtxt
         push      cx                       ; £schova roku
         push      dx                       ; £schova màs°ce
         xor       ax,ax
         mov       al,dl                    ; den
         xor       dx,dx
         call      deknum
         mov       al,"."                   ; oddàlovac° teáka
         stosb
         pop       dx                       ; n†vrat màs°ce
         mov       al,dh                    ; màs°ce
         dec       al
         lea       si,[mesice]              ; tabulka màs°cñ
         call      askvol                   ; poskytnut° adresy màs°ce
         call      transtxt
         mov       al," "                   ; oddàlovac° mezera
         stosb
         pop       ax                       ; rok
         xor       dx,dx
         or        byte ptr ds:[parnum],1   ; z†kaz tisku teáek
         call      deknum                   ; rok
         and       byte ptr ds:[parnum],0feh ; povolen° tisku teáek


                                          ;* celkov† velikost pamàti
         lea       si,[texthlp5]
         call      transtxt                 ; text "velikost pamàti"

         int       12h                      ; hl†®en° o velikosti pamàti
         mov       bx,1024                  ; velikost 1 KB dat
         mul       bx                       ; vòpoáet velikosti pamàti
         push      di                       ; £schova zaá†tku á°selnÇho £daje
         call      deknum                   ; dek¢dov†n° á°sla
         mov       si,offset texthlpb       ; text "bajt"
         call      transtxt                 ; uloëen° textu "bajt"
         pop       si                       ; adresa á°sla volnÇ kapacity
         call      setkonc                  ; nastaven° koncovky "y", "ñ"
                                          ;* velikost volnÇ pamàti
         lea       si,[texthlp2]            ; pokraáov†n° textu
         call      transtxt
         mov       ax,ds:[2]                ; segment konce pamàti
         mov       bx,cs                    ; segment programu
         sub       ax,bx                    ; velikost volnÇ pamàti v segmentech
         test      byte ptr ds:[flags],8    ; je rezidentn° reëim ?
         jz        help12                   ; nen° rezidentn° reëim
         lea       bx,[endshell]            ; konec programu
         jmp       short help13
help12:  cmp       bx,ds:[segrez]
         je        help11                   ; nen° je®tà rezidentn° á†st
                                          ;* je jië rezidentn° á†st
;         dec       ax                       ; sn°ëen° o popisovaá
         push      es
         mov       cx,ds:[2ch]              ; segment prost©ed°
         dec       cx
         mov       es,cx                    ; popisovaá segmentu prost©ed°
         inc       cx
         add       cx,es:[3]                ; n†sleduj°c° segment
         inc       cx
         cmp       cx,bx                    ; je tento segment ?
         jne       help15                   ; nen° tento segment
         add       ax,es:[3]                ; zvò®en° o velikost segmentu
         inc       ax                       ; zvò®en° o popisovaáe
help15:  pop       es
         jmp       short help14
                                          ;* nen° je®tà rezidentn° á†st
help11:  lea       bx,[inidend]             ; konec rezidentn°ch dat
         sub       bx,offset inidata        ; dÇlka rezidentn°ch dat
         add       bx,offset datarez        ; konec rezidentn°ch dat
help13:  add       bx,15                    ; zaokrouhlen°
         mov       cl,4
         shr       bx,cl                    ; p©epoáet na odstavce
         sub       ax,bx                    ; zmen®en° volnÇ pamàti
         dec       ax                       ; sn°ëen° o popisovaá
help14:  mov       bx,16
         mul       bx                       ; velikost volnÇ pamàti
         push      di                       ; £schova zaá†tku á°selnÇho £daje
         call      deknum                   ; dek¢dov†n° á°sla
         mov       si,offset texthlpb       ; text "bajt"
         call      transtxt                 ; uloëen° textu "bajt"
         pop       si                       ; adresa á°sla volnÇ kapacity
         call      setkonc                  ; nastaven° koncovky "y", "ñ"

         xor       al,al
         stosb
                                          ;* zobrazen° okna napovàdy
         lea       di,[helpbuf]
         lea       si,[volbhlp1]
         xor       al,al
         call      volbyh
         pushf
         call      windret
         test      byte ptr cs:[parint],30h ; je funkce F3 nebo F4 ?
         jnz       help16                   ; je F3 nebo F4
         call      outhelp                  ; zobrazen° n†povàdy
help16:  popf
         jc        help2
         mov       ah,0
         or        al,al
         jz        hlpmain0                 ; je dal®° n†povàda
help2:   pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
;                           Vnàj®° n†povàda
; -----------------------------------------------------------------------------

public   hlpmain,althelp

althelp:                                  ;* n†povàda Alt-F1




hlpmain:                                  ;* hlavn° n†povàda
                                            ; VSTUP: AH=0 je inicializace
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es
hlpmain0:mov       bp,ax                    ; £schova k¢du kl†vesy
         push      cs
         pop       ds
         push      cs
         pop       es
                                          ;* sestaven° cesty k souboru
         lea       di,[outbuf]              ; pracovn° buffer
         push      di
         lea       si,[pathhome]            ; cesta k dom†c°mu adres†©i
         call      transtxt                 ; p©enesen° jmÇna cesty
         mov       al,"\"
         cmp       byte ptr es:[di-1],al    ; byl posledn° znak "\" ?
         je        hlpmain1                 ; posledn° znak je jië "\"
         stosb                              ; oddàlovaá cesty a jmÇna programu
hlpmain1:lea       si,[filehelp]            ; jmÇno souboru "NSHELL.HLP"
         call      transtxt                 ; p©enesen° jmÇna
         pop       dx                       ; jmÇno souboru
                                          ;* otev©en° souboru
         mov       ax,3d00h                 ; funkce otev©en° souboru pro áten°
         int       21h                      ; otev©en° souboru pro áten°
         mov       bx,ax                    ; identifik†tor souboru
         jnc       hlpmain3                 ; soubor otev©en OK
hlpmain2:                                 ;* chyba - soubor nenalezen
         lea       di,[helpbuf]             ; buffer pro n†povàdu
         lea       si,[txtchyb]
         call      transtxt                 ; p©enos textu
         lea       si,[errhlp1]             ; chybovò text
         call      transtxt
         lea       si,[txtchyb1]
         lea       di,[helpbuf]
         xor       al,al
         call      volbyh
         jmp       hlpmain9
hlpmain3:                                 ;* uráen° volnÇ pamàti
         mov       ax,ds:[editnum]          ; poáet bajtñ v pamàti
         add       ax,31                    ; zaokrouhlen°
         jnc       hlpmai32                 ; nen° p©eteáen°
         mov       ax,0ffffh                ; omezen° na maximum
hlpmai32:mov       cl,4
         shr       ax,cl                    ; p©epoáet na odstavce
         add       ax,2                     ; rezerva pro oddàlen°
         add       ax,ds:[topseg]           ; segment pro uloëen° n†povàdy
         mov       ds:[hlpseg],ax           ; segment pro uloëen° n†povàdy
         mov       ax,ds:[segend]           ; segment konce pamàti
         sub       ax,2                     ; rezerva
         sub       ax,ds:[hlpseg]           ; voln† pamàü
         jc        hlpmain2                 ; pamàü nedostaáuje
         cmp       ax,1000h                 ; je vàt®° neë 64 KB ?
         jb        hlpmain4                 ; nen° vàt®° neë 64 KB
         mov       ax,0fffh                 ; omezen° na 64 KB
hlpmain4:mov       cl,4
         shl       ax,cl                    ; voln† kapacita (v bajtech)
                                          ;* naáten° souboru do pamàti
         push      bx                       ; identifik†tor souboru
         mov       cx,ax                    ; maxim†ln° dÇlka dat
         mov       ah,3fh
         mov       ds,ds:[hlpseg]           ; segment pro uloëen° dat
         xor       dx,dx                    ; offset adresy k uloëen°
         int       21h                      ; naáten° dat do pamàti
         push      cs
         pop       ds
         mov       ds:[hlpnum],ax           ; poáet bajtñ dat v pamàti
         pop       bx                       ; identifik†tor souboru
                                          ;* uzav©en° souboru
         push      ax
         pushf
         mov       ah,3eh                   ; funkce uzav©en° souboru
         int       21h                      ; uzav©en° souboru
         popf
         pop       ax
         jc        hlpmain2                 ; chyba operace
         or        ax,ax
         jz        hlpmain2                 ; nen° ë†dnò znak v souboru

         call      hlpkonv                  ; konverze fontñ v textech
         call      hlpram0                  ; zobrazen° r†mu n†povàdy
         call      mouseoff                 ; vypnut° kurzoru my®i

         cmp       word ptr cs:[hlpkurz],0
         je        hlpmn52                  ; nebyla je®tà inicializace
         mov       ax,bp                    ; startovac° kl†vesa
         or        ah,ah
         jnz       hlpmn51
hlpmn52: mov       word ptr cs:[hlptop],0   ; poá†teán° adresa zobrazen°
         call      hlpstop                  ; nastaven° zaá†tku str†nky
hlpmn51: mov       bh,80h                   ; p©°znak zobrazen° v®ech ©†dkñ
hlpmain6:
         call      hlpall                   ; zobrazen° str†nky textu

hlpmain7:push      cs
         pop       ds
         push      cs
         pop       es

         call      kurzout
         call      inpkeyh                  ; vstup kl†vesy pro n†povàdu


         cmp       al,27
         je        hlpmain9                 ; konec n†povàdy

         lea       bx,[hlptskok]            ; tabulka skokñ pro n†povàdu
         call      skokax                   ; skok do obsluhy kl†vesy
         jc        hlpmain7                 ; kl†vesa nebyla obslouëena
         jmp       short hlpmain6           ; p©ekreslen° obrazovky


hlpmain9:
         call      mouseon                  ; zapnut° kurzoru my®i
         call      windret
         test      byte ptr cs:[parint],30h ; je funkce F3 nebo F4 ?
         jnz       hlpmaina                 ; je F3 nebo F4
         call      outhelp                  ; zobrazen° n†povàdy
hlpmaina:pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret


public   inpkeyh
inpkeyh:                                  ;* vstup kl†vesy pro n†povàdu

         call      mouseget                 ; vstup z my®i
         jz        inpkeyh4                 ; nen° tlaá°tko
                                          ;* test kl†vesy ESC
         mov       ax,011bh                 ; ESC
         cmp       bl,11                    ; uvolnàn° pravÇho tlaá°tka ?
         je        inpkeyh6                 ; je ESC
                                          ;* kontrola, zda je poloëka na ©†dku
;         mov       al,dl
;         cmp       al,byte ptr cs:[mousepoz]
;         ja        inpkeys4                 ; kurzor p©°li® vlevo
;         add       al,cl
;         cmp       al,byte ptr cs:[mousepoz]
;         jbe       inpkeys4                 ; kurzoru p©°li® vpravo
;         mov       al,dh
;         add       al,ch
;         cmp       al,byte ptr cs:[mousepoz+1]
;         jbe       inpkeys4                 ; kurzor p©°li® dole
;         mov       al,byte ptr cs:[mousepoz+1]
;         sub       al,dh                    ; relativn° ©†dek
;         jb        inpkeys4                 ; kurzor p©°li® naho©e
                                          ;* funkce ENTER
         cmp       bl,10                    ; uvolnàn° levÇho tlaá°tka ?
         jne       inpkeyh3                 ; nen° funkce ENTER
         mov       ax,1c0dh                 ; ENTER
         jmp       short inpkeyh6
inpkeyh3:                                 ;* vòpoáet á°sla poloëky
;         sub       al,2                     ; horn° okraj
;         jnc       inpkeys1                 ; nen° v horn°m okraji
;         xor       al,al
;inpkeyh1:cbw                                ; offset ©†dku
;         add       ax,cs:[firstsel]         ; poëadovan† poloëka
;                                          ;* test dosaëen° poloëky
;         cmp       ax,cs:[kurzsel]          ; je jië poloëky dosaëeno ?
;         je        inpkeyh4                 ; poloëky je jië dosaëeno
;         mov       ax,4800h                 ; kurzor nahoru
;         jb        inpkeyh6                 ; je posun nahoru
;         mov       ax,5000h                 ; kurzor dolñ
;         jmp       short inpkeyh6           ; posun dolñ

inpkeyh4:cmp       word ptr cs:[edikey],0   ; je nàjakò znak v bufferu ?
         jne       inpkeyh5                 ; v bufferu je nàjakò znak
         call      testkey                  ; je p©ipraven znak ?
         jz        inpkeyh                  ; áek†n° na p©°chod znaku
inpkeyh5:lea       si,[tabhlfnd]
         call      inpkeyf                  ; vstup znaku s vyprazd§ov†n°m
inpkeyh6:ret



public   hlptskok

hlptskok label     byte                   ;* tabulka skokñ pro n†povàdu

         db        40h+13                   ; testuje se AH
         db        3bh                      ; n†povàda F1
         dw        offset hlphlp
         db        4dh                      ; kurzor vpravo RIGHT
         dw        offset hlpright
         db        4bh                      ; kurzor vlevo LEFT
         dw        offset hlpleft
         db        50h                      ; kurzor dolñ DOWN
         dw        offset hlpdown
         db        48h                      ; kurzor nahoru UP
         dw        offset hlpup
         db        47h                      ; prvn° poloëka HOME
         dw        offset hlphome
         db        4fh                      ; posledn° poloëka END
         dw        offset hlpend
         db        77h                      ; prvn° poloëka ^HOME
         dw        offset hlphome
         db        75h                      ; posledn° poloëka ^END
         dw        offset hlpend
         db        49h                      ; prvn° poloëka PAGE UP
         dw        offset hlphome
         db        51h                      ; posledn° poloëka PAGE DOWN
         dw        offset hlpend
         db        84h                      ; prvn° poloëka ^PAGE UP
         dw        offset hlphome
         db        76h                      ; posledn° poloëka ^PAGE DOWN
         dw        offset hlpend

         db        00h+2                    ; testuje se AL
         db        0dh                      ; skok do dal®° poloëky ENTER
         dw        offset hlpent
         db        9                        ; poloëka vpravo TAB
         dw        offset hlpright

         db        80h+1                    ; testuje se AX
         dw        0f00h                    ; kurzor vlevo SHIFT-TAB
         dw        offset hlpleft

         db        0


public   hlpkonv

hlpkonv:                                  ;* konverze fontñ textñ
         push      ax
         push      cx
         push      si
         push      ds
         xor       ah,ah                    ; bit 0: p©°znak p©evodu
         mov       cx,cs:[hlpnum]           ; poáet znakñ v bufferu
         mov       ds,cs:[hlpseg]           ; segment s textem n†povàdy
         xor       si,si
hlpkonv1:lodsb                              ; naáten° znaku
         cmp       al,31                    ; je p©ep°naá ?
         jne       hlpkonv2                 ; nen° p©ep°naá
         cmp       byte ptr ds:[si],"*"     ; je p©ep°naá p©evodu ?
         jne       hlpkonv2                 ; nen° p©ep°naá
         xor       ah,1                     ; zmàna p©°znaku p©evodu
hlpkonv2:test      ah,1                     ; prov†d° se konverze ?
         jnz       hlpkonv3                 ; konverze se neprov†d°
         call      konvfnt                  ; konverze fontu znakñ
         mov       ds:[si-1],al             ; uloëen° p©evedenÇho znaku
hlpkonv3:loop      hlpkonv1                 ; dal®° znak ke konverzi
         pop       ds
         pop       si
         pop       cx
         pop       ax
         ret


public   hlpram

hlpram:                                   ;* zobrazen° r†mu obrazovky
         call      getdispcx
         dec       cx
         jmp       short hlpram2

hlpram0: mov       cx,23                    ; poáet ©†dkñk obrazovky
hlpram2: push      cx
         call      mouseoff                 ; vypnut° my®i
         mov       al,16                    ; barva r†mu
         call      outch1
         xor       dx,dx                    ; poá†teán° pozice horn°ho rohu
         mov       al,201                   ; levò horn° roh
         call      outch1
         mov       al,205                   ; horn° á†ra
         mov       cl,78                    ; dÇlka á†ry
         call      outch                    ; zobrazen° horn° á†ry
         mov       al,187                   ; pravò horn° roh
         call      outch1
         pop       cx
                                          ;* vnit©n° ©†dky
         mov       dh,1                     ; druhò ©†dek
hlpram1: push      cx
         xor       dl,dl                    ; poá†teán° pozice
         mov       al,186
         call      outch1                   ; levò okraj
         mov       al," "                   ; mazac° mezera
         mov       cl,78
         call      outch
         mov       al,186
         call      outch1                   ; pravò okraj
         pop       cx
         inc       dh
         loop      hlpram1                  ; dal®° ©†dek
                                          ;* spodn° ©†dek
         xor       dl,dl
;         mov       dx,24*256                ; poá†teán° pozice spodn°ho rohu
         mov       al,200                   ; pravò spodn° roh
         call      outch1
         mov       al,205                   ; spodn° á†ra
         mov       cx,78                    ; dÇlka á†ry
         call      outch                    ; zobrazen° horn° á†ry
         mov       al,188                   ; pravò horn° roh
         call      outch1
         mov       byte ptr cs:[citachod],0 ; vynulov†n° á°taáe hodin
         call      mouseon                  ; zapnut° my®i
         ret



public   hlpent

hlpent:                                   ;* skok do dal®° poloëky

         push      dx
         push      si
         push      di
         push      es
         mov       dx,cs:[hlptop]           ; pñvodn° adresa str†nky
         mov       es,cs:[hlpseg]           ; segment s textem
         mov       di,[hlpkurz]             ; adresa kurzoru
         call      hlpsrcl                  ; nalezen° n†và®t° v textu
         jc        hlpent3                  ; n†và®t° nenalezeno
         mov       cs:[hlptop],si           ; nov† adresa str†nky
         call      hlpstop                  ; nastaven° parametrñ pro zobrazen°
;         call      hlppred                  ; nalezen° adresy kurzoru p©edvolby
         mov       bh,80h                   ; p©°znak zmàny obrazovky
         clc                                ; p©°znak - poloëka zmànàna
hlpent3: pop       es
         pop       di
         pop       si
         pop       dx
         ret


public   hlppred

hlppred:                                  ;* nastaven° p©edvolby
                                            ; VSTUP: DX=pñvodn° adresa str†nky

         push      si
hlppred1:                                 ;* test, zda souhlas° poloëka
         mov       es,cs:[hlpseg]           ; segment s textem
         mov       di,[hlpkurz]             ; adresa kurzoru
         call      hlpsrcl                  ; nalezen° n†và®t° v textu
         jc        hlppred2                 ; n†và®t° nenalezeno
                                          ;* nalezen° zaá†tku str†nky
hlppred5:call      hlptestl                 ; test, zda je n†và®t° str†nky
         jc        hlppred3                 ; je jië konec textu
         jne       hlppred3                 ; nen° n†và®t° - OK
         call      hlpnext                  ; nalezen° dal®°ho ©†dku
         jnc       hlppred5                 ; test dal®°ho ©†dku
hlppred3:cmp       dx,si                    ; souhlas° nalezen† str†nka ?
         je        hlppred4                 ; str†nka nalezena
hlppred2:                                 ;* n†và®t° nesouhlas°/nenalezeno
         call      hlpright                 ; posun na dal®° n†và®t°
         jnc       hlppred1                 ; test dal®°ho n†và®t°
                                          ;* nastaven° prvn°ho n†và®t°
         call      hlpstop                  ; nastaven° na prvn° poloëku
hlppred4:                                 ;* n†và®t° nalezeno
         pop       si
         ret


public   hlphlp

hlphlp:                                   ;* zobrazen° n†povàdy

         push      word ptr ds:[hlptop]
         push      word ptr ds:[hlpkurz]
         lea       di,[txthlp1]             ; text "[HELP HELP]"
         call      hlpsrcl                  ; nalezen° n†và®t° n†povàdy
         jc        hlphlp3                  ; n†và®t° nenalezeno
         mov       ds:[hlptop],si           ; nastaven° adresy n†và®t°
         call      hlpstop                  ; nastaven° zaá†tku str†nky
         mov       bh,80h
         call      hlpall                   ; zobrazen° str†nky n†povàdy
         call      inpkeyf                  ; áek†n° na zad†n° kl†vesy
         mov       bh,80h
hlphlp3: pop       word ptr ds:[hlpkurz]
         pop       word ptr ds:[hlptop]     ; n†vrat poá†tku zobrazen°
         ret



public   hlphome

hlphome:                                  ;* nastaven° prvn° poloëky HOME
         call      hlpleft
         jnc       hlphome
         ret

public   hlpend

hlpend:                                   ;* nastaven° posledn° poloëky END
         call      hlpright
         jnc       hlpend
         ret


public   hlpup

hlpup:                                    ;* posun kurzoru nahoru
                                            ; VùSTUP: CY=operace neprovedena
         jmp       hlpleft



public   hlpleft

hlpleft:                                  ;* posun kurzoru vlevo
                                            ; VùSTUP: CY=operace neprovedena
         push      si
         mov       si,cs:[hlpkurz]          ; adresa kurzoru n†povàdy
         call      hlpspoll                 ; nalezen° p©edch†zej°c° poloëky
         jc        hlpleft2                 ; dal®° poloëka nenalezena
         mov       cs:[hlpkurz],si          ; nastaven° novÇ adresy kurzoru
         mov       bh,80h                   ; p©°znak zmàny obrazovky
hlpleft2:pop       si
         ret



public   hlpdown

hlpdown:                                  ;* posun kurzoru dolñ
                                            ; VùSTUP: CY=operace neprovedena
         jmp       hlpright



public   hlpright

hlpright:                                 ;* posun kurzoru vpravo
                                            ; VùSTUP: CY=operace neprovedena

         push      si
         mov       si,cs:[hlpkurz]          ; adresa kurzoru n†povàdy
         call      hlpspolr                 ; nalezen° dal®° poloëky
         jc        hlprght2                 ; dal®° poloëka nenalezena
         mov       cs:[hlpkurz],si          ; nastaven° novÇ adresy kurzoru
         mov       bh,80h                   ; p©°znak zmàny obrazovky
hlprght2:pop       si
         ret



public   hlpspoll

hlpspoll:                                 ;* hled†n° poloëky vlevo
                                            ; VSTUP: SI=adresa textu
                                            ; VùSTUP: CY=nen° dal®° poloëka
                                            ;         SI=adresa poloëky

         push      bx
         push      dx
         mov       bx,si                    ; £schova vòchoz° pozice
         mov       dx,si                    ; mezi£schova nalezenÇ pozice
         mov       si,cs:[hlptop]           ; pozice, od kterÇ se hled†
         jmp       short hlpspll2
hlpspll1:mov       dx,si                    ; mezi£schova nalezenÇ pozice
hlpspll2:call      hlpspolr                 ; nalezen° dal®° poloëky
         jc        hlpspll4                 ; nen° ë†dn† poloëka
         cmp       si,bx                    ; je dosaëeno pñvodn° poloëky ?
         jne       hlpspll1                 ; hled†n° dal®° poloëky
         cmp       si,dx                    ; byla nalezena dal®° poloëka ?
         stc
         je        hlpspll4                 ; nebyla nalezena dal®° poloëka
         mov       si,dx                    ; nalezen† poloëka
         clc                                ; p©°znak - poloëka nalezena
hlpspll4:pop       dx
         pop       bx
         ret



public   hlpspolr

hlpspolr:                                 ;* hled†n° poloëky vpravo
                                            ; VSTUP: SI=adresa textu
                                            ; VùSTUP: CY=nen° dal®° poloëka
                                            ;         SI=adresa poloëky

         push      ax
         inc       si                       ; dal®° znak
                                          ;* nalezen° poloëky v ©†dku
hlpsplr1:call      hlpchar                  ; naáten° dal®°ho znaku
         jnc       hlpsplr3                 ; je platnò znak
                                          ;* nalezen° dal®°ho ©†dku
hlpsplr2:call      hlpnext                  ; nalezen° dal®°ho ©†dku
         jc        hlpsplr5                 ; konec textu
         call      hlptestl                 ; je dal®° str†nka ?
         stc
         je        hlpsplr5                 ; je dal®° str†nka
         jmp       short hlpsplr1           ; nalezen° poloëky na ©†dku
hlpsplr3:                                 ;* test znaku na ©†dku
         cmp       al,"["                   ; je oznaáen° poloëky ?
         jne       hlpsplr1                 ; nen° oznaáen° poloëky - dal®° znak
         call      hlpchar                  ; naáten° dal®°ho znaku poloëky
         cmp       al,"["                   ; je zdvojenò znak ?
         je        hlpsplr1                 ; je zdvojenò znak - dal®° znak
         sub       si,2                     ; n†vrat zaá†tku poloëky
         clc                                ; p©°znak - poloëka nalezena
hlpsplr5:pop       ax
         ret



;
;public   hlptstp
;
;hlptstp:                                  ;* test, zda je poloëka volby
;                                            ; VSTUP: SI=adresa poloëky
;                                            ; VùSTUP: CY=nen° poloëka volby
;                                            ;         AL=znak za kurzorem
;         push      si
;         call      hlpchar                  ; naáten° znaku
;         cmp       al,"["                   ; je zaá†tek n†và®t° ?
;         stc
;         jne       hlptstp2                 ; nen° n†và®t°
;         call      hlpchar                  ; naáten° dal®°ho znaku
;         jc        hlptstp2                 ; konec ©†dku - nen° n†và®t°
;         cmp       al,"["                   ; je zdvojenò znak ?
;         stc
;         je        hlptstp2                 ; je zdvojenò znak - nen° n†và®t°
;         clc                                ; je n†và®t°
;hlptstp2:pop       si
;         ret
;


public   hlpsrcl

hlpsrcl:                                  ;* nalezen° n†và®t° v textu
                                            ; VSTUP: ES:DI=adresa n†và®t°
                                            ; VùSTUP: CY=n†và®t° nenalezeno
                                            ;         SI=adresa n†và®t°

         push      ax
         xor       si,si                    ; poá†teán° adresa souboru
hlpsrcl1:                                 ;* je opravdu n†và®t° ?
         call      hlptestl                 ; test, zda je n†và®t°
         jc        hlpsrcl5                 ; konec textu - nenalezeno
         jne       hlpsrcl4                 ; nen° n†và®t° - nalezen°
                                          ;* porovn†n° n†và®t°
         push      di
         push      si
         inc       si                       ; p©eskoáen° znaku "@"
hlpsrcl2:call      hlpchar                  ; testovanò znak
         call      highcase                 ; p©evod na velkÇ p°smeno
         mov       ah,al                    ; £schova znaku
         mov       al,es:[di]               ; hledanò znak
         inc       di
         call      highcase                 ; p©evod na velkÇ p°smeno
         cmp       al,ah                    ; porovn†n° znakñ
         jne       hlpsrcl3                 ; nen° shoda n†và®t°
         or        al,al                    ; je konec textu zdroje ?
         jz        hlpsrcl3                 ; konec zdrojovÇho n†và®t°
         cmp       al,"]"                   ; je ukonáen° n†và®t° ?
         jne       hlpsrcl2                 ; nen° konec n†và®t° - dal®° znak
hlpsrcl3:pop       si
         pop       di
         je        hlpsrcl5                 ; n†và®t° souhlas° - OK
hlpsrcl4:                                 ;* nalezen° dal®°ho n†và®t°
         call      hlpnxtl                  ; nalezen° dal®°ho n†và®t°
         jnc       hlpsrcl1                 ; n†và®t° nalezeno - jeho test
hlpsrcl5:
         pop       ax
         ret



public   hlpall

hlpall:                                   ;* zobrazen° str†nky textu
         push      ax
         push      cx
         push      dx
         push      si
         or        bh,bh                    ; je zmàna zobrazen° ?
         jz        hlpall3                  ; nen° zmàna zobrazen°
         mov       si,cs:[hlptop]           ; zaá†tek zobrazen°
         mov       cx,23                    ; poáet ©†dkñ k zobrazen°
         mov       dh,1                     ; poá†teán° ©†dek k zobrazen°
hlpall1: call      hlpline                  ; zobrazen° jednoho ©†dku
         call      hlptestl                 ; test, zda je n†và®t° str†nky
         jbe       hlpall2                  ; je n†và®t° nebo konec textu
         call      hlpnext                  ; nalezen° dal®°ho ©†dku
hlpall2: inc       dh                       ; zvò®en° á°sla ©†dku
         loop      hlpall1                  ; zobrazen° dal®°ho ©†dku n†povàdy
         xor       bh,bh
hlpall3: pop       si
         pop       dx
         pop       cx
         pop       ax
         ret


public   hlpline

hlpline:                                  ;* zobrazen° ©†dku
                                            ; VSTUP: DH=©†dek na displeji
                                            ;        SI=poá†teán° adresa
                                            ; VùSTUP: SI=koncov† adresa
;         call      mouseoff                 ; vypnut° my®i
         push      ax
         push      bx
         push      cx
         push      dx
         mov       dl,2                     ; poá†teán° pozice pro zobrazen°
         mov       al,16
         call      outch1                   ; barva pro zobrazen° textu
         mov       cx,76                    ; poáet znakñ na ©†dek
         call      hlptestl                 ; test, zda je n†và®t° str†nky
         ja        hlpline1                 ; nen° dal®° str†nka ani konec textu
hlpline0:jmp       hlpline8                 ; je dal®° str†nka nebo konec textu
hlpline1:jcxz      hlpline0                 ; je konec ©†dku
         or        cx,cx
         js        hlpline0
         call      hlpchar                  ; naáten° dal®°ho znaku
         jc        hlpline0                 ; nen° jië dal®° znak na ©†dku
hlpline2:mov       bx,1                     ; 1 znak k zobrazen°
                                          ;* zaá†tek poloëky
         cmp       al,"["                   ; je poloëka n†povàdy ?
         jne       hlplin31                 ; nen° poloëka n†povàdy
         call      hlpchar                  ; naáten° dal®°ho znaku
         cmp       al,"["                   ; je platnò znak "[" ?
         je        hlplin31                 ; je platnò znak "["
         push      ax                       ; £schova znaku
         push      si
         sub       si,2
         mov       al,17                    ; barva poloëky n†povàdy
         cmp       si,cs:[hlpkurz]          ; je to poloëka s kurzorem ?
         jne       hlplin32                 ; nen° poloëka s kurzorem
         mov       al,18                    ; barva poloëky s kurzorem
hlplin32:call      outch1                   ; nastaven° barvy poloëky
         mov       al," "                   ; oddàlovac° mezera
         call      outch1
         dec       cx
         pop       si
         pop       ax
hlplin31:                                 ;* konec poloëky
         cmp       al,"]"                   ; je poloëka n†povàdy ?
         jne       hlplin34                 ; nen° poloëka n†povàdy
         call      hlpchar                  ; naáten° dal®°ho znaku
         cmp       al,"]"                   ; je platnò znak "]" ?
         je        hlplin34                 ; je platnò znak "]"
         push      ax                       ; £schova znaku
         mov       al," "                   ; oddàlovac° mezera
         call      outch1
         dec       cx
         mov       al,16                    ; norm†ln° barva podkladu
         call      outch1                   ; nastaven° barvy poloëky
         pop       ax
hlplin34:
         cmp       al,31                    ; je platnò znak ASCII ?
         ja        hlpline5                 ; je platnò znak ASCII - zobrazen°
         jb        hlpline4                 ; nen° speci†ln° znak
                                          ;* dek¢dov†n° speci†ln°ho znaku
         call      hlpdeks                  ; dek¢dov†n° speci†ln°ch znakñ
         jc        hlpline8                 ; konec textu
         jcxz      hlpline8                 ; je konec ©†dku
         jmp       short hlpline2           ; dek¢dov†n° dal®°ho znaku

hlpline4:cmp       al,1                     ; je opakovaá ?
         mov       bl,al                    ; poáet znakñ k z†pisu
         mov       al," "                   ; n†hradn° mezera
         ja        hlpline5                 ; je tabel†tor
                                          ;* zobrazen° opakovaáe
         call      hlpchar                  ; áten° dal®°ho znaku
         jc        hlpline8                 ; je jië konec ©†dku
         cmp       al,32                    ; je men®° znak neë 32 ?
         jb        hlpline2                 ; je men®° znak neë 32
         sub       al,32                    ; vòpoáet poátu opakov†n°
         mov       bl,al                    ; poáet opakov†n°
         call      hlpchar                  ; áten° dal®°ho znaku k opakov†n°
         jc        hlpline8                 ; nen° jië dal®° znak
                                          ;* kontrola, zda je spec. ©°d. znak
         or        bl,bl                    ; je poáet = 0 ?
         jne       hlpline5                 ; nen° = 0
         inc       bl                       ; poáet = 1
         cmp       al,"["                   ; je znak "[" ?
         je        hlplin52                 ; je znak "["
         cmp       al,"]"
         jne       hlplin53                 ; nen° znak "]"
hlplin52:push      ax
         call      hlpchar                  ; naáten° dal®°ho znaku - ignorov†n°
         pop       ax
hlplin53:sub       al,"@"                   ; korekce na ©°dic° znak
hlpline5:cmp       bl,cl                    ; je vàt®° neë á°taá ?
         jbe       hlpline6                 ; nen° p©eteáen°
         mov       bl,cl                    ; omezen° dÇlky
hlpline6:sub       cl,bl                    ; sn°ëen° á°taáe
         push      cx
         mov       cl,bl                    ; poáet znakñ k z†pisu
         call      outch0                   ; zobrazen° znakñ
         pop       cx
         jmp       hlpline1                 ; dal®° znak

hlpline8:mov       al,16                    ; norm†ln° barva podkladu
         call      outch1
         mov       al," "                   ; mazac° mezera
         call      outch                    ; vymaz†n° zbytku ©†dku
         pop       dx
         pop       cx
         pop       bx
         pop       ax
;         call      mouseon                  ; zapnut° my®i
         ret


public   hlpdeks

hlpdeks:                                  ;* dek¢dov†n° speci†ln°ch funkc°

         call      hlpchar                  ; naáten° oznaáen° funkce
         jc        hlpline8                 ; nen° jië dal®° znak na ©†dku
                                          ;* ignorov†n° p©ep°naáe "*"
         cmp       al,"*"                   ; je p©ep°naá "*" ?
         je        hlpdeks7                 ; dal®° znak
                                          ;* dek¢dov†n° ©°dic°ho znaku < 32
         cmp       al,"^"                   ; je ©°dic° znak ?
         jne       hlpdeks2                 ; je ©°dic° znak
         call      hlpchar                  ; áten° znaku
         cmp       al,"@"                   ; nejmen®° povolenò znak
         cmc
         jnb       hlpdeks8                 ; nepovolenò znak

         cmp       al,"["                   ; je znak "[" ?
         je        hlpdeks1                 ; je znak "["
         cmp       al,"]"
         jne       hlpdeks4                 ; nen° znak "]"
hlpdeks1:push      ax
         call      hlpchar                  ; naáten° dal®°ho znaku - ignorov†n°
         pop       ax
hlpdeks4:
         sub       al,"@"                   ; korekce na znak
         call      outch10                  ; zobrazen° znaku
         dec       cx                       ; sn°ëen° á°taáe
         jmp       short hlpdeks7
hlpdeks2:                                 ;* nastaven° norm†ln° barvy
         cmp       al,"N"                   ; je nastaven° norm†ln° barvy ?
         jne       hlpdeks3                 ; nen° nastaven° "N"
         mov       al,16
         call      outch1                   ; nastaven° norm†ln° barvy
         jmp       short hlpdeks7           ; dal®° znak
hlpdeks3:                                 ;* nastaven° barvy pop©ed° i pozad°
         call      hlpdekb0                 ; dek¢dov†n° barvy pozad°
         jc        hlpdeks8                 ; nen° dal®° znak
         call      hlpdekf0                 ; dek¢dov†n° barvy pop©ed°
         jmp       short hlpdeks8           ; nezn†mò k¢d operace
hlpdeks7:call      hlpchar                  ; naáten° dal®°ho znaku
hlpdeks8:ret


public   hlpdekf

hlpdekf:                                  ;* dek¢dov†n° barvy pop©ed°

         call      hlpchar                  ; naáten° barvy pop©ed°
         jc        hlpdekf2                 ; nen° dal®° znak
hlpdekf0:cmp       al,"X"                   ; màn° se barva ?
         je        hlpdekf1                 ; barva se nemàn°
         cmp       al,"Y"                   ; je standardn° barva ?
         jne       hlpdekf3                 ; nen° standardn° nastaven°
         mov       al,cs:[col16]            ; standardn° nastaven° podkladu
         and       al,0fh
         jmp       short hlpdekf4
hlpdekf3:call      hlpdekc                  ; dek¢dov†n° barvy
         cmc
         jnc       hlpdekf2                 ; nen° platnÇ oznaáen° barvy
hlpdekf4:mov       ah,cs:[color]            ; souáasnÇ nastaven° barvy
         and       ah,0f0h                  ; zru®en° pñvodn° barvy pop©ed°
         or        ah,al                    ; nov† barva pop©ed°
         mov       cs:[color],ah            ; novÇ nastaven° barvy
hlpdekf1:call      hlpchar
hlpdekf2:ret


public   hlpdekb
hlpdekb:                                  ;* dek¢dov†n° barvy pozad°

         call      hlpchar                  ; naáten° barvy pozad°
         jc        hlpdekb2                 ; nen° dal®° znak
hlpdekb0:cmp       al,"X"                   ; màn° se barva ?
         je        hlpdekb1                 ; barva se nemàn°
         cmp       al,"Y"                   ; je standardn° barva ?
         jne       hlpdekb3                 ; nen° standardn° nastaven°
         mov       al,cs:[col16]            ; standardn° nastaven° podkladu
         and       al,0f0h
         jmp       short hlpdekb4
hlpdekb3:call      hlpdekc                  ; dek¢dov†n° barvy
         cmc
         jnc       hlpdekb2                 ; nen° platnÇ oznaáen° barvy
         shl       al,1
         shl       al,1
         shl       al,1
         shl       al,1
hlpdekb4:mov       ah,cs:[color]            ; souáasnÇ nastaven° barvy
         and       ah,0fh                   ; zru®en° pñvodn° barvy pozad°
         or        ah,al                    ; nov† barva pozad°
         mov       cs:[color],ah            ; novÇ nastaven° barvy
hlpdekb1:call      hlpchar
hlpdekb2:ret


public   hlpdekc

hlpdekc:                                  ;* dek¢dov†n° barvy
                                            ; VSTUP: AL=oznaáen° barvy
                                            ; VùSTUP: AL=á°slo barvy
                                            ;         CY=neplatnÇ oznaáen° barvy

         cmp       al,"0"
         jc        hlpdekc5
         cmp       al,"9"
         ja        hlpdekc2
         sub       al,"0"
         jmp       short hlpdekc5
hlpdekc2:cmp       al,"A"
         jb        hlpdekc5
         cmp       al,"G"
         cmc
         jc        hlpdekc5
         sub       al,"A"-10
hlpdekc5:ret



public   hlpstop

hlpstop:                                  ;* nalezen° zaá†tku str†nky
                                            ;         CY=je konec souboru

         push      ax
         push      si
         mov       si,cs:[hlptop]           ; poá†teán° adresa zobrazen°
         cmp       si,cs:[hlpnum]           ; je p©ekroáen° konce ?
         jb        hlpstop1
         xor       si,si
hlpstop1:call      hlptestl                 ; test, zda je n†và®t° str†nky
         jc        hlpstop2                 ; je jië konec textu
         jne       hlpstop2                 ; nen° n†và®t° - OK
         call      hlpnext                  ; nalezen° dal®°ho ©†dku
         jnc       hlpstop1                 ; test dal®°ho ©†dku
hlpstop2:mov       cs:[hlptop],si           ; nov† adresa zaá†tku
         mov       cs:[hlpkurz],si          ; nastaven° kurzoru
         pop       si
         pop       ax
         call      hlpright                 ; nastaven° na prvn° poloëku
         ret



public   hlpnxtl

hlpnxtl:                                  ;* nalezen° dal®°ho n†và®t°
                                            ; VSTUP: SI=ukazatel textu
                                            ; VùSTUP: SI=adresa dal®°ho n†và®t°
                                            ;         CY=nen° dal®° n†và®t°

         push      ax
hlpnxtl1:call      hlpnext                  ; nalezen° dal®°ho ©†dku
         jc        hlpnxtl2                 ; je konec textu
         call      hlptestl                 ; test, zda je n†và®t° str†nky
         jc        hlpnxtl2                 ; je jië konec textu
         jne       hlpnxtl1                 ; nen° n†và®t° - dal®° ©†dek
hlpnxtl2:pop       ax
         ret




public   hlptestl

hlptestl:                                 ;* test, zda je n†và®t° str†nky
                                            ; VSTUP: SI=ukazatel zaá†tku ©†dku
                                            ; VùSTUP: CY=konec textu
                                            ;         ZY=je n†và®t° str†nky

         push      ax
         cmp       si,cs:[hlpnum]           ; je jië dosaëeno konce textu ?
         cmc
         jb        hlptstl2                 ; je jië konec textu
         push      si
         call      hlpchar                  ; p©eáten° prvn°ho znaku na ©†dku
         pop       si
         cmp       al,"@"                   ; je n†và®t° ?
         clc
hlptstl2:pop       ax
         ret



public   hlpnext

hlpnext:                                  ;* nalezen° dal®°ho ©†dku
                                            ; VSTUP: SI=vòchoz° adresa
                                            ; VùSTUP: SI=n†sleduj°c° ©†dek
                                            ;         CY=je konec souboru

hlpnext1:call      hlpchar                  ; áten° n†sleduj°c°ho znaku
         jnc       hlpnext1                 ; vypu®tàn° zbylòch znakñ
         cmp       si,cs:[hlpnum]           ; je jië dosaëeno konce textu ?
         cmc
         jb        hlpnext2                 ; je jië konec textu
         inc       si                       ; p©eskoáen° znaku EOL
hlpnext2:ret



public   hlpchar

hlpchar:                                  ;* áten° n†sleduj°c°ho znaku
                                            ; VSTUP: SI=adresa znaku
                                            ; VùSTUP: AL=znak textu
                                            ;         CY=konec ©†dku
         push      ds
         cmp       si,cs:[hlpnum]           ; je jië dosaëeno konce textu ?
         jae       hlpchar8                 ; je jië konec textu
         mov       ds,cs:[hlpseg]           ; segment s textem n†povàdy
         lodsb                              ; naáten° dal®°ho znaku
         or        al,al                    ; je konec souboru ?
         jz        hlpchar8                 ; je konec souboru
         cmp       al,1eh                   ; je konec ©†dku ?
         clc
         jne       hlpchar7                 ; nen° konec ©†dku
         dec       si                       ; n†vrat pozice
hlpchar8:xor       al,al                    ; n†hradn° znak - konec textu
         stc                                ; p©°znak konce ©†dku
hlpchar7:pop       ds
         ret


code     ends

         end

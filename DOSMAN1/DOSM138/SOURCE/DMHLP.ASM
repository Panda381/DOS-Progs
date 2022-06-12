
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
extrn    edikey:word,testkey:near,getdispcx:near,parint2:byte
extrn    podklad:near,wram1:near,wram2:near,wnadpis:near,stinw:near
extrn    kaltxt1:byte,poctydnu:byte,unordnu:byte,aktden:dword
extrn    tisknm2s:near,center:near,outtxt:near,soubkal:byte
extrn    rozbdat:byte,rozbdat0:byte,rozbnum:near,outspc:near,rozbodd:near
extrn    kaltxt2:byte,kaltxt3:byte,txtkon2:byte,kaltxt4:byte
extrn    bufcalc:word,bufcalc1:byte,bufcalc2:byte,bufcalc3:word
extrn    caltxt1:byte,vysledek:dword,select:near,baze:byte,caltxt2:byte
extrn    col10:byte,col20:byte,ukazkey:dword,conf6:byte

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

         test      byte ptr ds:[conf6],80h  ; automatickò kalend†© ?
         jz        help00                   ; nen° automatickò kalend†©

         jmp       help00k                  ; automatickò kalend†©

help00:
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
                                          ;* dek¢dov†n° data
         lea       si,[dny]                 ; seznam dnñ
         call      askvol                   ; poskytnut° adresy dne v tòdnu
         call      transtxt                 ; p©enos textu dne
         lea       si,[texthlp4]            ; oddàlovac° á†rka
         call      transtxt                 ; oddàlovac° á†rka
         call      dekoddat                 ; dek¢dov†n° data

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
         cmp       al,2                     ; je kalend†© ?
         jne       help162                  ; nen° kalend†©
help00k: and       byte ptr cs:[conf6],not 80h ; zru®en° p©°znaku aut. kalend†©e
         call      kalendar                 ; kalend†©
         jmp       short help2
help162: cmp       al,1
         jne       help164                  ; nen° kalkul†tor
         call      kalkulator               ; kalkul†tor
         jmp       short help2
help164:

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

         mov       si,offset filehelp       ; jmÇno souboru "DOSMAN.HLP"
         call      hlpsoub                  ; sestaven° cesty k souboru
         call      hlpopen                  ; otev©en° souboru
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

hlpmain3:call      hlpmemor                 ; uráen° volnÇ pamàti
         jc        hlpmain2                 ; chyba - nedostatek pamàti

         call      hlpread                  ; naáten° souboru do pamàti
         call      hlpclose                 ; uzav©en° souboru
         jc        hlpmain2                 ; chyba operace
         or        ax,ax
         jz        hlpmain2                 ; nen° ë†dnò znak v souboru


         call      hlpkonv                  ; konverze fontñ v textech
         call      hlpram0                  ; zobrazen° r†mu n†povàdy
         call      mouseoff                 ; vypnut° kurzoru my®i

         or        byte ptr cs:[parint2],2  ; p©°znak zobrazen° n†povàdy

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
         and       byte ptr cs:[parint2],not 2 ; vyp. p©°znaku zobraz. n†povàdy

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



; -----------------------------------------------------------------------------
;                                Kalend†©
; -----------------------------------------------------------------------------

public   kalendar
kalendar:                                 ;* kalend†©

ifdef    upver
         push      cs
         pop       ds
         push      cs
         pop       es

                                          ;* naáten° souboru DOSMAN.CAL
         mov       word ptr ds:[hlpnum],0   ; zru®en° dat v pamàti
         mov       si,offset soubkal        ; pozn†mky pro kalend†©
         call      hlpsoub                  ; sestaven° cesty k souboru
         call      hlpopen                  ; otev©en° souboru DOSMAN.CAL
         jc        kalend15                 ; soubor nenalezen
         call      hlpmemor                 ; uráen° volnÇ pamàti
         jc        kalend15                 ; nedostatek pamàti
         call      hlpread                  ; naáten° souboru do pamàti
         call      hlpclose                 ; uzav©en° souboru
kalend15:

         mov       ah,2ah
         int       21h                      ; poskytnut° systÇmovÇho data
         mov       bx,dx                    ; den a màs°c
         call      setdatum                 ; nastaven° poátu dnñ podle data

kalend16:                                 ;* vykreslen° podkladu okna
         mov       dx,3*256+15              ; poá†teán° pozice okna
         mov       cx,17*256+50             ; rozmàry okna
         mov       al,7                     ; barva pro okno volby
         call      outch1                   ; nastaven° barvy á°slo 7
         call      podklad                  ; vykreslen° podkladu okna
         call      wram1                    ; zobrazen° vnit©n°ho r†meáku
         call      wram2                    ; zobrazen° vnàj®°ho r†meáku
         mov       di,offset kaltxt1        ; text nadpisu
         call      wnadpis                  ; zobrazen° nadpisu okna
         call      stinw                    ; zobrazen° st°nu okna

                                          ;* zobrazen° oddàlovac°ch áar
         push      dx
         add       dh,4                     ; horn° linka
         call      kallinka                 ; oddàlovac° linka pod dny
         add       dh,7
         call      kallinka                 ; linka mezi dny a pozn†mkou
;         add       dh,4
;         call      kallinka                 ; oddàlovac° linka nad n†povàdou
         pop       dx

kalend1:
         push      cs
         pop       ds
         push      cs
         pop       es

         call      kalall                   ; zobrazen° aktu†ln°ho màs°ce
                                          ;* zobrazen° aktu†ln°ho data
         push      dx                       ; £schova pozice okna
         push      cx
         push      cx                       ; £schova rozmàrñ okna
         call      getdatum                 ; vòpoáet aktu†ln°ho data
         add       dh,2                     ; ©†dek k zobrazen° data
         push      dx                       ; £schova pozice textu
         mov       dx,bx                    ; den a màs°c
         mov       di,offset helpbuf        ; buffer pro n†povàdu
         mov       si,di                    ; adresa textu
         call      dekoddat                 ; dek¢dov†n° data

         pop       dx                       ; n†vrat pozice textu
         pop       cx                       ; n†vrat rozmàrñ okna
         call      center                   ; centrov†n° textu
         call      mouseoff                 ; vypnut° kurzoru my®i
         mov       al,10                    ; zvòraznànò text
         call      outch1                   ; nastaven° zvòraznànÇ barvy
         sub       dl,6
         mov       cx,6
         mov       al," "
         call      outch                    ; vymaz†n° zaá†tku textu
         call      outtxt                   ; zobrazen° textu data
         call      outch                    ; vymaz†n° konce textu
         pop       cx
         pop       dx                       ; n†vrat pozice okna

                                          ;* zobrazen° pozn†mky k datu
         push      cx
         push      dx
         sub       cl,10                    ; maxim†ln° ®°©ka textu
         add       dx,12*256+5              ; poá†teán° pozice textu
         xor       si,si
         call      hlpfndd                  ; zobrazen° ©†dku
         inc       dh
         call      hlpfndd                  ; zobrazen° druhÇho ©†dku
         inc       dh
         call      hlpfndd                  ; zobrazen° t©et°ho ©†dku
         pop       dx
         pop       cx
         call      mouseon                  ; zapnut° kurzoru my®i

kalend2:
         call      mouseoff                 ; vypnut° my®i
         call      kurzout                  ; vypnut° kurzoru
         lea       si,[tabhlfnd]            ; pr†zdn† funkce
         call      inpkeyh                  ; vstup znaku pro n†povàdu
         call      mouseon                  ; zapnut° my®i
         cmp       al,0fh                   ; je Ctrl-O ?
         jne       kalend4
         call      kalend8                  ; vypnut° okna
         call      inpkeyf
         jmp       kalend16                 ; novÇ zobrazen° okna

kalend4: cmp       al,0ah                   ; je Ctrl-Enter ?
         jne       kalend5
                                          ;* sestaven° aktu†ln°ho data
         mov       di,offset helpbuf        ; buffer pro n†povàdu
         mov       word ptr ds:[ukazkey],di
         mov       word ptr ds:[ukazkey+2],ds
         call      getdatum                 ; vòpoáet aktu†ln°ho data
         mov       dx,bx                    ; den a màs°c
         call      dekoddat                 ; dek¢dov†n° data
         jmp       short kalend8            ; konec

kalend5: cmp       al,27
         je        kalend8
         cmp       al,13
         je        kalend6                  ; nastaven° novÇho data

         call      mouseoff                 ; vypnut° my®i
         push      cx
         push      dx
         mov       bx,offset kalskok        ; tabulka skokñ kalend†©e
         call      skokax                   ; skok na obsluhu
         pop       dx
         pop       cx
         call      mouseon                  ; zapnut° my®i
         jc        kalend2                  ; kl†vesa nebyla obslouëena
         jmp       kalend1                  ; p©ekreslen° stavu

kalend6:                                  ;* nastaven° novÇho data
         call      windret
                                          ;* dotaz ovà©uj°c° zad†n°
         mov       di,offset helpbuf        ; buffer pro n†povàdu
         mov       si,offset kaltxt2        ; £vodn° text dotazu
         call      transtxt                 ; p©enos £vodn° á†sti textu
         call      getdatum                 ; poskytnut° nastavenÇho data
         mov       dx,bx                    ; màs°c a den
         call      dekoddat                 ; dek¢dov†n° data
         mov       si,offset kaltxt3        ; zbytek textu
         call      transtxt                 ; p©enos zbytku textu
         mov       di,offset helpbuf        ; nadpis
         mov       si,offset txtkon2        ; volby ANO/NE
         xor       al,al                    ; p©edvolba ANO
         call      volbyh                   ; volba (dotaz)
         jc        kalend8                  ; p©eru®en° operace
         or        al,al
         jnz       kalend8                  ; je volba NE
                                          ;* nastaven° data
         call      getdatum                 ; poskytnut° nastavenÇho data
         mov       dx,bx                    ; màs°c a den
         mov       ah,2bh
         int       21h                      ; nastaven° novÇho data
         inc       al                       ; bylo zad†no spr†vnÇ datum ?
         jnz       kalend8                  ; datum bylo OK
                                          ;* chybovÇ hl†®en°
         call      windret
         mov       di,offset kaltxt4        ; chybovÇ hl†®en°
         mov       si,offset txtchyb1       ; volba OK
         xor       al,al
         call      volbyh
kalend8:
                                          ;* n†vrat zobrazen° okna
                                            ; (pouë°v† se jako podprogram !)
         pushf
         call      windret                  ; n†vrat zobrazen° okna
         test      byte ptr cs:[parint],30h ; je funkce F3 nebo F4 ?
         jnz       kalend9                  ; je F3 nebo F4
         call      outhelp                  ; zobrazen° n†povàdy
kalend9: popf

endif
         ret

ifdef    upver

kalskok  label     word                   ;* tabulka skokñ obsluhy kalend†©e
         db        40h+12                   ; testuje se AH
         db        4bh                      ; kurzor vlevo
         dw        offset kalleft
         db        4dh                      ; kurzor vpravo
         dw        offset kalright
         db        48h                      ; kurzor nahoru
         dw        offset kalup
         db        50h                      ; kurzor dolñ
         dw        offset kaldown
         db        47h                      ; prvn° den Home
         dw        offset kalhome
         db        4fh                      ; posledn° den End
         dw        offset kalend
         db        49h                      ; Page Up - posun o rok zpàt
         dw        offset kalpgup
         db        51h                      ; Page Down - posun o rok vp©ed
         dw        offset kalpgdwn
         db        84h                      ; Ctrl-Page Up - o 10 let zpàt
         dw        offset kalcpgup
         db        76h                      ; Ctrl-Page Down - o 10 let vp©ed
         dw        offset kalcpgdn
         db        77h                      ; Ctrl-Home - zaá†tek roku
         dw        offset kalchome
         db        75h                      ; Ctrl-End - konec roku
         dw        offset kalcend

         db        0


public   kalleft
kalleft:                                  ;* kurzor o den vlevo
         call      decden                   ; sn°ëen° dne o 1
         ret

public   kalright
kalright:                                 ;* kurzor o den vpravo
         call      incden                   ; zvò®en° poátu dnñ o 1
         ret


public   kalup
kalup:                                    ;* kurzor nahoru (o màs°c)
         call      getdatum                 ; poskytnut° aktu†ln°ho data
kalup1:  mov       dl,bl                    ; datum v tomto màs°ci
         mov       al,bl
         call      subden0                  ; odeáten° AL dnñ
         call      getdatum                 ; poskytnut° novÇho data
         mov       al,ah                    ; poáet dnñ v màs°ci
         sub       al,dl                    ; poáet dnñ pro posun
         jc        kalup2                   ; je men®° poáet dnñ
         call      subden0                  ; odeáten° AL dnñ
kalup2:  ret

public   kaldown
kaldown:                                  ;* kurzor dolñ (o màs°c)

         call      getdatum                 ; poskytnut° aktu†ln°ho data
kaldwn1: mov       dl,bl                    ; den v tomto màs°ci
         sub       ah,bl                    ; poáet zbylòch dnñ
         mov       al,ah                    ; poáet zbylòch dnñ
         inc       al                       ; poáet dnñ + 1
         call      addden0                  ; zvò®en° na 1. p©°®t° màs°c
         call      getdatum                 ; poskytnut° novÇho data
         mov       al,dl                    ; poëadovanÇ datum
         cmp       ah,al                    ; je vàt®° datum neë poáet dnñ ?
         jae       kaldwn2                  ; nen° vàt®°
         mov       al,ah                    ; omezen° na posledn° den
kaldwn2: dec       al                       ; datum - 1
         call      addden0                  ; zvò®en° data o AL dnñ
         ret

public   kalchome
kalchome:                                 ;* kurzor na zaá†tek roku
         call      getdatum                 ; poskytnut° aktu†ln°ho data
         cmp       bh,1                     ; je nastaven leden ?
         je        kalhome                  ; je leden - nastaven° na zaá†tek
         call      kalup1                   ; posun o màs°c zpàt
         jmp       short kalchome

public   kalhome
kalhome:                                  ;* kurzor na prvn° den màs°ce
         call      getdatum                 ; poskytnut° aktu†ln°ho data
         mov       al,bl                    ; aktu†ln° den
         dec       al
         call      subden0                  ; sn°ëen° dne na 1.
         ret


public   kalcend
kalcend:                                  ;* kurzor na konec roku
         call      getdatum                 ; poskytnut° aktu†ln°ho data
         cmp       bh,12                    ; je nastaven prosinec ?
         je        kalend                   ; je prosinec - nastaven° na konec
         call      kaldwn1                  ; posun o màs°c vp©ed
         jmp       short kalcend


public   kalend
kalend:                                   ;* kurzor na posledn° den màs°ce
         call      getdatum                 ; poskytnut° aktivn°ho data
         mov       al,ah                    ; poáet dnñ v màs°ci
         sub       al,bl                    ; poáet zbylòch dnñ do konec
         call      addden0                  ; zvò®en° poátu dnñ na posledn°
         ret

public   kalpgup
kalpgup:                                  ;* posun o rok zpàt
         push      cx
         call      getdatum                 ; poskytnut° aktivn°ho data
         mov       dx,365                   ; poáet dnñ pro nep©estupnò rok
         cmp       bh,2                     ; je leden nebo £nor ?
         ja        kalpgup3                 ; je vy®®° màs°c neë £nor
                                          ;* je leden nebo £nor
         jb        kalpgup2                 ; je leden
         cmp       bl,29                    ; je 29.£nora ?
         je        kalpgup3                 ; je 29. £nora
kalpgup2:dec       cx                       ; poá°t† se p©ede®lò rok
kalpgup3:call      roktest                  ; je to p©estupnò rok ?
         jnc       kalpgup4                 ; nen° to p©estupnò rok
         inc       dx                       ; poáet dnñ = 366
kalpgup4:mov       ax,dx                    ; poáet dnñ ke korekci
         call      subden                   ; sn°ëen° poátu dnñ
         pop       cx
         ret

public   kalcpgup
kalcpgup:                                 ;* posun o 10 let zpàt
         mov       cx,10
kalcpgp2:call      kalpgup                  ; posun o rok zpàt
         loop      kalcpgp2                 ; posun o dal®° rok
         ret


public   kalpgdwn
kalpgdwn:                                 ;* posun o rok vp©ed
         push      cx
         call      getdatum                 ; poskytnut° aktivn°ho data
         mov       dx,365                   ; poáet dnñ pro nep©estupnò rok
         cmp       bx,2*256+29              ; je 29. £nora ?
         je        kalpgdn2                 ; je 29. £nora
         cmp       bh,2                     ; je leden nebo £nor ?
         jbe       kalpgdn3                 ; je leden nebo £nor
kalpgdn2:inc       cx                       ; poá°t† se n†sleduj°c° rok
kalpgdn3:call      roktest                  ; je to p©estupnò rok ?
         jnc       kalpgdn4                 ; nen° to p©estupnò rok
         inc       dx                       ; poáet dnñ = 366
kalpgdn4:mov       ax,dx                    ; poáet dnñ ke korekci
         call      addden                   ; zvò®en° poátu dnñ
         pop       cx
         ret


public   kalcpgdn
kalcpgdn:                                 ;* posun o 10 let vp©ed
         mov       cx,10
kalcpgd2:call      kalpgdwn                 ; posun o rok vp©ed
         loop      kalcpgd2                 ; posun o dal®° rok
         ret


public   kallinka
kallinka:                                 ;* oddàlovac° linka
         call      mouseoff                 ; vypnut° kurzoru my®i
         push      ax
         push      dx
         push      cx
         xor       ch,ch
         add       dl,3
         mov       al,7
         call      outch1                   ; nastaven° barvy linky
         mov       al,195                   ; levò okraj
         call      outch1                   ; zobrazen° levÇho okraje
         mov       al,196                   ; vodorovn† linka
         sub       cl,8                     ; odeáten° okrajñ
         call      outch                    ; zobrazen° vodorovnÇ linky
         mov       al,180                   ; pravò okraj
         call      outch1                   ; zobrazen° pravÇho okraje
         pop       cx
         pop       dx
         pop       ax
         call      mouseon                  ; zapnut° kurzoru my®i
         ret


public   kalall
kalall:                                   ;* zobrazen° v®ech dnñ v màs°ci
                                            ; VSTUP: DX=pozice okna

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         call      mouseoff                 ; vypnut° kurzoru my®i
                                          ;* vòpoáet prvn°ho dne v màs°ci
         push      word ptr ds:[aktden]     ; £schova aktu†ln°ho dne - LOW
         push      word ptr ds:[aktden+2]   ; £schova aktu†ln°ho dne - HIGH
         call      getdatum                 ; vòpoáet aktu†ln°ho data
         mov       al,bl                    ; den v màs°ci
         dec       al                       ; offset v màs°ci
         call      subden0                  ; odeáten° AL dnñ
         mov       ah,bl                    ; den v màs°ci
         mov       si,ax                    ; £schova aktu†ln°ho dne
         call      getdatum                 ; vòpoáet prvn°ho dne v màs°ci
         pop       word ptr ds:[aktden+2]   ; n†vrat aktu†ln°ho dne - HIGH
         pop       word ptr ds:[aktden]     ; n†vrat aktu†ln°ho dne - LOW
                                          ;* p©°prava parametrñ
         mov       bh,al                    ; prvn° den v tòdnu
         mov       bl,1                     ; poá†teán° den
         xor       cx,cx
         mov       cl,ah                    ; poáet dnñ v màs°ci
         mov       ax,si                    ; n†vrat aktu†ln°ho dne AH
                                          ;* vymaz†n° poá†teán°ch dnñ
         push      ax
         push      cx                       ; poáet dnñ v màs°ci
         push      dx                       ; poá†teán° pozice okna
         mov       al,7
         call      outch1                   ; nastaven° norm†ln° barvy
         mov       cl,4                     ; poáet znakñ na den
         mov       al,bh                    ; prvn° den v tòdnu
         mul       cl                       ; poáet mezer na zaá†tku
         mov       cl,al                    ; poáet mezer k vymaz†n°
         add       dx,5*256+11              ; poá†teán° pozice kurzoru
         mov       al," "                   ; mazac° mezera
         call      outch                    ; vymaz†n° zaá†tku
         pop       dx
         pop       cx
         pop       ax

                                          ;* zobrazen° jednoho dne
kalall2: push      dx                       ; £schova pozice okna
         push      ax                       ; £schova aktu†ln°ho dne
         call      kalkurz                  ; vòpoáet pozice kurzoru
                                          ;* nastaven° barvy dne (kurzoru)
         cmp       ah,bl                    ; je aktu†ln° den ?
         je        kalall5                  ; je aktu†ln° den
         cmp       al,6                     ; je nedàle ?
         mov       al,7                     ; barva norm†ln°ho textu
         jne       kalall3                  ; nen° nedàle
         mov       al,10                    ; barva pro nedàli
kalall3: jmp       short kalall4
kalall5: cmp       al,6                     ; je nedàle ?
         mov       al,19                    ; barva norm†ln°ho textu
         jne       kalall4                  ; nen° nedàle
         mov       al,14                    ; barva pro nedàli
kalall4: call      outch1                   ; nastaven° barvy kurzoru
                                          ;* zobrazen° dne (kurzoru)
         mov       al," "
         call      outch1                   ; zobrazen° £vodn° mezery
         mov       al,bl                    ; den k zobrazen°
         call      tisknm2s                 ; tisk á°sla s mezerami
         mov       al," "
         call      outch1                   ; zobrazen° koncovÇ mezery
         pop       ax                       ; n†vrat aktu†ln°ho dne
         pop       dx                       ; n†vrat pozice okna
         inc       bl                       ; zvò®en° dne v màs°ci
         loop      kalall2                  ; zobrazen° dal®°ho dne
                                          ;* vymaz†n° zbylòch dnñ
         mov       cl,dh                    ; ©†dek okna
         add       cl,11                    ; maxim†ln° ©†dek
kalall6: push      dx
         call      kalkurz                  ; vòpoáet kurzoru dal®°ho dne
         cmp       dh,cl                    ; p©ekroáen max. ©†dek ?
         jae       kalall7                  ; p©ekroáen max. ©†dek
         push      cx
         mov       al,7
         call      outch1
         mov       al," "
         mov       cl,4
         call      outch                    ; vymaz†n° pozice
         pop       cx
         inc       bl                       ; zvò®en° á°taáe dnñ
         stc
kalall7: pop       dx
         jc        kalall6                  ; dal®° den

         call      mouseon                  ; zapnut° kurzoru my®i
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret


public   kalkurz
kalkurz:                                  ;* vòpoáet pozice kurzoru
                                            ; VSTUP:  BH=prvn° den v tòdnu
                                            ;         BL=den
                                            ;         DX=pozice okna
                                            ; VùSTUP: DX=pozice kurzoru
                                            ;         AL=den v tòdnu
         push      bx
         push      ax                       ; £schova AX
         mov       al,bh                    ; poá†teán° den v tòdnu
         add       al,bl                    ; poëadovanò den
         dec       al                       ; odeáten° prvn°ho dne
         cbw                                ; p©evod na slovo
         mov       bl,7                     ; poáet dnñ v tòdnu
         div       bl                       ; vòpoáet dne v tòdnu
         add       dh,al                    ; ©†dek
         add       dh,5                     ; p©iáten° poá†teán°ho offsetu
         mov       al,ah                    ; den v tòdnu
         push      ax                       ; £schova dne v tòdnu
         mov       bl,4                     ; poáet pozic na den
         mul       bl                       ; vòpoáet offsetu kurzoru
         add       dl,al                    ; vòpoáet pozice kurzoru
         add       dl,11                    ; p©iáten° poá†teán° pozice
         pop       bx                       ; den v tòdnu
         pop       ax                       ; n†vrat AX
         mov       al,bl                    ; den v tòdnu
         pop       bx
         ret


public   setdatum
setdatum:                                 ;* p©evod data na poáet dnñ
                                            ; VSTUP:  CX=rok
                                            ;         BH=màs°c
                                            ;         BL=den

         push      ax
         push      bx
         push      cx
         push      dx
         push      si

         xor       dx,dx                    ; nië®° slovo st©adaáe
         xor       si,si                    ; vy®®° slovo st©adaáe
         dec       bl
         dec       bh
         mov       dl,bl                    ; den
                                          ;* p©iáten° màs°cñ
setdat1: dec       bh                       ; sn°ëen° ukazatele màs°ce
         js        setdat2                  ; byly jië v®echny màs°ce
         call      mesicset                 ; nastaven° poátu dnñ màs°ce
         add       dx,ax                    ; p©iáten° poátu dnñ màs°ce
         adc       si,0                     ; p©enos do vy®®°ho slova
         jmp       short setdat1            ; dal®° màs°c
                                          ;* p©iáten° rokñ
setdat2: dec       cx                       ; sn°ëen° ukazatele rokñ
         js        setdat3                  ; byly jië v®echny roky
         call      rokset                   ; vòpoáet poátu dnñ v roce
         add       dx,ax                    ; p©iáten° poátu dnñ roku
         adc       si,0                     ; p©enos do vy®®°ho slova
         jmp       short setdat2            ; dal®° rok
setdat3:                                  ;* nastaven° poátu dnñ
         mov       word ptr ds:[aktden+2],si; aktu†ln° den - vy®®° slovo
         mov       word ptr ds:[aktden],dx  ; aktu†ln° den - nië®° slovo

         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret


public   getdatum
getdatum:                                 ;* p©evod poátu dnñ na datum
                                            ; VùSTUP: AL=den v tòdnu
                                            ;         AH=poáet dnñ v màs°ci
                                            ;         CX=rok
                                            ;         BH=màs°c
                                            ;         BL=den

         push      dx                       ; £schova DX
         push      si
         mov       dx,word ptr ds:[aktden]  ; aktu†ln° den
         mov       si,word ptr ds:[aktden+2] ; aktu†ln° den - vy®®° slovo
         xor       cx,cx                    ; poá†teán° rok 0
                                          ;* odeáten° stolet°
getdata: call      stoset                   ; vòpoáet poátu dnñ ve stolet°
         sub       dx,ax                    ; stolet° nalezeno ?
         sbb       si,0                     ; p©enos do vy®®°ho slova
         jc        getdatb                  ; stolet° nastaveno OK
         add       cx,100                   ; zvò®en° ukazatele roku o 100 let
         jmp       short getdata            ; p©evod dal®°ho roku
                                          ;* odeáten° rokñ
getdatb: add       dx,ax                    ; n†vrat poátu let ve stolet°
         adc       si,0                     ; p©enos do vy®®°ho slova
getdat0: call      rokset                   ; vòpoáet poátu dnñ v roce
         sub       dx,ax                    ; je rok nalezen ?
         sbb       si,0                     ; p©enos do vy®®°ho slova
         jc        getdat1                  ; rok je nastaven OK
         inc       cx                       ; zvò®en° ukazatele roku
         jmp       short getdat0            ; p©evod dal®°ho roku
                                          ;* odeáten° màs°cñ
getdat1: add       dx,ax                    ; n†vrat poátu dnñ v roce
         adc       si,0                     ; p©enos do vy®®°ho slova
         xor       bx,bx                    ; poá†teán° màs°c = leden
getdat2: call      mesicset                 ; nastaven° poátu dnñ màs°ce
         inc       bh                       ; zvò®en° ukazatele màs°ce
         sub       dx,ax                    ; je màs°c nalezen ?
         sbb       si,0                     ; p©enos do vy®®°ho slova
         jc        getdat3                  ; màs°c je nastaven OK
         jmp       short getdat2            ; p©evod dal®°ho màs°ce
                                          ;* vòpoáet poátu dnñ, korekce £dajñ
getdat3: add       dx,ax                    ; n†vrat poátu dnñ
         inc       dl                       ; den v màs°ci
         mov       bl,dl                    ; den v màs°ci
                                          ;* vòpoáet dne v tòdnu
         push      bx
         push      ax                       ; £schova poátu dnñ v màs°ci
         mov       dx,word ptr ds:[aktden+2]; aktu†ln° den - vy®®° slovo
         mov       ax,word ptr ds:[aktden]  ; aktu†ln° den - nië®° slovo
IFDEF    ANGL
         add       ax,4                     ; korekce pro spr†vnò den
ELSE
         add       ax,3                     ; korekce pro spr†vnò den
ENDIF
         adc       dx,0                     ; p©enos do vy®®°ho slova
         mov       bx,7                     ; poáet dnñ v tòdnu
         push      ax
         mov       ax,dx
         xor       dx,dx
         div       bx                       ; dàlen° vy®®°ho slova
         pop       ax
         div       bx                       ; vòpoáet dne v tòdnu
         mov       al,dl                    ; den v tòdnu
         pop       bx                       ; n†vrat poátu dnñ v màs°ci
         mov       ah,bl                    ; poáet dnñ v màs°ci
         pop       bx

         pop       si
         pop       dx
         mov       word ptr ds:[rozbdat],bx ; den a màs°c
         mov       word ptr ds:[rozbdat+2],cx ; rok

         ret


public   incden
incden:                                   ;* zvò®en° dne o 1
         push      ax
         mov       ax,1
         call      addden
         pop       ax
         ret

public   decden
decden:                                   ;* sn°ëen° dne o 1
         push      ax
         mov       ax,1
         call      subden
         pop       ax
         ret

public   addden0
addden0:                                  ;* zvò®en° dne o AL dnñ
         cbw

public   addden
addden:                                   ;* zvò®en° dne
                                            ; VSTUP: AX=poáet dnñ k p©iáten°

         add       word ptr ds:[aktden],ax  ; p©iáten° danÇho poátu dnñ
         adc       word ptr ds:[aktden+2],0
         jnc       addden1                  ; nen° p©eteáen°
         sub       word ptr ds:[aktden],ax  ; n†vrat poátu dnñ
         sbb       word ptr ds:[aktden+2],0
addden1: ret

public   subden0
subden0:                                  ;* sn°ëen° dne o AL dnñ
         cbw

public   subden
subden:                                   ;* sn°ëen° dne
                                            ; VSTUP: AX=poáet dnñ k odeáten°

         sub       word ptr ds:[aktden],ax  ; odeáten° danÇho poátu dnñ
         sbb       word ptr ds:[aktden+2],0
         jnc       subden1                  ; nen° p©eteáen°
         add       word ptr ds:[aktden],ax  ; n†vrat poátu dnñ
         adc       word ptr ds:[aktden+2],0
subden1: ret


public   mesicset
mesicset:                                 ;* nastaven° poátu dnñ v màs°ci
                                            ; VSTUP: BH=màs°c 0...
                                            ; VùSTUP: AX=poáet dnñ

         push      bx
         cmp       cx,1582                  ; je rok 1582 ?
         jne       mesicst1                 ; nen° rok 1582
         mov       ax,28                    ; 28 dnñ v prosinci
         cmp       bh,11                    ; je prosinec ?
         je        mesicst2                 ; je prosinec 1582
mesicst1:mov       bl,bh                    ; màs°c
         xor       bh,bh
         mov       al,ds:[bx+poctydnu]      ; poáet dnñ v màs°ci
         cbw                                ; poáet dnñ v màs°ci
         cmp       bl,1                     ; je to £nor ?
         jne       mesicst2                 ; nen° to £nor
         call      roktest                  ; test p©estupnosti roku
         jnc       mesicst2                 ; rok nen° p©estupnò
         inc       al                       ; poáet dnñ v £noru = 29
mesicst2:pop       bx
         ret


public   stoset
stoset:                                   ;* nastaven° poátu dnñ ve stolet°
                                            ; VSTUP: CX=rok (koná°c° 00)
                                            ; VùSTUP: AX=poáet dnñ

         push      bx
         push      dx
         xor       dx,dx                    ; DX <- 0
         mov       ax,cx                    ; rok
         mov       bx,100                   ; poáet rokñ ve stolet°
         div       bx                       ; vòpoáet stolet°
         cmp       ax,15                    ; je stolet° 15 ?
         jne       stoset0                  ; nen° stolet° 15
         mov       ax,25*366+75*365-3       ; zkr†cenÇ p©estupnÇ stolet°
         jmp       short stoset2
stoset0: cmp       cx,1600                  ; je p©ed rokem 1600 ?
         jb        stoset1                  ; je p©ed 1600 - p©estupnÇ vëdy
         test      ax,3                     ; je stolet° dàlitelnÇ 4 ?
         mov       ax,24*366+76*365         ; nep©estupnÇ stolet°
         jnz       stoset2                  ; stolet° nen° p©estupnÇ
stoset1: mov       ax,25*366+75*365         ; stolet° je p©estupnÇ
stoset2: pop       dx
         pop       bx
         ret


public   rokset
rokset:                                   ;* nastaven° poátu dnñ v roce
                                            ; VSTUP: CX=rok
                                            ; VùSTUP: AX=poáet dnñ

         mov       ax,365-3                 ; poáet dnñ v roce 1582
         cmp       cx,1582                  ; je rok 1582 ?
         je        rokset2                  ; je rok 1582
         mov       ax,365                   ; poáet dnñ v nep©estupnÇm roce
         call      roktest                  ; test p©estupnosti roku
         jnc       rokset2                  ; rok nen° p©estupnò
         inc       ax                       ; poáet dnñ = 366
rokset2: ret


public   roktest
roktest:                                  ;* test p©estupnosti roku
                                            ; VSTUP: CX=rok
                                            ; VùSTUP: CY=je p©estupnò rok

         push      ax
         push      bx
         push      dx
         test      cx,3                     ; je p©estupnò rok ?
         jnz       roktest2                 ; nen° p©estupnò rok
         cmp       cx,1600                  ; je p©ed rokem 1600 ?
         jb        roktest1                 ; je p©ed 1600 - p©estupnÇ vëdy
         mov       bx,100                   ; stolet°
         xor       dx,dx                    ; DX <- 0
         mov       ax,cx                    ; rok
         div       bx                       ; vòpoáet stolet°
         or        dx,dx                    ; je stolet° ?
         jnz       roktest1                 ; nen° stolet°
         test      ax,3                     ; je stolet° dàlitelnÇ 4 ?
         jnz       roktest2                 ; nen° dàlitelnÇ - nen° p©estupnÇ
roktest1:stc                                ; p©°znak p©estupnÇho roku
roktest2:pop       dx
         pop       bx
         pop       ax
         ret



endif


public   dekoddat
dekoddat:                                 ;* dek¢dov†n° data
                                            ; VSTUP: ES:DI=ukl†dac° adresa textu
                                            ;        CX=rok
                                            ;        DH=màs°c
                                            ;        DL=den

         push      ax
         push      bx
         push      cx
         push      dx
         push      si

         push      cx                       ; £schova roku
         push      dx                       ; £schova màs°ce
         xor       ax,ax
         mov       al,dl                    ; den
         xor       dx,dx
         call      deknum
         mov       ax," ."                  ; oddàlovac° teáka a mezera
         stosw
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
         mov       byte ptr es:[di],0       ; oznaáen° konce textu
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret



hlpsoub:                                  ;* sestaven° cesty k souboru DS:SI

         lea       di,[outbuf]              ; pracovn° buffer
         push      di
         push      si
         mov       si,offset pathhome       ; cesta k dom†c°mu adres†©i
         call      transtxt                 ; p©enesen° jmÇna cesty
         mov       al,"\"
         cmp       byte ptr es:[di-1],al    ; byl posledn° znak "\" ?
         je        hlpsoub1                 ; posledn° znak je jië "\"
         stosb                              ; oddàlovaá cesty a jmÇna programu
hlpsoub1:pop       si                       ; jmÇno souboru
         call      transtxt                 ; p©enesen° jmÇna
         pop       dx                       ; jmÇno souboru
         ret


hlpopen:                                  ;* otev©en° souboru
         mov       ax,3d00h                 ; funkce otev©en° souboru pro áten°
         int       21h                      ; otev©en° souboru pro áten°
         mov       bx,ax                    ; identifik†tor souboru
         ret


hlpmemor:                                 ;* uráen° volnÇ pamàti
                                            ; VùSTUP: AX=max. poáet bajtñ
                                            ;         CY=nedostatek pamàti

         mov       ax,ds:[editnum]          ; poáet bajtñ v pamàti
         add       ax,31                    ; zaokrouhlen°
         jnc       hlpmemr2                 ; nen° p©eteáen°
         mov       ax,1000h                 ; omezen° na maximum
         jmp       short hlpmmr22
hlpmemr2:mov       cl,4
         shr       ax,cl                    ; p©epoáet na odstavce
;         add       ax,2                     ; rezerva pro oddàlen°
hlpmmr22:add       ax,ds:[topseg]           ; segment pro uloëen° n†povàdy
         mov       ds:[hlpseg],ax           ; segment pro uloëen° n†povàdy
         mov       ax,ds:[segend]           ; segment konce pamàti
         sub       ax,2                     ; rezerva
         sub       ax,ds:[hlpseg]           ; voln† pamàü
         jc        hlpmemr3                 ; pamàü nedostaáuje
         cmp       ax,1000h                 ; je vàt®° neë 64 KB ?
         jb        hlpmemr4                 ; nen° vàt®° neë 64 KB
         mov       ax,0fffh                 ; omezen° na 64 KB
hlpmemr4:mov       cl,4
         shl       ax,cl                    ; voln† kapacita (v bajtech)
         clc                                ; p©°znak - pamàü OK
hlpmemr3:ret


hlpread:                                  ;* naáten° souboru do pamàti

         push      ds
         mov       cx,ax                    ; maxim†ln° dÇlka dat
         mov       ah,3fh
         mov       ds,ds:[hlpseg]           ; segment pro uloëen° dat
         xor       dx,dx                    ; offset adresy k uloëen°
         int       21h                      ; naáten° dat do pamàti
         pop       ds
         jc        hlpread2                 ; chyba p©i áten° souboru
         mov       ds:[hlpnum],ax           ; poáet bajtñ dat v pamàti
hlpread2:ret

hlpclose:                                 ;* uzav©en° souboru

         push      ax
         pushf
         mov       ah,3eh                   ; funkce uzav©en° souboru
         int       21h                      ; uzav©en° souboru
         popf
         pop       ax
         ret




hlpfndd:                                  ;* nalezen° data v textu
                                            ; VSTUP: DX=pozice na displeji
                                            ;        CL=max. ®°©ka textu
                                            ;        SI=poá†teán° pozice textu
                                            ; VùSTUP: CY=nen° aktu†ln° datum
                                            ;         SI=adresa dal®°ho ©†dku

         push      cx
         push      dx
         mov       al,7
         call      outch1                   ; nastaven° barvy
         mov       al," "                   ; mazac° mezera
         xor       ch,ch
         call      outch                    ; vymaz†n° textu
         pop       dx
         pop       cx

hlpfndd2:
         call      kalzos                   ; vypu®tàn° mezer
         jc        hlpfndd5                 ; je konec textu
         je        hlpfndd3                 ; je konec ©†dku
         call      kalchar                  ; naáten° dal®°ho znaku
         jc        hlpfndd5                 ; konec - datum nenalezeno
         dec       si                       ; n†vrat znaku
         cmp       al,";"                   ; je pozn†mka ?
         je        hlpfndd3                 ; je pozn†mka - dal®° ©†dek
         cmp       al,"'"                   ; je pozn†mka ?
         je        hlpfndd3                 ; je pozn†mka - dal®° ©†dek

         call      hlprozbd                 ; rozbor data
         jnc       hlpfndd4                 ; datum nalezeno
hlpfndd3:call      kalchar                  ; naáten° dal®°ho znaku
         jc        hlpfndd5                 ; konec textu
         cmp       al,10                    ; je LF ?
         jne       hlpfndd3                 ; nen° LF - dal®° znak
         jmp       short hlpfndd2           ; test dal®°ho ©†dku

hlpfndd4:
         call      kalzob                   ; zobrazen° textu
         clc
hlpfndd5:ret



public   kalzob
kalzob:                                   ;* zobrazen° ©†dku ze soub. DOSMAN.CAL
                                            ; VSTUP: SI=poá†teán° pozice ©†dku
                                            ;        DX=pozice na displeji
                                            ;        CL=max. ®°©ka textu

         push      cx
         push      dx
         call      kalzos                   ; vypustàn° poá†teán°ch oddàlovaáñ
         jc        kalzob9                  ; nen° jië dal®° znak - konec
         je        kalzob9                  ; je konec ©†dku LF - nen° text
         call      kalchar                  ; naáten° prvn°ho znaku textu
         xor       ch,ch
kalzob2:                                  ;* p©enos textu do bufferu
         mov       di,offset helpbuf        ; pracovn° buffer
         push      di
         push      cx
kalzob3: jcxz      kalzob5                  ; p©ekroáen poáet znakñ
         add       sp,4                     ; zru®en° dat v z†sobn°ku
         push      di                       ; mezi£schova konce textu
         push      cx
kalzob4: jcxz      kalzob5                  ; jsou jië v®echny znaky
         stosb                              ; uloëen° znaku do bufferu
         dec       cx                       ; sn°ëen° á°taáe znakñ
kalzob5: call      kalchar                  ; naáten° dal®°ho znaku
         jc        kalzob6                  ; konec souboru
         cmp       al,13                    ; je CR ?
         je        kalzob4                  ; je CR - nen° platnò znak
         cmp       al," "                   ; je mezera ?
         je        kalzob4                  ; je mezera - nen° platnò znak
         cmp       al,9                     ; je tabel†tor ?
         je        kalzob4                  ; je tabel†tor - nen° platnò znak
         cmp       al,10                    ; je LF (konec ©†dku) ?
         jne       kalzob3                  ; uloëen° platnÇho znaku
kalzob6: pop       cx
         pop       di                       ; konec textu v bufferu
         inc       di
         xor       ax,ax
         stosb                              ; oznaáen° konce textu
         shr       cx,1                     ; zbylò okraj textu
         add       dl,cl                    ; zvò®en° pozice textu (vyst©edàn°)
                                          ;* zobrazen° textu
         push      si
         mov       al,7
         call      outch1                   ; nastaven° barvy textu
         mov       si,offset helpbuf
kalzob7: lodsb                              ; znak k zobrazen°
         or        al,al                    ; je konec ?
         jz        kalzob8                  ; je konec textu
         call      outch10                  ; zobrazen° znaku
         jmp       short kalzob7            ; dal®° znak

kalzob8:
         pop       si
kalzob9: pop       dx
         pop       cx
         ret

                                          ;* vypustàn° oddàlovaáñ
                                            ; VSTUP: SI=ukazatel textu
                                            ; VùSTUP: CY=konec souboru
                                            ;         ZY=konec ©†dku

public   kalzos
kalzos:  call      kalchar                  ; naáten° dal®°ho znaku
         jc        kalzos2                  ; nen° jië dal®° znak - konec
         cmp       al,13                    ; je CR ?
         je        kalzos                   ; je CR - ignorov†n°
         cmp       al," "                   ; je mezera ?
         je        kalzos                   ; je mezera - ignorov†n°
         cmp       al,9                     ; je tabel†tor ?
         je        kalzos                   ; je tabel†tor - ignorov†n°
         dec       si                       ; n†vrat posledn°ho znaku
         cmp       al,10                    ; je konec ©†dku ?
         clc
kalzos2: ret



public   kalchar
kalchar:                                  ;* áten° znaku SI z textu
                                            ; VSTUP: SI=adresa znaku
                                            ; VùSTUP: AL=znak textu
                                            ;         CY=konec ©†dku
         push      ds
         cmp       si,cs:[hlpnum]           ; je jië dosaëeno konce textu ?
         jae       kalchar8                 ; je jië konec textu
         mov       ds,cs:[hlpseg]           ; segment s textem n†povàdy
         lodsb                              ; naáten° dal®°ho znaku
         or        al,al                    ; je konec souboru ?
         jnz       kalchar7                 ; nen° konec ©†dku
         dec       si                       ; n†vrat pozice
kalchar8:xor       al,al                    ; n†hradn° znak - konec textu
         stc                                ; p©°znak konce ©†dku
kalchar7:pop       ds
         ret


public   hlprozbd
hlprozbd:                                 ;* rozbor data z textu SI
                                            ; VSTUP: SI=ukazatel textu
                                            ; VùSTUP: CY=nen° aktu†ln° datum

         mov       ax,word ptr ds:[rozbdat] ; den a màs°c
         mov       word ptr ds:[rozbdat0],ax ; pracovn° den a màs°c
         mov       ax,word ptr ds:[rozbdat+2]; rok
         mov       word ptr ds:[rozbdat0+2],ax ; pracovn° rok

         push      ds                       ; £schova DS
         mov       ds,ds:[hlpseg]           ; segment s textem

                                          ;* prvn° á°slo (den)
         call      rozbnum                  ; rozbor prvn°ho á°sla
         jc        kalrzbd2                 ; á°slo nen° zad†no
         mov       byte ptr cs:[rozbdat0],al; uloëen° dne
kalrzbd2:call      rozbodd                  ; test oddàlovaáe
         jc        kalrzbd6                 ; je konec zad†n°
                                          ;* druhÇ á°slo (màs°c)
         call      rozbnum                  ; rozbor druhÇho á°sla
         jc        kalrzbd3                 ; á°slo nen° zad†no
         mov       byte ptr cs:[rozbdat0+1],al ; uloëen° màs°ce
kalrzbd3:call      rozbodd                  ; test oddàlovaáe
         jc        kalrzbd6                 ; je konec zad†n°
                                          ;* t©et° á°slo (rok)
         call      rozbnum                  ; rozbor t©et°ho á°sla
         jc        kalrzbd6                 ; á°slo nen° zad†no
         mov       word ptr cs:[rozbdat0+2],ax ; uloëen° t©et°ho á°sla
kalrzbd6:
         pop       ds

         mov       ax,word ptr ds:[rozbdat] ; den a màs°c
         cmp       word ptr ds:[rozbdat0],ax ; pracovn° den a màs°c
         stc
         jne       kalrzbd7                 ; nen° shoda
         mov       ax,word ptr ds:[rozbdat+2]; rok
         cmp       word ptr ds:[rozbdat0+2],ax ; pracovn° rok
         je        kalrzbd7
         stc                                ; nen° shoda
kalrzbd7:
         ret

; -----------------------------------------------------------------------------
;                                Kalkul†tor
; -----------------------------------------------------------------------------

public   kalkulator
kalkulator:
ifdef    upver

         push      cs
         pop       ds
         push      cs
         pop       es
kalkul2:
         call      setvysl                  ; dek¢dov†n° textu vòsledku
         mov       si,offset bufcalc        ; buffer kalkul†toru
         mov       word ptr ds:[si],132     ; velikost bufferu
         mov       byte ptr ds:[bufcalc2],1 ; poáet p©edvoleb = 1
         mov       word ptr ds:[bufcalc3],offset helpbuf ; text á°sla
         mov       di,offset caltxt1        ; nadpis okna kalkul†toru
         call      select                   ; zad†n° matematickÇho vòrazu
         call      kalend8                  ; n†vrat okna
         jc        kalkul9

         push      si                       ; £schova zaá†tku textu
         xor       di,di                    ; priorita operac° 0
         call      calc                     ; vòpoáet zadanÇho vòrazu DS:SI
         mov       cx,ax                    ; nië®° slovo vòsledku
         pop       bx                       ; n†vrat zaá†tku textu
         jc        kalkul4                  ; chyba

         call      calspc                   ; vypu®tàn° zbytku textu
         jnc       kalkul4                  ; je je®tà nàjakò text - chyba

         mov       word ptr ds:[vysledek],cx ; nië®° slovo
         mov       word ptr ds:[vysledek+2],dx ; vy®®° slovo
         jmp       short kalkulator         ; dal®° vòraz

kalkul4: mov       ax,si                    ; pozice chyby
         mov       dx,si                    ; adresa chyby
         mov       di,offset helpbuf
         mov       si,offset caltxt2        ; £vodn° text hl†®en°
         call      transtxt                 ; p©enos £vodn°ho textu
         sub       ax,15                    ; minim†ln° zaá†tek textu
         cmp       ax,bx                    ; podteáen° ?
         jae       kalkul5                  ; nen° podteáen°
         mov       ax,bx                    ; omezen° na zaá†tek textu
kalkul5: mov       si,ax                    ; zaá†tek textu
         mov       cx,30                    ; maxim†ln° dÇlka textu
kalkul6: cmp       dx,si
         jne       kalkul8

         mov       al,ds:[col10]
         or        al,80h
         mov       ds:[col20],al
         mov       al,20
         stosb
         lodsb
         dec       si
         or        al,al
         jz        kalkul63
         inc       si
         cmp       al," "
         jne       kalkul62
kalkul63:mov       al,"?"
kalkul62:stosb
         mov       al,7
         stosb
         cmp       byte ptr ds:[si],0
         jz        kalkul7
         jmp       short kalkul82

kalkul8: lodsb
         or        al,al
         jz        kalkul7
         stosb
kalkul82:loop      kalkul6
kalkul7: xor       al,al
         stosb
         mov       di,offset helpbuf
         mov       si,offset txtchyb1
         xor       al,al
         call      volbyh
         call      kalend8                  ; n†vrat okna
         jmp       kalkulator

kalkul9:

endif
         ret


ifdef    upver

public   setvysl
setvysl:                                  ;* dek¢dov†n° vòsledku

         push      si
         mov       si,word ptr ds:[baze]    ; á°seln† soustava
         and       si,0ffh                  ; maska soustavy

         mov       di,offset helpbuf        ; buffer k uloëen° textu
         mov       al,"~"
         cmp       si,36
         je        setvysl1
         mov       al,"%"
         cmp       si,2
         je        setvysl1
         mov       al,"$"
         cmp       si,16
         je        setvysl1
         mov       al,"@"
         cmp       si,8
         jne       setvysl2
setvysl1:stosb                              ; uloëen° znaku prefixu
setvysl2:
         mov       ax,word ptr ds:[vysledek] ; nië®° slovo vòsledku
         mov       dx,word ptr ds:[vysledek+2]; vy®®° slovo vòsledku
         or        dx,dx                    ; je z†pornÇ á°slo ?
         jns       setvysla                 ; je kladnÇ á°slo
         mov       byte ptr ds:[di],"-"     ; znamÇnko
         inc       di
         call      calnegda                 ; negace á°sla DX:AX
setvysla:xor       cx,cx                    ; á°taá znakñ
setvysl3:mov       bx,ax                    ; £schova nië®°ho slova
         or        ax,dx                    ; je jië á°slo = 0 ?
         jz        setvysl5                 ; jsou jië v®echny á°slice
         mov       ax,dx                    ; vy®®° slovo
         xor       dx,dx                    ; DX <- 0
         div       si                       ; vydàlen° vy®®°ho slova
         xchg      bx,ax                    ; AX<-nië®° slovo, BX<-vy®®° slovo
         div       si                       ; vydàlen° nië®°ho slova
         cmp       dl,10
         jb        setvysl4
         add       dl,7                     ; korekce na p°smeno
setvysl4:add       dx,"0"                   ; korekce na znak ASCII
         push      dx                       ; £schova znaku do z†sobn°ku
         inc       cx                       ; zvò®en° á°taáe znakñ
         mov       dx,bx                    ; n†vrat vy®®°ho slova á°sla
         jmp       short setvysl3           ; dal®° á°slice

setvysl5:
setvysl9:mov       word ptr ds:[di],"0"     ; nen° ë†dnò znak v bufferu
         jcxz      setvysl7                 ; v z†sobn°ku nen° ë†dnò znak
setvysl6:pop       ax                       ; n†vrat znaku ze z†sobn°ku
         stosb                              ; uloëen° znaku do bufferu
         loop      setvysl6                 ; n†vrat dal®°ho znaku
         xor       al,al
         stosb                              ; oznaáen° konce textu
setvysl7:
         pop       si
         ret




public   calc
calc:                                     ;* vòpoáet vòrazu DS:SI (DX:AX vòsl.)
                                            ; priorita DI: 8: + - un†rn°
                                            ;              7: ^ (mocnina)
                                            ;              6: * /
                                            ;              5: + - bin†rn°
                                            ;              4: ! (NOT)
                                            ;              3: & (AND)
                                            ;              2: | (OR)


         push      bx
         push      cx
         xor       bx,bx
         xor       cx,cx
                                          ;* vòpoáet prvn°ho operandu
calc0:   call      calspc                   ; vypustàn° mezer
         call      calcch                   ; áten° znaku z bufferu
         cmc
         jnc       calc62                   ; konec textu
         cmp       al,"+"                   ; un†rn° plus ?
         je        calc0                    ; un†rn° plus - ignoruje se

                                          ;* un†rn° m°nus
         cmp       al,"-"                   ; je un†rn° m°nus ?
         jne       calc11                   ; nen° un†rn° m°nus
         push      di                       ; £schova priority
         mov       di,9                     ; priorita 9 (jenom á°slo)
         call      calc                     ; vòpoáet prvn°ho operandu
         pop       di
         jc        calc12                   ; chyba zad†n°
         mov       bx,dx
         mov       cx,ax
         call      calneg                   ; negace á°sla BX:CX
         jmp       short calc6              ; vyhodnocen° oper†toru

calc11:                                   ;* un†rn° NOT
         cmp       al,"!"                   ; je un†rn° NOT ?
         jne       calc1                    ; nen° un†rn° NOT
         push      di                       ; £schova priority
         mov       di,5                     ; priorita 5 (bin†rn° + a -)
         call      calc                     ; vòpoáet prvn°ho operandu
         pop       di
calc12:  jc        calc14                   ; chyba zad†n°
         mov       bx,dx
         mov       cx,ax
         not       bx
         not       cx
         jmp       short calc6              ; vyhodnocen° oper†toru

calc1:                                    ;* otev°rac° z†vorka
         cmp       al,"("                   ; otev©en° z†vorky ?
         jne       calc3                    ; nen° otev©en° z†vorky
         push      di                       ; £schova priority
         xor       di,di                    ; nejnië®° priorita
         call      calc                     ; vòpoáet vòrazu v z†vorce
         pop       di                       ; n†vrat priority
         mov       bx,dx
         mov       cx,ax
calc14:  jc        calc16                   ; chyba zad†n°
         call      calspc                   ; vypustàn° mezer
         call      calcch                   ; áten° znaku z bufferu
         jc        calc16                   ; chyba zad†n° - chyb° z†vorka
         cmp       al,")"
         stc
         jne       calc16                   ; chyb° z†vorka - chyba
         jmp       short calc6              ; vyhodnocen° oper†toru

calc3:   dec       si                       ; n†vrat prvn°ho znaku
         call      calnum                   ; vòpoáet á°sla BX:CX
calc16:  jc        calc9                    ; chyba zad†n°


                                          ;* prvn° operand je zadanò

calc6:                                    ;* vyhodnocen° oper†toru
         call      calspc                   ; vypustàn° mezer
         call      calcch                   ; áten° znaku z bufferu
         cmc
calc62:  jnc       calc9                    ; nen° dal®° znak

                                          ;* rozvàtven° podle priority
         cmp       di,8                     ; un†rn° + - ?
         jae       calc8                    ; pouze 1 operand
         cmp       di,7                     ; mocnina ?
         je        calc77                   ; vòpoáet mocniny
         cmp       di,6                     ; n†sobek, pod°l ?
         je        calc76                   ; n†sobek, pod°l
         cmp       di,5                     ; bin†rn° + - ?
         je        calc75                   ; bin†rn° + -
         cmp       di,4                     ; NOT ?
         je        calc74
         cmp       di,3                     ; AND
         je        calc73

                                          ;* logickò souáet
         cmp       al,"|"
         jne       calc73
         call      logor
         jmp       short calc80


calc73:                                   ;* logickò souáin
         cmp       al,"&"
         jne       calc74
         call      logand
         jmp       short calc80


calc74:

calc75:                                   ;* souáet
         cmp       al,"+"
         jne       calc752                  ; nen° souáet
         call      soucet
         jmp       short calc80

calc752:                                  ;* rozd°l
         cmp       al,"-"
         jne       calc76
         call      rozdil
         jmp       short calc80

calc76:                                   ;* n†sobek
         cmp       al,"*"                   ; je n†sobek ?
         jne       calc762                  ; nen° n†sobek
         call      nasobek                  ; vòpoáet n†sobku
         jmp       short calc80

calc762:                                  ;* pod°l
         cmp       al,":"
         je        calc764
         cmp       al,"/"
         jne       calc77                   ; nen° pod°l
calc764: call      podil
         jmp       short calc80

calc77:                                   ;* mocnina
         cmp       al,"^"                   ; je mocnina ?
         clc                                ; p©°znak - OK
         jne       calc8                    ; nezn†mò vòraz - chyba
         call      mocnina                  ; vòpoáet mocniny
calc80:  jnc       calc6                    ; vyhodnocen° dal®°ho vòrazu
         jmp       short calc9

calc8:   dec       si                       ; n†vrat znaku
         clc

calc9:   mov       ax,cx                    ; nië®° slovo vòsledku
         mov       dx,bx                    ; vy®®° slovo vòsledku
         pop       cx
         pop       bx
         ret




public   logor
logor:                                    ;* logickò souáet
         push      di
         mov       di,3                     ; priorita 2
         call      calc                     ; vyhodnocen° operandu DX:AX
         pop       di
         jc        logor2                   ; chyba zad†n° operandu
         call      calor                    ; log. souáet operandñ
logor2:  ret


public   logand
logand:                                    ;* logickò souáin
         push      di
         mov       di,4                     ; priorita 4 (NOT)
         call      calc                     ; vyhodnocen° operandu DX:AX
         pop       di
         jc        logand2                  ; chyba zad†n° operandu
         call      caland                   ; log. souáin operandñ
logand2: ret



public   soucet
soucet:                                   ;* vòpoáet souátu
         push      di
         mov       di,6                     ; priorita 6 (* a /)
         call      calc                     ; vyhodnocen° operandu DX:AX
         pop       di
         jc        soucet2                  ; chyba zad†n° operandu
         call      caladd                   ; souáet operandñ
soucet2: ret


public   rozdil
rozdil:                                   ;* vòpoáet rozd°lu

         push      di
         mov       di,6                     ; priorita 6 (* a /)
         call      calc                     ; vyhodnocen° operandu DX:AX
         pop       di
         jc        rozdil2                  ; chyba zad†n° operandu
         call      calsub                   ; rozd°l operandñ
rozdil2: ret


public   nasobek
nasobek:                                  ;* vòpoáet n†sobku
         push      di
         mov       di,7                     ; priorita 7 (mocnina)
         call      calc                     ; vyhodnocen° operandu DX:AX
         pop       di
         jc        nasobek2                 ; chyba zad†n° operandu
         call      calmul                   ; n†sobek operandñ
nasobek2:ret


public   podil
podil:                                    ;* vòpoáet rozd°lu

         push      di
         mov       di,7                     ; priorita 7 (mocnina)
         call      calc                     ; vyhodnocen° operandu DX:AX
         pop       di
         jc        podil2                   ; chyba zad†n° operandu
         call      caldiv                   ; dàlen° operandñ
podil2:  ret


public   mocnina
mocnina:                                  ;* mocnina á°sla

         push      di
         mov       di,8                     ; priorita 8 (un†rn° + a -)
         call      calc                     ; vyhodnocen° operandu DX:AX
         pop       di
         jc        mocnina2                 ; chyba zad†n° operandu
         call      calmoc                   ; umocnàn° operandñ
mocnina2:ret



public   calmoc
calmoc:                                   ;* umocnàn° á°sla BX:CX á°slem DX:AX

                                          ;* test na umoc§ov†n° z†pornòm á°slem
         or        dx,dx                    ; je z†pornÇ á°slo ?
         jns       calmoc0                  ; nen° z†pornÇ á°slo
         xor       bx,bx                    ; vòsledek 0
         xor       cx,cx
         jmp       short calmoc6            ; konec operace
                                          ;* test na umoc§ov†n° nulou
calmoc0: jnz       calmoc1                  ; mocnitel nen° 0
         or        ax,ax
         jnz       calmoc1
         xor       bx,bx
         mov       cx,1                     ; vòsledkem je 1
                                          ;* test na umoc§ov†n° á°sla 1
calmoc1: or        bx,bx
         jnz       calmoc2                  ; nemocn° se á°slo 1
         jcxz      calmoc6                  ; umoc§uje se á°slo 0
         cmp       cx,1                     ; mocn° se á°slo 1 ?
         je        calmoc6                  ; mocn° se á°slo 1
                                          ;* umocnàn° á°sla BX:CX á°slem DX:AX
calmoc2: or        dx,dx                    ; mocn° se velkòm á°slem ?
         jnz       calmoc5                  ; je p©eteáen° operace
         cmp       ax,32                    ; maxim†ln° mocnitel 32
         ja        calmoc5                  ; velkò mocnitel - chyba p©eteáen°
         push      ax
         push      dx
         push      si
         mov       si,ax                    ; á°taá mocnin
         mov       ax,cx
         mov       dx,bx
calmoc3: dec       si
         jz        calmoc4
         call      calmul                   ; vyn†soben° á°sla
         jnc       calmoc3                  ; operace OK
calmoc4: pop       si
         pop       dx
         pop       ax
         ret

calmoc5: stc                                ; p©°znak chyby
calmoc6: ret



public   calor
calor:                                    ;* operace OR mezi BX:CX a DX:AX
         or        cx,ax
         or        bx,dx
         ret

public   caland
caland:                                   ;* operace AND mezi BX:CX a DX:AX
         and       cx,ax
         and       bx,dx
         ret


public   caladd
caladd:                                   ;* p©iáten° á°sla DX:AX k á°slu BX:CX
         add       cx,ax
         adc       bx,dx
         clc
         jno       caladd2                  ; nen° p©eteáen°
         stc                                ; p©°znak p©eteáen°
caladd2: ret


public   calsub
calsub:                                   ;* odeáten° á°sla DX:AX od á°sla BX:CX
         sub       cx,ax
         sbb       bx,dx
         clc
         jno       calsub2
         stc                                ; p©°znak p©eteáen°
calsub2: ret






public   absbxcx
absbxcx:                                  ;* absolutn° hodnota BX:CX
         or        bx,bx                    ; je to z†pornÇ á°slo ?
         js        calneg                   ; negace á°sla
absbxcx1:ret


public   absdxax
absdxax:                                  ;* absolutn° hodnota DX:AX
         or        dx,dx                    ; je to z†pornÇ á°slo ?
         jns       absbxcx1                 ; nen° to z†pornÇ á°slo

public   calnegda
calnegda:                                 ;* negace á°sla DX:AX
         not       ax
         not       dx
         add       ax,1
         adc       dx,0
         clc
         ret



public   calmul
calmul:                                   ;* vyn†soben° á°sla BX:CX á°slem DX:AX
         push      dx
         xor       dx,bx                    ; XOR znamÇnkovòch bitñ operandñ
         pop       dx
         jns       calmul01                 ; vòsledek je kladnò
                                          ;* vòsledek je z†pornò
         call      calmul01                 ; vyn†soben° bez znamÇnka
         jc        calneg2                  ; chyba operace

public   calneg
calneg:                                   ;* negace á°sla BX:CX
         not       cx
         not       bx
         add       cx,1
         adc       bx,0
         clc
calneg2: ret


calmul01:                                 ;* vyn†soben° absolutn°ch hodnot
         call      absbxcx                  ; absolutn° hodnota BX:CX
         call      absdxax                  ; absolutn° hodnota DX:AX
         call      calmul0                  ; n†soben° á°sla BX:CX á°slem DX:AX
         ret


calmul0:                                  ;* vyn†soben° á°sel bez znamÇnka
         push      ax
         push      dx
         push      si                       ; nië®° slovo st©adaáe mezivòsledku
         push      di                       ; vy®®° slovo st©adaáe mezivòsledku
                                          ;* prvn° mezisouáet AX * CX
         push      dx
         push      ax
         mul       cx                       ; AX * CX
         mov       si,ax                    ; nië®° slovo prvn°ho n†sobku
         mov       di,dx                    ; vy®®° slovo prvn°ho n†sobku
         pop       ax
                                          ;* druhò mezisouáet AX * BX
         mul       bx                       ; AX * BX
         add       di,ax                    ; vy®®° slovo
         adc       dx,0                     ; p©enos do vy®®°ho slova
         pop       dx
         jc        calmul3                  ; p©eteáen° vòsledku
         jnz       calmul3                  ; p©eteáen° vòsledku
         or        di,di                    ; je p©eteáen° mezivòsledku ?
         js        calmul3                  ; je p©eteáen° mezivòsledku
                                          ;* t©et° mezisouáet DX * CX
         mov       ax,dx
         push      ax                       ; £schova DX
         mul       cx                       ; DX * CX
         add       di,ax
         adc       dx,0                     ; p©enos do vy®®°ho slova
         pop       ax
         jc        calmul3                  ; p©eteáen° vòsledku
         jnz       calmul3                  ; p©eteáen° vòsledku
         or        di,di                    ; je p©eteáen° mezivòsledku ?
         js        calmul3                  ; je p©eteáen° mezivòsledku
                                          ;* átvrtò mezisouáet DX * BX
         mul       bx                       ; DX * BX
         or        ax,ax
         jnz       calmul3                  ; p©eteáen° vòsledku
         or        dx,dx
         jz        calmul4                  ; vòsledek OK
calmul3: stc                                ; p©°znak chyby (p©eteáen°)
calmul4: mov       cx,si                    ; nië®° slovo vòsledku
         mov       bx,di                    ; vy®®° slovo vòsledku
         pop       di
         pop       si
         pop       dx
         pop       ax
         ret




public   caldiv
caldiv:                                   ;* vydàlen° á°sla DX:AX á°slem BX:CX

         push      dx
         xor       dx,bx                    ; XOR znamÇnkovòch bitñ operandñ
         pop       dx
         jns       caldiv01                 ; vòsledek je kladnò
                                          ;* vòsledek je z†pornò
         call      caldiv01                 ; vydàlen° bez znamÇnka
         jc        caldiv03                 ; p©eteáen° operace
         jmp       calneg                   ; negace vòsledku


caldiv01:                                 ;* vydàlen° absolutn°ch hodnot
         call      absbxcx                  ; absolutn° hodnota BX:CX
         call      absdxax                  ; absolutn° hodnota DX:AX
         call      caldiv0                  ; n†soben° á°sla BX:CX á°slem DX:AX
caldiv03:ret



caldiv0:                                  ;* vydàlen° kladnòch á°sel BX:CX/DX:AX
         xchg      ax,cx
         xchg      dx,bx

         push      si
         or        bx,bx
         jnz       caldiv2
         or        cx,cx
         stc
         jz        caldiv9                  ; chyba - dàlen° 0

                                          ;* dàlen° á°slem CX
         mov       si,ax                    ; nië®° slovo
         mov       ax,dx
         xor       dx,dx
         div       cx                       ; dàlen° vy®®°ho slova
         xchg      ax,si                    ; ni®®° slovo
         div       cx                       ; dàlen° nië®°ho slova
         xchg      dx,si                    ; n†vrat vy®®°ho slova
         clc                                ; p©°znak - operace OK
         jmp       short caldiv9


caldiv2:                                  ;* dàlen° á°slem BX:CX
         cmp       dx,bx
         jne       caldiv3
         cmp       ax,cx
caldiv3: jb        caldiv8                  ; dàl° se vàt®°m á°slem

         xor       si,si                    ; st©adaá á°sla
                                          ;* dàlen° odeá°t†n°m
caldiv4: inc       si
         sub       ax,cx
         sbb       dx,bx
         jnc       caldiv4
         dec       si
         mov       ax,si
         jmp       short caldiv7

caldiv8:
         xor       ax,ax
caldiv7: xor       dx,dx

caldiv9: pop       si
         xchg      ax,cx
         xchg      dx,bx
         ret


public   calnum
calnum:                                   ;* áten° á°sla z bufferu
                                            ; VùSTUP: BX:CX=á°slo
                                            ;         CY=nen° á°slo

         push      dx
         push      ax
         xor       cx,cx                    ; CX <- 0 nië®° slovo á°sla
         xor       bx,bx                    ; BX <- 0 vy®®° slovo á°sla
         call      calspc                   ; vypustàn° mezer z textu
         call      calnm                    ; naáten° prvn° á°slice
         jc        calnum9                  ; nen° á°slo
calnum1: xor       ah,ah                    ; AH <- 0
         push      ax                       ; £schova naátenÇho á°sla
         xor       dx,dx                    ; DX <- 0
         mov       al,ds:[baze]             ; á°seln† soustava
         call      calmul                   ; vyn†soben° BX:CX á°slem DX:AX
         pop       ax                       ; n†vrat á°sla
         jc        calnum9                  ; p©eteáen° á°sla
         call      caladd                   ; p©iáten° á°sla DX:AX k BX:CX
         jc        calnum9                  ; p©eteáen°
         call      calnm                    ; naáten° dal®° á°slice
         jnc       calnum1                  ; je dal®° á°slice
         clc                                ; p©°znak operace OK
calnum9: pop       ax
         pop       dx
         ret


public   calnm
calnm:                                    ;* áten° á°slice z bufferu
         call      calcch                   ; áten° znaku z bufferu
         jc        calnm3                   ; nen° dal®° znak
         sub       al,"0"
         jc        calnm2                   ; nen° á°slice
         cmp       al,9
         jbe       calnm1                   ; je á°slice
         sub       al,7                     ; korekce znakñ ASCII
         cmp       al,10
         jb        calnm2                   ; nen° platnò znak
calnm1:  cmp       al,ds:[baze]             ; je povolenò rozsah á°sla ?
         cmc
         jnc       calnm3                   ; je platn† á°slice
calnm2:  dec       si                       ; n†vrat znaku
calnm3:  ret


public   calspc
calspc:                                   ;* vypu®tàn° mezer z textu
         call      calcch
         jc        calspc2
         cmp       al," "
         je        calspc
         dec       si
calspc2: ret




public   calcch

calcch0: mov       byte ptr ds:[baze],ah    ; nastaven° novÇ á°selnÇ soustavy

calcch:                                   ;* áten° znaku z bufferu
         cmp       byte ptr ds:[si],0       ; je konec textu ?
         stc
         je        calcch2                  ; je konec textu
         lodsb                              ; naáten° znaku
         cmp       al,"a"
         jb        calcch1                  ; nen° malÇ p°smeno
         cmp       al,"z"
         ja        calcch1                  ; nen° malÇ p°smeno
         sub       al,32                    ; korekce na velkÇ p°smeno
                                          ;* test p©ep°naáe á°selnÇ soustavy
calcch1: mov       ah,10                    ; dekadick† soustava
         cmp       al,"#"                   ; dekadick† soustava
         je        calcch0                  ; je dekadick† soustava
         mov       ah,2                     ; bin†rn° soustava
         cmp       al,"%"                   ; je bin†rn° soustava ?
         je        calcch0                  ; je bin†rn° soustava
         mov       ah,16                    ; hexadecim†ln° soustava
         cmp       al,"$"                   ; je hexadecim†ln° soustava ?
         je        calcch0                  ; je hexadecim†ln° soustava
         mov       ah,8                     ; oktalov† soustava
         cmp       al,"@"                   ; je oktalov† soustava ?
         je        calcch0                  ; je oktalov† soustava
         mov       ah,36                    ; 36-znakov† soustava
         cmp       al,"~"                   ; 36-znakov† soustava ?
         je        calcch0                  ; je 36-znakov† soustava
         clc                                ; p©°znak - znak OK
calcch2: ret

endif


code     ends

         end

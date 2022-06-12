
; modul DMUSE1.ASM 

; *****************************************************************************
;
;                    
;
; *****************************************************************************


extrn    editnum:word,editseg:byte,darkcit:word
extrn    editmax:word,topseged:word,segend:word,topseg:word,seznseg:word
extrn    seznseg0:byte,bufwin:byte,bufwin2:byte
extrn    parnum:byte,citdek:byte,citnum:byte
extrn    upperkam:byte,upperlat:byte,prevcs:byte,config:byte
extrn    textvy11:byte,textvy12:byte,displ:byte,flags:byte,extent:byte
extrn    tabl:byte,tabr:byte,col1:byte,color:byte,mousedat:byte,citmouse:byte
extrn    edikey:word,keystat:byte,keyinp:byte,mousepoz:word,insmouse:byte
extrn    aktpage:byte,adrvram:dword,selbuf:byte,numsrc:byte,tabhlp0:word
extrn    txthlped:word,endline:near,conf2:byte
extrn    conf6:byte,windret:near,displw:byte,windretx:near,usesedit:near
extrn    palon:byte,paloff:byte,dark:word,vyzvy:near,ukazkey:dword
extrn    verze:word,rerdir:near,test1file:near,srcins0:near,parbreak:word
extrn    usesedit:near,getkurz:near,windret:near,storekur:near,storfile:near
extrn    settabf:near,window:near,aktdisk:near,aktfile:near,space:near
extrn    directory:near,endline:near,delpolf:near,col7:byte,outbuf:byte
extrn    srcins:near,pathhome:byte,parrez:byte
extrn    rozbnam:byte,bufcopy:byte,bufcop1:byte,bufcop2:byte,bufcop3:word
extrn    bufcop4:word,soucins:near,outbuf3:byte,flagsc:byte,bufnadp:byte
extrn    txtvar:byte,errdir1:byte,errdir2:byte,errdel2:byte,delvolb:byte
extrn    textvy2:byte,txtadr:byte,errdel1:byte,volbyh:near
extrn    transuk:dword,blokuk:dword,poziceuk:byte,delkauk:byte
extrn    hledpol0:near,hledpol:near,segvram:word
extrn    errcop1:byte,zobrchyb:near,rozbflg:byte,maxdbuf:word
extrn    xpush:near,xpop:near,zacrol:word,kurrol:word,delrol:byte
extrn    zobrfile:near,files:near,comlin:byte,kurzlin:near,obrlin:near
extrn    normat:byte,kurzon:near,kurzoff:near,radeknul:near,aktkurz:word
extrn    all:byte,errxc1:byte,errxc2:byte,erroper:byte,nadadr:byte
extrn    copyfk:near,txtcop5:byte,txtcop6:byte,testex:near,topret:near
extrn    msgcek:near,getoper:near,txtmov5:byte,delfk:near
extrn    errdr1:byte,errdr2:byte,storekall:near,prodldem:near
extrn    conf7:byte,storecnf:near,soubhis:byte,zachis:byte,konhis:byte

code     segment   public
         assume    cs:code,ds:code


; -----------------------------------------------------------------------------

public   ulozhist                         ;* uloëen° historie
ulozhist:

ifndef   demo
ifdef    upver

         or        byte ptr ds:[parrez],0ch ; ignor. p©eru®. i chyby
         mov       word ptr ds:[parbreak],0
         test      byte ptr ds:[conf7],2    ; m† se uschovat historie ?
         jz        ulozhst1                 ; neuchov†v† se historie
;         call      storecnf                 ; uloëen° konfigurace
         mov       si,offset soubhis
         mov       di,offset outbuf
         call      sethome                  ; sestaven° cesty k souboru
         mov       ah,3ch
         xor       cx,cx                    ; atributy - norm†ln° soubor
         int       21h                      ; vytvo©en° souboru
         jc        ulozhst1                 ; chyba vytvo©en° souboru
         mov       bx,ax                    ; identifik†tor souboru
         mov       ah,40h
         mov       cx,offset konhis
         mov       dx,offset zachis         ; zaá†tek historie
         sub       cx,dx                    ; dÇlka historie
         int       21h                      ; z†pis historie do souboru
         mov       ah,3eh
         int       21h                      ; uzav©en° souboru

endif
endif

                                          ;* inicializace registrñ
ulozhst1:ret

; -----------------------------------------------------------------------------
public   modiscr
modiscr:                                    ; modifikace oken pomoc° SCROLL LOCK

         pushf
         call      testscr                  ; je aktivn° funkce SCROLL LOCK ?
         jnz       modiscr0                 ; SCROLL LOCK je aktivn°
modiscrx:popf
         ret

modiscr0:
ifdef    upver
         call      testaktw                 ; je okno aktivn° ?
         jc        modiscrx                 ; okno nen° aktivn°
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

         or        byte ptr ds:[conf6],4    ; p©°znak funkce SCROLL LOCK

         call      kurzout                  ; vypnut° kurzoru
         call      windret                  ; novÇ zobrazen° oken

modiscr1:call      testscr                  ; je p©esmykaá SCROLL LOCK uvolnàn ?
         jz        modiscr9                 ; p©esmykaá SCROLL LOCK je uvolnàn
         call      testkey                  ; test, zda je kl†vesa z kl†vesnice
         jz        modiscr1                 ; nen° kl†vesa z kl†vesnice

                                          ;* oprava konce okna
         call      getendl                  ; poskytnut° max. ©†dku konce okna
         inc       dh
         cmp       dh,ds:[displw]           ; je za maxim†ln°m ©†dkem ?
         jae       modiscr5                 ; je povolenò konec okna
         mov       ds:[displw],dh           ; omezen° na maxim†ln° ©†dek
modiscr5:
                                          ;* je kl†vesa z kl†vesnice
         call      inpkey                   ; vstup znaku z kl†vesnice
         call      flushkey                 ; vypr†zdnàn° kl†vesnice
                                          ;* kurzor nahoru
         cmp       ah,48h                   ; je kurzor nahoru ?
         jne       modiscr4                 ; nen° kurzor nahoru
         cmp       byte ptr ds:[displw],8   ; je jië ©†dek 8 ?
         jbe       modiscr1                 ; je jië ©†dek 8
         dec       byte ptr ds:[displw]     ; sn°ëen° ©†dku okna
         jmp       short modiscr8           ; p©ekreslen° okna
                                          ;* kurzor dolñ
modiscr4:cmp       ah,50h                   ; je kurzor dolñ ?
         jne       modiscr6                 ; nen° kurzor dolñ
         call      getendl                  ; poskytnut° max. ©†dku konce okna
         inc       dh
         cmp       dh,ds:[displw]           ; je jië posledn° ©†dek okna ?
         jbe       modiscr1                 ; je jië posledn° ©†dek okna
         inc       byte ptr ds:[displw]     ; posun konce dolñ
         jmp       short modiscr8           ; p©ekreslen° okna

                                          ;* prvn° ©†dek
modiscr6:cmp       ah,47h                   ; je Home ?
         jne       modiscr7                 ; nen° Homr
         mov       byte ptr ds:[displw],8   ; prvn° povolenò ©†dek
         jmp       short modiscr8           ; p©ekreslen° okna

                                          ;* posledn° ©†dek
modiscr7:cmp       ah,4fh                   ; je End ?
         jne       modiscr1                 ; nen° End
         call      getendl                  ; poskytnut° max. ©†dku konce okna
         inc       dh
         mov       ds:[displw],dh           ; omezen° na maxim†ln° ©†dek

modiscr8:call      windret                  ; novÇ zobrazen° okna
         jmp       short modiscr1           ; áek†n° na nàjakou akci

modiscr9:
         and       byte ptr ds:[conf6],not 4 ; zru®en° funkce SCROLL LOCK

         call      getnakt
         xor       ax,ax
         call      usesedit                 ; normalizace
         call      getakt
         xor       ax,ax
         call      usesedit                 ; normalizace

         call      windretx                 ; n†vrat zobrazen° oken

         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
endif
         popf
         ret
; -----------------------------------------------------------------------------
public   modihlpalt,outhelp,outedhlp,outthlp

modihlpalt:                               ;* modifikace vyhled†v†n° s Alt

         call      testalt                  ; test stisku kl†vesy Alt
         jnz       modihla2                 ; kl†vesa Alt je stisknuta
         cmp       byte ptr cs:[numsrc],0   ; je buffer jië vynulovanò ?
         je        modihla2                 ; je jië vynulovanò
         mov       byte ptr cs:[numsrc],0   ; vynulov†n° buff. rychlÇho hled†n°
         call      endline                  ; zobrazen° koncovÇho ©†dku
         call      obrkurz                  ; zobrazen° kurzoru povel. ©†dku
modihla2:ret


outhelp:                                  ;* zobrazen° z†kladn° n†povàdy
         pushf
         push      si
         call      obrcomm                  ; zobrazen° p©°kazovÇho ©†dku
         lea       si,[tabhlp0]             ; tabulka z†kladn°ch n†povàd
         call      outakth                  ; zobrazen° textu n†povàdy
         call      obrkurz                  ; navr†cen° zobrazen° kurzoru
         pop       si
         popf
         ret


outedhlp:                                 ;* zobrazen° n†povàdy pro editor
         pushf
         and       byte ptr cs:[flags],3fh  ; p©°znak - nejsou p©esmykaáe
         push      si
         lea       si,[txthlped]            ; adresa n†povàdy pro editor
         call      outthlp                  ; zobrazen° textu n†povàdy
         pop       si
         popf
         ret

public   modihlp

modihlp:                                  ;* modifikace n†povàdy
                                            ; VSTUP: SI=tabulka adres n†povàd

         push      bx
         push      si
         push      ds
                                          ;* zji®tàn° statutu p©esmykaáñ
         xor       bx,bx
         mov       ds,bx                    ; DS <- 0000
         mov       bh,ds:[0417h]            ; statu p©esmykaáñ
         push      cs
         pop       ds                       ; DS <- CS
         mov       bl,0c0h                  ; k¢d pro Alt-
         test      bh,8                     ; je p©esmykaá Alt- ?
         jnz       modihlp2                 ; je p©esmykaá Alt-
         mov       bl,80h                   ; k¢d pro Ctrl-
         test      bh,4                     ; je p©esmykaá Ctrl- ?
         jnz       modihlp2                 ; je p©esmykaá Ctrl-
         test      bh,3                     ; je p©esmykaá Shift- ?
         mov       bl,40h                   ; k¢d pro Shift-
         jnz       modihlp2                 ; je p©esmykaá Shift-
         xor       bl,bl                    ; k¢d - bez p©esmykaáe
modihlp2:                                 ;* aktualizace stavu p©esmykaáñ
         mov       bh,ds:[flags]            ; souáasnÇ nastaven° p©esmykaáñ
         and       byte ptr ds:[flags],3fh  ; zru®en° p©°znaku p©esmykaáñ
         or        ds:[flags],bl            ; novÇ nastaven° p©esmykaáñ
         and       bh,0c0h                  ; pñvodn° nastaven° p©esmykaáñ
         cmp       bh,bl                    ; byla zmàna statutu p©esmykaáñ ?
         je        modihlp3                 ; nebyla zmàna
         call      outakth                  ; zobrazen° novÇ n†povàdy
modihlp3:pop       ds
         pop       si
         pop       bx
         ret

public   outakth
outakth:                                  ;* zobrazen° aktivn° n†povàdy
                                            ; VSTUP: SI=tabulka adres n†povàd

         push      bx
         push      si
         cmp       word ptr cs:[si],0       ; je tabulka definovan† ?
         je        outakth1                 ; tabulka nen° definovan†
         mov       bl,cs:[flags]            ; souáasnÇ nastaven° p©esmykaáñ
         and       bl,0c0h                  ; nastaven° p©esmykaáñ
         rol       bl,1
         rol       bl,1
         rol       bl,1                     ; p©evod na á°slo
         xor       bh,bh
         mov       si,cs:[si+bx]            ; adresa n†povàdy
         call      outthlp                  ; zobrazen° n†povàdy SI
outakth1:pop       si
         pop       bx
         ret


outthlp:                                  ;* zobrazen° textu n†povàdy
                                            ; VSTUP: SI=adresa textu n†povàdy
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      ds
         push      cs
         pop       ds
         call      testakth                 ; je n†povàda povolena ?
         jc        outthlp5                 ; n†povàda nen° povolena
         call      mouseoff                 ; vypnut° my®i
         call      getdispl                 ; posledn° ©†dek obrazovky
         xor       dl,dl
;         mov       dx,24*256                ; pozice pro zobrazen° textu n†pov.
         mov       cx,10                    ; á°taá funkán°ch kl†ves
         mov       bl,"1"                   ; oznaáen° funkán° kl†vesy
                                          ;* zobrazen° k¢du kl†vesy
outthlp1:mov       al,9                     ; nastaven° barvy 9
         call      outch1                   ; nastaven° barvy pro oznaá. kl†vesy
         mov       al,bl                    ; oznaáen° kl†vesy
         cmp       al,"9"                   ; je jië kl†vesa 10 ?
         jbe       outthlp4                 ; nen°
         mov       al,"1"
         call      outch1
         mov       al,"0"
outthlp4:call      outch1                   ; zobrazen° á°sla kl†vesy
         mov       al,3                     ; barva pro oznaáen° textu n†povàdy
         call      outch1                   ; nastaven° barvy textu
                                          ;* zobrazen° textu kl†vesy
         push      cx                       ; á°taá kl†ves
         mov       cl,6                     ; poáet znakñ textu kl†vesy
outthlp2:lodsb                              ; naáten° znaku
         or        al,al                    ; je jië konec textu ?
         jz        outthlp3                 ; je konec textu
         call      outch1                   ; zobrazen° znaku textu
         loop      outthlp2                 ; zobrazen° dal®°ho znaku
outthlp3:mov       al," "                   ; mezera pro konec textu
         call      outch                    ; zobrazen° kocovòch mezer
         pop       cx
                                          ;* oddàlovac° mezera
         mov       al,9                     ; nastaven° barvy 9
         call      outch1                   ; nastaven° barvy pro oznaá. kl†vesy
         mov       al," "                   ; oddàlovac° mezera
         call      outch1                   ; zobrazen° oddàlovac° mezery
         inc       bl                       ; zvò®en° á°sla kl†vesy
         loop      outthlp1                 ; dal®° kl†vesa
         call      mouseon                  ; zapnut° my®i

outthlp5:pop       ds
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   testscr

testscr:                                  ;* test p©esmykaáe SCROLL LOCK
                                            ; VùSTUP: ZN=SCROLL LOCK je aktivn°

         push      ds
         push      ax
         xor       ax,ax
         mov       ds,ax
         test      byte ptr ds:[417h],10h   ; je aktivn° SCROLL LOCK ?
         pop       ax
         pop       ds
         ret

; -----------------------------------------------------------------------------
public   testalt

testalt:                                  ;* test stisku kl†vesy Alt
                                            ; VùSTUP: ZN=kl†vesa je stisknuta

         push      ds
         push      ax
         xor       ax,ax
         mov       ds,ax
         test      byte ptr ds:[417h],8     ; je stisknuta kl†vesa Alt ?
         pop       ax
         pop       ds
         ret

; -----------------------------------------------------------------------------
public   testshft

testshft:                                 ;* test stisku kl†vesy Shift
                                            ; VùSTUP: ZN=kl†vesa je stisknuta

         push      ds
         push      ax
         test      byte ptr cs:[conf2],8    ; je nucenò SHIFT ?
         jnz       testshf1                 ; je nucenò SHIFT
         test      byte ptr cs:[conf2],10h  ; je povolenò reëim se SHIFT ?
         jz        testshf1                 ; nen° povolenò SHIFT
         xor       ax,ax
         mov       ds,ax
         test      byte ptr ds:[417h],3     ; je stisknuta kl†vesa Shift ?
testshf1:pop       ax
         pop       ds
         ret



; *****************************************************************************
;
;                    ZnakovÇ vstupnà/vòstupn° podprogramy
;
; *****************************************************************************
public   flushkey

flushkey:                                 ;* vypr†zdnàn° bufferu kl†vesnice

         push      ax
         push      cx
         xor       cx,cx                    ; maxim†ln° poáet cyklñ
flk1:    call      testkey                  ; test stavu kl†vesnice
         jz        flk2                     ; nen° p©ipraven dal®° znak
         call      inpkey                   ; vstup znaku z kl†vesnice
         loop      flk1                     ; vypr†zdnàn° dal®°ho znaku
flk2:    pop       cx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   inpkeyf

inpkeyf:                                 ;* vstup znaku s vyprazd§ov†n°m
                                            ; VSTUP: SI=tabulka n†povàdy
                                            ; VùSTUP: AX=znak

         push      cx
         xor       ax,ax                    ; AX <- 0 nulov†n° bufferu
         xchg      ax,cs:[edikey]           ; vyjmut° znaku z bufferu
         or        ax,ax                    ; je nàjak† kl†vesa ?
         jnz       inpkey5                  ; byla nàjak† kl†vesa
inpkey4: call      modihlp                  ; modifikace zobrazen° n†povàdy
;         call      testalt
;         jnz       inpkey8                  ; kl†vesa ALT je stisknuta
;         mov       byte ptr cs:[numsrc],0   ; zru®en° bufferu znakñ
inpkey8: call      testkey                  ; je p©ipraven znak ?
         jz        inpkey4                  ; áek†n° na p©°chod znaku
         call      inpkey                   ; vstup znaku z kl†vesnice
                                          ;* zru®en° stejnòch znakñ
inpkey5: mov       cx,ax                    ; £schova znaku
         mov       ah,1
         call      inpkbuf                  ; je nàjakò znak v buffer ?
         jnz       inpkey7                  ; je znak v bufferu - neru®° se
inpkey6: call      testkey                  ; test p©ipravenÇ kl†vesy
         jz        inpkey7                  ; nen° p©ipraven ë†dnò znak
         cmp       ax,cx                    ; je stejnò znak ?
         jne       inpkey7                  ; nen° stejnò znak
         call      inpkey                   ; vypr†zdnàn° bufferu kl†vesnice
         mov       cs:[edikey],ax           ; £schova znaku
         jmp       short inpkey6            ; dal®° znak
inpkey7: mov       ax,cx                    ; n†vrat znaku
         pop       cx
         ret

; -----------------------------------------------------------------------------
public   testkey

testkey:                                  ;* test kl†vesnice, zda p©i®el znak
                                            ; VùSTUP: NZ=znak je p©ipraven
                                            ;         AX=znak

;         mov       ax,cs:[edikeym]
;         or        ax,ax
;         jnz       inpkey3                  ; je p©ipraven znak

         test      byte ptr cs:[conf6],8    ; je karta EGA ?
         jz        testkey2                 ; nen° karta EGA
         cmp       word ptr cs:[dark],0     ; je povoleno stm°v†n° ?
         je        testkey2                 ; stm°v†n° nen° povoleno
         cmp       word ptr cs:[segvram],0b000h ; je displej MDA ?
         je        testkey2                 ; je MDA - neztmavuje se
         cmp       word ptr cs:[darkcit],0  ; m† bòt displej stmaven ?
         jnz       testkey1                 ; displej nem† bòt stmaven
                                          ;* displej m† bòt stmaven
         test      byte ptr cs:[conf6],10h  ; je displej stmaven ?
         jnz       testkey2                 ; displej je jië stmaven
         call      darkon                   ; stmaven° displeje
         jmp       short testkey2
testkey1:                                 ;* displej nem† bòt stmaven
         test      byte ptr cs:[conf6],10h  ; je displej stmaven ?
         jz        testkey2                 ; displej nen° stmaven
         call      darkoff                  ; rozsv°cen° displeje
testkey2:
         sti
         call      vyzvy                    ; obsluha vòzev od portñ COM
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         sti
         int       28h                      ; obsluha áek†n° na kl†vesnici
         sti
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         mov       ah,cs:[keystat]          ; k¢d pro áten° stavu kl†vesnice
         jmp       short inpkey0            ; áten° stavu kl†vesnice

; -----------------------------------------------------------------------------
public   darkon
darkon:                                   ;* stmaven° displeje
         push      si
         mov       si,offset paloff
         call      setpal                   ; nastaven° palet displeje
         or        byte ptr cs:[conf6],10h  ; displej je stmaven
         pop       si
         ret
; -----------------------------------------------------------------------------
public   darkoff
darkoff:                                  ;* rozsv°cen° displeje
         push      si
         mov       si,offset palon
         call      setpal                   ; nastaven° palet displeje
         and       byte ptr cs:[conf6],not 10h ; displej nen° stmaven
         pop       si
         ret
; -----------------------------------------------------------------------------
public   setpal
setpal:                                   ;* nastaven° palet displeje CS:SI
         push      ax
         push      cx
         push      dx
         cli
         mov       dx,3dah
         in        al,dx                    ; synchronizace
         mov       dx,3c0h
         mov       cx,16
         xor       ax,ax
setpal1: xchg      ah,al
         out       dx,al                    ; registr
         xchg      ah,al
         mov       al,cs:[si]
         inc       si
         out       dx,al                    ; data
         inc       ah
         loop      setpal1                  ; dal®° registr
         mov       al,31h
         out       dx,al
         mov       al,cs:[si]
         inc       si
         out       dx,al                    ; okol°
         sti
         pop       dx
         pop       cx
         pop       ax
         ret
; -----------------------------------------------------------------------------
public   inpkey

inpkey:                                  ;* vstup znaku z kl†vesnice
                                           ; VùSTUP: AX=znak

;         call      testkey                  ; je p©ipraven znak ?
;         je        inpkey                   ; áek†n° na p©°chod znaku
;         xor       ax,ax
;         xchg      ax,cs:[edikeym]          ; znak od my®i
;         or        ax,ax
;         jnz       inpkey3                  ; byl znak v bufferu my®i
         and       byte ptr cs:[parrez],not 80h ; zru®en° p©°znaku p©eru®en°
         mov       ah,cs:[keyinp]           ; k¢d pro áten° znaku z kl†vesnice
inpkey0: call      inpkbuf                  ; vstup znaku z bufferu
         jnz       inpkey00                 ; byl nàjakò znak
         sti
         int       16h                      ; áten° znaku z kl†vesnice
         sti
inpkey00:pushf
         or        ah,ah                    ; je k¢d kl†vesy s Alt ?
         je        inpkey2                  ; je k¢d s Alt
         cmp       al,0e0h                  ; je ©°dic° k¢d s E0 ?
         je        inpkey1                  ; je ©°dic° k¢d s E0
         cmp       al,0f0h                  ; je ©°dic° k¢d s F0 ?
         jne       inpkey2                  ; nen° ©°dic° k¢d s F0
inpkey1: xor       al,al                    ; normalizace na k¢d 00
inpkey2: popf
inpkey3: ret


public   inpkbuf
inpkbuf:                                  ;* vstup znaku z bufferu
                                            ; VSTUP: AH=bit 0: 1=test
                                            ; VùSTUP: AX=kl†vesa
                                            ;         ZY=nen° kl†vesa

         push      bx
         push      si
         push      ds
                                          ;* test, zda je buffer
         mov       bx,word ptr cs:[ukazkey+2]
         or        bx,word ptr cs:[ukazkey] ; je buffer ?
         jz        inpkbuf3                 ; nen° kl†vesa
                                          ;* test, zda je znak
         lds       si,cs:[ukazkey]          ; ukazatel bufferu makrokl†ves
         mov       bl,ds:[si]               ; áten° p©ipravenÇho znaku
         or        bl,bl                    ; je to platnò znak ?
         jz        inpkbuf2                 ; nen° dal®° znak
                                          ;* zvò®en° ukazatele bufferu
         test      ah,1                     ; je jenom test vstupu ?
         mov       al,bl                    ; naátenò znak
         mov       ah,1                     ; je jako kl†vesa
         jnz       inpkbuf3                 ; je jenom test vstupu
         inc       word ptr cs:[ukazkey]    ; zvò®en° ukazatele textu
         jmp       short inpkbuf3
                                          ;* v bufferu nen° znak
inpkbuf2:mov       word ptr cs:[ukazkey],0
         mov       word ptr cs:[ukazkey+2],0 ; zru®en° ukazatele bufferu
inpkbuf3:pop       ds
         pop       si
         pop       bx
         ret

; -----------------------------------------------------------------------------
public   mouseon

mouseon:                                  ;* zapnut° zobrazen° my®i

         push      ax
         mov       ax,1
mouseon0:pushf
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es
         test      byte ptr cs:[config],40h ; je my® instalov†na ?
         jz        mouseon1                 ; my® nen° instalov†na
         sti
         int       33h                      ; zapnut° zobrazen° my®i
         sti
mouseon1:pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         popf
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   mouseoff

mouseoff:                                 ;* vypnut° zobrazen° my®i

         push      ax
         mov       ax,2
         jmp       short mouseon0

; -----------------------------------------------------------------------------
public   mouseget

; Pouëit° tlaá°tek:  levÇ=veden° kurzoru, pravÇ=ESC,oznaáen°


mouseget:                                 ;* poskytnut° stavu my®i
                                            ; VùSTUP:BX=funkce
                                            ;           0=nen° ë†dnÇ tlaá°tko
                                            ;           1=levÇ tlaá°tko drë°
                                            ;           2=pravÇ tlaá°tko drë°
                                            ;           3=st©edn° tlaá°tko drë°
                                            ;           4=levÇ tlaá°tko 1x
                                            ;           5=pravÇ tlaá°tko 1x
                                            ;           6=st©edn° tlaá°tko 1x
                                            ;           7=levÇ tlaá°tko 2x
                                            ;           8=pravÇ tlaá°tko 2x
                                            ;           9=st©edn° tlaá°tko 2x
                                            ;          10=uvolnàn° levÇho tlaá.
                                            ;          11=uvolnàn° pravÇho tlaá.
                                            ;          12=uvolnàn° prost©. tlaá.
                                            ;        ZY=nen° ë†dnÇ tlaá°tko

         xor       bx,bx
         test      byte ptr cs:[config],40h ; je my® instalov†na ?
         jnz       mouseg10                 ; my® je nainstalov†na

         jmp       mousegt1                 ; my® nen° instalov†na

mouseg10:pushf
         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es

         mov       ax,3
         sti
         int       33h                      ; poskytnut° pozice my®i
         sti
         shr       cx,1
         shr       cx,1
         shr       cx,1                     ; pozice / 8
         xchg      byte ptr cs:[mousepoz],cl ; pozice na displeji
         shr       dx,1
         shr       dx,1
         shr       dx,1                     ; ©†dek / 8
         xchg      byte ptr cs:[mousepoz+1],dl ; ©†dek s kurzorem my®i
         mov       ch,dl                    ; ©†dek s kurzorem my®i
         cmp       word ptr cs:[mousepoz],cx; byla zmàna pozice my®i ?
         je        mouseg13                 ; nen° zmàna pozice my®i

         mov       ax,cs:[dark]             ; konstanta pro stm°vaá
         mov       cs:[darkcit],ax          ; nastaven° á°taáe pro stm°v†n°
         cmp       word ptr cs:[mousepoz],79 ; je pravò horn° roh ?
         jne       mouseg13                 ; nen° pravò horn° roh
         mov       word ptr cs:[darkcit],9  ; zhasnut° displeje za 1/2 sekundy

mouseg13:
                                          ;* zji®tàn° tlaá°tek
         test      bl,4                     ; je st©edn° tlaá°tko ?
         jz        mousegt2                 ; nen° st©edn° tlaá°tko
         or        bl,3                     ; nastaven° obou tlaá°tek
mousegt2:and       bl,3                     ; ponech†n° stavu tlaá°tek
         mov       bh,cs:[citmouse]         ; á°taá my®i
         test      bl,2                     ; je pravÇ tlaá°tko ?
         jnz       mousegt6                 ; je pravÇ tlaá°tko
         or        byte ptr cs:[insmouse],1 ; p©°znak, ëe nastaven° nen° uráeno
mousegt6:                                 ;* byla zmàna ?
         cmp       bl,cs:[mousedat]         ; je zmàna tlaá°tek ?
         je        mousegt3                 ; nen° zmàna stavu tlaá°tek
                                          ;* je zmàna tlaá°tek
         ja        mousegt4                 ; nen° uvolnàn° tlaá°tek
                                          ;* je uvolnàn° tlaá°tka
         xchg      bl,cs:[mousedat]         ; n†vrat uvolnànÇho tlaá°tka
         add       bl,9                     ; korekce na k¢d uvolnàn°
         jmp       short mousegt3
mousegt4:                                 ;* je stisknuto dal®° tlaá°tko
         mov       ax,cs:[dark]             ; konstanta pro stm°vaá
         mov       cs:[darkcit],ax          ; nastaven° á°taáe pro stm°v†n°

         mov       byte ptr cs:[citmouse],6 ; á°taá my®i 1/3 sekundy
         mov       cs:[mousedat],bl         ; uloëen° novÇho stavu tlaá°tek
         add       bl,3                     ; k¢dy pro prvn° stisk
                                          ;* test druhÇho stisku
         or        bh,bh                    ; je prvn° stisk ?
         je        mousegt3                 ; je prvn° stisk
         add       bl,3                     ; k¢dy pro druhò stisk
mousegt3:xor       bh,bh                  ;* nen° zmàna tlaá°tek
         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         popf
mousegt1:
         ;cmp       bl,4
         ;jb        mousegt5
         ;cmp       bl,7
         ;jae       mousegt5
         ;cmp       byte ptr cs:[citmouse],3
         ;jb        mousegt5
         ;xor       bl,bl
;mousegt5:
         or        bx,bx
         ret

; -----------------------------------------------------------------------------
public   mousemen

mousemen:                                 ;* funkán° kl†vesy s my®°
                                            ; VSTUP: BL=k¢d tlaá°tek
                                            ; VùSTUP: AX=k¢d funkán° kl†vesy
                                            ;         CY=nen° funkán° kl†vesa


         xor       ax,ax
         push      dx
         call      testakth                 ; je n†povàda aktivn° ?
         jc        mousemn1                 ; n†povàda nen° aktivn°
         mov       dx,cs:[mousepoz]         ; pozice kurzoru my®i
         cmp       dh,cs:[displ]            ; je ©†dek s n†povàdou ?
         jb        mousemn1                 ; nen° ©†dek s n†povàdou
         cmp       bl,11                    ; je stisk pravÇho tlaá°tka ?
         je        mousemn3                 ; je stisk pravÇho tlaá°tka
         mov       dh,40h                   ; p©°znka n†povàdy se SHIFT
         cmp       bl,12                    ; je stisk prost©edn°ho tlaá°tka ?
         je        mousemn4                 ; je volba SHIFT
         cmp       bl,10                    ; je stisk levÇho tlaá°tka ?
         stc
         jne       mousemn1

         mov       dh,cs:[flags]            ; p©°znaky
         and       dh,0c0h                  ; stav p©esmykaáñ
         or        dh,dh
         mov       ax,3b00h                 ; k¢d kl†vesy F1
         jz        mousemn2                 ; je z†kladn° n†povàda
mousemn4:mov       ah,54h                   ; n†povàda se SHIFT
         cmp       dh,40h
         je        mousemn2                 ; je n†povàda se SHIFT
         mov       ah,5eh                   ; n†povàda s CTRL
         cmp       dh,80h
         je        mousemn2                 ; je n†povàda s CTRL
mousemn3:mov       ah,68h                   ; n†povàda s ALT
mousemn2:shr       dl,1
         shr       dl,1
         shr       dl,1                     ; pozice / 8
         add       ah,dl                    ; k¢d fukán° kl†vesy
mousemn1:pop       dx
         ret

; -----------------------------------------------------------------------------
public   kurzout

kurzout:                                  ;* vypnut° zobrazen° kurzoru

         pushf
         push      ax
         push      cx
         push      dx
         xor       al,al
         call      getdispl                 ; poáet ©†dkñ displeje
         inc       dh                       ; ©†dek za rohem
         xor       dl,dl
         call      outch1                   ; nastaven° pozice kurzoru
         pop       dx
         pop       cx
         pop       ax
         popf
         ret

; -----------------------------------------------------------------------------
public   outhexw,outhexb

outhexw:                                  ;* zobrazen° slova HEX
                                            ; VSTUP: AX=slovo k zobrazen°
                                            ;        DX=pozice
         push      ax
         mov       al,ah
         call      outhexb                  ; zobrazen° vy®®°ho bajtu
         pop       ax

outhexb:                                  ;* zobrazen° bajtu HEX
                                            ; VSTUP: AL=bajt k zobrazen°
                                            ;        DX=pozice
         push      ax
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1
         call      outhexch
         pop       ax

outhexch:push      ax
         and       al,0fh
         cmp       al,10
         jb        outhxch1
         add       al,7
outhxch1:add       al,"0"
         call      outch1
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   outch1,outch10

outch1:                                   ;* vòstup 1 znaku na displej
                                            ; VSTUP: DX=pozice kurzoru
                                            ;        AL=ASCII znak

         push      cx                       ; £schova CX
         mov       cx,1                     ; poáet - 1 znak
         call      outch                    ; zobrazen° 1 znaku
         pop       cx                       ; n†vrat CX
         ret

outch10:                                  ;* vòstup 1 znaku na displej
                                            ; VSTUP: DX=pozice kurzoru
                                            ;        AL=ASCII znak

         push      cx                       ; £schova CX
         mov       cx,1                     ; poáet - 1 znak
         call      outch0                   ; zobrazen° 1 znaku
         pop       cx                       ; n†vrat CX
         ret

; -----------------------------------------------------------------------------
public   outch01,outch011

outch01:                                  ;* vòstup znaku na displej VRAM
                                            ; VSTUP: DX=pozice kurzoru
                                            ;        CX=poáet znakñ
                                            ;        AL=ASCII znak
                                            ;        BL=atribut barvy

         push      cx
         push      dx
         push      es
         cmp       dl,79                    ; je p©ekroáena pozice ?
         ja        outch011                 ; pozice p©ekroáena
         cmp       dh,cs:[displ]            ; je p©ekroáen ©†dek ?
         ja        outch011                 ; ©†dek p©ekroáen
         les       di,dword ptr cs:[adrvram]; adresa zaá†tku VRAM
         push      ax
         mov       al,80
         mul       dh
         xor       dh,dh
         add       ax,dx
         add       ax,ax
         add       di,ax
         pop       ax
         mov       ah,bl
         rep       stosw
outch011:pop       es
         pop       dx
         pop       cx
         ret


public   outch02

outch02:                                  ;* vòstup znaku na displej BIOS
                                            ; VSTUP: DX=pozice kurzoru
                                            ;        CX=poáet znakñ
                                            ;        AL=ASCII znak
                                            ;        BL=atribut barvy

         push      cx
         push      dx
         mov       bh,cs:[aktpage]          ; aktivn° str†nka
         and       bh,1
         mov       ah,2                     ; funkce nastaven° pozice kurzoru
         push      ax
         push      cx
         push      bx
         int       10h                      ; nastaven° pozice kurzoru
         pop       bx
         pop       cx
         pop       ax
         jcxz      outch022
         mov       ah,9                     ; funkce z†pisu znaku s atributem
         int       10h                      ; z†pis znaku
outch022:pop       dx
         pop       cx
         ret


public   outch,outch0,setout

outch:                                    ;* vòstup znaku na displej (- ©°dic°)
                                            ; VSTUP: DX=pozice kurzoru
                                            ;        CX=poáet znakñ
                                            ;        AL=ASCII znak
                                            ;        DS=datovò segment

         cmp       al,32                    ; je nastaven° atributu ?
         jae       outch0                   ; nen° nastaven° atributu - tisk
         push      ax                       ; £schova AX (znak k tisku)
         push      bx                       ; £schova BX
         push      cx
         push      dx
         push      si                       ; £schova SI
         push      di                       ; £schova DI
         push      bp                       ; £schova BP
         or        al,al                    ; je pouze nastaven° kurzoru ?
         jz        outch12                  ; je nastaven° kurzoru
         xor       ah,ah                    ; AH <- 0
         mov       si,offset col1-1         ; tabulka barev
         add       si,ax                    ; adresa barvy
         mov       al,cs:[si]               ; naáten° barvy
         mov       cs:[color],al            ; nastaven° atributu barvy
         jmp       short outch13            ; n†vrat z obsluhy
                                          ;* nastaven° kurzoru
outch12: mov       bh,cs:[aktpage]          ; aktivn° videostr†nka
         and       bh,1
         mov       ah,2                     ; funkce nastaven° pozice kurzoru
         int       10h                      ; nastaven° pozice kurzoru
outch13: pop       bp                       ; n†vrat BP
         pop       di                       ; n†vrat DI
         pop       si                       ; n†vrat SI
         pop       dx
         pop       cx
         pop       bx                       ; n†vrat BX
         pop       ax                       ; n†vrat AX (znak k tisku)
         ret

outch0:                                   ;* vòstup znaku na displej
                                            ; VSTUP: DX=pozice kurzoru
                                            ;        CX=poáet znakñ
                                            ;        AL=ASCII znak
                                            ;        DS=datovò segment

         push      es
         push      bx                       ; £schova BX
         push      si                       ; £schova SI
         push      di                       ; £schova DI
         push      bp                       ; £schova BP
         push      ax                       ; £schova AX (znak k tisku)
         mov       bl,cs:[color]            ; aktivn° barva (atribut)
setout:  call      outch02                  ; vòstup znaku (nastavenò ovladaá)
         add       dl,cl                    ; zvò®en° pozice kurzoru
         pop       ax                       ; n†vrat AX (znak k tisku)
         pop       bp                       ; n†vrat BP
         pop       di                       ; n†vrat DI
         pop       si                       ; n†vrat SI
         pop       bx                       ; n†vrat BX
         pop       es
         ret




; -----------------------------------------------------------------------------
public   outtxt

outtxt:                                   ;* vòstup textu na displej
                                            ; VSTUP: DX=pozice kurzoru
                                            ;        DS:SI=text k tisku
                                            ;        (DS=datovò segment)
         push      ax
outtxt0: lodsb                              ; naáten° znaku k tisku
         or        al,al                    ; je koncovò bajt 0 ?
         jz        outtx1                   ; je koncovò bajt 0 - konec
         cmp       al,31                    ; je konec ©†dku ?
         je        outtx1                   ; je konec ©†dku
         call      outch1                   ; tisk 1 znaku
         jmp       short outtxt0            ; tisk dal®°ho znaku
outtx1:  pop       ax
         ret

; -----------------------------------------------------------------------------
public   outtx0

outtx0:                                   ;* vòstup textu na displej
                                            ; VSTUP: DX=pozice kurzoru
                                            ;        DS:SI=text k tisku
                                            ;        (DS=datovò segment)

         push      ax
outtx2:  lodsb                              ; naáten° znaku k tisku
         or        al,al                    ; je koncovò bajt 0 ?
         jz        outtx3                   ; je koncovò bajt 0 - konec
         cmp       al,31                    ; je konec ©†dku ?
         je        outtx3                   ; je konec ©†dku
         call      outch10                  ; tisk 1 znaku
         jmp       short outtx2             ; tisk dal®°ho znaku
outtx3:  pop       ax
         ret

; -----------------------------------------------------------------------------
public   wrolldown,wrollup

wrollup:                                  ;* rolov†n° okna nahoru
                                            ; VSTUP: BP=ukazatel okna
                                            ;        AL=poáet ©†dek k rolov†n°

         call      testaktw                 ; je okno aktivn° ?
         jnc       wrollup0                 ; okno je aktivn°
         ret

wrolldown:                                ;* rolov†n° okna dolñ
                                            ; VSTUP: BP=ukazatel okna
                                            ;        AL=poáet ©†dek k rolov†n°
         call      testaktw                 ; je okno aktivn° ?
         jnc       wrolldn0                 ; okno je aktivn°
         ret

wrollup0:                                 ;* rolov†n° okna nahoru
         push      ax
         mov       ah,6                     ; rolov†n° okna nahoru
         jmp       short wrolldn1           ; rolov†n° okna


wrolldn0:                                 ;* rolov†n° okna dolñ
         push      ax
         mov       ah,7                     ; rolov†n° dolñ
wrolldn1:call      wrolldnup                ; rolov†n° okna
         pop       ax
         ret

public   wrolldnup
wrolldnup:                                ;* rolov†n° okna
                                            ; VSTUP: AH=7 dolñ
                                            ;        AH=6 nahoru

         push      bp
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         call      mouseoff                 ; vypnut° my®i
         mov       cl,ds:[bp+3]             ; poá†teán° pozice okna
         mov       dl,cl
         add       dl,39
         mov       bh,ds:[col1]
         mov       ch,4
         call      getendlw                 ; poskytnut° posledn°ho ©†dku
         dec       dh
         int       10h
         call      mouseon                  ; zapnut° my®i
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       bp
         ret


; -----------------------------------------------------------------------------
public   getdispcx

getdispcx:                                ;* áten° á°sla posledn°ho ©†dku
                                            ; VùSTUP: CX=á°slo posledn°ho ©†dku
         xor       cx,cx
         mov       cl,cs:[displ]
         ret

; -----------------------------------------------------------------------------
public   getdisplw

getdisplw:                                ;* áten° á°sla posledn°ho ©†dku
                                            ; VùSTUP: DH=á°slo posledn°ho ©†dku
         mov       dh,cs:[displw]
         ret

; -----------------------------------------------------------------------------
public   getdispl

getdispl:                                 ;* áten° á°sla posledn°ho ©†dku
                                            ; VùSTUP: DH=á°slo posledn°ho ©†dku
         mov       dh,cs:[displ]
         ret

; -----------------------------------------------------------------------------
public   getpoclw

getpoclw:                                 ;* poskytnut° poátu ©†dkñ bez n†povàdy
                                            ; VùSTUP: CX=poáet ©†dkñ

         call      getpocl
         cmp       cl,cs:[displw]           ; je konec okna men®° ?
         jbe       getpocl4
         mov       cl,cs:[displw]
getpocl4:ret

; -----------------------------------------------------------------------------
public   getpocl

getpocl:                                  ;* poskytnut° poátu ©†dkñ bez n†povàdy
                                            ; VùSTUP: CX=poáet ©†dkñ
         xor       cx,cx
         mov       cl,cs:[displ]
         call      testakth                 ; je n†povàda aktivn° ?
         jc        getpocl2                 ; n†povàda nen° aktivn°
         dec       cx                       ; sn°ëen° poátu ©†dkñ
getpocl2:ret

; -----------------------------------------------------------------------------
public   getendlw
getendlw:                                 ;* posledn° ©†dek okna DH
         call      getendl                  ; maxim†ln° ©†dek okna
         cmp       dh,cs:[displw]           ; je konec okna men®° ?
         jb        getendl4
         mov       dh,cs:[displw]
         dec       dh
getendl4:ret
; -----------------------------------------------------------------------------
public   getendl

getendl:                                  ;* áten° á°sla ©†dku konce okna
                                            ; VùSTUP: DH=á°slo ©†dku konce okna

         call      getdispl                 ; poskytnut° á°sla posledn°ho ©†dku
         dec       dh
         call      testakth                 ; je n†povàda aktivn° ?
         jc        getend2                  ; n†povàda nen° aktivn°
         dec       dh                       ; sn°ëen° á°sla ©†dku
getend2: ret

; -----------------------------------------------------------------------------
public   getnumlw

getnumlw:                                 ;* áten° poátu ©†dkñ souborñ
                                            ; VùSTUP: CX=poáet ©†dkñ se soubory

         push      dx
         call      getendlw                 ; á°slo posledn°ho ©†dku okna
         xor       cx,cx
         mov       cl,dh
         sub       cl,4                     ; odeáten° okrajñ okna
         pop       dx
         ret

; -----------------------------------------------------------------------------
public   getnuml

getnuml:                                  ;* áten° poátu ©†dkñ souborñ
                                            ; VùSTUP: CX=poáet ©†dkñ se soubory

         push      dx
         call      getendl                  ; á°slo posledn°ho ©†dku okna
         xor       cx,cx
         mov       cl,dh
         sub       cl,4                     ; odeáten° okrajñ okna
         pop       dx
         ret

; -----------------------------------------------------------------------------
public   getnumfw

getnumfw:                                 ;* zji®tàn° poátu souborñ na displeji
                                            ; VùSTUP: CX=poáet souborñ v oknà

         call      getnumlw                 ; zji®tàn° poátu ©†dkñ souborñ
         call      testsetw                 ; je plnÇ zobrazen° okna ?
         jz        getnumf3                 ; je plnÇ zobrazen° okna
         push      ax
         mov       ax,cx
         add       cx,ax
         add       cx,ax
         pop       ax
getnumf3:ret

; -----------------------------------------------------------------------------
public   getnumf

getnumf:                                  ;* zji®tàn° poátu souborñ na displeji
                                            ; VùSTUP: CX=poáet souborñ v oknà

         call      getnuml                  ; zji®tàn° poátu ©†dkñ souborñ
         call      testsetw                 ; je plnÇ zobrazen° okna ?
         jz        getnumf1                 ; je plnÇ zobrazen° okna
         push      ax
         mov       ax,cx
         add       cx,ax
         add       cx,ax
         pop       ax
getnumf1:ret

; -----------------------------------------------------------------------------
public   testsetwn

testsetwn:                                ;* test nastaven° neaktivn°ho okna
                                            ; VSTUP: BP=adresa tabulky okna
                                            ; VùSTUP: ZY=je plnÇ zobrazen° okna
         push      bp
         call      getnakt
         call      testsetw
         pop       bp
         ret

; -----------------------------------------------------------------------------
public   testsetw

testsetw:                                 ;* test nastaven° okna
                                            ; VSTUP: BP=adresa tabulky okna
                                            ; VùSTUP: ZY=je plnÇ zobrazen° okna

         test      byte ptr cs:[bp+29],2    ; zobrazuj° se pozn†mky ?
         jz        teststw1                 ; pozn†mky se nezobrazuj°
         cmp       al,al                    ; nastaven° p©°znaku ZY
         ret

teststw1:test      byte ptr cs:[bp+29],1    ; je trojsloupcovÇ zobrazen° ?
         ret

; -----------------------------------------------------------------------------
public   testakth

testakth:                                 ;* test, zda je n†povàda aktivn°
                                            ; VSTUP: BP=adresa tabulky okna
                                            ; VùSTUP: CY=n†povàda nen° aktivn°

         test      byte ptr cs:[flags],4    ; je n†povàda aktivn° ?
         jnz       testakth1                ; n†povàda je aktivn°
         stc                                ; p©°znak - n†povàda nen° aktivn°
testakth1:ret

; -----------------------------------------------------------------------------
public   testaktwn

testaktwn:                                ;* test, zda je neaktivn° okno zapnutÇ
                                            ; VùSTUP: CY=okno je vypnutÇ
         push      bp
         call      getnakt                  ; poskytnut° neatkivn°ho okna
         call      testaktw                 ; test, jestli je okno zapnutÇ
         pop       bp
         ret

; -----------------------------------------------------------------------------
public   testaktw

testaktw:                                 ;* test, zda je okno zapnutÇ
                                            ; VSTUP: BP=adresa tabulky okna
                                            ; VùSTUP: CY=okno je vypnutÇ

         test      byte ptr cs:[flags],2    ; jsou vypnuta obà okna ?
         jnz       testaktw1                ; obà okna jsou vypnuta
         test      byte ptr cs:[bp+0],1     ; p©°znak okna
         jnz       testaktw2                ; okno je zapnutÇ
testaktw1:stc                               ; p©°znak - okno je vypnutÇ
testaktw2:ret

; -----------------------------------------------------------------------------
public   getakt

getakt:                                   ;* poskytnut° adresy aktivn°ho okna
                                            ; VùSTUP: BP=adresa tabulky okna

         test      byte ptr cs:[flags],1    ; je aktivn° levÇ okno ?
         lea       bp,[tabl]                ; adresa levÇho okna
         jnz       getakt1                  ; je levÇ okno
         lea       bp,[tabr]                ; adresa pravÇho okna
getakt1: ret

; -----------------------------------------------------------------------------
public   getnakt

getnakt:                                  ;* poskytnut° adresy neaktivn°ho okna
                                            ; VùSTUP: BP=adresa tabulky okna

         test      byte ptr cs:[flags],1    ; je aktivn° levÇ okno ?
         lea       bp,[tabl]                ; adresa levÇho okna
         jz        getnakt1                 ; je pravÇ okno
         lea       bp,[tabr]                ; adresa pravÇho okna
getnakt1:ret

; -----------------------------------------------------------------------------
public   testakt

testakt:                                  ;* test, zda jde o aktivn° okno
                                            ; VSTUP: BP=adresa tabulky okna
                                            ; VùSTUP: ZY=je aktivn°
         push      ax
         push      bp
         call      getakt                   ; nastaven° adresy aktivn°ho okna
         mov       ax,bp                    ; adresa aktivn°ho okna
         pop       bp
         cmp       ax,bp                    ; je to aktivn° okno ?
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   testexe

testexe:                                  ;* test, zda je soubor EXE, COM, BAT
                                            ; VSTUP: DS:SI=adresa poloëky
                                            ; VùSTUP: ZY=je spustitelnò program

         push      di
         push      es
         push      cs
         pop       es
         lea       di,[extent]              ; tabulka extentñ
         call      testexe0                 ; test p©°pony EXE
         je        testexe3                 ; p©°pona nalezena
         call      testexe0                 ; test p©°pony COM
         je        testexe3                 ; p©°pona nalezena
         call      testexe0                 ; test p©°pony BAT
testexe3:pop       es
         pop       di
         ret

testexe0:                                 ;* test, zda je p©°pona ES:DI
                                            ; VSTUP: BP=adresa parametrñ okna
                                            ;        DS:SI=adresa poloëky
                                            ;        ES:DI=adresa p©°pony

         push      di
         push      si
         push      ds
         add       si,9                     ; adresa p©°pony souboru
         cmpsw
         jne       testexe1
         cmpsb
testexe1:pop       ds
         pop       si
         pop       di
         pushf
         add       di,3                     ; adresa n†sleduj°c° p©°pony
         popf
         ret

; -----------------------------------------------------------------------------
;                              konverze znakñ
; -----------------------------------------------------------------------------
public   konvfnt
konvfnt:                                  ;* konverze fontu znakñ
                                            ; VSTUP/VùSTUP: AL=znak

         pushf
         push      bx
         push      ds
         push      cs
         pop       ds
         test      byte ptr ds:[config],3
         jz        konvfnt2                 ; nen° p©evod fontu
         cmp       al,128                   ; nejmen®° znak
         jb        konvfnt2                 ; je men®°
         cmp       al,171                   ; nejvàt®° znak
         ja        konvfnt2                 ; je vàt®°
         sub       al,128                   ; offset v tabulce
         add       al,al
         lea       bx,[prevcs]              ; tabulka pro p©evod
         test      byte ptr ds:[config],1   ; je vypnut° áe®tiny ?
         jnz       konvfnt1                 ; je vypnut° áe®tiny
         inc       bx                       ; je LATIN 2
konvfnt1:xlat                               ; p©evod znaku
konvfnt2:pop       ds
         pop       bx
         popf
         ret

; -----------------------------------------------------------------------------
public   lowcase0
lowcase0:                                 ; VSTUP: AL=znak k p©evodu

         cmp       al,"A"                   ; je znak men®° neë "A" ?
         jb        lowcas8                  ; nen° velkÇ p°smeno
         cmp       al,"Z"                   ; je znak vàt®° neë "Z" ?
         ja        lowcas8                  ; nen° velkÇ p°smeno
         add       al,32                    ; korekce na malÇ p°smeno
lowcas8: ret


public   lowcase
lowcase:                                  ;* p©evod znaku na malÇ p°smeno
                                            ; VSTUP: AL=znak k p©evodu

         cmp       al,"A"                   ; je znak men®° neë "A" ?
         jb        lowca5                   ; nen° velkÇ p°smeno
         cmp       al,"Z"                   ; je znak vàt®° neë "Z" ?
         ja        lowca1                   ; nen° velkÇ p°smeno
         add       al,32                    ; korekce na malÇ p°smeno
         ret

lowca1:  or        al,al
         jns       lowca5
         test      byte ptr cs:[config],1   ; je vypnut° áe®tiny ?
         jnz       lowca4                   ; je vypnut° áe®tiny
         push      bx
         lea       bx,[upperlat-2]          ; p©evodn° tabulka LATIN 2
         test      byte ptr cs:[config],2   ; je LATIN 2 ?
         jnz       lowca2                   ; je k¢d LATIN 2
         lea       bx,[upperkam-2]          ; p©evodn° tabulka KAMENICKùCH
lowca2:  add       bx,2                     ; zvò®en° adresy v tabulce
         cmp       byte ptr cs:[bx],0       ; je konec tabulky ?
         je        lowca3                   ; je konec tabulky
         cmp       cs:[bx+1],al             ; je hledanò znak ?
         jne       lowca2                   ; test dal®°ho znaku
         mov       al,cs:[bx]               ; p©evedenò znak
lowca3:  pop       bx
lowca4:  or        al,al
lowca5:  ret

; -----------------------------------------------------------------------------
public   highcase0
highcase0:                                ;* korekce AL na velkÇ p°smeno
                                            ; VSTUP: AL=znak k p©evodu

         cmp       al,"a"                   ; je znak men®° neë "a" ?
         jb        highcas8                 ; nen° malÇ p°smeno
         cmp       al,"z"                   ; je znak vàt®° neë "z" ?
         ja        highcas8                 ; nen° malÇ p°smeno
         sub       al,32                    ; korekce na velkÇ p°smeno
highcas8:ret


public   highcase
highcase:                                 ;* korekce AL na velkÇ p°smeno
                                            ; VSTUP: AL=znak k p©evodu

         cmp       al,"a"                   ; je znak men®° neë "a" ?
         jb        highc5                   ; nen° malÇ p°smeno
         cmp       al,"z"                   ; je znak vàt®° neë "z" ?
         ja        highc1                   ; nen° malÇ p°smeno
         sub       al,32                    ; korekce na velkÇ p°smeno
         ret

highc1:  test      byte ptr cs:[config],1   ; je vypnut° áe®tiny ?
         jnz       highc4                   ; je vypnut° áe®tiny
         push      bx
         lea       bx,[upperlat-2]          ; p©evodn° tabulka LATIN 2
         test      byte ptr cs:[config],2   ; je LATIN 2 ?
         jnz       highc2                   ; je k¢d LATIN 2
         lea       bx,[upperkam-2]          ; p©evodn° tabulka KAMENICKùCH
highc2:  add       bx,2                     ; zvò®en° adresy v tabulce
         cmp       byte ptr cs:[bx],0       ; je konec tabulky ?
         je        highc3                   ; je konec tabulky
         cmp       cs:[bx],al               ; je hledanò znak ?
         jne       highc2                   ; test dal®°ho znaku
         mov       al,cs:[bx+1]             ; p©evedenò znak
highc3:  pop       bx
highc4:  or        al,al
highc5:  ret

; -----------------------------------------------------------------------------
public   transtxt
transtxt:                                   ; p©enos textu ASCIIZ
                                            ; VSTUP: DS:SI -> ES:DI
                                            ; VùSTUP: ES:DI - koncov† 0

         push      ax                       ; £schova AX
transt1: lodsb                              ; naáten° znaku k p©enosu
         stosb                              ; uloëen° znaku na vòstup
         or        al,al                    ; byl to jië koncovò bajt 0 ?
         jnz       transt1                  ; nebyla je®tà koncov† 0 - dal®°
         dec       di                       ; n†vrat ukazatele na posledn° 0
         pop       ax                       ; n†vrat AX
         ret

; -----------------------------------------------------------------------------
public   comptxt
comptxt:                                    ; porovn†n° textñ ASCIIZ
                                            ; VSTUP: DS:SI -> ES:DI
                                            ; VùSTUP: ZY=je shoda ©etàzcñ

         push      si
         push      di
         push      ax                       ; £schova AX
compt1:  cmpsb                              ; porovn†n° znakñ
         jne       compt2                   ; nen° shoda znakñ
         cmp       byte ptr ds:[si-1],0     ; byl to jië konec ?
         jne       compt1                   ; nen° konec - dal®° znak
compt2:  pop       ax                       ; n†vrat AX
         pop       di
         pop       si
         ret

; -----------------------------------------------------------------------------
public   setkonc
setkonc:                                    ; z†pis koncovky "y", "ñ"
                                            ; VSTUP: DS:SI=text á°sla
                                            ;        ES:DI=ukl†dac° adresa
         push      ax
         call      testkonc                 ; test koncovky á°sla
         or        al,al
         jz        endli3                   ; je á°slo 1
         mov       si,offset textvy11       ; koncovka á°sla 2,3,4
         dec       al
         jz        endli2                   ; je á°slo 2,3,4
         mov       si,offset textvy12       ; kocovka ostatn°ch á°sel
endli2:  call      transtxt                 ; uloëen° koncovky
endli3:  pop       ax
         ret

public   testkonc
testkonc:                                   ; test koncovky á°sla
                                            ; VSTUP: DS:SI=text á°sla
                                            ; VùSTUP: AL=0 je koncovka pro "1"
                                            ;         AL=1 koncovka pro 2,3,4
                                            ;         AL=2 ostatn° á°sla

         push      dx
         push      si
         mov       dx,"00"                  ; posledn° 2 á°slice
testkon1:call      readtest                 ; naáten° prvn°/dal®° á°slice
         jc        testkon2                 ; nen° jië dal®° á°slice
         mov       dh,dl                    ; p©edposledn° á°slice
         mov       dl,al                    ; posledn° á°slice


ifdef    ANGL
         call      readtest                 ; naáten° dal®° á°slice
         mov       al,2                     ; p©°znak jinÇho á°sla
         jnc       testkon3                 ; je v°ce á°slic
else

IFDEF    slov
         call      readtest                 ; naáten° dal®° á°slice
         mov       al,2                     ; p©°znak jinÇho á°sla
         jnc       testkon3                 ; je v°ce á°slic
ELSE
         jmp       short testkon1           ; naáten° dal®° á°slice
ENDIF

endif

testkon2:mov       al,2                     ; p©°znak jinÇho á°sla
         cmp       dh,"1"                   ; byly des°tky ?
         je        testkon3                 ; jsou mnoën† á°sla
         cmp       dl,"4"                   ; je á°slice vàt®° neë "4" ?
         ja        testkon3                 ; je á°slice vàt®° neë "4"
         cmp       dl,"0"                   ; je á°slice "0" ?
         je        testkon3                 ; je á°slice "0"
         dec       al                       ; p©°znak á°sla 2,3,4
         cmp       dl,"1"                   ; je á°slice "1" ?
         jne       testkon3                 ; nen° "1" - je 2,3,4
         dec       al                       ; p©°znak á°slice "1"
testkon3:pop       si
         pop       dx
         ret

public   readtest
readtest:                                   ; áten° á°slice p©i testu
                                            ; VùSTUP: CY=nen° platn† á°slice

         lodsb                              ; naáten° dal®° á°slice
         cmp       al,"."                   ; je oddàlovac° teáka ?
         je        readtest
         or        al,al                    ; je jië konec textu ?
         stc
         jz        readtst1
         cmp       al,"0"                   ; je á°slice ?
         jb        readtst1                 ; nen° á°slice
         cmp       al,"9"+1                 ; je á°slice ?
         cmc                                ; CY=nen° á°slice
readtst1:ret

; -----------------------------------------------------------------------------
public   center
center:                                     ; centrov†n° textu ASCIIZ
                                            ; VSTUP: DS:SI=adresa textu
                                            ;        CL=max. ®°©ka ©†dku
                                            ;        DL=pozice kurzoru na ©†dku
                                            ; VùSTUP: CL=offset zaá†tku textu
                                            ;         DL=nov† pozice kurzoru

         push      ax                       ; £schova AX
         push      si                       ; £schova SI
center1: lodsb                              ; naáten° znaku z bufferu
         or        al,al                    ; je konec textu ?
         jz        center2                  ; je jië konec textu
         cmp       al,31                    ; je konec ©†dku ?
         je        center2                  ; je konec ©†dku
         jb        center1                  ; je ©°dic° znak <31 - dal®° znak
         dec       cl                       ; sn°ëen° á°taáe znakñ
         jnz       center1                  ; nen° je®tà 0 - dal®° znak
center2: shr       cl,1                     ; CL/2 - offset od zaá†tku
         add       dl,cl                    ; zvò®en° pozice kurzoru
         pop       si                       ; n†vrat SI
         pop       ax                       ; n†vrat AX
         ret
; -----------------------------------------------------------------------------
public   lensi0
lensi0:                                   ;* zji®tàn° dÇlky ©etàzce ASCIIZ DS:SI
                                            ; VSTUP: DS:SI=adresa ©etàzce
                                            ; VùSTUP: AX=dÇlka ©etàzce
                                            ;         ZY=©etàzec je nulovò

         push      si
         xor       ax,ax                    ; á°taá dÇlky ©etàzce
lensi01: cmp       byte ptr ds:[si],0       ; je jië konec ©etàzce ?
         je        lensi04                  ; je konec ©etàzce
         inc       si                       ; zvò®en° ukazatele textu
         inc       al                       ; zvò®en° á°taáe dÇlky
         jnz       lensi01                  ; dal®° znak
         dec       al                       ; omezen° na 255
lensi04: or        al,al
         pop       si
         ret
; -----------------------------------------------------------------------------
public   lensi
lensi:                                    ;* zji®tàn° dÇlky ©etàzce ASCIIZ DS:SI
                                            ; VSTUP: DS:SI=adresa ©etàzce
                                            ; VùSTUP: AL=dÇlka ©etàzce
                                            ;         CY=p©eteáen° (AL=255)

         push      si
         xor       ax,ax                    ; nejvàt®° nalezen† dÇlka
lens1:   cmp       byte ptr ds:[si],0       ; je jië konec ©etàzce ?
         je        lens3                    ; je konec ©etàzce
         inc       si                       ; zvò®en° ukazatele textu
         cmp       byte ptr ds:[si-1],31    ; je konec ©†dku ?
         jb        lens1                    ; je ©°dic° znak - ignorov†n°
         jne       lens2                    ; nen° konec ©†dku
         cmp       ah,al                    ; je vàt®° neë nalezenò ©†dek ?
         jbe       lens11                   ; nen° vàt®°
         mov       al,ah                    ; nov† nalezen† dÇlka
lens11:  xor       ah,ah                    ; nov† hodnota á°taáe dÇlky
         jmp       short lens1
lens2:   inc       ah                       ; zvò®en° á°taáe znakñ ©etàzce
         jnz       lens1                    ; test dal®°ho znaku
         dec       ah                       ; AH <- 255 p©eteáen° textu
         mov       al,ah
         stc                                ; p©°znak p©eteáen°
lens3:   cmp       ah,al                    ; je vàt®° neë nalezenò ©†dek ?
         jbe       lens4                    ; nen° vàt®°
         mov       al,ah                    ; nov† nalezen† dÇlka
lens4:   pop       si
         ret
; -----------------------------------------------------------------------------
public   lendi

lendi:                                    ;* zji®tàn° dÇlky ©etàzce ASCIIZ DS:DI
                                            ; VSTUP: ES:DI=adresa ©etàzce
                                            ; VùSTUP: AL=dÇlka ©etàzce
                                            ;         CY=p©eteáen° (AL=255)

         push      di
         xor       ax,ax                    ; nejvàt®° nalezen† dÇlka
lend1:   cmp       byte ptr ds:[di],0       ; je jië konec ©etàzce ?
         je        lend3                    ; je konec ©etàzce
         inc       di                       ; zvò®en° ukazatele textu
         cmp       byte ptr ds:[di-1],31    ; je konec ©†dku ?
         jb        lend1                    ; je ©°dic° znak - ignorov†n°
         jne       lend2                    ; nen° konec ©†dku
         cmp       ah,al                    ; je vàt®° neë nalezenò ©†dek ?
         jbe       lend11                   ; nen° vàt®°
         mov       al,ah                    ; nov† nalezen† dÇlka
lend11:  xor       ah,ah                    ; nov† hodnota á°taáe dÇlky
         jmp       short lend1
lend2:   inc       ah                       ; zvò®en° á°taáe znakñ ©etàzce
         jnz       lend1                    ; test dal®°ho znaku
         dec       ah                       ; AH <- 255 p©eteáen° textu
         mov       al,ah
         stc                                ; p©°znak p©eteáen°
lend3:   cmp       ah,al                    ; je vàt®° neë nalezenò ©†dek ?
         jbe       lend4                    ; nen° vàt®°
         mov       al,ah                    ; nov† nalezen† dÇlka
lend4:   pop       di
         ret
; -----------------------------------------------------------------------------
;                            Zobrazen° á°sel
; -----------------------------------------------------------------------------
public   tisknm2s,tisknm20,tisknm21
tisknm2s:                                   ; tisk á°sla 2 á°slice s mezerami
                                            ; VSTUP: AL=á°slo
                                            ;        DX=pozice

         call      setspc                   ; nastaven° m¢du tisku mezer
         jmp       short tisknm21

tisknm20:                                   ; tisk á°sla 2 á°slice s nulami
                                            ; VSTUP: AL=á°slo
                                            ;        DX=pozice

         call      setnul                   ; nastaven° m¢du tisku mezer
tisknm21:push      di
         push      si
         push      bx
         push      cx
         push      ds
         push      es
         push      cs
         pop       ds
         push      cs
         pop       es
         push      dx                       ; pozice
         mov       di,offset bufwin2        ; tiskovò buffer
         xor       ah,ah
         call      deknum2                  ; dek¢dov†n° á°sla 2 á°slice
         pop       dx                       ; pozice
         mov       si,offset bufwin2        ; tiskovò buffer
         call      outtxt                   ; zobrazen° textu
         call      setfre                   ; volnò form†t tisku á°sla
         pop       es
         pop       ds
         pop       cx
         pop       bx
         pop       si
         pop       di
         ret

; -----------------------------------------------------------------------------
public   tisknm0
tisknm0:                                    ; tisk á°sla 10 á°slic zarov. vpravo
                                            ; VSTUP: BX:AX=á°slo
                                            ;        DX=pozice

         push      di
         push      si
         push      ds
         push      es
         push      cs
         pop       ds
         push      cs
         pop       es
         push      dx                       ; pozice
         call      setspc                   ; nastaven° m¢du tisku mezer
         mov       dx,bx                    ; vy®®° slovo á°sla
         mov       di,offset bufwin2        ; tiskovò buffer
         call      deknumx                  ; p©ek¢dov†n° á°sla s omezen°m
         pop       dx                       ; pozice
         mov       si,offset bufwin2        ; tiskovò buffer
         call      outtxt                   ; zobrazen° textu
         call      setfre                   ; volnò form†t tisku á°sla
         pop       es
         pop       ds
         pop       si
         pop       di
         ret

; -----------------------------------------------------------------------------
public   setspc,setnul,setfre
setspc:                                   ;* zapnut° tisku mezer p©ed á°slem

         and       byte ptr cs:[parnum],0fdh ; vypnut° tisku nul
         or        byte ptr cs:[parnum],2   ; zapnut° tisku mezer
         ret


setnul:                                   ;* zapnut° tisku nul p©ed á°slem

         and       byte ptr cs:[parnum],0fbh ; vypnut° tisku mezer
         or        byte ptr cs:[parnum],4   ; zapnut° tisku nul
         ret


setfre:                                   ;* zapnut° volnÇho form†tu á°sla

         and       byte ptr cs:[parnum],0f9h ; vypnut° tisku mezer a nul
         ret

; -----------------------------------------------------------------------------
public   deknumx,deknmx1,deknmx2,deknmx3,deknmx4
deknumx:                                    ; p©ek¢dov†n° á°sla s omezen°m
                                            ; VSTUP: (DX:)AX=á°slo k p©ek¢dov†n°
                                            ;        ES:DI=adr. k uloëen° textu
                                            ; VùSTUP: AL=poáet znakñ ©etàzce
                                            ; zniáenÇ registry: AX,BX,CX,DX

         cmp       dx,5f5h                  ; vy®®° slovo á°sla 100 000 000
         jne       deknmx1                  ; nen° shoda
         cmp       ax,0e100h                ; nië®° slovo á°sla 100 000 000
deknmx1: jnb       deknmx2                  ; je á°slo 100 000 000 nebo vy®®°
         jmp       deknum8                  ; dek¢dov†n° á°sla 8 á°slic

deknmx2: cmp       dx,3b9ah                 ; vy®®° slovo á°sla 1000 000 000
         jne       deknmx3                  ; nen° shoda
         cmp       ax,0ca00h                ; nië®° slovo á°sla 1000 000 000
deknmx3: jnb       deknmx4                  ; je á°slo 1000 000 000 nebo vy®®°
         or        byte ptr cs:[parnum],10h ; z†kaz tisku teáku tis°cñ
         call      deknum9                  ; dek¢dov†n° á°sla 9 á°slic
         and       byte ptr cs:[parnum],0efh; povolen° tisku teáky tis°cñ
         ret

deknmx4: or        byte ptr cs:[parnum],1   ; z†kaz tisku teáek
         call      deknum0                  ; dek¢dov†n° á°sla 10 á°slic
         and       byte ptr cs:[parnum],0feh ; povolen° tisku teáek
         ret

; -----------------------------------------------------------------------------
public   deknum,deknum0,deknum9,deknum8,deknum7,deknum6,deknum5,deknum4
public   deknum41,deknum3,deknum2
deknum:                                   ;* p©evod á°sla na dekadickÇ á°slo
                                            ; VSTUP: (DX:)AX=á°slo k p©ek¢dov†n°
                                            ;        ES:DI=adr. k uloëen° textu
                                            ; VùSTUP: AL=poáet znakñ ©etàzce
                                            ; zniáenÇ registry: AX,BX,CX,DX

deknum0:                                  ;* dek¢dov†n° 10 á°slic
         mov       bx,3b9ah                 ; vy®®° slovo á°sla 1000 000 000
         mov       cx,0ca00h                ; nië®° slovo á°sla 1000 000 000
         call      deknm0                   ; dek¢dov†n° 1 á°slice
deknum9:                                  ;* dek¢dov†n° 9 á°slic
         mov       bx,5f5h                  ; vy®®° slovo á°sla 100 000 000
         mov       cx,0e100h                ; nië®° slovo á°sla 100 000 000
         call      deknm0                   ; dek¢dov†n° 1 á°slice
deknum8:                                  ;* dek¢dov†n° 8 á°slic
         mov       bl,98h                   ; vy®®° slovo á°sla 10 000 000
         mov       cx,9680h                 ; nië®° slovo á°sla 10 000 000
         call      deknm02                  ; dek¢dov†n° 1 á°slice
deknum7:                                  ;* dek¢dov†n° 7 á°slic
         mov       bl,0fh                   ; vy®®° slovo á°sla 1 000 000
         mov       cx,4240h                 ; nië®° slovo á°sla 1 000 000
         call      deknm02                  ; dek¢dov†n° 1 á°slice
         call      deknm8                   ; oddàlovac° teáka
deknum6:                                  ;* dek¢dov†n° 6 á°slic
         mov       bl,1                     ; vy®®° slovo á°sla 100 000
         mov       cx,86a0h                 ; nië®° slovo á°sla 100 000
         call      deknm02                  ; dek¢dov†n° 1 á°slice
deknum5:                                  ;* dek¢dov†n° 5 á°slic
         mov       cx,10000                 ; nië®° slovo á°sla 10 000
         call      deknm01                  ; dek¢dov†n° 1 á°slice
deknum4:                                  ;* dek¢dov†n° 4 á°slic
         mov       cx,1000                  ; nië®° slovo á°sla 1 000
         call      deknm00                  ; dek¢dov†n° 1 á°slice
         test      byte ptr cs:[parnum],10h ; je z†kaz tisku tis°cñ ?
         jz        deknum41                 ; nen° z†kaz tisku tis°cñ
         or        byte ptr cs:[parnum],8   ; p©echodnò z†kaz tisku teáky
deknum41:call      deknm8                   ; oddàlovac° teáka
deknum3:                                  ;* dek¢dov†n° 3 á°slic
         mov       cx,100                   ; nië®° slovo á°sla 100
         call      deknm00                  ; dek¢dov†n° 1 á°slice
deknum2:                                  ;* dek¢dov†n° 2 á°slic
         mov       cx,10                    ; nië®° slovo á°sla 10
         call      deknm00                  ; dek¢dov†n° 1 á°slice
                                          ;* dek¢dov†n° 1 á°slice
         add       al,"0"                   ; korekce na á°slici
         stosb                              ; uloëen° posledn° á°slice
         xor       al,al
         stosb                              ; uloëen° ukonáovac°ho bajtu 0
         dec       di                       ; ukazatel na posledn° bajt 0
         and       byte ptr cs:[parnum],0f7h; zru®en° p©echodnÇho z†kazu teáky
         xchg      al,cs:[citdek]           ; vynulov†n° á°taáe á°slic
         inc       al                       ; poáet znakñ dek¢dovanÇho textu
         ret

public   deknm00,deknm01,deknm02,deknm0,deknm1,deknm2,deknm21,deknm3

                                          ;* dek¢dov†n° á°slice 32-bit. á°sla
                                            ; VSTUP: DX:AX=á°slo
                                            ;        BX:CX=dàlitel á°sla
                                            ;        ES:DI=adr. k uloëen° textu

deknm00: xor       dx,dx                    ; DX <- 0
deknm01: xor       bl,bl                    ; BL <- 0
deknm02: xor       bh,bh                    ; BH <- 0
deknm0:  mov       byte ptr cs:[citnum],2fh ; inicializace á°taáe á°slice
deknm1:  inc       byte ptr cs:[citnum]     ; zvò®en° á°taáe á°slice
         sub       ax,cx                    ; odeáten° nië®°ho slova á°sla
         sbb       dx,bx                    ; odeáten° vy®®°ho slova á°sla
         jnc       deknm1                   ; nen° je®tà p©eteáen°
         add       ax,cx                    ; n†vrat nië®°ho slova á°sla
         adc       dx,bx                    ; n†vrat vy®®°ho slova á°sla
         cmp       byte ptr cs:[citnum],"0" ; je á°slice 0 ?
         jne       deknm2                   ; nen° á°slice 0 - dek¢dov†n°
         cmp       byte ptr cs:[citdek],0   ; byla jië nàjak† á°slice ?
         jne       deknm2                   ; byla jië nàjak† á°slice
         test      byte ptr cs:[parnum],4   ; je tisku nul ?
         jnz       deknm2                   ; je tisk nul
         mov       byte ptr cs:[citnum]," " ; n†hradn° znak mezery
         test      byte ptr cs:[parnum],2   ; je tisk mezer ?
         jz        deknm3                   ; nen° tisk mezer
         jmp       short deknm21
deknm2:  inc       byte ptr cs:[citdek]     ; zvò®en° á°taáe á°slic
deknm21: push      ax                       ; £schova AX
         mov       al,cs:[citnum]           ; dek¢dovan† á°slice
         stosb                              ; uloëen° á°slice
         pop       ax                       ; n†vrat AX
deknm3:  ret

public   deknm8,deknm81,deknm9
deknm8:
         push      ax
         mov       al,"."                   ; oddàlovac° teáka
         test      byte ptr cs:[parnum],9   ; je povolenò tisk teáky ?
         jnz       deknm9                   ; tisk nen° povolenò
         cmp       byte ptr cs:[citdek],0   ; byla jië platn† á°slice ?
         jne       deknm81                  ; byla jië platn† á°slice
         test      byte ptr cs:[parnum],3   ; je volnò form†t ?
         jz        deknm9                   ; je volnò form†t
         test      byte ptr cs:[parnum],4   ; je tisk nul ?
         jnz       deknm81                  ; je tisk nul
         mov       al," "                   ; n†hradn° oddàlovac° mezera
deknm81: mov       byte ptr es:[di],al      ; oddàlovac° znak
         inc       di                       ; zvò®en° ukl†dac° adresy
         cmp       byte ptr cs:[citdek],0   ; je jië nàjak† á°slice ?
         je        deknm9                   ; nen° je®tà ë†dn† á°slice
         inc       byte ptr cs:[citdek]     ; zvò®en° á°taáe á°slic (znakñ)
deknm9:  pop       ax
         ret

; -----------------------------------------------------------------------------
;                        Obsluha segmentace pamàti
; -----------------------------------------------------------------------------
public   iniedis
iniedis:                                  ;* inicializace segmentu editoru
                                            ; VùSTUP: CY=nen° voln† pamàü
         push      bx
         push      ax
         mov       word ptr cs:[editnum],0  ; zru®en° obsahu pamàti
         call      createseg                ; vytvo©en° novÇho segmentu
         jc        iniedis2                 ; nen° voln† poloëka
         mov       cs:[editseg],al          ; uloëen° á°sla segmentu
         call      getmax                   ; poskytnut° max. velikosti segmentu
         jc        iniedis2                 ; nen° voln† pamàü
         mov       cs:[editmax],bx          ; maxim†ln° velikost bufferu
         call      modiseg                  ; modifikace segmentu na max. velik.
iniedis2:pop       ax
         pop       bx
         ret
; -----------------------------------------------------------------------------
public   aktedis
aktedis:                                  ;* aktual. segmentu s edit. soub.
                                            ; VùSTUP: DS=adresa segmentu
         pushf
         push      bx
         push      ax
         mov       al,cs:[editseg]          ; segment se souborem
;         or        al,al                    ; je segment definovanò ?
;         jz        aktedis1                 ; nen° definovanò
         call      getseg                   ; poskytnut° adresy segmentu
         mov       cs:[topseged],bx         ; adresa segmentu editoru
aktedis1:pop       ax
         pop       bx
         popf
         ret
; -----------------------------------------------------------------------------
public   deledis
deledis:                                  ;* zru®en° segmentu s edit. soub.

         push      ax
         mov       al,cs:[editseg]          ; segment se souborem
         call      delseg                   ; poskytnut° adresy segmentu
         mov       byte ptr cs:[editseg],0  ; zru®en° segmentu
         mov       word ptr cs:[editnum],0  ; zru®en° obsahu pamàti
         pop       ax
         ret
; -----------------------------------------------------------------------------
public   getmax

getmax:                                   ;* poskytnut° maxim.velikosti segmentu
                                            ; VùSTUP: BX=maxim. velikost segm.
                                            ;         CY=segment < 16 B

         push      cx
         mov       bx,ds:[segend]           ; segment konce pamàti
         sub       bx,2                     ; rezerva
         sub       bx,ds:[topseg]           ; voln† pamàü
         jnc       getmax1                  ; nen° p©eteáen°
         xor       bx,bx                    ; BX <- 0 (nen° pamàü)
getmax1: cmp       bx,0fe0h                 ; je vàt®° neë 64 KB ?
         jb        getmax2                  ; nen° vàt®° neë 64 KB
         mov       bx,0fe0h                 ; omezen° na 64 KB
getmax2: mov       cl,4
         shl       bx,cl                    ; voln† kapacita (v bajtech)
         cmp       bx,10h                   ; porovn†n° s minim†ln° velikost°
         pop       cx
         ret
; -----------------------------------------------------------------------------
public   createseg

createseg:                                ;* vytvo©en° novÇho segmentu dat
                                            ; VùSTUP: AL=á°slo p©idàl. segmentu
                                            ;         CY=nen° voln† poloëka

         push      cx
         push      bx                       ; £schova BX
         xor       al,al                    ; á°taá poloëek
         mov       bx,offset seznseg        ; adresa seznamu segmentñ
         mov       cx,offset seznseg0       ; konec seznamu
         sub       cx,bx                    ; dÇlka seznamu
         shr       cx,1                     ; poáet poloëek v seznamu
creats1: cmp       word ptr cs:[bx],0       ; je voln† poloëka ?
         jz        creats2                  ; nalezena voln† poloëka
         inc       al                       ; zvò®en° á°sla poloëky
         add       bx,2                     ; zvò®en° adresy v tabulce
         loop      creats1                  ; test dal®° poloëky
         stc                                ; p©°znak chyby - nen° ë†dn† voln†
         jmp       short creats3            ; n†vrat s chybou
creats2: mov       cx,cs:[topseg]           ; segment zaá†tku volnÇ pamàti
         mov       cs:[bx],cx               ; nastaven° novÇho segmentu
         mov       bx,1                     ; minim†ln° dÇlka segmentu
         call      modiseg                  ; modifikace velikosti segmentu
creats3: pop       bx                       ; n†vrat BX
         pop       cx                       ; n†vrat
         ret

; -----------------------------------------------------------------------------
public   delseg

delseg:                                   ;* zru®en° poloëky segmentu
                                            ; VSTUP: AL=á°slo ru®enÇho segmentu

         push      bx                       ; £schova BX
         xor       bx,bx                    ; novò konec segmentu = 0
         call      modiseg0                 ; modifikace segmentu na 0
         mov       bl,al                    ; á°slo ru®enÇho segmentu
         add       bx,bx                    ; á°slo segmentu * 2
         add       bx,offset seznseg        ; adresa poloëky segmentu
         mov       word ptr cs:[bx],0       ; vynulov†n° poloëky
         pop       bx                       ; n†vrat BX
         ret

; -----------------------------------------------------------------------------
public   getseg

getseg:                                   ;* poskytnut° adresy segmentu
                                            ; VSTUP: AL=á°slo segmentu
                                            ; VùSTUP: BX=adresa segmentu

         xor       bh,bh                    ; BH <- 0
         mov       bl,al                    ; á°slo segmentu v tabulce
         add       bx,bx                    ; á°slo segmentu * 2
         add       bx,offset seznseg        ; adresa poloëky v seznamu
         mov       bx,cs:[bx]               ; p©eáten° adresy segmentu
         ret

; -----------------------------------------------------------------------------
public   getssize

getssize:                                 ;* poskytnut° velikosti segmentu
                                            ; VSTUP: AL=á°slo segmentu
                                            ; VùSTUP: BX=velikost segmentu
         push      ax
         push      dx
         call      getseg                   ; poskytnut° adresy segmentu
         mov       dx,bx                    ; £schova adresy segmentu
         call      nextseg                  ; nalezen° n†sleduj°c°ho segmentu
         mov       bx,cs:[topseg]           ; segment zaá†tku volnÇ pamàti
         jc        getssiz2                 ; nenalezen dal®° segment
         call      getseg                   ; poskytnut° adresy segmentu
getssiz2:sub       bx,dx                    ; velikost segmentu (odstavcñ)
         add       bx,bx
         add       bx,bx
         add       bx,bx
         add       bx,bx                    ; skuteán† dÇlka segmentu
         pop       dx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   nextseg

nextseg:                                  ;* nalezen° n†sleduj°c°ho segmentu
                                            ; VSTUP: AL=á°slo segmentu
                                            ; VùSTUP: AL=n†sled. segment (CN)
                                            ;         CY=nen° jië dal®° segment

         push      bx
         push      cx
         push      dx
         push      si
         call      getseg                   ; poskytnut° adresy segmentu BX
         lea       si,[seznseg]             ; seznam segmentñ
         xor       ah,ah                    ; á°taá á°sla poloëky
         mov       dx,0ffffh                ; vòchoz° minim†ln° adresa segmentu
         mov       cx,offset seznseg0       ; konec seznamu
         sub       cx,offset seznseg        ; dÇlka seznamu
         shr       cx,1                     ; poáet poloëek v seznamu
nextseg1:cmp       cs:[si],dx               ; je vàt®° poloëka neë nalezen† ?
         jae       nextseg2                 ; nen° to men®° poloëka
         cmp       cs:[si],bx               ; je z†rove§ vàt®° neë testovan† ?
         jbe       nextseg2                 ; nen° vàt®°
         mov       dx,cs:[si]               ; nov† nejblië®° poloëka
         mov       al,ah                    ; novÇ á°slo segmentu
nextseg2:add       si,2                     ; zvò®en° ukazatele v bufferu
         inc       ah                       ; zvò®en° á°sla segmentu
         loop      nextseg1                 ; testov†n° dal®° poloëky
         cmp       dx,0ffffh                ; byla nalezena nàjak† poloëka ?
         cmc                                ; CY=poloëka nenalezena
         pop       si
         pop       dx
         pop       cx
         pop       bx
         ret

; -----------------------------------------------------------------------------
public   predseg

predseg:                                  ;* nalezen° p©edch†zej°c°ho segmentu
                                            ; VSTUP: AL=á°slo segmentu
                                            ; VùSTUP: AL=p©edch†z. segment (CN)
                                            ;         CY=nen° jië dal®° segment

         push      bx
         push      cx
         push      dx
         push      si
         call      getseg                   ; poskytnut° adresy segmentu
         lea       si,[seznseg]             ; seznam segmentñ
         xor       ah,ah                    ; ukazatel á°sla poloëky
         xor       dx,dx                    ; vòchoz° minim†ln° adresa segmentu
         mov       cx,offset seznseg0       ; konec seznamu
         sub       cx,offset seznseg        ; dÇlka seznamu
         shr       cx,1                     ; poáet poloëek v seznamu
predseg1:cmp       cs:[si],dx               ; je men®° poloëka neë nalezen† ?
         jbe       predseg2                 ; nen° to vàt®° poloëka
         cmp       cs:[si],bx               ; je z†rove§ men®° neë testovan† ?
         jae       predseg2                 ; nen° men®°
         mov       dx,cs:[si]               ; nov† nejblië®° poloëka
         mov       al,ah
predseg2:add       si,2                     ; zvò®en° ukazatele v bufferu
         inc       ah
         loop      predseg1                 ; testov†n° dal®° poloëky
         cmp       dx,1                     ; byla nalezena nàjak† poloëka ?
         pop       si
         pop       dx
         pop       cx
         pop       bx
         ret

; -----------------------------------------------------------------------------
public   modiseg,modiseg0

modiseg:                                  ;* modifikace segmentu s ochranou
         push      bx
         or        bx,bx
         jnz       modisg01
         inc       bx                       ; rezerva
modisg01:call      modiseg0
         pop       bx
         ret

modiseg0:                                 ;* modifikace velikosti segmentu
                                          ;* (prov†d° se po n†sobc°ch 256 B)
                                            ; VSTUP: AL=á°slo segmentu
                                            ;        BX=nov† velikost segmentu
                                            ; VùSTUP: CY=nedostatek pamàti
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di

         add       bx,255                   ; zaokrouhlen° na n†sobek 256
         jnc       modisegc                 ; nen° p©eteáen°
         jmp       modisega                 ; p©eteáen°
modisegc:xor       bl,bl                    ; BL <- 0; zñstane pouze vy®®° bajt
         mov       dx,bx                    ; poëadovan† velikost segmentu
         call      getssize                 ; poskytnut° velikosti segmentu
         sub       bx,dx                    ; porovn†n° vy®®°ch slov velikost°
         mov       dx,bx                    ; £schova posunu
         ja        modiseg1                 ; poëadov†no sn°ëen° velikosti
         jc        modiseg4                 ; poëadov†no zvò®en° velikosti
         jmp       modiseg9                 ; zmàny jsou v ©†du 256 bajtñ
modiseg1:                                 ;* je sn°ëen° velikosti segmentu
         shr       dx,1
         shr       dx,1
         shr       dx,1
         shr       dx,1                     ; posun segmentñ v odstavc°ch
modiseg2:call      nextseg                  ; n†sleduj°c° segment
         jnc       modiseg8                 ; je je®tà dal®° segment
         sub       word ptr cs:[topseg],dx  ; sn°ëen° zaá†tku volnÇ pamàti
         jmp       modiseg9                 ; nen° jië dal®° segment
modiseg8:call      getseg                   ; poskytnut° adresy segmentu
         mov       cx,bx                    ; £schova adresy segmentu
         call      getssize                 ; poskytnut° velikosti segmentu
         xchg      cx,bx                    ; BX<-adresa segmentu, CX<-velikost
         push      ds                       ; £schova DS
         push      es                       ; £schova ES
         mov       ds,bx                    ; souáasn† adresa segmentu
         sub       bx,dx                    ; nov† adresa segmentu (sn°ëen†)
         mov       es,bx                    ; nov† adresa segmentu (sn°ëen†)
         xor       si,si                    ; offset zdrojovÇ adresy
         xor       di,di                    ; offset c°lovÇ adresy
         rep       movsb                    ; p©enos obsahu segmentu
         pop       es                       ; n†vrat ES
         pop       ds                       ; n†vrat DS
         mov       bl,al                    ; á°slo segmentu
         xor       bh,bh                    ; BH <- 0
         add       bx,bx                    ; á°slo segmentu * 2
         add       bx,offset seznseg        ; adresa poloëky segmentu
         sub       word ptr cs:[bx],dx      ; sn°ëen° adresy segmentu
         jmp       short modiseg2           ; p©esun dal®°ho segmentu

modiseg4:                                 ;* je zvò®en° velikosti segmentu
         neg       dx                       ; posun segmentu
         shr       dx,1
         shr       dx,1
         shr       dx,1
         shr       dx,1                     ; posun segmentñ v odstavc°ch
                                          ;* zjist° se, kolik segmentñ n†sleduje
         xor       cx,cx                    ; á°taá zbylòch segmentñ
modiseg5:inc       cx                       ; zvò®en° á°taáe segmentñ
         call      nextseg                  ; n†sleduj°c° segment
         jnc       modiseg5                 ; nalezen° posledn°ho segmentu
         dec       cx                       ; poáet n†sleduj°c°ch segmentñ
                                          ;* nastaven° novÇho konce pamàti
modiseg6:push      ax                       ; £schova á°sla segmentu
         push      cx                       ; £schova á°taáe segmentñ
         call      getseg                   ; poskytnut° adresy segmentu
         mov       cx,bx                    ; adresa segmentu
         call      getssize                 ; poskytnut° velikosti segmentu
         xchg      cx,bx                    ; BX<-adresa segmentu, CX<-velikost
         mov       ax,cx                    ; velikost segmentu
         add       ax,15                    ; zaokrouhlen° na odstavec
         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; velikost segmentu v odstavc°ch
         add       ax,bx                    ; pñvodn° adresa konce segmentu
         add       ax,dx                    ; nov† adresa konce segmentu
         cmp       ax,cs:[segend]           ; kontrola p©ekroáen° konce
         ja        modisg61                 ; p©ekroáen° konce pamàti
         mov       cs:[topseg],ax           ; novò zaá†tek volnÇ pamàti
modisg61:pop       cx
         pop       ax
         jbe       modiseg7                 ; nen° je®tà p©ekroáen° konce
         stc                                ; p©°znak chyby
         jmp       short modisega           ; n†vrat s chybou
                                          ;* p©esunut° v®ech segmentñ
modiseg7:jcxz      modiseg9                 ; nen†sleduje ë†dnò segment
         push      cx                       ; á°taá segmentñ
         push      ds                       ; £schova DS
         push      es                       ; £schova ES
         call      getseg                   ; poskytnut° adresy segmentu
         mov       cx,bx                    ; adresa segmentu
         call      getssize                 ; poskytnut° velikosti segmentu
         xchg      cx,bx                    ; BX<-adresa segmentu, CX<-velikost
         mov       ds,bx                    ; souáasn† adresa segmentu
         add       bx,dx                    ; nov† adresa segmentu (zvò®en†)
         mov       es,bx                    ; nov† adresa segmentu
         mov       si,cx                    ; dÇlka segmentu
         dec       si                       ; offset posledn°ho bajtu
         mov       di,si                    ; offset posledn°ho bajtu
         std                                ; smàr p©enosu dolñ
         rep       movsb                    ; posun obsahu segmentu
         cld                                ; smàr p©enosu nahoru
         pop       es
         pop       ds
         pop       cx
         mov       bl,al                    ; á°slo segmentu
         xor       bh,bh                    ; BH <- 0
         add       bx,bx                    ; á°slo segmentu * 2
         add       bx,offset seznseg        ; adresa poloëky segmentu
         add       word ptr cs:[bx],dx      ; zvò®en° adresy segmentu
         call      predseg                  ; á°slo p©edch†zej°c°ho segmentu
         loop      modiseg7                 ; p©esun dal®°ho segmentu
modiseg9:clc                                ; p©°znak - operace OK
modisega:pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         call      aktedis                  ; aktualizace segmentu editoru
         ret

; *****************************************************************************
;
;                      Podprogramy pro diskovÇ operace
;
; *****************************************************************************
public   testdev
testdev:                                  ;* test za©°zen°
                                            ; VSTUP: BX=identifik†tor za©°zen°
                                            ; VùSTUP: CY=chyba
                                            ;         NZ=je znakovÇ za©°zen°
         push      ax
         push      dx
         mov       ax,4400h
         int       21h                      ; poskytnut° informac° o za©°zen°
         jc        testdev2                 ; chyba
         test      dl,80h                   ; je to znakovÇ za©°zen° ?
         jz        testdev2                 ; je diskovÇ za©°zen°
         xor       dh,dh                    ; DH <- 0
         or        dl,20h                   ; nastaven° bin†rn°ho m¢du
         mov       ax,4401h
         int       21h                      ; nastaven° bin†rn°ho m¢du
         or        dx,dx                    ; p©°znaky NC, NZ
testdev2:pop       dx
         pop       ax
         ret
; -----------------------------------------------------------------------------
public   loadpath
loadpath:                                 ;* naáten° cesty aktivn°ho adres†©e
                                            ; VSTUP: ES:DI=ukl†dac° adresa

         push      ax                       ; £schova AX
         push      dx                       ; £schova DX
         push      si                       ; £schova SI
         push      di                       ; £schova DI
         push      ds                       ; £schova DS
         mov       ah,19h                   ; funkce poskytnut° aktivn°ho disku
         int       21h                      ; poskytnut° aktivn°ho disku
         inc       al                       ; á°slo disku + 1
         mov       dl,al                    ; £schova á°sla disku
         add       al,40h                   ; korekce disku na znak ASCII
         stosb                              ; uloëen° oznaáen° disku
         mov       ax,"\:"                  ; text ":\"
         stosw                              ; uloëen° textu ":\"
         mov       si,di                    ; zaá†tek oznaáen° cesty
         xor       al,al
         stosb
         push      es                       ; ES -> stack
         pop       ds                       ; DS <- ES segment s bufferem
         mov       ah,47h                   ; funkce poskytnut° aktiv. adres†©e
         int       21h                      ; poskytnut° aktivn°ho adres†©e
         pop       ds                       ; n†vrat DS
         pop       di                       ; n†vrat DI
         pop       si                       ; n†vrat SI
         pop       dx                       ; n†vrat DX
         pop       ax                       ; n†vrat AX
         ret

; -----------------------------------------------------------------------------
public   aktdir
aktdir:                                   ;* nastaven° aktivn°ho adres†©e
                                            ; VSTUP: DS:SI=p©°stupov† cesta
                                            ; VùSTUP: NZ=diskov† chyba
                                            ;         CY=adres†© nenalezen

         push      dx                       ; £schova DX
         push      ax                       ; £schova AX
         cmp       byte ptr ds:[si],0       ; je zad†n adres†© ?
         je        aktdir2                  ; adres†© nen° zad†n
         cmp       byte ptr ds:[si+1],":"   ; je ud†n disk ?
         jne       aktdir1                  ; nen° ud†n disk
         mov       al,ds:[si]               ; oznaáen° disku
         call      highcase                 ; p©evod na velkÇ p°smeno
         sub       al,"A"                   ; p©evod na á°slo disku
         mov       dl,al                    ; poëadovanò disk
         mov       ah,0eh                   ; funkce nastaven° disku
         int       21h                      ; nastaven° aktivn°ho disku
         mov       ah,19h
         int       21h                      ; poskytnut° aktivn°ho disku
         cmp       al,dl                    ; souhlas° nastavenò disk ?
         stc
         jne       aktdir2                  ; chyba zad†n° disku
         cmp       byte ptr ds:[si+2],0     ; je zad†n adres†© ?
         je        aktdir2                  ; nen° zad†n adres†© - OK
aktdir1: cmp       byte ptr ds:[si],0       ; je zad†n adres†© ?
         je        aktdir2                  ; nen° zad†n adres†© - OK
         mov       dx,si                    ; p©°stupov† cesta k adres†©i
         mov       ah,3bh                   ; funkce nastaven° aktiv. adres†©e
         int       21h                      ; nastaven° aktivn°ho adres†©e
aktdir2: pop       ax                       ; n†vrat AX
         pop       dx                       ; n†vrat DX
         ret

; -----------------------------------------------------------------------------
public   dekfile
dekfile:                                    ; zak¢dov†n° jmÇna souboru
                                            ; VSTUP: DS:SI -> ES:DI
         push      cx
         push      bx
         push      si
         lodsb                              ; atributy poloëky
         mov       bl,al                    ; £schova atributñ poloëky

                                          ;* p©enos v®ech znakñ jmÇna
         mov       cx,8
dekfil1: lodsb
         test      bl,16h                   ; je adres†© nebo skrytò/systÇmovò ?
         jnz       dekfl11                  ; je adres†© nebo skrytò/systÇmovò
         call      lowcase0                 ; p©evod na malÇ p°smeno
dekfl11: and       bl,0f9h                  ; zru®en° atributñ SYS/HID
         stosb                              ; uloëen° znaku
         loop      dekfil1                  ; dal®° znak
         mov       cl,8                     ; poáet znakñ jmÇna = 8

                                          ;* n†hrada hvàzdiákou
         cmp       word ptr es:[di-2],"??"  ; koná° jmÇno otazn°ky ?
         jne       dekfil7                  ; nekoná° otazn°ky
dekfil22:dec       di                       ; nastaven° na posledn° znak
         cmp       byte ptr es:[di],"?"     ; je otazn°k ?
         loope     dekfil22                 ; vypustàn° otazn°kñ
         je        dekfil23                 ; posledn° otazn°k se nevr†t°
         inc       di                       ; n†vrat pozice
         inc       cx                       ; n†vrat á°taáe
dekfil23:mov       al,"*"
         stosb                              ; uloëen° koncovÇ "*"
         jmp       short dekfil73

                                          ;* vypustàn° oddàlovac°ch mezer
dekfil7: dec       di                       ; nastaven° na posledn° znak
         cmp       byte ptr es:[di]," "     ; je mezera ?
         loope     dekfil7                  ; vypustàn° koncovòch mezer
         je        dekfil73                 ; posledn° mezera se nevr†t°
         inc       di                       ; n†vrat pozice
         inc       cx                       ; n†vrat á°taáe

dekfil73:                                 ;* oddàlovac° teáka
         cmp       byte ptr ds:[si-8],"."   ; je adres†© ?
         je        dekfil4                  ; neplat° teáka za jmÇnem
         cmp       word ptr ds:[si],"  "    ; je p©°pona ?
         jne       dekfilb                  ; je p©°pona
         cmp       byte ptr ds:[si+2]," "   ; je p©°pona ?
         je        dekfil4                  ; nen° p©°pona
dekfilb: mov       al,"."
         stosb

                                          ;* p©enesen° v®ech znakñ p©°pony
dekfil4: mov       cl,3
dekfil3: lodsb
         test      bl,16h                   ; je adres†© nebo skrytò/systÇmovò ?
         jnz       dekfl31                  ; je adres†© nebo skrytò/systÇmovò
         call      lowcase0                 ; p©evod na malÇ p°smeno
dekfl31: and       bl,0f9h                  ; zru®en° atributñ SYS/HID
         stosb
         loop      dekfil3
         mov       cl,3                     ; max. poáet znakñ k vypu®tàn°

                                          ;* n†hrada hvàzdiákou
         cmp       word ptr es:[di-2],"??"  ; koná° jmÇno otazn°ky ?
         jne       dekfil8                  ; nekoná° otazn°ky
dekfil52:dec       di                       ; nastaven° na posledn° znak
         cmp       byte ptr es:[di],"?"     ; je otazn°k ?
         loope     dekfil52                 ; vypustàn° otazn°kñ
         je        dekfil53                 ; posledn° otazn°k se nevr†t°
         inc       di                       ; n†vrat pozice
         inc       cx                       ; n†vrat á°taáe
dekfil53:mov       al,"*"
         stosb                              ; uloëen° koncovÇ "*"
         jmp       short dekfil83

                                          ;* vypu®tàn° koncovòch mezer
dekfil8: dec       di
         cmp       byte ptr es:[di]," "     ; je mezera ?
         loope     dekfil8                  ; vypu®tàn° koncovòch mezer
         je        dekfil83                 ; byla mezera
         inc       di                       ; n†vrat pozice
         inc       cx                       ; n†vrat á°taáe

dekfil83:
         mov       byte ptr es:[di],0       ; koncovò bajt 0
         pop       si
         pop       bx
         pop       cx
         ret

; -----------------------------------------------------------------------------
public   cmppath

cmppath:                                  ;* porovn†n° cest k oknñm
                                            ; VùSTUP: ZY=cesty jsou shodnÇ

         push      si
         push      di
         push      bp
         push      ds
         push      es
         push      cs
         pop       ds                       ; DS <- CS
         push      cs
         pop       es                       ; ES <- CS
         call      getnakt                  ; poskytnut° adresy neaktivn°ho okna
         mov       di,ds:[bp+4]             ; p©°stupov† cesta
         call      getakt                   ; adresa aktivn°ho okna
         mov       si,ds:[bp+4]             ; p©°stupov† cesta
         call      comptxt                  ; porovn†n° ©etàzcñ cest
         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         ret

; -----------------------------------------------------------------------------
public   cmpcpath

cmpcpath:                                 ;* porovn†n° c°lovÇ cesty
                                            ; VùSTUP: ZY=cesty jsou shodnÇ

         push      si
         push      di
         push      bp
         push      ds
         push      es
         push      cs
         pop       ds                       ; DS <- CS
         push      cs
         pop       es                       ; ES <- CS
         lea       di,[selbuf]              ; c°lov† cesta operace
         mov       si,ds:[bp+4]             ; p©°stupov† cesta
         call      comptxt                  ; porovn†n° ©etàzcñ cest
         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         ret

; -----------------------------------------------------------------------------
public   cmpdisk

cmpdisk:                                  ;* porovn†n° diskñ cest k oknñm
                                            ; VùSTUP: ZY=disky jsou shodnÇ

         push      si
         push      di
         push      bp
         push      ds
         push      es
         push      cs
         pop       ds                       ; DS <- CS
         push      cs
         pop       es                       ; ES <- CS
         call      getnakt                  ; poskytnut° adresy neaktivn°ho okna
         mov       di,ds:[bp+4]             ; p©°stupov† cesta
         call      getakt                   ; adresa aktivn°ho okna
         mov       si,ds:[bp+4]             ; p©°stupov† cesta
         cmpsb                              ; porovn†n° diskñ
         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         ret

; -----------------------------------------------------------------------------
public   cmpcdisk

cmpcdisk:                                 ;* porovn†n° c°lovÇho disku operace
                                            ; VùSTUP: ZY=disky jsou shodnÇ

         push      si
         push      di
         push      bp
         push      ds
         push      es
         push      cs
         pop       ds                       ; DS <- CS
         push      cs
         pop       es                       ; ES <- CS
         lea       di,[selbuf]              ; c°lov† cesta operace
         mov       si,ds:[bp+4]             ; p©°stupov† cesta
         cmpsb                              ; porovn†n° diskñ
         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         ret

; -----------------------------------------------------------------------------
public   aktuald

aktuald:                                  ;* aktualizace disku (novÇ naáten°)
                                            ; VSTUP: BP=ukazatel okna
                                            ; VùSTUP: CY=p©eru®en° operace

         push      ax
         push      bx
         cmp       word ptr cs:[verze],300h ; je verze 3.00 nebo vy®®° ?
         jb        aktuald1                 ; je nië®° verze neë 3.00 - aktual.
         mov       bx,cs:[bp+4]             ; cesta k adres†©i
         mov       bl,cs:[bx]               ; disk
         sub       bl,40h                   ; korekce na á°slo disku
         mov       ax,4408h
         int       21h                      ; dotaz na vòmànnost mÇdia
         cmp       al,1                     ; je disk vòmànnò ?
         je        aktuald2                 ; disk nen° vòmànnò
aktuald1:                                 ;* novÇ naáten° adres†©e
         call      rerdir                   ; p©°znak novÇho naáten° adres†©e
         call      windret                  ; naáten° adres†©e
aktuald2:call      testbreak                ; je p©eru®en° operace ?
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   informc

informc:                                  ;* vymaz†n° inform. ©†dku
                                            ; VùSTUP: DX=poá†teán° pozice textu

         push      ax
         push      bx
         push      cx
         push      si
         push      di
         push      bp
                                          ;* vymaz†n° informaán°ho ©†dku
         xor       cl,cl                    ; poá†teán° pozice okna
         mov       ch,cs:[displ]            ; posledn° ©†dek
         mov       dl,79                    ; koncov† pozice ©†dku
         mov       dh,ch                    ; spodn° okraj okna
         push      cx                       ; £schova poá†teán° pozice
         mov       bh,cs:[col7]             ; barva pro norm†ln° okno
         mov       ax,600h                  ; funkce vymaz†n° okna
         int       10h                      ; vymaz†n° okna
         pop       dx                       ; poá†teán° pozice okna
         mov       al,7                     ; barva textu 7
         call      outch1                   ; nastaven° barvy 7
         inc       dl                       ; poá†teán° pozice = 1
         pop       bp
         pop       di
         pop       si                       ; £vodn° text
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   modikap

modikap:                                   ;* modifik. kapacity disku

         call      aktdisk                  ; aktualizace kapacity disku
         call      aktfile                  ; zji®tàn° kapacity v adres†©i
         call      space                    ; zobrazen° informac° o disku
         call      directory                ; zobrazen° informac° o adres†©i
         call      endline                  ; zobrazen° koncovÇho ©†dku
         ret

; -----------------------------------------------------------------------------
public   inspol

inspol:                                   ;* vloëen° kop°r. poloëky do seznamu

         push      si
         call      cmpcpath                 ; je adres†© stejnò jako c°lovò ?
         jne       inspol1                  ; nen° c°lovò adres†©
         or        byte ptr ds:[bp+0],4     ; p©°znak, ëe se adres. nenuluje
         lea       si,[outbuf+20]           ; vkl†dan† poloëka
         call      storekur                 ; £schova pozice kurzoru
         call      storfile                 ; vloëen° novÇ poloëky
         call      settabf                  ; n†vrat pozice kurzoru
         call      window                   ; novÇ zobrazen° okna
inspol1: pop       si
         ret

; -----------------------------------------------------------------------------
public   delpol

delpol:                                   ;* zru®en° poloëky BX

;         push      bx
;         mov       bx,cs:[bp+kurzl-tabl]    ; ru®enò soubor
         call      delpolf                  ; zru®en° poloëky ze seznamu
         call      windret
;         pop       bx
         ret

; -----------------------------------------------------------------------------
public   setfirst

setfirst:                                 ;* nastaven° prvn°ho souboru
                                            ; VùSTUP: CY=nen° prvn° soubor

         push      bx
         push      si
         push      bp
         push      ds
         call      getakt
         call      getkurz                  ; poskytnut° kurzoru
         jc        setfst1                  ; nen° ë†dnò soubor
         call      test1file                ; je pr†ce s kurzorem ?
         jnz       setfst1                  ; je souboru pod kurzorem
         call      srcins                   ; nalezen° prvn° poloëky
         jc        setfst1                  ; poloëka nenalezena
         call      setkurz                  ; nastaven° kurzoru na BX
setfst1: pop       ds
         pop       bp
         pop       si
         pop       bx
         ret

; -----------------------------------------------------------------------------
public   setkurz,setkurzn

setkurzn:                                 ;* posun o jednu poloëku
                                            ; VSTUP: BP=definice okna
                                            ; VùSTUP: CY=konec seznamu

         push      bx
         mov       bx,cs:[bp+11]            ; souáasn† pozice kurzoru
         inc       bx                       ; zvò®en° pozice kurzoru
         cmp       bx,cs:[bp+7]             ; je jië konec seznamu ?
         cmc
         jb        setkurz6                 ; je jië konec seznamu
         call      setkurz                  ; nastaven° kurzoru na dal®° poloëku
setkurz6:pop       bx
         ret


setkurz:                                  ;* nastaven° kurzoru pro operaci
                                            ; VSTUP: BX=á°slo poloëky
                                            ;        BP=definice okna

         push      ax
         call      testaktw                 ; je okno aktivn° ?
         jc        setkur4                  ; n†povàda nen° aktivn°
         cmp       word ptr cs:[bp+7],0     ; je nàjak† poloëka ?
         je        setkur4                  ; nen° ë†dn† poloëka
         cmp       bx,cs:[bp+7]             ; p©ekroáena maxim†ln° poloëka ?
         jb        setkur1                  ; poloëka je OK
         mov       bx,cs:[bp+7]             ; poáet poloëek
         dec       bx                       ; maxim†ln° poloëka
setkur1: cmp       bx,cs:[bp+11]            ; je jië dosaëeno pozice kurzoru ?
         je        setkur4                  ; je jië pozice kurzoru
         mov       ax,4800h                 ; k¢d kurzoru nahoru
         jb        setkur2                  ; m† bòt posun nahoru
         mov       ax,5000h                 ; k¢d kurzoru dolñ
setkur2: call      usesedit                 ; proveden° posuvu kurzoru
         jmp       short setkur1            ; dal®° krok posuvu
setkur3:
setkur4: pop       ax
         clc
         ret

; -----------------------------------------------------------------------------
public   setnext

setnext:                                  ;* nastaven° dal®°ho souboru
                                            ; VùSTUP: CY=nen° dal®° soubor

         push      bp
         push      bx
         call      getakt
         call      test1file                ; je pr†ce s kurzorem ?
         stc
         jnz       setnxt1                  ; je pr†ce s kurzorem - konec
         mov       bx,cs:[bp+11]            ; souáasn† pozice kurzoru
         call      srcins0                  ; nalezen° dal®° poloëky (nebo tÇto)
         jc        setnxt1                  ; je jië za koncem seznamu
         call      setkurz                  ; nastaven° kurzoru
setnxt1: pop       bx
         pop       bp
         ret

; -----------------------------------------------------------------------------
public   sethome

sethome:                                  ;* sestaven° cesty k domovskÇmu adres.
                                            ; VSTUP: CS:SI=soubor
                                            ;        CS:DI=buffer
                                            ; VùSTUP: DS:DX=specifikace souboru

         push      cs
         pop       ds                       ; segment bufferu
         mov       dx,di                    ; adresa bufferu

         push      es
         push      si

         push      cs
         pop       es                       ; ES <- CS

         cld
         mov       si,offset pathhome       ; cesta k dom†c°mu adres†©i
         call      transtxt                 ; p©enesen° jmÇna cesty
         mov       al,"\"
         cmp       byte ptr es:[di-1],al    ; byl posledn° znak "\" ?
         je        sethome1                 ; posledn° znak je jië "\"
         stosb                              ; oddàlovaá cesty a jmÇna programu

sethome1:pop       si                       ; jmÇno souboru
         call      transtxt                 ; p©enesen° jmÇna
         pop       es
         ret

; -----------------------------------------------------------------------------
public   testbreak

testbreak:                                ;* test p©eru®en° operace
                                            ; VùSTUP: CY=je p©eru®en° operace
         push      ax
         cmp       word ptr cs:[parbreak],0 ; je nàjak† chyba ?
         jne       testbrk3

         test      byte ptr cs:[parrez],80h
         jnz       testbrk3                 ; je p©eru®en° Ctrl-Break

         call      testkey
         clc
         jz        testbrk1                 ; nen° p©ipraven znak

         cmp       al,27                    ; je Esc ?
         clc
         jne       testbrk1                 ; nen° Esc

testbrk3:and       byte ptr cs:[parrez],not 80h ; zru®en° p©°znaku p©eru®en°
         test      byte ptr cs:[parrez],4   ; je z†kaz p©eru®en° ?
         jnz       testbrk1                 ; je z†kaz p©eru®en°
         mov       word ptr cs:[parbreak],-1 ; p©°znak p©eru®en°
testbrk2:call      flushkey                 ; vypr†zdnàn° kl†vesnice
         stc                                ; p©°znak p©eru®en° CY
testbrk1:pop       ax
         ret

; -----------------------------------------------------------------------------
public   retwind

retwind:                                  ;* n†vrat parametrñ okna po editaci


         push      ax
         push      bx
         push      cx
         push      dx
         call      testaktw                 ; test zapnut° okna
         jnc       retwind0
         jmp       retwind9                 ; okno je vypnutÇ
retwind0:call      getnumlw                 ; poáet ©†dkñ souborñ
         mov       dx,cx
;         mov       dx,18
;         call      testakth
;         jnc       retwind1
;         inc       dx
;retwind1:
         mov       ax,ds:[zacrol]           ; prvn° zobrazenò ©†dek
         cmp       ax,ds:[bp+9]             ; nastala zmàna poá†tku ?
         je        retwind8                 ; nenastala zmàna poá†tku
         call      kurzoff                  ; vypnut° kurzoru
         mov       bx,ds:[kurrol]           ; pozice kurzoru
         mov       ds:[bp+11],bx            ; nov† pozice kurzoru
         xchg      ax,ds:[bp+9]             ; uloëen° novÇho poá†tku
         sub       ax,ds:[bp+9]             ; rozd°l pro posun okna
         ja        retwind5                 ; je rolov†n° dolñ
                                          ;* rolov†n° nahoru
         neg       ax                       ; poáet ©†dkñ k rolov†n°
         cmp       ax,8                     ; omezen° - nebude se jië rolovat
         ja        retwind4
         call      wrollup                  ; rolov†n° okna nahoru o AL ©†dkñ
         mov       bx,ds:[bp+9]             ; prvn° zobrazenò soubor
         add       bl,ds:[delrol]           ; poáet ©†dkñ okna
         adc       bh,0                     ; posledn° ©†dek
         sub       bx,ax                    ; prvn° ©†dek k doplnàn°
retwind6:
         mov       cx,1
         call      testsetw                 ; test nastaven° oken
         jz        retwind3                 ; je plnÇ zobrazen° oken
         mov       cl,3
retwind3:push      cx
         mov       cx,ax                    ; poáet ©†dkñ
         push      bx
retwind2:call      zobrfile                 ; zobrazen° poloëky
         inc       bx                       ; zvò®en° ukazatele poloëek
         loop      retwind2                 ; dal®° poloëka
         pop       bx
         pop       cx
         sub       bx,dx
         loop      retwind3
         jmp       short retwind7

retwind5:                                 ;* rolov†n° dolñ
         cmp       ax,8                     ; omezen° - nebude se jië rolovat
         ja        retwind4
         call      wrolldown                ; rolov†n° okna nahoru o AL ©†dkñ
         mov       bx,ds:[bp+9]             ; prvn° zobrazenò soubor
         neg       dx
         jmp       short retwind6

retwind4:call      files                    ; zobrazen° souborñ
         jmp       short retwind9

retwind8:mov       ax,ds:[kurrol]           ; pozice kurzoru
         cmp       ax,ds:[bp+11]            ; byla zmàna kurzoru ?
         je        retwind9                 ; nen° zmàna kurzoru
         call      kurzoff                  ; vypnut° kurzoru
         mov       ds:[bp+11],ax            ; uloëen° novÇ pozice kurzoru
retwind7:call      kurzon                   ; zapnut° kurzoru
;         call      endline                  ; zobrazen° spodn°ho ©†dku
retwind9:pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   obrkurz

obrkurz:                                  ;* zobrazen° kurzoru p©°kazovÇho ©†dku
         push      bp
         lea       bp,[comlin]             ; definice povelovÇho ©†dku
         call      kurzlin                  ; zobrazen° kurzoru na ©†dku
         pop       bp
         ret

; -----------------------------------------------------------------------------
public   obrcomm

obrcomm:                                  ;* zobrazen° p©°kazovÇho ©†dku
         push      bp
         push      si
         push      ds
         push      cs
         pop       ds
         call      getakt                   ; nastaven° adresy aktivn°ho okna
         mov       si,cs:[bp+4]             ; cesta k levÇmu adres†©i
         lea       bp,[comlin]              ; definice povelovÇho ©†dku
         call      pathcomm                 ; cesta v povelovÇm ©†dku
         call      obrlin                   ; zobrazen° textu povelovÇho ©†dku
         call      kurzlin                  ; zobrazen° kurzoru na ©†dku
         pop       ds
         pop       si
         pop       bp
         ret

; -----------------------------------------------------------------------------
public   pathcomm

pathcomm:                                 ;* zobrazen° cesty p©°kazovÇho ©†dku
                                            ; VSTUP: BP=tabulka definice ©†dku
                                            ;        SI=text p©°stupovÇ cesty

         push      ax
         push      cx
         push      dx
         push      si
         call      mouseoff                 ; vypnut° my®i
         mov       al,cs:[normat]           ; atributy p©°kazovÇho ©†dku
         mov       cs:[color],al            ; nastaven° atributñ barev
         xor       dl,dl                    ; poá†teán° pozice kurzoru
         call      getendl                  ; á°slo posledn°ho ©†dku displeje
         inc       dh
         test      byte ptr cs:[flags],2    ; jsou okna vypnuta ?
         jz        pathcm1                  ; okna nejsou vypnuta
                                          ;* okna jsou vypnuta
;         push      cx
         mov       cx,80
         call      radeknul                 ; vymaz†n° ©†dku
;         pop       cx

         cmp       dh,byte ptr cs:[aktkurz+1] ; je nad kurzorem ?
         jbe       pathcm1
         mov       dh,byte ptr cs:[aktkurz+1] ; ©†dek kurzoru
                                          ;* zobrazen° textu
pathcm1: call      outtxt                   ; zobrazen° textu cesty
         mov       al,">"                   ; £vodn° prompt
         call      outch1                   ; zobrazen° promptu
         mov       al,80                    ; posledn° pozice na ©†dku
         sub       al,dl                    ; poáet pozic do konce ©†dku
         jnc       pathcm2
         xor       al,al                    ; n†hradn° ®°©ka textu = 0
pathcm2: mov       cs:[bp+14],al            ; ®°©ka ©†dku textu
         mov       cs:[bp+12],dx            ; pozice zaá†tku textu
         call      mouseon                  ; zapnut° my®i
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret


; -----------------------------------------------------------------------------
public   setcil

setcil:                                   ;* sestaven° jmÇna c°lovÇho souboru
                                            ; VùSTUP: [outbuf+20]=c°lovÇ jmÇno
                                            ;         CY=jmÇno je shodnÇ

         push      ax
         push      cx
         push      si
         push      di
         push      cs
         pop       es
                                          ;* p©enesen° pñvodn°ho jmÇna souboru
         call      getkurz                  ; poskytnut° adresy souboru
         lea       di,[outbuf+20]           ; adresa k uloëen° rozboru
         push      di                       ; adresa pñvodn°ho jmÇna souboru
         mov       cx,19                    ; dÇlka identifikace souboru
         lodsb                              ; atributy souboru
         and       al,37h                   ; nulov†n° atributñ
         stosb
         rep       movsb                    ; p©enesen° vzorovÇho jmÇna
         push      cs
         pop       ds                       ; DS <- CS
         lea       si,[rozbnam]             ; maska pro nastaven° jmÇna souboru
         pop       di                       ; adresa pñvodn°ho jmÇna souboru
         inc       di                       ; pñvodn° jmÇno souboru
                                          ;* p©ek¢dov†n° jmÇna souboru
         mov       cx,11                    ; poáet znakñ jmÇna
setcil2: lodsb                              ; maskovanò znak
         cmp       al,"?"                   ; je n†hradn° znak ?
         je        setcil3                  ; je n†hradn° znak
         mov       ds:[di],al               ; nastaven° novÇho znaku
setcil3: inc       di                       ; zvò®en° ukl†dac° adresy
         loop      setcil2                  ; dek¢dov†n° dal®°ho znaku
                                          ;* test shody novÇho jmÇna se staròm
         call      cmpcpath                 ; je operace v adres†©i ?
         clc
         jne       setcil4                  ; nen° operace v adres†©i
         call      getkurz
         inc       si                       ; p©eskoáen° atributu
         lea       di,[outbuf+21]           ; adresa s uloëenòm novòm jmÇnem
         mov       cx,11                    ; dÇlka jmÇna
         repe      cmpsb                    ; porovn†n° jmen
         clc
         jne       setcil4                  ; jmÇna nejsou shodn†
         stc                                ; p©°znak - jmÇna jsou shodn†
setcil4: push      cs
         pop       ds                       ; DS <- CS
         pop       di
         pop       si
         pop       cx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   precopy

precopy:                                  ;* nastaven° p©edvoleb pro COPY a MOVE

         push      di
         push      ds
         mov       ax,offset bufcop2
         sub       ax,offset bufcop1
         mov       word ptr ds:[bufcopy],ax
         mov       byte ptr ds:[bufcop2],0  ; ë†dn† p©edvolba
         call      getkurz                  ; poskytnut° adresy kurzoru
         jnc       precop33
         jmp       precop3                  ; nen° ë†dnò soubor
precop33:                                 ;* nastaven° cesty k protàj®°mu oknu
         call      cmppath                  ; porovn†n° cest k oknñm
         je        precop1                  ; okna jsou shodn†
;         call      test1file                ; je pr†ce s kurzorem ?
;         jnz       precop4                  ; je kurzor (volba s ALT)
;         call      soucins                  ; seáten° oznaáenòch souborñ
;         or        cx,cx                    ; poáet oznaáenòch souborñ
;         jnz       precop5                  ; je oznaáen nàjakò soubor
;precop4: push      bp
;         push      ds
;         push      si
;         call      getkurz                  ; poskytnut° kurzoru
;         test      byte ptr ds:[si],10h     ; je adres†© ?
;         pop       si
;         pop       ds
;         pop       bp
;         jnz       precop1                  ; je adres†© - nenab°z° se cesta
                                          ;* je cesta k protàj®°mu oknu
precop5: push      bp
         push      si
         push      ds
         push      es
         push      cs
         pop       ds
         push      cs
         pop       es
         call      getnakt                  ; poskytnut° adresy neaktivn°ho okna
         mov       di,offset outbuf3        ; zde se uloë° cesta k protàj®. oknu
         mov       cs:[bufcop3],di          ; nastaven° cesty k protàj®°mu oknu
         mov       si,cs:[bp+4]             ; p©°stupov† cesta
         call      transtxt
         call      test1file                ; je pr†ce s kurzorem ?
         jz        precop54                 ; je v°ce souborñ
         mov       al,"\"
         cmp       es:[di-1],al             ; ukonáena cesta lom°tkem ?
         je        precop55                 ; cesta je ukonáena lom°tkem
         stosb                              ; uloëen° uko§covac°ho lom°tka
precop55:call      getakt                   ; poskytnut° aktivn°ho okna
         call      getkurz                  ; poskytnut° souboru pod kurzorem
         call      dekfile                  ; uloëen° jmÇna souboru
precop54:inc       byte ptr cs:[bufcop2]    ; = 1 p©edvolba
         pop       es
         pop       ds
         pop       si
         pop       bp

precop1:                                  ;* nastaven° jmÇna souboru
         lea       di,[outbuf]
         test      byte ptr ds:[si],10h     ; je adres†© ?
         jnz       precop2                  ; je adres†© - povolenÇ
         call      test1file                ; je pr†ce s kurzorem ?
         jnz       precop2                  ; je kurzor
         call      soucins                  ; souáet oznaáenòch souborñ
         cmp       cx,1                     ; je oznaáenò soubor ?
         ja        precop3                  ; je oznaáen v°ce neë 1 soubor
precop2: call      dekfile                  ; dek¢dov†n° jmÇna souboru
         mov       si,cs:[bufcop3]          ; adresa cesty k protàj®°mu adres†©i
         mov       cs:[bufcop4],si          ; adresa cesty jako 2. p©edvolba
         mov       word ptr cs:[bufcop3],offset outbuf ; tiskovò buffer
         inc       byte ptr cs:[bufcop2]    ; = 2 p©edvolby
precop3: cmp       byte ptr cs:[bufcop2],2  ; jsou 2 p©edvolby ?
         jne       precop6
         call      getoper                  ; poskytnut° k¢du operace
         cmp       al,1                     ; je p©esun ?
         jne       precop8                  ; nen° p©esun
         call      test1file                ; je pr†ce s kurzorem ?
         jnz       precop9                  ; je pr†ce s kurzorem
         call      soucins                  ; souáet oznaáenòch souborñ
         cmp       cx,1                     ; je oznaáenò soubor ?
         jae       precop8                  ; je oznaáen nàjakò soubor
precop9: call      getkurz                  ; poskytnut° souboru pod kurzorem
         test      byte ptr ds:[si],10h     ; je to adres†© ?
         jnz       precop7                  ; je to adres†©
precop8: call      testaktwn                ; je neaktivn° okno zapnutÇ ?
         jnc       precop6                  ; neakt. okno je zapnutÇ
precop7: mov       si,cs:[bufcop3]          ; p©edvolba 1
         xchg      si,cs:[bufcop4]          ; z†màna p©edvoleb
         mov       cs:[bufcop3],si
precop6: pop       ds
         pop       di
         ret

; -----------------------------------------------------------------------------
public   testro
testro:                                   ;* test ru®en° souboru R/O

                                          ;* test, zda je automatickò reëim
         test      byte ptr ds:[flagsc],40h ; prov†d° se dotaz ?
         jnz       testro3                  ; dotaz se neprov†d°
                                          ;* sestaven° textu dotazu
         lea       di,[bufnadp]             ; pracovn° buffer
         lea       si,[txtvar]              ; text varov†n°
         call      transtxt                 ; uloëen° nadpisu
         lea       si,[errdel1]             ; text "Soubor"
         test      byte ptr ds:[95h],10h    ; je to adres†© ?
         jz        testro2                  ; nen° to adres†©
         lea       si,[errdir1]             ; test "Adres†©"
testro2: call      transtxt                 ; p©enos oznaáen°
         mov       si,dx                    ; jmÇno souboru
         call      transtxt                 ; p©enos jmÇna souboru
         lea       si,[errdir2]             ; text "nelze zru®it, "
         call      transtxt
         lea       si,[errdel2]             ; text "protoëe je chr†nàn..."
         call      transtxt
                                          ;* provede se dotaz na dal®° postup
         lea       si,[delvolb]             ; volby
         lea       di,[bufnadp]             ; buffer s textem
         xor       al,al
         call      volbyh                   ; proveden° voleb
         call      windret                  ; navr†cen° oken
         jc        testro3                  ; p©eru®en° operace
         mov       cl,6                     ; poáet rotac°
         shl       al,cl                    ; á°slo dal®° funkce
         and       byte ptr cs:[flagsc],3fh ; zru®en° staròch p©°znakñ
         or        cs:[flagsc],al           ; nastaven° novòch p©°znakñ
testro3: ret

; -----------------------------------------------------------------------------
public   informz

informz:                                  ;* zobrazen° z†kladn°ho inform. ©†dku
                                            ; VSTUP: DS:SI=£vodn° text
                                            ; VùSTUP: DX=pozice konce textu
         call      mouseoff                 ; vypnut° my®i
         push      ax
;         push      bx
;         push      cx
         push      si
         push      di
;         push      bp
                                          ;* £vodn° á†st textu
         call      informc                  ; vymaz†n° informaán°ho ©†dku
         call      outtxt                   ; zobrazen° £vodn°ho textu
         inc       dl                       ; zvò®en° pozice za textem
                                          ;* zobrazen° textu "soubor","adres†©"
         call      getkurz                  ; adresa poloëky s kurzorem
         push      si
         push      ds
         test      byte ptr ds:[si],10h     ; je adres†© ?
         lea       si,[textvy2+2]           ; text "soubor"
         jz        informz2                 ; nen° adres†©
         lea       si,[txtadr]              ; text "adres†©"
informz2:push      cs
         pop       ds                       ; DS <- CS
         call      outtxt                   ; zobrazen° textu
         inc       dl                       ; zvò®en° pozice
         pop       ds
         pop       si
                                          ;* zobrazen° jmÇna souboru
         mov       al,10                    ; barva textu 10
         call      outch1                   ; nastaven° barvy 10
         lea       di,[outbuf]              ; tiskovò buffer
         push      di
         call      dekfile                  ; dek¢dov†n° jmÇna poloëky
         pop       si                       ; adresa textu
         push      cs
         pop       ds                       ; DS <- CS
         call      outtxt                   ; zobrazen° jmÇna souboru
         call      kurzout                  ; vypnut° kurzoru
;         pop       bp
         pop       di
         pop       si
;         pop       cx
;         pop       bx
         pop       ax
         call      mouseon                  ; zapnut° my®i
         ret


; -----------------------------------------------------------------------------
public   initukaz,initukaz0

initukaz:                                 ;* inicializace ukazatele kop°rov†n°
                                            ; VSTUP: AL=maxim†ln° dÇlka ukazat.

         push      ds
         push      si
         call      getkurz
         call      initukaz0
         pop       si
         pop       ds
         ret


initukaz0:
         call      mouseoff                 ; vypnut° my®i
         push      ax
         push      bx
         push      cx
         push      dx
         push      ds

         mov       bl,al                    ; £schova maxim†ln° dÇlky ukazatele
         xor       ax,ax
         mov       word ptr cs:[blokuk],ax
         mov       word ptr cs:[blokuk+2],ax ; vynulov†n° velikosti ukazatele
         mov       word ptr cs:[transuk],ax
         mov       word ptr cs:[transuk+2],ax ; vynulov†n° ukazatele p©enes. dat
                                          ;* vòpoáet dÇlky ukazatele
         mov       ax,ds:[si+12]            ; velikost souboru - nië®° slovo
         mov       dx,ds:[si+14]            ; velikost souboru - vy®®° slovo
         push      cs
         pop       ds
         push      ax
         push      dx
         xor       bh,bh                    ; á°taá cyklñ
inituk1: or        dx,dx                    ; je vy®®° slovo jië 0 ?
         jnz       inituk2                  ; nen° vy®®° slovo = 0
         cmp       ax,3                     ; je á°slo men®° nebo rovno 3 ?
         jbe       inituk3                  ; je jië á°slo men®° nebo rovno 3
inituk2: shr       dx,1                     ; DX / 2
         rcr       ax,1                     ; velikost / 2
         add       bh,4
         jmp       short inituk1            ; dal®° test
inituk3: add       bh,al                    ; celkov† ®°©ka (znakñ)
         sub       bh,32                    ; odeáten° poá†tku pro 512 bajtñ
         jc        inituk32                 ; je men®°
         cmp       bh,4
         jae       inituk31                 ; je vàt®° neë 512 bajtñ
inituk32:mov       bh,4                     ; n†hradn° dÇlka
inituk31:
         cmp       bh,bl                    ; je vàt®° neë povolen† dÇlka ?
         ja        inituk4                  ; je vàt®°
         mov       bl,bh                    ; omezen° na vypoátenou velikost
inituk4:                                  ;* vòpoáet parametrñ ukazatele
         pop       ax                       ; velikost souboru - vy®®° slovo
         pop       cx                       ; velikost souboru - nië®° slovo
         or        bl,bl                    ; je povoleno zobrazen° ?
         jz        inituk6                  ; nen° povoleno zobrazen°
         xor       dx,dx
         xor       bh,bh
         div       bx                       ; vòpoáet vy®®°ho slova bloku
         xchg      ax,cx                    ; £schova vy®®°ho slova bloku
         div       bx                       ; vòpoáet nië®°ho slova bloku
         mov       word ptr ds:[blokuk],ax
         mov       word ptr ds:[blokuk+2],cx; uloëen° velikosti ukazatele
         or        ax,cx                    ; je povoleno zobrazen° ?
         jz        inituk6                  ; zobrazen° nen° povoleno
                                          ;* zobrazen° ukazatele
         mov       dl,79                    ; konec zobrazen°
         sub       dl,bl                    ; poá†teán° pozice zobrazen°
         mov       ds:[poziceuk],dl         ; poá†teán° pozice ukazatele
         mov       ds:[delkauk],bl          ; £schova dÇlky ukazatele
         call      getdispl                 ; á°slo posledn°ho ©†dku
;         mov       dh,24                    ; ©†dek pro zobrazen° ukazatele
         mov       cx,bx                    ; dÇlka zobrazen° ukazatele
         mov       al,7                     ; barva
         call      outch1                   ; nastaven° barvy
         mov       al,0b0h                  ; podklad ukazatele
         call      outch                    ; zobrazen° podkladu ukazatele
inituk6: pop       ds
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         call      mouseon                  ; zapnut° my®i
         ret

; -----------------------------------------------------------------------------
public   modiukaz

modiukaz:                                 ;* modifikace ukazatele
                                            ; VSTUP: AX=poáet zapsanòch bajtñ
                                            ;        CY=zobrazen° 100%
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      ds
         push      cs
         pop       ds
         mov       si,word ptr ds:[blokuk]  ; nië®° slovo velikosti bloku
         mov       bx,word ptr ds:[blokuk+2]; vy®®° slovo velikosti bloku
         mov       cl,ds:[delkauk]          ; dÇlka ukazatele
         jc        modiuk5                  ; plnÇ zobrazen° ukazatele
         push      bx
         or        bx,si
         pop       bx
         jz        modiuk6                  ; zobrazen° nen° povoleno
         add       word ptr ds:[transuk],ax
         adc       word ptr ds:[transuk+2],0; zvò®en° velikosti dat
         mov       ax,word ptr ds:[transuk] ; nië®° slovo zapsanòch bajtñ
         mov       dx,word ptr ds:[transuk+2]; vy®®° slovo zapsanòch bajtñ
         xor       cl,cl                    ; á°taá blokñ
modiuk2: inc       cl                       ; zvò®en° á°taáe blokñ
         sub       ax,si                    ; nië®° slovo
         sbb       dx,bx                    ; vy®®° slovo
         jnc       modiuk2                  ; dal®° blok
         dec       cl
modiuk5: or        bx,si                    ; povoleno zobrazen° ?
         jz        modiuk6                  ; zobrazen° nen° povoleno
         call      mouseoff                 ; vypnut° my®i
         mov       al,7                     ; barva ukazatele
         call      outch1                   ; nastaven° barvy ukazatele
         mov       dl,ds:[poziceuk]         ; poá†teán° pozice ukazatele
         xor       ch,ch
         mov       al,0b2h                  ; znak ukazatele
         call      getdispl                 ; á°slo posledn°ho ©†dku
;         mov       dh,24                    ; ©†dek pro zobrazen°
         call      outch                    ; zobrazen° ukazatele
         call      mouseon                  ; zapnut° my®i
modiuk6: pop       ds
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   dispcil

dispcil:                                  ;* zobrazen° c°le operace
                                            ; VSTUP: AH=poáet oddàlovaáñ "\"
                                            ;        DI+1=adresa souboru

         push      ax
         push      cx
         push      si
         push      di
         pushf

         call      mouseoff                 ; vypnut° my®i
         mov       al,10
         call      outch1                   ; nastaven° barvy
                                          ;* test, zda je operace v adres†©i
         inc       di
         mov       cl,ds:[di-1]             ; £schova znaku oddàlovaáe
         mov       byte ptr ds:[di-1],0
         call      cmpcpath                 ; je operace v adres†©i ?
         mov       ds:[di-1],cl             ; n†vrat znaku
         pushf
         cmp       cl,"\"                   ; byl uschov†n znak "\" ?
         je        dispcil0                 ; byl "\" - OK
         dec       di                       ; nebyl "\" - byl z†kladn° adres†©
dispcil0:popf
         mov       si,di                    ; zaá†tek jmÇna souboru
         je        dispcil3                 ; je operace v adres†©i

                                          ;* nastaven° kurzoru v protàj®°m oknà
         lea       si,[selbuf]              ; cesta k c°lovÇmu adres†©i
         sub       ah,3                     ; je p©ekroáen poáet oddàlovaáñ ?
         jbe       dispcil3                 ; je malò poáet oddàlovaáñ
         mov       cl,ah                    ; £schova á°taáe oddàlovaáñ
         xor       ch,ch
         lodsb                              ; oznaáen° disku
         call      outch1
         lodsb                              ; oddàlovaá disku ":"
         call      outch1
         lodsb                              ; oddàlovaá "\"
         call      outch1
         mov       al,"."                   ; oddàlovac° teáka
         call      outch1
         call      outch1
         call      outch1
         inc       cx
dispcil1:lodsb
         cmp       al,"\"
         jnz       dispcil1                 ; nalezen° oddàlovaáe
         loop      dispcil1                 ; dal®° oddàlovaá
         dec       si                       ; n†vrat posledn°ho odàlovaáe
dispcil3:
         call      outtxt                   ; zobrazen° zbytku textu
         call      mouseon                  ; zapnut° my®i
         call      kurzout                  ; vypnut° kurzoru
         popf
         pop       di
         pop       si
         pop       cx
         pop       ax
         ret

public   kurzcil
kurzcil:                                  ;* zobrazen° c°lovÇho kurzoru BP
         push      si
         push      bx
         call      testaktw                 ; je okno zapnutÇ ?
         jc        kurzcil3                 ; okno nen° zapnutÇ
         mov       si,offset outbuf+20      ; c°lovò soubor
         call      hledpol0                 ; nalezen° shodnÇho c°lovÇho souboru
         jnc       kurzcil2                 ; kurzor nalezen OK
         test      byte ptr ds:[bp+0],10h   ; je net©°dànò adres†© ?
         jnz       kurzcil3                 ; je net©°dànò adres†©
         call      hledpol                  ; nalezen° podobnÇho jmÇna
kurzcil2:                                 ;* soubor nalezen
         call      setkurz                  ; nastaven° kurzoru na poloëku BX
         call      storekur                 ; £schova pozice kurzoru
kurzcil3:pop       bx
         pop       si
         ret
; -----------------------------------------------------------------------------
public   setpcil

setpcil:                                  ;* sestaven° c°lovÇ cesty k souboru
                                            ; VùSTUP: DI=pñvodn° konec SELBUF
                                            ;         CY=zdroj shodnò s c°lem
                                            ;         AH=poáet oddàlovaáñ "\"


         lea       di,[selbuf]              ; c°lovò adres†©
         call      lendi                    ; dÇlka cesty v SELBUF
         xor       ah,ah
         add       di,ax                    ; konec textu
         call      setcil                   ; sestaven° jmÇna
         push      di                       ; £schova pñvodn°ho konce cesty
         pushf
                                          ;* nastaven° kurzoru na c°lovò soubor
         xor       ax,ax
         xchg      byte ptr ds:[di],al      ; p©echodnò n†vrat konce cesty
         call      setpcil8
         xchg      byte ptr ds:[di],al      ; n†vrat pñvodn°ho znaku z cesty

         cmp       byte ptr ds:[di-1],"\"   ; je jië oddàlovaá konce cesty ?
         je        setpcil2                 ; je jië oddàlovaá
         mov       al,"\"
         stosb                              ; uloëen° oddàlovaáe
setpcil2:lea       si,[outbuf+20]           ; p©ek¢dovanÇ jmÇno souboru
         call      dekfile                  ; dek¢dov†n° jmÇna souboru
         lea       si,[selbuf]              ; buffer s cestou
         xor       ah,ah                    ; á°taá oddàlovaáñ "\"
setpcil3:lodsb                              ; naáten° znaku cesty
         or        al,al                    ; je jië konec cesty ?
         jz        setpcil4                 ; je konec cesty
         cmp       al,"\"                   ; je oddàlovaá "\" ?
         jne       setpcil3                 ; nen° - dal®° znak
         inc       ah                       ; zvò®en° á°taáe oddàlovaáñ
         jmp       short setpcil3           ; dal®° znak
setpcil4:mov       al,ah                    ; poáet oddàlovaáñ
         popf
         pop       di                       ; pñvodn° konec cesty
         ret


PUBLIC   setpcil8
setpcil8:                                 ;* nastaven° kurzoru na c°lovò soubor
         push      bp
         call      getnakt                  ; neaktivn° okno
         call      cmppath                  ; jsou obà okna stejn† ?
         je        dispcil5                 ; okna jsou stejn†
         call      cmpcpath                 ; je to c°lovÇ okno ?
         jne       dispcil4                 ; nen° to ani c°lovÇ okno
dispcil5:call      kurzcil                  ; zobrazen° c°lovÇho souboru
dispcil4:pop       bp
         ret


; -----------------------------------------------------------------------------
;        Kop°rov†n° celÇho adres†©e
; -----------------------------------------------------------------------------

xcopy9a: mov       si,offset errdr1         ; text - nelze cyklicky kop°rovat
         call      getoper                  ; poskytnut° k¢du operace
         or        al,al                    ; je kop°rov†n° ?
         jz        xcopy9c                  ; je kop°rov†n°
         mov       si,offset errdr2         ; text - nelze cyklicky p©esouvat
xcopy9c: call      zobrchyb                 ; zobrazen° chybovÇho hl†®en°
xcopy9:  ret

PUBLIC   XCopy
XCopy:

         push      cs
         pop       ds
         push      cs
         pop       es

         call      storekall                ; £schova pozic kurzorñ

                                          ;* nastaven° aktu†ln°ho adres†©e
         mov       si,ds:[bp+4]             ; adres†© okna
         call      aktdir                   ; nastaven° aktivn°ho adres†©e okna
         call      testbreak                ; je p©eru®en° operace ?
         jc        xcopy9                   ; p©eru®en° operace

                                          ;* nastaven° c°lovÇho adres†©e
         lea       si,[outbuf]              ; zadanò adres†©
         call      aktdir                   ; nastaven° c°lovÇho adres†©e
         jnc       xcopy1                   ; adres†© existuje
         call      testbreak                ; je p©eru®en° operace ?
         jc        xcopy9                   ; p©eru®en° operace
                                          ;* chyba zad†n° adres†©e
         lea       si,[errcop1]             ; text "ChybnÇ zad†n° ..."
         jmp       zobrchyb                 ; zobrazen° chybovÇho hl†®en°

                                          ;* pokus, zda je zadanÇ jmÇno adres†©e
xcopy1:  lea       di,[outbuf]              ; uloëen° podadres†©e
         lea       si,[rozbflg]             ; moënÇ jmÇno podadres†©e
         push      di
         call      dekfile                  ; dek¢dov†n° jmÇna podadres†©e
         pop       si                       ; p©°padnò podadres†©
         call      aktdir                   ; nastaven° podadres†©e
         jnc       xcopy2                   ; adres†© nastaven OK
         call      testbreak                ; je p©eru®en° operace ?
xcopy99: jc        xcopy9                   ; p©eru®en° operace

                                          ;* vytvo©en° zadanÇho podadres†©e
         mov       dx,si                    ; zadanò adres†©
         mov       ah,39h
ifndef   demo
         int       21h                      ; pokus o vytvo©en° adres†©e
else
         clc
endif
         jc        xcopy21                  ; adres†© nelze vytvo©it - nezad†n
         call      aktdir                   ; novò pokus o nastaven°
         jnc       xcopy2                   ; adres†© vytvo©en OK

                                          ;* vytvo©en° implicitn°ho adres†©e
xcopy21: push      ds
         call      getkurz                  ; poskytnut° adresy kurzoru
         lea       di,[outbuf]              ; uloëen° podadres†©e
         push      di
         call      dekfile                  ; dek¢dov†n° jmÇna podadres†©e
         pop       si                       ; p©°padnò podadres†©
         pop       ds
         call      aktdir                   ; nastaven° podadres†©e
         jnc       xcopy2                   ; adres†© nastaven OK
         call      testbreak                ; je p©eru®en° operace ?
         jc        xcopy99                  ; p©eru®en° operace

         mov       dx,si                    ; zadanò adres†©
         mov       ah,39h
ifndef   demo
         int       21h                      ; vytvo©en° implicitn°ho adres†©e
endif
         call      aktdir                   ; nastaven° adres†©e

                                          ;* £schova cesty k c°lovÇmu adres†©i
xcopy2:  call      testbreak                ; je p©eru®en° operace ?
         jc        xcopy99                  ; p©eru®en° operace
         lea       di,[selbuf]              ; buffer k uloëen° adres†©e
         call      loadpath                 ; naáten° c°lovÇho adres†©e
         call      testbreak                ; je p©eru®en° operace ?
         jc        xcopy99                  ; p©eru®en° operace
         mov       cx,80
         xor       al,al
         repne     scasb                    ; nalezen° konce cesty
         mov       word ptr es:[di-1],"\"   ; ukonáovac° znak "\"

;                                          ;* aktualizace druhÇho okna
;         push      bp
;         call      getnakt                  ; neaktivn° okno
;         call      cmpcpath                 ; je druhÇ okno c°lovÇ ?
;         clc
;         jne       xcopy3                   ; nen° c°lovÇ
;         call      aktuald                  ; aktualizace adres†©e disku
;xcopy3:  pop       bp
;         jc        xcopy99                  ; p©eru®en° operace

                                          ;* nastaven° parametrñ bufferu
         mov       ax,ds:[segend]           ; segment konce pamàti
         sub       ax,ds:[topseg]           ; dÇlka volnÇ pamàti
         dec       ax
         cmp       ax,0fffh                 ; je vàt®° neë maximum ?
         jbe       xcopy4                   ; je men®° neë maximum
         mov       ax,0fffh                 ; omezen° max. velikosti
xcopy4:  shl       ax,1
         shl       ax,1
         shl       ax,1
         shl       ax,1                     ; velikost bufferu v bajtech
         mov       ds:[maxdbuf],ax          ; maxim†ln° velikost bufferu
         or        ax,ax
         jz        xcopy9b                  ; chyba - nen° voln† pamàü

                                          ;* nastaven° aktu†ln°ho adres†©e
         mov       si,cs:[bp+4]             ; adres†© okna
         call      aktdir                   ; nastaven° aktivn°ho adres†©e okna
         call      testbreak                ; je p©eru®en° operace ?
         jc        xcopy9b                  ; je p©eru®en° operace
         push      ds
         call      getkurz                  ; poskytnut° adresy kurzoru
         lea       di,[outbuf]              ; uloëen° podadres†©e
         push      di
         call      dekfile                  ; dek¢dov†n° jmÇna podadres†©e
         pop       si                       ; p©°padnò podadres†©
         pop       ds
         call      aktdir                   ; nastaven° podadres†©e
         call      testbreak                ; je p©eru®en° operace ?
         jc        xcopy9b                  ; p©eru®en° operace

                                          ;* nastaven° standardn° adresy DTA
         mov       dx,80h                   ; standardn° adresa DTA
         mov       ah,1ah
         int       21h                      ; nastaven° adresy DTA

                                          ;* test, zda je zdroj nadadres†©em
         lea       di,[outbuf]              ; buffer k uloëen° adres†©e
         call      loadpath                 ; naáten° zdrojovÇho adres†©e
xcopy5:  mov       si,offset outbuf         ; zdrojovò adres†©
         mov       di,offset selbuf         ; c°lovò adres†©
         cld
xcopy52: lodsb                              ; znak zdrojovÇho adres†©e
         cmp       al,0                     ; je jië konec (=0) ?
         je        xcopy55                  ; je konec - je cyklickÇ kop°rov†n°
         scasb                              ; porovn†n° se znakem c°lovÇho adres.
         je        xcopy52                  ; porovn†n° dal®°ho znaku
         jmp       short xcopy56            ; nen° podmnoëinou

xcopy55: mov       al,es:[di]               ; dal®° znak
         cmp       al,0                     ; jsou stejnÇ cesty ?
         je        xcopy9aa                 ; cyklickÇ kop°rov†n°
         cmp       al,"\"                   ; je dal®°
         jne       xcopy56                  ; nen° cyklickÇ kop°rov†n°
xcopy9aa:jmp       xcopy9a                  ; je podadres†©

xcopy56:

xcopy7:
         call      xcopx                    ; zkop°rov†n° aktu†ln°ho adres†©e
         jc        xcopy9b                  ; p©eru®en° operace

                                          ;* p©i p©esunu zru®en° adres†©e
         call      getoper                  ; poskytnut° k¢du operace
         or        al,al                    ; je kop°rov†n° ?
         jz        xcopy9b                  ; je kop°rov†n°

                                          ;* zru®en° adres†©e pod kurzorem
         mov       si,cs:[bp+4]             ; adres†© okna
         call      aktdir                   ; nastaven° aktivn°ho adres†©e okna
         push      ds
         call      getkurz                  ; poskytnut° adresy kurzoru
         lea       di,[outbuf]              ; uloëen° podadres†©e
         mov       dx,di                    ; jmÇno adres†©e
         call      dekfile                  ; dek¢dov†n° jmÇna podadres†©e
         pop       ds
         mov       cx,0                     ; novÇ atributy - nic nenastaveno
         mov       ax,4301h
         int       21h                      ; nulov†n° atributñ adres†©e
         mov       ah,3ah
         int       21h                      ; zru®en° adres†©e
         call      testbreak                ; pouze test p©eru®en°

xcopy9b: ret

; -----------------------------------------------------------------------------
;        Kop°rov†n° obsahu aktivn°ho adres†©e (SELBUF=c°lovò adres†©)
; -----------------------------------------------------------------------------

PUBLIC   xcopx
xcopx:
         mov       ah,4eh                   ; funkce nalezen° souboru
         mov       cx,37h                   ; atributy - v®echny soubory
         mov       dx,offset all            ; specifikace - v®echny soubory

                                          ;* nalezen° souboru/adres†©e
xcopx1:  int       21h                      ; nalezen° prvn°ho/dal®°ho souboru
         jnc       xcopx2                   ; nalezen soubor
         cmp       al,2                     ; soubor nenalezen ?
         je        xcopx9                   ; nen° ë†dnò soubor
         cmp       al,12h                   ; nen° dal®° soubor ?
         je        xcopx9                   ; nen° dal®° soubor
         stc                                ; p©°znak jinÇ chyby
         jmp       short xcopx9             ; jin† chyba

                                          ;* p©eskoáen° adres†©ñ "." a ".."
xcopx2:  call      testbreak                ; je p©eru®en° operace ?
         jc        xcopx9                   ; je p©eru®en° operace
         cmp       word ptr ds:[9eh],"."
         je        xcopx88                  ; nepovolenÇ jmÇno
         cmp       word ptr ds:[9eh],".."
         jne       xcopx21                  ; povolenÇ jmÇno
xcopx88: jmp       xcopx8

                                          ;* kop°rov†n° podadres†©e

                                          ;* sestaven° cesty k adres†©i
xcopx21: test      byte ptr ds:[95h],10h    ; je to adres†© ?
         jnz       xcopx22                  ; je to adres†©
         jmp       xcopx7                   ; nen° adres†©, je to soubor

xcopx22: mov       di,offset selbuf         ; c°lovò adres†©
         mov       cx,80                    ; max. dÇlka cesty
         xor       al,al                    ; hledanò bajt
         repne     scasb                    ; nalezen° konce cesty
         dec       di                       ; n†vrat na posledn° znak
         mov       si,9eh                   ; jmÇno nalezenÇho adres†©e
         call      transtxt                 ; p©enos textu jmÇna souboru

                                          ;* vytvo©en° adres†©e
         mov       dx,offset selbuf         ; jmÇno adres†©e
         mov       ah,39h                   ; funkce vytvo©en° adres†©e
ifndef   demo
         int       21h                      ; vytvo©en° c°lovÇho adres†©e
endif
                                          ;* nastaven° atributñ adres†©e
         mov       ax,4300h                 ; funkce poskytnut° atributñ
         int       21h                      ; poskytnut° atributñ
         jc        xcopx3                   ; adres†© neexistuje
         test      cl,10h                   ; je to adres†© ?
         jz        xcopx3                   ; je to soubor - chyba
         mov       cl,ds:[95h]              ; atributy kop°rovanÇho adres†©e
         and       cl,not 10h               ; zru®en° atributu adres†©e
         mov       ax,4301h                 ; funkce nastaven° atributñ
         int       21h                      ; test, zda adres†© existuje
         jnc       xcopx4                   ; v®e probàhlo OK

                                          ;* chyba - adres†© nelze vytvo©it
xcopx3:  mov       di,offset outbuf
         mov       si,offset errxc1
         call      transtxt
         mov       si,offset selbuf
         call      transtxt
         mov       si,offset errxc2
         call      transtxt
         mov       si,offset outbuf
xcopx33: jmp       zobrchyb

xcopx9:  jmp       short xcopm

                                          ;* nastaven° novÇho adres†©e
xcopx4:  call      testbreak
         jc        xcopx9                   ; p©eru®en° operace
         mov       word ptr es:[di],"\"     ; koncovò znak adres†©e
         mov       dx,9eh                   ; jmÇno nalezenÇho adres†©e
         mov       ah,3bh                   ; funkce nastaven° adres†©e
         int       21h                      ; nastaven° podadres†©e
xcopx44: mov       dx,offset erroper
         jc        xcopx33                  ; chyba - adres†© nelze nastavit

                                          ;* kop°rov†n° obsahu adres†©e
         call      xpush                    ; £schova bufferu DTA
         call      xcopx                    ; kop°rov†n° aktivn°ho adres†©e
         call      xpop                     ; n†vrat bufferu DTA
         jc        xcopx9                   ; chyba operace (p©eru®en°)

                                          ;* n†vrat do nadadres†©e
         mov       dx,offset nadadr         ; nadadres†©
         mov       ah,3bh                   ; funkce nastaven° adres†©e
         int       21h                      ; n†vrat do adres†©e
         jc        xcopx44                  ; nàjak† chyba - nelze nastavit
         call      testbreak
         jc        xcopx9                   ; p©eru®en° operace

                                          ;* zru®en° adres†©e
         call      getoper                  ; poskytnut° k¢du operace
         cmp       al,1                     ; je p©esun souborñ ?
         jne       xcopx47                  ; nen° p©esun souborñ
ifndef   demo
         mov       dx,offset 9eh            ; jmÇno adres†©e
         mov       cx,0                     ; novÇ atributy - nic nenastaveno
         mov       ax,4301h
         int       21h                      ; nulov†n° atributñ adres†©e
         mov       ah,3ah
         int       21h                      ; zru®en° adres†©e
endif
xcopx47:

                                          ;* zru®en° adres†©e z c°lovÇ cesty
         cld
         mov       di,offset selbuf         ; c°lovò adres†©
         mov       cx,90
         xor       al,al                    ; hledanò bajt 0
         repne     scasb                    ; nalezen° koncovÇho bajtu 0
xcopx5:  dec       di
         cmp       byte ptr es:[di-2],"\"
         jne       xcopx5                   ; nalezen° dal®°ho znaku "\"
         mov       byte ptr es:[di-1],0     ; oznaáen° pñvodn°ho konce cesty

         jmp       short xcopx8             ; dal®° soubor/adres†©


xcopx7:  call      xpush                    ; £schova tabulky DTA
         call      xcopf                    ; kop°rov†n° nalezenÇho souboru
         call      xpop                     ; n†vrat tabulky DTA
         jc        xcopx9                   ; chyba nebo p©eru®en°

                                          ;* nalezen° dal®°ho souboru/adres†©e
xcopx8:  mov       ah,4fh                   ; funkce - nalezen° dal®°ho souboru
         jmp       xcopx1                   ; nalezen° dal®°ho souboru


xcopm:
                                          ;* modifikace kapacity disku
;         pushf
;         call      getoper                  ; poskytnut° k¢du operace
;         or        al,al                    ; je kop°rov†n° ?
;         jnz       xcopm47                  ; je p©esun - nezobraz° se kapacita
;         call      cmpcdisk                 ; je c°lovò disk ?
;         jne       xcopm3                   ; nen° c°lovò disk
;         call      modikap                  ; modifikace kapacity disku
;xcopm3:  push      bp
;         mov       bp,cs:[bp+1]             ; adresa druhÇho okna
;         call      cmpcdisk                 ; je c°lovò disk ?
;         jne       xcopm4                   ; nen° c°lovò disk
;         call      modikap                  ; modifikace kapacity o soubor
;xcopm4:  pop       bp
;xcopm47: popf
         ret

; -----------------------------------------------------------------------------
;        Kop°rov†n° jednoho souboru (SELBUF=c°lovò adres†©)
; -----------------------------------------------------------------------------

PUBLIC   xcopf
xcopf:

         mov       word ptr ds:[blokuk],0
         mov       word ptr ds:[blokuk+2],0 ; z†kaz zobrazen° ukazatele

         lea       si,[txtcop5]             ; text " Kop°ruji"
         call      getoper                  ; poskytnut° operace
         or        al,al                    ; je kop°rov†n° ?
         jz        xcopf1                   ; je kop°rov†n°
         lea       si,[txtmov5]             ; text "P©esouv†m"

                                          ;* zobrazen° informaán°ho ©†dku
xcopf1:  call      mouseoff                 ; vypnut° my®i
         call      informc                  ; vymaz†n° informaán°ho ©†dku
         call      outtxt                   ; zobrazen° £vodn°ho textu
         inc       dl                       ; zvò®en° pozice za textem
         lea       si,[textvy2+2]           ; text "soubor"
         call      outtxt                   ; zobrazen° textu
         inc       dl                       ; zvò®en° pozice
         mov       al,10                    ; barva textu 10
         call      outch1                   ; nastaven° barvy 10
         mov       si,9eh                   ; kop°rovanò soubor
         call      outtxt                   ; zobrazen° jmÇna souboru
         lea       si,[txtcop6]             ; text "do"
         call      outtxt
         call      kurzout                  ; vypnut° kurzoru
         call      mouseon                  ; zapnut° my®i

                                          ;* sestaven° c°le operace
         mov       di,offset selbuf         ; c°lovò adres†©
         xor       al,al
         mov       cx,90
         repne     scasb                    ; nalezen° konce adres†©e
         dec       di

         push      di                       ; £schova pñvodn°ho konce adres†©e

         mov       si,9eh                   ; kop°rovanò soubor
         call      transtxt                 ; p©ipojen° k jmÇnu adres†©e
         call      mouseoff                 ; vypnut° my®i
         mov       si,offset selbuf
         call      outtxt                   ; zobrazen° c°le operace
         call      mouseon                  ; zapnut° my®i

                                          ;* £schova parametrñ souboru
         mov       si,9eh
         mov       di,offset outbuf         ; buffer k uloëen° zdroje
         call      transtxt                 ; £schova zdrojovÇho souboru
         mov       ax,ds:[98h]              ; datum
         mov       word ptr ds:[outbuf+20+16],ax ; datum
         mov       ax,ds:[96h]              ; áas
         mov       word ptr ds:[outbuf+20+18],ax ; áas
         mov       al,ds:[95h]              ; atributy
         mov       ds:[outbuf+20],al        ; atributy

                                          ;* test, zda soubor jië existuje
         call      testex                   ; pokud existuje, ru®en°
         jc        xcopf9                   ; p©eru®en° operace
         jnz       xcopf9                   ; operace se neprov†d°

                                          ;* proveden° funkce kop°rov†n°
         call      msgcek                   ; hl†®en° "áekejte"
         call      getoper                  ; poskytnut° k¢du operace
         or        al,al                    ; je kop°rov†n° ?
         jz        xcopf2                   ; je kop°rov†n°

         call      xmove                    ; p©esun souboru
         jmp       short xcopf22

xcopf2:  call      copyfk                   ; kop°rov†n° 1 souboru

xcopf22: pop       di                       ; pñvodn° adresa konce SELBUF
         mov       al,0                     ; ukonáovac° bajt 0
         stosb                              ; n†vrat pñvodn°ho konce SELBUF
         jc        xcopf7                   ; chyba operace

                                          ;* modifikace kapacity disku
         call      getoper                  ; poskytnut° k¢du operace
         or        al,al                    ; je kop°rov†n° ?
         jnz       xcopf47                  ; je p©esun - nezobraz° se kapacita
         call      cmpcdisk                 ; je c°lovò disk ?
         jne       xcopf3                   ; nen° c°lovò disk
         call      modikap                  ; modifikace kapacity disku
xcopf3:  push      bp
         mov       bp,cs:[bp+1]             ; adresa druhÇho okna
         call      cmpcdisk                 ; je c°lovò disk ?
         jne       xcopf4                   ; nen° c°lovò disk
         call      modikap                  ; modifikace kapacity o soubor
xcopf4:  pop       bp
xcopf47: xor       al,al                    ; operace OK
         jmp       short xcopf8

                                          ;* chyba operace
xcopf7:
         stc                                ; p©°znak chyby
xcopf8:  call      topret                   ; n†vrat horn°ho ©†dku
         ret

                                          ;* operace se neprovede nebo p©eru®en°
xcopf9:  pop       di                       ; pñvodn° adresa konce SELBUF
         mov       al,0                     ; ukonáovac° bajt 0
         stosb                              ; n†vrat pñvodn°ho konce SELBUF
         ret

; -----------------------------------------------------------------------------
;        P©esun souboru
; -----------------------------------------------------------------------------

PUBLIC   xmove
xmove:   call      cmpcdisk                 ; je p©esun mezi disky ?
         jne       xmove5                   ; je p©esun mezi disky

                                          ;* p©esun mezi adres†©i
ifndef   demo
         lea       dx,[selbuf]              ; jmÇno c°lovÇho souboru
         mov       ah,41h                   ; funkce ru®en° souboru
         int       21h                      ; zru®en° c°lovÇho souboru
endif
         lea       dx,[outbuf]              ; jmÇno pñvodn°ho souboru
         lea       di,[selbuf]              ; novÇ jmÇno souboru
ifndef   demo
         mov       ah,56h                   ; funkce p©ejmenov†n° souboru
         int       21h                      ; p©ejmenov†n° souboru
else
         call      prodldem
endif
xmove4:  ret

                                          ;* p©esun mezi disky
xmove5:  call      copyfk                   ; zkop°rov†n° souboru
         jc        xmove4                   ; chyba operace
         mov       dx,offset outbuf         ; pñvodn° soubor
         call      delfk                    ; zru®en° souboru
         ret

code     ends

         end

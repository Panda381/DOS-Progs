
; modul DOSMSEL.ASM - zad†n° volby

; *****************************************************************************
;
;                               Zad†n° voleb
;
; *****************************************************************************
extrn    kurzlin:near,skokax:near,obrlin:near,edilin:near,adrnadp:word
extrn    testakth:near,skokax:near
extrn    sellin:byte,numselb:word,ukazsel:word,topsel:word,pocpozsl:byte
extrn    pocradsl:byte,delkasel:byte,atribsel:byte,radkusel:word
extrn    kurzsel:word,firstsel:word,zobrlsel:byte,selbuf:byte
extrn    usesedit:near,outch1:near,outch10:near
extrn    rozbset:byte,rozbflg:byte,rozbnam:byte,rozbext:byte,rozbdat:byte
extrn    rozbcas:byte,rozbvel:dword,rozbats:byte,rozbatr:byte,rozbend:byte
extrn    obrlin:near,transtxt:near,center:near,outtxt:near
extrn    color:byte,lendi:near,lensi:near,outbuf:byte
extrn    highcase:near,windret:near,outch:near,col3:byte,col7:byte
extrn    col19:byte,aktpage:byte
extrn    testkey:near
extrn    edikey:word,inpkeyf:near
extrn    kurzout:near,flagsc:byte,getdispl:near,getakt:near

code     segment   public
         assume    cs:code,ds:code


public   select,select0,select1,select2,select3

select:                                   ;* zad†n° volby
                                            ; VSTUP: DS:SI=buffer pro zad†n°
                                            ;        DS:DI=text nadpisu
                                            ; VùSTUP: DS:SI=ukazatel na ©etàzec
                                            ;         AX=ukonáovac° kl†vesa
                                            ;         CY=p©eru®en° operace

         mov       ds:[adrnadp],di          ; adresa nadpisu
         push      es
         push      ds
         pop       es
         push      bx
         push      dx
         push      cx
         push      bp
                                          ;* zobrazen° n†povàdy pro editaci
         call      testsel                  ; test bufferu zad†n°
                                          ;* BH=max.®°©ka ©et., BL=poáet poloëek
         call      setwsel                  ; nastaven° parametrñ okna voleb
         call      selwin                   ; vykreslen° okna pro volby
select0: mov       bp,offset sellin         ; adresa definián° tabulky
         call      selall                   ; zobrazen° poloëek voleb
         mov       ax,ds:[kurzsel]          ; pozice kurzoru
         call      selset                   ; nastaven° parametrñ ©†dku

                                          ;* obsahy registrñ (nesm° se mànit !):
                                            ;        BH=maxim. dÇlka ©etàzce
                                            ;        BL=poáet poloëek
                                            ;        DL=poá†tek okna (0=aut.)
                                            ;        DH=©†dek okna (0=aut.)
                                            ;        CL=®°©ka okna (0=aut.)
                                            ;        CH=max. vò®ka okna (0=max.)

         call      kurzlin                  ; nastaven° kurzoru pro select
select1: call      inpkeyf                  ; vstup prvn°ho znaku
         or        ah,ah                    ; je znak s ALT ?
         je        select10                 ; je znak s ALT
         cmp       al,32                    ; je platnò znak ASCII ?
         jnb       select10                 ; je platnò znak ASCII
         cmp       ah,3bh                   ; kl†vesa F1
         jb        select21                 ; nen° platn† funkán° kl†vesa
         cmp       ah,44h                   ; kl†vesa F10
         ja        select21                 ; nen° platn† funkán° kl†vesa
select10:mov       word ptr ds:[ukazsel],0  ; nulov†n° ukazatele kurzoru
         mov       word ptr ds:[topsel],0   ; nulov†n° poá†tku zobrazen°
         mov       word ptr ds:[numselb],0  ; nulov†n° poátu znakñ v bufferu
         jmp       short select21
select2: call      inpkeyf                  ; vstup znaku
select21:or        ah,ah                    ; je znak s ALT ?
         jz        select22                 ; je znak s ALT
         cmp       ax,0300h                 ; je CTRL-@ ?
         je        select22                 ; je CTRL-@
         cmp       al,32                    ; je ASCII k¢d ?
         jae       select22                 ; je znak ASCII

         push      bx
         mov       bx,offset skoksel        ; tabulka skokñ do funkc°
         call      skokax                   ; skok do obsluhy funkce
         pop       bx
         jnc       select2                  ; obsluha byla provedena

select22:call      editsel                  ; obsluha editace ©†dku
;         jc        select2                  ; kl†vesa nebyla obslouëena
         jnz       select1                  ; byla zmàna kurzoru
         cmp       al,32                    ; je ©°dic° znak ?
         jae       select2                  ; je platnò znak ASCII

         push      cx
         push      di
         mov       di,offset tabsel
         mov       cx,10                    ; poáet znakñ v tabulce
         mov       al,ah
         repnz     scasb                    ; nalezen° k¢du v tabulce
         pop       di
         pop       cx
         je        select0                  ; bude prvn° znak
         jmp       select2




                                          ;* tabulka kl†ves - bude prvn° znak
tabsel   db        48h,8dh,50h,91h,77h,75h,49h,84h,51h,76h

select3:                                  ;* je ukonáen° ENTER

         push      ax

         push      di
         push      si
                                          ;* oznaáen° konce textu
         mov       si,offset selbuf         ; buffer s textem
         push      ax
         mov       ax,ds:[numselb]          ; poáet znakñ v bufferu
         push      si
         add       si,ax                    ; konec bufferu
         mov       byte ptr ds:[si],0       ; konec bufferu
         pop       si
         pop       ax

         call      rozbor                   ; proveden° rozboru zad†n°
edits2a: pop       si
         pop       di
         pop       ax
         call      storesel                 ; uloëen° poloëky do bufferu
         jmp       short select4

select5:                                  ;* uloëen° textu do bufferu CTRL-ENTER
         mov       si,offset selbuf          ; buffer s textem
         push      bp
         push      ax
         push      cx
         push      si
         call      getakt                   ; poskytnut° aktivn°ho okna
         mov       cx,ds:[numselb]          ; poáet znakñ v bufferu
         jcxz      edits2d
edits2c: lodsb
         xor       ah,ah
         call      usesedit                 ; uloëen° znaku
         loop      edits2c
edits2d: mov       al," "
         xor       ah,ah
         call      usesedit                 ; ukonáovac° mezera
         pop       si
         pop       cx
         pop       ax
         pop       bp
                                          ;* ukonáen° ESC
select4: add       sp,6                     ; zru®en° n†vratovÇ adresy
         push      si
         pop       si
         cmp       al,13                    ; je ukonáen° ENTER ?
         je        select25
         stc
select25:pop       bp
         pop       cx
         pop       dx
         pop       bx
         pop       es
         call      kurzout                  ; vypnut° kurzoru
         ret


skoksel  label     word                     ; tabulka skokñ do obsluhy SELECT
         db        00h+3                    ; testuje se AL
         db        0dh                      ; ukonáen° editace ENTER
         dw        select3
         db        0ah                      ; p©eru®en° editace CTRL-ENTER
         dw        select5
         db        1bh                      ; p©eru®en° editace ESC
         dw        select4
         db        0

; -----------------------------------------------------------------------------
public   editsel

editsel:                                  ;* obsluha editace ©†dku
                                            ; VùSTUP: ;CY=kl†vesa nebyla obslouë.
                                            ;         ZN=byla zmàna okna

         push      ax                       ; £schova k¢du kl†vesy
         push      word ptr ds:[kurzsel]    ; £schova pozice kurzoru
         push      word ptr ds:[firstsel]   ; £schova prvn° poloëky
         call      edilin                   ; obsluha editace ©†dku
         pop       ax                       ; n†vrat prvn° poloëky
         cmp       ax,ds:[firstsel]         ; byla zmànàna prvn° poloëka ?
editsel1:pop       ax                       ; n†vrat pozice kurzoru
         jne       editsel2                 ; byla zmàna prvn° poloëky
         cmp       ax,ds:[kurzsel]          ; byla zmànàna pozice kurzoru ?
         je        editsel3                 ; nebyla zmàna kurzoru
editsel2:pushf                              ; £schova registru p©°znakñ
         call      selall                   ; zobrazen° poloëek voleb
         mov       al,byte ptr ds:[kurzsel] ; pozice kurzoru
         call      selset                   ; nastaven° parametrñ ©†dku
         call      kurzlin                  ; nastaven° kurzoru pro select
         popf                               ; n†vrat registru p©°znakñ
editsel3:pop       ax                       ; n†vrat k¢du kl†vesy
         ret

; -----------------------------------------------------------------------------
public   storesel

storesel:                                 ;* uloëen° poloëky do bufferu
                                            ; VSTUP:DS:SI=buffer poloëek
                                            ; VùSTUP: DS:SI=adresa textu ASCIIZ

         push      ax
         push      bx
         push      cx
         push      di
                                          ;* pokud poloëka existuje, zru®° se
         call      srcident                 ; nalezen° stejnÇ poloëky v seznamu
         jc        stores1                  ; stejn† poloëka nenalezena
         call      delselect                ; vypu®tàn° poloëky ze seznamu
                                          ;* nalezen° konce poloëek bufferu
stores1: mov       cx,ds:[si]               ; dÇlka bufferu
         mov       di,si                    ; zaá†tek dat bufferu - 2
         add       si,2                     ; zaá†tek dat bufferu
         inc       di
stores3: inc       di
         cmp       word ptr ds:[di],0       ; je konec bufferu ?
         loopnz    stores3                  ; nalezen° konce bufferu
                                          ;* nen°-li 1.poloëka, ponech† oddàl.0
         cmp       si,di                    ; je nàjak† poloëka v bufferu ?
         je        stores2                  ; v bufferu nen° ë†dn† poloëka
         inc       di                       ; ponech† jednu oddàlovac° 0
         dec       cx                       ; sn°ëen° poátu zbylòch znakñ
stores2:                                  ;* kontrola dostateánÇho prostoru
         mov       bx,ds:[numselb]          ; dÇlka dat v bufferu (k uloëen°)
         push      bx
         add       bx,2                     ; rezerva pro koncovÇ nuly
         cmp       bx,cx                    ; postaáuje kapacita ?
         pop       bx
         jb        stores4                  ; kapacita postaáuje
         xor       al,al                    ; ru®° se poloëka 0
         sub       si,2                     ; n†vrat zaá†tku bufferu
         call      delselect                ; zru®en° poloëky 0
         jmp       short stores1
                                          ;* dostateán† pakacita - uloëen°
stores4: mov       cx,bx                    ; dÇlka dat k p©enosu
         mov       si,offset selbuf         ; buffer s ukl†danòm textem
         push      di                       ; adresa zaá†tku textu
         rep       movsb                    ; uloëen° textu
         xor       ax,ax                    ; koncovÇ slovo 0
         stosw                              ; uloëen° koncovÇho slova 0
         pop       si                       ; text uloëenÇho textu
         pop       di
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   srcident

srcident:                                 ;* nalezen° stejnÇ poloëky ze seznamu
                                            ; VSTUP:DS:SI=buffer poloëek
                                            ; VùSTUP: AL=á°slo poloëky
                                            ;         CY=poloëka nenalezena AL=0

         push      bx
         push      cx
         push      dx
         push      si
         push      di
                                          ;* nastaven° parametrñ
         lodsw                              ; dÇlka bufferu
         mov       cx,ax                    ; dÇlka bufferu
         mov       bx,ds:[numselb]          ; dÇlka textu v bufferu
         or        bl,bl                    ; je nàjakò znak v bufferu ?
         jz        srcid7                   ; nen° ë†dnò znak v bufferu
                                          ;* zaá†tek porovn†n° jednÇ poloëky
srcid1:  jcxz      srcid7                   ; je konec bufferu - text nenalezen
         cmp       byte ptr ds:[si],0       ; je jië konec bufferu ?
         je        srcid7                   ; je jië konec bufferu - nenalezen
         mov       di,offset selbuf         ; buffer se zadanòm textem
         push      bx                       ; £schova á°taáe poloëek a dÇlky
                                          ;* cyklus porovn†n° jednoho znaku
srcid2:  lodsb                              ; znak z bufferu poloëek
         or        al,al                    ; je jië konec ©etàzce ?
         jz        srcid3                   ; je konec ©etàzce
         or        bl,bl                    ; je konec textu ?
         jz        srcid4                   ; je konec textu
         cmp       al,ds:[di]               ; porovn†n° se zadanòm textem
         jne       srcid4                   ; nen° shoda ©etàzcñ
         inc       di                       ; zvò®en° adresy zadanÇho textu
         dec       bl                       ; sn°ëen° á°taáe dÇlky textu
         loop      srcid2                   ; test dal®°ho znaku
srcid3:  or        bl,bl                    ; je i konec textu ?
         pop       bx                       ; n†vrat BX
         jz        srcid9                   ; jsou konce obou ©etàzcñ
         inc       bh                       ; zvò®en° á°taáe poloëek
         jmp       short srcid1             ; nen° shoda ©etàzcñ - dal®°
                                          ;* nalezen rozd°l ©etàzcñ
srcid4:  dec       cx
         jz        srcid6                   ; konec bufferu
srcid5:  lodsb
         or        al,al
         loopnz    srcid5                   ; nalezen° konce ©etàzce
srcid6:  pop       bx
         inc       bh                       ; zvò®en° á°taáe ©etàzcñ
         jmp       short srcid1             ; test dal®°ho ©etàzce
                                          ;* je konec bufferu - text nenalezen
srcid7:  xor       bh,bh
         stc                                ; p©°znak - poloëka nenalezena
srcid9:  mov       al,bh                    ; á°slo nalezenÇ poloëky
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         ret

; -----------------------------------------------------------------------------
public   delselect

delselect:                                ;* vypu®tàn° poloëky ze seznamu
                                            ; VSTUP:DS:SI=buffer poloëek
                                            ;       AL=á°slo poloëky
                                            ; VùSTUP: CY=poloëka nenalezena

         push      ax
         push      cx
         push      si
         push      di
                                          ;* nalezen° adresy ru®enÇ poloëky
         mov       cx,ds:[si]               ; dÇlka bufferu
         add       si,2                     ; zaá†tek textñ
         mov       ah,al                    ; á°taá ©etàzcñ
delsel2: cmp       byte ptr ds:[si],0       ; je jië konec bufferu ?
         stc                                ; p©°znak chyby
         jz        delsel4                  ; je konec bufferu - nenalezen
         jcxz      delsel4                  ; konec bufferu
         or        ah,ah                    ; je poëadovanò ©etàzec ?
         jz        delsel3                  ; nalezen poëadovanò ©etàzec
                                          ;* nalezen° zaá†tku dal®° poloëky
delsel5: lodsb                              ; naáten° znaku
         or        al,al                    ; je konec ©etàzce ?
         loopnz    delsel5                  ; nalezen° konce ©etàzce
         dec       ah                       ; sn°ëen° á°taáe ©etàzcñ
         jmp       short delsel2            ; dal®° ©etàzec
                                          ;* poloëka nalezena
delsel3: mov       di,si                    ; £schova zaá†tku ru®enÇ poloëky
                                          ;* nalezen° zaá†tku n†sled. poloëky
delsel1: lodsb                              ; naáten° znaku poloëky
         or        al,al                    ; je konec poloëky ?
         loopnz    delsel1                  ; nalezen° konce poloëky
         rep       movsb                    ; p©enos textu - vypu®tàn° poloëky
         mov       byte ptr ds:[di],0       ; oznaáen° konce bufferu
delsel4: pop       di
         pop       si
         pop       cx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   selall

selall:                                   ;* zobrazen° v®ech poloëek voleb
                                            ; VSTUP:DS:SI=buffer poloëek
                                            ;       DL=poá†tek okna
                                            ;       DH=©†dek okna
                                            ;       CL=®°©ka okna
                                            ;       CH=vò®ka okna

         push      ax
         push      cx
         push      dx
         mov       al,byte ptr ds:[firstsel] ; prvn° zobrazen† poloëka voleb
         mov       ah,ds:[zobrlsel]         ; poáet poloëek k zobrazen°
         or        ah,ah
         jz        selall2                  ; nen° ë†dn† poloëka
selall1: call      selset                   ; nastaven° parametrñ poloëky
         call      obrlin                   ; zobrazen° ©†dku
         inc       al                       ; zvò®en° á°sla poloëky
         dec       ah                       ; sn°ëen° á°taáe ©†dkñ
         jnz       selall1                  ; zobrazen° dal®° poloëky
selall2: pop       dx
         pop       cx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   selset

selset:                                   ;* nastaven° parametrñ poloëky
                                            ; VSTUP: DS:SI=buffer poloëek
                                            ;        AL=á°slo poloëky k zobraz.
                                            ;        DH=poá†teán° ©†dek okna
                                            ;        DL=poá†teán° pozice okna
                                            ;        CL=®°©ka okna
                                            ;        CH=vò®ka okna

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      ax                       ; á°slo poloëky
         mov       ah,ds:[col7]             ; barva pro norm†ln° poloëku
         cmp       al,byte ptr ds:[kurzsel] ; je poloëka s kurzorem ?
         jne       selpol0                  ; nen° poloëka s kurzorem
         mov       ah,ds:[col19]            ; barva poloëky s kurzorem
selpol0: mov       ds:[atribsel],ah         ; barva pro zobrazen° poloëky
         call      askselx                  ; poskytnut° adresy poloëky
         cbw
         mov       ds:[numselb],ax          ; nastaven° dÇlky textu
         mov       di,offset selbuf         ; buffer pro editaci
         call      transtxt                 ; p©enesen° textu
         xor       ax,ax
         mov       ds:[ukazsel],ax          ; pozice kurzoru
         mov       ds:[topsel],ax           ; poá†tek zobrazen° ©†dku
         pop       ax                       ; á°slo poloëky
         sub       al,byte ptr ds:[firstsel] ; odeáten° prvn° poloëky
         add       al,dh                    ; p©iáten° poá†teán°ho ©†dku
         add       al,2                     ; p©iáten° spodn°ho okraje
         mov       ds:[pocradsl],al         ; nastaven° ©†dku k zobrazen°
selpol6: pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   selwin

selwin:                                   ;* vykreslen° okna pro volby
                                            ; VSTUP:DS:DI=text nadpisu
                                            ;       DL=poá†tek okna
                                            ;       DH=©†dek okna
                                            ;       CL=®°©ka okna
                                            ;       CH=vò®ka okna

         push      ax
         mov       al,7                     ; barva pro okno volby
         call      outch1                   ; nastaven° barvy á°slo 7
         call      podklad                  ; vykreslen° podkladu okna
         call      wram1                    ; zobrazen° vnit©n°ho r†meáku
         call      wram2                    ; zobrazen° vnàj®°ho r†meáku
         call      wnadpis                  ; zobrazen° nadpisu okna
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   podklad

podklad:                                  ;* vykreslen° podkladu pod oknem
                                            ; VSTUP: DL=poá†tek okna
                                            ;        DH=©†dek okna
                                            ;        CL=®°©ka okna
                                            ;        CH=vò®ka okna

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp

         mov       ax,600h                  ; funkce vymaz†n° okna
         mov       bh,ds:[color]            ; barva pro podklad okna
         xchg      cx,dx                    ; CX <- pozice levÇho horn°ho rohu
         add       dl,cl                    ; koncov† pozice + 1
         dec       dl                       ; koncov† pozice
         add       dh,ch                    ; koncovò ©†dek + 1
         dec       dh                       ; koncovò ©†dek
         int       10h                      ; vymaz†n° okna

         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   wram1

wram1:                                    ;* zobrazen° vnit©n°ho r†mu okna
                                            ; VSTUP: DL=poá†tek okna
                                            ;        DH=©†dek okna
                                            ;        CL=®°©ka okna
                                            ;        CH=vò®ka okna

         push      ax
         push      cx
         push      dx
                                          ;* inicializace parametrñ
         inc       dh                       ; druhò ©†dek
         add       dl,3                     ; poá†teán° pozice
         sub       cl,8                     ; ®°©ka okna - 8
         sub       ch,4                     ; vò®ka okna - 4
                                          ;* vykreslen° horn° linky
         push      cx                       ; rozmàry okna
         push      dx                       ; sou©adnice okna
         mov       al,218                   ; levò horn° roh
         call      outch1                   ; vykreslen° levÇho horn°ho rohu
         xor       ch,ch                    ; CH <- 0
         mov       al,196                   ; vodorovn† linka
         call      outch                    ; vykreslen° horn° linky
         mov       al,191                   ; pravò horn° roh
         call      outch1                   ; vykreslen° pravÇho horn°ho rohu
         pop       dx
         pop       cx
         inc       dh                       ; ©†dek + 1
                                          ;* vykreslen° vnit©n°ch ©†dkñ
wram11:  push      cx
         push      dx
         mov       al,179                   ; lev† linka
         call      outch1                   ; vykreslen° levÇ linky
         add       dl,cl                    ; zvò®en° pozice
         call      outch1                   ; vykreslen° pravÇ linky
         pop       dx
         pop       cx
         inc       dh                       ; zvò®en° ©†dku
         dec       ch                       ; sn°ëen° á°taáe ©†dkñ
         jnz       wram11                   ; dal®° ©†dek
                                          ;* zobrazen° spodn° linky
         mov       al,192                   ; levò doln° roh
         call      outch1                   ; vykreslen° levÇho doln°ho rohu
         mov       al,196                   ; vodorovn† linka
         call      outch                    ; vykreslen° doln° linky
         mov       al,217                   ; pravò doln° roh
         call      outch1                   ; vykreslen° pravÇho doln°ho rohu
         pop       dx
         pop       cx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   wram2

wram2:                                    ;* zobrazen° vnàj®°ho r†mu okna
                                            ; VSTUP: DL=poá†tek okna
                                            ;        DH=©†dek okna
                                            ;        CL=®°©ka okna
                                            ;        CH=vò®ka okna

         push      ax
         push      cx
         push      dx
         mov       al,176                   ; zobrazovanò znak
                                          ;* zobrazen° horn° linky
         push      cx
         push      dx
         xor       ch,ch
         call      outch                    ; horn° linka
         pop       dx
         pop       cx
         inc       dh                       ; zvò®en° á°sla ©†dku
         sub       ch,2                     ; odeáten° horn°ho a doln°ho okraje
wram21:                                   ;* zobrazen° vnit©n°ch ©†dkñ
         push      cx
         push      dx
         call      outch1                   ; levò okraj
         call      outch1
         add       dl,cl                    ; zvò®en° pozice pro pravò okraj
         sub       dl,4                     ; odeáten° okrajñ
         call      outch1
         call      outch1                   ; pravò okraj
         pop       dx
         pop       cx
         inc       dh                       ; zvò®en° á°sla ©†dku
         dec       ch                       ; sn°ëen° á°taáe ©†dkñ
         jnz       wram21                   ; zobrazen° dal®°ho ©†dku
                                          ;* zobrazen° spodn°ho ©†dku
         xor       ch,ch
         call      outch                    ; spodn° linka

         pop       dx
         pop       cx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   wnadpis

wnadpis:                                  ;* zobrazen° nadpisu okna
                                            ; VSTUP:DS:DI=text nadpisu
                                            ;       DL=poá†tek okna
                                            ;       DH=©†dek okna
                                            ;       CL=®°©ka okna
                                            ;       CH=vò®ka okna
         push      ax
         push      dx
         push      si

         mov       si,di                    ; text
wnadpis1:push      dx                       ; £schova sou©adnice
         push      cx
         call      center                   ; centrov†n° textu nadpisu
         inc       dh                       ; prvn° ©†dek
         call      outtxt                   ; zobrazen° textu nadpisu
         pop       cx
         pop       dx
         inc       dh                       ; zvò®en° ©†dku
         cmp       byte ptr ds:[si-1],31    ; byl konec ©†dku ?
         je        wnadpis1                 ; zobrazen° dal®°ho ©†dku
         pop       si
         pop       dx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   setwsel

setwsel:                                  ;* nastaven° okna pro volby
                                            ; VSTUP: DI=text nadpisu
                                            ;        BH=maxim. dÇlka ©etàzce
                                            ;        BL=poáet poloëek
                                            ; VùSTUP:DL=poá†tek okna
                                            ;        DH=©†dek okna
                                            ;        CL=®°©ka okna
                                            ;        CH=vò®ka okna

         push      ax
                                          ;* nastaven° ®°©ky okna
         mov       cl,bh                    ; maxim†ln° dÇlka ©etàzce
         call      lendi                    ; zji®tàn° dÇlky ©etàzce DI
         cmp       al,cl                    ; je dÇlka vàt®° neë nalezen† ?
         jna       setwsl04                 ; dÇlka nen° vàt®°
         mov       cl,al                    ; nastaven° novÇ dÇlky textu
setwsl04:cmp       cl,60                    ; je dÇlka ©etàzce vàt®° neë 60 ?
         jna       setwsl11                 ; ®°©ka nen° vàt®° neë 60
         mov       cl,60                    ; omezen° na ®°©ku 60
setwsl11:cmp       cl,12                    ; minim†ln° ®°©ka poloëky
         jnb       setwsl12                 ; nen° men®° neë 12
         mov       cl,12                    ; omezen° na 12
setwsl12:mov       ds:[delkasel],cl         ; nastaven° ®°©ky textu pro editaci
         add       cl,10                    ; p©iáten° okrajñ
                                          ;* nastaven° vò®ky okna
         push      dx
         call      getdispl
         sub       dh,7                     ; max. poáet poloëek
setwsl2: mov       ch,bl                    ; poáet poloëek
         cmp       ch,dh                    ; je vàt®° poáet poloëek neë 17 ?
         jna       setwsl21                 ; nen° vàt®° poáet poloëek neë 17
         mov       ch,dh                    ; omezen° na 17 poloëek
setwsl21:or        ch,ch                    ; je nàjak† poloëka ?
         jnz       setwsl22                 ; je nàjak† poloëka
         inc       ch                       ; alespo§ 1 poloëka
setwsl22:add       ch,4                     ; p©iáten° okrajñ
         pop       dx
                                         ;* nastaven° poá†tku okna
setwsl3: mov       dl,80                    ; ®°©ka obrazovky
         sub       dl,cl                    ; odeáten° ®°©ky okna
         shr       dl,1                     ; offset od zaá†tku ©†dku
         mov       al,dl                    ; poá†teán° pozice
         add       al,5                     ; odeáten° pravÇho okraje
         mov       ds:[pocpozsl],al         ; nastaven° poá†teán° pozice editace
                                          ;* nastaven° poá†teán°ho ©†dku okna
setwsl4: call      getdispl                 ; vò®ka obrazovky
         inc       dh
         sub       dh,ch                    ; odeáten° vò®ky okna
         shr       dh,1                     ; poáet ©†dkñ nad oknem
         mov       ah,dh
         shr       ah,1
         sub       dh,ah                    ; korekce k horn°mu okraji
setwsl5:                                  ;* nastaven° prvn° zobrazenÇ poloëky
         xor       ax,ax
         mov       al,bl                    ; poáet poloëek
         mov       ds:[radkusel],ax         ; nastaven° celkovÇho poátu ©†dkñ
         mov       ds:[kurzsel],ax          ; nastaven° kurzoru na posledn° pol.
         dec       ax
         js        setwsl52
         mov       ds:[kurzsel],ax          ; nastaven° kurzoru na posledn° pol.
setwsl52:mov       al,bl                    ; poáet poloëek
         xor       ah,ah
         sub       al,ch                    ; odeáten° vò®ky okna
         add       al,4                     ; korekce okrajñ
         jns       setwsl53
         xor       al,al
setwsl53:mov       ds:[firstsel],ax         ; prvn° zobrazen† poloëka
         mov       al,ch                    ; vò®ka okna
         sub       al,4                     ; odeáten° okrajñ
         mov       ds:[zobrlsel],al         ; poáet zobrazenòch ©†dkñ
         mov       al,ds:[col3]             ; atributy pro editaci ©†dku
         mov       ds:[atribsel],al         ; nastaven° atributñ
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   asksel,askselx


askselx:                                  ;* poskytnut° poloëky s kontrolou

asksel:                                   ;* poskytnut° poloëky zad†n°
                                            ; VSTUP: SI=buffer pro zad†n°
                                            ;        AL=á°slo poloëky 0...
                                            ; VùSTUP: DS:SI=adresa poloëky
                                            ;         AL=dÇlka poloëky
         push      bx
         push      cx
         push      dx
         push      di
                                          ;* inicializace parametrñ
         mov       dl,al                    ; á°taá poloëek (á°slo poloëky)
         lodsw                              ; naáten° dÇlky bufferu
         mov       di,si                    ; ukazatel ©etàzce
         mov       cx,ax                    ; á°taá znakñ bufferu
         xor       al,al                    ; AL <- 0
                                          ;* nalezen° ©etàzce v bufferu
asksel1: cmp       al,[di]                  ; je jië konec dat ?
         je        asksel2                  ; je konec dat v bufferu
         or        dl,dl                    ; je poëadovanò ©etàzec ?
         jz        asksel4                  ; ©etàzec nalezen
         dec       dl                       ; sn°ëen° á°taáe ©etàzcñ
         repnz     scasb                    ; nalezen° konce ©etàzce
         jz        asksel1                  ; nen° je®tà konec - dal®° ©etàzec
asksel2:                                  ;* konec bufferu - budou p©edvolby
         add       di,cx                    ; konec bufferu
         mov       bx,di                    ; £schova adresy konce dat
         mov       si,di
         lodsb                              ; poáet poloëek p©edvoleb
         mov       dh,al                    ; á°taá poloëek p©edvoleb
asksel3: xor       ax,ax
         or        dh,dh                    ; je je®tà nàjak† poloëka ?
         jz        asksel8                  ; poloëka nenalezena
         lodsw                              ; naáten° adresy poloëky
         dec       dh                       ; sn°ëen° á°taáe poloëek
         mov       di,ax                    ; adresa poloëky
         dec       dl                       ; sn°ëen° á°taáe poloëek
         jns       asksel3                  ; nen° je®tà poëadovanò ©etàzec
asksel4:                                  ;* nalezen ©etàzec
         xor       al,al                    ; AL <- 0
         mov       bx,di                    ; £schova zaá†tku ©etàzce
         mov       cx,255                   ; maxim†ln° dÇlka ©etàzce
         repnz     scasb                    ; nalezen° dÇlky ©etàzce
         sub       di,bx                    ; dÇlka ©etàzce
         mov       ax,di                    ; dÇlka ©etàzce
         dec       ax
asksel8: mov       si,bx                    ; adresa zaá†tku ©etàzce
         or        ah,ah                    ; je ©etàzec del®° neë 255 ?
         jz        asksel9                  ; nen° vàt®° neë 255
         mov       al,255                   ; n†hradn° dÇlka ©etàzce
asksel9: pop       di
         pop       dx
         pop       cx
         pop       bx
         ret

; -----------------------------------------------------------------------------
public   testsel

testsel:                                  ;* test bufferu zad†n°
                                            ; VSTUP: DS:SI=buffer pro zad†n°
                                            ; VùSTUP: BH=maxim. dÇlka ©etàzce
                                            ;         BL=poáet poloëek

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         xor       bx,bx                    ; BH=max. dÇlka, BL=poáet poloëek
testsl1: mov       al,bl                    ; poëadovanò ©etàzec
         push      si                       ; £schova adresy bufferu
         call      askselx                  ; test poloëky
         pop       si                       ; n†vrat adresy bufferu
         or        al,al                    ; je jië posledn° ©etàzec ?
         jz        testsl3                  ; byl to posledn° ©etàzec
         inc       bl                       ; zvò®en° á°taáe poloëek
         jz        testsl2                  ; p©eteáen° poátu ©etàzcñ
         cmp       al,bh                    ; maxim†ln° dÇlka ©etàzcñ
         jb        testsl1                  ; nen° vàt®° dÇlka
         mov       bh,al                    ; nov† maxim†ln° dÇlka
         jmp       short testsl1
testsl2: dec       bl                       ; BL <- 255 max. poáet ©etàzcñ
testsl3: pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   rozbor

rozbor:                                   ;* rozbor zad†n° operac°
                                            ; VSTUP: DS:SI=zadanò text
                                            ; VùSTUP: CY=chyba
                                            ;         DS:DI=adresa chyby
                                            ; ROZBSET a OUTBUF=vòsledky rozboru

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      es
         push      cs
         pop       es
                                          ;* inicializace bufferu
         mov       di,offset rozbset        ; buffer rozboru
         push      di
         mov       cx,30                    ; dÇlka bufferu rozboru
         mov       al,"?"                   ; n†hradn° znak
         rep       stosb                    ; inicializace bufferu
         pop       di                       ; adresa zaá†tku bufferu
         xor       ax,ax
         mov       ds:[di+0],al             ; vynulov†n° p©°znakñ rozboru
         mov       ds:[di+24],ax            ; nië®° slovo velikosti
         mov       ds:[di+26],ax            ; vy®®° slovo velikost
         mov       ds:[di+28],ax            ; atributy
         mov       ds:[outbuf],al           ; zru®en° textu v bufferu cesty
rozbor1:                                  ;* rozbor jednÇ poloëky zad†n°
         call      outspc                   ; vypu®tàn° poá†teán°ch mezer
         jz        rozbor9                  ; je konec textu
         call      rozbornam                ; rozbor jmÇna souboru
         jc        rozbor8                  ; chyba zad†n°
         jmp       short rozbor1            ; dal®° rozbor

rozbor7: dec       si                     ;* chyba zad†n° parametrñ
         dec       si
rozbor8: call      outspc                   ; vypu®tàn° mezer
         stc
         mov       di,si                    ; adresa chyby
rozbor9: pop       es
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   outspc

outspc:                                   ;* vypu®tàn° mezer s DS:SI (ASCIIZ)
                                            ; VùSTUP: ZY=je konec textu

         cmp       byte ptr ds:[si],0       ; je jië konec textu ?
         jne       outspc0                  ; nen° konec textu
outspc2: ret

outspc0: cmp       byte ptr ds:[si]," "     ; je mezera ?
         ja        outspc2                  ; nen° mezera
         inc       si                       ; zvò®en° adresy textu
         jmp       short outspc             ; test dal®°ho znaku

; -----------------------------------------------------------------------------
public   rozbornam

rozbornam:                                ;* rozbor jmÇna souboru
                                            ; VùSTUP: CY=chyba
                                            ;         ZY=nen° ë†dnò text

         and       byte ptr cs:[flagsc],not 8 ; zru®en° p©°znaku zad†n° p©°pony
         mov       di,offset outbuf         ; buffer pro uloëen° cesty
         call      rozborpath               ; rozbor cesty souboru
         mov       di,offset rozbnam        ; adresa k uloëen° jmÇna
         jnc       rozbnam0                 ; zad†n° cesty OK
         ret

rozbnam0:call      outspc                   ; vypu®tàn° mezer
         cmp       byte ptr ds:[si]," "     ; je platnò znak ?
         ja        rozbnam6                 ; je nàjakò text
         cmp       al,al                    ; nastaven° p©°znaku ZY
         ret
rozbnam6:                                 ;* kontrola, zda jië bylo jmÇno zad†no
         push      di
         push      cx
         mov       al,"?"                   ; n†hradn° znak
         mov       cx,11                    ; poáet znakñ ke kontrole
         repz      scasb                    ; kontrola zad†n°
         pop       cx
         pop       di
         je        rozbnam1                 ; nebylo je®tà zad†no jmÇno souboru
         stc                                ; p©°znak chyby
         ret

rozbnam1:                                 ;* rozbor jmÇna souboru

public   rozborn

rozborn:                                  ;* rozbor jmÇna souboru s p©°ponou
                                            ; VSTUP: DS:SI=ukazatel textu
                                            ;        ES:DI=adresa k uloëen° rozboru
                                            ; VùSTUP: DS:SI=nov† adresa textu
         push      ax
         push      cx
         push      di

         push      di
         mov       cx,11
         call      rozbnm02                 ; vymaz†n° bufferu
         pop       di
                                          ;* je adres†© ".."
         cmp       word ptr ds:[si],".."    ; je nadadres†© ?
         jne       rozbnam3                 ; nen° nadadres†©
         movsw                              ; p©enos oznaáen°
         jmp       short rozbnam5           ; konec rozboru
                                          ;* rozbor jmÇna
rozbnam3:mov       cl,8                     ; dÇlka jmÇna = 8
         call      rozbnm0                  ; rozbor jmÇna
         inc       si                       ; p©eskoáen° p©°padnÇho znaku "."
         cmp       byte ptr ds:[si-1],"."   ; n†sleduje oddàlovaá "." ?
         je        rozbnam4                 ; n†sleduje oddàlovaá "."
         dec       si                       ; n†vrat znaku
         cmp       ah,"."                   ; n†sleduje p©°pona ?
         jne       rozbnam5                 ; nen†sleduje p©°pona
rozbnam4:or        byte ptr cs:[flagsc],8   ; p©°znak zad†n° p©°pony (teáka)
         mov       cl,3                     ; dÇlka p©°pony
         call      rozbnm0                  ; rozbor p©°pony
rozbnam5:clc                                ; p©°znak - operace OK
         pop       di
         pop       cx
         pop       ax
         ret


public   rozbnm0

rozbnm0:                                  ;* rozbor jmÇna nebo p©°pony
                                            ; VSTUP: CX=poáet znakñ
                                            ;        DS:SI=ukazatel textu
                                            ;        ES:DI=ukl†dac° adresa
                                            ; VùSTUP: AH=poslednà naátenò znak

         mov       al,ds:[si]               ; naáten° znaku
         call      highcase                 ; p©evod na velkÇ p°smeno
         mov       ah,al                    ; £schova poslednà naátenÇho znaku
         cmp       al," "                   ; je platnò znak ?
         jb        rozbnm02                 ; je konec textu
         cmp       al,"\"                   ; je oddàlovaá textu ?
         je        rozbnm02                 ; je konec textu
         cmp       al,":"                   ; je oddàlovaá diskñ ?
         je        rozbnm02                 ; je konec textu
         cmp       al,"/"                   ; je oddàlovaá parametrñ ?
         je        rozbnm02                 ; je konec textu
         inc       si                       ; zvò®en° pozice
         cmp       al,"."                   ; je konec jmÇna ?
         je        rozbnm02                 ; je konec jmÇna
         cmp       al,"*"                   ; je konvence "*" ?
         je        rozbnm01                 ; je konvence "*"
         stosb                              ; uloëen° znaku jmÇna
         loop      rozbnm0                  ; p©enos dal®°ho znaku
         ret
                                          ;* vymaz†n° zbytku jmÇna
rozbnm01:mov       al,"?"                   ; dopl§uj°c° znak - otazn°k
         jmp       short rozbnm03           ; doplnàn° znakem

rozbnm02:mov       al," "                   ; dopl§uj°c° znak - mezera
rozbnm03:rep       stosb                    ; doplnàn° textu znakem
         ret

; -----------------------------------------------------------------------------
public   rozborpath

rozborpath:                               ;* rozbor cesty k souboru
                                            ; VSTUP: DS:SI=ukazatel textu
                                            ;        DS:DI=ukl†dac° buffer
                                            ; VùSTUP: CY=chyba zad†n°
                                            ;         ZY=nen° dal®° text

         call      outspc                   ; vypu®tàn° mezer
         cmp       byte ptr ds:[si]," "     ; je platnò znak ?
         ja        rozbpth1                 ; je nàjakò text
         cmp       al,al                    ; nastaven° p©°znaku ZY
         ret
                                          ;* nastaven° disku
rozbpth1:cmp       byte ptr ds:[di],0       ; je jië text v bufferu ?
         jne       rozbpth8                 ; chyba - cesta jië byla zad†na
         lodsb                              ; naáten° prvn°ho znaku
         call      highcase                 ; p©evod na velkÇ p°smeno
         mov       ah,":"                   ; oznaáen° disku
         cmp       ds:[si],ah               ; je zad†n° disku ?
         je        rozbpth2                 ; je zad†n disk
         dec       si                       ; navr†cen° znaku
         jmp       short rozbpth7
rozbpth2:inc       si                       ; p©eskoáen° oznaáen° disku
         stosw                              ; uloëen° oznaáen° disku
         mov       byte ptr es:[di],0       ; konec oznaáen° disku
                                          ;* nastaven° cesty k adres†©i
rozbpth7:mov       cx,69                    ; maxim†ln° dÇlka textu
         mov       bx,di                    ; zaá†tek ukl†dac° cesty adres†©e
         push      si                       ; zaá†tek cesty k disku
         push      di
rozbpth3:lodsb
         call      highcase                 ; p©evod na velkÇ p°smeno
         cmp       al," "
         jbe       rozbpth6                 ; je konec textu
         cmp       al,"/"
         je        rozbpth6
         cmp       al,"\"
         jne       rozbpth4
         add       sp,4
         push      si                       ; nastaven° novÇ adresy konce cesty
         push      di
rozbpth4:stosb
         loop      rozbpth3
rozbpth6:pop       di                       ; konec cesty
         pop       si                       ; zaá†tek jmÇna
         cmp       di,bx
         jne       rozbpthb                 ; nen° zaá†tek cesty
         cmp       byte ptr es:[di],"\"     ; je to znak oddàlovaáe ?
         je        rozbptha                 ; je oddàlovaá
rozbpthb:cmp       word ptr es:[di-1],"\:"  ; je oddàlovaá za jmÇnem disku ?
         jne       rozbpth9                 ; nen° prvn° oddàlovaá za diskem
rozbptha:inc       di                       ; p©eskoáen° oddàlovaáe
rozbpth9:xor       al,al
         stosb                              ; uloëen° koncovÇ 0
         inc       al
         clc
         ret

rozbpth8:stc                                ; p©°znak chyby
         ret

; -----------------------------------------------------------------------------

code     ends

         end

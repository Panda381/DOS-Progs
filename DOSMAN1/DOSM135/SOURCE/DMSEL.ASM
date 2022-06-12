
; modul DOSMSEL.ASM - zad†n° volby

; *****************************************************************************
;
;                               Zad†n° voleb
;
; *****************************************************************************
extrn    kurzlin:near,skokax:near,obrlin:near,edilin:near,adrnadp:word
extrn    testakth:near,helped:byte,outthlp:near,inpkey:near,skokax:near
extrn    sellin:byte,numselb:word,ukazsel:word,topsel:word,pocpozsl:byte
extrn    pocradsl:byte,delkasel:byte,atribsel:byte,radkusel:word
extrn    kurzsel:word,firstsel:word,zobrlsel:byte,selbuf:byte
extrn    usesedit:near,outch1:near,outch10:near,selbufz:byte
extrn    rozbset:byte,rozbflg:byte,rozbnam:byte,rozbext:byte,rozbdat:byte
extrn    rozbcas:byte,rozbvel:dword,rozbats:byte,rozbatr:byte,rozbend:byte
extrn    obrlin:near,transtxt:near,center:near,outtxt:near
extrn    color:byte,lendi:near,lensi:near,outbuf:byte
extrn    highcase0:near,windret:near,outch:near,col3:byte,col7:byte
extrn    col19:byte,aktpage:byte,mouseon:near,mouseoff:near,mouseget:near
extrn    citachod:byte,citacexp:byte,testkey:near,mousepoz:word
extrn    edikey:word,inpkeyf:near,tabhlfnd:word,modihlp:near
extrn    kurzout:near,flagsc:byte,getdispl:near,getakt:near,highcase:near
extrn    flagsc2:byte,flushkey:near,parint2:byte,ukazkey:dword

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
         call      testakth                 ; je n†povàda aktivn° ?
         jc        select01                 ; n†povàda nen° aktivn°
         push      si
         lea       si,[helped]              ; text n†povàdy
         call      outthlp                  ; zobrazen° textu n†povàdy
         pop       si
select01:
         call      testsel                  ; test bufferu zad†n°
                                          ;* BH=max.®°©ka ©et., BL=poáet poloëek
         call      setwsel                  ; nastaven° parametrñ okna voleb
         call      selwin                   ; vykreslen° okna pro volby
select0: lea       bp,[sellin]              ; adresa definián° tabulky
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
select1: call      inpkeys                  ; vstup prvn°ho znaku
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
select2: call      inpkeys                  ; vstup znaku
select21:or        ah,ah                    ; je znak s ALT ?
         jz        select22                 ; je znak s ALT
         cmp       ax,0300h                 ; je CTRL-@ ?
         je        select22                 ; je CTRL-@
         cmp       al,32                    ; je ASCII k¢d ?
         jae       select22                 ; je znak ASCII

         push      bx
         lea       bx,[skoksel]             ; tabulka skokñ do funkc°
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
         lea       di,ds:[tabsel]
         mov       cx,10                    ; poáet znakñ v tabulce
         mov       al,ah
         repnz     scasb                    ; nalezen° k¢du v tabulce
         pop       di
         pop       cx
         je        select0                  ; bude prvn° znak
         jmp       select2



public   inpkeys
inpkeys:                                  ;* vstup kl†vesy

         push      si
         push      bx
inpkeys0:call      mouseget                 ; vstup z my®i
         jz        inpkeys4                 ; nen° tlaá°tko
                                          ;* test kl†vesy ESC
         mov       ax,011bh                 ; ESC
         cmp       bl,11                    ; uvolnàn° pravÇho tlaá°tka ?
         je        inpkeys6                 ; je ESC
                                          ;* kontrola hranic
         mov       al,dl
         cmp       al,byte ptr cs:[mousepoz]
         ja        inpkeys4                 ; kurzor p©°li® vlevo
         add       al,cl
         cmp       al,byte ptr cs:[mousepoz]
         jbe       inpkeys4                 ; kurzoru p©°li® vpravo
         mov       al,dh
         add       al,ch
         cmp       al,byte ptr cs:[mousepoz+1]
         jbe       inpkeys4                 ; kurzor p©°li® dole
         mov       al,byte ptr cs:[mousepoz+1]
         sub       al,dh                    ; relativn° ©†dek
         jb        inpkeys4                 ; kurzor p©°li® naho©e
                                          ;* funkce ENTER
         cmp       bl,10                    ; uvolnàn° levÇho tlaá°tka ?
         jne       inpkeys3                 ; nen° funkce ENTER
         mov       ax,1c0dh                 ; ENTER
         jmp       short inpkeys6
inpkeys3:                                 ;* vòpoáet á°sla poloëky
         sub       al,2                     ; horn° okraj
         jnc       inpkeys1                 ; nen° v horn°m okraji
         xor       al,al
inpkeys1:cbw                                ; offset ©†dku
         add       ax,cs:[firstsel]         ; poëadovan† poloëka
                                          ;* test dosaëen° poloëky
         cmp       ax,cs:[kurzsel]          ; je jië poloëky dosaëeno ?
         je        inpkeys4                 ; poloëky je jië dosaëeno
         mov       ax,4800h                 ; kurzor nahoru
         jb        inpkeys6                 ; je posun nahoru
         mov       ax,5000h                 ; kurzor dolñ
         jmp       short inpkeys6           ; posun dolñ

;inpkeys4:call      testkey
;         jz        inpkeys0                 ; nen° kl†vesa
;         call      inpkey                   ; vstup kl†vesy
;inpkeys6:pop       bx
;         pop       si
;         ret

inpkeys4:cmp       word ptr cs:[edikey],0   ; je nàjakò znak v bufferu ?
         jne       inpkeys5                 ; v bufferu je nàjakò znak
         call      testkey                  ; je p©ipraven znak ?
         jz        inpkeys0                 ; áek†n° na p©°chod znaku
inpkeys5:lea       si,[tabhlfnd]
         call      inpkeyf                  ; vstup znaku s vyprazd§ov†n°m
inpkeys6:pop       bx
         pop       si
         ret


                                          ;* tabulka kl†ves - bude prvn° znak
tabsel   db        48h,8dh,50h,91h,77h,75h,49h,84h,51h,76h

select3:                                  ;* je ukonáen° ENTER

         push      ax

         push      di
         push      si
                                          ;* oznaáen° konce textu
         lea       si,[selbuf]              ; buffer s textem
         push      ax
         mov       ax,ds:[numselb]          ; poáet znakñ v bufferu
         push      si
         add       si,ax                    ; konec bufferu
         mov       byte ptr ds:[si],0       ; konec bufferu
         pop       si
         pop       ax

         call      rozbor                   ; proveden° rozboru zad†n°
         jnc       edits2a                  ; rozbor OK
;
;         mov       ax,di                    ; adresa chyby
;         sub       ax,si                    ; offset zaá†tku chyby
;         mov       ds:[ukazsel],ax          ; offset zaá†tku textu
;         mov       word ptr ds:[topsel],0   ; zaá†tek textu
;         mov       ah,cl
;         shr       ah,1
;         sub       al,ah
;         add       al,5                     ; p©edpokl†danò zaá†tek textu
;         push      cx
;         push      di
;edits2e: inc       al                       ; zvò®en° zaá†tku
;         cmp       byte ptr ds:[di],20h     ; je konec ?
;         jbe       edits2f                  ; je konec textu
;         dec
;         loop      edits2e                  ; dal®° test
;edits2f: pop       di
;         pop       cx
;         or        al,al                    ; p©edpokl†danò zaá†tek
;         js        edits2c                  ; je p©°li® na zaá†tku
;         mov       ds:[topsel],ax           ; novò zaá†tek textu
;edits2c: call      obredit0                 ; zobrazen° ©†dku s chybou
;         call      kurzedsel                ; zobrazen° kurzoru na ©†dku
;edits2d: mov       ah,1
;         int       16h
;         jz        edits2d                  ; áek†n° na stisk kl†vesy
;         call      obredit                  ; novÇ zobrazen° ©†dku
;         pop       si
;         pop       di
;         pop       ax
edits2a: pop       si
         pop       di
         pop       ax
         call      storesel                 ; uloëen° poloëky do bufferu
         jmp       short select4

select5:                                  ;* uloëen° textu do bufferu CTRL-ENTER
         push      bx
         mov       bx,ds:[numselb]          ; poáet znakñ v bufferu
         mov       si,offset selbuf         ; buffer s textem
         mov       byte ptr ds:[si+bx],0    ; oznaáen° konce textu
         pop       bx
         mov       word ptr cs:[ukazkey],si
         mov       word ptr cs:[ukazkey+2],ds

;         lea       si,[selbuf]              ; buffer s textem
;         push      bp
;         push      ax
;         push      cx
;         push      si
;         call      getakt                   ; poskytnut° aktivn°ho okna
;         mov       cx,ds:[numselb]          ; poáet znakñ v bufferu
;         jcxz      edits2d
;edits2c: lodsb
;         xor       ah,ah
;         call      usesedit                 ; uloëen° znaku
;         loop      edits2c
;edits2d: mov       al," "
;         xor       ah,ah
;         call      usesedit                 ; ukonáovac° mezera
;         pop       si
;         pop       cx
;         pop       ax
;         pop       bp
                                          ;* ukonáen° ESC
select4: add       sp,6                     ; zru®en° n†vratovÇ adresy
         push      si
;         call      outhelp                  ; zobrazen° z†kladn° n†povàdy
;         call      obrcomm                  ; zobrazen° povelovÇho ©†dku
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
         db        00h+4                    ; testuje se AL
         db        0dh                      ; ukonáen° editace ENTER
         dw        select3
         db        0ah                      ; p©eru®en° editace CTRL-ENTER
         dw        select5
         db        1bh                      ; p©eru®en° editace ESC
         dw        select4
         db        0fh                      ; zap/vyp okna ^O
         dw        selectoff
         db        0

; -----------------------------------------------------------------------------
public   selectoff

selectoff:                                ;* vypnut°/zapnut° okna
         push      dx
         xor       al,al
         mov       dx,25*256
         call      outch1                   ; vypnut° kurzoru
         pop       dx
         call      windret                  ; n†vrat zobrazen° oken
         call      inpkey
         mov       di,ds:[adrnadp]          ; adresa nadpisu
         call      selwin                   ; vykreslen° okna pro volby
         push      ds:[numselb]
         push      ds:[ukazsel]
         push      ds:[topsel]
         push      ds:[firstsel]
         push      ds:[kurzsel]
         push      word ptr ds:[pocpozsl]
         push      si
         push      di
         push      cx
         lea       si,[selbuf]              ; editovanò text
         lea       di,[selbufz]
         mov       cx,129
         rep       movsb                    ; £schova textu
         pop       cx
         pop       di
         pop       si
         call      selall                   ; zobrazen° v®ech poloëek
         push      si
         push      di
         push      cx
         lea       di,[selbuf]              ; editovanò text
         lea       si,[selbufz]
         mov       cx,129
         rep       movsb                    ; £schova textu
         pop       cx
         pop       di
         pop       si
         pop       word ptr ds:[pocpozsl]
         pop       ds:[kurzsel]
         pop       ds:[firstsel]
         pop       ds:[topsel]
         pop       ds:[ukazsel]
         pop       ds:[numselb]
         mov       ah,ds:[col3]             ; barva poloëky s kurzorem
         mov       ds:[atribsel],ah         ; barva pro zobrazen° poloëky
         call      obrlin                   ; zobrazen° ©†dku
         call      kurzlin                  ; nastaven° kurzoru pro select
         ret

; -----------------------------------------------------------------------------
public   editsel

editsel:                                  ;* obsluha editace ©†dku
                                            ; VùSTUP: ;CY=kl†vesa nebyla obslouë.
                                            ;         ZN=byla zmàna okna

         push      ax                       ; £schova k¢du kl†vesy
         push      word ptr ds:[kurzsel]    ; £schova pozice kurzoru
         push      word ptr ds:[firstsel]   ; £schova prvn° poloëky
         call      edilin                   ; obsluha editace ©†dku
;         xor       ax,ax                    ; p©°znak ZY=nebyla zmàna okna
         pop       ax                       ; n†vrat prvn° poloëky
;         jc        editsel1                 ; kl†vesa nebyla obslouëena
         cmp       ax,ds:[firstsel]         ; byla zmànàna prvn° poloëka ?
;         clc
editsel1:pop       ax                       ; n†vrat pozice kurzoru
         jne       editsel2                 ; byla zmàna prvn° poloëky
;         jb        editsel3                 ; kl†vesa nebyla obslouëena
         cmp       ax,ds:[kurzsel]          ; byla zmànàna pozice kurzoru ?
;         clc
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
         add       di,2
         cmp       byte ptr ds:[si],0       ; konec bufferu ?
         je        stores2                  ; v bufferu nen° ë†dn† poloëka
         dec       di
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
         lea       si,[selbuf]              ; buffer s ukl†danòm textem
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
         lea       di,[selbuf]              ; buffer pro editaci
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
         call      stinw                    ; zobrazen° st°nu okna
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   podklad

podklad:                                  ;* vykreslen° podkladu pod oknem
                                            ; VSTUP: DL=poá†tek okna
                                            ;        DH=©†dek okna
                                            ;        CL=®°©ka okna
                                            ;        CH=vò®ka okna

                                          ;* zde se provede exploze okna
         push      bx
         mov       bl,2                     ; á°taá f†z° exploze
         mov       byte ptr cs:[citacexp],255 ; á°taá f†z° exploze
podklad1:mov       bh,cs:[citacexp]
         push      bx
         push      cx
         push      dx
         shr       cl,1                     ; ®°©ka okna / 2
         shr       ch,1                     ; vò®ka okna / 2
         add       dx,cx                    ; pozice na prost©edek
         dec       dl
         dec       dh
podklad3:shr       cl,1                     ; ®°©ka okna / 4
         shr       ch,1                     ; vò®ka okna / 4
         dec       bl
         jnz       podklad3
         sub       dx,cx
         shl       cx,1
         add       cx,101h
         call      podklad2
         pop       dx
         pop       cx
         pop       bx
podklad4:cmp       bh,cs:[citacexp]
         je        podklad4                 ; áek†n° na impuls hodin
         dec       bl
         jnz       podklad1                 ; dal®° f†ze

         pop       bx

podklad2:                                 ;* zobrazen° jednoho podkladu
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

         call      mouseoff                 ; vypnut° my®i
         mov       ax,600h                  ; funkce vymaz†n° okna
         mov       bh,ds:[color]            ; barva pro podklad okna
         xchg      cx,dx                    ; CX <- pozice levÇho horn°ho rohu
         add       dl,cl                    ; koncov† pozice + 1
         dec       dl                       ; koncov† pozice
         add       dh,ch                    ; koncovò ©†dek + 1
         dec       dh                       ; koncovò ©†dek
         int       10h                      ; vymaz†n° okna
         call      mouseon                  ; zapnut° my®i

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
         call      mouseoff                 ; vypnut° my®i
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
         call      mouseon                  ; zapnut° my®i
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
         call      mouseoff                 ; vypnut° my®i
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

         call      mouseon                  ; zapnut° my®i
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
         call      mouseoff                 ; vypnut° my®i

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
         call      mouseon                  ; zapnut° my®i
         pop       si
         pop       dx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   stinw

stinw:                                    ;* zobrazen° st°nu pod oknem
                                            ; VSTUP: DL=poá†tek okna
                                            ;        DH=©†dek okna
                                            ;        CL=®°©ka okna
                                            ;        CH=vò®ka okna

         push      ax
         push      bx
         push      si
         call      mouseoff                 ; vypnut° my®i
                                          ;* nastaven° offsetu pro st°n
;         push      cx
;         push      dx
;         mov       ah,2ch                   ; funkce poskytnut° syst. áasu
;         int       21h                      ; poskytnut° systÇmovÇho áasu
;         mov       al,ch                    ; hodina
;         lea       si,[tabstin]             ; tabulka hodin pro st°n
;         mov       cx,6                     ; poáet hodnot v tabulce
;         mov       bl,3                     ; vòchoz° hodnota offsetu st°nu
;stinw1:  cmp       al,ds:[si]               ; je men®° neë £daj hodin ?
;         jb        stinw2                   ; nalezen áasovò interval
;         inc       si                       ; zvò®en° ukazatele v tabulce
;         dec       bl                       ; posun st°nu o znak vlevo
;         loop      stinw1                   ; test dal®°ho áasu
;stinw2:  pop       dx
;         pop       cx
         mov       bl,2
;         cmp       bl,-3                    ; je pozdà veáer ?
;         je        stinw5                   ; je noc
;         cmp       bl,3                     ; je brzo r†no ?
;         je        stinw5                   ; je noc
                                          ;* zobrazen° st°nu
         push      cx
         push      dx
         inc       dh                       ; zvò®en° ©†dku
stinw3:  call      obrstin                  ; zobrazen° st°nu na ©†dku
         inc       dh                       ; zvò®en° á°sla ©†dku
         dec       ch                       ; sn°ëen° á°taáe ©†dkñ
         jnz       stinw3                   ; zobrazen° dal®°ho ©†dku
         dec       dh                       ; n†vrat posledn°ho ©†dku
         add       dl,bl                    ; poá†tek st°nu
stinw4:  call      stin                     ; zobrazen° st°nu v posledn°m ©†dku
         loop      stinw4                   ; zobrazen° dal®°ho znaku v ©†dku
         pop       dx
         pop       cx

stinw5:  call      mouseon                  ; zapnut° my®i
         pop       si
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   obrstin

obrstin:                                  ;* vykreslen° st°nu na ©†dku
                                            ; VSTUP:DL=pozice zaá†tku okna
                                            ;       DH=©†dek pro zobrazen°
                                            ;       CL=®°©ka okna
                                            ;       BL=offset st°nu
         push      ax
         push      cx
         push      dx
         or        bl,bl                    ; je offset z†pornò ?
         js        obrst0                   ; offset je z†pornò
         add       dl,cl                    ; p©iáten° ®°©ky okna
obrst0:  mov       cl,bl                    ; offset st°nu
         or        bl,bl
         jns       obrst1                   ; je nez†pornò offset
         neg       cl                       ; absolutn° hodnota offsetu
         add       dl,bl                    ; p©iáten° offsetu st°nu
obrst1:  xor       ch,ch
         jcxz      obrst4
obrst3:  call      stin                     ; vykreslen° st°nu
         loop      obrst3                   ; dal®° st°n
obrst4:  pop       dx
         pop       cx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   stin

stin:                                     ;* vykreslen° st°nu (1 znak)
                                            ; VSTUP:DL=pozice
                                            ;       DH=©†dek
                                            ; VùSTUP: DX=nov† pozice

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         mov       bh,ds:[aktpage]          ; aktivn° str†nka
         push      bx                       ; £schova str†nky
         mov       ah,2                     ; funkce nastaven° pozice kurzoru
         int       10h                      ; nastaven° pozice kurzoru
         pop       bx                       ; str†nka
         mov       ah,8                     ; funkce áten° znaku
         int       10h                      ; poskytnut° znaku a atributu
;         mov       bl,ah
;         and       ah,7fh
;         mov       cl,4
;         shr       ah,cl
;         and       bl,0fh
;         cmp       ah,bl
         mov       ah,7
;         jna       stin1
;         mov       ah,70h
stin1:   pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         push      word ptr ds:[color]      ; £schova atributu barev
         mov       ds:[color],ah            ; barva b°lÇ p°smo na áernÇm pozad°
         call      outch10                  ; vòstup znaku s novòm atributem
         pop       word ptr ds:[color]      ; navr†cen° pñvodn° barvy
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
setwsl04:cmp       cl,66                    ; je dÇlka ©etàzce vàt®° neë 66 ?
         jna       setwsl11                 ; ®°©ka nen° vàt®° neë 66
         mov       cl,66                    ; omezen° na ®°©ku 66
setwsl11:cmp       cl,12                    ; minim†ln° ®°©ka poloëky
         jnb       setwsl12                 ; nen° men®° neë 12
         mov       cl,12                    ; omezen° na 12
setwsl12:mov       ds:[delkasel],cl         ; nastaven° ®°©ky textu pro editaci
         add       cl,10                    ; p©iáten° okrajñ
                                          ;* nastaven° vò®ky okna
         push      dx
         call      getdispl
         sub       dh,6                     ; max. poáet poloëek
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
;         call      asksel                   ; poskytnut° poloëky
;         or        al,al                    ; je platnò ©etàzec ?
;
;
;
;askselx5:ret
;
;


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
         lea       di,[rozbset]             ; buffer rozboru
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
         and       byte ptr ds:[flagsc2],not 1 ; zru®en° p©°znaku zad†n° souboru
rozbor1:                                  ;* rozbor jednÇ poloëky zad†n°
         call      outspc                   ; vypu®tàn° poá†teán°ch mezer
         jz        rozbor9                  ; je konec textu
;         lodsb                              ; naáten° znaku
;                                          ;* test, zda jsou zad†ny atributy
;         cmp       al,"+"                   ; je nastaven° atributñ ?
;         mov       di,offset rozbats        ; nastaven° atributñ
;         je        rozbor2                  ; je nastaven° atributñ
;         cmp       al,"-"                   ; je nulov†n° atributñ
;         mov       di,offset rozbatr        ; nulov†n° atributñ
;         jne       rozbor3                  ; nen° nulov†n° atributñ
;rozbor2: call      rozboratr                ; rozbor atributñ
;         jc        rozbor8                  ; chyba zad†n° atributñ
;         jmp       short rozbor1            ; dal®° rozbor
;rozbor3: cmp       al,"/"                   ; jsou p©ep°naáe ?
;         jne       rozbor6                  ; nen° p©ep°naá
;         lodsb                              ; naáten° dal®°ho znaku
;         call      highcase0                ; p©evod na velkÇ p°smeno
;         cmp       al,"D"                   ; je nastaven° data ?
;         jne       rozbor4                  ; nen° nastaven° data
;         call      rozbordat                ; rozbor data
;         jc        rozbor8                  ; chyba zad†n° data
;         jmp       short rozbor1            ; dal®° rozbor
;rozbor4: cmp       al,"T"                   ; je nastaven° áasu ?
;         jne       rozbor5                  ; nen° nastaven° áasu
;         call      rozborcas                ; rozbor áasu
;         jc        rozbor8                  ; chyba zad†n° áasu
;         jmp       short rozbor1            ; dal®° rozbor
;rozbor5: cmp       al,"S"                   ; je nastaven° velikosti ?
;         jne       rozbor7                  ; nen° nastaven° velikosti - chyba
;         call      rozborvel                ; rozbor velikosti
;         jc        rozbor8                  ; chyba zad†n° velikosti
;         jmp       short rozbor1            ; dal®° rozbor
;rozbor6: dec       si                       ; n†vrat prvn°ho znaku
         test      byte ptr ds:[flagsc2],1  ; byl soubor jië zad†n ?
         jnz       rozbor8                  ; soubor byl jië zad†n
         call      rozbornam                ; rozbor jmÇna souboru
         jc        rozbor8                  ; chyba zad†n°
         or        byte ptr ds:[flagsc2],1  ; nastaven° p©°znaku zad†n° souboru
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
;public   rozboratr
;
;rozboratr:                                ;* rozbor atributñ zad†n°
;
;         push      di
;         push      si
;         call      rozbatr0                 ; rozbor prvn°ho atributu
;         jnc       rozbatr2                 ; nen° chyba rozboru
;rozbatr1:stc                              ;* chyba rozboru
;         pop       si                       ; n†vrat zaá†tku textu
;         pop       di
;         ret
;rozbatr2:call      rozbatr0                 ; rozbor dal®°ho atributu
;         jnc       rozbatr2                 ; dal®° atribut
;         dec       si                       ; n†vrat posledn°ho znaku
;         mov       al,ds:[rozbats]          ; atributy pro nastaven°
;         and       al,ds:[rozbatr]          ; atributy pro nulov†n°
;         jnz       rozbatr1                 ; p©ekròvaj° se - chyba
;         clc                                ; p©°znak spr†vnÇho rozboru
;         pop       di                       ; zru®en° adresy zaá†tku textu
;         pop       di
;         ret
;
;public   rozbatr0
;
;rozbatr0:                                 ;* rozbor jednoho znaku atributu
;
;         lodsb                              ; naáten° dal®°ho znaku
;         call      highcase0                ; p©evod na velkÇ p°smeno
;         cmp       al,"A"                   ; je atribut "Archivn°" ?
;         jne       rozbatr6                 ; nen° atribut "Archivn°"
;         or        byte ptr ds:[di],20h     ; nastaven° archivn°ho atributu
;         ret
;rozbatr6:cmp       al,"S"                   ; je atribut "SystÇmovò" ?
;         jne       rozbatr7                 ; nen° atribut "SystÇmovò"
;         or        byte ptr ds:[di],4       ; nastaven° systÇmovÇho atributu
;         ret
;rozbatr7:cmp       al,"H"                   ; je atribut "Hidden" ?
;         jne       rozbatr8                 ; nen° atribut "Hidden"
;         or        byte ptr ds:[di],2       ; nastaven° atributu "Hidden"
;         ret
;rozbatr8:cmp       al,"R"                   ; je atribut "R/O" ?
;         stc
;         jne       rozbatr9                 ; nen° atribut "R/O"
;         or        byte ptr ds:[di],1       ; nastaven° atributu R/O
;rozbatr9:ret
;
;; -----------------------------------------------------------------------------
;public   rozborcas
;
;rozborcas:                                ;* rozbor áasu souboru
;
;                                          ;* kontrola, zda je jië áas zad†n
;         push      di
;         mov       di,offset rozbcas        ; zaá†tek pro uloëen° rozboru
;         push      di
;         push      cx
;         mov       al,"?"                   ; porovn†vanò znak
;         mov       cx,6                     ; poáet kontrolovanòch znakñ
;         repe      scasb                    ; kontrola, zda je jië áas
;         pop       cx
;         pop       di
;         je        rozbcas1                 ; áas nen° zad†n - OK
;         sub       si,2                     ; zaá†tek textu "/T"
;         pop       di
;         stc                                ; p©°znak chyby
;         ret
;
;rozbcas1:push      si                       ; £schova zaá†tku textu
;rozbcas7:call      outspc                   ; nalezen° dal®°ho textu
;         jz        rozbcas3                 ; je konec textu
;         add       sp,2                     ; zru®en° ukazatele textu
;         push      si
;         cmp       byte ptr ds:[si],">"     ; je p©°znak "vàt®°" ?
;         jne       rozbcas5                 ; nen° p©°znak "vàt®°"
;         inc       si                       ; zvò®en° adresy textu
;         or        byte ptr ds:[rozbflg],20h; nastaven° bitu 5
;         jmp       short rozbcas7           ; rozbor dal®°ho znaku
;rozbcas5:cmp       byte ptr ds:[si],"<"     ; je p©°znak "men®°" ?
;         jne       rozbcas6                 ; nen° p©°znak "men®°"
;         inc       si                       ; zvò®en° adresy textu
;         or        byte ptr ds:[rozbflg],10h ; nastaven° bitu 4
;         jmp       short rozbcas7           ; rozbor dal®°ho znaku
;rozbcas6:cmp       byte ptr ds:[si],32      ; je oddàlovac° znak ?
;         jbe       rozbcas3                 ; konec zad†n°
;         call      rozbdat0                 ; rozbor hodiny
;         jnc       rozbcas2                 ; zad†n° OK
;rozbcas4:stc                                ; p©°znak chyby rozboru
;         pop       si                       ; n†vrat zaá†tku textu
;         pop       di
;         ret
;
;rozbcas2:cmp       al,32
;         jae       rozbcas4                 ; chyba zad†n° hodiny
;         add       di,2                     ; zvò®en° ukl†dac° adresy
;         cmp       byte ptr ds:[si],32      ; je oddàlovac° znak ?
;         jbe       rozbcas3                 ; konec zad†n°
;         call      rozbdat0                 ; rozbor minuty áasu
;         jc        rozbcas4
;         cmp       al,64
;         jae       rozbcas4                 ; chyba zad†n° minuty
;         add       di,2                     ; zvò®en° ukl†dac° adresy
;         cmp       byte ptr ds:[si],32      ; je oddàlovac° znak ?
;         jbe       rozbcas3                 ; konec zad†n°
;         call      rozbdat0                 ; rozbor sekundy áasu
;         jc        rozbcas4
;         cmp       al,64
;         jae       rozbcas4                 ; chyba zad†n° minuty
;         mov       al,ds:[di+1]             ; nië®° ©†d sekund
;         cmp       al,"?"
;         je        rozbcas3                 ; je n†hradn° znak "?"
;         and       byte ptr ds:[di+1],0feh  ; p©evod na sudou á°slici
;rozbcas3:clc                                ; p©°znak - rozbor OK
;         pop       di                       ; zru®en° zaá†tku textu
;         pop       di
;         ret
;
;
; -----------------------------------------------------------------------------
;public   rozbordat
;
;rozbordat:                                ;* rozbor data souboru
;
;                                          ;* kontrola, zda je jië áas zad†n
;         push      di
;         mov       di,offset rozbdat        ; zaá†tek pro uloëen° rozboru
;         push      di
;         push      cx
;         mov       al,"?"                   ; porovn†vanò znak
;         mov       cx,6                     ; poáet kontrolovanòch znakñ
;         repe      scasb                    ; kontrola, zda je jië datum
;         pop       cx
;         pop       di
;         je        rozbdat1                 ; datum nen° zad†n - OK
;         sub       si,2                     ; zaá†tek textu "/D"
;         pop       di
;         stc                                ; p©°znak chyby
;         ret
;
;rozbdat1:push      si                       ; £schova zaá†tku textu
;rozbdat2:                                 ;* rozbor data
;         add       di,4                     ; den data
;         call      outspc                   ; nalezen° zaá†tku textu
;         jz        rozbdat5                 ; je konec textu
;         add       sp,2                     ; zru®en° ukazatele textu
;         push      si                       ; novò ukazatel textu
;         cmp       byte ptr ds:[si],">"     ; je p©°znak "vàt®°" ?
;         jne       rozbdat6                 ; nen° p©°znak "vàt®°"
;         inc       si                       ; zvò®en° adresy textu
;         or        byte ptr ds:[rozbflg],8  ; nastaven° bitu 3
;         jmp       short rozbdat2           ; rozbor dal®°ho znaku
;rozbdat6:cmp       byte ptr ds:[si],"<"     ; je p©°znak "men®°" ?
;         jne       rozbdat7                 ; nen° p©°znak "men®°"
;         inc       si                       ; zvò®en° adresy textu
;         or        byte ptr ds:[rozbflg],4  ; nastaven° bitu 2
;         jmp       short rozbdat2           ; rozbor dal®°ho znaku
;rozbdat7:cmp       byte ptr ds:[si],32      ; je oddàlovac° znak ?
;         jbe       rozbdat5                 ; konec zad†n°
;         call      rozbdat0                 ; rozbor dne data
;         jnc       rozbdat3                 ; zad†n° OK
;rozbdat4:stc                                ; p©°znak chyby rozboru
;         pop       si                       ; n†vrat zaá†tku textu
;         pop       di
;         ret
;rozbdat3:
;         cmp       al,32                    ; kontrola maxim†ln°ho dne
;         jae       rozbdat4                 ; chyba zad†n°
;         sub       di,2                     ; zvò®en° ukl†dac° adresy
;         cmp       byte ptr ds:[si],32      ; je oddàlovac° znak ?
;         jbe       rozbdat5                 ; konec zad†n°
;         call      rozbdat0                 ; rozbor màs°ce data
;         jc        rozbdat4
;         cmp       al,16                    ; maxim†ln° màs°c
;         jae       rozbdat4                 ; chyba zad†n° màs°ce
;         sub       di,2                     ; zvò®en° ukl†dac° adresy
;         cmp       byte ptr ds:[si],32      ; je oddàlovac° znak ?
;         jbe       rozbdat5                 ; konec zad†n°
;         call      rozbdat0                 ; rozbor roku data
;         jc        rozbdat4
;rozbdat5:clc                                ; p©°znak - rozbor OK
;         pop       di                       ; zru®en° zaá†tku textu
;         pop       di
;         ret
;
;public   rozbdat0
;
;rozbdat0:                                 ;* rozbor 2 á°slic zad†n°
;                                            ; VùSTUP: AL=á°slo
;                                            ;         CY=chyba syntaxe
;                                            ;         ZY=je oddàlovac° znak
;
;
;         push      bx
;         xor       bl,bl                    ; st©adaá á°sla
;         call      rozb1cis                 ; naáten° 1 á°slice
;         jc        rozbdat8                 ; chyba zad†n°
;         mov       word ptr ds:[di],"00"    ; vynulov†n° bufferu
;         je        rozbdat8                 ; je oddàlovac° znak
;         mov       ds:[di+1],al             ; uloëen° nië®° á°slice
;         call      rozb1cis                 ; naáten° dal®° á°slice
;         jbe       rozbdat8                 ; chyba nebo konec á°sla
;         mov       al,ds:[di+1]             ; p©ede®l† á°slice
;         mov       ds:[di],al               ; p©enos do vy®®°ho ©†du
;         call      rozb1cis                 ; test, zda n†sleduje dal®° á°slice
;         je        rozbdat8                 ; je konec textu - OK
;         cmc                                ; zmàna p©°znaku á°sla
;rozbdat8:mov       al,bl                    ; naátenÇ á°slo
;         pop       bx
;         ret
;
;public   rozb1cis
;
;rozb1cis:                                 ;* naáten° 1 á°slice (nebo ? .)
;                                            ; VùSTUP: CY=nen° platnò znak
;                                            ;         ZY=je oddàlovac° znak
;
;         xor       ah,ah
;         mov       al,ds:[si]
;         cmp       al," "                   ; je mezera nebo nië®° á°slice ?
;         ja        rozb1cs0                 ; je konec textu
;         cmp       al,al                    ; nastaven° p©°znaku ZY
;         ret
;rozb1cs0:lodsb                              ; naáten° 1 znaku
;         cmp       al,"?"                   ; n†hradn° znak ?
;         je        rozb1cs4                 ; je n†hradn° znak
;         cmp       al,"."                   ; je konec ?
;         je        rozb1cs3                 ; platnò znak
;         cmp       al,","
;         je        rozb1cs3                 ; platnò znak
;         cmp       al,":"
;         je        rozb1cs3                 ; platnò znak
;         mov       ah,al
;         sub       ah,"0"                   ; je znak men®° neë "0" ?
;         jb        rozb1cs1                 ; nen° platn† á°slice
;         cmp       al,"9"                   ; je znak vàt®° neë "9" ?
;         jbe       rozb1cs4                 ; je platn† á°slice
;rozb1cs1:dec       si                       ; n†vrat ukazatele textu
;         stc                                ; chyba á°slice
;         ret
;rozb1cs4:mov       bh,bl
;         add       bl,bl                    ; á°slo * 2
;         add       bl,bl                    ; á°slo * 4
;         add       bl,bh                    ; á°slo * 5
;         add       bl,bl                    ; á°slo * 10
;         add       bl,ah
;rozb1cs2:or        al,al                    ; p©°znak - platn† á°slice
;rozb1cs3:ret
;
;
;; -----------------------------------------------------------------------------
;public   rozborvel
;
;rozborvel:                                ;* rozbor velikosti souboru
;
;                                          ;* kontrola, zda je jië vel. zad†na
;         push      di
;         mov       di,offset rozbvel        ; zaá†tek pro uloëen° rozboru
;         mov       ax,ds:[di]               ; nië®° slovo velikosti
;         or        ax,ds:[di+2]             ; vy®®° slovo velikosti
;         je        rozbvel1                 ; datum nen° zad†n - OK
;         sub       si,2                     ; zaá†tek textu "/S"
;         pop       di
;         stc                                ; p©°znak chyby
;         ret
;
;rozbvel1:push      si
;rozbvel2:call      outspc                   ; vypu®tàn° mezer
;         je        rozbvel5                 ; konec textu
;         add       sp,2
;         push      si
;         cmp       byte ptr ds:[si],">"     ; je p©°znak "vàt®°" ?
;         jne       rozbvel6                 ; nen° p©°znak "vàt®°"
;         inc       si                       ; zvò®en° adresy textu
;         or        byte ptr ds:[rozbflg],80h; nastaven° bitu 7
;         jmp       short rozbvel2           ; rozbor dal®°ho znaku
;rozbvel6:cmp       byte ptr ds:[si],"<"     ; je p©°znak "men®°" ?
;         jne       rozbvel7                 ; nen° p©°znak "men®°"
;         inc       si                       ; zvò®en° adresy textu
;         or        byte ptr ds:[rozbflg],40h; nastaven° bitu 6
;         jmp       short rozbvel2           ; rozbor dal®°ho znaku
;rozbvel7:call      rozbcisvel               ; rozbor 1 á°slice
;         jz        rozbvel5                 ; konec textu
;         jnc       rozbvel7                 ; zad†n° OK
;         pop       si                       ; n†vrat zaá†tku textu
;         pop       di
;         ret
;
;rozbvel5:pop       di                       ; zru®en° zaá†tku textu
;         pop       di
;         ret
;
;public   rozbcisvel
;
;rozbcisvel:                               ;* naáten° á°slice pro velikost
;                                            ; VùSTUP: CY=nen° platnò znak
;                                            ;         ZY=je konec textu
;rcisvel0:mov       al,ds:[si]
;         cmp       al," "                   ; je jië konec textu ?
;         ja        rcisvel1                 ; je platnò znak ASCII
;         cmp       al,al                    ; nastaven° p©°znaku ZY
;         ret
;rcisvel1:call      rozb1cis                 ; naáten° 1 á°slice
;         jc        rcisvel6                 ; chyba znaku
;         je        rcisvel0                 ; ignorov†n° oddàlovac°ch znakñ
;         sub       al,"0"                   ; p©evod na á°slice na á°slo
;         jc        rcisvel6                 ; neplatnò znak
;         cmp       al,10
;         jae       rcisvel5                 ; neplatnò znak
;
;         mov       cx,ds:[di]               ; nië®° slovo á°sla
;         mov       bx,ds:[di+2]             ; vy®®° slovo á°sla
;         add       cx,cx
;         adc       bx,bx                    ; á°slo * 2
;         jc        rcisvel6                 ; p©eteáen°
;         add       cx,cx
;         adc       bx,bx                    ; á°slo * 4
;         jc        rcisvel6                 ; p©eteáen°
;         add       cx,ds:[di]
;         adc       bx,ds:[di+2]             ; á°slo * 5
;         jc        rcisvel6                 ; p©eteáen°
;         add       cx,cx
;         adc       bx,bx                    ; á°slo * 10
;         jc        rcisvel6                 ; p©eteáen°
;         xor       ah,ah
;         add       ax,cx                    ; p©iáten° naátenÇho á°sla
;         adc       bx,0                     ; p©enos do vy®®°ho slova
;         mov       ds:[di],ax               ; uloëen° nië®°ho slova
;         mov       ds:[di+2],bx             ; uloëen° vy®®°ho slova á°sla
;         or        di,di                    ; zru®en° p©°znaku ZF
;         ret                                ; CY=p©eteáen°
;
;rcisvel4:dec       si                       ; n†vrat znaku
;rcisvel5:stc                                ; p©°znak chyby
;rcisvel6:ret
;
; -----------------------------------------------------------------------------
public   rozborcis
rozborcis:                                ;* rozbor á°sla
                                            ; VSTUP: DS:SI=adresa textu
                                            ; VùSTUP: DX:AX=á°slo
         push      bx
         push      cx
         xor       bx,bx                    ; nië®° slovo á°sla
         xor       dx,dx                    ; vy®®° slovo á°sla
         call      outspc                   ; vypu®tàn° mezer
         cmp       byte ptr ds:[si],'$'     ; je zad†n° HEX ?
         je        rozbcis3                 ; je zad†n° HEX

rozbcis2:mov       al,ds:[si]               ; znak k rozboru
         cmp       al,"0"                   ; je platnò znak ?
         jb        rozbcis5                 ; nen° platnò znak
         cmp       al,"9"
         ja        rozbcis5                 ; nen° platnò znak
         mov       cx,dx                    ; vy®®° slovo
         mov       ax,bx                    ; nië®° slovo
         add       bx,bx
         adc       dx,dx                    ; *2
         add       bx,bx
         adc       dx,dx                    ; *4
         add       bx,ax
         adc       dx,cx                    ; *5
         add       bx,bx
         adc       dx,dx                    ; *10
         xor       ax,ax
         lodsb
         sub       al,"0"
         add       bx,ax                    ; p©iáten° á°slice
         adc       dx,0                     ; p©enos
         jmp       short rozbcis2           ; dal®° znak

rozbcis3:inc       si
rozbcis4:mov       al,ds:[si]               ; znak k rozboru
         cmp       al,"0"                   ; je platnò znak ?
         jb        rozbcis5                 ; nen° platnò znak
         cmp       al,"9"
         ja        rozbcis5                 ; nen° platnò znak
         add       bx,bx
         adc       dx,dx                    ; *2
         add       bx,bx
         adc       dx,dx                    ; *4
         add       bx,bx
         adc       dx,dx                    ; *8
         add       bx,bx
         adc       dx,dx                    ; *16
         xor       ax,ax
         lodsb
         sub       al,"0"
         add       bx,ax                    ; p©iáten° á°slice
         adc       dx,0                     ; p©enos
         jmp       short rozbcis4           ; dal®° znak

rozbcis5:mov       ax,bx                    ; nië®° slovo á°sla
         pop       cx
         pop       bx
         ret
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
         cmp       byte ptr ds:[si],"<"     ; je parametr "men®°" ?
         jne       rozbnam2                 ; nen° parametr "men®°"
         inc       si                       ; zvò®en° átec° adresy
         or        byte ptr ds:[rozbflg],1  ; nastaven° p©°znaku "men®°"
         jmp       short rozbnam0           ; dal®° rozbor
rozbnam2:
         cmp       byte ptr ds:[si],">"     ; je parametr "vàt®°" ?
         jne       rozborn                  ; nen° parametr "vàt®°"
         inc       si                       ; zvò®en° átec° adresy
         or        byte ptr ds:[rozbflg],2  ; nastaven° p©°znaku "vàt®°"
         jmp       short rozbnam0           ; dal®° rozbor


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
         call      highcase0                ; p©evod na velkÇ p°smeno
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
         call      highcase0                ; p©evod na velkÇ p°smeno
         mov       ah,":"                   ; oznaáen° disku
         cmp       ds:[si],ah               ; je zad†n° disku ?
         je        rozbpth2                 ; je zad†n disk
;         push      si
;         push      bp
;         call      getakt
;         mov       si,ds:[bp+adrpathl-tabl]
;         mov       al,ds:[si]               ; aktivn° disk
;         pop       bp
;         pop       si
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
         call      highcase0                ; p©evod na velkÇ p°smeno
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

public   volbyh

volbyh:                                   ;* volby v horizont†ln°m smàru
                                            ; VSTUP: ES:DI=nadpis
                                            ;        DS:SI=seznam poloëek
                                            ;        AL=p©edvolen† poloëka
                                            ; VùSTUP: AL=á°slo poloëky
                                            ;         CY=p©eru®en° <ESC>
                                            ;         DS:SI=adresa poloëky

         push      bx
         push      cx
         push      dx
         push      di
                                          ;* zobrazen° z†kladn°ho okna
         push      ax                       ; £schova p©edvolby
         mov       bl,2                     ; minim†ln° mezera mezi poloëkami
         call      delvol                   ; dÇlka seznamu poloëek -> BH
                                          ;* vòpoáet poátu ©†dkñ
         push      di                       ; nadpis
         mov       bl,2                     ; poáet ©†dkñ (pouze nadpis)
volbyh1: cmp       byte ptr es:[di],31      ; je konec ©†dku ?
         jne       volbyh11                 ; nen° konec ©†dku
         inc       bl                       ; zvò®en° á°taáe ©†dkñ
volbyh11:inc       di                       ; zvò®en° ukazatele textu
         cmp       byte ptr es:[di-1],0     ; je konec textu ?
         jne       volbyh1                  ; dal®° znak
         pop       di

         call      setwsel                  ; nastaven° parametrñ okna
         mov       al,7                     ; barva pro okno volby
         call      outch1                   ; nastaven° barvy á°slo 7
         call      podklad                  ; vykreslen° podkladu okna
         call      wram1                    ; zobrazen° vnit©n°ho r†meáku
         call      wram2                    ; zobrazen° vnàj®°ho r†meáku
         call      wnadpis                  ; zobrazen° nadpisu okna
         call      stinw                    ; zobrazen° st°nu okna
         test      byte ptr cs:[parint2],80h ; je vyprazdneni klavesnice ?
         jz        volbyh13
         call      flushkey
volbyh13:and       byte ptr cs:[parint2],7fh
                                          ;* inicializace parametrñ poloëek
         add       dh,bl
         inc       dh                       ; poá†teán° ©†dek v oknà
         add       dl,5                     ; poá†teán° pozice v oknà
         xor       bl,bl                    ; nen° ë†dn† mezera
         call      delvol                   ; zkuteán† dÇlka ©etàzcñ
         sub       cl,10                    ; efektivn° ®°©ka ©†dku
         sub       cl,bh                    ; zbytek okrajñ
         call      testvol                  ; test parametrñ poloëek
         mov       bh,bl                    ; £schova poátu poloëek
         inc       bl                       ; poáet poloëek + 1
         mov       al,cl                    ; zbytek okrajñ
         xor       ah,ah
         div       bl                       ; ®°©ka oddàlovac° mezery
         shr       ah,1                     ; zbytek okrajñ / 2
         add       dl,ah                    ; vyst©edàn° textu poloëek
         mov       bl,al                    ; ®°©ka mezery
                                          ;* poá†teán° zobrazen° poloëek
         xor       cl,cl                    ; poá†teán° zobrazen† poloëka
         push      bx                       ; £schova poátu poloëek
volbyh2: call      voloff                   ; zobrazen° poloëky
         inc       cl                       ; zvò®en° ukazatele
         dec       bh                       ; sn°ëen° á°taáe poloëek
         jnz       volbyh2                  ; zobrazen° dal®° poloëky
         pop       bx
                                          ;* zobrazen° aktivn° poloëky
         pop       cx                       ; CL=p©edvolen† poloëka
volbyh3: call      volon                    ; zapnut° poloëky volby
volbyh4:

volbyh48:push      bx
         call      mouseget                 ; vstup my®i
         mov       al,bl
         pop       bx

         call      volbyhm                  ; obsluha voleb my®°
         jnc       volbyh4a                 ; byla obsluha

volbyh49:call      testkey
         jz        volbyh48                 ; áek†n° na tlaá°tko
         call      inpkey                   ; vstup znaku z kl†vesnice
volbyh4a:
         cmp       ax,180fh                 ; vypnut° okna ^O
         jne       volbyh41
                                            ; vypnut° okna ^O
         call      windret                  ; n†vrat zobrazen° oken

         call      inpkey                   ; áek†n° na stisk kl†vesy
         mov       al,cl                    ; pozice kurzoru
         pop       di
         pop       dx
         pop       cx
         pop       bx
         jmp       volbyh                   ; novÇ zobrazen° okna

volbyh41:
         cmp       ah,4bh                   ; kurzor vlevo ?
         je        volbyhl
         cmp       ah,73h
         je        volbyhl
         cmp       al,13h
         je        volbyhl
         cmp       ax,0f00h                 ; SHIFT-TAB
         jne       volbyh5

volbyhl:                                  ;* kurzor o poloëku vlevo
         call      voloff                   ; vypnut° kurzoru
         or        cl,cl
         jnz       volbyhl1
volbyhl2:mov       cl,bh                    ; posledn° poloëka + 1
volbyhl1:dec       cl                       ; sn°ëen° ukazatele poloëek
         jmp       short volbyh3            ; zpàtnÇ zapnut° kurzoru

volbyh5: cmp       ah,4dh                   ; kurzor vpravo ?
         je        volbyhr
         cmp       ah,74h
         je        volbyhr
         cmp       al,4
         je        volbyhr
         cmp       al,9
         jne       volbyh6

volbyhr:                                  ;* kurzor o poloëku vpravo
         call      voloff                   ; vypnut° kurzoru
         inc       cl                       ; zvò®en° ukazatele kurzoru
         cmp       cl,bh                    ; je jië dosaëeno posledn° poloëky ?
         jb        volbyhr1                 ; nen° je®tà posledn° poloëka
volbyhr2:xor       cl,cl                    ; nov† poloëka = 0
volbyhr1:jmp       short volbyh3            ; zpàtnÇ zapnut° kurzoru

volbyh6: cmp       ah,47h                   ; Home
         je        volbyhh
         cmp       ah,77h
         je        volbyhh
         cmp       ah,49h                   ; PageUp
         je        volbyhh
         cmp       ah,84h
         je        volbyhh
         cmp       al,12h
         jne       volbyh7

volbyhh: call      voloff                   ; vypnut° kurzoru
         jmp       short volbyhr2           ; prvn° poloëka

volbyh7: cmp       ah,4fh                   ; End
         je        volbyhe
         cmp       ah,75h
         je        volbyhe
         cmp       ah,51h                   ; PageDown
         je        volbyhe
         cmp       ah,76h
         je        volbyhe
         cmp       al,3
         jne       volbyh8

volbyhe: call      voloff                   ; vypnut° kurzoru
         jmp       short volbyhl2           ; posledn° poloëka


volbyh8:
         cmp       al,27                    ; je <Esc> ?
         stc                                ; p©°znak p©eru®en° operace
         je        volbyh9
         cmp       al,13                    ; je <Enter> ?
         je        volbyh9
                                          ;* test poá†teán°ho p°smene
         call      highcase                 ; p©evod na velkÇ p°smeno
         mov       ah,al                    ; £schova znaku
         push      cx
         mov       cl,bh                    ; poáet poloëek
         xor       ch,ch
         jcxz      volbyhc
volbyha: mov       al,cl
         push      si
         push      bx
         dec       al
         call      askvol
         lodsb
         pop       bx
         pop       si
         call      highcase
         cmp       al,ah
         je        volbyhb                  ; nalezena
         loop      volbyha
volbyhc: pop       cx
         jmp       volbyh4
                                          ;* nalezena kl†vesa
volbyhb: mov       al,cl
         pop       cx
         call      voloff                   ; vypnut° kurzoru
         mov       cl,al
         dec       cl
         call      volon                    ; zapnut° kurzoru
                                          ;* n†vrat z obsluhy
volbyh9: mov       al,cl                    ; á°slo vybranÇ poloëky
         pushf
         call      askvol                   ; nastaven° adresy poloëky
         popf
         pop       di
         pop       dx
         pop       cx
         pop       bx
         ret

; -----------------------------------------------------------------------------
public   volbyhm

volbyhm:                                  ;* obsluha voleb my®°
                                            ; VSTUP: DS:SI=adresa seznamu
                                            ;        BL=oddàlovac° mezera
                                            ;        CL=á°slo poloëky
                                            ;        DX=adresa zaá†tku zobrazen°
                                            ;        AL=vstup z tlaá°tek my®i
                                            ; VùSTUP: AX=k¢d kl†vesy

         push      bx
;         push      cx
         push      dx
         push      si
                                          ;* obsluha stisku tlaá°tek
         mov       bh,al                    ; volba tlaá°tek
         or        bh,bh                    ; je nàjakÇ tlaá°tko ?
         jz        volbyhm8                 ; nen° ë†dnÇ tlaá°tko
         mov       ax,011bh                 ; kl†vesa ESC
         cmp       bh,11                    ; je uvolnàn° pravÇho tlaá°tka ?
         je        volbyhm9                 ; uvolnàn° pravÇho tlaá°tka
         cmp       dh,byte ptr cs:[mousepoz+1] ; souhlas° ©†dek s kurzorem ?
         jne       volbyhm8                 ; ©†dek nesouhlas°
         push      dx
         push      bx
         mov       bh,bl
         shr       bh,1
         add       dl,bh                    ; poá†teán° levò okraj
         cmp       byte ptr cs:[mousepoz],dl; je p©ed levòm okrajem ?
         pop       bx
         pop       dx
         jb        volbyhm8                 ; pozice nesouhlas°
         mov       ax,1c0dh                 ; kl†vesa ENTER
         cmp       bh,10                    ; je uvolnàn° levÇho tlaá°tka ?
         je        volbyhm9                 ; je uvolnàn° levÇho tlaá°tka
                                          ;* nalezen° odpov°daj°c° poloëky
         push      dx
         push      si
         mov       bh,bl
         shr       bh,1
         add       dl,bh                    ; poá†teán° levò okraj
         xor       bh,bh                    ; ukazatel á°sla poloëky
;volbyhm2:cmp       byte ptr cs:[mousepoz],dl; je pod okrajem poloëky ?
;         jb        volbyhm5                 ; je pod levòm okrajem
volbyhm2:add       dl,bl                    ; p©iáten° mezery
;         inc       dl                       ; oddàlovac° mezera
         cmp       byte ptr ds:[si],0       ; je jië konec seznamu ?
         stc
         je        volbyhm5                 ; je konec - poloëka nenalezena
volbyhm3:lodsb                              ; naáten° dal®°ho znaku
         or        al,al                    ; je konec poloëky ?
         jz        volbyhm4
         inc       dl                       ; zvò®en° pozice na displeji
         jmp       short volbyhm3           ; dal®° znak
volbyhm4:
         cmp       byte ptr cs:[mousepoz],dl; je spr†vn† poloëka ?
         cmc
         ja        volbyhm5                 ; poloëka nalezena
         inc       bh                       ; zvò®en° ukazatele poloëek
         jmp       short volbyhm2           ; test dal®° poloëky
volbyhm5:                                 ;* poloëka nalezena nebo nenalezena
         pop       si
         pop       dx
         jc        volbyhm8                 ; poloëka nenalezena
         cmp       bh,cl
         je        volbyhm8
         call      voloff
         mov       cl,bh                    ; nov† poloëka
         call      volon
;         clc
;         jmp       short volbyhm9

volbyhm8:stc
volbyhm9:pop       si
         pop       dx
;         pop       cx
         pop       bx
         ret

; -----------------------------------------------------------------------------
public   volon,voloff

voloff:                                   ;* vypnut° zobrazen° kurzoru
         mov       ah,10
         jmp       short volon1

volon:                                    ;* zapnut° zobrazen° kurzoru
                                            ; VSTUP: DS:SI=adresa seznamu
                                            ;        BL=oddàlovac° mezera
                                            ;        CL=á°slo poloëky
                                            ;        DX=adresa zaá†tku zobrazen°
         mov       ah,14
volon1:  push      ax
         push      cx
         push      dx
         push      si
         call      mouseoff                 ; vypnut° my®i
         mov       al,cl                    ; á°slo poloëky
         call      adrvol                   ; nastaven° adresy poloëky
         mov       al,ah                    ; atribut kurzoru
         call      outch1
         xor       ch,ch
         mov       cl,bl
         shr       cl,1                     ; mezera / 2
         sub       dl,cl                    ; sn°ëen° pozice o mezeru
         mov       al," "
         call      outch                    ; poá†teán° okraj
         lodsb
         call      outch1                   ; zobrazen° prvn°ho znaku
         cmp       ah,10
         jne       volon2
         mov       al,7
         call      outch1
volon2:  cmp       ah,14
         jne       volon3
         mov       al,19
         call      outch1
volon3:  call      outtxt                   ; zobrazen° textu
         mov       al," "
         call      outch                    ; koncovò okraj
         call      kurzout                  ; vypnut° kurzoru
         call      mouseon                  ; zapnut° my®i
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   adrvol

adrvol:                                   ;* nastaven° adresy poloëky
                                            ; VSTUP: DS:SI=adresa seznamu
                                            ;        BL=oddàlovac° mezera
                                            ;        AL=á°slo poloëky
                                            ;        DX=adresa zaá†tku zobrazen°
                                            ; VùSTUP: DS:SI=adresa poloëky
                                            ;         DX=adresa na displeji

         push      ax
         push      bx
         push      cx
         xor       ch,ch
         mov       cl,al                    ; á°taá poloëek
         xor       al,al                    ; ukazatel poloëky
                                          ;* nejd©°ve se nastav° adresa displeje
         add       dl,bl                    ; poá†teán° levò okraj
         jcxz      adrvol3                  ; dosaëeno poloëky
adrvol1: push      si
         call      askvol                   ; poskytnut° parametrñ poloëky
         pop       si
         inc       al                       ; zvò®en° ukazatele poloëek
         add       dl,bh                    ; zvò®en° pozice na displeji
         add       dl,bl                    ; p©iáten° oddàlovac° mezery
         loop      adrvol1                  ; test dal®° poloëky
adrvol3: call      askvol                   ; poskytnut° adresy poloëky
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   delvol

delvol:                                   ;* seáten° dÇlek v®ech poloëek
                                            ; VSTUP: DS:SI=adresa seznamu
                                            ;        BL=oddàlovac° mezera
                                            ; VùSTUP: BH=celkov† dÇlka textu
         push      ax
         xor       al,al                    ; ukazatel poloëek
         mov       ah,bl                    ; poá†teán° mezera (st©adaá souátu)
delvol1: push      si                       ; ukazatel seznamu
         call      askvol                   ; poskytnut° parametrñ poloëky
         pop       si
         jc        delvol2                  ; konec seznamu
         inc       al                       ; zvò®en° ukazatele poloëek
         add       ah,bh                    ; p©iáten° dÇlky poloëky
         jc        delvol2                  ; p©eteáen°
         add       ah,bl                    ; p©iáten° oddàlovac° mezery
         jnc       delvol1                  ; dal®° poloëka
delvol2: mov       bh,ah                    ; souáet dÇlek
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   testvol

testvol:                                  ;* nalezen° poátu poloëek a max. dÇlky
                                            ; VSTUP: DS:SI=adresa seznamu
                                            ; VùSTUP: BH=max. dÇlka poloëky
                                            ;         BL=poáet poloëek
         push      ax
         push      dx
         xor       dh,dh                    ; max. dÇlka <- 0
         xor       bl,bl                    ; á°taá poloëek <- 0
testvl1: mov       al,bl                    ; poëadovanò ©etàzec
         push      si                       ; £schova adresy bufferu
         call      askvol                   ; test poloëky volby
         pop       si                       ; n†vrat adresy bufferu
         jc        testvl3                  ; byl to posledn° ©etàzec
         inc       bl                       ; zvò®en° á°taáe poloëek
         jz        testvl2                  ; p©eteáen° poátu ©etàzcñ
         cmp       bh,dh                    ; maxim†ln° dÇlka ©etàzcñ
         jb        testvl1                  ; nen° vàt®° dÇlka
         mov       dh,bh                    ; nov† maxim†ln° dÇlka
         jmp       short testvl1
testvl2: dec       bl                       ; BL <- 255 max. poáet ©etàzcñ
testvl3: mov       bh,dh                    ; nejvàt®° nalezen† poloëka
         pop       dx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   askvol

askvol:                                   ;* poskytnut° adresy poloëky
                                            ; VSTUP: DS:SI=adresa seznamu
                                            ;        AL=á°slo poloëky
                                            ; VùSTUP: DS:SI=adresa poloëky
                                            ;         CY=neplatnÇ á°slo poloëky
                                            ;         BH=dÇlka poloëky

         push      ax
         mov       ah,al                    ; á°taá poloëek
         xor       al,al                    ; hledanò bajt
                                          ;* nalezen° poloëky
askvol1: cmp       ds:[si],al               ; je konec seznamu ?
         stc                                ; p©°znak chyby
         je        askvol3                  ; konec seznamu
         or        ah,ah                    ; je jië nalezena poloëka ?
         jz        askvol3                  ; poloëka nalezena
askvol2:                                  ;* nalezen° zaá†tku dal®° poloëky
         lodsb                              ; naáten° dal®°ho znaku
         or        al,al                    ; je konec poloëky ?
         jne       askvol2                  ; test dal®°ho znaku
         dec       ah                       ; sn°ëen° á°taáe poloëek
         jmp       short askvol1            ; test dal®° poloëky
askvol3: pushf
         call      lensi                    ; zji®tàn° dÇlky poloëky DS:SI
         popf
         mov       bh,al                    ; dÇlka poloëky
         pop       ax
         ret







code     ends

         end

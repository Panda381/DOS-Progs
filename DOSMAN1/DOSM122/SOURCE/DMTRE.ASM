
; modul DOSMTRE.ASM - strom adres†©ñ

; *****************************************************************************
;
;                          Strom adres†©ñ
;
; *****************************************************************************

code     segment   public
         assume    cs:code,ds:code

extrn    topline:near,testakth:near,outch1:near,outch:near,windret:near
extrn    inpkeyf:near,kurzout:near,all:byte,nadadr:byte,aktdir:near
extrn    topseg:word,transtxt:near,outtxt:near,rootdir:byte
extrn    msgcek:near,topret:near,outbuf:byte,edikurz:word,editnum:word
extrn    skokax:near,ediradek:word,edidrad:byte,col1:byte,testshft:near
extrn    center:near,outhelp:near,readdir:near,storekall:near,adrradek:word
extrn    comptxt:near,loadpath:near,testbreak:near,hlptre:byte,outthlp:near
extrn    testaktw:near,soubtre:byte,config:byte,parbreak:word,lensi:near
extrn    tabhlpt:word,outakth:near,windretx:near,firstrad:word,conf2:byte
extrn    cmpdisk:near,getnakt:near,window:near,prevalt:near,numsrc:byte
extrn    bufsrc:byte,testalt:near,edikey:word,testkey:near,lowcase:near
extrn    modihlp:near,mouseget:near,mousemen:near,mousepoz:word
extrn    mouseon:near,mouseoff:near,setshft:near,resshft:near
extrn    rerdir:near,getdispcx:near,getendl:near,getdispl:near
extrn    getpocl:near,iniedis:near,deledis:near,aktedis:near
extrn    editmax:word,topseged:word,pozl:byte,pozr:byte,getakt:near
extrn    flags:byte,parint2:byte,citacexp:byte

public   strom

strom:                                    ;* stromov† struktura disku ALT-F10

         call      testaktw                 ; je okno zapnuto ?
         jnc       strom1                   ; okno je zapnuto
strom0:  ret
                                          ;* obsluha funkce se provede
strom1:  call      iniedis                  ; inicializace segmentu
         jc        strom0                   ; nen° voln† pamàü

         or        byte ptr ds:[parint2],1  ; p©°znak obsluhy stromu

         lea       si,[tabhlpt]             ; zobrazen° z†kladn° n†povàdy
         call      outakth                  ; zobrazen° aktivn° n†povàdy
                                          ;* poá†teán° zobrazen° okna
         xor       ax,ax
;         mov       ds:[editnum],ax          ; vynulov†n° obsahu pamàti
         mov       ds:[edikurz],ax          ; ukazatel kurzoru
         mov       ds:[firstrad],ax         ; prvn° zobrazenò ©†dek
         inc       al
         mov       ds:[edidrad],al          ; 1. ©†dek s kurzorem
         and       byte ptr ds:[config],not 8 ; zru®en° p©°znaku naáten° adres.
         mov       bh,80h                   ; p©°znak p©ekreslen° okna
         call      treeall                  ; zobrazen° celÇho okna
                                          ;* nastaven° vòchoz°ho adres†©e
         mov       si,ds:[bp+4]             ; cesta k adres†©i
         call      aktdir                   ; nastaven° aktivn°ho adres†©e
         call      testbreak                ; je p©eru®en° operace ?
         jc        strom4                   ; je p©eru®en° operace
         lea       si,[rootdir]             ; z†kladn° adres†©
         call      aktdir                   ; nastaven° z†kladn°ho adres†©e
         call      testbreak                ; je p©eru®en° operace ?
         jc        strom4                   ; je p©eru®en° operace
                                          ;* pokus o naáten° DOSMAN.TRE
         lea       dx,[soubtre]             ; soubor DOSMAN.TRE
         mov       ax,3d00h
         int       21h                      ; otev©en° souboru pro áten°
         jc        strom3                   ; soubor nenalezen
         mov       bx,ax                    ; identifik†tor souboru
         mov       ds,cs:[topseged]         ; segment
         xor       dx,dx                    ; ukl†dac° adresa
         mov       cx,cs:[editmax]          ; max. dÇlka dat
         mov       ah,3fh
         int       21h                      ; naáten° souboru
         jc        strom2                   ; chyba naáten° souboru
         mov       cs:[editnum],ax          ; dÇlka dat
strom2:  mov       ah,3eh
         int       21h                      ; uzav©en° souboru
         call      testbreak                ; je p©eru®en° operace ?
         jc        strom4                   ; je p©eru®en° operace
         push      cs
         pop       ds
strom3:
         call      tree                     ; ovl†d†n° stromovÇ struktury
         mov       byte ptr cs:[numsrc],0
strom4:  call      deledis                  ; zru®en° segmentu
         and       byte ptr ds:[parint2],not 1 ; zru®en° p©°znaku obsluhy stromu
         call      windretx                 ; n†vrat zobrazen° oken
strom5:  ret

; -----------------------------------------------------------------------------
public   stromxc
stromxc:                                  ;* z†màna pozic oken
         xor       byte ptr cs:[flags],1    ; zmàna aktivn°ho okna
         mov       al,cs:[pozr]             ; pozice pravÇho okna
         xchg      al,cs:[pozl]             ; z†màna s pozic° levÇho okna
         mov       cs:[pozr],al             ; nov† pozice pravÇho okna
         ret

public   tree

tree:                                     ;* ovl†d†n° stromovÇ struktury

         cmp       word ptr ds:[editnum],0  ; jsou nàjak† data v bufferu ?
         jne       tree0                    ; soubor naáten OK
         call      treex                    ; naáten° struktury adres†©ñ
         jc        strom5                   ; p©eru®en° operace
                                          ;* nastaven° na aktivn° adres†©
tree0:   xor       ax,ax
         mov       ds:[edikurz],ax          ; poá†teán° adresa kurzoru
         mov       ds:[firstrad],ax         ; prvn° zobrazenò ©†dek = 0
         mov       ds:[adrradek],ax         ; adresa aktivn°ho adres†©e
         inc       al
         mov       ds:[edidrad],al          ; ©†dek s kurzorem
                                          ;* porovn†n° jednÇ á†sti cesty
tree9:   mov       di,ds:[bp+4]             ; cesta k adres†©i
         xor       si,si                    ; zaá†tek seznamu
treef:   call      treecom                  ; porovn†n° á†sti adres†©e
         je        treeg                    ; je shoda - dal®° á†st
         call      treesrcn                 ; nalezen° dal®°ho adres†©e
         jnc       treef                    ; je dal®° adres†© - jeho test
         jmp       short tree6              ; shodnò adres†© nenalezen
                                          ;* nastaven° dal®° á†sti cesty
treeg:   inc       di
         cmp       byte ptr es:[di-1],0     ; byl jië konec adres†©e ?
         je        treeh                    ; je konec adres†©e
         cmp       byte ptr es:[di-1],"\"   ; je oddàlovaá ?
         jne       treeg                    ; nalezen° oddàlovaáe
         cmp       byte ptr es:[di],0       ; je to z†kladn° adres†© ?
         je        treeh                    ; je to z†kladn° adres†©
treej:   call      treelch                  ; dal®° znak ze seznamu
         jc        treeh
         jnz       treej                    ; nastaven° na dal®° podadres†©
         jmp       short treef              ; test dal®°ho podadres†©e
                                          ;* nalezen stejnò adres†©
treeh:   mov       ds:[edikurz],si          ; nastaven° adresy kurzoru
         mov       ds:[adrradek],si         ; nastaven° aktivn°ho adres†©e
                                          ;* nastaven° prvn°ho ©†dku
         mov       cx,12                    ; poáet ©†dkñ pro posun
treek:   call      treeprp                  ; nastaven° na p©edchoz° poloëku
         loop      treek
         mov       ds:[firstrad],si         ; nastaven° prvn°ho ©†dku

tree6:   call      stromxc                  ; z†màna oken
         call      window                   ; zobrazen° aktivn°ho okna
         call      topret                   ; n†vrat horn°ho ©†dku
         call      stromxc                  ; z†màna oken
         or        byte ptr cs:[config],10h ; p©°znak naáten° okna
         mov       bh,80h                   ; p©°znak zobrazen° okna
tree2:   call      treeall                  ; zobrazen° okna stromu
         push      cs
         pop       ds
         push      cs
         pop       es
         call      resshft                  ; zru®en° nucenÇho p©°znaku SHIFT

tree7:   call      mouseget                 ; vstup my®i
         jz        tree79                   ; nen° ë†dn† kl†vesa
         call      mousemen                 ; vstup funkán°ch kl†ves
         jnc       treeab
         mov       ax,011bh                 ; kl†vesa <ESC>
         cmp       bl,11                    ; je uvolnàn° pravÇho tlaá°tka ?
         je        treeab                   ; je kl†vesa ESC
                                          ;* kontrola mez°
         mov       dx,ds:[mousepoz]         ; pozice my®i
         call      getpocl                  ; posledn° ©†dek
;         mov       ch,23
;         call      testakth                 ; je n†povàda aktivn° ?
;         jnc       tree72
;         inc       ch
;tree72:
         cmp       dh,cl
         ja        tree79                   ; je pod oknem
         sub       dl,ds:[bp+3]             ; poá†teán° pozice okna
         jb        tree79
         cmp       dl,40
         jae       tree79
         mov       ax,1c0dh
         cmp       bl,7                     ; levÇ tlaá°tko 2x ?
         je        treeab                   ; je levÇ tlaá°tko 2x - nastaven°

         cmp       dh,ds:[edidrad]          ; je na kurzoru ?
         je        tree79                   ; je na kurzoru
         mov       ax,4800h                 ; kurzor nahoru
         jb        treeab                   ; je posun nahoru
         mov       ax,5000h                 ; kurzor dolñ
         jmp       short treeab             ; posun dolñ

tree79:  lea       si,[tabhlpt]             ; zobrazen° z†kladn° n†povàdy
         call      modihlp                  ; modifikace zobrazen° n†povàdy
         call      testalt                  ; je stisknut p©esmykaá ALT ?
         jnz       tree8                    ; je stisknut p©esmykaá ALT
         cmp       byte ptr cs:[numsrc],0   ; je jië pr†zdnò buffer ?
         je        tree8                    ; buffer je jië pr†zdnò
         mov       byte ptr cs:[numsrc],0   ; zru®en° bufferu znakñ
         call      topline                  ; zobrazen° horn°ho ©†dku
         call      kurzout                  ; vypnut° kurzoru
tree8:   cmp       word ptr cs:[edikey],0   ; je nàjak† kl†vesa ?
         jnz       treea                    ; byla nàjak† kl†vesa
         call      testkey                  ; je p©ipraven znak ?
         jnz       treea                    ; je p©ipraven znak - vstup
         test      byte ptr cs:[config],30h ; m† bòt naáten adres†© ?
         jnz       tree7                    ; nem† bòt naáten adres†©
         cmp       byte ptr cs:[citacexp],0 ; je á°taá jië 0 ?
         jne       tree7                    ; áek†n° na p©°chod znaku
         mov       ax,3d00h
         jmp       short tree4              ; novÇ naáten° adres†©e

treea:   call      inpkeyf                  ; vstup znaku s vypr†zdnàn°m
treeab:  mov       word ptr cs:[parbreak],0 ; zru®en° p©°znaku p©eru®en°
         and       byte ptr cs:[config],not 10h ; zru®en° p©°znaku naáten°
         mov       byte ptr cs:[citacexp],8 ; nastaven° á°taáe
         call      treequick                ; obsluha rychlovyhled†v†n° stromu
         jnc       tree20                   ; byla obsluha funkce
;         cmp       byte ptr ds:[numsrc],0   ; je nàjakò znak v bufferu ?
;         jne       tree20                   ; v bufferu je nàjakò znak
         cmp       al,27                    ; Esc
         je        tree5                    ; p©eru®en°
         cmp       ah,43h                   ; F9
         je        tree5                    ; p©eru®en°
         cmp       ah,70h                   ; Alt-F9
         je        tree5                    ; p©eru®en°
         cmp       ah,44h                   ; F10
         je        tree4                    ; nastaven°
         cmp       ah,71h                   ; Alt-F10
         je        tree4                    ; nastaven°
         cmp       al,13                    ; zmàna adres†©e ENTER
         je        tree4                    ; nastaven°
         cmp       ah,3ch                   ; je F2 (modifikace stromu) ?
         je        treesave                 ; uloëen° stromu
         cmp       ah,69h                   ; Alt-F2
         je        treesave                 ; uloëen° stromu

         call      treeoff                  ; vypnut° pñvodn°ho kurzoru
         lea       bx,[treeskok]            ; tabulka skokñ
         call      skokax                   ; obsluha
         jnc       tree20
         xor       bx,bx
tree20:  jmp       tree2

tree4:                                    ;* zmàna adres†©e ENTER
         push      ax
         call      storekall                ; £schova pozice kurzorñ obou oken
         push      cs
         pop       ds
         push      cs
         pop       es
         lea       si,[outbuf]              ; nov† cesta
         mov       di,ds:[bp+4]             ; adresa cesty
         call      transtxt                 ; p©enos novÇ cesty
         and       byte ptr ds:[bp+0],not 6 ; p©°znak, ëe adres†© nen° naáten
         pop       ax
         cmp       ah,3dh                   ; byla zmàna adres†©e F3 ?
         jne       tree5                    ; nebyla zmàna F3
         call      treeaktd                 ; nastaven° novÇho aktiv. adres†©e
         jmp       tree6
tree5:   ret

public   treesave
treesave:                                 ;* uloëen° stromu na disk F2
         push      cs
         pop       ds
IFNDEF   DEMO
         call      treex                    ; naáten° struktury adres†©ñ
         jc        treesav2                 ; je p©eru®en° operace
         lea       si,[rootdir]             ; z†kladn° adres†©
         call      aktdir                   ; nastaven° z†kladn°ho adres†©e
         lea       dx,[soubtre]             ; soubor DOSMAN.TRE
         xor       cx,cx                    ; atributy - norm†ln° soubor
         mov       ah,3ch
         int       21h                      ; vytvo©en° souboru DOSMAN.TRE
         jc        treesav2                 ; chyba vytvo©en°
         mov       bx,ax                    ; identifik†tor souboru
         mov       ds,cs:[topseged]         ; segment k uloëen° dat
         xor       dx,dx                    ; átec° adresa
         mov       cx,cs:[editnum]          ; dÇlka dat v pamàti
         mov       ah,40h
         int       21h                      ; z†pis souboru
         mov       ah,3eh
         int       21h                      ; uzav©en° souboru
         push      cs
         pop       ds
         call      treesav4                 ; p©ehl†®en° adres†©e
         call      cmpdisk                  ; jsou v oknech stejnÇ disky ?
         jne       treesav6                 ; nejsou stejnÇ disky
         push      bp
         call      getnakt                  ; neaktivn° okno
         call      treesav4                 ; p©ehl†®en° adres†©e
         call      window                   ; p©ekreslen° neaktivn°ho okna
         pop       bp
treesav6:clc
treesav2:push      cs
         pop       ds
         jc        tree5                    ; chyba - p©eru®en° operace
ENDIF
         jmp       tree0                    ; inicializace zobrazen°


treesav4:                                 ;* poëadavek novÇho naáten° adres†©e
         mov       si,ds:[bp+4]             ; adres†© okna
         cmp       byte ptr ds:[si+3],0     ; je z†kladn° adres†© ?
         jne       treesav5                 ; nen° to z†kladn° adres†©
         call      rerdir                   ; p©°znak novÇho naáten° adres†©e
;         and       byte ptr ds:[bp+0],not 2 ; p©°znak, ëe adres†© nen° naáten
;         or        byte ptr ds:[bp+0],4     ; p©°znka, ëe se adres†© nenuluje
treesav5:ret


treeaktd:                                 ;* novÇ nastaven° aktivn°ho adres†©e

                                          ;* porovn†n° jednÇ á†sti cesty
         mov       di,ds:[bp+4]             ; cesta k adres†©i
         xor       si,si                    ; zaá†tek seznamu
treedf:  call      treecom                  ; porovn†n° á†sti adres†©e
         je        treedg                   ; je shoda - dal®° á†st
         call      treesrcn                 ; nalezen° dal®°ho adres†©e
         jnc       treedf                   ; je dal®° adres†© - jeho test
         jmp       short treed6             ; shodnò adres†© nenalezen
                                          ;* nastaven° dal®° á†sti cesty
treedg:  inc       di
         cmp       byte ptr es:[di-1],0     ; byl jië konec adres†©e ?
         je        treedh                   ; je konec adres†©e
         cmp       byte ptr es:[di-1],"\"   ; je oddàlovaá ?
         jne       treedg                   ; nalezen° oddàlovaáe
         cmp       byte ptr es:[di],0       ; je to z†kladn° adres†© ?
         je        treedh                   ; je to z†kladn° adres†©
treedj:  call      treelch                  ; dal®° znak ze seznamu
         jc        treedh
         jnz       treedj                   ; nastaven° na dal®° podadres†©
         jmp       short treedf             ; test dal®°ho podadres†©e
                                          ;* nalezen stejnò adres†©
treedh:  mov       ds:[adrradek],si         ; nastaven° aktivn°ho adres†©e
treed6:  ret



public   treequick
treequick:                                ;* rychlovyhled†v†n° ve stromu
                                            ; VùSTUP: BH=posuv
                                            ;         CY=nezn†m† kl†vesa

         push      ax
         call      testalt                  ; je stisknuta kl†vesa ALT ?
         jz        treeq7                   ; nen° kl†vesa ALT
                                          ;* nastaven° ukazatelñ
         mov       cx,word ptr ds:[numsrc]  ; poáet znakñ v bufferu
         lea       di,[bufsrc]              ; buffer pro rychlÇ vyhled†v†n°
         add       di,cx                    ; ukl†dac° adresa do bufferu
         push      cx
         push      di
         sub       cl,12
         neg       cl                       ; doplnàk do 11
         mov       al,"?"
         rep       stosb                    ; vynulov†n° zbytku bufferu
         pop       di
         pop       cx
         mov       si,ds:[edikurz]          ; souáasnò kurzor
;         mov       si,4                     ; poá†teán° soubor k hled†n°

                                          ;* je platnò znak ?
         call      prevalt                  ; p©evod na znak ASCII
         jc        treeq1                   ; nen° platnò znak ASCII
                                          ;* uloëen° znaku do bufferu
         cmp       cl,12                    ; je buffer jië plnò ?
         jae       treeq9                   ; buffer je jië plnò
         stosb                              ; uloëen° znaku do bufferu
         inc       cl                       ; zvò®en° á°taáe znakñ v bufferu
         jmp       short treeq2             ; zobrazen° prvn°ho souboru
treeq1:                                   ;* je jin† kl†vesa
         lea       bx,[treetabq]            ; tabulka skokñ
         call      skokax                   ; obsluha kl†vesy
         jc        treeq9                   ; nen° zn†m† kl†vesa

treeq2:                                   ;* aktualizace parametrñ bufferu
         mov       ds:[numsrc],cl           ; novò poáet znakñ
                                          ;* nalezen° souboru od SI
treeq5:  lea       di,[bufsrc]              ; buffer pro rychlÇ vyhled†v†n°
         call      treecom                  ; porovn†n° poloëky
         je        treeq6                   ; poloëka nalezena
         call      treenxp                  ; nalezen° dal®° poloëky
         jnc       treeq5                   ; test dal®° poloëky
         jmp       short treeq7             ; poloëka nenalezena
treeq6:                                   ;* p©esun kurzoru na poloëku
         call      treeoff                  ; vypnut° pñvodn°ho kurzoru
         xor       bx,bx
         cmp       si,ds:[edikurz]          ; adresa kurzoru
         jb        treeqa                   ; je posun dolñ
treeqc:                                   ;* je posun dolñ
         cmp       si,ds:[edikurz]          ; je jië dosaëeno pozice ?
         je        treeq9                   ; je jië dosaëeno pozice
         call      treedown                 ; posun dolñ
         jnc       treeqc
         jmp       short treeq7

treeqa:                                   ;* je posun nahoru
         cmp       si,ds:[edikurz]          ; je jië dosaëeno pozice ?
         je        treeq9                   ; je jië dosaëeno pozice
         call      treeup                   ; posun dolñ
         jnc       treeqa
treeq7:  cmc
treeq9:  pop       ax
         ret


treetabq label     byte                     ; tabulka skokñ pro rychlovyhled†v†n°

         db        40h+7
         db        0a0h                     ; Alt-dolñ
         dw        offset treeqdn           ; posun na dal®° poloëku
         db        98h                      ; Alt-nahoru
         dw        offset treequp           ; posun nahoru
         db        0eh                      ; BS
         dw        offset treebs
         db        0a3h                     ; ALT-DELETE
         dw        offset treebs
         db        9bh                      ; ALT-vlevo
         dw        offset treebs
         db        97h                      ; ALT-HOME
         dw        offset treeqhome
         db        9fh                      ; ALT-END
         dw        offset treeqend

         db        0

public   treebs
treebs:                                   ;* zru®en° znaku
         jcxz      treebs2
         dec       cl
         dec       di
         mov       byte ptr es:[di],"?"
treebs2: ret


public   treeqdn
treeqdn:                                  ;* posun na dal®° poloëku
         call      treenxp                  ; nalezen° dal®° poloëky
         ret


public   treeqhome
treeqhome:                                ;* posun na prvn° poloëku
         xor       si,si
         ret



public   treeqend
treeqend:                                 ;* posun na posledn° poloëku
         mov       si,ds:[editnum]          ; adresa konce seznamu


public   treequp
treequp:                                  ;* posun na p©edchoz° poloëku
         push      di
treequp1:call      treeprp                  ; nalezen° p©edchoz° poloëky seznamu
         jc        treequp2                 ; nen° dal®° poloëka
         lea       di,[bufsrc]              ; hledanò text
         call      treecom                  ; porovn†n° s poloëkou
         jne       treequp1                 ; nen° shoda - dal®° poloëka
treequp2:pop       di
         ret


public   treecom
treecom:                                  ;* porovn†n° á†sti adres†©e
                                            ; VSTUP: ES:DI=porovn†vanò text
                                            ;        SI=adres†© v seznamu
                                            ; VùSTUP: ZY=je shoda

         push      ax
         push      si
         push      di
treecom1:call      treelch                  ; naáten° znaku ze seznamu
         cmp       al,"\"
         jne       treecom5
         xor       al,al
treecom5:mov       ah,es:[di]               ; naáten° porovn†vanÇho znaku
         inc       di                       ; zvò®en° ukazatele
         cmp       ah,"?"                   ; je n†hradn° znak ?
         je        treecom3                 ; je shoda - dal®° znak
         cmp       ah,"\"                   ; je konec á†sti ?
         jne       treecom2                 ; nen° konec
         xor       ah,ah                    ; n†hrada bajtem 0
treecom2:cmp       al,ah                    ; je shoda znakñ ?
         jne       treecom4                 ; nen° shoda znakñ
treecom3:or        al,al                    ; byl jië konec jmÇna ?
         jne       treecom1                 ; test dal®°ho znaku
treecom4:pop       di
         pop       si
         pop       ax
         ret


treeskok label     byte                   ;* tabulka skokñ pro strom
         db        40h+15                   ; testuje se AH
         db        50h                      ; kurzor dolñ DOWN
         dw        offset treedown
         db        48h                      ; kurzor nahoru UP
         dw        offset treeup
         db        4dh                      ; kurzor vpravo RIGHT
         dw        offset treedown
         db        4bh                      ; kurzor vlevo LEFT
         dw        offset treeleft
         db        47h                      ; prvn° poloëka HOME
         dw        offset treehome
         db        4fh                      ; posledn° poloëka END
         dw        offset treeend
         db        49h                      ; str†nka nahoru PAGE UP
         dw        offset treepgup
         db        51h                      ; str†nka dolñ PAGE DOWN
         dw        offset treepgdn
         db        8dh                      ; 6 ©†dkñ nahoru ^UP
         dw        offset treecup
         db        91h                      ; 6 ©†dkñ dolñ ^DOWN
         dw        offset treecdown
         db        84h                      ; zaá†tek seznamu ^PageUp
         dw        offset treehome
         db        76h                      ; konec seznamu ^PageDown
         dw        offset treeend
         db        77h                      ; horn° okraj ^Home
         dw        offset treechom
         db        75h                      ; doln° okraj ^End
         dw        offset treecend
         db        3dh                      ; automat. naá°t†n° F3
         dw        offset treeautom

         db        00h+2                    ; testuje se AL
         db        17h                      ; rolov†n° nahoru ^W
         dw        offset treerup
         db        1ah                      ; rolov†n° dolñ ^Z
         dw        offset treerdn

         db        0


public   treeautom
treeautom:                                ;* automatickÇ naá°t†n° adres†©e F3
         xor       byte ptr ds:[config],20h
         ret

public   treeoff

treeoff:                                  ;* vypnut° zobrazen° kurzoru
         push      si
         push      dx
         mov       si,ds:[edikurz]          ; adresa kurzoru
         dec       word ptr ds:[edikurz]    ; zru®en° ukazatele kurzoru
         mov       dh,ds:[edidrad]          ; ©†dek s kurzorem
         call      treelin                  ; novÇ zobrazen° kurzoru
         inc       word ptr ds:[edikurz]    ; n†vrat ukazatele kurzoru
         pop       dx
         pop       si
         ret

public   treeleft
treeleft:                                 ;* kurzor vlevo LEFT

         mov       dx,ds:[edikurz]          ; adresa kurzoru
treelf1: call      treeup                   ; kurzor nahoru
         jc        treelf2                  ; konec seznamu
         mov       si,ds:[edikurz]          ; adresa kurzoru
         call      treesrcn                 ; nalezen° dal®°ho adres†©e
         cmp       si,dx                    ; je jië nadadres†© ?
         jbe       treelf1                  ; nen° je®tà nadadres†©
treelf2: ret


public   treerup

treerup:                                  ;* rolov†n° nahoru ^W

         call      setshft                  ; nucenò p©°znak SHIFT
         call      treedown                 ; posun dolñ s rolov†n°m
         call      resshft                  ; zru®en° nucenÇho p©°znaku SHIFT
         jc        treerup1                 ; nebyl posun kurzoru
         cmp       byte ptr cs:[edidrad],1  ; je to prvn° ©†dek ?
         je        treerup1                 ; je to prvn° ©†dek
         call      treeup                   ; n†vrat kurzoru nahoru
treerup1:ret

public   treerdn

treerdn:                                  ;* rolov†n° dolñ ^Z

         call      setshft                  ; nucenò p©°znak SHIFT
         call      treeup                   ; posun nahoru s rolov†n°m
         call      resshft                  ; zru®en° nucenÇho p©°znaku SHIFT
         jc        treerdn1                 ; nebyl posun kurzoru
         call      getendl
         dec       dh
;         mov       al,21
;         call      testakth
;         jnc       treerdn0
;         inc       al                       ; posledn° ©†dek = 24
;treerdn0:
         cmp       cs:[edidrad],dh          ; je to posledn° ©†dek ?
         je        treerdn1                 ; je to posledn° ©†dek
         call      treedown                 ; n†vrat kurzoru nahoru
treerdn1:ret


public   treechom

treechom:                                 ;* horn° okraj ^Home
         cmp       byte ptr ds:[edidrad],1  ; je jië prvn° ©†dek ?
         je        treechm1                 ; je jië prvn° ©†dek
         call      treeup                   ; posun kurzoru nahoru
         jnc       treechom                 ; test dosaëen° pozice
treechm1:ret


public   treecend

treecend:                                 ;* doln° okraj ^End
         push      dx
         call      getendl
         dec       dh
         mov       cl,21                    ; doln° okraj
;         call      testakth                 ; je n†povàda aktivn° ?
;         jnc       treecen1                 ; n†povàda je aktivn°
;         inc       cl                       ; doln° okraj = 22
treecen1:
         cmp       ds:[edidrad],dh          ; je jië doln° okraj ?
         je        treecen2                 ; je jië doln° okraj
         call      treedown                 ; posun o ©†dek dolñ
         jnc       treecen1                 ; test dosaëen° pozice
treecen2:pop       dx
         ret


public   treecup

treecup:                                  ;* posun o 6 ©†dkñ nahoru
         push      cx
         mov       cx,6
         jmp       short treepgu2


public   treepgup

treepgup:                                 ;* posun o str†nku nahoru
         push      cx
         call      getpocl
         sub       cx,4
;         mov       cx,20
         call      setshft                  ; nucenò p©°znak SHIFT
treepgu2:call      treeup
         jc        treepgu3
         loop      treepgu2
treepgu3:call      resshft                  ; zru®en° nucenÇho p©°znaku SHIFT
         pop       cx
         ret


public   treecdown

treecdown:                                ;* posun o 6 ©†dkñ dolñ
         push      cx
         mov       cx,6
         jmp       short treepgd2

public   treepgdn

treepgdn:                                 ;* posun o str†nku dolñ
         push      cx
         call      getpocl
         sub       cx,4
;         mov       cx,20
         call      setshft                  ; nucenò p©°znak SHIFT
treepgd2:call      treedown
         jc        treepgd3
         loop      treepgd2
treepgd3:call      resshft                  ; zru®en° nucenÇho p©°znaku SHIFT
         pop       cx
         ret



public   treehome

treehome:                                 ;* posun kurzoru na prvn° poloëku
         call      treeup                   ; posun o ©†dek nahoru
         jnc       treehome                 ; posun o dal®° ©†dek
         ret


public   treeend

treeend:                                  ;* posun kurzoru na posledn° poloëku
         call      treedown                 ; posun o ©†dek dolñ
         jnc       treeend                  ; posun o dal®° ©†dek
         ret


public   treeup

treeup:                                   ;* posun kurzoru nahoru
                                            ; VùSTUP: CY=operace neprovedena

         push      si
         mov       si,ds:[edikurz]          ; adresa kurzoru
         call      treeprp                  ; nalezen° p©edchoz° poloëky
         jc        treeup3                  ; nen° dal®° poloëka
         dec       byte ptr ds:[edidrad]    ; sn°ëen° ©†dku na displeji
         mov       ds:[edikurz],si          ; nastaven° novÇho kurzoru
         call      testshft                 ; je stisknut p©esmykaá SHIFT ?
         jnz       treeup2                  ; je SHIFT - posun podkladu
         cmp       si,ds:[firstrad]         ; je pod prvn°m ©†dkem ?
         jae       treeup1                  ; nen° je®tà pod prvn°m ©†dkem
treeup2: mov       si,ds:[firstrad]         ; adresa prvn°ho ©†dku
         call      treeprp                  ; nalezen° p©edchoz° poloëky
         jc        treeup1                  ; nebyl posun
         dec       bh                       ; p©°znak posunu kurzoru nahoru
         mov       ds:[firstrad],si         ; nastaven° novÇho prvn°ho ©†dku
         inc       byte ptr ds:[edidrad]    ; n†vrat ©†dku s kurzorem
treeup1: clc
treeup3: pop       si
         ret


public   treedown

treedown:                                 ;* posun kurzoru dolñ
                                            ; VùSTUP: CY=operace neprovedena

         push      cx
         push      si

         call      getpocl
         sub       cx,2
;         mov       cx,21                    ; celkovò poáet ©†dkñ
;         call      testakth                 ; je n†povàda aktivn° ?
;         jnc       treedwn5                 ; n†povàda je aktivn°
;         inc       cx                       ; poáet ©†dkñ = 22
;treedwn5:
                                          ;* test opr†vnànosti operace
         mov       si,ds:[edikurz]          ; souáasn† pozice kurzoru
         call      treenxp                  ; nalezen° dal®° poloëky
         jc        treedwn4                 ; nen° dal®° poloëka
         mov       ds:[edikurz],si          ; nastaven° novÇho kurzoru
         inc       byte ptr ds:[edidrad]    ; sn°ëen° ©†dku na displeji
         call      testshft                 ; je stisknut p©esmykaá SHIFT ?
         jnz       treedwn2                 ; je SHIFT - posun podkladu
         cmp       byte ptr ds:[edidrad],cl ; je p©ekroáen konec ?
         jbe       treedwn3                 ; nen° p©ekroáen konec
treedwn2:                                 ;* kontrola, zda lze rolovat
         mov       si,ds:[firstrad]         ; adresa prvn°ho ©†dku
treedwn6:call      treenxp                  ; nalezen° dal®° poloëky
         jc        treedwn3                 ; nen° dal®° poloëka
         loop      treedwn6                 ; test dal®° poloëky
                                          ;* posun podkladu
         mov       si,ds:[firstrad]         ; adresa prvn°ho ©†dku
         call      treenxp                  ; nalezen° dal®° poloëky
         jc        treedwn3                 ; nebyl posun
         inc       bh                       ; p©°znak posunu kurzoru dolñ
         mov       ds:[firstrad],si         ; nastaven° novÇho prvn°ho ©†dku
         dec       byte ptr ds:[edidrad]    ; n†vrat ©†dku s kurzorem
treedwn3:clc
treedwn4:pop       si
         pop       cx
         ret

; -----------------------------------------------------------------------------
public   treeall

treeall:                                  ;* zobrazen° okna stromu

         push      si
         push      dx
         push      cx
         or        bh,bh                    ; je posun podkladu ?
         jz        treeall0                 ; je pouze p©ekreslen° kurzoru
                                          ;* je rolov†n° o 1 ©†dek ?
         mov       ah,6                     ; funkce rolov†n° nahoru
         mov       al,bh                    ; poáet ©†dkñ k rolov†n°
         jns       treeall2                 ; je rolov†n° nahoru
         neg       al                       ; poáet ©†dkñ k rolov†n°
         mov       ah,7                     ; funkce rolov†n° dolñ
treeall2:cmp       al,10                    ; je men®° poáet ©†dkñ neë 10 ?
         ja        treeall3                 ; p©ekreslen° celÇho okna
         call      treeroll                 ; rolov†n° okna
         xor       cx,cx
         mov       cl,al                    ; poáet novòch poloëek k zobrazen°
         or        bh,bh                    ; je rolov†n° nahoru ?
         js        treeall6                 ; je rolov†n° dolñ
                                          ;* je rolov†n° nahoru
         mov       bx,cx                    ; poáet novòch ©†dkñ

;         mov       cx,21                    ; celkovò poáet ©†dkñ
         call      getpocl
         sub       cx,2

         mov       dh,1                     ; poá†teán° ©†dek na displeji
         mov       si,ds:[firstrad]         ; prvn° ©†dek k zobrazen°
;         call      testakth                 ; je n†povàda aktivn° ?
;         jnc       treeall7                 ; n†povàda je aktivn°
;         inc       cx                       ; zvò®en° poátu ©†dkñ
;treeall7:
         sub       cx,bx                    ; poáet ©†dkñ, kterÇ se p©eskoá°
treeall8:call      treenxp                  ; nalezen° dal®°ho adres†©e
         inc       dh
         loop      treeall8                 ; nalezen° dal®°ho ©†dku
         mov       cx,bx                    ; poáet ©†dkñ k zobrazen°
         jmp       short treeall1           ; zobrazen° zbylòch ©†dkñ

treeall3:                                 ;* zobrazen° celÇho okna
         call      getpocl
         sub       cx,2
;         mov       cx,21
;         call      testakth                 ; je n†povàda aktivn° ?
;         jnc       treeall6                 ; n†povàda je aktivn°
;         inc       cx                       ; zvò®en° poátu ©†dkñ
treeall6:                                 ;* je rolov†n° dolñ
         mov       dh,1
         mov       si,ds:[firstrad]         ; prvn° ©†dek k zobrazen°
treeall1:call      treelin                  ; zobrazen° jednoho ©†dku
         call      treenxp                  ; nalezen° dal®°ho adres†©e
         inc       dh
         loop      treeall1
treeall0:                                 ;* obnoven° kurzoru
         mov       si,ds:[edikurz]          ; adresa kurzoru
         mov       dh,ds:[edidrad]          ; ©†dek s kurzorem
         call      treelin                  ; novÇ zobrazen° kurzoru
treeall4:call      treept                   ; sestaven° cesty k adres†©i
         call      treepath                 ; zobrazen° cesty s kurzorem
                                          ;* zobrazen° p©edvolby
         call      mouseoff                 ; vypnut° kurzoru my®i
;         mov       dh,25
         lea       si,[bufsrc]
         mov       al,2
         call      outch1
         xor       dh,dh
         mov       dl,ds:[bp+3]             ; poá†teán° pozice okna
         add       dl,2
         cmp       dl,22                    ; je levÇ okno ?
         ja        treeallb                 ; je pravÇ okno
         add       dl,8
treeallb:mov       cx,word ptr ds:[numsrc]  ; poáet znakñ v bufferu
         jcxz      treealld                 ; nen° ë†dnò znak v bufferu

         mov       al," "
         call      outch1
         push      cx
treeallc:lodsb
         call      lowcase                  ; p©evod na malÇ p°smeno
         call      outch1
         loop      treeallc
         pop       cx
         mov       al," "
         call      outch1
treealld:push      dx
         mov       al,1
         call      outch1
         mov       al,205                   ; znal "Õ"
         mov       cx,4
         call      outch
         pop       dx
         dec       dl
         cmp       byte ptr ds:[numsrc],0
         jne       treealla
         call      getdispl
         inc       dh
treealla:xor       al,al
         call      outch1                   ; nastaven° pozice kurzoru
treeall9:call      mouseon                  ; zapnut° kurzoru my®i
         pop       cx
         pop       dx
         pop       si
         ret


treepath:                                 ;* zobrazen° cesty
         call      mouseoff                 ; vypnut° kurzoru my®i
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
                                          ;* zobrazen° á†ry
         mov       dl,ds:[bp+3]             ; poá†teán° pozice okna
         call      getendl
;         mov       dh,22                    ; ©†dek k tisku
;         call      testakth
;         jnc       treepat2                 ; n†povàda nen° aktivn°
;         inc       dh                       ; ©†dek k zobrazen° = 23
;treepat2:
         mov       al,1                     ; nastaven° z†kladn° barvy textu
         call      outch1                   ; nastaven° z†kladn° barvy textu
         push      dx                       ; £schova poá†teán° pozice kurzoru
         mov       al,200                   ; levò spodn° roh
         call      outch1                   ; zobrazen° levÇho rohu
         mov       al,205                   ; vodorovn† dvojit† á†ra
         mov       cx,38                    ; dÇlka linky
         call      outch                    ; zobrazen° linky
         mov       al,188                   ; pravò spodn° roh
         call      outch1                   ; zobrazen° pravÇho rohu
         pop       dx                       ; n†vrat pozice kurzoru
                                          ;* zobrazen° oznaáen° disku
         mov       al,3                     ; barva kurzoru
         call      outch1                   ; nastaven° barvy kurzoru
         lea       si,[outbuf]              ; text cesty
         cmp       byte ptr ds:[si],0       ; je nàjakò text ?
         je        treepat4
         inc       dl                       ; zaá†tek k tisku textu
         mov       cl,36                    ; max. ®°©ka ©†dku
         call      center                   ; centrov†n° textu
         mov       al," "                   ; znak oddàlovac° mezery
         call      outch1                   ; zobrazen° mezery
         lodsb                              ; znak jmÇna disku
         call      outch1                   ; zobrazen° jmÇna disku
         lodsb                              ; znak ":"
         call      outch1                   ; zobrazen° znaku ":"
         lodsb                              ; znak "\"
         call      outch1                   ; zobrazen° znaku "\"
                                          ;* zobrazen° zbytku cesty
         mov       di,si                    ; zaá†tek cesty (za oznaáen°m disku)
         mov       cx,255                   ; á°taá dÇlky ©etàzce
         xor       al,al                    ; hledanò bajt 0
         repnz     scasb                    ; nalezen° konce textu
         not       cl                       ; dÇlka ©etàzce
         cmp       cl,34                    ; je text del®° neë 34 znakñ ?
         jna       treepat3                 ; text nen° del®° neë 34 znakñ
         sub       cl,31                    ; p©ebytek dÇlky ©etàzce
         add       si,cx                    ; zaá†tek ©etàzce
         mov       al,"."                   ; oddàlovac° teáka
         mov       cx,3                     ; poáet znakñ "."
         call      outch                    ; zobrazen° textu "..."
treepat3:call      outtxt                   ; zobrazen° (zbytku) cesty adres†©e
         mov       al," "                   ; znak oddàlovac° mezery
         call      outch1                   ; zobrazen° mezery
treepat4:call      kurzout                  ; vypnut° kurzoru

         pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         call      mouseon                  ; zapnut° kurzoru my®i
         ret


public   treelin

treelin:                                  ;* zobrazen° jednoho ©†dku adres†©e
                                            ; VSTUP: DH=©†dek k zobrazen°
                                            ;        SI=adresa adres†©e

         call      mouseoff                 ; vypnut° kurzoru my®i
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         xor       dl,dl                    ; referenán° á°taá pozice
         lea       di,[outbuf]              ; pracovn° buffer
         mov       al," "
         stosb                              ; £vodn° mezera
         cmp       si,ds:[editnum]          ; je jië konec bufferu ?
         jb        treelin0                 ; nen° je®tà konec bufferu
         jmp       treelin8                 ; je konec bufferu
treelin0:or        si,si                    ; je z†kladn° adres†© ?
         jz        treelin6                 ; je z†kladn° adres†©
         mov       bx,si                    ; £schova pozice kurzoru
         xor       si,si                    ; ukazatel na zaá†tek seznamu
treelin1:                                 ;* nastaven° na prvn° podadres†©
         call      treelch                  ; naáten° dal®°ho znaku
         jc        treelin6                 ; konec seznamu
         jnz       treelin1                 ; nalezen° konce textu adres†©e
treelin2:                                 ;* nalezen° nejblië®°ho adres†©e
         mov       cx,si                    ; mezi£schova adres†©e
         call      treesrcn                 ; nalezen° dal®°ho adres†©e
         mov       al," "                   ; znak - nen° dal®° adres†©
         jc        treelin3                 ; nen° dal®° adres†©
         mov       al,179                   ; znak "≥" (je dal®° adres†©)
treelin3:cmp       si,bx                    ; je jië za kurzorem ?
         jb        treelin2                 ; je je®tà p©ed kurzorem
         je        treelin4                 ; je to tento adres†©
         cmp       cx,bx                    ; je to jië tento adres†© ?
         jae       treelin5                 ; je to tento adres†©
                                          ;* je nadadres†©
         mov       si,cx                    ; n†vrat adres†©e
         cmp       dl,29
         jae       treelin1
         stosb                              ; nastaven° prvn°ho znaku
         inc       dl
         mov       al," "
         cmp       dl,23                    ; je za pozic° 23 ?
         jae       treelin1                 ; je za pozic° 23
         cmp       dl,11                    ; je za pozic° 11 ?
         jae       treelinm                 ; je za pozic° 11
         stosb                              ; prvn° mezera
         inc       dl
treelinm:stosb                              ; druh† mezera
         inc       dl
         jmp       short treelin1           ; zobrazen° dal®°ho adres†©e
                                          ;* nalezen tento adres†©
treelin5:mov       si,cx                    ; n†vrat adres†©e
treelin4:
         push      si
         call      treesrcn                 ; nalezen° dal®°ho adres†©e
         pop       si
         mov       al,192                   ; znak "¿"
         jc        treelin7                 ; nen° dal®° adres†©
         mov       al,195                   ; znak "√"
treelin7:cmp       dl,29
         jb        treelino
         dec       di
         mov       al,">"
treelino:stosb
         mov       al,196                   ; znak "ƒ"
         cmp       dl,22                    ; je za pozic° 23 ?
         jae       treelin6                 ; je za pozic° 23
         cmp       dl,10                    ; je za pozic° 11 ?
         jae       treelinn                 ; je za pozic° 11
         stosb
treelinn:stosb
treelin6:
         mov       al,1
         cmp       si,ds:[edikurz]          ; je to kurzor ?
         jne       treelind                 ; nen° to kurzor
         mov       al,3                     ; oznaáen° kurzoru
         mov       ds:[edidrad],dh          ; £schova ©†dku na displeji
treelind:cmp       si,ds:[adrradek]         ; je to aktivn° adres†© ?
         jne       treeline                 ; nen° to aktivn° adres†©
         inc       al                       ; atribut je vysv°cenò
treeline:mov       ds,ds:[topseged]
         stosb
         mov       cx,12
treelinf:lodsb
         or        al,al                    ; je konec ?
         jnz       treeling                 ; nen° to konec textu
         dec       si                       ; n†vrat ukazatele
         mov       al," "                   ; n†hradn° znak
treeling:stosb
         loop      treelinf                 ; p©enos dal®°ho znaku
         mov       al,1
         stosb
         push      cs
         pop       ds
                                          ;* zobrazen° adres†©e
treelin8:xor       al,al
         stosb                              ; oznaáen° konce textu
         mov       dl,ds:[bp+3]             ; poá†teán° pozice okna
         mov       al,1
         call      outch1                   ; nastaven° barvy
         mov       al,186                   ; znak "∫"
         call      outch1                   ; zobrazen° znaku
         lea       si,[outbuf]              ; buffer s textem
         mov       cx,38                    ; ®°©ka ©†dku
treelin9:lodsb                              ; naáten° znaku k zobrazen°
         or        al,al                    ; je jië konec textu ?
         jnz       treelina                 ; nen° konec textu
         dec       si                       ; n†vrat pozice konce
         mov       al," "                   ; n†hradn° znak mezery
treelina:cmp       al,32                    ; je znak k zobrazen° ?
         jae       treelinb                 ; je zobrazitelnò znak
         inc       cx                       ; n†vrat á°taáe znakñ
treelinb:call      outch1                   ; zobrazen° znaku
         loop      treelin9                 ; zobrazen° dal®°ho znaku
         mov       al,1
         call      outch1                   ; norm†ln° barva
         mov       al,186                   ; znak "∫"
         call      outch1                   ; zobrazen° znaku

         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         call      mouseon                  ; zapnut° kurzoru my®i
         ret

; -----------------------------------------------------------------------------
;                     Vyhled†v†n° v seznamu adres†©ñ
; -----------------------------------------------------------------------------

public   treeprp

treeprp:                                  ;* p©edchoz° poloëka seznamu
                                            ; VSTUP: SI=adresa
                                            ; VùSTUP: CY=nen° dal®° adres†©
                                            ;         SI=adresa p©edch. poloëky

         push      ax
treeprp1:                                 ;* nalezen° konce poloëky
         call      treeprch                 ; naáten° p©edchoz°ho znaku
         jc        treeprp3                ; je jië zaá†tek seznamu
         jz        treeprp1                 ; je oddàlovaá - dal®° znak
treeprp2:                                 ;* nalezen° zaá†tku poloëky
         call      treeprch                 ; naáten° dal®°ho znaku
         jc        treeprp4                 ; je jië zaá†tek seznamu
         jnz       treeprp2                 ; nen° oddàlovaá - dal®° znak
         inc       si
treeprp4:clc
treeprp3:pop       ax
         ret


; -----------------------------------------------------------------------------
public   treeprch

treeprch:                                 ;* naáten° p©edchoz°ho znaku
                                            ; VSTUP: SI=adresa znaku
                                            ; VùSTUP: CY=je jië zaá†tek seznamu

         push      ds
         mov       ds,cs:[topseged]         ; segment se seznamem
         or        si,si
         stc
         jz        treeprc2                 ; je zaá†tek seznamu
         dec       si
         mov       al,ds:[si]               ; znak
         or        al,al
treeprc2:pop       ds
         ret


; -----------------------------------------------------------------------------
public   treenxp

treenxp:                                  ;* dal®° poloëka seznamu
                                            ; VSTUP: SI=adresa
                                            ; VùSTUP: CY=nen° dal®° adres†©
                                            ;         SI=adresa dal®° poloëky

         push      ax
treenxp1:                                 ;* nalezen° oddàlovaáe poloëek
         call      treelch                  ; naáten° dal®°ho znaku
         jb        treenxp3                 ; je jië konec seznamu
         jnz       treenxp1                 ; nen° oddàlovaá - dal®° znak
treenxp2:                                 ;* nalezen° zaá†tku poloëky
         call      treelch                  ; naáten° dal®°ho znaku
         jb        treenxp3                 ; je jië konec seznamu
         jz        treenxp2                 ; je oddàlovaá - dal®° znak
         dec       si                       ; n†vrat zaá†tku
treenxp3:pop       ax
         ret



; -----------------------------------------------------------------------------
public   treesrcn

treesrcn:                                 ;* nalezen° dal®°ho adres†©e
                                            ; VSTUP: SI=adresa adres†©e
                                            ; VùSTUP: CY=nen° dal®° adres†©
                                            ;         SI=adresa dal®°ho adr.

         push      ax
                                          ;* nalezen° konce poloëky
treesrc1:call      treelch                  ; naáten° dal®°ho znaku
         jc        treesrc2                 ; konec seznamu
         jnz       treesrc1                 ; nalezen° konec textu adres†©e
                                          ;* p©eskoáen° pod©°zenÇ poloëky
treesrc3:call      treelch                  ; oddàlovac° znak
         jc        treesrc2                 ; konec seznamu
         jz        treesrc4                 ; nen° dal®° podadres†©
         dec       si                       ; poá†teán° adresa poloëky
treesrc5:call      treesrcn                 ; nalezen° dal®°ho adres†©e
         jnc       treesrc5                 ; p©eskoáen° v®ech poloëek
         inc       si                       ; p©eskoáen° koncovÇ 0
treesrc4:                                 ;* test, zda je n†sleduj°c° poloëka
         push      ds
         mov       ds,cs:[topseged]
         cmp       byte ptr ds:[si],0       ; je dal®° poloëka ?
         pop       ds
         stc
         je        treesrc2                 ; nen° dal®° poloëka
         clc
treesrc2:pop       ax
         ret

; -----------------------------------------------------------------------------
public   treept

treept:                                   ;* sestaven° cesty s kurzorem
         push      ax
         push      dx
         push      si
         push      di
         push      ds
         push      es
         lea       di,[outbuf]              ; buffer k uloëen° cesty
         mov       byte ptr cs:[outbuf],0   ; zru®en° dat v bufferu
         cmp       word ptr cs:[editnum],0
         je        treept5
         mov       ds,cs:[topseged]         ; segment se seznamem
         push      cs
         pop       es                       ; ukl†dac° segment cesty

         xor       si,si                    ; ukazatel zaá†tku seznamu
                                          ;* nalezen° nadadres†©e
treept1: mov       dx,si                    ; mezi£schova adres†©e
         call      treesrcn                 ; nalezen° dal®°ho adres†©e
         cmp       si,cs:[edikurz]          ; je jië za kurzorem ?
         jb        treept1                  ; je pod kurzorem - dal®° poloëka
         je        treept4                  ; je shoda
treept2:                                  ;* nalezen nadadres†© - p©enesen°
         mov       si,dx                    ; n†vrat zaá†tku adres†©e
treept4: mov       dx,si
         or        si,si                    ; je poá†teán° adres†© ?
         jz        treept3                  ; je poá†teán° adres†©
         cmp       byte ptr es:[di-1],"\"   ; byla jië cesta ?
         je        treept3                  ; byla jië cesta
         mov       al,"\"
         stosb                              ; uloëen° oddàlovaáe cest
treept3: call      transtxt                 ; p©enesen° textu cesty adres†©e
         cmp       dx,cs:[edikurz]          ; byl to jië aktivn° adres†© ?
         jne       treept1                  ; nebyl - dal®° podadres†©
treept5:
         pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       ax
         ret

; -----------------------------------------------------------------------------
;                        Naáten° struktury adres†©ñ
; -----------------------------------------------------------------------------
treex:                                    ;* novÇ naáten° adres†©e
                                            ; VùSTUP: CY=p©eru®en° operace

         push      ax
         push      bx
         push      si
         push      di
         push      es
         push      ds
         push      cs
         pop       ds
         test      byte ptr ds:[config],8   ; je adres†© jië naáten ?
         jnz       treex2                   ; adres†© je jië naáten
                                          ;* uloëen° z†kladn°ho adres†©e
         xor       di,di                    ; poá†teán° ukl†dac° adresa
         mov       es,cs:[topseged]         ; segment k uloëen° dat
         mov       si,ds:[bp+4]             ; cesta k adres†©i
         movsw                              ; p©enos jmÇna disku a znaku ":"
         movsb                              ; p©enos znaku "\"
         xor       ax,ax                    ; AX <- 0
         stosw                              ; uloëen° koncovÇho slova 0
         mov       ds:[editnum],di          ; poáet znakñ v bufferu
         call      msgcek                   ; zobrazen° hl†®en° "Äekejte"
         call      kurzout                  ; vypnut° kurzoru
                                          ;* nastaven° vòchoz°ho adres†©e
         lea       si,[rootdir]             ; z†kladn° adres†©
         call      aktdir                   ; nastaven° z†kladn°ho adres†©e
         call      testbreak                ; je p©eru®en° operace ?
         jc        treex2                   ; je p©eru®en° operace
                                          ;* naáten° struktury adres†©ñ
         xor       bx,bx                    ; ukazatel na nad©azenò adres†©
         call      treeload                 ; naáten° adres†©ñ
         or        byte ptr ds:[config],8   ; p©°znak naáten° adres†©ñ
         mov       word ptr ds:[edikurz],0  ; poá†teán° pozice kurzoru
         mov       byte ptr ds:[ediradek],0 ; offset ©†dku
         mov       byte ptr ds:[edidrad],1  ; ©†dek s kurzorem
         mov       word ptr ds:[adrradek],0 ; adresa aktivn°ho adres†©e
         call      testbreak                ; bylo p©eru®en° operace ?
treex2:  pop       ds
         pop       es
         pop       di
         pop       si
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   treeload

treeload:                                 ;* naáten° seznamu adres†©ñ
                                            ; VSTUP: ES:DI=ukl†dac° adresa
                                            ;        BX=nad©azenò adres†©

         call      treefirst                ; nalezen° prvn°ho adres†©e
         jc        treelo5                  ; nenalezen ë†dnò adres†©
treelo2:                                  ;* zde je nalezen dal®° adres†©
         call      treesd                   ; uloëen° adres†©e do seznamu
         call      treept                   ; sestaven° cesty k adres†©i
         call      treepath                 ; zobrazen° cesty adres†©e
                                          ;* p©epnut° na adres†©
         call      testbreak                ; je p©eru®en° operace ?
         jc        treelo5                  ; je p©eru®en° operace
         mov       si,9eh                   ; testovanò adres†©
         call      aktdir                   ; nastaven° nalezenÇho adres†©e
         jc        treelo6                  ; chyba, adres†© nelze nastavit
                                          ;* £schova tabulky DTA
         mov       si,80h                   ; zaá†tek tabulky DTA
         mov       cx,22                    ; poáet slov k uloëen°
treelo3: push      word ptr ds:[si]         ; £schova 2 bajtñ z tabulky DTA
         add       si,2                     ; zvò®en° adresy v tabulce
         loop      treelo3                  ; dal®° 2 bajty z tabulky
                                          ;* prohled†v†n° podadres†©e
         push      bx
         mov       bx,ds:[edikurz]          ; novò adres†©
         call      treeload                 ; naáten° dal®°ho adres†©e
         pop       bx
                                          ;* navr†cen° tabulky DTA
         mov       si,80h+44                ; konec tabulky DTA
         mov       cx,22                    ; poáet slov k uloëen°
treelo4: sub       si,2                     ; navr†cen° adresy v tabulce DTA
         pop       word ptr ds:[si]         ; navr†cen° 2 bajtñ tabulky DTA
         loop      treelo4                  ; navr†cen° dal®°ch 2 bajtñ tabulky
                                          ;* navr†cen° adres†©e
         call      testbreak                ; je p©eru®en° operace ?
         jc        treelo5                  ; je p©eru®en° operace
         lea       si,[nadadr]              ; cesta k nadadres†©i ".."
         call      aktdir                   ; nastaven° pñvodn°ho adres†©e
                                          ;* nalezen° dal®°ho adres†©e
treelo6: call      treenext                 ; nalezen° dal®°ho adres†©e
         jnc       treelo2                  ; nalezen dal®° adres†©
treelo5: ret

; -----------------------------------------------------------------------------
public   treefirst

treefirst:                                ;* nalezen° prvn°ho adres†©e
                                            ; VùSTUP: CY=nen° ë†dnò adres†©

         call      testbreak                ; je p©eru®en° operace ?
         jc        treefst2                 ; je p©eru®en° operace
         push      ax
         push      cx
         push      dx
         mov       cx,37h                   ; atribut - v®echny soubory
         lea       dx,[all]                 ; specifikace - v®echny soubory
         mov       ah,4eh
         int       21h                      ; nalezen° adres†©e
         pop       dx
         pop       cx
         pop       ax
         jc        treefst2                 ; nen° ë†dnò soubor
         call      treetestd                ; test, zda byl nalezen adres†©
         jc        treenext                 ; nen° to adres†© - dal®° soubor
treefst2:ret

; -----------------------------------------------------------------------------
public   treenext

treenext:                                 ;* nalezen° dal®°ho adres†©e
                                            ; VùSTUP: CY=nen° dal®° adres†©

         call      testbreak                ; je p©eru®en° operace ?
         jc        treenxt2                 ; je p©eru®en° operace
         push      ax
         mov       ah,4fh
         int       21h                      ; nalezen° dal®°ho souboru
         pop       ax
         jc        treenxt2                 ; nenalezen dal®° soubor
         call      treetestd                ; test, zda byl nalezen adres†©
         jc        treenext                 ; nen° to adres†©
treenxt2:ret

; -----------------------------------------------------------------------------
public   treetestd

treetestd:                                ;* test, zda byl nalezen adres†©
                                            ; VùSTUP: CY=nen° platnò adres†©

         test      byte ptr ds:[95h],10h    ; je to adres†© ?
         jz        treetst3                 ; nen° to adres†©
         cmp       word ptr ds:[9eh],"."    ; je to adres†© "." ?
         je        treetst3                 ; je to adres†© "."
         cmp       word ptr ds:[9eh],".."   ; je to adres†© ".." ?
         je        treetst3                 ; je to adres†© ".."
         stc                                ; p©°znak - je platnò adres†©
treetst3:cmc                                ; negace p©°znaku adres†©e
         ret

; -----------------------------------------------------------------------------
public   treesd

treesd:                                   ;* zaálenàn° adres†©e do seznamu
                                            ; VSTUP: BX=nad©azenò adres†©

         push      ax
         push      bx
         push      cx
         push      si
         push      di

         mov       si,bx                    ; adresa nad©azenÇho adres†©e
treesd1:                                  ;* nalezen° prvn°ho podadres†©e
         call      treelch                  ; naáten° dal®°ho znaku
         jnz       treesd1                  ; nen° oddàlovaá - dal®° znak
treesd2:                                  ;* nalezen° vy®®° poloëky neë nov†
         call      treetest                 ; je m°sto pro vloëen° poloëky ?
         jbe       treesd3                  ; nalezena men®° poloëka
         call      treesrcn                 ; nalezen° dal®° poloëky
         jmp       short treesd2            ; test dal®° poloëky
treesd3:                                  ;* vytvo©en° m°sta pro poloëku
         mov       ds:[edikurz],si          ; adresa kurzoru - aktu†ln° adres†©
         push      si                       ; adresa k uloëen° poloëky
         mov       si,9eh                   ; adresa jmÇna adres†©e
         call      lensi                    ; zji®tàn° dÇlky jmÇna
         cbw                                ; AX <- dÇlka textu adres†©e
         pop       si
         mov       cx,ds:[editnum]          ; konec seznamu
         sub       cx,si                    ; poáet bajtñ dat k odsunu
         mov       di,si                    ; c°lov† adresa
         add       di,ax                    ; posun dat
         add       di,2                     ; m°sto pro koncovou 0
         add       si,cx
         add       di,cx
         mov       ds:[editnum],di          ; novò konec seznamu
         dec       si
         dec       di
         std                                ; smàr dolñ
         push      ds
         mov       ds,ds:[topseged]           ; segment se seznamem
         rep       movsb                    ; uvolnàn° m°sta
         pop       ds
         cld                                ; smàr nahoru
                                          ;* p©enesen° poloëky
         mov       si,9eh                   ; jmÇno novÇ poloëky
         mov       di,ds:[edikurz]          ; adresa k uloëen° poloëky
         call      transtxt                 ; p©enos novÇ poloëky
         xor       ax,ax
         stosw                              ; uloëen° koncovÇ 0

         pop       di
         pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   treetest

treetest:                                 ;* test poloëky pro zaálenàn°
                                            ; VSTUP: SI=testovan† adresa
                                            ; VùSTUP: CY=nov† poloëka je men®°
                                            ;         ZY=je koncov† 0 adres†©e
         push      ax
         push      si
         push      di
         mov       di,9eh                   ; jmÇno novÇ poloëky
         call      treelch                  ; naáten° dal®°ho znaku
         jz        treets2                  ; je koncov† 0 adres†©e
treets1: cmp       ds:[di],al               ; porovn†n° znakñ jmÇna
         jne       treets2                  ; nen° shoda - n†vrat
         or        al,al                    ; je konec jmÇna ?
         jz        treets2                  ; je konec jmÇna
         inc       di                       ; zvò®en° ukazatele novÇ poloëky
         call      treelch                  ; naáten° dal®°ho znaku
         jnc       treets1                  ; test dal®°ho znaku
treets2: pop       di
         pop       si
         pop       ax
         ret

; -----------------------------------------------------------------------------
;                           Vstup/vòstup znakñ
; -----------------------------------------------------------------------------
public   treelch

treelch:                                  ;* naáten° znaku ze seznamu
                                            ; VSTUP: SI=adresa znaku

         push      ds
         cmp       si,cs:[editnum]          ; je jië dosaëeno konce ?
         cmc
         jb        treelch2                 ; je jië konec seznamu
         mov       ds,cs:[topseged]         ; segment se seznamem
         lodsb
         or        al,al
treelch2:pop       ds
         ret


treeroll:                                 ;* rolov†n° okna
                                            ; VSTUP: AH=k¢d operace 6,7
                                            ;        AL=poáet ©†dkñ

         call      mouseoff                 ; vypnut° kurzoru my®i
         push      bp
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         mov       cl,ds:[bp+3]             ; poá†teán° pozice
         inc       cl
         mov       dl,cl
         add       dl,37
         mov       bh,ds:[col1]
         mov       ch,1
         call      getendl
         dec       dh
;         mov       dh,22
;         call      testakth                 ; je n†povàda aktivn° ?
;         jc        wrolldn1                 ; nen° aktivn°
;         dec       dh
;wrolldn1:
         cmp       al,dh
         jb        wrolldn2
         mov       al,dh
         dec       al
wrolldn2:int       10h
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         pop       bp
         call      mouseon                  ; zapnut° kurzoru my®i
         ret



code     ends

         end


; modul DOSMUSE.ASM

; *****************************************************************************
;
;                          Ovl†d†n° programu
;
; *****************************************************************************

extrn    storekall:near,kurzlin:near,skokax:near,obrlin:near,edilin:near
extrn    editor:near,zobraz:near,setwsel:near
extrn    select:near,wram1:near,wram2:near,setwsel:near,wnadpis:near
extrn    podklad:near,storesel:near
extrn    parbreak:word
extrn    endline:near,kurzoff:near,zobrfile:near
extrn    files:near,kurzon:near,endline:near,msgcek:near,diskfail:near
extrn    hledpol:near,adrpolsi:near,adrpoldi:near,cmpfile:near,obrpath:near
extrn    window:near,rozborn:near,topret:near,getkurz:near,readdir:near
extrn    creatfile:near,storfile:near,settabf:near,soucins:near
extrn    getatrib0:near,insertf:near,directory:near,delpolf:near
extrn    aktdisk:near,srcnxt:near,srcins:near,aktfile:near,space:near
extrn    storefile:near,hledpol0:near,rozbor:near
extrn    obnovs:near,radeknul:near,srcins0:near,storekur:near

public   uziv



uziv:                                     ;* inicializace povelovÇho ©†dku

         call      outhelp                  ; zobrazen° n†povàdy

uziv0:
         call      obrkurz                  ; zobrazen° kurzoru povel. ©†dku
         push      cs
         pop       ds
         push      cs
         pop       es

         call      getakt                   ; aktivn° okno
         test      byte ptr ds:[bp+0],1     ; je okno zapnuto ?
         jnz       uziv03                   ; okno je zapnuto
         call      getnakt                  ; neaktivn° okno
         test      byte ptr ds:[bp+0],1     ; je neaktivn° okno takÇ vypnuto ?
         jz        uziv03                   ; je takÇ vypnuto
         xor       byte ptr ds:[flags],1    ; zmàna aktivn°ho okna
         call      windretx                 ; navr†cen° oken

uziv03:
         call      getakt
uziv04:  push      cs
         pop       ds
         push      cs
         pop       es

uziv044:
         call      inpkeyf                  ; vstup znaku z kl†vesnice
         call      getakt                   ; poskytnut° ukazatele aktiv. okna
         mov       word ptr ds:[parbreak],0
         cmp       al,27                    ; je kl†vesa <Esc> ?
         jne       uziv12
         mov       al,19h                   ; n†hrada znakem ^Y (maz†n° ©†dku)
uziv12:
         cmp       word ptr ds:[poclin],0   ; je nàjakò znak v bufferu ?
         jne       uziv18                   ; v bufferu je nàjakò znak
         cmp       ah,4bh                   ; je kurzor vlevo ?
         jne       uziv1c                   ; nen° kurzor vlevo
         cmp       byte ptr ds:[bp+3],20    ; je levÇ okno ?
         jb        uziv1d                   ; je levÇ okno - neplat°
uziv1e:  mov       ax,0f09h                 ; n†hrada znakem tabel†toru

uziv1c:  cmp       ah,4dh                   ; je kurzor vpravo ?
         jne       uziv1d                   ; nen° kurzor vpravo
         cmp       byte ptr ds:[bp+3],20    ; je pravÇ okno ?
         jb        uziv1e                   ; je levÇ okno - OK
uziv1d:
         cmp       ah,47h                   ; je kl†vesa HOME ?
         jne       uziv17                   ; nen° HOME
         mov       ah,84h                   ; n†hrada kl†vesou ^PAGEUP
uziv17:  cmp       ah,4fh                   ; je kl†vesa END ?
         jne       uziv18                   ; nen° END
         mov       ah,76h                   ; n†hrada kl†vesou ^PAGEDOWN

uziv18:                                   ;* obsluha uëivatelskòch funkc°
         cmp       ax,0300h                 ; ^@
         je        uziv16
         cmp       ah,4eh                   ; [+]
         je        uziv19
         cmp       ah,4ah                   ; [-]
         je        uziv19
         cmp       ah,37h                   ; [*]
         je        uziv19
         or        ah,ah                    ; je znak s ALT ?
         jz        uziv16
         cmp       al,32
         jae       uziv16                   ; je znak ASCII
uziv19:
         mov       bx,offset skokuziv       ; tabulka skokñ do uëivat. funkce
         call      skokax                   ; skok do obsluhy funkce
         jnc       uziv1a                   ; k¢d kl†vesy nalezen - OK

uziv16:                                   ;* obsluha editaán°ch funkc°
uziv166: call      usesedit                 ; obsluha editaán°ch kl†ves
uziv1a:  jmp       uziv0


public   usesedit

usesedit:                                 ;* obsluha editaán°ch kl†ves
         push      ds
         push      cs
         pop       ds
         push      ax
         mov       ax,ds:[bp+numfl-tabl]    ; poáet poloëek v seznamu
         mov       ds:[pocrol],ax           ; poáet poloëek celkem
         mov       ax,ds:[bp+kurzl-tabl]    ; pozice kurzoru
         mov       ds:[kurrol],ax           ; pozice kurzoru
         mov       ax,ds:[bp+firstl-tabl]   ; prvn° zobrazen† poloëka
         mov       ds:[zacrol],ax           ; prvn° zobrazenò ©†dek
         push      cx
         call      getnumf                  ; poáet souborñ v oknà
         mov       ds:[delrol],cl
         pop       cx
         pop       ax

         push      bp
         mov       bp,offset comlin         ; definice povelovÇho ©†dku
         call      edilin                   ; editace povelovÇho ©†dku
         pop       bp
         call      retwind                  ; n†vrat parametrñ okna po editaci
         pop       ds
         ret



public   skokuziv

skokuziv label     word                     ; tabulka skokñ do uëivatel. funkc°

         db        00h+6                    ; testuje se AL
         db        02h                      ; zap/vyp n†povàdy CTRL-B
         dw        offset sethlp
         db        09h                      ; p©epnut° oken ^I, TAB
         dw        offset xchgakt
         db        0ah                      ; p©enesen° jmÇna CTRL-ENTER, ^J
         dw        offset ctrlent
         db        0ch                      ; zap/vyp druhÇho okna CTRL-L
         dw        offset xchgw
         db        0dh                      ; ENTER, ^M
         dw        offset enterx
         db        0fh                      ; zap/vyp obou oken CTRL-O
         dw        offset xchgall

         db        40h+14                   ; testuje se AH
         db        52h                      ; oznaáen° souboru INS
         dw        offset insert
         db        4eh                      ; oznaáen° souborñ [+]
         dw        offset selplus
         db        4ah                      ; oznaáen° souborñ [-]
         dw        offset selminus
         db        37h                      ; inverze vòbàru [*]
         dw        offset invsel
         db        3bh                      ; nastaven° levÇho disku F1
         dw        offset setdskl
         db        3ch                      ; nastaven° pravÇho disku F2
         dw        offset setdskr
         db        3dh                      ; prohl°ëen° souborñ F3
         dw        offset zobraz
         db        3eh                      ; editace souborñ F4
         dw        offset editor
         db        3fh                      ; kop°rov†n° F5
         dw        offset copyfile
         db        40h                      ; p©esun souborñ F6
         dw        offset movefile
         db        41h                      ; vyto©en° adres†©e F7
         dw        offset vytvadr
         db        42h                      ; ru®en° souborñ F8
         dw        offset delfile
         db        43h                      ; historie povelñ F9
         dw        offset povely
         db        44h                      ; konec programu F10
         dw        offset keyf10

         db        0

; -----------------------------------------------------------------------------
public   keyf10

keyf10:                                   ;* ukonáen° programu F10
         mov       di,offset txtkon1        ; nadpis 'Chcete ukonáit program ?'
         mov       si,offset txtkon2        ; volby Ano/Ne
         xor       al,al                    ; p©edvolen† poloëka "Ano"
         call      volbyh                   ; proveden° voleb (horizont†lnà)
         jc        keyf101                  ; p©eru®en° operace
         or        al,al                    ; je volba "Ano" ?
         jz        keyf102                  ; je ukonáen° programu
keyf101: call      windretx                 ; n†vrat zobrazen° oken
         ret

public   keyf102
keyf102:                                  ;* ukonáen° programu
         mov       sp,cs:[zasob]            ; n†vrat vrcholu z†sobn°ku
         xor       al,al
         mov       ds:[80h],al              ; vymaz†n° p©°kazovÇho ©†dku
         jmp       mainx                    ; n†vrat do systÇmu

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
retwind0:call      getnuml                  ; poáet ©†dkñ souborñ
         mov       dx,cx
         mov       ax,ds:[zacrol]           ; prvn° zobrazenò ©†dek
         cmp       ax,ds:[bp+firstl-tabl]   ; nastala zmàna poá†tku ?
         je        retwind8                 ; nenastala zmàna poá†tku
         call      kurzoff                  ; vypnut° kurzoru
         mov       bx,ds:[kurrol]           ; pozice kurzoru
         mov       ds:[bp+kurzl-tabl],bx    ; nov† pozice kurzoru
         xchg      ax,ds:[bp+firstl-tabl]   ; uloëen° novÇho poá†tku
         sub       ax,ds:[bp+firstl-tabl]   ; rozd°l pro posun okna
         ja        retwind5                 ; je rolov†n° dolñ
                                          ;* rolov†n° nahoru
         neg       ax                       ; poáet ©†dkñ k rolov†n°
         cmp       ax,8                     ; omezen° - nebude se jië rolovat
         ja        retwind4
         call      wrollup                  ; rolov†n° okna nahoru o AL ©†dkñ
         mov       bx,ds:[bp+firstl-tabl]   ; prvn° zobrazenò soubor
         add       bl,ds:[delrol]           ; poáet ©†dkñ okna
         adc       bh,0                     ; posledn° ©†dek
         sub       bx,ax                    ; prvn° ©†dek k doplnàn°
retwind6:
retwind3:
         mov       cx,ax                    ; poáet ©†dkñ
retwind2:call      zobrfile                 ; zobrazen° poloëky
         inc       bx                       ; zvò®en° ukazatele poloëek
         loop      retwind2                 ; dal®° poloëka
         jmp       short retwind7

retwind5:                                 ;* rolov†n° dolñ
         cmp       ax,8                     ; omezen° - nebude se jië rolovat
         ja        retwind4
         call      wrolldown                ; rolov†n° okna nahoru o AL ©†dkñ
         mov       bx,ds:[bp+firstl-tabl]   ; prvn° zobrazenò soubor
         neg       dx
         jmp       short retwind6

retwind4:call      files                    ; zobrazen° souborñ
         jmp       short retwind9

retwind8:mov       ax,ds:[kurrol]           ; pozice kurzoru
         cmp       ax,ds:[bp+kurzl-tabl]    ; byla zmàna kurzoru ?
         je        retwind9                 ; nen° zmàna kurzoru
         call      kurzoff                  ; vypnut° kurzoru
         mov       ds:[bp+kurzl-tabl],ax    ; uloëen° novÇ pozice kurzoru
retwind7:call      kurzon                   ; zapnut° kurzoru
retwind9:pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
outhelp:                                  ;* zobrazen° z†kladn° n†povàdy
         pushf
         push      si
         call      obrcomm                  ; zobrazen° p©°kazovÇho ©†dku
         mov       si,offset txthelp        ; tabulka z†kladn°ch n†povàd
         call      outthlp                  ; zobrazen° textu n†povàdy
         call      obrkurz                  ; navr†cen° zobrazen° kurzoru
         pop       si
         popf
         ret

outthlp:                                  ;* zobrazen° textu n†povàdy
                                            ; VSTUP: SI=adresa textu n†povàdy
         push      dx
         push      si
         push      ds
         push      cs
         pop       ds
         call      testakth                 ; je n†povàda povolena ?
         jc        outthlp5                 ; n†povàda nen° povolena
         call      getdispl                 ; posledn° ©†dek obrazovky
         xor       dl,dl
         call      outtxt                   ; zobrazen° textu n†povàdy
outthlp5:pop       ds
         pop       si
         pop       dx
         ret

; -----------------------------------------------------------------------------
public   testshft

testshft:                                 ;* test stisku kl†vesy Shift
                                            ; VùSTUP: ZN=kl†vesa je stisknuta

         test      byte ptr cs:[conf2],8    ; je nucenò SHIFT ?
         ret

; -----------------------------------------------------------------------------
public   obrkurz

obrkurz:                                  ;* zobrazen° kurzoru p©°kazovÇho ©†dku
         push      bp
         mov       bp,offset comlin         ; definice povelovÇho ©†dku
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
         mov       bp,offset comlin         ; definice povelovÇho ©†dku
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
         mov       al,cs:[normat]           ; atributy p©°kazovÇho ©†dku
         mov       cs:[color],al            ; nastaven° atributñ barev
         xor       dl,dl                    ; poá†teán° pozice kurzoru
         call      getendl                  ; á°slo posledn°ho ©†dku displeje
         inc       dh
         test      byte ptr cs:[flags],2    ; jsou okna vypnuta ?
         jz        pathcm1                  ; okna nejsou vypnuta
                                          ;* okna jsou vypnuta
         mov       cx,80
         call      radeknul                 ; vymaz†n° ©†dku

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
pathcm2: mov       cs:[bp+dellin-comlin],al ; ®°©ka ©†dku textu
         mov       cs:[bp+pozlin-comlin],dx ; pozice zaá†tku textu
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   setdskl,setdskr,setdsk11

setdskl:                                  ;* p©epnut° disku pro levÇ okno F1
         call      getakt                   ; aktivn° okno
         cmp       byte ptr ds:[bp+3],20    ; je levÇ okno ?
         jb        setdsk1                  ; je levÇ okno
         jmp       short setdsk0

setdskr:                                  ;* p©epnut° disku pro pravÇ okno F2
         call      getakt                   ; aktivn° okno
         cmp       byte ptr ds:[bp+3],20    ; je pravÇ okno ?
         jae       setdsk1                  ; je pravÇ okno
setdsk0: call      getnakt                  ; druhÇ okno

setdsk1:
                                          ;* sestaven° nadpisu
         mov       di,offset outbuf         ; pracovn° buffer
         mov       si,offset txtdisk1
setdsk11:
         call      transtxt                 ; p©enos textu "Zmàna disku pro "
         mov       si,offset txtdisk2       ; text "levÇ"
         cmp       byte ptr ds:[bp+3],20    ; je levÇ okno ?
         jb        setdsk2                  ; je levÇ okno
         mov       si,offset txtdisk3       ; text "pravÇ
setdsk2: call      transtxt                 ; p©enos textu
         mov       si,offset txtdisk4       ; text "okno:"
         call      transtxt                 ; p©enos textu
                                          ;* sestaven° textu voleb
         mov       di,offset outbuf         ; pracovn° buffer
         mov       bx,ds:[bp+4]             ; adresa cesty
         xchg      di,si                    ; £schova DI do SI
         mov       di,offset selbuf
         push      di
         xor       dx,dx                    ; ukazatel á°sla disku
         mov       cx,40                    ; maxim†ln° poáet diskñ
setdsk3: push      cx                       ; £schova á°taáe diskñ
         push      dx                       ; £schova á°taáe diskñ
         mov       ah,0eh                   ; funkce vòbàru aktivn°ho disku
         int       21h                      ; vòbàr aktivn°ho disku DL
         mov       ah,19h                   ; funkce poskytnut° aktivn°ho disku
         int       21h                      ; poskytnut° aktivn°ho disku
         mov       ah,-1                    ; n†hradn° oznaáen°
         cmp       al,dl                    ; kontrola á°sla disku
         jne       setdsk4                  ; nen° platnò disk
                                          ;* vloëen° disku do textu
         add       al,"A"                   ; korekce á°sla disku na znak ASCII
         mov       ah,al                    ; £schova oznaáen° disku
         stosb                              ; uloëen° oznaáen° disku
         xor       al,al                    ; oddàlovaá poloëek
         stosb                              ; oddàlovac° mezera
setdsk4: pop       dx                       ; n†vrat á°taáe diskñ
         pop       cx                       ; n†vrat á°taáe diskñ
         cmp       ah,ds:[bx]               ; je dosaëeno disku ?
         jae       setdsk5
         inc       dh                       ; zvò®en° ukazatele poloëky
setdsk5: inc       dl                       ; zvò®en° á°sla disku
         loop      setdsk3                  ; nastaven° dal®°ho disku
         xor       al,al
         stosb                              ; koncov† 0
         pop       di
         xchg      di,si
         mov       al,dh                    ; p©edvolen† poloëka
         call      volbyh                   ; proveden° voleb (horizont†lnà)
         call      windretx                 ; n†vrat zobrazen° oken
         jnc       setdsk53
         ret                                ; p©eru®en° operace
                                          ;* nastaven° novÇho disku
setdsk53:and       byte ptr ds:[bp+0],not 6 ; p©°znak nenaátenÇho adres†©e
         or        byte ptr ds:[bp+0],1     ; p©°znak zapnut° okna
         test      byte ptr ds:[flags],2    ; jsou obà okna vypnuta ?
         jz        setdsk55                 ; nejsou obà okna vypnuta
         push      bp
         mov       bp,ds:[bp+1]             ; adresa druhÇho okna
         and       byte ptr ds:[bp+0],not 1 ; vypnut° opaánÇho okna
         pop       bp
setdsk55:and       byte ptr ds:[flags],not 2 ; zapnut° oken
         call      msgcek                   ; hl†®en° "áekejte"
                                          ;* n†vrat adres†©e (stejnò disk)
         mov       al,ds:[si]               ; oznaáen° novÇho disku
         mov       di,ds:[bp+4]             ; p©°stupov† cesta k adres†©i
         mov       si,di                    ; oznaáen° p©°stupovÇ cesty
         cmp       al,ds:[di]               ; je zmàna disku ?
         jne       setdsk64                 ; je zmàna disku
         call      cmpdisk                  ; jsou shodnÇ disky v oknech ?
         jne       setdsk63                 ; nejsou shodnÇ disky
         push      bp
         call      getakt
         mov       si,ds:[bp+4]             ; cesta k aktivn°mu oknu
         pop       bp
         jmp       short setdsk63           ; nen° zmàna - novÇ naáten° adres†©e
setdsk64:                                 ;* zmàna disku
         mov       si,ds:[bp+1]             ; tabulka protàj®°ho okna
         mov       si,ds:[si+4]             ; cesta k protàj®°mu oknu
         cmp       al,ds:[si]               ; souhlas° novò disk s protàj®°m ?
         je        setdsk63                 ; novò disk souhlas°->protàj®° okno
         call      cmpdisk                  ; porovn†n° diskñ oken
         jne       setdsk7                  ; ani pñvodn° disky nejsou shodnÇ
         call      cmppath                  ; porovn†n° cest diskñ
         je        setdsk7                  ; cesty jsou shodnÇ
setdsk63:call      aktdir                   ; nastaven° cesty k protàj®°mu oknu
setdsk7: sub       al,41h                   ; korekce na á°slo disku
         mov       dl,al                    ; poëadovanò disk
         mov       ah,0eh                   ; funkce vòbàru aktivn°ho disku
         int       21h                      ; nastaven° novÇho disku
         clc
         call      diskfail
         jc        setdsk9                  ; je diskov† chyba - zru®en°
         call      loadpath                 ; sestaven° novÇ p©°stupovÇ cesty
         call      diskfail                 ; obsluha diskovÇ chyby

         call      storekall                ; £schova pozice kurzorñ obou oken
         and       byte ptr ds:[bp+0],not 6 ; p©°znak, ëe adres†© nen° naáten
setdsk9:
         call      windretx                 ; n†vrat zobrazen° oken
         ret

;-----------------------------------------------------------------------------
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

volbyh48:
volbyh49:
         call      inpkeyf                  ; vstup znaku z kl†vesnice
volbyh4a:
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

; -----------------------------------------------------------------------------
public   xchgakt,xchgwind

xchgakt:                                  ;* zmàna aktivn°ho okna TAB

         call      testaktw                 ; test zapnut° okna
         jc        xchgakt2                 ; okno je vypnutÇ
                                          ;* je neaktivni okno zapnute ?
         call      testaktwn                ; je neaktivni okno zapnute ?
         jc        xchgwind                 ; okno nen° zapnutÇ - z†màna oken
                                          ;* pouze se p©epne okno
         xor       byte ptr ds:[flags],1    ; zmàna aktivn°ho okna
         call      windretx
         xor       ax,ax
         call      usesedit
         ret

xchgwind:                                 ;* z†màna oken ^U
         mov       al,ds:[pozr]             ; pozice pravÇho okna
         xchg      al,ds:[pozl]             ; z†màna s pozic° levÇho okna
         mov       ds:[pozr],al             ; nov† pozice pravÇho okna
xchgakt1:call      windretx                 ; obnoveni zobrazeni oken
xchgakt2:ret

; -----------------------------------------------------------------------------
public   selminus,selplus


selminus:                                 ;* vòbàr souborñ pomoc° [-]

         mov       di,offset txtunsel       ; nadpis "zru®it vòbàr"
         xor       dl,dl                    ; p©°znak zru®en° oznaáen°
         jmp       short selfile

selplus:                                  ;* vòbàr souborñ pomoc° [+]

         mov       di,offset txtsel         ; nadpis "vybrat soubory"
         mov       dl,80h                   ; p©°znak nastaven° oznaáen°

selfile:                                  ;* vòbàr podle specifikace
         call      testaktw                 ; test zapnut° okna
         jc        selplus8                 ; okno je vypnutÇ
         mov       si,offset historie       ; buffer historie
         mov       byte ptr ds:[histor2],1  ; poáet p©edvoleb
         mov       word ptr ds:[histor3],offset all ; p©edvolba

         call      select                   ; zad†n° masky
         jc        selplus6                 ; p©eru®en° volby
         xor       bx,bx                    ; poá†teán° poloëka v seznamu
selplusx:                                 ;* smyáka oznaáen° souborñ
         call      adrpoldi                 ; poskytnut° adresy poloëky
         jc        selplus6                 ; konec seznamu
         inc       bx                       ; zvò®en° ukazatele souborñ
         test      byte ptr es:[di],10h     ; je adres†© ?
         jnz       selplusx                 ; je adres†©
         call      testnm                   ; test podm°nky vòbàru souborñ
         jne       selplusx                 ; soubor neodpov°d†
         and       byte ptr es:[di],7fh     ; zru®en° p©°znaku vòbàru
         or        es:[di],dl               ; zmàna atributu
         jmp       short selplusx           ; dal®° poloëka seznamu
selplus6:
         call      windretx
selplus8:ret

; -----------------------------------------------------------------------------
public   testnm

testnm:                                   ;* test podm°nky shody jmen souborñ
                                            ; VSTUP: ES:DI=jmÇno ve vnit©. tvaru
                                            ; VùSTUP: ZY=je shoda jmen

         push      si
         push      ds
         push      cs
         pop       ds
         mov       si,offset rozbset        ; rozbor jmÇna souboru
         call      cmpfile                  ; porovn†n° jmÇna souboru
         pop       ds
         pop       si
         ret

; -----------------------------------------------------------------------------
public   insert

insert:                                   ;* oznaáen° souboru
         mov       ax,0ff00h                ; hodnota pro nulov†n° a maskov†n°

         call      testaktw                 ; test zapnut° okna
         jc        insert3                  ; okno je vypnutÇ
         call      getkurz                  ; poskytnut° adresy kurzoru
         jc        insert3                  ; nen° platnò kurzor
         test      byte ptr ds:[si],10h
         jnz       insert4                  ; je to adres†©
insert1: xor       byte ptr ds:[si],80h     ; zmàna vòbàru
         and       byte ptr ds:[si],ah      ; nulov†n° bitu
         or        byte ptr ds:[si],al      ; nastaven° bitu
         call      endline                  ; zobrazen° koncovÇho ©†dku
         call      kurzon                   ; novÇ zobrazen° kurzoru
insert4: mov       al,18h                   ; kl†vesa ^X (kurzor dolñ)
         call      usesedit                 ; posun kurzoru o ©†dek dolñ
insert3: ret

; -----------------------------------------------------------------------------
public   invsel

invsel:                                   ;* inverze vòbàru souborñ [*]
         mov       ax,0ff00h                ; hodnota pro nulov†n° a maskov†n°

selsoub:                                  ;* nastaven° poloëek v seznamu
         call      testaktw                 ; test zapnut° okna
         jc        selsoub4                 ; okno je vypnutÇ
         xor       bx,bx                    ; á°slo prvn° poloëky
selsoub1:call      adrpolsi                 ; poskytnut° adresy prvn° poloëky
         jc        selsoub3                 ; je konec seznamu
         inc       bx                       ; zvò®en° ukazatele poloëky
         test      byte ptr ds:[si],10h     ; je to adres†© ?
         jnz       selsoub1                 ; je adres†© - dal®° poloëka
         xor       byte ptr ds:[si],80h     ; zmàna vòbàru
         and       byte ptr ds:[si],ah      ; nulov†n° bitu
         or        byte ptr ds:[si],al      ; nastaven° bitu
         jmp       short selsoub1           ; dal®° poloëka
selsoub3:call      windretx                 ; n†vrat zobrazen° oken
selsoub4:ret

; -----------------------------------------------------------------------------
public   ctrlent

ctrlent:                                  ;* p©enesen° jmÇna poloëky CTRL-ENTER

public   entname

entname:                                  ;* vloëen° jmÇna poloëky

         call      testaktw                 ; test zapnut° okna
         jc        entname3                 ; okno je vypnutÇ
         call      getkurz                  ; poskytnut° adresy kurzoru
         jc        entname3                 ; nen° platnÇ jmÇno
         mov       di,offset outbuf         ; vòstupn° buffer
         push      di                       ; £schova adresy bufferu
         call      dekfile                  ; zak¢dov†n° jmÇna souboru
         pop       si                       ; adresa bufferu
         push      cs
         pop       ds
         xor       ah,ah
entname1:lodsb
         or        al,al                    ; je jië konec ?
         jz        entname2                 ; konec textu
         call      usesedit                 ; zobrazen° znaku
         jmp       short entname1
entname2:mov       al," "                   ; znak ukonáovac° mezery
         call      usesedit
entname3:ret

; -----------------------------------------------------------------------------
public   enterx

enterx:                                   ;* funkce ENTER

         mov       cx,ds:[poclin]           ; poáet znakñ v bufferu
         call      testaktw                 ; test zapnut° okna
         jc        entex08                  ; okno je vypnutÇ
         or        cx,cx                    ; je nàjakò znak v bufferu ?
         je        entex0                   ; v bufferu nen° ë†dnò znak

entex08:                                  ;* proveden° p©°kazu z ©†dku
         mov       ds:[numselb],cx          ; poáet znakñ textu
         mov       si,offset buftxt         ; buffer textu p©°kazovÇho ©†dku
         mov       di,offset selbuf         ; buffer pro zad†n° voleb
         rep       movsb                    ; p©enos textu
         mov       si,offset historie       ; buffer historie
         call      storesel                 ; uloëen° textu do bufferu
entex02:                                  ;* proveden° p©°kazu SI
         push      cs
         pop       ds
         mov       dl,2                     ; p©°znak, ëe se text zobraz°
         jmp       execute                  ; proveden° p©°kazu DS:SI

                                          ;* v bufferu nen° ë†dnò znak
entex0:  call      getkurz                  ; poskytnut° adresy souboru s kurz.
         jc        entex212                 ; nen° ë†dnò soubor
         test      byte ptr ds:[si],10h     ; je adres†© ?
         jnz       entex2                   ; je adres†©

                                          ;* proveden° p©°kazu s kurzorem
         call      testexe                  ; je spustitelnò program ?
         je        entex07                  ; je spustitelnò program
         ret

entex07:
         mov       di,offset outbuf         ; pracovn° buffer
         push      di
         call      dekfile                  ; dek¢dov†n° jmÇna souboru
         pop       si                       ; buffer s textem
         jmp       short entex02            ; proveden° p©°kazu

entex212:ret                                ; adres†© se nep©epne

entex2:                                   ;* zmàna adres†©e DS:SI (novò adres†©)
                                          ;* £schova jmÇna adres†©e
         push      si
         push      ds
         cmp       word ptr ds:[si+1],".."  ; je p©epnut° do podadres†©e ?
         push      cs
         pop       ds
         mov       si,offset nadadr         ; oznaáen° nad©azenÇho adres†©e ".."
         jne       entex23                  ; nen° p©epnut° do ko©ene
         mov       si,ds:[bp+4]             ; cesta k adres†©i
entex23: call      rozbor                   ; rozbor jmÇna souboru
         mov       si,offset rozbset        ; jmÇno adres†©e
         call      storefile                ; £schova jmÇna cesty
         pop       ds
         pop       si
                                          ;* p©epnut° adres†©e
         mov       di,offset outbuf         ; tiskovò buffer
         push      di                       ; cesta k novÇmu adres†©i
         call      dekfile                  ; zak¢dov†n° jmÇna souboru
         push      cs
         pop       ds
         call      msgcek                   ; hl†®en° "áekejte"
         mov       si,ds:[bp+4]             ; cesta k pñvodn°mu adres†©i
         call      aktdir                   ; nastaven° aktivn°ho adres†©e
         pop       si                       ; jmÇno novÇ cesty
         call      aktdir                   ; zapnut° novÇho adres†©e
         mov       di,cs:[bp+4]             ; p©°stupov† cesta k adres†©i
         call      loadpath                 ; sestaven° novÇ p©°stupovÇ cesty
         and       byte ptr ds:[bp+0],not 6 ; p©°znak, ëe se adres†© nuluje
         call      windretx                 ; navr†cen° oken
         ret

; -----------------------------------------------------------------------------
public   execute
execute:                                  ;* proveden° p©°kazu DS:SI
                                            ; DX=0 p©°znak, ëe se text nezobraz°

         call      msgcek                   ; hl†®en° "áekejte"
                                          ;* p©enesen° p©°kaz. ©†dku na 80h
         push      cs
         pop       es
         mov       di,81h                   ; p©°kazovò ©†dek
         mov       ax,"c/"
         stosw                              ; parametr "/c"
                                          ;* zji®tàn° dÇlky textu
         push      si
         mov       al,2
execut2: cmp       byte ptr ds:[si],0
         je        execut3
         inc       si
         inc       al
         jns       execut2
         dec       al
execut3: pop       si

         mov       es:[80h],al              ; dÇlka p©°kazu
         xor       ch,ch
         mov       cl,al                    ; dÇlka p©°kaz. ©†dku
         sub       cl,2
         rep       movsb                    ; p©enesen° textu p©°kazu
         xor       al,al                    ; n†vratovò k¢d - operace OK
         jmp       mainx                    ; skok do p©°kazu

; -----------------------------------------------------------------------------
public   xchgall

xchgall:                                  ;* vyp/zap obou oken ^O

         test      byte ptr cs:[flags],2    ; jsou okna zapnuta ?
         jnz       xchgall2                 ; okna jsou vypnuta
                                          ;* okna maj° bòt zapnuta
         call      testaktw                 ; je aktivn° okno zapnuto ?
         jc        xchgall3                 ; zapnut° aktivn°ho okna
xchgall2:
         xor       byte ptr cs:[flags],2    ; zmàna p©°znaku vypnut° obou oken
xchgall3:or        byte ptr cs:[bp+0],1     ; zapnut° aktivn°ho okna
         call      windretx                 ; n†vrat zobrazen° oken
         ret

; -----------------------------------------------------------------------------
public   xchgw

xchgw:                                    ;* zmàna zapnut° okna ^L

         call      testaktw                 ; je aktivn° okno zapnuto ?
         pushf
         or        byte ptr cs:[bp+0],1     ; zapnut° aktivn°ho okna
         call      getnakt                  ; poskytnut° adresy neakt. okna
         xor       byte ptr cs:[bp+0],1     ; zmàna p©°znaku aktivity
         popf
         jnc       xchgw2                   ; aktivn° okno je zapnutÇ
xchgw1:                                   ;* zapnut° pouze aktivn°ho okna
         and       byte ptr cs:[flags],not 2; zapnut° oken
         and       byte ptr cs:[bp+0],not 1 ; vypnut° neakt. okna
xchgw2:
         call      windretx                 ; zobrazen° oken
         ret

; -----------------------------------------------------------------------------
public   sethlp

sethlp:                                   ;* nastaven° n†povàdy ^B

         xor       byte ptr ds:[flags],4    ; zmàna p©°znaku n†povàdy
                                          ;* neaktivn° okno
         call      getnakt                  ; poskytnut° adresy neaktiv. okna
         xor       ax,ax
         call      usesedit                 ; normalizace parametrñ
                                          ;* aktivn° okno
         call      getakt                   ; poskytnut° adresy aktivn°ho okna
         xor       ax,ax
         call      usesedit                 ; normalizace parametrñ
         call      windretx                 ; n†vrat zobrazen° oken
         ret

; -----------------------------------------------------------------------------
public   povely

povely:                                   ;* historie povelñ F9

         mov       byte ptr ds:[histor2],0  ; poáet p©edvoleb
         mov       ax,ds:[poclin]           ; poáet znakñ v bufferu
         or        ax,ax                    ; je nàjakò znak v bufferu ?
         jnz       povely1                  ; v bufferu je nàjakò znak
         cmp       byte ptr ds:[histor1],0  ; je nàco v bufferu ?
         je        povely4                  ; buffer je pr†zdnò
povely1: inc       byte ptr ds:[histor2]    ; je 1 p©edvolba
         mov       si,offset buftxt         ; buffet textu p©°kaz. ©†dku
         mov       ds:[histor3],si          ; adresa bufferu s textem
         add       si,ax                    ; konec textu
         mov       byte ptr ds:[si],0       ; konec textu
povely2: mov       si,offset historie       ; buffer povelñ
         mov       di,offset txtpovel       ; text "Historie povelñ: "
         call      select                   ; volby
         call      windretx
         jc        povely4                  ; p©eru®en° voleb
         jmp       entex02                  ; proveden° povelu
povely4: ret

; -----------------------------------------------------------------------------
public   vytvadr

vytvadr:                                  ;* vytvo©en° adres†©e F7

         mov       byte ptr ds:[histor2],0  ; nen° ë†dn† p©edvolba
         mov       si,offset historie       ; buffer historie
         mov       di,offset txtvyt1        ; text nadpisu "Vytvo©°m adres†©: "
         call      select                   ; volby
vytvad0: call      windretx                 ; pñvodn° zobrazen° oken
         jnc       vytvad1                  ; je zadanò adres†©
         ret

vytvad1:                                  ;* vytvo©en° adres†©e
         call      msgcek                   ; hl†®en° "áekejte"
                                          ;* nastaven° aktu†ln°ho adres†©e
         call      kurzout                  ; vypnut° kurzoru
         mov       si,ds:[bp+4]             ; adres†© okna
         call      aktdir                   ; nastaven° aktivn°ho adres†©e okna
         jc        vytvad0                  ; diskov† chyba
                                          ;* inicializace zadanÇho adres†©e
         mov       si,offset outbuf         ; pracovn° buffer
         call      aktdir                   ; nastaven° zadanÇho adres†©e
         jc        vytvad4                  ; diskov† chyba
         mov       di,offset selbuf         ; buffer k naáten° adres†©e
         call      loadpath                 ; naáten° adres†©e
         jc        vytvad4                  ; diskov† chyba
                                          ;* dek¢dov†n° jmÇna adres†©e
         mov       di,offset outbuf         ; buffer pro uloëen° jmÇna
         mov       si,offset rozbflg        ; zadanÇ jmÇno adres†©e
         mov       byte ptr ds:[si],10h     ; p©°znak adres†©e
         call      dekfile                  ; dek¢dov†n° jmÇna adres†©e
                                          ;* hl†®en° o vytv†©en° adres†©e
         call      informc                  ; vymaz†n° informaán°ho okna
         mov       si,offset txtvyt2        ; text "Vytv†©°m adres†©"
         call      outtxt
         mov       si,offset selbuf         ; cesta k adres†©i
         call      outtxt
         cmp       byte ptr ds:[si-2],"\"   ; byla cesta ukonáena s "\" ?
         je        vytvad2                  ; byl znak "\"
         mov       al,"\"
         call      outch1                   ; zobrazen° znaku "\"
vytvad2: mov       si,offset outbuf         ; jmÇno adres†©e
         call      outtxt                   ; zobrazen° jmÇna novÇho adres†©e
         call      kurzout                  ; vypnut° kurzoru
                                          ;* vytvo©en° adres†©e
         mov       dx,offset outbuf         ; jmÇno novÇho adres†©e
         mov       ah,39h                   ; funkce vytvo©en° adres†©e
         int       21h                      ; vytvo©en° adres†©e
                                          ;* aktualizace adres†©ñ
         call      getakt                   ; aktivn° okno
         call      vytvad8                  ; aktualizace adres†©e
         call      getnakt                  ; neaktivn° okno
         call      vytvad8                  ; aktualizace adres†©e

vytvad5: stc
vytvad3: jmp       vytvad0

vytvad4: clc
         call      testbreak                ; je p©eru®en° operace ?
         jc        vytvad3                  ; je p©eru®en° operace
         mov       si,offset erradres       ; chyba "ChybnÇ zad†n° adres†©e !"
         call      zobrchyb                 ; zobrazen° chybovÇho hl†®en°
         jmp       short vytvad5


vytvad8:                                  ;* aktualizace adres†©e

         call      cmpcpath                 ; je to c°lovò adres†© ?
         jne       vytvad82                 ; nen° to c°lovò adres†©
         mov       si,offset rozbflg        ; zadanÇ jmÇno adres†©e
         call      storefile                ; uloëen° adres†©e pro p©edvolbu
         call      rerdir                   ; novÇ naáten° adres†©e
vytvad82:ret

; -----------------------------------------------------------------------------
public   zobrchyb

zobrchyb:                                 ;* zobrazen° chybovÇho hl†®en°
                                            ; VSTUP: CS:SI=text hl†®en° chyby

         push      es
         push      ds
         push      cs
         pop       es
         push      cs
         pop       ds
         push      ax
         push      di
         push      si
         mov       di,offset buffail        ; buffer pro hl†®en° chyb
         mov       si,offset txtchyb
         call      transtxt                 ; p©enos textu
         pop       si
         push      si
         call      transtxt
         mov       si,offset txtchyb1
         mov       di,offset buffail
         xor       al,al
         call      volbyh
         pop       si
         pop       di
         pop       ax
         pop       ds
         pop       es
         call      windret                  ; pñvodn° zobrazen° oken
         stc
         ret

; -----------------------------------------------------------------------------
public   getoper

getoper:                                  ;* poskytnut° operace
                                            ; VùSTUP: AL=0:kop°rov†n° souborñ
                                            ;            1:p©ejmenov†n° souborñ
                                            ;            2:ru®en° souborñ
                                            ; p©°znaky: JB - kop°r. nebo p©ejm.
                                            ;           JE - ru®en°

         mov       al,cs:[flagsc]
         and       al,3                     ; maska á°sla operace
         cmp       al,2                     ; je operace ru®en° ?
         ret

; -----------------------------------------------------------------------------
public   test1file

test1file:                                ;* test, zda je operace s 1 souborem
                                            ; VùSTUP: NZ=je operace s kurzorem
         test      byte ptr cs:[flagsc],4
         ret

; -----------------------------------------------------------------------------
public   copyfile1,copyfile,movefile1,movefile,delfile1,delfile

copyfile1:                                ;* kop°rov†n° 1 souboru
         mov       byte ptr ds:[flagsc],4+0 ; operace kop°rov†n° soub. pod kurz.
         jmp       short file1

copyfile:                                 ;* kop°rov†n° souborñ
         mov       byte ptr ds:[flagsc],0   ; operace kop°rov†n° souborñ
         jmp       short file1

movefile1:                                ;* p©esun 1 souboru
         mov       byte ptr ds:[flagsc],4+1 ; operace p©ejmen. soub. pod kurz.
         jmp       short file1

movefile:                                 ;* p©esun souborñ
         mov       byte ptr ds:[flagsc],1 ; operace p©ejmen. souborñ
         jmp       short file1

delfile1:                                 ;* zru®en° 1 souboru
         mov       byte ptr ds:[flagsc],4+2 ; operace ru®en° souboru pod kurz.
         jmp       short file1

delfile:                                  ;* ru®en° souborñ
         mov       byte ptr ds:[flagsc],2   ; operace ru®en° v°ce souborñ
         jmp       short file1

                                          ;* vstupn° test opr†vnànosti poëadavku
file1:   call      testaktw                 ; test zapnut° okna
         jc        file22                   ; okno je vypnutÇ
         call      getkurz                  ; test, zda je kurzor platnò
         jc        file22                   ; nen° ë†dnò soubor
         call      test1file                ; je operace s kurzorem ?
         jnz       file2                    ; je pr†ce s kurzorem
         call      soucins                  ; seáten° oznaáenòch souborñ
         jnz       file3                    ; je oznaáen alespo§ 1 soubor - OK
         or        byte ptr cs:[flagsc],4   ; p©°znak - operace s 1 souborem
file2:   call      getoper                  ; test á°sla operace
         or        al,al                    ; á°slo operace
         jnz       file21                   ; je p©esun,ru®en° nebo atributy
         test      byte ptr ds:[si],10h     ; je adres†© ?
         jnz       file22                   ; je adres†© - chyba
file21:  cmp       word ptr ds:[si+1],".."  ; je adres†© ".." ?
         jne       file3                    ; nen° adres†© ".."
file22:  ret

file3:                                    ;* volby pro dal®° operaci
         push      cs
         pop       ds                       ; DS <- CS
         call      nadpfile                 ; sestaven° nadpisu pro okno voleb
         call      getoper                  ; k¢d operace
         jb        file31                   ; je kop°rov†n°/p©esun

                                          ;* volby pro ru®en°
file32:  call      flushkey                 ; vypr†zdnàn° kl†vesnice
         mov       si,offset txtkon2        ; poloëky voleb "Ano", "Ne"
         xor       al,al                    ; p©edvolba
         call      volbyh                   ; zobrazen° varov†n°
         call      windretx                 ; n†vrat oken
         jc        file33                   ; p©eru®en° operace
         or        al,al                    ; je volba ANO ?
         jz        file62                   ; je potvrzen° ANO
file33:  ret                                ; p©eru®en° operace

file31:                                   ;* volby pro kop°rov†n°/p©esun
         call      precopy                  ; nastaven° p©edvoleb pro COPY,...
         mov       si,offset historie       ; buffer historie
         call      select                   ; volba c°le operace
         call      windretx                 ; n†vrat oken
         jc        file33                   ; je p©eru®en° operace ESC
         call      adrcop                   ; nastaven° c°lovÇ cesty operace
         jc        file33                   ; chyba zad†n° cesty, p©eru®en° operace
                                          ;* nastaven° parametrñ bufferu
         mov       ax,ds:[segend]           ; segment konce pamàti
         sub       ax,ds:[topseg]           ; dÇlka volnÇ pamàti
         dec       ax
         cmp       ax,0fffh                 ; je vàt®° neë maximum ?
         jbe       file34                   ; je men®° neë maximum
         mov       ax,0fffh                 ; omezen° max. velikosti
file34:  shl       ax,1
         shl       ax,1
         shl       ax,1
         shl       ax,1                     ; velikost bufferu v bajtech
         mov       ds:[maxdbuf],ax          ; maxim†ln° velikost bufferu
         or        ax,ax
         jz        file33                   ; chyba - nen° voln† pamàü

file62:                                   ;* proveden° operace se soubory
         call      storekall                ; £schova pozice kurzorñ obou oken
         mov       si,cs:[bp+4]             ; adres†© okna
         call      aktdir                   ; nastaven° aktivn°ho adres†©e okna
         call      testbreak                ; je p©eru®en° operace ?
         jc        file33                   ; je p©eru®en° operace
         call      aktuald                  ; aktualizace adres†©e disku
         jc        file33                   ; p©eru®en° operace
         call      setfirst                 ; nastaven° prvn°ho souboru
         jc        file33                   ; nen° prvn° soubor
         jmp       short file72             ; zpracov†n° prvn°ho souboru
file7:   call      setkurzn                 ; nastaven° na dal®° poloëku
         jc        file71                   ; je jië konec seznamu
file70:  call      setnext                  ; nastaven° dal®°ho souboru
file72:  jc        file71                   ; nen° jië dal®° soubor
         call      storekur                 ; £schova pozice kurzoru
         call      getoper                  ; poskytnut° á°sla operace
         jb        file73                   ; je kop°rov†n° nebo p©esun
                                          ;* zru®en° jednoho souboru
         call      delete1f                 ; zru®en° jednoho souboru
         jc        file71                   ; p©eru®en° operace
         jmp       short file70             ; zru®en° dal®°ho souboru

file73:  or        al,al                    ; je kop°rov†n° ?
         jnz       file74                   ; je p©esun
                                          ;* kop°rov†n° jednoho souboru
         call      copy1f                   ; kop°rov†n° jednoho souboru
         jc        file71                   ; p©eru®en° operace
         jmp       short file7              ; kop°rov†n° dal®°ho souboru

file74:                                   ;* p©esun jednoho souboru
         call      move1f                   ; p©esun jednoho souboru
         jnc       file70                   ; operace OK - dal®° soubor

file71:                                   ;* n†vrat parametrñ oken
         call      windretx
         call      getnakt
         call      rerdir                   ; nastaven° novÇho naáten° adres†©e
         call      getakt
         call      rerdir                   ; nastaven° novÇho naáten° adres†©e
         call      windretx                 ; n†vrat zobrazen° oken
         ret

; -----------------------------------------------------------------------------
public   rerdir

rerdir:                                   ;* nastaven° novÇho naáten° adres†©e
         and       byte ptr cs:[bp+0],not 2 ; zru®en° p©°znaku naáten° adres†©e
         or        byte ptr cs:[bp+0],4     ; p©°znak, ëe se adres†© nenuluje
         ret

; -----------------------------------------------------------------------------
public   nadpfile

nadpfile:                                 ;* sestaven° nadpisu pro okno voleb
                                            ; VùSTUP: DI=buffer s textem nadpisu
                                          ;* sestaven° £vodu nadpisu
         push      si
         mov       di,offset bufnadp        ; buffer pro nadpis
         push      di
                                          ;* £vodn° text nadpisu
         call      getoper                  ; test prov†dànÇ operace
         dec       al                       ; je AL=1 ? (=p©esun)
         mov       si,offset txtcop1        ; test 'Zkop°ruji'
         js        nadpfl2                  ; je kop°rov†n°
         call      test1file                ; je pr†ce s kurzorem ?
         jnz       nadpfl13                 ; je kurzor (volba s ALT)
         push      ax
         call      soucins                  ; seáten° oznaáenòch souborñ
         pop       ax
         jnz       nadpfl11                 ; je oznaáen nàjakò soubor
nadpfl13:push      bx
         call      getatrib0
         test      bl,10h                   ; je adres†© ?
         pop       bx
         mov       si,offset txtmov2        ; text 'P©ejmenuji'
         jnz       nadpfl1                  ; je adres†©
nadpfl11:mov       si,offset txtmov1        ; text 'P©esunu/p©ejmenuji '
nadpfl1: or        al,al
         jz        nadpfl2                  ; je p©esun/p©ejmenov†n°
         mov       si,offset txtvar         ; text "Varov†n°"
         call      transtxt                 ; p©enos textu varov†n°
         mov       si,offset txtdel1        ; text 'Zru®°m'

nadpfl2: call      transtxt                 ; p©enos £vodn° á†sti nadpisu
                                          ;* sestaven° textu souborñ
         call      test1file                ; je pr†ce s kurzorem ?
         jnz       nadpfl4                  ; je kurzor (volba s ALT)
         call      soucins                  ; seáten° oznaáenòch souborñ
         cmp       cx,1                     ; poáet oznaáenòch souborñ
         ja        nadpfl5                  ; je oznaáen v°ce neë 1 soubor
nadpfl4: call      nadpf1                   ; parametr nadpisu pro 1 soubor
         jmp       short nadpfl6
nadpfl5: call      nadpfm                   ; parametr nadpisu pro v°ce souborñ
                                          ;* z†vàr nadpisu
nadpfl6: call      getoper                  ; test prov†dànÇ operace
         mov       si,offset txtcop2        ; text ' na: '
         jb        nadpfl7                  ; je kop°rov†n°, p©esun
         mov       si,offset txtdel3        ; text " !"
nadpfl7: call      transtxt                 ; p©enos textu ' na: ' nebo ' !'
nadpfl8: xor       al,al
         stosb
         pop       di                       ; adresa bufferu
         pop       si
         ret

; -----------------------------------------------------------------------------
public   nadpf1

nadpf1:                                   ;* parametr nadpisu pro 1 soubor
                                            ; VSTUP: DI=ukl†dac° adresa

         push      ax
         push      bx
         push      si
         push      ds
         call      getkurz                  ; poskytnut° adresy kurzoru
         jc        nadpf13                  ; nen° ë†dnò soubor
                                          ;* nalezen° souboru pro operaci
         call      test1file                ; je pr†ce s kurzorem ?
         jnz       nadpf11                  ; pracuje se se souborem pod kurz.
         call      srcins                   ; nalezen° prvn° oznaáenÇ poloëky
         jc        nadpf11                  ; nenalezena ë†dn† poloëka
         call      adrpolsi                 ; poskytnut° adresy poloëky
                                          ;* oznaáen° "soubor" nebo "adres†©"
nadpf11: push      si                       ; adresa poloëky
         push      ds
         test      byte ptr ds:[si],10h     ; je adres†© ?
         mov       si,offset textvy2+2      ; text 'soubor'
         jz        nadpf12                  ; nen° adres†©
         mov       si,offset txtadr         ; text ' adres†©'
nadpf12: push      cs
         pop       ds                       ; DS <- CS
         call      transtxt                 ; p©enos textu 'soubor'
         mov       ax,10*256+" "            ; oddàlovac° mezera, zvòraznànò text
         stosw                              ; uloëen° oddàlovac° mezery
         pop       ds
         pop       si                       ; adresa poloëky
                                          ;* jmÇno souboru, adres†©e
         call      dekfile                  ; dek¢dovn†n° jmÇna souboru, adres.
         mov       al,7                     ; atribut norm†ln°ho okna
         stosb                              ; norm†ln° okno
nadpf13: pop       ds
         pop       si
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   nadpfm

nadpfm:                                   ;* parametr nadpisu pro v°ce souborñ
                                            ; VSTUP: DI=ukl†dac° adresa
                                            ;        CX=poáet souborñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si                       ; £schova adresy poloëky
         mov       al,10                    ; atribut zvòraznànÇho textu
         stosb                              ; uloëen° atributu
         mov       ax,cx                    ; poáet oznaáenòch souborñ
         xor       dx,dx                    ; vy®®° slovo á°sla pro dek¢dov†n°
         push      di                       ; £schova adresy á°sla
         call      deknum5                  ; dek¢dov†n° poátu souborñ
         mov       al,7                     ; atribut norm†ln°ho okna
         stosb                              ; nastaven° norm†ln°ho textu
         mov       si,offset txtcop3        ; text ' oznaáen'
         call      transtxt                 ; p©enos textu ' oznaáen'
         pop       si                       ; adresa á°sla
         push      si                       ; adresa á°sla
         call      testkonc                 ; test koncovky á°sla
         mov       si,offset textsp20       ; koncovka "ò"
         or        al,al
         jz        nadpfm1                  ; je á°slo "1"
         mov       si,offset textsp21       ; koncovka "Ç"
         dec       al                       ; je á°slo 2,3,4 ?
         jz        nadpfm1                  ; je koncovka "Ç"
         mov       si,offset textsp22       ; koncovka "òch"
nadpfm1: call      transtxt                 ; uloëen° koncovky
         mov       si,offset textvy2 + 1    ; text 'soubor'
         call      transtxt                 ; p©enos textu 'soubor'
         pop       si                       ; adresa textu á°sla
         call      setkonc                  ; nastaven° koncovky
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   testex

testex:                                   ;* test, zda soubor existuje
                                            ; VùSTUP: CY=p©eru®en° operace
                                            ;         NZ=p©eskoáen° souboru

         push      ax
         push      si
         push      ds
         push      es
         push      cs
         pop       es
                                          ;* test, zda existuje c°lovò soubor
         mov       dx,offset selbuf         ; cesta k c°lovÇmu souboru
         mov       ah,4eh                   ; funkce nalezen° souboru
         mov       cx,37h                   ; v®echny atributy
         int       21h                      ; pokus o nalezen° souboru
         jnc       testex1                  ; soubor existuje
         xor       al,al                    ; p©°znak, ëe se operace prov†d°
         jmp       short testex4            ; soubor nenalezen - OK
testex1:                                  ;* test, zda se m† soubor ru®it
         test      byte ptr cs:[flagsc],10h ; prov†d° se dotaz ?
         jnz       testex3                  ; dotaz se neprov†d°
                                          ;* sestaven° textu dotazu
         push      cs
         pop       ds                       ; DS <- CS
         mov       di,offset outbuf+40
         mov       si,offset txtvar         ; text varov†n°
         call      transtxt                 ; uloëen° nadpisu
         mov       si,offset errdel1        ; text "Soubor"
         call      transtxt                 ; p©enos oznaáen°
         mov       si,offset selbuf         ; plnÇ oznaáen° souboru
         call      transtxt
         mov       si,offset errcop4        ; text "jië existuje..."
         call      transtxt
         mov       si,offset copyvolb       ; volby
         mov       di,offset outbuf+40      ; buffer s textem
         xor       al,al
         call      volbyh                   ; proveden° voleb
         call      windret                  ; navr†cen° oken
         jc        testex4                  ; p©eru®en° operace
         mov       cl,4                     ; poáet rotac°
         shl       al,cl                    ; á°slo dal®° funkce
         and       byte ptr cs:[flagsc],0cfh; zru®en° staròch p©°znakñ
         or        cs:[flagsc],al           ; nastaven° novòch p©°znakñ
testex3: test      byte ptr cs:[flagsc],20h ; ru®° se poloëka ?
         jz        testex5                  ; poloëka se ru®°
         jmp       short testex4            ; p©eskoáen° poloëky
                                          ;* zru®en° ochrany z†pisu poloëky
testex5: mov       dx,offset selbuf         ; c°lovò soubor
ifndef   demo
         xor       cx,cx
         mov       ax,4301h                 ; funkce nastaven° atributñ
         int       21h                      ; zru®en° atributu SYS, HID, R/O
endif
         xor       al,al                    ; p©°znak, ëe se v operaci pokraáuje
testex4: pop       es
         pop       ds
         pop       si
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   nulsel

nulsel:                                   ;* nulov†n° atributu vòbàru kurzoru

         pushf
         push      si
         push      ds
         call      getkurz                  ; poskytnut° adresy kurzoru
         and       byte ptr ds:[si],7fh     ; zru®en° p©°znaku vòbàru souboru
         call      endline
         pop       ds
         pop       si
         popf
         ret

; -----------------------------------------------------------------------------
public   testbreak

testbreak:                                ;* test p©eru®en° operace
                                            ; VùSTUP: CY=je p©eru®en° operace
         push      ax
         cmp       word ptr cs:[parbreak],0 ; je nàjak† chyba ?
         jne       testbrk2                 ; je chyba nebo p©eru®en° operace
         call      testkey
         clc
         jz        testbrk1                 ; nen° p©ipraven znak
         cmp       al,27                    ; je Esc ?
         clc
         jne       testbrk1                 ; nen° Esc
         mov       word ptr cs:[parbreak],-1 ; p©°znak p©eru®en°
testbrk2:;mov       word ptr cs:[parbreak],0 ; zru®en° p©°znaku p©eru®en°
         call      flushkey                 ; vypr†zdnàn° kl†vesnice
         stc                                ; p©°znak p©eru®en° CY
testbrk1:pop       ax
         ret

; -----------------------------------------------------------------------------
public   move1f

move1f:                                   ;* p©esun/p©ejmenov†n° jednoho souboru
                                            ; VùSTUP: CY=chyba kop°rov†n°

         call      cmpcdisk                 ; p©esouv† se na stejnÇm disku ?
         mov       si,offset txtmov5        ; text "P©esouv†m"
         je        move1f0                  ; p©esun mezi adres†©i
         jmp       move1f5                  ; p©esun souboru mezi disky
                                          ;* p©esun souboru mezi adres†©i
move1f0: call      cmpcpath                 ; je p©esun v adres†©i ?
         mov       di,offset txtcop6        ; text "do"
         jne       move1f1                  ; je p©esun mezi adres†©i
move1f03:mov       si,offset txtmov6        ; text "P©ejmenov†v†m"
         mov       di,offset txtmov7        ; text "na"
move1f1: call      informz                  ; zobrazen° z†kladn°ho inform. ©†dku
         mov       si,di                    ; text "do" nebo "na"
         call      outtxt
         call      setpcil                  ; sestaven° c°lovÇ cesty souboru
         push      di                       ; pñvodn° konec cesty
         call      dispcil                  ; zobrazen° c°le operace
         jnc       move1f9                  ; nen° stejnò soubor
                                          ;* p©ejmenov†n° souboru s†m na sebe
         call      nulsel                   ; zru®en° oznaáen° poloëky
         push      cs
         pop       ds
         clc                                ; operace OK
         jmp       short move1f2

move1f9:                                  ;* test zda soubor existuje - ru®en°
         call      testex                   ; pokud existuje, ru®en°
         jc        move1f7                  ; p©eru®en° operace
         jnz       move1f2                  ; operace se neprov†d°
                                          ;* p©esun/p©ejmenov†n° souboru
         call      msgcek                   ; hl†®en° "áekejte"
         call      testbreak                ; je p©eru®en° operace ?
         jc        move1f6                  ; je p©eru®en° operace
         mov       dx,offset selbuf         ; jmÇno c°lovÇho souboru
         mov       ah,41h                   ; funkce ru®en° souboru
         int       21h                      ; zru®en° c°lovÇho souboru

         mov       dx,offset outbuf         ; jmÇno pñvodn°ho souboru
         mov       di,offset selbuf         ; novÇ jmÇno souboru
         mov       ah,56h                   ; funkce p©ejmenov†n° souboru
         int       21h                      ; p©ejmenov†n° souboru
         jc        move1f6                  ; chyba operace
                                          ;* zmàna poloëek v adres†©°ch
         pop       di                       ; pñvodn° adresa konce SELBUF
         push      di
         xor       al,al
         stosb
                                          ;* aktualizace aktivn°ho adres†©e
         mov       bx,cs:[bp+11]
         call      delpol                   ; zru®en° pñvodn° poloëky
         call      inspol                   ; vloëen° poloëky do adres†©e
         call      modikap                  ; modifikace kapacity disku
                                          ;* aktualizace neaktivniho adresare
         push      bp
         mov       bp,cs:[bp+adrtabl-tabl]  ; adresa druhÇho okna
         call      cmpcpath                 ; jsou stejnÇ adres†©e ?
         je        move1fd                  ; jsou stejnÇ adres†©e
         call      cmpcdisk                 ; jsou stejnÇ disky ?
         jnz       move1f4                  ; nejsou stejnÇ adres†©e
         jmp       short move1fe            ; jsou stejnÇ disky
move1fd: call      cmppath                  ; jsou stejne adresare ?
         jne       move1ff
         mov       bx,cs:[bp+11]
         call      delpol                   ; zru®en° poloëky z adres†©e
move1ff:
         call      inspol                   ; vloëen° poloëky do adres†©e
move1fe: call      modikap                  ; modifikace kapacity o soubor
move1f4: pop       bp
         clc
         jmp       short move1f7

move1f6:
         call      topret                   ; n†vrat horn°ho ©†dku

move1f2: pushf
         call      setkurzn                 ; zvò®en° pozice kurzoru
         popf
move1f7: pop       di                       ; pñvodn° adresa konce SELBUF
         pushf
         xor       al,al
         stosb
         call      topret                   ; n†vrat horn°ho ©†dku
         popf
         ret

move1f5:                                  ;* p©esun mezi disky
         call      copy1f0                  ; p©ekop°rov†n° souboru
         jc        move1f8                  ; chyba operace
         jz        move1fa                  ; operace probàhla OK
         call      setkurzn                 ; zvò®en° pozice kurzoru
         clc
         ret
move1fa:
         call      deletef0
move1f8: ret

; -----------------------------------------------------------------------------
public   copy1f

copy1f:                                   ;* kop°rov†n° jednoho souboru
                                            ; VùSTUP: CY=chyba kop°rov†n°
                                            ;         NZ=operace neprobàhla

         mov       si,offset txtcop5        ; text " Kop°ruji"
copy1f0: call      informz                  ; zobrazen° z†kladn°ho inform. ©†dku
         mov       si,offset txtcop6        ; text "do"
         call      outtxt
         call      cmpcpath                 ; je kop°rov†n° v adres†©i ?
         call      setpcil                  ; sestaven° c°lovÇ cesty souboru
         push      di                       ; pñvodn° konec cesty
         call      dispcil                  ; zobrazen° c°le operace
         jnc       copy1f3                  ; nen° chyba
                                          ;* kop°ruje se soubor s†m do sebe
         call      nulsel                   ; zru®en° oznaáen° poloëky
         push      cs
         pop       ds
         pop       di                       ; pñvodn° adresa konce SELBUF
         xor       al,al
         stosb
         xor       al,al                    ; operace OK
         jmp       short copy1f2

copy1f3:                                  ;* test zda soubor existuje - ru®en°
         call      testex                   ; pokud existuje, ru®en°
         jc        copy1f7                  ; p©eru®en° operace
         jnz       copy1f7                  ; operace se neprov†d°

         call      msgcek                   ; hl†®en° "áekejte"
         call      copyfk                   ; kop°rov†n° 1 souboru
         pop       di                       ; pñvodn° adresa konce SELBUF
         pushf
         xor       al,al
         stosb
         popf
         jc        copy1f4                  ; chyba operace

ifndef   demo
         call      inspol                   ; vloëen° poloëky do adres†©e
endif
         call      cmpcdisk                 ; je c°lovò disk ?
         jne       copy1f6                  ; nen° c°lovò disk
         call      modikap                  ; modifikace kapacity disku
copy1f6: push      bp
         mov       bp,cs:[bp+adrtabl-tabl]  ; adresa druhÇho okna
ifndef   demo
         call      inspol                   ; vloëen° poloëky do adres†©e
endif
         call      cmpcdisk                 ; je c°lovò disk ?
         jne       copy1f5                  ; nen° c°lovò disk
         call      modikap                  ; modifikace kapacity o soubor
copy1f5: pop       bp
         xor       al,al                    ; operace OK
         jmp       short copy1f2

copy1f4:
         stc                                ; p©°znak chyby
copy1f2: call      topret                   ; n†vrat horn°ho ©†dku
         ret

copy1f7: pop       di                       ; pñvodn° adresa konce SELBUF
         pushf
         xor       al,al
         stosb
         popf
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
                                          ;* test, zda je operace v adres†©i
         inc       di
         mov       cl,ds:[di-1]             ; £schova znaku oddàlovaáe
         mov       byte ptr ds:[di-1],0
         call      cmpcpath                 ; je operace v adres†©i ?
         mov       ds:[di-1],cl             ; n†vrat znaku
         mov       si,di                    ; zaá†tek jmÇna souboru
         je        dispcil3                 ; je operace v adres†©i

         mov       si,offset selbuf         ; cesta k c°lovÇmu adres†©i
         sub       ah,4                     ; je p©ekroáen poáet oddàlovaáñ ?
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
dispcil3:call      outtxt                   ; zobrazen° zbytku textu
         popf
         pop       di
         pop       si
         pop       cx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   setpcil

setpcil:                                  ;* sestaven° c°lovÇ cesty k souboru
                                            ; VùSTUP: DI=pñvodn° konec SELBUF
                                            ;         CY=zdroj shodnò s c°lem
                                            ;         AH=poáet oddàlovaáñ "\"

         mov       di,offset selbuf         ; c°lovò adres†©
         call      lendi                    ; dÇlka cesty v SELBUF
         xor       ah,ah
         add       di,ax                    ; konec textu
         push      di                       ; £schova pñvodn°ho konce cesty
         call      setcil                   ; sestaven° jmÇna
         pushf
         cmp       byte ptr ds:[di-1],"\"   ; je jië oddàlovaá konce cesty ?
         je        setpcil2                 ; je jië oddàlovaá
         mov       al,"\"
         stosb                              ; uloëen° oddàlovaáe
setpcil2:mov       si,offset outbuf+20      ; p©ek¢dovanÇ jmÇno souboru
         call      dekfile                  ; dek¢dov†n° jmÇna souboru
         mov       si,offset selbuf         ; buffer s cestou
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

; -----------------------------------------------------------------------------
public   delete1f

delete1f:                                 ;* zru®en° souboru s kurzorem
                                            ; VùSTUP: CY=p©eru®en° operace

         mov       si,offset txtdel2        ; text "Ru®°m "
         call      informz                  ; zobrazen° z†kladn°ho inform. ©†dku
deletef0:                                 ;* zru®en° souboru BX
         call      msgcek                   ; hl†®en° "áekejte"
                                          ;* rozk¢dov†n° jmÇna souboru
         push      ds
         call      getkurz                  ; poskytnut° adresy poloëky
         mov       di,offset outbuf         ; buffer k uloëen° jmÇna souboru
         push      di
         call      dekfile                  ; dek¢dov†n° jmÇna poloëky
         pop       dx                       ; adresa textu - jmÇno souboru
         pop       ds
                                          ;* zru®en° poloëky DS:SI
         call      delfk                    ; zru®en° souboru oznaáenÇho kurz.
         jc        deletef1                 ; p©eru®en° operace
         test      byte ptr ds:[95h],1      ; m† poloëka ochranu proti z†pisu ?
         jz        deletef2                 ; poloëka nem† ochranu proti z†pisu
         test      byte ptr ds:[flagsc],80h ; ru®ila se poloëka ?
         jz        deletef2                 ; poloëka se ru®ila
         call      setkurzn                 ; posun o jednu poloëku
         jmp       short deletef1
deletef2:                                 ;* aktualizace seznamu adres†©e
ifdef    demo
         call      nulsel                   ; zru®en° oznaáen° poloëky
endif
         mov       bx,ds:[bp+11]            ; á°slo poloëky s kurzorem
ifndef   demo
         call      delpol                   ; zru®en° poloëky BX z adres†©e
endif
         call      modikap                  ; modifikace kapacity disku
         call      cmpdisk                  ; jsou stejnÇ disky ?
         jne       deletef5                 ; disky nejsou shodnÇ
         push      bp
         call      getnakt                  ; adresa neaktivn°ho okna
deletef3:call      cmppath                  ; jsou stejnÇ adres†©e ?
         jne       deletef6                 ; nejsou stejnÇ adres†©e
ifndef   demo
         call      delpol                   ; zru®en° poloëky z adres†©e
endif
deletef6:call      modikap                  ; modifikace kapacity o soubor
         pop       bp
deletef5:clc
deletef1:call      topret
         ret

; -----------------------------------------------------------------------------
public   delfk

delfk:                                    ;* ru®en° souboru
                                            ; VSTUP: DS:DX=jmÇno souboru
                                            ; VùSTUP: CY=chyba operace


         mov       si,offset erroper
         mov       ah,4eh
         mov       cx,16h                   ; atribut - v®echny soubory
         int       21h                      ; nalezen° poëadovanÇho souboru
         jc        delfk3                   ; soubor nenalezen
         call      testbreak
         jc        delfk5                   ; p©eru®en° operace
                                          ;* test atributñ R/O
         test      byte ptr ds:[95h],1      ; m† poloëku ochranu proti z†pisu ?
         jz        delfk1                   ; poloëka nem† ochranu proti z†pisu
         call      testro                   ; test atributñ R/O
         jc        delfk5                   ; je p©eru®en° operace
         test      byte ptr ds:[flagsc],80h ; ru®° se poloëka ?
         jnz       delfk5                   ; poloëka se neru®°
                                          ;* zru®en° atributu R/O
ifndef   demo
         mov       ax,4300h                 ; funkce poskytnut° atributñ
         int       21h                      ; poskytnut° atributñ
         jc        delfk3                   ; chyba operace
         mov       ax,4301h                 ; funkce nastaven° atributñ
         and       cx,not 1                 ; zru®en° atributu R/O
         int       21h                      ; zru®en° atributu R/O
         jc        delfk3                   ; chyba operace
endif
         call      testbreak                ; je p©eru®en° operace ?
         jc        delfk5                   ; je p©eru®en° operace
delfk1:  test      byte ptr ds:[95h],10h    ; atributy souboru - je adres†© ?
         jnz       delfk2                   ; je adres†©
                                          ;* zru®en° souboru
         mov       ah,41h                   ; funkce zru®en° souboru
         int       21h                      ; zru®en° souboru
         jnc       delfk5                   ; soubor zru®en OK
         jmp       short delfk3             ; chyba operace
delfk2:                                   ;* zru®en° adres†©e
         mov       ah,3ah                   ; funkce zru®en° adres†©e
         int       21h                      ; zru®en° adres†©e
         jnc       delfk5                   ; adres†© zru®en OK
         mov       si,offset errdir3        ; chyba - adres†© mus° bòt pr†zdnò
delfk3:                                   ;* chyba - operaci nelze provÇst
         call      testbreak                ; test p©eru®en° operace
         jc        delfk5                   ; je p©eru®en° operace
         call      zobrchyb                 ; hl†®en° chyby
delfk5:  ret


testro:                                   ;* test ru®en° souboru R/O

                                          ;* test, zda je automatickò reëim
         test      byte ptr ds:[flagsc],40h ; prov†d° se dotaz ?
         jnz       testro3                  ; dotaz se neprov†d°
                                          ;* sestaven° textu dotazu
         mov       di,offset bufnadp        ; pracovn° buffer
         mov       si,offset txtvar         ; text varov†n°
         call      transtxt                 ; uloëen° nadpisu
         mov       si,offset errdel1        ; text "Soubor"
         test      byte ptr ds:[95h],10h    ; je to adres†© ?
         jz        testro2                  ; nen° to adres†©
         mov       si,offset errdir1        ; test "Adres†©"
testro2: call      transtxt                 ; p©enos oznaáen°
         mov       si,dx                    ; jmÇno souboru
         call      transtxt                 ; p©enos jmÇna souboru
         mov       si,offset errdir2        ; text "nelze zru®it, "
         call      transtxt
         mov       si,offset errdel2        ; text "protoëe je chr†nàn..."
         call      transtxt
                                          ;* provede se dotaz na dal®° postup
         mov       si,offset delvolb        ; volby
         mov       di,offset bufnadp        ; buffer s textem
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
         push      ax
         push      si
         push      di
                                          ;* £vodn° á†st textu
         call      informc                  ; vymaz†n° informaán°ho ©†dku
         call      outtxt                   ; zobrazen° £vodn°ho textu
         inc       dl                       ; zvò®en° pozice za textem
                                          ;* zobrazen° textu "soubor","adres†©"
         call      getkurz                  ; adresa poloëky s kurzorem
         push      si
         push      ds
         test      byte ptr ds:[si],10h     ; je adres†© ?
         mov       si,offset textvy2+2      ; text "soubor"
         jz        informz2                 ; nen° adres†©
         mov       si,offset txtadr         ; text "adres†©"
informz2:push      cs
         pop       ds                       ; DS <- CS
         call      outtxt                   ; zobrazen° textu
         inc       dl                       ; zvò®en° pozice
         pop       ds
         pop       si
                                          ;* zobrazen° jmÇna souboru
         mov       al,10                    ; barva textu 10
         call      outch1                   ; nastaven° barvy 10
         mov       di,offset outbuf         ; tiskovò buffer
         push      di
         call      dekfile                  ; dek¢dov†n° jmÇna poloëky
         pop       si                       ; adresa textu
         push      cs
         pop       ds                       ; DS <- CS
         call      outtxt                   ; zobrazen° jmÇna souboru
         call      kurzout                  ; vypnut° kurzoru
         pop       di
         pop       si
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
         mov       si,offset outbuf+20      ; vkl†dan† poloëka
         call      storekur                 ; £schova pozice kurzoru
         call      storfile                 ; vloëen° novÇ poloëky
         call      settabf                  ; n†vrat pozice kurzoru
         call      window                   ; novÇ zobrazen° okna
inspol1: pop       si
         ret

; -----------------------------------------------------------------------------
public   delpol

delpol:                                   ;* zru®en° poloëky BX

         call      delpolf                  ; zru®en° poloëky ze seznamu
         call      windret
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
public   copyfk

copyfk:                                   ;* zkop°rov†n° souboru
                                            ; VSTUP: [outbuf]=jmÇno souboru
                                            ;        [selbuf]=c°lovò soubor
                                            ; VùSTUP: CY=chyba operace

                                          ;* otev©en° zdrojovÇho souboru
         mov       dx,offset outbuf         ; zdrojovò soubor
         mov       ax,3d00h                 ; otev©en° pro áten°
         int       21h                      ; otev©en° zdrojovÇho souboru
         jc        copyfk8                  ; chyba otev©en° souboru
         call      testbreak                ; je p©eru®en° operace ?
         jc        copyfk9                  ; je p©eru®en° operace
         mov       ds:[inpid],ax            ; identifik†tor vstupn°ho souboru
                                          ;* vytvo©en° c°lovÇho souboru
         mov       dx,offset selbuf         ; c°lovò soubor
         xor       cx,cx                    ; norm†ln° atributy
         mov       ah,3ch                   ; funkce vytvo©en° souboru
         int       21h                      ; vytvo©en° c°lovÇho souboru

         mov       ds:[outid],ax            ; identifik†tor vòstupn°ho souboru
         jc        copyfk1                  ; chyba operace
         call      testbreak                ; je p©eru®en° operace ?
         jnc       copyfk2                  ; operace OK
;         call      copyclose                ; uzav©en° souborñ
         jmp       short copyfk6            ; p©eru®en° operace
copyfk1: call      copycl1                  ; uzav©en° vstupn°ho souboru
         jmp       short copyfk8            ; chyba operace

copyfk2:                                  ;* kop°rov†n° souboru
         call      readblok                 ; áten° bloku dat
         jc        copyfk6                  ; chyba operace - p©eru®en°
         jz        copyfk4                  ; konec operace
         call      writeblok                ; z†pis á†sti bloku dat
         jc        copyfk6                  ; chyba operace - p©eru®en°
         je        copyfk2                  ; jsou zaps†na v®echna data
                                          ;* chyba - nedostatek m°sta
         stc                                ; p©°znak chyby operace
         call      copyclose                ; uzav©en° souborñ
         mov       di,offset bufnadp        ; buffer textu nadpisu
         mov       si,offset errcop5        ; text "Na disku"
         push      di                       ; adresa textu
         call      transtxt
         mov       al,ds:[selbuf]           ; disk c°lovÇ operace
         stosb
         mov       si,offset errcop51       ; text "nen° dost volnÇho m°sta !"
         call      transtxt
         pop       si                       ; text chybovÇho hl†®en°
         jmp       short copyfka            ; chybovò n†vrat

copyfk4:                                  ;* nastaven° data a áasu
;         stc
;         call      modiukaz                 ; plnÇ zobrazen° ukazatele kop°rov.
         mov       bx,ds:[outid]            ; vòstupn° soubor
         mov       dx,word ptr ds:[outbuf+20+16] ; datum
         mov       cx,word ptr ds:[outbuf+20+18] ; áas
ifndef   demo
         mov       ax,5701h                 ; funkce nastaven° data a áasu
         int       21h                      ; nastaven° data a áasu souboru
endif
;         jc        copyfk6                  ; chyba operace
;         call      nulsel                   ; zru®en° oznaáen° poloëky
copyfk6:                                  ;* uzav©en° c°lovÇho souboru
         call      copyclose                ; uzav©en° souborñ
         jnc       copyfk9                  ; operace OK
copyfk8: call      testbreak                ; je p©eru®en° operace ?
         jc        copyfk9                  ; bylo p©eru®en° operace
         mov       si,offset erroper        ; text "Operaci nelze provÇst !"
copyfka: call      zobrchyb                 ; zobrazen° chybovÇho hl†®en°
copyfk9: ret



public   copyclose,copycl1

copyclose:                                ;* uzav©en° souborñ
                                            ; VSTUP: CY=chyba operace

         pushf
ifndef   demo
         mov       bx,ds:[outid]            ; identifik†tor vòstupn°ho souboru
         mov       ah,3eh                   ; funkce uzav©en° identifik†toru
         int       21h                      ; uzav©en° vòstupn°ho souboru
endif
         popf
         mov       dx,offset selbuf         ; c°lovò soubor
         jc        copycl0                  ; je chyba operace - zru®en° souboru
                                          ;* nastaven° atributñ souboru
         pushf
ifndef   demo
         mov       cl,[outbuf+20]           ; atributy pñvodn°ho souboru
         and       cx,27h                   ; ponech†n° norm†ln°ch atributñ
         mov       ax,4301h
         int       21h                      ; nastaven° atributñ souboru
endif
         popf
         jmp       short copycl1
copycl0:                                  ;* zru®en° vòstupn°ho souboru
ifndef   demo
         mov       ah,41h                   ; funkce ru®en° souboru
         int       21h                      ; zru®en° souboru

         mov       word ptr cs:[parbreak],-2 ; ignorov†n° chyb
         push      bp
         call      getakt
         call      errclose
         call      getnakt
         call      errclose
         call      windretx                 ; n†vrat zobrazen° oken
         pop       bp

endif
         stc                                ; p©°znak chyby operace
copycl1:                                  ;* uzav©en° zdrojovÇho souboru
         pushf
         mov       bx,ds:[inpid]            ; identifik†tor vstupn°ho souboru
         mov       ah,3eh                   ; funkce uzav©en° identifik†ttoru
         int       21h                      ; uzav©en° vstupn°ho souboru
         popf
         jc        copycl5
         call      nulsel                   ; zru®en° znaáen° poloëky
copycl5: ret

public   errclose
errclose:                                 ;* uzav©en° p©i chybà

         call      cmpcdisk                 ; je c°lovò disk ?
         jne       errcl1                   ; nen° c°lovò disk
         call      rerdir                   ; p©°znak novÇho naáten° adres†©e
;         and       byte ptr cs:[bp+0],not 2 ; zru®en° p©°znaku naáten° adres†©e
;         or        byte ptr cs:[bp+0],4     ; adres†© se nenuluje
errcl1:  ret



public   readblok
readblok:                                 ;* áten° bloku dat z disku
                                            ; VùSTUP: CY=chyba operace, p©eru®en°
                                            ;         ZY=nejsou jië dal®° data
                                            ;         AX=dÇlka naátenÇho bloku

         mov       ah,3fh                   ; funkce áten° ze souboru
         mov       bx,ds:[inpid]            ; vstupn° soubor
         mov       cx,ds:[maxdbuf]          ; velikost diskovÇho bufferu
         push      ds
         mov       ds,ds:[topseg]           ; segment volnÇ pamàti
         xor       dx,dx                    ; offset v bufferu
         int       21h                      ; naáten° bloku dat
         pop       ds
         jc        readblk1                 ; chyba operace, p©eru®en°
         call      testbreak                ; je p©eru®en° operace ?
         jc        readblk1                 ; je p©eru®en° operace
         mov       cs:[numbuf],ax           ; poáet bajtñ v bufferu k z†pisu
         or        ax,ax                    ; poáet naátenòch dat
readblk1:ret


public   writeblok
writeblok:                                ;* z†pis bloku dat na disk
                                            ; VùSTUP: CY=chyba operace, p©eru®en°
                                            ;         NZ=nedostatek m°sta na disku

         xor       dx,dx                    ; ukl†dac° adresa (offset)
writebl1:                                 ;* omezen° velikosti bloku shora
;         mov       cx,word ptr ds:[blokuk]  ; nië®° slovo velikosti bloku
;         cmp       word ptr ds:[blokuk+2],0 ; je blok vàt®° neë 0ffffh ?
;         jne       writebl2                 ; blok je vàt®° neë 0ffffh
;         cmp       cx,8000h                 ; je blok vàt®° neë 32 KB ?
;         jb        writebl3                 ; blok je men®° neë 32 KB
;writebl2:mov       cx,8000h                 ; maxim†ln° blok 32 KB
;writebl3:                                 ;* omezen° velikosti bloku zdola
;         cmp       cx,2000h                 ; nejmen®° blok 8 KB
;         ja        writebl4                 ; blok nen° men®° neë 8 KB
;         mov       cx,2000h                 ; omezen° zdola na 8 KB
;writebl4:                                 ;* omezen° skuteánòmi daty
;         cmp       cx,ds:[numbuf]           ; je v bufferu men®° blok dat ?
;         jb        writebl5                 ; blok dat je men®° neë data v bufferu
         mov       cx,ds:[numbuf]           ; poáet bajtñ k z†pisu
writebl5:                                 ;* z†pis á†sti bloku dat
         mov       bx,ds:[outid]            ; vòstupn° soubor
         push      ds
ifndef   demo
         mov       ds,[topseg]              ; segment volnÇ pamàti
         mov       ah,40h                   ; funkce z†pisu do souboru
         int       21h                      ; z†pis dat
else
         call      prodldem                 ; prodleva pro demo
         mov       ax,cx                    ; poáet zapsanòch bajtñ
         clc
endif
         pop       ds
         jc        writebl7                 ; chyba operace - p©eru®en°
         call      testbreak                ; test p©eru®en° operace
         jc        writebl7                 ; je p©eru®en° operace
         cmp       ax,cx                    ; souhlas° poáet zapsanòch dat ?
         clc
;         jne       writebl7                 ; chyba - nedostatek m°sta na disku
;         add       dx,ax                    ; zvò®en° adresy v bufferu
;         call      modiukaz                 ; zobrazen° ukazatele kop°rov†n°
         mov       word ptr ds:[numbuf],0   ; zru®en° dat v bufferu
;         sub       ds:[numbuf],ax           ; sn°ëen° poátu dat v bufferu
;         ja        writebl1                 ; z†pis dal®°ho bloku dat
writebl7:
         ret

; -----------------------------------------------------------------------------
public   adrcop

adrcop:                                   ;* sestaven° c°lovÇho adres†©e kop°r.
                                            ; VùSTUP: CY=chybnÇ zad†n° cesty
                                            ;         [selbuf] - c°lov† cesta

         push      cs
         pop       ds
                                          ;* nastaven° zadanÇho adres†©e
         mov       si,ds:[bp+4]             ; adres†© okna
         call      aktdir                   ; nastaven° aktivn°ho adres†©e okna
         call      testbreak                ; je p©eru®en° operace ?
         jc        adrcop33                 ; p©eru®en° operace

         mov       si,offset outbuf         ; zadanò adres†©
         call      aktdir                   ; nastaven° c°lovÇho adres†©e
         jnc       adrcop1                  ; adres†© existuje
         call      testbreak                ; je p©eru®en° operace ?
         jc        adrcop33                 ; p©eru®en° operace
                                          ;* chyba zad†n° adres†©e
         mov       si,offset errcop1        ; text "ChybnÇ zad†n° ..."
         jmp       zobrchyb                 ; zobrazen° chybovÇho hl†®en°

adrcop1:                                  ;* pokus o p©epnut° na podadres†©
         mov       di,offset outbuf         ; uloëen° podadres†©e
         mov       si,offset rozbflg        ; moënÇ jmÇno podadres†©e
         push      di
         call      dekfile                  ; dek¢dov†n° jmÇna podadres†©e
         pop       si                       ; p©°padnò podadres†©
         call      aktdir                   ; nastaven° podadres†©e
         jc        adrcop2                  ; nen° to podadres†©
                                          ;* je to podadres†© - zru®° se jmÇno
         mov       di,offset rozbnam        ; jmÇno souboru
         mov       cx,11
         mov       al,"?"                   ; n†hradn° znak
         rep       stosb                    ; vynulov†n° jmÇna
adrcop2: call      testbreak                ; je p©eru®en° operace ?
         jc        adrcop33                 ; p©eru®en° operace
         mov       di,offset selbuf         ; buffer k uloëen° adres†©e
         call      loadpath                 ; naáten° c°lovÇho adres†©e
         call      testbreak                ; je p©eru®en° operace ?
         jc        adrcop33                 ; p©eru®en° operace
                                          ;* aktualizace druhÇho okna
         push      bp
         call      getnakt                  ; neaktivn° okno
         call      cmpcpath                 ; je druhÇ okno c°lovÇ ?
         clc
         jne       adrcop4                  ; nen° c°lovÇ
         call      aktuald                  ; aktualizace adres†©e disku
adrcop4: pop       bp
         jc        adrcop33                 ; p©eru®en° operace
                                          ;* test, zda se kop°ruje v°ce do jedn.
         call      test1file                ; je operace s jedn°m souborem ?
         jnz       adrcop3                  ; je operace s jedn°m souborem
         call      soucins                  ; poáet oznaáenòch souborñ
         cmp       cx,1
         jbe       adrcop3                  ; nen° v°ce souborñ neë 1
         mov       di,offset rozbnam        ; rozbor zadanÇho jmÇna
         mov       cx,11                    ; poáet znakñ jmÇna
         mov       al,"?"                   ; n†hradn° znak
         repne     scasb                    ; nalezen°, zda je znak "?"
         jne       errcopy2                 ; chyba - v°ce souborñ do jednoho
adrcop3: clc
adrcop33:ret

errcopy2:                                 ;* chyba - v°ce souborñ do jednoho

         mov       di,offset selbuf
         push      di
         mov       si,offset errcop2        ; text "Nelze"
         call      transtxt
         call      getoper                  ; poskytnut° operace
         or        al,al                    ; je kop°rov†n° ?
         mov       si,offset errcop21       ; text chyby "kop°rovat"
         jz        errcopy3                 ; je kop°rov†n°
         mov       si,offset errcop22       ; text chyby "p©esouvat"
errcopy3:call      transtxt
         mov       si,offset errcop25       ; text "v°ce souborñ do jednoho !"
         call      transtxt
         pop       si                       ; vòslednò text chyby
         jmp       zobrchyb                 ; zobrazen° chybovÇho hl†®en°

; -----------------------------------------------------------------------------
public   aktuald

aktuald:                                  ;* aktualizace disku (novÇ naáten°)
                                            ; VSTUP: BP=ukazatel okna
                                            ; VùSTUP: CY=p©eru®en° operace

         call      rerdir                   ; p©°znak novÇho naáten° adres†©e
         call      windretx                 ; naáten° adres†©e
         call      testbreak                ; je p©eru®en° operace ?
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
         mov       di,offset outbuf+20      ; adresa k uloëen° rozboru
         push      di                       ; adresa pñvodn°ho jmÇna souboru
         mov       cx,19                    ; dÇlka identifikace souboru
         lodsb                              ; atributy souboru
         and       al,37h                   ; nulov†n° atributñ
         stosb
         rep       movsb                    ; p©enesen° vzorovÇho jmÇna
         push      cs
         pop       ds                       ; DS <- CS
         mov       si,offset rozbnam        ; maska pro nastaven° jmÇna souboru
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
         mov       di,offset outbuf+21      ; adresa s uloëenòm novòm jmÇnem
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
         mov       byte ptr ds:[histor2],0  ; ë†dn† p©edvolba
         call      getkurz                  ; poskytnut° adresy kurzoru
         jc        precop3                  ; nen° ë†dnò soubor
                                          ;* nastaven° cesty k protàj®°mu oknu
         call      cmppath                  ; porovn†n° cest k oknñm
         je        precop1                  ; okna jsou shodn†
         call      test1file                ; je pr†ce s kurzorem ?
         jnz       precop4                  ; je kurzor (volba s ALT)
         call      soucins                  ; seáten° oznaáenòch souborñ
         or        cx,cx                    ; poáet oznaáenòch souborñ
         jnz       precop5                  ; je oznaáen nàjakò soubor
precop4: push      bp
         push      ds
         push      si
         call      getkurz                  ; poskytnut° kurzoru
         test      byte ptr ds:[si],10h     ; je adres†© ?
         pop       si
         pop       ds
         pop       bp
         jnz       precop1                  ; je adres†© - nenab°z° se cesta
precop5: push      bp
         call      getnakt                  ; poskytnut° adresy neaktivn°ho okna
         mov       di,cs:[bp+4]             ; p©°stupov† cesta
         mov       cs:[histor3],di          ; nastaven° cesty k protàj®°mu oknu
         inc       byte ptr cs:[histor2]    ; = 1 p©edvolba
         pop       bp
precop1:                                  ;* nastaven° jmÇna souboru
         mov       di,offset outbuf
         test      byte ptr ds:[si],10h     ; je adres†© ?
         jnz       precop2                  ; je adres†© - povolenÇ
         call      test1file                ; je pr†ce s kurzorem ?
         jnz       precop2                  ; je kurzor
         call      soucins                  ; souáet oznaáenòch souborñ
         cmp       cx,1                     ; je oznaáenò soubor ?
         ja        precop3                  ; je oznaáen v°ce neë 1 soubor
precop2: call      dekfile                  ; dek¢dov†n° jmÇna souboru
         mov       si,cs:[histor3]          ; adresa cesty k protàj®°mu adres†©i
         mov       cs:[histor4],si          ; adresa cesty jako 2. p©edvolba
         mov       word ptr cs:[histor3],offset outbuf ; tiskovò buffer
         inc       byte ptr cs:[histor2]    ; = 2 p©edvolby
precop3: cmp       byte ptr cs:[histor2],2  ; jsou 2 p©edvolby ?
         jne       precop6
         call      testaktwn                ; je neaktivn° okno zapnutÇ ?
         jnc       precop6                  ; neakt. okno je zapnutÇ
         mov       si,cs:[histor3]          ; p©edvolba 1
         xchg      si,cs:[histor4]          ; z†màna p©edvoleb
         mov       cs:[histor3],si
precop6: pop       ds
         pop       di
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
         mov       di,offset selbuf         ; c°lov† cesta operace
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
         mov       di,offset selbuf         ; c°lov† cesta operace
         mov       si,ds:[bp+4]             ; p©°stupov† cesta
         cmpsb                              ; porovn†n° diskñ
         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         ret

; -----------------------------------------------------------------------------
public   windret,windretx

windretx:
         call      windret                  ; n†vrat zobrazen° oknec
         call      outhelp                  ; zobrazen° z†kladn° n†povàdy
         ret

windret:                                  ;* n†vrat zobrazen° oken
         pushf
         push      bp
         push      ax
         push      bx
         push      ds
         push      es
         push      cs
         pop       ds
         push      cs
         pop       es
windret7:call      getakt
         call      window                   ; aktivn° okno
         call      getnakt
         call      window                   ; neaktivn° okno
windret9:pop       es
         pop       ds
         pop       bx
         pop       ax
         pop       bp
         popf
         ret
